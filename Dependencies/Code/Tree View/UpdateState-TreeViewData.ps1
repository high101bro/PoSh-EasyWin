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
# 1ZagggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUC+PvrogkeSd4wU+NWDGdZnesHqAwDQYJKoZI
# hvcNAQEBBQAEggEAx14nH4InRfTwiPnXzU9YSumqfR5CIGmkVvY6esKzbzRpElpM
# rtNcwP7whKDFojYoLP+p2hNo3oa9psYr+86yRy0P6f74HkGrQSDVtYsW2p3VCdCP
# 6bT8k8ygjMB36hlY4/8tqO6ACF6s3aJmJpjjq57OayCnFHoNXv8ySqy1iApOBQoJ
# jAWlBPAWcfRMZKFgQX025zYnC+XwiTUJ/xxxRFzkufZL/6xTAxpDcB2303QEUyjt
# YcqL9R2CqBDDE4Mv94MT8j4SItkrKdo+op1zO6bAiACc1h5nFEao6gLVXlSYhqv6
# yc/hhIBoIMuUCWqbeBFoc4f0iSZY1c2o8e4zsg==
# SIG # End signature block
