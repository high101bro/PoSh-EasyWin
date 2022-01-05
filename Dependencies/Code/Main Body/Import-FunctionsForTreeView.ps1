Update-FormProgress "Normalize-TreeViewData"
function Normalize-TreeViewData {
    <#
        .Description
        If Computer treenodes are imported/created with missing data, this populates various fields with default data
    #>
    param(
        [switch]$Accounts,
        [switch]$Endpoint
    )
    if ($Accounts) {
        # This section populates the data with default data if it doesn't have any
        $script:AccountsTreeViewDataTemp = @()

        Foreach($Account in $script:AccountsTreeViewData) {
            # Trims out the domain name from the the CanonicalName
            $CanonicalName = $($($Account.CanonicalName) -replace $Account.Name,"" -replace $Account.CanonicalName.split('/')[0],"").TrimEnd("/")

            $AccountsTreeNodeInsertDefaultData = New-Object PSObject -Property @{ Name = $Account.Name}


            if ($Account.Enabled -eq $true -or $Account.Enabled -eq $false) {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name Enabled -Value $Account.Enabled -Force }
            else {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name Enabled -Value "Unknown Status" -Force }

            if ($Account.CanonicalName) {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name CanonicalName -Value $CanonicalName -Force }
            else {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name CanonicalName -Value "/Unknown OU" -Force }

            if ($Account.LockedOut -eq $true -or $Account.LockedOut -eq $false) {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name LockedOut -Value $Account.LockedOut -Force }
            else {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name LockedOut -Value "Unknown Status" -Force }

            if ($Account.SmartCardLogonRequired -eq $true -or $Account.SmartCardLogonRequired -eq $false) {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name SmartCardLogonRequired -Value $Account.SmartCardLogonRequired -Force }
            else {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name SmartCardLogonRequired -Value "Unknown Status" -Force }

            if ($Account.Created) {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name Created -Value $Account.Created -Force }
            else {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name Created -Value "No TimeStamp" -Force }

            if ($Account.Modified) {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name Modified -Value $Account.Modified -Force }
            else {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name Modified -Value "No TimeStamp" -Force }

            if ($Account.LastLogonDate) {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name LastLogonDate -Value $Account.LastLogonDate -Force }
            else {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name LastLogonDate -Value "No TimeStamp" -Force }

            if ($Account.LastBadPasswordAttempt) {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name LastBadPasswordAttempt -Value $Account.LastBadPasswordAttempt -Force }
            else {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name LastBadPasswordAttempt -Value "No TimeStamp" -Force }

            if ($Account.BadLogonCount) {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name BadLogonCount -Value $Account.BadLogonCount -Force }
            else {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name BadLogonCount -Value "0" -Force }

            if ($Account.PasswordExpired -eq $true -or $Account.PasswordExpired -eq $false) {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name PasswordExpired -Value $Account.PasswordExpired -Force }
            else {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name PasswordExpired -Value "Unknown Status" -Force }

            if ($Account.PasswordNeverExpires -eq $true -or $Account.PasswordNeverExpires -eq $false) {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name PasswordNeverExpires -Value $Account.PasswordNeverExpires -Force }
            else {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name PasswordNeverExpires -Value "Unknown Status" -Force }

            if ($Account.PasswordNotRequired -eq $true -or $Account.PasswordNotRequired -eq $false) {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name PasswordNotRequired -Value $Account.PasswordNotRequired -Force }
            else {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name PasswordNotRequired -Value "Unknown Status" -Force }

            if ($Account.MemberOf) {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name MemberOf -Value $Account.MemberOf -Force }
            # Note: removed, it produced a false group count of 1... it counted "No Group" as a group...
            # else {
            #     $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name MemberOf -Value "No Group" -Force }

            if ($Account.SID) {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name SID -Value $Account.SID -Force }
            else {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name SID -Value "Unknown SID" -Force }

            if ($Account.ScriptPath) {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name ScriptPath -Value $Account.ScriptPath -Force }
            else {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name ScriptPath -Value "No Script Path" -Force }

            if ($Account.HomeDrive) {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name HomeDrive -Value $Account.HomeDrive -Force }
            else {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name HomeDrive -Value "No Home Drive" -Force }

            if ($Account.Notes) {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name Notes -Value $Account.Notes -Force }
            else {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name Notes -Value $null -Force }

            if ($Account.ImageIndex) {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name ImageIndex -Value $Account.ImageIndex -Force }
            else {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name ImageIndex -Value 2 -Force }
            $script:AccountsTreeViewDataTemp += $AccountsTreeNodeInsertDefaultData

            ###write-host $($AccountsTreeNodeInsertDefaultData | Select Name, OperatingSystem, CanonicalName, IPv4Address, Notes)
        }
        $script:AccountsTreeViewData       = $script:AccountsTreeViewDataTemp
        $script:AccountsTreeViewDataTemp   = $null
        $AccountsTreeNodeInsertDefaultData = $null
    }


    if ($Endpoint) {
        # This section populates the data with default data if it doesn't have any
        $script:ComputerTreeViewDataTemp = @()
        Foreach($Computer in $script:ComputerTreeViewData) {
            # Trims out the domain name from the the CanonicalName
            $CanonicalName = $($($Computer.CanonicalName) -replace $Computer.Name,"" -replace $Computer.CanonicalName.split('/')[0],"").TrimEnd("/")


            $ComputerTreeNodeInsertDefaultData = New-Object PSObject -Property @{ Name = $Computer.Name}
            if ($Computer.OperatingSystem) {
                $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name OperatingSystem -Value $Computer.OperatingSystem -Force }
            else {
                $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name OperatingSystem -Value "Unknown OS" -Force }

            if ($Computer.CanonicalName) {
                $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name CanonicalName -Value $CanonicalName -Force }
            else {
                $ComputerTreeNodeInsertDefaultDat0a | Add-Member -MemberType NoteProperty -Name CanonicalName -Value "/Unknown OU" -Force }

            if ($Computer.IPv4Address) {
                $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name IPv4Address -Value $Computer.IPv4Address -Force }
            else {
                $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name IPv4Address -Value "No IP Available" -Force }

            if ($Computer.MACAddress) {
                $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name MACAddress -Value $Computer.MACAddress -Force }
            else {
                $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name MACAddress -Value "No MAC Available" -Force }

            if ($Computer.PortScan) {
                $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name PortScan -Value $Computer.PortScan -Force }
            # Note: removed, it produced a false group count of 1... it counted "No Ports" as a group...
            # else {
            #    $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name PortScan -Value "No Ports" -Force }

            if ($Computer.Notes) {
                $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name Notes -Value $Computer.Notes -Force }
            # else {
            #     $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name Notes -Value "No Notes Available" -Force }

            if ($Computer.OperatingSystemHotfix) {
                $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name OperatingSystemHotfix -Value $Computer.OperatingSystemHotfix -Force }
            # Note: removed, it produced a false group count of 1... it counted "No OS Hotfixes" as a group...
            # else {
            #     $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name OperatingSystemHotfix -Value "No OS Hotfixes" -Force }

            if ($Computer.OperatingSystemServicePack) {
                $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name OperatingSystemServicePack -Value $Computer.OperatingSystemServicePack -Force }
            # Note: removed, it produced a false group count of 1... it counted "No OS Service Packs" as a group...
            # else {
            #     $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name OperatingSystemServicePack -Value "No OS Service Packs" -Force }

            if ($Computer.Enabled) {
                $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name Enabled -Value $Computer.Enabled -Force }
            elseif ($Computer.Enabled -eq $false) {
                $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name Enabled -Value $Computer.Enabled -Force }
            else {
                $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name Enabled -Value "Unknown Status" -Force }

            if ($Computer.LockedOut) {
                $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name LockedOut -Value $Computer.LockedOut -Force }
            elseif ($Computer.LockedOut -eq $false) {
                $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name LockedOut -Value $Computer.LockedOut -Force }
            else {
                $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name LockedOut -Value "Unknown Status" -Force }

            if ($Computer.LogonCount) {
                $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name LogonCount -Value $Computer.LogonCount -Force }
            else {
                $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name LogonCount -Value "0" -Force }

            if ($Computer.Created) {
                $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name Created -Value $Computer.Created -Force }
            else {
                $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name Created -Value "No Creation Time" -Force }

            if ($Computer.Modified) {
                $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name Modified -Value $Computer.Modified -Force }
            else {
                $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name Modified -Value "No Modification Time" -Force }

            if ($Computer.LastLogonDate) {
                $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name LastLogonDate -Value $Computer.LastLogonDate -Force }
            else {
                $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name LastLogonDate -Value "No Last Logon Date" -Force }

            if ($Computer.MemberOf) {
                $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name MemberOf -Value $Computer.MemberOf -Force }
            # Note: removed, it produced a false group count of 1... it counted "No Group" as a group...
            # else {
            #     $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name MemberOf -Value "No Groups" -Force }

            if ($Computer.isCriticalSystemObject) {
                $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name isCriticalSystemObject -Value $Computer.isCriticalSystemObject -Force }
            elseif ($Computer.isCriticalSystemObject -eq $false) {
                $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name isCriticalSystemObject -Value $Computer.isCriticalSystemObject -Force }
            else {
                $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name isCriticalSystemObject -Value "Unknown Status" -Force }

            if ($Computer.HomedirRequired) {
                $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name HomedirRequired -Value $Computer.HomedirRequired -Force }
            else {
                $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name HomedirRequired -Value "No Home Dir Required" -Force }

            if ($Computer.Location) {
                $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name Location -Value $Computer.Location -Force }
            else {
                $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name Location -Value "No Location" -Force }

            if ($Computer.ProtectedFromAccidentalDeletion) {
                $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name ProtectedFromAccidentalDeletion -Value $Computer.ProtectedFromAccidentalDeletion -Force }
            elseif ($Computer.ProtectedFromAccidentalDeletion -eq $false) {
                $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name ProtectedFromAccidentalDeletion -Value $Computer.ProtectedFromAccidentalDeletion -Force }
            else {
                $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name ProtectedFromAccidentalDeletion -Value "Unknown Status" -Force }

            if ($Computer.TrustedForDelegation) {
                $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name TrustedForDelegation -Value $Computer.TrustedForDelegation -Force }
            elseif ($Computer.TrustedForDelegation -eq $false) {
                $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name TrustedForDelegation -Value $Computer.TrustedForDelegation -Force }
            else {
                $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name TrustedForDelegation -Value "Unknown Status" -Force }

            if ($Computer.SID) {
                $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name SID -Value $Computer.SID -Force }
            else {
                $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name SID -Value "No SID" -Force }

            if ($Computer.ImageIndex) {
                $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name ImageIndex -Value $Computer.ImageIndex -Force }
            else {
                if ($Computer.OperatingSystem -match 'Win' -and $Computer.OperatingSystem -match 'Server') {
                    $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name ImageIndex -Value 4 -Force
                }
                elseif ($Computer.OperatingSystem -match 'Win' -and $Computer.OperatingSystem -match '95' -and $Computer.OperatingSystem -notmatch 'Server' ) {
                    $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name ImageIndex -Value 6 -Force
                }
                elseif ($Computer.OperatingSystem -match 'Win' -and $Computer.OperatingSystem -match 'XP' -and $Computer.OperatingSystem -notmatch 'Server' ) {
                    $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name ImageIndex -Value 7 -Force
                }
                elseif ($Computer.OperatingSystem -match 'Win' -and $Computer.OperatingSystem -match 'Vista' -and $Computer.OperatingSystem -notmatch 'Server' ) {
                    $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name ImageIndex -Value 8 -Force
                }
                elseif ($Computer.OperatingSystem -match 'Win' -and $Computer.OperatingSystem -match '7' -and $Computer.OperatingSystem -notmatch 'Server' ) {
                    $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name ImageIndex -Value 9 -Force
                }
                elseif ($Computer.OperatingSystem -match 'Win' -and $Computer.OperatingSystem -match '8' -and $Computer.OperatingSystem -notmatch 'Server' ) {
                    $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name ImageIndex -Value 10 -Force
                }
                elseif ($Computer.OperatingSystem -match 'Win' -and $Computer.OperatingSystem -match '10' -and $Computer.OperatingSystem -notmatch 'Server' ) {
                    $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name ImageIndex -Value 11 -Force
                }
                elseif ($Computer.OperatingSystem -match 'Win' -and $Computer.OperatingSystem -match '11' -and $Computer.OperatingSystem -notmatch 'Server' ) {
                    $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name ImageIndex -Value 12 -Force
                }
                elseif ($Computer.OperatingSystem -match 'ubuntu' ) {
                    $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name ImageIndex -Value 13 -Force
                }
                elseif ($Computer.OperatingSystem -match 'debian' ) {
                    $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name ImageIndex -Value 14 -Force
                }
                elseif ($Computer.OperatingSystem -match 'redhat' -or $Computer.OperatingSystem -match 'rhel' ) {
                    $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name ImageIndex -Value 15 -Force
                }
                elseif ($Computer.OperatingSystem -match 'centos' ) {
                    $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name ImageIndex -Value 16 -Force
                }
                else {
                    $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name ImageIndex -Value 3 -Force
                }
            }
            $script:ComputerTreeViewDataTemp += $ComputerTreeNodeInsertDefaultData
            ###write-host $($ComputerTreeNodeInsertDefaultData | Select Name, OperatingSystem, CanonicalName, IPv4Address, Notes)
        }
        $script:ComputerTreeViewData       = $script:ComputerTreeViewDataTemp
        $script:ComputerTreeViewDataTemp   = $null
        $ComputerTreeNodeInsertDefaultData = $null
    }
}



