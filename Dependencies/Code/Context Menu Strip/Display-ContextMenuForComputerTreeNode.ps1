####################################################################################################
# ScriptBlocks
####################################################################################################

$EventViewerConnectionButtonAdd_Click = {
    $InformationTabControl.SelectedTab = $Section3ResultsTab
    #Create-TreeViewCheckBoxArray -Endpoint
    Generate-ComputerList

    if ($script:ComputerListProvideCredentialsCheckBox.Checked) { $Username = $script:Credential.UserName}
    else {$Username = $PoShEasyWinAccountLaunch }

    if ($script:ComputerListEndpointNameToolStripLabel.text) {
        $VerifyAction = Verify-Action -Title "Verification: Event Viewer" -Question "Connecting Account:  $Username`n`nAttempt to launch the Event Viewer on the following?" -Computer $($script:ComputerListEndpointNameToolStripLabel.text)
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
            if (!$script:Credential) { Set-NewCredential }

            $ResultsListBox.Items.Add("start-process powershell.exe -ArgumentList '-WindowStyle Hidden -Command Show-EventLog -ComputerName $script:ComputerTreeViewSelected' -Credential <Credential> -WindowStyle Hidden")
            #start-process -FilePath 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -ArgumentList "-WindowStyle Hidden -Command Show-eventLog -ComputerName $script:ComputerTreeViewSelected" -Credential $script:Credential -WindowStyle Hidden
            [System.Windows.Forms.MessageBox]::Show("If the Event Viewer doesn't display, try re-launching PoSh-EasyWin itself with domain credentials and wihtout checking 'Specify Credentials'. This method would require the localhost to be on the domain.",'Show-EventLog')
            start-process powershell.exe -ArgumentList "-WindowStyle Hidden -Command Show-EventLog -ComputerName $script:ComputerTreeViewSelected" -Credential $script:Credential -WindowStyle Hidden
        }
        else {
            $ResultsListBox.Items.Add("start-process powershell.exe -ArgumentList '-WindowStyle Hidden -Command Show-EventLog -ComputerName $script:ComputerTreeViewSelected' -WindowStyle Hidden")
            [System.Windows.Forms.MessageBox]::Show("If the Event Viewer doesn't display, try re-launching PoSh-EasyWin itself with domain credentials and wihtout checking 'Specify Credentials'. This method would require the localhost to be on the domain.",'Show-EventLog')
            start-process powershell.exe -ArgumentList "-WindowStyle Hidden -Command Show-EventLog -ComputerName $script:ComputerTreeViewSelected" -WindowStyle Hidden
        }
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "start-process powershell.exe -ArgumentList '-WindowStyle Hidden -Command Show-EventLog -ComputerName $script:ComputerTreeViewSelected' -WindowStyle Hidden"

        if ($script:RollCredentialsState -and $script:ComputerListProvideCredentialsCheckBox.checked) {
            Start-Sleep -Seconds 3
            Set-NewRollingPassword
        }
    }
    else {
        [system.media.systemsounds]::Exclamation.play()
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Event Viewer:  Cancelled")
    }
}


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
            if (!$script:Credential) { Set-NewCredential }

            $Session = New-PSSession -ComputerName $script:ComputerTreeViewSelected -Credential $script:Credential
            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "New-PSSession -ComputerName $script:ComputerTreeViewSelected -Credential $script:Credential"
        }
        else {
            $Session = New-PSSession -ComputerName $script:ComputerTreeViewSelected
            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "New-PSSession -ComputerName $script:ComputerTreeViewSelected"
        }
            
        $EventLogSelectionLogFileName = $null

        if ($script:OptionEventViewerCollectVerboseCheckBox.checked -eq $false) {
            $EventLogSelectionLogFileName = Invoke-Command -ScriptBlock { 
                # Method 1: Didn't list all event logs, like sysmon
                # Get-WmiObject -Class Win32_NTEventlogFile 
    
                # Method 2 - Faster, but no added metadata
                wevtutil enum-logs
            } `
            -Session $Session `
            | Out-GridView -Title 'Event Log Selection' -OutputMode 'Single'    
        }
        elseif ($script:OptionEventViewerCollectVerboseCheckBox.checked -eq $true) {
            $EventLogSelectionLogFileName = (Invoke-Command -ScriptBlock {     
                # Method 3 - Slower, but adds metadata. Lists all available logs, the script queries for addtional log information
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
        }

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
                wevtutil export-log $EventLogSelectionLogFileName "c:\Windows\Temp\$EventLogSelectionLogFileSaveName ($EventLogPullDateTime).evtx"

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
                $SaveLocation = $script:CollectionSavedDirectoryTextBox.Text
                $command = @"
Start-Process 'PowerShell' -ArgumentList '-NoProfile',
'-ExecutionPolicy ByPass',
{ New-Item -Type Directory '$SaveLocation' -Force | Out-Null; },
{ Set-Location '$SaveLocation' | Out-Null; },
{ "& '$Dependencies\Executables\chainsaw\chainsaw.exe' hunt '$EventLogSaveName' --rules '$Dependencies\Executables\chainsaw\sigma_rules\' --mapping '$Dependencies\Executables\chainsaw\mapping_files\sigma-mapping.yml' --full --lateral-all --csv"; },
{ Foreach ( `$EvtxFile in `$(Get-ChildItem '$SaveLocation\chainsaw_*' -Recurse | Where-Object {`$_.Name -like '*.csv'}) ) { `$FullName = iex '`$EvtxFile.FullName'; `$BaseName = iex '`$EvtxFile.BaseName'; `$BaseName = 'ChainSaw by F-Secure Countercept:  ' + '"'+ `$BaseName + '"'; Import-Csv "`$FullName" | Out-GridView -Title `$BaseName -Wait }; }
"@
#'-NoExit',
#{ `$ErrorActionPreference = 'SilentlyContinue'; },
# { Write-Host "Passing information from PoSh-EasyWin to ChainSaw"; },
# { Write-Host ".\chainsaw.exe' hunt '$EventLogSaveName' --rules '.\sigma_rules\' --mapping '.\mapping_files\sigma-mapping.yml' --full --lateral-all --csv"; },
# { Write-Host ""; },

                Invoke-Expression $command
            }
       }
        $Session | Remove-PSSession

        if ($script:RollCredentialsState -and $script:ComputerListProvideCredentialsCheckBox.checked) {
            Start-Sleep -Seconds 3
            Set-NewRollingPassword
        }
    }
    else {
        [system.media.systemsounds]::Exclamation.play()
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Event Viewer:  Cancelled")
    }
}

$ComputerListSSHButtonAdd_Click = {
    $InformationTabControl.SelectedTab = $Section3ResultsTab
    Create-TreeViewCheckBoxArray -Endpoint
    Generate-ComputerList

    if ($script:ComputerListProvideCredentialsCheckBox.Checked) { $Username = $script:Credential.UserName}
    else {$Username = $PoShEasyWinAccountLaunch }

    if ($script:ComputerListEndpointNameToolStripLabel.text) {
        $VerifyAction = Verify-Action -Title "Verification: SSH" -Question "Connecting Account:  $Username`n`nEnter a SSH session to the following?" -Computer $($script:ComputerListEndpointNameToolStripLabel.text)
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
        [System.Windows.Forms.Messagebox]::Show('Left click an endpoint node to select it, then right click to access the context menu and select SSH.','SSH')
    }

    if ($VerifyAction) {
        # This brings specific tabs to the forefront/front view
        $InformationTabControl.SelectedTab = $Section3ResultsTab

        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("SSH:  $($script:ComputerTreeViewSelected)")
        #Removed For Testing#$ResultsListBox.Items.Clear()
        if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
            if (!$script:Credential) { Set-NewCredential }
            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Credentials Used: $($script:Credential.UserName)"
            $Username = $script:Credential.UserName
            $Password = $script:Credential.GetNetworkCredential().Password

            if ($Username -like '*@*'){
                $User     = $Username.split('@')[0]
                $Domain   = $Username.split('@')[1]
                $Username = "$($Domain)\$($User)"
            }

            $ResultsListBox.Items.Add("kitty-0.74.4.7.exe -ssh '$script:ComputerTreeViewSelected' -l '$Username' -pw 'password'")
            start-process $kitty_ssh_client -ArgumentList @("-ssh",$script:ComputerTreeViewSelected,"-l",$Username,"-pw",$Password)
            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "start-process $kitty_ssh_client -ArgumentList @(`"-ssh`",$script:ComputerTreeViewSelected,`"-l`",$User,`"-pw`",`"Password`")"
        }
        else {
            $ResultsListBox.Items.Add("kitty-0.74.4.7.exe -ssh '$script:ComputerTreeViewSelected' -l '$Username'")
            start-process $kitty_ssh_client -ArgumentList @("-ssh",$script:ComputerTreeViewSelected,"-l",$Username)
            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "start-process $kitty_ssh_client -ArgumentList @(`"-ssh`",$script:ComputerTreeViewSelected,`"-l`",$User)"
        }

        if ($script:RollCredentialsState -and $script:ComputerListProvideCredentialsCheckBox.checked) {
            Start-Sleep -Seconds 3
            Set-NewRollingPassword
        }
    }
    else {
        [system.media.systemsounds]::Exclamation.play()
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("SSH:  Cancelled")
    }
}


$ComputerListRDPButtonAdd_Click = {
    $InformationTabControl.SelectedTab = $Section3ResultsTab
    Create-TreeViewCheckBoxArray -Endpoint
    Generate-ComputerList

    if ($script:ComputerListProvideCredentialsCheckBox.Checked) { $Username = $script:Credential.UserName}
    else {$Username = $PoShEasyWinAccountLaunch }

    if ($script:ComputerListEndpointNameToolStripLabel.text) {
        $VerifyAction = Verify-Action -Title "Verification: Remote Desktop" -Question "Connecting Account:  $Username`n`nOpen a Remote Desktop session to the following?" -Computer $($script:ComputerListEndpointNameToolStripLabel.text)
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
        [System.Windows.Forms.Messagebox]::Show('Left click an endpoint node to select it, then right click to access the context menu and select Remote Desktop.','Remote Desktop')
    }

    if ($VerifyAction) {
        # This brings specific tabs to the forefront/front view
        $InformationTabControl.SelectedTab = $Section3ResultsTab
        if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
            if (!$script:Credential) { Set-NewCredential }

            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Credentials Used: $($script:Credential.UserName)"

            $Username = $null
            $Password = $null
            $Username = $script:Credential.UserName
            $Password = $script:Credential.GetNetworkCredential().Password
            #doesn't store in base64# $Password = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Password))

            # The cmdkey utility helps you manage username and passwords; it allows you to create, delete, and display credentials for the current user
                # cmdkey /list                <-- lists all credentials
                # cmdkey /list:targetname     <-- lists the credentials for a speicific target
                # cmdkey /add:targetname      <-- creates domain credential
                # cmdkey /generic:targetname  <-- creates a generic credential
                # cmdkey /delete:targetname   <-- deletes target credential
            #cmdkey /generic:TERMSRV/$script:ComputerTreeViewSelected /user:$Username /pass:$Password
            cmdkey /delete:"$script:ComputerTreeViewSelected"
            cmdkey /delete /ras

            #doesn't store in base64# cmdkey /generic:$script:ComputerTreeViewSelected /user:"$Username" /pass:"$([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String(`"$Password`")))"

            cmdkey /generic:$script:ComputerTreeViewSelected /user:"$Username" /pass:"$Password"
            mstsc /v:$($script:ComputerTreeViewSelected):3389 /admin /noConsentPrompt /f

            # There seems to be a delay between the credential passing before credentials can be removed locally from cmdkey and them still being needed
            Start-Sleep -Seconds 5
            cmdkey /delete /ras
            cmdkey /delete:"$script:ComputerTreeViewSelected"

            if ($script:RollCredentialsState -and $script:ComputerListProvideCredentialsCheckBox.checked) {
                Start-Sleep -Seconds 3
                Set-NewRollingPassword
            }
        }
        else {
            #ensures no credentials are stored for use
            cmdkey /delete /ras
            cmdkey /delete:"$script:ComputerTreeViewSelected"

            mstsc /v:$($script:ComputerTreeViewSelected):3389 /admin /noConsentPrompt /f
        }

        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Remote Desktop:  $($script:ComputerTreeViewSelected)")
        #Removed For Testing#$ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("mstsc /v:$($script:ComputerTreeViewSelected):3389 /NoConsentPrompt")
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Remote Desktop (RDP): $($script:ComputerTreeViewSelected)"
    }
    else {
        [system.media.systemsounds]::Exclamation.play()
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Remote Desktop:  Cancelled")
    }
}


