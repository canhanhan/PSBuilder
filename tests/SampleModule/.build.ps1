param (
    $Name = 'SampleModule',
    $PublishRepository = "Test",
    $BuildOutput = 'output',
    $SourcePath = 'src',
    $IsScript = $false
)

. (Join-Path -Path $PSScriptRoot -ChildPath "PSBuildHelpers.ps1")