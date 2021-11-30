$EventLogsEventIDsToMonitorCheckedListBoxAdd_Click = {
    $InformationTabControl.SelectedTab = $Section3ResultsTab
    $EventID = $($script:EventLogSeverityQueries | Where-Object {$_.EventID -eq $($($EventLogsEventIDsToMonitorCheckListBox.SelectedItem) -split " ")[0]})
    $Display = @(
        "====================================================================================================",
        "Current Event ID:  $($EventID.EventID)",
        "Legacy Event ID:   $($EventID.LegacyEventID)",
        "===================================================================================================="
        "$($EventID.Message)",
        "Ref: $($EventID.Reference)",
        "===================================================================================================="
        )
    # Adds the data from PSObject
    $ResultsListBox.Items.Clear()

    foreach ($item in $Display) {
        $ResultsListBox.Items.Add($item)
    }
    # Adds the notes
    foreach ($line in $($EventID.Notes -split "`r`n")) {
        $ResultsListBox.Items.Add($line)
    }
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU3EtGEgZTBsvrpsRO26GDIwrq
# yUCgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUWIa2q5tL2/Mq+yWmGG/0yDwiOo0wDQYJKoZI
# hvcNAQEBBQAEggEAcvpxuAbnvImBmYVukACViAYLSyNm8ptthIuDcVGrMb/hh7al
# wH5gOaV65RwlWXQtcIyAK1PmtIUfcmOYUR93WBy/igE1DBQnphmeAae2dMnygFEm
# t0rCUnYX0qV/lwt1Tvxd8KdPcVHGpiwmKpbrQpAslS5VghGDAZX4OXaIC0dNr04f
# C9itJWg1cBoC5w6sjQNiLrnJPe0ie3BcldBhP7+clKEUo6Mrmn/twk0XXtWHn4DJ
# jMX1bf7GCRufuqBzijSYq0Xu70HC64Smwm3SvdizxolJDRUlsTOHEmxEZFSldARF
# jVrEuuLMggsaCScPgfdkHhjn3wgAmVeGlAiILQ==
# SIG # End signature block