$ComputerListPSSessionPivotButtonAdd_Click = {

    $InformationTabControl.SelectedTab = $Section3ResultsTab
    Create-TreeViewCheckBoxArray -Endpoint
    Generate-ComputerList
    
    if ($script:ComputerListProvideCredentialsCheckBox.Checked) { $Username = $script:Credential.UserName}
    else {$Username = $PoShEasyWinAccountLaunch }

    if ($script:ComputerListEndpointNameToolStripLabel.text) {
        $VerifyAction = Verify-Action -Title "Verification: PowerShell Session" -Question "Connecting Account:  $Username`n`nEnter a PowerShell BROKEN Session to the following?" -Computer $($script:ComputerListEndpointNameToolStripLabel.text)
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
        [System.Windows.Forms.Messagebox]::Show('Left click an endpoint node to select it, then right click to access the context menu and select PSSession.','PowerShell Session')
    }

    if ($VerifyAction) {
        # This brings specific tabs to the forefront/front view
        $InformationTabControl.SelectedTab = $Section3ResultsTab

        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Pivot-PSSession:  $($script:ComputerTreeViewSelected)")
        #Removed For Testing#$ResultsListBox.Items.Clear()
        if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
            if (-not $script:Credential) { Set-NewCredential }
            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Credentials Used: $($script:Credential.UserName)"
            #$Username = $script:Credential.UserName
            #$Password = $script:Credential.GetNetworkCredential().Password
            #$password = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Password))

            $ResultsListBox.Items.Add("Pivot-PSSession -PivotHost $($script:ComputerListPivotExecutionTextBox.text) -TargetComputer $($script:ComputerTreeViewSelected) -Credential $script:Credential")
            #start-process -FilePath 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -ArgumentList "-noexit -Command Enter-PSSession -ComputerName $($script:ComputerListPivotExecutionTextBox.text) -Credential `$(New-Object PSCredential('$Username'`,`$([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('$Password')) | ConvertTo-SecureString -AsPlainText -Force))); function Pivot-PSSession(`$Id) { while ( `$Command -ne 'Exit' ) {`$Session = Get-PSSession -Id `$id; `$ComputerName = `$Session.ComputerName; Write-Host -NoNewline `"[$($script:ComputerListPivotExecutionTextBox.text) --> `$ComputerName]: Pivot> `"; `$Command = Read-Host; Invoke-Command -Session `$Session -ScriptBlock {param(`$Command) invoke-command {iex `$Command}} -ArgumentList `$Command; }; ; }; Pivot-PSSession -Id (New-PSSession -ComputerName $script:ComputerTreeViewSelected -Credential `$(New-Object PSCredential('$Username'`,`$([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('$Password')) | ConvertTo-SecureString -AsPlainText -Force)))).Id"

            start-process -FilePath 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -ArgumentList "-NoExit -NoProfile -Command & '$Dependencies\Code\Main Body\Pivot-PSSession.ps1' -PivotHost '$($script:ComputerListPivotExecutionTextBox.text)' -TargetComputer '$($script:ComputerTreeViewSelected)' -CredentialXML '$script:SelectedCredentialPath'"

            Start-Sleep -Seconds 3
        }
        else {
            $ResultsListBox.Items.Add("Pivot-PSSession -PivotHost $($script:ComputerListPivotExecutionTextBox.text) -TargetComputer $($script:ComputerTreeViewSelected)")
            start-process -FilePath 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -ArgumentList "-NoExit -NoProfile -Command & '$Dependencies\Code\Main Body\Pivot-PSSession.ps1' -PivotHost '$($script:ComputerListPivotExecutionTextBox.text)' -TargetComputer '$($script:ComputerTreeViewSelected)'"
            Start-Sleep -Seconds 3
        }
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Pivot-PSSession -ComputerName $($script:ComputerTreeViewSelected)"

        if ($script:RollCredentialsState -and $script:ComputerListProvideCredentialsCheckBox.checked) {
            Start-Sleep -Seconds 3
            Set-NewRollingPassword
        }
    }
    else {
        [system.media.systemsounds]::Exclamation.play()
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Pivot-PSSession:  Cancelled")
    }
}


$ComputerListPSSessionButtonAdd_Click = {
    
    $InformationTabControl.SelectedTab = $Section3ResultsTab
    Create-TreeViewCheckBoxArray -Endpoint
    Generate-ComputerList

    if ($script:ComputerListProvideCredentialsCheckBox.Checked) { $Username = $script:Credential.UserName}
    else {$Username = $PoShEasyWinAccountLaunch }

    if ($script:ComputerListEndpointNameToolStripLabel.text) {
        $VerifyAction = Verify-Action -Title "Verification: PowerShell Session" -Question "Connecting Account:  $Username`n`nEnter a PowerShell Session to the following?" -Computer $($script:ComputerListEndpointNameToolStripLabel.text)
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
        [System.Windows.Forms.Messagebox]::Show('Left click an endpoint node to select it, then right click to access the context menu and select PSSession.','PowerShell Session')
    }

    if ($VerifyAction) {
        # This brings specific tabs to the forefront/front view
        $InformationTabControl.SelectedTab = $Section3ResultsTab

        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Enter-PSSession:  $($script:ComputerTreeViewSelected)")
        #Removed For Testing#$ResultsListBox.Items.Clear()
        if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
            if (-not $script:Credential) { Set-NewCredential }
            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Credentials Used: $($script:Credential.UserName)"
            $Username = $script:Credential.UserName
            $Password = $script:Credential.GetNetworkCredential().Password

            $password = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Password))
            #if ($UserName -like '*\*') {
            #    $Name     = $UserName.split('\')[1]
            #    $Domain   = $UserName.split('\')[0]
            #    $UserName = "$Name@$Domain"
            #}

            $ResultsListBox.Items.Add("Enter-PSSession -ComputerName $script:ComputerTreeViewSelected -Credential $script:Credential")
            #start-process -FilePath 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -ArgumentList "-noexit -Command Enter-PSSession -ComputerName $script:ComputerTreeViewSelected -Credential `$(New-Object PSCredential('$Username'`,`$('$Password' | ConvertTo-SecureString -AsPlainText -Force)))"
            start-process -FilePath 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -ArgumentList "-noexit -Command Enter-PSSession -ComputerName $script:ComputerTreeViewSelected -Credential `$(New-Object PSCredential('$Username'`,`$([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('$Password')) | ConvertTo-SecureString -AsPlainText -Force)))"

            Start-Sleep -Seconds 3
        }
        else {
            $ResultsListBox.Items.Add("Enter-PSSession -ComputerName $script:ComputerTreeViewSelected")
            Start-Process PowerShell -ArgumentList "-noexit Enter-PSSession -ComputerName $script:ComputerTreeViewSelected"
            Start-Sleep -Seconds 3
        }
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Enter-PSSession -ComputerName $($script:ComputerTreeViewSelected)"

        if ($script:RollCredentialsState -and $script:ComputerListProvideCredentialsCheckBox.checked) {
            Start-Sleep -Seconds 3
            Set-NewRollingPassword
        }
    }
    else {
        [system.media.systemsounds]::Exclamation.play()
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("PowerShell Session:  Cancelled")
    }
}

$ComputerListPsExecButtonAdd_Click = {
    $InformationTabControl.SelectedTab = $Section3ResultsTab
    Create-TreeViewCheckBoxArray -Endpoint
    Generate-ComputerList

    if ($script:ComputerListProvideCredentialsCheckBox.Checked) { $Username = $script:Credential.UserName}
    else {$Username = $PoShEasyWinAccountLaunch }

    if ($script:ComputerListEndpointNameToolStripLabel.text) {
        $VerifyAction = Verify-Action -Title "Verification: PSExec" -Question "Connecting Account:  $Username`n`nEnter a PSEexec session to the following?" -Computer $($script:ComputerListEndpointNameToolStripLabel.text)
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
        [System.Windows.Forms.Messagebox]::Show('Left click an endpoint node to select it, then right click to access the context menu and select PSExec.','PSExec (Sysinternals)')
    }

    if ($VerifyAction) {
        # This brings specific tabs to the forefront/front view
        $InformationTabControl.SelectedTab = $Section3ResultsTab

        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("PsExec:  $($script:ComputerTreeViewSelected)")
        #Removed For Testing#$ResultsListBox.Items.Clear()
        if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
            if (!$script:Credential) { Set-NewCredential }
            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Credentials Used: $($script:Credential.UserName)"
            $Username = $script:Credential.UserName
            $Password = $script:Credential.GetNetworkCredential().Password

            if ($Username -like '*@*'){
                $User     = $Username.split('@')[0]
                $Domain   = $Username.split('@')[1]
                $Username = "$($Domain)\$($User)"
            }
            $Password = "'$Password'"

            $ResultsListBox.Items.Add("./PsExec.exe -AcceptEULA -NoBanner \\$script:ComputerTreeViewSelected '<domain\username>' -p '<password>' cmd")
            #opens in black terminal# Start-Process PowerShell -WindowStyle Hidden -ArgumentList "Start-Process '$PsExecPath' -ArgumentList '-AcceptEULA -NoBanner \\$script:ComputerTreeViewSelected -u '$Username' -p '$Password' cmd'"
            start-process powershell "-noexit -command $PsExecPath -accepteula -nobanner \\$script:ComputerTreeViewSelected -u $Username -p $Password cmd"
        }
        else {
            $ResultsListBox.Items.Add("./PsExec.exe -AcceptEULA -NoBanner \\$script:ComputerTreeViewSelected cmd")
            #$ResultsListBox.Items.Add("$PsExecPath -AcceptEULA -NoBanner \\$script:ComputerTreeViewSelected cmd")
            #opens in black terminal# Start-Process PowerShell -WindowStyle Hidden -ArgumentList "Start-Process '$PsExecPath' -ArgumentList '-AcceptEULA -NoBanner \\$script:ComputerTreeViewSelected cmd'"
            start-process powershell "-noexit -command $PsExecPath -accepteula -nobanner \\$script:ComputerTreeViewSelected cmd"
        }
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "PsExec: $($script:ComputerTreeViewSelected)"

        if ($script:RollCredentialsState -and $script:ComputerListProvideCredentialsCheckBox.checked) {
            Start-Sleep -Seconds 3
            Set-NewRollingPassword
        }
    }
    else {
        [system.media.systemsounds]::Exclamation.play()
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("PSExec Session:  Cancelled")
    }
}


####################################################################################################
# WinForms
####################################################################################################

