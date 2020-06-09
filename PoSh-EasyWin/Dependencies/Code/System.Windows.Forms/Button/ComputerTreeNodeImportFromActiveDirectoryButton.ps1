$ComputerTreeNodeImportFromActiveDirectoryButtonAdd_Click = {

    $ImportFromADFrom = New-Object Windows.Forms.Form -Property @{
        Text          = 'Import Endpoint Data using Directory Searcher'
        Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
        Width         = 500
        Height        = 410
        StartPosition = "CenterScreen"
        Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }

    $ImportFromADAutoPullGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
        text      = "Import from Domain using Directory Searcher"
        left      = 10
        top       = 10
        Width     = 465
        Height    = 125
        Font      = New-Object System.Drawing.Font("$Font",12,1,2,1)
        ForeColor = "Blue"
    }
        $ImportFromDomainNoteLabel = New-Object System.Windows.Forms.Label -Property @{
            Text      = "This method can be exeucted from any domained host. It uses a Directory Searcher object to search and perform queries against an Active Directory Domain Services hierarchy using Lightweight Directory Access Protocol (LDAP). This will only pull hostnames and none of the metadata such as Operating Systems or Organizational Units. Endpoint nodes imported this way are labeled with an Unknown OS and with the OU being the domain name; these can be later manually moved."
            left      = 5
            top       = 20
            Width     = 445
            Height    = 70
            Font      = New-Object System.Drawing.Font("$Font",10,0,0,0)
            ForeColor = "Black"
        }
        $ImportFromADAutoPullGroupBox.Controls.Add($ImportFromDomainNoteLabel)  


        . "$Dependencies\Code\System.Windows.Forms\RichTextBox\ImportFromADManualEntryRichTextBox.ps1"
        $ImportFromADManualEntryRichTextBox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Text      = "<Domain Name>"
            left      = 5
            top       = $ImportFromDomainNoteLabel.top + $ImportFromDomainNoteLabel.height + 5
            Width     = 185
            Height    = 22   
            Font      = New-Object System.Drawing.Font("$Font",10,0,0,0)
            ForeColor = "Black"
            Add_MouseEnter = $ImportFromADManualEntryRichTextBoxAdd_MouseEnter
            Add_MouseLeave = $ImportFromADManualEntryRichTextBoxAdd_MouseLeave
            Add_MouseHover = $ImportFromADManualEntryRichTextBoxAdd_MouseHover
        }
        $ImportFromADAutoPullGroupBox.Controls.Add($ImportFromADManualEntryRichTextBox)


        $ImportFromADAutoCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
            Text      = "Auto Pull"
            left      = $ImportFromADManualEntryRichTextBox.Left + $ImportFromADManualEntryRichTextBox.Width + 5
            top       = $ImportFromADManualEntryRichTextBox.Top
            Width     = 155
            Height    = 22    
            Font      = New-Object System.Drawing.Font("$Font",10,0,0,0)
            ForeColor = "Black"
            Add_Click = {
                if ($This.checked) {
                    $ImportFromADManualEntryRichTextBox.text = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().Name
                }
                else {
                    $ImportFromADManualEntryRichTextBox.text = '<Domain Name>'
                }
            }
        }
        $ImportFromADAutoPullGroupBox.Controls.Add($ImportFromADAutoCheckBox)


        $ImportFromADImportButton = New-Object System.Windows.Forms.Button -Property @{
            Text      = "Import Hosts"
            left      = $ImportFromADAutoCheckBox.Left + $ImportFromADAutoCheckBox.Width + 5
            top       = $ImportFromADManualEntryRichTextBox.Top
            Width     = 100
            Height    = 20
            Add_Click = { 
                if (($ImportFromADManualEntryRichTextBox.Text -ne '<Domain Name>') -or $ImportFromADAutoCheckBox.Checked) {
                    if (($ImportFromADManualEntryRichTextBox.Text -ne '') -or ($ImportFromADAutoCheckBox.Checked)) {
                        # Checks if the domain input field is either blank or contains the default info
                        If ($ImportFromADAutoCheckBox.Checked  -eq $true){. Import-HostsFromDomain "Auto"}
                        else {
                            . Import-HostsFromDomain "Manual" "$($ImportFromADManualEntryRichTextBox.Text)"
                        }
            
                        $CurrentDomain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().Name
                        $ResultsListBox.Items.Clear()
                        foreach ($Computer in $ComputerList) {
                            if ($ComputerTreeNodeOSHostnameRadioButton.Checked) {
                                if ($script:ComputerTreeViewData.Name -contains $computer) {
                                    Message-HostAlreadyExists -Message "Add Hostname/IP:  Error" -Computer $Computer -ResultsListBoxMessage
                                }
                                elseif ($ImportFromADAutoCheckBox.Checked) {
                                    Add-ComputerTreeNode -RootNode $script:TreeNodeComputerList -Category 'Unknown' -Entry $Computer #-ToolTip $Computer.IPv4Address
                                    $ComputerTreeNodeAddHostnameIP = New-Object PSObject -Property @{ 
                                        Name            = $Computer
                                        OperatingSystem = 'Unknown'
                                        CanonicalName   = "/$CurrentDomain"
                                        IPv4Address     = ''
                                    }
                                    $script:ComputerTreeViewData += $ComputerTreeNodeAddHostnameIP    
                                }
                                else {
                                    Add-ComputerTreeNode -RootNode $script:TreeNodeComputerList -Category 'Unknown' -Entry $Computer #-ToolTip $Computer.IPv4Address
                                    $ComputerTreeNodeAddHostnameIP = New-Object PSObject -Property @{ 
                                        Name            = $Computer
                                        OperatingSystem = 'Unknown'
                                        CanonicalName   = "/$($ImportFromADManualEntryRichTextBox.Text)"
                                        IPv4Address     = ''
                                    }
                                    $script:ComputerTreeViewData += $ComputerTreeNodeAddHostnameIP    
                                }
                                   
                                $MainBottomTabControl.SelectedTab = $Section3ResultsTab
                            }
                            elseif ($ComputerTreeNodeOUHostnameRadioButton.Checked) {
                                if ($ImportFromADAutoCheckBox.Checked) {
                                    Add-ComputerTreeNode -RootNode $script:TreeNodeComputerList -Category $CurrentDomain -Entry $Computer #-ToolTip $Computer.IPv4Address
                                    $ComputerTreeNodeAddHostnameIP = New-Object PSObject -Property @{ 
                                        Name            = $Computer
                                        OperatingSystem = 'Unknown'
                                        CanonicalName   = "/$CurrentDomain"
                                        IPv4Address     = ''
                                    }
                                    $script:ComputerTreeViewData += $ComputerTreeNodeAddHostnameIP    
                                }
                                else {
                                    Add-ComputerTreeNode -RootNode $script:TreeNodeComputerList -Category $($ImportFromADManualEntryRichTextBox.Text) -Entry $Computer #-ToolTip $Computer.IPv4Address
                                    $ComputerTreeNodeAddHostnameIP = New-Object PSObject -Property @{ 
                                        Name            = $Computer
                                        OperatingSystem = 'Unknown'
                                        CanonicalName   = "/$($ImportFromADManualEntryRichTextBox.Text)"
                                        IPv4Address     = ''
                                    }
                                    $script:ComputerTreeViewData += $ComputerTreeNodeAddHostnameIP    
                                }
                            }
                            $script:ComputerTreeView.ExpandAll()
                            Populate-ComputerTreeNodeDefaultData
                        }
                    }
                }                
                AutoSave-HostData
                Save-HostData
            }
        }
        $ImportFromADAutoPullGroupBox.Controls.Add($ImportFromADImportButton) 
        CommonButtonSettings -Button $ImportFromADImportButton
    $ImportFromADFrom.Controls.Add($ImportFromADAutoPullGroupBox)














