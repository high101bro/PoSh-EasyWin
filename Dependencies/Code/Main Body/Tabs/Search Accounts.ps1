
$Section1AccountsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = "Accounts  "
    Left   = $FormScale * -1
    Top    = $FormScale * $Column1DownPosition
    Width  = $FormScale * $Column1BoxWidth
    Height = $FormScale * $Column1BoxHeight
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
    ImageIndex = 1
}
$MainLeftSearchTabControl.Controls.Add($Section1AccountsTab)


$AccountsOptionsGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text   = "Collection Options"
    Left   = $FormScale * 5
    Top    = $FormScale * 5
    Width  = $FormScale * 425
    Height = $FormScale * 94
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
}
            $AccountsProtocolRadioButtonLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Protocol:"
                Left   = $FormScale * 7
                Top    = $FormScale * 20
                Width  = $FormScale * 73
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
            }
            $AccountsOptionsGroupBox.Controls.Add($AccountsProtocolRadioButtonLabel)


            $AccountsWinRMRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text   = "WinRM"
                Left   = $FormScale * 80
                Top    = $FormScale * 15
                Width  = $FormScale * 80
                Height = $FormScale * 20
                Checked   = $True
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
            }
            $AccountsOptionsGroupBox.Controls.Add($AccountsWinRMRadioButton)


            $AccountsRPCRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text   = "RPC"
                Left   = $AccountsWinRMRadioButton.Left + $AccountsWinRMRadioButton.Width + $($FormScale * 10)
                Top    = $AccountsWinRMRadioButton.Top
                Width  = $FormScale * 60
                Height = $FormScale * 20
                Checked   = $False
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
                Enabled = $false
            }
            $AccountsOptionsGroupBox.Controls.Add($AccountsRPCRadioButton)


            <#
            $AccountsMaximumCollectionLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Max Collection:"
                Left   = $AccountsRPCRadioButton.Left + $AccountsRPCRadioButton.Width + $($FormScale * 35)
                Top    = $AccountsRPCRadioButton.Top + $($FormScale * 3)
                Width  = $FormScale * 100
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
                Add_MouseHover = $AccountsMaximumCollectionLabelAdd_MouseHover
            }
            $AccountsOptionsGroupBox.Controls.Add($AccountsMaximumCollectionLabel)


            $AccountsMaximumCollectionTextBox = New-Object System.Windows.Forms.TextBox -Property @{
                    Text   = 100
                    Left   = $AccountsMaximumCollectionLabel.Left + $AccountsMaximumCollectionLabel.Width
                    Top    = $AccountsMaximumCollectionLabel.Top - $($FormScale * 3)
                    Width  = $FormScale * 50
                    Height = $FormScale * 20
                    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                    Enabled  = $True
                    Add_MouseHover = $AccountsMaximumCollectionTextBoxAdd_MouseHover
                }
                $AccountsOptionsGroupBox.Controls.Add($AccountsMaximumCollectionTextBox)
        #>


            $AccountsDatetimeStartLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "DateTime Start:"
                Left   = $FormScale * 77
                Top    = $AccountsProtocolRadioButtonLabel.Top + $AccountsProtocolRadioButtonLabel.Height + $($FormScale * 5)
                Width  = $FormScale * 90
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
            }
            $AccountsOptionsGroupBox.Controls.Add($AccountsDatetimeStartLabel)


            $AccountsStartTimePicker = New-Object System.Windows.Forms.DateTimePicker -Property @{
                Left         = $AccountsDatetimeStartLabel.Left + $AccountsDatetimeStartLabel.Width
                Top          = $AccountsProtocolRadioButtonLabel.Top + $AccountsProtocolRadioButtonLabel.Height
                Width        = $FormScale * 250
                Height       = $FormScale * 100
                Font         = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                Format       = [windows.forms.datetimepickerFormat]::custom
                CustomFormat = "dddd MMM dd, yyyy hh:mm tt"
                Enabled      = $True
                Checked      = $True
                ShowCheckBox = $True
                ShowUpDown   = $False
                AutoSize     = $true
                #MinDate      = (Get-Date -Month 1 -Day 1 -Year 2000).DateTime
                #MaxDate      = (Get-Date).DateTime
                Value         = (Get-Date).AddDays(-1).DateTime
            }
            $AccountsOptionsGroupBox.Controls.Add($AccountsStartTimePicker)


            $AccountsDatetimeStopLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "DateTime Stop:"
                Left   = $AccountsDatetimeStartLabel.Left
                Top    = $AccountsDatetimeStartLabel.Top + $AccountsDatetimeStartLabel.Height
                Width  = $AccountsDatetimeStartLabel.Width
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
            }
            $AccountsOptionsGroupBox.Controls.Add($AccountsDatetimeStopLabel)


            $AccountsStopTimePicker = New-Object System.Windows.Forms.DateTimePicker -Property @{
                Left         = $AccountsDatetimeStopLabel.Left + $AccountsDatetimeStopLabel.Width
                Top          = $AccountsDatetimeStartLabel.Top + $AccountsDatetimeStartLabel.Height - $($FormScale * 5)
                Width        = $AccountsStartTimePicker.Width
                Height       = $FormScale * 100
                Font         = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                Format       = [windows.forms.datetimepickerFormat]::custom
                CustomFormat = "dddd MMM dd, yyyy hh:mm tt"
                Enabled      = $True
                Checked      = $True
                ShowCheckBox = $True
                ShowUpDown   = $False
                AutoSize     = $true
                #MinDate      = (Get-Date -Month 1 -Day 1 -Year 2000).DateTime
                #MaxDate      = (Get-Date).DateTime
            }
            $AccountsOptionsGroupBox.Controls.Add($AccountsStopTimePicker)
