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
        }
        elseif ($script:ComputerListPivotExecutionCheckbox.checked -eq $true) {
            $InformationTabControl.SelectedTab = $Section3MonitorJobsTab

            if ($script:EnumerationPortScanSpecificComputerNodeCheckbox.checked -eq $true) {
                $InvokeCommandSplat = @{
                    ScriptBlock = {
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
                    }
                    ArgumentList = @($ConductPortScan,$script:ComputerList,$EnumerationPortScanPortQuickPickComboBox.SelectedItem,$EnumerationPortScanTimeoutTextbox.text,$EnumerationPortScanTestICMPFirstCheckBox.checked,$EnumerationPortScanSpecificPortsTextbox.text,$EnumerationPortScanPortRangeFirstTextbox.text,$EnumerationPortScanPortRangeLastTextbox.text)
                    AsJob        = $True
                    JobName      = "PoSh-EasyWin: $($CollectionName) -- $($script:ComputerListPivotExecutionTextBox.text)"
                    ComputerName = $script:ComputerListPivotExecutionTextBox.text
                }
    
                if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                    if (!$script:Credential) { Create-NewCredentials }
                    $InvokeCommandSplat += @{Credential = $script:Credential}
                }
                
                Invoke-Command @InvokeCommandSplat | Select-Object PSComputerName, *

                Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:Conduct-PortScan} -ArgumentList @($ConductPortScan,$script:ComputerList,$EnumerationPortScanPortQuickPickComboBox.SelectedItem,$EnumerationPortScanTimeoutTextbox.text,$EnumerationPortScanTestICMPFirstCheckBox.checked,$EnumerationPortScanSpecificPortsTextbox.text,$EnumerationPortScanPortRangeFirstTextbox.text,$EnumerationPortScanPortRangeLastTextbox.text) -InputValues $InputValues -DisableReRun -JobsExportFiles 'true'
            }
            elseif ($script:EnumerationPortScanSpecificComputerNodeCheckbox.checked -eq $false) {

                $InvokeCommandSplat = @{
                    ScriptBlock = {
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
                    }
                    ArgumentList = @($ConductPortScan,$EnumerationPortScanPortQuickPickComboBox.SelectedItem,$EnumerationPortScanTimeoutTextbox.Text,$EnumerationPortScanTestICMPFirstCheckBox.Checked,$EnumerationPortScanSpecificIPTextbox.Text,$EnumerationPortScanSpecificPortsTextbox.Text,$EnumerationPortScanIPRangeNetworkTextbox.Text,$EnumerationPortScanIPRangeFirstTextbox.Text,$EnumerationPortScanIPRangeLastTextbox.Text,$EnumerationPortScanPortRangeFirstTextbox.Text,$EnumerationPortScanPortRangeLastTextbox.Text)
                    AsJob        = $True
                    JobName      = "PoSh-EasyWin: $($CollectionName) -- $($script:ComputerListPivotExecutionTextBox.text)"
                    ComputerName = $script:ComputerListPivotExecutionTextBox.text
                }
    
                if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                    if (!$script:Credential) { Create-NewCredentials }
                    $InvokeCommandSplat += @{Credential = $script:Credential}
                }
                
                Invoke-Command @InvokeCommandSplat | Select-Object PSComputerName, *

                Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:Conduct-PortScan} -ArgumentList @($ConductPortScan,$EnumerationPortScanPortQuickPickComboBox.SelectedItem,$EnumerationPortScanTimeoutTextbox.Text,$EnumerationPortScanTestICMPFirstCheckBox.Checked,$EnumerationPortScanSpecificIPTextbox.Text,$EnumerationPortScanSpecificPortsTextbox.Text,$EnumerationPortScanIPRangeNetworkTextbox.Text,$EnumerationPortScanIPRangeFirstTextbox.Text,$EnumerationPortScanIPRangeLastTextbox.Text,$EnumerationPortScanPortRangeFirstTextbox.Text,$EnumerationPortScanPortRangeLastTextbox.Text) -InputValues $InputValues -DisableReRun -JobsExportFiles 'true'
            }
        }
    }
    else {
        [system.media.systemsounds]::Exclamation.play()
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Port Scan:  Cancelled")
    }

    $script:ComputerTreeView.Nodes.Clear()
    Initialize-TreeViewData -Endpoint
    Normalize-TreeViewData -Endpoint
    Save-TreeViewData -Endpoint

    $ComputerAndAccountTreeViewTabControl.SelectedTab = $ComputerTreeviewTab
    $script:ComputerTreeNodeComboBox.SelectedItem = 'CanonicalName'
    
    Foreach($Computer in $script:ComputerTreeViewData) {
        AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category $Computer.OperatingSystem -Entry $Computer.Name -ToolTip $ComputerData.IPv4Address -IPv4Address $Computer.IPv4Address -Metadata $Computer
    }
    UpdateState-TreeViewData -Endpoint
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUl5AIq3qObZmn0aDxKElFsmOw
# T32gggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU8BnDf+TvqJIrDLsmFRPdYT1XnZgwDQYJKoZI
# hvcNAQEBBQAEggEAhccqMR+09sLRabJvJ04PvBFFBk1ElwaMVAUA3JxmQInB1uIi
# IHU64byanVb8jP/sqd9DXnJIIds9+hMBo8dT+QU2/XtvSFnWmbZHlHcKohytwKUs
# gXVwJjDyGYk6T7t8ZSfTNxC4bdTGvSg8Wum7ryymBsmgA3ux51xx2EAofO76MGHS
# MaPCG6WI23IsuAcmgEtxWS89DUsGS1ylC+p5PMYME26kcrJ3ApDf6zqbZmiWhEsb
# GE7yPApsqfM5bi5MPHEcJ28r7AMXtRKhwRnhjlax/5Snewbpfj/AX9n2sS/7TNpk
# Bp6QykOf9ri6MnjZAxR/nktQb3SePY6ahoJFMw==
# SIG # End signature block
