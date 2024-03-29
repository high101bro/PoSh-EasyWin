####################################################################################################
# ScriptBlocks
####################################################################################################
Update-FormProgress "Action.ps1 - ScriptBlocks"

$OptionJobTimeoutSelectionComboBoxAdd_MouseHover = {
    Show-ToolTip -Title "Sets the Background Job Timeout" -Icon "Info" -Message @"
+  Queries are threaded and not executed serially like typical scripts.
+  This is done in command order for each host checked.
"@
}

$CommandTreeViewQueryMethodSelectionComboBoxAdd_SelectedIndexChanged = {
    $SelectedIndexTemp = $this.SelectedIndex
    #deprecated
    # if ( ($EventLogRPCRadioButton.checked -or $ExternalProgramsRPCRadioButton.checked -or $script:RpcCommandCount -gt 0 -or $script:SmbCommandCount -gt 0) -and $this.SelectedItem -eq 'Session Based' ) {
    #     $MessageBox = [System.Windows.Forms.MessageBox]::Show("The '$($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem)' mode does not support the RPC and SMB protocols.`nThe 'Monitor Jobs' collection mode supports the RPC, SMB, and WinRM protocols - but may be slower and noisier on the network.`n`nDo you want to change to 'Session Based' collection using the WinRM protocol?","Protocol Alert",[System.Windows.Forms.MessageBoxButtons]::OKCancel)
    #     switch ($MessageBox){
    #         "OK" {
    #             $StatusListBox.Items.Clear()
    #             $StatusListBox.Items.Add("Event Log Protocol Set To WinRM")
    #             $EventLogWinRMRadioButton.checked         = $true
    #             $ExternalProgramsWinRMRadioButton.checked = $true

    #             $RpcCommandNodesRemoved = @()
    #             $SmbCommandNodesRemoved = @()
    #             [System.Windows.Forms.TreeNodeCollection]$AllCommandsNode = $script:CommandsTreeView.Nodes
    #             foreach ($root in $AllCommandsNode) {
    #                 foreach ($Category in $root.Nodes) {
    #                     foreach ($Entry in $Category.nodes) {
    #                         if ($Entry.Checked -and $Entry.Text -match '[\[(]rpc[)\]]') {
    #                             $root.Checked     = $false
    #                             $Category.Checked = $false
    #                             $Entry.Checked    = $false
    #                             $RpcCommandNodesRemoved += $Entry
    #                         }
    #                         elseif ($Entry.Checked -and $Entry.Text -match '[\[(]smb[)\]]') {
    #                             $root.Checked     = $false
    #                             $Category.Checked = $false
    #                             $Entry.Checked    = $false
    #                             $SmbCommandNodesRemoved += $Entry
    #                         }
    #                     }
    #                 }
    #             }
    #             Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes

    #             # This brings specific tabs to the forefront/front view
    #             $MainLeftTabControl.SelectedTab = $Section1SearchTab
    #             $InformationTabControl.SelectedTab = $Section3ResultsTab

    #             #Removed For Testing#$ResultsListBox.Items.Clear()
    #             if ($RpcCommandNodesRemoved.count -gt 0) {
    #                 $ResultsListBox.Items.Add("The following RPC queries have been unchecked:")
    #                 foreach ($Entry in $RpcCommandNodesRemoved) {
    #                     $ResultsListBox.Items.Add("   $($Entry.Text)")
    #                 }
    #             }
    #             if ($SmbCommandNodesRemoved.count -gt 0) {
    #                 $ResultsListBox.Items.Add("The following SMB queries have been unchecked:")
    #                 foreach ($Entry in $SmbCommandNodesRemoved) {
    #                     $ResultsListBox.Items.Add("   $($Entry.Text)")
    #                 }
    #             }


    #         }
    #         "Cancel" {
    #             $this.SelectedIndex = 0 #'Monitor Jobs'
    #          }
    #     }

    # }
}

$ProvideCredentialsButtonAdd_Click = {
    $InformationTabControl.SelectedTab = $Section3ResultsTab
    Show-CredentialManagementForm
}

$ProvideCredentialsButtonAdd_MouseHover = {
    Show-ToolTip -Title "Specify Credentials" -Icon "Info" -Message @"
+  Credentials are stored in memory as credential objects.
+  Credentials stored on disk as XML files are encrypted credential objects using Windows Data Protection API.
    This encryption ensures that only your user account on only that computer can decrypt the contents of the
    credential object. The exported CLIXML file can't be used on a different computer or by a different user.
+  If checked, credentials are applied to:
    RDP, PSSession, PSExec
"@
}

