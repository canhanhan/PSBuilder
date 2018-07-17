

Describe "Invoke-Builder" -Tag Run  {
    InModuleScope -ModuleName "PSBuilder" {
        Mock -CommandName "Invoke-PSake" -MockWith { $Global:psake = @{ build_success = $true } }

        It "throws if configuration file is specified but missing" {
            { Invoke-Builder -ConfigurationFile "$TestDrive/NotExistingPath" SampleTask } | Should -Throw
        }

        It "does not throw when configuration file is not specified" {
            Mock -CommandName "Test-Path" -MockWith { $False }
            Invoke-Builder SampleTask
        }
    }
}