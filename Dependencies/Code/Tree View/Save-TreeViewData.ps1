Function Save-TreeViewData {
    param(
        [switch]$Accounts,
        [switch]$Endpoint,
        [switch]$SaveAllChecked,
        [switch]$SaveScan,
        [string[]]$Ports,
        [string[]]$Endpoints
    )
    if ($Accounts) {
        $AccountsTreeNodeSaveData = @()
        Foreach($AccountsData in $script:AccountsTreeViewData) {
            $AccountsTreeNodeSaveDataTemp = New-Object PSObject -Property @{ Name = $AccountsData.Name}
            $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Enabled -Value $AccountsData.Enabled -Force
            $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name CanonicalName   -Value $AccountsData.CanonicalName -Force

            # If the node is selected, it will save the values you enter
            if ($AccountsData.Name -eq $script:Section3AccountsDataNameTextBox.Text) {
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name LockedOut              -Value $AccountsData.LockedOut -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name SmartCardLogonRequired -Value $AccountsData.SmartCardLogonRequired -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Created                -Value $AccountsData.Created -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Modified               -Value $AccountsData.Modified -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name LastLogonDate          -Value $AccountsData.LastLogonDate -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name LastBadPasswordAttempt -Value $AccountsData.LastBadPasswordAttempt -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name BadLogonCount          -Value $AccountsData.BadLogonCount -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name PasswordExpired        -Value $AccountsData.PasswordExpired -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name PasswordNeverExpires   -Value $AccountsData.PasswordNeverExpires -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name PasswordNotRequired    -Value $AccountsData.PasswordNotRequired -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name MemberOf               -Value $AccountsData.MemberOf -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name SID                    -Value $AccountsData.SID -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name ScriptPath             -Value $AccountsData.ScriptPath -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name HomeDrive              -Value $AccountsData.HomeDrive -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Notes                  -Value $AccountsData.Notes -Force
            }
            # Else, if the node is not selected, it will retain what was saved
            else {
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name LockedOut              -Value $AccountsData.LockedOut -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name SmartCardLogonRequired -Value $AccountsData.SmartCardLogonRequired -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Created                -Value $AccountsData.Created -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Modified               -Value $AccountsData.Modified -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name LastLogonDate          -Value $AccountsData.LastLogonDate -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name LastBadPasswordAttempt -Value $AccountsData.LastBadPasswordAttempt -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name BadLogonCount          -Value $AccountsData.BadLogonCount -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name PasswordExpired        -Value $AccountsData.PasswordExpired -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name PasswordNeverExpires   -Value $AccountsData.PasswordNeverExpires -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name PasswordNotRequired    -Value $AccountsData.PasswordNotRequired -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name MemberOf               -Value $AccountsData.MemberOf -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name SID                    -Value $AccountsData.SID -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name ScriptPath             -Value $AccountsData.ScriptPath -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name HomeDrive              -Value $AccountsData.HomeDrive -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Notes                  -Value $AccountsData.Notes -Force
            }
            $AccountsTreeNodeSaveData += $AccountsTreeNodeSaveDataTemp
        }
        $script:AccountsTreeViewData  = $AccountsTreeNodeSaveData
        $AccountsTreeNodeSaveDataTemp = $null
        $AccountsTreeNodeSaveData     = $null
 
        $script:Section3AccountsDataNotesSaveCheck = $Section3AccountsDataNotesRichTextBox.Text
        #Check-HostDataIfModified

        # Saves the TreeView Data to File
        $script:AccountsTreeViewData | Export-Csv $script:AccountsTreeNodeFileSave -NoTypeInformation -Force
    }


    if ($Endpoint) {
        $ComputerTreeNodeSaveData = @()
        Foreach($Computer in $script:ComputerTreeViewData) {
            $ComputerTreeNodeSaveDataTemp = New-Object PSObject -Property @{ Name = $Computer.Name}
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name OperatingSystem                 -Value $Computer.OperatingSystem -Force
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name CanonicalName                   -Value $Computer.CanonicalName -Force
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name OperatingSystemHotfix           -Value $Computer.OperatingSystemHotfix -Force
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name OperatingSystemServicePack      -Value $Computer.OperatingSystemServicePack -Force
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Enabled                         -Value $Computer.Enabled -Force
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name LockedOut                       -Value $Computer.LockedOut -Force
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name LogonCount                      -Value $Computer.LogonCount -Force
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Created                         -Value $Computer.Created -Force
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Modified                        -Value $Computer.Modified -Force
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name LastLogonDate                   -Value $Computer.LastLogonDate -Force
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name IPv4Address                     -Value $Computer.IPv4Address -Force
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name MACAddress                      -Value $Computer.MACAddress -Force
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name MemberOf                        -Value $Computer.MemberOf -Force
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name isCriticalSystemObject          -Value $Computer.isCriticalSystemObject -Force
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name HomedirRequired                 -Value $Computer.HomedirRequired -Force
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Location                        -Value $Computer.Location -Force
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name ProtectedFromAccidentalDeletion -Value $Computer.ProtectedFromAccidentalDeletion -Force
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name TrustedForDelegation            -Value $Computer.TrustedForDelegation -Force
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name SID                             -Value $Computer.SID -Force

            if ($SaveScan){
                # If the node is selected, it will save the values you enter
                if ($Computer.Name -in $Endpoints) {
                    $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name IPv4Address -Value $Computer.IPv4Address -Force
                    $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name MACAddress  -Value $Computer.MACAddress -Force
                    $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name PortScan    -Value "$($Ports -join',')" -Force
                    $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Notes       -Value $Computer.Notes -Force
                }
                # Else, if the node is not selected, it will retain what was saved
                else {
                    $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name IPv4Address -Value $Computer.IPv4Address -Force
                    $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name MACAddress  -Value $Computer.MACAddress -Force
                    $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name PortScan    -Value $Computer.PortScan -Force
                    $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Notes       -Value $Computer.Notes -Force
                }
                $ComputerTreeNodeSaveData += $ComputerTreeNodeSaveDataTemp
            }
            ### Those that are checked, used in the context menu
            elseif ($SaveAllChecked) {
                # If the node is selected, it will save the values you enter
                if ($Computer.Name -in $script:ComputerTreeViewSelected) {
                    $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name IPv4Address -Value $Section3HostDataIPTextBox.Text -Force
                    $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name MACAddress  -Value $Section3HostDataMACTextBox.Text -Force
                    $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name PortScan    -Value $Computer.PortScan -Force
                    $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Notes       -Value $Section3HostDataNotesRichTextBox.Text -Force
                }
                # Else, if the node is not selected, it will retain what was saved
                else {
                    $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name IPv4Address -Value $Computer.IPv4Address -Force
                    $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name MACAddress  -Value $Computer.MACAddress -Force
                    $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name PortScan    -Value $Computer.PortScan -Force
                    $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Notes       -Value $Computer.Notes -Force
                }
                $ComputerTreeNodeSaveData += $ComputerTreeNodeSaveDataTemp
            }
            ### Saves just that selected
            else {
                # If the node is selected, it will save the values you enter
                if ($Computer.Name -eq $script:Section3HostDataNameTextBox.Text) {
                    $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name IPv4Address -Value $Section3HostDataIPTextBox.Text -Force
                    $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name MACAddress  -Value $Section3HostDataMACTextBox.Text -Force
                    $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name PortScan    -Value $Computer.PortScan -Force
                    $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Notes       -Value $Section3HostDataNotesRichTextBox.Text -Force
                }
                # Else, if the node is not selected, it will retain what was saved
                else {
                    $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name IPv4Address -Value $Computer.IPv4Address -Force
                    $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name MACAddress  -Value $Computer.MACAddress -Force
                    $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name PortScan    -Value $Computer.PortScan -Force
                    $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Notes       -Value $Computer.Notes -Force
                }
                $ComputerTreeNodeSaveData += $ComputerTreeNodeSaveDataTemp
            }
        }
        $script:ComputerTreeViewData  = $ComputerTreeNodeSaveData
        $ComputerTreeNodeSaveDataTemp = $null
        $ComputerTreeNodeSaveData     = $null

        $script:Section3HostDataNotesSaveCheck = $Section3HostDataNotesRichTextBox.Text
        Check-HostDataIfModified

        # Saves the TreeView Data to File
        $script:ComputerTreeViewData | Export-Csv $script:EndpointTreeNodeFileSave -NoTypeInformation -Force
    }
}

