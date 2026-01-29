<#
.SYNOPSIS
    Sends a test email using Microsoft 365 MS Graph API with OAuth authentication.

.DESCRIPTION
    This script obtains an OAuth access token using client credentials and sends a test email via MS Graph API.
    Useful for troubleshooting OAuth configuration issues by validating that the Tenant ID, Client ID, Client
    Secret, and sender email address are working correctly outside of the application.

.NOTES
    Author: Netikus.net
    Date: January 2026
    Version: 1.0
#>

# [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$tenantId     = "your-tenant-id"
$clientId     = "your-client-id"
$clientSecret = "your-client-secret"
$fromEmail    = "sender@yourdomain.com"
$toEmail      = "recipient@example.com"
# Port set to 81 specifically just in case something real is listening on port 80
$redirectUri  = "http://localhost:81"

$authUrl = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/authorize?" +
    "client_id=$clientId" +
    "&response_type=code" +
    "&redirect_uri=$redirectUri" +
    "&scope=https://graph.microsoft.com/Mail.Send offline_access" +
    "&response_mode=query"

Write-Host "Opening browser for authentication..." -ForegroundColor Yellow
Start-Process $authUrl

# Step 2: User pastes the full URL
$input = Read-Host "After login, paste the FULL URL from the browser address bar"

# Extract code - handles full URL or just the code
$code = $input.Trim()

if ($code -match "code=([^&#]+)") {
    $code = $matches[1]
    Write-Host "Code extracted from URL" -ForegroundColor Gray
} elseif ($code -match "^http") {
    Write-Host "ERROR: URL detected but could not extract code. Make sure the URL contains 'code=' parameter." -ForegroundColor Red
    exit 1
}

# Remove any trailing # or whitespace
$code = $code.TrimEnd('#').Trim()

if ($code.Length -lt 50) {
    Write-Host "ERROR: Code seems too short. Please paste the full URL." -ForegroundColor Red
    exit 1
}

Write-Host "Code: $($code.Substring(0,50))..." -ForegroundColor Gray

try {
    $token = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" -Method POST -Body @{
        grant_type    = "authorization_code"
        client_id     = $clientId
        client_secret = $clientSecret
        code          = $code
        redirect_uri  = $redirectUri
        scope         = "https://graph.microsoft.com/Mail.Send offline_access"
    }
    Write-Host "Token acquired successfully" -ForegroundColor Green
} catch {
    Write-Host "Failed to get token: $_" -ForegroundColor Red
    exit 1
}

# Step 4: Send email via Graph API
$body = @{
    message = @{
        subject = "Test Email via Graph API"
        body = @{ contentType = "Text"; content = "This is a test email sent using Microsoft Graph API with OAuth." }
        toRecipients = @(@{ emailAddress = @{ address = $toEmail } })
    }
} | ConvertTo-Json -Depth 10

try {
    Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/me/sendMail" -Method POST -Headers @{
        Authorization  = "Bearer $($token.access_token)"
        "Content-Type" = "application/json"
    } -Body $body
    Write-Host "Email sent successfully!" -ForegroundColor Green
} catch {
    Write-Host "Failed to send email: $_" -ForegroundColor Red
}
