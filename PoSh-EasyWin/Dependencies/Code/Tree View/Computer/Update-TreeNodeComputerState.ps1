function Update-TreeNodeComputerState {
    param(
    	[switch]$NoMessage
    )
    $script:ComputerTreeView.Nodes.Add($script:TreeNodeComputerList)
    $script:ComputerTreeView.ExpandAll()

    if ($script:ComputerTreeViewSelected.count -gt 0) {
        ##if (-not $NoMessage) {
        ##    #Removed For Testing#$ResultsListBox.Items.Clear()
        ##    $ResultsListBox.Items.Add("Categories that were checked will not remained checked.")
        ##    $ResultsListBox.Items.Add("")
        ##    $ResultsListBox.Items.Add("The following hostname/IP selections are still selected in the new treeview:")
        ##}
        foreach ($root in $AllHostsNode) {
            foreach ($Category in $root.Nodes) {
                foreach ($Entry in $Category.nodes) {
                    $Entry.Collapse()
                    if ($script:ComputerTreeViewSelected -contains $Entry.text -and $root.text -notmatch 'Query History') {
                        $Entry.Checked      = $true
                        $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                        $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,0,224)
                        $Category.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                        $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                       ## $ResultsListBox.Items.Add(" - $($Entry.Text)")
                    }
                    foreach ($Metadata in $Entry.Nodes){
                        $Metadata.Drawing = $False
                    }
                }
            }
        }
    }
    else {
        foreach ($root in $AllHostsNode) {
            foreach ($Category in $root.Nodes) {
                foreach ($Entry in $Category.Nodes) {
                    $Entry.Collapse()
                    foreach ($Metadata in $Entry.Nodes){
                        $Metadata.Drawing = $false
                    }
                }
            }
        }
    }
}


