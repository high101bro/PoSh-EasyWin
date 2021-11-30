$CommandsViewCommandNamesRadioButtonAdd_Click = {
    #$StatusListBox.Items.Clear()
    #$StatusListBox.Items.Add("Display And Group By:  Query")

    # This variable stores data on checked checkboxes, so boxes checked remain among different views
    $script:CommandsCheckedBoxesSelected = @()

    [System.Windows.Forms.TreeNodeCollection]$AllCommandsNode = $script:CommandsTreeView.Nodes
    foreach ($root in $AllCommandsNode) {
        foreach ($Category in $root.Nodes) {
            foreach ($Entry in $Category.nodes) {
                if ($Entry.Checked) {
                    $script:CommandsCheckedBoxesSelected += $Entry.Text
                }
            }
        }
    }
    $script:CommandsTreeView.Nodes.Clear()
    Initialize-CommandTreeNodes
    View-CommandTreeNodeQuery
    Update-TreeNodeCommandState
}

$CommandsViewCommandNamesRadioButtonAdd_MouseHover = {
    Show-ToolTip -Title "Display by Command Grouping" -Icon "Info" -Message @"
+  Displays commands grouped by queries
+  All commands executed against each host are logged
"@
}




# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUNDEzD/rsOi5FucbXYaQk9cK1
# p02gggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUGJ9j8Tkseon36w6BsaAo4/98zwAwDQYJKoZI
# hvcNAQEBBQAEggEAq45vMLlJEoiURU09FZsbxTpJVMaM6boVli7gvxDn8BhnZ/6h
# jy8BZ+Gd+WXdOGGU66D9H5PIoHIsGOkqZ7Ltkk6+Yopp9KMnbD6TJkg+gAqi627U
# PBDh1dOYhnko97+fRB9kX8UrpAkbz5h+madM6W5Oi1MYIdjgvHpmplQQkZhjDzgA
# u2Xog1j2wsS3oh5wOEnktpuERPtiDK/yurHeZgVGgF5OAZidxDK+7k8y9l4ywXK5
# S4SRfyeRpwwrQIUM2WacqzV122/dCKcWOrYkKV3XTT03dcplts4M/kiulgIWhREs
# rP8f058h+9JGPIHvTAvSURqiEq3w3N07SZ8nWw==
# SIG # End signature block
