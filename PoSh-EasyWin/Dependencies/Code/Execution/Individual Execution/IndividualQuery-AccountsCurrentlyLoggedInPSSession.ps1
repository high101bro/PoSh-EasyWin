$CollectionCommandStartTime = Get-Date
$CollectionName = "Accounts Currently Logged In via PowerShell Session"

$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Executing: $CollectionName")
$ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")
$PoShEasyWin.Refresh()

$script:ProgressBarEndpointsProgressBar.Value = 0


foreach ($TargetComputer in $script:ComputerList) {
    if ($ComputerListProvideCredentialsCheckBox.Checked) {
        if (!$script:Credential) { Create-NewCredentials }           

        Start-Job -ScriptBlock {
            param($TargetComputer,$script:Credential)
            Get-WSManInstance -ComputerName $TargetComputer -ResourceURI Shell -Enumerate -Credential $script:Credential | Select-Object *
        } `
        -Name "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
        -ArgumentList @($TargetComputer,$script:Credential)

        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Get-WSManInstance -ComputerName $TargetComputer -ResourceURI Shell -Enumerate -Credential $script:Credential"
    }
    else {
        Start-Job -ScriptBlock {
            param($TargetComputer)
            Get-WSManInstance -ComputerName $TargetComputer -ResourceURI Shell -Enumerate
        } `
        -Name "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
        -ArgumentList @($TargetComputer,$null)
        
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Get-WSManInstance -ComputerName $TargetComputer -ResourceURI Shell -Enumerate"
    }
}
Monitor-Jobs -CollectionName $CollectionName

$CollectionCommandEndTime  = Get-Date                    
$CollectionCommandDiffTime = New-TimeSpan -Start $CollectionCommandStartTime -End $CollectionCommandEndTime
$ResultsListBox.Items.RemoveAt(0)
$ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $CollectionName")


Compile-CsvFiles -LocationOfCSVsToCompile   "$($script:CollectionSavedDirectoryTextBox.Text)\Results By Endpoints\$($CollectionName)\$($CollectionName)*.csv" `
                 -LocationToSaveCompiledCSV "$($script:CollectionSavedDirectoryTextBox.Text)\$($CollectionName).csv"

Compile-XmlFiles -LocationOfXmlsToCompile   "$($script:CollectionSavedDirectoryTextBox.Text)\Results By Endpoints\$($CollectionName)\$($CollectionName)*.xml" `
                 -LocationToSaveCompiledXml "$($script:CollectionSavedDirectoryTextBox.Text)\$($CollectionName).xml"


Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Compiling CSV Files"
Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "$($script:CollectionSavedDirectoryTextBox.Text)\$((($Command.Name) -split ' -- ')[1]) - $($Command.Type).csv"
