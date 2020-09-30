$FormScale = 2.5
$Font = 'Courier new'
$Dependencies = 'C:\Users\Dan\Documents\GitHub\PoSh-EasyWin--BETA-Build\PoSh-EasyWin\Dependencies'
$EasyWinIcon = "$Dependencies\Images\favicon.ico"



$script:ProgressBarSelectionForm = New-Object System.Windows.Forms.Form -Property @{
    Text   = 'PoSh-EasyWIn - Setup and Extraction'
    Width  = $FormScale * 600
    Height = $FormScale * 400
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
    Add_Shown     = {}
    Add_Closing = { $This.dispose() }
}

$PoShEasyWinLogoLoadingPictureBox = New-Object Windows.Forms.PictureBox -Property @{
    Text   = "PoSh-EasyWin Image"
    Left   = $FormScale * 10
    Top    = $FormScale * 10
    Width  = $FormScale * 285
    Height = $FormScale * 25
    Image  = [System.Drawing.Image]::Fromfile("$Dependencies\Images\PoSh-EasyWin Image 01.png")
    SizeMode = 'StretchImage'
}
$script:ProgressBarSelectionForm.Controls.Add($PoShEasyWinLogoLoadingPictureBox)

$script:ProgressBarMainLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = 'PowerShell - Endpoint Analysis Solution Your Windows Intranet Needs'
    Left   = $FormScale * 10
    Top    = $PoShEasyWinLogoLoadingPictureBox.Top + $PoShEasyWinLogoLoadingPictureBox.Height + ($FormScale * 5)
    Width  = $script:ProgressBarSelectionForm.Width - ($FormScale * 35)
    Height = $FormScale * 25
    Font   = New-Object System.Drawing.Font("$font",$($FormScale * 11),0,0,0)
}
$script:ProgressBarSelectionForm.Controls.Add($script:ProgressBarMainLabel)


$ProgressBarFormProgressBar = New-Object System.Windows.Forms.ProgressBar -Property @{
    Style    = "Continuous"
    #Maximum = 10
    Minimum  = 0
    Left     = $FormScale * 10
    Top      = $script:ProgressBarMainLabel.Top + $script:ProgressBarMainLabel.Height + ($FormScale * 5)
    Width    = $script:ProgressBarSelectionForm.Width - ($FormScale * 35)
    Height   = $FormScale * 10
    Value    = 0
}
$script:ProgressBarSelectionForm.Controls.Add($ProgressBarFormProgressBar)


$InstallationLocationLabel = New-Object System.Windows.Forms.Label -Property @{
    Text    = 'Installation Directory. Files will be installed and saved at this location.'
    Left    = $FormScale * 8
    Top     = $ProgressBarFormProgressBar.Top + $ProgressBarFormProgressBar.Height + ($FormScale * 10)
    Width   = $ProgressBarFormProgressBar.Width
    Height  = $FormScale * 22
    Font    = New-Object System.Drawing.Font("$font",$($FormScale * 11),0,0,0)
    Padding = 5

}
$script:ProgressBarSelectionForm.Controls.Add($InstallationLocationLabel)


$InstallationLocationTextbox = New-Object System.Windows.Forms.Textbox -Property @{
    Text   = "C:$($env:HOMEPATH)\Documents\PoSh-EasyWin\"
    Left   = $ProgressBarFormProgressBar.Left
    Top    = $InstallationLocationLabel.Top + $InstallationLocationLabel.Height
    Width  = $ProgressBarFormProgressBar.Width
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$font",$($FormScale * 11),0,0,0)
}
$script:ProgressBarSelectionForm.Controls.Add($InstallationLocationTextbox)


