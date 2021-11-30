function Query-ProcessInfoWithinSysmon {
    param(
        $DestinationIP   = $null,
        $DestinationPort = $null,
        $SourceIP        = $null,
        $SourcePort      = $null,
        $Account         = $null,
        $ExecutablePath  = $null,
        $regex           = $false
    )

    $SysmonNetworkEventLogs = Get-WinEvent -FilterHashtable @{
        LogName = 'Microsoft-Windows-Sysmon/Operational'
        Id      = 3
    }

    $SysmonNetworkEventLogsFormatted = @()
    Foreach ($event in ($SysmonNetworkEventLogs | Select-Object -Expand Message)) {
        $SysmonNetworkEventLogsFormatted += [PSCustomObject]@{
            'Event'               = ($event -split "`r`n")[0].TrimEnd(':')
            'RuleName'            = (($event -split "`r`n")[1] -split ": ")[1]
            'UtcTime'             = [datetime](($event -split "`r`n")[2] -split ": ")[1]
            'ProcessGuid'         = (($event -split "`r`n")[3] -split ": ")[1].Replace('{','').Replace('}','')
            'ProcessId'           = (($event -split "`r`n")[4] -split ": ")[1]
            'Image'               = (($event -split "`r`n")[5] -split ": ")[1]
            'User'                = (($event -split "`r`n")[6] -split ": ")[1]
            'Protocol'            = (($event -split "`r`n")[7] -split ": ")[1]
            'Initiated'           = (($event -split "`r`n")[8] -split ": ")[1]
            'SourceIsIpv6'        = (($event -split "`r`n")[9] -split ": ")[1]
            'SourceIp'            = (($event -split "`r`n")[10] -split ": ")[1]
            'SourceHostname'      = (($event -split "`r`n")[11] -split ": ")[1]
            'SourcePort'          = (($event -split "`r`n")[12] -split ": ")[1]
            'SourcePortName'      = (($event -split "`r`n")[13] -split ": ")[1]
            'DestinationIsIpv6'   = (($event -split "`r`n")[14] -split ": ")[1]
            'DestinationIp'       = (($event -split "`r`n")[15] -split ": ")[1]
            'DestinationHostname' = (($event -split "`r`n")[16] -split ": ")[1]
            'DestinationPort'     = (($event -split "`r`n")[17] -split ": ")[1]
            'DestinationPortName' = (($event -split "`r`n")[18] -split ": ")[1]
        }
    }

    $SysmonNetworkConnectionEventFound = @()

    foreach ($SysmonNetEvent in $SysmonNetworkEventLogsFormatted) {
        if ($regex -eq $true) {
            if     ($DestinationIP)   { foreach ($DestIP   in $DestinationIP)   { if (($SysmonNetEvent.DestinationIp       -match $DestIP    -or
                                                                                       $SysmonNetEvent.DestinationHostname -match $DestIP)   -and ($DestIP   -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
            elseif ($DestinationPort) { foreach ($DestPort in $DestinationPort) { if (($SysmonNetEvent.DestinationPort     -match $DestPort  -or
                                                                                       $SysmonNetEvent.DestinationPortName -match $DestPort) -and ($DestPort -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
            elseif ($SourceIP)        { foreach ($SrcPort  in $SourceIP)        { if (($SysmonNetEvent.SourceIP            -match $SrcPort   -or
                                                                                       $SysmonNetEvent.SourceHostName      -match $SrcPort)  -and ($SrcPort  -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
            elseif ($SourcePort)      { foreach ($SrcPort  in $SourcePort)      { if (($SysmonNetEvent.SourcePort          -match $SrcPort   -or
                                                                                       $SysmonNetEvent.SourcePortName      -match $SrcPort)  -and ($SrcPort  -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
            elseif ($Account)         { foreach ($Command  in $Account)         { if (($SysmonNetEvent.User                -match $Command)  -and ($Command  -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
            elseif ($ExecutablePath)  { foreach ($Path     in $ExecutablePath)  { if (($SysmonNetEvent.Image               -match $Path)     -and ($Path     -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
        }
        elseif ($regex -eq $false) {
            if     ($DestinationIP)   { foreach ($DestIP   in $DestinationIP)   { if (($SysmonNetEvent.DestinationIp       -eq $DestIP    -or
                                                                                       $SysmonNetEvent.DestinationHostname -eq $DestIP)   -and ($DestIP   -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
            elseif ($DestinationPort) { foreach ($DestPort in $DestinationPort) { if (($SysmonNetEvent.DestinationPort     -eq $DestPort  -or
                                                                                       $SysmonNetEvent.DestinationPortName -eq $DestPort) -and ($DestPort -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
            elseif ($SourceIP)        { foreach ($SrcPort  in $SourceIP)        { if (($SysmonNetEvent.SourceIP            -eq $SrcPort   -or
                                                                                       $SysmonNetEvent.SourceHostName      -eq $SrcPort)  -and ($SrcPort  -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
            elseif ($SourcePort)      { foreach ($SrcPort  in $SourcePort)      { if (($SysmonNetEvent.SourcePort          -eq $SrcPort   -or
                                                                                       $SysmonNetEvent.SourcePortName      -eq $SrcPort)  -and ($SrcPort  -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
            elseif ($Account)         { foreach ($Command  in $Account)         { if (($SysmonNetEvent.User                -eq $Command)  -and ($Command  -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
            elseif ($ExecutablePath)  { foreach ($Path     in $ExecutablePath)  { if (($SysmonNetEvent.Image               -eq $Path)     -and ($Path     -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
        }
    }
    return $SysmonNetworkConnectionEventFound | Select-Object -Property ComputerName, UtcTime, Protocol, SourceHostName, SourceIP, SourcePort, SourcePortName, DestinationHostName, DestinationIP, DestinationPort, DestinationPortName, User, ProcessId, Image, RuleName, Event, Initiated, SourceIsIPv6, DestinationIsIPv6, PSComputerName | Sort-Object -Property UtcTime
}

# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUD1WRSm+SbbruTBq9haU+Mq5d
# n8mgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUWuPHnRUp2TGIhZxskxQCH8O8+DIwDQYJKoZI
# hvcNAQEBBQAEggEAr88yrXtlC1pPUXyfI2IovkPFzOn6q+4wbpXYU7gW3tsssgUB
# S3Qpqtibq4O5MQ9MXByjh5fcD9fvIwuvjayJFu+D9rkTosLUXj8z1P+zvoPA9BG3
# Ms3Fiw9dfy9Mk3+qZuBAWDy01xtjHjVZlspKYWCVXG3hk/5jzk3j9BzfgJaS3H4Z
# QBdw78F4A54DH4w1wDE/E3hC5N09YW75nYtlSP3clKRK8TRYfjSg39M4Ko0hAfbI
# sTKCptKdC75sZAMSFgtwF/1yaMkUG2jQV6yocej0fs9NLo+7O/5u8uoUjRlFD/kM
# J6KShKtsY7bi88pA94WScvWx6GBbjioKbxQQuA==
# SIG # End signature block
