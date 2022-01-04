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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU942XelhfxL70GWsKdrmeM8w9
# LEKgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUFu6TXpo+O/pifI54C0JGVJ55KjwwDQYJKoZI
# hvcNAQEBBQAEggEADVC3nQfGxpxls6NUX7OPLK+p8FTKDcq5Eeo2BGhqzvT1RSbk
# OANR+TQMhd+TmNc1JqW3d6z+eT0PwwMa+NI++TeElcHQVmytMxFCmLxX3+r6m277
# zF0FcFA9gy9PSCHqzQ8NBZTKTs8s9T4y4UBgkPtbCzJjqlNO2o/0yy4mSPVXQFzC
# 8/eVEHBk2+hTLJIzrN6HadalPakpULKt1ZnlsV/o9kcExm10EHelUebq+UCj6Qp1
# 9oBah21VKpMeYDx6mp3EYaq9RqX8gwMWVdjMSabJR1yrwj3/R/RGQnAg694rT12n
# GS3pR5jPBGcJiSYhhTItWf2r29TXgPGMzE3rpQ==
# SIG # End signature block
