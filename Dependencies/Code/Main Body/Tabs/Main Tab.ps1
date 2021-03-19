
$MainCenterMainTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text = "Main"
    Name = "Main"
    Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
}
$MainCenterTabControl.Controls.Add($MainCenterMainTab)

$DefaultSingleHostIPText = "<Type In A Hostname / IP>"


# This checkbox highlights when selecting computers from the ComputerList
Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Checkbox\SingleHostIPCheckBox.ps1"
. "$Dependencies\Code\System.Windows.Forms\Checkbox\SingleHostIPCheckBox.ps1"
$script:SingleHostIPCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
    Text      = "Query A Single Endpoint:"
    Left      = $FormScale * 3
    Top       = $FormScale * 11
    Width     = $FormScale * 210
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
    Forecolor = 'Blue'
    Enabled   = $true
    Add_Click = $SingleHostIPCheckBoxAdd_Click
    Add_MouseHover = $SingleHostIPCheckBoxAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($script:SingleHostIPCheckBox)


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\TextBox\SingleHostIPTextBox.ps1"
. "$Dependencies\Code\System.Windows.Forms\TextBox\SingleHostIPTextBox.ps1"
$script:SingleHostIPTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Text   = $DefaultSingleHostIPText
    Left   = $script:SingleHostIPCheckBox.Left
    Top    = $script:SingleHostIPCheckBox.Top + $script:SingleHostIPCheckBox.Height + ($FormScale * 2)
    Width  = $FormScale * 235
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_KeyDown    = $SingleHostIPTextBoxAdd_KeyDown
    Add_MouseHover = $SingleHostIPTextBoxAdd_MouseHover
    Add_MouseEnter = $SingleHostIPTextBoxAdd_MouseEnter
    Add_MouseLeave = $SingleHostIPTextBoxAdd_MouseLeave
}
$MainCenterMainTab.Controls.Add($script:SingleHostIPTextBox)


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\SingleHostIPAddButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\SingleHostIPAddButton.ps1"
$SingleHostIPAddButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Add To List"
    Left   = $script:SingleHostIPTextBox.Left + $script:SingleHostIPTextBox.Width + ($FormScale * 5)
    Top    = $script:SingleHostIPTextBox.Top
    Width  = $FormScale * 115
    Height = $FormScale * 22
    Add_Click      = $SingleHostIPAddButtonAdd_Click
    Add_MouseHover = $SingleHostIPAddButtonAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($SingleHostIPAddButton)
CommonButtonSettings -Button $SingleHostIPAddButton


$DirectoryListLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Results Folder:"
    Left   = $script:SingleHostIPTextBox.Left
    Top    = $script:SingleHostIPTextBox.Top + $script:SingleHostIPTextBox.Height + $($FormScale * 28)
    Width  = $FormScale * 120
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
    ForeColor = "Blue"
}
$MainCenterMainTab.Controls.Add($DirectoryListLabel)


# This shows the name of the directy that data will be currently saved to
Update-FormProgress "$Dependencies\Code\System.Windows.Forms\TextBox\CollectionSavedDirectoryTextBox.ps1"
. "$Dependencies\Code\System.Windows.Forms\TextBox\CollectionSavedDirectoryTextBox.ps1"
$script:CollectionSavedDirectoryTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Name   = "Saved Directory List Box"
    Text   = $SaveDirectory
    Left   = $DirectoryListLabel.Left
    Top    = $DirectoryListLabel.Top + $DirectoryListLabel.Height + ($FormScale * 1)
    Width  = $FormScale * 354
    Height = $FormScale * 22
    WordWrap   = $false
    AcceptsTab = $true
    TabStop    = $true
    Multiline  = $false
    AutoSize   = $false
    Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "FileSystem"
    AutoCompleteMode   = "SuggestAppend"
    Add_MouseHover     = $CollectionSavedDirectoryTextBoxAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($script:CollectionSavedDirectoryTextBox)


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\DirectoryOpenButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\DirectoryOpenButton.ps1"
$DirectoryOpenButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Open Folder"
    Left   = $script:CollectionSavedDirectoryTextBox.Left + ($FormScale * 120)
    Top    = $script:CollectionSavedDirectoryTextBox.Top + $script:CollectionSavedDirectoryTextBox.Height + $($FormScale * 5)
    Width  = $FormScale * 115
    Height = $FormScale * 22
    Add_Click      = $DirectoryOpenButtonAdd_Click
    Add_MouseHover = $DirectoryOpenButtonAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($DirectoryOpenButton)
