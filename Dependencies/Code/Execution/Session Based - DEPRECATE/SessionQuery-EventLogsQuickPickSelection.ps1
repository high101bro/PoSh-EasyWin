$ExecutionStartTime = Get-Date

$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Executing: Event ID Quick Selection")
$PoShEasyWin.Refresh()

$script:ProgressBarEndpointsProgressBar.Value = 0

$EventLogsMaximumCollectionTextBoxText   = $script:EventLogsMaximumCollectionTextBox.Text
$EventLogsStartTimePickerChecked         = $script:EventLogsStartTimePicker.Checked
$EventLogsStopTimePickerChecked          = $script:EventLogsStopTimePicker.Checked
$EventLogsStartTimePickerValue           = $script:EventLogsStartTimePicker.Value
$EventLogsStopTimePickerValue            = $script:EventLogsStopTimePicker.Value

function SessionQuery-EventIdQuickSelection {
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


foreach ($Query in $script:EventLogQueries) {
    if ($EventLogsQuickPickSelectionCheckedlistbox.CheckedItems -match $Query.Name) {
        $CollectionName = "Event Logs - $($Query.Name)"
        $OutputFilePath = "$($script:CollectionSavedDirectoryTextBox.Text)\Event Logs - $($Query.Name)"


        $ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName ($($Query.Name))")
        $PoShEasyWin.Refresh()


        Invoke-Command -ScriptBlock ${function:SessionQuery-EventIdQuickSelection} `
        -ArgumentList $Query.Filter, $EventLogsMaximumCollectionTextBoxText, $EventLogsStartTimePickerChecked, $EventLogsStopTimePickerChecked, $EventLogsStartTimePickerValue, $EventLogsStopTimePickerValue `
        -Session $PSSession `
        | Set-Variable SessionData


        $SessionData | Export-Csv    -Path "$OutputFilePath.csv" -NoTypeInformation -Force
        $SessionData | Export-Clixml -Path "$OutputFilePath.xml" -Force
        Remove-Variable -Name SessionData -Force


        $script:ProgressBarQueriesProgressBar.Value += 1
        $PoShEasyWin.Refresh()


        $ResultsListBox.Items.RemoveAt(0)
        $ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  [$(New-TimeSpan -Start $ExecutionStartTime -End (Get-Date))]  $CollectionName ($($Query.Name))")
        $PoShEasyWin.Refresh()
    }
}


$script:ProgressBarEndpointsProgressBar.Value = ($PSSession.ComputerName).Count
$PoShEasyWin.Refresh()
Start-Sleep -match 500



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUSlEEsi81HVSRfYBPBrrrjDUh
# fOOgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUegRvluY/XTQFMyFrs7fxMuy+918wDQYJKoZI
# hvcNAQEBBQAEggEAmmr9pd85xNVMSl7kJJ08bpd8GZNaJwn+i5RcSxsyPzUN9cvl
# 4NsRrfwyBasN/soK8rzTdFRyzY5JB2JUghdbRAmEJhqKlTEnFA0/gVdbuvOb0ZKs
# 7t5D8O0VVpQaEVrDL1xsZB/X/mazzLJKYE7vWuClTfnw0iriIYgt+EgZU36bV89f
# TSH8glLmNxGWOyaI1ibIEzG+jdEPYRuYu+bdZNikY5dH5JDMg9D4v4cboZ3ccXjp
# kVa2LWsRLHsgDSNwodxlSMJXhWMh7oEuyazI2c5HKnXGeHwOyuIA95cebW4hVyex
# sDrBDBZmYB6Gb8qjw2qUk8eF7NE9wU0iVsNJNg==
# SIG # End signature block
