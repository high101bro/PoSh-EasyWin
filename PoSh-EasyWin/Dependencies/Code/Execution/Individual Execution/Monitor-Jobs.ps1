function Monitor-Jobs {
    param(
        $CollectionName,
        [String]$SaveProperties,
        [switch]$NotExportFiles,
        [switch]$MonitorMode,
        [switch]$PcapSwitch,
        [switch]$PSWriteHTMLSwitch,
        $PSWriteHTML
    )



if ($MonitorMode) {
    $MainBottomTabControl.SelectedTab = $Section3MonitorJobsTab

    # Creates locations to saves the results from jobs
    if (-not (Test-Path "$($script:CollectionSavedDirectoryTextBox.Text)\Results By Endpoints\$($CollectionName)")){
        New-Item -Type Directory "$($script:CollectionSavedDirectoryTextBox.Text)\Results By Endpoints\$($CollectionName)" -Force -ErrorAction SilentlyContinue
    }


#write-host "Job Monitor: $(Get-date)"

    $JobId = Get-Random -Minimum 100009 -Maximum 999999
    #Get-Job | Sort-Object Id | Select-Object -Last 1 -ExpandProperty ID


    $script:AllJobs = Get-Job -Name "PoSh-EasyWin: *"


    Invoke-Expression @"
        # Timer that updates the GUI on interval
        `$script:Timer$JobId = New-Object System.Windows.Forms.Timer -Property @{
            Enabled  = `$true
            Interval = 250 #1000 = 1 second
        }
        `$script:Timer$JobId.Start()
    

        `$script:CurrentJobs$JobId = @()
        foreach (`$Job in `$script:AllJobs) {
            if (`$Job.Id -notin `$script:PastJobsIDList) {
                `$script:PastJobsIDList += `$Job.Id
                `$script:CurrentJobs$JobId += `$Job
            }
        }


        if (`$PSWriteHTMLSwitch) {
            if ("$PSWriteHTML" -eq 'PSWriteHTMLProcesses') {
                `$script:JobName$JobId = 'Process Data (Browser)'
            }
            elseif ("$PSWriteHTML" -eq 'EndpointDataNetworkConnections') {
                `$script:JobName$JobId = 'Network Connections (Browser)'
            }
            elseif ("$PSWriteHTML" -eq 'EndpointDataConsoleLogons') {
                `$script:JobName$JobId = 'Console Logons (Browser)'
            }
            elseif ("$PSWriteHTML" -eq 'PowerShellSessionsData') {
                `$script:JobName$JobId = 'PowerShell Sessions (Browser)'
            }
            elseif ("$PSWriteHTML" -eq 'EndpointApplicationCrashes') {
                `$script:JobName$JobId = 'Application Crashes (Browser)'
            }
            elseif ("$PSWriteHTML" -eq 'EndpointLogonActivity') {
                `$script:JobName$JobId = 'Logon Activity (Browser)'
            }
            elseif ("$PSWriteHTML" -eq 'PSWriteHTMLADUsers') {
                `$script:JobName$JobId = 'Active Directory Users (Browser)'
            }
            elseif ("$PSWriteHTML" -eq 'PSWriteHTMLADComputers') {
                `$script:JobName$JobId = 'Active Directory Computers (Browser)'
            }
        }
        else {
            `$script:JobName$JobId = `$CollectionName
        }

        # Sets the job timeout value, so they don't run forever
        `$script:JobsTimer$JobId  = [int]`$(`$script:OptionJobTimeoutSelectionComboBox.Text)

        `$script:JobStartTime$JobId = Get-Date
        `$script:JobStartTimeFileFriendly$JobId = `$(`$script:JobStartTime$JobId).ToString('yyyy-MM-dd HH.mm.ss')
        `$script:PreviousJobFormItemsList$JobId = `$script:PreviousJobFormItemsList
        `$script:JobCompletionMessageShown$JobId = `$false
        `$script:JobsRowHeight = (`$FormScale * 22)
        `$script:JobsRowGap = (`$FormScale * 5)
        `$script:JobsStartedCount$JobId = `$script:CurrentJobs$JobId.count
        

        #`$TempSaveJobName = `$script:CurrentJobs$JobId[0].Name
        #`$script:JobSaveName$JobId = ((`$TempSaveJobName -replace 'PoSh-EasyWin: ','').split('-')[0..`$(`$TempSaveJobName.split('-').GetUpperBound(0)-2)] -join '-').trim(' -')

        
        `$script:Section3MonitorJobPanel$JobId = New-Object System.Windows.Forms.panel -Property @{
            Left      = `$script:MonitorJobsLeftPosition
            Top       = `$script:MonitorJobsTopPosition
            Width     = `$FormScale * 715
            Height    = `$script:JobsRowHeight
        }
    
        `$script:Section3MonitorJobDetailsButton$JobId = New-Object System.Windows.Forms.Button -Property @{
            text     = '+'
            Left     = `$FormScale * 1
            Top      = `$FormScale * 10
            Width    = `$FormScale * 11
            Height   = `$FormScale * 11
            Font     = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 6),0,0,0)
            Add_click = {
                                `$script:MonitorJobsDetailsFrom$JobId = New-Object Windows.Forms.Form -Property @{
                                    Text          = "Monitor Jobs Details - `$(`$script:JobName$JobId)"
                                    Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("`$EasyWinIcon")
                                    Width         = `$FormScale * 670
                                    Height        = `$FormScale * 600
                                    StartPosition = "CenterScreen"
                                    Font          = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 11),0,0,0)
                                    Add_Closing = { 
                                        Remove-Variable MonitorJobsDetailsFrom$JobId -scope script

                                        Remove-Variable MonitorJobsDetailsRunningGroupBox$JobId -scope script
                                        Remove-Variable MonitorJobsDetailsRunningListBox$JobId -scope script
                                        Remove-Variable MonitorJobsDetailsRunningSelectAllButton$JobId -scope script
                                        Remove-Variable MonitorJobsDetailsRunningSelectedForTreeNodeButton$JobId -scope script
                                        
                                        Remove-Variable MonitorJobsDetailsCompletedGroupBox$JobId -scope script
                                        Remove-Variable MonitorJobsDetailsCompletedListBox$JobId -scope script
                                        Remove-Variable MonitorJobsDetailsCompletedSelectAllButton$JobId -scope script
                                        Remove-Variable MonitorJobsDetailsCompletedSelectedForTreeNodeLButton$JobId -scope script

                                        Remove-Variable MonitorJobsDetailsStoppedGroupBox$JobId -scope script
                                        Remove-Variable MonitorJobsDetailsStoppedListBox$JobId -scope script
                                        Remove-Variable MonitorJobsDetailsStoppedSelectAllButton$JobId -scope script
                                        Remove-Variable MonitorJobsDetailsStoppedSelectedForTreeNodeButton$JobId -scope script

                                        Remove-Variable MonitorJobsDetailsFailedGroupBox$JobId -scope script
                                        Remove-Variable MonitorJobsDetailsFailedListBox$JobId -scope script
                                        Remove-Variable MonitorJobsDetailsFailedSelectAllButton$JobId -scope script
                                        Remove-Variable MonitorJobsDetailsFailedSelectedForTreeNodeButton$JobId -scope script

                                        Remove-Variable MonitorJobsDetailsStatusGroupBox$JobId -scope script
                                        Remove-Variable MonitorJobsDetailsStatusRichTextBox$JobId -scope script

                                        `$This.dispose() 
                                    }
                                }

                                
                                    `$script:MonitorJobsDetailsRunningGroupBox$JobId = New-Object System.Windows.Forms.GroupBox -Property @{
                                        text      = "Running"
                                        left      = `$FormScale * 10
                                        top       = `$FormScale * 10
                                        Width     = `$FormScale * 150
                                        Height    = `$FormScale * 402
                                        Font      = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 12),1,2,1)
                                        ForeColor = "Blue"
                                    }
                                    `$script:MonitorJobsDetailsFrom$JobId.Controls.Add(`$script:MonitorJobsDetailsRunningGroupBox$JobId)
                                
                                        `$script:MonitorJobsDetailsRunningListBox$JobId = New-Object System.Windows.Forms.ListBox -Property @{
                                            left      = `$FormScale * 5
                                            top       = `$FormScale * 20
                                            Width     = `$FormScale * 140
                                            Height    = `$FormScale * 300
                                            Font      = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 10),0,0,0)
                                            ForeColor = "Black"
                                            FormattingEnabled   = `$True
                                            SelectionMode       = 'MultiExtended'
                                            ScrollAlwaysVisible = `$True
                                            AutoSize            = `$false
                                        }
                                        `$script:MonitorJobsDetailsRunningGroupBox$JobId.Controls.Add(`$script:MonitorJobsDetailsRunningListBox$JobId)
                                
                                
                                        `$script:MonitorJobsDetailsRunningSelectAllButton$JobId = New-Object System.Windows.Forms.Button -Property @{
                                            text      = 'Select All'
                                            left      = `$FormScale * 5
                                            top       = `$script:MonitorJobsDetailsRunningListBox$JobId.Top + `$script:MonitorJobsDetailsRunningListBox$JobId.Height + (`$FormScale * 5)
                                            Width     = `$FormScale * 140
                                            Height    = `$FormScale * 22
                                            Font      = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 10),0,0,0)
                                            ForeColor = "Black"
                                            Add_Click = {
                                                for(`$i = 0; `$i -lt `$script:MonitorJobsDetailsRunningListBox$JobId.Items.Count; `$i++) {
                                                    `$script:MonitorJobsDetailsRunningListBox$JobId.SetSelected(`$i, `$true)
                                                }
                                            }
                                        }
                                        `$script:MonitorJobsDetailsRunningGroupBox$JobId.Controls.Add(`$script:MonitorJobsDetailsRunningSelectAllButton$JobId)
                                        CommonButtonSettings -Button `$script:MonitorJobsDetailsRunningSelectAllButton$JobId
                                
                                
                                        `$script:MonitorJobsDetailsRunningSelectedForTreeNodeButton$JobId = New-Object System.Windows.Forms.Button -Property @{
                                            text      = "Checkbox The Selected`nIn The`nComputer TreeView"
                                            left      = `$FormScale * 5
                                            top       = `$script:MonitorJobsDetailsRunningSelectAllButton$JobId.Top + `$script:MonitorJobsDetailsRunningSelectAllButton$JobId.Height + (`$FormScale * 5)
                                            Width     = `$FormScale * 140
                                            Height    = `$FormScale * 44
                                            Font      = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 10),0,0,0)
                                            ForeColor = "Black"
                                            Add_Click = {
                                                [System.Windows.Forms.TreeNodeCollection]`$AllHostsNode = `$script:ComputerTreeView.Nodes
                                                foreach (`$root in `$AllHostsNode) { 
                                                    `$root.Checked = `$false 
                                                    foreach (`$Category in `$root.Nodes) { 
                                                        `$Category.Checked = `$false 
                                                        foreach (`$Entry in `$Category.nodes) { 
                                                            `$Entry.Checked = `$false 
                                                        } 
                                                    } 
                                                }
                                                
                                                foreach (`$Selected in `$script:MonitorJobsDetailsRunningListBox$JobId.SelectedItems) {
                                                    foreach (`$root in `$AllHostsNode) { 
                                                        foreach (`$Category in `$root.Nodes) { 
                                                            foreach (`$Entry in `$Category.nodes) { 
                                                                if (`$Entry.Text -eq `$Selected){ 
                                                                    `$Entry.Checked = `$true 
                                                                } 
                                                            } 
                                                        } 
                                                    }
                                                }
                                                Conduct-NodeAction -TreeView `$script:ComputerTreeView.Nodes -ComputerList
                                            }
                                        }
                                        `$script:MonitorJobsDetailsRunningGroupBox$JobId.Controls.Add(`$script:MonitorJobsDetailsRunningSelectedForTreeNodeButton$JobId)
                                        CommonButtonSettings -Button `$script:MonitorJobsDetailsRunningSelectedForTreeNodeButton$JobId        


                                        `$script:MonitorJobsDetailsCompletedGroupBox$JobId = New-Object System.Windows.Forms.GroupBox -Property @{
                                            text      = "Completed"
                                            left      = `$script:MonitorJobsDetailsRunningGroupBox$JobId.Left + `$script:MonitorJobsDetailsRunningGroupBox$JobId.Width + (`$FormScale * 10)
                                            top       = `$FormScale * 10
                                            Width     = `$FormScale * 150
                                            Height    = `$FormScale * 402
                                            Font      = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 12),1,2,1)
                                            ForeColor = "DarkGreen"
                                        }
                                        `$script:MonitorJobsDetailsFrom$JobId.Controls.Add(`$script:MonitorJobsDetailsCompletedGroupBox$JobId)
                                    
                                            `$script:MonitorJobsDetailsCompletedListBox$JobId = New-Object System.Windows.Forms.ListBox -Property @{
                                                left      = `$FormScale * 5
                                                top       = `$FormScale * 20
                                                Width     = `$FormScale * 140
                                                Height    = `$FormScale * 300
                                                Font      = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 10),0,0,0)
                                                ForeColor = "Black"
                                                FormattingEnabled   = `$True
                                                SelectionMode       = 'MultiExtended'
                                                ScrollAlwaysVisible = `$True
                                                AutoSize            = `$false
                                            }
                                            `$script:MonitorJobsDetailsCompletedGroupBox$JobId.Controls.Add(`$script:MonitorJobsDetailsCompletedListBox$JobId)
                                    
                                            `$script:MonitorJobsDetailsCompletedSelectAllButton$JobId = New-Object System.Windows.Forms.Button -Property @{
                                                text      = 'Select All'
                                                left      = `$FormScale * 5
                                                top       = `$script:MonitorJobsDetailsCompletedListBox$JobId.Top + `$script:MonitorJobsDetailsCompletedListBox$JobId.Height + (`$FormScale * 5)
                                                Width     = `$FormScale * 140
                                                Height    = `$FormScale * 22
                                                Font      = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 10),0,0,0)
                                                ForeColor = "Black"
                                                Add_Click = {
                                                    for(`$i = 0; `$i -lt `$script:MonitorJobsDetailsCompletedListBox$JobId.Items.Count; `$i++) {
                                                        `$script:MonitorJobsDetailsCompletedListBox$JobId.SetSelected(`$i, `$true)
                                                    }
                                                }
                                            }
                                            `$script:MonitorJobsDetailsCompletedGroupBox$JobId.Controls.Add(`$script:MonitorJobsDetailsCompletedSelectAllButton$JobId)
                                            CommonButtonSettings -Button `$script:MonitorJobsDetailsCompletedSelectAllButton$JobId
    
                                    
                                            `$script:MonitorJobsDetailsCompletedSelectedForTreeNodeLButton$JobId = New-Object System.Windows.Forms.Button -Property @{
                                                text      = "Checkbox The Selected`nIn The`nComputer TreeView"
                                                left      = `$FormScale * 5
                                                top       = `$script:MonitorJobsDetailsCompletedSelectAllButton$JobId.Top + `$script:MonitorJobsDetailsCompletedSelectAllButton$JobId.Height + (`$FormScale * 5)
                                                Width     = `$FormScale * 140
                                                Height    = `$FormScale * 44
                                                Font      = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 10),0,0,0)
                                                ForeColor = "Black"
                                                Add_Click = {
                                                    [System.Windows.Forms.TreeNodeCollection]`$AllHostsNode = `$script:ComputerTreeView.Nodes
                                                    foreach (`$root in `$AllHostsNode) { 
                                                        `$root.Checked = `$false 
                                                        foreach (`$Category in `$root.Nodes) { 
                                                            `$Category.Checked = `$false 
                                                            foreach (`$Entry in `$Category.nodes) { 
                                                                `$Entry.Checked = `$false 
                                                            } 
                                                        } 
                                                    }
    
                                                    foreach (`$Selected in `$script:MonitorJobsDetailsCompletedListBox$JobId.SelectedItems) {
                                                        foreach (`$root in `$AllHostsNode) { 
                                                            foreach (`$Category in `$root.Nodes) { 
                                                                foreach (`$Entry in `$Category.nodes) { 
                                                                    if (`$Entry.Text -eq `$Selected){ 
                                                                        `$Entry.Checked = `$true 
                                                                    }
                                                                } 
                                                            } 
                                                        }
                                                    }
                                                    Conduct-NodeAction -TreeView `$script:ComputerTreeView.Nodes -ComputerList
                                                }
                                            }
                                            `$script:MonitorJobsDetailsCompletedGroupBox$JobId.Controls.Add(`$script:MonitorJobsDetailsCompletedSelectedForTreeNodeLButton$JobId)
                                            CommonButtonSettings -Button `$script:MonitorJobsDetailsCompletedSelectedForTreeNodeLButton$JobId
                                                                           

                                    `$script:MonitorJobsDetailsStoppedGroupBox$JobId = New-Object System.Windows.Forms.GroupBox -Property @{
                                        text      = "Stopped"
                                        left      = `$script:MonitorJobsDetailsCompletedGroupBox$JobId.Left + `$script:MonitorJobsDetailsCompletedGroupBox$JobId.Width + (`$FormScale * 10)
                                        top       = `$FormScale * 10
                                        Width     = `$FormScale * 150
                                        Height    = `$FormScale * 402
                                        Font      = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 12),1,2,1)
                                        ForeColor = "Brown"
                                    }
                                    `$script:MonitorJobsDetailsFrom$JobId.Controls.Add(`$script:MonitorJobsDetailsStoppedGroupBox$JobId)
                                
                                        `$script:MonitorJobsDetailsStoppedListBox$JobId = New-Object System.Windows.Forms.ListBox -Property @{
                                            left      = `$FormScale * 5
                                            top       = `$FormScale * 20
                                            Width     = `$FormScale * 140
                                            Height    = `$FormScale * 300
                                            Font      = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 10),0,0,0)
                                            ForeColor = "Black"
                                            FormattingEnabled   = `$True
                                            SelectionMode       = 'MultiExtended'
                                            ScrollAlwaysVisible = `$True
                                            AutoSize            = `$false
                                        }
                                        `$script:MonitorJobsDetailsStoppedGroupBox$JobId.Controls.Add(`$script:MonitorJobsDetailsStoppedListBox$JobId)
                                
                                
                                        `$script:MonitorJobsDetailsStoppedSelectAllButton$JobId = New-Object System.Windows.Forms.Button -Property @{
                                            text      = 'Select All'
                                            left      = `$FormScale * 5
                                            top       = `$script:MonitorJobsDetailsStoppedListBox$JobId.Top + `$script:MonitorJobsDetailsStoppedListBox$JobId.Height + (`$FormScale * 5)
                                            Width     = `$FormScale * 140
                                            Height    = `$FormScale * 22
                                            Font      = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 10),0,0,0)
                                            ForeColor = "Black"
                                            Add_Click = {
                                                for(`$i = 0; `$i -lt `$script:MonitorJobsDetailsStoppedListBox$JobId.Items.Count; `$i++) {
                                                    `$script:MonitorJobsDetailsStoppedListBox$JobId.SetSelected(`$i, `$true)
                                                }
                                            }
                                        }
                                        `$script:MonitorJobsDetailsStoppedGroupBox$JobId.Controls.Add(`$script:MonitorJobsDetailsStoppedSelectAllButton$JobId)
                                        CommonButtonSettings -Button `$script:MonitorJobsDetailsStoppedSelectAllButton$JobId

                                        
                                        `$script:MonitorJobsDetailsStoppedSelectedForTreeNodeButton$JobId = New-Object System.Windows.Forms.Button -Property @{
                                            text      = "Checkbox The Selected`nIn The`nComputer TreeView"
                                            left      = `$FormScale * 5
                                            top       = `$script:MonitorJobsDetailsStoppedSelectAllButton$JobId.Top + `$script:MonitorJobsDetailsStoppedSelectAllButton$JobId.Height + (`$FormScale * 5)
                                            Width     = `$FormScale * 140
                                            Height    = `$FormScale * 44
                                            Font      = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 10),0,0,0)
                                            ForeColor = "Black"
                                            Add_Click = {
                                                [System.Windows.Forms.TreeNodeCollection]`$AllHostsNode = `$script:ComputerTreeView.Nodes
                                                foreach (`$root in `$AllHostsNode) { 
                                                    `$root.Checked = `$false 
                                                    foreach (`$Category in `$root.Nodes) { 
                                                        `$Category.Checked = `$false 
                                                        foreach (`$Entry in `$Category.nodes) { 
                                                            `$Entry.Checked = `$false 
                                                        } 
                                                    } 
                                                }
                                                
                                                foreach (`$Selected in `$script:MonitorJobsDetailsStoppedListBox$JobId.SelectedItems) {
                                                    foreach (`$root in `$AllHostsNode) { 
                                                        foreach (`$Category in `$root.Nodes) { 
                                                            foreach (`$Entry in `$Category.nodes) { 
                                                                if (`$Entry.Text -eq `$Selected){ 
                                                                    `$Entry.Checked = `$true 
                                                                } 
                                                            } 
                                                        } 
                                                    }
                                                }
                                                Conduct-NodeAction -TreeView `$script:ComputerTreeView.Nodes -ComputerList
                                            }
                                        }
                                        `$script:MonitorJobsDetailsStoppedGroupBox$JobId.Controls.Add(`$script:MonitorJobsDetailsStoppedSelectedForTreeNodeButton$JobId)
                                        CommonButtonSettings -Button `$script:MonitorJobsDetailsStoppedSelectedForTreeNodeButton$JobId


                                        `$script:MonitorJobsDetailsFailedGroupBox$JobId = New-Object System.Windows.Forms.GroupBox -Property @{
                                            text      = "Failed"
                                            left      = `$script:MonitorJobsDetailsStoppedGroupBox$JobId.Left + `$script:MonitorJobsDetailsStoppedGroupBox$JobId.Width + (`$FormScale * 10)
                                            top       = `$FormScale * 10
                                            Width     = `$FormScale * 150
                                            Height    = `$FormScale * 402
                                            Font      = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 12),1,2,1)
                                            ForeColor = "Red"
                                        }
                                        `$script:MonitorJobsDetailsFrom$JobId.Controls.Add(`$script:MonitorJobsDetailsFailedGroupBox$JobId)
                                    
                                            `$script:MonitorJobsDetailsFailedListBox$JobId = New-Object System.Windows.Forms.ListBox -Property @{
                                                left      = `$FormScale * 5
                                                top       = `$FormScale * 20
                                                Width     = `$FormScale * 140
                                                Height    = `$FormScale * 300
                                                Font      = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 10),0,0,0)
                                                ForeColor = "Black"
                                                FormattingEnabled   = `$True
                                                SelectionMode       = 'MultiExtended'
                                                ScrollAlwaysVisible = `$True
                                                AutoSize            = `$false
                                            }
                                            `$script:MonitorJobsDetailsFailedGroupBox$JobId.Controls.Add(`$script:MonitorJobsDetailsFailedListBox$JobId)
                                    
                                    
                                            `$script:MonitorJobsDetailsFailedSelectAllButton$JobId = New-Object System.Windows.Forms.Button -Property @{
                                                text      = 'Select All'
                                                left      = `$FormScale * 5
                                                top       = `$script:MonitorJobsDetailsFailedListBox$JobId.Top + `$script:MonitorJobsDetailsFailedListBox$JobId.Height + (`$FormScale * 5)
                                                Width     = `$FormScale * 140
                                                Height    = `$FormScale * 22
                                                Font      = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 10),0,0,0)
                                                ForeColor = "Black"
                                                Add_Click = {
                                                    for(`$i = 0; `$i -lt `$script:MonitorJobsDetailsFailedListBox$JobId.Items.Count; `$i++) {
                                                        `$script:MonitorJobsDetailsFailedListBox$JobId.SetSelected(`$i, `$true)
                                                    }
                                                }
                                            }
                                            `$script:MonitorJobsDetailsFailedGroupBox$JobId.Controls.Add(`$script:MonitorJobsDetailsFailedSelectAllButton$JobId)
                                            CommonButtonSettings -Button `$script:MonitorJobsDetailsFailedSelectAllButton$JobId

                                    
                                            `$script:MonitorJobsDetailsFailedSelectedForTreeNodeButton$JobId = New-Object System.Windows.Forms.Button -Property @{
                                                text      = "Checkbox The Selected`nIn The`nComputer TreeView"
                                                left      = `$FormScale * 5
                                                top       = `$script:MonitorJobsDetailsFailedSelectAllButton$JobId.Top + `$script:MonitorJobsDetailsFailedSelectAllButton$JobId.Height + (`$FormScale * 5)
                                                Width     = `$FormScale * 140
                                                Height    = `$FormScale * 44
                                                Font      = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 10),0,0,0)
                                                ForeColor = "Black"
                                                Add_Click = {
                                                    [System.Windows.Forms.TreeNodeCollection]`$AllHostsNode = `$script:ComputerTreeView.Nodes
                                                    foreach (`$root in `$AllHostsNode) { 
                                                        `$root.Checked = `$false 
                                                        foreach (`$Category in `$root.Nodes) { 
                                                            `$Category.Checked = `$false 
                                                            foreach (`$Entry in `$Category.nodes) { 
                                                                `$Entry.Checked = `$false 
                                                            } 
                                                        } 
                                                    }
                                                    
                                                    foreach (`$Selected in `$script:MonitorJobsDetailsFailedListBox$JobId.SelectedItems) {
                                                        foreach (`$root in `$AllHostsNode) { 
                                                            foreach (`$Category in `$root.Nodes) { 
                                                                foreach (`$Entry in `$Category.nodes) { 
                                                                    if (`$Entry.Text -eq `$Selected){ 
                                                                        `$Entry.Checked = `$true 
                                                                    } 
                                                                } 
                                                            } 
                                                        }
                                                    }
                                                }
                                            }
                                            `$script:MonitorJobsDetailsFailedGroupBox$JobId.Controls.Add(`$script:MonitorJobsDetailsFailedSelectedForTreeNodeButton$JobId)
                                            CommonButtonSettings -Button `$script:MonitorJobsDetailsFailedSelectedForTreeNodeButton$JobId

                                            
                                    `$script:MonitorJobsDetailsStatusGroupBox$JobId = New-Object System.Windows.Forms.GroupBox -Property @{
                                        text      = "Job Messages"
                                        left      = `$FormScale * 10
                                        top       = `$script:MonitorJobsDetailsCompletedGroupBox$JobId.Top + `$script:MonitorJobsDetailsCompletedGroupBox$JobId.Height + (`$FormScale * 10)
                                        Width     = `$script:MonitorJobsDetailsCompletedGroupBox$JobId.Width + `$script:MonitorJobsDetailsRunningGroupBox$JobId.Width + `$script:MonitorJobsDetailsStoppedGroupBox$JobId.Width + `$script:MonitorJobsDetailsFailedGroupBox$JobId.Width +(`$FormScale * 30)
                                        Height    = `$FormScale * 130
                                        Font      = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 12),1,2,1)
                                        ForeColor = "Black"
                                    }
                                    `$script:MonitorJobsDetailsFrom$JobId.Controls.Add(`$script:MonitorJobsDetailsStatusGroupBox$JobId)

                                        `$script:MonitorJobsDetailsStatusRichTextBox$JobId = New-Object System.Windows.Forms.RichTextbox -Property @{
                                            left      = `$FormScale * 5
                                            top       = `$FormScale * 20
                                            Width     = `$script:MonitorJobsDetailsStatusGroupBox$JobId.Width - (`$FormScale * 10)
                                            Height    = `$FormScale * 110
                                            Font      = New-Object System.Drawing.Font("`$Font",`$(`$FormScale * 10),0,0,0)
                                            ForeColor = "Black"
                                            ShortcutsEnabled = `$true
                                            ReadOnly         = `$false
                                            ScrollBars       = "Vertical"
                                            MultiLine        = `$True
                                            WordWrap         = `$True
                                        }
                                        `$script:MonitorJobsDetailsStatusGroupBox$JobId.Controls.Add(`$script:MonitorJobsDetailsStatusRichTextBox$JobId)
                                
                                    
                                        foreach (`$Job in `$(`$script:CurrentJobs$JobId | Where-Object {`$_.State -eq 'Completed'})) {
                                            `$script:MonitorJobsDetailsCompletedListBox$JobId.Items.Add((`$Job | Select-Object @{n='ComputerName';e={`$((`$Job.Name -split ' ')[-1])}}).ComputerName)
                                        }
                                        `$script:JobsStatusCompletedNameList$JobId -join ', '


                                        foreach (`$Job in `$(`$script:CurrentJobs$JobId | Where-Object {`$_.State -eq 'Running'})) {
                                            `$script:MonitorJobsDetailsRunningListBox$JobId.Items.Add((`$Job | Select-Object @{n='ComputerName';e={`$((`$Job.Name -split ' ')[-1])}}).ComputerName)
                                        }


                                        foreach (`$Job in `$(`$script:CurrentJobs$JobId | Where-Object {`$_.State -eq 'Stopped'})) {
                                            `$CurrentJobEndpointName = (`$Job | Select-Object @{n='ComputerName';e={`$((`$Job.Name -split ' ')[-1])}}).ComputerName

                                            `$script:MonitorJobsDetailsStoppedListBox$JobId.Items.Add(`$CurrentJobEndpointName)
                                            `$script:MonitorJobsDetailsStatusRichTextBox$JobId.text += "[`$(`$CurrentJobEndpointName)]  Timed Out:  `$((New-TimeSpan -Start `$Job.PSBeginTime -End `$Job.PSEndTime).ToString())  (`$(`$Job.PSBeginTime) -- `$(`$Job.PSEndTime))`n`n"
                                        }


                                        foreach (`$Job in `$(`$script:CurrentJobs$JobId | Where-Object {`$_.State -eq 'Failed'})) {
                                            `$CurrentJobEndpointName = (`$Job | Select-Object @{n='ComputerName';e={`$((`$Job.Name -split ' ')[-1])}}).ComputerName

                                            `$script:MonitorJobsDetailsFailedListBox$JobId.Items.Add(`$CurrentJobEndpointName)
                                            `$script:MonitorJobsDetailsStatusRichTextBox$JobId.text += "[`$(`$CurrentJobEndpointName)]  `$(`$job.ChildJobs.JobStateInfo.Reason.Message)`n`n"
                                        }


                                    `$script:MonitorJobsDetailsFrom$JobId.ShowDialog()
            }
        }


        `$script:Section3MonitorJobLabel$JobId = New-Object System.Windows.Forms.Label -Property @{
            Text      = "`$(`$script:JobStartTime$JobId)`n "
            Left      = 0
            Top       = 0
            Width     = `$FormScale * 115
            Height    = `$script:JobsRowHeight
            Font      = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 9),1,2,1)
            ForeColor = 'Blue'
        }


        `$script:Section3MonitorJobProgressBar$JobId = New-Object System.Windows.Forms.ProgressBar -Property @{
            Left      = `$script:Section3MonitorJobLabel$JobId.Left + `$script:Section3MonitorJobLabel$JobId.Width + (`$FormScale * 5)
            Top       = `$script:Section3MonitorJobLabel$JobId.Top
            Width     = `$FormScale * 261
            Height    = `$script:JobsRowHeight
            Font      = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 9),1,2,1)
            value     = 0
            Minimum   = 0
            Maximum   = `$script:JobsStartedCount$JobId
            Forecolor = 'LightBlue'
            BackColor = 'white'
            Style     = 'Continuous' #Marque
        }


        `$script:Section3MonitorJobTransparentLabel$JobId = New-Object System.Windows.Forms.Label -Property @{
            Text      = "[0/`$script:JobsStartedCount$JobId] `$script:JobName$JobId"
            Left      = `$script:Section3MonitorJobLabel$JobId.Left + `$script:Section3MonitorJobLabel$JobId.Width + (`$FormScale * 5)
            Top       = `$script:Section3MonitorJobLabel$JobId.Top - `$(`$FormScale * 1)
            Width     = `$FormScale * 261
         Height    = `$script:JobsRowHeight / 2
            Font      = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 9),1,2,1)
            ForeColor = 'Blue'
            BackColor = [System.Drawing.Color]::FromName('Transparent')
        }
"@

        if ($PcapSwitch) {
        Invoke-Expression @"
            `$script:PcapEndpointName$JobId = `$(`$script:CurrentJobs$JobId[0].name -split ' ')[-2]
            `$script:PcapJobData$JobId = `$(`$script:CurrentJobs$JobId[0].name -split ' ')[-1]

            `$script:Section3MonitorJobTransparentLabel$JobId.text = = "[0/`$script:JobsStartedCount$JobId] `$script:JobName$JobId (`$script:PcapEndpointName$JobId)"

            `$script:Section3MonitorJobViewButton$JobId = New-Object System.Windows.Forms.Button -Property @{
                text      = 'Open Folder'
                Left      = `$script:Section3MonitorJobProgressBar$JobId.Left + `$script:Section3MonitorJobProgressBar$JobId.Width + (`$FormScale * 5)
                Top       = `$script:Section3MonitorJobLabel$JobId.Top
                Width     = `$FormScale * 100
                Height    = `$script:JobsRowHeight
                Font      = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 8),1,2,1)
                Add_click = {
                    if (`$script:Section3MonitorJobViewButton$JobId.BackColor -eq 'LightGreen') {
                        `$script:Section3MonitorJobViewButton$JobId.BackColor = 'LightGray'
                    }
                    Invoke-Item "`$(`$script:CollectionSavedDirectoryTextBox.Text)\Results By Endpoints\$CollectionName\"
                }
            }
    
            
            `$script:Section3MonitorJobTerminalButton$JobId = New-Object System.Windows.Forms.Button -Property @{
                text     = 'View PCap'
                Left     = `$script:Section3MonitorJobViewButton$JobId.Left + `$script:Section3MonitorJobViewButton$JobId.Width + (`$FormScale * 5)
                Top      = `$script:Section3MonitorJobLabel$JobId.Top
                Width    = `$FormScale * 75
                Height   = `$script:JobsRowHeight
                Font     = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 8),1,2,1)
                Add_click = {
                    if (`$script:Section3MonitorJobTerminalButton$JobId.BackColor -eq 'LightGreen') {
                        `$script:Section3MonitorJobTerminalButton$JobId.BackColor = 'LightGray'
                    }
                    if ((Test-Path "`$(`$script:CollectionSavedDirectoryTextBox.Text)\Results By Endpoints\$CollectionName\`$(`$script:PcapEndpointName$JobId)*Packet Capture*`$(`$script:PcapJobData$JobId)*.pcapng")) {
                        Invoke-Item "`$(`$script:CollectionSavedDirectoryTextBox.Text)\Results By Endpoints\$CollectionName\`$(`$script:PcapEndpointName$JobId)*Packet Capture*`$(`$script:PcapJobData$JobId)*.pcapng"
                    }
                    else {
                        [System.Windows.Forms.MessageBox]::Show("This feature requires you wait until the command has completed.",'PoSh-EasyWin')
                    }
                }
            }


            `$script:Section3MonitorJobRemoveButton$JobId = New-Object System.Windows.Forms.Button -Property @{
                Text      = 'Remove'
                Left      = `$script:Section3MonitorJobTerminalButton$JobId.Left + `$script:Section3MonitorJobTerminalButton$JobId.Width + (`$FormScale * 5)
                Top       = `$script:Section3MonitorJobLabel$JobId.Top
                Width     = `$FormScale * 75
                Height    = `$script:JobsRowHeight
                Font      = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 8),1,2,1)
                ForeColor = 'Red'
                Add_click = {
                    function JobsRemoveFunction$JobId {
                        if (`$script:Section3MonitorJobKeepDataCheckbox$JobId.Checked -eq `$false) {
                            Remove-Item "`$(`$script:CollectionSavedDirectoryTextBox.Text)\Results By Endpoints\$CollectionName\`$(`$script:PcapEndpointName$JobId)*Packet Capture*`$(`$script:PcapJobData$JobId)*.pcapng" -Force
                        }
    
                        `$script:CurrentJobs$JobId | Stop-Job
                        `$script:CurrentJobs$JobId | Remove-Job -Force
        
                        # Moves all form items higher up that are not created before this one
                        Get-Variable | Where-Object {`$_.Name -match 'Section3MonitorJobPanel'} | Foreach-Object {
                            if (`$_.Name -notin `$script:PreviousJobFormItemsList$JobId){
                                `$_.Value.top = `$_.Value.Top - `$script:JobsRowHeight - `$script:JobsRowGap
                            }
                        }
    
    
                        `$script:MonitorJobsTopPosition -= (`$script:Section3MonitorJobPanel$JobId.Height + `$script:JobsRowGap)
    
                        
                        `$script:Section3MonitorJobsTab.Controls.Remove(`$script:Section3MonitorJobPanel$JobId)
                        `$script:Section3MonitorJobPanel$JobId.Controls.Remove(`$script:Section3MonitorJobDetailsButton$JobId)
                        `$script:Section3MonitorJobPanel$JobId.Controls.Remove(`$script:Section3MonitorJobLabel$JobId)
                        `$script:Section3MonitorJobPanel$JobId.Controls.Remove(`$script:Section3MonitorJobProgressBar$JobId)
                        `$script:Section3MonitorJobPanel$JobId.Controls.Remove(`$script:Section3MonitorJobRemoveButton$JobId)
                        `$script:Section3MonitorJobPanel$JobId.Controls.Remove(`$script:Section3MonitorJobViewButton$JobId)
                        `$script:Section3MonitorJobPanel$JobId.Controls.Remove(`$script:Section3MonitorJobTerminalButton$JobId)
                        `$script:Section3MonitorJobPanel$JobId.Controls.Remove(`$script:Section3MonitorJobKeepDataCheckbox$JobId)
                        `$script:Section3MonitorJobPanel$JobId.Controls.Remove(`$script:Section3MonitorJobNotifyCheckbox$JobId)
                        `$script:Section3MonitorJobPanel$JobId.Controls.Remove(`$script:Section3MonitorJobTransparentLabel$JobId)
    
                        `$script:Section3MonitorJobPanel$JobId = `$null
                        Remove-Variable -Name Section3MonitorJobPanel$JobId -Scope Script                    
                        `$script:Section3MonitorJobLabel$JobId = `$null
                        Remove-Variable -Name Section3MonitorJobLabel$JobId -Scope Script
                        `$script:Section3MonitorJobDetailsButton$JobId = `$null
                        Remove-Variable -Name Section3MonitorJobDetailsButton$JobId -Scope Script
                        `$script:Section3MonitorJobProgressBar$JobId = `$null
                        Remove-Variable -Name Section3MonitorJobProgressBar$JobId -Scope Script                    
                        `$script:Section3MonitorJobRemoveButton$JobId = `$null
                        Remove-Variable -Name Section3MonitorJobRemoveButton$JobId -Scope Script
                        `$script:Section3MonitorJobViewButton$JobId = `$null
                        Remove-Variable -Name Section3MonitorJobViewButton$JobId -Scope Script                    
                        `$script:Section3MonitorJobTerminalButton$JobId = `$null
                        Remove-Variable -Name Section3MonitorJobTerminalButton$JobId -Scope Script
                        `$script:Section3MonitorJobKeepDataCheckbox$JobId = `$null
                        Remove-Variable -Name Section3MonitorJobKeepDataCheckbox$JobId -Scope Script
                        `$script:Section3MonitorJobNotifyCheckbox$JobId = `$null
                        Remove-Variable -Name Section3MonitorJobNotifyCheckbox$JobId -Scope Script
                        `$script:Section3MonitorJobTransparentLabel$JobId = `$null
                        Remove-Variable -Name Section3MonitorJobTransparentLabel$JobId -Scope Script
    
                        
                        `$script:CurrentJobs$JobId = `$null
                        Remove-Variable -Name CurrentJobs$JobId -Scope Script
                        
                            
                        # Garbage Collection to free up memory
                        [System.GC]::Collect()                    
                    }
    
                    if (`$script:Section3MonitorJobKeepDataCheckbox$JobId.Checked -eq `$false) {
                        `$RemoveJobVerify$JobId = [System.Windows.Forms.MessageBox]::Show("You checked to not keep the saved data.`nAre you sure you want to remove the following:`n        `$(`$script:JobName$JobId)",'PoSh-EasyWin','YesNo','Warning')
                        switch (`$RemoveJobVerify$JobId) {
                            'Yes'{
                                JobsRemoveFunction$JobId
                            }
                            'No' {
                                continue
                            }
                        }
                    }
                    else {
                        JobsRemoveFunction$JobId
                    }
                }
            }    