$ShotcutCreationLabel = New-Object System.Windows.Forms.CheckBox -Property @{
    Text    = 'Create a desktop shortcut to launch PoSh-EasyWin from. The orginal file and directory is easily access via a button within the GUI.'
    Left    = $InstallationLocationLabel.left+ ($FormScale * 2)
    Top     = $InstallationLocationTextbox.Top + $InstallationLocationTextbox.Height + ($FormScale * 5)
    Width   = $ProgressBarFormProgressBar.Width
    Height  = $FormScale * 32
    Font    = New-Object System.Drawing.Font("$font",$($FormScale * 11),0,0,0)
    Checked = $true
}
$script:ProgressBarSelectionForm.Controls.Add($ShotcutCreationLabel)


$CreateCredentialLabel = New-Object System.Windows.Forms.CheckBox -Property @{
    Text    = 'Setup a remote credential before launch. Later you can change, add, or delete credentials to use if necessary.'
    Left    = $InstallationLocationLabel.left
    Top     = $ShotcutCreationLabel.Top + $ShotcutCreationLabel.Height
    Width   = $ProgressBarFormProgressBar.Width
    Height  = $FormScale * 32
    Font    = New-Object System.Drawing.Font("$font",$($FormScale * 11),0,0,0)
    Checked = $true
}
$script:ProgressBarSelectionForm.Controls.Add($CreateCredentialLabel)


$ShowToolTipLabel = New-Object System.Windows.Forms.CheckBox -Property @{
    Text    = "Show tooltips when you hover over areas. They provide insight into what is happening, examples, and capabilities."
    Left    = $CreateCredentialLabel.left
    Top     = $CreateCredentialLabel.Top + $CreateCredentialLabel.Height
    Width   = $ProgressBarFormProgressBar.Width - ($FormScale * 10)
    Height  = $FormScale * 32
    Font    = New-Object System.Drawing.Font("$font",$($FormScale * 11),0,0,0)
    Checked = $true
}
$script:ProgressBarSelectionForm.Controls.Add($ShowToolTipLabel)


$EnableVoiceCompletionLabel = New-Object System.Windows.Forms.CheckBox -Property @{
    Text    = 'Enabled voice audio completion message. The message spoken notifies the user of completion rather than a single audible tone.'
    Left    = $ShowToolTipLabel.left
    Top     = $ShowToolTipLabel.Top + $ShowToolTipLabel.Height
    Width   = $ProgressBarFormProgressBar.Width - ($FormScale * 10)
    Height  = $FormScale * 32
    Font    = New-Object System.Drawing.Font("$font",$($FormScale * 11),0,0,0)
    Checked = $false
}
$script:ProgressBarSelectionForm.Controls.Add($EnableVoiceCompletionLabel)


$JobTimeoutComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text    = '120'
    Left    = $InstallationLocationLabel.left+ ($FormScale * 2)
    Top     = $EnableVoiceCompletionLabel.Top + $EnableVoiceCompletionLabel.Height + ($FormScale * 8)
    Width   = 120
    Height  = $FormScale * 32
    Font    = New-Object System.Drawing.Font("$font",$($FormScale * 11),0,0,0)
}
$JobTimesAvailable = @(15,30,45,60,120,180,240,300,600)
ForEach ($Item in $JobTimesAvailable) { $script:JobTimeoutComboBox.Items.Add($Item) }
$script:ProgressBarSelectionForm.Controls.Add($JobTimeoutComboBox)


$JobTimeoutLabel = New-Object System.Windows.Forms.Label -Property @{
    Text    = 'Default timeout in seconds for jobs. Depending on the method used to query hosts, queries are started within jobs and in some scenarios can hang.'
    Left    = $JobTimeoutComboBox.left + $JobTimeoutComboBox.Width
    Top     = $JobTimeoutComboBox.Top - ($FormScale * 5)
    Width   = $ProgressBarFormProgressBar.Width - ($FormScale * 15)
    Height  = $FormScale * 32
    Font    = New-Object System.Drawing.Font("$font",$($FormScale * 11),0,0,0)
}
$script:ProgressBarSelectionForm.Controls.Add($JobTimeoutLabel)


$script:ProgressBarSelectionForm.ShowDialog()


