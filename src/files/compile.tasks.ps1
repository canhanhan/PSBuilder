task "Clean" `
    -requiredVariables "BuildOutput" `
    -description "Removes output from previous builds" `
{
    if (Test-Path -Path $BuildOutput)
    {
        Remove-Item -Path $BuildOutput -Recurse -Force
    }
}

task "CreateOutputDir" `
    -requiredVariables "BuildOutput" `
    -description "Creates a blank output directory" `
{
    if (-not (Test-Path -Path $BuildOutput))
    {
        New-Item -Path $BuildOutput -ItemType Directory -Force | Out-Null
    }
}

task "CopyFiles" `
    -depends "CreateOutputDir" `
    -requiredVariables "BuildOutput", "FilesPath" `
    -description "Copies extra files to output" `
{
    if (Test-Path -Path $FilesPath)
    {
        Copy-Item -Path $FilesPath -Destination $BuildOutput -Recurse -Container -Force
    }
}

task "CopyLicense" `
    -depends "CreateOutputDir" `
    -requiredVariables "BuildOutput", "LicensePath" `
    -description "Copy license file to output" `
{
    if (Test-Path -Path $LicensePath)
    {
        Copy-Item -Path $LicensePath -Destination $BuildOutput -Force
    }
}

task "CompileModule" `
    -depends "CreateOutputDir" `
    -requiredVariables "SourcePath", "MergedFilePath" `
    -description "Compiles Powershell files into a module file" `
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

task "CreateManifest" `
    -depends "CreateOutputDir" `
    -requiredVariables "Name", "Guid", "Author", "Description", "ManifestDestination" `
    -description "Creates a module manifest file" `
{
    $ManifestArguments = @{
        "RootModule" = "$Name.psm1"
        "Guid" = $Guid
        "Author" = $Author
        "Description" = $Description
        "Copyright" = "(c) $((Get-Date).Year) $Author. All rights reserved."
    }

    $ManifestFilePath = Join-Path -Path $SourcePath -ChildPath "$Name.psd1"
    New-ModuleManifest -Path $ManifestFilePath @ManifestArguments
}

task "Compile" `
    -depends "Clean", "CreateOutputDir", "CopyFiles", "CopyLicense", "CreateManifest", "CompileModule", "Sign" `
    -description "Compiles and signs the module"