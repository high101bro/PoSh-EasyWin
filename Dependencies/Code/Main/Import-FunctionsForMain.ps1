function Update-FormProgress {
    <#
        .Description
        Updatees the Progress Bar Form when used
    #>
    param(
        [string]$ScriptPath = '...'
    )
    $StatusDescription = $ScriptPath | Split-Path -Leaf
    # NOTE: Apparently there are issues with scoping when dot sourcing within a function
    #if ($ScriptPath -ne '...') {
    #    # Loads the script using the Dot Sourcing method
    #    . $ScriptPath
    #}
    $script:ProgressBarMainLabel.text = "Download at: https://GitHub.com/high101bro
Loading: $StatusDescription"
    $script:ProgressBarMainLabel.Refresh()
    $script:ProgressBarFormProgressBar.Value += 1
    $script:ProgressBarSelectionForm.Refresh()
}



Update-FormProgress "Show-SystemTrayNotifyIcon"
function Show-SystemTrayNotifyIcon {
    <#
        .Description
        Launches the accompanying Notifications Icon helper in the  System Tray
    #>
    param($PewCollectedData,$CommandsAndScripts,$CommandsEndpoint,$CommandsActiveDirectory,$PewScriptProcessId,$FormAdminCheck,$EasyWinIcon,$Font,$PewScript,$InitialScriptLoadTime)
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $PoShEasyWinSystemTrayNotifyIcon = New-Object System.Windows.Forms.NotifyIcon -Property @{
        Text        = 'PoSh-EasyWin  ' + '[' + $InitialScriptLoadTime + ']'
        Icon        = $EasyWinIcon
        Visible     = $true
        ContextMenu = New-Object System.Windows.Forms.ContextMenu
        BalloonTipTitle = 'PoSh-EasyWin'
    }

        $SystemTrayCollectedDataMenuItem = New-Object System.Windows.Forms.MenuItem -Property @{
            Text      = 'Collection Folder'
            Add_Click = {
                Start-Process -FilePath "$PewCollectedData"
            }
        }
        $PoShEasyWinSystemTrayNotifyIcon.contextMenu.MenuItems.Add($SystemTrayCollectedDataMenuItem)


        $SystemTrayEndpointCommandsMenuItem = New-Object System.Windows.Forms.MenuItem -Property @{
            Text      = 'Endpoint Commands'
            Add_Click = {
                Invoke-Item $CommandsEndpoint
            }
        }
        $SystemTrayEndpointScriptsMenuItem = New-Object System.Windows.Forms.MenuItem -Property @{
            Text      = 'Endpoint Scripts'
            Add_Click = {
                Start-Process -FilePath "$CommandsAndScripts\Scripts-Host"
            }
        }
        $SystemTrayActiveDirectoryCommandsMenuItem = New-Object System.Windows.Forms.MenuItem -Property @{
            Text      = 'Active Directory Commands'
            Add_Click = {
                Invoke-Item $CommandsActiveDirectory
            }
        }
        $SystemTrayActiveDirectoryScriptssMenuItem = New-Object System.Windows.Forms.MenuItem -Property @{
            Text      = 'Active Directory Scripts'
            Add_Click = {
                Start-Process -FilePath "$CommandsAndScripts\Scripts-AD"
            }
        }
        $SystemTrayOpenFilesAndFoldersMenuItem = New-Object System.Windows.Forms.MenuItem -Property @{
            Text      = 'Commands and Scripts'
        }

        $PoShEasyWinSystemTrayNotifyIcon.contextMenu.MenuItems.Add($SystemTrayOpenFilesAndFoldersMenuItem)
        $SystemTrayOpenFilesAndFoldersMenuItem.MenuItems.Add($SystemTrayEndpointCommandsMenuItem)
        $SystemTrayOpenFilesAndFoldersMenuItem.MenuItems.Add($SystemTrayEndpointScriptsMenuItem)
        $SystemTrayOpenFilesAndFoldersMenuItem.MenuItems.Add($SystemTrayActiveDirectoryCommandsMenuItem)
        $SystemTrayOpenFilesAndFoldersMenuItem.MenuItems.Add($SystemTrayActiveDirectoryScriptssMenuItem)


        $SystemTrayAbortReloadMenuItem = New-Object System.Windows.Forms.MenuItem -Property @{
            Text      = 'Restart Tool'
            Add_Click = {
                $script:VerifyCloseForm = New-Object System.Windows.Forms.Form -Property @{
                    Text    = 'Restart Tool'
                    Width   = 280
                    Height  = 109
                    TopMost = $true
                    Icon    = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
                    Font    = New-Object System.Drawing.Font("$Font",11,0,0,0)
                    FormBorderStyle = 'Fixed3d'
                    StartPosition   = 'CenterScreen'
                    ControlBox      = $true
                    MaximizeBox     = $false
                    MinimizeBox     = $false
                    showintaskbar   = $true
                    Add_Closing = { $This.dispose() }
                }
                $VerifyCloseLabel = New-Object System.Windows.Forms.Label -Property @{
                    Text   = 'Do you want to restart PoSh-EasyWin?'
                    Width  = 280
                    Height = 22
                    Left   = 10
                    Top    = 10
                }
                $script:VerifyCloseForm.Controls.Add($VerifyCloseLabel)


                $VerifyYesButton = New-Object System.Windows.Forms.Button -Property @{
                    Text   = 'Yes'
                    Width  = 115
                    Height = 22
                    Left   = 10
                    Top    = $VerifyCloseLabel.Top + $VerifyCloseLabel.Height
                    BackColor = 'LightGray'
                    Add_Click = {
                        Stop-Process -id $PewScriptProcessId -Force
                        if ($FormAdminCheck -eq 'True'){
                            try {
                                Start-Process PowerShell.exe -Verb RunAs -ArgumentList $PewScript
                            }
                            catch {
                                Start-Process PowerShell.exe -ArgumentList @($PewScript, '-SkipEvelationCheck')
                            }
                        }
                        else {
                            Start-Process PowerShell.exe -ArgumentList @($PewScript, '-SkipEvelationCheck')
                        }
                        $PoShEasyWinSystemTrayNotifyIcon.Visible = $false
                        $script:VerifyCloseForm.close()
                    }
                }
                $script:VerifyCloseForm.Controls.Add($VerifyYesButton)


                $VerifyNoButton = New-Object System.Windows.Forms.Button -Property @{
                    Text   = 'No'
                    Width  = 115
                    Height = 22
                    Left   = $VerifyYesButton.Left + $VerifyYesButton.Width + 10
                    Top    = $VerifyYesButton.Top
                    BackColor = 'LightGray'
                    Add_Click = {
                        $script:VerifyCloseForm.close()
                    }
                }
                $script:VerifyCloseForm.Controls.Add($VerifyNoButton)

                $script:VerifyCloseForm.ShowDialog()
            }
        }
        $PoShEasyWinSystemTrayNotifyIcon.contextMenu.MenuItems.Add($SystemTrayAbortReloadMenuItem)


        $CloseTime = 'Close  [' + $InitialScriptLoadTime + ']'
        $SystemTrayCloseToolMenuItem = New-Object System.Windows.Forms.MenuItem -Property @{
            Text = 'Close Tool'
            add_Click = {
                $script:VerifyCloseForm = New-Object System.Windows.Forms.Form -Property @{
                    Text    = $CloseTime
                    Width   = 250
                    Height  = 109
                    TopMost = $true
                    Icon    = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
                    Font    = New-Object System.Drawing.Font("$Font",11,0,0,0)
                    FormBorderStyle =  'Fixed3d'
                    StartPosition   = 'CenterScreen'
                    ControlBox      = $true
                    MaximizeBox     = $false
                    MinimizeBox     = $false
                    showintaskbar   = $true
                    Add_Closing = { $This.dispose() }
                }
                $VerifyCloseLabel = New-Object System.Windows.Forms.Label -Property @{
                    Text   = 'Do you want to close PoSh-EasyWin?'
                    Width  = 250
                    Height = 22
                    Left   = 10
                    Top    = 10
                }
                $script:VerifyCloseForm.Controls.Add($VerifyCloseLabel)


                $VerifyYesButton = New-Object System.Windows.Forms.Button -Property @{
                    Text   = 'Yes'
                    Width  = 100
                    Height = 22
                    Left   = 10
                    Top    = $VerifyCloseLabel.Top + $VerifyCloseLabel.Height
                    BackColor = 'LightGray'
                    Add_Click = {
                        Stop-Process -id $PewScriptProcessId -Force
                        $PoShEasyWinSystemTrayNotifyIcon.Visible = $false
                        $script:VerifyCloseForm.close()
                    }
                }
                $script:VerifyCloseForm.Controls.Add($VerifyYesButton)


                $VerifyNoButton = New-Object System.Windows.Forms.Button -Property @{
                    Text   = 'No'
                    Width  = 100
                    Height = 22
                    Left   = $VerifyYesButton.Left + $VerifyYesButton.Width + 10
                    Top    = $VerifyYesButton.Top
                    BackColor = 'LightGray'
                    Add_Click = {
                        $script:VerifyCloseForm.close()
                    }
                }
                $script:VerifyCloseForm.Controls.Add($VerifyNoButton)


                $script:VerifyCloseForm.ShowDialog()
            }
        }
        $PoShEasyWinSystemTrayNotifyIcon.contextMenu.MenuItems.Add($SystemTrayCloseToolMenuItem)

    [System.GC]::Collect()

    # Create an application context for it to all run within.
    # This helps with responsiveness, especially when clicking Exit... like in my testing: immediately vs 5-10 seconds
    $appContext = New-Object System.Windows.Forms.ApplicationContext
    [void][System.Windows.Forms.Application]::Run($appContext)
}



Update-FormProgress "Verify-Action"
Function Verify-Action {
    <#
        .Description
        Shows a message box asking for verificaiton and retuns a boolean result
    #>
    param($Title,$Question,$Computer)
    $Verify = [System.Windows.Forms.MessageBox]::Show(
        "$Question`n$Computer",
        "PoSh-EasyWin - $Title",
        'YesNo',
        "Warning")
    $Decision = switch ($Verify) {
        'Yes'{return $true}
        'No' {return $false}
    }
    return $Decision
}



Update-FormProgress "Show-MessageBox"
function Show-MessageBox {
    <#
        .Description
        Shows a Message box for decision making. Combines two .net library methods into one, and inline with PowerShell syntax
    #>
    param(
        [string]$Title = 'Oops... No title was provided',

        [string]$Message = 'Oops... there should be a message here!',

        [ValidateSet('None', 'Hand', 'Error', 'Stop', 'Question', 'Exclamation', 'Warning', 'Asterisk', 'Information')]
        [string]$Type = 'Warning',

        [ValidateSet('OK', 'OKCancel', 'AbortRetryIgnore', 'YesNoCancel', 'YesNo', 'RetryCancel')]
        [string]$Options = 'Ok',

        [switch]$Sound
    )
    # Helpful website:
    # https://michlstechblog.info/blog/powershell-show-a-messagebox/

    # If used elsewhere, you need to load the assemply using one of the methods below:
    # 1) [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    # 2) Add-Type -AssemblyName System.Windows.Forms

    if ($Sound) { [system.media.systemsounds]::Exclamation.play() }

    # Show-MessageBox -Message  -Title "PoSh-EasyWin" -Options "Ok" -Type "Error" -Sound
    return [System.Windows.MessageBox]::Show($Message,$Title,$Options,$Type)
        # Note, the return codes are either as follows: None, OK, Cancel, Abort, Retry, Ignore, Yes, No

    <#
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("$($Message):  Error")
        #Removed For Testing#$ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Error:  No hostname/IP selected")
        $ResultsListBox.Items.Add("        Make sure to checkbox only one hostname/IP")
        $ResultsListBox.Items.Add("        Selecting a Category will not allow you to connect to multiple hosts")
    #>
}



Update-FormProgress "Set-CheckState"
function Set-CheckState {
    <#
        .Description
        Used with PSWriteHTML
    #>
    Param(
        $CheckedListBox,
         # regex matches anything
         [string]$Match = '.',
         [switch]$Check
    )
    0 .. ($CheckedListBox.Items.Count - 1) |
        Where-Object { $CheckedListBox.Items[$_] -match $Match  } |
        ForEach-Object { $CheckedListBox.SetItemChecked($_, $Check) }
}



Update-FormProgress "Resize-MonitorJobsTab"
function Resize-MonitorJobsTab {
    <#
        .Description
        Resizes the Monitor Jobs tabs, useful for viewing double the amount of jobs in the GUI
    #>
    param(
        [switch]$Minimize,
        [switch]$Maximize
    )
    if ($Minimize) {
        $script:Section3MonitorJobsResizeButton.text = "^ Maximize Tab"
        $InformationPanel.Top  = $MainCenterPanel.Top + $MainCenterPanel.Height
        $InformationPanel.Height = $FormScale * 357
        $InformationPanel.bringtofront()
        $InformationTabControl.Height = $InformationPanel.Height
    }
    if ($Maximize) {
        $script:Section3MonitorJobsResizeButton.text = "v Minimize Tab"
        $InformationPanel.Top = $ComputerAndAccountTreeNodeViewPanel.Top
        $InformationPanel.Height = $MainCenterPanel.Height + $InformationPanel.Height
        $InformationPanel.bringtofront()
        $InformationTabControl.Height = $ComputerAndAccountTreeNodeViewPanel.Height
    }
}



Update-FormProgress "Show-ToolTip"
function Show-ToolTip {
    <#
        .Description
        Provides messages when hovering over various areas in the GUI
    #>
    param (
        $Title   = 'No Title Specified',
        $Message = 'No Message Specified',
        $Icon    = 'Warning'
    )
    $ToolTip = New-Object System.Windows.Forms.ToolTip
    if ($OptionShowToolTipCheckBox.Checked){
        $ToolTipMessage1   = "`n`n+  ToolTips can be disabled in the Options Tab."
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage1))
        $ToolTip.Active         = $true
        $ToolTip.UseAnimation   = $true
        $ToolTip.UseFading      = $true
        $ToolTip.IsBalloon      = $true
        $ToolTip.ToolTipIcon    = $Icon  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle   = $Title
    }
}



Update-FormProgress "Check-Connection"
function Check-Connection {
    param (
        $CheckType,
        $MessageTrue,
        $MessageFalse
    )
    # This brings specific tabs to the forefront/front view
    $InformationTabControl.SelectedTab   = $Section3ResultsTab

    $ResultsListBox.Items.Clear()

    # Testing the Workflow concept to speedup connection testing...
    <#
    workflow Parallel-ConnectionTest {
        param(
            [string[]]$script:ComputerTreeViewSelected
        )
        $ConnectionTestResults = @()
        foreach -parallel -throttlelimit 30 ($Computer in $script:ComputerTreeViewSelected) {
            $workflow:ConnectionTestResults += Test-Connection -ComputerName $Computer -Count 1
            InlineScript {
                $script:ProgressBarEndpointsProgressBar.Value += 1
                write-host 'inline test'
                write-host $Using:ComputerTreeViewSelected
            }
        }
        InlineScript {
            $Using:ConnectionTestResults
            $script:ProgressBarEndpointsProgressBar.Value += 1
            #$ResultsListBox.Items.Insert(0,"$($MessageTrue):    $target")
            #Start-Sleep -Milliseconds 50
            #$PoShEasyWin.Refresh()

        }
    }
    Parallel-ConnectionTest -ComputerTreeViewSelected $script:ComputerTreeViewSelected
    #>

    function Test-Port {
        param ($ComputerName, $Port)
        begin { $tcp = New-Object Net.Sockets.TcpClient }
        process {
            try { $tcp.Connect($ComputerName, $Port) } catch {}
            if ($tcp.Connected) { $tcp.Close(); $open = $true }
            else { $open = $false }
            [PSCustomObject]@{ IP = $ComputerName; Port = $Port; Open = $open }
        }
    }

    if ($script:ComputerTreeViewSelected.count -lt 1) {
        Show-MessageBox -Message "No hostname/IP selected`r`nMake sure to checkbox only one hostname/IP`r`nSelecting a Category will not allow you to connect to multiple hosts" -Title "$($CheckType):  Error"
    }
    else {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("$($CheckType):  $($script:ComputerTreeViewSelected.count) hosts")

        $script:ProgressBarEndpointsProgressBar.Maximum = $script:ComputerTreeViewSelected.count
        $script:ProgressBarEndpointsProgressBar.Value   = 0

        Start-Sleep -Milliseconds 50

        $script:NotReachable = @()
        foreach ($target in $script:ComputerTreeViewSelected){

            if ($CheckType -eq "Ping") {
                $CheckCommand = Test-Connection -Count 1 -ComputerName $target

                if ($CheckCommand){
                    $ResultsListBox.Items.Insert(0,"$($MessageTrue):      $target")
                    Start-Sleep -Milliseconds 50
                    $PoShEasyWin.Refresh()
                }
                else {
                    $ResultsListBox.Items.Insert(0,"$($MessageFalse):    $target")
                    $script:NotReachable += $target
                }
            }
            elseif ($CheckType -eq "WinRM Check") {
                # The following does a ping first...
                # Test-NetConnection -CommonTCPPort WINRM -ComputerName <Target>

                #if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                #    if (!$script:Credential) { Set-NewCredential }
                #    $CheckCommand = Test-WSman -ComputerName $target #-Credential $script:Credential
                #}

                $CheckCommand = Test-WSman -ComputerName $target

                if ($CheckCommand){
                    $ResultsListBox.Items.Insert(0,"$($MessageTrue):      $target")
                }
                else {
                    $ResultsListBox.Items.Insert(0,"$($MessageFalse):    $target")
                    $script:NotReachable += $target
                }
            }
            elseif ($CheckType -eq "RPC Port Check") {
                # The following does a ping first...
                # Test-NetConnection -Port 135 -ComputerName <Target>

                #$CheckCommand = Test-Connection -Count 1 -ComputerName $target -Protocol DCOM

                # The following tests for the default RPC port, but not the service itself
                $CheckCommand = Test-Port -ComputerName $target -Port 135 | Select-Object -ExpandProperty Open

                if ($CheckCommand){
                    $ResultsListBox.Items.Insert(0,"$($MessageTrue):      $target")
                }
                else {
                    $ResultsListBox.Items.Insert(0,"$($MessageFalse):    $target")
                    $script:NotReachable += $target
                }
            }
            elseif ($CheckType -eq "SMB Port Check") {
                # The following does a ping first...
                # Test-NetConnection -Port 135 -ComputerName <Target>

                # The following tests for the default RPC port, but not the service itself
                $CheckCommand = Test-Port -ComputerName $target -Port 445 | Select-Object -ExpandProperty Open

                if($CheckCommand){
                    $ResultsListBox.Items.Insert(0,"$($MessageTrue):      $target")
                }
                else {
                    $ResultsListBox.Items.Insert(0,"$($MessageFalse):    $target")
                    $script:NotReachable += $target
                }
            }

            Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message " - $CheckCommand"
            $ResultsListBox.Refresh()
            $PoShEasyWin.Refresh()
            Start-Sleep -Milliseconds 50
            $script:ProgressBarEndpointsProgressBar.Value += 1
        }

        # Popup windows requesting user action
        #[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic")
        #$verify = [Microsoft.VisualBasic.Interaction]::MsgBox(`
        #    "Do you want to uncheck unresponsive hosts?", `
        #    #'YesNoCancel,Question', `
        #    'YesNo,Question', `
        #    "PoSh-EasyWin")
        #switch ($verify) {
        #    'Yes'{
                [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
                foreach ($root in $AllTreeViewNodes) {
                    $root.Checked = $False
                    foreach ($Category in $root.Nodes) {
                        $Category.Checked = $False
                        $EntryNodeCheckedCount = 0
                        foreach ($Entry in $Category.nodes) {
                            if ($script:NotReachable -icontains $($Entry.Text)) {
                                $Entry.Checked   = $False
                                $Entry.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                                $Entry.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
                            }
                            if ($Entry.Checked) {
                                $EntryNodeCheckedCount += 1
                            }
                        }
                        if ($EntryNodeCheckedCount -eq 0) {
                            $Category.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                            $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
                        }
                    }
                }
        #    }
        #    'No'     {continue}
        #    #'Cancel' {exit}
        #}
        $ResultsListBox.Items.Insert(0,"")
        $ResultsListBox.Items.Insert(0,"Finished Testing Connections")
    }
}



Update-FormProgress "Convert-CsvNumberStringsToIntergers"
function Convert-CsvNumberStringsToIntergers {
    <#
        .Description
        Charts - Convert CSV Number Strings To Intergers
    #>
    param (
        $InputDataSource
    )
    $InputDataSource | ForEach-Object {
        if ($_.CreationDate)    { $_.CreationDate    = [datatime]$_.CreationDate }
        if ($_.Handle)          { $_.Handle          = [int]$_.Handle            }
        if ($_.HandleCount)     { $_.HandleCount     = [int]$_.HandleCount       }
        if ($_.ParentProcessID) { $_.ParentProcessID = [int]$_.ParentProcessID   }
        if ($_.ProcessID)       { $_.ProcessID       = [int]$_.ProcessID         }
        if ($_.ThreadCount)     { $_.ThreadCount     = [int]$_.ThreadCount       }
        if ($_.WorkingSetSize)  { $_.WorkingSetSize  = [int]$_.WorkingSetSize    }
    }
}



Update-FormProgress "Search-Registry"
function Search-Registry {
    <#
        .Description
        Allows you to search the any number of registry paths for key names, value names, and value data.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=0, ValueFromPipelineByPropertyName)]
        [Alias("PsPath")]
        # Registry path to search
        [string[]] $Path,
        # Specifies whether or not all subkeys should also be searched
        [switch] $Recurse,
        [Parameter(ParameterSetName="SingleSearchString", Mandatory)]
        # A regular expression that will be checked against key names, value names, and value data (depending on the specified switches)
        [string[]] $SearchRegex,
        [Parameter(ParameterSetName="SingleSearchString")]
        # When the -SearchRegex parameter is used, this switch means that key names will be tested (if none of the three switches are used, keys will be tested)
        [switch] $KeyName,
        [Parameter(ParameterSetName="SingleSearchString")]
        # When the -SearchRegex parameter is used, this switch means that the value names will be tested (if none of the three switches are used, value names will be tested)
        [switch] $ValueName,
        [Parameter(ParameterSetName="SingleSearchString")]
        # When the -SearchRegex parameter is used, this switch means that the value data will be tested (if none of the three switches are used, value data will be tested)
        [switch] $ValueData,
        [Parameter(ParameterSetName="MultipleSearchStrings")]
        # Specifies a regex that will be checked against key names only
        [string[]] $KeyNameRegex,
        [Parameter(ParameterSetName="MultipleSearchStrings")]
        # Specifies a regex that will be checked against value names only
        [string[]] $ValueNameRegex,
        [Parameter(ParameterSetName="MultipleSearchStrings")]
        # Specifies a regex that will be checked against value data only
        [string[]] $ValueDataRegex
    )

    begin {
        switch ($PSCmdlet.ParameterSetName) {
            SingleSearchString {
                $NoSwitchesSpecified = -not ($PSBoundParameters.ContainsKey("KeyName") -or $PSBoundParameters.ContainsKey("ValueName") -or $PSBoundParameters.ContainsKey("ValueData"))
                if ($KeyName   -or $NoSwitchesSpecified) { $KeyNameRegex   = $SearchRegex }
                if ($ValueName -or $NoSwitchesSpecified) { $ValueNameRegex = $SearchRegex }
                if ($ValueData -or $NoSwitchesSpecified) { $ValueDataRegex = $SearchRegex }
            }
            MultipleSearchStrings {
                # No extra work needed
            }
        }
    }

    process {
        $SearchRegexFound = @()
        foreach ($CurrentPath in $Path) {
            Get-ChildItem $CurrentPath -Recurse:$Recurse |
            ForEach-Object {
                $Key = $_
                if ($KeyNameRegex) {
                    foreach ($Regex in $KeyNameRegex) {
                        if ($Key.PSChildName -match $Regex) {
                            $SearchRegexFound += [PSCustomObject] @{
                                SearchTerm = $Regex
                                Key        = $Key
                                KeyName    = $Key.PSChildName
                                Reason     = "KeyName"
                            }
                        }
                    }
                }

                if ($ValueNameRegex) {
                    foreach ($Regex in $ValueNameRegex) {
                        if ($Key.GetValueNames() -match $Regex) {
                            $SearchRegexFound += [PSCustomObject] @{
                                SearchTerm = $Regex
                                Key        = $Key
                                ValueName  = $Key.GetValueNames()
                                Reason     = "ValueName"
                            }
                        }
                    }
                }

                if ($ValueDataRegex) {
                    foreach ($Regex in $ValueDataRegex) {
                        $ValueDataKey = ($Key.GetValueNames() | % { $Key.GetValue($_) })
                        if ($ValueDataKey -match $Regex) {
                            $SearchRegexFound += [PSCustomObject] @{
                                SearchTerm = $Regex
                                Key        = $Key
                                ValueData  = $ValueDataKey
                                Reason     = "ValueData"
                            }
                        }
                    }
                }
            }
        }
        Return $SearchRegexFound
    }
}



Update-FormProgress "Query-NetworkConnection"
function Query-NetworkConnection {
    <#
        .Description
        Searches for network connections that match provided IPs, Ports, or network connections started by specific process names
        Required for Query-NetworkConnectionRemoteIPAddress, Query-NetworkConnectionRemotePort, and Query-NetworkConnectionProcess

    #>
    param(
        $IP             = $null,
        $RemotePort     = $null,
        $LocalPort      = $null,
        $ProcessName    = $null,
        $CommandLine    = $null,
        $ExecutablePath = $null,
        $regex          = $false
    )

    if ([bool]((Get-Command Get-NetTCPConnection).ParameterSets | Select-Object -ExpandProperty Parameters | Where-Object Name -match OwningProcess)) {
        $Processes           = Get-WmiObject -Class Win32_Process
        $Connections         = Get-NetTCPConnection
        $GetNetTCPConnection = $True
        foreach ($Conn in $Connections) {
            foreach ($Proc in $Processes) {
                if ($Conn.OwningProcess -eq $Proc.ProcessId) {
                    $Conn | Add-Member -MemberType NoteProperty -Name 'Duration'        -Value $((New-TimeSpan -Start ($Conn.CreationTime)).ToString())
                    $Conn | Add-Member -MemberType NoteProperty -Name 'ParentProcessId' -Value $Proc.ParentProcessId
                    $Conn | Add-Member -MemberType NoteProperty -Name 'ProcessName'     -Value $Proc.Name
                    $Conn | Add-Member -MemberType NoteProperty -Name 'ExecutablePath'  -Value $Proc.Path
                    $Conn | Add-Member -MemberType NoteProperty -Name 'CommandLine'     -Value $Proc.CommandLine
                }
            }
        }
    }
    else {
        function Get-Netstat {
            $NetworkConnections = netstat -nao -p TCP
            $NetStat = Foreach ($line in $NetworkConnections[4..$NetworkConnections.count]) {
                $line = $line -replace '^\s+',''
                $line = $line -split '\s+'
                $Properties = @{
                    Protocol      =  $line[0]
                    LocalAddress  = ($line[1] -split ":")[0]
                    LocalPort     = ($line[1] -split ":")[1]
                    RemoteAddress = ($line[2] -split ":")[0]
                    RemotePort    = ($line[2] -split ":")[1]
                    State         =  $line[3]
                    ProcessId     =  $line[4]
                }
                $Connection = New-Object -TypeName PSObject -Property $Properties
                $Processes  = Get-WmiObject -query ('select * from win32_process where ProcessId="{0}"' -f $line[4])
                $Connection | Add-Member -MemberType NoteProperty PSComputerName  $env:COMPUTERNAME
                $Connection | Add-Member -MemberType NoteProperty ParentProcessId $Processes.ParentProcessId
                $Connection | Add-Member -MemberType NoteProperty ProcessName     $Processes.Caption
                $Connection | Add-Member -MemberType NoteProperty ExecutablePath  $Processes.ExecutablePath
                $Connection | Add-Member -MemberType NoteProperty CommandLine     $Processes.CommandLine
                $Connection | Add-Member -MemberType NoteProperty CreationTime    ([WMI] '').ConvertToDateTime($Processes.CreationDate)
                #implemented lower #$Connection | Add-Member -MemberType NoteProperty Duration        $((New-TimeSpan -Start $($this.CreationTime).ToString()))
                if ($Connection.ExecutablePath -ne $null -AND -NOT $NoHash) {
                    $MD5Hash = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
                    $Hash    = [System.BitConverter]::ToString($MD5Hash.ComputeHash([System.IO.File]::ReadAllBytes($Processes.ExecutablePath)))
                    $Connection | Add-Member -MemberType NoteProperty MD5Hash $($Hash -replace "-","")
                }
                else {
                    $Connection | Add-Member -MemberType NoteProperty MD5Hash $null
                }
                $Connection
            }
            $NetStat | Select-Object -Property PSComputerName,Protocol,LocalAddress,LocalPort,RemoteAddress,RemotePort,State,ProcessName,ProcessId,ParentProcessId,MD5Hash,ExecutablePath,CommandLine,CreationTime,Duration
        }
        $Connections = Get-Netstat
    }

    function CollectionNetworkData {
        $MD5Hash = $Hash = $null
        if ($GetNetTCPConnection) {
            $Processes      = Get-Process -Pid $conn.OwningProcess
        }
        $ConnectionsFound  += [PSCustomObject]@{
            LocalAddress    = $conn.LocalAddress
            LocalPort       = $conn.LocalPort
            RemoteAddress   = $conn.RemoteAddress
            RemotePort      = $conn.RemotePort
            State           = $conn.State
            CreationTime    = $conn.CreationTime
            Duration        = $((New-TimeSpan -Start ($Conn.CreationTime)).ToString())
            ParentProcessId = $conn.ParentProcessId
            ProcessID       = $(if($GetNetTCPConnection) {$conn.OwningProcess} else {$conn.ProcessID})
            ProcessName     = $conn.ProcessName
            CommandLine     = $conn.CommandLine
            MD5Hash         = $(if($GetNetTCPConnection) {
                $MD5Hash = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
                $Hash    = [System.BitConverter]::ToString($MD5Hash.ComputeHash([System.IO.File]::ReadAllBytes($Processes.path)))
                $($Hash -replace "-","")
            } else {$conn.MD5Hash} )
            ExecutablePath  = $(if($GetNetTCPConnection) { $Processes.Path } else {$conn.ExecutablePath} )
            Protocol        = $(if($GetNetTCPConnection) {'TCP'} else {$conn.Protocol} )
        }
        return $ConnectionsFound
    }

    $ConnectionsFound = @()

    foreach ($Conn in $Connections) {
        if ($regex -eq $true) {
            if     ($IP)             { foreach ($DestIP   in $IP)             { if (($Conn.RemoteAddress  -match $DestIP)   -and ($DestIP   -ne '')) { CollectionNetworkData } } }
            elseif ($RemotePort)     { foreach ($DestPort in $RemotePort)     { if (($Conn.RemotePort     -match $DestPort) -and ($DestPort -ne '')) { CollectionNetworkData } } }
            elseif ($LocalPort)      { foreach ($SrcPort  in $LocalPort)      { if (($Conn.LocalPort      -match $SrcPort)  -and ($SrcPort  -ne '')) { CollectionNetworkData } } }
            elseif ($ProcessName)    { foreach ($ProcName in $ProcessName)    { if (($conn.ProcessName    -match $ProcName) -and ($ProcName -ne '')) { CollectionNetworkData } } }
            elseif ($CommandLine)    { foreach ($Command  in $CommandLine)    { if (($conn.CommandLine    -match $Command)  -and ($Command  -ne '')) { CollectionNetworkData } } }
            elseif ($ExecutablePath) { foreach ($Path     in $ExecutablePath) { if (($conn.ExecutablePath -match $Path)     -and ($Path     -ne '')) { CollectionNetworkData } } }
        }
        elseif ($regex -eq $false) {
            if     ($IP)             { foreach ($DestIP   in $IP)             { if (($Conn.RemoteAddress  -eq $DestIP)   -and ($DestIP   -ne '')) { CollectionNetworkData } } }
            elseif ($RemotePort)     { foreach ($DestPort in $RemotePort)     { if (($Conn.RemotePort     -eq $DestPort) -and ($DestPort -ne '')) { CollectionNetworkData } } }
            elseif ($LocalPort)      { foreach ($SrcPort  in $LocalPort)      { if (($Conn.LocalPort      -eq $SrcPort)  -and ($SrcPort  -ne '')) { CollectionNetworkData } } }
            elseif ($ProcessName)    { foreach ($ProcName in $ProcessName)    { if (($conn.ProcessName    -eq $ProcName) -and ($ProcName -ne '')) { CollectionNetworkData } } }
            elseif ($CommandLine)    { foreach ($Command  in $CommandLine)    { if (($conn.CommandLine    -eq $Command)  -and ($Command  -ne '')) { CollectionNetworkData } } }
            elseif ($ExecutablePath) { foreach ($Path     in $ExecutablePath) { if (($conn.ExecutablePath -eq $Path)     -and ($Path     -ne '')) { CollectionNetworkData } } }
        }
    }
    return $ConnectionsFound
}



Update-FormProgress "Compile-CsvFiles"
function Compile-CsvFiles {
    <#
        .Description
        Compiles the .csv files in the collection directory then saves the combined file to the partent directory
        The first line (collumn headers) is only copied once from the first file compiled, then skipped for the rest

    #>
    param (
        [string]$LocationOfCSVsToCompile,
        [string]$LocationToSaveCompiledCSV
    )
    Remove-Item -Path "$LocationToSaveCompiledCSV" -Force
    Start-Sleep -Milliseconds 250

    $CompiledCSVs = @()
    Get-ChildItem "$LocationOfCSVsToCompile" | ForEach-Object {
        if ((Get-Content $_).Length -eq 0) {
            # Removes any files that don't contain data
            Remove-Item $_
        }
        else {
            $CompiledCSVs += Import-Csv -Path $_
        }
    }
    $CompiledCSVs | Select-Object -Property * -Unique | Export-Csv $LocationToSaveCompiledCSV -NoTypeInformation -Force
}



Update-FormProgress "Compile-XmlFiles"
function Compile-XmlFiles {
    <#
        .Description
        Compiles the .xml files in the collection directory then saves the combined file to the partent directory
    #>
    param (
        [string]$LocationOfXMLsToCompile,
        [string]$LocationToSaveCompiledXML
    )
    Remove-Item -Path "$LocationToSaveCompiledXML" -Force
    Start-Sleep -Milliseconds 250

    $XmlFiles = Get-ChildItem "$LocationOfXMLsToCompile"
    $XmlFiles | Where-Object { (Get-Content $PSItem).Length -eq 0 } | Remove-Item -Force

    Import-CliXml $XmlFiles | Export-CliXml $LocationToSaveCompiledXML
}



Update-FormProgress "Remove-DuplicateCsvHeaders"
function Remove-DuplicateCsvHeaders {
    <#
        .Description
        Removes Duplicate CSV Headers
    #>
    $count = 1
    $output = @()
    $Contents = Get-Content "$($CollectedDataTimeStamp)\$($CollectionName).csv"
    $Header = $Contents | Select-Object -First 1
    foreach ($line in $Contents) {
        if ($line -match $Header -and $count -eq 1) {
            $output = $line + "`r`n"
            $count ++
        }
        elseif ($line -notmatch $Header) {
            $output += $line + "`r`n"
        }
    }
    Remove-Item -Path "$($CollectedDataTimeStamp)\$($CollectionName).csv"
    $output | Out-File -FilePath "$($CollectedDataTimeStamp)\$($CollectionName).csv"
}



