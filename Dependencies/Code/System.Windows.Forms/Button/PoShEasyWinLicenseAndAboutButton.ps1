$PoShEasyWinLicenseAndAboutButtonAdd_Click = {
    $InformationTabControl.SelectedTab = $Section3AboutTab

    if ($PoShEasyWinLicenseAndAboutButton.Text -eq "License (GPLv3)" ) {
        $PoShEasyWinLicenseAndAboutButton.Text = "About PoSh-EasyWin"
        $Section1AboutSubTabRichTextBox.Text   = $(Get-Content "$Dependencies\GPLv3 - GNU General Public License.txt" -raw)
    }
    elseif ($PoShEasyWinLicenseAndAboutButton.Text -eq "About PoSh-EasyWin" ) {
        $PoShEasyWinLicenseAndAboutButton.Text = "License (GPLv3)"
        $Section1AboutSubTabRichTextBox.Text   = $(Get-Content "$Dependencies\About PoSh-EasyWin.txt" -raw)
    }
}

$PoShEasyWinLicenseAndAboutButtonAdd_MouseHover = {
    Show-ToolTip -Title "Posh-EasyWin" -Icon "Info" -Message @"
+  Switch between the following:
     About PoSh-EasyWin
     GNU General Public License v3
"@
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU0Im7ye5mCRevPhmuYiFhEimC
# VUigggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU8Uh6iuB2QE37hTGod1lcGNKPFf0wDQYJKoZI
# hvcNAQEBBQAEggEAdYhF/hA8nfKnKINdseVRRXXwDSif9Asv4kDGJY41ECRhJJ5I
# hc246BI9U/Z1ZIw7qYqLVjv+flK0SvT1q+NjgLm72VHP6catmnQx3tal+4QkUmDU
# QeaOI69h89kf52mXck5+In9mDcN1ovZu5TvqKHmKOFC/sIeWzkZKCW0P8Qr7Edop
# heM5/htX7HXVynn7auyyj+7K2tFRmKlkJW61TlZbQ5e8KGn1BtQ7MIEbgThl6BIq
# IJHitLGF816YPDsnq7/BnilWIDoATvDWgbX8J6T0uV5Ob7ret04BkKUalKrEAn0/
# XvIYohMlQArsdQYC28Ov2t+jPynlvQUrAZyXDw==
# SIG # End signature block
