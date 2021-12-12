
$Section3QueryExplorationTabPage = New-Object System.Windows.Forms.TabPage -Property @{
    Text = "Command Exploration  "
    Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
    Add_click = { script:Minimize-MonitorJobsTab }
    ImageIndex = 5
}
$InformationTabControl.Controls.Add($Section3QueryExplorationTabPage)


$Section3QueryExplorationNameLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "Query Name:"
    Location = @{ X = $FormScale * 0
                  Y = $FormScale * 6 }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section3QueryExplorationNameTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationNameLabel.Location.X + $Section3QueryExplorationNameLabel.Size.Width + $($FormScale * 5)
                  Y = $FormScale * 3 }
    Size     = @{ Width  = $FormScale * 195
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Backcolor = 'White'
    ReadOnly = $true
    Add_MouseEnter = { $This.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $This.size = @{ Width  = $FormScale * 195 } }
}
$Section3QueryExplorationTabPage.Controls.AddRange(@($Section3QueryExplorationNameLabel,$Section3QueryExplorationNameTextBox))


$Section3QueryExplorationWinRMPoShLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "WinRM PoSh:"
    Location = @{ X = 0
                  Y = $Section3QueryExplorationNameLabel.location.Y + $Section3QueryExplorationNameLabel.Size.Height }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section3QueryExplorationWinRMPoShTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationWinRMPoShLabel.Location.X + $Section3QueryExplorationWinRMPoShLabel.Size.Width + $($FormScale * 5)
                  Y = $Section3QueryExplorationWinRMPoShLabel.Location.Y - $($FormScale * 3) }
    Size     = @{ Width  = $FormScale * 195
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Backcolor = 'White'
    ReadOnly = $true
    Add_MouseEnter = { $This.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $This.size = @{ Width  = $FormScale * 195 } }
}
$Section3QueryExplorationTabPage.Controls.AddRange(@($Section3QueryExplorationWinRMPoShLabel,$Section3QueryExplorationWinRMPoShTextBox))


$Section3QueryExplorationWinRMWMILabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "WinRM WMI:"
    Location = @{ X = 0
                  Y = $Section3QueryExplorationWinRMPoShLabel.location.Y + $Section3QueryExplorationWinRMPoShLabel.Size.Height }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationWinRMWMILabel)


$Section3QueryExplorationWinRMWMITextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationWinRMWMILabel.Location.X + $Section3QueryExplorationWinRMWMILabel.Size.Width + $($FormScale * 5)
                  Y = $Section3QueryExplorationWinRMWMILabel.Location.Y - $($FormScale * 3) }
    Size     = @{ Width  = $FormScale * 195
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Backcolor = 'White'
    ReadOnly = $true
    Add_MouseEnter = { $This.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $This.size = @{ Width  = $FormScale * 195 } }
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationWinRMWMITextBox)


$Section3QueryExplorationWinRMCmdLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "WinRM Cmd:"
    Location = @{ X = 0
                  Y = $Section3QueryExplorationWinRMWMILabel.location.Y + $Section3QueryExplorationWinRMWMILabel.Size.Height }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationWinRMCmdLabel)


$Section3QueryExplorationWinRMCmdTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationWinRMCmdLabel.Location.X + $Section3QueryExplorationWinRMCmdLabel.Size.Width + $($FormScale * 5)
                  Y = $Section3QueryExplorationWinRMCmdLabel.Location.Y - $($FormScale * 3) }
    Size     = @{ Width  = $FormScale * 195
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Backcolor = 'White'
    ReadOnly = $true
    Add_MouseEnter = { $This.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $This.size = @{ Width  = $FormScale * 195 } }
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationWinRMCmdTextBox)


$Section3QueryExplorationRPCPoShLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "RPC/DCOM PoSh:"
    Location = @{ X = 0
                  Y = $Section3QueryExplorationWinRMCmdLabel.location.Y + $Section3QueryExplorationWinRMCmdLabel.Size.Height }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationRPCPoShLabel)


$Section3QueryExplorationRPCPoShTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationRPCPoShLabel.Location.X + $Section3QueryExplorationRPCPoShLabel.Size.Width + $($FormScale * 5)
                  Y = $Section3QueryExplorationRPCPoShLabel.Location.Y - $($FormScale * 3) }
    Size     = @{ Width  = $FormScale * 195
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Backcolor = 'White'
    ReadOnly = $true
    Add_MouseEnter = { $This.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $This.size = @{ Width  = $FormScale * 195 } }
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationRPCPoShTextBox)


$Section3QueryExplorationRPCWMILabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "RPC/DCOM WMI:"
    Location = @{ X = 0
                  Y = $Section3QueryExplorationRPCPoShLabel.location.Y + $Section3QueryExplorationRPCPoShLabel.Size.Height }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationRPCWMILabel)


$Section3QueryExplorationRPCWMITextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationRPCWMILabel.Location.X + $Section3QueryExplorationRPCWMILabel.Size.Width + $($FormScale * 5)
                  Y = $Section3QueryExplorationRPCWMILabel.Location.Y - $($FormScale * 3) }
    Size     = @{ Width  = $FormScale * 195
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Backcolor = 'White'
    ReadOnly = $true
    Add_MouseEnter = { $This.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $This.size = @{ Width  = $FormScale * 195 } }
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationRPCWMITextBox)


$Section3QueryExplorationPropertiesPoshLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "Properties PoSh:"
    Location = @{ X = 0
                  Y = $Section3QueryExplorationRPCWMILabel.location.Y + $Section3QueryExplorationRPCWMILabel.Size.Height }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationPropertiesPoshLabel)


$Section3QueryExplorationPropertiesPoshTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationPropertiesPoshLabel.Location.X + $Section3QueryExplorationPropertiesPoshLabel.Size.Width + $($FormScale * 5)
                  Y = $Section3QueryExplorationPropertiesPoshLabel.Location.Y - $($FormScale * 3) }
    Size     = @{ Width  = $FormScale * 195
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Backcolor = 'White'
    ReadOnly = $true
    Add_MouseEnter = { $This.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $This.size = @{ Width  = $FormScale * 195 } }
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationPropertiesPoshTextBox)


$Section3QueryExplorationPropertiesWMILabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "Properties WMI:"
    Location = @{ X = 0
                  Y = $Section3QueryExplorationPropertiesPoshLabel.location.Y + $Section3QueryExplorationPropertiesPoshLabel.Size.Height }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationPropertiesWMILabel)


$Section3QueryExplorationPropertiesWMITextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationPropertiesWMILabel.Location.X + $Section3QueryExplorationPropertiesWMILabel.Size.Width + $($FormScale * 5)
                  Y = $Section3QueryExplorationPropertiesWMILabel.Location.Y - $($FormScale * 3) }
    Size     = @{ Width  = $FormScale * 195
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Backcolor = 'White'
    ReadOnly = $true
    Add_MouseEnter = { $This.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $This.size = @{ Width  = $FormScale * 195 } }
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationPropertiesWMITextBox)


$Section3QueryExplorationWinRSWmicLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "WinRS WMIC:"
    Location = @{ X = 0
                  Y = $Section3QueryExplorationPropertiesWMILabel.location.Y + $Section3QueryExplorationPropertiesWMILabel.Size.Height }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationWinRSWmicLabel)


$Section3QueryExplorationWinRSWmicTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationWinRSWmicLabel.Location.X + $Section3QueryExplorationWinRSWmicLabel.Size.Width + $($FormScale * 5)
                  Y = $Section3QueryExplorationWinRSWmicLabel.Location.Y - $($FormScale * 3) }
    Size     = @{ Width  = $FormScale * 195
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Backcolor = 'White'
    ReadOnly = $true
    Add_MouseEnter = { $This.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $This.size = @{ Width  = $FormScale * 195 } }
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationWinRSWmicTextBox)


$Section3QueryExplorationWinRSCmdLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "WinRS Cmd:"
    Location = @{ X = 0
                  Y = $Section3QueryExplorationWinRSWmicLabel.location.Y + $Section3QueryExplorationWinRSWmicLabel.Size.Height }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationWinRSCmdLabel)


$Section3QueryExplorationWinRSCmdTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationWinRSCmdLabel.Location.X + $Section3QueryExplorationWinRSCmdLabel.Size.Width + $($FormScale * 5)
                  Y = $Section3QueryExplorationWinRSCmdLabel.Location.Y - $($FormScale * 3) }
    Size     = @{ Width  = $FormScale * 195
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Backcolor = 'White'
    ReadOnly = $true
    Add_MouseEnter = { $This.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $This.size = @{ Width  = $FormScale * 195 } }
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationWinRSCmdTextBox)


















$Section3QueryExplorationSmbPoshLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "SMB PoSh:"
    Location = @{ X = 0
                  Y = $Section3QueryExplorationWinRSCmdLabel.location.Y + $Section3QueryExplorationWinRSCmdLabel.Size.Height }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationSmbPoshLabel)


$Section3QueryExplorationSmbPoshTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationSmbPoshLabel.Location.X + $Section3QueryExplorationSmbPoshLabel.Size.Width + $($FormScale * 5)
                  Y = $Section3QueryExplorationSmbPoshLabel.Location.Y - $($FormScale * 3) }
    Size     = @{ Width  = $FormScale * 195
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Backcolor = 'White'
    ReadOnly = $true
    Add_MouseEnter = { $This.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $this.size = @{ Width  = $FormScale * 195 } }
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationSmbPoshTextBox)


$Section3QueryExplorationSmbWmiLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "SMB WMI:"
    Location = @{ X = 0
                  Y = $Section3QueryExplorationSmbPoshLabel.location.Y + $Section3QueryExplorationSmbPoshLabel.Size.Height }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationSmbWmiLabel)


$Section3QueryExplorationSmbWmiTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationSmbWmiLabel.Location.X + $Section3QueryExplorationSmbWmiLabel.Size.Width + $($FormScale * 5)
                  Y = $Section3QueryExplorationSmbWmiLabel.Location.Y - $($FormScale * 3) }
    Size     = @{ Width  = $FormScale * 195
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Backcolor = 'White'
    ReadOnly = $true
    Add_MouseEnter = { $This.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $this.size = @{ Width  = $FormScale * 195 } }
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationSmbWmiTextBox)


$Section3QueryExplorationSmbCmdLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "SMB Cmd:"
    Location = @{ X = 0
                  Y = $Section3QueryExplorationSmbWmiLabel.location.Y + $Section3QueryExplorationSmbWmiLabel.Size.Height }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationSmbCmdLabel)


$Section3QueryExplorationSmbCmdTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationSmbCmdLabel.Location.X + $Section3QueryExplorationSmbCmdLabel.Size.Width + $($FormScale * 5)
                  Y = $Section3QueryExplorationSmbCmdLabel.Location.Y - $($FormScale * 3) }
    Size     = @{ Width  = $FormScale * 195
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Backcolor = 'White'
    ReadOnly = $true
    Add_MouseEnter = { $This.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $this.size = @{ Width  = $FormScale * 195 } }
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationSmbCmdTextBox)



$Section3QueryExplorationSshLinuxLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "SSH Linux:"
    Location = @{ X = 0
                  Y = $Section3QueryExplorationSmbCmdLabel.location.Y + $Section3QueryExplorationSmbCmdLabel.Size.Height }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationSshLinuxLabel)


$Section3QueryExplorationSshLinuxTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationSshLinuxLabel.Location.X + $Section3QueryExplorationSshLinuxLabel.Size.Width + $($FormScale * 5)
                  Y = $Section3QueryExplorationSshLinuxLabel.Location.Y - $($FormScale * 3) }
    Size     = @{ Width  = $FormScale * 195
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Backcolor = 'White'
    ReadOnly = $true
    Add_MouseEnter = { $This.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $this.size = @{ Width  = $FormScale * 195 } }
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationSshLinuxTextBox)






























$Section3QueryExplorationDescriptionPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location   = @{ X = $Section3QueryExplorationNameTextBox.Location.X + $Section3QueryExplorationNameTextBox.Size.Width + $($FormScale * 10)
                    Y = $Section3QueryExplorationNameTextBox.Location.Y }
    Size       = @{ Width  = $FormScale * 428
                    Height = $FormScale * 300 }
    BorderStyle = 'FixedSingle'
}
            $Section3QueryExplorationDescriptionRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
                Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                Backcolor   = 'White'
                Multiline   = $True
                ScrollBars  = 'Vertical'
                WordWrap    = $True
                ReadOnly    = $true
                Dock        = 'Fill'
                BorderStyle = 'None'
                ShortcutsEnabled = $true
            }
            $Section3QueryExplorationDescriptionPanel.Controls.Add($Section3QueryExplorationDescriptionRichTextbox)
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationDescriptionPanel)


$Section3QueryExplorationTagWordsLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "Tags: "
    Left     = $Section3QueryExplorationDescriptionPanel.Location.X + ($FormScale * 1)
    Top      = $Section3QueryExplorationDescriptionPanel.location.Y + $Section3QueryExplorationDescriptionPanel.Size.Height + $($FormScale * 5)
    AutoSize = $true
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationTagWordsLabel)


$Section3QueryExplorationTagWordsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left   = $Section3QueryExplorationTagWordsLabel.Left + $Section3QueryExplorationTagWordsLabel.Width + $($FormScale * 5)
    Top    = $Section3QueryExplorationTagWordsLabel.Top
    Width  = $FormScale * 200
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Backcolor = 'White'
    ReadOnly = $true
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationTagWordsTextBox)


Load-Code "$Dependencies\Code\System.Windows.Forms\CheckBox\Section3QueryExplorationEditCheckBox.ps1"
. "$Dependencies\Code\System.Windows.Forms\CheckBox\Section3QueryExplorationEditCheckBox.ps1"
$Section3QueryExplorationEditCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
    Text  = "Edit"
    Left  = $FormScale * 580
    Top   = $Section3QueryExplorationTagWordsTextBox.Top
    Font  = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,2,1)
    Checked   = $false
    AutoSize  = $true
    Add_Click = $Section3QueryExplorationEditCheckBoxAdd_Click
}
# Note: The button is added/removed in other parts of the code


Load-Code "$Dependencies\Code\System.Windows.Forms\Button\Section3QueryExplorationSaveButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\Section3QueryExplorationSaveButton.ps1"
$Section3QueryExplorationSaveButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Locked'
    Left   = $FormScale * 638
    Top    = $Section3QueryExplorationEditCheckBox.Top
    Width  = $FormScale * 100
    Height = $FormScale * 22
    Add_Click = $Section3QueryExplorationSaveButtonAdd_Click
}
Apply-CommonButtonSettings -Button $Section3QueryExplorationSaveButton
# Note: The button is added/removed in other parts of the code


Load-Code "$Dependencies\Code\System.Windows.Forms\Button\Section3QueryExplorationViewScriptButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\Section3QueryExplorationViewScriptButton.ps1"
$Section3QueryExplorationViewScriptButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'View Script'
    Left   = $FormScale * 500
    Top    = $Section3QueryExplorationEditCheckBox.Top
    Width  = $FormScale * $Column5BoxWidth
    Height = $FormScale * $Column5BoxHeight
    Add_Click = $Section3QueryExplorationViewScriptButtonAdd_Click
}
Apply-CommonButtonSettings -Button $Section3QueryExplorationViewScriptButton

# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUMeCW3fvMI9Y0BdnBRjI24af6
# tdigggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU8IZ9WrqwCsp5KXd1FsNgQWlsAWUwDQYJKoZI
# hvcNAQEBBQAEggEAK6dAwWrILwO95I74WALeNSRrRTjC4/hZW4m16VMA9bJFr9+g
# 38+2fkKiQL98Ql2ThVq7U94ZYvq6mq1NzWQhj/hd8Al4Zguo7qpz7cqMdrjzwxEn
# j5KEDmCN15coQDMyCE0Uh6KrYZbnMCj3cUyNdYtR3nHFle6icRW8JAQ5zP1CGa/D
# jyXTVTo70iHc59Vy4FtFc1wWtaYh3kjaqovZL3AmBeHZ/pXi6cHewhWi/XzyruSU
# anFNDxgC0kT4U71kfxIqUR/0gqX5tZFUTFx4rI3k8c9Q4jBdiDLsU4f3xZaJEibN
# +5t0QtbI0OTPmXbxdgyM4/6BA44oxixsG4tsJg==
# SIG # End signature block
