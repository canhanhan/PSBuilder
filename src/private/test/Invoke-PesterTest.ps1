function Invoke-PesterTest
{
    param (
        [string[]]$Tags = @(),
        [string]$Path,
        [string]$Module,
        [string]$OutputPath,
        [string]$CoverageOutputPath,
        [string]$CoverageSummaryPath,
        [int]$MinCoverage=0
    )

    if ($Tags -eq "*") { $Tags = @() }

    if (-not (Test-Path -Path $Path))
    {
        $testCoverage = 0
    }
    else
    {
        $testResult = Start-Job -ScriptBlock {
            Set-StrictMode -Version Latest
            $ErrorActionPreference = "Stop"

            Set-Location -Path $using:Path
            Import-Module -Name $using:Module -Force
            $files = @(Get-ChildItem -Path ([IO.Path]::GetDirectoryName($using:Module)) -Include "*.ps1","*.psm1" -File -Recurse)
            $pesterArgs = @{
                CodeCoverage = $files
                Tag = $using:Tags
                OutputFile = $using:OutputPath
                OutputFormat = "NUnitXml"
                CodeCoverageOutputFile = $using:CoverageOutputPath
                CodeCoverageOutputFileFormat = "JaCoCo"
                PassThru = $true
            }

            Invoke-Pester @pesterArgs
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

        $codeCoverageSummary = $testResult.CodeCoverage.MissedCommands | Format-Table -AutoSize @{Name="File";Expr={ [IO.Path]::GetFileName($_.File) }}, Function, Line, Command | Out-String
        [IO.File]::WriteAllText($CoverageSummaryPath, "Code coverage: ${testCoverage}%`r`n`r`n$codeCoverageSummary")
    }

    Write-Output "Code coverage: ${testCoverage}%"

    assert ($MinCoverage -le $testCoverage) ('Code coverage must be higher or equal to {0}%. Current coverage: {1}%' -f ($MinCoverage, $testCoverage))
}