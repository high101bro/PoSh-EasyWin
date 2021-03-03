
$Section1AccountsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = "Accounts"
    Left   = $FormScale * $Column1RightPosition
    Top    = $FormScale * $Column1DownPosition
    Width  = $FormScale * $Column1BoxWidth
    Height = $FormScale * $Column1BoxHeight
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
}
$MainLeftCollectionsTabControl.Controls.Add($Section1AccountsTab)


$AccountsMainLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Accounts can be obtained from workstations and servers."
    Left   = $FormScale * 5
    Top    = $FormScale * 5
    Width  = $FormScale * 410
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Black"
}
$Section1AccountsTab.Controls.Add($AccountsMainLabel)


$AccountsOptionsGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text   = "Collection Options"
    Left   = $FormScale * 5
    Top    = $AccountsMainLabel.Top + $AccountsMainLabel.Height
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
                Height = $FormScale * 22
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
                Height = $FormScale * 22
                Checked   = $False
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
                Enabled = $false
            }
            $AccountsOptionsGroupBox.Controls.Add($AccountsRPCRadioButton)


            <#
            . "$Dependencies\Code\System.Windows.Forms\Label\AccountsMaximumCollectionLabel.ps1"
            $AccountsMaximumCollectionLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Max Collection:"
                Left   = $AccountsRPCRadioButton.Left + $AccountsRPCRadioButton.Width + $($FormScale * 35)
                Top    = $AccountsRPCRadioButton.Top + $($FormScale * 3)
                Width  = $FormScale * 100
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
                Add_MouseHover = $AccountsMaximumCollectionLabelAdd_MouseHover
            }
            $AccountsOptionsGroupBox.Controls.Add($AccountsMaximumCollectionLabel)


            . "$Dependencies\Code\System.Windows.Forms\TextBox\AccountsMaximumCollectionTextBox.ps1"
            $AccountsMaximumCollectionTextBox = New-Object System.Windows.Forms.TextBox -Property @{
                    Text   = 100
                    Left   = $AccountsMaximumCollectionLabel.Left + $AccountsMaximumCollectionLabel.Width
                    Top    = $AccountsMaximumCollectionLabel.Top - $($FormScale * 3)
                    Width  = $FormScale * 50
                    Height = $FormScale * 22
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
                Height = $FormScale * 22
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
                Height = $FormScale * 22
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


$AccountsCurrentlyLoggedInConsoleCheckbox  = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Accounts Logged In via Console (Currently)"
    Left   = $FormScale * 7
    Top    = $AccountsOptionsGroupBox.Top + $AccountsOptionsGroupBox.Height + $($FormScale * 10)
    Width  = $FormScale * 325
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = { 
        Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands 
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1AccountsTab.Controls.Add($AccountsCurrentlyLoggedInConsoleCheckbox)


$AccountsCurrentlyLoggedInInfoButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Reference"
    Left   = $AccountsCurrentlyLoggedInConsoleCheckbox.Left + $AccountsCurrentlyLoggedInConsoleCheckbox.Width + ($FormScale * 22)
    Top    = $AccountsCurrentlyLoggedInConsoleCheckbox.Top #- ($FormScale * 9)
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
CommonButtonSettings -Button $AccountsCurrentlyLoggedInInfoButton



$AccountsCurrentlyLoggedInPSSessionCheckbox  = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Accounts Logged In via PowerShell Session (Currently)"
    Left   = $FormScale * 7
    Top    = $AccountsCurrentlyLoggedInConsoleCheckbox.Top + $AccountsCurrentlyLoggedInConsoleCheckbox.Height + $($FormScale * 10)
    Width  = $FormScale * 350
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = { 
        Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands 
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1AccountsTab.Controls.Add($AccountsCurrentlyLoggedInPSSessionCheckbox)


$AccountsCurrentlyLoggedInPSSessionLabel  = New-Object System.Windows.Forms.Label -Property @{
    Text   = "With WinRM Sessions, your account should also show up in these results."
    Left   = $FormScale * 7
    Top    = $AccountsCurrentlyLoggedInPSSessionCheckbox.Top + $AccountsCurrentlyLoggedInPSSessionCheckbox.Height
    Width  = $FormScale * 400
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = "Black"
    Add_MouseHover = $AccountsMaximumCollectionLabelAdd_MouseHover
}
$Section1AccountsTab.Controls.Add($AccountsCurrentlyLoggedInPSSessionLabel)


Update-FormProgress "$Dependencies\Code\Main Body\Get-AccountLogonActivity.ps1"
. "$Dependencies\Code\Main Body\Get-AccountLogonActivity.ps1"
$AccountActivityCheckbox  = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Account Logon Activity (Select Datetime Range)"
    Left   = $FormScale * 7
    Top    = $AccountsCurrentlyLoggedInPSSessionLabel.Top + $AccountsCurrentlyLoggedInPSSessionLabel.Height + $($FormScale * 10)
    Width  = $FormScale * 410
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = { 
        Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands 
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1AccountsTab.Controls.Add($AccountActivityCheckbox)


$AccountActivityLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Enter Account Names; One Per Line"
    Left   = $FormScale * 5
    Top    = $AccountActivityCheckbox.Top + $AccountActivityCheckbox.Height
    Width  = $FormScale * 200
    Height = $FormScale * 22
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
        if (Test-Path "$PoShHome\Account Data.csv") {
            Import-Csv "$PoShHome\Account Data.csv" | Out-GridView -Title 'PoSh-EasyWin Select Accounts' -PassThru | Set-Variable -Name AccountCsvData
            $AccountActivityTextbox.lines = ''
            foreach ($Account in $AccountCsvData) { $AccountActivityTextbox.lines += $Account.Name}
        }
        else {
            [System.Windows.Forms.MessageBox]::Show("No Account Information available...`nImport account info from the Import Data tab.",'PoSh-EasyWin Select Accounts')
        }
    }
}
$Section1AccountsTab.Controls.Add($AccountActivitySelectionButton)
CommonButtonSettings -Button $AccountActivitySelectionButton


$AccountActivityClearButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Clear"
    Left   = $FormScale * 136
    Top    = $AccountActivityLabel.Top + $AccountActivityLabel.Height
    Width  = $FormScale * 75
    Height = $FormScale * 20
    Add_Click = { $AccountActivityTextbox.Text = "" }
}
$Section1AccountsTab.Controls.Add($AccountActivityClearButton)
CommonButtonSettings -Button $AccountActivityClearButton


$AccountActivityTextbox = New-Object System.Windows.Forms.TextBox -Property @{
    Lines  = 'Default is All Accounts'
    Left   = $FormScale * 5
    Top    = $AccountActivityClearButton.Top + $AccountActivityClearButton.Height + $($FormScale * 5)
    Width  = $FormScale * 205
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
