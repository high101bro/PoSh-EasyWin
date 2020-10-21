$ImportEndpointDataFromCsvButtonAdd_Click = {
    $MainBottomTabControl.SelectedTab = $Section3ResultsTab

    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    $ComputerTreeNodeImportCsvOpenFileDialog                  = New-Object System.Windows.Forms.OpenFileDialog -Property @{
        Title            = "Import .csv Data"
        InitialDirectory = "$PoShHome"
        filter           = "CSV (*.csv)| *.csv|Excel (*.xlsx)| *.xlsx|Excel (*.xls)| *.xls|All files (*.*)|*.*"
        ShowHelp         = $true
    }
    $ComputerTreeNodeImportCsvOpenFileDialog.ShowDialog() | Out-Null
    $ComputerTreeNodeImportCsv = Import-Csv $($ComputerTreeNodeImportCsvOpenFileDialog.filename) | Select-Object -Property Name, IPv4Address, MACAddress, OperatingSystem, CanonicalName | Sort-Object -Property CanonicalName

    $StatusListBox.Items.Clear()
    #Removed For Testing#$ResultsListBox.Items.Clear()

    # Imports data
    foreach ($Computer in $ComputerTreeNodeImportCsv) {
        # Checks if data already exists
        if ($script:ComputerTreeViewData.Name -contains $Computer.Name) {
            Message-HostAlreadyExists -Message "Import .CSV:  Warning" -Computer $Computer.Name -ResultsListBoxMessage
        }
        else {
            if ($ComputerTreeNodeOSHostnameRadioButton.Checked) {
                if ($Computer.OperatingSystem -eq "") { Add-NodeComputer -RootNode $script:TreeNodeComputerList -Category 'Unknown' -Entry $Computer.Name -ToolTip $Computer.IPv4Address }
                else { Add-NodeComputer -RootNode $script:TreeNodeComputerList -Category $Computer.OperatingSystem -Entry $Computer.Name -ToolTip $Computer.IPv4Address }
            }
            elseif ($ComputerTreeNodeOUHostnameRadioButton.Checked) {
                $CanonicalName = $($($Computer.CanonicalName) -replace $Computer.Name,"" -replace $Computer.CanonicalName.split('/')[0],"").TrimEnd("/")
                if ($Computer.CanonicalName -eq "") { Add-NodeComputer -RootNode $script:TreeNodeComputerList -Category '/Unknown' -Entry $Computer.Name -ToolTip $Computer.IPv4Address }
                else { Add-NodeComputer -RootNode $script:TreeNodeComputerList -Category $CanonicalName -Entry $Computer.Name -ToolTip $Computer.IPv4Address }
            }
            $script:ComputerTreeViewData += $Computer

            $script:ComputerTreeView.Nodes.Clear()
            Initialize-ComputerTreeNodes
            Update-TreeNodeComputerState -NoMessage
            Populate-ComputerTreeNodeDefaultData
            Foreach($Computer in $script:ComputerTreeViewData) { Add-NodeComputer -RootNode $script:TreeNodeComputerList -Category $Computer.CanonicalName -Entry $Computer.Name -ToolTip $Computer.IPv4Address }
            $script:ComputerTreeView.ExpandAll()
        }
    }
    AutoSave-HostData
    Update-NeedToSaveTreeView
}


$ImportEndpointDataFromCsvButtonAdd_MouseHover = {
    Show-ToolTip -Title "Import From CSV File" -Icon "Info" -Message @"
+  Imports data from a selected Comma Separated Value file
+  This file can be easily generated with the following command:
     - Get-ADComputer -Filter * -Properties Name,OperatingSystem,CanonicalName,IPv4Address,MACAddress | Export-Csv "Domain Computers.csv"
+  This file should be formatted with the following headers, though the import script should populate default missing data:
     - Name
     - OperatingSystem
     - CanonicalName
     - IPv4Address
     - MACAddress
     - Notes
"@
}





