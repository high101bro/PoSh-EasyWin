$CommandTreeViewQueryMethodSelectionComboBoxAdd_SelectedIndexChanged = {
    $SelectedIndexTemp = $this.SelectedIndex
    if ( ($EventLogRPCRadioButton.checked -or $ExternalProgramsRPCRadioButton.checked ) -and $this.SelectedItem -eq 'Session Based' ) {
        $MessageBox = [System.Windows.Forms.MessageBox]::Show("The '$($CommandTreeViewQueryMethodSelectionComboBox.SelectedItem)' mode does not support the RPC Protocol.`nThe 'Individual Execution' mode supports the RPC Protocol, but is much slower.`n`nDo you want to change the Event Log collection Protocol to WinRM?","RPC Protocol Alert",[System.Windows.Forms.MessageBoxButtons]::OKCancel)	
        switch ($MessageBox){
            "OK" {
                $StatusListBox.Items.Clear()
                $StatusListBox.Items.Add("Event Log Protocol Set To WinRM")
                $EventLogWinRMRadioButton.checked         = $true
                $ExternalProgramsWinRMRadioButton.checked = $true

                $CommandNodesRemoved = @()
                [System.Windows.Forms.TreeNodeCollection]$AllCommandsNode = $script:CommandsTreeView.Nodes 
                foreach ($root in $AllCommandsNode) { 
                    foreach ($Category in $root.Nodes) {
                        foreach ($Entry in $Category.nodes) { 
                            if ($Entry.Checked -and $Entry.Text -match '[\[(]rpc[)\]]') { 
                                $root.Checked     = $false 
                                $Category.Checked = $false 
                                $Entry.Checked    = $false 
                                $CommandNodesRemoved += $Entry
                            }
                        }
                    }
                }
                Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands

                # This brings specific tabs to the forefront/front view
                $MainLeftTabControl.SelectedTab = $Section1CollectionsTab
                $MainBottomTabControl.SelectedTab = $Section3ResultsTab

                $ResultsListBox.Items.Clear()
                $ResultsListBox.Items.Add("The following RPC queries have been unchecked:")
                foreach ($Entry in $CommandNodesRemoved) {
                    $ResultsListBox.Items.Add("   $($Entry.Text)")
                }

                
            } 
            "Cancel" { 
                $this.SelectedIndex = 0 #'Individual Execution'                
#                $StatusListBox.Items.Clear()
#                $StatusListBox.Items.Add("$($CommandTreeViewQueryMethodSelectionComboBox.SelectedItem) does not support RPC")
             } 
        }

    }

}
