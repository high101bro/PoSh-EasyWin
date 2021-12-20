####################################################################################################
# ScriptBlocks
####################################################################################################

$Section3QueryExplorationEditCheckBoxAdd_Click = {
    if ($Section3QueryExplorationEditCheckBox.checked){
        $Section3QueryExplorationSaveButton.Text                    = "Save"
        $Section3QueryExplorationSaveButton.ForeColor               = "Red"
        $Section3QueryExplorationDescriptionRichTextbox.ReadOnly    = $false
        $Section3QueryExplorationDescriptionRichTextbox.BackColor   = 'White'
        $Section3QueryExplorationDescriptionRichTextbox.ForeColor   = 'Blue'
        $Section3QueryExplorationWinRSCmdTextBox.ReadOnly           = $false
        $Section3QueryExplorationWinRSCmdTextBox.BackColor          = 'White'
        $Section3QueryExplorationWinRSCmdTextBox.ForeColor          = 'Blue'
        $Section3QueryExplorationWinRSWmicTextBox.ReadOnly          = $false
        $Section3QueryExplorationWinRSWmicTextBox.BackColor         = 'White'
        $Section3QueryExplorationWinRSWmicTextBox.ForeColor         = 'Blue'
        $Section3QueryExplorationPropertiesWMITextBox.ReadOnly      = $false
        $Section3QueryExplorationPropertiesWMITextBox.BackColor     = 'White'
        $Section3QueryExplorationPropertiesWMITextBox.ForeColor     = 'Blue'
        $Section3QueryExplorationPropertiesPoshTextBox.ReadOnly     = $false
        $Section3QueryExplorationPropertiesPoshTextBox.BackColor    = 'White'
        $Section3QueryExplorationPropertiesPoshTextBox.ForeColor    = 'Blue'
        $Section3QueryExplorationRPCWMITextBox.ReadOnly             = $false
        $Section3QueryExplorationRPCWMITextBox.BackColor            = 'White'
        $Section3QueryExplorationRPCWMITextBox.ForeColor            = 'Blue'
        $Section3QueryExplorationRPCPoShTextBox.ReadOnly            = $false
        $Section3QueryExplorationRPCPoShTextBox.BackColor           = 'White'
        $Section3QueryExplorationRPCPoShTextBox.ForeColor           = 'Blue'
        $Section3QueryExplorationWinRMWMITextBox.ReadOnly           = $false
        $Section3QueryExplorationWinRMWMITextBox.BackColor          = 'White'
        $Section3QueryExplorationWinRMWMITextBox.ForeColor          = 'Blue'
        $Section3QueryExplorationWinRMCmdTextBox.ReadOnly           = $false
        $Section3QueryExplorationWinRMCmdTextBox.BackColor          = 'White'
        $Section3QueryExplorationWinRMCmdTextBox.ForeColor          = 'Blue'
        $Section3QueryExplorationWinRMPoShTextBox.ReadOnly          = $false
        $Section3QueryExplorationWinRMPoShTextBox.BackColor         = 'White'
        $Section3QueryExplorationWinRMPoShTextBox.ForeColor         = 'Blue'
        $Section3QueryExplorationTagWordsTextBox.ReadOnly           = $false
        $Section3QueryExplorationTagWordsTextBox.BackColor          = 'White'
        $Section3QueryExplorationTagWordsTextBox.ForeColor          = 'Blue'
        $Section3QueryExplorationSmbPoshTextBox.ReadOnly            = $true
        $Section3QueryExplorationSmbPoshTextBox.BackColor           = 'White'
        $Section3QueryExplorationSmbPoshTextBox.ForeColor           = 'Blue'
        $Section3QueryExplorationSmbWmiTextBox.ReadOnly             = $true
        $Section3QueryExplorationSmbWmiTextBox.BackColor            = 'White'
        $Section3QueryExplorationSmbWmiTextBox.ForeColor            = 'Blue'
        $Section3QueryExplorationSmbCmdTextBox.ReadOnly             = $true
        $Section3QueryExplorationSmbCmdTextBox.BackColor            = 'White'
        $Section3QueryExplorationSmbCmdTextBox.ForeColor            = 'Blue'
        $Section3QueryExplorationSshLinuxTextBox.ReadOnly           = $true
        $Section3QueryExplorationSshLinuxTextBox.BackColor          = 'White'
        $Section3QueryExplorationSshLinuxTextBox.ForeColor          = 'Blue'
    }
    else {
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
    }
}

