$CollectionName = "Event Logs - Event ID Search"
$ExecutionStartTime = Get-Date

$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Query: $CollectionName")
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")

$script:ProgressBarEndpointsProgressBar.Value = 0

$EventLogsEventIDsManualEntryTextboxText = $EventLogsEventIDsManualEntryTextbox.Lines
$EventLogsMaximumCollectionTextBoxText   = $script:EventLogsMaximumCollectionTextBox.Text
$EventLogsStartTimePickerChecked         = $script:EventLogsStartTimePicker.Checked
$EventLogsStopTimePickerChecked          = $script:EventLogsStopTimePicker.Checked
$EventLogsStartTimePickerValue           = $script:EventLogsStartTimePicker.Value
$EventLogsStopTimePickerValue            = $script:EventLogsStopTimePicker.Value


function IndividualQuery-EventIdSearch {
    param(
        $script:ComputerList,
        $script:Credential,
        $ExecutionStartTime,
        $CollectionName,
        $EventLogsEventIDsManualEntryTextboxText,
        $EventLogsMaximumCollectionTextBoxText,
        $EventLogsStartTimePickerChecked,
        $EventLogsStopTimePickerChecked,
        $EventLogsStartTimePickerValue,
        $EventLogsStopTimePickerValue
    )
    $IDs = $EventLogsEventIDsManualEntryTextboxText -replace " ","" -replace "a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z","" | Where-Object {$_.trim() -ne ""}
    #$ManualEntry = ($EventLogsEventIDsManualEntryTextboxText).split("`r`n")

    $EventLogList = (Get-ChildItem 'C:\Windows\System32\Winevt\Logs' | Select-Object -ExpandProperty BaseName) -replace '%4','/'

    if ($EventLogsStartTimePickerValue -and $EventLogsStopTimePickerValue) {
        foreach ($LogName in $EventLogList) {
            $FilterHashtable = @{LogName=$LogName; Id=$IDs}
            try {
                 Get-Winevent -FilterHashtable $FilterHashtable `
                 | Where-Object {$_.TimeCreated -gt $EventLogsStartTimePickerValue -and $_.TimeCreated -lt $EventLogsStopTimePickerValue} `
                 | Select-Object -first $EventLogsMaximumCollectionTextBoxText
            }
            catch {
                Get-Winevent -FilterHashtable $FilterHashtable -Oldest `
                | Where-Object {$_.TimeCreated -gt $EventLogsStartTimePickerValue -and $_.TimeCreated -lt $EventLogsStopTimePickerValue} `
                | Select-Object -first $EventLogsMaximumCollectionTextBoxText
            }
        }
    }
    elseif ($EventLogsStartTimePickerValue) {
        foreach ($LogName in $EventLogList) {
            $FilterHashtable = @{LogName=$LogName; Id=$IDs}
            try {
                 Get-Winevent -FilterHashtable $FilterHashtable `
                 | Where-Object {$_.TimeCreated -gt $EventLogsStartTimePickerValue} `
                 | Select-Object -first $EventLogsMaximumCollectionTextBoxText
            }
            catch {
                Get-Winevent -FilterHashtable $FilterHashtable -Oldest `
                | Where-Object {$_.TimeCreated -gt $EventLogsStartTimePickerValue} `
                | Select-Object -first $EventLogsMaximumCollectionTextBoxText
            }
        }
    }
    elseif ($EventLogsStopTimePickerValue) {
        foreach ($LogName in $EventLogList) {
            $FilterHashtable = @{LogName=$LogName; Id=$IDs}
            try {
                 Get-Winevent -FilterHashtable $FilterHashtable `
                 | Where-Object {$_.TimeCreated -lt $EventLogsStopTimePickerValue} `
                 | Select-Object -first $EventLogsMaximumCollectionTextBoxText
            }
            catch {
                Get-Winevent -FilterHashtable $FilterHashtable -Oldest `
                | Where-Object {$_.TimeCreated -lt $EventLogsStopTimePickerValue} `
                | Select-Object -first $EventLogsMaximumCollectionTextBoxText
            }
        }
    }
    else {
        foreach ($LogName in $EventLogList) {
            $FilterHashtable = @{LogName=$LogName; Id=$IDs}
            try {
                 Get-Winevent -FilterHashtable $FilterHashtable `
                 | Select-Object -first $EventLogsMaximumCollectionTextBoxText
                }
            catch {
                Get-Winevent -FilterHashtable $FilterHashtable -Oldest `
                | Select-Object -first $EventLogsMaximumCollectionTextBoxText
            }
        }
    }
}


