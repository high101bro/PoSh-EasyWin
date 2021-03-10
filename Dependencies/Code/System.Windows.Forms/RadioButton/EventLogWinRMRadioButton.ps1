$EventLogWinRMRadioButtonAdd_Click = {
    $ExternalProgramsWinRMRadioButton.checked = $true
}

$EventLogWinRMRadioButtonAdd_MouseHover = {
    Show-ToolTip -Title "WinRM" -Icon "Info" -Message @"
+  Invoke-Command -ComputerName <Endpoint> -ScriptBlock {
 Get-WmiObject -Class Win32_NTLogEvent -Filter "(((EventCode='4624') OR (EventCode='4634')) and `
 (TimeGenerated>='20190313180030.000000-300') and (TimeGenerated<='20190314180030.000000-300')) }"
"@
}


