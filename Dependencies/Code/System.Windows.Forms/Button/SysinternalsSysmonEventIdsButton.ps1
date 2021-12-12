$SysinternalsSysmonEventIdsButtonAdd_Click = {
    $EventCodeManualEntrySelectionContents = $null
    Import-Csv  "$Dependencies\Sysmon Config Files\Sysmon Event IDs.csv" | Out-GridView -Title 'Sysmon Event IDs' -OutputMode Multiple | Set-Variable -Name EventCodeManualEntrySelectionContents
    $EventIDColumn = $EventCodeManualEntrySelectionContents | Select-Object -ExpandProperty "Event ID"
    Foreach ($EventID in $EventIDColumn) {
        $EventLogsEventIDsManualEntryTextbox.Text += "$EventID`r`n"
    }

    if ($EventCodeManualEntrySelectionContents){
        $MainLeftSearchTabControl.SelectedTab = $Section1EventLogsTab
    }
}

$SysinternalsSysmonEventIdsButtonAdd_MouseHover = {
    Show-ToolTip -Title "Sysmon Event ID List" -Icon "Info" -Message @"
+  Shows a list of Sysmon specific event IDs
+  These Event IDs will only be generated on endpoints that have Sysmon installed
+  https://docs.microsoft.com/en-us/sysinternals/downloads/sysmon
"@
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU3B62i2f6rK3iU87PE+sM8jpz
# pl6gggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
# AQUFADAzMTEwLwYDVQQDDChQb1NoLUVhc3lXaW4gQnkgRGFuIEtvbW5pY2sgKGhp
# Z2gxMDFicm8pMB4XDTIxMTEyOTIzNDA0NFoXDTMxMTEyOTIzNTA0M1owMzExMC8G
# A1UEAwwoUG9TaC1FYXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANUnnNeIFC/eQ11BjDFsIHp1
# 2HkKgnRRV07Kqsl4/fibnbOclptJbeKBDQT3iG5csb31s9NippKfzZmXfi69gGE6
# v/L3X4Zb/10SJdFLstfT5oUD7UdiOcfcNDEiD+8OpZx4BWl5SNWuSv0wHnDSIyr1
# 2M0oqbq6WA2FqO3ETpdhkK22N3C7o+U2LeuYrGxWOi1evhIHlnRodVSYcakmXIYh
# pnrWeuuaQk+b5fcWEPClpscI5WiQh2aohWcjSlojsR+TiWG/6T5wKFxSJRf6+exu
# C0nhKbyoY88X3y/6qCBqP6VTK4C04tey5z4Ux4ibuTDDePqH5WpRFMo9Vie1nVkC
# AwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0G
# A1UdDgQWBBS2KLS0Frf3zyJTbQ4WsZXtnB9SFDANBgkqhkiG9w0BAQUFAAOCAQEA
# s/TfP54uPmv+yGI7wnusq3Y8qIgFpXhQ4K6MmnTUpZjbGc4K3DRJyFKjQf8MjtZP
# s7CxvS45qLVrYPqnWWV0T5NjtOdxoyBjAvR/Mhj+DdptojVMMp2tRNPSKArdyOv6
# +yHneg5PYhsYjfblzEtZ1pfhQXmUZo/rW2g6iCOlxsUDr4ZPEEVzpVUQPYzmEn6B
# 7IziXWuL31E90TlgKb/JtD1s1xbAjwW0s2s1E66jnPgBA2XmcfeAJVpp8fw+OFhz
# Q4lcUVUoaMZJ3y8MfS+2Y4ggsBLEcWOK4vGWlAvD5NB6QNvouND1ku3z94XmRO8v
# bqpyXrCbeVHascGVDU3UWTGCAegwggHkAgEBMEcwMzExMC8GA1UEAwwoUG9TaC1F
# YXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKQIQVnYuiASKXo9Gly5k
# J70InDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkq
# hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGC
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUvs2B33qSlveRmKBY1Koc+6Lm4U4wDQYJKoZI
# hvcNAQEBBQAEggEAyuyk9P8O4tKcFd1h8HXmu+JyTwPjVU3kr/MvTn9+M8BQJGF2
# hTFAyajD2c7tYIfYllu8zmQ3uwx9j0+KlVZB2xETWxOJVanD8Y0GQu9F1lf824Jw
# yMnih8Fb2AJ88dZrEW+SfVPwFGsJg+3tlqUEjZNfvLfgNbB7QNk+JllKhR+5WyPW
# RlTc67rF67XdtEpBDeDZsMakhSGnnensAS0wXFmGlBxSbilegK3eWMGrl5p0dMrt
# /CWrazncjdbswKRwQgmbwoiM3iWeTo/2BPQABQA7FCmAF6E9nY1QrRng4jJvTJlA
# UvD79xCkp5CkQ39HKAa1peGzSYy3D02mHwoRCw==
# SIG # End signature block
