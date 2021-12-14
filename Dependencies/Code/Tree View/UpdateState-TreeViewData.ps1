function UpdateState-TreeViewData {
    param(
        [switch]$Accounts,
        [switch]$Endpoint,
    	[switch]$NoMessage
    )
    if ($Accounts) {
        $script:AccountsTreeView.Nodes.Add($script:TreeNodeComputerList)
        $script:AccountsTreeView.ExpandAll()
    
        if ($script:AccountsTreeViewSelected.count -gt 0) {
            ##if (-not $NoMessage) {
            ##    #Removed For Testing#$ResultsListBox.Items.Clear()
            ##    $ResultsListBox.Items.Add("Categories that were checked will not remained checked.")
            ##    $ResultsListBox.Items.Add("")
            ##    $ResultsListBox.Items.Add("The following hostname/IP selections are still selected in the new treeview:")
            ##}
            foreach ($root in $AllTreeViewNodes) {
                foreach ($Category in $root.Nodes) {
                    foreach ($Entry in $Category.nodes) {
                        $Entry.Collapse()
                        if ($script:AccountsTreeViewSelected -contains $Entry.text -and $root.text -notmatch 'Custom Group Commands') {
                            $Entry.Checked      = $true
                            $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                            $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,0,224)
                            $Category.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                            $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                           ## $ResultsListBox.Items.Add(" - $($Entry.Text)")
                        }
                        foreach ($Metadata in $Entry.Nodes){
                            $Metadata.Drawing = $False
                        }
                    }
                }
            }
        }
        else {
            foreach ($root in $AllTreeViewNodes) {
                foreach ($Category in $root.Nodes) {
                    foreach ($Entry in $Category.Nodes) {
                        $Entry.Collapse()
                        foreach ($Metadata in $Entry.Nodes){
                            $Metadata.Drawing = $false
                        }
                    }
                }
            }
        }
    }
    if ($Endpoint) {
        $script:ComputerTreeView.Nodes.Add($script:TreeNodeComputerList)
        $script:ComputerTreeView.ExpandAll()
    
        if ($script:ComputerTreeViewSelected.count -gt 0) {
            ##if (-not $NoMessage) {
            ##    #Removed For Testing#$ResultsListBox.Items.Clear()
            ##    $ResultsListBox.Items.Add("Categories that were checked will not remained checked.")
            ##    $ResultsListBox.Items.Add("")
            ##    $ResultsListBox.Items.Add("The following hostname/IP selections are still selected in the new treeview:")
            ##}
            foreach ($root in $AllTreeViewNodes) {
                foreach ($Category in $root.Nodes) {
                    foreach ($Entry in $Category.nodes) {
                        $Entry.Collapse()
                        if ($script:ComputerTreeViewSelected -contains $Entry.text -and $root.text -notmatch 'Custom Group Commands') {
                            $Entry.Checked      = $true
                            $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                            $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,0,224)
                            $Category.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                            $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                           ## $ResultsListBox.Items.Add(" - $($Entry.Text)")
                        }
                        foreach ($Metadata in $Entry.Nodes){
                            $Metadata.Drawing = $False
                        }
                    }
                }
            }
        }
        else {
            foreach ($root in $AllTreeViewNodes) {
                foreach ($Category in $root.Nodes) {
                    foreach ($Entry in $Category.Nodes) {
                        $Entry.Collapse()
                        foreach ($Metadata in $Entry.Nodes){
                            $Metadata.Drawing = $false
                        }
                    }
                }
            }
        }
    }
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUkukXVl37PwCOyitd0yPsoPD9
# 1ZagggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUC+PvrogkeSd4wU+NWDGdZnesHqAwDQYJKoZI
# hvcNAQEBBQAEggEAXirpTlGscPn9MW2VSnL7Hh4RGC4V4r2eijR+R80Bhw4WYdsE
# g9rfht7LG996++sVP9+a0i7a1RhTMtdGzY0/JR2mOSLDmndfoFbLljOtbTRsI+r0
# xHD/5B32j27/uIdfpfGKPKfOx3DZE+RJlcjrsGT6pTQZ4pg9IY5hJVrsj8twFgxZ
# SeeXl+FqEhfeHneM3gQUKUPkQERWHS1WJO2bIQj3Pmo1ZKFe34ARrZIJ1h365Zej
# m5hjIbgISkKF4g3MIiEgUkE/PNfYEFtjUfdfTe1K/bGHS2Gz4qtIsqsj0GqAUvJH
# qkRW1XtL4VPwaxFw3dM/v+ryKqvLctUADghW0Q==
# SIG # End signature block
