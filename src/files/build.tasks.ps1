param (
    [Parameter(Mandatory=$true)]
    [string]$BuildRoot,

    [string]$Name = [IO.Path]::GetFileName([IO.Path]::GetDirectoryName($BuildRoot + "/")),

    [string]$Version = $null,

    [string]$VersionSuffix = $null,

    [string]$ProjectBuildFile = $null,

    [string]$BuildOutputDirectory = $null,

    [string]$BuildOutput = $null,

    [string]$SourcePath = $null,

    [string]$DocumentationPath = $null,

    [string[]]$FilesPath = ("files", "lib", "bin"),

    [string]$TestsPath = $null,

    [string]$LicensePath = $null,

    [string]$SourceFilePath = $null,

    [string]$ManifestDestination = $null,

    [string]$MergedFilePath = $null,

    [int]$CodeCoverageMin = 0,

    [string]$AnalysisFailureLevel = "Error",

    [string]$AnalysisSettingsFile = $null,

    [string[]]$TestTags = @("*"),

    [string]$TestResultsFile = $null,

    [string]$CoverageResultsFile = $null,

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

    [string]$PublishToArchiveName = $null,

    [string]$PublishToArchiveDestination = $null,

    [bool]$PublishToAppveyor = (Test-Path -Path "Env:APPVEYOR_JOB_ID"),

    [string]$LicenseUri = $null,

    [string]$ProjectUri = $null,

    [string]$IconUri = $null,

    [string[]]$Tags = @()
)

if ([string]::IsNullOrEmpty($ProjectBuildFile)) { $ProjectBuildFile = Join-Path -Path $BuildRoot -ChildPath "build.ps1" }
if (Test-Path -Path $ProjectBuildFile) { . $ProjectBuildFile }

if ([string]::IsNullOrEmpty($BuildOutputDirectory)) { $BuildOutputDirectory = Join-Path -Path $BuildRoot -ChildPath "output" }
if ([string]::IsNullOrEmpty($BuildOutput)) { $BuildOutput = Join-Path -Path $BuildOutputDirectory -ChildPath $Name }
if ([string]::IsNullOrEmpty($SourcePath)) { $SourcePath = Join-Path -Path $BuildRoot -ChildPath "src" }
if ([string]::IsNullOrEmpty($DocumentationPath)) { $DocumentationPath = Join-Path $BuildRoot -ChildPath "docs" }
if ([string]::IsNullOrEmpty($TestsPath)) { $TestsPath = Join-Path -Path $BuildRoot -ChildPath "tests" }
if ([string]::IsNullOrEmpty($TestResultsFile)) { $TestResultsFile = Join-Path -Path $BuildOutputDirectory -ChildPath "TestResults.xml" }
if ([string]::IsNullOrEmpty($CoverageResultsFile)) { $CoverageResultsFile = Join-Path -Path $BuildOutputDirectory -ChildPath "CoverageResults.xml" }
if ([string]::IsNullOrEmpty($LicensePath)) { $LicensePath = Join-Path -Path $BuildRoot -ChildPath "LICENSE" }
if ([string]::IsNullOrEmpty($SourceFilePath)) { $SourceFilePath = Join-Path -Path $SourcePath -ChildPath "$Name.psm1" }
if ([string]::IsNullOrEmpty($ManifestDestination)) { $ManifestDestination = Join-Path -Path $BuildOutput -ChildPath "$Name.psd1" }
if ([string]::IsNullOrEmpty($MergedFilePath)) { $MergedFilePath = Join-Path -Path $BuildOutput -ChildPath "$Name.psm1" }
if ([string]::IsNullOrEmpty($AnalysisSettingsFile)) { $AnalysisSettingsFile = Join-Path -Path $BuildRoot -ChildPath "PSScriptAnalyzerSettings.psd1" }
if ([string]::IsNullOrEmpty($PublishToArchiveName)) { $PublishToArchiveName = "$Name-$Version$VersionSuffix.zip" }
if ([string]::IsNullOrEmpty($PublishToArchiveDestination)) { $PublishToArchiveDestination = Join-Path -Path $BuildOutputDirectory -ChildPath $PublishToArchiveName }

