####################################################################################################
# ScriptBlocks
####################################################################################################

$EnumerationPortScanPortQuickPickComboBoxItemsAddRange =@(
    "N/A"
    "Nmap Top 100 Ports"
    "Nmap Top 1000 Ports"
    "Well-Known Ports (0-1023)"
    "Registered Ports (1024-49151)"
    "Dynamic Ports (49152-65535)"
    "All Ports (0-65535)"
    "Previous Scan - Parses LogFile.txt"
    "File: CustomPortsToScan.txt"
)

$EnumerationPortScanPortQuickPickComboBoxAdd_Click = {
    #Removed For Testing#$ResultsListBox.Items.Clear()
    if ($EnumerationPortScanPortQuickPickComboBox.SelectedItem -match "N/A") { $ResultsListBox.Items.Add("") }
    elseif ($EnumerationPortScanPortQuickPickComboBox.SelectedItem -match "Nmap Top 100 Ports") { $ResultsListBox.Items.Add("Will conduct a connect scan the top 100 ports as reported by nmap on each target.") }
    elseif ($EnumerationPortScanPortQuickPickComboBox.SelectedItem -match "Nmap Top 1000 Ports") { $ResultsListBox.Items.Add("Will conduct a connect scan the top 1000 ports as reported by nmap on each target.") }
    elseif ($EnumerationPortScanPortQuickPickComboBox.SelectedItem -match "Well-Known Ports") { $ResultsListBox.Items.Add("Will conduct a connect scan all Well-Known Ports on each target [0-1023].") }
    elseif ($EnumerationPortScanPortQuickPickComboBox.SelectedItem -match "Registered Ports") { $ResultsListBox.Items.Add("Will conduct a connect scan all Registered Ports on each target [1024-49151].") }
    elseif ($EnumerationPortScanPortQuickPickComboBox.SelectedItem -match "Dynamic Ports") { $ResultsListBox.Items.Add("Will conduct a connect scan all Dynamic Ports, AKA Ephemeral Ports, on each target [49152-65535].") }
    elseif ($EnumerationPortScanPortQuickPickComboBox.SelectedItem -match "All Ports") { $ResultsListBox.Items.Add("Will conduct a connect scan all 65535 ports on each target.") }
    elseif ($EnumerationPortScanPortQuickPickComboBox.SelectedItem -match "Previous Scan") {
        $LastPortsScanned = $((Get-Content $LogFile | Select-String -Pattern "Ports To Be Scanned" | Select-Object -Last 1) -split '  ')[2]
        $LastPortsScannedConvertedToList = @()
        Foreach ($Port in $(($LastPortsScanned) -split',')){ $LastPortsScannedConvertedToList += $Port }
        $ResultsListBox.Items.Add("Will conduct a connect scan on ports listed below.")
        $ResultsListBox.Items.Add("Previous Ports Scanned:  $($LastPortsScannedConvertedToList | Where {$_ -ne ''})")
    }
    elseif ($EnumerationPortScanPortQuickPickComboBox.SelectedItem -match "CustomPortsToScan") {
        $CustomSavedPorts = $($PortList="";(Get-Content $CustomPortsToScan | foreach {$PortList += $_ + ','}); $PortList)
        $CustomSavedPortsConvertedToList = @()
        Foreach ($Port in $(($CustomSavedPorts) -split',')){ $CustomSavedPortsConvertedToList += $Port }
        $ResultsListBox.Items.Add("Will conduct a connect scan on ports listed below.")
        $ResultsListBox.Items.Add("Previous Ports Scanned:  $($CustomSavedPortsConvertedToList | Where {$_ -ne ''})")
    }
}

$EnumerationComputerListBoxAddToListButtonAdd_Click = {
    $InformationTabControl.SelectedTab = $Section3ResultsTab

    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Enumeration:  Added $($EnumerationComputerListBox.SelectedItems.Count) IPs")
    #Removed For Testing#
    $ResultsListBox.Items.Clear()
    foreach ($Selected in $EnumerationComputerListBox.SelectedItems) {
        if ($script:ComputerTreeViewData.Name -contains $Selected) {
            Message-TreeViewNodeAlreadyExists -Endpoint -Message "Port Scan Import:  Warning" -Computer $Selected
        }
        else {
            $ComputerAndAccountTreeViewTabControl.SelectedTab = $ComputerTreeviewTab
            $script:ComputerTreeNodeComboBox.SelectedItem = 'CanonicalName'

            $CanonicalName = $($($Computer.CanonicalName) -replace $Computer.Name,"" -replace $Computer.CanonicalName.split('/')[0],"").TrimEnd("/")
            Add-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category '/Unknown' -Entry $Selected -ToolTip 'Enumeration Scan' -IPv4Address $Computer.IPv4Address
            $ResultsListBox.Items.Add("$($Selected) has been added to /Unknown category")

            $ComputerTreeNodeAddHostnameIP = New-Object PSObject -Property @{
                Name            = $Selected
                OperatingSystem = 'Unknown'
                CanonicalName   = '/Unknown'
                IPv4Address     = $Selected
            }
            $script:ComputerTreeViewData += $ComputerTreeNodeAddHostnameIP
        }
    }
    $script:ComputerTreeView.ExpandAll()
    Normalize-TreeViewData -Endpoint
    Save-TreeViewData -Endpoint
}

$EnumerationResolveDNSNameButtonAdd_Click = {
    if ($($EnumerationComputerListBox.SelectedItems).count -eq 0){
        [system.media.systemsounds]::Exclamation.play()
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("DNS Resolution:  Make at least one selection")
    }
    else {
        if (Verify-Action -Title "Verification: Resolve DNS" -Question "Conduct a DNS Resolution of the following?" -Computer $($EnumerationComputerListBox.SelectedItems -join ', ')) {
            #for($i = 0; $i -lt $EnumerationComputerListBox.Items.Count; $i++) { $EnumerationComputerListBox.SetSelected($i, $true) }

            #$EnumerationComputerListBoxSelected = $EnumerationComputerListBox.SelectedItems
            #$EnumerationComputerListBox.Items.Clear()

            # Resolve DNS Names
            $DNSResolutionList = @()
            foreach ($Selected in $($EnumerationComputerListBox.SelectedItems)) {
                $DNSResolution      = (((Resolve-DnsName $Selected).NameHost).split('.'))[0]
                $DNSResolutionList += $DNSResolution
                $EnumerationComputerListBox.Items.Remove($Selected)
            }
            foreach ($Item in $DNSResolutionList) { $EnumerationComputerListBox.Items.Add($Item) }
        }
        else {
            [system.media.systemsounds]::Exclamation.play()
            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("DNS Resolution:  Cancelled")
        }
    }
}


