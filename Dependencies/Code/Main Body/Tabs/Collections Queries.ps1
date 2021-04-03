
$Section1CommandsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = "Queries"
    Left   = $FormScale * $Column1RightPosition
    Top    = $FormScale * $Column1DownPosition
    Width  = $FormScale * $Column1BoxWidth
    Height = $FormScale * ($Column1BoxHeight + 10)
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
}
$MainLeftCollectionsTabControl.Controls.Add($Section1CommandsTab)


# Imports all the Endpoint Commands fromthe csv file
$script:AllEndpointCommands = Import-Csv $CommandsEndpoint

# Imports scripts from the Endpoint script folder and loads them into the treeview
# New scripts can be added to 'Dependencies\Cmds & Scripts\Scirpts - Endpoint' to be imported
# Verify that the scripts function properly and return results with the Invoke-Command cmdlet
Update-FormProgress "$Dependencies\Code\Main Body\Import-EndpointScripts.ps1"
. "$Dependencies\Code\Main Body\Import-EndpointScripts.ps1"
Import-EndpointScripts


# Imports all the Active Directoyr Commands fromthe csv file
$script:AllActiveDirectoryCommands = Import-Csv $CommandsActiveDirectory

# Imports scripts from the Active Directory script folder and loads them into the treeview
# New scripts can be added to 'Dependencies\Cmds & Scripts\Scirpts - Active Directory' to be imported
# Verify that the scripts function properly and return results with the Invoke-Command cmdlet
Update-FormProgress "$Dependencies\Code\Main Body\Import-ActiveDirectoryScripts.ps1"
. "$Dependencies\Code\Main Body\Import-ActiveDirectoryScripts.ps1"
Import-ActiveDirectoryScripts


# Initializes/empties the Custom Group Commands array
# Queries executed will be stored within this array and added later to as treenodes
$script:CustomGroupCommandsListListListList = @()


#======================================================================
#   ______             _    ___                 ______          __
#  /_  __/_______  ___| |  / (_)__ _      __   / ____/___  ____/ /__
#   / / / ___/ _ \/ _ \ | / / / _ \ | /| / /  / /   / __ \/ __  / _ \
#  / / / /  /  __/  __/ |/ / /  __/ |/ |/ /  / /___/ /_/ / /_/ /  __/
# /_/ /_/   \___/\___/|___/_/\___/|__/|__/   \____/\____/\__,_/\___/
#
#======================================================================

$script:TreeeViewComputerListCount = 0
$script:TreeeViewCommandsCount     = 0

# Handles the behavior of nodes when clicked, such as checking all sub-checkboxes, changing text colors, and Tabs selected.
# Also counts the total number of checkboxes checked (both command and computer treenodes, and other query checkboxes) and
# changes the color of the start collection button to-and-from Green.
Update-FormProgress "$Dependencies\Code\Tree View\Conduct-NodeAction.ps1"
. "$Dependencies\Code\Tree View\Conduct-NodeAction.ps1"

# Initializes the Commands TreeView section that various command nodes are added to
# TreeView initialization initially happens upon load and whenever the it is regenerated, like when switching between views
# These include the root nodes of Search, Endpoint and Active Directory queryies by method and type, and Custom Group Commands
Update-FormProgress "$Dependencies\Code\Tree View\Command\Initialize-CommandTreeNodes.ps1"
. "$Dependencies\Code\Tree View\Command\Initialize-CommandTreeNodes.ps1"

# This will keep the Command TreeNodes checked when switching between Method and Command views
Update-FormProgress "$Dependencies\Code\Tree View\Command\Update-TreeNodeCommandState.ps1"
. "$Dependencies\Code\Tree View\Command\Update-TreeNodeCommandState.ps1"

# Adds a treenode to the specified root node... a command node within a category node
Update-FormProgress "$Dependencies\Code\Tree View\Command\Add-NodeCommand.ps1"
. "$Dependencies\Code\Tree View\Command\Add-NodeCommand.ps1"

