if     ($RegistryKeyNameCheckbox.checked)   { $CollectionName = "Registry Search - Key Name" }
elseif ($RegistryValueNameCheckbox.checked) { $CollectionName = "Registry Search - Value Name" }
elseif ($RegistryValueDataCheckbox.checked) { $CollectionName = "Registry Search - Value Data" }

$CollectionCommandStartTime = Get-Date
$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Query: $CollectionName")
$ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")

foreach ($TargetComputer in $script:ComputerList) {
    Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $script:CollectedDataTimeStampDirectory `
                            -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                            -TargetComputer $TargetComputer
    Create-LogEntry -TargetComputer $TargetComputer  -LogFile $LogFile -Message $CollectionName

    $RegistrySearchDirectory = @()
    foreach ($Directory in $($script:RegistrySearchDirectoryRichTextbox.Text).split("`r`n")){ $RegistrySearchDirectory += $Directory.trim() | Where {$_ -ne ''} }

    $SearchRegistryKeyName = @()
    foreach ($KeyName in $($script:RegistryKeyNameSearchRichTextbox.Text).split("`r`n")){ $SearchRegistryKeyName += $KeyName.trim() | Where {$_ -ne ''} }

    $SearchRegistryValueName = @()
    foreach ($ValueName in $($script:RegistryValueNameSearchRichTextbox.Text).split("`r`n")){ $SearchRegistryValueName += $ValueName.trim() | Where {$_ -ne ''} }

    $SearchRegistryValueData = @()
    foreach ($ValueData in $($script:RegistryValueDataSearchRichTextbox.Text).split("`r`n")){ $SearchRegistryValueData += $ValueData.trim() | Where {$_ -ne ''} }


    if ($RegistryKeyNameCheckbox.checked)   { 
        $CountCommandQueries++
        if ($RegistrySearchRecursiveCheckbox.checked) {
            $SearchRegistryCommand = @($RegistrySearchDirectory,$true,$SearchRegistryKeyName,$true,$false,$false)
        }
        else {
            $SearchRegistryCommand = @($RegistrySearchDirectory,$false,$SearchRegistryKeyName,$true,$false,$false)
        }
    }
    if ($RegistryValueNameCheckbox.checked) { 
        $CountCommandQueries++
        if ($RegistrySearchRecursiveCheckbox.checked) {
            $SearchRegistryCommand = @($RegistrySearchDirectory,$true,$SearchRegistryValueName,$false,$true,$false)
        }
        else {
            $SearchRegistryCommand = @($RegistrySearchDirectory,$false,$SearchRegistryValueName,$false,$true,$false)
        }
    }
    if ($RegistryValueDataCheckbox.checked) { 
        $CountCommandQueries++
        if ($RegistrySearchRecursiveCheckbox.checked) {
            $SearchRegistryCommand = @($RegistrySearchDirectory,$true,$SearchRegistryValueData,$false,$false,$true)
        }
        else {
            $SearchRegistryCommand = @($RegistrySearchDirectory,$false,$SearchRegistryValueData,$false,$false,$true)
        }
    }


    if ($ComputerListProvideCredentialsCheckBox.Checked) {
        if (!$script:Credential) { Create-NewCredentials }           
        Invoke-Command -ScriptBlock $QueryRegistryFunction `
        -ArgumentList $SearchRegistryCommand `
        -ComputerName $TargetComputer `
        -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
        -Credential $script:Credential

        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `$QueryRegistryFunction -ArgumentList `$SearchRegistryCommand  -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)' -Credential `$script:Credential"
        $ResultsListBox.Items.Add("$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName -- $TargetComputer")    
    }
    else {
        Invoke-Command -ScriptBlock $QueryRegistryFunction `
        -ArgumentList $SearchRegistryCommand `
        -ComputerName $TargetComputer `
        -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"

        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `$QueryRegistryFunction -ArgumentList `$SearchRegistryCommand  -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)''"
        $ResultsListBox.Items.Add("$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName -- $TargetComputer")    
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

