$RegistryValueNameSearchRichTextboxAdd_MouseEnter = {
    if ($this.text -eq "Enter Value Name; One Per Line") {
        $this.text = ""
    }
}

$RegistryValueNameSearchRichTextboxAdd_MouseLeave = {
    if ($this.text -eq "") {
        $this.text = "Enter Value Name; One Per Line"
    }
}

$RegistryValueNameSearchRichTextboxAdd_MouseHover = {
    Show-ToolTip -Title "Registry Search (WinRM)" -Icon "Info" -Message @"
+  Enter one Value Name per line
+  Supports RegEx, examples:
    +  [aeiou]
    +  ([0-9]{1,3}\.){3}[0-9]{1,3}
    +  [(http)(https)]://
    +  ^[(http)(https)]://
    +  [a-z0-9]
+  Will return results with partial matches
"@
}


