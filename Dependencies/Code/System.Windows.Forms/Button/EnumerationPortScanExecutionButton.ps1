$EnumerationPortScanExecutionButtonAdd_Click = {
    if (Verify-Action -Title "Verification: Port Scan" -Question "Conduct a Port Scan of the following?" -Computer $(
        $CollectionName = 'Enumeration Scanning'
    
        if ( $script:EnumerationPortScanSpecificComputerNodeCheckbox.checked ) {
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
        

        if ($script:EnumerationPortScanSpecificComputerNodeCheckbox.checked) {
            $EndpointString = ''
            foreach ($item in $script:ComputerList) {$EndpointString += "$item`n"}
        }
        else {
            $EndpointString = 'Details are listed in the section beneath'
        }
                
        $InputValues = @"
===========================================================================
Collection Name:
===========================================================================
$CollectionName

===========================================================================
Execution Time:
===========================================================================
$(Get-Date)

===========================================================================
Credentials:
===========================================================================
$($script:Credential.UserName)

===========================================================================
Endpoints:
===========================================================================
$($EndpointString.trim())

===========================================================================
Specified IPs To Scan:
===========================================================================
$($EnumerationPortScanSpecificIPTextbox.Text)

===========================================================================
Network Range:
===========================================================================
$($EnumerationPortScanIPRangeNetworkTextbox.Text):$($EnumerationPortScanIPRangeFirstTextbox.Text)-$($EnumerationPortScanIPRangeLastTextbox.Text)

===========================================================================
Quick Port Selection:
===========================================================================
$($EnumerationPortScanPortQuickPickComboBox.SelectedItem)

===========================================================================
Specified Ports To Scan:
===========================================================================
$($EnumerationPortScanSpecificPortsTextbox.Text)

===========================================================================
Port Range:
===========================================================================
$($EnumerationPortScanPortRangeFirstTextbox.Text)-$($EnumerationPortScanPortRangeLastTextbox.Text)

===========================================================================
Test With ICMP First:
===========================================================================
$($EnumerationPortScanTestICMPFirstCheckBox.Checked)

===========================================================================
Timeout (ms):
===========================================================================
$($EnumerationPortScanTimeoutTextbox.Text)


"@        

        if ($script:ComputerListPivotExecutionCheckbox.checked -eq $false) {
            #if ($script:EnumerationPortScanMonitorJobsCheckbox.checked -eq $false) {
                $InformationTabControl.SelectedTab = $Section3ResultsTab
                
                # NOTE: Credentials are not necessarily needed to conduct scanning
                if ($script:EnumerationPortScanSpecificComputerNodeCheckbox.checked -eq $true){
                    Conduct-PortScan `
                        -ComputerList $ComputerList `
                        -EnumerationPortScanPortQuickPickComboBoxSelectedItem $EnumerationPortScanPortQuickPickComboBox.SelectedItem `
                        -Timeout_ms $EnumerationPortScanTimeoutTextbox.Text `
                        -TestWithICMPFirst $EnumerationPortScanTestICMPFirstCheckBox.Checked `
                        -EndpointList `
                        -SpecificPortsToScan $EnumerationPortScanSpecificPortsTextbox.Text `
                        -FirstPort $EnumerationPortScanPortRangeFirstTextbox.Text `
                        -LastPort $EnumerationPortScanPortRangeLastTextbox.Text
                }
                elseif ($script:EnumerationPortScanSpecificComputerNodeCheckbox.checked -eq $false){
                    Conduct-PortScan `
                        -EnumerationPortScanPortQuickPickComboBoxSelectedItem $EnumerationPortScanPortQuickPickComboBox.SelectedItem `
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
            #}
            #### ERROR. For some reason the Invoke-Command locally with Monitor-Job version isn't working... maybe I'll work on this later
            # elseif ($script:EnumerationPortScanMonitorJobsCheckbox.checked -eq $true) {
            #     $InformationTabControl.SelectedTab = $Section3MonitorJobsTab

            #     $EnumerationPortScanPortQuickPickComboBoxSelectedItem = $EnumerationPortScanPortQuickPickComboBox.SelectedItem
            #     $EnumerationPortScanTimeoutTextboxtext = $EnumerationPortScanTimeoutTextbox.text
            #     $EnumerationPortScanTestICMPFirstCheckBoxchecked = $EnumerationPortScanTestICMPFirstCheckBox.checked
            #     $EnumerationPortScanSpecificPortsTextboxtext = $EnumerationPortScanSpecificPortsTextbox.text
            #     $EnumerationPortScanPortRangeFirstTextboxtext = $EnumerationPortScanPortRangeFirstTextbox.text
            #     $EnumerationPortScanPortRangeLastTextboxtext = $EnumerationPortScanPortRangeLastTextbox.text
                
            #     # NOTE: Credentials are not necessarily needed to conduct scanning
            #     if ($script:EnumerationPortScanSpecificComputerNodeCheckbox.checked -eq $true) {
            #         $ConductPortScan = "function Conduct-PortScan { ${function:Conduct-PortScan} }"
            #         Invoke-Command -ScriptBlock {
            #             Param($ConductPortScan,$ComputerList,$EnumerationPortScanPortQuickPickComboBoxSelectedItem,$EnumerationPortScanTimeoutTextbox,$EnumerationPortScanTestICMPFirstCheckBox,$EnumerationPortScanSpecificPortsTextbox,$EnumerationPortScanPortRangeFirstTextbox,$EnumerationPortScanPortRangeLastTextbox)
            #             $ErrorActionPreference = 'SilentlyContinue'
            #             . ([ScriptBlock]::Create($ConductPortScan))

            #             Conduct-PortScan `
            #                 -ComputerList $ComputerList `
            #                 -EnumerationPortScanPortQuickPickComboBoxSelectedItem $EnumerationPortScanPortQuickPickComboBoxSelectedItem `
            #                 -Timeout_ms $EnumerationPortScanTimeoutTextbox `
            #                 -TestWithICMPFirst $EnumerationPortScanTestICMPFirstCheckBox `
            #                 -EndpointList `
            #                 -SpecificPortsToScan $EnumerationPortScanSpecificPortsTextbox `
            #                 -FirstPort $EnumerationPortScanPortRangeFirstTextbox `
            #                 -LastPort $EnumerationPortScanPortRangeLastTextbox
            #         } `
            #         -ArgumentList @($ConductPortScan,$script:ComputerList,$EnumerationPortScanPortQuickPickComboBox.SelectedItem,$EnumerationPortScanTimeoutTextbox.text,$EnumerationPortScanTestICMPFirstCheckBox.checked,$EnumerationPortScanSpecificPortsTextbox.text,$EnumerationPortScanPortRangeFirstTextbox.text,$EnumerationPortScanPortRangeLastTextbox.text) `
            #         -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- localhost"

            #         Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:Conduct-PortScan} -ArgumentList @($ConductPortScan,$script:ComputerList,$EnumerationPortScanPortQuickPickComboBox.SelectedItem,$EnumerationPortScanTimeoutTextbox.text,$EnumerationPortScanTestICMPFirstCheckBox.checked,$EnumerationPortScanSpecificPortsTextbox.text,$EnumerationPortScanPortRangeFirstTextbox.text,$EnumerationPortScanPortRangeLastTextbox.text) -InputValues $InputValues -DisableReRun -JobsExportFiles 'true'
            #     }
            #     elseif ($script:EnumerationPortScanSpecificComputerNodeCheckbox.checked -eq $false) {
            #         $ConductPortScan = "function Conduct-PortScan { ${function:Conduct-PortScan} }"
            #         Invoke-Command -ScriptBlock {
            #             Param($ConductPortScan,$EnumerationPortScanPortQuickPickComboBoxSelectedItem,$EnumerationPortScanTimeoutTextboxText,$EnumerationPortScanTestICMPFirstCheckBoxChecked,$EnumerationPortScanSpecificIPTextboxText,$EnumerationPortScanSpecificPortsTextboxText,$EnumerationPortScanIPRangeNetworkTextboxText,$EnumerationPortScanIPRangeFirstTextboxText,$EnumerationPortScanIPRangeLastTextboxText,$EnumerationPortScanPortRangeFirstTextboxText,$EnumerationPortScanPortRangeLastTextboxText)
    
            #             . ([ScriptBlock]::Create($ConductPortScan))
    
            #             Conduct-PortScan `
            #                 -EnumerationPortScanPortQuickPickComboBoxSelectedItem $EnumerationPortScanPortQuickPickComboBoxSelectedItem `
            #                 -Timeout_ms $EnumerationPortScanTimeoutTextboxText `
            #                 -TestWithICMPFirst $EnumerationPortScanTestICMPFirstCheckBoxChecked `
            #                 -SpecificIPsToScan $EnumerationPortScanSpecificIPTextboxText `
            #                 -SpecificPortsToScan $EnumerationPortScanSpecificPortsTextboxText `
            #                 -Network $EnumerationPortScanIPRangeNetworkTextboxText `
            #                 -FirstIP $EnumerationPortScanIPRangeFirstTextboxText `
            #                 -LastIP $EnumerationPortScanIPRangeLastTextboxText `
            #                 -FirstPort $EnumerationPortScanPortRangeFirstTextboxText `
            #                 -LastPort $EnumerationPortScanPortRangeLastTextboxText
            #         } `
            #         -ArgumentList @($ConductPortScan,$EnumerationPortScanPortQuickPickComboBox.SelectedItem,$EnumerationPortScanTimeoutTextbox.Text,$EnumerationPortScanTestICMPFirstCheckBox.Checked,$EnumerationPortScanSpecificIPTextbox.Text,$EnumerationPortScanSpecificPortsTextbox.Text,$EnumerationPortScanIPRangeNetworkTextbox.Text,$EnumerationPortScanIPRangeFirstTextbox.Text,$EnumerationPortScanIPRangeLastTextbox.Text,$EnumerationPortScanPortRangeFirstTextbox.Text,$EnumerationPortScanPortRangeLastTextbox.Text) `
            #         -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- localhost"
    
            #         Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:Conduct-PortScan} -ArgumentList @($ConductPortScan,$EnumerationPortScanPortQuickPickComboBox.SelectedItem,$EnumerationPortScanTimeoutTextbox.Text,$EnumerationPortScanTestICMPFirstCheckBox.Checked,$EnumerationPortScanSpecificIPTextbox.Text,$EnumerationPortScanSpecificPortsTextbox.Text,$EnumerationPortScanIPRangeNetworkTextbox.Text,$EnumerationPortScanIPRangeFirstTextbox.Text,$EnumerationPortScanIPRangeLastTextbox.Text,$EnumerationPortScanPortRangeFirstTextbox.Text,$EnumerationPortScanPortRangeLastTextbox.Text) -InputValues $InputValues -DisableReRun -JobsExportFiles 'true'
            #     }
            # }
        }
        elseif ($script:ComputerListPivotExecutionCheckbox.checked -eq $true) {
            $InformationTabControl.SelectedTab = $Section3MonitorJobsTab

            if ($script:EnumerationPortScanSpecificComputerNodeCheckbox.checked -eq $true) {
                if ($ComputerListProvideCredentialsCheckBox.Checked) {
                    if (!$script:Credential) { Create-NewCredentials }
                    $CollectionName = "Enumeration Scanning $($script:ComputerList.count) [Pivot: $($script:ComputerListPivotExecutionTextBox.text)]"

                    $ConductPortScan = "function Conduct-PortScan { ${function:Conduct-PortScan} }"
                    Invoke-Command -ScriptBlock {
                        Param($ConductPortScan,$ComputerList,$EnumerationPortScanPortQuickPickComboBoxSelectedItem,$EnumerationPortScanTimeoutTextbox,$EnumerationPortScanTestICMPFirstCheckBox,$EnumerationPortScanSpecificPortsTextbox,$EnumerationPortScanPortRangeFirstTextbox,$EnumerationPortScanPortRangeLastTextbox)

                        . ([ScriptBlock]::Create($ConductPortScan))

                        Conduct-PortScan `
                            -ComputerList $ComputerList `
                            -EnumerationPortScanPortQuickPickComboBoxSelectedItem $EnumerationPortScanPortQuickPickComboBoxSelectedItem `
                            -Timeout_ms $EnumerationPortScanTimeoutTextbox `
                            -TestWithICMPFirst $EnumerationPortScanTestICMPFirstCheckBox `
                            -EndpointList `
                            -SpecificPortsToScan $EnumerationPortScanSpecificPortsTextbox `
                            -FirstPort $EnumerationPortScanPortRangeFirstTextbox `
                            -LastPort $EnumerationPortScanPortRangeLastTextbox
                    } `
                    -ArgumentList @($ConductPortScan,$script:ComputerList,$EnumerationPortScanPortQuickPickComboBox.SelectedItem,$EnumerationPortScanTimeoutTextbox.text,$EnumerationPortScanTestICMPFirstCheckBox.checked,$EnumerationPortScanSpecificPortsTextbox.text,$EnumerationPortScanPortRangeFirstTextbox.text,$EnumerationPortScanPortRangeLastTextbox.text) `
                    -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($script:ComputerListPivotExecutionTextBox.text)" `
                    -ComputerName $script:ComputerListPivotExecutionTextBox.text `
                    -Credential $script:Credential

                    Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:Conduct-PortScan} -ArgumentList @($ConductPortScan,$script:ComputerList,$EnumerationPortScanPortQuickPickComboBox.SelectedItem,$EnumerationPortScanTimeoutTextbox.text,$EnumerationPortScanTestICMPFirstCheckBox.checked,$EnumerationPortScanSpecificPortsTextbox.text,$EnumerationPortScanPortRangeFirstTextbox.text,$EnumerationPortScanPortRangeLastTextbox.text) -InputValues $InputValues -DisableReRun -JobsExportFiles 'true'
                }
                else {
                    $CollectionName = "Enumeration Scanning $($script:ComputerList.count) Endpoints [Pivot: $($script:ComputerListPivotExecutionTextBox.text)]"

                    $ConductPortScan = "function Conduct-PortScan { ${function:Conduct-PortScan} }"
                    Invoke-Command -ScriptBlock {
                        Param($ConductPortScan,$ComputerList,$EnumerationPortScanPortQuickPickComboBoxSelectedItem,$EnumerationPortScanTimeoutTextbox,$EnumerationPortScanTestICMPFirstCheckBox,$EnumerationPortScanSpecificPortsTextbox,$EnumerationPortScanPortRangeFirstTextbox,$EnumerationPortScanPortRangeLastTextbox)

                        . ([ScriptBlock]::Create($ConductPortScan))

                        Conduct-PortScan `
                            -ComputerList $ComputerList `
                            -EnumerationPortScanPortQuickPickComboBoxSelectedItem $EnumerationPortScanPortQuickPickComboBoxSelectedItem `
                            -Timeout_ms $EnumerationPortScanTimeoutTextbox `
                            -TestWithICMPFirst $EnumerationPortScanTestICMPFirstCheckBox `
                            -EndpointList `
                            -SpecificPortsToScan $EnumerationPortScanSpecificPortsTextbox `
                            -FirstPort $EnumerationPortScanPortRangeFirstTextbox `
                            -LastPort $EnumerationPortScanPortRangeLastTextbox
                    } `
                    -ArgumentList @($ConductPortScan,$script:ComputerList,$EnumerationPortScanPortQuickPickComboBox.SelectedItem,$EnumerationPortScanTimeoutTextbox.text,$EnumerationPortScanTestICMPFirstCheckBox.checked,$EnumerationPortScanSpecificPortsTextbox.text,$EnumerationPortScanPortRangeFirstTextbox.text,$EnumerationPortScanPortRangeLastTextbox.text) `
                    -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($script:ComputerListPivotExecutionTextBox.text)" `
                    -ComputerName $script:ComputerListPivotExecutionTextBox.text

                    Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:Conduct-PortScan} -ArgumentList @($ConductPortScan,$script:ComputerList,$EnumerationPortScanPortQuickPickComboBox.SelectedItem,$EnumerationPortScanTimeoutTextbox.text,$EnumerationPortScanTestICMPFirstCheckBox.checked,$EnumerationPortScanSpecificPortsTextbox.text,$EnumerationPortScanPortRangeFirstTextbox.text,$EnumerationPortScanPortRangeLastTextbox.text) -InputValues $InputValues -DisableReRun -JobsExportFiles 'true'
                }
            }
            elseif ($script:EnumerationPortScanSpecificComputerNodeCheckbox.checked -eq $false) {
                if ($ComputerListProvideCredentialsCheckBox.Checked) {
                    if (!$script:Credential) { Create-NewCredentials }
                    $CollectionName = "Enumeration Scanning $(
                        $(
                            ([int]$($EnumerationPortScanIPRangeFirstTextbox.Text)..[int]$($EnumerationPortScanIPRangeLastTextbox.Text)).count
                        ) + $(
                            ($EnumerationPortScanSpecificIPTextbox.Text).split(',').trim().count
                        )
                        ) [Pivot: $($script:ComputerListPivotExecutionTextBox.text)]"

                    $ConductPortScan = "function Conduct-PortScan { ${function:Conduct-PortScan} }"
                    Invoke-Command -ScriptBlock {
                        Param($ConductPortScan,$EnumerationPortScanPortQuickPickComboBoxSelectedItem,$EnumerationPortScanTimeoutTextboxText,$EnumerationPortScanTestICMPFirstCheckBoxChecked,$EnumerationPortScanSpecificIPTextboxText,$EnumerationPortScanSpecificPortsTextboxText,$EnumerationPortScanIPRangeNetworkTextboxText,$EnumerationPortScanIPRangeFirstTextboxText,$EnumerationPortScanIPRangeLastTextboxText,$EnumerationPortScanPortRangeFirstTextboxText,$EnumerationPortScanPortRangeLastTextboxText)

                        . ([ScriptBlock]::Create($ConductPortScan))

                        Conduct-PortScan `
                            -EnumerationPortScanPortQuickPickComboBoxSelectedItem $EnumerationPortScanPortQuickPickComboBoxSelectedItem `
                            -Timeout_ms $EnumerationPortScanTimeoutTextboxText `
                            -TestWithICMPFirst $EnumerationPortScanTestICMPFirstCheckBoxChecked `
                            -SpecificIPsToScan $EnumerationPortScanSpecificIPTextboxText `
                            -SpecificPortsToScan $EnumerationPortScanSpecificPortsTextboxText `
                            -Network $EnumerationPortScanIPRangeNetworkTextboxText `
                            -FirstIP $EnumerationPortScanIPRangeFirstTextboxText `
                            -LastIP $EnumerationPortScanIPRangeLastTextboxText `
                            -FirstPort $EnumerationPortScanPortRangeFirstTextboxText `
                            -LastPort $EnumerationPortScanPortRangeLastTextboxText
                    } `
                    -ArgumentList @($ConductPortScan,$EnumerationPortScanPortQuickPickComboBox.SelectedItem,$EnumerationPortScanTimeoutTextbox.Text,$EnumerationPortScanTestICMPFirstCheckBox.Checked,$EnumerationPortScanSpecificIPTextbox.Text,$EnumerationPortScanSpecificPortsTextbox.Text,$EnumerationPortScanIPRangeNetworkTextbox.Text,$EnumerationPortScanIPRangeFirstTextbox.Text,$EnumerationPortScanIPRangeLastTextbox.Text,$EnumerationPortScanPortRangeFirstTextbox.Text,$EnumerationPortScanPortRangeLastTextbox.Text) `
                    -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($script:ComputerListPivotExecutionTextBox.text)" `
                    -ComputerName $script:ComputerListPivotExecutionTextBox.text `
                    -Credential $script:Credential

                    Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:Conduct-PortScan} -ArgumentList @($ConductPortScan,$EnumerationPortScanPortQuickPickComboBox.SelectedItem,$EnumerationPortScanTimeoutTextbox.Text,$EnumerationPortScanTestICMPFirstCheckBox.Checked,$EnumerationPortScanSpecificIPTextbox.Text,$EnumerationPortScanSpecificPortsTextbox.Text,$EnumerationPortScanIPRangeNetworkTextbox.Text,$EnumerationPortScanIPRangeFirstTextbox.Text,$EnumerationPortScanIPRangeLastTextbox.Text,$EnumerationPortScanPortRangeFirstTextbox.Text,$EnumerationPortScanPortRangeLastTextbox.Text) -InputValues $InputValues -DisableReRun -JobsExportFiles 'true'
                }
                else {
                    $ConductPortScan = "function Conduct-PortScan { ${function:Conduct-PortScan} }"
                    Invoke-Command -ScriptBlock {
                        Param($ConductPortScan,$EnumerationPortScanPortQuickPickComboBoxSelectedItem,$EnumerationPortScanTimeoutTextboxText,$EnumerationPortScanTestICMPFirstCheckBoxChecked,$EnumerationPortScanSpecificIPTextboxText,$EnumerationPortScanSpecificPortsTextboxText,$EnumerationPortScanIPRangeNetworkTextboxText,$EnumerationPortScanIPRangeFirstTextboxText,$EnumerationPortScanIPRangeLastTextboxText,$EnumerationPortScanPortRangeFirstTextboxText,$EnumerationPortScanPortRangeLastTextboxText)

                        . ([ScriptBlock]::Create($ConductPortScan))

                        Conduct-PortScan `
                            -EnumerationPortScanPortQuickPickComboBoxSelectedItem $EnumerationPortScanPortQuickPickComboBoxSelectedItem `
                            -Timeout_ms $EnumerationPortScanTimeoutTextboxText `
                            -TestWithICMPFirst $EnumerationPortScanTestICMPFirstCheckBoxChecked `
                            -SpecificIPsToScan $EnumerationPortScanSpecificIPTextboxText `
                            -SpecificPortsToScan $EnumerationPortScanSpecificPortsTextboxText `
                            -Network $EnumerationPortScanIPRangeNetworkTextboxText `
                            -FirstIP $EnumerationPortScanIPRangeFirstTextboxText `
                            -LastIP $EnumerationPortScanIPRangeLastTextboxText `
                            -FirstPort $EnumerationPortScanPortRangeFirstTextboxText `
                            -LastPort $EnumerationPortScanPortRangeLastTextboxText
                    } `
                    -ArgumentList @($ConductPortScan,$EnumerationPortScanPortQuickPickComboBox.SelectedItem,$EnumerationPortScanTimeoutTextbox.Text,$EnumerationPortScanTestICMPFirstCheckBox.Checked,$EnumerationPortScanSpecificIPTextbox.Text,$EnumerationPortScanSpecificPortsTextbox.Text,$EnumerationPortScanIPRangeNetworkTextbox.Text,$EnumerationPortScanIPRangeFirstTextbox.Text,$EnumerationPortScanIPRangeLastTextbox.Text,$EnumerationPortScanPortRangeFirstTextbox.Text,$EnumerationPortScanPortRangeLastTextbox.Text) `
                    -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($script:ComputerListPivotExecutionTextBox.text)" `
                    -ComputerName $script:ComputerListPivotExecutionTextBox.text
                    

                    Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:Conduct-PortScan} -ArgumentList @($ConductPortScan,$EnumerationPortScanPortQuickPickComboBox.SelectedItem,$EnumerationPortScanTimeoutTextbox.Text,$EnumerationPortScanTestICMPFirstCheckBox.Checked,$EnumerationPortScanSpecificIPTextbox.Text,$EnumerationPortScanSpecificPortsTextbox.Text,$EnumerationPortScanIPRangeNetworkTextbox.Text,$EnumerationPortScanIPRangeFirstTextbox.Text,$EnumerationPortScanIPRangeLastTextbox.Text,$EnumerationPortScanPortRangeFirstTextbox.Text,$EnumerationPortScanPortRangeLastTextbox.Text) -InputValues $InputValues -DisableReRun -JobsExportFiles 'true'
                }
            }
        }
    }
    else {
        [system.media.systemsounds]::Exclamation.play()
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Port Scan:  Cancelled")
    }

    $script:ComputerTreeView.Nodes.Clear()
    Initialize-ComputerTreeNodes
    Populate-ComputerTreeNodeDefaultData
    Save-ComputerTreeNodeHostData

    Foreach($Computer in $script:ComputerTreeViewData) {
        Add-NodeComputer -RootNode $script:TreeNodeComputerList -Category $Computer.OperatingSystem -Entry $Computer.Name -ToolTip 'No ToolTip Data' -IPv4Address $Computer.IPv4Address -Metadata $Computer
    }
    Update-TreeNodeComputerState
}