function Import-EndpointsFromDomain {
    param(
        $ADComputer
    )
    # Imports data
    foreach ($Computer in $ADComputer) {
        # Checks if data already exists
        if ($script:ComputerTreeViewData.Name -contains $Computer.Name) {
            Message-HostAlreadyExists -Message "Importing Hosts:  Warning" -Computer $Computer.Name -ResultsListBoxMessage
            Add-ComputerTreeNode -RootNode $script:TreeNodeComputerList -Category $Computer.OperatingSystem -Entry $Computer.Name -ToolTip $Computer.IPv4Address 
        }
        else {
            if ($ComputerTreeNodeOSHostnameRadioButton.Checked) {
                if ($Computer.OperatingSystem -eq "") { 
                    Add-ComputerTreeNode -RootNode $script:TreeNodeComputerList -Category 'Unknown' -Entry $Computer.Name -ToolTip $Computer.IPv4Address 
                }
                else { 
                    Add-ComputerTreeNode -RootNode $script:TreeNodeComputerList -Category $Computer.OperatingSystem -Entry $Computer.Name -ToolTip $Computer.IPv4Address 
                }
            }
            elseif ($ComputerTreeNodeOUHostnameRadioButton.Checked) {
                $CanonicalName = $($($Computer.CanonicalName) -replace $Computer.Name,"" -replace $Computer.CanonicalName.split('/')[0],"").TrimEnd("/")
                if ($Computer.CanonicalName -eq "") { 
                    Add-ComputerTreeNode -RootNode $script:TreeNodeComputerList -Category '/Unknown' -Entry $Computer.Name -ToolTip $Computer.IPv4Address 
                }
                else { 
                    Add-ComputerTreeNode -RootNode $script:TreeNodeComputerList -Category $CanonicalName -Entry $Computer.Name -ToolTip $Computer.IPv4Address 
                }
            }
            $script:ComputerTreeViewData += $Computer
        }
    }
    if ($ComputerTreeNodeOSHostnameRadioButton.Checked) {
        Foreach($Computer in $script:ComputerTreeViewData) { Add-ComputerTreeNode -RootNode $script:TreeNodeComputerList -Category $Computer.OperatingSystem -Entry $Computer.Name -ToolTip $Computer.IPv4Address }    
    }
    elseif ($ComputerTreeNodeOUHostnameRadioButton.Checked) {
        Foreach($Computer in $script:ComputerTreeViewData) { Add-ComputerTreeNode -RootNode $script:TreeNodeComputerList -Category $Computer.CanonicalName -Entry $Computer.Name -ToolTip $Computer.IPv4Address }
    }
    $script:ComputerTreeView.Nodes.Clear()
    Initialize-ComputerTreeNodes
    KeepChecked-ComputerTreeNode -NoMessage
    Populate-ComputerTreeNodeDefaultData
    Foreach($Computer in $script:ComputerTreeViewData) { Add-ComputerTreeNode -RootNode $script:TreeNodeComputerList -Category $Computer.CanonicalName -Entry $Computer.Name -ToolTip $Computer.IPv4Address }
    $script:ComputerTreeView.ExpandAll()
    Save-HostData
    AutoSave-HostData
}




















    $ImportFromADWinRMGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
        text      = "Import from Active Directory remotely using WinRM"
        left      = 10
        top       = $ImportFromADAutoPullGroupBox.Top + $ImportFromADAutoPullGroupBox.Height + 20
        Width     = 465
        Height    = 95
        Font      = New-Object System.Drawing.Font("$Font",12,1,2,1)
        ForeColor = "Blue"
    }
        $ImportFromADWinRMNoteLabel = New-Object System.Windows.Forms.Label -Property @{
            Text      = "This method pulls endpoints from within Active Directory from a single server. It uses PowerShell remoting to communitcate with the server to obtain the data, so this method requires that WinRM is enabled and configured properly on the server."
            left      = 5
            top       = 20
            Width     = 445
            Height    = 40
            Font      = New-Object System.Drawing.Font("$Font",10,0,0,0)
            ForeColor = "Black"
        }
        $ImportFromADWinRMGroupBox.Controls.Add($ImportFromADWinRMNoteLabel)  


        . "$Dependencies\Code\System.Windows.Forms\RichTextBox\ImportFromADWinRMManuallEntryRichTextBox.ps1"
        $ImportFromADWinRMManuallEntryRichTextBox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Text      = "<Enter a hostname/IP>"
            left      = 5
            top       = $ImportFromADWinRMNoteLabel.top + $ImportFromADWinRMNoteLabel.height + 5
            Width     = 185
            Height    = 22   
            Font      = New-Object System.Drawing.Font("$Font",10,0,0,0)
            ForeColor = "Black"
            Add_MouseEnter = $ImportFromADWinRMManuallEntryRichTextBoxAdd_MouseEnter
            Add_MouseLeave = $ImportFromADWinRMManuallEntryRichTextBoxAdd_MouseLeave
            Add_MouseHover = $ImportFromADWinRMManuallEntryRichTextBoxAdd_MouseHover
        }
        $ImportFromADWinRMGroupBox.Controls.Add($ImportFromADWinRMManuallEntryRichTextBox)


        $ImportFromADWinRMAutoCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
            Text      = "Single Endpoint Checked"
            left      = $ImportFromADWinRMManuallEntryRichTextBox.Left + $ImportFromADWinRMManuallEntryRichTextBox.Width + 5
            top       = $ImportFromADWinRMManuallEntryRichTextBox.Top
            Width     = 155
            Height    = 22    
            Font      = New-Object System.Drawing.Font("$Font",10,0,0,0)
            ForeColor = "Black"
            Add_Click = {
                if ($ImportFromADWinRMManuallEntryRichTextBox.Enabled) {
                    $ImportFromADWinRMManuallEntryRichTextBox.Enabled = $false
                    $ImportFromADWinRMManuallEntryRichTextBox.Text    = ''
                }
                else {
                    $ImportFromADWinRMManuallEntryRichTextBox.Enabled = $true
                    $ImportFromADWinRMManuallEntryRichTextBox.Text    = "<Enter a hostname/IP>"
                }
            }
        }
        $ImportFromADWinRMGroupBox.Controls.Add($ImportFromADWinRMAutoCheckBox)


        $ImportFromADWinRMImportButton = New-Object System.Windows.Forms.Button -Property @{
            Text      = "Import Hosts"
            left      = $ImportFromADWinRMAutoCheckBox.Left + $ImportFromADWinRMAutoCheckBox.Width + 5
            top       = $ImportFromADWinRMManuallEntryRichTextBox.Top
            Width     = 100
            Height    = 20
            Add_Click = { 
                Create-ComputerNodeCheckBoxArray
                if ($ImportFromADWinRMManuallEntryRichTextBox.Text -ne '<Enter a hostname/IP>' -and $ImportFromADWinRMManuallEntryRichTextBox.Text -ne '' -and $ImportFromADWinRMAutoCheckBox.checked -eq $false ) {
                    if (Verify-Action -Title "Verification: Active Directory Import" -Question "Either manually enter a hostname or select one from the computer treeview.

Import Active Directory hosts from the following?" -Computer $ImportFromADWinRMManuallEntryRichTextBox.text) {
                        $StatusListBox.Items.Clear()
                        $StatusListBox.Items.Add("Importing Hosts From Active Directory")
                            
                        # This brings specific tabs to the forefront/front view
                        $MainBottomTabControl.SelectedTab = $Section3ResultsTab
                        $ImportFromADWinRMManuallEntryRichTextBoxTarget = $ImportFromADWinRMManuallEntryRichTextBox.Text
                        if ($ComputerListProvideCredentialsCheckBox.Checked) {
                            if (!$script:Credential) { Create-NewCredentials }
                            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Credentials Used: $($script:Credential.UserName)"
                            $Username = $script:Credential.UserName
                            $Password = '"PASSWORD HIDDEN"'
                            [array]$ImportedActiveDirectoryHosts = Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, OperatingSystem, CanonicalName, IPv4Address, MACAddress } -ComputerName $ImportFromADWinRMManuallEntryRichTextBoxTarget -Credential $script:Credential
                            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, OperatingSystem, CanonicalName, IPv4Address, MACAddress } -ComputerName $($ImportFromADWinRMManuallEntryRichTextBox.Text) -Credential [ $UserName | $Password ]"
                        }
                        else {
                            [array]$ImportedActiveDirectoryHosts = Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, OperatingSystem, CanonicalName, IPv4Address, MACAddress } -ComputerName $ImportFromADWinRMManuallEntryRichTextBoxTarget
                            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message  "Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, OperatingSystem, CanonicalName, IPv4Address, MACAddress } -ComputerName $($ImportFromADWinRMManuallEntryRichTextBox.Text)"
                        }    
                    }
                    else {
                        [system.media.systemsounds]::Exclamation.play()
                        $StatusListBox.Items.Clear()
                        $StatusListBox.Items.Add("Import from Active Directory:  Cancelled")
                    }
                }

                elseif ($ImportFromADWinRMAutoCheckBox.checked -and $script:ComputerTreeViewSelected.count -eq 1) {
                    Create-ComputerNodeCheckBoxArray
                    if (Verify-Action -Title "Verification: Active Directory Import" -Question "Make sure to select the proper server.`nImport Active Directory hosts from the following?" -Computer $($script:ComputerTreeViewSelected -join ', ')) {
                        $MainBottomTabControl.SelectedTab = $Section3ResultsTab
            
                        $StatusListBox.Items.Clear()
                        $StatusListBox.Items.Add("Importing Hosts From Active Directory")

                        if ($ComputerListProvideCredentialsCheckBox.Checked) {
                            if (!$script:Credential) { Create-NewCredentials }
                            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Credentials Used: $($script:Credential.UserName)"
                            $Username = $script:Credential.UserName
                            $Password = '"PASSWORD HIDDEN"'
            
                            [array]$ImportedActiveDirectoryHosts = Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, OperatingSystem, CanonicalName, IPv4Address, MACAddress } -ComputerName $script:ComputerTreeViewSelected -Credential $script:Credential
                            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, OperatingSystem, CanonicalName, IPv4Address, MACAddress } -ComputerName $script:ComputerTreeViewSelected -Credential [ $UserName | $Password ]"
                        }
                        else {
                            [array]$ImportedActiveDirectoryHosts = Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, OperatingSystem, CanonicalName, IPv4Address, MACAddress } -ComputerName $script:ComputerTreeViewSelected
                            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, OperatingSystem, CanonicalName, IPv4Address, MACAddress } -ComputerName $script:ComputerTreeViewSelected"
                        }
                    }
                    else {
                        [system.media.systemsounds]::Exclamation.play()
                        $StatusListBox.Items.Clear()
                        $StatusListBox.Items.Add("Import from Active Directory:  Cancelled")
                    }
                }
                elseif ($script:ComputerTreeViewSelected.count -lt 1) { ComputerNodeSelectedLessThanOne -Message 'Importing Hosts' }
                elseif ($script:ComputerTreeViewSelected.count -gt 1) { ComputerNodeSelectedMoreThanOne -Message 'Importing Hosts' }
            
                Import-EndpointsFromDomain -ADComputer $ImportedActiveDirectoryHosts
            }
        }
        $ImportFromADWinRMGroupBox.Controls.Add($ImportFromADWinRMImportButton) 
        CommonButtonSettings -Button $ImportFromADWinRMImportButton
    $ImportFromADFrom.Controls.Add($ImportFromADWinRMGroupBox)
























    








    $ImportFromADLocalhostGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
        text      = "Import from Active Directory locallly ($($env:COMPUTERNAME))"
        left      = 10
        top       = $ImportFromADWinRMGroupBox.Top + $ImportFromADWinRMGroupBox.Height + 20
        Width     = 465
        Height    = 90
        Font      = New-Object System.Drawing.Font("$Font",12,1,2,1)
        ForeColor = "Blue"
    }
        $ImportFromADLocalhostNoteLabel = New-Object System.Windows.Forms.Label -Property @{
            Text      = "This method is to be executed on the localhost ($($env:COMPUTERNAME)) if it is a server with Active Directory Domain Services installed. It obtains endpoint information from within Active Directory using the Get-ADComputer cmdlet."
            left      = 5
            top       = 20
            Width     = 445
            Height    = 35
            Font      = New-Object System.Drawing.Font("$Font",10,0,0,0)
            ForeColor = "Black"
        }
        $ImportFromADLocalhostGroupBox.Controls.Add($ImportFromADLocalhostNoteLabel)  


        $ImportFromADLocalhostModuleCheckLabel = New-Object System.Windows.Forms.Label -Property @{
            Text      = 'Active Directory PowerShell Module Detected Locally:'
            left      = 5
            top       = $ImportFromADLocalhostNoteLabel.top + $ImportFromADLocalhostNoteLabel.height + 10
            Width     = 255
            Height    = 22   
            Font      = New-Object System.Drawing.Font("$Font",10,0,0,0)
            ForeColor = "Black"
        }
        $ImportFromADLocalhostGroupBox.Controls.Add($ImportFromADLocalhostModuleCheckLabel)


        $ImportFromADLocalhostDetectedLabel = New-Object System.Windows.Forms.Label -Property @{
            left      = $ImportFromADLocalhostModuleCheckLabel.Left + $ImportFromADLocalhostModuleCheckLabel.Width
            top       = $ImportFromADLocalhostModuleCheckLabel.Top
            Width     = 90
            Height    = 22    
            Font      = New-Object System.Drawing.Font("$Font",10,0,0,0)
        }
        $ImportFromADLocalhostGroupBox.Controls.Add($ImportFromADLocalhostDetectedLabel)
        $ADModuleCheck = Get-Module -ListAvailable -Name ActiveDirectory
        if ($ADModuleCheck) {
            $ImportFromADLocalhostDetectedLabel.text      = "Available"
            $ImportFromADLocalhostDetectedLabel.ForeColor = 'Green'
        }
        else {
            $ImportFromADLocalhostDetectedLabel.text      = "NOT Available"
            $ImportFromADLocalhostDetectedLabel.ForeColor = 'Red'
        }


        $ImportFromADLocalhostImportButton = New-Object System.Windows.Forms.Button -Property @{
            Text      = "Import Hosts"
            left      = $ImportFromADLocalhostDetectedLabel.Left + $ImportFromADLocalhostDetectedLabel.Width + 5
            top       = $ImportFromADLocalhostDetectedLabel.Top - 5
            Width     = 100
            Height    = 20
            Add_Click = { 
                if ($ComputerListProvideCredentialsCheckBox.Checked) {
                    if (!$script:Credential) { Create-NewCredentials }
                    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Credentials Used: $($script:Credential.UserName)"
                    $Username = $script:Credential.UserName
                    $Password = '"PASSWORD HIDDEN"'
                    [array]$ImportedActiveDirectoryHosts = Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, OperatingSystem, CanonicalName, IPv4Address, MACAddress } -Credential $script:Credential
                    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, OperatingSystem, CanonicalName, IPv4Address, MACAddress } -Credential [ $UserName | $Password ]"
                }
                else {
                    [array]$ImportedActiveDirectoryHosts = Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, OperatingSystem, CanonicalName, IPv4Address, MACAddress }
                    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message  "Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, OperatingSystem, CanonicalName, IPv4Address, MACAddress }"
                }                
                Import-EndpointsFromDomain -ADComputer $ImportedActiveDirectoryHosts
            }
        }
        $ImportFromADLocalhostGroupBox.Controls.Add($ImportFromADLocalhostImportButton) 
        CommonButtonSettings -Button $ImportFromADLocalhostImportButton
    $ImportFromADFrom.Controls.Add($ImportFromADLocalhostGroupBox)

    $ImportFromADFrom.ShowDialog()
}

    


$ComputerTreeNodeImportFromActiveDirectoryButtonAdd_MouseHover = {
    Show-ToolTip -Title "Import From Active Directory" -Icon "Info" -Message @"
+  Opens a form that provides you options on how to import endpoint data from Acitve Directory
+  Options include:
     - Import from Domain with Directory Searcher
     - Import from Active Directory remotely using WinRM
     - Import from Active Directory Locally
"@
}
    