$Section3QueryExplorationViewScriptButtonAdd_Click = {
    Foreach($Query in $script:AllEndpointCommands) {
        if ($Section3QueryExplorationNameTextBox.Text -match $Query.Name -and $Query.Type -match 'script' -and $Query.Command_WinRM_Script -match 'filepath') {
            write.exe $Query.ScriptPath
        }
    }
    Foreach($Query in $script:AllActiveDirectoryCommands) {
        if ($Section3QueryExplorationNameTextBox.Text -eq $Query.Name -and $Query.Type -match 'script') {
            write.exe $Query.ScriptPath
        }
    }
}

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
        Initialize-TreeViewCommand
        View-TreeViewCommandMethod
        Update-TreeViewCommand

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


####################################################################################################
# WinForms
####################################################################################################

$Section3QueryExplorationTabPage = New-Object System.Windows.Forms.TabPage -Property @{
    Text = "Command Exploration  "
    Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
    Add_click = { script:Minimize-MonitorJobsTab }
    ImageIndex = 5
}
$InformationTabControl.Controls.Add($Section3QueryExplorationTabPage)


$Section3QueryExplorationNameLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "Query Name:"
    Location = @{ X = $FormScale * 0
                  Y = $FormScale * 6 }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section3QueryExplorationNameTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationNameLabel.Location.X + $Section3QueryExplorationNameLabel.Size.Width + $($FormScale * 5)
                  Y = $FormScale * 3 }
    Size     = @{ Width  = $FormScale * 195
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Backcolor = 'White'
    ReadOnly = $true
    Add_MouseEnter = { $This.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $This.size = @{ Width  = $FormScale * 195 } }
}
$Section3QueryExplorationTabPage.Controls.AddRange(@($Section3QueryExplorationNameLabel,$Section3QueryExplorationNameTextBox))


$Section3QueryExplorationWinRMPoShLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "WinRM PoSh:"
    Location = @{ X = 0
                  Y = $Section3QueryExplorationNameLabel.location.Y + $Section3QueryExplorationNameLabel.Size.Height }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section3QueryExplorationWinRMPoShTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationWinRMPoShLabel.Location.X + $Section3QueryExplorationWinRMPoShLabel.Size.Width + $($FormScale * 5)
                  Y = $Section3QueryExplorationWinRMPoShLabel.Location.Y - $($FormScale * 3) }
    Size     = @{ Width  = $FormScale * 195
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Backcolor = 'White'
    ReadOnly = $true
    Add_MouseEnter = { $This.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $This.size = @{ Width  = $FormScale * 195 } }
}
$Section3QueryExplorationTabPage.Controls.AddRange(@($Section3QueryExplorationWinRMPoShLabel,$Section3QueryExplorationWinRMPoShTextBox))


$Section3QueryExplorationWinRMWMILabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "WinRM WMI:"
    Location = @{ X = 0
                  Y = $Section3QueryExplorationWinRMPoShLabel.location.Y + $Section3QueryExplorationWinRMPoShLabel.Size.Height }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationWinRMWMILabel)


$Section3QueryExplorationWinRMWMITextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationWinRMWMILabel.Location.X + $Section3QueryExplorationWinRMWMILabel.Size.Width + $($FormScale * 5)
                  Y = $Section3QueryExplorationWinRMWMILabel.Location.Y - $($FormScale * 3) }
    Size     = @{ Width  = $FormScale * 195
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Backcolor = 'White'
    ReadOnly = $true
    Add_MouseEnter = { $This.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $This.size = @{ Width  = $FormScale * 195 } }
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationWinRMWMITextBox)


$Section3QueryExplorationWinRMCmdLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "WinRM Cmd:"
    Location = @{ X = 0
                  Y = $Section3QueryExplorationWinRMWMILabel.location.Y + $Section3QueryExplorationWinRMWMILabel.Size.Height }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationWinRMCmdLabel)


$Section3QueryExplorationWinRMCmdTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationWinRMCmdLabel.Location.X + $Section3QueryExplorationWinRMCmdLabel.Size.Width + $($FormScale * 5)
                  Y = $Section3QueryExplorationWinRMCmdLabel.Location.Y - $($FormScale * 3) }
    Size     = @{ Width  = $FormScale * 195
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Backcolor = 'White'
    ReadOnly = $true
    Add_MouseEnter = { $This.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $This.size = @{ Width  = $FormScale * 195 } }
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationWinRMCmdTextBox)


$Section3QueryExplorationRPCPoShLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "RPC/DCOM PoSh:"
    Location = @{ X = 0
                  Y = $Section3QueryExplorationWinRMCmdLabel.location.Y + $Section3QueryExplorationWinRMCmdLabel.Size.Height }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationRPCPoShLabel)


$Section3QueryExplorationRPCPoShTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationRPCPoShLabel.Location.X + $Section3QueryExplorationRPCPoShLabel.Size.Width + $($FormScale * 5)
                  Y = $Section3QueryExplorationRPCPoShLabel.Location.Y - $($FormScale * 3) }
    Size     = @{ Width  = $FormScale * 195
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Backcolor = 'White'
    ReadOnly = $true
    Add_MouseEnter = { $This.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $This.size = @{ Width  = $FormScale * 195 } }
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationRPCPoShTextBox)


$Section3QueryExplorationRPCWMILabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "RPC/DCOM WMI:"
    Location = @{ X = 0
                  Y = $Section3QueryExplorationRPCPoShLabel.location.Y + $Section3QueryExplorationRPCPoShLabel.Size.Height }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationRPCWMILabel)


$Section3QueryExplorationRPCWMITextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationRPCWMILabel.Location.X + $Section3QueryExplorationRPCWMILabel.Size.Width + $($FormScale * 5)
                  Y = $Section3QueryExplorationRPCWMILabel.Location.Y - $($FormScale * 3) }
    Size     = @{ Width  = $FormScale * 195
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Backcolor = 'White'
    ReadOnly = $true
    Add_MouseEnter = { $This.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $This.size = @{ Width  = $FormScale * 195 } }
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationRPCWMITextBox)


$Section3QueryExplorationPropertiesPoshLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "Properties PoSh:"
    Location = @{ X = 0
                  Y = $Section3QueryExplorationRPCWMILabel.location.Y + $Section3QueryExplorationRPCWMILabel.Size.Height }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationPropertiesPoshLabel)


$Section3QueryExplorationPropertiesPoshTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationPropertiesPoshLabel.Location.X + $Section3QueryExplorationPropertiesPoshLabel.Size.Width + $($FormScale * 5)
                  Y = $Section3QueryExplorationPropertiesPoshLabel.Location.Y - $($FormScale * 3) }
    Size     = @{ Width  = $FormScale * 195
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Backcolor = 'White'
    ReadOnly = $true
    Add_MouseEnter = { $This.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $This.size = @{ Width  = $FormScale * 195 } }
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationPropertiesPoshTextBox)


$Section3QueryExplorationPropertiesWMILabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "Properties WMI:"
    Location = @{ X = 0
                  Y = $Section3QueryExplorationPropertiesPoshLabel.location.Y + $Section3QueryExplorationPropertiesPoshLabel.Size.Height }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationPropertiesWMILabel)


$Section3QueryExplorationPropertiesWMITextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationPropertiesWMILabel.Location.X + $Section3QueryExplorationPropertiesWMILabel.Size.Width + $($FormScale * 5)
                  Y = $Section3QueryExplorationPropertiesWMILabel.Location.Y - $($FormScale * 3) }
    Size     = @{ Width  = $FormScale * 195
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Backcolor = 'White'
    ReadOnly = $true
    Add_MouseEnter = { $This.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $This.size = @{ Width  = $FormScale * 195 } }
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationPropertiesWMITextBox)


$Section3QueryExplorationWinRSWmicLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "WinRS WMIC:"
    Location = @{ X = 0
                  Y = $Section3QueryExplorationPropertiesWMILabel.location.Y + $Section3QueryExplorationPropertiesWMILabel.Size.Height }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationWinRSWmicLabel)


$Section3QueryExplorationWinRSWmicTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationWinRSWmicLabel.Location.X + $Section3QueryExplorationWinRSWmicLabel.Size.Width + $($FormScale * 5)
                  Y = $Section3QueryExplorationWinRSWmicLabel.Location.Y - $($FormScale * 3) }
    Size     = @{ Width  = $FormScale * 195
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Backcolor = 'White'
    ReadOnly = $true
    Add_MouseEnter = { $This.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $This.size = @{ Width  = $FormScale * 195 } }
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationWinRSWmicTextBox)


$Section3QueryExplorationWinRSCmdLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "WinRS Cmd:"
    Location = @{ X = 0
                  Y = $Section3QueryExplorationWinRSWmicLabel.location.Y + $Section3QueryExplorationWinRSWmicLabel.Size.Height }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationWinRSCmdLabel)


$Section3QueryExplorationWinRSCmdTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationWinRSCmdLabel.Location.X + $Section3QueryExplorationWinRSCmdLabel.Size.Width + $($FormScale * 5)
                  Y = $Section3QueryExplorationWinRSCmdLabel.Location.Y - $($FormScale * 3) }
    Size     = @{ Width  = $FormScale * 195
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Backcolor = 'White'
    ReadOnly = $true
    Add_MouseEnter = { $This.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $This.size = @{ Width  = $FormScale * 195 } }
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationWinRSCmdTextBox)


















$Section3QueryExplorationSmbPoshLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "SMB PoSh:"
    Location = @{ X = 0
                  Y = $Section3QueryExplorationWinRSCmdLabel.location.Y + $Section3QueryExplorationWinRSCmdLabel.Size.Height }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationSmbPoshLabel)


$Section3QueryExplorationSmbPoshTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationSmbPoshLabel.Location.X + $Section3QueryExplorationSmbPoshLabel.Size.Width + $($FormScale * 5)
                  Y = $Section3QueryExplorationSmbPoshLabel.Location.Y - $($FormScale * 3) }
    Size     = @{ Width  = $FormScale * 195
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Backcolor = 'White'
    ReadOnly = $true
    Add_MouseEnter = { $This.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $this.size = @{ Width  = $FormScale * 195 } }
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationSmbPoshTextBox)


$Section3QueryExplorationSmbWmiLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "SMB WMI:"
    Location = @{ X = 0
                  Y = $Section3QueryExplorationSmbPoshLabel.location.Y + $Section3QueryExplorationSmbPoshLabel.Size.Height }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationSmbWmiLabel)


$Section3QueryExplorationSmbWmiTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationSmbWmiLabel.Location.X + $Section3QueryExplorationSmbWmiLabel.Size.Width + $($FormScale * 5)
                  Y = $Section3QueryExplorationSmbWmiLabel.Location.Y - $($FormScale * 3) }
    Size     = @{ Width  = $FormScale * 195
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Backcolor = 'White'
    ReadOnly = $true
    Add_MouseEnter = { $This.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $this.size = @{ Width  = $FormScale * 195 } }
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationSmbWmiTextBox)


$Section3QueryExplorationSmbCmdLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "SMB Cmd:"
    Location = @{ X = 0
                  Y = $Section3QueryExplorationSmbWmiLabel.location.Y + $Section3QueryExplorationSmbWmiLabel.Size.Height }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationSmbCmdLabel)


$Section3QueryExplorationSmbCmdTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationSmbCmdLabel.Location.X + $Section3QueryExplorationSmbCmdLabel.Size.Width + $($FormScale * 5)
                  Y = $Section3QueryExplorationSmbCmdLabel.Location.Y - $($FormScale * 3) }
    Size     = @{ Width  = $FormScale * 195
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Backcolor = 'White'
    ReadOnly = $true
    Add_MouseEnter = { $This.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $this.size = @{ Width  = $FormScale * 195 } }
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationSmbCmdTextBox)



$Section3QueryExplorationSshLinuxLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "SSH Linux:"
    Location = @{ X = 0
                  Y = $Section3QueryExplorationSmbCmdLabel.location.Y + $Section3QueryExplorationSmbCmdLabel.Size.Height }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationSshLinuxLabel)


$Section3QueryExplorationSshLinuxTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationSshLinuxLabel.Location.X + $Section3QueryExplorationSshLinuxLabel.Size.Width + $($FormScale * 5)
                  Y = $Section3QueryExplorationSshLinuxLabel.Location.Y - $($FormScale * 3) }
    Size     = @{ Width  = $FormScale * 195
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Backcolor = 'White'
    ReadOnly = $true
    Add_MouseEnter = { $This.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $this.size = @{ Width  = $FormScale * 195 } }
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationSshLinuxTextBox)






























