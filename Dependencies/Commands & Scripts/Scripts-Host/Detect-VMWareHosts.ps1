$VMwareDetected   = $False
$VMNetworkAdapter = $(Get-WmiObject Win32_NetworkAdapter -Filter 'Manufacturer LIKE "%VMware%" OR Name LIKE "%VMware%"')
$VMBios           = $(Get-WmiObject Win32_BIOS -Filter 'SerialNumber LIKE "%VMware%"')
$VMWareService    = $(Get-Service | Where-Object {$_.Name -match "vmware" -and $_.Status -eq 'Running'} | Select-Object -ExpandProperty Name)
$VMWareProcess    = $(Get-Process | Where-Object Name -match "vmware" | Select-Object -ExpandProperty Name)
$VMToolsProcess   = $(Get-Process | Where-Object Name -match "vmtoolsd" | Select-Object -ExpandProperty Name)
if($VMNetworkAdapter -or $VMBios -or $VMToolsProcess) {
    $VMwareDetected = $True
}
[PSCustomObject]@{
    PSComputerName   = $env:COMPUTERNAME
    Name             = 'VMWare Detection'
    VMWareDetected   = $VMwareDetected
    VMNetworkAdapter = $VMNetworkAdapter
    VMBIOS           = $VMBIOS
    VMWareService    = $VMWareService
    VMWareProcess    = $VMWareProcess
    VMToolsProcess   = $VMToolsProcess
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU305Zx7eb879Y5AOKLL7Pn31z
# N92gggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUa1JICNtmaKm0QmbM2H5QgPR1uQ8wDQYJKoZI
# hvcNAQEBBQAEggEAVQmnKTPimtUsNGv1nLScG0ESwFhokCe7dUaSq+iZMafi5eMn
# PWRWDQXUx2wPxWjAgb9sF1Sz+qSWme8G2D+RgHBC0Fb+yC+p+PpBJM0xo8GiYQWV
# 3ugBY1sMR7DSjFo+H7muJ+UPB/+wilAAN02pYGxndnM+ocRb8BTlFL+8sV7+JnoL
# RiFDKK9mgP/gJHu94LUPoJWUE5FM2eHIgXdkpu87IW/Fr+90bvWkALe6C3GfOCUA
# rH4ypUMQbMgoVTMk3ggeM8CUHjDDEXDSOlQouCW4mi8UnpL2sCMoH/z92O1cVGg0
# JnebNJZ5x3eXMBRu852FqPnFothSymQ2XujEMA==
# SIG # End signature block
