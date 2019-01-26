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

        [string]$CompanyName = $null,
        [object[]]$Dependencies,
        [string]$LicenseUri = $null,
        [string]$IconUri = $null,
        [string]$ProjectUri = $null,
        [string]$HelpInfoUri = $null,
        [string[]]$CompatiblePSEditions = $null,
        [string]$PowerShellVersion = $null,
        [string]$PowerShellHostName = $null,
        [string]$PowerShellHostVersion = $null,
        [string]$DotNetFrameworkVersion = $null,
        [string]$CLRVersion = $null,
        [string]$ProcessorArchitecture = $null,
        [string[]]$RequiredAssemblies = $null,
        [string[]]$ScriptsToProcess = $null,
        [string[]]$TypesToProcess = $null,
        [string[]]$FormatsToProcess = $null,
        [string[]]$NestedModules = $null,
        [string]$DefaultCommandPrefix = $null,
        [string[]]$Tags = $null,
        [string]$Prerelease = $null
    )

    $module = Get-Module -Name $ModuleFilePath -ListAvailable
    $Exports = @{
        "Aliases" = @($module.ExportedAliases.Keys)
        "Cmdlets" = @($module.ExportedCmdlets.Keys)
        "DscResources" = @($module.ExportedDscResources)
        "Functions" = @($module.ExportedFunctions.Keys)
        "Variables" = @($module.ExportedVariables.Keys)
    }

    $GalleryDependencies = [System.Collections.ArrayList]::new()
    $ExternalDependencies = [System.Collections.ArrayList]::new()

    foreach ($dependencyLine in $Dependencies)
    {
        $dependency = Convert-Dependency -InputObject $dependencyLine

        if ($dependency.External)
        {
            [void]$ExternalDependencies.Add($dependency.Name)
        }

        if ($dependency.ContainsKey("Repository")) { $dependency.Remove("Repository") }
        if ($dependency.ContainsKey("MinimumVersion"))
        {
            $dependency["ModuleVersion"] = $dependency["MinimumVersion"]
            $dependency.Remove("MinimumVersion")
        }
        $dependency["ModuleName"] = $dependency["Name"]
        $dependency.Remove("Name")
        $dependency.Remove("External")

        [void]$GalleryDependencies.Add([Microsoft.PowerShell.Commands.ModuleSpecification]::new($dependency))
    }

    $ManifestArguments = @{
        "RootModule" = "$Name.psm1"
        "Guid" = $Guid
        "Author" = $Author
        "Description" = $Description
        "Copyright" = "(c) $((Get-Date).Year) $Author. All rights reserved."
        "ModuleVersion" = $Version
    }

    if (-not [string]::IsNullOrEmpty($CompanyName))
    {
        $ManifestArguments.CompanyName = $CompanyName
    }

    if ($Exports.Aliases.Count -gt 0)
    {
        $ManifestArguments.AliasesToExport = $Exports.Aliases
    }

    if ($Exports.Cmdlets.Count -gt 0)
    {
        $ManifestArguments.CmdletsToExport = $Exports.Cmdlets
    }

    if ($Exports.DscResources.Count -gt 0)
    {
        $ManifestArguments.DscResourcesToExport = $Exports.DscResources
    }

    if ($Exports.Functions.Count -gt 0)
    {
        $ManifestArguments.FunctionsToExport = $Exports.Functions
    }

    if ($Exports.Variables.Count -gt 0)
    {
        $ManifestArguments.VariablesToExport = $Exports.Variables
    }

    if ($GalleryDependencies.Count -gt 0)
    {
        $ManifestArguments.RequiredModules = $GalleryDependencies.ToArray()
    }

    if ($ExternalDependencies.Count -gt 0)
    {
        $ManifestArguments.ExternalModuleDependencies = $ExternalDependencies.ToArray()
    }

    if (-not [string]::IsNullOrEmpty($LicenseUri))
    {
        $ManifestArguments.LicenseUri = $LicenseUri
    }

    if (-not [string]::IsNullOrEmpty($ProjectUri))
    {
        $ManifestArguments.ProjectUri = $ProjectUri
    }

    if (-not [string]::IsNullOrEmpty($IconUri))
    {
        $ManifestArguments.IconUri = $IconUri
    }

    if (-not [string]::IsNullOrEmpty($HelpInfoUri))
    {
        $ManifestArguments.HelpInfoUri = $HelpInfoUri
    }

    if ($null -ne $CompatiblePSEditions -and $CompatiblePSEditions.Count -gt 0)
    {
        $ManifestArguments.CompatiblePSEditions = $CompatiblePSEditions
    }

    if (-not [string]::IsNullOrEmpty($PowerShellVersion))
    {
        $ManifestArguments.PowerShellVersion = $PowerShellVersion
    }

    if (-not [string]::IsNullOrEmpty($PowerShellHostName))
    {
        $ManifestArguments.PowerShellHostName = $PowerShellHostName
    }

    if (-not [string]::IsNullOrEmpty($PowerShellHostVersion))
    {
        $ManifestArguments.PowerShellHostVersion = $PowerShellHostVersion
    }

    if (-not [string]::IsNullOrEmpty($DotNetFrameworkVersion))
    {
        $ManifestArguments.DotNetFrameworkVersion = $DotNetFrameworkVersion
    }

    if (-not [string]::IsNullOrEmpty($CLRVersion))
    {
        $ManifestArguments.CLRVersion = $CLRVersion
    }

    if (-not [string]::IsNullOrEmpty($ProcessorArchitecture))
    {
        $ManifestArguments.ProcessorArchitecture = $ProcessorArchitecture
    }

    if ($null -ne $RequiredAssemblies -and $RequiredAssemblies.Count -gt 0)
    {
        $ManifestArguments.RequiredAssemblies = $RequiredAssemblies
    }

    if ($null -ne $ScriptsToProcess -and $ScriptsToProcess.Count -gt 0)
    {
        $ManifestArguments.ScriptsToProcess = $ScriptsToProcess
    }

    if ($null -ne $TypesToProcess -and $TypesToProcess.Count -gt 0)
    {
        $ManifestArguments.TypesToProcess = $TypesToProcess
    }

    if ($null -ne $FormatsToProcess -and $FormatsToProcess.Count -gt 0)
    {
        $ManifestArguments.FormatsToProcess = $FormatsToProcess
    }

    if ($null -ne $NestedModules -and $NestedModules.Count -gt 0)
    {
        $ManifestArguments.NestedModules = $NestedModules
    }

    if (-not [string]::IsNullOrEmpty($DefaultCommandPrefix))
    {
        $ManifestArguments.DefaultCommandPrefix = $DefaultCommandPrefix
    }

    if (-not [string]::IsNullOrEmpty($Prerelease))
    {
        $ManifestArguments.Prerelease = $Prerelease
    }

    if ($null -ne $Tags -and $Tags.Count -gt 0)
    {
        $ManifestArguments.Tags = $Tags
    }

    if (-not (Test-Path -Path $Path))
    {
        New-ModuleManifest -Path $Path -VariablesToExport @()
    }

    Update-ModuleManifest -Path $Path @ManifestArguments
}
