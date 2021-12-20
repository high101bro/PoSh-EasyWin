####################################################################################################
# ScriptBlocks
####################################################################################################

$SysinternalsSysmonRenameServiceProcessTextBoxAdd_MouseHover = {
    Show-ToolTip -Title "Rename Sysmon's Service/Process Name" -Icon "Info" -Message @"
+  The default Service/Process name for SysInternals' System Monitor tool is: 'Sysmon'
+  Use this field to obfuscate the service and process name as the tool is running
+  Do NOT add the .exe filename extension; this will be done automatically
+  If this textbox is blank and hovered by the cursor, it will input the default name
+  If a renamed Symmon service push is attempted when sysmon is already installed,
     the script will continue to check for the Renamed Sysmon service exists until it times out
"@
    If ( $($This.Text).Length -eq 0 ) { $This.Text = 'Sysmon' }
}

$SysinternalsSysmonRenameDriverTextBoxAdd_MouseHover = {
    Show-ToolTip -Title "Rename Sysmon's Driver Name" -Icon "Info" -Message @"
+  The default Driver name for SysInternals' System Monitor tool is: 'SysmonDrv'
+  Use this field to obfuscate the driver's name when installed
+  There is an 8 character limit when renaming the driver
+  If this textbox is blank and hovered by the cursor, it will input the default name
+  If you don't know the Sysmon Driver name, either leave the field empty or as its default
"@
    If ( $($This.Text).Length -eq 0 ) { $This.Text = 'SysmonDrv' }
}

$SysinternalsProcmonRenameProcessTextBoxAdd_MouseHover = {
    Show-ToolTip -Title "Rename Procmon's Process Name" -Icon "Info" -Message @"
+  The default process name for SysInternals' Process Monitor tool is: 'Procmon'
+  Do NOT add the .exe filename extension; this will be done automatically
+  Use this field to obfuscate the process name as the tool is running
+  If this textbox is blank and hovered by the cursor, it will input the default name
"@
    If ( $($This.Text).Length -eq 0 ) { $This.Text = 'Procmon' }
}

$ExternalProgramsTimoutOutTextBoxAdd_MouseHover = {
    Show-ToolTip -Title "Recheck Time" -Icon "Info" -Message @"
+  This time in seconds is used when external tools recheck the status
+  Essentially, each time the status is checked a query is made to the endpoint(s)
     - This is either visible in network or event logs
"@
}

$ExternalProgramsWinRMRadioButtonAdd_MouseHover = {
    Show-ToolTip -Title "WinRM" -Icon "Info" -Message @'
+  Commands Used: (example)
    $Session = New-PSSession -ComputerName 'Endpoint'
    Invoke-Command {
        param($Path)
        Start-Process -Filepath "$Path\Procmon.exe" -ArgumentList @("/AcceptEULA /BackingFile $Path\ProcMon /RunTime 30 /Quiet")
        Remove-Item -Path "C:\Windows\Temp\Procmon.exe" -Force
    } -Session $Session -ArgumentList $Path
    Copy-Item -Path c:\Windows\Temp\ProcMon.pml -Destination $LocalPath\ProcMon -FromSession $Session -Force
'@
}

$ExternalProgramsRPCRadioButtonAdd_Click = {
    if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Session Based') {
        $MessageBox = [System.Windows.Forms.MessageBox]::Show("The '$($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem)' mode does not support the RPC and SMB protocols.`nThe 'Monitor Jobs' mode supports the RPC, SMB, and RPC protocol - but is slower and noiser.`n`nDo you want to change the collection mode to 'Monitor Jobs'?","Protocol Alert",[System.Windows.Forms.MessageBoxButtons]::OKCancel)
        switch ($MessageBox){
            "OK" {
                # This brings specific tabs to the forefront/front view
                $MainLeftTabControl.SelectedTab   = $Section1SearchTab
                $InformationTabControl.SelectedTab = $Section3ResultsTab

                $StatusListBox.Items.Clear()
                $StatusListBox.Items.Add("Collection Mode Changed to: Individual Execution")
                #Removed For Testing#$ResultsListBox.Items.Clear()
                $ResultsListBox.Items.Add("The collection mode '$($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem)' does not support the RPC and SMB protocols and has been changed to")
                $ResultsListBox.Items.Add("'Monitor Jobs' which supports RPC, SMB, and WinRM - but may be slower and noisier on the network.")
                $script:CommandTreeViewQueryMethodSelectionComboBox.SelectedIndex = 0
                $EventLogRPCRadioButton.checked         = $true
                $ExternalProgramsRPCRadioButton.checked = $true
            }
            "Cancel" {
                $StatusListBox.Items.Clear()
                $StatusListBox.Items.Add("$($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem) does not support RPC")
                $EventLogWinRMRadioButton.checked         = $true
                $ExternalProgramsWinRMRadioButton.checked = $true
            }
        }
    }
    else {
        $EventLogRPCRadioButton.checked = $true
    }
}

$ExternalProgramsRPCRadioButtonAdd_MouseHover = {
    Show-ToolTip -Title "RPC" -Icon "Info" -Message @'
+  Commands Used: (example)
     Copy-Item .\LocalDir\Procmon.exe "\\Endpoint\C$\Windows\Temp"
     Invoke-WmiMethod -ComputerName 'Endpoint' -Class Win32_Process -Name Create -ArgumentList "$Path\Procmon.exe -AcceptEULA [...etc]"
     Remove-Item "\\Endpoint\C$\Windows\Temp\Procmon.exe" -Force
'@
}

