function Show-TreeViewMoveForm {
    param(
        [switch]$Accounts,
        [switch]$Endpoint,
        [switch]$SelectedAccounts,
        [switch]$SelectedEndpoint,
        $Title
    )

    if ($Accounts) {
        $AccountsTreeNodePopup = New-Object system.Windows.Forms.Form -Property @{
            Text          = "Move"
            Size          = New-Object System.Drawing.Size(($FormScale * 330),($FormScale * 107))
            StartPosition = "CenterScreen"
            Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$script:EasyWinIcon")
            Add_Closing = { $This.dispose() }
        }
        $AccountsTreeNodePopup.Text = $Title
    
    
        $AccountsTreeNodePopupMoveComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
            Text     = "Select A Category"
            Location = @{ X = $FormScale * 10
                          Y = $FormScale * 10 }
            Size     = @{ Width  = $FormScale * 300
                          Height = $FormScale * 25 }
            AutoCompleteSource = "ListItems"
            AutoCompleteMode   = "SuggestAppend"
            Font               = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        # Dynamically creates the combobox's Category list used for the move destination
        $AccountsTreeNodeCategoryList = @()
        [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:AccountsTreeView.Nodes
        ForEach ($root in $AllTreeViewNodes) { foreach ($Category in $root.Nodes) { $AccountsTreeNodeCategoryList += $Category.text } }
        ForEach ($Item in $AccountsTreeNodeCategoryList) { $AccountsTreeNodePopupMoveComboBox.Items.Add($Item) }
    
        # Moves the hostname/IPs to the new Category
        $AccountsTreeNodePopupMoveComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") {
            # This brings specific tabs to the forefront/front view
            $InformationTabControl.SelectedTab = $Section3ResultsTab
            if ($SelectedAccounts){ Move-TreeViewData -Accounts -SelectedAccounts }
            else { Move-TreeViewData -Accounts }
            $AccountsTreeNodePopup.close()
        } })
        $AccountsTreeNodePopup.Controls.Add($AccountsTreeNodePopupMoveComboBox)
    
    
        $AccountsTreeNodePopupExecuteButton = New-Object System.Windows.Forms.Button -Property @{
            Text     = "Execute"
            Location = @{ X = $FormScale * 210
                          Y = $AccountsTreeNodePopupMoveComboBox.Size.Height + ($FormScale * 15) }
            Size     = @{ Width  = $FormScale * 100
                          Height = $FormScale * 25 }
            Add_Click = {
                # This brings specific tabs to the forefront/front view
                $InformationTabControl.SelectedTab = $Section3ResultsTab
                if ($SelectedAccounts){ Move-TreeViewData -Accounts -SelectedAccounts }
                else { Move-TreeViewData -Accounts }
                $AccountsTreeNodePopup.close()
            }                
        }
        Apply-CommonButtonSettings -Button $AccountsTreeNodePopupExecuteButton
        $AccountsTreeNodePopup.Controls.Add($AccountsTreeNodePopupExecuteButton)
        $AccountsTreeNodePopup.ShowDialog()
    }
    if ($Endpoint) {
        $ComputerTreeNodePopup = New-Object system.Windows.Forms.Form -Property @{
            Text          = "Move"
            Size          = New-Object System.Drawing.Size(($FormScale * 330),($FormScale * 107))
            StartPosition = "CenterScreen"
            Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$script:EasyWinIcon")
            Add_Closing = { $This.dispose() }
        }
        $ComputerTreeNodePopup.Text = $Title
    
    
        $ComputerTreeNodePopupMoveComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
            Text     = "Select A Category"
            Location = @{ X = $FormScale * 10
                          Y = $FormScale * 10 }
            Size     = @{ Width  = $FormScale * 300
                          Height = $FormScale * 25 }
            AutoCompleteSource = "ListItems"
            AutoCompleteMode   = "SuggestAppend"
            Font               = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        # Dynamically creates the combobox's Category list used for the move destination
        $ComputerTreeNodeCategoryList = @()
        [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
        ForEach ($root in $AllTreeViewNodes) { foreach ($Category in $root.Nodes) { $ComputerTreeNodeCategoryList += $Category.text } }
        ForEach ($Item in $ComputerTreeNodeCategoryList) { $ComputerTreeNodePopupMoveComboBox.Items.Add($Item) }
    
        # Moves the hostname/IPs to the new Category
        $ComputerTreeNodePopupMoveComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") {
            # This brings specific tabs to the forefront/front view
            $InformationTabControl.SelectedTab = $Section3ResultsTab
            if ($SelectedEndpoint){ Move-TreeViewData -Endpoint -SelectedEndpoint }
            else { Move-TreeViewData -Endpoint }
            $ComputerTreeNodePopup.close()
        } })
        $ComputerTreeNodePopup.Controls.Add($ComputerTreeNodePopupMoveComboBox)
    
    
        $ComputerTreeNodePopupExecuteButton = New-Object System.Windows.Forms.Button -Property @{
            Text     = "Execute"
            Location = @{ X = $FormScale * 210
                          Y = $ComputerTreeNodePopupMoveComboBox.Size.Height + ($FormScale * 15) }
            Size     = @{ Width  = $FormScale * 100
                          Height = $FormScale * 25 }
            Add_Click = {
                # This brings specific tabs to the forefront/front view
                $InformationTabControl.SelectedTab = $Section3ResultsTab
                if ($SelectedEndpoint){ Move-TreeViewData -Endpoint -SelectedEndpoint }
                else { Move-TreeViewData -Endpoint }
                $ComputerTreeNodePopup.close()
            }                
        }
        Apply-CommonButtonSettings -Button $ComputerTreeNodePopupExecuteButton
        $ComputerTreeNodePopup.Controls.Add($ComputerTreeNodePopupExecuteButton)
        $ComputerTreeNodePopup.ShowDialog()
    }
}


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUgdgyQiHmZu5B97ghqObd5fpI
# heKgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUqCozuCUwP7qu8sS7e3CUMT9eIUcwDQYJKoZI
# hvcNAQEBBQAEggEApmqUZXs8ZjSotM+93b3QEWETZI2cYX348OB3m4pVhn2ft/Bx
# /xUsZPJpSrxKib6/fe6zxJ58ItqUWMb7e4DIVsYKVSvi5sQvXNDZh7l2Zgen6LrG
# zB+Sf8bbGR0IGh3esBuH3iRUQTNlwHAVtHA0A8yI9ToigiIP5DEmebnbhOY0UOYO
# /jndSfZnKP1hsWGDGFDrwUSpECtYd8PhQ/t2EXft16STLryIT2Ey/Ju0VmY+usrL
# aZ/I+iXff/USYdLFZCtq2QN5RxtNaxnoyPVBFgmaYt9wR8ELYodI7tyj/flR5ToI
# yeY+kJ2Sp38iGFjbCaPo2e9j602+ax5SQvfTkA==
# SIG # End signature block