$EnumerationPortScanExecutionButtonAdd_Click = {
    if (Verify-Action -Title "Verification: Port Scan" -Question "Conduct a Port Scan of the following?" -Computer $(
        $CollectionName = 'Enumeration Scanning'
    
        if ( $script:EnumerationPortScanSpecificComputerNodeCheckbox.checked ) {
            Generate-ComputerList
            ($script:ComputerList.split(',') -join ', ')
        }
        else {
            if ($EnumerationPortScanSpecificIPTextbox.Text -and $EnumerationPortScanIPRangeNetworkTextbox.Text -and $EnumerationPortScanIPRangeFirstTextbox.Text -and $EnumerationPortScanIPRangeLastTextbox.Text ) {
                $EnumerationPortScanSpecificIPTextbox.Text + ', ' + $EnumerationPortScanIPRangeNetworkTextbox.Text + '.' + $EnumerationPortScanIPRangeFirstTextbox.Text + '-' + $EnumerationPortScanIPRangeLastTextbox.Text
            }
            elseif ($EnumerationPortScanSpecificIPTextbox.Text) {
                $EnumerationPortScanSpecificIPTextbox.Text
            }
            elseif ($EnumerationPortScanIPRangeNetworkTextbox.Text -and $EnumerationPortScanIPRangeFirstTextbox.Text -and $EnumerationPortScanIPRangeLastTextbox.Text) {
                $EnumerationPortScanIPRangeNetworkTextbox.Text + '.' + $EnumerationPortScanIPRangeFirstTextbox.Text + '-' + $EnumerationPortScanIPRangeLastTextbox.Text
            }
        }
        )) {
        $ResultsListBox.Items.Clear()
        

        if ($script:EnumerationPortScanSpecificComputerNodeCheckbox.checked) {
            $EndpointString = ''
            foreach ($item in $script:ComputerList) {$EndpointString += "$item`n"}
        }
        else {
            $EndpointString = 'Details are listed in the section beneath'
        }
                
        $InputValues = @"
===========================================================================
Collection Name:
===========================================================================
$CollectionName

===========================================================================
Execution Time:
===========================================================================
$(Get-Date)

===========================================================================
Credentials:
===========================================================================
$($script:Credential.UserName)

===========================================================================
Endpoints:
===========================================================================
$($EndpointString.trim())

===========================================================================
Specified IPs To Scan:
===========================================================================
$($EnumerationPortScanSpecificIPTextbox.Text)

===========================================================================
Network Range:
===========================================================================
$($EnumerationPortScanIPRangeNetworkTextbox.Text):$($EnumerationPortScanIPRangeFirstTextbox.Text)-$($EnumerationPortScanIPRangeLastTextbox.Text)

===========================================================================
Quick Port Selection:
===========================================================================
$($EnumerationPortScanPortQuickPickComboBox.SelectedItem)

===========================================================================
Specified Ports To Scan:
===========================================================================
$($EnumerationPortScanSpecificPortsTextbox.Text)

===========================================================================
Port Range:
===========================================================================
$($EnumerationPortScanPortRangeFirstTextbox.Text)-$($EnumerationPortScanPortRangeLastTextbox.Text)

===========================================================================
Test With ICMP First:
===========================================================================
$($EnumerationPortScanTestICMPFirstCheckBox.Checked)

===========================================================================
Timeout (ms):
===========================================================================
$($EnumerationPortScanTimeoutTextbox.Text)


"@        

        if ($script:ComputerListPivotExecutionCheckbox.checked -eq $false) {
            $InformationTabControl.SelectedTab = $Section3ResultsTab
            
            # NOTE: Credentials are not necessarily needed to conduct scanning
            if ($script:EnumerationPortScanSpecificComputerNodeCheckbox.checked -eq $true){
                Conduct-PortScan `
                    -ComputerList $ComputerList `
                    -EnumerationPortScanPortQuickPickComboBoxSelectedItem $EnumerationPortScanPortQuickPickComboBox.SelectedItem `
                    -Timeout_ms $EnumerationPortScanTimeoutTextbox.Text `
                    -TestWithICMPFirst $EnumerationPortScanTestICMPFirstCheckBox.Checked `
                    -EndpointList `
                    -SpecificPortsToScan $EnumerationPortScanSpecificPortsTextbox.Text `
                    -FirstPort $EnumerationPortScanPortRangeFirstTextbox.Text `
                    -LastPort $EnumerationPortScanPortRangeLastTextbox.Text
            }
            elseif ($script:EnumerationPortScanSpecificComputerNodeCheckbox.checked -eq $false){
                Conduct-PortScan `
                    -EnumerationPortScanPortQuickPickComboBoxSelectedItem $EnumerationPortScanPortQuickPickComboBox.SelectedItem `
                    -Timeout_ms $EnumerationPortScanTimeoutTextbox.Text `
                    -TestWithICMPFirst $EnumerationPortScanTestICMPFirstCheckBox.Checked `
                    -SpecificIPsToScan $EnumerationPortScanSpecificIPTextbox.Text `
                    -SpecificPortsToScan $EnumerationPortScanSpecificPortsTextbox.Text `
                    -Network $EnumerationPortScanIPRangeNetworkTextbox.Text `
                    -FirstIP $EnumerationPortScanIPRangeFirstTextbox.Text `
                    -LastIP $EnumerationPortScanIPRangeLastTextbox.Text `
                    -FirstPort $EnumerationPortScanPortRangeFirstTextbox.Text `
                    -LastPort $EnumerationPortScanPortRangeLastTextbox.Text
            }
        }
        elseif ($script:ComputerListPivotExecutionCheckbox.checked -eq $true) {
            $InformationTabControl.SelectedTab = $Section3MonitorJobsTab

            if ($script:EnumerationPortScanSpecificComputerNodeCheckbox.checked -eq $true) {
                $InvokeCommandSplat = @{
                    ScriptBlock = {
                        Param($ConductPortScan,$ComputerList,$EnumerationPortScanPortQuickPickComboBoxSelectedItem,$EnumerationPortScanTimeoutTextbox,$EnumerationPortScanTestICMPFirstCheckBox,$EnumerationPortScanSpecificPortsTextbox,$EnumerationPortScanPortRangeFirstTextbox,$EnumerationPortScanPortRangeLastTextbox)
                        . ([ScriptBlock]::Create($ConductPortScan))
                        Conduct-PortScan `
                            -ComputerList $ComputerList `
                            -EnumerationPortScanPortQuickPickComboBoxSelectedItem $EnumerationPortScanPortQuickPickComboBoxSelectedItem `
                            -Timeout_ms $EnumerationPortScanTimeoutTextbox `
                            -TestWithICMPFirst $EnumerationPortScanTestICMPFirstCheckBox `
                            -EndpointList `
                            -SpecificPortsToScan $EnumerationPortScanSpecificPortsTextbox `
                            -FirstPort $EnumerationPortScanPortRangeFirstTextbox `
                            -LastPort $EnumerationPortScanPortRangeLastTextbox
                    }
                    ArgumentList = @($ConductPortScan,$script:ComputerList,$EnumerationPortScanPortQuickPickComboBox.SelectedItem,$EnumerationPortScanTimeoutTextbox.text,$EnumerationPortScanTestICMPFirstCheckBox.checked,$EnumerationPortScanSpecificPortsTextbox.text,$EnumerationPortScanPortRangeFirstTextbox.text,$EnumerationPortScanPortRangeLastTextbox.text)
                    AsJob        = $True
                    JobName      = "PoSh-EasyWin: $($CollectionName) -- $($script:ComputerListPivotExecutionTextBox.text)"
                    ComputerName = $script:ComputerListPivotExecutionTextBox.text
                }
    
                if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                    if (!$script:Credential) { Set-NewCredential }
                    $InvokeCommandSplat += @{Credential = $script:Credential}
                }
                
                Invoke-Command @InvokeCommandSplat | Select-Object PSComputerName, *

                Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:Conduct-PortScan} -ArgumentList @($ConductPortScan,$script:ComputerList,$EnumerationPortScanPortQuickPickComboBox.SelectedItem,$EnumerationPortScanTimeoutTextbox.text,$EnumerationPortScanTestICMPFirstCheckBox.checked,$EnumerationPortScanSpecificPortsTextbox.text,$EnumerationPortScanPortRangeFirstTextbox.text,$EnumerationPortScanPortRangeLastTextbox.text) -InputValues $InputValues -DisableReRun -JobsExportFiles 'true'
            }
            elseif ($script:EnumerationPortScanSpecificComputerNodeCheckbox.checked -eq $false) {

                $InvokeCommandSplat = @{
                    ScriptBlock = {
                        Param($ConductPortScan,$EnumerationPortScanPortQuickPickComboBoxSelectedItem,$EnumerationPortScanTimeoutTextboxText,$EnumerationPortScanTestICMPFirstCheckBoxChecked,$EnumerationPortScanSpecificIPTextboxText,$EnumerationPortScanSpecificPortsTextboxText,$EnumerationPortScanIPRangeNetworkTextboxText,$EnumerationPortScanIPRangeFirstTextboxText,$EnumerationPortScanIPRangeLastTextboxText,$EnumerationPortScanPortRangeFirstTextboxText,$EnumerationPortScanPortRangeLastTextboxText)
                        . ([ScriptBlock]::Create($ConductPortScan))
                        Conduct-PortScan `
                            -EnumerationPortScanPortQuickPickComboBoxSelectedItem $EnumerationPortScanPortQuickPickComboBoxSelectedItem `
                            -Timeout_ms $EnumerationPortScanTimeoutTextboxText `
                            -TestWithICMPFirst $EnumerationPortScanTestICMPFirstCheckBoxChecked `
                            -SpecificIPsToScan $EnumerationPortScanSpecificIPTextboxText `
                            -SpecificPortsToScan $EnumerationPortScanSpecificPortsTextboxText `
                            -Network $EnumerationPortScanIPRangeNetworkTextboxText `
                            -FirstIP $EnumerationPortScanIPRangeFirstTextboxText `
                            -LastIP $EnumerationPortScanIPRangeLastTextboxText `
                            -FirstPort $EnumerationPortScanPortRangeFirstTextboxText `
                            -LastPort $EnumerationPortScanPortRangeLastTextboxText
                    }
                    ArgumentList = @($ConductPortScan,$EnumerationPortScanPortQuickPickComboBox.SelectedItem,$EnumerationPortScanTimeoutTextbox.Text,$EnumerationPortScanTestICMPFirstCheckBox.Checked,$EnumerationPortScanSpecificIPTextbox.Text,$EnumerationPortScanSpecificPortsTextbox.Text,$EnumerationPortScanIPRangeNetworkTextbox.Text,$EnumerationPortScanIPRangeFirstTextbox.Text,$EnumerationPortScanIPRangeLastTextbox.Text,$EnumerationPortScanPortRangeFirstTextbox.Text,$EnumerationPortScanPortRangeLastTextbox.Text)
                    AsJob        = $True
                    JobName      = "PoSh-EasyWin: $($CollectionName) -- $($script:ComputerListPivotExecutionTextBox.text)"
                    ComputerName = $script:ComputerListPivotExecutionTextBox.text
                }
    
                if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                    if (!$script:Credential) { Set-NewCredential }
                    $InvokeCommandSplat += @{Credential = $script:Credential}
                }
                
                Invoke-Command @InvokeCommandSplat | Select-Object PSComputerName, *

                Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:Conduct-PortScan} -ArgumentList @($ConductPortScan,$EnumerationPortScanPortQuickPickComboBox.SelectedItem,$EnumerationPortScanTimeoutTextbox.Text,$EnumerationPortScanTestICMPFirstCheckBox.Checked,$EnumerationPortScanSpecificIPTextbox.Text,$EnumerationPortScanSpecificPortsTextbox.Text,$EnumerationPortScanIPRangeNetworkTextbox.Text,$EnumerationPortScanIPRangeFirstTextbox.Text,$EnumerationPortScanIPRangeLastTextbox.Text,$EnumerationPortScanPortRangeFirstTextbox.Text,$EnumerationPortScanPortRangeLastTextbox.Text) -InputValues $InputValues -DisableReRun -JobsExportFiles 'true'
            }
        }
    }
    else {
        [system.media.systemsounds]::Exclamation.play()
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Port Scan:  Cancelled")
    }

    $script:ComputerTreeView.Nodes.Clear()
    Initialize-TreeViewData -Endpoint
    Normalize-TreeViewData -Endpoint
    Save-TreeViewData -Endpoint

    $ComputerAndAccountTreeViewTabControl.SelectedTab = $ComputerTreeviewTab
    $script:ComputerTreeNodeComboBox.SelectedItem = 'CanonicalName'
    
    Foreach($Computer in $script:ComputerTreeViewData) {
        Add-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category $Computer.OperatingSystem -Entry $Computer.Name -ToolTip $ComputerData.IPv4Address -IPv4Address $Computer.IPv4Address -Metadata $Computer
    }
    Update-TreeViewState -Endpoint
}

