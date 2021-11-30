function Compile-CsvFiles {
    param (
        [string]$LocationOfCSVsToCompile,
        [string]$LocationToSaveCompiledCSV
    )
    Remove-Item -Path "$LocationToSaveCompiledCSV" -Force
    Start-Sleep -Milliseconds 250

    $CompiledCSVs = @()
    Get-ChildItem "$LocationOfCSVsToCompile" | ForEach-Object {
        if ((Get-Content $_).Length -eq 0) {
            # Removes any files that don't contain data
            Remove-Item $_
        }
        else {
            $CompiledCSVs += Import-Csv -Path $_
        }
    }
    $CompiledCSVs | Select-Object -Property * -Unique | Export-Csv $LocationToSaveCompiledCSV -NoTypeInformation -Force

    # # BUG: When the box is unchecked, the results don't compile correctly
    # if ($OptionKeepResultsByEndpointsFilesCheckBox.checked -eq $false) {
    #     if (Test-Path "$($script:CollectionSavedDirectoryTextBox.Text)\*\*.csv") {
    #         Remove-Item -Path "$($script:CollectionSavedDirectoryTextBox.Text)\*\*.csv" -Recurse -Force
    #     }
    # }
}


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUAZPzT9Ri5TayqoAmhIdeIhzz
# K5qgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUrm32OogWu0wzu2SfyN2C0LhcKzowDQYJKoZI
# hvcNAQEBBQAEggEAqnIEnzZqgFSB2eHhL8kblaRh5UUZpyL8NCezt/PHmDQ9Xa6K
# jp2twB4kQcjsoNN/wmVtDHmLL0T9NH07S1F++JzKLQndqUPOHD+n7oUkjCamz658
# e99M4PSSu+APJPCnHDHLUlTIB94ccT2cqE/v6SSVLuidaiCQzKDrsv10vab5K78Z
# Uf8TG0w4hP3jOfJ2Ki1JKLmUi5gwyvrv+xg5Q8yM/H7Bi3j00LAjgPohVQQCvmkd
# 8q0jSUKMDoiEhjYsWIFOwIGdecsbV2qX8MELZrSgIetca859zZb8hxVWv11UISeJ
# 8o6LPUX73Oy2O47/L14tm62Z4guVWvET/bUQmg==
# SIG # End signature block
