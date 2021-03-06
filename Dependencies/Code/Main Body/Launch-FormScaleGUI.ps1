function Launch-FormScaleGUI {
    param([switch]$Relaunch)

    # Code to detection current screen resolution
    Add-Type @"
using System;
using System.Runtime.InteropServices;
public class PInvoke {
    [DllImport("user32.dll")] public static extern IntPtr GetDC(IntPtr hwnd);
    [DllImport("gdi32.dll")] public static extern int GetDeviceCaps(IntPtr hdc, int nIndex);
}
"@
    $hdc    = [PInvoke]::GetDC([IntPtr]::Zero)
    $ScreenWidth  = [PInvoke]::GetDeviceCaps($hdc, 118)
    $ScreenHeight = [PInvoke]::GetDeviceCaps($hdc, 117)


    $FormOriginalWidth  = 1260
    $FormOriginalHeight = 660
    $FormScale = 1

    
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


