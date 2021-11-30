param(
    $CredentialXML,
    $ComputerList
)
function MultiEndpoint-PSSession {
    param(
        $SessionId,
        $ComputerList
    )
    while ($Command -ne "exit") {
        $PSSession = Get-PSSession -Id $SessionId

#        if ($PSSession.ComputerName.count -ge 1) {
#            Write-Host "MultiEndpoint [$($PSSession.ComputerName.count)]: > " -NoNewline
#        }
#        elseif ($PSSession.ComputerName.count -eq 0) {
            Write-Host "MultiEndpoint [$($PSSession.ComputerName.count)]: > " -NoNewline
#        }
        $Command = Read-Host
        
        if ($Command -eq '' -or $Command -eq $null) {
            continue
        }        
        elseif ($Command -ne "exit") {
            Invoke-Command `
            -ScriptBlock {
                param([string]$Command)
                . ([ScriptBlock]::Create("$Command")) | Add-Member -MemberType NoteProperty -Name PSComputerName -Value $env:ComputerName -PassThru
            } `
            -Session $PSSession `
            -ArgumentList @($Command)
        }
        elseif ($command -eq "exit") {
            $PSSession = Get-PSSession -Id $SessionId | Remove-PSSession
        }
    }
}
$Credential = Import-CliXML "$CredentialXML"

$MultiEndpointSession = New-PSSession -ComputerName $ComputerList -Credential $Credential
MultiEndpoint-PSSession -SessionId $MultiEndpointSession.Id -ComputerList $ComputerList



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU7P+PXUXbXwZ9OOmQcnt/EBpN
# aqigggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUVpuOFY5obI2eToeHZXeLOpesdMgwDQYJKoZI
# hvcNAQEBBQAEggEAq3o9FHkKWRFG3cjMCobZrR8JkW6cuORBa+ZBzeEg/kAIiVUY
# 51B/6ULU/sU4/3JcSCdLAKE3Sg4R718eezwbDsoOCgYz4AkLqWEFewLz35Yrg2Aa
# 2WlgZeKVGjmVjmFyuEXsWyeTy4rkaSb9hQ38JoKNEzqGS0ZuHBdPvPGHZ4MCn0L5
# h5tv7eJbGCKQG9ljNehGhlSGcs9v1WiWb3z3qgakwmT/ZJd9FkRyAgdtJgzdp7ra
# qlcO59HgYMugiDzq5y4i7Wy0BD2hgT0R+B+G+R29v7Ow1AmXVXGwMW8wgx02FSuP
# d7FBpQqAEdv2VKgnM3gs4yVF7yMN7irPpAXMXw==
# SIG # End signature block
