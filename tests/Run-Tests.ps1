#Requires -Modules @{ ModuleName="Pester"; ModuleVersion="5.3.3" }

BeforeDiscovery { 
    $sslCertificateDetails = Get-Content "$PSScriptRoot/../sslCertificateDetails.json" | ConvertFrom-Json
}

Describe "Alert Severity of SSL Certificate of <_.hostname>" -ForEach $sslCertificateDetails {
    It "is equals to None" {
        $_.Severity | Should -Not -BeIn @("Low", "Medium", "High", "Error")
    }
}

