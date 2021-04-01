$RekallWinPmemMemoryCaptureButtonAdd_MouseHover = {
    Show-ToolTip -Title "Memory Capture" -Icon "Info" -Message @"
+  Uses Rekall WinPmem to retrieve memory for analysis.
+  The memory.raw file collected can be used with Volatility or windbg.
+  It supports all windows versions from WinXP SP2 to Windows 10.
+  It supports processor types: i386 and amd64.
+  Uses RPC/DCOM `n`n
"@
}


$RekallWinPmemMemoryCaptureButtonAdd_Click = {
    # This brings specific tabs to the forefront/front view
    $InformationTabControl.SelectedTab = $Section3ResultsTab

    # Ensures only one endpoint is selected
    # This array stores checkboxes that are check; a minimum of at least one checkbox will be needed later in the script
    $script:ComputerTreeViewSelected = @()
    [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerTreeView.Nodes
    foreach ($root in $AllHostsNode) {
        if ($root.Checked) {
            foreach ($Category in $root.Nodes) { foreach ($Entry in $Category.nodes) { $script:ComputerTreeViewSelected += $Entry.Text } }
        }
        foreach ($Category in $root.Nodes) {
            if ($Category.Checked) {
                foreach ($Entry in $Category.nodes) { $script:ComputerTreeViewSelected += $Entry.Text }
            }
            foreach ($Entry in $Category.nodes) {
                if ($Entry.Checked) {
                    $script:ComputerTreeViewSelected += $Entry.Text
                }
            }
        }
    }
    #Removed For Testing#$ResultsListBox.Items.Clear()
    if ($script:ComputerTreeViewSelected.count -eq 1) {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Rekall WinPMem:  $($script:ComputerTreeViewSelected)")
        #Removed For Testing#$ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Launching Memory Collection Window")
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Launched Memory Collection Window"
        Launch-RekallWinPmemForm
    }
    elseif ($script:ComputerTreeViewSelected.count -lt 1) { ComputerNodeSelectedLessThanOne -Message 'Rekall WinPmem' }
    elseif ($script:ComputerTreeViewSelected.count -gt 1) { ComputerNodeSelectedMoreThanOne -Message 'Rekall WinPmem' }
}



