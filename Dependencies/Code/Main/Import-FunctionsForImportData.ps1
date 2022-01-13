Update-FormProgress "Import-HostsFromDomain"
Function Import-HostsFromDomain {
    <#
        .Description
        Takes entered domain and lists all computers
        Used within the Import-DataFromActiveDirectory function
    #>
    param(
        [string]$Choice,
        [string]$Script:Domain
    )
    $DN          = ""
    $Response    = ""
    $DNSName     = ""
    $DNSArray    = ""
    $objSearcher = ""
    $colProplist = ""
    $objComputer = ""
    $objResults  = ""
    $colResults  = ""
    $Computer    = ""
    $comp        = ""
    New-Item -type file -force "$Script:Folder_Path\Computer_List$Script:curDate.txt" | Out-Null
    $Script:Compute = "$Script:Folder_Path\Computer_List$Script:curDate.txt"
    $strCategory = "(ObjectCategory=Computer)"

    If($Choice -eq "Auto" -or $Choice -eq "" ) {
        $DNSName = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().Name
        If($DNSName -ne $Null) {
            $DNSArray = $DNSName.Split(".")
            for ($x = 0; $x -lt $DNSArray.Length ; $x++) {
                if ($x -eq ($DNSArray.Length - 1)){$Separator = ""}else{$Separator =","}
                [string]$DN += "DC=" + $DNSArray[$x] + $Separator  } }
        $Script:Domain = $DN
        Write-Output "Pulled computers from: "$Script:Domain
        $objSearcher = New-Object System.DirectoryServices.DirectorySearcher("LDAP://$Script:Domain")
        $objSearcher.Filter = $strCategory
        $objSearcher.PageSize = 100000
        $objSearcher.SearchScope = "SubTree"
        $colProplist = "name"
        foreach ($i in $colPropList) {
            $objSearcher.propertiesToLoad.Add($i) }
        $colResults = $objSearcher.FindAll()
        foreach ($objResult in $colResults) {
            $objComputer = $objResult.Properties
            $comp = $objComputer.name
            Write-Output $comp | Out-File $Script:Compute -Append }
        $Script:ComputerList = (Get-Content $Script:Compute) | Sort-Object
    }
	elseif($Choice -eq "Manual") {
        $objOU = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$Script:Domain")
        $objSearcher = New-Object System.DirectoryServices.DirectorySearcher
        $objSearcher.SearchRoot = $objOU
        $objSearcher.Filter = $strCategory
        $objSearcher.PageSize = 100000
        $objSearcher.SearchScope = "SubTree"
        $colProplist = "name"
        foreach ($i in $colPropList) { $objSearcher.propertiesToLoad.Add($i) }
        $colResults = $objSearcher.FindAll()
        foreach ($objResult in $colResults) {
            $objComputer = $objResult.Properties
            $comp = $objComputer.name
            Write-Output $comp | Out-File $Script:Compute -Append }
        $Script:ComputerList = (Get-Content $Script:Compute) | Sort-Object
    }
    else {
        #Write-Host "You did not supply a correct response, Please select a response." -foregroundColor Red
        . Import-HostsFromDomain }
}



