$PSWriteHTMLButtonAdd_Click = {


Update-FormProgress "$PSWriteHTMLDirectory\Invoke-PSWriteHTMLEndpointSnapshot.ps1"
. "$PSWriteHTMLDirectory\Invoke-PSWriteHTMLEndpointSnapshot.ps1"

Update-FormProgress "$PSWriteHTMLDirectory\EndpointDataSystemSnapshotScriptBlock.ps1"
. "$PSWriteHTMLDirectory\EndpointDataSystemSnapshotScriptBlock.ps1"
#Note: Contains $EndpointDataSystemSnapshotScriptBlock

Update-FormProgress "$PSWriteHTMLDirectory\Invoke-PSWriteHTMLProcess.ps1"
. "$PSWriteHTMLDirectory\Invoke-PSWriteHTMLProcess.ps1"

Update-FormProgress "$PSWriteHTMLDirectory\ProcessesScriptblock.ps1"
. "$PSWriteHTMLDirectory\ProcessesScriptblock.ps1"
    #Note: Contains $ProcessesScriptblock

Update-FormProgress "$PSWriteHTMLDirectory\Launch-NetworkConnectionGUI.ps1"
. "$PSWriteHTMLDirectory\Launch-NetworkConnectionGUI.ps1"

Update-FormProgress "$PSWriteHTMLDirectory\Invoke-PSWriteHTMLNetworkConnections.ps1"
. "$PSWriteHTMLDirectory\Invoke-PSWriteHTMLNetworkConnections.ps1"
        
Update-FormProgress "$PSWriteHTMLDirectory\NetworkConnectionsScriptBlock.ps1"
. "$PSWriteHTMLDirectory\NetworkConnectionsScriptBlock.ps1"
    #Note: Contains $NetworkConnectionsScriptBlock

Update-FormProgress "$PSWriteHTMLDirectory\Invoke-PSWriteHTMLConsoleLogons.ps1"
. "$PSWriteHTMLDirectory\Invoke-PSWriteHTMLConsoleLogons.ps1"
    
Update-FormProgress "$PSWriteHTMLDirectory\ConsoleLogonsScriptBlock.ps1"
. "$PSWriteHTMLDirectory\ConsoleLogonsScriptBlock.ps1"
    #Note: Contains $ConsoleLogonsScriptBlock

Update-FormProgress "$PSWriteHTMLDirectory\Invoke-PSWriteHTMLPowerShellSessions.ps1"
. "$PSWriteHTMLDirectory\Invoke-PSWriteHTMLPowerShellSessions.ps1"
    
Update-FormProgress "$PSWriteHTMLDirectory\PowerShellSessionsScriptBlock.ps1"
. "$PSWriteHTMLDirectory\PowerShellSessionsScriptBlock.ps1"
    #Note: Contains $PowerShellSessionsScriptBlock

Update-FormProgress "$PSWriteHTMLDirectory\Invoke-PSWriteHTMLLogonActivity.ps1"
. "$PSWriteHTMLDirectory\Invoke-PSWriteHTMLLogonActivity.ps1"
    
Update-FormProgress "$PSWriteHTMLDirectory\LogonActivityScriptblock.ps1"
. "$PSWriteHTMLDirectory\LogonActivityScriptblock.ps1"
    #Note: Contains $LogonActivityScriptblock



$InformationTabControl.SelectedTab = $Section3MonitorJobsTab

$script:PSWriteHTMLFilePath = "$($script:CollectionSavedDirectoryTextBox.Text)\$CollectionName (Browser) $($(Get-Date).ToString('yyyy-MM-dd HH.mm.ss')).html"

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
                    New-ChartLegend -HideLegend #-LegendPosition topRight -Names "XXXXXXXX" -Color LightCoral
                    Foreach ($_ in ($Data | Select-Object -First 10)){
                        New-ChartPie -Name $_.Name -Value $_.Count
                    }
                    New-ChartEvent -DataTableID $DataTableID -ColumnID 0
                }
            }
            New-HTMLSection -Invisible {
                New-HTMLChart -Title 'Botom 10' -Gradient -TitleAlignment left {
                    New-ChartLegend -HideLegend #-LegendPosition topRight -Names "XXXXXXXX" -Color LightCoral
                    Foreach ($_ in ($Data | Select-Object -Last 10)){
                        New-ChartPie -Name $_.Name -Value $_.Count
                    }
                    New-ChartEvent -DataTableID $DataTableID -ColumnID 0
                }
            }
        }
        New-HTMLPanel {
            New-HTMLChart -Title "$Title" -Gradient -TitleAlignment left {
                New-ChartLegend -HideLegend #-LegendPosition topRight -Names "XXXXXXXX" -Color LightCoral
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
    Add_Closing     = {}
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
        else { 
            [System.Windows.Forms.MessageBox]::Show("Switching to Session Based mode. Please be patient as PoSh-EasyWin gathers data - the tool may appear unresponsive as data is compiled. Results will be combined and displayed in one browser tab.",'PoSh-EasyWin - Combine Results','Ok',"Info")
            $script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem = 'Session Based' 
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
    'Endpoint Network Connections',
    'Endpoint Console Logons',
    'Endpoint PowerShell Sessions',
    'Endpoint Process Data',
    'Endpoint Logon Activity (30 Days)',
    'Endpoint Data Deep Dive (Under Development)'
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
        else {
            $script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem = 'Session Based'
        }

        if ($PSWriteHTMLCheckedListBox.CheckedItems.Count -ge 1) {
            Generate-ComputerList
            if ($script:ComputerList.count -ge 1) {
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
        # elseif ($PSWriteHTMLCheckedListBox.CheckedItems.Count -gt 2) {
        #     [System.Windows.Forms.MessageBox]::Show("Checkbox only one option from the list to collect data.",'PoSh-EasyWin')
        # }
    }
}
$PSWriteHTMLForm.Controls.Add($PSWriteHTMLGraphDataButton)
CommonButtonSettings -Button $PSWriteHTMLGraphDataButton

$PSWriteHTMLForm.Showdialog()

$PSWriteHTMLCheckedItemsList = @()
foreach($Checked in $PSWriteHTMLCheckedListBox.CheckedItems) {
    $PSWriteHTMLCheckedItemsList += $Checked
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
        $Data
    )
    New-HTML -TitleText $Title -FavIcon "$Dependencies\Images\favicon.jpg" -Online `
        -FilePath $script:PSWriteHTMLFilePath {
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
Generate-ComputerList

if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedItemsList -match 'Endpoint') {

    if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Individual Exeuction")
    }
    elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Session Based') {
        $StatusListBox.Items.Clear()
        if ($script:ComputerList.count -eq 1) {$StatusListBox.Items.Add("Establishing a PS Session with 1 Endpoint")}
        else {$StatusListBox.Items.Add("Establishing PS Sessions with $($script:ComputerList.count) Endpoints")}
    
        if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
            if (!$script:Credential) { Create-NewCredentials }
            $PSSession = New-PSSession -ComputerName $script:ComputerList -Credential $script:Credential
            Create-LogEntry -LogFile $LogFile -Message "New-PSSession -ComputerName $script:ComputerList -Credential $script:Credential"
        }
        else {
            $PSSession = New-PSSession -ComputerName $script:ComputerList 
            Create-LogEntry -LogFile $LogFile -Message "New-PSSession -ComputerName $script:ComputerList"
        }    
    }
}


if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedItemsList.count -gt 0) {
    $script:ProgressBarEndpointsProgressBar.Maximum = $script:ComputerList.count
    $script:ProgressBarEndpointsProgressBar.Value = 0
    $script:ProgressBarEndpointsProgressBar.Refresh()

    $script:ProgressBarQueriesProgressBar.Maximum = $PSWriteHTMLCheckedItemsList.count
    $script:ProgressBarQueriesProgressBar.Value = 0
    $script:ProgressBarQueriesProgressBar.Refresh()
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Using WinRM To Collect Data")
    Start-Sleep -Seconds 1
}































####################################################################################################
# Endpoint Data Deep Dive (Under Development)                                                      #
####################################################################################################
if ($PSWriteHTMLCheckedItemsList -contains 'Endpoint Data Deep Dive (Under Development)') {
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Endpoint Data Deep Dive (Under Development)")

    $CollectionName = 'test name'

    if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
        foreach ($TargetComputer in $script:ComputerList) {
            if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { Create-NewCredentials }

                Invoke-Command -ScriptBlock $EndpointDataSystemSnapshotScriptBlock `
                -ComputerName $TargetComputer `
                -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
                -Credential $script:Credential
        
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `$EndpointDataSystemSnapshotScriptBlock -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)' -Credential `$script:Credential"
            }
            else {
                Invoke-Command -ScriptBlock $EndpointDataSystemSnapshotScriptBlock `
                -ComputerName $TargetComputer `
                -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"
                            
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `$EndpointDataSystemSnapshotScriptBlock -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)'"
            }
        }
        Monitor-Jobs -CollectionName $CollectionName -MonitorMode -PSWriteHTMLSwitch -PSWriteHTML 'EndpointDataSystemSnapshot' -PSWriteHTMLFilePath $script:PSWriteHTMLFilePath -xml
    }
    elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Session Based') {
        $GetEndpointDataDeepDiveResults = Invoke-Command -ScriptBlock $EndpointDataSystemSnapshotScriptBlock -Session $PSSession | Select-Object -Property *
    } 

    $GetEndpointDataDeepDiveResults

    $script:ProgressBarQueriesProgressBar.Value += 1
    $script:ProgressBarQueriesProgressBar.Refresh()

    # if ($PSWriteHTMLIndividualWebPagesCheckbox.checked -and $script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Session Based') {
    #     if ($PSWriteHTMLCheckedListBox.CheckedItems.Count -gt 0 -and $script:ComputerList.count -gt 0) {
    #         script:Individual-PSWriteHTML -Title 'Process Data' -Data { script:Invoke-PSWriteHTMLProcess }
    #     }
    # }
}


####################################################################################################
# Process Data                                                                                     #
####################################################################################################
if ($PSWriteHTMLCheckedItemsList -contains 'Endpoint Process Data') {
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Query: Endpoint Process Data")

    if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
        foreach ($TargetComputer in $script:ComputerList) {
            if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { Create-NewCredentials }

                Invoke-Command -ScriptBlock $ProcessesScriptblock `
                -ComputerName $TargetComputer `
                -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
                -Credential $script:Credential
        
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `$ProcessesScriptblock -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)' -Credential `$script:Credential"
            }
            else {
                Invoke-Command -ScriptBlock $ProcessesScriptblock `
                -ComputerName $TargetComputer `
                -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"
                            
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `$ProcessesScriptblock -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)'"
            }
        }
        Monitor-Jobs -CollectionName $CollectionName -MonitorMode -PSWriteHTMLSwitch -PSWriteHTML 'PSWriteHTMLProcesses' -PSWriteHTMLFilePath $script:PSWriteHTMLFilePath
    }
    elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Session Based') {
        $script:PSWriteHTMLProcesses = Invoke-Command -ScriptBlock $ProcessesScriptblock -Session $PSSession |
        Select-Object ProcessID, ProcessName, PSComputerName, ParentProcessName, ParentProcessID, Level,
        ServiceInfo, StartTime, Duration, CPU, TotalProcessorTime,
        NetworkConnections, NetworkConnectionCount, CommandLine, Path, WorkingSet, MemoryUsage,
        MD5Hash, SignerCertificate, StatusMessage, SignerCompany, Company, Product, ProductVersion, Description,
        Modules, ModuleCount, Threads, ThreadCount, Handle, Handles, HandleCount,
        Owner, OwnerSID, CollectionType
    } 

    $script:ProgressBarQueriesProgressBar.Value += 1
    $script:ProgressBarQueriesProgressBar.Refresh()

    # if ($PSWriteHTMLIndividualWebPagesCheckbox.checked -and $script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Session Based') {
    #     if ($PSWriteHTMLCheckedListBox.CheckedItems.Count -gt 0 -and $script:ComputerList.count -gt 0) {
    #         script:Individual-PSWriteHTML -Title 'Process Data' -Data { script:Invoke-PSWriteHTMLProcess }
    #     }
    # }
}


####################################################################################################
# Network Connections                                                                              #
####################################################################################################
if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedItemsList -contains 'Endpoint Network Connections') {
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Query: Endpoint Network Connections")

    if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
        foreach ($TargetComputer in $script:ComputerList) {
            if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { Create-NewCredentials }

                Invoke-Command -ScriptBlock $NetworkConnectionsScriptBlock `
                -ComputerName $TargetComputer `
                -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
                -Credential $script:Credential
        
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `$NetworkConnectionsScriptBlock -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)' -Credential `$script:Credential"
            }
            else {
                Invoke-Command -ScriptBlock $NetworkConnectionsScriptBlock `
                -ComputerName $TargetComputer `
                -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"
                            
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `$NetworkConnectionsScriptBlock -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)'"
            }
        }
        Monitor-Jobs -CollectionName $CollectionName -MonitorMode -PSWriteHTMLSwitch -PSWriteHTML 'EndpointDataNetworkConnections' -PSWriteHTMLFilePath $script:PSWriteHTMLFilePath
    }
    elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Session Based') {
        $script:EndpointDataNetworkConnections = Invoke-Command -ScriptBlock $NetworkConnectionsScriptBlock -Session $PSSession
    }

    $script:ProgressBarQueriesProgressBar.Value += 1
    $script:ProgressBarQueriesProgressBar.Refresh()

    # if ($script:PSWriteHTMLIndividualWebPagesCheckbox.checked -eq $true -and $script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
    #     if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedListBox.CheckedItems.Count -gt 0) {
    #         script:Individual-PSWriteHTML -Title 'Network Connections' -Data { script:Invoke-PSWriteHTMLNetworkConnections -InputData $script:EndpointDataNetworkConnections }
    #     }
    # }
}


####################################################################################################
# Console Logons                                                                                   #
####################################################################################################
if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedItemsList -contains 'Endpoint Console Logons') {
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Query: Endpoint Console Logons")    

    if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
        foreach ($TargetComputer in $script:ComputerList) {
            if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { Create-NewCredentials }

                Invoke-Command -ScriptBlock $ConsoleLogonsScriptBlock `
                -ComputerName $TargetComputer `
                -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
                -Credential $script:Credential
        
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `$ConsoleLogonsScriptBlock -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)' -Credential `$script:Credential"
            }
            else {
                Invoke-Command -ScriptBlock $ConsoleLogonsScriptBlock `
                -ComputerName $TargetComputer `
                -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"
                            
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `$ConsoleLogonsScriptBlock -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)'"
            }
        }
        Monitor-Jobs -CollectionName $CollectionName -MonitorMode -PSWriteHTMLSwitch -PSWriteHTML 'EndpointDataConsoleLogons' -PSWriteHTMLFilePath $script:PSWriteHTMLFilePath
    }
    elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Session Based') {
        $script:EndpointDataConsoleLogons = Invoke-Command -ScriptBlock $ConsoleLogonsScriptBlock -Session $PSSession | 
        Select-Object PSComputerName, UserName, LogonTime, State, IdleTime, SessionName, SessionID
    }

    $script:ProgressBarQueriesProgressBar.Value += 1
    $script:ProgressBarQueriesProgressBar.Refresh()

    # if ($script:PSWriteHTMLIndividualWebPagesCheckbox.checked -eq $true -and $script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
    #     if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedListBox.CheckedItems.Count -gt 0) {
    #         script:Individual-PSWriteHTML -Title 'Console Logons' { script:Invoke-PSWriteHTMLConsoleLogons -InputData $script:EndpointDataConsoleLogons}
    #     }
    # }        
}


####################################################################################################
# PowerShell Sessions                                                                              #
####################################################################################################
if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedItemsList -contains 'Endpoint PowerShell Sessions') {
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Query: Endpoint PowerShell Sessions")
    
    if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
        foreach ($TargetComputer in $script:ComputerList) {
            if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { Create-NewCredentials }

                Invoke-Command -ScriptBlock $PowerShellSessionsScriptBlock `
                -ComputerName $TargetComputer `
                -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
                -Credential $script:Credential
        
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `$PowerShellSessionsScriptBlock -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)' -Credential `$script:Credential"
            }
            else {
                Invoke-Command -ScriptBlock $PowerShellSessionsScriptBlock `
                -ComputerName $TargetComputer `
                -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"
                            
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `$PowerShellSessionsScriptBlock -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)'"
            }
        }
        Monitor-Jobs -CollectionName $CollectionName -MonitorMode -PSWriteHTMLSwitch -PSWriteHTML 'PowerShellSessionsData' -PSWriteHTMLFilePath $script:PSWriteHTMLFilePath
    }
    elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Session Based') {
        $script:PowerShellSessionsData = Invoke-Command -ScriptBlock $PowerShellSessionsScriptBlock -Session $PSSession |
        Select-Object PSComputerName, ClientIP, Owner, ProcessId, State, ShellRunTime, ShellInactivity, MemoryUsed, ProfileLoaded, LogonTime, CollectionType
    }

    $script:ProgressBarQueriesProgressBar.Value += 1
    $script:ProgressBarQueriesProgressBar.Refresh()

    # if ($script:PSWriteHTMLIndividualWebPagesCheckbox.checked -eq $true -and $script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
    #     if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedListBox.CheckedItems.Count -gt 0) {
    #         script:Individual-PSWriteHTML -Title 'PowerShell Sessions' { script:PowerShellSessionsData -InputData $script:EndpointDataConsoleLogons }
    #     }
    # } 
}


####################################################################################################
# Logon Activity                                                                                   #
####################################################################################################
if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedItemsList -contains 'Endpoint Logon Activity (30 Days)') {
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Query: Endpoint Logon Activity (30 Days)")
    
    if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
        foreach ($TargetComputer in $script:ComputerList) {
            if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { Create-NewCredentials }

                Invoke-Command -ScriptBlock $LogonActivityScriptblock `
                -ComputerName $TargetComputer `
                -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
                -Credential $script:Credential
        
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `$LogonActivityScriptblock -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)' -Credential `$script:Credential"
            }
            else {
                Invoke-Command -ScriptBlock $LogonActivityScriptblock `
                -ComputerName $TargetComputer `
                -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"
                            
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `$LogonActivityScriptblock -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)'"
            }
        }
        Monitor-Jobs -CollectionName $CollectionName -MonitorMode -PSWriteHTMLSwitch -PSWriteHTML 'EndpointLogonActivity' -PSWriteHTMLFilePath $script:PSWriteHTMLFilePath
    }
    elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Session Based') {
        $script:EndpointLogonActivity = Invoke-Command -ScriptBlock $LogonActivityScriptblock -Session $PSSession | 
        Select-Object UserAccount, LogonType, TimeStamp, UserDomain, WorkstationName, SourceNetworkAddress, SourceNetworkPort, Type, LogonInterpretation
    }
        
    $script:ProgressBarQueriesProgressBar.Value += 1
    $script:ProgressBarQueriesProgressBar.Refresh()

    # if ($script:PSWriteHTMLIndividualWebPagesCheckbox.checked -eq $true -and $script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
    #     if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedListBox.CheckedItems.Count -gt 0) {
    #         script:Individual-PSWriteHTML -Title 'Logon Activity' -Data { script:EndpointLogonActivity }
    #     }
    # }
}    





if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedItemsList -match 'Endpoint') {
    if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Completed: Individual Execution")
    }
    elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Session Based') {
        $PSSession | Remove-PSSession
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "$PSSession | Remove-Session"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Completed: Removed PS Sessions")
    }
}


####################################################################################################
####################################################################################################
##                                                                                                ##
##  Active Directory Collection                                                                   ##
##                                                                                                ##
####################################################################################################
####################################################################################################
Generate-ComputerList

if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedItemsList -match 'Active Directory'){
    if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Individual Exeuction")
    }
    elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Session Based') {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Establishing a PS Session with $script:ComputerList")

        if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
            if (!$script:Credential) { Create-NewCredentials }
            $PSSession = New-PSSession -ComputerName $script:ComputerList -Credential $script:Credential
            Create-LogEntry -LogFile $LogFile -Message "New-PSSession -ComputerName $script:ComputerList -Credential $script:Credential"
        }
        else {
            $PSSession = New-PSSession -ComputerName $script:ComputerList 
            Create-LogEntry -LogFile $LogFile -Message "New-PSSession -ComputerName $script:ComputerList"
        }    
    }
}


####################################################################################################
# Active Directory Users                                                                           #
####################################################################################################

if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedItemsList -contains 'Active Directory Users') {
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Query: Active Directory Users Data")


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




    if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
        foreach ($TargetComputer in $script:ComputerList) {
            if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { Create-NewCredentials }

                $script:PSWriteHTMLForest = Invoke-Command -ScriptBlock { Get-ADForest } `
                -ComputerName $TargetComputer `
                -Credential $script:Credential
        
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { Get-ADForest } -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)' -Credential `$script:Credential"

                foreach ($Domain in $script:PSWriteHTMLForest.Domains) {
                    $Script:Job = Invoke-Command -ScriptBlock {
                        param($Domain)
                        Get-ADUser -Server $Domain -Filter * -Properties SamAccountName, Name, Enabled, LockedOut, BadLogonCount, SmartcardLogonRequired, PasswordNotRequired, PasswordNeverExpires, PasswordExpired, LastBadPasswordAttempt, PasswordLastSet, AccountExpirationDate, WhenCreated, WhenChanged, LastLogonDate, MemberOf, Description, Certificates, DistinguishedName, SID | Select-Object SamAccountName, Name, Enabled, LockedOut, BadLogonCount, SmartcardLogonRequired, PasswordNotRequired, PasswordNeverExpires, PasswordExpired, LastBadPasswordAttempt, PasswordLastSet, AccountExpirationDate, WhenCreated, WhenChanged, LastLogonDate, MemberOf, Description, Certificates, DistinguishedName, SID
                    } `
                    -ArgumentList $Domain `
                    -ComputerName $TargetComputer `
                    -Credential $script:Credential `
                    -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"
            
                    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock {param($Domain); Get-ADUser -Server $Domain -Filter * -Properties SamAccountName, Name, Enabled, LockedOut, BadLogonCount, SmartcardLogonRequired, PasswordNotRequired, PasswordNeverExpires, PasswordExpired, LastBadPasswordAttempt, PasswordLastSet, AccountExpirationDate, WhenCreated, WhenChanged, LastLogonDate, MemberOf, Description, Certificates, DistinguishedName, SID | Select-Object SamAccountName, Name, Enabled, LockedOut, BadLogonCount, SmartcardLogonRequired, PasswordNotRequired, PasswordNeverExpires, PasswordExpired, LastBadPasswordAttempt, PasswordLastSet, AccountExpirationDate, WhenCreated, WhenChanged, LastLogonDate, MemberOf, Description, Certificates, DistinguishedName, SID} -ArgumentList $Domain -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)' -Credential `$script:Credential"
                }
            }
            else {
                $script:PSWriteHTMLForest = Invoke-Command -ScriptBlock { Get-ADForest } `
                -ComputerName $TargetComputer
                            
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { Get-ADForest } -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)'"


                foreach ($Domain in $script:PSWriteHTMLForest.Domains) {
                    $Script:Job = Invoke-Command -ScriptBlock {
                        param($Domain)
                        Get-ADUser -Server $Domain -Filter * -Properties SamAccountName, Name, Enabled, LockedOut, BadLogonCount, SmartcardLogonRequired, PasswordNotRequired, PasswordNeverExpires, PasswordExpired, LastBadPasswordAttempt, PasswordLastSet, AccountExpirationDate, WhenCreated, WhenChanged, LastLogonDate, MemberOf, Description, Certificates, DistinguishedName, SID | Select-Object SamAccountName, Name, Enabled, LockedOut, BadLogonCount, SmartcardLogonRequired, PasswordNotRequired, PasswordNeverExpires, PasswordExpired, LastBadPasswordAttempt, PasswordLastSet, AccountExpirationDate, WhenCreated, WhenChanged, LastLogonDate, MemberOf, Description, Certificates, DistinguishedName, SID
                    } `
                    -ArgumentList $Domain `
                    -ComputerName $TargetComputer `
                    -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"
                                
                    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock {param($Domain); Get-ADUser -Server $Domain -Filter * -Properties SamAccountName, Name, Enabled, LockedOut, BadLogonCount, SmartcardLogonRequired, PasswordNotRequired, PasswordNeverExpires, PasswordExpired, LastBadPasswordAttempt, PasswordLastSet, AccountExpirationDate, WhenCreated, WhenChanged, LastLogonDate, MemberOf, Description, Certificates, DistinguishedName, SID | Select-Object SamAccountName, Name, Enabled, LockedOut, BadLogonCount, SmartcardLogonRequired, PasswordNotRequired, PasswordNeverExpires, PasswordExpired, LastBadPasswordAttempt, PasswordLastSet, AccountExpirationDate, WhenCreated, WhenChanged, LastLogonDate, MemberOf, Description, Certificates, DistinguishedName, SID} -ArgumentList $Domain -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)'"
                }
            }
        }
        Monitor-Jobs -CollectionName $CollectionName -MonitorMode -PSWriteHTMLSwitch -PSWriteHTML 'PSWriteHTMLADUsers' -PSWriteHTMLFilePath $script:PSWriteHTMLFilePath
    }
    elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Session Based') {
        $script:PSWriteHTMLForest = invoke-command -ScriptBlock { Get-ADForest } -Session $PSSession
        
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { Get-ADForest } -Session $PSSession"

        foreach ($Domain in $script:PSWriteHTMLForest.Domains) {
            $script:PSWriteHTMLADUsers = invoke-command -ScriptBlock {
                param($Domain)
                Get-ADUser -Server $Domain -Filter * -Properties SamAccountName, Name, Enabled, LockedOut, BadLogonCount, SmartcardLogonRequired, PasswordNotRequired, PasswordNeverExpires, PasswordExpired, LastBadPasswordAttempt, PasswordLastSet, AccountExpirationDate, WhenCreated, WhenChanged, LastLogonDate, MemberOf, Description, Certificates, DistinguishedName, SID | Select-Object SamAccountName, Name, Enabled, LockedOut, BadLogonCount, SmartcardLogonRequired, PasswordNotRequired, PasswordNeverExpires, PasswordExpired, LastBadPasswordAttempt, PasswordLastSet, AccountExpirationDate, WhenCreated, WhenChanged, LastLogonDate, MemberOf, Description, Certificates, DistinguishedName, SID
            } -ArgumentList $Domain -Session $PSSession
        }
    }
}





























