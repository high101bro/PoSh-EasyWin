$CollectionCommandStartTime = Get-Date
$CollectionName = "File Search"
$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Executing: $CollectionName")
$ResultsListBox.Items.Insert(1,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")
$PoShEasyWin.Refresh()

$script:ProgressBarEndpointsProgressBar.Value   = 0

$OutputFilePath      = "$($script:CollectionSavedDirectoryTextBox.Text)\File Name Search"
#$FileHashSelection   = $FileSearchSelectFileHashCheckbox.Text
$DirectoriesToSearch = ($FileSearchFileSearchDirectoryRichTextbox.Text).split("`r`n")
$FilesToSearch       = ($FileSearchFileSearchFileRichTextbox.Text).split("`r`n")
$MaximumDepth        = $FileSearchFileSearchMaxDepthTextbox.text

function FileSearch {
    param($DirectoriesToSearch,$FilesToSearch,$MaximumDepth,$GetChildItemDepth)
    if ([int]$MaximumDepth -gt 0) {
        Invoke-Expression $GetChildItemDepth
        
        # Older operating systems don't support the -depth parameter, needed to create a function to do so for backwards compatability
        #Get-ChildItem -Path $DirectoryPath -Depth $MaximumDepth
        
        $AllFiles = Get-ChildItemDepth -Path $DirectoriesToSearch -Depth $MaximumDepth
    }
    else {
        $AllFiles = Get-ChildItem -Path $DirectoriesToSearch -Force -ErrorAction SilentlyContinue    
    }

    $foundlist = @()
    foreach ($File in $AllFiles){
        foreach ($item in $FilesToSearch) {
            if ($File.name -match $item){
                if ($File.FullName -notin $FoundList) { $foundlist += $File }
            }
        }
    }
    return $FoundList
}

Invoke-Command -ScriptBlock ${function:FileSearch} -ArgumentList $DirectoriesToSearch,$FilesToSearch,$MaximumDepth,$GetChildItemDepth -Session $PSSession | Select-Object PSComputerName, Mode, Length, Name, Extension, Attributes, FullName, CreationTime, LastWriteTime, LastAccessTime, BaseName, Directory, PSIsContainer `
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
