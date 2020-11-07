$CollectionName = "Directory Listing"
$ExecutionStartTime = Get-Date

$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Query: $CollectionName")
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")

foreach ($TargetComputer in $script:ComputerList) {
    Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $script:CollectedDataTimeStampDirectory `
                            -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                            -TargetComputer $TargetComputer
    Create-LogEntry -TargetComputer $TargetComputer  -LogFile $LogFile -Message $CollectionName

    $DirectoryPath = $FileSearchDirectoryListingTextbox.Text
    $MaximumDepth  = $FileSearchDirectoryListingMaxDepthTextbox.text

    if ($ComputerListProvideCredentialsCheckBox.Checked) {
        if (!$script:Credential) { $script:Credential = Get-Credential }
        Invoke-Command -ScriptBlock {
            param($DirectoryPath,$MaximumDepth,$GetChildItemDepth)
            function Get-DirectoryListing {
                param($DirectoryPath,$MaximumDepth)
                if ([int]$MaximumDepth -gt 0) {
                    Invoke-Expression $GetChildItemDepth

                    # Older operating systems don't support the -depth parameter, needed to create a function to do so for backwards compatability
                    #Get-ChildItem -Path $DirectoryPath -Depth $MaximumDepth

                    Get-ChildItemDepth -Path $DirectoryPath -Depth $MaximumDepth `
                    | Select-Object PSComputerName, Mode, Length, Name, Extension, Attributes, FullName, CreationTime, LastWriteTime, LastAccessTime, BaseName, Directory, PSIsContainer
                }
                else {
                    Get-ChildItem -Path $DirectoryPath -Force -ErrorAction SilentlyContinue `
                    | Select-Object PSComputerName, Mode, Length, Name, Extension, Attributes, FullName, CreationTime, LastWriteTime, LastAccessTime, BaseName, Directory, PSIsContainer
                }
            }
            Get-DirectoryListing -DirectoryPath $DirectoryPath -MaximumDepth $MaximumDepth

        } `
        -ArgumentList $DirectoryPath,$MaximumDepth,$GetChildItemDepth `
        -ComputerName $TargetComputer `
        -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
        -Credential $script:Credential
    }
    else {
        Invoke-Command -ScriptBlock {
            param($DirectoryPath,$MaximumDepth,$GetChildItemDepth)
            function Get-DirectoryListing {
                param($DirectoryPath,$MaximumDepth)
                if ([int]$MaximumDepth -gt 0) {
                    Invoke-Expression $GetChildItemDepth

                    # Older operating systems don't support the -depth parameter, needed to create a function to do so for backwards compatability
                    #Get-ChildItem -Path $DirectoryPath -Depth $MaximumDepth

                    Get-ChildItemDepth -Path $DirectoryPath -Depth $MaximumDepth `
                    | Select-Object PSComputerName, Mode, Length, Name, Extension, Attributes, FullName, CreationTime, LastWriteTime, LastAccessTime, BaseName, Directory, PSIsContainer
                }
                else {
                    Get-ChildItem -Path $DirectoryPath -Force -ErrorAction SilentlyContinue `
                    | Select-Object PSComputerName, Mode, Length, Name, Extension, Attributes, FullName, CreationTime, LastWriteTime, LastAccessTime, BaseName, Directory, PSIsContainer
                }
            }
            Get-DirectoryListing -DirectoryPath $DirectoryPath -MaximumDepth $MaximumDepth

        } `
        -ArgumentList $DirectoryPath,$MaximumDepth,$GetChildItemDepth `
        -ComputerName $TargetComputer `
        -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"
    }
}

Monitor-Jobs -CollectionName $CollectionName -MonitorMode
#Commented out because the above -MonitorMode implementation doesn't save files individually
#Post-MonitorJobs -CollectionName $CollectionName -CollectionCommandStartTime $ExecutionStartTime

$CollectionCommandEndTime  = Get-Date
$CollectionCommandDiffTime = New-TimeSpan -Start $ExecutionStartTime -End $CollectionCommandEndTime
$ResultsListBox.Items.RemoveAt(0)
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $CollectionName")


