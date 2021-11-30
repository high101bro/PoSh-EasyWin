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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUuBsmMiomvvxLMqPz6qio+CdR
# z96gggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU07IrI7mXpbcyhvO7tlqSrRIlHycwDQYJKoZI
# hvcNAQEBBQAEggEAntx3Dig/JnGilHa26OVKAL/CULp5pQzigzj9qr5XULRMzbeh
# r1GKRGlYDfzlTAqjTvWzrBgVpQpM67Tw8zOLBvGSA7mLisyVclhSmArNBN+2h1pW
# 5x1+zAVr17BjhG27ZxBF15/noJRKIOQWj+UTdbl4ix1TiydevS61bVGV7BbtxF3c
# XtHoTC+2AsAUZFva/jfSm+S0FlbEE5NVzea+eD4igoWbdXUtkChdXje5HQSWbXTP
# 5h8UhGcdjGOj0UZnREGxpzqfryUSaCSuSE9oV1YG8SOOn8bnOrd6gMS8x/p+p1ns
# zRIXWU5M2mTH6fzXwFPlRyNb6RV6JzcBAaITjA==
# SIG # End signature block
