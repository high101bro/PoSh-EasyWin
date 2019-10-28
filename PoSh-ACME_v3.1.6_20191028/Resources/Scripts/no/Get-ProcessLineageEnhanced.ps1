function Get-ProcessLineage
{
    [CmdletBinding()]
    param([string]$ComputerName, [int]$IndentSize = 2)
    
    $indentSize   = [Math]::Max(1, [Math]::Min(12, $indentSize))
    $computerName = ($computerName, ".")[[String]::IsNullOrEmpty($computerName)]
    $Processes    = Get-WmiObject Win32_Process -ComputerName $computerName
    $pids         = $Processes | select -ExpandProperty ProcessId
    $parents      = $Processes | select -ExpandProperty ParentProcessId -Unique
    $liveParents  = $parents | ? { $pids -contains $_ }
    $deadParents  = Compare-Object -ReferenceObject $parents -DifferenceObject $liveParents `
                  | select -ExpandProperty InputObject
    $ProcessByParent = $Processes | Group-Object -AsHashTable ParentProcessId
    

    # Create Hashtable of all network processes and their PIDs
    $NetConnections = @{}
    foreach($Connection in Get-NetTCPConnection) {
        $connStr = "[$($Connection.State)] " + "$($Connection.LocalAddress)" + ";" + "$($Connection.LocalPort)" + " <--> " + "$($Connection.RemoteAddress)" + ";" + "$($Connection.RemotePort)" + " [$($Connection.CreationTime)]`n"
        if($Connection.OwningProcess -in $NetConnections.keys) {
            if($connStr -notin $NetConnections[$Connection.OwningProcess]) {
                $NetConnections[$Connection.OwningProcess] += $connStr
            }
        }
        else{
            $NetConnections[$Connection.OwningProcess] = $connStr
        }
    }

    function Write-ProcessTree($Process, [int]$level = 0) {
        $indent          = New-Object String(' ', ($level * $indentSize))
        $ProcessID       = $Process.ProcessId
        $ParentProcessId = $Process.ParentProcessId
        $CommandLine     = $Process.CommandLine
        $WorkingSetSize  = $Process.WorkingSetSize
        $CreationDate    = $([Management.ManagementDateTimeConverter]::ToDateTime($Process.CreationDate))
        $NetConns        = $NetConnections[$Process.ProcessId]
        $Process         = Get-Process -Id $ProcessID -ComputerName $computerName
        $Process `
        | Add-Member NoteProperty IndentedName "$indent$($process.Name)" -PassThru `
        | Add-Member NoteProperty ProcessId $ProcessId -PassThru -Force `
        | Add-Member NoteProperty ParentPID $ParentProcessId -PassThru -Force `
        | Add-Member NoteProperty Level $level -PassThru -Force `
        | Add-Member NoteProperty ProcessName $Process.Name -PassThru -Force `
        | Add-Member NoteProperty WorkingSetSize $WorkingSetSize -PassThru -Force `
        | Add-Member NoteProperty CommandLine $CommandLine -PassThru -Force `
        | Add-Member NoteProperty NetworkConnections $NetConns -PassThru -Force `
        | Add-Member NoteProperty CreationDate $CreationDate -PassThru -Force
        $ProcessByParent.Item($ProcessID) `
        | ? { $_ } `
        | % { Write-ProcessTree $_ ($level + 1) }
    }

    $Processes `
    | ? { $_.ProcessId -ne 0 -and ($_.ProcessId -eq $_.ParentProcessId -or $deadParents -contains $_.ParentProcessId) } `
    | % { Write-ProcessTree $_ }
}
Get-ProcessLineage -Verbose | select @{name="PSComputerName";expression={$env:COMPUTERNAME}}, Level, ProcessId, IndentedName, ParentPID, CreationDate, WorkingSetSize, CommandLine, NetworkConnections, ProcessName
#Get-ProcessLineage -Verbose | select Level, ProcessId, IndentedName, ParentPID, CreationDate, WorkingSetSize, CommandLine, NetworkConnections, ProcessName -PipelineVariable $pass | Ft -AutoSize