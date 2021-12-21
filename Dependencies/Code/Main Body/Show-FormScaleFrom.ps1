function Show-FormScaleFrom {
    param(
        [switch]$Relaunch,
        [switch]$Compact,
        [switch]$Extended,
        $FormScale = 1
    )

    # Code to detection current screen resolution
    Add-Type @"
using System;
using System.Runtime.InteropServices;
public class PInvoke {
    [DllImport("user32.dll")] public static extern IntPtr GetDC(IntPtr hwnd);
    [DllImport("gdi32.dll")] public static extern int GetDeviceCaps(IntPtr hdc, int nIndex);
}
"@
    $hdc = [PInvoke]::GetDC([IntPtr]::Zero)
    $ScreenWidth = [PInvoke]::GetDeviceCaps($hdc, 118)
    $ScreenHeight = [PInvoke]::GetDeviceCaps($hdc, 117)


    if ($Compact) {
        $FormOriginalWidth  = 1260
        $FormOriginalHeight = 660
    }
    if ($Extended) {
        $FormOriginalWidth  = 1470
        $FormOriginalHeight = 695
    }

    
    $ResolutionCheckForm = New-Object System.Windows.Forms.Form -Property @{
        Text          = "PoSh-EasyWin - Form Scaling   [$([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)]"
        StartPosition = "CenterScreen"
        Width  = $FormScale * $FormOriginalWidth
        Height = $FormScale * $FormOriginalHeight
        TopMost = $true
        Icon    = [System.Drawing.Icon]::ExtractAssociatedIcon("$script:EasyWinIcon")
        FormBorderStyle =  'Sizable' #  Fixed3D, FixedDialog, FixedSingle, FixedToolWindow, None, Sizable, SizableToolWindow
        Add_Closing = { $This.dispose() }
    }


    $ResolutionCheckMessageLabel = New-Object System.Windows.Forms.Label -Property @{
        Text = "Form scaling has been implemented to provide you with the best user experience
while useing PoSh-EasyWin. This window size displayed will be the basis for the GUI.

Screen Resolution Detected:  $($ScreenWidth) x $($ScreenHeight)

You can also set or delete the value in the following file:
    '$PoShSettings\Form Scaling Modifier.txt'

Use the trackbar below to scale PoSh-EasyWin's interface:"
        Left = 10
        Top  = 10
        Autosize = $true
    }
    $ResolutionCheckForm.Controls.Add($ResolutionCheckMessageLabel)


    $script:ResolutionCheckScalingTrackBar = New-Object System.Windows.Forms.TrackBar -Property @{
        Left = $ResolutionCheckMessageLabel.Location.X
        Top = $ResolutionCheckMessageLabel.Location.Y + $ResolutionCheckMessageLabel.Size.Height + 20
        Width  = $ResolutionCheckForm.Size.Width * 0.8
        Height = 22
        Orientation   = "Horizontal"
        TickFrequency = 1
        TickStyle     = "TopLeft"
        Minimum       = 5
        Maximum       = 30
        Value         = 10
    }
    $script:ResolutionCheckScalingTrackBar.add_ValueChanged({
        $script:ResolutionCheckScalingTrackBarValue = $script:ResolutionCheckScalingTrackBar.Value / 10
        $ResolutionCheckSelectLabel.Text = $script:ResolutionCheckScalingTrackBarValue
        $FormScale = $script:ResolutionCheckScalingTrackBarValue
        $ResolutionCheckForm.Width  = $FormScale * $FormOriginalWidth
        $ResolutionCheckForm.Height = $FormScale * $FormOriginalHeight
    })
    $ResolutionCheckForm.Controls.Add($script:ResolutionCheckScalingTrackBar)


    $ResolutionCheckSelectLabel = New-Object System.Windows.Forms.Label -Property @{
        Text = $script:ResolutionCheckScalingTrackBar.Value / 10
        Left = $script:ResolutionCheckScalingTrackBar.Location.X + $script:ResolutionCheckScalingTrackBar.Size.Width + ($FormScale * 10)
        Top  = $script:ResolutionCheckScalingTrackBar.Location.Y
        AutoSize = $true
    }
    $ResolutionCheckForm.Controls.Add($ResolutionCheckSelectLabel)

    function FormScaleButtonSettings {
        param($Button)
        $Button.ForeColor = "Black"
        $Button.Flatstyle = 'Flat'
        $Button.BackColor = 'LightGray'
        $Button.UseVisualStyleBackColor = $true
        $Button.FlatAppearance.BorderColor        = [System.Drawing.Color]::Gray
        $Button.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::DimGray
        $Button.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::DarkGray
    }


    $ResolutionCheckCancelButton = New-Object System.Windows.Forms.Button -Property @{
        Text   = 'Cancel'
        Left = $script:ResolutionCheckScalingTrackBar.Location.X
        Top  = $script:ResolutionCheckScalingTrackBar.Location.Y + $script:ResolutionCheckScalingTrackBar.Size.Height
        AutoSize = $true
        Add_click = { $ResolutionCheckForm.Close() }
    }
    $ResolutionCheckForm.Controls.Add($ResolutionCheckCancelButton)
    FormScaleButtonSettings -Button $ResolutionCheckCancelButton


    $script:ResolutionSetOkay = $false
    $ResolutionCheckOkayButton = New-Object System.Windows.Forms.Button -Property @{
        Text   = 'Okay'
        Left   = $ResolutionCheckCancelButton.Left + $ResolutionCheckCancelButton.Width + 10
        Top    = $ResolutionCheckCancelButton.Top
        AutoSize = $true
        Add_Click = {
            $script:ResolutionSetOkay = $true
            $script:ResolutionCheckScalingTrackBar.Value / 10 | Out-File "$PoShSettings\Form Scaling Modifier.txt"
            if ($Relaunch) { $script:RelaunchEasyWin = $true }
            $ResolutionCheckForm.Close()
        }
    }
    $ResolutionCheckForm.Controls.Add($ResolutionCheckOkayButton)
    FormScaleButtonSettings -Button $ResolutionCheckOkayButton


    $ResolutionCheckRelaunchMessageLabel = New-Object System.Windows.Forms.Label -Property @{
        Left = $ResolutionCheckOkayButton.Left + $ResolutionCheckOkayButton.Width + 10
        Top  = $ResolutionCheckOkayButton.Top
        Autosize  = $true
        ForeColor = 'Red'
    }
    $ResolutionCheckForm.Controls.Add($ResolutionCheckRelaunchMessageLabel)
    if ($Relaunch) {$ResolutionCheckRelaunchMessageLabel.text = "Note: This will relaunch the PoSh-EasyWin GUI." }

    $ResolutionCheckForm.ShowDialog()
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU7zpUJNYJ+BFKKg7PMwWxbf9M
# urWgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUjrafJZTjNTKszzPhiU4xskLXJT0wDQYJKoZI
# hvcNAQEBBQAEggEAESa0tw1PDlnWQRnCJRuQ8HdM3RINTzlSnKyhfoHOePDh5HTR
# KbHqxXBvdchIbJadBSWsppDvRRiWDy6jZz2ws519yGMaV4TWhFVnzN5APv+Uu49o
# eF0+aamVA6q5P8sac1EX0THqAfQX+9KKrCUoKFSuPCWvX0P18CQfXOSE8cjPslQ/
# mZMmlLx2iejYgZvH4j4iXMKSwhX5AFtl3WifoGBdK/0VyS4AX4YVIZ0IcFV8/8BO
# FhaCRp9fSYeBTQ6iwO2YV0D8e7lpEU6wnFpnY9JfGdVoMcGdBCrC1/p/UaPteRxj
# Yn/lfXIWzu+4Nff1deFtSQK6c9mYDNeqCXupUg==
# SIG # End signature block
