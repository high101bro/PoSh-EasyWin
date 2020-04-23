$CollectionName = "Network Connection - DNS Cache"
$CollectionCommandStartTime = Get-Date
$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Query: $CollectionName")
$ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")
foreach ($TargetComputer in $ComputerList) {
    param(
        $CollectedDataTimeStampDirectory, 
        $script:IndividualHostResults, 
        $CollectionName,
        $TargetComputer
    )
    Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $CollectedDataTimeStampDirectory `
                            -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                            -TargetComputer $TargetComputer
    Create-LogEntry -TargetComputer $TargetComputer  -LogFile $LogFile -Message $CollectionName

    if ($ComputerListProvideCredentialsCheckBox.Checked) {
        if (!$script:Credential) { $script:Credential = Get-Credential }
        $QueryCredentialParam = ", $script:Credential"
        $QueryCredential      = "-Credential $script:Credential"
    }
    else {
        $QueryCredentialParam = $null
        $QueryCredential      = $null        
    }

    $NetworkConnectionSearchDNSCache = $NetworkConnectionSearchDNSCacheRichTextbox.Lines
    #$NetworkConnectionSearchDNSCache = @()
    #foreach ($DNSQuery in $($NetworkConnectionSearchDNSCacheRichTextbox.Text).split("`r`n")){ $NetworkConnectionSearchDNSCache += $DNSQuery | Where {$_ -ne ''} }

$QueryJob = @"
    Start-Job -Name "PoSh-EasyWin: `$(`$CollectionName) -- `$(`$TargetComputer)" -ScriptBlock {
        param(`$TargetComputer, `$NetworkConnectionSearchDNSCache, `$script:IndividualHostResults, `$CollectionName $QueryCredentialParam)
        [System.Threading.Thread]::CurrentThread.Priority = 'High'
        ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'High'

        `$DNSQueryCache = Invoke-Command -ComputerName `$TargetComputer -ScriptBlock { Get-DnsClientCache }        
        `$DNSQueryFoundList = @()
        foreach (`$DNSQuery in `$NetworkConnectionSearchDNSCache) {
#                `$DNSQueryFoundList += `$DNSQueryCache | Out-String -Stream | Select-String -Pattern `$DNSQuery
            `$DNSQueryFoundList += `$DNSQueryCache | Where {(`$_.name -match `$DNSQuery) -or (`$_.entry -match `$DNSQuery) -or (`$_.data -match `$DNSQuery) }
        }
        `$DNSQueryFoundList | Select-Object -Property @{Name='PSComputerName';Expression={`$(`$TargetComputer)}}, Entry, Name, Data, Type, Status, Section, TTL, DataLength

    } -ArgumentList @(`$TargetComputer, `$NetworkConnectionSearchDNSCache, `$script:IndividualHostResults, `$CollectionName $QueryCredentialParam)
"@
Invoke-Expression -Command $QueryJob
}

Monitor-Jobs -CollectionName $CollectionName

$CollectionCommandEndTime  = Get-Date                    
$CollectionCommandDiffTime = New-TimeSpan -Start $CollectionCommandStartTime -End $CollectionCommandEndTime
$ResultsListBox.Items.RemoveAt(0)
$ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $CollectionName")

Compile-CsvFiles -LocationOfCSVsToCompile   "$($script:IndividualHostResults)\$($CollectionName)\$($CollectionName)*.csv" `
                 -LocationToSaveCompiledCSV "$($script:CollectionSavedDirectoryTextBox.Text)\$($CollectionName).csv"

Compile-XmlFiles -LocationOfXmlsToCompile   "$($script:IndividualHostResults)\$($CollectionName)\$($CollectionName)*.xml" `
                 -LocationToSaveCompiledXml "$($script:CollectionSavedDirectoryTextBox.Text)\$($CollectionName).xml"

Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Compiling CSV Files"
Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "$($script:CollectionSavedDirectoryTextBox.Text)\$((($Command.Name) -split ' -- ')[1]) - $($Command.Type).csv"                 
