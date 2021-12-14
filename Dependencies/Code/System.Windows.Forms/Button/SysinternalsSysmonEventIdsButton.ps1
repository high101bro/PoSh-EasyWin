$SysinternalsSysmonEventIdsButtonAdd_Click = {
    $EventCodeManualEntrySelectionContents = $null
    Import-Csv  "$Dependencies\Sysmon Config Files\Sysmon Event IDs.csv" | Out-GridView -Title 'Sysmon Event IDs' -OutputMode Multiple | Set-Variable -Name EventCodeManualEntrySelectionContents
    $EventIDColumn = $EventCodeManualEntrySelectionContents | Select-Object -ExpandProperty "Event ID"
    Foreach ($EventID in $EventIDColumn) {
        $EventLogsEventIDsManualEntryTextbox.Text += "$EventID`r`n"
    }

    if ($EventCodeManualEntrySelectionContents){
        $MainLeftSearchTabControl.SelectedTab = $Section1EventLogsTab
    }
}

$SysinternalsSysmonEventIdsButtonAdd_MouseHover = {
    Show-ToolTip -Title "Sysmon Event ID List" -Icon "Info" -Message @"
+  Shows a list of Sysmon specific event IDs
+  These Event IDs will only be generated on endpoints that have Sysmon installed
+  https://docs.microsoft.com/en-us/sysinternals/downloads/sysmon
"@
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU7qx588/8bkD2h2E7YQnsdEMA
# d/mgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUP3c7kLy6cYQcqrT6g5IOG2hQ+hswDQYJKoZI
# hvcNAQEBBQAEggEAjdkrsaGr9w8s/ecWuz1n46kbXr4ZumRId6QaUkS7Fd5A9a04
# NT+DjOEemtZkFsTKrOcERQZ64ShYohi6BiaEcnJ7oTBfxWp9ERu7nUdrrAL+hC7l
# chzZhuTAaCja0COsc2QTwOzvFrLcOf1UO9L00AXwHOyA2d3jiHbYw+7JNExd3EX2
# i9t+lFX6hEtOQN/dSs7mhU7E1rtrFyZ6sJzujJ1Uxh8GUfgrbI8NCLHqhnAOWgeu
# kuyTxBHbgFww2fJTuKGroPV1bims5baHVS+ErhyOguCjpgzghXJt0pnpD3gMxvSa
# G370bsPI0sskSgB+6F0dMJDW6lrd2s8TxvDeZA==
# SIG # End signature block
