function Create-NewCredentials {
    $script:Credential = Get-Credential
    if (!$script:Credential){exit}
    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Created New Credentials and stored them locally as an XML using Windows Data Protection API."

    # Encrypt an exported credential object
    # The Export-Clixml cmdlet encrypts credential objects by using the Windows Data Protection API.
    # The encryption ensures that only your user account on only that computer can decrypt the contents of the 
    # credential object. The exported CLIXML file can't be used on a different computer or by a different user.
    $NewCredentialsUsername = ($script:Credential.UserName).replace('\','-')
    $DateTime = "{0:yyyy-MM-dd @ HHmm.ss}" -f (Get-Date)
    $CredentialName = "$NewCredentialsUsername ($DateTime).xml"
    $script:Credential | Export-Clixml -path "$script:CredentialManagementPath\$CredentialName"

    $CredentialManagementSelectCredentialsTextBox.text = $CredentialName
    $CredentialName | Out-File "$script:CredentialManagementPath\Specified Credentials.txt"

    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Credentials:  $CredentialName")
}