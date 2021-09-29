
$EnumerationRightPosition     = 3
$EnumerationLabelWidth        = 450
$EnumerationLabelHeight       = 25
$EnumerationGroupGap          = 15

$Section1EnumerationTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = "Scanning"
    Left   = $FormScale * $EnumerationRightPosition
    Top    = 0
    Width  = $FormScale * $EnumerationLabelWidth
    Height = $FormScale * $EnumerationLabelHeight
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
    Add_MouseEnter = {Check-IfScanExecutionReady}
    Add_MouseLeave = {Check-IfScanExecutionReady}
    ImageIndex = 2
}
$MainLeftTabControl.Controls.Add($Section1EnumerationTab)

# Enumeration - Domain Generated Input Check
Update-FormProgress "$Dependencies\Code\Execution\Enumeration\InputCheck-EnumerationByDomainImport.ps1"
. "$Dependencies\Code\Execution\Enumeration\InputCheck-EnumerationByDomainImport.ps1"

#============================================================================================================================================================
# Enumeration - Port Scanning
#============================================================================================================================================================
if (!(Test-Path $CustomPortsToScan)) {
    #Don't modify / indent the numbers below... to ensure the file created is formated correctly
    Write-Output "21`r`n22`r`n23`r`n53`r`n80`r`n88`r`n110`r`n123`r`n135`r`n143`r`n161`r`n389`r`n443`r`n445`r`n3389" | Out-File -FilePath $CustomPortsToScan -Force
}

# Using the inputs selected or provided from the GUI, it scans the specified IPs or network range for specified ports
# The intent of this scan is not to be stealth, but rather find hosts; such as those not in active directory
# The results can be added to the computer treenodes
Update-FormProgress "$Dependencies\Code\Execution\Enumeration\Conduct-PortScan.ps1"
. "$Dependencies\Code\Execution\Enumeration\Conduct-PortScan.ps1"


#batman
function Check-IfScanExecutionReady {
    Generate-ComputerList
    $IPv4Pattern = "([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){3}"
    $ClassC = "^([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){2}$"
    $PortPattern = "([0-9]{1,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])"
    $InvalidChars = "abcdefghijklmnopqrstuvwxyz~``'`"!@#$%^&*()_+-=[]{}|\/?<>"
    if (
        (
            (
                ($script:EnumerationPortScanSpecificComputerNodeCheckbox.checked) -and 
                ($script:computerList.count -gt 0)
            ) -or 
            (
                ($EnumerationPortScanSpecificIPTextbox.text -match $IPv4Pattern)
            ) -or
            (
                (
                    ($EnumerationPortScanIPRangeNetworkTextbox.text -match $ClassC)
                ) -and
                (
                    ($EnumerationPortScanIPRangeFirstTextbox.text -gt 0 ) -and 
                    ($EnumerationPortScanIPRangeFirstTextbox.text -lt 255) -and 
                    ($EnumerationPortScanIPRangeFirstTextbox.text -le $EnumerationPortScanIPRangeLastTextbox.text)
                ) -and
                (
                    ($EnumerationPortScanIPRangeLastTextbox.text -gt 0 ) -and 
                    ($EnumerationPortScanIPRangeLastTextbox.text -lt 255) -and 
                    ($EnumerationPortScanIPRangeLastTextbox.text -ge $EnumerationPortScanIPRangeFirstTextbox.text)
                )
            )
        ) -and
        (
            (
                ($EnumerationPortScanPortQuickPickComboBox.text -ne 'Quick-Pick Port Selection') -and
                ($EnumerationPortScanPortQuickPickComboBox.selectedItem -ne 'N/A')
            ) -or
            (
                ($EnumerationPortScanSpecificPortsTextbox.text -match $PortPattern)
            ) -or
            (
                (
                    ($EnumerationPortScanPortRangeFirstTextbox.text -ge 0) -and
                    ($EnumerationPortScanPortRangeFirstTextbox.text -le 65535) -and
                    ($EnumerationPortScanPortRangeFirstTextbox.text -le $EnumerationPortScanPortRangeLastTextbox.text)
                ) -and
                (
                    ($EnumerationPortScanPortRangeLastTextbox.text -ge 0) -and
                    ($EnumerationPortScanPortRangeLastTextbox.text -le 65535) -and
                    ($EnumerationPortScanPortRangeLastTextbox.text -ge $EnumerationPortScanPortRangeFirstTextbox.text)
                )
            ) 
        ) -and
        (
            ($EnumerationPortScanTimeoutTextbox.text -gt 0) -and 
            ($EnumerationPortScanTimeoutTextbox.text -match "\d")
        )
    ) {
        $EnumerationPortScanExecutionButton.enabled = $true
        $EnumerationPortScanExecutionButton.BackColor = 'LightGreen'
    }
    else {
        $EnumerationPortScanExecutionButton.enabled = $false
        $EnumerationPortScanExecutionButton.BackColor = 'LightGray'
    }
}


$EnumerationPortScanGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text   = "Create List From TCP Port Scan"
    Left   = 0
    Top    = $FormScale * 13
    Width  = $FormScale * 294
    Height = $FormScale * 350
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
    Add_MouseEnter = {Check-IfScanExecutionReady}
    Add_MouseLeave = {Check-IfScanExecutionReady}
}
           $script:EnumerationPortScanSpecificComputerNodeCheckbox = New-Object System.Windows.Forms.checkbox -Property @{
                Text   = "Scan Checkboxed Endpoints"
                Left   = $FormScale * 3
                Top    = $FormScale * 15
                Width  = $FormScale * 185
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor     = "Black"
                Add_Click = {
                    $ComputerAndAccountTreeViewTabControl.SelectedTab = $ComputerTreeviewTab
                    $script:ComputerTreeNodeComboBox.SelectedItem = 'CanonicalName'
    
                    if ($this.checked){
                        $EnumerationPortScanSpecificIPTextbox.enabled     = $false
                        $EnumerationPortScanIPRangeNetworkTextbox.enabled = $false
                        $EnumerationPortScanIPRangeFirstTextbox.enabled   = $false
                        $EnumerationPortScanIPRangeLastTextbox.enabled    = $false
                        $EnumerationPortScanSpecificIPTextbox.text     = ""
                        $EnumerationPortScanIPRangeNetworkTextbox.text = ""
                        $EnumerationPortScanIPRangeFirstTextbox.text   = ""
                        $EnumerationPortScanIPRangeLastTextbox.text    = ""
                    }
                    else {
                        $EnumerationPortScanSpecificIPTextbox.enabled     = $true
                        $EnumerationPortScanIPRangeNetworkTextbox.enabled = $true
                        $EnumerationPortScanIPRangeFirstTextbox.enabled   = $true
                        $EnumerationPortScanIPRangeLastTextbox.enabled    = $true
                    }
                    Check-IfScanExecutionReady
                }
                Add_MouseEnter = {Check-IfScanExecutionReady}
            }
            $EnumerationPortScanGroupBox.Controls.Add($script:EnumerationPortScanSpecificComputerNodeCheckbox)


            # $script:EnumerationPortScanMonitorJobsCheckbox = New-Object System.Windows.Forms.checkbox -Property @{
            #     Text   = "Monitor as Job"
            #     Left   = $script:EnumerationPortScanSpecificComputerNodeCheckbox.Left + $script:EnumerationPortScanSpecificComputerNodeCheckbox.Width
            #     Top    = $script:EnumerationPortScanSpecificComputerNodeCheckbox.Top
            #     Width  = $FormScale * 100
            #     Height = $FormScale * 22
            #     Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            #     ForeColor     = "Black"
            # }
            # $EnumerationPortScanGroupBox.Controls.Add($script:EnumerationPortScanMonitorJobsCheckbox)

            
            $EnumerationPortScanIPNote1Label = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Enter Comma Separated IPs (ex: 10.0.0.1,10.0.0.2)"
                Left   = $script:EnumerationPortScanSpecificComputerNodeCheckbox.Left
                Top    = $script:EnumerationPortScanSpecificComputerNodeCheckbox.Top + $script:EnumerationPortScanSpecificComputerNodeCheckbox.Height
                Width  = $FormScale * 250
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor  = "Black"
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPNote1Label)


            $EnumerationPortScanSpecificIPTextbox = New-Object System.Windows.Forms.TextBox -Property @{
                Text   = ""
                Left   = $EnumerationPortScanIPNote1Label.Left
                Top    = $EnumerationPortScanIPNote1Label.Top + $EnumerationPortScanIPNote1Label.Height
                Width  = $FormScale * 287
                Height = $FormScale * 22
                MultiLine     = $False
                WordWrap      = $True
                AcceptsTab    = $false
                AcceptsReturn = $false
                Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor     = "Black"
                Add_Click      = {Check-IfScanExecutionReady}
                Add_MouseEnter = {Check-IfScanExecutionReady}
                Add_MouseLeave = {Check-IfScanExecutionReady}
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanSpecificIPTextbox)


            $EnumerationPortScanIPRangeNote1Label = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Network Range:  (ex: [ 192.168.1 ]  [ 1 ]  [ 100 ])"
                Left   = $EnumerationPortScanSpecificIPTextbox.Left
                Top    = $EnumerationPortScanSpecificIPTextbox.Top + $EnumerationPortScanSpecificIPTextbox.Height + ($FormScale + 5)
                Width  = $FormScale * 250
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor  = "Blue"
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPRangeNote1Label)


            $EnumerationPortScanIPRangeNetworkLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Network"
                Left   = $EnumerationPortScanIPRangeNote1Label.left
                Top    = $EnumerationPortScanIPRangeNote1Label.Top + $EnumerationPortScanIPRangeNote1Label.Height
                Width  = $FormScale * 80
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor = "Black"
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPRangeNetworkLabel)


            $EnumerationPortScanIPRangeNetworkTextbox = New-Object System.Windows.Forms.TextBox -Property @{
                Text   = ""
                Left   = $EnumerationPortScanIPRangeNetworkLabel.Left
                Top    = $EnumerationPortScanIPRangeNetworkLabel.Top + $EnumerationPortScanIPRangeNetworkLabel.Height
                Width  = $EnumerationPortScanIPRangeNetworkLabel.Width
                Height = $FormScale * 22
                MultiLine     = $False
                WordWrap      = $True
                AcceptsTab    = $false
                AcceptsReturn = $false
                Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor     = "Black"
                Add_Click      = {Check-IfScanExecutionReady}
                Add_MouseEnter = {Check-IfScanExecutionReady}
                Add_MouseLeave = {Check-IfScanExecutionReady}
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPRangeNetworkTextbox)


            $EnumerationPortScanIPRangeFirstLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "First IP"
                Left   = $EnumerationPortScanIPRangeNetworkTextbox.Left  + $EnumerationPortScanIPRangeNetworkTextbox.Width + $($FormScale * 20)
                Top    = $EnumerationPortScanIPRangeNetworkLabel.Top
                Width  = $EnumerationPortScanIPRangeNetworkLabel.Width
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor = "Black"
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPRangeFirstLabel)


            $EnumerationPortScanIPRangeFirstTextbox = New-Object System.Windows.Forms.TextBox -Property @{
                Text   = ""
                Left   = $EnumerationPortScanIPRangeFirstLabel.Left
                Top    = $EnumerationPortScanIPRangeFirstLabel.Top + $EnumerationPortScanIPRangeFirstLabel.Height
                Width  = $EnumerationPortScanIPRangeFirstLabel.Width
                Height = $FormScale * 22
                MultiLine     = $False
                WordWrap      = $True
                AcceptsTab    = $false
                AcceptsReturn = $false
                Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor     = "Black"
                Add_Click      = {Check-IfScanExecutionReady}
                Add_MouseEnter = {Check-IfScanExecutionReady}
                Add_MouseLeave = {Check-IfScanExecutionReady}
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPRangeFirstTextbox)


            $EnumerationPortScanIPRangeLastLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Last IP"
                Left   = $EnumerationPortScanIPRangeFirstLabel.Left + $EnumerationPortScanIPRangeFirstLabel.Width + $($FormScale * 20)
                Top    = $EnumerationPortScanIPRangeFirstLabel.Top
                Width  = $EnumerationPortScanIPRangeNetworkLabel.Size.Width
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor = "Black"
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPRangeLastLabel)


            $EnumerationPortScanIPRangeLastTextbox = New-Object System.Windows.Forms.TextBox -Property @{
                Text   = ""
                Left   = $EnumerationPortScanIPRangeLastLabel.Left
                Top    = $EnumerationPortScanIPRangeLastLabel.Top + $EnumerationPortScanIPRangeLastLabel.Height
                Width  = $EnumerationPortScanIPRangeLastLabel.Size.Width
                Height = $FormScale * 20
                MultiLine     = $False
                WordWrap      = $True
                AcceptsTab    = $false
                AcceptsReturn = $false
                Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor     = "Black"
                Add_Click      = {Check-IfScanExecutionReady}
                Add_MouseEnter = {Check-IfScanExecutionReady}
                Add_MouseLeave = {Check-IfScanExecutionReady}
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPRangeLastTextbox)


            $EnumerationPortScanPortNote1Label = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Comma Separated Ports:  (ex: 22,80,135,445)"
                Left   = $EnumerationPortScanIPRangeNetworkLabel.Left
                Top    = $EnumerationPortScanIPRangeLastTextbox.Top + $EnumerationPortScanIPRangeLastTextbox.Height + $($FormScale * 5)
                Width  = $FormScale * 290
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor  = "Blue"
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortNote1Label)


            $EnumerationPortScanSpecificPortsTextbox = New-Object System.Windows.Forms.TextBox -Property @{
                Text   = ""
                Left   = $EnumerationPortScanPortNote1Label.Left
                Top    = $EnumerationPortScanPortNote1Label.Top + $EnumerationPortScanPortNote1Label.Height
                Width  = $FormScale * 288
                Height = $FormScale * 22
                MultiLine     = $False
                WordWrap      = $True
                AcceptsTab    = $false
                AcceptsReturn = $false
                Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor     = "Black"
                Add_Click      = {Check-IfScanExecutionReady}
                Add_MouseEnter = {Check-IfScanExecutionReady}
                Add_MouseLeave = {Check-IfScanExecutionReady}
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanSpecificPortsTextbox)


            Update-FormProgress "$Dependencies\Code\System.Windows.Forms\ComboBox\EnumerationPortScanPortQuickPickComboBox.ps1"
            . "$Dependencies\Code\System.Windows.Forms\ComboBox\EnumerationPortScanPortQuickPickComboBox.ps1"
            $EnumerationPortScanPortQuickPickComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
                Text   = "Quick-Pick Port Selection"
                Left   = $EnumerationPortScanSpecificPortsTextbox.Left
                Top    = $EnumerationPortScanSpecificPortsTextbox.Top + $EnumerationPortScanSpecificPortsTextbox.Height + $($FormScale * 10)
                Width  = $FormScale * 183
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor     = "Black"
                Add_Click = $EnumerationPortScanPortQuickPickComboBoxAdd_Click
                Add_MouseEnter = {Check-IfScanExecutionReady}
            }
            $EnumerationPortScanPortQuickPickComboBox.Items.AddRange($EnumerationPortScanPortQuickPickComboBoxItemsAddRange)
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortQuickPickComboBox)


            Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\EnumerationPortScanPortsSelectionButton.ps1"
            . "$Dependencies\Code\System.Windows.Forms\Button\EnumerationPortScanPortsSelectionButton.ps1"
            $EnumerationPortScanPortsSelectionButton = New-Object System.Windows.Forms.Button -Property @{
                Text   = "Select Ports"
                Left   = $EnumerationPortScanPortQuickPickComboBox.Left + $EnumerationPortScanPortQuickPickComboBox.Width + $($FormScale * 4)
                Top    = $EnumerationPortScanPortQuickPickComboBox.Top
                Width  = $FormScale * 100
                Height = $FormScale * 20
                Add_Click = $EnumerationPortScanPortsSelectionButtonAdd_Click
                Add_MouseEnter = {Check-IfScanExecutionReady}
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortsSelectionButton)
            Apply-CommonButtonSettings -Button $EnumerationPortScanPortsSelectionButton


            $EnumerationPortScanPortRangeNetworkLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Port Range"
                Left   = $EnumerationPortScanPortQuickPickComboBox.Left
                Top    = $EnumerationPortScanPortsSelectionButton.Top + $EnumerationPortScanPortsSelectionButton.Height + ($FormScale + 10)
                Width  = $FormScale * 83
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor = "Blue"
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortRangeNetworkLabel)


            $EnumerationPortScanPortRangeFirstLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "First Port"
                Left   = $EnumerationPortScanIPRangeFirstLabel.Left
                Top    = $EnumerationPortScanPortRangeNetworkLabel.Top
                Width  = $EnumerationPortScanIPRangeFirstLabel.Width
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor = "Black"
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortRangeFirstLabel)


            $EnumerationPortScanPortRangeFirstTextbox = New-Object System.Windows.Forms.TextBox -Property @{
                Text   = ""
                Left   = $EnumerationPortScanPortRangeFirstLabel.Left
                Top    = $EnumerationPortScanPortRangeFirstLabel.Top + $EnumerationPortScanPortRangeFirstLabel.Height
                Width  = $EnumerationPortScanPortRangeFirstLabel.Width
                Height = $FormScale * 22
                MultiLine     = $False
                WordWrap      = $True
                AcceptsTab    = $false # Allows you to enter in tabs into the textbox
                AcceptsReturn = $false # Allows you to enter in returnss into the textbox
                Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor     = "Black"
                Add_Click      = {Check-IfScanExecutionReady}
                Add_MouseEnter = {Check-IfScanExecutionReady}
                Add_MouseLeave = {Check-IfScanExecutionReady}
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortRangeFirstTextbox)


            $EnumerationPortScanPortRangeLastLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Last Port"
                Left   = $EnumerationPortScanIPRangeLastLabel.Left
                Top    = $EnumerationPortScanPortRangeFirstLabel.Top
                Width  = $EnumerationPortScanPortRangeFirstTextbox.Width
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor = "Black"
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortRangeLastLabel)


            $EnumerationPortScanPortRangeLastTextbox = New-Object System.Windows.Forms.TextBox -Property @{
                Text   = ""
                Left   = $EnumerationPortScanPortRangeLastLabel.Left
                Top    = $EnumerationPortScanPortRangeLastLabel.Top + $EnumerationPortScanPortRangeLastLabel.Height
                Width  = $EnumerationPortScanPortRangeLastLabel.Width
                Height = $FormScale * 22
                MultiLine     = $False
                WordWrap      = $True
                AcceptsTab    = $false # Allows you to enter in tabs into the textbox
                AcceptsReturn = $false # Allows you to enter in returnss into the textbox
                Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor     = "Black"
                Add_Click      = {Check-IfScanExecutionReady}
                Add_MouseEnter = {Check-IfScanExecutionReady}
                Add_MouseLeave = {Check-IfScanExecutionReady}
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortRangeLastTextbox)


            $EnumerationPortScanTestICMPFirstCheckBox = New-Object System.Windows.Forms.CheckBox -Property @{
                Text   = "Ping First"
                Left   = $EnumerationPortScanPortRangeNetworkLabel.Left
                Top    = $EnumerationPortScanPortRangeLastTextbox.Top + $EnumerationPortScanPortRangeLastTextbox.Height + ($FormScale * 5)
                Width  = $EnumerationPortScanIPRangeNetworkLabel.Size.Width
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor = "Black"
                Checked   = $False
                Add_Click      = {Check-IfScanExecutionReady}
                Add_MouseEnter = {Check-IfScanExecutionReady}
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanTestICMPFirstCheckBox)


            $EnumerationPortScanTimeoutLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Timeout (ms)"
                Left   = $EnumerationPortScanPortRangeFirstLabel.Left
                Top    = $EnumerationPortScanTestICMPFirstCheckBox.Top
                Width  = $EnumerationPortScanIPRangeNetworkTextbox.Width
                Height = $FormScale * 20
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor = "Black"
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanTimeoutLabel)


            $EnumerationPortScanTimeoutTextbox = New-Object System.Windows.Forms.TextBox -Property @{
                Text   = 50
                Left   = $EnumerationPortScanTimeoutLabel.Left
                Top    = $EnumerationPortScanTimeoutLabel.Top + $EnumerationPortScanTimeoutLabel.Height
                Width  = $EnumerationPortScanIPRangeNetworkTextbox.Width
                Height = $FormScale * 22
                MultiLine     = $False
                WordWrap      = $True
                AcceptsTab    = $false
                AcceptsReturn = $false
                Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor     = "Black"
                Add_Click      = {Check-IfScanExecutionReady}
                Add_MouseEnter = {Check-IfScanExecutionReady}
                Add_MouseLeave = {Check-IfScanExecutionReady}
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanTimeoutTextbox)


            Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\EnumerationPortScanExecutionButton.ps1"
            . "$Dependencies\Code\System.Windows.Forms\Button\EnumerationPortScanExecutionButton.ps1"
            $EnumerationPortScanExecutionButton = New-Object System.Windows.Forms.Button -Property @{
                Text   = "Execute Scan"
                Left   = $FormScale * 190
                Top    = $EnumerationPortScanTimeoutTextbox.Top
                Width  = $FormScale * 100
                Height = $FormScale * 22
                Enabled   = $false
                Add_Click = $EnumerationPortScanExecutionButtonAdd_Click
                Add_MouseHover = {
                    Check-IfScanExecutionReady
Show-ToolTip -Title "Execute Scan" -Icon "Info" -Message @"
+  Reference Port Check:
     New-Object System.Net.Sockets.TcpClient("<Hostname/IP>", 139)
"@
                }
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanExecutionButton)
            Apply-CommonButtonSettings -Button $EnumerationPortScanExecutionButton

