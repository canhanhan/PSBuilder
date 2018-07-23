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
        }

        Context "PSake failed" {
            Mock -CommandName "Invoke-psake" -MockWith { $Global:psake = @{ build_success = $false } }

            It "throws on error" {
                { Invoke-Builder SampleTask } | Should -Throw
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