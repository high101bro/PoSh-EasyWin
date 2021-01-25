$FileSearchDirectoryListingTextboxAdd_MouseEnter = {
    if ($this.text -eq "Enter a single directory") {
        $this.text = ""
    }
}

$FileSearchDirectoryListingTextboxAdd_MouseLeave = {
    if ($this.text -eq "") {
        $this.text = "Enter a single directory"
    }
}

$FileSearchDirectoryListingTextboxAdd_MouseHover = {
    Show-ToolTip -Title "Directory Listing (WinRM)" -Icon "Info" -Message @"
+  Enter a single directory
+  Example - C:\Windows\System32
"@
}


