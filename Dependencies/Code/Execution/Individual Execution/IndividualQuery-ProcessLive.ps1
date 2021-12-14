#batman
function IndividualQuery-ProcessLive {
    param(
        [switch]$ProcessLiveSearchNameCheckbox,
        [switch]$ProcessLiveSearchCommandlineCheckbox,
        [switch]$ProcessLiveSearchParentNameCheckbox,
        [switch]$ProcessLiveSearchOwnerSIDCheckbox,
        [switch]$ProcessLiveSearchServiceInfoCheckbox,
        [switch]$ProcessLiveSearchNetworkConnectionsCheckbox,
        [switch]$ProcessLiveSearchHashesSignerCertsCheckbox,
        [switch]$ProcessLiveSearchCompanyProductCheckbox
    )

    function MonitorJobScriptBlock {
        param(
            $CollectionName,
            $ProcessesLiveRegex,
            $ProcessLiveSearchName,
            $ProcessLiveSearchCommandline,
            $ProcessLiveSearchParentName,
            $ProcessLiveSearchOwnerSID,
            $ProcessLiveSearchServiceInfo,
            $ProcessLiveSearchNetworkConnections,
            $ProcessLiveSearchHashesSignerCerts,
            $ProcessLiveSearchCompanyProduct
        )

        foreach ($TargetComputer in $script:ComputerList) {
            Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $script:CollectedDataTimeStampDirectory `
                                    -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                                    -TargetComputer $TargetComputer
            Create-LogEntry -TargetComputer $TargetComputer  -LogFile $LogFile -Message $CollectionName


            $ProcessLiveScriptBlock = {
                param(
                    $CollectionName,
                    $ProcessesLiveRegex,
                    $ProcessLiveSearchName,
                    $ProcessLiveSearchCommandline,
                    $ProcessLiveSearchParentName,
                    $ProcessLiveSearchOwnerSID,
                    $ProcessLiveSearchServiceInfo,
                    $ProcessLiveSearchNetworkConnections,
                    $ProcessLiveSearchHashesSignerCerts,
                    $ProcessLiveSearchCompanyProduct
                )
            
                $ErrorActionPreference = 'SilentlyContinue'
                $CollectionTime = Get-Date
                $Services  += Get-WmiObject Win32_Service
                $Processes = Get-WmiObject Win32_Process
                
                $ParameterSets = (Get-Command Get-NetTCPConnection).ParameterSets | Select-Object -ExpandProperty Parameters
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
                    $CommandLine           = $Process.CommandLine
                    $CreationDate         = [Management.ManagementDateTimeConverter]::ToDateTime($Process.CreationDate)
                
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
                    | Add-Member NoteProperty 'CommandLine'            $CommandLine       -PassThru -Force `
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

                $Processes = $Processes | Foreach-Object { Write-ProcessTree -Process $PSItem} | Select-Object -Property Name, ProcessID, ParentProcessName, ParentProcessID, ServiceInfo,`
                    StartTime, @{Name='Duration';Expression={New-TimeSpan -Start $_.StartTime -End $CollectionTime}}, CPU, TotalProcessorTime, `
                    NetworkConnections, NetworkConnectionCount, CommandLine, Path, `
                    WorkingSet, @{Name='MemoryUsage';Expression={
                        if     ($_.WorkingSet -gt 1GB) {"$([Math]::Round($_.WorkingSet/1GB, 2)) GB"}
                        elseif ($_.WorkingSet -gt 1MB) {"$([Math]::Round($_.WorkingSet/1MB, 2)) MB"}
                        elseif ($_.WorkingSet -gt 1KB) {"$([Math]::Round($_.WorkingSet/1KB, 2)) KB"}
                        else                           {"$([Math]::Round($_.WorkingSet,     2)) Bytes"}
                    }}, `
                    MD5Hash, SignerCertificate, StatusMessage, SignerCompany, Company, Product, ProductVersion, Description, `
                    Modules, ModuleCount, `
                    @{n='Threads';e={([string]($_ | Select-Object -Expand Threads | Select-Object -Expand id)).Split() -Join',' }}, `
                    ThreadCount, Handle, Handles, HandleCount, `
                    Owner, OwnerSID


                if ($ProcessLiveSearchName) {
                    foreach ($p in $ProcessLiveSearchName) {
                        if ($ProcessesLiveRegex) { $Processes | Where-Object {$_.Name -match $p } }
                        else                     { $Processes | Where-Object {$_.Name -eq $p } }
                    }
                }
                if ($ProcessLiveSearchCommandline) {
                    foreach ($p in $ProcessLiveSearchCommandline) {
                        if ($ProcessesLiveRegex) { $Processes | Where-Object {$_.CommandLine -match $p } }
                        else                     { $Processes | Where-Object {$_.CommandLine -eq $p } }
                    }
                }
                if ($ProcessLiveSearchParentName) {
                    foreach ($p in $ProcessLiveSearchParentName) {
                        if ($ProcessesLiveRegex) { $Processes | Where-Object {$_.ParentProcessName -match $p} }
                        else                     { $Processes | Where-Object {$_.ParentProcessName -eq $p } }
                    }
                }
                if ($ProcessLiveSearchOwnerSID) {
                    foreach ($p in $ProcessLiveSearchOwnerSID) {
                        if ($ProcessesLiveRegex) { $Processes | Where-Object {$_.Owner -match $p -or $_.OwnerSID -match $p} }
                        else                     { $Processes | Where-Object {$_.Owner -eq $p -or $_.OwnerSID -eq $p} }
                    }
                }
                if ($ProcessLiveSearchServiceInfo) {
                    foreach ($p in $ProcessLiveSearchServiceInfo) {
                        if ($ProcessesLiveRegex) { $Processes | Where-Object {$_.ServiceInfo -match $p} }
                        else                     { $Processes | Where-Object {$_.ServiceInfo -eq $p} }
                    }
                }
                if ($ProcessLiveSearchNetworkConnections) {
                    foreach ($p in $ProcessLiveSearchNetworkConnections) {
                        if ($ProcessesLiveRegex) { $Processes | Where-Object {$_.NetworkConnections -match $p } }
                        else                     { $Processes | Where-Object {$_.NetworkConnections -eq $p } }
                    }
                }
                if ($ProcessLiveSearchHashesSignerCerts) {
                    foreach ($p in $ProcessLiveSearchHashesSignerCerts) {
                        if ($ProcessesLiveRegex) { $Processes | Where-Object {$_.MD5Hash -match $p -or $_.SignerCertificate -match $p} }
                        else                     { $Processes | Where-Object {$_.MD5Hash -eq $p -or $_.SignerCertificate -eq $p} }
                    }
                }
                if ($ProcessLiveSearchCompanyProduct) {
                    foreach ($p in $ProcessLiveSearchCompanyProduct) {
                        if ($ProcessesLiveRegex) { $Processes | Where-Object {$_.Company -match $p -or $_.Product -match $p -or $_.SignerCompany -match $p} }
                        else                     { $Processes | Where-Object {$_.Company -eq $p -or $_.Product -eq $p -or $_.SignerCompany -eq $p} }
                    }
                }                
            }

            $InvokeCommandSplat = @{
                ScriptBlock  = $ProcessLiveScriptBlock
                ArgumentList = @(
                    $CollectionName,
                    $ProcessesLiveRegex,
                    $ProcessLiveSearchName,
                    $ProcessLiveSearchCommandline,
                    $ProcessLiveSearchParentName,
                    $ProcessLiveSearchOwnerSID,
                    $ProcessLiveSearchServiceInfo,
                    $ProcessLiveSearchNetworkConnections,
                    $ProcessLiveSearchHashesSignerCerts,
                    $ProcessLiveSearchCompanyProduct
                )
                ComputerName = $TargetComputer
                AsJob        = $true
                JobName      = "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"
            }
            
            if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { Create-NewCredentials }
                $InvokeCommandSplat += @{ 
                    Credential = $script:Credential
                }
            }
            Invoke-Command @InvokeCommandSplat | Select-Object PSComputerName, *
        }
    }


    if     ($ProcessLiveSearchNameCheckbox)               {$CollectionName = "Process (Live) Name"}
    elseif ($ProcessLiveSearchCommandlineCheckbox)        {$CollectionName = "Process (Live) Command Line"}
    elseif ($ProcessLiveSearchParentNameCheckbox)         {$CollectionName = "Process (Live) Parent Name"}
    elseif ($ProcessLiveSearchOwnerSIDCheckbox)           {$CollectionName = "Process (Live) Owner, SID"}
    elseif ($ProcessLiveSearchServiceInfoCheckbox)        {$CollectionName = "Process (Live) Service Info"}
    elseif ($ProcessLiveSearchNetworkConnectionsCheckbox) {$CollectionName = "Process (Live) Network Connections"}
    elseif ($ProcessLiveSearchHashesSignerCertsCheckbox)  {$CollectionName = "Process (Live) Hashes, Signer Cert"}
    elseif ($ProcessLiveSearchCompanyProductCheckbox)     {$CollectionName = "Process (Live) Company, Product"}
        

    $EndpointString = ''
    foreach ($item in $script:ComputerList) {$EndpointString += "$item`n"}

    $InputValues = @"
