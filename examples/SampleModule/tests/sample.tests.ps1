describe "SampleModule" {
    it "should fail when `$Env:Fail is `$true" {
        { Get-Item -Path "$PSScriptRoot/fail.txt" } | Should -Throw
    }
}