function Invoke-CreateMarkdown
{
    param (
        [Parameter(Mandatory=$true)]
        [string]$Manifest,

        [Parameter(Mandatory=$true)]
        [string]$Path
    )

    $module = Import-Module -Name $Manifest -Global -Force -PassThru
    if (-not (Test-Path -Path $Path))
    {
        New-Item -Path $Path -ItemType Directory -Force | Out-Null
    }

    $moduleFile = Join-Path -Path $Path -ChildPath "$($module.Name).md"
    if (-not (Test-Path -Path $moduleFile))
    {
        New-MarkdownHelp -Module $($module.Name) -OutputFolder $Path -WithModulePage | Out-Null
    }

    Update-MarkdownHelpModule -Path $Path -RefreshModulePage | Out-Null
}