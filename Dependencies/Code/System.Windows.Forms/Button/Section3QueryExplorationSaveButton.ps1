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
# 3B2gggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUjTG8OFUB+YBin+pTFXM1KGIcKdgwDQYJKoZI
# hvcNAQEBBQAEggEAsZuac+zMKrhvaiqhGdEVhr2MT2f/fjJusgzhWtoT1QD1onYF
# q0VZsDIxw0Rub0ALzdsmu3ZHfTViIXQC0yVV3vgFNseLfdOAyDV232sw4xfwsqQp
# BoH8AKWSFTsb/KyIbQzarjcxyi3pq4+mcri2Cu56ml2iha9MmiSRBQAa5czXGibg
# r+xz6Oo2CRbB2IzqU/y1AXHOMHRWsaDjibqmXwZURE7430/PTBapzCj4ogosxQsA
# fgvc1vVYLbzSbBQZab44uvvrPIFCu4rEXWZfNcMlRBHZNYla3lKfJuREWg5biA0b
# vbie0W3w9RRWIpVXE+8xcPYq99gJKl01Iudh4g==
# SIG # End signature block
