function Generate-ComputerList {
    # Generate list of endpoints to query
    
    #$StatusListBox.Items.Clear()
    #$StatusListBox.Items.Add("Multiple Host Collection")
    $script:ComputerList = @()
    $script:ComputerListAll = @()

    # If the root computerlist checkbox is checked, All Endpoints will be queried
    [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
    if ($script:ComputerListUseDNSCheckbox.checked) {
        if ($script:ComputerListSearch.Checked) {
            foreach ($root in $AllTreeViewNodes) {
                if ($root.text -imatch "Search Results") {
                    foreach ($Category in $root.Nodes) {
                        foreach ($Entry in $Category.nodes) {
                            $script:ComputerList += $Entry.text
                        }
                    }
                }
            }
        }
        if ($script:TreeNodeComputerList.Checked) {
            foreach ($root in $AllTreeViewNodes) {
                if ($root.text -imatch "All Endpoints") {
                    foreach ($Category in $root.Nodes) {
                        foreach ($Entry in $Category.nodes) {
                            $script:ComputerList += $Entry.text
                        }
                    }
                }
            }
        }
        foreach ($root in $AllTreeViewNodes) {
            # This loop will select All Endpoints in a Category
            foreach ($Category in $root.Nodes) {
                if ($Category.Checked) {
                    foreach ($Entry in $Category.Nodes) {
                        $script:ComputerList += $Entry.text
                    }
                }
            }
            # This loop will check for entries that are checked
            foreach ($Category in $root.Nodes) {
                foreach ($Entry in $Category.nodes) {
                    $script:ComputerListAll += $Entry.Text
                    if ($Entry.Checked) { $script:ComputerList += $Entry.text }
                }
            }
        }
        # This will dedup the ComputerList, though there is unlikely multiple computers of the same name
        $script:ComputerList = $script:ComputerList | Sort-Object -Unique
        $script:ComputerListAll = $script:ComputerListAll | Sort-Object -Unique
    }
    else {
        if ($script:ComputerListSearch.Checked) {
            foreach ($root in $AllTreeViewNodes) {
                if ($root.text -imatch "Search Results") {
                    foreach ($Category in $root.Nodes) {
                        foreach ($Entry in $Category.nodes) {
                            foreach ($Metadata in $Entry.nodes) {
                                if ($Metadata.Name -eq 'IPv4Address') {
                                    $script:ComputerList += $Metadata.text
                                }
                            }
                        }
                    }
                }
            }
        }
        if ($script:TreeNodeComputerList.Checked) {
            foreach ($root in $AllTreeViewNodes) {
                if ($root.text -imatch "All Endpoints") {
                    foreach ($Category in $root.Nodes) {
                        foreach ($Entry in $Category.nodes) {
                            foreach ($Metadata in $Entry.nodes) {
                                if ($Metadata.Name -eq 'IPv4Address') {
                                    $script:ComputerList += $Metadata.text
                                }
                            }
                        }
                    }
                }
            }
        }
        foreach ($root in $AllTreeViewNodes) {
            # This loop will select All Endpoints in a Category
            foreach ($Category in $root.Nodes) {
                if ($Category.Checked) {
                    foreach ($Entry in $Category.Nodes) {
                        foreach ($Metadata in $Entry.nodes) {
                            if ($Metadata.Name -eq 'IPv4Address') {
                                $script:ComputerList += $Metadata.text
                            }
                        }
                    }
                }
            }
            # This loop will check for entries that are checked
            foreach ($Category in $root.Nodes) {
                foreach ($Entry in $Category.nodes) {
                    if ($Entry.Checked) { 
                        foreach ($Metadata in $Entry.nodes) {
                            if ($Metadata.Name -eq 'IPv4Address') {
                                $script:ComputerList += $Metadata.text
                            }
                        }
                    }
                }
            }
        }
        # This will dedup the ComputerList, though there is unlikely multiple computers of the same name
        $script:ComputerList = $script:ComputerList | Sort-Object -Unique            
    }
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUbgzuPYoQW9lZy0v1nok4ome4
# CPmgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUYeezqYC/UT6Ug0Y04+IDbOdHuG4wDQYJKoZI
# hvcNAQEBBQAEggEAkEsTgOnwtoYpBC+6/8yIbrQP6tDrkzjjMJJL2Qchpzyv1d7y
# hghj836HsCF6nm0cflsBclB6PvORzsgCy0ZXA5ljKBIOTfDmSANir/j2mpvbVtFG
# NWwOTSY3Fupf7nbvWTplMUeK724cJDRP2q/kg/m0jRabZc+B8qj9yKI0V7CIhC86
# M/Whk6GW9BmHKjSCc8EijkRMTGx6LcYNIpdWBOcavYD005dPAKZxl/xmM3l+DrNZ
# amdAYvDQriAycpFRtww0cWX4xvSh0P754UABII8uiS4cldFbNlrgiBp4jgJugkg3
# vBH60pjwPIvpUOxJNZWbvtziug9x+7t1K10RQw==
# SIG # End signature block
