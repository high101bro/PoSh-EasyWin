$ErrorActionPreference = 'SilentlyContinue'
$CollectionTime     = Get-Date
$Processes          = Get-WmiObject Win32_Process
$Services           = Get-WmiObject Win32_Service

$ParameterSets = (Get-Command Get-NetTCPConnection).ParameterSets | Select -ExpandProperty Parameters
if (($ParameterSets | Foreach {$_.name}) -contains 'OwningProcess') {
    $NetworkConnections = Get-NetTCPConnection
}
else {
    $NetworkConnections = netstat -nao -p TCP
    $NetStat = Foreach ($line in $NetworkConnections[4..$NetworkConnections.count]) {
        $line = $line -replace '^\s+',''
        $line = $line -split '\s+'
        $properties = @{
            Protocol      = $line[0]
            LocalAddress  = ($line[1] -split ":")[0]
            LocalPort     = ($line[1] -split ":")[1]
            RemoteAddress = ($line[2] -split ":")[0]
            RemotePort    = ($line[2] -split ":")[1]
            State         = $line[3]
            ProcessId     = $line[4]
        }
        $Connection = New-Object -TypeName PSObject -Property $properties
        $proc       = Get-WmiObject -query ('select * from win32_process where ProcessId="{0}"' -f $line[4])
        $Connection | Add-Member -MemberType NoteProperty OwningProcess $proc.ProcessId
        $Connection | Add-Member -MemberType NoteProperty ParentProcessId $proc.ParentProcessId
        $Connection | Add-Member -MemberType NoteProperty Name $proc.Caption
        $Connection | Add-Member -MemberType NoteProperty ExecutablePath $proc.ExecutablePath
        $Connection | Add-Member -MemberType NoteProperty CommandLine $proc.CommandLine
        $Connection | Add-Member -MemberType NoteProperty PSComputerName $env:COMPUTERNAME
        if ($Connection.ExecutablePath -ne $null -AND -NOT $NoHash) {
            $MD5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
            $hash = [System.BitConverter]::ToString($MD5.ComputeHash([System.IO.File]::ReadAllBytes($proc.ExecutablePath)))
            $Connection | Add-Member -MemberType NoteProperty MD5 $($hash -replace "-","")
        }
        else {
            $Connection | Add-Member -MemberType NoteProperty MD5 $null
        }
        $Connection
    }
    $NetworkConnections = $NetStat | Select-Object -Property PSComputerName,Protocol,LocalAddress,LocalPort,RemoteAddress,RemotePort,State,Name,OwningProcess,ProcessId,ParentProcessId,MD5,ExecutablePath,CommandLine
}

# Create Hashtable of all network processes and their PIDs
$NetConnections = @{}
foreach ( $Connection in $NetworkConnections ) {
    $connStr = "[$($Connection.State)] " + "$($Connection.LocalAddress)" + ";" + "$($Connection.LocalPort)" + " <--> " + "$($Connection.RemoteAddress)" + ";" + "$($Connection.RemotePort)" + " [$($Connection.CreationTime)]`n"
    if ( $Connection.OwningProcess -in $NetConnections.keys ) {
        if ( $connStr -notin $NetConnections[$Connection.OwningProcess] ) { $NetConnections[$Connection.OwningProcess] += $connStr }
    }
    else { $NetConnections[$Connection.OwningProcess] = $connStr }
}

# Create HashTable of services associated to PIDs
$ServicePIDs = @{}
foreach ( $svc in $Services ) {
    if ( $svc.ProcessID -notin $ServicePIDs.keys ) {
        $ServicePIDs[$svc.ProcessID] += "$($svc.name) [$($svc.Startmode) Start By $($svc.startname)]`n"
    }
}

# Create HashTable of Process Filepath's MD5Hash 
$MD5Hashtable = @{}
foreach ( $Proc in $Processes ) {
    if ( $Proc.Path -and $Proc.Path -notin $MD5Hashtable.keys ) {
        $MD5Hashtable[$Proc.Path] += $(Get-FileHash -Path $Proc.Path -ErrorAction SilentlyContinue).Hash
    }
}

# Create HashTable of Process Filepath's Authenticode Signature Information 
$TrackPaths  = @()
$AuthenCodeSigStatus            = @{}
$AuthenCodeSigSignerCertificate = @{}
$AuthenCodeSigSignerCompany     = @{}
foreach ( $Proc in $Processes ) {
    if ( $Proc.Path -notin $TrackPaths ) {
        $TrackPaths += $Proc.Path
        $AuthenCodeSig = Get-AuthenticodeSignature -FilePath $Proc.Path -ErrorAction SilentlyContinue
        if ( $Proc.Path -notin $AuthenCodeSigStatus.keys ) { $AuthenCodeSigStatus[$Proc.Path] += $AuthenCodeSig.Status }
        if ( $Proc.Path -notin $AuthenCodeSigSignerCertificate.keys ) { $AuthenCodeSigSignerCertificate[$Proc.Path] += $AuthenCodeSig.SignerCertificate.Thumbprint }
        if ( $Proc.Path -notin $AuthenCodeSigSignerCompany.keys ) { $AuthenCodeSigSignerCompany[$Proc.Path] += $AuthenCodeSig.SignerCertificate.Subject.split(',')[0].replace('CN=','').replace('"','') }
    }
}

