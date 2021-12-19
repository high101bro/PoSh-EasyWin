Function Import-DataFromCsv {
    param(
        [switch]$Endpoint,
        [switch]$Accounts
    )

    if ($Endpoint){
        $ComputerAndAccountTreeViewTabControl.SelectedTab = $ComputerTreeviewTab
        $InformationTabControl.SelectedTab = $Section3ResultsTab
    
        [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
        $ComputerTreeNodeImportCsvOpenFileDialog                  = New-Object System.Windows.Forms.OpenFileDialog -Property @{
            Title            = "Import .csv Data"
            InitialDirectory = "$PoShHome"
            filter           = "CSV (*.csv)| *.csv|Excel (*.xlsx)| *.xlsx|Excel (*.xls)| *.xls|All files (*.*)|*.*"
            ShowHelp         = $true
        }
        $ComputerTreeNodeImportCsvOpenFileDialog.ShowDialog() | Out-Null
        $ComputerTreeNodeImportCsv = Import-Csv $($ComputerTreeNodeImportCsvOpenFileDialog.filename) | Select-Object -Property Name, IPv4Address, MACAddress, OperatingSystem, CanonicalName | Sort-Object -Property CanonicalName
    
        $StatusListBox.Items.Clear()
        #Removed For Testing#
        $ResultsListBox.Items.Clear()
    
        # Imports data
        foreach ($Computer in $ComputerTreeNodeImportCsv) {
            # Checks if data already exists
            if ($script:ComputerTreeViewData.Name -contains $Computer.Name) {
                Message-NodeAlreadyExists -Endpoint -Message "Import .CSV:  Warning" -Computer $Computer.Name -ResultsListBoxMessage
            }
            else {
                $ComputerAndAccountTreeViewTabControl.SelectedTab = $ComputerTreeviewTab
                $script:ComputerTreeNodeComboBox.SelectedItem = 'CanonicalName'
    
                $CanonicalName = $($($Computer.CanonicalName) -replace $Computer.Name,"" -replace $Computer.CanonicalName.split('/')[0],"").TrimEnd("/")
                if ($Computer.CanonicalName -eq "") { AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category '/Unknown' -Entry $Computer.Name -ToolTip $ComputerData.IPv4Address -IPv4Address $Computer.IPv4Address }
                else { AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category $CanonicalName -Entry $Computer.Name -ToolTip $ComputerData.IPv4Address -IPv4Address $Computer.IPv4Address }
    
                $script:ComputerTreeViewData += $Computer
    
                $script:ComputerTreeView.Nodes.Clear()
                Initialize-TreeViewData -Endpoint
                UpdateState-TreeViewData -Endpoint -NoMessage
                Normalize-TreeViewData -Endpoint
                Foreach($Computer in $script:ComputerTreeViewData) { AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category $Computer.CanonicalName -Entry $Computer.Name -ToolTip $ComputerData.IPv4Address -IPv4Address $Computer.IPv4Address }
                $script:ComputerTreeView.ExpandAll()
            }
        }
        Save-TreeViewData -Endpoint   
    }
    elseif ($Accounts){
        $ComputerAndAccountTreeViewTabControl.SelectedTab = $AccountsTreeviewTab
        $InformationTabControl.SelectedTab = $Section3ResultsTab
        
        [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
        $AccountsTreeNodeImportCsvOpenFileDialog                  = New-Object System.Windows.Forms.OpenFileDialog -Property @{
            Title            = "Import .csv Data"
            InitialDirectory = "$PoShHome"
            filter           = "CSV (*.csv)| *.csv|Excel (*.xlsx)| *.xlsx|Excel (*.xls)| *.xls|All files (*.*)|*.*"
            ShowHelp         = $true
        }
        $AccountsTreeNodeImportCsvOpenFileDialog.ShowDialog() | Out-Null
        $AccountsTreeNodeImportCsv = Import-Csv $($AccountsTreeNodeImportCsvOpenFileDialog.filename) | Select-Object -Property Name, IPv4Address, MACAddress, OperatingSystem, CanonicalName | Sort-Object -Property CanonicalName
        
        $StatusListBox.Items.Clear()
        #Removed For Testing#
        $ResultsListBox.Items.Clear()
        
        # Imports data
        foreach ($Account in $AccountsTreeNodeImportCsv) {
            # Checks if data already exists
            if ($script:AccountsTreeViewData.Name -contains $Account.Name) {
                Message-NodeAlreadyExists -Accounts -Message "Import .CSV:  Warning" -Account $Account.Name -ResultsListBoxMessage
            }
            else {
                $ComputerAndAccountTreeViewTabControl.SelectedTab = $AccountsTreeviewTab
                $script:AccountsTreeNodeComboBox.SelectedItem = 'CanonicalName'
        
                $CanonicalName = $($($Account.CanonicalName) -replace $Account.Name,"" -replace $Account.CanonicalName.split('/')[0],"").TrimEnd("/")
                if ($Account.CanonicalName -eq "") { AddTreeNodeTo-TreeViewData -Accounts -RootNode $script:TreeNodeAccountsList -Category '/Unknown' -Entry $Account.Name -ToolTip $Account.SID }
                else { AddTreeNodeTo-TreeViewData -Accounts -RootNode $script:TreeNodeAccountsList -Category $CanonicalName -Entry $Account.Name -ToolTip $Account.SID }
        
                $script:AccountsTreeViewData += $Account
        
                $script:AccountsTreeView.Nodes.Clear()
                Initialize-TreeViewData -Accounts
                UpdateState-TreeViewData -Accounts -NoMessage
                Normalize-TreeViewData -Accounts
                Foreach($Account in $script:AccountsTreeViewData) { AddTreeNodeTo-TreeViewData -Accounts -RootNode $script:TreeNodeAccountsList -Category $Account.CanonicalName -Entry $Account.Name -ToolTip $Account.SID }
                $script:AccountsTreeView.ExpandAll()
            }
        }
        Save-TreeViewData -Accounts
    }
}


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUIJ/5Mvh0ITTvPZ0XCA/MHDx0
# kX6gggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUb/1dGzgGc5juqxnktwm5RlKqAW8wDQYJKoZI
# hvcNAQEBBQAEggEAeevxhJ+psUkZbQydgfPrlnE0WE5mVSGvxlSJcjr8w23pyAfN
# naRcHQRc+83gcAtVTNPyy5QdOEt1BEAAcOJM/bfuJzrwU+V/gdyxb8L8vF7jP2Nt
# /bNQzyKaDL+HIXAaey9x8vznTkEr+zaLfUI1IjO+T0M+aenNrYwyldihOR9hiTLU
# Z3TgfvFJq/R8esiUBL9Ez2gQelou9EClklD3DiAc/O7pFl41AlNZIfrGnUklvH/b
# ruGqYpCthsxbe6sAy1ev312Sl6Hm4t5QLxasSnSMMdJf779usUouqWLiDoTj6G24
# 5W3XOHcu6lxq3m6SO90fY40BTtinoy/wsugYxw==
# SIG # End signature block
