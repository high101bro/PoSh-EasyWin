<#
    .SYNOPSIS
    Obtains and enriches process data

    .DESCRIPTION
    -This script queries for process data and enriches it with a lot of associated information such as:
        Additional Process data
        Network Connections
        Service Information
        Signer Certificate Information
        File Hashes

    .EXAMPLE
    None

    .LINK
    https://github.com/high101bro/PoSh-EasyWin
    
    .NOTES
    None
#>
$ErrorActionPreference = 'SilentlyContinue'
$CollectionTime     = Get-Date
$GetProcess         = Get-Process
$Processes          = Get-WmiObject Win32_Process
$Services           = Get-WmiObject Win32_Service



$ParameterSets = (Get-Command Get-NetTCPConnection).ParameterSets | Select -ExpandProperty Parameters
if (($ParameterSets | ForEach-Object {$_.name}) -contains 'OwningProcess') {
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
        $Connection | Add-Member -MemberType NoteProperty OwningProcess $proc.ProcessId -Force
        $Connection | Add-Member -MemberType NoteProperty ParentProcessId $proc.ParentProcessId -Force
        $Connection | Add-Member -MemberType NoteProperty Name $proc.Caption -Force
        $Connection | Add-Member -MemberType NoteProperty ExecutablePath $proc.ExecutablePath -Force
        $Connection | Add-Member -MemberType NoteProperty CommandLine $proc.CommandLine -Force
        $Connection | Add-Member -MemberType NoteProperty PSComputerName $env:COMPUTERNAME -Force
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
$NetworkConnectionsTotal       = @{}
$NetworkConnectionsTypes       = @{}
$NetworkConnectionsBound       = @{}
$NetworkConnectionsClosed      = @{}
$NetworkConnectionsCloseWait   = @{}
$NetworkConnectionsClosing     = @{}
$NetworkConnectionsDeleteTCB   = @{}
$NetworkConnectionsEstablished = @{}
$NetworkConnectionsFinWait1    = @{}
$NetworkConnectionsFinWait2    = @{}
$NetworkConnectionsLastAck     = @{}
$NetworkConnectionsListen      = @{}
$NetworkConnectionsSynReceived = @{}
$NetworkConnectionsSynSent     = @{}
$NetworkConnectionsTimeWait    = @{}

foreach ( $Connection in $NetworkConnections ) {
    $connStrTot = "[$($Connection.State)] " + "$($Connection.LocalAddress)" + ";" + "$($Connection.LocalPort)" + " <--> " + "$($Connection.RemoteAddress)" + ";" + "$($Connection.RemotePort)" + " [$($Connection.CreationTime)]" + "`n"

    if ( $Connection.OwningProcess -in $NetworkConnectionsTotal.keys ) {
        if ( $connStrTot -notin $NetworkConnectionsTotal[$Connection.OwningProcess] ) {
            $NetworkConnectionsTotal[$Connection.OwningProcess] += $connStrTot
        }
        if ( $Connection.State -notin $NetworkConnectionsTypes[$Connection.OwningProcess] ) {
            $NetworkConnectionsTypes[$Connection.OwningProcess] += "$($Connection.State),"
        }
    }
    else {
        $NetworkConnectionsTotal[$Connection.OwningProcess] = $connStrTot
        if ( $Connection.State -notin $NetworkConnectionsTypes[$Connection.OwningProcess] ) {
            $NetworkConnectionsTypes[$Connection.OwningProcess] += "$($Connection.State),"
        }
    }


    if ($Connection.State -eq 'Bound') {
        if ($Connection.CreationTime){
            $connStr = "[$($Connection.CreationTime)] " + "$($Connection.LocalAddress)" + ";" + "$($Connection.LocalPort)" + " <--> " + "$($Connection.RemoteAddress)" + ";" + "$($Connection.RemotePort)`n"
        }
        else {
            $connStr = "$($Connection.LocalAddress)" + ";" + "$($Connection.LocalPort)" + " <--> " + "$($Connection.RemoteAddress)" + ";" + "$($Connection.RemotePort)`n"
        }

        if ( $Connection.OwningProcess -in $NetworkConnectionsBound.keys ) {
            if ( $connStr -notin $NetworkConnectionsBound[$Connection.OwningProcess] ) { $NetworkConnectionsBound[$Connection.OwningProcess] += $connStr }
        }
        else {
            $NetworkConnectionsBound[$Connection.OwningProcess] = $connStr
        }
    }
    elseif ($Connection.State -eq 'Closed') {
        if ($Connection.CreationTime){
            $connStr = "[$($Connection.CreationTime)] " + "$($Connection.LocalAddress)" + ";" + "$($Connection.LocalPort)" + " <--> " + "$($Connection.RemoteAddress)" + ";" + "$($Connection.RemotePort)`n"
        }
        else {
            $connStr = "$($Connection.LocalAddress)" + ";" + "$($Connection.LocalPort)" + " <--> " + "$($Connection.RemoteAddress)" + ";" + "$($Connection.RemotePort)`n"
        }

        if ( $Connection.OwningProcess -in $NetworkConnectionsClosed.keys ) {
            if ( $connStr -notin $NetworkConnectionsClosed[$Connection.OwningProcess] ) { $NetworkConnectionsClosed[$Connection.OwningProcess] += $connStr }
        }
        else {
            $NetworkConnectionsClosed[$Connection.OwningProcess] = $connStr
        }
    }
    elseif ($Connection.State -eq 'CloseWait') {
        if ($Connection.CreationTime){
            $connStr = "[$($Connection.CreationTime)] " + "$($Connection.LocalAddress)" + ";" + "$($Connection.LocalPort)" + " <--> " + "$($Connection.RemoteAddress)" + ";" + "$($Connection.RemotePort)`n"
        }
        else {
            $connStr = "$($Connection.LocalAddress)" + ";" + "$($Connection.LocalPort)" + " <--> " + "$($Connection.RemoteAddress)" + ";" + "$($Connection.RemotePort)`n"
        }

        if ( $Connection.OwningProcess -in $NetworkConnectionsCloseWait.keys ) {
            if ( $connStr -notin $NetworkConnectionsCloseWait[$Connection.OwningProcess] ) { $NetworkConnectionsCloseWait[$Connection.OwningProcess] += $connStr }
        }
        else {
            $NetworkConnectionsCloseWait[$Connection.OwningProcess] = $connStr
        }
    }
    elseif ($Connection.State -eq 'Closing') {
        if ($Connection.CreationTime){
            $connStr = "[$($Connection.CreationTime)] " + "$($Connection.LocalAddress)" + ";" + "$($Connection.LocalPort)" + " <--> " + "$($Connection.RemoteAddress)" + ";" + "$($Connection.RemotePort)`n"
        }
        else {
            $connStr = "$($Connection.LocalAddress)" + ";" + "$($Connection.LocalPort)" + " <--> " + "$($Connection.RemoteAddress)" + ";" + "$($Connection.RemotePort)`n"
        }

        if ( $Connection.OwningProcess -in $NetworkConnectionsClosing.keys ) {
            if ( $connStr -notin $NetworkConnectionsClosing[$Connection.OwningProcess] ) { $NetworkConnectionsClosing[$Connection.OwningProcess] += $connStr }
        }
        else {
            $NetworkConnectionsClosing[$Connection.OwningProcess] = $connStr
        }
    }
    elseif ($Connection.State -eq 'DeleteTCB') {
        if ($Connection.CreationTime){
            $connStr = "[$($Connection.CreationTime)] " + "$($Connection.LocalAddress)" + ";" + "$($Connection.LocalPort)" + " <--> " + "$($Connection.RemoteAddress)" + ";" + "$($Connection.RemotePort)`n"
        }
        else {
            $connStr = "$($Connection.LocalAddress)" + ";" + "$($Connection.LocalPort)" + " <--> " + "$($Connection.RemoteAddress)" + ";" + "$($Connection.RemotePort)`n"
        }

        if ( $Connection.OwningProcess -in $NetworkConnectionsDeleteTCB.keys ) {
            if ( $connStr -notin $NetworkConnectionsDeleteTCB[$Connection.OwningProcess] ) { $NetworkConnectionsDeleteTCB[$Connection.OwningProcess] += $connStr }
        }
        else {
            $NetworkConnectionsDeleteTCB[$Connection.OwningProcess] = $connStr
        }
    }
    elseif ($Connection.State -eq 'Established') {
        if ($Connection.CreationTime){
            $connStr = "[$($Connection.CreationTime)] " + "$($Connection.LocalAddress)" + ";" + "$($Connection.LocalPort)" + " <--> " + "$($Connection.RemoteAddress)" + ";" + "$($Connection.RemotePort)`n"
        }
        else {
            $connStr = "$($Connection.LocalAddress)" + ";" + "$($Connection.LocalPort)" + " <--> " + "$($Connection.RemoteAddress)" + ";" + "$($Connection.RemotePort)`n"
        }

        if ( $Connection.OwningProcess -in $NetworkConnectionsEstablished.keys ) {
            if ( $connStr -notin $NetworkConnectionsEstablished[$Connection.OwningProcess] ) { $NetworkConnectionsEstablished[$Connection.OwningProcess] += $connStr }
        }
        else {
            $NetworkConnectionsEstablished[$Connection.OwningProcess] = $connStr
        }
    }
    elseif ($Connection.State -eq 'FinWait1') {
        if ($Connection.CreationTime){
            $connStr = "[$($Connection.CreationTime)] " + "$($Connection.LocalAddress)" + ";" + "$($Connection.LocalPort)" + " <--> " + "$($Connection.RemoteAddress)" + ";" + "$($Connection.RemotePort)`n"
        }
        else {
            $connStr = "$($Connection.LocalAddress)" + ";" + "$($Connection.LocalPort)" + " <--> " + "$($Connection.RemoteAddress)" + ";" + "$($Connection.RemotePort)`n"
        }

        if ( $Connection.OwningProcess -in $NetworkConnectionsFinWait1.keys ) {
            if ( $connStr -notin $NetworkConnectionsFinWait1[$Connection.OwningProcess] ) { $NetworkConnectionsFinWait1[$Connection.OwningProcess] += $connStr }
        }
        else {
            $NetworkConnectionsFinWait1[$Connection.OwningProcess] = $connStr
        }
    }
    elseif ($Connection.State -eq 'FinWait2') {
        if ($Connection.CreationTime){
            $connStr = "[$($Connection.CreationTime)] " + "$($Connection.LocalAddress)" + ";" + "$($Connection.LocalPort)" + " <--> " + "$($Connection.RemoteAddress)" + ";" + "$($Connection.RemotePort)`n"
        }
        else {
            $connStr = "$($Connection.LocalAddress)" + ";" + "$($Connection.LocalPort)" + " <--> " + "$($Connection.RemoteAddress)" + ";" + "$($Connection.RemotePort)`n"
        }

        if ( $Connection.OwningProcess -in $NetworkConnectionsFinWait2.keys ) {
            if ( $connStr -notin $NetworkConnectionsFinWait2[$Connection.OwningProcess] ) { $NetworkConnectionsFinWait2[$Connection.OwningProcess] += $connStr }
        }
        else {
            $NetworkConnectionsFinWait2[$Connection.OwningProcess] = $connStr
        }
    }
    elseif ($Connection.State -eq 'LastAck') {
        if ($Connection.CreationTime){
            $connStr = "[$($Connection.CreationTime)] " + "$($Connection.LocalAddress)" + ";" + "$($Connection.LocalPort)" + " <--> " + "$($Connection.RemoteAddress)" + ";" + "$($Connection.RemotePort)`n"
        }
        else {
            $connStr = "$($Connection.LocalAddress)" + ";" + "$($Connection.LocalPort)" + " <--> " + "$($Connection.RemoteAddress)" + ";" + "$($Connection.RemotePort)`n"
        }

        if ( $Connection.OwningProcess -in $NetworkConnectionsLastAck.keys ) {
            if ( $connStr -notin $NetworkConnectionsLastAck[$Connection.OwningProcess] ) { $NetworkConnectionsLastAck[$Connection.OwningProcess] += $connStr }
        }
        else {
            $NetworkConnectionsLastAck[$Connection.OwningProcess] = $connStr
        }
    }
    elseif ($Connection.State -eq 'Listen') {
        if ($Connection.CreationTime){
            $connStr = "[$($Connection.CreationTime)] " + "$($Connection.LocalAddress)" + ";" + "$($Connection.LocalPort)" + " <--> " + "$($Connection.RemoteAddress)" + ";" + "$($Connection.RemotePort)`n"
        }
        else {
            $connStr = "$($Connection.LocalAddress)" + ";" + "$($Connection.LocalPort)" + " <--> " + "$($Connection.RemoteAddress)" + ";" + "$($Connection.RemotePort)`n"
        }

        if ( $Connection.OwningProcess -in $NetworkConnectionsListen.keys ) {
            if ( $connStr -notin $NetworkConnectionsListen[$Connection.OwningProcess] ) { $NetworkConnectionsListen[$Connection.OwningProcess] += $connStr }
        }
        else {
            $NetworkConnectionsListen[$Connection.OwningProcess] = $connStr
        }
    }
    elseif ($Connection.State -eq 'SynReceived') {
        if ($Connection.CreationTime){
            $connStr = "[$($Connection.CreationTime)] " + "$($Connection.LocalAddress)" + ";" + "$($Connection.LocalPort)" + " <--> " + "$($Connection.RemoteAddress)" + ";" + "$($Connection.RemotePort)`n"
        }
        else {
            $connStr = "$($Connection.LocalAddress)" + ";" + "$($Connection.LocalPort)" + " <--> " + "$($Connection.RemoteAddress)" + ";" + "$($Connection.RemotePort)`n"
        }

        if ( $Connection.OwningProcess -in $NetworkConnectionsSynReceived.keys ) {
            if ( $connStr -notin $NetworkConnectionsSynReceived[$Connection.OwningProcess] ) { $NetworkConnectionsSynReceived[$Connection.OwningProcess] += $connStr }
        }
        else {
            $NetworkConnectionsSynReceived[$Connection.OwningProcess] = $connStr
        }
    }
    elseif ($Connection.State -eq 'SynSent') {
        if ($Connection.CreationTime){
            $connStr = "[$($Connection.CreationTime)] " + "$($Connection.LocalAddress)" + ";" + "$($Connection.LocalPort)" + " <--> " + "$($Connection.RemoteAddress)" + ";" + "$($Connection.RemotePort)`n"
        }
        else {
            $connStr = "$($Connection.LocalAddress)" + ";" + "$($Connection.LocalPort)" + " <--> " + "$($Connection.RemoteAddress)" + ";" + "$($Connection.RemotePort)`n"
        }

        if ( $Connection.OwningProcess -in $NetworkConnectionsSynSent.keys ) {
            if ( $connStr -notin $NetworkConnectionsSynSent[$Connection.OwningProcess] ) { $NetworkConnectionsSynSent[$Connection.OwningProcess] += $connStr }
        }
        else {
            $NetworkConnectionsSynSent[$Connection.OwningProcess] = $connStr
        }
    }
    elseif ($Connection.State -eq 'TimeWait') {
        if ($Connection.CreationTime){
            $connStr = "[$($Connection.CreationTime)] " + "$($Connection.LocalAddress)" + ";" + "$($Connection.LocalPort)" + " <--> " + "$($Connection.RemoteAddress)" + ";" + "$($Connection.RemotePort)`n"
        }
        else {
            $connStr = "$($Connection.LocalAddress)" + ";" + "$($Connection.LocalPort)" + " <--> " + "$($Connection.RemoteAddress)" + ";" + "$($Connection.RemotePort)`n"
        }

        if ( $Connection.OwningProcess -in $NetworkConnectionsTimeWait.keys ) {
            if ( $connStr -notin $NetworkConnectionsTimeWait[$Connection.OwningProcess] ) { $NetworkConnectionsTimeWait[$Connection.OwningProcess] += $connStr }
        }
        else {
            $NetworkConnectionsTimeWait[$Connection.OwningProcess] = $connStr
        }
    }
}



$ServiceAssociated = @{}
foreach ( $svc in $Services ) {
    if ( $svc.ProcessID -notin $ServiceAssociated.keys ) {
        $ServiceAssociated[$svc.ProcessID] += $svc.name
    }
}

$ServiceStartMode = @{}
foreach ( $svc in $Services ) {
    if ( $svc.ProcessID -notin $ServiceStartMode.keys ) {
        $ServiceStartMode[$svc.ProcessID] += $svc.Startmode
    }
}

$ServiceStartedBy = @{}
foreach ( $svc in $Services ) {
    if ( $svc.ProcessID -notin $ServiceStartedBy.keys ) {
        $ServiceStartedBy[$svc.ProcessID] += $svc.startname
    }
}



$MD5Hashtable = @{}
foreach ( $Proc in $Processes ) {
    if ( $Proc.Path -and $Proc.Path -notin $MD5Hashtable.keys ) {
        $MD5Hashtable[$Proc.Path] += $(Get-FileHash -Path $Proc.Path -ErrorAction SilentlyContinue).Hash
    }
}



<#
    $AdsFound = $AllFiles | ForEach-Object { Get-Item $_.FullName -Force -Stream * -ErrorAction SilentlyContinue } | Where-Object stream -ne ':$DATA'
    foreach ($Ads in $AdsFound) {
        $AdsData = Get-Content -Path "$($Ads.FileName)" -Stream "$($Ads.Stream)"
        $Ads | Add-Member -MemberType NoteProperty -Name PSComputerName -Value $($Env:ComputerName)
        #too much... $Ads | Add-Member -MemberType NoteProperty -Name StreamData -Value $AdsData
        $Ads | Add-Member -MemberType NoteProperty -Name StreamDataSample -Value $(($AdsData | Out-String)[0..1000] -join "")
        if     (($Ads.Stream -eq 'Zone.Identifier') -and ($Ads.StreamDataSample -match 'ZoneID=0')) { $Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "[ZoneID 0] Local Machine Zone: The most trusted zone for content that exists on the local computer." }
        elseif (($Ads.Stream -eq 'Zone.Identifier') -and ($Ads.StreamDataSample -match 'ZoneID=1')) { $Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "[ZoneID 1] Local Intranet Zone: For content located on an organizationâ€™s intranet." }
        elseif (($Ads.Stream -eq 'Zone.Identifier') -and ($Ads.StreamDataSample -match 'ZoneID=2')) { $Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "[ZoneID 2] Trusted Sites Zone: For content located on Web sites that are considered more reputable or trustworthy than other sites on the Internet." }
        elseif (($Ads.Stream -eq 'Zone.Identifier') -and ($Ads.StreamDataSample -match 'ZoneID=3')) { $Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "[ZoneID 3] Internet Zone: For Web sites on the Internet that do not belong to another zone." }
        elseif (($Ads.Stream -eq 'Zone.Identifier') -and ($Ads.StreamDataSample -match 'ZoneID=4')) { $Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "[ZoneID 4] Restricted Sites Zone: For Web sites that contain potentially-unsafe content." }
        else {$Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "N/A"}
        $Ads | Add-Member -MemberType NoteProperty -Name FileSize -Value $(
            if     ($Ads.Length -gt 1000000000) { "$([Math]::Round($($Ads.Length / 1gb),2)) GB" }
            elseif ($Ads.Length -gt 1000000)    { "$([Math]::Round($($Ads.Length / 1mb),2)) MB" }
            elseif ($Ads.Length -gt 1000)       { "$([Math]::Round($($Ads.Length / 1kb),2)) KB" }
            elseif ($Ads.Length -le 1000)       { "$($Ads.Length) Bytes" }
        )
    }
    $AdsFound
#>
$ADS = @{}
foreach ( $Proc in $Processes ) {
    if ( $Proc.Path -and $Proc.Path -notin $ADS.keys ) {
        $ADS[$Proc.Path] += Get-Item -Path $Proc.Path -Stream * -ErrorAction SilentlyContinue | Where-Object {$_.Stream -ne ':$DATA'}
    }
}



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
    $EnrichedProcess       = $GetProcess | Where-OBject {$_.Id -eq $Process.ProcessId}
    
    $ProcessID             = $Process.ProcessID
    $ParentProcessID       = $Process.ParentProcessID
    $ParentProcessName     =  ($GetProcess | Where-OBject {$_.Id -eq $Process.ParentProcessID}).Name
    
    $CommandLine           = $Process.CommandLine
    $ParentCommandLine     = ($Processes | Where-Object {$_.ProcessId -eq $ParentProcessID}).CommandLine

    $CreationDate          = [Management.ManagementDateTimeConverter]::ToDateTime($Process.CreationDate)

    $ServiceAssociated     = $ServiceAssociated[$Process.ProcessId]
    $ServiceStartMode      = $ServiceStartMode[$Process.ProcessId]
    $ServiceStartedBy      = $ServiceStartedBy[$Process.ProcessId]

    $NetworkConnTypes            = (($NetworkConnectionsTypes[$Process.ProcessId]).TrimEnd(",") -split ',' | Sort-Object -Unique ) -join ', '

    $NetworkConnTotal            = ($NetworkConnectionsTotal[$Process.ProcessId]).TrimEnd("`n")
    $NetworkConnTotalCount       = if ($NetworkConnTotal) {$($NetworkConnTotal -split "`n").Count}
    $NetworkConnBound            = ($NetworkConnectionsBound[$Process.ProcessId]).TrimEnd("`n")
    $NetworkConnBoundCount       = if ($NetworkConnBound) {$($NetworkConnBound -split "`n").Count}
    $NetworkConnClosed           = ($NetworkConnectionsClosed[$Process.ProcessId]).TrimEnd("`n")
    $NetworkConnClosedCount      = if ($NetworkConnClosed) {$($NetworkConnClosed -split "`n").Count}
    $NetworkConnCloseWait        = ($NetworkConnectionsCloseWait[$Process.ProcessId]).TrimEnd("`n")
    $NetworkConnCloseWaitCount   = if ($NetworkConnCloseWait) {$($NetworkConnCloseWait -split "`n").Count}
    $NetworkConnClosing          = ($NetworkConnectionsClosing[$Process.ProcessId]).TrimEnd("`n")
    $NetworkConnClosingCount     = if ($NetworkConnClosing) {$($NetworkConnClosing -split "`n").Count}
    $NetworkConnDeleteTCB        = ($NetworkConnectionsDeleteTCB[$Process.ProcessId]).TrimEnd("`n")
    $NetworkConnDeleteTCBCount   = if ($NetworkConnDeleteTCB) {$($NetworkConnDeleteTCB -split "`n").Count}
    $NetworkConnEstablished      = ($NetworkConnectionsEstablished[$Process.ProcessId]).TrimEnd("`n")
    $NetworkConnEstablishedCount = if ($NetworkConnEstablished) {$($NetworkConnEstablished -split "`n").Count}
    $NetworkConnFinWait1         = ($NetworkConnectionsFinWait1[$Process.ProcessId]).TrimEnd("`n")
    $NetworkConnFinWait1Count    = if ($NetworkConnFinWait1) {$($NetworkConnFinWait1 -split "`n").Count}
    $NetworkConnFinWait2         = ($NetworkConnectionsFinWait2[$Process.ProcessId]).TrimEnd("`n")
    $NetworkConnFinWait2Count    = if ($NetworkConnFinWait2) {$($NetworkConnFinWait2 -split "`n").Count}
    $NetworkConnLastAck          = ($NetworkConnectionsLastAck[$Process.ProcessId]).TrimEnd("`n")
    $NetworkConnLastAckCount     = if ($NetworkConnLastAck) {$($NetworkConnLastAck -split "`n").Count}
    $NetworkConnListen           = ($NetworkConnectionsListen[$Process.ProcessId]).TrimEnd("`n")
    $NetworkConnListenCount      = if ($NetworkConnListen) {$($NetworkConnListen -split "`n").Count}
    $NetworkConnSynReceived      = ($NetworkConnectionsSynReceived[$Process.ProcessId]).TrimEnd("`n")
    $NetworkConnSynReceivedCount = if ($NetworkConnSynReceived) {$($NetworkConnSynReceived -split "`n").Count}
    $NetworkConnSynSent          = ($NetworkConnectionsSynSent[$Process.ProcessId]).TrimEnd("`n")
    $NetworkConnSynSentCount     = if ($NetworkConnSynSent) {$($NetworkConnSynSent -split "`n").Count}
    $NetworkConnTimeWait         = ($NetworkConnectionsTimeWait[$Process.ProcessId]).TrimEnd("`n")
    $NetworkConnTimeWaitCount    = if ($NetworkConnTimeWait) {$($NetworkConnTimeWait -split "`n").Count}

    $MD5Hash                     = $MD5Hashtable[$Process.Path]

    $AlternateDataStream         = $ADS[$Process.Path].Stream
    $AlternateDataStreamLength   = $ADS[$Process.Path].Length

    $StatusMessage         = $AuthenCodeSigStatus[$Process.Path]
    $SignerCertificate     = $AuthenCodeSigSignerCertificate[$Process.Path]
    $SignerCompany         = $AuthenCodeSigSignerCompany[$Process.Path]

    $Modules               = "$($EnrichedProcess.Modules.ModuleName -join ', ')"
    $ModuleCount           = $($Modules -split ',').count

    $ThreadCount           = $EnrichedProcess.Threads.count

    $Owner                 = $Process.GetOwner().Domain.ToString() + "\"+ $Process.GetOwner().User.ToString()
    $OwnerSID              = $Process.GetOwnerSid().Sid.ToString()
    $EnrichedProcess `
    | Add-Member NoteProperty 'ProcessID'              $ProcessID         -PassThru -Force `
    | Add-Member NoteProperty 'ParentProcessID'        $ParentProcessID   -PassThru -Force `
    | Add-Member NoteProperty 'ParentProcessName'      $ParentProcessName -PassThru -Force `
    | Add-Member NoteProperty 'CommandLine'            $CommandLine       -PassThru -Force `
    | Add-Member NoteProperty 'ParentCommandLine'      $ParentCommandLine -PassThru -Force `
    | Add-Member NoteProperty 'CreationDate'           $CreationDate      -PassThru -Force `
    | Add-Member NoteProperty 'ServiceAssociated'      $ServiceAssociated -PassThru -Force `
    | Add-Member NoteProperty 'ServiceStartMode'       $ServiceStartMode  -PassThru -Force `
    | Add-Member NoteProperty 'ServiceStartedBy'       $ServiceStartedBy  -PassThru -Force `
    | Add-Member NoteProperty 'NetworkConnectionsTypes'            $NetworkConnTypes            -PassThru -Force `
    | Add-Member NoteProperty 'NetworkConnectionsTotal'            $NetworkConnTotal            -PassThru -Force `
    | Add-Member NoteProperty 'NetworkConnectionsTotalCount'       $NetworkConnTotalCount       -PassThru -Force `
    | Add-Member NoteProperty 'NetworkConnectionsBound'            $NetworkConnBound            -PassThru -Force `
    | Add-Member NoteProperty 'NetworkConnectionsBoundcount'       $NetworkConnBoundcount       -PassThru -Force `
    | Add-Member NoteProperty 'NetworkConnectionsClosed'           $NetworkConnClosed           -PassThru -Force `
    | Add-Member NoteProperty 'NetworkConnectionsClosedcount'      $NetworkConnClosedcount      -PassThru -Force `
    | Add-Member NoteProperty 'NetworkConnectionsCloseWait'        $NetworkConnCloseWait        -PassThru -Force `
    | Add-Member NoteProperty 'NetworkConnectionsCloseWaitcount'   $NetworkConnCloseWaitcount   -PassThru -Force `
    | Add-Member NoteProperty 'NetworkConnectionsClosing'          $NetworkConnClosing          -PassThru -Force `
    | Add-Member NoteProperty 'NetworkConnectionsClosingcount'     $NetworkConnClosingcount     -PassThru -Force `
    | Add-Member NoteProperty 'NetworkConnectionsDeleteTCB'        $NetworkConnDeleteTCB        -PassThru -Force `
    | Add-Member NoteProperty 'NetworkConnectionsDeleteTCBcount'   $NetworkConnDeleteTCBcount   -PassThru -Force `
    | Add-Member NoteProperty 'NetworkConnectionsEstablished'      $NetworkConnEstablished      -PassThru -Force `
    | Add-Member NoteProperty 'NetworkConnectionsEstablishedcount' $NetworkConnEstablishedcount -PassThru -Force `
    | Add-Member NoteProperty 'NetworkConnectionsFinWait1'         $NetworkConnFinWait1         -PassThru -Force `
    | Add-Member NoteProperty 'NetworkConnectionsFinWait1count'    $NetworkConnFinWait1count    -PassThru -Force `
    | Add-Member NoteProperty 'NetworkConnectionsFinWait2'         $NetworkConnFinWait2         -PassThru -Force `
    | Add-Member NoteProperty 'NetworkConnectionsFinWait2count'    $NetworkConnFinWait2count    -PassThru -Force `
    | Add-Member NoteProperty 'NetworkConnectionsLastAck'          $NetworkConnLastAck          -PassThru -Force `
    | Add-Member NoteProperty 'NetworkConnectionsLastAckcount'     $NetworkConnLastAckcount     -PassThru -Force `
    | Add-Member NoteProperty 'NetworkConnectionsListen'           $NetworkConnListen           -PassThru -Force `
    | Add-Member NoteProperty 'NetworkConnectionsListencount'      $NetworkConnListencount      -PassThru -Force `
    | Add-Member NoteProperty 'NetworkConnectionsSynReceived'      $NetworkConnSynReceived      -PassThru -Force `
    | Add-Member NoteProperty 'NetworkConnectionsSynReceivedcount' $NetworkConnSynReceivedcount -PassThru -Force `
    | Add-Member NoteProperty 'NetworkConnectionsSynSent'          $NetworkConnSynSent          -PassThru -Force `
    | Add-Member NoteProperty 'NetworkConnectionsSynSentcount'     $NetworkConnSynSentcount     -PassThru -Force `
    | Add-Member NoteProperty 'NetworkConnectionsTimeWait'         $NetworkConnTimeWait         -PassThru -Force `
    | Add-Member NoteProperty 'NetworkConnectionsTimeWaitcount'    $NetworkConnTimeWaitcount    -PassThru -Force `
    | Add-Member NoteProperty 'AlternateDataStream'                $AlternateDataStream         -PassThru -Force `
    | Add-Member NoteProperty 'AlternateDataStreamLength'          $AlternateDataStreamLength   -PassThru -Force `
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



$Processes | Foreach-Object { Write-ProcessTree -Process $PSItem} | Select Name, ProcessID, ParentProcessName, ParentProcessID,`
StartTime, @{Name='Duration';Expression={New-TimeSpan -Start $_.StartTime -End $CollectionTime}},`
ServiceAssociated, ServiceStartMode, ServiceStartedBy,`
CommandLine, ParentCommandLine, Path, `
CPU, TotalProcessorTime, WorkingSet, @{Name='MemoryUsage';Expression={
    if     ($_.WorkingSet -gt 1GB) {"$([Math]::Round($_.WorkingSet/1GB, 2)) GB"}
    elseif ($_.WorkingSet -gt 1MB) {"$([Math]::Round($_.WorkingSet/1MB, 2)) MB"}
    elseif ($_.WorkingSet -gt 1KB) {"$([Math]::Round($_.WorkingSet/1KB, 2)) KB"}
    else                           {"$([Math]::Round($_.WorkingSet,     2)) Bytes"}
}}, `
MD5Hash, SignerCertificate, StatusMessage, SignerCompany, Company, Product, ProductVersion, Description, `
Modules, ModuleCount, `
@{n='Threads';e={([string]($_ | Select -Expand Threads | Select -Expand id)).Split() -Join', ' }}, `
ThreadCount, Handle, Handles, HandleCount, `
SessionId, Owner, OwnerSID,`
NetworkConnectionsTypes, NetworkConnectionsTotalCount,`
NetworkConnectionsBound, NetworkConnectionsBoundCount,`
NetworkConnectionsClosed, NetworkConnectionsClosedCount,`
NetworkConnectionsCloseWait, NetworkConnectionsCloseWaitCount,`
NetworkConnectionsClosing, NetworkConnectionsClosingCount,`
NetworkConnectionsDeleteTCB, NetworkConnectionsDeleteTCBCount,`
NetworkConnectionsEstablished, NetworkConnectionsEstablishedCount,`
NetworkConnectionsFinWait1, NetworkConnectionsFinWait1Count,`
NetworkConnectionsFinWait2, NetworkConnectionsFinWait2Count,`
NetworkConnectionsLastAck, NetworkConnectionsLastAckCount,`
NetworkConnectionsListen, NetworkConnectionsListenCount,`
NetworkConnectionsSynReceived, NetworkConnectionsSynReceivedCount,`
NetworkConnectionsSynSent, NetworkConnectionsSynSentCount,`
NetworkConnectionsTimeWait, NetworkConnectionsTimeWaitCount,`
AlternateDataStream,AlternateDataStreamLength

#NetworkConnectionsTotal














# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUm3snFjD8qbNmHdwCqTEcjqDo
# iTigggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
# AQUFADAzMTEwLwYDVQQDDChQb1NoLUVhc3lXaW4gQnkgRGFuIEtvbW5pY2sgKGhp
# Z2gxMDFicm8pMB4XDTIxMTIxNDA1MDIwMFoXDTMxMTIxNDA1MTIwMFowMzExMC8G
# A1UEAwwoUG9TaC1FYXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALvIxUDFEVGB/G0FXPryoNlF
# dA65j5jPEFM2R4468rjlTVsNYUOR+XvhjmhpggSQa6SzvXtklUJIJ6LgVUpt/0C1
# zlr1pRwTvsd3svI7FHTbJahijICjCv8u+bFcAR2hH3oHFZTqvzWD1yG9FGCw2pq3
# h4ahxtYBd1+/n+jOtPUoMzcKIOXCUe4Cay+xP8k0/OLIVvKYRlMY4B9hvTW2CK7N
# fPnvFpNFeGgZKPRLESlaWncbtEBkexmnWuferJsRtjqC75uNYuTimLDSXvNps3dJ
# wkIvKS1NcxfTqQArX3Sg5qKX+ZR21uugKXLUyMqXmVo2VEyYJLAAAITEBDM8ngUC
# AwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0G
# A1UdDgQWBBSDJIlo6BcZ7KJAW5hoB/aaTLxFzTANBgkqhkiG9w0BAQUFAAOCAQEA
# ouCzal7zPn9vc/C9uq7IDNb1oNbWbVlGJELLQQYdfBE9NWmXi7RfYNd8mdCLt9kF
# CBP/ZjHKianHeZiYay1Tj+4H541iUN9bPZ/EaEIup8nTzPbJcmDbaAGaFt2PFG4U
# 3YwiiFgxFlyGzrp//sVnOdtEtiOsS7uK9NexZ3eEQfb/Cd9HRikeUG8ZR5VoQ/kH
# 2t2+tYoCP4HsyOkEeSQbnxlO9s1jlSNvqv4aygv0L6l7zufiKcuG7q4xv/5OvZ+d
# TcY0W3MVlrrNp1T2wxzl3Q6DgI+zuaaA1w4ZGHyxP8PLr6lMi6hIugI1BSYVfk8h
# 7KAaul5m+zUTDBUyNd91ojGCAegwggHkAgEBMEcwMzExMC8GA1UEAwwoUG9TaC1F
# YXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKQIQeugH5LewQKBKT6dP
# XhQ7sDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkq
# hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGC
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUM+BQr6N6tRbYF8jNqH2Dv9VNWDMwDQYJKoZI
# hvcNAQEBBQAEggEAekEml6g2cNotDCp8rohR2OinFu+tJW8EiTyG0e/daiEKUhr/
# ozeKBq16Kde89g9mY90kcdf9g0zHIf4KcYlCOexBWGfQAmLRjChkQ+8pcFXbZEQ2
# MgTPf9bAEUUPB6Hr4ZJ+z1CtmUDD8x9sth7jI5sFC9TS2+rFhlcRoPnFZ2lGnrDQ
# zZDcRgLxuuIflxcqpchKGeH40piHsld/ygkjxNSE3SHOygB3bT4IghocyqqdXZjN
# ECkhpqQ4ar36tYag4JCTgjEVAcJcpJtA9SBYEUKCnGdteLsP7fd/WRoJHMwSn7OP
# Ovt5SD6hnLTC0eaAuUi9s5CKa3s/qrWvKMZ3sw==
# SIG # End signature block
