function Stop-ProcessesOnMultipleComputers {
    param(
        [switch]$SelectProcessCsvFile,
        [switch]$CollectNewProcessData
    )
    $InformationTabControl.SelectedTab = $Section3ResultsTab

    if ($SelectProcessCsvFile) {
        [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
        $SelectProcessFileToStopSelectedProcessesOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{
            Title            = "Select Process File to Stop Selected Processes"
            InitialDirectory = "$(if (Test-Path $($script:CollectionSavedDirectoryTextBox.Text)) {$($script:CollectionSavedDirectoryTextBox.Text)} else {$CollectedDataDirectory})"
            Filter           = "CSV (*.csv)|*.csv|All files (*.*)|*.*"
            ShowHelp         = $true
        }
        $SelectProcessFileToStopSelectedProcessesOpenFileDialog.ShowDialog() | Out-Null

        Import-Csv -Path $($SelectProcessFileToStopSelectedProcessesOpenFileDialog.filename) `
        | Select-Object -Property PSComputerName, * -ErrorAction SilentlyContinue `
        | Sort-Object -Property Name, PSComputername, * -ErrorAction SilentlyContinue `
        | Out-GridView -Title 'Select Processes To Stop' -PassThru -OutVariable ProcessesToStop
    }
    elseif ($CollectNewProcessData) {
        Generate-ComputerList

        if ($script:ComputerList.count -eq 0){
            Show-MessageBox -Message 'Ensure you checkbox one or more endpoints to collect process data from. Alternatively, you can select a CSV file from a previous process collection.' -Title "PoSh-EasyWin - No Endpoints Selected" -Options "Ok" -Type "Error" -Sound
        }
        else {
            if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { Set-NewCredential }
                Invoke-Command -ScriptBlock {
                    Get-Process #| Select-Object -Property @{n='PSComputerName';e={$(hostname)}}, *
                } -ComputerName $script:ComputerList -Credential $script:Credential `
                | Select-Object -Property PSComputerName, * -ErrorAction SilentlyContinue `
                | Sort-Object -Property Name, PSComputername, * -ErrorAction SilentlyContinue `
                | Out-GridView -Title 'Select Processes To Stop' -PassThru -OutVariable ProcessesToStop
            }
            else {
                Invoke-Command -ScriptBlock {
                    Get-Process #| Select-Object -Property @{n='PSComputerName';e={$(hostname)}}, *
                } -ComputerName $script:ComputerList `
                | Select-Object -Property PSComputerName, * -ErrorAction SilentlyContinue `
                | Sort-Object -Property Name, PSComputername, * -ErrorAction SilentlyContinue `
                | Out-GridView -Title 'Select Processes To Stop' -PassThru -OutVariable ProcessesToStop
            }
        }
    }

    $ProcessesToStop = $ProcessesToStop | Sort-Object -Property PSComputerName
    $Computers = $ProcessesToStop | Select-Object -ExpandProperty PSComputerName -Unique | Sort-Object

    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Multi-Endpoint Process Stopper")
    $ResultsListBox.Items.Clear()

    foreach ($Computer in $Computers) {
        $Session = $null

        try {
            if ($script:Credential) {
                $Session = New-PSSession -ComputerName $Computer -Credential $script:Credential
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "New-PSSession -ComputerName $Computer -Credential $script:Credential"
            }
            else {
                $Session = New-PSSession -ComputerName $Computer
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "New-PSSession -ComputerName $Computer"
            }
            #Write-Host "Connected to:  $Computer" -ForegroundColor Cyan
            $ResultsListBox.Items.Insert(0,"Connected to:  $Computer")

            if ($Session) {
                foreach ($Process in $ProcessesToStop){
                    if ($Process.PSComputerName -eq $Computer){
                        $ProcessName = $Process.Name
                        $ProcessId   = $Process.id
                        $ResultsListBox.Items.Insert(1,"  - Stopping Process:  [Computer]$Computer  [Process]$($ProcessName)  [PID]$($ProcessId)")
                        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { param(`$ProcessName,`$ProcessID); Stop-Process -Name $ProcessName | Where-Object {`$_.Id -eq $ProcessID}} -ArgumentList @(`$ProcessName,`$ProcessID) -Session `$Session"
                        Invoke-Command -ScriptBlock { param($ProcessName,$ProcessID); Stop-Process -Name $ProcessName -Force | Where-Object {$_.Id -eq $ProcessID}} -ArgumentList @($ProcessName,$ProcessID) -Session $Session
                    }
                }
                Remove-PSSession -Session $Session
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Remove-PSSession -Session $Session"
            }
        }
        catch {
            #Write-Host "Unable to Connect:  $Computer" -ForegroundColor Red
            $ResultsListBox.Items.Insert(1,"Unable to Connect:  $Computer")
            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Unable to Connect:  $Computer"
        }
    }
    # To alert the user that it's finished
    [system.media.systemsounds]::Exclamation.play()

    if ($script:RollCredentialsState -and $script:ComputerListProvideCredentialsCheckBox.checked) {
        Start-Sleep -Seconds 3
        Set-NewRollingPassword
    }
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUtXqldCIUE+x+bFXdMobCpLp8
# b/WgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU/6z5ZLfNU/l2KXNYfIWlMrD43lYwDQYJKoZI
# hvcNAQEBBQAEggEAKTfU2VlXshq2XzP3GtndboccX0kwybxFBVhkXuC8CXYRTUed
# /FrjRadED1xgku7PQHLX+uIGK/JLZ1BSyqUfZh9HEahdbMG35BCiwJZ0/3zwgIoD
# t8uOEIReZDltixF4csngViKCN09gfXFlRLsgCeicEz0NmS1zon2zUDRpszMdOc5z
# xdGgch28RZIPbbyM5oWGg5zy3wjHzyNUUm/nq9Ld/21rmSGnHi20zPBkZPcvnBHE
# QxniG9iRKjn0s/pT/UjQGvvK3zmBX782paWpbl6/TjW+SWd7aTiOxLi9Ozqp27gb
# fRcMRZakoaG/4ndDhTl9m8HT0xHSyV9phc+EFA==
# SIG # End signature block
