$NetworkConnectionsScriptBlock = {
    if ([bool]((Get-Command Get-NetTCPConnection).ParameterSets | Select-Object -ExpandProperty Parameters | Where-Object Name -match OwningProcess)) {
        $Processes           = Get-WmiObject -Class Win32_Process
        $Connections         = Get-NetTCPConnection

        foreach ($Conn in $Connections) {
            foreach ($Proc in $Processes) {
                if ($Conn.OwningProcess -eq $Proc.ProcessId) {
                    $Conn | Add-Member -MemberType NoteProperty 'PSComputerName'   $env:COMPUTERNAME -Force
                    $Conn | Add-Member -MemberType NoteProperty 'Protocol'         'TCP'
                    $Conn | Add-Member -MemberType NoteProperty 'Duration'         ((New-TimeSpan -Start ($Conn.CreationTime)).ToString())
                    $Conn | Add-Member -MemberType NoteProperty 'ProcessId'        $Proc.ProcessId
                    $Conn | Add-Member -MemberType NoteProperty 'ParentProcessId'  $Proc.ParentProcessId
                    $Conn | Add-Member -MemberType NoteProperty 'ProcessName'      $Proc.Name
                    $Conn | Add-Member -MemberType NoteProperty 'CommandLine'      $Proc.CommandLine
                    $Conn | Add-Member -MemberType NoteProperty 'ExecutablePath'   $proc.ExecutablePath
                    $Conn | Add-Member -MemberType NoteProperty 'CollectionMethod' 'Get-NetTCPConnection Enhanced'

                    if ($Conn.ExecutablePath -ne $null) {
                        $MD5Hash = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
                        $Hash    = [System.BitConverter]::ToString($MD5Hash.ComputeHash([System.IO.File]::ReadAllBytes($proc.ExecutablePath)))
                        $Conn | Add-Member -MemberType NoteProperty MD5Hash $($Hash -replace "-","")
                    }
                    else {
                        $Conn | Add-Member -MemberType NoteProperty MD5Hash $null
                    }
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
                    Protocol      = $line[0]
                    LocalAddress  = ($line[1] -split ":")[0]
                    LocalPort     = ($line[1] -split ":")[1]
                    RemoteAddress = ($line[2] -split ":")[0]
                    RemotePort    = ($line[2] -split ":")[1]
                    State         = $line[3]
                    ProcessId     = $line[4]
                    OwningProcess = $line[4]
                }
                $Connection = New-Object -TypeName PSObject -Property $Properties
                $proc       = Get-WmiObject -query ('select * from win32_process where ProcessId="{0}"' -f $line[4])
                $Connection | Add-Member -MemberType NoteProperty 'PSComputerName'   $env:COMPUTERNAME -Force
                $Connection | Add-Member -MemberType NoteProperty 'ParentProcessId'  $proc.ParentProcessId
                $Connection | Add-Member -MemberType NoteProperty 'ProcessName'      $proc.Caption
                $Connection | Add-Member -MemberType NoteProperty 'ExecutablePath'   $proc.ExecutablePath
                $Connection | Add-Member -MemberType NoteProperty 'CommandLine'      $proc.CommandLine
                $Connection | Add-Member -MemberType NoteProperty 'CreationTime'     ([WMI] '').ConvertToDateTime($proc.CreationDate)
                $Connection | Add-Member -MemberType NoteProperty 'Duration'         ((New-TimeSpan -Start ([WMI] '').ConvertToDateTime($proc.CreationDate)).ToString())
                $Connection | Add-Member -MemberType NoteProperty 'CollectionMethod' 'NetStat.exe Enhanced'

                if ($Connection.ExecutablePath -ne $null) {
                    $MD5Hash = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
                    $Hash    = [System.BitConverter]::ToString($MD5Hash.ComputeHash([System.IO.File]::ReadAllBytes($proc.ExecutablePath)))
                    $Connection | Add-Member -MemberType NoteProperty MD5Hash $($Hash -replace "-","")
                }
                else {
                    $Connection | Add-Member -MemberType NoteProperty MD5Hash $null
                }
                $Connection
            }
            $NetStat
        }
        $Connections = Get-Netstat
    }

    $Connections | Select-Object -Property PSComputerName, Protocol, LocalAddress, LocalPort, RemoteAddress, RemotePort, State,
    ProcessName, ProcessId, ParentProcessId, CreationTime, Duration, CommandLine, ExecutablePath, MD5Hash, OwningProcess, 
    @{n='LocalIPPort'; e={"$($_.LocalAddress):$($_.LocalPort)"}},
    @{n='RemoteIPPort';e={"$($_.RemoteAddress):$($_.RemotePort)"}},
    CollectionMethod -ErrorAction SilentlyContinue
}


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUH/6ENNtkoEPpChO2WbXG3V45
# BdegggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUdY1I6gI0T+VSDNH+zjsd8+yCbf4wDQYJKoZI
# hvcNAQEBBQAEggEAE9WGtaZDv2hwLLyKrv0S2n85siyJF7QE+RJVuGGlxInqiw13
# N9J9utI+62NZcLAQcxWT4lynTbYabFtzLQNptGT+RkpYgY9fopE3RbT5AzXzAy8H
# IQrFnRuJWabuJrze+oNDsvwCLAhjdyu4eJ2fRN0c4Q9WwZsAaCmx1uftOmTTxgTx
# l0Uxn6/S+7pDlapSzgH1DQ/RWlQYPm1yyEKJeOxNX7a8+BPfbArrZWJMxSfge1R4
# AsLMLxbPzpx9G7MqN34bYl/Q6/56McOOU6rIJUsr+UQ4lzVVTcBLza1r8JIAfAR6
# eU8actQu2d5BaWhAdyIhlDCtCV64eqtVmAA6Eg==
# SIG # End signature block
