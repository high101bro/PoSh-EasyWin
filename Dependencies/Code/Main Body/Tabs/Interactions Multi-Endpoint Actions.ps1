####################################################################################################
# ScriptBlocks
####################################################################################################

$ActionsTabQuarantineEndpointAccessFromIPSubnetTextbox_MouseHover = {
    Show-ToolTip -Title "Access Endpoints from IP or Subnet" -Icon "Info" -Message @"
+  This textbox identifies the host(s) that can access the quarantined endpoint(s).
+  CAUTION! If there's an error in the entry, the endpoint(s) may become completely inaccessible over the network.
+  Use the following list as guidelines to fill the textbox:
     -  Single IPv4 Address: 1.2.3.4
     -  Single IPv6 Address: fe80::1
     -  IPv4 Subnet (by network bit count): 1.2.3.4/24
     -  IPv6 Subnet (by network bit count): fe80::1/48
     -  IPv4 Subnet (by network mask): 1.2.3.4/255.255.255.0
     -  IPv4 Range: 1.2.3.4-1.2.3.7
     -  IPv6 Range: fe80::1-fe80::9
     -  Keyword: Any, LocalSubnet, DNS, DHCP, WINS, DefaultGateway, Internet, Intranet, IntranetRemoteAccess,
     PlayToDevice. NOTE: Keywords can be restricted to IPv4 or IPv6 by appending a 4 or 6 (for example, keyword
     "LocalSubnet4" means that all local IPv4 addresses are matching this rule).
"@
}

####################################################################################################
# WinForms
####################################################################################################

$Section1ActionOnEndpointTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = "Multi-Endpoint Actions  "
    Left   = $FormScale * 3
    Top    = $FormScale * -10
    Width  = $FormScale * 440
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
    ImageIndex = 0
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
            Apply-CommonButtonSettings -Button $ActionsTabProcessKillerButton
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
            Apply-CommonButtonSettings -Button $ActionsTabServiceKillerButton
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
            Apply-CommonButtonSettings -Button $ActionsTabAccountLogoutButton
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
            Apply-CommonButtonSettings -Button $ActionsTabSelectNetworkConnectionsToKillButton
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


            $script:ActionsTabQuarantineEndpointAccessFromIPSubnetTextbox = New-Object System.Windows.Forms.Textbox -Property @{
                Text   = "Enter IP, Range, or Subnet"
                Left   = $FormScale * 268
                Top    = $ActionsTabQuarantineEndpointLabel.Top
                Width  = $FormScale * 150
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor      = 'Black'
                Add_MouseEnter = { if ($this.text -eq "Enter IP, Range, or Subnet") { $this.text = "" } }
                Add_MouseLeave = { if ($this.text -eq "") { $this.text = "Enter IP, Range, or Subnet" } }
                Add_MouseHover = $ActionsTabQuarantineEndpointAccessFromIPSubnetTextbox_MouseHover
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
            Apply-CommonButtonSettings -Button $ActionsTabQuarantineEndpointsButton
$Section1ActionOnEndpointTab.Controls.Add($ActionsTabQuarantineEndpointGroupBox)



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUieOWKDWZdkYLb4gzCbTzAipe
# 5OWgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
# AQUFADAzMTEwLwYDVQQDDChQb1NoLUVhc3lXaW4gQnkgRGFuIEtvbW5pY2sgKGhp
# Z2gxMDFicm8pMB4XDTIxMTIxNDA1MDIwMFoXDTMxMTIxNDA1MTIwMFowMzExMC8G
# A1UEAwwoUG9TaC1FYXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALvIxUDFEVGB/G0FXPryoNlF
# dA65j5jPEFM2R4468rjlTVsNYUOR+XvhjmhpggSQa6SzvXtklUJIJ6LgVUpt/0C1
# zlr1pRwTvsd3svI7FHTbJahijICjCv8u+bFcAR2hH3oHFZTqvzWD1yG9FGCw2pq3
# h4ahxtYBd1+/n+jOtPUoMzcKIOXCUe4Cay+xP8k0/OLIVvKYRlMY4B9hvTW2CK7N
# fPnvFpNFeGgZKPRLESlaWncbtEBkexmnWuferJsRtjqC75uNYuTimLDSXvNps3dJ
# wkIvKS1NcxfTqQArX3Sg5qKX+ZR21uugKXLUyMqXmVo2VEyYJLAAAITEBDM8ngUC
# AwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0G
# A1UdDgQWBBSDJIlo6BcZ7KJAW5hoB/aaTLxFzTANBgkqhkiG9w0BAQUFAAOCAQEA
# ouCzal7zPn9vc/C9uq7IDNb1oNbWbVlGJELLQQYdfBE9NWmXi7RfYNd8mdCLt9kF
# CBP/ZjHKianHeZiYay1Tj+4H541iUN9bPZ/EaEIup8nTzPbJcmDbaAGaFt2PFG4U
# 3YwiiFgxFlyGzrp//sVnOdtEtiOsS7uK9NexZ3eEQfb/Cd9HRikeUG8ZR5VoQ/kH
# 2t2+tYoCP4HsyOkEeSQbnxlO9s1jlSNvqv4aygv0L6l7zufiKcuG7q4xv/5OvZ+d
# TcY0W3MVlrrNp1T2wxzl3Q6DgI+zuaaA1w4ZGHyxP8PLr6lMi6hIugI1BSYVfk8h
# 7KAaul5m+zUTDBUyNd91ojGCAegwggHkAgEBMEcwMzExMC8GA1UEAwwoUG9TaC1F
# YXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKQIQeugH5LewQKBKT6dP
# XhQ7sDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkq
# hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGC
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUJaJnNPIxkD5XAQFvmav+h2vufYEwDQYJKoZI
# hvcNAQEBBQAEggEAM2Ya1wDtd/c/6VoWe7gwHYFlizuErYyHfCBboUE38uODl5cv
# 4jy3vJp7oOrR7isG1ny6OtwlJLovfNr1zHo9a8CkZR4CzUEjTgqU0A6ZbBBmLAt3
# n9mcS2YtNYXUt/erH7Pi4i6JXLpyAYg/rm/Y9r0AxXp0g3nyLwjvt++IxNrO7PkA
# U1yKJAr4SVv4FyzhsdlXZImLkWisNN0hq1dy6ghlolXojRQFCUjH8XuzP4ePvOd/
# PPOXQvU6Sy2VsOHxwSH0jptua8mUvo76RyK58k83nQBfXm3iO3jluhMd7hGCk6WM
# FgnGYZgUA1/Ou8nm1h5NA8QGpNRhVklCv89eLg==
# SIG # End signature block