$SysinternalsSysmonCheckBoxAdd_Click = {
    Update-QueryCount
    
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Sysinternals - Sysmon")

    # Manages how the checkbox is handeled to ensure that a config is selected if sysmon is checked
    if ($SysinternalsSysmonCheckbox.checked -and $SysinternalsSysmonConfigTextBox.Text -eq "Config:") {
        OpenFileDialog-UserSpecifiedScript
    }
    if ($SysinternalsSysmonConfigTextBox.Text -eq "Config:"){
        $SysinternalsSysmonCheckbox.checked = $false
    }

    Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
}

$SysinternalsSysmonCheckboxAdd_MouseHover = {
    Show-ToolTip -Title "Sysinternals - Sysmon" -Icon "Info" -Message @"
+  System Monitor (Sysmon) is a Windows system service and device driver that, once installed on a system, remains resident
     across system reboots to monitor and log system activity to the Windows event log. It provides detailed information
     about process creations, network connections, and changes to file creation time. By collecting the events it generates
     using Windows Event Collection or SIEM agents and subsequently analyzing them, you can identify malicious or anomalous
     activity and understand how intruders and malware operate on your network.

+  Note that Sysmon does not provide analysis of the events it generates, nor does it attempt to protect or hide itself
     from attackers.

+  Sysmon includes the following capabilities:
    - Logs process creation with full command line for both current and parent processes.
    - Records the hash of process image files using SHA1 (the default), MD5, SHA256 or IMPHASH.
    - Multiple hashes can be used at the same time.
    - Includes a process GUID in process create events to allow for correlation of events even when Windows reuses process IDs.
    - Include a session GUID in each events to allow correlation of events on same logon session.
    - Logs loading of drivers or DLLs with their signatures and hashes.
    - Logs opens for raw read access of disks and volumes
    - Optionally logs network connections, including each connection’s source process, IP addresses, port numbers, hostnames
      and port names.
    - Detects changes in file creation time to understand when a file was really created. Modification of file create timestamps
      is a technique commonly used by malware to cover its tracks.
    - Automatically reload configuration if changed in the registry.
    - Rule filtering to include or exclude certain events dynamically.
    - Generates events from early in the boot process to capture activity made by even sophisticated kernel-mode malware.

+  https://docs.microsoft.com/en-us/sysinternals/downloads/sysmon
"@
}

$SysinternalsProcessMonitorCheckboxAdd_MouseHover = {
    Show-ToolTip -Title "Sysinternals - Procmon" -Icon "Info" -Message @"
+  Process Monitor is an advanced monitoring tool for Windows that shows real-time file system, Registry and process/thread
     activity. It combines the features of two legacy Sysinternals utilities, Filemon and Regmon, and adds an extensive list
     of enhancements including rich and non-destructive filtering, comprehensive event properties such session IDs and user
     names, reliable process information, full thread stacks with integrated symbol support for each operation, simultaneous
     logging to a file, and much more. Its uniquely powerful features will make Process Monitor a core utility in your system
     troubleshooting and malware hunting toolkit.

+  Process Monitor includes powerful monitoring and filtering capabilities, including:
     - More data captured for operation input and output parameters
     - Non-destructive filters allow you to set filters without losing data
     - Capture of thread stacks for each operation make it possible in many cases to identify the root cause of an operation
     - Reliable capture of process details, including image path, command line, user and session ID
     - Configurable and moveable columns for any event property
     - Filters can be set for any data field, including fields not configured as columns
     - Advanced logging architecture scales to tens of millions of captured events and gigabytes of log data
     - Process tree tool shows relationship of all processes referenced in a trace
     - Native log format preserves all data for loading in a different Process Monitor instance
     - Process tooltip for easy viewing of process image information
     - Detail tooltip allows convenient access to formatted data that doesn't fit in the column
     - Cancellable search
     - Boot time logging of all operations

+  https://docs.microsoft.com/en-us/sysinternals/downloads/procmon
"@
}

$ExeScriptUserSpecifiedExecutableAndScriptCheckboxAdd_Click = {
    Update-QueryCount
    
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("User Specified Executable and Script")

    # Manages how the checkbox is handeled to ensure that a config is selected if sysmon is checked
    if ($ExeScriptUserSpecifiedExecutableAndScriptCheckbox.checked -and ($ExeScriptSelectExecutableTextBox.Text -eq "Directory:" -or $ExeScriptSelectExecutableTextBox.Text -eq "File:")) {
        FolderBrowserDialog-UserSpecifiedExecutable
    }
    if ($ExeScriptUserSpecifiedExecutableAndScriptCheckbox.checked -and $ExeScriptSelectScriptTextBox.Text -eq "Script:") {
        OpenFileDialog-UserSpecifiedScript
    }

    if ($ExeScriptSelectExecutableTextBox.Text -eq "Executable:" -and $ExeScriptSelectScriptTextBox.Text -eq "Script:"){
        $ExeScriptUserSpecifiedExecutableAndScriptCheckbox.checked = $false
        [System.Windows.Forms.MessageBox]::Show("You need to first select an executable and script.","Prerequisite Check",'OK','Info')

    }
    elseif ($ExeScriptSelectExecutableTextBox.Text -eq "Executable:"){
        $ExeScriptUserSpecifiedExecutableAndScriptCheckbox.checked = $false
        [System.Windows.Forms.MessageBox]::Show("You need to first select an executable.","Prerequisite Check",'OK','Info')
    }
    elseif ($ExeScriptSelectScriptTextBox.Text -eq "Script:"){
        $ExeScriptUserSpecifiedExecutableAndScriptCheckbox.checked = $false
        [System.Windows.Forms.MessageBox]::Show("You need to first select an script.","Prerequisite Check",'OK','Info')
    }

    Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
}

