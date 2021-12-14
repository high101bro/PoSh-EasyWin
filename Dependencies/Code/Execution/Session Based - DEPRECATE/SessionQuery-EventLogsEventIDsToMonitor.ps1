$ExecutionStartTime = Get-Date
$CollectionName = "Event Logs - Event IDs To Monitor"
$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Executing: $CollectionName")
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")
$PoShEasyWin.Refresh()

$script:ProgressBarEndpointsProgressBar.Value = 0

$OutputFilePath = "$($script:CollectionSavedDirectoryTextBox.Text)\$CollectionName"

$EventLogsEventIDsToMonitorCheckListBoxCheckedItems = $EventLogsEventIDsToMonitorCheckListBox.CheckedItems
$EventLogsMaximumCollectionTextBoxText = $script:EventLogsMaximumCollectionTextBox.Text
$EventLogsStartTimePickerChecked       = $script:EventLogsStartTimePicker.Checked
$EventLogsStopTimePickerChecked        = $script:EventLogsStopTimePicker.Checked
$EventLogsStartTimePickerValue         = $script:EventLogsStartTimePicker.Value
$EventLogsStopTimePickerValue          = $script:EventLogsStopTimePicker.Value


Invoke-Command -ScriptBlock {
    param($EventLogsEventIDsToMonitorCheckListBoxCheckedItems,$EventLogsMaximumCollectionTextBoxText,$EventLogsStartTimePickerChecked,$EventLogsStopTimePickerChecked,$EventLogsStartTimePickerValue,$EventLogsStopTimePickerValue)
    function Query-EventLogLogsEventIDsIndividualSelectionSessionBased {
        param(
            $EventLogsEventIDsToMonitorCheckListBoxCheckedItems,
            $EventLogsMaximumCollectionTextBoxText,
            $EventLogsStartTimePickerChecked,
            $EventLogsStopTimePickerChecked,
            $EventLogsStartTimePickerValue,
            $EventLogsStopTimePickerValue
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
        $EventLogQueryBuild = "$EventLogQueryCommand $EventLogQueryFilter $EventLogQueryPipe"
        Invoke-Expression $EventLogQueryBuild
    }

    Query-EventLogLogsEventIDsIndividualSelectionSessionBased -EventLogsEventIDsToMonitorCheckListBoxCheckedItems $EventLogsEventIDsToMonitorCheckListBoxCheckedItems -EventLogsMaximumCollectionTextBoxText $EventLogsMaximumCollectionTextBoxText -EventLogsStartTimePickerChecked $EventLogsStartTimePickerChecked -EventLogsStopTimePickerChecked $EventLogsStopTimePickerChecked -EventLogsStartTimePickerValue $EventLogsStartTimePickerValue -EventLogsStopTimePickerValue $EventLogsStopTimePickerValue
} -ArgumentList @($EventLogsEventIDsToMonitorCheckListBoxCheckedItems,$EventLogsMaximumCollectionTextBoxText,$EventLogsStartTimePickerChecked,$EventLogsStopTimePickerChecked,$EventLogsStartTimePickerValue,$EventLogsStopTimePickerValue) -Session $PSSession `
| Set-Variable SessionData
$SessionData | Export-Csv    -Path "$OutputFilePath.csv" -NoTypeInformation -Force
$SessionData | Export-Clixml -Path "$OutputFilePath.xml" -Force
Remove-Variable -Name SessionData -Force


$ResultsListBox.Items.RemoveAt(0)
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  [$(New-TimeSpan -Start $ExecutionStartTime -End (Get-Date))]  $CollectionName")
$PoShEasyWin.Refresh()


$script:ProgressBarQueriesProgressBar.Value += 1
$script:ProgressBarEndpointsProgressBar.Value = ($PSSession.ComputerName).Count
$PoShEasyWin.Refresh()
Start-Sleep -match 500



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU5RjOZ3qlNo+ZWyZqn4+Wlhmj
# x8OgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUu+ex1N8s8XZyg6MJ3v73Cs5k5GIwDQYJKoZI
# hvcNAQEBBQAEggEAXcURm6sNQ3WitQ90Bp3flRuMqUKc41RNx/+SbNakYi1y2d6t
# SqTYpuwriZZuqnp6MI9ZFhfv//0JDdt0M1PVcn8vJeHhb1Ushkj9ksrzH1HMXwsN
# u1GCfvU0xak1ErV3HdDR4rXyygonIg2eGx9hbXDlJZo5g7CjCWcNrNLhL6ERmN6t
# vpp0SxtJI1IcEB3kyqJ7sIQxNARnpLtzFXH/CwHDK/ECf/itdnRSDpPOJjr8+mvi
# vKRD3yJ9qIOZw0pgakGEJmkHf92vAI5vun12hiUK3GS/q0hbBBx9w3O52KGe7FiI
# p1QQkgSwAgL+Q3xRAlnbXHXXlCEaO/PrXoVP3g==
# SIG # End signature block
