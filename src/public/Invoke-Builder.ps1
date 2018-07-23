function Invoke-Builder
{
    [CmdletBinding(DefaultParameterSetName="Default")]
    param (
        [Parameter(Position=0, ValueFromRemainingArguments=$true)]
        [string[]]$Tasks = (, "default"),

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string[]]$TestTags,

        [switch]$ExitOnError
    )

    $buildRoot = (Get-Location).Path
    $buildFile = "$PSScriptRoot/files/build.tasks.ps1"

    Invoke-psake -buildFile $BuildFile -nologo -parameters @{ "BuildRoot" = $buildRoot } -taskList $Tasks

    if (-not $psake.build_success)
    {
        if ($ExitOnError)
        {
            Exit-Powershell -ExitCode 1
        }
        else
        {
            throw "Build Failed"
        }
    }
}