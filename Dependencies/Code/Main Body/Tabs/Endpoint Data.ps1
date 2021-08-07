$Section3HostDataTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text = "Endpoint Data"
    Name = "Host Data Tab"
    Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
    Add_click = { script:Minimize-MonitorJobsTab }
}
$InformationTabControl.Controls.Add($Section3HostDataTab)


$script:Section3HostDataNameTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = 0
    Top       = $FormScale * 3
    Width     = $FormScale * 250
    Height    = $FormScale * 25
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    ReadOnly  = $true
    Add_MouseEnter = {
        $script:TextMemory = $This.Text
        $This.ForeColor    = 'Blue'
        $This.Text         = "Hostname"
    }
    Add_MouseLeave = {
        $This.ForeColor    = 'Black'
        $This.Text         = $script:TextMemory
    }
    Add_MouseHover = {
        Show-ToolTip -Title "Hostname" -Icon "Info" -Message @"
+  This field is reserved for the hostname.
+  Hostnames are not case sensitive.
+  Though IP addresses may be entered, WinRM queries may fail as
    IPs may only be used for authentication under certain conditions.
"@
    }
}
$Section3HostDataTab.Controls.Add($script:Section3HostDataNameTextBox)


$Section3HostDataOSTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = 0
    Top       = $script:Section3HostDataNameTextBox.Top + $script:Section3HostDataNameTextBox.Height + $($FormScale * 4)
    Width     = $FormScale * 250
    Height    = $FormScale * 25
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    ReadOnly  = $true
    Add_MouseEnter = {
        $script:TextMemory = $This.Text
        $This.ForeColor    = 'Blue'
        $This.Text         = "Operating System"
    }
    Add_MouseLeave = {
        $This.ForeColor    = 'Black'
        $This.Text         = $script:TextMemory
    }
    Add_MouseHover = {
        Show-ToolTip -Title "Operating System" -Icon "Info" -Message @"
+  This field is useful to view groupings of hosts by OS.
"@
    }
}
$Section3HostDataTab.Controls.Add($Section3HostDataOSTextBox)


$Section3HostDataOUTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = 0
    Top       = $Section3HostDataOSTextBox.Top + $Section3HostDataOSTextBox.Height + $($FormScale * 4)
    Width     = $FormScale * 250
    Height    = $FormScale * 25
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    ReadOnly  = $true
    Add_MouseEnter = {
        $script:TextMemory = $This.Text
        $This.ForeColor    = 'Blue'
        $This.Text         = "Organizational Unit / Container Name"
    }
    Add_MouseLeave = {
        $This.ForeColor    = 'Black'
        $This.Text         = $script:TextMemory
    }
    Add_MouseHover = {
        Show-ToolTip -Title "Organizational Unit / Container Name" -Icon "Info" -Message @"
+  This field is useful to view groupings of hosts by OU/CN.
"@
    }
}
$Section3HostDataTab.Controls.Add($Section3HostDataOUTextBox)


$Section3HostDataIPTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = 0
    Top       = $Section3HostDataOUTextBox.Top + $Section3HostDataOUTextBox.Height + $($FormScale * 4)
    Width     = $FormScale * 120
    Height    = $FormScale * 25
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    ReadOnly  = $false
    Add_MouseHover = {
        Show-ToolTip -Title "IP Address" -Icon "Info" -Message @"
+  Informational field not used to query hosts.
"@
    }
    Add_MouseEnter = {
        $This.ForeColor = 'DarkRed'
    }
    Add_MouseLeave = {
        $This.ForeColor = 'Black'
        Save-TreeViewData -Endpoint
    }
    Add_KeyDown    = {
        if ($_.KeyCode) {
            $This.ForeColor = 'DarkRed'
        }
    }
}
$Section3HostDataTab.Controls.Add($Section3HostDataIPTextBox)


