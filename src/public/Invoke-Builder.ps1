function Invoke-Builder
{
    [CmdletBinding(DefaultParameterSetName="Default")]
    param (
        [Parameter(Position=0, ValueFromRemainingArguments=$true)]
        [string[]]$Tasks,

        [Parameter(Mandatory=$false)]
        [hashtable]$Parameters = $null,

        [switch]$ExitOnError
    )

    $buildRoot = (Get-Location).Path
    $buildFile = "$PSScriptRoot/files/build.tasks.ps1"
    $buildScript = Get-Command -Name $buildFile

    $buildParameters = @{ "BuildRoot" = $buildRoot }
    (Get-ChildItem -Path "Env:").Where({ $_.Name -like "PSBuilder*" }).ForEach({ $buildParameters[$_.Name.Substring(9)] = $_.Value })
    if ($null -ne $Parameters) { $buildParameters += $Parameters }

    foreach ($parameter in @($buildParameters.Keys))
    {
        if (-not $buildScript.Parameters.ContainsKey($parameter))
        {
            throw "Unknown parameter: $parameter"
        }

        $buildParameterType = $buildScript.Parameters[$parameter].ParameterType
        $currentValue = $buildParameters[$parameter]
        if ($buildParameterType -eq [string[]] -and $currentValue -is [string])
        {
            $buildParameters[$parameter] = $currentValue -split ","
        }
        elseif ($buildParameterType -eq [securestring])
        {
            $value = [securestring]::new()
            $currentValue.ToCharArray().ForEach({ $value.AppendChar($_) })
            $buildParameters[$parameter] = $value
        }
        elseif ($buildParameterType -eq [bool])
        {
            $buildParameters[$parameter] = [Convert]::ToBoolean($buildParameters[$parameter])
        }
        elseif ($buildParameterType -eq [int])
        {
            $buildParameters[$parameter] = [Convert]::ToInt32($buildParameters[$parameter])
        }
        elseif ($buildParameterType -eq [datetime])
        {
            $buildParameters[$parameter] = [Convert]::ToDateTime($buildParameters[$parameter])
        }
    }

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