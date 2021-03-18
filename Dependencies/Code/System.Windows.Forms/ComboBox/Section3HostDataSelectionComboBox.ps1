$Section3HostDataSelectionComboBoxAdd_MouseHover = {
    Show-ToolTip -Title "Select Search Topic" -Icon "Info" -Message @"
+  If data exists, the datetime group will be displayed below.
+  These files can be searchable, toggle in Options Tab.
+  Note: Datetimes with more than one collection type won't
display, these results will need to be navigated to manually.
"@
}

$Section3HostDataSelectionComboBoxAdd_SelectedIndexChanged = {
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


