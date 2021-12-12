#batman
function IndividualQuery-ProcessCreationSysmon {
    param(
        [switch]$ProcessCreationSysmonSearchOriginalFileNameCheckbox,
        [switch]$ProcessCreationSysmonSearchUserCheckbox,
        [switch]$ProcessCreationSysmonSearchHashesCheckbox,
        [switch]$ProcessCreationSysmonSearchFilePathCheckbox,
        [switch]$ProcessCreationSysmonSearchCommandlineCheckbox,
        [switch]$ProcessCreationSysmonSearchParentFilePathCheckbox,
        [switch]$ProcessCreationSysmonSearchParentCommandlineCheckbox
    )

    function MonitorJobScriptBlock {
        param(
            $CollectionName,
            $ProcessCreationSysmonRegex,
            $ProcessCreationSysmonSearchOriginalFileName,
            $ProcessCreationSysmonSearchUser,
            $ProcessCreationSysmonSearchHashes,
            $ProcessCreationSysmonSearchFilePath,
            $ProcessCreationSysmonSearchCommandline,
            $ProcessCreationSysmonSearchParentFilePath,
            $ProcessCreationSysmonSearchParentCommandline
        )

        foreach ($TargetComputer in $script:ComputerList) {
            Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $script:CollectedDataTimeStampDirectory `
                                    -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                                    -TargetComputer $TargetComputer
            Create-LogEntry -TargetComputer $TargetComputer  -LogFile $LogFile -Message $CollectionName


            $ProcessCreationSysmonScriptBlock = {
                    param(
                        $SourceIP        = $null,
                        $SourcePort      = $null,
                        $DestinationIP   = $null,
                        $DestinationPort = $null,
                        $Account         = $null,
                        $ExecutablePath  = $null,
                        $regex           = $false
                    )
                
                    $SysmonProcessCreationEventLogs = Get-WinEvent -FilterHashtable @{
                        LogName = 'Microsoft-Windows-Sysmon/Operational'
                        Id      = 1
                    }

                    $SysmonProcessCreationEventLogsFormatted = @()
                    Foreach ($event in ($SysmonProcessCreationEventLogs | Select-Object -Expand Message)) {
                        $SysmonProcessCreationEventLogsFormatted += [PSCustomObject]@{
                            'Event'             = ($event -split "`r`n")[0].TrimEnd(':')
                            'RuleName'          = (($event -split "`r`n")[1] -split ": ")[1]
                            'UtcTime'           = [datetime](($event -split "`r`n")[2] -split ": ")[1]
                            'ProcessGuid'       = (($event -split "`r`n")[3] -split ": ")[1].Replace('{','').Replace('}','')
                            'ProcessId'         = (($event -split "`r`n")[4] -split ": ")[1]
                            'Image'             = (($event -split "`r`n")[5] -split ": ")[1]
                            'FileVersion'       = (($event -split "`r`n")[6] -split ": ")[1]
                            'Description'       = (($event -split "`r`n")[7] -split ": ")[1]
                            'Product'           = (($event -split "`r`n")[8] -split ": ")[1]
                            'Company'           = (($event -split "`r`n")[9] -split ": ")[1]
                            'OriginalFileName'  = (($event -split "`r`n")[10] -split ": ")[1]
                            'CommandLine'       = (($event -split "`r`n")[11] -split ": ")[1]
                            'CurrentDirectory'  = (($event -split "`r`n")[12] -split ": ")[1]
                            'User'              = (($event -split "`r`n")[13] -split ": ")[1]
                            'LogonGuid'         = (($event -split "`r`n")[14] -split ": ")[1]
                            'LogonId'           = (($event -split "`r`n")[15] -split ": ")[1]
                            'TerminalSessionId' = (($event -split "`r`n")[16] -split ": ")[1]
                            'IntegrityLevel'    = (($event -split "`r`n")[17] -split ": ")[1]
                            'SHA1Hash'          = (($event -split "`r`n")[18] -split ": ")[1].split(',')[0].split('=')[1]
                            'MD5Hash'           = (($event -split "`r`n")[18] -split ": ")[1].split(',')[1].split('=')[1]
                            'SHA256Hash'        = (($event -split "`r`n")[18] -split ": ")[1].split(',')[2].split('=')[1]
                            'IMPHash'           = (($event -split "`r`n")[18] -split ": ")[1].split(',')[3].split('=')[1]
                            'Hashes'            = (($event -split "`r`n")[18] -split ": ")[1]
                            'ParentProcessGuid' = (($event -split "`r`n")[19] -split ": ")[1]
                            'ParentProcessId'   = (($event -split "`r`n")[20] -split ": ")[1]
                            'ParentImage'       = (($event -split "`r`n")[21] -split ": ")[1]
                            'ParentCommandLine' = (($event -split "`r`n")[22] -split ": ")[1]
                        }
                    }
                
                    $SysmonProcessCreationConnectionEventFound = @()
                
                    foreach ($SysmonNetEvent in $SysmonProcessCreationEventLogsFormatted) {
                        if ($regex -eq $true) {
                            if     ($SourceIP)        { foreach ($SrcPort  in $SourceIP)        { if (($SysmonNetEvent.SourceIP            -match $SrcPort   -or
                                                                                                       $SysmonNetEvent.SourceHostName      -match $SrcPort)  -and ($SrcPort  -ne '')) { $SysmonProcessCreationConnectionEventFound += $SysmonNetEvent } } }
                            elseif ($SourcePort)      { foreach ($SrcPort  in $SourcePort)      { if (($SysmonNetEvent.SourcePort          -match $SrcPort   -or
                                                                                                       $SysmonNetEvent.SourcePortName      -match $SrcPort)  -and ($SrcPort  -ne '')) { $SysmonProcessCreationConnectionEventFound += $SysmonNetEvent } } }
                            elseif ($DestinationIP)   { foreach ($DestIP   in $DestinationIP)   { if (($SysmonNetEvent.DestinationIp       -match $DestIP    -or
                                                                                                       $SysmonNetEvent.DestinationHostname -match $DestIP)   -and ($DestIP   -ne '')) { $SysmonProcessCreationConnectionEventFound += $SysmonNetEvent } } }
                            elseif ($DestinationPort) { foreach ($DestPort in $DestinationPort) { if (($SysmonNetEvent.DestinationPort     -match $DestPort  -or
                                                                                                       $SysmonNetEvent.DestinationPortName -match $DestPort) -and ($DestPort -ne '')) { $SysmonProcessCreationConnectionEventFound += $SysmonNetEvent } } }
                            elseif ($Account)         { foreach ($User  in $Account)            { if (($SysmonNetEvent.User                -match $User)     -and ($User     -ne '')) { $SysmonProcessCreationConnectionEventFound += $SysmonNetEvent } } }
                            elseif ($ExecutablePath)  { foreach ($Path     in $ExecutablePath)  { if (($SysmonNetEvent.Image               -match $Path)     -and ($Path     -ne '')) { $SysmonProcessCreationConnectionEventFound += $SysmonNetEvent } } }
                        }
                        elseif ($regex -eq $false) {
                            if     ($SourceIP)        { foreach ($SrcPort  in $SourceIP)        { if (($SysmonNetEvent.SourceIP            -eq $SrcPort   -or
                                                                                                       $SysmonNetEvent.SourceHostName      -eq $SrcPort)  -and ($SrcPort  -ne '')) { $SysmonProcessCreationConnectionEventFound += $SysmonNetEvent } } }
                            elseif ($SourcePort)      { foreach ($SrcPort  in $SourcePort)      { if (($SysmonNetEvent.SourcePort          -eq $SrcPort   -or
                                                                                                       $SysmonNetEvent.SourcePortName      -eq $SrcPort)  -and ($SrcPort  -ne '')) { $SysmonProcessCreationConnectionEventFound += $SysmonNetEvent } } }
                            elseif ($DestinationIP)   { foreach ($DestIP   in $DestinationIP)   { if (($SysmonNetEvent.DestinationIp       -eq $DestIP    -or
                                                                                                       $SysmonNetEvent.DestinationHostname -eq $DestIP)   -and ($DestIP   -ne '')) { $SysmonProcessCreationConnectionEventFound += $SysmonNetEvent } } }
                            elseif ($DestinationPort) { foreach ($DestPort in $DestinationPort) { if (($SysmonNetEvent.DestinationPort     -eq $DestPort  -or
                                                                                                       $SysmonNetEvent.DestinationPortName -eq $DestPort) -and ($DestPort -ne '')) { $SysmonProcessCreationConnectionEventFound += $SysmonNetEvent } } }
                            elseif ($Account)         { foreach ($User  in $Account)            { if (($SysmonNetEvent.User                -eq $User)     -and ($User     -ne '')) { $SysmonProcessCreationConnectionEventFound += $SysmonNetEvent } } }
                            elseif ($ExecutablePath)  { foreach ($Path     in $ExecutablePath)  { if (($SysmonNetEvent.Image               -eq $Path)     -and ($Path     -ne '')) { $SysmonProcessCreationConnectionEventFound += $SysmonNetEvent } } }
                        }
                    }
                    return $SysmonProcessCreationConnectionEventFound | Select-Object -Property ComputerName, UtcTime, Protocol, SourceHostName, SourceIP, SourcePort, SourcePortName, DestinationHostName, DestinationIP, DestinationPort, DestinationPortName, User, ProcessId, Image, RuleName, Event, Initiated, SourceIsIPv6, DestinationIsIPv6, PSComputerName | Sort-Object -Property UtcTime
            }

            $InvokeCommandSplat = @{
                ScriptBlock  = $ProcessCreationSysmonScriptBlock
                ArgumentList = @(
                    $ProcessCreationSysmonSearchOriginalFileName,
                    $ProcessCreationSysmonSearchUser,
                    $ProcessCreationSysmonSearchHashes,
                    $ProcessCreationSysmonSearchFilePath,
                    $ProcessCreationSysmonSearchCommandline,
                    $ProcessCreationSysmonSearchParentFilePath,
                    $ProcessCreationSysmonRegex
                )
                ComputerName = $TargetComputer
                AsJob        = $true
                JobName      = "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"
            }
            

            if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { Create-NewCredentials }
                $InvokeCommandSplat += @{Credential = $script:Credential}
            }
            Invoke-Command @InvokeCommandSplat | Select-Object PSComputerName, *
        }
    }



    if ($ProcessCreationSysmonSearchOriginalFileNameCheckbox) {
        $CollectionName = "Process (Sysmon) Source IP"
        $ProcessCreationSysmonSearchOriginalFileName = ($ProcessCreationSysmonSearchOriginalFileNameRichTextbox.Text).split("`r`n")
    }
    else {
        $ProcessCreationSysmonSearchOriginalFileName = $null
    }


    if ($ProcessCreationSysmonSearchUserCheckbox) {
        $CollectionName = "Process (Sysmon) Source Port"
        $ProcessCreationSysmonSearchUser = $ProcessCreationSysmonSearchUserRichTextbox.Lines
    }
    else {
        $ProcessCreationSysmonSearchUser = $null
    }


    if ($ProcessCreationSysmonSearchHashesCheckbox) {
        $CollectionName = "Process (Sysmon) Destination IP"
        $ProcessCreationSysmonSearchHashes = ($ProcessCreationSysmonSearchHashesRichTextbox.Text).split("`r`n")
    }
    else {
        $ProcessCreationSysmonSearchHashes = $null
    }


    if ($ProcessCreationSysmonSearchFilePathCheckbox) {
        $CollectionName = "Process (Sysmon) Destination Port"
        $ProcessCreationSysmonSearchFilePath = ($ProcessCreationSysmonSearchFilePathRichTextbox.Text).split("`r`n")
    }
    else {
        $ProcessCreationSysmonSearchFilePath = $null
    }


    if ($ProcessCreationSysmonSearchCommandlineCheckbox) {
        $CollectionName = "Process (Sysmon) Account-User Started"
        $ProcessCreationSysmonSearchCommandline = ($ProcessCreationSysmonSearchCommandlineRichTextbox.Text).split("`r`n")
    }
    else {
        $ProcessCreationSysmonSearchCommandline = $null
    }


    if ($ProcessCreationSysmonSearchParentFilePathCheckbox) {
        $CollectionName = "Process (Sysmon) Executable Path"
        $ProcessCreationSysmonSearchParentFilePath = ($ProcessCreationSysmonSearchParentFilePathTextbox.Text).split("`r`n")
    }
    else {
        $ProcessCreationSysmonSearchParentFilePath = $null
    }

    
    if ($ProcessCreationSysmonSearchParentCommandlineCheckbox) {
        $CollectionName = "Process (Sysmon) Executable Path"
        $ProcessCreationSysmonSearchParentFilePath = ($ProcessCreationSysmonSearchParentFilePathTextbox.Text).split("`r`n")
    }
    else {
        $ProcessCreationSysmonSearchParentFilePath = $null
    }


    if ($ProcessCreationSysmonRegexCheckbox.checked) {
        $ProcessCreationSysmonRegex = $True
    }
    else {
        $ProcessCreationSysmonRegex = $False
    }


    $ExecutionStartTime = Get-Date
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Query: $CollectionName")
    $ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")


    $EndpointString = ''
    foreach ($item in $script:ComputerList) {$EndpointString += "$item`n"}
    $SearchString = ''
    foreach ($item in $ProcessCreationSysmonSearchHashes) {$SearchString += "$item`n" }

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
$ProcessCreationSysmonRegex

===========================================================================
Remote IP Address:
===========================================================================
$($SearchString.trim())

"@



    if ($ProcessCreationSysmonSearchOriginalFileNameCheckbox) {
        Invoke-Command -ScriptBlock ${function:MonitorJobScriptBlock} -ArgumentList @($CollectionName,$ProcessCreationSysmonRegex,$ProcessCreationSysmonSearchOriginalFileName,$null,$null,$null,$null,$null,$null)
        Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:MonitorJobScriptBlock} -ArgumentList @($CollectionName,$ProcessCreationSysmonRegex,$ProcessCreationSysmonSearchOriginalFileName,$null,$null,$null,$null,$null,$null) -InputValues $InputValues
    }


    if ($ProcessCreationSysmonSearchUserCheckbox) {
        Invoke-Command -ScriptBlock ${function:MonitorJobScriptBlock} -ArgumentList @($CollectionName,$ProcessCreationSysmonRegex,$null,$ProcessCreationSysmonSearchUser,$null,$null,$null,$null,$null)
        Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:MonitorJobScriptBlock} -ArgumentList @($CollectionName,$ProcessCreationSysmonRegex,$null,$ProcessCreationSysmonSearchUser,$null,$null,$null,$null,$null) -InputValues $InputValues
    }


    if ($ProcessCreationSysmonSearchHashesCheckbox) {
        Invoke-Command -ScriptBlock ${function:MonitorJobScriptBlock} -ArgumentList @($CollectionName,$ProcessCreationSysmonRegex,$null,$null,$ProcessCreationSysmonSearchHashes,$null,$null,$null,$null)
        Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:MonitorJobScriptBlock} -ArgumentList @($CollectionName,$ProcessCreationSysmonRegex,$null,$null,$ProcessCreationSysmonSearchHashes,$null,$null,$null,$null) -InputValues $InputValues
    }


    if ($ProcessCreationSysmonSearchFilePathCheckbox) {
        Invoke-Command -ScriptBlock ${function:MonitorJobScriptBlock} -ArgumentList @($CollectionName,$ProcessCreationSysmonRegex,$null,$null,$null,$ProcessCreationSysmonSearchFilePath,$null,$null,$null)
        Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:MonitorJobScriptBlock} -ArgumentList @($CollectionName,$ProcessCreationSysmonRegex,$null,$null,$null,$ProcessCreationSysmonSearchFilePath,$null,$null,$null) -InputValues $InputValues
    }


    if ($ProcessCreationSysmonSearchCommandlineCheckbox) {
        Invoke-Command -ScriptBlock ${function:MonitorJobScriptBlock} -ArgumentList @($CollectionName,$ProcessCreationSysmonRegex,$null,$null,$null,$null,$ProcessCreationSysmonSearchCommandline,$null,$null)
        Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:MonitorJobScriptBlock} -ArgumentList @($CollectionName,$ProcessCreationSysmonRegex,$null,$null,$null,$null,$ProcessCreationSysmonSearchCommandline,$null,$null) -InputValues $InputValues
    }


    if ($ProcessCreationSysmonSearchParentFilePathCheckbox) {
        Invoke-Command -ScriptBlock ${function:MonitorJobScriptBlock} -ArgumentList @($CollectionName,$ProcessCreationSysmonRegex,$null,$null,$null,$null,$null,$ProcessCreationSysmonSearchParentFilePath,$null)
        Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:MonitorJobScriptBlock} -ArgumentList @($CollectionName,$ProcessCreationSysmonRegex,$null,$null,$null,$null,$null,$ProcessCreationSysmonSearchParentFilePath,$null) -InputValues $InputValues
    }
    

    if ($ProcessCreationSysmonSearchParentCommandlineCheckbox) {
        Invoke-Command -ScriptBlock ${function:MonitorJobScriptBlock} -ArgumentList @($CollectionName,$ProcessCreationSysmonRegex,$null,$null,$null,$null,$null,$null,$ProcessCreationSysmonSearchParentCommandline)
        Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:MonitorJobScriptBlock} -ArgumentList @($CollectionName,$ProcessCreationSysmonRegex,$null,$null,$null,$null,$null,$null,$ProcessCreationSysmonSearchParentCommandline) -InputValues $InputValues
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUf5zvfVvT5VIuwmepgGgm+lCi
# QnSgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUr5XmrcuTmG1M+Cw1/4InzMQ2mc4wDQYJKoZI
# hvcNAQEBBQAEggEACoV1YfkZMCdthrVoFJFmY13dY2jMOnRHIhXN6dMbwuOs6zb+
# Svah5YzpMHkAVJ2lzKex9g1O8PmBwQI+wtTun561011QbimTGyGErtN2TfQBDzgn
# ixvQEzUOks9LGBFQ4bbcxE8F9uP5cmvKL3FKit27u/hWrFc7WDjUmMN2OAxISEVM
# citVUXCQvvpCEImI4TkX/eXp5rOAgL00GUOnkvyzrwzsSLncjNEooqHy2GO+okaJ
# fA73D0iMwZzq0kDwb7xR7PP0kgl+TDBi7BNLE1hHT+ITaioEoVOGqQKbocJcBkDJ
# fcPVRm8veRWWwEUVZNffdmZXo5rXrTPLGtT3Qg==
# SIG # End signature block
