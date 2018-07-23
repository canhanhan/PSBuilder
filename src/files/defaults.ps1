function SetDefault($VariableName, $Value)
{
    if (-not (Test-Path -Path "Variable:$VariableName"))
    {
        Set-Variable -Name $VariableName -Value $Value -Scope Script
    }
}

Properties {
    SetDefault "BuildRoot" (Get-Location).Path
    SetDefault "Name" ([IO.Path]::GetFileName([IO.Path]::GetDirectoryName($BuildRoot + "/")))
    SetDefault "BuildOutput" (Join-Path -Path $BuildRoot -ChildPath "output/$Name")
    SetDefault "SourcePath" (Join-Path -Path $BuildRoot -ChildPath "src")
    SetDefault "DocumentationPath" (Join-Path $BuildOutput -ChildPath "docs")
    SetDefault "SourceFilePath" (Join-Path -Path $SourcePath -ChildPath "$Name.psm1")
    SetDefault "ManifestDestination" (Join-Path -Path $BuildOutput -ChildPath "$Name.psd1")
    SetDefault "MergedFilePath" (Join-Path -Path $BuildOutput -ChildPath "$Name.psm1")

    SetDefault "CodeCoverageMin" 0
    SetDefault "AnalysisFailureLevel" "Error"
    SetDefault "AnalysisSettingsFile" ""
    SetDefault "TestTags" @()

    SetDefault "ExtensionsToSign" "*.ps1", "*.psd1", "*.psm1"
    SetDefault "Sign" $false
    SetDefault "SignFiles" $true
}