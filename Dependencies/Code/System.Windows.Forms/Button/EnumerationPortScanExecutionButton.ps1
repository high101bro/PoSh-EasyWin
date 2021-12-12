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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUDEVPspFdf+cRUPUw1XbndmtE
# GUGgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
# AQUFADAzMTEwLwYDVQQDDChQb1NoLUVhc3lXaW4gQnkgRGFuIEtvbW5pY2sgKGhp
# Z2gxMDFicm8pMB4XDTIxMTEyOTIzNDA0NFoXDTMxMTEyOTIzNTA0M1owMzExMC8G
# A1UEAwwoUG9TaC1FYXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANUnnNeIFC/eQ11BjDFsIHp1
# 2HkKgnRRV07Kqsl4/fibnbOclptJbeKBDQT3iG5csb31s9NippKfzZmXfi69gGE6
# v/L3X4Zb/10SJdFLstfT5oUD7UdiOcfcNDEiD+8OpZx4BWl5SNWuSv0wHnDSIyr1
# 2M0oqbq6WA2FqO3ETpdhkK22N3C7o+U2LeuYrGxWOi1evhIHlnRodVSYcakmXIYh
# pnrWeuuaQk+b5fcWEPClpscI5WiQh2aohWcjSlojsR+TiWG/6T5wKFxSJRf6+exu
# C0nhKbyoY88X3y/6qCBqP6VTK4C04tey5z4Ux4ibuTDDePqH5WpRFMo9Vie1nVkC
# AwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0G
# A1UdDgQWBBS2KLS0Frf3zyJTbQ4WsZXtnB9SFDANBgkqhkiG9w0BAQUFAAOCAQEA
# s/TfP54uPmv+yGI7wnusq3Y8qIgFpXhQ4K6MmnTUpZjbGc4K3DRJyFKjQf8MjtZP
# s7CxvS45qLVrYPqnWWV0T5NjtOdxoyBjAvR/Mhj+DdptojVMMp2tRNPSKArdyOv6
# +yHneg5PYhsYjfblzEtZ1pfhQXmUZo/rW2g6iCOlxsUDr4ZPEEVzpVUQPYzmEn6B
# 7IziXWuL31E90TlgKb/JtD1s1xbAjwW0s2s1E66jnPgBA2XmcfeAJVpp8fw+OFhz
# Q4lcUVUoaMZJ3y8MfS+2Y4ggsBLEcWOK4vGWlAvD5NB6QNvouND1ku3z94XmRO8v
# bqpyXrCbeVHascGVDU3UWTGCAegwggHkAgEBMEcwMzExMC8GA1UEAwwoUG9TaC1F
# YXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKQIQVnYuiASKXo9Gly5k
# J70InDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkq
# hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGC
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUT2fUk3uHP/flBP6AELKTX+uagEswDQYJKoZI
# hvcNAQEBBQAEggEAAc4N3rLUZPczIgn4nIwWBnTvUi7baIUybPU5bR5++awA6EQF
# v7+WAwh+jqbcJtjzVVontlP7UX9QRD7qB9zt9KeNUhYxSodpzQgk+olnlaSuHsDt
# 3WGqMSftrxb4Kxkf0b2K2nkeH3GUXy50jn+Io6YOe3khay6ihOpVAhFosAFheNr2
# ebIjUW7BWM+A+n6PXF1vB/VB1gDLH9VMebhZ+0JMkDxddDztArH404xGp4YISZ/d
# TFN3p0T125oe6q8MWiWGgB+b3iDULd4bscYobm8vg4LZ92lgToilbPRLAYezhwfk
# 1FfWp2KfcDYZNp/xhMIQMS5yd+owOZHt9U4d8w==
# SIG # End signature block
