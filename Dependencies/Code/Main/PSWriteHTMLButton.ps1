$PSWriteHTMLButtonAdd_Click = {


Update-FormProgress "$PSWriteHTMLDirectory\Invoke-PSWriteHTMLEndpointSnapshot.ps1"
. "$PSWriteHTMLDirectory\Invoke-PSWriteHTMLEndpointSnapshot.ps1"

Update-FormProgress "$PSWriteHTMLDirectory\EndpointDataSystemSnapshotScriptBlock.ps1"
. "$PSWriteHTMLDirectory\EndpointDataSystemSnapshotScriptBlock.ps1"

Update-FormProgress "$PSWriteHTMLDirectory\Invoke-PSWriteHTMLProcess.ps1"
. "$PSWriteHTMLDirectory\Invoke-PSWriteHTMLProcess.ps1"

Update-FormProgress "$PSWriteHTMLDirectory\ProcessesScriptblock.ps1"
. "$PSWriteHTMLDirectory\ProcessesScriptblock.ps1"

Update-FormProgress "$PSWriteHTMLDirectory\Launch-NetworkConnectionGUI.ps1"
. "$PSWriteHTMLDirectory\Launch-NetworkConnectionGUI.ps1"

Update-FormProgress "$PSWriteHTMLDirectory\Invoke-PSWriteHTMLNetworkConnections.ps1"
. "$PSWriteHTMLDirectory\Invoke-PSWriteHTMLNetworkConnections.ps1"

Update-FormProgress "$PSWriteHTMLDirectory\NetworkConnectionsScriptBlock.ps1"
. "$PSWriteHTMLDirectory\NetworkConnectionsScriptBlock.ps1"

Update-FormProgress "$PSWriteHTMLDirectory\Invoke-PSWriteHTMLProcessAndNetwork.ps1"
. "$PSWriteHTMLDirectory\Invoke-PSWriteHTMLProcessAndNetwork.ps1"

Update-FormProgress "$PSWriteHTMLDirectory\ProcessAndNetworkScriptBlock.ps1"
. "$PSWriteHTMLDirectory\ProcessAndNetworkScriptBlock.ps1"

Update-FormProgress "$PSWriteHTMLDirectory\Invoke-PSWriteHTMLConsoleLogons.ps1"
. "$PSWriteHTMLDirectory\Invoke-PSWriteHTMLConsoleLogons.ps1"

Update-FormProgress "$PSWriteHTMLDirectory\ConsoleLogonsScriptBlock.ps1"
. "$PSWriteHTMLDirectory\ConsoleLogonsScriptBlock.ps1"

Update-FormProgress "$PSWriteHTMLDirectory\Invoke-PSWriteHTMLPowerShellSessions.ps1"
. "$PSWriteHTMLDirectory\Invoke-PSWriteHTMLPowerShellSessions.ps1"

Update-FormProgress "$PSWriteHTMLDirectory\PowerShellSessionsScriptBlock.ps1"
. "$PSWriteHTMLDirectory\PowerShellSessionsScriptBlock.ps1"

Update-FormProgress "$PSWriteHTMLDirectory\Invoke-PSWriteHTMLLogonActivity.ps1"
. "$PSWriteHTMLDirectory\Invoke-PSWriteHTMLLogonActivity.ps1"

Update-FormProgress "$PSWriteHTMLDirectory\LogonActivityScriptblock.ps1"
. "$PSWriteHTMLDirectory\LogonActivityScriptblock.ps1"


$InformationTabControl.SelectedTab = $Section3MonitorJobsTab

$DateTime = (Get-Date).ToString('yyyy-MM-dd HH.mm.ss')

function Create-PSWriteHTMLSaveName {
    param(
        $CollectionName,
        $DateTime
    )
    if ($ResultsFolderAutoTimestampCheckbox.Checked -eq $true -and $SaveResultsToFileShareCheckbox.Checked -eq $false) {
        $CollectedDataTimeStamp = "$PewCollectedData\$DateTime"
        $script:CollectionSavedDirectoryTextBox.Text = $CollectedDataTimeStamp
        $script:PSWriteHTMLFilePath = "$($script:CollectionSavedDirectoryTextBox.Text)\$CollectionName (Browser) $DateTime.html"
    }
    elseif ($ResultsFolderAutoTimestampCheckbox.Checked -eq $true -and $SaveResultsToFileShareCheckbox.Checked -eq $true) {
        $script:CollectionSavedDirectoryTextBox.Text = "$($script:SmbShareDriveLetter):\$((Get-Date).ToString('yyyy-MM-dd HH.mm.ss'))"
        $script:PSWriteHTMLFilePath = "$($script:CollectionSavedDirectoryTextBox.Text)\$CollectionName (Browser) $DateTime.html"
    }
    return $script:PSWriteHTMLFilePath
}

function script:Generate-TablePieBarCharts {
    param(
        $Title,
        $Data
    )
    New-HTMLSection -HeaderText "$Title" -Height 725 -HeaderTextSize 15 -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
        $DataTableID = Get-Random -Minimum 100000 -Maximum 2000000
        New-HTMLPanel -Width 50% {
            New-HTMLTable -DataTable ($Data `
                | Select-Object Name, Count, `
                @{n='PSComputerName';e={($_.Group.PSComputerName | Sort-Object -Unique) -join ', '}} ) `
                -DataTableID $DataTableID
        }
        New-HTMLPanel -Width 50% {
            New-HTMLSection -Invisible {
                New-HTMLChart -Title 'Top 10' -Gradient -TitleAlignment left {
                    New-ChartLegend -HideLegend
                    Foreach ($_ in ($Data | Select-Object -First 10)){
                        New-ChartPie -Name $_.Name -Value $_.Count
                    }
                    New-ChartEvent -DataTableID $DataTableID -ColumnID 0
                }
            }
            New-HTMLSection -Invisible {
                New-HTMLChart -Title 'Botom 10' -Gradient -TitleAlignment left {
                    New-ChartLegend -HideLegend
                    Foreach ($_ in ($Data | Select-Object -Last 10)){
                        New-ChartPie -Name $_.Name -Value $_.Count
                    }
                    New-ChartEvent -DataTableID $DataTableID -ColumnID 0
                }
            }
        }
        New-HTMLPanel {
            New-HTMLChart -Title "$Title" -Gradient -TitleAlignment left {
                New-ChartLegend -HideLegend
                Foreach ($_ in $Data){
                    New-ChartBar -Name $_.Name -Value $_.Count
                }
                New-ChartEvent -DataTableID $DataTableID -ColumnID 0
            }
        }
    }
}

####################################################################################################
####################################################################################################
##                                                                                                ##
##  PSWriteHTML Query Selection Form                                                              ##
##                                                                                                ##
####################################################################################################
####################################################################################################
$PSWriteHTMLForm = New-Object System.Windows.Forms.Form -Property @{
    Text            = "Graph Data Selection"
    StartPosition   = "CenterScreen"
    Width           = $FormScale * 350
    Height          = $FormScale * 294
    Icon            = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
    FormBorderStyle = 'Sizable' #  Fixed3D, FixedDialog, FixedSingle, FixedToolWindow, None, Sizable, SizableToolWindow
    ShowIcon        = $true
    showintaskbar   = $false
    ControlBox      = $true
    MaximizeBox     = $false
    MinimizeBox     = $true
    AutoScroll      = $True
    Add_Load        = {}
    Add_Closing     = {$This.dispose()}
}


$script:PSWriteHTMLIndividualWebPagesCheckbox = New-Object -TypeName System.Windows.Forms.CheckBox -Property @{
    Text    = "Display Results In Individual Browser Tabs"
    Left    = $FormScale * 5
    Top     = $FormScale * 5
    Width   = $FormScale * 270
    Height  = $FormScale * 22
    Font    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Checked = $true
    Add_click = {
        if ( $this.checked ) {
            [System.Windows.Forms.MessageBox]::Show("Switching to Monitor Jobs mode. Data will be collected separately as jobs. Results will be displayed in multiple browser tabs.",'PoSh-EasyWin - Individual Tabs','Ok',"Info")
            $script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem = 'Monitor Jobs'
        }
    }
}
$PSWriteHTMLForm.Controls.Add($script:PSWriteHTMLIndividualWebPagesCheckbox)
if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
    $script:PSWriteHTMLIndividualWebPagesCheckbox.enabled = $true
}


$PSWriteHTMLCheckedListBox = New-Object -TypeName System.Windows.Forms.CheckedListBox -Property @{
    Text   = "Select Data to Collect"
    Left   = $script:PSWriteHTMLIndividualWebPagesCheckbox.Left
    Top    = $script:PSWriteHTMLIndividualWebPagesCheckbox.Top + $script:PSWriteHTMLIndividualWebPagesCheckbox.Height + ($FormScale * 5)
    Width  = $script:PSWriteHTMLIndividualWebPagesCheckbox.Width
    Height = $FormScale * 150
    ScrollAlwaysVisible = $true
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click = {}
}
$PSWriteHTMLCheckedBoxList = @(
    'Active Directory Computers',
    'Active Directory Users',
    'Endpoint Process Data',
    'Endpoint Network Connections',
    'Endpoint Process and Network',
    'Endpoint Console Logons',
    'Endpoint PowerShell Sessions',
    'Endpoint Logon Activity (30 Days)',
    'Endpoint Data Deep Dive'
)

#    'Endpoint CPU Data',
#    'Endpoint RAM Data',
#    'Endpoint SMB Shares',
#    'Endpoint Storage Data',

foreach ( $Query in $PSWriteHTMLCheckedBoxList ) { $PSWriteHTMLCheckedListBox.Items.Add($Query) }
$PSWriteHTMLForm.Controls.Add($PSWriteHTMLCheckedListBox)


$script:PSWriteHTMLFormOkay = $false
$PSWriteHTMLGraphDataButton = New-Object -TypeName System.Windows.Forms.Button -Property @{
    Text   = "Collect and Graph Data"
    Left   = $FormScale * 5
    Top    = $PSWriteHTMLCheckedListBox.Top + $PSWriteHTMLCheckedListBox.Height + $($FormScale * 5)
    Width  = $FormScale * 150
    Height = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click = {
        if ($script:PSWriteHTMLIndividualWebPagesCheckbox.checked) {
            $script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem = 'Monitor Jobs'
        }

        if ($PSWriteHTMLCheckedListBox.CheckedItems.Count -ge 1) {
            Generate-ComputerList
                $script:PSWriteHTMLFormOkay = $false
            if ($script:ComputerList.count -ne 1 -and $PSWriteHTMLCheckedListBox.CheckedItems -Contains 'Endpoint Data Deep Dive') {
                [System.Windows.Forms.MessageBox]::Show("Endpoint Data Deep Dive can only be ran against one endpoint at a time.`n`nEnsure to checkbox only one endpoint.",'PoSh-EasyWin')
            }
            elseif ($script:ComputerList.count -ge 1) {
                $script:PSWriteHTMLFormOkay = $true
                $PSWriteHTMLForm.Close()
            }
            else {
                [System.Windows.Forms.MessageBox]::Show("Checkbox at least one endpoint from the computer treeview.",'PoSh-EasyWin')
            }
        }
        else {
            [System.Windows.Forms.MessageBox]::Show("Checkbox one option from the list to collect data.",'PoSh-EasyWin')
        }
    }
}
$PSWriteHTMLForm.Controls.Add($PSWriteHTMLGraphDataButton)
Add-CommonButtonSettings -Button $PSWriteHTMLGraphDataButton

$PSWriteHTMLForm.Showdialog()



if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -eq 1 -and $PSWriteHTMLCheckedListBox.CheckedItems -Contains 'Endpoint Data Deep Dive') {
                        $PSWriteHTMLSelectCommandsForm = New-Object System.Windows.Forms.Form -Property @{
                            Text            = "Select Data to Collect"
                            StartPosition   = "CenterScreen"
                            Width           = $FormScale * 350
                            Height          = $FormScale * 294
                            Icon            = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
                            FormBorderStyle = 'Sizable'
                            ShowIcon        = $true
                            showintaskbar   = $false
                            ControlBox      = $true
                            MaximizeBox     = $false
                            MinimizeBox     = $true
                            AutoScroll      = $True
                            Add_Load        = {}
                            Add_Closing     = {$This.dispose()}
                        }


                        $script:PSWriteHTMLSelectCommandsCheckedListBox = New-Object -TypeName System.Windows.Forms.CheckedListBox -Property @{
                            Text   = "Select Data to Collect"
                            Left   = $FormScale * 5
                            Top    = $FormScale * 5
                            Width  = $FormScale * 270
                            Height = $FormScale * 150
                            ScrollAlwaysVisible = $true
                            Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                            Add_Click = {}
                        }
                        $PSWriteHTMLSelectCommandsCheckedBoxList = @(
                            'System Info',
                            'Hardware',
                            'Security',
                            'Accounts',
                            'Network',
                            'Processes',
                            'Services',
                            'Event Logs',
                            'Software',
                            'Shares',
                            'Startup',
                            'PowerShell',
                            'Virtualization',
                            'SRUM Database (Must also Network or Software)'
                            # 'Active User Sessions',
                            # 'Antivirus Products',
                            # 'Audit Options',
                            # 'auditpol',
                            # 'BIOS',
                            # 'Computer Info',
                            # 'Computer Restore Points',
                            # 'Confirm Secure Boot UEFI',
                            # 'Crashed Applications',
                            # 'Disks',
                            # 'DNS Cache',
                            # 'Driver Details',
                            # 'Environmental Variables',
                            # 'Event Logs - Application (Last 1000)',
                            # 'Event Logs - Login Event Details (Past 30 Days)',
                            # 'Event Logs - Security (Last 1000)',
                            # 'Event Logs - System (Last 1000)',
                            # 'EventLog List',
                            # 'Failed Logins (Past 30 Days)',
                            # 'Firewall Profiles',
                            # 'Firewall Rules',
                            # 'Functions',
                            # 'Hosts File',
                            # 'Hyper-V Status',
                            # 'Hyper-V VM Network Adapters',
                            # 'Hyper-V VM Network Adapters',
                            # 'Hyper-V VM Snapshots',
                            # 'Hyper-V VMs',
                            # 'IP Configuration',
                            # 'Local Group Administrators',
                            # 'Local Groups',
                            # 'Local Users',
                            # 'Logical Disks',
                            # 'Memory Performance',
                            # 'Motherboard',
                            # 'Mp Computer Status',
                            # 'Mp Preferences',
                            # 'Mp Threat',
                            # 'Mp Threat Detection',
                            # 'Network Login Information',
                            # 'Network TCP Connections',
                            # 'Network UDP Endpoints',
                            # 'Non-Local Groups',
                            # 'Non-Local Users',
                            # 'Physical Memory',
                            # 'PNP Devices',
                            # 'Port Proxy',
                            # 'PowerShell Command History',
                            # 'PowerShell Commands',
                            # 'Powershell Modules Available',
                            # 'Powershell Modules Installed',
                            # 'PowerShell Profile (All Users All Hosts)',
                            # 'PowerShell Profile (All Users Current Host)',
                            # 'PowerShell Profile (Current User All Hosts)',
                            # 'PowerShell Profile (Current User Current Host)',
                            # 'PowerShell Sessions',
                            # 'PowerShell Sessions',
                            # 'PowerShell Version',
                            # 'Prefetch',
                            # 'Printers',
                            # 'Processes',
                            # 'Processor (CPU)',
                            # 'Product Info',
                            # 'PSDrives',
                            # 'Scheduled Jobs',
                            # 'Scheduled Tasks',
                            # 'schtasks',
                            # 'Secure Boot Policy',
                            # 'Security HotFixes',
                            # 'Services',
                            # 'Set Variables',
                            # 'SMB Connections',
                            # 'SMB Mappings',
                            # 'SMB Open Files',
                            # 'SMB Sessions',
                            # 'SMB Share Access',
                            # 'SMB Shares',
                            # 'Software (Registry)',
                            # 'SRUM Application Timeline',
                            # 'SRUM Application Usage',
                            # 'SRUM Network Connectivity',
                            # 'SRUM Network Data Usage',
                            # 'SRUM Push Notifications',
                            # 'Startup Commands',
                            # 'Startup Commands (Registry)',
                            # 'Successful Logins (Past 30 Days)',
                            # 'System DateTimes',
                            # 'System Drivers',
                            # 'USB Controllers & Devices',
                            # 'USB History',
                            # 'VMWare Detected',
                            # 'Windows Optional Features',
                            # 'WinEvent LogList',
                            # 'WinRM Status',
                            # 'Wireless Networks',
                            # 'WSMan TrustedHosts'
                        )

                        foreach ( $Option in $PSWriteHTMLSelectCommandsCheckedBoxList ) { $script:PSWriteHTMLSelectCommandsCheckedListBox.Items.Add($Option) }
                        $PSWriteHTMLSelectCommandsForm.Controls.Add($script:PSWriteHTMLSelectCommandsCheckedListBox)


                        $PSWriteHTMLGraphDataButton = New-Object -TypeName System.Windows.Forms.Button -Property @{
                            Text   = "Execute Collection"
                            Left   = $FormScale * 5
                            Top    = $script:PSWriteHTMLSelectCommandsCheckedListBox.Top + $script:PSWriteHTMLSelectCommandsCheckedListBox.Height + $($FormScale * 5)
                            Width  = $FormScale * 150
                            Height = $FormScale * 22
                            Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                            Add_Click = { $PSWriteHTMLSelectCommandsForm.Close() }
                        }
                        $PSWriteHTMLSelectCommandsForm.Controls.Add($PSWriteHTMLGraphDataButton)
                        Add-CommonButtonSettings -Button $PSWriteHTMLGraphDataButton

                        $PSWriteHTMLSelectCommandsForm.Showdialog()

                        #$script:PSWriteHTMLSelectCommandsCheckedListBox.CheckedItems

}



###########################################
###########################################
###########################################
###########################################
###########################################
###########################################
###########################################
###########################################
###########################################
###########################################
###########################################
###########################################
###########################################
###########################################
###########################################













function script:Individual-PSWriteHTML {
    param(
        $Title,
        $Data,
        $FilePath
    )
    New-HTML -TitleText $Title -FavIcon "$Dependencies\Images\favicon.jpg" -Online `
        -FilePath $FilePath {
            #-Show
        New-HTMLHeader {
            New-HTMLText -Text "Date of this report $(Get-Date)" -Color Blue -Alignment right

            New-HTMLLogo  -LeftLogoString "$Dependencies\Images\PoSh-EasyWin Image 01.png"
        }

        New-HTMLTabStyle -SlimTabs -Transition -LinearGradient -SelectorColor DarkBlue -SelectorColorTarget Blue -BorderRadius 25px -BorderBackgroundColor LightBlue

        Invoke-Command $Data

        New-HTMLFooter {
            New-HTMLText `
                -FontSize 12 `
                -FontFamily 'Source Sans Pro' `
                -Color Black `
                -Text 'Disclaimer: The information provided by PoSh-EasyWin is for general information purposes only. All data collected And represented is provided and done so in good faith, however we make no representation, guarentee, or warranty of any kind, expressed or implied, regarding the accuracy, adequacy, validity, reliability, availability, or completeness of any infomration collected or represented.'
            New-HTMLText `
                -Text "https://www.GitHub.com/high101bro/PoSh-EasyWin" `
                -Color Blue `
                -Alignment right
        }
    }
}





















###########################################
###########################################
###########################################
###########################################
###########################################
###########################################
###########################################
###########################################
###########################################
###########################################
###########################################
###########################################
###########################################
###########################################
###########################################















####################################################################################################
####################################################################################################
##                                                                                                ##
##  Endpoint Data Collection                                                                      ##
##                                                                                                ##
####################################################################################################
####################################################################################################

if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedListBox.CheckedItems -match 'Endpoint') {

    if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Individual Exeuction")
    }
}


if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedListBox.CheckedItems.count -gt 0) {
    $script:ProgressBarEndpointsProgressBar.Maximum = $script:ComputerList.count
    $script:ProgressBarEndpointsProgressBar.Value = 0
    $script:ProgressBarEndpointsProgressBar.Refresh()

    $script:ProgressBarQueriesProgressBar.Maximum = $PSWriteHTMLCheckedListBox.CheckedItems.count
    $script:ProgressBarQueriesProgressBar.Value = 0
    $script:ProgressBarQueriesProgressBar.Refresh()
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Using WinRM To Collect Data")
    Start-Sleep -Seconds 1
}































####################################################################################################
# Endpoint Data Deep Dive
####################################################################################################
if ($script:PSWriteHTMLFormOkay -eq $true -and $PSWriteHTMLCheckedListBox.CheckedItems -contains 'Endpoint Data Deep Dive') {
    $CollectionName = 'Endpoint Analysis'
    Create-PSWriteHTMLSaveName -CollectionName $CollectionName -DateTime $DateTime

    if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
        foreach ($TargetComputer in $script:ComputerList) {
            if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { Set-NewCredential }

                Invoke-Command -ScriptBlock $EndpointDataSystemSnapshotScriptBlock `
                -ComputerName $TargetComputer `
                -ArgumentList @($($script:PSWriteHTMLSelectCommandsCheckedListBox.CheckedItems),$null) `
                -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
                -Credential $script:Credential

                Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `$EndpointDataSystemSnapshotScriptBlock -ArgumentList `$script:PSWriteHTMLSelectCommandsCheckedListBox.CheckedItems -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)' -Credential `$script:Credential"
            }
            else {
                Invoke-Command -ScriptBlock $EndpointDataSystemSnapshotScriptBlock `
                -ComputerName $TargetComputer `
                -ArgumentList @($($script:PSWriteHTMLSelectCommandsCheckedListBox.CheckedItems),$null) `
                -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"

                Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `$EndpointDataSystemSnapshotScriptBlock -ArgumentList `$script:PSWriteHTMLSelectCommandsCheckedListBox.CheckedItems -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)'"
            }
        }
        Monitor-Jobs -CollectionName $CollectionName -MonitorMode -PSWriteHTMLSwitch -PSWriteHTML 'EndpointDataSystemSnapshot' -PSWriteHTMLFilePath $script:PSWriteHTMLFilePath -PSWriteHTMLOptions $script:PSWriteHTMLSelectCommandsCheckedListBox.CheckedItems -ComputerName $TargetComputer -xml
    }

    $script:ProgressBarQueriesProgressBar.Value += 1
    $script:ProgressBarQueriesProgressBar.Refresh()
}


####################################################################################################
# Process Data                                                                                     #
####################################################################################################
#batman
if ($script:PSWriteHTMLFormOkay -eq $true -and $PSWriteHTMLCheckedListBox.CheckedItems -contains 'Endpoint Process Data') {

    $CollectionName = 'Process Data'
    Create-PSWriteHTMLSaveName -CollectionName $CollectionName -DateTime $DateTime

    if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
        foreach ($TargetComputer in $script:ComputerList) {
            if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { Set-NewCredential }

                Invoke-Command -ScriptBlock $ProcessesScriptblock `
                -ComputerName $TargetComputer `
                -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
                -Credential $script:Credential

                Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `$ProcessesScriptblock -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)' -Credential `$script:Credential"
            }
            else {
                Invoke-Command -ScriptBlock $ProcessesScriptblock `
                -ComputerName $TargetComputer `
                -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"

                Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `$ProcessesScriptblock -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)'"
            }
        }
        Monitor-Jobs -CollectionName $CollectionName -MonitorMode -PSWriteHTMLSwitch -PSWriteHTML 'PSWriteHTMLProcesses' -PSWriteHTMLFilePath $script:PSWriteHTMLFilePath -ComputerName $TargetComputer
    }

    $script:ProgressBarQueriesProgressBar.Value += 1
    $script:ProgressBarQueriesProgressBar.Refresh()
}


####################################################################################################
# Network Connections                                                                              #
####################################################################################################
if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedListBox.CheckedItems -contains 'Endpoint Network Connections') {

    $CollectionName = 'Network Connections'
    Create-PSWriteHTMLSaveName -CollectionName $CollectionName -DateTime $DateTime

    if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
        foreach ($TargetComputer in $script:ComputerList) {
            if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { Set-NewCredential }

                Invoke-Command -ScriptBlock $NetworkConnectionsScriptBlock `
                -ComputerName $TargetComputer `
                -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
                -Credential $script:Credential

                Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `$NetworkConnectionsScriptBlock -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)' -Credential `$script:Credential"
            }
            else {
                Invoke-Command -ScriptBlock $NetworkConnectionsScriptBlock `
                -ComputerName $TargetComputer `
                -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"

                Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `$NetworkConnectionsScriptBlock -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)'"
            }
        }
        Monitor-Jobs -CollectionName $CollectionName -MonitorMode -PSWriteHTMLSwitch -PSWriteHTML 'EndpointDataNetworkConnections' -PSWriteHTMLFilePath $script:PSWriteHTMLFilePath -ComputerName $TargetComputer
    }

    $script:ProgressBarQueriesProgressBar.Value += 1
    $script:ProgressBarQueriesProgressBar.Refresh()
}



####################################################################################################
# Process and Network                                                                              #
####################################################################################################
if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedListBox.CheckedItems -contains 'Endpoint Process and Network') {

    $CollectionName = 'Endpoint Process and Network'
    Create-PSWriteHTMLSaveName -CollectionName $CollectionName -DateTime $DateTime

    if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
        foreach ($TargetComputer in $script:ComputerList) {
            if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { Set-NewCredential }

                Invoke-Command -ScriptBlock $ProcessAndNetworkScriptBlock `
                -ComputerName $TargetComputer `
                -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
                -Credential $script:Credential

                Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `$ProcessAndNetworkScriptBlock -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)' -Credential `$script:Credential"
            }
            else {
                Invoke-Command -ScriptBlock $ProcessAndNetworkScriptBlock `
                -ComputerName $TargetComputer `
                -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"

                Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `$ProcessAndNetworkScriptBlock -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)'"
            }
        }
        Monitor-Jobs -CollectionName $CollectionName -MonitorMode -PSWriteHTMLSwitch -PSWriteHTML 'EndpointProcessAndNetwork' -PSWriteHTMLFilePath $script:PSWriteHTMLFilePath -ComputerName $TargetComputer
    }

    $script:ProgressBarQueriesProgressBar.Value += 1
    $script:ProgressBarQueriesProgressBar.Refresh()
}




####################################################################################################
# Console Logons                                                                                   #
####################################################################################################
if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedListBox.CheckedItems -contains 'Endpoint Console Logons') {

    $CollectionName = 'Console Logons'
    Create-PSWriteHTMLSaveName -CollectionName $CollectionName -DateTime $DateTime

    if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
        foreach ($TargetComputer in $script:ComputerList) {
            if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { Set-NewCredential }

                Invoke-Command -ScriptBlock $ConsoleLogonsScriptBlock `
                -ComputerName $TargetComputer `
                -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
                -Credential $script:Credential

                Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `$ConsoleLogonsScriptBlock -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)' -Credential `$script:Credential"
            }
            else {
                Invoke-Command -ScriptBlock $ConsoleLogonsScriptBlock `
                -ComputerName $TargetComputer `
                -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"

                Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `$ConsoleLogonsScriptBlock -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)'"
            }
        }
        Monitor-Jobs -CollectionName $CollectionName -MonitorMode -PSWriteHTMLSwitch -PSWriteHTML 'EndpointDataConsoleLogons' -PSWriteHTMLFilePath $script:PSWriteHTMLFilePath -ComputerName $TargetComputer

    }

    $script:ProgressBarQueriesProgressBar.Value += 1
    $script:ProgressBarQueriesProgressBar.Refresh()
}


####################################################################################################
# PowerShell Sessions                                                                              #
####################################################################################################
if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedListBox.CheckedItems -contains 'Endpoint PowerShell Sessions') {

    $CollectionName = 'PowerShell Sessions'
    Create-PSWriteHTMLSaveName -CollectionName $CollectionName -DateTime $DateTime

    if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
        foreach ($TargetComputer in $script:ComputerList) {
            if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { Set-NewCredential }

                Invoke-Command -ScriptBlock $PowerShellSessionsScriptBlock `
                -ComputerName $TargetComputer `
                -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
                -Credential $script:Credential

                Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `$PowerShellSessionsScriptBlock -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)' -Credential `$script:Credential"
            }
            else {
                Invoke-Command -ScriptBlock $PowerShellSessionsScriptBlock `
                -ComputerName $TargetComputer `
                -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"

                Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `$PowerShellSessionsScriptBlock -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)'"
            }
        }
        Monitor-Jobs -CollectionName $CollectionName -MonitorMode -PSWriteHTMLSwitch -PSWriteHTML 'PowerShellSessionsData' -PSWriteHTMLFilePath $script:PSWriteHTMLFilePath -ComputerName $TargetComputer
    }

    $script:ProgressBarQueriesProgressBar.Value += 1
    $script:ProgressBarQueriesProgressBar.Refresh()
}


####################################################################################################
# Logon Activity                                                                                   #
####################################################################################################
if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedListBox.CheckedItems -contains 'Endpoint Logon Activity (30 Days)') {

    $CollectionName = 'Logon Activity (30 Days)'
    Create-PSWriteHTMLSaveName -CollectionName $CollectionName -DateTime $DateTime

    if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
        foreach ($TargetComputer in $script:ComputerList) {
            if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { Set-NewCredential }

                Invoke-Command -ScriptBlock $LogonActivityScriptblock `
                -ComputerName $TargetComputer `
                -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
                -Credential $script:Credential

                Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `$LogonActivityScriptblock -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)' -Credential `$script:Credential"
            }
            else {
                Invoke-Command -ScriptBlock $LogonActivityScriptblock `
                -ComputerName $TargetComputer `
                -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"

                Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `$LogonActivityScriptblock -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)'"
            }
        }
        Monitor-Jobs -CollectionName $CollectionName -MonitorMode -PSWriteHTMLSwitch -PSWriteHTML 'EndpointLogonActivity' -PSWriteHTMLFilePath $script:PSWriteHTMLFilePath -ComputerName $TargetComputer
    }

    $script:ProgressBarQueriesProgressBar.Value += 1
    $script:ProgressBarQueriesProgressBar.Refresh()
}





if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedListBox.CheckedItems -match 'Endpoint') {
    if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Completed: Individual Execution")
    }
}


####################################################################################################
####################################################################################################
##                                                                                                ##
##  Active Directory Collection                                                                   ##
##                                                                                                ##
####################################################################################################
####################################################################################################

if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedListBox.CheckedItems -match 'Active Directory'){
    if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Individual Exeuction")
    }
}


####################################################################################################
# Active Directory Users                                                                           #
####################################################################################################

if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedListBox.CheckedItems -contains 'Active Directory Users') {

    $CollectionName = 'Active Directory Users'
    Create-PSWriteHTMLSaveName -CollectionName $CollectionName -DateTime $DateTime

    function script:start-PSWriteHTMLActiveDirectoryUsers {

        $ADUsersEnabled                = $script:PSWriteHTMLADUsers | Select-Object Enabled | Where-Object {$_.Enabled -ne $null} | Group-Object Enabled | Sort-Object Count, Name
        $ADUsersLockedOut              = $script:PSWriteHTMLADUsers | Select-Object LockedOut | Where-Object {$_.LockedOut -ne $null} | Group-Object LockedOut | Sort-Object Count, Name
        $ADUsersBadLogonCount          = $script:PSWriteHTMLADUsers | Select-Object BadLogonCount | Where-Object {$_.BadLogonCount -ne $null} | Group-Object BadLogonCount | Sort-Object Count, Name
        $ADUsersMemberOf = @()
            $script:PSWriteHTMLADUsers | Select-Object memberof | Foreach-Object {$ADUsersMemberOf += ($_.memberof -split ',')[0] -replace 'CN=','' | Where-Object {$_ -ne ''}}
            $ADUsersMemberOf           = $ADUsersMemberOf | Group-Object | Sort-Object Count, Name
        $ADUsersSmartcardLogonRequired = $script:PSWriteHTMLADUsers | Select-Object SmartcardLogonRequired | Where-Object {$_.SmartcardLogonRequired -ne $null} | Group-Object SmartcardLogonRequired | Sort-Object Count, Name
        $ADUsersPasswordNotRequired    = $script:PSWriteHTMLADUsers | Select-Object PasswordNotRequired  | Where-Object {$_.PasswordNotRequired  -ne $null} | Group-Object PasswordNotRequired  | Sort-Object Count, Name
        $ADUsersPasswordNeverExpires   = $script:PSWriteHTMLADUsers | Select-Object PasswordNeverExpires | Where-Object {$_.PasswordNeverExpires -ne $null} | Group-Object PasswordNeverExpires | Sort-Object Count, Name
        $ADUsersPasswordExpired        = $script:PSWriteHTMLADUsers | Select-Object PasswordExpired | Where-Object {$_.PasswordExpired -ne $null} | Group-Object PasswordExpired | Sort-Object Count, Name

        $ADUsersLastBadPasswordAttempt = $script:PSWriteHTMLADUsers | Select-Object @{n='LastBadPasswordAttemptDay';e={($_.LastBadPasswordAttempt -split ' ')[0]}} | Group-Object LastBadPasswordAttempt | Sort-Object Count, Name
        $ADUsersPassWordLastSetDay     = $script:PSWriteHTMLADUsers | Select-Object @{n='PasswordLastSetDay';e={($_.PasswordLastSet -split ' ')[0]}} | Group-Object PasswordLastSetDay | Sort-Object Count, Name
        $ADUsersAccountExpirationDay   = $script:PSWriteHTMLADUsers | Select-Object @{n='AccountExpirationDay';e={($_.AccountExpirationDate -split ' ')[0]}} | Group-Object AccountExpirationDay | Sort-Object Count, Name
        $ADUsersWhenCreatedDay         = $script:PSWriteHTMLADUsers | Select-Object @{n='WhenCreatedDay';e={($_.WhenCreated -split ' ')[0]}} | Group-Object WhenCreatedDay | Sort-Object Count, Name
        $ADUsersWhenChangedDay         = $script:PSWriteHTMLADUsers | Select-Object @{n='WhenChangedDay';e={($_.WhenChanged -split ' ')[0]}} | Group-Object WhenChangedDay | Sort-Object Count, Name
        $ADUsersLastLogonDay           = $script:PSWriteHTMLADUsers | Select-Object @{n='LastLogonDay';e={($_.lastlogondate -split ' ')[0]}} | Group-Object LastLogonDay | Sort-Object Count, Name


        #foreach ($Domain in $script:PSWriteHTMLForest.Domains) {
        #    New-HTMLTab -TabName "Domain: $Domain" -IconSolid dice -IconColor LightSkyBlue {

                $DataTableIDUsers = Get-Random -Minimum 1000000 -Maximum 20000000

                New-HTMLTab -TabName "Active Directory Users" -IconSolid user -IconColor LightSkyBlue {
                    ###########
                    New-HTMLTab -Name 'Table Search' -IconRegular window-maximize {
                        New-HTMLSection -HeaderText 'Table Search' -Height 725 -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                            New-HTMLTable -DataTable $script:PSWriteHTMLADUsers {
                                New-TableHeader -Color Blue -Alignment left -Title 'Active Directory Users' -FontSize 18
                            } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                        }
                    }
                    ###########
                    New-HTMLTab -Name 'Pane Search' -IconSolid th {
                        New-HTMLSection -HeaderText 'Pane Search' -Height 725 -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                            New-HTMLTable -DataTable $script:PSWriteHTMLADUsers {
                                New-TableHeader -Color Blue -Alignment left -Title 'Active Directory Users' -FontSize 18
                            } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength', 'searchPanes') -searchpane -SearchRegularExpression
                        }
                    }
                    ###########
                    New-HTMLTab -TabName "Calendar" -IconRegular calendar-alt   {
                        New-HTMLSection -HeaderText 'Calendar' {
                            New-HTMLTable -DataTable $script:PSWriteHTMLADUsers {
                                New-TableHeader -Color Blue -Alignment left -Title 'Calendar - Active Directory Users' -FontSize 18
                            } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                            New-HTMLCalendar {
                                foreach ($_ in $script:PSWriteHTMLADUsers) {
                                    New-CalendarEvent -StartDate $_.WhenCreated -Title "Created: $($_.DNSHostName)" -Description "$($_.Name) || Created: $($_.WhenCreated)"
                                    New-CalendarEvent -StartDate $_.WhenChanged -Title "Changed: $($_.DNSHostName)" -Description "$($_.Name) || Modified: $($_.WhenChanged)"
                                }
                            } -InitialView dayGridMonth #timeGridDay
                        }
                    }
                    ###########
                    New-HTMLTab -Name 'Charts' -IconRegular chart-bar {
                        script:Generate-TablePieBarCharts -Title "Enabled" -Data $ADUsersEnabled
                        script:Generate-TablePieBarCharts -Title "Locked Out" -Data $ADUsersLockedOut
                        script:Generate-TablePieBarCharts -Title "Bad Logon Count" -Data $ADUsersBadLogonCount
                        script:Generate-TablePieBarCharts -Title "Member Of" -Data $ADUsersMemberOf
                        script:Generate-TablePieBarCharts -Title "Smartcard Logon Required" -Data $ADUsersSmartcardLogonRequired
                        script:Generate-TablePieBarCharts -Title "Password Not Required" -Data $ADUsersPasswordNotRequired
                        script:Generate-TablePieBarCharts -Title "Password Never Expires" -Data $ADUsersPasswordNeverExpires
                        script:Generate-TablePieBarCharts -Title "Password Expired" -Data $ADUsersPasswordExpired
                        script:Generate-TablePieBarCharts -Title "Last Bad Password Attempt" -Data $ADUsersLastBadPasswordAttempt
                        script:Generate-TablePieBarCharts -Title "PassWord Last Set Day" -Data $ADUsersPassWordLastSetDay
                        script:Generate-TablePieBarCharts -Title "Account Expiration Day" -Data $ADUsersAccountExpirationDay
                        script:Generate-TablePieBarCharts -Title "When Created Day" -Data $ADUsersWhenCreatedDay
                        script:Generate-TablePieBarCharts -Title "When Changed Day" -Data $ADUsersWhenChangedDay
                        script:Generate-TablePieBarCharts -Title "Last Logon Day" -Data $ADUsersLastLogonDay
                    }
                    ###########
                    New-HTMLTab -TabName 'Graph & Table' -IconSolid bezier-curve {
                        New-HTMLSection -HeaderText 'Active Directory Users' -CanCollapse {
                            New-HTMLPanel -Width 40% {
                                New-HTMLTable -DataTable $script:PSWriteHTMLADUsers -DataTableID $DataTableIDUsers {
                                    New-TableHeader -Color Blue -Alignment Center -Title 'AD Users' -FontSize 18
                                }
                            }
                            New-HTMLPanel {
                                New-HTMLText `
                                    -FontSize 12 `
                                    -FontFamily 'Source Sans Pro' `
                                    -Color Blue `
                                    -Text 'Click On The User Icons To Automatically Locate Them Within The Table'

                                New-HTMLDiagram -Height '1000px' {
                                    New-DiagramEvent -ID $DataTableIDUsers -ColumnID 1

                                    $OuCnList = @()
                                    foreach ($object in $script:PSWriteHTMLADUsers) {
                                        $OuCn = ($object.DistinguishedName -split ',')[1..$object.DistinguishedName.length] -join ','
                                        $Level = 0
                                        $OrgUnit = $object.DistinguishedName -split ','

                                        foreach ($OU in $OrgUnit) {
                                            $OrgUnit[0..$Level] -join ','
                                            $Level += 1
                                            if ("Active Directory" -notin $OuCnList) {
                                                $OuCnList += "Active Directory"
                                                New-DiagramNode `
                                                    -Label  "Active Directory" `
                                                    -To     "$($OrgUnit[-1])" `
                                                    -Image  "$Dependencies\Images\ActiveDirectory.jpg" `
                                                    -Size   35 `
                                                    -BorderWidth 2 `
                                                    -ArrowsFromEnabled
                                            }
                                            elseif ("$($OrgUnit[$Level..$OrgUnit.Length])" -notin $OuCnList) {
                                                $OuCnList += "$($OrgUnit[$Level..$OrgUnit.Length])"
                                                New-DiagramNode `
                                                    -Label  "$($OrgUnit[$Level..$OrgUnit.Length] -join ',')" `
                                                    -To     "$($OrgUnit[$($Level + 1)..$OrgUnit.Length] -join ',')" `
                                                    -Image  "$Dependencies\Images\OrganizationalUnit.jpg" `
                                                    -Size   30 `
                                                    -ArrowsToEnabled
                                            }
                                        }
                                        New-DiagramNode `
                                            -Label  $OuCn `
                                            -To     $object.Name `
                                            -Image  "$Dependencies\Images\OrganizationalUnit.jpg" `
                                            -Size   30 `
                                            -ArrowsFromEnabled

                                        New-DiagramNode `
                                            -Label  $object.Name `
                                            -Image  "$Dependencies\Images\User.jpg" `
                                            -size   25
                                    }
                                }
                            }
                        }
                    }
            #    }
            #}
        }
    }


    if ($script:PSWriteHTMLFormOkay -eq $true -and $script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
        foreach ($TargetComputer in $script:ComputerList) {
            if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { Set-NewCredential }

                $script:PSWriteHTMLForest = Invoke-Command -ScriptBlock { Get-ADForest } `
                -ComputerName $TargetComputer `
                -Credential $script:Credential

                Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { Get-ADForest } -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)' -Credential `$script:Credential"

                foreach ($Domain in $script:PSWriteHTMLForest.Domains) {
                    $Script:Job = Invoke-Command -ScriptBlock {
                        param($Domain)
                        Get-ADUser -Server $Domain -Filter * -Properties SamAccountName, Name, Enabled, LockedOut, BadLogonCount, SmartcardLogonRequired, PasswordNotRequired, PasswordNeverExpires, PasswordExpired, LastBadPasswordAttempt, PasswordLastSet, AccountExpirationDate, WhenCreated, WhenChanged, LastLogonDate, MemberOf, Description, Certificates, DistinguishedName, SID | Select-Object SamAccountName, Name, Enabled, LockedOut, BadLogonCount, SmartcardLogonRequired, PasswordNotRequired, PasswordNeverExpires, PasswordExpired, LastBadPasswordAttempt, PasswordLastSet, AccountExpirationDate, WhenCreated, WhenChanged, LastLogonDate, MemberOf, Description, Certificates, DistinguishedName, SID
                    } `
                    -ArgumentList $Domain `
                    -ComputerName $TargetComputer `
                    -Credential $script:Credential `
                    -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"

                    Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock {param($Domain); Get-ADUser -Server $Domain -Filter * -Properties SamAccountName, Name, Enabled, LockedOut, BadLogonCount, SmartcardLogonRequired, PasswordNotRequired, PasswordNeverExpires, PasswordExpired, LastBadPasswordAttempt, PasswordLastSet, AccountExpirationDate, WhenCreated, WhenChanged, LastLogonDate, MemberOf, Description, Certificates, DistinguishedName, SID | Select-Object SamAccountName, Name, Enabled, LockedOut, BadLogonCount, SmartcardLogonRequired, PasswordNotRequired, PasswordNeverExpires, PasswordExpired, LastBadPasswordAttempt, PasswordLastSet, AccountExpirationDate, WhenCreated, WhenChanged, LastLogonDate, MemberOf, Description, Certificates, DistinguishedName, SID} -ArgumentList $Domain -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)' -Credential `$script:Credential"
                }
            }
            else {
                $script:PSWriteHTMLForest = Invoke-Command -ScriptBlock { Get-ADForest } `
                -ComputerName $TargetComputer

                Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { Get-ADForest } -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)'"


                foreach ($Domain in $script:PSWriteHTMLForest.Domains) {
                    $Script:Job = Invoke-Command -ScriptBlock {
                        param($Domain)
                        Get-ADUser -Server $Domain -Filter * -Properties SamAccountName, Name, Enabled, LockedOut, BadLogonCount, SmartcardLogonRequired, PasswordNotRequired, PasswordNeverExpires, PasswordExpired, LastBadPasswordAttempt, PasswordLastSet, AccountExpirationDate, WhenCreated, WhenChanged, LastLogonDate, MemberOf, Description, Certificates, DistinguishedName, SID | Select-Object SamAccountName, Name, Enabled, LockedOut, BadLogonCount, SmartcardLogonRequired, PasswordNotRequired, PasswordNeverExpires, PasswordExpired, LastBadPasswordAttempt, PasswordLastSet, AccountExpirationDate, WhenCreated, WhenChanged, LastLogonDate, MemberOf, Description, Certificates, DistinguishedName, SID
                    } `
                    -ArgumentList $Domain `
                    -ComputerName $TargetComputer `
                    -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"

                    Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock {param($Domain); Get-ADUser -Server $Domain -Filter * -Properties SamAccountName, Name, Enabled, LockedOut, BadLogonCount, SmartcardLogonRequired, PasswordNotRequired, PasswordNeverExpires, PasswordExpired, LastBadPasswordAttempt, PasswordLastSet, AccountExpirationDate, WhenCreated, WhenChanged, LastLogonDate, MemberOf, Description, Certificates, DistinguishedName, SID | Select-Object SamAccountName, Name, Enabled, LockedOut, BadLogonCount, SmartcardLogonRequired, PasswordNotRequired, PasswordNeverExpires, PasswordExpired, LastBadPasswordAttempt, PasswordLastSet, AccountExpirationDate, WhenCreated, WhenChanged, LastLogonDate, MemberOf, Description, Certificates, DistinguishedName, SID} -ArgumentList $Domain -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)'"
                }
            }
        }
        Monitor-Jobs -CollectionName $CollectionName -MonitorMode -PSWriteHTMLSwitch -PSWriteHTML 'PSWriteHTMLADUsers' -PSWriteHTMLFilePath $script:PSWriteHTMLFilePath
    }
}
















