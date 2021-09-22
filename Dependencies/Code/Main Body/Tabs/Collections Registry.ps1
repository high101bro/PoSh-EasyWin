
Update-FormProgress "$Dependencies\Code\Main Body\Search-Registry.ps1"
. "$Dependencies\Code\Main Body\Search-Registry.ps1"
$Section1RegistryTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text     = "Registry"
    Location = @{ X = $FormScale * $RegistryRightPosition
                  Y = $FormScale * $RegistryDownPosition }
    Size     = @{ Width  = $FormScale * 450
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
}
$MainLeftCollectionsTabControl.Controls.Add($Section1RegistryTab)


$RegistrySearchCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Registry Search (WinRM)"
    Location = @{ X = $FormScale * 3
                  Y = $FormScale * 15 }
    Size     = @{ Width  = $FormScale * 230
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        Update-QueryCount
        
        if ($this.Checked -eq $true){
            $RegistrySearchCheckbox.checked = $true
            if ($script:RegistrySelected -eq 'RegistryKeyItemPropertyNameCheckBox') {
                $RegistryKeyItemPropertyNameCheckbox.checked = $true
                $RegistryKeyItemPropertyNameCheckbox.ForeColor = 'Red'
            }
            elseif ($script:RegistrySelected -eq 'RegistryKeyNameCheckBox') {
                $RegistryKeyNameCheckbox.checked = $true
                $RegistryKeyNameCheckbox.ForeColor = 'Red'
            }
            elseif ($script:RegistrySelected -eq 'RegistryValueNameCheckbox') {
                $RegistryValueNameCheckbox.checked = $true
                $RegistryValueNameCheckbox.ForeColor = 'Red'
            }
            elseif ($script:RegistrySelected -eq 'RegistryValueDataCheckBox') {
                $RegistryValueDataCheckbox.checked = $true
                $RegistryValueDataCheckbox.ForeColor = 'Red'
            }
            else {
                $RegistryKeyItemPropertyNameCheckbox.checked = $true
                $RegistryKeyItemPropertyNameCheckbox.ForeColor = 'Red'
            }
        }
        else {
            $RegistrySearchCheckbox.checked = $false
            $RegistryKeyItemPropertyNameCheckbox.checked = $false
            $RegistryKeyNameCheckbox.checked = $false
            $RegistryValueNameCheckbox.checked = $false
            $RegistryValueDataCheckbox.checked = $false

            $RegistrySearchCheckbox.ForeColor = 'Blue'
            $RegistryKeyItemPropertyNameCheckbox.ForeColor = 'Blue'
            $RegistryKeyNameCheckbox.ForeColor = 'Blue'
            $RegistryValueNameCheckbox.ForeColor = 'Blue'
            $RegistryValueDataCheckbox.ForeColor = 'Blue'                
        }
    
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}        
    }
}
$Section1RegistryTab.Controls.Add($RegistrySearchCheckbox)


$RegistrySearchRecursiveCheckbox = New-Object System.Windows.Forms.Checkbox -Property @{
    Text     = "Recursive Search"
    Location = @{ X = $RegistrySearchCheckbox.Size.Width + $($FormScale * 85)
                  Y = $RegistrySearchCheckbox.Location.Y + $($FormScale * 3) }
    Size     = @{ Width  = $FormScale * 200
                  Height = $FormScale * 22 }
    Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor  = "Black"
}
$Section1RegistryTab.Controls.Add($RegistrySearchRecursiveCheckbox)
$script:RegistrySelected = ''


# $RegistrySearchItemPropertiesCheckbox = New-Object System.Windows.Forms.Checkbox -Property @{
#     Text     = "Item Properties"
#     Location = @{ X = $RegistrySearchCheckbox.Size.Width + $($FormScale * 85)
#                   Y = $RegistrySearchCheckbox.Location.Y + $($FormScale * 3) }
#     Size     = @{ Width  = $FormScale * 200
#                   Height = $FormScale * 22 }
#     Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
#     ForeColor  = "Black"
# }
# $Section1RegistryTab.Controls.Add($RegistrySearchItemPropertiesCheckbox)


$RegistrySearchLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = "The collection time is depenant on the number of paths and queries entered, and more so if recursive is selected."
    Location = @{ X = $RegistrySearchCheckbox.Location.X
                  Y = $RegistrySearchRecursiveCheckbox.Location.Y + $RegistrySearchRecursiveCheckbox.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 300
                  Height = $FormScale * 40 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = "Black"
}
$Section1RegistryTab.Controls.Add($RegistrySearchLabel)


$RegistrySearchReferenceButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Select Location"
    Location = @{ X = $RegistrySearchLabel.Location.X + $RegistrySearchLabel.Size.Width + $($FormScale * 30)
                  Y = $RegistrySearchLabel.Location.Y + $($FormScale * 5)}
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Add_Click = {
        Import-Csv "$Dependencies\Reference Registry Locations.csv" | Out-GridView -Title 'PoSh-EasyWin Registry Reference Selection' -PassThru | Set-Variable -Name RegistryReferenceSelected
        $script:RegistrySearchDirectoryRichTextbox.text = ''
        foreach ($Registry in $RegistryReferenceSelected) { $script:RegistrySearchDirectoryRichTextbox.Lines += $Registry.Location}
    }
}
$Section1RegistryTab.Controls.Add($RegistrySearchReferenceButton)
Apply-CommonButtonSettings -Button $RegistrySearchReferenceButton


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RichTextBox\RegistrySearchDirectoryRichTextbox.ps1"
. "$Dependencies\Code\System.Windows.Forms\RichTextBox\RegistrySearchDirectoryRichTextbox.ps1"
$script:RegistrySearchDirectoryRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Text     = "Enter Registry Paths; One Per Line"
    Location = @{ X = $RegistrySearchLabel.Location.X
                  Y = $RegistrySearchLabel.Location.Y + $RegistrySearchLabel.Size.Height }
    Size     = @{ Width  = $FormScale * 430
                  Height = $FormScale * 100 }
    MultiLine     = $True
    ShortcutsEnabled = $true
    Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_MouseEnter = $RegistrySearchDirectoryRichTextboxAdd_MouseEnter
    Add_MouseLeave = $RegistrySearchDirectoryRichTextboxAdd_MouseLeave
    Add_MouseHover = $RegistrySearchDirectoryRichTextboxAdd_MouseHover
}
$Section1RegistryTab.Controls.Add($script:RegistrySearchDirectoryRichTextbox)


$RegistryKeyItemPropertyNameCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Key Item Property (no monitor)"
    Location = @{ X = $script:RegistrySearchDirectoryRichTextbox.Location.X
                  Y = $script:RegistrySearchDirectoryRichTextbox.Location.Y + $script:RegistrySearchDirectoryRichTextbox.Size.Height + $($FormScale * 10) }
    Size     = @{ Width  = $FormScale * 210
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click = {
        $RegistrySearchCheckbox.checked = $true
        $RegistryKeyItemPropertyNameCheckbox.checked = $true
        $RegistryKeyNameCheckbox.checked = $false
        $RegistryValueNameCheckbox.checked = $false
        $RegistryValueDataCheckbox.checked = $false

        $RegistrySearchCheckbox.ForeColor    = 'Red'
        $RegistryKeyItemPropertyNameCheckbox.ForeColor = 'Red'
        $RegistryKeyNameCheckbox.ForeColor   = 'Blue'
        $RegistryValueNameCheckbox.ForeColor = 'Blue'
        $RegistryValueDataCheckbox.ForeColor = 'Blue'                

        $script:RegistrySelected = 'RegistryKeyItemPropertyNameCheckBox'
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes    

    }
}
$Section1RegistryTab.Controls.Add($RegistryKeyItemPropertyNameCheckbox)


