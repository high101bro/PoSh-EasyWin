$ProcessesScriptblock = {
    $ErrorActionPreference = 'SilentlyContinue'
    $CollectionTime = Get-Date
    $Processes      = Get-WmiObject Win32_Process
    $Services       = Get-WmiObject Win32_Service

    # Get's Endpoint Network Connections associated with Process IDs
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
            $Connection | Add-Member -MemberType NoteProperty 'OwningProcess'   $proc.ProcessId
            $Connection | Add-Member -MemberType NoteProperty 'ParentProcessId' $proc.ParentProcessId
            $Connection | Add-Member -MemberType NoteProperty 'Name'            $proc.Caption
            $Connection | Add-Member -MemberType NoteProperty 'ExecutablePath'  $proc.ExecutablePath
            $Connection | Add-Member -MemberType NoteProperty 'CommandLine'     $proc.CommandLine
            $Connection | Add-Member -MemberType NoteProperty 'PSComputerName'  $env:COMPUTERNAME
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

    # Create Hashtable of all network processes And their PIDs
    $ProcessNamePid = @{}
    foreach ( $proc in $Processes ) {
        if ( $proc.ProcessID -notin $ProcessNamePid.keys ) {
            $ProcessNamePid[$proc.ProcessID] += $proc.ProcessName
        }
    }

    # Create Hashtable of all network processes And their PIDs
    $NetConnections = @{}
    foreach ( $Connection in $NetworkConnections ) {
        $connStr = "[$($Connection.State)] " + "$($Connection.LocalAddress)" + ";" + "$($Connection.LocalPort)" + " <--> " + "$($Connection.RemoteAddress)" + ";" + "$($Connection.RemotePort)" + " [$($Connection.CreationTime)] || "
        if ( $Connection.OwningProcess -in $NetConnections.keys ) {
            if ( $connStr -notin $NetConnections[$Connection.OwningProcess] ) { $NetConnections[$Connection.OwningProcess] += $connStr }
        }
        else { $NetConnections[$Connection.OwningProcess] = $connStr }
    }

    # Create HashTable of services associated to PIDs
    $ServicePIDs = @{}
    foreach ( $svc in $Services ) {
        if ( $svc.ProcessID -notin $ServicePIDs.keys ) {
            $ServicePIDs[$svc.ProcessID] += "$($svc.name) [$($svc.Startmode) Start By $($svc.startname)]"
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
    $TrackPaths                     = @()
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

    function Get-ProcessTree {
        [CmdletBinding()]
        param(
            [string]$ComputerName = 'localhost', 
            $Processes,
            [int]$IndentSize = 5
        )
        $indentSize   = [Math]::Max(1, [Math]::Min(12, $indentSize))
        #$computerName = ($computerName, ".")[[String]::IsNullOrEmpty($computerName)]
        $PIDs         = $Processes | Select-Object -ExpandProperty ProcessId
        $Parents      = $Processes | Select-Object -ExpandProperty ParentProcessId -Unique
        $LiveParents  = $Parents   | Where-Object { $PIDs -contains $_ }
        $DeadParents  = Compare-Object -ReferenceObject $Parents -DifferenceObject $LiveParents `
                        | Select-Object -ExpandProperty InputObject
        $ProcessByParent = $Processes | Group-Object -AsHashTable ParentProcessId

        function Write-ProcessTree($Process, [int]$level = 0) {
            $EnrichedProcess       = Get-Process -Id $Process.ProcessId
            $indent                = New-Object String(' ', ($level * $indentSize))

            $ProcessID             = $Process.ProcessID
            $ParentProcessID       = $Process.ParentProcessID
            $ParentProcessName     = $ProcessNamePid[$Process.ParentProcessID]
            $CreationDate          = [Management.ManagementDateTimeConverter]::ToDateTime($Process.CreationDate)

            $ServiceInfo           = $ServicePIDs[$Process.ProcessId]

            $NetConns              = $($NetConnections[$Process.ProcessId]).TrimEnd(" || ")
            $NetConnsCount         = if ($NetConns) {$($NetConns -split " || ").Count} else {[int]0}

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
            | Add-Member NoteProperty 'Level'                  $level                    -PassThru -Force `
            | Add-Member NoteProperty 'ProcessID'              $ProcessID                -PassThru -Force `
            | Add-Member NoteProperty 'ProcessName'            $_.Name                   -PassThru -Force `
            | Add-Member NoteProperty 'ParentProcessID'        $ParentProcessID          -PassThru -Force `
            | Add-Member NoteProperty 'ParentProcessName'      $ParentProcessName        -PassThru -Force `
            | Add-Member NoteProperty 'CreationDate'           $CreationDate             -PassThru -Force `
            | Add-Member NoteProperty 'ServiceInfo'            $ServiceInfo              -PassThru -Force `
            | Add-Member NoteProperty 'NetworkConnections'     $NetConns                 -PassThru -Force `
            | Add-Member NoteProperty 'NetworkConnectionCount' $NetConnsCount            -PassThru -Force `
            | Add-Member NoteProperty 'StatusMessage'          $StatusMessage            -PassThru -Force `
            | Add-Member NoteProperty 'SignerCertificate'      $SignerCertificate        -PassThru -Force `
            | Add-Member NoteProperty 'SignerCompany'          $SignerCompany            -PassThru -Force `
            | Add-Member NoteProperty 'MD5Hash'                $MD5Hash                  -PassThru -Force `
            | Add-Member NoteProperty 'Modules'                $Modules                  -PassThru -Force `
            | Add-Member NoteProperty 'ModuleCount'            $ModuleCount              -PassThru -Force `
            | Add-Member NoteProperty 'ThreadCount'            $ThreadCount              -PassThru -Force `
            | Add-Member NoteProperty 'Owner'                  $Owner                    -PassThru -Force `
            | Add-Member NoteProperty 'OwnerSID'               $OwnerSID                 -PassThru -Force `
            | Add-Member NoteProperty 'Duration'               $(New-TimeSpan -Start $_.StartTime -End $CollectionTime) -PassThru -Force `
            | Add-Member NoteProperty 'MemoryUsage'            $(if    ($_.WorkingSet -gt 1GB) {"$([Math]::Round($_.WorkingSet/1GB, 2)) GB"}
                                                                elseif ($_.WorkingSet -gt 1MB) {"$([Math]::Round($_.WorkingSet/1MB, 2)) MB"}
                                                                elseif ($_.WorkingSet -gt 1KB) {"$([Math]::Round($_.WorkingSet/1KB, 2)) KB"}
                                                                else                           {"$([Math]::Round($_.WorkingSet,     2)) Bytes"} ) -PassThru -Force

            $ProcessByParent.Item($ProcessID) `
            | Where-Object   { $_ } `
            | ForEach-Object { Write-ProcessTree $_ ($level + 1) }
        }
        $Processes `
        | Where-Object   { $_.ProcessId -ne 0 -and ($_.ProcessId -eq $_.ParentProcessId -or $DeadParents -contains $_.ParentProcessId) } `
        | ForEach-Object { Write-ProcessTree $_ }
    }
    Get-ProcessTree -Processes $Processes | Select-Object `
    ProcessID, ProcessName, Level, ParentProcessName, ParentProcessID, ServiceInfo,
    @{n='PSComputerName';e={$env:Computername}},
    StartTime, Duration, CPU, TotalProcessorTime,
    NetworkConnections, NetworkConnectionCount, CommandLine, Path,
    WorkingSet, MemoryUsage,
    MD5Hash, SignerCertificate, StatusMessage, SignerCompany, Company, Product, ProductVersion, Description,
    Modules, ModuleCount, Threads, ThreadCount, Handle, Handles, HandleCount,
    Owner, OwnerSID,
    @{n='CollectionType';e={'ProcessData'}}

# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUFl94F4gS/PMjSdXl9W0eC3jj
# Tl+gggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU4FA2Tk6URqj48x2yuPTy9gNmLDcwDQYJKoZI
# hvcNAQEBBQAEggEAhv/C2eF8lV0j+xh6xuOaNjsFdZTME0Ba8ce98PjV0RlVPUco
# gUu4czHys0tZ5OeUnOMwbSlr6k9bAYqB2QITuw98ywMCpgeI6AevQI+4uo/dKh+/
# qTWJpi2HTuWTSSNIFBA8U+3wXEaU2KR40cUkTlOfFOgeKswVOjOsYUQiUjDseVfk
# y0bxpRxd/hmINolKSK8W0pvaD0DwkMGNYJT+aqxPRVWoIz1wcZ1hnKCrbSHD0vfi
# z6lR7nqmMRnFaARXc1lyihCR+kLQbSTJq+zLfVch3RrbTCnaCCHDcLN8Lcsiw5Tu
# ZC4hJBLyw0Wdm5G/P2gpsxmVSj3XjvwuO6nz6A==
# SIG # End signature block