####################################################################################################
# Active Directory Computers                                                                       #
####################################################################################################

if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedListBox.CheckedItems -contains 'Active Directory Computers') {

    $CollectionName = 'Active Directory Computers'
    Create-PSWriteHTMLSaveName -CollectionName $CollectionName -DateTime $DateTime

    function script:start-PSWriteHTMLActiveDirectoryComputers {

        $ADComputersOperatingSystems   = $script:PSWriteHTMLADComputers | Select-Object OperatingSystem | Where-Object {$_.OperatingSystem -ne $null} | Group-Object OperatingSystem | Sort-Object Count, Name
        $ADComputersOSVersions         = $script:PSWriteHTMLADComputers | Select-Object OperatingSystemVersion | Where-Object {$_.OperatingSystemVersion -ne $null} | Group-Object OperatingSystemVersion | Sort-Object Count, Name
        $ADComputersOSServicePacks     = $script:PSWriteHTMLADComputers | Select-Object OperatingSystemServicePack | Where-Object {$_.OperatingSystemServicePack -ne $null} | Group-Object OperatingSystemServicePack | Sort-Object Count, Name
        $ADComputersOSHotfixes         = $script:PSWriteHTMLADComputers | Select-Object OperatingSystemHotfix | Where-Object {$_.OperatingSystemHotfix -ne $null} | Group-Object OperatingSystemHotfix | Sort-Object Count, Name
        $ADComputersIPv4Address        = $script:PSWriteHTMLADComputers | Select-Object IPv4Address | Where-Object {$_.IPv4Address  -ne $null} | Group-Object IPv4Address  | Sort-Object Count, Name
        $ADComputersEnabled            = $script:PSWriteHTMLADComputers | Select-Object Enabled | Where-Object {$_.Enabled -ne $null} | Group-Object Enabled | Sort-Object Count, Name
        $ADComputersWhenCreatedDay     = $script:PSWriteHTMLADComputers | Select-Object @{n='WhenCreatedDay';e={($_.WhenCreated -split ' ')[0]}} | Group-Object WhenCreatedDay | Sort-Object Count, Name
        $ADComputersWhenChangedDay     = $script:PSWriteHTMLADComputers | Select-Object @{n='WhenChangedDay';e={($_.WhenChanged -split ' ')[0]}} | Group-Object WhenChangedDay | Sort-Object Count, Name
        $ADComputersLastLogonDay       = $script:PSWriteHTMLADComputers | Select-Object @{n='LastLogonDay';e={($_.lastlogondate -split ' ')[0]}} | Group-Object LastLogonDay | Sort-Object Count, Name
        $ADComputersPassWordLastSetDay = $script:PSWriteHTMLADComputers | Select-Object @{n='PasswordLastSetDay';e={($_.PasswordLastSet -split ' ')[0]}} | Group-Object PasswordLastSetDay | Sort-Object Count, Name


        #foreach ($Domain in $script:PSWriteHTMLForest.Domains) {
        #    New-HTMLTab -TabName "Domain: $Domain" -IconSolid dice -IconColor LightSkyBlue {

                $DataTableIDComputers = Get-Random -Minimum 1000000 -Maximum 20000000

                New-HTMLTab -TabName "Active Directory Computers" -IconSolid server -IconColor LightSkyBlue {
                    ###########
                    New-HTMLTab -Name 'Table Search' -IconRegular window-maximize {
                        New-HTMLSection -HeaderText 'Table Search' -Height 725 -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                            New-HTMLTable -DataTable $script:PSWriteHTMLADComputers {
                                New-TableHeader -Color Blue -Alignment left -Title 'Active Directory Computers' -FontSize 18
                            } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                        }
                    }
                    ###########
                    New-HTMLTab -Name 'Pane Search' -IconSolid th {
                        New-HTMLSection -HeaderText 'Pane Search' -Height 725 -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                            New-HTMLTable -DataTable $script:PSWriteHTMLADComputers {
                                New-TableHeader -Color Blue -Alignment left -Title 'Active Directory Computers' -FontSize 18
                            } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength', 'searchPanes') -searchpane -SearchRegularExpression
                        }
                    }
                    ###########
                    New-HTMLTab -TabName "Calendar" -IconRegular calendar-alt   {
                        New-HTMLSection -HeaderText 'Calendar' {
                            New-HTMLTable -DataTable $script:PSWriteHTMLADComputers {
                                New-TableHeader -Color Blue -Alignment left -Title 'Calendar - Active Directory Computers' -FontSize 18
                            } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                            New-HTMLCalendar {
                                foreach ($_ in $script:PSWriteHTMLADComputers) {
                                    New-CalendarEvent -StartDate $_.WhenCreated -Title "Created: $($_.DNSHostName)" -Description "$($_.DNSHostName) || Created: $($_.WhenCreated)"
                                    New-CalendarEvent -StartDate $_.LastLogonDate -Title "Logon: $($_.DNSHostName)" -Description "$($_.DNSHostName) || Last Logon Date: $($_.LastLogonDate)"
                                    New-CalendarEvent -StartDate $_.PasswordLastSet -Title "Password: $($_.DNSHostName)" -Description "$($_.DNSHostName) || Password Last Set: $($_.PasswordLastSet)"
                                }
                            } -InitialView dayGridMonth #timeGridDay
                        }
                    }
                    ###########
                    New-HTMLTab -Name 'Charts' -IconRegular chart-bar {
                        script:Generate-TablePieBarCharts -Title "Operating Systems" -Data $ADComputersOperatingSystems
                        script:Generate-TablePieBarCharts -Title "OS Versions" -Data $ADComputersOSVersions
                        script:Generate-TablePieBarCharts -Title "OS Service Packs" -Data $ADComputersOSServicePacks
                        script:Generate-TablePieBarCharts -Title "OS Hot fixes" -Data $ADComputersOSHotfixes
                        script:Generate-TablePieBarCharts -Title "IPv4 Address" -Data $ADComputersIPv4Address
                        script:Generate-TablePieBarCharts -Title "Enabled" -Data $ADComputersEnabled
                        script:Generate-TablePieBarCharts -Title "When Created Day" -Data $ADComputersWhenCreatedDay
                        script:Generate-TablePieBarCharts -Title "When Changed Day" -Data $ADComputersWhenChangedDay
                        script:Generate-TablePieBarCharts -Title "Last Logon Day" -Data $ADComputersLastLogonDay
                        script:Generate-TablePieBarCharts -Title "PassWord Last Set Day" -Data $ADComputersPassWordLastSetDay
                    }
                    ###########
                    New-HTMLTab -TabName 'Graph & Table' -IconSolid bezier-curve {
                        New-HTMLSection -HeaderText 'Active Directory Computers' -CanCollapse {
                            New-HTMLPanel -Width 40% {
                                New-HTMLTable -DataTable $script:PSWriteHTMLADComputers -DataTableID $DataTableIDComputers {
                                    New-TableHeader -Color Blue -Alignment center -Title 'AD Computers' -FontSize 18
                                }
                            }
                            New-HTMLPanel {
                                New-HTMLText `
                                    -FontSize 12 `
                                    -FontFamily 'Source Sans Pro' `
                                    -Color Blue `
                                    -Text 'Click On The Computer Icons To Automatically Locate Them Within The Table'

                                New-HTMLDiagram -Height '1000px' {
                                    New-DiagramEvent -ID $DataTableIDComputers -ColumnID 1

                                    $OuCnList = @()
                                    foreach ($object in $script:PSWriteHTMLADComputers) {
                                        $OuCn = ($object.DistinguishedName -split ',')[1..$object.DistinguishedName.length] -join ','
                                        $Level = 0
                                        $OrgUnit = $object.DistinguishedName -split ','

                                        foreach ($OU in $OrgUnit) {
                                            $OrgUnit[0..$Level] -join ','
                                            $Level += 1
                                            if ("Active Directory" -notin $OuCnList) {
                                                $OuCnList += "Active Directory"
                                                New-DiagramNode `
                                                    -Label  "Active Directory" `
                                                    -To     "$($OrgUnit[-1])" `
                                                    -Image  "$Dependencies\Images\ActiveDirectory.jpg" `
                                                    -Size   35 `
                                                    -BorderWidth 2 `
                                                    -ArrowsFromEnabled
                                            }
                                            elseif ("$($OrgUnit[$Level..$OrgUnit.Length])" -notin $OuCnList) {
                                                $OuCnList += "$($OrgUnit[$Level..$OrgUnit.Length])"
                                                New-DiagramNode `
                                                    -Label  "$($OrgUnit[$Level..$OrgUnit.Length] -join ',')" `
                                                    -To     "$($OrgUnit[$($Level + 1)..$OrgUnit.Length] -join ',')" `
                                                    -Image  "$Dependencies\Images\OrganizationalUnit.jpg" `
                                                    -Size   30 `
                                                    -ArrowsToEnabled
                                            }
                                        }
                                        New-DiagramNode `
                                            -Label  $OuCn `
                                            -To     $object.Name `
                                            -Image  "$Dependencies\Images\OrganizationalUnit.jpg" `
                                            -Size   30 `
                                            -ArrowsFromEnabled

                                        New-DiagramNode `
                                            -Label  $object.Name `
                                            -Image  "$Dependencies\Images\Computer.jpg" `
                                            -size   20
                                    }
                                }
                            }
                        }
                    }
                }
        #    }
        #}
    }


    if ($script:PSWriteHTMLFormOkay -eq $true -and $script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {

        $CollectionName = 'Process Data'
        Create-PSWriteHTMLSaveName -CollectionName $CollectionName -DateTime $DateTime

        foreach ($TargetComputer in $script:ComputerList) {
            if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { Set-NewCredential }

                $script:PSWriteHTMLForest = Invoke-Command -ScriptBlock { Get-ADForest } `
                -ComputerName $TargetComputer `
                -Credential $script:Credential

                Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { Get-ADForest } -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)' -Credential `$script:Credential"


                foreach ($Domain in $script:PSWriteHTMLForest.Domains) {
                    Invoke-Command -ScriptBlock {
                        param($Domain)
                        Get-ADComputer -Server $Domain -Filter * -Properties DNSHostName, Name, LogonCount, IPv4Address, IPv6Address, Enabled, OperatingSystem, OperatingSystemVersion, OperatingSystemHotfix, OperatingSystemServicePack, LastLogonDate, WhenCreated, WhenChanged, PasswordLastSet, PasswordExpired, LockedOut, DistinguishedName, MemberOf, PrimaryGroupID, SID | Select-Object DNSHostName, Name, LogonCount, IPv4Address, IPv6Address, Enabled, OperatingSystem, OperatingSystemVersion, OperatingSystemHotfix, OperatingSystemServicePack, LastLogonDate, WhenCreated, WhenChanged, PasswordLastSet, PasswordExpired, LockedOut, DistinguishedName, MemberOf, PrimaryGroupID, SID
                    } `
                    -ArgumentList $Domain `
                    -ComputerName $TargetComputer `
                    -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
                    -Credential $script:Credential

                    Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock {param($Domain); Get-ADComputer -Server $Domain -Filter * -Properties DNSHostName, Name, LogonCount, IPv4Address, IPv6Address, Enabled, OperatingSystem, OperatingSystemVersion, OperatingSystemHotfix, OperatingSystemServicePack, LastLogonDate, WhenCreated, WhenChanged, PasswordLastSet, PasswordExpired, LockedOut, DistinguishedName, MemberOf, PrimaryGroupID, SID | Select-Object DNSHostName, Name, LogonCount, IPv4Address, IPv6Address, Enabled, OperatingSystem, OperatingSystemVersion, OperatingSystemHotfix, OperatingSystemServicePack, LastLogonDate, WhenCreated, WhenChanged, PasswordLastSet, PasswordExpired, LockedOut, DistinguishedName, MemberOf, PrimaryGroupID, SID} -ArgumentList $Domain -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)' -Credential `$script:Credential"
                }
            }
            else {
                $script:PSWriteHTMLForest = Invoke-Command -ScriptBlock { Get-ADForest } `
                -ComputerName $TargetComputer

                Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { Get-ADForest } -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)'"


                foreach ($Domain in $script:PSWriteHTMLForest.Domains) {
                    Invoke-Command -ScriptBlock {
                        param($Domain)
                        Get-ADComputer -Server $Domain -Filter * -Properties DNSHostName, Name, LogonCount, IPv4Address, IPv6Address, Enabled, OperatingSystem, OperatingSystemVersion, OperatingSystemHotfix, OperatingSystemServicePack, LastLogonDate, WhenCreated, WhenChanged, PasswordLastSet, PasswordExpired, LockedOut, DistinguishedName, MemberOf, PrimaryGroupID, SID | Select-Object DNSHostName, Name, LogonCount, IPv4Address, IPv6Address, Enabled, OperatingSystem, OperatingSystemVersion, OperatingSystemHotfix, OperatingSystemServicePack, LastLogonDate, WhenCreated, WhenChanged, PasswordLastSet, PasswordExpired, LockedOut, DistinguishedName, MemberOf, PrimaryGroupID, SID
                    } `
                    -ArgumentList $Domain `
                    -ComputerName $TargetComputer `
                    -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"

                    Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock {param($Domain); Get-ADComputer -Server $Domain -Filter * -Properties DNSHostName, Name, LogonCount, IPv4Address, IPv6Address, Enabled, OperatingSystem, OperatingSystemVersion, OperatingSystemHotfix, OperatingSystemServicePack, LastLogonDate, WhenCreated, WhenChanged, PasswordLastSet, PasswordExpired, LockedOut, DistinguishedName, MemberOf, PrimaryGroupID, SID | Select-Object DNSHostName, Name, LogonCount, IPv4Address, IPv6Address, Enabled, OperatingSystem, OperatingSystemVersion, OperatingSystemHotfix, OperatingSystemServicePack, LastLogonDate, WhenCreated, WhenChanged, PasswordLastSet, PasswordExpired, LockedOut, DistinguishedName, MemberOf, PrimaryGroupID, SID} -ArgumentList $Domain -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)'"
                }
            }
        }
        Monitor-Jobs -CollectionName $CollectionName -MonitorMode -PSWriteHTMLSwitch -PSWriteHTML 'PSWriteHTMLADComputers' -PSWriteHTMLFilePath $script:PSWriteHTMLFilePath
    }
}


if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedListBox.CheckedItems -match 'Active Directory') {
    if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Completed: Individual Execution")
    }
}
































