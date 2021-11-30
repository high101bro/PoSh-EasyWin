$EventLogRPCRadioButtonAdd_Click = {
    if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Session Based') {
        $MessageBox = [System.Windows.Forms.MessageBox]::Show("The '$($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem)' mode does not support the RPC and SMB protocols.`nThe 'Monitor Jobs' mode supports the RPC, SMB, and WinRM protocols - but may be slower and noisier on the network.`n`nDo you want to change the collection mode to 'Monitor Jobs'?","Protocol Alert",[System.Windows.Forms.MessageBoxButtons]::OKCancel)
        switch ($MessageBox){
            "OK" {
                # This brings specific tabs to the forefront/front view
                $MainLeftTabControl.SelectedTab   = $Section1CollectionsTab
                $InformationTabControl.SelectedTab = $Section3ResultsTab

                $StatusListBox.Items.Clear()
                $StatusListBox.Items.Add("Collection Mode Changed to: Individual Execution")
                #Removed For Testing#$ResultsListBox.Items.Clear()
                $ResultsListBox.Items.Add("The collection mode '$($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem)' does not support the RPC and SMB protocols and has been changed to")
                $ResultsListBox.Items.Add("'Monitor Jobs' which supports RPC, SMB, and WinRM - but may be slower and noisier on the network.")
                $script:CommandTreeViewQueryMethodSelectionComboBox.SelectedIndex = 0
                $EventLogRPCRadioButton.checked         = $true
                $ExternalProgramsRPCRadioButton.checked = $true
            }
            "Cancel" {
                $StatusListBox.Items.Clear()
                $StatusListBox.Items.Add("$($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem) does not support RPC")
                $EventLogWinRMRadioButton.checked         = $true
                $ExternalProgramsWinRMRadioButton.checked = $true
             }
        }
    }
    else {
        $ExternalProgramsRPCRadioButton.checked = $true
    }
}

$EventLogRPCRadioButtonAdd_MouseHover = {
    Show-ToolTip -Title "RPC" -Icon "Info" -Message @"
+  Get-WmiObject -Class Win32_NTLogEvent -Filter "(((EventCode='4624') OR (EventCode='4634')) and `
 (TimeGenerated>='$([System.Management.ManagementDateTimeConverter]::ToDmtfDateTime(($script:EventLogsStartTimePicker.Value)))') and (TimeGenerated<='20190314180030.000000-300'))"
"@
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUpuhvvy7J13ppI6pQ1Itu934i
# +1igggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUG5B3xc45dJ9teJqc2fDD32JBOAkwDQYJKoZI
# hvcNAQEBBQAEggEAK4tnT5hl1VeDyZ8i+rNDn+Hi/AgPtQDQg6oY+nSjfVF5pqCv
# BcrHdU8jauej9N4kK9AF3Rz5a6Yyu3oyi2n/OUyqEHAGKnSGxSWaKRB1arizdqBH
# GVBiO70JkBWMUsgU6xOXpEiRjEH06+Ekq0mNzD43/Prn8gIevfoFYWHGatjxIeiq
# wSfmbsFj4PT+6Wfm5ExxFaQf1koKvOihb/CnmleKz7td08+Xn5KyvsjTakntt8qJ
# 0d1toUB9ybUp36lOjny93gKC9jKcShLbeLZv67BpsXSmFTLiuSRwqIfMXvhV7Rcl
# pP1m9V72xxlMJyIRiYfnoOm6yq9DuRuce8ojXg==
# SIG # End signature block
