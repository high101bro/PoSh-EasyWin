function Query-NetworkConnectionProcess {
    $CollectionName = "Network Connection Process Check"
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
        $NetworkConnectionSearchProcess = @()
        foreach ($Port in $($NetworkConnectionSearchProcessTextbox.Text).split("`r`n")){ $NetworkConnectionSearchProcess += $Port }

$QueryJob = @"
        Start-Job -Name "PoSh-ACME: `$(`$CollectionName) -- `$(`$TargetComputer)" -ScriptBlock {
            param(`$TargetComputer, `$NetworkConnectionSearchProcess, `$IndividualHostResults, `$CollectionName $QueryCredentialParam)
            [System.Threading.Thread]::CurrentThread.Priority = 'High'
            ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'High'

            `$ConnectionFound = Invoke-Command -ComputerName `$TargetComputer $QueryCredential -ScriptBlock {
                param(`$NetworkConnectionSearchProcess, `$TargetComputer)

                $QueryNetworkConnection
                Query-NetworkConnection -ProcessName `$NetworkConnectionSearchProcess

            } -ArgumentList @(`$NetworkConnectionSearchProcess, `$TargetComputer)
                    
            `$ConnectionFound | Select-Object -Property @{Name='PSComputerName';Expression={`$(`$TargetComputer)}}, * | Export-CSV "`$(`$IndividualHostResults)\`$(`$CollectionName)\`$(`$CollectionName)-`$(`$TargetComputer).csv" -NoTypeInformation   
        } -ArgumentList @(`$TargetComputer, `$NetworkConnectionSearchProcess, `$IndividualHostResults, `$CollectionName $QueryCredentialParam)
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
    #not needed# Remove-DuplicateCsvHeaders
}