Update-FormProgress "Save-TreeViewData"
Function Save-TreeViewData {
    <#
        .Description
        Saves data as a csv file for either the Endpoint or Accounts tree views.
    #>
    param(
        [switch]$Accounts,
        [switch]$Endpoint,
        [switch]$SaveAllChecked,
        [switch]$SaveScan,
        [switch]$SkipTextFieldSave,
        [string[]]$Ports,
        [string[]]$Endpoints
    )
    if ($Accounts) {
        $AccountsTreeNodeSaveData = @()
        Foreach($Account in $script:AccountsTreeViewData) {
            $AccountsTreeNodeSaveDataTemp = New-Object PSObject -Property @{ Name = $Account.Name}
            $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Enabled -Value $Account.Enabled -Force
            $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name CanonicalName   -Value $Account.CanonicalName -Force

            # If the node is selected, it will save the values you enter
            if ($Account.Name -eq $script:Section3AccountDataNameTextBox.Text -and -not $SkipTextFieldSave) {
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name LockedOut              -Value $Section3AccountDataLockedOutTextBox.text -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name SmartCardLogonRequired -Value $Section3AccountDataSmartCardLogonRequiredTextBox.text -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Created                -Value $Section3AccountDataCreatedTextBox.text -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Modified               -Value $Section3AccountDataModifiedTextBox.text -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name LastLogonDate          -Value $Section3AccountDataLastLogonDateTextBox.text -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name LastBadPasswordAttempt -Value $Section3AccountDataLastBadPasswordAttemptTextBox.text -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name BadLogonCount          -Value $Section3AccountDataBadLogonCountTextBox.text -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name PasswordExpired        -Value $Section3AccountDataPasswordExpiredTextBox.text -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name PasswordNeverExpires   -Value $Section3AccountDataPasswordNeverExpiresTextBox.text -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name PasswordNotRequired    -Value $Section3AccountDataPasswordNotRequiredTextBox.text -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name MemberOf               -Value $Section3AccountDataMemberOfComboBox.Items -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name SID                    -Value $Section3AccountDataSIDTextBox.text -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name ScriptPath             -Value $Section3AccountDataScriptPathTextBox.text -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name HomeDrive              -Value $Section3AccountDataHomeDriveTextBox.text -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Notes                  -Value $script:Section3AccountDataNotesRichTextBox.text -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name ImageIndex             -Value $Account.ImageIndex -Force

                # $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name LockedOut              -Value $Account.LockedOut -Force
                # $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name SmartCardLogonRequired -Value $Account.SmartCardLogonRequired -Force
                # $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Created                -Value $Account.Created -Force
                # $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Modified               -Value $Account.Modified -Force
                # $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name LastLogonDate          -Value $Account.LastLogonDate -Force
                # $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name LastBadPasswordAttempt -Value $Account.LastBadPasswordAttempt -Force
                # $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name BadLogonCount          -Value $Account.BadLogonCount -Force
                # $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name PasswordExpired        -Value $Account.PasswordExpired -Force
                # $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name PasswordNeverExpires   -Value $Account.PasswordNeverExpires -Force
                # $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name PasswordNotRequired    -Value $Account.PasswordNotRequired -Force
                # $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name MemberOf               -Value $Account.MemberOf -Force
                # $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name SID                    -Value $Account.SID -Force
                # $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name ScriptPath             -Value $Account.ScriptPath -Force
                # $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name HomeDrive              -Value $Account.HomeDrive -Force
                # $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Notes                  -Value $Account.Notes -Force
            }
            # Else, if the node is not selected, it will retain what was saved
            else {
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name LockedOut              -Value $Account.LockedOut -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name SmartCardLogonRequired -Value $Account.SmartCardLogonRequired -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Created                -Value $Account.Created -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Modified               -Value $Account.Modified -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name LastLogonDate          -Value $Account.LastLogonDate -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name LastBadPasswordAttempt -Value $Account.LastBadPasswordAttempt -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name BadLogonCount          -Value $Account.BadLogonCount -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name PasswordExpired        -Value $Account.PasswordExpired -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name PasswordNeverExpires   -Value $Account.PasswordNeverExpires -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name PasswordNotRequired    -Value $Account.PasswordNotRequired -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name MemberOf               -Value $(($Account | Select-Object -ExpandProperty MemberOf) -join "`n") -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name SID                    -Value $Account.SID -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name ScriptPath             -Value $Account.ScriptPath -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name HomeDrive              -Value $Account.HomeDrive -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Notes                  -Value $Account.Notes -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name ImageIndex             -Value $Account.ImageIndex -Force
            }
            $AccountsTreeNodeSaveData += $AccountsTreeNodeSaveDataTemp
        }
        $script:AccountsTreeViewData  = $AccountsTreeNodeSaveData
        $AccountsTreeNodeSaveDataTemp = $null
        $AccountsTreeNodeSaveData     = $null

        # Saves the TreeView Data to File
        $script:AccountsTreeViewData | Export-Csv $AccountsTreeNodeFileSave -NoTypeInformation -Force
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
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name PortScan                        -Value $Computer.PortScan -Force
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Notes                           -Value $Computer.Notes -Force
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name ImageIndex                      -Value $Computer.ImageIndex -Force

            if ($SaveScan){
                # If the node is selected, it will save the values you enter
                if ($Computer.Name -in $Endpoints) {
                    $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name PortScan    -Value "$($Ports -join',')" -Force
                }
                $ComputerTreeNodeSaveData += $ComputerTreeNodeSaveDataTemp
            }
            elseif ($SkipTextFieldSave) {
                # Just a basic save of the $Script:ComputerTreeViewData
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
                    $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name ImageIndex  -Value $Computer.ImageIndex -Force
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
                    $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name ImageIndex  -Value $Computer.ImageIndex -Force
                }
                $ComputerTreeNodeSaveData += $ComputerTreeNodeSaveDataTemp
            }
        }
        $script:ComputerTreeViewData  = $ComputerTreeNodeSaveData
        $ComputerTreeNodeSaveDataTemp = $null
        $ComputerTreeNodeSaveData     = $null

        $script:Section3HostDataNotesSaveCheck = $Section3HostDataNotesRichTextBox.Text

        # Saves the TreeView Data to File
        $script:ComputerTreeViewData | Export-Csv $EndpointTreeNodeFileSave -NoTypeInformation -Force
    }
}



Update-FormProgress "Initialize-TreeViewData"
function Initialize-TreeViewData {
    <#
        .Description
        Initializes the Computer TreeView section that computer nodes are added to
        TreeView initialization initially happens upon load and whenever the it is regenerated, like when switching between views
        These include the root nodes of Search, and various Operating System and OU/CN names
    #>
    param(
        [switch]$Accounts,
        [switch]$Endpoint
    )
    if ($Accounts) {
        $script:TreeNodeAccountsList = New-Object -TypeName System.Windows.Forms.TreeNode -ArgumentList 'All Accounts'
        $script:TreeNodeAccountsList.Tag = "Accounts"
        $script:TreeNodeAccountsList.Expand()
        $script:TreeNodeAccountsList.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
        $script:TreeNodeAccountsList.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)

        $script:AccountsListSearch     = New-Object -TypeName System.Windows.Forms.TreeNode -ArgumentList '* Search Results'
        $script:AccountsListSearch.Tag = "Search"
    }
    if ($Endpoint) {
        $script:TreeNodeComputerList = New-Object -TypeName System.Windows.Forms.TreeNode -ArgumentList 'All Endpoints'
        $script:TreeNodeComputerList.Tag = "Endpoint"
        $script:TreeNodeComputerList.Expand()
        $script:TreeNodeComputerList.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
        $script:TreeNodeComputerList.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)

        $script:ComputerListSearch     = New-Object -TypeName System.Windows.Forms.TreeNode -ArgumentList '* Search Results'
        $script:ComputerListSearch.Tag = "Search"
    }
}



