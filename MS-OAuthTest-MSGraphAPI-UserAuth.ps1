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

# SIG # Begin signature block
# MIISGwYJKoZIhvcNAQcCoIISDDCCEggCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUUOrXp6dwXDF+IAfk7MBKVMND
# EBCggg54MIIG6DCCBNCgAwIBAgIQd70OBbdZC7YdR2FTHj917TANBgkqhkiG9w0B
# AQsFADBTMQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFsU2lnbiBudi1zYTEp
# MCcGA1UEAxMgR2xvYmFsU2lnbiBDb2RlIFNpZ25pbmcgUm9vdCBSNDUwHhcNMjAw
# NzI4MDAwMDAwWhcNMzAwNzI4MDAwMDAwWjBcMQswCQYDVQQGEwJCRTEZMBcGA1UE
# ChMQR2xvYmFsU2lnbiBudi1zYTEyMDAGA1UEAxMpR2xvYmFsU2lnbiBHQ0MgUjQ1
# IEVWIENvZGVTaWduaW5nIENBIDIwMjAwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAw
# ggIKAoICAQDLIO+XHrkBMkOgW6mKI/0gXq44EovKLNT/QdgaVdQZU7f9oxfnejlc
# wPfOEaP5pe0B+rW6k++vk9z44rMZTIOwSkRQBHiEEGqk1paQjoH4fKsvtaNXM9JY
# e5QObQ+lkSYqs4NPcrGKe2SS0PC0VV+WCxHlmrUsshHPJRt9USuYH0mjX/gTnjW4
# AwLapBMvhUrvxC9wDsHUzDMS7L1AldMRyubNswWcyFPrUtd4TFEBkoLeE/MHjnS6
# hICf0qQVDuiv6/eJ9t9x8NG+p7JBMyB1zLHV7R0HGcTrJnfyq20Xk0mpt+bDkJzG
# uOzMyXuaXsXFJJNjb34Qi2HPmFWjJKKINvL5n76TLrIGnybADAFWEuGyip8OHtyY
# iy7P2uKJNKYfJqCornht7KGIFTzC6u632K1hpa9wNqJ5jtwNc8Dx5CyrlOxYBjk2
# SNY7WugiznQOryzxFdrRtJXorNVJbeWv3ZtrYyBdjn47skPYYjqU5c20mLM3GSQS
# cnOrBLAJ3IXm1CIE70AqHS5tx2nTbrcBbA3gl6cW5iaLiPcDRIZfYmdMtac3qFXc
# AzaMbs9tNibxDo+wPXHA4TKnguS2MgIyMHy1k8gh/TyI5mlj+O51yYvCq++6Ov3p
# Xr+2EfG+8D3KMj5ufd4PfpuVxBKH5xq4Tu4swd+hZegkg8kqwv25UwIDAQABo4IB
# rTCCAakwDgYDVR0PAQH/BAQDAgGGMBMGA1UdJQQMMAoGCCsGAQUFBwMDMBIGA1Ud
# EwEB/wQIMAYBAf8CAQAwHQYDVR0OBBYEFCWd0PxZCYZjxezzsRM7VxwDkjYRMB8G
# A1UdIwQYMBaAFB8Av0aACvx4ObeltEPZVlC7zpY7MIGTBggrBgEFBQcBAQSBhjCB
# gzA5BggrBgEFBQcwAYYtaHR0cDovL29jc3AuZ2xvYmFsc2lnbi5jb20vY29kZXNp
# Z25pbmdyb290cjQ1MEYGCCsGAQUFBzAChjpodHRwOi8vc2VjdXJlLmdsb2JhbHNp
# Z24uY29tL2NhY2VydC9jb2Rlc2lnbmluZ3Jvb3RyNDUuY3J0MEEGA1UdHwQ6MDgw
# NqA0oDKGMGh0dHA6Ly9jcmwuZ2xvYmFsc2lnbi5jb20vY29kZXNpZ25pbmdyb290
# cjQ1LmNybDBVBgNVHSAETjBMMEEGCSsGAQQBoDIBAjA0MDIGCCsGAQUFBwIBFiZo
# dHRwczovL3d3dy5nbG9iYWxzaWduLmNvbS9yZXBvc2l0b3J5LzAHBgVngQwBAzAN
# BgkqhkiG9w0BAQsFAAOCAgEAJXWgCck5urehOYkvGJ+r1usdS+iUfA0HaJscne9x
# thdqawJPsz+GRYfMZZtM41gGAiJm1WECxWOP1KLxtl4lC3eW6c1xQDOIKezu86Jt
# vE21PgZLyXMzyggULT1M6LC6daZ0LaRYOmwTSfilFQoUloWxamg0JUKvllb0EPok
# ffErcsEW4Wvr5qmYxz5a9NAYnf10l4Z3Rio9I30oc4qu7ysbmr9sU6cUnjyHccBe
# jsj70yqSM+pXTV4HXsrBGKyBLRoh+m7Pl2F733F6Ospj99UwRDcy/rtDhdy6/KbK
# Mxkrd23bywXwfl91LqK2vzWqNmPJzmTZvfy8LPNJVgDIEivGJ7s3r1fvxM8eKcT0
# 4i3OKmHPV+31CkDi9RjWHumQL8rTh1+TikgaER3lN4WfLmZiml6BTpWsVVdD3FOL
# JX48YQ+KC7r1P6bXjvcEVl4hu5/XanGAv5becgPY2CIr8ycWTzjoUUAMrpLvvj19
# 94DGTDZXhJWnhBVIMA5SJwiNjqK9IscZyabKDqh6NttqumFfESSVpOKOaO4ZqUmZ
# XtC0NL3W+UDHEJcxUjk1KRGHJNPE+6ljy3dI1fpi/CTgBHpO0ORu3s6eOFAm9CFx
# ZdcJJdTJBwB6uMfzd+jF1OJV0NMe9n9S4kmNuRFyDIhEJjNmAUTf5DMOId5iiUgH
# 2vUwggeIMIIFcKADAgECAgw/RuE7RRJ1uSmNYaEwDQYJKoZIhvcNAQELBQAwXDEL
# MAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExMjAwBgNVBAMT
# KUdsb2JhbFNpZ24gR0NDIFI0NSBFViBDb2RlU2lnbmluZyBDQSAyMDIwMB4XDTIz
# MDgyNDAxNDAyMFoXDTI2MDgyNDAxNDAyMFowge0xHTAbBgNVBA8MFFByaXZhdGUg
# T3JnYW5pemF0aW9uMREwDwYDVQQFEwg2MzY3Mzg0NjETMBEGCysGAQQBgjc8AgED
# EwJVUzEZMBcGCysGAQQBgjc8AgECEwhJbGxpbm9pczELMAkGA1UEBhMCVVMxETAP
# BgNVBAgTCElsbGlub2lzMRAwDgYDVQQHEwdDaGljYWdvMSEwHwYDVQQJExgxNTAg
# UyBXYWNrZXIgRHIgU3RlIDI0MDAxGTAXBgNVBAoTEE5FVElLVVMuTkVUIExURC4x
# GTAXBgNVBAMTEE5FVElLVVMuTkVUIExURC4wggIiMA0GCSqGSIb3DQEBAQUAA4IC
# DwAwggIKAoICAQDGZCrBLmd4la7HQ+HY81iKJ2Wj/aa69Xd/kk/Vyjcylcv6gPJT
# QXeHAg4S16gFj+7lOY0Ss9v4yZ3jxqdac8LgzEDxXEV0f27x9z/IpXAOsIjIxNok
# X9qENN9UK6SSOvR11+WqRVal4yviAcGXkXw6ks+vxb4rsimgL5Hh+UWuj5N2Y79y
# GUro/gogIhyLhCzLWJKweYELrhZyONcH8ERVGbm24gnXSTgGpK5EdiTSWISUu/LZ
# md4UWAt6xSezEfajitFo2BjgxcymxN5tO3gPXT1GZo0IFfrOVpY6Wyz9RZPMHLNO
# inzNPcOwoxIs8s57uNcNlZz5lBFbhVbiricis07GUgLEWViSQDi8qp0RAwYutKnu
# aDS4b6cWr6BK3o5I133U+f6aw7kzp8jjAl9eqyr97U4xkdcnw73KwOrBBFc1ZksX
# UtqSgczV7fUsCQgWpVbWJfDVttG9IuuQmIqy4U+ibo5U4fmYRVrJQXt6YA1nQNTW
# 381Ld15A+0HUldtq6/7KXfj1daxSVUOX81/26gR7ruajN64yOZlq+AWEThUgyowx
# rJtpeOI+Y0qGVpZQnSWuVo1Hnjg1GsM1T56Z06lozFZo1kpsau41ByF85IWFIlBI
# Fn7QWdmu2pwD3iDHvL1r8R50khwsRJvfuJgcY6y3SAem1GL/hYUrdKaZ8wIDAQAB
# o4IBtjCCAbIwDgYDVR0PAQH/BAQDAgeAMIGfBggrBgEFBQcBAQSBkjCBjzBMBggr
# BgEFBQcwAoZAaHR0cDovL3NlY3VyZS5nbG9iYWxzaWduLmNvbS9jYWNlcnQvZ3Nn
# Y2NyNDVldmNvZGVzaWduY2EyMDIwLmNydDA/BggrBgEFBQcwAYYzaHR0cDovL29j
# c3AuZ2xvYmFsc2lnbi5jb20vZ3NnY2NyNDVldmNvZGVzaWduY2EyMDIwMFUGA1Ud
# IAROMEwwQQYJKwYBBAGgMgECMDQwMgYIKwYBBQUHAgEWJmh0dHBzOi8vd3d3Lmds
# b2JhbHNpZ24uY29tL3JlcG9zaXRvcnkvMAcGBWeBDAEDMAkGA1UdEwQCMAAwRwYD
# VR0fBEAwPjA8oDqgOIY2aHR0cDovL2NybC5nbG9iYWxzaWduLmNvbS9nc2djY3I0
# NWV2Y29kZXNpZ25jYTIwMjAuY3JsMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB8GA1Ud
# IwQYMBaAFCWd0PxZCYZjxezzsRM7VxwDkjYRMB0GA1UdDgQWBBR8MU/cehTUeI1C
# GA/8L+micJm9jzANBgkqhkiG9w0BAQsFAAOCAgEAOGcU5qtNq0RRS21ENaJszDn6
# 9KHAdjbOrfhPk3/VAhP5oTIpSUEkliGVSf25hNLj8gG7iAbC3XDQSoS6RMEXfkj9
# Pm/3AIGao4Lv6HKbD492nfVnmnT361pNQDOdD7orSXt10RnR9F7rkIaEKh0d0mNp
# IhxduFXpvZH1POTn3XSBp7XaZtGIKjvP7dfokG3Q7xYs0UMHdXO0IfFYdkYKlt2/
# lGg5JBgrrJ3xUG78FrfO16FFnm1ueFjBxkJvuE0efIsnD69FXtaWZiFIebWpWnHE
# THP6QTivmpBEkPQaHiPp2/8t7Zo1lIJxHVDOVoN5BKK5cEYssSKWGKucNxQPg88I
# L94Rk4mBZZ3NJG7WSNkxbEkDdBznF4Sluu6apqyVG14vqxXOSIFT+WaDOKlZiiJT
# xFswFTAQkoAjAIXgt8H7Ju0ApIlcZmh9by5/M794ADbvu0fTMpzDU6JtOXFlU7sV
# oNQ4C+NlxLM8tnh/XNbYBBMuvwXc0rYdkR4o0bzqRyCm/ZlSmOJuAS3XSfmeQaR6
# paTRrt/Radj1CCm5OYo+ghwvFncUiLe/hywDnksJ0QAdCM68/vq0t0xfRCovWiV5
# 88VskgzN5PgtKhOhSxc138290UeGTmlO8j9Yvx2FzmNz3R0oZiqsWmdvMaGiGsui
# opYmQo2X4N6vg3lYxRYxggMNMIIDCQIBATBsMFwxCzAJBgNVBAYTAkJFMRkwFwYD
# VQQKExBHbG9iYWxTaWduIG52LXNhMTIwMAYDVQQDEylHbG9iYWxTaWduIEdDQyBS
# NDUgRVYgQ29kZVNpZ25pbmcgQ0EgMjAyMAIMP0bhO0USdbkpjWGhMAkGBSsOAwIa
# BQCgeDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgor
# BgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3
# DQEJBDEWBBSg6M6lCLOtuxw3Oh5H3aGNGuHv7jANBgkqhkiG9w0BAQEFAASCAgDA
# I644ell28fzg1tpu7JdBTETORaC9MsmZzxvQrRxDi8fE7kQV3BM8DIBuLsE7q0Y/
# 5TvLBSnO8Ulx+ioJm7Xshp+JGNxJOCVQlW5c+6kYs9A94edr77JIuOgAMlYvGJ6i
# wNnSSEltlMiCQ92M8P/s8ZXFONfhGG5KJiBFaapyuMic7GfbihXusLkkqtdJpAax
# aQFU7r0lfvN1P9czBZQnmhvuF7N1Wwzs1LEb8pdeqti5HYlF4Vp9DayKorW/2r3l
# NRVmUwSF5eRGxYFUqbXFzfpzUHDK8wQKScdmjNii8dluwmispKuQ5JjSxHv4z8e/
# XU0tghLhXpABhuei9wWcESRDA2BxK7/vnYvuQ09oj20MkJgQF4iE9ooZsfKDRgGD
# xvZcE3USypwKaXrLbBJdW/w/h4gArxaRqRMNABao8qrXc2RC2efGLJZ7KttajJ3P
# YfGdLeBLiR/xYlC70rKGtTheGKtKYydrkto+1HE/q4VXvEOJCAEyptPrB6vIwerX
# hUMIuOnewOY9xP6mT0w8Cwk/4PVi/mFQAYamB2eGgewjvCYCfKgRQ4MOhiz52v/Q
# zmJlomsRy60XJ6nvQXtWlR8MDxHqZy+Gb2a4MR6TTP4rBkFS1XEs7fusQBn4bHDk
# OeYNAS9wkgYZ/midVkEVnIDhXbP/KlyDIU9tJmnPlg==
# SIG # End signature block
