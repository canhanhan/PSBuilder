function Invoke-CreateHelp
{
    param (
        [Parameter(Mandatory=$true)]
        [string]$Source,

        [Parameter(Mandatory=$true)]
        [string]$Destination,

        [string]$Language="en-US"
    )

    $destinationPath = Join-Path -Path $Destination -ChildPath $Language
    New-ExternalHelp -Path $Source -OutputPath $destinationPath -Force | Out-Null
}