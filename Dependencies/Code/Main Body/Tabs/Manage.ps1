
$Section3ManageListTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = "Import Data"
    Left   = $FormScale * $Column5RightPosition
    Top    = $FormScale * $Column5DownPosition
    Width  = $FormScale * $Column5BoxWidth
    Height = $FormScale * $Column5BoxHeight
    UseVisualStyleBackColor = $True
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$MainRightTabControl.Controls.Add($Section3ManageListTab)


$ImportEndpointDataLabel = New-Object System.Windows.Forms.RadioButton -Property @{
    Text   = "Endpoint Data"
    Left   = 6
    Top    = 6
    AutoSize  = $true
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = 'Blue'
    Checked   = $True
}
$Section3ManageListTab.Controls.Add($ImportEndpointDataLabel)


Load-Code "$Dependencies\Code\System.Windows.Forms\Button\ImportEndpointDataFromActiveDirectoryButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\ImportEndpointDataFromActiveDirectoryButton.ps1"
$ImportEndpointDataFromActiveDirectoryButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Import from AD"
    Left   = $ImportEndpointDataLabel.Left
    Top    = $ImportEndpointDataLabel.Top + $ImportEndpointDataLabel.Height + ($FormScale * 5)
    Width  = $FormScale * 124
    Height = $FormScale * 22
    Add_Click      = $ImportEndpointDataFromActiveDirectoryButtonAdd_Click
    Add_MouseHover = $ImportEndpointDataFromActiveDirectoryButtonAdd_MouseHover
}
$Section3ManageListTab.Controls.Add($ImportEndpointDataFromActiveDirectoryButton)
CommonButtonSettings -Button $ImportEndpointDataFromActiveDirectoryButton


Load-Code "$Dependencies\Code\System.Windows.Forms\Button\ImportEndpointDataFromCsvButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\ImportEndpointDataFromCsvButton.ps1"
$ImportEndpointDataFromCsvButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Import from .CSV"
    Left   = $ImportEndpointDataFromActiveDirectoryButton.Left
    Top    = $ImportEndpointDataFromActiveDirectoryButton.Top + $ImportEndpointDataFromActiveDirectoryButton.Height + ($FormScale * 10)
    Width  = $FormScale * 124
    Height = $FormScale * 22
    Add_Click      = $ImportEndpointDataFromCsvButtonAdd_Click
    Add_MouseHover = $ImportEndpointDataFromCsvButtonAdd_MouseHover
}
$Section3ManageListTab.Controls.Add($ImportEndpointDataFromCsvButton)
CommonButtonSettings -Button $ImportEndpointDataFromCsvButton


Load-Code "$Dependencies\Code\System.Windows.Forms\Button\ImportEndpointDataFromTxtButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\ImportEndpointDataFromTxtButton.ps1"
$ImportEndpointDataFromTxtButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Import from .TXT"
    Left   = $ImportEndpointDataFromCsvButton.Left
    Top    = $ImportEndpointDataFromCsvButton.Top + $ImportEndpointDataFromCsvButton.Height + ($FormScale * 10)
    Width  = $FormScale * 124
    Height = $FormScale * 22
    Add_Click      = $ImportEndpointDataFromTxtButtonAdd_Click
    Add_MouseHover = $ImportEndpointDataFromTxtButtonAdd_MouseHover
}
$Section3ManageListTab.Controls.Add($ImportEndpointDataFromTxtButton)
CommonButtonSettings -Button $ImportEndpointDataFromTxtButton


Load-Code "$Dependencies\Code\System.Windows.Forms\Button\ComputerTreeNodeSaveButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\ComputerTreeNodeSaveButton.ps1"
$ComputerTreeNodeSaveButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "TreeView`r`nSaved"
    Left   = $ImportEndpointDataFromTxtButton.Left
    Top    = $ImportEndpointDataFromTxtButton.Top + $ImportEndpointDataFromTxtButton.Height + ($FormScale * 10)
    Width  = $FormScale * 124
    Height = $FormScale * (22 * 2) - 10
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click      = $ComputerTreeNodeSaveButtonAdd_Click
    Add_MouseHover = $ComputerTreeNodeSaveButtonAdd_MouseHover
}
$Section3ManageListTab.Controls.Add($ComputerTreeNodeSaveButton)
CommonButtonSettings -Button $ComputerTreeNodeSaveButton


