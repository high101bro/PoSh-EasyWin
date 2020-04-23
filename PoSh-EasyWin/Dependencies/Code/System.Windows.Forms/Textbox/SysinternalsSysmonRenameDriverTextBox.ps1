$SysinternalsSysmonRenameDriverTextBoxAdd_MouseHover = {
    Show-ToolTip -Title "Rename Sysmon's Driver Name" -Icon "Info" -Message @"
+  The default Driver name for SysInternals' System Monitor tool is: 'SysmonDrv'
+  Use this field to obfuscate the driver's name when installed
+  There is an 8 character limit when renaming the driver
+  If this textbox is blank and hovered by the cursor, it will input the default name
+  If you don't know the Sysmon Driver name, either leave the field empty or as its default
"@
    If ( $($This.Text).Length -eq 0 ) {
        $This.Text = 'SysmonDrv'
    }
}
