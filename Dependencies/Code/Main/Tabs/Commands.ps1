####################################################################################################
# ScriptBlocks
####################################################################################################
Update-FormProgress "Commands.ps1 - ScriptBlocks"

$CommandsViewCommandNamesRadioButtonAdd_Click = {
    # This variable stores data on checked checkboxes, so boxes checked remain among different views
    $script:CommandsCheckedBoxesSelected = @()

    [System.Windows.Forms.TreeNodeCollection]$AllCommandsNode = $script:CommandsTreeView.Nodes
    foreach ($root in $AllCommandsNode) {
        foreach ($Category in $root.Nodes) {
            foreach ($Entry in $Category.nodes) {
                if ($Entry.Checked) {
                    $script:CommandsCheckedBoxesSelected += $Entry.Text
                }
            }
        }
    }
    $script:CommandsTreeView.Nodes.Clear()
    Initialize-TreeViewCommand
    View-TreeViewCommandQuery
    Update-TreeViewCommand
}

$CommandsViewCommandNamesRadioButtonAdd_MouseHover = {
    Show-ToolTip -Title "Display by Command Grouping" -Icon "Info" -Message @"
+  Displays commands grouped by queries
+  All commands executed against each host are logged
"@
}

$CommandsTreeViewSearchButtonAdd_MouseHover = {
    Show-ToolTip -Title "Command Search" -Icon "Info" -Message @"
+  Searches through query names and metadata.
+  Search results are returned as nodes.
+  Search results are not persistent.
"@
}

$CommandsTreeviewDeselectAllButtonAdd_MouseHover = {
    Show-ToolTip -Title "Deselect All" -Icon "Info" -Message @"
+  Unchecks all commands checked within this view.
+  Commands and queries in other Tabs must be manually unchecked.
"@
}

$CustomQueryScriptBlockTextboxAdd_KeyDown = {
    if ($_.KeyCode -eq "Enter") {
        CustomQueryScriptBlock
        $script:CustomQueryScriptBlockGroupBoxTextMemory = $script:CustomQueryScriptBlockTextbox.Text
        $script:CustomQueryScriptBlockTextbox.forecolor = 'black'
    }
}

$CustomQueryScriptBlockTextboxAdd_MouseEnter = {
    $this.ForeColor = 'DarkRed'
    if ($this.text -eq 'Enter a command'){
        $this.text = ''
    }
}

$CustomQueryScriptBlockTextboxAdd_MouseLeave = {
    if ($this.text -eq '' -or $this.text -eq $null) {
        $this.text = 'Enter a command'
        $this.ForeColor = 'Black'
    }
}

$CustomQueryScriptBlockDisableSyntaxCheckboxAdd_Click = {
    if ($this.checked) {
        $CustomQueryScriptBlockVerifyButton.Enabled = $false
        $CustomQueryScriptBlockSearchAndBuildButton.Enabled = $false
        $CustomQueryScriptBlockAddCommandButton.Enabled = $True
        $CustomQueryScriptBlockAddCommandButton.Backcolor = 'LightBlue'
    }
    else {
        $CustomQueryScriptBlockVerifyButton.Enabled = $true
        $CustomQueryScriptBlockSearchAndBuildButton.Enabled = $true
        $CustomQueryScriptBlockAddCommandButton.Enabled = $false
        $CustomQueryScriptBlockAddCommandButton.Backcolor = 'LightGray'
    }
}

$CustomQueryScriptBlockVerifyButtonAdd_Click = {
    CustomQueryScriptBlock
    $script:CustomQueryScriptBlockGroupBoxTextMemory = $script:CustomQueryScriptBlockTextbox.Text
    $script:CustomQueryScriptBlockTextbox.forecolor = 'black'
}

$CustomQueryScriptBlockSearchAndBuildButtonAdd_Click = {
    if ($CustomQueryScriptBlockCheckBoxWinRM.checked) {
        CustomQueryScriptBlock -Build
    }
    elseif ($CustomQueryScriptBlockCheckBoxSSH.checked) {
        $script:CustomQueryScriptBlockTextbox.Text = Import-Csv "$Dependencies\Linux Commands.csv" | Out-GridView -Title "Linux Commands - Reference" -PassThru | Select-Object -ExpandProperty Command
    }

    $script:CustomQueryScriptBlockGroupBoxTextMemory = $script:CustomQueryScriptBlockTextbox.Text
    $script:CustomQueryScriptBlockTextbox.forecolor = 'black'
}

$CustomQueryScriptBlockCheckBoxWinRMAdd_Click = {
    if ($This.Checked -eq $true ) {
        $This.ForeColor = 'Blue'
        $script:CustomQueryScriptBlockDisableSyntaxCheckbox.Checked = $false
        $script:CustomQueryScriptBlockDisableSyntaxCheckbox.Enabled = $true
        $CustomQueryScriptBlockVerifyButton.Enabled = $true
        $CustomQueryScriptBlockSearchAndBuildButton.Text = 'Search + Build'
        $CustomQueryScriptBlockSearchAndBuildButton.Enabled = $true
        $CustomQueryScriptBlockAddCommandButton.Enabled = $false
        $CustomQueryScriptBlockAddCommandButton.Backcolor = 'LightGray'
        $CustomQueryScriptBlockCheckBoxSSH.ForeColor = 'Black'
    }
    Update-QueryCount
    Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
}
$CustomQueryScriptBlockCheckBoxSSHAdd_Click = {
    if ($This.Checked -eq $true ) {
        $This.ForeColor = 'Blue'
        $script:CustomQueryScriptBlockDisableSyntaxCheckbox.Checked = $True
        $script:CustomQueryScriptBlockDisableSyntaxCheckbox.Enabled = $False
        $CustomQueryScriptBlockVerifyButton.Enabled = $false
        $CustomQueryScriptBlockSearchAndBuildButton.Text = 'Reference'
        $CustomQueryScriptBlockAddCommandButton.Enabled = $true
        $CustomQueryScriptBlockAddCommandButton.Backcolor = 'LightBlue'
        $CustomQueryScriptBlockCheckBoxWinRM.Forecolor = 'Black'
    }
    Update-QueryCount
    Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
}