Update-FormProgress "Post-MonitorJobs"
function Post-MonitorJobs {
    <#
        .Description
        Common code that runs after jobs have completed that updates the GUI, Compiles files (csv & xml), and logs
    #>
    param(
        $ExecutionStartTime,
        $CollectionName
    )
    $CollectionCommandEndTime  = Get-Date
    $CollectionCommandDiffTime = New-TimeSpan -Start $ExecutionStartTime -End $CollectionCommandEndTime
    $ResultsListBox.Items.RemoveAt(0)
    $ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $CollectionName")

    Compile-CsvFiles -LocationOfCSVsToCompile "$($script:CollectionSavedDirectoryTextBox.Text)\$($CollectionName)\$($CollectionName)*.csv" `
                     -LocationToSaveCompiledCSV "$($script:CollectionSavedDirectoryTextBox.Text)\$($CollectionName) ($ExecutionStartTime).csv"

    Compile-XmlFiles -LocationOfXmlsToCompile "$($script:CollectionSavedDirectoryTextBox.Text)\$($CollectionName)\$($CollectionName)*.xml" `
                     -LocationToSaveCompiledXml "$($script:CollectionSavedDirectoryTextBox.Text)\$($CollectionName) ($ExecutionStartTime).xml"

    #Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Compilied CSV and XML Files"
}



Update-FormProgress "Conduct-PreCommandCheck"
function Conduct-PreCommandCheck {
    <#
        .Description
        If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    #>
    param(
        $CollectedDataTimeStamp,
        $CollectionName,
        $TargetComputer,
        $IndividualHostResults
    )
    # Removes the individual results
    Remove-Item -Path "$($script:CollectionSavedDirectoryTextBox.Text)\$($CollectionName)\$($CollectionName)-$($TargetComputer).csv" -Force -ErrorAction SilentlyContinue
    # Removes the compiled results
    Remove-Item -Path "$($CollectedDataTimeStamp)\$($CollectionName).csv" -Force -ErrorAction SilentlyContinue
    # Creates a directory to save compiled results
    New-Item -ItemType Directory -Path "$($script:CollectionSavedDirectoryTextBox.Text)\$($CollectionName)" -Force -ErrorAction SilentlyContinue
}



Update-FormProgress "Query-EventLog"
function Query-EventLog {
    <#
        .Description
        Combines the inputs from the various GUI fields to query for event logs; fields such as
        event codes/IDs entered, time range, and max amount
        Uses 'Get-WmiObject -Class Win32_NTLogEvent'
    #>
    param(
        $CollectionName,
        $Filter
    )
    $ExecutionStartTime = Get-Date
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Query: $CollectionName")
    $ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")


    function Compiled-EventLogCommand {
        param($script:EventLogsMaximumCollectionTextBox,$script:EventLogsStartTimePicker,$script:EventLogsStopTimePicker,$Filter)

        # Builds the Event Log Query Command
        $EventLogQueryCommand  = "Get-WmiObject -Class Win32_NTLogEvent"
        ###$EventLogQueryComputer = "-ComputerName $TargetComputer"


        # Code to set the amount of data to return
        if ($script:EventLogsMaximumCollectionTextBox.Text -eq $null -or $script:EventLogsMaximumCollectionTextBox.Text -eq '' -or $script:EventLogsMaximumCollectionTextBox.Text -eq 0) {
            $EventLogQueryMax = $null
        }
        else { $EventLogQueryMax = "-First $($script:EventLogsMaximumCollectionTextBox.Text)" }


        # Code to include calendar start/end datetimes if checked
        if ( $script:EventLogsStartTimePicker.Checked -and $script:EventLogsStopTimePicker.Checked ) {
            $EventLogQueryFilter = @"
-Filter "($Filter and (TimeGenerated>='$([System.Management.ManagementDateTimeConverter]::ToDmtfDateTime(($script:EventLogsStartTimePicker.Value)))') and (TimeGenerated<='$([System.Management.ManagementDateTimeConverter]::ToDmtfDateTime(($script:EventLogsStopTimePicker.Value)))'))"
"@
        }
        else { $EventLogQueryFilter = "-Filter `"$Filter`""}


        # Code to select and format properties
        $EventLogQueryPipe = @"
| Select-Object PSComputerName, LogFile, EventIdentifier, CategoryString, @{Name='TimeGenerated';Expression={[Management.ManagementDateTimeConverter]::ToDateTime(`$_.TimeGenerated)}}, Message, Type $EventLogQueryMax
"@

        # TODO Batman... look into why Get-AccountLogonActivity is here...
        #Invoke-Expression -Command "Invoke-Command -ScriptBlock `${function:Get-AccountLogonActivity} -ArgumentList @(`$AccountsStartTimePickerValue,`$AccountsStopTimePickerValue) -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)' -Credential `$script:Credential"
    }



    foreach ($TargetComputer in $script:ComputerList) {
        Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $CollectedDataTimeStamp `
                                -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                                -TargetComputer $TargetComputer
        Write-LogEntry -TargetComputer $TargetComputer  -LogFile $PewLogFile -Message $CollectionName


        if ($EventLogWinRMRadioButton.Checked) {
            $InvokeCommandSplat = @{
                ScriptBlock  = ${function:Compiled-EventLogCommand}
                ArgumentList = @($script:EventLogsMaximumCollectionTextBox,$script:EventLogsStartTimePicker,$script:EventLogsStopTimePicker,$Filter)
                ComputerName = $TargetComputer
                AsJob        = $true
                JobName      = "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"
            }

            if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { Set-NewCredential }
                $InvokeCommandSplat += @{
                    Credential = $script:Credential
                }
            }

            Invoke-Command @InvokeCommandSplat | Select-Object PSComputerName, *
        }
        elseif ($EventLogRPCRadioButton.Checked) {
            #batman
            if ( $script:ComputerListProvideCredentialsCheckBox.Checked ) {
                #$EventLogQueryBuild = "$EventLogQueryCommand $EventLogQueryComputer $EventLogQueryFilter -Credential $script:Credential $EventLogQueryPipe"
                #Start-Job -Name "PoSh-EasyWin: $CollectionName -- $TargetComputer" -ScriptBlock {
                #    param(
                #        $EventLogQueryBuild
                #    )
                #    Invoke-Expression -Command "$EventLogQueryBuild"
                #} -ArgumentList @($EventLogQueryBuild,$null)
            }
            else {
                #$EventLogQueryBuild = "$EventLogQueryCommand $EventLogQueryComputer $EventLogQueryFilter $EventLogQueryPipe"
                #Start-Job -Name "PoSh-EasyWin: $CollectionName -- $TargetComputer" -ScriptBlock {
                #    param(
                #        $EventLogQueryBuild
                #    )
                #    Invoke-Expression -Command "$EventLogQueryBuild"
                #} -ArgumentList @($EventLogQueryBuild,$null)
            }
            #Write-LogEntry -LogFile $PewLogFile -TargetComputer $TargetComputer -Message "$EventLogQueryBuild"
        }
    }



    if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
        Monitor-Jobs -CollectionName $CollectionName -MonitorMode
    }
    elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Individual Execution') {
        Monitor-Jobs -CollectionName $CollectionName
        Post-MonitorJobs -CollectionName $CollectionName -CollectionCommandStartTime $ExecutionStartTime
    }


    $CollectionCommandEndTime  = Get-Date
    $CollectionCommandDiffTime = New-TimeSpan -Start $ExecutionStartTime -End $CollectionCommandEndTime


    $ResultsListBox.Items.RemoveAt(0)
    $ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $CollectionName")
}



Update-FormProgress "Generate-ComputerList"
function Generate-ComputerList {
    <#
        .Description
        Generate list of endpoints to query
    #>
    $script:ComputerList = @()
    $script:ComputerListAll = @()

    # If the root computerlist checkbox is checked, All Endpoints will be queried
    [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
    if ($script:ComputerListUseDNSCheckbox.checked) {
        if ($script:ComputerListSearch.Checked) {
            foreach ($root in $AllTreeViewNodes) {
                if ($root.text -imatch "Search Results") {
                    foreach ($Category in $root.Nodes) {
                        foreach ($Entry in $Category.nodes) {
                            $script:ComputerList += $Entry.text
                        }
                    }
                }
            }
        }
        if ($script:TreeNodeComputerList.Checked) {
            foreach ($root in $AllTreeViewNodes) {
                if ($root.text -imatch "All Endpoints") {
                    foreach ($Category in $root.Nodes) {
                        foreach ($Entry in $Category.nodes) {
                            $script:ComputerList += $Entry.text
                        }
                    }
                }
            }
        }
        foreach ($root in $AllTreeViewNodes) {
            # This loop will select All Endpoints in a Category
            foreach ($Category in $root.Nodes) {
                if ($Category.Checked) {
                    foreach ($Entry in $Category.Nodes) {
                        $script:ComputerList += $Entry.text
                    }
                }
            }
            # This loop will check for entries that are checked
            foreach ($Category in $root.Nodes) {
                foreach ($Entry in $Category.nodes) {
                    $script:ComputerListAll += $Entry.Text
                    if ($Entry.Checked) { $script:ComputerList += $Entry.text }
                }
            }
        }
        # This will dedup the ComputerList, though there is unlikely multiple computers of the same name
        $script:ComputerList = $script:ComputerList | Sort-Object -Unique
        $script:ComputerListAll = $script:ComputerListAll | Sort-Object -Unique
    }
    else {
        if ($script:ComputerListSearch.Checked) {
            foreach ($root in $AllTreeViewNodes) {
                if ($root.text -imatch "Search Results") {
                    foreach ($Category in $root.Nodes) {
                        foreach ($Entry in $Category.nodes) {
                            foreach ($Metadata in $Entry.nodes) {
                                if ($Metadata.Name -eq 'IPv4Address') {
                                    $script:ComputerList += $Metadata.text
                                }
                            }
                        }
                    }
                }
            }
        }
        if ($script:TreeNodeComputerList.Checked) {
            foreach ($root in $AllTreeViewNodes) {
                if ($root.text -imatch "All Endpoints") {
                    foreach ($Category in $root.Nodes) {
                        foreach ($Entry in $Category.nodes) {
                            foreach ($Metadata in $Entry.nodes) {
                                if ($Metadata.Name -eq 'IPv4Address') {
                                    $script:ComputerList += $Metadata.text
                                }
                            }
                        }
                    }
                }
            }
        }
        foreach ($root in $AllTreeViewNodes) {
            # This loop will select All Endpoints in a Category
            foreach ($Category in $root.Nodes) {
                if ($Category.Checked) {
                    foreach ($Entry in $Category.Nodes) {
                        foreach ($Metadata in $Entry.nodes) {
                            if ($Metadata.Name -eq 'IPv4Address') {
                                $script:ComputerList += $Metadata.text
                            }
                        }
                    }
                }
            }
            # This loop will check for entries that are checked
            foreach ($Category in $root.Nodes) {
                foreach ($Entry in $Category.nodes) {
                    if ($Entry.Checked) {
                        foreach ($Metadata in $Entry.nodes) {
                            if ($Metadata.Name -eq 'IPv4Address') {
                                $script:ComputerList += $Metadata.text
                            }
                        }
                    }
                }
            }
        }
        # This will dedup the ComputerList, though there is unlikely multiple computers of the same name
        $script:ComputerList = $script:ComputerList | Sort-Object -Unique
    }
}



Update-FormProgress "Execute-TextToSpeach"
function Execute-TextToSpeach {
    <#
        .Description
        Text To Speach (TTS)
        Plays message when finished, if checked within options
    #>
    if ($OptionTextToSpeachCheckBox.Checked -eq $true) {
        Add-Type -AssemblyName System.speech
        $speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
        Start-Sleep -Seconds 1

        # TTS for Query Count
        if ($QueryCount -eq 1) {$TTSQuerySingularPlural = "query"}
        else {$TTSQuerySingularPlural = "queries"}

        # TTS for TargetComputer Count
        if ($script:ComputerList.Count -eq 1) {$TTSTargetComputerSingularPlural = "host"}
        else {$TTSTargetComputerSingularPlural = "hosts"}

        # Say Message
        if (($QueryCount -eq 0) -and ($script:ComputerList.Count -eq 0)) {$speak.Speak("You need to select at least one query and target host.")}
        else {
            if ($QueryCount -eq 0) {$speak.Speak("You need to select at least one query.")}
            if ($script:ComputerList.Count -eq 0) {$speak.Speak("You need to select at least one target host.")}
            else {$speak.Speak("PoSh-EasyWin has completed $($QueryCount) $($TTSQuerySingularPlural) against $($script:ComputerList.Count) $($TTSTargetComputerSingularPlural).")}
        }
    }
}



Update-FormProgress "Completed-QueryExecution"
Function Completed-QueryExecution {
    <#
        .Description
        The code that is to run after execution is complete
    #>
    # Updates the value of the most recent queried computers
    # Used to ask if you want to conduct rpc,smb,winrm checks again if the currnet computerlist doens't match the history
    $script:ComputerListHistory = $script:ComputerList
    if ($script:RpcCommandCount   -gt 0) { Set-variable RpcCommandCountHistory   -Scope script -Value $true -Force } else { Set-variable RpcCommandCountHistory   -Scope script -Value $false -Force }
    if ($script:SmbCommandCount   -gt 0) { Set-variable SmbCommandCountHistory   -Scope script -Value $true -Force } else { Set-variable SmbCommandCountHistory   -Scope script -Value $false -Force }
    if ($script:WinRmCommandCount -gt 0) { Set-variable WinRmCommandCountHistory -Scope script -Value $true -Force } else { Set-variable WinRmCommandCountHistory -Scope script -Value $false -Force }

    $CollectionTimerStop = Get-Date
    $ResultsListBox.Items.Insert(0,"$(($CollectionTimerStop).ToString('yyyy/MM/dd HH:mm:ss'))  Finished Executing Commands")

    if ($script:RollCredentialsState -and $script:ComputerListProvideCredentialsCheckBox.checked) {
        Start-Sleep -Seconds 3
        Set-NewRollingPassword
        $ResultsListBox.Items.Insert(1,"$(($CollectionTimerStop).ToString('yyyy/MM/dd HH:mm:ss'))  Rolled Password For Account: $($script:PoShEasyWinAccount)")
        $TotalElapsedTimeOrder = @(2,3,4)
    }
    else {$TotalElapsedTimeOrder = @(1,2,3)}


    # Check for and remove empty direcotires
    #$EmtpyDir = "$($script:CollectionSavedDirectoryTextBox.Text)\"
    #do {
    #    $Dirs = Get-ChildItem $EmtpyDir -Directory -Recurse `
    #    | Where-Object { (Get-ChildItem $_.FullName).count -eq 0 } `
    #    | Select-Object -ExpandProperty FullName
    #    $Dirs | Foreach-Object { Remove-Item $_ }
    #} while ($Dirs.count -gt 0)


    $StatusListBox.Items.Clear()
    if     ($QueryCount -eq 1 -and $script:ComputerList.Count -eq 1) { $StatusListBox.Items.Add("Completed Executing $($QueryCount) Command to $($script:ComputerList.Count) Endpoint") }
    elseif ($QueryCount -gt 1 -and $script:ComputerList.Count -eq 1) { $StatusListBox.Items.Add("Completed Executing $($QueryCount) Commands to $($script:ComputerList.Count) Endpoint") }
    elseif ($QueryCount -eq 1 -and $script:ComputerList.Count -gt 1) { $StatusListBox.Items.Add("Completed Executing $($QueryCount) Command to $($script:ComputerList.Count) Endpoints") }
    elseif ($QueryCount -eq 1 -and $script:ComputerList.Count -gt 1) { $StatusListBox.Items.Add("Completed Executing $($QueryCount) Commands to $($script:ComputerList.Count) Endpoints") }


    $CollectionTime = New-TimeSpan -Start $CollectionTimerStart -End $CollectionTimerStop
    $ResultsListBox.Items.Insert($TotalElapsedTimeOrder[0],"   $CollectionTime  Total Elapsed Time")
    $ResultsListBox.Items.Insert($TotalElapsedTimeOrder[1],"====================================================================================================")
    $ResultsListBox.Items.Insert($TotalElapsedTimeOrder[2],"")


    # Ensures that the Progress Bars are full at the end of collection
    $script:ProgressBarEndpointsProgressBar.Maximum = 1
    $script:ProgressBarEndpointsProgressBar.Value   = 1
    $script:ProgressBarQueriesProgressBar.Maximum   = 1
    $script:ProgressBarQueriesProgressBar.Value     = 1

    # Plays a Sound When finished
    [system.media.systemsounds]::Exclamation.play()

    Execute-TextToSpeach

    #Deselect-AllComputers
    Deselect-AllCommands

    # Garbage Collection to free up memory
    [System.GC]::Collect()
}



