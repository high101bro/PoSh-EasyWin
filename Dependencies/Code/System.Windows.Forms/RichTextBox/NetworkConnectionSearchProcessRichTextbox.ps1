$NetworkConnectionSearchProcessRichTextboxAdd_MouseEnter = {
    if ($this.text -eq "Enter Process Names; One Per Line") {
        $this.text = ""
    }
}

$NetworkConnectionSearchProcessRichTextboxAdd_MouseLeave = {
    if ($this.text -eq "") {
        $this.text = "Enter Process Names; One Per Line"
    }
}

$NetworkConnectionSearchProcessRichTextboxAdd_MouseHover = {
    Show-ToolTip -Title "Remote Process Name (WinRM)" -Icon "Info" -Message @"
+  Check hosts for connections created by a given process
+  This search will also find the keyword within the process name
+  Enter Remote Process Names
+  One Per Line
"@
}


