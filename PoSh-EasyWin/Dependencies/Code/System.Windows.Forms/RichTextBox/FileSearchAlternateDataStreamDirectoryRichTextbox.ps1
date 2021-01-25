$FileSearchAlternateDataStreamDirectoryRichTextboxAdd_MouseEnter = {
    if ($this.text -eq "Enter Directories; One Per Line") {
        $this.text = ""
    }
}

$FileSearchAlternateDataStreamDirectoryRichTextboxAdd_MouseLeave = {
    if ($this.text -eq "") {
        $this.text = "Enter Directories; One Per Line"
    }
}

$FileSearchAlternateDataStreamDirectoryRichTextboxAdd_MouseHover = {
    Show-ToolTip -Title "Alternate Data Stream Search (WinRM)" -Icon "Info" -Message @"
+  Enter Directories
+  One Per Line
"@ }