Update-FormProgress "IndividualQuery-ProcessLive"
function IndividualQuery-ProcessLive {
    <#
        .Description
        Queries and searches the live processes running on endpoints
    #>
    param(
        [switch]$ProcessLiveSearchNameCheckbox,
        [switch]$ProcessLiveSearchCommandlineCheckbox,
        [switch]$ProcessLiveSearchParentNameCheckbox,
        [switch]$ProcessLiveSearchOwnerSIDCheckbox,
        [switch]$ProcessLiveSearchServiceInfoCheckbox,
        [switch]$ProcessLiveSearchNetworkConnectionsCheckbox,
        [switch]$ProcessLiveSearchHashesSignerCertsCheckbox,
        [switch]$ProcessLiveSearchCompanyProductCheckbox
    )

    function MonitorJobScriptBlock {
        param(
            $CollectionName,
            $ProcessesLiveRegex,
            $ProcessLiveSearchName,
            $ProcessLiveSearchCommandline,
            $ProcessLiveSearchParentName,
            $ProcessLiveSearchOwnerSID,
            $ProcessLiveSearchServiceInfo,
            $ProcessLiveSearchNetworkConnections,
            $ProcessLiveSearchHashesSignerCerts,
            $ProcessLiveSearchCompanyProduct
        )

        foreach ($TargetComputer in $script:ComputerList) {
            Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $CollectedDataTimeStamp `
                                    -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                                    -TargetComputer $TargetComputer
            Write-LogEntry -TargetComputer $TargetComputer  -LogFile $PewLogFile -Message $CollectionName


            $ProcessLiveScriptBlock = {
                param(
                    $CollectionName,
                    $ProcessesLiveRegex,
                    $ProcessLiveSearchName,
                    $ProcessLiveSearchCommandline,
                    $ProcessLiveSearchParentName,
                    $ProcessLiveSearchOwnerSID,
                    $ProcessLiveSearchServiceInfo,
                    $ProcessLiveSearchNetworkConnections,
                    $ProcessLiveSearchHashesSignerCerts,
                    $ProcessLiveSearchCompanyProduct
                )

                $ErrorActionPreference = 'SilentlyContinue'
                $CollectionTime = Get-Date
                $Services  += Get-WmiObject Win32_Service
                $Processes = Get-WmiObject Win32_Process

                $ParameterSets = (Get-Command Get-NetTCPConnection).ParameterSets | Select-Object -ExpandProperty Parameters
                if (($ParameterSets | ForEach-Object {$_.name}) -contains 'OwningProcess') {
                    $NetworkConnections = Get-NetTCPConnection
                }
                else {
                    $NetworkConnections = netstat -nao -p TCP
                    $NetStat = Foreach ($line in $NetworkConnections[4..$NetworkConnections.count]) {
                        $line = $line -replace '^\s+',''
                        $line = $line -split '\s+'
                        $properties = @{
                            Protocol      = $line[0]
                            LocalAddress  = ($line[1] -split ":")[0]
                            LocalPort     = ($line[1] -split ":")[1]
                            RemoteAddress = ($line[2] -split ":")[0]
                            RemotePort    = ($line[2] -split ":")[1]
                            State         = $line[3]
                            ProcessId     = $line[4]
                        }
                        $Connection = New-Object -TypeName PSObject -Property $properties
                        $proc       = Get-WmiObject -query ('select * from win32_process where ProcessId="{0}"' -f $line[4])
                        $Connection | Add-Member -MemberType NoteProperty OwningProcess $proc.ProcessId -Force
                        $Connection | Add-Member -MemberType NoteProperty ParentProcessId $proc.ParentProcessId -Force
                        $Connection | Add-Member -MemberType NoteProperty Name $proc.Caption -Force
                        $Connection | Add-Member -MemberType NoteProperty ExecutablePath $proc.ExecutablePath -Force
                        $Connection | Add-Member -MemberType NoteProperty CommandLine $proc.CommandLine -Force
                        $Connection | Add-Member -MemberType NoteProperty PSComputerName $env:COMPUTERNAME -Force
                        if ($Connection.ExecutablePath -ne $null -AND -NOT $NoHash) {
                            $MD5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
                            $hash = [System.BitConverter]::ToString($MD5.ComputeHash([System.IO.File]::ReadAllBytes($proc.ExecutablePath)))
                            $Connection | Add-Member -MemberType NoteProperty MD5 $($hash -replace "-","")
                        }
                        else {
                            $Connection | Add-Member -MemberType NoteProperty MD5 $null
                        }
                        $Connection
                    }
                    $NetworkConnections = $NetStat | Select-Object -Property PSComputerName,Protocol,LocalAddress,LocalPort,RemoteAddress,RemotePort,State,Name,OwningProcess,ProcessId,ParentProcessId,MD5,ExecutablePath,CommandLine
                }

                # Create Hashtable of all network processes and their PIDs
                $NetConnections = @{}
                foreach ( $Connection in $NetworkConnections ) {
                    $connStr = "[$($Connection.State)] " + "$($Connection.LocalAddress)" + ";" + "$($Connection.LocalPort)" + " <--> " + "$($Connection.RemoteAddress)" + ";" + "$($Connection.RemotePort)" + " [$($Connection.CreationTime)]`n"
                    if ( $Connection.OwningProcess -in $NetConnections.keys ) {
                        if ( $connStr -notin $NetConnections[$Connection.OwningProcess] ) { $NetConnections[$Connection.OwningProcess] += $connStr }
                    }
                    else { $NetConnections[$Connection.OwningProcess] = $connStr }
                }

                # Create HashTable of services associated to PIDs
                $ServicePIDs = @{}
                foreach ( $svc in $Services ) {
                    if ( $svc.ProcessID -notin $ServicePIDs.keys ) {
                        $ServicePIDs[$svc.ProcessID] += "$($svc.name) [$($svc.Startmode) Start By $($svc.startname)]`n"
                    }
                }

                # Create HashTable of Process Filepath's MD5Hash
                $MD5Hashtable = @{}
                foreach ( $Proc in $Processes ) {
                    if ( $Proc.Path -and $Proc.Path -notin $MD5Hashtable.keys ) {
                        $MD5Hashtable[$Proc.Path] += $(Get-FileHash -Path $Proc.Path -ErrorAction SilentlyContinue).Hash
                    }
                }

                # Create HashTable of Process Filepath's Authenticode Signature Information
                $TrackPaths  = @()
                $AuthenCodeSigStatus            = @{}
                $AuthenCodeSigSignerCertificate = @{}
                $AuthenCodeSigSignerCompany     = @{}
                foreach ( $Proc in $Processes ) {
                    if ( $Proc.Path -notin $TrackPaths ) {
                        $TrackPaths += $Proc.Path
                        $AuthenCodeSig = Get-AuthenticodeSignature -FilePath $Proc.Path -ErrorAction SilentlyContinue
                        if ( $Proc.Path -notin $AuthenCodeSigStatus.keys ) { $AuthenCodeSigStatus[$Proc.Path] += $AuthenCodeSig.Status }
                        if ( $Proc.Path -notin $AuthenCodeSigSignerCertificate.keys ) { $AuthenCodeSigSignerCertificate[$Proc.Path] += $AuthenCodeSig.SignerCertificate.Thumbprint }
                        if ( $Proc.Path -notin $AuthenCodeSigSignerCompany.keys ) { $AuthenCodeSigSignerCompany[$Proc.Path] += $AuthenCodeSig.SignerCertificate.Subject.split(',')[0].replace('CN=','').replace('"','') }
                    }
                }

                function Write-ProcessTree($Process) {

                    $EnrichedProcess       = Get-Process -Id $Process.ProcessId

                    $ProcessID             = $Process.ProcessID
                    $ParentProcessID       = $Process.ParentProcessID
                    $ParentProcessName     = $(Get-Process -Id $Process.ParentProcessID).Name
                    $CommandLine           = $Process.CommandLine
                    $CreationDate         = [Management.ManagementDateTimeConverter]::ToDateTime($Process.CreationDate)

                    $ServiceInfo           = $ServicePIDs[$Process.ProcessId]

                    $NetConns              = $($NetConnections[$Process.ProcessId]).TrimEnd("`n")
                    $NetConnsCount         = if ($NetConns) {$($NetConns -split "`n").Count} else {[int]0}

                    $MD5Hash               = $MD5Hashtable[$Process.Path]

                    $StatusMessage         = $AuthenCodeSigStatus[$Process.Path]
                    $SignerCertificate     = $AuthenCodeSigSignerCertificate[$Process.Path]
                    $SignerCompany         = $AuthenCodeSigSignerCompany[$Process.Path]

                    $Modules               = $EnrichedProcess.Modules.ModuleName
                    $ModuleCount           = $Modules.count

                    $ThreadCount           = $EnrichedProcess.Threads.count

                    $Owner                 = $Process.GetOwner().Domain.ToString() + "\"+ $Process.GetOwner().User.ToString()
                    $OwnerSID              = $Process.GetOwnerSid().Sid.ToString()

                    $EnrichedProcess `
                    | Add-Member NoteProperty 'ProcessID'              $ProcessID         -PassThru -Force `
                    | Add-Member NoteProperty 'ParentProcessID'        $ParentProcessID   -PassThru -Force `
                    | Add-Member NoteProperty 'ParentProcessName'      $ParentProcessName -PassThru -Force `
                    | Add-Member NoteProperty 'CommandLine'            $CommandLine       -PassThru -Force `
                    | Add-Member NoteProperty 'CreationDate'           $CreationDate      -PassThru -Force `
                    | Add-Member NoteProperty 'ServiceInfo'            $ServiceInfo       -PassThru -Force `
                    | Add-Member NoteProperty 'NetworkConnections'     $NetConns          -PassThru -Force `
                    | Add-Member NoteProperty 'NetworkConnectionCount' $NetConnsCount     -PassThru -Force `
                    | Add-Member NoteProperty 'StatusMessage'          $StatusMessage     -PassThru -Force `
                    | Add-Member NoteProperty 'SignerCertificate'      $SignerCertificate -PassThru -Force `
                    | Add-Member NoteProperty 'SignerCompany'          $SignerCompany     -PassThru -Force `
                    | Add-Member NoteProperty 'MD5Hash'                $MD5Hash           -PassThru -Force `
                    | Add-Member NoteProperty 'Modules'                $Modules           -PassThru -Force `
                    | Add-Member NoteProperty 'ModuleCount'            $ModuleCount       -PassThru -Force `
                    | Add-Member NoteProperty 'ThreadCount'            $ThreadCount       -PassThru -Force `
                    | Add-Member NoteProperty 'Owner'                  $Owner             -PassThru -Force `
                    | Add-Member NoteProperty 'OwnerSID'               $OwnerSID          -PassThru -Force
                }

                $Processes = $Processes | Foreach-Object { Write-ProcessTree -Process $PSItem} | Select-Object -Property Name, ProcessID, ParentProcessName, ParentProcessID, ServiceInfo,`
                    StartTime, @{Name='Duration';Expression={New-TimeSpan -Start $_.StartTime -End $CollectionTime}}, CPU, TotalProcessorTime, `
                    NetworkConnections, NetworkConnectionCount, CommandLine, Path, `
                    WorkingSet, @{Name='MemoryUsage';Expression={
                        if     ($_.WorkingSet -gt 1GB) {"$([Math]::Round($_.WorkingSet/1GB, 2)) GB"}
                        elseif ($_.WorkingSet -gt 1MB) {"$([Math]::Round($_.WorkingSet/1MB, 2)) MB"}
                        elseif ($_.WorkingSet -gt 1KB) {"$([Math]::Round($_.WorkingSet/1KB, 2)) KB"}
                        else                           {"$([Math]::Round($_.WorkingSet,     2)) Bytes"}
                    }}, `
                    MD5Hash, SignerCertificate, StatusMessage, SignerCompany, Company, Product, ProductVersion, Description, `
                    Modules, ModuleCount, `
                    @{n='Threads';e={([string]($_ | Select-Object -Expand Threads | Select-Object -Expand id)).Split() -Join',' }}, `
                    ThreadCount, Handle, Handles, HandleCount, `
                    Owner, OwnerSID


                if ($ProcessLiveSearchName) {
                    foreach ($p in $ProcessLiveSearchName) {
                        if ($ProcessesLiveRegex) { $Processes | Where-Object {$_.Name -match $p } }
                        else                     { $Processes | Where-Object {$_.Name -eq $p } }
                    }
                }
                if ($ProcessLiveSearchCommandline) {
                    foreach ($p in $ProcessLiveSearchCommandline) {
                        if ($ProcessesLiveRegex) { $Processes | Where-Object {$_.CommandLine -match $p } }
                        else                     { $Processes | Where-Object {$_.CommandLine -eq $p } }
                    }
                }
                if ($ProcessLiveSearchParentName) {
                    foreach ($p in $ProcessLiveSearchParentName) {
                        if ($ProcessesLiveRegex) { $Processes | Where-Object {$_.ParentProcessName -match $p} }
                        else                     { $Processes | Where-Object {$_.ParentProcessName -eq $p } }
                    }
                }
                if ($ProcessLiveSearchOwnerSID) {
                    foreach ($p in $ProcessLiveSearchOwnerSID) {
                        if ($ProcessesLiveRegex) { $Processes | Where-Object {$_.Owner -match $p -or $_.OwnerSID -match $p} }
                        else                     { $Processes | Where-Object {$_.Owner -eq $p -or $_.OwnerSID -eq $p} }
                    }
                }
                if ($ProcessLiveSearchServiceInfo) {
                    foreach ($p in $ProcessLiveSearchServiceInfo) {
                        if ($ProcessesLiveRegex) { $Processes | Where-Object {$_.ServiceInfo -match $p} }
                        else                     { $Processes | Where-Object {$_.ServiceInfo -eq $p} }
                    }
                }
                if ($ProcessLiveSearchNetworkConnections) {
                    foreach ($p in $ProcessLiveSearchNetworkConnections) {
                        if ($ProcessesLiveRegex) { $Processes | Where-Object {$_.NetworkConnections -match $p } }
                        else                     { $Processes | Where-Object {$_.NetworkConnections -eq $p } }
                    }
                }
                if ($ProcessLiveSearchHashesSignerCerts) {
                    foreach ($p in $ProcessLiveSearchHashesSignerCerts) {
                        if ($ProcessesLiveRegex) { $Processes | Where-Object {$_.MD5Hash -match $p -or $_.SignerCertificate -match $p} }
                        else                     { $Processes | Where-Object {$_.MD5Hash -eq $p -or $_.SignerCertificate -eq $p} }
                    }
                }
                if ($ProcessLiveSearchCompanyProduct) {
                    foreach ($p in $ProcessLiveSearchCompanyProduct) {
                        if ($ProcessesLiveRegex) { $Processes | Where-Object {$_.Company -match $p -or $_.Product -match $p -or $_.SignerCompany -match $p} }
                        else                     { $Processes | Where-Object {$_.Company -eq $p -or $_.Product -eq $p -or $_.SignerCompany -eq $p} }
                    }
                }
            }

            $InvokeCommandSplat = @{
                ScriptBlock  = $ProcessLiveScriptBlock
                ArgumentList = @(
                    $CollectionName,
                    $ProcessesLiveRegex,
                    $ProcessLiveSearchName,
                    $ProcessLiveSearchCommandline,
                    $ProcessLiveSearchParentName,
                    $ProcessLiveSearchOwnerSID,
                    $ProcessLiveSearchServiceInfo,
                    $ProcessLiveSearchNetworkConnections,
                    $ProcessLiveSearchHashesSignerCerts,
                    $ProcessLiveSearchCompanyProduct
                )
                ComputerName = $TargetComputer
                AsJob        = $true
                JobName      = "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"
            }

            if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { Set-NewCredential }
                $InvokeCommandSplat += @{
                    Credential = $script:Credential
                }
            }
            Invoke-Command @InvokeCommandSplat | Select-Object PSComputerName, *
        }
    }


    if     ($ProcessLiveSearchNameCheckbox)               {$CollectionName = "Process (Live) Name"}
    elseif ($ProcessLiveSearchCommandlineCheckbox)        {$CollectionName = "Process (Live) Command Line"}
    elseif ($ProcessLiveSearchParentNameCheckbox)         {$CollectionName = "Process (Live) Parent Name"}
    elseif ($ProcessLiveSearchOwnerSIDCheckbox)           {$CollectionName = "Process (Live) Owner, SID"}
    elseif ($ProcessLiveSearchServiceInfoCheckbox)        {$CollectionName = "Process (Live) Service Info"}
    elseif ($ProcessLiveSearchNetworkConnectionsCheckbox) {$CollectionName = "Process (Live) Network Connections"}
    elseif ($ProcessLiveSearchHashesSignerCertsCheckbox)  {$CollectionName = "Process (Live) Hashes, Signer Cert"}
    elseif ($ProcessLiveSearchCompanyProductCheckbox)     {$CollectionName = "Process (Live) Company, Product"}


    $EndpointString = ''
    foreach ($item in $script:ComputerList) {$EndpointString += "$item`n"}

    $InputValues = @"
===========================================================================
Collection Name:
===========================================================================
$CollectionName

===========================================================================
Execution Time:
===========================================================================
$ExecutionStartTime

===========================================================================
Credentials:
===========================================================================
$($script:Credential.UserName)

===========================================================================
Endpoints:
===========================================================================
$($EndpointString.trim())

===========================================================================
Regular Expression:
===========================================================================
$($ProcessesLiveRegexCheckbox.checked)

===========================================================================
Search Terms:
===========================================================================

"@


    if   ($ProcessesLiveRegexCheckbox.checked) {$ProcessesLiveRegex = $True}
    else {$ProcessesLiveRegex = $False}


    if ($ProcessLiveSearchNameCheckbox) {
        $ProcessLiveSearchName = ($ProcessLiveSearchNameRichTextbox.Text).split("`r`n")
        $InputValues += $($ProcessLiveSearchName -join "`n")
    }
    else {$ProcessLiveSearchName = $null}


    if ($ProcessLiveSearchCommandlineCheckbox) {
        $ProcessLiveSearchCommandline = $ProcessLiveSearchCommandlineRichTextbox.Lines
        $InputValues += $($ProcessLiveSearchCommandline -join "`n")
    }
    else {$ProcessLiveSearchCommandline = $null}


    if ($ProcessLiveSearchParentNameCheckbox) {
        $ProcessLiveSearchParentName = ($ProcessLiveSearchParentNameRichTextbox.Text).split("`r`n")
        $InputValues += $($ProcessLiveSearchParentName -join "`n")
    }
    else {$ProcessLiveSearchParentName = $null}


    if ($ProcessLiveSearchOwnerSIDCheckbox) {
        $ProcessLiveSearchOwnerSID = ($ProcessLiveSearchOwnerSIDRichTextbox.Text).split("`r`n")
        $InputValues += $($ProcessLiveSearchOwnerSID -join "`n")
    }
    else {$ProcessLiveSearchOwnerSID = $null}


    if ($ProcessLiveSearchServiceInfoCheckbox) {
        $ProcessLiveSearchServiceInfo = ($ProcessLiveSearchServiceInfoRichTextbox.Text).split("`r`n")
        $InputValues += $($ProcessLiveSearchServiceInfo -join "`n")
    }
    else {$ProcessLiveSearchServiceInfo = $null}


    if ($ProcessLiveSearchNetworkConnectionsCheckbox) {
        $ProcessLiveSearchNetworkConnections = ($ProcessLiveSearchNetworkConnectionsRichTextbox.Text).split("`r`n")
        $InputValues += $($ProcessLiveSearchNetworkConnections -join "`n")
    }
    else {$ProcessLiveSearchNetworkConnections = $null}


    if ($ProcessLiveSearchHashesSignerCertsCheckbox) {
        $ProcessLiveSearchHashesSignerCerts = ($ProcessLiveSearchHashesSignerCertsRichTextbox.Text).split("`r`n")
        $InputValues += $($ProcessLiveSearchHashesSignerCerts -join "`n")
    }
    else {$ProcessLiveSearchHashesSignerCerts = $null}


    if ($ProcessLiveSearchCompanyProductCheckbox) {
        $ProcessLiveSearchCompanyProduct = ($ProcessLiveSearchCompanyProductRichTextbox.Text).split("`r`n")
        $InputValues += $($ProcessLiveSearchCompanyProduct -join "`n")
    }
    else {$ProcessLiveSearchCompanyProduct = $null}


    $ExecutionStartTime = Get-Date
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Query: $CollectionName")
    $ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")


    $InvokeCommandSplat = @{
        ScriptBlock  = ${function:MonitorJobScriptBlock}
        ArgumentList = @($CollectionName,$ProcessesLiveRegex,$ProcessLiveSearchName,$ProcessLiveSearchCommandline,$ProcessLiveSearchParentName,$ProcessLiveSearchOwnerSID,$ProcessLiveSearchServiceInfo,$ProcessLiveSearchNetworkConnections,$ProcessLiveSearchHashesSignerCerts,$ProcessLiveSearchCompanyProduct)
    }
    Invoke-Command @InvokeCommandSplat
    Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:MonitorJobScriptBlock} -ArgumentList @($CollectionName,$ProcessesLiveRegex,$ProcessLiveSearchName,$ProcessLiveSearchCommandline,$ProcessLiveSearchParentName,$ProcessLiveSearchOwnerSID,$ProcessLiveSearchServiceInfo,$ProcessLiveSearchNetworkConnections,$ProcessLiveSearchHashesSignerCerts,$ProcessLiveSearchCompanyProduct) -InputValues $InputValues

    $CollectionCommandEndTime  = Get-Date
    $CollectionCommandDiffTime = New-TimeSpan -Start $ExecutionStartTime -End $CollectionCommandEndTime
    $ResultsListBox.Items.RemoveAt(0)
    $ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $CollectionName")

    Update-EndpointNotes
}




Update-FormProgress "IndividualQuery-ProcessSysmon"
function IndividualQuery-ProcessSysmon {
    <#
        .Description
        Loads the function used to query for various Sysmon Event ID 1 Process Creation logs
    #>
    param(
        [switch]$ProcessSysmonSearchRuleNameCheckbox,
        [switch]$ProcessSysmonSearchUserAccountIdCheckbox,
        [switch]$ProcessSysmonSearchHashesCheckbox,
        [switch]$ProcessSysmonSearchFilePathCheckbox,
        [switch]$ProcessSysmonSearchCommandlineCheckbox,
        [switch]$ProcessSysmonSearchParentFilePathCheckbox,
        [switch]$ProcessSysmonSearchParentCommandlineCheckbox,
        [switch]$ProcessSysmonSearchCompanyProductCheckbox
    )

    function MonitorJobScriptBlock {
        param(
            $CollectionName,
            $ProcessSysmonRegex,
            $ProcessSysmonSearchRuleName,
            $ProcessSysmonSearchUserAccountId,
            $ProcessSysmonSearchHashes,
            $ProcessSysmonSearchFilePath,
            $ProcessSysmonSearchCommandline,
            $ProcessSysmonSearchParentFilePath,
            $ProcessSysmonSearchParentCommandline,
            $ProcessSysmonSearchCompanyProduct
        )

        foreach ($TargetComputer in $script:ComputerList) {
            Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $CollectedDataTimeStamp `
                                    -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                                    -TargetComputer $TargetComputer
            Write-LogEntry -TargetComputer $TargetComputer  -LogFile $PewLogFile -Message $CollectionName


            $ProcessSysmonScriptBlock = {
                    param(
                        $CollectionName,
                        $ProcessSysmonRegex,
                        $ProcessSysmonSearchRuleName,
                        $ProcessSysmonSearchUserAccountId,
                        $ProcessSysmonSearchHashes,
                        $ProcessSysmonSearchFilePath,
                        $ProcessSysmonSearchCommandline,
                        $ProcessSysmonSearchParentFilePath,
                        $ProcessSysmonSearchParentCommandline,
                        $ProcessSysmonSearchCompanyProduct
                    )

                    $SysmonProcessCreationEventLogs = Get-WinEvent -FilterHashtable @{
                        LogName = 'Microsoft-Windows-Sysmon/Operational'
                        Id      = 1
                    }

                    $SysmonProcessCreationEventLogsFormatted = @()
                    Foreach ($event in ($SysmonProcessCreationEventLogs)) {
                        $Message = $event | Select-Object -Expand Message
                        $SysmonProcessCreationEventLogsFormatted += [PSCustomObject]@{
                            'Event'             = ($Message -split "`r`n")[0].TrimEnd(':')
                            'RuleName'          = (($Message -split "`r`n")[1] -split ": ")[1]
                            'UtcTime'           = [datetime](($Message -split "`r`n")[2] -split ": ")[1]
                            'ProcessGuid'       = (($Message -split "`r`n")[3] -split ": ")[1].Replace('{','').Replace('}','')
                            'ProcessId'         = (($Message -split "`r`n")[4] -split ": ")[1]
                            'Image'             = (($Message -split "`r`n")[5] -split ": ")[1]
                            'FileVersion'       = (($Message -split "`r`n")[6] -split ": ")[1]
                            'Description'       = (($Message -split "`r`n")[7] -split ": ")[1]
                            'Product'           = (($Message -split "`r`n")[8] -split ": ")[1]
                            'Company'           = (($Message -split "`r`n")[9] -split ": ")[1]
                            'OriginalFileName'  = (($Message -split "`r`n")[10] -split ": ")[1]
                            'CommandLine'       = (($Message -split "`r`n")[11] -split ": ")[1]
                            'CurrentDirectory'  = (($Message -split "`r`n")[12] -split ": ")[1]
                            'User'              = (($Message -split "`r`n")[13] -split ": ")[1]
                            'LogonGuid'         = (($Message -split "`r`n")[14] -split ": ")[1]
                            'LogonId'           = (($Message -split "`r`n")[15] -split ": ")[1]
                            'TerminalSessionId' = (($Message -split "`r`n")[16] -split ": ")[1]
                            'IntegrityLevel'    = (($Message -split "`r`n")[17] -split ": ")[1]
                            'SHA1Hash'          = (($Message -split "`r`n")[18] -split ": ")[1].split(',')[0].split('=')[1]
                            'MD5Hash'           = (($Message -split "`r`n")[18] -split ": ")[1].split(',')[1].split('=')[1]
                            'SHA256Hash'        = (($Message -split "`r`n")[18] -split ": ")[1].split(',')[2].split('=')[1]
                            'IMPHash'           = (($Message -split "`r`n")[18] -split ": ")[1].split(',')[3].split('=')[1]
                            'Hashes'            = (($Message -split "`r`n")[18] -split ": ")[1]
                            'ParentProcessGuid' = (($Message -split "`r`n")[19] -split ": ")[1]
                            'ParentProcessId'   = (($Message -split "`r`n")[20] -split ": ")[1]
                            'ParentImage'       = (($Message -split "`r`n")[21] -split ": ")[1]
                            'ParentCommandLine' = (($Message -split "`r`n")[22] -split ": ")[1]
                            'ThreadId'          = $event.ThreadId
                            'ComputerName'      = $event.MachineName
                            'MachineName'       = $event.MachineName
                            'UserId'            = $event.UserId
                            'TimeCreated'       = $event.TimeCreated
                        }
                    }

                    $ProcessSysmonEventFound = @()

                    foreach ($SysmonNetEvent in $SysmonProcessCreationEventLogsFormatted) {
                        if ($ProcessSysmonRegex -eq $true) {
                            if ($ProcessSysmonSearchRuleName)          { foreach ($Name in $ProcessSysmonSearchRuleName) { if (($SysmonNetEvent.RuleName -match $Name) -and ($Name -ne '')) { $ProcessSysmonEventFound += $SysmonNetEvent } } }
                            if ($ProcessSysmonSearchUserAccountId)     { foreach ($User in $ProcessSysmonSearchUserAccountId) { if (($SysmonNetEvent.User -match $User -or $SysmonNetEvent.UserId -match $User) -and ($User -ne '')) { $ProcessSysmonEventFound += $SysmonNetEvent } } }
                            if ($ProcessSysmonSearchHashes)            { foreach ($Hash in $ProcessSysmonSearchHashes) { if (($SysmonNetEvent.MD5Hash -match $Hash -or $SysmonNetEvent.SHA1Hash -match $Hash -or $SysmonNetEvent.SHA256Hash -match $Hash -or $SysmonNetEvent.IMPHash -match $Hash) -and ($Hash -ne '')) { $ProcessSysmonEventFound += $SysmonNetEvent } } }
                            if ($ProcessSysmonSearchFilePath)          { foreach ($Path in $ProcessSysmonSearchFilePath) { if (($SysmonNetEvent.Image -match $Path) -and ($Path -ne '')) { $ProcessSysmonEventFound += $SysmonNetEvent } } }
                            if ($ProcessSysmonSearchCommandline)       { foreach ($CommandLine in $ProcessSysmonSearchCommandline) { if (($SysmonNetEvent.CommandLine -match $CommandLine) -and ($CommandLine -ne '')) { $ProcessSysmonEventFound += $SysmonNetEvent } } }
                            if ($ProcessSysmonSearchParentFilePath)    { foreach ($Path in $ProcessSysmonSearchParentFilePath) { if (($SysmonNetEvent.ParentImage -match $Path) -and ($Path -ne '')) { $ProcessSysmonEventFound += $SysmonNetEvent } } }
                            if ($ProcessSysmonSearchParentCommandline) { foreach ($CommandLine in $ProcessSysmonSearchParentCommandline) { if (($SysmonNetEvent.ParentCommandLine -match $CommandLine) -and ($CommandLine -ne '')) { $ProcessSysmonEventFound += $SysmonNetEvent } } }
                            if ($ProcessSysmonSearchCompanyProduct)    { foreach ($Item in $ProcessSysmonSearchCompanyProduct) { if (($SysmonNetEvent.Company -match $Item -or $SysmonNetEvent.Product -match $Item) -and ($Item -ne '')) { $ProcessSysmonEventFound += $SysmonNetEvent } } }
                        }
                        elseif ($ProcessSysmonRegex -eq $false) {
                            if ($ProcessSysmonSearchRuleName)          { foreach ($Name in $ProcessSysmonSearchRuleName) { if (($SysmonNetEvent.RuleName -eq $Name) -and ($Name -ne '')) { $ProcessSysmonEventFound += $SysmonNetEvent } } }
                            if ($ProcessSysmonSearchUserAccountId)     { foreach ($User in $ProcessSysmonSearchUserAccountId) { if (($SysmonNetEvent.User -eq $User -or $SysmonNetEvent.UserId -eq $User) -and ($User -ne '')) { $ProcessSysmonEventFound += $SysmonNetEvent } } }
                            if ($ProcessSysmonSearchHashes)            { foreach ($Hash in $ProcessSysmonSearchHashes) { if (($SysmonNetEvent.MD5Hash -eq $Hash -or $SysmonNetEvent.SHA1Hash -eq $Hash -or $SysmonNetEvent.SHA256Hash -eq $Hash -or $SysmonNetEvent.IMPHash -eq $Hash) -and ($Hash -ne '')) { $ProcessSysmonEventFound += $SysmonNetEvent } } }
                            if ($ProcessSysmonSearchFilePath)          { foreach ($Path in $ProcessSysmonSearchFilePath) { if (($SysmonNetEvent.Image -eq $Path) -and ($Path -ne '')) { $ProcessSysmonEventFound += $SysmonNetEvent } } }
                            if ($ProcessSysmonSearchCommandline)       { foreach ($CommandLine in $ProcessSysmonSearchCommandline) { if (($SysmonNetEvent.CommandLine -eq $CommandLine) -and ($CommandLine -ne '')) { $ProcessSysmonEventFound += $SysmonNetEvent } } }
                            if ($ProcessSysmonSearchParentFilePath)    { foreach ($Path in $ProcessSysmonSearchParentFilePath) { if (($SysmonNetEvent.ParentImage -eq $Path) -and ($Path -ne '')) { $ProcessSysmonEventFound += $SysmonNetEvent } } }
                            if ($ProcessSysmonSearchParentCommandline) { foreach ($CommandLine in $ProcessSysmonSearchParentCommandline) { if (($SysmonNetEvent.ParentCommandLine -eq $CommandLine) -and ($CommandLine -ne '')) { $ProcessSysmonEventFound += $SysmonNetEvent } } }
                            if ($ProcessSysmonSearchCompanyProduct)    { foreach ($Item in $ProcessSysmonSearchCompanyProduct) { if (($SysmonNetEvent.Company -eq $Item -or $SysmonNetEvent.Product -eq $Item) -and ($Item -ne '')) { $ProcessSysmonEventFound += $SysmonNetEvent } } }
                        }
                    }
                    return $ProcessSysmonEventFound | Select-Object -Property ComputerName, Event, Description, TimeCreated, UtcTime, ProcessId, CommandLine, ParentProcessId, ParentCommandLine, User, UserId, RuleName, SHA1Hash, MD5Hash, SHA256Hash, IMPHash, Company, Product, Image, ParentImage, LogonId, FileVersion, OriginalFileName, MachineName, CurrentDirectory, IntegrityLevel, TerminalSessionId, ThreadId, LogonGuid, ProcessGuid, ParentProcessGuid
                    #, Hashes
            }


            $InvokeCommandSplat = @{
                ScriptBlock  = $ProcessSysmonScriptBlock
                ArgumentList = @(
                    $CollectionName,
                    $ProcessSysmonRegex,
                    $ProcessSysmonSearchRuleName,
                    $ProcessSysmonSearchUserAccountId,
                    $ProcessSysmonSearchHashes,
                    $ProcessSysmonSearchFilePath,
                    $ProcessSysmonSearchCommandline,
                    $ProcessSysmonSearchParentFilePath,
                    $ProcessSysmonSearchParentCommandline,
                    $ProcessSysmonSearchCompanyProduct
            )
                ComputerName = $TargetComputer
                AsJob        = $true
                JobName      = "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"
            }


            if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { Set-NewCredential }
                $InvokeCommandSplat += @{Credential = $script:Credential}
            }
            Invoke-Command @InvokeCommandSplat | Select-Object PSComputerName, *
        }
    }


    if     ($ProcessSysmonSearchRuleNameCheckbox)          {$CollectionName = "Process (Sysmon) Rule Name"}
    elseif ($ProcessSysmonSearchUserAccountIdCheckbox)     {$CollectionName = "Process (Sysmon) User Account, Id"}
    elseif ($ProcessSysmonSearchHashesCheckbox)            {$CollectionName = "Process (Sysmon) Hash"}
    elseif ($ProcessSysmonSearchFilePathCheckbox)          {$CollectionName = "Process (Sysmon) File Path"}
    elseif ($ProcessSysmonSearchCommandlineCheckbox)       {$CollectionName = "Process (Sysmon) Command Line"}
    elseif ($ProcessSysmonSearchParentFilePathCheckbox)    {$CollectionName = "Process (Sysmon) Parent File Path"}
    elseif ($ProcessSysmonSearchParentCommandlineCheckbox) {$CollectionName = "Process (Sysmon) Parent Command Line"}
    elseif ($ProcessSysmonSearchCompanyProductCheckbox)    {$CollectionName = "Process (Sysmon) Company Product"}


    $EndpointString = ''
    foreach ($item in $script:ComputerList) {$EndpointString += "$item`n"}

    $InputValues = @"
===========================================================================
Collection Name:
===========================================================================
$CollectionName

===========================================================================
Execution Time:
===========================================================================
$ExecutionStartTime

===========================================================================
Credentials:
===========================================================================
$($script:Credential.UserName)

===========================================================================
Endpoints:
===========================================================================
$($EndpointString.trim())

===========================================================================
Regular Expression:
===========================================================================
$($ProcessSysmonRegexCheckbox.checked)

===========================================================================
Search Terms:
===========================================================================

"@


    if   ($ProcessSysmonRegexCheckbox.checked) {$ProcessSysmonRegex = $True}
    else {$ProcessSysmonRegex = $False}


    if ($ProcessSysmonSearchRuleNameCheckbox) {
        $ProcessSysmonSearchRuleName = ($ProcessSysmonSearchRuleNameRichTextbox.Text).split("`r`n")
        $InputValues += $($ProcessSysmonSearchRuleName -join "`n")
    }
    else {$ProcessSysmonSearchRuleName = $null}


    if ($ProcessSysmonSearchUserAccountIdCheckbox) {
        $ProcessSysmonSearchUserAccountId = $ProcessSysmonSearchUserAccountIdRichTextbox.Lines
        $InputValues += $($ProcessSysmonSearchUserAccountId -join "`n")
    }
    else {$ProcessSysmonSearchUserAccountId = $null}


    if ($ProcessSysmonSearchHashesCheckbox) {
        $ProcessSysmonSearchHashes = ($ProcessSysmonSearchHashesRichTextbox.Text).split("`r`n")
        $InputValues += $($ProcessSysmonSearchHashes -join "`n")
    }
    else {$ProcessSysmonSearchHashes = $null}


    if ($ProcessSysmonSearchFilePathCheckbox) {
        $ProcessSysmonSearchFilePath = ($ProcessSysmonSearchFilePathRichTextbox.Text).split("`r`n")
        $InputValues += $($ProcessSysmonSearchFilePath -join "`n")
    }
    else {$ProcessSysmonSearchFilePath = $null}


    if ($ProcessSysmonSearchCommandlineCheckbox) {
        $ProcessSysmonSearchCommandline = ($ProcessSysmonSearchCommandlineRichTextbox.Text).split("`r`n")
        $InputValues += $($ProcessSysmonSearchCommandline -join "`n")
    }
    else {$ProcessSysmonSearchCommandline = $null}


    if ($ProcessSysmonSearchParentFilePathCheckbox) {
        $ProcessSysmonSearchParentFilePath = ($ProcessSysmonSearchParentFilePathRichTextbox.Text).split("`r`n")
        $InputValues += $($ProcessSysmonSearchParentFilePath -join "`n")
    }
    else {$ProcessSysmonSearchParentFilePath = $null}


    if ($ProcessSysmonSearchParentCommandlineCheckbox) {
        $ProcessSysmonSearchParentCommandline = ($ProcessSysmonSearchParentCommandlineRichTextBox.Text).split("`r`n")
        $InputValues += $($ProcessSysmonSearchParentCommandline -join "`n")
    }
    else {$ProcessSysmonSearchParentCommandline = $null}


    if ($ProcessSysmonSearchCompanyProductCheckbox) {
        $ProcessSysmonSearchCompanyProduct = ($ProcessSysmonSearchCompanyProductRichTextBox.Text).split("`r`n")
        $InputValues += $($ProcessSysmonSearchCompanyProduct -join "`n")
    }
    else {$ProcessSysmonSearchCompanyProduct = $null}


    $ExecutionStartTime = Get-Date
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Query: $CollectionName")
    $ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")


    $InvokeCommandSplat = @{
        ScriptBlock  = ${function:MonitorJobScriptBlock}
        ArgumentList = @($CollectionName,$ProcessSysmonRegex,$ProcessSysmonSearchRuleName,$ProcessSysmonSearchUserAccountId,$ProcessSysmonSearchHashes,$ProcessSysmonSearchFilePath,$ProcessSysmonSearchCommandline,$ProcessSysmonSearchParentFilePath,$ProcessSysmonSearchParentCommandline,$ProcessSysmonSearchCompanyProduct)
    }
    Invoke-Command @InvokeCommandSplat
    Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:MonitorJobScriptBlock} -ArgumentList @($CollectionName,$ProcessSysmonRegex,$ProcessSysmonSearchRuleName,$ProcessSysmonSearchUserAccountId,$ProcessSysmonSearchHashes,$ProcessSysmonSearchFilePath,$ProcessSysmonSearchCommandline,$ProcessSysmonSearchParentFilePath,$ProcessSysmonSearchParentCommandline,$ProcessSysmonSearchCompanyProduct) -InputValues $InputValues


    $CollectionCommandEndTime  = Get-Date
    $CollectionCommandDiffTime = New-TimeSpan -Start $ExecutionStartTime -End $CollectionCommandEndTime
    $ResultsListBox.Items.RemoveAt(0)
    $ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $CollectionName")


    Update-EndpointNotes
}




Update-FormProgress "IndividualQuery-NetworkSysmon"
function IndividualQuery-NetworkSysmon {
    <#
        .Description
        Loads the function used to query for various Sysmon Event ID 3 Network Connections logs
    #>
    param(
        [switch]$NetworkSysmonSearchSourceIPAddressCheckbox,
        [switch]$NetworkSysmonSearchSourcePortCheckbox,
        [switch]$NetworkSysmonSearchDestinationIPAddressCheckbox,
        [switch]$NetworkSysmonSearchDestinationPortCheckbox,
        [switch]$NetworkSysmonSearchAccountCheckbox,
        [switch]$NetworkSysmonSearchExecutablePathCheckbox
    )

    function MonitorJobScriptBlock {
        param(
            $CollectionName,
            $NetworkSysmonSearchSourceIPAddress,
            $NetworkSysmonSearchSourcePort,
            $NetworkSysmonSearchDestinationIPAddress,
            $NetworkSysmonSearchDestinationPort,
            $NetworkSysmonSearchAccount,
            $NetworkSysmonSearchExecutablePath,
            $NetworkSysmonRegex
        )

        foreach ($TargetComputer in $script:ComputerList) {
            Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $CollectedDataTimeStamp `
                                    -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                                    -TargetComputer $TargetComputer
            Write-LogEntry -TargetComputer $TargetComputer  -LogFile $PewLogFile -Message $CollectionName


            $NetworkSysmonScriptBlock = {
                    param(
                        $SourceIP        = $null,
                        $SourcePort      = $null,
                        $DestinationIP   = $null,
                        $DestinationPort = $null,
                        $Account         = $null,
                        $ExecutablePath  = $null,
                        $regex           = $false
                    )

                    $SysmonNetworkEventLogs = Get-WinEvent -FilterHashtable @{
                        LogName = 'Microsoft-Windows-Sysmon/Operational'
                        Id      = 3
                    }

                    $SysmonNetworkEventLogsFormatted = @()
                    Foreach ($event in ($SysmonNetworkEventLogs | Select-Object -Expand Message)) {
                        $SysmonNetworkEventLogsFormatted += [PSCustomObject]@{
                            'Event'               = ($event -split "`r`n")[0].TrimEnd(':')
                            'RuleName'            = (($event -split "`r`n")[1] -split ": ")[1]
                            'UtcTime'             = [datetime](($event -split "`r`n")[2] -split ": ")[1]
                            'ProcessGuid'         = (($event -split "`r`n")[3] -split ": ")[1].Replace('{','').Replace('}','')
                            'ProcessId'           = (($event -split "`r`n")[4] -split ": ")[1]
                            'Image'               = (($event -split "`r`n")[5] -split ": ")[1]
                            'User'                = (($event -split "`r`n")[6] -split ": ")[1]
                            'Protocol'            = (($event -split "`r`n")[7] -split ": ")[1]
                            'Initiated'           = (($event -split "`r`n")[8] -split ": ")[1]
                            'SourceIsIpv6'        = (($event -split "`r`n")[9] -split ": ")[1]
                            'SourceIp'            = (($event -split "`r`n")[10] -split ": ")[1]
                            'SourceHostname'      = (($event -split "`r`n")[11] -split ": ")[1]
                            'SourcePort'          = (($event -split "`r`n")[12] -split ": ")[1]
                            'SourcePortName'      = (($event -split "`r`n")[13] -split ": ")[1]
                            'DestinationIsIpv6'   = (($event -split "`r`n")[14] -split ": ")[1]
                            'DestinationIp'       = (($event -split "`r`n")[15] -split ": ")[1]
                            'DestinationHostname' = (($event -split "`r`n")[16] -split ": ")[1]
                            'DestinationPort'     = (($event -split "`r`n")[17] -split ": ")[1]
                            'DestinationPortName' = (($event -split "`r`n")[18] -split ": ")[1]
                        }
                    }

                    $SysmonNetworkConnectionEventFound = @()

                    foreach ($SysmonNetEvent in $SysmonNetworkEventLogsFormatted) {
                        if ($regex -eq $true) {
                            if     ($SourceIP)        { foreach ($SrcPort  in $SourceIP)        { if (($SysmonNetEvent.SourceIP            -match $SrcPort   -or
                                                                                                       $SysmonNetEvent.SourceHostName      -match $SrcPort)  -and ($SrcPort  -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
                            elseif ($SourcePort)      { foreach ($SrcPort  in $SourcePort)      { if (($SysmonNetEvent.SourcePort          -match $SrcPort   -or
                                                                                                       $SysmonNetEvent.SourcePortName      -match $SrcPort)  -and ($SrcPort  -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
                            elseif ($DestinationIP)   { foreach ($DestIP   in $DestinationIP)   { if (($SysmonNetEvent.DestinationIp       -match $DestIP    -or
                                                                                                       $SysmonNetEvent.DestinationHostname -match $DestIP)   -and ($DestIP   -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
                            elseif ($DestinationPort) { foreach ($DestPort in $DestinationPort) { if (($SysmonNetEvent.DestinationPort     -match $DestPort  -or
                                                                                                       $SysmonNetEvent.DestinationPortName -match $DestPort) -and ($DestPort -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
                            elseif ($Account)         { foreach ($User  in $Account)            { if (($SysmonNetEvent.User                -match $User)     -and ($User     -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
                            elseif ($ExecutablePath)  { foreach ($Path     in $ExecutablePath)  { if (($SysmonNetEvent.Image               -match $Path)     -and ($Path     -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
                        }
                        elseif ($regex -eq $false) {
                            if     ($SourceIP)        { foreach ($SrcPort  in $SourceIP)        { if (($SysmonNetEvent.SourceIP            -eq $SrcPort   -or
                                                                                                       $SysmonNetEvent.SourceHostName      -eq $SrcPort)  -and ($SrcPort  -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
                            elseif ($SourcePort)      { foreach ($SrcPort  in $SourcePort)      { if (($SysmonNetEvent.SourcePort          -eq $SrcPort   -or
                                                                                                       $SysmonNetEvent.SourcePortName      -eq $SrcPort)  -and ($SrcPort  -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
                            elseif ($DestinationIP)   { foreach ($DestIP   in $DestinationIP)   { if (($SysmonNetEvent.DestinationIp       -eq $DestIP    -or
                                                                                                       $SysmonNetEvent.DestinationHostname -eq $DestIP)   -and ($DestIP   -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
                            elseif ($DestinationPort) { foreach ($DestPort in $DestinationPort) { if (($SysmonNetEvent.DestinationPort     -eq $DestPort  -or
                                                                                                       $SysmonNetEvent.DestinationPortName -eq $DestPort) -and ($DestPort -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
                            elseif ($Account)         { foreach ($User  in $Account)            { if (($SysmonNetEvent.User                -eq $User)     -and ($User     -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
                            elseif ($ExecutablePath)  { foreach ($Path     in $ExecutablePath)  { if (($SysmonNetEvent.Image               -eq $Path)     -and ($Path     -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
                        }
                    }
                    return $SysmonNetworkConnectionEventFound | Select-Object -Property ComputerName, UtcTime, Protocol, SourceHostName, SourceIP, SourcePort, SourcePortName, DestinationHostName, DestinationIP, DestinationPort, DestinationPortName, User, ProcessId, Image, RuleName, Event, Initiated, SourceIsIPv6, DestinationIsIPv6, PSComputerName | Sort-Object -Property UtcTime
            }

            $InvokeCommandSplat = @{
                ScriptBlock  = $NetworkSysmonScriptBlock
                ArgumentList = @(
                    $NetworkSysmonSearchSourceIPAddress,
                    $NetworkSysmonSearchSourcePort,
                    $NetworkSysmonSearchDestinationIPAddress,
                    $NetworkSysmonSearchDestinationPort,
                    $NetworkSysmonSearchAccount,
                    $NetworkSysmonSearchExecutablePath,
                    $NetworkSysmonRegex
                )
                ComputerName = $TargetComputer
                AsJob        = $true
                JobName      = "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"
            }


            if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { Set-NewCredential }
                $InvokeCommandSplat += @{
                    Credential = $script:Credential
                }
            }
            Invoke-Command @InvokeCommandSplat | Select-Object PSComputerName, *
        }
    }



    if ($NetworkSysmonSearchSourceIPAddressCheckbox) {
        $CollectionName = "Network Connection (Sysmon) Source IP"
        $NetworkSysmonSearchSourceIPAddress = ($NetworkSysmonSearchSourceIPAddressRichTextbox.Text).split("`r`n")
    }
    else {
        $NetworkSysmonSearchSourceIPAddress = $null
    }


    if ($NetworkSysmonSearchSourcePortCheckbox) {
        $CollectionName = "Network Connection (Sysmon) Source Port"
        $NetworkSysmonSearchSourcePort = $NetworkSysmonSearchSourcePortRichTextbox.Lines
    }
    else {
        $NetworkSysmonSearchSourcePort = $null
    }


    if ($NetworkSysmonSearchDestinationIPAddressCheckbox) {
        $CollectionName = "Network Connection (Sysmon) Destination IP"
        $NetworkSysmonSearchDestinationIPAddress = ($NetworkSysmonSearchDestinationIPAddressRichTextbox.Text).split("`r`n")
    }
    else {
        $NetworkSysmonSearchDestinationIPAddress = $null
    }


    if ($NetworkSysmonSearchDestinationPortCheckbox) {
        $CollectionName = "Network Connection (Sysmon) Destination Port"
        $NetworkSysmonSearchDestinationPort = ($NetworkSysmonSearchDestinationPortRichTextbox.Text).split("`r`n")
    }
    else {
        $NetworkSysmonSearchDestinationPort = $null
    }


    if ($NetworkSysmonSearchAccountCheckbox) {
        $CollectionName = "Network Connection (Sysmon) Account-User Started"
        $NetworkSysmonSearchAccount = ($NetworkSysmonSearchAccountRichTextbox.Text).split("`r`n")
    }
    else {
        $NetworkSysmonSearchAccount = $null
    }


    if ($NetworkSysmonSearchExecutablePathCheckbox) {
        $CollectionName = "Network Connection (Sysmon) Executable Path"
        $NetworkSysmonSearchExecutablePath = ($NetworkSysmonSearchExecutablePathTextbox.Text).split("`r`n")
    }
    else {
        $NetworkSysmonSearchExecutablePath = $null
    }


    if ($NetworkSysmonRegexCheckbox.checked) {
        $NetworkSysmonRegex = $True
    }
    else {
        $NetworkSysmonRegex = $False
    }


    $ExecutionStartTime = Get-Date
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Query: $CollectionName")
    $ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")


    $EndpointString = ''
    foreach ($item in $script:ComputerList) {$EndpointString += "$item`n"}
    $SearchString = ''
    foreach ($item in $NetworkSysmonSearchDestinationIPAddress) {$SearchString += "$item`n" }

    $InputValues = @"
===========================================================================
Collection Name:
===========================================================================
$CollectionName

===========================================================================
Execution Time:
===========================================================================
$ExecutionStartTime

===========================================================================
Credentials:
===========================================================================
$($script:Credential.UserName)

===========================================================================
Endpoints:
===========================================================================
$($EndpointString.trim())

===========================================================================
Regular Expression:
===========================================================================
$NetworkSysmonRegex

===========================================================================
Remote IP Address:
===========================================================================
$($SearchString.trim())

"@



    if ($NetworkSysmonSearchSourceIPAddressCheckbox) {
        Invoke-Command -ScriptBlock ${function:MonitorJobScriptBlock} -ArgumentList @($CollectionName,$NetworkSysmonSearchSourceIPAddress,$null,$null,$null,$null,$null,$NetworkSysmonRegex)
        Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:MonitorJobScriptBlock} -ArgumentList @($CollectionName,$NetworkSysmonSearchSourceIPAddress,$null,$null,$null,$null,$null,$NetworkSysmonRegex) -InputValues $InputValues
    }


    if ($NetworkSysmonSearchSourcePortCheckbox) {
        Invoke-Command -ScriptBlock ${function:MonitorJobScriptBlock} -ArgumentList @($CollectionName,$null,$NetworkSysmonSearchSourcePort,$null,$null,$null,$null,$NetworkSysmonRegex)
        Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:MonitorJobScriptBlock} -ArgumentList @($CollectionName,$null,$NetworkSysmonSearchSourcePort,$null,$null,$null,$null,$NetworkSysmonRegex) -InputValues $InputValues
    }


    if ($NetworkSysmonSearchDestinationIPAddressCheckbox) {
        Invoke-Command -ScriptBlock ${function:MonitorJobScriptBlock} -ArgumentList @($CollectionName,$null,$null,$NetworkSysmonSearchDestinationIPAddress,$null,$null,$null,$NetworkSysmonRegex)
        Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:MonitorJobScriptBlock} -ArgumentList @($CollectionName,$null,$null,$NetworkSysmonSearchDestinationIPAddress,$null,$null,$null,$NetworkSysmonRegex) -InputValues $InputValues
    }


    if ($NetworkSysmonSearchDestinationPortCheckbox) {
        Invoke-Command -ScriptBlock ${function:MonitorJobScriptBlock} -ArgumentList @($CollectionName,$null,$null,$null,$NetworkSysmonSearchDestinationPort,$null,$null,$NetworkSysmonRegex)
        Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:MonitorJobScriptBlock} -ArgumentList @($CollectionName,$null,$null,$null,$NetworkSysmonSearchDestinationPort,$null,$null,$NetworkSysmonRegex) -InputValues $InputValues
    }


    if ($NetworkSysmonSearchAccountCheckbox) {
        Invoke-Command -ScriptBlock ${function:MonitorJobScriptBlock} -ArgumentList @($CollectionName,$null,$null,$null,$null,$NetworkSysmonSearchAccount,$null,$NetworkSysmonRegex)
        Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:MonitorJobScriptBlock} -ArgumentList @($CollectionName,$null,$null,$null,$null,$NetworkSysmonSearchAccount,$null,$NetworkSysmonRegex) -InputValues $InputValues
    }


    if ($NetworkSysmonSearchExecutablePathCheckbox) {
        Invoke-Command -ScriptBlock ${function:MonitorJobScriptBlock} -ArgumentList @($CollectionName,$null,$null,$null,$null,$null,$NetworkSysmonSearchExecutablePath,$NetworkSysmonRegex)
        Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:MonitorJobScriptBlock} -ArgumentList @($CollectionName,$null,$null,$null,$null,$null,$NetworkSysmonSearchExecutablePath,$NetworkSysmonRegex) -InputValues $InputValues
    }


    $CollectionCommandEndTime  = Get-Date
    $CollectionCommandDiffTime = New-TimeSpan -Start $ExecutionStartTime -End $CollectionCommandEndTime
    $ResultsListBox.Items.RemoveAt(0)
    $ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $CollectionName")

    Update-EndpointNotes
}




