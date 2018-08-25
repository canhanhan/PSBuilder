function Invoke-Sign
{
    param (
        [Parameter(Mandatory=$false)]
        [string]$CertificateThumbprint,

        [Parameter(Mandatory=$false)]
        [string]$CertificateSubject,

        [string]$Path
    )

    $Certificates = @(Get-ChildItem -Path "Cert:\CurrentUser" -CodeSigningCert -Recurse)

    if (-not [string]::IsNullOrEmpty($CertificateThumbprint))
    {
        $Certificates = $Certificates.Where({ $_.Thumbprint -eq $CertificateThumbprint })
    }
    elseif (-not [string]::IsNullOrEmpty($CertificateSubject))
    {
        $Certificates = $Certificates.Where({ $_.Subject -eq $CertificateSubject })
    }

    $Script:Certificate = @($Certificates).Where({ Test-Certificate -Cert $_ -ErrorAction SilentlyContinue }) | Sort-Object -Descending -Property NotAfter | Select-Object -First 1
    if ($null -eq $Certificate)
    {
        throw "$($Certificates.Count) code signing certificates were found but none are valid."
    }

    $files = @(Get-ChildItem -Path $Path -Recurse -Include $ExtensionsToSign).ForEach({ $_.FullName })

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