$Section3QueryExplorationDescriptionPanel = New-Object System.Windows.Forms.Panel -Property @{
    Location   = @{ X = $Section3QueryExplorationNameTextBox.Location.X + $Section3QueryExplorationNameTextBox.Size.Width + $($FormScale * 10)
                    Y = $Section3QueryExplorationNameTextBox.Location.Y }
    Size       = @{ Width  = $FormScale * 428
                    Height = $FormScale * 300 }
    BorderStyle = 'FixedSingle'
}
            $Section3QueryExplorationDescriptionRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
                Font        = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                Backcolor   = 'White'
                Multiline   = $True
                ScrollBars  = 'Vertical'
                WordWrap    = $True
                ReadOnly    = $true
                Dock        = 'Fill'
                BorderStyle = 'None'
                ShortcutsEnabled = $true
            }
            $Section3QueryExplorationDescriptionPanel.Controls.Add($Section3QueryExplorationDescriptionRichTextbox)
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationDescriptionPanel)


$Section3QueryExplorationTagWordsLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "Tags: "
    Left     = $Section3QueryExplorationDescriptionPanel.Location.X + ($FormScale * 1)
    Top      = $Section3QueryExplorationDescriptionPanel.location.Y + $Section3QueryExplorationDescriptionPanel.Size.Height + $($FormScale * 5)
    AutoSize = $true
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationTagWordsLabel)


$Section3QueryExplorationTagWordsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left   = $Section3QueryExplorationTagWordsLabel.Left + $Section3QueryExplorationTagWordsLabel.Width + $($FormScale * 5)
    Top    = $Section3QueryExplorationTagWordsLabel.Top
    Width  = $FormScale * 200
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Backcolor = 'White'
    ReadOnly = $true
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationTagWordsTextBox)


$Section3QueryExplorationEditCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
    Text  = "Edit"
    Left  = $FormScale * 580
    Top   = $Section3QueryExplorationTagWordsTextBox.Top
    Font  = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,2,1)
    Checked   = $false
    AutoSize  = $true
    Add_Click = $Section3QueryExplorationEditCheckBoxAdd_Click
}
# Note: The button is added/removed in other parts of the code


$Section3QueryExplorationSaveButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Locked'
    Left   = $FormScale * 638
    Top    = $Section3QueryExplorationEditCheckBox.Top
    Width  = $FormScale * 100
    Height = $FormScale * 22
    Add_Click = $Section3QueryExplorationSaveButtonAdd_Click
}
Apply-CommonButtonSettings -Button $Section3QueryExplorationSaveButton
# Note: The button is added/removed in other parts of the code


$Section3QueryExplorationViewScriptButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'View Script'
    Left   = $FormScale * 500
    Top    = $Section3QueryExplorationEditCheckBox.Top
    Width  = $FormScale * $Column5BoxWidth
    Height = $FormScale * $Column5BoxHeight
    Add_Click = $Section3QueryExplorationViewScriptButtonAdd_Click
}
Apply-CommonButtonSettings -Button $Section3QueryExplorationViewScriptButton



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUjpyRfswTN47mOBw+1Q7bv22x
# Ko2gggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUASk9QeiFKUvXQ/4agwSw3pfvWtgwDQYJKoZI
# hvcNAQEBBQAEggEAcZ0qW1FYdyHpMUvYZL5jkllHtYpZ6Fl0qAXg1PoSwtNncRiF
# ueCK5V7gqYY4HA9Lt6nnsEbdq7lORTp2Spf5ocfk0rYJsBLEm+JHi0O6pJuIZdL/
# QhQji9Rh8n4w+BrDtlRIQ3tIJE9uercCebnFEONpcMJyavCTkNmmj6uQbHGMqqFl
# 7YNpEnTpAhb6Kd2pf3/WM40iD9bJ8F0T8Pn31a82cm1BNnbk3wjTs+zeDa/BqS6U
# KPqull23KpvHWmbWbXX7/mWj09bTh1wvRkRyRUxY5SXFchQh61VKevcFr7gcdUnY
# 0h2y0EzQFKcxYaZYu8xFyunMF+R8rS/33YW4Pg==
# SIG # End signature block
