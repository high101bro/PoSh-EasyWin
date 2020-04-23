function Launch-RekallWinPmemForm {
    $script:ReportedRAMAmount                = $null
    $script:ReportedDiskSize                 = $null
    $script:ReportedDiskFreeSpace            = $null
    $script:RekalWinPmemDiskPercentageUse    = $null
    $script:RekallWinPmemReportedAverageLoad = $null
    
    function RekallWinPmemStatusCheckUpdate {
        $RekallWinPmemStatusMessageLabel.Text = $null

        # Update RAM Status
        if ($script:ReportedRAMAmount -gt $RekallWinPmemSettingHowMuchRAMToCollectComboBox.Text ) {
            $RekallWinPmemReportedTotalRAMLabel.Text = $('{0,-40}{1,-20}{2}' -f 'Total RAM Amount:',"$([math]::round($($script:ReportedRAMAmount / 1GB),2)) GB", "Fail")
            $RekallWinPmemStatusMessageLabel.Text += "[!] The RAM collection SETTING is insufficient`r`n"
        }
        else {
            $RekallWinPmemReportedTotalRAMLabel.Text = $('{0,-40}{1,-20}{2}' -f 'Total RAM Amount:',"$([math]::round($($script:ReportedRAMAmount / 1GB),2)) GB", "Pass")
            $RekallWinPmemStatusMessageLabel.Text += "[+] Passes RAM mount check`r`n"
        }

        # Update Disk Size Status
        if ($script:ReportedDiskSize -lt $script:ReportedRAMAmount){
            $RekallWinPmemRemoteTotalDiskSpaceLabel.Text = $('{0,-40}{1,-20}{2}' -f 'Total Disk Space:',"$([math]::round($($script:ReportedDiskSize / 1GB),2)) GB", "Fail")
            $RekallWinPmemStatusMessageLabel.Text += "[!] Endpoint has less disk space than its total RAM`r`n"
        }
        else {
            $RekallWinPmemRemoteTotalDiskSpaceLabel.Text = $('{0,-40}{1,-20}{2}' -f 'Total Disk Space:',"$([math]::round($($script:ReportedDiskSize / 1GB),2)) GB", "Pass")

            $RekallWinPmemStatusMessageLabel.Text += "[+] Passes disk size check`r`n"
        }            

        # Update Disk Free Space Status
        if ($script:ReportedDiskFreeSpace -lt $RekallWinPmemSettingMinimumAvailbleDiskSpaceComboBox.Text){
            $RekallWinPmemRemoteAvailableDiskSpaceLabel.Text = $('{0,-40}{1,-20}{2}' -f 'Available Disk Space:',"$([math]::round($($script:ReportedDiskFreeSpace  / 1GB),2)) GB", "Fail")
            $RekallWinPmemStatusMessageLabel.Text += "[!] The available disk space SETTING is insufficient`r`n"
        }
        else {
            $RekallWinPmemRemoteAvailableDiskSpaceLabel.Text = $('{0,-40}{1,-20}{2}' -f 'Available Disk Space:',"$([math]::round($($script:ReportedDiskFreeSpace  / 1GB),2)) GB", "Pass")
            $RekallWinPmemStatusMessageLabel.Text += "[+] Passes disk free space check`r`n"
        }            

        # Update Disk Utilization Percentage Use Status
        if ( $script:RekalWinPmemDiskPercentageUse -gt 75 ) {
            $RekallWinPmemReportedDiskPercentUsedLabel.Text = $('{0,-40}{1,-20}{2}' -f 'Disk Percentage Used:', "$script:RekalWinPmemDiskPercentageUse %", "Risk")
            $RekallWinPmemStatusMessageLabel.Text += "[!] Endpoint is using more than 75% of its disk space`r`n"
        }
        else {
            $RekallWinPmemReportedDiskPercentUsedLabel.Text = $('{0,-40}{1,-20}{2}' -f 'Disk Percentage Used:', "$script:RekalWinPmemDiskPercentageUse %", "Okay")
            $RekallWinPmemStatusMessageLabel.Text += "[+] Passes disk utilization ratio check`r`n"
        }

        # Update the Average Processor Load Status
        if ( $RekalWinPmemAverageLoad -gt 75 ) {
            $RekallWinPmemRemoteCPULevelLabel.Text = $('{0,-40}{1,-20}{2}' -f 'CPU Utilization (10s Avg):', "$([math]::Round($script:RekallWinPmemReportedAverageLoad,2)) %", "Risk")
            $RekallWinPmemStatusMessageLabel.Text += "[!] Endpoint is using more than 75% of its CPU`r`n"
        }
        else {
            $RekallWinPmemRemoteCPULevelLabel.Text = $('{0,-40}{1,-20}{2}' -f 'CPU Utilitzation (10s Avg):', "$([math]::Round($script:RekallWinPmemReportedAverageLoad,2)) %", "Okay")
            $RekallWinPmemStatusMessageLabel.Text += "[+] Passes CPU utilization check`r`n"
        }
                     
        $RekallWinPmemCheckRemoteResourcesButton.Text = "Update Status"

        if ($RekallWinPmemReportedTotalRAMLabel.Text -match 'Pass' -and $RekallWinPmemRemoteAvailableDiskSpaceLabel.Text -match 'Pass' -and $RekallWinPmemRemoteTotalDiskSpaceLabel.Text -match 'Pass') {
            if ($RekallWinPmemReportedDiskPercentUsedLabel.Text -match 'Okay' -and $RekallWinPmemRemoteCPULevelLabel.Text -match 'Okay') {
                $RekallWinPmemCollectMemoryButton.Enabled = $true
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
        Width    = 542
        Height   = 450
        StartPosition = "CenterScreen"
        ControlBox    = $true
        Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
    }
    #-----------------------------
    # Rekall WinPmem - Main Label
    #-----------------------------
    $RekallWinPmemMainLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Remote Memory Collection using Rekall WinPmem"
        Location = @{ X = 10
                      Y = 10 }
        Size     = @{ Width  = 528
                      Height = 25 }
        Font     = New-Object System.Drawing.Font("$Font",12,0,0,0)
    }
    $RekallWinPmemForm.Controls.Add($RekallWinPmemMainLabel)

    #-------------------------------------------
    # Rekall WinPmem - Verify Settings GroupBox
    #-------------------------------------------
    $RekallWinPmemVerifySettingsGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
        Text     = "Memory Collection Restrictions Settings"
        Location = @{ X = 10
                      Y = $RekallWinPmemMainLabel.Location.y + $RekallWinPmemMainLabel.Size.Height }
        Size     = @{ Width  = 508
                      Height = 105 }
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = "Blue"
    }
        #---------------------------------
        # Rekall WinPmem - Settings Label
        #---------------------------------
        $RekallWinPmemVerifySettingsLabel = New-Object System.Windows.Forms.Label -Property @{
            Text     = "Set limitations to reduce endpoint resource risk and limit network bandwidth utilization."
            Location = @{ X = 8
                          Y = 20 }
            Size     = @{ Width  = 480
                          Height = 20 }
            Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
            ForeColor = "Black"
        }
        $RekallWinPmemVerifySettingsGroupBox.Controls.Add($RekallWinPmemVerifySettingsLabel)

        #------------------------------------------------------------
        # Rekall WinPmem - Settings How Much RAM to Collect ComboBox
        #------------------------------------------------------------
        $RekallWinPmemSettingHowMuchRAMToCollectComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
            Text     = "4GB"
            Location = @{ X = 20
                          Y = $RekallWinPmemVerifySettingsLabel.Location.Y + $RekallWinPmemVerifySettingsLabel.Size.Height }
            Size     = @{ Width  = 65
                          Height = 20 }
            Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
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
            Location = @{ X = $RekallWinPmemSettingHowMuchRAMToCollectComboBox.Location.X + $RekallWinPmemSettingHowMuchRAMToCollectComboBox.Size.Width + 5
                          Y = $RekallWinPmemSettingHowMuchRAMToCollectComboBox.Location.Y + 2 }
            Size     = @{ Width  = 355
                          Height = 25 }
            Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
            ForeColor = "Black"
        }
        $RekallWinPmemVerifySettingsGroupBox.Controls.Add($RekallWinPmemSettingHowMuchRAMToCollectLabel)

        #---------------------------------------------------------------
        # Rekall WinPmem - Setting Minimum Availble Disk Space ComboBox
        #---------------------------------------------------------------
        $RekallWinPmemSettingMinimumAvailbleDiskSpaceComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
            Text     = "250GB"
            Location = @{ X = 20
                          Y = $RekallWinPmemSettingHowMuchRAMToCollectComboBox.Location.Y + $RekallWinPmemSettingHowMuchRAMToCollectComboBox.Size.Height + 5 }
            Size     = @{ Width  = 65
                          Height = 25 }
            Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
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
            Location = @{ X = $RekallWinPmemSettingMinimumAvailbleDiskSpaceComboBox.Location.X + $RekallWinPmemSettingMinimumAvailbleDiskSpaceComboBox.Size.Width + 5
                          Y = $RekallWinPmemSettingMinimumAvailbleDiskSpaceComboBox.Location.Y + 2 }
            Size     = @{ Width  = 355
                          Height = 25 }
            Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
            ForeColor = "Black"
        }
        $RekallWinPmemVerifySettingsGroupBox.Controls.Add($RekallWinPmemSettingMinimumAvailbleDiskSpaceLabel)

    $RekallWinPmemForm.Controls.Add($RekallWinPmemVerifySettingsGroupBox) 

    #----------------------------------------------
    # Rekall WinPmem - Reported Resources GroupBox
    #----------------------------------------------
    $RekallWinPmemReportedResourcesGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
        Text     = "Endpoint Resource Information and Checks"
        Location = @{ X = 10
                      Y = $RekallWinPmemVerifySettingsGroupBox.Location.y + $RekallWinPmemVerifySettingsGroupBox.Size.Height + 5 }
        Size     = @{ Width  = 508
                      Height = 144 }
        Font      = New-Object System.Drawing.Font("$Font",12,0,0,0)
        ForeColor = "Blue"
    }
        #-------------------------------------------
        # Rekall WinPmem - Reported Total RAM Label
        #-------------------------------------------
        $RekallWinPmemReportedTotalRAMLabel = New-Object System.Windows.Forms.Label -Property @{
            Text     = "Total RAM Amount:"
            Location = @{ X = 20
                          Y = 20 }
            Size     = @{ Width  = 475
                          Height = 20 }
            Font     = New-Object System.Drawing.Font("Courier New",11,0,0,0)
            ForeColor = "Black"
        }
        $RekallWinPmemReportedResourcesGroupBox.Controls.Add($RekallWinPmemReportedTotalRAMLabel)

        #------------------------------------------------
        # Rekall WinPmem - Remote Total Disk Space Label
        #------------------------------------------------
        $RekallWinPmemRemoteTotalDiskSpaceLabel = New-Object System.Windows.Forms.Label -Property @{
            Text     = "Total Disk Space"
            Location = @{ X = 20
                          Y = $RekallWinPmemReportedTotalRAMLabel.Location.y + $RekallWinPmemReportedTotalRAMLabel.Size.Height - 2 }
            Size     = @{ Width  = 475
                          Height = 20 }
            Font      = New-Object System.Drawing.Font("Courier New",11,0,0,0)
            ForeColor = "Black"
        }
        $RekallWinPmemReportedResourcesGroupBox.Controls.Add($RekallWinPmemRemoteTotalDiskSpaceLabel)

        #----------------------------------------------------
        # Rekall WinPmem - Remote Available Disk Space Label
        #----------------------------------------------------
        $RekallWinPmemRemoteAvailableDiskSpaceLabel = New-Object System.Windows.Forms.Label -Property @{
            Text     = "Available Disk Space"
            Location = @{ X = 20
                          Y = $RekallWinPmemRemoteTotalDiskSpaceLabel.Location.y + $RekallWinPmemRemoteTotalDiskSpaceLabel.Size.Height - 2 }
            Size     = @{ Width  = 475
                         Height = 20 }
            Font      = New-Object System.Drawing.Font("Courier New",11,0,0,0)
            ForeColor = "Black"
        }
        $RekallWinPmemReportedResourcesGroupBox.Controls.Add($RekallWinPmemRemoteAvailableDiskSpaceLabel)

        #---------------------------------------------------
        # Rekall WinPmem - Reported Disk Percent Used Label
        #---------------------------------------------------
        $RekallWinPmemReportedDiskPercentUsedLabel = New-Object System.Windows.Forms.Label -Property @{
            Text     = "Disk Percentage Used:"
            Location = @{ X = 20
                          Y = $RekallWinPmemRemoteAvailableDiskSpaceLabel.Location.y + $RekallWinPmemRemoteAvailableDiskSpaceLabel.Size.Height - 2 }
            Size     = @{ Width  = 475
                          Height = 20 }
            Font      = New-Object System.Drawing.Font("Courier New",11,0,0,0)
            ForeColor = "Black"
        }
        $RekallWinPmemReportedResourcesGroupBox.Controls.Add($RekallWinPmemReportedDiskPercentUsedLabel)

        #-----------------------------------------
        # Rekall WinPmem - Remote CPU Level Label
        #-----------------------------------------
        $RekallWinPmemRemoteCPULevelLabel = New-Object System.Windows.Forms.Label -Property @{
            Text     = "CPU Utilization (10s Avg):"
            Location = @{ X = 20
                          Y = $RekallWinPmemReportedDiskPercentUsedLabel.Location.y + $RekallWinPmemReportedDiskPercentUsedLabel.Size.Height - 2 }
            Size     = @{ Width  = 475
                          Height = 20 }
            Font      = New-Object System.Drawing.Font("Courier New",11,0,0,0)
            ForeColor = "Black"
        }
        $RekallWinPmemReportedResourcesGroupBox.Controls.Add($RekallWinPmemRemoteCPULevelLabel)

        #------------------------------------------------
        # Rekall WinPmem - Check Remote Resources Button
        #------------------------------------------------
        $RekallWinPmemCheckRemoteResourcesButton = New-Object System.Windows.Forms.Button -Property @{
            Text     = "Check Remote Resources"
            Location = @{ X = 180
                          Y = $RekallWinPmemRemoteCPULevelLabel.Location.y + $RekallWinPmemRemoteCPULevelLabel.Size.Height }
            Size     = @{ Width  = 150
                          Height = 25 }
        }
        CommonButtonSettings -Button $RekallWinPmemCheckRemoteResourcesButton
        $RekallWinPmemCheckRemoteResourcesButton.add_click({
            # This brings specific tabs to the forefront/front view
            $MainBottomTabControl.SelectedTab   = $Section3ResultsTab

            if ($RekallWinPmemCheckRemoteResourcesButton.Text -eq "Check Remote Resources") {
                $RekallWinPmemCheckRemoteResourcesButton.Text = "Querying Endpoint"
                $RekallWinPmemCheckRemoteResourcesButton.add_click({$null})
            }
            $RekallWinPmemStatusMessageLabel.Text = $null

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
                foreach ($count in $(10..10)) {
                    if ($count -in @(0,5,10)) {
                        $LoadPercentageAverage += Get-WmiObject Win32_Processor -ComputerName $script:ComputerTreeViewSelected | Select-Object -Property LoadPercentage
                        $Message = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Get-WmiObject Win32_Processor -ComputerName $script:ComputerTreeViewSelected | Select-Object -Property LoadPercentage"
                        $Message | Add-Content -Path $LogFile
                    }
                    $RekallWinPmemRemoteCPULevelLabel.Text = $('{0,-40}{1,-20}{2}' -f 'CPU Utilization (10s Avg):', "Remaining $($count)", "____")
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

    #---------------------------------------
    # Rekall WinPmem - Status Message Label
    #---------------------------------------
    $RekallWinPmemStatusMessageLabel = New-Object System.Windows.Forms.Textbox -Property @{
        Text     = "Status: Need to query endpoint"
        Location = @{ X = 10
                      Y = $RekallWinPmemReportedResourcesGroupBox.Location.Y + $RekallWinPmemReportedResourcesGroupBox.Size.Height + 5 }
        Size     = @{ Width  = 508
                      Height = 80 }
        Font      = New-Object System.Drawing.Font("Courier New",11,0,0,0)
        ForeColor = "Black"
        MultiLine = $true
        Enabled   = $false
    }
    $RekallWinPmemForm.Controls.Add($RekallWinPmemStatusMessageLabel)

    #----------------------------------------
    # Rekall WinPmem - Collect Memory Button
    #----------------------------------------
    $RekallWinPmemCollectMemoryButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Collect Memory"
        Location = @{ X = 190
                      Y = $RekallWinPmemStatusMessageLabel.Location.y + $RekallWinPmemStatusMessageLabel.Size.Height + 5 }
        Size     = @{ Width  = 150
                      Height = 25 }
        Enabled   = $false
    }
    CommonButtonSettings -Button $RekallWinPmemCollectMemoryButton
    $RekallWinPmemCollectMemoryButton.add_click({ 
        RekallWinPmemStatusCheckUpdate
        if ($RekallWinPmemCollectMemoryButton.Enabled) {
            $RekallWinPmemForm.Close()        
            Conduct-RekallWinPmemMemoryCapture -ChunkSize $($RekallWinPmemCompressionSettingChunkSizeComboBox.Text) -Compression $($RekallWinPmemCompressionSettingCompressionTypeComboBox.Text)
        }
    })
    $RekallWinPmemForm.Controls.Add($RekallWinPmemCollectMemoryButton)

    #---------------------------------------------------
    # Rekall WinPmem - Collect Memory Override Checkbox
    #---------------------------------------------------
    $RekallWinPmemCollectMemoryOverrideRiskCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
        Text     = "Override Risk"
        Location = @{ X = $RekallWinPmemCollectMemoryButton.Location.X + $RekallWinPmemCollectMemoryButton.Size.Width + 25
                      Y = $RekallWinPmemCollectMemoryButton.Location.Y + 2 }
        Size     = @{ Width  = 185
                      Height = 25 }
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
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



function Conduct-RekallWinPmemMemoryCapture {
    $CollectionName = "Memory Capture"
    $CollectionCommandStartTime = Get-Date 
    Conduct-PreCommandExecution $PoShLocation $CollectedResultsUncompiled $CollectionName
    $ResultsListBox.Items.Insert(1,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName - $script:ComputerTreeViewSelected")
    Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $CollectedDataTimeStampDirectory `
                            -IndividualHostResults $script:IndividualHostResults -CollectionName $CollectionName `
                            -TargetComputer $script:ComputerTreeViewSelected
    Create-LogEntry -TargetComputer $script:ComputerTreeViewSelected -CollectionName $CollectionName -LogFile $LogFile
    Function RekallWinPmemMemoryCaptureData {
        # https://isc.sans.edu/forums/diary/Winpmem+Mild+mannered+memory+aquisition+tool/17054/
        # This will create a raw memory image named "memory.raw" suitable for analysis with Volatility, Mandiants Redline and others.
        $TempPath            = "Windows\Temp"
        $WinPmem             = "WinPmem.exe"
        $MemoryCaptureScript = "Capture-Memory.ps1"
        $MemoryCaptureFile   = "MemoryCapture-$($script:ComputerTreeViewSelected).raw"
        $CompressionsType    = $Compression.TrimEnd(' Compression')

        # Starts the WinPmem Memory Capture and saves the capture to the targets Windows' Temp dir
        "Start-Process `"C:\$TempPath\$WinPmem`" -WindowStyle Hidden -ArgumentList `"C:\$TempPath\$MemoryCaptureFile`"" > "$ExternalPrograms\$MemoryCaptureScript"

        $Message = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Starting Memory Capture"
        $RekallWinPmemStatusMessageLabel.Text = "$Message `r`n" + "$($RekallWinPmemStatusMessageLabel.Text)"

        # Copies WinPmem.exe and Strings.exe over to the TargetComputer
        $CopyWinPmemToTargetHost = "Copy-Item '$ExternalPrograms\$WinPmem' '\\$script:ComputerTreeViewSelected\C$\$TempPath' -Force"
        Invoke-Expression $CopyWinPmemToTargetHost
        $Message = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $CopyWinPmemToTargetHost"
        $Message | Add-Content -Path $LogFile

        # Copies the Capture-Memory.ps1 script to the TargetComputer
        $CopyMemoryScriptToTargetHost = Copy-Item "$ExternalPrograms\$MemoryCaptureScript" "\\$script:ComputerTreeViewSelected\C$\$TempPath" -Force
        Invoke-Expression $CopyMemoryScriptToTargetHost
        $Message = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $CopyMemoryScriptToTargetHost"
        $Message | Add-Content -Path $LogFile

        # Executes the Capture-Memory.ps1 Script located on the TargetComputer - This uses the WinPmem Program to save the Memory to the TargetComputer
        $ExecuteMemoryCaptureOnTargetHost = "Invoke-WmiMethod -Class Win32_Process -Name Create -ComputerName $script:ComputerTreeViewSelected -ArgumentList `"PowerShell -WindowStyle Hidden -Command C:\$TempPath\$MemoryCaptureScript`" | Out-Null"
        Invoke-Expression $ExecuteMemoryCaptureOnTargetHost 
        $Message = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $ExecuteMemoryCaptureOnTargetHost"
        $Message | Add-Content -Path $LogFile

        Start-Sleep -Seconds 10
        # Checks to see if the process is still running
        while ($true) {
            $CheckWinPmemProcessOnTargetHost = "Get-WmiObject -Class Win32_Process -ComputerName $script:ComputerTreeViewSelected | Where-Object ProcessName -eq WinPmem.exe"
            $CheckWinPmemProcessOnTargetHostStatus = Invoke-Expression $CheckWinPmemProcessOnTargetHost
            $Message1 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Checking Status "
            $Message1 | Add-Content -Path $LogFile
            $RekallWinPmemStatusMessageLabel.Text = "$Message1 `r`n" + "$($RekallWinPmemStatusMessageLabel.Text)"
            $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $CheckWinPmemProcessOnTargetHost"
            $Message2 | Add-Content -Path $LogFile

            if ($CheckWinPmemProcessOnTargetHostStatus) { Start-Sleep -Seconds 10 }
            else {
                # Copies the Memory Capture File from the TargetComputer back to the Localhost
                $CopyMemoryCaptureFromTargetHost = "Copy-Item '\\$script:ComputerTreeViewSelected\C$\$TempPath\$MemoryCaptureFile' '$CollectedDataTimeStampDirectory' -Force"
                Invoke-Expression $CopyMemoryCaptureFromTargetHost
                $Message = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $CopyMemoryCaptureFromTargetHost"
                $Message | Add-Content -Path $LogFile
                                
                $Message = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Memory Capture Has Finished!"
                $Message | Add-Content -Path $LogFile
                $RekallWinPmemStatusMessageLabel.Text = "$Message `r`n" + "$($RekallWinPmemStatusMessageLabel.Text)"
                Start-Sleep -Seconds 5

                # Removes the Memory Capture script from the localhost and TargetHost
                Remove-Item "$ExternalPrograms\$MemoryCaptureScript" -Force
                Remove-Item "\\$script:ComputerTreeViewSelected\C$\$TempPath\$MemoryCaptureScript" -Force
                    
                # Removes WinPmem and Memory Capture filefrom the TargetHost
                Remove-Item "\\$script:ComputerTreeViewSelected\C$\$TempPath\$WinPmem" -Force
                Remove-Item "\\$script:ComputerTreeViewSelected\C$\$TempPath\$MemoryCaptureFile" -Force
                break
            }
        }
    }
    RekallWinPmemMemoryCaptureData

    $CollectionCommandEndTime1  = Get-Date 
    $CollectionCommandDiffTime1 = New-TimeSpan -Start $CollectionCommandStartTime -End $CollectionCommandEndTime1
    $ResultsListBox.Items.RemoveAt(1)
    $ResultsListBox.Items.Insert(1,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime1]  $CollectionName - $script:ComputerTreeViewSelected")

    Conduct-PostCommandExecution $CollectionName
    $CollectionCommandEndTime0  = Get-Date 
    $CollectionCommandDiffTime0 = New-TimeSpan -Start $CollectionCommandStartTime -End $CollectionCommandEndTime0
    $ResultsListBox.Items.RemoveAt(0)
    $ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime0]  $CollectionName")
}
