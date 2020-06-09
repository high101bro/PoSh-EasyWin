$ImportFromADWinRMManuallEntryRichTextBoxAdd_MouseEnter = { 
    if ($this.text -eq "<Enter a hostname/IP>") { 
        $this.text = "" 
    } 
}

$ImportFromADWinRMManuallEntryRichTextBoxAdd_MouseLeave = { 
    if ($this.text -eq "") { 
        $this.text = "<Enter a hostname/IP>" 
    } 
}

$ImportFromADWinRMManuallEntryRichTextBoxAdd_MouseHover = {
    Show-ToolTip -Title "Hostname or IP Address" -Icon "Info" -Message @"
+  Enter the hostname or IP address of the Active Directory Server
+  Example: dc1
"@ 
}
