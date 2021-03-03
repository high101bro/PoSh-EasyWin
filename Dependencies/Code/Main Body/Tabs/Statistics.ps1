
$Section2StatisticsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text                    = "Statistics"
    Font                    = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
    UseVisualStyleBackColor = $True
}
$MainCenterTabControl.Controls.Add($Section2StatisticsTab)

# Gets various statistics on PoSh-EasyWin such as number of queries and computer treenodes selected, and
# the number number of csv files and data storage consumed
Load-Code "$Dependencies\Code\Execution\Get-PoShEasyWinStatistics.ps1"
. "$Dependencies\Code\Execution\Get-PoShEasyWinStatistics.ps1"
$StatisticsResults = Get-PoShEasyWinStatistics


Load-Code "$Dependencies\Code\System.Windows.Forms\Button\StatisticsRefreshButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\StatisticsRefreshButton.ps1"
$StatisticsRefreshButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Refresh"
    Location = @{ X = $FormScale * 2
                  Y = $FormScale * 5 }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Add_Click = $StatisticsRefreshButtonAdd_Click
}
$Section2StatisticsTab.Controls.Add($StatisticsRefreshButton)
CommonButtonSettings -Button $StatisticsRefreshButton


Load-Code "$Dependencies\Code\System.Windows.Forms\Button\StatisticsViewLogButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\StatisticsViewLogButton.ps1"
$StatisticsViewLogButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "View Log"
    Location = @{ X = $FormScale * 258
                  Y = $FormScale * 5 }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Add_Click      = $StatisticsViewLogButtonAdd_Click
    Add_MouseHover = $StatisticsViewLogButtonAdd_MouseHover
}
$Section2StatisticsTab.Controls.Add($StatisticsViewLogButton)
CommonButtonSettings -Button $StatisticsViewLogButton


$StatisticsNumberOfCSVs = New-Object System.Windows.Forms.Textbox -Property @{
    Text       = $StatisticsResults
    Location = @{ X = $FormScale * 3
                  Y = $FormScale * 32 }
    Size     = @{ Width  = $FormScale * 354
                  Height = $FormScale * 215 }
    Font       = New-Object System.Drawing.Font("Courier new",$($FormScale * 11),0,0,0)
    Multiline  = $true
    Enabled    = $true
}
$Section2StatisticsTab.Controls.Add($StatisticsNumberOfCSVs)
