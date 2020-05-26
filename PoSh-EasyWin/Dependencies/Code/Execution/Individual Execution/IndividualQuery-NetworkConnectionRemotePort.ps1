$CollectionName = "Network Connection - Remote Port"
$CollectionCommandStartTime = Get-Date
$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Query: $CollectionName")
$ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")
foreach ($TargetComputer in $ComputerList) {
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

    $NetworkConnectionSearchRemotePort = $NetworkConnectionSearchRemotePortRichTextbox.Lines
    #$NetworkConnectionSearchRemotePort = @()
    #foreach ($Port in $($NetworkConnectionSearchRemotePortRichTextbox.Text).split("`r`n")){ $NetworkConnectionSearchRemotePort += $Port }

$QueryJob = @"
    Start-Job -Name "PoSh-EasyWin: `$(`$CollectionName) -- `$(`$TargetComputer)" -ScriptBlock {
        param(`$TargetComputer, `$NetworkConnectionSearchRemotePort, `$CollectionName $QueryCredentialParam)
        [System.Threading.Thread]::CurrentThread.Priority = 'High'
        ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'High'

        `$ConnectionFound = Invoke-Command -ComputerName `$TargetComputer $QueryCredential -ScriptBlock {
            param(`$NetworkConnectionSearchRemotePort, `$TargetComputer)

            $QueryNetworkConnection
            Query-NetworkConnection -RemotePort `$NetworkConnectionSearchRemotePort

        } -ArgumentList @(`$NetworkConnectionSearchRemotePort, `$TargetComputer)
                
        `$ConnectionFound | Select-Object -Property @{Name='PSComputerName';Expression={`$(`$TargetComputer)}}, *
    } -ArgumentList @(`$TargetComputer, `$NetworkConnectionSearchRemotePort, `$CollectionName $QueryCredentialParam)
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
