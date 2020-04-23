$ExternalProgramsRPCRadioButtonAdd_Click = {
    if ($CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Session Based') {
        $MessageBox = [System.Windows.Forms.MessageBox]::Show("The '$($CommandTreeViewQueryMethodSelectionComboBox.SelectedItem)' mode does not support the RPC Protocol.`nThe 'Individual Execution' mode supports the RPC Protocol, but is much slower.`n`nDo you want to change the collection mode to 'Individual Execution'?","RPC Protocol Alert",[System.Windows.Forms.MessageBoxButtons]::OKCancel)	
        switch ($MessageBox){
            "OK" {
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
        $EventLogRPCRadioButton.checked = $true 
    }
}

$ExternalProgramsRPCRadioButtonAdd_MouseHover = {
    Show-ToolTip -Title "RPC" -Icon "Info" -Message @'
+  Commands Used: (example)
     Copy-Item .\LocalDir\Procmon.exe "\\Endpoint\C$\Windows\Temp"
     Invoke-WmiMethod -ComputerName 'Endpoint' -Class Win32_Process -Name Create -ArgumentList "$Path\Procmon.exe -accepteula [...etc]"
     Remove-Item "\\Endpoint\C$\Windows\Temp\Procmon.exe" -Force
'@  
}
  