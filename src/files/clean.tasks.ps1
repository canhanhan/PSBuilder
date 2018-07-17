task "Clean" -requiredVariables "BuildOutput" {
    if (Test-Path $BuildOutput)
    {
        Remove-Item -Path $BuildOutput -Force -Recurse
    }
}