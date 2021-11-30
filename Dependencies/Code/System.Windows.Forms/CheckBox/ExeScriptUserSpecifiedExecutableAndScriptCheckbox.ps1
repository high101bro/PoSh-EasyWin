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
# JW+gggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUKzPnTNL0dsQdHXvpkSBoOfAUOLUwDQYJKoZI
# hvcNAQEBBQAEggEARIxQc4Pva5prBn/lJsSvojGE0jdzsqLoh7KzATiW7+u/8meP
# 1MrBotDvXhgcnxBB7u6n/OgfEvGrYeuVIFGh7lQqEy9iaYd2eLnIkUS2oliFgauu
# 9X+hqx9pDwyAMr6etP8ctUJOIknks7693KM1qiHwABSf8mOx2BNZ010br77NMC2i
# j5KpJVplt7XabwO+c3Mv1tkj1Z3pYfay7tao/55h5BsD3xFOwsJwkaVaQMCVlLwD
# fPD51haES3dXw5PKVTconM7ZR99+Zz7OCnCjFNE9W/kqr1B7hz1k6cM8h7AENiH9
# /Y/PGv1dlPdcnvg2JOn+7ZWgFJ0+32Kc/5m/Tw==
# SIG # End signature block
