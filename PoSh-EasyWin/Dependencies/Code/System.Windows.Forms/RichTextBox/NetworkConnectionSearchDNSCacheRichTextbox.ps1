$NetworkConnectionSearchDNSCacheRichTextboxAdd_MouseEnter = {
    if ($this.text -eq "Enter DNS query information or IP addresses; One Per Line") {
        $this.text = "" }
}

$NetworkConnectionSearchDNSCacheRichTextboxAdd_MouseLeave = {
    if ($this.text -eq "") {
        $this.text = "Enter DNS query information or IP addresses; One Per Line"
    }
}

$NetworkConnectionSearchDNSCacheRichTextboxAdd_MouseHover = {
    Show-ToolTip -Title "Remote DNS Cache Entry (WinRM)" -Icon "Info" -Message @"
+  Check hosts' DNS Cache for entries that match given criteria
+  The DNS Cache is not persistence on systems
+  By default, Windows stores positive responses in the DNS Cache for 86,400 seconds (1 day)
+  By default, Windows stores negative responses in the DNS Cache for 300 seconds (5 minutes)
+  The default DNS Cache time limits can be changed within the registry
+  Enter DNS query information or IP addresses
+  One Per Line
"@
}


