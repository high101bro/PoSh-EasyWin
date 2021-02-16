
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
        if ($this.Checked -eq $true){
            $RegistrySearchCheckbox.checked = $true
            if     ($script:RegistrySelected -eq 'RegistryKeyNameCheckBox') {
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
                $RegistryKeyNameCheckbox.checked = $true
                $RegistryKeyNameCheckbox.ForeColor = 'Red'
            }
        }
        else {
            $RegistrySearchCheckbox.checked    = $false
            $RegistryKeyNameCheckbox.checked   = $false
            $RegistryValueNameCheckbox.checked = $false
            $RegistryValueDataCheckbox.checked = $false

            $RegistrySearchCheckbox.ForeColor    = 'Blue'
            $RegistryKeyNameCheckbox.ForeColor   = 'Blue'
            $RegistryValueNameCheckbox.ForeColor = 'Blue'
            $RegistryValueDataCheckbox.ForeColor = 'Blue'                
        }
    
        Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands
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
                  Y = $RegistrySearchLabel.Location.Y }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Add_Click = {
        Import-Csv "$Dependencies\Reference Registry Locations.csv" | Out-GridView -Title 'PoSh-EasyWin Registry Reference Selection' -PassThru | Set-Variable -Name RegistryReferenceSelected
        $script:RegistrySearchDirectoryRichTextbox.text = ''
        foreach ($Registry in $RegistryReferenceSelected) { $script:RegistrySearchDirectoryRichTextbox.Lines += $Registry.Location}
    }
}
$Section1RegistryTab.Controls.Add($RegistrySearchReferenceButton)
CommonButtonSettings -Button $RegistrySearchReferenceButton


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RichTextBox\RegistrySearchDirectoryRichTextbox.ps1"
. "$Dependencies\Code\System.Windows.Forms\RichTextBox\RegistrySearchDirectoryRichTextbox.ps1"
$script:RegistrySearchDirectoryRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Text     = "Enter Registry Paths; One Per Line"
    Location = @{ X = $RegistrySearchLabel.Location.X
                  Y = $RegistrySearchLabel.Location.Y + $RegistrySearchLabel.Size.Height }
    Size     = @{ Width  = $FormScale * 430
                  Height = $FormScale * 80 }
    MultiLine     = $True
    ShortcutsEnabled = $true
    Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_MouseEnter = $RegistrySearchDirectoryRichTextboxAdd_MouseEnter
    Add_MouseLeave = $RegistrySearchDirectoryRichTextboxAdd_MouseLeave
    Add_MouseHover = $RegistrySearchDirectoryRichTextboxAdd_MouseHover
}
$Section1RegistryTab.Controls.Add($script:RegistrySearchDirectoryRichTextbox)


$RegistryKeyNameCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Key Name (Supports RegEx)"
    Location = @{ X = $script:RegistrySearchDirectoryRichTextbox.Location.X
                  Y = $script:RegistrySearchDirectoryRichTextbox.Location.Y + $script:RegistrySearchDirectoryRichTextbox.Size.Height + $($FormScale * 10) }
    Size     = @{ Width  = $FormScale * 300
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click = {
        $RegistrySearchCheckbox.checked    = $true
        $RegistryKeyNameCheckbox.checked   = $true
        $RegistryValueNameCheckbox.checked = $false
        $RegistryValueDataCheckbox.checked = $false

        $RegistrySearchCheckbox.ForeColor    = 'Red'
        $RegistryKeyNameCheckbox.ForeColor   = 'Red'
        $RegistryValueNameCheckbox.ForeColor = 'Blue'
        $RegistryValueDataCheckbox.ForeColor = 'Blue'                

        $script:RegistrySelected = 'RegistryKeyNameCheckBox'
        Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands    
    }
}
$Section1RegistryTab.Controls.Add($RegistryKeyNameCheckbox)


$SupportsRegexButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Regex Examples"
    Location = @{ X = $RegistryKeyNameCheckbox.Location.X + $RegistryKeyNameCheckbox.Size.Width + $($FormScale * 28)
                  Y = $RegistryKeyNameCheckbox.Location.Y }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Add_Click = { Import-Csv "$Dependencies\Reference RegEx Examples.csv" | Out-GridView }
}
$Section1RegistryTab.Controls.Add($SupportsRegexButton)
CommonButtonSettings -Button $SupportsRegexButton


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RichTextBox\RegistryKeyNameSearchRichTextbox.ps1"
. "$Dependencies\Code\System.Windows.Forms\RichTextBox\RegistryKeyNameSearchRichTextbox.ps1"
$script:RegistryKeyNameSearchRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Text     = "Enter Key Name; One Per Line"
    Location = @{ X = $RegistryKeyNameCheckbox.Location.X
                  Y = $RegistryKeyNameCheckbox.Location.Y + $RegistryKeyNameCheckbox.Size.Height + $($FormScale * 10) }
    Size     = @{ Width  = $FormScale * 430
                  Height = $FormScale * 80 }
    MultiLine     = $True
    ShortcutsEnabled = $true
    Font           = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_MouseEnter = $RegistryKeyNameSearchRichTextboxAdd_MouseEnter
    Add_MouseLeave = $RegistryKeyNameSearchRichTextboxAdd_MouseLeave
    Add_MouseHover = $RegistryKeyNameSearchRichTextboxAdd_MouseHover
}
$Section1RegistryTab.Controls.Add($script:RegistryKeyNameSearchRichTextbox)


$RegistryValueNameCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Value Name (Supports RegEx)"
    Location = @{ X = $script:RegistryKeyNameSearchRichTextboxv.Location.X
                  Y = $script:RegistryKeyNameSearchRichTextbox.Location.Y + $script:RegistryKeyNameSearchRichTextbox.Size.Height + $($FormScale * 10) }
    Size     = @{ Width  = $FormScale * 300
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click = {
        $RegistrySearchCheckbox.checked    = $true
        $RegistryKeyNameCheckbox.checked   = $false
        $RegistryValueNameCheckbox.checked = $true
        $RegistryValueDataCheckbox.checked = $false
    
        $RegistrySearchCheckbox.ForeColor    = 'Red'
        $RegistryKeyNameCheckbox.ForeColor   = 'Blue'
        $RegistryValueNameCheckbox.ForeColor = 'Red'
        $RegistryValueDataCheckbox.ForeColor = 'Blue'

        $script:RegistrySelected = 'RegistryValueNameCheckbox'
        Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}    
    }
}
$Section1RegistryTab.Controls.Add($RegistryValueNameCheckbox)


$SupportsRegexButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Regex Examples"
    Location = @{ X = $RegistryValueNameCheckbox.Location.X + $RegistryValueNameCheckbox.Size.Width + $($FormScale * 28)
                  Y = $RegistryValueNameCheckbox.Location.Y }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
}
$SupportsRegexButton.Add_Click({ Import-Csv "$Dependencies\Reference RegEx Examples.csv" | Out-GridView })
$Section1RegistryTab.Controls.Add($SupportsRegexButton)
CommonButtonSettings -Button $SupportsRegexButton


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RichTextBox\RegistryValueNameSearchRichTextbox.ps1"
. "$Dependencies\Code\System.Windows.Forms\RichTextBox\RegistryValueNameSearchRichTextbox.ps1"
$script:RegistryValueNameSearchRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Text     = "Enter Value Name; One Per Line"
    Location = @{ X = $RegistryValueNameCheckbox.Location.X
                  Y = $RegistryValueNameCheckbox.Location.Y + $RegistryValueNameCheckbox.Size.Height + $($FormScale * 10) }
    Size     = @{ Width  = $FormScale * 430
                  Height = $FormScale * 80 }
    MultiLine     = $True
    ShortcutsEnabled = $true
    Font           = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_MouseEnter = $RegistryValueNameSearchRichTextboxAdd_MouseEnter
    Add_MouseLeave = $RegistryValueNameSearchRichTextboxAdd_MouseLeave
    Add_MouseHover = $RegistryValueNameSearchRichTextboxAdd_MouseHover
}
$Section1RegistryTab.Controls.Add($script:RegistryValueNameSearchRichTextbox)


$RegistryValueDataCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Value Data (Supports RegEx)"
    Location = @{ X = $script:RegistryValueNameSearchRichTextbox.Location.X
                  Y = $script:RegistryValueNameSearchRichTextbox.Location.Y + $script:RegistryValueNameSearchRichTextbox.Size.Height + $($FormScale * 10) }
    Size     = @{ Width  = $FormScale * 300
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click = {
        $RegistrySearchCheckbox.checked    = $true
        $RegistryKeyNameCheckbox.checked   = $false
        $RegistryValueNameCheckbox.checked = $false
        $RegistryValueDataCheckbox.checked = $true

        $RegistrySearchCheckbox.ForeColor    = 'Red'
        $RegistryKeyNameCheckbox.ForeColor   = 'Blue'
        $RegistryValueNameCheckbox.ForeColor = 'Blue'
        $RegistryValueDataCheckbox.ForeColor = 'Red'

        $script:RegistrySelected = 'RegistryValueDataCheckBox'
        Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}    
    }
}
$Section1RegistryTab.Controls.Add($RegistryValueDataCheckbox)


$SupportsRegexButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Regex Examples"
    Location = @{ X = $RegistryValueDataCheckbox.Location.X + $RegistryValueDataCheckbox.Size.Width + $($FormScale * 28)
                  Y = $RegistryValueDataCheckbox.Location.Y }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Add_Click = { Import-Csv "$Dependencies\Reference RegEx Examples.csv" | Out-GridView }
}
$Section1RegistryTab.Controls.Add($SupportsRegexButton)
CommonButtonSettings -Button $SupportsRegexButton


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RichTextBox\RegistryValueDataSearchRichTextbox.ps1"
. "$Dependencies\Code\System.Windows.Forms\RichTextBox\RegistryValueDataSearchRichTextbox.ps1"
$script:RegistryValueDataSearchRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Text     = "Enter Value Data; One Per Line"
    Location = @{ X = $RegistryValueDataCheckbox.Location.X
                  Y = $RegistryValueDataCheckbox.Location.Y + $RegistryValueDataCheckbox.Size.Height + $($FormScale * 10) }
    Size     = @{ Width  = $FormScale * 430
                  Height = $FormScale * 80 }
    MultiLine     = $True
    ShortcutsEnabled = $true
    Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_MouseEnter = $RegistryValueDataSearchRichTextboxAdd_MouseEnter
    Add_MouseLeave = $RegistryValueDataSearchRichTextboxAdd_MouseLeave
    Add_MouseHover = $RegistryValueDataSearchRichTextboxAdd_MouseHover
}
$Section1RegistryTab.Controls.Add($script:RegistryValueDataSearchRichTextbox)

