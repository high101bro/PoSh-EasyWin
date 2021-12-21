function Show-ProgressBar {
    param(
        $FormTitle,
        $ProgressBarImage = "$Dependencies\Images\PoSh-EasyWin Image 01.png",
        $ScriptBlockProgressBarInput,
        [switch]$ShowImage, 
        $Width = $FormScale * 350,
        $Height = $FormScale * 180
    )
    <#
    https://flamingtext.com/logo/Design-Style
    https://www11.flamingtext.com/net-fu/dynamic.cgi?script=style-logo&text=PoSh-EasyWin&fontname=Black+Ops+One&fillTextColor=%23006fff&fillOutlineColor=%2320d
    Font: Display --> Black Ops One
    #>
    $script:ProgressBarSelectionForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = $FormTitle
        Width  = $Width
        Height = $Height
        StartPosition = "CenterScreen"
        Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$script:EasyWinIcon")
        Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoScroll    = $True
        #FormBorderStyle =  "fixed3d"
        #ControlBox    = $false
        MaximizeBox   = $false
        MinimizeBox   = $false
        ShowIcon      = $true
        TopMost       = $true
        Add_Shown     = $ScriptBlockProgressBarInput
        Add_Closing = { $This.dispose() }
    }

    if ($ShowImage) {
        $PoShEasyWinLogoLoadingPictureBox = New-Object Windows.Forms.PictureBox -Property @{
            Text   = "PoSh-EasyWin Image"
            Left   = $FormScale * 10
            Top    = $FormScale * 10
            Width  = $FormScale * 285
            Height = $FormScale * 35
            Image  = [System.Drawing.Image]::Fromfile($ProgressBarImage)
            SizeMode = 'StretchImage'
        }
        $script:ProgressBarSelectionForm.Controls.Add($PoShEasyWinLogoLoadingPictureBox)

        $script:ProgressBarMainLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Status:"
            Left   = $FormScale * 10
            Top    = $PoShEasyWinLogoLoadingPictureBox.Top + $PoShEasyWinLogoLoadingPictureBox.Height + ($FormScale * 5)
            Width  = $FormScale * 300
            Height = $FormScale * 25
            Font   = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
        }
        $script:ProgressBarSelectionForm.Controls.Add($script:ProgressBarMainLabel)
    }
    else {
        $script:ProgressBarMainLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Status:"
            Left   = $FormScale * 10
            Top    = $FormScale * 10
            Width  = $FormScale * 300
            Height = $FormScale * 50
            Font   = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
        }
        $script:ProgressBarSelectionForm.Controls.Add($script:ProgressBarMainLabel)
    }


    $script:ProgressBarFormProgressBar = New-Object System.Windows.Forms.ProgressBar -Property @{
        Style    = "Continuous"
        #Maximum = 10
        Minimum  = 0
        Left     = $FormScale * 10
        Top      = $script:ProgressBarMainLabel.Top + $script:ProgressBarMainLabel.Height + ($FormScale * 5)
        Width  = $FormScale * 290
        Height = $FormScale * 10
        Value   = 0
    }
    $script:ProgressBarSelectionForm.Controls.Add($script:ProgressBarFormProgressBar)

    <#
    $script:AutoChartsProgressBar = New-Object System.Windows.Forms.ProgressBar -Property @{
        Style    = "Continuous"
        #Maximum = 10
        Minimum  = 0
        Left     = $FormScale * 10
        Top      = $script:ProgressBarFormProgressBar.Top + $script:ProgressBarFormProgressBar.Height + ($FormScale * 5)
        Width  = $FormScale * 290
        Height = $FormScale * 10
        Value   = 0
    }
    $script:ProgressBarSelectionForm.Controls.Add($script:AutoChartsProgressBar)
#>

    $script:ProgressBarMessageLabel = New-Object System.Windows.Forms.Label -Property @{
        Left   = $FormScale * 10
        Top    = $script:ProgressBarFormProgressBar.Top + $script:ProgressBarFormProgressBar.Height + ($FormScale * 5)
        Width  = $FormScale * 300
        Height = $FormScale * 40
        Font   = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    }
    $script:ProgressBarSelectionForm.Controls.Add($script:ProgressBarMessageLabel)

    
    $script:ProgressBarSelectionForm.ShowDialog()
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU6sXZ3CU8VJVX830itVfLACxD
# 8HGgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU4kLJ/Ci/nqd30cp/7A6Dayiz2yYwDQYJKoZI
# hvcNAQEBBQAEggEAkX8dC0pS4AuO/qJMwQw8Mb0R88Pu7Vd6e6A3zygGRwg/DBoq
# R0Kr3zOr4hm/ZaAQceVgOjg1kauNTE6xpNznD4OjqeQ5qKO84N08N2YCeL5o4Brv
# hjn36NtvbvcC1MddjV7UCKIxbcMahh2CLw5VLgg4odH1C3qPh/u6oYuQ/WLGi61a
# NH7vNgPgTgquWdj7zKRIbSlKI2SQsgAD9CGZ4ktTpDJKEK8Q6fBCd0ao0iknBqEn
# qqZckPB+VBm6TbGqJA6rNgZkROpoRjwLnL7s+YO0Zr55QaT7eAACLxwnZTe1yPQj
# khpMrVpU9W8wM863Fv7WQTH67Meqy4Lk92a5vQ==
# SIG # End signature block
