function Show-MoveForm {
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
            Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
            Add_Closing = { $This.dispose() }
        }
        $AccountsTreeNodePopup.Text = $Title
    
    
        $AccountsTreeNodePopupMoveComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
            Text     = "Select A Category"
            Location = @{ X = $FormScale * 10
                          Y = $FormScale * 10 }
            Size     = @{ Width  = $FormScale * 300
                          Height = $FormScale * 25 }
            AutoCompleteSource = "ListItems" # Options are: FileSystem, HistoryList, RecentlyUsedList, AllURL, AllSystemSources, FileSystemDirectories, CustomSource, ListItems, None
            AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
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
            if ($SelectedAccounts){ MoveNode-TreeViewData -Accounts -SelectedAccounts }
            else { MoveNode-TreeViewData -Accounts }
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
                if ($SelectedAccounts){ MoveNode-TreeViewData -Accounts -SelectedAccounts }
                else { MoveNode-TreeViewData -Accounts }
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
            Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
            Add_Closing = { $This.dispose() }
        }
        $ComputerTreeNodePopup.Text = $Title
    
    
        $ComputerTreeNodePopupMoveComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
            Text     = "Select A Category"
            Location = @{ X = $FormScale * 10
                          Y = $FormScale * 10 }
            Size     = @{ Width  = $FormScale * 300
                          Height = $FormScale * 25 }
            AutoCompleteSource = "ListItems" # Options are: FileSystem, HistoryList, RecentlyUsedList, AllURL, AllSystemSources, FileSystemDirectories, CustomSource, ListItems, None
            AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
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
            if ($SelectedEndpoint){ MoveNode-TreeViewData -Endpoint -SelectedEndpoint }
            else { MoveNode-TreeViewData -Endpoint }
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
                if ($SelectedEndpoint){ MoveNode-TreeViewData -Endpoint -SelectedEndpoint }
                else { MoveNode-TreeViewData -Endpoint }
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUjXLTVtG6MqqQJeLOtp4eN+iF
# sFqgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUSFtXOLyOnLvaiPMeGnb122c0lNMwDQYJKoZI
# hvcNAQEBBQAEggEAlkOFQig/mM7WeBoweNnejVSFj8qOn5JF2inzh1yorcYVEOxB
# ouzkFP8wRuSe3WbrUhgdRuERSoLN2tnDI/qJH9w2HBTKC7k9sDdMwkhhFc4AFhni
# vCEjf0Vey5VfqC5wIQWumvJz5DhpB8/I+XQ4IGKo7vJts4Bk7KEe4yrRQF5e4zdR
# R39nFzisDHl/5dTOq0195xYjLE4HwB656wS6XJr4y5V7nH6+PktQ+cfbg+YhcSWA
# aTb3rePeU+cXXE/SG+Vf8GzpQwAVPF/AgrAP+lHwlvbi2ZlPyVtfHxNbLkFI4SxF
# 5763/l4vWPOnzW9dJvSD1yyuvav67RqiktD4dw==
# SIG # End signature block