####################################################################################################
# Active Directory Computers                                                                       #
####################################################################################################

if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedItemsList -contains 'Active Directory Computers') {
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Query: Active Directory Computer Data")


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


    if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
        foreach ($TargetComputer in $script:ComputerList) {
            if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { Create-NewCredentials }

                $script:PSWriteHTMLForest = Invoke-Command -ScriptBlock { Get-ADForest } `
                -ComputerName $TargetComputer `
                -Credential $script:Credential
        
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { Get-ADForest } -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)' -Credential `$script:Credential"


                foreach ($Domain in $script:PSWriteHTMLForest.Domains) {
                    Invoke-Command -ScriptBlock {
                        param($Domain)
                        Get-ADComputer -Server $Domain -Filter * -Properties DNSHostName, Name, LogonCount, IPv4Address, IPv6Address, Enabled, OperatingSystem, OperatingSystemVersion, OperatingSystemHotfix, OperatingSystemServicePack, LastLogonDate, WhenCreated, WhenChanged, PasswordLastSet, PasswordExpired, LockedOut, DistinguishedName, MemberOf, PrimaryGroupID, SID | Select-Object DNSHostName, Name, LogonCount, IPv4Address, IPv6Address, Enabled, OperatingSystem, OperatingSystemVersion, OperatingSystemHotfix, OperatingSystemServicePack, LastLogonDate, WhenCreated, WhenChanged, PasswordLastSet, PasswordExpired, LockedOut, DistinguishedName, MemberOf, PrimaryGroupID, SID        
                    } `
                    -ArgumentList $Domain `
                    -ComputerName $TargetComputer `
                    -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
                    -Credential $script:Credential
            
                    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock {param($Domain); Get-ADComputer -Server $Domain -Filter * -Properties DNSHostName, Name, LogonCount, IPv4Address, IPv6Address, Enabled, OperatingSystem, OperatingSystemVersion, OperatingSystemHotfix, OperatingSystemServicePack, LastLogonDate, WhenCreated, WhenChanged, PasswordLastSet, PasswordExpired, LockedOut, DistinguishedName, MemberOf, PrimaryGroupID, SID | Select-Object DNSHostName, Name, LogonCount, IPv4Address, IPv6Address, Enabled, OperatingSystem, OperatingSystemVersion, OperatingSystemHotfix, OperatingSystemServicePack, LastLogonDate, WhenCreated, WhenChanged, PasswordLastSet, PasswordExpired, LockedOut, DistinguishedName, MemberOf, PrimaryGroupID, SID} -ArgumentList $Domain -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)' -Credential `$script:Credential"
                }
            }
            else {
                $script:PSWriteHTMLForest = Invoke-Command -ScriptBlock { Get-ADForest } `
                -ComputerName $TargetComputer
                            
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { Get-ADForest } -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)'"


                foreach ($Domain in $script:PSWriteHTMLForest.Domains) {
                    Invoke-Command -ScriptBlock {
                        param($Domain)
                        Get-ADComputer -Server $Domain -Filter * -Properties DNSHostName, Name, LogonCount, IPv4Address, IPv6Address, Enabled, OperatingSystem, OperatingSystemVersion, OperatingSystemHotfix, OperatingSystemServicePack, LastLogonDate, WhenCreated, WhenChanged, PasswordLastSet, PasswordExpired, LockedOut, DistinguishedName, MemberOf, PrimaryGroupID, SID | Select-Object DNSHostName, Name, LogonCount, IPv4Address, IPv6Address, Enabled, OperatingSystem, OperatingSystemVersion, OperatingSystemHotfix, OperatingSystemServicePack, LastLogonDate, WhenCreated, WhenChanged, PasswordLastSet, PasswordExpired, LockedOut, DistinguishedName, MemberOf, PrimaryGroupID, SID        
                    } `
                    -ArgumentList $Domain `
                    -ComputerName $TargetComputer `
                    -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"
                                
                    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock {param($Domain); Get-ADComputer -Server $Domain -Filter * -Properties DNSHostName, Name, LogonCount, IPv4Address, IPv6Address, Enabled, OperatingSystem, OperatingSystemVersion, OperatingSystemHotfix, OperatingSystemServicePack, LastLogonDate, WhenCreated, WhenChanged, PasswordLastSet, PasswordExpired, LockedOut, DistinguishedName, MemberOf, PrimaryGroupID, SID | Select-Object DNSHostName, Name, LogonCount, IPv4Address, IPv6Address, Enabled, OperatingSystem, OperatingSystemVersion, OperatingSystemHotfix, OperatingSystemServicePack, LastLogonDate, WhenCreated, WhenChanged, PasswordLastSet, PasswordExpired, LockedOut, DistinguishedName, MemberOf, PrimaryGroupID, SID} -ArgumentList $Domain -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)'"
                }
            }
        }
        Monitor-Jobs -CollectionName $CollectionName -MonitorMode -PSWriteHTMLSwitch -PSWriteHTML 'PSWriteHTMLADComputers' -PSWriteHTMLFilePath $script:PSWriteHTMLFilePath
    }
    elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Session Based') {
        $script:PSWriteHTMLForest = invoke-command -ScriptBlock { Get-ADForest } -Session $PSSession

        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { Get-ADForest } -Session $PSSession"


        foreach ($Domain in $script:PSWriteHTMLForest.Domains) {
            $script:PSWriteHTMLADComputers = Invoke-Command -ScriptBlock {
                param($Domain)
                Get-ADComputer -Server $Domain -Filter * -Properties DNSHostName, Name, LogonCount, IPv4Address, IPv6Address, Enabled, OperatingSystem, OperatingSystemVersion, OperatingSystemHotfix, OperatingSystemServicePack, LastLogonDate, WhenCreated, WhenChanged, PasswordLastSet, PasswordExpired, LockedOut, DistinguishedName, MemberOf, PrimaryGroupID, SID | Select-Object DNSHostName, Name, LogonCount, IPv4Address, IPv6Address, Enabled, OperatingSystem, OperatingSystemVersion, OperatingSystemHotfix, OperatingSystemServicePack, LastLogonDate, WhenCreated, WhenChanged, PasswordLastSet, PasswordExpired, LockedOut, DistinguishedName, MemberOf, PrimaryGroupID, SID
            } -ArgumentList $Domain -Session $PSSession
        }
    }
}








