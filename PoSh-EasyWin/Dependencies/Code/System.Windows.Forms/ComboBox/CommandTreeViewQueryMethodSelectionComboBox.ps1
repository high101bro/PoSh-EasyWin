$CommandTreeViewQueryMethodSelectionComboBoxAdd_SelectedIndexChanged = {
    $SelectedIndexTemp = $this.SelectedIndex
    if ( ($EventLogRPCRadioButton.checked -or $ExternalProgramsRPCRadioButton.checked -or $script:RpcCommandCount -gt 0 -or $script:SmbCommandCount -gt 0) -and $this.SelectedItem -eq 'Session Based' ) {
        $MessageBox = [System.Windows.Forms.MessageBox]::Show("The '$($CommandTreeViewQueryMethodSelectionComboBox.SelectedItem)' mode does not support the RPC and SMB protocols.`nThe 'Individual Execution' collection mode supports the RPC, SMB, and WinRM protocols - but may be slower and noisier on the network.`n`nDo you want to change to 'Session Based' collection using the WinRM protocol?","Protocol Alert",[System.Windows.Forms.MessageBoxButtons]::OKCancel)	
        switch ($MessageBox){
            "OK" {
                $StatusListBox.Items.Clear()
                $StatusListBox.Items.Add("Event Log Protocol Set To WinRM")
                $EventLogWinRMRadioButton.checked         = $true
                $ExternalProgramsWinRMRadioButton.checked = $true

                $RpcCommandNodesRemoved = @()
                $SmbCommandNodesRemoved = @()
                [System.Windows.Forms.TreeNodeCollection]$AllCommandsNode = $script:CommandsTreeView.Nodes 
                foreach ($root in $AllCommandsNode) { 
                    foreach ($Category in $root.Nodes) {
                        foreach ($Entry in $Category.nodes) { 
                            if ($Entry.Checked -and $Entry.Text -match '[\[(]rpc[)\]]') { 
                                $root.Checked     = $false 
                                $Category.Checked = $false 
                                $Entry.Checked    = $false 
                                $RpcCommandNodesRemoved += $Entry
                            }
                            elseif ($Entry.Checked -and $Entry.Text -match '[\[(]smb[)\]]') { 
                                $root.Checked     = $false 
                                $Category.Checked = $false 
                                $Entry.Checked    = $false 
                                $SmbCommandNodesRemoved += $Entry
                            }
                        }
                    }
                }
                Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands

                # This brings specific tabs to the forefront/front view
                $MainLeftTabControl.SelectedTab = $Section1CollectionsTab
                $MainBottomTabControl.SelectedTab = $Section3ResultsTab

                $ResultsListBox.Items.Clear()
                if ($RpcCommandNodesRemoved.count -gt 0) {
                    $ResultsListBox.Items.Add("The following RPC queries have been unchecked:")
                    foreach ($Entry in $RpcCommandNodesRemoved) {
                        $ResultsListBox.Items.Add("   $($Entry.Text)")
                    }
                }
                if ($SmbCommandNodesRemoved.count -gt 0) {
                    $ResultsListBox.Items.Add("The following SMB queries have been unchecked:")
                    foreach ($Entry in $SmbCommandNodesRemoved) {
                        $ResultsListBox.Items.Add("   $($Entry.Text)")
                    }
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
