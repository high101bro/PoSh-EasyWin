$ComputerTreeNodeSearchComboBoxAdd_KeyDown = { 
    if ($_.KeyCode -eq "Enter") { 
        Search-ComputerTreeNode 
    }
}

$ComputerTreeNodeSearchComboBoxAdd_MouseHover = {
    Show-ToolTip -Title "Search for Hosts" -Icon "Info" -Message @"
+  Searches through host data and returns results as nodes.
+  Search can include any character.
+  Tags are pre-built to assist with standarized notes.
+  Can search CSV Results, enable them in the Options Tab.
"@ 
}
