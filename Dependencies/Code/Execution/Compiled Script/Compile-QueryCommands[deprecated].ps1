function Compile-QueryCommands {
    param(
        [switch]$raw
    )
    $script:QueryCommands = @{}
    Foreach ($Command in $script:CommandsCheckedBoxesSelected) {
        # Checks for the type of command selected and assembles the command to be executed
        $script:OutputFileFileType = ""

        if ($Command.Type -eq "(WinRM) Script") {
            $CommandScript = $command.command
            if ($raw) {
                $script:QueryCommands += @{
                    $Command.Name = @{ Name = $Command.Name
                    Command = @"

$(Invoke-Expression ("$CommandScript").Replace("Invoke-Command -FilePath '","Get-Content -Raw -Path '"))

"@
                    Properties = $Command.Properties }
                }
            }
            else {
                $File = ("$CommandScript").Replace("Invoke-Command -FilePath '","").TrimEnd("'")
                $CommandContents = ""
                Foreach ($line in (Get-Content $File)) {$CommandContents += "$line`r`n"}
                $script:QueryCommands += @{
                    $Command.Name = @{ Name = $Command.Name
                    Command = @"

$CommandContents

"@
                    Properties = $Command.Properties }
                }
            }
        }
        elseif ($Command.Type -eq "(WinRM) PoSh") {
            $script:QueryCommands += @{ $Command.Name = @{ Name = $Command.Name ; Command = $Command.Command ; Properties = $Command.Properties }}
        }
        elseif ($Command.Type -eq "(WinRM) WMI") {
            $script:QueryCommands += @{ $Command.Name = @{ Name = $Command.Name ; Command = $Command.Command ; Properties = $Command.Properties }}
        }
        #elseif ($Command.Type -eq "(WinRM) CMD") {
        #    $script:QueryCommands += @{ $Command.Name = @{ Name = $Command.Name ; Command = $Command.Command ; Properties = $Command.Properties }}
        #}



        #elseif ($Command.Type -eq "(RPC) PoSh") {
        #    $script:QueryCommands += @{ $Command.Name = @{ Name = $Command.Name ; Command = $Command.Command ; Properties = $Command.Properties }}
        #}
        if (($Command.Type -eq "(RPC) WMI") -and ($Command.Command -match "Get-WmiObject")) { $script:QueryCommands += @{ $Command.Name = @{ Name = $Command.Name ; Command = $Command.Command ; Properties = $Command.Properties }} }
        elseif (($Command.Type -eq "(RPC) WMI") -and ($Command.Command -match "Invoke-WmiMethod")) {
            $script:QueryCommands += @{ $Command.Name = @{ Name = $Command.Name ; Command = $Command.Command ; Properties = $Command.Properties }}
        }
        #if ($Command.Type -eq "(RPC) CMD") {
        #    $script:QueryCommands += @{ $Command.Name = @{ Name = $Command.Name ; Command = $Command.Command ; Properties = $Command.Properties }}
        #}




        if ($Command.Type -eq "(SMB) PoSh") {
            $script:QueryCommands += @{ $Command.Name = @{ Name = $Command.Name ; Command = $Command.Command ; Properties = $Command.Properties }}
        }
        elseif ($Command.Type -eq "(SMB) WMI") {
            $script:QueryCommands += @{ $Command.Name = @{ Name = $Command.Name ; Command = $Command.Command ; Properties = $Command.Properties }}
        }
        elseif ($Command.Type -eq "(SMB) CMD") {
            $script:QueryCommands += @{ $Command.Name = @{ Name = $Command.Name ; Command = $Command.Command ; Properties = $Command.Properties }}
        }



        $CommandName = $Command.Name
        $CommandType = $Command.Type
    }
}












# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU7LUn5jdclE7CtfnJMVEJBqb0
# nTKgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUYfNAJpc0LBfroWeO7QqMvXwfL4YwDQYJKoZI
# hvcNAQEBBQAEggEAAP2e27IpQObztt0aIdLU2plluAFvxb6wfpU0tKFoggQdgq13
# uwf5vbfJDnqyywCPcwa+rPbvsjslnVq87vN8zpaAt+Vi9nRmKQ7YCv6HKbx/COTi
# 2oegyof0Qca0+aOVE/ATQ4yojfgUBJzGWAQz3aScW6828BC3vjf8iZ8oYhTHwIAw
# ukf2xSvC9cxiMNrqQmCrGLnAtEx+4SiE7LmB6YSXBwIrG1idue0HEoglSQp+Uxr4
# uQqZHxxiX/j6ZwpbLOO8z/N5cfSIsq1PBM2Cfm3wcOZkpwqsjSej6PLWc5shUJdF
# SgGsOmqLvozOvfG1HzixYtyYxzbxKA2jXLUhiA==
# SIG # End signature block