$Section1AccountsTab.Controls.Add($AccountsOptionsGroupBox)


Update-FormProgress "$Dependencies\Code\Main Body\Get-AccountLogonActivity.ps1"
. "$Dependencies\Code\Main Body\Get-AccountLogonActivity.ps1"
$AccountActivityCheckbox  = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Account Logon Activity (WinRM)"
    Left   = $FormScale * 7
    Top    = $AccountsOptionsGroupBox.Top + $AccountsOptionsGroupBox.Height + $($FormScale * 5)
    Width  = $FormScale * 410
    Height = $FormScale * 20
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        Update-QueryCount
        
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1AccountsTab.Controls.Add($AccountActivityCheckbox)


$AccountActivityLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Uses the Collections Options for Datatime Start/Stop filtering. "
    Left   = $FormScale * 5
    Top    = $AccountActivityCheckbox.Top + $AccountActivityCheckbox.Height
    Width  = $FormScale * 420
    Height = $FormScale * 20
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = "Black"
}
$Section1AccountsTab.Controls.Add($AccountActivityLabel)


$AccountActivitySelectionButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Select Accounts"
    Left   = $FormScale * 4
    Top    = $AccountActivityLabel.Top + $AccountActivityLabel.Height
    Width  = $FormScale * 125
    Height = $FormScale * 20
    Add_Click = {
        if (Test-Path $script:AccountsTreeNodeFileSave) {
            Import-Csv $script:AccountsTreeNodeFileSave | Out-GridView -Title 'PoSh-EasyWin Select Accounts' -PassThru | Set-Variable -Name AccountCsvData
            $AccountActivityTextbox.lines = ''
            foreach ($Account in $AccountCsvData) { $AccountActivityTextbox.lines += $Account.Name}
        }
        else {
            [System.Windows.Forms.MessageBox]::Show("No Account Information available...`nImport account info from the Import Data tab.",'PoSh-EasyWin Select Accounts')
        }
    }
}
$Section1AccountsTab.Controls.Add($AccountActivitySelectionButton)
Apply-CommonButtonSettings -Button $AccountActivitySelectionButton


$AccountActivityClearButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Clear"
    Left   = $FormScale * 136
    Top    = $AccountActivityLabel.Top + $AccountActivityLabel.Height
    Width  = $FormScale * 75
    Height = $FormScale * 20
    Add_Click = { $AccountActivityTextbox.Text = "" }
}
$Section1AccountsTab.Controls.Add($AccountActivityClearButton)
Apply-CommonButtonSettings -Button $AccountActivityClearButton


$AccountActivityTextbox = New-Object System.Windows.Forms.TextBox -Property @{
    Lines  = 'Default is All Accounts'
    Left   = $FormScale * 5
    Top    = $AccountActivityClearButton.Top + $AccountActivityClearButton.Height + $($FormScale * 5)
    Width  = $FormScale * 425
    Height = $FormScale * 139
    MultiLine  = $True
    WordWrap   = $True
    AcceptsTab = $false
    AcceptsReturn  = $false
    ScrollBars     = "Vertical"
    Font           = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_MouseEnter = {if ($this.Text -eq 'Default is All Accounts'){$this.Text = ''}}
    Add_MouseLeave = {if ($this.Text -eq ''){$this.Text = 'Default is All Accounts'}}
}
$Section1AccountsTab.Controls.Add($AccountActivityTextbox)