$script:HostQueryTreeViewSelected = ""

# This builds out the Commands TreeView with command nodes
# The TreeNodes are organized by the Method the queries are conducted, eg: RPC, WinRM
Update-FormProgress "$Dependencies\Code\Tree View\Command\View-CommandTreeNodeMethod.ps1"
. "$Dependencies\Code\Tree View\Command\View-CommandTreeNodeMethod.ps1"

# This builds out the Commands TreeView with command nodes
# The TreeNodes are organized by the Query/Commannd Topic the queries are conducted, eg: Processes, Services
Update-FormProgress "$Dependencies\Code\Tree View\Command\View-CommandTreeNodeQuery.ps1"
. "$Dependencies\Code\Tree View\Command\View-CommandTreeNodeQuery.ps1"

# Deselects all nodes within the indicated treeview
Update-FormProgress "$Dependencies\Code\Main Body\DeselectAllCommands.ps1"
. "$Dependencies\Code\Main Body\DeselectAllCommands.ps1"

Update-FormProgress "$Dependencies\Code\Main Body\DeselectAllComputers.ps1"
. "$Dependencies\Code\Main Body\DeselectAllComputers.ps1"


# Initially imports the Custom Group Commands and populates the command treenode
$script:CustomGroupCommands = Import-CliXml "$Dependencies\Custom Group Commands.xml"
foreach ($Command in $script:CustomGroupCommands) {
    $Command | Add-Member -MemberType NoteProperty -Name CategoryName -Value "$($Command.CategoryName)" -Force
    Add-NodeCommand -RootNode $script:TreeNodeCustomGroupCommands -Category "$($Command.CategoryName)" -Entry "$($Command.Name)" -ToolTip $Command.Command
}
$script:CustomGroupCommandsList = $script:CustomGroupCommands

function Update-CustomCommandGroup {
    Compile-SelectedCommandTreeNode

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
    $CommandGroupCategoryName = $script:CollectionSavedDirectoryTextBox.Text | Split-Path -Leaf
    foreach ($Command in $CommandsCheckedBoxesSelectedDedup) { 
        Add-NodeCommand -RootNode $script:TreeNodeCustomGroupCommands -Category $CommandGroupCategoryName -Entry "$($Command.Name)" -ToolTip "$($Command.Command)"
        $CustomCommandGroupKeepSelected += [pscustomobject]@{
            CategoryName = $CommandGroupCategoryName
            Name         = $Command.Name
            Command      = $Command.Command
        }
    }

    $script:CustomGroupCommandsList + $CustomCommandGroupKeepSelected | Export-CliXml "$Dependencies\Custom Group Commands.xml"

    $script:CustomGroupCommands = Import-CliXml "$Dependencies\Custom Group Commands.xml"
    foreach ($Command in $script:CustomGroupCommands) {
        $Command | Add-Member -MemberType NoteProperty -Name CategoryName -Value "$($Command.CategoryName)" -Force
        Add-NodeCommand -RootNode $script:TreeNodeCustomGroupCommands -Category "$($Command.CategoryName)" -Entry "$($Command.Name)" -ToolTip $Command.Command
    }
    $script:CustomGroupCommandsList = $script:CustomGroupCommands

    Remove-Variable -name CommandsCheckedBoxesSelectedTemp
    Remove-Variable -name CommandsCheckedBoxesSelectedDedup
    Remove-Variable -name CustomCommandGroupKeepSelected
    Remove-Variable -name CustomGroupCommands

    $script:CommandsTreeView.Nodes.Clear()
    Initialize-CommandTreeNodes
    View-CommandTreeNodeMethod
    Update-TreeNodeCommandState
}

$CommandsTreeViewViewByGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text   = "Display And Group By:"
    Left   = $FormScale * 0
    Top    = $FormScale * 5
    Width  = $FormScale * 231
    Height = $FormScale * 37
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
    ForeColor = 'Blue'
}
            Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RadioButton\CommandsViewMethodRadioButton.ps1"
            . "$Dependencies\Code\System.Windows.Forms\RadioButton\CommandsViewMethodRadioButton.ps1"
            $CommandsViewProtocolsUsedRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text      = "Protocol"
                Left      = $FormScale * 10
                Top       = $FormScale * 13
                Width     = $FormScale * 95
                Height    = $FormScale * 22
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
                Checked   = $True
                Add_Click = $CommandsViewProtocolsUsedRadioButtonAdd_Click
                Add_MouseHover = $CommandsViewProtocolsUsedRadioButtonAdd_MouseHover
            }
            $CommandsTreeViewViewByGroupBox.Controls.Add( $CommandsViewProtocolsUsedRadioButton )


            Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RadioButton\CommandsViewQueryRadioButton.ps1"
            . "$Dependencies\Code\System.Windows.Forms\RadioButton\CommandsViewQueryRadioButton.ps1"
            $CommandsViewCommandNamesRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text      = "Command Name"
                Left      = $CommandsViewProtocolsUsedRadioButton.Left + $CommandsViewProtocolsUsedRadioButton.Width
                Top       = $CommandsViewProtocolsUsedRadioButton.Top
                Width     = $FormScale * 115
                Height    = $FormScale * 22
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
                Checked   = $false
                Add_Click = $CommandsViewCommandNamesRadioButtonAdd_Click
                Add_MouseHover = $CommandsViewCommandNamesRadioButtonAdd_MouseHover
            }
            $CommandsTreeViewViewByGroupBox.Controls.Add($CommandsViewCommandNamesRadioButton)
$Section1CommandsTab.Controls.Add($CommandsTreeViewViewByGroupBox)


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
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
                Add_SelectedValueChanged = {
                    $script:CommandsTreeView.Nodes.Clear()
                    Initialize-CommandTreeNodes
                    View-CommandTreeNodeMethod
                    Update-TreeNodeCommandState
                    $CommandsViewProtocolsUsedRadioButton.Checked = $true
                    $This.Text | Set-Content "$PoShHome\Settings\Display Commands Filter.txt" -Force
                }
            }
            $QueryTypeList = @('All (WinRM,RPC,SMB,SSH)','WinRM','RPC','SMB','SSH')
            foreach ( $QueryType in $QueryTypeList ) { $CommandsViewFilterComboBox.Items.Add("$QueryType") }
            if (Get-Content "$PoShHome\Settings\Display Commands Filter.txt") {
                $CommandsViewFilterComboBox.Text = Get-Content "$PoShHome\Settings\Display Commands Filter.txt"
            }
            else {
                $CommandsViewFilterComboBox.Text = 'All (WinRM,RPC,SMB,SSH)'
            }
            $CommandsTreeViewFilterGroupBox.Controls.Add( $CommandsViewFilterComboBox )

$Section1CommandsTab.Controls.Add($CommandsTreeViewFilterGroupBox)

# $PoShEasyWinLogoPictureBox = New-Object System.Windows.Forms.PictureBox -Property @{
#     #text     = "PoSh-EasyWin Image"
#     Left     = $CommandsTreeViewViewByGroupBox.Left + $CommandsTreeViewViewByGroupBox.Width + ($FormScale * + 15)
#     Top      = $FormScale * $CommandsTreeViewViewByGroupBox.Top
#     Width    = $FormScale * 175
#     Height   = $FormScale * 35
#     AutoSize = $true
#     SizeMode = 'Stretch'
#     Image    = [System.Drawing.Image]::FromFile("$Dependencies\PoSh-EasyWin Image.png" )
#     #InitialImage = $null
#     #ErrorImage   = $null
# }
# $Section1CommandsTab.Controls.Add($PoShEasyWinLogoPictureBox)


