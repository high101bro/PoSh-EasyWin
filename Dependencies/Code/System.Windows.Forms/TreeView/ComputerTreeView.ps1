$ComputerTreeViewAdd_Click = {
    Update-TreeViewData -Endpoint -TreeView $this.Nodes

    # When the node is checked, it updates various items
    [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $this.Nodes
    foreach ($root in $AllTreeViewNodes) {
        if ($root.checked) {
            $root.Expand()
            foreach ($Category in $root.Nodes) {
                $Category.Expand()
                foreach ($Entry in $Category.nodes) {
                    $Entry.Checked      = $True
                    $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                    $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,0,224)
                    $Category.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                    $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                    $Root.NodeFont      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                    $Root.ForeColor     = [System.Drawing.Color]::FromArgb(0,0,0,224)
                }
            }
        }
        foreach ($Category in $root.Nodes) {
            $EntryNodeCheckedCount = 0
            if ($Category.checked) {
                $Category.Expand()
                $Category.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                $Root.NodeFont      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                $Root.ForeColor     = [System.Drawing.Color]::FromArgb(0,0,0,224)
                foreach ($Entry in $Category.nodes) {
                    $EntryNodeCheckedCount  += 1
                    $Entry.Checked      = $True
                    $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                    $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,0,224)
                }
            }
            if (!($Category.checked)) {
                foreach ($Entry in $Category.nodes) {
                    #if ($Entry.isselected) {
                    if ($Entry.checked) {
                        $EntryNodeCheckedCount  += 1
                        $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                        $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,0,224)
                        $Root.NodeFont      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                        $Root.ForeColor     = [System.Drawing.Color]::FromArgb(0,0,0,224)
                    }
                    elseif (!($Entry.checked)) {
                        if ($CategoryCheck -eq $False) {$Category.Checked = $False}
                        $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                        $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,0,0)
                    }
                }
            }
            if ($EntryNodeCheckedCount -gt 0) {
                $Category.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                $Root.NodeFont      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                $Root.ForeColor     = [System.Drawing.Color]::FromArgb(0,0,0,224)
            }
            else {
                $Category.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
                $Root.NodeFont      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                $Root.ForeColor     = [System.Drawing.Color]::FromArgb(0,0,0,0)
            }
        }
    }
}

