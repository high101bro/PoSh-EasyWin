$ComputerTreeNodeImportFromActiveDirectoryButtonAdd_Click = {
    Create-ComputerNodeCheckBoxArray    
    if ($script:SingleHostIPCheckBox.Checked -eq $true) {
        if (Verify-Action -Title "Verification: Active Directory Import" -Question "Make sure to select the proper server.`nImport Active Directory hosts from the following?" -Computer $script:SingleHostIPTextBoxTarget) {
            # This brings specific tabs to the forefront/front view
            $MainBottomTabControl.SelectedTab = $Section3ResultsTab
            $script:SingleHostIPTextBoxTarget = $script:SingleHostIPTextBox.Text

            if ($ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { Create-NewCredentials }
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Credentials Used: $($script:Credential.UserName)"
                $Username = $script:Credential.UserName
                $Password = '"PASSWORD HIDDEN"'
                
                [array]$ImportedActiveDirectoryHosts = Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, OperatingSystem, CanonicalName, IPv4Address, MACAddress } -ComputerName $script:SingleHostIPTextBoxTarget -Credential $script:Credential
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, OperatingSystem, CanonicalName, IPv4Address, MACAddress } -ComputerName $($script:SingleHostIPTextBox.Text) -Credential [ $UserName | $Password ]"
            }
            else {
                [array]$ImportedActiveDirectoryHosts = Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, OperatingSystem, CanonicalName, IPv4Address, MACAddress } -ComputerName $script:SingleHostIPTextBoxTarget
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message  "Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, OperatingSystem, CanonicalName, IPv4Address, MACAddress } -ComputerName $($script:SingleHostIPTextBox.Text)"
            }
            $script:SingleHostIPCheckBox.Checked = $false
            $script:SingleHostIPTextBox.Text     = $DefaultSingleHostIPText
            $script:ComputerTreeView.Enabled     = $true
            $script:ComputerTreeView.BackColor   = "white"

            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("Importing Hosts")
            $ResultsListBox.Items.Clear()
            $ResultsListBox.Items.Add("Importing hosts from Active Directory")
            $ResultsListBox.Items.Add("Make sure to select a domain server to import from")
            $ResultsListBox.Items.Add("")
            Start-Sleep -Seconds 1
            Update-NeedToSaveTreeView
        }
        else {
            [system.media.systemsounds]::Exclamation.play()
            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("Import from Active Directory:  Cancelled")
        }
    }
    elseif ($script:ComputerTreeViewSelected.count -eq 1) {
        Create-ComputerNodeCheckBoxArray
        if (Verify-Action -Title "Verification: Active Directory Import" -Question "Make sure to select the proper server.`nImport Active Directory hosts from the following?" -Computer $($script:ComputerTreeViewSelected -join ', ')) {
            # This brings specific tabs to the forefront/front view
            $MainBottomTabControl.SelectedTab = $Section3ResultsTab
            $script:SingleHostIPTextBoxTarget = $script:SingleHostIPTextBox.Text

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
            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("Importing Hosts")
            $ResultsListBox.Items.Clear()
            $ResultsListBox.Items.Add("Importing hosts from Active Directory")
            $ResultsListBox.Items.Add("Make sure to select a domain server to import from")
            $ResultsListBox.Items.Add("")
            Start-Sleep -Seconds 1
            Update-NeedToSaveTreeView
        }
        else {
            [system.media.systemsounds]::Exclamation.play()
            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("Import from Active Directory:  Cancelled")
        }
    }
    elseif ($script:ComputerTreeViewSelected.count -lt 1) { ComputerNodeSelectedLessThanOne -Message 'Importing Hosts' }
    elseif ($script:ComputerTreeViewSelected.count -gt 1) { ComputerNodeSelectedMoreThanOne -Message 'Importing Hosts' }
    
    # Imports data
    foreach ($Computer in $ImportedActiveDirectoryHosts) {
        # Checks if data already exists
        if ($script:ComputerTreeViewData.Name -contains $Computer.Name) {
            Message-HostAlreadyExists -Message "Importing Hosts:  Warning" -Computer $Computer.Name
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
    AutoSave-HostData
    Update-NeedToSaveTreeView
}
