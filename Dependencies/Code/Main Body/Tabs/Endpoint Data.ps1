
$Section3HostDataTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text = "Endpoint Data"
    Name = "Host Data Tab"
    Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
    Add_click = { script:Minimize-MonitorJobsTab }
}
$InformationTabControl.Controls.Add($Section3HostDataTab)


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\TextBox\Section3HostDataNameTextBox.ps1"
. "$Dependencies\Code\System.Windows.Forms\TextBox\Section3HostDataNameTextBox.ps1"
$script:Section3HostDataNameTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = 0
                  Y = $FormScale * 3 }
    Size     = @{ Width  = $FormScale * 250
                  Height = $FormScale * 25 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ReadOnly = $true
    Add_MouseHover = $script:Section3HostDataNameTextBoxAdd_MouseHover
}
$Section3HostDataTab.Controls.Add($script:Section3HostDataNameTextBox)


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\TextBox\Section3HostDataOSTextBox.ps1"
. "$Dependencies\Code\System.Windows.Forms\TextBox\Section3HostDataOSTextBox.ps1"
$Section3HostDataOSTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = 0
                  Y = $script:Section3HostDataNameTextBox.Location.Y + $script:Section3HostDataNameTextBox.Size.Height + $($FormScale * 4) }
    Size     = @{ Width  = $FormScale * 250
                  Height = $FormScale * 25 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ReadOnly = $true
    Add_MouseHover = $Section3HostDataOSTextBoxAdd_MouseHover
}
$Section3HostDataTab.Controls.Add($Section3HostDataOSTextBox)


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\TextBox\Section3HostDataOUTextBox.ps1"
. "$Dependencies\Code\System.Windows.Forms\TextBox\Section3HostDataOUTextBox.ps1"
$Section3HostDataOUTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = 0
                  Y = $Section3HostDataOSTextBox.Location.Y + $Section3HostDataOSTextBox.Size.Height + $($FormScale * 4) }
    Size     = @{ Width  = $FormScale * 250
                  Height = $FormScale * 25 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ReadOnly = $true
    Add_MouseHover = $Section3HostDataOUTextBoxAdd_MouseHover
}
$Section3HostDataTab.Controls.Add($Section3HostDataOUTextBox)


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\TextBox\Section3HostDataIPTextBox.ps1"
. "$Dependencies\Code\System.Windows.Forms\TextBox\Section3HostDataIPTextBox.ps1"
$Section3HostDataIPTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = 0
                  Y = $Section3HostDataOUTextBox.Location.Y + $Section3HostDataOUTextBox.Size.Height + $($FormScale * 4) }
    Size     = @{ Width  = $FormScale * 120
                  Height = $FormScale * 25 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ReadOnly = $false
    Add_MouseHover = $Section3HostDataIPTextBoxAdd_MouseHover
}
$Section3HostDataTab.Controls.Add($Section3HostDataIPTextBox)


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\TextBox\Section3HostDataMACTextBox.ps1"
. "$Dependencies\Code\System.Windows.Forms\TextBox\Section3HostDataMACTextBox.ps1"
$Section3HostDataMACTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3HostDataIPTextBox.Size.Width + $($FormScale * 10)
                  Y = $Section3HostDataOUTextBox.Location.Y + $Section3HostDataOUTextBox.Size.Height + $($FormScale * 4) }
    Size     = @{ Width  = $FormScale * 120
                  Height = $FormScale * 25 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ReadOnly = $false
    Add_MouseHover = $Section3HostDataMACTextBoxAdd_MouseHover
}
$Section3HostDataTab.Controls.Add($Section3HostDataMACTextBox)


