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

        [switch]$ThrowOnError,
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

    if (-not $Configuration.ContainsKey("IsScript")) { $Configuration["IsScript"] = $false }
    if (-not $Configuration.ContainsKey("BuildRoot")) { $Configuration["BuildRoot"] = $buildRoot }
    if (-not $Configuration.ContainsKey("BuildOutput")) { $Configuration["BuildOutput"] = Join-Path -Path $buildRoot -ChildPath "output" }
    if (-not $Configuration.ContainsKey("SourcePath")) { $Configuration["SourcePath"] = Join-Path -Path $buildRoot -ChildPath "src" }
    if (-not $Configuration.ContainsKey("Name")) { $Configuration["Name"] = [IO.Path]::GetFileName([IO.Path]::GetDirectoryName($buildRoot + "/")) }
    if (-not $Configuration.ContainsKey("CodeCoverageMin")) { $Configuration["CodeCoverageMin"] = 0 }
    if (-not $Configuration.ContainsKey("TestTags")) { $Configuration["TestTags"] = @() }
    if (-not $Configuration.ContainsKey("AnalysisFailureLevel")) { $Configuration["AnalysisFailureLevel"] = "None" }
    if (-not $Configuration.ContainsKey("AnalysisSettingsFile")) { $Configuration["AnalysisSettingsFile"] = "" }

    if (-not $Configuration["IsScript"])
    {
        $Configuration["ManifestDestination"] = Join-Path -Path $Configuration["BuildOutput"] -ChildPath "$($Configuration["Name"]).psd1"
        $Configuration["SourceFilePath"] = Join-Path -Path $Configuration["SourcePath"] -ChildPath "$($Configuration["Name"]).psm1"
        $Configuration["MergedFilePath"] = Join-Path -Path $Configuration["BuildOutput"] -ChildPath "$($Configuration["Name"]).psm1"
    }
    else
    {
        $Configuration["SourceFilePath"] = Join-Path -Path $Configuration["SourcePath"] -ChildPath "$($Configuration["Name"]).ps1"
        $Configuration["MergedFilePath"] = Join-Path -Path $Configuration["BuildOutput"] -ChildPath "$($Configuration["Name"]).pm1"
    }

    Invoke-psake -buildFile $buildFile -nologo -parameters $Configuration -taskList $Tasks -OutVariable psakeResult

    if (-not $Psake.build_success)
    {
        if (-not $ExitWithCode -and $ThrowOnError)
        {
            throw $psakeResult
        }

        if ($ExitWithCode)
        {
            Exit-Powershell -ExitCode 1
        }
    }
}