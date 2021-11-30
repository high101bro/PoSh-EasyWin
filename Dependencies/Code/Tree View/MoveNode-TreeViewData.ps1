function MoveNode-TreeViewData {
    param(
        [switch]$Accounts,
        [switch]$Endpoint,
        [switch]$SelectedAccounts,
        [switch]$SelectedEndpoint
    )
    if ($Accounts) {
        # Makes a copy of the checkboxed node name in the new Category
        $script:AccountsTreeNodeToMove = New-Object System.Collections.ArrayList

        if ($SelectedAccounts){
            # Adds (copies) the node to the new Category
            [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:AccountsTreeView.Nodes
            foreach ($root in $AllTreeViewNodes) {
                if ($root.Checked) { $root.Checked = $false }
                foreach ($Category in $root.Nodes) {
                    if ($Category.Checked) { $Category.Checked = $false }
                    foreach ($Entry in $Category.nodes) {
                        if ($Entry.text -eq $script:EntrySelected.text) {
                            AddTreeNodeTo-TreeViewData -Accounts -RootNode $script:TreeNodeAccountsList -Category $AccountsTreeNodePopupMoveComboBox.SelectedItem -Entry $Entry.text #-ToolTip "No Unique Data Available"
                            $script:AccountsTreeNodeToMove.Add($Entry.text)
                            break
                        }
                    }
                }
            }

            # Removes the original Account that was copied above
            foreach ($i in $script:AccountsTreeNodeToMove) {
                foreach ($root in $AllTreeViewNodes) {
                    foreach ($Category in $root.Nodes) {
                        foreach ($Entry in $Category.nodes) {
                            if (($i -contains $Entry.text) -and ($Entry.text -eq $script:EntrySelected.text)) {
                                $($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).CanonicalName = $AccountsTreeNodePopupMoveComboBox.SelectedItem
                                $ResultsListBox.Items.Add($Entry.text)
                                $Entry.remove()
                            }
                        }
                    }
                }
            }
        }
        else {
            # Adds (copies) the node to the new Category
            [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:AccountsTreeView.Nodes
            foreach ($root in $AllTreeViewNodes) {
                if ($root.Checked) { $root.Checked = $false }
                foreach ($Category in $root.Nodes) {
                    if ($Category.Checked) { $Category.Checked = $false }
                    foreach ($Entry in $Category.nodes) {
                        if ($Entry.Checked) {
                            AddTreeNodeTo-TreeViewData -Accounts -RootNode $script:TreeNodeAccountsList -Category $AccountsTreeNodePopupMoveComboBox.SelectedItem -Entry $Entry.text #-ToolTip "No Unique Data Available"
                            $script:AccountsTreeNodeToMove.Add($Entry.text)
                        }
                    }
                }
            }

            $AccountsAndAccountTreeViewTabControl.SelectedTab = $AccountsTreeviewTab
            $script:AccountsTreeNodeComboBox.SelectedItem = 'CanonicalName'

            # Removes the original Account that was copied above
            foreach ($i in $script:AccountsTreeNodeToMove) {
                foreach ($root in $AllTreeViewNodes) {
                    foreach ($Category in $root.Nodes) {
                        foreach ($Entry in $Category.nodes) {
                            if (($i -contains $Entry.text) -and ($Entry.Checked)) {
                                $($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).CanonicalName = $AccountsTreeNodePopupMoveComboBox.SelectedItem
                                $ResultsListBox.Items.Add($Entry.text)
                                $Entry.remove()
                            }
                        }
                    }
                }
            }
        }

        Remove-EmptyCategory -Accounts
        Save-TreeViewData -Accounts
    }
    if ($Endopint) {
        # Makes a copy of the checkboxed node name in the new Category
        $script:ComputerTreeNodeToMove = New-Object System.Collections.ArrayList

        if ($SelectedEndpoint){
            # Adds (copies) the node to the new Category
            [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
            foreach ($root in $AllTreeViewNodes) {
                if ($root.Checked) { $root.Checked = $false }
                foreach ($Category in $root.Nodes) {
                    if ($Category.Checked) { $Category.Checked = $false }
                    foreach ($Entry in $Category.nodes) {
                        if ($Entry.text -eq $script:EntrySelected.text) {
                            AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category $ComputerTreeNodePopupMoveComboBox.SelectedItem -Entry $Entry.text #-ToolTip "No Unique Data Available"
                            $script:ComputerTreeNodeToMove.Add($Entry.text)
                            break
                        }
                    }
                }
            }

            # Removes the original hostname/IP that was copied above
            foreach ($i in $script:ComputerTreeNodeToMove) {
                foreach ($root in $AllTreeViewNodes) {
                    foreach ($Category in $root.Nodes) {
                        foreach ($Entry in $Category.nodes) {
                            if (($i -contains $Entry.text) -and ($Entry.text -eq $script:EntrySelected.text)) {
                                $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).CanonicalName = $ComputerTreeNodePopupMoveComboBox.SelectedItem
                                $ResultsListBox.Items.Add($Entry.text)
                                $Entry.remove()
                            }
                        }
                    }
                }
            }
        }
        else {
            # Adds (copies) the node to the new Category
            [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
            foreach ($root in $AllTreeViewNodes) {
                if ($root.Checked) { $root.Checked = $false }
                foreach ($Category in $root.Nodes) {
                    if ($Category.Checked) { $Category.Checked = $false }
                    foreach ($Entry in $Category.nodes) {
                        if ($Entry.Checked) {
                            AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category $ComputerTreeNodePopupMoveComboBox.SelectedItem -Entry $Entry.text #-ToolTip "No Unique Data Available"
                            $script:ComputerTreeNodeToMove.Add($Entry.text)
                        }
                    }
                }
            }

            $ComputerAndAccountTreeViewTabControl.SelectedTab = $ComputerTreeviewTab
            $script:ComputerTreeNodeComboBox.SelectedItem = 'CanonicalName'

            # Removes the original hostname/IP that was copied above
            foreach ($i in $script:ComputerTreeNodeToMove) {
                foreach ($root in $AllTreeViewNodes) {
                    foreach ($Category in $root.Nodes) {
                        foreach ($Entry in $Category.nodes) {
                            if (($i -contains $Entry.text) -and ($Entry.Checked)) {
                                $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).CanonicalName = $ComputerTreeNodePopupMoveComboBox.SelectedItem
                                $ResultsListBox.Items.Add($Entry.text)
                                $Entry.remove()
                            }
                        }
                    }
                }
            }
        }

        Remove-EmptyCategory -Endpoint
        Save-TreeViewData -Endpoint
    }
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUU8umOiUX4lttTeYm+RL9yizO
# sJygggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUW2AGbJ6ItCw2KMTWf/9NbGAir/4wDQYJKoZI
# hvcNAQEBBQAEggEAbyLjLq2vLfygdn5x3PHpFmyslA/KIhwaV8/X1rA5euvWwTwi
# ZlJ1pjzAweS9IQEuxD5QV+Gyl/rlGnyCo6ocpHyRAei5BzHpzGSzJwiA+fn9kV2n
# qR6Few2b7AnSDJZ7Ymj2c1Nui+J7BzVVwmb6nj0Yv79cMuBQCjtl+vLBKAKFuAr6
# msUbir65gMpOaF+gHjXkVFfMw3YeTo08HbM4K/DzJ7pQEQwOUFVVHwns1JfNkhp3
# uTPcsqU5rMaSq1p1ON4w63ytRSLC/sYRyymLwLFS55sBnRuXL6/Y8bkQUfYmGyVn
# hpK0Pc2PHVFYmDVj55Y4SAtW/1PzMslTngi4Uw==
# SIG # End signature block
