$CommandsTreeviewDeselectAllButtonAdd_Click = {
    Deselect-AllCommands
}

$CommandsTreeviewDeselectAllButtonAdd_MouseHover = {
    Show-ToolTip -Title "Deselect All" -Icon "Info" -Message @"
+  Unchecks all commands checked within this view.
+  Commands and queries in other Tabs must be manually unchecked.
"@
}


