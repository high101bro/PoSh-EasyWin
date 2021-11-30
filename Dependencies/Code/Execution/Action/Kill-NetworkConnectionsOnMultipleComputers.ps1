function Kill-NetworkConnectionsOnMultipleComputers {
    param(
        [switch]$SelectNetworkConnectionsCsvFile,
        [switch]$CollectNewNetworkConnections
    )
    $InformationTabControl.SelectedTab = $Section3ResultsTab

    $ResultsListBox.Items.Clear()

    if ($SelectNetworkConnectionsCsvFile) {
        [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
        $SelectFileToKillSelectedConnectionsOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{
            Title            = "Select File to Kill Selected Network Connections"
            InitialDirectory = "$(if (Test-Path $($script:CollectionSavedDirectoryTextBox.Text)) {$($script:CollectionSavedDirectoryTextBox.Text)} else {$CollectedDataDirectory})"
            Filter           = "CSV (*.csv)|*.csv|All files (*.*)|*.*"
            ShowHelp         = $true
        }
        $SelectFileToKillSelectedConnectionsOpenFileDialog.ShowDialog() | Out-Null

        Import-Csv -Path $($SelectFileToKillSelectedConnectionsOpenFileDialog.filename) `
        | Select-Object -Property PSComputerName, * -ErrorAction SilentlyContinue `
        | Sort-Object -Property Name, PSComputername, * -ErrorAction SilentlyContinue `
        | Out-GridView -Title 'Select Network Connections To Kill' -PassThru -OutVariable NetworkConnectionsToKill
    }
    elseif ($CollectNewNetworkConnections) {
        Generate-ComputerList

        if ($script:ComputerList.count -eq 0){
            [System.Windows.MessageBox]::Show('Ensure you checkbox one or more endpoints to collect network connections from. Alternatively, you can select a CSV file from a previous network connection collection.','Error: No Endpoints Selected')
        }
        else {
            if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { Create-NewCredentials }
                $GetNetworkConnectionsTCPEnriched = {
                    if ([bool]((Get-Command Get-NetTCPConnection).ParameterSets | Select-Object -ExpandProperty Parameters | Where-Object Name -match OwningProcess)) {
                        $Processes           = Get-WmiObject -Class Win32_Process
                        $Connections         = Get-NetTCPConnection

                        foreach ($Conn in $Connections) {
                            foreach ($Proc in $Processes) {
                                if ($Conn.OwningProcess -eq $Proc.ProcessId) {
                                    $Conn | Add-Member -MemberType NoteProperty 'PSComputerName'  $env:COMPUTERNAME -Force
                                    $Conn | Add-Member -MemberType NoteProperty 'Protocol'        'TCP'
                                    $Conn | Add-Member -MemberType NoteProperty 'Duration'        ((New-TimeSpan -Start ($Conn.CreationTime)).ToString())
                                    $Conn | Add-Member -MemberType NoteProperty 'ProcessId'       $Proc.ProcessId
                                    $Conn | Add-Member -MemberType NoteProperty 'ParentProcessId' $Proc.ParentProcessId
                                    $Conn | Add-Member -MemberType NoteProperty 'ProcessName'     $Proc.Name
                                    $Conn | Add-Member -MemberType NoteProperty 'CommandLine'     $Proc.CommandLine
                                    $Conn | Add-Member -MemberType NoteProperty 'ExecutablePath'  $proc.ExecutablePath
                                    $Conn | Add-Member -MemberType NoteProperty 'ScriptNote'       'Get-NetTCPConnection Enhanced'

                                    if ($Conn.ExecutablePath -ne $null -AND -NOT $NoHash) {
                                        $MD5Hash = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
                                        $Hash    = [System.BitConverter]::ToString($MD5Hash.ComputeHash([System.IO.File]::ReadAllBytes($proc.ExecutablePath)))
                                        $Conn | Add-Member -MemberType NoteProperty MD5Hash $($Hash -replace "-","")
                                    }
                                    else {
                                        $Conn | Add-Member -MemberType NoteProperty MD5Hash $null
                                    }
                                }
                            }
                        }
                    }
                    else {
                        function Get-Netstat {
                            $NetworkConnections = netstat -nao -p TCP
                            $NetStat = Foreach ($line in $NetworkConnections[4..$NetworkConnections.count]) {
                                $line = $line -replace '^\s+',''
                                $line = $line -split '\s+'
                                $Properties = @{
                                    Protocol      = $line[0]
                                    LocalAddress  = ($line[1] -split ":")[0]
                                    LocalPort     = ($line[1] -split ":")[1]
                                    RemoteAddress = ($line[2] -split ":")[0]
                                    RemotePort    = ($line[2] -split ":")[1]
                                    State         = $line[3]
                                    ProcessId     = $line[4]
                                    OwningProcess = $line[4]
                                }
                                $Connection = New-Object -TypeName PSObject -Property $Properties
                                $proc       = Get-WmiObject -query ('select * from win32_process where ProcessId="{0}"' -f $line[4])
                                $Connection | Add-Member -MemberType NoteProperty 'PSComputerName'  $env:COMPUTERNAME -Force
                                $Connection | Add-Member -MemberType NoteProperty 'ParentProcessId' $proc.ParentProcessId
                                $Connection | Add-Member -MemberType NoteProperty 'ProcessName'     $proc.Caption
                                $Connection | Add-Member -MemberType NoteProperty 'ExecutablePath'  $proc.ExecutablePath
                                $Connection | Add-Member -MemberType NoteProperty 'CommandLine'     $proc.CommandLine
                                $Connection | Add-Member -MemberType NoteProperty 'CreationTime'    ([WMI] '').ConvertToDateTime($proc.CreationDate)
                                $Connection | Add-Member -MemberType NoteProperty 'Duration'        ((New-TimeSpan -Start ([WMI] '').ConvertToDateTime($proc.CreationDate)).ToString())
                                $Connection | Add-Member -MemberType NoteProperty 'ScriptNote'      'NetStat.exe Enhanced'

                                if ($Connection.ExecutablePath -ne $null -AND -NOT $NoHash) {
                                    $MD5Hash = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
                                    $Hash    = [System.BitConverter]::ToString($MD5Hash.ComputeHash([System.IO.File]::ReadAllBytes($proc.ExecutablePath)))
                                    $Connection | Add-Member -MemberType NoteProperty MD5Hash $($Hash -replace "-","")
                                }
                                else {
                                    $Connection | Add-Member -MemberType NoteProperty MD5Hash $null
                                }
                                $Connection
                            }
                            $NetStat
                        }
                        $Connections = Get-Netstat
                    }
                    $Connections | Select-Object -Property PSComputerName, Protocol,LocalAddress,LocalPort,RemoteAddress,RemotePort,State,ProcessName,ProcessId,ParentProcessId,CreationTime,Duration,CommandLine,ExecutablePath,MD5Hash,OwningProcess,ScriptNote -ErrorAction SilentlyContinue
                }
                if (!$script:Credential) { Create-NewCredentials }

                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message 'Invoke-Command -ScriptBlock $GetNetworkConnectionsTCPEnriched -ComputerName $script:ComputerList -Credential $script:Credential'
                $ResultsListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  Obtaining Network Connections (TCP) with Enriched Data from $($script:ComputerList.count) Endpoints")

                Invoke-Command -ScriptBlock $GetNetworkConnectionsTCPEnriched -ComputerName $script:ComputerList -Credential $script:Credential `
                | Select-Object -Property PSComputerName, * -ExcludeProperty RunspaceID -ErrorAction SilentlyContinue `
                | Out-GridView -Title 'Select Network Connections To Kill' -PassThru -OutVariable NetworkConnectionsToKill
            }
            else {
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message 'Invoke-Command -ScriptBlock $GetNetworkConnectionsTCPEnriched -ComputerName $script:ComputerList'
                $ResultsListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  Obtaining Network Connections (TCP) with Enriched Data from $($script:ComputerList.count) Endpoints")

                Invoke-Command -ScriptBlock $GetNetworkConnectionsTCPEnriched -ComputerName $script:ComputerList `
                | Select-Object -Property PSComputerName, * -ExcludeProperty RunspaceID -ErrorAction SilentlyContinue `
                | Out-GridView -Title 'Select Network Connections To Kill' -PassThru -OutVariable NetworkConnectionsToKill
            }
        }
    }

    $NetworkConnectionsToKill = $NetworkConnectionsToKill | Sort-Object -Property PSComputerName
    $Computers = $NetworkConnectionsToKill | Select-Object -ExpandProperty PSComputerName -Unique | Sort-Object

    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Multi-Endpoint Network Connection Killer")

    foreach ($Computer in $Computers) {
        $Session = $null

        try {
            if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { Create-NewCredentials }
                $Session = New-PSSession -ComputerName $Computer -Credential $script:Credential

                $StatusListBox.Items.Clear()
                $StatusListBox.Items.Add("PSSession Ended With $Computer")
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "New-PSSession -ComputerName $Computer -Credential $script:Credential"
            }
            else {
                $Session = New-PSSession -ComputerName $Computer

                $StatusListBox.Items.Clear()
                $StatusListBox.Items.Add("PSSession Ended With $Computer")
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "New-PSSession -ComputerName $Computer"
            }
        }
        catch {
            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("Unable to Connect:  $Computer")
            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Unable to Connect:  $Computer"
        }
        if ($Session) {
            $ResultsListBox.Items.Insert(1,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  Killing Connections on: $Computer")
            foreach ($Connection in $NetworkConnectionsToKill){
                if ($Connection.PSComputerName -eq $Computer){
                    $LocalIP       = $Connection.LocalAddress
                    $LocalPort     = $Connection.LocalPort
                    $RemoteIP      = $Connection.RemoteAddress
                    $RemotePort    = $Connection.RemotePort
                    $ProcessName   = $Connection.ProcessName
                    $ProcessID     = $Connection.ProcessID

                    Invoke-Command -ScriptBlock {
                        param($ProcessID)
                        Stop-Process -Id $ProcessID -Force
                    } -ArgumentList $ProcessID -Session $Session

                    $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  - [Process]$ProcessName  $($LocalIP):$($LocalPort) <-> $($RemoteIP):$($RemotePort)")
                    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { param($ProcessID) Stop-Process -Id $ProcessID -Force } -ArgumentList $ProcessID -Session $Session"
                }
            }
            Remove-PSSession -Session $Session
            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("PSSession Ended With $Computer")
            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Remove-PSSession -Session $Session"
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU/qT/pCat2KRM8A64zPSTz9xx
# lFegggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUEBztWi2hO/14LYeS+Jp1VDhEeyMwDQYJKoZI
# hvcNAQEBBQAEggEAax4Qy2PEs0qMs2OWMdoJbNbeZPgV8UW/1AMIHL4p79aUjQFs
# cTtWWMBjZjSwzqcXg1/2i9RIXHFNF2L+iZb7r0+euoMteq7gOhlRqyXir/SWCx4P
# Qcz7EE7EmeGM1KUP31cieasmKREfCgHRQvWTOI/58ZU6GF8z46ciIUlVYW6vtcfw
# C0R3jJp7QhxRMoHuLQo17dO6s/gVEuGUB8FXUmVsY4k9HdshjRna0cveLtsUh0+8
# gaBHnlxgde56ODZDjlABG6D+qLe+FpvrxLXJdpr1FLfen84lIPGsTdD21ke9p//P
# PYB00RUyUVYsn273EsjGQA4jBtFXEXr1GxKc6Q==
# SIG # End signature block
