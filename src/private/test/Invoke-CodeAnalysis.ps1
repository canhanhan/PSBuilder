function Invoke-CodeAnalysis
{
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path,

        [string]$FailureLevel,

        [string]$SettingsFile,

        [string]$ResultsFile,

        [string]$SummaryFile
    )

    $analysisParameters = @{}
    if (-not [string]::IsNullOrEmpty($SettingsFile) -and (Test-Path -Path $SettingsFile)) { $analysisParameters["Settings"] = $SettingsFile }
    $analysisResult = Invoke-ScriptAnalyzer -Path $Path -Recurse @analysisParameters
    $analysisResult | Format-Table -AutoSize | Out-String | Tee-Object -FilePath $SummaryFile
    ($analysisResult | ConvertTo-Xml -NoTypeInformation -Depth 3).Save($ResultsFile)

    $warnings = $analysisResult.Where({ $_.Severity -eq "Warning" -or $_.Severity -eq "Warning" }).Count
    $errors = $analysisResult.Where({ $_.Severity -eq "Error" }).Count
    "Script analyzer triggered {0} warnings and {1} errors" -f $warnings, $errors

    if ($FailureLevel -eq "Warning")
    {
        Assert ($warnings -eq 0 -and $errors -eq 0) "Build failed due to warnings or errors found in analysis."
    }
    elseif ($FailureLevel -eq "Error")
    {
        Assert ($errors -eq 0) "Build failed due to errors found in analysis."
    }
}