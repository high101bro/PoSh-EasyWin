$ComputerListRDPButtonAdd_Click = {
    $InformationTabControl.SelectedTab = $Section3ResultsTab
    Create-TreeViewCheckBoxArray -Endpoint
    Generate-ComputerList

    if ($script:ComputerListProvideCredentialsCheckBox.Checked) { $Username = $script:Credential.UserName}
    else {$Username = $PoShEasyWinAccountLaunch }

    if ($script:ComputerListEndpointNameToolStripLabel.text) {
        $VerifyAction = Verify-Action -Title "Verification: Remote Desktop" -Question "Connecting Account:  $Username`n`nOpen a Remote Desktop session to the following?" -Computer $($script:ComputerListEndpointNameToolStripLabel.text)
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
        [System.Windows.Forms.Messagebox]::Show('Left click an endpoint node to select it, then right click to access the context menu and select Remote Desktop.','Remote Desktop')
    }

    if ($VerifyAction) {
        # This brings specific tabs to the forefront/front view
        $InformationTabControl.SelectedTab = $Section3ResultsTab
        if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
            if (!$script:Credential) { Create-NewCredentials }

            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Credentials Used: $($script:Credential.UserName)"

            $Username = $null
            $Password = $null
            $Username = $script:Credential.UserName
            $Password = $script:Credential.GetNetworkCredential().Password
            #doesn't store in base64# $Password = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Password))

            # The cmdkey utility helps you manage username and passwords; it allows you to create, delete, and display credentials for the current user
                # cmdkey /list                <-- lists all credentials
                # cmdkey /list:targetname     <-- lists the credentials for a speicific target
                # cmdkey /add:targetname      <-- creates domain credential
                # cmdkey /generic:targetname  <-- creates a generic credential
                # cmdkey /delete:targetname   <-- deletes target credential
            #cmdkey /generic:TERMSRV/$script:ComputerTreeViewSelected /user:$Username /pass:$Password
            cmdkey /delete:"$script:ComputerTreeViewSelected"
            cmdkey /delete /ras

            #doesn't store in base64# cmdkey /generic:$script:ComputerTreeViewSelected /user:"$Username" /pass:"$([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String(`"$Password`")))"

            cmdkey /generic:$script:ComputerTreeViewSelected /user:"$Username" /pass:"$Password"
            mstsc /v:$($script:ComputerTreeViewSelected):3389 /admin /noConsentPrompt /f

            # There seems to be a delay between the credential passing before credentials can be removed locally from cmdkey and them still being needed
            Start-Sleep -Seconds 5
            cmdkey /delete /ras
            cmdkey /delete:"$script:ComputerTreeViewSelected"

            if ($script:RollCredentialsState -and $script:ComputerListProvideCredentialsCheckBox.checked) {
                Start-Sleep -Seconds 3
                Generate-NewRollingPassword
            }
        }
        else {
            #ensures no credentials are stored for use
            cmdkey /delete /ras
            cmdkey /delete:"$script:ComputerTreeViewSelected"

            mstsc /v:$($script:ComputerTreeViewSelected):3389 /admin /noConsentPrompt /f
        }

        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Remote Desktop:  $($script:ComputerTreeViewSelected)")
        #Removed For Testing#$ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("mstsc /v:$($script:ComputerTreeViewSelected):3389 /NoConsentPrompt")
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Remote Desktop (RDP): $($script:ComputerTreeViewSelected)"
    }
    else {
        [system.media.systemsounds]::Exclamation.play()
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Remote Desktop:  Cancelled")
    }
}
# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU4uALRrT5OjRhiuGHNZSyF0+p
# o1ugggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUiniKtzmTI4Dnu1B3eZu824RsV+owDQYJKoZI
# hvcNAQEBBQAEggEAU+Z0ix0GdN02Q3Kg3bbN/ZVONKpOtW2dH++/GwW7zE1QdBRy
# 69pGdmTzi5n5uU051osxQb7VWH7vv2ve4LZ7V8QduuWs5ZGVDft2FE9gHlHxh06F
# 4u9MffHxCCws/vfwCvy6SB3Kd5oc0GH7W23HNDcJBM82OA6XMRWH4jJbZNt9sG4Z
# F+ouO6OUTiC6c3aX5OHC8MhVs61L4mVE5vVooPmjd0FwmMlgQvj6xnUysLiVuO6V
# /1ltYtEv5QCTrHqjdK3rGdsiSmw2sunBAGPKEoYAESCfkIHhhczBasxS2zNlyTF2
# d0T0VBhVGBHhu8XMECjRMi+SfKC/LxyC/DI//g==
# SIG # End signature block
