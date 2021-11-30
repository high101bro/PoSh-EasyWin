$ExecutionStartTime = Get-Date
$CollectionName = "Event Logs - Event IDs To Monitor"
$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Executing: $CollectionName")
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")
$PoShEasyWin.Refresh()

$script:ProgressBarEndpointsProgressBar.Value = 0

$EventLogsEventIDsToMonitorCheckListBoxCheckedItems = $EventLogsEventIDsToMonitorCheckListBox.CheckedItems
$EventLogsMaximumCollectionTextBoxText = $script:EventLogsMaximumCollectionTextBox.Text
$EventLogsStartTimePickerChecked       = $script:EventLogsStartTimePicker.Checked
$EventLogsStopTimePickerChecked        = $script:EventLogsStopTimePicker.Checked
$EventLogsStartTimePickerValue         = $script:EventLogsStartTimePicker.Value
$EventLogsStopTimePickerValue          = $script:EventLogsStopTimePicker.Value


function Query-EventLogLogsEventIDsIndividualSelectionSessionBased {
    param(
        $EventLogsEventIDsToMonitorCheckListBoxCheckedItems,
        $EventLogsMaximumCollectionTextBoxText,
        $EventLogsStartTimePickerChecked,
        $EventLogsStopTimePickerChecked,
        $EventLogsStartTimePickerValue,
        $EventLogsStopTimePickerValue,
        [switch]$RPC,
        $TargetComputer,
        $Script:Credential
    )
    # Variables begins with an open "(
    $EventLogsEventIDsToMonitorCheckListBoxFilter = '('
    foreach ($Checked in $EventLogsEventIDsToMonitorCheckListBoxCheckedItems) {
        # Get's just the EventID from the checkbox
        $Checked = $($Checked -split " ")[0]

        $EventLogsEventIDsToMonitorCheckListBoxFilter += "(EventCode='$Checked') OR "
    }
    # Replaces the ' OR ' at the end of the varable with a closing )"
    $Filter = $EventLogsEventIDsToMonitorCheckListBoxFilter -replace " OR $",")"

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

    if ($RPC){
        Invoke-Expression -Command "$EventLogQueryCommand -ComputerName $TargetComputer -Credential `$Script:Credential $EventLogQueryFilter $EventLogQueryPipe"

    "$EventLogQueryCommand -ComputerName $TargetComputer -Credential `$Script:Credential $EventLogQueryFilter $EventLogQueryPipe"
    }
    else {
        Invoke-Expression "$EventLogQueryCommand $EventLogQueryFilter $EventLogQueryPipe"
    }
}


