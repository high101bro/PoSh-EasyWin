$ExeScriptUserSpecifiedExecutableAndScriptCheckboxAdd_Click = {
    Update-QueryCount
    
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("User Specified Executable and Script")

    # Manages how the checkbox is handeled to ensure that a config is selected if sysmon is checked
    if ($ExeScriptUserSpecifiedExecutableAndScriptCheckbox.checked -and ($ExeScriptSelectExecutableTextBox.Text -eq "Directory:" -or $ExeScriptSelectExecutableTextBox.Text -eq "File:")) {
        Select-UserSpecifiedExecutable
    }
    if ($ExeScriptUserSpecifiedExecutableAndScriptCheckbox.checked -and $ExeScriptSelectScriptTextBox.Text -eq "Script:") {
        Select-UserSpecifiedScript
    }

    if ($ExeScriptSelectExecutableTextBox.Text -eq "Executable:" -and $ExeScriptSelectScriptTextBox.Text -eq "Script:"){
        $ExeScriptUserSpecifiedExecutableAndScriptCheckbox.checked = $false
        [System.Windows.Forms.MessageBox]::Show("You need to first select an executable and script.","Prerequisite Check",'OK','Info')

    }
    elseif ($ExeScriptSelectExecutableTextBox.Text -eq "Executable:"){
        $ExeScriptUserSpecifiedExecutableAndScriptCheckbox.checked = $false
        [System.Windows.Forms.MessageBox]::Show("You need to first select an executable.","Prerequisite Check",'OK','Info')
    }
    elseif ($ExeScriptSelectScriptTextBox.Text -eq "Script:"){
        $ExeScriptUserSpecifiedExecutableAndScriptCheckbox.checked = $false
        [System.Windows.Forms.MessageBox]::Show("You need to first select an script.","Prerequisite Check",'OK','Info')
    }

    Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
}

$ExeScriptUserSpecifiedExecutableAndScriptCheckboxAdd_MouseHover = {
    Show-ToolTip -Title "User Specified Executable and Script" -Icon "Info" -Message @"
+  Select an Executable and Script to be sent and used within endpoints
+  The executable needs to be executed/started with the accompaning script
+  The script needs to execute/start with the accompaning executable
+  Results and outputs to copy back need to be manually scripted
+  Cleanup and removal of the executable, script, and any results need to be scripted
+  Validate the executable and script combo prior to use within a production network
+  The executable and script are copied to the endpoints' C:\Windows\Temp directory
"@
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUTdXUWa8l3lzWXlNWlGwdzXfH
# JW+gggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUKzPnTNL0dsQdHXvpkSBoOfAUOLUwDQYJKoZI
# hvcNAQEBBQAEggEAqI3DItvssIpztd1KZyHfdjbHf2ZrXSSJCk6bVbZEsrSaqKLT
# /RlwwWQTkyOYXAWxQsH21N9LT/rWnWD6OJv0LUmyqX+N9I7OIBjrH+kRSPTie/E1
# XXrVERhTKcvxb7Z6RPbgKwTVY8n3CEWY63uVIwIetWfyngyG9Eih0Fk79rFwybj1
# HvufcFewwVl42ul6EnFxIWMTVOh3eQ1C1/7r8+SCI/Gb1c7tw63iKiVHoCAya8UH
# xz4ECPoSLQY5rIp48KYHtOzyd6qdYWoOXm0dPmj5bg7DtEISP4PclQ0o3q9ojFtM
# GyFnfO1YZs6aIEp9qKhUZ4HfJ169yt2A/v12zQ==
# SIG # End signature block