Update-FormProgress "Update-EndpointNotes"
function Update-EndpointNotes {
    if ($script:LogCommandsInEndpointNotes.checked) {
        # Updates endpoint notes with timestamp and command executed
        $script:ComputerTreeViewSelected = @()
        [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
        foreach ($root in $AllTreeViewNodes) {
            foreach ($Category in $root.Nodes) {
                foreach ($Entry in $Category.Nodes) {
                    Foreach ($Computer in $script:ComputerTreeViewData) {
                        if ($entry.checked -and $entry.text -eq $Computer.Name) {
                            $script:ComputerTreeViewSelected += $Entry.Text
                            $UpdatedNotes = "$(Get-Date) -- Executed: $CollectionName`n$($Computer.Notes)"
                            $Computer | Add-Member -MemberType NoteProperty -Name Notes -Value $UpdatedNotes -Force
                        }
                    }
                }
            }
        }
        Save-TreeViewData -Endpoint -SkipTextFieldSave
    }
}




Update-FormProgress "Get-PoShEasyWinStatistics"
function Get-PoShEasyWinStatistics {
    <#
        .Description
        Gets various statistics on PoSh-EasyWin such as number of queries and computer treenodes selected, and
        the number number of csv files and data storage consumed
    #>
    Compile-TreeViewCommand

    $StatisticsResults             = ""
    $StatisticsAllCSVFiles         = Get-Childitem -Path $PewCollectedData -Recurse -Include "*.csv"
    $StatisticsAllCSVFilesMeasured = $StatisticsAllCSVFiles | Measure-Object -Property Length -Sum -Average -Maximum -Minimum

    $StatisticsResults += "$('{0,-25}{1}' -f "Number of CSV files:", $($StatisticsAllCSVFilesMeasured.Count))`r`n"

    $StatisticsFirstCollection = $($StatisticsAllCSVFiles | Sort-Object -Property CreationTime | Select-Object -First 1).CreationTime
    $StatisticsResults += "$('{0,-25}{1}' -f "First query datetime:", $StatisticsFirstCollection)`r`n"

    $StatisticsLatestCollection = $($StatisticsAllCSVFiles | Sort-Object -Property CreationTime | Select-Object -Last 1).CreationTime
    $StatisticsResults += "$('{0,-25}{1}' -f "Latest query datetime:", $StatisticsLatestCollection)`r`n"

    $StatisticsAllCSVFilesSum = $(
        $CSVBytes = $StatisticsAllCSVFilesMeasured.Sum
        if ($CSVBytes -gt 1GB) {"{0:N3} GB" -f $($CSVBytes / 1GB)}
        elseif ($CSVBytes -gt 1MB) {"{0:N3} MB" -f $($CSVBytes / 1MB)}
        elseif ($CSVBytes -gt 1KB) {"{0:N3} KB" -f $($CSVBytes / 1KB)}
        else {"{0:N3} Bytes" -f $CSVBytes}
    )
    $StatisticsResults += "$('{0,-25}{1}' -f "Total CSV Data:", $StatisticsAllCSVFilesSum)`r`n"

    $StatisticsAllCSVFilesAverage = $(
        $CSVBytes = $StatisticsAllCSVFilesMeasured.Average
        if ($CSVBytes -gt 1GB) {"{0:N3} GB" -f $($CSVBytes / 1GB)}
        elseif ($CSVBytes -gt 1MB) {"{0:N3} MB" -f $($CSVBytes / 1MB)}
        elseif ($CSVBytes -gt 1KB) {"{0:N3} KB" -f $($CSVBytes / 1KB)}
        else {"{0:N3} Bytes" -f $CSVBytes}
    )
    $StatisticsResults += "$('{0,-25}{1}' -f "Average CSV filesize:", $StatisticsAllCSVFilesAverage)`r`n"

    $StatisticsAllCSVFilesMaximum = $(
        $CSVBytes = $StatisticsAllCSVFilesMeasured.Maximum
        if ($CSVBytes -gt 1GB) {"{0:N3} GB" -f $($CSVBytes / 1GB)}
        elseif ($CSVBytes -gt 1MB) {"{0:N3} MB" -f $($CSVBytes / 1MB)}
        elseif ($CSVBytes -gt 1KB) {"{0:N3} KB" -f $($CSVBytes / 1KB)}
        else {"{0:N3} Bytes" -f $CSVBytes}
    )
    $StatisticsResults += "$('{0,-25}{1}' -f "Largest CSV filesize:", $StatisticsAllCSVFilesMaximum)`r`n"

    $StatisticsAllCSVFilesMinimum = $(
        $CSVBytes = $StatisticsAllCSVFilesMeasured.Minimum
        if ($CSVBytes -gt 1GB) {"{0:N3} GB" -f $($CSVBytes / 1GB)}
        elseif ($CSVBytes -gt 1MB) {"{0:N3} MB" -f $($CSVBytes / 1MB)}
        elseif ($CSVBytes -gt 1KB) {"{0:N3} KB" -f $($CSVBytes / 1KB)}
        else {"{0:N3} Bytes" -f $CSVBytes}
    )
    $StatisticsResults += "$('{0,-25}{1}' -f "Smallest CSV filesize:", $StatisticsAllCSVFilesMinimum)`r`n"

    $StatisticsResults += "`r`n"
    $StatisticsLogFile = Get-ItemProperty -Path $PewLogFile

    $NumberOfLogEntries = (get-content -path $PewLogFile | Select-String -Pattern '\d{4}/\d{2}/\d{2} \d{2}[:]\d{2}[:]\d{2} [-] ').count
    $StatisticsResults += "$('{0,-25}{1}' -f "Number of Log Entries:", $NumberOfLogEntries)`r`n"

    $StatisticsLogFileSize = $(
        $PewLogFileSize = $StatisticsLogFile.Length
        if ($PewLogFileSize -gt 1GB) {"{0:N3} GB" -f $($PewLogFileSize / 1GB)}
        elseif ($PewLogFileSize -gt 1MB) {"{0:N3} MB" -f $($PewLogFileSize / 1MB)}
        elseif ($PewLogFileSize -gt 1KB) {"{0:N3} KB" -f $($PewLogFileSize / 1KB)}
        else {"{0:N3} Bytes" -f $PewLogFileSize}
    )
    $StatisticsResults += "$('{0,-25}{1}' -f "Logfile filesize:", $StatisticsLogFileSize)`r`n"

    $StatisticsResults += "`r`n"
    $StatisticsComputerCount = 0
    [System.Windows.Forms.TreeNodeCollection]$StatisticsAllHostsNode = $script:ComputerTreeView.Nodes
    foreach ($root in $StatisticsAllHostsNode) {foreach ($Category in $root.Nodes) {foreach ($Entry in $Category.nodes) {if ($Entry.Checked) { $StatisticsComputerCount++ }}}}
    $StatisticsResults += "$('{0,-25}{1}' -f "Computers Selected:", $StatisticsComputerCount)`r`n"
    $StatisticsResults += "$('{0,-25}{1}' -f "Queries Selected:", $QueryCount)`r`n"

    $ResourcesDirCheck = Test-Path -Path "$Dependencies"
    $StatisticsResults += "$('{0,-25}{1}' -f "Dependancies Check:", $ResourcesDirCheck)`r`n"

    return $StatisticsResults
}




Update-FormProgress "Conduct-FileSearch"
function Conduct-FileSearch {
    <#
        .Description
        This code is used within the Individual execution modes
    #>
    param($DirectoriesToSearch,$FilesToSearch,$MaximumDepth,$GetChildItemDepth,$GetFileHash,$FileHashSelection)

    #Invoke-Expression $GetChildItemDepth
    Function Get-ChildItemDepth {
        Param(
            [String[]]$Path     = $PWD,
            [String]$Filter     = "*",
            [Byte]$Depth        = 255,
            [Byte]$CurrentDepth = 0
        )
        $CurrentDepth++
        Get-ChildItem $Path -Force | ForEach-Object {
            $_ | Where-Object { $_.Name -Like $Filter }
            If ($_.PsIsContainer) {
                If ($CurrentDepth -le $Depth) {
                    # Callback to this function
                    Get-ChildItemDepth -Path $_.FullName -Filter $Filter -Depth $Depth -CurrentDepth $CurrentDepth
                }
            }
        }
    }

    #Invoke-Expression $GetFileHash
    function Get-FileHash{
        param (
            [string]$Path,
            [string]$Algorithm
        )
        if     ($Algorithm -eq 'MD5')       {$HashAlgorithm = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider}
        elseif ($Algorithm -eq 'SHA1')      {$HashAlgorithm = New-Object -TypeName System.Security.Cryptography.SHA1CryptoServiceProvider}
        elseif ($Algorithm -eq 'SHA256')    {$HashAlgorithm = New-Object -TypeName System.Security.Cryptography.SHA256CryptoServiceProvider}
        elseif ($Algorithm -eq 'SHA384')    {$HashAlgorithm = New-Object -TypeName System.Security.Cryptography.SHA384CryptoServiceProvider}
        elseif ($Algorithm -eq 'SHA512')    {$HashAlgorithm = New-Object -TypeName System.Security.Cryptography.SHA512CryptoServiceProvider}
        elseif ($Algorithm -eq 'RIPEMD160') {$HashAlgorithm = New-Object -TypeName System.Security.Cryptography.RIPEMD160Managed}
        $Hash=[System.BitConverter]::ToString($HashAlgorithm.ComputeHash([System.IO.File]::ReadAllBytes($Path)))
        $Properties = @{
            "Path"       = $Path
            "Hash"       = $Hash.Replace("-", "")
            "Algorithm"  = $Algorithm
            "ScriptNote" = 'Get-FileHash Script For Backwards Compatibility'
        }
        $ReturnFileHash = New-Object â€“TypeName PSObject â€“Prop $Properties
        return $ReturnFileHash
    }


    if ([int]$MaximumDepth -gt 0) {
        # Older operating systems don't support the -depth parameter, this function was created for backwards compatability
        $AllFiles = @()
        foreach ($Directory in $DirectoriesToSearch){
            $AllFiles += Get-ChildItemDepth -Path "$Directory" -Depth $MaximumDepth -Force -ErrorAction SilentlyContinue
        }
    }
    else {
        $AllFiles = @()
        foreach ($Directory in $DirectoriesToSearch){
            $AllFiles += Get-ChildItem -Path "$Directory" -Force -ErrorAction SilentlyContinue
        }
    }
    $AllFiles = $AllFiles | Sort-Object -Unique

    $foundlist = @()
    foreach ($File in $AllFiles){
        foreach ($SearchItem in $FilesToSearch) {
            if ($FileHashSelection -eq 'Filename') {
                if ($File.name -match $SearchItem.trim()){
                    if ($File.FullName -notin $FoundList) { $foundlist += $File }
                }
            }
            if ($FileHashSelection -eq 'MD5') {
                $FileHash = Get-FileHash -Path $($File.FullName) -Algorithm 'MD5'
                if ($FileHash.Hash -eq $SearchItem.trim()){
                    $File | Add-Member -MemberType NoteProperty -Name 'FileHash'          -Value $FileHash.Hash       -Force
                    $File | Add-Member -MemberType NoteProperty -Name 'FileHashAlgorithm' -Value $FileHash.Algorithm  -Force
                    $File | Add-Member -MemberType NoteProperty -Name 'ScriptNote'        -Value $FileHash.ScriptNote -Force
                    if ($File.FullName -notin $FoundList) { $foundlist += $File }
                }
            }
            elseif ($FileHashSelection -eq 'SHA1') {
                $FileHash = Get-FileHash -Path $($File.FullName) -Algorithm 'SHA1'
                if ($FileHash.Hash -eq $SearchItem.trim()){
                    $File | Add-Member -MemberType NoteProperty -Name 'FileHash'          -Value $FileHash.Hash       -Force
                    $File | Add-Member -MemberType NoteProperty -Name 'FileHashAlgorithm' -Value $FileHash.Algorithm  -Force
                    $File | Add-Member -MemberType NoteProperty -Name 'ScriptNote'        -Value $FileHash.ScriptNote -Force
                    if ($File.FullName -notin $FoundList) { $foundlist += $File }
                }
            }
            elseif ($FileHashSelection -eq 'SHA256') {
                $FileHash = Get-FileHash -Path $($File.FullName) -Algorithm 'SHA256'
                if ($FileHash.Hash -eq $SearchItem.trim()){
                    $File | Add-Member -MemberType NoteProperty -Name 'FileHash'          -Value $FileHash.Hash       -Force
                    $File | Add-Member -MemberType NoteProperty -Name 'FileHashAlgorithm' -Value $FileHash.Algorithm  -Force
                    $File | Add-Member -MemberType NoteProperty -Name 'ScriptNote'        -Value $FileHash.ScriptNote -Force
                    if ($File.FullName -notin $FoundList) { $foundlist += $File }
                }
            }
            elseif ($FileHashSelection -eq 'SHA384') {
                $FileHash = Get-FileHash -Path $($File.FullName) -Algorithm 'SHA384'
                if ($FileHash.Hash -eq $SearchItem.trim()){
                    $File | Add-Member -MemberType NoteProperty -Name 'FileHash'          -Value $FileHash.Hash       -Force
                    $File | Add-Member -MemberType NoteProperty -Name 'FileHashAlgorithm' -Value $FileHash.Algorithm  -Force
                    $File | Add-Member -MemberType NoteProperty -Name 'ScriptNote'        -Value $FileHash.ScriptNote -Force
                    if ($File.FullName -notin $FoundList) { $foundlist += $File }
                }
            }
            elseif ($FileHashSelection -eq 'SHA512') {
                $FileHash = Get-FileHash -Path $($File.FullName) -Algorithm 'SHA512'
                if ($FileHash.Hash -eq $SearchItem.trim()){
                    $File | Add-Member -MemberType NoteProperty -Name 'FileHash'          -Value $FileHash.Hash       -Force
                    $File | Add-Member -MemberType NoteProperty -Name 'FileHashAlgorithm' -Value $FileHash.Algorithm  -Force
                    $File | Add-Member -MemberType NoteProperty -Name 'ScriptNote'        -Value $FileHash.ScriptNote -Force
                    if ($File.FullName -notin $FoundList) { $foundlist += $File }
                }
            }
            elseif ($FileHashSelection -eq 'RIPEMD160') {
                $FileHash = Get-FileHash -Path $($File.FullName) -Algorithm 'RIPEMD160'
                if ($FileHash.Hash -eq $SearchItem.trim()){
                    $File | Add-Member -MemberType NoteProperty -Name 'FileHash'          -Value $FileHash.Hash       -Force
                    $File | Add-Member -MemberType NoteProperty -Name 'FileHashAlgorithm' -Value $FileHash.Algorithm  -Force
                    $File | Add-Member -MemberType NoteProperty -Name 'ScriptNote'        -Value $FileHash.ScriptNote -Force
                    if ($File.FullName -notin $FoundList) { $foundlist += $File }
                }
            }
        }
    }
    return $FoundList
}




Update-FormProgress "CustomQueryScriptBlock"
function CustomQueryScriptBlock {
    <#
        .Description
        Scriptblock that is executed to manage the Query Build features such as the interactions between
        the textbox and button, launching Show-Command, variable manipulation, and message prompts
    #>
    param(
        [switch]$Build
    )

    $PSDefaultParameterValues = @{
        "Show-Command:Height" = 700
        "Show-Command:Width" = 1000
#        "Show-Command:ErrorPopup" = $True
    }
    if ($script:CustomQueryScriptBlockDisableSyntaxCheckbox.checked) {
        $script:ShowCommandQueryBuild = $script:CustomQueryScriptBlockTextbox.text
        if ($script:ShowCommandQueryBuild -eq $null) {
            $script:CustomQueryScriptBlockTextbox.text = $script:ShowCommandQueryBuild
            $script:CustomQueryScriptBlockTextbox.forecolor = 'black'
            $script:CustomQueryScriptBlockSaved = $script:ShowCommandQueryBuild
            $CustomQueryScriptBlockCheckBox.enabled = $true
            $CustomQueryScriptBlockAddCommandButton.Enabled = $true
            $CustomQueryScriptBlockAddCommandButton.BackColor = 'LightBlue'
        }
        if ($script:ShowCommandQueryBuild -match '-ComputerName') {
            [System.Windows.Forms.MessageBox]::Show("Error: Do not include the -ComputerName parameter.`nRather, make a selection from the Computer Treeview.","PoSh-EasyWin Query Builder",'Ok','Error')

            $script:ShowCommandQueryBuild = $script:ShowCommandQueryBuild -replace "-ComputerName\s(')?(\w|[0-9a-z_-])*(')?\s?",""
            $script:CustomQueryScriptBlockTextbox.text = $script:ShowCommandQueryBuild
            $script:CustomQueryScriptBlockTextbox.forecolor = 'black'
            $script:CustomQueryScriptBlockSaved = $script:ShowCommandQueryBuild
            $CustomQueryScriptBlockCheckBox.enabled = $true
        }
        elseif ($script:ShowCommandQueryBuild -eq $null) {
            $CustomQueryScriptBlockCheckBox.enabled = $true
            $script:CustomQueryScriptBlockSaved =  $script:CustomQueryScriptBlockTextbox.text
        }
    }
    elseif ($Build){
        $script:ShowCommandQueryBuild = Show-Command -PassThru

        if ($script:ShowCommandQueryBuild -eq $null) {
            $script:CustomQueryScriptBlockTextbox.text = 'Enter a cmdlet'
            $script:CustomQueryScriptBlockTextbox.forecolor = 'black'
            $CustomQueryScriptBlockCheckBox.checked = $false
            $CustomQueryScriptBlockCheckBox.enabled = $false
            $CustomQueryScriptBlockAddCommandButton.Enabled = $false
            $CustomQueryScriptBlockAddCommandButton.BackColor = 'LightGray'
        }
        else {
            $script:CustomQueryScriptBlockTextbox.text = $script:ShowCommandQueryBuild
            $script:CustomQueryScriptBlockTextbox.forecolor = 'black'
            $script:CustomQueryScriptBlockSaved = $script:ShowCommandQueryBuild
            $CustomQueryScriptBlockCheckBox.enabled = $true
            $CustomQueryScriptBlockAddCommandButton.Enabled = $true
            $CustomQueryScriptBlockAddCommandButton.BackColor = 'LightBlue'
        }

        if ($script:ShowCommandQueryBuild -match '-ComputerName') {
            [System.Windows.Forms.MessageBox]::Show("Error: Do not include the -ComputerName parameter.`nRather, make a selection from the Computer Treeview.","PoSh-EasyWin Query Builder",'Ok','Error')

            $script:ShowCommandQueryBuild = $script:ShowCommandQueryBuild -replace "-ComputerName\s(')?(\w|[0-9a-z_-])*(')?\s?",""
            $script:CustomQueryScriptBlockTextbox.text = $script:ShowCommandQueryBuild
            $script:CustomQueryScriptBlockTextbox.forecolor = 'black'
            $script:CustomQueryScriptBlockSaved = $script:ShowCommandQueryBuild
            $CustomQueryScriptBlockCheckBox.enabled = $true
        }
        elseif ($script:ShowCommandQueryBuild -eq $null) {
            $CustomQueryScriptBlockCheckBox.enabled = $true
            $script:CustomQueryScriptBlockSaved =  $script:CustomQueryScriptBlockTextbox.text
        }

    }
    else {
        $CustomQueryCheck = $true
        if ($CustomQueryCheck -eq $true) {
            if ($script:CustomQueryScriptBlockTextbox.text -eq 'Enter a cmdlet') {
                [System.Windows.Forms.MessageBox]::Show("Error: Enter a cmdlet that is avaible within a module on this endpoint.","PoSh-EasyWin Query Builder",'Ok','Error')
                $CustomQueryCheck = $false
                $CustomQueryScriptBlockCheckBox.checked = $false
                $CustomQueryScriptBlockCheckBox.enabled = $false
            }
            elseif ($(($script:CustomQueryScriptBlockTextbox.text -split ' ')[0]) -in $script:CmdletList -and $script:CustomQueryScriptBlockTextbox.text -notin $script:CmdletList) {
                [System.Windows.Forms.MessageBox]::Show("The entered cmdlet and any parameters will be updated.","PoSh-EasyWin Query Builder",'Ok','Info')
                $CustomQueryCheck = $true
            }
            elseif ($script:CustomQueryScriptBlockTextbox.text -notin $script:CmdletList) {
                [System.Windows.Forms.MessageBox]::Show("Error: The following is not an available command:`n`n$($script:CustomQueryScriptBlockTextbox.text)","PoSh-EasyWin Query Builder",'Ok','Error')
                $CustomQueryCheck = $false
                $CustomQueryScriptBlockCheckBox.checked = $false
                $CustomQueryScriptBlockCheckBox.enabled = $false
            }

            if (($script:CustomQueryScriptBlockTextbox.text -split ' ').count -eq 1){
                $script:ShowCommandQueryBuild = Show-Command -Name $script:CustomQueryScriptBlockTextbox.text -PassThru
            }
            elseif (($script:CustomQueryScriptBlockTextbox.text -split ' ').count -gt 1){
                $script:ShowCommandQueryBuild = Show-Command -Name $($script:CustomQueryScriptBlockTextbox.text -split ' ')[0] -PassThru
            }

            if ($script:ShowCommandQueryBuild -eq $null) {
                $script:CustomQueryScriptBlockTextbox.text = 'Enter a cmdlet'
                $script:CustomQueryScriptBlockTextbox.forecolor = 'black'
                $CustomQueryScriptBlockCheckBox.checked = $false
                $CustomQueryScriptBlockCheckBox.enabled = $false
                $CustomQueryScriptBlockAddCommandButton.Enabled = $false
                $CustomQueryScriptBlockAddCommandButton.BackColor = 'LightGray'
            }
            else {
                $script:CustomQueryScriptBlockTextbox.text = $script:ShowCommandQueryBuild
                $script:CustomQueryScriptBlockSaved = $script:ShowCommandQueryBuild
                $script:CustomQueryScriptBlockTextbox.forecolor = 'black'
                $CustomQueryScriptBlockCheckBox.enabled = $true
                $CustomQueryScriptBlockAddCommandButton.Enabled = $true
                $CustomQueryScriptBlockAddCommandButton.BackColor = 'LightBlue'
            }

            if ($script:ShowCommandQueryBuild -match '-ComputerName') {
                [System.Windows.Forms.MessageBox]::Show("Error: Do not include the -ComputerName parameter.`nRather, make a selection from the Computer Treeview.","PoSh-EasyWin Query Builder",'Ok','Error')

                $script:ShowCommandQueryBuild = $script:ShowCommandQueryBuild -replace "-ComputerName\s(')?(\w|[0-9a-z_-])*(')?\s?",""
                $script:CustomQueryScriptBlockTextbox.text = $script:ShowCommandQueryBuild
                $script:CustomQueryScriptBlockTextbox.forecolor = 'black'
                $script:CustomQueryScriptBlockSaved = $script:ShowCommandQueryBuild
                $CustomQueryScriptBlockCheckBox.enabled = $true
            }
            elseif ($script:ShowCommandQueryBuild -eq $null) {
                $CustomQueryScriptBlockCheckBox.enabled = $true
                $script:CustomQueryScriptBlockSaved =  $script:CustomQueryScriptBlockTextbox.text
            }
        }
    }
}



Update-FormProgress "Deselect-AllAccounts"
function Deselect-AllAccounts {
    #$script:AccountsTreeView.Nodes.Clear()
    [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:AccountsTreeView.Nodes
    foreach ($root in $AllTreeViewNodes) {
        #if ($root.Checked) { $root.Checked = $false }
        $root.Checked = $false
        foreach ($Category in $root.Nodes) {
            #if ($Category.Checked) { $Category.Checked = $false }
            $Category.Checked = $false
            foreach ($Entry in $Category.nodes) {
                #if ($Entry.Checked) { $Entry.Checked = $false }
                $Entry.Checked = $false
                $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,0,0)
                $Category.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
            }
        }
    }
    Update-TreeViewData -Endpoint -TreeView $script:AccountsTreeView.Nodes
}



Update-FormProgress "Deselect-AllCommands"
function Deselect-AllCommands {
    <#
        .Description
        Deselects all nodes within the indicated treeview
    #>
    [System.Windows.Forms.TreeNodeCollection]$AllCommandsNode = $script:CommandsTreeView.Nodes
    foreach ($root in $AllCommandsNode) {
        $root.Checked   = $false
        $root.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
        $root.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
        $root.Collapse()
        if ($root.text -notmatch 'Custom Group Commands') { $root.Expand() }
        foreach ($Category in $root.Nodes) {
            $Category.Checked   = $false
            $Category.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
            $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
            $Category.Collapse()
            foreach ($Entry in $Category.nodes) {
                $Entry.Checked   = $false
                $Entry.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                $Entry.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
            }
        }
    }

    foreach ($CheckBox in $script:AllCheckBoxesList) {
        $CheckBox.checked = $false
        $CheckBox.ForeColor = 'Blue'
    }

    $script:PreviousQueryCount = 0
    $script:SectionQueryCount = 0

    # This has the added affect of updating the command count which in part has to do with the disable/color change of the 'Execute Script' button
    Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
}



Update-FormProgress "Deselect-AllComputers"
function Deselect-AllComputers {
    <#
        .Description
        Deselects all nodes within the indicated treeview
    #>
    #$script:ComputerTreeView.Nodes.Clear()
    [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
    foreach ($root in $AllTreeViewNodes) {
        #if ($root.Checked) { $root.Checked = $false }
        $root.Checked = $false
        foreach ($Category in $root.Nodes) {
            #if ($Category.Checked) { $Category.Checked = $false }
            $Category.Checked = $false
            foreach ($Entry in $Category.nodes) {
                #if ($Entry.Checked) { $Entry.Checked = $false }
                $Entry.Checked = $false
                $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,0,0)
                $Category.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
            }
        }
    }
    Update-TreeViewData -Endpoint -TreeView $script:ComputerTreeView.Nodes
}



Update-FormProgress "FolderBrowserDialog-UserSpecifiedExecutable"
function FolderBrowserDialog-UserSpecifiedExecutable {
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null

    if (Test-Path "$PewRoot\User Specified Executable And Script") {$ExecAndScriptDir = "$PewRoot\User Specified Executable And Script"}
    else {$ExecAndScriptDir = "$PewRoot"}

    if ($ExeScriptScriptOnlyCheckbox.checked -eq $False) {
        if ($ExeScriptSelectDirRadioButton.checked) {
            $ExeScriptSelectExecutableFolderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{
                #RootFolder = $PewRoot
                SelectedPath = $ExecAndScriptDir
                ShowNewFolderButton = $false
            }
            $ExeScriptSelectExecutableFolderBrowserDialog.ShowDialog()

            if ($($ExeScriptSelectExecutableFolderBrowserDialog.SelectedPath)) {
                $script:ExeScriptSelectDirOrFilePath = $ExeScriptSelectExecutableFolderBrowserDialog.SelectedPath

                $ExeScriptSelectExecutableTextBox.text = "$(($ExeScriptSelectExecutableFolderBrowserDialog.SelectedPath).split('\')[-1])"
            }
        }
    }
    if ($ExeScriptSelectFileRadioButton.checked) {
        $ExeScriptSelectExecutableOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{
            Title = "Select Executable File"
            Filter = "Executable (*.exe)| *.exe|Windows Installer (*.msi)| *.msi|All files (*.*)|*.*"
            ShowHelp = $true
            InitialDirectory = $ExecAndScriptDir
        }
        $ExeScriptSelectExecutableOpenFileDialog.ShowDialog()

        if ($($ExeScriptSelectExecutableOpenFileDialog.filename)) {
            $script:ExeScriptSelectDirOrFilePath = $ExeScriptSelectExecutableOpenFileDialog.filename

            $ExeScriptSelectExecutableTextBox.text = "$(($ExeScriptSelectExecutableOpenFileDialog.filename).split('\')[-1])"
        }
    }
}



Update-FormProgress "Get-AccountLogonActivity"
Function Get-AccountLogonActivity {
    Param (
        [datetime]$StartTime,
        [datetime]$EndTime,
        $AccountActivityTextboxtext
    )
    function LogonTypes {
        param($number)
        switch ($number) {
            0  { 'LocalSystem' }
            2  { 'Interactive' }
            3  { 'Network' }
            4  { 'Batch' }
            5  { 'Service' }
            7  { 'Unlock' }
            8  { 'NetworkClearText' }
            9  { 'NewCredentials' }
            10 { 'RemoteInteractive' }
            11 { 'CachedInteractive' }
            12 { 'CachedRemoteInteractive' }
            13 { 'CachedUnlock' }
        }
    }

    function LogonInterpretation {
        param($number)
        switch ($number) {
            0  { 'Local System' }
            2  { 'Logon Via Console' }
            3  { 'Network Remote Logon' }
            4  { 'Scheduled Task Logon' }
            5  { 'Windows Service Account Logon' }
            7  { 'Screen Unlock' }
            8  { 'Clear Text Network Logon' }
            9  { 'Alt Credentials Other Than Logon' }
            10 { 'RDP TS RemoteAssistance' }
            11 { 'Cached Local Credentials' }
            12 { 'Cached RDP TS RemoteAssistance' }
            13 { 'Cached Screen Unlock' }
        }
    }

    $FilterHashTable = @{
        LogName   = 'Security'
        ID        = 4624,4625,4634,4647,4648
    }
    if ($PSBoundParameters.ContainsKey('StartTime')){
        $FilterHashTable['StartTime'] = $StartTime
    }
    if ($PSBoundParameters.ContainsKey('EndTime')){
        $FilterHashTable['EndTime'] = $EndTime
    }

    Get-WinEvent -FilterHashtable $FilterHashTable `
    | Set-Variable GetAccountActivity -Force

    if ($AccountActivityTextboxtext.count -ge 1 -and $AccountActivityTextboxtext -notmatch 'Default is All Accounts') {
        $ObtainedAccountActivity = $GetAccountActivity | ForEach-Object {
            [pscustomobject]@{
                TimeStamp            = $_.TimeCreated
                UserAccount          = $_.Properties.Value[5]
                UserDomain           = $_.Properties.Value[6]
                Type                 = $_.Properties.Value[8]
                LogonType            = "$(LogonTypes -number $($_.Properties.Value[8]))"
                LogonInterpretation  = "$(LogonInterpretation -number $($_.Properties.Value[8]))"
                WorkstationName      = $_.Properties.Value[11]
                SourceNetworkAddress = $_.Properties.Value[18]
                SourceNetworkPort    = $_.Properties.Value[19]
            }
        }
        ForEach ($AccountName in $AccountActivityTextboxtext) {
            $ObtainedAccountActivity | Where-Object {$_.UserAccount -match $AccountName} | Sort-Object TimeStamp
        }
    }
    elseif ($AccountActivityTextboxtext.count -eq 1 -and $AccountActivityTextboxtext -match 'Default is All Accounts') {
        $ObtainedAccountActivity = $GetAccountActivity | ForEach-Object {
            [pscustomobject]@{
                TimeStamp            = $_.TimeCreated
                UserAccount          = $_.Properties.Value[5]
                UserDomain           = $_.Properties.Value[6]
                Type                 = $_.Properties.Value[8]
                LogonType            = "$(LogonTypes -number $($_.Properties.Value[8]))"
                LogonInterpretation  = "$(LogonInterpretation -number $($_.Properties.Value[8]))"
                WorkstationName      = $_.Properties.Value[11]
                SourceNetworkAddress = $_.Properties.Value[18]
                SourceNetworkPort    = $_.Properties.Value[19]
            }
        }
        $ObtainedAccountActivity | Sort-Object TimeStamp
    }
}




Update-FormProgress "Get-ChildItemDepth"
# This function is created within a string variable as it is used with an an agrument for Invoke-Command
# It is initialized below with an Invoke-Expression
# batman look into if this is still used
$GetChildItemDepth = @'
    Function Get-ChildItemDepth {
        Param(
            [String[]]$Path     = $PWD,
            [String]$Filter     = "*",
            [Byte]$Depth        = 255,
            [Byte]$CurrentDepth = 0
        )

        $CurrentDepth++
        Get-ChildItem $Path -Force | Foreach {
            $_ | Where-Object { $_.Name -Like $Filter }

            If ($_.PsIsContainer) {
                If ($CurrentDepth -le $Depth) {
                    # Callback to this function
                    Get-ChildItemDepth -Path $_.FullName -Filter $Filter -Depth $Depth -CurrentDepth $CurrentDepth

                }
            }
        }
    }
'@
Invoke-Expression -Command $GetChildItemDepth




Update-FormProgress "Get-FileHash"
# This function is created within a string variable as it is used with an an agrument for Invoke-Command
# It is initialized below with an Invoke-Expression
# batman look into if this is still used
$GetFileHash = @'
function Get-FileHash {
    param (
        [string]$Path,
        [string]$Algorithm
    )
    if ($Algorithm -eq 'MD5') {
        $HashAlgorithm = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
    }
    elseif ($Algorithm -eq 'SHA1') {
        $HashAlgorithm = New-Object -TypeName System.Security.Cryptography.SHA1CryptoServiceProvider
    }
    elseif ($Algorithm -eq 'SHA256') {
        $HashAlgorithm = New-Object -TypeName System.Security.Cryptography.SHA256CryptoServiceProvider
    }
    elseif ($Algorithm -eq 'SHA384') {
        $HashAlgorithm = New-Object -TypeName System.Security.Cryptography.SHA384CryptoServiceProvider
    }
    elseif ($Algorithm -eq 'SHA512') {
        $HashAlgorithm = New-Object -TypeName System.Security.Cryptography.SHA512CryptoServiceProvider
    }
    elseif ($Algorithm -eq 'RIPEMD160') {
        $HashAlgorithm = New-Object -TypeName System.Security.Cryptography.RIPEMD160Managed
    }


    $Hash=[System.BitConverter]::ToString($HashAlgorithm.ComputeHash([System.IO.File]::ReadAllBytes($Path)))

    $Properties = @{
        "Path"       = $Path
        "Hash"       = $Hash.Replace("-", "")
        "Algorithm"  = $Algorithm
        "ScriptNote" = 'Get-FileHash Script For Backwards Compatibility'
    }
    $ReturnFileHash = New-Object â€“TypeName PSObject â€“Prop $Properties
    return $ReturnFileHash
}
'@
Invoke-Expression -Command $GetFileHash




Update-FormProgress "Get-DNSCache"
function Get-DNSCache {
    param(
        $NetworkConnectionSearchDNSCache,
        $Regex
    )
    $DNSQueryCache = Get-DnsClientCache
    $DNSQueryFoundList = @()
    foreach ($DNSQuery in $NetworkConnectionSearchDNSCache) {
        if ($Regex -eq $true){
            $DNSQueryFoundList += $DNSQueryCache | Where-Object {
                ($_.name -match $DNSQuery) -or ($_.entry -match $DNSQuery) -or ($_.data -match $DNSQuery)
            }
        }
        if ($Regex -eq $false){
            $DNSQueryFoundList += $DNSQueryCache | Where-Object {
                ($_.name -eq $DNSQuery) -or ($_.entry -eq $DNSQuery) -or ($_.data -eq $DNSQuery)
            }
        }
    }
    $DNSQueryFoundList | Select-Object -Property PSComputerName, Entry, Name, Data, Type, Status, Section, TTL, DataLength
}




Update-FormProgress "Get-RemoteAlternateDataStream"
function Get-RemoteAlternateDataStream {
    param(
        $Files
    )
    $SelectedFilesToExtractStreamData = $Files

    if ($SelectedFilesToExtractStreamData) {
        $DownloadSize = $SelectedFilesToExtractStreamData | Select-Object -ExpandProperty length | Measure-Object -Sum | Select-Object -ExpandProperty Sum
        if     ($DownloadSize -gt 1000000000) { $DownloadSize = "$([Math]::Round($($DownloadSize / 1gb),2)) GB" }
        elseif ($DownloadSize -gt 1000000)    { $DownloadSize = "$([Math]::Round($($DownloadSize / 1mb),2)) MB" }
        elseif ($DownloadSize -gt 1000)       { $DownloadSize = "$([Math]::Round($($DownloadSize / 1kb),2)) KB" }
        elseif ($DownloadSize -le 1000)       { $DownloadSize = "$DownloadSize Bytes" }

        $ConfirmSelection = $False
        $MessageBox = [System.Windows.Forms.MessageBox]::Show("Total data amount prior to compression and download:  $DownloadSize","PoSh-EasyWin - Extract Stream Data",[System.Windows.Forms.MessageBoxButtons]::OKCancel)
        switch ($MessageBox){
            "OK"     { $ConfirmSelection = $true }
            "Cancel" { $ConfirmSelection = $False }
        }
    }


    if ($SelectedFilesToExtractStreamData -and $ConfirmSelection) {
        $InformationTabControl.SelectedTab = $Section3ResultsTab

        if (Test-Path $($script:CollectionSavedDirectoryTextBox.Text)) { $RetrieveFilesSaveDirectory = $script:CollectionSavedDirectoryTextBox.Text }
        $RetrieveFilesSaveDirectory = $script:CollectionSavedDirectoryTextBox.Text


        $StatusListBox.Items.clear()
        $StatusListBox.Items.Add("Extracting Alternate Data Stream from Files")
        #Removed For Testing#$ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Extracting Alternate Data Stream from Files:")
        Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Retrieved the following files from:"

        # Function Zip-File
        # Uses the .Net Framework to zip files and directories
        . "$Dependencies\Code\Execution\Retrieve Files\Zip-File.ps1"

    #        # Function Create-RetrievedFileDetails
    #        # Creates the 'File Details.txt' fiile that is included into zipped Retrieved Files
        . "$Dependencies\Code\Execution\Retrieve Files\Create-RetrievedFileDetails.ps1"

        $SelectedFilesToExtractStreamData = $SelectedFilesToExtractStreamData | Sort-Object -Property PSComputerName
        $ExtractStreamDataCurrentComputer = ''

        $script:ProgressBarEndpointsProgressBar.Maximum = ($SelectedFilesToExtractStreamData.PSComputerName | Sort-Object -Unique).count
        $script:ProgressBarEndpointsProgressBar.Value   = 0


        function Extract-AlternateDataStream {
            # Identified file is first compressed on the endpoint
            # If the target item is a directory, the directory will be directly compressed
            # If the target item is not a directory, it will copy the item to c:\Windows\Temp
            # Uses .Net Framework System.IO.Compression.FileSystem
            $StreamDataRemoteSaveLocation = "C:\Windows\Temp\$($File.Stream)"
            Invoke-Command -ScriptBlock {
                param(
                    $File,
                    $StreamDataRemoteSaveLocation,
                    $ZipFile
                )
                Get-content -Path $($File.FileName) -Stream $($File.Stream) -Raw | Set-Content $StreamDataRemoteSaveLocation
                Invoke-Expression $ZipFile
                Zip-File -Path $StreamDataRemoteSaveLocation -Destination 'C:\Windows\Temp' -Compression Optimal -ADS
            } -Argumentlist @($File,$StreamDataRemoteSaveLocation,$ZipFile) -Session $session


            # File is hashed remotely on endpoint, then copied back over the network
            $RetrievedFileHashMD5 = Invoke-Command -ScriptBlock {
                param($StreamDataRemoteSaveLocation)
                (Get-FileHash -Algorithm MD5 -Path $StreamDataRemoteSaveLocation).Hash
            } -Argumentlist $StreamDataRemoteSaveLocation -Session $session
            Copy-Item -Path "c:\Windows\Temp\$($File.Stream).zip" -Destination "$LocalSavePath\$($File.Stream) [MD5=$RetrievedFileHashMD5].zip" -FromSession $session

            # The 'File Details.txt' is created locally from the source file on the endpoint
            # The file in this case is of that what is extracted from an Alternate Data Stream
            # This script also get other file metatadata
            # Also hashes the file with multiple algorithms
            # Gets AuthenticodeSignature information
            Create-RetrievedFileDetails -LocalSavePath $LocalSavePath -File $StreamDataRemoteSaveLocation -ADS $File -AdsUpdateName "$LocalSavePath\$($File.Stream) [MD5=$RetrievedFileHashMD5].zip"


            # The extracted alternate data stream and zipped file are removed from the endpoint
            Invoke-Command -ScriptBlock {
                param(
                    $File,
                    $StreamDataRemoteSaveLocation
                )
                Remove-Item -Path $StreamDataRemoteSaveLocation -Force
                Remove-Item "c:\Windows\Temp\$($File.Stream).zip" -Force
            } -ArgumentList @($File,$StreamDataRemoteSaveLocation) -Session $session

            $script:ProgressBarQueriesProgressBar.Value += 1
        }



        Foreach ($File in $SelectedFilesToExtractStreamData) {
            if ($ExtractStreamDataCurrentComputer -eq '') {
                $ExtractStreamDataCurrentComputer = $File.PSComputerName
                $script:ProgressBarQueriesProgressBar.Maximum = ($SelectedFilesToExtractStreamData | Where {$_.PSComputerName -eq $ExtractStreamDataCurrentComputer}).count
                $script:ProgressBarQueriesProgressBar.Value   = 0


                $LocalSavePath = "$RetrieveFilesSaveDirectory\Retrieved & Extracted Stream Data - $ExtractStreamDataCurrentComputer"
                if ( -not (Test-Path -Path "$RetrieveFilesSaveDirectory\Retrieved & Extracted Stream Data - $ExtractStreamDataCurrentComputer") ) {
                    New-Item -Type Directory -Path $LocalSavePath
                }


                if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                    if (!$script:Credential) { Set-NewCredential }
                    $session = New-PSSession -ComputerName $ExtractStreamDataCurrentComputer -Name "PoSh-EasyWin Extract Stream Data $ExtractStreamDataCurrentComputer" -Credential $script:Credential
                    Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "- New-PSSession -ComputerName $ExtractStreamDataCurrentComputer -Credential $script:Credential"
                }
                else {
                    $session = New-PSSession -ComputerName $ExtractStreamDataCurrentComputer -Name "PoSh-EasyWin Extract Stream Data $ExtractStreamDataCurrentComputer"
                    Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "- New-PSSession -ComputerName $ExtractStreamDataCurrentComputer"
                }

                Extract-AlternateDataStream
            }
            elseif ($ExtractStreamDataCurrentComputer -eq $File.PSComputerName) {
                # no need for new session as there is already one open to the target computer

                Extract-AlternateDataStream
            }
            elseif ($ExtractStreamDataCurrentComputer -ne $File.PSComputerName) {
                Get-PSSession -Name "PoSh-EasyWin Extract Stream Data $ExtractStreamDataCurrentComputer" | Remove-PSSession
                Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "   Remove-PSSession -ComputerName $ExtractStreamDataCurrentComputer"

                $ExtractStreamDataCurrentComputer = $File.PSComputerName
                $script:ProgressBarQueriesProgressBar.Maximum = ($SelectedFilesToExtractStreamData | Where {$_.PSComputerName -eq $ExtractStreamDataCurrentComputer}).count
                $script:ProgressBarQueriesProgressBar.Value   = 0


                $LocalSavePath = "$RetrieveFilesSaveDirectory\Retrieved & Extracted Stream Data - $ExtractStreamDataCurrentComputer"
                if ( -not (Test-Path -Path "$RetrieveFilesSaveDirectory\Retrieved & Extracted Stream Data - $ExtractStreamDataCurrentComputer") ) {
                    New-Item -Type Directory -Path $LocalSavePath
                }


                $session = New-PSSession -ComputerName $ExtractStreamDataCurrentComputer -Name "PoSh-EasyWin Extract Stream Data $ExtractStreamDataCurrentComputer"
                Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "- New-PSSession -ComputerName $ExtractStreamDataCurrentComputer"


                Extract-AlternateDataStream


                $script:ProgressBarEndpointsProgressBar.Value += 1
                $PoShEasyWin.Refresh()
            }
            $ResultsListBox.Items.Insert(1,"- $($ExtractStreamDataCurrentComputer): $($File.FileName)")
            Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "   Copied: $($File.FileName)"
            $PoShEasyWin.Refresh()
        }
        $script:ProgressBarEndpointsProgressBar.Maximum = 1
        $script:ProgressBarEndpointsProgressBar.Value   = 1
        $script:ProgressBarQueriesProgressBar.Maximum   = 1
        $script:ProgressBarQueriesProgressBar.Value     = 1

        Get-PSSession -Name "PoSh-EasyWin Extract Stream Data $ExtractStreamDataCurrentComputer" | Remove-PSSession
        Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "   Remove-PSSession -ComputerName $ExtractStreamDataCurrentComputer"

        Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Retrieved Files Saved To: $RetrieveFilesSaveDirectory"
        Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Retrieved Files From Endpoints Were Zipped To 'c:\Windows\Temp\' Then Removed"

        if ($script:RollCredentialsState -and $script:ComputerListProvideCredentialsCheckBox.checked) {
            Start-Sleep -Seconds 3
            Set-NewRollingPassword
        }

        if ($SelectedFilesToExtractStreamData) { Start-Sleep -Seconds 1;  Invoke-Item -Path $RetrieveFilesSaveDirectory }
        $PoShEasyWin.Refresh()
    }
    Add-CommonButtonSettings -Button $FileSearchAlternateDataStreamDirectoryExtractStreamDataButton

    Add-CommonButtonSettings -Button $RetrieveFilesButton
    Add-CommonButtonSettings -Button $OpenXmlResultsButton
    Add-CommonButtonSettings -Button $OpenCsvResultsButton
}




Update-FormProgress "Get-RemoteFile"
function Get-RemoteFile {
    param(
        $Files
    )
    $FilesToDownload = $Files

    if ($FilesToDownload) {
        $DownloadSize = $FilesToDownload | Select-Object -ExpandProperty length | Measure-Object -Sum | Select-Object -ExpandProperty Sum
        if     ($DownloadSize -gt 1000000000) { $DownloadSize = "$([Math]::Round($($DownloadSize / 1gb),2)) GB" }
        elseif ($DownloadSize -gt 1000000)    { $DownloadSize = "$([Math]::Round($($DownloadSize / 1mb),2)) MB" }
        elseif ($DownloadSize -gt 1000)       { $DownloadSize = "$([Math]::Round($($DownloadSize / 1kb),2)) KB" }
        elseif ($DownloadSize -le 1000)       { $DownloadSize = "$DownloadSize Bytes" }

        $ConfirmDownload = $False
        $MessageBox = [System.Windows.Forms.MessageBox]::Show("Total data amount prior to compression and download:  $DownloadSize`n`nFiles are hashed and compressed remotely before retrieval.","PoSh-EasyWin - Retreive Files",[System.Windows.Forms.MessageBoxButtons]::OKCancel)
        switch ($MessageBox){
            "OK"     { $ConfirmDownload = $true }
            "Cancel" { $ConfirmDownload = $False }
        }
    }


    if ($FilesToDownload -and $ConfirmDownload) {
        $InformationTabControl.SelectedTab = $Section3ResultsTab

        if (Test-Path $($script:CollectionSavedDirectoryTextBox.Text)) { $RetrieveFilesSaveDirectory = $script:CollectionSavedDirectoryTextBox.Text }
        $RetrieveFilesSaveDirectory = $script:CollectionSavedDirectoryTextBox.Text



        $StatusListBox.Items.clear()
        $StatusListBox.Items.Add("Retrieving Files")
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Retrieving the following files from:")
        Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Retrieved the following files from:"

        # Function Zip-File
        # Uses the .Net Framework to zip files and directories
        . "$Dependencies\Code\Execution\Retrieve Files\Zip-File.ps1"

        # Function Create-RetrievedFileDetails
        # Creates the 'File Details.txt' fiile that is included into zipped Retrieved Files
        . "$Dependencies\Code\Execution\Retrieve Files\Create-RetrievedFileDetails.ps1"

        $FilesToDownload = $FilesToDownload | Sort-Object -Property PSComputerName
        $RetrieveFilesCurrentComputer = ''

        $script:ProgressBarEndpointsProgressBar.Maximum = ($FilesToDownload.PSComputerName | Sort-Object -Unique).count
        $script:ProgressBarEndpointsProgressBar.Value   = 0

        Foreach ($File in $FilesToDownload) {
            if ($RetrieveFilesCurrentComputer -eq '') {
                $RetrieveFilesCurrentComputer = $File.PSComputerName
                $script:ProgressBarQueriesProgressBar.Maximum = ($FilesToDownload | Where-Object {$_.PSComputerName -eq $RetrieveFilesCurrentComputer}).count
                $script:ProgressBarQueriesProgressBar.Value   = 0


                $LocalSavePath = "$RetrieveFilesSaveDirectory\Retrieved Files - $RetrieveFilesCurrentComputer"
                if ( -not (Test-Path -Path "$RetrieveFilesSaveDirectory\Retrieved Files - $RetrieveFilesCurrentComputer") ) {
                    New-Item -Type Directory -Path $LocalSavePath
                }


                if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                    if (!$script:Credential) { Set-NewCredential }
                    $session = New-PSSession -ComputerName $RetrieveFilesCurrentComputer -Name "PoSh-EasyWin Retrieve File $RetrieveFilesCurrentComputer" -Credential $script:Credential
                    Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "- New-PSSession -ComputerName $RetrieveFilesCurrentComputer -Credential $script:Credential"
                }
                else {
                    $session = New-PSSession -ComputerName $RetrieveFilesCurrentComputer -Name "PoSh-EasyWin Retrieve File $RetrieveFilesCurrentComputer"
                    Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "- New-PSSession -ComputerName $RetrieveFilesCurrentComputer"
                }

                # Identified file is first compressed on the endpoint
                # If the target item is a directory, the directory will be directly compressed
                # If the target item is not a directory, it will copy the item to c:\Windows\Temp
                # Uses .Net Framework System.IO.Compression.FileSystem
                Invoke-Command -ScriptBlock ${function:Zip-File} -argumentlist @($File.FullName),"c:\Windows\Temp","Optimal" -Session $session
#                Copy-Item -Path "c:\Windows\Temp\$($File.BaseName).zip" -Destination $LocalSavePath -FromSession $session

                # File is hashed remotely on endpoint, then copied back over the network
                $RetrievedFileHashMD5 = Invoke-Command -ScriptBlock { param($File) (Get-FileHash -Algorithm md5 -Path "$($File.FullName)").Hash } -argumentlist $File -Session $session
                Copy-Item -Path "c:\Windows\Temp\$($File.BaseName).zip" -Destination "$LocalSavePath\$($File.BaseName) [MD5=$RetrievedFileHashMD5].zip" -FromSession $session

                Start-Sleep -Milliseconds 250

                # The zipped file is removed from the endpoint
                Invoke-Command -ScriptBlock {
                    param($File)
                    Remove-Item "c:\Windows\Temp\$($File.BaseName).zip"
                } -ArgumentList $File -Session $session

                # The 'File Details.txt' is created locally from the source file on the endpoint
                # This script also get other file metatadata
                # Also hashes the file with multiple algorithms
                # Gets AuthenticodeSignature information
                Create-RetrievedFileDetails -LocalSavePath $LocalSavePath -File $File

                $script:ProgressBarQueriesProgressBar.Value += 1
            }
            elseif ($RetrieveFilesCurrentComputer -eq $File.PSComputerName) {
                # no need for new session as there is already one open to the target computer

                # Reference notes above
                Invoke-Command -ScriptBlock ${function:Zip-File} -argumentlist @($File.FullName),"c:\Windows\Temp","Optimal" -Session $session
#                Copy-Item -Path "c:\Windows\Temp\$($File.BaseName).zip" -Destination $LocalSavePath -FromSession $session

                # Reference notes above
                $RetrievedFileHashMD5 = Invoke-Command -ScriptBlock { param($File) (Get-FileHash -Algorithm md5 -Path "$($File.FullName)").Hash } -argumentlist $File -Session $session
                Copy-Item -Path "c:\Windows\Temp\$($File.BaseName).zip" -Destination "$LocalSavePath\$($File.BaseName) [MD5=$RetrievedFileHashMD5].zip" -FromSession $session

                Start-Sleep -Milliseconds 250

                # Reference notes above
                Invoke-Command -ScriptBlock {
                    param($File)
                    Remove-Item "c:\Windows\Temp\$($File.BaseName).zip"
                } -ArgumentList $File -Session $session

                # Reference notes above
                Create-RetrievedFileDetails -LocalSavePath $LocalSavePath -File $File

                $script:ProgressBarQueriesProgressBar.Value += 1
            }
            elseif ($RetrieveFilesCurrentComputer -ne $File.PSComputerName) {
                Get-PSSession -Name "PoSh-EasyWin Retrieve File $RetrieveFilesCurrentComputer" | Remove-PSSession
                Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "   Remove-PSSession -ComputerName $RetrieveFilesCurrentComputer"

                $RetrieveFilesCurrentComputer = $File.PSComputerName
                $script:ProgressBarQueriesProgressBar.Maximum = ($FilesToDownload | Where-Object {$_.PSComputerName -eq $RetrieveFilesCurrentComputer}).count
                $script:ProgressBarQueriesProgressBar.Value   = 0

                $LocalSavePath = "$RetrieveFilesSaveDirectory\Retrieved Files - $RetrieveFilesCurrentComputer"
                if ( -not (Test-Path -Path "$RetrieveFilesSaveDirectory\Retrieved Files - $RetrieveFilesCurrentComputer") ) { New-Item -Type Directory -Path $LocalSavePath }
                $session = New-PSSession -ComputerName $RetrieveFilesCurrentComputer -Name "PoSh-EasyWin Retrieve File $RetrieveFilesCurrentComputer"
                Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "- New-PSSession -ComputerName $RetrieveFilesCurrentComputer"

                # Reference notes above
                Invoke-Command -ScriptBlock ${function:Zip-File} -argumentlist @($File.FullName),"c:\Windows\Temp","Optimal" -Session $session
#                Copy-Item -Path "c:\Windows\Temp\$($File.BaseName).zip" -Destination $LocalSavePath -FromSession $session

                # Reference notes above
                $RetrievedFileHashMD5 = Invoke-Command -ScriptBlock { param($File) (Get-FileHash -Algorithm md5 -Path "$($File.FullName)").Hash } -argumentlist $File -Session $session
                Copy-Item -Path "c:\Windows\Temp\$($File.BaseName).zip" -Destination "$LocalSavePath\$($File.BaseName) [MD5=$RetrievedFileHashMD5].zip" -FromSession $session

                Start-Sleep -Milliseconds 250

                # Reference notes above
                Invoke-Command -ScriptBlock {
                    param($File)
                    Remove-Item "c:\Windows\Temp\$($File.BaseName).zip"
                } -ArgumentList $File -Session $session

                # Reference notes above
                Create-RetrievedFileDetails -LocalSavePath $LocalSavePath -File $File

                $script:ProgressBarEndpointsProgressBar.Value += 1
                $script:ProgressBarQueriesProgressBar.Value += 1
                $PoShEasyWin.Refresh()
            }
            $ResultsListBox.Items.Insert(1,"- $($RetrieveFilesCurrentComputer): $($File.FullName)")
            Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "   Copied: $($File.FullName)"
            $PoShEasyWin.Refresh()
        }
        $script:ProgressBarEndpointsProgressBar.Maximum = 1
        $script:ProgressBarEndpointsProgressBar.Value   = 1
        $script:ProgressBarQueriesProgressBar.Maximum   = 1
        $script:ProgressBarQueriesProgressBar.Value     = 1

        Get-PSSession -Name "PoSh-EasyWin Retrieve File $RetrieveFilesCurrentComputer" | Remove-PSSession
        Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "   Remove-PSSession -ComputerName $RetrieveFilesCurrentComputer"

        Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Retrieved Files Saved To: $RetrieveFilesSaveDirectory"
        Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Retrieved Files From Endpoints Were Zipped To 'c:\Windows\Temp\' Then Removed"

        if ($script:RollCredentialsState -and $script:ComputerListProvideCredentialsCheckBox.checked) {
            Start-Sleep -Seconds 3
            Set-NewRollingPassword
        }

        if ($FilesToDownload) { Start-Sleep -Seconds 1;  Invoke-Item -Path $RetrieveFilesSaveDirectory }
        $PoShEasyWin.Refresh()
    }

    Add-CommonButtonSettings -Button $RetrieveFilesButton

    Add-CommonButtonSettings -Button $OpenXmlResultsButton
    Add-CommonButtonSettings -Button $OpenCsvResultsButton
}




Update-FormProgress "Get-SubnetRange"
Function Get-SubnetRange {
    <#
        .Description
        Using the inputs selected or provided from the GUI, it conducts a basic ping sweep
        The results can be added to the computer treenodes
        Lists all IPs in a subnet

        .Notes
        Ex: Get-SubnetRange -IP 192.168.1.0 -Netmask /24
        Ex: Get-SubnetRange -IP 192.168.1.128 -Netmask 255.255.255.128
    #>
    Param(
        [string]
        $IP,
        [string]
        $netmask
    )
    Begin {
        $IPs = New-Object System.Collections.ArrayList

        # Get the network address of a given lan segment
        # Ex: Get-NetworkAddress -IP 192.168.1.36 -mask 255.255.255.0
        Function Get-NetworkAddress {
            Param (
                [string]$IP,
                [string]$Mask,
                [switch]$Binary
            )
            Begin { $NetAdd = $null }
            Process {
                $BinaryIP = ConvertTo-BinaryIP $IP
                $BinaryMask = ConvertTo-BinaryIP $Mask
                0..34 | %{
                    $IPBit = $BinaryIP.Substring($_,1)
                    $MaskBit = $BinaryMask.Substring($_,1)
                    IF ($IPBit -eq '1' -and $MaskBit -eq '1') {
                        $NetAdd = $NetAdd + "1"
                    }
                    elseif ($IPBit -eq ".") { $NetAdd = $NetAdd +'.'}
                    else { $NetAdd = $NetAdd + "0" }
                }
                if ($Binary) { return $NetAdd }
                else { return ConvertFrom-BinaryIP $NetAdd }
            }
        }

        # Convert an IP address to binary
        # Ex: ConvertTo-BinaryIP -IP 192.168.1.1
        Function ConvertTo-BinaryIP {
            Param ( [string]$IP )
            Process {
                $out = @()
                Foreach ($octet in $IP.split('.')) {
                    $strout = $null
                    0..7|% {
                        if (($octet - [math]::pow(2,(7-$_)))-ge 0) {
                            $octet = $octet - [math]::pow(2,(7-$_))
                            [string]$strout = $strout + "1"
                        }
                        else { [string]$strout = $strout + "0" }
                    }
                    $out += $strout
                }
                return [string]::join('.',$out)
            }
        }

        # Convert from Binary to an IP address
        # Convertfrom-BinaryIP -IP 11000000.10101000.00000001.00000001
        Function ConvertFrom-BinaryIP {
            Param ( [string]$IP )
            Process {
                $out = @()
                Foreach ($octet in $IP.split('.')) {
                    $strout = 0
                    0..7|% {
                        $bit = $octet.Substring(($_),1)
                        IF ($bit -eq 1) { $strout = $strout + [math]::pow(2,(7-$_)) }
                    }
                    $out += $strout
                }
                return [string]::join('.',$out)
            }
        }

        # Convert from a netmask to the masklength
        # Ex: ConvertTo-MaskLength -Mask 255.255.255.0
        Function ConvertTo-MaskLength {
            Param ( [string]$mask )
            Process {
                $out = 0
                Foreach ($octet in $Mask.split('.')) {
                    $strout = 0
                    0..7|% {
                        IF (($octet - [math]::pow(2,(7-$_)))-ge 0) {
                            $octet = $octet - [math]::pow(2,(7-$_))
                            $out++
                        }
                    }
                }
                return $out
            }
        }

        # Convert from masklength to a netmask
        # Ex: ConvertFrom-MaskLength -Mask /24
        # Ex: ConvertFrom-MaskLength -Mask 24
        Function ConvertFrom-MaskLength {
            Param ( [int]$mask )
            Process {
                $out = @()
                [int]$wholeOctet = ($mask - ($mask % 8))/8
                if ($wholeOctet -gt 0) { 1..$($wholeOctet) | % { $out += "255" } }
                $subnet = ($mask - ($wholeOctet * 8))
                if ($subnet -gt 0) {
                    $octet = 0
                    0..($subnet - 1) | % { $octet = $octet + [math]::pow(2,(7-$_)) }
                    $out += $octet
                }
                for ($i=$out.count;$i -lt 4; $I++) { $out += 0 }
                return [string]::join('.',$out)
            }
        }

        # Given an Ip and subnet, return every IP in that lan segment
        # Ex: Get-IPRange -IP 192.168.1.36 -Mask 255.255.255.0
        # Ex: Get-IPRange -IP 192.168.5.55 -Mask /23
        Function Get-IPRange {
            Param (
                [string]$IP,
                [string]$netmask
            )
            Process {
                iF ($netMask.length -le 3) {
                    $masklength = $netmask.replace('/','')
                    $Subnet = ConvertFrom-MaskLength $masklength
                }
                else {
                    $Subnet = $netmask
                    $masklength = ConvertTo-MaskLength -Mask $netmask
                }
                $network = Get-NetworkAddress -IP $IP -Mask $Subnet

                [int]$FirstOctet,[int]$SecondOctet,[int]$ThirdOctet,[int]$FourthOctet = $network.split('.')
                $TotalIPs = ([math]::pow(2,(32-$masklength)) -2)
                $blocks = ($TotalIPs - ($TotalIPs % 256))/256
                if ($Blocks -gt 0) {
                    1..$blocks | %{
                        0..255 |%{
                            if ($FourthOctet -eq 255) {
                                If ($ThirdOctet -eq 255) {
                                    If ($SecondOctet -eq 255) {
                                        $FirstOctet++
                                        $secondOctet = 0
                                    }
                                    else {
                                        $SecondOctet++
                                        $ThirdOctet = 0
                                    }
                                }
                                else {
                                    $FourthOctet = 0
                                    $ThirdOctet++
                                }
                            }
                            else {
                                $FourthOctet++
                            }
                            Write-Output ("{0}.{1}.{2}.{3}" -f `
                            $FirstOctet,$SecondOctet,$ThirdOctet,$FourthOctet)
                        }
                    }
                }
                $sBlock = $TotalIPs - ($blocks * 256)
                if ($sBlock -gt 0) {
                    1..$SBlock | %{
                        if ($FourthOctet -eq 255) {
                            If ($ThirdOctet -eq 255) {
                                If ($SecondOctet -eq 255) {
                                    $FirstOctet++
                                    $secondOctet = 0
                                }
                                else {
                                    $SecondOctet++
                                    $ThirdOctet = 0
                                }
                            }
                            else {
                                $FourthOctet = 0
                                $ThirdOctet++
                            }
                        }
                        else {
                            $FourthOctet++
                        }
                        Write-Output ("{0}.{1}.{2}.{3}" -f `
                        $FirstOctet,$SecondOctet,$ThirdOctet,$FourthOctet)
                    }
                }
            }
        }
    }
    Process {
        # Get every ip in scope
        Get-IPRange $IP $netmask | ForEach-Object { [void]$IPs.Add($_) }
        $Script:IPList = $IPs
    }
}




Update-FormProgress "Open-XmlResultsInShell"
function script:Open-XmlResultsInShell {
    <#
        .Description
        This is placed here as the code is used with the "Open Data In Shell" button in the main form as well as within the dashboards
    #>
    param(
        $ViewImportResults,
        $FileName,
        $SavePath
    )
    #Start-Process  'PowerShell' -ArgumentList '-NoExit',{$Results = Import-Clixml 'C:\Firewall Status - (WinRM) PoSh - Win81-07.xml';Write-Host -f White "$('='*100)";Write-Host -f Yellow '  The results available as XML data within the variable: ' -NoNewline;Write-Host -f Red '$Results ';Write-Host '';Write-Host -f Yellow '  You can manipulate the ' -NoNewline;Write-Host -f Red '$Results ' -NoNewline;Write-Host -f Yellow 'data via command line, a few examples are:';Write-Host -f White "`t" '$Results';Write-Host -f White "`t" '$Results | Out-GridView';Write-Host -f White "`t" '$Results | Select-Object -Property Name';Write-Host -f White "`t" '$Results | Get-Member';Write-Host -f White "$('='*100)";Write-Host""},{$(Set-Location c:\ -ErrorAction SilentlyContinue)}
    New-Item -Type Directory 'c:\Windows\Temp\PoSh-EasyWin' -Force -ErrorAction SilentlyContinue

    $Command = @"
    Start-Process 'PowerShell' -ArgumentList '-NoExit',
    '-ExecutionPolicy Bypass',
        { `$ErrorActionPreference = 'SilentlyContinue'; },
        { Write-Host ' '; },

        { Write-Host -f Yellow 'Generate Property Statistics? For larger files this may take some time: ' -NoNewLine;},
        { `$script:YesNo = `$null; function Read-KeyOrTimeout {Param([int]`$seconds=5,[string]`$prompt='[Y/n]',[string]`$default = 'Y'); `$startTime=Get-Date; `$timeOut = New-TimeSpan -Seconds `$seconds; Write-Host `$prompt; while (-not `$host.ui.RawUI.KeyAvailable) {`$currentTime = Get-Date; if (`$currentTime -gt `$startTime + `$timeOut) {Break}}; if (`$host.ui.RawUI.KeyAvailable) {[string]`$response = (`$host.ui.RawUI.ReadKey('IncludeKeyDown,NoEcho')).character} else {`$response = `$default};`$script:YesNo = `$response;}; Read-KeyOrTimeOut; },

        { switch (`$YesNo) {Y {`$Answer=`$true}; n {`$Answer=`$false}; Default {`$Answer=`$true}};},
        { `$Message = 'Importing selcted file...'; },
        { Write-Host ' '; },

        { Write-Host -f Yellow "`$Message" -NoNewLine; },

        { `$Results = Import-CliXml '$ViewImportResults'; },
        { foreach (`$i in (0..(40-(`$Message.length)))) {Write-Host ' '-NoNewLine}; },
        { Write-Host -f Green '  [Complete]'; },
        { Write-Host ' '; },

        { `$Message = 'Generating Variables and Functions...'; },
        { Write-Host -f Yellow "`$Message" -NoNewLine; },
        { `$script:ComputerList        = `$Results | Select-Object PSComputerName -Unique; },
        { `$ComputerCount       = @(`$Results | Select-Object PSComputerName -Unique).count; },
        { `$TotalObjectCount    = @(`$Results).count; },
        { `$PropertyList          = (`$Results[0] | Get-Member | Where-Object MemberType -Match Property).Name; },
        { foreach (`$i in (0..(40-(`$Message.length)))) {Write-Host ' '-NoNewLine}; },
        { Write-Host -f Green '  [Complete]'; },
        { Write-Host ' '; },

        { if (`$Answer -eq `$true) {`$Message = 'Processing Select Results...'}; },
        { if (`$Answer -eq `$true) {Write-Host -f Yellow "`$Message"}; },
        { if (`$Answer -eq `$true) {`$PropertyUniqueCount = @()} else {`$PropertyUniqueCount = 'These statistics were not generated...'}; },
        { if (`$Answer -eq `$true) {foreach (`$p in `$PropertyList) { Write-Host "``t`$p" -NoNewLine; foreach (`$i in (0..(33-(`$p.length)))) {Write-Host ' '-NoNewLine} ;`$PropertyUniqueCount += [pscustomobject]@{Name = "`$p";Value = (`$Results.`$p | Select -unique).count}; Write-host -f Green '[Complete]'  }} ; },
        { Write-Host ' '; },

        { function View-Results {`$Results | Out-GridView -Title 'PoSh-EasyWin - View Results'}; },
        { function Open-ResultsDirectory {`Invoke-Item `$SavePath}; },

        { New-PSDrive -Name 'PoSh-EasyWin' -PSProvider FileSystem -Root 'C:\Windows\Temp' -ErrorAction SilentlyContinue | Out-Null; Set-Location PoSh-EasyWin:\; },
        { `$host.UI.RawUI.WindowTitle = 'PoSh-EasyWin: Raw Data Manipulation in Terminal'; },

        { Clear-Host; },

        { Write-Host -f White        "$('='*100)"; },
        { Write-Host ' '; },

        { Write-Host -f Yellow       '  The selected results are available as object data within the variable: ' -NoNewline; },
        { Write-Host -f Red          '`$Results'; },
        { Write-Host -f White "``t"   '\`"$FileName\`"'; },
        { Write-Host ' '; },

        { `$SavePath = '$SavePath'; },
        { Write-Host -f Yellow       '  Data can be saved to the same location selected using the variable: ' -NoNewline; },
        { Write-Host -f Cyan         '`$SavePath'; },
        { Write-Host -f White "``t"   '\`"$SavePath\`"'; },
        { Write-Host ' '; },

        { Write-Host -f Yellow       '  You can manipulate the ' -NoNewline; },
        { Write-Host -f Red          '`$Results ' -NoNewline; },
        { Write-Host -f Yellow 'data via command line, a few examples are:'; },

        { Write-Host -f Red    "``t" '`$Results'; },

        { Write-Host -f Red    "``t" '`$Results ' -NoNewLine; },
        { Write-Host -f White        '| Get-Member'; },

        { Write-Host -f Red    "``t" '`$Results ' -NoNewLine; },
        { Write-Host -f White        '| Select-Object -Property PSComputerName -Unique'; },

        { Write-Host -f Red    "``t" '`$Results ' -NoNewLine; },
        { Write-Host -f White        '| Out-GridView -PassThru | Export-Csv \`"' -NoNewLine; },
        { Write-Host -f Cyan         '`$SavePath' -NoNewLine; },
        { Write-Host -f White        '`\Shell Output.csv\`" -NoTypeInfo'; },

        { Write-Host -f Red    "``t" '`$Results ' -NoNewLine; },
        { Write-Host -f White        '| ? {`$_.name -match \`"win\`"} | Select PSComputerName, Name | Sort Name | ft -auto'; },
        { Write-Host ' '; },

        { Write-Host -f Yellow       '  Below are some useful variables generated from the results imported:'; },
        { Write-Host -f Green  "``t" '`$script:ComputerList'"``t``t"'`$PropertyList'"``t``t"'`$TotalObjectCount'; },
        { Write-Host -f Green  "``t" '`$ComputerCount'"``t"'`$PropertyUniqueCount'; },
        { Write-Host ' '; },

        { Write-Host -f Yellow       '  The functions have been created for use:'; },
        { Write-Host -f Magenta "``t" '`View-Results'"``t``t"'Open-ResultsDirectory'; },
        { Write-Host ' '; },

        { Write-Host -f White        "$('='*100)"; },
        { Write-Host""; },

        { `$ErrorActionPreference = 'Continue'; }
"@
    Invoke-Expression $Command
}




Update-FormProgress "OpenFileDialog-SysinternalsSysmonXmlConfig"
function OpenFileDialog-SysinternalsSysmonXmlConfig {
    <#
        .Description
        Selects the .xml configuration file for sysmon
    #>
    Add-Type -AssemblyName System.Windows.Forms
        #[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null

    $SysinternalsSysmonOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{
        Title = "Select Sysmon Configuration XML File"
        Filter = "XML Files (*.xml)| *.xml|All files (*.*)|*.*"
        ShowHelp = $true
        InitialDirectory = "$Dependencies\Executables\Sysmon Config Files"
    }
    $SysinternalsSysmonOpenFileDialog.ShowDialog() | Out-Null
    if ($($SysinternalsSysmonOpenFileDialog.filename)) {
        $script:SysmonXMLPath = $SysinternalsSysmonOpenFileDialog.filename

        $SysinternalsSysmonConfigTextBox.text = "Config: $(($SysinternalsSysmonOpenFileDialog.filename).split('\')[-1])"
        $Script:SysmonXMLName = $(($SysinternalsSysmonOpenFileDialog.filename).split('\')[-1])
    }
}




Update-FormProgress "OpenFileDialog-UserSpecifiedScript"
function OpenFileDialog-UserSpecifiedScript {
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null

    if (Test-Path "$PewRoot\User Specified Executable And Script") {$ExecAndScriptDir = "$PewRoot\User Specified Executable And Script"}
    else {$ExecAndScriptDir = "$PewRoot"}

    $ExeScriptSelectScriptOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{
        Title = "Select Script File"
        Filter = "PowerShell Script (*.ps1)| *.ps1|Batch File (*.bat)| *.bat|Text File (*.txt)| *.txt|All files (*.*)|*.*"
        ShowHelp = $true
        InitialDirectory = $ExecAndScriptDir
    }
    $ExeScriptSelectScriptOpenFileDialog.ShowDialog() | Out-Null
    if ($($ExeScriptSelectScriptOpenFileDialog.filename)) {
        $script:ExeScriptSelectScriptPath = $ExeScriptSelectScriptOpenFileDialog.filename

        $ExeScriptSelectScriptTextBox.text = "$(($ExeScriptSelectScriptOpenFileDialog.filename).split('\')[-1])"
        #$Script:ExeScriptSelectScriptName  = $(($ExeScriptSelectScriptOpenFileDialog.filename).split('\')[-1])
    }
}




Update-FormProgress "Save-OpNotes"
function Save-OpNotes {
    # Select all fields to be saved
    for($i = 0; $i -lt $OpNotesListBox.Items.Count; $i++) { $OpNotesListBox.SetSelected($i, $true) }

    # Saves all OpNotes to file
    Set-Content -Path $PewOpNotes -Value ($OpNotesListBox.SelectedItems) -Force

    # Unselects Fields
    for($i = 0; $i -lt $OpNotesListBox.Items.Count; $i++) { $OpNotesListBox.SetSelected($i, $false) }
}




Update-FormProgress "Show-PktMon"
Function Show-PktMon {
    <#
        .Description
        Provides messages when hovering over various areas in the GUI
    #>
    #https://docs.microsoft.com/en-us/windows-server/networking/technologies/pktmon/pktmon-syntax
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Windows.Drawing

    # batman Add code to check if Windows version support pktmon

    $PktMonPacketCaptureForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = "PoSh-EasyWin - Packet Monitor (PktMon.exe)"
        Width  = $FormScale * 750
        Height = $FormScale * 625
        StartPosition = "CenterScreen"
        Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoScroll    = $True
        #FormBorderStyle =  "fixed3d"
        #ControlBox    = $false
        MaximizeBox   = $false
        MinimizeBox   = $false
        ShowIcon      = $true
        TopMost       = $false
        Add_Shown     = $null
        Add_load = {
            $ScriptBlock = {
                $script:ProgressBarMainLabel.text = "Attempting to establish PowerShell sessions with $($script:ComputerList.count) endpoints."
                $script:ProgressBarMessageLabel.text = @"
Open Sessions: $($session | Where-Object {$_.State -match 'Open'})
"@
                $script:ProgressBarFormProgressBar.Value = 0
                $script:ProgressBarFormProgressBar.Maximum = $script:ComputerList.Count

                $script:PSSessionPktMon = New-PSSession -ComputerName $script:ComputerList -Credential $script:Credential

                $script:ProgressBarMessageLabel.text = @"
Open Sessions: $($session | Where-Object {$_.State -match 'Open'})
"@
                $script:ProgressBarFormProgressBar.Value = $script:ComputerList.Count
                Start-Sleep -Seconds 1
                $script:ProgressBarSelectionForm.Hide()
            }

            Show-ProgressBar -FormTitle "PoSh-EasyWin - Establishing Connection" -ScriptBlockProgressBarInput $ScriptBlock -Height $($FormScale * 155)

            $script:SupportsType = $null
            $script:SupportsType = Invoke-Command -ScriptBlock {PktMon start help | Select-String -Pattern '--type'} -Session $script:PSSessionPktMon

            $script:SupportsCountersOnly = $null
            $script:SupportsCountersOnly = Invoke-Command -ScriptBlock {PktMon start help | Select-String -Pattern '--counters-only'} -Session $script:PSSessionPktMon

            $script:SupportsPktSize = $null
            $script:SupportsPktSize = Invoke-Command -ScriptBlock {PktMon start help | Select-String -Pattern '--pkt-size'} -Session $script:PSSessionPktMon

            $script:SupportsFlags = $null
            $script:SupportsFlags = Invoke-Command -ScriptBlock {PktMon start help | Select-String -Pattern '--flags'} -Session $script:PSSessionPktMon

            $script:SupportsKeywords = $null
            $script:SupportsKeywords = Invoke-Command -ScriptBlock {PktMon start help | Select-String -Pattern '--keywords'} -Session $script:PSSessionPktMon

            $script:SupportsCapture = $null
            $script:SupportsCapture = Invoke-Command -ScriptBlock {PktMon start help | Select-String -Pattern '--capture'} -Session $script:PSSessionPktMon

            # Checks for pktmon.exe on endpoints
            $script:PktMonCheckComputerList = @()
            foreach ($Session in $script:PSSessionPktMon) {
                if (-not (Invoke-Command -ScriptBlock { Get-Command PktMon.exe } -Session $Session)) {
                    $script:PktMonCheckComputerList += $Session.ComputerName
                }
            }

            # Removed sessions that didn't have pktmon
            foreach ($Session in $script:PSSessionPktMon) {
                if ($Session.ComputerName -in $script:PktMonCheckComputerList) {
                    $Session | Remove-PSSession
                    $script:PSSessionPktMon = $script:PSSessionPktMon | Where-Object {$_.ComputerName -ne $session.ComputerName}
                }
            }

            # Unchecks all endpoint nodes
            [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
            foreach ($root in $AllTreeViewNodes) {
                $root.Checked = $false
                foreach ($Category in $root.Nodes) {
                    $Category.Checked = $false
                    foreach ($Entry in $Category.nodes) {
                        $Entry.Checked = $false
                    }
                }
            }

            # Removes endpoints that don't have pktmon.exe
            $script:PktMonCheckComputerKeepList = @()
            $PktMonComputerList = $($script:PSSessionPktMon | Where-Object {$_.State -match 'Open'}).ComputerName
            Foreach ($Computer in $PktMonComputerList) {
                if ($Computer -notin $script:PktMonCheckComputerList) {
                    $script:PktMonCheckComputerKeepList += $Computer
                }
            }

            # Checks all the nodes that have sessions
            foreach ($Computer in $script:PktMonCheckComputerKeepList) {
                foreach ($root in $AllTreeViewNodes) {
                    foreach ($Category in $root.Nodes) {
                        foreach ($Entry in $Category.nodes) {
                            if ($Entry.Text -eq $Computer){
                                $Entry.Checked = $true
                            }
                        }
                    }
                }
            }
            Update-TreeViewData -Endpoint -TreeView $script:ComputerTreeView.Nodes

            function script:Update-PktMonFilterListBox {
                $PktMonFilterListListBox.Items.Clear()
                foreach ($Session in $script:PSSessionPktMon) {
                    $PktMonFilterListResults = Invoke-Command -ScriptBlock {
                        & PktMon filter list | Where-Object {$_ -notmatch '----'}
                    } -Session $Session

                    $Tabs = $PktMonFilterTabControl.Controls `
                    | Where-Object {$_.name -eq "$($Session.ComputerName)"}

                    # Adds the filter results to each listbox specific to the targetcomputer
                    $Tabs.Controls `
                    | Where-Object {$_.name -eq $($Session.ComputerName)} `
                    | ForEach-Object {
                        $_.Items.Clear()
                        #$_.Items.Add($Session.ComputerName)
                        foreach ($Filter in $PktMonFilterListResults) {
                            $_.Items.Add("$Filter")
                        }
                    }
                }
            }

            function Populate-EndpointFilterTabs {
                $PktMonFilterTabControl.TabPages.Clear()

                foreach ($Session in $script:PSSessionPktMon) {
                    Invoke-Expression @"
                    `$PktMonRandomId = Get-Random
                    `$script:PktMonFilterTabPage$PktMonRandomId = New-Object System.Windows.Forms.TabPage -Property @{
                        Name   = "`$(`$Session.ComputerName)"
                        Text   = "`$(`$Session.ComputerName)  "
                        Width  = `$FormScale * 710
                        Height = `$FormScale * 125
                        Font   = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 11),0,0,0)
                        UseVisualStyleBackColor = `$True
                    }
                    `$PktMonFilterTabControl.Controls.Add(`$script:PktMonFilterTabPage$PktMonRandomId)


                    `$PktMonFilterListListBox$PktMonRandomId = New-Object System.Windows.Forms.ListBox -Property @{
                        Name   = "`$(`$Session.ComputerName)"
                        Text   = `$null
                        Left   = 0
                        Top    = `$FormScale * 2
                        Width  = `$PktMonOnlyPacketCountersCheckbox.Width + `$PktMonOnlyPacketCountersArgLabel.Width + `$(`$FormScale * 5) + `$PktMonComponentComboBox.Width
                        Height = `$FormScale * 125
                        Font   = New-Object System.Drawing.Font("Courier New",`$(`$FormScale * 11),0,0,0)
                        ForeColor  = 'Black'
                        SelectionMode = 'MultiExtended'
                        ScrollAlwaysVisible  = `$true
                        Add_MouseEnter = { `$PktMonFilterListSelectionComboBox.text = `$PktMonFilterListSelectionComboBox.SelectedItem -replace '\s+',' ' }
                        Add_MouseLeave = { `$PktMonFilterListSelectionComboBox.text = `$PktMonFilterListSelectionComboBox.SelectedItem -replace '\s+',' ' }
                        Add_Click = { script:Update-PktMonFilterListBox }
                    }
                    `$script:PktMonFilterTabPage$PktMonRandomId.Controls.Add(`$PktMonFilterListListBox$PktMonRandomId)
"@
                }
            }

            Populate-EndpointFilterTabs
            script:Update-PktMonFilterListBox
        }
        Add_Closing = {
            if ($script:PktMonCaptureStartButton.enabled -eq $false) {
                [System.Windows.Forms.MessageBox]::Show("All existing PowerShell sessions will be removed.`n`nAny running packet captures will be continue on the endpoints.","PoSh-EasyWin",'Ok',"Warning")
            }
            $This.dispose()
        }
    }

        $script:OnlyPacketCounters = $null
        $PktMonOnlyPacketCountersCheckbox = New-Object System.Windows.Forms.Checkbox -Property @{
            Text   = "Collect packet counters only. No packet logging will occur."
            Left   = $FormScale * 10
            Top    = $FormScale * 10
            Width  = $FormScale * 525
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = 'Blue'
            Checked = $false
            Add_Click = {
                if ($this.checked) {
                    $script:OnlyPacketCounters = '--counters-only'
                }
                else {
                    $script:OnlyPacketCounters = $null
                }
                Update-PktMonCommand
            }
        }
        $PktMonPacketCaptureForm.Controls.Add($PktMonOnlyPacketCountersCheckbox)

            $PktMonOnlyPacketCountersArgLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "--counters-only"
                Left   = $PktMonOnlyPacketCountersCheckbox.Left + $PktMonOnlyPacketCountersCheckbox.Width + $($FormScale * 5)
                Top    = $PktMonOnlyPacketCountersCheckbox.Top + $($FormScale * 6)
                Width  = $FormScale * 100
                Height = $FormScale * 16
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'DarkGreen'
                BackColor = 'White'
                BorderStyle = 'FixedSingle'
            }
            $PktMonPacketCaptureForm.Controls.Add($PktMonOnlyPacketCountersArgLabel)


            if (-not $script:SupportsCountersOnly) {
                $PktMonOnlyPacketCountersCheckbox.enabled = $false
                $PktMonOnlyPacketCountersArgLabel.enabled = $false
            }


        $PktMonComponentLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Select components to capture packets on. The default is all."
            Left   = $PktMonOnlyPacketCountersCheckbox.Left
            Top    = $PktMonOnlyPacketCountersCheckbox.Top + $PktMonOnlyPacketCountersCheckbox.Height + $($FormScale * 5)
            Width  = $PktMonOnlyPacketCountersCheckbox.Width
            Height = $FormScale * 16
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = 'Blue'
            BackColor = 'White'
            BorderStyle = 'FixedSingle'
        }
        $PktMonPacketCaptureForm.Controls.Add($PktMonComponentLabel)


            $PktMonComponentArgLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "--comp"
                Left   = $PktMonComponentLabel.Left + $PktMonComponentLabel.Width + $($FormScale * 5)
                Top    = $PktMonComponentLabel.Top
                Width  = $PktMonOnlyPacketCountersArgLabel.Width
                Height = $FormScale * 16
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'DarkGreen'
                BackColor = 'White'
                BorderStyle = 'FixedSingle'
            }
            $PktMonPacketCaptureForm.Controls.Add($PktMonComponentArgLabel)


            $script:ComponentArg = $null
            $PktMonComponentComboBox = New-Object System.Windows.Forms.Combobox -Property @{
                Text   = "all"
                Left   = $PktMonComponentArgLabel.Left + $PktMonComponentArgLabel.Width + $($FormScale * 5)
                Top    = $PktMonComponentArgLabel.Top
                Width  = $FormScale * 75
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
                add_SelectedIndexChanged = {
                    if ($this.SelectedItem -ne 'all') {
                        $script:ComponentArg = "--comp $($this.SelectedItem)"
                    }
                    else {
                        $script:ComponentArg = $null
                    }
                    Update-PktMonCommand
                }
                Add_KeyDown = {
                    if ($_.KeyCode -eq "Enter") {
                        $script:ComponentArg = "--comp $($this.text)"
                        Update-PktMonCommand
                    }
                }
            }
            $ComponentList = @('all','nics','id1','id2','Enter ID#')
            Foreach ($Item in $ComponentList) {$PktMonComponentComboBox.Items.Add($Item)}
            $PktMonPacketCaptureForm.Controls.Add($PktMonComponentComboBox)


        $PktMonTypeLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Select which packets to capture. Default is all."
            Left   = $PktMonComponentLabel.Left
            Top    = $PktMonComponentLabel.Top + $PktMonComponentLabel.Height + $($FormScale * 5)
            Width  = $PktMonOnlyPacketCountersCheckbox.Width
            Height = $FormScale * 16
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = 'blue'
            BackColor = 'White'
            BorderStyle = 'FixedSingle'
        }
        $PktMonPacketCaptureForm.Controls.Add($PktMonTypeLabel)


            $PktMonTypeArgLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "--type"
                Left   = $PktMonTypeLabel.Left + $PktMonTypeLabel.Width + $($FormScale * 5)
                Top    = $PktMonTypeLabel.Top
                Width  = $PktMonOnlyPacketCountersArgLabel.Width
                Height = $FormScale * 16
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'DarkGreen'
                BackColor = 'White'
                BorderStyle = 'FixedSingle'
            }
            $PktMonPacketCaptureForm.Controls.Add($PktMonTypeArgLabel)


            $script:TypeArg = $null
            $PktMonTypeComboBox = New-Object System.Windows.Forms.Combobox -Property @{
                Text   = "all"
                Left   = $PktMonTypeArgLabel.Left + $PktMonTypeArgLabel.Width + $($FormScale * 5)
                Top    = $PktMonTypeArgLabel.Top
                Width  = $PktMonComponentComboBox.Width
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
                add_SelectedIndexChanged = {
                    if ($this.SelectedItem -ne 'all') {
                        $script:TypeArg = "--type $($this.SelectedItem)"
                    }
                    else {
                        $script:TypeArg = $null
                    }
                    Update-PktMonCommand
                }
            }
            $TypeList = @('all','flow','drop')
            Foreach ($Item in $TypeList) {$PktMonTypeComboBox.Items.Add($Item)}
            $PktMonPacketCaptureForm.Controls.Add($PktMonTypeComboBox)


            if (-not $script:SupportsType) {
                $PktMonTypeLabel.enabled = $false
                $PktMonTypeArgLabel.enabled = $false
                $PktMonTypeComboBox.enabled = $false

            }


        $PktMonPktSizeLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Number of bytes to log from each packet. To log the entire packet select 0. The default is 128."
            Left   = $PktMonTypeLabel.Left
            Top    = $PktMonTypeLabel.Top + $PktMonTypeLabel.Height + $($FormScale * 5)
            Width  = $PktMonOnlyPacketCountersCheckbox.Width
            Height = $FormScale * 16
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = 'Blue'
            BackColor = 'White'
            BorderStyle = 'FixedSingle'
        }
        $PktMonPacketCaptureForm.Controls.Add($PktMonPktSizeLabel)


            $PktMonPktSizeArgLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "--pkt-size"
                Left   = $PktMonPktSizeLabel.Left + $PktMonPktSizeLabel.Width + $($FormScale * 5)
                Top    = $PktMonPktSizeLabel.Top
                Width  = $PktMonOnlyPacketCountersArgLabel.Width
                Height = $FormScale * 16
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'DarkGreen'
                BackColor = 'White'
                BorderStyle = 'FixedSingle'
            }
            $PktMonPacketCaptureForm.Controls.Add($PktMonPktSizeArgLabel)


            $script:PktSizeArg = $null
            $PktMonPktSizeComboBox = New-Object System.Windows.Forms.Combobox -Property @{
                Text   = "128"
                Left   = $PktMonPktSizeArgLabel.Left + $PktMonPktSizeArgLabel.Width + $($FormScale * 5)
                Top    = $PktMonPktSizeArgLabel.Top
                Width  = $PktMonComponentComboBox.Width
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
                add_SelectedIndexChanged = {
                    if ($this.SelectedItem -ne '128') {
                        $script:PktSizeArg = "--pkt-size $($this.SelectedItem)"
                    }
                    else {
                        $script:PktSizeArg = $null
                    }
                    Update-PktMonCommand
                }
            }
            $PktSizeList = @('0','32','64','128','256','512')
            Foreach ($Item in $PktSizeList) {$PktMonPktSizeComboBox.Items.Add($Item)}
            $PktMonPacketCaptureForm.Controls.Add($PktMonPktSizeComboBox)


            if (-not $script:SupportsPktSize) {
                $PktMonPktSizeLabel.enabled = $false
                $PktMonPktSizeArgLabel.enabled = $false
                $PktMonPktSizeComboBox.enabled = $false
            }


        $PktMonFlagsLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Hexadecimal bitmask that controls information logged during packet capture. The default is 0x012.
    0x001 - Internal Packet Monitor errors.
    0x002 - Information about components, counters and filters.
    0x004 - NET_BUFFER_LIST group source and destination information.
    0x008 - Select packet metadata from NDIS_NET_BUFFER_LIST_INFO.
    0x010 - Raw packet, truncated to the size from --pkt-size."
            Left   = $PktMonPktSizeLabel.Left
            Top    = $PktMonPktSizeLabel.Top + $PktMonPktSizeLabel.Height + $($FormScale * 5)
            Width  = $PktMonOnlyPacketCountersCheckbox.Width
            Height = $FormScale * 16
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = 'Blue'
            BackColor = 'White'
            BorderStyle = 'FixedSingle'
            Add_MouseEnter = {
                $this.Height = $FormScale * 80
                $this.ForeColor = 'DarkRed'
            }
            Add_MouseLeave = {
                $this.Height = $FormScale * 16
                $this.ForeColor = 'Blue'
            }
        }
        $PktMonPacketCaptureForm.Controls.Add($PktMonFlagsLabel)


            $PktMonFlagsArgLabel = New-Object System.Windows.Forms.Label -Property @{
                Left   = $PktMonFlagsLabel.Left + $PktMonFlagsLabel.Width + $($FormScale * 5)
                Top    = $PktMonFlagsLabel.Top
                Width  = $PktMonOnlyPacketCountersArgLabel.Width
                Height = $FormScale * 16
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'DarkGreen'
                BackColor = 'White'
                BorderStyle = 'FixedSingle'
            }
            $PktMonPacketCaptureForm.Controls.Add($PktMonFlagsArgLabel)
            if ($script:SupportsFlags) { $PktMonFlagsArgLabel.text = "--flags" }
            elseif ($script:SupportsKeywords) { $PktMonFlagsArgLabel.text = "--keywords" }


            $script:FlagsArg = $null
            $PktMonFlagsComboBox = New-Object System.Windows.Forms.Combobox -Property @{
                Text   = "0x012"
                Left   = $PktMonFlagsArgLabel.Left + $PktMonFlagsArgLabel.Width + $($FormScale * 5)
                Top    = $PktMonFlagsArgLabel.Top
                Width  = $PktMonComponentComboBox.Width
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
                add_SelectedIndexChanged = {
                    if ($script:SupportsFlags) {
                        if ($this.SelectedItem -ne '0x012'){
                            $script:FlagsArg = "--flags $($this.SelectedItem)"
                        }
                        else {
                            $script:FlagsArg = $null
                        }
                    }
                    elseif ($script:SupportsKeywords) {
                        if ($this.SelectedItem -ne '0x012'){
                            $script:FlagsArg = "--keywords $($this.SelectedItem)"
                        }
                        else {
                            $script:FlagsArg = $null
                        }
                    }
                    Update-PktMonCommand
                }
            }
            $FlagsList = @('0x012','0x010','0x008','0x004','0x002','0x001')
            Foreach ($Item in $FlagsList) {$PktMonFlagsComboBox.Items.Add($Item)}
            $PktMonPacketCaptureForm.Controls.Add($PktMonFlagsComboBox)


        $PktMonFileSizeLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Maximum log file size in megabytes. Default is 512 MB."
            Left   = $PktMonFlagsLabel.Left
            Top    = $PktMonFlagsLabel.Top + $PktMonFlagsLabel.Height + $($FormScale * 5)
            Width  = $PktMonOnlyPacketCountersCheckbox.Width
            Height = $FormScale * 16
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = 'Blue'
            BackColor = 'White'
            BorderStyle = 'FixedSingle'
        }
        $PktMonPacketCaptureForm.Controls.Add($PktMonFileSizeLabel)


            $PktMonFileSizeArgLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "--file-size"
                Left   = $PktMonFileSizeLabel.Left + $PktMonFileSizeLabel.Width + $($FormScale * 5)
                Top    = $PktMonFileSizeLabel.Top
                Width  = $PktMonOnlyPacketCountersArgLabel.Width
                Height = $FormScale * 16
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'DarkGreen'
                BackColor = 'White'
                BorderStyle = 'FixedSingle'
            }
            $PktMonPacketCaptureForm.Controls.Add($PktMonFileSizeArgLabel)


            $script:FileSizeArg = $null
            $PktMonFileSizeComboBox = New-Object System.Windows.Forms.Combobox -Property @{
                Text   = "512"
                Left   = $PktMonFileSizeArgLabel.Left + $PktMonFileSizeArgLabel.Width + $($FormScale * 5)
                Top    = $PktMonFileSizeArgLabel.Top
                Width  = $PktMonComponentComboBox.Width
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
                add_SelectedIndexChanged = {
                    if ($this.SelectedItem -ne '512'){
                        $script:FileSizeArg = "--file-size $($this.SelectedItem)"
                    }
                    else {
                        $script:FileSizeArg = $null
                    }
                    Update-PktMonCommand
                }
            }
            $FileSizeList = @('8','16','32','64','128','256','512','1024')
            Foreach ($Item in $FileSizeList) {$PktMonFileSizeComboBox.Items.Add($Item)}
            $PktMonPacketCaptureForm.Controls.Add($PktMonFileSizeComboBox)


        $PktMonCommandDescriptionLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = 'Command Executed on Remote Host:'
            Left   = $PktMonFileSizeLabel.Left
            Top    = $PktMonFileSizeLabel.Top + $PktMonFileSizeLabel.Height + $PktMonFileSizeLabel.Height + $($FormScale * 5)
            Width  = $PktMonOnlyPacketCountersCheckbox.Width + $PktMonOnlyPacketCountersArgLabel.Width + $($FormScale * 5) + $PktMonComponentComboBox.Width + $($FormScale * 5)
            Height = $FormScale * 16
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
            ForeColor = 'Black'
        }
        $PktMonPacketCaptureForm.Controls.Add($PktMonCommandDescriptionLabel)


        $PktMonCommandTextbox = New-Object System.Windows.Forms.Textbox -Property @{
            Text   = $null
            Left   = $PktMonCommandDescriptionLabel.Left
            Top    = $PktMonCommandDescriptionLabel.Top + $PktMonCommandDescriptionLabel.Height
            Width  = $PktMonOnlyPacketCountersCheckbox.Width + $PktMonOnlyPacketCountersArgLabel.Width + $($FormScale * 5) + $PktMonComponentComboBox.Width + $($FormScale * 5)
            Height = $FormScale * 30
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = 'DarkGreen'
            BackColor = 'White'
            ReadOnly  = $true
            Multiline = $true
            WordWrap  = $false
            Scrollbars = 'vertical'
        }
        $PktMonPacketCaptureForm.Controls.Add($PktMonCommandTextbox)

        function Update-PktMonFileNameDateTime {
            $DateTime = (Get-Date).ToString('yyyy-MM-dd HH.mm.ss')

            $script:PktMonFileNameEtl    = "PktMon $($DateTime).etl"
            $script:PktMonFileNamePcapng = "PktMon $($DateTime).pcapng"

            if ($script:SupportsCapture) {
                $script:Capture = '--capture'
                $script:FileName = "--file-name 'C:\Windows\Temp\$script:PktMonFileNameEtl'"
            }
            else {
                $script:Capture = $null
                $script:FileName = "--etw --file-name 'C:\Windows\Temp\$script:PktMonFileNameEtl'"
            }
        }
        Update-PktMonFileNameDateTime


        function Update-PktMonCommand {
            $PktMonCommandTextbox.Text = @"
pktmon start $script:Capture $script:ComponentArg $script:OnlyPacketCounters $script:TypeArg $script:PktSizeArg $script:FlagsArg $script:FileSizeArg $script:FileName
"@ -replace '\s+',' '
        }
        Update-PktMonCommand


        $PktMonFilterListLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Filters: **
It's highly recommended to apply filters before starting any packet capture, because troubleshooting connectivity to a particular destination is easier when you focus on a single stream of packets. Capturing all the networking traffic can make the output too noisy to analyze. Providing names within the filters are optional.
Up to 32 filters are supported at once.
Actual Command Example: pktmon filter add 'SMB SYN Packets' --IP 10.10.10.100  --Transport TCP SYN --Port 445"
            Left   = $PktMonCommandTextbox.Left
            Top    = $PktMonCommandTextbox.Top + $PktMonCommandTextbox.Height + $($FormScale * 5)
            Width  = $FormScale * 80
            Height = $FormScale * 16
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
            ForeColor = 'Black'
            Add_MouseEnter = {
                $this.Height = $FormScale * 90
                $this.Width  = $PktMonOnlyPacketCountersCheckbox.Width + $PktMonOnlyPacketCountersArgLabel.Width + $($FormScale * 5) + $PktMonComponentComboBox.Width + $($FormScale * 5)
                $this.ForeColor = 'DarkRed'
                $This.BringToFront()
            }
            Add_MouseLeave = {
                $this.Height = $FormScale * 16
                $this.Width  = $FormScale * 80
                $this.ForeColor = 'Black'
                $PktMonFilterListLabel.BringToFront()
            }
        }
        $PktMonPacketCaptureForm.Controls.Add($PktMonFilterListLabel)


            $PktMonFilterListNoteLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "For a packet to be reported, it must match all conditions specified in at least one filter."
                Left   = $FormScale * 90
                Top    = $PktMonCommandTextbox.Top + $PktMonCommandTextbox.Height + $($FormScale * 5)
                Width  = $FormScale * 425
                Height = $FormScale * 16
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor = 'Black'
            }
            $PktMonPacketCaptureForm.Controls.Add($PktMonFilterListNoteLabel)


        $PktMonFilterListSelectionComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
            Text   = "Enter a custom filter or select one or more to modify and/or add."
            Left   = $PktMonFilterListLabel.Left
            Top    = $PktMonFilterListLabel.Top + $PktMonFilterListLabel.Height
            Width  = $PktMonCommandTextbox.Width
            Height = $FormScale * 16
            Font   = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
            ForeColor  = 'Black'
            AutoCompleteSource = "ListItems"
            AutoCompleteMode   = "SuggestAppend"
            Add_MouseEnter = { $This.text = $This.SelectedItem -replace '\s+',' ' }
            Add_MouseLeave = { $This.text = $This.SelectedItem -replace '\s+',' ' }
        }
        $PktMonPacketCaptureForm.Controls.Add($PktMonFilterListSelectionComboBox)
        $PktMonPacketCaptureFilterList = @(
            "'SMB SYN Packets' --IP 10.10.10.100  --Transport TCP SYN --Port 445",
            "'TCP w/in Subnet' --IP 10.10.10.0/24 --Transport TCP",
            "'DNS To Server'   --IP 10.10.10.100  --Transport UDP --Port 53",
            "'Ping Traffic'    --IP 10.10.10.100  --Transport ICMP",
            "",
            "'TCP Traffic'    --Transport TCP",
            "'UDP Traffic'    --Transport UDP",
            "'ICMP Traffic'   --Transport ICMP",
            "'ICMPv6 Traffic' --Transport ICMPv6",
            "'Protocol #'     --Transport <Protocol Number>",
            "",
            "'Computer MAC' --MAC DE:AD:BE:EF:FE:ED",
            "'Computer MAC' --MAC DE-FA-CE-DB-AB-E1",
            "",
            "'Default VLAN' --VLAN 1",
            "",
            "'IPv4' --Data-Link IPv4",
            "'IPv6' --Data-Link IPv6",
            "'ARP'  --Data-Link ARP",
            "--Data-Link <Protocol Number>",
            "",
            "'VXLAN'    --Encap VXLAN",
            "'GRE'      --Encap GRE",
            "'NVGRE'    --Encap NVGRE",
            "'IP-in-IP' --Encap IP-in-IP",
            "",
            "'FTP'         --Port 21 --Transport TCP",
            "'SSH'         --Port 22 --Transport TCP",
            "'Telnet'      --Port 23 --Transport TCP",
            "'SMTP'        --Port 25 --Transport TCP",
            "'DNS'         --Port 53",
            "'DHCP-S'      --Port 67 --Transport UDP",
            "'DHCP-C'      --Port 68 --Transport UDP",
            "'TFTP'        --Port 69 --Transport UDP",
            "'HTTP'        --Port 80 --Transport TCP",
            "'Kerberos'    --Port 88",
            "'POP3'        --Port 110 --Transport TCP",
            "'RPCbind'     --Port 111",
            "'NTP'         --Port 123 --Transport UDP",
            "'MS-RPC'      --Port 135",
            "'NetBIOS-NS'  --Port 137 --Transport UDP",
            "'NetBIOS-DGM' --Port 138 --Transport UDP",
            "'NetBIOS-SSN' --Port 139",
            "'IMAP'        --Port 143 --Transport TCP",
            "'SNMP'        --Port 161 --Transport UDP",
            "'SNMP-Trap'   --Port 162 --Transport UDP",
            "'LDAP'        --Port 389 --Transport TCP",
            "'HTTPS'       --Port 443 --Transport TCP",
            "'SMB'         --Port 445",
            "'SMTPS'       --Port 465 --Transport TCP",
            "'ISAKMP'      --Port 500 --Transport UDP",
            "'SysLog'      --Port 514",
            "'RTSP'        --Port 554 --Transport TCP",
            "'RSync'       --Port 873 --Transport TCP",
            "'FTPS'        --Port 990 --Transport TCP",
            "'IMAPS'       --Port 993 --Transport TCP",
            "'POP3S'       --Port 995 --Transport TCP",
            "'MS-SQL-S'    --Port 1433",
            "'RADIUS-Auth' --Port 1645 --Transport UDP",
            "'RADIUS-Acnt' --Port 1646 --Transport UDP",
            "'L2TP'        --Port 1701 --Transport UDP",
            "'PPTP'        --Port 1723 --Transport TCP",
            "'RADIUS-Auth' --Port 1812 --Transport UDP",
            "'RADIUS-Acnt' --Port 1813 --Transport UDP",
            "'UPNP'        --Port 1900 --Transport UDP",
            "'Cisco-SCCP'  --Port 2000",
            "'NFS'         --Port 2049 --Transport UDP",
            "'PPP'         --Port 3000 --Transport TCP",
            "'MYSQL'       --Port 3306 --Transport TCP",
            "'RDP/MS-DS'   --Port 3389",
            "'MetaSploit'  --Port 4444",
            "'NAT-T-IKE'   --Port 4500 --Transport UDP",
            "'SIP'         --Port 5060 --Transport UDP",
            "'PostgreSQL'  --Port 5432 --Transport TCP",
            "'VNC'         --Port 5900",
            "'WinRM/HTTP'  --Port 5985 --Transport TCP",
            "'WinRM/HTTPS' --Port 5986 --Transport TCP",
            "'X11'         --Port 6000 --Transport TCP",
            "'HTTP-Alt'    --Port 8000 --Transport TCP",
            "'HTTP-Proxy'  --Port 8080 --Transport TCP",
            "'HTTPS-Alt'   --Port 8443 --Transport TCP"
        )
        Foreach ($Filter in $PktMonPacketCaptureFilterList) {
            $PktMonFilterListSelectionComboBox.Items.Add($Filter)
        }


        $PktMonFilterListSelectionAddButton = New-Object System.Windows.Forms.Button -Property @{
            Text   = 'Add Filter To Selected'
            Left   = $PktMonFilterListSelectionComboBox.Left
            Top    = $PktMonFilterListSelectionComboBox.Top + $PktMonFilterListSelectionComboBox.Height + $($FormScale * 5)
            Width  = $FormScale * 125
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = 'Black'
            Add_MouseEnter = { $PktMonFilterListSelectionComboBox.text = $PktMonFilterListSelectionComboBox.SelectedItem -replace '\s+',' ' }
            Add_MouseLeave = { $PktMonFilterListSelectionComboBox.text = $PktMonFilterListSelectionComboBox.SelectedItem -replace '\s+',' ' }
            Add_Click = {
                if ($script:PSSessionPktMon.state -notmatch 'Open') {
                    [System.Windows.Forms.MessageBox]::Show("There are no current open sessions.","PoSh-EasyWin",'Ok',"Warning")
                }
                elseif (-not $script:PSSessionPktMon) {
                    [System.Windows.Forms.MessageBox]::Show("There are no current open sessions.","PoSh-EasyWin",'Ok',"Warning")
                }
                elseif ($PktMonFilterListSelectionComboBox.text -eq $null -or $PktMonFilterListSelectionComboBox.text -eq '') {
                    [System.Windows.Forms.MessageBox]::Show("You need to select or enter a filter.","PoSh-EasyWin",'Ok',"Warning")
                }
                else {
                    Foreach ($Session in $script:PSSessionPktMon) {
                        if ($Session.ComputerName -eq $PktMonFilterTabControl.SelectedTab.Name ) {
                            $PktMonFilterListSelectionComboBoxtext = $($PktMonFilterListSelectionComboBox.text).trim() -replace '\s+',' '
                            if (Verify-Action -Title 'PoSh-EasyWin - PktMon.exe' -Question "Do you want to add the filter to:`n`n$($Session.ComputerName)") {
                                $PktMonFilterAddError = $null
                                $PktMonResults = Invoke-Command -ScriptBlock {
                                    param($PktMonFilterListSelectionComboBoxtext)
                                    Invoke-Expression "pktmon filter add $PktMonFilterListSelectionComboBoxtext"
                                } -ArgumentList @($PktMonFilterListSelectionComboBoxtext,$null) -Session $Session -ErrorVariable PktMonFilterAddError

                                $PktMonStatusTextbox.text = "$((Get-Date).tostring()):  [$($Session.ComputerName)] $($PktMonResults.trim() -replace '\s+',' ')  [$($PktMonFilterListSelectionComboBoxtext)]`r`n" + $PktMonStatusTextbox.text
                                if ($PktMonFilterAddError){
                                    $PktMonStatusTextbox.text = "$((Get-Date).tostring()):  [$($Session.ComputerName)] $($PktMonFilterAddError.trim() -replace '\s+',' ')`r`n" + $PktMonStatusTextbox.text
                                }
                            }
                        }
                    }
                }
                script:Update-PktMonFilterListBox
            }
        }
        $PktMonPacketCaptureForm.Controls.Add($PktMonFilterListSelectionAddButton)
        Add-CommonButtonSettings -Button $PktMonFilterListSelectionAddButton


        $PktMonFilterListSelectionAddAllButton = New-Object System.Windows.Forms.Button -Property @{
            Text   = 'Add Filter To All'
            Left   = $PktMonFilterListSelectionAddButton.Left + $PktMonFilterListSelectionAddButton.Width + $($FormScale * 5)
            Top    = $PktMonFilterListSelectionAddButton.Top
            Width  = $FormScale * 125
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = 'Black'
            Add_MouseEnter = { $PktMonFilterListSelectionComboBox.text = $PktMonFilterListSelectionComboBox.SelectedItem -replace '\s+',' ' }
            Add_MouseLeave = { $PktMonFilterListSelectionComboBox.text = $PktMonFilterListSelectionComboBox.SelectedItem -replace '\s+',' ' }
            Add_Click = {
                if ($script:PSSessionPktMon.state -notmatch 'Open') {
                    [System.Windows.Forms.MessageBox]::Show("There are no current open sessions.","PoSh-EasyWin",'Ok',"Warning")
                }
                elseif (-not $script:PSSessionPktMon) {
                    [System.Windows.Forms.MessageBox]::Show("There are no current open sessions.","PoSh-EasyWin",'Ok',"Warning")
                }
                elseif ($PktMonFilterListSelectionComboBox.text -eq $null -or $PktMonFilterListSelectionComboBox.text -eq '') {
                    [System.Windows.Forms.MessageBox]::Show("You need to select or enter a filter.","PoSh-EasyWin",'Ok',"Warning")
                }
                else {
                    $PktMonFilterListSelectionComboBoxtext = $($PktMonFilterListSelectionComboBox.text).trim() -replace '\s+',' '
                    if (Verify-Action -Title 'PoSh-EasyWin - PktMon.exe' -Question "Do you want to add the the filters to the following?`n`n$($script:ComputerList -join ', ')") {

                        $PktMonFilterAddError = $null
                        $PktMonResults = Invoke-Command -ScriptBlock {
                            param($PktMonFilterListSelectionComboBoxtext)
                            Invoke-Expression "pktmon filter add $PktMonFilterListSelectionComboBoxtext"
                        } -ArgumentList @($PktMonFilterListSelectionComboBoxtext,$null) -Session $script:PSSessionPktMon -ErrorVariable PktMonFilterAddError

                        $PktMonStatusTextbox.text = "$((Get-Date).tostring()):  [$($Session.ComputerName.Count) Endpoints] $($PktMonResults.trim() -replace '\s+',' ')  [$($PktMonFilterListSelectionComboBoxtext)]`r`n" + $PktMonStatusTextbox.text
                        if ($PktMonFilterAddError){
                            $PktMonStatusTextbox.text = "$((Get-Date).tostring()):  [$($Session.ComputerName.Count) Endpoints] $($PktMonFilterAddError.trim() -replace '\s+',' ')`r`n" + $PktMonStatusTextbox.text
                        }
                    }
                }
                script:Update-PktMonFilterListBox
            }
        }
        $PktMonPacketCaptureForm.Controls.Add($PktMonFilterListSelectionAddAllButton)
        Add-CommonButtonSettings -Button $PktMonFilterListSelectionAddAllButton


        $PktMonFilterListSelectionClearSelectedButton = New-Object System.Windows.Forms.Button -Property @{
            Text   = 'Clear on Selected'
            Left   = $PktMonFilterListSelectionAddAllButton.Left + $PktMonFilterListSelectionAddAllButton.Width + $($FormScale * 5)
            Top    = $PktMonFilterListSelectionAddAllButton.Top
            Width  = $FormScale * 125
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = 'Black'
            Add_MouseEnter = { $PktMonFilterListSelectionComboBox.text = $PktMonFilterListSelectionComboBox.SelectedItem -replace '\s+',' ' }
            Add_MouseLeave = { $PktMonFilterListSelectionComboBox.text = $PktMonFilterListSelectionComboBox.SelectedItem -replace '\s+',' ' }
            Add_Click = {
                if ($script:PSSessionPktMon.state -notmatch 'Open') {
                    [System.Windows.Forms.MessageBox]::Show("There are no current open sessions.","PoSh-EasyWin",'Ok',"Warning")
                }
                elseif (-not $script:PSSessionPktMon) {
                    [System.Windows.Forms.MessageBox]::Show("There are no current open sessions.","PoSh-EasyWin",'Ok',"Warning")
                }
                else {
                    Foreach ($Session in $($script:PSSessionPktMon | Sort-Object -Property ComputerName)) {
                        if ($Session.ComputerName -eq $PktMonFilterTabControl.SelectedTab.Name ) {
                            if (Verify-Action -Title 'PoSh-EasyWin - PktMon.exe' -Question "Do you want to clear the filters on:`n`n$($Session.ComputerName)") {
                                $PktMonFilterClearError = $null
                                $PktMonResults = Invoke-Command -ScriptBlock {
                                    PktMon filter remove
                                } -Session $Session -ErrorVariable PktMonFilterClearError

                                $PktMonStatusTextbox.text = "$((Get-Date).tostring()):  [$($Session.ComputerName)] $($PktMonResults.trim() -replace '\s+',' ')`r`n" + $PktMonStatusTextbox.text
                                if ($PktMonFilterClearError){
                                    $PktMonStatusTextbox.text = "$((Get-Date).tostring()):  [$($Session.ComputerName)] $($PktMonFilterClearError.trim() -replace '\s+',' ')`r`n" + $PktMonStatusTextbox.text
                                }
                            }
                        }
                    }
                }
                script:Update-PktMonFilterListBox
            }
        }
        $PktMonPacketCaptureForm.Controls.Add($PktMonFilterListSelectionClearSelectedButton)
        Add-CommonButtonSettings -Button $PktMonFilterListSelectionClearSelectedButton


        $PktMonFilterListSelectionClearAllButton = New-Object System.Windows.Forms.Button -Property @{
            Text   = 'Clear on All'
            Left   = $PktMonFilterListSelectionClearSelectedButton.Left + $PktMonFilterListSelectionClearSelectedButton.Width + $($FormScale * 5)
            Top    = $PktMonFilterListSelectionClearSelectedButton.Top
            Width  = $FormScale * 125
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = 'Black'
            Add_MouseEnter = { $PktMonFilterListSelectionComboBox.text = $PktMonFilterListSelectionComboBox.SelectedItem -replace '\s+',' ' }
            Add_MouseLeave = { $PktMonFilterListSelectionComboBox.text = $PktMonFilterListSelectionComboBox.SelectedItem -replace '\s+',' ' }
            Add_Click = {
                if ($script:PSSessionPktMon.state -notmatch 'Open') {
                    [System.Windows.Forms.MessageBox]::Show("There are no current open sessions.","PoSh-EasyWin",'Ok',"Warning")
                }
                elseif (-not $script:PSSessionPktMon) {
                    [System.Windows.Forms.MessageBox]::Show("There are no current open sessions.","PoSh-EasyWin",'Ok',"Warning")
                }
                else {
                    if (Verify-Action -Title 'PoSh-EasyWin - PktMon.exe' -Question "Do you want to clear the filters on the following?`n`n$($script:ComputerList -join ', ')") {
                        $PktMonFilterClearError = $null
                        $PktMonResults = Invoke-Command -ScriptBlock {
                            PktMon filter remove
                        } -Session $script:PSSessionPktMon -ErrorVariable PktMonFilterClearError

                        $PktMonStatusTextbox.text = "$((Get-Date).tostring()):  [$($Session.ComputerName.Count) Endpoints] $($PktMonResults.trim() -replace '\s+',' ')`r`n" + $PktMonStatusTextbox.text
                        if ($PktMonFilterClearError){
                            $PktMonStatusTextbox.text = "$((Get-Date).tostring()):  [$($Session.ComputerName.Count) Endpoints] $($PktMonFilterClearError.trim() -replace '\s+',' ')`r`n" + $PktMonStatusTextbox.text
                        }
                    }
                }
                script:Update-PktMonFilterListBox
            }
        }
        $PktMonPacketCaptureForm.Controls.Add($PktMonFilterListSelectionClearAllButton)
        Add-CommonButtonSettings -Button $PktMonFilterListSelectionClearAllButton


        $PktMonFilterTabControl = New-Object System.Windows.Forms.TabControl -Property @{
            Left   = $PktMonFilterListSelectionAddButton.Left
            Top    = $PktMonFilterListSelectionAddButton.Top + $PktMonFilterListSelectionAddButton.Height + $($FormScale * 5)
            Width  = $FormScale * 710
            Height = $FormScale * 140
            Appearance = [System.Windows.Forms.TabAppearance]::Buttons
            Hottrack   = $true
            Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,2,1)
        }
        $PktMonPacketCaptureForm.Controls.Add($PktMonFilterTabControl)


        $PktMonStatusDescriptionLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = 'Status Information:'
            Left   = $PktMonFilterTabControl.Left
            Top    = $PktMonFilterTabControl.Top + $PktMonFilterTabControl.Height + $($FormScale * 5)
            Width  = $PktMonOnlyPacketCountersCheckbox.Width + $PktMonOnlyPacketCountersArgLabel.Width + $($FormScale * 5) + $PktMonComponentComboBox.Width + $($FormScale * 5)
            Height = $FormScale * 16
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
            ForeColor = 'Black'
            Add_MouseEnter = { $PktMonFilterListSelectionComboBox.text = $PktMonFilterListSelectionComboBox.SelectedItem -replace '\s+',' ' }
            Add_MouseLeave = { $PktMonFilterListSelectionComboBox.text = $PktMonFilterListSelectionComboBox.SelectedItem -replace '\s+',' ' }
        }
        $PktMonPacketCaptureForm.Controls.Add($PktMonStatusDescriptionLabel)


        $PktMonStatusTextbox = New-Object System.Windows.Forms.Textbox -Property @{
            Text   = $null
            Left   = $PktMonStatusDescriptionLabel.Left
            Top    = $PktMonStatusDescriptionLabel.Top + $PktMonStatusDescriptionLabel.Height
            Width  = $PktMonOnlyPacketCountersCheckbox.Width + $PktMonOnlyPacketCountersArgLabel.Width + $($FormScale * 5) + $PktMonComponentComboBox.Width + $($FormScale * 5)
            Height = $FormScale * 100
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = 'Black'
            BackColor = 'White'
            ReadOnly  = $true
            Multiline = $true
            WordWrap  = $true
            Scrollbars = 'vertical'
            Add_MouseEnter = { $PktMonFilterListSelectionComboBox.text = $PktMonFilterListSelectionComboBox.SelectedItem -replace '\s+',' ' }
            Add_MouseLeave = { $PktMonFilterListSelectionComboBox.text = $PktMonFilterListSelectionComboBox.SelectedItem -replace '\s+',' ' }
        }
        $PktMonPacketCaptureForm.Controls.Add($PktMonStatusTextbox)


        $script:PktMonCaptureStartButton = New-Object System.Windows.Forms.Button -Property @{
            Text   = 'Start Capture'
            Left   = $PktMonStatusTextbox.Left
            Top    = $PktMonStatusTextbox.Top + $PktMonStatusTextbox.Height + $($FormScale * 5)
            Width  = $FormScale * 110
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = 'Black'
            Enabled = $true
            Add_MouseEnter = { $PktMonFilterListSelectionComboBox.text = $PktMonFilterListSelectionComboBox.SelectedItem -replace '\s+',' ' }
            Add_MouseLeave = { $PktMonFilterListSelectionComboBox.text = $PktMonFilterListSelectionComboBox.SelectedItem -replace '\s+',' ' }
            Add_Click = {
                if ($script:PSSessionPktMon.state -notmatch 'Open') {
                    [System.Windows.Forms.MessageBox]::Show("There are no current open sessions.","PoSh-EasyWin",'Ok',"Warning")
                }
                elseif (-not $script:PSSessionPktMon) {
                    [System.Windows.Forms.MessageBox]::Show("There are no current open sessions.","PoSh-EasyWin",'Ok',"Warning")
                }
                else {
                    if (Verify-Action -Title 'PoSh-EasyWin - PktMon.exe' -Question "Do you want to start a packet capture on the following:`n`n$($script:ComputerList -join ', ')") {
                        $PktMonCaptureStopButton.enabled = $true
                        $This.enabled = $false

                        Update-PktMonFileNameDateTime
                        Update-PktMonCommand

                        foreach ($session in $script:PSSessionPktMon) {
                            $PktMonResultsError = $null
                            $PktMonResults = Invoke-Command -ScriptBlock {
                                param($PktMonCommandTextboxText)
                                Invoke-Expression $PktMonCommandTextboxText
                            } -ArgumentList @($PktMonCommandTextbox.Text,$null) -Session $Session -ErrorVariable PktMonResultsError

                            $PktMonStatusTextbox.text = "$((Get-Date).tostring()):  [$($Session.ComputerName)] $($PktMonResults.trim() -replace '\s+',' ')`r`n" + $PktMonStatusTextbox.text
                            if ($PktMonResultsError){
                                $PktMonStatusTextbox.text = "$((Get-Date).tostring()):  [$($Session.ComputerName)] Error $($PktMonResultsError.trim() -replace '\s+',' ')`r`n" + $PktMonStatusTextbox.text
                            }
                        }
                    }
                }
            }
        }
        $PktMonPacketCaptureForm.Controls.Add($script:PktMonCaptureStartButton)
        Add-CommonButtonSettings -Button $script:PktMonCaptureStartButton

        $StopAndCollectCaptures = {
            if (Verify-Action -Title 'PoSh-EasyWin - PktMon.exe' -Question "Do you want stop packet capturing on the following?`n`n$($script:ComputerList -join ', ')") {
                Foreach ($Session in $script:PSSessionPktMon) {
                    $PktMonResultsError = $null
                    $PktMonResults = Invoke-Command -ScriptBlock {
                        & PktMon stop
                    } -Session $Session -ErrorVariable PktMonResultsError

                    $PktMonStatusTextbox.text = "$((Get-Date).tostring()):  [$($Session.ComputerName)] $($PktMonResults.trim() -replace '\s+',' ')`r`n" + $PktMonStatusTextbox.text
                    if ($PktMonResultsError) {
                        $PktMonStatusTextbox.text = "$((Get-Date).tostring()):  [$($Session.ComputerName)] Error $($PktMonResultsError.trim() -replace '\s+',' ')`r`n" + $PktMonStatusTextbox.text
                    }
                }
                $PacketCaptureDetails = @()
                Foreach ($Session in $script:PSSessionPktMon) {
                    $PktMonDetailsError = $null
                    $PacketCaptureDetails += Invoke-Command -ScriptBlock {
                        param($FileName)
                        Get-ItemProperty "C:\Windows\Temp\$FileName" | Select-Object @{n='ComputerName';e={$env:ComputerName}}, Name, CreationTime, LastAccessTime, LastWriteTime, Length, @{n='KiloBytes';e={[math]::round($($_.Length / 1KB),2)}}, @{n='MegaBytes';e={[math]::round($($_.Length / 1MB),2)}}, @{n='GigaBytes';e={[math]::round($($_.Length / 1GB),2)}}, Directory
                    } -ArgumentList @($script:PktMonFileNameEtl,$null) -Session $Session -ErrorVariable PktMonDetailsError

                    $PktMonStatusTextbox.text = "$((Get-Date).tostring()):  [$($Session.ComputerName)] Removing file from [$($Session.ComputerName)]$('C:\Windows\Temp\$script:PktMonFileNameEtl')`r`n" + $PktMonStatusTextbox.text
                    if ($PktMonDetailsError) {
                        $PktMonStatusTextbox.text = "$((Get-Date).tostring()):  [$($Session.ComputerName)] Error $($PktMonDetailsError.trim() -replace '\s+',' ')`r`n" + $PktMonStatusTextbox.text
                    }
                }
                $SelectedPacketCaptures = $PacketCaptureDetails | Out-GridView -Title "PoSh-EasyWin - Packet Capture Details" -PassThru

                Foreach ($Session in $script:PSSessionPktMon) {
                    Foreach ($Capture in $SelectedPacketCaptures) {
                        if ($Session.ComputerName -eq $Capture.ComputerName) {
                            # Copies data back to localhost
                            $PktMonCopyError = $null
                            New-Item -Type Directory $script:CollectionSavedDirectoryTextBox.Text
                            Copy-Item -Path "C:\Windows\Temp\$script:PktMonFileNameEtl" -Destination "$($script:CollectionSavedDirectoryTextBox.Text)\$($Session.ComputerName) $script:PktMonFileNameEtl" -FromSession $Session -ErrorVariable PktMonCopyError
                            $PktMonStatusTextbox.text = "$((Get-Date).tostring()):  [$($Session.ComputerName)] Copying $('C:\Windows\Temp\$script:PktMonFileNameEtl') to localhost`r`n" + $PktMonStatusTextbox.text
                            if ($PktMonCopyError) {
                                $PktMonStatusTextbox.text = "$((Get-Date).tostring()):  [$($Session.ComputerName)] Error $($PktMonCopyError.trim() -replace '\s+',' ')`r`n" + $PktMonStatusTextbox.text
                            }

                            # Removes remote .etl file from endpoints
                            $PktMonRemoveError = $null
                            Invoke-Command -ScriptBlock {
                                param($FileName)
                                Remove-Item "C:\Windows\Temp\$FileName" -Force
                            } -ArgumentList @($script:PktMonFileNameEtl,$null) -Session $Session -ErrorVariable PktMonRemoveError
                            $PktMonStatusTextbox.text = "$((Get-Date).tostring()):  [$($Session.ComputerName)] Removing file from [$($Session.ComputerName)]$('C:\Windows\Temp\$script:PktMonFileNameEtl')`r`n" + $PktMonStatusTextbox.text
                            if ($PktMonRemoveError) {
                                $PktMonStatusTextbox.text = "$((Get-Date).tostring()):  [$($Session.ComputerName)] Error $($PktMonRemoveError.trim() -replace '\s+',' ')`r`n" + $PktMonStatusTextbox.text
                            }

                            # Converts local .etl file to .pcapng
                            pktmon etl2pcap "$($script:CollectionSavedDirectoryTextBox.Text)\$($Session.ComputerName) $script:PktMonFileNameEtl" --out "$($script:CollectionSavedDirectoryTextBox.Text)\$($Session.ComputerName) $script:PktMonFileNamePcapng"

                            # Removes local .etl file
                            Remove-Item "$($script:CollectionSavedDirectoryTextBox.Text)\$($Session.ComputerName) $script:PktMonFileNameEtl"

                            # Adds metadata / alternate data streams (ADS) to local .pcapng files
                            $PktMonFilterListToADSResults = Invoke-Command -ScriptBlock {
                                & PktMon filter list | Where-Object {$_ -notmatch '----'}
                            } -Session $Session
                            $PktMonFilterListToADSResults = $PktMonFilterListToADSResults.split("`r`n") -join '&&'
                            Invoke-Expression "Set-Content '$($script:CollectionSavedDirectoryTextBox.Text)\$($Session.ComputerName) $($script:PktMonFileNamePcapng):PacketCaptureMetadata' -Value '$PktMonFilterListToADSResults'"

                            # Opens selected local .pcapng file with system default application - typically Wireshark if installed
                            Invoke-Item "$($script:CollectionSavedDirectoryTextBox.Text)\$($Session.ComputerName) $script:PktMonFileNamePcapng"
                        }
                    }
                }
            }
        }

        $PktMonCaptureStopButton = New-Object System.Windows.Forms.Button -Property @{
            Text   = 'Stop Capture'
            Left   = $script:PktMonCaptureStartButton.Left + $script:PktMonCaptureStartButton.Width + $($FormScale * 5)
            Top    = $script:PktMonCaptureStartButton.Top
            Width  = $FormScale * 110
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = 'Black'
            Enabled = $false
            Add_Click = {
                if ($script:PSSessionPktMon.state -notmatch 'Open') {
                    [System.Windows.Forms.MessageBox]::Show("There are no current open sessions.","PoSh-EasyWin",'Ok',"Warning")
                }
                elseif (-not $script:PSSessionPktMon) {
                    [System.Windows.Forms.MessageBox]::Show("There are no current open sessions.","PoSh-EasyWin",'Ok',"Warning")
                }
                else {
                    & $StopAndCollectCaptures

                    $script:PktMonCaptureStartButton.enabled = $true
                    $This.Enabled = $false
                }
            }
        }
        $PktMonPacketCaptureForm.Controls.Add($PktMonCaptureStopButton)
        Add-CommonButtonSettings -Button $PktMonCaptureStopButton


        $PktMonPSSessionOpenCapturesButton = New-Object System.Windows.Forms.Button -Property @{
            Text   = 'Open Captures'
            Left   = $PktMonCaptureStopButton.Left + $PktMonCaptureStopButton.Width + $($FormScale * 5)
            Top    = $PktMonCaptureStopButton.Top
            Width  = $FormScale * 110
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = 'Black'
            Add_Click = {
                Get-ChildItem $PewCollectedData -Recurse `
                | Where-Object {$_.extension -match 'pcap'} `
                | Select-Object -Property `
                    @{n='ComputerName';e={$($_.BaseName.split(' ')[0])}}, `
                    Name, CreationTime, LastAccessTime, LastWriteTime, `
                    @{n='Filter';e={$(Get-Content "$($_.Fullname):PacketCaptureMetadata") -replace "&&","`r`n"}}, `
                    Length, @{n='KiloBytes';e={[math]::round($($_.Length / 1KB),2)}}, @{n='MegaBytes';e={[math]::round($($_.Length / 1MB),2)}}, @{n='GigaBytes';e={[math]::round($($_.Length / 1GB),2)}}, Directory, Fullname `
                | Sort-Object -Property @{e="CreationTime";Descending=$True}, @{e="Name";Descending=$False} `
                | Out-GridView -Title 'PoSh-EasyWin - Packet Captures' -PassThru `
                | ForEach-Object { Invoke-Item "$($_.Fullname)" }
            }
        }
        $PktMonPacketCaptureForm.Controls.Add($PktMonPSSessionOpenCapturesButton)
        Add-CommonButtonSettings -Button $PktMonPSSessionOpenCapturesButton


        $PktMonPSSessionRestartButton = New-Object System.Windows.Forms.Button -Property @{
            Text   = 'New-PSSession'
            Left   = $PktMonPSSessionOpenCapturesButton.Left + $PktMonPSSessionOpenCapturesButton.Width + $($FormScale * 5)
            Top    = $PktMonPSSessionOpenCapturesButton.Top
            Width  = $FormScale * 110
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = 'Black'
            Enabled = $false
            Add_Click = {
                if (Verify-Action -Title 'PoSh-EasyWin - New-PSSession' -Question "Do you want to start a new PSSession to the following?`n`n$($script:ComputerList -join ', ')") {
                    $script:PSSessionPktMon = New-PSSession -ComputerName $script:ComputerList -Credential $script:Credential
                    $PktMonPSSessionRemoveButton.Enabled = $True
                    $This.Enabled = $false
                    $script:Timer.Start()
                }
            }
        }
        $PktMonPacketCaptureForm.Controls.Add($PktMonPSSessionRestartButton)
        Add-CommonButtonSettings -Button $PktMonPSSessionRestartButton


        $PktMonPSSessionRemoveButton = New-Object System.Windows.Forms.Button -Property @{
            Text   = 'Remove-PSSession'
            Left   = $PktMonPSSessionRestartButton.Left + $PktMonCaptureStopButton.Width + $($FormScale * 5)
            Top    = $PktMonPSSessionRestartButton.Top
            Width  = $FormScale * 110
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = 'Black'
            Enabled = $true
            Add_Click = {
                if (Verify-Action -Title 'PoSh-EasyWin - Remove-PSSession' -Question "Do you want to remove the current PSSession on the following?`n`n$($script:ComputerList -join ', ')") {
                    $script:PSSessionPktMon | Remove-PSSession
                    $This.Enabled = $false
                    & $UpdateStatusBar
                }
            }
        }
        $PktMonPacketCaptureForm.Controls.Add($PktMonPSSessionRemoveButton)
        Add-CommonButtonSettings -Button $PktMonPSSessionRemoveButton


        $PktMonPSSessionStatusButton = New-Object System.Windows.Forms.Button -Property @{
            Text   = 'Get-PSSession'
            Left   = $PktMonPSSessionRemoveButton.Left + $PktMonPSSessionRemoveButton.Width + $($FormScale * 5)
            Top    = $PktMonPSSessionRemoveButton.Top
            Width  = $FormScale * 110
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = 'Black'
            Add_Click = {
                $script:PSSessionPktMon | Out-GridView -Title "PoSh-EasyWin - PSSession Status"
            }
        }
        $PktMonPacketCaptureForm.Controls.Add($PktMonPSSessionStatusButton)
        Add-CommonButtonSettings -Button $PktMonPSSessionStatusButton


        $script:Timer = New-Object System.Windows.Forms.Timer -Property @{
            Enabled  = $true
            Interval = 1000
        }
        $script:Timer.Start()


        $script:FileTransferStatusBar = New-Object System.Windows.Forms.StatusBar


        $UpdateStatusBar = {
            if ($script:PSSessionPktMon) {
                $PSSessionOpen   = ($script:PSSessionPktMon | Where-Object {$_.State -match 'Opened'}).count
                $PSSessionClosed = ($script:PSSessionPktMon | Where-Object {$_.State -match 'Closed'}).count
                $PSSessionDisconnected = ($script:PSSessionPktMon | Where-Object {$_.State -match 'Disconnected'}).count
                $PSSessionBroken = ($script:PSSessionPktMon | Where-Object {$_.State -match 'Broken'}).count

                $script:ConnectionState = "$(Get-Date) - Connection Status: Open [$PSSessionOpen], Closed [$PSSessionClosed], Disconnected [$PSSessionDisconnected], Broken [$PSSessionBroken]"
            }
            else {
                $script:ConnectionState = "$(Get-Date) - Connection Status with $($script:ComputerList):  Error"
            }

            if ($script:PSSessionPktMon.State -match 'Open') {
                $script:FileTransferStatusBar.Text = $script:ConnectionState
                if ($script:PktMonCaptureStartButton.enabled -eq $true){
                    Update-PktMonFileNameDateTime
                    Update-PktMonCommand
                }
            }
            else {
                $script:FileTransferStatusBar.Text = $script:ConnectionState
                $PktMonPSSessionRemoveButton.Enabled = $false
                $PktMonPSSessionRestartButton.Enabled = $true
                $script:Timer.Stop()
            }

        }
        $script:Timer.add_Tick($UpdateStatusBar)


        $PktMonPacketCaptureForm.Controls.Add($script:FileTransferStatusBar)

    $PktMonPacketCaptureForm.ShowDialog()

    <#
    ############On both
        --log-mode { circular | multi-file | memory | real-time }
            Logging mode. Default is circular.

            circular    New events overwrite the oldest ones when the log is full.

            multi-file  No limit on number of captured events, but a new log file
                        is created each time the log is full.

            memory      Like circular, but the entire log is stored in memory.
                        It is written to a file when pktmon is stopped.

            real-time   Display events and packets on screen at real time. No log
                        file is created. Press Ctrl+C to stop monitoring.

    #############
        ### new
        Event Providers
        [--trace --provider <name> [--keywords <k>] [--level <n>] ...]
        -t, --trace
            Enable event collection.

            -p, --provider <name>
                Event provider name or GUID. For multiple providers, use this
                parameter more than once.

            -k, --keywords <k>
                Hexadecimal bitmask that controls which events are logged
                for the corresponding provider. Default is 0xFFFFFFFF.

            -l, --level <n>
                Logging level for the corresponding provider.
                Default is 4 (info level).

        ### old
        ETW Logging
            [--etw [-p size] [-k keywords]]
            --etw
                Start a logging session for packet capture.
            -k, --keywords
                Hexadecimal bitmask (i.e. sum of the below flags) that controls
                which events are logged. Default is 0x012.

                Flags:
                0x001 - Internal Packet Monitor errors.
                0x002 - Information about components, counters and filters.
                        This information is added to the end of the log file.
                0x004 - Source and destination information for the first
                        packet in NET_BUFFER_LIST group.
                0x008 - Select packet metadata from NDIS_NET_BUFFER_LIST_INFO
                        enumeration.
                0x010 - Raw packet, truncated to the size specified in
                        [--packet-size] parameter.


    ############
        ### both
            -p, --packet-size
                Number of bytes to log from each packet. To always log the entire
                packet, set this to 0. Default is 128 bytes.
    ############
        ### new
            --comp { all | nics | id1 id2 ... }
                Select components to capture packets on. Can be ALL components,
                NICs only, or a list of component Ids. Default is ALL.
        ### old
            -c, --components
                Select components to monitor. Can be all components, NICs only, or a
                list of component ids. Defaults to all.
    #>
}




Update-FormProgress "Show-PortProxy"
function Show-PortProxy {
    function Manage-WindowsRelay {
        Param(
            $ComputerName,
            [Switch]$Delete,
            [Switch]$Show,
            $RelayType,
            $ListenAddress,
            $ListenPort,
            $ConnectAddress,
            $ConnectPort,
            $UserName,
            $Password,
            [switch]$UseCreds,
            #[System.Management.Automation.PSCredential]
            $Credential
        )
        if ($UseCreds) {
            $Credential.GetNetworkCredential.
            $null
        }
        elseif ($UserName -and $Password) {
            $SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ($UserName, $SecurePassword)
        }
        else {
            $Credential = $Null
        }

        if ($Show) {
            if ($UseCreds) {
                Invoke-Command -ScriptBlock {
                    $PortProxy = @()
                    $netsh = & netsh interface portproxy show all
                    $netsh | Select-Object -Skip 5 | Where-Object {$_ -ne ''} | ForEach-Object {
                        $Attribitutes = $_ -replace "\s+"," " -split ' '
                        $PortProxy += [PSCustomObject]@{
                            'ComputerName'         = $Env:COMPUTERNAME
                            'Listening On Address' = $Attribitutes[0]
                            'Listening On Port'    = $Attribitutes[1]
                            'Connect To Address'   = $Attribitutes[2]
                            'Connect To Port'      = $Attribitutes[3]
                        }
                    }
                    return $PortProxy | Where-Object {$_.'Listening On Address' -match "\d.\d.\d.\d" -or $_.'Listening On Address' -match ':' }
                } -ArgumentList $null -ComputerName $ComputerName -Credential $Credential
            }
            else {
                Invoke-Command -ScriptBlock {
                    $PortProxy = @()
                    $netsh = & netsh interface portproxy show all
                    $netsh | Select-Object -Skip 5 | Where-Object {$_ -ne ''} | ForEach-Object {
                        $Attribitutes = $_ -replace "\s+"," " -split ' '
                        $PortProxy += [PSCustomObject]@{
                            'ComputerName'         = $Env:COMPUTERNAME
                            'Listening On Address' = $Attribitutes[0]
                            'Listening On Port'    = $Attribitutes[1]
                            'Connect To Address'   = $Attribitutes[2]
                            'Connect To Port'      = $Attribitutes[3]
                        }
                    }
                    return $PortProxy | Where-Object {$_.'Listening On Address' -match "\d.\d.\d.\d" -or $_.'Listening On Address' -match ':' }
                } -ArgumentList $null -ComputerName $ComputerName
            }
        }


        if (-not $Delete -and -not $Show) {
            if ($UseCreds) {
                Invoke-Command -ScriptBlock {
                    param ($RelayType,$ListenPort,$ListenAddress,$ConnectPort,$ConnectAddress)

                    & netsh interface portproxy add $RelayType listenport=$ListenPort listenaddress=$ListenAddress connectport=$ConnectPort connectaddress=$ConnectAddress protocol=tcp

                } -ArgumentList @($RelayType,$ListenPort,$ListenAddress,$ConnectPort,$ConnectAddress) -ComputerName $ComputerName -Credential $Credential | Out-Null

                Invoke-Command -ScriptBlock {
                    $PortProxy = @()
                    $netsh = & netsh interface portproxy show all
                    $netsh | Select-Object -Skip 5 | Where-Object {$_ -ne ''} | ForEach-Object {
                        $Attribitutes = $_ -replace "\s+"," " -split ' '
                        $PortProxy += [PSCustomObject]@{
                            'ComputerName'         = $Env:COMPUTERNAME
                            'Listening On Address' = $Attribitutes[0]
                            'Listening On Port'    = $Attribitutes[1]
                            'Connect To Address'   = $Attribitutes[2]
                            'Connect To Port'      = $Attribitutes[3]
                        }
                    }
                    return $PortProxy | Where-Object {$_.'Listening On Address' -match "\d.\d.\d.\d" -or $_.'Listening On Address' -match ':' }
                } -ArgumentList $null -ComputerName $ComputerName -Credential $Credential
            }
            else {
                Invoke-Command -ScriptBlock {
                    param ($RelayType,$ListenPort,$ListenAddress,$ConnectPort,$ConnectAddress)

                    & netsh interface portproxy add $RelayType listenport=$ListenPort listenaddress=$ListenAddress connectport=$ConnectPort connectaddress=$ConnectAddress protocol=tcp

                } -ArgumentList @($RelayType,$ListenPort,$ListenAddress,$ConnectPort,$ConnectAddress) -ComputerName $ComputerName | Out-Null

                Invoke-Command -ScriptBlock {
                    $PortProxy = @()
                    $netsh = & netsh interface portproxy show all
                    $netsh | Select-Object -Skip 5 | Where-Object {$_ -ne ''} | ForEach-Object {
                        $Attribitutes = $_ -replace "\s+"," " -split ' '
                        $PortProxy += [PSCustomObject]@{
                            'ComputerName'         = $Env:COMPUTERNAME
                            'Listening On Address' = $Attribitutes[0]
                            'Listening On Port'    = $Attribitutes[1]
                            'Connect To Address'   = $Attribitutes[2]
                            'Connect To Port'      = $Attribitutes[3]
                        }
                    }
                    return $PortProxy | Where-Object {$_.'Listening On Address' -match "\d.\d.\d.\d" -or $_.'Listening On Address' -match ':' }
                } -ArgumentList $null -ComputerName $ComputerName
            }
        }

        if ($Delete) {
            if ($UseCreds) {
                Invoke-Command -ScriptBlock {
                    param ($RelayType,$ListenPort,$ListenAddress)

                    & netsh interface portproxy delete $RelayType listenport=$ListenPort listenaddress=$ListenAddress protocol=tcp

                } -ArgumentList @($RelayType,$ListenPort,$ListenAddress) -ComputerName $ComputerName -Credential $Credential | Out-Null

                Invoke-Command -ScriptBlock {
                    $PortProxy = @()
                    $netsh = & netsh interface portproxy show all
                    $netsh | Select-Object -Skip 5 | Where-Object {$_ -ne ''} | ForEach-Object {
                        $Attribitutes = $_ -replace "\s+"," " -split ' '
                        $PortProxy += [PSCustomObject]@{
                            'ComputerName'         = $Env:COMPUTERNAME
                            'Listening On Address' = $Attribitutes[0]
                            'Listening On Port'    = $Attribitutes[1]
                            'Connect To Address'   = $Attribitutes[2]
                            'Connect To Port'      = $Attribitutes[3]
                        }
                    }
                    return $PortProxy | Where-Object {$_.'Listening On Address' -match "\d.\d.\d.\d" -or $_.'Listening On Address' -match ':' }
                } -ArgumentList $null -ComputerName $ComputerName -Credential $Credential
            }
            else {
                Invoke-Command -ScriptBlock {
                    param ($RelayType,$ListenPort,$ListenAddress)

                    & netsh interface portproxy delete $RelayType listenport=$ListenPort listenaddress=$ListenAddress protocol=tcp

                } -ArgumentList @($RelayType,$ListenPort,$ListenAddress) -ComputerName $ComputerName | Out-Null

                Invoke-Command -ScriptBlock {
                    $PortProxy = @()
                    $netsh = & netsh interface portproxy show all
                    $netsh | Select-Object -Skip 5 | Where-Object {$_ -ne ''} | ForEach-Object {
                        $Attribitutes = $_ -replace "\s+"," " -split ' '
                        $PortProxy += [PSCustomObject]@{
                            'ComputerName'         = $Env:COMPUTERNAME
                            'Listening On Address' = $Attribitutes[0]
                            'Listening On Port'    = $Attribitutes[1]
                            'Connect To Address'   = $Attribitutes[2]
                            'Connect To Port'      = $Attribitutes[3]
                        }
                    }
                    return $PortProxy | Where-Object {$_.'Listening On Address' -match "\d.\d.\d.\d" -or $_.'Listening On Address' -match ':' }
                } -ArgumentList $null -ComputerName $ComputerName
            }
        }
    }

    Generate-ComputerList

    $ManagePortProxyForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = "PoSh-EasyWin - Port Proxy"
        Width  = $FormScale * 440
        Height = $FormScale * 400
        StartPosition = "CenterScreen"
        Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoScroll    = $True
        #FormBorderStyle =  "fixed3d"
        #ControlBox    = $false
        MaximizeBox   = $false
        MinimizeBox   = $false
        ShowIcon      = $true
        TopMost       = $true
        Add_Shown     = $null
        Add_Closing = { $This.dispose() }
    }

    $ManagePortProxyPictureBox = New-Object Windows.Forms.PictureBox -Property @{
        Text   = "PowerShell Charts"
        Left   = $FormScale * 10
        Top    = $FormScale * 10
        Width  = $FormScale * 300
        Height = $FormScale * 44
        Image  = [System.Drawing.Image]::Fromfile("$Dependencies\Images\Port_Proxy_Banner.png")
        SizeMode = 'StretchImage'
    }
    $ManagePortProxyForm.Controls.Add($ManagePortProxyPictureBox)


    $ManagePortProxyLabel = New-Object System.Windows.Forms.Label -Property @{
        Text   = "The netsh command can be used to configure port proxies, allowing the mapping and redirection of traffic one port to another, be it external or local to the endpoint."
        Left   = $FormScale * 10
        Top    = $ManagePortProxyPictureBox.Top + $ManagePortProxyPictureBox.Height + ($FormScale * 5)
        Width  = $FormScale * 400
        Height = $FormScale * 50
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = 'Blue'
    }
    $ManagePortProxyForm.Controls.Add($ManagePortProxyLabel)


    $RelayActionLabel = New-Object System.Windows.Forms.Label -Property @{
        Text   = "Action to perform:"
        Left   = $ManagePortProxyLabel.Left
        Top    = $ManagePortProxyLabel.Top + $ManagePortProxyLabel.Height + ($FormScale + 5)
        Width  = $FormScale * 250
        Height = $FormScale * 22
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
    }
    $ManagePortProxyForm.Controls.Add($RelayActionLabel)


    $RelayActionComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Left   = $RelayActionLabel.Left + $RelayActionLabel.width + ($FormScale + 5)
        Top    = $RelayActionLabel.Top
        Width  = $FormScale * 125
        Height = $FormScale * 22
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        Add_SelectedIndexChanged = {
            switch ($this.SelectedItem){
                'Show'   {
                    $RelayTypeComboBox.enabled           = $false
                    $RelayListenAddressComboBox.enabled  = $false
                    $RelayListenPortComboBox.enabled     = $false
                    $RelayConnectAddressComboBox.enabled = $false
                    $RelayConnectPortComboBox.enabled    = $false
                    $RelayComputerNameComboBox.enabled   = $true
                    $RelayProtocolComboBox.enabled       = $false

                    $RelayComputerNameLabel.text = "IP/Hostname to Show port proxy:"
                }
                'Create' {
                    $RelayTypeComboBox.enabled           = $true
                    $RelayListenAddressComboBox.enabled  = $true
                    $RelayListenPortComboBox.enabled     = $true
                    $RelayConnectAddressComboBox.enabled = $true
                    $RelayConnectPortComboBox.enabled    = $true
                    $RelayComputerNameComboBox.enabled   = $true
                    $RelayProtocolComboBox.enabled       = $false

                    $RelayComputerNameLabel.text = "IP/Hostname to Create port proxy:"
                }
                'Delete' {
                    $RelayTypeComboBox.enabled           = $true
                    $RelayListenAddressComboBox.enabled  = $true
                    $RelayListenPortComboBox.enabled     = $true
                    $RelayConnectAddressComboBox.enabled = $false
                    $RelayConnectPortComboBox.enabled    = $false
                    $RelayComputerNameComboBox.enabled   = $true
                    $RelayProtocolComboBox.enabled       = $false

                    $RelayComputerNameLabel.text = "IP/Hostname to Delete port proxy:"
                }
            }
        }
    }
    $ManagePortProxyForm.Controls.Add($RelayActionComboBox)
    $RelayActionList = @('Show','Create','Delete')
    ForEach ($Action in $RelayActionList) { $RelayActionComboBox.Items.Add($Action) }
    $RelayActionComboBox.SelectedItem = 'Show'

    $RelayComputerNameLabel = New-Object System.Windows.Forms.Label -Property @{
        Text   = "IP/Hostname to Show port proxy:"
        Left   = $RelayActionLabel.Left
        Top    = $RelayActionLabel.Top + $RelayActionLabel.Height + ($FormScale + 5)
        Width  = $FormScale * 250
        Height = $FormScale * 22
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
    }
    $ManagePortProxyForm.Controls.Add($RelayComputerNameLabel)


    $RelayComputerNameComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Text   = ""
        Left   = $RelayComputerNameLabel.Left + $RelayComputerNameLabel.width + ($FormScale + 5)
        Top    = $RelayComputerNameLabel.Top
        Width  = $FormScale * 125
        Height = $FormScale * 22
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        Enabled = $true
    }
    $ManagePortProxyForm.Controls.Add($RelayComputerNameComboBox)
    ForEach ($Endpoint in $script:ComputerListAll) { $RelayComputerNameComboBox.Items.Add($Endpoint) }


    $RelayActionLabel = New-Object System.Windows.Forms.Label -Property @{
        Text   = "Proxy Relay Type:"
        Left   = $RelayComputerNameLabel.Left
        Top    = $RelayComputerNameLabel.Top + $RelayComputerNameLabel.Height + ($FormScale * 5)
        Width  = $FormScale * 250
        Height = $FormScale * 22
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        Add_Click = {
        }
    }
    $ManagePortProxyForm.Controls.Add($RelayActionLabel)


    $RelayTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Left   = $RelayActionLabel.Left + $RelayActionLabel.Width + ($FormScale + 5)
        Top    = $RelayActionLabel.Top
        Width  = $FormScale * 125
        Height = $FormScale * 22
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        Enabled = $false
    }
    $ManagePortProxyForm.Controls.Add($RelayTypeComboBox)
    $RelayTypeList = @('v4tov4','v6tov4','v4tov6','v6tov6')
    ForEach ($Type in $RelayTypeList) { $RelayTypeComboBox.Items.Add($Type) }
    $RelayTypeComboBox.SelectedItem = 'v4tov4'


    $RelayListenAddressLabel = New-Object System.Windows.Forms.Label -Property @{
        Text   = "Proxy Listening IP Address:"
        Left   = $RelayActionLabel.Left
        Top    = $RelayActionLabel.Top + $RelayActionLabel.Height + ($FormScale + 5)
        Width  = $FormScale * 250
        Height = $FormScale * 22
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
    }
    $ManagePortProxyForm.Controls.Add($RelayListenAddressLabel)


    $RelayListenAddressComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Left   = $RelayListenAddressLabel.Left + $RelayListenAddressLabel.width + ($FormScale + 5)
        Top    = $RelayListenAddressLabel.Top
        Width  = $FormScale * 125
        Height = $FormScale * 22
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        Enabled = $false
    }
    $ManagePortProxyForm.Controls.Add($RelayListenAddressComboBox)
    $RelayListenAddressList = @('0.0.0.0','127.0.0.1')
    ForEach ($Address in $RelayListenAddressList) { $RelayListenAddressComboBox.Items.Add($Address) }
    $RelayListenAddressComboBox.SelectedItem = '0.0.0.0'


    $RelayListenPortLabel = New-Object System.Windows.Forms.Label -Property @{
        Text   = "Proxy Listening Port:"
        Left   = $RelayListenAddressLabel.Left
        Top    = $RelayListenAddressLabel.Top + $RelayListenAddressLabel.Height + ($FormScale + 5)
        Width  = $FormScale * 250
        Height = $FormScale * 22
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
    }
    $ManagePortProxyForm.Controls.Add($RelayListenPortLabel)


    $RelayListenPortComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Left   = $RelayListenPortLabel.Left + $RelayListenPortLabel.width + ($FormScale + 5)
        Top    = $RelayListenPortLabel.Top
        Width  = $FormScale * 125
        Height = $FormScale * 22
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        Enabled = $false
    }
    $ManagePortProxyForm.Controls.Add($RelayListenPortComboBox)
    $RelayListenPortList = @('8000','8080','8888')
    ForEach ($Port in $RelayListenPortList) { $RelayListenPortComboBox.Items.Add($Port) }
    $RelayListenPortComboBox.SelectedItem = '8000'


    $RelayConnectAddressLabel = New-Object System.Windows.Forms.Label -Property @{
        Text   = "Destination IP/Hostname:"
        Left   = $RelayListenPortLabel.Left
        Top    = $RelayListenPortLabel.Top + $RelayListenPortLabel.Height + ($FormScale + 5)
        Width  = $FormScale * 250
        Height = $FormScale * 22
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
    }
    $ManagePortProxyForm.Controls.Add($RelayConnectAddressLabel)


    $RelayConnectAddressComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Left   = $RelayConnectAddressLabel.Left + $RelayConnectAddressLabel.width + ($FormScale + 5)
        Top    = $RelayConnectAddressLabel.Top
        Width  = $FormScale * 125
        Height = $FormScale * 22
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        Enabled = $false
    }
    $ManagePortProxyForm.Controls.Add($RelayConnectAddressComboBox)
    ForEach ($Address in $script:ComputerListAll) { $RelayConnectAddressComboBox.Items.Add($Address) }


    $RelayConnectPortLabel = New-Object System.Windows.Forms.Label -Property @{
        Text   = "Destination Port:"
        Left   = $RelayConnectAddressLabel.Left
        Top    = $RelayConnectAddressLabel.Top + $RelayConnectAddressLabel.Height + ($FormScale + 5)
        Width  = $FormScale * 250
        Height = $FormScale * 22
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
    }
    $ManagePortProxyForm.Controls.Add($RelayConnectPortLabel)


    $RelayConnectPortComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Left   = $RelayConnectPortLabel.Left + $RelayConnectPortLabel.width + ($FormScale + 5)
        Top    = $RelayConnectPortLabel.Top
        Width  = $FormScale * 125
        Height = $FormScale * 22
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        Enabled = $false
    }
    $ManagePortProxyForm.Controls.Add($RelayConnectPortComboBox)
    $RelayPortList = @('8000','8080','8888')
    ForEach ($Port in $RelayPortList) { $RelayConnectPortComboBox.Items.Add($Port) }


    $RelayProtocolLabel = New-Object System.Windows.Forms.Label -Property @{
        Text   = "Protocol (Only supports TCP):"
        Left   = $RelayConnectPortLabel.Left
        Top    = $RelayConnectPortLabel.Top + $RelayConnectPortLabel.Height + ($FormScale + 5)
        Width  = $FormScale * 250
        Height = $FormScale * 22
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
    }
    $ManagePortProxyForm.Controls.Add($RelayProtocolLabel)


    $RelayProtocolComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Text   = "TCP"
        Left   = $RelayProtocolLabel.Left + $RelayProtocolLabel.width + ($FormScale + 5)
        Top    = $RelayProtocolLabel.Top
        Width  = $FormScale * 125
        Height = $FormScale * 22
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        Enabled = $false
    }
    $ManagePortProxyForm.Controls.Add($RelayProtocolComboBox)
    $RelayProtocolList = @('TCP')
    ForEach ($Protocol in $RelayProtocolList) { $RelayProtocolComboBox.Items.Add($Protocol) }


    $RelayActionExecutionButton = New-Object System.Windows.Forms.Button -Property @{
        Text   = "Execution"
        Left   = $RelayProtocolComboBox.Left
        Top    = $RelayProtocolComboBox.Top + $RelayProtocolComboBox.Height + ($FormScale + 10)
        Width  = $FormScale * 125
        Height = $FormScale * 22
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        Add_Click = {
            switch ($RelayActionComboBox.SelectedItem) {
                'Show' {
                    Manage-WindowsRelay `
                    -Show `
                    -ComputerName   $RelayComputerNameComboBox.Text `
                    -Credential     $Script:Credential `
                    -UseCreds | Out-GridView -Title 'PoSh-EasyWin - Port Proxy'
                }
                'Create' {
                    Manage-WindowsRelay `
                    -RelayType      $RelayTypeComboBox.Text `
                    -ListenAddress  $RelayListenAddressComboBox.Text `
                    -ListenPort     $RelayListenPortComboBox.Text `
                    -ConnectAddress $RelayConnectAddressComboBox.Text `
                    -ConnectPort    $RelayConnectPortComboBox.Text `
                    -ComputerName   $RelayComputerNameComboBox.Text `
                    -Credential     $Script:Credential `
                    -UseCreds | Out-GridView -Title 'PoSh-EasyWin - Port Proxy'
                }
                'Delete' {
                    Manage-WindowsRelay `
                    -Delete `
                    -RelayType      $RelayTypeComboBox.Text `
                    -ListenAddress  $RelayListenAddressComboBox.Text `
                    -ListenPort     $RelayListenPortComboBox.Text `
                    -ComputerName   $RelayComputerNameComboBox.Text `
                    -Credential     $Script:Credential `
                    -UseCreds | Out-GridView -Title 'PoSh-EasyWin - Port Proxy'
                }
            }
        }
    }
    $ManagePortProxyForm.Controls.Add($RelayActionExecutionButton)
    Add-CommonButtonSettings -Button $RelayActionExecutionButton


    $ManagePortProxyStatusBar = New-Object System.Windows.Forms.StatusBar
    $ManagePortProxyStatusBar.Text = "Ready"
    $ManagePortProxyForm.Controls.Add($ManagePortProxyStatusBar)


    $ManagePortProxyForm.ResumeLayout()
    $ManagePortProxyForm.ShowDialog()
}




Update-FormProgress "Show-FileShareConnection"
Function Show-FileShareConnection {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Windows.Drawing

    $SmbFileShareServerForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = "PoSh-EasyWin - File Share Connection"
        Width  = $FormScale * 540
        Height = $FormScale * 300
        StartPosition = "CenterScreen"
        Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoScroll    = $True
        #FormBorderStyle =  "fixed3d"
        #ControlBox    = $false
        MaximizeBox   = $false
        MinimizeBox   = $false
        ShowIcon      = $true
        TopMost       = $false
        Add_Shown     = $null
        Add_load = {
            if (Test-Path "$PewSettings\SMB File Share Hostname IP.txt")    {$script:SmbFileShareServerHostnameIPTextbox.Text = Get-Content "$PewSettings\SMB File Share Hostname IP.txt"}
            if (Test-Path "$PewSettings\SMB File Share File Path.txt")      {$SmbFileShareServerFilePathTextbox.Text      = Get-Content "$PewSettings\SMB File Share File Path.txt"}
            if (Test-Path "$PewSettings\SMB File Share Server Name.txt")    {$SmbFileShareServerFileShareNameTextbox.Text = Get-Content "$PewSettings\SMB File Share Server Name.txt"}
            if (Test-Path "$PewSettings\SMB File Share Drive Letter.txt")   {$SmbFileShareServerDriveLetterTextbox.Text   = Get-Content "$PewSettings\SMB File Share Drive Letter.txt"}
            if (Test-Path "$PewSettings\SMB File Share Account Access.txt") {$SmbFileShareServerAccountAccessTextbox.Text = Get-Content "$PewSettings\SMB File Share Account Access.txt"}
            if (Test-Path "$PewSettings\SMB File Share Access Rights.txt")  {$SmbFileShareServerAccessRightsTextbox.Text  = Get-Content "$PewSettings\SMB File Share Access Rights.txt"}
        }
        Add_Closing = {
            if (Get-SmbMapping -LocalPath "$($script:SmbShareDriveLetter):") {
                $SaveResultsToFileShareCheckbox.Checked = $true
                $script:CollectionSavedDirectoryTextBox.Text = "$($script:SmbShareDriveLetter):\$((Get-Date).ToString('yyyy-MM-dd HH.mm.ss'))"

                if ($SaveResultsToFileShareCheckbox.checked) { $DirectoryListLabel.Text = "Results Folder on SMB File Share ($script:SMBServer):" }
            }
            else {
                $SaveResultsToFileShareCheckbox.Checked = $false
                if (-not $SaveResultsToFileShareCheckbox.checked) { $DirectoryListLabel.Text = "Results Folder on localhost ($env:COMPUTERNAME):" }
            }
            $This.dispose()
        }
    }


    $SmbFileShareServerLabel = New-Object System.Windows.Forms.label -Property @{
        Text   = "PoSh-EasyWin can store collected data to the localhost's filesystem or to a networked SMB file Share. Elevated permissions are required to create and connect to the SMB file share. This section allows you to specify a file path on a host that you have permissions to and create and/or connect to an SMB file share."
        Left   = $FormScale * 10
        Top    = $FormScale * 10
        Width  = $FormScale * 510
        Height = $FormScale * 60
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $SmbFileShareServerForm.Controls.Add($SmbFileShareServerLabel)


    $SmbFileShareServerConfigurationGroupbox = New-Object System.Windows.Forms.Groupbox -Property @{
        Text   = "SMB File Share Configuration"
        Left   = $SmbFileShareServerLabel.Left
        Top    = $SmbFileShareServerLabel.Top + $SmbFileShareServerLabel.Height + $($FormScale * 5)
        Width  = $FormScale * 510
        Height = $FormScale * 170
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = 'Blue'
    }
    $SmbFileShareServerForm.Controls.Add($SmbFileShareServerConfigurationGroupbox)


        $SmbFileShareServerHostnameIPLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Server Hostname/IP:"
            Left   = $FormScale * 10
            Top    = $FormScale * 25
            Width  = $FormScale * 120
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $SmbFileShareServerConfigurationGroupbox.Controls.Add($SmbFileShareServerHostnameIPLabel)

            $script:SmbFileShareServerHostnameIPTextbox = New-Object System.Windows.Forms.Textbox -Property @{
                Text   = "localhost"
                Left   = $SmbFileShareServerHostnameIPLabel.Left + $SmbFileShareServerHostnameIPLabel.Width + $($FormScale * 5)
                Top    = $SmbFileShareServerHostnameIPLabel.Top
                Width  = $FormScale * 360
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            }
            $SmbFileShareServerConfigurationGroupbox.Controls.Add($script:SmbFileShareServerHostnameIPTextbox)


        $SmbFileShareServerFilePathLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Remote File Path:"
            Left   = $SmbFileShareServerHostnameIPLabel.Left
            Top    = $SmbFileShareServerHostnameIPLabel.Top + $SmbFileShareServerHostnameIPLabel.Height + $($FormScale * 5)
            Width  = $FormScale * 120
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $SmbFileShareServerConfigurationGroupbox.Controls.Add($SmbFileShareServerFilePathLabel)

            $SmbFileShareServerFilePathTextbox = New-Object System.Windows.Forms.Textbox -Property @{
                Text   = "C:\Windows\Temp\PoSh-EasyWin Collected Data\"
                Left   = $SmbFileShareServerFilePathLabel.Left + $SmbFileShareServerFilePathLabel.Width + $($FormScale * 5)
                Top    = $SmbFileShareServerFilePathLabel.Top
                Width  = $FormScale * 360
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            }
            $SmbFileShareServerConfigurationGroupbox.Controls.Add($SmbFileShareServerFilePathTextbox)


        $SmbFileShareServerFileShareNameLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Remote Share Name:"
            Left   = $SmbFileShareServerFilePathLabel.Left
            Top    = $SmbFileShareServerFilePathLabel.Top + $SmbFileShareServerFilePathLabel.Height + $($FormScale * 5)
            Width  = $FormScale * 120
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $SmbFileShareServerConfigurationGroupbox.Controls.Add($SmbFileShareServerFileShareNameLabel)

            $SmbFileShareServerFileShareNameTextbox = New-Object System.Windows.Forms.Textbox -Property @{
                Text   = 'PoSh-EasyWin'
                Left   = $SmbFileShareServerFileShareNameLabel.Left + $SmbFileShareServerFileShareNameLabel.Width + $($FormScale * 5)
                Top    = $SmbFileShareServerFileShareNameLabel.Top
                Width  = $FormScale * 120
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            }
            $SmbFileShareServerConfigurationGroupbox.Controls.Add($SmbFileShareServerFileShareNameTextbox)


        $SmbFileShareServerDriveLetterLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Local Drive Letter:"
            Left   = $SmbFileShareServerFileShareNameTextbox.Left + $SmbFileShareServerFileShareNameTextbox.Width + $($FormScale * 5)
            Top    = $SmbFileShareServerFileShareNameTextbox.Top
            Width  = $FormScale * 115
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $SmbFileShareServerConfigurationGroupbox.Controls.Add($SmbFileShareServerDriveLetterLabel)

            $SmbFileShareServerDriveLetterTextbox = New-Object System.Windows.Forms.Textbox -Property @{
                Text   = "P"
                Left   = $SmbFileShareServerDriveLetterLabel.Left + $SmbFileShareServerDriveLetterLabel.Width
                Top    = $SmbFileShareServerDriveLetterLabel.Top
                Width  = $FormScale * 120
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            }
            $SmbFileShareServerConfigurationGroupbox.Controls.Add($SmbFileShareServerDriveLetterTextbox)


        $SmbFileShareServerAccountAccessLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Account Access:"
            Left   = $SmbFileShareServerFileShareNameLabel.Left
            Top    = $SmbFileShareServerFileShareNameLabel.Top + $SmbFileShareServerFileShareNameLabel.Height + $($FormScale * 5)
            Width  = $FormScale * 120
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $SmbFileShareServerConfigurationGroupbox.Controls.Add($SmbFileShareServerAccountAccessLabel)

            $SmbFileShareServerAccountAccessTextbox = New-Object System.Windows.Forms.Textbox -Property @{
                Text   = 'Everyone'
                Left   = $SmbFileShareServerAccountAccessLabel.Left + $SmbFileShareServerAccountAccessLabel.Width + $($FormScale * 5)
                Top    = $SmbFileShareServerAccountAccessLabel.Top
                Width  = $FormScale * 120
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            }
            $SmbFileShareServerConfigurationGroupbox.Controls.Add($SmbFileShareServerAccountAccessTextbox)


        $SmbFileShareServerAccessRightsLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Access Rigths:"
            Left   = $SmbFileShareServerAccountAccessTextbox.Left + $SmbFileShareServerAccountAccessTextbox.Width + $($FormScale * 5)
            Top    = $SmbFileShareServerAccountAccessTextbox.Top
            Width  = $FormScale * 115
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $SmbFileShareServerConfigurationGroupbox.Controls.Add($SmbFileShareServerAccessRightsLabel)

            $SmbFileShareServerAccessRightsTextbox = New-Object System.Windows.Forms.ComboBox -Property @{
                Text   = "Full"
                Left   = $SmbFileShareServerAccessRightsLabel.Left + $SmbFileShareServerAccessRightsLabel.Width
                Top    = $SmbFileShareServerAccessRightsLabel.Top
                Width  = $FormScale * 120
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            }
            $SmbFileShareServerConfigurationGroupbox.Controls.Add($SmbFileShareServerAccessRightsTextbox)
            $SmbFileShareServerAccessRightsList = @('Full','Read','Change')
            ForEach ($Item in $SmbFileShareServerAccessRightsList) { $SmbFileShareServerAccessRightsTextbox.Items.Add($Item) }


    $SmbFileShareServerFilterListSelectionAddButton = New-Object System.Windows.Forms.Button -Property @{
        Text   = 'Connect To SMB Share'
        Left   = $SmbFileShareServerAccountAccessLabel.Left
        Top    = $SmbFileShareServerAccountAccessLabel.Top + $SmbFileShareServerAccountAccessLabel.Height + $($FormScale * 5)
        Width  = $FormScale * 155
        Height = $FormScale * 22
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = 'Black'
        Add_Click = {
            $script:SmbFileShareServerHostnameIPTextbox.Text    | Set-Content "$PewSettings\SMB File Share Hostname IP.txt" -Force
            $SmbFileShareServerFilePathTextbox.Text      | Set-Content "$PewSettings\SMB File Share File Path.txt" -Force
            $SmbFileShareServerFileShareNameTextbox.Text | Set-Content "$PewSettings\SMB File Share Server Name.txt" -Force
            $SmbFileShareServerDriveLetterTextbox.Text   | Set-Content "$PewSettings\SMB File Share Drive Letter.txt" -Force
            $SmbFileShareServerAccountAccessTextbox.Text | Set-Content "$PewSettings\SMB File Share Account Access.txt" -Force
            $SmbFileShareServerAccessRightsTextbox.Text  | Set-Content "$PewSettings\SMB File Share Access Rights.txt" -Force

            $script:FileShareName = $SmbFileShareServerFileShareNameTextbox.Text
            $FilePath = $SmbFileShareServerFilePathTextbox.Text
            $script:SMBServer = $script:SmbFileShareServerHostnameIPTextbox.Text
            $script:SmbShareDriveLetter = $SmbFileShareServerDriveLetterTextbox.Text
            $AccountAccess = $SmbFileShareServerAccountAccessTextbox.Text
            $AccountRights = $SmbFileShareServerAccessRightsTextbox.Text

            if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                if (-not $script:Credential) { Set-NewCredential }
            }

            $InvokeCommandSplat = @{
                ScriptBlock = {
                    param($FilePath,$script:FileShareName,$AccountAccess,$AccountRights)
                    if (-not (Get-PSDrive -Name $script:FileShareName -ErrorAction SilentlyContinue)) {
                        New-Item -Type Directory -Path $FilePath -ErrorAction SilentlyContinue
                        New-SmbShare -Path $FilePath -Name $script:FileShareName
                        Grant-SmbShareAccess -Name $script:FileShareName -AccountName $AccountAccess -AccessRight $AccountRights -Force
                    }
                }
                ArgumentList = @($FilePath,$script:FileShareName,$AccountAccess,$AccountRights)
                ComputerName = $script:SMBServer
                Credential   = $script:Credential
            }
            Invoke-Command @InvokeCommandSplat

            $NewSmbMappingSplat = @{
                LocalPath  = "$($script:SmbShareDriveLetter):"
                RemotePath = "\\$script:SMBServer\$script:FileShareName"
                Persistent = $true
                UserName   = $script:Credential.UserName
                Password   = $script:Credential.GetNetworkCredential().Password
            }
            New-SmbMapping @NewSmbMappingSplat
            net use P: \\hostname\PoSh-EasyWin /USER:user@domain.com 'password' /persistent:Yes

            if (Get-SmbMapping -LocalPath "$($script:SmbShareDriveLetter):") {
                $script:FileTransferStatusBar.Text = "SMB File Share Mapping Exists for: [$($script:SmbShareDriveLetter):] $((Get-SmbMapping).RemotePath)"
                Start-Sleep -Seconds 1
                $DirectoryListLabel.Text = "Results Folder on SMB File Share ($script:SMBServer):"
                $SmbFileShareServerForm.Close()
            }
            else {
                $DirectoryListLabel.Text = "Results Folder on localhost ($env:COMPUTERNAME):"
                $script:FileTransferStatusBar.Text = "SMB File Share Mapping to $script:SMBServer Failed..."
            }
        }
    }
    $SmbFileShareServerConfigurationGroupbox.Controls.Add($SmbFileShareServerFilterListSelectionAddButton)
    Add-CommonButtonSettings -Button $SmbFileShareServerFilterListSelectionAddButton


    $SmbFileShareServerShowSmbMappingsButton = New-Object System.Windows.Forms.Button -Property @{
        Text   = 'Show SMB Mappings'
        Left   = $SmbFileShareServerFilterListSelectionAddButton.Left + $SmbFileShareServerFilterListSelectionAddButton.Width + $($FormScale * 5)
        Top    = $SmbFileShareServerFilterListSelectionAddButton.Top
        Width  = $FormScale * 155
        Height = $FormScale * 22
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = 'Black'
        Add_Click = {
            Get-SmbMapping | Out-GridView -Title '[localhost] SMB Mappings'

            $InvokeCommandSplat = @{
                ScriptBlock = {
                    $Shares = Get-SmbShare
                    Foreach ($Share in $Shares) {
                        $Rights = Get-SmbShareAccess -Name $Share.Name
                        $Share `
                        | Add-Member -MemberType NoteProperty -Name AccountName -Value "$($Rights.AccountName)" -Force -PassThru `
                        | Add-Member -MemberType NoteProperty -Name AccessRight -Value "$($Rights.AccessRight)" -Force -PassThru `
                        | Add-Member -MemberType NoteProperty -Name AccessControlType -Value "$($Rights.AccessControlType)" -Force -PassThru `
                        | Add-Member -MemberType NoteProperty -Name ScopeName -Value "$($Rights.ScopeName)" -Force -PassThru `
                        | Select-Object -Property @{n='ComputerName';e={$env:COMPUTERNAME}}, Name, Path, Description, AccountName, AccessRight, AccessControlType, ScopeName
                    }
                }
                ComputerName = $script:SmbFileShareServerHostnameIPTextbox.text
            }

            if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { Set-NewCredential }
                $InvokeCommandSplat += @{ Credential = $script:Credential }
            }

            Invoke-Command @InvokeCommandSplat | Out-GridView -Title "[$($script:SmbFileShareServerHostnameIPTextbox.text)] SMB Server Mappings & Permissions"
        }
    }
    $SmbFileShareServerConfigurationGroupbox.Controls.Add($SmbFileShareServerShowSmbMappingsButton)
    Add-CommonButtonSettings -Button $SmbFileShareServerShowSmbMappingsButton


    $SmbFileShareServerRemoveSmbMappingsButton = New-Object System.Windows.Forms.Button -Property @{
        Text   = 'Remove SMB Mappings'
        Left   = $SmbFileShareServerShowSmbMappingsButton.Left + $SmbFileShareServerShowSmbMappingsButton.Width + $($FormScale * 5)
        Top    = $SmbFileShareServerShowSmbMappingsButton.Top
        Width  = $FormScale * 155
        Height = $FormScale * 22
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = 'Black'
        Add_Click = { Get-SmbMapping | Out-GridView -Title '[localhost] SMB Mappings' -PassThru | Remove-SmbMapping -Force }
    }
    $SmbFileShareServerConfigurationGroupbox.Controls.Add($SmbFileShareServerRemoveSmbMappingsButton)
    Add-CommonButtonSettings -Button $SmbFileShareServerRemoveSmbMappingsButton


    $script:Timer = New-Object System.Windows.Forms.Timer -Property @{
        Enabled  = $true
        Interval = 1000
    }
    $script:Timer.Start()


    $script:FileTransferStatusBar = New-Object System.Windows.Forms.StatusBar


    # $UpdateStatusBar = {
    #     if ($true) { $script:FileTransferStatusBar.Text = Get-Date }
    #     else { $script:Timer.Stop() }
    # }
    # $script:Timer.add_Tick($UpdateStatusBar)
    # $SmbFileShareServerForm.Controls.Add($script:FileTransferStatusBar)
    if ($((Get-SmbMapping).count) -gt 0) {
        $script:FileTransferStatusBar.Text = "Number of SMB Shares Mapped: $((Get-SmbMapping).count)"
    }
    else {
        $script:FileTransferStatusBar.Text = "Number of SMB Shares Mapped: 0"
    }
    $SmbFileShareServerForm.Controls.Add($script:FileTransferStatusBar)

    $SmbFileShareServerForm.ShowDialog()
}



