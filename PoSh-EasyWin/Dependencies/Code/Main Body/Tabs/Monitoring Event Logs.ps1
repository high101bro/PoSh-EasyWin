
$SmithEventLogsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = "Event Logs"
    Left   = $FormScale * $Column1RightPosition
    Top    = $FormScale * $Column1DownPosition
    Width  = $FormScale * $Column1BoxWidth
    Height = $FormScale * $Column1BoxHeight
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
}
$MainLeftSMITHTabControl.Controls.Add($SmithEventLogsTab)


$SmithEventLogsMainLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Event Logs can be obtained from workstations and servers."
    Left   = $FormScale * 5
    Top    = $FormScale * 5
    Width  = $FormScale * 410
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Black"
}
$SmithEventLogsTab.Controls.Add($SmithEventLogsMainLabel)


$SmithEventLogsOptionsGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text   = "Collection Options"
    Left   = $FormScale * 5
    Top    = $SmithEventLogsMainLabel.Top + $SmithEventLogsMainLabel.Height
    Width  = $FormScale * 425
    Height = $FormScale * 94
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
}

            $SmithEventLogsMaximumCollectionLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Max Collection:"
                Left   = $FormScale * 7
                Top    = $FormScale * 20
                Width  = $FormScale * 100
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
                Add_MouseHover = $SmithEventLogsMaximumCollectionLabelAdd_MouseHover
            }

            $SmithEventLogsMaximumCollectionTextBox = New-Object System.Windows.Forms.TextBox -Property @{
                Text   = 100
                Left   = $SmithEventLogsMaximumCollectionLabel.Left + $SmithEventLogsMaximumCollectionLabel.Width
                Top    = $SmithEventLogsMaximumCollectionLabel.Top - $($FormScale * 3)
                Width  = $FormScale * 50
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                Enabled  = $True
                Add_MouseHover = $SmithEventLogsMaximumCollectionTextBoxAdd_MouseHover
            }


            $SmithEventLogsOptionsGroupBox.Controls.AddRange(@($SmithEventLogsMaximumCollectionLabel,$SmithEventLogsMaximumCollectionTextBox))
$SmithEventLogsTab.Controls.Add($SmithEventLogsOptionsGroupBox)


#============================================================================================================================================================
# Event Logs - Event IDs Manual Entry
#============================================================================================================================================================

$SmithEventLogsEventIDsManualEntryCheckbox  = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Event IDs Manual Entry"
    Left   = $FormScale * 7
    Top    = $SmithEventLogsOptionsGroupBox.Top + $SmithEventLogsOptionsGroupBox.Height + $($FormScale * 10)
    Width  = $FormScale * 200
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
}
$SmithEventLogsTab.Controls.Add($SmithEventLogsEventIDsManualEntryCheckbox)


$SmithEventLogsEventIDsManualEntryLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Enter Event IDs; One Per Line"
    Left   = $FormScale * 5
    Top    = $SmithEventLogsEventIDsManualEntryCheckbox.Top + $SmithEventLogsEventIDsManualEntryCheckbox.Height
    Width  = $FormScale * 200
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = "Black"
}
$SmithEventLogsTab.Controls.Add($SmithEventLogsEventIDsManualEntryLabel)


$SmithEventLogsEventIDsManualEntrySelectionButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Select Event IDs"
    Left   = $FormScale * 4
    Top    = $SmithEventLogsEventIDsManualEntryLabel.Top + $SmithEventLogsEventIDsManualEntryLabel.Height
    Width  = $FormScale * 125
    Height = $FormScale * 20
    Add_Click = $SmithEventLogsEventIDsManualEntrySelectionButtonAdd_Click
}
$SmithEventLogsTab.Controls.Add($SmithEventLogsEventIDsManualEntrySelectionButton)
CommonButtonSettings -Button $SmithEventLogsEventIDsManualEntrySelectionButton


$SmithEventLogsEventIDsManualEntryClearButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Clear"
    Left   = $FormScale * 136
    Top    = $SmithEventLogsEventIDsManualEntryLabel.Top + $SmithEventLogsEventIDsManualEntryLabel.Height
    Width  = $FormScale * 75
    Height = $FormScale * 20
    Add_Click = { $SmithEventLogsEventIDsManualEntryTextbox.Text = "" }
}
$SmithEventLogsTab.Controls.Add($SmithEventLogsEventIDsManualEntryClearButton)
CommonButtonSettings -Button $SmithEventLogsEventIDsManualEntryClearButton


