$ExecutionStartTime = Get-Date
$CollectionName = ($script:CustomQueryScriptBlockTextbox.text -split ' ')[0]
$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Executing: $CollectionName")
$ResultsListBox.Items.Insert(1,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")
$PoShEasyWin.Refresh()

$script:ProgressBarEndpointsProgressBar.Value = 0

$OutputFilePath = "$($script:CollectionSavedDirectoryTextBox.Text)\$CollectionName"

Invoke-Command -ScriptBlock {
    param($script:ShowCommandQueryBuild)
    Invoke-Expression -Command $script:ShowCommandQueryBuild
} `
-ArgumentList $script:ShowCommandQueryBuild `
-Session $PSSession `
| Set-Variable SessionData

Create-LogEntry -LogFile $LogFile -Message "Invoke-Command -ScriptBlock { param(`$script:ShowCommandQueryBuild) Invoke-Expression -Command $script:ShowCommandQueryBuild } -Session `$PSSession -ArgumentList `$script:ShowCommandQueryBuild"

$SessionData | Export-Csv    -Path "$OutputFilePath.csv" -NoTypeInformation -Force
$SessionData | Export-Clixml -Path "$OutputFilePath.xml" -Force
Remove-Variable -Name SessionData -Force

$ResultsListBox.Items.RemoveAt(1)
$ResultsListBox.Items.Insert(1,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  [$(New-TimeSpan -Start $ExecutionStartTime -End (Get-Date))]  $CollectionName")
$PoShEasyWin.Refresh()

$script:ProgressBarQueriesProgressBar.Value   += 1
$script:ProgressBarEndpointsProgressBar.Value = ($PSSession.ComputerName).Count
$PoShEasyWin.Refresh()
Start-Sleep -match 500



