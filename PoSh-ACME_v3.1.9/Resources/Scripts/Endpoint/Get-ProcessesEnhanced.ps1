<#
.Description
This script compiles the properties from two process commands, Get-Prcoess and Get-WmiObject -Class	Win32_Process, and also adds addtional information such as matching network connections, the process' hash and signature, and owner information. Essentially, all possible information that can be obtained for each process is compiled. As more techniques and methods are identified, they will be added.
#>
function Get-ProcessEnhanced
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
        $AuthenticodeSignature = Get-AuthenticodeSignature $Process.Path
        $Process `
        | Add-Member NoteProperty ProcessNameIndented "$indent$($process.Name)" -PassThru `
        | Add-Member NoteProperty ProcessId $ProcessId -PassThru -Force `
        | Add-Member NoteProperty ParentPID $ParentProcessId -PassThru -Force `
        | Add-Member NoteProperty Level $level -PassThru -Force `
        | Add-Member NoteProperty ProcessName $Process.Name -PassThru -Force `
        | Add-Member NoteProperty ParentProcessName $((Get-Process -Id $ParentProcessId -ErrorAction SilentlyContinue).name) -PassThru -Force `
        | Add-Member NoteProperty WorkingSetSize $WorkingSetSize -PassThru -Force `
        | Add-Member NoteProperty CommandLine $CommandLine -PassThru -Force `
        | Add-Member NoteProperty NetworkConnections $($NetConns.TrimEnd("`n")) -PassThru -Force `
        | Add-Member NoteProperty NetworkConnectionCount ($($NetConns -split "`n").Count - 1) -PassThru -Force `
        | Add-Member NoteProperty CreationDate $CreationDate -PassThru -Force `
        | Add-Member NoteProperty MD5Hash $((Get-FileHash -Path ($Process.Path) -Algorithm MD5 -ErrorAction SilentlyContinue).Hash) -PassThru -Force `
        | Add-Member NoteProperty ThreadCount $($Process.Threads).Count -PassThru -Force `
        | Add-Member NoteProperty Modules $($Process.Modules.ModuleName) -PassThru -Force `
        | Add-Member NoteProperty ModuleCount $($Process.Modules.ModuleName).Count -PassThru -Force `
        | Add-Member NoteProperty StatusMessage $( if ($AuthenticodeSignature.StatusMessage -match 'verified') {'Signature Verified'}; elseif ($AuthenticodeSignature.StatusMessage -match 'not digitally signed') {'The file is not digitially signed.'}) -PassThru -Force `
        | Add-Member NoteProperty SignerCertificate $( $AuthenticodeSignature.SignerCertificate.Thumbprint) -PassThru -Force `
        | Add-Member NoteProperty SignerCompany $( $AuthenticodeSignature.SignerCertificate.Subject.split(',')[0].replace('CN=','').replace('"','')) -PassThru -Force `
        | Add-Member NoteProperty Owner $($Process.GetOwner().Domain.ToString() + "\"+ $Process.GetOwner().User.ToString()) -PassThru -Force `
        | Add-Member NoteProperty OwnerSID $($Process.GetOwnerSid().Sid.ToString()) -PassThru -Force 
        $ProcessByParent.Item($ProcessID) `
        | ? { $_ } `
        | % { Write-ProcessTree $_ ($level + 1) }
    }

    $Processes `
    | ? { $_.ProcessId -ne 0 -and ($_.ProcessId -eq $_.ParentProcessId -or $deadParents -contains $_.ParentProcessId) } `
    | % { Write-ProcessTree $_ }
}
Get-ProcessEnhanced -Verbose | select  @{name="PSComputerName";expression={$env:COMPUTERNAME}}, ProcessNameIndented, Level, ProcessId, ProcessName, ParentPID, ParentProcessName, CreationDate, WorkingSetSize, NetworkConnections, NetworkConnectionCount, CommandLine, MD5Hash, Path, Name, Handle, HandleCount, Threads, ThreadCount, StatusMessage, SignerCertificate, SignerCompany, Company, Product, Description, Modules, ModuleCount, Owner, OwnerSID
#Get-ProcessEnhanced -Verbose | select Level, ProcessId, ProcessNameIndented, ParentPID, CreationDate, WorkingSetSize, CommandLine, NetworkConnections, ProcessName | Ft -AutoSize