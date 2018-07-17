describe "SampleModule" {
    it "should fail when `$Fail is `$true" {
        $Fail | Should -BeFalse
    }
}