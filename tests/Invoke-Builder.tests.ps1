. "$PSScriptRoot\testhelper.ps1"

Describe "Invoke-Builder" {
    InModuleScope -ModuleName "PSBuilder" {
        Context "Build failed" {
            Mock -CommandName "Invoke-Build" -MockWith { $Global:Result = @{ Errors = @("SAMPLE ERROR") } }

            It "throws on error" {
                { Invoke-Builder SampleTask } | Should -Throw
            }

            Context "Exit flag set" {
                Mock -CommandName "Exit-Powershell" -MockWith { $Global:ExitCode = $ExitCode } -Verifiable

                It "exits on error" {
                    Invoke-Builder SampleTask -ExitOnError

                    Assert-VerifiableMock
                }
            }
        }
    }
}

Describe_WithSampleModule "Clean" {
    It "cleans output directory" {
        New-Item -Path $OutputPath -ItemType Directory -Force

        Invoke-Builder Clean

        Test-Path -Path $OutputPath | Should -BeFalse
    }
}

Describe_WithSampleModule "Build" {
    Context "Additional files exist" {
        It "copies the non-Powershell files" {
            Invoke-Builder Build

            Test-Path -Path "$OutputPath/files/sample_file.txt" | Should -BeTrue
        }

        It "copies Powershell files" {
            Invoke-Builder Build

            Test-Path -Path "$OutputPath/files/sample_file.ps1" | Should -BeTrue
        }

        It "copies files from subfolders" {
            Invoke-Builder Build

            Test-Path -Path "$OutputPath/files/sample_subfolder/sample_file.txt" | Should -BeTrue
        }
    }

    Context "License file exists" {
        It "copies the license file" {
            Invoke-Builder Build

            Test-Path -Path "$OutputPath/LICENSE" | Should -BeTrue
        }
    }

    Context "PSM1 does not exist" {
        It "merges files" {
            Invoke-Builder Build

            Test-Path -Path "$OutputPath/SampleModule.psm1" | Should -BeTrue
        }

        It "does not copy source folders" {
            Invoke-Builder Build

            Test-Path -Path "$OutputPath/Public" | Should -BeFalse
            Test-Path -Path "$OutputPath/Private" | Should -BeFalse
            Test-Path -Path "$OutputPath/Classes" | Should -BeFalse
        }

        It "exports public functions" {
            Invoke-Builder Build

            $module = Get-Module -Name "$OutputPath/SampleModule.psm1" -ListAvailable
            $module.ExportedFunctions.ContainsKey("Get-Something") | Should -BeTrue
        }

        It "does not export private functions" {
            Invoke-Builder Build

            $module = Get-Module -Name "$OutputPath/SampleModule.psm1" -ListAvailable
            $module.ExportedFunctions.ContainsKey("Get-SomethingElse") | Should -BeFalse
        }
    }

    Context "PSM1 exists" {
        BeforeEach {
            Copy-Item -Path "$PSScriptRoot/files/SampleModule.psm1" -Destination "$ModulePath/src/SampleModule.psm1"
        }

        It "copies the psm1" {
            Invoke-Builder Build

            Test-Path -Path "$OutputPath/SampleModule.psm1" | Should -BeTrue
        }

        It "copies source folders" {
            Invoke-Builder Build

            Test-Path -Path "$OutputPath/Public" | Should -BeTrue
            Test-Path -Path "$OutputPath/Private" | Should -BeTrue
            Test-Path -Path "$OutputPath/Classes" | Should -BeTrue
        }
    }
}