####################################################################################################
# WinForms
####################################################################################################

$EnumerationRightPosition     = 3
$EnumerationLabelWidth        = 450
$EnumerationLabelHeight       = 25
$EnumerationGroupGap          = 15

$Section1EnumerationTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = "Enumeration  "
    Left   = $FormScale * $EnumerationRightPosition
    Top    = 0
    Width  = $FormScale * $EnumerationLabelWidth
    Height = $FormScale * $EnumerationLabelHeight
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
    ImageIndex = 3
}
$MainLeftTabControl.Controls.Add($Section1EnumerationTab)

# Enumeration - Domain Generated Input Check
Update-FormProgress "$Dependencies\Code\Execution\Enumeration\InputCheck-EnumerationByDomainImport.ps1"
. "$Dependencies\Code\Execution\Enumeration\InputCheck-EnumerationByDomainImport.ps1"

#============================================================================================================================================================
# Enumeration - Port Scanning
#============================================================================================================================================================
if (!(Test-Path $CustomPortsToScan)) {
    #Don't modify / indent the numbers below... to ensure the file created is formated correctly
    Write-Output "21`r`n22`r`n23`r`n53`r`n80`r`n88`r`n110`r`n123`r`n135`r`n143`r`n161`r`n389`r`n443`r`n445`r`n3389" | Out-File -FilePath $CustomPortsToScan -Force
}

