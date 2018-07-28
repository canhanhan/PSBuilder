param (
    [Parameter(Mandatory=$true)]
    [string]$BuildRoot
)

. (Join-Path -Path $PSScriptRoot -ChildPath "compile.tasks.ps1")
. (Join-Path -Path $PSScriptRoot -ChildPath "sign.tasks.ps1")
. (Join-Path -Path $PSScriptRoot -ChildPath "docs.tasks.ps1")
. (Join-Path -Path $PSScriptRoot -ChildPath "publish.tasks.ps1")
. (Join-Path -Path $PSScriptRoot -ChildPath "test.tasks.ps1")

. (Join-Path -Path $PSScriptRoot -ChildPath "defaults.ps1")
if (Test-Path -Path $ProjectBuildFile) { . $ProjectBuildFile }

Task "." "Compile", "Sign", "BuildDocs", "Test"