#============================================================================================================================================================
# Host Data - Selection Data ComboBox and Date/Time ComboBox
#============================================================================================================================================================
$HostDataList1 = (Get-ChildItem -Path $CollectedDataDirectory -Recurse | Where-Object {$_.Extension -match 'csv'}).basename | ForEach-Object { $_.split('(')[0].trim() } | Sort-Object -Unique -Descending

    Update-FormProgress "$Dependencies\Code\System.Windows.Forms\ComboBox\Section3HostDataSelectionComboBox.ps1"
    . "$Dependencies\Code\System.Windows.Forms\ComboBox\Section3HostDataSelectionComboBox.ps1"
    $Section3HostDataSelectionComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Text      = "Host Data - Selection"
        Location  = @{ X = $FormScale * 260
                       Y = $FormScale * 3 }
        Size      = @{ Width  = $FormScale * 200
                       Height = $FormScale * 25 }
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = "Black"
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
        DataSource         = $HostDataList1
        Add_MouseHover     = $Section3HostDataSelectionComboBoxAdd_MouseHover
        Add_SelectedIndexChanged = $Section3HostDataSelectionComboBoxAdd_SelectedIndexChanged
    }
    $Section3HostDataTab.Controls.Add($Section3HostDataSelectionComboBox)


    Update-FormProgress "$Dependencies\Code\System.Windows.Forms\ComboBox\Section3HostDataSelectionDateTimeComboBox.ps1"
    . "$Dependencies\Code\System.Windows.Forms\ComboBox\Section3HostDataSelectionDateTimeComboBox.ps1"
    $Section3HostDataSelectionDateTimeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Text      = "Host Data - Date & Time"
        Location  = @{ X = $FormScale * 260
                       Y = $Section3HostDataSelectionComboBox.Size.Height + $Section3HostDataSelectionComboBox.Location.Y + $($FormScale * 3)}
        Size      = @{ Width  = $FormScale * 200
                       Height = $FormScale * 25 }
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = "Black"
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
        Add_MouseHover     = $Section3HostDataSelectionDateTimeComboBoxAdd_MouseHover
    }
    $Section3HostDataTab.Controls.Add($Section3HostDataSelectionDateTimeComboBox)


    Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\Section3HostDataGetDataButton.ps1"
    . "$Dependencies\Code\System.Windows.Forms\Button\Section3HostDataGetDataButton.ps1"
    $Section3HostDataGridViewButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Grid View"
        Location = @{ X = $Section3HostDataSelectionDateTimeComboBox.Location.X + $Section3HostDataSelectionDateTimeComboBox.Size.Width + $($FormScale * 5)
                      Y =  $Section3HostDataSelectionDateTimeComboBox.Location.Y - $($FormScale * 1) }
        Size     = @{ Width  = $FormScale * 75
                      Height = $FormScale * 22 }
        Add_Click = $Section3HostDataGridViewButtonAdd_Click
        Add_MouseHover = $Section3HostDataGridViewButtonAdd_MouseHover
    }
    $Section3HostDataTab.Controls.Add($Section3HostDataGridViewButton)
    CommonButtonSettings -Button $Section3HostDataGridViewButton


    if ((Test-Path -Path "$Dependencies\Modules\PSWriteHTML") -and (Get-Content "$PoShHome\Settings\PSWriteHTML Module Install.txt") -match 'Yes') {
        $Section3HostDataPSWriteHTMLButton = New-Object System.Windows.Forms.Button -Property @{
            Text     = "HTML"
            Location = @{ X = $Section3HostDataGridViewButton.Location.X + $Section3HostDataGridViewButton.Size.Width + $($FormScale * 5)
                          Y =  $Section3HostDataGridViewButton.Location.Y - $($FormScale * 1) }
            Size     = @{ Width  = $FormScale * 75
                          Height = $FormScale * 22 }
            Add_Click = $Section3HostDataPSWriteHTMLButtonAdd_Click
        }
        $Section3HostDataTab.Controls.Add($Section3HostDataPSWriteHTMLButton)
        CommonButtonSettings -Button $Section3HostDataPSWriteHTMLButton    
    }