$GroupCommandUniqueNameCheck = {
    $CustomGroupCommandUnique = $true
    [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:CommandsTreeView.Nodes
    foreach ($root in $AllTreeViewNodes) {
        if ($root.text -match 'Custom Group Commands') {
            foreach ($category in $root.nodes) {
                if ($category.text -eq $GroupCommandsGroupNameTextBox.text) {
                    $CustomGroupCommandUnique = $false
                }
            }
        }
    }
    if ($CustomGroupCommandUnique) {
        $script:GroupCommandsGroupName = $GroupCommandsGroupNameTextBox.Text
        $GroupCommandsForm.close()
    }
    else {
        [system.media.systemsounds]::Exclamation.play()
        [System.Windows.Forms.MessageBox]::Show("The custom command group name already exists. Enter a new name or delete the other one.","PoSh-EasyWin",'Ok',"Info")
    }
}

$CustomQueryScriptBlockAddCommandButtonAdd_Click = {
    $script:CustomQueryScriptBlockTextbox.ForeColor = 'Black'

    $command = $null
    if ($CustomQueryScriptBlockCheckBoxWinRM.Checked -eq $true) {
        if (-not $script:CustomQueryScriptBlockDisableSyntaxCheckbox.checked) {
            # Creates the command object for use to add to the treeview
            $Command = [PSCustomObject]@{
                ExportFileName     = "$(($script:ShowCommandQueryBuild -split ' ')[0]) (User Added Command)"
                Properties_PoSh    = '*'
                Command_WinRM_PoSh = "Invoke-Command -ScriptBlock { $script:ShowCommandQueryBuild }"
                Name               = $script:ShowCommandQueryBuild
                Type               = '(WinRM) PoSh'
            }
        }
        else {
            $Command = [PSCustomObject]@{
                ExportFileName     = "$(($($script:CustomQueryScriptBlockTextbox.text) -split ' ')[0]) (User Added Command)"
                Properties_PoSh    = '*'
                Command_WinRM_PoSh = "Invoke-Command -ScriptBlock { $($script:CustomQueryScriptBlockTextbox.text) }"
                Name               = $($script:CustomQueryScriptBlockTextbox.text)
                Type               = '(WinRM) PoSh'
            }
        }
        # Check if command already exists
        $VerifyUserAddedCommandAddition = $true
        [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:CommandsTreeView.Nodes
        foreach ($root in $AllTreeViewNodes) {
            if ($root.text -match 'User Added Commands') {
                foreach ($category in $root.nodes) {
                    foreach ($entry in $category.nodes) {
                        if ($command.Command_WinRM_PoSh -eq $entry.ToolTipText) {
                            $VerifyUserAddedCommandAddition = $false
                        }
                    }
                }
            }
        }

        # Adds command if it doesn't exist
        if ($VerifyUserAddedCommandAddition) {
            Add-TreeViewCommand -RootNode $script:TreeNodeUserAddedCommands -Category $("{0,-10}{1}" -f "[WinRM]", "PowerShell Cmdlets") -Entry "(WinRM) PoSh -- $($Command.Name)" -ToolTip $($command.Command_WinRM_PoSh)
            $script:UserAddedCommandsWinRM += $Command
            $script:UserAddedCommandsWinRM | Export-Csv $CommandsUserAddedWinRM -NoTypeInformation
        }
        else {
            [system.media.systemsounds]::Exclamation.play()
            if (-not $script:CustomQueryScriptBlockDisableSyntaxCheckbox.checked) {
                [System.Windows.Forms.MessageBox]::Show("The following User Added Command already exists:`n   $($script:ShowCommandQueryBuild)","PoSh-EasyWin",'Ok',"Info")
            }
            else {
                [System.Windows.Forms.MessageBox]::Show("The following User Added Command already exists:`n   $($script:CustomQueryScriptBlockTextbox.text)","PoSh-EasyWin",'Ok',"Info")
            }
        }
        $This.Enabled = $false
        $This.Backcolor = 'LightGray'

    }
    elseif ($CustomQueryScriptBlockCheckBoxSSH.Checked -eq $true) {
        $Command = [PSCustomObject]@{
            ExportFileName = "$(($($script:CustomQueryScriptBlockTextbox.text) -split ' ')[0]) (User Added Command)"
            Command_Linux  = "$($script:CustomQueryScriptBlockTextbox.text)"
            Name           = "$($script:CustomQueryScriptBlockTextbox.text)"
            Type           = '(SSH) Linux'
        }

        # Check if command already exists
        $VerifyUserAddedCommandAddition = $true
        [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:CommandsTreeView.Nodes
        foreach ($root in $AllTreeViewNodes) {
            if ($root.text -match 'User Added Commands') {
                foreach ($category in $root.nodes) {
                    foreach ($entry in $category.nodes) {
                        if ($command.Command_Linux -eq $entry.ToolTipText) {
                            $VerifyUserAddedCommandAddition = $false
                        }
                    }
                }
            }
        }

        # Adds command if it doesn't exist
        if ($VerifyUserAddedCommandAddition) {
            Add-TreeViewCommand -RootNode $script:TreeNodeUserAddedCommands -Category $("{0,-10}{1}" -f "[SSH]", "Linux Commands") -Entry "(SSH) Linux -- $($Command.Name)" -ToolTip "$($command.Command_Linux)"
            $script:UserAddedCommandsSSH += $Command
            $script:UserAddedCommandsSSH | Export-Csv $CommandsUserAddedSSH -NoTypeInformation
        }
        else {
            [system.media.systemsounds]::Exclamation.play()
            if (-not $script:CustomQueryScriptBlockDisableSyntaxCheckbox.checked) {
                [System.Windows.Forms.MessageBox]::Show("The following User Added Command already exists:`n   $($script:ShowCommandQueryBuild)","PoSh-EasyWin",'Ok',"Info")
            }
            else {
                [System.Windows.Forms.MessageBox]::Show("The following User Added Command already exists:`n   $($script:CustomQueryScriptBlockTextbox.text)","PoSh-EasyWin",'Ok',"Info")
            }
        }
        $This.Enabled = $true
        $This.Backcolor = 'LightBlue'
    }
    
    # Shows all the commands
    $entry.ExpandAll()
    $entry.EnsureVisible()

    if (-not $script:CustomQueryScriptBlockDisableSyntaxCheckbox.checked) {
        $This.enabled = $false
    }
    else {
        $CustomQueryScriptBlockSearchAndBuildButton.enabled = $true
    }

    $script:CustomQueryScriptBlockTextbox.text = 'Enter a command'
    $script:CustomQueryScriptBlockDisableSyntaxCheckbox.checked = $false
}

$CommandsViewProtocolsUsedRadioButtonAdd_Click = {
    #$StatusListBox.Items.Clear()
    #$StatusListBox.Items.Add("Display And Group By:  Method")

    # This variable stores data on checked checkboxes, so boxes checked remain among different views
    $script:CommandsCheckedBoxesSelected = @()

    [System.Windows.Forms.TreeNodeCollection]$AllCommandsNode = $script:CommandsTreeView.Nodes
    foreach ($root in $AllCommandsNode) {
        foreach ($Category in $root.Nodes) {
            foreach ($Entry in $Category.nodes) {
                if ($Entry.Checked) { $script:CommandsCheckedBoxesSelected += $Entry.Text }
            }
        }
    }
    $script:CommandsTreeView.Nodes.Clear()
    Initialize-TreeViewCommand
    View-TreeViewCommandMethod
    Update-TreeViewCommand
}

$CommandsViewProtocolsUsedRadioButtonAdd_MouseHover = {
    Show-ToolTip -Title "Display by Method Grouping" -Icon "Info" -Message @"
+  Displays commands grouped by the method they're collected
+  All commands executed against each host are logged
"@
}

$CommandsTreeViewSearchComboBoxAdd_MouseHover = {
    Show-ToolTip -Title "Search Input Field" -Icon "Info" -Message @"
+  Searches may be typed in manually.
+  Searches can include any character.
+  There are several default searches available.
"@
}

$CommandsTreeviewGroupCommandsButtonAdd_Click = {
    [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:CommandsTreeView.Nodes
    $CommandCount = 0
    foreach ($root in $AllTreeViewNodes) {
        foreach ($category in $root.nodes) {
            foreach ($entry in $category.nodes) {
                if ($entry.checked) { $CommandCount++ }
            }
        }
    }
    if ($CommandCount -ge 2) {
        Compile-TreeViewCommand

        $GroupCommandsForm = New-Object system.Windows.Forms.Form -Property @{
            Text          = "PoSh-EasyWin - Group Commands"
            Width         = $FormScale * 335
            Height        = $FormScale * 120
            StartPosition = "CenterScreen"
            Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
            Add_Closing = { $This.dispose() }
        }
            $GroupCommandsGroupNameLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Enter a new or existing group name:"
                Left   = $FormScale * 10
                Top    = $FormScale * 10
                Width  = $FormScale * 300
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Blue'
            }
            $GroupCommandsForm.Controls.Add($GroupCommandsGroupNameLabel)
    
    
            $GroupCommandsGroupNameTextBox = New-Object System.Windows.Forms.TextBox -Property @{
                Text   = "$((Get-Date).ToString('yyyy-MM-dd HH.mm.ss'))"
                Left   = $FormScale * 10
                Top    = $GroupCommandsGroupNameLabel.Top + $GroupCommandsGroupNameLabel.Height
                Width  = $FormScale * 300
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                Add_KeyDown = {
                    if ($_.KeyCode -eq "Enter") { Invoke-Command $GroupCommandUniqueNameCheck }
                }
            }
            $GroupCommandsForm.Controls.Add($GroupCommandsGroupNameTextBox)
    
    
            $GroupCommandsGroupNameCreateButton = New-Object System.Windows.Forms.Button -Property @{
                Text   = "Create Group"
                Left   = $GroupCommandsGroupNameTextBox.Left + $GroupCommandsGroupNameTextBox.Width - $($FormScale * 100)
                Top    = $GroupCommandsGroupNameTextBox.Top + $GroupCommandsGroupNameTextBox.Height + ($FormScale * 5)
                Width  = $FormScale * 100
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                Add_Click = { Invoke-Command $GroupCommandUniqueNameCheck }
            }
            Add-CommonButtonSettings -Button $GroupCommandsGroupNameCreateButton
            $GroupCommandsForm.Controls.Add($GroupCommandsGroupNameCreateButton)
    
        $GroupCommandsForm.ShowDialog()
    
    
        # Verifies that the command is only present once. Prevents running the multiple copies of the same comand, line from using the Custom Group Commands
        $CommandsCheckedBoxesSelectedTemp  = @()
        $CommandsCheckedBoxesSelectedDedup = @()
        foreach ($Command in $script:CommandsCheckedBoxesSelected) {
            if ($CommandsCheckedBoxesSelectedTemp -notcontains $Command.command) {
                $CommandsCheckedBoxesSelectedTemp  += "$($Command.command)"
                $CommandsCheckedBoxesSelectedDedup += $command
            }
        }
    
        $CustomCommandGroupKeepSelected = @()
        foreach ($Command in $CommandsCheckedBoxesSelectedDedup) {
            Add-TreeViewCommand -RootNode $script:TreeNodeCustomGroupCommands -Category $script:GroupCommandsGroupName -Entry "$($Command.Name)" -ToolTip "$($Command.Command)"
            $CustomCommandGroupKeepSelected += [pscustomobject]@{
                CategoryName = $script:GroupCommandsGroupName
                Name         = $Command.Name
                Command      = $Command.Command
            }
        }
    
        $script:CustomGroupCommandsList + $CustomCommandGroupKeepSelected | Export-CliXml $CommandsCustomGrouped
    
    
        if (Test-Path $CommandsCustomGrouped) { $script:CustomGroupCommands = Import-CliXml $CommandsCustomGrouped }
        elseif (Test-Path $CommandsCustomGroupedDemo) { $script:CustomGroupCommands = Import-CliXml $CommandsCustomGroupedDemo }
        foreach ($Command in $script:CustomGroupCommands) {
            $Command | Add-Member -MemberType NoteProperty -Name CategoryName -Value "$($Command.CategoryName)" -Force
            Add-TreeViewCommand -RootNode $script:TreeNodeCustomGroupCommands -Category "$($Command.CategoryName)" -Entry "$($Command.Name)" -ToolTip $Command.Command
        }
        $script:CustomGroupCommandsList = $script:CustomGroupCommands
    
        Remove-Variable -name CommandsCheckedBoxesSelectedTemp
        Remove-Variable -name CommandsCheckedBoxesSelectedDedup
        Remove-Variable -name CustomCommandGroupKeepSelected
        Remove-Variable -name CustomGroupCommands
    
        $script:CommandsTreeView.Nodes.Clear()
        Initialize-TreeViewCommand
        View-TreeViewCommandMethod
        Update-TreeViewCommand
    }
    else {
        [System.Windows.Forms.MessageBox]::Show("Checkbox two or more commands to group together.","PoSh-EasyWin",'Ok',"Info")
    }
}

$CommandsTreeViewRemoveCommandButtonAdd_Click = {
    if (Verify-Action -Title "PoSh-EasyWin" -Question "Do you want to remove the selected Custom Group or User Added Commands?") {
        $QueryHistoryRemoveGroupCategoryList  = @()
        $QueryHistoryRemoveUserAddedEntryList = @()
        $QueryHistoryKeepGroupCategoryList    = @()
        $QueryHistoryKeepUserAddedEntryList   = @()

        # Iterates through the command treeview and creates a list of non-checked commands
        [System.Windows.Forms.TreeNodeCollection]$AllCommandsNode = $script:CommandsTreeView.Nodes
        foreach ($root in $AllCommandsNode) {
            if ($root.text -match 'Custom Group Commands') {
                $root.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
                foreach ($Category in $root.Nodes) {
                    $QueryHistoryRemoveGroupCategoryList += $Category
                    if (!($Category.checked)) { $QueryHistoryKeepGroupCategoryList += $Category }
                }
            }
            if ($root.text -match 'User Added Commands') {
                $root.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
                foreach ($Category in $root.Nodes) {
                    foreach ($Entry in $Category.Nodes) {
                        $QueryHistoryRemoveUserAddedEntryList += $Entry
                        if (!($Entry.checked)) { $QueryHistoryKeepUserAddedEntryList += $Entry }
                    }
                }
            }
        }

        # Removes all commands
        foreach ($Entry in $QueryHistoryRemoveGroupCategoryList) {
            $Entry.remove()
        }
        foreach ($Entry in $QueryHistoryRemoveUserAddedEntryList) {
            $Entry.remove()
        }

        # removes the button from view
        $Section1TreeViewCommandsTab.Controls.Remove($CommandsTreeViewRemoveCommandButton)

        # iterates through the list of non-checked commands and re-adds them to the command treeview
        $QueryHistoryKeepGroupSelected = @()
        foreach ($Category in $QueryHistoryKeepGroupCategoryList) {
            foreach ($Entry in $Category.nodes) {
                $QueryHistoryKeepGroupSelected += [pscustomobject]@{
                    CategoryName = $Category.Text
                    Name         = $Entry.Text
                }
                Add-TreeViewCommand -RootNode $script:TreeNodeCustomGroupCommands -Category "$($Category.text)" -Entry "$($Entry.Text)" -ToolTip "$($Command.Command)"
            }
        }
        $script:CustomGroupCommandsList = $QueryHistoryKeepGroupSelected
        $QueryHistoryKeepGroupSelected | Export-CliXml $CommandsCustomGrouped


        # iterates through the list of non-checked commands and re-adds them to the command treeview
        $CommandsUserAddedWinRMAddedList = @()
        $CommandsUserAddedWinRMToKeep = @()
        $CommandsUserAddedSSHAddedList = @()
        $CommandsUserAddedSSHToKeep = @()
        foreach ($Entry in $QueryHistoryKeepUserAddedEntryList) {
            Foreach ($command in $script:UserAddedCommandsWinRM){
                if ( $Entry.text -match $command.name -and $command -notin $CommandsUserAddedWinRMAddedList) {
                    $CommandsUserAddedWinRMAddedList += $command
                    Add-TreeViewCommand -RootNode $script:TreeNodeUserAddedCommands -Category $("{0,-10}{1}" -f "[WinRM]", "PowerShell Cmdlets") -Entry "(WinRM) PoSh -- $($Command.Name)" -ToolTip "$($command.Command_WinRM_PoSh)"
                    $CommandsUserAddedWinRMToKeep += $command
                }
            }
            Foreach ($command in $script:UserAddedCommandsSSH){
                if ( $Entry.text -match $command.name -and $command -notin $CommandsUserAddedSSHAddedList) {
                    $CommandsUserAddedSSHAddedList += $command
                    Add-TreeViewCommand -RootNode $script:TreeNodeUserAddedCommands -Category $("{0,-10}{1}" -f "[SSH]", "Linux Commands") -Entry "(SSH) Linux -- $($Command.Name)" -ToolTip "$($command.Command_Linux)"
                    $CommandsUserAddedSSHToKeep += $command
                }
            }
        }

        # Save remaining User Added Commands
        $script:UserAddedCommandsWinRM = $CommandsUserAddedWinRMToKeep
        $script:UserAddedCommandsWinRM | Export-Csv $CommandsUserAddedWinRM -NoTypeInformation
        $script:UserAddedCommandsSSH = $CommandsUserAddedSSHToKeep
        $script:UserAddedCommandsSSH | Export-Csv $CommandsUserAddedSSH -NoTypeInformation

        # Save remaining Custom Group Commands List
        $QueryHistoryKeepGroupSelected | Export-CliXml $CommandsCustomGrouped
    }
}


####################################################################################################
# WinForms
####################################################################################################
Update-FormProgress "Commands.ps1 - WinForms"

$Section1TreeViewCommandsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = "Commands  "
    Left   = $FormScale * -1
    Top    = $FormScale * $Column1DownPosition
    Width  = $FormScale * $Column1BoxWidth
    Height = $FormScale * ($Column1BoxHeight + 10)
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
    ImageIndex = 0
}
$MainLeftTabControl.Controls.Add($Section1TreeViewCommandsTab)


# Imports all the Endpoint Commands fromthe csv file
$script:AllEndpointCommands = Import-Csv $CommandsEndpoint

# Imports scripts from the Endpoint Directory script folder and loads them into the treeview
Update-FormProgress "PowerShell Scripts (Endpoints)"
Import-EndpointScripts

# Imports all the Active Directoyr Commands fromthe csv file
$script:AllActiveDirectoryCommands = Import-Csv $CommandsActiveDirectory

# Imports scripts from the Active Directory script folder and loads them into the treeview
Update-FormProgress "PowerShell Scripts (Active Directory)"
Import-ActiveDirectoryScripts

# Initializes/empties the Custom Group Commands array
# Queries executed will be stored within this array and added later to as treenodes
$script:CustomGroupCommandsListListListList = @()

$script:TreeeViewEndpointCount = 0
$script:TreeeViewCommandsCount = 0

$script:HostQueryTreeViewSelected = ""

# Initially imports the Custom Group Commands and populates the command treenode
if (Test-Path $CommandsCustomGrouped) { $script:CustomGroupCommands = Import-CliXml $CommandsCustomGrouped }
elseif (Test-Path $CommandsCustomGroupedDemo) { $script:CustomGroupCommands = Import-CliXml $CommandsCustomGroupedDemo }
foreach ($Command in $script:CustomGroupCommands) {
    $Command | Add-Member -MemberType NoteProperty -Name CategoryName -Value "$($Command.CategoryName)" -Force
    Add-TreeViewCommand -RootNode $script:TreeNodeCustomGroupCommands -Category "$($Command.CategoryName)" -Entry "$($Command.Name)" -ToolTip $Command.Command
}
$script:CustomGroupCommandsList = $script:CustomGroupCommands



$CommandsTreeViewViewByGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text   = "Display And Group By:"
    Left   = $FormScale * 10
    Top    = $FormScale * 5
    Width  = $FormScale * 231
    Height = $FormScale * 37
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
    ForeColor = 'Blue'
}

    $CommandsViewProtocolsUsedRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
        Text      = "Protocol"
        Left      = $FormScale * 10
        Top       = $FormScale * 13
        Width     = $FormScale * 95
        Height    = $FormScale * 20
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = 'Black'
        Checked   = $True
        Add_Click = $CommandsViewProtocolsUsedRadioButtonAdd_Click
        Add_MouseHover = $CommandsViewProtocolsUsedRadioButtonAdd_MouseHover
    }
    $CommandsTreeViewViewByGroupBox.Controls.Add( $CommandsViewProtocolsUsedRadioButton )


    $CommandsViewCommandNamesRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
        Text      = "Command Name"
        Left      = $CommandsViewProtocolsUsedRadioButton.Left + $CommandsViewProtocolsUsedRadioButton.Width
        Top       = $CommandsViewProtocolsUsedRadioButton.Top
        Width     = $FormScale * 115
        Height    = $FormScale * 20
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = 'Black'
        Checked   = $false
        Add_Click = $CommandsViewCommandNamesRadioButtonAdd_Click
        Add_MouseHover = $CommandsViewCommandNamesRadioButtonAdd_MouseHover
    }
    $CommandsTreeViewViewByGroupBox.Controls.Add($CommandsViewCommandNamesRadioButton)
