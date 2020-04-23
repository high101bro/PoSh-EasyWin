$CollectionName = "File Search"
$CollectionCommandStartTime = Get-Date 
$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Query: $CollectionName")                    
$ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")
foreach ($TargetComputer in $ComputerList) {
    param(
        $CollectedDataTimeStampDirectory, 
        $script:IndividualHostResults, 
        $CollectionName, 
        $TargetComputer
    )
    Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $CollectedDataTimeStampDirectory `
                            -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                            -TargetComputer $TargetComputer
    Create-LogEntry -TargetComputer $TargetComputer  -LogFile $LogFile -Message $CollectionName

    $DirectoriesToSearch = ($FileSearchFileSearchDirectoryRichTextbox.Text).split("`r`n")
    $FilesToSearch       = ($FileSearchFileSearchFileRichTextbox.Text).split("`r`n")
    $MaximumDepth        = $FileSearchFileSearchMaxDepthTextbox.text
    $FileHashSelection   = $FileSearchSelectFileHashCheckbox.Text

    if ($ComputerListProvideCredentialsCheckBox.Checked) {
        if (!$script:Credential) { $script:Credential = Get-Credential }
        $QueryCredentialParam = ", $script:Credential"
        $QueryCredential      = "-Credential $script:Credential"
    }
    else {
        $QueryCredentialParam = $null
        $QueryCredential      = $null        
    }
$QueryJob= @"
    Start-Job -Name "PoSh-EasyWin: `$(`$CollectionName) -- `$(`$TargetComputer)" -ScriptBlock {
        param(`$DirectoriesToSearch, `$FilesToSearch, `$TargetComputer, `$DirectoryPath, `$Filename, `$MaximumDepth, `$script:IndividualHostResults, `$CollectionName $QueryCredentialParam)
        [System.Threading.Thread]::CurrentThread.Priority = 'High'
        ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'High'

        `$FilesFoundList = @()
        foreach (`$DirectoryPath in `$DirectoriesToSearch) {
            foreach (`$Filename in `$FilesToSearch) {
                `$FilesFound = Invoke-Command -ComputerName `$TargetComputer $QueryCredential -ScriptBlock {
                    param(`$DirectoryPath, `$Filename, `$MaximumDepth, `$TargetComputer)

                $GetChildItemDepth

                Get-ChildItemDepth -Path `$DirectoryPath -Depth `$MaximumDepth | Where-Object { (`$_.Name -match "`$Filename") }
                } -ArgumentList @(`$DirectoryPath, `$Filename, `$MaximumDepth, `$TargetComputer)
                    
                `$FilesFoundList += `$FilesFound | Select-Object -Property @{n='PSComputerName';e={`$TargetComputer}}, Mode, Length, Name, Extension, Attributes, FullName, CreationTime, LastWriteTime, LastAccessTime, BaseName, Directory, PSIsContainer
            }
        }
        `$FilesFoundList
    } -ArgumentList @(`$DirectoriesToSearch, `$FilesToSearch, `$TargetComputer, `$DirectoryPath, `$Filename, `$MaximumDepth, `$script:IndividualHostResults, `$CollectionName $QueryCredentialParam)
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
