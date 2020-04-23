$EndpointsWithNoSessions = @()
Foreach ($Endpoint in $ComputerList) {
    if ($Endpoint -notin $PSSession.ComputerName) { $EndpointsWithNoSessions += $Endpoint }
}
if ($EndpointsWithNoSessions.count -gt 0) {
    [system.media.systemsounds]::Exclamation.play()
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Unchecked $($EndpointsWithNoSessions.Count) Endpoints Without Sessions")
    $PoShEasyWin.Refresh()
    [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerTreeView.Nodes 
    foreach ($root in $AllHostsNode) { 
        foreach ($Category in $root.Nodes) { 
            $Category.Checked = $False
            $EntryNodeCheckedCount = 0
            foreach ($Entry in $Category.nodes) {
                if ($EndpointsWithNoSessions -icontains $($Entry.Text)) {
                    $Entry.Checked         = $False
                    $Entry.NodeFont        = New-Object System.Drawing.Font("$Font",10,1,1,1)
                    $Entry.ForeColor       = [System.Drawing.Color]::FromArgb(0,0,0,0)
                }
                if ($Entry.Checked) {
                    $EntryNodeCheckedCount += 1                  
                }
            }   
            if ($EntryNodeCheckedCount -eq 0) {
                $Category.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
                $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
            }
        }         
    }
    Start-Sleep -Seconds 3
}