$SmithEventLogsEventIDsManualEntryTextbox = New-Object System.Windows.Forms.TextBox -Property @{
    Lines  = $null
    Left   = $FormScale * 5
    Top    = $SmithEventLogsEventIDsManualEntryClearButton.Top + $SmithEventLogsEventIDsManualEntryClearButton.Height + $($FormScale * 5)
    Width  = $FormScale * 205
    Height = $FormScale * 139
    MultiLine     = $True
    WordWrap      = $True
    AcceptsTab    = $false
    AcceptsReturn = $false
    ScrollBars    = "Vertical"
    Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$SmithEventLogsTab.Controls.Add($SmithEventLogsEventIDsManualEntryTextbox)


$SmithEventLogsQuickPickSelectionCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Event IDs Quick Selection"
    Left   = $FormScale * 220
    Top    = $SmithEventLogsOptionsGroupBox.Top + $SmithEventLogsOptionsGroupBox.Height + $($FormScale * 10)
    Width  = $FormScale * 200
    Height = $FormScale * 22
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
}
$SmithEventLogsTab.Controls.Add( $SmithEventLogsQuickPickSelectionCheckbox )


$SmithEventLogsQuickPickSelectionLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Event IDs by Topic - Can Select Multiple"
    Left   = $FormScale * 218
    Top    = $SmithEventLogsQuickPickSelectionCheckbox.Top + $SmithEventLogsQuickPickSelectionCheckbox.Height
    Width  = $FormScale * 410
    Height = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = "Black"
}
$SmithEventLogsTab.Controls.Add($SmithEventLogsQuickPickSelectionLabel)


$SmithEventLogsQuickPickSelectionClearButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Clear"
    Left   = $FormScale * 356
    Top    = $SmithEventLogsQuickPickSelectionLabel.Top + $SmithEventLogsQuickPickSelectionLabel.Height
    Width  = $FormScale * 75
    Height = $FormScale * 20
    Add_Click = $SmithEventLogsQuickPickSelectionClearButtonAdd_Click
}
$SmithEventLogsTab.Controls.Add($SmithEventLogsQuickPickSelectionClearButton)
CommonButtonSettings -Button $SmithEventLogsQuickPickSelectionClearButton


$SmithEventLogsQuickPickSelectionSelectAllButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Select All"
    Left   = $SmithEventLogsQuickPickSelectionClearButton.Left - $SmithEventLogsQuickPickSelectionClearButton.Width - $($FormScale + 10)
    Top    = $SmithEventLogsQuickPickSelectionClearButton.Top
    Width  = $FormScale * 75
    Height = $FormScale * 20
    Add_Click = { For ($i=0;$i -lt $SmithEventLogsQuickPickSelectionCheckedlistbox.Items.count;$i++) { $SmithEventLogsQuickPickSelectionCheckedlistbox.SetItemChecked($i,$true) } }
}
$SmithEventLogsTab.Controls.Add($SmithEventLogsQuickPickSelectionSelectAllButton)
CommonButtonSettings -Button $SmithEventLogsQuickPickSelectionSelectAllButton


$SmithEventLogsQuickPickSelectionCheckedListBox = New-Object -TypeName System.Windows.Forms.CheckedListBox -Property @{
    Name   = "Event Logs Selection"
    Text   = "Event Logs Selection"
    Left   = $FormScale * 220
    Top    = $SmithEventLogsQuickPickSelectionClearButton.Top + $SmithEventLogsQuickPickSelectionClearButton.Height + $($FormScale * 5)
    Width  = $FormScale * 210
    Height = $FormScale * 150
    ScrollAlwaysVisible = $true
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click = $SmithEventLogsQuickPickSelectionCheckedListBoxAdd_Click
}
foreach ( $Query in $script:SmithEventLogQueries ) { $SmithEventLogsQuickPickSelectionCheckedListBox.Items.Add("$($Query.Name)") }
$SmithEventLogsTab.Controls.Add($SmithEventLogsQuickPickSelectionCheckedListBox)


