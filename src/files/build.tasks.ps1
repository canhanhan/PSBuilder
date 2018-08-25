param (
    [Parameter(Mandatory=$true)]
    [string]$BuildRoot,

    [string]$Name = [IO.Path]::GetFileName([IO.Path]::GetDirectoryName($BuildRoot + "/")),

    [string]$Version = $ENV:APPVEYOR_BUILD_VERSION,

    [string]$ProjectBuildFile = (Join-Path -Path $BuildRoot -ChildPath "build.ps1"),

    [string]$BuildOutputDirectory = (Join-Path -Path $BuildRoot -ChildPath "output"),

    [string]$BuildOutput = (Join-Path -Path $BuildOutputDirectory -ChildPath $Name),

    [string]$SourcePath = (Join-Path -Path $BuildRoot -ChildPath "src"),

    [string]$DocumentationPath = (Join-Path $BuildRoot -ChildPath "docs"),

    [string[]]$FilesPath = ("files", "lib", "bin"),

    [string]$TestsPath = (Join-Path -Path $BuildRoot -ChildPath "tests"),

    [string]$LicensePath = (Join-Path -Path $BuildRoot -ChildPath "LICENSE"),

    [string]$SourceFilePath = (Join-Path -Path $SourcePath -ChildPath "$Name.psm1"),

    [string]$ManifestDestination = (Join-Path -Path $BuildOutput -ChildPath "$Name.psd1"),

    [string]$MergedFilePath = (Join-Path -Path $BuildOutput -ChildPath "$Name.psm1"),

    [int]$CodeCoverageMin = 0,

    [string]$AnalysisFailureLevel = "Error",

    [string]$AnalysisSettingsFile = (Join-Path -Path $BuildRoot -ChildPath "PSScriptAnalyzerSettings.psd1"),

    [string[]]$TestTags = @("*"),

    [string]$TestResultsFile = (Join-Path -Path $BuildOutputDirectory -ChildPath "TestResults.xml"),

    [bool]$UploadTestResultsToAppveyor = (Test-Path -Path "Env:APPVEYOR_JOB_ID"),

    [string[]]$ExtensionsToSign = ("*.ps1", "*.psd1", "*.psm1"),

    [bool]$Sign = $false,

    [bool]$SignFiles = $true,

    [bool]$PublishToRepository = $false,

    [bool]$PublishToArchive = $true,

    [string]$PublishToArchiveName = '$Name-$Version.zip',

    [string]$PublishToArchiveDestination = (Join-Path -Path $BuildOutputDirectory -ChildPath $PublishToArchiveName),

    [bool]$PublishToAppveyor = (Test-Path -Path "Env:APPVEYOR_JOB_ID")
)

Task "Clean" {
    Requires "BuildOutputDirectory"

    if (Test-Path -Path $BuildOutputDirectory)
    {
        Remove-Item -Path $BuildOutputDirectory -Recurse -Force
    }
}

Task "Compile" "Clean", {
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
    Invoke-CreateModuleManifest -Name $Name -Path $ManifestDestination -ModuleFilePath $MergedFilePath -Author $Author -Description $Description -Guid $Guid

    if ($Sign)
    {
        Invoke-Sign -Path $Path -CertificateThumbprint $CertificateThumbprint -CertificateSubject $CertificateSubject
    }

    Invoke-CreateMarkdown -Path $DocumentationPath -Manifest $ManifestDestination
    Invoke-CreateHelp -Source $DocumentationPath -Destination $BuildOutput
}

Task "Analyze" "Compile", {
    Invoke-CodeAnalysis -Path $BuildOutput -SettingsFile $AnalysisSettingsFile -FailureLevel $AnalysisFailureLevel
}

Task "Test" "Compile", {
    Invoke-PesterTest -Path $TestsPath -Tags $TestTags -Module $ManifestDestination -OutputPath $TestResultsFile -MinCoverage $CodeCoverageMin

    if (-not [string]::IsNullOrEmpty($TestResultsFile))
    {
        if ($UploadTestResultsToAppveyor) {
            Invoke-WebRequest -UseBasicParsing -Uri "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)" -InFile $TestResultsFile
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

if (Test-Path -Path $ProjectBuildFile) { . $ProjectBuildFile }