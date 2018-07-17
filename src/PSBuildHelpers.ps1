<#PSScriptInfo
.VERSION 1.1
.GUID c2034bae-5d1a-4bb2-9815-2d3cf7a16453
.AUTHOR Can Hanhan
.DESCRIPTION Shared components for build scripts
#>

requires -Property BuildOutput, SourcePath, Name, IsScript

if (-not [io.path]::IsPathRooted($BuildOutput))
{
    $BuildOutput = Join-Path -Path $BuildRoot -ChildPath $BuildOutput
}

if (-not [io.path]::IsPathRooted($SourcePath))
{
    $SourcePath = Join-Path -Path $BuildRoot -ChildPath $SourcePath
}

if (-not $IsScript)
{
    $ManifestFilePath = Join-Path -Path $SourcePath -ChildPath "$Name.psd1"
    $ManifestDestination = Join-Path -Path $BuildOutput -ChildPath "$Name.psd1"
    $SourceFilePath = Join-Path -Path $SourcePath -ChildPath "$Name.psm1"
    $MergedFilePath = Join-Path -Path $BuildOutput -ChildPath "$Name.psm1"
}
else
{
    $SourceFilePath = Join-Path -Path $SourcePath -ChildPath "$Name.ps1"
    $MergedFilePath = Join-Path -Path $BuildOutput -ChildPath "$Name.ps1"
}

function Get-NugetApiKey
{
    if (Test-Path -Path "Variable:NugetCredential")
    {
        "$($NugetCredential.Username):$($NugetCredential.GetNetworkCredential().Password)"
    }
    elseif (Test-Path -Path "Env:NugetCredential")
    {
        $Env:NugetCredential
    }
    else
    {
        $null
    }
}

function Invoke-ReplaceMagicMarker
{
    param (
        [Parameter(Mandatory=$true)]
        [scriptblock]$Builder
    )

    $mergedFileContent = Get-Content -Path $MergedFilePath -Raw
    if ($mergedFileContent -match "(?m)^([ \t]*)### MERGE HERE ###\s*$")
    {
        $whitespace = $Matches[1]
        $source = $builder.Invoke() -replace "(?m)^(?!(?:\r|\n|$))", $whitespace
        $mergedFileContent = $mergedFileContent -replace "(?m)^([ \t]*)### MERGE HERE ###\s*$", $source

        Set-Content -Path $MergedFilePath -Value $mergedFileContent -Force
    }
    else
    {
        Write-Build -Color Yellow "Found $SourceFilePath but magic marker '### MERGE HERE ###' does not exist. Skipping compile..."
    }
}

task Clean {
    if (Test-Path $BuildOutput)
    {
        Write-Build -Color Green "Removing $BuildOutput\*"
        Remove-Item -Path $BuildOutput -Force -Recurse
    }
}

task CreateOutputDir {
    if (-not (Test-Path $BuildOutput))
    {
        New-Item -Path $BuildOutput -ItemType Directory | Out-Null
    }
}

task CopyFiles CreateOutputDir, {
    $FilesPath = Join-Path -Path $SourcePath -ChildPath "files"
    if (Test-Path -Path $FilesPath)
    {
        Copy-Item -Path $FilesPath -Destination $BuildOutput -Recurse -Container
    }
}

task CreateOrCopyModuleFile -If (-not $IsScript) CreateOutputDir, {
    if (Test-Path -Path $SourceFilePath)
    {
        Copy-Item -Path $SourceFilePath -Destination $MergedFilePath
    }
    else
    {
        $publicFolder = Join-Path -Path $SourcePath -ChildPath "Public"
        $publicFunctions = @(Get-ChildItem -Path $publicFolder -Filter "*.ps1" -Recurse).ForEach({ $_.BaseName })

        $builder = [System.Text.StringBuilder]::new()
        [void]$builder.AppendLine("Set-StrictMode -Version Latest")
        [void]$builder.AppendLine("`$ErrorActionPreference='Stop'")
        [void]$builder.AppendLine("### MERGE HERE ###")

        if ($publicFunctions.Count -gt 0)
        {
            [void]$builder.AppendLine("Export-ModuleMember -Function (, $($publicFunctions.ForEach({ "'$_'" }) -join ", "))")
        }

        Set-Content -Path $MergedFilePath -Value ($builder.ToString()) -Force
    }
}

