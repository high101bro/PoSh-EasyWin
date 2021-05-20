function Normalize-TreeViewData {
    param(
        [switch]$Accounts,
        [switch]$Endpoint
    )
    if ($Accounts) {
        # This section populates the data with default data if it doesn't have any
        $script:AccountsTreeViewDataTemp = @()
        
        Foreach($AccountsData in $script:AccountsTreeViewData) {
            # Trims out the domain name from the the CanonicalName
            $CanonicalName = $($($AccountsData.CanonicalName) -replace $AccountsData.Name,"" -replace $AccountsData.CanonicalName.split('/')[0],"").TrimEnd("/")

            $AccountsTreeNodeInsertDefaultData = New-Object PSObject -Property @{ Name = $AccountsData.Name}


            if ($AccountsData.Enabled) {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name Enabled -Value $AccountsData.Enabled -Force }
            elseif ($AccountsData.Enabled -eq $false) {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name Enabled -Value $AccountsData.Enabled -Force }
            else {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name Enabled -Value "Unknown Status" -Force }

            if ($AccountsData.CanonicalName) {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name CanonicalName -Value $CanonicalName -Force }
            else {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name CanonicalName -Value "/Unknown OU" -Force }

            if ($AccountsData.LockedOut) {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name LockedOut -Value $AccountsData.LockedOut -Force }
            elseif ($AccountsData.LockedOut -eq $false) {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name LockedOut -Value $AccountsData.LockedOut -Force }
            else {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name LockedOut -Value "Unknown Status" -Force }

            if ($AccountsData.SmartCardLogonRequired) {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name SmartCardLogonRequired -Value $AccountsData.SmartCardLogonRequired -Force }
            elseif ($AccountsData.SmartCardLogonRequired -eq $false) {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name SmartCardLogonRequired -Value $AccountsData.SmartCardLogonRequired -Force }
            else {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name SmartCardLogonRequired -Value "Unknown Status" -Force }

            if ($AccountsData.Created) {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name Created -Value $AccountsData.Created -Force }
            else {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name Created -Value "No TimeStamp" -Force }

            if ($AccountsData.Modified) {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name Modified -Value $AccountsData.Modified -Force }
            else {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name Modified -Value "No TimeStamp" -Force }

            if ($AccountsData.LastLogonDate) {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name LastLogonDate -Value $AccountsData.LastLogonDate -Force }
            else {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name LastLogonDate -Value "No TimeStamp" -Force }

            if ($AccountsData.LastBadPasswordAttempt) {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name LastBadPasswordAttempt -Value $AccountsData.LastBadPasswordAttempt -Force }
            else {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name LastBadPasswordAttempt -Value "No TimeStamp" -Force }

            if ($AccountsData.BadLogonCount) {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name BadLogonCount -Value $AccountsData.BadLogonCount -Force }
            else {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name BadLogonCount -Value "0" -Force }

            if ($AccountsData.PasswordExpired) {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name PasswordExpired -Value $AccountsData.PasswordExpired -Force }
            elseif ($AccountsData.PasswordExpired -eq $false) {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name PasswordExpired -Value $AccountsData.PasswordExpired -Force }
            else {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name PasswordExpired -Value "Unknown Status" -Force }

            if ($AccountsData.PasswordNeverExpires) {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name PasswordNeverExpires -Value $AccountsData.PasswordNeverExpires -Force }
            elseif ($AccountsData.PasswordNeverExpires -eq $false) {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name PasswordNeverExpires -Value $AccountsData.PasswordNeverExpires -Force }
            else {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name PasswordNeverExpires -Value "Unknown Status" -Force }

            if ($AccountsData.PasswordNotRequired) {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name PasswordNotRequired -Value $AccountsData.PasswordNotRequired -Force }
            elseif ($AccountsData.PasswordNotRequired -eq $false) {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name PasswordNotRequired -Value $AccountsData.PasswordNotRequired -Force }
            else {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name PasswordNotRequired -Value "Unknown Status" -Force }

            if ($AccountsData.MemberOf) {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name MemberOf -Value $AccountsData.MemberOf -Force }
            else {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name MemberOf -Value "No Group" -Force }

            if ($AccountsData.SID) {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name SID -Value $AccountsData.SID -Force }
            else {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name SID -Value "Unknown SID" -Force }

            if ($AccountsData.ScriptPath) {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name ScriptPath -Value $AccountsData.ScriptPath -Force }
            else {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name ScriptPath -Value "No ScriptPath" -Force }

            if ($AccountsData.HomeDrive) {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name HomeDrive -Value $AccountsData.HomeDrive -Force }
            else {
                $AccountsTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name HomeDrive -Value "No HomeDrive" -Force }


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
    #        else {
    #            $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name PortScan -Value "No Ports Available" -Force }

            if ($Computer.Notes) {
                $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name Notes -Value $Computer.Notes -Force }
            else {
                $ComputerTreeNodeInsertDefaultData | Add-Member -MemberType NoteProperty -Name Notes -Value "No Notes Available" -Force }

            $script:ComputerTreeViewDataTemp += $ComputerTreeNodeInsertDefaultData
            ###write-host $($ComputerTreeNodeInsertDefaultData | Select Name, OperatingSystem, CanonicalName, IPv4Address, Notes)
        }
        $script:ComputerTreeViewData       = $script:ComputerTreeViewDataTemp
        $script:ComputerTreeViewDataTemp   = $null
        $ComputerTreeNodeInsertDefaultData = $null
    }
}

