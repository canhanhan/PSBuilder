function Invoke-Sign
{
    param (
        [Parameter(Mandatory=$false)]
        [string]$CertificateThumbprint,

        [Parameter(Mandatory=$false)]
        [string]$CertificateSubject,

        [string]$CertificatePath,

        [securestring]$CertificatePassword,

        [string]$Name,

        [string]$Path,

        [string]$HashAlgorithm
    )

    if ($CertificatePath -like "Cert:*")
    {
        $Certificates = @(Get-ChildItem -Path $CertificatePath -CodeSigningCert)
    }
    else
    {
        $Certificates = @([System.Security.Cryptography.X509Certificates.X509Certificate2]::new($CertificatePath, $CertificatePassword))
    }

    if (-not [string]::IsNullOrEmpty($CertificateThumbprint))
    {
        $Certificates = $Certificates.Where({ $_.Thumbprint -eq $CertificateThumbprint })
    }
    elseif (-not [string]::IsNullOrEmpty($CertificateSubject))
    {
        $Certificates = $Certificates.Where({ $_.Subject -eq $CertificateSubject })
    }

    $Script:Certificate = @($Certificates).Where({ $_.HasPrivateKey -and $_.NotAfter -gt (Get-Date) }) | Sort-Object -Descending -Property NotAfter | Select-Object -First 1
    if ($null -eq $Certificate)
    {
        throw "$($Certificates.Count) code signing certificates were found but none are valid."
    }

    $files = @(Get-ChildItem -Path $Path -Recurse -Include $ExtensionsToSign).ForEach({ $_.FullName })

    foreach ($file in $files) {
        $setAuthSigParams = @{
            FilePath = $file
            Certificate = $certificate
            HashAlgorithm = $HashAlgorithm
            Verbose = $VerbosePreference
        }

        $result = Set-AuthenticodeSignature @setAuthSigParams
        if ($result.Status -ne 'Valid') {
            throw "Failed to sign: $file. Status: $($result.Status) $($result.StatusMessage)"
        }

        "Successfully signed: $file"
    }

    $catalogFile = "$Path\$Name.cat"
    $catalogParams = @{
        Path = $Path
        CatalogFilePath = $catalogFile
        CatalogVersion = 2.0
        Verbose = $VerbosePreference
    }
    New-FileCatalog @catalogParams | Out-Null

    $catalogSignParams = @{
        FilePath = $catalogFile
        Certificate = $certificate
        HashAlgorithm = $HashAlgorithm
        Verbose = $VerbosePreference
    }
    $result = Set-AuthenticodeSignature @catalogSignParams
    if ($result.Status -ne 'Valid') {
        throw "Failed to sign the catalog file. Status: $($result.Status) $($result.StatusMessage)"
    }
}