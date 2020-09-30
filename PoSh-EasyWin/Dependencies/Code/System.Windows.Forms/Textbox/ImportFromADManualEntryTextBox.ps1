$ImportFromADManualEntryTextBoxAdd_MouseEnter = {
    if ($this.text -eq "<Domain Name>") {
        $this.text = ""
    }
}

$ImportFromADManualEntryTextBoxAdd_MouseLeave = {
    if ($this.text -eq "") {
        $this.text = "<Domain Name>"
    }
}

$ImportFromADManualEntryTextBoxAdd_MouseHover = {
    Show-ToolTip -Title "Domain Name" -Icon "Info" -Message @"
+  Enter the Domain Name of the Active Directory Server
+  Example: training.lab or east.company.com
"@
}


