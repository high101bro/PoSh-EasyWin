function Rename-ComputerTreeNodeSelected {
    if ($script:ComputerTreeViewData.Name -contains $script:ComputerTreeNodeRenamePopupTextBox.Text) {
        Message-NodeAlreadyExists -Endpoint -Message "Rename Hostname/IP:  Error" -computer $script:ComputerTreeNodeRenamePopupTextBox.Text

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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUVOalvFBtPvFCRJ0nqIKxx7hq
# PTmgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUDAsfujUN6ri6WSZaaOdxe/S1FuIwDQYJKoZI
# hvcNAQEBBQAEggEAlrrrqFPrVrn/jTNYtQ0FRKXGqHDNaRDh7OPCYgyB1vjwRYOx
# awp+DFm0VqBmBg878e7dr05X8Zc8ndOrens3diFRi54ROI0KJEDnqlK7fWaYURIC
# hiu33O2b3s3nIqGw8iEzPSbjbL0Z39hRDCGKH1FP16h+i5OXAehVAbZJjbAd+U1p
# OpXfcQ9+svg68ZTKJsyK7YyIppAHVI+mAOs2c5HuQ2H1xCeYyWg8MVXE+KEqX+Lk
# trDMOsXBhD+LRbQiCpPHQvkvVHKL1sdlZ7y+QP4Ez/wc+n3hR5KkcXhzABS+JAGy
# 86jCHKMcP9xS0U8aA1H5SCZQB7WVg25DPzwHBQ==
# SIG # End signature block
