<#
.Description
    Compiles various time related data into one easy to read results
#>

$os = $null
$GetTimeZone = $null
$os = Get-WmiObject win32_operatingsystem
$GetTimeZone = Get-Timezone
if ($GetTimeZone) {
    $DateTimes = [PSCustomObject]@{
        LastBootUpTime             = $os.ConvertToDateTime($os.LastBootUpTime)
        InstallDate                = $os.ConvertToDateTime($os.InstallDate)
        LocalDateTime              = $os.ConvertToDateTime($os.LocalDateTime)
        TimeZone                   = $GetTimeZone.StandardName
        BaseUtcOffset              = $GetTimeZone.BaseUtcOffset
        SupportsDaylightSavingTime = $GetTimeZone.SupportsDaylightSavingTime
    }
    $DateTimes | Select-Object @{n='ComputerName';E={$env:COMPUTERNAME}}, LocalDateTime, LastBootUpTime, InstallDate, TimeZone, BaseUtcOffset, SupportsDaylightSavingTime
}
else {
    $DateTimes = [PSCustomObject]@{
        LastBootUpTime  = $os.ConvertToDateTime($os.LastBootUpTime)
        InstallDate     = $os.ConvertToDateTime($os.InstallDate)
        LocalDateTime   = $os.ConvertToDateTime($os.LocalDateTime)
        CurrentTimeZone = $os.CurrentTimeZone
    }
    $DateTimes | Select-Object @{n='ComputerName';E={$env:COMPUTERNAME}}, LocalDateTime, LastBootUpTime, InstallDate, CurrentTimeZone
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUB8ax2c1VmdGEu/x79Cejg34b
# AEWgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUEM5wsw+87M6V6PCA31NExR96EpwwDQYJKoZI
# hvcNAQEBBQAEggEALxdwjdOuvNy24dZWFfrQf/afemOxukMKi6Lml+12QD5AKEjk
# L/Z/zim/rSpkMUsB0kPYnulGapskkSUxVAkfb6gRLBgLKOz9ulFlROQf/2pYqlNE
# e9Wj0kXzAXSzM48cNvUk++s+Xh8TMmvokbVelZaGtBz9bDwGfMUN+UJxWloclxMH
# C0THNIajAxRyTpMshzdrYWjBgEMT1RkSJvrpX+pr8TcmAHx70Iuchwg8lpt0KqYC
# z/8OarYnx/+lO1GWG3hnDhcwwCWhijN5CwAOkc1Qkb1oc2Lsx0dv47Jf5uJHyWFQ
# Ygwy29hsHd4kHLACXLer7OKTrrGDMxthMdyOTA==
# SIG # End signature block
