Task "Analyze" "Compile", {
    Requires "BuildOutput", "AnalysisFailureLevel", "AnalysisSettingsFile"

    $analysisParameters = @{ "Path"= $BuildOutput }
    if (-not [string]::IsNullOrEmpty($AnalysisSettingsFile)) { $analysisParameters["Settings"] = $AnalysisSettingsFile }
    $analysisResult = Invoke-ScriptAnalyzer @analysisParameters -Recurse
    $analysisResult | Format-Table

    $warnings = $analysisResult.Where({ $_.Severity -eq "Warning" -or $_.Severy -eq "Warning" }).Count
    $errors = $analysisResult.Where({ $_.Severy -eq "Error" }).Count
    "Script analyzer triggered {0} warnings and {1} errors" -f $warnings, $errors

    if ($AnalysisFailureLevel -eq "Warning")
    {
        Assert ($warnings -eq 0 -and $errors -eq 0) "Build failed due to warnings or errors found in analysis."
    }
    elseif ($AnalysisFailureLevel -eq "Error")
    {
        Assert ($errors -eq 0) "Build failed due to errors found in analysis."
    }
}

task "RunPester" "Compile", {
    Requires "BuildRoot", "ManifestDestination", "CodeCoverageMin", "TestTags"

    $testResult = Start-Job -ArgumentList ("$BuildRoot\tests", $ManifestDestination, $MergedFilePath, $testTags) -ScriptBlock {
        param($testPath, $manifestFilePath, $moduleFilePath, $tags)

        Set-StrictMode -Version Latest
        $ErrorActionPreference = "Stop"

        Push-Location -StackName "Testing" -Path $testPath

        try
        {
            Import-Module -Name $manifestFilePath -Global -Force
            Invoke-Pester -PassThru -Verbose -CodeCoverage $moduleFilePath -Tag $tags
        }
        finally
        {
            Pop-Location -StackName "Testing"
        }
    } | Receive-Job -Wait -AutoRemoveJob

    assert ($testResult.FailedCount -eq 0) ('Failed {0} Unit tests. Aborting Build' -f $testResult.FailedCount)

    if (0 -eq $testResult.CodeCoverage.NumberOfCommandsAnalyzed)
    {
        $testCoverage = 0
    }
    else
    {
        $testCoverage = [int]($testResult.CodeCoverage.NumberOfCommandsExecuted / $testResult.CodeCoverage.NumberOfCommandsAnalyzed * 100)
    }

    "Pester code coverage: ${testCoverage}%"

    assert ($CodeCoverageMin -le $testCoverage) ('Code coverage must be higher or equal to {0}%. Current coverage: {1}%' -f ($CodeCoverageMin, $testCoverage))
}

task Test "Compile", "Analyze", "RunPester"