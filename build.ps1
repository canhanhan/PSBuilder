param ($Action="Build")

$isDotSourced = $MyInvocation.InvocationName -eq '.' -or $MyInvocation.Line -eq ''

if ($isDotSourced)
{
    $Name = 'PSBuilder'
    $Guid = '4e489c66-8a1a-11e8-9a94-a6cf71072f73'
    $Author = 'Can Hanhan'
    $Description = 'PSBuilder provides re-usable, shared build tasks for building Powershell modules and scripts.'
    $PublishToRepositoryName = "PSGallery"
}
else
{
    . "$PSScriptRoot/src/public/build/Invoke-CompileModule.ps1"
    Invoke-CompileModule -Name "PSBuilder" -Source "$PSScriptRoot/src" -Destination "$PSScriptRoot/src/TempPSBuilder.psm1"
    Import-Module -Prefix "Temp" -Name "$PSScriptRoot/src/TempPSBuilder.psm1" -Force

    Invoke-TempBuilder $Action -ExitOnError
}