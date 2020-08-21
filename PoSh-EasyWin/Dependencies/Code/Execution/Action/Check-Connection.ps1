function Check-Connection {
    param (
        $CheckType,
        [string[]]$ComputerTreeViewSelected,
        $MessageTrue,
        $MessageFalse
    )
    # This brings specific tabs to the forefront/front view
    $MainBottomTabControl.SelectedTab   = $Section3ResultsTab

    $ResultsListBox.Items.Clear()
    if ($ComputerTreeViewSelected.count -lt 1) { ComputerNodeSelectedLessThanOne -Message $CheckType }
    else {
        $StatusListBox.Items.Clear()    
        $StatusListBox.Items.Add("$($CheckType):  $($ComputerTreeViewSelected.count) hosts")    

        $script:ProgressBarEndpointsProgressBar.Maximum = $ComputerTreeViewSelected.count
        $script:ProgressBarEndpointsProgressBar.Value   = 0
    

        Start-Sleep -Milliseconds 50
        

        # Testing the Workflow concept to speedup connection testing...
        <#
        workflow Parallel-ConnectionTest {
            param(
                [string[]]$ComputerTreeViewSelected
            )
            $ConnectionTestResults = @()
            foreach -parallel -throttlelimit 30 ($Computer in $ComputerTreeViewSelected) {
                $workflow:ConnectionTestResults += Test-Connection -ComputerName $Computer -Count 1 
                InlineScript {
                    $script:ProgressBarEndpointsProgressBar.Value += 1
                    write-host 'inline test'
                    write-host $Using:ComputerTreeViewSelected
                }
            }
            InlineScript {
                $Using:ConnectionTestResults
                $script:ProgressBarEndpointsProgressBar.Value += 1
                #$ResultsListBox.Items.Insert(0,"$($MessageTrue):    $target")
                #Start-Sleep -Milliseconds 50
                #$PoShEasyWin.Refresh()

            }
        }
        Parallel-ConnectionTest -ComputerTreeViewSelected $script:ComputerTreeViewSelected
        #>
        


        $NotReachable = @()
        foreach ($target in $ComputerTreeViewSelected){
            
            if ($CheckType -eq "Ping") { 
                $CheckCommand = Test-Connection -Count 1 -ComputerName $target 
            }
            elseif ($CheckType -eq "WinRM Check") {
                $CheckCommand = Test-WSman -ComputerName $target
                # The following does a ping first...
                # Test-NetConnection -CommonTCPPort WINRM -ComputerName <Target>
            }
            
            elseif ($CheckType -eq "RPC/DCOM Check") {
                #$CheckCommand = Test-Connection -Count 1 -ComputerName $target -Protocol DCOM

                # The following tests for the default RPC port, but not the service itself
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
            elseif ($CheckType -eq "SMB Check") {
                # The following tests for the default RPC port, but not the service itself
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
                $CheckCommand = Test-Port -ComputerName $target -Port 445 | Select-Object -ExpandProperty Open

                # The following does a ping first...
                # Test-NetConnection -Port 135 -ComputerName <Target>
            }
            

            foreach ($line in $target){
                if($CheckCommand){
                    $ResultsListBox.Items.Insert(0,"$($MessageTrue):    $target")
                    Start-Sleep -Milliseconds 50
                    $PoShEasyWin.Refresh()
                }
                else {
                    $ResultsListBox.Items.Insert(0,"$($MessageFalse):  $target")
                    $NotReachable += $target
                }
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message " - $CheckCommand"
                $PoShEasyWin.Refresh()
            }
            $script:ProgressBarEndpointsProgressBar.Value += 1
        }

        # Popup windows requesting user action
        [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic")
        $verify = [Microsoft.VisualBasic.Interaction]::MsgBox(`
            "Do you want to uncheck unresponsive hosts?",`
            #'YesNoCancel,Question',`
            'YesNo,Question',`
            "PoSh-EasyWin")
        switch ($verify) {
            'Yes'{
                [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerTreeView.Nodes 
                foreach ($root in $AllHostsNode) { 
                    $root.Checked = $False
                    foreach ($Category in $root.Nodes) { 
                        $Category.Checked = $False
                        $EntryNodeCheckedCount = 0
                        foreach ($Entry in $Category.nodes) {
                            if ($NotReachable -icontains $($Entry.Text)) {
                                $Entry.Checked   = $False
                                $Entry.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                                $Entry.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
                            }
                            if ($Entry.Checked) {
                                $EntryNodeCheckedCount += 1                  
                            }
                        }   
                        if ($EntryNodeCheckedCount -eq 0) {
                            $Category.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
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