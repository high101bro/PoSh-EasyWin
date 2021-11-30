# This function is created within a string variable as it is used with an an agrument for Invoke-Command
# It is initialized below with an Invoke-Expression
$GetChildItemDepth = @'
    Function Get-ChildItemDepth {
        Param(
            [String[]]$Path     = $PWD,
            [String]$Filter     = "*",
            [Byte]$Depth        = 255,
            [Byte]$CurrentDepth = 0
        )

        $CurrentDepth++
        Get-ChildItem $Path -Force | Foreach {
            $_ | Where-Object { $_.Name -Like $Filter }

            If ($_.PsIsContainer) {
                If ($CurrentDepth -le $Depth) {
                    # Callback to this function
                    Get-ChildItemDepth -Path $_.FullName -Filter $Filter -Depth $Depth -CurrentDepth $CurrentDepth

                }
            }
        }
    }
'@
Invoke-Expression -Command $GetChildItemDepth



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUqjSW2O6rInEHoDtQZGvVhtNK
# g7igggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUbEypCUBVJNLI2sPqzL7rmYI2cpswDQYJKoZI
# hvcNAQEBBQAEggEAikkoDlDwLynhftmu7XhNR/kE/x0YtH2zT3x+37ReklLx+rW8
# bpzEUl2X2sh+spClLPlF0oJpQgRr66irHqRArxUVC10DUvBG1FDCDrUcy/ePJIyq
# cCuoWvXrDyznqBLhVe+GjnktBTWEOVVK8g5byBADLBhidjs1p1jRgRJ4rF0epxc9
# FfkOx1Ea9welQqsHlbLjFq9l7MibtE/uDkn3cV1HOTQNvwlQL8WOOmiDgYqiiEjk
# kdDoG/oRjFoODCRqK+sOm4CZOa+SUkLNtUUTLaAGhwSmE13ToST5NfaLwy1+hEgt
# JIH2DHtD07uYIhbiPQJj5eLNpRdB8cZxBIDNeg==
# SIG # End signature block
