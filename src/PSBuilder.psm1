Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Exit-Powershell {
    param ([int]$ExitCode=0)

    exit $ExitCode
 }

 #.ExternalHelp PSBuilder-Help.xml
 function Invoke-Builder
{
    [CmdletBinding(DefaultParameterSetName="Default")]
    param (
        [Parameter(Position=0, ValueFromRemainingArguments=$true)]
        [string[]]$Tasks,

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string[]]$TestTags,

        [switch]$ExitOnError
    )

    $buildRoot = (Get-Location).Path
    $buildFile = "$PSScriptRoot/files/build.tasks.ps1"

    $buildParameters = @{ "BuildRoot" = $buildRoot }
    (Get-ChildItem -Path "Env:").Where({ $_.Name -like "PSBuilder*" }).ForEach({ $buildParameters[$_.Name.Substring(9)] = $_.Value })

    try
    {
        $failed = $false
        Invoke-Build -Task $Tasks -File $BuildFile -Result "result" @buildParameters
    }
    catch
    {
        $failed = $true
        if (-not $ExitOnError) { throw }
    }


    if ($failed -or $result.Errors.Count -gt 0)
    {
        if ($ExitOnError)
        {
            Exit-Powershell -ExitCode 1
        }
        else
        {
            throw "Build Failed..."
        }
    }
}

Export-ModuleMember -Function "Invoke-Builder"