$Section1EnumerationTab.Controls.Add($EnumerationPortScanGroupBox)


# Using the inputs selected or provided from the GUI, it conducts a basic ping sweep
# The results can be added to the computer treenodes
# Lists all IPs in a subnet
Update-FormProgress "$Dependencies\Code\Main Body\Get-SubnetRange.ps1"
. "$Dependencies\Code\Main Body\Get-SubnetRange.ps1"

Update-FormProgress "$Dependencies\Code\Execution\Enumeration\Conduct-PingSweep.ps1"
. "$Dependencies\Code\Execution\Enumeration\Conduct-PingSweep.ps1"


# Create a group that will contain your radio buttons
$EnumerationPingSweepGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text   = "Create List From Ping Sweep"
    Left   = 0
    Top    = $EnumerationPortScanGroupBox.Top + $EnumerationPortScanGroupBox.Height + $($FormScale * $EnumerationGroupGap)
    Width  = $FormScale * 294
    Height = $FormScale * 70
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
    Add_MouseEnter = {Check-IfScanExecutionReady}
    Add_MouseLeave = {Check-IfScanExecutionReady}
}
            $EnumerationPingSweepNote1Label = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Enter Network/CIDR: (ex: 10.0.0.0/24)"
                Left   = $FormScale * 3
                Top    = $FormScale * 20
                Width  = $FormScale * 180
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor  = "Black"
            }
            $EnumerationPingSweepGroupBox.Controls.Add($EnumerationPingSweepNote1Label)


            Update-FormProgress "$Dependencies\Code\System.Windows.Forms\TextBox\EnumerationPingSweepIPNetworkCIDRTextbox.ps1"
            . "$Dependencies\Code\System.Windows.Forms\TextBox\EnumerationPingSweepIPNetworkCIDRTextbox.ps1"
            $EnumerationPingSweepIPNetworkCIDRTextbox = New-Object System.Windows.Forms.TextBox -Property @{
                Text   = ""
                Left   = $FormScale * 190
                Top    = $EnumerationPingSweepNote1Label.Top
                Width  = $FormScale * 100
                Height = $FormScale * $EnumerationLabelHeight
                MultiLine     = $False
                WordWrap      = $True
                AcceptsTab    = $false
                AcceptsReturn = $false
                Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor     = "Black"
                Add_KeyDown   = $EnumerationPingSweepIPNetworkCIDRTextboxAdd_KeyDown
                Add_MouseEnter = {Check-IfScanExecutionReady}
                Add_MouseLeave = {Check-IfScanExecutionReady}
            }
            $EnumerationPingSweepGroupBox.Controls.Add($EnumerationPingSweepIPNetworkCIDRTextbox)


            Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\EnumerationPingSweepExecutionButton.ps1"
            . "$Dependencies\Code\System.Windows.Forms\Button\EnumerationPingSweepExecutionButton.ps1"
            $EnumerationPingSweepExecutionButton = New-Object System.Windows.Forms.Button -Property @{
                Text   = "Execute Sweep"
                Left   = $EnumerationPingSweepIPNetworkCIDRTextbox.Left
                Top    = $EnumerationPingSweepIPNetworkCIDRTextbox.Top + $EnumerationPingSweepIPNetworkCIDRTextbox.Height + ($FormScale * 8)
                Width  = $FormScale * 100
                Height = $FormScale * 22
                Add_Click = $EnumerationPingSweepExecutionButtonAdd_Click
            }
            $EnumerationPingSweepGroupBox.Controls.Add($EnumerationPingSweepExecutionButton)
            Apply-CommonButtonSettings -Button $EnumerationPingSweepExecutionButton
