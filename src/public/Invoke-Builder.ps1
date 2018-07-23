function Invoke-Builder
{
    [CmdletBinding(DefaultParameterSetName="Default")]
    param (
        [Parameter(Position=0, ValueFromRemainingArguments=$true)]
        [string[]]$Tasks = (, "default"),

        [Parameter(Mandatory=$true, ParameterSetName="UseFile")]
        [ValidateNotNullOrEmpty()]
        [string]$ConfigurationFile="build.json",

        [Parameter(Mandatory=$true, ParameterSetName="UseHashtable")]
        [ValidateNotNull()]
        [hashtable]$Configuration=@{},

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string[]]$TestTags,

        [switch]$ExitWithCode
    )

    $buildRoot = (Get-Location).Path
    $buildFile = "$PSScriptRoot/files/build.tasks.ps1"

    if (-not [IO.Path]::IsPathRooted($ConfigurationFile))
    {
       $ConfigurationFile = Join-Path -Path $buildRoot -ChildPath $ConfigurationFile
    }

    if (-not (Test-Path -Path $ConfigurationFile))
    {
        if ($PSCmdlet.ParameterSetName -eq "UseFile") { throw "Configuration file does not exist in $ConfigurationFile" }
    }
    else
    {
        $config = Get-Content $ConfigurationFile | ConvertFrom-Json
        @(Get-Member -InputObject $config -MemberType NoteProperty).ForEach({
            $Configuration[$_.Name] = $config."$($_.Name)"
        })
    }

    $Configuration["BuildRoot"] = $buildRoot

    Invoke-psake -buildFile $BuildFile -nologo -parameters $Configuration -taskList $Tasks

    if (-not $psake.build_success)
    {
        if ($ExitWithCode)
        {
            Exit-Powershell -ExitCode 1
        }
        else
        {
            throw "Build Failed"
        }
    }
}