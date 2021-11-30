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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUbYH3hO0YfJqSom2XQPBT0PVO
# fw6gggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUrVCjwzMoIAOxS1kOEzOtLxtHyLQwDQYJKoZI
# hvcNAQEBBQAEggEAR2BnV+QNRm6n6g6ECzN6LpVp5FdJykZc8VLBaeu2ClQzLFRt
# YdrctqVNm+EhA1jdVmwaMvEvLLLG/SNohetFNbzSJ44ZHqlweGI4BC6thzkkkQX8
# OprxPB3gEWBHKApGzsItt1YixZTigNNoYSHA2ZEmAI8b9rR9MEL0VsBI1pdkY/Jf
# +lx2Lz5fRkhADPycxksODIyPJtfIOlk6IHxZ6ywowi35rnpASntvItonHUv5eGhE
# 7SRVniC1V0ma41Lhv3GrzVsQLSI3T1w/CjYaqQUItYk/WrQzIT44AXpgdSYdpWh4
# BHBYEW382gFXkHg5cRMA1HYUzzoksMSP++hGFA==
# SIG # End signature block
