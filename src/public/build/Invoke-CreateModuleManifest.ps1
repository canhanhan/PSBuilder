function Invoke-CreateModuleManifest
{
    param (
        [Parameter(Mandatory=$true)]
        [string]$Name,

        [Parameter(Mandatory=$true)]
        [string]$Guid,

        [Parameter(Mandatory=$true)]
        [string]$Author,

        [Parameter(Mandatory=$true)]
        [string]$Description,

        [Parameter(Mandatory=$true)]
        [string]$Path,

        [Parameter(Mandatory=$true)]
        [string]$ModuleFilePath,

        [Parameter(Mandatory=$true)]
        [string]$Version,

        [string]$LicenseUri = $null,
        [string]$IconUri = $null,
        [string]$ProjectUri = $null,
        [string[]]$Tags = $null,
        [string]$Prerelease = $null
    )

    $module = Get-Module -Name $ModuleFilePath -ListAvailable
    $Exports = @{
        "Aliases" = @($module.ExportedAliases.Keys)
        "Cmdlets" = @($module.ExportedCmdlets.Keys)
        "Functions" = @($module.ExportedFunctions.Keys)
        "Variables" = @($module.ExportedVariables.Keys)
    }

    $ManifestArguments = @{
        "RootModule" = "$Name.psm1"
        "Guid" = $Guid
        "Author" = $Author
        "Description" = $Description
        "Copyright" = "(c) $((Get-Date).Year) $Author. All rights reserved."
        "AliasesToExport" = $Exports.Aliases
        "CmdletsToExport" = $Exports.Cmdlets
        "FunctionsToExport" = $Exports.Functions
        "VariablesToExport" = $Exports.Variables
        "ModuleVersion" = $Version
    }

    if ($PSBoundParameters.ContainsKey("LicenseUri"))
    {
        $ManifestArguments.LicenseUri = $LicenseUri
    }

    if ($PSBoundParameters.ContainsKey("ProjectUri"))
    {
        $ManifestArguments.ProjectUri = $ProjectUri
    }

    if ($PSBoundParameters.ContainsKey("IconUri"))
    {
        $ManifestArguments.IconUri = $IconUri
    }

    if ($PSBoundParameters.ContainsKey("Tags") -and $Tags.Count -gt 0)
    {
        $ManifestArguments.Tags = $Tags
    }

    New-ModuleManifest -Path $Path @ManifestArguments

    if ($PSBoundParameters.ContainsKey("Prerelease"))
    {
        Update-ModuleManifest -Path $Path -Prerelease $Prerelease
    }
}