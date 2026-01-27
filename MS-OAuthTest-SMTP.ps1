<#
.SYNOPSIS
    Powershell script to send SMTP emails using MS OAuth (o365/Azure/Exchange Online)

.DESCRIPTION
    This script obtains an OAuth access token using client credentials and sends a test email via SMTP. Useful for troubleshooting OAuth configuration
    issues by validating that the Tenant ID, Client ID, Client Secret, and sender email address are working correctly outside of the application.

.PARAMETER TenantId
    The Azure AD Tenant ID.

.PARAMETER ClientId
    The Application (Client) ID from Azure App Registration.

.EXAMPLE
    .\MS-OAuthTest-SMTP.ps1
    Sends a test email using the configured OAuth credentials.

.NOTES
    Author: EventSentry/Netikus
    Date: January 2026
    Version: 1.0
    Requires: PowerShell 5.1+

.LINK
    https://docs.microsoft.com/en-us/exchange/client-developer/legacy-protocols/how-to-authenticate-an-imap-pop-smtp-application-by-using-oauth
#>
 
# === Configuration ===
$tenantId     = "your-tenant-id"
$clientId     = "your-client-id"
$clientSecret = "your-client-secret"
$fromEmail    = "sender@yourdomain.com"
$toEmail      = "recipient@example.com"
# Normally you dont need to change this
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

# Connect and send via SMTP
$tcpClient = New-Object System.Net.Sockets.TcpClient($smtpServer, $smtpPort)
$stream = $tcpClient.GetStream()
$reader = New-Object System.IO.StreamReader($stream)
$writer = New-Object System.IO.StreamWriter($stream)
$writer.AutoFlush = $true

function Read-Response { 
    Start-Sleep -Milliseconds 500
    while ($stream.DataAvailable) { Write-Host $reader.ReadLine() -ForegroundColor Gray }
}

function Send-Command($cmd, $mask = $false) { 
    if ($mask) { Write-Host ">>> [AUTH DATA HIDDEN]" -ForegroundColor Cyan }
    else { Write-Host ">>> $cmd" -ForegroundColor Cyan }
    $writer.WriteLine($cmd)
    Read-Response
}

Read-Response
Send-Command "EHLO localhost"
Send-Command "STARTTLS"

# Upgrade to TLS
$sslStream = New-Object System.Net.Security.SslStream($stream, $false)
$sslStream.AuthenticateAsClient($smtpServer)
$reader = New-Object System.IO.StreamReader($sslStream)
$writer = New-Object System.IO.StreamWriter($sslStream)
$writer.AutoFlush = $true

Send-Command "EHLO localhost"
Send-Command "AUTH XOAUTH2 $authBase64" $true
Send-Command "MAIL FROM:<$fromEmail>"
Send-Command "RCPT TO:<$toEmail>"
Send-Command "DATA"
$writer.WriteLine("Subject: Test Email via SMTP OAuth")
$writer.WriteLine("From: $fromEmail")
$writer.WriteLine("To: $toEmail")
$writer.WriteLine("")
$writer.WriteLine("This is a test email sent using SMTP with OAuth.")
Send-Command "."
Send-Command "QUIT"

$tcpClient.Close()

Write-Host "Done!" -ForegroundColor Green
