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
# 2bWgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUIjghr73V5R+gfrTvFF05vnddq8QwDQYJKoZI
# hvcNAQEBBQAEggEAc3VQA0LUbxtZMy9Gq0nCqiOQM60lu+tdkkBRdNdB+T+vG9x3
# j0Of9Fdgsjc1KDzmFRl59UYq+dyG/EG5yCAlVyUfHTdONCClEc1xU0Gi4PD9Tl8v
# TKkIRATdSkE8oDpdSKuS2tuhpElz09hntQAUbhdTOoRVIENj30icG5NYTgC9rN1n
# dzWFbEsl44shb6wxM7H5JWVB4LkuEPdo2FILcqD5lZwttNTtm2bpZ62LxxqrzpEm
# ItVrEIqASP2hUv9wMDrasmXWFpR3+3IW+fsxzHQGT/oS0FhrTYyPZi+bKziV38SY
# l34hOwBefyaq/KociyW+tYRwq4VIKZNTOFP1+w==
# SIG # End signature block
