Function Import-DataFromActiveDirectory {
    param(
        [switch]$Endpoint,
        [switch]$Accounts
    )

    if ($Endpoint){
        $ComputerAndAccountTreeViewTabControl.SelectedTab = $ComputerTreeviewTab

        function Import-EndpointsFromDomain {
            param(
                $ADComputer
            )
            # Imports data
            foreach ($Computer in $ADComputer) {
                # Checks if data already exists
                if ($script:ComputerTreeViewData.Name -contains $Computer.Name) {
                    Message-NodeAlreadyExists -Endpoint -Message "Importing Hosts:  Warning" -Computer $Computer.Name -ResultsListBoxMessage
                    AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category $Computer.OperatingSystem -Entry $Computer.Name -ToolTip $ComputerData.IPv4Address -IPv4Address $Computer.IPv4Address
                }
                else {
                    $ComputerAndAccountTreeViewTabControl.SelectedTab = $ComputerTreeviewTab
                    $script:ComputerTreeNodeComboBox.SelectedItem = 'CanonicalName'
        
                    $CanonicalName = $($($Computer.CanonicalName) -replace $Computer.Name,"" -replace $Computer.CanonicalName.split('/')[0],"").TrimEnd("/")
                    if ($Computer.CanonicalName -eq "") {
                        AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category '/Unknown' -Entry $Computer.Name -ToolTip $ComputerData.IPv4Address -IPv4Address $Computer.IPv4Address
                    }
                    else {
                        AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category $CanonicalName -Entry $Computer.Name -ToolTip $ComputerData.IPv4Address -IPv4Address $Computer.IPv4Address
                    }
                    $script:ComputerTreeViewData += $Computer
                }
            }
        
            $ComputerAndAccountTreeViewTabControl.SelectedTab = $ComputerTreeviewTab
            $script:ComputerTreeNodeComboBox.SelectedItem = 'CanonicalName'
        
            Foreach($Computer in $script:ComputerTreeViewData) {
                AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category $Computer.CanonicalName -Entry $Computer.Name -ToolTip $ComputerData.IPv4Address -IPv4Address $Computer.IPv4Address
            }
        
            #Updates TreeView
            $script:ComputerTreeView.Nodes.Clear()
            Initialize-TreeViewData -Endpoint
            Normalize-TreeViewData -Endpoint
            Foreach($Computer in $script:ComputerTreeViewData) { AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category $Computer.CanonicalName -Entry $Computer.Name -ToolTip $ComputerData.IPv4Address -IPv4Address $Computer.IPv4Address }
            $script:ComputerTreeView.ExpandAll()
            UpdateState-TreeViewData -Endpoint
            Save-TreeViewData -Endpoint
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
                    Add_KeyDown    = { if ($_.KeyCode -eq "Enter") { $ImportFromADWinRMManuallEntryTextBoxAdd_MouseEnter }}
                    Add_MouseEnter = $ImportFromADWinRMManuallEntryTextBoxAdd_MouseEnter
                    Add_MouseLeave = $ImportFromADWinRMManuallEntryTextBoxAdd_MouseLeave
                    Add_MouseHover = $ImportFromADWinRMManuallEntryTextBoxAdd_MouseHover
                }
                $ImportFromADWinRMGroupBox.Controls.Add($ImportFromADWinRMManuallEntryTextBox)
                if (Get-Content $script:ActiveDirectoryEndpoint) { $ImportFromADWinRMManuallEntryTextBox.Text = Get-Content $script:ActiveDirectoryEndpoint }
        
        
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
                        $ImportFromADWinRMManuallEntryTextBox.Text | Out-File $script:ActiveDirectoryEndpoint -Force
        
                        Create-TreeViewCheckBoxArray -Endpoint
                        if ($ImportFromADWinRMManuallEntryTextBox.Text -ne '<Enter a hostname/IP>' -and $ImportFromADWinRMManuallEntryTextBox.Text -ne '' -and $ImportFromADWinRMAutoCheckBox.checked -eq $false ) {
                            if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                                $CredentialsUsed = $script:Credential.UserName
                            }
                            else {
                                $CredentialsUsed =  $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)
                            }
                            
                            if (Verify-Action -Title "Verification: Active Directory Import" -Question "Credentials Used:`n$($CredentialsUsed)`n`nImport Active Directory hosts from the following?" -Computer $ImportFromADWinRMManuallEntryTextBox.text) {
                                $StatusListBox.Items.Clear()
                                $StatusListBox.Items.Add("Importing Hosts From Active Directory")
        
                                # This brings specific tabs to the forefront/front view
                                $InformationTabControl.SelectedTab = $Section3ResultsTab
                                $ImportFromADWinRMManuallEntryTextBoxTarget = $ImportFromADWinRMManuallEntryTextBox.Text
                                if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                                    if (!$script:Credential) { Create-NewCredentials }
                                    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Credentials Used: $($script:Credential.UserName)"
                                    $Username = $script:Credential.UserName
                                    $Password = '"PASSWORD HIDDEN"'
                                    [array]$ImportedActiveDirectoryHosts = Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, CanonicalName, OperatingSystem, OperatingSystemHotfix, OperatingSystemServicePack, Enabled, LockedOut, LogonCount, Created, Modified, LastLogonDate, IPv4Address, MACAddress, MemberOf, isCriticalSystemObject, HomedirRequired, Location, ProtectedFromAccidentalDeletion, TrustedForDelegation, SID } -ComputerName $ImportFromADWinRMManuallEntryTextBoxTarget -Credential $script:Credential
                                    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, CanonicalName, OperatingSystem, OperatingSystemHotfix, OperatingSystemServicePack, Enabled, LockedOut, LogonCount, Created, Modified, LastLogonDate, IPv4Address, MACAddress, MemberOf, isCriticalSystemObject, HomedirRequired, Location, ProtectedFromAccidentalDeletion, TrustedForDelegation, SID } -ComputerName $($ImportFromADWinRMManuallEntryTextBox.Text) -Credential [ $UserName | $Password ]"
                                }
                                else {
                                    [array]$ImportedActiveDirectoryHosts = Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, CanonicalName, OperatingSystem, OperatingSystemHotfix, OperatingSystemServicePack, Enabled, LockedOut, LogonCount, Created, Modified, LastLogonDate, IPv4Address, MACAddress, MemberOf, isCriticalSystemObject, HomedirRequired, Location, ProtectedFromAccidentalDeletion, TrustedForDelegation, SID } -ComputerName $ImportFromADWinRMManuallEntryTextBoxTarget
                                    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message  "Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, CanonicalName, OperatingSystem, OperatingSystemHotfix, OperatingSystemServicePack, Enabled, LockedOut, LogonCount, Created, Modified, LastLogonDate, IPv4Address, MACAddress, MemberOf, isCriticalSystemObject, HomedirRequired, Location, ProtectedFromAccidentalDeletion, TrustedForDelegation, SID } -ComputerName $($ImportFromADWinRMManuallEntryTextBox.Text)"
                                }
                            }
                            else {
                                [system.media.systemsounds]::Exclamation.play()
                                $StatusListBox.Items.Clear()
                                $StatusListBox.Items.Add("Import from Active Directory:  Cancelled")
                            }
                        }
        
                        elseif ($ImportFromADWinRMAutoCheckBox.checked -and $script:ComputerTreeViewSelected.count -eq 1) {
                            Create-TreeViewCheckBoxArray -Endpoint
                            if (Verify-Action -Title "Verification: Active Directory Import" -Question "Make sure to select the proper server.`nImport Active Directory hosts from the following?" -Computer $($script:ComputerTreeViewSelected -join ', ')) {
                                $InformationTabControl.SelectedTab = $Section3ResultsTab
        
                                $StatusListBox.Items.Clear()
                                $StatusListBox.Items.Add("Importing Hosts From Active Directory")
        
                                if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                                    if (!$script:Credential) { Create-NewCredentials }
                                    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Credentials Used: $($script:Credential.UserName)"
                                    $Username = $script:Credential.UserName
                                    $Password = '"PASSWORD HIDDEN"'
        
                                    [array]$ImportedActiveDirectoryHosts = Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, CanonicalName, OperatingSystem, OperatingSystemHotfix, OperatingSystemServicePack, Enabled, LockedOut, LogonCount, Created, Modified, LastLogonDate, IPv4Address, MACAddress, MemberOf, isCriticalSystemObject, HomedirRequired, Location, ProtectedFromAccidentalDeletion, TrustedForDelegation, SID } -ComputerName $script:ComputerTreeViewSelected -Credential $script:Credential
                                    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, CanonicalName, OperatingSystem, OperatingSystemHotfix, OperatingSystemServicePack, Enabled, LockedOut, LogonCount, Created, Modified, LastLogonDate, IPv4Address, MACAddress, MemberOf, isCriticalSystemObject, HomedirRequired, Location, ProtectedFromAccidentalDeletion, TrustedForDelegation, SID } -ComputerName $script:ComputerTreeViewSelected -Credential [ $UserName | $Password ]"
                                }
                                else {
                                    [array]$ImportedActiveDirectoryHosts = Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, CanonicalName, OperatingSystem, OperatingSystemHotfix, OperatingSystemServicePack, Enabled, LockedOut, LogonCount, Created, Modified, LastLogonDate, IPv4Address, MACAddress, MemberOf, isCriticalSystemObject, HomedirRequired, Location, ProtectedFromAccidentalDeletion, TrustedForDelegation, SID } -ComputerName $script:ComputerTreeViewSelected
                                    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, CanonicalName, OperatingSystem, OperatingSystemHotfix, OperatingSystemServicePack, Enabled, LockedOut, LogonCount, Created, Modified, LastLogonDate, IPv4Address, MACAddress, MemberOf, isCriticalSystemObject, HomedirRequired, Location, ProtectedFromAccidentalDeletion, TrustedForDelegation, SID } -ComputerName $script:ComputerTreeViewSelected"
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
                        if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                            if (!$script:Credential) { Create-NewCredentials }
                            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Credentials Used: $($script:Credential.UserName)"
                            $Username = $script:Credential.UserName
                            $Password = '"PASSWORD HIDDEN"'
                            [array]$ImportedActiveDirectoryHosts = Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, CanonicalName, OperatingSystem, OperatingSystemHotfix, OperatingSystemServicePack, Enabled, LockedOut, LogonCount, Created, Modified, LastLogonDate, IPv4Address, MACAddress, MemberOf, isCriticalSystemObject, HomedirRequired, Location, ProtectedFromAccidentalDeletion, TrustedForDelegation, SID } -Credential $script:Credential
                            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, CanonicalName, OperatingSystem, OperatingSystemHotfix, OperatingSystemServicePack, Enabled, LockedOut, LogonCount, Created, Modified, LastLogonDate, IPv4Address, MACAddress, MemberOf, isCriticalSystemObject, HomedirRequired, Location, ProtectedFromAccidentalDeletion, TrustedForDelegation, SID } -Credential [ $UserName | $Password ]"
                        }
                        else {
                            [array]$ImportedActiveDirectoryHosts = Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, CanonicalName, OperatingSystem, OperatingSystemHotfix, OperatingSystemServicePack, Enabled, LockedOut, LogonCount, Created, Modified, LastLogonDate, IPv4Address, MACAddress, MemberOf, isCriticalSystemObject, HomedirRequired, Location, ProtectedFromAccidentalDeletion, TrustedForDelegation, SID }
                            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message  "Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, CanonicalName, OperatingSystem, OperatingSystemHotfix, OperatingSystemServicePack, Enabled, LockedOut, LogonCount, Created, Modified, LastLogonDate, IPv4Address, MACAddress, MemberOf, isCriticalSystemObject, HomedirRequired, Location, ProtectedFromAccidentalDeletion, TrustedForDelegation, SID }"
                        }
                        Import-EndpointsFromDomain -ADComputer $ImportedActiveDirectoryHosts
                        UpdateState-TreeViewData -Endpoint
        
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
                            #Removed For Testing#
                            $ResultsListBox.Items.Clear()
                            foreach ($Computer in $script:ComputerList) {
                                if ($ImportFromADAutoCheckBox.Checked) {
                                    AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category $CurrentDomain -Entry $Computer -ToolTip $Computer.IPv4Address -IPv4Address $Computer.IPv4Address
                                    $ComputerTreeNodeAddHostnameIP = New-Object PSObject -Property @{
                                        Name            = $Computer
                                        OperatingSystem = 'Unknown'
                                        CanonicalName   = "/$CurrentDomain"
                                        IPv4Address     = ''
                                    }
                                    $script:ComputerTreeViewData += $ComputerTreeNodeAddHostnameIP
                                }
                                else {
                                    AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category $($ImportFromADManualEntryTextBox.Text) -Entry $Computer -ToolTip $Computer.IPv4Address -IPv4Address $Computer.IPv4Address
                                    $ComputerTreeNodeAddHostnameIP = New-Object PSObject -Property @{
                                        Name            = $Computer
                                        OperatingSystem = 'Unknown'
                                        CanonicalName   = "/$($ImportFromADManualEntryTextBox.Text)"
                                        IPv4Address     = ''
                                    }
                                    $script:ComputerTreeViewData += $ComputerTreeNodeAddHostnameIP
                                }
                                $script:ComputerTreeView.ExpandAll()
                                Normalize-TreeViewData -Endpoint
                            }
                        }
                    }
                    Save-TreeViewData -Endpoint
                    UpdateState-TreeViewData -Endpoint
        
                    $ImportFromADFrom.Close()
                }
            }
            $ImportFromADAutoPullGroupBox.Controls.Add($ImportFromADImportButton)
            CommonButtonSettings -Button $ImportFromADImportButton
            $ImportFromADFrom.Controls.Add($ImportFromADAutoPullGroupBox)
        
            [System.GC]::Collect()
        
            $ImportFromADFrom.ShowDialog()        
    }
    if ($Accounts){
        $ComputerAndAccountTreeViewTabControl.SelectedTab = $AccountsTreeviewTab

        $ImportFromADFrom = New-Object Windows.Forms.Form -Property @{
            Text          = 'Import account information from Active Directory'
            Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
            Width         = $FormScale * 500
            Height        = $FormScale * 265
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
                    Text      = "This method pulls account information from within Active Directory from a single server. It uses PowerShell remoting to communitcate with the server to obtain the data, so this method requires that WinRM is enabled and configured properly on the server."
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
                    Add_KeyDown    = { if ($_.KeyCode -eq "Enter") { & $ImportFromADWinRMManuallEntryTextBoxAdd_MouseEnter }}
                    Add_MouseEnter = $ImportFromADWinRMManuallEntryTextBoxAdd_MouseEnter
                    Add_MouseLeave = $ImportFromADWinRMManuallEntryTextBoxAdd_MouseLeave
                    Add_MouseHover = $ImportFromADWinRMManuallEntryTextBoxAdd_MouseHover
                }
                $ImportFromADWinRMGroupBox.Controls.Add($ImportFromADWinRMManuallEntryTextBox)
                if (Get-Content $script:ActiveDirectoryEndpoint) { $ImportFromADWinRMManuallEntryTextBox.Text = Get-Content $script:ActiveDirectoryEndpoint }
        
        
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
                    Text      = "Import Accounts"
                    left      = $ImportFromADWinRMAutoCheckBox.Left + $ImportFromADWinRMAutoCheckBox.Width + $($FormScale * 5)
                    top       = $ImportFromADWinRMManuallEntryTextBox.Top
                    Width     = $FormScale * 100
                    Height    = $FormScale * 20
                    Add_Click = {
                        $ImportFromADWinRMManuallEntryTextBox.Text | Out-File $script:ActiveDirectoryEndpoint -Force
        
                        Create-TreeViewCheckBoxArray -Accounts
                        if ($ImportFromADWinRMManuallEntryTextBox.Text -ne '<Enter a hostname/IP>' -and $ImportFromADWinRMManuallEntryTextBox.Text -ne '' -and $ImportFromADWinRMAutoCheckBox.checked -eq $false ) {
                            if (Verify-Action -Title "Verification: Active Directory Import" -Question "Credentials Used:`n$($script:Credential.UserName)`n`nImport Active Directory account information from the following?" -Computer $ImportFromADWinRMManuallEntryTextBox.text) {
                                $StatusListBox.Items.Clear()
                                $StatusListBox.Items.Add("Importing Hosts From Active Directory")
        
                                # This brings specific tabs to the forefront/front view
                                $InformationTabControl.SelectedTab = $Section3ResultsTab
                                $ImportFromADWinRMManuallEntryTextBoxTarget = $ImportFromADWinRMManuallEntryTextBox.Text
                                if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                                    if (!$script:Credential) { Create-NewCredentials }
                                    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Credentials Used: $($script:Credential.UserName)"
                                    $Username = $script:Credential.UserName
                                    $Password = '"PASSWORD HIDDEN"'
                                    $script:AccountsTreeViewData = Invoke-Command -ScriptBlock {
                                        Get-ADUser -Filter * -Properties * `
                                        | Select-Object Name, SID, Enabled, LockedOut, Created, Modified, LastLogonDate, LastBadPasswordAttempt, BadLogonCount, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CanonicalName, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive
                                    } -ComputerName $ImportFromADWinRMManuallEntryTextBoxTarget -Credential $script:Credential
                                    $script:AccountsTreeViewData | Export-Csv $script:AccountsTreeNodeFileSave -NoTypeInformation
                                    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { Get-ADUser -Filter * -Properties * | Select-Object Name, SID, Enabled, LockedOut, Created, Modified, LastLogonDate, LastBadPasswordAttempt, BadLogonCount, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CanonicalName, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive } -ComputerName $($ImportFromADWinRMManuallEntryTextBox.Text) -Credential [ $UserName | $Password ]"
                                }
                                else {
                                    $script:AccountsTreeViewData = Invoke-Command -ScriptBlock {
                                        Get-ADUser -Filter * -Properties * `
                                        | Select-Object Name, SID, Enabled, LockedOut, Created, Modified, LastLogonDate, LastBadPasswordAttempt, BadLogonCount, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CanonicalName, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive
                                    } -ComputerName $ImportFromADWinRMManuallEntryTextBoxTarget
                                    $script:AccountsTreeViewData | Export-Csv $script:AccountsTreeNodeFileSave -NoTypeInformation
                                    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message  "Invoke-Command -ScriptBlock { Get-ADUser -Filter * -Properties * | Select-Object Name, SID, Enabled, LockedOut, Created, Modified, LastLogonDate, LastBadPasswordAttempt, BadLogonCount, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CanonicalName, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive } -ComputerName $($ImportFromADWinRMManuallEntryTextBox.Text)"
                                }
                                #Initialize-TreeViewData -Accounts
                                Normalize-TreeViewData -Accounts
                                Save-TreeViewData -Accounts
        
                                Foreach($Account in $script:AccountsTreeViewData) {
                                    AddTreeNodeTo-TreeViewData -Accounts -RootNode $script:TreeNodeAccountsList -Category $Account.Enabled -Entry $Account.Name -ToolTip $Account.SID -Metadata $Account 
                                }
                                
                                UpdateState-TreeViewData -Accounts
                            }
                            else {
                                [system.media.systemsounds]::Exclamation.play()
                                $StatusListBox.Items.Clear()
                                $StatusListBox.Items.Add("Import from Active Directory:  Cancelled")
                            }
                        }
                        elseif ($ImportFromADWinRMAutoCheckBox.checked -and $script:ComputerTreeViewSelected.count -eq 1) {
                            Create-TreeViewCheckBoxArray -Accounts
                            if (Verify-Action -Title "Verification: Active Directory Import" -Question "Make sure to select the proper server.`nImport Active Directory hosts from the following?" -Computer $($script:ComputerTreeViewSelected -join ', ')) {
                                $InformationTabControl.SelectedTab = $Section3ResultsTab
        
                                $StatusListBox.Items.Clear()
                                $StatusListBox.Items.Add("Importing Hosts From Active Directory")
        
                                if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                                    if (!$script:Credential) { Create-NewCredentials }
                                    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Credentials Used: $($script:Credential.UserName)"
                                    $Username = $script:Credential.UserName
                                    $Password = '"PASSWORD HIDDEN"'
        
                                    $script:AccountsTreeViewData = Invoke-Command -ScriptBlock {
                                        Get-ADUser -Filter * -Properties * `
                                        | Select-Object Name, SID, Enabled, LockedOut, Created, Modified, LastLogonDate, LastBadPasswordAttempt, BadLogonCount, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CanonicalName, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive
                                    } -ComputerName $script:ComputerTreeViewSelected -Credential $script:Credential
                                    $script:AccountsTreeViewData | Export-Csv $script:AccountsTreeNodeFileSave -NoTypeInformation
        
                                    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { Get-ADUser -Filter * -Properties * | Select-Object Name, SID, Enabled, LockedOut, Created, Modified, LastLogonDate, LastBadPasswordAttempt, BadLogonCount, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CanonicalName, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive } -ComputerName $script:ComputerTreeViewSelected -Credential [ $UserName | $Password ]"
                                }
                                else {
                                    $script:AccountsTreeViewData = Invoke-Command -ScriptBlock {
                                        Get-ADUser -Filter * -Properties * `
                                        | Select-Object Name, SID, Enabled, LockedOut, Created, Modified, LastLogonDate, LastBadPasswordAttempt, BadLogonCount, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CanonicalName, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive
                                    } -ComputerName $script:ComputerTreeViewSelected
                                    $script:AccountsTreeViewData | Export-Csv $script:AccountsTreeNodeFileSave -NoTypeInformation
                                    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { Get-ADUser -Filter * -Properties * | Select-Object Name, SID, Enabled, LockedOut, Created, Modified, LastLogonDate, LastBadPasswordAttempt, BadLogonCount, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CanonicalName, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive } -ComputerName $script:ComputerTreeViewSelected"
                                }
                                #Initialize-TreeViewData -Accounts
                                Normalize-TreeViewData -Accounts
                                Save-TreeViewData -Accounts
        
                                Foreach($Account in $script:AccountsTreeViewData) {
                                    AddTreeNodeTo-TreeViewData -Accounts -RootNode $script:TreeNodeAccountsList -Category $Account.Enabled -Entry $Account.Name -ToolTip $Account.SID -Metadata $Account 
                                }
                                
                                UpdateState-TreeViewData -Accounts
                            }
                            else {
                                [system.media.systemsounds]::Exclamation.play()
                                $StatusListBox.Items.Clear()
                                $StatusListBox.Items.Add("Import from Active Directory:  Cancelled")
                            }
                        }
                        elseif ($script:ComputerTreeViewSelected.count -lt 1) { ComputerNodeSelectedLessThanOne -Message 'Importing Accounts' }
                        elseif ($script:ComputerTreeViewSelected.count -gt 1) { ComputerNodeSelectedMoreThanOne -Message 'Importing Accounts' }
        
                        Save-TreeViewData -Accounts
                        
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
                    Text      = "This method is to be executed on the localhost ($($env:COMPUTERNAME)) if it is a server with Active Directory Domain Services installed. It obtains account information from within Active Directory using the Get-ADUser cmdlet."
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
                    Text      = "Import Accounts"
                    left      = $ImportFromADLocalhostDetectedLabel.Left + $ImportFromADLocalhostDetectedLabel.Width + $($FormScale * 5)
                    top       = $ImportFromADLocalhostDetectedLabel.Top - $($FormScale * 5)
                    Width     = $FormScale * 100
                    Height    = $FormScale * 20
                    Add_Click = {
                        if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                            if (!$script:Credential) { Create-NewCredentials }
                            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Credentials Used: $($script:Credential.UserName)"
                            $Username = $script:Credential.UserName
                            $Password = '"PASSWORD HIDDEN"'
                            Invoke-Command -ScriptBlock {
                                Get-ADUser -Filter * -Properties * `
                                | Select-Object Name, SID, Enabled, LockedOut, Created, Modified, LastLogonDate, LastBadPasswordAttempt, BadLogonCount, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CanonicalName, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive
                            } -Credential $script:Credential `
                            | Export-Csv $script:AccountsTreeNodeFileSave -NoTypeInformation
                            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { Get-ADUser -Filter * -Properties * | Select-Object Name, SID, Enabled, LockedOut, Created, Modified, LastLogonDate, LastBadPasswordAttempt, BadLogonCount, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CanonicalName, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive } -Credential [ $UserName | $Password ]"
                        }
                        else {
                            Invoke-Command -ScriptBlock {
                                Get-ADUser -Filter * -Properties * `
                                | Select-Object Name, SID, Enabled, LockedOut, Created, Modified, LastLogonDate, LastBadPasswordAttempt, BadLogonCount, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CanonicalName, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive
                            } `
                            | Export-Csv $script:AccountsTreeNodeFileSave -NoTypeInformation
                            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message  "Invoke-Command -ScriptBlock { Get-ADUser -Filter * -Properties * | Select-Object Name, SID, Enabled, LockedOut, Created, Modified, LastLogonDate, LastBadPasswordAttempt, BadLogonCount, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CanonicalName, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive }"
                        }
                        Save-TreeViewData -Accounts
        
                        $AccountsTreeNodeOUCNRadioButton.checked = $true
                        $ImportFromADFrom.Close()
                    }
                }
                $ImportFromADLocalhostGroupBox.Controls.Add($ImportFromADLocalhostImportButton)
                CommonButtonSettings -Button $ImportFromADLocalhostImportButton
                $ImportFromADFrom.Controls.Add($ImportFromADLocalhostGroupBox)
        
            [System.GC]::Collect()
        
            $ImportFromADFrom.ShowDialog()
    }
}