$ExeScriptUserSpecifiedExecutableAndScriptCheckboxAdd_MouseHover = {
    Show-ToolTip -Title "User Specified Executable and Script" -Icon "Info" -Message @"
+  Select an Executable and Script to be sent and used within endpoints
+  The executable needs to be executed/started with the accompaning script
+  The script needs to execute/start with the accompaning executable
+  Results and outputs to copy back need to be manually scripted
+  Cleanup and removal of the executable, script, and any results need to be scripted
+  Validate the executable and script combo prior to use within a production network
+  The executable and script are copied to the endpoints' C:\Windows\Temp directory
"@
}

$ExeScriptScriptOnlyCheckboxAdd_Click = {
    if ($this.Checked -eq $true) {
        $ExeScriptSelectExecutableButton.Enabled  = $false
        $ExeScriptSelectExecutableTextBox.Enabled = $false
        $ExeScriptSelectDirRadioButton.Enabled    = $false
        $ExeScriptSelectFileRadioButton.Enabled   = $false
        $ExeScriptSelectExecutableTextBox.text    = 'Disabled - No files being copied over'
        $ExeScriptUserSpecifiedExecutableAndScriptCheckbox.text = "User Specified Custom Script (WinRM)"
    }
    else {
        $ExeScriptSelectExecutableButton.Enabled  = $true
        $ExeScriptSelectExecutableTextBox.Enabled = $true
        $ExeScriptSelectDirRadioButton.Enabled    = $true
        $ExeScriptSelectFileRadioButton.Enabled   = $true
        if     ($ExeScriptSelectDirRadioButton.checked)  { $ExeScriptSelectExecutableTextBox.text = 'Directory:'}
        elseif ($ExeScriptSelectFileRadioButton.checked) { $ExeScriptSelectExecutableTextBox.text = 'File:'}
        $script:ExeScriptSelectDirOrFilePath      = $null
        $ExeScriptUserSpecifiedExecutableAndScriptCheckbox.text = "User Specified Files and Custom Script (WinRM)"
    }
}

$SysinternalsSysmonEventIdsButtonAdd_Click = {
    $EventCodeManualEntrySelectionContents = $null
    Import-Csv  "$Dependencies\Sysmon Config Files\Sysmon Event IDs.csv" | Out-GridView -Title 'Sysmon Event IDs' -OutputMode Multiple | Set-Variable -Name EventCodeManualEntrySelectionContents
    $EventIDColumn = $EventCodeManualEntrySelectionContents | Select-Object -ExpandProperty "Event ID"
    Foreach ($EventID in $EventIDColumn) {
        $EventLogsEventIDsManualEntryTextbox.Text += "$EventID`r`n"
    }

    if ($EventCodeManualEntrySelectionContents){
        $MainLeftSearchTabControl.SelectedTab = $Section1EventLogsTab
    }
}

$SysinternalsSysmonEventIdsButtonAdd_MouseHover = {
    Show-ToolTip -Title "Sysmon Event ID List" -Icon "Info" -Message @"
+  Shows a list of Sysmon specific event IDs
+  These Event IDs will only be generated on endpoints that have Sysmon installed
+  https://docs.microsoft.com/en-us/sysinternals/downloads/sysmon
"@
}

