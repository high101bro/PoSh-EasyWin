param(
    $CredentialXML,
    $TargetComputer,
    $PivotHost
)
function Pivot-PSSession {
    param(
        $SessionId,
        $TargetComputer
    )
    while ($Command -ne "exit") {
        $Session = Get-PSSession -Id $SessionId
        $PivotHost = $Session.ComputerName
        Write-Host "[$PivotHost -> $TargetComputer]: Pivot> " -NoNewline
        $Command = Read-Host
        
        if ($Command -eq '' -or $Command -eq $null) {
            continue
        }        
        elseif ($Command -ne "exit") {
            function Pivot-Command {
                param(
                    $Command,
                    $TargetComputer,
                    $Credential
                )
                Invoke-Command `
                -ScriptBlock {
                    param($Command)
                    Invoke-Expression -Command "$Command"
                } `
                -ArgumentList @($Command,$null) `
                -ComputerName $TargetComputer `
                -credential $Credential `
                -HideComputerName
            }
            $PivotCommand = "function Pivot-Command { ${function:Pivot-Command} }"
            Invoke-Command `
            -ScriptBlock {
                param($PivotCommand,$Command,$TargetComputer,$Credential)
                . ([ScriptBlock]::Create($PivotCommand)) #| Add-Member -MemberType NoteProperty -Name PSComputerName -Value $env:ComputerName -PassThru

                Pivot-Command -Command $Command -TargetComputer $TargetComputer -Credential $Credential
            
            } `
            -Session $Session `
            -ArgumentList @($PivotCommand,$Command,$TargetComputer,$Credential) `
            -HideComputerName
        }
        elseif ($command -eq "exit") {
            $Session = Get-PSSession -Id $SessionId | Remove-PSSession
        }
    }
}

$Credential = Import-CliXML $CredentialXML

$PivotSession = New-PSSession -ComputerName $PivotHost -Credential $Credential
Pivot-PSSession -SessionId $PivotSession.Id -TargetComputer $TargetComputer

# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUpFdq8YWBu7DeBmRpKmPcVhaG
# 0UOgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUc2l49zuERW1mVvq7iAqfHWG241cwDQYJKoZI
# hvcNAQEBBQAEggEAe6GcbwepsCXiWO2ARRB7skKBxP8o7Vaw7gvK7VFtSNfht7DF
# m1xXZrnc1jU6AleoihgvZLB9d9LhVi/k76P+5j0JLNwRRi1TaSqcV5Vrw+ClGB0c
# zduTUfDZPOzcKuGt196DBtgqRfS69cLk54ytOJXkI9aQgcL2SK+MmDqDTlb7hgDR
# 6kf7R5PW006v+Kp/Mtcue0ywtg8VhVd3xIsbBhZOAUR0jiXx/4Sd/0evx6/9HBqo
# y2r9qIsRm/O50ANNyeySXwbpRn9IUfMW+BRtkPbEBrO+ca5TDtmMaQAbpjLC7KDV
# P+ePesBD8TFu/motPo/xjGEAb/g7JHP9tJ1/1w==
# SIG # End signature block
