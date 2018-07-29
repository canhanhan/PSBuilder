Task "PublishToRepository" "Compile", {
    Requires "BuildOutput"

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

Task "Publish" "Build", "PublishToRepository"