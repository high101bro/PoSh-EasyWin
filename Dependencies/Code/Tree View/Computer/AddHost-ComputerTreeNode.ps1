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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUCdcg/JXJYqdccckMgUjUorIa
# Yr+gggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUd1oGGEM25ZU6E1LwKEu3Xm4hBlYwDQYJKoZI
# hvcNAQEBBQAEggEAh2Hv9XfGiIe1XnwGxUQAGHITLaLreCrMj8cU0X358QAQMNYy
# z25FfTcTGGS5VOTLmgb0/3xLThX0ShjS3WGZyN54MYLdeEryIICdBsVMOpbul3qT
# 4/wic8No4Ob7iauR9SjXWJPlGxGYDq1QpSdTrph16aBI5r6AAFEWDPy5zyCsO1jh
# CYPtlCSrQTc2uJFiYtHOUafQtSjqPKH2PM7Jcs1Q109Dh9OTgmOuBYSp6B8cbALr
# +oAcj/AfTh+z0PdWRlDMR64oaM6wczbshkJmdCBfsy/RwR6+Wg4mcKk6r1C0WlWh
# lrNS7lbPZ+D8FhKCjlZYokC0qCedNE5P1CtS+w==
# SIG # End signature block
