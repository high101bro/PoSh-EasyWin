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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUrOJdvM1Es7ZAbpImPbXgFkYF
# GLWgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUiK9QSaVmPUpJU8gQ60J13UszLu0wDQYJKoZI
# hvcNAQEBBQAEggEAl1Pf2rkDe+A1TcNWhgzGRP6vz1IcHWgpJWQO73gHTub7MU0l
# A3Msuc24qF1+QBqXyuQxcanhmuWJqffLHUfgPfM7qsYmSUU1ZnFImLr/Fh3IKDZM
# CXwbxqcZ02dFGQH9qnRvFHMokEYCTk4RLZuVKN1cviWPROFEGs9lU/Bwoh4QaHUV
# 3xGcx7xiR4ZMRS3ZK6+VmTeYWpqWRXB6hNjMeI4PfOrcsjdC00d53ATvWAUYJC1c
# MkaXJHCtk5RakB15HZ/CSAJuBG+4AvQN4BkvJE48fhmUuH83/R7xwwYp7JJBIqmA
# rKceroUQd1E+OgiWDNHEcrsPDX1B8FqeCusZXg==
# SIG # End signature block
