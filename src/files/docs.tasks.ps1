Task "GenerateDocs" "Compile", {
    Requires "Name", "ManifestDestination", "DocumentationPath"

    Import-Module -Name $ManifestDestination -Global -Force

    if (-not (Test-Path -Path $DocumentationPath))
    {
        New-Item -Path $DocumentationPath -ItemType Directory -Force | Out-Null
    }

    $moduleFile = Join-Path -Path $DocumentationPath -ChildPath "$Name.md"
    if (-not (Test-Path -Path $moduleFile))
    {
        New-MarkdownHelp -Module $Name -OutputFolder $DocumentationPath -WithModulePage | Out-Null
    }

    Update-MarkdownHelpModule -Path $DocumentationPath -RefreshModulePage | Out-Null
}

Task "BuildDocs" "GenerateDocs", {
    Requires "BuildOutput", "DocumentationPath"

    $destination = Join-Path -Path $BuildOutput -ChildPath "en-US"
    New-ExternalHelp -Path $DocumentationPath -OutputPath $destination | Out-Null
}