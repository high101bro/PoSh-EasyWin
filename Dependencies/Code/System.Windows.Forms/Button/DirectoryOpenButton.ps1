$DirectoryOpenButtonAdd_Click = {
    if (Test-Path $($script:CollectionSavedDirectoryTextBox.Text)) {
        $OpenDirectory = $script:CollectionSavedDirectoryTextBox.Text
    }
    elseif (Test-Path $CollectedDataDirectory) {
        $OpenDirectory = $CollectedDataDirectory
    }
    else {
        $OpenDirectory = $PoShHome
    }
    Invoke-Item -Path $OpenDirectory
}

$DirectoryOpenButtonAdd_MouseHover = {
    Show-ToolTip -Title "Open Results" -Icon "Info" -Message @"
+  Opens the directory where the collected data is saved.
+  The 'Collected Data' parent directory is opened by default.
+  After collecting data, the directory opened is changed to that
    of where the data is saved - normally the timestamp folder.
+  From here, you can easily navigate the rest of the directory.
"@
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUGmB1tmO4t6br3B3GMWqXtnKx
# yFKgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUX4p1WI5Lu41STlonlUHFqZ6oXvswDQYJKoZI
# hvcNAQEBBQAEggEAKw+ttRWTLkQDHSTKozgOcuub6P6ggdXslorgjwUQ2JOmTKk2
# 5jz5ntU75i8P0qJrhUY0uinuD65pFHzrs9LZ9BZnAI+PDyXD1mrbalwEjGO6cTJJ
# aA4RtbQO3Z1ao+7naonXRLY2Dj6LIcrIwwRqot9+pnieaO0eTIbJb10XE6n4xq0e
# yVj5Dj2LUKFVrtaOFZzR4sqTF0xOxMD6iyvPfV7lv8awp0bfJIRoF+yyQj3II4pQ
# 0bu4X+NsFhSwvj4WYCsPXAHrJRrCIqEktvVEs2kM88IrgKPAnmwl/ociyiw0/Z8i
# z5zZGoqxDmMkOdR0zINKrbrel/U91s7sFHPXTA==
# SIG # End signature block
