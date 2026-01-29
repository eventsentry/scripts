# This script can easily be integrated with EventSentry's performance monitoring functionality (option "executable")
# See KB 473 for more information

If ($args.Length -le 0)
{
    Write-Host "Hostname argument required"
    Exit(1)
}

# Path to the plink utility
$pathToPlink = "c:\tools\ssh\plink.exe"

# User for SSH login
$sshUser = "sshUser"

# Path to SSH public key cert, user/pass auth can be used an alternative, can also be customized to use cmd arg
$sshPathToCert = "C:\tools\ssh\sshCert"

$procInstance = @{}

$pinfo = New-Object System.Diagnostics.ProcessStartInfo
$pinfo.Arguments = '-batch -i ' + $sshPathToCert + ' -l ' + $sshUser + ' ' + $args[0] + ' "ps -eo %cpu,cmd"'
$pinfo.FileName = $pathToPlink
$pinfo.RedirectStandardError = $true
$pinfo.RedirectStandardOutput = $true
$pinfo.UseShellExecute = $false
$pinfo.CreateNoWindow = $true
$p = New-Object System.Diagnostics.Process
$p.StartInfo = $pinfo
$p.Start() | Out-Null

$stdout = $p.StandardOutput.ReadToEnd()
$stderr = $p.StandardError.ReadToEnd()

$processes = @()
$cpuValues = @()

$lines = $stdout.Split("`n")

ForEach ($line in $lines)
{
    $tokens = $line.Split(" ")
       
    If ($tokens.Count -gt 2)
    {
        $cpuUsage = $tokens[1]
        $processName = $tokens[2]
        
        try
        {
            $cpuValues += [Math]::Round($cpuUsage)
            
            $processName = $processName.TrimEnd(":")
            $processName = $processName.TrimEnd(")")
            $processName = $processName.TrimStart("-")
            $processName = $processName.TrimStart("(")
            
            $processNameOutput = $processName
            
            If ($procInstance[$processName] -gt 0)
            { 
                $processNameOutput += "#"
                $processNameOutput += $procInstance[$processName] 
            }
            
            $processes += $processNameOutput            
                    
            If ($procInstance[$processName] -eq '')
                { $procInstance[$processName] = 1 }
            Else
                { $procInstance[$processName]++ }
        }
        catch {
        }
    }
}

$processes -join ","
$cpuValues -join ","

# SIG # Begin signature block
# MIISGwYJKoZIhvcNAQcCoIISDDCCEggCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUiUVky670siO5cHv6CJTptx5K
# on+ggg54MIIG6DCCBNCgAwIBAgIQd70OBbdZC7YdR2FTHj917TANBgkqhkiG9w0B
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
# DQEJBDEWBBSJirFVcFleAmYgnleUxkYEvw6KvTANBgkqhkiG9w0BAQEFAASCAgAX
# it+sJUPBmnGydZggcBXx79s1b3lrPhBZen16ai43CLXDxUa/isX1ApCR7hBViNE5
# WU46jrRd0V1lZy2ygg7qQ1nceyKPl6BnTbMTT+L0Jzalz1oCdiGaruT9/ZRf1Skn
# AcSzraiaQBhnPaRzrUfLb+g+9tHnA0m7yD4nhnxUXmv+IVJV7lMEwK545b7V2H05
# rMZyenigEyHppjb/PDy0NXhE87OMrj/eEOFRD1CBzGtsBRS7+32qG0GmI1rE1JjR
# a/yk7vb/8VP8t67ztKEr66tkgBsfXMWnAzQjDEkui8wWbvp5RrYUTYy0YoStJD7w
# DLloCyz2lB9kvX7x1tGeRzUFLSeYC5z3waRvsV+1W9LS1xk1wWPMHzoHTKrAZRiN
# O4F2toQCGMkiYsRXSOixgPXI+ezpvh/Gi3I8lTgTzv0sJmUmX/q+frZFHM6ihcAr
# GAEDRubO2zuwGPsww4plPxpgmwckjii8JmuVLoQn47uaQdyfB97O1Rbgp+6xvygz
# Y+KcArqE7VkzeGLOXOxbfwOOJADxvpF1hr32jiCIqwCER17Z42qrCnRpWVqGPGlp
# 1SoJkFO5MvRtyTncmum1DQLnHlCKWfhpnOyMnyV0I5HNMtEPmPqy5CkEKyINUP0c
# xMBt66p2rQmSSRP0iH65V2gfbChxoJn043jZ7zS7sw==
# SIG # End signature block
