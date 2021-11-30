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
            InitialDirectory = "$(if (Test-Path $($script:CollectionSavedDirectoryTextBox.Text)) {$($script:CollectionSavedDirectoryTextBox.Text)} else {$CollectedDataDirectory})"
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
            [System.Windows.MessageBox]::Show('Ensure you checkbox one or more endpoints to collect accounts logon info from. Alternatively, you can select a CSV file from a previous Accounts Currently Logon collection.','Error: No Endpoints Selected')
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
                if (!$script:Credential) { Create-NewCredentials }
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
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "New-PSSession -ComputerName $Computer -Credential $script:Credential"
            }
            else {
                $Session = New-PSSession -ComputerName $Computer
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "New-PSSession -ComputerName $Computer"
            }
            $ResultsListBox.Items.Insert(0,"Connected to:  $Computer")

            if ($Session) {
                foreach ($Logon in $AccountsToLogout){
                    if ($Logon.PSComputerName -eq $Computer){
                        $AccountName = $Logon.AccountName
                        $SessionID   = $Logon.SessionID
                        $ResultsListBox.Items.Insert(1,"  - Logging Out:  [Computer]$Computer  [Account]$AccountName  [SessionID]$SessionId")
                        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { param($SessionID) C:\Windows\System32\Logoff.exe $SessionID } -ArgumentList $SessionID -Session $Session"
                        Invoke-Command -ScriptBlock {
                            param($SessionID)
                            & 'C:\Windows\System32\Logoff.exe' $SessionID
                        } -ArgumentList $SessionID -Session $Session
                    }
                }
                Remove-PSSession -Session $Session
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Remove-PSSession -Session $Session"
            }
        }
        catch {
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU40zpvtOz3Nlo5hrHAX1Bp8OE
# m6OgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU0mAPMG3et7m24Bm4IkIPw0jsz18wDQYJKoZI
# hvcNAQEBBQAEggEAx1NiRrmOwdz2gMI4C3lu0W/bod+xeGu+8Ubnj2naSrC/WC9G
# YGuDSCJDhGExkLjvYDLAAbGCcEXHVPJ+VJLprV0/9/zKBkMWVO8dvO66EGnAjUx1
# FOVugKKwhZ2dwqVzkGPBEt5j5tJ43PdSB8nRgfBzCQuJ2kxaPxBelk6eDemzCwAl
# MT2/eB8BQyM880JdAeGjnFmVtc/YgAohgexEr3+LZgf0WCZzrMC1CDO/EOds/qPk
# /DeqBbBF8lDn/vEe4cx0hl+lzUiDX2vU+gw5d8KiJd1f0g4zPr+K/vJiCCt16XaG
# ERRKHycIUXdN4o418ugBMX4M+z5YWxmv2xvVdg==
# SIG # End signature block
