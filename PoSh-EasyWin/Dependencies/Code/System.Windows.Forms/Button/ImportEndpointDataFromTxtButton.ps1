$ImportEndpointDataFromTxtButtonAdd_Click = {
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    $ComputerTreeNodeImportTxtOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{
        Title            = "Import .txt Data"
        InitialDirectory = "$PoShHome"
        filter           = "TXT (*.txt)| *.txt|All files (*.*)|*.*"
        ShowHelp         = $true
    }
    $ComputerTreeNodeImportTxtOpenFileDialog.ShowDialog() | Out-Null
    $ComputerTreeNodeImportTxt = Get-Content $($ComputerTreeNodeImportTxtOpenFileDialog.filename)

    $StatusListBox.Items.Clear()
    #Removed For Testing#$ResultsListBox.Items.Clear()

    foreach ($Computer in $($ComputerTreeNodeImportTxt | Where-Object {$_ -ne ''}) ) {
        # Checks if the data already exists
        if ($script:ComputerTreeViewData.Name -contains $Computer) {
            Message-HostAlreadyExists -Message "Import .CSV:  Warning" -Computer $Computer -ResultsListBoxMessage
        }
        else {
            if ($ComputerTreeNodeOSHostnameRadioButton.Checked -and $Computer -ne "") {
                Add-NodeComputer -RootNode $script:TreeNodeComputerList -Category 'Unknown' -Entry $Computer -ToolTip 'N/A'
            }
            elseif ($ComputerTreeNodeOUHostnameRadioButton.Checked -and $Computer -ne "") {
                Add-NodeComputer -RootNode $script:TreeNodeComputerList -Category '/Unknown' -Entry $Computer -ToolTip 'N/A'
            }
            $script:ComputerTreeViewData += [PSCustomObject]@{
                Name            = $Computer
                OperatingSystem = 'Unknown'
                CanonicalName   = '/Unknown'
                IPv4Address     = 'N/A'
                MACAddress      = 'N/A'
            }
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



$ImportEndpointDataFromTxtButtonAdd_MouseHover = {
    Show-ToolTip -Title "Import From TXT File" -Icon "Info" -Message @"
+  Imports data from a selected Text file
+  Useful if you recieve a computer list file from an Admin or outputted from nmap
+  This file should be formatted with one hostname or IP address per line
"@
}





