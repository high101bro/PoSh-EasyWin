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
# vpmgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUlFK5CsFQAEnzzKOTgj9gL4PzWIUwDQYJKoZI
# hvcNAQEBBQAEggEAQYHZjIO5hRZACt8H8IlFIhST+VvuugN5rNfe1ZdsGvC1d187
# ggDxo8WstF5iP1JFn5eHPM7hVy/vJ6PxjwlB9plkH0pB7pFDjKLqt4r8t3v3E62t
# wCM5CF5iF2mO6nOO5XAatpZB7VaGQmdXWGEgkVNMEcoEv02yoJ2NcVPaQBQOoEBH
# yGZKoqtzXg3tHYNU3Z0mi1pU9pMuSWWx7N01Yl5eAaWe9+UkERqPtSETD1oPxPd6
# 9wEpbGotBVq5LWQqSc2eEl+6aAXJgmHixIJiwBRN7f5XDj/8k1+EpNGpb12Da8rM
# /mmCHE5Ik6WjdvhImsmX3EoHjsWkb/oINOpFng==
# SIG # End signature block
