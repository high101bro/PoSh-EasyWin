$CommandsViewCommandNamesRadioButtonAdd_Click = {
    #$StatusListBox.Items.Clear()
    #$StatusListBox.Items.Add("Display And Group By:  Query")

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
    Initialize-CommandTreeNodes
    View-CommandTreeNodeQuery
    Update-TreeNodeCommandState
}

$CommandsViewCommandNamesRadioButtonAdd_MouseHover = {
    Show-ToolTip -Title "Display by Command Grouping" -Icon "Info" -Message @"
+  Displays commands grouped by queries
+  All commands executed against each host are logged
"@
}