#============================================================================================================================================================
# Event Logs - Event IDs To Monitor
#============================================================================================================================================================
$script:SmithEventLogSeverityQueries = @()

# The following were obtained from https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/plan/appendix-l--events-to-monitor
$SmithEventLogNotes = "
A potential criticality of High means that one occurrence of the event should be investigated. Potential criticality of Medium or Low means that these events should only be investigated if they occur unexpectedly or in numbers that significantly exceed the expected baseline in a measured period of time. All organizations should test these recommendations in their environments before creating alerts that require mandatory investigative responses. Every environment is different, and some of the events ranked with a potential criticality of High may occur due to other harmless events.
"
$SmithEventLogsToMonitorMicrosoft = Import-Csv -Path $SmithEventLogsWindowITProCenter
$SmithEventLogReference           = "https://conf.splunk.com/session/2015/conf2015_MGough_MalwareArchaelogy_SecurityCompliance_FindingAdvnacedAttacksAnd.pdf"
$SmithEventLogNotes               = Get-Content -Path "$CommandsEventLogsDirectory\Individual Selection\Notes - Event Logs to Monitor - Window IT Pro Center.txt"

# Adds the Current Event Logs to the Selection Pane
$SmithCurrentWindowsEventIdDuplicateCheck = @()
foreach ($CSVLine in $SmithEventLogsToMonitorMicrosoft) {
    if ($CSVLine.CurrentWindowsEventID -ne "NA") {
        $SmithEventLogQuery = New-Object PSObject -Property @{ EventID = $CSVLine.CurrentWindowsEventID }
        $SmithEventLogQuery | Add-Member -MemberType NoteProperty -Name LegacyEventID -Value $CSVLine.LegacyWindowsEventID -Force
        $SmithEventLogQuery | Add-Member -MemberType NoteProperty -Name Label         -Value "Windows IT Pro Center" -Force
        $SmithEventLogQuery | Add-Member -MemberType NoteProperty -Name Severity      -Value $CSVLine.PotentialCriticality -Force
        $SmithEventLogQuery | Add-Member -MemberType NoteProperty -Name Reference     -Value $SmithEventLogReference -Force
        $SmithEventLogQuery | Add-Member -MemberType NoteProperty -Name Message       -Value $CSVLine.EventSummary -Force
        $SmithEventLogQuery | Add-Member -MemberType NoteProperty -Name Notes         -Value $SmithEventLogNotes -Force
        if ($CSVLine.CurrentWindowsEventID -notin $SmithCurrentWindowsEventIdDuplicateCheck) {
            $script:SmithEventLogSeverityQueries      += $SmithEventLogQuery
            $SmithCurrentWindowsEventIdDuplicateCheck += $CSVLine.CurrentWindowsEventID
        }
    }
}
# Adds the Legacy Event Logs to the Selection Pane
$LegacyWindowsEventIdDuplicateCheck = @()
foreach ($CSVLine in $SmithEventLogsToMonitorMicrosoft) {
    if ($CSVLine.LegacyWindowsEventID -ne "NA") {
        $SmithEventLogQuery = New-Object PSObject -Property @{ EventID = $CSVLine.LegacyWindowsEventID }
        $SmithEventLogQuery | Add-Member -MemberType NoteProperty -Name LegacyEventID -Value $CSVLine.LegacyWindowsEventID -Force
        $SmithEventLogQuery | Add-Member -MemberType NoteProperty -Name Label         -Value "Windows IT Pro Center" -Force
        $SmithEventLogQuery | Add-Member -MemberType NoteProperty -Name Severity      -Value $CSVLine.PotentialCriticality -Force
        $SmithEventLogQuery | Add-Member -MemberType NoteProperty -Name Reference     -Value $SmithEventLogReference -Force
        $SmithEventLogQuery | Add-Member -MemberType NoteProperty -Name Message       -Value "<Legacy> $($CSVLine.EventSummary)" -Force
        $SmithEventLogQuery | Add-Member -MemberType NoteProperty -Name Notes         -Value $SmithEventLogNotes -Force
        if ($CSVLine.LegacyWindowsEventID  -notin $LegacyWindowsEventIdDuplicateCheck) {
            $script:SmithEventLogSeverityQueries     += $SmithEventLogQuery
            $LegacyWindowsEventIdDuplicateCheck += $CSVLine.LegacyWindowsEventID
        }
    }
}


$SmithEventLogsEventIDsToMonitorCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Event IDs To Monitor"
    Left   = $FormScale * 7
    Top    = $SmithEventLogsEventIDsManualEntryTextbox.Top + $SmithEventLogsEventIDsManualEntryTextbox.Height + $($FormScale * 15)
    Width  = $FormScale * 250
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
}
$SmithEventLogsTab.Controls.Add($SmithEventLogsEventIDsToMonitorCheckbox)


$SmithEventLogsEventIDsToMonitorClearButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Clear"
    Left   = $FormScale * 356
    Top    = $SmithEventLogsEventIDsToMonitorCheckbox.Top + $SmithEventLogsEventIDsToMonitorCheckbox.Height - $($FormScale * 3)
    Width  = $FormScale * 75
    Height = $FormScale * 20
    Add_Click = $SmithEventLogsEventIDsToMonitorClearButtonAdd_Click
}
$SmithEventLogsTab.Controls.Add($SmithEventLogsEventIDsToMonitorClearButton)
CommonButtonSettings -Button $SmithEventLogsEventIDsToMonitorClearButton

<#
$SmithEventLogsEventIDsToMonitorSelectAllButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Select All"
    Left   = $SmithEventLogsEventIDsToMonitorClearButton.Left - $SmithEventLogsEventIDsToMonitorClearButton.Width - $($FormScale + 10)
    Top    = $SmithEventLogsEventIDsToMonitorClearButton.Top
    Width  = $FormScale * 75
    Height = $FormScale * 20
    Add_Click = { For ($i=0;$i -lt $SmithEventLogsEventIDsToMonitorCheckListBox.Items.count;$i++) { $SmithEventLogsEventIDsToMonitorCheckListBox.SetItemChecked($i,$true) } }
}
$SmithEventLogsTab.Controls.Add($SmithEventLogsEventIDsToMonitorSelectAllButton)
CommonButtonSettings -Button $SmithEventLogsEventIDsToMonitorSelectAllButton
#>

$SmithEventLogsEventIDsToMonitorLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Events IDs to Monitor for Signs of Compromise"
    Left   = $FormScale * 5
    Top    = $SmithEventLogsEventIDsToMonitorCheckbox.Top + $SmithEventLogsEventIDsToMonitorCheckbox.Height
    Width  = $FormScale * 410
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = "Black"
}
$SmithEventLogsTab.Controls.Add($SmithEventLogsEventIDsToMonitorLabel)


$SmithEventLogsEventIDsToMonitorCheckListBox = New-Object -TypeName System.Windows.Forms.CheckedListBox -Property @{
    Text   = "Event IDs [Potential Criticality] Event Summary"
    Left   = $FormScale * 5
    Top    = $SmithEventLogsEventIDsToMonitorLabel.Top + $SmithEventLogsEventIDsToMonitorLabel.Height
    Width  = $FormScale * 425
    Height = $FormScale * 125
    #checked            = $true
    #CheckOnClick       = $true #so we only have to click once to check a box
    #SelectionMode      = One #This will only allow one options at a time
    ScrollAlwaysVisible = $true
    Add_Click = $SmithEventLogsEventIDsToMonitorCheckedListBoxAdd_Click
}
# Creates the list from the variable
foreach ( $Query in $script:SmithEventLogSeverityQueries ) {
    $SmithEventLogsEventIDsToMonitorCheckListBox.Items.Add("$($Query.EventID) [$($Query.Severity)] $($Query.Message)")
}
    $SmithEventLogsEventIDsToMonitorCheckListBox.Items.Add("4624 [test] An account was successfully logged on")
    $SmithEventLogsEventIDsToMonitorCheckListBox.Items.Add("4634 [test] An account was logged off")
$SmithEventLogsEventIDsToMonitorCheckListBox.Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
$SmithEventLogsTab.Controls.Add($SmithEventLogsEventIDsToMonitorCheckListBox)
