$NetworkConnectionSearchRemoteIPAddressRichTextboxAdd_MouseEnter = {
    if ($this.text -eq "Enter Remote IPs; One Per Line"){
        $this.text = ""
    }
}

$NetworkConnectionSearchRemoteIPAddressRichTextboxAdd_MouseLeave = {
    if ($this.text -eq "") {
        $this.text = "Enter Remote IPs; One Per Line"
    }
}

$NetworkConnectionSearchRemoteIPAddressRichTextboxAdd_MouseHover = {
    Show-ToolTip -Title "Remote IP Address (WinRM)" -Icon "Info" -Message @"
+  Check hosts for connections to one or more remote IP addresses
+  Enter Remote IPs
+  One Per Line
"@
}


