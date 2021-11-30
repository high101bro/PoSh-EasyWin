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
# 17KgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
# AQUFADAzMTEwLwYDVQQDDChQb1NoLUVhc3lXaW4gQnkgRGFuIEtvbW5pY2sgKGhp
# Z2gxMDFicm8pMB4XDTIxMTEyOTIzNDA0NFoXDTMxMTEyOTIzNTA0M1owMzExMC8G
# A1UEAwwoUG9TaC1FYXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANUnnNeIFC/eQ11BjDFsIHp1
# 2HkKgnRRV07Kqsl4/fibnbOclptJbeKBDQT3iG5csb31s9NippKfzZmXfi69gGE6
# v/L3X4Zb/10SJdFLstfT5oUD7UdiOcfcNDEiD+8OpZx4BWl5SNWuSv0wHnDSIyr1
# 2M0oqbq6WA2FqO3ETpdhkK22N3C7o+U2LeuYrGxWOi1evhIHlnRodVSYcakmXIYh
# pnrWeuuaQk+b5fcWEPClpscI5WiQh2aohWcjSlojsR+TiWG/6T5wKFxSJRf6+exu
# C0nhKbyoY88X3y/6qCBqP6VTK4C04tey5z4Ux4ibuTDDePqH5WpRFMo9Vie1nVkC
# AwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0G
# A1UdDgQWBBS2KLS0Frf3zyJTbQ4WsZXtnB9SFDANBgkqhkiG9w0BAQUFAAOCAQEA
# s/TfP54uPmv+yGI7wnusq3Y8qIgFpXhQ4K6MmnTUpZjbGc4K3DRJyFKjQf8MjtZP
# s7CxvS45qLVrYPqnWWV0T5NjtOdxoyBjAvR/Mhj+DdptojVMMp2tRNPSKArdyOv6
# +yHneg5PYhsYjfblzEtZ1pfhQXmUZo/rW2g6iCOlxsUDr4ZPEEVzpVUQPYzmEn6B
# 7IziXWuL31E90TlgKb/JtD1s1xbAjwW0s2s1E66jnPgBA2XmcfeAJVpp8fw+OFhz
# Q4lcUVUoaMZJ3y8MfS+2Y4ggsBLEcWOK4vGWlAvD5NB6QNvouND1ku3z94XmRO8v
# bqpyXrCbeVHascGVDU3UWTGCAegwggHkAgEBMEcwMzExMC8GA1UEAwwoUG9TaC1F
# YXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKQIQVnYuiASKXo9Gly5k
# J70InDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkq
# hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGC
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUWfoxc7ru+lzSUpb3XPOW7KJQc00wDQYJKoZI
# hvcNAQEBBQAEggEAD1JYWWI8B88Q54DesYnanZ9kBuM/8UFmLavBlaxFh5nRxwae
# JtNpiy0yv8NLNwOnRYWi3gwFO1uK3ct6U8Y0kJjYDURJo/L84tRBrXt0acBVUqEl
# P2EbJ6yQs76uHi6qIC0l0peE3Fct6bRaM0g1J40Hg2fGwp2d4L31cN/FVyIQrd7x
# +jdW5yfrePVLVBCmAxuS845tGIVIEocr8E1qs5uH6a1f3WO619daIL350nUdQES3
# q+S8NKHtW+XXEBcpp9CmQNrX+g19hsnBrux3hdhGYsfwjCzlT2hPJlxeQiYKRf1z
# /sh17cGGb7AoBHf2tmlJtuHweG9uZDX+H1Jd0Q==
# SIG # End signature block
