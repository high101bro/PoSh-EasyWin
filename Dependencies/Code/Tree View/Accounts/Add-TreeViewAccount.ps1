function Add-TreeViewAccount {
    if (($AccountsTreeNodePopupAddTextBox.Text -eq "Enter an Account") -or ($AccountsTreeNodePopupOUComboBox.Text -eq "Select an Organizational Unit / Canonical Name (or type a new one)")) {
        [system.media.systemsounds]::Exclamation.play()
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Add an Account:  Error")
        Show-MessageBox -Message 'Error: Enter a suitable name:
- Cannot be blank
- Cannot already exists
- Cannot be the default value' -Title "PoSh-EasyWin" -Options "Ok" -Type "Error" -Sound
    }
    elseif ($script:AccountsTreeViewData.Name -contains $AccountsTreeNodePopupAddTextBox.Text) {
        Message-TreeViewNodeAlreadyExists -Accounts -Message "Add an Account:  Error" -Account $AccountsTreeNodePopupAddTextBox.Text
    }
    else {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Added Selection:  $($AccountsTreeNodePopupAddTextBox.Text)")

        $AccountsAndAccountTreeViewTabControl.SelectedTab = $AccountsTreeviewTab
        $script:AccountsTreeNodeComboBox.SelectedItem = 'CanonicalName'

        Add-TreeViewData -Accounts -RootNode $script:TreeNodeAccountsList -Category $AccountsTreeNodePopupOUComboBox.SelectedItem -Entry $AccountsTreeNodePopupAddTextBox.Text #-ToolTip "No Unique Data Available"
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
        Update-TreeViewState -Accounts -NoMessage
    }
}


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUg0NRgsiTG4lPcSWF/0ylL3wn
# 7omgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUwABcRyNBgENcs00d2JXuiEnsJgkwDQYJKoZI
# hvcNAQEBBQAEggEAWudp8uGX9Ci54eXk9mI6hiAKLBNaN4XUzi++7plnSQf4R0ZG
# sE0nAdPquEbTvLfrYmMtdXYxSKfQtqlgRcGsQ4tXctms2vI4R3UC7XegSKXM9l//
# imY7Ct1TWPsm202xtmheP4DflYWkjJeFplH8SCCDaptrnQQCIsHxFv7/QEx5iStO
# 4xbIiZt2TqG7J2EkfmRhag36Z9hmeMsErJ96vtfv5qBJtFlHj708QUpRTEszF25f
# kaG2IIQK3UDRf63A2spDdK5NJIrX1vpvrJL7L4KJY+KPq06KBFOX/FZeAffnvudP
# 18zfgaDe6ynyu1a6Vti3D07HClxRM633XzoByQ==
# SIG # End signature block