===========================================================================
Collection Name:
===========================================================================
$CollectionName

===========================================================================
Execution Time:
===========================================================================
$ExecutionStartTime

===========================================================================
Credentials:
===========================================================================
$($script:Credential.UserName)

===========================================================================
Endpoints:
===========================================================================
$($EndpointString.trim())

===========================================================================
Regular Expression:
===========================================================================
$($ProcessesLiveRegexCheckbox.checked)

===========================================================================
Search Terms:
===========================================================================

"@


    if   ($ProcessesLiveRegexCheckbox.checked) {$ProcessesLiveRegex = $True}
    else {$ProcessesLiveRegex = $False}


    if ($ProcessLiveSearchNameCheckbox) {
        $ProcessLiveSearchName = ($ProcessLiveSearchNameRichTextbox.Text).split("`r`n")
        $InputValues += $($ProcessLiveSearchName -join "`n")
    }
    else {$ProcessLiveSearchName = $null}


    if ($ProcessLiveSearchCommandlineCheckbox) {
        $ProcessLiveSearchCommandline = $ProcessLiveSearchCommandlineRichTextbox.Lines
        $InputValues += $($ProcessLiveSearchCommandline -join "`n")
    }
    else {$ProcessLiveSearchCommandline = $null}


    if ($ProcessLiveSearchParentNameCheckbox) {
        $ProcessLiveSearchParentName = ($ProcessLiveSearchParentNameRichTextbox.Text).split("`r`n")
        $InputValues += $($ProcessLiveSearchParentName -join "`n")
    }
    else {$ProcessLiveSearchParentName = $null}


    if ($ProcessLiveSearchOwnerSIDCheckbox) {
        $ProcessLiveSearchOwnerSID = ($ProcessLiveSearchOwnerSIDRichTextbox.Text).split("`r`n")
        $InputValues += $($ProcessLiveSearchOwnerSID -join "`n")
    }
    else {$ProcessLiveSearchOwnerSID = $null}


    if ($ProcessLiveSearchServiceInfoCheckbox) {
        $ProcessLiveSearchServiceInfo = ($ProcessLiveSearchServiceInfoRichTextbox.Text).split("`r`n")
        $InputValues += $($ProcessLiveSearchServiceInfo -join "`n")
    }
    else {$ProcessLiveSearchServiceInfo = $null}


    if ($ProcessLiveSearchNetworkConnectionsCheckbox) {
        $ProcessLiveSearchNetworkConnections = ($ProcessLiveSearchNetworkConnectionsRichTextbox.Text).split("`r`n")
        $InputValues += $($ProcessLiveSearchNetworkConnections -join "`n")
    }
    else {$ProcessLiveSearchNetworkConnections = $null}


    if ($ProcessLiveSearchHashesSignerCertsCheckbox) {
        $ProcessLiveSearchHashesSignerCerts = ($ProcessLiveSearchHashesSignerCertsRichTextbox.Text).split("`r`n")
        $InputValues += $($ProcessLiveSearchHashesSignerCerts -join "`n")
    }
    else {$ProcessLiveSearchHashesSignerCerts = $null}


    if ($ProcessLiveSearchCompanyProductCheckbox) {
        $ProcessLiveSearchCompanyProduct = ($ProcessLiveSearchCompanyProductRichTextbox.Text).split("`r`n")
        $InputValues += $($ProcessLiveSearchCompanyProduct -join "`n")
    }
    else {$ProcessLiveSearchCompanyProduct = $null}


    $ExecutionStartTime = Get-Date
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Query: $CollectionName")
    $ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")


    $InvokeCommandSplat = @{
        ScriptBlock  = ${function:MonitorJobScriptBlock}
        ArgumentList = @($CollectionName,$ProcessesLiveRegex,$ProcessLiveSearchName,$ProcessLiveSearchCommandline,$ProcessLiveSearchParentName,$ProcessLiveSearchOwnerSID,$ProcessLiveSearchServiceInfo,$ProcessLiveSearchNetworkConnections,$ProcessLiveSearchHashesSignerCerts,$ProcessLiveSearchCompanyProduct)
    }
    Invoke-Command @InvokeCommandSplat
    Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:MonitorJobScriptBlock} -ArgumentList @($CollectionName,$ProcessesLiveRegex,$ProcessLiveSearchName,$ProcessLiveSearchCommandline,$ProcessLiveSearchParentName,$ProcessLiveSearchOwnerSID,$ProcessLiveSearchServiceInfo,$ProcessLiveSearchNetworkConnections,$ProcessLiveSearchHashesSignerCerts,$ProcessLiveSearchCompanyProduct) -InputValues $InputValues


    $CollectionCommandEndTime  = Get-Date
    $CollectionCommandDiffTime = New-TimeSpan -Start $ExecutionStartTime -End $CollectionCommandEndTime
    $ResultsListBox.Items.RemoveAt(0)
    $ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $CollectionName")

    
    Update-EndpointNotes
}


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUvtRQpYxwc+i6ltiGUnD/h2Gm
# 8WigggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUPez95mX10hCVS9aco46B7DhCuVYwDQYJKoZI
# hvcNAQEBBQAEggEAdpDbWjqr6oQ7PMuZn+kscKhbf//sApXMGrOgwjFjxkjc1Vo1
# /sz03ht6gARlslhQ47U/f3nPsTTDAu9OSgAA8MmYOIHzkoUy3ny8onyPGEgpTyX6
# 8e2Sh5CztVZX6f/VNEw/RitHA68sTntpGN0qyU/HuX7DXoT1d3igPho9NG970Skx
# r2YUInsa5E3ryCIgRy4E5pB1noJFDDzIGsj/Pg7rDB8EGO/JhU0avUOmWPiULWhW
# KivEOFpTZP/6lzRwCeFEfdvh6vn5ETcSGLZu52XK70T+uKcZlbIbFt76ECHcaLTx
# uCbsLZAgrq1xSukjMRzu3yqjWZwc/sNKzi9FEw==
# SIG # End signature block
