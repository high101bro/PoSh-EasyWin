function script:Launch-FormScaleGUI {
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
        Icon    = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUjaCBkbl3HnFpXD9/upvPz4YP
# pkegggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUTeKKWVaeO6Ql61JQqlQEcRwZPdYwDQYJKoZI
# hvcNAQEBBQAEggEAPnMp8Rud6z5Tsld6/1izUoVwfcQJBWSvlxjFr9wMRaHc+wvE
# F2az6QiF2HE2jQKj22tRehYZze+NNhkTPdN3ityErAY4Ebhhi27WulElcZG2eQAT
# OyunECYlfYHXsJmhIoY04KMYzcZcoDjkkcu1g+mE/bsRwVNcBvFX5KGspVEw7b/w
# U9oVqEwu311VAqDxlrcYj5e6hhftWdkSWUDFJPQGP1GVMvjLkNssHxt9FJQ7eQP7
# BOcnCtoSRUv4K7fb7gglivqR9cw/HlZnrjnB6rvdoo85wZcz/kRug+8cqStwQqig
# wKq20MBa2QWZwPNmuI3U+7GWdmBpQl0dioSwFQ==
# SIG # End signature block
