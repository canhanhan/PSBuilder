Task "Clean" {
    Requires "BuildOutput"

    if (Test-Path -Path $BuildOutput)
    {
        Remove-Item -Path $BuildOutput -Recurse -Force
    }
}

Task "CreateOutputDir" {
    Requires "BuildOutput"

    if (-not (Test-Path -Path $BuildOutput))
    {
        New-Item -Path $BuildOutput -ItemType Directory -Force | Out-Null
    }
}

Task "CopyFiles" "CreateOutputDir", {
    Requires "BuildOutput", "FilesPath"

    if (Test-Path -Path $FilesPath)
    {
        Copy-Item -Path $FilesPath -Destination $BuildOutput -Recurse -Container -Force
    }
}

Task "CopyLicense" "CreateOutputDir", {
    Requires "BuildOutput", "LicensePath"

    if (Test-Path -Path $LicensePath)
    {
        Copy-Item -Path $LicensePath -Destination $BuildOutput -Force
    }
}

Task "CompileModule" "CreateOutputDir", {
    Requires "SourcePath", "MergedFilePath"

    $SourceFile = Join-Path -Path $SourcePath -ChildPath "$Name.psm1"
    if (Test-Path -Path $SourceFile)
    {
        Copy-Item -Path $SourceFile -Destination $MergedFilePath
    }
    else
    {
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
            [void]$builder.AppendLine("Export-ModuleMember -Function @($($publicFunctions.ForEach({ "'$_'" }) -join ", "))")
        }

        Set-Content -Path $MergedFilePath -Value ($builder.ToString()) -Force
    }
}

Task "CreateManifest" "CreateOutputDir", {
    Requires "Name", "Guid", "Author", "Description", "ManifestDestination"

    $ManifestArguments = @{
        "RootModule" = "$Name.psm1"
        "Guid" = $Guid
        "Author" = $Author
        "Description" = $Description
        "Copyright" = "(c) $((Get-Date).Year) $Author. All rights reserved."
    }

    New-ModuleManifest -Path $ManifestDestination @ManifestArguments
}

Task "Compile" "Clean", "CreateOutputDir", "CopyFiles", "CopyLicense", "CreateManifest", "CompileModule"