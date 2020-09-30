$ImportAccountDataFromActiveDirectoryButtonAdd_Click = {

function Import-AccountsFromDomain {
    Save-HostData
    AutoSave-HostData
}


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
            Text      = "Import Accounts"
            left      = $ImportFromADWinRMAutoCheckBox.Left + $ImportFromADWinRMAutoCheckBox.Width + $($FormScale * 5)
            top       = $ImportFromADWinRMManuallEntryTextBox.Top
            Width     = $FormScale * 100
            Height    = $FormScale * 20
            Add_Click = {
                Create-ComputerNodeCheckBoxArray
                if ($ImportFromADWinRMManuallEntryTextBox.Text -ne '<Enter a hostname/IP>' -and $ImportFromADWinRMManuallEntryTextBox.Text -ne '' -and $ImportFromADWinRMAutoCheckBox.checked -eq $false ) {
                    if (Verify-Action -Title "Verification: Active Directory Import" -Question "Import Active Directory account information from the following?" -Computer $ImportFromADWinRMManuallEntryTextBox.text) {
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
                            Invoke-Command -ScriptBlock {
                                Get-ADUser -Filter * -Properties * `
                                | Select-Object Name, SID, Enabled, LockedOut, Created, Modified, LastLogonDate, LastBadPasswordAttempt, BadLogonCount, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CanonicalName, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive
                            } -ComputerName $ImportFromADWinRMManuallEntryTextBoxTarget -Credential $script:Credential `
                            | Export-Csv "$PoShHome\Account Data.csv" -NoTypeInformation
                            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { Get-ADUser -Filter * -Properties * | Select-Object Name, SID, Enabled, LockedOut, Created, Modified, LastLogonDate, LastBadPasswordAttempt, BadLogonCount, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CanonicalName, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive } -ComputerName $($ImportFromADWinRMManuallEntryTextBox.Text) -Credential [ $UserName | $Password ]"
                        }
                        else {
                            Invoke-Command -ScriptBlock {
                                Get-ADUser -Filter * -Properties * `
                                | Select-Object Name, SID, Enabled, LockedOut, Created, Modified, LastLogonDate, LastBadPasswordAttempt, BadLogonCount, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CanonicalName, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive
                            } -ComputerName $ImportFromADWinRMManuallEntryTextBoxTarget `
                            | Export-Csv "$PoShHome\Account Data.csv" -NoTypeInformation
                            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message  "Invoke-Command -ScriptBlock { Get-ADUser -Filter * -Properties * | Select-Object Name, SID, Enabled, LockedOut, Created, Modified, LastLogonDate, LastBadPasswordAttempt, BadLogonCount, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CanonicalName, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive } -ComputerName $($ImportFromADWinRMManuallEntryTextBox.Text)"
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

                            Invoke-Command -ScriptBlock {
                                Get-ADUser -Filter * -Properties * `
                                | Select-Object Name, SID, Enabled, LockedOut, Created, Modified, LastLogonDate, LastBadPasswordAttempt, BadLogonCount, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CanonicalName, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive
                            } -ComputerName $script:ComputerTreeViewSelected -Credential $script:Credential `
                            | Export-Csv "$PoShHome\Account Data.csv" -NoTypeInformation

                            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { Get-ADUser -Filter * -Properties * | Select-Object Name, SID, Enabled, LockedOut, Created, Modified, LastLogonDate, LastBadPasswordAttempt, BadLogonCount, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CanonicalName, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive } -ComputerName $script:ComputerTreeViewSelected -Credential [ $UserName | $Password ]"
                        }
                        else {
                            Invoke-Command -ScriptBlock {
                                Get-ADUser -Filter * -Properties * `
                                | Select-Object Name, SID, Enabled, LockedOut, Created, Modified, LastLogonDate, LastBadPasswordAttempt, BadLogonCount, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CanonicalName, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive
                            } -ComputerName $script:ComputerTreeViewSelected `
                            | Export-Csv "$PoShHome\Account Data.csv" -NoTypeInformation
                            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { Get-ADUser -Filter * -Properties * | Select-Object Name, SID, Enabled, LockedOut, Created, Modified, LastLogonDate, LastBadPasswordAttempt, BadLogonCount, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CanonicalName, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive } -ComputerName $script:ComputerTreeViewSelected"
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

                Import-AccountsFromDomain

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
                if ($ComputerListProvideCredentialsCheckBox.Checked) {
                    if (!$script:Credential) { Create-NewCredentials }
                    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Credentials Used: $($script:Credential.UserName)"
                    $Username = $script:Credential.UserName
                    $Password = '"PASSWORD HIDDEN"'
                    Invoke-Command -ScriptBlock {
                        Get-ADUser -Filter * -Properties * `
                        | Select-Object Name, SID, Enabled, LockedOut, Created, Modified, LastLogonDate, LastBadPasswordAttempt, BadLogonCount, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CanonicalName, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive
                    } -Credential $script:Credential `
                    | Export-Csv "$PoShHome\Account Data.csv" -NoTypeInformation
                    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { Get-ADUser -Filter * -Properties * | Select-Object Name, SID, Enabled, LockedOut, Created, Modified, LastLogonDate, LastBadPasswordAttempt, BadLogonCount, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CanonicalName, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive } -Credential [ $UserName | $Password ]"
                }
                else {
                    Invoke-Command -ScriptBlock {
                        Get-ADUser -Filter * -Properties * `
                        | Select-Object Name, SID, Enabled, LockedOut, Created, Modified, LastLogonDate, LastBadPasswordAttempt, BadLogonCount, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CanonicalName, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive
                    } `
                    | Export-Csv "$PoShHome\Account Data.csv" -NoTypeInformation
                    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message  "Invoke-Command -ScriptBlock { Get-ADUser -Filter * -Properties * | Select-Object Name, SID, Enabled, LockedOut, Created, Modified, LastLogonDate, LastBadPasswordAttempt, BadLogonCount, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CanonicalName, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive }"
                }
                Import-AccountsFromDomain

                $ImportFromADFrom.Close()
            }
        }
        $ImportFromADLocalhostGroupBox.Controls.Add($ImportFromADLocalhostImportButton)
        CommonButtonSettings -Button $ImportFromADLocalhostImportButton
    $ImportFromADFrom.Controls.Add($ImportFromADLocalhostGroupBox)

    # Garbage Collection to free up memory
    [System.GC]::Collect()

    $ImportFromADFrom.ShowDialog()
}










$ImportEndpointDataFromActiveDirectoryButtonAdd_MouseHover = {
    Show-ToolTip -Title "Import From Active Directory" -Icon "Info" -Message @"
+  Opens a form that provides you options on how to import account information from Acitve Directory
"@
}




