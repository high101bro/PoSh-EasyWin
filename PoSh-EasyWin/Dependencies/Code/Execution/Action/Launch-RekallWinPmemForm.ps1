function Launch-RekallWinPmemForm {
    $script:ReportedRAMAmount                = $null
    $script:ReportedDiskSize                 = $null
    $script:ReportedDiskFreeSpace            = $null
    $script:RekalWinPmemDiskPercentageUse    = $null
    $script:RekallWinPmemReportedAverageLoad = $null
    
    function RekallWinPmemStatusCheckUpdate {
        $RekallWinPmemStatusMessageTextbox.Text = $null

        # Update RAM Status
        if ($script:ReportedRAMAmount -gt $RekallWinPmemSettingHowMuchRAMToCollectComboBox.Text ) {
            $RekallWinPmemReportedTotalRAMLabel.Text = $('{0,-40}{1,-20}{2}' -f 'Total RAM Amount:',"$([math]::round($($script:ReportedRAMAmount / 1GB),2)) GB", "Fail")
            $RekallWinPmemStatusMessageTextbox.Text += "[!] The RAM collection SETTING is insufficient`r`n"
        }
        else {
            $RekallWinPmemReportedTotalRAMLabel.Text = $('{0,-40}{1,-20}{2}' -f 'Total RAM Amount:',"$([math]::round($($script:ReportedRAMAmount / 1GB),2)) GB", "Pass")
            $RekallWinPmemStatusMessageTextbox.Text += "[+] Passes RAM mount check`r`n"
        }

        # Update Disk Size Status
        if ($script:ReportedDiskSize -lt $script:ReportedRAMAmount){
            $RekallWinPmemRemoteTotalDiskSpaceLabel.Text = $('{0,-40}{1,-20}{2}' -f 'Total Disk Space:',"$([math]::round($($script:ReportedDiskSize / 1GB),2)) GB", "Fail")
            $RekallWinPmemStatusMessageTextbox.Text += "[!] Endpoint has less disk space than its total RAM`r`n"
        }
        else {
            $RekallWinPmemRemoteTotalDiskSpaceLabel.Text = $('{0,-40}{1,-20}{2}' -f 'Total Disk Space:',"$([math]::round($($script:ReportedDiskSize / 1GB),2)) GB", "Pass")

            $RekallWinPmemStatusMessageTextbox.Text += "[+] Passes disk size check`r`n"
        }            

        # Update Disk Free Space Status
        if ($script:ReportedDiskFreeSpace -lt $RekallWinPmemSettingMinimumAvailbleDiskSpaceComboBox.Text){
            $RekallWinPmemRemoteAvailableDiskSpaceLabel.Text = $('{0,-40}{1,-20}{2}' -f 'Available Disk Space:',"$([math]::round($($script:ReportedDiskFreeSpace  / 1GB),2)) GB", "Fail")
            $RekallWinPmemStatusMessageTextbox.Text += "[!] The available disk space SETTING is insufficient`r`n"
        }
        else {
            $RekallWinPmemRemoteAvailableDiskSpaceLabel.Text = $('{0,-40}{1,-20}{2}' -f 'Available Disk Space:',"$([math]::round($($script:ReportedDiskFreeSpace  / 1GB),2)) GB", "Pass")
            $RekallWinPmemStatusMessageTextbox.Text += "[+] Passes disk free space check`r`n"
        }            

        # Update Disk Utilization Percentage Use Status
        if ( $script:RekalWinPmemDiskPercentageUse -gt 75 ) {
            $RekallWinPmemReportedDiskPercentUsedLabel.Text = $('{0,-40}{1,-20}{2}' -f 'Disk Percentage Used:', "$script:RekalWinPmemDiskPercentageUse %", "Risk")
            $RekallWinPmemStatusMessageTextbox.Text += "[!] Endpoint is using more than 75% of its disk space`r`n"
        }
        else {
            $RekallWinPmemReportedDiskPercentUsedLabel.Text = $('{0,-40}{1,-20}{2}' -f 'Disk Percentage Used:', "$script:RekalWinPmemDiskPercentageUse %", "Okay")
            $RekallWinPmemStatusMessageTextbox.Text += "[+] Passes disk utilization ratio check`r`n"
        }

        # Update the Average Processor Load Status
        if ( $RekalWinPmemAverageLoad -gt 75 ) {
            $RekallWinPmemRemoteCPULevelLabel.Text = $('{0,-40}{1,-20}{2}' -f 'CPU Utilization (10s Avg):', "$([math]::Round($script:RekallWinPmemReportedAverageLoad,2)) %", "Risk")
            $RekallWinPmemStatusMessageTextbox.Text += "[!] Endpoint is using more than 75% of its CPU`r`n"
        }
        else {
            $RekallWinPmemRemoteCPULevelLabel.Text = $('{0,-40}{1,-20}{2}' -f 'CPU Utilitzation (10s Avg):', "$([math]::Round($script:RekallWinPmemReportedAverageLoad,2)) %", "Okay")
            $RekallWinPmemStatusMessageTextbox.Text += "[+] Passes CPU utilization check`r`n"
        }
                     
        $RekallWinPmemCheckRemoteResourcesButton.Text = "Update Status"

        if ($RekallWinPmemReportedTotalRAMLabel.Text -match 'Pass' -and $RekallWinPmemRemoteAvailableDiskSpaceLabel.Text -match 'Pass' -and $RekallWinPmemRemoteTotalDiskSpaceLabel.Text -match 'Pass') {
            if ($RekallWinPmemReportedDiskPercentUsedLabel.Text -match 'Okay' -and $RekallWinPmemRemoteCPULevelLabel.Text -match 'Okay') {
                $RekallWinPmemCollectMemoryButton.Enabled = $true
                $RekallWinPmemCollectMemoryButton.BackColor = 'LightGreen'
                $RekallWinPmemCollectMemoryOverrideRiskCheckbox.Enabled = $false
            }
            else {
                $RekallWinPmemCollectMemoryButton.Enabled = $false
                $RekallWinPmemCollectMemoryOverrideRiskCheckbox.Enabled = $true
                if ($RekallWinPmemCollectMemoryOverrideRiskCheckbox.checked){ $RekallWinPmemCollectMemoryButton.Enabled = $true }
                else { $RekallWinPmemCollectMemoryButton.Enabled = $false }
            }
        }
        else {
            $RekallWinPmemCollectMemoryButton.Enabled = $false
            $RekallWinPmemCollectMemoryOverrideRiskCheckbox.Enabled = $false                
        }
    }

    #-----------------------
    # Rekall WinPmem - Form
    #-----------------------
    $RekallWinPmemForm = New-Object System.Windows.Forms.Form -Property @{
        Text     = 'Memory Collection - ReKall WinPmem'
        Width    = $FormScale * 542
        Height   = $FormScale * 475
        StartPosition = "CenterScreen"
        ControlBox    = $true
        Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
    }
    #-----------------------------
    # Rekall WinPmem - Main Label
    #-----------------------------
    $RekallWinPmemMainLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Remote Memory Collection using Rekall WinPmem"
        Location = @{ X = $FormScale * 10
                      Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 528
                      Height = $FormScale * 25 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 12),0,0,0)
    }
    $RekallWinPmemForm.Controls.Add($RekallWinPmemMainLabel)

    #-------------------------------------------
    # Rekall WinPmem - Verify Settings GroupBox
    #-------------------------------------------
    $RekallWinPmemVerifySettingsGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
        Text     = "Memory Collection Restrictions Settings"
        Location = @{ X = $FormScale * 10
                      Y = $RekallWinPmemMainLabel.Location.y + $RekallWinPmemMainLabel.Size.Height }
        Size     = @{ Width  = $FormScale * 508
                      Height = $FormScale * 100 }
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = "Blue"
    }
        #---------------------------------
        # Rekall WinPmem - Settings Label
        #---------------------------------
        $RekallWinPmemVerifySettingsLabel = New-Object System.Windows.Forms.Label -Property @{
            Text     = "Set limitations to reduce endpoint resource risk and limit network bandwidth utilization."
            Location = @{ X = $FormScale * 8
                          Y = $FormScale * 20 }
            Size     = @{ Width  = $FormScale * 480
                          Height = $FormScale * 20 }
            Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = "Black"
        }
        $RekallWinPmemVerifySettingsGroupBox.Controls.Add($RekallWinPmemVerifySettingsLabel)

        #------------------------------------------------------------
        # Rekall WinPmem - Settings How Much RAM to Collect ComboBox
        #------------------------------------------------------------
        $RekallWinPmemSettingHowMuchRAMToCollectComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
            Text     = "4GB"
            Location = @{ X = $FormScale * 20
                          Y = $RekallWinPmemVerifySettingsLabel.Location.Y + $RekallWinPmemVerifySettingsLabel.Size.Height }
            Size     = @{ Width  = $FormScale * 65
                          Height = $FormScale * 20 }
            Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = "Black"
            AutoCompleteSource = "ListItems"
            AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
        }
        $RekallWinPmemRemoteTotalRamSize = @('1GB','2GB','4GB','6GB','8GB','10GB','12GB','16GB') #1073741824 bytes = 1GB
        ForEach ($Item in $RekallWinPmemRemoteTotalRamSize) { $RekallWinPmemSettingHowMuchRAMToCollectComboBox.Items.Add($Item) }
        #$RekallWinPmemRemoteTotalRAMComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") {ViewChartExecute} })
        $RekallWinPmemVerifySettingsGroupBox.Controls.Add($RekallWinPmemSettingHowMuchRAMToCollectComboBox)

        #---------------------------------------------------------
        # Rekall WinPmem - Settings How Much RAM to Collect Label
        #---------------------------------------------------------
        $RekallWinPmemSettingHowMuchRAMToCollectLabel = New-Object System.Windows.Forms.Label -Property @{
            Text     = "The maximum amount of endpoint RAM that can be collected"
            Location = @{ X = $RekallWinPmemSettingHowMuchRAMToCollectComboBox.Location.X + $RekallWinPmemSettingHowMuchRAMToCollectComboBox.Size.Width + $($FormScale * 5)
                          Y = $RekallWinPmemSettingHowMuchRAMToCollectComboBox.Location.Y + $($FormScale * 2) }
            Size     = @{ Width  = $FormScale * 355
                          Height = $FormScale * 25 }
            Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = "Black"
        }
        $RekallWinPmemVerifySettingsGroupBox.Controls.Add($RekallWinPmemSettingHowMuchRAMToCollectLabel)

        #---------------------------------------------------------------
        # Rekall WinPmem - Setting Minimum Availble Disk Space ComboBox
        #---------------------------------------------------------------
        $RekallWinPmemSettingMinimumAvailbleDiskSpaceComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
            Text     = "250GB"
            Location = @{ X = $FormScale * 20
                          Y = $RekallWinPmemSettingHowMuchRAMToCollectComboBox.Location.Y + $RekallWinPmemSettingHowMuchRAMToCollectComboBox.Size.Height + $($FormScale * 5) }
            Size     = @{ Width  = $FormScale * 65
                          Height = $FormScale * 25 }
            Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = "Black"
            AutoCompleteSource = "ListItems"
            AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
        }
        $RekallWinPmemRemoteAvailableDiskSpace = @('25GB','50GB','100GB','250GB','500GB','750GB','1TB','2TB') #1073741824 bytes = 1GB
        ForEach ($Item in $RekallWinPmemRemoteAvailableDiskSpace) { $RekallWinPmemSettingMinimumAvailbleDiskSpaceComboBox.Items.Add($Item) }
        $RekallWinPmemVerifySettingsGroupBox.Controls.Add($RekallWinPmemSettingMinimumAvailbleDiskSpaceComboBox)

        #--------------------------------------------------------------
        # Rekall WinPmem - Settings Mimimal Available Disk Space Label
        #--------------------------------------------------------------
        $RekallWinPmemSettingMinimumAvailbleDiskSpaceLabel = New-Object System.Windows.Forms.Label -Property @{
            Text     = "The minimum endpoint disk space to permit memory collection."                     
            Location = @{ X = $RekallWinPmemSettingMinimumAvailbleDiskSpaceComboBox.Location.X + $RekallWinPmemSettingMinimumAvailbleDiskSpaceComboBox.Size.Width + $($FormScale * 5)
                          Y = $RekallWinPmemSettingMinimumAvailbleDiskSpaceComboBox.Location.Y + $($FormScale * 2) }
            Size     = @{ Width  = $FormScale * 355
                          Height = $FormScale * 25 }
            Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = "Black"
        }
        $RekallWinPmemVerifySettingsGroupBox.Controls.Add($RekallWinPmemSettingMinimumAvailbleDiskSpaceLabel)

    $RekallWinPmemForm.Controls.Add($RekallWinPmemVerifySettingsGroupBox) 

    #----------------------------------------------
    # Rekall WinPmem - Reported Resources GroupBox
    #----------------------------------------------
    $RekallWinPmemReportedResourcesGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
        Text     = "Endpoint Resource Information and Checks"
        Location = @{ X = $FormScale * 10
                      Y = $RekallWinPmemVerifySettingsGroupBox.Location.y + $RekallWinPmemVerifySettingsGroupBox.Size.Height + $($FormScale * 5) }
        Size     = @{ Width  = $FormScale * 508
                      Height = $FormScale * 144 }
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 12),0,0,0)
        ForeColor = "Blue"
    }
        #-------------------------------------------
        # Rekall WinPmem - Reported Total RAM Label
        #-------------------------------------------
        $RekallWinPmemReportedTotalRAMLabel = New-Object System.Windows.Forms.Label -Property @{
            Text     = "Total RAM Amount:"
            Location = @{ X = $FormScale * 20
                          Y = $FormScale * 20 }
            Size     = @{ Width  = $FormScale * 475
                          Height = $FormScale * 20 }
            Font     = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
            ForeColor = "Black"
        }
        $RekallWinPmemReportedResourcesGroupBox.Controls.Add($RekallWinPmemReportedTotalRAMLabel)

        #------------------------------------------------
        # Rekall WinPmem - Remote Total Disk Space Label
        #------------------------------------------------
        $RekallWinPmemRemoteTotalDiskSpaceLabel = New-Object System.Windows.Forms.Label -Property @{
            Text     = "Total Disk Space"
            Location = @{ X = $FormScale * 20
                          Y = $RekallWinPmemReportedTotalRAMLabel.Location.y + $RekallWinPmemReportedTotalRAMLabel.Size.Height - $($FormScale * 2) }
            Size     = @{ Width  = $FormScale * 475
                          Height = $FormScale * 20 }
            Font      = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
            ForeColor = "Black"
        }
        $RekallWinPmemReportedResourcesGroupBox.Controls.Add($RekallWinPmemRemoteTotalDiskSpaceLabel)

        #----------------------------------------------------
        # Rekall WinPmem - Remote Available Disk Space Label
        #----------------------------------------------------
        $RekallWinPmemRemoteAvailableDiskSpaceLabel = New-Object System.Windows.Forms.Label -Property @{
            Text     = "Available Disk Space"
            Location = @{ X = $FormScale * 20
                          Y = $RekallWinPmemRemoteTotalDiskSpaceLabel.Location.y + $RekallWinPmemRemoteTotalDiskSpaceLabel.Size.Height - $($FormScale * 2) }
            Size     = @{ Width  = $FormScale * 475
                          Height = $FormScale * 20 }
            Font      = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
            ForeColor = "Black"
        }
        $RekallWinPmemReportedResourcesGroupBox.Controls.Add($RekallWinPmemRemoteAvailableDiskSpaceLabel)

        #---------------------------------------------------
        # Rekall WinPmem - Reported Disk Percent Used Label
        #---------------------------------------------------
        $RekallWinPmemReportedDiskPercentUsedLabel = New-Object System.Windows.Forms.Label -Property @{
            Text     = "Disk Percentage Used:"
            Location = @{ X = $FormScale * 20
                          Y = $RekallWinPmemRemoteAvailableDiskSpaceLabel.Location.y + $RekallWinPmemRemoteAvailableDiskSpaceLabel.Size.Height - $($FormScale * 2) }
            Size     = @{ Width  = $FormScale * 475
                          Height = $FormScale * 20 }
            Font      = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
            ForeColor = "Black"
        }
        $RekallWinPmemReportedResourcesGroupBox.Controls.Add($RekallWinPmemReportedDiskPercentUsedLabel)

        #-----------------------------------------
        # Rekall WinPmem - Remote CPU Level Label
        #-----------------------------------------
        $RekallWinPmemRemoteCPULevelLabel = New-Object System.Windows.Forms.Label -Property @{
            Text     = "CPU Utilization (10s Avg):"
            Location = @{ X = $FormScale * 20
                          Y = $RekallWinPmemReportedDiskPercentUsedLabel.Location.y + $RekallWinPmemReportedDiskPercentUsedLabel.Size.Height - $($FormScale * 2) }
            Size     = @{ Width  = $FormScale * 475
                          Height = $FormScale * 20 }
            Font      = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
            ForeColor = "Black"
        }
        $RekallWinPmemReportedResourcesGroupBox.Controls.Add($RekallWinPmemRemoteCPULevelLabel)

        #------------------------------------------------
        # Rekall WinPmem - Check Remote Resources Button
        #------------------------------------------------
        $RekallWinPmemCheckRemoteResourcesButton = New-Object System.Windows.Forms.Button -Property @{
            Text     = "Check Remote Resources"
            Location = @{ X = $FormScale * 180
                          Y = $RekallWinPmemRemoteCPULevelLabel.Location.y + $RekallWinPmemRemoteCPULevelLabel.Size.Height }
            Size     = @{ Width  = $FormScale * 150
                          Height = $FormScale * 25 }
        }
        CommonButtonSettings -Button $RekallWinPmemCheckRemoteResourcesButton
        $RekallWinPmemCheckRemoteResourcesButton.add_click({
            # This brings specific tabs to the forefront/front view
            $MainBottomTabControl.SelectedTab   = $Section3ResultsTab

            if ($RekallWinPmemCheckRemoteResourcesButton.Text -eq "Check Remote Resources") {
                $RekallWinPmemCheckRemoteResourcesButton.Text = "Querying Endpoint"
                $RekallWinPmemCheckRemoteResourcesButton.add_click({$null})
            }
            $RekallWinPmemStatusMessageTextbox.Text = $null

            # Provides GUI Message about collecting remote info
            $RekallWinPmemReportedTotalRAMLabel.Text         = $('{0,-40}{1,-20}{2}' -f 'Total RAM Amount:',          "Collecting", "____")
            $RekallWinPmemRemoteTotalDiskSpaceLabel.Text     = $('{0,-40}{1,-20}{2}' -f 'Total Disk Space:',          "Collecting", "____")
            $RekallWinPmemRemoteAvailableDiskSpaceLabel.Text = $('{0,-40}{1,-20}{2}' -f 'Available Disk Space:',      "Collecting", "____")
            $RekallWinPmemReportedDiskPercentUsedLabel.Text  = $('{0,-40}{1,-20}{2}' -f 'Disk Percentage Used:',      "Collecting", "____")
            $RekallWinPmemRemoteCPULevelLabel.Text           = $('{0,-40}{1,-20}{2}' -f 'CPU Utilization (10s Avg):', "Collecting", "____")

            if ($RekallWinPmemCheckRemoteResourcesButton.Text -eq "Querying Endpoint") {
                # Gets RAM Amount
                # Get-WmiObject -Class Win32_PhysicalMemory | Select capacity
                $script:ReportedRAMAmount = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $script:ComputerTreeViewSelected | Select-Object -ExpandProperty TotalPhysicalMemory
                $Message = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty TotalPhysicalMemory"
                $Message | Add-Content -Path $LogFile
                $RekallWinPmemReportedTotalRAMLabel.Text = $('{0,-40}{1,-20}{2}' -f 'Total RAM Amount:',"$([math]::round($($script:ReportedRAMAmount / 1GB),2)) GB", "____")
                Start-Sleep -Milliseconds 500

                # Gets Disk Statistics
                $ReportedDiskInfo = Get-WmiObject -Class Win32_LogicalDisk -ComputerName $script:ComputerTreeViewSelected | Where-Object {$_.DriveType -eq 3 -and $_.DeviceID -eq 'C:'} | Select-Object -Property Size, FreeSpace
                $Message = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Get-WmiObject -Class Win32_LogicalDisk -ComputerName $script:ComputerTreeViewSelected | Select-Object -Property Size, FreeSpace"
                $Message | Add-Content -Path $LogFile

                    # Determine Disk Total Size
                    $script:ReportedDiskSize = $ReportedDiskInfo | Select-Object -ExpandProperty Size                
                    $RekallWinPmemRemoteTotalDiskSpaceLabel.Text = $('{0,-40}{1,-20}{2}' -f 'Total Disk Space:',"$([math]::round($($script:ReportedDiskSize / 1GB),2)) GB", "____")
                    Start-Sleep -Milliseconds 500

                    # Determine Disk Free Space
                    $script:ReportedDiskFreeSpace = $ReportedDiskInfo | Select-Object -ExpandProperty FreeSpace
                    $RekallWinPmemRemoteAvailableDiskSpaceLabel.Text = $('{0,-40}{1,-20}{2}' -f 'Available Disk Space:',"$([math]::round($($script:ReportedDiskFreeSpace / 1GB),2)) GB", "____")
                    Start-Sleep -Milliseconds 500

                # Calculate Disk Utilization Percentage Use
                $script:RekalWinPmemDiskPercentageUse = $([math]::abs([math]::round($((($script:ReportedDiskFreeSpace / $script:ReportedDiskSize) * 100) - 100),2)))
                $RekallWinPmemReportedDiskPercentUsedLabel.Text = $('{0,-40}{1,-20}{2}' -f 'Disk Percentage Used:', "$script:RekalWinPmemDiskPercentageUse %", "____")
                Start-Sleep -Milliseconds 500

                # Gets the Average Processor Load
                $LoadPercentageAverage = @()
                foreach ($count in $(10..0)) {
                    if ($count -in @(0,5,10)) {
                        $LoadPercentageAverage += Get-WmiObject Win32_Processor -ComputerName $script:ComputerTreeViewSelected | Select-Object -Property LoadPercentage
                        $Message = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Get-WmiObject Win32_Processor -ComputerName $script:ComputerTreeViewSelected | Select-Object -Property LoadPercentage"
                        $Message | Add-Content -Path $LogFile
                    }
                    $RekallWinPmemRemoteCPULevelLabel.Text = $('{0,-40}{1,-20}{2}' -f 'CPU Utilization (10s Avg):', "Remaining $($count)", "____")
                    $RekallWinPmemForm.Refresh()
                    if ($count -eq 0) {break}
                    Start-Sleep -Seconds 1
                }
                $script:RekallWinPmemReportedAverageLoad = $LoadPercentageAverage | Measure-Object -Property LoadPercentage -Average | Select-Object -ExpandProperty Average
                $RekalWinPmemAverageLoad = $([math]::abs([math]::round($((($script:ReportedDiskFreeSpace / $script:ReportedDiskSize) * 100) - 100),2)))
                $RekallWinPmemRemoteCPULevelLabel.Text = $('{0,-40}{1,-20}{2}' -f 'CPU Utilization (10s Avg):', "$([math]::Round($script:RekallWinPmemReportedAverageLoad,2)) %", "____")
            }
            RekallWinPmemStatusCheckUpdate
        })
        $RekallWinPmemReportedResourcesGroupBox.Controls.Add($RekallWinPmemCheckRemoteResourcesButton) 

    $RekallWinPmemForm.Controls.Add($RekallWinPmemReportedResourcesGroupBox) 


    # -------------
    # Progress Bar  
    #--------------
    $script:MemoryCaptureProgressBarLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Update Timer:"
        Location = @{ X = $RekallWinPmemReportedResourcesGroupBox.Location.X
                      Y = $RekallWinPmemReportedResourcesGroupBox.Location.Y + $RekallWinPmemReportedResourcesGroupBox.Size.Height + $($FormScale * 7) }
        Size     = @{ Width  = $FormScale * 85
                      Height = $FormScale * 22 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $RekallWinPmemForm.Controls.Add($script:MemoryCaptureProgressBarLabel)  

    $script:MemoryCaptureProgressBar = New-Object System.Windows.Forms.ProgressBar -Property @{
        Location = @{ X = $script:MemoryCaptureProgressBarLabel.Location.X + $script:MemoryCaptureProgressBarLabel.Size.Width
                      Y = $script:MemoryCaptureProgressBarLabel.Location.Y }
        Size     = @{ Width  = $RekallWinPmemReportedResourcesGroupBox.Size.Width - $script:MemoryCaptureProgressBarLabel.Size.Width - $($FormScale * 1)
                      Height = $FormScale * 15 }
        Forecolor = 'LightBlue'
        BackColor = 'white'
        Style     = "Continuous" #"Marque" 
        Minimum   = 0
    }
    $RekallWinPmemForm.Controls.Add($script:MemoryCaptureProgressBar)


    #-----------------------------------------
    # Rekall WinPmem - Status Message Textbox
    #-----------------------------------------
    $RekallWinPmemStatusMessageTextbox = New-Object System.Windows.Forms.Textbox -Property @{
        Text     = "Status: Need to query endpoint"
        Location = @{ X = $FormScale * 10
                      Y = $script:MemoryCaptureProgressBar.Location.Y + $script:MemoryCaptureProgressBar.Size.Height + $($FormScale * 7) }
        Size     = @{ Width  = $FormScale * 508
                      Height = $FormScale * 80 }
        Font      = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
        ForeColor = "Black"
        BackColor = 'white'
        MultiLine = $true
        Enabled   = $false
    }
    $RekallWinPmemForm.Controls.Add($RekallWinPmemStatusMessageTextbox)

    #----------------------------------------
    # Rekall WinPmem - Collect Memory Button
    #----------------------------------------
    $RekallWinPmemCollectMemoryButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Collect Memory"
        Location = @{ X = $FormScale * 190
                      Y = $RekallWinPmemStatusMessageTextbox.Location.y + $RekallWinPmemStatusMessageTextbox.Size.Height + $($FormScale * 5) }
        Size     = @{ Width  = $FormScale * 150
                      Height = $FormScale * 25 }
        Enabled   = $false
    }
    CommonButtonSettings -Button $RekallWinPmemCollectMemoryButton
    $RekallWinPmemCollectMemoryButton.add_click({ 
        RekallWinPmemStatusCheckUpdate
        if ($RekallWinPmemCollectMemoryButton.Enabled) {
            Conduct-RekallWinPmemMemoryCapture -ChunkSize $($RekallWinPmemCompressionSettingChunkSizeComboBox.Text) -Compression $($RekallWinPmemCompressionSettingCompressionTypeComboBox.Text)
        }
    })
    $RekallWinPmemForm.Controls.Add($RekallWinPmemCollectMemoryButton)

    #---------------------------------------------------
    # Rekall WinPmem - Collect Memory Override Checkbox
    #---------------------------------------------------
    $RekallWinPmemCollectMemoryOverrideRiskCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
        Text     = "Override Risk"
        Location = @{ X = $RekallWinPmemCollectMemoryButton.Location.X + $RekallWinPmemCollectMemoryButton.Size.Width + $($FormScale * 25)
                      Y = $RekallWinPmemCollectMemoryButton.Location.Y + $($FormScale * 2) }
        Size     = @{ Width  = $FormScale * 185
                      Height = $FormScale * 25 }
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = "Black"
        Enabled   = $false
    }
    $RekallWinPmemCollectMemoryOverrideRiskCheckbox.add_click({
        if ($RekallWinPmemCollectMemoryOverrideRiskCheckbox.checked){ 
            $RekallWinPmemCollectMemoryButton.Enabled = $true 
        }
        else { $RekallWinPmemCollectMemoryButton.Enabled = $false }
    })
    $RekallWinPmemForm.Controls.Add($RekallWinPmemCollectMemoryOverrideRiskCheckbox)

    $RekallWinPmemForm.ShowDialog()
}






































