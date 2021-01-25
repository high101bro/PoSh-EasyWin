
$SmithAccountsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = "Accounts"
    Left   = $FormScale * $Column1RightPosition
    Top    = $FormScale * $Column1DownPosition
    Width  = $FormScale * $Column1BoxWidth
    Height = $FormScale * $Column1BoxHeight
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
}
$MainLeftSMITHTabControl.Controls.Add($SmithAccountsTab)


$SmithAccountsMainLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Accounts can be obtained from workstations and servers."
    Left   = $FormScale * 5
    Top    = $FormScale * 5
    Width  = $FormScale * 410
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Black"
}
$SmithAccountsTab.Controls.Add($SmithAccountsMainLabel)


$SmithAccountsCurrentlyLoggedInConsoleCheckbox  = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Accounts Logged In via Console"
    Left   = $FormScale * 5
    Top    = $SmithAccountsMainLabel.Top + $SmithAccountsMainLabel.Height
    Width  = $FormScale * 325
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
}
$SmithAccountsTab.Controls.Add($SmithAccountsCurrentlyLoggedInConsoleCheckbox)


$SmithAccountsCurrentlyLoggedInInfoButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Reference"
    Left   = $SmithAccountsCurrentlyLoggedInConsoleCheckbox.Left + $SmithAccountsCurrentlyLoggedInConsoleCheckbox.Width + ($FormScale * 22)
    Top    = $SmithAccountsCurrentlyLoggedInConsoleCheckbox.Top #- ($FormScale * 9)
    Width  = $FormScale * 75
    Height = $FormScale * 20
    Add_Click = {
        if (Test-Path "$Dependencies\Reference Account Information.csv") {
            Import-Csv "$Dependencies\Reference Account Information.csv" | Out-GridView -Title 'PoSh-EasyWin - General Account Information'
        }
        else {[System.Windows.Forms.MessageBox]::Show("The General Account Information file for reference cannot be located.",'PoSh-EasyWin Select Accounts')}
     }
}
$SmithAccountsTab.Controls.Add($SmithAccountsCurrentlyLoggedInInfoButton)
CommonButtonSettings -Button $SmithAccountsCurrentlyLoggedInInfoButton


$SmithAccountsCurrentlyLoggedInPSSessionCheckbox  = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Accounts Logged In via PowerShell Session"
    Left   = $FormScale * 7
    Top    = $SmithAccountsCurrentlyLoggedInConsoleCheckbox.Top + $SmithAccountsCurrentlyLoggedInConsoleCheckbox.Height + $($FormScale * 10)
    Width  = $FormScale * 350
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
}
$SmithAccountsTab.Controls.Add($SmithAccountsCurrentlyLoggedInPSSessionCheckbox)


$SmithAccountsCurrentlyLoggedInPSSessionLabel  = New-Object System.Windows.Forms.Label -Property @{
    Text   = "With WinRM Sessions, your account should also show up in these results."
    Left   = $FormScale * 7
    Top    = $SmithAccountsCurrentlyLoggedInPSSessionCheckbox.Top + $SmithAccountsCurrentlyLoggedInPSSessionCheckbox.Height
    Width  = $FormScale * 400
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = "Black"
    Add_MouseHover = $SmithAccountsMaximumCollectionLabelAdd_MouseHover
}
$SmithAccountsTab.Controls.Add($SmithAccountsCurrentlyLoggedInPSSessionLabel)


$SmithAccountActivityCheckbox  = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Account Logon Activity"
    Left   = $FormScale * 7
    Top    = $SmithAccountsCurrentlyLoggedInPSSessionLabel.Top + $SmithAccountsCurrentlyLoggedInPSSessionLabel.Height + $($FormScale * 10)
    Width  = $FormScale * 410
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
}
$SmithAccountsTab.Controls.Add($SmithAccountActivityCheckbox)


$SmithAccountActivityLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Enter Account Names; One Per Line"
    Left   = $FormScale * 5
    Top    = $SmithAccountActivityCheckbox.Top + $SmithAccountActivityCheckbox.Height
    Width  = $FormScale * 200
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = "Black"
}
$SmithAccountsTab.Controls.Add($SmithAccountActivityLabel)


$SmithAccountActivitySelectionButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Select Accounts"
    Left   = $FormScale * 4
    Top    = $SmithAccountActivityLabel.Top + $SmithAccountActivityLabel.Height
    Width  = $FormScale * 125
    Height = $FormScale * 20
    Add_Click = {
        if (Test-Path "$PoShHome\Account Data.csv") {
            Import-Csv "$PoShHome\Account Data.csv" | Out-GridView -Title 'PoSh-EasyWin Select Accounts' -PassThru | Set-Variable -Name AccountCsvData
            $SmithAccountActivityTextbox.lines = ''
            foreach ($SmithAccount in $SmithAccountCsvData) { $SmithAccountActivityTextbox.lines += $SmithAccount.Name}
        }
        else {
            [System.Windows.Forms.MessageBox]::Show("No Account Information available...`nImport account info from the Import Data tab.",'PoSh-EasyWin Select Accounts')
        }
    }
}
$SmithAccountsTab.Controls.Add($SmithAccountActivitySelectionButton)
CommonButtonSettings -Button $SmithAccountActivitySelectionButton


$SmithAccountActivityClearButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Clear"
    Left   = $FormScale * 136
    Top    = $SmithAccountActivityLabel.Top + $SmithAccountActivityLabel.Height
    Width  = $FormScale * 75
    Height = $FormScale * 20
    Add_Click = { $SmithAccountActivityTextbox.Text = "" }
}
$SmithAccountsTab.Controls.Add($SmithAccountActivityClearButton)
CommonButtonSettings -Button $SmithAccountActivityClearButton


$SmithAccountActivityTextbox = New-Object System.Windows.Forms.TextBox -Property @{
    Lines  = 'Default is All Accounts'
    Left   = $FormScale * 5
    Top    = $SmithAccountActivityClearButton.Top + $SmithAccountActivityClearButton.Height + $($FormScale * 5)
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
$SmithAccountsTab.Controls.Add($SmithAccountActivityTextbox)