if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedItemsList -match 'Active Directory') {    
    if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Completed: Individual Execution")    
    }
    elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Session Based') {
        $PSSession | Remove-PSSession
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "$PSSession | Remove-Session"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Completed: Removed PS Sessions")    
    }
}
































####################################################################################################
####################################################################################################
##                                                                                                ##
## PSWriteHTML Launcher                                                                           ##
##                                                                                                ##
####################################################################################################
####################################################################################################


if ($PSWriteHTMLCheckedListBox.CheckedItems.Count -gt 0 -and `
    $script:PSWriteHTMLFormOkay -eq $true -and `
    $script:ComputerList.count -gt 0 -and `
    ($PSWriteHTMLCheckedItemsList -match 'Endpoint' -or $PSWriteHTMLCheckedItemsList -match 'Active Directory')
    ) {
    ##################################
    # Launches One Compiled Web Page #
    ##################################
    if ($script:PSWriteHTMLIndividualWebPagesCheckbox.checked -eq $false -and $script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Session Based') {
        New-HTML -TitleText 'PoSh-EasyWin' -FavIcon "$Dependencies\Images\favicon.jpg" -Online `
            -FilePath $script:PSWriteHTMLFilePath {
                #-Show
            New-HTMLHeader { 
                New-HTMLText -Text "Date of this report $(Get-Date)" -Color Blue -Alignment right 

                New-HTMLLogo  -LeftLogoString "$Dependencies\Images\PoSh-EasyWin Image 01.png"
            }

            New-HTMLTabStyle -SlimTabs -Transition -LinearGradient -SelectorColor DarkBlue -SelectorColorTarget Blue -BorderRadius 25px -BorderBackgroundColor LightBlue


            if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedItemsList -contains 'Endpoint Process Data') {
                script:Invoke-PSWriteHTMLProcess -InputData $script:PSWriteHTMLProcesses
            } 
            if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedItemsList -contains 'Endpoint Network Connections') {
                script:Invoke-PSWriteHTMLNetworkConnections -InputData $script:EndpointDataNetworkConnections
            }
            if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedItemsList -contains 'Endpoint Console Logons') {
                script:Invoke-PSWriteHTMLConsoleLogons -InputData $script:EndpointDataConsoleLogons
            }
            if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedItemsList -contains 'Endpoint PowerShell Sessions') {
                script:Invoke-PSWriteHTMLPowerShellSessions -InputData $script:PowerShellSessionsData
            } 
            if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedItemsList -contains 'Endpoint Logon Activity (30 Days)') {
                script:Invoke-PSWriteHTMLLogonActivity -InputData $script:EndpointLogonActivity
            }
            if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedItemsList -match 'Active Directory'){
                script:Start-PSWriteHTMLActiveDirectory
            }


            New-HTMLFooter { 
                New-HTMLText `
                    -FontSize 12 `
                    -FontFamily 'Source Sans Pro' `
                    -Color Black `
                    -Text 'Disclaimer: The information provided by PoSh-EasyWin is for general information purposes only. All data collected And represented is provided and done so in good faith, however we make no representation, guarentee, or warranty of any kind, expressed or implied, regarding the accuracy, adequacy, validity, reliability, availability, or completeness of any infomration collected or represented.' `
                    -Alignment left
                New-HTMLText `
                    -Text "https://www.GitHub.com/high101bro/PoSh-EasyWin" `
                    -Color Blue `
                    -Alignment right 
            }
        }
    }
}


if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedItemsList.count -gt 0) {
    $script:ProgressBarQueriesProgressBar.Value = $script:ProgressBarQueriesProgressBar.Maximum
    $script:ProgressBarQueriesProgressBar.Refresh()
}

if ($script:RollCredentialsState -and $script:ComputerListProvideCredentialsCheckBox.checked) {
    Start-Sleep -Seconds 3
    Generate-NewRollingPassword
}



    
}

$PSWriteHTMLButtonAdd_MouseHover = {
    Show-ToolTip -Title "Graph Data" -Icon "Info" -Message @"
+  Utilizes the PSWriteHTML module to generate graph data in a web browser.
+  Requires that the PSWriteHTML module is loaded 
+  Requires PowerShell v5.1+
"@
}


