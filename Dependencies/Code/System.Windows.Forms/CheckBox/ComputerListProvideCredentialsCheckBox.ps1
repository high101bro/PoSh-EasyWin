$ComputerListProvideCredentialsCheckBoxAdd_Click = {
    if ($script:ComputerListProvideCredentialsCheckBox.Checked -and (Test-Path "$script:CredentialManagementPath\Specified Credentials.txt")) {
        $SelectedCredentialName = Get-Content "$script:CredentialManagementPath\Specified Credentials.txt"
        $script:SelectedCredentialPath = Get-ChildItem "$script:CredentialManagementPath\$SelectedCredentialName"
        $script:Credential = Import-CliXml $script:SelectedCredentialPath
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Credentials:  $SelectedCredentialName.xml")
    }
    elseif ($script:ComputerListProvideCredentialsCheckBox.Checked -and -not (Test-Path "$script:CredentialManagementPath\Specified Credentials.txt")) {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Credentials:  There are no credentials stored")
        Launch-CredentialManagementForm
    }
    else {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Credentials:  $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)")
    }

    # Test View of Credentials
    ##Removed For Testing#$ResultsListBox.Items.Clear()
    #$ResultsListBox.Items.Add("Username: $($script:Credential.UserName)")
    #$ResultsListBox.Items.Add("Password: $($script:Credential.GetNetworkCredential().Password)")
}

$ComputerListProvideCredentialsCheckBoxAdd_MouseHover = {
    Show-ToolTip -Title "Specify Credentials" -Icon "Info" -Message @"
+  Credentials are stored in memory as credential objects.
+  Credentials stored on disk as XML files are encrypted credential objects using Windows Data Protection API.
    This encryption ensures that only your user account on only that computer can decrypt the contents of the
    credential object. The exported CLIXML file can't be used on a different computer or by a different user.
+  To enable auto password rolling, both this checkbox and the one in Automatic Password Rolling must be checked.
+  If checked, credentials are applied to:
    RDP, PSSession, PSExec
"@
}


