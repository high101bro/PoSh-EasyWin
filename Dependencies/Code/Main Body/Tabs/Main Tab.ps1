
$MainCenterMainTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text = "Main"
    Name = "Main"
    Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
}
$MainCenterTabControl.Controls.Add($MainCenterMainTab)

$Column3RightPosition     = 3
$Column3DownPosition      = 11
$Column3BoxHeight         = 22
$Column3DownPositionShift = 26

$DefaultSingleHostIPText = "<Type In A Hostname / IP>"


# This checkbox highlights when selecting computers from the ComputerList
Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Checkbox\SingleHostIPCheckBox.ps1"
. "$Dependencies\Code\System.Windows.Forms\Checkbox\SingleHostIPCheckBox.ps1"
$script:SingleHostIPCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
    Text      = "Query A Single Endpoint:"
    Location  = @{ X = $FormScale * 3
                   Y = $FormScale * 11 }
    Size      = @{ Width  = $FormScale * 210
                   Height = $FormScale * $Column3BoxHeight }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
    Forecolor = 'Blue'
    Enabled   = $true
    Add_Click      = $SingleHostIPCheckBoxAdd_Click
    Add_MouseHover = $SingleHostIPCheckBoxAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($script:SingleHostIPCheckBox)

$Column3DownPosition += $Column3DownPositionShift


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\TextBox\SingleHostIPTextBox.ps1"
. "$Dependencies\Code\System.Windows.Forms\TextBox\SingleHostIPTextBox.ps1"
$script:SingleHostIPTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Text     = $DefaultSingleHostIPText
    Location = @{ X = $FormScale * $Column3RightPosition
                  Y = $FormScale * $Column3DownPosition + 1 }
    Size     = @{ Width  = $FormScale * 235
                  Height = $FormScale * $Column3BoxHeight }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_KeyDown    = $SingleHostIPTextBoxAdd_KeyDown
    Add_MouseHover = $SingleHostIPTextBoxAdd_MouseHover
    Add_MouseEnter = $SingleHostIPTextBoxAdd_MouseEnter
    Add_MouseLeave = $SingleHostIPTextBoxAdd_MouseLeave
}
$MainCenterMainTab.Controls.Add($script:SingleHostIPTextBox)


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\SingleHostIPAddButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\SingleHostIPAddButton.ps1"
$SingleHostIPAddButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Add To List"
    Location = @{ X = $FormScale * ($Column3RightPosition + 240)
                  Y = $FormScale * $Column3DownPosition }
    Size     = @{ Width  = $FormScale * 115
                  Height = $FormScale * $Column3BoxHeight }
    Add_Click      = $SingleHostIPAddButtonAdd_Click
    Add_MouseHover = $SingleHostIPAddButtonAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($SingleHostIPAddButton)
CommonButtonSettings -Button $SingleHostIPAddButton

$Column3DownPosition += $Column3DownPositionShift
$Column3DownPosition += $Column3DownPositionShift - 3


$DirectoryListLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = "Results Folder:"
    Location  = @{ X = $FormScale * $Column3RightPosition
                   Y = $SingleHostIPAddButton.Location.Y + $SingleHostIPAddButton.Size.Height + $($FormScale * 30) }
    Size      = @{ Width  = $FormScale * 120
                   Height = $FormScale * 22 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
    ForeColor = "Blue"
}
$MainCenterMainTab.Controls.Add($DirectoryListLabel)


# This shows the name of the directy that data will be currently saved to
Update-FormProgress "$Dependencies\Code\System.Windows.Forms\TextBox\CollectionSavedDirectoryTextBox.ps1"
. "$Dependencies\Code\System.Windows.Forms\TextBox\CollectionSavedDirectoryTextBox.ps1"
$script:CollectionSavedDirectoryTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Name     = "Saved Directory List Box"
    Text    = $SaveDirectory
    Location = @{ X = $FormScale * $Column3RightPosition
                  Y = $DirectoryListLabel.Location.Y + $DirectoryListLabel.Size.Height }
    Size     = @{ Width  = $FormScale * 354
                  Height = $FormScale * 22 }
    WordWrap = $false
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
    Text     = "Open Folder"
    Location = @{ X = $FormScale * ($Column3RightPosition + 120)
                  Y = $script:CollectionSavedDirectoryTextBox.Location.Y + $script:CollectionSavedDirectoryTextBox.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 115
                  Height = $FormScale * $Column3BoxHeight }
    Add_Click      = $DirectoryOpenButtonAdd_Click
    Add_MouseHover = $DirectoryOpenButtonAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($DirectoryOpenButton)
