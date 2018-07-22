task PublishToRepository -depends Stage {
    $publishParams = @{ "Path" = $MergedFilePath }

    if (Test-Path "Variable:PublishRepository")
    {
        $publishParams["Repository"] = $PublishRepository
    }

    $nugetApiKey = Get-NugetApiKey
    if ($null -ne $nugetApiKey)
    {
        $publishParams["NuGetApiKey"] = $nugetApiKey
    }

    Publish-Module @publishParams
}


task Publish -depends Clean, Stage, Test, PublishToRepository