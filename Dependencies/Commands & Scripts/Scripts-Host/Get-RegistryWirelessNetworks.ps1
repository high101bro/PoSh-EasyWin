function Get-WirelessNetworks {
    $RegistryPath     = "Registry::HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles\"
    $RegistryKeyNames = Get-ChildItem -Name $RegistryPath
    $Data = @()
    foreach ($Key in $RegistryKeyNames){
        $KeyPath = $RegistryPath + $Key
        $KeyProperty = get-itemproperty -Path $KeyPath

        $DateCreated = $KeyProperty.DateCreated
          $DC_Hexes  = [System.BitConverter]::ToString($KeyProperty.datecreated) -split '-'
          $DC_Year   = [Convert]::ToInt32($DC_Hexes[1]+$DC_Hexes[0],16)
          $DC_Month  = [Convert]::ToInt32($DC_Hexes[3]+$DC_Hexes[2],16)
          $DC_Day    = [Convert]::ToInt32($DC_Hexes[7]+$DC_Hexes[6],16)
          $DC_Hour   = [Convert]::ToInt32($DC_Hexes[9]+$DC_Hexes[8],16)
          $DC_Minute = [Convert]::ToInt32($DC_Hexes[11]+$DC_Hexes[10],16)
          $DC_Second = [Convert]::ToInt32($DC_Hexes[13]+$DC_Hexes[12],16)
          $DateCreatedFormatted = [datetime]"$DC_Month/$DC_Day/$DC_Year $DC_Hour`:$DC_Minute`:$DC_Second"

        $DateLastConnected = $KeyProperty.DateLastConnected
          $DLC_Hexes  = [System.BitConverter]::ToString($KeyProperty.DateLastConnected) -split '-'
          $DLC_Year   = [Convert]::ToInt32($DLC_Hexes[1]+$DLC_Hexes[0],16)
          $DLC_Month  = [Convert]::ToInt32($DLC_Hexes[3]+$DLC_Hexes[2],16)
          $DLC_Day    = [Convert]::ToInt32($DLC_Hexes[7]+$DLC_Hexes[6],16)
          $DLC_Hour   = [Convert]::ToInt32($DLC_Hexes[9]+$DLC_Hexes[8],16)
          $DLC_Minute = [Convert]::ToInt32($DLC_Hexes[11]+$DLC_Hexes[10],16)
          $DLC_Second = [Convert]::ToInt32($DLC_Hexes[13]+$DLC_Hexes[12],16)
          $DateLastConnectedFormatted = [datetime]"$DLC_Month/$DLC_Day/$DLC_Year $DLC_Hour`:$DLC_Minute`:$DLC_Second"

        $Data += [PSCustomObject]@{
		 "PSComputerName"   = $env:ComputerName
            "SSID"             = $KeyProperty.Description
            "ProfileName"      = $KeyProperty.ProfileName
            "DateCreated"      = $DateCreatedFormatted
            "DateLastConnected"= $DateLastConnectedFormatted
        }
    }
    $Data
}
Get-WirelessNetworks | Select-Object -Property PSComputerName, SSID, ProfileName, DateCreated, DateLastConnected


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUYKIwN/MNN0AqKnYdsUU7O5dv
# OFagggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUB1MlBJ+EPwK5LTTHVdAzep702CYwDQYJKoZI
# hvcNAQEBBQAEggEAEDZJ3EY4hhbiXdxkNCazoHMZYF0kZdZUiUA/0A4JlEc3WDRo
# 2NQ4Da5IG/m+uXti2fFwYc/163hmyqbmJ0jp4JfBBXHD1KIPOUDOZQw7GmS7mFCe
# Ub+Y6DqlnfU68J/xHkHF4ashECTRawAJAw9wbtfaCSZv9d+R8eQ8EjTu9sJxzdnf
# W0LB1QRE8cGJSBcI5TjkPgaf1Sz77UUrNtzonOhRrkumiz13G7IIF5YIeXsoUkTJ
# 1VUG6E2DzG6VfQlahtJAGG5tc0/vzqbIrhzbbSSyssQTWSOCWljktkzzv+NN/KJO
# xkLxCcpx/ezmy4rRri41OFo+v2ci8VWc9J6uIg==
# SIG # End signature block
