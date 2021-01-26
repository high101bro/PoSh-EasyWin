Function Conduct-PingSweep {
    Function Create-PingList {
        param($IPAddress)
        $Comp = $IPAddress
        if ($Comp -eq $Null) { . Create-PingList }
        elseif ($Comp -match "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/\d{1,2}") {
            $Temp = $Comp.Split("/")
            $IP = $Temp[0]
            $Mask = $Temp[1]
            . Get-SubnetRange $IP $Mask
            $global:PingList = $Script:IPList
        }
        Else { $global:PingList = $Comp }
    }
    . Create-PingList $EnumerationPingSweepIPNetworkCIDRTextbox.Text
    $EnumerationComputerListBox.Items.Clear()

    # Sets initial values for the progress bars
    $script:ProgressBarEndpointsProgressBar.Maximum = $PingList.count
    $script:ProgressBarEndpointsProgressBar.Value   = 0
#    $script:ProgressBarQueriesProgressBar.Maximum = $PingList.count
#    $script:ProgressBarQueriesProgressBar.Value   = 0

    foreach ($Computer in $PingList) {
        $ping = Test-Connection $Computer -Count 1
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Pinging: $Computer")
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message " - $ping"
        if($ping){$EnumerationComputerListBox.Items.Insert(0,"$Computer")}
        $script:ProgressBarEndpointsProgressBar.Value += 1
        $PoShEasyWin.Refresh()
    }
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Finished with Ping Sweep!")
}

