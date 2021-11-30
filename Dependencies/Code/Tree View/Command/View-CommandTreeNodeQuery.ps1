Function View-CommandTreeNodeQuery {
    <#
        .Description
        This functions populates the command treeview under the Query view mode.
        It takes the nested different types of commmands within the main command object and places
        them within their respective protocol/command type node

        Related Function:
            View-CommandTreeNodeMethod
            MonitorJobScriptBlock
    #>

    # Adds Endpoint Command nodes
    Foreach($Command in $script:AllEndpointCommands) {        
        if ($Command.Command_WinRM_Script) { Add-NodeCommand -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(WinRM) Script -- $($Command.Name)" -ToolTip $Command.Command_WinRM_Script }
        if ($Command.Command_WinRM_PoSh)   { Add-NodeCommand -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(WinRM) PoSh -- $($Command.Name)"   -ToolTip $Command.Command_WinRM_PoSh }
        if ($Command.Command_WinRM_WMI)    { Add-NodeCommand -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(WinRM) WMI -- $($Command.Name)"    -ToolTip $Command.Command_WinRM_WMI }
        #if ($Command.Command_WinRM_CMD)    { Add-NodeCommand -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(WinRM) CMD -- $($Command.Name)"    -ToolTip $Command.Command_WinRM_CMD }

        #if ($Command.Command_RPC_PoSh)     { Add-NodeCommand -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(RPC) PoSh -- $($Command.Name)"     -ToolTip $Command.Command_RPC_PoSh }
        if ($Command.Command_RPC_WMI)      { Add-NodeCommand -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(RPC) WMI -- $($Command.Name)"      -ToolTip $Command.Command_RPC_WMI }
        # Not included in the treeview generation as the native Windows CMDs either don't natively support remoting or have non-standard switches/parameters
        #if ($Command.Command_RPC_CMD)      { Add-NodeCommand -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(RPC) CMD -- $($Command.Name)"      -ToolTip $Command.Command_RPC_CMD }

        if ($Command.Command_SMB_PoSh)     { Add-NodeCommand -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(SMB) PoSh -- $($Command.Name)"     -ToolTip $Command.Command_SMB_PoSh }
        if ($Command.Command_SMB_WMI)      { Add-NodeCommand -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(SMB) WMI -- $($Command.Name)"      -ToolTip $Command.Command_SMB_WMI }
        if ($Command.Command_SMB_CMD)      { Add-NodeCommand -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(SMB) CMD -- $($Command.Name)"      -ToolTip $Command.Command_SMB_CMD }

        if ($Command.Command_Linux) { Add-NodeCommand -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(SSH) Linux -- $($Command.Name)" -ToolTip $Command.Command_Linux }
    }
    # Adds Active Directory Command nodes
    Foreach($Command in $script:AllActiveDirectoryCommands) {
        if ($Command.Command_WinRM_Script) { Add-NodeCommand -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(WinRM) Script -- $($Command.Name)" -ToolTip $Command.Command_WinRM_Script }
        if ($Command.Command_WinRM_PoSh)   { Add-NodeCommand -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(WinRM) PoSh -- $($Command.Name)"   -ToolTip $Command.Command_WinRM_PoSh }
        if ($Command.Command_WinRM_WMI)    { Add-NodeCommand -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(WinRM) WMI -- $($Command.Name)"    -ToolTip $Command.Command_WinRM_WMI }
        #if ($Command.Command_WinRM_CMD)    { Add-NodeCommand -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(WinRM) CMD -- $($Command.Name)"    -ToolTip $Command.Command_WinRM_CMD }

        #if ($Command.Command_RPC_PoSh)     { Add-NodeCommand -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(RPC) PoSh -- $($Command.Name)"     -ToolTip $Command.Command_RPC_PoSh }
        if ($Command.Command_RPC_WMI)      { Add-NodeCommand -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(RPC) WMI -- $($Command.Name)"      -ToolTip $Command.Command_RPC_WMI }
        # Not included in the treeview generation as the native Windows CMDs either don't natively support remoting or have non-standard switches/parameters
        #if ($Command.Command_RPC_CMD)      { Add-NodeCommand -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(RPC) CMD -- $($Command.Name)"      -ToolTip $Command.Command_RPC_CMD }

        if ($Command.Command_SMB_PoSh)     { Add-NodeCommand -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(SMB) PoSh -- $($Command.Name)"     -ToolTip $Command.Command_SMB_PoSh }
        if ($Command.Command_SMB_WMI)      { Add-NodeCommand -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(SMB) WMI -- $($Command.Name)"      -ToolTip $Command.Command_SMB_WMI }
        if ($Command.Command_SMB_CMD)      { Add-NodeCommand -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(SMB) CMD -- $($Command.Name)"      -ToolTip $Command.Command_SMB_CMD }
    }
    # Adds the selected commands to the Custom Group Commands Nodes
    foreach ($Command in $script:CustomGroupCommandsList) {
        Add-NodeCommand -RootNode $script:TreeNodeCustomGroupCommands -Category "$($Command.CategoryName)" -Entry "$($Command.Name)" -ToolTip "$($Command.Command)"
    }
}


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUAjQKx+12tLHWZRDhuGwwri5y
# gqCgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUoIwPlSWyzHxGEt0AaOmtuEOIGp0wDQYJKoZI
# hvcNAQEBBQAEggEArcij24Kh7Hqlskc2fw/L7fDeO1coCq3tnNO0NG5QW3besY6E
# oNQlllz9rFVw/vJ5LT0ntsFgkGIjEI6LfBKAB/04pMzl43JjuWhKaQolXAouIvX6
# j++oxvKLtYdOt/U3sUAmFOuXFfMz/d2ZCWQwRqDtgx1VjIn8YV4UgE3HhnGO/Q0m
# ZZOvbrwMZHsJ+uTLiVhhxts5oVhQBq0t8KQGuSP9dQp4825UyoOgDW1KMq3/WM7X
# cOmwnqgtSECgJdWUGz6Gqhb8oeKkPtHAxO3dxolDxSBXrhTJqvceO2QRnbLabfPm
# SUuj2MGGHVynuugcz3cAsKWbhjlztt7QQqZPgw==
# SIG # End signature block
