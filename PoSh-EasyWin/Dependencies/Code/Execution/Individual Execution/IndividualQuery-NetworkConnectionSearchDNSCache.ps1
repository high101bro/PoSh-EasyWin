$CollectionName = "Network Connection - DNS Cache"
$ExecutionStartTime = Get-Date
$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Query: $CollectionName")
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")
foreach ($TargetComputer in $script:ComputerList) {
    param(
        $script:CollectedDataTimeStampDirectory,
        $script:IndividualHostResults,
        $CollectionName,
        $TargetComputer
    )
    Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $script:CollectedDataTimeStampDirectory `
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

    if ($ComputerListProvideCredentialsCheckBox.Checked) {
        if (!$script:Credential) { Create-NewCredentials }

        Invoke-Command -ScriptBlock ${function:Get-DNSCache} `
        -Argumentlist @($NetworkConnectionSearchDNSCache,$null) `
        -ComputerName $TargetComputer `
        -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
        -Credential $script:Credential `
        | Select-Object PSComputerName, Mode, Length, Name, Extension, Attributes, FullName, CreationTime, LastWriteTime, LastAccessTime, BaseName, Directory, PSIsContainer, Filehash, FileHashAlgorithm
    }
    else {
        Invoke-Command -ScriptBlock ${function:Get-DNSCache} `
        -Argumentlist @($NetworkConnectionSearchDNSCache,$null) `
        -ComputerName $TargetComputer `
        -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
        | Select-Object PSComputerName, Mode, Length, Name, Extension, Attributes, FullName, CreationTime, LastWriteTime, LastAccessTime, BaseName, Directory, PSIsContainer, Filehash, FileHashAlgorithm
    }
}

Monitor-Jobs -CollectionName $CollectionName -MonitorMode
#Commented out because the above -MonitorMode implementation doesn't save files individually
#Post-MonitorJobs -CollectionName $CollectionName -CollectionCommandStartTime $ExecutionStartTime

$CollectionCommandEndTime  = Get-Date
$CollectionCommandDiffTime = New-TimeSpan -Start $ExecutionStartTime -End $CollectionCommandEndTime
$ResultsListBox.Items.RemoveAt(0)
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $CollectionName")