$Section1TreeViewCommandsTab.Controls.Add($CommandsTreeViewViewByGroupBox)


$CommandsTreeViewFilterGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text   = "Protocol Command Filter:"
    Left   = $CommandsTreeViewViewByGroupBox.Left + $CommandsTreeViewViewByGroupBox.Width + ($FormScale * 4)
    Top    = $FormScale * 5
    Width  = $FormScale * 200
    Height = $FormScale * 37
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
    ForeColor = 'Blue'
}
    $CommandsViewFilterComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Left   = $FormScale * 5
        Top    = $FormScale * 15
        Width  = $FormScale * 190
        Height = $FormScale * 20
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = 'Black'
        Add_SelectedValueChanged = {
            $script:CommandsTreeView.Nodes.Clear()
            Initialize-TreeViewCommand
            View-TreeViewCommandMethod
            Update-TreeViewCommand
            $CommandsViewProtocolsUsedRadioButton.Checked = $true
            $This.Text | Set-Content "$PewSettings\Display Commands Filter.txt" -Force
        }
    }
    $QueryTypeList = @('All (WinRM,RPC,SMB,SSH)','WinRM','RPC','SMB','SSH')
    foreach ( $QueryType in $QueryTypeList ) { $CommandsViewFilterComboBox.Items.Add("$QueryType") }
    if (Get-Content "$PewSettings\Display Commands Filter.txt") {
        $CommandsViewFilterComboBox.Text = Get-Content "$PewSettings\Display Commands Filter.txt"
    }
    else {
        $CommandsViewFilterComboBox.Text = 'All (WinRM,RPC,SMB,SSH)'
    }
    $CommandsTreeViewFilterGroupBox.Controls.Add( $CommandsViewFilterComboBox )

