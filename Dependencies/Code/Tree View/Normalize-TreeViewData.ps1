function Normalize-TreeViewData {
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

