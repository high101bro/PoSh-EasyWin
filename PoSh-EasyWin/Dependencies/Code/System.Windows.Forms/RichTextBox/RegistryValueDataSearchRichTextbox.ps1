$RegistryValueDataSearchRichTextboxAdd_MouseEnter = {
    if ($this.text -eq "Enter Value Data; One Per Line") {
        $this.text = ""
    }
}

$RegistryValueDataSearchRichTextboxAdd_MouseLeave = {
    if ($this.text -eq "") {
        $this.text = "Enter Value Data; One Per Line"
    }
}

$RegistryValueDataSearchRichTextboxAdd_MouseHover = {
    Show-ToolTip -Title "Registry Search (WinRM)" -Icon "Info" -Message @"
+  Enter FileNames
+  One Per Line
+  Example: svchost
+  Filenames don't have to include file extension
+  This search will also find the keyword within the filename
"@
}


