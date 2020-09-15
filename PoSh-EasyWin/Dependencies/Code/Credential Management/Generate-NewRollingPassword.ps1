function Generate-NewRollingPassword {
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
    $SecurePassword         = ConvertTo-SecureString $GeneratedPassword -AsPlainText -Force
    $PoShEasyWinAccount     = $script:CredentialManagementPasswordRollingAccountTextBox.text
    $PoShEasyWinDomainName  = $script:CredentialManagementPasswordDomainNameTextBox.text

    if ($PoShEasyWinDomainName -ne '') {
        $PoShEasyWinDomainNameAndAccount = "$($PoShEasyWinDomainName)\$($PoShEasyWinAccount)"
    }
    else {
        $PoShEasyWinDomainNameAndAccount = $PoShEasyWinAccount
    }
    $script:credential = $null
    $script:Credential = New-Object System.Management.Automation.PSCredential("$PoShEasyWinDomainNameAndAccount",$SecurePassword)
    # Rolls the PoSh-EasyWin Account Credential
    $ActiveDirectoryServer = $script:CredentialManagementActiveDirectoryTextBox.text

    if ($script:CredentialManagementPasswordRollingAccountCheckbox.checked) {
        $CredentialRoller = Get-Content "$script:CredentialManagementPath\Specified Credentials To Roll Credentials.txt"
        $script:AdminCredsToRollPassword = Import-CliXml "$script:CredentialManagementPath\$CredentialRoller"
        Invoke-Command -ComputerName $ActiveDirectoryServer -Credential $script:AdminCredsToRollPassword -ScriptBlock {
            param(
                $PoShEasyWinAccount,
                $SecurePassword
            ) 
            Set-ADAccountPassword -Identity $PoShEasyWinAccount -Reset -NewPassword $SecurePassword 
        } -ArgumentList @($PoShEasyWinAccount,$SecurePassword)
    }
    else {
        Invoke-Command -ComputerName $ActiveDirectoryServer -ScriptBlock { 
            param(
                $PoShEasyWinDomainNameAndAccount,
                $SecurePassword
            ) 
            Set-ADAccountPassword -Identity $PoShEasyWinDomainNameAndAccount -Reset -NewPassword $SecurePassword 
        } -ArgumentList @($PoShEasyWinDomainNameAndAccount,$SecurePassword)
    }

    $ResultsListBox.Items.Insert(1,"$(($CollectionTimerStop).ToString('yyyy/MM/dd HH:mm:ss'))  Rolled Password For Account: $($script:CredentialManagementPasswordRollingAccountTextBox.text)")
    $PoShEasyWin.Refresh()
    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Generated Secure Password ($NumberOfCharacters Random Characters) and Rolled Credentials"
    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message " - Invoke-Command -ComputerName $ActiveDirectoryServer -ScriptBlock { param($PoShEasyWinDomainNameAndAccount,$SecurePassword) Set-ADAccountPassword -Identity $PoShEasyWinDomainNameAndAccount -Reset -NewPassword $SecurePassword } -ArgumentList @($PoShEasyWinDomainNameAndAccount,$SecurePassword)"



    # Encrypt an exported credential object
    # The Export-Clixml cmdlet encrypts credential objects by using the Windows Data Protection API.
    # The encryption ensures that only your user account on only that computer can decrypt the contents of the 
    # credential object. The exported CLIXML file can't be used on a different computer or by a different user.
    if ($PoShEasyWinDomainName -ne '') {
        $PoShEasyWinDomainNameAndAccount = "$($PoShEasyWinDomainName)-$($PoShEasyWinAccount)"
    }
    else {
        $PoShEasyWinDomainNameAndAccount = $PoShEasyWinAccount
    }
 
    $DateTime = "{0:yyyy-MM-dd @ HHmm.ss}" -f (Get-Date)
    Move-Item -Path "$script:CredentialManagementPath\$PoShEasyWinDomainNameAndAccount (*).xml" -Destination "$script:CredentialManagementPath\Rolled Credentials"
    $CredentialName = "$PoShEasyWinDomainNameAndAccount ($DateTime).xml"
    $script:Credential | Export-Clixml -path "$script:CredentialManagementPath\$CredentialName"

    $CredentialManagementSelectCredentialsTextBox.text = $CredentialName
    $CredentialName | Out-File "$script:CredentialManagementPath\Specified Credentials.txt"

    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Credentials:  $CredentialName")
    $script:CredentialManagementPasswordRollingAccountCheckbox.checked = $true
}