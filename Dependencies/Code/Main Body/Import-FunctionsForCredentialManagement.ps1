Update-FormProgress "Set-NewRollingPassword"
function Set-NewRollingPassword {
    <#
        .Description
        Rolls the credenaisl: 250 characters of random: abcdefghiklmnoprstuvwxyzABCDEFGHKLMNOPRSTUVWXYZ1234567890
    #>
    function Get-RandomCharacters($length, $characters) {
        $random = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length }
        $private:ofs=""
        return [String]$characters[$random]
    }

    # Active Directory has a max password length of 256 characters
    # note: Previous versions had the random password set at 250 characters, but this was scalled back because during testing cmdkey doesn't seem to support anything larger
    $NumberOfCharacters = 32 #100 #150 #200 #250

    #abcdefghiklmnoprstuvwxyzABCDEFGHKLMNOPRSTUVWXYZ1234567890`~!@#$%^&*()_+-=[]\{}|;:'",./<>?
    $GeneratedPassword  = Get-RandomCharacters -length $NumberOfCharacters -characters @"
abcdefghiklmnoprstuvwxyzABCDEFGHKLMNOPRSTUVWXYZ1234567890
"@

    $script:CredentialManagementGeneratedRollingPasswordTextBox.text = $GeneratedPassword
    $SecurePassword = ConvertTo-SecureString $GeneratedPassword -AsPlainText -Force

    if ($script:CredentialManagementPasswordRollingAccountTextBox.text) {
        $script:PoShEasyWinAccount = $script:CredentialManagementPasswordRollingAccountTextBox.text
    }
    if ($script:CredentialManagementPasswordDomainNameTextBox.text) {
        $script:PoShEasyWinDomainName = $script:CredentialManagementPasswordDomainNameTextBox.text
        if ($script:PoShEasyWinDomainName -ne '') {
            $script:PoShEasyWinDomainNameAndAccount = "$($script:PoShEasyWinAccount)@$($script:PoShEasyWinDomainName)"
        }
        else {
            $script:PoShEasyWinDomainNameAndAccount = "$script:PoShEasyWinAccount"
        }
    }
    if ($script:CredentialManagementPasswordDomainNameTextBox.text) {
        $script:ActiveDirectoryServer = $script:CredentialManagementActiveDirectoryTextBox.text
    }

    $script:credential = $null
    $script:Credential = New-Object System.Management.Automation.PSCredential($script:PoShEasyWinDomainNameAndAccount,$SecurePassword)

    # Rolls the PoSh-EasyWin Account Credential

    $CredentialRoller = Get-Content "$script:CredentialManagementPath\Administrator Account That Updates The Rolling Credentials.txt"
    $script:AdminCredsToRollPassword = Import-CliXml "$script:CredentialManagementPath\$CredentialRoller"
    Invoke-Command -ComputerName $script:ActiveDirectoryServer -Credential $script:AdminCredsToRollPassword -ScriptBlock {
        param(
            $PoShEasyWinAccount,
            $SecurePassword
        )
        Set-ADAccountPassword -Identity $PoShEasyWinAccount -Reset -NewPassword $SecurePassword
    } -ArgumentList @($script:PoShEasyWinAccount,$SecurePassword)

    $ResultsListBox.Items.Insert(1,"$(($CollectionTimerStop).ToString('yyyy/MM/dd HH:mm:ss'))  Rolled Password For Account: $($script:PoShEasyWinAccount)")
    $PoShEasyWin.Refresh()
    Write-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Generated Secure Password ($NumberOfCharacters Random Characters) and Rolled Credentials"
    Write-LogEntry -LogFile $LogFile -NoTargetComputer -Message " - Invoke-Command -ComputerName $script:ActiveDirectoryServer -ScriptBlock { param($script:PoShEasyWinDomainNameAndAccount,$SecurePassword) Set-ADAccountPassword -Identity $script:PoShEasyWinDomainNameAndAccount -Reset -NewPassword $SecurePassword } -ArgumentList @($script:PoShEasyWinDomainNameAndAccount,$SecurePassword)"



    # Encrypt an exported credential object
    # The Export-Clixml cmdlet encrypts credential objects by using the Windows Data Protection API.
    # The encryption ensures that only your user account on only that computer can decrypt the contents of the
    # credential object. The exported CLIXML file can't be used on a different computer or by a different user.
    if ($script:PoShEasyWinDomainName -ne '') {
        $script:PoShEasyWinDomainNameAndAccount = "$($script:PoShEasyWinAccount)@$($script:PoShEasyWinDomainName)"
    }
    else {
        $script:PoShEasyWinDomainNameAndAccount = $script:PoShEasyWinAccount
    }

    $DateTime = "{0:yyyy-MM-dd @ HHmm.ss}" -f (Get-Date)
    Move-Item -Path "$script:CredentialManagementPath\$script:PoShEasyWinDomainNameAndAccount (*).xml" -Destination "$script:CredentialManagementPath\Rolled Credentials"
    $CredentialName = "$script:PoShEasyWinDomainNameAndAccount ($DateTime).xml"

    $script:Credential | Export-Clixml -path "$script:CredentialManagementPath\$CredentialName"

    $CredentialManagementSelectCredentialsTextBox.text = $CredentialName
    $CredentialName | Out-File "$script:CredentialManagementPath\Specified Credentials.txt"

    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Credentials:  $CredentialName")
    $script:CredentialManagementPasswordRollingAccountCheckbox.checked = $true
}




