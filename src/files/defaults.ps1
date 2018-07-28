$Name = [IO.Path]::GetFileName([IO.Path]::GetDirectoryName($BuildRoot + "/"))
$ProjectBuildFile = Join-Path -Path $BuildRoot -ChildPath "build.ps1"
$BuildOutput = Join-Path -Path $BuildRoot -ChildPath "output/$Name"

$SourcePath = Join-Path -Path $BuildRoot -ChildPath "src"
$DocumentationPath = Join-Path $BuildRoot -ChildPath "docs"
$FilesPath = Join-Path -Path $SourcePath -ChildPath "files"
$LicensePath = Join-Path -Path $BuildRoot -ChildPath "LICENSE"
$SourceFilePath = Join-Path -Path $SourcePath -ChildPath "$Name.psm1"
$ManifestDestination = Join-Path -Path $BuildOutput -ChildPath "$Name.psd1"
$MergedFilePath = Join-Path -Path $BuildOutput -ChildPath "$Name.psm1"

$CodeCoverageMin = 0
$AnalysisFailureLevel = "Error"
$AnalysisSettingsFile = Join-Path -Path $BuildRoot -ChildPath "PSScriptAnalyzerSettings.psd1"
$TestTags = @("*")

$ExtensionsToSign = "*.ps1", "*.psd1", "*.psm1"
$Sign = $false
$SignFiles = $true