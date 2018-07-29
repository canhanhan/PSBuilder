Task "PublishToRepository" -If { $PublishToRepository } "Compile", {
    Requires "BuildOutput"

    $publishParams = @{ "Path" = $BuildOutput }

    if (Test-Path "Variable:PublishToRepositoryName")
    {
        $publishParams["Repository"] = $PublishToRepositoryName
    }

    $nugetApiKey = $Env:NugetCredential
    if ($null -ne $nugetApiKey)
    {
        $publishParams["NuGetApiKey"] = $nugetApiKey
    }

    Publish-Module @publishParams
}

Task "PublishToArchive" -If { $PublishToArchive -or $PublishToAppveyor } "Compile", {
    $PublishToArchiveDestination = [scriptblock]::Create("`"$PublishToArchiveDestination`"").Invoke()
    Compress-Archive -Path $BuildOutput -DestinationPath $PublishToArchiveDestination -Force
}

Task "PublishToAppveyor" -If { $PublishToAppveyor  } "PublishToArchive", {
    Push-AppveyorArtifact $PublishToArchiveDestination
}

Task "Publish" "Build", "PublishToArchive", "PublishToAppveyor", "PublishToRepository"