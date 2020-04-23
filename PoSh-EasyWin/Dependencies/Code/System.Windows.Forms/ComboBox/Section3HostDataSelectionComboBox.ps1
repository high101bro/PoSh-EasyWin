$HostDataList1 = @(
    "Host Data - Selection",
    "Accounts (Local Users)",
    "Anti Virus Product",
    "Audit Policy",
    "BIOS Info",
    "Date Info",
    "Disk - Logical Info",
    "Disk - Physical Info",
    "DNS Cache",
    "Drivers",
    "Environmental Variables",
    "Firewall Port Proxy",
    "Firewall Rules",
    "Firewall Status",
    "Groups (Local)",
    "Host Files",
    "Logical Drives Mapped",
    "Logon Info",
    "Logon User Status",
    "Memory (Capacity Info)",
    "Motherboard Info",
    "Network Connections TCP",
    "Network Connections UDP",
    "Network Settings",
    "Plug and Play Devices",
    "Printers Mapped",
    "Processes",
    "Processor (CPU Info)",
    "Scheduled Tasks",
    "Security Patches",
    "Services",
    "Sessions",
    "Shares",
    "Software Installed",
    "Startup Commands"
    "System Info",
    "USB Controller Devices",
    "Windows Defender (Malware Detected)"
)

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
        # Searches though the all Collection Data Directories to find files that match
        $ListOfCollectedDataDirectories = $(Get-ChildItem -Path $CollectedDataDirectory | Sort-Object -Descending).FullName
        $script:CSVFileMatch = @()
        foreach ($CollectionDir in $ListOfCollectedDataDirectories) {
            $CSVFiles = $(Get-ChildItem -Path $CollectionDir -Recurse).FullName
            foreach ($CSVFile in $CSVFiles) {
                # Searches for the CSV file that matches the data selected
                if (($CSVFile -match $Section3HostDataSelectionComboBox.SelectedItem) -and ($CSVFile -match $Section3HostDataNameTextBox.Text)) {
                    $HostDataCsvFile = Import-CSV -Path $CSVFile
                    # Searches for the Hostname in the CsvFile, if present that file will be used for viewing
                    if ($HostDataCsvFile.PSComputerName -eq $Section3HostDataNameTextBox.Text) {
                        $script:CSVFileMatch += "$CSVFile"
                        break
                    }
                }
            }
        }
    }

    function Get-HostDataCsvDateTime {
        $script:HostDataCsvDateTime = @()
        foreach ($Csv in $script:CSVFileMatch) {
            $DirDateTime = $Csv.split('\')[-4]
            $script:HostDataCsvDateTime += $DirDateTime
            $script:HostDataCsvPath = $Csv.split('\')[-3,-2] -join '\'
        }
    }                               

    Get-HostDataCsvResults $Section3HostDataSelectionComboBox.SelectedItem
    if ($($script:CSVFileMatch).count -eq 0) {$script:HostDataCsvDateTime = @('No Data Available')}
    else {Get-HostDataCsvDateTime}
    $Section3HostDataSelectionDateTimeComboBox.DataSource = $script:HostDataCsvDateTime
}
