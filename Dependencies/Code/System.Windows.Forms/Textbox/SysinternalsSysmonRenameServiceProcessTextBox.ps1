$SysinternalsSysmonRenameServiceProcessTextBoxAdd_MouseHover = {
    Show-ToolTip -Title "Rename Sysmon's Service/Process Name" -Icon "Info" -Message @"
+  The default Service/Process name for SysInternals' System Monitor tool is: 'Sysmon'
+  Use this field to obfuscate the service and process name as the tool is running
+  Do NOT add the .exe filename extension; this will be done automatically
+  If this textbox is blank and hovered by the cursor, it will input the default name
+  If a renamed Symmon service push is attempted when sysmon is already installed,
     the script will continue to check for the Renamed Sysmon service exists until it times out
"@

    If ( $($This.Text).Length -eq 0 ) {
        $This.Text = 'Sysmon'
    }

}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU4/jPxiezIhDwtyiwszbiwx/J
# wwGgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUnFuh/EtC2tsrv2ImVdD67046dUQwDQYJKoZI
# hvcNAQEBBQAEggEAfA+HfJHtZyyAecgLQhnvT5G95ZL5PiP30ZOYqDbhGos2i4Kg
# 9tVMQEBjW8WbHWGrx53NHE7S1RiF4F8Oz7+lEZV0WusEXgdN6xeq/r/F0+iTlFYq
# /8+Z2LzB6hebxrE69/+C2ThsbcaajIScoUWdvwKReXTrDMZbIHbQ3pRbasdNkdIY
# 9Rd1kU6g9hHggCJMUCiX2n5XSe96MuQfNY3ePFE94J7m0607hQGDIPtF+pjFXWce
# Y3g9QgfX+TrQow8F8IFwXcqytvO/49lbBJ8t1Rq2sOxA3/1iqnNNTnoOFvvolNMe
# L8q+N+My5tcJNuD82qvuzOXQMNVnYUtD//dpEg==
# SIG # End signature block
