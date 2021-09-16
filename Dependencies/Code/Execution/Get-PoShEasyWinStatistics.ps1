function Get-PoShEasyWinStatistics {
    Compile-SelectedCommandTreeNode
    $QueryCount = $script:SectionQueryCount + $script:CommandsCheckedBoxesSelected.count

    $StatisticsResults             = ""
    $StatisticsAllCSVFiles         = Get-Childitem -Path $CollectedDataDirectory -Recurse -Include "*.csv"
    $StatisticsAllCSVFilesMeasured = $StatisticsAllCSVFiles | Measure-Object -Property Length -Sum -Average -Maximum -Minimum

    $StatisticsResults += "$('{0,-25}{1}' -f "Number of CSV files:", $($StatisticsAllCSVFilesMeasured.Count))`r`n"

    $StatisticsFirstCollection = $($StatisticsAllCSVFiles | Sort-Object -Property CreationTime | Select-Object -First 1).CreationTime
    $StatisticsResults += "$('{0,-25}{1}' -f "First query datetime:", $StatisticsFirstCollection)`r`n"

    $StatisticsLatestCollection = $($StatisticsAllCSVFiles | Sort-Object -Property CreationTime | Select-Object -Last 1).CreationTime
    $StatisticsResults += "$('{0,-25}{1}' -f "Latest query datetime:", $StatisticsLatestCollection)`r`n"

    $StatisticsAllCSVFilesSum = $(
        $CSVBytes = $StatisticsAllCSVFilesMeasured.Sum
        if ($CSVBytes -gt 1GB) {"{0:N3} GB" -f $($CSVBytes / 1GB)}
        elseif ($CSVBytes -gt 1MB) {"{0:N3} MB" -f $($CSVBytes / 1MB)}
        elseif ($CSVBytes -gt 1KB) {"{0:N3} KB" -f $($CSVBytes / 1KB)}
        else {"{0:N3} Bytes" -f $CSVBytes}
    )
    $StatisticsResults += "$('{0,-25}{1}' -f "Total CSV Data:", $StatisticsAllCSVFilesSum)`r`n"

    $StatisticsAllCSVFilesAverage = $(
        $CSVBytes = $StatisticsAllCSVFilesMeasured.Average
        if ($CSVBytes -gt 1GB) {"{0:N3} GB" -f $($CSVBytes / 1GB)}
        elseif ($CSVBytes -gt 1MB) {"{0:N3} MB" -f $($CSVBytes / 1MB)}
        elseif ($CSVBytes -gt 1KB) {"{0:N3} KB" -f $($CSVBytes / 1KB)}
        else {"{0:N3} Bytes" -f $CSVBytes}
    )
    $StatisticsResults += "$('{0,-25}{1}' -f "Average CSV filesize:", $StatisticsAllCSVFilesAverage)`r`n"

    $StatisticsAllCSVFilesMaximum = $(
        $CSVBytes = $StatisticsAllCSVFilesMeasured.Maximum
        if ($CSVBytes -gt 1GB) {"{0:N3} GB" -f $($CSVBytes / 1GB)}
        elseif ($CSVBytes -gt 1MB) {"{0:N3} MB" -f $($CSVBytes / 1MB)}
        elseif ($CSVBytes -gt 1KB) {"{0:N3} KB" -f $($CSVBytes / 1KB)}
        else {"{0:N3} Bytes" -f $CSVBytes}
    )
    $StatisticsResults += "$('{0,-25}{1}' -f "Largest CSV filesize:", $StatisticsAllCSVFilesMaximum)`r`n"

    $StatisticsAllCSVFilesMinimum = $(
        $CSVBytes = $StatisticsAllCSVFilesMeasured.Minimum
        if ($CSVBytes -gt 1GB) {"{0:N3} GB" -f $($CSVBytes / 1GB)}
        elseif ($CSVBytes -gt 1MB) {"{0:N3} MB" -f $($CSVBytes / 1MB)}
        elseif ($CSVBytes -gt 1KB) {"{0:N3} KB" -f $($CSVBytes / 1KB)}
        else {"{0:N3} Bytes" -f $CSVBytes}
    )
    $StatisticsResults += "$('{0,-25}{1}' -f "Smallest CSV filesize:", $StatisticsAllCSVFilesMinimum)`r`n"

    $StatisticsResults += "`r`n"
    $StatisticsLogFile = Get-ItemProperty -Path $Logfile

    $NumberOfLogEntries = (get-content -path $logfile | Select-String -Pattern '\d{4}/\d{2}/\d{2} \d{2}[:]\d{2}[:]\d{2} [-] ').count
    $StatisticsResults += "$('{0,-25}{1}' -f "Number of Log Entries:", $NumberOfLogEntries)`r`n"

    $StatisticsLogFileSize = $(
        $LogFileSize = $StatisticsLogFile.Length
        if ($LogFileSize -gt 1GB) {"{0:N3} GB" -f $($LogFileSize / 1GB)}
        elseif ($LogFileSize -gt 1MB) {"{0:N3} MB" -f $($LogFileSize / 1MB)}
        elseif ($LogFileSize -gt 1KB) {"{0:N3} KB" -f $($LogFileSize / 1KB)}
        else {"{0:N3} Bytes" -f $LogFileSize}
    )
    $StatisticsResults += "$('{0,-25}{1}' -f "Logfile filesize:", $StatisticsLogFileSize)`r`n"

    $StatisticsResults += "`r`n"
    $StatisticsComputerCount = 0
    [System.Windows.Forms.TreeNodeCollection]$StatisticsAllHostsNode = $script:ComputerTreeView.Nodes
    foreach ($root in $StatisticsAllHostsNode) {foreach ($Category in $root.Nodes) {foreach ($Entry in $Category.nodes) {if ($Entry.Checked) { $StatisticsComputerCount++ }}}}
    $StatisticsResults += "$('{0,-25}{1}' -f "Computers Selected:", $StatisticsComputerCount)`r`n"
    $StatisticsResults += "$('{0,-25}{1}' -f "Queries Selected:", $QueryCount)`r`n"

    $ResourcesDirCheck = Test-Path -Path "$Dependencies"
    $StatisticsResults += "$('{0,-25}{1}' -f "Dependancies Check:", $ResourcesDirCheck)`r`n"

    return $StatisticsResults
}

