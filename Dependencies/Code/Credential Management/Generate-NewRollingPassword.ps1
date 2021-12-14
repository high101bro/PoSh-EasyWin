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
    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Generated Secure Password ($NumberOfCharacters Random Characters) and Rolled Credentials"
    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message " - Invoke-Command -ComputerName $script:ActiveDirectoryServer -ScriptBlock { param($script:PoShEasyWinDomainNameAndAccount,$SecurePassword) Set-ADAccountPassword -Identity $script:PoShEasyWinDomainNameAndAccount -Reset -NewPassword $SecurePassword } -ArgumentList @($script:PoShEasyWinDomainNameAndAccount,$SecurePassword)"



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


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUd0Qt5wwNpu+tl2PIkz4/LXDR
# 17KgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUWfoxc7ru+lzSUpb3XPOW7KJQc00wDQYJKoZI
# hvcNAQEBBQAEggEAVQ+uyGvV8yodYT5/w8c1Xi1LrI1VssADx8uvLxRs0RyyQmX6
# fXekxg8qLzBDJrOx3ArUnz9C+larQYGPSmxnMeRtSxNM6tokzM217+5jdikuzTbU
# elECeOo9G9oLqggWI+xHc5kVIf0+xntTmuhlozJzvyQAHZ6+L5SODunP0C5GWdbn
# ZOiR7nx3JldVs4Xf30mdCFU10BYnVFBHohw0FIGtgYb8UTuPD1O1IPTva+W3NHtS
# b1Q90fxdsRoN/wCPo90Ee0jp/cQ8icqRPraebDHjXnJNcy3WwzHXiYZfj26SiPng
# wzOSIKQfeaIx13747sMoUuxgaINaYi3+upvlcA==
# SIG # End signature block
