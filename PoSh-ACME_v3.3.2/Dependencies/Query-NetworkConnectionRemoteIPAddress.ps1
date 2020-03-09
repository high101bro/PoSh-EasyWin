function Query-NetworkConnectionRemoteIPAddress {
    $CollectionName = "Network Connection Remote IP Address"
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
        $NetworkConnectionSearchRemoteIPAddress = @()
        foreach ($IP in $($NetworkConnectionSearchRemoteIPAddressTextbox.Text).split("`r`n")){ $NetworkConnectionSearchRemoteIPAddress += $IP }

$QueryJob = @"
        Start-Job -Name "PoSh-ACME: `$(`$CollectionName) -- `$(`$TargetComputer)" -ScriptBlock {
            param(`$TargetComputer, `$NetworkConnectionSearchRemoteIPAddress, `$IndividualHostResults, `$CollectionName $QueryCredentialParam)
            [System.Threading.Thread]::CurrentThread.Priority = 'High'
            ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'High'

            `$ConnectionFound = Invoke-Command -ComputerName `$TargetComputer $QueryCredential -ScriptBlock {
                param(`$NetworkConnectionSearchRemoteIPAddress, `$TargetComputer)

                $QueryNetworkConnection
                Query-NetworkConnection -IP `$NetworkConnectionSearchRemoteIPAddress

            } -ArgumentList @(`$NetworkConnectionSearchRemoteIPAddress, `$TargetComputer)
                    
            `$ConnectionFound | Select-Object -Property @{Name='PSComputerName';Expression={`$(`$TargetComputer)}}, * | Export-CSV "`$(`$IndividualHostResults)\`$(`$CollectionName)\`$(`$CollectionName)-`$(`$TargetComputer).csv" -NoTypeInformation
            
        } -ArgumentList @(`$TargetComputer, `$NetworkConnectionSearchRemoteIPAddress, `$IndividualHostResults, `$CollectionName $QueryCredentialParam)
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