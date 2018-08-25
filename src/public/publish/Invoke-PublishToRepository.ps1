function Invoke-PublishToRepository
{
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path,

        [Parameter(Mandatory=$false)]
        [string]$Repository,

        [Parameter(Mandatory=$false)]
        [string]$NugetApiKey
    )

    $publishParams = @{ "Path" = $Path }
    if (-not [string]::IsNullOrEmpty($Repository)) { $publishParams["Repository"] = $Repository }
    if (-not [string]::IsNullOrEmpty($NugetApiKey)) { $publishParams["NuGetApiKey"] = $NugetApiKey }

    Publish-Module @publishParams
}