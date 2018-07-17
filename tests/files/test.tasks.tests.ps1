. ./../testhelper.ps1

Describe_WithSampleModule "Test" {
    BeforeEach {
        if (Test-Path "$ModulePath/tests/fail.txt") { Remove-Item "$ModulePath/Tests/fail.txt" }
    }

    It "executes tests" {
        Invoke-BuildHelper Test
        $psake.build_success | Should -BeTrue
    }

    It "fails when tests fail" {
        New-Item -Path "$ModulePath/tests/fail.txt"

        { Invoke-BuildHelper Test } | Should -Throw
        $psake.build_success | Should -BeFalse
    }
}