$Section1TreeViewCommandsTab.Controls.Add($CommandsTreeViewFilterGroupBox)


$CommandsTreeViewSearchComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Name     = "Search TextBox"
    Left     = $FormScale * 10
    Top      = $FormScale * 45
    Width    = $FormScale * 170
    Height   = $FormScale * 25
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
    Add_KeyDown    = { if ($_.KeyCode -eq "Enter") { Search-TreeViewCommand } }
    Add_MouseHover = $CommandsTreeViewSearchComboBoxAdd_MouseHover
}
    $CommandTypes = @("Chart","File","Hardware","Hunt","Network","System","User")
    ForEach ($Type in $CommandTypes) { [void] $CommandsTreeViewSearchComboBox.Items.Add($Type) }
$Section1TreeViewCommandsTab.Controls.Add($CommandsTreeViewSearchComboBox)


$CommandsTreeViewSearchButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Search"
    Left   =  $CommandsTreeViewSearchComboBox.Left + $CommandsTreeViewSearchComboBox.Width + $($FormScale * 5)
    Top    = $FormScale * 45
    Width  = $FormScale * 55
    Height = $FormScale * 20
    Add_Click      = { Search-TreeViewCommand }
    Add_MouseHover = $CommandsTreeViewSearchButtonAdd_MouseHover
}
$Section1TreeViewCommandsTab.Controls.Add($CommandsTreeViewSearchButton)
Add-CommonButtonSettings -Button $CommandsTreeViewSearchButton


$CommandsTreeviewGroupCommandsButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Group Commands'
    Left   = $CommandsTreeViewSearchButton.Left + $CommandsTreeViewSearchButton.Width + ($FormScale * 5)
    Top    = $FormScale * 45
    Width  = $FormScale * 110
    Height = $FormScale * 20
    Add_Click = $CommandsTreeviewGroupCommandsButtonAdd_Click
}
$Section1TreeViewCommandsTab.Controls.Add($CommandsTreeviewGroupCommandsButton)
Add-CommonButtonSettings -Button $CommandsTreeviewGroupCommandsButton


$CommandsTreeviewDeselectAllButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Deselect All'
    Left   = $CommandsTreeviewGroupCommandsButton.Left + $CommandsTreeviewGroupCommandsButton.Width + ($FormScale * 5)
    Top    = $FormScale * 45
    Width  = $FormScale * 84
    Height = $FormScale * 20
    Add_Click      = { Deselect-AllCommands }
    Add_MouseHover = $CommandsTreeviewDeselectAllButtonAdd_MouseHover
}
$Section1TreeViewCommandsTab.Controls.Add($CommandsTreeviewDeselectAllButton)
Add-CommonButtonSettings -Button $CommandsTreeviewDeselectAllButton


$CommandsTreeViewRemoveCommandButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Remove Command"
    Left   = $FormScale * 288
    Top    = $FormScale * 457
    Width  = $FormScale * 150
    Height = $FormScale * 20
    Add_Click = $CommandsTreeViewRemoveCommandButtonAdd_Click
}
Add-CommonButtonSettings -Button $CommandsTreeViewRemoveCommandButton
# Note: This button is added/removed dynamicallly when custom group commands category treenodes are selected


