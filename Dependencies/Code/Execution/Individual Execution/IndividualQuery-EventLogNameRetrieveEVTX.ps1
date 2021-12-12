# Query-EventLog -CollectionName $Query.Name -Filter $Query.Filter
$ExecutionStartTime = Get-Date

$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Executing: Event Log Name .evtx Retrieval")

$script:ProgressBarEndpointsProgressBar.Value = 0

$EventLogNameEVTXMaximumCollectionTextBoxText = $script:EventLogNameEVTXMaximumCollectionTextBox.Text
$EventLogNameEVTXLogNameSelectionComboBoxSelectedItem = $EventLogNameEVTXLogNameSelectionComboBox.SelectedItem
$EventLogNameEVTXStartTimePickerChecked = $script:EventLogNameEVTXStartTimePicker.Checked
$EventLogNameEVTXStopTimePickerChecked = $script:EventLogNameEVTXStopTimePicker.Checked
$EventLogNameEVTXStartTimePickerValue = $script:EventLogNameEVTXStartTimePicker.Value
$EventLogNameEVTXStopTimePickerValue = $script:EventLogNameEVTXStopTimePicker.Value
$EventLogNameEVTXEventIDsManualEntryTextboxFilter = $script:EventLogNameEVTXEventIDsManualEntryTextbox.Text
$EndpointSavePath = "C:\windows\temp\$($EventLogNameEVTXLogNameSelectionComboBoxSelectedItem.replace('/','-')).evtx"

if ($EventLogNameEVTXWinRMRadioButton.Checked) {
    $CollectionName = "$($EventLogNameEVTXLogNameSelectionComboBoxSelectedItem -replace '/','-')"
}


