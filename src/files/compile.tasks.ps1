task "Clean" -requiredVariables "BuildOutput" {
    if (Test-Path $BuildOutput)
    {
        Remove-Item -Path $BuildOutput -Force -Recurse
    }
}

task "CreateOutputDir" -depends "Clean" -requiredVariables "BuildOutput" {
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

task "CopyLicense" -depends "CreateOutputDir" -requiredVariables "BuildRoot", "BuildOutput" {
    $LicensePath = Join-Path -Path $BuildRoot -ChildPath "LICENSE"
    if (Test-Path -Path $LicensePath)
    {
        Copy-Item -Path $LicensePath -Destination $BuildOutput
    }
}

task "CompileModule" -depends "CreateOutputDir", "CopyFiles", "CopyLicense" -requiredVariables "ManifestDestination" {
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

task Compile -depends CompileModule
task Stage -depends Clean, CreateOutputDir, Compile, Sign