$Section3HostDataMACTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = $Section3HostDataIPTextBox.Width + $($FormScale * 10)
    Top       = $Section3HostDataOUTextBox.Top + $Section3HostDataOUTextBox.Height + $($FormScale * 4)
    Width     = $FormScale * 120
    Height    = $FormScale * 25
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    ReadOnly  = $false
    Add_MouseHover = {
        Show-ToolTip -Title "MAC Address" -Icon "Info" -Message @"
+  Informational field not used to query hosts.
"@
    }
    Add_MouseEnter = {
        $This.ForeColor = 'DarkRed'
    }
    Add_MouseLeave = {
        $This.ForeColor = 'Black'
        Save-TreeViewData -Endpoint
    }
    Add_KeyDown    = {
        if ($_.KeyCode) {
            $This.ForeColor = 'DarkRed'
        }
    }
}
$Section3HostDataTab.Controls.Add($Section3HostDataMACTextBox)


$HostDataList1 = (Get-ChildItem -Path $CollectedDataDirectory -Recurse | Where-Object {$_.Extension -match 'csv'}).basename | ForEach-Object { $_.split('(')[0].trim() } | Sort-Object -Unique -Descending


$Section3HostDataSelectionComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Host Data - Selection"
    Left      = $FormScale * 260
    Top       = $FormScale * 3
    Width     = $FormScale * 200
    Height    = $FormScale * 25
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    ForeColor = "Black"
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
    DataSource         = $HostDataList1
    Add_MouseEnter = {
        $This.ForeColor = 'Blue'
    }
    Add_MouseLeave = {
        $This.ForeColor = 'Black'
    }
    Add_MouseHover = {
        Show-ToolTip -Title "Select Search Topic" -Icon "Info" -Message @"
+  If data exists, the datetime group will be displayed below.
+  These files can be searchable, toggle in Options Tab.
+  Note: Datetimes with more than one collection type won't
display, these results will need to be navigated to manually.
"@            
    }
    Add_SelectedIndexChanged = {
        function Get-HostDataCsvResults {
            param(
                $ComboxInput
            )
            # Searches though the all Collection Data Directories to find files that match
            $ListOfCollectedDataDirectories = $(Get-ChildItem -Path $CollectedDataDirectory  | Sort-Object -Descending).FullName
            $script:CSVFileMatch = @()
            foreach ($CollectionDir in $ListOfCollectedDataDirectories) {
                $CSVFiles = Get-ChildItem -Path $CollectionDir -Recurse | Where {$_.Extension -match 'csv'}
                foreach ($CSVFile in $CSVFiles) {
                    # Searches for the CSV file that matches the data selected
                    if ($CSVFile.BaseName -match $ComboxInput) {
                        $CsvComputerNameList = Import-Csv $CSVFile.FullName | Select -Property ComputerName -Unique
                        foreach ($computer in $CsvComputerNameList){
                            if ("$computer" -match "$($script:Section3HostDataNameTextBox.Text)"){
                                $script:CSVFileMatch += $CSVFile.Name
                            }
                        }
                    }
                }
            }
        }
    
        Get-HostDataCsvResults -ComboxInput $Section3HostDataSelectionComboBox.SelectedItem
    
        if (($script:CSVFileMatch).count -eq 0) {
            $Section3HostDataSelectionDateTimeComboBox.DataSource = @('No Data Available')
        }
        else {
            $Section3HostDataSelectionDateTimeComboBox.DataSource = $script:CSVFileMatch
            #    Get-HostDataCsvDateTime -ComboBoxInput $script:CSVFileMatch
        }
    }
}
$Section3HostDataTab.Controls.Add($Section3HostDataSelectionComboBox)


$Section3HostDataSelectionDateTimeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Host Data - Date & Time"
    Left      = $FormScale * 260
    Top       = $Section3HostDataSelectionComboBox.Height + $Section3HostDataSelectionComboBox.Top + $($FormScale * 3)
    Width     = $FormScale * 200
    Height    = $FormScale * 25
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    ForeColor = "Black"
    AutoCompleteSource = "ListItems"
    AutoCompleteMode = "SuggestAppend"
    Add_MouseEnter = {
        $This.ForeColor = 'Blue'
    }
    Add_MouseLeave = {
        $This.ForeColor = 'Black'
    }
    Add_MouseHover = {
        Show-ToolTip -Title "Datetime of Results" -Icon "Info" -Message @"
+  If data exists, the datetime group will be displayed.
+  These files can be searchable, toggle in Options Tab.
+  Note: Datetimes with more than one collection type won't
display, these results will need to be navigated to manually.
"@
    }
}
$Section3HostDataTab.Controls.Add($Section3HostDataSelectionDateTimeComboBox)