Update-FormProgress "Update-TreeViewData"
function Update-TreeViewData {
    <#
        .Description
    #>
    param(
        $TreeView,
        [switch]$Commands,
        [switch]$Accounts,
        [switch]$Endpoint
    )
    #Previously known as: Conduct-NodeAction

    if ($Commands) {
        $script:TreeeViewCommandsCount = 0
        $InformationTabControl.SelectedTab = $Section3QueryExplorationTabPage

        # Resets the SMB and RPC command count each time
        $script:RpcCommandCount   = 0
        $script:SmbCommandCount   = 0
        $script:WinRMCommandCount = 0
    }
    elseif ($Accounts) {
        $script:TreeeViewAccountsCount = 0
        $InformationTabControl.SelectedTab = $Section3AccountDataTab
    }
    elseif ($Endpoint) {
        $script:TreeeViewEndpointCount = 0
        $InformationTabControl.SelectedTab = $Section3HostDataTab
    }
    else {
        $InformationTabControl.SelectedTab = $Section3ResultsTab
    }

    $EntryQueryHistoryChecked = 0

    # This will return data on hosts selected/highlight, but not necessarily checked
    [System.Windows.Forms.TreeNodeCollection]$AllNodes = $TreeView
    foreach ($root in $AllNodes) {
    #     $EntryNodeCheckedCountforRoot = 0

    #     # if ($Commands) { if ($root.Text -match 'Search Results') { $EnsureViisible = $root } }
    #     # if ($Accounts) { if ($root.Text -match 'All Accounts')  { $EnsureViisible = $root } }
    #     # if ($Endpoint) { if ($root.Text -match 'All Endpoints')  { $EnsureViisible = $root } }

        if ($root.Checked) {
            $Root.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
            $Root.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
            #$Root.Expand()
            foreach ($Category in $root.Nodes) {
                #$Category.Expand()
                $Category.checked = $true
                $Category.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                foreach ($Entry in $Category.nodes) {
                    if ($Commands) { $script:TreeeViewCommandsCount++ }
                    if ($Accounts) { $script:TreeeViewAccountsCount++ }
                    if ($Endpoint) { $script:TreeeViewEndpointCount++ }
                    $Entry.Checked   = $True
                    $Entry.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                    $Entry.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                }
            }
        }

        if ($root.isselected) {
            $script:rootSelected     = $root
            $script:CategorySelected = $null
            $script:EntrySelected    = $null

            $script:HostQueryTreeViewSelected              = ""
            $Section3QueryExplorationName.Text             = "N/A"
            $Section3QueryExplorationTypeTextBox.Text      = "N/A"
            $Section3QueryExplorationWinRMPoShTextBox.Text = "N/A"
            $Section3QueryExplorationWinRMWMITextBox.Text  = "N/A"
            $Section3QueryExplorationRPCPoShTextBox.Text   = "N/A"
            $Section3QueryExplorationRPCWMITextBox.Text    = "N/A"
        }

        foreach ($Category in $root.Nodes) {
            $EntryNodeCheckedCountforCategory = 0

            if ($Commands){
                if ($Category.Checked) {
                    #$MainLeftTabControl.SelectedTab = $Section1SearchTab

                    #    $Category.Expand()
                    if ($Category.Text -match '[\[(]WinRM[)\]]' ) {
                        $script:WinRMCommandCount++
                    }
                    if ($Category.Text -match '[\[(]rpc[)\]]' ) {
                        $script:RpcCommandCount++
                        #deprecated
                        # if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Session Based') {
                        #     [system.media.systemsounds]::Exclamation.play()
                        #     $StatusListBox.Items.Clear()
                        #     $StatusListBox.Items.Add("Collection Mode Changed to: Individual Execution")
                        #     #Removed For Testing#$ResultsListBox.Items.Clear()
                        #     $ResultsListBox.Items.Add("The collection mode '$($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem)' does not support the RPC and SMB protocols and has been changed to")
                        #     $ResultsListBox.Items.Add("'Monitor Jobs' which supports RPC, SMB, and WinRM - but may be slower and noisier on the network.")
                        #     $script:CommandTreeViewQueryMethodSelectionComboBox.SelectedIndex = 0 #'Monitor Jobs'
                        #     $EventLogRPCRadioButton.checked         = $true
                        #     $ExternalProgramsRPCRadioButton.checked = $true
                        # }
                    }
                    if ($Category.Text -match '[\[(]smb[)\]]' ) {
                        $script:SmbCommandCount++
                        #deprecated
                        # if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Session Based') {
                        #     # This brings specific tabs to the forefront/front view

                        #     [system.media.systemsounds]::Exclamation.play()
                        #     $StatusListBox.Items.Clear()
                        #     $StatusListBox.Items.Add("Collection Mode Changed to: Individual Execution")
                        #     #Removed For Testing#$ResultsListBox.Items.Clear()
                        #     $ResultsListBox.Items.Add("The collection mode '$($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem)' does not support the RPC and SMB protocols and has been changed to")
                        #     $ResultsListBox.Items.Add("'Monitor Jobs' which supports RPC, SMB, and WinRM - but may be slower and noisier on the network.")
                        #     $script:CommandTreeViewQueryMethodSelectionComboBox.SelectedIndex = 0 #'Monitor Jobs'
                        # }
                    }

                    $Category.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                    $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                    $Root.NodeFont      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                    $Root.ForeColor     = [System.Drawing.Color]::FromArgb(0,0,0,224)

                    foreach ($Entry in $Category.nodes) {
                        if ($Commands) { $script:TreeeViewCommandsCount++ }
                        if ($Accounts) { $script:TreeeViewAccountsCount++ }
                        if ($Endpoint) { $script:TreeeViewEndpointCount++ }

                        if ($Entry.Text -match '[\[(]WinRM[)\]]' ) {
                            $script:WinRMCommandCount++
                        }
                        if ($Entry.Text -match '[\[(]rpc[)\]]') {
                            $script:RpcCommandCount++
                            #deprecated
                            # if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Session Based') {
                            #     [system.media.systemsounds]::Exclamation.play()
                            #     $StatusListBox.Items.Clear()
                            #     $StatusListBox.Items.Add("Collection Mode Changed to: Individual Execution")
                            #     #Removed For Testing#$ResultsListBox.Items.Clear()
                            #     $ResultsListBox.Items.Add("The collection mode '$($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem)' does not support the RPC and SMB protocols and has been changed to")
                            #     $ResultsListBox.Items.Add("'Monitor Jobs' which supports RPC, SMB, and WinRM - but may be slower and noisier on the network.")
                            #     $script:CommandTreeViewQueryMethodSelectionComboBox.SelectedIndex = 0 #'Monitor Jobs'
                            #     $EventLogRPCRadioButton.checked         = $true
                            #     $ExternalProgramsRPCRadioButton.checked = $true
                            # }
                        }
                        if ($Entry.Text -match '[\[(]smb[)\]]') {
                            $script:SmbCommandCount++
                            #deprecated
                            # if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Session Based') {
                            #     [system.media.systemsounds]::Exclamation.play()
                            #     $StatusListBox.Items.Clear()
                            #     $StatusListBox.Items.Add("Collection Mode Changed to: Individual Execution")
                            #     #Removed For Testing#$ResultsListBox.Items.Clear()
                            #     $ResultsListBox.Items.Add("The collection mode '$($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem)' does not support the RPC and SMB protocols and has been changed to")
                            #     $ResultsListBox.Items.Add("'Monitor Jobs' which supports RPC, SMB, and WinRM - but may be slower and noisier on the network.")
                            #     $script:CommandTreeViewQueryMethodSelectionComboBox.SelectedIndex = 0 #'Monitor Jobs'
                            # }
                        }

                        $EntryNodeCheckedCountforCategory++
                        $EntryNodeCheckedCountforRoot++
                        $Entry.Checked   = $True
                        $Entry.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                        $Entry.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                    }
                    if ($root.text -match 'Custom Group Commands' -or $root.text -match 'User Added Commands') {
                        $EntryQueryHistoryChecked++
                        $Section1TreeViewCommandsTab.Controls.Add($CommandsTreeViewRemoveCommandButton)
                        $CommandsTreeViewRemoveCommandButton.bringtofront()
                    }
                }
                elseif (!($Category.checked)) {
                    foreach ($Entry in $Category.nodes) {
                        if ($Entry.checked) {
                            # Currently used to support cmdkey /delete:$script:EntryChecked to clear out credentials when using Remote Desktop
                            $script:EntryChecked = $entry.text

                            if ($Entry.Text -match '[\[(]WinRM[)\]]' ) {
                                $script:WinRMCommandCount++
                            }
                            if ($Entry.Text -match '[\[(]rpc[)\]]') {
                                $script:RpcCommandCount++
                                #deprecated
                                # if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Session Based') {
                                #     [system.media.systemsounds]::Exclamation.play()
                                #     $StatusListBox.Items.Clear()
                                #     $StatusListBox.Items.Add("Collection Mode Changed to: Individual Execution")
                                #     #Removed For Testing#$ResultsListBox.Items.Clear()
                                #     $ResultsListBox.Items.Add("The collection mode '$($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem)' does not support the RPC and SMB protocols and has been changed to")
                                #     $ResultsListBox.Items.Add("'Monitor Jobs' which supports RPC, SMB, and WinRM - but may be slower and noisier on the network.")
                                #     $script:CommandTreeViewQueryMethodSelectionComboBox.SelectedIndex = 0 #'Monitor Jobs'
                                #     $EventLogRPCRadioButton.checked         = $true
                                #     $ExternalProgramsRPCRadioButton.checked = $true
                                # }
                            }
                            if ($Entry.Text -match '[\[(]smb[)\]]') {
                                $script:SmbCommandCount++
                                #deprecated
                                # if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Session Based') {
                                #     [system.media.systemsounds]::Exclamation.play()
                                #     $StatusListBox.Items.Clear()
                                #     $StatusListBox.Items.Add("Collection Mode Changed to: Individual Execution")
                                #     #Removed For Testing#$ResultsListBox.Items.Clear()
                                #     $ResultsListBox.Items.Add("The collection mode '$($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem)' does not support the RPC and SMB protocols and has been changed to")
                                #     $ResultsListBox.Items.Add("'Monitor Jobs' which supports RPC, SMB, and WinRM - but may be slower and noisier on the network.")
                                #     $script:CommandTreeViewQueryMethodSelectionComboBox.SelectedIndex = 0 #'Monitor Jobs'
                                # }
                            }

                            # if ($Commands) { $script:TreeeViewCommandsCount++ }
                            # if ($Accounts) { $script:TreeeViewAccountsCount++ }
                            # if ($Endpoint) { $script:TreeeViewEndpointCount++ }
                            $EntryNodeCheckedCountforCategory++
                            $EntryNodeCheckedCountforRoot++
                            $Entry.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                            $Entry.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                        }
                        elseif (-not $Entry.checked) {
                            if ($CategoryCheck -eq $False) {$Category.Checked = $False}
                            $Entry.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                            $Entry.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
                        }
                    }
                    if ($EntryQueryHistoryChecked -eq 0) {
                        $Section1TreeViewCommandsTab.Controls.Remove($CommandsTreeViewRemoveCommandButton)
                    }
                }
                if ($Category.isselected) {
                    $script:rootSelected      = $null
                    $script:CategorySelected  = $Category
                    $script:EntrySelected     = $null

                    $script:HostQueryTreeViewSelected = ""
                    #$StatusListBox.Items.clear()
                    #$StatusListBox.Items.Add("Category:  $($Category.Text)")
                    ##Removed For Testing#$ResultsListBox.Items.Clear()
                    #$ResultsListBox.Items.Add("- Checkbox This Node to Execute All Commands Within")

                    $Section3QueryExplorationNameTextBox.Text = ''
                    $Section3QueryExplorationName.Text = ''
                    $Section3QueryExplorationTypeTextBox.Text = ''
                    $Section3QueryExplorationWinRMPoShTextBox.Text = ''
                    $Section3QueryExplorationWinRMWMITextBox.Text = ''
                    $Section3QueryExplorationRPCPoShTextBox.Text = ''
                    $Section3QueryExplorationRPCWMITextBox.Text = ''
                    $Section3QueryExplorationWinRMCmdTextBox.Text = ''
                    $Section3QueryExplorationSmbPoshTextBox.Text = ''
                    $Section3QueryExplorationSmbWmiTextBox.Text = ''
                    $Section3QueryExplorationSmbCmdTextBox.Text = ''
                    $Section3QueryExplorationSshLinuxTextBox.Text = ''
                    $Section3QueryExplorationPropertiesPoshTextBox.Text = ''
                    $Section3QueryExplorationPropertiesWMITextBox.Text = ''
                    $Section3QueryExplorationWinRSWmicTextBox.Text = ''
                    $Section3QueryExplorationWinRSCmdTextBox.Text = ''
                    $Section3QueryExplorationTagWordsTextBox.Text = ''
                    $Section3QueryExplorationDescriptionRichTextbox.Text = ''
                }
            }

            foreach ($Entry in $Category.nodes) {
                $EntryNodesWithinCategory++

                if ($Commands) {
                    if ($Entry.isselected) {
                        $script:rootSelected     = $null
                        $script:CategorySelected = $Category
                        $script:EntrySelected    = $Entry

                        if ($root.text -match 'Endpoint Commands') {
                            $NodeCommand = $script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }
                            $Section3QueryExplorationNameTextBox.Text            = $NodeCommand.Name
                            $Section3QueryExplorationTagWordsTextBox.Text        = $NodeCommand.Type
                            $Section3QueryExplorationWinRMPoShTextBox.Text       = $NodeCommand.Command_WinRM_PoSh
                            $Section3QueryExplorationWinRMWMITextBox.Text        = $NodeCommand.Command_WinRM_WMI
                            $Section3QueryExplorationWinRMCmdTextBox.Text        = $NodeCommand.Command_WinRM_Cmd
                            $Section3QueryExplorationRPCPoShTextBox.Text         = $NodeCommand.Command_RPC_PoSh
                            $Section3QueryExplorationRPCWMITextBox.Text          = $NodeCommand.Command_RPC_WMI
                            $Section3QueryExplorationPropertiesPoshTextBox.Text  = $NodeCommand.Properties_PoSh
                            $Section3QueryExplorationPropertiesWMITextBox.Text   = $NodeCommand.Properties_WMI
                            $Section3QueryExplorationWinRSWmicTextBox.Text       = $NodeCommand.Command_WinRS_WMIC
                            $Section3QueryExplorationWinRSCmdTextBox.Text        = $NodeCommand.Command_WinRS_CMD
                            $Section3QueryExplorationSmbPoshTextBox.Text         = $NodeCommand.Command_SMB_PoSh
                            $Section3QueryExplorationSmbWmiTextBox.Text          = $NodeCommand.Command_SMB_WMI
                            $Section3QueryExplorationSmbCmdTextBox.Text          = $NodeCommand.Command_SMB_Cmd
                            $Section3QueryExplorationSshLinuxTextBox.Text        = $NodeCommand.Command_Linux
                            $Section3QueryExplorationDescriptionRichTextbox.Text = $NodeCommand.Description
                        }
                        elseif ($root.text -match 'Active Directory Commands') {
                            $NodeCommand = $script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }
                            $Section3QueryExplorationNameTextBox.Text            = $NodeCommand.Name
                            $Section3QueryExplorationTagWordsTextBox.Text        = $NodeCommand.Type
                            $Section3QueryExplorationWinRMPoShTextBox.Text       = $NodeCommand.Command_WinRM_PoSh
                            $Section3QueryExplorationWinRMWMITextBox.Text        = $NodeCommand.Command_WinRM_WMI
                            $Section3QueryExplorationWinRMCmdTextBox.Text        = $NodeCommand.Command_WinRM_Cmd
                            $Section3QueryExplorationRPCPoShTextBox.Text         = $NodeCommand.Command_RPC_PoSh
                            $Section3QueryExplorationRPCWMITextBox.Text          = $NodeCommand.Command_RPC_WMI
                            $Section3QueryExplorationPropertiesPoshTextBox.Text  = $NodeCommand.Properties_PoSh
                            $Section3QueryExplorationPropertiesWMITextBox.Text   = $NodeCommand.Properties_WMI
                            $Section3QueryExplorationWinRSWmicTextBox.Text       = $NodeCommand.Command_WinRS_WMIC
                            $Section3QueryExplorationWinRSCmdTextBox.Text        = $NodeCommand.Command_WinRS_CMD
                            $Section3QueryExplorationSmbPoshTextBox.Text         = $NodeCommand.Command_SMB_PoSh
                            $Section3QueryExplorationSmbWmiTextBox.Text          = $NodeCommand.Command_SMB_WMI
                            $Section3QueryExplorationSmbCmdTextBox.Text          = $NodeCommand.Command_SMB_Cmd
                            $Section3QueryExplorationSshLinuxTextBox.Text        = $NodeCommand.Command_Linux
                            $Section3QueryExplorationDescriptionRichTextbox.Text = $NodeCommand.Description
                        }
                        elseif ($root.text -match 'Search Results'){
                            $NodeCommand = $script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }

                            if ($NodeCommand.Name) {
                                $Section3QueryExplorationNameTextBox.Text            = $NodeCommand.Name
                                $Section3QueryExplorationTagWordsTextBox.Text        = $NodeCommand.Type
                                $Section3QueryExplorationWinRMPoShTextBox.Text       = $NodeCommand.Command_WinRM_PoSh
                                $Section3QueryExplorationWinRMWMITextBox.Text        = $NodeCommand.Command_WinRM_WMI
                                $Section3QueryExplorationWinRMCmdTextBox.Text        = $NodeCommand.Command_WinRM_Cmd
                                $Section3QueryExplorationRPCPoShTextBox.Text         = $NodeCommand.Command_RPC_PoSh
                                $Section3QueryExplorationRPCWMITextBox.Text          = $NodeCommand.Command_RPC_WMI
                                $Section3QueryExplorationPropertiesPoshTextBox.Text  = $NodeCommand.Properties_PoSh
                                $Section3QueryExplorationPropertiesWMITextBox.Text   = $NodeCommand.Properties_WMI
                                $Section3QueryExplorationWinRSWmicTextBox.Text       = $NodeCommand.Command_WinRS_WMIC
                                $Section3QueryExplorationWinRSCmdTextBox.Text        = $NodeCommand.Command_WinRS_CMD
                                $Section3QueryExplorationSmbPoshTextBox.Text         = $NodeCommand.Command_SMB_PoSh
                                $Section3QueryExplorationSmbWmiTextBox.Text          = $NodeCommand.Command_SMB_WMI
                                $Section3QueryExplorationSmbCmdTextBox.Text          = $NodeCommand.Command_SMB_Cmd
                                $Section3QueryExplorationSshLinuxTextBox.Text        = $NodeCommand.Command_Linux
                                $Section3QueryExplorationDescriptionRichTextbox.Text = $NodeCommand.Description
                            }
                            else {
                                $NodeCommand = $script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }
                                $Section3QueryExplorationNameTextBox.Text            = $NodeCommand.Name
                                $Section3QueryExplorationTagWordsTextBox.Text        = $NodeCommand.Type
                                $Section3QueryExplorationWinRMPoShTextBox.Text       = $NodeCommand.Command_WinRM_PoSh
                                $Section3QueryExplorationWinRMWMITextBox.Text        = $NodeCommand.Command_WinRM_WMI
                                $Section3QueryExplorationWinRMCmdTextBox.Text        = $NodeCommand.Command_WinRM_Cmd
                                $Section3QueryExplorationRPCPoShTextBox.Text         = $NodeCommand.Command_RPC_PoSh
                                $Section3QueryExplorationRPCWMITextBox.Text          = $NodeCommand.Command_RPC_WMI
                                $Section3QueryExplorationPropertiesPoshTextBox.Text  = $NodeCommand.Properties_PoSh
                                $Section3QueryExplorationPropertiesWMITextBox.Text   = $NodeCommand.Properties_WMI
                                $Section3QueryExplorationWinRSWmicTextBox.Text       = $NodeCommand.Command_WinRS_WMIC
                                $Section3QueryExplorationWinRSCmdTextBox.Text        = $NodeCommand.Command_WinRS_CMD
                                $Section3QueryExplorationSmbPoshTextBox.Text         = $NodeCommand.Command_SMB_PoSh
                                $Section3QueryExplorationSmbWmiTextBox.Text          = $NodeCommand.Command_SMB_WMI
                                $Section3QueryExplorationSmbCmdTextBox.Text          = $NodeCommand.Command_SMB_Cmd
                                $Section3QueryExplorationSshLinuxTextBox.Text        = $NodeCommand.Command_Linux
                                $Section3QueryExplorationDescriptionRichTextbox.Text = $NodeCommand.Description
                            }
                        }

                        if ($Category.text -match 'PowerShell Scripts'){
                            # Replaces the edit checkbox and save button with View Script button
                            $Section3QueryExplorationTabPage.Controls.Remove($Section3QueryExplorationEditCheckBox)
                            $Section3QueryExplorationTabPage.Controls.Remove($Section3QueryExplorationSaveButton)
                            $Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationViewScriptButton)
                        }
                        else {
                            # Replaces the View Script button with the edit checkbox and save button
                            $Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationEditCheckBox)
                            $Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationSaveButton)
                            $Section3QueryExplorationTabPage.Controls.Remove($Section3QueryExplorationViewScriptButton)
                        }
                    }

                    if ($Entry.checked -and $root.text -match 'User Added Commands') {
                        $EntryQueryHistoryChecked++
                        $Section1TreeViewCommandsTab.Controls.Add($CommandsTreeViewRemoveCommandButton)
                        $CommandsTreeViewRemoveCommandButton.bringtofront()
                    }
                    else {
                        $EntryQueryHistoryChecked--
                    }
                }

                if ($Endpoint) {
                    if ($Entry.isselected) {
                        #$Entry.ImageIndex = 8
                        $script:rootSelected     = $null
                        $script:CategorySelected = $Category
                        $script:EntrySelected    = $Entry

                        Display-ContextMenuForComputerTreeNode -ClickedOnNode

                        $script:HostQueryTreeViewSelected = $Entry.Text

                        if ($root.text -match 'All Endpoints') {
                            $script:NodeEndpoint = $script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}

                            $script:Section3EndpointDataIconPictureBox.Image        = [System.Drawing.Image]::FromFile($($EndpointTreeviewImageHashTable["$($script:NodeEndpoint.ImageIndex)"]))
                            $script:Section3HostDataNameTextBox.Text                = $script:NodeEndpoint.Name
                            $Section3HostDataOUTextBox.Text                         = $script:NodeEndpoint.CanonicalName
                            $Section3EndpointDataCreatedTextBox.Text                = $script:NodeEndpoint.Created
                            $Section3EndpointDataModifiedTextBox.Text               = $script:NodeEndpoint.Modified
                            $Section3EndpointDataLastLogonDateTextBox.Text          = $script:NodeEndpoint.LastLogonDate
                            $Section3HostDataIPTextBox.Text                         = $script:NodeEndpoint.IPv4Address
                            $Section3HostDataMACTextBox.Text                        = $script:NodeEndpoint.MACAddress
                            $Section3EndpointDataEnabledTextBox.Text                = $script:NodeEndpoint.Enabled
                            $Section3EndpointDataisCriticalSystemObjectTextBox.Text = $script:NodeEndpoint.isCriticalSystemObject
                            $Section3EndpointDataSIDTextBox.Text                    = $script:NodeEndpoint.SID
                            $Section3EndpointDataOperatingSystemTextBox.Text        = $script:NodeEndpoint.OperatingSystem

                            $Section3EndpointDataOperatingSystemHotfixComboBox.ForeColor = "Black"
                                $Section3EndpointDataOperatingSystemHotfixComboBox.Items.Clear()
                                $OSHotfixList = $null
                                $OSHotfixList = $(($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).OperatingSystemHotfix).split("`n") | Sort-Object
                                ForEach ($Hotfix in $OSHotfixList) {
                                    $Section3EndpointDataOperatingSystemHotfixComboBox.Items.Add($Hotfix)
                                }
                            $Section3EndpointDataOperatingSystemHotfixComboBox.Text = "- Select Dropdown [$(if ($OSHotfixList -ne $null) {$OSHotfixList.count} else {0})] OS Hotfixes"

                            $Section3EndpointDataOperatingSystemServicePackComboBox.ForeColor = "Black"
                                $Section3EndpointDataOperatingSystemServicePackComboBox.Items.Clear()
                                $OSServicePackList = $null
                                $OSServicePackList = $(($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).OperatingSystemServicePack).split("`n") | Sort-Object
                                ForEach ($ServicePack in $OSServicePackList) {
                                    $Section3EndpointDataOperatingSystemServicePackComboBox.Items.Add($ServicePack)
                                }
                            $Section3EndpointDataOperatingSystemServicePackComboBox.Text = "- Select Dropdown [$(if ($OSServicePackList -ne $null) {$OSServicePackList.count} else {0})] OS Service Packs"

                            $Section3EndpointDataMemberOfComboBox.ForeColor = "Black"
                                $Section3EndpointDataMemberOfComboBox.Items.Clear()
                                $MemberOfList = $null
                                $MemberOfList = $(($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).MemberOf).split("`n") | Sort-Object
                                ForEach ($Group in $MemberOfList) {
                                    $Section3EndpointDataMemberOfComboBox.Items.Add($Group)
                                }
                            $Section3EndpointDataMemberOfComboBox.Text              = "- Select Dropdown [$(if ($MemberOfList -ne $null) {$MemberOfList.count} else {0})] Groups"
                            $Section3EndpointDataLockedOutTextBox.Text              = $script:NodeEndpoint.LockedOut
                            $Section3EndpointDataLogonCountTextBox.Text             = $script:NodeEndpoint.LogonCount

                            $Section3EndpointDataPortScanComboBox.ForeColor = "Black"
                                $Section3EndpointDataPortScanComboBox.Items.Clear()
                                $PortScanList = $null
                                $PortScanList = $(($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).PortScan).split(",") | Sort-Object
                                ForEach ($Port in $PortScanList) {
                                    $Section3EndpointDataPortScanComboBox.Items.Add($Port)
                                }
                            $Section3EndpointDataPortScanComboBox.Text              = " $(if ($PortScanList -ne $null) {$PortScanList.count} else {0}) Ports"

                            $Section3HostDataSelectionComboBox.Text                 = "Host Data - Selection"
                            $Section3HostDataSelectionDateTimeComboBox.Text         = "Host Data - Date & Time"

                            $script:Section3HostDataNotesSaveCheck = $Section3HostDataNotesRichTextBox.Text = $script:NodeEndpoint.Notes
                        }
                    }
                }
                if ($Accounts) {
                    if ($Entry.isselected) {
                        $script:rootSelected      = $null
                        $script:CategorySelected  = $Category
                        $script:EntrySelected     = $Entry

                        Display-ContextMenuForAccountsTreeNode -ClickedOnNode
                        $script:Section3AccountDataNotesRichTextBox.ForeColor = 'Black'

                        # $script:HostQueryTreeViewSelected = $Entry.Text

                        if ($root.text -match 'All Accounts') {
                            $script:NodeAccount = $script:AccountsTreeViewData | Where-Object {$($Entry.Text) -like "*$($_.Name)" }

                            $script:Section3AccountDataIconPictureBox.Image         = [System.Drawing.Image]::FromFile($($AccountsTreeviewImageHashTable["$($script:NodeAccount.ImageIndex)"]))
                            $script:Section3AccountDataNameTextBox.Text             = $script:NodeAccount.Name
                            $Section3AccountDataEnabledTextBox.Text                 = $script:NodeAccount.Enabled
                            $Section3AccountDataOUTextBox.Text                      = $script:NodeAccount.CanonicalName
                            $Section3AccountDataLockedOutTextBox.Text               = $script:NodeAccount.LockedOut
                            $Section3AccountDataSmartCardLogonRequiredTextBox.Text  = $script:NodeAccount.SmartCardLogonRequired
                            $Section3AccountDataCreatedTextBox.Text                 = $script:NodeAccount.Created
                            $Section3AccountDataModifiedTextBox.Text                = $script:NodeAccount.Modified
                            $Section3AccountDataLastLogonDateTextBox.Text           = $script:NodeAccount.LastLogonDate
                            $Section3AccountDataLastBadPasswordAttemptTextBox.Text  = $script:NodeAccount.LastBadPasswordAttempt
                            $Section3AccountDataBadLogonCountTextBox.Text           = $script:NodeAccount.BadLogonCount
                            $Section3AccountDataPasswordExpiredTextBox.Text         = $script:NodeAccount.PasswordExpired
                            $Section3AccountDataPasswordNeverExpiresTextBox.Text    = $script:NodeAccount.PasswordNeverExpires
                            $Section3AccountDataPasswordNotRequiredTextBox.Text     = $script:NodeAccount.PasswordNotRequired
                            $Section3AccountDataMemberOfComboBox.ForeColor          = "Black"
                                $Section3AccountDataMemberOfComboBox.Items.Clear()
                                $MemberOfList = $null
                                $MemberOfList = $(($script:AccountsTreeViewData | Where-Object {$($Entry.Text) -like $_.Name}).MemberOf).split("`n") | Sort-Object
                                ForEach ($Group in $MemberOfList) {
                                    $Section3AccountDataMemberOfComboBox.Items.Add($Group)
                                }
                            $Section3AccountDataMemberOfComboBox.Text               = "- Select Dropdown [$(if ($MemberOfList -ne $null) {$MemberOfList.count} else {0})] Groups"
                            $Section3AccountDataSIDTextBox.Text                     = $script:NodeAccount.SID
                            $Section3AccountDataScriptPathTextBox.Text              = $script:NodeAccount.ScriptPath
                            $Section3AccountDataHomeDriveTextBox.Text               = $script:NodeAccount.HomeDrive
                            $script:Section3AccountDataNotesRichTextBox.Text        = $script:NodeAccount.Notes
                        }
                    }
                }

                if ($entry.checked) {
                    if ($Commands) { $script:TreeeViewCommandsCount++ }
                    if ($Accounts) { $script:TreeeViewAccountsCount++ }
                    if ($Endpoint) { $script:TreeeViewEndpointCount++ }
                    $EntryNodeCheckedCountforCategory++
                    $EntryNodeCheckedCountforRoot++
                    $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                    $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,0,224)
                    $Category.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                    $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                    $Root.NodeFont      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                    $Root.ForeColor     = [System.Drawing.Color]::FromArgb(0,0,0,224)
                }
                if (-not $entry.checked) {
                    $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                    $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,0,0)
                }
            }
            if ($EntryNodeCheckedCountforCategory -gt 0) {
                $Category.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
            }
            else {
                $Category.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
            }
            if ($EntryNodeCheckedCountforRoot -gt 0) {
                $Root.NodeFont      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                $Root.ForeColor     = [System.Drawing.Color]::FromArgb(0,0,0,224)
            }
            else {
                $Root.NodeFont      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                $Root.ForeColor     = [System.Drawing.Color]::FromArgb(0,0,0,0)
          }
        }
    }
    #$EnsureViisible.EnsureVisible()


    # Note: If adding new checkboxes to other areas, make sure also add it to the script handler
    if ($Commands) {
        # Removes prevous query count from overall count, needed to maintain accurate count
        $script:SectionQueryCount -= $script:PreviousQueryCount
        $SectionQueryTempCount = 0
        # Counts queries checked
        [System.Windows.Forms.TreeNodeCollection]$AllNodes = $TreeView
        foreach ($root in $AllNodes) {
            foreach ($Category in $root.Nodes) {
                foreach ($Entry in $Category.nodes) {
                    if ($Entry.checked) {
                        $SectionQueryTempCount += 1
                    }
                }
            }
        }
        # Tracks previous count and tallies up new query total
        $script:PreviousQueryCount = $SectionQueryTempCount
        $script:SectionQueryCount += $script:PreviousQueryCount


        # List of all checkboxes - used to check if they're checkboxed and managing their color and checked state
        $script:AllCheckBoxesList = @(
            $CustomQueryScriptBlockCheckBox,

            $AccountsCurrentlyLoggedInConsoleCheckbox,
            $AccountsCurrentlyLoggedInPSSessionCheckbox,
            $AccountActivityCheckbox,

            $EventLogsEventIDsManualEntryCheckbox,
            $EventLogsQuickPickSelectionCheckbox,
            $EventLogNameEVTXLogNameSelectionCheckbox,

            $FileSearchFileSearchCheckbox,
            $FileSearchDirectoryListingCheckbox,
            $FileSearchAlternateDataStreamCheckbox,

            $ProcessLiveSearchNameCheckbox,
            $ProcessLiveSearchCommandlineCheckbox,
            $ProcessLiveSearchParentNameCheckbox,
            $ProcessLiveSearchOwnerSIDCheckbox,
            $ProcessLiveSearchServiceInfoCheckbox,
            $ProcessLiveSearchNetworkConnectionsCheckbox,
            $ProcessLiveSearchHashesSignerCertsCheckbox,
            $ProcessLiveSearchCompanyProductCheckbox,

            $ProcessSysmonSearchFilePathCheckbox,
            $ProcessSysmonSearchCommandlineCheckbox,
            $ProcessSysmonSearchParentFilePathCheckbox,
            $ProcessSysmonSearchParentCommandlineCheckbox,
            $ProcessSysmonSearchRuleNameCheckbox,
            $ProcessSysmonSearchUserAccountIdCheckbox,
            $ProcessSysmonSearchHashesCheckbox,
            $ProcessSysmonSearchCompanyProductCheckbox,

            $NetworkEndpointPacketCaptureCheckBox,

            $NetworkLiveSearchRemoteIPAddressCheckbox,
            $NetworkLiveSearchRemotePortCheckbox,
            $NetworkLiveSearchLocalPortCheckbox,
            $NetworkLiveSearchCommandLineCheckbox
            $NetworkLiveSearchExecutablePathCheckbox,
            $NetworkLiveSearchProcessCheckbox,
            $NetworkLiveSearchDNSCacheCheckbox,

            $NetworkSysmonSearchSourceIPAddressCheckbox,
            $NetworkSysmonSearchSourcePortCheckbox,
            $NetworkSysmonSearchDestinationIPAddressCheckbox,
            $NetworkSysmonSearchDestinationPortCheckbox,
            $NetworkSysmonSearchAccountCheckbox,
            $NetworkSysmonSearchExecutablePathCheckbox,

            $ExeScriptUserSpecifiedExecutableAndScriptCheckbox,

            $SysinternalsSysmonCheckbox,
            $SysinternalsProcessMonitorCheckbox,

            $RegistrySearchCheckbox
        )

        foreach ($CheckBox in $script:AllCheckBoxesList) {
            if ($CheckBox.checked -eq $true) { $script:TreeeViewCommandsCount++ }
        }
    }

    # Updates the color of the button if there is at least one query and endpoint selected
    if ($script:TreeeViewCommandsCount -gt 0 -and $script:TreeeViewEndpointCount -gt 0) {
        $script:ComputerListExecuteButton.Enabled   = $true
        $script:ComputerListExecuteButton.forecolor = 'Black'
        $script:ComputerListExecuteButton.backcolor = 'lightgreen'
    }
    else {
        $script:ComputerListExecuteButton.Enabled   = $false
        Add-CommonButtonSettings -Button $script:ComputerListExecuteButton
    }
    $StatisticsRefreshButton.PerformClick()

    # Updates the color of the button if there is at least one endpoint selected
    if ($script:TreeeViewEndpointCount -gt 0) {
        $ActionsTabProcessKillerButton.forecolor = 'Black'
        $ActionsTabProcessKillerButton.backcolor = 'lightgreen'

        $ActionsTabServiceKillerButton.forecolor = 'Black'
        $ActionsTabServiceKillerButton.backcolor = 'lightgreen'

        $ActionsTabAccountLogoutButton.forecolor = 'Black'
        $ActionsTabAccountLogoutButton.backcolor = 'lightgreen'

        $ActionsTabSelectNetworkConnectionsToKillButton.forecolor = 'Black'
        $ActionsTabSelectNetworkConnectionsToKillButton.backcolor = 'lightgreen'

        $WindowsTimelineButton.forecolor = 'Black'
        $WindowsTimelineButton.backcolor = 'lightgreen'

        $ActionsTabQuarantineEndpointsButton.forecolor = 'Black'
        $ActionsTabQuarantineEndpointsButton.backcolor = 'lightgreen'
    }
    else {
        Add-CommonButtonSettings -Button $ActionsTabProcessKillerButton
        Add-CommonButtonSettings -Button $ActionsTabServiceKillerButton
        Add-CommonButtonSettings -Button $ActionsTabAccountLogoutButton
        Add-CommonButtonSettings -Button $ActionsTabSelectNetworkConnectionsToKillButton
        Add-CommonButtonSettings -Button $WindowsTimelineButton
        Add-CommonButtonSettings -Button $ActionsTabQuarantineEndpointsButton
    }

    Resize-MonitorJobsTab -Minimize
    Check-IfScanExecutionReady
}