#batman update the mouseover,hover,enter
Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RichTextBox\RegistryKeyNameSearchRichTextbox.ps1"
. "$Dependencies\Code\System.Windows.Forms\RichTextBox\RegistryKeyNameSearchRichTextbox.ps1"
$script:RegistryKeyItemPropertyNameSearchRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Text     = "Enter Key Name; One Per Line"
    Location = @{ X = $RegistryKeyItemPropertyNameCheckbox.Location.X
                  Y = $RegistryKeyItemPropertyNameCheckbox.Location.Y + $RegistryKeyItemPropertyNameCheckbox.Size.Height + $($FormScale * 10) }
    Size     = @{ Width  = $FormScale * 210
                  Height = $FormScale * 115 }
    MultiLine     = $True
    ShortcutsEnabled = $true
    Font           = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_MouseEnter = $RegistryKeyNameSearchRichTextboxAdd_MouseEnter
    Add_MouseLeave = $RegistryKeyNameSearchRichTextboxAdd_MouseLeave
    Add_MouseHover = $RegistryKeyNameSearchRichTextboxAdd_MouseHover
}
$Section1RegistryTab.Controls.Add($script:RegistryKeyItemPropertyNameSearchRichTextbox)


$RegistryKeyNameCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Key Name (RegEx)"
    Location = @{ X = $RegistryKeyItemPropertyNameCheckbox.Location.X + $RegistryKeyItemPropertyNameCheckbox.Size.Width + $($FormScale * 10)
                  Y = $RegistryKeyItemPropertyNameCheckbox.Location.Y }
    Size     = @{ Width  = $FormScale * 210
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click = {
        $RegistrySearchCheckbox.checked = $true
        $RegistryKeyItemPropertyNameCheckbox.checked = $false
        $RegistryKeyNameCheckbox.checked = $true
        $RegistryValueNameCheckbox.checked = $false
        $RegistryValueDataCheckbox.checked = $false

        $RegistrySearchCheckbox.ForeColor = 'Red'
        $RegistryKeyItemPropertyNameCheckbox.ForeColor = 'Blue'
        $RegistryKeyNameCheckbox.ForeColor = 'Red'
        $RegistryValueNameCheckbox.ForeColor = 'Blue'
        $RegistryValueDataCheckbox.ForeColor = 'Blue'                

        $script:RegistrySelected = 'RegistryKeyNameCheckBox'
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes    
    }
}
$Section1RegistryTab.Controls.Add($RegistryKeyNameCheckbox)


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RichTextBox\RegistryKeyNameSearchRichTextbox.ps1"
. "$Dependencies\Code\System.Windows.Forms\RichTextBox\RegistryKeyNameSearchRichTextbox.ps1"
$script:RegistryKeyNameSearchRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Text     = "Enter Key Name; One Per Line"
    Location = @{ X = $RegistryKeyNameCheckbox.Location.X
                  Y = $RegistryKeyNameCheckbox.Location.Y + $RegistryKeyNameCheckbox.Size.Height + $($FormScale * 10) }
    Size     = @{ Width  = $FormScale * 210
                  Height = $FormScale * 115 }
    MultiLine     = $True
    ShortcutsEnabled = $true
    Font           = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_MouseEnter = $RegistryKeyNameSearchRichTextboxAdd_MouseEnter
    Add_MouseLeave = $RegistryKeyNameSearchRichTextboxAdd_MouseLeave
    Add_MouseHover = $RegistryKeyNameSearchRichTextboxAdd_MouseHover
}
$Section1RegistryTab.Controls.Add($script:RegistryKeyNameSearchRichTextbox)


$RegistryValueNameCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Value Name (RegEx)"
    Location = @{ X = $script:RegistryKeyItemPropertyNameSearchRichTextbox.Location.X
                  Y = $script:RegistryKeyItemPropertyNameSearchRichTextbox.Location.Y + $script:RegistryKeyItemPropertyNameSearchRichTextbox.Size.Height + $($FormScale * 10) }
    Size     = @{ Width  = $FormScale * 210
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click = {
        $RegistrySearchCheckbox.checked = $true
        $RegistryKeyItemPropertyNameCheckbox.checked = $false
        $RegistryKeyNameCheckbox.checked = $false
        $RegistryValueNameCheckbox.checked = $true
        $RegistryValueDataCheckbox.checked = $false
    
        $RegistrySearchCheckbox.ForeColor = 'Red'
        $RegistryKeyItemPropertyNameCheckbox.ForeColor = 'Blue'
        $RegistryKeyNameCheckbox.ForeColor = 'Blue'
        $RegistryValueNameCheckbox.ForeColor = 'Red'
        $RegistryValueDataCheckbox.ForeColor = 'Blue'

        $script:RegistrySelected = 'RegistryValueNameCheckbox'
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}    
    }
}
$Section1RegistryTab.Controls.Add($RegistryValueNameCheckbox)


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RichTextBox\RegistryValueNameSearchRichTextbox.ps1"
. "$Dependencies\Code\System.Windows.Forms\RichTextBox\RegistryValueNameSearchRichTextbox.ps1"
$script:RegistryValueNameSearchRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Text     = "Enter Value Name; One Per Line"
    Location = @{ X = $RegistryValueNameCheckbox.Location.X
                  Y = $RegistryValueNameCheckbox.Location.Y + $RegistryValueNameCheckbox.Size.Height + $($FormScale * 10) }
    Size     = @{ Width  = $FormScale * 210
                  Height = $FormScale * 115 }
    MultiLine     = $True
    ShortcutsEnabled = $true
    Font           = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_MouseEnter = $RegistryValueNameSearchRichTextboxAdd_MouseEnter
    Add_MouseLeave = $RegistryValueNameSearchRichTextboxAdd_MouseLeave
    Add_MouseHover = $RegistryValueNameSearchRichTextboxAdd_MouseHover
}
$Section1RegistryTab.Controls.Add($script:RegistryValueNameSearchRichTextbox)


$RegistryValueDataCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Value Data (RegEx)"
    Location = @{ X = $RegistryValueNameCheckbox.Location.X + $RegistryValueNameCheckbox.Size.Width + $($FormScale * 10)
                  Y = $RegistryValueNameCheckbox.Location.Y }
    Size     = @{ Width  = $FormScale * 210
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click = {
        $RegistrySearchCheckbox.checked = $true
        $RegistryKeyItemPropertyNameCheckbox.checked = $false
        $RegistryKeyNameCheckbox.checked = $false
        $RegistryValueNameCheckbox.checked = $false
        $RegistryValueDataCheckbox.checked = $true

        $RegistrySearchCheckbox.ForeColor = 'Red'
        $RegistryKeyItemPropertyNameCheckbox.ForeColor = 'Blue'
        $RegistryKeyNameCheckbox.ForeColor = 'Blue'
        $RegistryValueNameCheckbox.ForeColor = 'Blue'
        $RegistryValueDataCheckbox.ForeColor = 'Red'

        $script:RegistrySelected = 'RegistryValueDataCheckBox'
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}    
    }
}
$Section1RegistryTab.Controls.Add($RegistryValueDataCheckbox)


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RichTextBox\RegistryValueDataSearchRichTextbox.ps1"
. "$Dependencies\Code\System.Windows.Forms\RichTextBox\RegistryValueDataSearchRichTextbox.ps1"
$script:RegistryValueDataSearchRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Text     = "Enter Value Data; One Per Line"
    Location = @{ X = $RegistryValueDataCheckbox.Location.X
                  Y = $RegistryValueDataCheckbox.Location.Y + $RegistryValueDataCheckbox.Size.Height + $($FormScale * 10) }
    Size     = @{ Width  = $FormScale * 210
                  Height = $FormScale * 115 }
    MultiLine     = $True
    ShortcutsEnabled = $true
    Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_MouseEnter = $RegistryValueDataSearchRichTextboxAdd_MouseEnter
    Add_MouseLeave = $RegistryValueDataSearchRichTextboxAdd_MouseLeave
    Add_MouseHover = $RegistryValueDataSearchRichTextboxAdd_MouseHover
}
$Section1RegistryTab.Controls.Add($script:RegistryValueDataSearchRichTextbox)


$SupportsRegexButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "RegEx Examples"
    Location = @{ X = $script:RegistryValueDataSearchRichTextbox.Location.X + $script:RegistryValueDataSearchRichTextbox.Size.Width - $($FormScale * 100)
                  Y = $script:RegistryValueDataSearchRichTextbox.Location.Y + $script:RegistryValueDataSearchRichTextbox.Size.Height + $($FormScale * 10) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Add_Click = { Import-Csv "$Dependencies\Reference RegEx Examples.csv" | Out-GridView }
}
$Section1RegistryTab.Controls.Add($SupportsRegexButton)
Apply-CommonButtonSettings -Button $SupportsRegexButton