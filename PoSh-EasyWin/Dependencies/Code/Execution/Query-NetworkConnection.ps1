<#
This function is created within a string variable as it is used with an an agrument for Start-Job
It is initialized below with an Invoke-Expression
20200413: Re-wrote script for backwards compatability with older OS that don't support the Get-NetTCPConnection paramter of owningprocess and creation time
#>
$QueryNetworkConnection = @'
function Query-NetworkConnection {
    param(
        [string[]]$IP          = $null,
        [string[]]$RemotePort  = $null,
        [string[]]$LocalPort   = $null,
        [string[]]$ProcessName = $null
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
                    Protocol      = $line[0]
                    LocalAddress  = ($line[1] -split ":")[0]
                    LocalPort     = ($line[1] -split ":")[1]
                    RemoteAddress = ($line[2] -split ":")[0]
                    RemotePort    = ($line[2] -split ":")[1]
                    State         = $line[3]
                    ProcessId     = $line[4]
                }
                $Connection = New-Object -TypeName PSObject -Property $Properties
                $proc       = Get-WmiObject -query ('select * from win32_process where ProcessId="{0}"' -f $line[4])
                $Connection | Add-Member -MemberType NoteProperty PSComputerName  $env:COMPUTERNAME
                $Connection | Add-Member -MemberType NoteProperty ParentProcessId $proc.ParentProcessId
                $Connection | Add-Member -MemberType NoteProperty ProcessName     $proc.Caption
                $Connection | Add-Member -MemberType NoteProperty ExecutablePath  $proc.ExecutablePath
                $Connection | Add-Member -MemberType NoteProperty CommandLine     $proc.CommandLine
                $Connection | Add-Member -MemberType NoteProperty CreationTime    ([WMI] '').ConvertToDateTime($proc.CreationDate) 
                #implemented lower #$Connection | Add-Member -MemberType NoteProperty Duration        $((New-TimeSpan -Start $($this.CreationTime).ToString()))
                if ($Connection.ExecutablePath -ne $null -AND -NOT $NoHash) {
                    $MD5Hash = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
                    $Hash    = [System.BitConverter]::ToString($MD5Hash.ComputeHash([System.IO.File]::ReadAllBytes($proc.ExecutablePath)))
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
            $proc           = Get-Process -Pid $conn.OwningProcess 
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
                $Hash    = [System.BitConverter]::ToString($MD5Hash.ComputeHash([System.IO.File]::ReadAllBytes($proc.path)))
                $($Hash -replace "-","")                
            } else {$conn.MD5Hash} )
            ExecutablePath  = $(if($GetNetTCPConnection) { $proc.Path } else {$conn.ExecutablePath} )
            Protocol        = $(if($GetNetTCPConnection) {'TCP'} else {$conn.Protocol} )
        }
        return $ConnectionsFound    
    }

    $ConnectionsFound = @()        
    
    foreach ($Conn in $Connections) {        
        if     ($IP)          { foreach ($DestIP in $IP)            { if (($Conn.RemoteAddress  -eq $DestIP)   -and ($DestIP   -ne '')) { CollectionNetworkData } } }
        elseif ($RemotePort)  { foreach ($DestPort in $RemotePort)  { if (($Conn.RemotePort     -eq $DestPort) -and ($DestPort -ne '')) { CollectionNetworkData } } }
        elseif ($LocalPort)   { foreach ($SrcPort in $LocalPort)    { if (($Conn.LocalPort      -eq $SrcPort)  -and ($SrcPort  -ne '')) { CollectionNetworkData } } }            
        elseif ($ProcessName) { foreach ($ProcName in $ProcessName) { if (($conn.ProcessName -match $ProcName) -and ($ProcName -ne '')) { CollectionNetworkData } } }
    }
    return $ConnectionsFound 

}
'@
# No need to call this into memory, as it's when a query is conducted
#Invoke-Expression -Command $QueryNetworkConnection
