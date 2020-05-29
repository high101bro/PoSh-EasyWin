function Show-TagForm {
    $script:ComputerListMassTagValue = $null
    $ComputerListMassTagForm = New-Object System.Windows.Forms.Form -Property @{
        Text = "Tag Endpoints"
        Size     = @{ Width  = 350
                      Height = 115 }
        StartPosition = "CenterScreen"
        Font = New-Object System.Drawing.Font('Courier New',11,0,0,0)
    }
    #$ComputerListMassTagForm | select *
    $ComputerListMassTagNewTagNameLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Tag Name:"
        Location = @{ X = 5
                      Y = 14}
        Size     = @{ Width  = 100
                      Height = 25 }
    }
    $ComputerListMassTagNewTagNameComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Text     = ""
        Location = @{ X = $ComputerListMassTagNewTagNameLabel.Location.X + $ComputerListMassTagNewTagNameLabel.Size.Width + 5
                      Y = 10 }
        Size     = @{ Width  = 215
                      Height = 25 }
        AutoCompleteSource = "ListItems" # Options are: FileSystem, HistoryList, RecentlyUsedList, AllURL, AllSystemSources, FileSystemDirectories, CustomSource, ListItems, None
        AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
        #DataSource         = $ArrayIfNotAddedWIth .Items.Add
    }
    #$TagListFileContents = Get-Content -Path $TagAutoListFile
    ForEach ($Tag in $TagListFileContents) { $ComputerListMassTagNewTagNameComboBox.Items.Add($Tag) }
    $ComputerListMassTagNewTagNameComboBox.Add_KeyDown({ 
        if ($_.KeyCode -eq "Enter" -and $ComputerListMassTagNewTagNameComboBox.text -ne '') {
            $script:ComputerListMassTagValue = $ComputerListMassTagNewTagNameComboBox.text
            $ComputerListMassTagForm.Close()
        }
    })
    $ComputerListMassTagNewTagNameButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Apply Tag"
        Location = @{ X = $ComputerListMassTagNewTagNameLabel.Location.X + 104
                      Y = $ComputerListMassTagNewTagNameLabel.Location.Y + $ComputerListMassTagNewTagNameLabel.Size.Height + 2 }
        Size     = @{ Width  = 100
                      Height = 25 }
        Add_Click = { 
            if ($ComputerListMassTagNewTagNameComboBox.text -ne '') {
                $script:ComputerListMassTagValue = $ComputerListMassTagNewTagNameComboBox.text
                $ComputerListMassTagForm.Close()
            }
        }
    }
    CommonButtonSettings -Button $ComputerListMassTagNewTagNameButton
    $ComputerListMassTagForm.Controls.AddRange(@($ComputerListMassTagNewTagNameLabel,$ComputerListMassTagNewTagNameComboBox,$ComputerListMassTagNewTagNameButton))
    $ComputerListMassTagForm.Add_Shown({$ComputerListMassTagForm.Activate()})
    $ComputerListMassTagForm.ShowDialog()
}




$ComputerListTagSelectedToolStripButtonAdd_Click = {
    $MainBottomTabControl.SelectedTab = $Section3HostDataTab

    if ($script:EntrySelected) {
        Show-TagForm
        if ($script:ComputerListMassTagValue) {
            $MainBottomTabControl.SelectedTab  = $Section3HostDataTab
            $Section3HostDataNameTextBox.Text  = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $script:EntrySelected.Text}).Name
            $Section3HostDataOSTextBox.Text    = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $script:EntrySelected.Text}).OperatingSystem
            $Section3HostDataOUTextBox.Text    = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $script:EntrySelected.Text}).CanonicalName
            $Section3HostDataIPTextBox.Text    = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $script:EntrySelected.Text}).IPv4Address
            $Section3HostDataMACTextBox.Text   = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $script:EntrySelected.Text}).MACAddress
            $Section3HostDataNotesTextBox.Text = "[$($script:ComputerListMassTagValue)] " + $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $script:EntrySelected.Text}).Notes
            Save-ComputerTreeNodeHostData
            Check-HostDataIfModified
            $StatusListBox.Items.clear()
            $StatusListBox.Items.Add("Tag applied to: $($script:EntrySelected.text)")
        }
    }
}



$ComputerListTagAllCheckedToolStripButtonAdd_Click = {
    $MainBottomTabControl.SelectedTab = $Section3HostDataTab

    Create-ComputerNodeCheckBoxArray 
    if ($script:ComputerTreeViewSelected.count -ge 0) {
        Show-TagForm

        if ($script:ComputerListMassTagValue) {
            $ComputerListMassTageArray = @()
            foreach ($node in $script:ComputerTreeViewSelected) {    
                [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerTreeView.Nodes
                foreach ($root in $AllHostsNode) {
                    foreach ($Category in $root.Nodes) { 
                        foreach ($Entry in $Category.Nodes) {
                            if ($Entry.Checked -and $Entry.Text -notin $ComputerListMassTageArray) {
                                $ComputerListMassTageArray += $Entry.Text
                                $MainBottomTabControl.SelectedTab = $Section3HostDataTab
                                $Section3HostDataNameTextBox.Text = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).Name
                                $Section3HostDataOSTextBox.Text   = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).OperatingSystem
                                $Section3HostDataOUTextBox.Text   = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).CanonicalName
                                $Section3HostDataIPTextBox.Text   = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).IPv4Address
                                $Section3HostDataMACTextBox.Text  = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).MACAddress
                                $Section3HostDataNotesTextBox.Text = "[$($script:ComputerListMassTagValue)] " + $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).Notes
                            }
                            Save-ComputerTreeNodeHostData
                            Check-HostDataIfModified
                        }
                    }
                }  
            }
            $StatusListBox.Items.clear()
            $StatusListBox.Items.Add("Tag Complete: $($script:ComputerTreeViewSelected.count) Endpoints")
        }
    }
}


