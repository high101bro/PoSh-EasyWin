function AddHost-ComputerTreeNode {
    if (($ComputerTreeNodePopupAddTextBox.Text -eq "Enter a hostname/IP") -or ($ComputerTreeNodePopupOSComboBox.Text -eq "Select an Operating System (or type in a new one)") -or ($ComputerTreeNodePopupOUComboBox.Text -eq "Select an Organizational Unit / Canonical Name (or type a new one)")) {
        [system.media.systemsounds]::Exclamation.play()
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Add Hostname/IP:  Error")
        [System.Windows.MessageBox]::Show('Enter a suitable name:
- Cannot be blank
- Cannot already exists
- Cannot be the default value ','Error')
    }
    elseif ($script:ComputerTreeViewData.Name -contains $ComputerTreeNodePopupAddTextBox.Text) {
        Message-NodeAlreadyExists -Endpoint -Message "Add Hostname/IP:  Error" -Computer $ComputerTreeNodePopupAddTextBox.Text
    }
    else {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Added Selection:  $($ComputerTreeNodePopupAddTextBox.Text)")

        $ComputerAndAccountTreeViewTabControl.SelectedTab = $ComputerTreeviewTab
        $script:ComputerTreeNodeComboBox.SelectedItem = 'CanonicalName'

        AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category $ComputerTreeNodePopupOUComboBox.SelectedItem -Entry $ComputerTreeNodePopupAddTextBox.Text #-ToolTip "No Unique Data Available"

        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("$($ComputerTreeNodePopupAddTextBox.Text) has been added to $($ComputerTreeNodePopupOUComboBox.Text)")

        $ComputerTreeNodeAddHostnameIP = New-Object PSObject -Property @{
            Name            = $ComputerTreeNodePopupAddTextBox.Text
            OperatingSystem = $ComputerTreeNodePopupOSComboBox.Text
            CanonicalName   = $ComputerTreeNodePopupOUComboBox.Text
            IPv4Address     = "No IP Available"
        }
        $script:ComputerTreeViewData += $ComputerTreeNodeAddHostnameIP
        #$script:ComputerTreeView.ExpandAll()
        $ComputerTreeNodePopup.close()
        Save-TreeViewData -Endpoint
        #UpdateState-TreeViewData -Endpoint -NoMessage
    }
}


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU+w4aU79/lBTbR866LaDmXcYY
# VM6gggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUsR/M9FCoRF1zSTuKCIImzccZYHgwDQYJKoZI
# hvcNAQEBBQAEggEAOKwGpxnK3ARBDKjqKINf1ST2TGvFIqZvRHuza6TJxDn+GKSH
# VybdcqbaYqfMek457yWOSvjYBW6qymHuj/MDeMIIwzcQgwV9Ajx7wzRN8pA5mvO8
# spoqAU1yQpCBHkERDaEyKAoLo/HTxm1hmzVvCKfpUfrmTAV8ygxpasztZiVKQL5x
# jty+hBkIGieLJj8d27IBO/z9QfbLjlFvddQvvsFsbOnDXvWDCv8VC/bxqc/wkMoA
# sUC3ovIfcsEuTyeBgSh+K/CwTj96LKXVIar8phc/NkH7jvAXWuckpoDbAJK/eAAq
# bJYP/mDDcNY7su9+L1aX3EefbkWbw3jPmP/HEw==
# SIG # End signature block
