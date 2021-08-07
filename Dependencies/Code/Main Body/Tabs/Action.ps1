Update-FormProgress "$Dependencies\Code\Tree View\Create-TreeViewCheckBoxArray.ps1"
. "$Dependencies\Code\Tree View\Create-TreeViewCheckBoxArray.ps1"

Update-FormProgress "$Dependencies\Code\Tree View\Computer\ComputerNodeSelectedLessThanOne.ps1"
. "$Dependencies\Code\Tree View\Computer\ComputerNodeSelectedLessThanOne.ps1"

Update-FormProgress "$Dependencies\Code\Tree View\Computer\ComputerNodeSelectedMoreThanOne.ps1"
. "$Dependencies\Code\Tree View\Computer\ComputerNodeSelectedMoreThanOne.ps1"

Update-FormProgress "$Dependencies\Code\Tree View\Computer\Verify-Action.ps1"
. "$Dependencies\Code\Tree View\Computer\Verify-Action.ps1"

$Section3ActionTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = "Action"
    Left   = $FormScale * 3
    Top    = 0
    Height = $FormScale * 124
    Width  = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
}
$MainRightTabControl.Controls.Add($Section3ActionTab)


<# TODO: Needs more testing
batman
# Used to verify settings before capturing memory as this can be quite resource exhaustive
# Contains various checks to ensure that adequate resources are available on the remote and local hosts
Update-FormProgress "$Dependencies\Code\Execution\Action\Launch-RekallWinPmemForm.ps1"
. "$Dependencies\Code\Execution\Action\Launch-RekallWinPmemForm.ps1"


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\RekallWinPmemMemoryCaptureButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\RekallWinPmemMemoryCaptureButton.ps1"
$RekallWinPmemMemoryCaptureButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Memory Capture"
    Left   = $FormScale * 3
    Top    = $FormScale * 5
    Width  = $FormScale * 124
    Height = $FormScale * 22
    Add_MouseHover = $RekallWinPmemMemoryCaptureButtonAdd_MouseHover
    Add_Click      = $RekallWinPmemMemoryCaptureButtonAdd_Click
}
CommonButtonSettings -Button $RekallWinPmemMemoryCaptureButton


# Test if the External Programs directory is present; if it's there load the tab
if (Test-Path "$ExternalPrograms\WinPmem\WinPmem.exe") { $Section3ActionTab.Controls.Add($RekallWinPmemMemoryCaptureButton) }

#>



Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\ComputerListRDPButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\ComputerListRDPButton.ps1"

Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\ComputerListPSSessionButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\ComputerListPSSessionButton.ps1"

Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\ComputerListPSSessionPivotButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\ComputerListPSSessionPivotButton.ps1"

Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\ComputerListSSHButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\ComputerListSSHButton.ps1"

Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\ComputerListPsExecButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\ComputerListPsExecButton.ps1"

Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\EventViewerButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\EventViewerButton.ps1"

# Rolls the credenaisl: 250 characters of random: abcdefghiklmnoprstuvwxyzABCDEFGHKLMNOPRSTUVWXYZ1234567890
Update-FormProgress "$Dependencies\Code\Credential Management\Generate-NewRollingPassword.ps1"
. "$Dependencies\Code\Credential Management\Generate-NewRollingPassword.ps1"

# Used to create new credentials (Get-Credential), create a log entry, and save an encypted local copy
Update-FormProgress "$Dependencies\Code\Credential Management\Create-NewCredentials.ps1"
. "$Dependencies\Code\Credential Management\Create-NewCredentials.ps1"
# Encrypt an exported credential object
# The Export-Clixml cmdlet encrypts credential objects by using the Windows Data Protection API.
# The encryption ensures that only your user account on only that computer can decrypt the contents of the
# credential object. The exported CLIXML file can't be used on a different computer or by a different user.

# Code to launch the Credential Management Form
# Provides the abiltiy to select create, select, and save credentials
# Provides the option to enable password auto rolling
Update-FormProgress "$Dependencies\Code\Credential Management\Launch-CredentialManagementForm.ps1"
. "$Dependencies\Code\Credential Management\Launch-CredentialManagementForm.ps1"


$ManageCredentialsGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Left   = $FormScale + 3
    Top    = 0
    Width  = $FormScale * 126 + ($FormScale + 5)
    Height = $FormScale * 53
}
            Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\ProvideCredentialsButton.ps1"
            . "$Dependencies\Code\System.Windows.Forms\Button\ProvideCredentialsButton.ps1"
            $ProvideCredentialsButton = New-Object System.Windows.Forms.Button -Property @{
                Text   = "Manage Credentials"
                Left   = $FormScale * 3
                Top    = $FormScale * 10
                Width  = $FormScale * 122
                Height = $FormScale * 22
                Add_Click      = $ProvideCredentialsButtonAdd_Click
                Add_MouseHover = $ProvideCredentialsButtonAdd_MouseHover
            }
            $ManageCredentialsGroupBox.Controls.Add($ProvideCredentialsButton)
            CommonButtonSettings -Button $ProvideCredentialsButton


            Update-FormProgress "$Dependencies\Code\System.Windows.Forms\CheckBox\ComputerListProvideCredentialsCheckBox.ps1"
            . "$Dependencies\Code\System.Windows.Forms\CheckBox\ComputerListProvideCredentialsCheckBox.ps1"
            $script:ComputerListProvideCredentialsCheckBox = New-Object System.Windows.Forms.CheckBox -Property @{
                Text    = "Use Selected Creds"
                Left    = $FormScale * 3 + 1
                Top     = $ProvideCredentialsButton.Top + $ProvideCredentialsButton.Height + ($FormScale * 3)
                Width   = $FormScale * 124
                Height  = $FormScale * 15
                Checked = $false
                Font    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                Add_Click      = $ComputerListProvideCredentialsCheckBoxAdd_Click
                Add_MouseHover = $ComputerListProvideCredentialsCheckBoxAdd_MouseHover
            }
            $ManageCredentialsGroupBox.Controls.Add($script:ComputerListProvideCredentialsCheckBox)
  
$Section3ActionTab.Controls.Add($ManageCredentialsGroupBox)


$PivotExecutionGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Left   = $ManageCredentialsGroupBox.Left
    Top    = $ManageCredentialsGroupBox.Top + $ManageCredentialsGroupBox.Height + ($FormScale + 2)
    Width  = $FormScale * 126 + ($FormScale + 5)
    Height = $FormScale * 73
}

            Update-FormProgress "$Dependencies\Code\Main Body\Launch-ManagePortProxy.ps1"
            . "$Dependencies\Code\Main Body\Launch-ManagePortProxy.ps1"
            $ManageWindowsPortProxyButton = New-Object System.Windows.Forms.Button -Property @{
                Text   = "Manage Port Proxy"
                Left   = $FormScale * 3
                Top    = $FormScale * 10
                Width  = $FormScale * 122
                Height = $FormScale * 22
                Add_Click      = $ManageWindowsPortProxyButtonAdd_Click
                #Add_MouseHover = $ManageWindowsPortProxyButtonAdd_MouseHover
            }
            $PivotExecutionGroupBox.Controls.Add($ManageWindowsPortProxyButton)
            CommonButtonSettings -Button $ManageWindowsPortProxyButton            


            $script:ComputerListPivotExecutionCheckbox = New-Object System.Windows.Forms.Checkbox -Property @{
                Text    = "Pivot Thru (WinRM)"
                Left    = $FormScale * 3
                Top     = $ManageWindowsPortProxyButton.Top + $ManageWindowsPortProxyButton.Height + ($FormScale * 3)
                Width   = $FormScale * 120
                Height  = $FormScale * 15
                Checked = $false
                Add_Click = {
                    if ( $script:ComputerListPivotExecutionTextBox.Text -eq '' ) {
                        [System.Windows.Forms.MessageBox]::Show("Ensure to enter an endpoint hostname or IP address below.`n`nWinRM commands will be sent to and exected by this endpoint, then returned to PoSh-EasyWin. This can be used to pivot to networks that this localhost does not have access to, but where the other may. Data can be collected, files sent or received, and actions taken from that endpoint's perspecitve.","PoSh-EasyWin - Pivot Execution (WinRM)",'Ok',"Info")
                        $this.checked = $false
                        $script:ComputerListPivotExecutionTextBox.enabled = $true
                    }
                    elseif ( $script:ComputerListPivotExecutionTextBox.Text -ne '' -and $This.checked -eq $false) {
                        $this.checked = $false
                        $script:ComputerListPivotExecutionTextBox.enabled = $true
                    }
                    else {
                        [System.Windows.Forms.MessageBox]::Show("WinRM commands will be sent to and executed by '$($script:ComputerListPivotExecutionTextBox.text)', then returned to PoSh-EasyWin. This can be used to pivot to networks that this localhost does not have access to, but '$($script:ComputerListPivotExecutionTextBox.text)' may be able to access. Data can be collected, files sent or received, and actions taken from the perspecitve of '$($script:ComputerListPivotExecutionTextBox.text)'.`n`nAre you sure you want to pivot commands through '$($script:ComputerListPivotExecutionTextBox.text)'?`n`nNote: Integration with Credential Auto-Rollover has not been fully tested yet.","PoSh-EasyWin - Pivot Execution (WinRM)",'Ok',"Info")
                        if ($this.Checked){$this.checked = $true}
                        else {$this.checked = $false}
                        $script:ComputerListPivotExecutionTextBox.enabled = $true
                        $script:ComputerListPivotExecutionTextBox.text | Set-Content "$PoShHome\Settings\Pivot Thru Endpoint (WinRM).txt"
                    }

                    if ($this.checked -eq $true) { 
                        $MainLeftTabControl.Controls.Remove($Section1InteractionsTab)
                        #$MainLeftTabControl.Controls.Remove($Section1EnumerationTab)

                        $MainLeftCollectionsTabControl.Controls.Remove($Section1AccountsTab)
                        $MainLeftCollectionsTabControl.Controls.Remove($Section1EventLogsTab)
                        $MainLeftCollectionsTabControl.Controls.Remove($Section1RegistryTab)
                        $MainLeftCollectionsTabControl.Controls.Remove($Section1FileSearchTab)
                        $MainLeftCollectionsTabControl.Controls.Remove($Section1NetworkConnectionsSearchTab)
                        $MainLeftCollectionsTabControl.Controls.Remove($Section1PacketCaptureTab)
                        Deselect-AllCommands

                        $CommandsViewFilterComboBox.text = 'Pivot Thru (WinRM)'
                        $CommandsViewFilterComboBox.enabled = $false
                        $CommandsViewProtocolsUsedRadioButton.enabled = $false
                        $CommandsViewCommandNamesRadioButton.enabled = $false
                
                        $script:CommandsTreeView.Nodes.Clear()
                        Initialize-CommandTreeNodes
                        View-CommandTreeNodeMethod
                        Update-TreeNodeCommandState

                        $script:ComputerListPivotExecutionTextBox.enabled = $false
                        # $script:EnumerationPortScanMonitorJobsCheckbox.checked = $true
                        # $script:EnumerationPortScanMonitorJobsCheckbox.enabled = $false
                    }
                    elseif ($this.checked -eq $false) { 
                        $MainLeftTabControl.Controls.Remove($Section1OpNotesTab)
                        $MainLeftTabControl.Controls.Remove($MainLeftInfoTab)
                        $MainLeftTabControl.Controls.Add($Section1InteractionsTab)
                        #$MainLeftTabControl.Controls.Add($Section1EnumerationTab)
                        $MainLeftTabControl.Controls.Add($Section1OpNotesTab)
                        $MainLeftTabControl.Controls.Add($MainLeftInfoTab)

                        $MainLeftCollectionsTabControl.Controls.Add($Section1AccountsTab)
                        $MainLeftCollectionsTabControl.Controls.Add($Section1EventLogsTab)
                        $MainLeftCollectionsTabControl.Controls.Add($Section1RegistryTab)
                        $MainLeftCollectionsTabControl.Controls.Add($Section1FileSearchTab)
                        $MainLeftCollectionsTabControl.Controls.Add($Section1NetworkConnectionsSearchTab)
                        $MainLeftCollectionsTabControl.Controls.Add($Section1PacketCaptureTab)

                        $CommandsViewFilterComboBox.text = 'All (WinRM,RPC,SMB,SSH)'
                        $CommandsViewFilterComboBox.enabled = $true
                        $CommandsViewProtocolsUsedRadioButton.enabled = $true
                        $CommandsViewCommandNamesRadioButton.enabled = $true
                
                        $script:CommandsTreeView.Nodes.Clear()
                        Initialize-CommandTreeNodes
                        View-CommandTreeNodeMethod
                        Update-TreeNodeCommandState

                        $script:ComputerListPivotExecutionTextBox.enabled = $true
                        # $script:EnumerationPortScanMonitorJobsCheckbox.checked = $false
                        # $script:EnumerationPortScanMonitorJobsCheckbox.enabled = $true
                    }
                }
            }
            $PivotExecutionGroupBox.Controls.Add($script:ComputerListPivotExecutionCheckbox)


            $script:ComputerListPivotExecutionTextBox = New-Object System.Windows.Forms.TextBox -Property @{
                Left    = $FormScale * 3
                Top     = $script:ComputerListPivotExecutionCheckbox.Top + $script:ComputerListPivotExecutionCheckbox.Height + ($FormScale * 3)
                Width   = $FormScale * 122
                Height  = $FormScale * 22 - 5
            }
            $PivotExecutionGroupBox.Controls.Add($script:ComputerListPivotExecutionTextBox)

            if (Test-Path "$PoShHome\Settings\Pivot Thru Endpoint (WinRM).txt") { 
                $script:ComputerListPivotExecutionTextBox.text = Get-Content "$PoShHome\Settings\Pivot Thru Endpoint (WinRM).txt"
            }

            $script:CommandsTreeView.Nodes.Clear()
            Initialize-CommandTreeNodes
            View-CommandTreeNodeMethod
            Update-TreeNodeCommandState

