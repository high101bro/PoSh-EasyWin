$EventLogsQuickPickSelectionCheckedListBoxAdd_Click = {
    foreach ( $Query in $script:EventLogQueries ) {
        If ( $Query.Name -imatch $EventLogsQuickPickSelectionCheckedListBox.SelectedItem ) {
            $ResultsListBox.Items.Clear()
            $CommandFileNotes = Get-Content -Path $Query.FilePath
            foreach ($line in $CommandFileNotes) {$ResultsListBox.Items.Add("$line")}
        }
    }
}
