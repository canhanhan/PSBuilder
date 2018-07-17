. ./../testhelper.ps1

Describe_WithSampleModule "Test" {
    BeforeEach {
        if (Test-Path "$ModulePath/tests/fail.txt") { Remove-Item "$ModulePath/Tests/fail.txt" }
    }

    It "executes tests" {
        Invoke-Builder Test
        $psake.build_success | Should -BeTrue
    }

    It "fails when tests fail" {
        New-Item -Path "$ModulePath/tests/fail.txt"

        { Invoke-Builder Test } | Should -Throw
        $psake.build_success | Should -BeFalse
    }
}