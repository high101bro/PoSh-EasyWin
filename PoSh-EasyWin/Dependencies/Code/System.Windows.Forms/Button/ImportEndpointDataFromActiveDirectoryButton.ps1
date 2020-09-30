$ImportEndpointDataFromActiveDirectoryButtonAdd_Click = {

function Import-EndpointsFromDomain {
    param(
        $ADComputer
    )
    # Imports data
    foreach ($Computer in $ADComputer) {
        # Checks if data already exists
        if ($script:ComputerTreeViewData.Name -contains $Computer.Name) {
            Message-HostAlreadyExists -Message "Importing Hosts:  Warning" -Computer $Computer.Name -ResultsListBoxMessage
            Add-NodeComputer -RootNode $script:TreeNodeComputerList -Category $Computer.OperatingSystem -Entry $Computer.Name -ToolTip $Computer.IPv4Address
            Update
        }
        else {
            if ($ComputerTreeNodeOSHostnameRadioButton.Checked) {
                if ($Computer.OperatingSystem -eq "") {
                    Add-NodeComputer -RootNode $script:TreeNodeComputerList -Category 'Unknown' -Entry $Computer.Name -ToolTip $Computer.IPv4Address
                }
                else {
                    Add-NodeComputer -RootNode $script:TreeNodeComputerList -Category $Computer.OperatingSystem -Entry $Computer.Name -ToolTip $Computer.IPv4Address
                }
            }
            elseif ($ComputerTreeNodeOUHostnameRadioButton.Checked) {
                $CanonicalName = $($($Computer.CanonicalName) -replace $Computer.Name,"" -replace $Computer.CanonicalName.split('/')[0],"").TrimEnd("/")
                if ($Computer.CanonicalName -eq "") {
                    Add-NodeComputer -RootNode $script:TreeNodeComputerList -Category '/Unknown' -Entry $Computer.Name -ToolTip $Computer.IPv4Address
                }
                else {
                    Add-NodeComputer -RootNode $script:TreeNodeComputerList -Category $CanonicalName -Entry $Computer.Name -ToolTip $Computer.IPv4Address
                }
            }
            $script:ComputerTreeViewData += $Computer
        }
    }
    if ($ComputerTreeNodeOSHostnameRadioButton.Checked) {
        Foreach($Computer in $script:ComputerTreeViewData) {
            Add-NodeComputer -RootNode $script:TreeNodeComputerList -Category $Computer.OperatingSystem -Entry $Computer.Name -ToolTip $Computer.IPv4Address
        }
    }
    elseif ($ComputerTreeNodeOUHostnameRadioButton.Checked) {
        Foreach($Computer in $script:ComputerTreeViewData) {
            Add-NodeComputer -RootNode $script:TreeNodeComputerList -Category $Computer.CanonicalName -Entry $Computer.Name -ToolTip $Computer.IPv4Address
        }
    }
    $script:ComputerTreeView.Nodes.Clear()
    Initialize-ComputerTreeNodes
    Update-TreeNodeComputerState -NoMessage
    Populate-ComputerTreeNodeDefaultData
    Foreach($Computer in $script:ComputerTreeViewData) { Add-NodeComputer -RootNode $script:TreeNodeComputerList -Category $Computer.CanonicalName -Entry $Computer.Name -ToolTip $Computer.IPv4Address }
    $script:ComputerTreeView.ExpandAll()
    Save-HostData
    AutoSave-HostData
}










$ImportFromADFrom = New-Object Windows.Forms.Form -Property @{
    Text          = 'Import Endpoint Data from Active Directory'
    Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
    Width         = $FormScale * 500
    Height        = $FormScale * 410
    StartPosition = "CenterScreen"
    Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Closing = { $This.dispose() }
}










    $ImportFromADWinRMGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
        text      = "Import from Active Directory remotely using WinRM"
        left      = $FormScale * 10
        top       = $FormScale * 10
        Width     = $FormScale * 465
        Height    = $FormScale * 95
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
        ForeColor = "Blue"
    }
        $ImportFromADWinRMNoteLabel = New-Object System.Windows.Forms.Label -Property @{
            Text      = "This method pulls endpoints from within Active Directory from a single server. It uses PowerShell remoting to communitcate with the server to obtain the data, so this method requires that WinRM is enabled and configured properly on the server."
            left      = $FormScale * 5
            top       = $FormScale * 20
            Width     = $FormScale * 445
            Height    = $FormScale * 40
            Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
            ForeColor = "Black"
        }
        $ImportFromADWinRMGroupBox.Controls.Add($ImportFromADWinRMNoteLabel)


        . "$Dependencies\Code\System.Windows.Forms\TextBox\ImportFromADWinRMManuallEntryTextBox.ps1"
        $ImportFromADWinRMManuallEntryTextBox = New-Object System.Windows.Forms.TextBox -Property @{
            Text      = "<Enter a hostname/IP>"
            left      = $FormScale * 5
            top       = $ImportFromADWinRMNoteLabel.top + $ImportFromADWinRMNoteLabel.height + $($FormScale * 5)
            Width     = $FormScale * 185
            Height    = $FormScale * 22
            Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
            ForeColor = "Black"
            Add_MouseEnter = $ImportFromADWinRMManuallEntryTextBoxAdd_MouseEnter
            Add_MouseLeave = $ImportFromADWinRMManuallEntryTextBoxAdd_MouseLeave
            Add_MouseHover = $ImportFromADWinRMManuallEntryTextBoxAdd_MouseHover
        }
        $ImportFromADWinRMGroupBox.Controls.Add($ImportFromADWinRMManuallEntryTextBox)


        $ImportFromADWinRMAutoCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
            Text      = "Single Endpoint Checked"
            left      = $ImportFromADWinRMManuallEntryTextBox.Left + $ImportFromADWinRMManuallEntryTextBox.Width + $($FormScale * 5)
            top       = $ImportFromADWinRMManuallEntryTextBox.Top - + $($FormScale * 3)
            Width     = $FormScale * 155
            Height    = $FormScale * 22
            Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
            ForeColor = "Black"
            Add_Click = {
                if ($ImportFromADWinRMManuallEntryTextBox.Enabled) {
                    $ImportFromADWinRMManuallEntryTextBox.Enabled = $false
                    $ImportFromADWinRMManuallEntryTextBox.Text    = ''
                }
                else {
                    $ImportFromADWinRMManuallEntryTextBox.Enabled = $true
                    $ImportFromADWinRMManuallEntryTextBox.Text    = "<Enter a hostname/IP>"
                }
            }
        }
        $ImportFromADWinRMGroupBox.Controls.Add($ImportFromADWinRMAutoCheckBox)


        $ImportFromADWinRMImportButton = New-Object System.Windows.Forms.Button -Property @{
            Text      = "Import Hosts"
            left      = $ImportFromADWinRMAutoCheckBox.Left + $ImportFromADWinRMAutoCheckBox.Width + $($FormScale * 5)
            top       = $ImportFromADWinRMManuallEntryTextBox.Top
            Width     = $FormScale * 100
            Height    = $FormScale * 20
            Add_Click = {
                Create-ComputerNodeCheckBoxArray
                if ($ImportFromADWinRMManuallEntryTextBox.Text -ne '<Enter a hostname/IP>' -and $ImportFromADWinRMManuallEntryTextBox.Text -ne '' -and $ImportFromADWinRMAutoCheckBox.checked -eq $false ) {
                    if (Verify-Action -Title "Verification: Active Directory Import" -Question "Import Active Directory hosts from the following?" -Computer $ImportFromADWinRMManuallEntryTextBox.text) {
                        $StatusListBox.Items.Clear()
                        $StatusListBox.Items.Add("Importing Hosts From Active Directory")

                        # This brings specific tabs to the forefront/front view
                        $MainBottomTabControl.SelectedTab = $Section3ResultsTab
                        $ImportFromADWinRMManuallEntryTextBoxTarget = $ImportFromADWinRMManuallEntryTextBox.Text
                        if ($ComputerListProvideCredentialsCheckBox.Checked) {
                            if (!$script:Credential) { Create-NewCredentials }
                            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Credentials Used: $($script:Credential.UserName)"
                            $Username = $script:Credential.UserName
                            $Password = '"PASSWORD HIDDEN"'
                            [array]$ImportedActiveDirectoryHosts = Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, OperatingSystem, CanonicalName, IPv4Address, MACAddress } -ComputerName $ImportFromADWinRMManuallEntryTextBoxTarget -Credential $script:Credential
                            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, OperatingSystem, CanonicalName, IPv4Address, MACAddress } -ComputerName $($ImportFromADWinRMManuallEntryTextBox.Text) -Credential [ $UserName | $Password ]"
                        }
                        else {
                            [array]$ImportedActiveDirectoryHosts = Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, OperatingSystem, CanonicalName, IPv4Address, MACAddress } -ComputerName $ImportFromADWinRMManuallEntryTextBoxTarget
                            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message  "Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, OperatingSystem, CanonicalName, IPv4Address, MACAddress } -ComputerName $($ImportFromADWinRMManuallEntryTextBox.Text)"
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
                Update-TreeNodeComputerState -NoMessage

                $ImportFromADFrom.Close()
            }
        }
        $ImportFromADWinRMGroupBox.Controls.Add($ImportFromADWinRMImportButton)
        CommonButtonSettings -Button $ImportFromADWinRMImportButton
    $ImportFromADFrom.Controls.Add($ImportFromADWinRMGroupBox)










    $ImportFromADLocalhostGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
        text      = "Import from Active Directory Locallly ($($env:COMPUTERNAME))"
        left      = $FormScale * 10
        top       = $ImportFromADWinRMGroupBox.Top + $ImportFromADWinRMGroupBox.Height + $($FormScale * 20)
        Width     = $FormScale * 465
        Height    = $FormScale * 90
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
        ForeColor = "Blue"
    }
        $ImportFromADLocalhostNoteLabel = New-Object System.Windows.Forms.Label -Property @{
            Text      = "This method is to be executed on the localhost ($($env:COMPUTERNAME)) if it is a server with Active Directory Domain Services installed. It obtains endpoint information from within Active Directory using the Get-ADComputer cmdlet."
            left      = $FormScale * 5
            top       = $FormScale * 20
            Width     = $FormScale * 445
            Height    = $FormScale * 35
            Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
            ForeColor = "Black"
        }
        $ImportFromADLocalhostGroupBox.Controls.Add($ImportFromADLocalhostNoteLabel)


        $ImportFromADLocalhostModuleCheckLabel = New-Object System.Windows.Forms.Label -Property @{
            Text      = 'Active Directory PowerShell Module Detected Locally:'
            left      = $FormScale * 5
            top       = $ImportFromADLocalhostNoteLabel.top + $ImportFromADLocalhostNoteLabel.height + $($FormScale * 10)
            Width     = $FormScale * 255
            Height    = $FormScale * 22
            Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
            ForeColor = "Black"
        }
        $ImportFromADLocalhostGroupBox.Controls.Add($ImportFromADLocalhostModuleCheckLabel)


        $ImportFromADLocalhostDetectedLabel = New-Object System.Windows.Forms.Label -Property @{
            left      = $ImportFromADLocalhostModuleCheckLabel.Left + $ImportFromADLocalhostModuleCheckLabel.Width
            top       = $ImportFromADLocalhostModuleCheckLabel.Top
            Width     = $FormScale * 90
            Height    = $FormScale * 22
            Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
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
            left      = $ImportFromADLocalhostDetectedLabel.Left + $ImportFromADLocalhostDetectedLabel.Width + $($FormScale * 5)
            top       = $ImportFromADLocalhostDetectedLabel.Top - $($FormScale * 5)
            Width     = $FormScale * 100
            Height    = $FormScale * 20
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
                Update-TreeNodeComputerState -NoMessage

                $ImportFromADFrom.Close()
            }
        }
        $ImportFromADLocalhostGroupBox.Controls.Add($ImportFromADLocalhostImportButton)
        CommonButtonSettings -Button $ImportFromADLocalhostImportButton
    $ImportFromADFrom.Controls.Add($ImportFromADLocalhostGroupBox)










$ImportFromADAutoPullGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    text      = "Import from Domain using Directory Searcher"
    left      = $FormScale * 10
    top       = $ImportFromADLocalhostGroupBox.Top + $ImportFromADLocalhostGroupBox.Height + $($FormScale * 20)
    Width     = $FormScale * 465
    Height    = $FormScale * 125
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
}
    $ImportFromDomainNoteLabel = New-Object System.Windows.Forms.Label -Property @{
        Text      = "If permitted within the domain, this method can be exeucted from any domained host. It uses a Directory Searcher object to search and perform queries against an Active Directory Domain Services hierarchy using Lightweight Directory Access Protocol (LDAP). This will only pull hostnames and none of the metadata such as Operating Systems or Organizational Units. Endpoint nodes imported this way are labeled with an Unknown OS and with the OU being the domain name; these can be later manually moved."
        left      = $FormScale * 5
        top       = $FormScale * 20
        Width     = $FormScale * 445
        Height    = $FormScale * 70
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
        ForeColor = "Black"
    }
    $ImportFromADAutoPullGroupBox.Controls.Add($ImportFromDomainNoteLabel)


    . "$Dependencies\Code\System.Windows.Forms\TextBox\ImportFromADManualEntryTextBox.ps1"
    $ImportFromADManualEntryTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Text      = "<Domain Name>"
        left      = $FormScale * 5
        top       = $ImportFromDomainNoteLabel.top + $ImportFromDomainNoteLabel.height + $($FormScale * 5)
        Width     = $FormScale * 185
        Height    = $FormScale * 22
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
        ForeColor = "Black"
        Add_MouseEnter = $ImportFromADManualEntryTextBoxAdd_MouseEnter
        Add_MouseLeave = $ImportFromADManualEntryTextBoxAdd_MouseLeave
        Add_MouseHover = $ImportFromADManualEntryTextBoxAdd_MouseHover
    }
    $ImportFromADAutoPullGroupBox.Controls.Add($ImportFromADManualEntryTextBox)


    $ImportFromADAutoCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
        Text      = "Auto Pull"
        left      = $ImportFromADManualEntryTextBox.Left + $ImportFromADManualEntryTextBox.Width + $($FormScale * 5)
        top       = $ImportFromADManualEntryTextBox.Top - $($FormScale * 3)
        Width     = $FormScale * 155
        Height    = $FormScale * 22
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
        ForeColor = "Black"
        Add_Click = {
            if ($This.checked) {
                $ImportFromADManualEntryTextBox.text = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().Name
            }
            else {
                $ImportFromADManualEntryTextBox.text = '<Domain Name>'
            }
        }
    }
    $ImportFromADAutoPullGroupBox.Controls.Add($ImportFromADAutoCheckBox)


    $ImportFromADImportButton = New-Object System.Windows.Forms.Button -Property @{
        Text      = "Import Hosts"
        left      = $ImportFromADAutoCheckBox.Left + $ImportFromADAutoCheckBox.Width + $($FormScale * 5)
        top       = $ImportFromADManualEntryTextBox.Top
        Width     = $FormScale * 100
        Height    = $FormScale * 20
        Add_Click = {
            if (($ImportFromADManualEntryTextBox.Text -ne '<Domain Name>') -or $ImportFromADAutoCheckBox.Checked) {
                if (($ImportFromADManualEntryTextBox.Text -ne '') -or ($ImportFromADAutoCheckBox.Checked)) {
                    # Checks if the domain input field is either blank or contains the default info
                    If ($ImportFromADAutoCheckBox.Checked  -eq $true){. Import-HostsFromDomain "Auto"}
                    else {
                        . Import-HostsFromDomain "Manual" "$($ImportFromADManualEntryTextBox.Text)"
                    }

                    $CurrentDomain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().Name
                    #Removed For Testing#$ResultsListBox.Items.Clear()
                    foreach ($Computer in $script:ComputerList) {
                        if ($ComputerTreeNodeOSHostnameRadioButton.Checked) {
                            if ($script:ComputerTreeViewData.Name -contains $computer) {
                                Message-HostAlreadyExists -Message "Add Hostname/IP:  Error" -Computer $Computer -ResultsListBoxMessage
                            }
                            elseif ($ImportFromADAutoCheckBox.Checked) {
                                Add-NodeComputer -RootNode $script:TreeNodeComputerList -Category 'Unknown' -Entry $Computer #-ToolTip $Computer.IPv4Address
                                $ComputerTreeNodeAddHostnameIP = New-Object PSObject -Property @{
                                    Name            = $Computer
                                    OperatingSystem = 'Unknown'
                                    CanonicalName   = "/$CurrentDomain"
                                    IPv4Address     = ''
                                }
                                $script:ComputerTreeViewData += $ComputerTreeNodeAddHostnameIP
                            }
                            else {
                                Add-NodeComputer -RootNode $script:TreeNodeComputerList -Category 'Unknown' -Entry $Computer #-ToolTip $Computer.IPv4Address
                                $ComputerTreeNodeAddHostnameIP = New-Object PSObject -Property @{
                                    Name            = $Computer
                                    OperatingSystem = 'Unknown'
                                    CanonicalName   = "/$($ImportFromADManualEntryTextBox.Text)"
                                    IPv4Address     = ''
                                }
                                $script:ComputerTreeViewData += $ComputerTreeNodeAddHostnameIP
                            }

                            $MainBottomTabControl.SelectedTab = $Section3ResultsTab
                        }
                        elseif ($ComputerTreeNodeOUHostnameRadioButton.Checked) {
                            if ($ImportFromADAutoCheckBox.Checked) {
                                Add-NodeComputer -RootNode $script:TreeNodeComputerList -Category $CurrentDomain -Entry $Computer #-ToolTip $Computer.IPv4Address
                                $ComputerTreeNodeAddHostnameIP = New-Object PSObject -Property @{
                                    Name            = $Computer
                                    OperatingSystem = 'Unknown'
                                    CanonicalName   = "/$CurrentDomain"
                                    IPv4Address     = ''
                                }
                                $script:ComputerTreeViewData += $ComputerTreeNodeAddHostnameIP
                            }
                            else {
                                Add-NodeComputer -RootNode $script:TreeNodeComputerList -Category $($ImportFromADManualEntryTextBox.Text) -Entry $Computer #-ToolTip $Computer.IPv4Address
                                $ComputerTreeNodeAddHostnameIP = New-Object PSObject -Property @{
                                    Name            = $Computer
                                    OperatingSystem = 'Unknown'
                                    CanonicalName   = "/$($ImportFromADManualEntryTextBox.Text)"
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
            Update-TreeNodeComputerState -NoMessage

            $ImportFromADFrom.Close()
        }
    }
    $ImportFromADAutoPullGroupBox.Controls.Add($ImportFromADImportButton)
    CommonButtonSettings -Button $ImportFromADImportButton
    $ImportFromADFrom.Controls.Add($ImportFromADAutoPullGroupBox)

    # Garbage Collection to free up memory
    [System.GC]::Collect()

    $ImportFromADFrom.ShowDialog()
}










$ImportEndpointDataFromActiveDirectoryButtonAdd_MouseHover = {
    Show-ToolTip -Title "Import From Active Directory" -Icon "Info" -Message @"
+  Opens a form that provides you options on how to import endpoint data from Acitve Directory
+  Options include:
     - Import from Domain with Directory Searcher
     - Import from Active Directory remotely using WinRM
     - Import from Active Directory Locally
"@
}




