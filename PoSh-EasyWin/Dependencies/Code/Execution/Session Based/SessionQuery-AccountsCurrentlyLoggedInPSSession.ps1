$ExecutionStartTime = Get-Date
$CollectionName = "Accounts Currently Logged In via PowerShell Session"

$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Executing: $CollectionName")
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")
$PoShEasyWin.Refresh()

$script:ProgressBarEndpointsProgressBar.Value = 0

$OutputFilePath = "$($script:CollectionSavedDirectoryTextBox.Text)"
if (-not (Test-Path $OutputFilePath)){New-Item -Type Directory -Path $OutputFilePath -Force}

Invoke-Command -ScriptBlock { Get-WSManInstance -ResourceURI Shell -Enumerate } `
-Session $PSSession `
| Set-Variable SessionData -Force


$SessionData | Export-Csv    -Path "$($OutputFilePath)\$($CollectionName).csv" -NoTypeInformation -Force
$SessionData | Export-Clixml -Path "$($OutputFilePath)\$($CollectionName).xml" -Force
Remove-Variable -Name SessionData -Force


Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { Get-WSManInstance -ResourceURI Shell -Enumerate } -Session `$PSSession'"


$ResultsListBox.Items.RemoveAt(0)
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  [$(New-TimeSpan -Start $ExecutionStartTime -End (Get-Date))]  $CollectionName")
$PoShEasyWin.Refresh()


$script:ProgressBarQueriesProgressBar.Value += 1
$script:ProgressBarEndpointsProgressBar.Value = ($PSSession.ComputerName).Count
$PoShEasyWin.Refresh()
Start-Sleep -match 500


