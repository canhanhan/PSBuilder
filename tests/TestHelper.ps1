Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Clone-SampleModule {
    $ModuleSource = "$PSScriptRoot/../examples/SampleModule"
    $ModulePath = Join-Path -Path $testDrive -ChildPath "SampleModule"

    if (Test-Path $ModulePath) { Remove-Item -Path $ModulePath -Recurse -Force }
    Copy-Item -Path $ModuleSource -Destination $testDrive -Recurse

    Push-Location -Path $ModulePath -StackName "TestPath"
    $OutputPath = Join-Path -Path $ModulePath -ChildPath "Output"

    return $ModulePath, $OutputPath
}

function Clean-SampleModule {
    Pop-Location -StackName "TestPath" -ErrorAction SilentlyContinue
}

function Test-SampleModulePath {
    Get-Location -StackName "TestPath" -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
}

function Describe_WithSampleModule
{
    param ([string]$Name, [scriptblock]$ScriptBlock)

    Describe $Name {
        BeforeAll { Test-SampleModulePath }
        BeforeEach { $ModulePath, $OutputPath = Clone-SampleModule }
        AfterEach { Clean-SampleModule }
        AfterAll { Test-SampleModulePath }

        & $ScriptBlock
    }
}