"@    
        }
        else {
    Invoke-Expression @"
            `$script:Section3MonitorJobViewButton$JobId = New-Object System.Windows.Forms.Button -Property @{
                text      = 'View Progress'
                Left      = `$script:Section3MonitorJobProgressBar$JobId.Left + `$script:Section3MonitorJobProgressBar$JobId.Width + (`$FormScale * 5)
                Top       = `$script:Section3MonitorJobLabel$JobId.Top
                Width     = `$FormScale * 100
                Height    = `$script:JobsRowHeight
                Font      = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 8),1,2,1)
                Add_click = {
                    if (`$script:Section3MonitorJobViewButton$JobId.BackColor -eq 'LightGreen') {
                        `$script:Section3MonitorJobViewButton$JobId.BackColor = 'LightGray'
                    }
                    if ((Test-Path "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId)).csv")) {
                        Import-Csv "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId)).csv" | Out-GridView -Title "PoSh-EasyWin: `$(`$script:JobName$JobId) (`$(`$JobStartTimeFileFriendly$JobId))"
                    }
                    else {
                        `$script:CurrentJobsWithComputerName$JobId = @()
                        foreach (`$Job in `$script:CurrentJobs$JobId) {
                            `$script:CurrentJobsWithComputerName$JobId += `$Job | Receive-Job -Keep | Select-Object @{n='ComputerName';e={"`$((`$Job.Name -split ' ')[-1])"}},* -ErrorAction SilentlyContinue
                        }
                        `$script:CurrentJobsWithComputerName$JobId | Out-GridView -Title "PoSh-EasyWin: `$(`$script:JobName$JobId) (`$(`$JobStartTimeFileFriendly$JobId))"

                        `$script:CurrentJobsWithComputerName$JobId = `$null
                        Remove-Variable -Name CurrentJobsWithComputerName$JobId -Scope script
                    }
                }
            }
    
            
            `$script:Section3MonitorJobTerminalButton$JobId = New-Object System.Windows.Forms.Button -Property @{
                text     = 'Terminal'
                Left     = `$script:Section3MonitorJobViewButton$JobId.Left + `$script:Section3MonitorJobViewButton$JobId.Width + (`$FormScale * 5)
                Top      = `$script:Section3MonitorJobLabel$JobId.Top
                Width    = `$FormScale * 75
                Height   = `$script:JobsRowHeight
                Font     = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 8),1,2,1)
                Add_click = {
                    if (`$script:Section3MonitorJobTerminalButton$JobId.BackColor -eq 'LightGreen') {
                        `$script:Section3MonitorJobTerminalButton$JobId.BackColor = 'LightGray'
                    }
                    if ((Test-Path "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId)).xml")) {
                        Open-XmlResultsInShell -ViewImportResults "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId)).xml" -FileName "`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId)).xml" -SavePath `$script:CollectionSavedDirectoryTextBox.Text
                    }
                    else {
                        [System.Windows.Forms.MessageBox]::Show("This feature requires you wait until the command has completed.",'PoSh-EasyWin')
                    }
                }
            }


            `$script:Section3MonitorJobRemoveButton$JobId = New-Object System.Windows.Forms.Button -Property @{
                Text      = 'Remove'
                Left      = `$script:Section3MonitorJobTerminalButton$JobId.Left + `$script:Section3MonitorJobTerminalButton$JobId.Width + (`$FormScale * 5)
                Top       = `$script:Section3MonitorJobLabel$JobId.Top
                Width     = `$FormScale * 75
                Height    = `$script:JobsRowHeight
                Font      = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 8),1,2,1)
                ForeColor = 'Red'
                Add_click = {
                    function JobsRemoveFunction$JobId {
                        if (`$script:Section3MonitorJobKeepDataCheckbox$JobId.Checked -eq `$false) {
                            Remove-Item "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId)).csv" -Force
                            Remove-Item "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId)).xml" -Force     
                        }
    
                        `$script:CurrentJobs$JobId | Stop-Job
                        `$script:CurrentJobs$JobId | Remove-Job -Force
        
                        # Moves all form items higher up that are not created before this one
                        Get-Variable | Where-Object {`$_.Name -match 'Section3MonitorJobPanel'} | Foreach-Object {
                            if (`$_.Name -notin `$script:PreviousJobFormItemsList$JobId){
                                `$_.Value.top = `$_.Value.Top - `$script:JobsRowHeight - `$script:JobsRowGap
                            }
                        }
    
    
                        `$script:MonitorJobsTopPosition -= (`$script:Section3MonitorJobPanel$JobId.Height + `$script:JobsRowGap)
    
                        
                        `$script:Section3MonitorJobsTab.Controls.Remove(`$script:Section3MonitorJobPanel$JobId)
                        `$script:Section3MonitorJobPanel$JobId.Controls.Remove(`$script:Section3MonitorJobLabel$JobId)
                        `$script:Section3MonitorJobPanel$JobId.Controls.Remove(`$script:Section3MonitorJobDetailsButton$JobId)
                        `$script:Section3MonitorJobPanel$JobId.Controls.Remove(`$script:Section3MonitorJobProgressBar$JobId)
                        `$script:Section3MonitorJobPanel$JobId.Controls.Remove(`$script:Section3MonitorJobRemoveButton$JobId)
                        `$script:Section3MonitorJobPanel$JobId.Controls.Remove(`$script:Section3MonitorJobViewButton$JobId)
                        `$script:Section3MonitorJobPanel$JobId.Controls.Remove(`$script:Section3MonitorJobTerminalButton$JobId)
                        `$script:Section3MonitorJobPanel$JobId.Controls.Remove(`$script:Section3MonitorJobKeepDataCheckbox$JobId)
                        `$script:Section3MonitorJobPanel$JobId.Controls.Remove(`$script:Section3MonitorJobNotifyCheckbox$JobId)
                        `$script:Section3MonitorJobPanel$JobId.Controls.Remove(`$script:Section3MonitorJobTransparentLabel$JobId)
    
                        `$script:Section3MonitorJobPanel$JobId = `$null
                        Remove-Variable -Name Section3MonitorJobPanel$JobId -Scope Script
                        `$script:Section3MonitorJobLabel$JobId = `$null
                        Remove-Variable -Name Section3MonitorJobLabel$JobId -Scope Script
                        `$script:Section3MonitorJobDetailsButton$JobId = `$null
                        Remove-Variable -Name Section3MonitorJobDetailsButton$JobId -Scope Script
                        `$script:Section3MonitorJobProgressBar$JobId = `$null
                        Remove-Variable -Name Section3MonitorJobProgressBar$JobId -Scope Script
                        `$script:Section3MonitorJobRemoveButton$JobId = `$null
                        Remove-Variable -Name Section3MonitorJobRemoveButton$JobId -Scope Script
                        `$script:Section3MonitorJobViewButton$JobId = `$null
                        Remove-Variable -Name Section3MonitorJobViewButton$JobId -Scope Script
                        `$script:Section3MonitorJobTerminalButton$JobId = `$null
                        Remove-Variable -Name Section3MonitorJobTerminalButton$JobId -Scope Script
                        `$script:Section3MonitorJobKeepDataCheckbox$JobId = `$null
                        Remove-Variable -Name Section3MonitorJobKeepDataCheckbox$JobId -Scope Script
                        `$script:Section3MonitorJobNotifyCheckbox$JobId = `$null
                        Remove-Variable -Name Section3MonitorJobNotifyCheckbox$JobId -Scope Script
                        `$script:Section3MonitorJobTransparentLabel$JobId = `$null
                        Remove-Variable -Name Section3MonitorJobTransparentLabel$JobId -Scope Script
    
                        
                        `$script:CurrentJobs$JobId = `$null
                        Remove-Variable -Name CurrentJobs$JobId -Scope Script
                        
                            
                        # Garbage Collection to free up memory
                        [System.GC]::Collect()                    
                    }
    
                    if (`$script:Section3MonitorJobKeepDataCheckbox$JobId.Checked -eq `$false) {
                        `$RemoveJobVerify$JobId = [System.Windows.Forms.MessageBox]::Show("You checked to not keep the saved data.`nAre you sure you want to remove the following:`n        `$(`$script:JobName$JobId)",'PoSh-EasyWin','YesNo','Warning')
                        switch (`$RemoveJobVerify$JobId) {
                            'Yes'{
                                JobsRemoveFunction$JobId
                            }
                            'No' {
                                continue
                            }
                        }
                    }
                    else {
                        JobsRemoveFunction$JobId
                    }
                }
            }    