Update-FormProgress "Import-DataFromTxt"
Function Import-DataFromTxt {
    <#
        .Description
        Imports data from a Text file and popultes the respective tree view with nodes
    #>
    param(
        [switch]$Endpoint,
        [switch]$Accounts
    )

    if ($Endpoint){
        $ComputerAndAccountTreeViewTabControl.SelectedTab = $ComputerTreeviewTab

        [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
        $ComputerTreeNodeImportTxtOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{
            Title            = "Import .txt Data"
            InitialDirectory = "$PewRoot"
            filter           = "TXT (*.txt)| *.txt|All files (*.*)|*.*"
            ShowHelp         = $true
        }
        $ComputerTreeNodeImportTxtOpenFileDialog.ShowDialog() | Out-Null
        $ComputerTreeNodeImportTxt = Get-Content $($ComputerTreeNodeImportTxtOpenFileDialog.filename)

        $StatusListBox.Items.Clear()
        #Removed For Testing#
        $ResultsListBox.Items.Clear()

        foreach ($Computer in $($ComputerTreeNodeImportTxt | Where-Object {$_ -ne ''}) ) {
            # Checks if the data already exists
            if ($script:ComputerTreeViewData.Name -contains $Computer) {
                Message-TreeViewNodeAlreadyExists -Endpoint -Message "Import .CSV:  Warning" -Computer $Computer -ResultsListBoxMessage
            }
            else {
                $ComputerAndAccountTreeViewTabControl.SelectedTab = $ComputerTreeviewTab
                $script:ComputerTreeNodeComboBox.SelectedItem = 'CanonicalName'

                Add-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category '/Unknown' -Entry $Computer -ToolTip 'N/A'

                $script:ComputerTreeViewData += [PSCustomObject]@{
                    Name            = $Computer
                    OperatingSystem = 'Unknown'
                    CanonicalName   = '/Unknown'
                    IPv4Address     = 'N/A'
                    MACAddress      = 'N/A'
                }
                $script:ComputerTreeView.Nodes.Clear()
                Initialize-TreeViewData -Endpoint
                Update-TreeViewState -Endpoint -NoMessage
                Normalize-TreeViewData -Endpoint
                Foreach($Computer in $script:ComputerTreeViewData) { Add-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category $Computer.CanonicalName -Entry $Computer.Name -ToolTip $ComputerData.IPv4Address -IPv4Address $Computer.IPv4Address }
                $script:ComputerTreeView.ExpandAll()
            }
        }
        Save-TreeViewData -Endpoint
    }
    if ($Accounts){
        $ComputerAndAccountTreeViewTabControl.SelectedTab = $AccountsTreeviewTab

        [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
        $AccountsTreeNodeImportTxtOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{
            Title            = "Import .txt Data"
            InitialDirectory = "$PewRoot"
            filter           = "TXT (*.txt)| *.txt|All files (*.*)|*.*"
            ShowHelp         = $true
        }
        $AccountsTreeNodeImportTxtOpenFileDialog.ShowDialog() | Out-Null
        $AccountsTreeNodeImportTxt = Get-Content $($AccountsTreeNodeImportTxtOpenFileDialog.filename)

        $StatusListBox.Items.Clear()
        #Removed For Testing#
        $ResultsListBox.Items.Clear()

        foreach ($Account in $($AccountsTreeNodeImportTxt | Where-Object {$_ -ne ''}) ) {
            # Checks if the data already exists
            if ($script:AccountsTreeViewData.Name -contains $Account) {
                Message-TreeViewNodeAlreadyExists -Accounts -Message "Import .CSV:  Warning" -Account $Account -ResultsListBoxMessage
            }
            else {
                $ComputerAndAccountTreeViewTabControl.SelectedTab = $AccountsTreeviewTab
                $script:AccountsTreeNodeComboBox.SelectedItem = 'CanonicalName'

                Add-TreeViewData -Accounts -RootNode $script:TreeNodeAccountsList -Category '/Unknown' -Entry $Account -ToolTip 'N/A'

                $script:AccountsTreeViewData += [PSCustomObject]@{
                    Name            = $Account
                    OperatingSystem = 'Unknown'
                    CanonicalName   = '/Unknown'
                    IPv4Address     = 'N/A'
                    MACAddress      = 'N/A'
                }
                $script:AccountsTreeView.Nodes.Clear()
                Initialize-TreeViewData -Accounts
                Update-TreeViewState -Accounts -NoMessage
                Normalize-TreeViewData -Accounts
                Foreach($Account in $script:AccountsTreeViewData) { Add-TreeViewData -Accounts -RootNode $script:TreeNodeAccountsList -Category $Account.CanonicalName -Entry $Account.Name -ToolTip $Account.SID }
                $script:AccountsTreeView.ExpandAll()
            }
        }
        Save-TreeViewData -Accounts
    }
}



Update-FormProgress "Import-DataFromCsv"
Function Import-DataFromCsv {
    <#
        .Description
        Imports data from a CSV file and popultes the respective tree view with nodes
        The CSV file is ideally created from the csv export of Get-ADComputer or Get-ADUser from Active Directory
    #>
    param(
        [switch]$Endpoint,
        [switch]$Accounts
    )

    if ($Endpoint){
        $ComputerAndAccountTreeViewTabControl.SelectedTab = $ComputerTreeviewTab
        $InformationTabControl.SelectedTab = $Section3ResultsTab

        [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
        $ComputerTreeNodeImportCsvOpenFileDialog                  = New-Object System.Windows.Forms.OpenFileDialog -Property @{
            Title            = "Import .csv Data"
            InitialDirectory = "$PewRoot"
            filter           = "CSV (*.csv)| *.csv|Excel (*.xlsx)| *.xlsx|Excel (*.xls)| *.xls|All files (*.*)|*.*"
            ShowHelp         = $true
        }
        $ComputerTreeNodeImportCsvOpenFileDialog.ShowDialog() | Out-Null
        $ComputerTreeNodeImportCsv = Import-Csv $($ComputerTreeNodeImportCsvOpenFileDialog.filename) | Select-Object -Property Name, IPv4Address, MACAddress, OperatingSystem, CanonicalName | Sort-Object -Property CanonicalName

        $StatusListBox.Items.Clear()
        #Removed For Testing#
        $ResultsListBox.Items.Clear()

        # Imports data
        foreach ($Computer in $ComputerTreeNodeImportCsv) {
            # Checks if data already exists
            if ($script:ComputerTreeViewData.Name -contains $Computer.Name) {
                Message-TreeViewNodeAlreadyExists -Endpoint -Message "Import .CSV:  Warning" -Computer $Computer.Name -ResultsListBoxMessage
            }
            else {
                $ComputerAndAccountTreeViewTabControl.SelectedTab = $ComputerTreeviewTab
                $script:ComputerTreeNodeComboBox.SelectedItem = 'CanonicalName'

                $CanonicalName = $($($Computer.CanonicalName) -replace $Computer.Name,"" -replace $Computer.CanonicalName.split('/')[0],"").TrimEnd("/")
                if ($Computer.CanonicalName -eq "") { Add-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category '/Unknown' -Entry $Computer.Name -ToolTip $ComputerData.IPv4Address -IPv4Address $Computer.IPv4Address }
                else { Add-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category $CanonicalName -Entry $Computer.Name -ToolTip $ComputerData.IPv4Address -IPv4Address $Computer.IPv4Address }

                $script:ComputerTreeViewData += $Computer

                $script:ComputerTreeView.Nodes.Clear()
                Initialize-TreeViewData -Endpoint
                Update-TreeViewState -Endpoint -NoMessage
                Normalize-TreeViewData -Endpoint
                Foreach($Computer in $script:ComputerTreeViewData) { Add-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category $Computer.CanonicalName -Entry $Computer.Name -ToolTip $ComputerData.IPv4Address -IPv4Address $Computer.IPv4Address }
                $script:ComputerTreeView.ExpandAll()
            }
        }
        Save-TreeViewData -Endpoint
    }
    elseif ($Accounts){
        $ComputerAndAccountTreeViewTabControl.SelectedTab = $AccountsTreeviewTab
        $InformationTabControl.SelectedTab = $Section3ResultsTab

        [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
        $AccountsTreeNodeImportCsvOpenFileDialog                  = New-Object System.Windows.Forms.OpenFileDialog -Property @{
            Title            = "Import .csv Data"
            InitialDirectory = "$PewRoot"
            filter           = "CSV (*.csv)| *.csv|Excel (*.xlsx)| *.xlsx|Excel (*.xls)| *.xls|All files (*.*)|*.*"
            ShowHelp         = $true
        }
        $AccountsTreeNodeImportCsvOpenFileDialog.ShowDialog() | Out-Null
        $AccountsTreeNodeImportCsv = Import-Csv $($AccountsTreeNodeImportCsvOpenFileDialog.filename) | Select-Object -Property Name, IPv4Address, MACAddress, OperatingSystem, CanonicalName | Sort-Object -Property CanonicalName

        $StatusListBox.Items.Clear()
        #Removed For Testing#
        $ResultsListBox.Items.Clear()

        # Imports data
        foreach ($Account in $AccountsTreeNodeImportCsv) {
            # Checks if data already exists
            if ($script:AccountsTreeViewData.Name -contains $Account.Name) {
                Message-TreeViewNodeAlreadyExists -Accounts -Message "Import .CSV:  Warning" -Account $Account.Name -ResultsListBoxMessage
            }
            else {
                $ComputerAndAccountTreeViewTabControl.SelectedTab = $AccountsTreeviewTab
                $script:AccountsTreeNodeComboBox.SelectedItem = 'CanonicalName'

                $CanonicalName = $($($Account.CanonicalName) -replace $Account.Name,"" -replace $Account.CanonicalName.split('/')[0],"").TrimEnd("/")
                if ($Account.CanonicalName -eq "") { Add-TreeViewData -Accounts -RootNode $script:TreeNodeAccountsList -Category '/Unknown' -Entry $Account.Name -ToolTip $Account.SID }
                else { Add-TreeViewData -Accounts -RootNode $script:TreeNodeAccountsList -Category $CanonicalName -Entry $Account.Name -ToolTip $Account.SID }

                $script:AccountsTreeViewData += $Account

                $script:AccountsTreeView.Nodes.Clear()
                Initialize-TreeViewData -Accounts
                Update-TreeViewState -Accounts -NoMessage
                Normalize-TreeViewData -Accounts
                Foreach($Account in $script:AccountsTreeViewData) { Add-TreeViewData -Accounts -RootNode $script:TreeNodeAccountsList -Category $Account.CanonicalName -Entry $Account.Name -ToolTip $Account.SID }
                $script:AccountsTreeView.ExpandAll()
            }
        }
        Save-TreeViewData -Accounts
    }
}


Update-FormProgress "Import-DataFromActiveDirectory"
Function Import-DataFromActiveDirectory {
    <#
        .Description
        Imports data directly from Active Directory
    #>
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
                    Message-TreeViewNodeAlreadyExists -Endpoint -Message "Importing Hosts:  Warning" -Computer $Computer.Name -ResultsListBoxMessage
                    Add-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category $Computer.OperatingSystem -Entry $Computer.Name -ToolTip $ComputerData.IPv4Address -IPv4Address $Computer.IPv4Address
                }
                else {
                    $ComputerAndAccountTreeViewTabControl.SelectedTab = $ComputerTreeviewTab
                    $script:ComputerTreeNodeComboBox.SelectedItem = 'CanonicalName'

                    $CanonicalName = $($($Computer.CanonicalName) -replace $Computer.Name,"" -replace $Computer.CanonicalName.split('/')[0],"").TrimEnd("/")
                    if ($Computer.CanonicalName -eq "") {
                        Add-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category '/Unknown' -Entry $Computer.Name -ToolTip $ComputerData.IPv4Address -IPv4Address $Computer.IPv4Address
                    }
                    else {
                        Add-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category $CanonicalName -Entry $Computer.Name -ToolTip $ComputerData.IPv4Address -IPv4Address $Computer.IPv4Address
                    }
                    $script:ComputerTreeViewData += $Computer
                }
            }

            $ComputerAndAccountTreeViewTabControl.SelectedTab = $ComputerTreeviewTab
            $script:ComputerTreeNodeComboBox.SelectedItem = 'CanonicalName'

            Foreach($Computer in $script:ComputerTreeViewData) {
                Add-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category $Computer.CanonicalName -Entry $Computer.Name -ToolTip $ComputerData.IPv4Address -IPv4Address $Computer.IPv4Address
            }

            #Updates TreeView
            $script:ComputerTreeView.Nodes.Clear()
            Initialize-TreeViewData -Endpoint
            Normalize-TreeViewData -Endpoint
            Foreach($Computer in $script:ComputerTreeViewData) { Add-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category $Computer.CanonicalName -Entry $Computer.Name -ToolTip $ComputerData.IPv4Address -IPv4Address $Computer.IPv4Address }
            $script:ComputerTreeView.ExpandAll()
            Update-TreeViewState -Endpoint
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


                $ImportFromADWinRMManuallEntryTextBox = New-Object System.Windows.Forms.TextBox -Property @{
                    Text      = "<Enter a hostname/IP>"
                    left      = $FormScale * 5
                    top       = $ImportFromADWinRMNoteLabel.top + $ImportFromADWinRMNoteLabel.height + $($FormScale * 5)
                    Width     = $FormScale * 185
                    Height    = $FormScale * 22
                    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                    ForeColor = "Black"
                    Add_KeyDown    = { if ($_.KeyCode -eq "Enter") { if ($this.text -eq "<Enter a hostname/IP>") { $this.text = "" } } }
                    Add_MouseEnter = { if ($this.text -eq "<Enter a hostname/IP>") { $this.text = "" } }
                    Add_MouseLeave = { if ($this.text -eq "") { $this.text = "<Enter a hostname/IP>" } }
                    Add_MouseHover = {
                        Show-ToolTip -Title "Hostname or IP Address" -Icon "Info" -Message @"
+  Enter the hostname or IP address of the Active Directory Server
+  Example: dc1
"@
                    }
                }
                $ImportFromADWinRMGroupBox.Controls.Add($ImportFromADWinRMManuallEntryTextBox)
                if (Get-Content $ActiveDirectoryEndpoint) { $ImportFromADWinRMManuallEntryTextBox.Text = Get-Content $ActiveDirectoryEndpoint }


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
                        $ImportFromADWinRMManuallEntryTextBox.Text | Out-File $ActiveDirectoryEndpoint -Force

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
                                    if (!$script:Credential) { Set-NewCredential }
                                    Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Credentials Used: $($script:Credential.UserName)"
                                    $Username = $script:Credential.UserName
                                    $Password = '"PASSWORD HIDDEN"'
                                    [array]$ImportedActiveDirectoryHosts = Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, CanonicalName, OperatingSystem, OperatingSystemHotfix, OperatingSystemServicePack, Enabled, LockedOut, LogonCount, Created, Modified, LastLogonDate, IPv4Address, MACAddress, MemberOf, isCriticalSystemObject, HomedirRequired, Location, ProtectedFromAccidentalDeletion, TrustedForDelegation, SID } -ComputerName $ImportFromADWinRMManuallEntryTextBoxTarget -Credential $script:Credential
                                    Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, CanonicalName, OperatingSystem, OperatingSystemHotfix, OperatingSystemServicePack, Enabled, LockedOut, LogonCount, Created, Modified, LastLogonDate, IPv4Address, MACAddress, MemberOf, isCriticalSystemObject, HomedirRequired, Location, ProtectedFromAccidentalDeletion, TrustedForDelegation, SID } -ComputerName $($ImportFromADWinRMManuallEntryTextBox.Text) -Credential [ $UserName | $Password ]"
                                }
                                else {
                                    [array]$ImportedActiveDirectoryHosts = Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, CanonicalName, OperatingSystem, OperatingSystemHotfix, OperatingSystemServicePack, Enabled, LockedOut, LogonCount, Created, Modified, LastLogonDate, IPv4Address, MACAddress, MemberOf, isCriticalSystemObject, HomedirRequired, Location, ProtectedFromAccidentalDeletion, TrustedForDelegation, SID } -ComputerName $ImportFromADWinRMManuallEntryTextBoxTarget
                                    Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message  "Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, CanonicalName, OperatingSystem, OperatingSystemHotfix, OperatingSystemServicePack, Enabled, LockedOut, LogonCount, Created, Modified, LastLogonDate, IPv4Address, MACAddress, MemberOf, isCriticalSystemObject, HomedirRequired, Location, ProtectedFromAccidentalDeletion, TrustedForDelegation, SID } -ComputerName $($ImportFromADWinRMManuallEntryTextBox.Text)"
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
                                    if (!$script:Credential) { Set-NewCredential }
                                    Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Credentials Used: $($script:Credential.UserName)"
                                    $Username = $script:Credential.UserName
                                    $Password = '"PASSWORD HIDDEN"'

                                    [array]$ImportedActiveDirectoryHosts = Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, CanonicalName, OperatingSystem, OperatingSystemHotfix, OperatingSystemServicePack, Enabled, LockedOut, LogonCount, Created, Modified, LastLogonDate, IPv4Address, MACAddress, MemberOf, isCriticalSystemObject, HomedirRequired, Location, ProtectedFromAccidentalDeletion, TrustedForDelegation, SID } -ComputerName $script:ComputerTreeViewSelected -Credential $script:Credential
                                    Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, CanonicalName, OperatingSystem, OperatingSystemHotfix, OperatingSystemServicePack, Enabled, LockedOut, LogonCount, Created, Modified, LastLogonDate, IPv4Address, MACAddress, MemberOf, isCriticalSystemObject, HomedirRequired, Location, ProtectedFromAccidentalDeletion, TrustedForDelegation, SID } -ComputerName $script:ComputerTreeViewSelected -Credential [ $UserName | $Password ]"
                                }
                                else {
                                    [array]$ImportedActiveDirectoryHosts = Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, CanonicalName, OperatingSystem, OperatingSystemHotfix, OperatingSystemServicePack, Enabled, LockedOut, LogonCount, Created, Modified, LastLogonDate, IPv4Address, MACAddress, MemberOf, isCriticalSystemObject, HomedirRequired, Location, ProtectedFromAccidentalDeletion, TrustedForDelegation, SID } -ComputerName $script:ComputerTreeViewSelected
                                    Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, CanonicalName, OperatingSystem, OperatingSystemHotfix, OperatingSystemServicePack, Enabled, LockedOut, LogonCount, Created, Modified, LastLogonDate, IPv4Address, MACAddress, MemberOf, isCriticalSystemObject, HomedirRequired, Location, ProtectedFromAccidentalDeletion, TrustedForDelegation, SID } -ComputerName $script:ComputerTreeViewSelected"
                                }
                            }
                            else {
                                [system.media.systemsounds]::Exclamation.play()
                                $StatusListBox.Items.Clear()
                                $StatusListBox.Items.Add("Import from Active Directory:  Cancelled")
                            }
                        }
                        elseif ($script:ComputerTreeViewSelected.count -lt 1) {
                            Show-MessageBox -Message "No hostname/IP selected`r`nMake sure to checkbox only one hostname/IP`r`nSelecting a Category will not allow you to connect to multiple hosts" -Title "Importing Hosts:  Error"
                        }
                        elseif ($script:ComputerTreeViewSelected.count -gt 1) {
                            Show-MessageBox -Message "Too many hostname/IPs selected`r`nMake sure to checkbox only one hostname/IP`r`nSelecting a Category will not allow you to connect to multiple hosts" -Title "Importing Hosts:  Error"
                        }

                        Import-EndpointsFromDomain -ADComputer $ImportedActiveDirectoryHosts

                        $ImportFromADFrom.Close()
                    }
                }
                $ImportFromADWinRMGroupBox.Controls.Add($ImportFromADWinRMImportButton)
                Add-CommonButtonSettings -Button $ImportFromADWinRMImportButton
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
                            if (!$script:Credential) { Set-NewCredential }
                            Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Credentials Used: $($script:Credential.UserName)"
                            $Username = $script:Credential.UserName
                            $Password = '"PASSWORD HIDDEN"'
                            [array]$ImportedActiveDirectoryHosts = Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, CanonicalName, OperatingSystem, OperatingSystemHotfix, OperatingSystemServicePack, Enabled, LockedOut, LogonCount, Created, Modified, LastLogonDate, IPv4Address, MACAddress, MemberOf, isCriticalSystemObject, HomedirRequired, Location, ProtectedFromAccidentalDeletion, TrustedForDelegation, SID } -Credential $script:Credential
                            Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, CanonicalName, OperatingSystem, OperatingSystemHotfix, OperatingSystemServicePack, Enabled, LockedOut, LogonCount, Created, Modified, LastLogonDate, IPv4Address, MACAddress, MemberOf, isCriticalSystemObject, HomedirRequired, Location, ProtectedFromAccidentalDeletion, TrustedForDelegation, SID } -Credential [ $UserName | $Password ]"
                        }
                        else {
                            [array]$ImportedActiveDirectoryHosts = Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, CanonicalName, OperatingSystem, OperatingSystemHotfix, OperatingSystemServicePack, Enabled, LockedOut, LogonCount, Created, Modified, LastLogonDate, IPv4Address, MACAddress, MemberOf, isCriticalSystemObject, HomedirRequired, Location, ProtectedFromAccidentalDeletion, TrustedForDelegation, SID }
                            Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message  "Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, CanonicalName, OperatingSystem, OperatingSystemHotfix, OperatingSystemServicePack, Enabled, LockedOut, LogonCount, Created, Modified, LastLogonDate, IPv4Address, MACAddress, MemberOf, isCriticalSystemObject, HomedirRequired, Location, ProtectedFromAccidentalDeletion, TrustedForDelegation, SID }"
                        }
                        Import-EndpointsFromDomain -ADComputer $ImportedActiveDirectoryHosts
                        Update-TreeViewState -Endpoint

                        $ImportFromADFrom.Close()
                    }
                }
                $ImportFromADLocalhostGroupBox.Controls.Add($ImportFromADLocalhostImportButton)
                Add-CommonButtonSettings -Button $ImportFromADLocalhostImportButton
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


            $ImportFromADManualEntryTextBox = New-Object System.Windows.Forms.TextBox -Property @{
                Text      = "<Domain Name>"
                left      = $FormScale * 5
                top       = $ImportFromDomainNoteLabel.top + $ImportFromDomainNoteLabel.height + $($FormScale * 5)
                Width     = $FormScale * 185
                Height    = $FormScale * 22
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor = "Black"
                Add_MouseEnter = { if ($this.text -eq "<Domain Name>") { $this.text = "" } }
                Add_MouseLeave = { if ($this.text -eq "") { $this.text = "<Domain Name>" } }
                Add_MouseHover = {
                    Show-ToolTip -Title "Domain Name" -Icon "Info" -Message @"
+  Enter the Domain Name of the Active Directory Server
+  Example: training.lab or east.company.com
"@
                }
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
                                    Add-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category $CurrentDomain -Entry $Computer -ToolTip $Computer.IPv4Address -IPv4Address $Computer.IPv4Address
                                    $ComputerTreeNodeAddHostnameIP = New-Object PSObject -Property @{
                                        Name            = $Computer
                                        OperatingSystem = 'Unknown'
                                        CanonicalName   = "/$CurrentDomain"
                                        IPv4Address     = ''
                                    }
                                    $script:ComputerTreeViewData += $ComputerTreeNodeAddHostnameIP
                                }
                                else {
                                    Add-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category $($ImportFromADManualEntryTextBox.Text) -Entry $Computer -ToolTip $Computer.IPv4Address -IPv4Address $Computer.IPv4Address
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
                    Update-TreeViewState -Endpoint

                    $ImportFromADFrom.Close()
                }
            }
            $ImportFromADAutoPullGroupBox.Controls.Add($ImportFromADImportButton)
            Add-CommonButtonSettings -Button $ImportFromADImportButton
            $ImportFromADFrom.Controls.Add($ImportFromADAutoPullGroupBox)

            [System.GC]::Collect()

            $ImportFromADFrom.ShowDialog()
    }
    if ($Accounts){
        $ComputerAndAccountTreeViewTabControl.SelectedTab = $AccountsTreeviewTab

        $ImportFromADFrom = New-Object Windows.Forms.Form -Property @{
            Text          = 'Import Account information from Active Directory'
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


                $ImportFromADWinRMManuallEntryTextBox = New-Object System.Windows.Forms.TextBox -Property @{
                    Text      = "<Enter a hostname/IP>"
                    left      = $FormScale * 5
                    top       = $ImportFromADWinRMNoteLabel.top + $ImportFromADWinRMNoteLabel.height + $($FormScale * 5)
                    Width     = $FormScale * 185
                    Height    = $FormScale * 22
                    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                    ForeColor = "Black"
                    Add_KeyDown    = { if ($_.KeyCode -eq "Enter") { { if ($this.text -eq "<Enter a hostname/IP>") { $this.text = "" } } } }
                    Add_MouseEnter = { if ($this.text -eq "<Enter a hostname/IP>") { $this.text = "" } }
                    Add_MouseLeave = { if ($this.text -eq "") { $this.text = "<Enter a hostname/IP>" } }
                    Add_MouseHover = {
                    Show-ToolTip -Title "Hostname/IP" -Icon "Info" -Message @"
+  Enter the Hostname or IP of the Active Directory Server
"@
                    }
                }
                $ImportFromADWinRMGroupBox.Controls.Add($ImportFromADWinRMManuallEntryTextBox)
                if (Get-Content $ActiveDirectoryEndpoint) { $ImportFromADWinRMManuallEntryTextBox.Text = Get-Content $ActiveDirectoryEndpoint }


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
                        $ImportFromADWinRMManuallEntryTextBox.Text | Out-File $ActiveDirectoryEndpoint -Force

                        Create-TreeViewCheckBoxArray -Accounts
                        if ($ImportFromADWinRMManuallEntryTextBox.Text -ne '<Enter a hostname/IP>' -and $ImportFromADWinRMManuallEntryTextBox.Text -ne '' -and $ImportFromADWinRMAutoCheckBox.checked -eq $false ) {
                            if (Verify-Action -Title "Verification: Active Directory Import" -Question "Credentials Used:`n$($script:Credential.UserName)`n`nImport Active Directory account information from the following?" -Computer $ImportFromADWinRMManuallEntryTextBox.text) {
                                $StatusListBox.Items.Clear()
                                $StatusListBox.Items.Add("Importing Hosts From Active Directory")

                                # This brings specific tabs to the forefront/front view
                                $InformationTabControl.SelectedTab = $Section3ResultsTab
                                $ImportFromADWinRMManuallEntryTextBoxTarget = $ImportFromADWinRMManuallEntryTextBox.Text
                                if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                                    if (!$script:Credential) { Set-NewCredential }
                                    Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Credentials Used: $($script:Credential.UserName)"
                                    $Username = $script:Credential.UserName
                                    $Password = '"PASSWORD HIDDEN"'
                                    $script:AccountsTreeViewData = Invoke-Command -ScriptBlock {
                                        Get-ADUser -Filter * -Properties * `
                                        | Select-Object Name, SID, Enabled, LockedOut, Created, Modified, LastLogonDate, LastBadPasswordAttempt, BadLogonCount, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CanonicalName, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive
                                    } -ComputerName $ImportFromADWinRMManuallEntryTextBoxTarget -Credential $script:Credential
                                    $script:AccountsTreeViewData | Export-Csv $AccountsTreeNodeFileSave -NoTypeInformation
                                    Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { Get-ADUser -Filter * -Properties * | Select-Object Name, SID, Enabled, LockedOut, Created, Modified, LastLogonDate, LastBadPasswordAttempt, BadLogonCount, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CanonicalName, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive } -ComputerName $($ImportFromADWinRMManuallEntryTextBox.Text) -Credential [ $UserName | $Password ]"
                                }
                                else {
                                    $script:AccountsTreeViewData = Invoke-Command -ScriptBlock {
                                        Get-ADUser -Filter * -Properties * `
                                        | Select-Object Name, SID, Enabled, LockedOut, Created, Modified, LastLogonDate, LastBadPasswordAttempt, BadLogonCount, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CanonicalName, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive
                                    } -ComputerName $ImportFromADWinRMManuallEntryTextBoxTarget
                                    $script:AccountsTreeViewData | Export-Csv $AccountsTreeNodeFileSave -NoTypeInformation
                                    Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message  "Invoke-Command -ScriptBlock { Get-ADUser -Filter * -Properties * | Select-Object Name, SID, Enabled, LockedOut, Created, Modified, LastLogonDate, LastBadPasswordAttempt, BadLogonCount, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CanonicalName, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive } -ComputerName $($ImportFromADWinRMManuallEntryTextBox.Text)"
                                }
                                #Initialize-TreeViewData -Accounts
                                Normalize-TreeViewData -Accounts
                                Save-TreeViewData -Accounts

                                Foreach($Account in $script:AccountsTreeViewData) {
                                    Add-TreeViewData -Accounts -RootNode $script:TreeNodeAccountsList -Category $Account.Enabled -Entry $Account.Name -ToolTip $Account.SID -Metadata $Account
                                }

                                Update-TreeViewState -Accounts
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
                                    if (!$script:Credential) { Set-NewCredential }
                                    Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Credentials Used: $($script:Credential.UserName)"
                                    $Username = $script:Credential.UserName
                                    $Password = '"PASSWORD HIDDEN"'

                                    $script:AccountsTreeViewData = Invoke-Command -ScriptBlock {
                                        Get-ADUser -Filter * -Properties * `
                                        | Select-Object Name, SID, Enabled, LockedOut, Created, Modified, LastLogonDate, LastBadPasswordAttempt, BadLogonCount, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CanonicalName, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive
                                    } -ComputerName $script:ComputerTreeViewSelected -Credential $script:Credential
                                    $script:AccountsTreeViewData | Export-Csv $AccountsTreeNodeFileSave -NoTypeInformation

                                    Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { Get-ADUser -Filter * -Properties * | Select-Object Name, SID, Enabled, LockedOut, Created, Modified, LastLogonDate, LastBadPasswordAttempt, BadLogonCount, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CanonicalName, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive } -ComputerName $script:ComputerTreeViewSelected -Credential [ $UserName | $Password ]"
                                }
                                else {
                                    $script:AccountsTreeViewData = Invoke-Command -ScriptBlock {
                                        Get-ADUser -Filter * -Properties * `
                                        | Select-Object Name, SID, Enabled, LockedOut, Created, Modified, LastLogonDate, LastBadPasswordAttempt, BadLogonCount, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CanonicalName, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive
                                    } -ComputerName $script:ComputerTreeViewSelected
                                    $script:AccountsTreeViewData | Export-Csv $AccountsTreeNodeFileSave -NoTypeInformation
                                    Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { Get-ADUser -Filter * -Properties * | Select-Object Name, SID, Enabled, LockedOut, Created, Modified, LastLogonDate, LastBadPasswordAttempt, BadLogonCount, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CanonicalName, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive } -ComputerName $script:ComputerTreeViewSelected"
                                }
                                #Initialize-TreeViewData -Accounts
                                Normalize-TreeViewData -Accounts
                                Save-TreeViewData -Accounts

                                Foreach($Account in $script:AccountsTreeViewData) {
                                    Add-TreeViewData -Accounts -RootNode $script:TreeNodeAccountsList -Category $Account.Enabled -Entry $Account.Name -ToolTip $Account.SID -Metadata $Account
                                }

                                Update-TreeViewState -Accounts
                            }
                            else {
                                [system.media.systemsounds]::Exclamation.play()
                                $StatusListBox.Items.Clear()
                                $StatusListBox.Items.Add("Import from Active Directory:  Cancelled")
                            }
                        }
                        elseif ($script:ComputerTreeViewSelected.count -lt 1) {
                            Show-MessageBox -Message "No hostname/IP selected`r`nMake sure to checkbox only one hostname/IP`r`nSelecting a Category will not allow you to connect to multiple hosts" -Title "Importing Accounts:  Error"
                        }
                        elseif ($script:ComputerTreeViewSelected.count -gt 1) {
                            Show-MessageBox -Message "Too many hostname/IPs selected`r`nMake sure to checkbox only one hostname/IP`r`nSelecting a Category will not allow you to connect to multiple hosts" -Title "Importing Accounts:  Error"
                        }

                        Save-TreeViewData -Accounts

                        $ImportFromADFrom.Close()
                    }
                }
                $ImportFromADWinRMGroupBox.Controls.Add($ImportFromADWinRMImportButton)
                Add-CommonButtonSettings -Button $ImportFromADWinRMImportButton
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
                            if (!$script:Credential) { Set-NewCredential }
                            Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Credentials Used: $($script:Credential.UserName)"
                            $Username = $script:Credential.UserName
                            $Password = '"PASSWORD HIDDEN"'
                            Invoke-Command -ScriptBlock {
                                Get-ADUser -Filter * -Properties * `
                                | Select-Object Name, SID, Enabled, LockedOut, Created, Modified, LastLogonDate, LastBadPasswordAttempt, BadLogonCount, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CanonicalName, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive
                            } -Credential $script:Credential `
                            | Export-Csv $AccountsTreeNodeFileSave -NoTypeInformation
                            Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { Get-ADUser -Filter * -Properties * | Select-Object Name, SID, Enabled, LockedOut, Created, Modified, LastLogonDate, LastBadPasswordAttempt, BadLogonCount, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CanonicalName, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive } -Credential [ $UserName | $Password ]"
                        }
                        else {
                            Invoke-Command -ScriptBlock {
                                Get-ADUser -Filter * -Properties * `
                                | Select-Object Name, SID, Enabled, LockedOut, Created, Modified, LastLogonDate, LastBadPasswordAttempt, BadLogonCount, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CanonicalName, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive
                            } `
                            | Export-Csv $AccountsTreeNodeFileSave -NoTypeInformation
                            Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message  "Invoke-Command -ScriptBlock { Get-ADUser -Filter * -Properties * | Select-Object Name, SID, Enabled, LockedOut, Created, Modified, LastLogonDate, LastBadPasswordAttempt, BadLogonCount, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CanonicalName, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive }"
                        }
                        Save-TreeViewData -Accounts

                        $AccountsTreeNodeOUCNRadioButton.checked = $true
                        $ImportFromADFrom.Close()
                    }
                }
                $ImportFromADLocalhostGroupBox.Controls.Add($ImportFromADLocalhostImportButton)
                Add-CommonButtonSettings -Button $ImportFromADLocalhostImportButton
                $ImportFromADFrom.Controls.Add($ImportFromADLocalhostGroupBox)

            [System.GC]::Collect()

            $ImportFromADFrom.ShowDialog()
    }
}