$Section3HostDataGridViewButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "Grid View"
    Left      = $Section3HostDataSelectionDateTimeComboBox.Left + $Section3HostDataSelectionDateTimeComboBox.Width + $($FormScale * 5)
    Top       =  $Section3HostDataSelectionDateTimeComboBox.Top - $($FormScale * 1)
    Width     = $FormScale * 75
    Height    = $FormScale * 22
    Add_Click = {
        # Chooses the most recent file if multiple exist
        $CSVFileToImport = (Get-ChildItem -File -Path $CollectedDataDirectory -Recurse | Where-Object {$_.name -like $Section3HostDataSelectionDateTimeComboBox.SelectedItem}).Fullname
        $HostData = Import-Csv $CSVFileToImport
        if ($HostData) {
            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("Showing Results:  $HostDataSection")
            $HostData | Out-GridView -Title 'PoSh-EasyWin: Collected Data' -OutputMode Multiple | Set-Variable -Name HostDataResultsSection

            # Adds Out-GridView selected Host Data to OpNotes
            foreach ($Selection in $HostDataResultsSection) {
                $OpNotesListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  $HostDataSection - $($Selection -replace '@{','' -replace '}','')")
                Add-Content -Path $OpNotesWriteOnlyFile -Value ($OpNotesListBox.SelectedItems) -Force
            }
            Save-OpNotes
        }
        else {
            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("No Data Available:  $HostDataSection")
            # Sounds a chime if there is not data
            [system.media.systemsounds]::Exclamation.play()
        }
    }
    Add_MouseHover = {
        Show-ToolTip -Title "Get Data" -Icon "Info" -Message @"
+  If data exists, the datetime group will be displayed.
+  These files can be searchable, toggle in Options Tab.
+  Note: If datetimes don't show contents, it may be due to multiple results.
If this is the case, navigate to the csv file manually.
"@
    }
}
$Section3HostDataTab.Controls.Add($Section3HostDataGridViewButton)
CommonButtonSettings -Button $Section3HostDataGridViewButton


if ((Test-Path -Path "$Dependencies\Modules\PSWriteHTML") -and (Get-Content "$PoShHome\Settings\PSWriteHTML Module Install.txt") -match 'Yes') {
    $Section3HostDataPSWriteHTMLButton = New-Object System.Windows.Forms.Button -Property @{
        Text      = "HTML"
        Left      = $Section3HostDataGridViewButton.Left + $Section3HostDataGridViewButton.Width + $($FormScale * 5)
        Top       = $Section3HostDataGridViewButton.Top - $($FormScale * 1)
        Width     = $FormScale * 75
        Height    = $FormScale * 22
        Add_Click = {
            # Chooses the most recent file if multiple exist
            $CSVFileToImport = (Get-ChildItem -File -Path $CollectedDataDirectory -Recurse | Where-Object {$_.name -like $Section3HostDataSelectionDateTimeComboBox.SelectedItem}).Fullname
            $HostData = Import-Csv $CSVFileToImport
            if ($HostData) {
                $StatusListBox.Items.Clear()
                $StatusListBox.Items.Add("Showing Results:  $HostDataSection")
                $HostData | Out-HTMLView -Title "$($CSVFileToImport | Split-Path -Leaf)"
            }
            else {
                $StatusListBox.Items.Clear()
                $StatusListBox.Items.Add("No Data Available:  $HostDataSection")
                # Sounds a chime if there is not data
                [system.media.systemsounds]::Exclamation.play()
            }
        }
    }
    $Section3HostDataTab.Controls.Add($Section3HostDataPSWriteHTMLButton)
    CommonButtonSettings -Button $Section3HostDataPSWriteHTMLButton    
}


