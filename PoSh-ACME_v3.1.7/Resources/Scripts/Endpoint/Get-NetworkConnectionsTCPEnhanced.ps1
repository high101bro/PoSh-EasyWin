$Connections = Get-NetTCPConnection
$Processes   = Get-WmiObject -Class Win32_Process
ForEach ($Conn in $Connections) {
    foreach ($Proc in $Processes) {
        if ($Conn.OwningProcess -eq $Proc.ProcessId) {
            $Conn | Add-Member -MemberType NoteProperty -Name 'ProcessName' -Value $Proc.Name
            $Conn | Add-Member -MemberType NoteProperty -Name 'Duration' -Value $((New-TimeSpan -Start ($Conn.CreationTime)).ToString())
            $Conn | Add-Member -MemberType NoteProperty -Name 'CommandLine' -Value $Proc.CommandLine
        }
    }        
}
return $Connections `
    | Select-Object -Property @{name="PSComputerName";expression={$env:COMPUTERNAME}}, RemoteAddress, RemotePort, OwningProcess, ProcessName, CreationTime, CommandLine `
    | Sort-Object -Property ProcessName
