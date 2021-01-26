$ExeScriptSelectScriptButtonAdd_MouseHover = {
    Show-ToolTip -Title "Select Script" -Icon "Info" -Message @"
+  Select a Script to be sent and used within endpoints
+  This script needs to execute/start with the accompaning executable
+  Results and outputs to copy back need to be manually scripted
+  Cleanup and removal of the executable, script, and any results need to be scripted
+  Validate the executable and script combo prior to use within a production network
+  The script is  copied to the endpoints' C:\Windows\Temp directory
"@
}


