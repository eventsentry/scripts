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

# SIG # Begin signature block
# MIISGwYJKoZIhvcNAQcCoIISDDCCEggCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUtZzJfONfpb/BhqqciGsIZLRX
# 5DSggg54MIIG6DCCBNCgAwIBAgIQd70OBbdZC7YdR2FTHj917TANBgkqhkiG9w0B
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
# DQEJBDEWBBSxTi4+oqnd7SsUEKwkPDmGuMwrKjANBgkqhkiG9w0BAQEFAASCAgCd
# yr9auxnAF9hzBOpp/sCjpq7cG16fYPS64nwuemmuq67xV4iUukYewslF/j/C08xg
# pmtDvzD2eNlXoxpaTWopw22pNycGXaMdQMa3sh+BZSGx7hhXNykX5IVouksb8v9r
# I4QDDV87wuzMghFbqnBOFJvZ2f0VUSLZ7K0d9+TgqcpnKQLT4Kjg+PHdaHu+WWi2
# WwkR/pW9rK/vboad92Xzr6zQjDCmmfCtF6eO81aBSVfxvXoiPtAQ32WlEC1sCm0I
# 5cBSFcrz0mbd8CI9JLvbyMHFVWlk+9bBHbT7OCcsly6GuKU31kyp8NpCVL8HFqSU
# /TVm+I1Yle81aMrNfEHNSsB+sokvbU+R4LCuV1b2VBetZmANjaEqkG/EJwyTDLVL
# TxsnFsbppkh/t0ylf5CUrzr+Neuy9NQ2FH/WrptqazLd+TGooX/fCQIddLKI6Wvi
# RXWlP7v+NKkxCkqB7YpXKz9moC/mevKNbmCEIh3msiXxhDnrwObZ9IWqCem7zj43
# d+7vuqorFOz7harR/ppbpqqsjU/nHi/JZqY8N/ZTT1djTMZH3U7HopzR9yNzWnUz
# lDJaFc9d/q1woFnWhhS9CzkcY2HbsZQUWrRjL0J7uZM6aHY5Srj0XpeKRk8Qw6iV
# RSFR0G3RV7O8IcZWTnmLRIxdHPTOTkow3fg59FQqxA==
# SIG # End signature block