CommonButtonSettings -Button $DirectoryOpenButton


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\DirectoryUpdateButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\DirectoryUpdateButton.ps1"
$DirectoryUpdateButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "New Timestamp"
    Left   = $DirectoryOpenButton.Left + $DirectoryOpenButton.Width + $($FormScale * 5)
    Top    = $DirectoryOpenButton.Top
    Width  = $FormScale * 115
    Height = $FormScale * 22
    Add_Click      = $DirectoryUpdateButtonAdd_Click
    Add_MouseHover = $DirectoryUpdateButtonAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($DirectoryUpdateButton)
CommonButtonSettings -Button $DirectoryUpdateButton


$ResultsSectionLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "File Actions and Analysis:"
    Left   = $CollectionSavedDirectoryTextBox.Left
    Top    = $DirectoryUpdateButton.Top + $DirectoryUpdateButton.Height + $($FormScale * 20)
    Width  = $FormScale * 230
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
    ForeColor = "Blue"
}
$MainCenterMainTab.Controls.Add($ResultsSectionLabel)


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\SendFilesButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\SendFilesButton.ps1"
$SendFilesButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Send Files"
    Left   = $ResultsSectionLabel.Left
    Top    = $ResultsSectionLabel.Top + $ResultsSectionLabel.Height + ($FormScale * 1)
    Width  = $FormScale * 115
    Height = $FormScale * 22
    Add_Click = $SendFilesButtonAdd_Click
}
$MainCenterMainTab.Controls.Add($SendFilesButton)
CommonButtonSettings -Button $SendFilesButton


# batman
# Update-FormProgress "$Dependencies\Code\Charts\Generate-AutoChartsCommand.ps1"
# . "$Dependencies\Code\Charts\Generate-AutoChartsCommand.ps1"
# Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\AutoCreateMultiSeriesChartButton.ps1"
# . "$Dependencies\Code\System.Windows.Forms\Button\AutoCreateMultiSeriesChartButton.ps1"
# $AutoCreateMultiSeriesChartButton = New-Object System.Windows.Forms.Button -Property @{
#     Text   = "Multi-Charts"
#     Left   = $ResultsSectionLabel.Left
#     Top    = $ResultsSectionLabel.Top + $ResultsSectionLabel.Height + ($FormScale * 1)
#     Width  = $FormScale * 115
#     Height = $FormScale * 22
#     Add_Click      = $AutoCreateMultiSeriesChartButtonAdd_Click
#     Add_MouseHover = $AutoCreateMultiSeriesChartButtonAdd_MouseHover
# }
# $MainCenterMainTab.Controls.Add($AutoCreateMultiSeriesChartButton)
# CommonButtonSettings -Button $AutoCreateMultiSeriesChartButton


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\PSWriteHTMLButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\PSWriteHTMLButton.ps1"
$PSWriteHTMLButton = New-Object System.Windows.Forms.Button -Property @{
    Left   = $SendFilesButton.Left + $SendFilesButton.Width + $($FormScale * 5)
    Top    = $SendFilesButton.Top
    Width  = $FormScale * 115
    Height = $FormScale * 22
    Add_Click      = $PSWriteHTMLButtonAdd_Click
    Add_MouseHover = $PSWriteHTMLButtonAdd_MouseHover
    Enabled = $false
}
$MainCenterMainTab.Controls.Add($PSWriteHTMLButton)
CommonButtonSettings -Button $PSWriteHTMLButton
if ((Test-Path -Path "$Dependencies\Modules\PSWriteHTML") -and (Get-Content "$PoShHome\Settings\PSWriteHTML Module Install.txt") -match 'Yes') {
    $PSWriteHTMLButton.enabled = $true
    $PSWriteHTMLButton.Text    = "Graph Data [Beta]"
}

# This is placed here as the code is used with the "Open Data In Shell" button in the main form as well as within the dashboards
Update-FormProgress "$Dependencies\Code\Main Body\script:Open-XmlResultsInShell.ps1"
. "$Dependencies\Code\Main Body\script:Open-XmlResultsInShell.ps1"