# Using the inputs selected or provided from the GUI, it scans the specified IPs or network range for specified ports
# The intent of this scan is not to be stealth, but rather find hosts; such as those not in active directory
# The results can be added to the computer treenodes
Update-FormProgress "$Dependencies\Code\Execution\Enumeration\Conduct-PortScan.ps1"
. "$Dependencies\Code\Execution\Enumeration\Conduct-PortScan.ps1"


function Check-IfScanExecutionReady {
    Generate-ComputerList
    $IPv4Pattern = "([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){3}"
    $ClassC = "^([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){2}$"
    $PortPattern = "([0-9]{1,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])"
    $InvalidChars = "abcdefghijklmnopqrstuvwxyz~``'`"!@#$%^&*()_+-=[]{}|\/?<>"
    if (
        (
            (
                ($script:EnumerationPortScanSpecificComputerNodeCheckbox.checked) -and 
                ($script:computerList.count -gt 0)
            ) -or 
            (
                ($EnumerationPortScanSpecificIPTextbox.text -match $IPv4Pattern)
            ) -or
            (
                (
                    ($EnumerationPortScanIPRangeNetworkTextbox.text -match $ClassC)
                ) -and
                (
                    ($EnumerationPortScanIPRangeFirstTextbox.text -gt 0 ) -and 
                    ($EnumerationPortScanIPRangeFirstTextbox.text -lt 255) -and 
                    ($EnumerationPortScanIPRangeFirstTextbox.text -le $EnumerationPortScanIPRangeLastTextbox.text)
                ) -and
                (
                    ($EnumerationPortScanIPRangeLastTextbox.text -gt 0 ) -and 
                    ($EnumerationPortScanIPRangeLastTextbox.text -lt 255) -and 
                    ($EnumerationPortScanIPRangeLastTextbox.text -ge $EnumerationPortScanIPRangeFirstTextbox.text)
                )
            )
        ) -and
        (
            (
                ($EnumerationPortScanPortQuickPickComboBox.text -ne 'Quick-Pick Port Selection') -and
                ($EnumerationPortScanPortQuickPickComboBox.selectedItem -ne 'N/A')
            ) -or
            (
                ($EnumerationPortScanSpecificPortsTextbox.text -match $PortPattern)
            ) -or
            (
                (
                    ($EnumerationPortScanPortRangeFirstTextbox.text -ge 0) -and
                    ($EnumerationPortScanPortRangeFirstTextbox.text -le 65535) -and
                    ($EnumerationPortScanPortRangeFirstTextbox.text -le $EnumerationPortScanPortRangeLastTextbox.text)
                ) -and
                (
                    ($EnumerationPortScanPortRangeLastTextbox.text -ge 0) -and
                    ($EnumerationPortScanPortRangeLastTextbox.text -le 65535) -and
                    ($EnumerationPortScanPortRangeLastTextbox.text -ge $EnumerationPortScanPortRangeFirstTextbox.text)
                )
            ) 
        ) -and
        (
            ($EnumerationPortScanTimeoutTextbox.text -gt 0) -and 
            ($EnumerationPortScanTimeoutTextbox.text -match "\d")
        )
    ) {
        $EnumerationPortScanExecutionButton.enabled = $true
        $EnumerationPortScanExecutionButton.BackColor = 'LightGreen'
    }
    else {
        $EnumerationPortScanExecutionButton.enabled = $false
        $EnumerationPortScanExecutionButton.BackColor = 'LightGray'
    }
}


$EnumerationPortScanGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text   = "Create List From TCP Port Scan"
    Left   = 0
    Top    = $FormScale * 7
    Width  = $FormScale * 294
    Height = $FormScale * 350
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
}
           $script:EnumerationPortScanSpecificComputerNodeCheckbox = New-Object System.Windows.Forms.checkbox -Property @{
                Text   = "Scan Checkboxed Endpoints"
                Left   = $FormScale * 3
                Top    = $FormScale * 15
                Width  = $FormScale * 185
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor     = "Black"
                Add_Click = {
                    $ComputerAndAccountTreeViewTabControl.SelectedTab = $ComputerTreeviewTab
                    $script:ComputerTreeNodeComboBox.SelectedItem = 'CanonicalName'
    
                    if ($this.checked){
                        $EnumerationPortScanSpecificIPTextbox.enabled     = $false
                        $EnumerationPortScanIPRangeNetworkTextbox.enabled = $false
                        $EnumerationPortScanIPRangeFirstTextbox.enabled   = $false
                        $EnumerationPortScanIPRangeLastTextbox.enabled    = $false
                        $EnumerationPortScanSpecificIPTextbox.text     = ""
                        $EnumerationPortScanIPRangeNetworkTextbox.text = ""
                        $EnumerationPortScanIPRangeFirstTextbox.text   = ""
                        $EnumerationPortScanIPRangeLastTextbox.text    = ""
                    }
                    else {
                        $EnumerationPortScanSpecificIPTextbox.enabled     = $true
                        $EnumerationPortScanIPRangeNetworkTextbox.enabled = $true
                        $EnumerationPortScanIPRangeFirstTextbox.enabled   = $true
                        $EnumerationPortScanIPRangeLastTextbox.enabled    = $true
                    }
                    Check-IfScanExecutionReady
                }
                Add_MouseEnter = {Check-IfScanExecutionReady}
            }
            $EnumerationPortScanGroupBox.Controls.Add($script:EnumerationPortScanSpecificComputerNodeCheckbox)


            # $script:EnumerationPortScanMonitorJobsCheckbox = New-Object System.Windows.Forms.checkbox -Property @{
            #     Text   = "Monitor as Job"
            #     Left   = $script:EnumerationPortScanSpecificComputerNodeCheckbox.Left + $script:EnumerationPortScanSpecificComputerNodeCheckbox.Width
            #     Top    = $script:EnumerationPortScanSpecificComputerNodeCheckbox.Top
            #     Width  = $FormScale * 100
            #     Height = $FormScale * 22
            #     Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            #     ForeColor     = "Black"
            # }
            # $EnumerationPortScanGroupBox.Controls.Add($script:EnumerationPortScanMonitorJobsCheckbox)

            
            $EnumerationPortScanIPNote1Label = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Enter Comma Separated IPs (ex: 10.0.0.1,10.0.0.2)"
                Left   = $script:EnumerationPortScanSpecificComputerNodeCheckbox.Left
                Top    = $script:EnumerationPortScanSpecificComputerNodeCheckbox.Top + $script:EnumerationPortScanSpecificComputerNodeCheckbox.Height
                Width  = $FormScale * 250
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor  = "Black"
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPNote1Label)


            $EnumerationPortScanSpecificIPTextbox = New-Object System.Windows.Forms.TextBox -Property @{
                Text   = ""
                Left   = $EnumerationPortScanIPNote1Label.Left
                Top    = $EnumerationPortScanIPNote1Label.Top + $EnumerationPortScanIPNote1Label.Height
                Width  = $FormScale * 287
                Height = $FormScale * 22
                MultiLine     = $False
                WordWrap      = $True
                AcceptsTab    = $false
                AcceptsReturn = $false
                Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor     = "Black"
                Add_Click      = {Check-IfScanExecutionReady}
                Add_MouseEnter = {Check-IfScanExecutionReady}
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanSpecificIPTextbox)


            $EnumerationPortScanIPRangeNote1Label = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Network Range:  (ex: [ 192.168.1 ]  [ 1 ]  [ 100 ])"
                Left   = $EnumerationPortScanSpecificIPTextbox.Left
                Top    = $EnumerationPortScanSpecificIPTextbox.Top + $EnumerationPortScanSpecificIPTextbox.Height + ($FormScale + 5)
                Width  = $FormScale * 250
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor  = "Blue"
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPRangeNote1Label)


            $EnumerationPortScanIPRangeNetworkLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Network"
                Left   = $EnumerationPortScanIPRangeNote1Label.left
                Top    = $EnumerationPortScanIPRangeNote1Label.Top + $EnumerationPortScanIPRangeNote1Label.Height
                Width  = $FormScale * 80
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor = "Black"
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPRangeNetworkLabel)


            $EnumerationPortScanIPRangeNetworkTextbox = New-Object System.Windows.Forms.TextBox -Property @{
                Text   = ""
                Left   = $EnumerationPortScanIPRangeNetworkLabel.Left
                Top    = $EnumerationPortScanIPRangeNetworkLabel.Top + $EnumerationPortScanIPRangeNetworkLabel.Height
                Width  = $EnumerationPortScanIPRangeNetworkLabel.Width
                Height = $FormScale * 22
                MultiLine     = $False
                WordWrap      = $True
                AcceptsTab    = $false
                AcceptsReturn = $false
                Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor     = "Black"
                Add_Click      = {Check-IfScanExecutionReady}
                Add_MouseEnter = {Check-IfScanExecutionReady}
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPRangeNetworkTextbox)


            $EnumerationPortScanIPRangeFirstLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "First IP"
                Left   = $EnumerationPortScanIPRangeNetworkTextbox.Left  + $EnumerationPortScanIPRangeNetworkTextbox.Width + $($FormScale * 20)
                Top    = $EnumerationPortScanIPRangeNetworkLabel.Top
                Width  = $EnumerationPortScanIPRangeNetworkLabel.Width
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor = "Black"
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPRangeFirstLabel)


            $EnumerationPortScanIPRangeFirstTextbox = New-Object System.Windows.Forms.TextBox -Property @{
                Text   = ""
                Left   = $EnumerationPortScanIPRangeFirstLabel.Left
                Top    = $EnumerationPortScanIPRangeFirstLabel.Top + $EnumerationPortScanIPRangeFirstLabel.Height
                Width  = $EnumerationPortScanIPRangeFirstLabel.Width
                Height = $FormScale * 22
                MultiLine     = $False
                WordWrap      = $True
                AcceptsTab    = $false
                AcceptsReturn = $false
                Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor     = "Black"
                Add_Click      = {Check-IfScanExecutionReady}
                Add_MouseEnter = {Check-IfScanExecutionReady}
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPRangeFirstTextbox)


            $EnumerationPortScanIPRangeLastLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Last IP"
                Left   = $EnumerationPortScanIPRangeFirstLabel.Left + $EnumerationPortScanIPRangeFirstLabel.Width + $($FormScale * 20)
                Top    = $EnumerationPortScanIPRangeFirstLabel.Top
                Width  = $EnumerationPortScanIPRangeNetworkLabel.Size.Width
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor = "Black"
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPRangeLastLabel)


            $EnumerationPortScanIPRangeLastTextbox = New-Object System.Windows.Forms.TextBox -Property @{
                Text   = ""
                Left   = $EnumerationPortScanIPRangeLastLabel.Left
                Top    = $EnumerationPortScanIPRangeLastLabel.Top + $EnumerationPortScanIPRangeLastLabel.Height
                Width  = $EnumerationPortScanIPRangeLastLabel.Size.Width
                Height = $FormScale * 20
                MultiLine     = $False
                WordWrap      = $True
                AcceptsTab    = $false
                AcceptsReturn = $false
                Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor     = "Black"
                Add_Click      = {Check-IfScanExecutionReady}
                Add_MouseEnter = {Check-IfScanExecutionReady}
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPRangeLastTextbox)


            $EnumerationPortScanPortNote1Label = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Comma Separated Ports:  (ex: 22,80,135,445)"
                Left   = $EnumerationPortScanIPRangeNetworkLabel.Left
                Top    = $EnumerationPortScanIPRangeLastTextbox.Top + $EnumerationPortScanIPRangeLastTextbox.Height + $($FormScale * 5)
                Width  = $FormScale * 290
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor  = "Blue"
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortNote1Label)


            $EnumerationPortScanSpecificPortsTextbox = New-Object System.Windows.Forms.TextBox -Property @{
                Text   = ""
                Left   = $EnumerationPortScanPortNote1Label.Left
                Top    = $EnumerationPortScanPortNote1Label.Top + $EnumerationPortScanPortNote1Label.Height
                Width  = $FormScale * 288
                Height = $FormScale * 22
                MultiLine     = $False
                WordWrap      = $True
                AcceptsTab    = $false
                AcceptsReturn = $false
                Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor     = "Black"
                Add_Click      = {Check-IfScanExecutionReady}
                Add_MouseEnter = {Check-IfScanExecutionReady}
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanSpecificPortsTextbox)


            $EnumerationPortScanPortQuickPickComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
                Text   = "Quick-Pick Port Selection"
                Left   = $EnumerationPortScanSpecificPortsTextbox.Left
                Top    = $EnumerationPortScanSpecificPortsTextbox.Top + $EnumerationPortScanSpecificPortsTextbox.Height + $($FormScale * 10)
                Width  = $FormScale * 183
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor     = "Black"
                Add_Click = $EnumerationPortScanPortQuickPickComboBoxAdd_Click
                Add_MouseEnter = {Check-IfScanExecutionReady}
            }
            $EnumerationPortScanPortQuickPickComboBox.Items.AddRange($EnumerationPortScanPortQuickPickComboBoxItemsAddRange)
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortQuickPickComboBox)


            $EnumerationPortScanPortsSelectionButton = New-Object System.Windows.Forms.Button -Property @{
                Text   = "Select Ports"
                Left   = $EnumerationPortScanPortQuickPickComboBox.Left + $EnumerationPortScanPortQuickPickComboBox.Width + $($FormScale * 4)
                Top    = $EnumerationPortScanPortQuickPickComboBox.Top
                Width  = $FormScale * 100
                Height = $FormScale * 20
                Add_Click = {
                    Import-Csv "$Dependencies\Ports, Protocols, and Services.csv" | Out-GridView -Title 'PoSh-EasyWin: Port Selection' -OutputMode Multiple | Set-Variable -Name PortManualEntrySelectionContents
                    $PortsColumn = $PortManualEntrySelectionContents | Select-Object -ExpandProperty "Port"
                    $PortsToBeScan = ""
                    Foreach ($Port in $PortsColumn) { $PortsToBeScan += "$Port," }
                    $EnumerationPortScanSpecificPortsTextbox.Text += $("," + $PortsToBeScan)
                    $EnumerationPortScanSpecificPortsTextbox.Text = $EnumerationPortScanSpecificPortsTextbox.Text.Trim(",")
                }                
                Add_MouseEnter = {Check-IfScanExecutionReady}
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortsSelectionButton)
            Apply-CommonButtonSettings -Button $EnumerationPortScanPortsSelectionButton


            $EnumerationPortScanPortRangeNetworkLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Port Range"
                Left   = $EnumerationPortScanPortQuickPickComboBox.Left
                Top    = $EnumerationPortScanPortsSelectionButton.Top + $EnumerationPortScanPortsSelectionButton.Height + ($FormScale + 10)
                Width  = $FormScale * 83
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor = "Blue"
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortRangeNetworkLabel)


            $EnumerationPortScanPortRangeFirstLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "First Port"
                Left   = $EnumerationPortScanIPRangeFirstLabel.Left
                Top    = $EnumerationPortScanPortRangeNetworkLabel.Top
                Width  = $EnumerationPortScanIPRangeFirstLabel.Width
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor = "Black"
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortRangeFirstLabel)


            $EnumerationPortScanPortRangeFirstTextbox = New-Object System.Windows.Forms.TextBox -Property @{
                Text   = ""
                Left   = $EnumerationPortScanPortRangeFirstLabel.Left
                Top    = $EnumerationPortScanPortRangeFirstLabel.Top + $EnumerationPortScanPortRangeFirstLabel.Height
                Width  = $EnumerationPortScanPortRangeFirstLabel.Width
                Height = $FormScale * 22
                MultiLine     = $False
                WordWrap      = $True
                AcceptsTab    = $false # Allows you to enter in tabs into the textbox
                AcceptsReturn = $false # Allows you to enter in returnss into the textbox
                Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor     = "Black"
                Add_Click      = {Check-IfScanExecutionReady}
                Add_MouseEnter = {Check-IfScanExecutionReady}
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortRangeFirstTextbox)


            $EnumerationPortScanPortRangeLastLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Last Port"
                Left   = $EnumerationPortScanIPRangeLastLabel.Left
                Top    = $EnumerationPortScanPortRangeFirstLabel.Top
                Width  = $EnumerationPortScanPortRangeFirstTextbox.Width
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor = "Black"
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortRangeLastLabel)


            $EnumerationPortScanPortRangeLastTextbox = New-Object System.Windows.Forms.TextBox -Property @{
                Text   = ""
                Left   = $EnumerationPortScanPortRangeLastLabel.Left
                Top    = $EnumerationPortScanPortRangeLastLabel.Top + $EnumerationPortScanPortRangeLastLabel.Height
                Width  = $EnumerationPortScanPortRangeLastLabel.Width
                Height = $FormScale * 22
                MultiLine     = $False
                WordWrap      = $True
                AcceptsTab    = $false # Allows you to enter in tabs into the textbox
                AcceptsReturn = $false # Allows you to enter in returnss into the textbox
                Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor     = "Black"
                Add_Click      = {Check-IfScanExecutionReady}
                Add_MouseEnter = {Check-IfScanExecutionReady}
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortRangeLastTextbox)


            $EnumerationPortScanTestICMPFirstCheckBox = New-Object System.Windows.Forms.CheckBox -Property @{
                Text   = "Ping First"
                Left   = $EnumerationPortScanPortRangeNetworkLabel.Left
                Top    = $EnumerationPortScanPortRangeLastTextbox.Top + $EnumerationPortScanPortRangeLastTextbox.Height + ($FormScale * 5)
                Width  = $EnumerationPortScanIPRangeNetworkLabel.Size.Width
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor = "Black"
                Checked   = $False
                Add_Click      = {Check-IfScanExecutionReady}
                Add_MouseEnter = {Check-IfScanExecutionReady}
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanTestICMPFirstCheckBox)


            $EnumerationPortScanTimeoutLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Timeout (ms)"
                Left   = $EnumerationPortScanPortRangeFirstLabel.Left
                Top    = $EnumerationPortScanTestICMPFirstCheckBox.Top
                Width  = $EnumerationPortScanIPRangeNetworkTextbox.Width
                Height = $FormScale * 20
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor = "Black"
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanTimeoutLabel)


            $EnumerationPortScanTimeoutTextbox = New-Object System.Windows.Forms.TextBox -Property @{
                Text   = 50
                Left   = $EnumerationPortScanTimeoutLabel.Left
                Top    = $EnumerationPortScanTimeoutLabel.Top + $EnumerationPortScanTimeoutLabel.Height
                Width  = $EnumerationPortScanIPRangeNetworkTextbox.Width
                Height = $FormScale * 22
                MultiLine     = $False
                WordWrap      = $True
                AcceptsTab    = $false
                AcceptsReturn = $false
                Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor     = "Black"
                Add_Click      = {Check-IfScanExecutionReady}
                Add_MouseEnter = {Check-IfScanExecutionReady}
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanTimeoutTextbox)


            $EnumerationPortScanExecutionButton = New-Object System.Windows.Forms.Button -Property @{
                Text   = "Execute Scan"
                Left   = $FormScale * 190
                Top    = $EnumerationPortScanTimeoutTextbox.Top
                Width  = $FormScale * 100
                Height = $FormScale * 22
                Enabled   = $false
                Add_Click = $EnumerationPortScanExecutionButtonAdd_Click
                Add_MouseHover = {
                    Check-IfScanExecutionReady
Show-ToolTip -Title "Execute Scan" -Icon "Info" -Message @"
+  Reference Port Check:
     New-Object System.Net.Sockets.TcpClient("<Hostname/IP>", 139)
"@
                }
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanExecutionButton)
            Apply-CommonButtonSettings -Button $EnumerationPortScanExecutionButton

