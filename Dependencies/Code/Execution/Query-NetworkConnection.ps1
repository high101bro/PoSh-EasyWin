function Query-NetworkConnection {
    param(
        $IP             = $null,
        $RemotePort     = $null,
        $LocalPort      = $null,
        $ProcessName    = $null,
        $CommandLine    = $null,
        $ExecutablePath = $null,
        $regex          = $false
    )

    if ([bool]((Get-Command Get-NetTCPConnection).ParameterSets | Select-Object -ExpandProperty Parameters | Where-Object Name -match OwningProcess)) {
        $Processes           = Get-WmiObject -Class Win32_Process
        $Connections         = Get-NetTCPConnection
        $GetNetTCPConnection = $True
        foreach ($Conn in $Connections) {
            foreach ($Proc in $Processes) {
                if ($Conn.OwningProcess -eq $Proc.ProcessId) {
                    $Conn | Add-Member -MemberType NoteProperty -Name 'Duration'        -Value $((New-TimeSpan -Start ($Conn.CreationTime)).ToString())
                    $Conn | Add-Member -MemberType NoteProperty -Name 'ParentProcessId' -Value $Proc.ParentProcessId
                    $Conn | Add-Member -MemberType NoteProperty -Name 'ProcessName'     -Value $Proc.Name
                    $Conn | Add-Member -MemberType NoteProperty -Name 'ExecutablePath'  -Value $Proc.Path
                    $Conn | Add-Member -MemberType NoteProperty -Name 'CommandLine'     -Value $Proc.CommandLine
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
                    Protocol      =  $line[0]
                    LocalAddress  = ($line[1] -split ":")[0]
                    LocalPort     = ($line[1] -split ":")[1]
                    RemoteAddress = ($line[2] -split ":")[0]
                    RemotePort    = ($line[2] -split ":")[1]
                    State         =  $line[3]
                    ProcessId     =  $line[4]
                }
                $Connection = New-Object -TypeName PSObject -Property $Properties
                $Processes  = Get-WmiObject -query ('select * from win32_process where ProcessId="{0}"' -f $line[4])
                $Connection | Add-Member -MemberType NoteProperty PSComputerName  $env:COMPUTERNAME
                $Connection | Add-Member -MemberType NoteProperty ParentProcessId $Processes.ParentProcessId
                $Connection | Add-Member -MemberType NoteProperty ProcessName     $Processes.Caption
                $Connection | Add-Member -MemberType NoteProperty ExecutablePath  $Processes.ExecutablePath
                $Connection | Add-Member -MemberType NoteProperty CommandLine     $Processes.CommandLine
                $Connection | Add-Member -MemberType NoteProperty CreationTime    ([WMI] '').ConvertToDateTime($Processes.CreationDate)
                #implemented lower #$Connection | Add-Member -MemberType NoteProperty Duration        $((New-TimeSpan -Start $($this.CreationTime).ToString()))
                if ($Connection.ExecutablePath -ne $null -AND -NOT $NoHash) {
                    $MD5Hash = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
                    $Hash    = [System.BitConverter]::ToString($MD5Hash.ComputeHash([System.IO.File]::ReadAllBytes($Processes.ExecutablePath)))
                    $Connection | Add-Member -MemberType NoteProperty MD5Hash $($Hash -replace "-","")
                }
                else {
                    $Connection | Add-Member -MemberType NoteProperty MD5Hash $null
                }
                $Connection
            }
            $NetStat | Select-Object -Property PSComputerName,Protocol,LocalAddress,LocalPort,RemoteAddress,RemotePort,State,ProcessName,ProcessId,ParentProcessId,MD5Hash,ExecutablePath,CommandLine,CreationTime,Duration
        }
        $Connections = Get-Netstat
    }

    function CollectionNetworkData {
        $MD5Hash = $Hash = $null
        if ($GetNetTCPConnection) {
            $Processes      = Get-Process -Pid $conn.OwningProcess
        }
        $ConnectionsFound  += [PSCustomObject]@{
            LocalAddress    = $conn.LocalAddress
            LocalPort       = $conn.LocalPort
            RemoteAddress   = $conn.RemoteAddress
            RemotePort      = $conn.RemotePort
            State           = $conn.State
            CreationTime    = $conn.CreationTime
            Duration        = $((New-TimeSpan -Start ($Conn.CreationTime)).ToString())
            ParentProcessId = $conn.ParentProcessId
            ProcessID       = $(if($GetNetTCPConnection) {$conn.OwningProcess} else {$conn.ProcessID})
            ProcessName     = $conn.ProcessName
            CommandLine     = $conn.CommandLine
            MD5Hash         = $(if($GetNetTCPConnection) {
                $MD5Hash = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
                $Hash    = [System.BitConverter]::ToString($MD5Hash.ComputeHash([System.IO.File]::ReadAllBytes($Processes.path)))
                $($Hash -replace "-","")
            } else {$conn.MD5Hash} )
            ExecutablePath  = $(if($GetNetTCPConnection) { $Processes.Path } else {$conn.ExecutablePath} )
            Protocol        = $(if($GetNetTCPConnection) {'TCP'} else {$conn.Protocol} )
        }
        return $ConnectionsFound
    }

    $ConnectionsFound = @()

    foreach ($Conn in $Connections) {
        if ($regex -eq $true) {
            if     ($IP)             { foreach ($DestIP   in $IP)             { if (($Conn.RemoteAddress  -match $DestIP)   -and ($DestIP   -ne '')) { CollectionNetworkData } } }
            elseif ($RemotePort)     { foreach ($DestPort in $RemotePort)     { if (($Conn.RemotePort     -match $DestPort) -and ($DestPort -ne '')) { CollectionNetworkData } } }
            elseif ($LocalPort)      { foreach ($SrcPort  in $LocalPort)      { if (($Conn.LocalPort      -match $SrcPort)  -and ($SrcPort  -ne '')) { CollectionNetworkData } } }
            elseif ($ProcessName)    { foreach ($ProcName in $ProcessName)    { if (($conn.ProcessName    -match $ProcName) -and ($ProcName -ne '')) { CollectionNetworkData } } }
            elseif ($CommandLine)    { foreach ($Command  in $CommandLine)    { if (($conn.CommandLine    -match $Command)  -and ($Command  -ne '')) { CollectionNetworkData } } }
            elseif ($ExecutablePath) { foreach ($Path     in $ExecutablePath) { if (($conn.ExecutablePath -match $Path)     -and ($Path     -ne '')) { CollectionNetworkData } } }
        }
        elseif ($regex -eq $false) {
            if     ($IP)             { foreach ($DestIP   in $IP)             { if (($Conn.RemoteAddress  -eq $DestIP)   -and ($DestIP   -ne '')) { CollectionNetworkData } } }
            elseif ($RemotePort)     { foreach ($DestPort in $RemotePort)     { if (($Conn.RemotePort     -eq $DestPort) -and ($DestPort -ne '')) { CollectionNetworkData } } }
            elseif ($LocalPort)      { foreach ($SrcPort  in $LocalPort)      { if (($Conn.LocalPort      -eq $SrcPort)  -and ($SrcPort  -ne '')) { CollectionNetworkData } } }
            elseif ($ProcessName)    { foreach ($ProcName in $ProcessName)    { if (($conn.ProcessName    -eq $ProcName) -and ($ProcName -ne '')) { CollectionNetworkData } } }
            elseif ($CommandLine)    { foreach ($Command  in $CommandLine)    { if (($conn.CommandLine    -eq $Command)  -and ($Command  -ne '')) { CollectionNetworkData } } }
            elseif ($ExecutablePath) { foreach ($Path     in $ExecutablePath) { if (($conn.ExecutablePath -eq $Path)     -and ($Path     -ne '')) { CollectionNetworkData } } }
        }
    }
    return $ConnectionsFound
}

# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUy8/haF40xEEseTWOJjpuggJR
# /wCgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
# AQUFADAzMTEwLwYDVQQDDChQb1NoLUVhc3lXaW4gQnkgRGFuIEtvbW5pY2sgKGhp
# Z2gxMDFicm8pMB4XDTIxMTEyOTIzNDA0NFoXDTMxMTEyOTIzNTA0M1owMzExMC8G
# A1UEAwwoUG9TaC1FYXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANUnnNeIFC/eQ11BjDFsIHp1
# 2HkKgnRRV07Kqsl4/fibnbOclptJbeKBDQT3iG5csb31s9NippKfzZmXfi69gGE6
# v/L3X4Zb/10SJdFLstfT5oUD7UdiOcfcNDEiD+8OpZx4BWl5SNWuSv0wHnDSIyr1
# 2M0oqbq6WA2FqO3ETpdhkK22N3C7o+U2LeuYrGxWOi1evhIHlnRodVSYcakmXIYh
# pnrWeuuaQk+b5fcWEPClpscI5WiQh2aohWcjSlojsR+TiWG/6T5wKFxSJRf6+exu
# C0nhKbyoY88X3y/6qCBqP6VTK4C04tey5z4Ux4ibuTDDePqH5WpRFMo9Vie1nVkC
# AwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0G
# A1UdDgQWBBS2KLS0Frf3zyJTbQ4WsZXtnB9SFDANBgkqhkiG9w0BAQUFAAOCAQEA
# s/TfP54uPmv+yGI7wnusq3Y8qIgFpXhQ4K6MmnTUpZjbGc4K3DRJyFKjQf8MjtZP
# s7CxvS45qLVrYPqnWWV0T5NjtOdxoyBjAvR/Mhj+DdptojVMMp2tRNPSKArdyOv6
# +yHneg5PYhsYjfblzEtZ1pfhQXmUZo/rW2g6iCOlxsUDr4ZPEEVzpVUQPYzmEn6B
# 7IziXWuL31E90TlgKb/JtD1s1xbAjwW0s2s1E66jnPgBA2XmcfeAJVpp8fw+OFhz
# Q4lcUVUoaMZJ3y8MfS+2Y4ggsBLEcWOK4vGWlAvD5NB6QNvouND1ku3z94XmRO8v
# bqpyXrCbeVHascGVDU3UWTGCAegwggHkAgEBMEcwMzExMC8GA1UEAwwoUG9TaC1F
# YXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKQIQVnYuiASKXo9Gly5k
# J70InDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkq
# hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGC
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUJCYbMOjpdQ5OvMycSxh/YUMH99QwDQYJKoZI
# hvcNAQEBBQAEggEAHeMEfntMem+XMPnEJuzP4xFnYW/4Q095ngyivut0lHQOkkdd
# JDS2ea17Dz4hg6I+N1waIlfnHoj8+47yQpBCLGFKPousQB+wmqj7zkiJaxsj4kar
# sWagoOI/T1gEj/M3GYB5kTXn3OJxMld+9T0zqCHR377ssySRxdDDgC1uSs8g74W+
# pIcjhDXUiazuwSA0u9dadfLpwnKRY20eqWSY6NMiA/Vk4QEriqArv/SjbIYOrvrI
# I3d2+DkdP+d0ADCUfXzFXFMmnbU0Es+/RAAlpeh6dZDaE8iXaOYPHcVgmKGmOvbW
# M73XApPov3Dmk/ASwjhhqO3w+A3C9ZR7VDGc+A==
# SIG # End signature block
