$PortProxy = @()
$netsh = & netsh interface portproxy show all
$netsh | Select-Object -Skip 5 | Where-Object {$_ -ne ''} | ForEach-Object {
    $Attribitutes = $_ -replace "\s+"," " -split ' '
    $PortProxy += [PSCustomObject]@{
        'ComputerName'         = $Env:COMPUTERNAME
        'Listening On Address' = $Attribitutes[0]
        'Listening On Port'    = $Attribitutes[1]
        'Connect To Address'   = $Attribitutes[2]
        'Connect To Port'      = $Attribitutes[3]
    }
}
$PortProxy | Where-Object {$_.'Listening On Address' -match "\d.\d.\d.\d" -or $_.'Listening On Address' -match ':' }












# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU/wSjmefFjW3un8yssdMAqNsw
# sfKgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
# AQUFADAzMTEwLwYDVQQDDChQb1NoLUVhc3lXaW4gQnkgRGFuIEtvbW5pY2sgKGhp
# Z2gxMDFicm8pMB4XDTIxMTIxNDA1MDIwMFoXDTMxMTIxNDA1MTIwMFowMzExMC8G
# A1UEAwwoUG9TaC1FYXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALvIxUDFEVGB/G0FXPryoNlF
# dA65j5jPEFM2R4468rjlTVsNYUOR+XvhjmhpggSQa6SzvXtklUJIJ6LgVUpt/0C1
# zlr1pRwTvsd3svI7FHTbJahijICjCv8u+bFcAR2hH3oHFZTqvzWD1yG9FGCw2pq3
# h4ahxtYBd1+/n+jOtPUoMzcKIOXCUe4Cay+xP8k0/OLIVvKYRlMY4B9hvTW2CK7N
# fPnvFpNFeGgZKPRLESlaWncbtEBkexmnWuferJsRtjqC75uNYuTimLDSXvNps3dJ
# wkIvKS1NcxfTqQArX3Sg5qKX+ZR21uugKXLUyMqXmVo2VEyYJLAAAITEBDM8ngUC
# AwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0G
# A1UdDgQWBBSDJIlo6BcZ7KJAW5hoB/aaTLxFzTANBgkqhkiG9w0BAQUFAAOCAQEA
# ouCzal7zPn9vc/C9uq7IDNb1oNbWbVlGJELLQQYdfBE9NWmXi7RfYNd8mdCLt9kF
# CBP/ZjHKianHeZiYay1Tj+4H541iUN9bPZ/EaEIup8nTzPbJcmDbaAGaFt2PFG4U
# 3YwiiFgxFlyGzrp//sVnOdtEtiOsS7uK9NexZ3eEQfb/Cd9HRikeUG8ZR5VoQ/kH
# 2t2+tYoCP4HsyOkEeSQbnxlO9s1jlSNvqv4aygv0L6l7zufiKcuG7q4xv/5OvZ+d
# TcY0W3MVlrrNp1T2wxzl3Q6DgI+zuaaA1w4ZGHyxP8PLr6lMi6hIugI1BSYVfk8h
# 7KAaul5m+zUTDBUyNd91ojGCAegwggHkAgEBMEcwMzExMC8GA1UEAwwoUG9TaC1F
# YXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKQIQeugH5LewQKBKT6dP
# XhQ7sDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkq
# hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGC
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUqa9VeFESbvcUgHinAJ6ixn6GhvMwDQYJKoZI
# hvcNAQEBBQAEggEAULiZbnuYnxpvIaWiEXaSPxK1HecUTsSiCzMlZSWv+YRmotmZ
# 6zTOwQQRkREfkWUMP8NnRWyWzgOX+eROQfyShi8kt0D+WxXSObxaXC3r4WEGlrpH
# EJM9a4Rt1/xnfp0ok7Raz9ll4epFtlhHaSErPW955vjfhP1kade9UbO9E3zXrSP6
# eVWmutNi+gFwy7TITS01LksSiM30lDLiBk+/Yonjs96BS9BNsLCmoptEQAjXt4qy
# bGEXMJC2HAoIdjpxRouL2fB9yg9kVxTyusf4rbrwwyTVkjCx4OLxaQhWljmQtio0
# cQwJ3zstUdrWV1w1FPhkzSkSg0n2rS/JjTzzng==
# SIG # End signature block
