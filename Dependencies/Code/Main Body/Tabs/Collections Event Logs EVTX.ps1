$Section1EventLogNameEVTXTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = "Event Logs"
    Left   = $FormScale * $Column1RightPosition
    Top    = $FormScale * $Column1DownPosition
    Width  = $FormScale * $Column1BoxWidth
    Height = $FormScale * $Column1BoxHeight
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
    ImageIndex = 8
}
$MainLeftCollectionsTabControl.Controls.Add($Section1EventLogNameEVTXTab)


$EventLogNameEVTXOptionsGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text   = "Collection Options"
    Left   = $FormScale * 5
    Top    = $FormScale * 5
    Width  = $FormScale * 425
    Height = $FormScale * 94
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
}
            $EventLogProtocolRadioButtonLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Protocol:"
                Left   = $FormScale * 7
                Top    = $FormScale * 20
                Width  = $FormScale * 73
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
            }


            $EventLogNameEVTXWinRMRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text   = "WinRM"
                Left   = $FormScale * 80
                Top    = $FormScale * 15
                Width  = $FormScale * 80
                Height = $FormScale * 22
                Checked   = $True
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
                Add_Click = {
                    $ExternalProgramsWinRMRadioButton.checked = $true
                }
                Add_MouseHover = {
                    Show-ToolTip -Title "WinRM" -Icon "Info" -Message @"
+  Invoke-Command -ComputerName <Endpoint> -ScriptBlock {
Get-WmiObject -Class Win32_NTLogEvent -Filter "(((EventCode='4624') OR (EventCode='4634')) and `
(TimeGenerated>='20190313180030.000000-300') and (TimeGenerated<='20190314180030.000000-300')) }"
"@
                }
            }


            $EventLogNameEVTXRPCRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text   = "RPC"
                Left   = $EventLogNameEVTXWinRMRadioButton.Left + $EventLogNameEVTXWinRMRadioButton.Width + $($FormScale * 10)
                Top    = $EventLogNameEVTXWinRMRadioButton.Top
                Width  = $FormScale * 60
                Height = $FormScale * 22
                Checked = $False
                Font    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                Enabled = $false
                ForeColor = 'Black'
                Add_Click = {}
                Add_MouseHover = {
                    Show-ToolTip -Title "RPC" -Icon "Info" -Message @"
+  Get-WmiObject -Class Win32_NTLogEvent -Filter "(((EventCode='4624') OR (EventCode='4634')) and `
 (TimeGenerated>='$([System.Management.ManagementDateTimeConverter]::ToDmtfDateTime(($script:EventLogNameEVTXStartTimePicker.Value)))') and (TimeGenerated<='20190314180030.000000-300'))"
