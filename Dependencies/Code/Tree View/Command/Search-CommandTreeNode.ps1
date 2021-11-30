<#
    .Description
    This function is used to search through the command treeview for matches.
    Results are displayed within the Search treeview with a new sub-treenode labeled after the search entry.
#>
function Search-CommandTreeNode {
    [cmdletbinding()]
    param(
        [string[]]$CommandSearchInput
    )

    [System.Windows.Forms.TreeNodeCollection]$AllCommandsNode = $script:CommandsTreeView.Nodes

    # Checks if the search node already exists
    $SearchNode = $false
    foreach ($root in $AllCommandsNode) {
        if ($root.text -imatch 'Search Results') { $SearchNode = $true }
    }
    if ($SearchNode -eq $false) { $script:CommandsTreeView.Nodes.Add($script:TreeNodeCommandSearch) }


    # Sets the value of $CommandSearchText from that of the command line line parameter -CommandSearch
    if ($CommandSearchInput) {
        # Conducts the search, if something is found it will add it to the treeview
        # Will not produce multiple results if the host triggers in more than one field

        $SearchFound = @()
        foreach ($CommandSearchText in $CommandSearchInput) {
            Foreach($Command in $script:AllCommands) {
                if (($SearchFound -inotcontains $Command) -and (
                    ($Command.Name -imatch $CommandSearchText) -or
                    ($Command.Type -imatch $CommandSearchText) -or
                    ($Command.Description -imatch $CommandSearchText))) {


                    if ($Command.Command_WinRM_Script) {
                        Add-NodeCommand -RootNode $script:TreeNodeCommandSearch -Category $($CommandSearchText) -Entry "(WinRM) Script -- $($Command.Name)" -ToolTip $Command.Command_WinRM_Script
                        $SearchFound += $Command
                    }
                    if ($Command.Command_WinRM_PoSh)   {
                        Add-NodeCommand -RootNode $script:TreeNodeCommandSearch -Category $($CommandSearchText) -Entry "(WinRM) PoSh -- $($Command.Name)" -ToolTip $Command.Command_WinRM_PoSh
                        $SearchFound += $Command
                    }
                    if ($Command.Command_WinRM_WMI)    {
                        Add-NodeCommand -RootNode $script:TreeNodeCommandSearch -Category $($CommandSearchText) -Entry "(WinRM) WMI -- $($Command.Name)" -ToolTip $Command.Command_WinRM_WMI
                        $SearchFound += $Command
                    }
                    #if ($Command.Command_WinRM_CMD)    {
                    #    Add-NodeCommand -RootNode $script:TreeNodeCommandSearch -Category $($CommandSearchText) -Entry "(WinRM) CMD -- $($Command.Name)" -ToolTip $Command.Command_WinRM_CMD
                    #    $SearchFound += $Command
                    #}



                    #if ($Command.Command_RPC_PoSh)     {
                    #    Add-NodeCommand -RootNode $script:TreeNodeCommandSearch -Category $($CommandSearchText) -Entry "(RPC) PoSh -- $($Command.Name)" -ToolTip $Command.Command_RPC_PoSh
                    #    $SearchFound += $Command
                    #}
                    if ($Command.Command_RPC_WMI)          {
                        Add-NodeCommand -RootNode $script:TreeNodeCommandSearch -Category $($CommandSearchText) -Entry "(RPC) WMI -- $($Command.Name)" -ToolTip $Command.Command_RPC_WMI
                        $SearchFound += $Command
                    }
                    #if ($Command.Command_RPC_CMD)     {
                    #    Add-NodeCommand -RootNode $script:TreeNodeCommandSearch -Category $($CommandSearchText) -Entry "(RPC) CMD -- $($Command.Name)" -ToolTip $Command.Command_RPC_CMD
                    #    $SearchFound += $Command
                    #}




                    if ($Command.Command_SMB_PoSh)    {
                        Add-NodeCommand -RootNode $script:TreeNodeCommandSearch -Category $($CommandSearchText) -Entry "(SMB) PoSh -- $($Command.Name)" -ToolTip $Command.Command_SMB_PoSh
                        $SearchFound += $Command
                    }
                    if ($Command.Command_SMB_WMI)    {
                        Add-NodeCommand -RootNode $script:TreeNodeCommandSearch -Category $($CommandSearchText) -Entry "(SMB) WMI -- $($Command.Name)" -ToolTip $Command.Command_SMB_WMI
                        $SearchFound += $Command
                    }
                    if ($Command.Command_SMB_CMD)    {
                        Add-NodeCommand -RootNode $script:TreeNodeCommandSearch -Category $($CommandSearchText) -Entry "(SMB) CMD -- $($Command.Name)" -ToolTip $Command.Command_SMB_CMD
                        $SearchFound += $Command
                    }
                }
            }
        }
    }
    # Sets the value of $CommandSearchText from that of the the GUI Textbox
    else {
        $CommandSearchText = $CommandsTreeViewSearchComboBox.Text

        $InformationTabControl.SelectedTab = $Section3ResultsTab

        # Checks if the search has already been conduected
        $SearchCheck = $false
        foreach ($root in $AllCommandsNode) {
            if ($root.text -imatch 'Search Results') {
                foreach ($Category in $root.Nodes) {
                    if ($Category.text -eq $CommandSearchText) { $SearchCheck = $true}
                }
            }
        }
        # Conducts the search, if something is found it will add it to the treeview
        # Will not produce multiple results if the host triggers in more than one field
        $SearchFound = @()
        if ($CommandSearchText -ne "" -and $SearchCheck -eq $false) {
            $script:AllCommands  = $script:AllEndpointCommands
            $script:AllCommands += $script:AllActiveDirectoryCommands

            Foreach($Command in $script:AllCommands) {
                if (($SearchFound -inotcontains $Command) -and (
                    ($Command.Name -imatch $CommandSearchText) -or
                    ($Command.Type -imatch $CommandSearchText) -or
                    ($Command.Description -imatch $CommandSearchText))) {


                    if ($Command.Command_WinRM_Script) {
                        Add-NodeCommand -RootNode $script:TreeNodeCommandSearch -Category $($CommandSearchText) -Entry "(WinRM) Script -- $($Command.Name)" -ToolTip $Command.Command_WinRM_Script
                        $SearchFound += $Command
                    }
                    if ($Command.Command_WinRM_PoSh)   {
                        Add-NodeCommand -RootNode $script:TreeNodeCommandSearch -Category $($CommandSearchText) -Entry "(WinRM) PoSh -- $($Command.Name)" -ToolTip $Command.Command_WinRM_PoSh
                        $SearchFound += $Command
                    }
                    if ($Command.Command_WinRM_WMI)    {
                        Add-NodeCommand -RootNode $script:TreeNodeCommandSearch -Category $($CommandSearchText) -Entry "(WinRM) WMI -- $($Command.Name)" -ToolTip $Command.Command_WinRM_WMI
                        $SearchFound += $Command
                    }
                    #if ($Command.Command_WinRM_CMD)    {
                    #    Add-NodeCommand -RootNode $script:TreeNodeCommandSearch -Category $($CommandSearchText) -Entry "(WinRM) CMD -- $($Command.Name)" -ToolTip $Command.Command_WinRM_CMD
                    #    $SearchFound += $Command
                    #}



                    #if ($Command.Command_RPC_PoSh)     {
                    #    Add-NodeCommand -RootNode $script:TreeNodeCommandSearch -Category $($CommandSearchText) -Entry "(RPC) PoSh -- $($Command.Name)" -ToolTip $Command.Command_RPC_PoSh
                    #    $SearchFound += $Command
                    #}
                    if ($Command.Command_RPC_WMI)          {
                        Add-NodeCommand -RootNode $script:TreeNodeCommandSearch -Category $($CommandSearchText) -Entry "(RPC) WMI -- $($Command.Name)" -ToolTip $Command.Command_RPC_WMI
                        $SearchFound += $Command
                    }
                    #if ($Command.Command_RPC_CMD)     {
                    #    Add-NodeCommand -RootNode $script:TreeNodeCommandSearch -Category $($CommandSearchText) -Entry "(RPC) CMD -- $($Command.Name)" -ToolTip $Command.Command_RPC_CMD
                    #    $SearchFound += $Command
                    #}



                    if ($Command.Command_SMB_PoSh)    {
                        Add-NodeCommand -RootNode $script:TreeNodeCommandSearch -Category $($CommandSearchText) -Entry "(SMB) PoSh -- $($Command.Name)" -ToolTip $Command.Command_SMB_PoSh
                        $SearchFound += $Command
                    }
                    if ($Command.Command_SMB_WMI)    {
                        Add-NodeCommand -RootNode $script:TreeNodeCommandSearch -Category $($CommandSearchText) -Entry "(SMB) WMI -- $($Command.Name)" -ToolTip $Command.Command_SMB_WMI
                        $SearchFound += $Command
                    }
                    if ($Command.Command_SMB_CMD)    {
                        Add-NodeCommand -RootNode $script:TreeNodeCommandSearch -Category $($CommandSearchText) -Entry "(SMB) CMD -- $($Command.Name)" -ToolTip $Command.Command_SMB_CMD
                        $SearchFound += $Command
                    }



                }
            }
        }

        # Expands the search results
        [System.Windows.Forms.TreeNodeCollection]$AllCommandsNode = $script:CommandsTreeView.Nodes
        foreach ($root in $AllCommandsNode) {
            if ($root.text -match 'Search Results'){
                $root.Collapse()
                $root.Expand()
                foreach ($Category in $root.Nodes) {
                    if ($CommandSearchText -in $Category.text) {
                        $Category.EnsureVisible()
                        $Category.Expand()
                    }
                    else {
                        $Category.Collapse()
                    }
                }
            }
        }

        $CommandSearchText = ""









    }
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU8nTHsBdmfVjWePsdwp/uo0xM
# h0igggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU/Y+Wq6njzATbOAF1x+ALFanFYVIwDQYJKoZI
# hvcNAQEBBQAEggEAWeRlWyrmxMH7p1JlzM5QUqmOAediSsbZ0x1mmOsKsTuUZCa4
# 4QT4ROjuO62vu1fLO2lD4G+utg4/GwOBtoITEyGEhBdJ7uCGw/a80wINbbi9wPs4
# w8F1+uoMT3MB3l8g4et127ULTWRgwWMgWe/nIhP8UMiNv6bTUBo8ceZ+FTckAQCx
# 4ZkpynzctIGEjH/TftC0DWbXksimGc+7CMCGHM8nFPkjwFEV2Go5x7EoSbbUlfTi
# jMlFMV96hZGjuSGxhIONnXCrBHF0SGYfJcduI66brdsE0rHEbYk+IOi4aoraHK/O
# HZs+K+/ViAfkt18yOICvChFN+h1TKKapp1ptxw==
# SIG # End signature block
