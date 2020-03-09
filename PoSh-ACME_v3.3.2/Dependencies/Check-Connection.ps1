function Check-Connection {
    param (
        $CheckType,
        $MessageTrue,
        $MessageFalse
    )
    # This brings specific tabs to the forefront/front view
    $Section4TabControl.SelectedTab   = $Section3ResultsTab

    # This array stores checkboxes that are check; a minimum of at least one checkbox will be needed later in the script
    $script:ComputerTreeNodeSelected = @()
    [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerTreeNode.Nodes 
    foreach ($root in $AllHostsNode) { 
        if ($root.Checked) {
            foreach ($Category in $root.Nodes) { foreach ($Entry in $Category.nodes) { $script:ComputerTreeNodeSelected += $Entry.Text } }
        }
        foreach ($Category in $root.Nodes) { 
            if ($Category.Checked) {
                foreach ($Entry in $Category.nodes) { $script:ComputerTreeNodeSelected += $Entry.Text }       
            }
            foreach ($Entry in $Category.nodes) {
                if ($Entry.Checked) {
                    $script:ComputerTreeNodeSelected += $Entry.Text
                }
            }       
        }         
    }
    $script:ComputerTreeNodeSelected = $script:ComputerTreeNodeSelected | Select-Object -Unique

    $ResultsListBox.Items.Clear()
    if ($script:ComputerTreeNodeSelected.count -lt 1) { ComputerNodeSelectedLessThanOne -Message $CheckType }
    else {
        $StatusListBox.Items.Clear()    
        $StatusListBox.Items.Add("$($CheckType):  $($script:ComputerTreeNodeSelected.count) hosts")    
        Start-Sleep -Milliseconds 50
        $NotReachable = @()
        foreach ($target in $script:ComputerTreeNodeSelected){
            if ($CheckType -eq "Ping") { $CheckCommand = Test-Connection -Count 1 -ComputerName $target }
            elseif ($CheckType -eq "WinRM Check") {
                $CheckCommand = Test-WSman -ComputerName $target
                # The following does a ping first...
                # Test-NetConnection -CommonTCPPort WINRM -ComputerName <Target>
            }
            elseif ($CheckType -eq "RPC Check") {
                function Test-Port {
                    param ($ComputerName, $Port)
                    begin { $tcp = New-Object Net.Sockets.TcpClient }
                    process {
                        try { $tcp.Connect($ComputerName, $Port) } catch {}
                        if ($tcp.Connected) { $tcp.Close(); $open = $true }
                        else { $open = $false }
                        [PSCustomObject]@{ IP = $ComputerName; Port = $Port; Open = $open }
                    }
                }
                $CheckCommand = Test-Port -ComputerName $target -Port 135 | Select-Object -ExpandProperty Open
                # The following does a ping first...
                # Test-NetConnection -Port 135 -ComputerName <Target>
            }
            foreach ($line in $target){
                if($CheckCommand){$ResultsListBox.Items.Insert(0,"$($MessageTrue):    $target"); Start-Sleep -Milliseconds 50}
                else {
                    $ResultsListBox.Items.Insert(0,"$($MessageFalse):  $target")
                    $NotReachable += $target
                    }
                    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message " - $CheckCommand"
            }
        }
        # Popup windows requesting user action
        [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic")
        $verify = [Microsoft.VisualBasic.Interaction]::MsgBox(`
            "Do you want to uncheck unresponsive hosts?",`
            #'YesNoCancel,Question',`
            'YesNo,Question',`
            "PoSh-ACME")
        switch ($verify) {
        'Yes'{
            [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerTreeNode.Nodes 
            foreach ($root in $AllHostsNode) { 
                foreach ($Category in $root.Nodes) { 
                    $Category.Checked = $False
                    $EntryNodeCheckedCount = 0
                    foreach ($Entry in $Category.nodes) {
                        if ($NotReachable -icontains $($Entry.Text)) {
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
        }
        'No'     {continue}
        #'Cancel' {exit}
        }
        $ResultsListBox.Items.Insert(0,"")
        $ResultsListBox.Items.Insert(0,"Finished Testing Connections")
    }
}