$FileSearchAlternateDataStreamDirectoryExtractStreamDataButtonAdd_Click = {
    try {
#       [System.Reflection.Assembly]::LoadWithPartialName("System .Windows.Forms") | Out-Null
        $ExtractStreamDataOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{
            Title            = "Select An Alternate Data Stream CSV File"
            InitialDirectory = "$(if (Test-Path $($script:CollectionSavedDirectoryTextBox.Text)) {$($script:CollectionSavedDirectoryTextBox.Text)} else {$CollectedDataDirectory})"
            Filter           = "CSV (*.csv)|*.csv|All files (*.*)|*.*"
            ShowHelp         = $true
        }
        $ExtractStreamDataOpenFileDialog.ShowDialog() | Out-Null
        $ExtractStreamDataFrom = Import-Csv $($ExtractStreamDataOpenFileDialog.FileName)
        $StatuListBox.Items.Clear()
        $StatusListBox.Items.Add("Retrieve & Extract Alternate Data Stream")
    }
    catch{}

    $SelectedFilesToExtractStreamData = $null
    $SelectedFilesToExtractStreamData = $ExtractStreamDataFrom | Out-GridView -Title 'Retrieve & Extract Alternate Data Stream' -PassThru

    Get-RemoteAlternateDataStream -Files $SelectedFilesToExtractStreamData

    Remove-Variable -Name SelectedFilesToExtractStreamData
}