$script:CommandsTreeView = New-Object System.Windows.Forms.TreeView -Property @{
    Left   = $FormScale * 10
    Top    = $FormScale * 70
    Width  = $FormScale * 435
    Height = $FormScale * 415
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    CheckBoxes       = $True
    #LabelEdit       = $True
    ShowLines        = $True
    ShowNodeToolTips = $True
    Add_Click        = { Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes }
}
$script:CommandsTreeView.Sort()
$Section1TreeViewCommandsTab.Controls.Add($script:CommandsTreeView)


$CustomQueryScriptBlockLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = 'Add Custom Command:  '
    Left   = $script:CommandsTreeView.Left + ($FormScale * 5)
    Top    = $script:CommandsTreeView.Top + $script:CommandsTreeView.Height + ($FormScale * 5)
    AutoSize  = $true
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
    ForeColor = 'Black'
}
$Section1TreeViewCommandsTab.controls.add($CustomQueryScriptBlockLabel)


$CustomQueryScriptBlockCheckBoxWinRM = New-Object System.Windows.Forms.RadioButton -Property @{
    Text   = '[WinRM] Query'
    Left   = $CustomQueryScriptBlockLabel.Right + ($FormScale * 5)
    Top    = $script:CommandsTreeView.Top + $script:CommandsTreeView.Height + ($FormScale * 5)
    AutoSize  = $true
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
    ForeColor = 'Blue'
    Add_Click = $CustomQueryScriptBlockCheckBoxWinRMAdd_Click
    Checked = $true
}
$Section1TreeViewCommandsTab.controls.add($CustomQueryScriptBlockCheckBoxWinRM)


