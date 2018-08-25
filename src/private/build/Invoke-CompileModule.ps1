function Invoke-CompileModule
{
    param (
        [Parameter(Mandatory=$true)]
        [string]$Name,

        [Parameter(Mandatory=$true)]
        [string]$Source,

        [Parameter(Mandatory=$true)]
        [string]$Destination
    )

    if (-not [IO.Path]::IsPathRooted($Source)) { $Source = Resolve-Path -Path $Source }
    if (-not [IO.Path]::IsPathRooted($Destination)) { $Destination = [IO.Path]::GetFullPath($Destination) }

    $buildFolders = ("Classes", "Private", "Public")
    $SourceFile = Join-Path -Path $Source -ChildPath "$Name.psm1"
    if (Test-Path -Path $SourceFile)
    {
        Copy-Item -Path $SourceFile -Destination $Destination

        foreach ($buildFolder in $buildFolders)
        {
            $path = Join-Path -Path $Source -ChildPath $buildFolder
            if (Test-Path -Path $path)
            {
                Copy-Item -Path $path -Destination $BuildOutput -Recurse -Container -Force
            }
        }
    }
    else
    {
        $publicFolder = Join-Path -Path $Source -ChildPath "Public"
        $publicFunctions = @(Get-ChildItem -Path $publicFolder -Filter "*.ps1" -Recurse).ForEach({ $_.BaseName })

        $builder = [System.Text.StringBuilder]::new()
        [void]$builder.AppendLine("Set-StrictMode -Version Latest")
        [void]$builder.AppendLine("`$ErrorActionPreference='Stop'")


        foreach ($buildFolder in $buildFolders)
        {
            $path = Join-Path -Path $Source -ChildPath $buildFolder
            if (-not (Test-Path -Path $path)) { continue }
            $files = Get-ChildItem -Path $path -Filter "*.ps1" -Recurse

            foreach ($file in $files)
            {
                $content = Get-Content -Path $file.FullName -Raw
                [void]$builder.AppendLine("")
                [void]$builder.AppendLine("##### BEGIN $($file.Name) #####")
                [void]$builder.AppendLine("#.ExternalHelp $Name-Help.xml")
                [void]$builder.AppendLine($content)
                [void]$builder.AppendLine("##### END $($file.Name) #####")
                [void]$builder.AppendLine("")
            }
        }

        if ($publicFunctions.Count -gt 0)
        {
            [void]$builder.AppendLine("Export-ModuleMember -Function @($($publicFunctions.ForEach({ "'$_'" }) -join ", "))")
        }

        Set-Content -Path $Destination -Value ($builder.ToString()) -Force
    }
}