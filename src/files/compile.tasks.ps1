task "Clean" -requiredVariables "BuildOutput" {
    if (Test-Path -Path $BuildOutput)
    {
        Remove-Item -Path $BuildOutput -Force -Recurse
    }
}

task "CreateOutputDir" -requiredVariables "BuildOutput" {
    if (-not (Test-Path -Path $BuildOutput))
    {
        New-Item -Path $BuildOutput -ItemType Directory -Force | Out-Null
    }
}

task "CopyFiles" -depends "CreateOutputDir" -requiredVariables "BuildOutput", "FilesPath" {
    if (Test-Path -Path $FilesPath)
    {
        Copy-Item -Path $FilesPath -Destination $BuildOutput -Recurse -Container -Force
    }
}

task "CopyLicense" -depends "CreateOutputDir" -requiredVariables "BuildOutput", "LicensePath" {
    if (Test-Path -Path $LicensePath)
    {
        Copy-Item -Path $LicensePath -Destination $BuildOutput -Force
    }
}

task "CompileModule" -depends "CreateOutputDir" -requiredVariables "SourcePath", "MergedFilePath" {
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
}

task "CopyManifest" -requiredVariables "Name", "SourcePath", "ManifestDestination" {
    $ManifestFilePath = Join-Path -Path $SourcePath -ChildPath "$Name.psd1"
    Copy-Item -Path $ManifestFilePath -Destination $ManifestDestination
}

task "Compile" -depends "CreateOutputDir", "CopyFiles", "CopyLicense", "CopyManifest", "CompileModule"
task "Stage" -depends "Clean", "CreateOutputDir", "Compile", "Sign"