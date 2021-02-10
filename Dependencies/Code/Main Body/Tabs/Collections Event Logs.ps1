
$Section1EventLogsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = "Event Logs"
    Left   = $FormScale * $Column1RightPosition
    Top    = $FormScale * $Column1DownPosition
    Width  = $FormScale * $Column1BoxWidth
    Height = $FormScale * $Column1BoxHeight
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
}
$MainLeftCollectionsTabControl.Controls.Add($Section1EventLogsTab)


$EventLogsMainLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Event Logs can be obtained from workstations and servers."
    Left   = $FormScale * 5
    Top    = $FormScale * 5
    Width  = $FormScale * 410
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Black"
}
$Section1EventLogsTab.Controls.Add($EventLogsMainLabel)


$EventLogsOptionsGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text   = "Collection Options"
    Left   = $FormScale * 5
    Top    = $EventLogsMainLabel.Top + $EventLogsMainLabel.Height
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


            Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RadioButton\EventLogWinRMRadioButton.ps1"
            . "$Dependencies\Code\System.Windows.Forms\RadioButton\EventLogWinRMRadioButton.ps1"
            $EventLogWinRMRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text   = "WinRM"
                Left   = $FormScale * 80
                Top    = $FormScale * 15
                Width  = $FormScale * 80
                Height = $FormScale * 22
                Checked   = $True
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
                Add_Click      = $EventLogWinRMRadioButtonAdd_Click
                Add_MouseHover = $EventLogWinRMRadioButtonAdd_MouseHover
            }


            Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RadioButton\EventLogRPCRadioButton.ps1"
            . "$Dependencies\Code\System.Windows.Forms\RadioButton\EventLogRPCRadioButton.ps1"
            $EventLogRPCRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text   = "RPC"
                Left   = $EventLogWinRMRadioButton.Left + $EventLogWinRMRadioButton.Width + $($FormScale * 10)
                Top    = $EventLogWinRMRadioButton.Top
                Width  = $FormScale * 60
                Height = $FormScale * 22
                Checked   = $False
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
                Add_Click      = $EventLogRPCRadioButtonAdd_Click
                Add_MouseHover = $EventLogRPCRadioButtonAdd_MouseHover
            }


            Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Label\EventLogsMaximumCollectionLabel.ps1"
            . "$Dependencies\Code\System.Windows.Forms\Label\EventLogsMaximumCollectionLabel.ps1"
            $EventLogsMaximumCollectionLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Max Collection:"
                Left   = $EventLogRPCRadioButton.Left + $EventLogRPCRadioButton.Width + $($FormScale * 35)
                Top    = $EventLogRPCRadioButton.Top + $($FormScale * 3)
                Width  = $FormScale * 100
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
                Add_MouseHover = $EventLogsMaximumCollectionLabelAdd_MouseHover
            }


            Update-FormProgress "$Dependencies\Code\System.Windows.Forms\TextBox\EventLogsMaximumCollectionTextBox.ps1"
            . "$Dependencies\Code\System.Windows.Forms\TextBox\EventLogsMaximumCollectionTextBox.ps1"
            $script:EventLogsMaximumCollectionTextBox = New-Object System.Windows.Forms.TextBox -Property @{
                Text   = 100
                Left   = $EventLogsMaximumCollectionLabel.Left + $EventLogsMaximumCollectionLabel.Width
                Top    = $EventLogsMaximumCollectionLabel.Top - $($FormScale * 3)
                Width  = $FormScale * 50
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                Enabled  = $True
                Add_MouseHover = $script:EventLogsMaximumCollectionTextBoxAdd_MouseHover
            }


            $EventLogsDatetimeStartLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "DateTime Start:"
                Left   = $FormScale * 77
                Top    = $EventLogProtocolRadioButtonLabel.Top + $EventLogProtocolRadioButtonLabel.Height + $($FormScale * 5)
                Width  = $FormScale * 90
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
            }


            Update-FormProgress "$Dependencies\Code\System.Windows.Forms\DateTimePicker\EventLogsStartTimePicker.ps1"
            . "$Dependencies\Code\System.Windows.Forms\DateTimePicker\EventLogsStartTimePicker.ps1"
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
                Add_Click      = $script:EventLogsStartTimePickerAdd_Click
                Add_MouseHover = $script:EventLogsStartTimePickerAdd_MouseHover
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
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
            }


            Update-FormProgress "$Dependencies\Code\System.Windows.Forms\DateTimePicker\EventLogsStopTimePicker.ps1"
            . "$Dependencies\Code\System.Windows.Forms\DateTimePicker\EventLogsStopTimePicker.ps1"
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
                Add_MouseHover = $script:EventLogsStartTimePickerAdd_MouseHover
            }
            $EventLogsOptionsGroupBox.Controls.AddRange(@($EventLogProtocolRadioButtonLabel,$EventLogRPCRadioButton,$EventLogWinRMRadioButton,$EventLogsDatetimeStartLabel,$script:EventLogsStartTimePicker,$EventLogsDatetimeStopLabel,$script:EventLogsStopTimePicker,$EventLogsMaximumCollectionLabel,$script:EventLogsMaximumCollectionTextBox))
