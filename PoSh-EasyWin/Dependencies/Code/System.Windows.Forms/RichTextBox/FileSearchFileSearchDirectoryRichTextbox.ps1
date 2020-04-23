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
"@ 
}