function Set-PivotThru {
    $MainLeftTabControl.Controls.Remove($Section1SearchTab)
    $MainLeftTabControl.Controls.Remove($Section1InteractionsTab)
    $MainLeftTabControl.Controls.Remove($Section1EnumerationTab)
    $MainLeftTabControl.Controls.Remove($Section1OpNotesTab)
    $MainLeftTabControl.Controls.Remove($MainLeftInfoTab)

    # $MainLeftTabControl.Controls.Add($Section1SearchTab)
    # $MainLeftTabControl.Controls.Add($Section1InteractionsTab)
    $MainLeftTabControl.Controls.Add($Section1EnumerationTab)
    $MainLeftTabControl.Controls.Add($Section1OpNotesTab)
    $MainLeftTabControl.Controls.Add($MainLeftInfoTab)

    Deselect-AllCommands

    $CommandsViewFilterComboBox.text = 'Pivot Thru (WinRM)'
    $CommandsViewFilterComboBox.enabled = $false
    $CommandsViewProtocolsUsedRadioButton.enabled = $false
    $CommandsViewCommandNamesRadioButton.enabled = $false

    $script:CommandsTreeView.Nodes.Clear()
    Initialize-TreeViewCommand
    View-TreeViewCommandMethod
    Update-TreeViewCommand

    $script:ComputerListPivotExecutionTextBox.enabled = $false
    # $script:EnumerationPortScanMonitorJobsCheckbox.checked = $true
    # $script:EnumerationPortScanMonitorJobsCheckbox.enabled = $false
}

$ComputerListPivotExecutionCheckboxAdd_Click = {
    $This.Checked | Set-Content "$PewSettings\Pivot Thru Endpoint Checked.txt" -Force

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
        $script:ComputerListPivotExecutionTextBox.text | Set-Content "$PewSettings\Pivot Thru Endpoint Name.txt"
    }

    if ($this.checked -eq $true) {
        Set-PivotThru
    }
    elseif ($this.checked -eq $false) {
        $MainLeftTabControl.Controls.Remove($Section1SearchTab)
        $MainLeftTabControl.Controls.Remove($Section1InteractionsTab)
        $MainLeftTabControl.Controls.Remove($Section1EnumerationTab)
        $MainLeftTabControl.Controls.Remove($Section1OpNotesTab)
        $MainLeftTabControl.Controls.Remove($MainLeftInfoTab)
    
        $MainLeftTabControl.Controls.Add($Section1SearchTab)
        $MainLeftTabControl.Controls.Add($Section1InteractionsTab)
        $MainLeftTabControl.Controls.Add($Section1EnumerationTab)
        $MainLeftTabControl.Controls.Add($Section1OpNotesTab)
        $MainLeftTabControl.Controls.Add($MainLeftInfoTab)


        $CommandsViewFilterComboBox.text = 'All (WinRM,RPC,SMB,SSH)'
        $CommandsViewFilterComboBox.enabled = $true
        $CommandsViewProtocolsUsedRadioButton.enabled = $true
        $CommandsViewCommandNamesRadioButton.enabled = $true

        $script:CommandsTreeView.Nodes.Clear()
        Initialize-TreeViewCommand
        View-TreeViewCommandMethod
        Update-TreeViewCommand

        $script:ComputerListPivotExecutionTextBox.enabled = $true
        # $script:EnumerationPortScanMonitorJobsCheckbox.checked = $false
        # $script:EnumerationPortScanMonitorJobsCheckbox.enabled = $true
    }
}

$ComputerListProvideCredentialsCheckBoxAdd_Click = {
    if ($script:ComputerListProvideCredentialsCheckBox.Checked -and (Test-Path "$PewSettings\Use Selected Credentials.txt")) {
        $SelectedCredentialName = Get-Content "$PewSettings\Use Selected Credentials.txt"
        $script:SelectedCredentialPath = Get-ChildItem "$CredentialManagementPath\$SelectedCredentialName"
        $script:Credential = Import-CliXml $script:SelectedCredentialPath
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Credentials:  $SelectedCredentialName.xml")
    }
    elseif ($script:ComputerListProvideCredentialsCheckBox.Checked -and -not (Test-Path "$PewSettings\Use Selected Credentials.txt")) {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Credentials:  There are no credentials stored")
        Show-CredentialManagementForm
    }
    else {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Credentials:  $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)")
    }
}

