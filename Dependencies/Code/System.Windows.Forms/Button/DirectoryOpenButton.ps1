$DirectoryOpenButtonAdd_Click = {
    # Invoke-Item -Path "$($script:CollectionSavedDirectoryTextBox.Text)"
    if ($SaveResultsToFileShareCheckbox.Checked) {
        if (Test-Path $($script:CollectionSavedDirectoryTextBox.Text)) {
            # Invoke-Item -Path "$($script:CollectionSavedDirectoryTextBox.Text)"
            # Start-Process PowerShell.exe -ArgumentList "-NoExit & Set-Location '$($script:CollectionSavedDirectoryTextBox.Text)'"
            $Command = @"
            Start-Process 'PowerShell' -ArgumentList '-NoExit',
            '-ExecutionPolicy Bypass',
                { Write-Host '================================================================================' -ForegroundColor Red ; },
                { Write-Host ' To view the SMB File Share natively within Windows Explorer, you need' ; },
                { Write-Host ' to manually map the network drive letter ' -ForegroundColor White -NoNewline ; },
                { Write-Host '$($script:SmbShareDriveLetter): ' -ForegroundColor Cyan -NoNewline ; },
                { Write-Host 'to folder ' -ForegroundColor White -NoNewline ; },
                { Write-Host '\\$script:SMBServer\$script:FileShareName' -ForegroundColor Cyan ; },
                { Write-Host '' ; },
                { Write-Host ' If the Network Drive is mapped, you can open the drive with the following:' -ForegroundColor White ; },
                { Write-Host ' PS> ' -ForegroundColor White -NoNewLine ; },
                { Write-Host ' Invoke-Item "$($script:CollectionSavedDirectoryTextBox.Text)"' -ForegroundColor Cyan ; },
                { Write-Host ' PS> ' -ForegroundColor White -NoNewLine ; },
                { Write-Host ' Invoke-Item .' -ForegroundColor Cyan ; },
                { Write-Host ' PS> ' -ForegroundColor White -NoNewLine ; },
                { Write-Host ' ii .' -ForegroundColor Cyan ; },
                { Write-Host '================================================================================' -ForegroundColor Red ; },
                { Set-Location '"$($script:CollectionSavedDirectoryTextBox.Text)"' ; },
                { Write-Host '' ; }
"@
            Invoke-Expression $Command
            
        }
        elseif (Test-Path "$($script:SmbShareDriveLetter):") {
            # Invoke-Item -Path "$($script:SmbShareDriveLetter):"
            # Start-Process PowerShell.exe -ArgumentList "-NoExit & Set-Location '$($script:SmbShareDriveLetter):'"
            $Command = @"
            Start-Process 'PowerShell' -ArgumentList '-NoExit',
            '-ExecutionPolicy Bypass',
                { Write-Host '================================================================================' -ForegroundColor Red ; },
                { Write-Host ' To view the SMB File Share natively within Windows Explorer, you need' ; },
                { Write-Host ' to manually map the network drive letter ' -ForegroundColor White -NoNewline ; },
                { Write-Host '$($script:SmbShareDriveLetter): ' -ForegroundColor Cyan -NoNewline ; },
                { Write-Host 'to folder ' -ForegroundColor White -NoNewline ; },
                { Write-Host '\\$script:SMBServer\$script:FileShareName' -ForegroundColor Cyan ; },
                { Write-Host '' ; },
                { Write-Host ' If the Network Drive is mapped, you can open the drive with the following:' -ForegroundColor White ; },
                { Write-Host ' PS> ' -ForegroundColor White -NoNewLine ; },
                { Write-Host ' Invoke-Item "$($script:SmbShareDriveLetter):"' -ForegroundColor Cyan ; },
                { Write-Host ' PS> ' -ForegroundColor White -NoNewLine ; },
                { Write-Host ' Invoke-Item .' -ForegroundColor Cyan ; },
                { Write-Host ' PS> ' -ForegroundColor White -NoNewLine ; },
                { Write-Host ' ii .' -ForegroundColor Cyan ; },
                { Write-Host '================================================================================' -ForegroundColor Red ; },
                { Set-Location "$($script:SmbShareDriveLetter):" ; },
                { Write-Host '' ; }
"@
            Invoke-Expression $Command

        }
        else {
            $SaveResultsToFileShareCheckbox.Checked = $false
            [System.Windows.Forms.MessageBox]::Show("There is not share drive connected.","PoSh-EasyWIn - Open Directory",'Ok',"Warning")
        }
    }
    else {
        if (Test-Path $($script:CollectionSavedDirectoryTextBox.Text)) {
            Invoke-Item -Path $script:CollectionSavedDirectoryTextBox.Text
        }
        elseif (Test-Path $CollectedDataDirectory) {
            Invoke-Item -Path $CollectedDataDirectory
        }
        else {
            Invoke-Item -Path $PoShHome
        }
    }
}

$DirectoryOpenButtonAdd_MouseHover = {
    Show-ToolTip -Title "Open Results" -Icon "Info" -Message @"
+  Opens the directory where the collected data is saved.
+  The 'Collected Data' parent directory is opened by default.
+  After collecting data, the directory opened is changed to that
    of where the data is saved - normally the timestamp folder.
+  From here, you can easily navigate the rest of the directory.
"@
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU7srwUMYZ+ZsEM5nRG3Zi5jZZ
# DKCgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUqxw0mt9WLv6kIjs2/mPLj7UBWREwDQYJKoZI
# hvcNAQEBBQAEggEAE9B5XMJo5FErbncag0UudAhBKm9OexUYwXP4zMATQc4uuVjw
# ijDXzZC3Yn/cS+7GsEQ7s4flvd51IzjqCkuoziDxqINU2yZLfJDfemVrLVof4qsu
# /xIVnFN0xf+mVgyTRYJYk64d50wKDDVZctlf8gdduF2GhI+nHm7u0WIRnkdvb85N
# lTAWQDqykdH1u6PHZi3Spel3WS9SOYn0XDo23Wfs8UZLYfeMEKD06TBQenzsNJCX
# 4QYLSvwX1y0KzcNXpq9VvlEHDnKJFOLtuRclW+EuPcZK7JG85XCncIBVVWcms+h+
# zbbomYUzw9yVGtt1DqlvhM4VJvm6y2NZA6l2ZQ==
# SIG # End signature block
