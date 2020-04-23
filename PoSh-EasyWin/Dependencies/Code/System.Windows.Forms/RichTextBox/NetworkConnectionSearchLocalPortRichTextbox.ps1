$NetworkConnectionSearchLocalPortRichTextboxAdd_MouseEnter = { 
    if ($this.text -eq "Enter Local Ports; One Per Line") { 
        $this.text = "" 
    } 
}

$NetworkConnectionSearchLocalPortRichTextboxAdd_MouseLeave = { 
    if ($this.text -eq "") { 
        $this.text = "Enter Local Ports; One Per Line" 
    } 
}

$NetworkConnectionSearchLocalPortRichTextboxAdd_MouseHover = {
    Show-ToolTip -Title "Local Port (WinRM)" -Icon "Info" -Message @"
+  Check hosts for connections with the listed local port
+  Enter Local Ports
+  One Per Line
"@ 
}
