function AddAccount-AccountsTreeNode {
    if (($AccountsTreeNodePopupAddTextBox.Text -eq "Enter an Account") -or ($AccountsTreeNodePopupOUComboBox.Text -eq "Select an Organizational Unit / Canonical Name (or type a new one)")) {
        [system.media.systemsounds]::Exclamation.play()
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Add an Account:  Error")
        [System.Windows.MessageBox]::Show('Enter a suitable name:
- Cannot be blank
- Cannot already exists
- Cannot be the default value ','Error')
    }
    elseif ($script:AccountsTreeViewData.Name -contains $AccountsTreeNodePopupAddTextBox.Text) {
        Message-NodeAlreadyExists -Accounts -Message "Add an Account:  Error" -Account $AccountsTreeNodePopupAddTextBox.Text
    }
    else {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Added Selection:  $($AccountsTreeNodePopupAddTextBox.Text)")

        $AccountsAndAccountTreeViewTabControl.SelectedTab = $AccountsTreeviewTab
        $script:AccountsTreeNodeComboBox.SelectedItem = 'CanonicalName'

        AddTreeNodeTo-TreeViewData -Accounts -RootNode $script:TreeNodeAccountsList -Category $AccountsTreeNodePopupOUComboBox.SelectedItem -Entry $AccountsTreeNodePopupAddTextBox.Text #-ToolTip "No Unique Data Available"
        #Removed For Testing#
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("$($AccountsTreeNodePopupAddTextBox.Text) has been added to $($AccountsTreeNodePopupOUComboBox.Text)")

        $AccountsTreeNodeAddAccount = New-Object PSObject -Property @{
            Name            = $AccountsTreeNodePopupAddTextBox.Text
            CanonicalName   = $AccountsTreeNodePopupOUComboBox.Text
        }
        $script:AccountsTreeViewData += $AccountsTreeNodeAddAccount
        $script:AccountsTreeView.ExpandAll()
        $AccountsTreeNodePopup.close()
        Save-TreeViewData -Accounts
        UpdateState-TreeViewData -Accounts -NoMessage
    }
}


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUg0NRgsiTG4lPcSWF/0ylL3wn
# 7omgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUwABcRyNBgENcs00d2JXuiEnsJgkwDQYJKoZI
# hvcNAQEBBQAEggEAoX5j+hWrOWxktDsEz1qczvEO8DQ/fcXybo8Vw5UABCHrpklQ
# NDpO28gn0raKKs9QLpFLxmeT1n9xMnbq/HZfMEWrwqheqna7mnSl5B/dtwTaLiXB
# meaUklPKO+AMkD0FsBsyKi75fmeorz2LerDVACscdep1lUPDTNrzQnj6gs9uT8sn
# xVNPRcWt/735/ptOEwiJogMOAzFB/YxogtjR3/tLtiRPA4A7HHvk/OhGQ4ozOhHJ
# pFxlEsQlmGbNqRxGnpRlFPt66I1CPfxOuxCw3XSumom46w9ME8EMBklLQuXLKPBM
# 3BBC10kPThrsVmvyrOZYo1S1420+7cJ3/+MAjw==
# SIG # End signature block
