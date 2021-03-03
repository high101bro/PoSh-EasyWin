function Query-NetworkConnection {
    param(
        $IP             = $null,
        $RemotePort     = $null,
        $LocalPort      = $null,
        $ProcessName    = $null,
        $CommandLine    = $null,
        $ExecutablePath = $null,
        $regex          = $false
    )

    if ([bool]((Get-Command Get-NetTCPConnection).ParameterSets | Select-Object -ExpandProperty Parameters | Where-Object Name -match OwningProcess)) {
        $Processes           = Get-WmiObject -Class Win32_Process
        $Connections         = Get-NetTCPConnection
        $GetNetTCPConnection = $True
        foreach ($Conn in $Connections) {
            foreach ($Proc in $Processes) {
                if ($Conn.OwningProcess -eq $Proc.ProcessId) {
                    $Conn | Add-Member -MemberType NoteProperty -Name 'Duration'        -Value $((New-TimeSpan -Start ($Conn.CreationTime)).ToString())
                    $Conn | Add-Member -MemberType NoteProperty -Name 'ParentProcessId' -Value $Proc.ParentProcessId
                    $Conn | Add-Member -MemberType NoteProperty -Name 'ProcessName'     -Value $Proc.Name
                    $Conn | Add-Member -MemberType NoteProperty -Name 'ExecutablePath'  -Value $Proc.Path
                    $Conn | Add-Member -MemberType NoteProperty -Name 'CommandLine'     -Value $Proc.CommandLine
                }
            }
        }
    }
    else {
        function Get-Netstat {
            $NetworkConnections = netstat -nao -p TCP
            $NetStat = Foreach ($line in $NetworkConnections[4..$NetworkConnections.count]) {
                $line = $line -replace '^\s+',''
                $line = $line -split '\s+'
                $Properties = @{
                    Protocol      =  $line[0]
                    LocalAddress  = ($line[1] -split ":")[0]
                    LocalPort     = ($line[1] -split ":")[1]
                    RemoteAddress = ($line[2] -split ":")[0]
                    RemotePort    = ($line[2] -split ":")[1]
                    State         =  $line[3]
                    ProcessId     =  $line[4]
                }
                $Connection = New-Object -TypeName PSObject -Property $Properties
                $Processes  = Get-WmiObject -query ('select * from win32_process where ProcessId="{0}"' -f $line[4])
                $Connection | Add-Member -MemberType NoteProperty PSComputerName  $env:COMPUTERNAME
                $Connection | Add-Member -MemberType NoteProperty ParentProcessId $Processes.ParentProcessId
                $Connection | Add-Member -MemberType NoteProperty ProcessName     $Processes.Caption
                $Connection | Add-Member -MemberType NoteProperty ExecutablePath  $Processes.ExecutablePath
                $Connection | Add-Member -MemberType NoteProperty CommandLine     $Processes.CommandLine
                $Connection | Add-Member -MemberType NoteProperty CreationTime    ([WMI] '').ConvertToDateTime($Processes.CreationDate)
                #implemented lower #$Connection | Add-Member -MemberType NoteProperty Duration        $((New-TimeSpan -Start $($this.CreationTime).ToString()))
                if ($Connection.ExecutablePath -ne $null -AND -NOT $NoHash) {
                    $MD5Hash = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
                    $Hash    = [System.BitConverter]::ToString($MD5Hash.ComputeHash([System.IO.File]::ReadAllBytes($Processes.ExecutablePath)))
                    $Connection | Add-Member -MemberType NoteProperty MD5Hash $($Hash -replace "-","")
                }
                else {
                    $Connection | Add-Member -MemberType NoteProperty MD5Hash $null
                }
                $Connection
            }
            $NetStat | Select-Object -Property PSComputerName,Protocol,LocalAddress,LocalPort,RemoteAddress,RemotePort,State,ProcessName,ProcessId,ParentProcessId,MD5Hash,ExecutablePath,CommandLine,CreationTime,Duration
        }
        $Connections = Get-Netstat
    }

    function CollectionNetworkData {
        $MD5Hash = $Hash = $null
        if ($GetNetTCPConnection) {
            $Processes      = Get-Process -Pid $conn.OwningProcess
        }
        $ConnectionsFound  += [PSCustomObject]@{
            LocalAddress    = $conn.LocalAddress
            LocalPort       = $conn.LocalPort
            RemoteAddress   = $conn.RemoteAddress
            RemotePort      = $conn.RemotePort
            State           = $conn.State
            CreationTime    = $conn.CreationTime
            Duration        = $((New-TimeSpan -Start ($Conn.CreationTime)).ToString())
            ParentProcessId = $conn.ParentProcessId
            ProcessID       = $(if($GetNetTCPConnection) {$conn.OwningProcess} else {$conn.ProcessID})
            ProcessName     = $conn.ProcessName
            CommandLine     = $conn.CommandLine
            MD5Hash         = $(if($GetNetTCPConnection) {
                $MD5Hash = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
                $Hash    = [System.BitConverter]::ToString($MD5Hash.ComputeHash([System.IO.File]::ReadAllBytes($Processes.path)))
                $($Hash -replace "-","")
            } else {$conn.MD5Hash} )
            ExecutablePath  = $(if($GetNetTCPConnection) { $Processes.Path } else {$conn.ExecutablePath} )
            Protocol        = $(if($GetNetTCPConnection) {'TCP'} else {$conn.Protocol} )
        }
        return $ConnectionsFound
    }

    $ConnectionsFound = @()

    foreach ($Conn in $Connections) {
        if ($regex -eq $true) {
            if     ($IP)             { foreach ($DestIP   in $IP)             { if (($Conn.RemoteAddress  -match $DestIP)   -and ($DestIP   -ne '')) { CollectionNetworkData } } }
            elseif ($RemotePort)     { foreach ($DestPort in $RemotePort)     { if (($Conn.RemotePort     -match $DestPort) -and ($DestPort -ne '')) { CollectionNetworkData } } }
            elseif ($LocalPort)      { foreach ($SrcPort  in $LocalPort)      { if (($Conn.LocalPort      -match $SrcPort)  -and ($SrcPort  -ne '')) { CollectionNetworkData } } }
            elseif ($ProcessName)    { foreach ($ProcName in $ProcessName)    { if (($conn.ProcessName    -match $ProcName) -and ($ProcName -ne '')) { CollectionNetworkData } } }
            elseif ($CommandLine)    { foreach ($Command  in $CommandLine)    { if (($conn.CommandLine    -match $Command)  -and ($Command  -ne '')) { CollectionNetworkData } } }
            elseif ($ExecutablePath) { foreach ($Path     in $ExecutablePath) { if (($conn.ExecutablePath -match $Path)     -and ($Path     -ne '')) { CollectionNetworkData } } }
        }
        elseif ($regex -eq $false) {
            if     ($IP)             { foreach ($DestIP   in $IP)             { if (($Conn.RemoteAddress  -eq $DestIP)   -and ($DestIP   -ne '')) { CollectionNetworkData } } }
            elseif ($RemotePort)     { foreach ($DestPort in $RemotePort)     { if (($Conn.RemotePort     -eq $DestPort) -and ($DestPort -ne '')) { CollectionNetworkData } } }
            elseif ($LocalPort)      { foreach ($SrcPort  in $LocalPort)      { if (($Conn.LocalPort      -eq $SrcPort)  -and ($SrcPort  -ne '')) { CollectionNetworkData } } }
            elseif ($ProcessName)    { foreach ($ProcName in $ProcessName)    { if (($conn.ProcessName    -eq $ProcName) -and ($ProcName -ne '')) { CollectionNetworkData } } }
            elseif ($CommandLine)    { foreach ($Command  in $CommandLine)    { if (($conn.CommandLine    -eq $Command)  -and ($Command  -ne '')) { CollectionNetworkData } } }
            elseif ($ExecutablePath) { foreach ($Path     in $ExecutablePath) { if (($conn.ExecutablePath -eq $Path)     -and ($Path     -ne '')) { CollectionNetworkData } } }
        }
    }
    return $ConnectionsFound
}
