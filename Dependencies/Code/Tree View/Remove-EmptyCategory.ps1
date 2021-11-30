function Remove-EmptyCategory {
    param(
        [switch]$Accounts,
        [switch]$Endpoint
    )
    if ($Accounts) {
        # Checks if the category node is empty, if so the node is removed
        [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:AccountsTreeView.Nodes
        foreach ($root in $AllTreeViewNodes) {
            foreach ($Category in $root.Nodes) {
                [int]$CategoryNodeContentCount = 0
                # Counts the number of computer nodes in each category
                foreach ($Entry in $Category.nodes) {
                    if ($Entry.Test -ne '' -and $Entry.Text -ne $null){
                        $CategoryNodeContentCount += 1
                    }
                }
                # Removes a category node if it is empty
                if ($CategoryNodeContentCount -eq 0 ) {
                    $Category.remove()
                }
            }
        }
    }
    if ($Endpoint) {
        # Checks if the category node is empty, if so the node is removed
        [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
        foreach ($root in $AllTreeViewNodes) {
            foreach ($Category in $root.Nodes) {
                [int]$CategoryNodeContentCount = 0
                # Counts the number of computer nodes in each category
                foreach ($Entry in $Category.nodes) {
                    if ($Entry.Test -ne '' -and $Entry.Text -ne $null){
                        $CategoryNodeContentCount += 1
                    }
                }
                # Removes a category node if it is empty
                if ($CategoryNodeContentCount -eq 0 ) {
                    $Category.remove()
                }
            }
        }
    }

    #   $ComputerTreeNodePopup.close()
}


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUnMnwkS/OKTozM082zusuGWAs
# JvWgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU+4HCot9xBLmL3I4KlwLbhMqQ0y8wDQYJKoZI
# hvcNAQEBBQAEggEAIzF41mz+KrbymC7Ih2FygZZd6Nymrt8DvMU3raxidX1L7yn/
# RSgLYMsLmL1DYnPQULy0KEqwB+BvIftY8wsmaw1n5T6ouQ/cUEww6ImhScphXtvU
# oQrzzjs98QBW63X+FTNddDVPqM7eXcY2ZnFnUW9kymsCHOqfb/eMv4j7eQJKJ963
# kVe2NoSoBBWU3QF83CAREOgutWTSltSYMeoMSg4zSQb6cxVgmIJRUiJfLvLizAM8
# hYBaqR/qHEwAcyzcLw+VtqeUhqhEiGzp3YmX9PsLoTWi+rCNH+NQDuYh1lhGU0U6
# m0wo44Os6iEUnAYbJt1lgTwvx1b4v/h7uPe29Q==
# SIG # End signature block