function MonitorJobScriptBlock {
    param(
        $script:ComputerList,
        $script:Credential,
        $ExecutionStartTime,
        $CollectionName,
        $EventLogsEventIDsManualEntryTextboxText,
        $EventLogsMaximumCollectionTextBoxText,
        $EventLogsStartTimePickerChecked,
        $EventLogsStopTimePickerChecked,
        $EventLogsStartTimePickerValue,
        $EventLogsStopTimePickerValue
    )

    foreach ($TargetComputer in $script:ComputerList) {
        Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $script:CollectedDataTimeStampDirectory `
                                -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                                -TargetComputer $TargetComputer
        Create-LogEntry -TargetComputer $TargetComputer  -LogFile $LogFile -Message $CollectionName

        if ($EventLogWinRMRadioButton.Checked) {            
            $InvokeCommandSplat = @{
                ScriptBlock  = ${function:IndividualQuery-EventIdSearch}
                ArgumentList = @($script:ComputerList,$script:Credential,$ExecutionStartTime,$CollectionName,$EventLogsEventIDsManualEntryTextboxText,$EventLogsMaximumCollectionTextBoxText,$EventLogsStartTimePickerChecked,$EventLogsStopTimePickerChecked,$EventLogsStartTimePickerValue,$EventLogsStopTimePickerValue)
                ComputerName = $TargetComputer
                AsJob        = $true
                JobName      = "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"
            }

            if ( $script:ComputerListProvideCredentialsCheckBox.Checked ) {
                if (!$script:Credential) { Create-NewCredentials }
                $InvokeCommandSplat += @{Credential = $script:Credential}
            }

            Invoke-Command @InvokeCommandSplat | Select-Object PSComputerName, *
        }
        else {
            if ( $script:ComputerListProvideCredentialsCheckBox.Checked ) {
                if (!$script:Credential) { Create-NewCredentials }

                Start-Job -ScriptBlock {
                    param(
                        $EventLogsEventIDsManualEntryTextboxText,
                        $EventLogsMaximumCollectionTextBoxText,
                        $EventLogsStartTimePickerChecked,
                        $EventLogsStopTimePickerChecked,
                        $EventLogsStartTimePickerValue,
                        $EventLogsStopTimePickerValue,
                        $TargetComputer,
                        $script:Credential
                    )
                    $ManualEntry = $EventLogsEventIDsManualEntryTextboxText
                    #$ManualEntry = ($EventLogsEventIDsManualEntryTextboxText).split("`r`n")
                    $ManualEntry = $ManualEntry -replace " ","" -replace "a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z",""
                    $ManualEntry = $ManualEntry | Where-Object {$_.trim() -ne ""}

                    # Variables begins with an open "(
                    $EventLogsEventIDsManualEntryTextboxFilter = '('

                    foreach ($EventCode in $ManualEntry) {
                        $EventLogsEventIDsManualEntryTextboxFilter += "(EventCode='$EventCode') OR "
                    }
                    # Replaces the ' OR ' at the end of the varable with a closing )"
                    $Filter = $EventLogsEventIDsManualEntryTextboxFilter -replace " OR $",")"

                    # Builds the Event Log Query Command
                    $EventLogQueryCommand  = "Get-WmiObject -Class Win32_NTLogEvent"
                    if ($EventLogsMaximumCollectionTextBoxText -eq $null -or $EventLogsMaximumCollectionTextBoxText -eq '' -or $EventLogsMaximumCollectionTextBoxText -eq 0) { $EventLogQueryMax = $null}
                    else { $EventLogQueryMax = "-First $($EventLogsMaximumCollectionTextBoxText)" }

                    if ( $EventLogsStartTimePickerChecked -and $EventLogsStopTimePickerChecked ) {
                        $EventLogQueryFilter = @"
-Filter "($Filter and (TimeGenerated>='$([System.Management.ManagementDateTimeConverter]::ToDmtfDateTime(($EventLogsStartTimePickerValue)))') and (TimeGenerated<='$([System.Management.ManagementDateTimeConverter]::ToDmtfDateTime(($EventLogsStopTimePickerValue)))'))"
"@
                    }
                    else { $EventLogQueryFilter = "-Filter `"$Filter`""}

                    $EventLogQueryPipe = @"
| Select-Object PSComputerName, LogFile, EventIdentifier, CategoryString, @{Name='TimeGenerated';Expression={[Management.ManagementDateTimeConverter]::ToDateTime(`$_.TimeGenerated)}}, Message, Type $EventLogQueryMax
"@

                    Invoke-Expression -Command "$EventLogQueryCommand -ComputerName $TargetComputer -Credential `$Script:Credential $EventLogQueryFilter $EventLogQueryPipe"
                } `
                -Name "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
                -ArgumentList @($EventLogsEventIDsManualEntryTextboxText,$EventLogsMaximumCollectionTextBoxText,$EventLogsStartTimePickerChecked,$EventLogsStopTimePickerChecked,$EventLogsStartTimePickerValue,$EventLogsStopTimePickerValue,$TargetComputer,$script:Credential)
            }
            else {
                Start-Job -ScriptBlock {
                    param(
                        $EventLogsEventIDsManualEntryTextboxText,
                        $EventLogsMaximumCollectionTextBoxText,
                        $EventLogsStartTimePickerChecked,
                        $EventLogsStopTimePickerChecked,
                        $EventLogsStartTimePickerValue,
                        $EventLogsStopTimePickerValue,
                        $TargetComputer
                    )
                    $ManualEntry = $EventLogsEventIDsManualEntryTextboxText
                    #$ManualEntry = ($EventLogsEventIDsManualEntryTextboxText).split("`r`n")
                    $ManualEntry = $ManualEntry -replace " ","" -replace "a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z",""
                    $ManualEntry = $ManualEntry | Where-Object {$_.trim() -ne ""}

                    # Variables begins with an open "(
                    $EventLogsEventIDsManualEntryTextboxFilter = '('

                    foreach ($EventCode in $ManualEntry) {
                        $EventLogsEventIDsManualEntryTextboxFilter += "(EventCode='$EventCode') OR "
                    }
                    # Replaces the ' OR ' at the end of the varable with a closing )"
                    $Filter = $EventLogsEventIDsManualEntryTextboxFilter -replace " OR $",")"

                    # Builds the Event Log Query Command
                    $EventLogQueryCommand  = "Get-WmiObject -Class Win32_NTLogEvent"
                    if ($EventLogsMaximumCollectionTextBoxText -eq $null -or $EventLogsMaximumCollectionTextBoxText -eq '' -or $EventLogsMaximumCollectionTextBoxText -eq 0) { $EventLogQueryMax = $null}
                    else { $EventLogQueryMax = "-First $($EventLogsMaximumCollectionTextBoxText)" }

                    if ( $EventLogsStartTimePickerChecked -and $EventLogsStopTimePickerChecked ) {
                        $EventLogQueryFilter = @"
-Filter "($Filter and (TimeGenerated>='$([System.Management.ManagementDateTimeConverter]::ToDmtfDateTime(($EventLogsStartTimePickerValue)))') and (TimeGenerated<='$([System.Management.ManagementDateTimeConverter]::ToDmtfDateTime(($EventLogsStopTimePickerValue)))'))"
"@
                    }
                    else { $EventLogQueryFilter = "-Filter `"$Filter`""}

                    $EventLogQueryPipe = @"
| Select-Object PSComputerName, LogFile, EventIdentifier, CategoryString, @{Name='TimeGenerated';Expression={[Management.ManagementDateTimeConverter]::ToDateTime(`$_.TimeGenerated)}}, Message, Type $EventLogQueryMax
"@

                    Invoke-Expression -Command "$EventLogQueryCommand -ComputerName $TargetComputer $EventLogQueryFilter $EventLogQueryPipe"
                } `
                -Name "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
                -ArgumentList @($EventLogsEventIDsManualEntryTextboxText,$EventLogsMaximumCollectionTextBoxText,$EventLogsStartTimePickerChecked,$EventLogsStopTimePickerChecked,$EventLogsStartTimePickerValue,$EventLogsStopTimePickerValue,$TargetComputer)
            }
        }
    }
}
Invoke-Command -ScriptBlock ${function:MonitorJobScriptBlock} -ArgumentList @($script:ComputerList,$script:Credential,$ExecutionStartTime,$CollectionName,$EventLogsEventIDsManualEntryTextboxText,$EventLogsMaximumCollectionTextBoxText,$EventLogsStartTimePickerChecked,$EventLogsStopTimePickerChecked,$EventLogsStartTimePickerValue,$EventLogsStopTimePickerValue)

$EndpointString = ''
foreach ($item in $script:ComputerList) {$EndpointString += "$item`n"}
$SearchString = ''
foreach ($item in $EventLogsEventIDsManualEntryTextboxText) {$SearchString += "$item`n" }

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
Start Time:  [$EventLogsStartTimePickerChecked]
===========================================================================
$EventLogsStartTimePickerValue

===========================================================================
End Time:  [$EventLogsStopTimePickerChecked]
===========================================================================
$EventLogsStopTimePickerValue

===========================================================================
Maximum Logs
===========================================================================
$EventLogsMaximumCollectionTextBoxText

===========================================================================
Event Logs:
===========================================================================
$SearchString

"@

if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
    Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:MonitorJobScriptBlock} -ArgumentList @($script:ComputerList,$script:Credential,$ExecutionStartTime,$CollectionName,$EventLogsEventIDsManualEntryTextboxText,$EventLogsMaximumCollectionTextBoxText,$EventLogsStartTimePickerChecked,$EventLogsStopTimePickerChecked,$EventLogsStartTimePickerValue,$EventLogsStopTimePickerValue) -InputValues $InputValues -DisableReRun
}
elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Individual Execution') {
    Monitor-Jobs -CollectionName $CollectionName
    Post-MonitorJobs -CollectionName $CollectionName -CollectionCommandStartTime $ExecutionStartTime
}

Update-EndpointNotes


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUt5oLyQEkzMpg075tnrjqn2DZ
# n5SgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUpdXhjfRHCV+nrhWGWE7NbhW/wwcwDQYJKoZI
# hvcNAQEBBQAEggEAcGYPaTuOl4hBEsK4Ix9IhkMJYfFokay1XQcTTyh35v2NtAHf
# HcT9EW/c0zUUXHAgE922WdD7pIDJ471OYPGq+UM2YYuSZ5bw+aEs58u/xm0HkVRc
# MSSq8AtGHDPioHoQT/X+bSgk5/n00TKwgAyxSOmHOOGijpveYtN3jNMSHA2RlFOU
# veZU2kzcPIAU+CB1ncTb+OOK8N974AVERdVReFpUbHXRKRd3w5n4Iq8I8zqC3Bbw
# AJo0ePrhEdkHF+fxeXK41CS4FmK/PdNv8xkwhr5KQJYu+dKOpyWgZUl7SWl7104o
# aY6vHM79xav1YuTLIvfQGH1aJGe/TiWCaKdcoQ==
# SIG # End signature block
