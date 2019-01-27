function Invoke-CreateMarkdown
{
    param (
        [Parameter(Mandatory=$true)]
        [string]$Manifest,

        [Parameter(Mandatory=$true)]
        [string]$Path
    )

    Start-Job -ScriptBlock {
        $module = Import-Module -Name $using:Manifest -Global -Force -PassThru
        if (-not (Test-Path -Path $using:Path))
        {
            New-Item -Path $using:Path -ItemType Directory -Force | Out-Null
        }

        $moduleFile = Join-Path -Path $using:Path -ChildPath "$($module.Name).md"
        if (-not (Test-Path -Path $moduleFile))
        {
            New-MarkdownHelp -Module $($module.Name) -OutputFolder $using:Path -WithModulePage | Out-Null
        }

        Update-MarkdownHelpModule -Path $using:Path -RefreshModulePage -Force | Out-Null
    } | Receive-Job -Wait -AutoRemoveJob
}