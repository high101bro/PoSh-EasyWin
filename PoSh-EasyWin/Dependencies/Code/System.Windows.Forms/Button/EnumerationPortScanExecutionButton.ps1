$EnumerationPortScanExecutionButtonAdd_Click = {
    if (Verify-Action -Title "Verification: Port Scan" -Question "Conduct a Port Scan of the following?" -Computer $(
        if( $script:EnumerationPortScanSpecificComputerNodeCheckbox.checked ){
            Generate-ComputerList
            ($script:ComputerList.split(',') -join ', ')
        }
        else {
            if ($EnumerationPortScanSpecificIPTextbox.Text -and $EnumerationPortScanIPRangeNetworkTextbox.Text -and $EnumerationPortScanIPRangeFirstTextbox.Text -and $EnumerationPortScanIPRangeLastTextbox.Text ) {
                $EnumerationPortScanSpecificIPTextbox.Text + ', ' + $EnumerationPortScanIPRangeNetworkTextbox.Text + '.' + $EnumerationPortScanIPRangeFirstTextbox.Text + '-' + $EnumerationPortScanIPRangeLastTextbox.Text
            }
            elseif ($EnumerationPortScanSpecificIPTextbox.Text) {
                $EnumerationPortScanSpecificIPTextbox.Text
            }
            elseif ($EnumerationPortScanIPRangeNetworkTextbox.Text -and $EnumerationPortScanIPRangeFirstTextbox.Text -and $EnumerationPortScanIPRangeLastTextbox.Text) {
                $EnumerationPortScanIPRangeNetworkTextbox.Text + '.' + $EnumerationPortScanIPRangeFirstTextbox.Text + '-' + $EnumerationPortScanIPRangeLastTextbox.Text
            }
        }
        )) {
        $ResultsListBox.Items.Clear()
        if ($script:EnumerationPortScanSpecificComputerNodeCheckbox.checked){
            Conduct-PortScan `
            -Timeout_ms $EnumerationPortScanTimeoutTextbox.Text `
            -TestWithICMPFirst $EnumerationPortScanTestICMPFirstCheckBox.Checked `
            -EndpointList `
            -SpecificPortsToScan $EnumerationPortScanSpecificPortsTextbox.Text `
            -FirstPort $EnumerationPortScanPortRangeFirstTextbox.Text `
            -LastPort $EnumerationPortScanPortRangeLastTextbox.Text
        }
        else {
            Conduct-PortScan `
            -Timeout_ms $EnumerationPortScanTimeoutTextbox.Text `
            -TestWithICMPFirst $EnumerationPortScanTestICMPFirstCheckBox.Checked `
            -SpecificIPsToScan $EnumerationPortScanSpecificIPTextbox.Text `
            -SpecificPortsToScan $EnumerationPortScanSpecificPortsTextbox.Text `
            -Network $EnumerationPortScanIPRangeNetworkTextbox.Text `
            -FirstIP $EnumerationPortScanIPRangeFirstTextbox.Text `
            -LastIP $EnumerationPortScanIPRangeLastTextbox.Text `
            -FirstPort $EnumerationPortScanPortRangeFirstTextbox.Text `
            -LastPort $EnumerationPortScanPortRangeLastTextbox.Text
        }
    }
    else {
        [system.media.systemsounds]::Exclamation.play()
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Port Scan:  Cancelled")
    }

    Update-TreeNodeComputerState -NoMessage
}


