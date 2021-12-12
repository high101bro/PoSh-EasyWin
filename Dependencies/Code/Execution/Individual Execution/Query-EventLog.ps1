function Query-EventLog {
    param(
        $CollectionName,
        $Filter
    )
    $ExecutionStartTime = Get-Date
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Query: $CollectionName")
    $ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")


    function Compiled-EventLogCommand {
        param($script:EventLogsMaximumCollectionTextBox,$script:EventLogsStartTimePicker,$script:EventLogsStopTimePicker,$Filter)

        # Builds the Event Log Query Command
        $EventLogQueryCommand  = "Get-WmiObject -Class Win32_NTLogEvent"
        ###$EventLogQueryComputer = "-ComputerName $TargetComputer"


        # Code to set the amount of data to return
        if ($script:EventLogsMaximumCollectionTextBox.Text -eq $null -or $script:EventLogsMaximumCollectionTextBox.Text -eq '' -or $script:EventLogsMaximumCollectionTextBox.Text -eq 0) {
            $EventLogQueryMax = $null
        }
        else { $EventLogQueryMax = "-First $($script:EventLogsMaximumCollectionTextBox.Text)" }


        # Code to include calendar start/end datetimes if checked
        if ( $script:EventLogsStartTimePicker.Checked -and $script:EventLogsStopTimePicker.Checked ) {
            $EventLogQueryFilter = @"
-Filter "($Filter and (TimeGenerated>='$([System.Management.ManagementDateTimeConverter]::ToDmtfDateTime(($script:EventLogsStartTimePicker.Value)))') and (TimeGenerated<='$([System.Management.ManagementDateTimeConverter]::ToDmtfDateTime(($script:EventLogsStopTimePicker.Value)))'))"
"@
        }
        else { $EventLogQueryFilter = "-Filter `"$Filter`""}


        # Code to select and format properties
        $EventLogQueryPipe = @"
| Select-Object PSComputerName, LogFile, EventIdentifier, CategoryString, @{Name='TimeGenerated';Expression={[Management.ManagementDateTimeConverter]::ToDateTime(`$_.TimeGenerated)}}, Message, Type $EventLogQueryMax
"@

        # TODO Batman... look into why Get-AccountLogonActivity is here... 
        Invoke-Expression -Command "Invoke-Command -ScriptBlock `${function:Get-AccountLogonActivity} -ArgumentList @(`$AccountsStartTimePickerValue,`$AccountsStopTimePickerValue) -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)' -Credential `$script:Credential"
    }



    foreach ($TargetComputer in $script:ComputerList) {
        Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $script:CollectedDataTimeStampDirectory `
                                -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                                -TargetComputer $TargetComputer
        Create-LogEntry -TargetComputer $TargetComputer  -LogFile $LogFile -Message $CollectionName


        if ($EventLogWinRMRadioButton.Checked) {
            $InvokeCommandSplat = @{
                ScriptBlock  = ${function:Compiled-EventLogCommand}
                ArgumentList = @($script:EventLogsMaximumCollectionTextBox,$script:EventLogsStartTimePicker,$script:EventLogsStopTimePicker,$Filter)
                ComputerName = $TargetComputer
                AsJob        = $true
                JobName      = "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"
            }

            if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { Create-NewCredentials }
                $InvokeCommandSplat += @{ 
                    Credential = $script:Credential
                }
            }
            
            Invoke-Command @InvokeCommandSplat | Select-Object PSComputerName, *
        }
        elseif ($EventLogRPCRadioButton.Checked) {
            #batman
            if ( $script:ComputerListProvideCredentialsCheckBox.Checked ) {
                #$EventLogQueryBuild = "$EventLogQueryCommand $EventLogQueryComputer $EventLogQueryFilter -Credential $script:Credential $EventLogQueryPipe"
                #Start-Job -Name "PoSh-EasyWin: $CollectionName -- $TargetComputer" -ScriptBlock {
                #    param(
                #        $EventLogQueryBuild
                #    )
                #    Invoke-Expression -Command "$EventLogQueryBuild"
                #} -ArgumentList @($EventLogQueryBuild,$null)
            }
            else {
                #$EventLogQueryBuild = "$EventLogQueryCommand $EventLogQueryComputer $EventLogQueryFilter $EventLogQueryPipe"
                #Start-Job -Name "PoSh-EasyWin: $CollectionName -- $TargetComputer" -ScriptBlock {
                #    param(
                #        $EventLogQueryBuild
                #    )
                #    Invoke-Expression -Command "$EventLogQueryBuild"
                #} -ArgumentList @($EventLogQueryBuild,$null)
            }
            #Create-LogEntry -LogFile $LogFile -TargetComputer $TargetComputer -Message "$EventLogQueryBuild"
        }
    }



    if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
        Monitor-Jobs -CollectionName $CollectionName -MonitorMode
    }
    elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Individual Execution') {
        Monitor-Jobs -CollectionName $CollectionName
        Post-MonitorJobs -CollectionName $CollectionName -CollectionCommandStartTime $ExecutionStartTime
    }

    
    $CollectionCommandEndTime  = Get-Date
    $CollectionCommandDiffTime = New-TimeSpan -Start $ExecutionStartTime -End $CollectionCommandEndTime


    $ResultsListBox.Items.RemoveAt(0)
    $ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $CollectionName")
}

Update-EndpointNotes

# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUsgA3z1g7elRY/Z+ATiGRG+MN
# A/ugggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUUVw3CYAtKqB4fBAQRK2gfGKj3PgwDQYJKoZI
# hvcNAQEBBQAEggEAsuqgC2iNnvD5ksR25jxT8M745fFmteiRJ5GmbVrxX5NESGRi
# jhWzJ7xl2JWoWHe1XHxVdT1wetaUJ/RIwXxpxNXCuRmgobTp67VClpOJpXc6ER3G
# lDx2SWdKoDq3VcsJhE/A9gmrFiZV7bJltQkECemBJVx0fWricVEQVNkJdPgSBndt
# hVpqkT05g0JS6dXNt7tyCVTI62ji4JGDeVJkLMxnGl4nuBxb3Boq5BXxSI538yoP
# T41Mqx/7XVEOdGX0w8sJ1C44WNSwcLu6PQnG/+WVgBzbvQjeAz2DZNEhnpgujZa6
# LYPR66Qjw6wt7P+4kUWigszuPyz0QEHC23KX+g==
# SIG # End signature block
