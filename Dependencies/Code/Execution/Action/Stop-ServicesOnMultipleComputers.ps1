function Stop-ServicesOnMultipleComputers {
    param(
        [switch]$SelectServiceCsvFile,
        [switch]$CollectNewServiceData
    )
    $InformationTabControl.SelectedTab = $Section3ResultsTab

    if ($SelectServiceCsvFile) {
        [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
        $SelectServiceFileToStopSelectedServicesOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{
            Title            = "Select Service File to Stop Selected Services"
            InitialDirectory = "$(if (Test-Path $($script:CollectionSavedDirectoryTextBox.Text)) {$($script:CollectionSavedDirectoryTextBox.Text)} else {$CollectedDataDirectory})"
            Filter           = "CSV (*.csv)|*.csv|All files (*.*)|*.*"
            ShowHelp         = $true
        }
        $SelectServiceFileToStopSelectedServicesOpenFileDialog.ShowDialog() | Out-Null

        Import-Csv -Path $($SelectServiceFileToStopSelectedServicesOpenFileDialog.filename) `
        | Select-Object -Property PSComputerName, * -ErrorAction SilentlyContinue `
        | Sort-Object -Property Name, PSComputername, * -ErrorAction SilentlyContinue `
        | Out-GridView -Title 'Select Services To Stop' -PassThru -OutVariable ServicesToStop
    }
    elseif ($CollectNewServiceData) {
        Generate-ComputerList

        if ($script:ComputerList.count -eq 0){
            [System.Windows.MessageBox]::Show('Ensure you checkbox one or more endpoints to collect Service data from. Alternatively, you can select a CSV file from a previous Service collection.','Error: No Endpoints Selected')
        }
        else {
            if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { Create-NewCredentials }
                Invoke-Command -ScriptBlock {
                    Get-Service #| Select-Object -Property @{n='PSComputerName';e={$(hostname)}}, *
                } -ComputerName $script:ComputerList -Credential $script:Credential `
                | Select-Object -Property PSComputerName, * -ErrorAction SilentlyContinue `
                | Sort-Object -Property Name, PSComputername, * -ErrorAction SilentlyContinue `
                | Out-GridView -Title 'Select Services To Stop' -PassThru -OutVariable ServicesToStop
            }
            else {
                Invoke-Command -ScriptBlock {
                    Get-Service #| Select-Object -Property @{n='PSComputerName';e={$(hostname)}}, *
                } -ComputerName $script:ComputerList `
                | Select-Object -Property PSComputerName, * -ErrorAction SilentlyContinue `
                | Sort-Object -Property Name, PSComputername, * -ErrorAction SilentlyContinue `
                | Out-GridView -Title 'Select Services To Stop' -PassThru -OutVariable ServicesToStop
            }
        }
    }

    $ServicesToStop = $ServicesToStop | Sort-Object -Property PSComputerName
    $Computers = $ServicesToStop | Select-Object -ExpandProperty PSComputerName -Unique | Sort-Object

    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Multi-Endpoint Service Stopper")
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
                foreach ($Service in $ServicesToStop){
                    if ($Service.PSComputerName -eq $Computer){
                        $ServiceName = $Service.Name
                        #Write-Host "  - Stopping:  $Service" -ForegroundColor Green
                        $ResultsListBox.Items.Insert(1,"  - Stopping Service:  [Computer]$Computer  [Service]$($Service.Name)  [Display Name]$($Service.DisplayName)")
                        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { param(`$ServiceName,`$ServiceID); Stop-Service -Name $ServiceName -Force | Where-Object {`$_.Id -eq $ServiceID}} -ArgumentList @(`$ServiceName,`$ServiceID) -Session `$Session"
                        Invoke-Command -ScriptBlock { param($ServiceName); Stop-Service -Name $ServiceName } -ArgumentList $ServiceName -Session $Session
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUjbATbCTV/FuUA9/YecgCQ/Je
# BySgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUoUbaaTF3vAtOfcJXAKT8t01KZNkwDQYJKoZI
# hvcNAQEBBQAEggEACbzorzS9HwgdKanTQZqXq6c6jrLSbpYoNmmsffY34Aig/Bpf
# OacOnK/iPEo0cRWJyIjxvmKxf3DS5HagoDx277jBZbsKKSZdwO2yfbZKG0a7uwSy
# wAcsJkuKmYKE2s2bK3OlDjyLCCMwxFli23OKNzQL3wH5TOP/g+iOq246s/Hzvour
# pr8Wch7JPh8Pp+eG0oIsmyTDVcpMdiv2VjyidszeOEJH7fuWY9g1d+MipwcQnNJT
# hy2rLLl34+ML6TXN7tioCC3NZRzmab3OWimxw4EsUAkWSHdv+fGXRLF1ZwX8REhX
# tyNTdYtkGmjLrnLVMuEM4SmEx0DHa1y9ZQG7Tg==
# SIG # End signature block
