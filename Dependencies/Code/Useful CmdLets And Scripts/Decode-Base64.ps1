function Decode-Base64 {
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'FileName')]
        $Filename,
        [Parameter(Mandatory = $true, ParameterSetName = 'String')]
        $String
    )

    if ($FileName){
        $Data = get-content $FileName
        $Bytes = [System.Text.Encoding]::UTF8.GetBytes($Data)
        $EncodedData = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($Bytes))

        return $EncodedData
    }
    if ($String) {
        $Bytes = [System.Text.Encoding]::UTF8.GetBytes($String)
        $EncodedData = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($Bytes))

        return $EncodedData
    }
}
# Decode-Base64 -String


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU62i85dIY8XTMse1hditLEx+1
# 1aGgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUa3oNDxvd7CBqtIFbVozMR2KbUgMwDQYJKoZI
# hvcNAQEBBQAEggEAxY5yeVi3osuxDGLyE5D/IBfghjat0/pfh79py3jNzTRaPPEM
# 9qq6W+4FIkvYzQtWamX+m2pQMcPd3JAhhz3DrFa4BsCf9zKbpsPg0sfo8TKfBPz8
# Rwf+tPw4CYXuhkZ2U90NsJWfiQg35js8dAMpSDmpNMoeVOPc6MhWtLq5bcf6TagQ
# QzmuqwVBDXOn9e7cL8rastfUOdIN9OVEU+3dV+VUfxnOALIINwNXQSVnE36klHUj
# suTAyxKeJNg41LysvySEUm+pI+U3zJz472aXDQYthXLro98f7bQ45t8phMi5FH93
# WGekfJJGDk85eDULCiqocm5uprMCeC+nycwBiw==
# SIG # End signature block
