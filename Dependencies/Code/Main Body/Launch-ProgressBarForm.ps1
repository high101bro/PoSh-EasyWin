function Launch-ProgressBarForm {
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUlxOTqQmj78GMuSqDv58YDn5D
# qYKgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUNmZ707SXri9o5J6yVAXO0DDJhVowDQYJKoZI
# hvcNAQEBBQAEggEAtBbDewwdaWQKFKTqcZSoofW6chkTrj1SG2RMVZmj91bm0rlt
# szAJersiDjrla3ghTtwz1Qi3JEyICajV17aOljEX5kJGwAbhd/ldC1KAFkIpTTKQ
# 9aVzAfMmNSqjEraV5Pvc0I0Co0AXp3iOZfDlbhddRqN41oxywsObd5VHCM8xGXvK
# cbDKFoOHOPomhUP0JO9CCeEdCt2rgxe91oGle/9vW4svY16Qzdy+xKIq7OuQqqe1
# YY258htizcTWoGk66r2nTL3H+Yijb9VFrPrbxqJ41Juih9A1LkREmpcfXFmLTusE
# 0KAXDzQgw/BzC5Thuracc+8FA7k1JJk2nKk4vA==
# SIG # End signature block
