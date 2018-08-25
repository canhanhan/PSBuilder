function Invoke-GenerateSelfSignedCert
{
    $AvailableCerts = @(Get-ChildItem -Path "Cert:\CurrentUser" -CodeSigningCert -Recurse).Where({ $_.Subject -eq "CN=Test Code Signing Certificate" -and (Test-Certificate -AllowUntrustedRoot -Cert $_) })
    $Certificate = $AvailableCerts | Sort-Object -Descending -Property NotAfter | Select-Object -First 1

    if ($null -eq $Certificate)
    {
        $CertArgs = @{
            Subject = "CN=Test Code Signing Certificate"
            KeyFriendlyName = "Test Code Signing Certificate"
            CertStoreLocation = "Cert:\CurrentUser"
            KeyAlgorithm = "RSA"
            KeyLength = 4096
            Provider = "Microsoft Enhanced RSA and AES Cryptographic Provider"
            KeyExportPolicy = "NonExportable"
            KeyUsage = "DigitalSignature"
            Type = "CodeSigningCert"
            Verbose = $VerbosePreference
        }

        $Certificate = New-SelfSignedCertificate @CertArgs
        "Generated $Certificate"
    }

    $RootPath = "Cert:LocalMachine\Root"
    $TrustedRootEntry = @(Get-ChildItem -Path $RootPath -Recurse).Where({ $_.Thumbprint -eq $Certificate.Thumbprint }) | Select-Object -First 1
    if ($null -eq $TrustedRootEntry)
    {
        $ExportPath = Join-Path -Path $Env:TEMP -ChildPath "cert.crt"
        Export-Certificate -Type CERT -FilePath $ExportPath -Cert $Certificate -Force | Out-Null
        Import-Certificate -FilePath $ExportPath -CertStoreLocation $RootPath | Out-Null
        Remove-Item -Path $ExportPath

        "Copied $Certificate to trusted root"
    }
}