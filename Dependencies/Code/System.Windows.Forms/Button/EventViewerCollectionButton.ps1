$EventViewerCollectionButtonAdd_Click = {
    $InformationTabControl.SelectedTab = $Section3ResultsTab
    #Create-TreeViewCheckBoxArray -Endpoint
    Generate-ComputerList

    if ($script:ComputerListProvideCredentialsCheckBox.Checked) { $Username = $script:Credential.UserName}
    else {$Username = $PoShEasyWinAccountLaunch }

    if ($script:ComputerListEndpointNameToolStripLabel.text) {
        $VerifyAction = Verify-Action -Title "Verification: Event Viewer" -Question "Connecting Account:  $Username`n`nAttempt to collect the Event Viewer data on the following?" -Computer $($script:ComputerListEndpointNameToolStripLabel.text)
        if ($script:ComputerListUseDNSCheckbox.checked) { 
            $script:ComputerTreeViewSelected = $script:ComputerListEndpointNameToolStripLabel.text 
        }
        else {
            [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
            foreach ($root in $AllTreeViewNodes) {
                foreach ($Category in $root.Nodes) {
                    foreach ($Entry in $Category.nodes) {
                        if ($Entry.Text -eq $script:ComputerListEndpointNameToolStripLabel.text) {
                            foreach ($Metadata in $Entry.nodes) {
                                if ($Metadata.Name -eq 'IPv4Address') {
                                    $script:ComputerTreeViewSelected = $Metadata.text
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    elseif (-not $script:ComputerListEndpointNameToolStripLabel.text) {
        [System.Windows.Forms.Messagebox]::Show('Left click an endpoint node to select it, then right click to access the context menu and select Event Viewer.','Event Viewer')
    }

    if ($VerifyAction) {
        $InformationTabControl.SelectedTab = $Section3ResultsTab

        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Event Viewer:  $($script:ComputerTreeViewSelected)")

        if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
            if (!$script:Credential) { Create-NewCredentials }

            $Session = New-PSSession -ComputerName $script:ComputerTreeViewSelected -Credential $script:Credential
            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "New-PSSession -ComputerName $script:ComputerTreeViewSelected -Credential $script:Credential"
        }
        else {
            $Session = New-PSSession -ComputerName $script:ComputerTreeViewSelected
            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "New-PSSession -ComputerName $script:ComputerTreeViewSelected"
        }
            
        $EventLogSelectionLogFileName = $null
        $EventLogSelectionLogFileName = (Invoke-Command -ScriptBlock { 
            # Method 1: Didn't list all event logs, like sysmon
            # Get-WmiObject -Class Win32_NTEventlogFile 

            # Method 2 - Lists all available logs, the script queries for addtional log information
            $AllEventLogNames = wevtutil enum-logs
            $EventLogDetails = @()
            Foreach ($LogName in $AllEventLogNames) {
                $EventLogMetadata = wevtutil get-log $LogName
            
                $EventLogObject = [pscustomobject]@{}
            
                ForEach ($line in $EventLogMetadata){
                    $Name  = $line.split(':').trim()[0]
                    $Value = $line.split(':').trim()[1]
                    if ($Value) {
                        $EventLogObject | Add-Member -MemberType NoteProperty -Name $Name -Value $Value
                    }
                }
                $EventLogDetails += $EventLogObject
            }
            $EventLogDetails `
            | Select-Object -Property @{n='Name';e={$_.Name}}, @{n='Enabled';e={$_.Enabled}}, @{n='Type';e={$_.Type}}, @{n='OwningPublisher';e={$_.OwningPublisher}}, @{n='Isolation';e={$_.Isolation}}, @{n='LogFileName';e={$_.LogFileName}}, @{n='MaxSize';e={$_.MaxSize}}, @{n='FileMax';e={$_.FileMax}}, @{n='Retention';e={$_.Retention}}, @{n='AutoBackup';e={$_.AutoBackup}} `
            | Sort-Object -Property @{e="Enabled";Descending=$True}, @{e="Name";Descending=$False}
        } `
        -Session $Session `
        | Out-GridView -Title 'Event Log Selection' -OutputMode 'Single').Name
        #| Out-GridView -Title 'Event Log Selection' -OutputMode 'Single').LogFileName

        if ($EventLogSelectionLogFileName) {
            $EventLogSelectionLogFileSaveName = $EventLogSelectionLogFileName.replace('/','-')

            # Clears localhost previously saved results... these results appear automatically when viewing saved .evtx logs
            Get-ChildItem -Path "$env:ProgramData\Microsoft\Event Viewer\ExternalLogs" | Remove-Item -Force

            $EventLogPullDateTime = (Get-Date).ToString('yyyy-MM-dd HH.mm.ss')
            New-Item -Type Directory -Path $script:CollectionSavedDirectoryTextBox.Text -ErrorAction SilentlyContinue
            $EventLogSaveName = "$($script:CollectionSavedDirectoryTextBox.Text)\$($script:ComputerTreeViewSelected) ($($EventLogPullDateTime)) $($EventLogSelectionLogFileSaveName).evtx"

            Invoke-Command -ScriptBlock { 
                param(
                    $EventLogSelectionLogFileName,
                    $EventLogSelectionLogFileSaveName,
                    $EventLogPullDateTime
                )
                # Method 1: Didn't list all event logs, like sysmon
                #(Get-WmiObject -Class Win32_NTEventlogFile | Where-Object { $_.LogFileName -eq $EventLogSelectionLogFileName }).BackupEventlog("c:\Windows\Temp\$EventLogSelectionLogFileSaveName ($EventLogPullDateTime).evtx")

                # Method 2 - Lists all available logs
                wevtutil epl $EventLogSelectionLogFileName "c:\Windows\Temp\$EventLogSelectionLogFileSaveName ($EventLogPullDateTime).evtx"

            } `
            -ArgumentList @($EventLogSelectionLogFileName, $EventLogSelectionLogFileSaveName, $EventLogPullDateTime) `
            -Session $Session

            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { (Get-WmiObject -Class Win32_NTEventlogFile | Where-Object { `$_.LogFileName -eq $EventLogSelectionLogFileName }).BackupEventlog('c:\Windows\Temp\$EventLogSelectionLogFileSaveName ($EventLogPullDateTime).evtx') } -FromSession `$Session"

            Copy-Item -Path "c:\Windows\Temp\$EventLogSelectionLogFileSaveName ($EventLogPullDateTime).evtx" -Destination "$EventLogSaveName" -FromSession $Session
            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Copy-Item -Path 'c:\Windows\Temp\$EventLogSelectionLogFileSaveName ($EventLogPullDateTime).evtx' -Destination "$EventLogSaveName" -FromSession `$Session"

            Invoke-Command -ScriptBlock { 
                param(
                    $EventLogSelectionLogFileName,
                    $EventLogSelectionLogFileSaveName,
                    $EventLogPullDateTime
                )
                Remove-Item "c:\Windows\Temp\$EventLogSelectionLogFileSaveName ($EventLogPullDateTime).evtx" -Force
            } `
            -ArgumentList @($EventLogSelectionLogFileName, $EventLogSelectionLogFileSaveName, $EventLogPullDateTime) `
            -Session $Session

            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { Remove-Item 'c:\Windows\Temp\$EventLogSelectionLogFileSaveName ($EventLogPullDateTime).evtx' -Force } -FromSession `$Session"

            # Opens results with Windows Event Viewer
            if (Verify-Action -Title 'Windows Event Viewer' -Question "View the following Event Logs with Windows Event Viewer?`n`n$EventLogSelectionLogFileName") {
                eventvwr -l:"$EventLogSaveName"
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "eventvwr -l:'$EventLogSaveName'"
            }

            # Prompts to open .evtx files with chainsaw.exe by F-Secure Countercept
            if (Verify-Action -Title 'Event Logs Post-Processing' -Question "Process the collected event logs with ChainSaw by F-Secure Countercept?") {
                Invoke-Expression "'$Dependencies\Executables\chainsaw\chainsaw.exe' hunt '$EventLogSaveName' --rules '$Dependencies\Executables\chainsaw\sigma_rules\' --mapping '$Dependencies\Executables\chainsaw\mapping_files\sigma-mapping.yml' --full --lateral-all --csv"
                $EvtxDirectory = Get-ChildItem "$Dependencies\Executables\chainsaw\chainsaw_*" | Select-Object -Last 1
                $EvtxFile = $null
                Foreach ($EvtxFile in $(Get-ChildItem $EvtxDirectory)) {
                    Import-Csv "$($EvtxFile.FullPath)" | Out-GridView -Title "Chainsaw by F-Secure Countercept - $EvtxFile"
                }
            }
        }
        $Session | Remove-PSSession

        if ($script:RollCredentialsState -and $script:ComputerListProvideCredentialsCheckBox.checked) {
            Start-Sleep -Seconds 3
            Generate-NewRollingPassword
        }
    }
    else {
        [system.media.systemsounds]::Exclamation.play()
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Event Viewer:  Cancelled")
    }
}