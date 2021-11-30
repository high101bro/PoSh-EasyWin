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
        Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU3kWsecn3UBklHwc3mxJrigIj
# XdegggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
# AQUFADAzMTEwLwYDVQQDDChQb1NoLUVhc3lXaW4gQnkgRGFuIEtvbW5pY2sgKGhp
# Z2gxMDFicm8pMB4XDTIxMTEyOTIzNDA0NFoXDTMxMTEyOTIzNTA0M1owMzExMC8G
# A1UEAwwoUG9TaC1FYXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANUnnNeIFC/eQ11BjDFsIHp1
# 2HkKgnRRV07Kqsl4/fibnbOclptJbeKBDQT3iG5csb31s9NippKfzZmXfi69gGE6
# v/L3X4Zb/10SJdFLstfT5oUD7UdiOcfcNDEiD+8OpZx4BWl5SNWuSv0wHnDSIyr1
# 2M0oqbq6WA2FqO3ETpdhkK22N3C7o+U2LeuYrGxWOi1evhIHlnRodVSYcakmXIYh
# pnrWeuuaQk+b5fcWEPClpscI5WiQh2aohWcjSlojsR+TiWG/6T5wKFxSJRf6+exu
# C0nhKbyoY88X3y/6qCBqP6VTK4C04tey5z4Ux4ibuTDDePqH5WpRFMo9Vie1nVkC
# AwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0G
# A1UdDgQWBBS2KLS0Frf3zyJTbQ4WsZXtnB9SFDANBgkqhkiG9w0BAQUFAAOCAQEA
# s/TfP54uPmv+yGI7wnusq3Y8qIgFpXhQ4K6MmnTUpZjbGc4K3DRJyFKjQf8MjtZP
# s7CxvS45qLVrYPqnWWV0T5NjtOdxoyBjAvR/Mhj+DdptojVMMp2tRNPSKArdyOv6
# +yHneg5PYhsYjfblzEtZ1pfhQXmUZo/rW2g6iCOlxsUDr4ZPEEVzpVUQPYzmEn6B
# 7IziXWuL31E90TlgKb/JtD1s1xbAjwW0s2s1E66jnPgBA2XmcfeAJVpp8fw+OFhz
# Q4lcUVUoaMZJ3y8MfS+2Y4ggsBLEcWOK4vGWlAvD5NB6QNvouND1ku3z94XmRO8v
# bqpyXrCbeVHascGVDU3UWTGCAegwggHkAgEBMEcwMzExMC8GA1UEAwwoUG9TaC1F
# YXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKQIQVnYuiASKXo9Gly5k
# J70InDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkq
# hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGC
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU11HVzDDPXD4xucMO2qzKHQCO9zswDQYJKoZI
# hvcNAQEBBQAEggEAZZ66PPGjDva8WolvQF3BFA7RDh7H+bBuBkDl/jtC4uBq7grj
# AfkXkd4BgRZylvPsnY9iFaDAZ+jCBQ4bMBqn/fHmmjYrWlQDoZbMuNSpXHx0DSyM
# cB6w6APHs7yrNDj2FQVNUSLXvY44PRWVDF7a8KYIchA9tHNBYJyyFBg1VgqqFq7d
# RhwJLTC1BdVpnCz2Au4E1xKRXDVMx2m5PX/XOjpoxBzd3OsgfAdnOyiCA+wlgWss
# lPEpJI+2gi/U7wJpTCi2vEGIj+Z4VT9lSWe9tvF0urG8GKq/Ohyj08A9TqVJthNh
# 5OYO6OyoURMLIsi80ewO+hUfF4BMbe4zXbSljw==
# SIG # End signature block
