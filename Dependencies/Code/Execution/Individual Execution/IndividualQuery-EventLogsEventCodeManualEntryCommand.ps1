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
                if (!$script:Credential) { Set-NewCredential }
                $InvokeCommandSplat += @{Credential = $script:Credential}
            }

            Invoke-Command @InvokeCommandSplat | Select-Object PSComputerName, *
        }
        else {
            if ( $script:ComputerListProvideCredentialsCheckBox.Checked ) {
                if (!$script:Credential) { Set-NewCredential }

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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUIaHFg5BWadgNigPXLS2LH5NG
# VKKgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUiPSNBspi/ZUxr3BnCtpXl4whDwYwDQYJKoZI
# hvcNAQEBBQAEggEAnISd8q+xa3qLWqjZY+SRvMnEAgxQLkskzmBcC+GOvLkMT/MH
# 5rQFwCPuwKoR9746wsYUO1AhMXld5NG+8duwOkHAdF135/AkCc+6xl3m+83tC3EE
# OpBPX41s/T8bGm2jq7sddQT+qF8IVLVZVeMVnclm92RvOBhuZ0di7RIpOBZFzeSC
# X5u8rDrg+J/NhmVYWekcTjxp5bG68h9G6Mr8kY4M8md/YSiKlTeIoFkhgsYheU25
# zlnASXl+CfAMPJ6YfcHRgxGDcZ22zgEZ3R0dQN4JWTkEcLaJ9G+atgmqEABaNNhu
# cK2TrSnhSJmm7rcGGT3FpFJO7kE2wZQKxL4P+g==
# SIG # End signature block