function Write-ProcessTree($Process) {
    $EnrichedProcess       = Get-Process -Id $Process.ProcessId

    $ProcessID             = $Process.ProcessID
    $ParentProcessID       = $Process.ParentProcessID
    $ParentProcessName     = $(Get-Process -Id $Process.ParentProcessID).Name
    #$CreationDate          = $([Management.ManagementDateTimeConverter]::ToDateTime($Process.CreationDate))

    $ServiceInfo           = $ServicePIDs[$Process.ProcessId]

    $NetConns              = $($NetConnections[$Process.ProcessId]).TrimEnd("`n")
    $NetConnsCount         = if ($NetConns) {$($NetConns -split "`n").Count} else {[int]0}

    $MD5Hash               = $MD5Hashtable[$Process.Path]

    $StatusMessage         = $AuthenCodeSigStatus[$Process.Path]
    $SignerCertificate     = $AuthenCodeSigSignerCertificate[$Process.Path]
    $SignerCompany         = $AuthenCodeSigSignerCompany[$Process.Path]

    $Modules               = $EnrichedProcess.Modules.ModuleName
    $ModuleCount           = $Modules.count

    $ThreadCount           = $EnrichedProcess.Threads.count
    
    $Owner                 = $Process.GetOwner().Domain.ToString() + "\"+ $Process.GetOwner().User.ToString()
    $OwnerSID              = $Process.GetOwnerSid().Sid.ToString()
    $EnrichedProcess `
    | Add-Member NoteProperty 'ProcessID'              $ProcessID         -PassThru -Force `
    | Add-Member NoteProperty 'ParentProcessID'        $ParentProcessID   -PassThru -Force `
    | Add-Member NoteProperty 'ParentProcessName'      $ParentProcessName -PassThru -Force `
    | Add-Member NoteProperty 'CreationDate'           $CreationDate      -PassThru -Force `
    | Add-Member NoteProperty 'ServiceInfo'            $ServiceInfo       -PassThru -Force `
    | Add-Member NoteProperty 'NetworkConnections'     $NetConns          -PassThru -Force `
    | Add-Member NoteProperty 'NetworkConnectionCount' $NetConnsCount     -PassThru -Force `
    | Add-Member NoteProperty 'StatusMessage'          $StatusMessage     -PassThru -Force `
    | Add-Member NoteProperty 'SignerCertificate'      $SignerCertificate -PassThru -Force `
    | Add-Member NoteProperty 'SignerCompany'          $SignerCompany     -PassThru -Force `
    | Add-Member NoteProperty 'MD5Hash'                $MD5Hash           -PassThru -Force `
    | Add-Member NoteProperty 'Modules'                $Modules           -PassThru -Force `
    | Add-Member NoteProperty 'ModuleCount'            $ModuleCount       -PassThru -Force `
    | Add-Member NoteProperty 'ThreadCount'            $ThreadCount       -PassThru -Force `
    | Add-Member NoteProperty 'Owner'                  $Owner             -PassThru -Force `
    | Add-Member NoteProperty 'OwnerSID'               $OwnerSID          -PassThru -Force 
}

$Processes | Foreach-Object { Write-ProcessTree -Process $PSItem} | Select Name, ProcessID, ParentProcessName, ParentProcessID, ServiceInfo,`
StartTime, @{Name='Duration';Expression={New-TimeSpan -Start $_.StartTime -End $CollectionTime}}, CPU, TotalProcessorTime, `
NetworkConnections, NetworkConnectionCount, CommandLine, Path, `
WorkingSet, @{Name='MemoryUsage';Expression={
    if     ($_.WorkingSet -gt 1GB) {"$([Math]::Round($_.WorkingSet/1GB, 2)) GB"}
    elseif ($_.WorkingSet -gt 1MB) {"$([Math]::Round($_.WorkingSet/1MB, 2)) MB"}
    elseif ($_.WorkingSet -gt 1KB) {"$([Math]::Round($_.WorkingSet/1KB, 2)) KB"}
    else                           {"$([Math]::Round($_.WorkingSet,     2)) Bytes"}
}}, `
MD5Hash, SignerCertificate, StatusMessage, SignerCompany, Company, Product, ProductVersion, Description, `
Modules, ModuleCount, Threads, ThreadCount, Handle, Handles, HandleCount, `
Owner, OwnerSID