$AccountsCurrentlyLoggedInConsoleCheckbox  = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Accounts Logged In via Console (WinRM)"
    Left   = $FormScale * 7
    Top    = $AccountActivityTextbox.Top + $AccountActivityTextbox.Height + $($FormScale * 10)
    Width  = $FormScale * 325
    Height = $FormScale * 20
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        Update-QueryCount
        
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes 
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1AccountsTab.Controls.Add($AccountsCurrentlyLoggedInConsoleCheckbox)


$AccountsCurrentlyLoggedInInfoLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Finds Current Activity; No Datetime Filtering."
    Left   = $AccountsCurrentlyLoggedInConsoleCheckbox.Left
    Top    = $AccountsCurrentlyLoggedInConsoleCheckbox.Top + $AccountsCurrentlyLoggedInConsoleCheckbox.Height
    Width  = $FormScale * 420
    Height = $FormScale * 20
    ForeColor = 'Black'
}
$Section1AccountsTab.Controls.Add($AccountsCurrentlyLoggedInInfoLabel)


$AccountsCurrentlyLoggedInInfoButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Reference"
    Left   = $AccountsCurrentlyLoggedInInfoLabel.Left + $AccountsCurrentlyLoggedInInfoLabel.Width + ($FormScale * 20)
    Top    = $AccountsCurrentlyLoggedInInfoLabel.Top #- ($FormScale * 9)
    Width  = $FormScale * 75
    Height = $FormScale * 20
    Add_Click = {
        if (Test-Path "$Dependencies\Reference Account Information.csv") {
            Import-Csv "$Dependencies\Reference Account Information.csv" | Out-GridView -Title 'PoSh-EasyWin - General Account Information'
        }
        else {[System.Windows.Forms.MessageBox]::Show("The General Account Information file for reference cannot be located.",'PoSh-EasyWin Select Accounts')}
     }
}
$Section1AccountsTab.Controls.Add($AccountsCurrentlyLoggedInInfoButton)
Apply-CommonButtonSettings -Button $AccountsCurrentlyLoggedInInfoButton


$AccountsCurrentlyLoggedInPSSessionCheckbox  = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Accounts Logged In Via PowerShell Session (WinRM)"
    Left   = $FormScale * 7
    Top    = $AccountsCurrentlyLoggedInInfoLabel.Top + $AccountsCurrentlyLoggedInInfoLabel.Height + $($FormScale * 10)
    Width  = $FormScale * 350
    Height = $FormScale * 20
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        Update-QueryCount
        
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1AccountsTab.Controls.Add($AccountsCurrentlyLoggedInPSSessionCheckbox)


$AccountsCurrentlyLoggedInPSSessionLabel  = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Finds Current Activity; No Datetime Filtering.`nNote: With WinRM Sessions, your account should also show up in these results."
    Left   = $FormScale * 7
    Top    = $AccountsCurrentlyLoggedInPSSessionCheckbox.Top + $AccountsCurrentlyLoggedInPSSessionCheckbox.Height
    Width  = $FormScale * 420
    Height = $FormScale * 32
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = "Black"
    Add_MouseHover = $AccountsMaximumCollectionLabelAdd_MouseHover
}
$Section1AccountsTab.Controls.Add($AccountsCurrentlyLoggedInPSSessionLabel)



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUv+8rwLqdBg3G2Hhyb9m8YH7x
# /qKgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUVokUCef1CT9Ifs6aZjx/gm02QWEwDQYJKoZI
# hvcNAQEBBQAEggEAnlPeHI/hDHIo9cSMSPmOU6eloSzkuASfzNq9gSqyzHXRLlJG
# tdkme6si0Or/sWZu1IhipceqqwBZsTB27uV/RD6/iNtIwDEjB1iLpZj2HlbDQ6Ee
# yd24aUryikkaiLdCYrBcfw6zprggkJwkvhSEvULvtVZX7i2xa3HUdaZOAj4q9sYO
# KJMYHMhwZmZX8PlnS1w6n3JgATjsqDwEuOQ/sNnV7D+l7H9juwZpXagKYAnNtaIL
# Odfd1jo+A5oNjxMVeQqvMg9pIJtf5xCPyGsOhNYXZqipRmzSDZAvcsRI93x82Rtg
# qveJiOJXjoVmdSzCShxumdWsLy9sUEQ4GZFQAQ==
# SIG # End signature block
