function Invoke-ReplaceMagicMarker
{
    param (
        [Parameter(Mandatory=$true)]
        [scriptblock]$Builder
    )

    $mergedFileContent = Get-Content -Path $MergedFilePath -Raw
    if ($mergedFileContent -match "(?m)^([ \t]*)### MERGE HERE ###\s*$")
    {
        $whitespace = $Matches[1]
        $source = $builder.Invoke() -replace "(?m)^(?!(?:\r|\n|$))", $whitespace
        $mergedFileContent = $mergedFileContent -replace "(?m)^([ \t]*)### MERGE HERE ###\s*$", $source

        Set-Content -Path $MergedFilePath -Value $mergedFileContent -Force
    }
    else
    {
        Write-Warning "Found $SourceFilePath but magic marker '### MERGE HERE ###' does not exist. Skipping compile..."
    }
}