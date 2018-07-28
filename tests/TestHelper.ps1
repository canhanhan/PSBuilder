Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Clone-SampleModule {
    $ModuleSource = "$PSScriptRoot/../examples/SampleModule"
    $ModuleDestination = Join-Path -Path $testDrive -ChildPath "SampleModule"

    if (Test-Path $ModuleDestination) { Remove-Item -Path $ModuleDestination -Recurse -Force }
    Copy-Item -Path $ModuleSource -Destination $testDrive -Recurse

    Push-Location -Path $ModuleDestination -StackName "TestPath"
    $OutputPath = Join-Path -Path $ModuleDestination -ChildPath "Output/SampleModule"

    return $ModuleDestination, $OutputPath
}

function Clean-SampleModule {
    Pop-Location -StackName "TestPath" -ErrorAction SilentlyContinue
}

function Test-SampleModulePath {
    Get-Location -StackName "TestPath" -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
}

function Describe_WithSampleModule
{
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Name,

        [string[]]$Tag=@(),

        [Parameter(Mandatory=$true, Position=1)]
        [scriptblock]$ScriptBlock
    )

    Describe $Name -Tag $Tag {
        BeforeAll { Test-SampleModulePath }
        BeforeEach {
            $ModulePath, $OutputPath = Clone-SampleModule
            Import-Module -Name InvokeBuild -Force
        }
        AfterEach { Clean-SampleModule }
        AfterAll { Test-SampleModulePath }

        & $ScriptBlock
    }
}