#If you want to use winpmem to acquire a raw memory image, all you have to do is provide it with a filename.  A copy of all the bytes in memory will be saved to that file.  For example:
#This will create a raw memory image named "memory.dmp" suitable for analysis with Volatility, Mandiants Redline and others.
# winpmem_1.4.exe memory.dmp

#The tool can also create a crash dump that is suitable for analysis with Microsoft WinDBG.   To do so you just add the "-d" option to your command line like this:
# winpmem_1.4.exe  -d crashdump.dmp

function Conduct-RekallWinPmemMemoryCapture {
    $CollectionName = "Memory Capture"
    $CollectionCommandStartTime = Get-Date 
    Conduct-PreCommandExecution $PoShLocation $CollectedResultsUncompiled $CollectionName
    Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $script:CollectedDataTimeStampDirectory `
                            -IndividualHostResults $script:IndividualHostResults -CollectionName $CollectionName `
                            -TargetComputer $script:ComputerTreeViewSelected
    Create-LogEntry -TargetComputer $script:ComputerTreeViewSelected -CollectionName $CollectionName -LogFile $LogFile
    Function RekallWinPmemMemoryCaptureData {
        # https://isc.sans.edu/forums/diary/Winpmem+Mild+mannered+memory+aquisition+tool/17054/
        # This will create a raw memory image named "memory.raw" suitable for analysis with Volatility, Mandiants Redline and others.   

        $CompressionsType    = $Compression.TrimEnd(' Compression')

        $ToolName              = "WinPmem"
        $ToolExecutable        = "$ToolName.exe"
        $ToolExecutablePath    = "$ExternalPrograms\WinPmem\$ToolExecutable"
        $RemoteTargetDirectory = "c:\Windows\Temp"        

        # Starts the WinPmem Memory Capture and saves the capture to the targets Windows' Temp dir
#        "Start-Process `"C:\$TempPath\$WinPmem`" -WindowStyle Hidden -ArgumentList `"C:\$TempPath\$MemoryCaptureFile`"" > "$ExternalPrograms\$MemoryCaptureScript"

        $Message = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Starting Memory Capture"
        $RekallWinPmemStatusMessageTextbox.Text = "$Message `r`n" + "$($RekallWinPmemStatusMessageTextbox.Text)"

        if ($ComputerListProvideCredentialsCheckBox.Checked) {
            if (!$script:Credential) { Create-NewCredentials }
            $PSSession = New-PSSession -ComputerName $script:ComputerTreeViewSelected -Credential $script:Credential #| Sort-Object ComputerName
        }
        else {
            $PSSession = New-PSSession -ComputerName $script:ComputerTreeViewSelected #| Sort-Object ComputerName
        }
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Memory Collection Started on $script:ComputerTreeViewSelected"
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "New-PSSession -ComputerName $($PSSession.ComputerName -join ', ')"

        foreach ($Session in $PSSession) {
    
            $MemoryCaptureFile   = "MemoryCapture-$($Session.ComputerName).dmp"
            # Attempts to copy WinPmem to the endpoints
            Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "Copy-Item -Path $ToolExecutablePath -Destination $RemoteTargetDirectory -ToSession $Session -Force -ErrorAction Stop"

            try {
                $RekallWinPmemStatusMessageTextbox.text = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Copying over WinPmem.exe`r`n"+ $RekallWinPmemStatusMessageTextbox.text
                Copy-Item -Path $ToolExecutablePath -Destination "$RemoteTargetDirectory" -ToSession $Session -Force -ErrorAction Stop 

                # # Copies WinPmem.exe and Strings.exe over to the TargetComputer
                # $CopyWinPmemToTargetHost = "Copy-Item '$ExternalPrograms\$WinPmem' '\\$script:ComputerTreeViewSelected\C$\$TempPath' -Force"
                # Invoke-Expression $CopyWinPmemToTargetHost
                # $Message = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $CopyWinPmemToTargetHost"
                # $Message | Add-Content -Path $LogFile
            }
            catch { 
                #$ResultsListBox.Items.Insert(4,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Copy $ToolExecutable Error:  $($_.Exception)")
                $RekallWinPmemStatusMessageTextbox.text = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Copy $ToolExecutable Error:  $($_.Exception)`r`n"+ $RekallWinPmemStatusMessageTextbox.text
                Create-LogEntry -LogFile $LogFile -TargetComputer "[!] Copy $ToolExecutable Error: $($_.Exception)"
                break
            }


            # Attempts to execute WinPmem to capture memory
            $ResultsListBox.Items.Insert(3,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))      $($Session.ComputerName)")
            Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message  "Start-Process -Filepath `"$RemoteTargetDirectory\$ToolExecutable`" -ArgumentList @(`"'$RemoteTargetDirectory\$MemoryCaptureFile`")"
            try {
                $RekallWinPmemStatusMessageTextbox.text = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Starting Memory Collection`r`n"+ $RekallWinPmemStatusMessageTextbox.text
                Invoke-Command -ScriptBlock {
                    param(
                        $RemoteTargetDirectory,
                        $ToolExecutable,
                        $MemoryCaptureFile
                    )
                    Start-Process -Filepath "$RemoteTargetDirectory\$ToolExecutable" -ArgumentList @("$RemoteTargetDirectory\$MemoryCaptureFile")
                } -ArgumentList @($RemoteTargetDirectory,$ToolExecutable,$MemoryCaptureFile) -Session $Session
            }
            catch {
                # If an error occurs, it will display it
                #$ResultsListBox.Items.insert(3,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))         Execution Error: $($_.Exception)")
                $RekallWinPmemStatusMessageTextbox.text = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Execution Error:  $($_.Exception)`r`n"+ $RekallWinPmemStatusMessageTextbox.text
                Create-LogEntry -LogFile $LogFile -TargetComputer "[!] Executions Error: $($_.Exception)"
                break       
            }


            # Checks to see if WinPmem is still running
            $script:MemoryCaptureProgressBar.Value = 0
            $script:MemoryCaptureProgressBar.Maximum = 15
            Start-Sleep -Seconds 1

            $RekallWinPmemStatusMessageTextbox.text = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Checking Memory Collection Status`r`n" + $RekallWinPmemStatusMessageTextbox.text
            While ($true) {
                $CompletionCheck = Invoke-Command -ScriptBlock {
                    param($ToolName)
                    Get-Process -Name $ToolName
                } -ArgumentList @($ToolName,$null) -Session $Session

                $RekallWinPmemForm.Refresh()

                $script:MemoryCaptureProgressBar.Value = 0
                foreach ($second in (1..15)) {
                    $script:MemoryCaptureProgressBar.Value += 1
                    $script:MemoryCaptureProgressBar.Refresh()
                    Start-Sleep -Seconds 1
                    $RekallWinPmemForm.Refresh()
#                    if ($Second -eq 15) {Break}
                }


                $RekallWinPmemStatusMessageTextbox.text = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $($Session.ComputerName) Memory Capture Size: $([math]::round($(($MemoryCaptureSize).length / 1GB),2)) GB `r`n" + $RekallWinPmemStatusMessageTextbox.text
                $MemoryCaptureSize = Invoke-Command -ScriptBlock {
                    param($RemoteTargetDirectory,$MemoryCaptureFile)
                    Get-Item "$RemoteTargetDirectory\$MemoryCaptureFile"
                } -ArgumentList @($RemoteTargetDirectory,$MemoryCaptureFile) -Session $Session

                if ($CompletionCheck) { continue }
                else { Break }
            }


            New-Item "$script:IndividualHostResults\Memory Capture" -Type Directory


            # Attempts to copy the memory capture back
            While ($true) {
                $FileSize1 = Invoke-Command -ScriptBlock {
                    param($RemoteTargetDirectory,$MemoryCaptureFile)
                    Get-Item "$RemoteTargetDirectory\$MemoryCaptureFile"
                } -ArgumentList @($RemoteTargetDirectory,$MemoryCaptureFile) -Session $Session

                Start-Sleep -Seconds 1

                $FileSize2 = Invoke-Command -ScriptBlock {
                    param($RemoteTargetDirectory,$MemoryCaptureFile)
                    Get-Item "$RemoteTargetDirectory\$MemoryCaptureFile"
                } -ArgumentList @($RemoteTargetDirectory,$MemoryCaptureFile) -Session $Session

                $RekallWinPmemStatusMessageTextbox.text = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Verifying Memory Collection is Complete`r`n"+ $RekallWinPmemStatusMessageTextbox.text
                if ($FileSize1.length -eq $FileSize2.length){break}
            }



<#
            -f .\MemoryCapture-WIN81-05.dmp imageinfo

            --profile=Win7SP0x86 pslist
            --profile=Win7SP0x86 pstree
            --profile=Win7SP0x86 cmdscan
            --profile=Win7SP0x86 netscan
            --profile=Win7SP0x86 malfind -p <PID>
#>

# NEED TO MAKE A MENU TO OPT TO COPY BACK THE MEMORY FILE
            $RekallWinPmemStatusMessageTextbox.text = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Copying Back Memory File: $([math]::round($(($MemoryCaptureSize).length / 1GB),2)) GB `r`n" + $RekallWinPmemStatusMessageTextbox.text
            Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "Copy-Item -Path '$RemoteTargetDirectory\$MemoryCaptureFile' -Destination '$script:IndividualHostResults\Memory Capture' -FromSession $Session -Force -ErrorAction Stop"
            try { 
                Copy-Item -Path "$RemoteTargetDirectory\$MemoryCaptureFile" -Destination "$script:IndividualHostResults\Memory Capture" -FromSession $Session -Force -ErrorAction Stop 
                $RekallWinPmemStatusMessageTextbox.text = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  $($Session.ComputerName) - Copy Complete`r`n" + $RekallWinPmemStatusMessageTextbox.text
            }
            catch { 
                $RekallWinPmemStatusMessageTextbox.text = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  $($Session.ComputerName) Copy Failed`r`n" + $RekallWinPmemStatusMessageTextbox.text
                $RekallWinPmemStatusMessageTextbox.text = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Error:  $($_.Exception)`r`n" + $RekallWinPmemStatusMessageTextbox.text
                Create-LogEntry -LogFile $LogFile -TargetComputer "[!] Copy $ToolExecutable Error: $($_.Exception)"
                break
            }


            # Attempts to cleanup/remove the tool fromt the endpoint
            Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "Remove-Item '$RemoteTargetDirectory\$ToolExecutable'"
            try { 
                $RekallWinPmemStatusMessageTextbox.text = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  $($Session.ComputerName) - Remove $ToolExecutable from $($Session.ComputerName)`r`n" + $RekallWinPmemStatusMessageTextbox.text
                Invoke-Command -ScriptBlock {
                    param($RemoteTargetDirectory, $ToolExecutable)
                    Remove-Item "$RemoteTargetDirectory\$ToolExecutable"
                } -ArgumentList @($RemoteTargetDirectory, $ToolExecutable) -Session $Session
            }
            catch { 
            #    $ResultsListBox.Items.Insert(4,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Remove $ToolExecutable Error:  $($_.Exception)")
            $RekallWinPmemStatusMessageTextbox.text = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  $($Session.ComputerName) - Remove $ToolExecutable Error:  $($_.Exception)`r`n" + $RekallWinPmemStatusMessageTextbox.text
                Create-LogEntry -LogFile $LogFile -TargetComputer "[!] Remove $ToolExecutable Error: $($_.Exception)"
                break
            }


            # Attempts to cleanup/remove the memory capture fromt the endpoint
            Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "Remove-Item '$RemoteTargetDirectory\$MemoryCaptureFile'"
            try { 
                $RekallWinPmemStatusMessageTextbox.text = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  $($Session.ComputerName) - Removing Memory Capture from $($Session.ComputerName)`r`n" + $RekallWinPmemStatusMessageTextbox.text
                Invoke-Command -ScriptBlock {
                    param($RemoteTargetDirectory, $MemoryCaptureFile)
                    Remove-Item "$RemoteTargetDirectory\$MemoryCaptureFile"
                } -ArgumentList @($RemoteTargetDirectory, $MemoryCaptureFile) -Session $Session
            }
            catch { 
            #    $ResultsListBox.Items.Insert(4,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Remove $ToolExecutable Error:  $($_.Exception)")
            $RekallWinPmemStatusMessageTextbox.text = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  $($Session.ComputerName) - Removing Memory Capture Error:  $($_.Exception)`r`n" + $RekallWinPmemStatusMessageTextbox.text
                Create-LogEntry -LogFile $LogFile -TargetComputer "[!] Remove $ToolExecutable Error: $($_.Exception)"
                break
            }

#>
        }
          
        Conduct-PostCommandExecution $CollectionName
        $CollectionCommandEndTime0  = Get-Date 
        $CollectionCommandDiffTime0 = New-TimeSpan -Start $CollectionCommandStartTime -End $CollectionCommandEndTime0
        $RekallWinPmemStatusMessageTextbox.text = "$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime0]  $CollectionName`r`n" + $RekallWinPmemStatusMessageTextbox.text
    
        $ResultsListBox.Items.Insert(4,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Memory Capture Has Finished!")
        $Message = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Memory Capture Has Finished!"
        $Message | Add-Content -Path $LogFile

        Get-PSSession | Remove-PSSession
#        $RekallWinPmemForm.close()

    }
    RekallWinPmemMemoryCaptureData
}