####################################################################################################
####################################################################################################
##                                                                                                ##
## PSWriteHTML Launcher                                                                           ##
##                                                                                                ##
####################################################################################################
####################################################################################################

if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedListBox.CheckedItems.count -gt 0) {
    $script:ProgressBarQueriesProgressBar.Value = $script:ProgressBarQueriesProgressBar.Maximum
    $script:ProgressBarQueriesProgressBar.Refresh()
}

if ($script:RollCredentialsState -and $script:ComputerListProvideCredentialsCheckBox.checked) {
    Start-Sleep -Seconds 3
    Set-NewRollingPassword
}




}

$PSWriteHTMLButtonAdd_MouseHover = {
    Show-ToolTip -Title "Graph Data" -Icon "Info" -Message @"
+  Utilizes the PSWriteHTML module to generate graph data in a web browser.
+  Requires that the PSWriteHTML module is loaded
+  Requires PowerShell v5.1+
"@
}










# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUYOmfkVS5zswH4AWhY0f70WST
# doigggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUDD34tGf5bx6YeH2ldKWgNMHn4XcwDQYJKoZI
# hvcNAQEBBQAEggEAT6JSxDh2r7KdKry6LEss40nz2Q/4mmQ19SgZIN1DnjPRJRxP
# O2ezIzMUQIMFnC9RZVfUbEqpT/+xegJuf2LJrordf77ifwqJwbpHbX+0SV6tezkJ
# cAkV4K04PBNiBJpwTbUfMgEDI9nyqyMbT0iw5lrWPWVQZMUo1V5qajq9l5k7YC+y
# 2Cb1svf3IdRyWYLF1JyH4cKK86kRBZRxeFdBsBfNb6V26X29nacAYHLVclRMZqyx
# 7Y7acfiVoiCIbzLPd72fgNVJrOXnzlWqo6Q3+8Sy7eaB+0f432tbbFm3oncxuluh
# yvoO8FFcIar2yOXmUNEfGhjD2Hb9ugKZ3ujzeQ==
# SIG # End signature block
