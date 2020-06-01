$EventLogRPCRadioButtonAdd_Click = {
    if ($CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Session Based') {
        $MessageBox = [System.Windows.Forms.MessageBox]::Show("The '$($CommandTreeViewQueryMethodSelectionComboBox.SelectedItem)' mode does not support the RPC Protocol.`nThe 'Individual Execution' mode supports the RPC Protocol, but slower.`n`nDo you want to change the collection mode to 'Individual Execution'?","RPC Protocol Alert",[System.Windows.Forms.MessageBoxButtons]::OKCancel)	
        switch ($MessageBox){
            "OK" {
                # This brings specific tabs to the forefront/front view
                $MainLeftTabControl.SelectedTab   = $Section1CollectionsTab
                $MainBottomTabControl.SelectedTab = $Section3ResultsTab

                $StatusListBox.Items.Clear()
                $StatusListBox.Items.Add("Collection Mode Changed to: Individual Execution")
                $ResultsListBox.Items.Clear()
                $ResultsListBox.Items.Add("The collection mode '$($CommandTreeViewQueryMethodSelectionComboBox.SelectedItem)' does not support the RPC protocol and has been changed to")
                $ResultsListBox.Items.Add("'Individual Execution' which supports both RPC and WinRM, but at the cost of being slower.")
                $CommandTreeViewQueryMethodSelectionComboBox.SelectedIndex = 0 #'Individual Execution'
                $EventLogRPCRadioButton.checked         = $true
                $ExternalProgramsRPCRadioButton.checked = $true
            } 
            "Cancel" { 
                $StatusListBox.Items.Clear()
                $StatusListBox.Items.Add("$($CommandTreeViewQueryMethodSelectionComboBox.SelectedItem) does not support RPC")         
                $EventLogWinRMRadioButton.checked         = $true
                $ExternalProgramsWinRMRadioButton.checked = $true
             } 
        }
    }
    else {
        $ExternalProgramsRPCRadioButton.checked = $true
    }
}

$EventLogRPCRadioButtonAdd_MouseHover = {
    Show-ToolTip -Title "RPC" -Icon "Info" -Message @"
+  Get-WmiObject -Class Win32_NTLogEvent -Filter "(((EventCode='4624') OR (EventCode='4634')) and `
 (TimeGenerated>='$([System.Management.ManagementDateTimeConverter]::ToDmtfDateTime(($EventLogsStartTimePicker.Value)))') and (TimeGenerated<='20190314180030.000000-300'))"
"@  
}
 