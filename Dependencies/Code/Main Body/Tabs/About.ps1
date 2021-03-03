
$Section3AboutTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text = "About"
    Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
    Add_click = { Minimize-MonitorJobsTab }
}
$MainBottomTabControl.Controls.Add($Section3AboutTab)


$PoShEasyWinLogoPictureBox = New-Object Windows.Forms.PictureBox -Property @{
    Text     = "PoSh-EasyWin Image"
    Location = @{ X = $FormScale * 3
                  Y = $FormScale * 10 }
    Size     = @{ Width  = $FormScale * 355
                  Height = $FormScale * 35 }
    Image = [System.Drawing.Image]::Fromfile("$Dependencies\Images\PoSh-EasyWin Image 01.png")
    SizeMode = 'StretchImage'
}
$Section3AboutTab.Controls.Add($PoShEasyWinLogoPictureBox)


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\PoShEasyWinLicenseAndAboutButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\PoShEasyWinLicenseAndAboutButton.ps1"
$PoShEasyWinLicenseAndAboutButton = New-Object Windows.Forms.Button -Property @{
    Text     = "GNU General Public License v3"
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Location = @{ X = $FormScale * 540
                  Y = $FormScale * 22 }
    Size     = @{ Width  = $FormScale * 200
                  Height = $FormScale * 22 }
    Add_Click      = $PoShEasyWinLicenseAndAboutButtonAdd_Click
    Add_MouseHover = $PoShEasyWinLicenseAndAboutButtonAdd_MouseHover
}
$Section3AboutTab.Controls.Add($PoShEasyWinLicenseAndAboutButton)
CommonButtonSettings -Button $PoShEasyWinLicenseAndAboutButton


$Section1AboutSubTabRichTextBox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Text     = $(Get-Content "$Dependencies\About PoSh-EasyWin.txt" -raw)
    Font     = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    Location = @{ X = $FormScale * 0
                  Y = $FormScale * $PoShEasyWinLogoPictureBox.Location.Y + $PoShEasyWinLogoPictureBox.Size.Height + 2}
    Size     = @{ Width  = $FormScale * 742
                  Height = $FormScale * 175 }
    MultiLine  = $True
    ScrollBars = "Vertical"
    WordWrap   = $true
    ReadOnly   = $True
    BackColor  = 'White'
    ShortcutsEnabled = $true
}
$Section3AboutTab.Controls.Add($Section1AboutSubTabRichTextBox)