foreach ($TargetComputer in $script:ComputerList) {
    Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $($script:CollectionSavedDirectoryTextBox.Text) `
                            -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                            -TargetComputer $TargetComputer
    Create-LogEntry -TargetComputer $TargetComputer  -LogFile $LogFile -Message $CollectionName

    $LocalSavePath = "$($script:CollectionSavedDirectoryTextBox.Text)\$CollectionName\$TargetComputer - $CollectionName.evtx"

    Start-Job -Name "PoSh-EasyWin: $CollectionName -- $TargetComputer $DateTime" -ScriptBlock {
        param(
            $ComputerListProvideCredentialsCheckBoxChecked,
            $script:Credential,
            $TargetComputer,
            $EventLogNameEVTXMaximumCollectionTextBoxText,
            $EventLogNameEVTXLogNameSelectionComboBoxSelectedItem,
            $EventLogNameEVTXStartTimePickerChecked,
            $EventLogNameEVTXStopTimePickerChecked,
            $EventLogNameEVTXStartTimePickerValue,
            $EventLogNameEVTXStopTimePickerValue,
            $EventLogNameEVTXEventIDsManualEntryTextboxFilter,
            $EndpointSavePath,
            $LocalSavePath
        )


        if ($ComputerListProvideCredentialsCheckBoxChecked) {
            if (!$script:Credential) { $script:Credential = Get-Credential }
            $Session = New-PSSession -ComputerName $TargetComputer -Credential $script:Credential
        }
        else {
            $Session = New-PSSession -ComputerName $TargetComputer
        }

        #$EventLog = wevtutil enum-logs | Out-GridView -Title "Event Logs" -OutputMode 'Single'
        $EventLog = $EventLogNameEVTXLogNameSelectionComboBoxSelectedItem

        #$DateTimeStart = (get-date).AddDays(-30).ToString('yyyy-MM-ddThh:mm:ss')
        $DateTimeStart = $EventLogNameEVTXStartTimePickerValue.ToString('yyyy-MM-ddThh:mm:ss')

        #$DateTimeStop = (get-date).ToString('yyyy-MM-ddThh:mm:ss')
        $DateTimeStop = $EventLogNameEVTXStopTimePickerValue.ToString('yyyy-MM-ddThh:mm:ss')

        $IdFilterList = $EventLogNameEVTXEventIDsManualEntryTextboxFilter.split("`r`n") | Where-Object {$_ -ne '' -and $_ -ne $null}

        $OverWrite = $true

        #wevtutil export-log $EventLog $EndpointSavePath /q:"* [System [(EventID=1014) or (EventID=7040) ] [TimeCreated [@SystemTime >= '$DateTimeStart' and @SystemTime < '$DateTimeStop'] ] ]” /ow:$OverWrite

        $EventLogQueryCommand = @"
wevtutil export-log '$EventLog' '$EndpointSavePath' /q:"* 
"@
         $EventLogQueryCommand += '[System '

        # Note: Not implemented yet
        #$EventLogNameEVTXMaximumCollectionTextBoxText
        
        if ($IdFilterList.count -gt 0) {

            $EventLogQueryCommand += '[ '
            if ($IdFilterList.count -eq 1) {
                $EventLogQueryCommand += "(EventID=$($IdFilterList))"
            }
            elseif ($IdFilterList.count -gt 1) {
                $FirstID = $true
                foreach ($Id in $IdFilterList) {
                    if ($FirstID) {
                        $EventLogQueryCommand += "(EventID=$($Id))"
                        $FirstID = $false
                    }
                    else {
                        $EventLogQueryCommand += " or (EventID=$($Id))"
                    }
                }
            }
            $EventLogQueryCommand += ' ]'
        }

#         if ( $EventLogNameEVTXStartTimePickerChecked -and $EventLogNameEVTXStopTimePickerChecked ) {
#             $EventLogQueryCommand += @'
# [TimeCreated [@SystemTime >= '$DateTimeStart' and @SystemTime < '$DateTimeStop'] ] 
# '@
#         }

         $EventLogQueryCommand += ']'

        $EventLogQueryCommand += '" '

        $EventLogQueryCommand += @"
/ow:$OverWrite
"@

        $InvokeCommandSplat = @{
            ScriptBlock = {
                param($EventLogQueryCommand)
                Invoke-Expression $EventLogQueryCommand
            }
            argumentlist = @($EventLogQueryCommand,$null)
            Session      = $Session
        }
        Invoke-Command @InvokeCommandSplat


        Copy-Item -Path $EndpointSavePath -Destination $LocalSavePath -FromSession $Session -Force

        
        $InvokeCommandSplat = @{
            ScriptBlock = {
                param($EndpointSavePath)
                Remove-Item -Path $EndpointSavePath -Force
            }
            argumentlist = @($EndpointSavePath,$null)
            Session      = $Session
        }
        Invoke-Command @InvokeCommandSplat


        $Session | Remove-PSSession

    } -ArgumentList @(
        $script:ComputerListProvideCredentialsCheckBox.checked,
        $script:Credential,
        $TargetComputer,
        $EventLogNameEVTXMaximumCollectionTextBoxText,
        $EventLogNameEVTXLogNameSelectionComboBoxSelectedItem,
        $EventLogNameEVTXStartTimePickerChecked,
        $EventLogNameEVTXStopTimePickerChecked,
        $EventLogNameEVTXStartTimePickerValue,
        $EventLogNameEVTXStopTimePickerValue,
        $EventLogNameEVTXEventIDsManualEntryTextboxFilter,
        $EndpointSavePath,
        $LocalSavePath
    )

    
    
    $InputValues = @"
===========================================================================
Collection Name:
===========================================================================
Event Log Retrieval

===========================================================================
Execution Time:
===========================================================================
$ExecutionStartTime

===========================================================================
Credentials:
===========================================================================
$($script:Credential.UserName)

===========================================================================
Endpoint:
===========================================================================
$TargetComputer

===========================================================================
Start Time:  [$EventLogNameEVTXStartTimePickerChecked]
===========================================================================
$EventLogNameEVTXStartTimePickerValue

===========================================================================
End Time:  [$EventLogNameEVTXStopTimePickerChecked]
===========================================================================
$EventLogNameEVTXStopTimePickerValue

===========================================================================
Event Log Name:
===========================================================================
$EventLogNameEVTXLogNameSelectionComboBoxSelectedItem

===========================================================================
Filters:
===========================================================================
$($script:EventLogNameEVTXEventIDsManualEntryTextbox.Text)

"@


    if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
        Monitor-Jobs -CollectionName $CollectionName -MonitorMode -EVTXSwitch -EVTXLocalSavePath $LocalSavePath -InputValues $InputValues -NotExportFiles -DisableReRun
    }
    elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Individual Execution') {
        Monitor-Jobs -CollectionName $CollectionName -NotExportFiles
        Post-MonitorJobs -CollectionName $CollectionName -CollectionCommandStartTime $ExecutionStartTime
    }
}

Update-EndpointNotes

# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUWaWS7aLOjV0P2VafLRGENjQb
# t/GgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU8AjDVataeh4t7TiEPg6axbpnQ5EwDQYJKoZI
# hvcNAQEBBQAEggEAKcvlF/DGmz9KWUDE6qJaDmXSy+QI0ZtdTqumV3xxJ00cKjBv
# 59ijwW84t+zGRy0jJU0QN0XlkGeQ6wnxrgNQGGToblu9IYwEjDxKsbYeWE2hz1Jk
# Pt4HCy4RaUK/w+SsbQ9HzyohkyoFhv9f6XKRkGMG/VXzTurF+oIYLwgk9oDNyZxn
# z7JygO9WIVWjdlIyvAAPzw7m3zUeA3OwjCdst5NgiL7ojdY3RT/F5PnRi+S7F7fR
# I77G967/Z51PW0MT17LDCcyO9mOCsybhrzNsU1ee4h567GaPERVkUa2zIRG5JsZY
# 6xsSk1J3n+vSzKa2l3loJAbUOzFVYDR+QtQsLw==
# SIG # End signature block
