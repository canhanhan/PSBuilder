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