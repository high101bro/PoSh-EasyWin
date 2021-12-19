<#
Antecedent: A CIM_USBController representing the Universal Serial Bus (USB) controller associated with this device.
Dependent: Describes the logical device connected to the Universal Serial Bus (USB) controller.
#>
Get-WmiObject -Class Win32_USBControllerDevice | Foreach-Object {
    $Dependent  = [wmi]($_.Dependent)
    $Antecedent = [wmi]($_.Antecedent)

    [PSCustomObject]@{
        USBDeviceName             = $Dependent.Name
        USBDeviceManufacturer     = $Dependent.Manufacturer
        USBDeviceService          = $Dependent.Service
        USBDeviceStatus           = $Dependent.Status
        USBDevicePNPDeviceID      = $Dependent.PNPDeviceID
        USBDeviceHardwareID       = $Dependent.HardwareID
        USBDeviceInstallDate      = $Dependent.InstallDate
        USBControllerName         = $Antecedent.Name
        USBControllerManufacturer = $Antecedent.Manufacturer
        USBControllerStatus       = $Antecedent.Status
        USBControllerPNPDeviceID  = $Antecedent.PNPDeviceID
        USBControllerInstallDate  = $Antecedent.InstallDate
    }
} `
| Select-Object -Property PSComputerName, * `
| Sort-Object Description,DeviceID



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUqqmeUF7QZuy+heT3yaYgRj1s
# rM6gggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUtPCrXiIDlr2Xi9EVo4C1wqlgweMwDQYJKoZI
# hvcNAQEBBQAEggEAXUZZH0gSR2tZIWvzF+tuR2LRW8bvA/8SGUPqGoxUl2LZtsTM
# nZKk0DuL/oU5B0bC0jpK8ZmHBmN55ak426wIJtxA4d8AeYm+e/OXjx864CZzvTF7
# GISp4SMfiqGaERJ33KwgMO4UvNdS7qC3uYmgj9wi1DYEhtFnOKhQavdgAMACNJ23
# dj6/v8QHPug11uwnnGvauffy32vW6Gu/lfqP2MF6RsQqkDvX0V7XokePDwM0qQqi
# yn7l858oEntmFxx9SqJ7m1Xr/83xsVy+DHKGqT5SuKFPgYrMnJBPVzQRzCFKUnrc
# rujNGI5xcY9WiAI+PA5BnBnfR7CXdp1HtQVqng==
# SIG # End signature block
