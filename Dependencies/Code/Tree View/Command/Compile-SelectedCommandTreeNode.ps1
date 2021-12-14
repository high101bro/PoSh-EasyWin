function Compile-SelectedCommandTreeNode {
    <#
        .Description
        This function compiles the selected treeview comamnds, placing the proper command
        type and protocol into a variable list to be executed.

        Related Functions:
            View-CommandTreeNodeMethod
            View-CommandTreeNodeQuery
            MonitorJobScriptBlock
    #>

    # Commands in the treenode that are selected
    $script:CommandsCheckedBoxesSelected = @()

    [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:CommandsTreeView.Nodes
    #Removed For Testing#$ResultsListBox.Items.Clear()

    # Compiles all the commands treenodes into one object
    $script:AllCommands  = $script:AllEndpointCommands
    $script:AllCommands += $script:AllActiveDirectoryCommands
    $script:AllCommands += $script:UserAddedCommands

    foreach ($root in $AllTreeViewNodes) {
        foreach ($Category in $root.Nodes) {
            if ($CommandsViewProtocolsUsedRadioButton.Checked) {
                foreach ($Entry in $Category.nodes) {
                    # Builds the query that is selected
                    if ($Entry.Checked -and $Entry -match '(WinRM)' -and $Entry -match 'Script') {
                        $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                        $script:CommandsCheckedBoxesSelected += New-Object psobject @{
                            Name           = $Entry.Text
                            Command        = $Command.Command_WinRM_Script
                            ExportFileName = $Command.ExportFileName
                            Type           = "(WinRM) Script"
                        }
                    }
                    elseif ($Entry.Checked -and $Entry -match '(WinRM)' -and $Entry -match 'PoSh') {
                        $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                        $script:CommandsCheckedBoxesSelected += New-Object psobject @{
                            Name           = $Entry.Text
                            Command        = $Command.Command_WinRM_PoSh
                            Properties     = $Command.Properties_PoSh
                            ExportFileName = $Command.ExportFileName
                            Type           = '(WinRM) PoSh'
                        }
                    }
                    elseif ($Entry.Checked -and $Entry -match '(WinRM)' -and $Entry -match 'WMI') {
                        $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                        $script:CommandsCheckedBoxesSelected += New-Object psobject @{
                            Name           = $Entry.Text
                            Command        = $Command.Command_WinRM_WMI
                            Properties     = $Command.Properties_WMI
                            ExportFileName = $Command.ExportFileName
                            Type           = "(WinRM) WMI"
                        }
                    }
                    #elseif ($Entry.Checked -and $Entry -match '(WinRM)' -and $Entry -match 'CMD') {
                    #    $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                    #    $script:CommandsCheckedBoxesSelected += New-Object psobject @{
                    #        Name           = $Entry.Text
                    #        Command        = $Command.Command_WinRM_CMD
                    #        ExportFileName = $Command.ExportFileName
                    #        Type           = "(WinRM) CMD"
                    #    }
                    #}
                    #elseif ($Entry.Checked -and $Entry -match '(RPC)' -and $Entry -match 'PoSh') {
                    #    $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                    #    $script:CommandsCheckedBoxesSelected += New-Object psobject @{
                    #        Name           = $Entry.Text
                    #        Command        = $Command.Command_RPC_PoSh
                    #        Properties     = $Command.Properties_PoSh
                    #        ExportFileName = $Command.ExportFileName
                    #        Type           = "(RPC) PoSh"
                    #    }
                    #}
                    elseif ($Entry.Checked -and $Entry -match '(RPC)' -and  $Entry -match 'WMI' -and $Entry -notmatch '(WinRM)') {
                        $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                        $script:CommandsCheckedBoxesSelected += New-Object psobject @{
                            Name           = $Entry.Text
                            Command        = $Command.Command_RPC_WMI
                            Properties     = $Command.Properties_WMI
                            ExportFileName = $Command.ExportFileName
                            Type           = "(RPC) WMI"
                        }
                    }
                    #elseif ($Entry.Checked -and $Entry -match '(RPC)' -and  $Entry -match 'CMD' -and $Entry -notmatch '(WinRM)') {
                    #    $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                    #    $script:CommandsCheckedBoxesSelected += New-Object psobject @{
                    #        Name           = $Entry.Text
                    #        Command        = $Command.Command_RPC_CMD
                    #        ExportFileName = $Command.ExportFileName
                    #        Type           = "(RPC) CMD"
                    #    }
                    #}
                    elseif ($Entry.Checked -and $Entry -match '(SMB)' -and $Entry -match 'PoSh') {
                        $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                        $script:CommandsCheckedBoxesSelected += New-Object psobject @{
                            Name           = $Entry.Text
                            Command        = $Command.Command_SMB_PoSh
                            ExportFileName = $Command.ExportFileName
                            Type           = "(SMB) PoSh"
                        }
                    }
                    elseif ($Entry.Checked -and $Entry -match '(SMB)' -and $Entry -match 'WMI') {
                        $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                        $script:CommandsCheckedBoxesSelected += New-Object psobject @{
                            Name           = $Entry.Text
                            Command        = $Command.Command_SMB_WMI
                            ExportFileName = $Command.ExportFileName
                            Type           = "(SMB) WMI"
                        }
                    }
                    elseif ($Entry.Checked -and $Entry -match '(SMB)' -and $Entry -match 'CMD') {
                        $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                        $script:CommandsCheckedBoxesSelected += New-Object psobject @{
                            Name           = $Entry.Text
                            Command        = $Command.Command_SMB_CMD
                            ExportFileName = $Command.ExportFileName
                            Type           = "(SMB) CMD"
                        }
                    }
                    elseif ($Entry.Checked -and $Entry -match '(SSH)' -and $Entry -match 'Linux') {
                        $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                        $script:CommandsCheckedBoxesSelected += New-Object psobject @{
                            Name           = $Entry.Text
                            Command        = $Command.Command_Linux
                            ExportFileName = $Command.ExportFileName
                            Type           = "(SSH) Linux"
                        }
                    }
                }
            }
            if ($CommandsViewCommandNamesRadioButton.Checked) {
                foreach ($Entry in $Category.nodes) {
                    # Builds the query that is selected
                    if ($Entry -match '(WinRM)' -and $Entry -match 'Script' -and $Entry.Checked) {
                        $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                        $script:CommandsCheckedBoxesSelected += New-Object psobject @{
                            Name           = $Entry.Text
                            Command        = $Command.Command_WinRM_Script
                            ExportFileName = $Command.ExportFileName
                            Type           = "(WinRM) Script"
                        }
                    }
                    elseif ($Entry -match '(WinRM)' -and $Entry -match 'PoSh' -and $Entry.Checked) {
                        $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                        $script:CommandsCheckedBoxesSelected += New-Object psobject @{
                            Name           = $Entry.Text
                            Command        = $Command.Command_WinRM_PoSh
                            Properties     = $Command.Properties_PoSh
                            ExportFileName = $Command.ExportFileName
                            Type           = '(WinRM) PoSh'
                        }
                    }
                    elseif ($Entry -match '(WinRM)' -and $Entry -match 'WMI' -and $Entry.Checked) {
                        $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                        $script:CommandsCheckedBoxesSelected += New-Object psobject @{
                            Name           = $Entry.Text
                            Command        = $Command.Command_WinRM_WMI
                            Properties     = $Command.Properties_WMI
                            ExportFileName = $Command.ExportFileName
                            Type           = "(WinRM) WMI"
                        }
                    }
                    #elseif ($Entry -match '(WinRM)' -and $Entry -match 'CMD' -and $Entry.Checked) {
                    #    $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                    #    $script:CommandsCheckedBoxesSelected += New-Object psobject @{
                    #        Name           = $Entry.Text
                    #        Command        = $Command.Command_WinRM_CMD
                    #        ExportFileName = $Command.ExportFileName
                    #        Type           = "(WinRM) CMD"
                    #    }
                    #}
                    #if ($Entry -match '(RPC)' -and $Entry -match 'PoSh' -and $Entry.Checked) {
                    #    $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                    #    $script:CommandsCheckedBoxesSelected += New-Object psobject @{
                    #        Name           = $Entry.Text
                    #        Command        = $Command.Command_RPC_PoSh
                    #        Properties     = $Command.Properties_PoSh
                    #        ExportFileName = $Command.ExportFileName
                    #        Type           = '(RPC) PoSh'
                    #    }
                    #}
                    elseif (($Entry -match '(RPC)') -and  $Entry -match 'WMI' -and ($Entry -notmatch '(WinRM)') -and $Entry.Checked) {
                        $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                        $script:CommandsCheckedBoxesSelected += New-Object psobject @{
                            Name           = $Entry.Text
                            Command        = $Command.Command_RPC_WMI
                            Properties     = $Command.Properties_WMI
                            ExportFileName = $Command.ExportFileName
                            Type           = "(RPC) WMI"
                        }
                    }
                    #elseif (($Entry -match '(RPC)') -and  $Entry -match 'CMD' -and ($Entry -notmatch '(WinRM)') -and $Entry.Checked) {
                    #    $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                    #    $script:CommandsCheckedBoxesSelected += New-Object psobject @{
                    #        Name           = $Entry.Text
                    #        Command        = $Command.Command_RPC_CMD
                    #        ExportFileName = $Command.ExportFileName
                    #        Type           = "(RPC) CMD"
                    #    }
                    #}
                    elseif ($Entry -match '(SMB)' -and $Entry -match 'PoSh' -and $Entry.Checked) {
                        $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                        $script:CommandsCheckedBoxesSelected += New-Object psobject @{
                            Name           = $Entry.Text
                            Command        = $Command.Command_SMB_PoSh
                            ExportFileName = $Command.ExportFileName
                            Type           = "(SMB) PoSh"
                        }
                    }
                    elseif ($Entry -match '(SMB)' -and $Entry -match 'WMI' -and $Entry.Checked) {
                        $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                        $script:CommandsCheckedBoxesSelected += New-Object psobject @{
                            Name           = $Entry.Text
                            Command        = $Command.Command_SMB_WMI
                            ExportFileName = $Command.ExportFileName
                            Type           = "(SMB) WMI"
                        }
                    }
                    elseif ($Entry -match '(SMB)' -and $Entry -match 'CMD' -and $Entry.Checked) {
                        $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                        $script:CommandsCheckedBoxesSelected += New-Object psobject @{
                            Name           = $Entry.Text
                            Command        = $Command.Command_SMB_CMD
                            ExportFileName = $Command.ExportFileName
                            Type           = "(SMB) CMD"
                        }
                    }
                    elseif ($Entry -match '(SSH)' -and $Entry -match 'Linux' -and $Entry.Checked) {
                        $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                        $script:CommandsCheckedBoxesSelected += New-Object psobject @{
                            Name           = $Entry.Text
                            Command        = $Command.Command_Linux
                            ExportFileName = $Command.ExportFileName
                            Type           = "(SSH) Linux"
                        }
                    }
                }
            }
        }
    }
}


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUBsEI8r+PSGu0+vK2nguvBwy2
# kb2gggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUhpRqFxYYsJMqjpCfwvh21RF+U6YwDQYJKoZI
# hvcNAQEBBQAEggEAF2HfmzEizF0M/18JRgOqo6cc7i1K03nhmQd3Kw0PLeg3rkSE
# eLYoNT3MzLyo6NrX0Tr0nQ9E0DU4UBYL3Nzo9Zxh39LlMHN+2K/wxc0+RUjnLnYR
# VZXebYR45BlsQ+SAPgeEnwN7rAS2OfiwoWjPEjMFY1NPCiCAKMMtqGJcnRmBWHZn
# f1DS45diSdT2buhQSURPHAGv3eYHfTkPE9+LcAvknHWhp3Of/T6y53tS1leDwkrJ
# dvq4iI0JKgjwphQcz0dOeC8QcwY2wHIPPVuev8iTmj2cU26E5W/uyuRQQTsl6owl
# VxC5zyz71N1/9EtI003rAgXdTD+NK8G9MNkFlQ==
# SIG # End signature block
