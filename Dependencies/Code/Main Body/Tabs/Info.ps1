
$MainLeftInfoTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text = "Info  "
    Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
    ImageIndex = 5
}
$MainLeftTabControl.Controls.Add($MainLeftInfoTab)


$MainLeftInfoTabControl = New-Object System.Windows.Forms.TabControl -Property @{
    Location = @{ X = $FormScale * 3
                  Y = $FormScale * 3 }
    Size     = @{ Width  = $FormScale * 446
                  Height = $FormScale * 557 }
    Hottrack      = $true
    Appearance    = [System.Windows.Forms.TabAppearance]::Buttons
    Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,2,1)
    ShowToolTips  = $True
    SelectedIndex = 0
}
$MainLeftInfoTab.Controls.Add($MainLeftInfoTabControl)


$ResourceFiles = Get-ChildItem "$Dependencies\About"


# Iterates through the files and dynamically creates tabs and imports data
foreach ($File in $ResourceFiles) {

    $Section1AboutSubTab = New-Object System.Windows.Forms.TabPage -Property @{
        Text                    = $File.BaseName
        UseVisualStyleBackColor = $True
        Font                    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $MainLeftInfoTabControl.Controls.Add($Section1AboutSubTab)


    $TabContents = Get-Content -Path $File.FullName -Force | ForEach-Object {$_ + "`r`n"}
    $Section1AboutSubTabTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Text       = "$TabContents"
        Name       = "$file"
        Location = @{ X = $FormScale * -2
                      Y = $FormScale * -2 }
        Size     = @{ Width  = $FormScale * 448
                      Height = $FormScale * 553 }
        MultiLine  = $True
        ScrollBars = "Vertical"
        Font       = New-Object System.Drawing.Font("Courier New",($FormScale * 9),0,0,0)
    }
    $Section1AboutSubTab.Controls.Add($Section1AboutSubTabTextBox)
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUSR8s/6Jef5oZPTLnJuy40Oym
# gXGgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUC4CAoMpnom/5co7ZynXHNm1icN4wDQYJKoZI
# hvcNAQEBBQAEggEAoUpK90v9++peyfN/uHQ5am4mZQrDppuA5zsKIJfImwDAtHYf
# 8DYEyw56Vqb36fGSx0xkegevrzTYmEg8iQQ7YIFoJSxpQ8Ch03zwq7sFxtoAHwEq
# VuPR38RSXyuvUUuwprtbqvx68pK2Ui71mFvjnvzuENwgKWzA0j37GgslE98/9uPz
# gvuhw3KFtP+4RSnKETfPST70AYu+9xqfCJHxGxBANlyRm8k/pdZjCD+FYVKt0tJ5
# JJOamUEIsbo9o6jYeTYKkpukZH8YoekTnDQhbAtKtwkXx74FZQqLfPHc8tA+5TCZ
# Kqz2c+8GtjYw6DdcMqGtFZG0/q6+j/gwRYafNA==
# SIG # End signature block