# Code to allow the dashboards to update upon request
Update-FormProgress "$Dependencies\Code\Charts\Update-AutoChartsActiveDirectoryComputers.ps1"
. "$Dependencies\Code\Charts\Update-AutoChartsActiveDirectoryComputers.ps1"
Update-FormProgress "$Dependencies\Code\Charts\Update-AutoChartsActiveDirectoryGroups.ps1"
. "$Dependencies\Code\Charts\Update-AutoChartsActiveDirectoryGroups.ps1"
Update-FormProgress "$Dependencies\Code\Charts\Update-AutoChartsActiveDirectoryUserAccounts.ps1"
. "$Dependencies\Code\Charts\Update-AutoChartsActiveDirectoryUserAccounts.ps1"
Update-FormProgress "$Dependencies\Code\Charts\Update-AutoChartsDeepBlueAll.ps1"
. "$Dependencies\Code\Charts\Update-AutoChartsDeepBlueAll.ps1"
Update-FormProgress "$Dependencies\Code\Charts\Update-AutoChartsDeepBlue7Days.ps1"
. "$Dependencies\Code\Charts\Update-AutoChartsDeepBlue7Days.ps1"
Update-FormProgress "$Dependencies\Code\Charts\Update-AutoChartsDeepBlue24Hours.ps1"
. "$Dependencies\Code\Charts\Update-AutoChartsDeepBlue24Hours.ps1"


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\AutoChartSelectChartComboBoxSelectedItem_Monitor-Jobs.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\AutoChartSelectChartComboBoxSelectedItem_Monitor-Jobs.ps1"


# Used to populate the dashboard choices form
Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\AutoCreateDashboardChartButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\AutoCreateDashboardChartButton.ps1"
$AutoCreateDashboardChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Dashboard Charts"
    Left   = $PSWriteHTMLButton.Left + $PSWriteHTMLButton.Width + $($FormScale * 5)
    Top    = $PSWriteHTMLButton.Top
    Width  = $FormScale * 115
    Height = $FormScale * 22
    Add_Click      = $AutoCreateDashboardChartButtonAdd_Click
    Add_MouseHover = $AutoCreateDashboardChartButtonAdd_MouseHover
    Enabled        = $true
}
$MainCenterMainTab.Controls.Add($AutoCreateDashboardChartButton)
CommonButtonSettings -Button $AutoCreateDashboardChartButton


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\RetrieveFilesButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\RetrieveFilesButton.ps1"
Update-FormProgress "$Dependencies\Code\Main Body\Get-RemoteFile.ps1"
. "$Dependencies\Code\Main Body\Get-RemoteFile.ps1"
$RetrieveFilesButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Retrieve Files"
    Left   = $SendFilesButton.Left
    Top    = $SendFilesButton.Top + $SendFilesButton.Height + $($FormScale * 5)
    Width  = $FormScale * 115
    Height = $FormScale * 22
    Add_Click      = $RetrieveFilesButtonAdd_Click
    Add_MouseHover = $RetrieveFilesButtonAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($RetrieveFilesButton)
CommonButtonSettings -Button $RetrieveFilesButton


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\OpenXmlResultsButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\OpenXmlResultsButton.ps1"
$OpenXmlResultsButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Open Data In Shell"
    Left   = $RetrieveFilesButton.Left + $RetrieveFilesButton.Width + $($FormScale * 5)
    Top    = $RetrieveFilesButton.Top
    Width  = $FormScale * 115
    Height = $FormScale * 22
    Add_Click      = $OpenXmlResultsButtonAdd_Click
    Add_MouseHover = $OpenXmlResultsButtonAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($OpenXmlResultsButton)
CommonButtonSettings -Button $OpenXmlResultsButton


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\OpenCsvResultsButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\OpenCsvResultsButton.ps1"
$OpenCsvResultsButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "View CSV Results"
    Left   = $OpenXmlResultsButton.Left + $OpenXmlResultsButton.Width + $($FormScale * 5)
    Top    = $OpenXmlResultsButton.Top
    Width  = $FormScale * 115
    Height = $FormScale * 22
    Add_Click      = $OpenCsvResultsButtonAdd_Click
    Add_MouseHover = $OpenCsvResultsButtonAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($OpenCsvResultsButton)
CommonButtonSettings -Button $OpenCsvResultsButton


# The Launch-ChartImageSaveFileDialog function is use by 'build charts and autocharts'
Update-FormProgress "$Dependencies\Code\Charts\Launch-ChartImageSaveFileDialog.ps1"
. "$Dependencies\Code\Charts\Launch-ChartImageSaveFileDialog.ps1"


# Increases the chart size by 4 then saves it to file
Update-FormProgress "$Dependencies\Code\Charts\Save-ChartImage.ps1"
. "$Dependencies\Code\Charts\Save-ChartImage.ps1"
