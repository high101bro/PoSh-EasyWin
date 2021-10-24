function Query-NetworkConnectionWithinSysmon {
    param(
        $DestinationIP   = $null,
        $DestinationPort = $null,
        $SourceIP        = $null,
        $SourcePort      = $null,
        $Account         = $null,
        $ExecutablePath  = $null,
        $regex           = $false
    )

    $SysmonNetworkEventLogs = Get-WinEvent -FilterHashtable @{
        LogName = 'Microsoft-Windows-Sysmon/Operational'
        Id      = 3
    }

    $SysmonNetworkEventLogsFormatted = @()
    Foreach ($event in ($SysmonNetworkEventLogs | Select-Object -Expand Message)) {
        $SysmonNetworkEventLogsFormatted += [PSCustomObject]@{
            'Event'               = ($event -split "`r`n")[0].TrimEnd(':')
            'RuleName'            = (($event -split "`r`n")[1] -split ": ")[1]
            'UtcTime'             = [datetime](($event -split "`r`n")[2] -split ": ")[1]
            'ProcessGuid'         = (($event -split "`r`n")[3] -split ": ")[1].Replace('{','').Replace('}','')
            'ProcessId'           = (($event -split "`r`n")[4] -split ": ")[1]
            'Image'               = (($event -split "`r`n")[5] -split ": ")[1]
            'User'                = (($event -split "`r`n")[6] -split ": ")[1]
            'Protocol'            = (($event -split "`r`n")[7] -split ": ")[1]
            'Initiated'           = (($event -split "`r`n")[8] -split ": ")[1]
            'SourceIsIpv6'        = (($event -split "`r`n")[9] -split ": ")[1]
            'SourceIp'            = (($event -split "`r`n")[10] -split ": ")[1]
            'SourceHostname'      = (($event -split "`r`n")[11] -split ": ")[1]
            'SourcePort'          = (($event -split "`r`n")[12] -split ": ")[1]
            'SourcePortName'      = (($event -split "`r`n")[13] -split ": ")[1]
            'DestinationIsIpv6'   = (($event -split "`r`n")[14] -split ": ")[1]
            'DestinationIp'       = (($event -split "`r`n")[15] -split ": ")[1]
            'DestinationHostname' = (($event -split "`r`n")[16] -split ": ")[1]
            'DestinationPort'     = (($event -split "`r`n")[17] -split ": ")[1]
            'DestinationPortName' = (($event -split "`r`n")[18] -split ": ")[1]
        }
    }

    $SysmonNetworkConnectionEventFound = @()

    foreach ($SysmonNetEvent in $SysmonNetworkEventLogsFormatted) {
        if ($regex -eq $true) {
            if     ($DestinationIP)   { foreach ($DestIP   in $DestinationIP)   { if (($SysmonNetEvent.DestinationIp       -match $DestIP    -or
                                                                                       $SysmonNetEvent.DestinationHostname -match $DestIP)   -and ($DestIP   -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
            elseif ($DestinationPort) { foreach ($DestPort in $DestinationPort) { if (($SysmonNetEvent.DestinationPort     -match $DestPort  -or
                                                                                       $SysmonNetEvent.DestinationPortName -match $DestPort) -and ($DestPort -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
            elseif ($SourceIP)        { foreach ($SrcPort  in $SourceIP)        { if (($SysmonNetEvent.SourceIP            -match $SrcPort   -or
                                                                                       $SysmonNetEvent.SourceHostName      -match $SrcPort)  -and ($SrcPort  -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
            elseif ($SourcePort)      { foreach ($SrcPort  in $SourcePort)      { if (($SysmonNetEvent.SourcePort          -match $SrcPort   -or
                                                                                       $SysmonNetEvent.SourcePortName      -match $SrcPort)  -and ($SrcPort  -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
            elseif ($Account)         { foreach ($Command  in $Account)         { if (($SysmonNetEvent.User                -match $Command)  -and ($Command  -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
            elseif ($ExecutablePath)  { foreach ($Path     in $ExecutablePath)  { if (($SysmonNetEvent.Image               -match $Path)     -and ($Path     -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
        }
        elseif ($regex -eq $false) {
            if     ($DestinationIP)   { foreach ($DestIP   in $DestinationIP)   { if (($SysmonNetEvent.DestinationIp       -eq $DestIP    -or
                                                                                       $SysmonNetEvent.DestinationHostname -eq $DestIP)   -and ($DestIP   -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
            elseif ($DestinationPort) { foreach ($DestPort in $DestinationPort) { if (($SysmonNetEvent.DestinationPort     -eq $DestPort  -or
                                                                                       $SysmonNetEvent.DestinationPortName -eq $DestPort) -and ($DestPort -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
            elseif ($SourceIP)        { foreach ($SrcPort  in $SourceIP)        { if (($SysmonNetEvent.SourceIP            -eq $SrcPort   -or
                                                                                       $SysmonNetEvent.SourceHostName      -eq $SrcPort)  -and ($SrcPort  -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
            elseif ($SourcePort)      { foreach ($SrcPort  in $SourcePort)      { if (($SysmonNetEvent.SourcePort          -eq $SrcPort   -or
                                                                                       $SysmonNetEvent.SourcePortName      -eq $SrcPort)  -and ($SrcPort  -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
            elseif ($Account)         { foreach ($Command  in $Account)         { if (($SysmonNetEvent.User                -eq $Command)  -and ($Command  -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
            elseif ($ExecutablePath)  { foreach ($Path     in $ExecutablePath)  { if (($SysmonNetEvent.Image               -eq $Path)     -and ($Path     -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
        }
    }
    return $SysmonNetworkConnectionEventFound | Select-Object -Property ComputerName, UtcTime, Protocol, SourceHostName, SourceIP, SourcePort, SourcePortName, DestinationHostName, DestinationIP, DestinationPort, DestinationPortName, User, ProcessId, Image, RuleName, Event, Initiated, SourceIsIPv6, DestinationIsIPv6, PSComputerName | Sort-Object -Property UtcTime
}
