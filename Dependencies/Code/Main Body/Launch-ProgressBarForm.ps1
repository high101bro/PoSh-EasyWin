function Launch-ProgressBarForm {
    param(
        $FormTitle,
        $ProgressBarImage = "$Dependencies\Images\PoSh-EasyWin Image 01.png",
        $ScriptBlockProgressBarInput,
        [switch]$ShowImage
    )
    <#
    https://flamingtext.com/logo/Design-Style
    https://www11.flamingtext.com/net-fu/dynamic.cgi?script=style-logo&text=PoSh-EasyWin&fontname=Black+Ops+One&fillTextColor=%23006fff&fillOutlineColor=%2320d
    Font: Display --> Black Ops One
    #>
    $script:ProgressBarSelectionForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = $FormTitle
        Width  = $FormScale * 350
        Height = $FormScale * 180
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

    $script:ProgressBarSelectionForm.Topmost = $false
    $script:ProgressBarSelectionForm.ShowDialog()
}

