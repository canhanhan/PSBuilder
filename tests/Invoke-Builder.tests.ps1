Describe "Invoke-Builder" {
    InModuleScope -ModuleName "PSBuilder" {
        Context "PSake failed" {
            Mock -CommandName "Invoke-psake" -MockWith { $Global:psake = @{ build_success = $false } }

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