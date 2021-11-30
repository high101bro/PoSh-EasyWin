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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUBGiEe7B4kxW9pKD9CbeMgw+O
# njagggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUR/rN1mnd4C4ID5sz+ERwI0SfuaAwDQYJKoZI
# hvcNAQEBBQAEggEAfWihw3ESpkSZLAf4CzpA1NFFFoD62GnSgQfiIakF1STcmDA0
# 31IIYFcI9YmASPO+kORLRw0DkVgN7DkaKtDvnF6ksoOeb0S2SVRzs8vFAaU/ngGs
# LyCGd9fM/wjmuhnqfPgluZ8x8VvvCcVtf6TU2l690m2koBwEuJcCNk6Zdy+st66C
# q9LMqbWOXiApcbYtgEOOLsRd5L9bkiyDa5dX660r2kSIho0bHSNYnnL+JCTiinN0
# 8+6aGYr7T7Y0bls1fEARc7kffKOhfW+S2fn2mNXHQnx2TSzquSZwK2FdykjQ+dwa
# H2RxPOfm2F5ilpe0JpFf0NtL13Lo7VQOIHxStg==
# SIG # End signature block
