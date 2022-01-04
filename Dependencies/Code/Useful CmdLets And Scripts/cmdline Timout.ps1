function Read-KeyOrTimeout {
    Param(
        [int]$seconds = 5,
        [string]$prompt = 'Hit a key',
        [string]$default = 'This is the default'
    )
    $startTime = Get-Date
    $timeOut = New-TimeSpan -Seconds $seconds
    Write-Host $prompt
    while (-not $host.ui.RawUI.KeyAvailable) {
        $currentTime = Get-Date
        if ($currentTime -gt $startTime + $timeOut) {
            Break
        }
    }
    if ($host.ui.RawUI.KeyAvailable) {
        [string]$response = ($host.ui.RawUI.ReadKey("IncludeKeyDown,NoEcho")).character
    }
    else {
        $response = $default
    }
    Write-Output "You typed $($response.toUpper())"
}
Read-KeyOrTimeOut












# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUnhrDX9hy2ARwhzNf6Cd7DejS
# ifWgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU2O/g4MB/KTA9vOFR87eEf8RrptEwDQYJKoZI
# hvcNAQEBBQAEggEAN15sHRoubSBm6pJWezv4ygIyaah8rpCtY4wGX3en/jzVyXux
# 5DiwK3xoF9UVgK/W+zx6knTX0ei9VrJYZWYb2XTzve6jVf/pPNwddpmn0t4zm5eZ
# 19C6kacqqfPKw1KQ3CEeDJtm0sQgkFOOKfY6nZQZIpUfc/23XZYFxR8kBA2eFYwa
# C6MsxEXoJcr1xCMUC+U53lMkPW+KTZINi+mYN7IFaL8IvBu5KZSfrN+clhZq8WjG
# OyYQfpsvpxzdOH0v2DgtLLncEflNdQExutA+/7ji6cD1Mp3DlRd7qBPYCgFall+2
# +L/vxtF/FXFFEOVI9+X3l3VR+o+Bi/JjM1Gu0g==
# SIG # End signature block