Task "Clean" {
    Requires "BuildOutputDirectory"

    if (Test-Path -Path $BuildOutputDirectory)
    {
        Remove-Item -Path $BuildOutputDirectory -Recurse -Force
    }
}

Task "Compile" @{
    Inputs = { Get-ChildItem $SourcePath -Recurse -Include "*.*" -Exclude "TempPSBuilder.psm1" }
    Outputs = { $MergedFilePath }
    Jobs = {
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

        if ([string]::IsNullOrWhiteSpace($Version))
        {
            if (-not [string]::IsNullOrWhiteSpace($ENV:APPVEYOR_BUILD_VERSION))
            {
                $Version = $ENV:APPVEYOR_BUILD_VERSION
            }
            else
            {
                $Version = "1.0.0"
            }
        }

        #Create module manifest
        $manifestArgs = @{
            Name = $Name
            Path = $ManifestDestination
            ModuleFilePath = $MergedFilePath
            Author = $Author
            Description = $Description
            Guid = $Guid
            Version = $Version
        }

        if (-not [string]::IsNullOrEmpty($VersionSuffix))
        {
            $manifestArgs.Prerelease = $VersionSuffix
        }

        if (-not [string]::IsNullOrEmpty($LicenseUri))
        {
            $manifestArgs.LicenseUri = $LicenseUri
        }

        if (-not [string]::IsNullOrEmpty($ProjectUri))
        {
            $manifestArgs.ProjectUri = $ProjectUri
        }

        if (-not [string]::IsNullOrEmpty($IconUri))
        {
            $manifestArgs.IconUri = $IconUri
        }

        if ($null -ne $Tags -and $Tags.Count -gt 0)
        {
            $manifestArgs.Tags = $Tags
        }

        Invoke-CreateModuleManifest @manifestArgs

        #Create module documentation
        $modulePath = $MyInvocation.MyCommand.ScriptBlock.Module.Path
        Start-Job -ScriptBlock {
            Import-Module -Name $using:modulePath | Out-Null
            Import-Module -Name $using:ManifestDestination | Out-Null

            Invoke-CreateMarkdown -Path $using:DocumentationPath -Manifest $using:ManifestDestination
            Invoke-CreateHelp -Source $using:DocumentationPath -Destination $using:BuildOutput
        } | Receive-Job -Wait -AutoRemoveJob

        #Sign module files
        if ($Sign)
        {
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
}

Task "Analyze" "Compile", {
    Invoke-CodeAnalysis -Path $BuildOutput -SettingsFile $AnalysisSettingsFile -FailureLevel $AnalysisFailureLevel
}

Task "Test" "Compile", {
    Invoke-PesterTest -Path $TestsPath -Tags $TestTags -Module $ManifestDestination -OutputPath $TestResultsFile -MinCoverage $CodeCoverageMin -CoverageOutputPath $CoverageResultsFile

    if (-not [string]::IsNullOrEmpty($TestResultsFile))
    {
        if ($UploadTestResultsToAppveyor) {
            [void][System.Net.WebClient]::new().UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", $TestResultsFile)
        }
    }
}

Task "Build" "Compile", "Analyze", "Test"
Task "Publish" "Build", {
    if ($PublishToArchive -or $PublishToAppveyor)
    {
        $PublishToArchiveDestination = [scriptblock]::Create("`"$PublishToArchiveDestination`"").Invoke()
        Compress-Archive -Path $BuildOutput -DestinationPath $PublishToArchiveDestination -Force

        if ($PublishToAppveyor)
        {
            Push-AppveyorArtifact $PublishToArchiveDestination
        }
    }

    if ($PublishToRepository)
    {
        Invoke-PublishToRepository -NugetApiKey $env:NugetApiKey -Repository $PublishToRepositoryName -Path $BuildOutput
    }
}

Task "GenerateCert" {
    Invoke-GenerateSelfSignedCert
}
