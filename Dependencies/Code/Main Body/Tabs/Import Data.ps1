
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
