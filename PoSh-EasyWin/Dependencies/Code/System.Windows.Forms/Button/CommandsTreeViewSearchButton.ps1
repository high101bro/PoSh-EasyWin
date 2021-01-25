$CommandsTreeViewSearchButtonAdd_Click = {
    Search-CommandTreeNode
}

$CommandsTreeViewSearchButtonAdd_MouseHover = {
    Show-ToolTip -Title "Command Search" -Icon "Info" -Message @"
+  Searches through query names and metadata.
+  Search results are returned as nodes.
+  Search results are not persistent.
"@
}


