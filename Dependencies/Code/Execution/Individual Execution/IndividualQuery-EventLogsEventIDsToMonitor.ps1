#DEPRECATED


            # # Clears the commands selected
            # For ($i=0;$i -lt $EventLogsEventIDsToMonitorChecklistbox.Items.count;$i++) {
            #     $EventLogsEventIDsToMonitorChecklistbox.SetSelected($i,$False)
            #     $EventLogsEventIDsToMonitorChecklistbox.SetItemChecked($i,$False)
            #     $EventLogsEventIDsToMonitorChecklistbox.SetItemCheckState($i,$False)
            # }


# $ExecutionStartTime = Get-Date
# $CollectionName = "Event Logs - Event IDs To Monitor"
# $StatusListBox.Items.Clear()
# $StatusListBox.Items.Add("Executing: $CollectionName")
# $ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")
# $PoShEasyWin.Refresh()

# $script:ProgressBarEndpointsProgressBar.Value = 0

# $EventLogsEventIDsToMonitorCheckListBoxCheckedItems = $EventLogsEventIDsToMonitorCheckListBox.CheckedItems
# $EventLogsMaximumCollectionTextBoxText = $script:EventLogsMaximumCollectionTextBox.Text
# $EventLogsStartTimePickerChecked       = $script:EventLogsStartTimePicker.Checked
# $EventLogsStopTimePickerChecked        = $script:EventLogsStopTimePicker.Checked
# $EventLogsStartTimePickerValue         = $script:EventLogsStartTimePicker.Value
# $EventLogsStopTimePickerValue          = $script:EventLogsStopTimePicker.Value


# function Query-EventLogLogsEventIDsIndividualSelectionSessionBased {
#     param(
#         $EventLogsEventIDsToMonitorCheckListBoxCheckedItems,
#         $EventLogsMaximumCollectionTextBoxText,
#         $EventLogsStartTimePickerChecked,
#         $EventLogsStopTimePickerChecked,
#         $EventLogsStartTimePickerValue,
#         $EventLogsStopTimePickerValue,
#         [switch]$RPC,
#         $TargetComputer,
#         $Script:Credential
#     )
#     # Variables begins with an open "(
#     $EventLogsEventIDsToMonitorCheckListBoxFilter = '('
#     foreach ($Checked in $EventLogsEventIDsToMonitorCheckListBoxCheckedItems) {
#         # Get's just the EventID from the checkbox
#         $Checked = $($Checked -split " ")[0]

#         $EventLogsEventIDsToMonitorCheckListBoxFilter += "(EventCode='$Checked') OR "
#     }
#     # Replaces the ' OR ' at the end of the varable with a closing )"
#     $Filter = $EventLogsEventIDsToMonitorCheckListBoxFilter -replace " OR $",")"

#     # Builds the Event Log Query Command
#     $EventLogQueryCommand  = "Get-WmiObject -Class Win32_NTLogEvent"
#     if ($EventLogsMaximumCollectionTextBoxText -eq $null -or $EventLogsMaximumCollectionTextBoxText -eq '' -or $EventLogsMaximumCollectionTextBoxText -eq 0) { $EventLogQueryMax = $null}
#     else { $EventLogQueryMax = "-First $($EventLogsMaximumCollectionTextBoxText)" }
#     if ( $EventLogsStartTimePickerChecked -and $EventLogsStopTimePickerChecked ) {
#         $EventLogQueryFilter = @"
# -Filter "($Filter and (TimeGenerated>='$([System.Management.ManagementDateTimeConverter]::ToDmtfDateTime(($EventLogsStartTimePickerValue)))') and (TimeGenerated<='$([System.Management.ManagementDateTimeConverter]::ToDmtfDateTime(($EventLogsStopTimePickerValue)))'))"
# "@
#     }
#     else { $EventLogQueryFilter = "-Filter `"$Filter`""}
#     $EventLogQueryPipe = @"
# | Select-Object PSComputerName, LogFile, EventIdentifier, CategoryString, @{Name='TimeGenerated';Expression={[Management.ManagementDateTimeConverter]::ToDateTime(`$_.TimeGenerated)}}, Message, Type $EventLogQueryMax
# "@

