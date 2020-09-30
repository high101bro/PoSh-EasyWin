$ComputerTreeNodeSaveButtonAdd_Click = {
    Save-HostData
    $ComputerTreeNodeSaveButton.Text      = "TreeView`nSaved"
    $ComputerTreeNodeSaveButton.Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    $ComputerTreeNodeSaveButton.ForeColor = "Green"
}

$ComputerTreeNodeSaveButtonAdd_MouseHover = {
    Show-ToolTip -Title "Start Collection" -Icon "Warning" -Message @"
+  Saves changes made to the Computer TreeView and their data
+  Once saved, the data is loaded automatically upon PoSh-EasyWin startup
+  Location: "$ComputerTreeNodeFileSave"

+  Autosaves are made immedately when changes are made
+  Autosaves are not loaded upon PoSh-EasyWin reload, use 'Import .CSV'
+  Location: "$ComputerTreeNodeFileAutoSave"
"@
}