$Section1EnumerationTab.Controls.Add($EnumerationPortScanGroupBox)


# Using the inputs selected or provided from the GUI, it conducts a basic ping sweep
# The results can be added to the computer treenodes
# Lists all IPs in a subnet
Update-FormProgress "$Dependencies\Code\Main Body\Get-SubnetRange.ps1"
. "$Dependencies\Code\Main Body\Get-SubnetRange.ps1"

Update-FormProgress "$Dependencies\Code\Execution\Enumeration\Conduct-PingSweep.ps1"
. "$Dependencies\Code\Execution\Enumeration\Conduct-PingSweep.ps1"


# Create a group that will contain your radio buttons
$EnumerationPingSweepGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text   = "Create List From Ping Sweep"
    Left   = 0
    Top    = $EnumerationPortScanGroupBox.Top + $EnumerationPortScanGroupBox.Height + $($FormScale * $EnumerationGroupGap)
    Width  = $FormScale * 294
    Height = $FormScale * 70
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
}
            $EnumerationPingSweepNote1Label = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Enter Network/CIDR: (ex: 10.0.0.0/24)"
                Left   = $FormScale * 3
                Top    = $FormScale * 20
                Width  = $FormScale * 180
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor  = "Black"
            }
            $EnumerationPingSweepGroupBox.Controls.Add($EnumerationPingSweepNote1Label)


            $EnumerationPingSweepIPNetworkCIDRTextbox = New-Object System.Windows.Forms.TextBox -Property @{
                Text   = ""
                Left   = $FormScale * 190
                Top    = $EnumerationPingSweepNote1Label.Top
                Width  = $FormScale * 100
                Height = $FormScale * $EnumerationLabelHeight
                MultiLine     = $False
                WordWrap      = $True
                AcceptsTab    = $false
                AcceptsReturn = $false
                Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor     = "Black"
                Add_KeyDown   = { if ($_.KeyCode -eq "Enter") { Conduct-PingSweep } }
            }
            
            $EnumerationPingSweepGroupBox.Controls.Add($EnumerationPingSweepIPNetworkCIDRTextbox)


            $EnumerationPingSweepExecutionButton = New-Object System.Windows.Forms.Button -Property @{
                Text   = "Execute Sweep"
                Left   = $EnumerationPingSweepIPNetworkCIDRTextbox.Left
                Top    = $EnumerationPingSweepIPNetworkCIDRTextbox.Top + $EnumerationPingSweepIPNetworkCIDRTextbox.Height + ($FormScale * 8)
                Width  = $FormScale * 100
                Height = $FormScale * 22
                Add_Click = {
                    if (Verify-Action -Title "Verification: Ping Sweep" -Question "Conduct a Ping Sweep of the following?" -Computer $(
                        $EnumerationPingSweepIPNetworkCIDRTextbox.Text
                    )) {
                        $ResultsListBox.Items.Clear()
                        Conduct-PingSweep
                    }
                    else {
                        [system.media.systemsounds]::Exclamation.play()
                        $StatusListBox.Items.Clear()
                        $StatusListBox.Items.Add("Ping Sweep:  Cancelled")
                    }
                }
            }
            $EnumerationPingSweepGroupBox.Controls.Add($EnumerationPingSweepExecutionButton)
            Apply-CommonButtonSettings -Button $EnumerationPingSweepExecutionButton
