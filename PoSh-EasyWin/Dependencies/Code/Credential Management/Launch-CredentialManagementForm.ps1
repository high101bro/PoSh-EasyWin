$CredentialManagementForm = New-Object system.Windows.Forms.Form -Property @{
    Text          = "Credential Management"
    StartPosition = "CenterScreen"
    Size          = @{ Width  = 510
                       Height = 595 }
    Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
    Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor     = 'Black'
}

if (-not (Test-Path -Path $CredentialManagementPath) ) { New-Item -Path $CredentialManagementPath -Type Directory }
if (-not (Test-Path -Path "$CredentialManagementPath\Rolled Credentials") ) { New-Item -Path "$CredentialManagementPath\Rolled Credentials" -Type Directory }

function Check-RollingAccountPrerequisites {
    $PrerequisitesCheckDomainController = $false
    if ((Test-Path "$CredentialManagementPath\Specified Domain Controller.txt")) {
        if ( $script:CredentialManagementActiveDirectoryTextBox.text -ne (Get-Content "$CredentialManagementPath\Specified Domain Controller.txt")) {
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
        if ( (Get-Content "$CredentialManagementPath\Specified Domain Controller.txt").length -eq 0 ) { $PrerequisitesCheckDomainController = $false }
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
    if ((Test-Path "$CredentialManagementPath\Specified Rolling Account.txt")) {
        if ( $script:CredentialManagementPasswordRollingAccountTextBox.text -ne (Get-Content "$CredentialManagementPath\Specified Rolling Account.txt")) {
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
        if ((Get-Content "$CredentialManagementPath\Specified Rolling Account.txt").length -eq 0){ $PrerequisitesCheckRollingAccount = $false }
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

    if ( ($PrerequisitesCheckDomainController -eq $true) -and ($PrerequisitesCheckRollingAccount -eq $true) -and ($script:CredentialManagementPasswordRollingAccountCheckbox.checked -eq $false) ) { 
        $CredentialManagementGenerateNewPasswordButton.enabled = $true 
    }
    else { $CredentialManagementGenerateNewPasswordButton.enabled = $false }            
}  

#---------------------------------------------------
# Credential Management Select Credentials GroupBox
#---------------------------------------------------
$CredentialManagementAvailableCredentialsGroupBox  = New-Object System.Windows.Forms.Groupbox -Property @{
    Text     = "Specify Credentials:"
    Location = @{ X = 10
                  Y = 10 }
    Size     = @{ Width  = 475
                  Height = 185 }
    Font      = New-Object System.Drawing.Font("$Font",12,1,2,1)
    ForeColor = 'Blue'
}

    $CredentialManagementSelectCredentialsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Select the credentials that PoSh-EasyWin will use while executing queries and for remote access. If no store XML credentials are selected, the credentials used will default to those that launched PoSh-EasyWin."
        Location = @{ X = 5
                      Y = 20 }
        Size     = @{ Width  = 465
                      Height = 44 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = 'Black'
    }
    $CredentialManagementAvailableCredentialsGroupBox.Controls.Add($CredentialManagementSelectCredentialsLabel)


    $CredentialManagementSelectCredentialsTextBox = New-Object System.Windows.Forms.Textbox -Property @{
        Location = @{ X = $CredentialManagementSelectCredentialsLabel.Location.X
                      Y = $CredentialManagementSelectCredentialsLabel.Location.Y + $CredentialManagementSelectCredentialsLabel.Size.Height }
        Size     = @{ Width  = 300
                      Height = 25 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = 'Black'
        BackColor = 'White'
        Enabled   = $false
    }
    $CredentialManagementAvailableCredentialsGroupBox.Controls.Add($CredentialManagementSelectCredentialsTextBox)


    $CredentialManagementSelectCredentialsButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Select Credentials"
        Location = @{ X = $CredentialManagementSelectCredentialsTextBox.Location.X + $CredentialManagementSelectCredentialsTextBox.Size.Width + 10
                      Y = $CredentialManagementSelectCredentialsTextBox.Location.Y - 1}
        Size     = @{ Width  = 150
                      Height = 20 }
    }
    CommonButtonSettings -Button $CredentialManagementSelectCredentialsButton
    $CredentialManagementSelectCredentialsButton.Add_Click({ 
        try {
#               [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
            $CredentialManagementSelectCredentialsOpenFileDialog                  = New-Object System.Windows.Forms.OpenFileDialog
            $CredentialManagementSelectCredentialsOpenFileDialog.Title            = "Select Credentials"
            $CredentialManagementSelectCredentialsOpenFileDialog.InitialDirectory = $CredentialManagementPath
            $CredentialManagementSelectCredentialsOpenFileDialog.filter           = "XML (*.xml)|*.xml|All files (*.*)|*.*"
            $CredentialManagementSelectCredentialsOpenFileDialog.ShowHelp         = $true
            $CredentialManagementSelectCredentialsOpenFileDialog.ShowDialog() | Out-Null
            $script:Credential = Import-CliXml -Path $($CredentialManagementSelectCredentialsOpenFileDialog.filename)
            $CredentialName = $($CredentialManagementSelectCredentialsOpenFileDialog.filename).split('\')[-1]
            $CredentialManagementSelectCredentialsTextBox.text = $CredentialName
            $CredentialName | Out-File "$CredentialManagementPath\Specified Credentials.txt"
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
                      Y = $CredentialManagementSelectCredentialsTextBox.Location.Y + $CredentialManagementSelectCredentialsTextBox.Size.Height + 20 }
        Size     = @{ Width  = 465
                      Height = 52 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = 'Black'
    }
    $CredentialManagementAvailableCredentialsGroupBox.Controls.Add($CredentialManagementCreateCredentialsLabel)


    $CredentialManagementCreateNewCredentialsButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Create New Credentials"
        Location = @{ X = $CredentialManagementSelectCredentialsButton.Location.X
                      Y = $CredentialManagementCreateCredentialsLabel.Location.Y + $CredentialManagementCreateCredentialsLabel.Size.Height }
        Size     = @{ Width  = 150
                      Height = 20 }
    }
    CommonButtonSettings -Button $CredentialManagementCreateNewCredentialsButton
    $CredentialManagementCreateNewCredentialsButton.Add_Click({        
        Create-NewCredentials

        Start-Sleep -Seconds 2
        $ComputerListProvideCredentialsCheckBox.checked = $true
        $CredentialManagementForm.close()
    })
    $CredentialManagementAvailableCredentialsGroupBox.Controls.Add($CredentialManagementCreateNewCredentialsButton)


    $CredentialManagementDecryptCredentialButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Decrypt Credentials"
        Location = @{ X = $CredentialManagementCreateNewCredentialsButton.Location.X - $CredentialManagementCreateNewCredentialsButton.Size.Width - 10
                      Y = $CredentialManagementCreateNewCredentialsButton.Location.Y }
        Size     = @{ Width  = 150
                      Height = 20 }
    }
    CommonButtonSettings -Button $CredentialManagementDecryptCredentialButton
    $CredentialManagementDecryptCredentialButton.Add_Click({
#            [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
        $CredentialManagementDecryptCredentialOpenFileDialog                  = New-Object System.Windows.Forms.OpenFileDialog
        $CredentialManagementDecryptCredentialOpenFileDialog.Title            = "Decode Credentials"
        $CredentialManagementDecryptCredentialOpenFileDialog.InitialDirectory = $CredentialManagementPath
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

#---------------------------------------------------------
# Credential Management Password Rolling Account GroupBox
#---------------------------------------------------------
$CredentialManagementPasswordRollingAccountGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text     = "Automatic Password Rolling:"
    Location = @{ X = $CredentialManagementAvailableCredentialsGroupBox.Location.X
                  Y = $CredentialManagementAvailableCredentialsGroupBox.Location.Y + $CredentialManagementAvailableCredentialsGroupBox.Size.Height + 10 }
    Size     = @{ Width  = $CredentialManagementAvailableCredentialsGroupBox.Size.Width
                  Height = 340 }
    Font      = New-Object System.Drawing.Font("$Font",12,1,2,1)
    ForeColor = 'Blue'
}
    $script:CredentialManagementPasswordRollingAccountCheckbox = New-Object System.Windows.Forms.Checkbox -Property @{
        Text     = "Enable rolling of credentials after queries and remote connections"
        Location = @{ X = 5
                      Y = 20 }
        Size     = @{ Width  = 465
                    Height = 25 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = 'Black'
        Checked  = $script:RollCredentialsState
    }
    $script:CredentialManagementPasswordRollingAccountCheckbox.Add_Click({ 
        if ($script:CredentialManagementActiveDirectoryTextBox.text -eq '' -or $script:CredentialManagementPasswordRollingAccountTextBox.text -eq '') {
            [System.Windows.MessageBox]::Show('You must first specify a domain controller and user account.')
            $script:CredentialManagementPasswordRollingAccountCheckbox.checked = $false
        }
        else {
            if ($script:CredentialManagementPasswordRollingAccountCheckbox.checked) { 
                #[System.Windows.MessageBox]::Show('Checkboxing this also forces an initial credential roll.')
                Generate-NewRollingPassword
                $script:RollCredentialsState = $true

                $ComputerListProvideCredentialsCheckBox.checked = $true
                $CredentialManagementGenerateNewPasswordButton.enabled = $false
            }
            else { $script:RollCredentialsState = $false }
        }
    })
    $CredentialManagementPasswordRollingAccountGroupBox.Controls.Add($script:CredentialManagementPasswordRollingAccountCheckbox)

    #-----------------------------------------------------
    # Credential Management Domain Controller Server Name 
    #-----------------------------------------------------
    $CredentialManagementActiveDirectoryLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Enter the domain controller name that is used for credential management." 
        Location = @{ X = 5
                      Y = $script:CredentialManagementPasswordRollingAccountCheckbox.Location.Y + $script:CredentialManagementPasswordRollingAccountCheckbox.Size.Height + 10 }
        Size     = @{ Width  = 465
                      Height = 20 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = 'Black'
    }
    $CredentialManagementPasswordRollingAccountGroupBox.Controls.Add($CredentialManagementActiveDirectoryLabel)


    $script:CredentialManagementActiveDirectoryTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location = @{ X = $CredentialManagementActiveDirectoryLabel.Location.X 
                      Y = $CredentialManagementActiveDirectoryLabel.Location.Y  + $CredentialManagementActiveDirectoryLabel.Size.Height }
        Size     = @{ Width  = 300
                      Height = 25 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = 'Black'
    }
    $script:CredentialManagementActiveDirectoryTextBox.Add_MouseEnter({ Check-RollingAccountPrerequisites })
    $script:CredentialManagementActiveDirectoryTextBox.Add_MouseLeave({ Check-RollingAccountPrerequisites })
    $script:CredentialManagementActiveDirectoryTextBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { 
        if ($script:CredentialManagementActiveDirectoryTextBox.text -ne ''){
            $script:CredentialManagementActiveDirectoryTextBox.text | Out-File "$CredentialManagementPath\Specified Domain Controller.txt"
        }
        else {Remove-Item "$CredentialManagementPath\Specified Domain Controller.txt"}
        Check-RollingAccountPrerequisites 
    } })
    $CredentialManagementPasswordRollingAccountGroupBox.Controls.Add($script:CredentialManagementActiveDirectoryTextBox)


    $script:CredentialManagementActiveDirectoryButton = New-Object System.Windows.Forms.Button -Property @{
        Location = @{ X = $CredentialManagementActiveDirectoryTextBox.Location.X + $CredentialManagementActiveDirectoryTextBox.Size.Width + 10 
                      Y = $CredentialManagementActiveDirectoryTextBox.Location.Y - 1}
        Size     = @{ Width  = 150
                      Height = 20 }
    }
    CommonButtonSettings -Button $script:CredentialManagementActiveDirectoryButton
    $script:CredentialManagementActiveDirectoryButton.Add_Click({ 
        if ($script:CredentialManagementActiveDirectoryTextBox.text -ne ''){
            $script:CredentialManagementActiveDirectoryTextBox.text | Out-File "$CredentialManagementPath\Specified Domain Controller.txt"
        }
        else {Remove-Item "$CredentialManagementPath\Specified Domain Controller.txt"}
        Check-RollingAccountPrerequisites
    })
    $CredentialManagementPasswordRollingAccountGroupBox.Controls.Add($script:CredentialManagementActiveDirectoryButton)

    if ((Test-Path "$CredentialManagementPath\Specified Domain Controller.txt")) {
        $script:CredentialManagementActiveDirectoryTextBox.text = Get-Content "$CredentialManagementPath\Specified Domain Controller.txt"
    }
    else {$script:CredentialManagementActiveDirectoryTextBox.text = ''}
    Check-RollingAccountPrerequisites

    #------------------------------------------------
    # Credential Management Password Rolling Account 
    #------------------------------------------------
    $CredentialManagementPasswordRollingAccountLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Enter the account name that will be used for password rolling after queries and remote connections are executed. This does not create the account, it just changes the account's password. You must coordinate with the administrator to create an account like: `"EasyWin`"" 
        Location = @{ X = 5
                      Y = $script:CredentialManagementActiveDirectoryButton.Location.Y + $script:CredentialManagementActiveDirectoryButton.Size.Height + 20 }
        Size     = @{ Width  = 465
                      Height = 45 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = 'Black'
    }
    $CredentialManagementPasswordRollingAccountGroupBox.Controls.Add($CredentialManagementPasswordRollingAccountLabel)


    $script:CredentialManagementPasswordRollingAccountTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location = @{ X = $CredentialManagementPasswordRollingAccountLabel.Location.X 
                      Y = $CredentialManagementPasswordRollingAccountLabel.Location.Y + $CredentialManagementPasswordRollingAccountLabel.Size.Height }
        Size     = @{ Width  = 300
                      Height = 25 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = 'Black'
    }
    $script:CredentialManagementPasswordRollingAccountTextBox.Add_MouseEnter({ Check-RollingAccountPrerequisites })
    $script:CredentialManagementPasswordRollingAccountTextBox.Add_MouseLeave({ Check-RollingAccountPrerequisites })
    $script:CredentialManagementPasswordRollingAccountTextBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { 
        if ($script:CredentialManagementPasswordRollingAccountTextBox.text -ne ''){
            $script:CredentialManagementPasswordRollingAccountTextBox.text | Out-File "$CredentialManagementPath\Specified Rolling Account.txt"
        }
        else {Remove-Item "$CredentialManagementPath\Specified Rolling Account.txt"}
        Check-RollingAccountPrerequisites
    } })
    $CredentialManagementPasswordRollingAccountGroupBox.Controls.Add($script:CredentialManagementPasswordRollingAccountTextBox)


    $script:CredentialManagementPasswordRollingAccountButton = New-Object System.Windows.Forms.Button -Property @{
        Location = @{ X = $script:CredentialManagementPasswordRollingAccountTextBox.Location.X + $script:CredentialManagementPasswordRollingAccountTextBox.Size.Width + 10 
                      Y = $script:CredentialManagementPasswordRollingAccountTextBox.Location.Y - 2}
        Size     = @{ Width  = 150
                      Height = 20 }
    }
    CommonButtonSettings -Button $script:CredentialManagementPasswordRollingAccountButton
    $script:CredentialManagementPasswordRollingAccountButton.Add_Click({ 
        if ($script:CredentialManagementPasswordRollingAccountTextBox.text -ne ''){
            $script:CredentialManagementPasswordRollingAccountTextBox.text | Out-File "$CredentialManagementPath\Specified Rolling Account.txt"
        }
        else {Remove-Item "$CredentialManagementPath\Specified Rolling Account.txt"}
        Check-RollingAccountPrerequisites
    })
    $CredentialManagementPasswordRollingAccountGroupBox.Controls.Add($script:CredentialManagementPasswordRollingAccountButton)

    if ((Test-Path "$CredentialManagementPath\Specified Rolling Account.txt")) {
        $script:CredentialManagementPasswordRollingAccountTextBox.text = Get-Content "$CredentialManagementPath\Specified Rolling Account.txt"
    }
    else {$script:CredentialManagementPasswordRollingAccountTextBox.text = ''}

    #--------------------------------------------------------------
    # Credential Management Generate New Password Label and Button
    #--------------------------------------------------------------
    $CredentialManagementGenerateNewPasswordLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Generates a new on-demand password for the rolling account. It consists of 250 random characters from the following: a-z,A-Z,0-9``~!@#$%^&*()_+-=[]\{}|;:',`"./<>?"
        Location = @{ X = 5
                      Y = $script:CredentialManagementPasswordRollingAccountButton.Location.Y + $script:CredentialManagementPasswordRollingAccountButton.Size.Height + 20 }
        Size     = @{ Width  = 465
                      Height = 35 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = 'Black'
    }
    $CredentialManagementPasswordRollingAccountGroupBox.Controls.Add($CredentialManagementGenerateNewPasswordLabel)


    $script:CredentialManagementGeneratedRollingPasswordTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Location = @{ X = $CredentialManagementGenerateNewPasswordLabel.Location.X 
                      Y = $CredentialManagementGenerateNewPasswordLabel.Location.Y + $CredentialManagementGenerateNewPasswordLabel.Size.Height }
        Size     = @{ Width  = 300
                      Height = 25 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = 'Black'
    }
    $CredentialManagementPasswordRollingAccountGroupBox.Controls.Add($script:CredentialManagementGeneratedRollingPasswordTextBox)


    $CredentialManagementGenerateNewPasswordButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Generate New Password"
        Location = @{ X = $script:CredentialManagementPasswordRollingAccountButton.Location.X
                      Y = $script:CredentialManagementGeneratedRollingPasswordTextBox.Location.Y }
        Size     = @{ Width  = 150
                      Height = 20 }
        Enabled   = $true
    }
    CommonButtonSettings -Button $CredentialManagementGenerateNewPasswordButton
    $CredentialManagementGenerateNewPasswordButton.Add_Click({
        Generate-NewRollingPassword
        $ComputerListProvideCredentialsCheckBox.checked = $true
        $CredentialManagementGenerateNewPasswordButton.enabled = $false
    })
    $CredentialManagementPasswordRollingAccountGroupBox.Controls.Add($CredentialManagementGenerateNewPasswordButton)


    $CredentialManagementAdminCredsForPasswordRollingLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "If needed, this credential is used for changing the rolling account's password. It is to be distinguished from other credentials as it should only be used to roll passwords and never be used itself to query or remote access endpoints."
        Location = @{ X = $CredentialManagementPasswordRollingAccountLabel.Location.X
                      Y = $CredentialManagementGenerateNewPasswordButton.Location.Y + $CredentialManagementGenerateNewPasswordButton.Size.Height + 20 }
        Size     = @{ Width  = 465
                      Height = 42 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = 'Black'
    }
    $CredentialManagementPasswordRollingAccountGroupBox.Controls.Add($CredentialManagementAdminCredsForPasswordRollingLabel)


    $script:ProvideAdminCredsToRollPasswordCheckbox = New-Object System.Windows.Forms.Checkbox -Property @{
        Text     = "Specify The Credentials That Change The Rolling Password"
        Location = @{ X = $CredentialManagementAdminCredsForPasswordRollingLabel.Location.X
                      Y = $CredentialManagementAdminCredsForPasswordRollingLabel.Location.Y + $CredentialManagementAdminCredsForPasswordRollingLabel.Size.Height }
        Size     = @{ Width  = 465
                      Height = 20 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = 'Black'
        Checked = $script:AdminCredsToRollPasswordState
    }
    $script:ProvideAdminCredsToRollPasswordCheckbox.Add_Click({
        if ($script:ProvideAdminCredsToRollPasswordCheckbox.checked){
            $script:AdminCredsToRollPassword = Get-Credential
            $script:AdminCredsToRollPasswordState = $true
        }
        else { $script:AdminCredsToRollPasswordState = $false }
    })
    $CredentialManagementPasswordRollingAccountGroupBox.Controls.Add($script:ProvideAdminCredsToRollPasswordCheckbox)

$CredentialManagementForm.Controls.Add($CredentialManagementPasswordRollingAccountGroupBox)

if ((Test-Path "$CredentialManagementPath\Specified Credentials.txt")) {
    $CredentialManagementSelectCredentialsTextBox.text = Get-Content "$CredentialManagementPath\Specified Credentials.txt"
}
Check-RollingAccountPrerequisites
$CredentialManagementGenerateNewPasswordButton.enabled = $true

$CredentialManagementForm.ShowDialog()