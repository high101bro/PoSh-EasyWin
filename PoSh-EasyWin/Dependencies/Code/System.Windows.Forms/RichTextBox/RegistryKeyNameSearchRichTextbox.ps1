$RegistryKeyNameSearchRichTextboxAdd_MouseEnter = { 
    if ($this.text -eq "Enter Key Name; One Per Line") { 
        $this.text = "" 
    } 
}

$RegistryKeyNameSearchRichTextboxAdd_MouseLeave = { 
    if ($this.text -eq "") { 
        $this.text = "Enter Key Name; One Per Line" 
    } 
}

$RegistryKeyNameSearchRichTextboxAdd_MouseHover = {
    Show-ToolTip -Title "Registry Search (WinRM)" -Icon "Info" -Message @"
+  Enter FileNames
+  One Per Line
+  Filenames don't have to include file extension
+  This search will also find the keyword within the filename
+  Example: dhcp
"@ 
}
