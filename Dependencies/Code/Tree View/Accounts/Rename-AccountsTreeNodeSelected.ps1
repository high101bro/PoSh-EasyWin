function Rename-ComputerTreeNodeSelected {
    if ($script:ComputerTreeViewData.Name -contains $script:ComputerTreeNodeRenamePopupTextBox.Text) {
        Message-NodeAlreadyExists -Accounts -Message "Rename Hostname/IP:  Error" -Account $script:ComputerTreeNodeRenamePopupTextBox.Text

    }
    else {
        # Makes a copy of the checkboxed node name in the new Category
        $ComputerTreeNodeToRename = New-Object System.Collections.ArrayList

        # Adds (copies) the node to the new Category
        [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
        foreach ($root in $AllTreeViewNodes) {
            if ($root.Checked) { $root.Checked = $false }
            foreach ($Category in $root.Nodes) {
                if ($Category.Checked) { $Category.Checked = $false }
                foreach ($Entry in $Category.nodes) {
                    if ($Entry.IsSelected) {
                        AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category $Category.Text -Entry $script:ComputerTreeNodeRenamePopupTextBox.text #-ToolTip "No Unique Data Available"
                        $ComputerTreeNodeToRename.Add($Entry.text)

                        $script:PreviousEndpointName = $script:EntrySelected.Text
                        $Section3HostDataNotesRichTextBox.Text = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).Notes + "`r`nPrevious Endpoint Name: $script:PreviousEndpointName"
                        Save-TreeViewData -Endpoint
                        break
                    }
                }
            }
        }
        # Removes the original hostname/IP that was copied above
        foreach ($i in $ComputerTreeNodeToRename) {
            foreach ($root in $AllTreeViewNodes) {
                foreach ($Category in $root.Nodes) {
                    foreach ($Entry in $Category.nodes) {
                        if (($i -contains $Entry.text) -and ($Entry.IsSelected)) {
                            $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).Name = $script:ComputerTreeNodeRenamePopupTextBox.text
                            $ResultsListBox.Items.Add($Entry.text)
                            $Entry.remove()
                        }
                    }
                }
            }
        }
        Save-TreeViewData -Endpoint
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Rename Selection:  $($ComputerTreeNodeToRename.Count) Hosts")
        #Removed For Testing#$ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("The computer has been renamed to $($script:ComputerTreeNodeRenamePopupTextBox.Text)")
    }
    $ComputerTreeNodeRenamePopup.close()
}


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUMbzOC0RVP+gnf49DwTOCigIf
# PMOgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUFxKA+PQcRPmS6DjoTfz4wckdWcQwDQYJKoZI
# hvcNAQEBBQAEggEAfZodKRZPy7CC5ZhxdFREuthIqOUuj3OSIi8MWDLPrXV2O0No
# OVSh+pKFG+dMr0tEOoQxLzO5XEgO5p+4KBasCC4lfcqEpgMUQwlRLqmmlmHMf2S/
# d6iGPTdHavVTZU1XCHgBMOCHwzbc75+5gRhC1VYZu8K/pVtLDKedXDs0e5ZnU+gU
# MoNLOiCj2rSJgYA126GGuPUab8vWywxmNVhHhJY88O2Om1Hs6RBiRTmab+tduaKX
# fQheuy9Gzy14a1BXKsCBDWFdtpwhfIXMS4GWYH3xWHvp0OHjRoeU3tjvKc6HcZnU
# YRLbUp8zlVWCxMcasgBQlIhvbsF+deNlK9Bkzw==
# SIG # End signature block
