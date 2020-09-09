$Section3QueryExplorationSaveButtonAdd_Click = {
    if ($Section3QueryExplorationSaveButton.Text -eq "Save") {
        $Section3QueryExplorationSaveButton.Text                 = "Locked"
        $Section3QueryExplorationSaveButton.ForeColor            = "Green"
        $Section3QueryExplorationEditCheckBox.checked            = $false
        $Section3QueryExplorationDescriptionRichTextbox.ReadOnly = $true
        $Section3QueryExplorationWinRSCmdTextBox.ReadOnly        = $true
        $Section3QueryExplorationWinRSWmicTextBox.ReadOnly       = $true
        $Section3QueryExplorationPropertiesWMITextBox.ReadOnly   = $true
        $Section3QueryExplorationPropertiesPoshTextBox.ReadOnly  = $true
        $Section3QueryExplorationRPCWMITextBox.ReadOnly          = $true
        $Section3QueryExplorationRPCPoShTextBox.ReadOnly         = $true
        $Section3QueryExplorationWinRMWMITextBox.ReadOnly        = $true
        $Section3QueryExplorationWinRMCmdTextBox.ReadOnly        = $true
        $Section3QueryExplorationWinRMPoShTextBox.ReadOnly       = $true
        $Section3QueryExplorationTagWordsTextBox.ReadOnly        = $true

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
                    Command_SMB_PoSh   = $Query.Command_SMB_PoSh
                    Command_SMB_WMI    = $Query.Command_SMB_WMI
                    Command_SMB_Cmd    = $Query.Command_SMB_Cmd
                    Properties_PoSh    = $Query.Properties_PoSh
                    Properties_WMI     = $Query.Properties_WMI
                    Command_WinRS_WMIC = $Query.Command_WinRS_WMIC
                    Command_WinRS_CMD  = $Query.Command_WinRS_CMD
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
                    Command_SMB_CMD    = $Section3QueryExplorationWinRMCmdTextBox.Text
                    Command_RPC_Posh   = $Section3QueryExplorationRPCPoShTextBox.Text
                    Command_RPC_WMI    = $Section3QueryExplorationRPCWMITextBox.Text
                    Properties_PoSh    = $Section3QueryExplorationPropertiesPoshTextBox.Text
                    Properties_WMI     = $Section3QueryExplorationPropertiesWMITextBox.Text
                    Command_WinRS_WMIC = $Section3QueryExplorationWinRSWmicTextBox.Text
                    Command_WinRS_CMD  = $Section3QueryExplorationWinRSCmdTextBox.Text
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
                    Command_SMB_PoSh   = $Query.Command_SMB_PoSh
                    Command_SMB_WMI    = $Query.Command_SMB_WMI
                    Command_SMB_Cmd    = $Query.Command_SMB_Cmd
                    Properties_PoSh    = $Query.Properties_PoSh
                    Properties_WMI     = $Query.Properties_WMI
                    Command_WinRS_WMIC = $Query.Command_WinRS_WMIC
                    Command_WinRS_CMD  = $Query.Command_WinRS_CMD
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
                    Command_SMB_CMD    = $Section3QueryExplorationWinRMCmdTextBox.Text
                    Command_RPC_Posh   = $Section3QueryExplorationRPCPoShTextBox.Text
                    Command_RPC_WMI    = $Section3QueryExplorationRPCWMITextBox.Text
                    Properties_PoSh    = $Section3QueryExplorationPropertiesPoshTextBox.Text
                    Properties_WMI     = $Section3QueryExplorationPropertiesWMITextBox.Text
                    Command_WinRS_WMIC = $Section3QueryExplorationWinRSWmicTextBox.Text
                    Command_WinRS_CMD  = $Section3QueryExplorationWinRSCmdTextBox.Text
                    Description        = $Section3QueryExplorationDescriptionRichTextbox.Text
                    ExportFileName     = $Query.ExportFileName
                }
            }
        }
        $SaveAllActiveDirectoryCommands    | Export-Csv $CommandsActiveDirectory -NoTypeInformation -Force
        $script:AllActiveDirectoryCommands = $SaveAllActiveDirectoryCommands
        Import-ActiveDirectoryScripts

        $script:CommandsTreeView.Nodes.Clear()
        Initialize-CommandTreeNodes
        View-CommandTreeNodeMethod
        KeepChecked-CommandTreeNode

        $MainBottomTabControl.SelectedTab = $Section3ResultsTab
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
