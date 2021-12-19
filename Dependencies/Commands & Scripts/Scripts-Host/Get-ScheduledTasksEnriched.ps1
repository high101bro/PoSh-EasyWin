$ScheduledTasks = Get-ScheduledTask `
| Select-Object -Property State, Actions, Author, Date, Description, Documentation, Principal, SecurityDescriptor, Settings, Source, TaskName, TaskPath, Triggers, URI, Version, PSComputerName

foreach ($Task in $ScheduledTasks) {
    $Task | Add-Member -MemberType NoteProperty -Name Settings -Value $($Task.Settings | Out-String).trim(' ').trim("`r`n") -Force -PassThru `
          | Add-Member -MemberType NoteProperty -Name SettingsIdleSettings -Value $($Task.Settings.IdleSettings | Out-String).trim(' ').trim("`r`n") -Force -PassThru `
          | Add-Member -MemberType NoteProperty -Name SettingsNetworkSettings -Value $($Task.Settings.NetworkSettings | Out-String).trim(' ').trim("`r`n") -Force -PassThru `
          | Add-Member -MemberType NoteProperty -Name Principal -Value $($Task.Principal | Out-String).trim(' ').trim("`r`n") -Force -PassThru `
          | Add-Member -MemberType NoteProperty -Name Actions -Value $($Task.Actions | Out-String).trim(' ').trim("`r`n") -Force -PassThru `
          | Add-Member -MemberType NoteProperty -Name TriggersCount -Value $Task.Triggers.Count -Force -PassThru `
          | Add-Member -MemberType NoteProperty -Name Triggers -Value $($Task.Triggers | Out-String).trim(' ').trim("`r`n") -Force -PassThru `
          | Add-Member -MemberType NoteProperty -Name TriggersRepetition -Value $($Task.Triggers.Repetition | Out-String).trim(' ').trim("`r`n") -Force
}

$ScheduledTasks



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU1j1mgSd5qIDolukuipXHdjhw
# t5ugggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUAx2p43e3dQZ4IxIcV9am7rXCh3UwDQYJKoZI
# hvcNAQEBBQAEggEAJqlqiz1nBeBZFg1Rt2XbgHB4xCKD4t3F3c38E6+1Okr3UHUw
# cgdwt0+6Fmjnk1mcqxPk7r4H6FKWuQbmWAqOrjKC7c9XjfcqAPMywZ0VuJHJuhEc
# eUf6FsEyw6q/QkHw0xtlRWDe2anB13F4BaXZFmCz0HSlih1YWbh8us74EaAL9KAu
# VNqx4/cmEN8A2M8vuB0Ce0IzCK2CNXul3Snoarvf+G+X3qKyvS6JhC+o6l6GHkC0
# E28z7byaWHu674vJsesjdXeTF6Dp080PnvYOm4tRr+bRjMs1UmK4kRUXvgSTjfY1
# oxvkHX3iwjmQ8hm4W2jDooo47WQN9evSLnQTFg==
# SIG # End signature block
