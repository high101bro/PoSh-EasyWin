$ComputerListPSSessionPivotButtonAdd_Click = {

    $InformationTabControl.SelectedTab = $Section3ResultsTab
    Create-TreeViewCheckBoxArray -Endpoint
    Generate-ComputerList
    
    if ($script:ComputerListProvideCredentialsCheckBox.Checked) { $Username = $script:Credential.UserName}
    else {$Username = $PoShEasyWinAccountLaunch }

    if ($script:ComputerListEndpointNameToolStripLabel.text) {
        $VerifyAction = Verify-Action -Title "Verification: PowerShell Session" -Question "Connecting Account:  $Username`n`nEnter a PowerShell BROKEN Session to the following?" -Computer $($script:ComputerListEndpointNameToolStripLabel.text)
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
        [System.Windows.Forms.Messagebox]::Show('Left click an endpoint node to select it, then right click to access the context menu and select PSSession.','PowerShell Session')
    }

    if ($VerifyAction) {
        # This brings specific tabs to the forefront/front view
        $InformationTabControl.SelectedTab = $Section3ResultsTab

        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Pivot-PSSession:  $($script:ComputerTreeViewSelected)")
        #Removed For Testing#$ResultsListBox.Items.Clear()
        if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
            if (-not $script:Credential) { Create-NewCredentials }
            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Credentials Used: $($script:Credential.UserName)"
            #$Username = $script:Credential.UserName
            #$Password = $script:Credential.GetNetworkCredential().Password
            #$password = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Password))

            $ResultsListBox.Items.Add("Pivot-PSSession -PivotHost $($script:ComputerListPivotExecutionTextBox.text) -TargetComputer $($script:ComputerTreeViewSelected) -Credential $script:Credential")
            #start-process -FilePath 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -ArgumentList "-noexit -Command Enter-PSSession -ComputerName $($script:ComputerListPivotExecutionTextBox.text) -Credential `$(New-Object PSCredential('$Username'`,`$([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('$Password')) | ConvertTo-SecureString -AsPlainText -Force))); function Pivot-PSSession(`$Id) { while ( `$Command -ne 'Exit' ) {`$Session = Get-PSSession -Id `$id; `$ComputerName = `$Session.ComputerName; Write-Host -NoNewline `"[$($script:ComputerListPivotExecutionTextBox.text) --> `$ComputerName]: Pivot> `"; `$Command = Read-Host; Invoke-Command -Session `$Session -ScriptBlock {param(`$Command) invoke-command {iex `$Command}} -ArgumentList `$Command; }; ; }; Pivot-PSSession -Id (New-PSSession -ComputerName $script:ComputerTreeViewSelected -Credential `$(New-Object PSCredential('$Username'`,`$([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('$Password')) | ConvertTo-SecureString -AsPlainText -Force)))).Id"

            start-process -FilePath 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -ArgumentList "-NoExit -NoProfile -Command & '$Dependencies\Code\Main Body\Pivot-PSSession.ps1' -PivotHost '$($script:ComputerListPivotExecutionTextBox.text)' -TargetComputer '$($script:ComputerTreeViewSelected)' -CredentialXML '$script:SelectedCredentialPath'"

            Start-Sleep -Seconds 3
        }
        else {
            $ResultsListBox.Items.Add("Pivot-PSSession -PivotHost $($script:ComputerListPivotExecutionTextBox.text) -TargetComputer $($script:ComputerTreeViewSelected)")
            start-process -FilePath 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -ArgumentList "-NoExit -NoProfile -Command & '$Dependencies\Code\Main Body\Pivot-PSSession.ps1' -PivotHost '$($script:ComputerListPivotExecutionTextBox.text)' -TargetComputer '$($script:ComputerTreeViewSelected)'"
            Start-Sleep -Seconds 3
        }
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Pivot-PSSession -ComputerName $($script:ComputerTreeViewSelected)"

        if ($script:RollCredentialsState -and $script:ComputerListProvideCredentialsCheckBox.checked) {
            Start-Sleep -Seconds 3
            Generate-NewRollingPassword
        }
    }
    else {
        [system.media.systemsounds]::Exclamation.play()
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Pivot-PSSession:  Cancelled")
    }
}

$ComputerListPSSessionPivotButtonAdd_MouseHover = {
    Show-ToolTip -Title "Pivot-PSSession" -Icon "Info" -Message @"
+  Starts an interactive session with the specified pivot endpoint.
+  Uses Invoke-Command to route commands to the target endpoint thru the pivot endpoint.
+  Requires the WinRM service.
"@
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU2dlv7tLIAPZTObinlwzESU+p
# vpmgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUlFK5CsFQAEnzzKOTgj9gL4PzWIUwDQYJKoZI
# hvcNAQEBBQAEggEAZDjlrAOS338c8q+p92fJr+3GVfOQZpgj5o1M4Wjd2A25QAr4
# JvnlJH1JwsmtFVaWxZ4iziDDjplB5kNwS5yoy4u3svqj+sJF7txQeedvTjXnIKFB
# VQpxIiCio/YEWVnk8CI2xLVxuGlzbWxSWfK2DVdVLCIHaI676JqX6CRAEG92rCM2
# jJeQpYJOCvOuw7khpHZpzIYDvdmpNci4V/e+oV+shLkPdPMj6hvHzRLH539BxOIA
# 371DcE62ofZ4xRwtanRQkdTzHRqIs3j51NqJm4OhaGm/v68skoorEq6RuJja+vxe
# S/S+KjkG7sEjeMyiK8Jj9i/l8tIHDdcc4bfm6A==
# SIG # End signature block
