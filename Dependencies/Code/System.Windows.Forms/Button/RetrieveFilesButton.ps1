$RetrieveFilesButtonAdd_Click = {
    $InformationTabControl.SelectedTab = $Section3ResultsTab
    try {
#       [System.Reflection.Assembly]::LoadWithPartialName("System .Windows.Forms") | Out-Null
        $RetrieveFileOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{
            Title            = "Select A File Search CSV File"
            InitialDirectory = "$(if (Test-Path $($script:CollectionSavedDirectoryTextBox.Text)) {$($script:CollectionSavedDirectoryTextBox.Text)} else {$CollectedDataDirectory})"
            Filter           = "CSV (*.csv)|*.csv|All files (*.*)|*.*"
            ShowHelp         = $true
        }
        $RetrieveFileOpenFileDialog.ShowDialog() | Out-Null
        $DownloadFilesFrom = Import-Csv $($RetrieveFileOpenFileDialog.filename)
        $StatuListBox.Items.Clear()
        $StatusListBox.Items.Add("Retrieve Files")
    }
    catch{}

    $SelectedFilesToDownload = $null
    $SelectedFilesToDownload = $DownloadFilesFrom | Select-Object ComputerName, Name, FullName, CreationTime, LastAccessTime, LastWriteTime, Length, Attributes, VersionInfo, * -ErrorAction SilentlyContinue

    Get-RemoteFile -Files $SelectedFilesToDownload

    Remove-Variable -Name SelectedFilesToDownload
}

$RetrieveFilesButtonAdd_MouseHover = {
    Show-ToolTip -Title "Retrieve Files" -Icon "Info" -Message @"
+  Use the File Search query section to search for files or obtain directory
    listings, then open the results here to be able to download multple files
    from multiple endpoints.
+  To use this feature, first query for files and select then from the following:
    - Directory Listing.csv
    - File Search.csv
+  Requires WinRM Service
"@
}


