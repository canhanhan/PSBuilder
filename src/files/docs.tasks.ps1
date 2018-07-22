task GenerateDocs -depends Stage -requiredVariables "Name", "ManifestDestination", "DocumentationPath" {
    Start-Job -ArgumentList ($name, $ManifestDestination, $documentationPath) -ScriptBlock {
        param($name, $filePath, $docPath)

        Set-StrictMode -Version Latest
        $ErrorActionPreference = "Stop"

        $module = Import-Module -Name $filePath -Global -Force -PassThru

        if (-not (Test-Path -Path $docPath)) { New-Item -Path $docPath -ItemType Directory -Force | Out-Null }

        New-MarkdownHelp -Module $name -OutputFolder $docPath -WithModulePage -Force | Out-Null

        foreach ($function in $module.ExportedFunctions.Keys)
        {
            $doc = Join-Path -Path $docPath -ChildPath "$($function).md"
            Update-MarkdownHelp -Path $doc | Out-Null
        }
    } | Receive-Job -Wait -AutoRemoveJob
}

task "BuildDocs" -depends "GenerateDocs" -requiredVariables "BuildOutput", "DocumentationPath" {
    $destination = Join-Path -Path $BuildOutput -ChildPath "en-US"
    New-ExternalHelp -Path $DocumentationPath -OutputPath $destination | Out-Null
}