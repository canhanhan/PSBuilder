function SetDefault($Name, $Value)
{
    if (-not (Test-Path -Path "Variable:$Name"))
    {
        Set-Variable -Name $Name -Value $Value -Scope Script
    }
}

Properties {
    SetDefault "IsScript" $false
    SetDefault "BuildRoot" $psake.build_script_dir
    SetDefault "Name" ([IO.Path]::GetFileName([IO.Path]::GetDirectoryName($BuildRoot + "/")))
    SetDefault "BuildOutput" (Join-Path -Path $BuildRoot -ChildPath "output")
    SetDefault "SourcePath" (Join-Path -Path $BuildRoot -ChildPath "src")
    SetDefault "DocumentationPath" (Join-Path $BuildOutput -ChildPath "docs")

    if ($IsScript)
    {
        SetDefault "SourceFilePath" (Join-Path -Path $SourcePath -ChildPath "$Name.ps1")
        SetDefault "MergedFilePath" (Join-Path -Path $BuildOutput -ChildPath "$Name.ps1")
    }
    else
    {
        SetDefault "SourceFilePath" (Join-Path -Path $SourcePath -ChildPath "$Name.psm1")
        SetDefault "ManifestDestination" (Join-Path -Path $BuildOutput -ChildPath "$Name.psd1")
        SetDefault "MergedFilePath" (Join-Path -Path $BuildOutput -ChildPath "$Name.psm1")
    }

    SetDefault "CodeCoverageMin" 0
    SetDefault "AnalysisFailureLevel" "Error"
    SetDefault "AnalysisSettingsFile" ""
    SetDefault "TestTags" @()

    SetDefault "ExtensionsToSign" "*.ps1", "*.psd1", "*.psm1"
    SetDefault "SignFiles" $true
}