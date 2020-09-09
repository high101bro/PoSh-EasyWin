if ([bool]((Get-Command Get-NetTCPConnection).ParameterSets | Select-Object -ExpandProperty Parameters | Where-Object Name -match OwningProcess)) {                
    $Processes           = Get-WmiObject -Class Win32_Process
    $Connections         = Get-NetTCPConnection
    
    foreach ($Conn in $Connections) {
        foreach ($Proc in $Processes) {
            if ($Conn.OwningProcess -eq $Proc.ProcessId) {
                $Conn | Add-Member -MemberType NoteProperty 'PSComputerName'  $env:COMPUTERNAME -Force
                $Conn | Add-Member -MemberType NoteProperty 'Protocol'        'TCP'
                $Conn | Add-Member -MemberType NoteProperty 'Duration'        ((New-TimeSpan -Start ($Conn.CreationTime)).ToString())
                $Conn | Add-Member -MemberType NoteProperty 'ProcessId'       $Proc.ProcessId
                $Conn | Add-Member -MemberType NoteProperty 'ParentProcessId' $Proc.ParentProcessId
                $Conn | Add-Member -MemberType NoteProperty 'ProcessName'     $Proc.Name
                $Conn | Add-Member -MemberType NoteProperty 'CommandLine'     $Proc.CommandLine
                $Conn | Add-Member -MemberType NoteProperty 'ExecutablePath'  $proc.ExecutablePath
                $Conn | Add-Member -MemberType NoteProperty 'ScriptNote'       'Get-NetTCPConnection Enhanced'

                if ($Conn.ExecutablePath -ne $null -AND -NOT $NoHash) {
                    $MD5Hash = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
                    $Hash    = [System.BitConverter]::ToString($MD5Hash.ComputeHash([System.IO.File]::ReadAllBytes($proc.ExecutablePath)))
                    $Conn | Add-Member -MemberType NoteProperty MD5Hash $($Hash -replace "-","")
                }
                else {
                    $Conn | Add-Member -MemberType NoteProperty MD5Hash $null
                }
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
                OwningProcess = $line[4]
            }
            $Connection = New-Object -TypeName PSObject -Property $Properties
            $proc       = Get-WmiObject -query ('select * from win32_process where ProcessId="{0}"' -f $line[4])
            $Connection | Add-Member -MemberType NoteProperty 'PSComputerName'  $env:COMPUTERNAME -Force
            $Connection | Add-Member -MemberType NoteProperty 'ParentProcessId' $proc.ParentProcessId
            $Connection | Add-Member -MemberType NoteProperty 'ProcessName'     $proc.Caption
            $Connection | Add-Member -MemberType NoteProperty 'ExecutablePath'  $proc.ExecutablePath
            $Connection | Add-Member -MemberType NoteProperty 'CommandLine'     $proc.CommandLine
            $Connection | Add-Member -MemberType NoteProperty 'CreationTime'    ([WMI] '').ConvertToDateTime($proc.CreationDate) 
            $Connection | Add-Member -MemberType NoteProperty 'Duration'        ((New-TimeSpan -Start ([WMI] '').ConvertToDateTime($proc.CreationDate)).ToString())
            $Connection | Add-Member -MemberType NoteProperty 'ScriptNote'      'NetStat.exe Enhanced'
            
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
        $NetStat 
    }
    $Connections = Get-Netstat
}
$Connections | Select-Object -Property PSComputerName, Protocol,LocalAddress,LocalPort,RemoteAddress,RemotePort,State,ProcessName,ProcessId,ParentProcessId,CreationTime,Duration,CommandLine,ExecutablePath,MD5Hash,OwningProcess,ScriptNote -ErrorAction SilentlyContinue