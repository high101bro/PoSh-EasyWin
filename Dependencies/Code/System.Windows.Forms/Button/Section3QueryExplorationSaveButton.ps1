$Section3QueryExplorationSaveButtonAdd_Click = {
    if ($Section3QueryExplorationSaveButton.Text -eq "Save") {
        $Section3QueryExplorationEditCheckBox.Checked               = $false
        $Section3QueryExplorationSaveButton.Text                    = "Locked"
        $Section3QueryExplorationSaveButton.ForeColor               = "Green"
        $Section3QueryExplorationDescriptionRichTextbox.ReadOnly    = $true
        $Section3QueryExplorationDescriptionRichTextbox.BackColor   = 'White'
        $Section3QueryExplorationDescriptionRichTextbox.ForeColor   = 'Black'
        $Section3QueryExplorationWinRSCmdTextBox.ReadOnly           = $true
        $Section3QueryExplorationWinRSCmdTextBox.BackColor          = 'White'
        $Section3QueryExplorationWinRSCmdTextBox.ForeColor          = 'Black'
        $Section3QueryExplorationWinRSWmicTextBox.ReadOnly          = $true
        $Section3QueryExplorationWinRSWmicTextBox.BackColor         = 'White'
        $Section3QueryExplorationWinRSWmicTextBox.ForeColor         = 'Black'
        $Section3QueryExplorationPropertiesWMITextBox.ReadOnly      = $true
        $Section3QueryExplorationPropertiesWMITextBox.BackColor     = 'White'
        $Section3QueryExplorationPropertiesWMITextBox.ForeColor     = 'Black'
        $Section3QueryExplorationPropertiesPoshTextBox.ReadOnly     = $true
        $Section3QueryExplorationPropertiesPoshTextBox.BackColor    = 'White'
        $Section3QueryExplorationPropertiesPoshTextBox.ForeColor    = 'Black'
        $Section3QueryExplorationRPCWMITextBox.ReadOnly             = $true
        $Section3QueryExplorationRPCWMITextBox.BackColor            = 'White'
        $Section3QueryExplorationRPCWMITextBox.ForeColor            = 'Black'
        $Section3QueryExplorationRPCPoShTextBox.ReadOnly            = $true
        $Section3QueryExplorationRPCPoShTextBox.BackColor           = 'White'
        $Section3QueryExplorationRPCPoShTextBox.ForeColor           = 'Black'
        $Section3QueryExplorationWinRMWMITextBox.ReadOnly           = $true
        $Section3QueryExplorationWinRMWMITextBox.BackColor          = 'White'
        $Section3QueryExplorationWinRMWMITextBox.ForeColor          = 'Black'
        $Section3QueryExplorationWinRMCmdTextBox.ReadOnly           = $true
        $Section3QueryExplorationWinRMCmdTextBox.BackColor          = 'White'
        $Section3QueryExplorationWinRMCmdTextBox.ForeColor          = 'Black'
        $Section3QueryExplorationWinRMPoShTextBox.ReadOnly          = $true
        $Section3QueryExplorationWinRMPoShTextBox.BackColor         = 'White'
        $Section3QueryExplorationWinRMPoShTextBox.ForeColor         = 'Black'
        $Section3QueryExplorationTagWordsTextBox.ReadOnly           = $true
        $Section3QueryExplorationTagWordsTextBox.BackColor          = 'White'
        $Section3QueryExplorationTagWordsTextBox.ForeColor          = 'Black'
        $Section3QueryExplorationSmbPoshTextBox.ReadOnly            = $true
        $Section3QueryExplorationSmbPoshTextBox.BackColor           = 'White'
        $Section3QueryExplorationSmbPoshTextBox.ForeColor           = 'Black'
        $Section3QueryExplorationSmbWmiTextBox.ReadOnly             = $true
        $Section3QueryExplorationSmbWmiTextBox.BackColor            = 'White'
        $Section3QueryExplorationSmbWmiTextBox.ForeColor            = 'Black'
        $Section3QueryExplorationSmbCmdTextBox.ReadOnly             = $true
        $Section3QueryExplorationSmbCmdTextBox.BackColor            = 'White'
        $Section3QueryExplorationSmbCmdTextBox.ForeColor            = 'Black'
        $Section3QueryExplorationSshLinuxTextBox.ReadOnly           = $true
        $Section3QueryExplorationSshLinuxTextBox.BackColor          = 'White'
        $Section3QueryExplorationSshLinuxTextBox.ForeColor          = 'Black'

        $SaveAllEndpointCommands = @()
        Foreach($Query in $script:AllEndpointCommands) {
            if ($Section3QueryExplorationNameTextBox.Text -ne $Query.Name -and $Query.Type -notmatch 'script') {
                # For those commands not selected, this just copies their unmodified data to be saved.
                $SaveAllEndpointCommands += [PSCustomObject]@{
                    Name               = $Query.Name
                    Type               = $Query.Type
                    Command_WinRM_PoSh = $Query.Command_WinRM_PoSh
                    Command_WinRM_WMI  = $Query.Command_WinRM_WMI
                    Command_WinRM_Cmd  = $Query.Command_WinRM_Cmd
                    Command_RPC_Posh   = $Query.Command_RPC_Posh
                    Command_RPC_WMI    = $Query.Command_RPC_WMI
                    Command_RPC_Cmd    = $Query.Command_RPC_Cmd
                    Properties_PoSh    = $Query.Properties_PoSh
                    Properties_WMI     = $Query.Properties_WMI
                    Command_WinRS_WMIC = $Query.Command_WinRS_WMIC
                    Command_WinRS_CMD  = $Query.Command_WinRS_CMD
                    Command_SMB_PoSh   = $Query.Command_SMB_PoSh
                    Command_SMB_WMI    = $Query.Command_SMB_WMI
                    Command_SMB_Cmd    = $Query.Command_SMB_Cmd
                    Command_Linux      = $Query.Command_Linux
                    Description        = $Query.Description
                    ExportFileName     = $Query.ExportFileName
                }
            }
            elseif ($Section3QueryExplorationNameTextBox.Text -eq $Query.Name -and $Query.Type -notmatch 'script') {
                # if the node is selected, it saves the information in the text boxes
                $SaveAllEndpointCommands += [PSCustomObject]@{
                    Name               = $Section3QueryExplorationNameTextBox.Text
                    Type               = $Section3QueryExplorationTagWordsTextBox.Text
                    Command_WinRM_PoSh = $Section3QueryExplorationWinRMPoShTextBox.Text
                    Command_WinRM_WMI  = $Section3QueryExplorationWinRMWMITextBox.Text
                    Command_WinRM_Cmd  = $Section3QueryExplorationWinRMCmdTextBox.Text
                    Command_RPC_Posh   = $Section3QueryExplorationRPCPoShTextBox.Text
                    Command_RPC_WMI    = $Section3QueryExplorationRPCWMITextBox.Text
                    Properties_PoSh    = $Section3QueryExplorationPropertiesPoshTextBox.Text
                    Properties_WMI     = $Section3QueryExplorationPropertiesWMITextBox.Text
                    Command_WinRS_WMIC = $Section3QueryExplorationWinRSWmicTextBox.Text
                    Command_WinRS_CMD  = $Section3QueryExplorationWinRSCmdTextBox.Text
                    Command_SMB_PoSh   = $Section3QueryExplorationSmbPoshTextBox.Text
                    Command_SMB_WMI    = $Section3QueryExplorationSmbWmiTextBox.Text
                    Command_SMB_Cmd    = $Section3QueryExplorationSmbCmdTextBox.Text
                    Command_Linux      = $Section3QueryExplorationSshLinuxTextBox.Text
                    Description        = $Section3QueryExplorationDescriptionRichTextbox.Text
                    ExportFileName     = $Query.ExportFileName
                }
            }
        }
        $SaveAllEndpointCommands    | Export-Csv $CommandsEndpoint -NoTypeInformation -Force
        $script:AllEndpointCommands = $SaveAllEndpointCommands
        Import-EndpointScripts

        $SaveAllActiveDirectoryCommands = @()
        Foreach($Query in $script:AllActiveDirectoryCommands) {
            if ($Section3QueryExplorationNameTextBox.Text -ne $Query.Name -and $Query.Type -notmatch 'script') {
                # if the node is selected, it saves the information in the text boxes
                $SaveAllActiveDirectoryCommands += [PSCustomObject]@{
                    Name               = $Query.Name
                    Type               = $Query.Type
                    Command_WinRM_PoSh = $Query.Command_WinRM_PoSh
                    Command_WinRM_WMI  = $Query.Command_WinRM_WMI
                    Command_WinRM_Cmd  = $Query.Command_WinRM_Cmd
                    Command_RPC_Posh   = $Query.Command_RPC_Posh
                    Command_RPC_WMI    = $Query.Command_RPC_WMI
                    Command_RPC_Cmd    = $Query.Command_RPC_Cmd
                    Properties_PoSh    = $Query.Properties_PoSh
                    Properties_WMI     = $Query.Properties_WMI
                    Command_WinRS_WMIC = $Query.Command_WinRS_WMIC
                    Command_WinRS_CMD  = $Query.Command_WinRS_CMD
                    Command_SMB_PoSh   = $Query.Command_SMB_PoSh
                    Command_SMB_WMI    = $Query.Command_SMB_WMI
                    Command_SMB_Cmd    = $Query.Command_SMB_Cmd
                    Command_Linux      = $Query.Command_Linux
                    Description        = $Query.Description
                    ExportFileName     = $Query.ExportFileName

                }
            }
            elseif ($Section3QueryExplorationNameTextBox.Text -eq $Query.Name -and $Query.Type -notmatch 'script') {
                # if the node is selected, it saves the information in the text boxes
                $SaveAllActiveDirectoryCommands += [PSCustomObject]@{
                    Name               = $Section3QueryExplorationNameTextBox.Text
                    Type               = $Section3QueryExplorationTagWordsTextBox.Text
                    Command_WinRM_PoSh = $Section3QueryExplorationWinRMPoShTextBox.Text
                    Command_WinRM_WMI  = $Section3QueryExplorationWinRMWMITextBox.Text
                    Command_WinRM_Cmd  = $Section3QueryExplorationWinRMCmdTextBox.Text
                    Command_RPC_Posh   = $Section3QueryExplorationRPCPoShTextBox.Text
                    Command_RPC_WMI    = $Section3QueryExplorationRPCWMITextBox.Text
                    Properties_PoSh    = $Section3QueryExplorationPropertiesPoshTextBox.Text
                    Properties_WMI     = $Section3QueryExplorationPropertiesWMITextBox.Text
                    Command_WinRS_WMIC = $Section3QueryExplorationWinRSWmicTextBox.Text
                    Command_WinRS_CMD  = $Section3QueryExplorationWinRSCmdTextBox.Text
                    Command_SMB_PoSh   = $Section3QueryExplorationSmbPoshTextBox.Text
                    Command_SMB_WMI    = $Section3QueryExplorationSmbWmiTextBox.Text
                    Command_SMB_Cmd    = $Section3QueryExplorationSmbCmdTextBox.Text
                    Command_Linux      = $Section3QueryExplorationSshLinuxTextBox.Text
                    Description        = $Section3QueryExplorationDescriptionRichTextbox.Text
                    ExportFileName     = $Query.ExportFileName                }
            }
        }
        $SaveAllActiveDirectoryCommands    | Export-Csv $CommandsActiveDirectory -NoTypeInformation -Force
        $script:AllActiveDirectoryCommands = $SaveAllActiveDirectoryCommands
        Import-ActiveDirectoryScripts

        $script:CommandsTreeView.Nodes.Clear()
        Initialize-CommandTreeNodes
        View-CommandTreeNodeMethod
        Update-TreeNodeCommandState

        $InformationTabControl.SelectedTab = $Section3ResultsTab
        $CommandTextBoxList = @($Section3QueryExplorationNameTextBox,$Section3QueryExplorationTagWordsTextBox,$Section3QueryExplorationWinRMPoShTextBox,$Section3QueryExplorationWinRMWMITextBox,$Section3QueryExplorationWinRMCmdTextBox,$Section3QueryExplorationRPCPoShTextBox,$Section3QueryExplorationRPCWMITextBox,$Section3QueryExplorationPropertiesPoshTextBox,$Section3QueryExplorationPropertiesWMITextBox,$Section3QueryExplorationWinRSWmicTextBox,$Section3QueryExplorationWinRSCmdTextBox,$Section3QueryExplorationDescriptionRichTextbox)
        foreach ( $TextBox in $CommandTextBoxList ) { $TextBox.Text = '' }
        $StatusListBox.Items.Add("Command updated.")
        #Removed For Testing#$ResultsListBox.Items.Clear()

    }
    else {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Section is locked from editing.")
        [system.media.systemsounds]::Exclamation.play()
    }
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU3iYALpvmRWqlVE748pv9+sBU
# 3B2gggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUjTG8OFUB+YBin+pTFXM1KGIcKdgwDQYJKoZI
# hvcNAQEBBQAEggEAdgD+agkvkxEdK8peHsTbKVNrCLxdgA7yBLKgD+wPy518UN8r
# 3CW3k10U4g3gvEhLBLWroccZlYPwx1Ql0GbsbLEkLxzxBPbPY/A1QTIyTe0jijoV
# 4sVPAgvOB26nuvJicQuXipcpzii4e41jN5LAtz6gWX84Imd3e6v8EwK4H0P+ezn0
# ZqijOF2UOyEcyjEGLgDL8Mh1FxCr6ElKVw1RJiUiEBI5DNFNuSv2879K5X2AUSuC
# MeqH6GUW9FWktP0Qg96H7dnILFsVk4EiWT1x/BweJGyyWMFZd/DRvZvosbu6jYRV
# ku0qzWsJTw72ZKv3PPNeXQjqOGPie9JXzFseOw==
# SIG # End signature block
