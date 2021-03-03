
$Section1ActionOnEndpointTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = "Multi-Endpoint Actions"
    Left   = $FormScale * 3
    Top    = $FormScale * -10
    Width  = $FormScale * 440
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
}
$MainLeftSection1InteractionsTabTabControl.Controls.Add($Section1ActionOnEndpointTab)


$ActionsTabProcessKillerGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text   = "Process Stopper (WinRM)"
    Left   = $FormScale * 5
    Top    = $FormScale * 10
    Width  = $FormScale * 425
    Height = $FormScale * 89
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
}
            $ActionsTabProcessKillerLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Stop Multiple Processes On Multiple Endpoints."
                Left   = $FormScale * 7
                Top    = $FormScale * 22
                Width  = $FormScale * 410
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
            }
            $ActionsTabProcessKillerGroupBox.Controls.Add($ActionsTabProcessKillerLabel)


            $ActionsTabProcessKillerCollectNewProcessDataRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text   = "Collect Process Data From Endpoints"
                Left   = $FormScale * 12
                Top    = $ActionsTabProcessKillerLabel.Top + $ActionsTabProcessKillerLabel.Height
                Width  = $FormScale * 255
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
                Checked   = $true
            }
            $ActionsTabProcessKillerGroupBox.Controls.Add($ActionsTabProcessKillerCollectNewProcessDataRadioButton)


            $ActionsTabProcessKillerSelectFileRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text   = "Open Process Data From CSV File"
                Left   = $FormScale * 12
                Top    = $ActionsTabProcessKillerCollectNewProcessDataRadioButton.Top + $ActionsTabProcessKillerCollectNewProcessDataRadioButton.Height
                Width  = $FormScale * 255
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
            }
            $ActionsTabProcessKillerGroupBox.Controls.Add($ActionsTabProcessKillerSelectFileRadioButton)


            Update-FormProgress "$Dependencies\Code\Execution\Action\Stop-ProcessesOnMultipleComputers.ps1"
            . "$Dependencies\Code\Execution\Action\Stop-ProcessesOnMultipleComputers.ps1"
            $ActionsTabProcessKillerButton = New-Object System.Windows.Forms.Button -Property @{
                Text   = "Select Processes To Stop"
                Left   = $FormScale * 268
                Top    = $ActionsTabProcessKillerSelectFileRadioButton.Top - $($FormScale * 5)
                Width  = $FormScale * 150
                Height = $FormScale * 22
                Add_Click = {
                    if ($ActionsTabProcessKillerCollectNewProcessDataRadioButton.checked){
                        Stop-ProcessesOnMultipleComputers -CollectNewProcessData
                    }
                    if ($ActionsTabProcessKillerSelectFileRadioButton.checked){
                        Stop-ProcessesOnMultipleComputers -SelectProcessCsvFile
                    }
                }
            }
            $ActionsTabProcessKillerGroupBox.Controls.Add($ActionsTabProcessKillerButton)
            CommonButtonSettings -Button $ActionsTabProcessKillerButton
$Section1ActionOnEndpointTab.Controls.Add($ActionsTabProcessKillerGroupBox)


$ActionsTabServiceKillerGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text   = "Service Stopper (WinRM)"
    Left   = $FormScale * 5
    Top    = $ActionsTabProcessKillerGroupBox.Top + $ActionsTabProcessKillerGroupBox.Height + $($FormScale * 10)
    Width  = $FormScale * 425
    Height = $FormScale * 89
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
}
            $ActionsTabServiceKillerLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Stop Multiple Services On Multiple endpoints."
                Left   = $FormScale * 7
                Top    = $FormScale * 22
                Width  = $FormScale * 410
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
            }
            $ActionsTabServiceKillerGroupBox.Controls.Add($ActionsTabServiceKillerLabel)


            $ActionsTabServiceKillerCollectNewServiceDataRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text   = "Collect Service Data From Endpoints"
                Left   = $FormScale * 12
                Top    = $ActionsTabServiceKillerLabel.Top + $ActionsTabServiceKillerLabel.Height
                Width  = $FormScale * 255
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
                Checked   = $true
            }
            $ActionsTabServiceKillerGroupBox.Controls.Add($ActionsTabServiceKillerCollectNewServiceDataRadioButton)


            $ActionsTabServiceKillerSelectFileRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text   = "Open Service Data From CSV File"
                Left   = $FormScale * 12
                Top    = $ActionsTabServiceKillerCollectNewServiceDataRadioButton.Top + $ActionsTabServiceKillerCollectNewServiceDataRadioButton.Height
                Width  = $FormScale * 255
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
            }
            $ActionsTabServiceKillerGroupBox.Controls.Add($ActionsTabServiceKillerSelectFileRadioButton)


            Update-FormProgress "$Dependencies\Code\Execution\Action\Stop-ServicesOnMultipleComputers.ps1"
            . "$Dependencies\Code\Execution\Action\Stop-ServicesOnMultipleComputers.ps1"
            $ActionsTabServiceKillerButton = New-Object System.Windows.Forms.Button -Property @{
                Text   = "Select Services To Stop"
                Left   = $FormScale * 268
                Top    = $ActionsTabServiceKillerSelectFileRadioButton.Top - $($FormScale * 5)
                Width  = $FormScale * 150
                Height = $FormScale * 22
                Add_Click = {
                    if ($ActionsTabServiceKillerCollectNewServiceDataRadioButton.checked){
                        Stop-ServicesOnMultipleComputers -CollectNewServiceData
                    }
                    if ($ActionsTabServiceKillerSelectFileRadioButton.checked){
                        Stop-ServicesOnMultipleComputers -SelectServiceCsvFile
                    }
                }
            }
            $ActionsTabServiceKillerGroupBox.Controls.Add($ActionsTabServiceKillerButton)
            CommonButtonSettings -Button $ActionsTabServiceKillerButton
$Section1ActionOnEndpointTab.Controls.Add($ActionsTabServiceKillerGroupBox)


$ActionsTabAccountLogoutGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text   = "Account Logout (WinRM)"
    Left   = $FormScale * 5
    Top    = $ActionsTabServiceKillerGroupBox.Top + $ActionsTabServiceKillerGroupBox.Height + $($FormScale * 10)
    Width  = $FormScale * 425
    Height = $FormScale * 89
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
}
            $ActionsTabAccountLogoutLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Logout Multiple Accounts On multiple Endpoints."
                Left   = $FormScale * 7
                Top    = $FormScale * 22
                Width  = $FormScale * 410
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
            }
            $ActionsTabAccountLogoutGroupBox.Controls.Add($ActionsTabAccountLogoutLabel)


            $ActionsTabAccountLogoutCollectLoggedOnAccountsRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text   = "Collect Logged On Accounts From Endpoints"
                Left   = $FormScale * 12
                Top    = $ActionsTabAccountLogoutLabel.Top + $ActionsTabAccountLogoutLabel.Height
                Width  = $FormScale * 255
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
                Checked   = $true
            }
            $ActionsTabAccountLogoutGroupBox.Controls.Add($ActionsTabAccountLogoutCollectLoggedOnAccountsRadioButton)


            $ActionsTabAccountLogoutSelectFileRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text   = "Open Logged On Accounts From CSV File"
                Left   = $FormScale * 12
                Top    = $ActionsTabAccountLogoutCollectLoggedOnAccountsRadioButton.Top + $ActionsTabAccountLogoutCollectLoggedOnAccountsRadioButton.Height
                Width  = $FormScale * 255
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
            }
            $ActionsTabAccountLogoutGroupBox.Controls.Add($ActionsTabAccountLogoutSelectFileRadioButton)


            Update-FormProgress "$Dependencies\Code\Execution\Action\Logout-AccountsOnMultipleComputers.ps1"
            . "$Dependencies\Code\Execution\Action\Logout-AccountsOnMultipleComputers.ps1"
            $ActionsTabAccountLogoutButton = New-Object System.Windows.Forms.Button -Property @{
                Text   = "Select Accounts to Logout"
                Left   = $FormScale * 268
                Top    = $ActionsTabAccountLogoutSelectFileRadioButton.Top - $($FormScale * 5)
                Width  = $FormScale * 150
                Height = $FormScale * 22
                Add_Click = {
                    if ($ActionsTabAccountLogoutCollectLoggedOnAccountsRadioButton.checked){
                        Logout-AccountsOnMultipleComputers -CollectNewAccountData
                    }
                    elseif ($ActionsTabAccountLogoutSelectFileRadioButton.checked){
                        Logout-AccountsOnMultipleComputers -SelectAccountCsvFile
                    }
                }
            }
            $ActionsTabAccountLogoutGroupBox.Controls.Add($ActionsTabAccountLogoutButton)
            CommonButtonSettings -Button $ActionsTabAccountLogoutButton