Update-FormProgress "Update-TreeViewState"
function Update-TreeViewState {
    <#
        .Description
        This will keep the Computer TreeNodes checked when switching between OS and OU/CN views
    #>
    param(
        [switch]$Accounts,
        [switch]$Endpoint,
    	[switch]$NoMessage
    )
    if ($Accounts) {
        $script:AccountsTreeView.Nodes.Add($script:TreeNodeComputerList)
        $script:AccountsTreeView.ExpandAll()

        if ($script:AccountsTreeViewSelected.count -gt 0) {
            ##if (-not $NoMessage) {
            ##    #Removed For Testing#$ResultsListBox.Items.Clear()
            ##    $ResultsListBox.Items.Add("Categories that were checked will not remained checked.")
            ##    $ResultsListBox.Items.Add("")
            ##    $ResultsListBox.Items.Add("The following hostname/IP selections are still selected in the new treeview:")
            ##}
            foreach ($root in $AllTreeViewNodes) {
                foreach ($Category in $root.Nodes) {
                    foreach ($Entry in $Category.nodes) {
                        $Entry.Collapse()
                        if ($script:AccountsTreeViewSelected -contains $Entry.text -and $root.text -notmatch 'Custom Group Commands') {
                            $Entry.Checked      = $true
                            $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                            $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,0,224)
                            $Category.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                            $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                           ## $ResultsListBox.Items.Add(" - $($Entry.Text)")
                        }
                        foreach ($Metadata in $Entry.Nodes){
                            $Metadata.Drawing = $False
                        }
                    }
                }
            }
        }
        else {
            foreach ($root in $AllTreeViewNodes) {
                foreach ($Category in $root.Nodes) {
                    foreach ($Entry in $Category.Nodes) {
                        $Entry.Collapse()
                        foreach ($Metadata in $Entry.Nodes){
                            $Metadata.Drawing = $false
                        }
                    }
                }
            }
        }
    }
    if ($Endpoint) {
        $script:ComputerTreeView.Nodes.Add($script:TreeNodeComputerList)
        $script:ComputerTreeView.ExpandAll()

        if ($script:ComputerTreeViewSelected.count -gt 0) {
            ##if (-not $NoMessage) {
            ##    #Removed For Testing#$ResultsListBox.Items.Clear()
            ##    $ResultsListBox.Items.Add("Categories that were checked will not remained checked.")
            ##    $ResultsListBox.Items.Add("")
            ##    $ResultsListBox.Items.Add("The following hostname/IP selections are still selected in the new treeview:")
            ##}
            foreach ($root in $AllTreeViewNodes) {
                foreach ($Category in $root.Nodes) {
                    foreach ($Entry in $Category.nodes) {
                        $Entry.Collapse()
                        if ($script:ComputerTreeViewSelected -contains $Entry.text -and $root.text -notmatch 'Custom Group Commands') {
                            $Entry.Checked      = $true
                            $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                            $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,0,224)
                            $Category.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                            $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                           ## $ResultsListBox.Items.Add(" - $($Entry.Text)")
                        }
                        foreach ($Metadata in $Entry.Nodes){
                            $Metadata.Drawing = $False
                        }
                    }
                }
            }
        }
        else {
            foreach ($root in $AllTreeViewNodes) {
                foreach ($Category in $root.Nodes) {
                    foreach ($Entry in $Category.Nodes) {
                        $Entry.Collapse()
                        foreach ($Metadata in $Entry.Nodes){
                            $Metadata.Drawing = $false
                        }
                    }
                }
            }
        }
    }
}



Update-FormProgress "Add-TreeViewData"
function Add-TreeViewData {
    <#
        .Description
        Adds a treenode to the specified root node... a computer node within a category node
    #>
    param (
        [switch]$Accounts,
        [switch]$Endpoint,
        $RootNode,
        $Category,
        $Entry,
        [switch]$DoNotPopulateMetadata,
        $Metadata,
        $IPv4Address,
        $ToolTip,
        $ImageIndex
    )
    if (-not $ImageIndex){
        $ImageIndex = $Metadata.ImageIndex
    }
    # checks if data is in date/datetime format, if so, it trims off the time
    if ($Category -match ".{1,2}/.{1,2}/.{4}") {
        #$Category = ($Category.ToString() -split ' ')[0]
        $Category = ([datetime]$Category).ToString("yyyy-MM-dd")
    }

    if ($Accounts) {
        $newNode = New-Object System.Windows.Forms.TreeNode -Property @{
            Name = "$Entry"
            Text = "$Entry"
            ImageIndex = $ImageIndex
        }

        # if (-not $DoNotPopulateMetadata) {
        #     TAG: sub nodes, sub-nodes, child nodes, dropdown nodes
        #     $MetadataCreated = New-Object System.Windows.Forms.TreeNode -Property @{
        #         Name = "Created"
        #         Text = "Created: $($Metadata.Created)"
        #     }
        #     $newNode.Nodes.Add($MetadataCreated)

        #     $MetadataModified = New-Object System.Windows.Forms.TreeNode -Property @{
        #         Name = "Modified"
        #         Text = "Modified: $($Metadata.Modified)"
        #     }
        #     $newNode.Nodes.Add($MetadataModified)

        #     $MetadataLockedOut = New-Object System.Windows.Forms.TreeNode -Property @{
        #         Name = "Locked Out"
        #         Text = "Locked Out: $($Metadata.LockedOut)"
        #     }
        #     $newNode.Nodes.Add($MetadataLockedOut)

        #     $MetadataGroups = New-Object System.Windows.Forms.TreeNode -Property @{
        #         Name = 'Group Membership'
        #         Text = 'Group Membership'
        #     }
        #     $newNode.Nodes.Add($MetadataGroups)

        #     $AccountGroups = $Metadata.MemberOf.split("`n")
        #     $MetadataGroups.Nodes.Add("[ Count: $(if ($AccountGroups -ne $null) {$AccountGroups.Count} else {0}) ]")
        #     foreach ($Group in $AccountGroups) {
        #         if ($AccountGroups -ne $null) {
        #             $MetadataEachGroup = New-Object System.Windows.Forms.TreeNode -Property @{
        #                 Name = $Group
        #                 Text = $Group
        #             }
        #             $MetadataGroups.Nodes.Add($MetadataEachGroup)
        #         }
        #     }
        # }

        if ($ToolTip) {
            $newNode.ToolTipText  = "$ToolTip"
        }
        else {
            $newNode.ToolTipText  = "No Unique Data Available"
        }

        If ($RootNode.Nodes.Tag -contains $Category) {
            $EndpointNode = $RootNode.Nodes | Where-Object {$_.Tag -eq $Category}
        }
        Else {
            $CategoryNode = New-Object System.Windows.Forms.TreeNode -Property @{
                Name        = $Category
                Text        = $Category
                Tag         = $Category
                ToolTipText = "Checkbox this Category to query select all child nodes"
                NodeFont    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
                ForeColor   = [System.Drawing.Color]::FromArgb(0,0,0,0)
            }
            $RootNode.Nodes.Add($CategoryNode)
            $EndpointNode = $RootNode.Nodes | Where-Object {$_.Tag -eq $Category}
        }
        $EndpointNode.Nodes.Add($newNode)
    }


    if ($Endpoint) {
        $newNode = New-Object System.Windows.Forms.TreeNode -Property @{
            Name = "$Entry"
            Text = "$Entry"
            ImageIndex = $ImageIndex
        }

        #batman #TODO work on this
        $MetadataOperatingSystem = New-Object System.Windows.Forms.TreeNode -Property @{
            Name = "OperatingSystem"
            Text = $($Metadata.OperatingSystem)
            Tag  = $($Metadata.OperatingSystem)
            ToolTipText = ""
            NodeFont    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
            ForeColor   = [System.Drawing.Color]::FromArgb(0,0,0,0)
        }
        $newNode.Nodes.Add($MetadataOperatingSystem)

        if (-not $DoNotPopulateMetadata) {
            # TAG: sub nodes, sub-nodes, child nodes, dropdown nodes
            $MetadataIPv4Address = New-Object System.Windows.Forms.TreeNode -Property @{
                Name = "IPv4Address"
                Text = $Metadata.IPv4Address
            }
            $MetadataIPv4Address.Bounds.Height = 0
            $MetadataIPv4Address.Bounds.Width = 0
            $newNode.Nodes.Add($MetadataIPv4Address)

            $MetadataIPv4Ports = New-Object System.Windows.Forms.TreeNode -Property @{
                Name = 'Port Scan'
                Text = 'Port Scan'
            }
            $newNode.Nodes.Add($MetadataIPv4Ports)

            $MetadataIPv4Ports.Nodes.Add("[ Count: $(if ($Metadata.PortScan -ne $null) {$Metadata.PortScan.split(',').Count} else{0}) ]")
            foreach ($PortScan in ($Metadata.PortScan.split(','))) {
                if ($Metadata.PortScan -ne $null){
                    $MetadataIPv4EachPort = New-Object System.Windows.Forms.TreeNode -Property @{
                        Name = $PortScan
                        Text = $PortScan
                    }
                    $MetadataIPv4Ports.Nodes.Add($MetadataIPv4EachPort)
                }
            }
        }

        if ($ToolTip) {
            $newNode.ToolTipText  = "$ToolTip"
        }
        else {
            $newNode.ToolTipText  = "No Unique Data Available"
        }

        If ($RootNode.Nodes.Tag -contains $Category) {
            $EndpointNode = $RootNode.Nodes | Where-Object {$_.Tag -eq $Category}
        }
        Else {
            $CategoryNode = New-Object System.Windows.Forms.TreeNode -Property @{
                Name        = $Category
                Text        = $Category
                Tag         = $Category
                ToolTipText = "Checkbox this Category to query all its hosts"
                NodeFont    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
                ForeColor   = [System.Drawing.Color]::FromArgb(0,0,0,0)
            }
            $RootNode.Nodes.Add($CategoryNode)
            $EndpointNode = $RootNode.Nodes | Where-Object {$_.Tag -eq $Category}
        }
        $EndpointNode.Nodes.Add($newNode)
    }
}



