. ./../testhelper.ps1

Describe_WithSampleModule "Clean" {
    It "removes output directory" {
        New-Item -Path $OutputPath -ItemType Directory -Force

        Invoke-Builder Clean

        Test-Path -Path $OutputPath | Should -BeFalse
    }
}