Properties {
    $IsScript = $false
    $BuildRoot = $psake.build_script_dir

    if (-not (Test-Path -Path "Variable:Name"))
    {
        $Name = [IO.Path]::GetFileName([IO.Path]::GetDirectoryName($BuildRoot + "/"))
    }

    $BuildOutput = Join-Path -Path $BuildRoot -ChildPath "output"
    $SourcePath = Join-Path -Path $BuildRoot -ChildPath "src"

    if ($IsScript)
    {
        $SourceFilePath = Join-Path -Path $SourcePath -ChildPath "$Name.ps1"
        $MergedFilePath = Join-Path -Path $BuildOutput -ChildPath "$Name.ps1"
    }
    else
    {
        $SourceFilePath = Join-Path -Path $SourcePath -ChildPath "$Name.psm1"
        $ManifestDestination = Join-Path -Path $BuildOutput -ChildPath "$Name.psd1"
        $MergedFilePath = Join-Path -Path $BuildOutput -ChildPath "$Name.psm1"
    }

    $CodeCoverageMin = 0
    $AnalysisFailureLevel = "Error"
    $AnalysisSettingsFile = ""
    $TestTags = @()
    $DocumentationPath = "$PSScriptRoot/docs"

    $ExtensionsToSign = "*.ps1", "*.psd1", "*.psm1"
    $SignFiles = $true
}