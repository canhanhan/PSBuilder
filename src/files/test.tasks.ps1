task Analyze -requiredVariables "BuildOutput", "AnalysisFailureLevel", "AnalysisSettingsFile" {
    $analysisParameters = @{ "Path"= $BuildOutput }
    if (-not [string]::IsNullOrEmpty($AnalysisSettingsFile)) { $analysisParameters["Settings"] = $AnalysisSettingsFile }
    $analysisResult = Invoke-ScriptAnalyzer @analysisParameters -Recurse
    $analysisResult | Format-Table

    $warnings = $analysisResult.Where({ $_.Severity -eq "Warning" -or $_.Severy -eq "Warning" }).Count
    $errors = $analysisResult.Where({ $_.Severy -eq "Error" }).Count
    "Script analyzer triggered {0} warnings and {1} errors" -f $warnings, $errors

    if ($AnalysisFailureLevel -eq "Warning")
    {
        Assert -conditionToCheck ($warnings -eq 0 -and $errors -eq 0) -failureMessage "Build failed due to warnings or errors found in analysis."
    }
    elseif ($AnalysisFailureLevel -eq "Error")
    {
        Assert -conditionToCheck ($errors -eq 0) -failureMessage "Build failed due to errors found in analysis."
    }
}

task RunPester -requiredVariables "buildRoot", "ManifestDestination", "isScript", "CodeCoverageMin", "TestTags" {
    $testResult = Start-Job -ArgumentList ("$BuildRoot\tests", $ManifestDestination, $isScript, $testTags) -ScriptBlock {
        param($testPath, $filePath, $isScript, $tags)

        Set-StrictMode -Version Latest
        $ErrorActionPreference = "Stop"

        Push-Location -StackName "Testing" -Path $testPath

        try
        {
            if ($isScript) { . $filePath } else { Import-Module -Name $filePath -Global -Force }
            Invoke-Pester -PassThru -Verbose -CodeCoverage $filePath -Tag $tags
        }
        finally
        {
            Pop-Location -StackName "Testing"
        }
    } | Receive-Job -Wait -AutoRemoveJob

    assert ($testResult.FailedCount -eq 0) ('Failed {0} Unit tests. Aborting Build' -f $testResult.FailedCount)

    $testCoverage = [int]($testResult.CodeCoverage.NumberOfCommandsExecuted / $testResult.CodeCoverage.NumberOfCommandsAnalyzed * 100)
    "Pester code coverage: ${testCoverage}%"

    assert ($CodeCoverageMin -le $testCoverage) ('Code coverage must be higher or equal to {0}%. Current coverage: {1}%' -f ($CodeCoverageMin, $testCoverage))
}

task Test -depends Stage, Analyze, RunPester