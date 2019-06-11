param (
    [Parameter(Mandatory=$true)]
    [string]$BuildRoot,

    [string]$Name = [IO.Path]::GetFileName([IO.Path]::GetDirectoryName($BuildRoot + "/")),

    [string]$Version = $null,

    [string]$Prerelease = $null,

    [string]$VersionPrefix = "1.0",

    [string]$Author = $null,

    [string]$CompanyName = $null,

    [string]$LicenseUri = $null,

    [string]$ProjectUri = $null,

    [string]$IconUri = $null,

    [string]$HelpInfoUri = $null,

    [string[]]$Tags = @(),

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

    [bool]$RequireLicenseAcceptance = $false,

    [System.Collections.Specialized.OrderedDictionary]$PSData = $null,

    [object[]]$Dependencies = @(),

    [string]$DefaultDependencyRepository = "PSGallery",

    [string]$ProjectBuildFile = $null,

    [string]$BuildOutputDirectory = $null,

    [string]$BuildOutput = $null,

    [string]$SourcePath = $null,

    [string]$DocumentationPath = $null,

    [bool]$CreateDocumentation = $true,

    [string[]]$FilesPath = ("files", "lib", "bin"),

    [string]$TestsPath = $null,

    [string]$LicensePath = $null,

    [string]$SourceFilePath = $null,

    [string]$ManifestDestination = $null,

    [string]$MergedFilePath = $null,

    [int]$CodeCoverageMin = 0,

    [string]$AnalysisFailureLevel = "Error",

    [string]$AnalysisSettingsFile = $null,

    [string]$AnalysisResultsFile = $null,

    [string]$AnalysisSummaryFile = $null,

    [bool]$AllowFailingTests = $false,

    [string[]]$TestTags = @("*"),

    [string]$TestResultsFile = $null,

    [string]$CoverageResultsFile = $null,

    [string]$CoverageSummaryPath = $null,

    [bool]$UploadTestResultsToAppveyor = (Test-Path -Path "Env:APPVEYOR_JOB_ID"),

    [string[]]$ExtensionsToSign = ("*.ps1", "*.psd1", "*.psm1"),

    [bool]$Sign = $false,

    [bool]$SignFiles = $true,

    [string]$SignHashAlgorithm = "SHA256",

    [string]$CertificatePath = "Cert:\CurrentUser\My",

    [securestring]$CertificatePassword = $null,

    [string]$CertificateThumbprint = $null,

    [string]$CertificateSubject = $null,

    [bool]$PublishToRepository = $false,

    [string]$PublishToRepositoryName = $null,

    [bool]$PublishToArchive = $true,

    [string]$ArchiveName = $null,

    [string]$ArchiveDestination = $null,

    [bool]$PublishToAppveyor = (Test-Path -Path "Env:APPVEYOR_JOB_ID")
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrEmpty($ProjectBuildFile)) { $ProjectBuildFile = Join-Path -Path $BuildRoot -ChildPath "build.ps1" }
if (Test-Path -Path $ProjectBuildFile) { . $ProjectBuildFile }

if ([string]::IsNullOrWhiteSpace($Version))
{
    if (-not [string]::IsNullOrWhiteSpace($ENV:APPVEYOR_BUILD_VERSION))
    {
        $Version = $ENV:APPVEYOR_BUILD_VERSION
    }
    elseif (-not [string]::IsNullOrWhiteSpace($ENV:BUILD_NUMBER))
    {
        $Version = "$VersionPrefix.$($ENV:BUILD_NUMBER)"
    }
    else
    {
        $Version = "$VersionPrefix.0"
    }
}