$Section1EnumerationTab.Controls.Add($EnumerationPingSweepGroupBox)


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\EnumerationResolveDNSNameButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\EnumerationResolveDNSNameButton.ps1"
$EnumerationResolveDNSNameButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "DNS Resolution"
    Left   = $EnumerationPortScanGroupBox.Left + $EnumerationPortScanGroupBox.Width + ($FormScale + 15)
    Top    = $EnumerationPortScanGroupBox.Top + ($FormScale + 13)
    Width  = $FormScale * 152
    Height = $FormScale * 22
    Add_Click = $EnumerationResolveDNSNameButtonAdd_Click
}
$Section1EnumerationTab.Controls.Add($EnumerationResolveDNSNameButton)
Apply-CommonButtonSettings -Button $EnumerationResolveDNSNameButton


$EnumerationComputerListBox = New-Object System.Windows.Forms.ListBox -Property @{
    Left   = $EnumerationResolveDNSNameButton.Left
    Top    = $EnumerationResolveDNSNameButton.Top + $EnumerationResolveDNSNameButton.Height + ($FormScale + 10)
    Width  = $FormScale * 152
    Height = $EnumerationResolveDNSNameButton.Size.Height + $( $FormScale * 350)
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    SelectionMode = 'MultiExtended'
    Add_MouseEnter = {Check-IfScanExecutionReady}
    Add_MouseLeave = {Check-IfScanExecutionReady}
}
$EnumerationComputerListBox.Items.Add("127.0.0.1")
$Section1EnumerationTab.Controls.Add($EnumerationComputerListBox)


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\EnumerationComputerListBoxAddToListButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\EnumerationComputerListBoxAddToListButton.ps1"
$EnumerationComputerListBoxAddToListButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Add To Computer List"
    Left   = $EnumerationResolveDNSNameButton.Left
    Top    = $EnumerationComputerListBox.Top + $EnumerationComputerListBox.Height + ($FormScale + 5)
    Width  = $EnumerationResolveDNSNameButton.Width
    Height = $FormScale * 22
    Add_Click = {
        $InformationTabControl.SelectedTab = $Section3ResultsTab

        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Enumeration:  Added $($EnumerationComputerListBox.SelectedItems.Count) IPs")
        #Removed For Testing#
        $ResultsListBox.Items.Clear()
        foreach ($Selected in $EnumerationComputerListBox.SelectedItems) {
            if ($script:ComputerTreeViewData.Name -contains $Selected) {
                Message-NodeAlreadyExists -Endpoint -Message "Port Scan Import:  Warning" -Computer $Selected
            }
            else {
                $ComputerAndAccountTreeViewTabControl.SelectedTab = $ComputerTreeviewTab
                $script:ComputerTreeNodeComboBox.SelectedItem = 'CanonicalName'

                $CanonicalName = $($($Computer.CanonicalName) -replace $Computer.Name,"" -replace $Computer.CanonicalName.split('/')[0],"").TrimEnd("/")
                AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category '/Unknown' -Entry $Selected -ToolTip 'Enumeration Scan' -IPv4Address $Computer.IPv4Address
                $ResultsListBox.Items.Add("$($Selected) has been added to /Unknown category")

                $ComputerTreeNodeAddHostnameIP = New-Object PSObject -Property @{
                    Name            = $Selected
                    OperatingSystem = 'Unknown'
                    CanonicalName   = '/Unknown'
                    IPv4Address     = $Selected
                }
                $script:ComputerTreeViewData += $ComputerTreeNodeAddHostnameIP
            }
        }
        $script:ComputerTreeView.ExpandAll()
        Normalize-TreeViewData -Endpoint
        Save-TreeViewData -Endpoint
    }
}
$Section1EnumerationTab.Controls.Add($EnumerationComputerListBoxAddToListButton)
Apply-CommonButtonSettings -Button $EnumerationComputerListBoxAddToListButton


