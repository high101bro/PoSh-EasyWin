
$Section2OptionsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text = "Options"
    Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
}
$MainCenterTabControl.Controls.Add($Section2OptionsTab)


$OptionTextToSpeachButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Resize PoSh-EasyWin"
    Left   = $FormScale * 3
    Top    = $FormScale * 3
    Width  = $FormScale * 175
    Height = $FormScale * $Column3BoxHeight
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click = {
        Launch-FormScaleGUI -Relaunch
        If ($script:RelaunchEasyWin){
            $PoSHEasyWin.Close()
            Start-Process PowerShell.exe -Verb runAs -ArgumentList $ThisScript
        }
    }
}
# Cmdlet Parameter Option
if ($AudibleCompletionMessage) {$OptionTextToSpeachCheckBox.Checked = $True}
$Section2OptionsTab.Controls.Add($OptionTextToSpeachButton)
CommonButtonSettings -Button $OptionTextToSpeachButton


$OptionViewReadMeButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "View Read Me"
    Left   = $OptionTextToSpeachButton.Left + $OptionTextToSpeachButton.Width + ($FormScale * 5)
    Top    = $OptionTextToSpeachButton.Top
    Width  = $FormScale * 175
    Height = $FormScale * $Column3BoxHeight
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click = { Launch-ReadMe -ReadMe }
}
$Section2OptionsTab.Controls.Add($OptionViewReadMeButton)
CommonButtonSettings -Button $OptionViewReadMeButton


$OptionSearchComputersForPreviouslyCollectedDataProcessesGroupBox = New-Object System.Windows.Forms.Groupbox -Property @{
    Text   = "Search Endpoints for Previously Collected Data"
    Top    = $OptionTextToSpeachButton.Top + $OptionTextToSpeachButton.Height + $($FormScale * 5)
    Left   = $FormScale * 3 
    Width  = $FormScale * 352
    Height = $FormScale * 100
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
}
            Load-Code "$Dependencies\Code\System.Windows.Forms\ComboBox\CollectedDataDirectorySearchLimitComboBox.ps1"
            . "$Dependencies\Code\System.Windows.Forms\ComboBox\CollectedDataDirectorySearchLimitComboBox.ps1"
            $CollectedDataDirectorySearchLimitComboBox = New-Object System.Windows.Forms.Combobox -Property @{
                Text   = 50
                Left   = $FormScale * 10
                Top    = $FormScale * 15
                Width  = $FormScale * 50
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                Add_MouseHover = $CollectedDataDirectorySearchLimitComboBoxAdd_MouseHover
                Add_SelectedIndexChanged = { $This.Text | Set-Content "$PoShHome\Settings\Directory Search Limit.txt" -Force }
            }
            $NumberOfDirectoriesToSearchBack = @(25,50,100,150,200,250,500,750,1000)
            ForEach ($Item in $NumberOfDirectoriesToSearchBack) { $CollectedDataDirectorySearchLimitComboBox.Items.Add($Item) }
            if (Test-Path "$PoShHome\Settings\Directory Search Limit.txt") { $CollectedDataDirectorySearchLimitComboBox.text = Get-Content "$PoShHome\Settings\Directory Search Limit.txt" }
            $OptionSearchComputersForPreviouslyCollectedDataProcessesGroupBox.Controls.Add($CollectedDataDirectorySearchLimitCombobox)


            $CollectedDataDirectorySearchLimitLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Number of Past Directories to Search"
                Left   = $CollectedDataDirectorySearchLimitCombobox.Size.Width + $($FormScale * 10)
                Top    = $CollectedDataDirectorySearchLimitCombobox.Top + $($FormScale + 3)
                Width  = $FormScale * 200
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            }
            $OptionSearchComputersForPreviouslyCollectedDataProcessesGroupBox.Controls.Add($CollectedDataDirectorySearchLimitLabel)


            $OptionSearchProcessesCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
                Text    = "Processes"
                Left    = $FormScale * 10
                Top     = $CollectedDataDirectorySearchLimitLabel.Top + $CollectedDataDirectorySearchLimitLabel.Height
                Width   = $FormScale * 200
                Height  = $FormScale * 20
                Enabled = $true
                Checked = $False
                Font    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                Add_Click = { $This.Checked | Set-Content "$PoShHome\Settings\Search - Processes Checkbox.txt" -Force }
            }
            if (Test-Path "$PoShHome\Settings\Search - Processes Checkbox.txt") { $OptionSearchProcessesCheckBox.Checked = Get-Content "$PoShHome\Settings\Search - Processes Checkbox.txt" }
            $OptionSearchComputersForPreviouslyCollectedDataProcessesGroupBox.Controls.Add($OptionSearchProcessesCheckBox)


            $OptionSearchServicesCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
                Text    = "Services"
                Left    = $FormScale * 10
                Top     = $OptionSearchProcessesCheckBox.Top + $OptionSearchProcessesCheckBox.Height
                Width   = $FormScale * 200
                Height  = $FormScale * 20
                Enabled = $true
                Checked = $False
                Font    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                Add_Click = { $This.Text | Set-Content "$PoShHome\Settings\Search - Services Checkbox.txt" -Force }
            }
            if (Test-Path "$PoShHome\Settings\Search - Services Checkbox.txt") { $OptionSearchServicesCheckBox.Checked = Get-Content "$PoShHome\Settings\Search - Services Checkbox.txt" }
            $OptionSearchComputersForPreviouslyCollectedDataProcessesGroupBox.Controls.Add($OptionSearchServicesCheckBox)


            $OptionSearchNetworkTCPConnectionsCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
                Text    = "Network TCP Connections"
                Left    = $FormScale * 10
                Top     = $OptionSearchServicesCheckBox.Top + $OptionSearchServicesCheckBox.Height - $($FormScale + 1)
                Width   = $FormScale * 200
                Height  = $FormScale * 20
                Enabled = $true
                Checked = $False
                Font    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                Add_Click = { $This.Text | Set-Content "$PoShHome\Settings\Search - Network TCP Connections Checkbox.txt" -Force }
            }
            if (Test-Path "$PoShHome\Settings\Search - Network TCP Connections Checkbox.txt") { $OptionSearchNetworkTCPConnectionsCheckBox.Checked = Get-Content "$PoShHome\Settings\Search - Network TCP Connections Checkbox.txt" }
            $OptionSearchComputersForPreviouslyCollectedDataProcessesGroupBox.Controls.Add($OptionSearchNetworkTCPConnectionsCheckBox)
