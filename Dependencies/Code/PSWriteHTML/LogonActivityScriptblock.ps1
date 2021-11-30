$LogonActivityScriptblock = {
    Function Get-AccountLogonActivity {
        Param (
            [datetime]$StartTime,
            [datetime]$EndTime
        )
        function LogonTypes {
            param($number)
            switch ($number) {
                0  { 'LocalSystem' }
                2  { 'Interactive' }
                3  { 'Network' }
                4  { 'Batch' }
                5  { 'Service' }
                7  { 'Unlock' }
                8  { 'NetworkClearText' }
                9  { 'NewCredentials' }
                10 { 'RemoteInteractive' }
                11 { 'CachedInteractive' }
                12 { 'CachedRemoteInteractive' }
                13 { 'CachedUnlock' }
            }
        }

        function LogonInterpretation {
            param($number)
            switch ($number) {
                0  { 'Local System' }
                2  { 'Logon Via Console' }
                3  { 'Network Remote Logon' }
                4  { 'Scheduled Task Logon' }
                5  { 'Windows Service Account Logon' }
                7  { 'Screen Unlock' }
                8  { 'Clear Text Network Logon' }
                9  { 'Alt Credentials Other Than Logon' }
                10 { 'RDP TS RemoteAssistance' }
                11 { 'Cached Local Credentials' }
                12 { 'Cached RDP TS RemoteAssistance' }
                13 { 'Cached Screen Unlock' }
            }
        }

        $FilterHashTable = @{
            LogName   = 'Security'
            ID        = 4624,4625,4634,4647,4648
        }
        if ($PSBoundParameters.ContainsKey('StartTime')){
            $FilterHashTable['StartTime'] = $StartTime
        }
        if ($PSBoundParameters.ContainsKey('EndTime')){
            $FilterHashTable['EndTime'] = $EndTime
        }

        Get-WinEvent -FilterHashtable $FilterHashTable `
        | Where-Object {$_.Type -ne 3} `
        | Set-Variable GetAccountActivity -Force

        $AccountActivityTextboxtext = $AccountActivityTextbox.lines | Where-Object {$_ -ne ''}
        if (($AccountActivityTextboxtext.count -gt 0) -and -not ($AccountActivityTextboxtext -eq 'Default is All Accounts')) {
            $GetAccountActivity | ForEach-Object {
                [pscustomobject]@{
                    TimeStamp            = $_.TimeCreated
                    UserAccount          = $_.Properties.Value[5]
                    UserDomain           = $_.Properties.Value[6]
                    Type                 = $_.Properties.Value[8]
                    LogonType            = "$(LogonTypes -number $($_.Properties.Value[8]))"
                    LogonInterpretation  = "$(LogonInterpretation -number $($_.Properties.Value[8]))"
                    WorkstationName      = $_.Properties.Value[11]
                    SourceNetworkAddress = $_.Properties.Value[18]
                    SourceNetworkPort    = $_.Properties.Value[19]
                }
            } | Set-Variable ObtainedAccountActivity
            ForEach ($AccountName in $AccountActivityTextboxtext) {
                $ObtainedAccountActivity | Where-Object {$_.UserAccount -match $AccountName} | Sort-Object TimeStamp
            }
        }
        else {
            $GetAccountActivity | ForEach-Object {
                [pscustomobject]@{
                    TimeStamp            = $_.TimeCreated
                    UserAccount          = $_.Properties.Value[5]
                    UserDomain           = $_.Properties.Value[6]
                    Type                 = $_.Properties.Value[8]
                    LogonType            = "$(LogonTypes -number $($_.Properties.Value[8]))"
                    LogonInterpretation  = "$(LogonInterpretation -number $($_.Properties.Value[8]))"
                    WorkstationName      = $_.Properties.Value[11]
                    SourceNetworkAddress = $_.Properties.Value[18]
                    SourceNetworkPort    = $_.Properties.Value[19]
                }
            }
        }
    }
    Get-AccountLogonActivity -StartTime (Get-Date).AddMonths(-1) | Where-Object type -ne 3
}

# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUGJ84kexojRPdQ5u2UwxKW6kS
# 3omgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUQudhO9SKuovinWwpSJLamR0RmQkwDQYJKoZI
# hvcNAQEBBQAEggEADf3x1iFpMTtXFU65KP0XtKuOWf/MimqbP3yyIJaxW89uIwG3
# jwRSxpCwFCR0YGVADniIah/PBUnPAZvRT2sjp4HZXKb8EqP0mvAjH3qz5mRkLpiL
# 0jjVZNCSHxSbnAT1OUeXVbOjjSykTa8tYqvhQNSg4jhaordHAdTDDzR76TjvCSJA
# c6y5OmOGD7k5J02ToFh/3uN1s/k0ZKoCtclWYZx84+zvBagbiArktA3zpTSGSD81
# VW6Rd4hCOG8d7DzAfuwASxtLFpnRDzeeqMJaxQdNaEpuCMFY4PiUKebNJe1cwfw2
# QPFBs/H2H/rZhgWhnaQaRi7vTENKsHWfTG4MzQ==
# SIG # End signature block
