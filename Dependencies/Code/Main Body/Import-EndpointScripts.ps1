Function Import-EndpointScripts {
    Foreach ($script in (Get-ChildItem -Path "$QueryCommandsAndScripts\Scripts-Host" | Where-Object {$_.Extension -eq '.ps1'})) {
        $CollectionName = $script.basename
        
        if ($CollectionName -match 'DeepBlue') {
            $script:AllEndpointCommands += [PSCustomObject]@{
                Name                 = $CollectionName
                Type                 = "script"
                Command_WinRM_Script = "Invoke-Command -FilePath '$($script.FullName)' -ArgumentList @('$Dependencies\Commands & Scripts\Scripts-Host\Invoke-DeepBlue-regexes.txt','$Dependencies\Commands & Scripts\Scripts-Host\Invoke-DeepBlue-whitelist.txt')"
                Arguments            = $null
                #Properties_PoSh      = 'PSComputerName, *'
                Description          = @"
$("$(Get-Help $($script.FullName) | Select-Object -ExpandProperty DESCRIPTION)".TrimStart('@{Text=').TrimEnd('}'))

Regex File:
$("$Dependencies\Commands & Scripts\Scripts-Host\Invoke-DeepBlue-regexes.txt")

Whitelist File:
$("$Dependencies\Commands & Scripts\Scripts-Host\Invoke-DeepBlue-whitelist.txt")
"@            
                ScriptPath           = "$($script.FullName)"
                ExportFileName       = "$(($script.basename).trim())"
            }    
        }
        else {
            $script:AllEndpointCommands += [PSCustomObject]@{
                Name                 = $CollectionName
                Type                 = "script"
                Command_WinRM_Script = "Invoke-Command -FilePath '$($script.FullName)'"
                Arguments            = $null
                #Properties_PoSh      = 'PSComputerName, *'
                Description          = @"
$("$(Get-Help $($script.FullName) | Select-Object -ExpandProperty SYNOPSIS)".TrimStart('@{Text=').TrimEnd('}'))

$("$(Get-Help $($script.FullName) | Select-Object -ExpandProperty DESCRIPTION)".TrimStart('@{Text=').TrimEnd('}'))
"@            
                ScriptPath           = "$($script.FullName)"
                ExportFileName       = "$(($script.basename).trim())"
            }
        }
    }
}


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUoVMA8nFY4zqXyaH6nY3yv6jj
# 2bWgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUIjghr73V5R+gfrTvFF05vnddq8QwDQYJKoZI
# hvcNAQEBBQAEggEAIUZ99jWXx9lXcjk+opegGTOyI3ImFVggtWO6dhkNDrbsvVKn
# KbTI09fes8INUfXuhlNH/3tUFsXoJbde3Qnixpu0sw2CspuNwiJcl5iBBpmHwwic
# 38y4iZil6d3hrHmibZgF5X4gWpoQZvk3wZRpQsCnTvnlNfm7ky0uh1bzSi8DMHQZ
# 7dC0ti19wTKPn9wQ9eulTcCkAcyJsks7d/ZZx5KX2gc3CbfpWhg7CHOsIuAz5vCb
# rqQ/+rCPRsmjKxpJzsDUzpNxgk6TZW8hCWDwE2wHHPCNusH5/X1BcdWxvNeYTU9s
# 5+6k1F+3wczsVhiNx+SGTokBrfKLCwMfsyAjcw==
# SIG # End signature block
