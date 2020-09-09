$FileSearchFileSearchDirectoryRichTextboxAdd_MouseEnter = { 
    if ($this.text -eq "Enter Directories; One Per Line") { 
        $this.text = "" 
    } 
}

$FileSearchFileSearchDirectoryRichTextboxAdd_MouseLeave = { 
    if ($this.text -eq "") { 
        $this.text = "Enter Directories; One Per Line" 
    } 
}

$FileSearchFileSearchDirectoryRichTextboxAdd_MouseHover = {
    Show-ToolTip -Title "File Search (WinRM)" -Icon "Info" -Message @"
+  Enter Directories
+  One Per Line
+  You can include wild cards in directory paths:
     Ex:  c:\users\*\appdata\local\temp\*
"@ 
}
