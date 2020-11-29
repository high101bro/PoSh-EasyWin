$ExecutionStartTime = Get-Date
$CollectionName = "Executable and Script"
$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Executing: $CollectionName")
$ResultsListBox.Items.Insert(1,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")
$PoShEasyWin.Refresh()

$script:ProgressBarEndpointsProgressBar.Value = 0

$TargetFolder                 = [string]($script:ExeScriptDestinationDirectoryTextBox.text).substring(3)
$ExeScriptSelectDirOrFilePath = $script:ExeScriptSelectDirOrFilePath
$ExeScriptSelectScriptPath    = $script:ExeScriptSelectScriptPath
$AdminShare                   = 'c$'

function Conduct-ExecutableAndScript {
    param($ExeScriptSelectScript,$ExeScriptScriptOnlyCheckbox,$ExeScriptSelectDirRadioButton,$ExeScriptSelectFileRadioButton,$ExeScriptSelectDirOrFilePath,$TargetComputer,$AdminShare,$TargetFolder)
    
    if ($ExeScriptScriptOnlyCheckbox.checked -eq $false) {
        if ($ExeScriptSelectDirRadioButton.checked -eq $true) {
            Copy-Item -Path $ExeScriptSelectDirOrFilePath -Destination "\\$TargetComputer\$AdminShare\$TargetFolder" -Recurse -Force
        }
        elseif ($ExeScriptSelectFileRadioButton.checked -eq $true) {
            Copy-Item -Path $ExeScriptSelectDirOrFilePath -Destination "\\$TargetComputer\$AdminShare\$TargetFolder" -Force
        }
    }

    Invoke-Expression $ExeScriptSelectScript
}


foreach ($TargetComputer in $script:ComputerList) {
    if ($ComputerListProvideCredentialsCheckBox.Checked) {
        if (!$script:Credential) { Create-NewCredentials }

        $ExeScriptSelectScript = Get-Content $ExeScriptSelectScriptPath
        Invoke-Command -ScriptBlock ${function:Conduct-ExecutableAndScript} `
        -ArgumentList @($ExeScriptSelectScript,$ExeScriptScriptOnlyCheckbox,$ExeScriptSelectDirRadioButton,$ExeScriptSelectFileRadioButton,$ExeScriptSelectDirOrFilePath,$TargetComputer,$AdminShare,$TargetFolder) `
        -ComputerName $TargetComputer `
        -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
        -Credential $script:Credential

        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `${function:Conduct-ExecutableAndScript} -ArgumentList @(`$ExeScriptSelectScriptPath,`$ExeScriptScriptOnlyCheckbox,`$ExeScriptSelectDirRadioButton,`$ExeScriptSelectFileRadioButton,`$ExeScriptSelectDirOrFilePath,`$TargetComputer,`$AdminShare,`$TargetFolder) -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)' -Credential `$script:Credential"
    }
    else {
        $ExeScriptSelectScript = Get-Content $ExeScriptSelectScriptPath
        Invoke-Command -ScriptBlock ${function:Conduct-ExecutableAndScript} `
        -ArgumentList @($ExeScriptSelectScript,$ExeScriptScriptOnlyCheckbox,$ExeScriptSelectDirRadioButton,$ExeScriptSelectFileRadioButton,$ExeScriptSelectDirOrFilePath,$TargetComputer,$AdminShare,$TargetFolder) `
        -ComputerName $TargetComputer `
        -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"

        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `${function:Conduct-ExecutableAndScript} -ArgumentList @(`$ExeScriptSelectScriptPath,`$ExeScriptScriptOnlyCheckbox,`$ExeScriptSelectDirRadioButton,`$ExeScriptSelectFileRadioButton,`$ExeScriptSelectDirOrFilePath,`$TargetComputer,`$AdminShare,`$TargetFolder) -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)'"
    }
}
Monitor-Jobs -CollectionName $CollectionName -MonitorMode

<# DEPRECATED
foreach ($TargetComputer in $script:ComputerList) {
    if ($ComputerListProvideCredentialsCheckBox.Checked) {
        if (!$script:Credential) { Create-NewCredentials }
        $Session = New-PSSession -ComputerName $TargetComputer -Name $TargetComputer -Credential $script:Credential
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "[+] New-PSSession -ComputerName $TargetComputer -Credential `$script:Credential"
        $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Creating Session with $TargetComputer")
        }
    else {
        $Session = New-PSSession -ComputerName $TargetComputer -Name $TargetComputer
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "[+] Creating Session with $TargetComputer"
        $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Creating Session with $TargetComputer")
    }


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


        try {
            if ($ExeScriptSelectDirRadioButton.checked -eq $true) {
                Copy-Item -Path $ExeScriptSelectDirOrFilePath -Destination "\\$TargetComputer\$AdminShare\$TargetFolder" -Recurse -Force -ErrorAction Stop

                $ResultsListBox.Items.Insert(3,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))      $($Session.ComputerName)")
                Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "Copy-Item -Path $ExeScriptSelectDirOrFilePath -Destination "\\$TargetComputer\$AdminShare\$TargetFolder" -Recurse -Force -ErrorAction Stop"
            }
            elseif ($ExeScriptSelectFileRadioButton.checked -eq $true) {
                Copy-Item -Path $ExeScriptSelectDirOrFilePath -Destination "\\$TargetComputer\$AdminShare\$TargetFolder" -Force -ErrorAction Stop

                $ResultsListBox.Items.Insert(3,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))      $($Session.ComputerName)")
                Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "Copy-Item -Path $ExeScriptSelectDirOrFilePath -Destination "\\$TargetComputer\$AdminShare\$TargetFolder" -Force -ErrorAction Stop"
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
    $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Executing the '$($ExeScriptSelectScriptTextBox.text)' script on:")
    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "[!] Executing the '$($ExeScriptSelectScriptTextBox.text)' script on:"
    $PoShEasyWin.Refresh()

    $script:ProgressBarEndpointsProgressBar.Value = 0

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

    Get-PSSession -Name $TargetComputer | Remove-PSSession
    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "[+] Removing Session with $TargetComputer"
    $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Removing Session with $TargetComputer")
}
DEPRECATED #>
$ResultsListBox.Items.RemoveAt(1)
$ResultsListBox.Items.Insert(1,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  [$(New-TimeSpan -Start $ExecutionStartTime -End (Get-Date))]  $CollectionName")
$PoShEasyWin.Refresh()

$script:ProgressBarQueriesProgressBar.Value += 1
$PoShEasyWin.Refresh()
Start-Sleep -match 500



