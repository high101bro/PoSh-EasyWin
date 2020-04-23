$Section3HostDataGetDataButtonAdd_Click = {
    # Chooses the most recent file if multiple exist
    $MostRecentResultIfMultipleCopiesExist = Get-ChildItem "$CollectedDataDirectory\$($Section3HostDataSelectionDateTimeComboBox.SelectedItem)\$script:HostDataCsvPath\*$($Section3HostDataNameTextBox.Text)*.csv" | Select-Object -Last 1
    $HostData = Import-Csv -Path $MostRecentResultIfMultipleCopiesExist
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

$Section3HostDataGetDataButtonAdd_MouseHover = {
Show-ToolTip -Title "Get Data" -Icon "Info" -Message @"
+  If data exists, the datetime group will be displayed.
+  These files can be searchable, toggle in Options Tab.
+  Note: If datetimes don't show contents, it may be due to multiple results.
If this is the case, navigate to the csv file manually.
"@
}
