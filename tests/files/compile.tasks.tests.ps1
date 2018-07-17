. ./../testhelper.ps1

Describe_WithSampleModule "CreateOutputDir" {
    It "created output directory" {
        Invoke-BuildHelper CreateOutputDir
        $psake.build_success | Should -BeTrue

        Test-Path -Path $OutputPath | Should -BeTrue
    }
}

Describe_WithSampleModule "CopyFiles" {
    It "copies files" {
        Invoke-BuildHelper CopyFiles
        $psake.build_success | Should -BeTrue

        Test-Path -Path "$OutputPath/files/sample_file.txt" | Should -BeTrue
        Test-Path -Path "$OutputPath/files/sample_file.ps1" | Should -BeTrue
        Test-Path -Path "$OutputPath/files/sample_subfolder/sample_file.txt" | Should -BeTrue
    }
}

Describe_WithSampleModule "Compile" {
    Context "PSM does not exist" {
        It "merges files" {
            Invoke-BuildHelper Compile
            $psake.build_success | Should -BeTrue

            Test-Path -Path "$OutputPath/SampleModule.psm1" | Should -BeTrue
            Test-Path -Path "$OutputPath/Public" | Should -BeFalse
            Test-Path -Path "$OutputPath/Private" | Should -BeFalse
            Test-Path -Path "$OutputPath/Classes" | Should -BeFalse
        }

        It "exports public functions" {
            Invoke-BuildHelper Compile
            $psake.build_success | Should -BeTrue

            Import-Module -Name "$OutputPath/SampleModule.psm1"
            Get-Something | Should -Be "Something"
        }

        It "does not export private functions" {
            Invoke-BuildHelper Compile
            $psake.build_success | Should -BeTrue

            Import-Module -Name "$OutputPath/SampleModule.psm1"
            { Get-SomethingElse } | Should -Throw
        }
    }
}