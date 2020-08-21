$ComputerListNSLookupCheckedToolStripButtonAdd_Click = {
    if ($script:ComputerTreeViewSelected.count -eq 0){
        [System.Windows.MessageBox]::Show('Error: You need to check at least one endpoint.','NSLookup')
    }
    else {
        $MainBottomTabControl.SelectedTab = $Section3HostDataTab

        $script:ProgressBarEndpointsProgressBar.Value     = 0
        $script:ProgressBarQueriesProgressBar.Value       = 0

        Create-ComputerNodeCheckBoxArray 
        if ($script:ComputerTreeViewSelected.count -ge 0) {

            $MessageBox = [System.Windows.Forms.MessageBox]::Show("Conduct an NSLookup of $($script:ComputerTreeViewSelected.count) endpoints?","NSLookup",'YesNo','Info')
            Switch ( $MessageBox ) {
                'Yes' {
                    $MessageBoxAnswer = $true
                }
                'No' {
                    $MessageBoxAnswer = $false
                    $StatusListBox.Items.Clear()
                    $StatusListBox.Items.Add('NSLookup Cancelled')
                }
            }

            $script:ProgressBarEndpointsProgressBar.Maximum  = $script:ComputerTreeViewSelected.count
            [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerTreeView.Nodes

            if ($MessageBoxAnswer -eq $true) {
                $ComputerListNSLookupArray = @()
                foreach ($node in $script:ComputerTreeViewSelected) {    
                    foreach ($root in $AllHostsNode) {
                        foreach ($Category in $root.Nodes) { 
                            foreach ($Entry in $Category.Nodes) {
                                $LookupEndpoint = $null
                                
                                if ($Entry.Checked -and $Entry.Text -notin $ComputerListNSLookupArray) {
                                    $ComputerListNSLookupArray += $Entry.Text
                                    $Section3HostDataNameTextBox.Text = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).Name
                                    $Section3HostDataOSTextBox.Text   = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).OperatingSystem
                                    $Section3HostDataOUTextBox.Text   = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).CanonicalName
                                    
                                    $LookupEndpoint = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).Name
                                    $NSlookup = $((Resolve-DnsName "$LookupEndpoint" | Sort-Object IPAddress | Select-Object -ExpandProperty IPAddress -Unique) -Join ', ')
                                    $Section3HostDataIPTextBox.Text   = $NSlookup

                                    $Section3HostDataMACTextBox.Text  = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).MACAddress
                                    $Section3HostDataNotesRichTextBox.Text = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).Notes
                                    Save-ComputerTreeNodeHostData
#                                    Save-HostData
                                
                                }
                                $script:ProgressBarEndpointsProgressBar.Value += 1
                            }
                        }
                    }  
                }
 #               Save-ComputerTreeNodeHostData -SaveAllChecked
 #               Check-HostDataIfModified
                $StatusListBox.Items.clear()
                $StatusListBox.Items.Add("NSLookup Complete: $($script:ComputerTreeViewSelected.count) Endpoints")
            }
        }
    }
}
