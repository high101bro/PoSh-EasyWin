Param (
    [datetime]$StartTime = $((Get-Date).AddMonths(-1)),
    [datetime]$EndTime = $(Get-Date)
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
| Set-Variable GetAccountActivity -Force

$ObtainedAccountActivity = $GetAccountActivity | ForEach-Object {
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
$ObtainedAccountActivity | Sort-Object TimeStamp

# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU6th7TpuOTHjCdj3N47E8wjAc
# JS+gggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUC369tc92UvZHv/Zxz7Yp4ic3STowDQYJKoZI
# hvcNAQEBBQAEggEAInH1MTti1mpIqlfTQLJ0NROwzx8K+dfutLZuK2Lkh4NC0sqH
# bIIoCOivUDSO64/gT3zw9kRhG7DCPWAFmOWl8qlrdyk0zu8dW1gCCqf05twt/ms2
# MxZRPc3x6E8y+Tt1PccdsrP+jf6TlYinewnXSY4CHgGnv/X5Oc/Z/3g1VHLtDELj
# QISXBU9SEm0XEvVkHX5MxjrfekDlCKvSbz5mp6lVznDaYswBqovYiSuqs9rtvz0j
# LPrANfEcTEoWPngfMdk0V2ZGVsCWTmbOVqyyTrRXcIjsK0XALz7FLTplw6dwTmrU
# 7qqSj75m1IOCt8IJhYXQJPU3HIDW3nIDVZZwKA==
# SIG # End signature block
