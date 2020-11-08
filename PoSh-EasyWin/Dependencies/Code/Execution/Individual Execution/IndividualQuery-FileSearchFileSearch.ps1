$ExecutionStartTime = Get-Date
if     ($FileSearchSelectFileHashComboBox.Text -eq 'Filename') {$CollectionName = "File Search"}
elseif ($FileSearchSelectFileHashComboBox.Text -eq 'MD5')      {$CollectionName = "MD5 Hash Search"}
elseif ($FileSearchSelectFileHashComboBox.Text -eq 'SHA1')     {$CollectionName = "SHA1 Hash Search"}
elseif ($FileSearchSelectFileHashComboBox.Text -eq 'SHA256')   {$CollectionName = "SHA256 Hash Search"}
elseif ($FileSearchSelectFileHashComboBox.Text -eq 'SHA384')   {$CollectionName = "SHA384 Hash Search"}
elseif ($FileSearchSelectFileHashComboBox.Text -eq 'SHA512')   {$CollectionName = "SHA512 Hash Search"}
elseif ($FileSearchSelectFileHashComboBox.Text -eq 'RIPEMD160'){$CollectionName = "RIPEMD160 Hash Search"}
else   {$CollectionName = "Search"}

$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Query: $CollectionName")
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")

foreach ($TargetComputer in $script:ComputerList) {
    Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $script:CollectedDataTimeStampDirectory `
                            -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                            -TargetComputer $TargetComputer
    Create-LogEntry -TargetComputer $TargetComputer  -LogFile $LogFile -Message $CollectionName


    $FileHashSelection   = $FileSearchSelectFileHashComboBox.Text
    $DirectoriesToSearch = ($FileSearchFileSearchDirectoryRichTextbox.Text).split("`r`n")
    $FilesToSearch       = ($FileSearchFileSearchFileRichTextbox.Text).split("`r`n")
    $MaximumDepth        = $FileSearchFileSearchMaxDepthTextbox.text

    if ($ComputerListProvideCredentialsCheckBox.Checked) {
        if (!$script:Credential) { Create-NewCredentials }

        Invoke-Command -ScriptBlock ${function:Conduct-FileSearch} `
        -ArgumentList @($DirectoriesToSearch,$FilesToSearch,$MaximumDepth,$GetChildItemDepth,$GetFileHash,$FileHashSelection) `
        -ComputerName $TargetComputer `
        -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
        -Credential $script:Credential `
        | Select-Object PSComputerName, Mode, Length, Name, Extension, Attributes, FullName, CreationTime, LastWriteTime, LastAccessTime, BaseName, Directory, PSIsContainer, Filehash, FileHashAlgorithm

        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `${function:Conduct-FileSearch} -ArgumentList @(`$DirectoriesToSearch,`$FilesToSearch,`$MaximumDepth,`$GetChildItemDepth,`$GetFileHash,`$FileHashSelection)  -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)' -Credential `$script:Credential"
    }
    else {
        Invoke-Command -ScriptBlock ${function:Conduct-FileSearch} `
        -ArgumentList @($DirectoriesToSearch,$FilesToSearch,$MaximumDepth,$GetChildItemDepth,$GetFileHash,$FileHashSelection) `
        -ComputerName $TargetComputer `
        -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
        | Select-Object PSComputerName, Mode, Length, Name, Extension, Attributes, FullName, CreationTime, LastWriteTime, LastAccessTime, BaseName, Directory, PSIsContainer, Filehash, FileHashAlgorithm

        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `${function:Conduct-FileSearch} -ArgumentList @(`$DirectoriesToSearch,`$FilesToSearch,`$MaximumDepth,`$GetChildItemDepth,`$GetFileHash,`$FileHashSelection)  -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)'"
    }
}

Monitor-Jobs -CollectionName $CollectionName -MonitorMode
#Commented out because the above -MonitorMode implementation doesn't save files individually
#Post-MonitorJobs -CollectionName $CollectionName -CollectionCommandStartTime $ExecutionStartTime

$CollectionCommandEndTime  = Get-Date
$CollectionCommandDiffTime = New-TimeSpan -Start $ExecutionStartTime -End $CollectionCommandEndTime
$ResultsListBox.Items.RemoveAt(0)
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $CollectionName")