$Section2OptionsTab.Controls.Add($OptionSearchComputersForPreviouslyCollectedDataProcessesGroupBox)


$script:OptionMonitorJobsDefaultRestartTimeCombobox = New-Object System.Windows.Forms.Combobox -Property @{
    Text   = 60
    Left   = $FormScale * 3
    Top    = $OptionSearchComputersForPreviouslyCollectedDataProcessesGroupBox.Top + $OptionSearchComputersForPreviouslyCollectedDataProcessesGroupBox.Height + $($FormScale + 2)
    Width  = $FormScale * 50
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_SelectedIndexChanged = { $This.Text | Set-Content "$PoShHome\Settings\Monitor Jobs Default Restart Time.txt" -Force }
}
$MonitorJobDefaultRestartTimesAvailable = @(1,5,10,15,30,60,120,300,600,1800,3600)
ForEach ($Item in $MonitorJobDefaultRestartTimesAvailable) { $script:OptionMonitorJobsDefaultRestartTimeCombobox.Items.Add($Item) }
if (Test-Path "$PoShHome\Settings\Monitor Jobs Default Restart Time.txt") { $script:OptionMonitorJobsDefaultRestartTimeCombobox.text = Get-Content "$PoShHome\Settings\Monitor Jobs Default Restart Time.txt" }
$Section2OptionsTab.Controls.Add($script:OptionMonitorJobsDefaultRestartTimeCombobox)


