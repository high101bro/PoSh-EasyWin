$PSWriteHTMLButtonAdd_Click = {

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
    'Endpoint Application Crashes (30 Days)'
)
#'Endpoint SMB Server Connections',

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

        if ($PSWriteHTMLCheckedListBox.CheckedItems.Count -eq 1) {
            Generate-ComputerList
            if ($script:ComputerList.count -eq 0) {
                [System.Windows.Forms.MessageBox]::Show("Checkbox at least one endpoint from the computer treeview.",'PoSh-EasyWin')
            }
            else {
                $script:PSWriteHTMLFormOkay = $true
                $PSWriteHTMLForm.Close()    
            }
        }
        elseif ($PSWriteHTMLCheckedListBox.CheckedItems.Count -gt 2) {
            [System.Windows.Forms.MessageBox]::Show("Checkbox only one option from the list to collect data.",'PoSh-EasyWin')
        }
        else {
            [System.Windows.Forms.MessageBox]::Show("Checkbox one option from the list to collect data.",'PoSh-EasyWin')
        }
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


if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedItemsList -contains 'Endpoint Network Connections') {
    $script:PSWriteHTMLSupportForm = New-Object System.Windows.Forms.Form -Property @{
        Text    = 'PoSh-EasyWin'
        Width   = $FormScale * 325
        Height  = $FormScale * 350
        StartPosition = "CenterScreen"
        TopMost = $false
        Icon    = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        Font    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        FormBorderStyle =  'Sizable' #  Fixed3D, FixedDialog, FixedSingle, FixedToolWindow, None, Sizable, SizableToolWindow
        ShowIcon        = $true
        showintaskbar   = $false
        ControlBox      = $true
        MaximizeBox     = $false
        MinimizeBox     = $true
        AutoScroll      = $True
        Add_Closing = { $This.dispose() }
    }


    $script:PoShEasyWinIPToExcludeLabel = New-Object System.Windows.Forms.Label -Property @{
        Text   = "Enter PoSh-EasyWin's IP. This will place it as an icon within various graphs for easy recognition, like network connections."
        Left   = $FormScale * 5
        Top    = $FormScale * 5
        Width  = $FormScale * 280
        Height = $FormScale * 40
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:PSWriteHTMLSupportForm.Controls.Add($script:PoShEasyWinIPToExcludeLabel)


                $script:ConnectionStatesFilterCheckedListBox = New-Object -TypeName System.Windows.Forms.CheckedListBox -Property @{
                    Left   = $script:PoShEasyWinIPToExcludeLabel.Left
                    Top    = $script:PoShEasyWinIPToExcludeLabel.Top + $script:PoShEasyWinIPToExcludeLabel.Height
                    Width  = $script:PoShEasyWinIPToExcludeLabel.Width
                    Height = $FormScale * 90
                    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                    ScrollAlwaysVisible = $true
                }
                $ConnectionFilterStates = @('Established','TimeWait','CloseWait','Listen','Bound','All Others: Closed,Closing,DeleteTCB,FinWait1,FinWait2,LastAck,SynReceived,SynSent')
                        foreach ( $State in $ConnectionFilterStates ) { 
                            $script:ConnectionStatesFilterCheckedListBox.Items.Add($State) 
                        }                
                        if ((Test-Path "$PoShHome\Settings\Network Connection Selected States.txt")){
                            $ConnectionFilterStatesImportedChecked = Get-Content "$PoShHome\Settings\Network Connection Selected States.txt"
                            foreach ($State in $ConnectionFilterStatesImportedChecked) {
                                Set-CheckState -Check -CheckedlistBox $script:ConnectionStatesFilterCheckedListBox -Match $State
                            }
                            $script:PSWriteHTMLSupportForm.Controls.Add($script:ConnectionStatesFilterCheckedListBox)
                        }
                        else {
                            $ConnectionFilterStatesDefaultChecked = @('Established','TimeWait','CloseWait')
                            foreach ($State in $ConnectionFilterStatesDefaultChecked) {
                                Set-CheckState -Check -CheckedlistBox $script:ConnectionStatesFilterCheckedListBox -Match $State
                            }
                            $script:PSWriteHTMLSupportForm.Controls.Add($script:ConnectionStatesFilterCheckedListBox)    
                        }

    
                $script:PSWriteHTMLResolveDNSCheckbox = New-Object System.Windows.Forms.checkbox -Property @{
                    Text   = "Resolve DNS"
                    Left   = $script:ConnectionStatesFilterCheckedListBox.Left
                    Top    = $script:ConnectionStatesFilterCheckedListBox.Top + $script:ConnectionStatesFilterCheckedListBox.Height
                    Width  = $script:ConnectionStatesFilterCheckedListBox.Width / 3
                    Height = $FormScale * 22
                    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                    checked = $false
                }
                $script:PSWriteHTMLSupportForm.Controls.Add($script:PSWriteHTMLResolveDNSCheckbox)


                            $script:PSWriteHTMLNameServerLabel = New-Object System.Windows.Forms.Label -Property @{
                                Text   = "Name Server:"
                                Left   = $script:PSWriteHTMLResolveDNSCheckbox.Left + $script:PSWriteHTMLResolveDNSCheckbox.Width
                                Top    = $script:PSWriteHTMLResolveDNSCheckbox.Top + ($FormScale * 4)
                                Width  = $script:PSWriteHTMLResolveDNSCheckbox.Width
                                Height = $FormScale * 22
                                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                            }
                            $script:PSWriteHTMLSupportForm.Controls.Add($script:PSWriteHTMLNameServerLabel)


                            $script:PSWriteHTMLNameServerTextBox = New-Object System.Windows.Forms.TextBox -Property @{
                                Text   = "Disabled"
                                Left   = $script:PSWriteHTMLNameServerLabel.Left + $script:PSWriteHTMLNameServerLabel.Width
                                Top    = $script:PSWriteHTMLNameServerLabel.Top
                                Width  = $script:PSWriteHTMLNameServerLabel.Width - ($FormScale * 5)
                                Height = $FormScale * 22
                                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                                Enabled = $false
                            }
                            $script:PSWriteHTMLSupportForm.Controls.Add($script:PSWriteHTMLNameServerTextBox)


                $script:PSWriteHTMLExcludeIPv6FromGraphsCheckbox = New-Object System.Windows.Forms.checkbox -Property @{
                    Text    = "Exclude IPv6"
                    Left    = $script:PSWriteHTMLResolveDNSCheckbox.Left
                    Top     = $script:PSWriteHTMLResolveDNSCheckbox.Top + $script:PSWriteHTMLResolveDNSCheckbox.Height
                    Width   = $script:PSWriteHTMLResolveDNSCheckbox.Width
                    Height  = $FormScale * 22
                    Font    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                    checked = $true
                }
                $script:PSWriteHTMLSupportForm.Controls.Add($script:PSWriteHTMLExcludeIPv6FromGraphsCheckbox)


                $script:PSWriteHTMLExcludeEasyWinFromGraphsCheckbox = New-Object System.Windows.Forms.checkbox -Property @{
                    Text    = "Exclude the following from the Graphs"
                    Left    = $script:PSWriteHTMLExcludeIPv6FromGraphsCheckbox.Left
                    Top     = $script:PSWriteHTMLExcludeIPv6FromGraphsCheckbox.Top + $script:PSWriteHTMLExcludeIPv6FromGraphsCheckbox.Height
                    Width   = $script:ConnectionStatesFilterCheckedListBox.Width
                    Height  = $FormScale * 22
                    Font    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                    checked = $true
                }
                $script:PSWriteHTMLSupportForm.Controls.Add($script:PSWriteHTMLExcludeEasyWinFromGraphsCheckbox)


                $script:IPAddressesToExcludeTextbox = New-Object System.Windows.Forms.TextBox -Property @{
                    Left   = $script:PSWriteHTMLExcludeEasyWinFromGraphsCheckbox.Left
                    Top    = $script:PSWriteHTMLExcludeEasyWinFromGraphsCheckbox.Top + $script:PSWriteHTMLExcludeEasyWinFromGraphsCheckbox.Height
                    Width  = $script:PoShEasyWinIPToExcludeLabel.Width
                    Height = $FormScale * 80
                    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                    Multiline  = $true
                    ScrollBars = 'Vertical'
            #        ScrollAlwaysVisible = $true
                }
                $script:PSWriteHTMLSupportForm.Controls.Add($script:IPAddressesToExcludeTextbox)
                if ((Test-Path "$PoShHome\Settings\Network Connection IP's to Exclude.txt")){
                    $script:IPAddressesToExcludeTextbox.text = ''
                    foreach ($line in (Get-Content "$PoShHome\Settings\Network Connection IP's to Exclude.txt")) {
                        $script:IPAddressesToExcludeTextbox.text += "$line`r`n"
                    }
                }
                else {
                    $DefaultIPListToExclude = @('127.0.0.1','0.0.0.0','::1','::')
                    $script:IPAddressesToExcludeTextbox.text = ''
                    foreach ($IP in $DefaultIPListToExclude) {
                        $script:IPAddressesToExcludeTextbox.text += "$IP`r`n"
                    }                    
                }


    # $script:PSWriteHTMLSupportOkayLabel = New-Object System.Windows.Forms.Label -Property @{
    #     Text   = "Enter the Domain Controller's hostname or IP Address. This is used to pull back domain level data if an Active Directory option was selected."
    #     Left   = $script:IPAddressesToExcludeTextbox.Left
    #     Top    = $script:IPAddressesToExcludeTextbox.Top + $script:IPAddressesToExcludeTextbox.Height
    #     Width  = $script:IPAddressesToExcludeTextbox.Width
    #     Height = $FormScale * 44
    #     Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    # }
    # $script:PSWriteHTMLSupportForm.Controls.Add($script:PSWriteHTMLSupportOkayLabel)

    
    #             $script:PSWriteHTMLSupportOkayTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    #                 Text   = "<Enter the Domain Controller's hostname/IP>"
    #                 Left   = $script:PSWriteHTMLSupportOkayLabel.Left
    #                 Top    = $script:PSWriteHTMLSupportOkayLabel.Top + $script:PSWriteHTMLSupportOkayLabel.Height
    #                 Width  = $script:IPAddressesToExcludeTextbox.Width
    #                 Height = $FormScale * 22
    #                 Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    #                 Multiline = $true
    #             }
    #             $script:PSWriteHTMLSupportForm.Controls.Add($script:PSWriteHTMLSupportOkayTextBox)
    #             if ((Test-Path "$PoShHome\Settings\Domain Controller Selected.txt")){
    #                 $script:PSWriteHTMLSupportOkayTextBox.text = Get-Content "$PoShHome\Settings\Domain Controller Selected.txt"
    #             }


    $script:PSWriteHTMLSupportOkay = $False
    $PSWriteHTMLSupportOkayButton = New-Object System.Windows.Forms.Button -Property @{
        Text   = 'Okay'
        Left   = $script:IPAddressesToExcludeTextbox.Left
        Top    = $script:IPAddressesToExcludeTextbox.Top + $script:IPAddressesToExcludeTextbox.Height + $($FormScale * 5)
        Width  = $FormScale * 100
        Height = $FormScale * 22
        Add_Click = {
            $script:ConnectionStatesFilterCheckedListBox.CheckedItems | Set-Content "$PoShHome\Settings\Network Connection Selected States.txt"

            $script:IPAddressesToExcludeTextbox.text | Set-Content "$PoShHome\Settings\Network Connection IP's to Exclude.txt"
            $script:PoShEasyWinIPAddress   = ($script:IPAddressesToExcludeTextbox.text).split() | Where-Object {$_ -ne '' -or $_ -ne $null}
            $script:PSWriteHTMLSupportOkay = $True

            # #Checks if the computer entered is in the computer treeview  
            # $ComputerNodeFound = $false
            # [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
            # foreach ($root in $AllTreeViewNodes) {
            #     foreach ($Category in $root.Nodes) {
            #         foreach ($Entry in $Category.nodes) { 
            #             if ($Entry.Text -eq $script:PSWriteHTMLSupportOkayTextBox.text){
            #                 $ComputerNodeFound = $true 
            #             }
            #         }
            #     }
            # }
            
            # if (-not $ComputerNodeFound) {
            #     [System.Windows.Forms.MessageBox]::Show('The hostname entered was not found within the computer treeview.','PoSh-EasyWin','Ok','Warning')
            # }
            # else {
            #     $script:PSWriteHTMLSupportOkayTextBox.text | Set-Content "$PoShHome\Settings\Domain Controller Selected.txt"
            #     $script:DomainControllerComputerName = $script:PSWriteHTMLSupportOkayTextBox.text
            #     $script:PSWriteHTMLSupportForm.close()
            # }
            $script:PSWriteHTMLSupportForm.close()
        }
    }
    $script:PSWriteHTMLSupportForm.Controls.Add($PSWriteHTMLSupportOkayButton)
    CommonButtonSettings -Button $PSWriteHTMLSupportOkayButton

    $script:PSWriteHTMLSupportForm.ShowDialog()
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
    
        if ($ComputerListProvideCredentialsCheckBox.Checked) {
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
    # Process Data                                                                                     #
    ####################################################################################################
    if ($PSWriteHTMLCheckedItemsList -contains 'Endpoint Process Data') {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Query: Endpoint Process Data")


        function script:Start-PSWriteHTMLProcessData {

            $ProcessesTotalMemoryPerHost = $script:PSWriteHTMLProcesses | Select-Object pscomputername, workingset | Sort-Object PScomputerName | Group-Object pscomputername | Foreach-Object {[PSCustomObject]@{Name=$_.group.pscomputername[0];count=(($_.group.workingset | Measure-Object -Sum).Sum)}} | Sort-Object Count, Name -Descending
            $ProcessesCountPerHost = $script:PSWriteHTMLProcesses | Select-Object PSComputerName, ProcessID | Group-Object PSComputerName | Sort-Object Count, Name -Descending
            $ProcessesUnique = $script:PSWriteHTMLProcesses | Select-Object PSComputerName, ProcessName -Unique | Where-Object {$_.ProcessName -ne $null} | Group-Object ProcessName | Sort-Object Count, Name
                $ProcessesNetworkConnections = $script:PSWriteHTMLProcesses | Select-Object PSComputerName, NetworkConnections -unique | Where-Object {$_.NetworkConnections -ne $null} | Group-Object NetworkConnections | Sort-Object Count, Name
                $ProcessesServicesStarted = $script:PSWriteHTMLProcesses | Select-Object PSComputerName, ServiceInfo -unique | Where-Object {$_.ServiceInfo -ne $null} | Group-Object ServiceInfo | Sort-Object Count, Name
            $ProcessesCompanyNames = $script:PSWriteHTMLProcesses | Select-Object PSComputerName, Company -unique | Where-Object {$_.Company -ne $null} | Group-Object Company | Sort-Object Count, Name
            $ProcessesProductNames = $script:PSWriteHTMLProcesses | Select-Object PSComputerName, Product -unique | Where-Object {$_.Product -ne $null} | Group-Object Product | Sort-Object Count, Name
            $ProcessesSignerCompany = $script:PSWriteHTMLProcesses | Select-Object PSComputerName, SignerCompany -Unique | Where-Object {$_.SignerCompany -ne $null} | Group-Object SignerCompany | Where-Object {$_.Name -ne ''} | Sort-Object Count, Name
                $ProcessesSignerCertificates = $script:PSWriteHTMLProcesses | Select-Object PSComputerName, SignerCertificate -unique | Where-Object {$_.SignerCertificate -ne $null} | Group-Object SignerCertificate | Sort-Object Count, Name
                $ProcessesPaths = $script:PSWriteHTMLProcesses | Select-Object PSComputerName, Path | Where-Object {$_.Path -ne $null} | Group-Object Path | Sort-Object Count, Name
                $ProcessesMD5Hashes = $script:PSWriteHTMLProcesses | Select-Object PSComputerName, MD5Hash -unique | Where-Object {$_.MD5Hash -ne $null} | Group-Object MD5Hash | Sort-Object Count, Name
            $ProcessesModules = @()
                $script:PSWriteHTMLProcesses | Select-Object pscomputername, processname, modules | Where-Object modules -ne $null | Foreach-Object {$ProcessesModules += $_.modules}
                $ProcessesModules = $ProcessesModules | Group-Object | Sort-Object count
    

            New-HTMLTab -Name 'Process Data' -IconBrands acquisitions-incorporated {
                ###########
                New-HTMLTab -Name 'Table' -IconSolid th {
                    New-HTMLSection -HeaderText 'Table' -Height 725 -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                        New-HTMLTable -DataTable $script:PSWriteHTMLProcesses {
                            New-TableHeader -Color Blue -Alignment left -Title 'Process Data Has Been Enriched With Related Network Connections, Authenticode Signatures, And File Hashes.' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength', 'searchPanes') -SearchRegularExpression
                    }
                }
                ###########
                New-HTMLTab -Name 'Search Pane' -IconSolid th {
                    New-HTMLSection -HeaderText 'Search Pane' -Height 725 -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                        New-HTMLTable -DataTable $script:PSWriteHTMLProcesses {
                            New-TableHeader -Color Blue -Alignment left -Title 'Process Data Has Been Enriched With Related Network Connections, Authenticode Signatures, And File Hashes.' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength', 'searchPanes') -searchpane -SearchRegularExpression
                    }
                }
                ###########
                New-HTMLTab -Name 'Calendar' -IconRegular calendar-alt  {
                    New-HTMLSection -HeaderText 'Calendar' -Height 725 -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                        New-HTMLTable -DataTable $script:PSWriteHTMLProcesses {
                            New-TableHeader -Color Blue -Alignment left -Title 'Calendar - Process Data' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                        New-HTMLCalendar {
                            foreach ($_ in $script:PSWriteHTMLProcesses) {
                                New-CalendarEvent -StartDate $_.StartTime `
                                -Title "$($_.PSComputerName) || $($_.ProcessName):$($_.ProcessID)" `
                                -Description "$($_.PSComputerName) || Process: $($_.ProcessName):$($_.ProcessID) || Start Time: $($_.StartTime) || Parent: $($_.ParentProcessName):$($_.ParentProcessID)"
                            }
                        } -InitialView dayGridMonth #timeGridDay
                    }
                }
                ###########
                New-HTMLTab -Name 'Charts' -IconRegular chart-bar {
                    script:Generate-TablePieBarCharts -Title "Total Memory Per Host" -Data $ProcessesTotalMemoryPerHost
                    script:Generate-TablePieBarCharts -Title "Count Per Host" -Data $ProcessesCountPerHost
                    script:Generate-TablePieBarCharts -Title "Unique Processes" -Data $ProcessesUnique
                    script:Generate-TablePieBarCharts -Title "Processes with Network Connections" -Data $ProcessesNetworkConnections
                    script:Generate-TablePieBarCharts -Title "Services Started by Processes" -Data $ProcessesServicesStarted
                    script:Generate-TablePieBarCharts -Title "Company Names" -Data $ProcessesCompanyNames
                    script:Generate-TablePieBarCharts -Title "Product Names" -Data $ProcessesProductNames
                    script:Generate-TablePieBarCharts -Title "Signer Company" -Data $ProcessesSignerCompany
                    script:Generate-TablePieBarCharts -Title "Signer Certificates" -Data $ProcessesSignerCertificates
                    script:Generate-TablePieBarCharts -Title "Paths" -Data $ProcessesPaths
                    script:Generate-TablePieBarCharts -Title "MD5 Hashes" -Data $ProcessesMD5Hashes
                    script:Generate-TablePieBarCharts -Title "Modules" -Data $ProcessesModules
                }        
                ###########
                New-HTMLTab -TabName 'Graph & Table' -IconSolid bezier-curve {
                    $DataTableIDProcesses1 = Get-Random -Minimum 100000 -Maximum 2000000
                    New-HTMLTab -TabName 'Processes Associated With Endpoints'{
                        New-HTMLSection -HeaderText 'Processes With Associated Started Services And Network Connections' -CanCollapse {
                            New-HTMLPanel -Width 40% {
                                New-HTMLTable -DataTable $script:PSWriteHTMLProcesses -DataTableID $DataTableIDProcesses1 -SearchRegularExpression  {
                                    New-TableHeader -Color Blue -Alignment left -Title 'Processes Associated With Endpoints' -FontSize 18 
                                } 
                            }
                            New-HTMLPanel {
                                New-HTMLText `
                                    -FontSize 12 `
                                    -FontFamily 'Source Sans Pro' `
                                    -Color Blue `
                                    -Text 'Click On The Process Icons To Automatically Locate Them Within The Table'
        
                                New-HTMLDiagram -Height '1000px' {
                                    New-DiagramEvent -ID $DataTableIDProcesses1 -ColumnID 1
                                    New-DiagramOptionsInteraction -Hover $true
                                    New-DiagramOptionsManipulation
                                    New-DiagramOptionsPhysics -Enabled $true
                                    New-DiagramOptionsLayout `
                                        -RandomSeed 13
                                    New-DiagramOptionsNodes `
                                        -BorderWidth 1 `
                                        -ColorBackground LightSteelBlue `
                                        -ColorHighlightBorder Orange `
                                        -ColorHoverBackground Orange
                                    New-DiagramOptionsLinks `
                                        -FontSize 12 `
                                        -ColorHighlight Orange `
                                        -ColorHover Orange `
                                        -Length 5000
                                        # -ArrowsToEnabled $true `
                                        # -Color BlueViolet `
                                        # -ArrowsToType arrow `
                                        # -ArrowsFromEnabled $false `
                                    New-DiagramOptionsEdges `
                                        -ColorHighlight Orange `
                                        -ColorHover Orange
                                    $list = @()
                                    foreach ($_ in $script:PSWriteHTMLProcesses) {
                                        New-DiagramNode `
                                            -Label $_.ProcessName `
                                            -To $_.PSComputerName `
                                            -IconRegular file-alt `
                                            -Size 35
                                        if ($_.ServiceInfo -ne $null) {
                                            $Service = ($_.ServiceInfo -split ' ')[0]
                                            $ServiceInfo = (($_.ServiceInfo -split ' ')[1..10] -join ' ').replace('[','').replace(']','')
                                            New-DiagramNode `
                                                -Label "[$($_.PSComputername)]`nService Started: $($Service)`n$($ServiceInfo)" `
                                                -To "[$($_.PSComputername)]`n$($_.ProcessName)" `
                                                -Size 10 `
                                                -Shape triangle `
                                                -ColorBackground Cyan `
                                                -ColorBorder LightBlue
                                        }
                                        if ("[$($_.PSComputername)]`n$($_.ProcessName)" -notin $list) {
                                            New-DiagramNode `
                                                -Label "[$($_.PSComputername)]`n$($_.ProcessName)" `
                                                -To $_.ProcessName `
                                                -size 25 `
                                                -Image "$Dependencies\Images\Computer.jpg" `
                                                -ColorBackground AliceBlue
                                            $list += "[$($_.PSComputername)]`n$($_.ProcessName)"
                                        }
                                        if ($_.NetworkConnections -ne $null) {
                                            if ($_.NetworkConnections -match 'Establish') {
                                                New-DiagramNode `
                                                    -Label "[$($_.PSComputername)]`nNetwork Connection`nEstablished`nPID: $($_.ProcessID)" `
                                                    -To "[$($_.PSComputername)]`n$($_.ProcessName)" `
                                                    -Size 10 `
                                                    -Shape dot `
                                                    -ColorBackground LightCoral `
                                                    -ColorBorder Red
                                            }
                                            if ($_.NetworkConnections -match 'Listen') {
                                                New-DiagramNode `
                                                    -Label "[$($_.PSComputername)]`nNetwork Connection`nListening`nPID: $($_.ProcessID)" `
                                                    -To "[$($_.PSComputername)]`n$($_.ProcessName)" `
                                                    -Size 10 `
                                                    -Shape dot `
                                                    -ColorBackground Yellow `
                                                    -ColorBorder Orange
                                            }
                                            if ($_.NetworkConnections -match 'Bound') {
                                                New-DiagramNode `
                                                    -Label "[$($_.PSComputername)]`nNetwork Connection`nBound`nPID: $($_.ProcessID)" `
                                                    -To "[$($_.PSComputername)]`n$($_.ProcessName)" `
                                                    -Size 10 `
                                                    -Shape dot `
                                                    -ColorBackground LightSteelBlue `
                                                    -ColorBorder Blue
                                            }
                                            if ($_.NetworkConnections -match 'CloseWait') {
                                                New-DiagramNode `
                                                    -Label "[$($_.PSComputername)]`nNetwork Connection`nCloseWait`nPID: $($_.ProcessID)" `
                                                    -To "[$($_.PSComputername)]`n$($_.ProcessName)" `
                                                    -Size 10 `
                                                    -Shape dot `
                                                    -ColorBackground LightGreen `
                                                    -ColorBorder Green
                                            }
                                            if ($_.NetworkConnections -match 'Timeout') {
                                                New-DiagramNode `
                                                    -Label "[$($_.PSComputername)]`nNetwork Connection`nTimeout`nPID: $($_.ProcessID)" `
                                                    -To "[$($_.PSComputername)]`n$($_.ProcessName)" `
                                                    -Size 10 `
                                                    -Shape dot `
                                                    -ColorBackground Violet `
                                                    -ColorBorder DarkViolet
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
        
                    $DataTableIDProcesses2 = Get-Random -Minimum 100000 -Maximum 2000000
                    New-HTMLTab -TabName 'Process Tree Represenation' {
                        New-HTMLSection -HeaderText 'Graph' -CanCollapse {
                            New-HTMLPanel -Width 40% {
                                New-HTMLTable -DataTable $script:PSWriteHTMLProcesses -DataTableID $DataTableIDProcesses2 -SearchRegularExpression  {
                                    New-TableHeader -Color Blue -Alignment left -Title 'Processes Associated With Endpoints' -FontSize 18 
                                } 
                            }
                            New-HTMLPanel {
                                New-HTMLText `
                                    -FontSize 12 `
                                    -FontFamily 'Source Sans Pro' `
                                    -Color Blue `
                                    -Text 'Click On The Computer Icons To Automatically Locate Them Within The Table'
        
                                New-HTMLDiagram -Height '1000px' {
                                    New-DiagramEvent -ID $DataTableIDProcesses2 -ColumnID 2
                                    New-DiagramOptionsInteraction
                                    New-DiagramOptionsManipulation
                                    New-DiagramOptionsPhysics
                                    New-DiagramOptionsLayout `
                                        -RandomSeed 13
                                    New-DiagramOptionsNodes `
                                        -BorderWidth 1 `
                                        -ColorBackground LightSteelBlue `
                                        -ColorHighlightBorder Orange `
                                        -ColorHoverBackground Orange
                                    New-DiagramOptionsLinks `
                                        -ColorHighlight Orange `
                                        -ColorHover Orange
                                    New-DiagramOptionsEdges `
                                        -ColorHighlight Orange `
                                        -ColorHover Orange
        
                                    foreach ($object in $script:PSWriteHTMLProcesses) {
                                        if ($object.level -eq 0) {
                                            New-DiagramNode `
                                                -Label  $object.PSComputerName `
                                                -To     "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                                -Image  "$Dependencies\Images\Computer.jpg" `
                                                -Size   35 `
                                                -FontSize   20 `
                                                -FontColor  Blue `
                                                -LinkColor  Blue `
                                                -ArrowsToEnabled
                                            New-DiagramNode `
                                                -Label  "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                                -Image  "$Dependencies\Images\Process.jpg" `
                                                -size   15 `
                                                -LinkColor  Blue `
                                                -ArrowsToEnabled
                                            if ($object.ServiceInfo) {
                                                New-DiagramNode `
                                                    -Label  "[$($object.PSComputerName)]`nService: $(($object.ServiceInfo -split ' ')[0])`n$((($object.ServiceInfo -split ' ')[1..$object.ServiceInfo.length] -join ' ') -replace '[','' -replace ']','')" `
                                                    -To     "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                                    -Shape  triangle `
                                                    -size   10 `
                                                    -ColorBackground  Cyan `
                                                    -LinkColor        Cyan `
                                                    -ArrowsFromEnabled
                                            }
                                            if ($object.NetworkConnections) {
                                                foreach ($connection in $($object.NetworkConnections -split "`n")){
                                                    $connList = $connection.split('||').replace("[]","").trim() | Where-Object {$_ -ne ''}
                                                    foreach ($conn in $connList) {
                                                        if ($conn -match 'Establish') {
                                                            New-DiagramNode `
                                                                -Label  "[$($object.PSComputerName)]`n$(($conn -replace ';',':' -split ' ')[0])`n$(($conn -replace ';',':' -split ' ')[1..$conn.length] -join ' ')" `
                                                                -To     "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                                                -Shape  dot `
                                                                -size   10 `
                                                                -ColorBorder      Red `
                                                                -ColorBackground  LightCoral `
                                                                -LinkColor        LightCoral `
                                                                -ArrowsFromEnabled
                                                        }
                                                        elseif ($conn -match 'Listen') {
                                                            New-DiagramNode `
                                                                -Label  "[$($object.PSComputerName)]`n$(($conn -replace ';',':' -split ' ')[0])`n$(($conn -replace ';',':' -split ' ')[1..$conn.length] -join ' ')" `
                                                                -To     "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                                                -Shape  dot `
                                                                -size   10 `
                                                                -ColorBorder      Orange `
                                                                -ColorBackground  Yellow `
                                                                -LinkColor        Gold `
                                                                -ArrowsFromEnabled
                                                        }
                                                        else {
                                                            New-DiagramNode `
                                                                -Label  "[$($object.PSComputerName)]`n$(($conn -replace ';',':' -split ' ')[0])`n$(($conn -replace ';',':' -split ' ')[1..$conn.length] -join ' ')" `
                                                                -To     "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                                                -Shape  dot `
                                                                -size   10 `
                                                                -ColorBorder      DarkGray `
                                                                -ColorBackground  LightGray `
                                                                -LinkColor        LightGray `
                                                                -ArrowsFromEnabled
                                                        }
                                                    }
                                                }
                                            }
                                            <# THIS VERSION OF THE CODE ENDED UP SHOWING THE RELATIONSHIPS BETWEEN THE ENDPOINTS VIA NETWORK CONNECTIONS                
                                            if ($object.NetworkConnections) {
                                                foreach ($conn in $($object.NetworkConnections -split "`n")){
                                                    if ($conn -match 'Establish') {
                                                        New-DiagramNode `
                                                            -Label  "$(($conn -replace ';',':' -split ' ')[0])`n$(($conn -replace ';',':' -split ' ')[1..$conn.length] -join ' ')" `
                                                            -To     "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                                            -Shape  dot `
                                                            -size   10 `
                                                            -BorderWidth      1 `
                                                            -ColorBorder      Red `
                                                            -ColorBackground  LightCoral `
                                                            -LinkColor        Pink `
                                                            -ArrowsFromEnabled
                                                    }
                                                    elseif ($conn -match 'Listen') {
                                                        New-DiagramNode `
                                                            -Label  "$(($conn -replace ';',':' -split ' ')[0])`n$(($conn -replace ';',':' -split ' ')[1..$conn.length] -join ' ')" `
                                                            -To     "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                                            -Shape  dot `
                                                            -size   10 `
                                                            -BorderWidth      1 `
                                                            -ColorBorder      Orange `
                                                            -ColorBackground  Yellow `
                                                            -LinkColor        Pink `
                                                            -ArrowsFromEnabled
                                                    }
                                                    else {
                                                        New-DiagramNode `
                                                            -Label  "$(($conn -replace ';',':' -split ' ')[0])`n$(($conn -replace ';',':' -split ' ')[1..$conn.length] -join ' ')" `
                                                            -To     "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                                            -Shape  dot `
                                                            -size   10 `
                                                            -BorderWidth      1 `
                                                            -ColorBorder      DarkViolet `
                                                            -ColorBackground  Violet `
                                                            -LinkColor        Pink `
                                                            -ArrowsFromEnabled
                                                    }
                                                }
                                            }#>
                                        }
                                        elseif ($object.level -gt 0) {
                                            New-DiagramNode `
                                                -Label  "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                                -To     "[$($object.PSComputerName)]`n$($object.ParentProcessName)`nPID:$($object.ParentProcessID)" `
                                                -Image  "$Dependencies\Images\Process.jpg" `
                                                -size   15 `
                                                -LinkColor  Blue `
                                                -ArrowsFromEnabled                        
                                            if ($object.ServiceInfo) {
                                                New-DiagramNode `
                                                    -Label  "[$($object.PSComputerName)]`nService: $(($object.ServiceInfo -split ' ')[0])`n$((($object.ServiceInfo -split ' ')[1..$object.ServiceInfo.length] -join ' ') -replace '[','' -replace ']','')" `
                                                    -To     "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                                    -Shape  triangle `
                                                    -size   10 `
                                                    -ColorBorder AliceBlue `
                                                    -ColorBackground  Cyan `
                                                    -LinkColor        Cyan `
                                                    -ArrowsFromEnabled
                                            }
        
                                            if ($object.NetworkConnections) {
                                                foreach ($connection in $($object.NetworkConnections -split "`n")){
                                                    $connList = $connection.split('||').replace("[]","").trim() | Where-Object {$_ -ne ''}
                                                    foreach ($conn in $connList) {
                                                        if ($conn -match 'Establish') {
                                                            New-DiagramNode `
                                                                -Label  "[$($object.PSComputerName)]`n$(($conn -replace ';',':' -split ' ')[0])`n$(($conn -replace ';',':' -split ' ')[1..$conn.length] -join ' ')" `
                                                                -To     "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                                                -Shape  dot `
                                                                -size   10 `
                                                                -ColorBorder      Red `
                                                                -ColorBackground  LightCoral `
                                                                -LinkColor        LightCoral `
                                                                -ArrowsFromEnabled
                                                        }
                                                        elseif ($conn -match 'Listen') {
                                                            New-DiagramNode `
                                                                -Label  "[$($object.PSComputerName)]`n$(($conn -replace ';',':' -split ' ')[0])`n$(($conn -replace ';',':' -split ' ')[1..$conn.length] -join ' ')" `
                                                                -To     "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                                                -Shape  dot `
                                                                -size   10 `
                                                                -ColorBorder      Orange `
                                                                -ColorBackground  Yellow `
                                                                -LinkColor        Gold `
                                                                -ArrowsFromEnabled
                                                        }
                                                        else {
                                                            New-DiagramNode `
                                                                -Label  "[$($object.PSComputerName)]`n$(($conn -replace ';',':' -split ' ')[0])`n$(($conn -replace ';',':' -split ' ')[1..$conn.length] -join ' ')" `
                                                                -To     "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                                                -Shape  dot `
                                                                -size   10 `
                                                                -ColorBorder      DarkGray `
                                                                -ColorBackground  LightGray `
                                                                -LinkColor        LightGray `
                                                                -ArrowsFromEnabled
                                                        }
                                                    }
                                                }
                                            }
                                            <# THIS VERSION OF THE CODE ENDED UP SHOWING THE RELATIONSHIPS BETWEEN THE ENDPOINTS VIA NETWORK CONNECTIONS       
                                            if ($object.NetworkConnections) {
                                                foreach ($conn in $($object.NetworkConnections -split "`n")){
                                                    if ($conn -match 'Establish') {
                                                        New-DiagramNode `
                                                            -Label  "$(($conn -replace ';',':' -split ' ')[0])`n$(($conn -replace ';',':' -split ' ')[1..$conn.length] -join ' ')" `
                                                            -To     "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                                            -Shape  dot `
                                                            -size   10 `
                                                            -BorderWidth      1 `
                                                            -ColorBorder      Red `
                                                            -ColorBackground  LightCoral `
                                                            -LinkColor        Pink `
                                                            -ArrowsFromEnabled
                                                    }
                                                    elseif ($conn -match 'Listen') {
                                                        New-DiagramNode `
                                                            -Label  "$(($conn -replace ';',':' -split ' ')[0])`n$(($conn -replace ';',':' -split ' ')[1..$conn.length] -join ' ')" `
                                                            -To     "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                                            -Shape  dot `
                                                            -size   10 `
                                                            -BorderWidth      1 `
                                                            -ColorBorder      Orange `
                                                            -ColorBackground  Yellow `
                                                            -LinkColor        Pink `
                                                            -ArrowsFromEnabled
                                                    }
                                                    else {
                                                        New-DiagramNode `
                                                            -Label  "$(($conn -replace ';',':' -split ' ')[0])`n$(($conn -replace ';',':' -split ' ')[1..$conn.length] -join ' ')" `
                                                            -To     "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                                            -Shape  dot `
                                                            -size   10 `
                                                            -BorderWidth      1 `
                                                            -ColorBorder      DarkViolet `
                                                            -ColorBackground  Violet `
                                                            -LinkColor        Pink `
                                                            -ArrowsFromEnabled
                                                    }
                                                }
                                            }#>
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }


        $ProcessesScriptblock = {
            $ErrorActionPreference = 'SilentlyContinue'
            $CollectionTime = Get-Date
            $Processes      = Get-WmiObject Win32_Process
            $Services       = Get-WmiObject Win32_Service

            # Get's Endpoint Network Connections associated with Process IDs
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
                    $Connection | Add-Member -MemberType NoteProperty 'OwningProcess'   $proc.ProcessId
                    $Connection | Add-Member -MemberType NoteProperty 'ParentProcessId' $proc.ParentProcessId
                    $Connection | Add-Member -MemberType NoteProperty 'Name'            $proc.Caption
                    $Connection | Add-Member -MemberType NoteProperty 'ExecutablePath'  $proc.ExecutablePath
                    $Connection | Add-Member -MemberType NoteProperty 'CommandLine'     $proc.CommandLine
                    $Connection | Add-Member -MemberType NoteProperty 'PSComputerName'  $env:COMPUTERNAME
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

            # Create Hashtable of all network processes And their PIDs
            $ProcessNamePid = @{}
            foreach ( $proc in $Processes ) {
                if ( $proc.ProcessID -notin $ProcessNamePid.keys ) {
                    $ProcessNamePid[$proc.ProcessID] += $proc.ProcessName
                }
            }

            # Create Hashtable of all network processes And their PIDs
            $NetConnections = @{}
            foreach ( $Connection in $NetworkConnections ) {
                $connStr = "[$($Connection.State)] " + "$($Connection.LocalAddress)" + ";" + "$($Connection.LocalPort)" + " <--> " + "$($Connection.RemoteAddress)" + ";" + "$($Connection.RemotePort)" + " [$($Connection.CreationTime)] || "
                if ( $Connection.OwningProcess -in $NetConnections.keys ) {
                    if ( $connStr -notin $NetConnections[$Connection.OwningProcess] ) { $NetConnections[$Connection.OwningProcess] += $connStr }
                }
                else { $NetConnections[$Connection.OwningProcess] = $connStr }
            }

            # Create HashTable of services associated to PIDs
            $ServicePIDs = @{}
            foreach ( $svc in $Services ) {
                if ( $svc.ProcessID -notin $ServicePIDs.keys ) {
                    $ServicePIDs[$svc.ProcessID] += "$($svc.name) [$($svc.Startmode) Start By $($svc.startname)]"
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
            $TrackPaths                     = @()
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

            function Get-ProcessTree {
                [CmdletBinding()]
                param(
                    [string]$ComputerName = 'localhost', 
                    $Processes,
                    [int]$IndentSize = 5
                )
                $indentSize   = [Math]::Max(1, [Math]::Min(12, $indentSize))
                #$computerName = ($computerName, ".")[[String]::IsNullOrEmpty($computerName)]
                $PIDs         = $Processes | Select-Object -ExpandProperty ProcessId
                $Parents      = $Processes | Select-Object -ExpandProperty ParentProcessId -Unique
                $LiveParents  = $Parents   | Where-Object { $PIDs -contains $_ }
                $DeadParents  = Compare-Object -ReferenceObject $Parents -DifferenceObject $LiveParents `
                                | Select-Object -ExpandProperty InputObject
                $ProcessByParent = $Processes | Group-Object -AsHashTable ParentProcessId

                function Write-ProcessTree($Process, [int]$level = 0) {
                    $EnrichedProcess       = Get-Process -Id $Process.ProcessId
                    $indent                = New-Object String(' ', ($level * $indentSize))

                    $ProcessID             = $Process.ProcessID
                    $ParentProcessID       = $Process.ParentProcessID
                    $ParentProcessName     = $ProcessNamePid[$Process.ParentProcessID]
                    #$CreationDate          = $([Management.ManagementDateTimeConverter]::ToDateTime($Process.CreationDate))

                    $ServiceInfo           = $ServicePIDs[$Process.ProcessId]

                    $NetConns              = $($NetConnections[$Process.ProcessId]).TrimEnd(" || ")
                    $NetConnsCount         = if ($NetConns) {$($NetConns -split " || ").Count} else {[int]0}

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
                    | Add-Member NoteProperty 'Level'                  $level                    -PassThru -Force `
                    | Add-Member NoteProperty 'ProcessID'              $ProcessID                -PassThru -Force `
                    | Add-Member NoteProperty 'ProcessName'            $_.Name                   -PassThru -Force `
                    | Add-Member NoteProperty 'ParentProcessID'        $ParentProcessID          -PassThru -Force `
                    | Add-Member NoteProperty 'ParentProcessName'      $ParentProcessName        -PassThru -Force `
                    | Add-Member NoteProperty 'CreationDate'           $CreationDate             -PassThru -Force `
                    | Add-Member NoteProperty 'ServiceInfo'            $ServiceInfo              -PassThru -Force `
                    | Add-Member NoteProperty 'NetworkConnections'     $NetConns                 -PassThru -Force `
                    | Add-Member NoteProperty 'NetworkConnectionCount' $NetConnsCount            -PassThru -Force `
                    | Add-Member NoteProperty 'StatusMessage'          $StatusMessage            -PassThru -Force `
                    | Add-Member NoteProperty 'SignerCertificate'      $SignerCertificate        -PassThru -Force `
                    | Add-Member NoteProperty 'SignerCompany'          $SignerCompany            -PassThru -Force `
                    | Add-Member NoteProperty 'MD5Hash'                $MD5Hash                  -PassThru -Force `
                    | Add-Member NoteProperty 'Modules'                $Modules                  -PassThru -Force `
                    | Add-Member NoteProperty 'ModuleCount'            $ModuleCount              -PassThru -Force `
                    | Add-Member NoteProperty 'ThreadCount'            $ThreadCount              -PassThru -Force `
                    | Add-Member NoteProperty 'Owner'                  $Owner                    -PassThru -Force `
                    | Add-Member NoteProperty 'OwnerSID'               $OwnerSID                 -PassThru -Force `
                    | Add-Member NoteProperty 'Duration'               $(New-TimeSpan -Start $_.StartTime -End $CollectionTime) -PassThru -Force `
                    | Add-Member NoteProperty 'MemoryUsage'            $(if    ($_.WorkingSet -gt 1GB) {"$([Math]::Round($_.WorkingSet/1GB, 2)) GB"}
                                                                        elseif ($_.WorkingSet -gt 1MB) {"$([Math]::Round($_.WorkingSet/1MB, 2)) MB"}
                                                                        elseif ($_.WorkingSet -gt 1KB) {"$([Math]::Round($_.WorkingSet/1KB, 2)) KB"}
                                                                        else                           {"$([Math]::Round($_.WorkingSet,     2)) Bytes"} ) -PassThru -Force

                    $ProcessByParent.Item($ProcessID) `
                    | Where-Object   { $_ } `
                    | ForEach-Object { Write-ProcessTree $_ ($level + 1) }
                }
                $Processes `
                | Where-Object   { $_.ProcessId -ne 0 -and ($_.ProcessId -eq $_.ParentProcessId -or $DeadParents -contains $_.ParentProcessId) } `
                | ForEach-Object { Write-ProcessTree $_ }
            }
            Get-ProcessTree -Processes $Processes | Select-Object `
            ProcessID, ProcessName, Level, ParentProcessName, ParentProcessID, ServiceInfo,
            @{n='PSComputerName';e={$env:Computername}},
            StartTime, Duration, CPU, TotalProcessorTime,
            NetworkConnections, NetworkConnectionCount, CommandLine, Path,
            WorkingSet, MemoryUsage,
            MD5Hash, SignerCertificate, StatusMessage, SignerCompany, Company, Product, ProductVersion, Description,
            Modules, ModuleCount, Threads, ThreadCount, Handle, Handles, HandleCount,
            Owner, OwnerSID,
            @{n='CollectionType';e={'ProcessData'}}
        }



        if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
            foreach ($TargetComputer in $script:ComputerList) {
                if ($ComputerListProvideCredentialsCheckBox.Checked) {
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
        #         script:Individual-PSWriteHTML -Title 'Process Data' -Data { script:Start-PSWriteHTMLProcessData }
        #     }
        # }
    }






































    



    ####################################################################################################
    # Network Connections                                                                              #
    ####################################################################################################
    if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $script:PSWriteHTMLSupportOkay -eq $true -and $PSWriteHTMLCheckedItemsList -contains 'Endpoint Network Connections') {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Query: Endpoint Network Connections")


        function script:Start-PSWriteHTMLNetworkConnections {
            $script:EndpointDataNetworkConnections    = $script:EndpointDataNetworkConnections | Select-Object -Property RemoteIPPort, LocalIPPort, PSComputerName, State, Protocol, LocalAddress, LocalPort, RemoteAddress, RemotePort, ProcessName, ProcessId, ParentProcessId, CreationTime, Duration, CommandLine, ExecutablePath, MD5Hash, OwningProcess, CollectionMethod
            $NetworkConnectionsLocalPortsListening    = $script:EndpointDataNetworkConnections | Select-Object LocalPort, State, PSComputerName -Unique | Where-Object {$_.State -match 'Listen'} | Group-Object LocalPort | Sort-Object Count, Name
            $NetworkConnectionsRemotePortsEstablished = $script:EndpointDataNetworkConnections | Select-Object RemotePort, State, PSComputerName -Unique | Where-Object {$_.State -match 'Establish'} | Group-Object RemotePort | Sort-Object Count, Name
            $NetworkConnectionsRemoteLocalIPsUnique   = $script:EndpointDataNetworkConnections | Select-Object RemoteAddress, PSComputerName -Unique  | Where-Object {$_.RemoteAddress -match '(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^192\.168\.)'} | Group-Object RemoteAddress | Sort-Object Count, Name
            $NetworkConnectionsRemoteLocalIPsSum      = $script:EndpointDataNetworkConnections | Select-Object RemoteAddress, PSComputerName          | Where-Object {$_.RemoteAddress -match '(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^192\.168\.)'} | Group-Object RemoteAddress | Sort-Object Count, Name
            $NetworkConnectionsRemotePublicIPsUnique  = $script:EndpointDataNetworkConnections | Select-Object RemoteAddress, PSComputerName -Unique  | Where-Object {$_.RemoteAddress -notmatch '(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^192\.168\.)|(^127\.)|(^::)|0.0.0.0'} | Group-Object RemoteAddress | Sort-Object Count, Name
            $NetworkConnectionsRemotePublicIPsSum     = $script:EndpointDataNetworkConnections | Select-Object RemoteAddress, PSComputerName          | Where-Object {$_.RemoteAddress -notmatch '(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^192\.168\.)|(^127\.)|(^::)|0.0.0.0'} | Group-Object RemoteAddress | Sort-Object Count, Name  

            New-HTMLTab -Name 'Network Connections' -IconBrands acquisitions-incorporated {
                ###########
                New-HTMLTab -Name 'Table Search' -IconRegular window-maximize {
                    New-HTMLSection -HeaderText 'Table Search' -Height 725 -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                        New-HTMLTable -DataTable $script:EndpointDataNetworkConnections {
                            New-TableHeader -Color Blue -Alignment left -Title 'Network Connections Have Been Enriched With Related Process Data And File Hashes.' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                    }
                }
                ###########
                New-HTMLTab -Name 'Pane Search' -IconSolid th {
                    New-HTMLSection -HeaderText 'Pane Search' -Height 725 -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                        New-HTMLTable -DataTable $script:EndpointDataNetworkConnections {
                            New-TableHeader -Color Blue -Alignment left -Title 'Network Connections Have Been Enriched With Related Process Data And File Hashes.' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength', 'searchPanes') -searchpane -SearchRegularExpression
                    }
                }
                ###########
                New-HTMLTab -Name 'Calendar' -IconRegular calendar-alt  {
                    New-HTMLSection -HeaderText 'Calendar' -Height 725 -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                        New-HTMLTable -DataTable $script:EndpointDataNetworkConnections {
                            New-TableHeader -Color Blue -Alignment left -Title 'Calendar - Network Connections Data' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                        New-HTMLCalendar {
                            foreach ($_ in $script:EndpointDataNetworkConnections) {
                                New-CalendarEvent -StartDate $_.CreationTime `
                                -Title "$($_.PSComputerName) [$($_.State)] $($_.RemoteAddress):$($_.RemotePort)" `
                                -Description "$($_.PSComputerName) || State: $($_.State) || $($_.LocalAddress):$($_.LocalPort) <--> $($_.RemoteAddress):$($_.RemotePort) || Start Time: $($_.StartTime) || Process: $($_.ProcessName):$($_.ProcessID)"
                            }
                        } -InitialView dayGridMonth #timeGridDay
                    }
                }
                ###########
                New-HTMLTab -Name 'Charts' -IconRegular chart-bar { 
                    script:Generate-TablePieBarCharts -Title "Local Ports Listening" -Data $NetworkConnectionsLocalPortsListening
                    script:Generate-TablePieBarCharts -Title "Remote Ports Established" -Data $NetworkConnectionsRemotePortsEstablished
                    script:Generate-TablePieBarCharts -Title "Remote Local IPs Unique" -Data $NetworkConnectionsRemoteLocalIPsUnique
                    script:Generate-TablePieBarCharts -Title "Remote Local IPs Sum" -Data $NetworkConnectionsRemoteLocalIPsSum
                    script:Generate-TablePieBarCharts -Title "Remote Public IPs Unique" -Data $NetworkConnectionsRemotePublicIPsUnique
                    script:Generate-TablePieBarCharts -Title "Remote Public IPs Sum" -Data $NetworkConnectionsRemotePublicIPsSum
                }        
                ###########
                New-HTMLTab -TabName 'Graph & Table' -IconSolid bezier-curve {
                    $DataTableID = Get-Random -Minimum 100000 -Maximum 2000000
                    $script:EndpointDataNetworkConnections = $script:EndpointDataNetworkConnections | Select-Object RemoteIPPort, * -ErrorAction SilentlyContinue
                    New-HTMLSection -HeaderText 'Network Connections' -CanCollapse {
                        New-HTMLPanel -Width 40% {
                            New-HTMLTable -DataTable $script:EndpointDataNetworkConnections -DataTableID $DataTableID -SearchRegularExpression  {
                                New-TableHeader -Color Blue -Alignment left -Title 'Processes Associated With Endpoints' -FontSize 18 
                            } 
                        }
                        New-HTMLPanel {
                            
                            New-HTMLText `
                                -FontSize 12 `
                                -FontFamily 'Source Sans Pro' `
                                -Color Blue `
                                -Text 'Click On The Network Connection Icons To Automatically Locate Them Within The Table'
        
                            New-HTMLDiagram -Height '1000px' {
                                New-DiagramEvent -ID $DataTableID -ColumnID 1
                                New-DiagramEvent -ID $DataTableID -ColumnID 2
                                New-DiagramEvent -ID $DataTableID -ColumnID 3
                                New-DiagramOptionsInteraction -Hover $true
                                New-DiagramOptionsManipulation 
                                New-DiagramOptionsPhysics -Enabled $true
                                New-DiagramOptionsLayout `
                                    -RandomSeed 13
        
                                ###New-DiagramOptionsLayout -RandomSeed 500 -HierarchicalEnabled $true -HierarchicalDirection FromLeftToRight
                                
                                New-DiagramOptionsNodes `
                                    -BorderWidth 1 `
                                    -ColorBackground LightSteelBlue `
                                    -ColorHighlightBorder Orange `
                                    -ColorHoverBackground Orange
                                New-DiagramOptionsLinks `
                                    -FontSize 12 `
                                    -ColorHighlight Orange `
                                    -ColorHover Orange `
                                    -Length 5000
                                    # -ArrowsToEnabled $true `
                                    # -Color BlueViolet `
                                    # -ArrowsToType arrow `
                                    # -ArrowsFromEnabled $false `
                            New-DiagramOptionsEdges `
                                    -ColorHighlight Orange `
                                    -ColorHover Orange
        
                                if ($script:PSWriteHTMLExcludeEasyWinFromGraphsCheckbox.checked -and $script:PSWriteHTMLExcludeIPv6FromGraphsCheckbox.checked){
                                    $filter = { $_.RemoteAddress -notin $script:PoShEasyWinIPAddress -and ($_.LocalAddress -notmatch ':' -or $_.RemoteAddress -notmatch ':') }
                                }
                                elseif ( $script:PSWriteHTMLExcludeEasyWinFromGraphsCheckbox.checked ) {
                                    $filter = { $_.RemoteAddress -notin $script:PoShEasyWinIPAddress }
                                }
                                elseif ($script:PSWriteHTMLExcludeIPv6FromGraphsCheckbox.checked) {
                                    $filter = { $_.LocalAddress -notmatch ':' -or $_.RemoteAddress -notmatch ':' }
                                }
                                else {
                                    $filter = { $_.LocalAddress -notmatch $false }
                                }

                                $script:LocalAddressList = $script:EndpointDataNetworkConnections | Select-Object -ExpandProperty LocalAddress | Sort-Object -Unique
                                $script:NameNodeList = $script:EndpointDataNetworkConnections | Select-Object -ExpandProperty PSComputerName | Sort-Object -Unique


                                #$script:AllComputersList = @()
                                #[System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
                                #foreach ($root in $AllTreeViewNodes) {
                                #    foreach ($Category in $root.Nodes) {
                                #        foreach ($Entry in $Category.nodes) {
                                #            $script:AllComputersList += $Entry.text
                                #        }
                                #    }
                                #}
                                if ($script:PSWriteHTMLResolveDNSCheckbox.checked) {

                                        #####################################
                                        # Hashtable of DNS Results // START #
                                        #####################################
                                        $StatusListBox.Items.Clear()
                                        $StatusListBox.Items.Add("Conducting DNS Resolution - In Progress")
                                        $PoShEasyWin.Refresh()
                            
                                        $script:DNSResolvedList = @{}
                                        $RemoteAddresses = ($script:EndpointDataNetworkConnections).RemoteAddress | `
                                            Sort-Object -Unique `
                                            | Where-Object {$_ -ne '::' -and $_ -ne '::1' -and $_ -ne '0.0.0.0' -and $_ -ne '127.0.0.1'}
                                        Get-Job  -Name "nslookup:*" | Remove-Job -Force
                                        foreach ( $RemoteIP in $RemoteAddresses ) {
                                            if ($script:DNSResolvedList.ContainsKey($RemoteIP)) {
                                                $null
                                            }
                                            else {
                                                Start-Job -Name "nslookup:$RemoteIP" `
                                                -ScriptBlock {
                                                    param($RemoteIP)
                                                    return @{$RemoteIP = $((Resolve-DnsName $RemoteIP -QuickTimeout -ErrorAction SilentlyContinue).NameHost)}
                                                } -ArgumentList @($RemoteIP,$null)
                                            }
                                        }

                                        $script:ProgressBarQueriesProgressBar.Value = 0
                                        $script:ProgressBarQueriesProgressBar.Maximum = (Get-Job -Name "nslookup:*").count
                                        while ((Get-Job -Name "nslookup:*").State -match 'Running'){
                                            $Jobs = Get-Job -Name "nslookup:*"
                                            "$($Jobs.count) / $(($jobs.State -match 'Complete').count)"
                                            if ($($Jobs.count) -eq $(($jobs.State -match 'Complete').count)){break}

                                            $script:ProgressBarQueriesProgressBar.Value = ($jobs.State -match 'Complete').count
                                            $script:ProgressBarQueriesProgressBar.Refresh()
                                            Start-Sleep -Milliseconds 250
                                        }
                                        $script:ProgressBarQueriesProgressBar.Maximum = 1
                                        $script:ProgressBarQueriesProgressBar.Value = 1
                                        $StatusListBox.Items.Clear()
                                        $StatusListBox.Items.Add("Conducting DNS Resolution - Completed")
                                        $PoShEasyWin.Refresh()

                                        $UnresolvedCount = 0
                                        ForEach ($Job in (Get-Job -Name "nslookup:*")){
                                            $JobRecieved = $Job | Receive-Job
                                            if ($JobRecieved.Values -ne $null) {
                                                $script:DNSResolvedList.add("$($JobRecieved.Keys)", "$($JobRecieved.Values)")
                                            }
                                            else {
                                                $UnresolvedCount += 1
                                                $script:DNSResolvedList.add("$($JobRecieved.Keys)", "Unresolved: $($UnresolvedCount)")
                                            }
                                        }
                                        Get-Job  -Name "nslookup:*" | Remove-Job
                                        ###################################
                                        # Hashtable of DNS Results // END #
                                        ###################################
                                }
                                #$DomainDNSHostnameList = @()
                                #foreach ($Endpoint in $script:DNSResolvedList.Values) {
                                #    $Endpoint = $Endpoint.split('.')[0]
                                #    if ( $Endpoint -in $script:AllComputersList -and $Endpoint -notin $DomainDNSHostnameList ) {
                                #        $DomainDNSHostnameList += $Endpoint
                                #    }
                                #}
                                #$DomainDNSHostnameList

                                
                                $StatusListBox.Items.Clear()
                                $StatusListBox.Items.Add("Generating Graphs, Charts, & Tables")
                                $PoShEasyWin.Refresh()
                                $script:EndpointDataNetworkConnections | Where-Object -FilterScript $filter `
                                | ForEach-Object {
                                    function New-ComputerNode {

                                        #if ($DNSHostname.split('.')[0] -in $script:AllComputersList) { 
                                        #if ( $_.RemoteAddress -in $DomainDNSIPList ) {
                                        #    $ResolvedHoseName = ($script:DNSResolvedList[$_.RemoteAddress]).spit('.')[0]
                                        #}
                                        if ($script:PSWriteHTMLResolveDNSCheckbox.checked) {
                                            if ( $script:DNSResolvedList[$_.RemoteAddress] ) {
                                                $ResolvedHoseName = "DNS Resolution:`n$( $script:DNSResolvedList[$_.RemoteAddress] )"
                                            }

                                            if ($ResolvedHoseName -notin $script:NameNodeList -and $_.RemoteAddress -notin $script:LocalAddressList) {
                                                New-DiagramNode `
                                                    -Label  $ResolvedHoseName `
                                                    -To     $_.RemoteAddress `
                                                    -Image  "$Dependencies\Images\DNS.png" `
                                                    -Size   25 `
                                                    -FontSize   20 `
                                                    -FontColor  Blue `
                                                    -LinkColor  Blue
                                                
                                                $script:LocalAddressList += $_.RemoteAddress
                                                $script:NameNodeList += $ResolvedHoseName
                                                $script:NameNodeList += $DNSResolution
                                            }
                                        }

                                        if ($_.LocalAddress -match '127(\.\d){3}' -or $_.LocalAddress -match '0.0.0.0' ) {
                                            
                                            if ($_.LocalAddress -notin $NIClist) {
                                                New-DiagramNode `
                                                    -Label  $_.PSComputerName `
                                                    -To     "[$($_.PSComputerName)]`n$($_.LocalAddress)" `
                                                    -Image  "$Dependencies\Images\Computer.jpg" `
                                                    -Size   65 `
                                                    -FontSize   20 `
                                                    -FontColor  Blue `
                                                    -LinkColor  Blue `
                                                    -ArrowsToEnabled
                                                $NIClist += $_.LocalAddress
                                            }
                                            New-DiagramNode `
                                                -Label  "[$($_.PSComputerName)]`n$($_.LocalAddress)" `
                                                -To     "[$($_.PSComputerName)]`n$($_.ProcessName)`nPID:$($_.ProcessID)`n($($_.State))" `
                                                -Image  "$Dependencies\Images\NIC.jpg" `
                                                -Size   40 `
                                                -LinkColor Blue `
                                                -ArrowsToEnabled
                                        }
                                        else {
                                            if ($_.LocalAddress -notin $NIClist) {
                                                New-DiagramNode `
                                                    -Label  $_.PSComputerName `
                                                    -To     $_.LocalAddress `
                                                    -Image  "$Dependencies\Images\Computer.jpg" `
                                                    -Size   65 `
                                                    -FontSize   20 `
                                                    -FontColor  Blue `
                                                    -LinkColor  Blue `
                                                    -ArrowsToEnabled
                                                $NIClist += $_.LocalAddress
                                            }
                                            New-DiagramNode `
                                                -Label  $_.LocalAddress `
                                                -To     "[$($_.PSComputerName)]`n$($_.ProcessName)`nPID:$($_.ProcessID)`n($($_.State))" `
                                                -Image  "$Dependencies\Images\NIC.jpg" `
                                                -Size   40 `
                                                -LinkColor Blue `
                                                -ArrowsToEnabled
                                        }
                                    }

                                    function New-ProcessConnectionNodes {
                                        param(
                                            $IconColor,
                                            $LinkColor
                                        )
                                        if ($_.RemotePort -ne '0'){
                                            New-DiagramNode `
                                                -Label  "[$($_.PSComputerName)]`n$($_.ProcessName)`nPID:$($_.ProcessID)`n($($_.State))" `
                                                -To     "$($_.LocalAddress):$($_.LocalPort)" `
                                                -Image  "$Dependencies\Images\Process.jpg" `
                                                -size   25 `
                                                -LinkColor $IconColor `
                                                -ArrowsToEnabled
                                            New-DiagramNode `
                                                -Label  "$($_.LocalAddress):$($_.LocalPort)" `
                                                -To     "$($_.RemoteAddress):$($_.RemotePort)" `
                                                -Size   20 `
                                                -IconSolid  Network-wired `
                                                -IconColor  $IconColor `
                                                -LinkColor  $IconColor `
                                                -ArrowsToEnabled
                                            New-DiagramNode `
                                                -Label  "$($_.RemoteAddress):$($_.RemotePort)" `
                                                -To     $_.RemoteAddress `
                                                -Size   20 `
                                                -IconSolid  Network-wired `
                                                -IconColor  $IconColor `
                                                -LinkColor  $IconColor `
                                                -ArrowsToEnabled
                                            New-DiagramNode `
                                                -Label  $_.RemoteIPPort  `
                                                -To     $_.RemoteAddress `
                                                -Size   20 `
                                                -IconSolid  Network-wired `
                                                -IconColor  $IconColor `
                                                -LinkColor  $IconColor `
                                                -ArrowsToEnabled
                                            New-DiagramNode `
                                                -Label  $_.RemoteAddress `
                                                -Image  "$Dependencies\Images\NIC.jpg" `
                                                -size   40 `
                                                -LinkColor $IconColor `
                                                -ArrowsToEnabled
                                        }                                        
                                    }

                                    # Only creates nodes for IPs that are not PoSh-EasyWin IPs
                                    if ($_.state -match 'Established' -and $script:ConnectionStatesFilterCheckedListBox.CheckedItems -contains 'Established'){
                                        New-ComputerNode
                                        New-ProcessConnectionNodes -IconColor DarkBlue -LinkColor Blue
                                    }
                                    elseif ($_.state -match 'Bound' -and $script:ConnectionStatesFilterCheckedListBox.CheckedItems -contains 'Bound') {
                                        New-ComputerNode
                                        New-ProcessConnectionNodes -IconColor Brown -LinkColor DarkBrown
                                    }
                                    elseif ($_.state -match 'CloseWait' -and $script:ConnectionStatesFilterCheckedListBox.CheckedItems -contains 'CloseWait') {
                                        New-ComputerNode
                                        New-ProcessConnectionNodes -IconColor Green -LinkColor DarkGreen
                                    }
                                    elseif ($_.state -match 'Timeout' -and $script:ConnectionStatesFilterCheckedListBox.CheckedItems -contains 'Timeout') {
                                        New-ComputerNode
                                        New-ProcessConnectionNodes -IconColor Violet -LinkColor DarkViolet
                                    }
                                    elseif ($_.State -match 'All Others' `
                                        -and ($script:ConnectionStatesFilterCheckedListBox.CheckedItems -contains 'Closed' `
                                         -or  $script:ConnectionStatesFilterCheckedListBox.CheckedItems -contains 'Closing' `
                                         -or  $script:ConnectionStatesFilterCheckedListBox.CheckedItems -contains 'DeleteTCB' `
                                         -or  $script:ConnectionStatesFilterCheckedListBox.CheckedItems -contains 'FinWait1' `
                                         -or  $script:ConnectionStatesFilterCheckedListBox.CheckedItems -contains 'FinWait2' `
                                         -or  $script:ConnectionStatesFilterCheckedListBox.CheckedItems -contains 'LastAck' `
                                         -or  $script:ConnectionStatesFilterCheckedListBox.CheckedItems -contains 'SynReceived' `
                                         -or  $script:ConnectionStatesFilterCheckedListBox.CheckedItems -contains 'SynSent' ) ) {
                                        New-ComputerNode
                                        New-ProcessConnectionNodes -IconColor Gray -LinkColor DarkGray
                                    }
                                    elseif ($_.state -match 'Listen' -and $script:ConnectionStatesFilterCheckedListBox.CheckedItems -contains 'Listen'){
                                        New-DiagramNode `
                                            -Label  $_.PSComputerName `
                                            -To     "[$($_.PSComputerName)]`n$($_.ProcessName)`nPID:$($_.ProcessID)`n($($_.State))" `
                                            -Image  "$Dependencies\Images\Computer.jpg" `
                                            -Size   65 `
                                            -FontSize   20 `
                                            -FontColor  Orange `
                                            -LinkColor  Gold `
                                            -ArrowsToEnabled
                                        New-DiagramNode `
                                            -Label  "[$($_.PSComputerName)]`n$($_.ProcessName)`nPID:$($_.ProcessID)`n($($_.State))" `
                                            -To     "[$($_.PSComputerName)]`n$($_.LocalAddress):$($_.LocalPort)" `
                                            -Image  "$Dependencies\Images\Process.jpg" `
                                            -size   25 `
                                            -LinkColor Gold `
                                            -ArrowsToEnabled
                                        New-DiagramNode `
                                            -Label  "[$($_.PSComputerName)]`n$($_.LocalAddress):$($_.LocalPort)" `
                                            -shape  dot `
                                            -Size   10 `
                                            -ColorBorder      Orange `
                                            -ColorBackground  Yellow `
                                            -LinkColor        Gold `
                                            -ArrowsToEnabled
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }   


        $NetworkConnectionsScriptBlock = {
            if ([bool]((Get-Command Get-NetTCPConnection).ParameterSets | Select-Object -ExpandProperty Parameters | Where-Object Name -match OwningProcess)) {
                $Processes           = Get-WmiObject -Class Win32_Process
                $Connections         = Get-NetTCPConnection

                foreach ($Conn in $Connections) {
                    foreach ($Proc in $Processes) {
                        if ($Conn.OwningProcess -eq $Proc.ProcessId) {
                            $Conn | Add-Member -MemberType NoteProperty 'PSComputerName'   $env:COMPUTERNAME -Force
                            $Conn | Add-Member -MemberType NoteProperty 'Protocol'         'TCP'
                            $Conn | Add-Member -MemberType NoteProperty 'Duration'         ((New-TimeSpan -Start ($Conn.CreationTime)).ToString())
                            $Conn | Add-Member -MemberType NoteProperty 'ProcessId'        $Proc.ProcessId
                            $Conn | Add-Member -MemberType NoteProperty 'ParentProcessId'  $Proc.ParentProcessId
                            $Conn | Add-Member -MemberType NoteProperty 'ProcessName'      $Proc.Name
                            $Conn | Add-Member -MemberType NoteProperty 'CommandLine'      $Proc.CommandLine
                            $Conn | Add-Member -MemberType NoteProperty 'ExecutablePath'   $proc.ExecutablePath
                            $Conn | Add-Member -MemberType NoteProperty 'CollectionMethod' 'Get-NetTCPConnection Enhanced'

                            if ($Conn.ExecutablePath -ne $null -AND -NOT $NoHash) {
                                $MD5Hash = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
                                $Hash    = [System.BitConverter]::ToString($MD5Hash.ComputeHash([System.IO.File]::ReadAllBytes($proc.ExecutablePath)))
                                $Conn | Add-Member -MemberType NoteProperty MD5Hash $($Hash -replace "-","")
                            }
                            else {
                                $Conn | Add-Member -MemberType NoteProperty MD5Hash $null
                            }
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
                            Protocol      = $line[0]
                            LocalAddress  = ($line[1] -split ":")[0]
                            LocalPort     = ($line[1] -split ":")[1]
                            RemoteAddress = ($line[2] -split ":")[0]
                            RemotePort    = ($line[2] -split ":")[1]
                            State         = $line[3]
                            ProcessId     = $line[4]
                            OwningProcess = $line[4]
                        }
                        $Connection = New-Object -TypeName PSObject -Property $Properties
                        $proc       = Get-WmiObject -query ('select * from win32_process where ProcessId="{0}"' -f $line[4])
                        $Connection | Add-Member -MemberType NoteProperty 'PSComputerName'   $env:COMPUTERNAME -Force
                        $Connection | Add-Member -MemberType NoteProperty 'ParentProcessId'  $proc.ParentProcessId
                        $Connection | Add-Member -MemberType NoteProperty 'ProcessName'      $proc.Caption
                        $Connection | Add-Member -MemberType NoteProperty 'ExecutablePath'   $proc.ExecutablePath
                        $Connection | Add-Member -MemberType NoteProperty 'CommandLine'      $proc.CommandLine
                        $Connection | Add-Member -MemberType NoteProperty 'CreationTime'     ([WMI] '').ConvertToDateTime($proc.CreationDate)
                        $Connection | Add-Member -MemberType NoteProperty 'Duration'         ((New-TimeSpan -Start ([WMI] '').ConvertToDateTime($proc.CreationDate)).ToString())
                        $Connection | Add-Member -MemberType NoteProperty 'CollectionMethod' 'NetStat.exe Enhanced'

                        if ($Connection.ExecutablePath -ne $null -AND -NOT $NoHash) {
                            $MD5Hash = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
                            $Hash    = [System.BitConverter]::ToString($MD5Hash.ComputeHash([System.IO.File]::ReadAllBytes($proc.ExecutablePath)))
                            $Connection | Add-Member -MemberType NoteProperty MD5Hash $($Hash -replace "-","")
                        }
                        else {
                            $Connection | Add-Member -MemberType NoteProperty MD5Hash $null
                        }
                        $Connection
                    }
                    $NetStat
                }
                $Connections = Get-Netstat
            }
            $Connections | Select-Object -Property PSComputerName, Protocol, LocalAddress, LocalPort, RemoteAddress, RemotePort, State,
            ProcessName, ProcessId, ParentProcessId, CreationTime, Duration, CommandLine, ExecutablePath, MD5Hash, OwningProcess, 
            @{n='LocalIPPort'; e={"$($_.LocalAddress):$($_.LocalPort)"}},
            @{n='RemoteIPPort';e={"$($_.RemoteAddress):$($_.RemotePort)"}},
            CollectionMethod -ErrorAction SilentlyContinue
        }


        if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
            foreach ($TargetComputer in $script:ComputerList) {
                if ($ComputerListProvideCredentialsCheckBox.Checked) {
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
        #         script:Individual-PSWriteHTML -Title 'Network Connections' -Data { script:Start-PSWriteHTMLNetworkConnections }
        #     }
        # }
    }
   


    












































    ####################################################################################################
    # Console Logons                                                                                   #
    ####################################################################################################
    if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedItemsList -contains 'Endpoint Console Logons') {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Query: Endpoint Console Logons")
        

        function script:Start-PSWriteHTMLConsoleLogons {

            $ConsoleLogonsPerEndpoint   = $script:EndpointDataConsoleLogons | Select-Object PSComputerName, UserName | Group-Object PSComputerName | Sort-Object Count, Name -Descending
            $ConsoleLogonsCount         = $script:EndpointDataConsoleLogons | Select-Object PSComputerName, UserName | Group-Object UserName | Sort-Object Count, Name -Descending
            $ConsoleLogonsLogonTimeHour = $script:EndpointDataConsoleLogons | Select-Object @{n='LogonTimeHour';e={(($_.LogonTime -split ' ')[0] -split ':')[0]}} | Group-Object LogonTimeHour | Sort-Object Name, Count
            $ConsoleLogonsState         = $script:EndpointDataConsoleLogons | Select-Object PSComputerName, State -Unique | Group-Object State | Sort-Object Count, Name

            New-HTMLTab -Name 'Console Logons' -IconBrands acquisitions-incorporated {
                ###########
                New-HTMLTab -Name 'Table Search' -IconRegular window-maximize {
                    New-HTMLSection -HeaderText 'Table Search' -Height 725 -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                        New-HTMLTable -DataTable $script:EndpointDataConsoleLogons {
                            New-TableHeader -Color Blue -Alignment left -Title 'Console Logons' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                    }
                }
                ###########
                New-HTMLTab -Name 'Pane Search' -IconSolid th {
                    New-HTMLSection -HeaderText 'Pane Search' -Height 725 -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                        New-HTMLTable -DataTable $script:EndpointDataConsoleLogons {
                            New-TableHeader -Color Blue -Alignment left -Title 'Console Logons' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength', 'searchPanes') -searchpane -SearchRegularExpression
                    }
                }
                ###########
                New-HTMLTab -Name 'Calendar' -IconRegular calendar-alt  {
                    New-HTMLSection -HeaderText 'Calendar' -Height 725 -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                        New-HTMLTable -DataTable $script:EndpointDataConsoleLogons {
                            New-TableHeader -Color Blue -Alignment left -Title 'Calendar - Console Logons' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                        New-HTMLCalendar {
                            foreach ($_ in $script:EndpointDataConsoleLogons) {
                                New-CalendarEvent -StartDate $_.LogonTime `
                                -Title "$($_.PSComputerName) Logon: $($_.UserName)" `
                                -Description "$($_.PSComputerName) || Logon: $($_.UserName) || State: $($_.State) || Idle Time: $($_.IdleTime)"
                            }
                        } -InitialView dayGridMonth #timeGridDay
                    }
                }
                ###########       
                New-HTMLTab -Name 'Charts' -IconRegular chart-bar {
                    script:Generate-TablePieBarCharts -Title "Console Logons Per Endpoint" -Data $ConsoleLogonsPerEndpoint
                    script:Generate-TablePieBarCharts -Title "Console Logon Count" -Data $ConsoleLogonsCount
                    script:Generate-TablePieBarCharts -Title "Logon Times (Hour)" -Data $ConsoleLogonsLogonTimeHour
                    script:Generate-TablePieBarCharts -Title "Console Logon State" -Data $ConsoleLogonsState
                }
                ###########
                New-HTMLTab -TabName 'Graph & Table' -IconSolid bezier-curve {
                    $DataTableIDConsoleLogons = Get-Random -Minimum 100000 -Maximum 2000000
                    New-HTMLSection -HeaderText 'Console Logons' -CanCollapse {
                        New-HTMLPanel -Width 40% {
                            New-HTMLTable -DataTable $script:EndpointDataConsoleLogons -DataTableID $DataTableIDConsoleLogons -SearchRegularExpression  {
                                New-TableHeader -Color Blue -Alignment left -Title 'Console Logons' -FontSize 18 
                            } 
                        }
                        New-HTMLPanel {
                            
                            New-HTMLText `
                                -FontSize 12 `
                                -FontFamily 'Source Sans Pro' `
                                -Color Blue `
                                -Text 'Click On The Computer Icons To Automatically Locate Them Within The Table'
        
                            New-HTMLDiagram -Height '1000px' {
                                New-DiagramEvent -ID $DataTableIDConsoleLogons -ColumnID 0
                                New-DiagramOptionsInteraction -Hover $true
                                New-DiagramOptionsManipulation 
                                New-DiagramOptionsPhysics -Enabled $true
                                New-DiagramOptionsLayout `
                                    -RandomSeed 13
        
                                ###New-DiagramOptionsLayout -RandomSeed 500 -HierarchicalEnabled $true -HierarchicalDirection FromLeftToRight
                                
                                New-DiagramOptionsNodes `
                                    -BorderWidth 1 `
                                    -ColorBackground LightSteelBlue `
                                    -ColorHighlightBorder Orange `
                                    -ColorHoverBackground Orange
                                New-DiagramOptionsLinks `
                                    -FontSize 12 `
                                    -ColorHighlight Orange `
                                    -ColorHover Orange `
                                    -Length 5000
                                    # -ArrowsToEnabled $true `
                                    # -Color BlueViolet `
                                    # -ArrowsToType arrow `
                                    # -ArrowsFromEnabled $false `
                            New-DiagramOptionsEdges `
                                    -ColorHighlight Orange `
                                    -ColorHover Orange
        
                                foreach ($object in $script:EndpointDataConsoleLogons) {
                                    New-DiagramNode `
                                        -Label  $object.PSComputerName `
                                        -To     "[$($object.PSComputerName)]`nUser Name: $($object.UserName)" `
                                        -Image "$Dependencies\Images\Computer.jpg" `
                                        -size 25 `
                                        -FontColor  Blue `
                                        -LinkColor  Blue
                                    New-DiagramNode `
                                        -Label "[$($object.PSComputerName)]`nUser Name: $($object.UserName)" `
                                        -To    "[$($object.PSComputerName)]`nState: $($object.State)`nLogon Time: $($object.LogonTime)" `
                                        -Image "$Dependencies\Images\User.jpg" `
                                        -size 15 `
                                        -FontColor  Blue `
                                        -LinkColor  Blue
                                    New-DiagramNode `
                                        -Label  "[$($object.PSComputerName)]`nState: $($object.State)`nLogon Time: $($object.LogonTime)" `
                                        -Image "$Dependencies\Images\Clock.jpg" `
                                        -size 10 `
                                        -FontColor  Blue `
                                        -LinkColor  LightBlue
                                }
                            }
                        }
                    }
                }
            }
        }

        
        $ConsoleLogonsScriptBlock = {
            ## Find all sessions matching the specified username
            $quser = quser | Where-Object {$_ -notmatch 'SESSIONNAME'}
    
            $sessions = ($quser -split "`r`n").trim()
    
            foreach ($session in $sessions) {
                try {
                    # This checks if the value is an integer, if it is then it'll TRY, if it errors then it'll CATCH
                    [int]($session -split '  +')[2] | Out-Null
    
                    [PSCustomObject]@{
                        PSComputerName = $env:COMPUTERNAME
                        UserName       = ($session -split '  +')[0].TrimStart('>')
                        SessionName    = ($session -split '  +')[1]
                        SessionID      = ($session -split '  +')[2]
                        State          = ($session -split '  +')[3]
                        IdleTime       = ($session -split '  +')[4]
                        LogonTime      = ($session -split '  +')[5]
                        CollectionType = 'ConsoleLogons'
                    }
                }
                catch {
                    [PSCustomObject]@{
                        PSComputerName = $env:COMPUTERNAME
                        UserName       = ($session -split '  +')[0].TrimStart('>')
                        SessionName    = ''
                        SessionID      = ($session -split '  +')[1]
                        State          = ($session -split '  +')[2]
                        IdleTime       = ($session -split '  +')[3]
                        LogonTime      = ($session -split '  +')[4]
                        CollectionType = 'ConsoleLogons'
                    }
                }
            }
        }
    

        if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
            foreach ($TargetComputer in $script:ComputerList) {
                if ($ComputerListProvideCredentialsCheckBox.Checked) {
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
        #         script:Individual-PSWriteHTML -Title 'Console Logons' { script:Start-PSWriteHTMLConsoleLogons }
        #     }
        # }        
    }




    ####################################################################################################
    # PowerShell Sessions                                                                              #
    ####################################################################################################
    if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedItemsList -contains 'Endpoint PowerShell Sessions') {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Query: Endpoint PowerShell Sessions")
        

        function script:Start-PSWriteHTMLPowerShellSessions {

            $PowerShellSessionsPerEndpoint    = $script:PowerShellSessionsData | Select-Object PSComputerName, ClientIP | Group-Object PSComputerName | Sort-Object Count, Name -Descending
            $PowerShellSessionsCount          = $script:PowerShellSessionsData | Select-Object PSComputerName, Owner | Group-Object Owner | Sort-Object Count, Name -Descending
            $PowerShellSessionsLogonTime      = $script:PowerShellSessionsData | Select-Object @{n='TimeCreatedHour';e={"$(($_.TimeCreated -split ' ')[0]) $((($_.TimeCreated -split ' ')[1] -split ':')[0])H"}} | Group-Object TimeCreatedHour | Sort-Object Name, Count
            $PowerShellSessionsClientIP       = $script:PowerShellSessionsData | Select-Object PSComputerName, ClientIP -Unique | Group-Object ClientIP | Sort-Object Count, Name
            $PowerShellSessionsOwner          = $script:PowerShellSessionsData | Select-Object PSComputerName, Owner -Unique | Group-Object Owner | Sort-Object Count, Name
            $PowerShellSessionsState          = $script:PowerShellSessionsData | Select-Object PSComputerName, State -Unique | Group-Object State | Sort-Object Count, Name
            $PowerShellSessionsMemoryUsed     = $script:PowerShellSessionsData | Select-Object PSComputerName, MemoryUsed -Unique | Group-Object MemoryUsed | Sort-Object Count, Name
            $PowerShellSessionsProfileLoaded  = $script:PowerShellSessionsData | Select-Object PSComputerName, ProfileLoaded -Unique | Group-Object ProfileLoaded | Sort-Object Count, Name
            $PowerShellSessionsChildProcesses = $script:PowerShellSessionsData | Select-Object PSComputerName, ChildProcesses -Unique | Where-Object {$_.ChildProcess -ne ''} | Group-Object ChildProcesses | Sort-Object Count, Name
    
            New-HTMLTab -Name 'PowerShell Sessions' -IconBrands acquisitions-incorporated {
                ###########
                New-HTMLTab -Name 'Table Search' -IconRegular window-maximize {
                    New-HTMLSection -HeaderText 'Table Search' -Height 725 -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                        New-HTMLTable -DataTable $script:PowerShellSessionsData {
                            New-TableHeader -Color Blue -Alignment left -Title 'PowerShell Sessions' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                    }
                }
                ###########
                New-HTMLTab -Name 'Pane Search' -IconSolid th {
                    New-HTMLSection -HeaderText 'Pane Search' -Height 725 -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                        New-HTMLTable -DataTable $script:PowerShellSessionsData {
                            New-TableHeader -Color Blue -Alignment left -Title 'PowerShell Sessions' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength', 'searchPanes') -searchpane -SearchRegularExpression
                    }
                }
                ###########
                New-HTMLTab -Name 'Calendar' -IconRegular calendar-alt  {
                    New-HTMLSection -HeaderText 'Calendar' -Height 725 -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                        New-HTMLTable -DataTable $script:PowerShellSessionsData {
                            New-TableHeader -Color Blue -Alignment left -Title 'Calendar - PowerShell Sessions' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression                       
                        New-HTMLCalendar {
                            foreach ($_ in $script:PowerShellSessionsData) {
                                New-CalendarEvent -StartDate $_.LogonTime `
                                -Title "$($_.PSComputerName) by $($_.Owner) from $($_.ClientIP)" `
                                -Description "$($_.PSComputerName) || Account: $($_.Owner) || From: $($_.ClientIP) || State: $($_.State)"
                            }
                        } -InitialView dayGridMonth #timeGridDay
                    }
                }
                ###########
                New-HTMLTab -Name 'Charts' -IconRegular chart-bar {
                    script:Generate-TablePieBarCharts -Title "PowerShell Sessions Per Endpoint" -Data $PowerShellSessionsPerEndpoint
                    script:Generate-TablePieBarCharts -Title "PowerShell Sessions Count" -Data $PowerShellSessionsCount
                    script:Generate-TablePieBarCharts -Title "PowerShell Sessions Logon Time" -Data $PowerShellSessionsLogonTime
                    script:Generate-TablePieBarCharts -Title "PowerShell Sessions Client IP" -Data $PowerShellSessionsClientIP
                    script:Generate-TablePieBarCharts -Title "PowerShell Sessions Owner" -Data $PowerShellSessionsOwner
                    script:Generate-TablePieBarCharts -Title "PowerShell Sessions State" -Data $PowerShellSessionsState
                    script:Generate-TablePieBarCharts -Title "PowerShell Sessions Memory Used" -Data $PowerShellSessionsMemoryUsed
                    script:Generate-TablePieBarCharts -Title "PowerShell Sessions Profile Loaded" -Data $PowerShellSessionsProfileLoaded
                    script:Generate-TablePieBarCharts -Title "PowerShell Sessions Child Processes" -Data $PowerShellSessionsChildProcesses
                } 
            
                ###########
                New-HTMLTab -TabName 'Graph & Table' -IconSolid bezier-curve {
                    $DataTableIDPowerShellSessions = Get-Random -Minimum 100000 -Maximum 2000000
                    New-HTMLSection -HeaderText 'PowerShell Sessions' -CanCollapse {
                        New-HTMLPanel -Width 40% {
                            New-HTMLTable -DataTable $script:PowerShellSessionsData -DataTableID $DataTableIDPowerShellSessions -SearchRegularExpression  {
                                New-TableHeader -Color Blue -Alignment left -Title 'PowerShell Sessions' -FontSize 18 
                            } 
                        }
                        New-HTMLPanel {
                            
                            New-HTMLText `
                                -FontSize 12 `
                                -FontFamily 'Source Sans Pro' `
                                -Color Blue `
                                -Text 'Click On The Computer Icons To Automatically Locate Them Within The Table'
        
                            New-HTMLDiagram -Height '1000px' {
                                New-DiagramEvent -ID $DataTableIDPowerShellSessions -ColumnID 0
                                New-DiagramOptionsInteraction -Hover $true
                                New-DiagramOptionsManipulation 
                                New-DiagramOptionsPhysics -Enabled $true
                                New-DiagramOptionsLayout -RandomSeed 13
        
                                ###New-DiagramOptionsLayout -RandomSeed 500 -HierarchicalEnabled $true -HierarchicalDirection FromLeftToRight
                                
                                New-DiagramOptionsNodes `
                                    -BorderWidth 1 `
                                    -ColorBackground LightSteelBlue `
                                    -ColorHighlightBorder Orange `
                                    -ColorHoverBackground Orange
                                New-DiagramOptionsLinks `
                                    -FontSize 12 `
                                    -ColorHighlight Orange `
                                    -ColorHover Orange `
                                    -Length 5000
                                    # -ArrowsToEnabled $true `
                                    # -Color BlueViolet `
                                    # -ArrowsToType arrow `
                                    # -ArrowsFromEnabled $false `
                                New-DiagramOptionsEdges `
                                    -ColorHighlight Orange `
                                    -ColorHover Orange
        
                                foreach ($object in $script:PowerShellSessionsData) {
                                    New-DiagramNode `
                                        -Label  $object.PSComputerName `
                                        -To     "[$($object.PSComputerName)]`nAccount: $($object.Owner)" `
                                        -Image "$Dependencies\Images\Computer.jpg" `
                                        -size 25 `
                                        -FontColor  Blue `
                                        -LinkColor  Blue `
                                        -ArrowsFromEnabled
                                    New-DiagramNode `
                                        -Label  "[$($object.PSComputerName)]`nAccount: $($object.Owner)" `
                                        -To     "[$($object.PSComputerName)]`nClient IP: $($object.ClientIP)" `
                                        -Image "$Dependencies\Images\User.jpg" `
                                        -size 20 `
                                        -FontColor  Blue `
                                        -LinkColor  Blue `
                                        -ArrowsFromEnabled
                                    if ($object.ClientIP -in $script:PoShEasyWinIPAddress) {
                                        New-DiagramNode `
                                            -Label  "[$($object.PSComputerName)]`nClient IP: $($object.ClientIP)" `
                                            -Image "$Dependencies\Images\NIC.jpg" `
                                            -size 20 `
                                            -FontColor  Blue `
                                            -LinkColor  LightBlue `
                                            -ArrowsFromEnabled
                                    }
                                    else {
                                        New-DiagramNode `
                                            -Label  "[$($object.PSComputerName)]`nClient IP: $($object.ClientIP)" `
                                            -Image  "$Dependencies\Images\favicon.ico" `
                                            -size   20 `
                                            -LinkColor DarkGray `
                                            -ArrowsToEnabled
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }


        $PowerShellSessionsScriptBlock = { 
            Get-WSManInstance -ResourceURI Shell -Enumerate |
                ForEach-Object {
                    $Days    = [int]($_.ShellRunTime.split(".").split('D')[0].trim('P'))    * 24 * 60 * 60
                    $Hours   = [int]($_.ShellRunTime.split(".").split('T')[1].split('H')[0]) * 60 * 60
                    $Minutes = [int]($_.ShellRunTime.split(".").split('H')[1].split('M')[0]) * 60
                    $Seconds = [int]($_.ShellRunTime.split(".").split('M')[1].split('S')[0]) + $Minutes + $Hours + $Days
                    $_ | Add-Member -MemberType NoteProperty -Name LogonTime -Value (Get-Date).AddSeconds(-$Seconds) -PassThru
                } |
                Select-Object @{n='PSComputerName';e={$env:Computername}}, ClientIP, Owner, ProcessId, State, ShellRunTime, ShellInactivity, MemoryUsed, ProfileLoaded,
                LogonTime, @{n='CollectionType';e={'PowerShellSessions'}} 
        }


        if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
            foreach ($TargetComputer in $script:ComputerList) {
                if ($ComputerListProvideCredentialsCheckBox.Checked) {
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
        #         script:Individual-PSWriteHTML -Title 'PowerShell Sessions' { script:Start-PSWriteHTMLPowerShellSessions }
        #     }
        # } 
    }



































    ####################################################################################################
    # SMB Server Connection                                                                            #
    ####################################################################################################
    if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedItemsList -contains 'Endpoint SMB Server Connections') {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Query: Endpoint Application Crashes (30 Days)")
        

       <#
        function script:Start-PSWriteHTMLApplicationCrashes {

        # $ApplicationCrashesPerEndpoint       = $script:EndpointDataConsoleLogons | Select-Object PSComputerName, ApplicationName | Group-Object PSComputerName | Sort-Object Count, Name -Descending
        # $ApplicationCrashesCount             = $script:EndpointDataConsoleLogons | Select-Object PSComputerName, ApplicationName | Group-Object ApplicationName | Sort-Object Count, Name -Descending
        # $ApplicationCrashesTimeCreatedDay    = $script:EndpointDataConsoleLogons | Select-Object @{n='TimeCreatedDay';e={($_.TimeCreated -split ' ')[0]}} | Group-Object TimeCreatedDay | Sort-Object Name, Count
        # $ApplicationCrashesApplicationName   = $script:EndpointDataConsoleLogons | Select-Object PSComputerName, ApplicationName -Unique | Group-Object ApplicationName | Sort-Object Count, Name
        # $ApplicationCrashesModuleName        = $script:EndpointDataConsoleLogons | Select-Object PSComputerName, ModuleName -Unique | Group-Object ModuleName | Sort-Object Count, Name

           New-HTMLTab -Name 'Application Crashes' -IconBrands acquisitions-incorporated {
                ###########
                New-HTMLTab -Name 'Table Search' -IconRegular window-maximize {
                    New-HTMLSection -HeaderText 'Table Search' -Height 725 -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                        New-HTMLTable -DataTable $script:EndpointApplicationCrashes {
                            New-TableHeader -Color Blue -Alignment left -Title 'Application Crashes' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                    }
                }
                ###########
                New-HTMLTab -Name 'Pane Search' -IconSolid th {
                    New-HTMLSection -HeaderText 'Pane Search' -Height 725 -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                        New-HTMLTable -DataTable $script:EndpointApplicationCrashes {
                            New-TableHeader -Color Blue -Alignment left -Title 'Application Crashes' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength', 'searchPanes') -searchpane -SearchRegularExpression
                    }
                }
                ###########
                New-HTMLTab -Name 'Calendar' -IconRegular calendar-alt  {
                    New-HTMLSection -HeaderText 'Calendar' -Height 725 -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                        New-HTMLTable -DataTable $script:EndpointApplicationCrashes {
                            New-TableHeader -Color Blue -Alignment left -Title 'Calendar - Application Crashes' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression                       
                        New-HTMLCalendar {
                            foreach ($_ in $script:EndpointApplicationCrashes) {
                                New-CalendarEvent -StartDate $_.TimeCreated `
                                -Title "$($_.PSComputerName) [$($_.ApplicationName)]" `
                                -Description "$($_.PSComputerName) || Application: $($_.ApplicationName) || Module: $($_.ModuleName) || Message: $($_.Message)"
                            }
                        } -InitialView dayGridMonth #timeGridDay
                    }
                }
                ###########
                New-HTMLTab -Name 'Charts' -IconRegular chart-bar {
                    script:Generate-TablePieBarCharts -Title "Application Crashes Per Endpoint" -Data $ApplicationCrashesPerEndpoint
                    script:Generate-TablePieBarCharts -Title "Application Crashes Count" -Data $ApplicationCrashesCount
                    script:Generate-TablePieBarCharts -Title "Application Crashes Time Created Day" -Data $ApplicationCrashesTimeCreatedDay
                    script:Generate-TablePieBarCharts -Title "Application Crashes Application Name" -Data $  ApplicationCrashesApplicationName      
                    script:Generate-TablePieBarCharts -Title "Application Crashes Module Name" -Data $ApplicationCrashesModuleName
                } 
            
                ###########
                New-HTMLTab -TabName 'Graph & Table' -IconSolid bezier-curve {
                    $DataTableIDApplicationCrashes = Get-Random -Minimum 100000 -Maximum 2000000
                    New-HTMLSection -HeaderText 'Application Crashes' -CanCollapse {
                        New-HTMLPanel -Width 40% {
                            New-HTMLTable -DataTable $script:EndpointApplicationCrashes -DataTableID $DataTableIDApplicationCrashes -SearchRegularExpression  {
                                New-TableHeader -Color Blue -Alignment left -Title 'Application Crashes' -FontSize 18 
                            } 
                        }
                        New-HTMLPanel {
                            
                            New-HTMLText `
                                -FontSize 12 `
                                -FontFamily 'Source Sans Pro' `
                                -Color Blue `
                                -Text 'Click On The Computer Icons To Automatically Locate Them Within The Table'
        
                            New-HTMLDiagram -Height '1000px' {
                                New-DiagramEvent -ID $DataTableIDApplicationCrashes -ColumnID 5
                                New-DiagramOptionsInteraction -Hover $true
                                New-DiagramOptionsManipulation 
                                New-DiagramOptionsPhysics -Enabled $true
                                New-DiagramOptionsLayout `
                                    -RandomSeed 13
        
                                ###New-DiagramOptionsLayout -RandomSeed 500 -HierarchicalEnabled $true -HierarchicalDirection FromLeftToRight
                                
                                New-DiagramOptionsNodes `
                                    -BorderWidth 1 `
                                    -ColorBackground LightSteelBlue `
                                    -ColorHighlightBorder Orange `
                                    -ColorHoverBackground Orange
                                New-DiagramOptionsLinks `
                                    -FontSize 12 `
                                    -ColorHighlight Orange `
                                    -ColorHover Orange `
                                    -Length 5000
                                    # -ArrowsToEnabled $true `
                                    # -Color BlueViolet `
                                    # -ArrowsToType arrow `
                                    # -ArrowsFromEnabled $false `
                                New-DiagramOptionsEdges `
                                    -ColorHighlight Orange `
                                    -ColorHover Orange
        
                                $CrashedApps = @()
                                foreach ($object in $script:EndpointApplicationCrashes) {
                                    New-DiagramNode `
                                        -Label  $object.PSComputerName `
                                        -To     "[$($object.PSComputerName)]`nApplication: $($object.ApplicationName)" `
                                        -Image "$Dependencies\Images\Computer.jpg" `
                                        -size 25 `
                                        -FontColor  Blue `
                                        -LinkColor  Blue
                                    if ("$($object.PSComputerName) : $($object.ApplicationName) : $($object.ModuleName)" -notin $CrashedApps){
                                        $CrashedApps += "$($object.PSComputerName) : $($object.ApplicationName) : $($object.ModuleName)"
                                        New-DiagramNode `
                                            -Label  "[$($object.PSComputerName)]`nApplication: $($object.ApplicationName)" `
                                            -To     "[$($object.PSComputerName)]`nModule: $($object.ModuleName)" `
                                            -shape dot `
                                            -size 10 `
                                            -FontColor  Blue `
                                            -LinkColor  Blue
                                        New-DiagramNode `
                                            -Label  "[$($object.PSComputerName)]`nModule: $($object.ModuleName)" `
                                            -shape triangle `
                                            -size 10 `
                                            -FontColor  Blue `
                                            -LinkColor  LightBlue
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }       
       #>


        # $script:EndpointDataConsoleLogons = {

       # }


        #if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
#            foreach ($TargetComputer in $script:ComputerList) {
#                if ($ComputerListProvideCredentialsCheckBox.Checked) {
#                    if (!$script:Credential) { Create-NewCredentials }
#
#                    Invoke-Command -ScriptBlock $ConsoleLogonsScriptBlock `
#                    -ComputerName $TargetComputer `
#                    -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
#                    -Credential $script:Credential
#            
#                    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `$ConsoleLogonsScriptBlock -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)' -Credential $script:Credential"
#                }
#                else {
#                    Invoke-Command -ScriptBlock $ConsoleLogonsScriptBlock `
#                    -ComputerName $TargetComputer `
#                    -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"
#                                
#                    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `$ConsoleLogonsScriptBlock -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)'"
#                }
#            }
#           Monitor-Jobs -CollectionName $CollectionName -MonitorMode -PSWriteHTMLSwitch -PSWriteHTML 'EndpointDataConsoleLogons' -PSWriteHTMLFilePath $script:PSWriteHTMLFilePath
        #}
        #elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Session Based') {
           # $script:EndpointDataConsoleLogons = Invoke-Command -ScriptBlock $ConsoleLogonsScriptBlock -Session $PSSession
        #}


#        $script:ProgressBarQueriesProgressBar.Value += 1
#        $script:ProgressBarQueriesProgressBar.Refresh()


#        if ($script:PSWriteHTMLIndividualWebPagesCheckbox.checked -eq $true -and $script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
#           if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedListBox.CheckedItems.Count -gt 0) {
#                script:Individual-PSWriteHTML -Title 'xxxxxxxxxxxx' { script:Start-PSWriteHTMLxxxxxxxxxxxxx }        
#           }
#        }
    }
























    ####################################################################################################
    # Application Crashes
    ####################################################################################################
    if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedItemsList -contains 'Endpoint Application Crashes (30 Days)') {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Query: Endpoint Application Crashes (30 Days)")
        

        function script:Start-PSWriteHTMLApplicationCrashes {

            $ApplicationCrashesPerEndpoint       = $script:EndpointApplicationCrashes | Select-Object PSComputerName, ApplicationName | Group-Object PSComputerName | Sort-Object Count, Name -Descending
            $ApplicationCrashesCount             = $script:EndpointApplicationCrashes | Select-Object PSComputerName, ApplicationName | Group-Object ApplicationName | Sort-Object Count, Name -Descending
            $ApplicationCrashesTimeCreatedDay    = $script:EndpointApplicationCrashes | Select-Object @{n='TimeCreatedDay';e={($_.TimeCreated -split ' ')[0]}} | Group-Object TimeCreatedDay | Sort-Object Name, Count
            $ApplicationCrashesApplicationName   = $script:EndpointApplicationCrashes | Select-Object PSComputerName, ApplicationName -Unique | Group-Object ApplicationName | Sort-Object Count, Name
            $ApplicationCrashesModuleName        = $script:EndpointApplicationCrashes | Select-Object PSComputerName, ModuleName -Unique | Group-Object ModuleName | Sort-Object Count, Name

            New-HTMLTab -Name 'Application Crashes' -IconBrands acquisitions-incorporated {
                ###########
                New-HTMLTab -Name 'Table Search' -IconRegular window-maximize {
                    New-HTMLSection -HeaderText 'Table Search' -Height 725 -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                        New-HTMLTable -DataTable $script:EndpointApplicationCrashes {
                            New-TableHeader -Color Blue -Alignment left -Title 'Application Crashes' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                    }
                }
                ###########
                New-HTMLTab -Name 'Pane Search' -IconSolid th {
                    New-HTMLSection -HeaderText 'Pane Search' -Height 725 -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                        New-HTMLTable -DataTable $script:EndpointApplicationCrashes {
                            New-TableHeader -Color Blue -Alignment left -Title 'Application Crashes' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength', 'searchPanes') -searchpane -SearchRegularExpression
                    }
                }
                ###########
                New-HTMLTab -Name 'Calendar' -IconRegular calendar-alt  {
                    New-HTMLSection -HeaderText 'Calendar' -Height 725 -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                        New-HTMLTable -DataTable $script:EndpointApplicationCrashes {
                            New-TableHeader -Color Blue -Alignment left -Title 'Calendar - Application Crashes' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression                       
                        New-HTMLCalendar {
                            foreach ($_ in $script:EndpointApplicationCrashes) {
                                New-CalendarEvent -StartDate $_.TimeCreated `
                                -Title "$($_.PSComputerName) [$($_.ApplicationName)]" `
                                -Description "$($_.PSComputerName) || Application: $($_.ApplicationName) || Module: $($_.ModuleName) || Message: $($_.Message)"
                            }
                        } -InitialView dayGridMonth #dayGridMonth
                    }
                }
                ###########
                New-HTMLTab -Name 'Charts' -IconRegular chart-bar {
                    script:Generate-TablePieBarCharts -Title "Application Crashes Per Endpoint" -Data $ApplicationCrashesPerEndpoint
                    script:Generate-TablePieBarCharts -Title "Application Crashes Count" -Data $ApplicationCrashesCount
                    script:Generate-TablePieBarCharts -Title "Application Crashes Time Created Day" -Data $ApplicationCrashesTimeCreatedDay
                    script:Generate-TablePieBarCharts -Title "Application Crashes Application Name" -Data $ApplicationCrashesApplicationName
                    script:Generate-TablePieBarCharts -Title "Application Crashes Module Name" -Data $ApplicationCrashesModuleName
                } 
            
                ###########
                New-HTMLTab -TabName 'Graph & Table' -IconSolid bezier-curve {
                    $DataTableIDApplicationCrashes = Get-Random -Minimum 100000 -Maximum 2000000
                    New-HTMLSection -HeaderText 'Application Crashes' -CanCollapse {
                        New-HTMLPanel -Width 40% {
                            New-HTMLTable -DataTable $script:EndpointApplicationCrashes -DataTableID $DataTableIDApplicationCrashes -SearchRegularExpression  {
                                New-TableHeader -Color Blue -Alignment left -Title 'Application Crashes' -FontSize 18 
                            } 
                        }
                        New-HTMLPanel {
                            
                            New-HTMLText `
                                -FontSize 12 `
                                -FontFamily 'Source Sans Pro' `
                                -Color Blue `
                                -Text 'Click On The Computer Icons To Automatically Locate Them Within The Table'
        
                            New-HTMLDiagram -Height '1000px' {
                                New-DiagramEvent -ID $DataTableIDApplicationCrashes -ColumnID 5
                                New-DiagramOptionsInteraction -Hover $true
                                New-DiagramOptionsManipulation 
                                New-DiagramOptionsPhysics -Enabled $true
                                New-DiagramOptionsLayout `
                                    -RandomSeed 13
        
                                ###New-DiagramOptionsLayout -RandomSeed 500 -HierarchicalEnabled $true -HierarchicalDirection FromLeftToRight
                                
                                New-DiagramOptionsNodes `
                                    -BorderWidth 1 `
                                    -ColorBackground LightSteelBlue `
                                    -ColorHighlightBorder Orange `
                                    -ColorHoverBackground Orange
                                New-DiagramOptionsLinks `
                                    -FontSize 12 `
                                    -ColorHighlight Orange `
                                    -ColorHover Orange `
                                    -Length 5000
                                    # -ArrowsToEnabled $true `
                                    # -Color BlueViolet `
                                    # -ArrowsToType arrow `
                                    # -ArrowsFromEnabled $false `
                            New-DiagramOptionsEdges `
                                    -ColorHighlight Orange `
                                    -ColorHover Orange
        
                                $CrashedApps = @()
                                foreach ($object in $script:EndpointApplicationCrashes) {
                                    New-DiagramNode `
                                        -Label  $object.PSComputerName `
                                        -To     "[$($object.PSComputerName)]`nApplication: $($object.ApplicationName)" `
                                        -Image "$Dependencies\Images\Computer.jpg" `
                                        -size 25 `
                                        -FontColor  Blue `
                                        -LinkColor  Blue
                                    if ("$($object.PSComputerName) : $($object.ApplicationName) : $($object.ModuleName)" -notin $CrashedApps){
                                        $CrashedApps += "$($object.PSComputerName) : $($object.ApplicationName) : $($object.ModuleName)"
                                        New-DiagramNode `
                                            -Label  "[$($object.PSComputerName)]`nApplication: $($object.ApplicationName)" `
                                            -To     "[$($object.PSComputerName)]`nModule: $($object.ModuleName)" `
                                            -shape dot `
                                            -size 10 `
                                            -FontColor  Blue `
                                            -LinkColor  Blue
                                        New-DiagramNode `
                                            -Label  "[$($object.PSComputerName)]`nModule: $($object.ModuleName)" `
                                            -shape triangle `
                                            -size 10 `
                                            -FontColor  Blue `
                                            -LinkColor  LightBlue
                                    }
        
                                    <#
                                    New-DiagramNode `
                                        -Label  $object.PSComputerName `
                                        -To     "[$($Object.PSComputerName)]`n$($object.ApplicationName)" `
                                        -Image  "$Dependencies\Images\Computer.jpg" `
                                        -Size   50 `
                                        -FontSize   20 `
                                        -FontColor  Blue `
                                        -LinkColor  Blue `
                                        -ArrowsToEnabled
                                    New-DiagramNode `
                                        -Label  "[$($Object.PSComputerName)]`n$($object.ApplicationName)" `
                                        -To     "[$($Object.PSComputerName)]`n$($object.ModuleName)" `
                                        -shape dot `
                                        -size 10 `
                                        -FontColor  Blue `
                                        -LinkColor  Blue
                                    New-DiagramNode `
                                        -Label  "[$($Object.PSComputerName)]`n$($object.ModuleName)" `
                                        -shape dot `
                                        -size 10 `
                                        -FontColor  Blue `
                                        -LinkColor  Blue
                                    #>
                                }
                            }
                        }
                    }
                }
            }
        }

        $ApplicationCrashesScriptblock = {
            $ApplicationCrashes = Get-WinEvent -FilterHashtable @{logname = 'Application'; id = 1000; StartTime = (Get-Date).AddMonths(-3)}

            ForEach ($AppCrash in $ApplicationCrashes) {
                if ($AppCrash.Message -match 'Faulting'){
                        $AppName = ($AppCrash.message.Split("`n") | Where-Object {$_ -match 'Faulting Application Name'}).split(':')[1].trim().split(',')[0].trim()
                        $ModName = ($AppCrash.message.Split("`n") | Where-Object {$_ -match 'Faulting Module Name'}).split(':')[1].trim().split(',')[0].trim()
                        $AppCrash | 
                            Add-Member -MemberType NoteProperty -Name 'ApplicationName' -Value $AppName -PassThru |
                            Add-Member -MemberType NoteProperty -Name 'ModuleName' -Value $ModName -PassThru
                }
            }
        }


        if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
            foreach ($TargetComputer in $script:ComputerList) {
                if ($ComputerListProvideCredentialsCheckBox.Checked) {
                    if (!$script:Credential) { Create-NewCredentials }

                    Invoke-Command -ScriptBlock $ApplicationCrashesScriptblock `
                    -ComputerName $TargetComputer `
                    -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
                    -Credential $script:Credential
            
                    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `$ApplicationCrashesScriptblock -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)' -Credential `$script:Credential"
                }
                else {
                    Invoke-Command -ScriptBlock $ApplicationCrashesScriptblock `
                    -ComputerName $TargetComputer `
                    -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"
                                
                    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `$ApplicationCrashesScriptblock -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)'"
                }
            }
            Monitor-Jobs -CollectionName $CollectionName -MonitorMode -PSWriteHTMLSwitch -PSWriteHTML 'EndpointApplicationCrashes' -PSWriteHTMLFilePath $script:PSWriteHTMLFilePath
        }
        elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Session Based') {
            $script:EndpointApplicationCrashes = Invoke-Command -ScriptBlock $ApplicationCrashesScriptblock -Session $PSSession | 
            Select-Object MachineName, TimeCreated, ApplicationName, ModuleName, Message, PSComputerName, LogName, ProviderName, Level, RecordId, ProcessId, ThreadId, UserID
        }
                            

        $script:ProgressBarQueriesProgressBar.Value += 1
        $script:ProgressBarQueriesProgressBar.Refresh()


        # if ($script:PSWriteHTMLIndividualWebPagesCheckbox.checked -eq $true -and $script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
        #     if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedListBox.CheckedItems.Count -gt 0) {
        #         script:Individual-PSWriteHTML -Title 'Application Crashes' { script:Start-PSWriteHTMLApplicationCrashes }
        #     }
        # }
    }































    ####################################################################################################
    # Logon Activity                                                                                   #
    ####################################################################################################
    if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedItemsList -contains 'Endpoint Logon Activity (30 Days)') {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Query: Endpoint Logon Activity (30 Days)")

        function script:Start-PSWriteHTMLLogonActivity {
            $LogonActivityTimeStampDaySortDay   = $script:EndpointLogonActivity | Select-Object @{n='TimeStampDay';e={($_.TimeStamp -split ' ')[0]}} | Group-Object TimeStampDay | Sort-Object Name, Count
            $LogonActivityTimeStampDaySortCount = $script:EndpointLogonActivity | Select-Object @{n='TimeStampDay';e={($_.TimeStamp -split ' ')[0]}} | Group-Object TimeStampDay | Sort-Object Count, Name
            $LogonActivityLogonType             = $script:EndpointLogonActivity | Select-Object LogonType | Group-Object LogonType | Sort-Object Count, Name
            $LogonActivityWorkstationName       = $script:EndpointLogonActivity | Select-Object WorkstationName | Where-Object {$_.WorkStationName -ne '' -and $_.WorkStationName -ne '-'} | Group-Object WorkstationName | Sort-Object Count, Name
            $LogonActivitySourceNetworkAddress  = $script:EndpointLogonActivity | Select-Object SourceNetworkAddress | Where-Object {$_.SourceNetworkAddress -ne '' -and $_.SourceNetworkAddress -ne '-'} | Group-Object SourceNetworkAddress | Sort-Object Count, Name
            $LogonActivityTimeStampLogonLocalSystem   = $script:EndpointLogonActivity | Where-Object LogonType -eq LocalSystem | Select-Object @{n='TimeStampDay';e={($_.TimeStamp -split ' ')[0]}}, logontype | Group-Object TimeStampDay  | Sort-Object Name, Count
            $LogonActivityTimeStampLogonInteractive   = $script:EndpointLogonActivity | Where-Object LogonType -eq Interactive | Select-Object @{n='TimeStampDay';e={($_.TimeStamp -split ' ')[0]}}, logontype | Group-Object TimeStampDay  | Sort-Object Name, Count
            $LogonActivityTimeStampLogonNetwork       = $script:EndpointLogonActivity | Where-Object LogonType -eq Network | Select-Object @{n='TimeStampDay';e={($_.TimeStamp -split ' ')[0]}}, logontype | Group-Object TimeStampDay  | Sort-Object Name, Count
                #very noisy
            $LogonActivityTimeStampLogonBatch         = $script:EndpointLogonActivity | Where-Object LogonType -eq Batch | Select-Object @{n='TimeStampDay';e={($_.TimeStamp -split ' ')[0]}}, logontype | Group-Object TimeStampDay  | Sort-Object Name, Count
            $LogonActivityTimeStampLogonService       = $script:EndpointLogonActivity | Where-Object LogonType -eq Service | Select-Object @{n='TimeStampDay';e={($_.TimeStamp -split ' ')[0]}}, logontype | Group-Object TimeStampDay  | Sort-Object Name, Count
            $LogonActivityTimeStampLogonUnlock        = $script:EndpointLogonActivity | Where-Object LogonType -eq Unlock | Select-Object @{n='TimeStampDay';e={($_.TimeStamp -split ' ')[0]}}, logontype | Group-Object TimeStampDay  | Sort-Object Name, Count
            $LogonActivityTimeStampLogonNetworkClearText    = $script:EndpointLogonActivity | Where-Object LogonType -eq NetworkClearText | Select-Object @{n='TimeStampDay';e={($_.TimeStamp -split ' ')[0]}}, logontype | Group-Object TimeStampDay  | Sort-Object Name, Count
            $LogonActivityTimeStampLogonNewCredentials      = $script:EndpointLogonActivity | Where-Object LogonType -eq NewCredentials | Select-Object @{n='TimeStampDay';e={($_.TimeStamp -split ' ')[0]}}, logontype | Group-Object TimeStampDay  | Sort-Object Name, Count
            $LogonActivityTimeStampLogonRemoteInteractive   = $script:EndpointLogonActivity | Where-Object LogonType -eq RemoteInteractive | Select-Object @{n='TimeStampDay';e={($_.TimeStamp -split ' ')[0]}}, logontype | Group-Object TimeStampDay  | Sort-Object Name, Count
            $LogonActivityTimeStampLogonCachedInteractive   = $script:EndpointLogonActivity | Where-Object LogonType -eq CachedInteractive | Select-Object @{n='TimeStampDay';e={($_.TimeStamp -split ' ')[0]}}, logontype | Group-Object TimeStampDay  | Sort-Object Name, Count
            $LogonActivityTimeStampLogonCachedRemoteInteractive   = $script:EndpointLogonActivity | Where-Object LogonType -eq CachedRemoteInteractive | Select-Object @{n='TimeStampDay';e={($_.TimeStamp -split ' ')[0]}}, logontype | Group-Object TimeStampDay  | Sort-Object Name, Count
            $LogonActivityTimeStampLogonCachedUnlock              = $script:EndpointLogonActivity | Where-Object LogonType -eq CachedUnlock | Select-Object @{n='TimeStampDay';e={($_.TimeStamp -split ' ')[0]}}, logontype | Group-Object TimeStampDay  | Sort-Object Name, Count
    
            New-HTMLTab -Name 'Logon Activity' -IconBrands acquisitions-incorporated {
                ###########
                New-HTMLTab -Name 'Table Search' -IconRegular window-maximize {
                    New-HTMLSection -HeaderText 'Table Search' -Height 725 -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                        New-HTMLTable -DataTable $script:EndpointLogonActivity {
                            New-TableHeader -Color Blue -Alignment left -Title 'Logon Type 3 (Network) have been excluded due to excessive logs. (i.e. remote connection to shared folder)' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                    }
                }
                ###########
                New-HTMLTab -Name 'Pane Search' -IconSolid th {
                    New-HTMLSection -HeaderText 'Pane Search' -Height 725 -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                        New-HTMLTable -DataTable $script:EndpointLogonActivity {
                            New-TableHeader -Color Blue -Alignment left -Title 'Logon Type 3 (Network) have been excluded due to excessive logs. (i.e. remote connection to shared folder)' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength', 'searchPanes') -searchpane -SearchRegularExpression
                    }
                }
                ###########
                New-HTMLTab -Name 'Calendar' -IconRegular calendar-alt  {
                    New-HTMLSection -HeaderText 'Calendar' -Height 725 -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                        New-HTMLTable -DataTable $script:EndpointLogonActivity {
                            New-TableHeader -Color Blue -Alignment left -Title 'Calendar - Logon Activity' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression                       
                        New-HTMLCalendar {
                            foreach ($_ in $script:EndpointLogonActivity) {
                                New-CalendarEvent -StartDate $_.TimeStamp `
                                -Title "$($_.PSComputerName) [$($_.UserAccount)] $($_.LogonType)" `
                                -Description "$($_.PSComputerName) || Account: $($_.UserAccount) || $($_.LogonType) || $($_.WorkStationName) || $($_.SourceNetworkAddress)"
                            }
                        } -InitialView dayGridMonth #timeGridDay
                    }
                }
                ###########
                New-HTMLTab -Name 'Charts' -IconRegular chart-bar {
                    script:Generate-TablePieBarCharts -Title "Logon Activity (Day Sort Day)" -Data $LogonActivityTimeStampDaySortDay
                    script:Generate-TablePieBarCharts -Title "Logon Activity (Day Sort Count)" -Data $LogonActivityTimeStampDaySortCount
                    script:Generate-TablePieBarCharts -Title "Workstation Name" -Data $LogonActivityWorkstationName
                    script:Generate-TablePieBarCharts -Title "Source Network Address" -Data $LogonActivitySourceNetworkAddress
                    script:Generate-TablePieBarCharts -Title "Logon Type" -Data $LogonActivityLogonType
                    script:Generate-TablePieBarCharts -Title "Logon Local System" -Data $LogonActivityTimeStampLogonLocalSystem
                    script:Generate-TablePieBarCharts -Title "Logon Interactive" -Data $LogonActivityTimeStampLogonInteractive
                    script:Generate-TablePieBarCharts -Title "Logon Network" -Data $LogonActivityTimeStampLogonNetwork
                    script:Generate-TablePieBarCharts -Title "Logon Batch" -Data $LogonActivityTimeStampLogonBatch
                    script:Generate-TablePieBarCharts -Title "Logon Service" -Data $LogonActivityTimeStampLogonService
                    script:Generate-TablePieBarCharts -Title "Logon Unlock" -Data $LogonActivityTimeStampLogonUnlock
                    script:Generate-TablePieBarCharts -Title "Logon Network Clear Text" -Data $LogonActivityTimeStampLogonNetworkClearText
                    script:Generate-TablePieBarCharts -Title "Logon New Credentials" -Data $LogonActivityTimeStampLogonNewCredentials
                    script:Generate-TablePieBarCharts -Title "Logon Remote Interactive" -Data $LogonActivityTimeStampLogonRemoteInteractive
                    script:Generate-TablePieBarCharts -Title "Logon Cached Interactive" -Data $LogonActivityTimeStampLogonCachedInteractive
                    script:Generate-TablePieBarCharts -Title "Logon Cached Remote Interactive" -Data $LogonActivityTimeStampLogonCachedRemoteInteractive
                    script:Generate-TablePieBarCharts -Title "Logon Cached Unlock" -Data $LogonActivityTimeStampLogonCachedUnlock
                }
            }
        }
        

        $LogonActivityScriptblock = {
            Function Get-AccountLogonActivity {
                Param (
                    [datetime]$StartTime,
                    [datetime]$EndTime
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
                    ID        = 4624
                }
                if ($PSBoundParameters.ContainsKey('StartTime')){
                    $FilterHashTable['StartTime'] = $StartTime
                }
                if ($PSBoundParameters.ContainsKey('EndTime')){
                    $FilterHashTable['EndTime'] = $EndTime
                }

                Get-WinEvent -FilterHashtable $FilterHashTable `
                | Where-Object {$_.Type -ne 3} `
                | Set-Variable GetAccountActivity -Force

                $AccountActivityTextboxtext = $AccountActivityTextbox.lines | Where-Object {$_ -ne ''}
                if (($AccountActivityTextboxtext.count -gt 0) -and -not ($AccountActivityTextboxtext -eq 'Default is All Accounts')) {
                    $GetAccountActivity | ForEach-Object {
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
                    } | Set-Variable ObtainedAccountActivity
                    ForEach ($AccountName in $AccountActivityTextboxtext) {
                        $ObtainedAccountActivity | Where-Object {$_.UserAccount -match $AccountName} | Sort-Object TimeStamp
                    }
                }
                else {
                    $GetAccountActivity | ForEach-Object {
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
                }
            }
            Get-AccountLogonActivity -StartTime (Get-Date).AddMonths(-1) | Where-Object type -ne 3
        }


        if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
            foreach ($TargetComputer in $script:ComputerList) {
                if ($ComputerListProvideCredentialsCheckBox.Checked) {
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
        #         script:Individual-PSWriteHTML -Title 'Logon Activity' -Data { script:Start-PSWriteHTMLLogonActivity }
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

        if ($ComputerListProvideCredentialsCheckBox.Checked) {
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
                if ($ComputerListProvideCredentialsCheckBox.Checked) {
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
                if ($ComputerListProvideCredentialsCheckBox.Checked) {
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
    $script:PSWriteHTMLSupportOkay -eq $true -and `
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
                script:Start-PSWriteHTMLProcessData
            } 
            if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $script:PSWriteHTMLSupportOkay -eq $true -and $PSWriteHTMLCheckedItemsList -contains 'Endpoint Network Connections') {
                script:Start-PSWriteHTMLNetworkConnections
            }
            if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedItemsList -contains 'Endpoint Console Logons') {
                script:Start-PSWriteHTMLConsoleLogons
            }
            if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedItemsList -contains 'Endpoint PowerShell Sessions') {
                script:Start-PSWriteHTMLPowerShellSessions
            } 
            if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedItemsList -contains 'Endpoint Logon Activity (30 Days)') {
                script:Start-PSWriteHTMLLogonActivity
            }
            if ($script:PSWriteHTMLFormOkay -eq $true -and $script:ComputerList.count -gt 0 -and $PSWriteHTMLCheckedItemsList -contains 'Endpoint Application Crashes (30 Days)') {
                script:Start-PSWriteHTMLApplicationCrashes
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

if ($script:RollCredentialsState -and $ComputerListProvideCredentialsCheckBox.checked) {
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