Describe_WithSampleModule "Analyze" {
    Context "Settings file exist" {
        BeforeEach {
            New-Item -Path "$ModulePath/PSScriptAnalyzerSettings.psd1"
            Mock "Invoke-ScriptAnalyzer" -ModuleName "PSBuilder" -Verifiable -ParameterFilter { -not [string]::IsNullOrEmpty($Settings) }
        }

        It "should use SettingsFile argument while calling PSScriptAnalyzer" {
            Invoke-Builder Analyze

            Assert-MockCalled "Invoke-ScriptAnalyzer" -ModuleName "PSBuilder"
        }
    }

    Context "Settings file do not exist" {
        BeforeEach {
            Mock "Invoke-ScriptAnalyzer" -ModuleName "PSBuilder" -Verifiable -ParameterFilter { [string]::IsNullOrEmpty($Settings) }
        }

        It "should not use SettingsFile argument while calling PSScriptAnalyzer" {
            Invoke-Builder Analyze

            Assert-MockCalled "Invoke-ScriptAnalyzer" -ModuleName "PSBuilder"
        }
    }
}

Describe_WithSampleModule "Test" {
    BeforeEach {
        if (Test-Path -Path "Env:APPVEYOR_JOB_ID") { $appveyorJobId = $Env:APPVEYOR_JOB_ID; Remove-Item -Path "Env:APPVEYOR_JOB_ID" -Force }
    }

    AfterEach {
        if (Test-Path -Path "Variable:appveyorJobId") { $Env:APPVEYOR_JOB_ID = $appveyorJobId }
    }

    Context "Has tests folder but no files in" {
        BeforeEach {
            Mock "Invoke-Pester" -Verifiable -ModuleName "PSBuilder" {
                [pscustomobject]@{ "FailedCount" = 0; "CodeCoverage"= [pscustomobject]@{ "NumberOfCommandsAnalyzed"= 0; "NumberOfCommandsExecuted"=0; "MissedCommands" = @() } }
            }
        }

        It "finishes without division to zero errors" {
            Invoke-Builder Test
        }
    }

    Context "Has passing tests" {
        BeforeEach {
            Mock "Invoke-Pester" -Verifiable -ModuleName "PSBuilder" {
                [pscustomobject]@{ "FailedCount" = 0; "CodeCoverage"= [pscustomobject]@{ "NumberOfCommandsAnalyzed"= 2; "NumberOfCommandsExecuted"=1; "MissedCommands" = @() } }
            }
        }

        It "should finish" {
            Invoke-Builder Test
        }

        # Context "UploadAppveyor Set" {
        #     It "should attempt to upload to Appveyor" {
        #         Mock "Invoke-WebRequest" -Verifiable -ModuleName "PSBuilder"

        #         Invoke-Builder Test -Parameters @{"UploadTestResultsToAppveyor"=$true}

        #         Assert-MockCalled "Invoke-WebRequest" -ModuleName "PSBuilder"
        #     }
        # }

        It "fails when code coverage set above" {
            { Invoke-Builder Test -Parameters @{"CodeCoverageMin"=100} } | Should -Throw
        }

        It "succeeds when code coverage set below or equal" {
            Invoke-Builder Test -Parameters @{"CodeCoverageMin"=50}
        }
    }

    Context "Has failing tests" {
        BeforeEach {
            Mock "Invoke-Pester" -Verifiable -ModuleName "PSBuilder" {
                [pscustomobject]@{ "FailedCount" = 1; "CodeCoverage"= [pscustomobject]@{ "NumberOfCommandsAnalyzed"= 0; "NumberOfCommandsExecuted"=0; "MissedCommands" = @() } }
            }
        }

        It "should throw" {
            { Invoke-Builder Test } | Should -Throw
        }
    }

    Context "Does not have tests" {
        BeforeEach {
            Mock "Test-Path" { $false }
            Remove-Item -Path "$ModulePath/tests" -Recurse -Force
        }

        It "does not execute Pester" {
            Mock "Invoke-Pester" -Verifiable -ModuleName "PSBuilder"

            Invoke-Builder Test -Parameters @{"CodeCoverageMin"=0}

            Assert-MockCalled "Invoke-Pester" -Times 0 -ModuleName "PSBuilder"
        }

        It "it fails code coverage check" {
            Mock "Invoke-Pester" -Verifiable -ModuleName "PSBuilder"

            { Invoke-Builder Test -Parameters @{"CodeCoverageMin"=1} } | Should -Throw
        }
    }
}