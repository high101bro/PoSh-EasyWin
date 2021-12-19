function Create-TreeViewCheckBoxArray {
    param(
        [switch]$Accounts,
        [switch]$Endpoint
    )

    if ($Accounts) {
        # This array stores checkboxes that are check; a minimum of at least one checkbox will be needed later in the script
        $script:AccountsTreeViewSelected = @()
        [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:AccountsTreeView.Nodes
        foreach ($root in $AllTreeViewNodes) {
            if ($root.Checked) {
                foreach ($Category in $root.Nodes) {
                    foreach ($Entry in $Category.nodes) {
                        $script:AccountsTreeViewSelected += $Entry.Text
                    }
                }
            }
            else {
                foreach ($Category in $root.Nodes) {
                    if ($Category.Checked) {
                        foreach ($Entry in $Category.nodes) { $script:AccountsTreeViewSelected += $Entry.Text }
                    }
                    else {
                        foreach ($Entry in $Category.nodes) {
                            if ($Entry.Checked) {
                                $script:AccountsTreeViewSelected += $Entry.Text
                            }
                        }
                    }
                }
            }
        }
        $script:AccountsTreeViewSelected = $script:AccountsTreeViewSelected | Select-Object -Unique
    }
    if ($Endpoint) {
        # This array stores checkboxes that are check; a minimum of at least one checkbox will be needed later in the script
        $script:ComputerTreeViewSelected = @()
        [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
        foreach ($root in $AllTreeViewNodes) {
            if ($root.Checked) {
                foreach ($Category in $root.Nodes) {
                    foreach ($Entry in $Category.nodes) {
                        $script:ComputerTreeViewSelected += $Entry.Text
                    }
                }
            }
            else {
                foreach ($Category in $root.Nodes) {
                    if ($Category.Checked) {
                        foreach ($Entry in $Category.nodes) { $script:ComputerTreeViewSelected += $Entry.Text }
                    }
                    else {
                        foreach ($Entry in $Category.nodes) {
                            if ($Entry.Checked) {
                                $script:ComputerTreeViewSelected += $Entry.Text
                            }
                        }
                    }
                }
            }
        }
        $script:ComputerTreeViewSelected = $script:ComputerTreeViewSelected | Select-Object -Unique
    }
}


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUCUmyxweCKrXcMgRCs4neUFD6
# y4OgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUUSyPqHzF45HcWIm/6A5ezPYcBRgwDQYJKoZI
# hvcNAQEBBQAEggEAho2u5KCBO7W1Lvm1pwL3V1299/indrx3lzhaycJ3VP6RnWIh
# zATVZJsbfFu9lb+P+kvByUWs9k/qlG4aGYRn+uiInBVorRW5R/hz/DjLIWPXZ4vi
# +Ys7/NAjfBgNgVN9yH+h+P2hov/Njs37SHBGea3czfr4EDCdEJDd8m17SCaNkZjB
# FuuQwf4nDwgAUsEBqvLTAHObcH97D21UDVCG9LQ2vDGWE0q+E3wTMMc51sY2Dcbp
# Pe0Vx/CCxOrhD+89Rc9QjfAPlsl5h5f8Y8cpZ/9SvV9hZkfI6S+M9J4SWsEGDOW7
# SaQaT+h9uOdo6zx0knmw5+xnYteaMSpY92Hugw==
# SIG # End signature block
