
$ExternalProgramsWinRMRadioButtonAdd_Click = {
    #if ($ExternalProgramsWinRMRadioButton.checked -eq $true {
        $EventLogWinRMRadioButton.checked = $true
    #}
}

$ExternalProgramsWinRMRadioButtonAdd_MouseHover = {
    Show-ToolTip -Title "WinRM" -Icon "Info" -Message @'
+  Commands Used: (example)
    $Session = New-PSSession -ComputerName 'Endpoint'
    Invoke-Command {
        param($Path)
        Start-Process -Filepath "$Path\Procmon.exe" -ArgumentList @("/AcceptEULA /BackingFile $Path\ProcMon /RunTime 30 /Quiet")
        Remove-Item -Path "C:\Windows\Temp\Procmon.exe" -Force
    } -Session $Session -ArgumentList $Path
    Copy-Item -Path c:\Windows\Temp\ProcMon.pml -Destination $LocalPath\ProcMon -FromSession $Session -Force
'@
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQULcavogkNdOdwheSI30poABpO
# 3LagggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUvVQRFL+/kDLefAwAjwfbwYV89xkwDQYJKoZI
# hvcNAQEBBQAEggEAosRFsdSooVdXjOz1a77LQLLeZG1NWrUGP/sqAuNUZ4NPHzTW
# 0M0fAaC4Z3O7IX7sGIh5n0dbkbiZqUWe4CzZKTpK0c0kIk73oiD7n7aA7mSK7gxs
# 7WvYV7pkyDT2l1EYjCgFF2qWazaCs/EtThqhu5G0l9cWNNwd2xgoBJ/7B/emvaXr
# Fa4/jpbWYyej7xvFRg1p9lr6D9eAp99B/HMVLyOFRDm64IwolIf8OhEtjwBEiXaC
# EkRU1QGxWdGNxsVM1giNXqvfvLTMrrAkBTgLigFXL5OefoXNAXZCWEUqdRZfti8N
# 04rr/0yvI4PSJE2TdfsHmxAQLnLKkt8P+tIZ7w==
# SIG # End signature block
