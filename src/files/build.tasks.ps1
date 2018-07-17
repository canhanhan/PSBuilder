task "Clean" -requiredVariables "BuildOutput" {
    if (Test-Path $BuildOutput)
    {
        Remove-Item -Path $BuildOutput -Force -Recurse
    }
}

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

task "CompileModule" -precondition { -not $IsScript } -depends "CreateOutputDir", "CopyFiles" {
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

task PublishToRepository -depends Stage {
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

task RunPester -requiredVariables "buildRoot", "mergedFilePath", "isScript" {
    $testResult = Start-Job -ArgumentList ("$BuildRoot\tests", $mergedFilePath, $isScript) -ScriptBlock {
        param($testPath, $filePath, $isScript)

        Set-StrictMode -Version Latest
        $ErrorActionPreference = "Stop"

        Push-Location -StackName "Testing" -Path $testPath

        try
        {
            if ($isScript) { . $filePath } else { Import-Module -Name $filePath -Force }
            Invoke-Pester -PassThru -Verbose -CodeCoverage $filePath
        }
        finally
        {
            Pop-Location -StackName "Testing"
        }
    } | Receive-Job -Wait -AutoRemoveJob

    assert ($testResult.FailedCount -eq 0) ('Failed {0} Unit tests. Aborting Build' -f $testResult.FailedCount)

    $testCoverage = [int]($testResult.CodeCoverage.NumberOfCommandsExecuted / $testResult.CodeCoverage.NumberOfCommandsAnalyzed * 100)
    "Pester code coverage: ${testCoverage}%"
}

task Compile -depends CompileModule, CompileScript
task Stage -depends Clean, CreateOutputDir, Compile
task Test -depends Stage, RunPester
task Publish -depends Clean, Stage, Test, PublishToRepository