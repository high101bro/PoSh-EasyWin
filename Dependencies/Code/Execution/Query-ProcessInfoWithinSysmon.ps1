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
# n8mgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUWuPHnRUp2TGIhZxskxQCH8O8+DIwDQYJKoZI
# hvcNAQEBBQAEggEAG5vVjyOjwJqRh5WP+CV4GDs+vwvDQ/3a2K2S0Ab9aGpk4DII
# Ttl20gS0thA3iO8Rrz+jRyz3FKMgFL8GYRVt4FU3ir6BfPulacab2n1qiDJFdjZr
# 6KdlIG2/qdrFL6tPLbJcQCFYf25YCQB13letjIgdd+UnQsiEBWwvVFePxRJMbyPL
# w2//pDHgy7zqfc7AgTF3+h0ameGinbT9TMOhy7NDUzHkoVoCLpo9DF+ctMsUjykT
# 8FClkfejV36aneb/eLj2Jz6ifSGw7P7hThCg6icxcP1cCKwTaLxQY8fyUyVaYvR4
# 6SaAR1wuGsyzXX1GyP51LzhJrIL1UtGLk3RjXQ==
# SIG # End signature block
