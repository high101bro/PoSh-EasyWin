$ExternalProgramsCheckTimeTextBoxAdd_MouseHover = {
    Show-ToolTip -Title "Recheck Time" -Icon "Info" -Message @"
+  This time in seconds is used when external tools recheck the status
+  Essentially, each time the status is checked a query is made to the endpoint(s)
     - This is either visible in network or event logs
"@  
}