$Section1EnumerationTab.Controls.Add($EnumerationPingSweepGroupBox)


$EnumerationResolveDNSNameButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "DNS Resolution"
    Left   = $EnumerationPortScanGroupBox.Left + $EnumerationPortScanGroupBox.Width + ($FormScale + 15)
    Top    = $EnumerationPortScanGroupBox.Top + ($FormScale + 13)
    Width  = $FormScale * 152
    Height = $FormScale * 22
    Add_Click = $EnumerationResolveDNSNameButtonAdd_Click
}
$Section1EnumerationTab.Controls.Add($EnumerationResolveDNSNameButton)
Apply-CommonButtonSettings -Button $EnumerationResolveDNSNameButton


$EnumerationComputerListBox = New-Object System.Windows.Forms.ListBox -Property @{
    Left   = $EnumerationResolveDNSNameButton.Left
    Top    = $EnumerationResolveDNSNameButton.Top + $EnumerationResolveDNSNameButton.Height + ($FormScale + 10)
    Width  = $FormScale * 152
    Height = $EnumerationResolveDNSNameButton.Size.Height + $( $FormScale * 350)
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    SelectionMode = 'MultiExtended'
}
$EnumerationComputerListBox.Items.Add("127.0.0.1")
$Section1EnumerationTab.Controls.Add($EnumerationComputerListBox)


$EnumerationComputerListBoxAddToListButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Add To Computer List"
    Left   = $EnumerationResolveDNSNameButton.Left
    Top    = $EnumerationComputerListBox.Top + $EnumerationComputerListBox.Height + ($FormScale + 5)
    Width  = $EnumerationResolveDNSNameButton.Width
    Height = $FormScale * 22
    Add_Click = $EnumerationComputerListBoxAddToListButtonAdd_Click
}
$Section1EnumerationTab.Controls.Add($EnumerationComputerListBoxAddToListButton)
Apply-CommonButtonSettings -Button $EnumerationComputerListBoxAddToListButton


$EnumerationComputerListBoxSelectAllButton = New-Object System.Windows.Forms.Button -Property @{
    Left   = $EnumerationComputerListBoxAddToListButton.Left
    Top    = $EnumerationComputerListBoxAddToListButton.Top + $EnumerationComputerListBoxAddToListButton.Height + ($FormScale + 10)
    Width  = $EnumerationResolveDNSNameButton.Width
    Height = $FormScale * 22
    Text   = "Select All"
    Add_Click = {
        for($i = 0; $i -lt $EnumerationComputerListBox.Items.Count; $i++) { $EnumerationComputerListBox.SetSelected($i, $true) }
    }
}
$Section1EnumerationTab.Controls.Add($EnumerationComputerListBoxSelectAllButton)
Apply-CommonButtonSettings -Button $EnumerationComputerListBoxSelectAllButton


$EnumerationComputerListBoxClearButton = New-Object System.Windows.Forms.Button -Property @{
    Left   = $EnumerationComputerListBoxSelectAllButton.Left
    Top    = $EnumerationComputerListBoxSelectAllButton.Top + $EnumerationComputerListBoxSelectAllButton.Height + ($FormScale + 10)
    Width  = $EnumerationResolveDNSNameButton.Width
    Height = $FormScale * 22
    Text   = 'Clear List'
    Add_Click = { $EnumerationComputerListBox.Items.Clear() }
}
$Section1EnumerationTab.Controls.Add($EnumerationComputerListBoxClearButton)
Apply-CommonButtonSettings -Button $EnumerationComputerListBoxClearButton



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUVp99F74tn4RNveYR7UQ1rx93
# Y0KgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU8mhsSevhINH7Cabu8UHbZ6LJDt4wDQYJKoZI
# hvcNAQEBBQAEggEAucRN5bfVwB4Fn8QPULFrgx/lAzF/rZMPGTWtd6xIXCOjR/6p
# JjNDbOxJEwBF61h3XroV6IaQ9YV0XKzHDbkw/1fEgQn3me9otl/xH+CN1tLw7l1o
# KZHlqt4WPizAytgjLZEZ8Ke898fDqUDmwbeRd1WYFZFMweZpJ/t8Xx/o8/UH7/T6
# 3xZ4IbbRMBN++csdj91OPKuDRsP+5z1Wk0DzXfjK3h4sESUTQCtnje1pxnFfuyBH
# +TD1tGZxA0SysQZ0Us8nhCgSz41k1MCdo75KFcdvuwQ7W/AbSBBm060ANPM3cZC+
# S4aS0BDSWRj4U3xXguFZUu0Ra5pWn8Avpte0UQ==
# SIG # End signature block
