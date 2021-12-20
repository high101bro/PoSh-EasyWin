Function View-TreeViewCommandQuery {
    <#
        .Description
        This functions populates the command treeview under the Query view mode.
        It takes the nested different types of commmands within the main command object and places
        them within their respective protocol/command type node

        Related Function:
            View-TreeViewCommandMethod
            MonitorJobScriptBlock
    #>

    # Adds Endpoint Command nodes
    Foreach($Command in $script:AllEndpointCommands) {        
        if ($Command.Command_WinRM_Script) { Add-TreeViewCommand -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(WinRM) Script -- $($Command.Name)" -ToolTip $Command.Command_WinRM_Script }
        if ($Command.Command_WinRM_PoSh)   { Add-TreeViewCommand -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(WinRM) PoSh -- $($Command.Name)"   -ToolTip $Command.Command_WinRM_PoSh }
        if ($Command.Command_WinRM_WMI)    { Add-TreeViewCommand -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(WinRM) WMI -- $($Command.Name)"    -ToolTip $Command.Command_WinRM_WMI }
        #if ($Command.Command_WinRM_CMD)    { Add-TreeViewCommand -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(WinRM) CMD -- $($Command.Name)"    -ToolTip $Command.Command_WinRM_CMD }

        #if ($Command.Command_RPC_PoSh)     { Add-TreeViewCommand -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(RPC) PoSh -- $($Command.Name)"     -ToolTip $Command.Command_RPC_PoSh }
        if ($Command.Command_RPC_WMI)      { Add-TreeViewCommand -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(RPC) WMI -- $($Command.Name)"      -ToolTip $Command.Command_RPC_WMI }
        # Not included in the treeview generation as the native Windows CMDs either don't natively support remoting or have non-standard switches/parameters
        #if ($Command.Command_RPC_CMD)      { Add-TreeViewCommand -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(RPC) CMD -- $($Command.Name)"      -ToolTip $Command.Command_RPC_CMD }

        if ($Command.Command_SMB_PoSh)     { Add-TreeViewCommand -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(SMB) PoSh -- $($Command.Name)"     -ToolTip $Command.Command_SMB_PoSh }
        if ($Command.Command_SMB_WMI)      { Add-TreeViewCommand -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(SMB) WMI -- $($Command.Name)"      -ToolTip $Command.Command_SMB_WMI }
        if ($Command.Command_SMB_CMD)      { Add-TreeViewCommand -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(SMB) CMD -- $($Command.Name)"      -ToolTip $Command.Command_SMB_CMD }

        if ($Command.Command_Linux) { Add-TreeViewCommand -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(SSH) Linux -- $($Command.Name)" -ToolTip $Command.Command_Linux }
    }
    # Adds Active Directory Command nodes
    Foreach($Command in $script:AllActiveDirectoryCommands) {
        if ($Command.Command_WinRM_Script) { Add-TreeViewCommand -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(WinRM) Script -- $($Command.Name)" -ToolTip $Command.Command_WinRM_Script }
        if ($Command.Command_WinRM_PoSh)   { Add-TreeViewCommand -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(WinRM) PoSh -- $($Command.Name)"   -ToolTip $Command.Command_WinRM_PoSh }
        if ($Command.Command_WinRM_WMI)    { Add-TreeViewCommand -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(WinRM) WMI -- $($Command.Name)"    -ToolTip $Command.Command_WinRM_WMI }
        #if ($Command.Command_WinRM_CMD)    { Add-TreeViewCommand -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(WinRM) CMD -- $($Command.Name)"    -ToolTip $Command.Command_WinRM_CMD }

        #if ($Command.Command_RPC_PoSh)     { Add-TreeViewCommand -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(RPC) PoSh -- $($Command.Name)"     -ToolTip $Command.Command_RPC_PoSh }
        if ($Command.Command_RPC_WMI)      { Add-TreeViewCommand -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(RPC) WMI -- $($Command.Name)"      -ToolTip $Command.Command_RPC_WMI }
        # Not included in the treeview generation as the native Windows CMDs either don't natively support remoting or have non-standard switches/parameters
        #if ($Command.Command_RPC_CMD)      { Add-TreeViewCommand -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(RPC) CMD -- $($Command.Name)"      -ToolTip $Command.Command_RPC_CMD }

        if ($Command.Command_SMB_PoSh)     { Add-TreeViewCommand -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(SMB) PoSh -- $($Command.Name)"     -ToolTip $Command.Command_SMB_PoSh }
        if ($Command.Command_SMB_WMI)      { Add-TreeViewCommand -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(SMB) WMI -- $($Command.Name)"      -ToolTip $Command.Command_SMB_WMI }
        if ($Command.Command_SMB_CMD)      { Add-TreeViewCommand -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(SMB) CMD -- $($Command.Name)"      -ToolTip $Command.Command_SMB_CMD }
    }
    # Adds the selected commands to the Custom Group Commands Nodes
    foreach ($Command in $script:CustomGroupCommandsList) {
        Add-TreeViewCommand -RootNode $script:TreeNodeCustomGroupCommands -Category "$($Command.CategoryName)" -Entry "$($Command.Name)" -ToolTip "$($Command.Command)"
    }
}


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUAjQKx+12tLHWZRDhuGwwri5y
# gqCgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUoIwPlSWyzHxGEt0AaOmtuEOIGp0wDQYJKoZI
# hvcNAQEBBQAEggEAojc0++2My1HTj4dF8/5WIen0fE0I4rnLZbcg8nqjcH2DTpJh
# 9gjEQpcW7HsQPapBPl5FmDQQj69RVxYuLIsQnBTrWv4lQkAM7fEsUd6zyRYpTX+h
# i37dj5ivWlirtvyEPklHOtQ+DJs23ZNORszvN8knCJ6JOfn+9RKZ7LJQZHNsmQE2
# 2tvd+P37MKCqd0qXU3tWSOXqICmv4sy0ukRTSBCfwd2EATFmnLFzUG4eIee3xDMm
# Koz9hbDCbh5pVE7u16sxYI0390FxtKSfGs1EUPsb1nA76ErEy6BWMGIYnyDXGM6t
# eR8B8EfhiGJUbZEZsOnlH3nNHVaYoA7XrcnlGw==
# SIG # End signature block