#     if ($RPC){
#         Invoke-Expression -Command "$EventLogQueryCommand -ComputerName $TargetComputer -Credential `$Script:Credential $EventLogQueryFilter $EventLogQueryPipe"

#     "$EventLogQueryCommand -ComputerName $TargetComputer -Credential `$Script:Credential $EventLogQueryFilter $EventLogQueryPipe"
#     }
#     else {
#         Invoke-Expression "$EventLogQueryCommand $EventLogQueryFilter $EventLogQueryPipe"
#     }
# }


# function MonitorJobScriptBlock {
#     param(
#         $script:ComputerList,
#         $script:Credential,
#         $ExecutionStartTime,
#         $CollectionName,
#         $EventLogsEventIDsToMonitorCheckListBoxCheckedItems,
#         $EventLogsMaximumCollectionTextBoxText,
#         $EventLogsStartTimePickerChecked,
#         $EventLogsStopTimePickerChecked,
#         $EventLogsStartTimePickerValue,
#         $EventLogsStopTimePickerValue
#     )
#     foreach ($TargetComputer in $script:ComputerList) {
#         Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $script:CollectedDataTimeStampDirectory `
#                                 -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
#                                 -TargetComputer $TargetComputer
#         Create-LogEntry -TargetComputer $TargetComputer  -LogFile $LogFile -Message $CollectionName

#         if ($EventLogWinRMRadioButton.Checked) {
#             if ( $script:ComputerListProvideCredentialsCheckBox.Checked ) {
#                 if (!$script:Credential) { Create-NewCredentials }

#                 Invoke-Command -ScriptBlock ${function:Query-EventLogLogsEventIDsIndividualSelectionSessionBased} `
#                 -ArgumentList @($EventLogsEventIDsToMonitorCheckListBoxCheckedItems,$EventLogsMaximumCollectionTextBoxText,$EventLogsStartTimePickerChecked,$EventLogsStopTimePickerChecked,$EventLogsStartTimePickerValue,$EventLogsStopTimePickerValue) `
#                 -ComputerName $TargetComputer `
#                 -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
#                 -Credential $script:Credential
#             }
#             else {
#                 Invoke-Command -ScriptBlock ${function:Query-EventLogLogsEventIDsIndividualSelectionSessionBased} `
#                 -ArgumentList @($EventLogsEventIDsToMonitorCheckListBoxCheckedItems,$EventLogsMaximumCollectionTextBoxText,$EventLogsStartTimePickerChecked,$EventLogsStopTimePickerChecked,$EventLogsStartTimePickerValue,$EventLogsStopTimePickerValue) `
#                 -ComputerName $TargetComputer `
#                 -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"
#             }
#         }
#         else {
#             if ( $script:ComputerListProvideCredentialsCheckBox.Checked ) {
#                 if (!$script:Credential) { Create-NewCredentials }

#                 Start-Job -ScriptBlock {
#                     param(
#                         $EventLogsEventIDsToMonitorCheckListBoxCheckedItems,
#                         $EventLogsMaximumCollectionTextBoxText,
#                         $EventLogsStartTimePickerChecked,
#                         $EventLogsStopTimePickerChecked,
#                         $EventLogsStartTimePickerValue,
#                         $EventLogsStopTimePickerValue,
#                         $TargetComputer,
#                         $script:Credential
#                     )

#                     # Variables begins with an open "(
#                     $EventLogsEventIDsToMonitorCheckListBoxFilter = '('
#                     foreach ($Checked in $EventLogsEventIDsToMonitorCheckListBoxCheckedItems) {
#                         # Get's just the EventID from the checkbox
#                         $Checked = $($Checked -split " ")[0]

#                         $EventLogsEventIDsToMonitorCheckListBoxFilter += "(EventCode='$Checked') OR "
#                     }
#                     # Replaces the ' OR ' at the end of the varable with a closing )"
#                     $Filter = $EventLogsEventIDsToMonitorCheckListBoxFilter -replace " OR $",")"