Update-FormProgress "OpNoteTextBoxEntry"
function OpNoteTextBoxEntry {
    # Adds Timestamp to Entered Text
    $OpNotesAdded = $OpNotesListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) $($OpNotesInputTextBox.Text)")

    Save-OpNotes

    # Adds all entries to the OpNotesWriteOnlyFile -- This file gets all entries and are not editable from the GUI
    # Useful for looking into accidentally deleted entries
    Add-Content -Path $OpNotesWriteOnlyFile -Value ("$($(Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) $($OpNotesInputTextBox.Text)") -Force

    $OpNotesInputTextBox.Text = ""
}















# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUfmk0FzRK9nbWdCwGjnz8UASf
# AC2gggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU3yXfCg3zUWuhp/6rfJwComQTVBQwDQYJKoZI
# hvcNAQEBBQAEggEAsrPhkJwGMzKmFa+ogzEeT4jB0j98gdT3iQ1YZD1PnrOjoDtR
# 0FPsP4WCB2USVIitBeY1EEbo1iAD692UnhgSesmfcmuJO6OaHbqwiH8GqmX5D6QR
# 5sNYIeVi0tq8xPB7iyB3a7PFj6/RZ6hevl/b2ES1hXERfJY+bBPTB0sTseVsXW6f
# s+4NWSTj5FYEJ8XGu3Ka+AavlFYz0hGrQoqGdtYO9OUlb34rc5rVUVVO9ttD1MCV
# +wkgtpzQwhR3og3692YJRWNZKvzlECzPS8TU/EbAeckzTZhSkkjM9eYi/A9TbmPc
# q08cQ5nt4rdG3jOANhzZJ4xtnLaLqDBM9VTPow==
# SIG # End signature block
