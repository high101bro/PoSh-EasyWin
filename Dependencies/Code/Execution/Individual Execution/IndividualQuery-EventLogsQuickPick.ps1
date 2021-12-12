# Query-EventLog -CollectionName $Query.Name -Filter $Query.Filter

$ExecutionStartTime = Get-Date

$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Executing: Event ID Quick Selection")

$script:ProgressBarEndpointsProgressBar.Value = 0

$EventLogsMaximumCollectionTextBoxText = $script:EventLogsMaximumCollectionTextBox.Text
$EventLogsStartTimePickerChecked       = $script:EventLogsStartTimePicker.Checked
$EventLogsStopTimePickerChecked        = $script:EventLogsStopTimePicker.Checked
$EventLogsStartTimePickerValue         = $script:EventLogsStartTimePicker.Value
$EventLogsStopTimePickerValue          = $script:EventLogsStopTimePicker.Value

function Query-EventLogLogsEventIDsManualEntrySessionBased {
    param(
        $Filter,
        $EventLogsMaximumCollectionTextBoxText,
        $EventLogsStartTimePickerChecked,
        $EventLogsStopTimePickerChecked,
        $EventLogsStartTimePickerValue,
        $EventLogsStopTimePickerValue
    )
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
    $EventLogQueryBuild = "$EventLogQueryCommand $EventLogQueryFilter $EventLogQueryPipe"
    Invoke-Expression $EventLogQueryBuild
}




function String-InputValues {
    param($InputValue)
    $EndpointString = ''
    foreach ($item in $script:ComputerList) {$EndpointString += "$item`n"}

    $script:InputValues = @"
===========================================================================
Collection Name:
===========================================================================
Event ID Quick Selection

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
$InputValue

"@
}



