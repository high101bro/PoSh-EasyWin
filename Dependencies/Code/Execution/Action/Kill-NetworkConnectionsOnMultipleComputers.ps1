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
# lFegggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUEBztWi2hO/14LYeS+Jp1VDhEeyMwDQYJKoZI
# hvcNAQEBBQAEggEAgLyrG7LZ51Z8nJCE91Pn0D8N8iZhNaDFars5U10Npt2xNYkI
# NUydg9vWqPIdJdJd173b6qwGgu9o/GUrjlH/bI6Pe4+OlLs/ErNij8grp4UzIdno
# IQmFA3XEeQehUISZ9lRpSzkYtbqUetn0SVZdXHRT4JDYupOR/wrBWSofLVjIWQGO
# aNPk9JwFLmeYHxq6aeFmbtusYo9QS+5E0fzk2Qdlo3PckKQFyoepmxkMEaz2VMl/
# 9xKxrOY9bFBWFQATyzl0h0WkLKjqNXus3eQt/fKcShFdliCKjRuouIlRCaDeWvxd
# 4MVd8sScY+G7ikyaH7ic2jOk8WTljV72gawNmg==
# SIG # End signature block
