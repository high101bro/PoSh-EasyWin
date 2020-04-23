$CollectionCommandStartTime = Get-Date
$CollectionName = "Directory Listing Query"
$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Executing: $CollectionName")
$ResultsListBox.Items.Insert(1,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")
$PoShEasyWin.Refresh()

$script:ProgressBarEndpointsProgressBar.Value = 0

$OutputFilePath = "$($script:CollectionSavedDirectoryTextBox.Text)\Directory Listing"
$DirectoryPath  = $FileSearchDirectoryListingTextbox.Text
$MaximumDepth   = $FileSearchDirectoryListingMaxDepthTextbox.text

Invoke-Command -ScriptBlock {
    param($DirectoryPath,$MaximumDepth,$GetChildItemDepth)
    function Get-DirectoryListing {
        param($DirectoryPath,$MaximumDepth)
        if ([int]$MaximumDepth -gt 0) {
            Invoke-Expression $GetChildItemDepth
            
            # Older operating systems don't support the -depth parameter, needed to create a function to do so for backwards compatability
            #Get-ChildItem -Path $DirectoryPath -Depth $MaximumDepth
            
            Get-ChildItemDepth -Path $DirectoryPath -Depth $MaximumDepth
        }
        else {
            Get-ChildItem -Path $DirectoryPath -Force -ErrorAction SilentlyContinue
        }
    }
    Get-DirectoryListing -DirectoryPath $DirectoryPath -MaximumDepth $MaximumDepth

} -ArgumentList $DirectoryPath,$MaximumDepth,$GetChildItemDepth -Session $PSSession | Select-Object PSComputerName, Mode, Length, Name, Extension, Attributes, FullName, CreationTime, LastWriteTime, LastAccessTime, BaseName, Directory, PSIsContainer `
| Set-Variable SessionData
$SessionData | Export-Csv    -Path "$OutputFilePath.csv" -NoTypeInformation -Force
$SessionData | Export-Clixml -Path "$OutputFilePath.xml" -Force
Remove-Variable -Name SessionData -Force

$ResultsListBox.Items.RemoveAt(1)
$ResultsListBox.Items.Insert(1,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  [$(New-TimeSpan -Start $CollectionCommandStartTime -End (Get-Date))]  $CollectionName")
$PoShEasyWin.Refresh()

$script:ProgressBarQueriesProgressBar.Value   += 1
$script:ProgressBarEndpointsProgressBar.Value = ($PSSession.ComputerName).Count
$PoShEasyWin.Refresh()
Start-Sleep -match 500

