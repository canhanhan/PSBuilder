param (
    [Parameter(Mandatory=$true)]
    [string]$BuildRoot,

    [string]$Name = [IO.Path]::GetFileName([IO.Path]::GetDirectoryName($BuildRoot + "/")),

    [string]$ProjectBuildFile = (Join-Path -Path $BuildRoot -ChildPath "build.ps1"),

    $BuildOutputDirectory = (Join-Path -Path $BuildRoot -ChildPath "output"),

    $BuildOutput = (Join-Path -Path $BuildOutputDirectory -ChildPath $Name),

    $SourcePath = (Join-Path -Path $BuildRoot -ChildPath "src"),

    $DocumentationPath = (Join-Path $BuildRoot -ChildPath "docs"),

    $FilesPath = (Join-Path -Path $SourcePath -ChildPath "files"),

    $TestsPath = (Join-Path -Path $BuildRoot -ChildPath "tests"),

    $LicensePath = (Join-Path -Path $BuildRoot -ChildPath "LICENSE"),

    $SourceFilePath = (Join-Path -Path $SourcePath -ChildPath "$Name.psm1"),

    $ManifestDestination = (Join-Path -Path $BuildOutput -ChildPath "$Name.psd1"),

    $MergedFilePath = (Join-Path -Path $BuildOutput -ChildPath "$Name.psm1"),

    $CodeCoverageMin = 0,

    $AnalysisFailureLevel = "Error",

    $AnalysisSettingsFile = (Join-Path -Path $BuildRoot -ChildPath "PSScriptAnalyzerSettings.psd1"),

    $TestTags = @("*"),

    $ExtensionsToSign = ("*.ps1", "*.psd1", "*.psm1"),

    $Sign = $false,

    $SignFiles = $true,

    $PublishToRepository = $false,

    $PublishToArchive = $true,

    $PublishToArchiveName = '$Name-$Version.zip',

    $PublishToArchiveDestination = (Join-Path -Path $BuildOutputDirectory -ChildPath $PublishToArchiveName),

    $PublishToAppveyor = $false
)

. (Join-Path -Path $PSScriptRoot -ChildPath "compile.tasks.ps1")
. (Join-Path -Path $PSScriptRoot -ChildPath "sign.tasks.ps1")
. (Join-Path -Path $PSScriptRoot -ChildPath "docs.tasks.ps1")
. (Join-Path -Path $PSScriptRoot -ChildPath "publish.tasks.ps1")
. (Join-Path -Path $PSScriptRoot -ChildPath "test.tasks.ps1")

if (Test-Path -Path $ProjectBuildFile) { . $ProjectBuildFile }

Task "Build" "Compile", "Sign", "BuildDocs", "Test"