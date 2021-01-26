
$Section3QueryExplorationTabPage = New-Object System.Windows.Forms.TabPage -Property @{
    Text = "Query Exploration"
    Name = "Query Exploration"
    Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
    Add_click = { Maximize-MonitorJobsTab }
}
$MainBottomTabControl.Controls.Add($Section3QueryExplorationTabPage)


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
    ReadOnly = $true
    Add_MouseEnter = { $Section3QueryExplorationNameTextBox.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $Section3QueryExplorationNameTextBox.size = @{ Width  = $FormScale * 195 } }
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
    ReadOnly = $true
    Add_MouseEnter = { $Section3QueryExplorationWinRMPoShTextBox.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $Section3QueryExplorationWinRMPoShTextBox.size = @{ Width  = $FormScale * 195 } }
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
    ReadOnly = $true
    Add_MouseEnter = { $Section3QueryExplorationWinRMWMITextBox.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $Section3QueryExplorationWinRMWMITextBox.size = @{ Width  = $FormScale * 195 } }
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
    ReadOnly = $true
    Add_MouseEnter = { $Section3QueryExplorationWinRMCmdTextBox.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $Section3QueryExplorationWinRMCmdTextBox.size = @{ Width  = $FormScale * 195 } }
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
    ReadOnly = $true
    Add_MouseEnter = { $Section3QueryExplorationRPCPoShTextBox.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $Section3QueryExplorationRPCPoShTextBox.size = @{ Width  = $FormScale * 195 } }
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
    ReadOnly = $true
    Add_MouseEnter = { $Section3QueryExplorationRPCWMITextBox.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $Section3QueryExplorationRPCWMITextBox.size = @{ Width  = $FormScale * 195 } }
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
    ReadOnly = $true
    Add_MouseEnter = { $Section3QueryExplorationPropertiesPoshTextBox.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $Section3QueryExplorationPropertiesPoshTextBox.size = @{ Width  = $FormScale * 195 } }
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
    ReadOnly = $true
    Add_MouseEnter = { $Section3QueryExplorationPropertiesWMITextBox.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $Section3QueryExplorationPropertiesWMITextBox.size = @{ Width  = $FormScale * 195 } }
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
    ReadOnly = $true
    Add_MouseEnter = { $Section3QueryExplorationWinRSWmicTextBox.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $Section3QueryExplorationWinRSWmicTextBox.size = @{ Width  = $FormScale * 195 } }
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
    ReadOnly = $true
    Add_MouseEnter = { $Section3QueryExplorationWinRSCmdTextBox.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $Section3QueryExplorationWinRSCmdTextBox.size = @{ Width  = $FormScale * 195 } }
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationWinRSCmdTextBox)


$Section3QueryExplorationDescriptionRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Location   = @{ X = $Section3QueryExplorationNameTextBox.Location.X + $Section3QueryExplorationNameTextBox.Size.Width + $($FormScale * 10)
                    Y = $Section3QueryExplorationNameTextBox.Location.Y }
    Size       = @{ Width  = $FormScale * 428
                    Height = $FormScale * 196 }
    Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Multiline  = $True
    ScrollBars = 'Vertical'
    WordWrap   = $True
    ReadOnly   = $true
    ShortcutsEnabled = $true
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationDescriptionRichTextbox)


$Section3QueryExplorationTagWordsLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "Tags"
    Location = @{ X = $Section3QueryExplorationDescriptionRichTextbox.Location.X
                  Y = $Section3QueryExplorationDescriptionRichTextbox.location.Y + $Section3QueryExplorationDescriptionRichTextbox.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 35
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationTagWordsLabel)


$Section3QueryExplorationTagWordsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationTagWordsLabel.Location.X + $Section3QueryExplorationTagWordsLabel.Size.Width + $($FormScale * 5)
                  Y = $Section3QueryExplorationTagWordsLabel.Location.Y - $($FormScale * 3) }
    Size     = @{ Width  = $FormScale * 200
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ReadOnly = $true
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationTagWordsTextBox)


Load-Code "$Dependencies\Code\System.Windows.Forms\CheckBox\Section3QueryExplorationEditCheckBox.ps1"
. "$Dependencies\Code\System.Windows.Forms\CheckBox\Section3QueryExplorationEditCheckBox.ps1"
$Section3QueryExplorationEditCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
    Text      = "Edit"
    Location  = @{ X = $Section3QueryExplorationDescriptionRichTextbox.Location.X + $($FormScale * 255)
                   Y = $Section3QueryExplorationDescriptionRichTextbox.Location.Y + $Section3QueryExplorationDescriptionRichTextbox.Size.Height + $($FormScale * 3) }
    Size      = @{ Height = $FormScale * 25
                   Width  = $FormScale * 50 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,2,1)
    Checked   = $false
    Add_Click = $Section3QueryExplorationEditCheckBoxAdd_Click
}
# Note: The button is added/removed in other parts of the code


Load-Code "$Dependencies\Code\System.Windows.Forms\Button\Section3QueryExplorationSaveButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\Section3QueryExplorationSaveButton.ps1"
$Section3QueryExplorationSaveButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = 'Locked'
    Location  = @{ X = $Section3QueryExplorationEditCheckBox.Location.X + $($FormScale * 50)
                   Y = $Section3QueryExplorationEditCheckBox.Location.Y }
    Size      = @{ Width  = $FormScale * $Column5BoxWidth
                   Height = $FormScale * $Column5BoxHeight }
    Add_Click = $Section3QueryExplorationSaveButtonAdd_Click
}
CommonButtonSettings -Button $Section3QueryExplorationSaveButton
# Note: The button is added/removed in other parts of the code


Load-Code "$Dependencies\Code\System.Windows.Forms\Button\Section3QueryExplorationViewScriptButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\Section3QueryExplorationViewScriptButton.ps1"
$Section3QueryExplorationViewScriptButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = 'View Script'
    Location  = @{ X = $Section3QueryExplorationEditCheckBox.Location.X + $($FormScale * 50)
                   Y = $Section3QueryExplorationEditCheckBox.Location.Y }
    Size      = @{ Width  = $FormScale * $Column5BoxWidth
                   Height = $FormScale * $Column5BoxHeight }
    Add_Click = $Section3QueryExplorationViewScriptButtonAdd_Click
}
CommonButtonSettings -Button $Section3QueryExplorationViewScriptButton
