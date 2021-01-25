$FileSearchFileSearchFileRichTextboxAdd_MouseEnter = {
    if ($this.text -eq "Enter FileNames; One Per Line") {
        $this.text = ""
    }
}

$FileSearchFileSearchFileRichTextboxAdd_MouseLeave = {
    if ($this.text -eq "") {
        $this.text = "Enter FileNames; One Per Line"
    }
}

$FileSearchFileSearchFileRichTextboxAdd_MouseHover = {
    Show-ToolTip -Title "File Search (WinRM)" -Icon "Info" -Message @"
+  Enter FileNames
+  One Per Line
+  Support Regular Expressions (RegEx)
+  Filenames don't have to include file extension
+  This search will also find the keyword within the filename
"@
}


