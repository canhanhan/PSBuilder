Describe "Invoke-Builder" {
    InModuleScope -ModuleName "PSBuilder" {
        Context "PSake successful" {
            Mock -CommandName "Invoke-PSake" -MockWith { $Global:psake = @{ build_success = $true } }

            It "throws if configuration file is specified but missing" {
                { Invoke-Builder -ConfigurationFile "$TestDrive/NotExistingPath" SampleTask } | Should -Throw
            }

            It "does not throw when configuration file is not specified" {
                Mock -CommandName "Test-Path" -MockWith { $False }
                Invoke-Builder SampleTask
            }

            It "handles relative config file paths" {
                $CurrentPath = Join-Path -Path $PSScriptroot -ChildPath "sample.json"

                Mock -CommandName "Get-Content" -MockWith { "{}" }
                Mock -CommandName "Test-Path" -MockWith { $True } -Verifiable -ParameterFilter { $Path -eq $CurrentPath }

                Invoke-Builder -ConfigurationFile "sample.json"

                Assert-VerifiableMock
            }

            It "reads the properties from build file" {
                $Global:Configuration = $null
                Mock -CommandName "Get-Content" -MockWith { "{ 'sample_key': 'sample_value' }" }
                Mock -CommandName "Test-Path" -MockWith { $True }
                Mock -CommandName "Invoke-psake" -MockWith { $Global:Configuration = $Parameters }

                Invoke-Builder SampleTask

                $Configuration.Keys | Should -Contain "sample_key"
                $Configuration["sample_key"] | Should -Be "sample_value"
            }

            It "sets default values" {
                Mock -CommandName "Test-Path" -MockWith { $False }
                Mock -CommandName "Invoke-psake" -MockWith { $Global:Configuration = $Parameters }

                Invoke-Builder SampleTask

                "IsScript" | Should -BeIn $Configuration.Keys
                "BuildRoot" | Should -BeIn $Configuration.Keys
                "BuildOutput" | Should -BeIn $Configuration.Keys
                "SourcePath" | Should -BeIn $Configuration.Keys
                "Name" | Should -BeIn $Configuration.Keys
                "CodeCoverageMin" | Should -BeIn $Configuration.Keys
                "ManifestDestination" | Should -BeIn $Configuration.Keys
                "SourceFilePath" | Should -BeIn $Configuration.Keys
                "MergedFilePath" | Should -BeIn $Configuration.Keys
            }

            It "sets default values for modules" {
                Mock -CommandName "Test-Path" -MockWith { $False }
                Mock -CommandName "Invoke-psake" -MockWith { $Global:Configuration = $Parameters }

                Invoke-Builder SampleTask -Configuration @{ IsScript = $false }

                "ManifestDestination" | Should -BeIn $Configuration.Keys
                "SourceFilePath" | Should -BeIn $Configuration.Keys
                "MergedFilePath" | Should -BeIn $Configuration.Keys
            }

            It "sets default values for scripts" {
                Mock -CommandName "Test-Path" -MockWith { $False }
                Mock -CommandName "Invoke-psake" -MockWith { $Global:Configuration = $Parameters }

                Invoke-Builder SampleTask -Configuration @{ IsScript = $true }

                "SourceFilePath" | Should -BeIn $Configuration.Keys
                "MergedFilePath" | Should -BeIn $Configuration.Keys
            }
        }

        Context "PSake failed" {
            Mock -CommandName "Invoke-psake" -MockWith { $Global:psake = @{ build_success = $false } }

            It "does not throw on error if flag not set" {
                { Invoke-Builder SampleTask } | Should -Not -Throw
            }

            It "throws on error if flag set" {
                { Invoke-Builder SampleTask -ThrowOnError } | Should -Throw
            }

            Context "Exit flag set" {
                Mock -CommandName "Exit-Powershell" -MockWith { $Global:ExitCode = $ExitCode } -Verifiable

                It "exits on error" {
                    Invoke-Builder SampleTask -ExitWithCode

                    Assert-VerifiableMock
                }
            }
        }
    }
}