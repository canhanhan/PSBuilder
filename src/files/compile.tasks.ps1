task "CreateOutputDir" -requiredVariables "BuildOutput" {
    if (-not (Test-Path $BuildOutput))
    {
        New-Item -Path $BuildOutput -ItemType Directory | Out-Null
    }
}

task "CopyFiles" -depends "CreateOutputDir" -requiredVariables "SourcePath" {
    $FilesPath = Join-Path -Path $SourcePath -ChildPath "files"
    if (Test-Path -Path $FilesPath)
    {
        Copy-Item -Path $FilesPath -Destination $BuildOutput -Recurse -Container
    }
}

task "CompileModule" -precondition { -not $IsScript } -depends "CreateOutputDir", "CopyFiles" -requiredVariables "ManifestDestination" {
    $publicFolder = Join-Path -Path $SourcePath -ChildPath "Public"
    $publicFunctions = @(Get-ChildItem -Path $publicFolder -Filter "*.ps1" -Recurse).ForEach({ $_.BaseName })

    $builder = [System.Text.StringBuilder]::new()
    [void]$builder.AppendLine("Set-StrictMode -Version Latest")
    [void]$builder.AppendLine("`$ErrorActionPreference='Stop'")

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

    if ($publicFunctions.Count -gt 0)
    {
        [void]$builder.AppendLine("Export-ModuleMember -Function (, $($publicFunctions.ForEach({ "'$_'" }) -join ", "))")
    }

    Set-Content -Path $MergedFilePath -Value ($builder.ToString()) -Force

    $ManifestFilePath = Join-Path -Path $SourcePath -ChildPath "$Name.psd1"
    Copy-Item -Path $ManifestFilePath -Destination $ManifestDestination
}

task "CreateOrCopyScriptFile" -precondition { $IsScript } -depends "CreateOutputDir" -requiredVariables "SourceFilePath", "MergedFilePath" {
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

task "CompileScript" -precondition { $IsScript } -depends "CreateOutputDir", "CreateOrCopyScriptFile" {
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

task Compile -depends CompileModule, CompileScript
task Stage -depends Clean, CreateOutputDir, Compile