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
        [string]$ModuleFilePath
    )

    $module = Get-Module -Name $ModuleFilePath -ListAvailable
    $Exports = @{
        "Aliases" = $module.ExportedAliases.Keys
        "Cmdlets" = $module.ExportedCmdlets.Keys
        "Functions" = $module.ExportedFunctions.Keys
        "Variables" = $module.ExportedVariables.Keys
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
    }

    New-ModuleManifest -Path $Path @ManifestArguments
}