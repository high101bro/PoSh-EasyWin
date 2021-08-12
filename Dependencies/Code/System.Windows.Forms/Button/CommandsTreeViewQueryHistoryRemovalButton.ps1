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
        $Section1CommandsTab.Controls.Remove($CommandsTreeViewRemoveCommandButton)
    
        # iterates through the list of non-checked commands and re-adds them to the command treeview
        $QueryHistoryKeepGroupSelected = @()
        foreach ($Category in $QueryHistoryKeepGroupCategoryList) {
            foreach ($Entry in $Category.nodes) {
                $QueryHistoryKeepGroupSelected += [pscustomobject]@{
                    CategoryName = $Category.Text
                    Name         = $Entry.Text
                }
                Add-NodeCommand -RootNode $script:TreeNodeCustomGroupCommands -Category "$($Category.text)" -Entry "$($Entry.Text)" -ToolTip $Command.Command
            }
        }
        $script:CustomGroupCommandsList = $QueryHistoryKeepGroupSelected
        $QueryHistoryKeepGroupSelected | Export-CliXml $CommandsCustomGrouped


        # iterates through the list of non-checked commands and re-adds them to the command treeview
        $CommandsUserAddedAddedList = @()
        $CommandsUserAddedToKeep = @()
        foreach ($Entry in $QueryHistoryKeepUserAddedEntryList) {
            Foreach ($command in $script:UserAddedCommands){
                if ($Entry.text -match $command.name -and $command -notin $CommandsUserAddedAddedList){
                    $CommandsUserAddedAddedList += $command
                    Add-NodeCommand -RootNode $script:TreeNodeUserAddedCommands -Category $("{0,-10}{1}" -f "[WinRM]", "PowerShell Cmdlets") -Entry "(WinRM) PoSh -- $($Command.Name)" -ToolTip "$($command.Command_WinRM_PoSh)"
                    $CommandsUserAddedToKeep += $command  
                }
            }
        }

        # Save remaining User Added Commands
        $script:UserAddedCommands = $CommandsUserAddedToKeep
        $script:UserAddedCommands | Export-Csv $CommandsUserAdded -NoTypeInformation

        # Save remaining Custom Group Commands List
        $QueryHistoryKeepGroupSelected | Export-CliXml $CommandsCustomGrouped
    }
}


