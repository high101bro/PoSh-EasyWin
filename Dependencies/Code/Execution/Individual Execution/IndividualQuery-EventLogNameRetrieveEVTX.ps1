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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU+G5JP47fwe7RhGkU5+exS4KD
# Y0KgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUZt6mC3/FelG+D9AG/mV6pnOcosAwDQYJKoZI
# hvcNAQEBBQAEggEAhsUvOdA7LJpaqGjvVW9vsbr3qCEACA1hzv8w4ZXAOEpYgTA6
# L9TtMWKTkA3SVu/jFwi6KUxxkG4c5n/N/QEbaDIinTqoCLZpcMYQKeauADB65GgB
# 64SqgGly20GTRLqJUPKI9+cMemPzIXEtdkbPzCjnKbLS3SvojOmcEx2cJPksh1Xt
# 57AlMvnDbaTEBFZATQQX7qQaOLqTDGuujNPqFzK/Dxfcto4f+ckdoh3k8xBRxjYV
# XaaOquWKY9R6bFp1loSXO3iZdYnEPWv+f1KgTyrW228ZATkefwDS+ycn9B80BFtY
# a2gnsEP3s6RvsBmG+2mohHSyPsaTUstCcKx8EQ==
# SIG # End signature block
