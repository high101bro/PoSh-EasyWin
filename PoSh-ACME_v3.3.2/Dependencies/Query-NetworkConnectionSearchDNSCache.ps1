function Query-NetworkConnectionSearchDNSCache {
    $CollectionName = "Network Connection DNS Cache Check"
    $CollectionCommandStartTime = Get-Date
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Query: $CollectionName")
    $ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")
    foreach ($TargetComputer in $ComputerList) {
        param(
            $CollectedDataTimeStampDirectory, 
            $IndividualHostResults, 
            $CollectionName,
            $TargetComputer
        )
        Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $CollectedDataTimeStampDirectory `
                                -IndividualHostResults $IndividualHostResults -CollectionName $CollectionName `
                                -TargetComputer $TargetComputer
        Create-LogEntry -TargetComputer $TargetComputer -CollectionName $CollectionName -LogFile $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked) {
            if (!$script:Credential) { $script:Credential = Get-Credential }
            $QueryCredentialParam = ", $script:Credential"
            $QueryCredential      = "-Credential $script:Credential"
        }
        else {
            $QueryCredentialParam = $null
            $QueryCredential      = $null        
        }
        $NetworkConnectionSearchDNSCache = @()
        foreach ($DNSQuery in $($NetworkConnectionSearchDNSCacheTextbox.Text).split("`r`n")){ $NetworkConnectionSearchDNSCache += $DNSQuery | Where {$_ -ne ''} }

$QueryJob = @"
        Start-Job -Name "PoSh-ACME: `$(`$CollectionName) -- `$(`$TargetComputer)" -ScriptBlock {
            param(`$TargetComputer, `$NetworkConnectionSearchDNSCache, `$IndividualHostResults, `$CollectionName $QueryCredentialParam)
            [System.Threading.Thread]::CurrentThread.Priority = 'High'
            ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'High'

            `$DNSQueryCache = Invoke-Command -ComputerName `$TargetComputer -ScriptBlock { Get-DnsClientCache }        
            `$DNSQueryFoundList = @()
            foreach (`$DNSQuery in `$NetworkConnectionSearchDNSCache) {
#                `$DNSQueryFoundList += `$DNSQueryCache | Out-String -Stream | Select-String -Pattern `$DNSQuery
                `$DNSQueryFoundList += `$DNSQueryCache | Where {(`$_.name -match `$DNSQuery) -or (`$_.entry -match `$DNSQuery) -or (`$_.data -match `$DNSQuery) }
            }
            `$DNSQueryFoundList | Select-Object -Property @{Name='PSComputerName';Expression={`$(`$TargetComputer)}}, Entry, Name, Data, Type, Status, Section, TTL, DataLength | Export-CSV "`$(`$IndividualHostResults)\`$(`$CollectionName)\`$(`$CollectionName)-`$(`$TargetComputer).csv" -NoTypeInformation

        } -ArgumentList @(`$TargetComputer, `$NetworkConnectionSearchDNSCache, `$IndividualHostResults, `$CollectionName $QueryCredentialParam)
"@
    Invoke-Expression -Command $QueryJob
    }
    Monitor-Jobs
    $CollectionCommandEndTime  = Get-Date                    
    $CollectionCommandDiffTime = New-TimeSpan -Start $CollectionCommandStartTime -End $CollectionCommandEndTime
    $ResultsListBox.Items.RemoveAt(0)
    $ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $CollectionName")
    Compile-CsvFiles -LocationOfCSVsToCompile   "$($IndividualHostResults)\$($CollectionName)\$($CollectionName)*.csv" `
                     -LocationToSaveCompiledCSV "$($CollectedDataTimeStampDirectory)\$($CollectionName).csv"
}