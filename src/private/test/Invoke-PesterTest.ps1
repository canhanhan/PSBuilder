function Invoke-PesterTest
{
    param (
        [string[]]$Tags = @(),
        [string]$Path,
        [string]$Module,
        [string]$OutputPath,
        [int]$MinCoverage=0
    )

    if ($Tags -eq "*") { $Tags = @() }

    if (-not (Test-Path -Path $Path))
    {
        $testCoverage = 0
    }
    else
    {
        Set-Location -Path $Path
        Import-Module -Name $Module -Force
        $files = @(Get-ChildItem -Path ([IO.Path]::GetDirectoryName($Module)) -Include "*.ps1","*.psm1" -File -Recurse)
        $testResult = Invoke-Pester -PassThru -CodeCoverage $files -Tag $tags -OutputFile $OutputPath -OutputFormat "NUnitXml"

        assert ($testResult.FailedCount -eq 0) ('Failed {0} Unit tests. Aborting Build' -f $testResult.FailedCount)

        if (0 -eq $testResult.CodeCoverage.NumberOfCommandsAnalyzed)
        {
            $testCoverage = 0
        }
        else
        {
            $testCoverage = [int]($testResult.CodeCoverage.NumberOfCommandsExecuted / $testResult.CodeCoverage.NumberOfCommandsAnalyzed * 100)
        }
    }

    Write-Output "Code coverage: ${testCoverage}%"

    assert ($MinCoverage -le $testCoverage) ('Code coverage must be higher or equal to {0}%. Current coverage: {1}%' -f ($MinCoverage, $testCoverage))
}