function Display-ContextMenuForComputerTreeNode {
    param(
        [switch]$ClickedOnNode,
        [switch]$ClickedOnArea
    )
    # https://info.sapien.com/index.php/guis/gui-controls/spotlight-on-the-contextmenustrip-control

    Create-TreeViewCheckBoxArray -Endpoint

    $script:ComputerListContextMenuStrip = New-Object System.Windows.Forms.ContextMenuStrip -Property @{
        ShowCheckMargin  = $false
        ShowImageMargin  = $true
        ShowItemToolTips = $true
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = 'Black'
        ImageScalingSize = @{ 
            Width  = $FormScale * 15
            Height = $FormScale * 15
        }
        Padding = @{Left=0;Top=0;Right=0;Bottom=0}
    }

    $script:ComputerListEndpointNameToolStripLabel = New-Object System.Windows.Forms.ToolStripMenuItem -Property @{
        Image = [System.Drawing.Image]::FromFile($($EndpointTreeviewImageHashTable["$($script:NodeEndpoint.ImageIndex)"]))
        Text    = "$($Entry.Text)"
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = 'Blue'
        Add_Click = { [System.Windows.Forms.MessageBox]::Show("This is just a heading, select another option","PoSh-EasyWin",'Ok',"Info") }
    }
    $script:ComputerListContextMenuStrip.Items.add($script:ComputerListEndpointNameToolStripLabel)
    if ($Entry.Text -eq $null) {$script:ComputerListEndpointNameToolStripLabel.Text = "Node Not Selected"}

    #$script:ComputerListContextMenuStrip.Items.Add("Import Endpoints")
    # $script:ComputerListEndpointNameToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
    #     Text      = "$($Entry.Text)"
    #     Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
    #     ForeColor = 'Blue'
    #     BackColor = 'lightgray'
    # }
    # $script:ComputerListContextMenuStrip.Items.Add($script:ComputerListEndpointNameToolStripLabel)
    # if ($Entry.Text -eq $null) {$script:ComputerListEndpointNameToolStripLabel.Text = "Node Not Selected"}


    $script:ComputerListContextMenuStrip.Items.Add('-')

    if ($ClickedOnNode) {
        if ($script:ComputerListPivotExecutionCheckbox.checked -eq $false) {

            $script:ComputerListRemoteDesktopToolStripButton = New-Object System.Windows.Forms.ToolStripMenuItem -Property @{
                Image = [System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Remote-Desktop.png")
                Text        = "Remote Desktop"
                ForeColor   = 'Black'
                Add_Click   = $ComputerListRDPButtonAdd_Click
                ToolTipText = "
Establishes a Remote Desktop session with an endpoint.

Uses the native cmd called mstsc.exe (Microsoft Terminal Services Client)

Requires RDP to be entabled within the network or on the host.

Default ports, protocols, and services: 
    TCP|UDP / 3389
    Remote Desktop Protocol (RDP)
    SSL/TLS Encryption: Windows Vista + / Server 2003 +

Command:
    mstsc /v:<endpoints>:3389 /user:USERNAME /pass:PASSWORD /NoConsentPrompt
"           
            }
            $script:ComputerListContextMenuStrip.Items.add($script:ComputerListRemoteDesktopToolStripButton)
        

            $script:ComputerListEnterPSSessionToolStripButton = New-Object System.Windows.Forms.ToolStripMenuItem -Property @{
                Image = [System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\PowerShell.png")
                Text        = "Enter-PSSession"
                ForeColor   = 'Black'
                Add_Click   = $ComputerListPSSessionButtonAdd_Click
                ToolTipText = "
Establishes an interactive Powershell Session with an endpoint.

Normally, conntections with endpoints are authenticated with Active Directory and the hostname.

To use with an IP address, rather than a hostname, the Credential parameter must be used. Also, the endpoint must have the remote computer's IP must be in the local TrustedHosts or be configured for HTTPS transport.

Default ports, protocols, and services: 
    TCP / 47001 - Endpoint Listener
    TCP / 5985 [HTTP]  Windows 7+
    TCP / 5986 [HTTPS] Windows 7+
    TCP / 80   [HTTP]  Windows Vista-
    TCP / 443  [HTTPS] Windows Vista-
    Windows Remote Management (WinRM)
    Regardless of the transport protocol used (HTTP or HTTPS), WinRM always encrypts all PowerShell remoting communication after initial authentication

Command:
    Enter-PSSession -ComputerName <endpoint> -Credential <`$creds>
"
            }
            $script:ComputerListContextMenuStrip.Items.add($script:ComputerListEnterPSSessionToolStripButton)


            $script:ComputerListPSExecToolStripButton = New-Object System.Windows.Forms.ToolStripMenuItem -Property @{
                Image = [System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\PSExec.png")
                Text        = "PSExec (Sysinternals)"
                ForeColor   = 'Black'
                Add_Click   = $ComputerListPsExecButtonAdd_Click
                ToolTipText = "
Establishes an interactive cmd prompt via PSExec.

PsExec.exe is a Windows Sysinternals tool.

This tool is particularly useful when WinRM is disabled or when trying to access an endpoint not joined to a domain.

Depending on the network security policy, PSExec may be prevented from running.

Additionally, many anti-virus scanners or security tools will alert on this as malicious executable, despite it being legitimate.

Default ports, protocols, and services: 
    TCP / 445 
    Server Message Block (SMB)
    PSExec version 2.1+ (released 7 March 2014), encrypts all communication between local and remote systems

Command:
    PsExec.exe -AcceptEULA -NoBanner \\<endpoint> -u <domain\username> -p <password> cmd
"
            }
            $script:ComputerListContextMenuStrip.Items.add($script:ComputerListPSExecToolStripButton)


            $script:ComputerListSSHToolStripButton = New-Object System.Windows.Forms.ToolStripMenuItem -Property @{
                Image = [System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\SSH.png")
                Text        = "SSH (Secure Shell)"
                ForeColor   = 'Black'
                Add_Click   = $ComputerListSSHButtonAdd_Click
                ToolTipText = "
Establishes an interactive secure shell (SSH) with an endpoint.

Useful to access Linux and Windows hosts with SSH enabled.

SSH/OpenSSH is natively available on Windows 10 as up the April 2018 update, it does not support passing credentials automatically.

Uses KiTTY, a better version forked from Plink (PuTTY) that not only has all the same features has but many more.

Plink (PuTTY CLI tool), is an ssh client often used for automation, but has some integration issues with PoSh-EasyWin.

Default ports, protocols, and services: 
    TCP / 22
    Secure Socket Layer/Transport Socket Layer (SSL/TLS)

Command:
    kitty.exe -ssh 'IP/hostname' -l 'username' -pw 'password'
"
            }
            $script:ComputerListContextMenuStrip.Items.add($script:ComputerListSSHToolStripButton)


            $script:ComputerListFileSystemToolStripButton = New-Object System.Windows.Forms.ToolStripMenuItem -Property @{
                Image = [System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\SMBShare.jpg")
                Text        = "Browse File System (SMB)"
                ForeColor   = 'Black'
                Add_Click   = {
                    Create-TreeViewCheckBoxArray -Endpoint
                    Generate-ComputerList

                    if ($script:ComputerListProvideCredentialsCheckBox.Checked) { $Username = $script:Credential.UserName}
                    else {$Username = $PoShEasyWinAccountLaunch }
                                                
                    if ($script:ComputerListEndpointNameToolStripLabel.text) {
                        $VerifyAction = Verify-Action -Title "Verification: Browse File System (PSDrive/SMB)" -Question "Connecting Account:  $Username`n`n`Browse the file system via SMB on the following?" -Computer $($script:ComputerListEndpointNameToolStripLabel.text)
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
                    # elseif (-not $script:ComputerListEndpointNameToolStripLabel.text) {
                    #     [System.Windows.Forms.Messagebox]::Show('Left click an endpoint node to select it, then right click to access the context menu and select PSSession.','PowerShell Session')
                    # }

                    $NewPSDriveSplat = @{
                        Name       = $script:ComputerListEndpointNameToolStripLabel.text
                        PSProvider = 'FileSystem'
                        Root       = "\\$($script:ComputerListEndpointNameToolStripLabel.text)\c$"
                    } 
                    if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                        if (!$script:Credential) { Set-NewCredential }
                        $NewPSDriveSplat += @{Credential = $script:Credential}
                    }
                    New-PSDrive @NewPSDriveSplat
                    # start-process PowerShell.exe -ArgumentList "param($script:ComputerListEndpointNameToolStripLabel,$script:credential,);New-PSDrive -Name $($script:ComputerListEndpointNameToolStripLabel.text) -PSProvider 'FileSystem' -Root "\\$($script:ComputerListEndpointNameToolStripLabel.text)\c$" -Credential $script:credential"

                    Invoke-Item -Path "$($script:ComputerListEndpointNameToolStripLabel.text):"

                    if ($script:RollCredentialsState -and $script:ComputerListProvideCredentialsCheckBox.checked) {
                        Start-Sleep -Seconds 3
                        Set-NewRollingPassword
                    }            
                }
                ToolTipText = "
"
            }
            $script:ComputerListContextMenuStrip.Items.add($script:ComputerListFileSystemToolStripButton)


            $script:ComputerListEventViewerToolStripButton = New-Object System.Windows.Forms.ToolStripMenuItem -Property @{
                Image = [System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Event-Viewer.png")
                Text        = "Event Viewer (Connect)"
                ForeColor   = 'Black'
                Add_Click   = $EventViewerConnectionButtonAdd_Click
                ToolTipText = "
Establishes an interactive session and displays a GUI with an endpoint.

Must launch shell with elevated permissions, as there is no credential parameter for Show-EventLog.

Default ports, protocols, and services: 
    TCP / 135 and dynamic ports, typically:
    TCP / 49152-65535 (Windows Vista, Server 2008 and above)
    TCP / 1024 -65535 (Windows NT4, Windows 2000, Windows 2003)
    Remote Procedure Call / Distributed Component Object Model (RPC/DCOM)

Command:
    Show-EventLog -ComputerName <Hostname>
"
            }
            $script:ComputerListContextMenuStrip.Items.add($script:ComputerListEventViewerToolStripButton)


            $script:ComputerListEventViewerToolStripButton = New-Object System.Windows.Forms.ToolStripMenuItem -Property @{
                Image = [System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Chainsaw.png")
                Text        = "Event Viewer / ChainSaw (Collect)"
                ForeColor   = 'Black'
                Add_Click   = $EventViewerCollectionButtonAdd_Click
                ToolTipText = "
Collects data on available Event Logs and saves them locally for review with Event Viewer.

Default ports, protocols, and services: 
    TCP / 47001 - Endpoint Listener
    TCP / 5985 [HTTP]  Windows 7+
    TCP / 5986 [HTTPS] Windows 7+
    TCP / 80   [HTTP]  Windows Vista-
    TCP / 443  [HTTPS] Windows Vista-
    Windows Remote Management (WinRM)
    Regardless of the transport protocol used (HTTP or HTTPS), WinRM always encrypts all PowerShell remoting communication after initial authentication

Command Ex:
    `$EventLogSaveName = (Get-WmiObject -Class Win32_NTEventlogFile | Where-Object LogfileName -EQ 'Security').BackupEventlog('c:\Windows\Temp\Hostname (yyyy-MM-dd HH.mm.ss) Security.evtx')
    eventvwr -l:'c:\Windows\Temp\Hostname (yyyy-MM-dd HH.mm.ss) Security.evtx'
"
            }
            $script:ComputerListContextMenuStrip.Items.add($script:ComputerListEventViewerToolStripButton)    
        }
        elseif ($script:ComputerListPivotExecutionCheckbox.checked -eq $true) {
           
            $script:ComputerListPSSessionPivotToolStripButton = New-Object System.Windows.Forms.ToolStripMenuItem -Property @{
                Image = [System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\PowerShell.png")
                Text        = "Pivot-PSSession"
                ForeColor   = 'Black'
                Add_Click   = $ComputerListPSSessionPivotButtonAdd_Click
                ToolTipText = "
Sends commands to a pivot host to execute on an endpoint.
Establishes an interactive Powershell Session with an endpoint.

Normally, conntections with endpoints are authenticated with Active Directory and the hostname.

To use with an IP address, rather than a hostname, the Credential parameter must be used. Also, the endpoint must have the remote computer's IP must be in the local TrustedHosts or be configured for HTTPS transport.

Default ports, protocols, and services: 
    TCP / 47001 - Endpoint Listener
    TCP / 5985 [HTTP]  Windows 7+
    TCP / 5986 [HTTPS] Windows 7+
    TCP / 80   [HTTP]  Windows Vista-
    TCP / 443  [HTTPS] Windows Vista-
    Windows Remote Management (WinRM)
    Regardless of the transport protocol used (HTTP or HTTPS), WinRM always encrypts all PowerShell remoting communication after initial authentication

Command:
    Enter-PSSession -ComputerName <endpoint> -Credential <`$creds>
"
            }
            $script:ComputerListContextMenuStrip.Items.add($script:ComputerListPSSessionPivotToolStripButton)
        }
    }

    if ($ClickedOnArea) {

        $script:ComputerListInteractWithEndpointToolStripLabel = New-Object System.Windows.Forms.ToolStripMenuItem -Property @{
            Image = [System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Computer-Alert.gif")
            Text      = "Interact With The Endpoint"
            Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
            ForeColor = 'Blue'
        }
        $script:ComputerListContextMenuStrip.Items.add($script:ComputerListInteractWithEndpointToolStripLabel)        

        $script:ComputerListContextMenuStrip.Items.Add('-')
    
        $script:ComputerListLeftClick1ToolStripLabel = New-Object System.Windows.Forms.ToolStripMenuItem -Property @{
            Image = [System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Disable-Sign.png")
            Text      = "Left-Click an endpoint, then Right-Click for options."
            TextAlign = 'MiddleLeft'
            ForeColor = 'DarkRed'

        }
        $script:ComputerListContextMenuStrip.Items.add($script:ComputerListLeftClick1ToolStripLabel)
    }


    $script:ComputerListSelectedNodeActionsToolStripLabel = New-Object System.Windows.Forms.ToolStripMenuItem -Property @{
        Image = [System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Node-Action.png")
        Text      = "Node Actions: Selected"
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = 'Black'
        Add_Click = { [System.Windows.Forms.MessageBox]::Show("This is just a heading, select another option","PoSh-EasyWin",'Ok',"Info") }
    }
    $script:ComputerListContextMenuStrip.Items.add($script:ComputerListSelectedNodeActionsToolStripLabel)


    $ComputerListSelectedNodeActionsToolStripComboBox = New-Object System.Windows.Forms.ToolStripComboBox -Property @{
        Size        = @{ Width  = $FormScale * 200 }
        Text        = '  - Make a selection'
        ForeColor   = 'Black'
        ToolTipText = 'Conduct various actions against a single node.'
        Add_SelectedIndexChanged = {
            $script:ComputerListContextMenuStrip.Close()

            if ($This.selectedItem -eq " - Tag Node With Metadata") { 
                $script:ComputerListContextMenuStrip.Close()

                $InformationTabControl.SelectedTab = $Section3HostDataTab

                if ($script:EntrySelected) {
                    Show-TreeViewTagForm -Endpoint
                    if ($script:ComputerListMassTagValue) {
                        $script:Section3HostDataNameTextBox.Text  = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $script:EntrySelected.Text}).Name
                        $Section3HostDataOSTextBox.Text    = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $script:EntrySelected.Text}).OperatingSystem
                        $Section3HostDataOUTextBox.Text    = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $script:EntrySelected.Text}).CanonicalName
                        $Section3HostDataIPTextBox.Text    = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $script:EntrySelected.Text}).IPv4Address
                        $Section3HostDataMACTextBox.Text   = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $script:EntrySelected.Text}).MACAddress
                        $Section3HostDataNotesRichTextBox.Text = "[$($script:ComputerListMassTagValue)] " + $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $script:EntrySelected.Text}).Notes
                        Save-TreeViewData -Endpoint
                        $StatusListBox.Items.clear()
                        $StatusListBox.Items.Add("Tag applied to: $($script:EntrySelected.text)")
                    }
                }   
            }
            if ($This.selectedItem -eq ' - Add New Endpoint Node')  { 
                $script:ComputerListContextMenuStrip.Close()
    
                $StatusListBox.Items.Clear()
                $StatusListBox.Items.Add("Add hostname/IP:")
           
                
                $ComputerTreeNodePopup = New-Object system.Windows.Forms.Form -Property @{
                    Text   = "Add Hostname/IP"
                    Width  = $FormScale * 335
                    Height = $FormScale * 177
                    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                    Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$script:EasyWinIcon")
                    StartPosition = "CenterScreen"
                    Add_Closing = { $This.dispose() }
                }
            
            
                $ComputerTreeNodePopupAddTextBox = New-Object System.Windows.Forms.TextBox -Property @{
                    Text   = "Enter a hostname/IP"
                    Left   = $FormScale * 10
                    Top    = $FormScale * 10
                    Width  = $FormScale * 300
                    Height = $FormScale * 25
                    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                }
                $ComputerTreeNodePopupAddTextBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { Add-TreeViewComputer } })
                $ComputerTreeNodePopup.Controls.Add($ComputerTreeNodePopupAddTextBox)
            
            
                $ComputerTreeNodePopupOSComboBox  = New-Object System.Windows.Forms.ComboBox -Property @{
                    Text   = "Select an Operating System (or type in a new one)"
                    Left   = $FormScale * 10
                    Top    = $ComputerTreeNodePopupAddTextBox.Top + $ComputerTreeNodePopupAddTextBox.Height + $($FormScale * 10)
                    Width  = $FormScale * 300
                    Height = $FormScale * 25
                    AutoCompleteSource = "ListItems"
                    AutoCompleteMode   = "SuggestAppend"
                    Font               = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                }
                $ComputerTreeNodeOSCategoryList = $script:ComputerTreeViewData | Select-Object -ExpandProperty OperatingSystem -Unique
            
            
                # Dynamically creates the OS Category combobox list used for OS Selection
                ForEach ($OS in $ComputerTreeNodeOSCategoryList) { $ComputerTreeNodePopupOSComboBox.Items.Add($OS) }
                $ComputerTreeNodePopup.Controls.Add($ComputerTreeNodePopupOSComboBox)
            
            
                $ComputerTreeNodePopupOUComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
                    Text   = "Select an Organizational Unit / Canonical Name (or type a new one)"
                    Left   = $FormScale * 10
                    Top    = $ComputerTreeNodePopupOSComboBox.Top + $ComputerTreeNodePopupOSComboBox.Height + $($FormScale * 10)
                    Width  = $FormScale * 300
                    Height = $FormScale * 25
                    AutoCompleteSource = "ListItems"
                    AutoCompleteMode   = "SuggestAppend"
                    Font               = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                }
                $ComputerTreeNodeOUCategoryList = $script:ComputerTreeViewData | Select-Object -ExpandProperty CanonicalName -Unique
                # Dynamically creates the OU Category combobox list used for OU Selection
                ForEach ($OU in $ComputerTreeNodeOUCategoryList) { $ComputerTreeNodePopupOUComboBox.Items.Add($OU) }
                $ComputerTreeNodePopupOUComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { Add-TreeViewComputer } })
                $ComputerTreeNodePopup.Controls.Add($ComputerTreeNodePopupOUComboBox)
            
                $ComputerAndAccountTreeViewTabControl.SelectedTab = $ComputerTreeviewTab
                $script:ComputerTreeNodeComboBox.SelectedItem = 'CanonicalName'
            
                if ($Script:CategorySelected){ $ComputerTreeNodePopupOUComboBox.Text = $Script:CategorySelected.text }
                elseif ($Script:EntrySelected){ $ComputerTreeNodePopupOUComboBox.Text = $Script:EntrySelected.text }
                else { $ComputerTreeNodePopupOUComboBox.Text  = "Select an Organizational Unit / Canonical Name (or type a new one)" }
            
            
                $ComputerTreeNodePopupAddHostButton = New-Object System.Windows.Forms.Button -Property @{
                    Text   = "Add Host"
                    Left   = $FormScale * 210
                    Top    = $ComputerTreeNodePopupOUComboBox.Top + $ComputerTreeNodePopupOUComboBox.Height + $($FormScale * 10)
                    Width  = $FormScale * 100
                    Height = $FormScale * 25
                    Add_Click = { Add-TreeViewComputer }
                    Add_KeyDown = { if ($_.KeyCode -eq "Enter") { Add-TreeViewComputer } }    
                }
                Apply-CommonButtonSettings -Button $ComputerTreeNodePopupAddHostButton
                $ComputerTreeNodePopup.Controls.Add($ComputerTreeNodePopupAddHostButton)
            
                # $script:ComputerTreeView.ExpandAll()
                # Remove-TreeViewEmptyCategory -Endpoint
                # Normalize-TreeViewData -Endpoint
                # Save-TreeViewData -Endpoint
                $ComputerTreeNodePopup.ShowDialog()
            }
            if ($This.selectedItem -eq " - Rename Selected Node")  { 
                $script:ComputerListContextMenuStrip.Close()

                
                $InformationTabControl.SelectedTab = $Section3ResultsTab

                Create-TreeViewCheckBoxArray -Endpoint
                if ($script:EntrySelected) {
                    $StatusListBox.Items.Clear()
                    $StatusListBox.Items.Add("Enter a new name:")

                    $ComputerTreeNodeRenamePopup = New-Object system.Windows.Forms.Form -Property @{
                        Text   = "Rename $($script:EntrySelected.text)"
                        Width  = $FormScale * 330
                        Height = $FormScale * 107
                        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                        StartPosition = "CenterScreen"
                        Add_Closing   = { $This.dispose() }    
                    }

                    $script:ComputerTreeNodeRenamePopupTextBox = New-Object System.Windows.Forms.TextBox -Property @{
                        Text   = "New Hostname/IP"
                        Left   = $FormScale * 10
                        Top    = $FormScale * 10
                        Width  = $FormScale * 300
                        Height = $FormScale * 25
                        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)    
                    }

                    # Renames the computer treenode to the specified name
                    . "$Dependencies\Code\Tree View\Computer\Rename-TreeViewComputer.ps1"

                    # Moves the hostname/IPs to the new Category
                    $script:ComputerTreeNodeRenamePopupTextBox.Add_KeyDown({
                        if ($_.KeyCode -eq "Enter") { Rename-TreeViewComputer }
                    })
                    $ComputerTreeNodeRenamePopup.Controls.Add($script:ComputerTreeNodeRenamePopupTextBox)


                    $ComputerTreeNodeRenamePopupButton = New-Object System.Windows.Forms.Button -Property @{
                        Text   = "Execute"
                        Left   = $FormScale * 210
                        Top    = $script:ComputerTreeNodeRenamePopupTextBox.Left + $script:ComputerTreeNodeRenamePopupTextBox.Height + ($FormScale * 5)
                        Width  = $FormScale * 100
                        Height = $FormScale * 22
                    }
                    Apply-CommonButtonSettings -Button $ComputerTreeNodeRenamePopupButton
                    $ComputerTreeNodeRenamePopupButton.Add_Click({ Rename-TreeViewComputer })
                    $ComputerTreeNodeRenamePopup.Controls.Add($ComputerTreeNodeRenamePopupButton)

                    $ComputerTreeNodeRenamePopup.ShowDialog()
                }
                else {
                    $StatusListBox.Items.Clear()
                    $StatusListBox.Items.Add($script:EntrySelected.text)
                }
                # elseif ($script:ComputerTreeViewSelected.count -lt 1) {
                #     Show-MessageBox -Message "No hostname/IP selected`r`nMake sure to checkbox only one hostname/IP`r`nSelecting a Category will not allow you to connect to multiple hosts" -Title "Rename Selection:  Error" 
                # }
                # elseif ($script:ComputerTreeViewSelected.count -gt 1) {
                #     Show-MessageBox -Message "Too many hostname/IPs selected`r`nMake sure to checkbox only one hostname/IP`r`nSelecting a Category will not allow you to connect to multiple hosts" -Title "Rename Selection:  Error"
                # }

                Remove-TreeViewEmptyCategory -Endpoint
                Save-TreeViewData -Endpoint
            }
            if ($This.selectedItem -eq " - Move Node To New OU/CN")  { 
                $script:ComputerListContextMenuStrip.Close()

                $InformationTabControl.SelectedTab = $Section3ResultsTab

                Create-TreeViewCheckBoxArray -Endpoint
                if ($script:EntrySelected) {
                    Show-TreeViewMoveForm -Endpoint -Title "Move: $($script:EntrySelected.Text)" -SelectedEndpoint
            
                    $script:ComputerTreeView.Nodes.Clear()
                    Initialize-TreeViewData -Endpoint
            
                    $ComputerAndAccountTreeViewTabControl.SelectedTab = $ComputerTreeviewTab
                    $script:ComputerTreeNodeComboBox.SelectedItem = 'CanonicalName'
            
                    Foreach($Computer in $script:ComputerTreeViewData) {
                        Add-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category $Computer.CanonicalName -Entry $Computer.Name -ToolTip $ComputerData.IPv4Address -IPv4Address $Computer.IPv4Address -Metadata $Computer
                    }
            
                    Remove-TreeViewEmptyCategory -Endpoint
                    Save-TreeViewData -Endpoint
                    Update-TreeViewState -Endpoint -NoMessage
            
                    $StatusListBox.Items.Clear()
                    $StatusListBox.Items.Add("Moved:  $($script:EntrySelected.text)")
                }
            }
            if ($This.selectedItem -eq " - Delete Selected Node")  {
                $script:ComputerListContextMenuStrip.Close()

                $InformationTabControl.SelectedTab = $Section3ResultsTab

                Create-TreeViewCheckBoxArray -Endpoint
                if ($script:EntrySelected) {

                    $MessageBox = Show-MessageBox -Message "Confirm Deletion of Endpoint Node: $($script:EntrySelected.text)`r`n`r`nAll Endpoint metadata and notes will be lost.`r`n`r`nAny previously collected data will still remain." -Title "PoSh-EasyWin - Delete Endpoint" -Options "YesNo" -Type "Error" -Sound

                    Switch ( $MessageBox ) {
                        'Yes' {
                            # Removes selected computer nodes
                            [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
                            foreach ($root in $AllTreeViewNodes) {
                                foreach ($Category in $root.Nodes) {
                                    foreach ($Entry in $Category.nodes) {
                                        if ($Entry.text -eq $script:EntrySelected.text) {
                                            # Removes the node from the treeview
                                            $Entry.remove()
                                            # Removes the host from the variable storing the all the computers
                                            $script:ComputerTreeViewData = $script:ComputerTreeViewData | Where-Object {$_.Name -ne $Entry.text}
                                        }
                                    }
                                }
                            }
                            $StatusListBox.Items.Clear()
                            $StatusListBox.Items.Add("Deleted:  $($script:EntrySelected.text)")

                            $ComputerAndAccountTreeViewTabControl.SelectedTab = $ComputerTreeviewTab
                            $script:ComputerTreeNodeComboBox.SelectedItem = 'CanonicalName'

                            #This is a bit of a workaround, but it prevents the host data message from appearing after a computer node is deleted...
                            $script:FirstCheck = $false

                            Remove-TreeViewEmptyCategory -Endpoint
                            Save-TreeViewData -Endpoint
                        }
                        'No' {
                            $StatusListBox.Items.Clear()
                            $StatusListBox.Items.Add('Endpoint Deletion Cancelled')
                        }
                    }
                }   
            }
        }
    }
    $ComputerListSelectedNodeActionsToolStripComboBox.Items.Add(" - Add New Endpoint Node")
    # $ComputerListSelectedNodeActionsToolStripComboBox.Items.Add(" - Tag Node With Metadata")
    $ComputerListSelectedNodeActionsToolStripComboBox.Items.Add(" - Move Node To New OU/CN")
    $ComputerListSelectedNodeActionsToolStripComboBox.Items.Add(" - Delete Selected Node")
    $ComputerListSelectedNodeActionsToolStripComboBox.Items.Add(" - Rename Selected Node")
    $script:ComputerListContextMenuStrip.Items.Add($ComputerListSelectedNodeActionsToolStripComboBox)


    $script:ComputerListContextMenuStrip.Items.Add('-')

    $script:ComputerListMultiEndpointPSSessionToolStripLabel = New-Object System.Windows.Forms.ToolStripMenuItem -Property @{
        Image = [System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Checked-Box.png")
        Text      = "Interact With Checked Endpoints"
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = 'Blue'
        Add_Click = { [System.Windows.Forms.MessageBox]::Show("This is just a heading, select another option","PoSh-EasyWin",'Ok',"Info") }
    }
    $script:ComputerListContextMenuStrip.Items.add($script:ComputerListMultiEndpointPSSessionToolStripLabel)

    $script:ComputerListContextMenuStrip.Items.Add('-')

    if ( $script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Beta Testing') {
        $ComputerListEnterPSSessionToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
            Text        = "New-PSSession"
            ForeColor   = 'Black'
            Add_Click   = {
                $InformationTabControl.SelectedTab = $Section3ResultsTab
                Create-TreeViewCheckBoxArray -Endpoint
                Generate-ComputerList
            
                if ($script:ComputerListProvideCredentialsCheckBox.Checked) { $Username = $script:Credential.UserName}
                else {$Username = $PoShEasyWinAccountLaunch }
            
                if ($script:ComputerListEndpointNameToolStripLabel.text) {
                    $script:SessionsAlreadyExists = $false
                    $script:SessionsAlreadyExistsList = @()
                    $script:SessionsDontExistList = @()
                    foreach ($Computer in $script:ComputerList) {
                        if ($Computer -in $($script:PoShEasyWinPSSessions | Where-Object {$_.State -match 'Open'}).ComputerName) {
                            $script:SessionsAlreadyExists = $true
                            $script:SessionsAlreadyExistsList += $Computer
                        }
                        else {
                            $script:SessionsDontExistList += $Computer
                        }
                    }

                    $VerifyAction = Verify-Action -Title "Verification: PowerShell Session" -Question "Connecting Account:  $Username`n`nCreate a new PowerShell Session to the following?" -Computer $script:SessionsDontExistList
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
                    [System.Windows.Forms.Messagebox]::Show('Left click an endpoint node to select it, then right click to access the context menu and select PSSession.','PowerShell Session')
                }
            
                if ($VerifyAction) {
                    # This brings specific tabs to the forefront/front view
                    $InformationTabControl.SelectedTab = $Section3ResultsTab
            
                    $StatusListBox.Items.Clear()
                    $StatusListBox.Items.Add("New-PSSession:  $($script:SessionsDontExistList.Count) Ednpoints")

                    if ($script:SessionsAlreadyExists -eq $true) {
                        [System.Windows.Forms.MessageBox]::Show("The following endpoints already have an open PowerShell session:`n`n$($script:SessionsAlreadyExistsList)","PoSh-EasyWin - PowerShell Sessions",'Ok',"Info")
                    }
                    else {
                        $PoShEasyWinNewPSSessions = $null

                        if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                            if (-not $script:Credential) { Set-NewCredential }
                            $PoShEasyWinNewPSSessions = New-PSSession -ComputerName $script:SessionsDontExistList -Credential $script:Credential
                            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "New-PSSession -ComputerName $($script:SessionsDontExistList) -Credential $script:Credential"
                        }
                        else {
                            $PoShEasyWinNewPSSessions = New-PSSession -ComputerName $script:SessionsDontExistList
                            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "New-PSSession -ComputerName $($script:SessionsDontExistList)"
                        }

                        $PoShEasyWinNewPSSessions `
                        | Add-Member -MemberType NoteProperty -Name 'StartTime' -Value $(Get-Date) -PassThru `
                        | Add-Member -MemberType NoteProperty -Name 'Duration' -Value $null -PassThru `
                        | Add-Member -MemberType NoteProperty -Name 'EndTime' -Value $null
                        $script:PoShEasyWinPSSessions += $PoShEasyWinNewPSSessions
                    }
            
                    if ($script:RollCredentialsState -and $script:ComputerListProvideCredentialsCheckBox.checked) {
                        Start-Sleep -Seconds 3
                        Set-NewRollingPassword
                    }
                }
                else {
                    [system.media.systemsounds]::Exclamation.play()
                    $StatusListBox.Items.Clear()
                    $StatusListBox.Items.Add("PowerShell New-PSSession:  Cancelled")
                }                        
            }
            ToolTipText = ""
        }
        $script:ComputerListContextMenuStrip.Items.Add($ComputerListEnterPSSessionToolStripButton)

        $ComputerListEnterPSSessionToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
            Text        = "Get-PSSession"
            ForeColor   = 'Black'
            Add_Click   = {
                $PoShEasyWinPSSessionsDisplay = @()
                
                $PoShEasyWinPSSessionsDisplay += $script:PoShEasyWinPSSessions `
                | Where-Object {$_.State -match 'Open'} `
                | Foreach-Object {
                    $_ | Add-Member -MemberType NoteProperty -Name Duration -Value $(New-TimeSpan -Start $_.StartTime -End $(Get-Date)) -Force -PassThru
                } `
                | Select-Object -Property Id, ComputerName, StartTime, Duration, Endtime, Name, ComputerType, State, ConfigurationName, Availability

                $PoShEasyWinPSSessionsDisplay += $script:PoShEasyWinPSSessions `
                | Where-Object {$_.State -notmatch 'Open'} `
                | Select-Object -Property Id, ComputerName, StartTime, Duration, Endtime, Name, ComputerType, State, ConfigurationName, Availability

                $PoShEasyWinPSSessionsDisplay `
                | Sort-Object -Property State `
                | Select-Object -Property Id, ComputerName, StartTime, Duration, Endtime, Name, ComputerType, State, ConfigurationName, Availability `
                | Out-GridView -Title "Status of Powershell Sessions"
            }
            ToolTipText = ""
        }
        $script:ComputerListContextMenuStrip.Items.Add($ComputerListEnterPSSessionToolStripButton)

        $ComputerListEnterPSSessionToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
            Text        = "Remove-PSSession"
            ForeColor   = 'Black'
            Add_Click   = {
                # Adds metadata to existing open sessions 
                $script:PoShEasyWinPSSessions | Where-Object {$_.State -match 'Open'} `
                | ForEach-Object {
                    $_ | Add-Member -MemberType NoteProperty -Name Duration -Value $(New-TimeSpan -Start $_.StartTime -End $(Get-Date)) -Force
                }
                $PoShEasyWinPSSessionsRemovePrompt = $script:PoShEasyWinPSSessions | Where-Object {$_.State -match 'Open'}

                if ($($PoShEasyWinPSSessionsRemovePrompt | Where-Object {$_.State -match 'Open'})) {
                    # Prompts user to close sessions
                    $PoShEasyWinPSSessionsRemovePrompt | Where-Object {$_.State -match 'Open'} `
                    | Select-Object -Property Id, ComputerName, StartTime, Duration, Endtime, Name, ComputerType, State, ConfigurationName, Availability `
                    | Out-GridView -Title 'Selecte PowerShell Sessions To Remove' -PassThru `
                    | Remove-PSSession

                    # Adds metadata to remaining open sessions
                    $PoShEasyWinPSSessionsRemovePrompt | Where-Object {$_.State -match 'Open'} `
                    | ForEach-Object {
                        $_ | Add-Member -MemberType NoteProperty -Name Duration -Value $(New-TimeSpan -Start $_.StartTime -End $(Get-Date)) -Force
                    }

                    # Adds metadata to remaining 'closed' sessions
                    $PoShEasyWinPSSessionsRemovePrompt | Where-Object {$_.State -notmatch 'Open'} `
                    | ForEach-Object {
                        $_ | Add-Member -MemberType NoteProperty -Name EndTime -Value $(Get-Date) -Force
                        $_ | Add-Member -MemberType NoteProperty -Name Duration -Value $(New-TimeSpan -Start $_.StartTime -End $(Get-Date)) -Force
                    }

                    if ($($PoShEasyWinPSSessionsRemovePrompt | Where-Object {$_.State -notmatch 'Open'})) {
                        $script:PoShEasyWinPSSessions `
                        | Select-Object -Property Id, ComputerName, StartTime, Duration, Endtime, Name, ComputerType, State, ConfigurationName, Availability `
                        | Sort-Object -Property State `
                        | Out-GridView -Title "Status of Powershell Sessions" -PassThru 
                    }
                }
                else {
                    [System.Windows.Forms.MessageBox]::Show("There are no open PowerShell Sessions.","PoSh-EasyWin - PowerShell Sessions",'Ok',"Info")
                }
            }
            ToolTipText = ""
        }
        $script:ComputerListContextMenuStrip.Items.Add($ComputerListEnterPSSessionToolStripButton)
    }


    $script:ComputerListMultiEndpointPSSessionToolStripButton = New-Object System.Windows.Forms.ToolStripMenuItem -Property @{
        Image = [System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\PowerShell-Multi-Session.png")
        Text        = "MultiEndpoint-PSSession"
        ForeColor   = 'Black'
        Add_Click   = {
            Create-TreeViewCheckBoxArray -Endpoint

            if ($script:ComputerTreeViewSelected.count -gt 0){
                $InformationTabControl.SelectedTab = $Section3ResultsTab
            
                if ($script:ComputerListProvideCredentialsCheckBox.Checked) { $Username = $script:Credential.UserName}
                else {$Username = $PoShEasyWinAccountLaunch }
            
                if (Verify-Action -Title "Verification: PowerShell Session" -Question "Connecting Account:  $Username`n`nEnter into PowerShell Sessions to the following $($script:ComputerTreeViewSelected.Count) endpoints?" -Computer $($script:ComputerTreeViewSelected)) {
                    # This brings specific tabs to the forefront/front view
                    $InformationTabControl.SelectedTab = $Section3ResultsTab
            
                    $StatusListBox.Items.Clear()
                    $StatusListBox.Items.Add("MultiEndpoint-PSSession:  $($script:ComputerTreeViewSelected)")
                    #Removed For Testing#$ResultsListBox.Items.Clear()
                    if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                        if (-not $script:Credential) { Set-NewCredential }
                        
                        Invoke-Expression @"
Start-Process 'PowerShell' -ArgumentList '-NoExit', '-NoProfile', '-ExecutionPolicy Bypass',
{ & '$Dependencies\Code\Main Body\MultiEndpoint-PSSession.ps1' -ComputerList "$($script:ComputerTreeViewSelected -split ' ' -join ',')" -CredentialXML '$script:SelectedCredentialPath'; }
"@
                        Start-Sleep -Seconds 3
                    }
                    else {
                        Invoke-Expression @"
Start-Process 'PowerShell' -ArgumentList '-NoExit', '-NoProfile', '-ExecutionPolicy Bypass',
{ & '$Dependencies\Code\Main Body\MultiEndpoint-PSSession.ps1' -ComputerList "$($script:ComputerTreeViewSelected -split ' ' -join ',')"; }
"@
                        
                        Start-Sleep -Seconds 3
                    }
                    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "MultiEndpoint-PSSession -ComputerName $($script:ComputerTreeViewSelected)"
            
                    if ($script:RollCredentialsState -and $script:ComputerListProvideCredentialsCheckBox.checked) {
                        Start-Sleep -Seconds 3
                        Set-NewRollingPassword
                    }
                }
                else {
                    [system.media.systemsounds]::Exclamation.play()
                    $StatusListBox.Items.Clear()
                    $StatusListBox.Items.Add("MultiEndpoint-PowerShell Session:  Cancelled")
                }        
            }
            else {
                [System.Windows.Forms.Messagebox]::Show('Checkbox one or more endpoints to establish a session with.','PowerShell Session')
            }
        }
        ToolTipText = "
Establishes interactive Powershell Sessions with one or endpoints.

Not compatible with 'Pivot Thru (WinRM)'.

Normally, conntections with endpoints are authenticated with Active Directory and the hostname.

To use with an IP address, rather than a hostname, the Credential parameter must be used. Also, the endpoint must have the remote computer's IP must be in the local TrustedHosts or be configured for HTTPS transport.

Default ports, protocols, and services: 
TCP / 47001 - Endpoint Listener
TCP / 5985 [HTTP]  Windows 7+
TCP / 5986 [HTTPS] Windows 7+
TCP / 80   [HTTP]  Windows Vista-
TCP / 443  [HTTPS] Windows Vista-
Windows Remote Management (WinRM)
Regardless of the transport protocol used (HTTP or HTTPS), WinRM always encrypts all PowerShell remoting communication after initial authentication

Command:
function:MultiEndpoint-PSSession -ComputerName <endpoints(s)> -Credential <`$creds>
"    }
    $script:ComputerListContextMenuStrip.Items.add($script:ComputerListMultiEndpointPSSessionToolStripButton)


    $script:ComputerListRenameToolStripLabel = New-Object System.Windows.Forms.ToolStripMenuItem -Property @{
        Image = [System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Network-Cable.png")
        Text      = 'Test Connection'
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = 'Black'
        Add_Click = { [System.Windows.Forms.MessageBox]::Show("This is just a heading, select another option","PoSh-EasyWin",'Ok',"Info") }
    }
    $script:ComputerListContextMenuStrip.Items.add($script:ComputerListRenameToolStripLabel)

    
    $ComputerListTestConnectionToolStripComboBox = New-Object System.Windows.Forms.ToolStripComboBox -Property @{
        Size = @{ Width  = $FormScale * 200 }
        Text = '  - Make a selection'
        ForeColor = "Black"
        Add_SelectedIndexChanged = {
            $script:ComputerListContextMenuStrip.Close()

            if ($This.selectedItem -eq ' - ICMP Ping') { 
                $script:ComputerListContextMenuStrip.Close()

                Create-TreeViewCheckBoxArray -Endpoint

                if ($script:ComputerTreeViewSelected.count -eq 0){
                    Show-MessageBox -Message 'Error: You need to check at least one endpoint.' -Title "PoSh-EasyWin - Ping" -Options "Ok" -Type "Error" -Sound
                }
                else {
                    if (Verify-Action -Title "Verification: Ping Test" -Question "Conduct a Ping test to the following?" -Computer $($script:ComputerTreeViewSelected -join ', ')) {
                        Check-Connection -CheckType "Ping" -MessageTrue "Able to Ping" -MessageFalse "Unable to Ping"
                    }
                    else {
                        [system.media.systemsounds]::Exclamation.play()
                        $StatusListBox.Items.Clear()
                        $StatusListBox.Items.Add("Ping:  Cancelled")
                    }
                }            
            }
            if ($This.selectedItem -eq ' - RPC Port Check')  { 
                $script:ComputerListContextMenuStrip.Close()

                Create-TreeViewCheckBoxArray -Endpoint

                if ($script:ComputerListProvideCredentialsCheckBox.Checked) { $Username = $script:Credential.UserName}
                else {$Username = $PoShEasyWinAccountLaunch }
            
                if ($script:ComputerTreeViewSelected.count -eq 0){
                    Show-MessageBox -Message 'Error: You need to check at least one endpoint.' -Title "PoSh-EasyWin - RPC Port Check" -Options "Ok" -Type "Error" -Sound
                }
                else {
                    if (Verify-Action -Title "Verification: RPC Port Check" -Question "Connecting Account:  $Username`n`nConduct a RPC Port Check to the following?" -Computer $($script:ComputerTreeViewSelected -join ', ')) {
                        Check-Connection -CheckType "RPC Port Check" -MessageTrue "RPC Port 135 is Open" -MessageFalse "RPC Port 135 is Closed"
                    }
                    else {
                        [system.media.systemsounds]::Exclamation.play()
                        $StatusListBox.Items.Clear()
                        $StatusListBox.Items.Add("RPC Port Check:  Cancelled")
                    }
                }
            }
            if ($This.selectedItem -eq ' - SMB Port Check')  { 
                $script:ComputerListContextMenuStrip.Close()

                Create-TreeViewCheckBoxArray -Endpoint

                if ($script:ComputerListProvideCredentialsCheckBox.Checked) { $Username = $script:Credential.UserName}
                else {$Username = $PoShEasyWinAccountLaunch }
            
                if ($script:ComputerTreeViewSelected.count -eq 0){
                    Show-MessageBox -Message 'Error: You need to check at least one endpoint.' -Title "PoSh-EasyWin - SMB Port Check" -Options "Ok" -Type "Error" -Sound
                }
                else {
                    if (Verify-Action -Title "Verification: SMB Port Check" -Question "Connecting Account:  $Username`n`nConduct a SMB Port Check to the following?" -Computer $($script:ComputerTreeViewSelected -join ', ')) {
                        Check-Connection -CheckType "SMB Port Check" -MessageTrue "SMB Port 445 is Open" -MessageFalse "SMB Port 445 is Closed"
                    }
                    else {
                        [system.media.systemsounds]::Exclamation.play()
                        $StatusListBox.Items.Clear()
                        $StatusListBox.Items.Add("SMB Port Check:  Cancelled")
                    }
                }
            }
            if ($This.selectedItem -eq ' - WinRM Check')  { 
                $script:ComputerListContextMenuStrip.Close()

                Create-TreeViewCheckBoxArray -Endpoint

                if ($script:ComputerListProvideCredentialsCheckBox.Checked) { $Username = $script:Credential.UserName}
                else {$Username = $PoShEasyWinAccountLaunch }
            
                if ($script:ComputerTreeViewSelected.count -lt 1){
                    Show-MessageBox -Message 'Error: You need to check at least one endpoint.' -Title "PoSh-EasyWin - WinRM Check" -Options "Ok" -Type "Error" -Sound
                }
                else {
                    if (Verify-Action -Title "Verification: WinRM Check" -Question "Connecting Account:  $Username`n`nConduct a WinRM Check to the following?" -Computer $($script:ComputerTreeViewSelected -join ', ')) {
                        Check-Connection -CheckType "WinRM Check" -MessageTrue "Able to Verify WinRM" -MessageFalse "Unable to Verify WinRM"
                    }
                    else {
                        [system.media.systemsounds]::Exclamation.play()
                        $StatusListBox.Items.Clear()
                        $StatusListBox.Items.Add("WinRM Check:  Cancelled")
                    }
                }
            }
        }
    }
    $ComputerListTestConnectionToolStripComboBox.Items.Add(' - ICMP Ping')
    $ComputerListTestConnectionToolStripComboBox.Items.Add(' - RPC Port Check')
    $ComputerListTestConnectionToolStripComboBox.Items.Add(' - SMB Port Check')
    $ComputerListTestConnectionToolStripComboBox.Items.Add(' - WinRM Check')
    $script:ComputerListContextMenuStrip.Items.Add($ComputerListTestConnectionToolStripComboBox)


    $script:ComputerListCheckedNodeActionsToolStripLabel = New-Object System.Windows.Forms.ToolStripMenuItem -Property @{
        Image = [System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Node-Action.png")
        Text      = "Node Actions: All"
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = 'Black'
        Add_Click = { [System.Windows.Forms.MessageBox]::Show("This is just a heading, select another option","PoSh-EasyWin",'Ok',"Info") }
    }
    $script:ComputerListContextMenuStrip.Items.add($script:ComputerListCheckedNodeActionsToolStripLabel)


    $ComputerListCheckedNodeActionsToolStripComboBox = New-Object System.Windows.Forms.ToolStripComboBox -Property @{
        Size = @{ Width  = $FormScale * 200 }
        Text = '  - Make a selection'
        ForeColor = 'Black'
        ToolTipText = 'Conduct various actions against selected nodes.'
        Add_SelectedIndexChanged = {
            $script:ComputerListContextMenuStrip.Close()

            if ($This.selectedItem -eq ' - NSLookup (Hostname to IP)')  { 
                $script:ComputerListContextMenuStrip.Close()

                if ($script:ComputerTreeViewSelected.count -eq 0){
                    Show-MessageBox -Message 'Error: You need to check at least one endpoint.' -Title "PoSh-EasyWin - NSLookup" -Options "Ok" -Type "Error" -Sound
                }
                else {
                    $InformationTabControl.SelectedTab = $Section3HostDataTab
            
                    $script:ProgressBarEndpointsProgressBar.Value = 0
                    $script:ProgressBarQueriesProgressBar.Value   = 0
            
                    Create-TreeViewCheckBoxArray -Endpoint
                    if ($script:ComputerTreeViewSelected.count -ge 0) {
            
                        $MessageBox = [System.Windows.Forms.MessageBox]::Show("Conduct an NSLookup of $($script:ComputerTreeViewSelected.count) endpoints?","NSLookup",'YesNo','Info')
                        Switch ( $MessageBox ) {
                            'Yes' {
                                $MessageBoxAnswer = $true
                            }
                            'No' {
                                $MessageBoxAnswer = $false
                                $StatusListBox.Items.Clear()
                                $StatusListBox.Items.Add('NSLookup Cancelled')
                            }
                        }
            
                        $script:ProgressBarEndpointsProgressBar.Maximum  = $script:ComputerTreeViewSelected.count
                        [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
            
                        if ($MessageBoxAnswer -eq $true) {
                            $ComputerListNSLookupArray = @()
                            foreach ($node in $script:ComputerTreeViewSelected) {
                                foreach ($root in $AllTreeViewNodes) {
                                    foreach ($Category in $root.Nodes) {
                                        foreach ($Entry in $Category.Nodes) {
                                            $LookupEndpoint = $null
            
                                            if ($Entry.Checked -and $Entry.Text -notin $ComputerListNSLookupArray) {
                                                $ComputerListNSLookupArray += $Entry.Text
                                                $script:Section3HostDataNameTextBox.Text = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).Name
                                                $Section3HostDataOSTextBox.Text = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).OperatingSystem
                                                $Section3HostDataOUTextBox.Text = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).CanonicalName
            
                                                $LookupEndpoint = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).Name
                                                $NSlookup = $((Resolve-DnsName "$LookupEndpoint" | Sort-Object IPAddress | Select-Object -ExpandProperty IPAddress -Unique) -Join ', ')
                                                $Section3HostDataIPTextBox.Text = $NSlookup
            
                                                $Section3HostDataMACTextBox.Text = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).MACAddress
                                                $Section3HostDataNotesRichTextBox.Text = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).Notes
                                                Save-TreeViewData -Endpoint
            
                                            }
                                            $script:ProgressBarEndpointsProgressBar.Value += 1
                                        }
                                    }
                                }
                            }
                #               Save-TreeViewData -Endpoint -SaveAllChecked
                            $StatusListBox.Items.clear()
                            $StatusListBox.Items.Add("NSLookup Complete: $($script:ComputerTreeViewSelected.count) Endpoints")
                        }
                    }
                }     
            }
            if ($This.selectedItem -eq ' - Tag Nodes With Metadata')  {
                $script:ComputerListContextMenuStrip.Close()

                Create-TreeViewCheckBoxArray -Endpoint
                if ($script:ComputerTreeViewSelected.count -eq 0){
                    Show-MessageBox -Message 'Error: You need to check at least one endpoint.' -Title "PoSh-EasyWin - Tag All" -Options "Ok" -Type "Error" -Sound
                }
                else {
                    $InformationTabControl.SelectedTab = $Section3HostDataTab
            
                    $script:ProgressBarEndpointsProgressBar.Value = 0
                    $script:ProgressBarQueriesProgressBar.Value   = 0
            
                    Create-TreeViewCheckBoxArray -Endpoint
                    if ($script:ComputerTreeViewSelected.count -ge 0) {
                        Show-TreeViewTagForm -Endpoint
            
                        $script:ProgressBarEndpointsProgressBar.Maximum  = $script:ComputerTreeViewSelected.count
                        [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
            
                        if ($script:ComputerListMassTagValue) {
                            $ComputerListMassTagArray = @()
                            foreach ($node in $script:ComputerTreeViewSelected) {
                                foreach ($root in $AllTreeViewNodes) {
                                    foreach ($Category in $root.Nodes) {
                                        foreach ($Entry in $Category.Nodes) {
                                            if ($Entry.Checked -and $Entry.Text -notin $ComputerListMassTagArray) {
                                                $ComputerListMassTagArray += $Entry.Text
                                                $Section3HostDataNotesRichTextBox.Text   = "$(Get-Date) [Tag] $($script:ComputerListMassTagValue)`n" + $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).Notes
                                            }
                                            $script:ProgressBarEndpointsProgressBar.Value += 1
                                        }
                                    }
                                }
                                Save-TreeViewData -Endpoint -SaveAllChecked
                            }
                            $StatusListBox.Items.clear()
                            $StatusListBox.Items.Add("Tag Complete: $($script:ComputerTreeViewSelected.count) Endpoints")
                        }
                    }
                }      
            }
            if ($This.selectedItem -eq ' - Move Nodes To New OU/CN')  { 
                $script:ComputerListContextMenuStrip.Close()

                Create-TreeViewCheckBoxArray -Endpoint

                if ($script:ComputerTreeViewSelected.count -eq 0){
                    Show-MessageBox -Message 'Error: You need to check at least one endpoint.' -Title "PoSh-EasyWin - Move All" -Options "Ok" -Type "Error" -Sound
                }
                else {
                    $InformationTabControl.SelectedTab = $Section3ResultsTab
            
                    if ($script:ComputerTreeViewSelected.count -ge 0) {
                        Show-TreeViewMoveForm -Endpoint -Title "Moving $($script:ComputerTreeViewSelected.count) Endpoints"
            
                        $script:ComputerTreeView.Nodes.Clear()
                        Initialize-TreeViewData -Endpoint
            
                        $ComputerAndAccountTreeViewTabControl.SelectedTab = $ComputerTreeviewTab
                        $script:ComputerTreeNodeComboBox.SelectedItem = 'CanonicalName'
            
                        Foreach($Computer in $script:ComputerTreeViewData) {
                            Add-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category $Computer.CanonicalName -Entry $Computer.Name -ToolTip $ComputerData.IPv4Address -IPv4Address $Computer.IPv4Address -Metadata $Computer
                        }
            
                        Remove-TreeViewEmptyCategory -Endpoint
                        Save-TreeViewData -Endpoint
                        Update-TreeViewState -Endpoint -NoMessage
            
                        $StatusListBox.Items.Clear()
                        $StatusListBox.Items.Add("Moved $($script:ComputerTreeNodeToMove.Count) Endpoints")
                        $ResultsListBox.Items.Clear()
                        $ResultsListBox.Items.Add("The following hostnames/IPs have been moved to $($ComputerTreeNodePopupMoveComboBox.SelectedItem):")
                    }
                    else { 
                        Show-MessageBox -Message "No hostname/IP selected`r`nMake sure to checkbox only one hostname/IP`r`nSelecting a Category will not allow you to connect to multiple hosts" -Title "Move Selection:  Error"
                    }
                }      
            }
            if ($This.selectedItem -eq ' - Delete Checked Nodes')  { 
                $script:ComputerListContextMenuStrip.Close()

                Create-TreeViewCheckBoxArray -Endpoint

                if ($script:ComputerTreeViewSelected.count -eq 0){
                    Show-MessageBox -Message 'Error: You need to check at least one endpoint.' -Title "PoSh-EasyWin - Delete All" -Options "Ok" -Type "Error" -Sound
                }
                else {
                    
                    $InformationTabControl.SelectedTab = $Section3ResultsTab
            
                    if ($script:ComputerTreeViewSelected.count -eq 1) {
                        $MessageBox = Show-MessageBox -Message "Confirm Deletion of $($script:ComputerTreeViewSelected.count) Endpoint Node.`r`n`r`nAll Endpoint metadata and notes will be lost.`r`nAny previously collected data will still remain." -Title "PoSh-EasyWin - Delete Endpoint" -Options "YesNo" -Type "Question" -Sound
                    }
                    elseif ($script:ComputerTreeViewSelected.count -gt 1) {
                        $MessageBox = Show-MessageBox -Message "Confirm Deletion of $($script:ComputerTreeViewSelected.count) Endpoint Nodes.`r`n`r`nAll Endpoint metadata and notes will be lost.`r`nAny previously collected data will still remain." -Title "PoSh-EasyWin - Delete Endpoints" -Options "YesNo" -Type "Question" -Sound
                    }
            
                    Switch ( $MessageBox ) {
                        'Yes' {
                            if ($script:ComputerTreeViewSelected.count -gt 0) {
                                foreach ($i in $script:ComputerTreeViewSelected) {
                                    [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
                                    foreach ($root in $AllTreeViewNodes) {
                                        foreach ($Category in $root.Nodes) {
                                            foreach ($Entry in $Category.nodes) {
                                                if ($Entry.checked) {
                                                    $Entry.remove()
                                                    # Removes the host from the variable storing the all the computers
                                                    $script:ComputerTreeViewData = $script:ComputerTreeViewData | Where-Object {$_.Name -ne $Entry.text}
                                                }
                                            }
                                        }
                                    }
                                }
                                # Removes selected category nodes - Note: had to put this in its own loop...
                                # the saving of nodes didn't want to work properly when use in the above loop when switching between treenode views.
                                foreach ($i in $script:ComputerTreeViewSelected) {
                                    foreach ($root in $AllTreeViewNodes) {
                                        foreach ($Category in $root.Nodes) {
                                            if ($Category.checked) { $Category.remove() }
                                        }
                                    }
                                }
                                # Removes selected root node - Note: had to put this in its own loop... see above category note
                                foreach ($i in $script:ComputerTreeViewSelected) {
                                    foreach ($root in $AllTreeViewNodes) {
                                        if ($root.checked) {
                                            foreach ($Category in $root.Nodes) { $Category.remove() }
                                            $root.remove()
                                            if ($i -eq "All Endpoints") { $script:ComputerTreeView.Nodes.Add($script:TreeNodeComputerList) }
                                        }
                                    }
                                }
            
                                $StatusListBox.Items.Clear()
                                $StatusListBox.Items.Add("Deleted:  $($script:ComputerTreeViewSelected.Count) Selected Items")
                                #Removed For Testing#$ResultsListBox.Items.Clear()
                                $ResultsListBox.Items.Add("The following hosts have been deleted:  ")
                                $ComputerListDeletedArray = @()
                                foreach ($Node in $script:ComputerTreeViewSelected) {
                                    if ($Node -notin $ComputerListDeletedArray) {
                                        $ComputerListDeletedArray += $Node
                                        $ResultsListBox.Items.Add(" - $Node")
                                    }
                                }
            
                                $ComputerAndAccountTreeViewTabControl.SelectedTab = $ComputerTreeviewTab
                                $script:ComputerTreeNodeComboBox.SelectedItem = 'CanonicalName'
                
                                Remove-TreeViewEmptyCategory -Endpoint
                                Save-TreeViewData -Endpoint
                            }
                            else { 
                                Show-MessageBox -Message "No hostname/IP selected`r`nMake sure to checkbox only one hostname/IP`r`nSelecting a Category will not allow you to connect to multiple hosts" -Title "Delete Selection:  Error"
                            }
                        }
                        'No' {
                            $StatusListBox.Items.Clear()
                            $StatusListBox.Items.Add('Endpoint Deletion Cancelled')
                        }
                    }
                }      
            }
        }
    }
    $ComputerListCheckedNodeActionsToolStripComboBox.Items.Add(' - Tag Nodes With Metadata')
    $ComputerListCheckedNodeActionsToolStripComboBox.Items.Add(' - NSLookup (Hostname to IP)')
    $ComputerListCheckedNodeActionsToolStripComboBox.Items.Add(' - Move Nodes To New OU/CN')
    $ComputerListCheckedNodeActionsToolStripComboBox.Items.Add(' - Delete Checked Nodes')
    $script:ComputerListContextMenuStrip.Items.Add($ComputerListCheckedNodeActionsToolStripComboBox)


    $script:ComputerListCheckedNodeActionsDeselectAllButton = New-Object System.Windows.Forms.ToolStripMenuItem -Property @{
        Image = [System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\UnChecked-Box.png")
        Text        = "Uncheck All Nodes"
        ForeColor   = 'Black'
        Add_Click   = {
            $script:ComputerListContextMenuStrip.Close()
            Deselect-AllComputers
        }
    }
    $script:ComputerListContextMenuStrip.Items.add($script:ComputerListCheckedNodeActionsDeselectAllButton)


    $script:ComputerListContextMenuStrip.Items.Add('-')
    

    $script:ComputerListEndpointAdditionalActionsToolStripLabel = New-Object System.Windows.Forms.ToolStripMenuItem -Property @{
        Image = [System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Squared-Menu-Blue.png")
        Text      = "Additional Actions"
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = 'Blue'
        Add_Click = { [System.Windows.Forms.MessageBox]::Show("This is just a heading, select another option","PoSh-EasyWin",'Ok',"Info") }
    }
    $script:ComputerListContextMenuStrip.Items.add($script:ComputerListEndpointAdditionalActionsToolStripLabel)


    $script:ComputerListContextMenuStrip.Items.Add('-')


    $script:ComputerListImportEndpointDataToolStripLabel = New-Object System.Windows.Forms.ToolStripMenuItem -Property @{
        Image = [System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Import-Data.png")
        Text      = "Import Endpoint Data"
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = 'Black'
        Add_Click = { [System.Windows.Forms.MessageBox]::Show("This is just a heading, select another option","PoSh-EasyWin",'Ok',"Info") }
    }
    $script:ComputerListContextMenuStrip.Items.add($script:ComputerListImportEndpointDataToolStripLabel)


    $ComputerListImportEndpointDataToolStripComboBox = New-Object System.Windows.Forms.ToolStripComboBox -Property @{
        Size        = @{ Width  = $FormScale * 200 }
        Text        = '  - Make a selection'
        ForeColor   = 'Black'
        ToolTipText = 'Import Endpoint Data from various sources. Conflicting endpoint names will not be imported.'
        Add_SelectedIndexChanged = {
            $script:ComputerListContextMenuStrip.Close()

            if ($This.selectedItem -eq ' - Active Directory') { 
                $script:ComputerListContextMenuStrip.Close()
                Import-DataFromActiveDirectory -Endpoint
            }
            if ($This.selectedItem -eq ' - Local .csv File')  { 
                $script:ComputerListContextMenuStrip.Close()
                Import-DataFromCsv -Endpoint
            }
            if ($This.selectedItem -eq ' - Local .txt File')  { 
                $script:ComputerListContextMenuStrip.Close()
                Import-DataFromTxt -Endpoint
            }
        }
    }
    $ComputerListImportEndpointDataToolStripComboBox.Items.Add(' - Active Directory')
        # Opens a form that provides you options on how to import endpoint data from Acitve Directory
        # Options include:
        #   - Import from Domain with Directory Searcher
        #   - Import from Active Directory remotely using WinRM
        #   - Import from Active Directory Locally
    $ComputerListImportEndpointDataToolStripComboBox.Items.Add(' - Local .csv File')
        # Imports data from a selected Comma Separated Value file
        # This file can be easily generated with the following command:
        #   - Get-ADComputer -Filter * -Properties Name,OperatingSystem,CanonicalName,IPv4Address,MACAddress | Export-Csv "Domain Computers.csv"
        # This file should be formatted with the following headers, though the import script should populate default missing data:
        #   - Name
        #   - OperatingSystem
        #   - CanonicalName
        #   - IPv4Address
        #   - MACAddress
        #   - Notes    
    $ComputerListImportEndpointDataToolStripComboBox.Items.Add(' - Local .txt File')
        # Imports data from a selected Text file
        # Useful if you recieve a computer list file from an Admin or outputted from nmap
        # This file should be formatted with one hostname or IP address per line
    $script:ComputerListContextMenuStrip.Items.Add($ComputerListImportEndpointDataToolStripComboBox)


    $script:ComputerListRenameToolStripLabel = New-Object System.Windows.Forms.ToolStripMenuItem -Property @{
        Image = [System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\View-Data.png")
        Text      = 'View Endpoint Data'
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = 'Black'
        Add_Click = { [System.Windows.Forms.MessageBox]::Show("This is just a heading, select another option","PoSh-EasyWin",'Ok',"Info") }
    }
    $script:ComputerListContextMenuStrip.Items.add($script:ComputerListRenameToolStripLabel)


    $ComputerListViewEndpointDataToolStripComboBox = New-Object System.Windows.Forms.ToolStripComboBox -Property @{
        Size        = @{ Width  = $FormScale * 200 }
        Text        = '  - Make a selection'
        ForeColor   = 'Black'
        ToolTipText = 'View the local data for all endpoints that populates the treeview.'
        Add_SelectedIndexChanged = {
            $script:ComputerListContextMenuStrip.Close()

            if ($This.selectedItem -eq ' - Out-GridView') { 
                $script:ComputerListContextMenuStrip.Close()
                Import-Csv -Path $script:EndpointTreeNodeFileSave | Out-GridView -Title 'Endpoint Data'
            }
            if ($This.selectedItem -eq ' - Spreadsheet Software')  { 
                $script:ComputerListContextMenuStrip.Close()
                Invoke-Item -Path $script:EndpointTreeNodeFileSave
            }
            if ($This.selectedItem -eq ' - Browser HTML View')  { 
                $script:ComputerListContextMenuStrip.Close()
                Import-Csv -Path $script:EndpointTreeNodeFileSave | Out-HTMLView -Title 'Endpoint Data'
            }
        }
    }
    $ComputerListViewEndpointDataToolStripComboBox.Items.Add(' - Out-GridView')
    $ComputerListViewEndpointDataToolStripComboBox.Items.Add(' - Spreadsheet Software')
    $ComputerListViewEndpointDataToolStripComboBox.Items.Add(' - Browser HTML View')
    $script:ComputerListContextMenuStrip.Items.Add($ComputerListViewEndpointDataToolStripComboBox)    

    

    $script:ComputerListEndpointUpdateTreeviewToolStripLabel = New-Object System.Windows.Forms.ToolStripMenuItem -Property @{
        Image = [System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Update-TreeView.png")
        Text      = 'Update TreeView'
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = 'Black'
        Add_Click = { [System.Windows.Forms.MessageBox]::Show("This is just a heading, select another option","PoSh-EasyWin",'Ok',"Info") }
    }
    $script:ComputerListContextMenuStrip.Items.add($script:ComputerListEndpointUpdateTreeviewToolStripLabel)


    $ComputerListEndpointUpdateTreeviewToolStripComboBox = New-Object System.Windows.Forms.ToolStripComboBox -Property @{
        Size        = @{ Width  = $FormScale * 200 }
        Text        = '  - Make a selection'
        ForeColor   = 'Black'
        ToolTipText = 'Quickly modify the endpoint treeview to better manage and find nodes.'
        Add_SelectedIndexChanged = {
            $script:ComputerListContextMenuStrip.Close()
            
            if ($This.selectedItem -eq ' - Collapsed View') { 
                $script:ComputerListContextMenuStrip.Close()

                [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
                $script:ComputerTreeView.CollapseAll()
                foreach ($root in $AllTreeViewNodes) { $root.Expand() }
            }
            if ($This.selectedItem -eq ' - Normal View')  { 
                $script:ComputerListContextMenuStrip.Close()

                [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
                $script:ComputerTreeView.CollapseAll()
                foreach ($root in $AllTreeViewNodes) {  
                    $root.Expand() 
                    foreach ($Category in $root.nodes) {
                        $Category.Expand()
                    }
                }
            }
            if ($This.selectedItem -eq ' - Expanded View')  { 
                $script:ComputerListContextMenuStrip.Close()

                [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
                foreach ($root in $AllTreeViewNodes) {  
                    $root.Expand() 
                    foreach ($Category in $root.nodes) {
                        $Category.Expand()
                        foreach ($Entry in $Category.nodes){
                            $Entry.Expand()
                            foreach($Metadata in $Entry.nodes){
                                $Metadata.Expand()
                                foreach($Data in $Metadata.nodes){
                                    $Data.Expand()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    $ComputerListEndpointUpdateTreeviewToolStripComboBox.Items.Add(' - Collapsed View')
    $ComputerListEndpointUpdateTreeviewToolStripComboBox.Items.Add(' - Normal View')
    $ComputerListEndpointUpdateTreeviewToolStripComboBox.Items.Add(' - Expanded View')
    $script:ComputerListContextMenuStrip.Items.Add($ComputerListEndpointUpdateTreeviewToolStripComboBox)    


    $script:ComputerListContextMenuStrip.Items.Add('-')


    $Entry.ContextMenuStrip = $script:ComputerListContextMenuStrip
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUrjgcLlN6pjY32N+oJ72bkEZb
# GJygggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
# AQUFADAzMTEwLwYDVQQDDChQb1NoLUVhc3lXaW4gQnkgRGFuIEtvbW5pY2sgKGhp
# Z2gxMDFicm8pMB4XDTIxMTIxNDA1MDIwMFoXDTMxMTIxNDA1MTIwMFowMzExMC8G
# A1UEAwwoUG9TaC1FYXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALvIxUDFEVGB/G0FXPryoNlF
# dA65j5jPEFM2R4468rjlTVsNYUOR+XvhjmhpggSQa6SzvXtklUJIJ6LgVUpt/0C1
# zlr1pRwTvsd3svI7FHTbJahijICjCv8u+bFcAR2hH3oHFZTqvzWD1yG9FGCw2pq3
# h4ahxtYBd1+/n+jOtPUoMzcKIOXCUe4Cay+xP8k0/OLIVvKYRlMY4B9hvTW2CK7N
# fPnvFpNFeGgZKPRLESlaWncbtEBkexmnWuferJsRtjqC75uNYuTimLDSXvNps3dJ
# wkIvKS1NcxfTqQArX3Sg5qKX+ZR21uugKXLUyMqXmVo2VEyYJLAAAITEBDM8ngUC
# AwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0G
# A1UdDgQWBBSDJIlo6BcZ7KJAW5hoB/aaTLxFzTANBgkqhkiG9w0BAQUFAAOCAQEA
# ouCzal7zPn9vc/C9uq7IDNb1oNbWbVlGJELLQQYdfBE9NWmXi7RfYNd8mdCLt9kF
# CBP/ZjHKianHeZiYay1Tj+4H541iUN9bPZ/EaEIup8nTzPbJcmDbaAGaFt2PFG4U
# 3YwiiFgxFlyGzrp//sVnOdtEtiOsS7uK9NexZ3eEQfb/Cd9HRikeUG8ZR5VoQ/kH
# 2t2+tYoCP4HsyOkEeSQbnxlO9s1jlSNvqv4aygv0L6l7zufiKcuG7q4xv/5OvZ+d
# TcY0W3MVlrrNp1T2wxzl3Q6DgI+zuaaA1w4ZGHyxP8PLr6lMi6hIugI1BSYVfk8h
# 7KAaul5m+zUTDBUyNd91ojGCAegwggHkAgEBMEcwMzExMC8GA1UEAwwoUG9TaC1F
# YXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKQIQeugH5LewQKBKT6dP
# XhQ7sDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkq
# hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGC
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUufVpIx3GCR2j5Y7sNl74d7/VK4cwDQYJKoZI
# hvcNAQEBBQAEggEAZvsx1Waj/ozNswGwp+wAeuNnEH3+rFOs15M/V5L4+gbQAOjS
# XZ9+sxBj3guSlGWEwf1fkEjFaXSvy8bo0E9PUUZvG6vcCE0ePNrYxM9VCSc+KcJs
# J/PUwP4o9F8r6MYvaxvHNdo0sV1gZSyL4UhMwh61IQqfcz0UmhRBMq33jx3hMvMh
# aeVsUpkqynovSsBszti7+F1YLORJvqK6oXrIe5SMJopDB4mQNsVurl/5ltgMvraX
# FmkU+us951CLbOcUNEMuJUpYaHrHv7lmwLG4OnXsyNrmt+Mqhq3LicGC3zCR+jPf
# 6i5twOIB596s48pkp0UNz/c1N+tTz9TN/1OIaw==
# SIG # End signature block
