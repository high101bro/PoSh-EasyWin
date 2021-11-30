if ([bool]((Get-Command Get-NetTCPConnection).ParameterSets | Select-Object -ExpandProperty Parameters | Where-Object Name -match OwningProcess)) {
    $Processes           = Get-WmiObject -Class Win32_Process
    $Connections         = Get-NetTCPConnection

    foreach ($Conn in $Connections) {
        foreach ($Proc in $Processes) {
            if ($Conn.OwningProcess -eq $Proc.ProcessId) {
                $Conn | Add-Member -MemberType NoteProperty 'PSComputerName'  $env:COMPUTERNAME -Force
                $Conn | Add-Member -MemberType NoteProperty 'Protocol'        'TCP'
                $Conn | Add-Member -MemberType NoteProperty 'Duration'        ((New-TimeSpan -Start ($Conn.CreationTime)).ToString())
                $Conn | Add-Member -MemberType NoteProperty 'ProcessId'       $Proc.ProcessId
                $Conn | Add-Member -MemberType NoteProperty 'ParentProcessId' $Proc.ParentProcessId
                $Conn | Add-Member -MemberType NoteProperty 'ProcessName'     $Proc.Name
                $Conn | Add-Member -MemberType NoteProperty 'CommandLine'     $Proc.CommandLine
                $Conn | Add-Member -MemberType NoteProperty 'ExecutablePath'  $proc.ExecutablePath
                $Conn | Add-Member -MemberType NoteProperty 'ScriptNote'      'Get-NetTCPConnection Enhanced'

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
            $Connection | Add-Member -MemberType NoteProperty 'PSComputerName'  $env:COMPUTERNAME -Force
            $Connection | Add-Member -MemberType NoteProperty 'ParentProcessId' $proc.ParentProcessId
            $Connection | Add-Member -MemberType NoteProperty 'ProcessName'     $proc.Caption
            $Connection | Add-Member -MemberType NoteProperty 'ExecutablePath'  $proc.ExecutablePath
            $Connection | Add-Member -MemberType NoteProperty 'CommandLine'     $proc.CommandLine
            $Connection | Add-Member -MemberType NoteProperty 'CreationTime'    ([WMI] '').ConvertToDateTime($proc.CreationDate)
            $Connection | Add-Member -MemberType NoteProperty 'Duration'        ((New-TimeSpan -Start ([WMI] '').ConvertToDateTime($proc.CreationDate)).ToString())
            $Connection | Add-Member -MemberType NoteProperty 'ScriptNote'      'NetStat.exe Enhanced'

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
$Connections | Select-Object -Property PSComputerName, Protocol,LocalAddress,LocalPort,RemoteAddress,RemotePort,State,ProcessName,ProcessId,ParentProcessId,CreationTime,Duration,CommandLine,ExecutablePath,MD5Hash,OwningProcess,ScriptNote -ErrorAction SilentlyContinue


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUjuhWtHDvt3VLxcJNTQu04Gg+
# 7dugggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUwyozCIiuUOC1jHWNCl5Hi85WblkwDQYJKoZI
# hvcNAQEBBQAEggEAOrJ2giIzJkuLkCWHdE4zx9Uaey+adp71e8qNzTINtlpIGdwC
# DGmcoAaCyDPomcoGjqP2fNsn6MJ05MRgXSBnzSBe4MoZX0OMj20ngnY1xHCJ5GmI
# 7tA9f8oPq6bU08k19x+et+6nhBtT+KQ05lSBLw06T6jfPRThiJgqRsxfljAAKoOX
# fI4VR550crnkUSH3a4SEVnZE/fgyZbl+t9/6uhXb5RZx0gLqMM57ptckdMysfvpv
# swOvAIQEJs8yRMzl6y2Gy4tngzIAGk5qspF9CnJk2uK0swYhY1rmCUl1jD0I+0A9
# /unjCkp3VDFVoaRbGeXqOfDp+n8hyzZb7bSP3w==
# SIG # End signature block
