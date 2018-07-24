task "GenerateCert" `
    -description "Generates a self-signed code signing certificate" `
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

task "SelectCert" {
    $Certificates = @(Get-ChildItem -Path "Cert:\CurrentUser" -CodeSigningCert -Recurse)

    if (Test-Path -Path "Variable:CertificateThumbprint")
    {
        $Certificates = $Certificates.Where({ $_.Thumbprint -eq $CertificateThumbprint })
    }
    elseif (Test-Path -Path "Variable:CertificateSubject")
    {
        $Certificates = $Certificates.Where({ $_.Subject -eq $CertificateSubject })
    }

    $Script:Certificate = @($Certificates).Where({ Test-Certificate -Cert $_ -ErrorAction SilentlyContinue }) | Sort-Object -Descending -Property NotAfter | Select-Object -First 1
    if ($null -eq $Certificate)
    {
        throw "$($Certificates.Count) code signing certificates were found but none are valid."
    }
}

task "Sign" `
    -precondition { $Sign -eq $true } `
    -depends "Compile", "SelectCert" `
    -requiredVariables "Certificate", "SignFiles", "MergedFilePath", "BuildOutput", "ExtensionsToSign" `
    -description "Signs module code and code files" `
{
    $filesTarget = Join-Path -Path $buildOutput -ChildPath "files"
    $files = (,$MergedFilePath)
    if ($SignFiles -and (Test-Path -Path $filesTarget))
    {
        $files += @(Get-ChildItem -Path $filesTarget\* -Recurse -Include $ExtensionsToSign).ForEach({ $_.FullName })
    }

    foreach ($file in $files) {
        $setAuthSigParams = @{
            FilePath = $file
            Certificate = $certificate
            Verbose = $VerbosePreference
        }

        $result = Set-AuthenticodeSignature @setAuthSigParams
        if ($result.Status -ne 'Valid') {
            throw "Failed to sign: $file. Status: $($result.Status) $($result.StatusMessage)"
        }

        "Successfully signed: $file"
    }
}