function Quarantine-EndpointsWithFirewallRules {
    param(
        [switch]$CopyEndpointFirewallRulesToLocalhost,
        [switch]$ApplyFirewallRulesLocalCopyToEndpoints
    )
    $MainBottomTabControl.SelectedTab = $Section3ResultsTab

    #Removed For Testing#$ResultsListBox.Items.Clear()

    $OutputFirewallRulesDirectory = "$PoShHome\Endpoint Firewall Rules"
    if (-not (Test-Path $OutputFirewallRulesDirectory)) { New-Item -Type Directory $OutputFirewallRulesDirectory }

    function Tag-QuarantineMessage {
        param($Message,$Computer)
        [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerTreeView.Nodes
        $ComputerListMassTagArray = @()
        foreach ($node in $script:ComputerTreeViewSelected) {    
            foreach ($root in $AllHostsNode) {
                foreach ($Category in $root.Nodes) { 
                    foreach ($Entry in $Category.Nodes) {
                        if ($Entry.Checked -and $Entry.Text -eq "$Computer" -and $Entry.Text -notin $ComputerListMassTagArray) {
                            $ComputerListMassTagArray += $Entry.Text
                            $Section3HostDataNameTextBox.Text      = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).Name
                            $Section3HostDataOSTextBox.Text        = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).OperatingSystem
                            $Section3HostDataOUTextBox.Text        = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).CanonicalName
                            $Section3HostDataIPTextBox.Text        = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).IPv4Address
                            $Section3HostDataMACTextBox.Text       = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).MACAddress
                            $Section3HostDataNotesRichTextBox.Text = $Message + $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).Notes
                        }
                    }
                }
            }  
        }
        Save-ComputerTreeNodeHostData -SaveAllChecked
    }

    Generate-ComputerList
    if ($script:ComputerList.count -eq 0){
        [System.Windows.MessageBox]::Show('Ensure you checkbox one or more endpoints.','Error: No Endpoints Selected')
    }
    elseif ($ActionsTabCopyEndpointFirewallRulesRadioButton.checked -and $ActionsTabQuarantineEndpointAccessFromIPSubnetTextbox.text -eq "Enter IP, Range, or Subnet"){
        [System.Windows.MessageBox]::Show("Make sure you enter a valid IP, Range, or Subnet.

NOTE: Mouse hover over the textbox for a list of references.

CAUTION! If you make a bad entry, you may cause the endpoints to become inaccessible over the network.",'Error: Enter A Valid Entry')
    }
    else {
        # Provides a messagebox with the proper prompt depending on which radiobutton was seclected
        if ($ActionsTabCopyEndpointFirewallRulesRadioButton.checked){
            $BackupAndQuarantineMessageBox = [System.Windows.MessageBox]::Show("Backup the firewall rules and quarantine the following endpoints:

$($script:ComputerList -join ', ')

These endpoints will only be accessable from the following:

$($ActionsTabQuarantineEndpointAccessFromIPSubnetTextbox.text)

CAUTION! If you make a bad entry, you may cause the endpoints to become inaccessible over the network.",'Backup and Quarantine','YesNo','Info')
        }
        elseif ($ActionsTabApplyFirewallRulesLocalCopyToEndpointsRadioButton.checked){
            $BackupAndQuarantineMessageBox = [System.Windows.MessageBox]::Show("Restore the firewall rules and Un-Quarantine the following endpoints:`n`n$($script:ComputerList -join ', ')",'Restore and Un-Quarantine','YesNo','Info')
        }

        # If the messagebox was 'Yes', then...
        if ($BackupAndQuarantineMessageBox -eq 'Yes') {
            if ($CopyEndpointFirewallRulesToLocalhost) {
                $ResultsListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  Backing up and applying quarantine firewall rules on $($script:ComputerList.count) Endpoints")
            }
            elseif ($ApplyFirewallRulesLocalCopyToEndpoints) {
                $ResultsListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  Restoring backup and removing quarantine firewall rules on $($script:ComputerList.count) Endpoints")
            }

            foreach ($computer in $script:ComputerList) {           
                try {
                    if ($ComputerListProvideCredentialsCheckBox.Checked) {
                        if (!$script:Credential) { Create-NewCredentials }
                        $session = New-PSSession -ComputerName $Computer -Credential $script:Credential
                        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message 'New-PSSession -ComputerName $Computer -Credential $script:Credential'
                        $StatusListBox.Items.Clear()
                        $StatusListBox.Items.Add("Established a PSSession with $Computer")
                    }
                    else { 
                        $session = New-PSSession -ComputerName $Computer 
                        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message 'New-PSSession -ComputerName $Computer'
                        $StatusListBox.Items.Clear()
                        $StatusListBox.Items.Add("Established a PSSession with $Computer")
                    }
                }
                catch {
                    [system.media.systemsounds]::Exclamation.play()
                    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Unable to establish a PSSession with $Computer"
                    $StatusListBox.Items.Clear()
                    $StatusListBox.Items.Add("  Unable to establish PSSession to $Computer")
                }
                # Maybe will add a reset firewall rules option...
                # reset netsh advfirewall reset
                if ($Session) {
                    $ResultsListBox.Items.Insert(1,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  Conducting actions on: $Computer")
                    if ($CopyEndpointFirewallRulesToLocalhost) {
                        $ActionsTabQuarantineEndpointAccessFromIPSubnetTextboxText = $ActionsTabQuarantineEndpointAccessFromIPSubnetTextbox.Text
                        $CancelQuarantine = $false
        
                        if (Test-Path "$OutputFirewallRulesDirectory\$Computer - Firewall Rules.wfw"){
                            [system.media.systemsounds]::Exclamation.play()
                            $OverwriteFirewallFile = [System.Windows.MessageBox]::Show("Warning: A version of the firewall rules for $Computer already exists.`n`nDo you want to overwrite the local copy?",'Overwrite Local Copy','YesNoCancel','Warning')
                            switch ($OverwriteFirewallFile) {
                                'Yes'{
                                    Invoke-Command -ScriptBlock { netsh advfirewall export "C:\Windows\Temp\firewall-export.wfw" } -Session $Session
                                    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message 'Invoke-Command -ScriptBlock { netsh advfirewall export "C:\Windows\Temp\firewall-export.wfw" } -Session $Session'
                                    $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  - Backing up firewall rules")
            
                                    Copy-Item -Path "C:\Windows\Temp\firewall-export.wfw" -Destination "$OutputFirewallRulesDirectory\$Computer - Firewall Rules.wfw" -FromSession $Session -ErrorAction Stop -Force
                                    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message 'Copy-Item -Path "C:\Windows\Temp\firewall-export.wfw" -Destination "$OutputFirewallRulesDirectory\$Computer - Firewall Rules.wfw" -FromSession $Session -ErrorAction Stop -Force'
                                    $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  - Copying back backup firewall rules")

                                    Invoke-Command -ScriptBlock { Remove-Item "C:\Windows\Temp\firewall-export.wfw" -Force } -Session $Session
                                    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message 'Invoke-Command -ScriptBlock { Remove-Item "C:\Windows\Temp\firewall-export.wfw" -Force } -Session $Session'
                                    $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  - Cleaning up files on endpoint")        
                                }
                                'No' { continue }
                                'Cancel' { $CancelQuarantine = $true }
                            }
                        }
                        else {
                            Invoke-Command -ScriptBlock { netsh advfirewall export "C:\Windows\Temp\firewall-export.wfw" } -Session $Session
                            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message 'Invoke-Command -ScriptBlock { netsh advfirewall export "C:\Windows\Temp\firewall-export.wfw" } -Session $Session'
                            $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  - Backing up firewall rules")

                            Copy-Item -Path "C:\Windows\Temp\firewall-export.wfw" -Destination "$OutputFirewallRulesDirectory\$Computer - Firewall Rules.wfw" -FromSession $Session -ErrorAction Stop -Force
                            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message 'Copy-Item -Path "C:\Windows\Temp\firewall-export.wfw" -Destination "$OutputFirewallRulesDirectory\$Computer - Firewall Rules.wfw" -FromSession $Session -ErrorAction Stop -Force'
                            $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  - Copying back backup firewall rules")

                            Invoke-Command -ScriptBlock { Remove-Item "C:\Windows\Temp\firewall-export.wfw" -Force } -Session $Session
                            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message 'Invoke-Command -ScriptBlock { Remove-Item "C:\Windows\Temp\firewall-export.wfw" -Force } -Session $Session'
                            $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  - Cleaning up files on endpoint")
                        }

                        if ($CancelQuarantine -eq $false) {                                                       
                            $ScriptBlockQuarantine = {
                                param($RemoteAddress)

                                # Removes all existing firewall rules
                                Get-NetFirewallRule | Remove-NetFirewallRule
                                
                                # Locks down the endpoint
                                Set-NetFirewallProfile `
                                    -Name                            Domain, Private, Public `
                                    -Enabled                         True  `
                                    -DefaultInboundAction            Block `
                                    -DefaultOutboundAction           Block `
                                    -AllowInboundRules               True  `
                                    -AllowLocalFirewallRules         False `
                                    -AllowLocalIPsecRules            False `
                                    -AllowUserApps                   False `
                                    -AllowUserPorts                  False `
                                    -AllowUnicastResponseToMulticast False `
                                    -EnableStealthModeForIPsec       True  `
                                    -LogAllowed                      True  `
                                    -LogBlocked                      True  `
                                    -LogIgnored                      True  `
                                    -LogFileName                     C:\Windows\Temp\Quarantine_Firewall_Log.log                          

                                New-NetFirewallRule `
                                    -Name                 'Incident Response Access (Inbound)' `
                                    -DisplayName          'Incident Response Access (Inbound)' `
                                    -Description          'Quarantine - Incident Response Access (Inbound)' `
                                    -Enabled               True `
                                    -Profile               Domain, Public, Private `
                                    -RemoteAddress         $RemoteAddress `
                                    -Direction             Inbound `
                                    -Protocol              Any `
                                    -Action                Allow      

                                New-NetFirewallRule `
                                    -Name                 'Disable UDP (Inbound)' `
                                    -DisplayName          'Disable UDP (Inbound)' `
                                    -Description          'Quarantine - Disable UDP (Inbound)' `
                                    -Enabled               True `
                                    -Profile               Domain, Public, Private `
                                    -Direction             Inbound `
                                    -Protocol              UDP `
                                    -Action                Block

                                New-NetFirewallRule `
                                    -Name                 'Disable ICMPv4 (Inbound)' `
                                    -DisplayName          'Disable ICMPv4 (Inbound)' `
                                    -Description          'Quarantine - Disable ICMPv4 (Inbound)' `
                                    -Enabled               True `
                                    -Profile               Domain, Public, Private `
                                    -Direction             Inbound `
                                    -Protocol              ICMPv4 `
                                    -Action                Block

                                New-NetFirewallRule `
                                    -Name                 'Disable ICMPv6 (Inbound)' `
                                    -DisplayName          'Disable ICMPv6 (Inbound)' `
                                    -Description          'Quarantine - Disable ICMPv6 (Inbound)' `
                                    -Enabled               True `
                                    -Profile               Domain, Public, Private `
                                    -Direction             Inbound `
                                    -Protocol              ICMPv6 `
                                    -Action                Block

                                New-NetFirewallRule `
                                    -Name                 'Disable Communications (Outbound)' `
                                    -DisplayName          'Disable Communications (Outbound)' `
                                    -Description          'Quarantine - Disable Communications (Outbound)' `
                                    -Enabled               True `
                                    -Profile               Domain, Public, Private `
                                    -Direction             Outbound `
                                    -Protocol              Any `
                                    -Action                Block                 

                                $EndpointFirewallArray = @($EndpointFirewallProfiles, $EndpointFirewallRules)
                                return $EndpointFirewallArray
                            }
                            Invoke-Command -ScriptBlock $ScriptBlockQuarantine -ArgumentList @($ActionsTabQuarantineEndpointAccessFromIPSubnetTextboxText,$null) -Session $Session
                            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message 'Invoke-Command -ScriptBlock $ScriptBlockQuarantine -ArgumentList @($ActionsTabQuarantineEndpointAccessFromIPSubnetTextboxText,$null) -Session $Session'
                            $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  - Applying Quarantine firewall rules")

                            Tag-QuarantineMessage -Computer $Computer -Message "[Quarantined] at $(Get-Date) -- Accessible from $ActionsTabQuarantineEndpointAccessFromIPSubnetTextboxText`n"
                        }
                    }   
                    



                    elseif ($ApplyFirewallRulesLocalCopyToEndpoints) {
                        $EndpointOriginalFirewallFiles = Get-ChildItem $OutputFirewallRulesDirectory

                        foreach ($FirewallFileName in $EndpointOriginalFirewallFiles) {
                            $FirewallRulesFileComputerName = (($FirewallFileName.BaseName | Where {$_ -match 'Rules'}) -split ' - ')[0]
                            if ($Computer -eq $FirewallRulesFileComputerName) {
                                
                                $RestoreEndpointFirewallRulesFile = Import-Csv $FirewallFileName.FullName

                                Copy-Item -Path "$OutputFirewallRulesDirectory\$Computer - Firewall Rules.wfw" -Destination "C:\Windows\Temp\firewall-export.wfw" -ToSession $Session -Force -ErrorAction Stop
                                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message 'Copy-Item -Path "$OutputFirewallRulesDirectory\$Computer - Firewall Rules.wfw" -Destination "C:\Windows\Temp\firewall-export.wfw" -ToSession $Session -Force -ErrorAction Stop'
                                $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  - Copying backup firewall rules to endpoint")

                                $ScriptBlockUnQuarantine = {
                                    Get-NetFirewallRule | Remove-NetFirewallRule
                                    netsh advfirewall import "C:\Windows\Temp\firewall-export.wfw" 
                                    Remove-Item "C:\Windows\Temp\firewall-export.wfw" -Force
                                }
                                Invoke-Command -ScriptBlock $ScriptBlockUnQuarantine -Session $Session
                                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message 'Invoke-Command -ScriptBlock $ScriptBlockUnQuarantine -Session $Session'
                                $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  - Applying backup firewall rules")

                                Copy-Item -Path "C:\Windows\Temp\Quarantine_Firewall_Log.log" -Destination "$OutputFirewallRulesDirectory\$Computer - Firewall Log.log" -FromSession $Session -ErrorAction Stop -Force
                                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message 'Copy-Item -Path "C:\Windows\Temp\Quarantine_Firewall_Log.log" -Destination "$OutputFirewallRulesDirectory\$Computer - Firewall Log.log" -FromSession $Session -ErrorAction Stop -Force'
                                $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  - Copying back firewall logs")

                                Start-Sleep -Seconds 1
                                Invoke-Command -ScriptBlock { Remove-Item "C:\Windows\Temp\Quarantine_Firewall_Log.log*" -Force } -Session $Session
                                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message 'Invoke-Command -ScriptBlock { Remove-Item "C:\Windows\Temp\Quarantine_Firewall_Log.log*" -Force } -Session $Session'
                                $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  - Cleaning up files on endpoint")

                                Tag-QuarantineMessage -Computer $Computer -Message "[Un-Quarantined] at $(Get-Date)`n"

                                # Maybe add a reset firewall rules options...
                                ###Invoke-Command -ScriptBlock { (New-Object -ComObject HNetCfg.FwPolicy2).RestoreLocalFirewallDefaults() } -Session $Session
                            }
                        }
                    }
                }
                $Session | Remove-PSSession -Force
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message '$Session | Remove-PSSession -Force'
                $StatusListBox.Items.Clear()
                $StatusListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  - PSSession closed")
            }
        }
    }
    # To alert the user that it's finished
    [system.media.systemsounds]::Exclamation.play()
}