CommonButtonSettings -Button $DirectoryOpenButton


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\DirectoryUpdateButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\DirectoryUpdateButton.ps1"
$DirectoryUpdateButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "New Timestamp"
    Location = @{ X = $DirectoryOpenButton.Location.X + $DirectoryOpenButton.Size.Width + $($FormScale * 5)
                  Y = $DirectoryOpenButton.Location.Y }
    Size     = @{ Width  = $FormScale * 115
                  Height = $FormScale * $Column3BoxHeight }
    Add_Click      = $DirectoryUpdateButtonAdd_Click
    Add_MouseHover = $DirectoryUpdateButtonAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($DirectoryUpdateButton)
CommonButtonSettings -Button $DirectoryUpdateButton


$ResultsSectionLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = "Analyst Options:"
    Location  = @{ X = $FormScale * 2
                   Y = $DirectoryUpdateButton.Location.Y + $DirectoryUpdateButton.Size.Height + $($FormScale * 15) }
    Size      = @{ Width  = $FormScale * 230
                   Height = $FormScale * $Column3BoxHeight }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
    ForeColor = "Blue"
}
$MainCenterMainTab.Controls.Add($ResultsSectionLabel)


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\PSWriteHTMLButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\PSWriteHTMLButton.ps1"
$PSWriteHTMLButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Graph Data [Beta]"
    Location = @{ X = $ResultsSectionLabel.Location.X
                  Y = $ResultsSectionLabel.Location.Y + $ResultsSectionLabel.Size.Height }
    Size     = @{ Width  = $FormScale * 115
                  Height = $FormScale * 22 }
    Add_Click      = $PSWriteHTMLButtonAdd_Click
    Add_MouseHover = $PSWriteHTMLButtonAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($PSWriteHTMLButton)
CommonButtonSettings -Button $PSWriteHTMLButton
#if ((Get-Content "$PoShHome\Settings\PSWriteHTML Module Install.txt") -match 'No') { $PSWriteHTMLButton.enabled = $false }


Update-FormProgress "$Dependencies\Code\Charts\Generate-AutoChartsCommand.ps1"
. "$Dependencies\Code\Charts\Generate-AutoChartsCommand.ps1"
Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\AutoCreateMultiSeriesChartButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\AutoCreateMultiSeriesChartButton.ps1"
$AutoCreateMultiSeriesChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Multi-Series Charts"
    Location = @{ X = $PSWriteHTMLButton.Location.X + $PSWriteHTMLButton.Size.Width + $($FormScale * 5)
                  Y = $PSWriteHTMLButton.Location.Y }
    Size     = @{ Width  = $FormScale * 115
                  Height = $FormScale * 22 }
    Add_Click = $AutoCreateMultiSeriesChartButtonAdd_Click
    Add_MouseHover = $AutoCreateMultiSeriesChartButtonAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($AutoCreateMultiSeriesChartButton)
CommonButtonSettings -Button $AutoCreateMultiSeriesChartButton


# This is placed here as the code is used with the "Open Data In Shell" button in the main form as well as within the dashboards
Update-FormProgress "$Dependencies\Code\Main Body\Open-XmlResultsInShell.ps1"
. "$Dependencies\Code\Main Body\Open-XmlResultsInShell.ps1"

