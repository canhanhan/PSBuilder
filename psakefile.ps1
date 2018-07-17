Properties {
    $Name = 'PSBuildHelper'
    $PublishRepository = "Test"
    $BuildRoot = $PSScriptRoot
    $BuildOutput = "$PSScriptRoot/output"
    $SourcePath = "$PSScriptRoot/src"
    $SourceFilePath = "$SourcePath/$Name.psm1"
    $MergedFilePath = "$PSScriptRoot/output/$Name.psm1"
    $IsScript = $false
    $CodeCoverageMin = 100
}

Include "$PSScriptRoot/src/files/build.tasks.ps1"