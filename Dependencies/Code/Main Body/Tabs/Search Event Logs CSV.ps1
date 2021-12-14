
$Section1EventLogsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = "Event IDs  "
    Left   = $FormScale * -1
    Top    = $FormScale * $Column1DownPosition
    Width  = $FormScale * $Column1BoxWidth
    Height = $FormScale * $Column1BoxHeight
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
    ImageIndex = 2
}
$MainLeftSearchTabControl.Controls.Add($Section1EventLogsTab)


$EventLogsOptionsGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
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


            $EventLogWinRMRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text   = "WinRM"
                Left   = $FormScale * 80
                Top    = $FormScale * 15
                Width  = $FormScale * 80
                Height = $FormScale * 20
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


            $EventLogRPCRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text   = "RPC"
                Left   = $EventLogWinRMRadioButton.Left + $EventLogWinRMRadioButton.Width + $($FormScale * 10)
                Top    = $EventLogWinRMRadioButton.Top
                Width  = $FormScale * 60
                Height = $FormScale * 20
                Checked   = $False
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
                Add_Click = {
                    if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Session Based') {
                        $MessageBox = [System.Windows.Forms.MessageBox]::Show("The '$($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem)' mode does not support the RPC and SMB protocols.`nThe 'Monitor Jobs' mode supports the RPC, SMB, and WinRM protocols - but may be slower and noisier on the network.`n`nDo you want to change the collection mode to 'Monitor Jobs'?","Protocol Alert",[System.Windows.Forms.MessageBoxButtons]::OKCancel)
                        switch ($MessageBox){
                            "OK" {
                                # This brings specific tabs to the forefront/front view
                                $MainLeftTabControl.SelectedTab   = $Section1SearchTab
                                $InformationTabControl.SelectedTab = $Section3ResultsTab

                                $StatusListBox.Items.Clear()
                                $StatusListBox.Items.Add("Collection Mode Changed to: Individual Execution")
                                #Removed For Testing#$ResultsListBox.Items.Clear()
                                $ResultsListBox.Items.Add("The collection mode '$($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem)' does not support the RPC and SMB protocols and has been changed to")
                                $ResultsListBox.Items.Add("'Monitor Jobs' which supports RPC, SMB, and WinRM - but may be slower and noisier on the network.")
                                $script:CommandTreeViewQueryMethodSelectionComboBox.SelectedIndex = 0
                                $EventLogRPCRadioButton.checked         = $true
                                $ExternalProgramsRPCRadioButton.checked = $true
                            }
                            "Cancel" {
                                $StatusListBox.Items.Clear()
                                $StatusListBox.Items.Add("$($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem) does not support RPC")
                                $EventLogWinRMRadioButton.checked         = $true
                                $ExternalProgramsWinRMRadioButton.checked = $true
                            }
                        }
                    }
                    else {
                        $ExternalProgramsRPCRadioButton.checked = $true
                    }
                }
                Add_MouseHover = {
                    Show-ToolTip -Title "RPC" -Icon "Info" -Message @"
+  Get-WmiObject -Class Win32_NTLogEvent -Filter "(((EventCode='4624') OR (EventCode='4634')) and `
 (TimeGenerated>='$([System.Management.ManagementDateTimeConverter]::ToDmtfDateTime(($script:EventLogsStartTimePicker.Value)))') and (TimeGenerated<='20190314180030.000000-300'))"