Update-FormProgress "$Dependencies\Code\System.Windows.Forms\ComboBox\Section3HostDataTagsComboBox.ps1"
. "$Dependencies\Code\System.Windows.Forms\ComboBox\Section3HostDataTagsComboBox.ps1"
$Section3HostDataTagsComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Name               = "Tags"
    Text               = "Tags"
    Location = @{ X = $FormScale * 260
                  Y = $Section3HostDataMACTextBox.Location.Y }
    Size     = @{ Width  = $FormScale * 200
                  Height = $FormScale * 25 }
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
    Font               = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_MouseHover     = $Section3HostDataTagsComboBoxAdd_MouseHover
}
ForEach ($Item in $TagListFileContents) { $Section3HostDataTagsComboBox.Items.Add($Item) }
$Section3HostDataTab.Controls.Add($Section3HostDataTagsComboBox)


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\Section3HostDataTagsAddButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\Section3HostDataTagsAddButton.ps1"
$Section3HostDataTagsAddButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Add"
    Location = @{ X = $Section3HostDataTagsComboBox.Size.Width + $Section3HostDataTagsComboBox.Location.X + $($FormScale * 5)
                  Y = $Section3HostDataTagsComboBox.Location.Y - $($FormScale * 1) }
    Size     = @{ Width  = $FormScale * 75
                  Height = $FormScale * 22 }
    Add_Click = $Section3HostDataTagsAddButtonAdd_Click
    Add_MouseHover = $Section3HostDataTagsAddButtonAdd_MouseHover
}
$Section3HostDataTab.Controls.Add($Section3HostDataTagsAddButton)
CommonButtonSettings -Button $Section3HostDataTagsAddButton


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RichTextBox\Section3HostDataNotesRichTextBox.ps1"
. "$Dependencies\Code\System.Windows.Forms\RichTextBox\Section3HostDataNotesRichTextBox.ps1"
$Section3HostDataNotesRichTextBox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Left   = 0
    Top    = $Section3HostDataMACTextBox.Location.Y + $Section3HostDataMACTextBox.Size.Height + $($FormScale * 6)
    Width  = $FormScale * 634
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Multiline  = $True
    ScrollBars = 'Vertical'
    WordWrap   = $True
    ReadOnly   = $false
    Add_MouseHover = $Section3HostDataNotesRichTextBoxAdd_MouseHover
    Add_MouseEnter = { Check-HostDataIfModified }
    Add_MouseLeave = { Check-HostDataIfModified }
}
$Section3HostDataTab.Controls.Add($Section3HostDataNotesRichTextBox)


$script:Section3HostDataNotesSaveCheck = ""
Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\Section3HostDataSaveButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\Section3HostDataSaveButton.ps1"
$Section3HostDataSaveButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "Data Saved"
    Location = @{ X = $Section3HostDataNotesRichTextBox.Location.X + $Section3HostDataNotesRichTextBox.Size.Width + $($FormScale + 5)
                  Y = $Section3HostDataNotesRichTextBox.Location.Y }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Add_Click = $Section3HostDataSaveButtonAdd_Click
    Add_MouseHover = $Section3HostDataSaveButtonAdd_MouseHover
}
$Section3HostDataTab.Controls.Add($Section3HostDataSaveButton)
CommonButtonSettings -Button $Section3HostDataSaveButton


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\Section3HostDataNotesAddOpNotesButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\Section3HostDataNotesAddOpNotesButton.ps1"
$Section3HostDataNotesAddOpNotesButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "Add To OpNotes"
    Location = @{ X = $Section3HostDataSaveButton.Location.X
                  Y = $Section3HostDataSaveButton.Location.Y + $Section3HostDataSaveButton.Size.Height + $($FormScale + 5) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Add_Click = $Section3HostDataNotesAddOpNotesButtonAdd_Click
    Add_MouseHover = $Section3HostDataNotesAddOpNotesButtonAdd_MouseHover
}
$Section3HostDataTab.Controls.Add($Section3HostDataNotesAddOpNotesButton)
CommonButtonSettings -Button $Section3HostDataNotesAddOpNotesButton


# Mass Tag one or multiple hosts in the computer treeview
Update-FormProgress "$Dependencies\Code\Tree View\Computer\Save-ComputerTreeNodeHostData.ps1"
. "$Dependencies\Code\Tree View\Computer\Save-ComputerTreeNodeHostData.ps1"

# Checks if the Host Data has been modified and determines the text color: Green/Red
Update-FormProgress "$Dependencies\Code\Main Body\Check-HostDataIfModified.ps1"
. "$Dependencies\Code\Main Body\Check-HostDataIfModified.ps1"
