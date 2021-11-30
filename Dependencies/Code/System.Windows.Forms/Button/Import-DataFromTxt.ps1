Function Import-DataFromTxt {
    param(
        [switch]$Endpoint,
        [switch]$Accounts
    )

    if ($Endpoint){
        $ComputerAndAccountTreeViewTabControl.SelectedTab = $ComputerTreeviewTab

        [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
        $ComputerTreeNodeImportTxtOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{
            Title            = "Import .txt Data"
            InitialDirectory = "$PoShHome"
            filter           = "TXT (*.txt)| *.txt|All files (*.*)|*.*"
            ShowHelp         = $true
        }
        $ComputerTreeNodeImportTxtOpenFileDialog.ShowDialog() | Out-Null
        $ComputerTreeNodeImportTxt = Get-Content $($ComputerTreeNodeImportTxtOpenFileDialog.filename)
    
        $StatusListBox.Items.Clear()
        #Removed For Testing#
        $ResultsListBox.Items.Clear()
    
        foreach ($Computer in $($ComputerTreeNodeImportTxt | Where-Object {$_ -ne ''}) ) {
            # Checks if the data already exists
            if ($script:ComputerTreeViewData.Name -contains $Computer) {
                Message-NodeAlreadyExists -Endpoint -Message "Import .CSV:  Warning" -Computer $Computer -ResultsListBoxMessage
            }
            else {
                $ComputerAndAccountTreeViewTabControl.SelectedTab = $ComputerTreeviewTab
                $script:ComputerTreeNodeComboBox.SelectedItem = 'CanonicalName'
    
                AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category '/Unknown' -Entry $Computer -ToolTip 'N/A'
    
                $script:ComputerTreeViewData += [PSCustomObject]@{
                    Name            = $Computer
                    OperatingSystem = 'Unknown'
                    CanonicalName   = '/Unknown'
                    IPv4Address     = 'N/A'
                    MACAddress      = 'N/A'
                }
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
    if ($Accounts){
        $ComputerAndAccountTreeViewTabControl.SelectedTab = $AccountsTreeviewTab

        [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
        $AccountsTreeNodeImportTxtOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{
            Title            = "Import .txt Data"
            InitialDirectory = "$PoShHome"
            filter           = "TXT (*.txt)| *.txt|All files (*.*)|*.*"
            ShowHelp         = $true
        }
        $AccountsTreeNodeImportTxtOpenFileDialog.ShowDialog() | Out-Null
        $AccountsTreeNodeImportTxt = Get-Content $($AccountsTreeNodeImportTxtOpenFileDialog.filename)
    
        $StatusListBox.Items.Clear()
        #Removed For Testing#
        $ResultsListBox.Items.Clear()
    
        foreach ($Account in $($AccountsTreeNodeImportTxt | Where-Object {$_ -ne ''}) ) {
            # Checks if the data already exists
            if ($script:AccountsTreeViewData.Name -contains $Account) {
                Message-NodeAlreadyExists -Accounts -Message "Import .CSV:  Warning" -Account $Account -ResultsListBoxMessage
            }
            else {
                $ComputerAndAccountTreeViewTabControl.SelectedTab = $AccountsTreeviewTab
                $script:AccountsTreeNodeComboBox.SelectedItem = 'CanonicalName'
    
                AddTreeNodeTo-TreeViewData -Accounts -RootNode $script:TreeNodeAccountsList -Category '/Unknown' -Entry $Account -ToolTip 'N/A'
    
                $script:AccountsTreeViewData += [PSCustomObject]@{
                    Name            = $Account
                    OperatingSystem = 'Unknown'
                    CanonicalName   = '/Unknown'
                    IPv4Address     = 'N/A'
                    MACAddress      = 'N/A'
                }
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU0dDVBLPKaJwAwstYqj/GBy7f
# HxqgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU+2bvxHH3w/ktvX3b5NaluqFgrFowDQYJKoZI
# hvcNAQEBBQAEggEAVPK48oPmetVoLC4tSRcImRTqE6ax7Ej195Ujm1/6JfEF5yT+
# oYm5eXxbDzMUUqO5t8XlNSwzVlrI2Ca1z9XyF3YT0WT07+0UjkycoWeRMYgJPW5D
# QEhUE2u1ApASHpan5pd0VlJNXFHziEM8pkCPTUONDRADjApeWHZAIjm5rkAuo62d
# /AWHyjHxELzli6AO3ndSrzoyReDqTiJd3ZdBUtWJeKUyFWcIqmp6zCsuP2D83UkV
# jC3LnYaJMX6Z9SkS4i5Ojkq4jiw3CL9O3CHEtvtya8w0bNPhLLQmGaJKM0UOnOwo
# SHX8Iur64gHEQkjw0yj0Mf6TOakdECjAAbUAFQ==
# SIG # End signature block
