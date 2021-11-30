function Select-UserSpecifiedExecutable {
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null

    if (Test-Path "$PoShHome\User Specified Executable And Script") {$ExecAndScriptDir = "$PoShHome\User Specified Executable And Script"}
    else {$ExecAndScriptDir = "$PoShHome"}

    if ($ExeScriptScriptOnlyCheckbox.checked -eq $False) {
        if ($ExeScriptSelectDirRadioButton.checked) {
            $ExeScriptSelectExecutableFolderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{
                #RootFolder = $PoShHome
                SelectedPath = $ExecAndScriptDir
                ShowNewFolderButton = $false
            }
            $ExeScriptSelectExecutableFolderBrowserDialog.ShowDialog()

            if ($($ExeScriptSelectExecutableFolderBrowserDialog.SelectedPath)) {
                $script:ExeScriptSelectDirOrFilePath = $ExeScriptSelectExecutableFolderBrowserDialog.SelectedPath

                $ExeScriptSelectExecutableTextBox.text = "$(($ExeScriptSelectExecutableFolderBrowserDialog.SelectedPath).split('\')[-1])"
            }
        }
    }
    if ($ExeScriptSelectFileRadioButton.checked) {
        $ExeScriptSelectExecutableOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{
            Title = "Select Executable File"
            Filter = "Executable (*.exe)| *.exe|Windows Installer (*.msi)| *.msi|All files (*.*)|*.*"
            ShowHelp = $true
            InitialDirectory = $ExecAndScriptDir
        }
        $ExeScriptSelectExecutableOpenFileDialog.ShowDialog()

        if ($($ExeScriptSelectExecutableOpenFileDialog.filename)) {
            $script:ExeScriptSelectDirOrFilePath = $ExeScriptSelectExecutableOpenFileDialog.filename

            $ExeScriptSelectExecutableTextBox.text = "$(($ExeScriptSelectExecutableOpenFileDialog.filename).split('\')[-1])"
        }
    }
}




# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU9Fr4QRFBe8zwmIFjXjO1Saqb
# 7+OgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUl09s/kiw55I8J4/d9A2y5D0zMq8wDQYJKoZI
# hvcNAQEBBQAEggEAdC9wKcogpxVZwl824cr9clbSZMF+BRtB89YoIn4qGlDxFhH1
# rAZXWmJdzdulcQ2IEpyvdXa5zd7qniwyMOZmDidI8Vk51zA5h+HTRv00portnKOG
# awfpOBX+6FE+MwglSrtqERhuvrSg5k1hnWeRLd5MZTGDtS0dVXPgtbCQWuYmxFIg
# bFQuEJXHTaQBqwsW2ESLToe+dKlPfQDC5ukcZAxndUIyuSiApx/XrlW0RMFw/uJE
# lrbcr+zBkEYcAk9v6oAgloGZbCNpxRk223CNN76Rzc4IMEtzCqmmf07dAEzDFCcC
# BSZRgiYsOJGn/enuZi8jLJlzpk5+Vr2EOfzJ1Q==
# SIG # End signature block
