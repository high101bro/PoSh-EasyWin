
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
# 3LagggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUvVQRFL+/kDLefAwAjwfbwYV89xkwDQYJKoZI
# hvcNAQEBBQAEggEAGGhOlfLPW7H+4wv3lItw5tPcDYzrKLdfOroV6MHn9ZcHWREK
# +jxUoh6oY8kkHpui2l1AGzG0Twbgv8JczRiuUBt5hyDt6bEpJoGV8BNt3KoBQGrw
# IpeC9m5bb+GA5vSLyVcx0FgmlR+KpCkodL2lt0ltxLvOQOt3bwGf9xExQBtcJmKH
# LWJ1SApPP0GNTHfR4i3O5zOlJ1w3P7NZ5c+gujBi9ABpO6MDgaSQCjUI1uCFpavI
# GeNMminn5xQrtTIlTM2DbymIw3v/5EeEN8M3NMqvol6tR+PvQv739vKnMsVCdcab
# feXR4A+45kxlPPPaFE67TK38u1ou5/pg+NKIcQ==
# SIG # End signature block
