$SysinternalsProcmonRenameProcessTextBoxAdd_MouseHover = {
    Show-ToolTip -Title "Rename Procmon's Process Name" -Icon "Info" -Message @"
    +  The default process name for SysInternals' Process Monitor tool is: 'Procmon'
    +  Do NOT add the .exe filename extension; this will be done automatically
    +  Use this field to obfuscate the process name as the tool is running
    +  If this textbox is blank and hovered by the cursor, it will input the default name
"@
    If ( $($This.Text).Length -eq 0 ) {
        $This.Text = 'Procmon'
    }
}


