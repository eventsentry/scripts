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
# MIIuJwYJKoZIhvcNAQcCoIIuGDCCLhQCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCXzjkv7HhZibYn
# EOIXmBOOG/pJDuMfiTbO30EohgxLIKCCJzUwggWNMIIEdaADAgECAhAOmxiO+dAt
# 5+/bUOIIQBhaMA0GCSqGSIb3DQEBDAUAMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQK
# EwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJDAiBgNV
# BAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0yMjA4MDEwMDAwMDBa
# Fw0zMTExMDkyMzU5NTlaMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2Vy
# dCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lD
# ZXJ0IFRydXN0ZWQgUm9vdCBHNDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoC
# ggIBAL/mkHNo3rvkXUo8MCIwaTPswqclLskhPfKK2FnC4SmnPVirdprNrnsbhA3E
# MB/zG6Q4FutWxpdtHauyefLKEdLkX9YFPFIPUh/GnhWlfr6fqVcWWVVyr2iTcMKy
# unWZanMylNEQRBAu34LzB4TmdDttceItDBvuINXJIB1jKS3O7F5OyJP4IWGbNOsF
# xl7sWxq868nPzaw0QF+xembud8hIqGZXV59UWI4MK7dPpzDZVu7Ke13jrclPXuU1
# 5zHL2pNe3I6PgNq2kZhAkHnDeMe2scS1ahg4AxCN2NQ3pC4FfYj1gj4QkXCrVYJB
# MtfbBHMqbpEBfCFM1LyuGwN1XXhm2ToxRJozQL8I11pJpMLmqaBn3aQnvKFPObUR
# WBf3JFxGj2T3wWmIdph2PVldQnaHiZdpekjw4KISG2aadMreSx7nDmOu5tTvkpI6
# nj3cAORFJYm2mkQZK37AlLTSYW3rM9nF30sEAMx9HJXDj/chsrIRt7t/8tWMcCxB
# YKqxYxhElRp2Yn72gLD76GSmM9GJB+G9t+ZDpBi4pncB4Q+UDCEdslQpJYls5Q5S
# UUd0viastkF13nqsX40/ybzTQRESW+UQUOsxxcpyFiIJ33xMdT9j7CFfxCBRa2+x
# q4aLT8LWRV+dIPyhHsXAj6KxfgommfXkaS+YHS312amyHeUbAgMBAAGjggE6MIIB
# NjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBTs1+OC0nFdZEzfLmc/57qYrhwP
# TzAfBgNVHSMEGDAWgBRF66Kv9JLLgjEtUYunpyGd823IDzAOBgNVHQ8BAf8EBAMC
# AYYweQYIKwYBBQUHAQEEbTBrMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdp
# Y2VydC5jb20wQwYIKwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNv
# bS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcnQwRQYDVR0fBD4wPDA6oDigNoY0
# aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENB
# LmNybDARBgNVHSAECjAIMAYGBFUdIAAwDQYJKoZIhvcNAQEMBQADggEBAHCgv0Nc
# Vec4X6CjdBs9thbX979XB72arKGHLOyFXqkauyL4hxppVCLtpIh3bb0aFPQTSnov
# Lbc47/T/gLn4offyct4kvFIDyE7QKt76LVbP+fT3rDB6mouyXtTP0UNEm0Mh65Zy
# oUi0mcudT6cGAxN3J0TU53/oWajwvy8LpunyNDzs9wPHh6jSTEAZNUZqaVSwuKFW
# juyk1T3osdz9HNj0d1pcVIxv76FQPfx2CWiEn2/K2yCNNWAcAgPLILCsWKAOQGPF
# mCLBsln1VWvPJ6tsds5vIy30fnFqI2si/xK4VC0nftg62fC2h5b9W9FcrBjDTZ9z
# twGpn1eqXijiuZQwggWiMIIEiqADAgECAhB4AxhCRXCKQc9vAbjutKlUMA0GCSqG
# SIb3DQEBDAUAMEwxIDAeBgNVBAsTF0dsb2JhbFNpZ24gUm9vdCBDQSAtIFIzMRMw
# EQYDVQQKEwpHbG9iYWxTaWduMRMwEQYDVQQDEwpHbG9iYWxTaWduMB4XDTIwMDcy
# ODAwMDAwMFoXDTI5MDMxODAwMDAwMFowUzELMAkGA1UEBhMCQkUxGTAXBgNVBAoT
# EEdsb2JhbFNpZ24gbnYtc2ExKTAnBgNVBAMTIEdsb2JhbFNpZ24gQ29kZSBTaWdu
# aW5nIFJvb3QgUjQ1MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAti3F
# MN166KuQPQNysDpLmRZhsuX/pWcdNxzlfuyTg6qE9aNDm5hFirhjV12bAIgEJen4
# aJJLgthLyUoD86h/ao+KYSe9oUTQ/fU/IsKjT5GNswWyKIKRXftZiAULlwbCmPgs
# pzMk7lA6QczwoLB7HU3SqFg4lunf+RuRu4sQLNLHQx2iCXShgK975jMKDFlrjrz0
# q1qXe3+uVfuE8ID+hEzX4rq9xHWhb71hEHREspgH4nSr/2jcbCY+6R/l4ASHrTDT
# DI0DfFW4FnBcJHggJetnZ4iruk40mGtwEd44ytS+ocCc4d8eAgHYO+FnQ4S2z/x0
# ty+Eo7+6CTc9Z2yxRVwZYatBg/WsHet3DUZHc86/vZWV7Z0riBD++ljop1fhs8+o
# WukHJZsSxJ6Acj2T3IyU3ztE5iaA/NLDA/CMDNJF1i7nj5ie5gTuQm5nfkIWcWLn
# BPlgxmShtpyBIU4rxm1olIbGmXRzZzF6kfLUjHlufKa7fkZvTcWFEivPmiJECKiF
# N84HYVcGFxIkwMQxc6GYNVdHfhA6RdktpFGQmKmgBzfEZRqqHGsWd/enl+w/GTCZ
# bzH76kCy59LE+snQ8FB2dFn6jW0XMr746X4D9OeHdZrUSpEshQMTAitCgPKJajbP
# yEygzp74y42tFqfT3tWbGKfGkjrxgmPxLg4kZN8CAwEAAaOCAXcwggFzMA4GA1Ud
# DwEB/wQEAwIBhjATBgNVHSUEDDAKBggrBgEFBQcDAzAPBgNVHRMBAf8EBTADAQH/
# MB0GA1UdDgQWBBQfAL9GgAr8eDm3pbRD2VZQu86WOzAfBgNVHSMEGDAWgBSP8Et/
# qC5FJK5NUPpjmove4t0bvDB6BggrBgEFBQcBAQRuMGwwLQYIKwYBBQUHMAGGIWh0
# dHA6Ly9vY3NwLmdsb2JhbHNpZ24uY29tL3Jvb3RyMzA7BggrBgEFBQcwAoYvaHR0
# cDovL3NlY3VyZS5nbG9iYWxzaWduLmNvbS9jYWNlcnQvcm9vdC1yMy5jcnQwNgYD
# VR0fBC8wLTAroCmgJ4YlaHR0cDovL2NybC5nbG9iYWxzaWduLmNvbS9yb290LXIz
# LmNybDBHBgNVHSAEQDA+MDwGBFUdIAAwNDAyBggrBgEFBQcCARYmaHR0cHM6Ly93
# d3cuZ2xvYmFsc2lnbi5jb20vcmVwb3NpdG9yeS8wDQYJKoZIhvcNAQEMBQADggEB
# AKz3zBWLMHmoHQsoiBkJ1xx//oa9e1ozbg1nDnti2eEYXLC9E10dI645UHY3qkT9
# XwEjWYZWTMytvGQTFDCkIKjgP+icctx+89gMI7qoLao89uyfhzEHZfU5p1GCdeHy
# L5f20eFlloNk/qEdUfu1JJv10ndpvIUsXPpYd9Gup7EL4tZ3u6m0NEqpbz308w2V
# Xeb5ekWwJRcxLtv3D2jmgx+p9+XUnZiM02FLL8Mofnrekw60faAKbZLEtGY/fadY
# 7qz37MMIAas4/AocqcWXsojICQIZ9lyaGvFNbDDUswarAGBIDXirzxetkpNiIHd1
# bL3IMrTcTevZ38GQlim9wX8wgga0MIIEnKADAgECAhANx6xXBf8hmS5AQyIMOkmG
# MA0GCSqGSIb3DQEBCwUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2Vy
# dCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lD
# ZXJ0IFRydXN0ZWQgUm9vdCBHNDAeFw0yNTA1MDcwMDAwMDBaFw0zODAxMTQyMzU5
# NTlaMGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjFBMD8G
# A1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBUaW1lU3RhbXBpbmcgUlNBNDA5NiBT
# SEEyNTYgMjAyNSBDQTEwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC0
# eDHTCphBcr48RsAcrHXbo0ZodLRRF51NrY0NlLWZloMsVO1DahGPNRcybEKq+Ruw
# OnPhof6pvF4uGjwjqNjfEvUi6wuim5bap+0lgloM2zX4kftn5B1IpYzTqpyFQ/4B
# t0mAxAHeHYNnQxqXmRinvuNgxVBdJkf77S2uPoCj7GH8BLuxBG5AvftBdsOECS1U
# kxBvMgEdgkFiDNYiOTx4OtiFcMSkqTtF2hfQz3zQSku2Ws3IfDReb6e3mmdglTca
# arps0wjUjsZvkgFkriK9tUKJm/s80FiocSk1VYLZlDwFt+cVFBURJg6zMUjZa/zb
# CclF83bRVFLeGkuAhHiGPMvSGmhgaTzVyhYn4p0+8y9oHRaQT/aofEnS5xLrfxnG
# pTXiUOeSLsJygoLPp66bkDX1ZlAeSpQl92QOMeRxykvq6gbylsXQskBBBnGy3tW/
# AMOMCZIVNSaz7BX8VtYGqLt9MmeOreGPRdtBx3yGOP+rx3rKWDEJlIqLXvJWnY0v
# 5ydPpOjL6s36czwzsucuoKs7Yk/ehb//Wx+5kMqIMRvUBDx6z1ev+7psNOdgJMoi
# wOrUG2ZdSoQbU2rMkpLiQ6bGRinZbI4OLu9BMIFm1UUl9VnePs6BaaeEWvjJSjNm
# 2qA+sdFUeEY0qVjPKOWug/G6X5uAiynM7Bu2ayBjUwIDAQABo4IBXTCCAVkwEgYD
# VR0TAQH/BAgwBgEB/wIBADAdBgNVHQ4EFgQU729TSunkBnx6yuKQVvYv1Ensy04w
# HwYDVR0jBBgwFoAU7NfjgtJxXWRM3y5nP+e6mK4cD08wDgYDVR0PAQH/BAQDAgGG
# MBMGA1UdJQQMMAoGCCsGAQUFBwMIMHcGCCsGAQUFBwEBBGswaTAkBggrBgEFBQcw
# AYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEEGCCsGAQUFBzAChjVodHRwOi8v
# Y2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNydDBD
# BgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNl
# cnRUcnVzdGVkUm9vdEc0LmNybDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgB
# hv1sBwEwDQYJKoZIhvcNAQELBQADggIBABfO+xaAHP4HPRF2cTC9vgvItTSmf83Q
# h8WIGjB/T8ObXAZz8OjuhUxjaaFdleMM0lBryPTQM2qEJPe36zwbSI/mS83afsl3
# YTj+IQhQE7jU/kXjjytJgnn0hvrV6hqWGd3rLAUt6vJy9lMDPjTLxLgXf9r5nWMQ
# wr8Myb9rEVKChHyfpzee5kH0F8HABBgr0UdqirZ7bowe9Vj2AIMD8liyrukZ2iA/
# wdG2th9y1IsA0QF8dTXqvcnTmpfeQh35k5zOCPmSNq1UH410ANVko43+Cdmu4y81
# hjajV/gxdEkMx1NKU4uHQcKfZxAvBAKqMVuqte69M9J6A47OvgRaPs+2ykgcGV00
# TYr2Lr3ty9qIijanrUR3anzEwlvzZiiyfTPjLbnFRsjsYg39OlV8cipDoq7+qNNj
# qFzeGxcytL5TTLL4ZaoBdqbhOhZ3ZRDUphPvSRmMThi0vw9vODRzW6AxnJll38F0
# cuJG7uEBYTptMSbhdhGQDpOXgpIUsWTjd6xpR6oaQf/DJbg3s6KCLPAlZ66RzIg9
# sC+NJpud/v4+7RWsWCiKi9EOLLHfMR2ZyJ/+xhCx9yHbxtl5TPau1j/1MIDpMPx0
# LckTetiSuEtQvLsNz3Qbp7wGWqbIiOWCnb5WqxL3/BAPvIXKUjPSxyZsq8WhbaM2
# tszWkPZPubdcMIIG6DCCBNCgAwIBAgIQd70OBbdZC7YdR2FTHj917TANBgkqhkiG
# 9w0BAQsFADBTMQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFsU2lnbiBudi1z
# YTEpMCcGA1UEAxMgR2xvYmFsU2lnbiBDb2RlIFNpZ25pbmcgUm9vdCBSNDUwHhcN
# MjAwNzI4MDAwMDAwWhcNMzAwNzI4MDAwMDAwWjBcMQswCQYDVQQGEwJCRTEZMBcG
# A1UEChMQR2xvYmFsU2lnbiBudi1zYTEyMDAGA1UEAxMpR2xvYmFsU2lnbiBHQ0Mg
# UjQ1IEVWIENvZGVTaWduaW5nIENBIDIwMjAwggIiMA0GCSqGSIb3DQEBAQUAA4IC
# DwAwggIKAoICAQDLIO+XHrkBMkOgW6mKI/0gXq44EovKLNT/QdgaVdQZU7f9oxfn
# ejlcwPfOEaP5pe0B+rW6k++vk9z44rMZTIOwSkRQBHiEEGqk1paQjoH4fKsvtaNX
# M9JYe5QObQ+lkSYqs4NPcrGKe2SS0PC0VV+WCxHlmrUsshHPJRt9USuYH0mjX/gT
# njW4AwLapBMvhUrvxC9wDsHUzDMS7L1AldMRyubNswWcyFPrUtd4TFEBkoLeE/MH
# jnS6hICf0qQVDuiv6/eJ9t9x8NG+p7JBMyB1zLHV7R0HGcTrJnfyq20Xk0mpt+bD
# kJzGuOzMyXuaXsXFJJNjb34Qi2HPmFWjJKKINvL5n76TLrIGnybADAFWEuGyip8O
# HtyYiy7P2uKJNKYfJqCornht7KGIFTzC6u632K1hpa9wNqJ5jtwNc8Dx5CyrlOxY
# Bjk2SNY7WugiznQOryzxFdrRtJXorNVJbeWv3ZtrYyBdjn47skPYYjqU5c20mLM3
# GSQScnOrBLAJ3IXm1CIE70AqHS5tx2nTbrcBbA3gl6cW5iaLiPcDRIZfYmdMtac3
# qFXcAzaMbs9tNibxDo+wPXHA4TKnguS2MgIyMHy1k8gh/TyI5mlj+O51yYvCq++6
# Ov3pXr+2EfG+8D3KMj5ufd4PfpuVxBKH5xq4Tu4swd+hZegkg8kqwv25UwIDAQAB
# o4IBrTCCAakwDgYDVR0PAQH/BAQDAgGGMBMGA1UdJQQMMAoGCCsGAQUFBwMDMBIG
# A1UdEwEB/wQIMAYBAf8CAQAwHQYDVR0OBBYEFCWd0PxZCYZjxezzsRM7VxwDkjYR
# MB8GA1UdIwQYMBaAFB8Av0aACvx4ObeltEPZVlC7zpY7MIGTBggrBgEFBQcBAQSB
# hjCBgzA5BggrBgEFBQcwAYYtaHR0cDovL29jc3AuZ2xvYmFsc2lnbi5jb20vY29k
# ZXNpZ25pbmdyb290cjQ1MEYGCCsGAQUFBzAChjpodHRwOi8vc2VjdXJlLmdsb2Jh
# bHNpZ24uY29tL2NhY2VydC9jb2Rlc2lnbmluZ3Jvb3RyNDUuY3J0MEEGA1UdHwQ6
# MDgwNqA0oDKGMGh0dHA6Ly9jcmwuZ2xvYmFsc2lnbi5jb20vY29kZXNpZ25pbmdy
# b290cjQ1LmNybDBVBgNVHSAETjBMMEEGCSsGAQQBoDIBAjA0MDIGCCsGAQUFBwIB
# FiZodHRwczovL3d3dy5nbG9iYWxzaWduLmNvbS9yZXBvc2l0b3J5LzAHBgVngQwB
# AzANBgkqhkiG9w0BAQsFAAOCAgEAJXWgCck5urehOYkvGJ+r1usdS+iUfA0HaJsc
# ne9xthdqawJPsz+GRYfMZZtM41gGAiJm1WECxWOP1KLxtl4lC3eW6c1xQDOIKezu
# 86JtvE21PgZLyXMzyggULT1M6LC6daZ0LaRYOmwTSfilFQoUloWxamg0JUKvllb0
# EPokffErcsEW4Wvr5qmYxz5a9NAYnf10l4Z3Rio9I30oc4qu7ysbmr9sU6cUnjyH
# ccBejsj70yqSM+pXTV4HXsrBGKyBLRoh+m7Pl2F733F6Ospj99UwRDcy/rtDhdy6
# /KbKMxkrd23bywXwfl91LqK2vzWqNmPJzmTZvfy8LPNJVgDIEivGJ7s3r1fvxM8e
# KcT04i3OKmHPV+31CkDi9RjWHumQL8rTh1+TikgaER3lN4WfLmZiml6BTpWsVVdD
# 3FOLJX48YQ+KC7r1P6bXjvcEVl4hu5/XanGAv5becgPY2CIr8ycWTzjoUUAMrpLv
# vj1994DGTDZXhJWnhBVIMA5SJwiNjqK9IscZyabKDqh6NttqumFfESSVpOKOaO4Z
# qUmZXtC0NL3W+UDHEJcxUjk1KRGHJNPE+6ljy3dI1fpi/CTgBHpO0ORu3s6eOFAm
# 9CFxZdcJJdTJBwB6uMfzd+jF1OJV0NMe9n9S4kmNuRFyDIhEJjNmAUTf5DMOId5i
# iUgH2vUwggbtMIIE1aADAgECAhAIT9wzT35FTtvDD4/5khg1MA0GCSqGSIb3DQEB
# CwUAMGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjFBMD8G
# A1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBUaW1lU3RhbXBpbmcgUlNBNDA5NiBT
# SEEyNTYgMjAyNSBDQTEwHhcNMjYwODA1MDAwMDAwWhcNMzcxMTA0MjM1OTU5WjBj
# MQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMT
# MkRpZ2lDZXJ0IFNIQTI1NiBSU0E0MDk2IFRpbWVzdGFtcCBSZXNwb25kZXIgMjAy
# NiAxMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAtnum8sn+zUr41JtM
# ZbP9OMYw+HwJDpG5xkIu/lqcfNYmMX81YmsUiHLbh9ykpeWBGKTLhYBrAN9Tdg/Q
# EzG32XcObmgIblnr0CoQ3WSAeDZ6nH6X6VkFyYkJw3QBJREwvm4UhLzSxmwPA7cF
# KRTEOMsmEEj6qJk/dqLEAL+oQYuOwE2UuiX1Vnul8YReIyWd4kgLn9gq6LNXM0Up
# lkR6jL/QHxmb6fMoGBJYbnaUI7XD6cKDpekK2SVMld4iDbzeHDtOaaxldH5IxuNu
# sQ69nd8/ZXEiB5Hbxj3RlK13cX1W4DlFXKdv/CEhM8Cj1vvlmvhNroyPdRGbbpBl
# gyf8Wdu5N6ByhFwURn0U6ozlPoxN22v+fviUhP+6DR547OZnpBMWDfei1f5sVGwi
# iW/KQTWOK97g+4RJpPzPNV4VYMAwO2jM2Aty2QYPVmOQTJm0msuXnJrSbl2gf9Jy
# lpkJlWXqk1Q4LJsxz+TELoQCZIljbgvTJgoPU2R12ydv8i1UqL/adelA0y7U9Pmm
# tbze9Xx3rtajC5SzQd1jgfwAwsa90v9YcSPdmeoyoBBA/27cCL237l5DTYYPDLQ4
# ON3OLTGWnvRb6jDrf/T75gMRfUzSLCBQfBusm9+mSWRlC/Df6S/e9Q8i13CuhzOT
# 2Jx+V/nlbXM4QoBwlUAhelwwJT0CAwEAAaOCAZUwggGRMAwGA1UdEwEB/wQCMAAw
# HQYDVR0OBBYEFBTJY4owLtRK+26U8+bjQH717M3iMB8GA1UdIwQYMBaAFO9vU0rp
# 5AZ8esrikFb2L9RJ7MtOMA4GA1UdDwEB/wQEAwIHgDAWBgNVHSUBAf8EDDAKBggr
# BgEFBQcDCDCBlQYIKwYBBQUHAQEEgYgwgYUwJAYIKwYBBQUHMAGGGGh0dHA6Ly9v
# Y3NwLmRpZ2ljZXJ0LmNvbTBdBggrBgEFBQcwAoZRaHR0cDovL2NhY2VydHMuZGln
# aWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZEc0VGltZVN0YW1waW5nUlNBNDA5NlNI
# QTI1NjIwMjVDQTEuY3J0MF8GA1UdHwRYMFYwVKBSoFCGTmh0dHA6Ly9jcmwzLmRp
# Z2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFRpbWVTdGFtcGluZ1JTQTQwOTZT
# SEEyNTYyMDI1Q0ExLmNybDAgBgNVHSAEGTAXMAgGBmeBDAEEAjALBglghkgBhv1s
# BwEwDQYJKoZIhvcNAQELBQADggIBAI3FOmEenVIK35msCYB+fShAsWvSYvLBItoN
# dAgQ2jIqrGsVsluXMJU/+mRebBc52s6lbKAvOVPXaizmKkMLLflEEKDZQx4CkS2t
# 8aHPjkXha3hYZ010htFa3dhNgmalH5vuWvh3tTCf4frTS7gPtGc4Z/xaPhQ2AB1m
# R8eEe/WbH0RWHvVIl6VwQ3+g5FKNfN2N/DWJkf13w2H+2GfqEfbd35Ww8CvoYBjL
# NIDTadcPWdgsjsiOaK/7EsKJgLjUNIVgvcaFOLLQ/GlrA+0ZHJoFUbOr5SJN8zyk
# PspXIXlpDJY/gqFUZRROeab9GVgmhbdOJcD/63RhxPahFUGbckRONqMe6DYAv6/m
# OG0pWd3cPStsdcS7buj5DyniwRY8yooMH6ptx5vpP/pZzBPBeZD2U4IsthyxB5Ja
# a8qrOkB5z160TXiM5ADMspZ0TfD9MJoq0tFpFPssKRFhWeEDYPvcUuN7U7lvcdHl
# 4ezQ3NT/7Ffs1sR1yh/LRbdZ3B3Vc6q2WmD8mDC0p9kzl2o73iVtS946IkEj7FkR
# sZGww1teYxERROC745xrtjvcw9ZyyUjHZWGRIpJeMNsPquCDf0fkyHtB+J4AiNZq
# CQk23rxh+KbpyMTNVKItJ5l92Svl20U9NbqMBOVYl1h54NEYLJq1/xHWFKPNK903
# zJZA9P2DMIIHZTCCBU2gAwIBAgIMFa+pm870J384wmw2MA0GCSqGSIb3DQEBCwUA
# MFwxCzAJBgNVBAYTAkJFMRkwFwYDVQQKExBHbG9iYWxTaWduIG52LXNhMTIwMAYD
# VQQDEylHbG9iYWxTaWduIEdDQyBSNDUgRVYgQ29kZVNpZ25pbmcgQ0EgMjAyMDAe
# Fw0yNjA4MjIxODM2MTBaFw0yNzA5MjQwMTQwMjBaMIHKMR0wGwYDVQQPDBRQcml2
# YXRlIE9yZ2FuaXphdGlvbjERMA8GA1UEBRMINjM2NzM4NDYxEzARBgsrBgEEAYI3
# PAIBAxMCVVMxGTAXBgsrBgEEAYI3PAIBAhMISWxsaW5vaXMxCzAJBgNVBAYTAlVT
# MREwDwYDVQQIEwhJbGxpbm9pczEQMA4GA1UEBxMHQ2hpY2FnbzEZMBcGA1UEChMQ
# TkVUSUtVUy5ORVQgTFRELjEZMBcGA1UEAxMQTkVUSUtVUy5ORVQgTFRELjCCAiIw
# DQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBALZYk7lqiKNbrFH6fndsVJfKuaz8
# 5pJMIOKzeh615BTU0CiuUQ8D6G0iZBOmY7Kx/QdG2QXGYqs1//GE6ASPClZzh3zX
# jfI26KENP62Yk7i+iZBKvlALal5ZVCzVL+zszL9XVL09o4B2LRtJMjXZuIIK+WJX
# /3GjJ2GSk6Vm04oyh9Hm89EP9KZm7r5FqYdmStyHbeMeyPMhslFe/eburb44CQPi
# Qj0oPiq79obTDT7pgooV8zLvKtFRN9+mwM0YPHiRzJkjF5KVVWUL+cgrwuznQK5S
# 6CWPCwR1CA2+OkyzybeQQ0DMrV3N5WeZtT5aUveY0PC1yr9JAZF1ANNh18qY9ElQ
# Z2QKvaY47Y3GFjkCS0ZZdJQ6UX7pM/tYlQ9pDCGKyq7cZ6re5ppDKiCRw3W1zOoR
# 68zufwmVsNmB9iaAbxJRQPO0JkUgZ1cfgVRzYXNfuowtc9W/JwzbGcbxdsiZr8a/
# 58WD9yjJhsCn5/T7de99YP+Z+iGxDU8Lg8fg+o4G4H3N0cyXcUiJb6R+P5hcpll5
# eRMLY3ZiIjCVSv9tpV4VlatZamc80hZPAhONZOvyrGl+8IYg5ZWBWqL0fS4ujkv4
# sheumGZx6JvPx1Y0FVe9hwDQwR8gOKIrsCx3UUhZbji8V80DP7DhEVmfEKCXA362
# 3yrGeysRQE71UOB9AgMBAAGjggG2MIIBsjAOBgNVHQ8BAf8EBAMCB4AwgZ8GCCsG
# AQUFBwEBBIGSMIGPMEwGCCsGAQUFBzAChkBodHRwOi8vc2VjdXJlLmdsb2JhbHNp
# Z24uY29tL2NhY2VydC9nc2djY3I0NWV2Y29kZXNpZ25jYTIwMjAuY3J0MD8GCCsG
# AQUFBzABhjNodHRwOi8vb2NzcC5nbG9iYWxzaWduLmNvbS9nc2djY3I0NWV2Y29k
# ZXNpZ25jYTIwMjAwVQYDVR0gBE4wTDBBBgkrBgEEAaAyAQIwNDAyBggrBgEFBQcC
# ARYmaHR0cHM6Ly93d3cuZ2xvYmFsc2lnbi5jb20vcmVwb3NpdG9yeS8wBwYFZ4EM
# AQMwCQYDVR0TBAIwADBHBgNVHR8EQDA+MDygOqA4hjZodHRwOi8vY3JsLmdsb2Jh
# bHNpZ24uY29tL2dzZ2NjcjQ1ZXZjb2Rlc2lnbmNhMjAyMC5jcmwwEwYDVR0lBAww
# CgYIKwYBBQUHAwMwHwYDVR0jBBgwFoAUJZ3Q/FkJhmPF7POxEztXHAOSNhEwHQYD
# VR0OBBYEFPKTFRLarNKBfF3LUP+3BzCnUokKMA0GCSqGSIb3DQEBCwUAA4ICAQC2
# 7tcoXAj16U21mRh+ouVYVl/QLRjLOvp+VPU3PXbRZsGWnGA+cYfiemgQvDsBFx7h
# uSyBiFXuTxj6IAOM5+YqPQySIJGmIuZtZzpyF6QQ2Q9ybHLhx1fOYxHSzCEcvWJf
# gPM1VGC1MqBO0AAIrKJASyIg9mGbnOFv48pm32Lr7kpiZuRKBP94st51evHkKLSP
# MykzqJi7hNy62K4Wzn/6ZdUVJfprGdlxPxdKeB5piZzdyG9pVcGBD5aPa3/LrcDr
# k6W7iTDhVBUuIzV1lj9I/qaJ6MkQes29Ek328CeOXwCPMI+oB756FSSPDF73VQyF
# oiMqpOy2DMuRbrZML34QDDZ5kiJMEBSQrk88Ua4VN/BEU5pwkR/ut++GgRaEeXbE
# tqGkIuEAIE8W2ESvxZqI+uPAiN2D4FeBMCjlzdZoXdJWesfwsZZ6fa92x9WJ5lBn
# k53TJdUg8ESpvXum47nhbrncFpJ/K6zT7wFUxcN4knSujcD5j8XbPPO3MjRkKyVr
# EJ+M3zOScEUs6afj9se6mES3HZuGx1SQl9m0hDrsFt4J+cEO6Zza5JOdE2X7ipMT
# szSOKUGuFDDbt4T1fcbF71joJO9jQ2qoSV9cpXVuqQv2yYrrm59njQdpWLo9ytMN
# mFLT4IVIoV6pbLkhEWeIN6EMFY1Z35oJNjmY3h1FBjGCBkgwggZEAgEBMGwwXDEL
# MAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExMjAwBgNVBAMT
# KUdsb2JhbFNpZ24gR0NDIFI0NSBFViBDb2RlU2lnbmluZyBDQSAyMDIwAgwVr6mb
# zvQnfzjCbDYwDQYJYIZIAWUDBAIBBQCggYQwGAYKKwYBBAGCNwIBDDEKMAigAoAA
# oQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4w
# DAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQg835QzwdAhzPgE1XqrQ7FO0mr
# cow6aUIsFYhdKNAMJGUwDQYJKoZIhvcNAQEBBQAEggIAN8h61uZwXITZ7UksZ3Bn
# OvkBLwqHPUPbhkD/bDPDa8rn+arXAuyEliW+LtAnTQARycSOcOBp7aygdwnV934B
# M7FmOsqrns854o5LeGPUOhQLVCcLAGFC6TZ1N38yD+EZWKbAaVHH4R6G1L/e8AZ5
# O0ySe/7Us/xO4JqPAs3r+4qywcs1lQBaqYJZssg800MMKb4AA+Dx3BVjltyFYbsy
# JuzbsC9r0OBgitWP4sktIHLF9zgKWKQGhNzxxAAYCxk6LLwVHK/4oFFjEvpSM0wF
# mkYDOXOeAfZZHtXHPEGrT2I+j074HJNYPAB5erJzTyA1xkqNPL9wDYHPF6jHs1Gr
# 83KiwSXekft+XpHu6Dlelee1cDuoEyID3Dr70FstNnMsgnxzF5nGOEJYJl/W5prx
# c9bUZRADr6qPd5cT5+UyAJ1BjeVhOHLsjYn5UrDLFbyYxev3C4WRCSSAqy/XGeTc
# VL1LJVqmvCQKrVNpHiKVBBVLYhUHrXLOBI/zqzzZYk77Fg20q9nhqQxDe5PUVh6X
# aLn94jRXXZWrkSBkPtjc343CGr/ni5Uwcr99rhMv+yodqc+kX0H/Rqqp1QO9Bql9
# +diteXuH9kMt/PPEUTp+xMZSpRUujdS5AhvyuN+PZN2Bv9MeDIawBfp4FxEsSw0N
# 0WqZGYM4Ns0EleptDdfjyl6hggMmMIIDIgYJKoZIhvcNAQkGMYIDEzCCAw8CAQEw
# fTBpMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xQTA/BgNV
# BAMTOERpZ2lDZXJ0IFRydXN0ZWQgRzQgVGltZVN0YW1waW5nIFJTQTQwOTYgU0hB
# MjU2IDIwMjUgQ0ExAhAIT9wzT35FTtvDD4/5khg1MA0GCWCGSAFlAwQCAQUAoGkw
# GAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMjYxMDIx
# MTU1NzQwWjAvBgkqhkiG9w0BCQQxIgQgtbp3tPQCKaFVqhA5g2oE87HbcjtmnfgO
# 2e8y57V2TA4wDQYJKoZIhvcNAQEBBQAEggIAgBCUoxkmywJ9ojmlwqGGe+XGd00e
# Z9xOscFflY79316XAhuxj7kauEmYDVmAdZu/JK+LN2uCoKeVmSmhv1k7+ZE2yvk3
# GsM9dJl7arU6F1/Vua+/jFw3XwtSdqRB9hPtahJVJ1l6EzRRK31e0AQc8OLP6KVK
# kPq9c012odLVt9GTaDgT0Iy40YFE34qQRlCow5okqdZeD0sYnNpsRF24lyA3yUNB
# WBNJc0ltaxqQ6Grom6ImpzDEKZgmsasYTKr5uo79fEAKzoW8V61kSDCQJx6xu25y
# 9kjxzbQU0yzFRFb0KqM6Bf3rOCW7+H8v3GrWgxox4Pv5OvCnHLFqnnD7MC8968yf
# kI+fW8svJJBO9yyDx9lTOLSIp336nzrhh3GKoVGfirrhTYN4cnhk1kQIX8O+9CNY
# uoLeFgwbYa2mwVnI56o7c7BWzPbxCXZYfyE2Rr2ZbeAcKZinSaeNji0MKq6zirC6
# SlGs9aRg9LGYJ6nECiOhp5VdbnGudqVy71xst+3u0m5qQPV7WUCcUMnxYYHLkeoP
# PzEjH59yb8fE3uJozJJnX460qQqPlfG4w69lzAZwHTkO4m7rF0PrJ6o/9BqaXks0
# fHb9RE418ZvqcrWJTYTCWN1YHvQwz29Tuxu/eUJh4/9PImHGnKnFCS2bj9KKWV1W
# or6K1GZW4DVWhys=
# SIG # End signature block
