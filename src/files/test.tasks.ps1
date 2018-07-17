task RunPester -requiredVariables "buildRoot", "mergedFilePath", "isScript", "CodeCoverageMin" {
    $testResult = Start-Job -ArgumentList ("$BuildRoot\tests", $mergedFilePath, $isScript) -ScriptBlock {
        param($testPath, $filePath, $isScript)

        Set-StrictMode -Version Latest
        $ErrorActionPreference = "Stop"

        Push-Location -StackName "Testing" -Path $testPath

        try
        {
            if ($isScript) { . $filePath } else { Import-Module -Name $filePath -Force }
            Invoke-Pester -PassThru -Verbose -CodeCoverage $filePath
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

task Test -depends Stage, RunPester