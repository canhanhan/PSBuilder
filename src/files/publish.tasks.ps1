task "PublishToRepository" `
     -depends "Compile" `
     -requiredVariables "BuildOutput" `
     -description "Publishes module to a Powershell Repository" `
{
    $publishParams = @{ "Path" = $BuildOutput }

    if (Test-Path "Variable:PublishRepository")
    {
        $publishParams["Repository"] = $PublishRepository
    }

    $nugetApiKey = $Env:NugetCredential
    if ($null -ne $nugetApiKey)
    {
        $publishParams["NuGetApiKey"] = $nugetApiKey
    }

    Publish-Module @publishParams
}


task "Publish" `
    -depends "Clean", "Compile", "Test", "PublishToRepository" `
    -description "Published module"