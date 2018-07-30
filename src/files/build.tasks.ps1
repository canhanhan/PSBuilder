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

    [string]$FilesPath = (Join-Path -Path $SourcePath -ChildPath "files"),

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

    [string]$UploadTestResultsToAppveyor = (Test-Path -Path "Env:APPVEYOR_JOB_ID"),

    [string]$ExtensionsToSign = ("*.ps1", "*.psd1", "*.psm1"),

    [bool]$Sign = $false,

    [bool]$SignFiles = $true,

    [bool]$PublishToRepository = $false,

    [bool]$PublishToArchive = $true,

    [string]$PublishToArchiveName = '$Name-$Version.zip',

    [string]$PublishToArchiveDestination = (Join-Path -Path $BuildOutputDirectory -ChildPath $PublishToArchiveName),

    [string]$PublishToAppveyor = (Test-Path -Path "Env:APPVEYOR_JOB_ID")
)

. (Join-Path -Path $PSScriptRoot -ChildPath "compile.tasks.ps1")
. (Join-Path -Path $PSScriptRoot -ChildPath "sign.tasks.ps1")
. (Join-Path -Path $PSScriptRoot -ChildPath "docs.tasks.ps1")
. (Join-Path -Path $PSScriptRoot -ChildPath "publish.tasks.ps1")
. (Join-Path -Path $PSScriptRoot -ChildPath "test.tasks.ps1")

if (Test-Path -Path $ProjectBuildFile) { . $ProjectBuildFile }

Task "Build" "Compile", "Sign", "BuildDocs", "Test"