$EnumerationComputerListBoxSelectAllButton = New-Object System.Windows.Forms.Button -Property @{
    Left   = $EnumerationComputerListBoxAddToListButton.Left
    Top    = $EnumerationComputerListBoxAddToListButton.Top + $EnumerationComputerListBoxAddToListButton.Height + ($FormScale + 10)
    Width  = $EnumerationResolveDNSNameButton.Width
    Height = $FormScale * 22
    Text   = "Select All"
    Add_Click = {
        for($i = 0; $i -lt $EnumerationComputerListBox.Items.Count; $i++) { $EnumerationComputerListBox.SetSelected($i, $true) }
    }
}
$Section1EnumerationTab.Controls.Add($EnumerationComputerListBoxSelectAllButton)
Apply-CommonButtonSettings -Button $EnumerationComputerListBoxSelectAllButton


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\EnumerationComputerListBoxClearButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\EnumerationComputerListBoxClearButton.ps1"
$EnumerationComputerListBoxClearButton = New-Object System.Windows.Forms.Button -Property @{
    Left   = $EnumerationComputerListBoxSelectAllButton.Left
    Top    = $EnumerationComputerListBoxSelectAllButton.Top + $EnumerationComputerListBoxSelectAllButton.Height + ($FormScale + 10)
    Width  = $EnumerationResolveDNSNameButton.Width
    Height = $FormScale * 22
    Text   = 'Clear List'
    Add_Click = $EnumerationComputerListBoxClearButtonAdd_Click
}
$Section1EnumerationTab.Controls.Add($EnumerationComputerListBoxClearButton)
Apply-CommonButtonSettings -Button $EnumerationComputerListBoxClearButton
