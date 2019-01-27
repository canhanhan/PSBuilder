param ($Action="Build")

if ($MyInvocation.InvocationName -eq '.')
{
    $Name = 'PSBuilder'
    $Guid = '4e489c66-8a1a-11e8-9a94-a6cf71072f73'
    $Author = 'Can Hanhan'
    $Description = 'PSBuilder provides re-usable, shared build tasks for building Powershell modules and scripts.'
    $PublishToRepositoryName = "PSGallery"
    $PublishToRepository = ($Env:APPVEYOR_REPO_BRANCH -eq "master")
    $ProjectUri = "https://github.com/finarfin/PSBuilder"
    $LicenseUri = "https://github.com/finarfin/PSBuilder/blob/master/LICENSE"
    $HelpInfoUri = "https://github.com/finarfin/PSBuilder/blob/master/docs/PSBuilder.md"
    $Dependencies = @(
        @{ Name="InvokeBuild"; MinimumVersion="5.4.2" },
        @{ Name="Pester"; MinimumVersion="4.6.0" },
        @{ Name="platyPS"; MinimumVersion="0.12.0" }
    )
}
else
{
    . "$PSScriptRoot/src/private/build/Invoke-CompileModule.ps1"
    Invoke-CompileModule -Name "PSBuilder" -Source "$PSScriptRoot/src" -Destination "$PSScriptRoot/src/TempPSBuilder.psm1"
    Import-Module -Name "$PSScriptRoot/src/TempPSBuilder.psm1" -Force
    Invoke-Builder $Action -ExitOnError
}
