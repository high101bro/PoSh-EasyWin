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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUBh8AZTpZNPsARs5A9ASnjDJ1
# OwGgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUaFZPslbLoXe8nJka7AOOnZ5KWkkwDQYJKoZI
# hvcNAQEBBQAEggEANSnj2RTAGtGU9ME/qqKv17TM9a7Zn196F6k0cswt6BiaID5j
# FM4Vf4hmm0szRLLATiG5xLexq4Hw/RWPRJD5wuKpwpeTeVBfzBpMKHJ2znXitd9Y
# vu4ostA1yvKzChz+/2mGyWd0EHxQZ80RWkduLVuFSkzWdfqFlAP/uMWfozcCEMtW
# WFSF9vjuNVBOag+v2Ip5WTij4E4/Nlnvdk7sn+nxz/31dgBP1mTWZ3SNIPJdruGw
# yXHNt/bX9+tQqxnwxqYKV8sg49dp7FHi01mwRfi75y/lGaZlGGbehSpD4CFMmwUv
# GwhZO40mhaU8v9+Qn1+jYYFzDCDCqr7U2EC5gQ==
# SIG # End signature block
