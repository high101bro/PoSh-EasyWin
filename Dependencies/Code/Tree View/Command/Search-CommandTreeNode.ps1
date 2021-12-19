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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUojaebNx+2IivoUBNZTNFTVap
# BtCgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUsx7J5WIljbXAJxo3X6gtMiZOdmAwDQYJKoZI
# hvcNAQEBBQAEggEADT+5kgNHqidMpjXFuA6vumBrobOoHoemyTnLxgqK+YUhbIU+
# vtSjmXo4gQQiyHLHai2/cOgHPI7L6ouvhFrpaAX+epQkzTEIWtks9azkfxPOFRlM
# E8xI3BvaOCDM/OuXBAE8FT75joNk/nX4mEYhcYgAhAz9PomFb4RNtV7ffV+/QcfS
# PgoYOHDjXSXfn28acplcczgto05076RbCFjNW23gT9u14X4gzsnRJMXdlkLLDS7H
# pF/ruwM0RDXe20ixgKtW40kzepahvU84vPqYPCwxHYrq7dEiUdZvJZy/B+y55WA0
# xHNv9HZ/zVY0OjmAkL0NP7qw7sSFR9H5yldeAw==
# SIG # End signature block
