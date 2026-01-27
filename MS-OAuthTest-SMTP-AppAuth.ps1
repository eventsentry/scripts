<#
.SYNOPSIS
    Sends a test email using Microsoft 365 SMTP with OAuth authentication.

.DESCRIPTION
    This script obtains an OAuth access token using client credentials and sends a test email via SMTP.
    Useful for troubleshooting OAuth configuration issues by validating that the Tenant ID, Client ID,
    Client Secret, and sender email address are working correctly outside of the application.

.NOTES
    Author: Netikus.net
    Date: January 2026
    Version: 1.1
#>

$tenantId     = "your-tenant-id"
$clientId     = "your-client-id"
$clientSecret = "your-client-secret"
$fromEmail    = "sender@yourdomain.com"
$toEmail      = "recipient@example.com"
$smtpServer   = "smtp.office365.com"
$smtpPort     = 587

# Get Token
$tokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" -Method POST -Body @{
    grant_type    = "client_credentials"
    client_id     = $clientId
    client_secret = $clientSecret
    scope         = "https://outlook.office365.com/.default"
}

Write-Host "Token acquired successfully" -ForegroundColor Green

# Build XOAUTH2 string
$authString = "user=$fromEmail$([char]1)auth=Bearer $($tokenResponse.access_token)$([char]1)$([char]1)"
$authBase64 = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($authString))

# Connect via SMTP
$tcpClient = New-Object System.Net.Sockets.TcpClient($smtpServer, $smtpPort)
$stream = $tcpClient.GetStream()
$stream.ReadTimeout = 10000
$stream.WriteTimeout = 10000
$reader = New-Object System.IO.StreamReader($stream)
$writer = New-Object System.IO.StreamWriter($stream)
$writer.AutoFlush = $true

function Read-Response {
    $response = ""
    do {
        $line = $reader.ReadLine()
        Write-Host $line -ForegroundColor Gray
        $response += $line
    } while ($line -match "^\d{3}-")
    return $response
}

function Send-Command($cmd, $mask = $false) {
    if ($mask) { Write-Host ">>> [AUTH DATA HIDDEN]" -ForegroundColor Cyan }
    else { Write-Host ">>> $cmd" -ForegroundColor Cyan }
    $writer.WriteLine($cmd)
    return Read-Response
}

# SMTP conversation
Read-Response
Send-Command "EHLO localhost"
Send-Command "STARTTLS"

# Upgrade to TLS
$sslStream = New-Object System.Net.Security.SslStream($stream, $false)
$sslStream.AuthenticateAsClient($smtpServer)
$sslStream.ReadTimeout = 10000
$sslStream.WriteTimeout = 10000
$reader = New-Object System.IO.StreamReader($sslStream)
$writer = New-Object System.IO.StreamWriter($sslStream)
$writer.AutoFlush = $true

Send-Command "EHLO localhost"
$authResponse = Send-Command "AUTH XOAUTH2 $authBase64" $true

if ($authResponse -notmatch "^235") {
    Write-Host "Authentication failed!" -ForegroundColor Red
    $tcpClient.Close()
    exit 1
}

Send-Command "MAIL FROM:<$fromEmail>"
Send-Command "RCPT TO:<$toEmail>"
Send-Command "DATA"

$writer.WriteLine("Subject: Test Email via SMTP OAuth")
$writer.WriteLine("From: $fromEmail")
$writer.WriteLine("To: $toEmail")
$writer.WriteLine("Date: $(Get-Date -Format 'ddd, dd MMM yyyy HH:mm:ss zzz')")
$writer.WriteLine("Content-Type: text/plain; charset=UTF-8")
$writer.WriteLine("")
$writer.WriteLine("This is a test email sent using SMTP with OAuth.")
Write-Host ">>> [EMAIL BODY]" -ForegroundColor Cyan

Send-Command "."
Send-Command "QUIT"

$tcpClient.Close()
Write-Host "Done!" -ForegroundColor Green
