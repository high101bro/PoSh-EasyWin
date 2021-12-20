function Quarantine-EndpointsWithFirewallRules {
    param(
        [switch]$CopyEndpointFirewallRulesToLocalhost,
        [switch]$ApplyFirewallRulesLocalCopyToEndpoints
    )
    $InformationTabControl.SelectedTab = $Section3ResultsTab

    $ResultsListBox.Items.Clear()

    $OutputFirewallRulesDirectory = "$PoShHome\Endpoint Firewall Rules"
    if (-not (Test-Path $OutputFirewallRulesDirectory)) { New-Item -Type Directory $OutputFirewallRulesDirectory }

    function Tag-QuarantineMessage {
        param($Message,$Computer)
        [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
        $ComputerListMassTagArray = @()
        foreach ($node in $script:ComputerTreeViewSelected) {
            foreach ($root in $AllTreeViewNodes) {
                foreach ($Category in $root.Nodes) {
                    foreach ($Entry in $Category.Nodes) {
                        if ($Entry.Checked -and $Entry.Text -eq "$Computer" -and $Entry.Text -notin $ComputerListMassTagArray) {
                            $ComputerListMassTagArray += $Entry.Text
                            $script:Section3HostDataNameTextBox.Text      = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).Name
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
        Save-TreeViewData -Endpoint -SaveAllChecked
    }

    Generate-ComputerList
    if ($script:ComputerList.count -eq 0){
        Show-MessageBox -Message 'Ensure you checkbox one or more endpoints.' -Title "PoSh-EasyWin - No Endpoints Selected" -Options "Ok" -Type "Error" -Sound
    }
    elseif ($ActionsTabCopyEndpointFirewallRulesRadioButton.checked -and $script:ActionsTabQuarantineEndpointAccessFromIPSubnetTextbox.text -eq "Enter IP, Range, or Subnet"){
        Show-MessageBox -Message "Error: Make sure you enter a valid IP, Range, or Subnet.`n
NOTE: Mouse hover over the textbox for a list of references.`n
CAUTION! If you make a bad entry, you may cause the endpoints to become inaccessible over the network." -Title "PoSh-EasyWin - Enter A Valid Entry" -Options "Ok" -Type "Error" -Sound
    }
    else {
        # Provides a messagebox with the proper prompt depending on which radiobutton was seclected
        if ($ActionsTabCopyEndpointFirewallRulesRadioButton.checked){
            $BackupAndQuarantineMessageBox = Show-MessageBox -Message "Backup the firewall rules and quarantine the following endpoints:`n
$($script:ComputerList -join ', ')`n
These endpoints will only be accessable from the following:`n
$($script:ActionsTabQuarantineEndpointAccessFromIPSubnetTextbox.text)`n
CAUTION! If you make a bad entry, you may cause the endpoints to become inaccessible over the network." -Title "PoSh-EasyWin - Backup and Quarantine" -Options "YesNo" -Type "Error" -Sound
        }
        elseif ($ActionsTabApplyFirewallRulesLocalCopyToEndpointsRadioButton.checked){
            $BackupAndQuarantineMessageBox = Show-MessageBox -Message "Restore the firewall rules and Un-Quarantine the following endpoints:`n`n$($script:ComputerList -join ', ')" -Title "PoSh-EasyWin - Restore and Un-Quarantine" -Options "YesNo" -Type "Error" -Sound
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
                    if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
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
                        $script:ActionsTabQuarantineEndpointAccessFromIPSubnetTextboxText = $script:ActionsTabQuarantineEndpointAccessFromIPSubnetTextbox.Text
                        $CancelQuarantine = $false

                        if (Test-Path "$OutputFirewallRulesDirectory\$Computer - Firewall Rules.wfw"){
                            $OverwriteFirewallFile = Show-MessageBox -Message "Warning: A version of the firewall rules for $Computer already exists.`n`nDo you want to overwrite the local copy?" -Title "PoSh-EasyWin - Overwrite Local Copy" -Options "YesNoCancel" -Type "Warning" -Sound
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
                            Invoke-Command -ScriptBlock $ScriptBlockQuarantine -ArgumentList @($script:ActionsTabQuarantineEndpointAccessFromIPSubnetTextboxText,$null) -Session $Session
                            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message 'Invoke-Command -ScriptBlock $ScriptBlockQuarantine -ArgumentList @($script:ActionsTabQuarantineEndpointAccessFromIPSubnetTextboxText,$null) -Session $Session'
                            $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  - Applying Quarantine firewall rules")

                            Tag-QuarantineMessage -Computer $Computer -Message "[Quarantined] at $(Get-Date) -- Accessible from $script:ActionsTabQuarantineEndpointAccessFromIPSubnetTextboxText`n"
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

    if ($script:RollCredentialsState -and $script:ComputerListProvideCredentialsCheckBox.checked) {
        Start-Sleep -Seconds 3
        Generate-NewRollingPassword
    }
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUgYhy+/d5rJhR2bWMM9w8sjrH
# c2mgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUfw4jdMfHq01QibsLcB0VOrvuFg0wDQYJKoZI
# hvcNAQEBBQAEggEAS4Gg/Qa4kDsymwTtco3g7bS9zkZyiKzYSJjNfFhgtRGM3xyV
# Kt6mglx75PXDJQb5pf7oN9Dul425Vfj8tJA78N499VZkEmRIDD1hq1TtKQlnXHLc
# Nxnf/9y+eLLp+gVQVx5EAegXEmWt1lAvz4HVjd+vh6YuIj/a5WYvIW2qtc+qeg2v
# T3A3DsU8qCKSOxstREyY+orbW7uy8Hy7H3Sv+lEbzEu19WY74s3Uj7yGSQS0pWrb
# NolVJmNW2WtUoB5XLv2Eg/a5A75w+A5CvNuDK3bF9zvxDM1DBqrdhmsutCEZkdhj
# SezWkZFBWM6M7eRurMr1/nQewPrIa1sUS4j3mQ==
# SIG # End signature block
