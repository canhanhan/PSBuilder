function Get-NugetApiKey
{
    if (Test-Path -Path "Variable:NugetCredential")
    {
        "$($NugetCredential.Username):$($NugetCredential.GetNetworkCredential().Password)"
    }
    elseif (Test-Path -Path "Env:NugetCredential")
    {
        $Env:NugetCredential
    }
    else
    {
        $null
    }
}