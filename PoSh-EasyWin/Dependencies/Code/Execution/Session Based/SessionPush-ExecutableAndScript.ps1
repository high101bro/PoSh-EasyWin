$CollectionCommandStartTime = Get-Date
$CollectionName = "Executable and Script"
$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Executing: $CollectionName")
$ResultsListBox.Items.Insert(1,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")
$PoShEasyWin.Refresh()

$script:ProgressBarEndpointsProgressBar.Value = 0

$TargetFolder                 = $script:ExeScriptDestinationDirectoryTextBox.text
$ExeScriptSelectDirOrFilePath = $script:ExeScriptSelectDirOrFilePath
$ExeScriptSelectScriptPath    = $script:ExeScriptSelectScriptPath


if ($ExeScriptScriptOnlyCheckbox.checked -eq $false) {
    if ($ExeScriptSelectDirRadioButton.checked){
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "[+] Copying the directory '$($ExeScriptSelectExecutableTextBox.Text)' and its contents to:"
        $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Copying the directory '$($ExeScriptSelectExecutableTextBox.Text)' and its contents to:")
        $PoShEasyWin.Refresh()        
    }
    elseif ($ExeScriptSelectFileRadioButton.checked){
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "[+] Copying the file '$($ExeScriptSelectExecutableTextBox.Text)' to:"
        $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Copying the file '$($ExeScriptSelectExecutableTextBox.Text)' to:")
        $PoShEasyWin.Refresh()        
    }

    foreach ($Session in $PSSession) {
        try { 
            if ($ExeScriptSelectDirRadioButton.checked -eq $true) {
                Copy-Item -Path $ExeScriptSelectDirOrFilePath -Destination "$TargetFolder" -Recurse -ToSession $Session -Force -ErrorAction Stop 
                $ResultsListBox.Items.Insert(3,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))      $($Session.ComputerName)")
                Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "Copy-Item -Path $ExeScriptSelectDirOrFilePath -Destination $TargetFolder -Recurse -ToSession $Session -Force -ErrorAction Stop"            
            }
            elseif ($ExeScriptSelectFileRadioButton.checked -eq $true) {
                Copy-Item -Path $ExeScriptSelectDirOrFilePath -Destination "$TargetFolder" -ToSession $Session -Force -ErrorAction Stop 
                $ResultsListBox.Items.Insert(3,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))      $($Session.ComputerName)")
                Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "Copy-Item -Path $ExeScriptSelectDirOrFilePath -Destination $TargetFolder -ToSession $Session -Force -ErrorAction Stop"    
            }
            $PoShEasyWin.Refresh()

            $script:ProgressBarEndpointsProgressBar.Value += 1
            $PoShEasyWin.Refresh()
        }
        catch { 
            $ResultsListBox.Items.Insert(4,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Copy Error:  $($_.Exception)")
            Create-LogEntry -LogFile $LogFile -TargetComputer "[!] Copy Error: $($_.Exception)"
            $PoShEasyWin.Refresh()
            break
        }
    }
}
$ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Executing the '$($ExeScriptSelectScriptTextBox.text)' script on:")
Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "[!] Executing the '$($ExeScriptSelectScriptTextBox.text)' script on:"
$PoShEasyWin.Refresh()

$script:ProgressBarEndpointsProgressBar.Value = 0

#$UserSpecifiedScriptContents = Get-Content $ExeScriptSelectScriptPath
foreach ($Session in $PSSession) {
    try {
        try {
            Invoke-Command -FilePath $ExeScriptSelectScriptPath -Session $Session  
        }
        catch{}
        $ResultsListBox.Items.Insert(3,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))      $($Session.ComputerName)")
        Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "Invoke-Command -FilePath $ExeScriptSelectScriptPath -Session $Session" 
        $PoShEasyWin.Refresh()
    }
    catch { 
        $ResultsListBox.Items.Insert(3,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Execution Error:  $($_.Exception)")
        Create-LogEntry -LogFile $LogFile -TargetComputer "[!] Execution Error: $($_.Exception)"
        $PoShEasyWin.Refresh()
        break
    }
    $script:ProgressBarEndpointsProgressBar.Value = ($PSSession.ComputerName).Count
}
#>
$ResultsListBox.Items.RemoveAt(1)
$ResultsListBox.Items.Insert(1,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  [$(New-TimeSpan -Start $CollectionCommandStartTime -End (Get-Date))]  $CollectionName")
$PoShEasyWin.Refresh()

$script:ProgressBarQueriesProgressBar.Value += 1
$PoShEasyWin.Refresh()
Start-Sleep -match 500