Update-FormProgress "Search-TreeViewData"
function Search-TreeViewData {
    <#
        .Description
        Searches for Accounts nodes that match a given search entry
        A new category node named by the search entry will be created and all results will be nested within
    #>
    param(
        [switch]$Accounts,
        [switch]$Endpoint
    )

    if ($Accounts) {
        #$InformationTabControl.SelectedTab   = $Section3ResultsTab
        [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:AccountsTreeView.Nodes

        # Checks if the search node already exists
        $SearchNode = $false
        foreach ($root in $AllTreeViewNodes) {
            if ($root.text -imatch 'Search Results') { $SearchNode = $true }
        }
        if ($SearchNode -eq $false) { $script:AccountsTreeView.Nodes.Add($script:AccountsListSearch) }


        $AccountsSearchText = $AccountsTreeNodeSearchComboBox.Text

        # Checks if the search has already been conduected
        $SearchCheck = $false
        foreach ($root in $AllTreeViewNodes) {
            if ($root.text -imatch 'Search Results') {
                foreach ($Category in $root.Nodes) {
                    if ($Category.text -eq $AccountsSearchText) { $SearchCheck = $true}
                }
            }
        }

        # Conducts the search, if something is found it will add it to the treeview
        # Will not produce multiple results if the host triggers in more than one field
        $SearchFoundNotes         = @()
        $SearchFoundName          = @()
        $SearchFoundCanonicalName = @()
        $SearchFoundMemberOf      = @()
        $SearchFoundScriptPath    = @()
        $SearchFoundHomeDrive     = @()
        if ($AccountsSearchText -ne "" -and $SearchCheck -eq $false) {
            if ($AccountsTreeNodeSearchGreedyCheckbox.checked) {
                Foreach($Account in $script:AccountsTreeViewData) {
                    if (($SearchFoundNotes -inotcontains $Account.Name) -and ($Account.Notes -imatch $AccountsSearchText)) {
                        Add-TreeViewData -Accounts -RootNode $script:AccountsListSearch -Category $($AccountsSearchText + ' [Notes]') -Entry $Account.Name -DoNotPopulateMetadata
                        $SearchFoundNotes += $Account.Name
                    }
                    if (($SearchFoundName -inotcontains $Account.Name) -and ($Account.Name -imatch $AccountsSearchText)) {
                        Add-TreeViewData -Accounts -RootNode $script:AccountsListSearch -Category $($AccountsSearchText + ' [Name]') -Entry $Account.Name -DoNotPopulateMetadata
                        $SearchFoundName += $Account.Name
                    }
                    if (($SearchFoundCanonicalName -inotcontains $Account.Name) -and ($Account.CanonicalName -imatch $AccountsSearchText)) {
                        Add-TreeViewData -Accounts -RootNode $script:AccountsListSearch -Category $($AccountsSearchText + ' [OU/CN]') -Entry $Account.Name -DoNotPopulateMetadata
                        $SearchFoundCanonicalName += $Account.Name
                    }
                    $AccountSearchGroupList = $Account.MemberOf.split("`n") | Sort-Object
                    ForEach ($Group in $AccountSearchGroupList) {
                        if (($SearchFoundMemberOf -inotcontains $Account.Name) -and ($Group -imatch $AccountsSearchText)) {
                            Add-TreeViewData -Accounts -RootNode $script:AccountsListSearch -Category $($AccountsSearchText + ' [Group]') -Entry $Account.Name -DoNotPopulateMetadata
                            $SearchFoundMemberOf += $Account.Name
                        }
                    }
                    if (($SearchFoundScriptPath -inotcontains $Account.Name) -and ($Account.ScriptPath -imatch $AccountsSearchText)) {
                        Add-TreeViewData -Accounts -RootNode $script:AccountsListSearch -Category $($AccountsSearchText + ' [Script Path]') -Entry $Account.Name -DoNotPopulateMetadata
                        $SearchFoundScriptPath += $Account.Name
                    }
                    if (($SearchFoundHomeDrive -inotcontains $Account.Name) -and ($Account.HomeDrive -imatch $AccountsSearchText)) {
                        Add-TreeViewData -Accounts -RootNode $script:AccountsListSearch -Category $($AccountsSearchText + ' [Home Drive]') -Entry $Account.Name -DoNotPopulateMetadata
                        $SearchFoundHomeDrive += $Account.Name
                    }
                }
            }
            else {
                Foreach($Account in $script:AccountsTreeViewData) {
                    if (($SearchFoundNotes -inotcontains $Account.Name) -and ($Account.Notes -eq $AccountsSearchText)) {
                        Add-TreeViewData -Accounts -RootNode $script:AccountsListSearch -Category $($AccountsSearchText + ' [Notes]') -Entry $Account.Name -DoNotPopulateMetadata
                        $SearchFoundNotes += $Account.Name
                    }
                    if (($SearchFoundName -inotcontains $Account.Name) -and ($Account.Name -eq $AccountsSearchText)) {
                        Add-TreeViewData -Accounts -RootNode $script:AccountsListSearch -Category $($AccountsSearchText + ' [Name]') -Entry $Account.Name -DoNotPopulateMetadata
                        $SearchFoundName += $Account.Name
                    }
                    if (($SearchFoundCanonicalName -inotcontains $Account.Name) -and ($Account.CanonicalName -eq $AccountsSearchText)) {
                        Add-TreeViewData -Accounts -RootNode $script:AccountsListSearch -Category $($AccountsSearchText + ' [OU/CN]') -Entry $Account.Name -DoNotPopulateMetadata
                        $SearchFoundCanonicalName += $Account.Name
                    }
                    $AccountSearchGroupList = $Account.MemberOf.split("`n") | Sort-Object
                    ForEach ($Group in $AccountSearchGroupList) {
                        if (($SearchFoundMemberOf -inotcontains $Account.Name) -and ($Group -eq $AccountsSearchText)) {
                            Add-TreeViewData -Accounts -RootNode $script:AccountsListSearch -Category $($AccountsSearchText + ' [Group]') -Entry $Account.Name -DoNotPopulateMetadata
                            $SearchFoundMemberOf += $Account.Name
                        }
                    }
                    if (($SearchFoundScriptPath -inotcontains $Account.Name) -and ($Account.ScriptPath -eq $AccountsSearchText)) {
                        Add-TreeViewData -Accounts -RootNode $script:AccountsListSearch -Category $($AccountsSearchText + ' [Script Path]') -Entry $Account.Name -DoNotPopulateMetadata
                        $SearchFoundScriptPath += $Account.Name
                    }
                    if (($SearchFoundHomeDrive -inotcontains $Account.Name) -and ($Account.HomeDrive -eq $AccountsSearchText)) {
                        Add-TreeViewData -Accounts -RootNode $script:AccountsListSearch -Category $($AccountsSearchText + ' [Home Drive]') -Entry $Account.Name -DoNotPopulateMetadata
                        $SearchFoundHomeDrive += $Account.Name
                    }
                }
            }
        }


        # Manages TreeView Appearance when Search Results are found
        [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:AccountsTreeView.Nodes
        foreach ($root in $AllTreeViewNodes) {
            if ($root.text -match 'Search Results'){
                $root.Collapse()
                $root.Expand()
                foreach ($Category in $root.Nodes) {
                    if ($AccountsSearchText -in $Category.text) {
                        $Category.Expand()
                    }
                    else {
                        $Category.Collapse()
                    }
                }
            }
        }
        $AccountsSearchText = ""
        $script:AccountsTreeView.Enabled   = $true
        $script:AccountsTreeView.BackColor = "white"
    }






    if ($Endpoint) {
        #$InformationTabControl.SelectedTab   = $Section3ResultsTab
        [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes

        # Checks if the search node already exists
        $SearchNode = $false
        foreach ($root in $AllTreeViewNodes) {
            if ($root.text -imatch 'Search Results') { $SearchNode = $true }
        }
        if ($SearchNode -eq $false) { $script:ComputerTreeView.Nodes.Add($script:ComputerListSearch) }


        $ComputerSearchText = $ComputerTreeNodeSearchComboBox.Text

        # Checks if the search has already been conduected
        $SearchCheck = $false
        foreach ($root in $AllTreeViewNodes) {
            if ($root.text -imatch 'Search Results') {
                foreach ($Category in $root.Nodes) {
                    if ($Category.text -eq $ComputerSearchText) { $SearchCheck = $true}
                }
            }
        }

        # Conducts the search, if something is found it will add it to the treeview
        # Will not produce multiple results if the host triggers in more than one field
        $SearchFoundNotes                      = @()
        $SearchFoundName                       = @()
        $SearchFoundOperatingSystem            = @()
        $SearchFoundCanonicalName              = @()
        $SearchFoundIPv4address                = @()
        $SearchFoundMACAddress                 = @()
        $SearchFoundOperatingSystemHotfix      = @()
        $SearchFoundOperatingSystemServicePack = @()
        $SearchFoundMemberOf                   = @()
        $SearchFoundLocation                   = @()
        $SearchFoundPortScan                   = @()
        if ($ComputerSearchText -ne "" -and $SearchCheck -eq $false) {
            if ($ComputerTreeNodeSearchGreedyCheckbox.checked) {
                Foreach($Computer in $script:ComputerTreeViewData) {
                    if (($SearchFoundNotes -inotcontains $Computer.Name) -and ($Computer.Notes -imatch $ComputerSearchText)) {
                        Add-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [Notes]') -Entry $Computer.Name -DoNotPopulateMetadata
                        $SearchFoundNotes += $Computer.Name
                    }
                    if (($SearchFoundName -inotcontains $Computer.Name) -and ($Computer.Name -imatch $ComputerSearchText)) {
                        Add-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [Name]') -Entry $Computer.Name -DoNotPopulateMetadata
                        $SearchFoundName += $Computer.Name
                    }
                    if (($SearchFoundOperatingSystem -inotcontains $Computer.Name) -and ($Computer.OperatingSystem -imatch $ComputerSearchText)) {
                        Add-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [OS]') -Entry $Computer.Name -DoNotPopulateMetadata
                        $SearchFoundOperatingSystem += $Computer.Name
                    }
                    if (($SearchFoundCanonicalName -inotcontains $Computer.Name) -and ($Computer.CanonicalName -imatch $ComputerSearchText)) {
                        Add-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [OU/CN]') -Entry $Computer.Name -DoNotPopulateMetadata
                        $SearchFoundCanonicalName += $Computer.Name
                    }
                    if (($SearchFoundIPv4address -inotcontains $Computer.Name) -and ($Computer.IPv4address -imatch $ComputerSearchText)) {
                        Add-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [IP]') -Entry $Computer.Name -DoNotPopulateMetadata
                        $SearchFoundIPv4address += $Computer.Name
                    }
                    if (($SearchFoundMACAddress -inotcontains $Computer.Name) -and ($Computer.MACAddress -imatch $ComputerSearchText)) {
                        Add-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [MAC]') -Entry $Computer.Name -DoNotPopulateMetadata
                        $SearchFoundMACAddress += $Computer.Name
                    }
                    if (($SearchFoundOperatingSystemHotfix -inotcontains $Computer.Name) -and ($Computer.OperatingSystemHotfix -imatch $ComputerSearchText)) {
                        Add-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [Hotfix]') -Entry $Computer.Name -DoNotPopulateMetadata
                        $SearchFoundOperatingSystemHotfix += $Computer.Name
                    }
                    if (($SearchFoundOperatingSystemServicePack -inotcontains $Computer.Name) -and ($Computer.OperatingSystemServicePack -imatch $ComputerSearchText)) {
                        Add-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [Service Pack]') -Entry $Computer.Name -DoNotPopulateMetadata
                        $SearchFoundOperatingSystemServicePack += $Computer.Name
                    }
                    if (($SearchFoundMemberOf -inotcontains $Computer.Name) -and ($Computer.MemberOf -imatch $ComputerSearchText)) {
                        Add-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [Group]') -Entry $Computer.Name -DoNotPopulateMetadata
                        $SearchFoundMemberOf += $Computer.Name
                    }
                    if (($SearchFoundLocation -inotcontains $Computer.Name) -and ($Computer.Location -imatch $ComputerSearchText)) {
                        Add-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [Location]') -Entry $Computer.Name -DoNotPopulateMetadata
                        $SearchFoundLocation += $Computer.Name
                    }
                    if ($Computer.PortScan) {
                        $EndpointPortScanList = $Computer.PortScan.split(",") | Sort-Object
                    }
                    else {
                        $EndpointPortScanList = $null
                    }
                    ForEach ($Port in $EndpointPortScanList) {
                        if (($SearchFoundPortScan -inotcontains $Computer.Name) -and ($Port -imatch $ComputerSearchText)) {
                            Add-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [Port Scan]') -Entry $Computer.Name -DoNotPopulateMetadata
                            $SearchFoundPortScan += $Computer.Name
                        }
                    }
                }
            }
            else {
                Foreach($Computer in $script:ComputerTreeViewData) {
                    if (($SearchFoundNotes -inotcontains $Computer.Name) -and ($Computer.Notes -eq $ComputerSearchText)) {
                        Add-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [Notes]') -Entry $Computer.Name -DoNotPopulateMetadata
                        $SearchFoundNotes += $Computer.Name
                    }
                    if (($SearchFoundName -inotcontains $Computer.Name) -and ($Computer.Name -eq $ComputerSearchText)) {
                        Add-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [Name]') -Entry $Computer.Name -DoNotPopulateMetadata
                        $SearchFoundName += $Computer.Name
                    }
                    if (($SearchFoundOperatingSystem -inotcontains $Computer.Name) -and ($Computer.OperatingSystem -eq $ComputerSearchText)) {
                        Add-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [OS]') -Entry $Computer.Name -DoNotPopulateMetadata
                        $SearchFoundOperatingSystem += $Computer.Name
                    }
                    if (($SearchFoundCanonicalName -inotcontains $Computer.Name) -and ($Computer.CanonicalName -eq $ComputerSearchText)) {
                        Add-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [OU/CN]') -Entry $Computer.Name -DoNotPopulateMetadata
                        $SearchFoundCanonicalName += $Computer.Name
                    }
                    if (($SearchFoundIPv4address -inotcontains $Computer.Name) -and ($Computer.IPv4address -eq $ComputerSearchText)) {
                        Add-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [IP]') -Entry $Computer.Name -DoNotPopulateMetadata
                        $SearchFoundIPv4address += $Computer.Name
                    }
                    if (($SearchFoundMACAddress -inotcontains $Computer.Name) -and ($Computer.MACAddress -eq $ComputerSearchText)) {
                        Add-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [MAC]') -Entry $Computer.Name -DoNotPopulateMetadata
                        $SearchFoundMACAddress += $Computer.Name
                    }
                    if (($SearchFoundOperatingSystemHotfix -inotcontains $Computer.Name) -and ($Computer.OperatingSystemHotfix -eq $ComputerSearchText)) {
                        Add-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [HotFix]') -Entry $Computer.Name -DoNotPopulateMetadata
                        $SearchFoundOperatingSystemHotfix += $Computer.Name
                    }
                    if (($SearchFoundOperatingSystemServicePack -inotcontains $Computer.Name) -and ($Computer.OperatingSystemServicePack -eq $ComputerSearchText)) {
                        Add-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [Service Pack]') -Entry $Computer.Name -DoNotPopulateMetadata
                        $SearchFoundOperatingSystemServicePack += $Computer.Name
                    }
                    if (($SearchFoundMemberOf -inotcontains $Computer.Name) -and ($Computer.MemberOf -eq $ComputerSearchText)) {
                        Add-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [Group]') -Entry $Computer.Name -DoNotPopulateMetadata
                        $SearchFoundMemberOf += $Computer.Name
                    }
                    if (($SearchFoundLocation -inotcontains $Computer.Name) -and ($Computer.Location -eq $ComputerSearchText)) {
                        Add-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [Location]') -Entry $Computer.Name -DoNotPopulateMetadata
                        $SearchFoundLocation += $Computer.Name
                    }
                    if ($Computer.PortScan) {
                        $EndpointPortScanList = $Computer.PortScan.split(",") | Sort-Object
                    }
                    else {
                        $EndpointPortScanList = $null
                    }
                    ForEach ($Port in $EndpointPortScanList) {
                        if (($SearchFoundPortScan -inotcontains $Computer.Name) -and ($Port -eq $ComputerSearchText)) {
                            Add-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [Port Scan]') -Entry $Computer.Name -DoNotPopulateMetadata
                            $SearchFoundPortScan += $Computer.Name
                        }
                    }
                }
            }

            # Checks if the Option is checked, if so it will include searching through 'Processes' CSVs
            # This is a slow process...
            if ($OptionSearchProcessesCheckBox.Checked -or $OptionSearchServicesCheckBox.Checked -or $OptionSearchNetworkTCPConnectionsCheckBox.Checked) {
                # Searches though the all Collection Data Directories to find files that match
                $ListOfCollectedDataDirectories = $(Get-ChildItem -Path $PewCollectedData | Sort-Object -Descending).FullName | Select-Object -first $PewCollectedDataSearchLimitCombobox.text
                $script:CSVFileMatch = @()

                foreach ($CollectionDir in $ListOfCollectedDataDirectories) {
                    $CSVFiles = $(Get-ChildItem -Path $CollectionDir -Filter "*.csv" -Recurse).FullName | Where {$_ -match  "Collected Data" -and $_ -notmatch "Results By Endpoints"}
                    foreach ($CSVFile in $CSVFiles) {
                        if ($OptionSearchProcessesCheckBox.Checked) {
                            # Searches for the CSV file that matches the data selected
                            if ($CSVFile -match "Processes") {
                                if ($ComputerTreeNodeSearchGreedyCheckbox.checked) {
                                    $SearchImportedCsvData = Import-CSV -Path $CSVFile | Select-Object -Property ComputerName, ProcessName, Name, Description  | where {($_.ProcessName -imatch $ComputerSearchText) -or ($_.Name -imatch $ComputerSearchText) -or ($_.Description -imatch $ComputerSearchText)} #| where {$_.name -ne ''}
                                }
                                else {
                                    $SearchImportedCsvData = Import-CSV -Path $CSVFile | Select-Object -Property ComputerName, ProcessName, Name, Description  | where {($_.ProcessName -eq $ComputerSearchText) -or ($_.Name -eq $ComputerSearchText) -or ($_.Description -eq $ComputerSearchText)} #| where {$_.name -ne ''}
                                }
                                $SearchImportedCsvData = $SearchImportedCsvData | Select-Object -ExpandProperty ComputerName -Unique
                                if ( $SearchImportedCsvData ) {
                                    foreach ($PSComputerName in $SearchImportedCsvData) {
                                        Add-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [Process]') -Entry $PSComputerName -DoNotPopulateMetadata
                                        $SearchFound += $ComputerWithResults
                                    }
                                }
                            }
                        }
                        if ($OptionSearchServicesCheckBox.Checked) {
                            # Searches for the CSV file that matches the data selected
                            if ($CSVFile -match "Services") {
                                if ($ComputerTreeNodeSearchGreedyCheckbox.checked) {
                                    $SearchImportedCsvData = Import-CSV -Path $CSVFile | Select-Object -Property ComputerName, Name, DisplayName  | where {($_.Name -imatch $ComputerSearchText) -or ($_.DisplayName -imatch $ComputerSearchText)} #| where {$_.name -ne ''}
                                }
                                else {
                                    $SearchImportedCsvData = Import-CSV -Path $CSVFile | Select-Object -Property ComputerName, Name, DisplayName  | where {($_.Name -eq $ComputerSearchText) -or ($_.DisplayName -eq $ComputerSearchText)} #| where {$_.name -ne ''}
                                }
                                $SearchImportedCsvData = $SearchImportedCsvData | Select-Object -ExpandProperty ComputerName -Unique
                                if ( $SearchImportedCsvData ) {
                                    foreach ($PSComputerName in $SearchImportedCsvData) {
                                        Add-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [Service]') -Entry $PSComputerName -DoNotPopulateMetadata
                                        $SearchFound += $ComputerWithResults
                                    }
                                }
                            }
                        }
                        if ($OptionSearchNetworkTCPConnectionsCheckBox.Checked) {
                            # Searches for the CSV file that matches the data selected
                            if ($CSVFile -match "Network") {
                                if ($ComputerTreeNodeSearchGreedyCheckbox.checked) {
                                    $SearchImportedCsvData = Import-CSV -Path $CSVFile | Select-Object -Property ComputerName, RemoteAddress, RemotePort, LocalPort, ProcessName, CommandLine | where {($_.CommandLine -imatch $ComputerSearchText) -or ($_.ProcessName -imatch $ComputerSearchText) -or ($_.RemoteAddress -imatch $ComputerSearchText) -or ($_.RemotePort -imatch $ComputerSearchText) -or ($_.LocalPort -imatch $ComputerSearchText)} #| where {$_.name -ne ''}
                                }
                                else {
                                    $SearchImportedCsvData = Import-CSV -Path $CSVFile | Select-Object -Property ComputerName, RemoteAddress, RemotePort, LocalPort, ProcessName, CommandLine | where {($_.CommandLine -eq $ComputerSearchText) -or ($_.ProcessName -eq $ComputerSearchText) -or ($_.RemoteAddress -eq $ComputerSearchText) -or ($_.RemotePort -eq $ComputerSearchText) -or ($_.LocalPort -eq $ComputerSearchText)} #| where {$_.name -ne ''}
                                }

                                $SearchImportedCsvData = $SearchImportedCsvData | Select-Object -ExpandProperty ComputerName -Unique
                                if ( $SearchImportedCsvData ) {
                                    foreach ($PSComputerName in $SearchImportedCsvData) {
                                        Add-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [Network]') -Entry $PSComputerName -DoNotPopulateMetadata
                                        $SearchFound += $ComputerWithResults
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }


        # Manages TreeView Appearance when Search Results are found
        [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
        foreach ($root in $AllTreeViewNodes) {
            if ($root.text -match 'Search Results'){
                $root.Collapse()
                $root.Expand()
                foreach ($Category in $root.Nodes) {
                    if ($ComputerSearchText -in $Category.text) {
                        $Category.Expand()
                    }
                    else {
                        $Category.Collapse()
                    }
                }
            }
        }
        $ComputerSearchText = ""
        $script:ComputerTreeView.Enabled   = $true
        $script:ComputerTreeView.BackColor = "white"
    }
}



Update-FormProgress "Remove-TreeViewEmptyCategory"
function Remove-TreeViewEmptyCategory {
    <#
        .Description
        Code to remove empty categoryies
    #>
    param(
        [switch]$Accounts,
        [switch]$Endpoint
    )
    if ($Accounts) {
        # Checks if the category node is empty, if so the node is removed
        [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:AccountsTreeView.Nodes
        foreach ($root in $AllTreeViewNodes) {
            foreach ($Category in $root.Nodes) {
                [int]$CategoryNodeContentCount = 0
                # Counts the number of computer nodes in each category
                foreach ($Entry in $Category.nodes) {
                    if ($Entry.Test -ne '' -and $Entry.Text -ne $null){
                        $CategoryNodeContentCount += 1
                    }
                }
                # Removes a category node if it is empty
                if ($CategoryNodeContentCount -eq 0 ) {
                    $Category.remove()
                }
            }
        }
    }
    if ($Endpoint) {
        # Checks if the category node is empty, if so the node is removed
        [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
        foreach ($root in $AllTreeViewNodes) {
            foreach ($Category in $root.Nodes) {
                [int]$CategoryNodeContentCount = 0
                # Counts the number of computer nodes in each category
                foreach ($Entry in $Category.nodes) {
                    if ($Entry.Test -ne '' -and $Entry.Text -ne $null){
                        $CategoryNodeContentCount += 1
                    }
                }
                # Removes a category node if it is empty
                if ($CategoryNodeContentCount -eq 0 ) {
                    $Category.remove()
                }
            }
        }
    }
}



Update-FormProgress "Message-TreeViewNodeAlreadyExists"
Function Message-TreeViewNodeAlreadyExists {
    param(
        [switch]$Accounts,
        [switch]$Endpoint,
        $Message,
        $Account,
        $Computer,
        [Switch]$ResultsListBoxMessage
    )
    if ($Accounts) {
        $InformationTabControl.SelectedTab = $Section3ResultsTab
        [system.media.systemsounds]::Exclamation.play()
        if ($Account){
            $AccountsNameExist = $Account
        }
        elseif ($Account.Name) {
            $AccountsNameExist = $Account.Name
        }

        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("$Message")

        if ($ResultsListBoxMessage) {
            $ResultsListBox.Items.Add("The following Account already exists: $AccountsNameExist")
            $ResultsListBox.Items.Add("- OS:    $($($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Account}).OperatingSystem)")
            $ResultsListBox.Items.Add("- OU/CN: $($($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Account}).CanonicalName)")
            $ResultsListBox.Items.Add("")
            $PoShEasyWin.Refresh()
        }
        else {
            Show-MessageBox -Message "The following Account already exists: $AccountsNameExist
- OU/CN:      $($($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Account}).CanonicalName)
- Created:    $($($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Account}).Created)
- LockedOut:  $($($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Account}).LockedOut)" -Title "PoSh-EasyWin" -Options "Ok" -Type "Error" -Sound
        }
        #$ResultsListBox.Items.Add("- IP:    $($($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Account}).IPv4Address)")
        #$ResultsListBox.Items.Add("- MAC:   $($($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Account}).MACAddress)")
    }
    if ($Endpoint) {
        $InformationTabControl.SelectedTab = $Section3ResultsTab
        [system.media.systemsounds]::Exclamation.play()
        if ($Computer){
            $ComputerNameExist = $Computer
        }
        elseif ($Computer.Name) {
            $ComputerNameExist = $Computer.Name
        }

        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("$Message")

        if ($ResultsListBoxMessage) {
            $ResultsListBox.Items.Add("The following Endpoint already exists: $ComputerNameExist")
            $ResultsListBox.Items.Add("- OS:    $($($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Computer}).OperatingSystem)")
            $ResultsListBox.Items.Add("- OU/CN: $($($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Computer}).CanonicalName)")
            $ResultsListBox.Items.Add("")
            $PoShEasyWin.Refresh()
        }
        else {
            Show-MessageBox -Message "Info: The following Endpoint already exists: $ComputerNameExist
- OU/CN: $($($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Computer}).CanonicalName)
- OS:    $($($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Computer}).OperatingSystem)" -Title "PoSh-EasyWin" -Options "Ok" -Type "Information" -Sound
        }
        #$ResultsListBox.Items.Add("- IP:    $($($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Computer}).IPv4Address)")
        #$ResultsListBox.Items.Add("- MAC:   $($($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Computer}).MACAddress)")
    }
}



Update-FormProgress "Show-TreeViewMoveForm"
function Show-TreeViewMoveForm {
    <#
        .Description
    #>
    param(
        [switch]$Accounts,
        [switch]$Endpoint,
        [switch]$SelectedAccounts,
        [switch]$SelectedEndpoint,
        $Title
    )

    if ($Accounts) {
        $AccountsTreeNodePopup = New-Object system.Windows.Forms.Form -Property @{
            Text          = "Move"
            Size          = New-Object System.Drawing.Size(($FormScale * 330),($FormScale * 107))
            StartPosition = "CenterScreen"
            Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
            Add_Closing = { $This.dispose() }
        }
        $AccountsTreeNodePopup.Text = $Title


        $AccountsTreeNodePopupMoveComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
            Text     = "Select A Category"
            Location = @{ X = $FormScale * 10
                          Y = $FormScale * 10 }
            Size     = @{ Width  = $FormScale * 300
                          Height = $FormScale * 25 }
            AutoCompleteSource = "ListItems"
            AutoCompleteMode   = "SuggestAppend"
            Font               = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        # Dynamically creates the combobox's Category list used for the move destination
        $AccountsTreeNodeCategoryList = @()
        [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:AccountsTreeView.Nodes
        ForEach ($root in $AllTreeViewNodes) { foreach ($Category in $root.Nodes) { $AccountsTreeNodeCategoryList += $Category.text } }
        ForEach ($Item in $AccountsTreeNodeCategoryList) { $AccountsTreeNodePopupMoveComboBox.Items.Add($Item) }

        # Moves the hostname/IPs to the new Category
        $AccountsTreeNodePopupMoveComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") {
            # This brings specific tabs to the forefront/front view
            $InformationTabControl.SelectedTab = $Section3ResultsTab
            if ($SelectedAccounts){ Move-TreeViewData -Accounts -SelectedAccounts }
            else { Move-TreeViewData -Accounts }
            $AccountsTreeNodePopup.close()
        } })
        $AccountsTreeNodePopup.Controls.Add($AccountsTreeNodePopupMoveComboBox)


        $AccountsTreeNodePopupExecuteButton = New-Object System.Windows.Forms.Button -Property @{
            Text     = "Execute"
            Location = @{ X = $FormScale * 210
                          Y = $AccountsTreeNodePopupMoveComboBox.Size.Height + ($FormScale * 15) }
            Size     = @{ Width  = $FormScale * 100
                          Height = $FormScale * 25 }
            Add_Click = {
                # This brings specific tabs to the forefront/front view
                $InformationTabControl.SelectedTab = $Section3ResultsTab
                if ($SelectedAccounts){ Move-TreeViewData -Accounts -SelectedAccounts }
                else { Move-TreeViewData -Accounts }
                $AccountsTreeNodePopup.close()
            }
        }
        Add-CommonButtonSettings -Button $AccountsTreeNodePopupExecuteButton
        $AccountsTreeNodePopup.Controls.Add($AccountsTreeNodePopupExecuteButton)
        $AccountsTreeNodePopup.ShowDialog()
    }
    if ($Endpoint) {
        $ComputerTreeNodePopup = New-Object system.Windows.Forms.Form -Property @{
            Text          = "Move"
            Size          = New-Object System.Drawing.Size(($FormScale * 330),($FormScale * 107))
            StartPosition = "CenterScreen"
            Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
            Add_Closing = { $This.dispose() }
        }
        $ComputerTreeNodePopup.Text = $Title


        $ComputerTreeNodePopupMoveComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
            Text     = "Select A Category"
            Location = @{ X = $FormScale * 10
                          Y = $FormScale * 10 }
            Size     = @{ Width  = $FormScale * 300
                          Height = $FormScale * 25 }
            AutoCompleteSource = "ListItems"
            AutoCompleteMode   = "SuggestAppend"
            Font               = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        # Dynamically creates the combobox's Category list used for the move destination
        $ComputerTreeNodeCategoryList = @()
        [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
        ForEach ($root in $AllTreeViewNodes) { foreach ($Category in $root.Nodes) { $ComputerTreeNodeCategoryList += $Category.text } }
        ForEach ($Item in $ComputerTreeNodeCategoryList) { $ComputerTreeNodePopupMoveComboBox.Items.Add($Item) }

        # Moves the hostname/IPs to the new Category
        $ComputerTreeNodePopupMoveComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") {
            # This brings specific tabs to the forefront/front view
            $InformationTabControl.SelectedTab = $Section3ResultsTab
            if ($SelectedEndpoint){ Move-TreeViewData -Endpoint -SelectedEndpoint }
            else { Move-TreeViewData -Endpoint }
            $ComputerTreeNodePopup.close()
        } })
        $ComputerTreeNodePopup.Controls.Add($ComputerTreeNodePopupMoveComboBox)


        $ComputerTreeNodePopupExecuteButton = New-Object System.Windows.Forms.Button -Property @{
            Text     = "Execute"
            Location = @{ X = $FormScale * 210
                          Y = $ComputerTreeNodePopupMoveComboBox.Size.Height + ($FormScale * 15) }
            Size     = @{ Width  = $FormScale * 100
                          Height = $FormScale * 25 }
            Add_Click = {
                # This brings specific tabs to the forefront/front view
                $InformationTabControl.SelectedTab = $Section3ResultsTab
                if ($SelectedEndpoint){ Move-TreeViewData -Endpoint -SelectedEndpoint }
                else { Move-TreeViewData -Endpoint }
                $ComputerTreeNodePopup.close()
            }
        }
        Add-CommonButtonSettings -Button $ComputerTreeNodePopupExecuteButton
        $ComputerTreeNodePopup.Controls.Add($ComputerTreeNodePopupExecuteButton)
        $ComputerTreeNodePopup.ShowDialog()
    }
}



Update-FormProgress "Show-TreeViewTagForm"
function Show-TreeViewTagForm {
    <#
        .Description
    #>
    param(
        [switch]$Endpoint,
        [switch]$Accounts
    )
    if ($Endpoint){
        $script:ComputerListMassTagValue = $null
        $ComputerListMassTagForm = New-Object System.Windows.Forms.Form -Property @{
            Text = "Tag Endpoints"
            Size     = @{ Width  = $FormScale * 350
                          Height = $FormScale * 115 }
            StartPosition = "CenterScreen"
            Font = New-Object System.Drawing.Font('Courier New',$($FormScale * 11),0,0,0)
            Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
            Add_Closing = { $This.dispose() }
        }


        $ComputerListMassTagNewTagNameLabel = New-Object System.Windows.Forms.Label -Property @{
            Text     = "Tag Name:"
            Location = @{ X = $FormScale * 5
                          Y = $FormScale * 14 }
            Size     = @{ Width  = $FormScale * 100
                          Height = $FormScale * 25 }
        }


        $ComputerListMassTagNewTagNameComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
            Text     = ""
            Location = @{ X = $ComputerListMassTagNewTagNameLabel.Location.X + $ComputerListMassTagNewTagNameLabel.Size.Width + $($FormScale * 5)
                          Y = $FormScale * 10 }
            Size     = @{ Width  = $FormScale * 215
                          Height = $FormScale * 25 }
            AutoCompleteSource = "ListItems"
            AutoCompleteMode   = "SuggestAppend"
        }
        ForEach ($Tag in $TagListFileContents) { $ComputerListMassTagNewTagNameComboBox.Items.Add($Tag) }
        $ComputerListMassTagNewTagNameComboBox.Add_KeyDown({
            if ($_.KeyCode -eq "Enter" -and $ComputerListMassTagNewTagNameComboBox.text -ne '') {
                $script:ComputerListMassTagValue = $ComputerListMassTagNewTagNameComboBox.text
                $ComputerListMassTagForm.Close()
            }
        })


        $ComputerListMassTagNewTagNameButton = New-Object System.Windows.Forms.Button -Property @{
            Text     = "Apply Tag"
            Location = @{ X = $ComputerListMassTagNewTagNameLabel.Location.X + $($FormScale * 104)
                          Y = $ComputerListMassTagNewTagNameLabel.Location.Y + $ComputerListMassTagNewTagNameLabel.Size.Height + $($FormScale * 2) }
            Size     = @{ Width  = $FormScale * 100
                          Height = $FormScale * 25 }
            Add_Click = {
                if ($ComputerListMassTagNewTagNameComboBox.text -ne '') {
                    $script:ComputerListMassTagValue = $ComputerListMassTagNewTagNameComboBox.text
                    $ComputerListMassTagForm.Close()
                }
            }
        }
        Add-CommonButtonSettings -Button $ComputerListMassTagNewTagNameButton


        $ComputerListMassTagForm.Controls.AddRange(@($ComputerListMassTagNewTagNameLabel,$ComputerListMassTagNewTagNameComboBox,$ComputerListMassTagNewTagNameButton))
        $ComputerListMassTagForm.Add_Shown({$ComputerListMassTagForm.Activate()})
        $ComputerListMassTagForm.ShowDialog()
    }
    elseif ($Accounts){
        $script:AccountsListMassTagValue = $null
        $AccountsListMassTagForm = New-Object System.Windows.Forms.Form -Property @{
            Text = "Tag Accounts"
            Size     = @{ Width  = $FormScale * 350
                          Height = $FormScale * 115 }
            StartPosition = "CenterScreen"
            Font = New-Object System.Drawing.Font('Courier New',$($FormScale * 11),0,0,0)
            Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
            Add_Closing = { $This.dispose() }
        }


        $AccountsListMassTagNewTagNameLabel = New-Object System.Windows.Forms.Label -Property @{
            Text     = "Tag Name:"
            Location = @{ X = $FormScale * 5
                          Y = $FormScale * 14 }
            Size     = @{ Width  = $FormScale * 100
                          Height = $FormScale * 25 }
        }


        $AccountsListMassTagNewTagNameComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
            Text     = ""
            Location = @{ X = $AccountsListMassTagNewTagNameLabel.Location.X + $AccountsListMassTagNewTagNameLabel.Size.Width + $($FormScale * 5)
                          Y = $FormScale * 10 }
            Size     = @{ Width  = $FormScale * 215
                          Height = $FormScale * 25 }
            AutoCompleteSource = "ListItems"
            AutoCompleteMode   = "SuggestAppend"
        }
        ForEach ($Tag in $TagListFileContents) { $AccountsListMassTagNewTagNameComboBox.Items.Add($Tag) }
        $AccountsListMassTagNewTagNameComboBox.Add_KeyDown({
            if ($_.KeyCode -eq "Enter" -and $AccountsListMassTagNewTagNameComboBox.text -ne '') {
                $script:AccountsListMassTagValue = $AccountsListMassTagNewTagNameComboBox.text
                $AccountsListMassTagForm.Close()
            }
        })


        $AccountsListMassTagNewTagNameButton = New-Object System.Windows.Forms.Button -Property @{
            Text     = "Apply Tag"
            Location = @{ X = $AccountsListMassTagNewTagNameLabel.Location.X + $($FormScale * 104)
                          Y = $AccountsListMassTagNewTagNameLabel.Location.Y + $AccountsListMassTagNewTagNameLabel.Size.Height + $($FormScale * 2) }
            Size     = @{ Width  = $FormScale * 100
                          Height = $FormScale * 25 }
            Add_Click = {
                if ($AccountsListMassTagNewTagNameComboBox.text -ne '') {
                    $script:AccountsListMassTagValue = $AccountsListMassTagNewTagNameComboBox.text
                    $AccountsListMassTagForm.Close()
                }
            }
        }
        Add-CommonButtonSettings -Button $AccountsListMassTagNewTagNameButton


        $AccountsListMassTagForm.Controls.AddRange(@($AccountsListMassTagNewTagNameLabel,$AccountsListMassTagNewTagNameComboBox,$AccountsListMassTagNewTagNameButton))
        $AccountsListMassTagForm.Add_Shown({$AccountsListMassTagForm.Activate()})
        $AccountsListMassTagForm.ShowDialog()
    }
}



Update-FormProgress "Move-TreeViewData"
function Move-TreeViewData {
    <#
        .Description
    #>
    param(
        [switch]$Accounts,
        [switch]$Endpoint,
        [switch]$SelectedAccounts,
        [switch]$SelectedEndpoint
    )
    if ($Accounts) {
        # Makes a copy of the checkboxed node name in the new Category
        $script:AccountsTreeNodeToMove = New-Object System.Collections.ArrayList

        if ($SelectedAccounts){
            # Adds (copies) the node to the new Category
            [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:AccountsTreeView.Nodes
            foreach ($root in $AllTreeViewNodes) {
                if ($root.Checked) { $root.Checked = $false }
                foreach ($Category in $root.Nodes) {
                    if ($Category.Checked) { $Category.Checked = $false }
                    foreach ($Entry in $Category.nodes) {
                        if ($Entry.text -eq $script:EntrySelected.text) {
                            Add-TreeViewData -Accounts -RootNode $script:TreeNodeAccountsList -Category $AccountsTreeNodePopupMoveComboBox.SelectedItem -Entry $Entry.text #-ToolTip "No Unique Data Available"
                            $script:AccountsTreeNodeToMove.Add($Entry.text)
                            break
                        }
                    }
                }
            }

            # Removes the original Account that was copied above
            foreach ($i in $script:AccountsTreeNodeToMove) {
                foreach ($root in $AllTreeViewNodes) {
                    foreach ($Category in $root.Nodes) {
                        foreach ($Entry in $Category.nodes) {
                            if (($i -contains $Entry.text) -and ($Entry.text -eq $script:EntrySelected.text)) {
                                $($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).CanonicalName = $AccountsTreeNodePopupMoveComboBox.SelectedItem
                                $ResultsListBox.Items.Add($Entry.text)
                                $Entry.remove()
                            }
                        }
                    }
                }
            }
        }
        else {
            # Adds (copies) the node to the new Category
            [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:AccountsTreeView.Nodes
            foreach ($root in $AllTreeViewNodes) {
                if ($root.Checked) { $root.Checked = $false }
                foreach ($Category in $root.Nodes) {
                    if ($Category.Checked) { $Category.Checked = $false }
                    foreach ($Entry in $Category.nodes) {
                        if ($Entry.Checked) {
                            Add-TreeViewData -Accounts -RootNode $script:TreeNodeAccountsList -Category $AccountsTreeNodePopupMoveComboBox.SelectedItem -Entry $Entry.text #-ToolTip "No Unique Data Available"
                            $script:AccountsTreeNodeToMove.Add($Entry.text)
                        }
                    }
                }
            }

            $AccountsAndAccountTreeViewTabControl.SelectedTab = $AccountsTreeviewTab
            $script:AccountsTreeNodeComboBox.SelectedItem = 'CanonicalName'

            # Removes the original Account that was copied above
            foreach ($i in $script:AccountsTreeNodeToMove) {
                foreach ($root in $AllTreeViewNodes) {
                    foreach ($Category in $root.Nodes) {
                        foreach ($Entry in $Category.nodes) {
                            if (($i -contains $Entry.text) -and ($Entry.Checked)) {
                                $($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).CanonicalName = $AccountsTreeNodePopupMoveComboBox.SelectedItem
                                $ResultsListBox.Items.Add($Entry.text)
                                $Entry.remove()
                            }
                        }
                    }
                }
            }
        }

        Remove-TreeViewEmptyCategory -Accounts
        Save-TreeViewData -Accounts
    }
    if ($Endopint) {
        # Makes a copy of the checkboxed node name in the new Category
        $script:ComputerTreeNodeToMove = New-Object System.Collections.ArrayList

        if ($SelectedEndpoint){
            # Adds (copies) the node to the new Category
            [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
            foreach ($root in $AllTreeViewNodes) {
                if ($root.Checked) { $root.Checked = $false }
                foreach ($Category in $root.Nodes) {
                    if ($Category.Checked) { $Category.Checked = $false }
                    foreach ($Entry in $Category.nodes) {
                        if ($Entry.text -eq $script:EntrySelected.text) {
                            Add-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category $ComputerTreeNodePopupMoveComboBox.SelectedItem -Entry $Entry.text #-ToolTip "No Unique Data Available"
                            $script:ComputerTreeNodeToMove.Add($Entry.text)
                            break
                        }
                    }
                }
            }

            # Removes the original hostname/IP that was copied above
            foreach ($i in $script:ComputerTreeNodeToMove) {
                foreach ($root in $AllTreeViewNodes) {
                    foreach ($Category in $root.Nodes) {
                        foreach ($Entry in $Category.nodes) {
                            if (($i -contains $Entry.text) -and ($Entry.text -eq $script:EntrySelected.text)) {
                                $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).CanonicalName = $ComputerTreeNodePopupMoveComboBox.SelectedItem
                                $ResultsListBox.Items.Add($Entry.text)
                                $Entry.remove()
                            }
                        }
                    }
                }
            }
        }
        else {
            # Adds (copies) the node to the new Category
            [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
            foreach ($root in $AllTreeViewNodes) {
                if ($root.Checked) { $root.Checked = $false }
                foreach ($Category in $root.Nodes) {
                    if ($Category.Checked) { $Category.Checked = $false }
                    foreach ($Entry in $Category.nodes) {
                        if ($Entry.Checked) {
                            Add-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category $ComputerTreeNodePopupMoveComboBox.SelectedItem -Entry $Entry.text #-ToolTip "No Unique Data Available"
                            $script:ComputerTreeNodeToMove.Add($Entry.text)
                        }
                    }
                }
            }

            $ComputerAndAccountTreeViewTabControl.SelectedTab = $ComputerTreeviewTab
            $script:ComputerTreeNodeComboBox.SelectedItem = 'CanonicalName'

            # Removes the original hostname/IP that was copied above
            foreach ($i in $script:ComputerTreeNodeToMove) {
                foreach ($root in $AllTreeViewNodes) {
                    foreach ($Category in $root.Nodes) {
                        foreach ($Entry in $Category.nodes) {
                            if (($i -contains $Entry.text) -and ($Entry.Checked)) {
                                $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).CanonicalName = $ComputerTreeNodePopupMoveComboBox.SelectedItem
                                $ResultsListBox.Items.Add($Entry.text)
                                $Entry.remove()
                            }
                        }
                    }
                }
            }
        }

        Remove-TreeViewEmptyCategory -Endpoint
        Save-TreeViewData -Endpoint
    }
}



Update-FormProgress "Create-TreeViewCheckBoxArray"
function Create-TreeViewCheckBoxArray {
    <#
        .Description
    #>
    param(
        [switch]$Accounts,
        [switch]$Endpoint
    )

    if ($Accounts) {
        # This array stores checkboxes that are check; a minimum of at least one checkbox will be needed later in the script
        $script:AccountsTreeViewSelected = @()
        [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:AccountsTreeView.Nodes
        foreach ($root in $AllTreeViewNodes) {
            if ($root.Checked) {
                foreach ($Category in $root.Nodes) {
                    foreach ($Entry in $Category.nodes) {
                        $script:AccountsTreeViewSelected += $Entry.Text
                    }
                }
            }
            else {
                foreach ($Category in $root.Nodes) {
                    if ($Category.Checked) {
                        foreach ($Entry in $Category.nodes) { $script:AccountsTreeViewSelected += $Entry.Text }
                    }
                    else {
                        foreach ($Entry in $Category.nodes) {
                            if ($Entry.Checked) {
                                $script:AccountsTreeViewSelected += $Entry.Text
                            }
                        }
                    }
                }
            }
        }
        $script:AccountsTreeViewSelected = $script:AccountsTreeViewSelected | Select-Object -Unique
    }
    if ($Endpoint) {
        # This array stores checkboxes that are check; a minimum of at least one checkbox will be needed later in the script
        $script:ComputerTreeViewSelected = @()
        [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
        foreach ($root in $AllTreeViewNodes) {
            if ($root.Checked) {
                foreach ($Category in $root.Nodes) {
                    foreach ($Entry in $Category.nodes) {
                        $script:ComputerTreeViewSelected += $Entry.Text
                    }
                }
            }
            else {
                foreach ($Category in $root.Nodes) {
                    if ($Category.Checked) {
                        foreach ($Entry in $Category.nodes) { $script:ComputerTreeViewSelected += $Entry.Text }
                    }
                    else {
                        foreach ($Entry in $Category.nodes) {
                            if ($Entry.Checked) {
                                $script:ComputerTreeViewSelected += $Entry.Text
                            }
                        }
                    }
                }
            }
        }
        $script:ComputerTreeViewSelected = $script:ComputerTreeViewSelected | Select-Object -Unique
    }
}



Update-FormProgress "Add-TreeViewAccount"
function Add-TreeViewAccount {
    if (($AccountsTreeNodePopupAddTextBox.Text -eq "Enter an Account") -or ($AccountsTreeNodePopupOUComboBox.Text -eq "Select an Organizational Unit / Canonical Name (or type a new one)")) {
        [system.media.systemsounds]::Exclamation.play()
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Add an Account:  Error")
        Show-MessageBox -Message 'Error: Enter a suitable name:
- Cannot be blank
- Cannot already exists
- Cannot be the default value' -Title "PoSh-EasyWin" -Options "Ok" -Type "Error" -Sound
    }
    elseif ($script:AccountsTreeViewData.Name -contains $AccountsTreeNodePopupAddTextBox.Text) {
        Message-TreeViewNodeAlreadyExists -Accounts -Message "Add an Account:  Error" -Account $AccountsTreeNodePopupAddTextBox.Text
    }
    else {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Added Selection:  $($AccountsTreeNodePopupAddTextBox.Text)")

        $AccountsAndAccountTreeViewTabControl.SelectedTab = $AccountsTreeviewTab
        $script:AccountsTreeNodeComboBox.SelectedItem = 'CanonicalName'

        Add-TreeViewData -Accounts -RootNode $script:TreeNodeAccountsList -Category $AccountsTreeNodePopupOUComboBox.SelectedItem -Entry $AccountsTreeNodePopupAddTextBox.Text #-ToolTip "No Unique Data Available"
        #Removed For Testing#
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("$($AccountsTreeNodePopupAddTextBox.Text) has been added to $($AccountsTreeNodePopupOUComboBox.Text)")

        $AccountsTreeNodeAddAccount = New-Object PSObject -Property @{
            Name            = $AccountsTreeNodePopupAddTextBox.Text
            CanonicalName   = $AccountsTreeNodePopupOUComboBox.Text
        }
        $script:AccountsTreeViewData += $AccountsTreeNodeAddAccount
        $script:AccountsTreeView.ExpandAll()
        $AccountsTreeNodePopup.close()
        Save-TreeViewData -Accounts
        Update-TreeViewState -Accounts -NoMessage
    }
}



Update-FormProgress "Compile-TreeViewCommand"
function Compile-TreeViewCommand {
    <#
        .Description
        Checks and compiles selected command treenode to be execute
        Those checked are either later executed individually or compiled
        This function compiles the selected treeview comamnds, placing the proper command
        type and protocol into a variable list to be executed.

        Related Functions:
            View-TreeViewCommandMethod
            View-TreeViewCommandQuery
            MonitorJobScriptBlock
    #>

    # Commands in the treenode that are selected
    $script:CommandsCheckedBoxesSelected = @()

    [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:CommandsTreeView.Nodes
    #Removed For Testing#$ResultsListBox.Items.Clear()

    # Compiles all the commands treenodes into one object
    $script:AllCommands  = $script:AllEndpointCommands
    $script:AllCommands += $script:AllActiveDirectoryCommands
    $script:AllCommands += $script:UserAddedCommands

    foreach ($root in $AllTreeViewNodes) {
        foreach ($Category in $root.Nodes) {
            if ($CommandsViewProtocolsUsedRadioButton.Checked) {
                foreach ($Entry in $Category.nodes) {
                    # Builds the query that is selected
                    if ($Entry.Checked -and $Entry -match '(WinRM)' -and $Entry -match 'Script') {
                        $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                        $script:CommandsCheckedBoxesSelected += New-Object psobject @{
                            Name           = $Entry.Text
                            Command        = $Command.Command_WinRM_Script
                            ExportFileName = $Command.ExportFileName
                            Type           = "(WinRM) Script"
                        }
                    }
                    elseif ($Entry.Checked -and $Entry -match '(WinRM)' -and $Entry -match 'PoSh') {
                        $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                        $script:CommandsCheckedBoxesSelected += New-Object psobject @{
                            Name           = $Entry.Text
                            Command        = $Command.Command_WinRM_PoSh
                            Properties     = $Command.Properties_PoSh
                            ExportFileName = $Command.ExportFileName
                            Type           = '(WinRM) PoSh'
                        }
                    }
                    elseif ($Entry.Checked -and $Entry -match '(WinRM)' -and $Entry -match 'WMI') {
                        $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                        $script:CommandsCheckedBoxesSelected += New-Object psobject @{
                            Name           = $Entry.Text
                            Command        = $Command.Command_WinRM_WMI
                            Properties     = $Command.Properties_WMI
                            ExportFileName = $Command.ExportFileName
                            Type           = "(WinRM) WMI"
                        }
                    }
                    #elseif ($Entry.Checked -and $Entry -match '(WinRM)' -and $Entry -match 'CMD') {
                    #    $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                    #    $script:CommandsCheckedBoxesSelected += New-Object psobject @{
                    #        Name           = $Entry.Text
                    #        Command        = $Command.Command_WinRM_CMD
                    #        ExportFileName = $Command.ExportFileName
                    #        Type           = "(WinRM) CMD"
                    #    }
                    #}
                    #elseif ($Entry.Checked -and $Entry -match '(RPC)' -and $Entry -match 'PoSh') {
                    #    $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                    #    $script:CommandsCheckedBoxesSelected += New-Object psobject @{
                    #        Name           = $Entry.Text
                    #        Command        = $Command.Command_RPC_PoSh
                    #        Properties     = $Command.Properties_PoSh
                    #        ExportFileName = $Command.ExportFileName
                    #        Type           = "(RPC) PoSh"
                    #    }
                    #}
                    elseif ($Entry.Checked -and $Entry -match '(RPC)' -and  $Entry -match 'WMI' -and $Entry -notmatch '(WinRM)') {
                        $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                        $script:CommandsCheckedBoxesSelected += New-Object psobject @{
                            Name           = $Entry.Text
                            Command        = $Command.Command_RPC_WMI
                            Properties     = $Command.Properties_WMI
                            ExportFileName = $Command.ExportFileName
                            Type           = "(RPC) WMI"
                        }
                    }
                    #elseif ($Entry.Checked -and $Entry -match '(RPC)' -and  $Entry -match 'CMD' -and $Entry -notmatch '(WinRM)') {
                    #    $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                    #    $script:CommandsCheckedBoxesSelected += New-Object psobject @{
                    #        Name           = $Entry.Text
                    #        Command        = $Command.Command_RPC_CMD
                    #        ExportFileName = $Command.ExportFileName
                    #        Type           = "(RPC) CMD"
                    #    }
                    #}
                    elseif ($Entry.Checked -and $Entry -match '(SMB)' -and $Entry -match 'PoSh') {
                        $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                        $script:CommandsCheckedBoxesSelected += New-Object psobject @{
                            Name           = $Entry.Text
                            Command        = $Command.Command_SMB_PoSh
                            ExportFileName = $Command.ExportFileName
                            Type           = "(SMB) PoSh"
                        }
                    }
                    elseif ($Entry.Checked -and $Entry -match '(SMB)' -and $Entry -match 'WMI') {
                        $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                        $script:CommandsCheckedBoxesSelected += New-Object psobject @{
                            Name           = $Entry.Text
                            Command        = $Command.Command_SMB_WMI
                            ExportFileName = $Command.ExportFileName
                            Type           = "(SMB) WMI"
                        }
                    }
                    elseif ($Entry.Checked -and $Entry -match '(SMB)' -and $Entry -match 'CMD') {
                        $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                        $script:CommandsCheckedBoxesSelected += New-Object psobject @{
                            Name           = $Entry.Text
                            Command        = $Command.Command_SMB_CMD
                            ExportFileName = $Command.ExportFileName
                            Type           = "(SMB) CMD"
                        }
                    }
                    elseif ($Entry.Checked -and $Entry -match '(SSH)' -and $Entry -match 'Linux') {
                        $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                        $script:CommandsCheckedBoxesSelected += New-Object psobject @{
                            Name           = $Entry.Text
                            Command        = $Command.Command_Linux
                            ExportFileName = $Command.ExportFileName
                            Type           = "(SSH) Linux"
                        }
                    }
                }
            }
            if ($CommandsViewCommandNamesRadioButton.Checked) {
                foreach ($Entry in $Category.nodes) {
                    # Builds the query that is selected
                    if ($Entry -match '(WinRM)' -and $Entry -match 'Script' -and $Entry.Checked) {
                        $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                        $script:CommandsCheckedBoxesSelected += New-Object psobject @{
                            Name           = $Entry.Text
                            Command        = $Command.Command_WinRM_Script
                            ExportFileName = $Command.ExportFileName
                            Type           = "(WinRM) Script"
                        }
                    }
                    elseif ($Entry -match '(WinRM)' -and $Entry -match 'PoSh' -and $Entry.Checked) {
                        $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                        $script:CommandsCheckedBoxesSelected += New-Object psobject @{
                            Name           = $Entry.Text
                            Command        = $Command.Command_WinRM_PoSh
                            Properties     = $Command.Properties_PoSh
                            ExportFileName = $Command.ExportFileName
                            Type           = '(WinRM) PoSh'
                        }
                    }
                    elseif ($Entry -match '(WinRM)' -and $Entry -match 'WMI' -and $Entry.Checked) {
                        $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                        $script:CommandsCheckedBoxesSelected += New-Object psobject @{
                            Name           = $Entry.Text
                            Command        = $Command.Command_WinRM_WMI
                            Properties     = $Command.Properties_WMI
                            ExportFileName = $Command.ExportFileName
                            Type           = "(WinRM) WMI"
                        }
                    }
                    #elseif ($Entry -match '(WinRM)' -and $Entry -match 'CMD' -and $Entry.Checked) {
                    #    $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                    #    $script:CommandsCheckedBoxesSelected += New-Object psobject @{
                    #        Name           = $Entry.Text
                    #        Command        = $Command.Command_WinRM_CMD
                    #        ExportFileName = $Command.ExportFileName
                    #        Type           = "(WinRM) CMD"
                    #    }
                    #}
                    #if ($Entry -match '(RPC)' -and $Entry -match 'PoSh' -and $Entry.Checked) {
                    #    $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                    #    $script:CommandsCheckedBoxesSelected += New-Object psobject @{
                    #        Name           = $Entry.Text
                    #        Command        = $Command.Command_RPC_PoSh
                    #        Properties     = $Command.Properties_PoSh
                    #        ExportFileName = $Command.ExportFileName
                    #        Type           = '(RPC) PoSh'
                    #    }
                    #}
                    elseif (($Entry -match '(RPC)') -and  $Entry -match 'WMI' -and ($Entry -notmatch '(WinRM)') -and $Entry.Checked) {
                        $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                        $script:CommandsCheckedBoxesSelected += New-Object psobject @{
                            Name           = $Entry.Text
                            Command        = $Command.Command_RPC_WMI
                            Properties     = $Command.Properties_WMI
                            ExportFileName = $Command.ExportFileName
                            Type           = "(RPC) WMI"
                        }
                    }
                    #elseif (($Entry -match '(RPC)') -and  $Entry -match 'CMD' -and ($Entry -notmatch '(WinRM)') -and $Entry.Checked) {
                    #    $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                    #    $script:CommandsCheckedBoxesSelected += New-Object psobject @{
                    #        Name           = $Entry.Text
                    #        Command        = $Command.Command_RPC_CMD
                    #        ExportFileName = $Command.ExportFileName
                    #        Type           = "(RPC) CMD"
                    #    }
                    #}
                    elseif ($Entry -match '(SMB)' -and $Entry -match 'PoSh' -and $Entry.Checked) {
                        $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                        $script:CommandsCheckedBoxesSelected += New-Object psobject @{
                            Name           = $Entry.Text
                            Command        = $Command.Command_SMB_PoSh
                            ExportFileName = $Command.ExportFileName
                            Type           = "(SMB) PoSh"
                        }
                    }
                    elseif ($Entry -match '(SMB)' -and $Entry -match 'WMI' -and $Entry.Checked) {
                        $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                        $script:CommandsCheckedBoxesSelected += New-Object psobject @{
                            Name           = $Entry.Text
                            Command        = $Command.Command_SMB_WMI
                            ExportFileName = $Command.ExportFileName
                            Type           = "(SMB) WMI"
                        }
                    }
                    elseif ($Entry -match '(SMB)' -and $Entry -match 'CMD' -and $Entry.Checked) {
                        $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                        $script:CommandsCheckedBoxesSelected += New-Object psobject @{
                            Name           = $Entry.Text
                            Command        = $Command.Command_SMB_CMD
                            ExportFileName = $Command.ExportFileName
                            Type           = "(SMB) CMD"
                        }
                    }
                    elseif ($Entry -match '(SSH)' -and $Entry -match 'Linux' -and $Entry.Checked) {
                        $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                        $script:CommandsCheckedBoxesSelected += New-Object psobject @{
                            Name           = $Entry.Text
                            Command        = $Command.Command_Linux
                            ExportFileName = $Command.ExportFileName
                            Type           = "(SSH) Linux"
                        }
                    }
                }
            }
        }
    }
}











# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUva8iYJpx7wVjkjjJL884rwnM
# gjagggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
# AQUFADAzMTEwLwYDVQQDDChQb1NoLUVhc3lXaW4gQnkgRGFuIEtvbW5pY2sgKGhp
# Z2gxMDFicm8pMB4XDTIxMTIxNDA1MDIwMFoXDTMxMTIxNDA1MTIwMFowMzExMC8G
# A1UEAwwoUG9TaC1FYXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALvIxUDFEVGB/G0FXPryoNlF
# dA65j5jPEFM2R4468rjlTVsNYUOR+XvhjmhpggSQa6SzvXtklUJIJ6LgVUpt/0C1
# zlr1pRwTvsd3svI7FHTbJahijICjCv8u+bFcAR2hH3oHFZTqvzWD1yG9FGCw2pq3
# h4ahxtYBd1+/n+jOtPUoMzcKIOXCUe4Cay+xP8k0/OLIVvKYRlMY4B9hvTW2CK7N
# fPnvFpNFeGgZKPRLESlaWncbtEBkexmnWuferJsRtjqC75uNYuTimLDSXvNps3dJ
# wkIvKS1NcxfTqQArX3Sg5qKX+ZR21uugKXLUyMqXmVo2VEyYJLAAAITEBDM8ngUC
# AwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0G
# A1UdDgQWBBSDJIlo6BcZ7KJAW5hoB/aaTLxFzTANBgkqhkiG9w0BAQUFAAOCAQEA
# ouCzal7zPn9vc/C9uq7IDNb1oNbWbVlGJELLQQYdfBE9NWmXi7RfYNd8mdCLt9kF
# CBP/ZjHKianHeZiYay1Tj+4H541iUN9bPZ/EaEIup8nTzPbJcmDbaAGaFt2PFG4U
# 3YwiiFgxFlyGzrp//sVnOdtEtiOsS7uK9NexZ3eEQfb/Cd9HRikeUG8ZR5VoQ/kH
# 2t2+tYoCP4HsyOkEeSQbnxlO9s1jlSNvqv4aygv0L6l7zufiKcuG7q4xv/5OvZ+d
# TcY0W3MVlrrNp1T2wxzl3Q6DgI+zuaaA1w4ZGHyxP8PLr6lMi6hIugI1BSYVfk8h
# 7KAaul5m+zUTDBUyNd91ojGCAegwggHkAgEBMEcwMzExMC8GA1UEAwwoUG9TaC1F
# YXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKQIQeugH5LewQKBKT6dP
# XhQ7sDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkq
# hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGC
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUelj0A/JUtu6cQHxgDHofOOtI7gcwDQYJKoZI
# hvcNAQEBBQAEggEAQAdo4qO7oh/b2Bq0NMlxpV+BtAPnb+TKmw/YUzYE7ElES1cu
# Z1+KIXSSaR5b05382K424UaaBCQF4rpp0XkxBnOI2EKGu7CTq1FM2/dZGmqSkeca
# knofQV2puwPM4pYuQQVKl5mxi32dp3ARLkEE7lNv50tCmFj4t7ggomKVEsQC3SCR
# gcA2r5b23YHKE0/pFTlEcsRV1b629s/mR4BY87gffHmQ1TJtTe/FeXhhzh/kNHgp
# LtIHnB+M6cpHMabhPmudstWGBriRsUZCVH5ZfTT5oskDDIk35ifnd9pTQ+H1TnVa
# fU64UHL7Bw9a8NDMbhjPZ/RganW+n8n1bDWxFQ==
# SIG # End signature block
