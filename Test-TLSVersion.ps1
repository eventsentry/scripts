param (
    [string]$hostname,
    [int]$port
)

$Title = "EventSentry TLS version check"
$host.UI.RawUI.WindowTitle = $Title
Write-Host ""
Write-Host "EventSentry TLS version check script"
Write-Host ""

if (-not $hostname -or -not $port) {
    Write-Host "Usage: .\Test-TlsVersion.ps1 -hostname <hostname or IP> <port>"
    Write-Host "Example .\Test-TlsVersion.ps1 172.24.1.1 5001"
    Write-Host ""
    exit
}

function Test-TlsVersion {
    param (
        [string]$hostname,
        [int]$port
    )
    
    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $tcpClient.Connect($hostname, $port)
        
        $sslStream = New-Object System.Net.Security.SslStream($tcpClient.GetStream(), $false, ({ $true }))
        $sslStream.AuthenticateAsClient($host)
        
        Write-Output "TLS Version: $($sslStream.SslProtocol)"
        
        $sslStream.Close()
        $tcpClient.Close()
    }
    catch {
        Write-Error "Failed to connect or determine TLS version: $_"
    }
}

# Call the function with command-line arguments
Test-TlsVersion -hostname $hostname -port $port