# Code to allow the dashboards to update upon request
Update-FormProgress "$Dependencies\Code\Charts\Update-AutoChartsActiveDirectoryComputers.ps1"
. "$Dependencies\Code\Charts\Update-AutoChartsActiveDirectoryComputers.ps1"
Update-FormProgress "$Dependencies\Code\Charts\Update-AutoChartsActiveDirectoryGroups.ps1"
. "$Dependencies\Code\Charts\Update-AutoChartsActiveDirectoryGroups.ps1"
Update-FormProgress "$Dependencies\Code\Charts\Update-AutoChartsActiveDirectoryUserAccounts.ps1"
. "$Dependencies\Code\Charts\Update-AutoChartsActiveDirectoryUserAccounts.ps1"
Update-FormProgress "$Dependencies\Code\Charts\Update-AutoChartsApplicationCrashes.ps1"
. "$Dependencies\Code\Charts\Update-AutoChartsApplicationCrashes.ps1"
Update-FormProgress "$Dependencies\Code\Charts\Update-AutoChartsDeepBlueAll.ps1"
. "$Dependencies\Code\Charts\Update-AutoChartsDeepBlueAll.ps1"
Update-FormProgress "$Dependencies\Code\Charts\Update-AutoChartsDeepBlue7Days.ps1"
. "$Dependencies\Code\Charts\Update-AutoChartsDeepBlue7Days.ps1"
Update-FormProgress "$Dependencies\Code\Charts\Update-AutoChartsDeepBlue24Hours.ps1"
. "$Dependencies\Code\Charts\Update-AutoChartsDeepBlue24Hours.ps1"
Update-FormProgress "$Dependencies\Code\Charts\Update-AutoChartsLoginActivity.ps1"
. "$Dependencies\Code\Charts\Update-AutoChartsLoginActivity.ps1"
Update-FormProgress "$Dependencies\Code\Charts\Update-AutoChartsNetworkConnections.ps1"
. "$Dependencies\Code\Charts\Update-AutoChartsNetworkConnections.ps1"
Update-FormProgress "$Dependencies\Code\Charts\Update-AutoChartsNetworkInterfaces.ps1"
. "$Dependencies\Code\Charts\Update-AutoChartsNetworkInterfaces.ps1"
Update-FormProgress "$Dependencies\Code\Charts\Update-AutoChartsProcesses.ps1"
. "$Dependencies\Code\Charts\Update-AutoChartsProcesses.ps1"
Update-FormProgress "$Dependencies\Code\Charts\Update-AutoChartsSecurityPatches.ps1"
. "$Dependencies\Code\Charts\Update-AutoChartsSecurityPatches.ps1"
Update-FormProgress "$Dependencies\Code\Charts\Update-AutoChartsServices.ps1"
. "$Dependencies\Code\Charts\Update-AutoChartsServices.ps1"
Update-FormProgress "$Dependencies\Code\Charts\Update-AutoChartsSoftware.ps1"
. "$Dependencies\Code\Charts\Update-AutoChartsSoftware.ps1"
Update-FormProgress "$Dependencies\Code\Charts\Update-AutoChartsSmbShare.ps1"
. "$Dependencies\Code\Charts\Update-AutoChartsSmbShare.ps1"
Update-FormProgress "$Dependencies\Code\Charts\Update-AutoChartsStartupCommands.ps1"
. "$Dependencies\Code\Charts\Update-AutoChartsStartupCommands.ps1"


# Used to populate the dashboard choices form
Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\AutoCreateDashboardChartButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\AutoCreateDashboardChartButton.ps1"
$AutoCreateDashboardChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Dashboard Charts"
    Location = @{ X = $AutoCreateMultiSeriesChartButton.Location.X + $AutoCreateMultiSeriesChartButton.Size.Width + $($FormScale * 5)
                  Y = $AutoCreateMultiSeriesChartButton.Location.Y }
    Size     = @{ Width  = $FormScale * 115
                  Height = $FormScale * 22 }
    Add_Click      = $AutoCreateDashboardChartButtonAdd_Click
    Add_MouseHover = $AutoCreateDashboardChartButtonAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($AutoCreateDashboardChartButton)
CommonButtonSettings -Button $AutoCreateDashboardChartButton


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\RetrieveFilesButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\RetrieveFilesButton.ps1"
. "$Dependencies\Code\Main Body\Get-RemoteFile.ps1"
$RetrieveFilesButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Retrieve Files"
    Location = @{ X = $PSWriteHTMLButton.Location.X
                  Y = $AutoCreateMultiSeriesChartButton.Location.Y + $AutoCreateMultiSeriesChartButton.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 115
                  Height = $FormScale * 22 }
    Add_Click      = $RetrieveFilesButtonAdd_Click
    Add_MouseHover = $RetrieveFilesButtonAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($RetrieveFilesButton)
CommonButtonSettings -Button $RetrieveFilesButton


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\OpenXmlResultsButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\OpenXmlResultsButton.ps1"
$OpenXmlResultsButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Open Data In Shell"
    Location = @{ X = $AutoCreateMultiSeriesChartButton.Location.X
                  Y = $AutoCreateMultiSeriesChartButton.Location.Y + $AutoCreateMultiSeriesChartButton.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 115
                  Height = $FormScale * 22 }
    Add_Click      = $OpenXmlResultsButtonAdd_Click
    Add_MouseHover = $OpenXmlResultsButtonAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($OpenXmlResultsButton)
CommonButtonSettings -Button $OpenXmlResultsButton


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\OpenCsvResultsButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\OpenCsvResultsButton.ps1"
$OpenCsvResultsButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "View CSV Results"
    Location = @{ X = $AutoCreateDashboardChartButton.Location.X
                  Y = $AutoCreateDashboardChartButton.Location.Y + $AutoCreateDashboardChartButton.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 115
                  Height = $FormScale * 22 }
    Add_Click = $OpenCsvResultsButtonAdd_Click
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