$OptionMonitorJobsDefaultRestartTimeLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Monitor Jobs Default Restart Time"
    Left   = $script:OptionMonitorJobsDefaultRestartTimeCombobox.Left + $script:OptionMonitorJobsDefaultRestartTimeCombobox.Width + $($FormScale + 5)
    Top    = $script:OptionMonitorJobsDefaultRestartTimeCombobox.Top + $($FormScale + 3)
    Width  = $FormScale * 200
    Height = $FormScale * 18
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section2OptionsTab.Controls.Add($OptionMonitorJobsDefaultRestartTimeLabel)


Load-Code "$Dependencies\Code\System.Windows.Forms\Combobox\OptionStatisticsUpdateIntervalComboBox.ps1"
. "$Dependencies\Code\System.Windows.Forms\Combobox\OptionStatisticsUpdateIntervalComboBox.ps1"
$OptionStatisticsUpdateIntervalCombobox = New-Object System.Windows.Forms.Combobox -Property @{
    Text   = 5
    Left   = $FormScale * 3
    Top    = $script:OptionMonitorJobsDefaultRestartTimeCombobox.Top + $script:OptionMonitorJobsDefaultRestartTimeCombobox.Height + $($FormScale + 2)
    Width  = $FormScale * 50
    Height = $FormScale * 22 
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_MouseHover = $OptionStatisticsUpdateIntervalComboboxAdd_MouseHover
    Add_SelectedIndexChanged = { $This.Text | Set-Content "$PoShHome\Settings\Statistics Update Interval.txt" -Force }
}
$StatisticsTimesAvailable = @(1,5,10,15,30,45,60)
ForEach ($Item in $StatisticsTimesAvailable) { $OptionStatisticsUpdateIntervalCombobox.Items.Add($Item) }
if (Test-Path "$PoShHome\Settings\Statistics Update Interval.txt") { $OptionStatisticsUpdateIntervalCombobox.text = Get-Content "$PoShHome\Settings\Statistics Update Interval.txt" }
$Section2OptionsTab.Controls.Add($OptionStatisticsUpdateIntervalCombobox)


$OptionStatisticsUpdateIntervalLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Statistics Update Interval"
    Left   = $OptionStatisticsUpdateIntervalCombobox.Left + $OptionStatisticsUpdateIntervalCombobox.Width + $($FormScale + 5)
    Top    = $OptionStatisticsUpdateIntervalCombobox.Top + $($FormScale + 3)
    Width  = $FormScale * 200
    Height = $FormScale * 18
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section2OptionsTab.Controls.Add($OptionStatisticsUpdateIntervalLabel)


Load-Code "$Dependencies\Code\System.Windows.Forms\CheckBox\OptionGUITopWindowCheckBox.ps1"
. "$Dependencies\Code\System.Windows.Forms\CheckBox\OptionGUITopWindowCheckBox.ps1"
$OptionGUITopWindowCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
    Text    = "GUI always on top"
    Left    = $FormScale * 3
    Top     = $OptionStatisticsUpdateIntervalLabel.Top + $OptionStatisticsUpdateIntervalLabel.Height + $($FormScale + 2)
    Width   = $FormScale * 300
    Height  = $FormScale * $Column3BoxHeight
    Enabled = $true
    Checked = $false
    Font    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click = $OptionGUITopWindowCheckBoxAdd_Click
}
if (Test-Path "$PoShHome\Settings\GUI Top Most Window.txt") { $OptionGUITopWindowCheckBox.checked = Get-Content "$PoShHome\Settings\GUI Top Most Window.txt" }
$Section2OptionsTab.Controls.Add( $OptionGUITopWindowCheckBox )


Load-Code "$Dependencies\Code\System.Windows.Forms\Checkbox\OptionsAutoSaveChartsAsImages.ps1"
. "$Dependencies\Code\System.Windows.Forms\Checkbox\OptionsAutoSaveChartsAsImages.ps1"
$OptionsAutoSaveChartsAsImages = New-Object System.Windows.Forms.Checkbox -Property @{
    Text    = "Autosave Charts As Images"
    Left    = $FormScale * 3
    Top     = $OptionGUITopWindowCheckBox.Top + $OptionGUITopWindowCheckBox.Height
    Width   = $FormScale * 300
    Height  = $FormScale * $Column3BoxHeight
    Enabled = $true
    Checked = $false
    Font    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click      = $OptionsAutoSaveChartsAsImagesAdd_Click
    Add_MouseHover = $OptionsAutoSaveChartsAsImagesAdd_MouseHover
}
if (Test-Path "$PoShHome\Settings\Auto Save Charts As Images.txt") { $OptionsAutoSaveChartsAsImages.Checked = Get-Content "$PoShHome\Settings\Auto Save Charts As Images.txt" }
$Section2OptionsTab.Controls.Add( $OptionsAutoSaveChartsAsImages )


$OptionShowToolTipCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
    Text    = "Show ToolTip"
    Left    = $FormScale * 3
    Top     = $OptionsAutoSaveChartsAsImages.Top + $OptionsAutoSaveChartsAsImages.Height
    Width   = $FormScale * 200
    Height  = $FormScale * $Column3BoxHeight
    Enabled = $true
    Checked = $True
    Font    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click = { $This.Checked | Set-Content "$PoShHome\Settings\Show Tool Tip.txt" -Force }
}
if (Test-Path "$PoShHome\Settings\Show Tool Tip.txt") { $OptionShowToolTipCheckBox.Checked = Get-Content "$PoShHome\Settings\Show Tool Tip.txt" }
$Section2OptionsTab.Controls.Add($OptionShowToolTipCheckBox)


$OptionTextToSpeachCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
    Text    = "Audible Completion Message"
    Left    = $FormScale * 3
    Top     = $OptionShowToolTipCheckBox.Top + $OptionShowToolTipCheckBox.Height
    Width   = $FormScale * 200
    Height  = $FormScale * $Column3BoxHeight
    Enabled = $true
    Checked = $false
    Font    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click = { $This.Checked | Set-Content "$PoShHome\Settings\Audible Completion Message.txt" -Force }
}
if (Test-Path "$PoShHome\Settings\Audible Completion Message.txt") { $OptionTextToSpeachCheckBox.checked = Get-Content "$PoShHome\Settings\Audible Completion Message.txt" }
if ($AudibleCompletionMessage) {$OptionTextToSpeachCheckBox.Checked = $True}
$Section2OptionsTab.Controls.Add($OptionTextToSpeachCheckBox)


$OptionPacketKeepEtlCabFilesCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
    Text    = "Packet Captures - Keep .etc & .cab files"
    Left    = $FormScale * 3
    Top     = $OptionTextToSpeachCheckBox.Top + $OptionTextToSpeachCheckBox.Height
    Width   = $FormScale * 250
    Height  = $FormScale * $Column3BoxHeight
    Enabled = $true
    Checked = $false
    Font    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click = { $This.Checked | Set-Content "$PoShHome\Settings\Packet Captures - Keep etl and cab files.txt" -Force }
}
if (Test-Path "$PoShHome\Settings\Packet Captures - Keep etl and cab files.txt") { $OptionPacketKeepEtlCabFilesCheckBox.checked = Get-Content "$PoShHome\Settings\Packet Captures - Keep etl and cab files.txt" }
$Section2OptionsTab.Controls.Add($OptionPacketKeepEtlCabFilesCheckBox)


$OptionKeepResultsByEndpointsFilesCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
    Text    = "Individual Execution - Keep Results by Endpoints"
    Left    = $FormScale * 3
    Top     = $OptionPacketKeepEtlCabFilesCheckBox.Top + $OptionPacketKeepEtlCabFilesCheckBox.Height
    Width   = $FormScale * 300
    Height  = $FormScale * $Column3BoxHeight
    Enabled = $true
    Checked = $true
    Font    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click = { $This.Checked | Set-Content "$PoShHome\Settings\Individual Execution - Keep Results by Endpoints.txt" -Force }
}
if (Test-Path "$PoShHome\Settings\Individual Execution - Keep Results by Endpoints.txt") { $OptionKeepResultsByEndpointsFilesCheckBox.checked = Get-Content "$PoShHome\Settings\Individual Execution - Keep Results by Endpoints.txt" }
$Section2OptionsTab.Controls.Add($OptionKeepResultsByEndpointsFilesCheckBox)
