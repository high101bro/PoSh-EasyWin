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

$FileHashSelection   = $FileSearchSelectFileHashComboBox.Text
$DirectoriesToSearch = ($FileSearchFileSearchDirectoryRichTextbox.Text).split("`r`n")
$FilesToSearch       = ($FileSearchFileSearchFileRichTextbox.Text).split("`r`n")
$MaximumDepth        = $FileSearchFileSearchMaxDepthTextbox.text

function MonitorJobScriptBlock {
    param(
        $ExecutionStartTime,
        $CollectionName,
        $FileHashSelection,
        $DirectoriesToSearch,
        $FilesToSearch,
        $MaximumDepth
    )
    foreach ($TargetComputer in $script:ComputerList) {
        Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $script:CollectedDataTimeStampDirectory `
                                -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                                -TargetComputer $TargetComputer
        Create-LogEntry -TargetComputer $TargetComputer  -LogFile $LogFile -Message $CollectionName
        
        if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
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
}

Invoke-Command -ScriptBlock ${function:MonitorJobScriptBlock} -ArgumentList @($ExecutionStartTime,$CollectionName,$FileHashSelection,$DirectoriesToSearch,$FilesToSearch,$MaximumDepth)

$EndpointString = ''
foreach ($item in $script:ComputerList) {$EndpointString += "$item`n"}
$SearchString1 = ''
foreach ($item in $DirectoriesToSearch) {$SearchString1 += "$item`n" }
$SearchString2 = ''
foreach ($item in $FilesToSearch) {$SearchString2 += "$item`n" }

$InputValues = @"
===========================================================================
Collection Name:
===========================================================================
$CollectionName

===========================================================================
Execution Time:
===========================================================================
$ExecutionStartTime

===========================================================================
Credentials:
===========================================================================
$($script:Credential.UserName)

===========================================================================
Endpoints:
===========================================================================
$($EndpointString.trim())

===========================================================================
Recursive Depth:
===========================================================================
$MaximumDepth

===========================================================================
Selection Type:
===========================================================================
$FileHashSelection

===========================================================================
Directories To Search:
===========================================================================
$($SearchString1.trim())

===========================================================================
Files to Search:
===========================================================================
$($SearchString2.trim())

"@

if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
    Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:MonitorJobScriptBlock} -ArgumentList @($ExecutionStartTime,$CollectionName,$FileHashSelection,$DirectoriesToSearch,$FilesToSearch,$MaximumDepth) -SmithFlag 'RetrieveFile' -InputValues $InputValues
}
elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Individual Execution') {
    Monitor-Jobs -CollectionName $CollectionName
    Post-MonitorJobs -CollectionName $CollectionName -CollectionCommandStartTime $ExecutionStartTime
}


$CollectionCommandEndTime  = Get-Date
$CollectionCommandDiffTime = New-TimeSpan -Start $ExecutionStartTime -End $CollectionCommandEndTime
$ResultsListBox.Items.RemoveAt(0)
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $CollectionName")


