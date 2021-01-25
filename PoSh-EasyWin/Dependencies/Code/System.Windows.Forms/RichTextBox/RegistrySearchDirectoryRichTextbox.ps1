$RegistrySearchDirectoryRichTextboxAdd_MouseEnter = {
    if ($this.text -eq "Enter Registry Paths; One Per Line") {
        $this.text = ""
    }
}

$RegistrySearchDirectoryRichTextboxAdd_MouseLeave = {
    if ($this.text -eq "") {
        $this.text = "Enter Registry Paths; One Per Line"
    }
}

$RegistrySearchDirectoryRichTextboxAdd_MouseHover = {
    Show-ToolTip -Title "Registry Search (WinRM)" -Icon "Info" -Message @"
+  Enter Directories
+  One Per Line
+  Example: HKLM:\SYSTEM\CurrentControlSet\Services\
"@
}


