function InputCheck-EnumerationByDomainImport {
    if (($EnumerationDomainGeneratedTextBox.Text -ne '<Domain Name>') -or ($EnumerationDomainGeneratedAutoCheckBox.Checked)) {
        if (($EnumerationDomainGeneratedTextBox.Text -ne '') -or ($EnumerationDomainGeneratedAutoCheckBox.Checked)) {
            # Checks if the domain input field is either blank or contains the default info
            If ($EnumerationDomainGeneratedAutoCheckBox.Checked  -eq $true){. Import-HostsFromDomain "Auto"}
            else {. Import-HostsFromDomain "Manual" "$($EnumerationDomainGeneratedTextBox.Text)"}

            $EnumerationComputerListBox.Items.Clear()
            foreach ($Computer in $script:ComputerList) {
                [void] $EnumerationComputerListBox.Items.Add("$Computer")
            }
        }
    }
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUBDTMLCUoNlE+JvCgiL6Cjvd2
# +TagggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQULkJQIxhePVJAgU50c06jQGfRaOQwDQYJKoZI
# hvcNAQEBBQAEggEAGAyofMH6kIy0JO8PMngDWKmHrKmdluQ79ptGRvkCITzdEYgb
# RF5hRM9wl91Odi1sE9SS0UAJpZRG+6iy9onw54RDbfZWyYZReCYm6riKEbDbVyQk
# KHCVHjy3UMOWzQFDiWez+9rDiYzkJKs6mKrd0rMK4DS/aPtmTZiH43XECAAUJmGz
# KxgmvoTGNLUfXI8ChY7IkxtUtRKOuV+2h7Ah8UvDL0XDIvFkyMk5qTPkljduZIDw
# xU2sZS8ADMbhwJa+TTy8jZQ7+8mAOD+6ugy7We54NoSoh5TyxWjOXXj1nbQ68Rgr
# eM1YSQWjvO/gMxbKrx0WIP54t2pJwjadho7+Ig==
# SIG # End signature block
