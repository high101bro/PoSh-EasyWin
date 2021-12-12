
function IndividualQuery-NetworkConnectionSysmon {
    param(
        [switch]$NetworkSysmonSearchSourceIPAddressCheckbox,
        [switch]$NetworkSysmonSearchSourcePortCheckbox,
        [switch]$NetworkSysmonSearchDestinationIPAddressCheckbox,
        [switch]$NetworkSysmonSearchDestinationPortCheckbox,
        [switch]$NetworkSysmonSearchAccountCheckbox,
        [switch]$NetworkSysmonSearchExecutablePathCheckbox
    )

    function MonitorJobScriptBlock {
        param(
            $CollectionName,
            $NetworkSysmonSearchSourceIPAddress,
            $NetworkSysmonSearchSourcePort,
            $NetworkSysmonSearchDestinationIPAddress,
            $NetworkSysmonSearchDestinationPort,
            $NetworkSysmonSearchAccount,
            $NetworkSysmonSearchExecutablePath,            
            $NetworkSysmonRegex
        )

        foreach ($TargetComputer in $script:ComputerList) {
            Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $script:CollectedDataTimeStampDirectory `
                                    -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                                    -TargetComputer $TargetComputer
            Create-LogEntry -TargetComputer $TargetComputer  -LogFile $LogFile -Message $CollectionName


            $NetworkSysmonScriptBlock = {
                    param(
                        $SourceIP        = $null,
                        $SourcePort      = $null,
                        $DestinationIP   = $null,
                        $DestinationPort = $null,
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
                            if     ($SourceIP)        { foreach ($SrcPort  in $SourceIP)        { if (($SysmonNetEvent.SourceIP            -match $SrcPort   -or
                                                                                                       $SysmonNetEvent.SourceHostName      -match $SrcPort)  -and ($SrcPort  -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
                            elseif ($SourcePort)      { foreach ($SrcPort  in $SourcePort)      { if (($SysmonNetEvent.SourcePort          -match $SrcPort   -or
                                                                                                       $SysmonNetEvent.SourcePortName      -match $SrcPort)  -and ($SrcPort  -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
                            elseif ($DestinationIP)   { foreach ($DestIP   in $DestinationIP)   { if (($SysmonNetEvent.DestinationIp       -match $DestIP    -or
                                                                                                       $SysmonNetEvent.DestinationHostname -match $DestIP)   -and ($DestIP   -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
                            elseif ($DestinationPort) { foreach ($DestPort in $DestinationPort) { if (($SysmonNetEvent.DestinationPort     -match $DestPort  -or
                                                                                                       $SysmonNetEvent.DestinationPortName -match $DestPort) -and ($DestPort -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
                            elseif ($Account)         { foreach ($User  in $Account)            { if (($SysmonNetEvent.User                -match $User)     -and ($User     -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
                            elseif ($ExecutablePath)  { foreach ($Path     in $ExecutablePath)  { if (($SysmonNetEvent.Image               -match $Path)     -and ($Path     -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
                        }
                        elseif ($regex -eq $false) {
                            if     ($SourceIP)        { foreach ($SrcPort  in $SourceIP)        { if (($SysmonNetEvent.SourceIP            -eq $SrcPort   -or
                                                                                                       $SysmonNetEvent.SourceHostName      -eq $SrcPort)  -and ($SrcPort  -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
                            elseif ($SourcePort)      { foreach ($SrcPort  in $SourcePort)      { if (($SysmonNetEvent.SourcePort          -eq $SrcPort   -or
                                                                                                       $SysmonNetEvent.SourcePortName      -eq $SrcPort)  -and ($SrcPort  -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
                            elseif ($DestinationIP)   { foreach ($DestIP   in $DestinationIP)   { if (($SysmonNetEvent.DestinationIp       -eq $DestIP    -or
                                                                                                       $SysmonNetEvent.DestinationHostname -eq $DestIP)   -and ($DestIP   -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
                            elseif ($DestinationPort) { foreach ($DestPort in $DestinationPort) { if (($SysmonNetEvent.DestinationPort     -eq $DestPort  -or
                                                                                                       $SysmonNetEvent.DestinationPortName -eq $DestPort) -and ($DestPort -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
                            elseif ($Account)         { foreach ($User  in $Account)            { if (($SysmonNetEvent.User                -eq $User)     -and ($User     -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
                            elseif ($ExecutablePath)  { foreach ($Path     in $ExecutablePath)  { if (($SysmonNetEvent.Image               -eq $Path)     -and ($Path     -ne '')) { $SysmonNetworkConnectionEventFound += $SysmonNetEvent } } }
                        }
                    }
                    return $SysmonNetworkConnectionEventFound | Select-Object -Property ComputerName, UtcTime, Protocol, SourceHostName, SourceIP, SourcePort, SourcePortName, DestinationHostName, DestinationIP, DestinationPort, DestinationPortName, User, ProcessId, Image, RuleName, Event, Initiated, SourceIsIPv6, DestinationIsIPv6, PSComputerName | Sort-Object -Property UtcTime
            }

            $InvokeCommandSplat = @{
                ScriptBlock  = $NetworkSysmonScriptBlock
                ArgumentList = @(
                    $NetworkSysmonSearchSourceIPAddress,
                    $NetworkSysmonSearchSourcePort,
                    $NetworkSysmonSearchDestinationIPAddress,
                    $NetworkSysmonSearchDestinationPort,
                    $NetworkSysmonSearchAccount,
                    $NetworkSysmonSearchExecutablePath,
                    $NetworkSysmonRegex
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



    if ($NetworkSysmonSearchSourceIPAddressCheckbox) {
        $CollectionName = "Network Connection (Sysmon) Source IP"
        $NetworkSysmonSearchSourceIPAddress = ($NetworkSysmonSearchSourceIPAddressRichTextbox.Text).split("`r`n")
    }
    else {
        $NetworkSysmonSearchSourceIPAddress = $null
    }


    if ($NetworkSysmonSearchSourcePortCheckbox) {
        $CollectionName = "Network Connection (Sysmon) Source Port"
        $NetworkSysmonSearchSourcePort = $NetworkSysmonSearchSourcePortRichTextbox.Lines
    }
    else {
        $NetworkSysmonSearchSourcePort = $null
    }


    if ($NetworkSysmonSearchDestinationIPAddressCheckbox) {
        $CollectionName = "Network Connection (Sysmon) Destination IP"
        $NetworkSysmonSearchDestinationIPAddress = ($NetworkSysmonSearchDestinationIPAddressRichTextbox.Text).split("`r`n")
    }
    else {
        $NetworkSysmonSearchDestinationIPAddress = $null
    }


    if ($NetworkSysmonSearchDestinationPortCheckbox) {
        $CollectionName = "Network Connection (Sysmon) Destination Port"
        $NetworkSysmonSearchDestinationPort = ($NetworkSysmonSearchDestinationPortRichTextbox.Text).split("`r`n")
    }
    else {
        $NetworkSysmonSearchDestinationPort = $null
    }


    if ($NetworkSysmonSearchAccountCheckbox) {
        $CollectionName = "Network Connection (Sysmon) Account-User Started"
        $NetworkSysmonSearchAccount = ($NetworkSysmonSearchAccountRichTextbox.Text).split("`r`n")
    }
    else {
        $NetworkSysmonSearchAccount = $null
    }


    if ($NetworkSysmonSearchExecutablePathCheckbox) {
        $CollectionName = "Network Connection (Sysmon) Executable Path"
        $NetworkSysmonSearchExecutablePath = ($NetworkSysmonSearchExecutablePathTextbox.Text).split("`r`n")
    }
    else {
        $NetworkSysmonSearchExecutablePath = $null
    }


    if ($NetworkSysmonRegexCheckbox.checked) {
        $NetworkSysmonRegex = $True
    }
    else {
        $NetworkSysmonRegex = $False
    }


    $ExecutionStartTime = Get-Date
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Query: $CollectionName")
    $ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")


    $EndpointString = ''
    foreach ($item in $script:ComputerList) {$EndpointString += "$item`n"}
    $SearchString = ''
    foreach ($item in $NetworkSysmonSearchDestinationIPAddress) {$SearchString += "$item`n" }

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
$NetworkSysmonRegex

===========================================================================
Remote IP Address:
===========================================================================
$($SearchString.trim())

"@



    if ($NetworkSysmonSearchSourceIPAddressCheckbox) {
        Invoke-Command -ScriptBlock ${function:MonitorJobScriptBlock} -ArgumentList @($CollectionName,$NetworkSysmonSearchSourceIPAddress,$null,$null,$null,$null,$null,$NetworkSysmonRegex)
        Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:MonitorJobScriptBlock} -ArgumentList @($CollectionName,$NetworkSysmonSearchSourceIPAddress,$null,$null,$null,$null,$null,$NetworkSysmonRegex) -InputValues $InputValues
    }


    if ($NetworkSysmonSearchSourcePortCheckbox) {
        Invoke-Command -ScriptBlock ${function:MonitorJobScriptBlock} -ArgumentList @($CollectionName,$null,$NetworkSysmonSearchSourcePort,$null,$null,$null,$null,$NetworkSysmonRegex)
        Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:MonitorJobScriptBlock} -ArgumentList @($CollectionName,$null,$NetworkSysmonSearchSourcePort,$null,$null,$null,$null,$NetworkSysmonRegex) -InputValues $InputValues
    }


    if ($NetworkSysmonSearchDestinationIPAddressCheckbox) {
        Invoke-Command -ScriptBlock ${function:MonitorJobScriptBlock} -ArgumentList @($CollectionName,$null,$null,$NetworkSysmonSearchDestinationIPAddress,$null,$null,$null,$NetworkSysmonRegex)
        Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:MonitorJobScriptBlock} -ArgumentList @($CollectionName,$null,$null,$NetworkSysmonSearchDestinationIPAddress,$null,$null,$null,$NetworkSysmonRegex) -InputValues $InputValues
    }


    if ($NetworkSysmonSearchDestinationPortCheckbox) {
        Invoke-Command -ScriptBlock ${function:MonitorJobScriptBlock} -ArgumentList @($CollectionName,$null,$null,$null,$NetworkSysmonSearchDestinationPort,$null,$null,$NetworkSysmonRegex)
        Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:MonitorJobScriptBlock} -ArgumentList @($CollectionName,$null,$null,$null,$NetworkSysmonSearchDestinationPort,$null,$null,$NetworkSysmonRegex) -InputValues $InputValues
    }


    if ($NetworkSysmonSearchAccountCheckbox) {
        Invoke-Command -ScriptBlock ${function:MonitorJobScriptBlock} -ArgumentList @($CollectionName,$null,$null,$null,$null,$NetworkSysmonSearchAccount,$null,$NetworkSysmonRegex)
        Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:MonitorJobScriptBlock} -ArgumentList @($CollectionName,$null,$null,$null,$null,$NetworkSysmonSearchAccount,$null,$NetworkSysmonRegex) -InputValues $InputValues
    }


    if ($NetworkSysmonSearchExecutablePathCheckbox) {
        Invoke-Command -ScriptBlock ${function:MonitorJobScriptBlock} -ArgumentList @($CollectionName,$null,$null,$null,$null,$null,$NetworkSysmonSearchExecutablePath,$NetworkSysmonRegex)
        Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:MonitorJobScriptBlock} -ArgumentList @($CollectionName,$null,$null,$null,$null,$null,$NetworkSysmonSearchExecutablePath,$NetworkSysmonRegex) -InputValues $InputValues
    }


    $CollectionCommandEndTime  = Get-Date
    $CollectionCommandDiffTime = New-TimeSpan -Start $ExecutionStartTime -End $CollectionCommandEndTime
    $ResultsListBox.Items.RemoveAt(0)
    $ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $CollectionName")

    Update-EndpointNotes
}

# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUU6OXrYXslrSr/mYAB9ArPinl
# g/OgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUYhtnNYYtVxlekfa3SJhB0NSjJq8wDQYJKoZI
# hvcNAQEBBQAEggEAISyCurMGEmZ2cj+7psMiCK0DL8AENMjDT7UP3Z3a2Bry5mBS
# Ah+GHPmULM28ptEmwvF6zkdTyF6D8h7Khj2Dn1mik0g65hAXqSqG2s6YOZLK6vB6
# 2XJFGdI2jBkE3AeAM+PUxhiSIgDCgG7C5S2QrCoeVWDdUFVAyrf7iUnJhB4W8rsk
# Shl2GwLJkz76urLbz0sT1SjD476a6eETGDrz93YOhliN0ozFdBajb2xwJJHpH6aw
# p4ucRX7DKNoB9wPRwdek9EhP6EizMetplBQZ5Pnn/bRvVvdyOmy60yX5+tTZhCoQ
# OUj2sGTxeNE6JZRMLOj0fRzk/5UTW5iNhCBqHg==
# SIG # End signature block