$ComputerListProvideCredentialsCheckBoxAdd_MouseHover = {
    Show-ToolTip -Title "Specify Credentials" -Icon "Info" -Message @"
+  Credentials are stored in memory as credential objects.
+  Credentials stored on disk as XML files are encrypted credential objects using Windows Data Protection API.
    This encryption ensures that only your user account on only that computer can decrypt the contents of the
    credential object. The exported CLIXML file can't be used on a different computer or by a different user.
+  To enable auto password rolling, both this checkbox and the one in Automatic Password Rolling must be checked.
+  If checked, credentials are applied to:
    RDP, PSSession, PSExec
"@
}


####################################################################################################
# WinForms
####################################################################################################
Update-FormProgress "Action.ps1 - WinForms"

$Section3ActionTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = "Action  "
    Left   = $FormScale * 3
    Top    = 0
    Height = $FormScale * 124
    Width  = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
    ImageIndex = 0
}
$MainRightTabControl.Controls.Add($Section3ActionTab)


$ManageCredentialsGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Left   = $FormScale + 3
    Top    = 0
    Width  = $FormScale * 126 + ($FormScale + 5)
    Height = $FormScale * 53
}

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
    Add-CommonButtonSettings -Button $ProvideCredentialsButton


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

    $ManageWindowsPortProxyButton = New-Object System.Windows.Forms.Button -Property @{
        Text   = "Manage Port Proxy"
        Left   = $FormScale * 3
        Top    = $FormScale * 10
        Width  = $FormScale * 122
        Height = $FormScale * 22
        Add_Click = { Show-PortProxy }
        #Add_MouseHover = $ManageWindowsPortProxyButtonAdd_MouseHover
    }
    $PivotExecutionGroupBox.Controls.Add($ManageWindowsPortProxyButton)
    Add-CommonButtonSettings -Button $ManageWindowsPortProxyButton


    $script:ComputerListPivotExecutionCheckbox = New-Object System.Windows.Forms.Checkbox -Property @{
        Text    = "Pivot Thru (WinRM)"
        Left    = $FormScale * 3
        Top     = $ManageWindowsPortProxyButton.Top + $ManageWindowsPortProxyButton.Height + ($FormScale * 3)
        Width   = $FormScale * 120
        Height  = $FormScale * 15
        Checked = $false
        Add_Click = $ComputerListPivotExecutionCheckboxAdd_Click
    }
    $PivotExecutionGroupBox.Controls.Add($script:ComputerListPivotExecutionCheckbox)
    if (Test-Path "$PewSettings\Pivot Thru Endpoint Checked.txt") { 
        if ((Get-Content "$PewSettings\Pivot Thru Endpoint Checked.txt") -eq 'True') { 
            $script:ComputerListPivotExecutionCheckbox.Checked = $true 
            Set-PivotThru
        }
        else {
            $script:ComputerListPivotExecutionCheckbox.Checked = $false
        }
    }
    

    $script:ComputerListPivotExecutionTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Left    = $FormScale * 3
        Top     = $script:ComputerListPivotExecutionCheckbox.Top + $script:ComputerListPivotExecutionCheckbox.Height + ($FormScale * 3)
        Width   = $FormScale * 122
        Height  = $FormScale * 22 - 5
    }
    $PivotExecutionGroupBox.Controls.Add($script:ComputerListPivotExecutionTextBox)

    if (Test-Path "$PewSettings\Pivot Thru Endpoint Name.txt") {
        $script:ComputerListPivotExecutionTextBox.text = Get-Content "$PewSettings\Pivot Thru Endpoint Name.txt"
    }

    $script:CommandsTreeView.Nodes.Clear()
    Initialize-TreeViewCommand
    View-TreeViewCommandMethod
    Update-TreeViewCommand

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
        Add_Click = { 
            $This.Checked | Set-Content "$PewSettings\Use DNS Hostname.txt" -Force 
            if ($This.Checked) {$This.ForeColor = 'Blue'}
            else {$This.ForeColor = 'Red'}
        }
    }
    $UseDNSHostnameGroupBox.Controls.Add($script:ComputerListUseDNSCheckbox)
    if (Test-Path "$PewSettings\Use DNS Hostname.txt") { 
        if ((Get-Content "$PewSettings\Use DNS Hostname.txt") -eq 'True') { $script:ComputerListUseDNSCheckbox.Checked = $true }
        else { $script:ComputerListUseDNSCheckbox.Checked = $false }

        if ($script:ComputerListUseDNSCheckbox.Checked) {$script:ComputerListUseDNSCheckbox.ForeColor = 'Blue'}
        else {$script:ComputerListUseDNSCheckbox.ForeColor = 'Red'}
    }


$Section3ActionTab.Controls.Add($UseDNSHostnameGroupBox)


$ExecutionModeGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Left   = $ManageCredentialsGroupBox.Left
    Top    = $UseDNSHostnameGroupBox.Top + $UseDNSHostnameGroupBox.Height + ($FormScale + 2)
    Width  = $FormScale * 126 + ($FormScale + 5)
    Height = $FormScale * 93
}
    $script:CommandTreeViewQueryMethodSelectionComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Left   = $FormScale * 3
        Top    = $FormScale * 10
        Height = $FormScale * 22
        Width  = $FormScale * 122
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor     = 'Black'
        DropDownStyle = 'DropDownList'
        Add_SelectedIndexChanged = $CommandTreeViewQueryMethodSelectionComboBoxAdd_SelectedIndexChanged
    }
    $QueryMethodSelectionList = @(
        'Monitor Jobs',
        'Individual Execution'
    )
    Foreach ($QueryMethod in $QueryMethodSelectionList) { $script:CommandTreeViewQueryMethodSelectionComboBox.Items.Add($QueryMethod) }
    if (Test-Path "$PewSettings\Script Execution Mode.txt") { $script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem = Get-Content "$PewSettings\Script Execution Mode.txt" }
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


    $script:OptionJobTimeoutSelectionComboBox = New-Object -TypeName System.Windows.Forms.Combobox -Property @{
        Text   = '180'
        Left   = $script:OptionJobTimeoutSelectionLabel.Left + $script:OptionJobTimeoutSelectionLabel.Width + $($FormScale * 5)
        Top    = $script:OptionJobTimeoutSelectionLabel.Top - $($FormScale * 3)
        Width  = $FormScale * 50
        Height = $FormScale * 22
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,2,0)
        AutoCompleteMode = "SuggestAppend"
        Add_MouseHover   = $OptionJobTimeoutSelectionComboBoxAdd_MouseHover
        Add_SelectedIndexChanged = { $This.Text | Set-Content "$PewSettings\Job Timeout.txt" -Force }
    }
    $JobTimesAvailable = @(15,30,45,60,120,180,240,300,600)
    ForEach ($Item in $JobTimesAvailable) { $script:OptionJobTimeoutSelectionComboBox.Items.Add($Item) }
    if (Test-Path "$PewSettings\Job Timeout.txt") { $script:OptionJobTimeoutSelectionComboBox.text = Get-Content "$PewSettings\Job Timeout.txt" }
    $ExecutionModeGroupBox.Controls.Add($script:OptionJobTimeoutSelectionComboBox)


    $script:ComputerListExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text    = "Execute Script"
        Left    = $FormScale * 3
        Top     = $script:OptionJobTimeoutSelectionLabel.Top + $script:OptionJobTimeoutSelectionLabel.Height + ($FormScale * 1)
        Width   = $FormScale * 122
        Height  = $FormScale * (22 * 2) - 10
        Enabled = $false
        Add_MouseHover = {
            Show-ToolTip -Title "Start Collection" -Icon "Info" -Message @"
+  Starts the collection process.
+  All checked commands are executed against all checked hosts.
+  Be sure to verify selections before execution.
+  All queries to targets are logged with timestamps.
+  Results are stored in CSV format.
"@
        }
    }
    ### $script:ComputerListExecuteButton.Add_Click($ExecuteScriptHandler) ### Is located lower in the script
    $ExecutionModeGroupBox.Controls.Add($script:ComputerListExecuteButton)
    Add-CommonButtonSettings -Button $script:ComputerListExecuteButton

$Section3ActionTab.Controls.Add($ExecutionModeGroupBox)










# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU9Xgw9nl/bO0788W0uuLN3Cxi
# uCegggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU5DmhFjnXDc48xNXbfgNgnVxI7KAwDQYJKoZI
# hvcNAQEBBQAEggEAgboUOcI1PVsBLIG4ztyhcQvPJxTKplXrw8t6cJVktx9+98S5
# TotvkUGgGFQfHDUJWIwGXcvUYa0THX2H1zXjmzOZY8HAsnWfKqTc8ZwnOcAhoUiP
# 8D1uiVbc9K33P8v/xmMrTleHcl5tq2FiynZRFHaJjXB1Tj+fOOzxzd8PJh+VBLk9
# IxKmPVPIZfB7pQzNDa3BqB/w9ASaxo3kOREuIs7arc+HGoZq0nyhED2j6cn4yTbv
# w3P00YFxb2KW9n1CSF032L01PkaQnDbilyDiCtiHSWgoUaf4JV18W0xKLsytABga
# wKcOMu2RUgQaxmc4CXI8bSYl0ej4kyD+S8Q2FA==
# SIG # End signature block
