$SysinternalsSysmonRenameServiceProcessTextBoxAdd_MouseHover = {
    Show-ToolTip -Title "Rename Sysmon's Service/Process Name" -Icon "Info" -Message @"
+  The default Service/Process name for SysInternals' System Monitor tool is: 'Sysmon'
+  Use this field to obfuscate the service and process name as the tool is running
+  Do NOT add the .exe filename extension; this will be done automatically
+  If this textbox is blank and hovered by the cursor, it will input the default name
+  If a renamed Symmon service push is attempted when sysmon is already installed,
     the script will continue to check for the Renamed Sysmon service exists until it times out
"@

    If ( $($This.Text).Length -eq 0 ) {
        $This.Text = 'Sysmon'
    }

}


