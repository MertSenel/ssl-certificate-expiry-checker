using namespace System.Net.Sockets
using namespace System.Net.Security
using namespace System.Security.Cryptography.X509Certificates

#Refence: https://gist.github.com/IISResetMe/66ab3f0ced4eb406f21bf354cfe7ad45
#Reference: https://blog.iisreset.me/openssl-s_client-but-in-powershell/

function ConvertFrom-X509Certificate {
    param(
        [Parameter(ValueFromPipeline)]
        [X509Certificate2]$Certificate
    )

    process {
        @(
            '-----BEGIN CERTIFICATE-----'
            [Convert]::ToBase64String(
                $Certificate.Export([X509ContentType]::Cert),
                [Base64FormattingOptions]::InsertLineBreaks
            )
            '-----END CERTIFICATE-----'
        ) -join [Environment]::NewLine
    }
}

function Get-RemoteCertificate {
    param(
        [Alias('CN')]
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$ComputerName,
        
        [Parameter(Position = 2)]
        [UInt16]$Port = 443,

        [ValidateSet('Base64', 'X509Certificate')]
        [string]$As = 'X509Certificate',

        [switch]$Insecure
    )

    $tcpClient = [TcpClient]::new($ComputerName, $Port)
    try {
        $tlsClient = [SslStream]::new($tcpClient.GetStream(), $false, { $Insecure })
        $tlsClient.AuthenticateAsClient($ComputerName)

        if ($As -eq 'Base64') {
            return $tlsClient.RemoteCertificate | ConvertFrom-X509Certificate
        }

        return $tlsClient.RemoteCertificate -as [X509Certificate2]
    }
    finally {
        if ($tlsClient -is [IDisposable]) {
            $tlsClient.Dispose()
        }
        $tcpClient.Dispose()
    }
}