"@    
        }

        
    Invoke-Expression @"
        `$script:Section3MonitorJobKeepDataCheckbox$JobId = New-Object System.Windows.Forms.Checkbox -Property @{
            Text     = 'Keep Data'
            Left     = `$script:Section3MonitorJobRemoveButton$JobId.Left + `$script:Section3MonitorJobRemoveButton$JobId.Width + (`$FormScale * 5)
            Top      = `$script:Section3MonitorJobLabel$JobId.Top
            Width    = `$FormScale * 70
            Height   = `$script:JobsRowHeight / 2
            Font     = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 8),1,2,1)
            Checked  = `$true
            add_click = {
                if (`$script:Section3MonitorJobKeepDataCheckbox$JobId.checked -eq `$false) {
                    `$script:Section3MonitorJobKeepDataAllCheckbox.checked = `$false
                    `$script:Section3MonitorJobKeepDataAllCheckbox.forecolor = 'red'
                    `$script:Section3MonitorJobKeepDataCheckbox$JobId.forecolor = 'red'
                }
                else {
                    `$script:Section3MonitorJobKeepDataCheckbox$JobId.forecolor = 'black'
                }
            }
        }


        `$script:Section3MonitorJobNotifyCheckbox$JobId = New-Object System.Windows.Forms.Checkbox -Property @{
            Text     = 'Notify Me'
            Left     = `$script:Section3MonitorJobRemoveButton$JobId.Left + `$script:Section3MonitorJobRemoveButton$JobId.Width + (`$FormScale * 5)
            Top      = `$script:Section3MonitorJobKeepDataCheckbox$JobId.Top + `$script:Section3MonitorJobKeepDataCheckbox$JobId.Height + (`$FormScale * 1)
            Width    = `$FormScale * 70
            Height   = `$script:JobsRowHeight / 2
            Font     = New-Object System.Drawing.Font('Courier New',`$(`$FormScale * 8),1,2,1)
            Checked  = `$false
            forecolor = 'black'
            add_click = {
                if (`$script:Section3MonitorJobNotifyCheckbox$JobId.checked -eq `$false) {
                    `$script:Section3MonitorJobNotifyAllCheckbox.checked = `$false
                    `$script:Section3MonitorJobNotifyAllCheckbox.forecolor = 'black'
                    `$script:Section3MonitorJobNotifyCheckbox$JobId.forecolor = 'black'
                }
                else {
                    `$script:Section3MonitorJobNotifyCheckbox$JobId.forecolor = 'blue'
                }
            }
        }


        `$script:Section3MonitorJobsTab.Controls.Add(`$script:Section3MonitorJobPanel$JobId)
        `$script:Section3MonitorJobPanel$JobId.Controls.AddRange(@(
            `$script:Section3MonitorJobDetailsButton$JobId,
            `$script:Section3MonitorJobLabel$JobId,
            `$script:Section3MonitorJobTransparentLabel$JobId,
            `$script:Section3MonitorJobProgressBar$JobId,
            `$script:Section3MonitorJobViewButton$JobId,
            `$script:Section3MonitorJobTerminalButton$JobId,
            `$script:Section3MonitorJobRemoveButton$JobId,
            `$script:Section3MonitorJobKeepDataCheckbox$JobId,
            `$script:Section3MonitorJobNotifyCheckbox$JobId
        ))

        
        CommonButtonSettings -Button `$script:Section3MonitorJobDetailsButton$JobId
        CommonButtonSettings -Button `$script:Section3MonitorJobViewButton$JobId
        `$script:Section3MonitorJobViewButton$JobId.BackColor = 'LightBlue'
        CommonButtonSettings -Button `$script:Section3MonitorJobTerminalButton$JobId
        CommonButtonSettings -Button `$script:Section3MonitorJobRemoveButton$JobId
        `$script:Section3MonitorJobRemoveButton$JobId.ForeColor = 'Red'

        `$PoShEasyWin.Refresh()

        `$script:MonitorJobsTopPosition += (`$script:Section3MonitorJobPanel$JobId.Height + `$script:JobsRowGap)

        # This adds each form item to a list
        `$script:PreviousJobFormItemsList += "Section3MonitorJobPanel$JobId"
        `$script:PreviousJobFormItemsList += "Section3MonitorJobLabel$JobId"
        `$script:PreviousJobFormItemsList += "Section3MonitorJobDetailsButton$JobId"
        `$script:PreviousJobFormItemsList += "Section3MonitorJobProgressBar$JobId"
        `$script:PreviousJobFormItemsList += "Section3MonitorJobTransparentLabel$JobId"
        `$script:PreviousJobFormItemsList += "Section3MonitorJobRemoveButton$JobId"
        `$script:PreviousJobFormItemsList += "Section3MonitorJobViewButton$JobId"
        `$script:PreviousJobFormItemsList += "Section3MonitorJobTerminalButton$JobId"
        `$script:PreviousJobFormItemsList += "Section3MonitorJobKeepDataCheckbox$JobId"
        `$script:PreviousJobFormItemsList += "Section3MonitorJobNotifyCheckbox$JobId"

