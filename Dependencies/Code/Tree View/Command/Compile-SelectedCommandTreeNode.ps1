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
# kb2gggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUhpRqFxYYsJMqjpCfwvh21RF+U6YwDQYJKoZI
# hvcNAQEBBQAEggEAd+9jR6EDarlusFL6r+0cvGUQErCEkqjaXtCIbhGZcfXCemgC
# GdBErhpG6gpZ0R4gAf82v52Xnqzj2iYSiMhEBjuqBcKFKp03cR2hOZmkQImmp5h/
# GgAnzYPCio3hvyfEcH9tsNq4nzzLIarv4nfUGkUvSTBg2cbi5PcANjFxAabGYzet
# LlWmuvbINMNOSX3UCLD/aM4Y/wsjcvg+Q9vJNGKh6sruB6lR4CDzkrZnSE94Mz8r
# TKtdw1JTI4vNfr7n7LZPy8zjAOqHpYRZkXMgv5NS3BlYZY2W7qZBVfceuaAGIcfe
# 2r3NbsGzKE4YhImOedDXRB5ORoQfrPhaSabG6g==
# SIG # End signature block
