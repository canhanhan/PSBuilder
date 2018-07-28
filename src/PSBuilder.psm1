Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Exit-Powershell {
    param ([int]$ExitCode=0)

    exit $ExitCode
 }

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

    Invoke-Build -Task $Tasks -File $BuildFile -Result "result" -BuildRoot $buildRoot

    if ($result.Errors.Count -gt 0)
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

Export-ModuleMember -Function "Invoke-Builder"