if ([string]::IsNullOrEmpty($BuildOutputDirectory)) { $BuildOutputDirectory = Join-Path -Path $BuildRoot -ChildPath "output" }
if ([string]::IsNullOrEmpty($BuildOutput)) { $BuildOutput = Join-Path -Path $BuildOutputDirectory -ChildPath $Name }
if ([string]::IsNullOrEmpty($SourcePath)) { $SourcePath = Join-Path -Path $BuildRoot -ChildPath "src" }
if ([string]::IsNullOrEmpty($DocumentationPath)) { $DocumentationPath = Join-Path $BuildRoot -ChildPath "docs" }
if ([string]::IsNullOrEmpty($TestsPath)) { $TestsPath = Join-Path -Path $BuildRoot -ChildPath "tests" }
if ([string]::IsNullOrEmpty($TestResultsFile)) { $TestResultsFile = Join-Path -Path $BuildOutputDirectory -ChildPath "TestResults.xml" }
if ([string]::IsNullOrEmpty($CoverageResultsFile)) { $CoverageResultsFile = Join-Path -Path $BuildOutputDirectory -ChildPath "CoverageResults.xml" }
if ([string]::IsNullOrEmpty($CoverageSummaryPath)) { $CoverageSummaryPath = Join-Path -Path $BuildOutputDirectory -ChildPath "CoverageSummary.txt" }
if ([string]::IsNullOrEmpty($LicensePath)) { $LicensePath = Join-Path -Path $BuildRoot -ChildPath "LICENSE" }
if ([string]::IsNullOrEmpty($SourceFilePath)) { $SourceFilePath = Join-Path -Path $SourcePath -ChildPath "$Name.psm1" }
if ([string]::IsNullOrEmpty($ManifestDestination)) { $ManifestDestination = Join-Path -Path $BuildOutput -ChildPath "$Name.psd1" }
if ([string]::IsNullOrEmpty($MergedFilePath)) { $MergedFilePath = Join-Path -Path $BuildOutput -ChildPath "$Name.psm1" }
if ([string]::IsNullOrEmpty($AnalysisSettingsFile)) { $AnalysisSettingsFile = Join-Path -Path $BuildRoot -ChildPath "PSScriptAnalyzerSettings.psd1" }
if ([string]::IsNullOrEmpty($AnalysisResultsFile)) { $AnalysisResultsFile = Join-Path -Path $BuildOutputDirectory -ChildPath "AnalysisResults.xml" }
if ([string]::IsNullOrEmpty($AnalysisSummaryFile)) { $AnalysisSummaryFile = Join-Path -Path $BuildOutputDirectory -ChildPath "AnalysisSummary.txt" }
if ([string]::IsNullOrEmpty($ArchiveName)) { $ArchiveName = "$Name-$($Version)$($Prerelease).zip" }
if ([string]::IsNullOrEmpty($ArchiveDestination)) { $ArchiveDestination = Join-Path -Path $BuildOutputDirectory -ChildPath $ArchiveName }

Task "Dependencies" {
    foreach ($dependencyLine in $Dependencies)
    {
        $dependency = Convert-Dependency -InputObject $dependencyLine -Repository $DefaultDependencyRepository
        $moduleArgs = [hashtable]::new($dependency)
        $moduleArgs.Remove("External")
        if ($moduleArgs.ContainsKey("Repository")) { $moduleArgs.Remove("Repository") }

        $module = Import-Module -PassThru -ErrorAction SilentlyContinue @moduleArgs
        if (-not $dependency.External -and $null -eq $module)
        {
            $dependency.Remove("External")

            Write-Host "Installing: $($dependency|ConvertTo-Json)"
            Install-Module @dependency -Force
            Write-Verbose "Installed $($moduleArgs.Name)"
        }

        Import-Module @moduleArgs
    }
}

Task "Clean" {
    Requires "BuildOutputDirectory"

    if (Test-Path -Path $BuildOutputDirectory)
    {
        Remove-Item -Path $BuildOutputDirectory -Recurse -Force
    }
}

Task "Compile" @{
    Inputs = { @(Get-ChildItem $SourcePath -Recurse -Include "*.*" -Exclude "TempPSBuilder.psm1" -File) + @(Get-Item "build.ps1") }
    Outputs = { $MergedFilePath }
    Jobs = "Dependencies", {
        Requires "BuildOutput", "FilesPath", "LicensePath"

        #Create output directory
        if (-not (Test-Path -Path $BuildOutput))
        {
            New-Item -Path $BuildOutput -ItemType "Directory" -Force | Out-Null
        }

        #Copy additional files
        foreach ($fileLocation in $FilesPath)
        {
            $path = (Join-Path -Path $SourcePath -ChildPath $fileLocation)
            if (Test-Path -Path $path)
            {
                Copy-Item -Path $path -Destination $BuildOutput -Recurse -Container -Force
            }
        }

        #Copy license files
        if (-not [string]::IsNullOrEmpty($LicensePath) -and (Test-Path -Path $LicensePath))
        {
            Copy-Item -Path $LicensePath -Destination $BuildOutput -Force
        }

        Invoke-CompileModule -Name $Name -Source $SourcePath -Destination $MergedFilePath

        #Create module manifest
        $manifestArgs = @{
            Name = $Name
            Path = $ManifestDestination
            ModuleFilePath = $MergedFilePath
            Author = $Author
            CompanyName = $CompanyName
            Description = $Description
            Guid = $Guid
            Version = $Version
            CompatiblePSEditions = $CompatiblePSEditions
            PowerShellVersion = $PowerShellVersion
            PowerShellHostName = $PowerShellHostName
            PowerShellHostVersion = $PowerShellHostVersion
            DotNetFrameworkVersion = $DotNetFrameworkVersion
            CLRVersion = $CLRVersion
            ProcessorArchitecture = $ProcessorArchitecture
            RequiredAssemblies = $RequiredAssemblies
            ScriptsToProcess = $ScriptsToProcess
            TypesToProcess = $TypesToProcess
            FormatsToProcess = $FormatsToProcess
            NestedModules = $NestedModules
            DefaultCommandPrefix = $DefaultCommandPrefix
            Dependencies = $Dependencies
            Prerelease = $Prerelease
            RequireLicenseAcceptance = $RequireLicenseAcceptance
            LicenseUri = $LicenseUri
            ProjectUri = $ProjectUri
            IconUri = $IconUri
            HelpInfoUri = $HelpInfoUri
            Tags = $Tags
            PSData = $PSData
        }
        Invoke-CreateModuleManifest @manifestArgs
    }
}

