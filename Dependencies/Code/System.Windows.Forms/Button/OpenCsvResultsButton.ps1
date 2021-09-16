$OpenCsvResultsButtonAdd_Click = {
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    $ViewCSVResultsOpenResultsOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{
        Title            = "Open CSV Data"
        InitialDirectory = "$(if (Test-Path $($script:CollectionSavedDirectoryTextBox.Text)) {$($script:CollectionSavedDirectoryTextBox.Text)} else {$CollectedDataDirectory})"
        filter           = "Results (*.txt;*.csv;*.xlsx;*.xls)|*.txt;*.csv;*.xls;*.xlsx|Text (*.txt)|*.txt|CSV (*.csv)|*.csv|Excel (*.xlsx)|*.xlsx|Excel (*.xls)|*.xls|All files (*.*)|*.*"
        ShowHelp = $true
    }
    $ViewCSVResultsOpenResultsOpenFileDialog.ShowDialog()
    Import-Csv $($ViewCSVResultsOpenResultsOpenFileDialog.filename) | Out-GridView -Title "$($ViewCSVResultsOpenResultsOpenFileDialog.filename)" -OutputMode Multiple | Set-Variable -Name ViewImportResults

    if ($ViewImportResults) {
        $OpNotesListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) View CSV File:  $($ViewCSVResultsOpenResultsOpenFileDialog.filename)")
        Add-Content -Path $OpNotesWriteOnlyFile -Value ("$($(Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) View CSV File:  $($ViewCSVResultsOpenResultsOpenFileDialog.filename)") -Force
        foreach ($Selection in $ViewImportResults) {
            $OpNotesListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  $($($Selection -replace '@{','' -replace '}','') -replace '@{','' -replace '}','')")
            Add-Content -Path $OpNotesWriteOnlyFile -Value ("$($(Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  $($Selection -replace '@{','' -replace '}','')") -Force
        }
    }
    Save-OpNotes

    Apply-CommonButtonSettings -Button $RetrieveFilesButton

    Apply-CommonButtonSettings -Button $OpenXmlResultsButton
    Apply-CommonButtonSettings -Button $OpenCsvResultsButton

    Apply-CommonButtonSettings -Button $AutoCreateDashboardChartButton
    Apply-CommonButtonSettings -Button $SendFilesButton
}

$OpenCsvResultsButtonAdd_MouseHover = {
    Show-ToolTip -Title "View Results" -Icon "Info" -Message @"
+  Utilizes Out-GridView to view the results.
+  Out-GridView is native to PowerShell, lightweight, and fast.
+  Results can be easily filtered with conditional statements.
+  Collected data from is primarily saved as CSVs, so they can
    be opened with Excel or similar products.
+  Multiple lines can be selected and added to OpNotes.
    The selection can be contiguous by using the Shift key
    and/or be separate using the Ctrl key, the press OK.
"@
}