task CompileModule -If (-not $IsScript) CreateOutputDir, CreateOrCopyModuleFile, {
    Invoke-ReplaceMagicMarker -Builder {
        $builder = [System.Text.StringBuilder]::new()

        $buildFolders = ("Classes", "Private", "Public")
        foreach ($buildFolder in $buildFolders)
        {
            $path = Join-Path -Path $SourcePath -ChildPath $buildFolder
            if (-not (Test-Path -Path $path)) { continue }
            $files = Get-ChildItem -Path $path -Filter "*.ps1" -Recurse

            foreach ($file in $files)
            {
                $content = Get-Content -Path $file.FullName -Raw
                [void]$builder.AppendLine("")
                [void]$builder.AppendLine("##### BEGIN $($file.Name) #####")
                [void]$builder.AppendLine($content)
                [void]$builder.AppendLine("##### END $($file.Name) #####")
                [void]$builder.AppendLine("")
            }
        }

        $builder.ToString()
    }

    Copy-Item -Path $ManifestFilePath -Destination $ManifestDestination
}

task CreateOrCopyScriptFile -If $IsScript CreateOutputDir, {
    if (Test-Path -Path $SourceFilePath)
    {
        Copy-Item -Path $SourceFilePath -Destination $MergedFilePath
    }
    else
    {
        $builder = [System.Text.StringBuilder]::new()
        [void]$builder.AppendLine("Set-StrictMode -Version Latest")
        [void]$builder.AppendLine("`$ErrorActionPreference='Stop'")
        [void]$builder.AppendLine("### MERGE HERE ###")
        Set-Content -Path $MergedFilePath -Value ($builder.ToString()) -Force
    }
}

task CompileScript -If $IsScript CreateOutputDir, CreateOrCopyScriptFile, {
    Invoke-ReplaceMagicMarker -Builder {
        $builder = [System.Text.StringBuilder]::new()

        $files = Get-ChildItem -Path $SourcePath -Filter "*.ps1" -Recurse
        foreach ($file in $files)
        {
            $content = Get-Content -Path $file.FullName -Raw
            [void]$builder.AppendLine("")
            [void]$builder.AppendLine("##### BEGIN $($file.Name) #####")
            [void]$builder.AppendLine($content)
            [void]$builder.AppendLine("##### END $($file.Name) #####")
            [void]$builder.AppendLine("")
        }

        $builder.ToString()
    }
}

task PublishToRepository Stage, {
    $publishParams = @{ "Path" = $MergedFilePath }

    if (Test-Path "Variable:PublishRepository")
    {
        $publishParams["Repository"] = $PublishRepository
    }

    $nugetApiKey = Get-NugetApiKey
    if ($null -ne $nugetApiKey)
    {
        $publishParams["NuGetApiKey"] = $nugetApiKey
    }

    if ($IsScript)
    {
        Publish-Script @publishParams
    }
    else
    {
        Publish-Module @publishParams
    }
}

task ImportOutput {
    if ($IsScript)
    {
        . $MergedFilePath
    }
    else
    {
        Import-Module -Name $ManifestDestination
    }
}

task RunPester ImportOutput, {
    try
    {
        Push-Location -StackName "Testing" -Path "$BuildRoot\tests"
        $testResult = Invoke-Pester -PassThru -Verbose
        assert ($testResult.FailedCount -eq 0) ('Failed {0} Unit tests. Aborting Build' -f $testResult.FailedCount)
    }
    finally
    {
        Pop-Location -StackName "Testing"
    }
}

task Compile CompileModule, CompileScript
task Stage Clean, CreateOutputDir, Compile
task Test Stage, RunPester
task Publish Clean, Stage, Test, PublishToRepository