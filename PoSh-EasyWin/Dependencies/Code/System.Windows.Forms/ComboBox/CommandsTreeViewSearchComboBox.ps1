$CommandsTreeViewSearchComboBoxAdd_KeyDown = {
    if ($_.KeyCode -eq "Enter") {
        Search-CommandTreeNode
    }
}

$CommandsTreeViewSearchComboBoxAdd_MouseHover = {
    Show-ToolTip -Title "Search Input Field" -Icon "Info" -Message @"
+  Searches may be typed in manually.
+  Searches can include any character.
+  There are several default searches available.
"@
}