"@
                }
            }


            $EventLogsMaximumCollectionLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Max Collection:"
                Left   = $EventLogRPCRadioButton.Left + $EventLogRPCRadioButton.Width + $($FormScale * 35)
                Top    = $EventLogRPCRadioButton.Top + $($FormScale * 3)
                Width  = $FormScale * 100
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
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


            $script:EventLogsMaximumCollectionTextBox = New-Object System.Windows.Forms.TextBox -Property @{
                Text   = 100
                Left   = $EventLogsMaximumCollectionLabel.Left + $EventLogsMaximumCollectionLabel.Width
                Top    = $EventLogsMaximumCollectionLabel.Top - $($FormScale * 3)
                Width  = $FormScale * 50
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                Enabled  = $True
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


            $EventLogsDatetimeStartLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "DateTime Start:"
                Left   = $FormScale * 77
                Top    = $EventLogProtocolRadioButtonLabel.Top + $EventLogProtocolRadioButtonLabel.Height + $($FormScale * 5)
                Width  = $FormScale * 90
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
            }


            $script:EventLogsStartTimePicker = New-Object System.Windows.Forms.DateTimePicker -Property @{
                Left         = $EventLogsDatetimeStartLabel.Left + $EventLogsDatetimeStartLabel.Width
                Top          = $EventLogProtocolRadioButtonLabel.Top + $EventLogProtocolRadioButtonLabel.Height
                Width        = $FormScale * 250
                Height       = $FormScale * 100
                Font         = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                Format       = [windows.forms.datetimepickerFormat]::custom
                CustomFormat = "dddd MMM dd, yyyy hh:mm tt"
                Enabled      = $True
                Checked      = $True
                ShowCheckBox = $True
                ShowUpDown   = $False
                AutoSize     = $true
                #MinDate      = (Get-Date -Month 1 -Day 1 -Year 2000).DateTime
                #MaxDate      = (Get-Date).DateTime
                Value         = (Get-Date).AddDays(-1).DateTime
                Add_Click = {
                    if ($script:EventLogsStopTimePicker.checked -eq $false) {
                        $script:EventLogsStopTimePicker.checked = $true
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
            # [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime(($script:EventLogsStartTimePicker.Value))


            $EventLogsDatetimeStopLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "DateTime Stop:"
                Left   = $EventLogsDatetimeStartLabel.Left
                Top    = $EventLogsDatetimeStartLabel.Top + $EventLogsDatetimeStartLabel.Height
                Width  = $EventLogsDatetimeStartLabel.Width
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
            }


            $script:EventLogsStopTimePicker = New-Object System.Windows.Forms.DateTimePicker -Property @{
                Left         = $EventLogsDatetimeStopLabel.Left + $EventLogsDatetimeStopLabel.Width
                Top          = $EventLogsDatetimeStartLabel.Top + $EventLogsDatetimeStartLabel.Height - $($FormScale * 5)
                Width        = $script:EventLogsStartTimePicker.Width
                Height       = $FormScale * 100
                Font         = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                Format       = [windows.forms.datetimepickerFormat]::custom
                CustomFormat = "dddd MMM dd, yyyy hh:mm tt"
                Enabled      = $True
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
            $EventLogsOptionsGroupBox.Controls.AddRange(@($EventLogProtocolRadioButtonLabel,$EventLogRPCRadioButton,$EventLogWinRMRadioButton,$EventLogsDatetimeStartLabel,$script:EventLogsStartTimePicker,$EventLogsDatetimeStopLabel,$script:EventLogsStopTimePicker,$EventLogsMaximumCollectionLabel,$script:EventLogsMaximumCollectionTextBox))
$Section1EventLogsTab.Controls.Add($EventLogsOptionsGroupBox)


#============================================================================================================================================================
# Event Logs - Event IDs Manual Entry
#============================================================================================================================================================

$EventLogsEventIDsManualEntryCheckbox  = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Event IDs Search (WinRM)"
    Left   = $FormScale * 7
    Top    = $EventLogsOptionsGroupBox.Top + $EventLogsOptionsGroupBox.Height + $($FormScale * 5)
    Width  = $FormScale * 200
    Height = $FormScale * 20
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        Update-QueryCount
        
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1EventLogsTab.Controls.Add($EventLogsEventIDsManualEntryCheckbox)


$EventLogsEventIDsManualEntryLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Enter Event IDs; One Per Line"
    Left   = $FormScale * 5
    Top    = $EventLogsEventIDsManualEntryCheckbox.Top + $EventLogsEventIDsManualEntryCheckbox.Height
    Width  = $FormScale * 200
    Height = $FormScale * 20
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = "Black"
}
$Section1EventLogsTab.Controls.Add($EventLogsEventIDsManualEntryLabel)


$EventLogsEventIDsManualEntrySelectionButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Select Event IDs"
    Left   = $FormScale * 4
    Top    = $EventLogsEventIDsManualEntryLabel.Top + $EventLogsEventIDsManualEntryLabel.Height
    Width  = $FormScale * 125
    Height = $FormScale * 20
    Add_Click = {
        Import-Csv $EventIDsFile | Out-GridView  -Title 'Windows Event IDs' -OutputMode Multiple | Set-Variable -Name EventCodeManualEntrySelectionContents
        $EventIDColumn = $EventCodeManualEntrySelectionContents | Select-Object -ExpandProperty "Event ID"
        Foreach ($EventID in $EventIDColumn) {
            $EventLogsEventIDsManualEntryTextbox.Text += "$EventID`r`n"
        }
    }
}
$Section1EventLogsTab.Controls.Add($EventLogsEventIDsManualEntrySelectionButton)
Apply-CommonButtonSettings -Button $EventLogsEventIDsManualEntrySelectionButton


$EventLogsEventIDsManualEntryClearButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Clear"
    Left   = $FormScale * 136
    Top    = $EventLogsEventIDsManualEntryLabel.Top + $EventLogsEventIDsManualEntryLabel.Height
    Width  = $FormScale * 75
    Height = $FormScale * 20
    Add_Click = { $EventLogsEventIDsManualEntryTextbox.Text = "" }
}
$Section1EventLogsTab.Controls.Add($EventLogsEventIDsManualEntryClearButton)
Apply-CommonButtonSettings -Button $EventLogsEventIDsManualEntryClearButton


