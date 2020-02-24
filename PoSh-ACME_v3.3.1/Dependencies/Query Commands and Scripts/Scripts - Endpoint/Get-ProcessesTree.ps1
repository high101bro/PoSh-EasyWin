function Get-ProcessTree
{
    [CmdletBinding()]
    param([string]$ComputerName, [int]$IndentSize = 5)
    
    $indentSize   = [Math]::Max(1, [Math]::Min(12, $indentSize))
    $computerName = ($computerName, ".")[[String]::IsNullOrEmpty($computerName)]
    $Processes    = Get-WmiObject Win32_Process -ComputerName $computerName
    $pids         = $Processes | select -ExpandProperty ProcessId
    $parents      = $Processes | select -ExpandProperty ParentProcessId -Unique
    $liveParents  = $parents | ? { $pids -contains $_ }
    $deadParents  = Compare-Object -ReferenceObject $parents -DifferenceObject $liveParents `
                  | select -ExpandProperty InputObject
    $ProcessByParent = $Processes | Group-Object -AsHashTable ParentProcessId

    function Write-ProcessTree($Process, [int]$level = 0) {
        $indent          = New-Object String(' ', ($level * $indentSize))
        $ProcessID       = $Process.ProcessId
        $ParentProcessId = $Process.ParentProcessId
        $CommandLine     = $Process.CommandLine
        $WorkingSetSize  = $Process.WorkingSetSize
        $CreationDate    = $([Management.ManagementDateTimeConverter]::ToDateTime($Process.CreationDate))
        $NetConns        = $NetConnections[$Process.ProcessId]
        $Process         = Get-Process -Id $ProcessID -ComputerName $computerName
        $AuthenticodeSignature = Get-AuthenticodeSignature $Process.Path
        $Process `
        | Add-Member NoteProperty ProcessNameIndented "$indent$($process.Name)" -PassThru `
        | Add-Member NoteProperty ProcessId $ProcessId -PassThru -Force `
        | Add-Member NoteProperty ParentPID $ParentProcessId -PassThru -Force `
        | Add-Member NoteProperty Level $level -PassThru -Force `
        | Add-Member NoteProperty ProcessName $Process.Name -PassThru -Force `
        | Add-Member NoteProperty ParentProcessName $((Get-Process -Id $ParentProcessId -ErrorAction SilentlyContinue).name) -PassThru -Force `
        | Add-Member NoteProperty WorkingSetSize $WorkingSetSize -PassThru -Force `
        | Add-Member NoteProperty CreationDate $CreationDate -PassThru -Force `

        $ProcessByParent.Item($ProcessID) `
        | ? { $_ } `
        | % { Write-ProcessTree $_ ($level + 1) }
    }

    $Processes `
    | ? { $_.ProcessId -ne 0 -and ($_.ProcessId -eq $_.ParentProcessId -or $deadParents -contains $_.ParentProcessId) } `
    | % { Write-ProcessTree $_ }
}
Get-ProcessTree -Verbose | select  @{name="PSComputerName";expression={$env:COMPUTERNAME}}, Level, ProcessId, ProcessNameIndented, ParentPID, ParentProcessName, CreationDate, WorkingSetSize, ProcessName, Path, Name
#Get-ProcessTree -Verbose | select Level, ProcessId, ProcessNameIndented, ParentPID, CreationDate, WorkingSetSize, CommandLine, NetworkConnections, ProcessName | Ft -AutoSize