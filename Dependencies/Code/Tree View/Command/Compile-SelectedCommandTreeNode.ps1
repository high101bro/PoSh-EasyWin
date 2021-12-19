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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUDw4ffgVHMSVHN1Pn52GT+6gH
# 4AWgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU/rajAwGgzb7rRafl6OcdXbeASgIwDQYJKoZI
# hvcNAQEBBQAEggEAa1W9eCuxlM//ykxDpKDRZ5g0wqH2pu1m1+DStPMfxPgusdG4
# JtKiGIgjZvCkWl5ZT9MVgwqeN4vt6DDL2KO3yL17X+fOIzPQKfljteFukRsZXb6h
# dOEECMGSFkJZPdSMOfYNCJIs6LulU8FZbbQ9U/FYcLhWK8MBPESqjU5GnfTE9a7R
# rHfxk3QiXcukbahTjYsD3ZMd7sJbQx4/aA39XHpub/T+woxoQfB4PGvzzMJZ3c4w
# TrQW+kuPeGzJXAn8UaFEjqTwdjTP+3/ZqpU6Esm9rl/A1s2tDfFEJ86mOW07+iln
# gIMs8REg/t9J01EMTHBL6tNGUGk5VWAuZLwmHA==
# SIG # End signature block
