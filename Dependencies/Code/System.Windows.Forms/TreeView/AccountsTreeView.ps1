$AccountsTreeViewAdd_Click = {
    Update-TreeViewData -Accounts -TreeView $this.Nodes

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

$AccountsTreeViewAdd_AfterSelect = {
    Update-TreeViewData -Accounts -TreeView $this.Nodes

    # This will return data on hosts selected/highlight, but not necessarily checked
    [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $this.Nodes
    foreach ($root in $AllTreeViewNodes) {
        if ($root.isselected) {
            $script:ComputerTreeViewSelected = ""
            $StatusListBox.Items.clear()
            $StatusListBox.Items.Add("Category:  $($root.Text)")
            #Removed For Testing#$ResultsListBox.Items.Clear()
            #$ResultsListBox.Items.Add("- Checkbox this Category to query all its hosts")

            $script:Section3AccountDataNameTextBox.Text             = 'N/A'
            $Section3AccountDataEnabledTextBox.Text                 = 'N/A'
            $Section3AccountDataOUTextBox.Text                      = 'N/A'
            $Section3AccountDataLockedOutTextBox.Text               = 'N/A'
            $Section3AccountDataSmartCardLogonRequiredTextBox.Text  = 'N/A'
            $Section3AccountDataCreatedTextBox.Text                 = 'N/A'
            $Section3AccountDataModifiedTextBox.Text                = 'N/A'
            $Section3AccountDataLastLogonDateTextBox.Text           = 'N/A'
            $Section3AccountDataLastBadPasswordAttemptTextBox.Text  = 'N/A'
            $Section3AccountDataBadLogonCountTextBox.Text           = 'N/A'
            $Section3AccountDataPasswordExpiredTextBox.Text         = 'N/A'
            $Section3AccountDataPasswordNeverExpiresTextBox.Text    = 'N/A'
            $Section3AccountDataPasswordNotRequiredTextBox.Text     = 'N/A'
            $Section3AccountDataMemberOfComboBox.Text               = 'N/A'
            $Section3AccountDataSIDTextBox.Text                     = 'N/A'
            $Section3AccountDataScriptPathTextBox.Text              = 'N/A'
            $Section3AccountDataHomeDriveTextBox.Text               = 'N/A'
            $script:Section3AccountDataNotesRichTextBox.Text        = 'N/A'

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
                $script:Section3AccountDataNameTextBox.Text             = 'N/A'
                $Section3AccountDataEnabledTextBox.Text                 = 'N/A'
                $Section3AccountDataOUTextBox.Text                      = 'N/A'
                $Section3AccountDataLockedOutTextBox.Text               = 'N/A'
                $Section3AccountDataSmartCardLogonRequiredTextBox.Text  = 'N/A'
                $Section3AccountDataCreatedTextBox.Text                 = 'N/A'
                $Section3AccountDataModifiedTextBox.Text                = 'N/A'
                $Section3AccountDataLastLogonDateTextBox.Text           = 'N/A'
                $Section3AccountDataLastBadPasswordAttemptTextBox.Text  = 'N/A'
                $Section3AccountDataBadLogonCountTextBox.Text           = 'N/A'
                $Section3AccountDataPasswordExpiredTextBox.Text         = 'N/A'
                $Section3AccountDataPasswordNeverExpiresTextBox.Text    = 'N/A'
                $Section3AccountDataPasswordNotRequiredTextBox.Text     = 'N/A'
                $Section3AccountDataMemberOfComboBox.Text               = 'N/A'
                $Section3AccountDataSIDTextBox.Text                     = 'N/A'
                $Section3AccountDataScriptPathTextBox.Text              = 'N/A'
                $Section3AccountDataHomeDriveTextBox.Text               = 'N/A'
                $script:Section3AccountDataNotesRichTextBox.Text        = 'N/A'
            }
            foreach ($Entry in $Category.nodes) {
                if ($Entry.isselected) {
                    $script:ComputerTreeViewSelected = $Entry.Text
                }
            }
        }
    }
    $InformationTabControl.SelectedTab = $Section3AccountDataTab
    Display-ContextMenuForAccountsTreeNode -ClickedOnArea
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUJA4GOF+EISuCmpwBMNA+5pZR
# PCGgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUbeCHesCFlRJXvmk5WPrSKGfRjkswDQYJKoZI
# hvcNAQEBBQAEggEAUx0KCOX60OGYXHP5x11HCe4HoqFnBVg74Y61PBkacp1nQQ2T
# UMjjBAQL4pwd8xdu0sT5kEvVGx+EFxLDFvY3kbPZ6MwnlA5KiLRb7B80+XOZxGWY
# Qpw1fpBsLQ8sUXjVmPKTaVlTWhLHnglSPUSNHKnP/2j/hlJaBlKAXwMRMPSktaSw
# iRL88d1oZDRp0/pJzZmG7Ryi8Tvl2HDS1gMSU/RDbe30LH36GxmIYxtqXectczz3
# oXYcQYj+pDD+5/vW2dUcc0XfoYOdv6SfxokZDB2o9k7BO9lJK0yfOcad44o2iQBu
# rN26rUzhXsIVoIl2TfJl8aMH5tQ+nWYIz1+cCw==
# SIG # End signature block
