
$SmithRegistryTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text     = "Registry"
    Location = @{ X = $FormScale * $SmithRegistryRightPosition
                  Y = $FormScale * $SmithRegistryDownPosition }
    Size     = @{ Width  = $FormScale * 450
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
}
$MainLeftSMITHTabControl.Controls.Add($SmithRegistryTab)


$SmithRegistrySearchCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Registry Search (WinRM)"
    Location = @{ X = $FormScale * 3
                  Y = $FormScale * 15 }
    Size     = @{ Width  = $FormScale * 230
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = $SmithRegistrySearchCheckboxAdd_Click
}
$SmithRegistryTab.Controls.Add($SmithRegistrySearchCheckbox)


$SmithRegistrySearchRecursiveCheckbox = New-Object System.Windows.Forms.Checkbox -Property @{
    Text     = "Recursive Search"
    Location = @{ X = $SmithRegistrySearchCheckbox.Size.Width + $($FormScale * 85)
                  Y = $SmithRegistrySearchCheckbox.Location.Y + $($FormScale * 3) }
    Size     = @{ Width  = $FormScale * 200
                  Height = $FormScale * 22 }
    Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor  = "Black"
}
$SmithRegistryTab.Controls.Add($SmithRegistrySearchRecursiveCheckbox)
$script:SmithRegistrySelected = ''


$SmithRegistrySearchLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = "The collection time is depenant on the number of paths and queries entered, and more so if recursive is selected."
    Location = @{ X = $SmithRegistrySearchCheckbox.Location.X
                  Y = $SmithRegistrySearchRecursiveCheckbox.Location.Y + $SmithRegistrySearchRecursiveCheckbox.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 300
                  Height = $FormScale * 40 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = "Black"
}
$SmithRegistryTab.Controls.Add($SmithRegistrySearchLabel)


$SmithRegistrySearchReferenceButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Select Location"
    Location = @{ X = $SmithRegistrySearchLabel.Location.X + $SmithRegistrySearchLabel.Size.Width + $($FormScale * 30)
                  Y = $SmithRegistrySearchLabel.Location.Y }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Add_Click = {
        Import-Csv "$Dependencies\Reference Registry Locations.csv" | Out-GridView -Title 'PoSh-EasyWin Registry Reference Selection' -PassThru | Set-Variable -Name RegistryReferenceSelected
        $script:SmithRegistrySearchDirectoryRichTextbox.text = ''
        foreach ($SmithRegistry in $SmithRegistryReferenceSelected) { $script:SmithRegistrySearchDirectoryRichTextbox.Lines += $SmithRegistry.Location}
    }
}
$SmithRegistryTab.Controls.Add($SmithRegistrySearchReferenceButton)
CommonButtonSettings -Button $SmithRegistrySearchReferenceButton


$script:SmithRegistrySearchDirectoryRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Text     = "Enter Registry Paths; One Per Line"
    Location = @{ X = $SmithRegistrySearchLabel.Location.X
                  Y = $SmithRegistrySearchLabel.Location.Y + $SmithRegistrySearchLabel.Size.Height }
    Size     = @{ Width  = $FormScale * 430
                  Height = $FormScale * 80 }
    MultiLine     = $True
    ShortcutsEnabled = $true
    Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_MouseEnter = $SmithRegistrySearchDirectoryRichTextboxAdd_MouseEnter
    Add_MouseLeave = $SmithRegistrySearchDirectoryRichTextboxAdd_MouseLeave
    Add_MouseHover = $SmithRegistrySearchDirectoryRichTextboxAdd_MouseHover
}
$SmithRegistryTab.Controls.Add($script:SmithRegistrySearchDirectoryRichTextbox)


$SmithRegistryKeyNameCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Key Name (Supports RegEx)"
    Location = @{ X = $script:SmithRegistrySearchDirectoryRichTextbox.Location.X
                  Y = $script:SmithRegistrySearchDirectoryRichTextbox.Location.Y + $script:SmithRegistrySearchDirectoryRichTextbox.Size.Height + $($FormScale * 10) }
    Size     = @{ Width  = $FormScale * 300
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click = $SmithRegistryKeyNameCheckBoxAdd_Click
}
$SmithRegistryTab.Controls.Add($SmithRegistryKeyNameCheckbox)


$SmithSupportsRegexButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Regex Examples"
    Location = @{ X = $SmithRegistryKeyNameCheckbox.Location.X + $SmithRegistryKeyNameCheckbox.Size.Width + $($FormScale * 28)
                  Y = $SmithRegistryKeyNameCheckbox.Location.Y }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Add_Click = { Import-Csv "$Dependencies\Reference RegEx Examples.csv" | Out-GridView }
}
$SmithRegistryTab.Controls.Add($SmithSupportsRegexButton)
CommonButtonSettings -Button $SmithSupportsRegexButton


$script:SmithRegistryKeyNameSearchRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Text     = "Enter Key Name; One Per Line"
    Location = @{ X = $SmithRegistryKeyNameCheckbox.Location.X
                  Y = $SmithRegistryKeyNameCheckbox.Location.Y + $SmithRegistryKeyNameCheckbox.Size.Height + $($FormScale * 10) }
    Size     = @{ Width  = $FormScale * 430
                  Height = $FormScale * 80 }
    MultiLine     = $True
    ShortcutsEnabled = $true
    Font           = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_MouseEnter = $SmithRegistryKeyNameSearchRichTextboxAdd_MouseEnter
    Add_MouseLeave = $SmithRegistryKeyNameSearchRichTextboxAdd_MouseLeave
    Add_MouseHover = $SmithRegistryKeyNameSearchRichTextboxAdd_MouseHover
}
$SmithRegistryTab.Controls.Add($script:SmithRegistryKeyNameSearchRichTextbox)


$SmithRegistryValueNameCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Value Name (Supports RegEx)"
    Location = @{ X = $script:SmithRegistryKeyNameSearchRichTextboxv.Location.X
                  Y = $script:SmithRegistryKeyNameSearchRichTextbox.Location.Y + $script:SmithRegistryKeyNameSearchRichTextbox.Size.Height + $($FormScale * 10) }
    Size     = @{ Width  = $FormScale * 300
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click = $SmithRegistryValueNameCheckboxAdd_Click
}
$SmithRegistryTab.Controls.Add($SmithRegistryValueNameCheckbox)


$SmithSupportsRegexButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Regex Examples"
    Location = @{ X = $SmithRegistryValueNameCheckbox.Location.X + $SmithRegistryValueNameCheckbox.Size.Width + $($FormScale * 28)
                  Y = $SmithRegistryValueNameCheckbox.Location.Y }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
}
$SmithSupportsRegexButton.Add_Click({ Import-Csv "$Dependencies\Reference RegEx Examples.csv" | Out-GridView })
$SmithRegistryTab.Controls.Add($SmithSupportsRegexButton)
CommonButtonSettings -Button $SmithSupportsRegexButton


$script:SmithRegistryValueNameSearchRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Text     = "Enter Value Name; One Per Line"
    Location = @{ X = $SmithRegistryValueNameCheckbox.Location.X
                  Y = $SmithRegistryValueNameCheckbox.Location.Y + $SmithRegistryValueNameCheckbox.Size.Height + $($FormScale * 10) }
    Size     = @{ Width  = $FormScale * 430
                  Height = $FormScale * 80 }
    MultiLine     = $True
    ShortcutsEnabled = $true
    Font           = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_MouseEnter = $SmithRegistryValueNameSearchRichTextboxAdd_MouseEnter
    Add_MouseLeave = $SmithRegistryValueNameSearchRichTextboxAdd_MouseLeave
    Add_MouseHover = $SmithRegistryValueNameSearchRichTextboxAdd_MouseHover
}
$SmithRegistryTab.Controls.Add($script:SmithRegistryValueNameSearchRichTextbox)


$SmithRegistryValueDataCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Value Data (Supports RegEx)"
    Location = @{ X = $script:SmithRegistryValueNameSearchRichTextbox.Location.X
                  Y = $script:SmithRegistryValueNameSearchRichTextbox.Location.Y + $script:SmithRegistryValueNameSearchRichTextbox.Size.Height + $($FormScale * 10) }
    Size     = @{ Width  = $FormScale * 300
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click = $SmithRegistryValueDataCheckBoxAdd_Click
}
$SmithRegistryTab.Controls.Add($SmithRegistryValueDataCheckbox)


$SmithSupportsRegexButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Regex Examples"
    Location = @{ X = $SmithRegistryValueDataCheckbox.Location.X + $SmithRegistryValueDataCheckbox.Size.Width + $($FormScale * 28)
                  Y = $SmithRegistryValueDataCheckbox.Location.Y }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Add_Click = { Import-Csv "$Dependencies\Reference RegEx Examples.csv" | Out-GridView }
}
$SmithRegistryTab.Controls.Add($SmithSupportsRegexButton)
CommonButtonSettings -Button $SmithSupportsRegexButton


$script:SmithRegistryValueDataSearchRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Text     = "Enter Value Data; One Per Line"
    Location = @{ X = $SmithRegistryValueDataCheckbox.Location.X
                  Y = $SmithRegistryValueDataCheckbox.Location.Y + $SmithRegistryValueDataCheckbox.Size.Height + $($FormScale * 10) }
    Size     = @{ Width  = $FormScale * 430
                  Height = $FormScale * 80 }
    MultiLine     = $True
    ShortcutsEnabled = $true
    Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_MouseEnter = $SmithRegistryValueDataSearchRichTextboxAdd_MouseEnter
    Add_MouseLeave = $SmithRegistryValueDataSearchRichTextboxAdd_MouseLeave
    Add_MouseHover = $SmithRegistryValueDataSearchRichTextboxAdd_MouseHover
}
$SmithRegistryTab.Controls.Add($script:SmithRegistryValueDataSearchRichTextbox)