# Searches for command nodes that match a given search entry
# A new category node named by the search entry will be created and all results will be nested within
Update-FormProgress "$Dependencies\Code\Tree View\Command\Search-CommandTreeNode.ps1"
. "$Dependencies\Code\Tree View\Command\Search-CommandTreeNode.ps1"


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\ComboBox\CommandsTreeViewSearchComboBox.ps1"
. "$Dependencies\Code\System.Windows.Forms\ComboBox\CommandsTreeViewSearchComboBox.ps1"
$CommandsTreeViewSearchComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Name     = "Search TextBox"
    Left     = $FormScale * 0
    Top      = $FormScale * 45
    Width    = $FormScale * 170
    Height   = $FormScale * 25
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
    Add_KeyDown    = $CommandsTreeViewSearchComboBoxAdd_KeyDown
    Add_MouseHover = $CommandsTreeViewSearchComboBoxAdd_MouseHover
}
    $CommandTypes = @("Chart","File","Hardware","Hunt","Network","System","User")
    ForEach ($Type in $CommandTypes) { [void] $CommandsTreeViewSearchComboBox.Items.Add($Type) }
$Section1CommandsTab.Controls.Add($CommandsTreeViewSearchComboBox)


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\CommandsTreeViewSearchButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\CommandsTreeViewSearchButton.ps1"
$CommandsTreeViewSearchButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Search"
    Left   =  $CommandsTreeViewSearchComboBox.Width + $($FormScale * 5)
    Top    = $FormScale * 45
    Width  = $FormScale * 55
    Height = $FormScale * 22
    Add_Click      = $CommandsTreeViewSearchButtonAdd_Click
    Add_MouseHover = $CommandsTreeViewSearchButtonAdd_MouseHover
}
$Section1CommandsTab.Controls.Add($CommandsTreeViewSearchButton)
CommonButtonSettings -Button $CommandsTreeViewSearchButton


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\CommandsTreeviewGroupCommandsButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\CommandsTreeviewGroupCommandsButton.ps1"
$CommandsTreeviewGroupCommandsButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Group Commands'
    Left   = $CommandsTreeViewSearchButton.Left + $CommandsTreeViewSearchButton.Width + ($FormScale * 5)
    Top    = $FormScale * 45
    Width  = $FormScale * 110
    Height = $FormScale * 22
    Add_Click      = {
        [System.Windows.Forms.MessageBox]::Show("Currently, the group node name will use the 'Results Folder' name of:`n`n`t$($script:CollectionSavedDirectoryTextBox.Text | Split-Path -Leaf)`n`nYou can delete the groups by checkboxing the node and selecting Remove Command Group Button when it appears.",'PoSh-EasyWin Group Commands')
        Update-CustomCommandGroup
    }
}
$Section1CommandsTab.Controls.Add($CommandsTreeviewGroupCommandsButton)
CommonButtonSettings -Button $CommandsTreeviewGroupCommandsButton


$CommandsTreeviewDeselectAllButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Deselect All'
    Left   = $CommandsTreeviewGroupCommandsButton.Left + $CommandsTreeviewGroupCommandsButton.Width + ($FormScale * 5)
    Top    = $FormScale * 45
    Width  = $FormScale * 84
    Height = $FormScale * 22
    Add_Click      = { Deselect-AllCommands }
    Add_MouseHover = {
        Show-ToolTip -Title "Deselect All" -Icon "Info" -Message @"
+  Unchecks all commands checked within this view.
+  Commands and queries in other Tabs must be manually unchecked.
"@        
    }
}
$Section1CommandsTab.Controls.Add($CommandsTreeviewDeselectAllButton)
CommonButtonSettings -Button $CommandsTreeviewDeselectAllButton


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\CommandsTreeViewQueryHistoryRemovalButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\CommandsTreeViewQueryHistoryRemovalButton.ps1"
$CommandsTreeViewCustomGroupCommandsRemovalButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Remove Command Group"
    Left   = $FormScale * 278
    Top    = $FormScale * 430
    Width  = $FormScale * 150
    Height = $FormScale * 22
    Add_Click = $CommandsTreeViewCustomGroupCommandsRemovalButtonAdd_Click
}
CommonButtonSettings -Button $CommandsTreeViewCustomGroupCommandsRemovalButton
# Note: This button is added/removed dynamicallly when custom group commands category treenodes are selected


