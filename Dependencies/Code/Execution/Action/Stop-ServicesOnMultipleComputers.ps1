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
            InitialDirectory = "$(if (Test-Path $($script:CollectionSavedDirectoryTextBox.Text)) {$($script:CollectionSavedDirectoryTextBox.Text)} else {$PewCollectedData})"
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
            Show-MessageBox -Message 'Ensure you checkbox one or more endpoints to collect Service data from.' -Title "PoSh-EasyWin - No Endpoints Selected" -Options "Ok" -Type "Error" -Sound
        }
        else {
            if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { Set-NewCredential }
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
                Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "New-PSSession -ComputerName $Computer -Credential $script:Credential"
            }
            else {
                $Session = New-PSSession -ComputerName $Computer
                Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "New-PSSession -ComputerName $Computer"
            }
            #Write-Host "Connected to:  $Computer" -ForegroundColor Cyan
            $ResultsListBox.Items.Insert(0,"Connected to:  $Computer")

            if ($Session) {
                foreach ($Service in $ServicesToStop){
                    if ($Service.PSComputerName -eq $Computer){
                        $ServiceName = $Service.Name
                        #Write-Host "  - Stopping:  $Service" -ForegroundColor Green
                        $ResultsListBox.Items.Insert(1,"  - Stopping Service:  [Computer]$Computer  [Service]$($Service.Name)  [Display Name]$($Service.DisplayName)")
                        Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { param(`$ServiceName,`$ServiceID); Stop-Service -Name $ServiceName -Force | Where-Object {`$_.Id -eq $ServiceID}} -ArgumentList @(`$ServiceName,`$ServiceID) -Session `$Session"
                        Invoke-Command -ScriptBlock { param($ServiceName); Stop-Service -Name $ServiceName } -ArgumentList $ServiceName -Session $Session
                    }
                }
                Remove-PSSession -Session $Session
                Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Remove-PSSession -Session $Session"
            }
        }
        catch {
            #Write-Host "Unable to Connect:  $Computer" -ForegroundColor Red
            $ResultsListBox.Items.Insert(1,"Unable to Connect:  $Computer")
            Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Unable to Connect:  $Computer"
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUz0c+wtP2oL5dqooPQBuGEDUc
# 30WgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUnTVlaGCkFpt4IguVI2vChhZKZJYwDQYJKoZI
# hvcNAQEBBQAEggEASiocKQlEkizsKh99ZzAM7FeR7VZ6fU+My/htRjSXaCmVQPhE
# I9mxJokoc20vx8zohroEwSw3Fn+wy+6/GB1rr2UBcoha0UlvRc4bpvF2fX9ZQWnk
# dbSSE8mXM/t9hHCPxrsyftVv92GTHt5vmrOA9zk5VAnIUqmOp6re+qCVIylwRX73
# hWI6o58AW+b0G7Bc4VjV8VUt4sOv8JwDrnsN9mPEGkJTuWsNo4zlmAXi7NZlMXEM
# QZ4HaCKBsjGbyYFPX3ngWQM+ez0XMQGCsGk7KuI40IFcpNHVdxsLLRUK8jjcwU1N
# nrAUMLCWHfuVVtSL4xrCYYd6xc9i6MS8GxWIhw==
# SIG # End signature block