$ImportAccountDataLabel = New-Object System.Windows.Forms.RadioButton -Property @{
    Text   = "Account Data"
    Left   = 6
    Top    = $ComputerTreeNodeSaveButton.Top + $ComputerTreeNodeSaveButton.Height + ($FormScale * 5)
    AutoSize  = $true
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = 'Blue'
    Checked   = $True
}
$Section3ManageListTab.Controls.Add($ImportAccountDataLabel)


Load-Code "$Dependencies\Code\System.Windows.Forms\Button\ImportAccountDataFromActiveDirectoryButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\ImportAccountDataFromActiveDirectoryButton.ps1"
$ImportAccountDataFromActiveDirectoryButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Import from AD"
    Left   = $ImportAccountDataLabel.Left
    Top    = $ImportAccountDataLabel.Top + $ImportAccountDataLabel.Height + ($FormScale * 5)
    Width  = $FormScale * 124
    Height = $FormScale * 22
    Add_Click      = $ImportAccountDataFromActiveDirectoryButtonAdd_Click
    Add_MouseHover = $ImportAccountDataFromActiveDirectoryButtonAdd_MouseHover
}
$Section3ManageListTab.Controls.Add($ImportAccountDataFromActiveDirectoryButton)
CommonButtonSettings -Button $ImportAccountDataFromActiveDirectoryButton


$StatusLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Status:"
    Left   = $FormScale * 470
    Top    = $FormScale * 288
    Width  = $FormScale * 60
    Height = $FormScale * 20
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
}
$PoShEasyWin.Controls.Add($StatusLabel)


$StatusListBox = New-Object System.Windows.Forms.ListBox -Property @{
    Name   = "StatusListBox"
    Left   = $StatusLabel.Location.X + $StatusLabel.Size.Width
    Top    = $StatusLabel.Location.Y
    Width  = $FormScale * 310
    Height = $FormScale * 22
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    FormattingEnabled = $True
}
$StatusListBox.Items.Add("Welcome to PoSh-EasyWin!") | Out-Null
$PoShEasyWin.Controls.Add($StatusListBox)


$ProgressBarEndpointsLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Endpoint:"
    Left   = $StatusLabel.Location.X
    Top    = $StatusLabel.Location.Y + $StatusLabel.Size.Height
    Width  = $StatusLabel.Size.Width
    Height = $StatusLabel.Size.Height
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$PoShEasyWin.Controls.Add($ProgressBarEndpointsLabel)


$script:ProgressBarEndpointsProgressBar = New-Object System.Windows.Forms.ProgressBar -Property @{
    Left   = $ProgressBarEndpointsLabel.Location.X + $ProgressBarEndpointsLabel.Size.Width
    Top    = $ProgressBarEndpointsLabel.Location.Y
    Width  = $StatusListBox.Size.Width - 1
    Height = $FormScale * 15
    Forecolor = 'LightBlue'
    BackColor = 'white'
    Style     = "Continuous" #"Marque"
    Minimum   = 0
}
$PoSHEasyWin.Controls.Add($script:ProgressBarEndpointsProgressBar)


$ProgressBarQueriesLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "Task:"
    Left = $ProgressBarEndpointsLabel.Location.X
    Top = $ProgressBarEndpointsLabel.Location.Y + $ProgressBarEndpointsLabel.Size.Height
    Width  = $ProgressBarEndpointsLabel.Size.Width
    Height = $ProgressBarEndpointsLabel.Size.Height
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$PoShEasyWin.Controls.Add($ProgressBarQueriesLabel)


$script:ProgressBarQueriesProgressBar = New-Object System.Windows.Forms.ProgressBar -Property @{
    Left = $ProgressBarQueriesLabel.Location.X + $ProgressBarQueriesLabel.Size.Width
    Top = $ProgressBarQueriesLabel.Location.Y
    Width  = $StatusListBox.Size.Width - 1
    Height = $FormScale * 15
    Forecolor = 'LightGreen'
    BackColor = 'white'
    Style     = "Continuous"
    Minimum   = 0
}
$PoSHEasyWin.Controls.Add($script:ProgressBarQueriesProgressBar)
