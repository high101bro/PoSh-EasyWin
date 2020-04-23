# This function is created within a string variable as it is used with an an agrument for Start-Job
# It is initialized below with an Invoke-Expression
$QueryNetworkConnection = @'
    function Query-NetworkConnection {
        param(
            [string[]]$IP          = $null,
            [string[]]$RemotePort  = $null,
            [string[]]$LocalPort   = $null,
            [string[]]$ProcessName = $null
        )
        $Connections      = Get-NetTCPConnection
        $Processes        = Get-WmiObject -Class Win32_Process
        $ConnectionsFound = @()        
        
        foreach ($Conn in $Connections) {
            foreach ($Proc in $Processes) {
                if ($Conn.OwningProcess -eq $Proc.ProcessId) {
                    $Conn | Add-Member -MemberType NoteProperty -Name 'Duration'    -Value $((New-TimeSpan -Start ($Conn.CreationTime)).ToString())
                    $Conn | Add-Member -MemberType NoteProperty -Name 'ParentPID'   -Value $Proc.ParentProcessId
                    $Conn | Add-Member -MemberType NoteProperty -Name 'ProcessName' -Value $Proc.Name
                    $Conn | Add-Member -MemberType NoteProperty -Name 'CommandLine' -Value $Proc.CommandLine
                }
            }
        }
        foreach ($Conn in $Connections) {        
            if ($IP) {
                foreach ($DestIP in $IP) { 
                    if (($Conn.RemoteAddress -eq $DestIP) -and ($DestIP -ne '')) { 
                        $ConnectionsFound += [PSCustomObject]@{
                            LocalAddress   = $conn.LocalAddress
                            LocalPort      = $conn.LocalPort
                            RemoteAddress  = $conn.RemoteAddress
                            RemotePort     = $conn.RemotePort
                            State          = $conn.State
                            Duration       = $((New-TimeSpan -Start ($Conn.CreationTime)).ToString())
                            ParentPID      = $conn.ParentPID
                            ProcessID      = $conn.OwningProcess
                            ProcessName    = $conn.ProcessName
                            CommandLine    = $conn.CommandLine
                        }
                    } 
                }
            }
            elseif ($RemotePort) {
                foreach ($DestPort in $RemotePort) { 
                    if (($Conn.RemotePort -eq $DestPort) -and ($DestPort -ne '')) { 
                        $ConnectionsFound += [PSCustomObject]@{
                            LocalAddress   = $conn.LocalAddress
                            LocalPort      = $conn.LocalPort
                            RemoteAddress  = $conn.RemoteAddress
                            RemotePort     = $conn.RemotePort
                            State          = $conn.State
                            Duration       = $((New-TimeSpan -Start ($Conn.CreationTime)).ToString())
                            ParentPID      = $conn.ParentPID
                            ProcessID      = $conn.OwningProcess
                            ProcessName    = $conn.ProcessName
                            CommandLine    = $conn.CommandLine
                        }
                    } 
                }
            }
            elseif ($LocalPort) {
                foreach ($SrcPort in $LocalPort) { 
                    if (($Conn.LocalPort -eq $SrcPort) -and ($SrcPort -ne '')) { 
                        $ConnectionsFound += [PSCustomObject]@{
                            LocalAddress   = $conn.LocalAddress
                            LocalPort      = $conn.LocalPort
                            RemoteAddress  = $conn.RemoteAddress
                            RemotePort     = $conn.RemotePort
                            State          = $conn.State
                            Duration       = $((New-TimeSpan -Start ($Conn.CreationTime)).ToString())
                            ParentPID      = $conn.ParentPID
                            ProcessID      = $conn.OwningProcess
                            ProcessName    = $conn.ProcessName
                            CommandLine    = $conn.CommandLine
                        }
                    } 
                }
            }            
            elseif ($ProcessName) {
                foreach ($ProcName in $ProcessName) { 
                    if (($conn.ProcessName -match $ProcName) -and ($ProcName -ne '')) { 
                        $ConnectionsFound += [PSCustomObject]@{
                            LocalAddress   = $conn.LocalAddress
                            LocalPort      = $conn.LocalPort
                            RemoteAddress  = $conn.RemoteAddress
                            RemotePort     = $conn.RemotePort
                            State          = $conn.State
                            Duration       = $((New-TimeSpan -Start ($Conn.CreationTime)).ToString())
                            ParentPID      = $conn.ParentPID
                            ProcessID      = $conn.OwningProcess
                            ProcessName    = $conn.ProcessName
                            CommandLine    = $conn.CommandLine
                        }
                    } 
                }
            }
        }
        return $ConnectionsFound
    }
'@
# No need to call this into memory, as it's when a query is conducted
#Invoke-Expression -Command $QueryNetworkConnection