Update-FormProgress "Import-EndpointScripts"
Function Import-EndpointScripts {
    <#
        .Description
        Imports scripts from the Endpoint script folder and loads them into the treeview
        New scripts can be added to 'Dependencies\Commands & Scripts\Scirpts - Endpoint' to be imported
        Verify that the scripts function properly and return results with the Invoke-Command cmdlet
    #>
    Foreach ($script in (Get-ChildItem -Path "$CommandsAndScripts\Scripts-Host" | Where-Object {$_.Extension -eq '.ps1'})) {
        $CollectionName = $script.basename
        Update-FormProgress $CollectionName

        if ($CollectionName -match 'DeepBlue') {
            $script:AllEndpointCommands += [PSCustomObject]@{
                Name                 = $CollectionName
                Type                 = "script"
                Command_WinRM_Script = "Invoke-Command -FilePath '$($script.FullName)' -ArgumentList @('$CommandsAndScripts\Scripts-Host\Invoke-DeepBlue-regexes.txt','$CommandsAndScripts\Scripts-Host\Invoke-DeepBlue-whitelist.txt')"
                Arguments            = $null
                #Properties_PoSh      = 'PSComputerName, *'
                Description          = @"
$("$(Get-Help $($script.FullName) | Select-Object -ExpandProperty DESCRIPTION)".TrimStart('@{Text=').TrimEnd('}'))

Regex File:
$("$CommandsAndScripts\Scripts-Host\Invoke-DeepBlue-regexes.txt")

Whitelist File:
$("$CommandsAndScripts\Scripts-Host\Invoke-DeepBlue-whitelist.txt")
"@
                ScriptPath           = "$($script.FullName)"
                ExportFileName       = "$(($script.basename).trim())"
            }
        }
        else {
            $script:AllEndpointCommands += [PSCustomObject]@{
                Name                 = $CollectionName
                Type                 = "script"
                Command_WinRM_Script = "Invoke-Command -FilePath '$($script.FullName)'"
                Arguments            = $null
                #Properties_PoSh      = 'PSComputerName, *'
                Description          = @"
$("$(Get-Help $($script.FullName) | Select-Object -ExpandProperty SYNOPSIS)".TrimStart('@{Text=').TrimEnd('}'))

$("$(Get-Help $($script.FullName) | Select-Object -ExpandProperty DESCRIPTION)".TrimStart('@{Text=').TrimEnd('}'))
"@
                ScriptPath           = "$($script.FullName)"
                ExportFileName       = "$(($script.basename).trim())"
            }
        }
    }
}



