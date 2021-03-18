$script:Section3HostDataNameTextBoxAdd_MouseHover = {
    Show-ToolTip -Title "Hostname" -Icon "Info" -Message @"
+  This field is reserved for the hostname.
+  Hostnames are not case sensitive.
+  Though IP addresses may be entered, WinRM queries may fail as
    IPs may only be used for authentication under certain conditions.
"@
}


