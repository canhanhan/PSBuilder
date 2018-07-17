param (
    $Name = 'PSBuildHelpers',
    $PublishRepository = "Test",
    $BuildOutput = 'output',
    $SourcePath = 'src',
    $IsScript = $true
)

. "$PSScriptRoot\src\PSBuildHelpers.ps1"

task BetterTest {
    Start-Job -ArgumentList (, $BuildOutput) -ScriptBlock { param($path) Set-Location $path; Invoke-Build Test } | Receive-Job -Wait -AutoRemoveJob
}