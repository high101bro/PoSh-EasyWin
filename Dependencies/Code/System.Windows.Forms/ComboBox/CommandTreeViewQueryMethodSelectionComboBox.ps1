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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU8Ieq4dWcChh/pUMaG+oHvb5q
# 9DCgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU7c4h0T5wwSYeahmYgy3Vv7DLlBQwDQYJKoZI
# hvcNAQEBBQAEggEAtWQO/dlzaXIEKi1OPiIbDun6k3+07dWnFxyl6ZUASn81FOhc
# ieo2mLubI+rzdpwK5La3f+xQ7o2GgEBycmbabJtz8UwAxCUdcKE4wFxMy/Xsihj4
# PAp4Gih46NSLVvdQka+M88yPT4OeK+zcQYFOFEZsTODBzk8mxiS4d/OdweljGE/F
# g7oIrSMLZMn8seOidJIvn3tGPjjZNLddat9/eBID2uV6hDikGkK5YWjsqhFhipzt
# dSZVa0JdhfcMIEKNQoDyjtNQNowTxog/gslmtdaEvc1sGGoNKRrPjCpGTT6xbcDZ
# XgATxcURlTW9piUEQEkfYXj9zTLbw8tMa0UifA==
# SIG # End signature block
