$CollectionName = "Network Connection - Process Search"
$CollectionCommandStartTime = Get-Date
$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Query: $CollectionName")
$ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")
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

    $NetworkConnectionSearchProcess = $NetworkConnectionSearchProcessRichTextbox.Lines
    #$NetworkConnectionSearchProcess = @()
    #foreach ($Name in $($NetworkConnectionSearchProcessRichTextbox.Text).split("`r`n")){ $NetworkConnectionSearchProcess += $Name }

$QueryJob = @"
    Start-Job -Name "PoSh-EasyWin: `$(`$CollectionName) -- `$(`$TargetComputer)" -ScriptBlock {
        param(`$TargetComputer, `$NetworkConnectionSearchProcess, `$CollectionName $QueryCredentialParam)
        [System.Threading.Thread]::CurrentThread.Priority = 'High'
        ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'High'

        `$ConnectionFound = Invoke-Command -ComputerName `$TargetComputer $QueryCredential -ScriptBlock {
            param(`$NetworkConnectionSearchProcess, `$TargetComputer)

            $QueryNetworkConnection
            Query-NetworkConnection -ProcessName `$NetworkConnectionSearchProcess

        } -ArgumentList @(`$NetworkConnectionSearchProcess, `$TargetComputer)
                
        `$ConnectionFound | Select-Object -Property @{Name='PSComputerName';Expression={`$(`$TargetComputer)}}, *
    } -ArgumentList @(`$TargetComputer, `$NetworkConnectionSearchProcess, `$CollectionName $QueryCredentialParam)
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
