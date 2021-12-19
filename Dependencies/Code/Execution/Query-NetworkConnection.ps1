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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU5LTiUQkCOWT0+Zk7aCRwR5N/
# J72gggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUwhQygZK4kD2aGSy+Mn9xsCOnAu4wDQYJKoZI
# hvcNAQEBBQAEggEAX3aM6xgJUGRNfifG3xjgpTHCmAWEK81O9hzD8u4QaKQeGGGE
# Ar09K3slVKtsU57YXOtVCU/R0JGbJnaa4b12XOUl8dYuSjjIngw0zoCdYi1xFVo1
# g0caKJfp4NSOk+SsNho5ALwDhyfmjWDEsfKqc4VKbRaTtZYRM3VKsfMkKTQ1T/zG
# OExCM0BUJxrHlFvvq0H3SD9bshmeeRh2dE2RUr8yvwN/8nYFygL5Sb3mwzsZq2si
# aa6N1JADMDX88tAsTrH57T/pIiAWij/YipFvHXaEqM14IMV48qQYIPNdO/ypazdl
# ks99eeFq3uSvZLXstWfcilCORkPBiW6XMr7ndA==
# SIG # End signature block
