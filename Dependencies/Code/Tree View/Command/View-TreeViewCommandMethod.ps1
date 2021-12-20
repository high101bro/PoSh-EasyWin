Function View-TreeViewCommandMethod {
    <#
        .Description
        This functions populates the command treeview under the Method view mode.
        It takes the nested different types of commmands within the main command object and places
        them within their respective protocol/command type node

        Related Function:
            View-TreeViewCommandQuery
            MonitorJobScriptBlock
    #>

    if ($script:ComputerListPivotExecutionCheckbox.checked -eq $false) {
        # Adds Endpoint Command nodes
        Foreach( $Command in $script:AllEndpointCommands ) {
            if ($CommandsViewFilterComboBox.text -match 'WinRM' -or $CommandsViewFilterComboBox.text -match 'All') {
                if ($Command.Command_WinRM_Script) { Add-TreeViewCommand -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-10}{1}" -f "[WinRM]", "PowerShell Scripts")                        -Entry "(WinRM) Script -- $($Command.Name)" -ToolTip $Command.Command_WinRM_Script }
                if ($Command.Command_WinRM_PoSh)   { Add-TreeViewCommand -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-10}{1}" -f "[WinRM]", "PowerShell Cmdlets")                        -Entry "(WinRM) PoSh -- $($Command.Name)"   -ToolTip $Command.Command_WinRM_PoSh }
                if ($Command.Command_WinRM_WMI)    { Add-TreeViewCommand -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-10}{1}" -f "[WinRM]", "Windows Management Instrumentation")        -Entry "(WinRM) WMI -- $($Command.Name)"    -ToolTip $Command.Command_WinRM_WMI }
                #if ($Command.Command_WinRM_Cmd)    { Add-TreeViewCommand -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-10}{1}" -f "[WinRM]", "Native Windows Command")                   -Entry "(WinRM) CMD -- $($Command.Name)"    -ToolTip $Command.Command_WinRM_CMD }    
            }
            if ($CommandsViewFilterComboBox.text -match 'RPC' -or $CommandsViewFilterComboBox.text -match 'All') {
                #if ($Command.Command_RPC_PoSh)     { Add-TreeViewCommand -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-13}{1}" -f "[RPC]", "PowerShell Cmdlets")                         -Entry "(RPC) PoSh -- $($Command.Name)"     -ToolTip $Command.Command_RPC_PoSh }
                if ($Command.Command_RPC_WMI)      { Add-TreeViewCommand -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-13}{1}" -f "[RPC]", "Windows Management Instrumentation")          -Entry "(RPC) WMI -- $($Command.Name)"      -ToolTip $Command.Command_RPC_WMI }

                # Not included in the treeview generation as the native Windows CMDs either don't natively support remoting or have non-standard switches/parameters
                #if ($Command.Command_RPC_CMD)      { Add-TreeViewCommand -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-13}{1}" -f "[RPC]", "Native Windows Command")                     -Entry "(RPC) CMD -- $($Command.Name)"      -ToolTip $Command.Command_RPC_CMD }
            }
            if ($CommandsViewFilterComboBox.text -match 'SMB' -or $CommandsViewFilterComboBox.text -match 'All') {
                if ($Command.Command_SMB_PoSh)     { Add-TreeViewCommand -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-13}{1}" -f "[SMB]", "PowerShell Cmdlets")                          -Entry "(SMB) PoSh -- $($Command.Name)"     -ToolTip $Command.Command_SMB_PoSh }
                if ($Command.Command_SMB_WMI)      { Add-TreeViewCommand -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-13}{1}" -f "[SMB]", "Windows Management Instrumentation")          -Entry "(SMB) WMI -- $($Command.Name)"      -ToolTip $Command.Command_SMB_WMI }
                if ($Command.Command_SMB_CMD)      { Add-TreeViewCommand -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-13}{1}" -f "[SMB]", "Native Windows Command")                      -Entry "(SMB) CMD -- $($Command.Name)"      -ToolTip $Command.Command_SMB_CMD }    
            }
            if ($CommandsViewFilterComboBox.text -match 'SSH' -or $CommandsViewFilterComboBox.text -match 'All') {
                if ($Command.Command_Linux)        { Add-TreeViewCommand -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-13}{1}" -f "[SSH]", "Linux Commands")                              -Entry "(SSH) Linux -- $($Command.Name)" -ToolTip $Command.Command_Linux }
            }
        }
        # Adds Active Directory Command nodes
        Foreach($Command in $script:AllActiveDirectoryCommands) {
            if ($CommandsViewFilterComboBox.text -match 'WinRM' -or $CommandsViewFilterComboBox.text -match 'All') {
                if ($Command.Command_WinRM_Script) { Add-TreeViewCommand -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-10}{1}" -f "[WinRM]", "PowerShell Scripts")                 -Entry "(WinRM) Script -- $($Command.Name)" -ToolTip $Command.Command_WinRM_Script }
                if ($Command.Command_WinRM_PoSh)   { Add-TreeViewCommand -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-10}{1}" -f "[WinRM]", "PowerShell Cmdlets")                 -Entry "(WinRM) PoSh -- $($Command.Name)"   -ToolTip $Command.Command_WinRM_PoSh }
                if ($Command.Command_WinRM_WMI)    { Add-TreeViewCommand -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-10}{1}" -f "[WinRM]", "Windows Management Instrumentation") -Entry "(WinRM) WMI -- $($Command.Name)"    -ToolTip $Command.Command_WinRM_WMI }
                #if ($Command.Command_WinRM_Cmd)    { Add-TreeViewCommand -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-10}{1}" -f "[WinRM]", "Native Windows Command")            -Entry "(WinRM) CMD -- $($Command.Name)"    -ToolTip $Command.Command_WinRM_CMD }    
            }
            if ($CommandsViewFilterComboBox.text -match 'RPC' -or $CommandsViewFilterComboBox.text -match 'All') {
                #if ($Command.Command_RPC_PoSh)     { Add-TreeViewCommand -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-13}{1}" -f "[RPC]", "PowerShell Cmdlets")                  -Entry "(RPC) PoSh -- $($Command.Name)"     -ToolTip $Command.Command_RPC_PoSh }
                if ($Command.Command_RPC_WMI)      { Add-TreeViewCommand -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-13}{1}" -f "[RPC]", "Windows Management Instrumentation")   -Entry "(RPC) WMI -- $($Command.Name)"      -ToolTip $Command.Command_RPC_WMI }

                # Not included in the treeview generation as the native Windows CMDs either don't natively support remoting or have non-standard switches/parameters
                #if ($Command.Command_RPC_CMD)      { Add-TreeViewCommand -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-13}{1}" -f "[RPC]", "Native Windows Command")              -Entry "(RPC) CMD -- $($Command.Name)"      -ToolTip $Command.Command_RPC_CMD }
            }
            if ($CommandsViewFilterComboBox.text -match 'SMB' -or $CommandsViewFilterComboBox.text -match 'All') {
                if ($Command.Command_SMB_PoSh)     { Add-TreeViewCommand -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-13}{1}" -f "[SMB]", "PowerShell Cmdlets")                   -Entry "(SMB) PoSh -- $($Command.Name)"     -ToolTip $Command.Command_SMB_PoSh }
                if ($Command.Command_SMB_WMI)      { Add-TreeViewCommand -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-13}{1}" -f "[SMB]", "Windows Management Instrumentation")   -Entry "(SMB) WMI -- $($Command.Name)"      -ToolTip $Command.Command_SMB_WMI }
                if ($Command.Command_SMB_CMD)      { Add-TreeViewCommand -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-13}{1}" -f "[SMB]", "Native Windows Command")               -Entry "(SMB) CMD -- $($Command.Name)"      -ToolTip $Command.Command_SMB_CMD }    
            }
            if ($CommandsViewFilterComboBox.text -match 'SSH' -or $CommandsViewFilterComboBox.text -match 'All') {
                $null
            }
        }
    }
    elseif ($script:ComputerListPivotExecutionCheckbox.checked -eq $true){
        Foreach( $Command in $script:AllEndpointCommands ) {
            if ($Command.Command_WinRM_PoSh)   { Add-TreeViewCommand -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-10}{1}" -f "[WinRM]", "PowerShell Cmdlets")                        -Entry "(WinRM) PoSh -- $($Command.Name)"   -ToolTip $Command.Command_WinRM_PoSh }
            if ($Command.Command_WinRM_WMI)    { Add-TreeViewCommand -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-10}{1}" -f "[WinRM]", "Windows Management Instrumentation")        -Entry "(WinRM) WMI -- $($Command.Name)"    -ToolTip $Command.Command_WinRM_WMI }
        }
        Foreach($Command in $script:AllActiveDirectoryCommands) {
            if ($Command.Command_WinRM_PoSh)   { Add-TreeViewCommand -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-10}{1}" -f "[WinRM]", "PowerShell Cmdlets")                 -Entry "(WinRM) PoSh -- $($Command.Name)"   -ToolTip $Command.Command_WinRM_PoSh }
            if ($Command.Command_WinRM_WMI)    { Add-TreeViewCommand -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-10}{1}" -f "[WinRM]", "Windows Management Instrumentation") -Entry "(WinRM) WMI -- $($Command.Name)"    -ToolTip $Command.Command_WinRM_WMI }
        }
    }

    # Adds the selected commands to the Custom Group Commands Nodes
    foreach ($Command in $script:CustomGroupCommandsList) { 
        Add-TreeViewCommand -RootNode $script:TreeNodeCustomGroupCommands -Category "$($Command.CategoryName)" -Entry "$($Command.Name)" -ToolTip "$($Command.Command)"
    }
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUXLO7s5JETDYCpOyWJhDWju2h
# bjWgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUtCI5qu3b/mHHPJe+Qkj6+8EdcaUwDQYJKoZI
# hvcNAQEBBQAEggEAOhZIDJAvKK26r60F2jNJ7mZi10+Y8BXqgIXrDcTakxcyuvPb
# Nb+9MeFzMYBmcAxwgL/mlnCqqhgy0nw2OgblLyvxwNM8bzGT9daHzogwyHGYMI2R
# Ol2Ie00B4DejadTDUdhyRSdZymo5KiASQaKKtVZ/Sa21rYLshWdP/SUUZtuYX0Nc
# ZvDW4f+379SxaFTeM9fDgPO9o4KY7MrLiKnXLJWL1ofMiS6e7ggmIhT9PR8gT2Du
# 4/87/NDWTtQ4XjfHSIbCxcK8bx8f7x+yK8ejB6TH44ZBG59udrr3ndBI/t/i5Rg3
# DFtY6+p/eWLyA0Uug/0KeRwXhl2+wNy+JO3GQQ==
# SIG # End signature block