$script:CommandsTreeView = New-Object System.Windows.Forms.TreeView -Property @{
    Left   = 0
    Top    = $FormScale * 70
    Width  = $FormScale * 435
    Height = $FormScale * 395
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    CheckBoxes       = $True
    #LabelEdit       = $True
    ShowLines        = $True
    ShowNodeToolTips = $True
    Add_Click        = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
    Add_AfterSelect  = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
}
$script:CommandsTreeView.Sort()
$Section1CommandsTab.Controls.Add($script:CommandsTreeView)


# Scriptblock that is executed to manage the Query Build features such as the interactions between
# the textbox and button, launching Show-Command, variable manipulation, and message prompts
Update-FormProgress "$Dependencies\Code\Main Body\CustomQueryScriptBlock.ps1"
. "$Dependencies\Code\Main Body\CustomQueryScriptBlock.ps1"

$CustomQueryScriptBlockCheckBox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = '[WinRM] Query:'
    Left   = $script:CommandsTreeView.Left + ($FormScale * 9)
    Top    = $script:CommandsTreeView.Top + $script:CommandsTreeView.Height + ($FormScale * 5)
    AutoSize  = $true
    Enabled   = $false
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands
        if ($script:CustomQueryScriptBlockTextbox.text -ne $script:CustomQueryScriptBlockSaved) {
            $CustomQueryScriptBlockCheckBox.checked = $false
            $CustomQueryScriptBlockCheckBox.enabled = $false
        }
    }
}
$Section1CommandsTab.controls.add($CustomQueryScriptBlockCheckBox)


$CustomQueryScriptBlockGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Left   = $script:CommandsTreeView.Left
    Top    = $script:CommandsTreeView.Top + $script:CommandsTreeView.Height + ($FormScale * 6)
    Width  = $script:CommandsTreeView.width
    Height = $FormScale * 68
}
            $script:CustomQueryScriptBlockTextbox = New-Object System.Windows.Forms.Textbox -Property @{
                Text   = 'Enter A Get Cmdlet (ex: Get-Process)'
                Left   = $FormScale * 7
                Top    = $FormScale * 18
                Width  = $script:CommandsTreeView.width - ($FormScale * 14)
                Height = $FormScale * 22
                ShortcutsEnabled   = $true
                AutoCompleteSource = "CustomSource"
                AutoCompleteMode   = "SuggestAppend"
                Add_KeyDown    = { if ($_.KeyCode -eq "Enter") {  Invoke-Command $CustomQueryScriptBlock } }
                Add_MouseEnter = {
                    if ($this.text -ne $script:CustomQueryScriptBlockSaved) {
                        $CustomQueryScriptBlockCheckBox.checked = $false
                        $CustomQueryScriptBlockCheckBox.enabled = $false
                    }
                    if ($this.text -eq 'Enter A Get Cmdlet (ex: Get-Process)'){
                        $this.text = 'Get-'
                        $CustomQueryScriptBlockCheckBox.checked = $false
                        $CustomQueryScriptBlockCheckBox.enabled = $false
                    }
                    if ($this.text -eq 'Enter Any Cmdlet'){
                        $this.text = ''
                        $CustomQueryScriptBlockCheckBox.checked = $false
                        $CustomQueryScriptBlockCheckBox.enabled = $false
                    }
                }
                Add_MouseLeave = {
                    if ($this.text -ne $script:CustomQueryScriptBlockSaved) {
                        $CustomQueryScriptBlockCheckBox.enabled = $false
                    }
                    if ($CustomQueryScriptBlockOverrideCheckBox.checked) {
                        if ($this.text -eq ''){
                            $this.text = 'Enter Any Cmdlet'
                            $CustomQueryScriptBlockCheckBox.checked = $false
                            $CustomQueryScriptBlockCheckBox.enabled = $false
                        }
                    }
                    elseif (-not $CustomQueryScriptBlockOverrideCheckBox.checked) {
                        if ($this.text -eq '' -or $this.text -eq 'Get-' -or $this.text -eq 'Get'){
                            $this.text = 'Enter A Get Cmdlet (ex: Get-Process)'
                            $CustomQueryScriptBlockCheckBox.checked = $false
                            $CustomQueryScriptBlockCheckBox.enabled = $false
                        }
                    }
                }
            }
            $script:CmdletList = (Get-Command -CommandType 'Alias', 'Cmdlet', 'Function', 'Workflow').Name | Where-Object {$_ -like "Get-*"}
            $script:CustomQueryScriptBlockTextbox.AutoCompleteCustomSource.AddRange($script:CmdletList)
            $CustomQueryScriptBlockGroupBox.controls.add($script:CustomQueryScriptBlockTextbox)


            $CustomQueryScriptBlockButton = New-Object System.Windows.Forms.Button -Property @{
                Text   = 'Modify Parameters'
                Left   = $script:CustomQueryScriptBlockTextbox.Left
                Top    = $script:CustomQueryScriptBlockTextbox.top + $script:CustomQueryScriptBlockTextbox.height + ($FormScale * 5)
                Width  = $FormScale * 135
                Height = $FormScale * 22
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                Add_Click = { Invoke-Command $CustomQueryScriptBlock }
            }
            CommonButtonSettings -Button $CustomQueryScriptBlockButton
            $CustomQueryScriptBlockGroupBox.controls.add($CustomQueryScriptBlockButton)


            $CustomQueryScriptBlockOverrideCheckBox = New-Object System.Windows.Forms.CheckBox -Property @{
                Text   = 'Allow All Verbs'
                Left   = $CustomQueryScriptBlockButton.Left + $CustomQueryScriptBlockButton.width + ($FormScale * 10)
                Top    = $script:CustomQueryScriptBlockTextbox.Top + $script:CustomQueryScriptBlockTextbox.Height + ($FormScale * 5)
                AutoSize  = $true
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                Add_click = {
                    if ($this.checked) {
                        $script:CustomQueryScriptBlockTextbox.AutoCompleteCustomSource.Clear()
                        $script:CmdletList = (Get-Command -CommandType 'Alias', 'Cmdlet', 'Function', 'Workflow').Name
                        $script:CustomQueryScriptBlockTextbox.AutoCompleteCustomSource.AddRange($script:CmdletList)
                        $script:CustomQueryScriptBlockTextbox.text = 'Enter Any Cmdlet'
                        $CustomQueryScriptBlockCheckBox.enabled = $false
                    }
                    else {
                        $script:CustomQueryScriptBlockTextbox.AutoCompleteCustomSource.Clear()
                        $script:CmdletList = (Get-Command -CommandType 'Alias', 'Cmdlet', 'Function', 'Workflow').Name | Where-Object {$_ -like "Get-*"}
                        $script:CustomQueryScriptBlockTextbox.AutoCompleteCustomSource.AddRange($script:CmdletList)
                        $script:CustomQueryScriptBlockTextbox.text = 'Enter A Get Cmdlet (ex: Get-Process)'
                        $CustomQueryScriptBlockCheckBox.enabled = $false
                    }
                }
            }
            $CustomQueryScriptBlockGroupBox.controls.add($CustomQueryScriptBlockOverrideCheckBox)

$Section1CommandsTab.controls.add($CustomQueryScriptBlockGroupBox)

# Default View
Initialize-CommandTreeNodes

# This adds the nodes to the Commands TreeView
View-CommandTreeNodeMethod

$script:CommandsTreeView.Nodes.Add($script:TreeNodeEndpointCommands)
$script:CommandsTreeView.Nodes.Add($script:TreeNodeActiveDirectoryCommands)
$script:CommandsTreeView.Nodes.Add($script:TreeNodeCommandSearch)
$script:CommandsTreeView.Nodes.Add($script:TreeNodeCustomGroupCommands)
#$script:CommandsTreeView.ExpandAll()