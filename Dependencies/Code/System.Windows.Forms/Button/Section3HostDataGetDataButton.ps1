$Section3HostDataGridViewButtonAdd_Click = {
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

$Section3HostDataPSWriteHTMLButtonAdd_Click = {
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

$Section3HostDataGridViewButtonAdd_MouseHover = {
Show-ToolTip -Title "Get Data" -Icon "Info" -Message @"
+  If data exists, the datetime group will be displayed.
+  These files can be searchable, toggle in Options Tab.
+  Note: If datetimes don't show contents, it may be due to multiple results.
If this is the case, navigate to the csv file manually.
"@
}