$Section1ActionOnEndpointTab.Controls.Add($ActionsTabAccountLogoutGroupBox)


$ActionsTabKillNetworkConnectionGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text   = "Network Connection Killer (WinRM)"
    Left   = $FormScale * 5
    Top    = $ActionsTabAccountLogoutGroupBox.Top + $ActionsTabAccountLogoutGroupBox.Height + $($FormScale * 10)
    Width  = $FormScale * 425
    Height = $FormScale * 89
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
}
            $ActionsTabKillNetworkConnectionLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Kill Multiple Network Connections On Multiple Endpoints. (Kills Owning PID)"
                Left   = $FormScale * 7
                Top    = $FormScale * 22
                Width  = $FormScale * 410
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
            }
            $ActionsTabKillNetworkConnectionGroupBox.Controls.Add($ActionsTabKillNetworkConnectionLabel)


            $ActionsTabGetNetworkConnectionsRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text   = "Collect Network Connections from Endpoints"
                Left   = $FormScale * 12
                Top    = $ActionsTabKillNetworkConnectionLabel.Top + $ActionsTabKillNetworkConnectionLabel.Height
                Width  = $FormScale * 255
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
                Checked   = $true
            }
            $ActionsTabKillNetworkConnectionGroupBox.Controls.Add($ActionsTabGetNetworkConnectionsRadioButton)


            $ActionsTabKillNetworkConnectionsSelectFileRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text   = "Open Network Connections From CSV File"
                Left   = $FormScale * 12
                Top    = $ActionsTabGetNetworkConnectionsRadioButton.Top + $ActionsTabGetNetworkConnectionsRadioButton.Height
                Width  = $FormScale * 255
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
            }
            $ActionsTabKillNetworkConnectionGroupBox.Controls.Add($ActionsTabKillNetworkConnectionsSelectFileRadioButton)


            Update-FormProgress "$Dependencies\Code\Execution\Action\Kill-NetworkConnectionsOnMultipleComputers.ps1"
            . "$Dependencies\Code\Execution\Action\Kill-NetworkConnectionsOnMultipleComputers.ps1"
            $ActionsTabSelectNetworkConnectionsToKillButton = New-Object System.Windows.Forms.Button -Property @{
                Text   = "Select Connections To Kill"
                Left   = $FormScale * 268
                Top    = $ActionsTabKillNetworkConnectionsSelectFileRadioButton.Top - $($FormScale * 5)
                Width  = $FormScale * 150
                Height = $FormScale * 22
                Add_Click = {
                    if ($ActionsTabGetNetworkConnectionsRadioButton.checked){
                        Kill-NetworkConnectionsOnMultipleComputers -CollectNewNetworkConnections
                    }
                    elseif ($ActionsTabKillNetworkConnectionsSelectFileRadioButton.checked){
                        Kill-NetworkConnectionsOnMultipleComputers -SelectNetworkConnectionsCsvFile
                    }
                }
            }
            $ActionsTabKillNetworkConnectionGroupBox.Controls.Add($ActionsTabSelectNetworkConnectionsToKillButton)
            CommonButtonSettings -Button $ActionsTabSelectNetworkConnectionsToKillButton
$Section1ActionOnEndpointTab.Controls.Add($ActionsTabKillNetworkConnectionGroupBox)


$ActionsTabQuarantineEndpointGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text   = "Quarantine Endpoints (WinRM) - [Beta]"
    Left   = $FormScale * 5
    Top    = $ActionsTabKillNetworkConnectionGroupBox.Top + $ActionsTabKillNetworkConnectionGroupBox.Height + $($FormScale * 10)
    Width  = $FormScale * 425
    Height = $FormScale * 89
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
}
            $ActionsTabQuarantineEndpointLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Quarantine Using Firewall Rules - Access From:  "
                Left   = $FormScale * 7
                Top    = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                AutoSize  = $true
                ForeColor = 'Black'
            }
            $ActionsTabQuarantineEndpointGroupBox.Controls.Add($ActionsTabQuarantineEndpointLabel)


            Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Textbox\ActionsTabQuarantineEndpointAccessFromIPSubnetTextbox.ps1"
            . "$Dependencies\Code\System.Windows.Forms\Textbox\ActionsTabQuarantineEndpointAccessFromIPSubnetTextbox.ps1"
            $script:ActionsTabQuarantineEndpointAccessFromIPSubnetTextbox = New-Object System.Windows.Forms.Textbox -Property @{
                Text   = "Enter IP, Range, or Subnet"
                Left   = $FormScale * 268
                Top    = $ActionsTabQuarantineEndpointLabel.Top
                Width  = $FormScale * 150
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor      = 'Black'
                Add_MouseEnter = $script:ActionsTabQuarantineEndpointAccessFromIPSubnetTextbox_MouseEnter
                Add_MouseLeave = $script:ActionsTabQuarantineEndpointAccessFromIPSubnetTextbox_MouseLeave
                Add_MouseHover = $script:ActionsTabQuarantineEndpointAccessFromIPSubnetTextbox_MouseHover
            }
            $ActionsTabQuarantineEndpointGroupBox.Controls.Add($script:ActionsTabQuarantineEndpointAccessFromIPSubnetTextbox)


            $ActionsTabCopyEndpointFirewallRulesRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text   = "Backup Firewall Rules and Quarantine"
                Left   = $FormScale * 12
                Top    = $ActionsTabQuarantineEndpointLabel.Top + $ActionsTabQuarantineEndpointLabel.Height
                Width  = $FormScale * 255
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
                Checked   = $true
                Add_Click = {
                    If ($this.checked){
                        $script:ActionsTabQuarantineEndpointAccessFromIPSubnetTextbox.Enabled = $true
                        $ActionsTabQuarantineEndpointsButton.text = "Backup and Quarantine"
                    }
                }
            }
            $ActionsTabQuarantineEndpointGroupBox.Controls.Add($ActionsTabCopyEndpointFirewallRulesRadioButton)


            $ActionsTabApplyFirewallRulesLocalCopyToEndpointsRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text   = "Restore Firewall Rules and Un-Quarantine"
                Left   = $FormScale * 12
                Top    = $ActionsTabCopyEndpointFirewallRulesRadioButton.Top + $ActionsTabCopyEndpointFirewallRulesRadioButton.Height
                Width  = $FormScale * 255
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
                Add_CLick = {
                    If ($this.checked){$script:ActionsTabQuarantineEndpointAccessFromIPSubnetTextbox.Enabled = $false}
                    $ActionsTabQuarantineEndpointsButton.text = "Restore and Un-Quarantine"
                }
            }
            $ActionsTabQuarantineEndpointGroupBox.Controls.Add($ActionsTabApplyFirewallRulesLocalCopyToEndpointsRadioButton)


            Update-FormProgress "$Dependencies\Code\Execution\Action\Quarantine-EndpointsWithFirewallRules.ps1"
            . "$Dependencies\Code\Execution\Action\Quarantine-EndpointsWithFirewallRules.ps1"
            $ActionsTabQuarantineEndpointsButton = New-Object System.Windows.Forms.Button -Property @{
                Text   = "Backup and Quarantine"
                Left   = $FormScale * 268
                Top    = $ActionsTabApplyFirewallRulesLocalCopyToEndpointsRadioButton.Top - $($FormScale * 5)
                Width  = $FormScale * 150
                Height = $FormScale * 22
                Add_Click = {
                    if ($ActionsTabCopyEndpointFirewallRulesRadioButton.checked) {
                        Quarantine-EndpointsWithFirewallRules -CopyEndpointFirewallRulesToLocalhost
                    }
                    elseif ($ActionsTabApplyFirewallRulesLocalCopyToEndpointsRadioButton.checked) {
                        Quarantine-EndpointsWithFirewallRules -ApplyFirewallRulesLocalCopyToEndpoints
                    }
                    [system.media.systemsounds]::Exclamation.play()
                }
            }
            $ActionsTabQuarantineEndpointGroupBox.Controls.Add($ActionsTabQuarantineEndpointsButton)
            CommonButtonSettings -Button $ActionsTabQuarantineEndpointsButton
$Section1ActionOnEndpointTab.Controls.Add($ActionsTabQuarantineEndpointGroupBox)
