$ExecutionStartTime = Get-Date
$CollectionName = "Network Connection - Search Local Port"
$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Executing: $CollectionName")
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")
$PoShEasyWin.Refresh()

$script:ProgressBarEndpointsProgressBar.Value = 0

if ($NetworkConnectionRegexCheckbox.checked){ $NetworkConnectionRegex = $True }
else { $NetworkConnectionRegex = $False }

$NetworkConnectionSearchLocalPort = $NetworkConnectionSearchLocalPortRichTextbox.Lines
#$NetworkConnectionSearchLocalPort = ($NetworkConnectionSearchLocalPortRichTextbox.Text).split("`r`n")
#$NetworkConnectionSearchLocalPort = $NetworkConnectionSearchLocalPort | Where $_ -ne ''

$OutputFilePath = "$($script:CollectionSavedDirectoryTextBox.Text)\Network Connection - Local Port"

#Invoke-Command -ScriptBlock ${function:Query-NetworkConnection} -argumentlist $null,$NetworkConnectionSearchLocalPort,$null -Session $PSSession | Export-Csv -Path $OutputFilePath -NoTypeInformation -Force
Invoke-Command -ScriptBlock ${function:Query-NetworkConnection} `
-ArgumentList @($null,$null,$NetworkConnectionSearchLocalPort,$null,$null,$null,$NetworkConnectionRegex) `
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


