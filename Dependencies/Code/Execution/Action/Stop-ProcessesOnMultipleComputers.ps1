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
            [System.Windows.MessageBox]::Show('Ensure you checkbox one or more endpoints to collect process data from. Alternatively, you can select a CSV file from a previous process collection.','Error: No Endpoints Selected')
        }
        else {
            if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { Create-NewCredentials }
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
        Generate-NewRollingPassword
    }
}





# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUAFwdXuLV3wy4QbTlhGpKsiBp
# kHSgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
# AQUFADAzMTEwLwYDVQQDDChQb1NoLUVhc3lXaW4gQnkgRGFuIEtvbW5pY2sgKGhp
# Z2gxMDFicm8pMB4XDTIxMTEyOTIzNDA0NFoXDTMxMTEyOTIzNTA0M1owMzExMC8G
# A1UEAwwoUG9TaC1FYXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANUnnNeIFC/eQ11BjDFsIHp1
# 2HkKgnRRV07Kqsl4/fibnbOclptJbeKBDQT3iG5csb31s9NippKfzZmXfi69gGE6
# v/L3X4Zb/10SJdFLstfT5oUD7UdiOcfcNDEiD+8OpZx4BWl5SNWuSv0wHnDSIyr1
# 2M0oqbq6WA2FqO3ETpdhkK22N3C7o+U2LeuYrGxWOi1evhIHlnRodVSYcakmXIYh
# pnrWeuuaQk+b5fcWEPClpscI5WiQh2aohWcjSlojsR+TiWG/6T5wKFxSJRf6+exu
# C0nhKbyoY88X3y/6qCBqP6VTK4C04tey5z4Ux4ibuTDDePqH5WpRFMo9Vie1nVkC
# AwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0G
# A1UdDgQWBBS2KLS0Frf3zyJTbQ4WsZXtnB9SFDANBgkqhkiG9w0BAQUFAAOCAQEA
# s/TfP54uPmv+yGI7wnusq3Y8qIgFpXhQ4K6MmnTUpZjbGc4K3DRJyFKjQf8MjtZP
# s7CxvS45qLVrYPqnWWV0T5NjtOdxoyBjAvR/Mhj+DdptojVMMp2tRNPSKArdyOv6
# +yHneg5PYhsYjfblzEtZ1pfhQXmUZo/rW2g6iCOlxsUDr4ZPEEVzpVUQPYzmEn6B
# 7IziXWuL31E90TlgKb/JtD1s1xbAjwW0s2s1E66jnPgBA2XmcfeAJVpp8fw+OFhz
# Q4lcUVUoaMZJ3y8MfS+2Y4ggsBLEcWOK4vGWlAvD5NB6QNvouND1ku3z94XmRO8v
# bqpyXrCbeVHascGVDU3UWTGCAegwggHkAgEBMEcwMzExMC8GA1UEAwwoUG9TaC1F
# YXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKQIQVnYuiASKXo9Gly5k
# J70InDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkq
# hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGC
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUYDj0hxAz3soVlH5kvKIVft8hz+0wDQYJKoZI
# hvcNAQEBBQAEggEARXsMIsWeqQ1QBO9C7LuODT12K0l+LGs8kbWilJBBabL59qMo
# 96A61g+sdrTop7yZWkObiYqFNwoyvFlIXnFw93CHuhwYcl0QS2jlZWtJJ6B6uqKm
# gVJXwg5tppmPdjhozhDILChQCOzPQzp54tC8YIbxgOnXW0U1K9jFkb6QVb+4kBfl
# yjsJMRiSiShnrDdOFKHZY8515sfEC8SyXyVsRFZ9sib/cQhKHUrQI7lRDV2JvU0X
# wQT+xhh/YMPHsPuFcn+cauXxCYWv0DcRVoNWZGfFmuYQEIV0ADn2JMk2SI5IcCVQ
# hHzleUEPIGKh9oKEqN1xy2kG6xyEQ0UCUMq2XQ==
# SIG # End signature block
