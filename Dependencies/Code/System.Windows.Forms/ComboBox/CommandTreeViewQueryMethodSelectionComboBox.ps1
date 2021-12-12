$script:CommandTreeViewQueryMethodSelectionComboBoxAdd_SelectedIndexChanged = {
    $SelectedIndexTemp = $this.SelectedIndex
    if ( ($EventLogRPCRadioButton.checked -or $ExternalProgramsRPCRadioButton.checked -or $script:RpcCommandCount -gt 0 -or $script:SmbCommandCount -gt 0) -and $this.SelectedItem -eq 'Session Based' ) {
        $MessageBox = [System.Windows.Forms.MessageBox]::Show("The '$($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem)' mode does not support the RPC and SMB protocols.`nThe 'Monitor Jobs' collection mode supports the RPC, SMB, and WinRM protocols - but may be slower and noisier on the network.`n`nDo you want to change to 'Session Based' collection using the WinRM protocol?","Protocol Alert",[System.Windows.Forms.MessageBoxButtons]::OKCancel)
        switch ($MessageBox){
            "OK" {
                $StatusListBox.Items.Clear()
                $StatusListBox.Items.Add("Event Log Protocol Set To WinRM")
                $EventLogWinRMRadioButton.checked         = $true
                $ExternalProgramsWinRMRadioButton.checked = $true

                $RpcCommandNodesRemoved = @()
                $SmbCommandNodesRemoved = @()
                [System.Windows.Forms.TreeNodeCollection]$AllCommandsNode = $script:CommandsTreeView.Nodes
                foreach ($root in $AllCommandsNode) {
                    foreach ($Category in $root.Nodes) {
                        foreach ($Entry in $Category.nodes) {
                            if ($Entry.Checked -and $Entry.Text -match '[\[(]rpc[)\]]') {
                                $root.Checked     = $false
                                $Category.Checked = $false
                                $Entry.Checked    = $false
                                $RpcCommandNodesRemoved += $Entry
                            }
                            elseif ($Entry.Checked -and $Entry.Text -match '[\[(]smb[)\]]') {
                                $root.Checked     = $false
                                $Category.Checked = $false
                                $Entry.Checked    = $false
                                $SmbCommandNodesRemoved += $Entry
                            }
                        }
                    }
                }
                Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes

                # This brings specific tabs to the forefront/front view
                $MainLeftTabControl.SelectedTab = $Section1SearchTab
                $InformationTabControl.SelectedTab = $Section3ResultsTab

                #Removed For Testing#$ResultsListBox.Items.Clear()
                if ($RpcCommandNodesRemoved.count -gt 0) {
                    $ResultsListBox.Items.Add("The following RPC queries have been unchecked:")
                    foreach ($Entry in $RpcCommandNodesRemoved) {
                        $ResultsListBox.Items.Add("   $($Entry.Text)")
                    }
                }
                if ($SmbCommandNodesRemoved.count -gt 0) {
                    $ResultsListBox.Items.Add("The following SMB queries have been unchecked:")
                    foreach ($Entry in $SmbCommandNodesRemoved) {
                        $ResultsListBox.Items.Add("   $($Entry.Text)")
                    }
                }


            }
            "Cancel" {
                $this.SelectedIndex = 0 #'Monitor Jobs'
#                $StatusListBox.Items.Clear()
#                $StatusListBox.Items.Add("$($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem) does not support RPC")
             }
        }

    }

}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUQlwvXfQ5l1n/xnCVXcnmDh5/
# UXOgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUIgJ+MB48gkv+P4tZOwaXAUCG4NcwDQYJKoZI
# hvcNAQEBBQAEggEAJWZUqGI8vsfD2+fwBwPRdPcp8tfaHvSqVXZ1PG4oKtx7jyxL
# AsiiuhFZ163Y1v/RUKsxCh8o3z5mn0p2eV55Xcn4d+qYg62wXQW+iOo2w+UwxoFF
# nj1k62ioEcHriwgxnUSL9V+hRjnOZz/AuVklgMu80HeH5oNhIzq5PXh75t0hehxU
# RhmNbZdzIL08LD+QhPZpT7mRo4suoVRuDgER14lYHG23jlh0qvgnxlNLXS4m7MhJ
# yJf/C2qjS/5MhCfp2eIMfh8SBPLS+5is0y/rY8DhSKhWKY7YpPaanQJZ8aoI0+SL
# 6PtR6EtpWmFIoaQx/Ze0sG/P5sYod0cXLAkFEA==
# SIG # End signature block