$Section1EventLogsTab.Controls.Add($EventLogsOptionsGroupBox)


#============================================================================================================================================================
# Event Logs - Event IDs Manual Entry
#============================================================================================================================================================

$EventLogsEventIDsManualEntryCheckbox  = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Event IDs Manual Entry"
    Left   = $FormScale * 7
    Top    = $EventLogsOptionsGroupBox.Top + $EventLogsOptionsGroupBox.Height + $($FormScale * 10)
    Width  = $FormScale * 200
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
}
$Section1EventLogsTab.Controls.Add($EventLogsEventIDsManualEntryCheckbox)


$EventLogsEventIDsManualEntryLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Enter Event IDs; One Per Line"
    Left   = $FormScale * 5
    Top    = $EventLogsEventIDsManualEntryCheckbox.Top + $EventLogsEventIDsManualEntryCheckbox.Height
    Width  = $FormScale * 200
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = "Black"
}
$Section1EventLogsTab.Controls.Add($EventLogsEventIDsManualEntryLabel)


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\EventLogsEventIDsManualEntrySelectionButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\EventLogsEventIDsManualEntrySelectionButton.ps1"
$EventLogsEventIDsManualEntrySelectionButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Select Event IDs"
    Left   = $FormScale * 4
    Top    = $EventLogsEventIDsManualEntryLabel.Top + $EventLogsEventIDsManualEntryLabel.Height
    Width  = $FormScale * 125
    Height = $FormScale * 20
    Add_Click = $EventLogsEventIDsManualEntrySelectionButtonAdd_Click
}
$Section1EventLogsTab.Controls.Add($EventLogsEventIDsManualEntrySelectionButton)
CommonButtonSettings -Button $EventLogsEventIDsManualEntrySelectionButton


$EventLogsEventIDsManualEntryClearButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Clear"
    Left   = $FormScale * 136
    Top    = $EventLogsEventIDsManualEntryLabel.Top + $EventLogsEventIDsManualEntryLabel.Height
    Width  = $FormScale * 75
    Height = $FormScale * 20
    Add_Click = { $EventLogsEventIDsManualEntryTextbox.Text = "" }
}
$Section1EventLogsTab.Controls.Add($EventLogsEventIDsManualEntryClearButton)
CommonButtonSettings -Button $EventLogsEventIDsManualEntryClearButton


$EventLogsEventIDsManualEntryTextbox = New-Object System.Windows.Forms.TextBox -Property @{
    Lines  = $null
    Left   = $FormScale * 5
    Top    = $EventLogsEventIDsManualEntryClearButton.Top + $EventLogsEventIDsManualEntryClearButton.Height + $($FormScale * 5)
    Width  = $FormScale * 205
    Height = $FormScale * 139
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
    Text   = "Event IDs Quick Selection"
    Left   = $FormScale * 220
    Top    = $EventLogsOptionsGroupBox.Top + $EventLogsOptionsGroupBox.Height + $($FormScale * 10)
    Width  = $FormScale * 200
    Height = $FormScale * 22
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
}
$Section1EventLogsTab.Controls.Add( $EventLogsQuickPickSelectionCheckbox )


$EventLogsQuickPickSelectionLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Event IDs by Topic - Can Select Multiple"
    Left   = $FormScale * 218
    Top    = $EventLogsQuickPickSelectionCheckbox.Top + $EventLogsQuickPickSelectionCheckbox.Height
    Width  = $FormScale * 410
    Height = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = "Black"
}
$Section1EventLogsTab.Controls.Add($EventLogsQuickPickSelectionLabel)


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\EventLogsQuickPickSelectionClearButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\EventLogsQuickPickSelectionClearButton.ps1"
$EventLogsQuickPickSelectionClearButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Clear"
    Left   = $FormScale * 356
    Top    = $EventLogsQuickPickSelectionLabel.Top + $EventLogsQuickPickSelectionLabel.Height
    Width  = $FormScale * 75
    Height = $FormScale * 20
    Add_Click = $EventLogsQuickPickSelectionClearButtonAdd_Click
}
$Section1EventLogsTab.Controls.Add($EventLogsQuickPickSelectionClearButton)
CommonButtonSettings -Button $EventLogsQuickPickSelectionClearButton


$EventLogsQuickPickSelectionSelectAllButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Select All"
    Left   = $EventLogsQuickPickSelectionClearButton.Left - $EventLogsQuickPickSelectionClearButton.Width - $($FormScale + 10)
    Top    = $EventLogsQuickPickSelectionClearButton.Top
    Width  = $FormScale * 75
    Height = $FormScale * 20
    Add_Click = { For ($i=0;$i -lt $EventLogsQuickPickSelectionCheckedlistbox.Items.count;$i++) { $EventLogsQuickPickSelectionCheckedlistbox.SetItemChecked($i,$true) } }
}
$Section1EventLogsTab.Controls.Add($EventLogsQuickPickSelectionSelectAllButton)
CommonButtonSettings -Button $EventLogsQuickPickSelectionSelectAllButton


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\CheckedListBox\EventLogsQuickPickSelectionCheckedListBox.ps1"
. "$Dependencies\Code\System.Windows.Forms\CheckedListBox\EventLogsQuickPickSelectionCheckedListBox.ps1"
$EventLogsQuickPickSelectionCheckedListBox = New-Object -TypeName System.Windows.Forms.CheckedListBox -Property @{
    Name   = "Event Logs Selection"
    Text   = "Event Logs Selection"
    Left   = $FormScale * 220
    Top    = $EventLogsQuickPickSelectionClearButton.Top + $EventLogsQuickPickSelectionClearButton.Height + $($FormScale * 5)
    Width  = $FormScale * 210
    Height = $FormScale * 150
    ScrollAlwaysVisible = $true
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click = $EventLogsQuickPickSelectionCheckedListBoxAdd_Click
}
foreach ( $Query in $script:EventLogQueries ) { $EventLogsQuickPickSelectionCheckedListBox.Items.Add("$($Query.Name)") }
$Section1EventLogsTab.Controls.Add($EventLogsQuickPickSelectionCheckedListBox)


#============================================================================================================================================================
# Event Logs - Event IDs To Monitor
#============================================================================================================================================================
$script:EventLogSeverityQueries = @()

# The following were obtained from https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/plan/appendix-l--events-to-monitor
$EventLogNotes = "
A potential criticality of High means that one occurrence of the event should be investigated. Potential criticality of Medium or Low means that these events should only be investigated if they occur unexpectedly or in numbers that significantly exceed the expected baseline in a measured period of time. All organizations should test these recommendations in their environments before creating alerts that require mandatory investigative responses. Every environment is different, and some of the events ranked with a potential criticality of High may occur due to other harmless events.
"
$EventLogsToMonitorMicrosoft = Import-Csv -Path $EventLogsWindowITProCenter
$EventLogReference           = "https://conf.splunk.com/session/2015/conf2015_MGough_MalwareArchaelogy_SecurityCompliance_FindingAdvnacedAttacksAnd.pdf"
$EventLogNotes               = Get-Content -Path "$CommandsEventLogsDirectory\Individual Selection\Notes - Event Logs to Monitor - Window IT Pro Center.txt"

# Adds the Current Event Logs to the Selection Pane
$CurrentWindowsEventIdDuplicateCheck = @()
foreach ($CSVLine in $EventLogsToMonitorMicrosoft) {
    if ($CSVLine.CurrentWindowsEventID -ne "NA") {
        $EventLogQuery = New-Object PSObject -Property @{ EventID = $CSVLine.CurrentWindowsEventID }
        $EventLogQuery | Add-Member -MemberType NoteProperty -Name LegacyEventID -Value $CSVLine.LegacyWindowsEventID -Force
        $EventLogQuery | Add-Member -MemberType NoteProperty -Name Label         -Value "Windows IT Pro Center" -Force
        $EventLogQuery | Add-Member -MemberType NoteProperty -Name Severity      -Value $CSVLine.PotentialCriticality -Force
        $EventLogQuery | Add-Member -MemberType NoteProperty -Name Reference     -Value $EventLogReference -Force
        $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message       -Value $CSVLine.EventSummary -Force
        $EventLogQuery | Add-Member -MemberType NoteProperty -Name Notes         -Value $EventLogNotes -Force
        if ($CSVLine.CurrentWindowsEventID -notin $CurrentWindowsEventIdDuplicateCheck) {
            $script:EventLogSeverityQueries      += $EventLogQuery
            $CurrentWindowsEventIdDuplicateCheck += $CSVLine.CurrentWindowsEventID
        }
    }
}
# Adds the Legacy Event Logs to the Selection Pane
$LegacyWindowsEventIdDuplicateCheck = @()
foreach ($CSVLine in $EventLogsToMonitorMicrosoft) {
    if ($CSVLine.LegacyWindowsEventID -ne "NA") {
        $EventLogQuery = New-Object PSObject -Property @{ EventID = $CSVLine.LegacyWindowsEventID }
        $EventLogQuery | Add-Member -MemberType NoteProperty -Name LegacyEventID -Value $CSVLine.LegacyWindowsEventID -Force
        $EventLogQuery | Add-Member -MemberType NoteProperty -Name Label         -Value "Windows IT Pro Center" -Force
        $EventLogQuery | Add-Member -MemberType NoteProperty -Name Severity      -Value $CSVLine.PotentialCriticality -Force
        $EventLogQuery | Add-Member -MemberType NoteProperty -Name Reference     -Value $EventLogReference -Force
        $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message       -Value "<Legacy> $($CSVLine.EventSummary)" -Force
        $EventLogQuery | Add-Member -MemberType NoteProperty -Name Notes         -Value $EventLogNotes -Force
        if ($CSVLine.LegacyWindowsEventID  -notin $LegacyWindowsEventIdDuplicateCheck) {
            $script:EventLogSeverityQueries     += $EventLogQuery
            $LegacyWindowsEventIdDuplicateCheck += $CSVLine.LegacyWindowsEventID
        }
    }
}


$EventLogsEventIDsToMonitorCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Event IDs To Monitor"
    Left   = $FormScale * 7
    Top    = $EventLogsEventIDsManualEntryTextbox.Top + $EventLogsEventIDsManualEntryTextbox.Height + $($FormScale * 15)
    Width  = $FormScale * 250
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
}
$Section1EventLogsTab.Controls.Add($EventLogsEventIDsToMonitorCheckbox)


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\EventLogsEventIDsToMonitorClearButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\EventLogsEventIDsToMonitorClearButton.ps1"
$EventLogsEventIDsToMonitorClearButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Clear"
    Left   = $FormScale * 356
    Top    = $EventLogsEventIDsToMonitorCheckbox.Top + $EventLogsEventIDsToMonitorCheckbox.Height - $($FormScale * 3)
    Width  = $FormScale * 75
    Height = $FormScale * 20
    Add_Click = $EventLogsEventIDsToMonitorClearButtonAdd_Click
}
$Section1EventLogsTab.Controls.Add($EventLogsEventIDsToMonitorClearButton)
CommonButtonSettings -Button $EventLogsEventIDsToMonitorClearButton

<#
$EventLogsEventIDsToMonitorSelectAllButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Select All"
    Left   = $EventLogsEventIDsToMonitorClearButton.Left - $EventLogsEventIDsToMonitorClearButton.Width - $($FormScale + 10)
    Top    = $EventLogsEventIDsToMonitorClearButton.Top
    Width  = $FormScale * 75
    Height = $FormScale * 20
    Add_Click = { For ($i=0;$i -lt $EventLogsEventIDsToMonitorCheckListBox.Items.count;$i++) { $EventLogsEventIDsToMonitorCheckListBox.SetItemChecked($i,$true) } }
}
$Section1EventLogsTab.Controls.Add($EventLogsEventIDsToMonitorSelectAllButton)
CommonButtonSettings -Button $EventLogsEventIDsToMonitorSelectAllButton
#>

$EventLogsEventIDsToMonitorLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Events IDs to Monitor for Signs of Compromise"
    Left   = $FormScale * 5
    Top    = $EventLogsEventIDsToMonitorCheckbox.Top + $EventLogsEventIDsToMonitorCheckbox.Height
    Width  = $FormScale * 410
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = "Black"
}
$Section1EventLogsTab.Controls.Add($EventLogsEventIDsToMonitorLabel)


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\CheckedListBox\EventLogsEventIDsToMonitorCheckedListBox.ps1"
. "$Dependencies\Code\System.Windows.Forms\CheckedListBox\EventLogsEventIDsToMonitorCheckedListBox.ps1"
$EventLogsEventIDsToMonitorCheckListBox = New-Object -TypeName System.Windows.Forms.CheckedListBox -Property @{
    Text   = "Event IDs [Potential Criticality] Event Summary"
    Left   = $FormScale * 5
    Top    = $EventLogsEventIDsToMonitorLabel.Top + $EventLogsEventIDsToMonitorLabel.Height
    Width  = $FormScale * 425
    Height = $FormScale * 125
    #checked            = $true
    #CheckOnClick       = $true #so we only have to click once to check a box
    #SelectionMode      = One #This will only allow one options at a time
    ScrollAlwaysVisible = $true
    Add_Click = $EventLogsEventIDsToMonitorCheckedListBoxAdd_Click
}
# Creates the list from the variable
foreach ( $Query in $script:EventLogSeverityQueries ) {
    $EventLogsEventIDsToMonitorCheckListBox.Items.Add("$($Query.EventID) [$($Query.Severity)] $($Query.Message)")
}
    $EventLogsEventIDsToMonitorCheckListBox.Items.Add("4624 [test] An account was successfully logged on")
    $EventLogsEventIDsToMonitorCheckListBox.Items.Add("4634 [test] An account was logged off")
$EventLogsEventIDsToMonitorCheckListBox.Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
$Section1EventLogsTab.Controls.Add($EventLogsEventIDsToMonitorCheckListBox)