Task "Docs" @{
    If = {$CreateDocumentation}
    Jobs = "Compile", {
        Invoke-CreateMarkdown -Path $DocumentationPath -Manifest $ManifestDestination
        Invoke-CreateHelp -Source $DocumentationPath -Destination $BuildOutput
    }
}

Task "Sign" @{
    If = {$Sign}
    Jobs = "Compile", "Docs", {
        $signArgs = @{
            Name = $Name
            Path = $BuildOutput
            CertificateThumbprint = $CertificateThumbprint
            CertificateSubject = $CertificateSubject
            CertificatePath = $CertificatePath
            CertificatePassword = $CertificatePassword
            HashAlgorithm = $SignHashAlgorithm
        }

        Invoke-Sign @signArgs
    }
}

Task "Analyze" "Compile", {
    $analysisArgs = @{
        Path = $BuildOutput
        SettingsFile = $AnalysisSettingsFile
        ResultsFile = $AnalysisResultsFile
        SummaryFile = $AnalysisSummaryFile
        FailureLevel = $AnalysisFailureLevel
    }

    Invoke-CodeAnalysis @analysisArgs
}

Task "Test" "Compile", {
    $pesterArgs = @{
        Path = $TestsPath
        Tags = $TestTags
        Module = $ManifestDestination
        OutputPath = $TestResultsFile
        MinCoverage = $CodeCoverageMin
        CoverageOutputPath = $CoverageResultsFile
        CoverageSummaryPath = $CoverageSummaryPath
        AllowFailingTests = $AllowFailingTests
    }
    Invoke-PesterTest @pesterArgs

    if (-not [string]::IsNullOrEmpty($TestResultsFile))
    {
        if ($UploadTestResultsToAppveyor) {
            [void][System.Net.WebClient]::new().UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", $TestResultsFile)
        }
    }
}

Task "Archive" "Compile", {
    $zipFile = [System.IO.FileStream]::new($ArchiveDestination, [System.IO.FileMode]::Create)
    $archive = [System.IO.Compression.ZipArchive]::new($zipFile, [System.IO.Compression.ZipArchiveMode]::Create)
    try
    {
        (Get-ChildItem -Path $BuildOutput -Recurse -File).ForEach({
            $name = $_.FullName.Substring($BuildOutput.Length + 1)
            $entry = $archive.CreateEntry($name)
            $entry.LastWriteTime = $_.LastWriteTime
            $fs = [System.IO.FileStream]::new($_.FullName, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
            $stream = $entry.Open()
            try
            {
                $fs.CopyTo($stream, 81920)
            }
            finally
            {
                if ($null -ne $stream) { $stream.Dispose() }
                if ($null -ne $fs) { $fs.Dispose() }
            }
        })
    }
    finally
    {
        if ($null -ne $archive) { $archive.Dispose() }
        if ($null -ne $zipFile) { $zipFile.Dispose() }
    }
}

Task "Build" "Compile", "Docs", "Sign", "Archive"

Task "Publish" "Build", {
    if ($PublishToAppveyor)
    {
        Push-AppveyorArtifact $ArchiveDestination
    }

    if ($PublishToRepository)
    {
        Invoke-PublishToRepository -NugetApiKey $env:NugetApiKey -Repository $PublishToRepositoryName -Path $BuildOutput
    }
}

Task "GenerateCert" {
    Invoke-GenerateSelfSignedCert
}