#                     # Builds the Event Log Query Command
#                     $EventLogQueryCommand  = "Get-WmiObject -Class Win32_NTLogEvent"
#                     if ($EventLogsMaximumCollectionTextBoxText -eq $null -or $EventLogsMaximumCollectionTextBoxText -eq '' -or $EventLogsMaximumCollectionTextBoxText -eq 0) { $EventLogQueryMax = $null}
#                     else { $EventLogQueryMax = "-First $($EventLogsMaximumCollectionTextBoxText)" }
#                     if ( $EventLogsStartTimePickerChecked -and $EventLogsStopTimePickerChecked ) {
#                         $EventLogQueryFilter = @"
# -Filter "($Filter and (TimeGenerated>='$([System.Management.ManagementDateTimeConverter]::ToDmtfDateTime(($EventLogsStartTimePickerValue)))') and (TimeGenerated<='$([System.Management.ManagementDateTimeConverter]::ToDmtfDateTime(($EventLogsStopTimePickerValue)))'))"
# "@
#                     }
#                     else { $EventLogQueryFilter = "-Filter `"$Filter`""}
#                     $EventLogQueryPipe = @"
# | Select-Object PSComputerName, LogFile, EventIdentifier, CategoryString, @{Name='TimeGenerated';Expression={[Management.ManagementDateTimeConverter]::ToDateTime(`$_.TimeGenerated)}}, Message, Type $EventLogQueryMax
# "@

#                     Invoke-Expression -Command "$EventLogQueryCommand -ComputerName $TargetComputer -Credential `$Script:Credential $EventLogQueryFilter $EventLogQueryPipe"
#                 } `
#                 -Name "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
#                 -ArgumentList @($EventLogsEventIDsToMonitorCheckListBoxCheckedItems,$EventLogsMaximumCollectionTextBoxText,$EventLogsStartTimePickerChecked,$EventLogsStopTimePickerChecked,$EventLogsStartTimePickerValue,$EventLogsStopTimePickerValue,$TargetComputer,$script:Credential)
#             }
#             else {
#                 Start-Job -ScriptBlock {
#                     param(
#                         $EventLogsEventIDsToMonitorCheckListBoxCheckedItems,
#                         $EventLogsMaximumCollectionTextBoxText,
#                         $EventLogsStartTimePickerChecked,
#                         $EventLogsStopTimePickerChecked,
#                         $EventLogsStartTimePickerValue,
#                         $EventLogsStopTimePickerValue,
#                         $TargetComputer
#                     )

#                     # Variables begins with an open "(
#                     $EventLogsEventIDsToMonitorCheckListBoxFilter = '('
#                     foreach ($Checked in $EventLogsEventIDsToMonitorCheckListBoxCheckedItems) {
#                         # Get's just the EventID from the checkbox
#                         $Checked = $($Checked -split " ")[0]

#                         $EventLogsEventIDsToMonitorCheckListBoxFilter += "(EventCode='$Checked') OR "
#                     }
#                     # Replaces the ' OR ' at the end of the varable with a closing )"
#                     $Filter = $EventLogsEventIDsToMonitorCheckListBoxFilter -replace " OR $",")"

#                     # Builds the Event Log Query Command
#                     $EventLogQueryCommand  = "Get-WmiObject -Class Win32_NTLogEvent"
#                     if ($EventLogsMaximumCollectionTextBoxText -eq $null -or $EventLogsMaximumCollectionTextBoxText -eq '' -or $EventLogsMaximumCollectionTextBoxText -eq 0) { $EventLogQueryMax = $null}
#                     else { $EventLogQueryMax = "-First $($EventLogsMaximumCollectionTextBoxText)" }
#                     if ( $EventLogsStartTimePickerChecked -and $EventLogsStopTimePickerChecked ) {
#                         $EventLogQueryFilter = @"
# -Filter "($Filter and (TimeGenerated>='$([System.Management.ManagementDateTimeConverter]::ToDmtfDateTime(($EventLogsStartTimePickerValue)))') and (TimeGenerated<='$([System.Management.ManagementDateTimeConverter]::ToDmtfDateTime(($EventLogsStopTimePickerValue)))'))"
# "@
#                     }
#                     else { $EventLogQueryFilter = "-Filter `"$Filter`""}
#                     $EventLogQueryPipe = @"
# | Select-Object PSComputerName, LogFile, EventIdentifier, CategoryString, @{Name='TimeGenerated';Expression={[Management.ManagementDateTimeConverter]::ToDateTime(`$_.TimeGenerated)}}, Message, Type $EventLogQueryMax
# "@