$EventLogsEventIDsManualEntryTextbox = New-Object System.Windows.Forms.TextBox -Property @{
    Lines  = $null
    Left   = $FormScale * 5
    Top    = $EventLogsEventIDsManualEntryClearButton.Top + $EventLogsEventIDsManualEntryClearButton.Height + $($FormScale * 5)
    Width  = $FormScale * 205
    Height = $FormScale * 341
    MultiLine     = $True
    WordWrap      = $True
    AcceptsTab    = $false
    AcceptsReturn = $false
    ScrollBars    = "Vertical"
    Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section1EventLogsTab.Controls.Add($EventLogsEventIDsManualEntryTextbox)

# Imports code that populates the Event IDs Quick Pick Selection,
# esentially tying a single name/selection to multiple predetermined Event IDs
Update-FormProgress "$Dependencies\Code\Main Body\Populate-EventLogsEventIDQuickPick.ps1"
. "$Dependencies\Code\Main Body\Populate-EventLogsEventIDQuickPick.ps1"


$EventLogsQuickPickSelectionCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Quick Selection (WinRM)"
    Left   = $FormScale * 220
    Top    = $EventLogsEventIDsManualEntryCheckbox.Top
    Width  = $FormScale * 200
    Height = $FormScale * 20
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Checked = $false
    Enabled = $false
    Add_Click = {
        if ($this.Checked -and $this.enabled -and $EventLogsQuickPickSelectionCheckedListBox.CheckedItems.count -gt 0) {
            $script:SectionQueryCount += $EventLogsQuickPickSelectionCheckedlistbox.CheckedItems.count
            $EventLogsQuickPickSelectionCheckedListBox.Enabled = $false
            $EventLogsQuickPickSelectionSelectAllButton.Enabled = $false
            $EventLogsQuickPickSelectionClearButton.Enabled = $false
        }
        else {
            $script:SectionQueryCount -= $EventLogsQuickPickSelectionCheckedlistbox.CheckedItems.count
            $EventLogsQuickPickSelectionCheckedListBox.Enabled = $true
            $EventLogsQuickPickSelectionSelectAllButton.Enabled = $true
            $EventLogsQuickPickSelectionClearButton.Enabled = $true
        }

        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1EventLogsTab.Controls.Add( $EventLogsQuickPickSelectionCheckbox )


$EventLogsQuickPickSelectionLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Event IDs by Topic - Can Select Multiple"
    Left   = $FormScale * 218
    Top    = $EventLogsQuickPickSelectionCheckbox.Top + $EventLogsQuickPickSelectionCheckbox.Height
    Width  = $FormScale * 410
    Height = $FormScale * 20
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = "Black"
}
$Section1EventLogsTab.Controls.Add($EventLogsQuickPickSelectionLabel)


$EventLogsQuickPickSelectionClearButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Clear"
    Left   = $FormScale * 356
    Top    = $EventLogsQuickPickSelectionLabel.Top + $EventLogsQuickPickSelectionLabel.Height
    Width  = $FormScale * 75
    Height = $FormScale * 20
    Add_Click = {
        # Clears the commands selected
        For ($i=0;$i -lt $EventLogsQuickPickSelectionCheckedlistbox.Items.count;$i++) {
            $EventLogsQuickPickSelectionCheckedlistbox.SetSelected($i,$False)
            $EventLogsQuickPickSelectionCheckedlistbox.SetItemChecked($i,$False)
            $EventLogsQuickPickSelectionCheckedlistbox.SetItemCheckState($i,$False)
        }
    }
}
$Section1EventLogsTab.Controls.Add($EventLogsQuickPickSelectionClearButton)
Apply-CommonButtonSettings -Button $EventLogsQuickPickSelectionClearButton


$EventLogsQuickPickSelectionSelectAllButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Select All"
    Left   = $EventLogsQuickPickSelectionClearButton.Left - $EventLogsQuickPickSelectionClearButton.Width - $($FormScale + 10)
    Top    = $EventLogsQuickPickSelectionClearButton.Top
    Width  = $FormScale * 75
    Height = $FormScale * 20
    Add_Click = { For ($i=0;$i -lt $EventLogsQuickPickSelectionCheckedlistbox.Items.count;$i++) { $EventLogsQuickPickSelectionCheckedlistbox.SetItemChecked($i,$true) } }
}
$Section1EventLogsTab.Controls.Add($EventLogsQuickPickSelectionSelectAllButton)
Apply-CommonButtonSettings -Button $EventLogsQuickPickSelectionSelectAllButton


$EventLogsQuickPickSelectionCheckboxUpdate = {
    if ($EventLogsQuickPickSelectionCheckedListBox.CheckedItems.count -gt 0) {
        $EventLogsQuickPickSelectionCheckbox.enabled = $true
    }
    else {
        $EventLogsQuickPickSelectionCheckbox.enabled = $false
        $EventLogsQuickPickSelectionCheckbox.checked = $false
    }

}
$EventLogsQuickPickSelectionCheckedListBox = New-Object -TypeName System.Windows.Forms.CheckedListBox -Property @{
    Name   = "Event Logs Selection"
    Text   = "Event Logs Selection"
    Left   = $FormScale * 220
    Top    = $EventLogsQuickPickSelectionClearButton.Top + $EventLogsQuickPickSelectionClearButton.Height + $($FormScale * 5)
    Width  = $FormScale * 210
    Height = $FormScale * 350
    ScrollAlwaysVisible = $true
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = 'Blue'
    Add_MouseHover = $EventLogsQuickPickSelectionCheckboxUpdate
    Add_MouseEnter = $EventLogsQuickPickSelectionCheckboxUpdate
    Add_MouseLeave = $EventLogsQuickPickSelectionCheckboxUpdate
    Add_Click = {
        & $EventLogsQuickPickSelectionCheckboxUpdate
        $InformationTabControl.SelectedTab = $Section3ResultsTab
        foreach ( $Query in $script:EventLogQueries ) {
            If ( $Query.Name -imatch $EventLogsQuickPickSelectionCheckedListBox.SelectedItem ) {
                $ResultsListBox.Items.Clear()
                $CommandFileNotes = Get-Content -Path $Query.FilePath
                foreach ($line in $CommandFileNotes) {$ResultsListBox.Items.Add("$line")}
            }
        }    
    }
}
foreach ( $Query in $script:EventLogQueries ) { $EventLogsQuickPickSelectionCheckedListBox.Items.Add("$($Query.Name)") }
$Section1EventLogsTab.Controls.Add($EventLogsQuickPickSelectionCheckedListBox)


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUH2av2rR83FOswM5castOwgnM
# /xWgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU+tLi4bKYndybeejtTPqKbNYCTwwwDQYJKoZI
# hvcNAQEBBQAEggEATFOLb5DfCFzeDKNOH9q8TXkzwSAOeFFZ5/0s5Np5RVSF+LOo
# aG14h3Wg2tOcoIzYkTDYR5uum3HAraOKnjCjh2e7zK1pi9RT5m6/pyk+OqJUqYu6
# f1tAJcl9yxim0h5lYnpNfTHoMAzt/0ZKQK35sdRPx98f1FEpg7Y5HCZ3Y9uHhvFC
# KSiE1pqsKlixs17K3GGUpAE5OI1Apf6UPWZxQYhnnTHaw9Oi6xP0DCA/yKGO+faP
# i76LxUBMF2J74EdZ2fO0Zof0MF17yecbgQqaDsjP8BujHOl2RjS3rHwFlPRaTnwk
# uQ+ORGhpDilYhMEJMLAfNoAh7v0SHKxEXLh7Mg==
# SIG # End signature block