function MonitorJobScriptBlock {
    param(
        $script:ComputerList,
        $script:Credential,
        $ExecutionStartTime,
        $CollectionName,
        $EventLogsEventIDsToMonitorCheckListBoxCheckedItems,
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
            if ( $script:ComputerListProvideCredentialsCheckBox.Checked ) {
                if (!$script:Credential) { Create-NewCredentials }

                Invoke-Command -ScriptBlock ${function:Query-EventLogLogsEventIDsIndividualSelectionSessionBased} `
                -ArgumentList @($EventLogsEventIDsToMonitorCheckListBoxCheckedItems,$EventLogsMaximumCollectionTextBoxText,$EventLogsStartTimePickerChecked,$EventLogsStopTimePickerChecked,$EventLogsStartTimePickerValue,$EventLogsStopTimePickerValue) `
                -ComputerName $TargetComputer `
                -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
                -Credential $script:Credential
            }
            else {
                Invoke-Command -ScriptBlock ${function:Query-EventLogLogsEventIDsIndividualSelectionSessionBased} `
                -ArgumentList @($EventLogsEventIDsToMonitorCheckListBoxCheckedItems,$EventLogsMaximumCollectionTextBoxText,$EventLogsStartTimePickerChecked,$EventLogsStopTimePickerChecked,$EventLogsStartTimePickerValue,$EventLogsStopTimePickerValue) `
                -ComputerName $TargetComputer `
                -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"
            }
        }
        else {
            if ( $script:ComputerListProvideCredentialsCheckBox.Checked ) {
                if (!$script:Credential) { Create-NewCredentials }

                Start-Job -ScriptBlock {
                    param(
                        $EventLogsEventIDsToMonitorCheckListBoxCheckedItems,
                        $EventLogsMaximumCollectionTextBoxText,
                        $EventLogsStartTimePickerChecked,
                        $EventLogsStopTimePickerChecked,
                        $EventLogsStartTimePickerValue,
                        $EventLogsStopTimePickerValue,
                        $TargetComputer,
                        $script:Credential
                    )

                    # Variables begins with an open "(
                    $EventLogsEventIDsToMonitorCheckListBoxFilter = '('
                    foreach ($Checked in $EventLogsEventIDsToMonitorCheckListBoxCheckedItems) {
                        # Get's just the EventID from the checkbox
                        $Checked = $($Checked -split " ")[0]

                        $EventLogsEventIDsToMonitorCheckListBoxFilter += "(EventCode='$Checked') OR "
                    }
                    # Replaces the ' OR ' at the end of the varable with a closing )"
                    $Filter = $EventLogsEventIDsToMonitorCheckListBoxFilter -replace " OR $",")"

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
                -ArgumentList @($EventLogsEventIDsToMonitorCheckListBoxCheckedItems,$EventLogsMaximumCollectionTextBoxText,$EventLogsStartTimePickerChecked,$EventLogsStopTimePickerChecked,$EventLogsStartTimePickerValue,$EventLogsStopTimePickerValue,$TargetComputer,$script:Credential)
            }
            else {
                Start-Job -ScriptBlock {
                    param(
                        $EventLogsEventIDsToMonitorCheckListBoxCheckedItems,
                        $EventLogsMaximumCollectionTextBoxText,
                        $EventLogsStartTimePickerChecked,
                        $EventLogsStopTimePickerChecked,
                        $EventLogsStartTimePickerValue,
                        $EventLogsStopTimePickerValue,
                        $TargetComputer
                    )

                    # Variables begins with an open "(
                    $EventLogsEventIDsToMonitorCheckListBoxFilter = '('
                    foreach ($Checked in $EventLogsEventIDsToMonitorCheckListBoxCheckedItems) {
                        # Get's just the EventID from the checkbox
                        $Checked = $($Checked -split " ")[0]

                        $EventLogsEventIDsToMonitorCheckListBoxFilter += "(EventCode='$Checked') OR "
                    }
                    # Replaces the ' OR ' at the end of the varable with a closing )"
                    $Filter = $EventLogsEventIDsToMonitorCheckListBoxFilter -replace " OR $",")"

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
                -ArgumentList @($EventLogsEventIDsToMonitorCheckListBoxCheckedItems,$EventLogsMaximumCollectionTextBoxText,$EventLogsStartTimePickerChecked,$EventLogsStopTimePickerChecked,$EventLogsStartTimePickerValue,$EventLogsStopTimePickerValue,$TargetComputer)
            }
        }
    }
}
Invoke-Command -ScriptBlock ${function:MonitorJobScriptBlock} -ArgumentList @($script:ComputerList,$script:Credential,$ExecutionStartTime,$CollectionName,$EventLogsEventIDsToMonitorCheckListBoxCheckedItems,$EventLogsMaximumCollectionTextBoxText,$EventLogsStartTimePickerChecked,$EventLogsStopTimePickerChecked,$EventLogsStartTimePickerValue,$EventLogsStopTimePickerValue)

$EndpointString = ''
foreach ($item in $script:ComputerList) {$EndpointString += "$item`n"}
$SearchString = ''
foreach ($item in $EventLogsEventIDsToMonitorCheckListBoxCheckedItems) {$SearchString += "$item`n" }

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
$($SearchString.trim())

"@

if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
    Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:MonitorJobScriptBlock} -ArgumentList @($script:ComputerList,$script:Credential,$ExecutionStartTime,$CollectionName,$EventLogsEventIDsToMonitorCheckListBoxCheckedItems,$EventLogsMaximumCollectionTextBoxText,$EventLogsStartTimePickerChecked,$EventLogsStopTimePickerChecked,$EventLogsStartTimePickerValue,$EventLogsStopTimePickerValue) -DisableReRun -InputValues $InputValues
}
elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Individual Execution') {
    Monitor-Jobs -CollectionName $CollectionName
    Post-MonitorJobs -CollectionName $CollectionName -CollectionCommandStartTime $ExecutionStartTime
}




# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUw3emG9Wequ0jveMcgwGBkFik
# X8+gggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUx2F7/fKfDJQDwDUW4HMFS/48aZIwDQYJKoZI
# hvcNAQEBBQAEggEAD6ksWndA7UQ6cp4vlHVM6tDqjaXGG6FHH26Ar214mBq7XaC3
# zu5Q3+tfpfsTdUR+g/gM+jRDn0uwvTsCDSMdWN92/pkoOkbo5bKdExAP3vREPVTY
# z33yL6EP2VXxP/yyiGDXcqbUr5ieaF/CMu6nCJic2w0gxhJychQLMviUId4Vu/9O
# 10BHZ6qMLTZMQ7C5K24sclKbVnnPfjpta6WVyhjryxxOngM7VoraaB/95oGsmOZ6
# 4ieTjzBaJYCfSnutPg1o2tHBS/gE1o4gP7PsosYOvdzrV7+ZnGLQoLpY2eHFqeg0
# ErhQQo9nFgEjl83Y4UjCvr6eY8lrayLoRRR+fA==
# SIG # End signature block