$SysinternalsProcmonButtonAdd_Click = {
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    $SysinternalsProcmonOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{
        Title    = "Open ProcMon File"
        Filter   = "ProcMon Log File (*.pml)| *.pml|All files (*.*)|*.*"
        ShowHelp = $true
    }
    if (Test-Path -Path "$script:IndividualHostResults\Procmon") {
        $SysinternalsProcmonOpenFileDialog.InitialDirectory = "$script:IndividualHostResults\$($SysinternalsProcessMonitorCheckbox.Text)"
        $SysinternalsProcmonOpenFileDialog.ShowDialog()
    }
    else {
        $SysinternalsProcmonOpenFileDialog.InitialDirectory = "$CollectedDataDirectory"
        $SysinternalsProcmonOpenFileDialog.ShowDialog()
    }
    if ($($SysinternalsProcmonOpenFileDialog.filename)) {
        Start-Process "$ExternalPrograms\Procmon.exe" -ArgumentList "`"$($SysinternalsProcmonOpenFileDialog.filename)`""
    }
    #Returns button to default color if it was turned green after task completion
    Apply-CommonButtonSettings -Button $SysinternalsProcmonButton
}

####################################################################################################
# WinForms
####################################################################################################

$SysinternalsRightPosition     = 3
$SysinternalsDownPosition      = -10
$SysinternalsDownPositionShift = 22
$SysinternalsButtonWidth       = 110
$SysinternalsButtonHeight      = 22

$Section1ExecutablesTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text     = "Executables  "
    Location = @{ X = $FormScale * $SysinternalsRightPosition
                  Y = $FormScale * $SysinternalsDownPosition }
    Size     = @{ Width  = $FormScale * 440
                  Height = $FormScale * 22 }
    UseVisualStyleBackColor = $True
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ImageIndex = 1
}
# Test if the External Programs directory is present; if it's there load the tab
if (Test-Path $ExternalPrograms) { $MainLeftSection1InteractionsTabTabControl.Controls.Add($Section1ExecutablesTab) }

$SysinternalsDownPosition += $SysinternalsDownPositionShift


$ExternalProgramsOptionsGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text      = "Collection Options"
    Location  = @{ X = $FormScale * $SysinternalsRightPosition
                   Y = $FormScale * $SysinternalsDownPosition }
    Size     = @{ Width  = $FormScale * 430
                  Height = $FormScale * 47 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
}
            $ExternalProgramsProtocolRadioButtonLabel = New-Object System.Windows.Forms.Label -Property @{
                Text     = "Protocol:"
                Location = @{ X = $FormScale * 7
                            Y = $FormScale * 22 }
                Size     = @{ Width  = $FormScale * 73
                            Height = $FormScale * 20 }
                Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
            }


            $ExternalProgramsWinRMRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text     = "WinRM"
                Location = @{ X = $FormScale * 80
                            Y = $FormScale * 19 }
                Size     = @{ Width  = $FormScale * 80
                            Height = $FormScale * 22 }
                Checked  = $True
                Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
                Add_Click      = { $EventLogWinRMRadioButton.checked = $true }
                Add_MouseHover = $ExternalProgramsWinRMRadioButtonAdd_MouseHover
            }


            $ExternalProgramsRPCRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text     = "RPC"
                Location = @{ X = $ExternalProgramsWinRMRadioButton.Location.X + $ExternalProgramsWinRMRadioButton.Size.Width + $($FormScale * 5)
                            Y = $ExternalProgramsWinRMRadioButton.Location.Y }
                Size     = @{ Width  = $FormScale * 60
                            Height = $FormScale * 22 }
                Checked  = $False
                Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
                Add_Click      = $ExternalProgramsRPCRadioButtonAdd_Click
                Add_MouseHover = $ExternalProgramsRPCRadioButtonAdd_MouseHover
            }


            $ExternalProgramsCheckTimeLabel = New-Object System.Windows.Forms.Label -Property @{
                Text     = "Recheck Time:"
                Location = @{ X = $ExternalProgramsRPCRadioButton.Location.X + $ExternalProgramsRPCRadioButton.Size.Width + $($FormScale * 30)
                            Y = $ExternalProgramsRPCRadioButton.Location.Y + $($FormScale * 3) }
                Size     = @{ Width  = $FormScale * 130
                            Height = $FormScale * 22 }
                Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
            }


            $ExternalProgramsTimoutOutTextBox = New-Object System.Windows.Forms.TextBox -Property @{
                Text     = 60
                Location = @{ X = $ExternalProgramsCheckTimeLabel.Location.X + $ExternalProgramsCheckTimeLabel.Size.Width
                                Y = $ExternalProgramsCheckTimeLabel.Location.Y - 3 }
                Size     = @{ Width  = $FormScale * 30
                                Height = $FormScale * 22 }
                Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                Enabled  = $True
                Add_MouseHover = $ExternalProgramsTimoutOutTextBoxAdd_MouseHover
            }

            $ExternalProgramsOptionsGroupBox.Controls.AddRange(@($ExternalProgramsProtocolRadioButtonLabel,$ExternalProgramsRPCRadioButton,$ExternalProgramsWinRMRadioButton,$ExternalProgramsCheckTimeLabel,$ExternalProgramsTimoutOutTextBox))
$Section1ExecutablesTab.Controls.Add($ExternalProgramsOptionsGroupBox)


$SysinternalsSysmonCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text      = "Sysmon (64-bit)"
    Location  = @{ X = $ExternalProgramsOptionsGroupBox.Location.X + $($FormScale * 5)
                   Y = $ExternalProgramsOptionsGroupBox.Location.Y + $ExternalProgramsOptionsGroupBox.Size.Height + $($FormScale * 5) }
    AutoSize  = $true
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click      = $SysinternalsSysmonCheckBoxAdd_Click
    Add_MouseHover = $SysinternalsSysmonCheckboxAdd_MouseHover
}
$Section1ExecutablesTab.Controls.Add($SysinternalsSysmonCheckbox)


$ExternalProgramsSysmonGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Location  = @{ X = $ExternalProgramsOptionsGroupBox.Location.X
                   Y =  $ExternalProgramsOptionsGroupBox.Location.Y + $ExternalProgramsOptionsGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $ExternalProgramsOptionsGroupBox.Size.Width
                   Height = $FormScale * 133 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
}
            $SysinternalsSysmonLabel = New-Object System.Windows.Forms.Label -Property @{
                Location = @{ X = $FormScale * 5
                            Y = $FormScale * 20 }
                Size     = @{ Width  = $FormScale * 420
                            Height = $FormScale * 25 }
                Text      = "System Monitor (Sysmon) will be installed on the endpoints. Logs created by sysmon can be viewed via command lilne, Windows Event Viewer, or a SIEM."
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
            }
            $ExternalProgramsSysmonGroupBox.Controls.Add($SysinternalsSysmonLabel)

            # Selects the .xml configuration file for sysmon
            Update-FormProgress "$Dependencies\Code\Main Body\OpenFileDialog-SysinternalsSysmonXmlConfig.ps1"
            . "$Dependencies\Code\Main Body\OpenFileDialog-SysinternalsSysmonXmlConfig.ps1"
            $script:SysmonXMLPath = $null
            $SysinternalsSysmonSelectConfigButton = New-Object System.Windows.Forms.Button -Property @{
                Text     = "Select Config"
                Location = @{ X = $SysinternalsSysmonLabel.Location.X
                            Y = $SysinternalsSysmonLabel.Location.Y + $SysinternalsSysmonLabel.Size.Height + $($FormScale * 10) }
                Size     = @{ Width  = $FormScale * $SysinternalsButtonWidth
                            Height = $FormScale * $SysinternalsButtonHeight }
                Add_Click = { OpenFileDialog-SysinternalsSysmonXmlConfig }
            }
            $ExternalProgramsSysmonGroupBox.Controls.Add($SysinternalsSysmonSelectConfigButton)
            Apply-CommonButtonSettings -Button $SysinternalsSysmonSelectConfigButton


            $SysinternalsSysmonEventIdsButton = New-Object System.Windows.Forms.Button -Property @{
                Text     = "Sysmon Event IDs"
                Location = @{ X = $SysinternalsSysmonSelectConfigButton.Location.X
                            Y = $SysinternalsSysmonSelectConfigButton.Location.Y + $SysinternalsSysmonSelectConfigButton.Size.Height + $($FormScale * 5) }
                Size     = @{ Width  = $FormScale * $SysinternalsButtonWidth
                            Height = $FormScale * $SysinternalsButtonHeight }
                Add_Click      = $SysinternalsSysmonEventIdsButtonAdd_Click
                Add_MouseHover = $SysinternalsSysmonEventIdsButtonAdd_MouseHover
            }
            $ExternalProgramsSysmonGroupBox.Controls.Add($SysinternalsSysmonEventIdsButton)
            Apply-CommonButtonSettings -Button $SysinternalsSysmonEventIdsButton


            $SysinternalsSysmonConfigTextBox = New-Object System.Windows.Forms.Textbox -Property @{
                Text     = "Config:"
                Location = @{ X = $FormScale * 125
                            Y = $SysinternalsSysmonSelectConfigButton.Location.Y + $($FormScale * 1) }
                Size     = @{ Width  = $FormScale * 300
                            Height = $FormScale * 22 }
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
                BackColor = "White"
                Enabled   = $false
                Multiline = $true
            }
            $ExternalProgramsSysmonGroupBox.Controls.Add($SysinternalsSysmonConfigTextBox)


            $SysinternalsSysmonRenameServiceProcessLabel = New-Object System.Windows.Forms.Label -Property @{
                Text     = "Service/Process Name:"
                Location = @{ X = $FormScale * 200
                            Y = $SysinternalsSysmonConfigTextBox.Location.Y + $SysinternalsSysmonConfigTextBox.Size.Height + $($FormScale * 8) }
                Size     = @{ Width  = $FormScale * 130
                            Height = $FormScale * 22 }
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Blue"
            }
            $ExternalProgramsSysmonGroupBox.Controls.Add($SysinternalsSysmonRenameServiceProcessLabel)


            $SysinternalsSysmonRenameServiceProcessTextBox = New-Object System.Windows.Forms.Textbox -Property @{
                Text     = "Sysmon"
                Location = @{ X = $SysinternalsSysmonRenameServiceProcessLabel.Location.X + $SysinternalsSysmonRenameServiceProcessLabel.Size.Width + $($FormScale * 10)
                            Y = $SysinternalsSysmonRenameServiceProcessLabel.Location.Y - $($FormScale * 3) }
                Size     = @{ Width  = $FormScale * 85
                            Height = $FormScale * 22 }
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                Add_MouseHover = $SysinternalsSysmonRenameServiceProcessTextBoxAdd_MouseHover
            }
            $ExternalProgramsSysmonGroupBox.Controls.Add($SysinternalsSysmonRenameServiceProcessTextBox)


            $SysinternalsSysmonRenameDriverLabel = New-Object System.Windows.Forms.Label -Property @{
                Text     = "Driver Name:"
                Location = @{ X = $SysinternalsSysmonRenameServiceProcessLabel.Location.X
                            Y = $SysinternalsSysmonRenameServiceProcessLabel.Location.Y + $SysinternalsSysmonRenameServiceProcessLabel.Size.Height }
                Size     = @{ Width  = $SysinternalsSysmonRenameServiceProcessLabel.Size.Width
                            Height = $FormScale * 22 }
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Blue"
            }
            $ExternalProgramsSysmonGroupBox.Controls.Add($SysinternalsSysmonRenameDriverLabel)


            $SysinternalsSysmonRenameDriverTextBox = New-Object System.Windows.Forms.Textbox -Property @{
                Text     = "SysmonDrv"
                Location = @{ X = $SysinternalsSysmonRenameServiceProcessTextBox.Location.X
                            Y = $SysinternalsSysmonRenameDriverLabel.Location.Y - $($FormScale * 3) }
                Size     = @{ Width  = $SysinternalsSysmonRenameServiceProcessTextBox.Size.Width
                            Height = $FormScale * 22 }
                MaxLength = 8
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                Add_MouseHover = $SysinternalsSysmonRenameDriverTextBoxAdd_MouseHover
            }
            $ExternalProgramsSysmonGroupBox.Controls.Add($SysinternalsSysmonRenameDriverTextBox)
$Section1ExecutablesTab.Controls.Add($ExternalProgramsSysmonGroupBox)


$SysinternalsProcessMonitorCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Procmon"
    Location  = @{ X = $ExternalProgramsOptionsGroupBox.Location.X + $($FormScale * 5)
                   Y = $ExternalProgramsSysmonGroupBox.Location.Y + $ExternalProgramsSysmonGroupBox.Size.Height + $($FormScale * 5) }
    AutoSize  = $true
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
    Add_Click = {
        Update-QueryCount
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
    }
    Add_MouseHover = $SysinternalsProcessMonitorCheckboxAdd_MouseHover
}
$Section1ExecutablesTab.Controls.Add($SysinternalsProcessMonitorCheckbox)


$ExternalProgramsProcmonGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Location  = @{ X = $ExternalProgramsSysmonGroupBox.Location.X
                   Y = $ExternalProgramsSysmonGroupBox.Location.Y + $ExternalProgramsSysmonGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $ExternalProgramsOptionsGroupBox.Size.Width
                   Height = $FormScale * 102 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
}
            $SysinternalsProcessMonitorLabel = New-Object System.Windows.Forms.Label -Property @{
                Location = @{ X = $FormScale * 5
                            Y = $FormScale * 20 }
                Size     = @{ Width  = $SysinternalsSysmonLabel.Size.Width
                            Height = $FormScale * 25 }
                Text      = "Obtains process data over a timespan and can easily return data in 100's of MBs. Checks are done to see if 500MB is available on the localhost and endpoints."
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
            }
            $ExternalProgramsProcmonGroupBox.Controls.Add($SysinternalsProcessMonitorLabel)

            $SysinternalsDownPosition += $SysinternalsDownPositionShift


            $SysinternalsProcmonButton = New-Object System.Windows.Forms.Button -Property @{
                Text     = "Open Procmon"
                Location = @{ X = $SysinternalsProcessMonitorLabel.Location.X
                            Y = $SysinternalsProcessMonitorLabel.Location.Y + $SysinternalsProcessMonitorLabel.Size.Height + $($FormScale * 5) }
                Size     = @{ Width  = $FormScale * $SysinternalsButtonWidth
                            Height = $FormScale * $SysinternalsButtonHeight }
                Add_Click = $SysinternalsProcmonButtonAdd_Click
            }
            $ExternalProgramsProcmonGroupBox.Controls.Add($SysinternalsProcmonButton)
            Apply-CommonButtonSettings -Button $SysinternalsProcmonButton


            $SysinternalsProcmonCaptureTimeLabel = New-Object System.Windows.Forms.Label -Property @{
                Text     = "Capture Time:"
                Location = @{ X = $SysinternalsSysmonRenameServiceProcessLabel.Location.X
                            Y = $SysinternalsProcmonButton.Location.Y }
                Size     = @{ Width  = $SysinternalsSysmonRenameServiceProcessLabel.Size.Width
                            Height = $FormScale * 22 }
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Blue"
            }
            $ExternalProgramsProcmonGroupBox.Controls.Add($SysinternalsProcmonCaptureTimeLabel)


            $script:SysinternalsProcessMonitorTimeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
                Text     = "5 Seconds"
                Location = @{ X = $SysinternalsSysmonRenameServiceProcessTextBox.Location.X
                            Y = $SysinternalsProcmonCaptureTimeLabel.Location.Y }
                Size     = @{ Width  = $SysinternalsSysmonRenameServiceProcessTextBox.Size.Width
                            Height = $FormScale * 22 }
                Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            }
            $ProcmonCaptureTimes = @('5 Seconds','10 Seconds','15 Seconds','30 Seconds','1 Minute','2 Minutes','3 Minutes','4 Minutes','5 Minutes')
                ForEach ($time in $ProcmonCaptureTimes) { $script:SysinternalsProcessMonitorTimeComboBox.Items.Add($time) }
            $ExternalProgramsProcmonGroupBox.Controls.Add($script:SysinternalsProcessMonitorTimeComboBox)


            $SysinternalsProcmonRenameProcessLabel = New-Object System.Windows.Forms.Label -Property @{
                Text     = "Process Name:"
                Location = @{ X = $SysinternalsSysmonRenameServiceProcessLabel.Location.X
                            Y = $SysinternalsProcmonCaptureTimeLabel.Location.Y + $SysinternalsProcmonCaptureTimeLabel.Size.Height + $($FormScale * 5) }
                Size     = @{ Width  = $SysinternalsSysmonRenameServiceProcessLabel.Size.Width
                            Height = $FormScale * 22 }
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Blue"
            }
            $ExternalProgramsProcmonGroupBox.Controls.Add($SysinternalsProcmonRenameProcessLabel)


            $SysinternalsProcmonRenameProcessTextBox = New-Object System.Windows.Forms.Textbox -Property @{
                Text     = "Procmon"
                Location = @{ X = $SysinternalsSysmonRenameServiceProcessTextBox.Location.X
                            Y = $SysinternalsProcmonRenameProcessLabel.Location.Y - $($FormScale * 3) }
                Size     = @{ Width  = $SysinternalsSysmonRenameServiceProcessTextBox.Size.Width
                            Height = $FormScale * 22 }
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                Add_MouseHover = $SysinternalsProcmonRenameProcessTextBoxAdd_MouseHover
            }
            $ExternalProgramsProcmonGroupBox.Controls.Add($SysinternalsProcmonRenameProcessTextBox)
$Section1ExecutablesTab.Controls.Add($ExternalProgramsProcmonGroupBox)


$ExeScriptUserSpecifiedExecutableAndScriptCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text      = "User Specified Files and Custom Script (WinRM)"
    Location  = @{ X = $ExternalProgramsProcmonGroupBox.Location.X + $($FormScale * 5)
                   Y = $ExternalProgramsProcmonGroupBox.Location.Y + $ExternalProgramsProcmonGroupBox.Size.Height + $($FormScale * 5) }
    AutoSize  = $true
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click      = $ExeScriptUserSpecifiedExecutableAndScriptCheckboxAdd_Click
    Add_MouseHover = $ExeScriptUserSpecifiedExecutableAndScriptCheckboxAdd_MouseHover
}
$Section1ExecutablesTab.Controls.Add($ExeScriptUserSpecifiedExecutableAndScriptCheckbox)


$ExeScriptProgramGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Location  = @{ X = $ExternalProgramsProcmonGroupBox.Location.X
                   Y = $ExternalProgramsProcmonGroupBox.Location.Y + $ExternalProgramsProcmonGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $ExternalProgramsProcmonGroupBox.Size.Width
                   Height = $FormScale * 135 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
}
            $ExeScriptProgramLabel = New-Object System.Windows.Forms.Label -Property @{
                Location = @{ X = $FormScale * 5
                            Y = $FormScale * 20 }
                Size     = @{ Width  = $FormScale * 420
                            Height = $FormScale * 25 }
                Text      = "Allows for the custom deployment of executables and scripts. Execution flow, cleanup, and retrieval of files is to be managed within the accompanying script."
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
            }
            $ExeScriptProgramGroupBox.Controls.Add($ExeScriptProgramLabel)


            Update-FormProgress "$Dependencies\Code\Main Body\FolderBrowserDialog-UserSpecifiedExecutable.ps1"
            . "$Dependencies\Code\Main Body\FolderBrowserDialog-UserSpecifiedExecutable.ps1"
            $ExeScriptSelectExecutableButton = New-Object System.Windows.Forms.Button -Property @{
                Text     = "Select Dir or File"
                Location = @{ X = $ExeScriptProgramLabel.Location.X
                            Y = $ExeScriptProgramLabel.Location.Y + $ExeScriptProgramLabel.Size.Height + $($FormScale * 10) }
                Size     = @{ Width  = $FormScale * 110
                            Height = $FormScale * 22 }
                Add_Click      = { FolderBrowserDialog-UserSpecifiedExecutable }
                Add_MouseHover = {
                    Show-ToolTip -Title "Select Executable" -Icon "Info" -Message @"
+  Select an Executable to be sent and used within endpoints
+  The executable needs to be executed/started with the accompaning script
+  Results and outputs to copy back need to be manually scripted
+  Cleanup and removal of the executable, script, and any results need to be scripted
+  Validate the executable and script combo prior to use within a production network
+  The executable is copied to the endpoints' C:\Windows\Temp directory
"@
}                
            }
            $ExeScriptProgramGroupBox.Controls.Add($ExeScriptSelectExecutableButton)
            Apply-CommonButtonSettings -Button $ExeScriptSelectExecutableButton


            $ExeScriptSelectExecutableTextBox = New-Object System.Windows.Forms.Textbox -Property @{
                Text     = "Directory:"
                Location = @{ X = $FormScale * 125
                            Y = $ExeScriptSelectExecutableButton.Location.Y + $($FormScale * 1) }
                Size     = @{ Width  = $FormScale * 200
                            Height = $FormScale * 22 }
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
                BackColor = "White"
                Enabled   = $false
                Multiline = $true
            }
            $ExeScriptProgramGroupBox.Controls.Add($ExeScriptSelectExecutableTextBox)


            $ExeScriptSelectDirRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text     = "Dir"
                Location = @{ X = $ExeScriptSelectExecutableTextBox.Location.X + $ExeScriptSelectExecutableTextBox.Size.Width + $($FormScale * 10)
                            Y = $ExeScriptSelectExecutableTextBox.Location.Y }
                Size     = @{ Width  = $FormScale * 45
                            Height = $FormScale * 22 }
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
                Add_Click = {
                    $ExeScriptSelectExecutableTextBox.text = "Directory:"
                    if ($ExeScriptSelectExecutableTextBox.text -eq "Directory:") {$ExeScriptUserSpecifiedExecutableAndScriptCheckbox.checked = $false}
                }
                Checked   = $True
            }
            $ExeScriptProgramGroupBox.Controls.Add($ExeScriptSelectDirRadioButton)


            $ExeScriptSelectFileRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text     = "File"
                Location = @{ X = $ExeScriptSelectDirRadioButton.Location.X + $ExeScriptSelectDirRadioButton.Size.Width
                            Y = $ExeScriptSelectDirRadioButton.Location.Y }
                Size     = @{ Width  = $FormScale * 40
                            Height = $FormScale * 22 }
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                Add_Click = {
                    $ExeScriptSelectExecutableTextBox.text = "File:"
                    if ($ExeScriptSelectExecutableTextBox.text -eq "File:") {$ExeScriptUserSpecifiedExecutableAndScriptCheckbox.checked = $false}
                }
                ForeColor = "Black"
            }
            $ExeScriptProgramGroupBox.Controls.Add($ExeScriptSelectFileRadioButton)



            Update-FormProgress "$Dependencies\Code\Main Body\OpenFileDialog-UserSpecifiedScript.ps1"
            . "$Dependencies\Code\Main Body\OpenFileDialog-UserSpecifiedScript.ps1"
            $ExeScriptSelectScriptButton = New-Object System.Windows.Forms.Button -Property @{
                Text     = "Select Script"
                Location = @{ X = $ExeScriptSelectExecutableButton.Location.X
                            Y = $ExeScriptSelectExecutableButton.Location.Y + $ExeScriptSelectExecutableButton.Size.Height + $($FormScale * 5) }
                Size     = @{ Width  = $FormScale * 110
                            Height = $FormScale * 22 }
                Add_Click      = { OpenFileDialog-UserSpecifiedScript }
                Add_MouseHover = {
                    Show-ToolTip -Title "Select Script" -Icon "Info" -Message @"
+  Select a Script to be sent and used within endpoints
+  This script needs to execute/start with the accompaning executable
+  Results and outputs to copy back need to be manually scripted
+  Cleanup and removal of the executable, script, and any results need to be scripted
+  Validate the executable and script combo prior to use within a production network
+  The script is  copied to the endpoints' C:\Windows\Temp directory
"@
}
            }
            $ExeScriptProgramGroupBox.Controls.Add($ExeScriptSelectScriptButton)
            Apply-CommonButtonSettings -Button $ExeScriptSelectScriptButton


            $ExeScriptSelectScriptTextBox = New-Object System.Windows.Forms.Textbox -Property @{
                Text     = "Script:"
                Location = @{ X = $FormScale * 125
                            Y = $ExeScriptSelectScriptButton.Location.Y + $($FormScale * 1) }
                Size     = @{ Width  = $ExeScriptSelectExecutableTextBox.Size.Width
                            Height = $FormScale * 22 }
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
                BackColor = "White"
                Enabled   = $false
                Multiline = $true
            }
            $ExeScriptProgramGroupBox.Controls.Add($ExeScriptSelectScriptTextBox)


            $ExeScriptScriptOnlyCheckbox = New-Object System.Windows.Forms.Checkbox -Property @{
                Text     = "Script Only"
                Location = @{ X = $ExeScriptSelectDirRadioButton.Location.X
                            Y = $ExeScriptSelectScriptTextBox.Location.Y }
                Size     = @{ Width  = $FormScale * 90
                            Height = $FormScale * 22 }
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
                Add_Click = $ExeScriptScriptOnlyCheckboxAdd_Click
            }
            $ExeScriptProgramGroupBox.Controls.Add($ExeScriptScriptOnlyCheckbox)


            $ExeScriptDestinationDirectoryLabel = New-Object System.Windows.Forms.Label -Property @{
                Text     = "Destination Folder:"
                Location = @{ X = $ExeScriptSelectScriptButton.Location.X
                            Y = $ExeScriptSelectScriptButton.Location.Y + $ExeScriptSelectScriptButton.Size.Height + $($FormScale * 7) }
                Size     = @{ Width  = $FormScale * 110
                            Height = $FormScale * 22 }
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
            }
            $ExeScriptProgramGroupBox.Controls.Add($ExeScriptDestinationDirectoryLabel)


            $script:ExeScriptDestinationDirectoryTextBox = New-Object System.Windows.Forms.Textbox -Property @{
                Text     = "C:\Windows\Temp\"
                Location = @{ X = $FormScale * 125
                            Y = $ExeScriptDestinationDirectoryLabel.Location.Y - $($FormScale * 2) }
                Size     = @{ Width  = $FormScale * 300
                            Height = $FormScale * 22 }
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                AutoCompleteSource = "FileSystem"
                AutoCompleteMode   = "SuggestAppend"
                }
            $ExeScriptProgramGroupBox.Controls.Add($script:ExeScriptDestinationDirectoryTextBox)
$Section1ExecutablesTab.Controls.Add($ExeScriptProgramGroupBox)



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUFtwH9RPjiot61dyxepWTmTy+
# NxKgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU+PQYbbDHWlLmn3eD/JsY3GZ35yEwDQYJKoZI
# hvcNAQEBBQAEggEAZlKbdK9XQvlOvKIwh6KqBJ5+expRzYJOst64UBhZhvsKd7WK
# HWXKjZerf9YY/GmD7ZCvn9Cbg3TN71YeeFLYw4YvXz/wb1TIo3QtnkC/4ubbppG6
# OXY0xkuZFk3ZaPAs2yQITnOR3wHcple0OTQLFpE9maDBVylABiCH6N4xLXwi+W8/
# 8CcnmwI8p8zHcwBUMXvp/rkBho+1cH85+DxOVCpxCDdKDtHA96ghmsngTRCo0Fle
# fK3kWy5Ny0isg7cy1K2acUvkK/Eut/iAAwnvQ3V/M5Putyqcb/nuyNYyytEL7lqu
# XzTWu6pGZqTJDZjisMxIB0AvEjo3j8KP+QxXeQ==
# SIG # End signature block
