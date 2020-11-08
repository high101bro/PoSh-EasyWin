function Post-MonitorJobs {
    param(
        $ExecutionStartTime,
        $CollectionName
    )
    $CollectionCommandEndTime  = Get-Date
    $CollectionCommandDiffTime = New-TimeSpan -Start $ExecutionStartTime -End $CollectionCommandEndTime
    $ResultsListBox.Items.RemoveAt(0)
    $ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $CollectionName")

    Compile-CsvFiles -LocationOfCSVsToCompile "$($script:CollectionSavedDirectoryTextBox.Text)\Results By Endpoints\$($CollectionName)\$($CollectionName)*.csv" `
                    -LocationToSaveCompiledCSV "$($script:CollectionSavedDirectoryTextBox.Text)\$($CollectionName).csv"

    Compile-XmlFiles -LocationOfXmlsToCompile "$($script:CollectionSavedDirectoryTextBox.Text)\Results By Endpoints\$($CollectionName)\$($CollectionName)*.xml" `
                    -LocationToSaveCompiledXml "$($script:CollectionSavedDirectoryTextBox.Text)\$($CollectionName).xml"

    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Compilied CSV Files"
    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Compilied XML Data"
}