Update-FormProgress "Import-ActiveDirectoryScripts"
Function Import-ActiveDirectoryScripts {
    Foreach ($script in (Get-ChildItem -Path "$CommandsAndScripts\Scripts-AD" | Where-Object {$_.Extension -eq '.ps1'})) {
        $CollectionName = $script.basename
        Update-FormProgress $CollectionName

        $script:AllActiveDirectoryCommands += [PSCustomObject]@{
            Name                 = $CollectionName
            Type                 = "script"
            Command_WinRM_Script = "Invoke-Command -FilePath '$($script.FullName)'"
            #Properties_PoSh      = 'PSComputerName, *'
            #Properties_WMI       = 'PSComputerName, *'
            Description          = "$(Get-Help $($script.FullName) | Select-Object -ExpandProperty Description)".TrimStart('@{Text=').TrimEnd('}')
            ScriptPath           = "$($script.FullName)"
        }
    }
}















# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUH4II2HeliV9YSmzRAaRNP0iU
# SlegggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUy13rSfLoPi/LP7RaRsdJesOkltYwDQYJKoZI
# hvcNAQEBBQAEggEAn9irJp2AmwkmaL77PQEqyE2thmbJjaUaBUL5ECpTNagnDztr
# 2HK/5ZLQYvIz98i7p6ZeoA2t7MGRxMjShwTEVcQ9xGRrKlIq4XkPLz76hSLDPGFt
# 8iznw96fgRJdbF2G5gYQrKRqiFVpi/gcA8S0vOFvJosEYj9tqt8xfnakLTW+gAgT
# aQl5NsVCxVa+29xwZfZisuLfNdajdbVdMWllKTmQkg2YdNR5+7U/wOi9+W/gvKrY
# nQDj1lK78bAxWiKX2hbeAvJhV52DNhDxM4dyY03jJpeh62R4RH4jNtD4iFXRLNJN
# 0pbaly5qKQO8kw2typN6+wZwYy7XrzphujTrmg==
# SIG # End signature block
