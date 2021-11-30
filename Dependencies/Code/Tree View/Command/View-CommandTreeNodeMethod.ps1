Function View-CommandTreeNodeMethod {
    <#
        .Description
        This functions populates the command treeview under the Method view mode.
        It takes the nested different types of commmands within the main command object and places
        them within their respective protocol/command type node

        Related Function:
            View-CommandTreeNodeQuery
            MonitorJobScriptBlock
    #>

    if ($script:ComputerListPivotExecutionCheckbox.checked -eq $false) {
        # Adds Endpoint Command nodes
        Foreach( $Command in $script:AllEndpointCommands ) {
            if ($CommandsViewFilterComboBox.text -match 'WinRM' -or $CommandsViewFilterComboBox.text -match 'All') {
                if ($Command.Command_WinRM_Script) { Add-NodeCommand -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-10}{1}" -f "[WinRM]", "PowerShell Scripts")                        -Entry "(WinRM) Script -- $($Command.Name)" -ToolTip $Command.Command_WinRM_Script }
                if ($Command.Command_WinRM_PoSh)   { Add-NodeCommand -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-10}{1}" -f "[WinRM]", "PowerShell Cmdlets")                        -Entry "(WinRM) PoSh -- $($Command.Name)"   -ToolTip $Command.Command_WinRM_PoSh }
                if ($Command.Command_WinRM_WMI)    { Add-NodeCommand -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-10}{1}" -f "[WinRM]", "Windows Management Instrumentation")        -Entry "(WinRM) WMI -- $($Command.Name)"    -ToolTip $Command.Command_WinRM_WMI }
                #if ($Command.Command_WinRM_Cmd)    { Add-NodeCommand -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-10}{1}" -f "[WinRM]", "Native Windows Command")                   -Entry "(WinRM) CMD -- $($Command.Name)"    -ToolTip $Command.Command_WinRM_CMD }    
            }
            if ($CommandsViewFilterComboBox.text -match 'RPC' -or $CommandsViewFilterComboBox.text -match 'All') {
                #if ($Command.Command_RPC_PoSh)     { Add-NodeCommand -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-13}{1}" -f "[RPC]", "PowerShell Cmdlets")                         -Entry "(RPC) PoSh -- $($Command.Name)"     -ToolTip $Command.Command_RPC_PoSh }
                if ($Command.Command_RPC_WMI)      { Add-NodeCommand -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-13}{1}" -f "[RPC]", "Windows Management Instrumentation")          -Entry "(RPC) WMI -- $($Command.Name)"      -ToolTip $Command.Command_RPC_WMI }

                # Not included in the treeview generation as the native Windows CMDs either don't natively support remoting or have non-standard switches/parameters
                #if ($Command.Command_RPC_CMD)      { Add-NodeCommand -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-13}{1}" -f "[RPC]", "Native Windows Command")                     -Entry "(RPC) CMD -- $($Command.Name)"      -ToolTip $Command.Command_RPC_CMD }
            }
            if ($CommandsViewFilterComboBox.text -match 'SMB' -or $CommandsViewFilterComboBox.text -match 'All') {
                if ($Command.Command_SMB_PoSh)     { Add-NodeCommand -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-13}{1}" -f "[SMB]", "PowerShell Cmdlets")                          -Entry "(SMB) PoSh -- $($Command.Name)"     -ToolTip $Command.Command_SMB_PoSh }
                if ($Command.Command_SMB_WMI)      { Add-NodeCommand -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-13}{1}" -f "[SMB]", "Windows Management Instrumentation")          -Entry "(SMB) WMI -- $($Command.Name)"      -ToolTip $Command.Command_SMB_WMI }
                if ($Command.Command_SMB_CMD)      { Add-NodeCommand -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-13}{1}" -f "[SMB]", "Native Windows Command")                      -Entry "(SMB) CMD -- $($Command.Name)"      -ToolTip $Command.Command_SMB_CMD }    
            }
            if ($CommandsViewFilterComboBox.text -match 'SSH' -or $CommandsViewFilterComboBox.text -match 'All') {
                if ($Command.Command_Linux)        { Add-NodeCommand -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-13}{1}" -f "[SSH]", "Linux Commands")                              -Entry "(SSH) Linux -- $($Command.Name)" -ToolTip $Command.Command_Linux }
            }
        }
        # Adds Active Directory Command nodes
        Foreach($Command in $script:AllActiveDirectoryCommands) {
            if ($CommandsViewFilterComboBox.text -match 'WinRM' -or $CommandsViewFilterComboBox.text -match 'All') {
                if ($Command.Command_WinRM_Script) { Add-NodeCommand -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-10}{1}" -f "[WinRM]", "PowerShell Scripts")                 -Entry "(WinRM) Script -- $($Command.Name)" -ToolTip $Command.Command_WinRM_Script }
                if ($Command.Command_WinRM_PoSh)   { Add-NodeCommand -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-10}{1}" -f "[WinRM]", "PowerShell Cmdlets")                 -Entry "(WinRM) PoSh -- $($Command.Name)"   -ToolTip $Command.Command_WinRM_PoSh }
                if ($Command.Command_WinRM_WMI)    { Add-NodeCommand -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-10}{1}" -f "[WinRM]", "Windows Management Instrumentation") -Entry "(WinRM) WMI -- $($Command.Name)"    -ToolTip $Command.Command_WinRM_WMI }
                #if ($Command.Command_WinRM_Cmd)    { Add-NodeCommand -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-10}{1}" -f "[WinRM]", "Native Windows Command")            -Entry "(WinRM) CMD -- $($Command.Name)"    -ToolTip $Command.Command_WinRM_CMD }    
            }
            if ($CommandsViewFilterComboBox.text -match 'RPC' -or $CommandsViewFilterComboBox.text -match 'All') {
                #if ($Command.Command_RPC_PoSh)     { Add-NodeCommand -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-13}{1}" -f "[RPC]", "PowerShell Cmdlets")                  -Entry "(RPC) PoSh -- $($Command.Name)"     -ToolTip $Command.Command_RPC_PoSh }
                if ($Command.Command_RPC_WMI)      { Add-NodeCommand -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-13}{1}" -f "[RPC]", "Windows Management Instrumentation")   -Entry "(RPC) WMI -- $($Command.Name)"      -ToolTip $Command.Command_RPC_WMI }

                # Not included in the treeview generation as the native Windows CMDs either don't natively support remoting or have non-standard switches/parameters
                #if ($Command.Command_RPC_CMD)      { Add-NodeCommand -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-13}{1}" -f "[RPC]", "Native Windows Command")              -Entry "(RPC) CMD -- $($Command.Name)"      -ToolTip $Command.Command_RPC_CMD }
            }
            if ($CommandsViewFilterComboBox.text -match 'SMB' -or $CommandsViewFilterComboBox.text -match 'All') {
                if ($Command.Command_SMB_PoSh)     { Add-NodeCommand -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-13}{1}" -f "[SMB]", "PowerShell Cmdlets")                   -Entry "(SMB) PoSh -- $($Command.Name)"     -ToolTip $Command.Command_SMB_PoSh }
                if ($Command.Command_SMB_WMI)      { Add-NodeCommand -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-13}{1}" -f "[SMB]", "Windows Management Instrumentation")   -Entry "(SMB) WMI -- $($Command.Name)"      -ToolTip $Command.Command_SMB_WMI }
                if ($Command.Command_SMB_CMD)      { Add-NodeCommand -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-13}{1}" -f "[SMB]", "Native Windows Command")               -Entry "(SMB) CMD -- $($Command.Name)"      -ToolTip $Command.Command_SMB_CMD }    
            }
            if ($CommandsViewFilterComboBox.text -match 'SSH' -or $CommandsViewFilterComboBox.text -match 'All') {
                $null
            }
        }
    }
    elseif ($script:ComputerListPivotExecutionCheckbox.checked -eq $true){
        Foreach( $Command in $script:AllEndpointCommands ) {
            if ($Command.Command_WinRM_PoSh)   { Add-NodeCommand -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-10}{1}" -f "[WinRM]", "PowerShell Cmdlets")                        -Entry "(WinRM) PoSh -- $($Command.Name)"   -ToolTip $Command.Command_WinRM_PoSh }
            if ($Command.Command_WinRM_WMI)    { Add-NodeCommand -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-10}{1}" -f "[WinRM]", "Windows Management Instrumentation")        -Entry "(WinRM) WMI -- $($Command.Name)"    -ToolTip $Command.Command_WinRM_WMI }
        }
        Foreach($Command in $script:AllActiveDirectoryCommands) {
            if ($Command.Command_WinRM_PoSh)   { Add-NodeCommand -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-10}{1}" -f "[WinRM]", "PowerShell Cmdlets")                 -Entry "(WinRM) PoSh -- $($Command.Name)"   -ToolTip $Command.Command_WinRM_PoSh }
            if ($Command.Command_WinRM_WMI)    { Add-NodeCommand -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-10}{1}" -f "[WinRM]", "Windows Management Instrumentation") -Entry "(WinRM) WMI -- $($Command.Name)"    -ToolTip $Command.Command_WinRM_WMI }
        }
    }

    # Adds the selected commands to the Custom Group Commands Nodes
    foreach ($Command in $script:CustomGroupCommandsList) { 
        Add-NodeCommand -RootNode $script:TreeNodeCustomGroupCommands -Category "$($Command.CategoryName)" -Entry "$($Command.Name)" -ToolTip "$($Command.Command)"
    }
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUXLO7s5JETDYCpOyWJhDWju2h
# bjWgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUtCI5qu3b/mHHPJe+Qkj6+8EdcaUwDQYJKoZI
# hvcNAQEBBQAEggEAFWxkiMscyXl1pFQzDmNTPWDyOdfY2IZJFam5TtoKRIS2UVPb
# ETdi60x5cVTcxtd0TTmT28mrx216f7M4QoTKmhqlwoWt4npTt0hopnRku+0uMBot
# cq8iiC+fQAml5f+/qo8V3k3XCHPogIIA8+GfxtpzjW/AOnrANwK2lOcXLL98Ne1t
# aCck5OlYe2mF+td3SpbrjCs+lNqXotCZE9d7FRMBlfDnLfZDH27RjK2hLtCKw3gI
# XTXgUWwAiuznNsIEKCvEuIjVIItK0vNZfwb+DIvtjZjd1fDe5PSqbOOTcyuYY80T
# R6dpRpMZ9ru8vtt60DE0gCs1PUfx8WokiARxMg==
# SIG # End signature block
