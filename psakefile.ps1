Properties {
    $Name = 'PSBuilder'
    $PublishRepository = "Test"
    $BuildRoot = $PSScriptRoot
    $BuildOutput = "$PSScriptRoot/output"
    $SourcePath = "$PSScriptRoot/src"
    $SourceFilePath = "$SourcePath/$Name.psm1"
    $ManifestDestination = "$PSScriptRoot/output/$Name.psd1"
    $MergedFilePath = "$PSScriptRoot/output/$Name.psm1"
    $IsScript = $false
    $CodeCoverageMin = 60
    $AnalysisFailureLevel = "Error"
    $AnalysisSettingsFile = ""
    $TestTags = @()
    $DocumentationPath = "$PSScriptRoot/docs"
}

Include "$PSScriptRoot/src/files/build.tasks.ps1"