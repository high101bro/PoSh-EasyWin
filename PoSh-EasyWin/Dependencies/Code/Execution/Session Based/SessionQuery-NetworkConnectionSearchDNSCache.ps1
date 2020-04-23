$CollectionCommandStartTime = Get-Date
$CollectionName = "Network Connection - Search DNS Cache"
$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Executing: $CollectionName")
$ResultsListBox.Items.Insert(1,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")
$PoShEasyWin.Refresh()

$script:ProgressBarEndpointsProgressBar.Value = 0

$NetworkConnectionSearchDNSCache = $NetworkConnectionSearchDNSCacheRichTextbox.Lines
#$NetworkConnectionSearchDNSCache = ($NetworkConnectionSearchDNSCacheRichTextbox.Text).split("`r`n")
#$NetworkConnectionSearchDNSCache = $NetworkConnectionSearchDNSCache | Where $_ -ne ''

$OutputFilePath = "$($script:CollectionSavedDirectoryTextBox.Text)\Network Connection - DNS Cache"

Invoke-Command -ScriptBlock {
    param($NetworkConnectionSearchDNSCache)
    $DNSQueryCache = Get-DnsClientCache
    $DNSQueryFoundList = @()
    foreach ($DNSQuery in $NetworkConnectionSearchDNSCache) {
        $DNSQueryFoundList += $DNSQueryCache | Where-Object {($_.name -match $DNSQuery) -or ($_.entry -match $DNSQuery) -or ($_.data -match $DNSQuery) }
    }
    $DNSQueryFoundList | Select-Object -Property PSComputerName, Entry, Name, Data, Type, Status, Section, TTL, DataLength

} -argumentlist $($NetworkConnectionSearchDNSCache,$null) -Session $PSSession `
| Set-Variable SessionData
$SessionData | Export-Csv    -Path "$OutputFilePath.csv" -NoTypeInformation -Force
$SessionData | Export-Clixml -Path "$OutputFilePath.xml" -Force
Remove-Variable -Name SessionData -Force

$ResultsListBox.Items.RemoveAt(1)
$ResultsListBox.Items.Insert(1,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  [$(New-TimeSpan -Start $CollectionCommandStartTime -End (Get-Date))]  $CollectionName")
$PoShEasyWin.Refresh()

$script:ProgressBarQueriesProgressBar.Value += 1
$script:ProgressBarEndpointsProgressBar.Value = ($PSSession.ComputerName).Count
$PoShEasyWin.Refresh()
Start-Sleep -match 500
 