Update-FormProgress "Set-NewCredential"
function Set-NewCredential {
    <#
        .Description
        Used to create new credentials (Get-Credential), create a log entry, and save an encypted local copy
        Encrypt an exported credential object
        The Export-Clixml cmdlet encrypts credential objects by using the Windows Data Protection API.
        The encryption ensures that only your user account on only that computer can decrypt the contents of the
        credential object. The exported CLIXML file can't be used on a different computer or by a different user.
    #>
    $script:Credential = Get-Credential
    if (!$script:Credential){exit}
    Write-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Created New Credentials and stored them locally as an XML using Windows Data Protection API."

    $NewCredentialsUsername = ($script:Credential.UserName).replace('\','-')
    $DateTime = "{0:yyyy-MM-dd @ HHmm.ss}" -f (Get-Date)
    $CredentialName = "$NewCredentialsUsername ($DateTime).xml"
    $script:Credential | Export-Clixml -path "$script:CredentialManagementPath\$CredentialName"

    $CredentialManagementSelectCredentialsTextBox.text = $CredentialName
    $CredentialName | Out-File "$PewSettings\Use Selected Credentials.txt"

    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Credentials:  $CredentialName")
}




Update-FormProgress "Show-CredentialManagementForm"
function Show-CredentialManagementForm {
    <#
        .Description
        Code to launch the Credential Management Form
        Provides the abiltiy to select create, select, and save credentials
        Provides the option to enable password auto rolling
    #>
    $CredentialManagementForm = New-Object system.Windows.Forms.Form -Property @{
        Text          = "Credential Management"
        StartPosition = "CenterScreen"
        Size          = @{ Width  = $FormScale * 510
                        Height = $FormScale * 588 }
        Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor     = 'Black'
        Add_Closing = { $This.dispose() }
    }

    if (-not (Test-Path -Path $script:CredentialManagementPath) ) { New-Item -Path $script:CredentialManagementPath -Type Directory }
    if (-not (Test-Path -Path "$script:CredentialManagementPath\Rolled Credentials") ) { New-Item -Path "$script:CredentialManagementPath\Rolled Credentials" -Type Directory }

    function Check-RollingAccountPrerequisites {
        $PrerequisitesCheckDomainController = $false
        if ((Test-Path "$script:CredentialManagementPath\Specified Domain Controller.txt")) {
            if ( $script:CredentialManagementActiveDirectoryTextBox.text -ne (Get-Content "$script:CredentialManagementPath\Specified Domain Controller.txt")) {
                if ($script:CredentialManagementActiveDirectoryTextBox.text -eq ''){
                    $script:CredentialManagementActiveDirectoryButton.Forecolor = 'Red'
                    $script:CredentialManagementActiveDirectoryButton.Text      = "Provide Server Name"
                    $PrerequisitesCheckDomainController = $false
                }
                else {
                    $script:CredentialManagementActiveDirectoryButton.Forecolor = 'Red'
                    $script:CredentialManagementActiveDirectoryButton.Text      = "Click to Save"
                    $PrerequisitesCheckDomainController = $false
                }
            }
            else {
                $script:CredentialManagementActiveDirectoryButton.Forecolor = 'Green'
                $script:CredentialManagementActiveDirectoryButton.Text      = "Server Name Saved"
                $PrerequisitesCheckDomainController = $true
            }
            if ( (Get-Content "$script:CredentialManagementPath\Specified Domain Controller.txt").length -eq 0 ) { $PrerequisitesCheckDomainController = $false }
            else { $PrerequisitesCheckDomainController = $true }
        }
        else {
            if ($script:CredentialManagementActiveDirectoryTextBox.text -eq ''){
                $script:CredentialManagementActiveDirectoryButton.Forecolor = 'Red'
                $script:CredentialManagementActiveDirectoryButton.Text      = "Provide Server Name"
                $PrerequisitesCheckDomainController = $false
            }
            else {
                $script:CredentialManagementActiveDirectoryButton.Forecolor = 'Red'
                $script:CredentialManagementActiveDirectoryButton.Text      = "Click to Save"
                $PrerequisitesCheckDomainController = $false
            }
        }


        $PrerequisitesCheckRollingAccount = $false
        if ((Test-Path "$script:CredentialManagementPath\Specified Rolling Account.txt")) {
            if ( $script:CredentialManagementPasswordRollingAccountTextBox.text -ne (Get-Content "$script:CredentialManagementPath\Specified Rolling Account.txt")) {
                if ($script:CredentialManagementPasswordRollingAccountTextBox.text -eq ''){
                    $script:CredentialManagementPasswordRollingAccountButton.Forecolor = 'Red'
                    $script:CredentialManagementPasswordRollingAccountButton.Text      = "Provide Account Name"
                    $PrerequisitesCheckRollingAccount = $false
                }
                else {
                    $script:CredentialManagementPasswordRollingAccountButton.Forecolor = 'Red'
                    $script:CredentialManagementPasswordRollingAccountButton.Text      = "Click to Save"
                    $PrerequisitesCheckRollingAccount = $false
                }
            }
            else {
                $script:CredentialManagementPasswordRollingAccountButton.Forecolor = 'Green'
                $script:CredentialManagementPasswordRollingAccountButton.Text      = "Account Name Saved"
                $PrerequisitesCheckRollingAccount = $true
            }
            if ((Get-Content "$script:CredentialManagementPath\Specified Rolling Account.txt").length -eq 0){ $PrerequisitesCheckRollingAccount = $false }
            else { $PrerequisitesCheckRollingAccount = $true }
        }
        else {
            if ($script:CredentialManagementPasswordRollingAccountTextBox.text -eq ''){
                $script:CredentialManagementPasswordRollingAccountButton.Forecolor = 'Red'
                $script:CredentialManagementPasswordRollingAccountButton.Text      = "Provide Account Name"
                $PrerequisitesCheckRollingAccount = $false
            }
            else {
                $script:CredentialManagementPasswordRollingAccountButton.Forecolor = 'Red'
                $script:CredentialManagementPasswordRollingAccountButton.Text      = "Click to Save"
                $PrerequisitesCheckRollingAccount = $false
            }
        }


        $PrerequisitesCheckDomainName = $false
        if ((Test-Path "$script:CredentialManagementPath\Specified Domain Name.txt")) {
            if ( $script:CredentialManagementPasswordDomainNameTextBox.text -ne (Get-Content "$script:CredentialManagementPath\Specified Domain Name.txt")) {
                if ($script:CredentialManagementPasswordDomainNameTextBox.text -eq ''){
                    $script:CredentialManagementPasswordDomainNameButton.Forecolor = 'Red'
                    $script:CredentialManagementPasswordDomainNameButton.Text      = "Provide Domain Name"
                    $PrerequisitesCheckDomainName = $false
                }
                else {
                    $script:CredentialManagementPasswordDomainNameButton.Forecolor = 'Red'
                    $script:CredentialManagementPasswordDomainNameButton.Text      = "Click to Save"
                    $PrerequisitesCheckDomainName = $false
                }
            }
            else {
                $script:CredentialManagementPasswordDomainNameButton.Forecolor = 'Green'
                $script:CredentialManagementPasswordDomainNameButton.Text      = "Domain Name Saved"
                $PrerequisitesCheckDomainName = $true
            }
            if ( (Get-Content "$script:CredentialManagementPath\Specified Domain Name.txt").length -eq 0 ) { $PrerequisitesCheckDomainName = $false }
            else { $PrerequisitesCheckDomainName = $true }
        }
        else {
            if ($script:CredentialManagementPasswordDomainNameTextBox.text -eq ''){
                $script:CredentialManagementPasswordDomainNameButton.Forecolor = 'Red'
                $script:CredentialManagementPasswordDomainNameButton.Text      = "Provide Domain Name"
                $PrerequisitesCheckDomainName = $false
            }
            else {
                $script:CredentialManagementPasswordDomainNameButton.Forecolor = 'Red'
                $script:CredentialManagementPasswordDomainNameButton.Text      = "Click to Save"
                $PrerequisitesCheckDomainName = $false
            }
        }


        $PrerequisitesCheckSelectCredentialRollingAccount = $false
        if ((Test-Path "$script:CredentialManagementPath\Administrator Account That Updates The Rolling Credentials.txt")) {
            if ( $CredentialManagementSelectCredentialRollingAccountTextBox.text -ne (Get-Content "$script:CredentialManagementPath\Administrator Account That Updates The Rolling Credentials.txt")) {
                if ($CredentialManagementSelectCredentialRollingAccountTextBox.text -eq ''){
                    $CredentialManagementSelectCredentialRollingAccountButton.Forecolor = 'Red'
                    $CredentialManagementSelectCredentialRollingAccountButton.Text      = "Select Credentials"
                    $PrerequisitesCheckSelectCredentialRollingAccount = $false
                }
                else {
                    $CredentialManagementSelectCredentialRollingAccountButton.Forecolor = 'Red'
                    $CredentialManagementSelectCredentialRollingAccountButton.Text      = "Click to Save"
                    $PrerequisitesCheckSelectCredentialRollingAccount = $false
                }
            }
            else {
                $CredentialManagementSelectCredentialRollingAccountButton.Forecolor = 'Green'
                $CredentialManagementSelectCredentialRollingAccountButton.Text      = "Credentials Selected"
                $PrerequisitesCheckSelectCredentialRollingAccount = $true
            }
            if ( (Get-Content "$script:CredentialManagementPath\Administrator Account That Updates The Rolling Credentials.txt").length -eq 0 ) { $PrerequisitesCheckSelectCredentialRollingAccount = $false }
            else { $PrerequisitesCheckSelectCredentialRollingAccount = $true }
        }
        else {
            if ($CredentialManagementSelectCredentialRollingAccountTextBox.text -eq ''){
                $CredentialManagementSelectCredentialRollingAccountButton.Forecolor = 'Red'
                $CredentialManagementSelectCredentialRollingAccountButton.Text      = "Select Credentials"
                $PrerequisitesCheckSelectCredentialRollingAccount = $false
            }
            else {
                $CredentialManagementSelectCredentialRollingAccountButton.Forecolor = 'Red'
                $CredentialManagementSelectCredentialRollingAccountButton.Text      = "Click to Save"
                $PrerequisitesCheckSelectCredentialRollingAccount = $false
            }
        }
    }


    $CredentialManagementAvailableCredentialsGroupBox  = New-Object System.Windows.Forms.Groupbox -Property @{
        Text     = "Specify Credentials:"
        Location = @{ X = $FormScale * 10
                    Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 475
                    Height = $FormScale * 178 }
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
        ForeColor = 'Blue'
    }

        $CredentialManagementSelectCredentialsLabel = New-Object System.Windows.Forms.Label -Property @{
            Text     = "Select the credentials that PoSh-EasyWin will use while executing queries and for remote access. If no store XML credentials are selected, the credentials used will default to those that launched PoSh-EasyWin."
            Location = @{ X = $FormScale * 5
                        Y = $FormScale * 20 }
            Size     = @{ Width  = $FormScale * 465
                        Height = $FormScale * 44 }
            Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = 'Black'
        }
        $CredentialManagementAvailableCredentialsGroupBox.Controls.Add($CredentialManagementSelectCredentialsLabel)


        $CredentialManagementSelectCredentialsTextBox = New-Object System.Windows.Forms.Textbox -Property @{
            Location = @{ X = $CredentialManagementSelectCredentialsLabel.Location.X
                        Y = $CredentialManagementSelectCredentialsLabel.Location.Y + $CredentialManagementSelectCredentialsLabel.Size.Height }
            Size     = @{ Width  = $FormScale * 300
                        Height = $FormScale * 25 }
            Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = 'Black'
            BackColor = 'White'
            Enabled   = $false
        }
        $CredentialManagementAvailableCredentialsGroupBox.Controls.Add($CredentialManagementSelectCredentialsTextBox)


        $CredentialManagementSelectCredentialsButton = New-Object System.Windows.Forms.Button -Property @{
            Text     = "Select Credentials"
            Location = @{ X = $CredentialManagementSelectCredentialsTextBox.Location.X + $CredentialManagementSelectCredentialsTextBox.Size.Width + $($FormScale * 10)
                        Y = $CredentialManagementSelectCredentialsTextBox.Location.Y - $($FormScale * 1) }
            Size     = @{ Width  = $FormScale * 150
                        Height = $FormScale * 20 }
        }
        CommonButtonSettings -Button $CredentialManagementSelectCredentialsButton
        $CredentialManagementSelectCredentialsButton.Add_Click({
            try {
                [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
                $CredentialManagementSelectCredentialsOpenFileDialog                  = New-Object System.Windows.Forms.OpenFileDialog
                $CredentialManagementSelectCredentialsOpenFileDialog.Title            = "Select Credentials"
                $CredentialManagementSelectCredentialsOpenFileDialog.InitialDirectory = $script:CredentialManagementPath
                $CredentialManagementSelectCredentialsOpenFileDialog.filter           = "XML (*.xml)|*.xml|All files (*.*)|*.*"
                $CredentialManagementSelectCredentialsOpenFileDialog.ShowHelp         = $true
                $CredentialManagementSelectCredentialsOpenFileDialog.ShowDialog() | Out-Null
                $script:Credential = Import-CliXml -Path $($CredentialManagementSelectCredentialsOpenFileDialog.filename)
                $CredentialName = $null
                $CredentialName = $($CredentialManagementSelectCredentialsOpenFileDialog.filename).split('\')[-1]
                $CredentialManagementSelectCredentialsTextBox.text = $CredentialName
                $CredentialName | Out-File "$script:CredentialManagementPath\Specified Credentials.txt"
                $StatusListBox.Items.Clear()
                $StatusListBox.Items.Add("Credentials:  $CredentialName")
            }
            catch{}
            if ($script:CredentialManagementPasswordRollingAccountCheckbox.checked) {
                [System.Windows.MessageBox]::Show('Manually selecting credentials disables auto password rolling.')
                $script:CredentialManagementPasswordRollingAccountCheckbox.checked = $false
                $script:RollCredentialsState = $false
            }
            $ComputerListProvideCredentialsCheckBox.checked = $true
        })
        $CredentialManagementAvailableCredentialsGroupBox.Controls.Add($CredentialManagementSelectCredentialsButton)


        $CredentialManagementCreateCredentialsLabel = New-Object System.Windows.Forms.Label -Property @{
            Text     = "You can create and store credentials locally of existing accounts and easily switch between them as necessary. These credentials are stored in XML format and encrypted using Windows Data Protection API, which restricts decryption of the password to the user account and computer that created them."
            Location = @{ X = $CredentialManagementSelectCredentialsTextBox.Location.X
                        Y = $CredentialManagementSelectCredentialsTextBox.Location.Y + $CredentialManagementSelectCredentialsTextBox.Size.Height + $($FormScale * 10) }
            Size     = @{ Width  = $FormScale * 465
                        Height = $FormScale * 52 }
            Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = 'Black'
        }
        $CredentialManagementAvailableCredentialsGroupBox.Controls.Add($CredentialManagementCreateCredentialsLabel)


        $CredentialManagementCreateNewCredentialsButton = New-Object System.Windows.Forms.Button -Property @{
            Text     = "Create New Credentials"
            Location = @{ X = $CredentialManagementSelectCredentialsButton.Location.X
                        Y = $CredentialManagementCreateCredentialsLabel.Location.Y + $CredentialManagementCreateCredentialsLabel.Size.Height }
            Size     = @{ Width  = $FormScale * 150
                        Height = $FormScale * 20 }
        }
        CommonButtonSettings -Button $CredentialManagementCreateNewCredentialsButton
        $CredentialManagementCreateNewCredentialsButton.Add_Click({
            Set-NewCredential

            Start-Sleep -Seconds 2
            $ComputerListProvideCredentialsCheckBox.checked = $true
            $CredentialManagementForm.close()
        })
        $CredentialManagementAvailableCredentialsGroupBox.Controls.Add($CredentialManagementCreateNewCredentialsButton)


        $CredentialManagementDecryptCredentialButton = New-Object System.Windows.Forms.Button -Property @{
            Text     = "Decrypt Credentials"
            Location = @{ X = $CredentialManagementCreateNewCredentialsButton.Location.X - $CredentialManagementCreateNewCredentialsButton.Size.Width - $($FormScale * 10)
                        Y = $CredentialManagementCreateNewCredentialsButton.Location.Y }
            Size     = @{ Width  = $FormScale * 150
                        Height = $FormScale * 20 }
        }
        CommonButtonSettings -Button $CredentialManagementDecryptCredentialButton
        $CredentialManagementDecryptCredentialButton.Add_Click({
            [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
            $CredentialManagementDecryptCredentialOpenFileDialog                  = New-Object System.Windows.Forms.OpenFileDialog
            $CredentialManagementDecryptCredentialOpenFileDialog.Title            = "Decode Credentials"
            $CredentialManagementDecryptCredentialOpenFileDialog.InitialDirectory = $script:CredentialManagementPath
            $CredentialManagementDecryptCredentialOpenFileDialog.Filter           = "XML (*.xml)|*.xml|All files (*.*)|*.*"
            $CredentialManagementDecryptCredentialOpenFileDialog.ShowHelp         = $true
            $CredentialManagementDecryptCredentialOpenFileDialog.ShowDialog() | Out-Null
            $CredentialToDecode = Import-CliXml -Path $($CredentialManagementDecryptCredentialOpenFileDialog.filename)

            $DecodedUsername = $CredentialToDecode.UserName
            $DecodedPassword = $CredentialToDecode.GetNetworkCredential().Password
            [System.Windows.MessageBox]::Show("Username: $DecodedUsername`nPassword: $DecodedPassword")
        })
        $CredentialManagementAvailableCredentialsGroupBox.Controls.Add($CredentialManagementDecryptCredentialButton)

    $CredentialManagementForm.Controls.Add($CredentialManagementAvailableCredentialsGroupBox)


    $CredentialManagementPasswordRollingAccountGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
        Text     = "Automatic Password Rolling:"
        Location = @{ X = $CredentialManagementAvailableCredentialsGroupBox.Location.X
                    Y = $CredentialManagementAvailableCredentialsGroupBox.Location.Y + $CredentialManagementAvailableCredentialsGroupBox.Size.Height + $($FormScale * 10) }
        Size     = @{ Width  = $CredentialManagementAvailableCredentialsGroupBox.Size.Width
                    Height = $FormScale * 342 }
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
        ForeColor = 'Blue'
    }
        $script:CredentialManagementPasswordRollingAccountCheckbox = New-Object System.Windows.Forms.Checkbox -Property @{
            Text     = "Enable rolling of credentials after queries and remote connections"
            Location = @{ X = $FormScale * 5
                        Y = $FormScale * 18 }
            Size     = @{ Width  = $FormScale * 465
                        Height = $FormScale * 25 }
            Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = 'Black'
            Checked  = $script:RollCredentialsState
        }
        $script:CredentialManagementPasswordRollingAccountCheckbox.Add_Click({
            if ($script:CredentialManagementActiveDirectoryTextBox.text -eq '' `
                -or $script:CredentialManagementPasswordRollingAccountTextBox.text -eq '' `
                -or $script:CredentialManagementPasswordDomainNameTextBox.text -eq '' `
                -or $CredentialManagementSelectCredentialRollingAccountTextBox.text -eq '') {
                [System.Windows.MessageBox]::Show('You must first specify a domain controller, user account, domain name, and the credentials used to roll the credentials.')
                $script:CredentialManagementPasswordRollingAccountCheckbox.checked = $false
            }
            else {
                if ($script:CredentialManagementPasswordRollingAccountCheckbox.checked) {
                    #[System.Windows.MessageBox]::Show('Checkboxing this also forces an initial credential roll.')
                    Set-NewRollingPassword
                    $script:RollCredentialsState = $true

                    $ComputerListProvideCredentialsCheckBox.checked = $true
                    $CredentialManagementGenerateNewPasswordButton.enabled = $true
                }
                else { $script:RollCredentialsState = $false }
            }
        })
        $CredentialManagementPasswordRollingAccountGroupBox.Controls.Add($script:CredentialManagementPasswordRollingAccountCheckbox)


        $CredentialManagementPasswordRollingAccountLabel = New-Object System.Windows.Forms.Label -Property @{
            Text     = "Enter the account name that will be used for password rolling after queries and remote connections are executed. This does not create the account, it just changes the account's password. You must coordinate with the administrator to create an account like: `"JohnDoe`""
            Location = @{ X = $FormScale * 5
                        Y = $script:CredentialManagementPasswordRollingAccountCheckbox.Location.Y + $script:CredentialManagementPasswordRollingAccountCheckbox.Size.Height + $($FormScale * 5) }
            Size     = @{ Width  = $FormScale * 465
                        Height = $FormScale * 45 }
            Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = 'Black'
        }
        $CredentialManagementPasswordRollingAccountGroupBox.Controls.Add($CredentialManagementPasswordRollingAccountLabel)


        $script:CredentialManagementPasswordRollingAccountTextBox = New-Object System.Windows.Forms.TextBox -Property @{
            Location = @{ X = $CredentialManagementPasswordRollingAccountLabel.Location.X
                        Y = $CredentialManagementPasswordRollingAccountLabel.Location.Y + $CredentialManagementPasswordRollingAccountLabel.Size.Height }
            Size     = @{ Width  = $FormScale * 300
                        Height = $FormScale * 25 }
            Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = 'Black'
        }
        $script:CredentialManagementPasswordRollingAccountTextBox.Add_MouseEnter({ Check-RollingAccountPrerequisites })
        $script:CredentialManagementPasswordRollingAccountTextBox.Add_MouseLeave({ Check-RollingAccountPrerequisites })
        $script:CredentialManagementPasswordRollingAccountTextBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") {
            if ($script:CredentialManagementPasswordRollingAccountTextBox.text -ne ''){
                $script:CredentialManagementPasswordRollingAccountTextBox.text | Out-File "$script:CredentialManagementPath\Specified Rolling Account.txt"
            }
            else {Remove-Item "$script:CredentialManagementPath\Specified Rolling Account.txt"}
            Check-RollingAccountPrerequisites
        } })
        $CredentialManagementPasswordRollingAccountGroupBox.Controls.Add($script:CredentialManagementPasswordRollingAccountTextBox)


        $script:CredentialManagementPasswordRollingAccountButton = New-Object System.Windows.Forms.Button -Property @{
            Location = @{ X = $script:CredentialManagementPasswordRollingAccountTextBox.Location.X + $script:CredentialManagementPasswordRollingAccountTextBox.Size.Width + $($FormScale * 10)
                        Y = $script:CredentialManagementPasswordRollingAccountTextBox.Location.Y }
            Size     = @{ Width  = $FormScale * 150
                        Height = $FormScale * 20 }
        }
        CommonButtonSettings -Button $script:CredentialManagementPasswordRollingAccountButton
        $script:CredentialManagementPasswordRollingAccountButton.Add_Click({
            if ($script:CredentialManagementPasswordRollingAccountTextBox.text -ne ''){
                $script:CredentialManagementPasswordRollingAccountTextBox.text | Out-File "$script:CredentialManagementPath\Specified Rolling Account.txt"
            }
            else {Remove-Item "$script:CredentialManagementPath\Specified Rolling Account.txt"}
            Check-RollingAccountPrerequisites
        })
        $CredentialManagementPasswordRollingAccountGroupBox.Controls.Add($script:CredentialManagementPasswordRollingAccountButton)

        if ((Test-Path "$script:CredentialManagementPath\Specified Rolling Account.txt")) {
            $script:CredentialManagementPasswordRollingAccountTextBox.text = Get-Content "$script:CredentialManagementPath\Specified Rolling Account.txt"
        }
        else {$script:CredentialManagementPasswordRollingAccountTextBox.text = ''}


        $CredentialManagementActiveDirectoryLabel = New-Object System.Windows.Forms.Label -Property @{
            Text     = "Enter the domain controller hostname that is used for credential management."
            Location = @{ X = $FormScale * 5
                        Y = $script:CredentialManagementPasswordRollingAccountTextBox.Location.Y + $script:CredentialManagementPasswordRollingAccountTextBox.Size.Height + $($FormScale * 10) }
            Size     = @{ Width  = $FormScale * 465
                        Height = $FormScale * 20 }
            Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = 'Black'
        }
        $CredentialManagementPasswordRollingAccountGroupBox.Controls.Add($CredentialManagementActiveDirectoryLabel)


        $script:CredentialManagementActiveDirectoryTextBox = New-Object System.Windows.Forms.TextBox -Property @{
            Location = @{ X = $CredentialManagementActiveDirectoryLabel.Location.X
                        Y = $CredentialManagementActiveDirectoryLabel.Location.Y  + $CredentialManagementActiveDirectoryLabel.Size.Height }
            Size     = @{ Width  = $FormScale * 300
                        Height = $FormScale * 25 }
            Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = 'Black'
        }
        $script:CredentialManagementActiveDirectoryTextBox.Add_MouseEnter({ Check-RollingAccountPrerequisites })
        $script:CredentialManagementActiveDirectoryTextBox.Add_MouseLeave({ Check-RollingAccountPrerequisites })
        $script:CredentialManagementActiveDirectoryTextBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") {
            if ($script:CredentialManagementActiveDirectoryTextBox.text -ne ''){
                $script:CredentialManagementActiveDirectoryTextBox.text | Out-File "$script:CredentialManagementPath\Specified Domain Controller.txt"
            }
            else {Remove-Item "$script:CredentialManagementPath\Specified Domain Controller.txt"}
            Check-RollingAccountPrerequisites
        } })
        $CredentialManagementPasswordRollingAccountGroupBox.Controls.Add($script:CredentialManagementActiveDirectoryTextBox)


        $script:CredentialManagementActiveDirectoryButton = New-Object System.Windows.Forms.Button -Property @{
            Location = @{ X = $CredentialManagementActiveDirectoryTextBox.Location.X + $CredentialManagementActiveDirectoryTextBox.Size.Width + $($FormScale * 10)
                        Y = $CredentialManagementActiveDirectoryTextBox.Location.Y}
            Size     = @{ Width  = $FormScale * 150
                        Height = $FormScale * 20 }
        }
        CommonButtonSettings -Button $script:CredentialManagementActiveDirectoryButton
        $script:CredentialManagementActiveDirectoryButton.Add_Click({
            if ($script:CredentialManagementActiveDirectoryTextBox.text -ne ''){
                $script:CredentialManagementActiveDirectoryTextBox.text | Out-File "$script:CredentialManagementPath\Specified Domain Controller.txt"
            }
            else {Remove-Item "$script:CredentialManagementPath\Specified Domain Controller.txt"}
            Check-RollingAccountPrerequisites
        })
        $CredentialManagementPasswordRollingAccountGroupBox.Controls.Add($script:CredentialManagementActiveDirectoryButton)

        if ((Test-Path "$script:CredentialManagementPath\Specified Domain Controller.txt")) {
            $script:CredentialManagementActiveDirectoryTextBox.text = Get-Content "$script:CredentialManagementPath\Specified Domain Controller.txt"
        }
        else {$script:CredentialManagementActiveDirectoryTextBox.text = ''}
        Check-RollingAccountPrerequisites


        $CredentialManagementPasswordDomainNameLabel = New-Object System.Windows.Forms.Label -Property @{
            Text     = "Enter the domain name for the credential rolling account."
            Location = @{ X = $FormScale * 5
                        Y = $script:CredentialManagementActiveDirectoryButton.Location.Y + $script:CredentialManagementActiveDirectoryButton.Size.Height + $($FormScale * 10) }
            Size     = @{ Width  = $FormScale * 465
                        Height = $FormScale * 22 }
            Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = 'Black'
        }
        $CredentialManagementPasswordRollingAccountGroupBox.Controls.Add($CredentialManagementPasswordDomainNameLabel)


        $script:CredentialManagementPasswordDomainNameTextBox = New-Object System.Windows.Forms.TextBox -Property @{
            Location = @{ X = $CredentialManagementPasswordDomainNameLabel.Location.X
                        Y = $CredentialManagementPasswordDomainNameLabel.Location.Y + $CredentialManagementPasswordDomainNameLabel.Size.Height }
            Size     = @{ Width  = $FormScale * 300
                        Height = $FormScale * 25 }
            Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = 'Black'
        }
        $script:CredentialManagementPasswordDomainNameTextBox.Add_MouseEnter({ Check-RollingAccountPrerequisites })
        $script:CredentialManagementPasswordDomainNameTextBox.Add_MouseLeave({ Check-RollingAccountPrerequisites })
        $script:CredentialManagementPasswordDomainNameTextBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") {
            if ($script:CredentialManagementPasswordDomainNameTextBox.text -ne ''){
                $script:CredentialManagementPasswordDomainNameTextBox.text | Out-File "$script:CredentialManagementPath\Specified Domain Name.txt"
            }
            else {Remove-Item "$script:CredentialManagementPath\Specified Domain Name.txt"}
            Check-RollingAccountPrerequisites
        } })
        $CredentialManagementPasswordRollingAccountGroupBox.Controls.Add($script:CredentialManagementPasswordDomainNameTextBox)


        $script:CredentialManagementPasswordDomainNameButton = New-Object System.Windows.Forms.Button -Property @{
            Location = @{ X = $script:CredentialManagementPasswordDomainNameTextBox.Location.X + $script:CredentialManagementPasswordDomainNameTextBox.Size.Width + $($FormScale * 10)
                        Y = $script:CredentialManagementPasswordDomainNameTextBox.Location.Y }
            Size     = @{ Width  = $FormScale * 150
                        Height = $FormScale * 20 }
        }
        CommonButtonSettings -Button $script:CredentialManagementPasswordDomainNameButton
        $script:CredentialManagementPasswordDomainNameButton.Add_Click({
            if ($script:CredentialManagementPasswordDomainNameTextBox.text -ne ''){
                $script:CredentialManagementPasswordDomainNameTextBox.text | Out-File "$script:CredentialManagementPath\Specified Domain Name.txt"
            }
            else {Remove-Item "$script:CredentialManagementPath\Specified Domain Name.txt"}
            Check-RollingAccountPrerequisites
        })
        $CredentialManagementPasswordRollingAccountGroupBox.Controls.Add($script:CredentialManagementPasswordDomainNameButton)

        if ((Test-Path "$script:CredentialManagementPath\Specified Domain Name.txt")) {
            $script:CredentialManagementPasswordDomainNameTextBox.text = Get-Content "$script:CredentialManagementPath\Specified Domain Name.txt"
        }
        else {$script:CredentialManagementPasswordDomainNameTextBox.text = ''}


        $CredentialManagementSelectCredentialRollingAccountLabel = New-Object System.Windows.Forms.Label -Property @{
            Text     = "Select the credentials that roll the credentials used to query and connect to endpoints."
            Location = @{ X = $FormScale * 5
                        Y = $script:CredentialManagementPasswordDomainNameButton.Location.Y + $script:CredentialManagementPasswordDomainNameButton.Size.Height + $($FormScale * 10) }
            Size     = @{ Width  = $FormScale * 465
                        Height = $FormScale * 22 }
            Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = 'Black'
        }
        $CredentialManagementPasswordRollingAccountGroupBox.Controls.Add($CredentialManagementSelectCredentialRollingAccountLabel)


        $CredentialManagementSelectCredentialRollingAccountTextBox = New-Object System.Windows.Forms.Textbox -Property @{
            Location = @{ X = $CredentialManagementSelectCredentialRollingAccountLabel.Location.X
                        Y = $CredentialManagementSelectCredentialRollingAccountLabel.Location.Y + $CredentialManagementSelectCredentialRollingAccountLabel.Size.Height }
            Size     = @{ Width  = $FormScale * 300
                        Height = $FormScale * 25 }
            Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = 'Black'
            BackColor = 'White'
            Enabled   = $false
        }
        $CredentialManagementPasswordRollingAccountGroupBox.Controls.Add($CredentialManagementSelectCredentialRollingAccountTextBox)


        $CredentialManagementSelectCredentialRollingAccountButton = New-Object System.Windows.Forms.Button -Property @{
            Text     = "Select Credentials"
            Location = @{ X = $CredentialManagementSelectCredentialRollingAccountTextBox.Location.X + $CredentialManagementSelectCredentialRollingAccountTextBox.Size.Width + $($FormScale * 10)
                        Y = $CredentialManagementSelectCredentialRollingAccountTextBox.Location.Y - $($FormScale * 1) }
            Size     = @{ Width  = $FormScale * 150
                        Height = $FormScale * 20 }
        }
        CommonButtonSettings -Button $CredentialManagementSelectCredentialRollingAccountButton
        $CredentialManagementSelectCredentialRollingAccountButton.Add_Click({
            try {
                [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
                $CredentialManagementSelectCredentialsOpenFileDialog                  = New-Object System.Windows.Forms.OpenFileDialog
                $CredentialManagementSelectCredentialsOpenFileDialog.Title            = "Select Credentials"
                $CredentialManagementSelectCredentialsOpenFileDialog.InitialDirectory = $script:CredentialManagementPath
                $CredentialManagementSelectCredentialsOpenFileDialog.filter           = "XML (*.xml)|*.xml|All files (*.*)|*.*"
                $CredentialManagementSelectCredentialsOpenFileDialog.ShowHelp         = $true
                $CredentialManagementSelectCredentialsOpenFileDialog.ShowDialog() | Out-Null
                $script:AdminCredsToRollPassword = Import-CliXml -Path $($CredentialManagementSelectCredentialsOpenFileDialog.filename)
                $CredentialName = $null
                $CredentialName = $($CredentialManagementSelectCredentialsOpenFileDialog.filename).split('\')[-1]
                $CredentialManagementSelectCredentialRollingAccountTextBox.text = $CredentialName
                $CredentialName | Out-File "$script:CredentialManagementPath\Administrator Account That Updates The Rolling Credentials.txt"
                $StatusListBox.Items.Clear()
                $StatusListBox.Items.Add("Credentials:  $CredentialName")
                Check-RollingAccountPrerequisites
            }
            catch{}
        })
        $CredentialManagementPasswordRollingAccountGroupBox.Controls.Add($CredentialManagementSelectCredentialRollingAccountButton)


        # note: Previous versions had the random password set at 250 characters, but this was scalled back because during testing cmdkey doesn't seem to support anything larger
        # a-z,A-Z,0-9``~!@#$%^&*()_+-=[]\{}|;:',`"./<>?
        $CredentialManagementGenerateNewPasswordLabel = New-Object System.Windows.Forms.Label -Property @{
            Text     = "Generates a new password for the rolling account consisting of 32 alpha-numeric random characters. This is done automatically after connections, but can be executed on demand."
            Location = @{ X = $FormScale * 5
                        Y = $CredentialManagementSelectCredentialRollingAccountButton.Location.Y + $CredentialManagementSelectCredentialRollingAccountButton.Size.Height + $($FormScale * 10) }
            Size     = @{ Width  = $FormScale * 465
                        Height = $FormScale * 35 }
            Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = 'Black'
        }
        $CredentialManagementPasswordRollingAccountGroupBox.Controls.Add($CredentialManagementGenerateNewPasswordLabel)


        $script:CredentialManagementGeneratedRollingPasswordTextBox = New-Object System.Windows.Forms.TextBox -Property @{
            Location = @{ X = $CredentialManagementGenerateNewPasswordLabel.Location.X
                        Y = $CredentialManagementGenerateNewPasswordLabel.Location.Y + $CredentialManagementGenerateNewPasswordLabel.Size.Height }
            Size     = @{ Width  = $FormScale * 300
                        Height = $FormScale * 25 }
            Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = 'Black'
            BackColor = 'White'
        }
        $CredentialManagementPasswordRollingAccountGroupBox.Controls.Add($script:CredentialManagementGeneratedRollingPasswordTextBox)


        $CredentialManagementGenerateNewPasswordButton = New-Object System.Windows.Forms.Button -Property @{
            Text     = "Generate New Password"
            Location = @{ X = $script:CredentialManagementPasswordRollingAccountButton.Location.X
                        Y = $script:CredentialManagementGeneratedRollingPasswordTextBox.Location.Y }
            Size     = @{ Width  = $FormScale * 150
                        Height = $FormScale * 20 }
            Enabled   = $true
        }
        CommonButtonSettings -Button $CredentialManagementGenerateNewPasswordButton
        $CredentialManagementGenerateNewPasswordButton.Add_Click({
            if ($script:CredentialManagementActiveDirectoryTextBox.text -eq '' `
                -or $script:CredentialManagementPasswordRollingAccountTextBox.text -eq '' `
                -or $script:CredentialManagementPasswordDomainNameTextBox.text -eq '' `
                -or $CredentialManagementSelectCredentialRollingAccountTextBox.text -eq '') {
                [System.Windows.MessageBox]::Show('You must first specify a domain controller, user account, domain name, and the credentials used to roll the credentials.')
                $script:CredentialManagementPasswordRollingAccountCheckbox.checked = $false
            }
            else {
                $script:CredentialManagementPasswordRollingAccountCheckbox.checked = $true
                Set-NewRollingPassword
                $script:RollCredentialsState = $true
                $ComputerListProvideCredentialsCheckBox.checked = $true
                $CredentialManagementGenerateNewPasswordButton.enabled = $false
            }
        })
        $CredentialManagementPasswordRollingAccountGroupBox.Controls.Add($CredentialManagementGenerateNewPasswordButton)


    $CredentialManagementForm.Controls.Add($CredentialManagementPasswordRollingAccountGroupBox)

    if ((Test-Path "$script:CredentialManagementPath\Specified Credentials.txt")) {
        $CredentialManagementSelectCredentialsTextBox.text = Get-Content "$script:CredentialManagementPath\Specified Credentials.txt"
    }
    if ((Test-Path "$script:CredentialManagementPath\Administrator Account That Updates The Rolling Credentials.txt")) {
        $CredentialManagementSelectCredentialRollingAccountTextBox.text = Get-Content "$script:CredentialManagementPath\Administrator Account That Updates The Rolling Credentials.txt"
        $CredentialRoller = Get-Content "$script:CredentialManagementPath\Administrator Account That Updates The Rolling Credentials.txt"
        $script:AdminCredsToRollPassword = Import-CliXml "$script:CredentialManagementPath\$CredentialRoller"
    }
    Check-RollingAccountPrerequisites
    $CredentialManagementGenerateNewPasswordButton.enabled = $true


    $CredentialManagementForm.ShowDialog()
}



