#                     Invoke-Expression -Command "$EventLogQueryCommand -ComputerName $TargetComputer $EventLogQueryFilter $EventLogQueryPipe"
#                 } `
#                 -Name "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
#                 -ArgumentList @($EventLogsEventIDsToMonitorCheckListBoxCheckedItems,$EventLogsMaximumCollectionTextBoxText,$EventLogsStartTimePickerChecked,$EventLogsStopTimePickerChecked,$EventLogsStartTimePickerValue,$EventLogsStopTimePickerValue,$TargetComputer)
#             }
#         }
#     }
# }
# Invoke-Command -ScriptBlock ${function:MonitorJobScriptBlock} -ArgumentList @($script:ComputerList,$script:Credential,$ExecutionStartTime,$CollectionName,$EventLogsEventIDsToMonitorCheckListBoxCheckedItems,$EventLogsMaximumCollectionTextBoxText,$EventLogsStartTimePickerChecked,$EventLogsStopTimePickerChecked,$EventLogsStartTimePickerValue,$EventLogsStopTimePickerValue)

# $EndpointString = ''
# foreach ($item in $script:ComputerList) {$EndpointString += "$item`n"}
# $SearchString = ''
# foreach ($item in $EventLogsEventIDsToMonitorCheckListBoxCheckedItems) {$SearchString += "$item`n" }

# $InputValues = @"
# ===========================================================================
# Collection Name:
# ===========================================================================
# $CollectionName

# ===========================================================================
# Execution Time:
# ===========================================================================
# $ExecutionStartTime

# ===========================================================================
# Credentials:
# ===========================================================================
# $($script:Credential.UserName)

# ===========================================================================
# Endpoints:
# ===========================================================================
# $($EndpointString.trim())

# ===========================================================================
# Start Time:  [$EventLogsStartTimePickerChecked]
# ===========================================================================
# $EventLogsStartTimePickerValue

# ===========================================================================
# End Time:  [$EventLogsStopTimePickerChecked]
# ===========================================================================
# $EventLogsStopTimePickerValue

# ===========================================================================
# Maximum Logs
# ===========================================================================
# $EventLogsMaximumCollectionTextBoxText

# ===========================================================================
# Event Logs:
# ===========================================================================
# $($SearchString.trim())

# "@

# if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
#     Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:MonitorJobScriptBlock} -ArgumentList @($script:ComputerList,$script:Credential,$ExecutionStartTime,$CollectionName,$EventLogsEventIDsToMonitorCheckListBoxCheckedItems,$EventLogsMaximumCollectionTextBoxText,$EventLogsStartTimePickerChecked,$EventLogsStopTimePickerChecked,$EventLogsStartTimePickerValue,$EventLogsStopTimePickerValue) -DisableReRun -InputValues $InputValues
# }
# elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Individual Execution') {
#     Monitor-Jobs -CollectionName $CollectionName
#     Post-MonitorJobs -CollectionName $CollectionName -CollectionCommandStartTime $ExecutionStartTime
# }

# Update-EndpointNotes


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUC+gXiz9TSe2Lmg1/ZyUS6M+k
# sPegggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU9OY/MCvZoJQXE4tdnPdxhrJ9X2gwDQYJKoZI
# hvcNAQEBBQAEggEAhjj+4eUbKbjxP38uXzm+Xc6Oz/faj2mlVvTNHlkEugHonkM8
# kd9RVTfDWu8HuI0qu1AoUKvjLKhukm6/KBN7OZpLifrrcNigQKcZLIy3hvRVHWYr
# qKcH7v+1X1IcWRp5DTaizMinrXgubwcBllm6X1aaNlQWom/Q99tBYK3ByIXTVr9S
# gd6q2GN0uMMYTKpFFc6cOumqTHYHvPacmuWmSil9fHBlCHwxxbO4nGOenqBwT7s2
# Thr96uDBlITkqAULUDVkRcpzR7bMecZG7LWp7UhXjSwCUzHnuVGOrZyig10VFQIl
# ieg6hNBEthcGnQ6JrZKLZuUhO/gRPdyCGwS7XQ==
# SIG # End signature block
