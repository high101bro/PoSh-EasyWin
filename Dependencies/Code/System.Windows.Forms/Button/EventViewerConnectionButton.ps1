$EventViewerConnectionButtonAdd_Click = {
    $InformationTabControl.SelectedTab = $Section3ResultsTab
    #Create-TreeViewCheckBoxArray -Endpoint
    Generate-ComputerList

    if ($script:ComputerListProvideCredentialsCheckBox.Checked) { $Username = $script:Credential.UserName}
    else {$Username = $PoShEasyWinAccountLaunch }

    if ($script:ComputerListEndpointNameToolStripLabel.text) {
        $VerifyAction = Verify-Action -Title "Verification: Event Viewer" -Question "Connecting Account:  $Username`n`nAttempt to launch the Event Viewer on the following?" -Computer $($script:ComputerListEndpointNameToolStripLabel.text)
        if ($script:ComputerListUseDNSCheckbox.checked) { 
            $script:ComputerTreeViewSelected = $script:ComputerListEndpointNameToolStripLabel.text 
        }
        else {
            [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
            foreach ($root in $AllTreeViewNodes) {
                foreach ($Category in $root.Nodes) {
                    foreach ($Entry in $Category.nodes) {
                        if ($Entry.Text -eq $script:ComputerListEndpointNameToolStripLabel.text) {
                            foreach ($Metadata in $Entry.nodes) {
                                if ($Metadata.Name -eq 'IPv4Address') {
                                    $script:ComputerTreeViewSelected = $Metadata.text
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    elseif (-not $script:ComputerListEndpointNameToolStripLabel.text) {
        [System.Windows.Forms.Messagebox]::Show('Left click an endpoint node to select it, then right click to access the context menu and select Event Viewer.','Event Viewer')
    }

    if ($VerifyAction) {
        $InformationTabControl.SelectedTab = $Section3ResultsTab

        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Event Viewer:  $($script:ComputerTreeViewSelected)")

        if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
            if (!$script:Credential) { Create-NewCredentials }

            $ResultsListBox.Items.Add("start-process powershell.exe -ArgumentList '-WindowStyle Hidden -Command Show-EventLog -ComputerName $script:ComputerTreeViewSelected' -Credential <Credential> -WindowStyle Hidden")
            #start-process -FilePath 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -ArgumentList "-WindowStyle Hidden -Command Show-eventLog -ComputerName $script:ComputerTreeViewSelected" -Credential $script:Credential -WindowStyle Hidden
            [System.Windows.Forms.MessageBox]::Show("If the Event Viewer doesn't display, try re-launching PoSh-EasyWin itself with domain credentials and wihtout checking 'Specify Credentials'. This method would require the localhost to be on the domain.",'Show-EventLog')
            start-process powershell.exe -ArgumentList "-WindowStyle Hidden -Command Show-EventLog -ComputerName $script:ComputerTreeViewSelected" -Credential $script:Credential -WindowStyle Hidden
        }
        else {
            $ResultsListBox.Items.Add("start-process powershell.exe -ArgumentList '-WindowStyle Hidden -Command Show-EventLog -ComputerName $script:ComputerTreeViewSelected' -WindowStyle Hidden")
            [System.Windows.Forms.MessageBox]::Show("If the Event Viewer doesn't display, try re-launching PoSh-EasyWin itself with domain credentials and wihtout checking 'Specify Credentials'. This method would require the localhost to be on the domain.",'Show-EventLog')
            start-process powershell.exe -ArgumentList "-WindowStyle Hidden -Command Show-EventLog -ComputerName $script:ComputerTreeViewSelected" -WindowStyle Hidden
        }
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "start-process powershell.exe -ArgumentList '-WindowStyle Hidden -Command Show-EventLog -ComputerName $script:ComputerTreeViewSelected' -WindowStyle Hidden"

        if ($script:RollCredentialsState -and $script:ComputerListProvideCredentialsCheckBox.checked) {
            Start-Sleep -Seconds 3
            Generate-NewRollingPassword
        }
    }
    else {
        [system.media.systemsounds]::Exclamation.play()
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Event Viewer:  Cancelled")
    }
}


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU7l4LLzuOSWLXPg43oAO8yU7W
# wUCgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQURxAo07cM+/gC1YGwi5EYEWIPmBQwDQYJKoZI
# hvcNAQEBBQAEggEAfnWEFTBBQWrJ94C08x671GBJmZIMuB/j2a0vAmwqTnU9SQ36
# GNjUrPwIkWF7AdUCn6/hDAe0J400N9nhZK/Zm2rYS9FeN0KvVXLQkotMlqA4m+kX
# pFvanpUCXv+SABF2Dwa23ASYjDRTDTWfHL+RGbWxWi/qgaRKlYGn8s91A0DD+ePg
# eldtNEOY46Pkcl2ckLVewGWVTNR/khKS5QYdzQ0txuhDnjI/1YJ74V5z61h2EWXj
# 3B6YpQRFeSflIvBtEHov/m3k97xsWeQayG/5air/0YzzI3Utxn0TsfiBVX5yUmvd
# MfcIrK94a6Hh2YY7Z0g72ttu+dvJtMW4ZwB8Yg==
# SIG # End signature block