"@
    ##############################################
    # Timer code that monitors the jobs by query #
    ##############################################
    if ($PcapSwitch){
    # For just Packet Capture
        Invoke-Expression @"
        `$script:Timer$JobId.add_Tick({
            `$script:JobsNotRunning$JobId = (`$script:CurrentJobs$JobId | Where-Object {`$_.State -ne 'Running'}).count

            if (`$script:JobsStartedCount$JobId -eq `$script:JobsNotRunning$JobId) {
                `$script:Section3MonitorJobLabel$JobId.text = "`$(`$script:JobStartTime$JobId)`n   `$(`$((New-TimeSpan -Start (`$script:JobStartTime$JobId)).ToString()))"
                `$script:Section3MonitorJobTransparentLabel$JobId.text = "[`$(`$script:JobsNotRunning$JobId)/`$script:JobsStartedCount$JobId] `$script:JobName$JobId (`$script:PcapEndpointName$JobId)"

                `$script:Section3MonitorJobLabel$JobId.ForeColor = 'Black'
                `$script:Section3MonitorJobTransparentLabel$JobId.ForeColor = 'Black'
                `$script:Section3MonitorJobProgressBar$JobId.ForeColor = 'LightGreen'
                `$script:Section3MonitorJobViewButton$JobId.BackColor = 'LightGreen'
                `$script:Section3MonitorJobTerminalButton$JobId.BackColor = 'LightGreen'

                
                `$script:JobsStartedCount$JobId = -1
                `$script:JobsTimeCompleted$JobId = Get-Date
                `$script:Timer$JobId.Stop()
                `$script:Timer$JobId = `$null
                Remove-Variable -Name Timer$JobId -Scope script


                
                
                `$script:Section3MonitorJobProgressBar$JobId.Value = `$script:Section3MonitorJobProgressBar$JobId.Maximum
                `$script:Section3MonitorJobProgressBar$JobId.Refresh()

                if (`$script:Section3MonitorJobNotifyCheckbox$JobId.checked -eq `$true){
                    [System.Windows.Forms.MessageBox]::Show("`$(`$script:JobName$JobId)`n`nTime Completed:`n     `$(`$script:JobsTimeCompleted$JobId)",'PoSh-EasyWin')
                }
            }
            else {
                `$script:Section3MonitorJobLabel$JobId.text = "`$(`$script:JobStartTime$JobId)`n   `$(`$((New-TimeSpan -Start (`$script:JobStartTime$JobId)).ToString()))"
                `$script:Section3MonitorJobTransparentLabel$JobId.text = "[`$(`$script:JobsNotRunning$JobId)/`$script:JobsStartedCount$JobId] `$script:JobName$JobId (`$script:PcapEndpointName$JobId)"

                
                `$script:Section3MonitorJobProgressBar$JobId.Value = `$script:JobsNotRunning$JobId
                `$script:Section3MonitorJobProgressBar$JobId.Refresh()
            }
        })
"@        
    }
    elseif ($PSWriteHTMLSwitch) {
    # Just for queries that generate the PSWriteHTML charts
        Invoke-Expression @"
        `$script:Timer$JobId.add_Tick({
            `$script:JobsNotRunning$JobId = (`$script:CurrentJobs$JobId | Where-Object {`$_.State -ne 'Running'}).count

            if (`$script:JobsStartedCount$JobId -eq `$script:JobsNotRunning$JobId) {
                `$script:Section3MonitorJobLabel$JobId.text = "`$(`$script:JobStartTime$JobId)`n   `$(`$((New-TimeSpan -Start (`$script:JobStartTime$JobId)).ToString()))"
                `$script:Section3MonitorJobTransparentLabel$JobId.Text = "[`$(`$script:JobsNotRunning$JobId)/`$script:JobsStartedCount$JobId] `$script:JobName$JobId"

                `$script:Section3MonitorJobLabel$JobId.ForeColor = 'Black'
                `$script:Section3MonitorJobTransparentLabel$JobId.ForeColor = 'Black'
                `$script:Section3MonitorJobProgressBar$JobId.ForeColor = 'LightGreen'
                `$script:Section3MonitorJobViewButton$JobId.Text = 'View Results'
                `$script:Section3MonitorJobViewButton$JobId.BackColor = 'LightGreen'
                `$script:Section3MonitorJobTerminalButton$JobId.BackColor = 'LightGreen'

                
                `$script:JobsStartedCount$JobId = -1
                `$script:JobsTimeCompleted$JobId = Get-Date
                `$script:Timer$JobId.Stop()
                `$script:Timer$JobId = `$null
                Remove-Variable -Name Timer$JobId -Scope script


                `$script:CurrentJobs$JobId | Receive-Job -Keep | Export-Csv "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId)).csv" -NoTypeInformation
                `$script:CurrentJobs$JobId | Receive-Job -Keep | Export-CliXml "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId)).xml"


                if ("$PSWriteHTML" -eq 'PSWriteHTMLProcesses') {
                    `$script:$PSWriteHTML = `$script:CurrentJobs$JobId | Receive-Job
                    script:Individual-PSWriteHTML -Title 'Process Data' -Data { script:Start-PSWriteHTMLProcessData }
                }
                elseif ("$PSWriteHTML" -eq 'EndpointDataNetworkConnections') {
                    `$script:$PSWriteHTML = `$script:CurrentJobs$JobId | Receive-Job
                    script:Individual-PSWriteHTML -Title 'Network Connections' -Data { script:Start-PSWriteHTMLNetworkConnections }
                }
                elseif ("$PSWriteHTML" -eq 'EndpointDataConsoleLogons') {
                    `$script:$PSWriteHTML = `$script:CurrentJobs$JobId | Receive-Job
                    script:Individual-PSWriteHTML -Title 'Console Logons' -Data { script:Start-PSWriteHTMLConsoleLogons }
                }
                elseif ("$PSWriteHTML" -eq 'PowerShellSessionsData') {
                    `$script:$PSWriteHTML = `$script:CurrentJobs$JobId | Receive-Job
                    script:Individual-PSWriteHTML -Title 'PowerShell Sessions' -Data { script:Start-PSWriteHTMLPowerShellSessions }
                }
                elseif ("$PSWriteHTML" -eq 'XXXXXXXXXXXXXXXXX') {
                    `$script:$PSWriteHTML = `$script:CurrentJobs$JobId | Receive-Job

                }
                elseif ("$PSWriteHTML" -eq 'EndpointApplicationCrashes') {
                    `$script:$PSWriteHTML = `$script:CurrentJobs$JobId | Receive-Job
                    script:Individual-PSWriteHTML -Title 'Application Crashes' -Data { script:Start-PSWriteHTMLApplicationCrashes }
                }
                elseif ("$PSWriteHTML" -eq 'EndpointLogonActivity') {
                    `$script:$PSWriteHTML = `$script:CurrentJobs$JobId | Receive-Job
                    script:Individual-PSWriteHTML -Title 'Logon Activity' -Data { script:Start-PSWriteHTMLLogonActivity }
                }
                elseif ("$PSWriteHTML" -eq 'PSWriteHTMLADUsers') {
                    `$script:$PSWriteHTML = `$script:CurrentJobs$JobId | Receive-Job
                    script:Individual-PSWriteHTML -Title 'AD Users' -Data { script:Start-PSWriteHTMLActiveDirectoryUsers }
                }
                elseif ("$PSWriteHTML" -eq 'PSWriteHTMLADComputers') {
                    `$script:$PSWriteHTML = `$script:CurrentJobs$JobId | Receive-Job
                    script:Individual-PSWriteHTML -Title 'AD Computers' -Data { script:Start-PSWriteHTMLActiveDirectoryComputers }
                }

                
                `$script:Section3MonitorJobProgressBar$JobId.Value = `$script:Section3MonitorJobProgressBar$JobId.Maximum
                `$script:Section3MonitorJobProgressBar$JobId.Refresh()

                if (`$script:Section3MonitorJobNotifyCheckbox$JobId.checked -eq `$true){
                    [System.Windows.Forms.MessageBox]::Show("`$(`$script:JobName$JobId)`n`nTime Completed:`n     `$(`$script:JobsTimeCompleted$JobId)",'PoSh-EasyWin')
                }
            }
            else {
                `$script:Section3MonitorJobLabel$JobId.text = "`$(`$script:JobStartTime$JobId)`n   `$(`$((New-TimeSpan -Start (`$script:JobStartTime$JobId)).ToString()))"
                `$script:Section3MonitorJobTransparentLabel$JobId.Text = "[`$(`$script:JobsNotRunning$JobId)/`$script:JobsStartedCount$JobId] `$script:JobName$JobId"

                `$script:Section3MonitorJobProgressBar$JobId.Value = `$script:JobsNotRunning$JobId
                `$script:Section3MonitorJobProgressBar$JobId.Refresh()
            }
        })        
"@
    }
    else {
    # Everything else, all the treeview queries checked and collection tabs.
        Invoke-Expression @"
        `$script:Timer$JobId.add_Tick({
            `$script:JobsNotRunning$JobId = (`$script:CurrentJobs$JobId | Where-Object {`$_.State -ne 'Running'}).count

            `$script:CurrentTime$JobId = Get-Date


            if (`$script:JobsStartedCount$JobId -eq `$script:JobsNotRunning$JobId) {
                `$script:Section3MonitorJobLabel$JobId.text = "`$(`$script:JobStartTime$JobId)`n   `$(`$((New-TimeSpan -Start (`$script:JobStartTime$JobId)).ToString()))"
                `$script:Section3MonitorJobTransparentLabel$JobId.Text = "[`$(`$script:JobsNotRunning$JobId)/`$script:JobsStartedCount$JobId] `$script:JobName$JobId"

                `$script:Section3MonitorJobLabel$JobId.ForeColor = 'Black'
                `$script:Section3MonitorJobTransparentLabel$JobId.ForeColor = 'Black'
                `$script:Section3MonitorJobProgressBar$JobId.ForeColor = 'LightGreen'
                `$script:Section3MonitorJobViewButton$JobId.Text = 'View Results'
                `$script:Section3MonitorJobViewButton$JobId.BackColor = 'LightGreen'
                `$script:Section3MonitorJobTerminalButton$JobId.BackColor = 'LightGreen'

                
                `$script:JobsStartedCount$JobId = -1
                `$script:JobsTimeCompleted$JobId = Get-Date
                `$script:Timer$JobId.Stop()
                `$script:Timer$JobId = `$null
                Remove-Variable -Name Timer$JobId -Scope script


                `$script:CurrentJobsWithComputerName$JobId = @()
                foreach (`$Job in `$script:CurrentJobs$JobId) {
                    `$script:CurrentJobsWithComputerName$JobId += `$Job | Receive-Job -Keep | Select-Object @{n='ComputerName';e={"`$((`$Job.Name -split ' ')[-1])"}},* -ErrorAction SilentlyContinue
                }

                `$script:CurrentJobsWithComputerName$JobId | Export-Csv "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId)).csv" -NoTypeInformation
                `$script:CurrentJobsWithComputerName$JobId | Export-CliXml "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId)).xml"
                `$script:CurrentJobsWithComputerName$JobId = `$null
                Remove-Variable -Name CurrentJobsWithComputerName$JobId -Scope script

                `$script:Section3MonitorJobProgressBar$JobId.Value = `$script:Section3MonitorJobProgressBar$JobId.Maximum
                `$script:Section3MonitorJobProgressBar$JobId.Refresh()

                if (`$script:Section3MonitorJobNotifyCheckbox$JobId.checked -eq `$true){
                    [System.Windows.Forms.MessageBox]::Show("`$(`$script:JobName$JobId)`n`nTime Completed:`n     `$(`$script:JobsTimeCompleted$JobId)",'PoSh-EasyWin')
                }
            }
            else {
                `$script:Section3MonitorJobLabel$JobId.text = "`$(`$script:JobStartTime$JobId)`n   `$(`$((New-TimeSpan -Start (`$script:JobStartTime$JobId)).ToString()))"
                `$script:Section3MonitorJobTransparentLabel$JobId.Text = "[`$(`$script:JobsNotRunning$JobId)/`$script:JobsStartedCount$JobId] `$script:JobName$JobId"

                `$script:Section3MonitorJobProgressBar$JobId.Value = `$script:JobsNotRunning$JobId
                `$script:Section3MonitorJobProgressBar$JobId.Refresh()

                if (`$script:CurrentTime$JobId -gt (`$script:CurrentJobs$JobId.PSBeginTime[0]).AddSeconds(`$script:JobsTimer$JobId) ) {
                    `$script:Section3MonitorJobLabel$JobId.text = "`$(`$script:JobStartTime$JobId)`n   `$(`$((New-TimeSpan -Start (`$script:JobStartTime$JobId)).ToString()))"
                    `$script:Section3MonitorJobTransparentLabel$JobId.Text = "TIMED OUT [`$(`$script:JobsNotRunning$JobId)/`$script:JobsStartedCount$JobId] `$script:JobName$JobId"
    
                    `$script:Section3MonitorJobLabel$JobId.ForeColor = 'Red'
                    `$script:Section3MonitorJobTransparentLabel$JobId.ForeColor = 'Red'
                    `$script:Section3MonitorJobProgressBar$JobId.ForeColor = 'LightCoral'
                    `$script:Section3MonitorJobViewButton$JobId.Text = 'View Results'
                    `$script:Section3MonitorJobViewButton$JobId.BackColor = 'LightGreen'
                    `$script:Section3MonitorJobTerminalButton$JobId.BackColor = 'LightGreen'
    
                    
                    `$script:JobsStartedCount$JobId = -1
                    `$script:JobsTimeCompleted$JobId = Get-Date
                    `$script:Timer$JobId.Stop()
                    `$script:Timer$JobId = `$null
                    Remove-Variable -Name Timer$JobId -Scope script
    
    
                    `$script:CurrentJobs$JobId | Receive-Job -Keep | Export-Csv "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId)).csv" -NoTypeInformation
                    `$script:CurrentJobs$JobId | Receive-Job -Keep | Export-CliXml "`$(`$script:CollectionSavedDirectoryTextBox.Text)\`$script:JobName$JobId (`$(`$JobStartTimeFileFriendly$JobId)).xml"
                    `$script:CurrentJobs$JobId | Stop-Job

                    
                    `$script:Section3MonitorJobProgressBar$JobId.Value = `$script:Section3MonitorJobProgressBar$JobId.Maximum
                    `$script:Section3MonitorJobProgressBar$JobId.Refresh()
    
                    if (`$script:Section3MonitorJobNotifyCheckbox$JobId.checked -eq `$true){
                        [System.Windows.Forms.MessageBox]::Show("`$(`$script:JobName$JobId)`n`nTime Completed:`n     `$(`$script:JobsTimeCompleted$JobId)",'PoSh-EasyWin')
                    }                
                }
            }
        })        
"@        
    }
}


































if (-not $MonitorMode) {
    $MainBottomTabControl.SelectedTab = $Section3ResultsTab

    # Creates locations to saves the results from jobs
    if (-not (Test-Path "$($script:CollectionSavedDirectoryTextBox.Text)\Results By Endpoints\$($CollectionName)")){
        New-Item -Type Directory "$($script:CollectionSavedDirectoryTextBox.Text)\Results By Endpoints\$($CollectionName)" -Force -ErrorAction SilentlyContinue
    }

    # Initially updates statistics
    $StatisticsResults = Get-PoShEasyWinStatistics
    $StatisticsNumberOfCSVs.text = $StatisticsResults

    $SleepMilliSeconds = 250
    $script:ProgressBarEndpointsProgressBar.Value = 0
    $script:ProgressBarFormProgressBar.Value      = 0

    # Sets the job timeout value, so they don't run forever
    $script:JobsTimer  = [int]$($script:OptionJobTimeoutSelectionComboBox.Text)
    # This is how often the statistics page updates, be default it is 20 which is 5 Seconds (250 ms x 4)
    $StatisticsUpdateInterval      = (1000 / $SleepMilliSeconds) * $OptionStatisticsUpdateIntervalCombobox.text
    $StatisticsUpdateIntervalCount = 0

    # The number of Jobs created by PoSh-EasyWin
    $JobsCount = (Get-Job -Name "PoSh-EasyWin:*").count
    $script:ProgressBarEndpointsProgressBar.Maximum = $JobsCount
    $script:ProgressBarFormProgressBar.Maximum      = $JobsCount

    $Done = 0

    do {
        # Updates Statistics
        $StatisticsUpdateIntervalCount++
        if (($StatisticsUpdateIntervalCount % $StatisticsUpdateInterval) -eq 0) {
            $StatisticsResults = Get-PoShEasyWinStatistics
            $StatisticsNumberOfCSVs.text = $StatisticsResults
        }

        # The number of Jobs created by PoSh-EasyWin
        $CurrentJobs = Get-Job -Name "PoSh-EasyWin:*"

        # Breaks loops if there are not jobs
        if ($CurrentJobs.count -eq 0) {break}



        # Calcualtes and formats time elaspsed
        $CurrentTime = Get-Date
        $Timecount   = $ExecutionStartTime - $CurrentTime
        $Hour        = [Math]::Truncate($Timecount)
        $Minute      = ($CollectionTime - $Hour) * 60
        $Second      = [int](($Minute - ([Math]::Truncate($Minute))) * 60)
        $Minute      = [Math]::Truncate($Minute)
        $Timecount   = [datetime]::Parse("$Hour`:$Minute`:$Second")

        # Provides updates on the jobs
        $ResultsListBox.Items.Insert(0,"Running Jobs:  $($JobsCount - $Done)")
        $ResultsListBox.Items.Insert(1,"Current Time:  $($CurrentTime)")
        $ResultsListBox.Items.Insert(2,"Elasped Time:  $($Timecount -replace '-','')")
        $ResultsListBox.Items.Insert(3,"")

        # From ProgressBar Update (if used)
        $script:ProgressBarMainLabel.text = "Status:
   Running Jobs:  $($JobsCount - $Done)
   Current Time:  $($CurrentTime)
   Elasped Time:  $($Timecount -replace '-','')"

        # This is how often PoSoh-EasyWin's GUI will refresh when provide the status of the jobs
        # Default have is 250 ms. If you change this, be sure to update the $StatisticsUpdateInterval variarible within this function
        Start-Sleep -MilliSeconds $SleepMilliSeconds
        $ResultsListBox.Refresh()

        # Checks if the current job is running too long and stops it
        foreach ($Job in $CurrentJobs) {
            # Gets the results from jobs that are completed, saves them, and deletes the job
            if ( $Job.State -eq 'Completed' ) {
                $Done++
                $script:ProgressBarEndpointsProgressBar.Value = $Done
                $script:ProgressBarFormProgressBar.Value      = $Done

                $JobName     = $Job.Name  -replace 'PoSh-EasyWin: ',''
                $JobReceived = $Job | Receive-Job #-Keep

                if (-not $NotExportFiles) {
                    if ($job.Location -notmatch $(($Job.Name -split ' ')[-1]) ) {
                        if ($SaveProperties) {
                            # This is needed because when jobs are started locally that use invoke-command, the localhost is used as the PSComputerName becuase it started the job rather than the invoke-command to a remote computer
                            $JobReceived | Select-Object @{n='PSComputerName';e={"$(($Job.Name -split ' ')[-1])"}},* -ErrorAction SilentlyContinue | Select-Object $(iex $SaveProperties) | Export-CSV    "$($script:CollectionSavedDirectoryTextBox.Text)\Results By Endpoints\$CollectionName\$JobName.csv" -NoTypeInformation
                            $JobReceived | Select-Object @{n='PSComputerName';e={"$(($Job.Name -split ' ')[-1])"}},* -ErrorAction SilentlyContinue | Select-Object $(iex $SaveProperties) | Export-Clixml "$($script:CollectionSavedDirectoryTextBox.Text)\Results By Endpoints\$CollectionName\$JobName.xml"
                        }
                        else {
                            # This is needed because when jobs are started locally that use inovke-command, the localhost is used as the PSComputerName becuase it started the job rather than the invoke-command to a remote computer
                            $JobReceived | Select-Object @{n='PSComputerName';e={"$(($Job.Name -split ' ')[-1])"}},* -ErrorAction SilentlyContinue | Export-CSV    "$($script:CollectionSavedDirectoryTextBox.Text)\Results By Endpoints\$CollectionName\$JobName.csv" -NoTypeInformation
                            $JobReceived | Select-Object @{n='PSComputerName';e={"$(($Job.Name -split ' ')[-1])"}},* -ErrorAction SilentlyContinue | Export-Clixml "$($script:CollectionSavedDirectoryTextBox.Text)\Results By Endpoints\$CollectionName\$JobName.xml"
                        }
                    }
                    else {
                        if ($SaveProperties) {
                            $JobReceived | Select-Object $(iex $SaveProperties) | Export-CSV    "$($script:CollectionSavedDirectoryTextBox.Text)\Results By Endpoints\$CollectionName\$JobName.csv" -NoTypeInformation
                            $JobReceived | Select-Object $(iex $SaveProperties) | Export-Clixml "$($script:CollectionSavedDirectoryTextBox.Text)\Results By Endpoints\$CollectionName\$JobName.xml"
                        }
                        else {
                            $JobReceived | Export-CSV    "$($script:CollectionSavedDirectoryTextBox.Text)\Results By Endpoints\$CollectionName\$JobName.csv" -NoTypeInformation
                            $JobReceived | Export-Clixml "$($script:CollectionSavedDirectoryTextBox.Text)\Results By Endpoints\$CollectionName\$JobName.xml"
                        }
                    }
                }
                $Job | Remove-Job -Force
            }
            elseif ($CurrentTime -gt ($Job.PSBeginTime).AddSeconds($script:JobsTimer)) {
                $TimeStamp = $($CurrentTime).ToString('yyyy/MM/dd HH:mm:ss')
                $ResultsListBox.Items.insert(5,"$($TimeStamp)   - Job Timed Out: $((($Job | Select-Object -ExpandProperty Name) -split '-')[-1])")
                $Job | Stop-Job
                $Job | Receive-Job -Force
                $Job | Remove-Job -Force
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message " - Job [TIMED OUT]: `"$($Job.Name)`" - Started at $($Job.PSBeginTime) - Ran for $($CurrentTime - $Job.PSBeginTime)"
                break
            }
        }

        $ResultsListBox.Items.RemoveAt(0)
        $ResultsListBox.Items.RemoveAt(0)
        $ResultsListBox.Items.RemoveAt(0)
        $ResultsListBox.Items.RemoveAt(0)
    } while ($Done -lt $JobsCount)

    # Logs Jobs Beginning and Ending Times
    foreach ($Job in $CurrentJobs) {
        if ($($Job.PSEndTime -ne $null)) {
           # $TimeStamp = $(Get-Date).ToString('yyyy/MM/dd HH:mm:ss')
            #$ResultsListBox.Items.insert(1,"$($TimeStamp)   - Job Completed: $((($Job | Select-Object -ExpandProperty Name) -split ' ')[-1])")
            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "$($TimeStamp)  Job [COMPLETED]: `"$($Job.Name)`" - Started at $($Job.PSBeginTime) - Ended at $($Job.PSEndTime)"
        }
    }

    # Updates Statistics One last time
    $StatisticsResults           = Get-PoShEasyWinStatistics
    $StatisticsNumberOfCSVs.text = $StatisticsResults
    Get-Job -Name "PoSh-EasyWin:*" | Remove-Job -Force -ErrorAction SilentlyContinue
    $PoShEasyWin.Refresh()
    Start-Sleep -Seconds 1
}


}

