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
            Generate-NewRollingPassword
        }
    }
    else {
        [system.media.systemsounds]::Exclamation.play()
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Event Viewer:  Cancelled")
    }
}


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU+3WD1v/nle1aenPKWO9SBxb2
# t6mgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU1JvIQCZLTTQ5QzAweIBucaOnsOUwDQYJKoZI
# hvcNAQEBBQAEggEAA+tYCmIknYhcfs4fuzz+XOKayc7UlQRIt6L6orrAtaZtc16B
# VpnsqU7ZrXl/GP2oaiycUDSxXf3PTo6UH3TmzKKiJKCegNNhnT5ZaOy0iQ96kqlh
# rNrCqvGG2gzaWtvxXd3TErQTKl0YvL3OsJ88oB/IiabDSWWgXM+9FmyN6HoZIZ2K
# UBu8EPHWQbOEAMH+bYgvNoUROSmuOW+UN1EjK68RvZshSpymFf11hF4o8loFWhZS
# uw2YdxHI8bNCQHaaGoj5uqOle24LyJzwN9B9uticQW1GUiOXhi6saM0dD2Ebo9zN
# iIs86gI4asWGcEdA170ChgcEA2jJtGmNBqQ+nQ==
# SIG # End signature block