$Section3HostDataTagsComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Name      = "Tags"
    Text      = "Tags"
    Left      = $FormScale * 260
    Top       = $Section3HostDataMACTextBox.Top
    Width     = $FormScale * 200
    Height    = $FormScale * 25
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    AutoCompleteSource = "ListItems"
    AutoCompleteMode = "SuggestAppend"
    Add_MouseEnter = {
        $This.ForeColor = 'DarkRed'
    }
    Add_MouseLeave = {
        $This.ForeColor = 'Black'
    }
    Add_MouseHover = {
        Show-ToolTip -Title "List of Pre-Built Tags" -Icon "Info" -Message @"
+  Tags are not mandatory.
+  Tags provide standized info to aide searches.
+  Custom tags can be modified, created, and used.
"@
    }
}
ForEach ($Item in $TagListFileContents) { $Section3HostDataTagsComboBox.Items.Add($Item) }
$Section3HostDataTab.Controls.Add($Section3HostDataTagsComboBox)


$Section3HostDataTagsAddButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "Add"
    Left      = $Section3HostDataTagsComboBox.Width + $Section3HostDataTagsComboBox.Left + $($FormScale * 5)
    Top       = $Section3HostDataTagsComboBox.Top - $($FormScale * 1)
    Width     = $FormScale * 70
    Height    = $FormScale * 22
    Add_Click = {
        if (-not ($Section3HostDataTagsComboBox.SelectedItem -eq "Tags")) {
            $Section3HostDataNotesRichTextBox.text = "$(Get-Date) -- $($Section3HostDataTagsComboBox.SelectedItem)`n" + $Section3HostDataNotesRichTextBox.text
        }
        Save-TreeViewData -Endpoint
    }
    Add_MouseHover = {
        Show-ToolTip -Title "Add Tag to Notes" -Icon "Info" -Message @"
+  Tags are not mandatory.
+  Tags provide standized info to aide searches.
+  Custom tags can be created and used.
"@
    }
}
$Section3HostDataTab.Controls.Add($Section3HostDataTagsAddButton)
CommonButtonSettings -Button $Section3HostDataTagsAddButton


$Section3HostDataNotesRichTextBox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Left       = 0
    Top        = $Section3HostDataMACTextBox.Top + $Section3HostDataMACTextBox.Height + $($FormScale * 6)
    Width      = $FormScale * 740
    Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor  = 'White'
    Multiline  = $True
    ScrollBars = 'Vertical'
    WordWrap   = $True
    ReadOnly   = $false
    Add_MouseHover = {
        Show-ToolTip -Title "Host Notes" -Icon "Info" -Message @"
+  These notes are specific to the host.
+  Also can contains Tags if used.
"@
    }
    Add_MouseEnter = {
        $This.ForeColor = 'DarkRed'
    }
    Add_MouseLeave = {
        $This.ForeColor = 'Black'
        Save-TreeViewData -Endpoint
    }
    Add_KeyDown    = {
        if ($_.KeyCode) {
            $This.ForeColor = 'DarkRed'
        }
    }
}
$Section3HostDataTab.Controls.Add($Section3HostDataNotesRichTextBox)


# DEPRECATED
# $script:Section3HostDataNotesSaveCheck = ""
# $Section3HostDataSaveButton = New-Object System.Windows.Forms.Button -Property @{
#     Text      = "Data Saved"
#     Left      = $Section3HostDataNotesRichTextBox.Left + $Section3HostDataNotesRichTextBox.Width + $($FormScale + 5)
#     Top       = $Section3HostDataNotesRichTextBox.Top
#     Width     = $FormScale * 100
#     Height    = $FormScale * 22
#     Add_Click = {
#         Save-TreeViewData -Endpoint
#         $StatusListBox.Items.Clear()
#         $StatusListBox.Items.Add("Saved Host Data:  $($script:Section3HostDataNameTextBox.Text)")            
#     }
#     Add_MouseHover = {
#         Show-ToolTip -Title "Warning" -Icon "Warning" -Message @"
# +  It's Best practice is to manually save after modifying each host data.
# +  That said, data is automatically saved when you select a endpoint in the computer treeview
# "@
#     }
# }
# $Section3HostDataTab.Controls.Add($Section3HostDataSaveButton)
# CommonButtonSettings -Button $Section3HostDataSaveButton