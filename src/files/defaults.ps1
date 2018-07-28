$Name = [IO.Path]::GetFileName([IO.Path]::GetDirectoryName($BuildRoot + "/"))

[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignment", "")]
$ProjectBuildFile = Join-Path -Path $BuildRoot -ChildPath "build.ps1"

$BuildOutput = Join-Path -Path $BuildRoot -ChildPath "output/$Name"

$SourcePath = Join-Path -Path $BuildRoot -ChildPath "src"

[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignment", "")]
$DocumentationPath = Join-Path $BuildRoot -ChildPath "docs"

[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignment", "")]
$FilesPath = Join-Path -Path $SourcePath -ChildPath "files"

[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignment", "")]
$LicensePath = Join-Path -Path $BuildRoot -ChildPath "LICENSE"

[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignment", "")]
$SourceFilePath = Join-Path -Path $SourcePath -ChildPath "$Name.psm1"

[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignment", "")]
$ManifestDestination = Join-Path -Path $BuildOutput -ChildPath "$Name.psd1"

[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignment", "")]
$MergedFilePath = Join-Path -Path $BuildOutput -ChildPath "$Name.psm1"

[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignment", "")]
$CodeCoverageMin = 0

[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignment", "")]
$AnalysisFailureLevel = "Error"

[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignment", "")]
$AnalysisSettingsFile = Join-Path -Path $BuildRoot -ChildPath "PSScriptAnalyzerSettings.psd1"

[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignment", "")]
$TestTags = @("*")

[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignment", "")]
$ExtensionsToSign = "*.ps1", "*.psd1", "*.psm1"

[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignment", "")]
$Sign = $false

[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignment", "")]
$SignFiles = $true