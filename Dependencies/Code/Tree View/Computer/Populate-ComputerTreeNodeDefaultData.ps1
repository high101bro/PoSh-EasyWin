function Populate-ComputerTreeNodeDefaultData {
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