"@
}
            }


            $EventLogNameEVTXMaximumCollectionLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Max Collection:"
                Left   = $EventLogNameEVTXRPCRadioButton.Left + $EventLogNameEVTXRPCRadioButton.Width + $($FormScale * 35)
                Top    = $EventLogNameEVTXRPCRadioButton.Top + $($FormScale * 3)
                Width  = $FormScale * 100
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
                Enabled = $false
                Add_MouseHover = {
                    Show-ToolTip -Title "Max Collection" -Icon "Info" -Message @"
+  Enter the maximum number of Event Logs to return
+  This can be used with the datatime picker
+  If left blank, it will collect all available Event Logs
+  An entry of 0 (zero) will return no Event Logs

+  This only applies to PowerShell object data retireved, not .evtx files
"@
}
            }


            $script:EventLogNameEVTXMaximumCollectionTextBox = New-Object System.Windows.Forms.TextBox -Property @{
                Text   = 100
                Left   = $EventLogNameEVTXMaximumCollectionLabel.Left + $EventLogNameEVTXMaximumCollectionLabel.Width
                Top    = $EventLogNameEVTXMaximumCollectionLabel.Top - $($FormScale * 3)
                Width  = $FormScale * 50
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                Enabled  = $false
                Scrollbars = "Vertical"
                Add_MouseHover = {
                    Show-ToolTip -Title "Max Collection" -Icon "Info" -Message @"
+  Enter the maximum number of Event Logs to return
+  This can be used with the datatime picker
+  If left blank, it will collect all available Event Logs
+  An entry of 0 (zero) will return no Event Logs

+  This only applies to PowerShell object data retireved, not .evtx files
"@
}
            }


            $EventLogNameEVTXDatetimeStartLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "DateTime Start:"
                Left   = $FormScale * 77
                Top    = $EventLogProtocolRadioButtonLabel.Top + $EventLogProtocolRadioButtonLabel.Height + $($FormScale * 5)
                Width  = $FormScale * 90
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
            }


            $script:EventLogNameEVTXStartTimePicker = New-Object System.Windows.Forms.DateTimePicker -Property @{
                Left         = $EventLogNameEVTXDatetimeStartLabel.Left + $EventLogNameEVTXDatetimeStartLabel.Width
                Top          = $EventLogProtocolRadioButtonLabel.Top + $EventLogProtocolRadioButtonLabel.Height
                Width        = $FormScale * 250
                Height       = $FormScale * 100
                Font         = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                Format       = [windows.forms.datetimepickerFormat]::custom
                CustomFormat = "dddd MMM dd, yyyy hh:mm tt"
                Enabled      = $false
                Checked      = $True
                ShowCheckBox = $True
                ShowUpDown   = $False
                AutoSize     = $true
                #MinDate      = (Get-Date -Month 1 -Day 1 -Year 2000).DateTime
                #MaxDate      = (Get-Date).DateTime
                Value         = (Get-Date).AddDays(-1).DateTime
                Add_Click = {
                    if ($script:EventLogNameEVTXStopTimePicker.checked -eq $false) {
                        $script:EventLogNameEVTXStopTimePicker.checked = $true
                    }
                }
                Add_MouseHover = {
                    Show-ToolTip -Title "DateTime - Starting" -Icon "Info" -Message @"
+  Select the starting datetime to filter Event Logs
+  This can be used with the Max Collection field
+  If left blank, it will collect all available Event Logs
+  If used, you must select both a start and end datetime
"@
}
            }
            # Wednesday, June 5, 2019 10:27:40 PM
            # $TimePicker.Value
            # 20190605162740.383143-240
            # [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime(($script:EventLogNameEVTXStartTimePicker.Value))


            $EventLogNameEVTXDatetimeStopLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "DateTime Stop:"
                Left   = $EventLogNameEVTXDatetimeStartLabel.Left
                Top    = $EventLogNameEVTXDatetimeStartLabel.Top + $EventLogNameEVTXDatetimeStartLabel.Height
                Width  = $EventLogNameEVTXDatetimeStartLabel.Width
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
            }


            $script:EventLogNameEVTXStopTimePicker = New-Object System.Windows.Forms.DateTimePicker -Property @{
                Left         = $EventLogNameEVTXDatetimeStopLabel.Left + $EventLogNameEVTXDatetimeStopLabel.Width
                Top          = $EventLogNameEVTXDatetimeStartLabel.Top + $EventLogNameEVTXDatetimeStartLabel.Height - $($FormScale * 5)
                Width        = $script:EventLogNameEVTXStartTimePicker.Width
                Height       = $FormScale * 100
                Font         = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                Format       = [windows.forms.datetimepickerFormat]::custom
                CustomFormat = "dddd MMM dd, yyyy hh:mm tt"
                Enabled      = $false
                Checked      = $True
                ShowCheckBox = $True
                ShowUpDown   = $False
                AutoSize     = $true
                #MinDate      = (Get-Date -Month 1 -Day 1 -Year 2000).DateTime
                #MaxDate      = (Get-Date).DateTime
                Add_MouseHover = {
                    Show-ToolTip -Title "DateTime - Ending" -Icon "Info" -Message @"
+  Select the ending datetime to filter Event Logs
+  This can be used with the Max Collection field
+  If left blank, it will collect all available Event Logs
+  If used, you must select both a start and end datetime
"@
}
            }
            $EventLogNameEVTXOptionsGroupBox.Controls.AddRange(@($EventLogProtocolRadioButtonLabel,$EventLogNameEVTXRPCRadioButton,$EventLogNameEVTXWinRMRadioButton,$EventLogNameEVTXDatetimeStartLabel,$script:EventLogNameEVTXStartTimePicker,$EventLogNameEVTXDatetimeStopLabel,$script:EventLogNameEVTXStopTimePicker,$EventLogNameEVTXMaximumCollectionLabel,$script:EventLogNameEVTXMaximumCollectionTextBox))
$Section1EventLogNameEVTXTab.Controls.Add($EventLogNameEVTXOptionsGroupBox)

#============================================================================================================================================================
# Event Logs - Event Log Names
#============================================================================================================================================================

$EventLogNameEVTXLogNameSelectionCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Log Name Selection (ChainSaw Integration Under Development)"
    Left   = $FormScale * 7
    Top    = $EventLogNameEVTXOptionsGroupBox.Top + $EventLogNameEVTXOptionsGroupBox.Height + $($FormScale * 5)
    Width  = $FormScale * 400
    Height = $FormScale * 22
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Checked = $false
    Enabled = $false
    Add_Click = {
        if ($this.Checked -and $this.enabled) {
            $script:SectionQueryCount++
        }
        else {
            $script:SectionQueryCount--
        }        
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1EventLogNameEVTXTab.Controls.Add( $EventLogNameEVTXLogNameSelectionCheckbox )


$EventLogNameEVTXLogNameSelectionComboBox = New-Object -TypeName System.Windows.Forms.ComboBox -Property @{
    Text   = "Event Log Selection"
    Left   = $EventLogNameEVTXLogNameSelectionCheckbox.Left
    Top    = $EventLogNameEVTXLogNameSelectionCheckbox.Top + $EventLogNameEVTXLogNameSelectionCheckbox.Height + $($FormScale * 5)
    Width  = $FormScale * 250
    Height = $FormScale * 350
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = 'Blue'
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"    
    Add_Click = {
        $InformationTabControl.SelectedTab = $Section3ResultsTab
    }
    Add_SelectedIndexChanged = {
        if ($EventLogNameEVTXLogNameSelectionComboBox.Text -eq 'Event Logs Selection') {
            $EventLogNameEVTXLogNameSelectionCheckbox.Checked = $False
            $EventLogNameEVTXLogNameSelectionCheckbox.Enabled = $false
        }
        elseif ($EventLogNameEVTXLogNameSelectionComboBox.Text -ne 'Event Logs Selection') {
            $EventLogNameEVTXLogNameSelectionCheckbox.Enabled = $true
        }

        # [System.Windows.Forms.MessageBox]::Show("Invalid Event Log Entry.","PoSh-EasyWin",'Ok',"Info")
    }
}

$EventLogNames = Import-Csv "$Dependencies\Event Log Info\Event Log Names.csv"

foreach ( $Query in $EventLogNames ) { $EventLogNameEVTXLogNameSelectionComboBox.Items.Add("$($Query.LogName)") }
$Section1EventLogNameEVTXTab.Controls.Add($EventLogNameEVTXLogNameSelectionComboBox)


$EventLogNameEVTXEventIDsManualEntryLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "The default action is to get all Event IDs associated with the log name.`nThe following list box filters in those entered and excludes all others."
    Left   = $EventLogNameEVTXLogNameSelectionComboBox.Left
    Top    = $EventLogNameEVTXLogNameSelectionComboBox.Top + $EventLogNameEVTXLogNameSelectionComboBox.Height + ($FormScale * 5)
    Width  = $FormScale * 410
    Height = $FormScale * 30
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = "Black"
}
$Section1EventLogNameEVTXTab.Controls.Add($EventLogNameEVTXEventIDsManualEntryLabel)


$EventLogNameEVTXEventIDsManualEntrySelectionButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Select Event IDs to Filter"
    Left   = $EventLogNameEVTXEventIDsManualEntryLabel.Left
    Top    = $EventLogNameEVTXEventIDsManualEntryLabel.Top + $EventLogNameEVTXEventIDsManualEntryLabel.Height
    Width  = $FormScale * 170
    Height = $FormScale * 20
    Enabled = $false
    Add_Click = {
        Import-Csv $EventIDsFile | Out-GridView  -Title 'Windows Event IDs' -OutputMode Multiple | Set-Variable -Name EventCodeManualEntrySelectionContents
        $EventIDColumn = $EventCodeManualEntrySelectionContents | Select-Object -ExpandProperty "Event ID"
        Foreach ($EventID in $EventIDColumn) {
            $EventLogNameEVTXEventIDsManualEntryTextbox.Text += "$EventID`r`n"
        }
    }
}
$Section1EventLogNameEVTXTab.Controls.Add($EventLogNameEVTXEventIDsManualEntrySelectionButton)
Apply-CommonButtonSettings -Button $EventLogNameEVTXEventIDsManualEntrySelectionButton


$EventLogNameEVTXEventIDsManualEntryClearButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Clear"
    Left   = $EventLogNameEVTXEventIDsManualEntrySelectionButton.Left + $EventLogNameEVTXEventIDsManualEntrySelectionButton.Width + ($FormScale * 5)
    Top    = $EventLogNameEVTXEventIDsManualEntryLabel.Top + $EventLogNameEVTXEventIDsManualEntryLabel.Height
    Width  = $FormScale * 75
    Height = $FormScale * 20
    Add_Click = { $EventLogNameEVTXEventIDsManualEntryTextbox.Text = "" }
    enabled = $false
}
$Section1EventLogNameEVTXTab.Controls.Add($EventLogNameEVTXEventIDsManualEntryClearButton)
Apply-CommonButtonSettings -Button $EventLogNameEVTXEventIDsManualEntryClearButton


$EventLogNameEVTXEventIDsManualEntryTextbox = New-Object System.Windows.Forms.TextBox -Property @{
    Lines  = $null
    Left   = $EventLogNameEVTXEventIDsManualEntryLabel.Left
    Top    = $EventLogNameEVTXEventIDsManualEntryClearButton.Top + $EventLogNameEVTXEventIDsManualEntryClearButton.Height + $($FormScale * 5)
    Width  = $FormScale * 250
    Height = $FormScale * 300
    Enabled = $false
    MultiLine     = $True
    WordWrap      = $True
    AcceptsTab    = $false
    AcceptsReturn = $false
    ScrollBars    = "Vertical"
    Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section1EventLogNameEVTXTab.Controls.Add($EventLogNameEVTXEventIDsManualEntryTextbox)


