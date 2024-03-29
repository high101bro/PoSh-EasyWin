function Logout-AccountsOnMultipleComputers {
    param(
        [switch]$SelectAccountCsvFile,
        [switch]$CollectNewAccountData
    )
    $InformationTabControl.SelectedTab = $Section3ResultsTab

    if ($SelectAccountCsvFile) {
        [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
        $SelectFileToLogoutSelectedAccountsOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{
            Title            = "Select File to Stop Selected Accounts"
            InitialDirectory = "$(if (Test-Path $($script:CollectionSavedDirectoryTextBox.Text)) {$($script:CollectionSavedDirectoryTextBox.Text)} else {$PewCollectedData})"
            Filter           = "CSV (*.csv)|*.csv|All files (*.*)|*.*"
            ShowHelp         = $true
        }
        $SelectFileToLogoutSelectedAccountsOpenFileDialog.ShowDialog() | Out-Null

        Import-Csv -Path $($SelectFileToLogoutSelectedAccountsOpenFileDialog.filename) `
        | Select-Object -Property PSComputerName, * -ErrorAction SilentlyContinue `
        | Sort-Object -Property Name, PSComputername, * -ErrorAction SilentlyContinue `
        | Out-GridView -Title 'Select Accounts To Logout' -PassThru -OutVariable AccountsToLogout
    }
    elseif ($CollectNewAccountData) {
        Generate-ComputerList

        if ($script:ComputerList.count -eq 0){
            Show-MessageBox -Message 'Error: Ensure you checkbox one or more endpoints to collect accounts logon info from.' -Title "PoSh-EasyWin - No Endpoints Selected" -Options "Ok" -Type "Error" -Sound
        }
        else {
            if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                $ScriptBlock = {
                    ## Find all sessions matching the specified username
                    $quser = quser | Where-Object {$_ -notmatch 'SESSIONNAME'}

                    $sessions = ($quser -split "`r`n").trim()

                    foreach ($session in $sessions) {
                        try {
                            # This checks if the value is an integer, if it is then it'll TRY, if it errors then it'll CATCH
                            [int]($session -split '  +')[2] | Out-Null

                            [PSCustomObject]@{
                                PSComputerName = $env:COMPUTERNAME
                                UserName       = ($session -split '  +')[0].TrimStart('>')
                                SessionName    = ($session -split '  +')[1]
                                SessionID      = ($session -split '  +')[2]
                                State          = ($session -split '  +')[3]
                                IdleTime       = ($session -split '  +')[4]
                                LogonTime      = ($session -split '  +')[5]
                            }
                        }
                        catch {
                            [PSCustomObject]@{
                                PSComputerName = $env:COMPUTERNAME
                                UserName       = ($session -split '  +')[0].TrimStart('>')
                                SessionName    = ''
                                SessionID      = ($session -split '  +')[1]
                                State          = ($session -split '  +')[2]
                                IdleTime       = ($session -split '  +')[3]
                                LogonTime      = ($session -split '  +')[4]
                            }
                        }
                    }
                }
                if (!$script:Credential) { Set-NewCredential }
                Invoke-Command -ScriptBlock $ScriptBlock -ComputerName $script:ComputerList -Credential $script:Credential `
                | Select-Object -ExcludeProperty RunspaceID `
                | Out-GridView -Title 'Select Accounts To Logout' -PassThru -OutVariable AccountsToLogout
            }
            else {
                Invoke-Command -ScriptBlock $ScriptBlock -ComputerName $script:ComputerList `
                | Select-Object -ExcludeProperty RunspaceID `
                | Out-GridView -Title 'Select Accounts To Logout' -PassThru -OutVariable AccountsToLogout
            }
        }
    }

    $AccountsToLogout = $AccountsToLogout | Sort-Object -Property PSComputerName
    $Computers = $AccountsToLogout | Select-Object -ExpandProperty PSComputerName -Unique | Sort-Object

    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Multi-Endpoint Account Logout")
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
            $ResultsListBox.Items.Insert(0,"Connected to:  $Computer")

            if ($Session) {
                foreach ($Logon in $AccountsToLogout){
                    if ($Logon.PSComputerName -eq $Computer){
                        $AccountName = $Logon.AccountName
                        $SessionID   = $Logon.SessionID
                        $ResultsListBox.Items.Insert(1,"  - Logging Out:  [Computer]$Computer  [Account]$AccountName  [SessionID]$SessionId")
                        Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { param($SessionID) C:\Windows\System32\Logoff.exe $SessionID } -ArgumentList $SessionID -Session $Session"
                        Invoke-Command -ScriptBlock {
                            param($SessionID)
                            & 'C:\Windows\System32\Logoff.exe' $SessionID
                        } -ArgumentList $SessionID -Session $Session
                    }
                }
                Remove-PSSession -Session $Session
                Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Remove-PSSession -Session $Session"
            }
        }
        catch {
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUlw726CkhvU8w9h5ltFHL0ud6
# ClugggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUo4iQaSH/sI5CIj6TkMrcQ3ZictMwDQYJKoZI
# hvcNAQEBBQAEggEAR5/zRbiswhmxbtN5pREbw2Qpp+VnNLRn6YGnETSEiLl50PC4
# gpTY06dzWWyYPnMNG9SmfQOF6z5ef3A2eilol0qHUEBvg2Cm/mNFat7zsaDhQuVi
# MCa+KGbVZqMj+xRxVt+OJeu0uwQEeCoo2ANsgkqX6YIj9/QfDMS1/YfCCWYXVfv5
# wLoJnm8G6sH1IwNPNoSaVv+yEANqQoiPK8qgiQBhx4RRYnZcejxh/LjnMB7oRQ4S
# tQ1bvoOmXKJZ2HyZF/XV5oMGtyFw/cGTVMP2G3LPflnSvfBByoxYCQfVoe84s0Od
# sdZJiaZskUzAJZff2WCYCxjlg/5ZDsk1LDbrtQ==
# SIG # End signature block
