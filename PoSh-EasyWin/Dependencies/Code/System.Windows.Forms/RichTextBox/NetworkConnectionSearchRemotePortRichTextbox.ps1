$NetworkConnectionSearchRemotePortRichTextboxAdd_MouseEnter = {
    if ($this.text -eq "Enter Remote Ports; One Per Line") {
        $this.text = ""
    }
}

$NetworkConnectionSearchRemotePortRichTextboxAdd_MouseLeave = {
    if ($this.text -eq "") {
        $this.text = "Enter Remote Ports; One Per Line"
    }
}

$NetworkConnectionSearchRemotePortRichTextboxAdd_MouseHover = {
    Show-ToolTip -Title "Remote Port (WinRM)" -Icon "Info" -Message @"
+  Check hosts for connections to one or more remote ports
+  Enter Remote Ports
+  One Per Line
"@
}


