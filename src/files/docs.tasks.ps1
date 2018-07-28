Task "GenerateDocs" "Compile", {
    Requires "Name", "ManifestDestination", "DocumentationPath"

    Start-Job -ScriptBlock {
        Set-StrictMode -Version Latest
        $ErrorActionPreference = "Stop"

        Import-Module -Name $using:ManifestDestination -Global -Force

        if (-not (Test-Path -Path $using:DocumentationPath))
        {
            New-Item -Path $using:DocumentationPath -ItemType Directory -Force | Out-Null
        }

        $moduleFile = Join-Path -Path $using:DocumentationPath -ChildPath "$($using:Name).md"
        if (-not (Test-Path -Path $moduleFile))
        {
            New-MarkdownHelp -Module $using:Name -OutputFolder $using:DocumentationPath -WithModulePage | Out-Null
        }

        Update-MarkdownHelpModule -Path $using:DocumentationPath -RefreshModulePage | Out-Null
    } | Receive-Job -Wait -AutoRemoveJob
}

Task "BuildDocs" "GenerateDocs", {
    Requires "BuildOutput", "DocumentationPath"

    $destination = Join-Path -Path $BuildOutput -ChildPath "en-US"
    New-ExternalHelp -Path $DocumentationPath -OutputPath $destination | Out-Null
}