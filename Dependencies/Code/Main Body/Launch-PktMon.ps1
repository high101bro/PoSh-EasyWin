Function Launch-PktMon {

#https://docs.microsoft.com/en-us/windows-server/networking/technologies/pktmon/pktmon-syntax
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Windows.Drawing

#############################################################################################################
##################### Add code to check if Windows version support pktmon ###################################
#############################################################################################################

         <#
        $FileTransferPropertyList0PictureBox = New-Object Windows.Forms.PictureBox -Property @{
            Text   = "PowerShell Charts"
            Left   = $FormScale * 10
            Top    = $FormScale * 10
            Width  = $FormScale * 275
            Height = $FormScale * 44
            Image  = [System.Drawing.Image]::Fromfile("$Dependencies\Images\Send_Files_Banner.png")
            SizeMode = 'StretchImage'
        }
        $PktMonPacketCaptureForm.Controls.Add($FileTransferPropertyList0PictureBox)
        #>
$PktMonPacketCaptureForm = New-Object System.Windows.Forms.Form -Property @{
    Text   = "PoSh-EasyWin - Packet Monitor (PktMon.exe)"
    Width  = $FormScale * 750
    Height = $FormScale * 625
    StartPosition = "CenterScreen"
    Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$script:EasyWinIcon")
    Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoScroll    = $True
    #FormBorderStyle =  "fixed3d"
    #ControlBox    = $false
    MaximizeBox   = $false
    MinimizeBox   = $false
    ShowIcon      = $true
    TopMost       = $false
    Add_Shown     = $null
    Add_load = {
        $ScriptBlock = {
            $script:ProgressBarMainLabel.text = "Attempting to establish PowerShell sessions with $($script:ComputerList.count) endpoints."
            $script:ProgressBarMessageLabel.text = @"
Open Sessions: $($session | Where-Object {$_.State -match 'Open'})
"@
            $script:ProgressBarFormProgressBar.Value = 0
            $script:ProgressBarFormProgressBar.Maximum = $script:ComputerList.Count
            
            $script:PSSessionPktMon = New-PSSession -ComputerName $script:ComputerList -Credential $script:Credential

            $script:ProgressBarMessageLabel.text = @"
Open Sessions: $($session | Where-Object {$_.State -match 'Open'})
"@
            $script:ProgressBarFormProgressBar.Value = $script:ComputerList.Count
            Start-Sleep -Seconds 1
            $script:ProgressBarSelectionForm.Hide()            
        }

        Launch-ProgressBarForm -FormTitle "PoSh-EasyWin - Establishing Connection" -ScriptBlockProgressBarInput $ScriptBlock -Height $($FormScale * 155)

        $script:SupportsType = $null
        $script:SupportsType = Invoke-Command -ScriptBlock {PktMon start help | Select-String -Pattern '--type'} -Session $script:PSSessionPktMon

        $script:SupportsCountersOnly = $null
        $script:SupportsCountersOnly = Invoke-Command -ScriptBlock {PktMon start help | Select-String -Pattern '--counters-only'} -Session $script:PSSessionPktMon

        $script:SupportsPktSize = $null
        $script:SupportsPktSize = Invoke-Command -ScriptBlock {PktMon start help | Select-String -Pattern '--pkt-size'} -Session $script:PSSessionPktMon

        $script:SupportsFlags = $null
        $script:SupportsFlags = Invoke-Command -ScriptBlock {PktMon start help | Select-String -Pattern '--flags'} -Session $script:PSSessionPktMon

        $script:SupportsKeywords = $null
        $script:SupportsKeywords = Invoke-Command -ScriptBlock {PktMon start help | Select-String -Pattern '--keywords'} -Session $script:PSSessionPktMon

        $script:SupportsCapture = $null
        $script:SupportsCapture = Invoke-Command -ScriptBlock {PktMon start help | Select-String -Pattern '--capture'} -Session $script:PSSessionPktMon

        # Checks for pktmon.exe on endpoints
        $script:PktMonCheckComputerList = @()
        foreach ($Session in $script:PSSessionPktMon) {
            if (-not (Invoke-Command -ScriptBlock { Get-Command PktMon.exe } -Session $Session)) {
                $script:PktMonCheckComputerList += $Session.ComputerName
            }
        }

        # Removed sessions that didn't have pktmon
        foreach ($Session in $script:PSSessionPktMon) {
            if ($Session.ComputerName -in $script:PktMonCheckComputerList) {
                $Session | Remove-PSSession
                $script:PSSessionPktMon = $script:PSSessionPktMon | Where-Object {$_.ComputerName -ne $session.ComputerName}
            }
        }

        # Unchecks all endpoint nodes
        [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
        foreach ($root in $AllTreeViewNodes) { 
            $root.Checked = $false 
            foreach ($Category in $root.Nodes) { 
                $Category.Checked = $false 
                foreach ($Entry in $Category.nodes) { 
                    $Entry.Checked = $false 
                } 
            } 
        }

        # Removes endpoints that don't have pktmon.exe
        $script:PktMonCheckComputerKeepList = @()
        $PktMonComputerList = $($script:PSSessionPktMon | Where-Object {$_.State -match 'Open'}).ComputerName
        Foreach ($Computer in $PktMonComputerList) {
            if ($Computer -notin $script:PktMonCheckComputerList) {
                $script:PktMonCheckComputerKeepList += $Computer
            }
        }

        # Checks all the nodes that have sessions
        foreach ($Computer in $script:PktMonCheckComputerKeepList) {
            foreach ($root in $AllTreeViewNodes) { 
                foreach ($Category in $root.Nodes) { 
                    foreach ($Entry in $Category.nodes) { 
                        if ($Entry.Text -eq $Computer){ 
                            $Entry.Checked = $true 
                        } 
                    } 
                } 
            }
        }
        Update-TreeViewData -Endpoint -TreeView $script:ComputerTreeView.Nodes

        function script:Update-PktMonFilterListBox {           
            $PktMonFilterListListBox.Items.Clear()
            foreach ($Session in $script:PSSessionPktMon) {
                $PktMonFilterListResults = Invoke-Command -ScriptBlock {
                    & PktMon filter list | Where-Object {$_ -notmatch '----'}
                } -Session $Session

                $Tabs = $PktMonFilterTabControl.Controls `
                | Where-Object {$_.name -eq "$($Session.ComputerName)"}
                
                # Adds the filter results to each listbox specific to the targetcomputer
                $Tabs.Controls `
                | Where-Object {$_.name -eq $($Session.ComputerName)} `
                | ForEach-Object {
                    $_.Items.Clear()
                    #$_.Items.Add($Session.ComputerName) 
                    foreach ($Filter in $PktMonFilterListResults) {
                        $_.Items.Add("$Filter")
                    }                
                }
            }
        }

        function Populate-EndpointFilterTabs {
            $PktMonFilterTabControl.TabPages.Clear()
    
            foreach ($Session in $script:PSSessionPktMon) {
                Invoke-Expression @"
                `$PktMonRandomId = Get-Random
                `$script:PktMonFilterTabPage$PktMonRandomId = New-Object System.Windows.Forms.TabPage -Property @{
                    Name   = "`$(`$Session.ComputerName)"
                    Text   = "`$(`$Session.ComputerName)  "
                    Width  = `$FormScale * 710
                    Height = `$FormScale * 125
                    Font   = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 11),0,0,0)
                    UseVisualStyleBackColor = `$True
                }
                `$PktMonFilterTabControl.Controls.Add(`$script:PktMonFilterTabPage$PktMonRandomId)


                `$PktMonFilterListListBox$PktMonRandomId = New-Object System.Windows.Forms.ListBox -Property @{
                    Name   = "`$(`$Session.ComputerName)"
                    Text   = `$null
                    Left   = 0
                    Top    = `$FormScale * 2
                    Width  = `$PktMonOnlyPacketCountersCheckbox.Width + `$PktMonOnlyPacketCountersArgLabel.Width + `$(`$FormScale * 5) + `$PktMonComponentComboBox.Width
                    Height = `$FormScale * 125
                    Font   = New-Object System.Drawing.Font("Courier New",`$(`$FormScale * 11),0,0,0)
                    ForeColor  = 'Black'
                    SelectionMode = 'MultiExtended'
                    ScrollAlwaysVisible  = `$true
                    Add_MouseEnter = { `$PktMonFilterListSelectionComboBox.text = `$PktMonFilterListSelectionComboBox.SelectedItem -replace '\s+',' ' }
                    Add_MouseLeave = { `$PktMonFilterListSelectionComboBox.text = `$PktMonFilterListSelectionComboBox.SelectedItem -replace '\s+',' ' }
                    Add_Click = { script:Update-PktMonFilterListBox }
                }
                `$script:PktMonFilterTabPage$PktMonRandomId.Controls.Add(`$PktMonFilterListListBox$PktMonRandomId)
"@
            }
        }

        Populate-EndpointFilterTabs
        script:Update-PktMonFilterListBox
    }
    Add_Closing = {
        param($sender,$Selection)
        if ($script:PktMonCaptureStartButton.enabled -eq $false) {
            [System.Windows.Forms.MessageBox]::Show("All existing PowerShell sessions will be removed.`n`nAny running packet captures will be continue on the endpoints.","PoSh-EasyWin",'Ok',"Warning")
        }

        $script:VerifyCloseForm = New-Object System.Windows.Forms.Form -Property @{
            Text    = "Packet Capture"
            Width   = $FormScale * 250
            Height  = $FormScale * 109
            TopMost = $true
            Icon    = [System.Drawing.Icon]::ExtractAssociatedIcon("$script:EasyWinIcon")
            Font    = New-Object System.Drawing.Font("$Font",($FormScale * 11),0,0,0)
            FormBorderStyle =  'Fixed3d'
            StartPosition   = 'CenterScreen'
            showintaskbar   = $true
            ControlBox      = $true
            MaximizeBox     = $false
            MinimizeBox     = $false
            Add_Closing = {
                if     ($script:VerifyToCloseForm -eq $true) { $Selection.Cancel = $false }
                elseif ($script:VerifyToCloseForm -eq $false){ $Selection.Cancel = $true }
                else   { $Selection.Cancel = $true  }
                $this.TopMost = $false
                $this.dispose()
                $this.close()
            }
        }
        $VerifyCloseLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = 'Do you want to close this form?'
            Width  = $FormScale * 250
            Height = $FormScale * 22
            Left   = $FormScale * 10
            Top    = $FormScale * 10
        }
        $script:VerifyCloseForm.Controls.Add($VerifyCloseLabel)
    
    
        $VerifyYesButton = New-Object System.Windows.Forms.Button -Property @{
            Text   = 'Yes'
            Width  = $FormScale * 100
            Height = $FormScale * 22
            Left   = $FormScale * 10
            Top    = $VerifyCloseLabel.Top + $VerifyCloseLabel.Height
            BackColor = 'LightGray'
            Add_Click = {
                $script:PSSessionPktMon | Remove-PSSession
                $script:Timer.Stop()
                $This.dispose()

                $script:VerifyToCloseForm = $True
                $script:VerifyCloseForm.close()
            }
        }
        $script:VerifyCloseForm.Controls.Add($VerifyYesButton)
    
        $VerifyNoButton = New-Object System.Windows.Forms.Button -Property @{
            Text   = 'No'
            Width  = $FormScale * 100
            Height = $FormScale * 22
            Left   = $VerifyYesButton.Left + $VerifyYesButton.Width + ($FormScale * 10)
            Top    = $VerifyYesButton.Top
            BackColor = 'LightGray'
            Add_Click = {
                $script:VerifyToCloseForm = $false
                $script:VerifyCloseForm.close()
            }
        }
        $script:VerifyCloseForm.Controls.Add($VerifyNoButton)
    
        $script:VerifyCloseForm.ShowDialog()
    }
}

    $script:OnlyPacketCounters = $null
    $PktMonOnlyPacketCountersCheckbox = New-Object System.Windows.Forms.Checkbox -Property @{
        Text   = "Collect packet counters only. No packet logging will occur."
        Left   = $FormScale * 10
        Top    = $FormScale * 10
        Width  = $FormScale * 525
        Height = $FormScale * 22
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = 'Blue'
        Checked = $false
        Add_Click = {
            if ($this.checked) {
                $script:OnlyPacketCounters = '--counters-only'
            }
            else {
                $script:OnlyPacketCounters = $null
            }
            Update-PktMonCommand
        }
    }
    $PktMonPacketCaptureForm.Controls.Add($PktMonOnlyPacketCountersCheckbox)

        $PktMonOnlyPacketCountersArgLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "--counters-only"
            Left   = $PktMonOnlyPacketCountersCheckbox.Left + $PktMonOnlyPacketCountersCheckbox.Width + $($FormScale * 5)
            Top    = $PktMonOnlyPacketCountersCheckbox.Top + $($FormScale * 6)
            Width  = $FormScale * 100
            Height = $FormScale * 16
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = 'DarkGreen'
            BackColor = 'White'
            BorderStyle = 'FixedSingle'
        }
        $PktMonPacketCaptureForm.Controls.Add($PktMonOnlyPacketCountersArgLabel)


        if (-not $script:SupportsCountersOnly) {
            $PktMonOnlyPacketCountersCheckbox.enabled = $false
            $PktMonOnlyPacketCountersArgLabel.enabled = $false
        }


    $PktMonComponentLabel = New-Object System.Windows.Forms.Label -Property @{
        Text   = "Select components to capture packets on. The default is all."
        Left   = $PktMonOnlyPacketCountersCheckbox.Left
        Top    = $PktMonOnlyPacketCountersCheckbox.Top + $PktMonOnlyPacketCountersCheckbox.Height + $($FormScale * 5)
        Width  = $PktMonOnlyPacketCountersCheckbox.Width
        Height = $FormScale * 16
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = 'Blue'
        BackColor = 'White'
        BorderStyle = 'FixedSingle'
    }
    $PktMonPacketCaptureForm.Controls.Add($PktMonComponentLabel)


        $PktMonComponentArgLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "--comp"
            Left   = $PktMonComponentLabel.Left + $PktMonComponentLabel.Width + $($FormScale * 5)
            Top    = $PktMonComponentLabel.Top
            Width  = $PktMonOnlyPacketCountersArgLabel.Width
            Height = $FormScale * 16
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = 'DarkGreen'
            BackColor = 'White'
            BorderStyle = 'FixedSingle'
        }
        $PktMonPacketCaptureForm.Controls.Add($PktMonComponentArgLabel)


        $script:ComponentArg = $null
        $PktMonComponentComboBox = New-Object System.Windows.Forms.Combobox -Property @{
            Text   = "all"
            Left   = $PktMonComponentArgLabel.Left + $PktMonComponentArgLabel.Width + $($FormScale * 5)
            Top    = $PktMonComponentArgLabel.Top
            Width  = $FormScale * 75
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = 'Black'
            add_SelectedIndexChanged = {
                if ($this.SelectedItem -ne 'all') {
                    $script:ComponentArg = "--comp $($this.SelectedItem)"
                }
                else {
                    $script:ComponentArg = $null
                }
                Update-PktMonCommand
            }
            Add_KeyDown = { 
                if ($_.KeyCode -eq "Enter") {
                    $script:ComponentArg = "--comp $($this.text)"
                    Update-PktMonCommand            
                } 
            }
        }
        $ComponentList = @('all','nics','id1','id2','Enter ID#')
        Foreach ($Item in $ComponentList) {$PktMonComponentComboBox.Items.Add($Item)}
        $PktMonPacketCaptureForm.Controls.Add($PktMonComponentComboBox)


    $PktMonTypeLabel = New-Object System.Windows.Forms.Label -Property @{
        Text   = "Select which packets to capture. Default is all."
        Left   = $PktMonComponentLabel.Left
        Top    = $PktMonComponentLabel.Top + $PktMonComponentLabel.Height + $($FormScale * 5)
        Width  = $PktMonOnlyPacketCountersCheckbox.Width
        Height = $FormScale * 16
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = 'blue'
        BackColor = 'White'
        BorderStyle = 'FixedSingle'
    }
    $PktMonPacketCaptureForm.Controls.Add($PktMonTypeLabel)


        $PktMonTypeArgLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "--type"
            Left   = $PktMonTypeLabel.Left + $PktMonTypeLabel.Width + $($FormScale * 5)
            Top    = $PktMonTypeLabel.Top
            Width  = $PktMonOnlyPacketCountersArgLabel.Width
            Height = $FormScale * 16
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = 'DarkGreen'
            BackColor = 'White'
            BorderStyle = 'FixedSingle'
        }
        $PktMonPacketCaptureForm.Controls.Add($PktMonTypeArgLabel)


        $script:TypeArg = $null
        $PktMonTypeComboBox = New-Object System.Windows.Forms.Combobox -Property @{
            Text   = "all"
            Left   = $PktMonTypeArgLabel.Left + $PktMonTypeArgLabel.Width + $($FormScale * 5)
            Top    = $PktMonTypeArgLabel.Top
            Width  = $PktMonComponentComboBox.Width
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = 'Black'
            add_SelectedIndexChanged = {
                if ($this.SelectedItem -ne 'all') {
                    $script:TypeArg = "--type $($this.SelectedItem)"
                }
                else {
                    $script:TypeArg = $null
                }
                Update-PktMonCommand
            }
        }
        $TypeList = @('all','flow','drop')
        Foreach ($Item in $TypeList) {$PktMonTypeComboBox.Items.Add($Item)}
        $PktMonPacketCaptureForm.Controls.Add($PktMonTypeComboBox)


        if (-not $script:SupportsType) {
            $PktMonTypeLabel.enabled = $false
            $PktMonTypeArgLabel.enabled = $false
            $PktMonTypeComboBox.enabled = $false

        }


    $PktMonPktSizeLabel = New-Object System.Windows.Forms.Label -Property @{
        Text   = "Number of bytes to log from each packet. To log the entire packet select 0. The default is 128."
        Left   = $PktMonTypeLabel.Left
        Top    = $PktMonTypeLabel.Top + $PktMonTypeLabel.Height + $($FormScale * 5)
        Width  = $PktMonOnlyPacketCountersCheckbox.Width
        Height = $FormScale * 16
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = 'Blue'
        BackColor = 'White'
        BorderStyle = 'FixedSingle'
    }
    $PktMonPacketCaptureForm.Controls.Add($PktMonPktSizeLabel)


        $PktMonPktSizeArgLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "--pkt-size"
            Left   = $PktMonPktSizeLabel.Left + $PktMonPktSizeLabel.Width + $($FormScale * 5)
            Top    = $PktMonPktSizeLabel.Top
            Width  = $PktMonOnlyPacketCountersArgLabel.Width
            Height = $FormScale * 16
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = 'DarkGreen'
            BackColor = 'White'
            BorderStyle = 'FixedSingle'
        }
        $PktMonPacketCaptureForm.Controls.Add($PktMonPktSizeArgLabel)


        $script:PktSizeArg = $null
        $PktMonPktSizeComboBox = New-Object System.Windows.Forms.Combobox -Property @{
            Text   = "128"
            Left   = $PktMonPktSizeArgLabel.Left + $PktMonPktSizeArgLabel.Width + $($FormScale * 5)
            Top    = $PktMonPktSizeArgLabel.Top
            Width  = $PktMonComponentComboBox.Width
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = 'Black'
            add_SelectedIndexChanged = {
                if ($this.SelectedItem -ne '128') {
                    $script:PktSizeArg = "--pkt-size $($this.SelectedItem)"
                }
                else {
                    $script:PktSizeArg = $null
                }
                Update-PktMonCommand
            }
        }
        $PktSizeList = @('0','32','64','128','256','512')
        Foreach ($Item in $PktSizeList) {$PktMonPktSizeComboBox.Items.Add($Item)}
        $PktMonPacketCaptureForm.Controls.Add($PktMonPktSizeComboBox)


        if (-not $script:SupportsPktSize) {
            $PktMonPktSizeLabel.enabled = $false
            $PktMonPktSizeArgLabel.enabled = $false
            $PktMonPktSizeComboBox.enabled = $false
        }


    $PktMonFlagsLabel = New-Object System.Windows.Forms.Label -Property @{
        Text   = "Hexadecimal bitmask that controls information logged during packet capture. The default is 0x012.
    0x001 - Internal Packet Monitor errors.
    0x002 - Information about components, counters and filters.
    0x004 - NET_BUFFER_LIST group source and destination information.
    0x008 - Select packet metadata from NDIS_NET_BUFFER_LIST_INFO.
    0x010 - Raw packet, truncated to the size from --pkt-size."
        Left   = $PktMonPktSizeLabel.Left
        Top    = $PktMonPktSizeLabel.Top + $PktMonPktSizeLabel.Height + $($FormScale * 5)
        Width  = $PktMonOnlyPacketCountersCheckbox.Width
        Height = $FormScale * 16
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = 'Blue'
        BackColor = 'White'
        BorderStyle = 'FixedSingle'
        Add_MouseEnter = { 
            $this.Height = $FormScale * 80 
            $this.ForeColor = 'DarkRed'
        }
        Add_MouseLeave = {
            $this.Height = $FormScale * 16
            $this.ForeColor = 'Blue'
        }
    }
    $PktMonPacketCaptureForm.Controls.Add($PktMonFlagsLabel)


        $PktMonFlagsArgLabel = New-Object System.Windows.Forms.Label -Property @{
            Left   = $PktMonFlagsLabel.Left + $PktMonFlagsLabel.Width + $($FormScale * 5)
            Top    = $PktMonFlagsLabel.Top
            Width  = $PktMonOnlyPacketCountersArgLabel.Width
            Height = $FormScale * 16
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = 'DarkGreen'
            BackColor = 'White'
            BorderStyle = 'FixedSingle'
        }
        $PktMonPacketCaptureForm.Controls.Add($PktMonFlagsArgLabel)
        if ($script:SupportsFlags) { $PktMonFlagsArgLabel.text = "--flags" }
        elseif ($script:SupportsKeywords) { $PktMonFlagsArgLabel.text = "--keywords" }


        $script:FlagsArg = $null
        $PktMonFlagsComboBox = New-Object System.Windows.Forms.Combobox -Property @{
            Text   = "0x012"
            Left   = $PktMonFlagsArgLabel.Left + $PktMonFlagsArgLabel.Width + $($FormScale * 5)
            Top    = $PktMonFlagsArgLabel.Top
            Width  = $PktMonComponentComboBox.Width
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = 'Black'
            add_SelectedIndexChanged = {
                if ($script:SupportsFlags) {
                    if ($this.SelectedItem -ne '0x012'){
                        $script:FlagsArg = "--flags $($this.SelectedItem)"
                    }
                    else {
                        $script:FlagsArg = $null
                    }
                }
                elseif ($script:SupportsKeywords) {
                    if ($this.SelectedItem -ne '0x012'){
                        $script:FlagsArg = "--keywords $($this.SelectedItem)"
                    }
                    else {
                        $script:FlagsArg = $null
                    }
                }
                Update-PktMonCommand
            }
        }
        $FlagsList = @('0x012','0x010','0x008','0x004','0x002','0x001')
        Foreach ($Item in $FlagsList) {$PktMonFlagsComboBox.Items.Add($Item)}
        $PktMonPacketCaptureForm.Controls.Add($PktMonFlagsComboBox)


    $PktMonFileSizeLabel = New-Object System.Windows.Forms.Label -Property @{
        Text   = "Maximum log file size in megabytes. Default is 512 MB."
        Left   = $PktMonFlagsLabel.Left
        Top    = $PktMonFlagsLabel.Top + $PktMonFlagsLabel.Height + $($FormScale * 5)
        Width  = $PktMonOnlyPacketCountersCheckbox.Width
        Height = $FormScale * 16
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = 'Blue'
        BackColor = 'White'
        BorderStyle = 'FixedSingle'
    }
    $PktMonPacketCaptureForm.Controls.Add($PktMonFileSizeLabel)


        $PktMonFileSizeArgLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "--file-size"
            Left   = $PktMonFileSizeLabel.Left + $PktMonFileSizeLabel.Width + $($FormScale * 5)
            Top    = $PktMonFileSizeLabel.Top
            Width  = $PktMonOnlyPacketCountersArgLabel.Width
            Height = $FormScale * 16
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = 'DarkGreen'
            BackColor = 'White'
            BorderStyle = 'FixedSingle'
        }
        $PktMonPacketCaptureForm.Controls.Add($PktMonFileSizeArgLabel)
        

        $script:FileSizeArg = $null
        $PktMonFileSizeComboBox = New-Object System.Windows.Forms.Combobox -Property @{
            Text   = "512"
            Left   = $PktMonFileSizeArgLabel.Left + $PktMonFileSizeArgLabel.Width + $($FormScale * 5)
            Top    = $PktMonFileSizeArgLabel.Top
            Width  = $PktMonComponentComboBox.Width
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = 'Black'
            add_SelectedIndexChanged = {
                if ($this.SelectedItem -ne '512'){
                    $script:FileSizeArg = "--file-size $($this.SelectedItem)"
                }
                else {
                    $script:FileSizeArg = $null
                }
                Update-PktMonCommand
            }
        }
        $FileSizeList = @('8','16','32','64','128','256','512','1024')
        Foreach ($Item in $FileSizeList) {$PktMonFileSizeComboBox.Items.Add($Item)}
        $PktMonPacketCaptureForm.Controls.Add($PktMonFileSizeComboBox)


    $PktMonCommandDescriptionLabel = New-Object System.Windows.Forms.Label -Property @{
        Text   = 'Command Executed on Remote Host:'
        Left   = $PktMonFileSizeLabel.Left
        Top    = $PktMonFileSizeLabel.Top + $PktMonFileSizeLabel.Height + $PktMonFileSizeLabel.Height + $($FormScale * 5)
        Width  = $PktMonOnlyPacketCountersCheckbox.Width + $PktMonOnlyPacketCountersArgLabel.Width + $($FormScale * 5) + $PktMonComponentComboBox.Width + $($FormScale * 5)
        Height = $FormScale * 16
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
        ForeColor = 'Black'
    }
    $PktMonPacketCaptureForm.Controls.Add($PktMonCommandDescriptionLabel)


    $PktMonCommandTextbox = New-Object System.Windows.Forms.Textbox -Property @{
        Text   = $null
        Left   = $PktMonCommandDescriptionLabel.Left
        Top    = $PktMonCommandDescriptionLabel.Top + $PktMonCommandDescriptionLabel.Height
        Width  = $PktMonOnlyPacketCountersCheckbox.Width + $PktMonOnlyPacketCountersArgLabel.Width + $($FormScale * 5) + $PktMonComponentComboBox.Width + $($FormScale * 5)
        Height = $FormScale * 30
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = 'DarkGreen'
        BackColor = 'White'
        ReadOnly  = $true
        Multiline = $true
        WordWrap  = $false
        Scrollbars = 'vertical'
    }
    $PktMonPacketCaptureForm.Controls.Add($PktMonCommandTextbox)

    
    function Update-PktMonFileNameDateTime {
        $DateTime = (Get-Date).ToString('yyyy-MM-dd HH.mm.ss')

        $script:PktMonFileNameEtl    = "PktMon $($DateTime).etl"
        $script:PktMonFileNamePcapng = "PktMon $($DateTime).pcapng"

        if ($script:SupportsCapture) {
            $script:Capture = '--capture'
            $script:FileName = "--file-name 'C:\Windows\Temp\$script:PktMonFileNameEtl'"
        }
        else {
            $script:Capture = $null
            $script:FileName = "--etw --file-name 'C:\Windows\Temp\$script:PktMonFileNameEtl'"
        }
    }
    Update-PktMonFileNameDateTime


    function Update-PktMonCommand {
        $PktMonCommandTextbox.Text = @"
pktmon start $script:Capture $script:ComponentArg $script:OnlyPacketCounters $script:TypeArg $script:PktSizeArg $script:FlagsArg $script:FileSizeArg $script:FileName
"@ -replace '\s+',' '
    }
    Update-PktMonCommand


    $PktMonFilterListLabel = New-Object System.Windows.Forms.Label -Property @{
        Text   = "Filters: **
It's highly recommended to apply filters before starting any packet capture, because troubleshooting connectivity to a particular destination is easier when you focus on a single stream of packets. Capturing all the networking traffic can make the output too noisy to analyze. Providing names within the filters are optional.
Up to 32 filters are supported at once.
Actual Command Example: pktmon filter add 'SMB SYN Packets' --IP 10.10.10.100  --Transport TCP SYN --Port 445"
        Left   = $PktMonCommandTextbox.Left
        Top    = $PktMonCommandTextbox.Top + $PktMonCommandTextbox.Height + $($FormScale * 5)
        Width  = $FormScale * 80
        Height = $FormScale * 16
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
        ForeColor = 'Black'
        Add_MouseEnter = { 
            $this.Height = $FormScale * 90 
            $this.Width  = $PktMonOnlyPacketCountersCheckbox.Width + $PktMonOnlyPacketCountersArgLabel.Width + $($FormScale * 5) + $PktMonComponentComboBox.Width + $($FormScale * 5)
            $this.ForeColor = 'DarkRed'
            $This.BringToFront()
        }
        Add_MouseLeave = {
            $this.Height = $FormScale * 16
            $this.Width  = $FormScale * 80 
            $this.ForeColor = 'Black'
            $PktMonFilterListLabel.BringToFront()
        }
    }
    $PktMonPacketCaptureForm.Controls.Add($PktMonFilterListLabel)


        $PktMonFilterListNoteLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "For a packet to be reported, it must match all conditions specified in at least one filter."
            Left   = $FormScale * 90
            Top    = $PktMonCommandTextbox.Top + $PktMonCommandTextbox.Height + $($FormScale * 5)
            Width  = $FormScale * 425
            Height = $FormScale * 16
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
            ForeColor = 'Black'
        }
        $PktMonPacketCaptureForm.Controls.Add($PktMonFilterListNoteLabel)


    $PktMonFilterListSelectionComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Text   = "Enter a custom filter or select one or more to modify and/or add."
        Left   = $PktMonFilterListLabel.Left
        Top    = $PktMonFilterListLabel.Top + $PktMonFilterListLabel.Height
        Width  = $PktMonCommandTextbox.Width
        Height = $FormScale * 16
        Font   = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
        ForeColor  = 'Black'
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
        Add_MouseEnter = { $This.text = $This.SelectedItem -replace '\s+',' ' }
        Add_MouseLeave = { $This.text = $This.SelectedItem -replace '\s+',' ' }
    }
    $PktMonPacketCaptureForm.Controls.Add($PktMonFilterListSelectionComboBox)
    $PktMonFilterListSelectionComboBox.Items.Add("'SMB SYN Packets' --IP 10.10.10.100  --Transport TCP SYN --Port 445")
    $PktMonFilterListSelectionComboBox.Items.Add("'TCP w/in Subnet' --IP 10.10.10.0/24 --Transport TCP")
    $PktMonFilterListSelectionComboBox.Items.Add("'DNS To Server'   --IP 10.10.10.100  --Transport UDP --Port 53")
    $PktMonFilterListSelectionComboBox.Items.Add("'Ping Traffic'    --IP 10.10.10.100  --Transport ICMP")
    $PktMonFilterListSelectionComboBox.Items.Add("")
    $PktMonFilterListSelectionComboBox.Items.Add("'TCP Traffic'    --Transport TCP")
    $PktMonFilterListSelectionComboBox.Items.Add("'UDP Traffic'    --Transport UDP")
    $PktMonFilterListSelectionComboBox.Items.Add("'ICMP Traffic'   --Transport ICMP")
    $PktMonFilterListSelectionComboBox.Items.Add("'ICMPv6 Traffic' --Transport ICMPv6")
    $PktMonFilterListSelectionComboBox.Items.Add("'Protocol #'     --Transport <Protocol Number>")
    $PktMonFilterListSelectionComboBox.Items.Add("")
    $PktMonFilterListSelectionComboBox.Items.Add("'Computer MAC' --MAC DE:AD:BE:EF:FE:ED")
    $PktMonFilterListSelectionComboBox.Items.Add("'Computer MAC' --MAC DE-FA-CE-DB-AB-E1")
    $PktMonFilterListSelectionComboBox.Items.Add("")
    $PktMonFilterListSelectionComboBox.Items.Add("'Default VLAN' --VLAN 1")
    $PktMonFilterListSelectionComboBox.Items.Add("")
    $PktMonFilterListSelectionComboBox.Items.Add("'IPv4' --Data-Link IPv4")
    $PktMonFilterListSelectionComboBox.Items.Add("'IPv6' --Data-Link IPv6")
    $PktMonFilterListSelectionComboBox.Items.Add("'ARP'  --Data-Link ARP")
    $PktMonFilterListSelectionComboBox.Items.Add("--Data-Link <Protocol Number>")
    $PktMonFilterListSelectionComboBox.Items.Add("")
    $PktMonFilterListSelectionComboBox.Items.Add("'VXLAN'    --Encap VXLAN")
    $PktMonFilterListSelectionComboBox.Items.Add("'GRE'      --Encap GRE")
    $PktMonFilterListSelectionComboBox.Items.Add("'NVGRE'    --Encap NVGRE")
    $PktMonFilterListSelectionComboBox.Items.Add("'IP-in-IP' --Encap IP-in-IP")
    $PktMonFilterListSelectionComboBox.Items.Add("")
    $PktMonFilterListSelectionComboBox.Items.Add("'FTP'         --Port 21 --Transport TCP")
    $PktMonFilterListSelectionComboBox.Items.Add("'SSH'         --Port 22 --Transport TCP")
    $PktMonFilterListSelectionComboBox.Items.Add("'Telnet'      --Port 23 --Transport TCP")
    $PktMonFilterListSelectionComboBox.Items.Add("'SMTP'        --Port 25 --Transport TCP")
    $PktMonFilterListSelectionComboBox.Items.Add("'DNS'         --Port 53")
    $PktMonFilterListSelectionComboBox.Items.Add("'DHCP-S'      --Port 67 --Transport UDP")
    $PktMonFilterListSelectionComboBox.Items.Add("'DHCP-C'      --Port 68 --Transport UDP")
    $PktMonFilterListSelectionComboBox.Items.Add("'TFTP'        --Port 69 --Transport UDP")
    $PktMonFilterListSelectionComboBox.Items.Add("'HTTP'        --Port 80 --Transport TCP")
    $PktMonFilterListSelectionComboBox.Items.Add("'Kerberos'    --Port 88")
    $PktMonFilterListSelectionComboBox.Items.Add("'POP3'        --Port 110 --Transport TCP")
    $PktMonFilterListSelectionComboBox.Items.Add("'RPCbind'     --Port 111")
    $PktMonFilterListSelectionComboBox.Items.Add("'NTP'         --Port 123 --Transport UDP")
    $PktMonFilterListSelectionComboBox.Items.Add("'MS-RPC'      --Port 135")
    $PktMonFilterListSelectionComboBox.Items.Add("'NetBIOS-NS'  --Port 137 --Transport UDP")
    $PktMonFilterListSelectionComboBox.Items.Add("'NetBIOS-DGM' --Port 138 --Transport UDP")
    $PktMonFilterListSelectionComboBox.Items.Add("'NetBIOS-SSN' --Port 139")
    $PktMonFilterListSelectionComboBox.Items.Add("'IMAP'        --Port 143 --Transport TCP")
    $PktMonFilterListSelectionComboBox.Items.Add("'SNMP'        --Port 161 --Transport UDP")
    $PktMonFilterListSelectionComboBox.Items.Add("'SNMP-Trap'   --Port 162 --Transport UDP")
    $PktMonFilterListSelectionComboBox.Items.Add("'LDAP'        --Port 389 --Transport TCP")
    $PktMonFilterListSelectionComboBox.Items.Add("'HTTPS'       --Port 443 --Transport TCP")
    $PktMonFilterListSelectionComboBox.Items.Add("'SMB'         --Port 445")
    $PktMonFilterListSelectionComboBox.Items.Add("'SMTPS'       --Port 465 --Transport TCP")
    $PktMonFilterListSelectionComboBox.Items.Add("'ISAKMP'      --Port 500 --Transport UDP")
    $PktMonFilterListSelectionComboBox.Items.Add("'SysLog'      --Port 514")
    $PktMonFilterListSelectionComboBox.Items.Add("'RTSP'        --Port 554 --Transport TCP")
    $PktMonFilterListSelectionComboBox.Items.Add("'RSync'       --Port 873 --Transport TCP")
    $PktMonFilterListSelectionComboBox.Items.Add("'FTPS'        --Port 990 --Transport TCP")
    $PktMonFilterListSelectionComboBox.Items.Add("'IMAPS'       --Port 993 --Transport TCP")
    $PktMonFilterListSelectionComboBox.Items.Add("'POP3S'       --Port 995 --Transport TCP")
    $PktMonFilterListSelectionComboBox.Items.Add("'MS-SQL-S'    --Port 1433")
    $PktMonFilterListSelectionComboBox.Items.Add("'RADIUS-Auth' --Port 1645 --Transport UDP")
    $PktMonFilterListSelectionComboBox.Items.Add("'RADIUS-Acnt' --Port 1646 --Transport UDP")
    $PktMonFilterListSelectionComboBox.Items.Add("'L2TP'        --Port 1701 --Transport UDP")
    $PktMonFilterListSelectionComboBox.Items.Add("'PPTP'        --Port 1723 --Transport TCP")
    $PktMonFilterListSelectionComboBox.Items.Add("'RADIUS-Auth' --Port 1812 --Transport UDP")
    $PktMonFilterListSelectionComboBox.Items.Add("'RADIUS-Acnt' --Port 1813 --Transport UDP")
    $PktMonFilterListSelectionComboBox.Items.Add("'UPNP'        --Port 1900 --Transport UDP")
    $PktMonFilterListSelectionComboBox.Items.Add("'Cisco-SCCP'  --Port 2000")
    $PktMonFilterListSelectionComboBox.Items.Add("'NFS'         --Port 2049 --Transport UDP")
    $PktMonFilterListSelectionComboBox.Items.Add("'PPP'         --Port 3000 --Transport TCP")
    $PktMonFilterListSelectionComboBox.Items.Add("'MYSQL'       --Port 3306 --Transport TCP")
    $PktMonFilterListSelectionComboBox.Items.Add("'RDP/MS-DS'   --Port 3389")
    $PktMonFilterListSelectionComboBox.Items.Add("'MetaSploit'  --Port 4444")
    $PktMonFilterListSelectionComboBox.Items.Add("'NAT-T-IKE'   --Port 4500 --Transport UDP")
    $PktMonFilterListSelectionComboBox.Items.Add("'SIP'         --Port 5060 --Transport UDP")
    $PktMonFilterListSelectionComboBox.Items.Add("'PostgreSQL'  --Port 5432 --Transport TCP")
    $PktMonFilterListSelectionComboBox.Items.Add("'VNC'         --Port 5900")
    $PktMonFilterListSelectionComboBox.Items.Add("'WinRM/HTTP'  --Port 5985 --Transport TCP")
    $PktMonFilterListSelectionComboBox.Items.Add("'WinRM/HTTPS' --Port 5986 --Transport TCP")
    $PktMonFilterListSelectionComboBox.Items.Add("'X11'         --Port 6000 --Transport TCP")
    $PktMonFilterListSelectionComboBox.Items.Add("'HTTP-Alt'    --Port 8000 --Transport TCP")
    $PktMonFilterListSelectionComboBox.Items.Add("'HTTP-Proxy'  --Port 8080 --Transport TCP")
    $PktMonFilterListSelectionComboBox.Items.Add("'HTTPS-Alt'   --Port 8443 --Transport TCP")


    $PktMonFilterListSelectionAddButton = New-Object System.Windows.Forms.Button -Property @{
        Text   = 'Add Filter To Selected'
        Left   = $PktMonFilterListSelectionComboBox.Left
        Top    = $PktMonFilterListSelectionComboBox.Top + $PktMonFilterListSelectionComboBox.Height + $($FormScale * 5)
        Width  = $FormScale * 125
        Height = $FormScale * 22
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = 'Black'
        Add_MouseEnter = { $PktMonFilterListSelectionComboBox.text = $PktMonFilterListSelectionComboBox.SelectedItem -replace '\s+',' ' }
        Add_MouseLeave = { $PktMonFilterListSelectionComboBox.text = $PktMonFilterListSelectionComboBox.SelectedItem -replace '\s+',' ' }
        Add_Click = {
            if ($script:PSSessionPktMon.state -notmatch 'Open') {
                [System.Windows.Forms.MessageBox]::Show("There are no current open sessions.","PoSh-EasyWin",'Ok',"Warning")
            }
            elseif (-not $script:PSSessionPktMon) {
                [System.Windows.Forms.MessageBox]::Show("There are no current open sessions.","PoSh-EasyWin",'Ok',"Warning")                
            }
            elseif ($PktMonFilterListSelectionComboBox.text -eq $null -or $PktMonFilterListSelectionComboBox.text -eq '') {
                [System.Windows.Forms.MessageBox]::Show("You need to select or enter a filter.","PoSh-EasyWin",'Ok',"Warning")
            }
            else {
                Foreach ($Session in $script:PSSessionPktMon) {
                    if ($Session.ComputerName -eq $PktMonFilterTabControl.SelectedTab.Name ) {
                        $PktMonFilterListSelectionComboBoxtext = $($PktMonFilterListSelectionComboBox.text).trim() -replace '\s+',' '
                        if (Verify-Action -Title 'PoSh-EasyWin - PktMon.exe' -Question "Do you want to add the filter to:`n`n$($Session.ComputerName)") {
                            $PktMonFilterAddError = $null
                            $PktMonResults = Invoke-Command -ScriptBlock {
                                param($PktMonFilterListSelectionComboBoxtext)
                                Invoke-Expression "pktmon filter add $PktMonFilterListSelectionComboBoxtext"
                            } -ArgumentList @($PktMonFilterListSelectionComboBoxtext,$null) -Session $Session -ErrorVariable PktMonFilterAddError

                            $PktMonStatusTextbox.text = "$((Get-Date).tostring()):  [$($Session.ComputerName)] $($PktMonResults.trim() -replace '\s+',' ')  [$($PktMonFilterListSelectionComboBoxtext)]`r`n" + $PktMonStatusTextbox.text
                            if ($PktMonFilterAddError){
                                $PktMonStatusTextbox.text = "$((Get-Date).tostring()):  [$($Session.ComputerName)] $($PktMonFilterAddError.trim() -replace '\s+',' ')`r`n" + $PktMonStatusTextbox.text
                            }
                        }
                    }
                }
            }
            script:Update-PktMonFilterListBox
        }
    }
    $PktMonPacketCaptureForm.Controls.Add($PktMonFilterListSelectionAddButton)
    Apply-CommonButtonSettings -Button $PktMonFilterListSelectionAddButton


    $PktMonFilterListSelectionAddAllButton = New-Object System.Windows.Forms.Button -Property @{
        Text   = 'Add Filter To All'
        Left   = $PktMonFilterListSelectionAddButton.Left + $PktMonFilterListSelectionAddButton.Width + $($FormScale * 5)
        Top    = $PktMonFilterListSelectionAddButton.Top
        Width  = $FormScale * 125
        Height = $FormScale * 22
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = 'Black'
        Add_MouseEnter = { $PktMonFilterListSelectionComboBox.text = $PktMonFilterListSelectionComboBox.SelectedItem -replace '\s+',' ' }
        Add_MouseLeave = { $PktMonFilterListSelectionComboBox.text = $PktMonFilterListSelectionComboBox.SelectedItem -replace '\s+',' ' }
        Add_Click = {
            if ($script:PSSessionPktMon.state -notmatch 'Open') {
                [System.Windows.Forms.MessageBox]::Show("There are no current open sessions.","PoSh-EasyWin",'Ok',"Warning")                
            }
            elseif (-not $script:PSSessionPktMon) {
                [System.Windows.Forms.MessageBox]::Show("There are no current open sessions.","PoSh-EasyWin",'Ok',"Warning")                
            }
            elseif ($PktMonFilterListSelectionComboBox.text -eq $null -or $PktMonFilterListSelectionComboBox.text -eq '') {
                [System.Windows.Forms.MessageBox]::Show("You need to select or enter a filter.","PoSh-EasyWin",'Ok',"Warning")
            }
            else {
                $PktMonFilterListSelectionComboBoxtext = $($PktMonFilterListSelectionComboBox.text).trim() -replace '\s+',' '
                if (Verify-Action -Title 'PoSh-EasyWin - PktMon.exe' -Question "Do you want to add the the filters to the following?`n`n$($script:ComputerList -join ', ')") {
                    
                    $PktMonFilterAddError = $null
                    $PktMonResults = Invoke-Command -ScriptBlock {
                        param($PktMonFilterListSelectionComboBoxtext)
                        Invoke-Expression "pktmon filter add $PktMonFilterListSelectionComboBoxtext"
                    } -ArgumentList @($PktMonFilterListSelectionComboBoxtext,$null) -Session $script:PSSessionPktMon -ErrorVariable PktMonFilterAddError

                    $PktMonStatusTextbox.text = "$((Get-Date).tostring()):  [$($Session.ComputerName.Count) Endpoints] $($PktMonResults.trim() -replace '\s+',' ')  [$($PktMonFilterListSelectionComboBoxtext)]`r`n" + $PktMonStatusTextbox.text
                    if ($PktMonFilterAddError){
                        $PktMonStatusTextbox.text = "$((Get-Date).tostring()):  [$($Session.ComputerName.Count) Endpoints] $($PktMonFilterAddError.trim() -replace '\s+',' ')`r`n" + $PktMonStatusTextbox.text
                    }
                }
            }
            script:Update-PktMonFilterListBox
        }
    }
    $PktMonPacketCaptureForm.Controls.Add($PktMonFilterListSelectionAddAllButton)
    Apply-CommonButtonSettings -Button $PktMonFilterListSelectionAddAllButton


    $PktMonFilterListSelectionClearSelectedButton = New-Object System.Windows.Forms.Button -Property @{
        Text   = 'Clear on Selected'
        Left   = $PktMonFilterListSelectionAddAllButton.Left + $PktMonFilterListSelectionAddAllButton.Width + $($FormScale * 5) 
        Top    = $PktMonFilterListSelectionAddAllButton.Top
        Width  = $FormScale * 125
        Height = $FormScale * 22
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = 'Black'
        Add_MouseEnter = { $PktMonFilterListSelectionComboBox.text = $PktMonFilterListSelectionComboBox.SelectedItem -replace '\s+',' ' }
        Add_MouseLeave = { $PktMonFilterListSelectionComboBox.text = $PktMonFilterListSelectionComboBox.SelectedItem -replace '\s+',' ' }
        Add_Click = {
            if ($script:PSSessionPktMon.state -notmatch 'Open') {
                [System.Windows.Forms.MessageBox]::Show("There are no current open sessions.","PoSh-EasyWin",'Ok',"Warning")                
            }
            elseif (-not $script:PSSessionPktMon) {
                [System.Windows.Forms.MessageBox]::Show("There are no current open sessions.","PoSh-EasyWin",'Ok',"Warning")                
            }
            else {
                Foreach ($Session in $($script:PSSessionPktMon | Sort-Object -Property ComputerName)) {
                    if ($Session.ComputerName -eq $PktMonFilterTabControl.SelectedTab.Name ) {
                        if (Verify-Action -Title 'PoSh-EasyWin - PktMon.exe' -Question "Do you want to clear the filters on:`n`n$($Session.ComputerName)") {
                            $PktMonFilterClearError = $null
                            $PktMonResults = Invoke-Command -ScriptBlock {
                                PktMon filter remove
                            } -Session $Session -ErrorVariable PktMonFilterClearError

                            $PktMonStatusTextbox.text = "$((Get-Date).tostring()):  [$($Session.ComputerName)] $($PktMonResults.trim() -replace '\s+',' ')`r`n" + $PktMonStatusTextbox.text
                            if ($PktMonFilterClearError){
                                $PktMonStatusTextbox.text = "$((Get-Date).tostring()):  [$($Session.ComputerName)] $($PktMonFilterClearError.trim() -replace '\s+',' ')`r`n" + $PktMonStatusTextbox.text
                            }
                        }
                    }
                }
            }
            script:Update-PktMonFilterListBox
        }
    }
    $PktMonPacketCaptureForm.Controls.Add($PktMonFilterListSelectionClearSelectedButton)
    Apply-CommonButtonSettings -Button $PktMonFilterListSelectionClearSelectedButton


    $PktMonFilterListSelectionClearAllButton = New-Object System.Windows.Forms.Button -Property @{
        Text   = 'Clear on All'
        Left   = $PktMonFilterListSelectionClearSelectedButton.Left + $PktMonFilterListSelectionClearSelectedButton.Width + $($FormScale * 5) 
        Top    = $PktMonFilterListSelectionClearSelectedButton.Top
        Width  = $FormScale * 125
        Height = $FormScale * 22
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = 'Black'
        Add_MouseEnter = { $PktMonFilterListSelectionComboBox.text = $PktMonFilterListSelectionComboBox.SelectedItem -replace '\s+',' ' }
        Add_MouseLeave = { $PktMonFilterListSelectionComboBox.text = $PktMonFilterListSelectionComboBox.SelectedItem -replace '\s+',' ' }
        Add_Click = {
            if ($script:PSSessionPktMon.state -notmatch 'Open') {
                [System.Windows.Forms.MessageBox]::Show("There are no current open sessions.","PoSh-EasyWin",'Ok',"Warning")
            }
            elseif (-not $script:PSSessionPktMon) {
                [System.Windows.Forms.MessageBox]::Show("There are no current open sessions.","PoSh-EasyWin",'Ok',"Warning")
            }
            else {
                if (Verify-Action -Title 'PoSh-EasyWin - PktMon.exe' -Question "Do you want to clear the filters on the following?`n`n$($script:ComputerList -join ', ')") {
                    $PktMonFilterClearError = $null
                    $PktMonResults = Invoke-Command -ScriptBlock {
                        PktMon filter remove
                    } -Session $script:PSSessionPktMon -ErrorVariable PktMonFilterClearError

                    $PktMonStatusTextbox.text = "$((Get-Date).tostring()):  [$($Session.ComputerName.Count) Endpoints] $($PktMonResults.trim() -replace '\s+',' ')`r`n" + $PktMonStatusTextbox.text
                    if ($PktMonFilterClearError){
                        $PktMonStatusTextbox.text = "$((Get-Date).tostring()):  [$($Session.ComputerName.Count) Endpoints] $($PktMonFilterClearError.trim() -replace '\s+',' ')`r`n" + $PktMonStatusTextbox.text
                    }
                }
            }
            script:Update-PktMonFilterListBox
        }
    }
    $PktMonPacketCaptureForm.Controls.Add($PktMonFilterListSelectionClearAllButton)
    Apply-CommonButtonSettings -Button $PktMonFilterListSelectionClearAllButton


    $PktMonFilterTabControl = New-Object System.Windows.Forms.TabControl -Property @{
        Left   = $PktMonFilterListSelectionAddButton.Left
        Top    = $PktMonFilterListSelectionAddButton.Top + $PktMonFilterListSelectionAddButton.Height + $($FormScale * 5)
        Width  = $FormScale * 710
        Height = $FormScale * 140
        Appearance = [System.Windows.Forms.TabAppearance]::Buttons
        Hottrack   = $true
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,2,1)
    }
    $PktMonPacketCaptureForm.Controls.Add($PktMonFilterTabControl)


    $PktMonStatusDescriptionLabel = New-Object System.Windows.Forms.Label -Property @{
        Text   = 'Status Information:'
        Left   = $PktMonFilterTabControl.Left
        Top    = $PktMonFilterTabControl.Top + $PktMonFilterTabControl.Height + $($FormScale * 5)
        Width  = $PktMonOnlyPacketCountersCheckbox.Width + $PktMonOnlyPacketCountersArgLabel.Width + $($FormScale * 5) + $PktMonComponentComboBox.Width + $($FormScale * 5)
        Height = $FormScale * 16
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
        ForeColor = 'Black'
        Add_MouseEnter = { $PktMonFilterListSelectionComboBox.text = $PktMonFilterListSelectionComboBox.SelectedItem -replace '\s+',' ' }
        Add_MouseLeave = { $PktMonFilterListSelectionComboBox.text = $PktMonFilterListSelectionComboBox.SelectedItem -replace '\s+',' ' }
    }
    $PktMonPacketCaptureForm.Controls.Add($PktMonStatusDescriptionLabel)


    $PktMonStatusTextbox = New-Object System.Windows.Forms.Textbox -Property @{
        Text   = $null
        Left   = $PktMonStatusDescriptionLabel.Left
        Top    = $PktMonStatusDescriptionLabel.Top + $PktMonStatusDescriptionLabel.Height
        Width  = $PktMonOnlyPacketCountersCheckbox.Width + $PktMonOnlyPacketCountersArgLabel.Width + $($FormScale * 5) + $PktMonComponentComboBox.Width + $($FormScale * 5)
        Height = $FormScale * 100
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = 'Black'
        BackColor = 'White'
        ReadOnly  = $true
        Multiline = $true
        WordWrap  = $true
        Scrollbars = 'vertical'
        Add_MouseEnter = { $PktMonFilterListSelectionComboBox.text = $PktMonFilterListSelectionComboBox.SelectedItem -replace '\s+',' ' }
        Add_MouseLeave = { $PktMonFilterListSelectionComboBox.text = $PktMonFilterListSelectionComboBox.SelectedItem -replace '\s+',' ' }
    }
    $PktMonPacketCaptureForm.Controls.Add($PktMonStatusTextbox)


    

    $script:PktMonCaptureStartButton = New-Object System.Windows.Forms.Button -Property @{
        Text   = 'Start Capture'
        Left   = $PktMonStatusTextbox.Left
        Top    = $PktMonStatusTextbox.Top + $PktMonStatusTextbox.Height + $($FormScale * 5)
        Width  = $FormScale * 110
        Height = $FormScale * 22
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = 'Black'
        Enabled = $true
        Add_MouseEnter = { $PktMonFilterListSelectionComboBox.text = $PktMonFilterListSelectionComboBox.SelectedItem -replace '\s+',' ' }
        Add_MouseLeave = { $PktMonFilterListSelectionComboBox.text = $PktMonFilterListSelectionComboBox.SelectedItem -replace '\s+',' ' }
        Add_Click = {
            if ($script:PSSessionPktMon.state -notmatch 'Open') {
                [System.Windows.Forms.MessageBox]::Show("There are no current open sessions.","PoSh-EasyWin",'Ok',"Warning")                
            }
            elseif (-not $script:PSSessionPktMon) {
                [System.Windows.Forms.MessageBox]::Show("There are no current open sessions.","PoSh-EasyWin",'Ok',"Warning")                
            }
            else {
                if (Verify-Action -Title 'PoSh-EasyWin - PktMon.exe' -Question "Do you want to start a packet capture on the following:`n`n$($script:ComputerList -join ', ')") {
                    $PktMonCaptureStopButton.enabled = $true
                    $This.enabled = $false
                
                    Update-PktMonFileNameDateTime
                    Update-PktMonCommand

                    foreach ($session in $script:PSSessionPktMon) {
                        $PktMonResultsError = $null
                        $PktMonResults = Invoke-Command -ScriptBlock {
                            param($PktMonCommandTextboxText)
                            Invoke-Expression $PktMonCommandTextboxText
                        } -ArgumentList @($PktMonCommandTextbox.Text,$null) -Session $Session -ErrorVariable PktMonResultsError

                        $PktMonStatusTextbox.text = "$((Get-Date).tostring()):  [$($Session.ComputerName)] $($PktMonResults.trim() -replace '\s+',' ')`r`n" + $PktMonStatusTextbox.text
                        if ($PktMonResultsError){
                            $PktMonStatusTextbox.text = "$((Get-Date).tostring()):  [$($Session.ComputerName)] Error $($PktMonResultsError.trim() -replace '\s+',' ')`r`n" + $PktMonStatusTextbox.text
                        }              
                    }
                }
            }
        }
    }
    $PktMonPacketCaptureForm.Controls.Add($script:PktMonCaptureStartButton)
    Apply-CommonButtonSettings -Button $script:PktMonCaptureStartButton

    $StopAndCollectCaptures = {
        if (Verify-Action -Title 'PoSh-EasyWin - PktMon.exe' -Question "Do you want stop packet capturing on the following?`n`n$($script:ComputerList -join ', ')") {
            Foreach ($Session in $script:PSSessionPktMon) {
                $PktMonResultsError = $null
                $PktMonResults = Invoke-Command -ScriptBlock {
                    & PktMon stop
                } -Session $Session -ErrorVariable PktMonResultsError

                $PktMonStatusTextbox.text = "$((Get-Date).tostring()):  [$($Session.ComputerName)] $($PktMonResults.trim() -replace '\s+',' ')`r`n" + $PktMonStatusTextbox.text
                if ($PktMonResultsError) {
                    $PktMonStatusTextbox.text = "$((Get-Date).tostring()):  [$($Session.ComputerName)] Error $($PktMonResultsError.trim() -replace '\s+',' ')`r`n" + $PktMonStatusTextbox.text
                }
            }
            $PacketCaptureDetails = @()
            Foreach ($Session in $script:PSSessionPktMon) {
                $PktMonDetailsError = $null
                $PacketCaptureDetails += Invoke-Command -ScriptBlock {
                    param($FileName)
                    Get-ItemProperty "C:\Windows\Temp\$FileName" | Select-Object @{n='ComputerName';e={$env:ComputerName}}, Name, CreationTime, LastAccessTime, LastWriteTime, Length, @{n='KiloBytes';e={[math]::round($($_.Length / 1KB),2)}}, @{n='MegaBytes';e={[math]::round($($_.Length / 1MB),2)}}, @{n='GigaBytes';e={[math]::round($($_.Length / 1GB),2)}}, Directory
                } -ArgumentList @($script:PktMonFileNameEtl,$null) -Session $Session -ErrorVariable PktMonDetailsError

                $PktMonStatusTextbox.text = "$((Get-Date).tostring()):  [$($Session.ComputerName)] Removing file from [$($Session.ComputerName)]$('C:\Windows\Temp\$script:PktMonFileNameEtl')`r`n" + $PktMonStatusTextbox.text
                if ($PktMonDetailsError) {
                    $PktMonStatusTextbox.text = "$((Get-Date).tostring()):  [$($Session.ComputerName)] Error $($PktMonDetailsError.trim() -replace '\s+',' ')`r`n" + $PktMonStatusTextbox.text
                }                        
            }
            $SelectedPacketCaptures = $PacketCaptureDetails | Out-GridView -Title "PoSh-EasyWin - Packet Capture Details" -PassThru

            Foreach ($Session in $script:PSSessionPktMon) {
                Foreach ($Capture in $SelectedPacketCaptures) {
                    if ($Session.ComputerName -eq $Capture.ComputerName) {
                        # Copies data back to localhost
                        $PktMonCopyError = $null
                        New-Item -Type Directory $script:CollectionSavedDirectoryTextBox.Text
                        Copy-Item -Path "C:\Windows\Temp\$script:PktMonFileNameEtl" -Destination "$($script:CollectionSavedDirectoryTextBox.Text)\$($Session.ComputerName) $script:PktMonFileNameEtl" -FromSession $Session -ErrorVariable PktMonCopyError
                        $PktMonStatusTextbox.text = "$((Get-Date).tostring()):  [$($Session.ComputerName)] Copying $('C:\Windows\Temp\$script:PktMonFileNameEtl') to localhost`r`n" + $PktMonStatusTextbox.text
                        if ($PktMonCopyError) {
                            $PktMonStatusTextbox.text = "$((Get-Date).tostring()):  [$($Session.ComputerName)] Error $($PktMonCopyError.trim() -replace '\s+',' ')`r`n" + $PktMonStatusTextbox.text
                        }

                        # Removes remote .etl file from endpoints
                        $PktMonRemoveError = $null
                        Invoke-Command -ScriptBlock {
                            param($FileName)
                            Remove-Item "C:\Windows\Temp\$FileName" -Force
                        } -ArgumentList @($script:PktMonFileNameEtl,$null) -Session $Session -ErrorVariable PktMonRemoveError
                        $PktMonStatusTextbox.text = "$((Get-Date).tostring()):  [$($Session.ComputerName)] Removing file from [$($Session.ComputerName)]$('C:\Windows\Temp\$script:PktMonFileNameEtl')`r`n" + $PktMonStatusTextbox.text
                        if ($PktMonRemoveError) {
                            $PktMonStatusTextbox.text = "$((Get-Date).tostring()):  [$($Session.ComputerName)] Error $($PktMonRemoveError.trim() -replace '\s+',' ')`r`n" + $PktMonStatusTextbox.text
                        }

                        # Converts local .etl file to .pcapng
                        pktmon etl2pcap "$($script:CollectionSavedDirectoryTextBox.Text)\$($Session.ComputerName) $script:PktMonFileNameEtl" --out "$($script:CollectionSavedDirectoryTextBox.Text)\$($Session.ComputerName) $script:PktMonFileNamePcapng"

                        # Removes local .etl file
                        Remove-Item "$($script:CollectionSavedDirectoryTextBox.Text)\$($Session.ComputerName) $script:PktMonFileNameEtl"

                        # Adds metadata / alternate data streams (ADS) to local .pcapng files
                        $PktMonFilterListToADSResults = Invoke-Command -ScriptBlock {
                            & PktMon filter list | Where-Object {$_ -notmatch '----'}
                        } -Session $Session
                        $PktMonFilterListToADSResults = $PktMonFilterListToADSResults.split("`r`n") -join '&&'
                        Invoke-Expression "Set-Content '$($script:CollectionSavedDirectoryTextBox.Text)\$($Session.ComputerName) $($script:PktMonFileNamePcapng):PacketCaptureMetadata' -Value '$PktMonFilterListToADSResults'"

                        # Opens selected local .pcapng file with system default application - typically Wireshark if installed
                        Invoke-Item "$($script:CollectionSavedDirectoryTextBox.Text)\$($Session.ComputerName) $script:PktMonFileNamePcapng"
                    }
                }
            }
        }
    }

    $PktMonCaptureStopButton = New-Object System.Windows.Forms.Button -Property @{
        Text   = 'Stop Capture'
        Left   = $script:PktMonCaptureStartButton.Left + $script:PktMonCaptureStartButton.Width + $($FormScale * 5)
        Top    = $script:PktMonCaptureStartButton.Top
        Width  = $FormScale * 110
        Height = $FormScale * 22
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = 'Black'
        Enabled = $false
        Add_Click = {
            if ($script:PSSessionPktMon.state -notmatch 'Open') {
                [System.Windows.Forms.MessageBox]::Show("There are no current open sessions.","PoSh-EasyWin",'Ok',"Warning")                
            }
            elseif (-not $script:PSSessionPktMon) {
                [System.Windows.Forms.MessageBox]::Show("There are no current open sessions.","PoSh-EasyWin",'Ok',"Warning")                
            }
            else {
                & $StopAndCollectCaptures

                $script:PktMonCaptureStartButton.enabled = $true
                $This.Enabled = $false
            }
        }
    }
    $PktMonPacketCaptureForm.Controls.Add($PktMonCaptureStopButton)
    Apply-CommonButtonSettings -Button $PktMonCaptureStopButton


    $PktMonPSSessionOpenCapturesButton = New-Object System.Windows.Forms.Button -Property @{
        Text   = 'Open Captures'
        Left   = $PktMonCaptureStopButton.Left + $PktMonCaptureStopButton.Width + $($FormScale * 5)
        Top    = $PktMonCaptureStopButton.Top
        Width  = $FormScale * 110
        Height = $FormScale * 22
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = 'Black'
        Add_Click = {
            Get-ChildItem $CollectedDataDirectory -Recurse `
            | Where-Object {$_.extension -match 'pcap'} `
            | Select-Object -Property `
                @{n='ComputerName';e={$($_.BaseName.split(' ')[0])}}, `
                Name, CreationTime, LastAccessTime, LastWriteTime, `
                @{n='Filter';e={$(Get-Content "$($_.Fullname):PacketCaptureMetadata") -replace "&&","`r`n"}}, `
                Length, @{n='KiloBytes';e={[math]::round($($_.Length / 1KB),2)}}, @{n='MegaBytes';e={[math]::round($($_.Length / 1MB),2)}}, @{n='GigaBytes';e={[math]::round($($_.Length / 1GB),2)}}, Directory, Fullname `
            | Sort-Object -Property @{e="CreationTime";Descending=$True}, @{e="Name";Descending=$False} `
            | Out-GridView -Title 'PoSh-EasyWin - Packet Captures' -PassThru `
            | ForEach-Object { Invoke-Item "$($_.Fullname)" }
        }
    }
    $PktMonPacketCaptureForm.Controls.Add($PktMonPSSessionOpenCapturesButton)
    Apply-CommonButtonSettings -Button $PktMonPSSessionOpenCapturesButton


    $PktMonPSSessionRestartButton = New-Object System.Windows.Forms.Button -Property @{
        Text   = 'New-PSSession'
        Left   = $PktMonPSSessionOpenCapturesButton.Left + $PktMonPSSessionOpenCapturesButton.Width + $($FormScale * 5)
        Top    = $PktMonPSSessionOpenCapturesButton.Top
        Width  = $FormScale * 110
        Height = $FormScale * 22
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = 'Black'
        Enabled = $false
        Add_Click = {
            if (Verify-Action -Title 'PoSh-EasyWin - New-PSSession' -Question "Do you want to start a new PSSession to the following?`n`n$($script:ComputerList -join ', ')") {
                $script:PSSessionPktMon = New-PSSession -ComputerName $script:ComputerList -Credential $script:Credential
                $PktMonPSSessionRemoveButton.Enabled = $True
                $This.Enabled = $false
                $script:Timer.Start()
            }
        }
    }
    $PktMonPacketCaptureForm.Controls.Add($PktMonPSSessionRestartButton)
    Apply-CommonButtonSettings -Button $PktMonPSSessionRestartButton


    $PktMonPSSessionRemoveButton = New-Object System.Windows.Forms.Button -Property @{
        Text   = 'Remove-PSSession'
        Left   = $PktMonPSSessionRestartButton.Left + $PktMonCaptureStopButton.Width + $($FormScale * 5)
        Top    = $PktMonPSSessionRestartButton.Top
        Width  = $FormScale * 110
        Height = $FormScale * 22
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = 'Black'
        Enabled = $true
        Add_Click = {
            if (Verify-Action -Title 'PoSh-EasyWin - Remove-PSSession' -Question "Do you want to remove the current PSSession on the following?`n`n$($script:ComputerList -join ', ')") {
                $script:PSSessionPktMon | Remove-PSSession
                $This.Enabled = $false
                & $UpdateStatusBar
            }
        }
    }
    $PktMonPacketCaptureForm.Controls.Add($PktMonPSSessionRemoveButton)
    Apply-CommonButtonSettings -Button $PktMonPSSessionRemoveButton


    $PktMonPSSessionStatusButton = New-Object System.Windows.Forms.Button -Property @{
        Text   = 'Get-PSSession'
        Left   = $PktMonPSSessionRemoveButton.Left + $PktMonPSSessionRemoveButton.Width + $($FormScale * 5)
        Top    = $PktMonPSSessionRemoveButton.Top
        Width  = $FormScale * 110
        Height = $FormScale * 22
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = 'Black'
        Add_Click = {
            $script:PSSessionPktMon | Out-GridView -Title "PoSh-EasyWin - PSSession Status"
        }
    }
    $PktMonPacketCaptureForm.Controls.Add($PktMonPSSessionStatusButton)
    Apply-CommonButtonSettings -Button $PktMonPSSessionStatusButton


    $script:Timer = New-Object System.Windows.Forms.Timer -Property @{
        Enabled  = $true
        Interval = 1000
    }
    $script:Timer.Start()


    $script:FileTransferStatusBar = New-Object System.Windows.Forms.StatusBar


    $UpdateStatusBar = {
        if ($script:PSSessionPktMon) {
            $PSSessionOpen   = ($script:PSSessionPktMon | Where-Object {$_.State -match 'Opened'}).count
            $PSSessionClosed = ($script:PSSessionPktMon | Where-Object {$_.State -match 'Closed'}).count
            $PSSessionDisconnected = ($script:PSSessionPktMon | Where-Object {$_.State -match 'Disconnected'}).count
            $PSSessionBroken = ($script:PSSessionPktMon | Where-Object {$_.State -match 'Broken'}).count

            $script:ConnectionState = "$(Get-Date) - Connection Status: Open [$PSSessionOpen], Closed [$PSSessionClosed], Disconnected [$PSSessionDisconnected], Broken [$PSSessionBroken]"
        }
        else {
            $script:ConnectionState = "$(Get-Date) - Connection Status with $($script:ComputerList):  Error"
        }

        if ($script:PSSessionPktMon.State -match 'Open') {
            $script:FileTransferStatusBar.Text = $script:ConnectionState
            if ($script:PktMonCaptureStartButton.enabled -eq $true){
                Update-PktMonFileNameDateTime
                Update-PktMonCommand
            }
        }
        else {
            $script:FileTransferStatusBar.Text = $script:ConnectionState
            $PktMonPSSessionRemoveButton.Enabled = $false
            $PktMonPSSessionRestartButton.Enabled = $true
            $script:Timer.Stop()
        }

    }
    $script:Timer.add_Tick($UpdateStatusBar)


    $PktMonPacketCaptureForm.Controls.Add($script:FileTransferStatusBar)

$PktMonPacketCaptureForm.ShowDialog()


}
<#
############On both
    --log-mode { circular | multi-file | memory | real-time }
        Logging mode. Default is circular.

        circular    New events overwrite the oldest ones when the log is full.

        multi-file  No limit on number of captured events, but a new log file
                    is created each time the log is full.

        memory      Like circular, but the entire log is stored in memory.
                    It is written to a file when pktmon is stopped.

        real-time   Display events and packets on screen at real time. No log
                    file is created. Press Ctrl+C to stop monitoring.

#############
    ### new
    Event Providers
    [--trace --provider <name> [--keywords <k>] [--level <n>] ...]
    -t, --trace
        Enable event collection.

        -p, --provider <name>
            Event provider name or GUID. For multiple providers, use this
            parameter more than once.

        -k, --keywords <k>
            Hexadecimal bitmask that controls which events are logged
            for the corresponding provider. Default is 0xFFFFFFFF.

        -l, --level <n>
            Logging level for the corresponding provider.
            Default is 4 (info level).

    ### old
    ETW Logging
         [--etw [-p size] [-k keywords]]
        --etw
            Start a logging session for packet capture.
        -k, --keywords
            Hexadecimal bitmask (i.e. sum of the below flags) that controls
            which events are logged. Default is 0x012.

            Flags:
            0x001 - Internal Packet Monitor errors.
            0x002 - Information about components, counters and filters.
                    This information is added to the end of the log file.
            0x004 - Source and destination information for the first 
                    packet in NET_BUFFER_LIST group.
            0x008 - Select packet metadata from NDIS_NET_BUFFER_LIST_INFO
                    enumeration.
            0x010 - Raw packet, truncated to the size specified in 
                    [--packet-size] parameter.


############
    ### both
        -p, --packet-size
            Number of bytes to log from each packet. To always log the entire
            packet, set this to 0. Default is 128 bytes.
############
    ### new
        --comp { all | nics | id1 id2 ... }
            Select components to capture packets on. Can be ALL components,
            NICs only, or a list of component Ids. Default is ALL.
    ### old
        -c, --components
            Select components to monitor. Can be all components, NICs only, or a
            list of component ids. Defaults to all.
#
# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUyCQrWTBHlDogLWEjU8fSl8jC
# pmagggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
# AQUFADAzMTEwLwYDVQQDDChQb1NoLUVhc3lXaW4gQnkgRGFuIEtvbW5pY2sgKGhp
# Z2gxMDFicm8pMB4XDTIxMTIxNDA1MDIwMFoXDTMxMTIxNDA1MTIwMFowMzExMC8G
# A1UEAwwoUG9TaC1FYXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALvIxUDFEVGB/G0FXPryoNlF
# dA65j5jPEFM2R4468rjlTVsNYUOR+XvhjmhpggSQa6SzvXtklUJIJ6LgVUpt/0C1
# zlr1pRwTvsd3svI7FHTbJahijICjCv8u+bFcAR2hH3oHFZTqvzWD1yG9FGCw2pq3
# h4ahxtYBd1+/n+jOtPUoMzcKIOXCUe4Cay+xP8k0/OLIVvKYRlMY4B9hvTW2CK7N
# fPnvFpNFeGgZKPRLESlaWncbtEBkexmnWuferJsRtjqC75uNYuTimLDSXvNps3dJ
# wkIvKS1NcxfTqQArX3Sg5qKX+ZR21uugKXLUyMqXmVo2VEyYJLAAAITEBDM8ngUC
# AwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0G
# A1UdDgQWBBSDJIlo6BcZ7KJAW5hoB/aaTLxFzTANBgkqhkiG9w0BAQUFAAOCAQEA
# ouCzal7zPn9vc/C9uq7IDNb1oNbWbVlGJELLQQYdfBE9NWmXi7RfYNd8mdCLt9kF
# CBP/ZjHKianHeZiYay1Tj+4H541iUN9bPZ/EaEIup8nTzPbJcmDbaAGaFt2PFG4U
# 3YwiiFgxFlyGzrp//sVnOdtEtiOsS7uK9NexZ3eEQfb/Cd9HRikeUG8ZR5VoQ/kH
# 2t2+tYoCP4HsyOkEeSQbnxlO9s1jlSNvqv4aygv0L6l7zufiKcuG7q4xv/5OvZ+d
# TcY0W3MVlrrNp1T2wxzl3Q6DgI+zuaaA1w4ZGHyxP8PLr6lMi6hIugI1BSYVfk8h
# 7KAaul5m+zUTDBUyNd91ojGCAegwggHkAgEBMEcwMzExMC8GA1UEAwwoUG9TaC1F
# YXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKQIQeugH5LewQKBKT6dP
# XhQ7sDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkq
# hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGC
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUrNlkfQuQGWQjfokGuPunwbA7nTAwDQYJKoZI
# hvcNAQEBBQAEggEAim6zykR/c+/Sl5Rf86DXG5A7dgVREliWYpK04iQLUTMJohGt
# 3MH7LCfNTWDnjsTJTOOzQ2NQi+gfonoA9864MifkXqZfPkwcCMewTiRzg/TyNRMC
# oIei4z1kZwtdR/nSPU3/pUMPmioh0OR36SANvW1TcgFzYOoOidnheiGiSoknGYNZ
# fR/Bc+hQP6KOJebUWQzffGtmBOWeAhboA78FovSDNkosjGiIrBp1e6/Myo6C5Dbl
# 40DyC8Eh6OpHNWqEsRuhiXyMrie1CiVqBIexYVRQkoJ3lLXPPkbcmp1QaRTBYDc9
# cGLsZIDbNCThBdS2dx4CBSSLVEJCzBxsJYk/HQ==
# SIG # End signature block