$ComputerTreeViewAdd_AfterSelect = {
    Update-TreeViewData -Endpoint -TreeView $this.Nodes

    # This will return data on hosts selected/highlight, but not necessarily checked
    [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $this.Nodes
    foreach ($root in $AllTreeViewNodes) {
        if ($root.isselected) {
            $script:ComputerTreeViewSelected = ""
            $StatusListBox.Items.clear()
            $StatusListBox.Items.Add("Category:  $($root.Text)")
            #Removed For Testing#$ResultsListBox.Items.Clear()
            #$ResultsListBox.Items.Add("- Checkbox this Category to query all its hosts")

            $script:Section3HostDataNameTextBox.Text                     = 'N/A'
            $Section3HostDataOUTextBox.Text                              = 'N/A'
            $Section3EndpointDataCreatedTextBox.Text                     = 'N/A'
            $Section3EndpointDataModifiedTextBox.Text                    = 'N/A'
            $Section3EndpointDataLastLogonDateTextBox.Text               = 'N/A'
            $Section3HostDataIPTextBox.Text                              = 'N/A'
            $Section3HostDataMACTextBox.Text                             = 'N/A'
            $Section3EndpointDataEnabledTextBox.Text                     = 'N/A'
            $Section3EndpointDataisCriticalSystemObjectTextBox.Text      = 'N/A'
            $Section3EndpointDataSIDTextBox.Text                         = 'N/A'
            $Section3EndpointDataOperatingSystemTextBox.Text             = 'N/A'
            $Section3EndpointDataOperatingSystemHotfixComboBox.Text      = 'N/A'
            $Section3EndpointDataOperatingSystemServicePackComboBox.Text = 'N/A'
            $Section3EndpointDataMemberOfComboBox.Text                   = 'N/A'
            $Section3EndpointDataLockedOutTextBox.Text                   = 'N/A'
            $Section3EndpointDataLogonCountTextBox.Text                  = 'N/A'
            $Section3EndpointDataPortScanComboBox.Text                   = 'N/A'
            $Section3HostDataSelectionComboBox.Text                      = 'N/A'
            $Section3HostDataSelectionDateTimeComboBox.Text              = 'N/A'
            $Section3HostDataNotesRichTextBox.Text                       = 'N/A'

            # Brings the Host Data Tab to the forefront/front view
            $InformationTabControl.SelectedTab   = $Section3HostDataTab
        }
        foreach ($Category in $root.Nodes) {
            if ($Category.isselected) {
                $script:ComputerTreeViewSelected = ""
                $StatusListBox.Items.clear()
                $StatusListBox.Items.Add("Category:  $($Category.Text)")
                #Removed For Testing#$ResultsListBox.Items.Clear()
                #$ResultsListBox.Items.Add("- Checkbox this Category to query all its hosts")

                # The follwing fields are filled out with N/A when host nodes are not selected
                $script:Section3HostDataNameTextBox.Text                     = 'N/A'
                $Section3HostDataOUTextBox.Text                              = 'N/A'
                $Section3EndpointDataCreatedTextBox.Text                     = 'N/A'
                $Section3EndpointDataModifiedTextBox.Text                    = 'N/A'
                $Section3EndpointDataLastLogonDateTextBox.Text               = 'N/A'
                $Section3HostDataIPTextBox.Text                              = 'N/A'
                $Section3HostDataMACTextBox.Text                             = 'N/A'
                $Section3EndpointDataEnabledTextBox.Text                     = 'N/A'
                $Section3EndpointDataisCriticalSystemObjectTextBox.Text      = 'N/A'
                $Section3EndpointDataSIDTextBox.Text                         = 'N/A'
                $Section3EndpointDataOperatingSystemTextBox.Text             = 'N/A'
                $Section3EndpointDataOperatingSystemHotfixComboBox.Text      = 'N/A'
                $Section3EndpointDataOperatingSystemServicePackComboBox.Text = 'N/A'
                $Section3EndpointDataMemberOfComboBox.Text                   = 'N/A'
                $Section3EndpointDataLockedOutTextBox.Text                   = 'N/A'
                $Section3EndpointDataLogonCountTextBox.Text                  = 'N/A'
                $Section3EndpointDataPortScanComboBox.Text                   = 'N/A'
                $Section3HostDataSelectionComboBox.Text                      = 'N/A'
                $Section3HostDataSelectionDateTimeComboBox.Text              = 'N/A'
                $Section3HostDataNotesRichTextBox.Text                       = 'N/A'

                # Brings the Host Data Tab to the forefront/front view
                $InformationTabControl.SelectedTab = $Section3HostDataTab
            }
            foreach ($Entry in $Category.nodes) {
                if ($Entry.isselected) {
                    $InformationTabControl.SelectedTab = $Section3HostDataTab
                    $script:ComputerTreeViewSelected = $Entry.Text
                }
            }
        }
    }
    $InformationTabControl.SelectedTab = $Section3HostDataTab
    Display-ContextMenuForComputerTreeNode -ClickedOnArea
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUdz38gZEJkCbEFNCTpIADOH7/
# 5RGgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUwPw2ancv2VOMLWhyvqnD7TfveBQwDQYJKoZI
# hvcNAQEBBQAEggEAfQZJsQdlx7J1kLLapZVcYJUCQ5JuWZvHSIdnfyTGwQ29Mq6T
# Z5TsxFvxuj7Tkd07ohuhAKw5laHqiCRJfarQBmswO0EqwPhJtLYzuy/wfVdxPcf9
# MWMwxhYl10KAObTtH+yGqXBWLfEzvc/NO7Q6bQ/XBX6fhoJSAqjDQJEgfiIFm0Qe
# 30CmEYgAwZwUIiBD1GZRnV7uPRToiV4R822gzrIT1bqncQIDlVT4eNrvvq/JBe/9
# MgpBhtd0GJHQ/9LpoooXqYdjWoQKf+mfN2X82pA+qo1SoDv2uVJA51m3XcmsZ+Tk
# icvPXDVCO1hXK4m4TxlGkSqv1v6LYjeDX4PrgA==
# SIG # End signature block
