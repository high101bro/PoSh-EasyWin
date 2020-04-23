Function Save-ComputerTreeNodeHostData {
    $ComputerTreeNodeSaveData = @()
    Foreach($Computer in $script:ComputerTreeViewData) {
        $ComputerTreeNodeSaveDataTemp = New-Object PSObject -Property @{ Name = $Computer.Name}        
        $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name OperatingSystem -Value $Computer.OperatingSystem -Force        
        $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name CanonicalName   -Value $Computer.CanonicalName -Force        
        # If the node is selected, it will save the values you enter
        if ($Computer.Name -eq $Section3HostDataNameTextBox.Text) {
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name IPv4Address -Value $Section3HostDataIPTextBox.Text -Force
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name MACAddress  -Value $Section3HostDataMACTextBox.Text -Force
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Notes       -Value $Section3HostDataNotesTextBox.Text -Force }
        # Else, if the node is not selected, it will retain what was saved
        else {
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name IPv4Address -Value $Computer.IPv4Address -Force
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name MACAddress  -Value $Computer.MACAddress -Force           
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Notes       -Value $Computer.Notes -Force }
        $ComputerTreeNodeSaveData += $ComputerTreeNodeSaveDataTemp
    }
    $script:ComputerTreeViewData  = $ComputerTreeNodeSaveData
    $ComputerTreeNodeSaveDataTemp = $null
    $ComputerTreeNodeSaveData     = $null
  
    $script:Section3HostDataNotesSaveCheck = $Section3HostDataNotesTextBox.Text
    Check-HostDataIfModified

    # Saves the TreeView Data to File
    $script:ComputerTreeViewData | Export-Csv $ComputerTreeNodeFileSave -NoTypeInformation -Force    
}