Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
Describe "PSBuildHelpers" {
    Context "Module" {
        BeforeEach {
            $ModuleSource = Join-Path -Path $PSScriptRoot -ChildPath "SampleModule"
            $ModulePath = Join-Path -Path $testDrive -ChildPath "SampleModule"

            if (Test-Path $ModulePath) { Remove-Item -Path $ModulePath -Recurse -Force }

            Copy-Item -Path $ModuleSource -Destination $testDrive -Recurse
            Copy-Item -Path "$PSScriptRoot/../output/PSBuildHelpers.ps1" -Destination $ModulePath

            Push-Location -Path $ModulePath -StackName "TestPath"

            $OutputPath = Join-Path -Path $ModulePath -ChildPath "Output"
        }

        AfterEach {
            Pop-Location -StackName "TestPath"
        }

        Describe "Clean" {
            It "removes output directory" {
                New-Item -Path $OutputPath -ItemType Directory | Out-Null

                Invoke-Build -Task Clean -Result result | Out-Null

                $result.Errors | Should -BeNullOrEmpty
                Test-Path -Path $OutputPath | Should -BeFalse
            }
        }

        Describe "CreateOutputDir" {
            It "created output directory" {
                Invoke-Build -Task CreateOutputDir -Result result | Out-Null

                $result.Errors | Should -BeNullOrEmpty
                Test-Path -Path $OutputPath | Should -BeTrue
            }
        }

        Describe "CopyFiles" {
            It "copies files" {
                Invoke-Build -Task CopyFiles -Result result | Out-Null

                $result.Errors | Should -BeNullOrEmpty
                Test-Path -Path "$OutputPath/files/sample_file.txt" | Should -BeTrue
                Test-Path -Path "$OutputPath/files/sample_file.ps1" | Should -BeTrue
                Test-Path -Path "$OutputPath/files/sample_subfolder/sample_file.txt" | Should -BeTrue
            }
        }

        Describe "Compile" {
            Context "PSM does not exist" {
                It "merges files" {
                    Invoke-Build -Task Compile -Result result | Out-Null
                    $result.Errors | Should -BeNullOrEmpty

                    Test-Path -Path "$OutputPath/SampleModule.psm1" | Should -BeTrue
                    Test-Path -Path "$OutputPath/Public" | Should -BeFalse
                    Test-Path -Path "$OutputPath/Private" | Should -BeFalse
                    Test-Path -Path "$OutputPath/Classes" | Should -BeFalse
                }

                It "exports public functions" {
                    Invoke-Build -Task Compile -Result result | Out-Null
                    $result.Errors | Should -BeNullOrEmpty

                    Import-Module -Name "$OutputPath/SampleModule.psm1"
                    Get-Something | Should -Be "Something"
                }

                It "does not export private functions" {
                    Invoke-Build -Task Compile -Result result | Out-Null
                    $result.Errors | Should -BeNullOrEmpty

                    Import-Module -Name "$OutputPath/SampleModule.psm1"
                    { Get-SomethingElse } | Should -Throw
                }
            }

            Context "PSM Exist but no marker" {
                BeforeEach {
                    Set-Content -Path "$ModulePath/src/SampleModule.psm1" -Value "Test" -NoNewline
                }

                It "does not do anything" {
                    Invoke-Build -Task Compile -Result result | Out-Null
                    $result.Errors | Should -BeNullOrEmpty

                    Get-Content -Path "$OutputPath/SampleModule.psm1" -Raw | Should -Be "Test"
                }
            }

            Context "PSM Exist with marker" {
                Context "With whitespace" {
                    BeforeEach {
                        Set-Content -Path "$ModulePath/src/SampleModule.psm1" -Value "#Test`r`n### MERGE HERE ###" -NoNewline
                    }

                    It "keeps existing line and merges" {
                        Invoke-Build -Task Compile -Result result | Out-Null
                        $result.Errors | Should -BeNullOrEmpty

                        $lines = Get-Content -Path "$OutputPath/SampleModule.psm1"
                        $lines[0] | Should -Be "#Test"
                        $lines[3] | Should -Be "function Get-SomethingElse"
                    }
                }

                Context "No whitespace" {
                    BeforeEach {
                        Set-Content -Path "$ModulePath/src/SampleModule.psm1" -Value "#Test`r`n`t`t### MERGE HERE ###" -NoNewline
                    }

                    It "keeps existing line and merges" {
                        Invoke-Build -Task Compile -Result result | Out-Null
                        $result.Errors | Should -BeNullOrEmpty

                        $lines = Get-Content -Path "$OutputPath/SampleModule.psm1"
                        $lines[0] | Should -Be "#Test"
                        $lines[3] | Should -Be "`t`tfunction Get-SomethingElse"
                        $lines[4] | Should -Be "`t`t{"
                    }
                }
            }
        }

        Describe "Test" {
            It "executes tests" {
                $Global:Fail = $false
                Invoke-Build -Task Test -Result result | Out-Null
                $result.Errors | Should -BeNullOrEmpty
            }

            It "fails when tests fail" {
                $Global:Fail = $true
                { Invoke-Build -Task Test } | Should -Throw
            }
        }
    }
}