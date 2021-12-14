
function IndividualQuery-NetworkSysmon {
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUWHpBMDCgY2UgrbhK31qam9wn
# XO2gggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUXIiyXEEm+gipIyplWs8DZSAKxFkwDQYJKoZI
# hvcNAQEBBQAEggEAIsZLOdDrqLg2jp3vAkpfwRXhW+9/bD2novjPmZTXeEeA+xM1
# TyBYaIRb9ytsWQKur4soAJZCe3Q4/tp2fW6qRYOKdUUUTh1iwGj3UUQKA/4a7S/R
# 8xK2KLE10qkipOejiwtH9zR2W/P5Zb01XSEoggAwgipZUHTPwOthWas6SOVR7Urr
# yXo3OnTfN4ccEhPCTHvheeKL81xP69G42OjOilnnJEv4M3GEhEjmexlrmrqQjQ6e
# YujhKvESYY8fLTJ4xv/ebWc9IP/OWMEz9RPnoKLscGrNN0SfWOU7WKa0phGW8USA
# kO2HYtw25WuBz+2wOMat0/Wd5pKQUMZGKvptIg==
# SIG # End signature block
