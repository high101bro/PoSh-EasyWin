$CollectionCommandStartTime = Get-Date
$CollectionName = "Account Logon Activity"

$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Executing: $CollectionName")
$ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")
$PoShEasyWin.Refresh()

$script:ProgressBarEndpointsProgressBar.Value = 0

$OutputFilePath = "$($script:CollectionSavedDirectoryTextBox.Text)"
if (-not (Test-Path $OutputFilePath)){New-Item -Type Directory -Path $OutputFilePath -Force}

$AccountsStartTimePickerValue = $AccountsStartTimePicker.Value
$AccountsStopTimePickerValue  = $AccountsStopTimePicker.Value


Invoke-Command -ScriptBlock ${function:Get-AccountLogonActivity} `
-ArgumentList @($AccountsStartTimePickerValue,$AccountsStopTimePickerValue) `
-Session $PSSession `
| Set-Variable SessionData


$SessionData | Export-Csv    -Path "$($OutputFilePath)\$($CollectionName).csv" -NoTypeInformation -Force
$SessionData | Export-Clixml -Path "$($OutputFilePath)\$($CollectionName).xml" -Force
Remove-Variable -Name SessionData -Force


Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `${function:Get-AccountLogonActivity} -ArgumentList @(`$AccountsStartTimePickerValue,`$AccountsStopTimePickerValue) -Session `$PSSession'"


$ResultsListBox.Items.RemoveAt(0)
$ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  [$(New-TimeSpan -Start $CollectionCommandStartTime -End (Get-Date))]  $CollectionName")
$PoShEasyWin.Refresh()


$script:ProgressBarQueriesProgressBar.Value += 1
$script:ProgressBarEndpointsProgressBar.Value = ($PSSession.ComputerName).Count
$PoShEasyWin.Refresh()
Start-Sleep -match 500
