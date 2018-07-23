task PublishToRepository -depends Stage -requiredVariables "BuildOutput" {
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


task Publish -depends Clean, Stage, Test, PublishToRepository