$Section3ActionTab.Controls.Add($PivotExecutionGroupBox)


$UseDNSHostnameGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Left   = $ManageCredentialsGroupBox.Left
    Top    = $PivotExecutionGroupBox.Top + $PivotExecutionGroupBox.Height + ($FormScale + 2)
    Width  = $FormScale * 126 + ($FormScale + 5)
    Height = $FormScale * 27
}
            $script:ComputerListUseDNSCheckbox = New-Object System.Windows.Forms.Checkbox -Property @{
                Text    = "Use DNS Hostname"
                Left    = $FormScale * 3
                Top     = $FormScale * 10
                Width   = $FormScale * 122
                Height  = $FormScale * 15
                Checked = $true
            }
            $UseDNSHostnameGroupBox.Controls.Add($script:ComputerListUseDNSCheckbox)

$Section3ActionTab.Controls.Add($UseDNSHostnameGroupBox)


$ExecutionModeGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Left   = $ManageCredentialsGroupBox.Left
    Top    = $UseDNSHostnameGroupBox.Top + $UseDNSHostnameGroupBox.Height + ($FormScale + 2)
    Width  = $FormScale * 126 + ($FormScale + 5)
    Height = $FormScale * 93
}
            Update-FormProgress "$Dependencies\Code\System.Windows.Forms\ComboBox\CommandTreeViewQueryMethodSelectionComboBox.ps1"
            . "$Dependencies\Code\System.Windows.Forms\ComboBox\CommandTreeViewQueryMethodSelectionComboBox.ps1"
            $script:CommandTreeViewQueryMethodSelectionComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
                Left   = $FormScale * 3
                Top    = $FormScale * 10
                Height = $FormScale * 22
                Width  = $FormScale * 122
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor     = 'Black'
                DropDownStyle = 'DropDownList'
                Add_SelectedIndexChanged = {
                    & $script:CommandTreeViewQueryMethodSelectionComboBoxAdd_SelectedIndexChanged
                    #$This.Text | Set-Content "$PoShHome\Settings\Script Execution Mode.txt" -Force

                    # if ($this.SelectedItem -eq 'Monitor Jobs') {
                    #     $Section3ActionTab.Controls.Add($script:OptionJobTimeoutSelectionLabel)
                    #     $Section3ActionTab.Controls.Add($script:OptionJobTimeoutSelectionComboBox)
                    # }
                    # else {
                    #     $Section3ActionTab.Controls.Remove($script:OptionJobTimeoutSelectionLabel)
                    #     $Section3ActionTab.Controls.Remove($script:OptionJobTimeoutSelectionComboBox)
                    # }
                }
            }
            $QueryMethodSelectionList = @(
                'Monitor Jobs',
                'Individual Execution',
                'Session Based'
                #'Compiled Script'
            )
            Foreach ($QueryMethod in $QueryMethodSelectionList) { $script:CommandTreeViewQueryMethodSelectionComboBox.Items.Add($QueryMethod) }
            if (Test-Path "$PoShHome\Settings\Script Execution Mode.txt") { $script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem = Get-Content "$PoShHome\Settings\Script Execution Mode.txt" }
            else { $script:CommandTreeViewQueryMethodSelectionComboBox.SelectedIndex = 0 }
            $ExecutionModeGroupBox.Controls.Add($script:CommandTreeViewQueryMethodSelectionComboBox)


            $script:OptionJobTimeoutSelectionLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Job Timeout:"
                Left   = $FormScale * 3
                Top    = $script:CommandTreeViewQueryMethodSelectionComboBox.Top + $script:CommandTreeViewQueryMethodSelectionComboBox.Height + ($FormScale * 6)
                Width  = $FormScale * 67
                Height = $FormScale * 15
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            }
            $ExecutionModeGroupBox.Controls.Add($script:OptionJobTimeoutSelectionLabel)


            Update-FormProgress "$Dependencies\Code\System.Windows.Forms\ComboBox\OptionJobTimeoutSelectionComboBox.ps1"
            . "$Dependencies\Code\System.Windows.Forms\ComboBox\OptionJobTimeoutSelectionComboBox.ps1"
            $script:OptionJobTimeoutSelectionComboBox = New-Object -TypeName System.Windows.Forms.Combobox -Property @{
                Text   = $JobTimeOutSeconds
                Left   = $script:OptionJobTimeoutSelectionLabel.Left + $script:OptionJobTimeoutSelectionLabel.Width + $($FormScale * 5)
                Top    = $script:OptionJobTimeoutSelectionLabel.Top - $($FormScale * 3)
                Width  = $FormScale * 50
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,2,0)
                AutoCompleteMode = "SuggestAppend"
                Add_MouseHover   = $script:OptionJobTimeoutSelectionComboBoxAdd_MouseHover
                Add_SelectedIndexChanged = { $This.Text | Set-Content "$PoShHome\Settings\Job Timeout.txt" -Force }
            }
            $JobTimesAvailable = @(15,30,45,60,120,180,240,300,600)
            ForEach ($Item in $JobTimesAvailable) { $script:OptionJobTimeoutSelectionComboBox.Items.Add($Item) }
            if (Test-Path "$PoShHome\Settings\Job Timeout.txt") { $script:OptionJobTimeoutSelectionComboBox.text = Get-Content "$PoShHome\Settings\Job Timeout.txt" }
            $ExecutionModeGroupBox.Controls.Add($script:OptionJobTimeoutSelectionComboBox)


            Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\ComputerListExecuteButton.ps1"
            . "$Dependencies\Code\System.Windows.Forms\Button\ComputerListExecuteButton.ps1"
            $script:ComputerListExecuteButton = New-Object System.Windows.Forms.Button -Property @{
                Text    = "Execute Script"
                Left    = $FormScale * 3
                Top     = $script:OptionJobTimeoutSelectionLabel.Top + $script:OptionJobTimeoutSelectionLabel.Height + ($FormScale * 1)
                Width   = $FormScale * 122
                Height  = $FormScale * (22 * 2) - 10
                Enabled = $false
                Add_MouseHover = $script:ComputerListExecuteButtonAdd_MouseHover
            }
            ### $script:ComputerListExecuteButton.Add_Click($ExecuteScriptHandler) ### Is located lower in the script
            $ExecutionModeGroupBox.Controls.Add($script:ComputerListExecuteButton)
            CommonButtonSettings -Button $script:ComputerListExecuteButton
            
$Section3ActionTab.Controls.Add($ExecutionModeGroupBox)





