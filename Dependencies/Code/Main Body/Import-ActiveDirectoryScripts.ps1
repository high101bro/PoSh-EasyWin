Function Import-ActiveDirectoryScripts {
    Foreach ($script in (Get-ChildItem -Path "$QueryCommandsAndScripts\Scripts-AD" | Where-Object {$_.Extension -eq '.ps1'})) {
        $CollectionName = $script.basename
        $script:AllActiveDirectoryCommands += [PSCustomObject]@{
            Name                 = $CollectionName
            Type                 = "script"
            Command_WinRM_Script = "Invoke-Command -FilePath '$($script.FullName)'"
            #Properties_PoSh      = 'PSComputerName, *'
            #Properties_WMI       = 'PSComputerName, *'
            Description          = "$(Get-Help $($script.FullName) | Select-Object -ExpandProperty Description)".TrimStart('@{Text=').TrimEnd('}')
            ScriptPath           = "$($script.FullName)"
        }
    }
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUhgEbWLQPFOFoROlD6DYv/lTo
# KOqgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUiLfd3uQ9gUIN4S7arxWGFOfLHYcwDQYJKoZI
# hvcNAQEBBQAEggEAetiYCmaAasZlx2Ywn9DnRds4OCoP9C7eXUrQiKcNzlmF9e/v
# mgFXCeLHC4qnOgtGR0fed0Ccks0iWFNNeF8t7WlCK1sSZ753LmccfbGD0LitClTQ
# wPmaDZVGg2w15aP6hCAJox1hAc9Fbb5XW5Iz2+ZvDBok801/1eaaKPxYEZaxU2aI
# 6ClZYMJOMmPq4upadFvb1Z+uB04wOHA+WX6tf3h7SyY85l99zCKsaSXAbAHMfIKt
# +hA9tgG2GckYruGNzztLnwyP35t8elBPmxegqhZzXotAoE5IHhUVAc8T5+26STFl
# PXG9dTEBK1pVuGMh4LqBqPevRfZ6gMbgwv7bsA==
# SIG # End signature block