$CustomQueryScriptBlockCheckBoxSSH = New-Object System.Windows.Forms.RadioButton -Property @{
    Text   = '[SSH] Query'
    Left   = $CustomQueryScriptBlockCheckBoxWinRM.Right + ($FormScale * 10)
    Top    = $script:CommandsTreeView.Top + $script:CommandsTreeView.Height + ($FormScale * 5)
    AutoSize  = $true
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
    ForeColor = 'Black'
    Add_Click = $CustomQueryScriptBlockCheckBoxSSHAdd_Click
    
}
$Section1TreeViewCommandsTab.controls.add($CustomQueryScriptBlockCheckBoxSSH)


$CustomQueryScriptBlockGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Left   = $script:CommandsTreeView.Left
    Top    = $script:CommandsTreeView.Top + $script:CommandsTreeView.Height + ($FormScale * 6)
    Width  = $script:CommandsTreeView.width
    Height = $FormScale * 68
}
    $script:CustomQueryScriptBlockTextbox = New-Object System.Windows.Forms.Textbox -Property @{
        Text   = 'Enter a command'
        Left   = $FormScale * 7
        Top    = $FormScale * 18
        Width  = $script:CommandsTreeView.width - ($FormScale * 14)
        Height = $FormScale * 22
        ShortcutsEnabled   = $true
        AutoCompleteSource = "CustomSource"
        AutoCompleteMode   = "SuggestAppend"
        Add_KeyDown    = $CustomQueryScriptBlockTextboxAdd_KeyDown
        Add_MouseEnter = $CustomQueryScriptBlockTextboxAdd_MouseEnter
        Add_MouseLeave = $CustomQueryScriptBlockTextboxAdd_MouseLeave
    }
    $script:CmdletList = (Get-Command -CommandType 'Alias', 'Cmdlet', 'Function', 'Workflow').Name
    $script:CustomQueryScriptBlockTextbox.AutoCompleteCustomSource.AddRange($script:CmdletList)
    $CustomQueryScriptBlockGroupBox.controls.add($script:CustomQueryScriptBlockTextbox)
    $script:CustomQueryScriptBlockSaved = $script:CustomQueryScriptBlockTextbox.text


    $script:CustomQueryScriptBlockDisableSyntaxCheckbox = New-Object System.Windows.Forms.Checkbox -Property @{
        Text      = "Disable Syntax`nVerification"
        Left      = $script:CustomQueryScriptBlockTextbox.Left
        Top       = $script:CustomQueryScriptBlockTextbox.top + $script:CustomQueryScriptBlockTextbox.height + ($FormScale * 5)
        Width     = $FormScale * 105
        Height    = $FormScale * 22
        ForeColor = 'Black'
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
        add_click = $CustomQueryScriptBlockDisableSyntaxCheckboxAdd_Click
    }
    $CustomQueryScriptBlockGroupBox.controls.add($script:CustomQueryScriptBlockDisableSyntaxCheckbox)


    $CustomQueryScriptBlockVerifyButton = New-Object System.Windows.Forms.Button -Property @{
        Text   = 'Verify Syntax'
        Left   = $script:CustomQueryScriptBlockDisableSyntaxCheckbox.Left + $script:CustomQueryScriptBlockDisableSyntaxCheckbox.Width + $($FormScale * 5)
        Top    = $script:CustomQueryScriptBlockDisableSyntaxCheckbox.Top
        Width  = $FormScale * 100
        Height = $FormScale * 20
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
        Add_Click = $CustomQueryScriptBlockVerifyButtonAdd_Click
    }
    Add-CommonButtonSettings -Button $CustomQueryScriptBlockVerifyButton
    $CustomQueryScriptBlockGroupBox.controls.add($CustomQueryScriptBlockVerifyButton)


    $CustomQueryScriptBlockSearchAndBuildButton = New-Object System.Windows.Forms.Button -Property @{
        Text   = "Search + Build"
        Left   = $CustomQueryScriptBlockVerifyButton.Left + $CustomQueryScriptBlockVerifyButton.Width + $($FormScale * 5)
        Top    = $CustomQueryScriptBlockVerifyButton.Top
        Width  = $FormScale * 100
        Height = $FormScale * 20
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        Add_click = $CustomQueryScriptBlockSearchAndBuildButtonAdd_Click
    }
    Add-CommonButtonSettings -Button $CustomQueryScriptBlockSearchAndBuildButton
    $CustomQueryScriptBlockGroupBox.controls.add($CustomQueryScriptBlockSearchAndBuildButton)


    $CustomQueryScriptBlockAddCommandButton = New-Object System.Windows.Forms.Button -Property @{
        Text   = 'Add To TreeView'
        Left   = $CustomQueryScriptBlockSearchAndBuildButton.Left + $CustomQueryScriptBlockSearchAndBuildButton.Width + $($FormScale * 5)
        Top    = $CustomQueryScriptBlockVerifyButton.Top
        Width  = $FormScale * 100
        Height = $FormScale * 20
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
        Enabled   = $false
        Add_Click = $CustomQueryScriptBlockAddCommandButtonAdd_Click
    }
    Add-CommonButtonSettings -Button $CustomQueryScriptBlockAddCommandButton
    $CustomQueryScriptBlockGroupBox.controls.add($CustomQueryScriptBlockAddCommandButton)

