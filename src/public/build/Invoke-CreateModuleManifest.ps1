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
        [string]$ReleaseNotes = $null,
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
        [string]$Prerelease = $null,
        [bool]$RequireLicenseAcceptance=$false
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

        [void]$GalleryDependencies.Add($dependency)
    }

    $ManifestArguments = [ordered]@{
        "RootModule" = "$Name.psm1"
        "ModuleVersion" = $Version
        "GUID" = $Guid
        "Author" = $Author
        "CompanyName" = "Unknown"
        "Copyright" = "(c) $((Get-Date).Year) $Author. All rights reserved."
        "Description" = $Description
    }

    if (-not [string]::IsNullOrEmpty($CompanyName))
    {
        $ManifestArguments.CompanyName = $CompanyName
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

    if ($GalleryDependencies.Count -gt 0)
    {
        $ManifestArguments.RequiredModules = $GalleryDependencies.ToArray()
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

    if ($Exports.Functions.Count -gt 0)
    {
        $ManifestArguments.FunctionsToExport = $Exports.Functions
    }

    if ($Exports.Cmdlets.Count -gt 0)
    {
        $ManifestArguments.CmdletsToExport = $Exports.Cmdlets
    }

    if ($Exports.Variables.Count -gt 0)
    {
        $ManifestArguments.VariablesToExport = $Exports.Variables
    }

    if ($Exports.Aliases.Count -gt 0)
    {
        $ManifestArguments.AliasesToExport = $Exports.Aliases
    }

    if ($Exports.DscResources.Count -gt 0)
    {
        $ManifestArguments.DscResourcesToExport = $Exports.DscResources
    }

    if ($null -ne $Tags -and $Tags.Count -gt 0)
    {
        $ManifestArguments.Tags = $Tags
    }

    $ManifestArguments.PrivateData = [ordered]@{ "PSData" = [ordered]@{} }
    if (-not [string]::IsNullOrEmpty($LicenseUri))
    {
        $ManifestArguments.PrivateData.PSData.LicenseUri = $LicenseUri
    }

    if (-not [string]::IsNullOrEmpty($ProjectUri))
    {
        $ManifestArguments.PrivateData.PSData.ProjectUri = $ProjectUri
    }

    if (-not [string]::IsNullOrEmpty($IconUri))
    {
        $ManifestArguments.PrivateData.PSData.IconUri = $IconUri
    }

    if (-not [string]::IsNullOrEmpty($ReleaseNotes))
    {
        $ManifestArguments.PrivateData.PSData.ReleaseNotes = $ReleaseNotes
    }

    if (-not [string]::IsNullOrEmpty($Prerelease))
    {
        $ManifestArguments.PrivateData.PSData.Prerelease = $Prerelease
    }

    if ($RequireLicenseAcceptance)
    {
        $ManifestArguments.PrivateData.PSData.RequireLicenseAcceptance = $true
    }

    if ($ExternalDependencies.Count -gt 0)
    {
        $ManifestArguments.PrivateData.PSData.ExternalModuleDependencies = $ExternalDependencies.ToArray()
    }

    if (-not [string]::IsNullOrEmpty($HelpInfoUri))
    {
        $ManifestArguments.HelpInfoUri = $HelpInfoUri
    }

    if (-not [string]::IsNullOrEmpty($DefaultCommandPrefix))
    {
        $ManifestArguments.DefaultCommandPrefix = $DefaultCommandPrefix
    }

    New-DataFile -Path $Path -Data $ManifestArguments
}
