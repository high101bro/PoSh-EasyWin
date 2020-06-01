$script:OptionJobTimeoutSelectionComboBoxAdd_MouseHover = {
    Show-ToolTip -Title "Sets the Background Job Timeout" -Icon "Info" -Message @"
+  Queries are threaded and not executed serially like typical scripts.
+  This is done in command order for each host checked.
"@ 
}
