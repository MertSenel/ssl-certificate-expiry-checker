. $PSScriptRoot/Get-RemoteCertificate.ps1

$upperPath = ($PSScriptRoot | split-path)

$endpoints = Get-Content "$upperPath/endpoints.json" | ConvertFrom-Json

$alertThresholds = Get-Content "$upperPath/alertThresholds.json" | ConvertFrom-Json

$sslCertificateDetails = $endpoints | ForEach-Object {
    $cert = Get-RemoteCertificate -ComputerName $_.hostname -Insecure
    Add-Member -InputObject $_ -NotePropertyName "Issuer" -NotePropertyValue $cert.Issuer
    Add-Member -InputObject $_ -NotePropertyName "DaysToExpire" -NotePropertyValue (($cert.NotAfter - (get-date)).Days)

    # Calculate Severity
    if ($_.DaysToExpire) {
        if ($_.DaysToExpire -lt $alertThresholds.Low) {
            $severity = 'Low'
        }
        if ($_.DaysToExpire -lt $alertThresholds.Medium) {
            $severity = 'Medium'
        }
        if ($_.DaysToExpire -lt $alertThresholds.High) {
            $severity = 'High'
        }
        if ($_.DaysToExpire -ge $alertThresholds.Low) {
            $severity = 'None'
        }
    }
    else {
        $severity = 'Error'
    }

    Add-Member -InputObject $_ -NotePropertyName "Severity" -NotePropertyValue $severity
    $_
}

$sslCertificateDetails | ConvertTo-Json | out-file "$upperPath/sslCertificateDetails.json" -Force

