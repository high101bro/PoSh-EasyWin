$ExecutionStartTime = Get-Date
$CollectionName = "Network Connection - Search Process"
$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Executing: $CollectionName")
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")
$PoShEasyWin.Refresh()

$script:ProgressBarEndpointsProgressBar.Value = 0

$NetworkConnectionSearchProcess = $NetworkConnectionSearchProcessRichTextbox.Lines
#$NetworkConnectionSearchProcess = ($NetworkConnectionSearchProcessRichTextbox.Text).split("`r`n")
#$NetworkConnectionSearchProcess = $NetworkConnectionSearchProcess | Where $_ -ne ''

$OutputFilePath = "$($script:CollectionSavedDirectoryTextBox.Text)\Network Connection - Remote Process Name"

#Invoke-Command -ScriptBlock ${function:Query-NetworkConnection} -argumentlist $null,$null,$NetworkConnectionSearchProcess -Session $PSSession | Export-Csv -Path $OutputFilePath -NoTypeInformation -Force
Invoke-Command -ScriptBlock ${function:Query-NetworkConnection} `
-ArgumentList @($null,$null,$null,$NetworkConnectionSearchProcess) `
-Session $PSSession `
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