if ($EventLogWinRMRadioButton.Checked) {
    foreach ($Query in $script:EventLogQueries) {
        if ($EventLogsQuickPickSelectionCheckedlistbox.CheckedItems -match $Query.Name) {
            $CollectionName = "Event Logs - $($Query.Name)"

            $ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")

            Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $script:CollectedDataTimeStampDirectory `
                                    -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                                    -TargetComputer $TargetComputer
            Create-LogEntry -TargetComputer $TargetComputer  -LogFile $LogFile -Message $CollectionName


            function MonitorJobScriptBlock {
                param(
                    $script:ComputerList,
                    $script:Credential,
                    $ExecutionStartTime,
                    $CollectionName,
                    $EventLogsMaximumCollectionTextBoxText,
                    $EventLogsStartTimePickerChecked,
                    $EventLogsStopTimePickerChecked,
                    $EventLogsStartTimePickerValue,
                    $EventLogsStopTimePickerValue
                )
                foreach ($TargetComputer in $script:ComputerList) {
                    $InvokeCommandSplat = @{
                        ScriptBlock  = ${function:Query-EventLogLogsEventIDsManualEntrySessionBased}
                        ArgumentList = @($Query.Filter,$EventLogsMaximumCollectionTextBoxText,$EventLogsStartTimePickerChecked,$EventLogsStopTimePickerChecked,$EventLogsStartTimePickerValue,$EventLogsStopTimePickerValue)
                        ComputerName = $TargetComputer
                        AsJob        = $true
                        JobName      = "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"
                    }
        
                    if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                        if (!$script:Credential) { Create-NewCredentials }
                        $InvokeCommandSplat += @{Credential = $script:Credential}
                    }
                    
                    Invoke-Command @InvokeCommandSplat
                }
            }

            $InvokeCommandSplat = @{
                ScriptBlock  = ${function:MonitorJobScriptBlock}
                ArgumentList = @($script:ComputerList,$script:Credential,$ExecutionStartTime,$CollectionName,$EventLogsMaximumCollectionTextBoxText,$EventLogsStartTimePickerChecked,$EventLogsStopTimePickerChecked,$EventLogsStartTimePickerValue,$EventLogsStopTimePickerValue)
            }
            Invoke-Command @InvokeCommandSplat


            String-InputValues -InputValue "$($Query.Name)"

            if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
                Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:MonitorJobScriptBlock} -ArgumentList @($script:ComputerList,$script:Credential,$ExecutionStartTime,$CollectionName,$EventLogsMaximumCollectionTextBoxText,$EventLogsStartTimePickerChecked,$EventLogsStopTimePickerChecked,$EventLogsStartTimePickerValue,$EventLogsStopTimePickerValue) -DisableReRun -InputValues $script:InputValues
            }
            elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Individual Execution') {
                Monitor-Jobs -CollectionName $CollectionName
                Post-MonitorJobs -CollectionName $CollectionName -CollectionCommandStartTime $ExecutionStartTime
            }
            Update-EndpointNotes
        }
    }
}
else {
    if ( $script:ComputerListProvideCredentialsCheckBox.Checked ) {
        if (!$script:Credential) { Create-NewCredentials }

        foreach ($Query in $script:EventLogQueries) {
            if ($EventLogsQuickPickSelectionCheckedlistbox.CheckedItems -match $Query.Name) {
                $CollectionName = "Event Logs - $($Query.Name)"

                $ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")

                Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $script:CollectedDataTimeStampDirectory `
                                        -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                                        -TargetComputer $TargetComputer
                Create-LogEntry -TargetComputer $TargetComputer  -LogFile $LogFile -Message $CollectionName

                function MonitorJobScriptBlock {
                    param(
                        $script:ComputerList,
                        $script:Credential,
                        $ExecutionStartTime,
                        $CollectionName,
                        $EventLogsMaximumCollectionTextBoxText,
                        $EventLogsStartTimePickerChecked,
                        $EventLogsStopTimePickerChecked,
                        $EventLogsStartTimePickerValue,
                        $EventLogsStopTimePickerValue
                    )
                    foreach ($TargetComputer in $script:ComputerList) {
                        Start-Job -ScriptBlock {
                            param(
                                $Filter,
                                $EventLogsMaximumCollectionTextBoxText,
                                $EventLogsStartTimePickerChecked,
                                $EventLogsStopTimePickerChecked,
                                $EventLogsStartTimePickerValue,
                                $EventLogsStopTimePickerValue,
                                $TargetComputer,
                                $script:Credential
                            )
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
                        -ArgumentList $Query.Filter, $EventLogsMaximumCollectionTextBoxText, $EventLogsStartTimePickerChecked,$EventLogsStopTimePickerChecked,$EventLogsStartTimePickerValue,$EventLogsStopTimePickerValue,$TargetComputer,$script:Credential
                    }
                }
                Invoke-Command -ScriptBlock ${function:MonitorJobScriptBlock} -ArgumentList @($script:ComputerList,$script:Credential,$ExecutionStartTime,$CollectionName,$EventLogsMaximumCollectionTextBoxText,$EventLogsStartTimePickerChecked,$EventLogsStopTimePickerChecked,$EventLogsStartTimePickerValue,$EventLogsStopTimePickerValue)

                String-InputValues -InputValue "$($Query.Name)"

                if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
                    Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:MonitorJobScriptBlock} -ArgumentList @($script:ComputerList,$script:Credential,$ExecutionStartTime,$CollectionName,$EventLogsMaximumCollectionTextBoxText,$EventLogsStartTimePickerChecked,$EventLogsStopTimePickerChecked,$EventLogsStartTimePickerValue,$EventLogsStopTimePickerValue) -InputValues $script:InputValues -DisableReRun
                }
                elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Individual Execution') {
                    Monitor-Jobs -CollectionName $CollectionName
                    Post-MonitorJobs -CollectionName $CollectionName -CollectionCommandStartTime $ExecutionStartTime
                }
                Update-EndpointNotes
            }
        }
    }
    else {
        foreach ($Query in $script:EventLogQueries) {
            if ($EventLogsQuickPickSelectionCheckedlistbox.CheckedItems -match $Query.Name) {
                $CollectionName = "Event Logs - $($Query.Name)"

                $ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")

                Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $script:CollectedDataTimeStampDirectory `
                                        -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                                        -TargetComputer $TargetComputer
                Create-LogEntry -TargetComputer $TargetComputer  -LogFile $LogFile -Message $CollectionName

                function MonitorJobScriptBlock {
                    param(
                        $script:ComputerList,
                        $script:Credential,
                        $ExecutionStartTime,
                        $CollectionName,
                        $EventLogsMaximumCollectionTextBoxText,
                        $EventLogsStartTimePickerChecked,
                        $EventLogsStopTimePickerChecked,
                        $EventLogsStartTimePickerValue,
                        $EventLogsStopTimePickerValue
                    )
                    foreach ($TargetComputer in $script:ComputerList) {
                        Start-Job -ScriptBlock {
                            param(
                                $Filter,
                                $EventLogsMaximumCollectionTextBoxText,
                                $EventLogsStartTimePickerChecked,
                                $EventLogsStopTimePickerChecked,
                                $EventLogsStartTimePickerValue,
                                $EventLogsStopTimePickerValue,
                                $TargetComputer
                            )
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
                        -ArgumentList $Query.Filter, $EventLogsMaximumCollectionTextBoxText, $EventLogsStartTimePickerChecked,$EventLogsStopTimePickerChecked,$EventLogsStartTimePickerValue,$EventLogsStopTimePickerValue,$TargetComputer
                    }
                }
                Invoke-Command -ScriptBlock ${function:MonitorJobScriptBlock} -ArgumentList @($script:ComputerList,$script:Credential,$ExecutionStartTime,$CollectionName,$EventLogsMaximumCollectionTextBoxText,$EventLogsStartTimePickerChecked,$EventLogsStopTimePickerChecked,$EventLogsStartTimePickerValue,$EventLogsStopTimePickerValue)

                String-InputValues -InputValue "$($Query.Name)"

                if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
                    Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:MonitorJobScriptBlock} -ArgumentList @($script:ComputerList,$script:Credential,$ExecutionStartTime,$CollectionName,$EventLogsMaximumCollectionTextBoxText,$EventLogsStartTimePickerChecked,$EventLogsStopTimePickerChecked,$EventLogsStartTimePickerValue,$EventLogsStopTimePickerValue) -DisableReRun -InputValues $script:InputValues
                }
                elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Individual Execution') {
                    Monitor-Jobs -CollectionName $CollectionName
                    Post-MonitorJobs -CollectionName $CollectionName -CollectionCommandStartTime $ExecutionStartTime
                }
                Update-EndpointNotes  
            }
        }
    }
}

# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUR7FmuZPho2MHG3WbVZiTkxuQ
# aOKgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUGAE3lQ7IgVoN64MrnK0gYhWRnegwDQYJKoZI
# hvcNAQEBBQAEggEAv0saZAbF3DIZO9FpJ1zSO7MRU1oYr+UmzVXc09AIIZDjDMXK
# RXeJJYvb/pkPEcpfb/Wbwnjeto1SGJQePsX1aZFNQV5vLpl6kEVykEfwW5x3IeLF
# hZwvaZe544TG6sp6JKjBXtKAROkZqlRpax7f3CJLyEpH5r5t5vNiYrd9HsSHH4um
# m4PbtxOjvsgrF7QXvIJgxKSsN5nOuJLySXZK2suHlLAPDrWqOhNk1ZdA/GGzLXI7
# rPOx3/pcoq7uqsRLDbh8sRZDX3SunVG1sTtnTCLOoyIrOzIG6wuT9KvHqmOztbtR
# LyhYOU60JY4avXucrmZ4rwLu4aP5w9oPYcfYjw==
# SIG # End signature block
