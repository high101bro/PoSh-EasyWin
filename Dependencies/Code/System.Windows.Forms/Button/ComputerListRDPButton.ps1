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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQULxzpurD+zbNdb/puObuD8lgn
# 9JugggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUKmo+V9WyeQiCTVyCwPH2aHtTifkwDQYJKoZI
# hvcNAQEBBQAEggEAdtvzAzp3js8OcYKxSCQ0VvoAh4y06t2hCYo/h1q/yhCX4bOI
# YbMxiSkuaxGwVP4MyEZnF6hkaOmive/+qZfIRYAtxaCynuP4RCuhoUj6aGbzpVZk
# H6HfZLIOQ+xtRq0ubQJuxChCL7yISBdWAAwDFh2nJBLCyuAaOh+cRlS2PtemIIvp
# 1wT2uraZArt2k8SKESXD6m/mTueSut3qN1X331EOTjLtJnsSvXXV0QKn5aWTfyKC
# 8bwJUpW3Y6YnAJ5uMRTaWwKkXOAWImecc7i55G5Y5uASM5TkuL+4KGz8eTEjar9x
# u4bvCSOcpgw2nOFnwSqi0/tvxL96IlzJvLePsQ==
# SIG # End signature block
