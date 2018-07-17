. ./../testhelper.ps1

Describe_WithSampleModule "Clean" {
    It "removes output directory" {
        New-Item -Path $OutputPath -ItemType Directory

        Invoke-Builder Clean

        $psake.build_success | Should -BeTrue
        Test-Path -Path $OutputPath | Should -BeFalse
    }
}