$Section1TreeViewCommandsTab.controls.add($CustomQueryScriptBlockGroupBox)

# Default View
Initialize-TreeViewCommand

# This adds the nodes to the Commands TreeView
View-TreeViewCommandMethod

$script:CommandsTreeView.Nodes.Add($script:TreeNodeEndpointCommands)
$script:CommandsTreeView.Nodes.Add($script:TreeNodeActiveDirectoryCommands)
$script:CommandsTreeView.Nodes.Add($script:TreeNodeCommandSearch)
$script:CommandsTreeView.Nodes.Add($script:TreeNodeCustomGroupCommands)
$script:CommandsTreeView.Nodes.Add($script:TreeNodeUserAddedCommands)
#$script:CommandsTreeView.ExpandAll()







# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUPv0BQCz1/M/1c9TikKKZ7LS6
# 5qmgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
# AQUFADAzMTEwLwYDVQQDDChQb1NoLUVhc3lXaW4gQnkgRGFuIEtvbW5pY2sgKGhp
# Z2gxMDFicm8pMB4XDTIxMTIxNDA1MDIwMFoXDTMxMTIxNDA1MTIwMFowMzExMC8G
# A1UEAwwoUG9TaC1FYXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALvIxUDFEVGB/G0FXPryoNlF
# dA65j5jPEFM2R4468rjlTVsNYUOR+XvhjmhpggSQa6SzvXtklUJIJ6LgVUpt/0C1
# zlr1pRwTvsd3svI7FHTbJahijICjCv8u+bFcAR2hH3oHFZTqvzWD1yG9FGCw2pq3
# h4ahxtYBd1+/n+jOtPUoMzcKIOXCUe4Cay+xP8k0/OLIVvKYRlMY4B9hvTW2CK7N
# fPnvFpNFeGgZKPRLESlaWncbtEBkexmnWuferJsRtjqC75uNYuTimLDSXvNps3dJ
# wkIvKS1NcxfTqQArX3Sg5qKX+ZR21uugKXLUyMqXmVo2VEyYJLAAAITEBDM8ngUC
# AwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0G
# A1UdDgQWBBSDJIlo6BcZ7KJAW5hoB/aaTLxFzTANBgkqhkiG9w0BAQUFAAOCAQEA
# ouCzal7zPn9vc/C9uq7IDNb1oNbWbVlGJELLQQYdfBE9NWmXi7RfYNd8mdCLt9kF
# CBP/ZjHKianHeZiYay1Tj+4H541iUN9bPZ/EaEIup8nTzPbJcmDbaAGaFt2PFG4U
# 3YwiiFgxFlyGzrp//sVnOdtEtiOsS7uK9NexZ3eEQfb/Cd9HRikeUG8ZR5VoQ/kH
# 2t2+tYoCP4HsyOkEeSQbnxlO9s1jlSNvqv4aygv0L6l7zufiKcuG7q4xv/5OvZ+d
# TcY0W3MVlrrNp1T2wxzl3Q6DgI+zuaaA1w4ZGHyxP8PLr6lMi6hIugI1BSYVfk8h
# 7KAaul5m+zUTDBUyNd91ojGCAegwggHkAgEBMEcwMzExMC8GA1UEAwwoUG9TaC1F
# YXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKQIQeugH5LewQKBKT6dP
# XhQ7sDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkq
# hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGC
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUqvMLz8CE+LoTALTMCHWOqBcHUBwwDQYJKoZI
# hvcNAQEBBQAEggEAhvrjWDQabR3QFMrlbuDKvaO4kxh0qDIlMzLLRroNr8WC6ZOH
# aIh+ZE21IRILNHWsW6Vz9FuMnDEPSbyDmZzIP7OdLu9tZ+sxfSDZntry5e9vlDT8
# V2bhncDL7Y3mPgmYTCIbkUEFPP1X4jF4J5Kwklcx4uhNBOE+Dwi9p46Cw8CfYV/g
# fdzPAQltKxBxkH3dson1Jk1CZYF6FvHF/mjzkXePiTnJ0uBCsngQuo4kr9eC2wtU
# KcGQkV4gtrRkZjg5Phg2DQeTI+467gkKBIusPyVxll2T6sBZgGX/SzC741nXn065
# /4L2oN8FhEax1u5KY0xrZAVg/hdo5hp56nH2VA==
# SIG # End signature block
