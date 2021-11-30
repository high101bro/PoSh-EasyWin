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
# PCGgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUbeCHesCFlRJXvmk5WPrSKGfRjkswDQYJKoZI
# hvcNAQEBBQAEggEAK7rzNtjaV/AcYCKSIWqWawExZVjG5S3sMIlzEAhIMKeg11sk
# owlEGHXwkdpBzqdz22rbvg0pNXSX8jt4r3rrGC8LGrZkIsK2u3DRdOKm+m649Xnj
# iGY2pFb/oduUqBChYW11OVHFQ8O0CpZv068S/1b1atoTQFL70WA8U4YvQx3qf2TL
# ADid9RHCNDiYuh6nTe4eAoQQgziUhOJEeagkVR0/M+MATTvaCBiXqsnk10vOShaf
# tAZEaa1zBN161gS2XRgZ7dQS5cYTWd8nJJl+VLE/Kcta4YyltqeNR0oxH9AlbAWO
# uRcvCQ2hKxoseG/N6EPhLvGrL3xUyDEiPAzWiA==
# SIG # End signature block
