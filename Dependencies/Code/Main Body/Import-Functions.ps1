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

            Create-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message " - $CheckCommand"
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

    # # BUG: When the box is unchecked, the results don't compile correctly
    # if ($OptionKeepResultsByEndpointsFilesCheckBox.checked -eq $false) {
    #     if (Test-Path "$($script:CollectionSavedDirectoryTextBox.Text)\*\*.csv") {
    #         Remove-Item -Path "$($script:CollectionSavedDirectoryTextBox.Text)\*\*.csv" -Recurse -Force
    #     }
    # }
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

    # # BUG: When the box is unchecked, the results don't compile correctly
    # if ($OptionKeepResultsByEndpointsFilesCheckBox.checked -eq $false) {
    #     if (Test-Path "$($script:CollectionSavedDirectoryTextBox.Text)\*\*.xml") {
    #         Remove-Item -Path "$($script:CollectionSavedDirectoryTextBox.Text)\*" -Recurse -Force
    #     }
    # }
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

    #Create-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Compilied CSV and XML Files"
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
        Create-LogEntry -TargetComputer $TargetComputer  -LogFile $PewLogFile -Message $CollectionName


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
            #Create-LogEntry -LogFile $PewLogFile -TargetComputer $TargetComputer -Message "$EventLogQueryBuild"
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
            Create-LogEntry -TargetComputer $TargetComputer  -LogFile $PewLogFile -Message $CollectionName


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
            Create-LogEntry -TargetComputer $TargetComputer  -LogFile $PewLogFile -Message $CollectionName


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
            Create-LogEntry -TargetComputer $TargetComputer  -LogFile $PewLogFile -Message $CollectionName


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
                            $UpdatedNotes = "$(Get-Date) [Executed] $CollectionName`n$($Computer.Notes)"
                            $Computer | Add-Member -MemberType NoteProperty -Name Notes -Value $UpdatedNotes -Force
                        }
                    }
                }
            }
        }
        Save-TreeViewData -Endpoint -SkipTextFieldSave
    }
}

