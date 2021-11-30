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
# x8OgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUu+ex1N8s8XZyg6MJ3v73Cs5k5GIwDQYJKoZI
# hvcNAQEBBQAEggEAxxW+ou7AJt66kg9wzdf8nod2d6RLCCTnqI//IeZF8vLGFfrn
# LxNhU/Z2N25yiWq0XWVlFKzCrKxPec78JsGzDhCKyNcLWu7FCCtGUVGgOee12FJY
# VN2RGXXOyEXTmDeKfs7gdS/nvmwsUmmCuab4+Me4a6uADOZztIJmG9RWvE2fNOQ3
# yVcUTD4IiW15e/xDcZK9l8OpceVVeAs5+gMqmBqzGBP3+DBMD3YZHfgCJU9aVjPp
# Mpa58VDczF5doUCbHWdVsG2+4UEgrygju1Bt8PrlUuwKnAOULWZCm5UyYuROWQUU
# 4OKWlJq4iJKNOyzx9aB0U2e6kzD1MkmlqoSHrA==
# SIG # End signature block
