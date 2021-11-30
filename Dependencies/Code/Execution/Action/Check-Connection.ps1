function Check-Connection {
    param (
        $CheckType,
        $MessageTrue,
        $MessageFalse
    )
    # This brings specific tabs to the forefront/front view
    $InformationTabControl.SelectedTab   = $Section3ResultsTab

    $ResultsListBox.Items.Clear()

    # Testing the Workflow concept to speedup connection testing...
    <#
    workflow Parallel-ConnectionTest {
        param(
            [string[]]$script:ComputerTreeViewSelected
        )
        $ConnectionTestResults = @()
        foreach -parallel -throttlelimit 30 ($Computer in $script:ComputerTreeViewSelected) {
            $workflow:ConnectionTestResults += Test-Connection -ComputerName $Computer -Count 1
            InlineScript {
                $script:ProgressBarEndpointsProgressBar.Value += 1
                write-host 'inline test'
                write-host $Using:ComputerTreeViewSelected
            }
        }
        InlineScript {
            $Using:ConnectionTestResults
            $script:ProgressBarEndpointsProgressBar.Value += 1
            #$ResultsListBox.Items.Insert(0,"$($MessageTrue):    $target")
            #Start-Sleep -Milliseconds 50
            #$PoShEasyWin.Refresh()

        }
    }
    Parallel-ConnectionTest -ComputerTreeViewSelected $script:ComputerTreeViewSelected
    #>

    function Test-Port {
        param ($ComputerName, $Port)
        begin { $tcp = New-Object Net.Sockets.TcpClient }
        process {
            try { $tcp.Connect($ComputerName, $Port) } catch {}
            if ($tcp.Connected) { $tcp.Close(); $open = $true }
            else { $open = $false }
            [PSCustomObject]@{ IP = $ComputerName; Port = $Port; Open = $open }
        }
    }

    if ($script:ComputerTreeViewSelected.count -lt 1) { ComputerNodeSelectedLessThanOne -Message $CheckType }
    else {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("$($CheckType):  $($script:ComputerTreeViewSelected.count) hosts")

        $script:ProgressBarEndpointsProgressBar.Maximum = $script:ComputerTreeViewSelected.count
        $script:ProgressBarEndpointsProgressBar.Value   = 0

        Start-Sleep -Milliseconds 50

        $script:NotReachable = @()
        foreach ($target in $script:ComputerTreeViewSelected){

            if ($CheckType -eq "Ping") {
                $CheckCommand = Test-Connection -Count 1 -ComputerName $target

                if ($CheckCommand){
                    $ResultsListBox.Items.Insert(0,"$($MessageTrue):      $target")
                    Start-Sleep -Milliseconds 50
                    $PoShEasyWin.Refresh()
                }
                else {
                    $ResultsListBox.Items.Insert(0,"$($MessageFalse):    $target")
                    $script:NotReachable += $target
                }
            }
            elseif ($CheckType -eq "WinRM Check") {
                # The following does a ping first...
                # Test-NetConnection -CommonTCPPort WINRM -ComputerName <Target>

                #if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                #    if (!$script:Credential) { Create-NewCredentials }
                #    $CheckCommand = Test-WSman -ComputerName $target #-Credential $script:Credential
                #}

                $CheckCommand = Test-WSman -ComputerName $target

                if ($CheckCommand){
                    $ResultsListBox.Items.Insert(0,"$($MessageTrue):      $target")
                }
                else {
                    $ResultsListBox.Items.Insert(0,"$($MessageFalse):    $target")
                    $script:NotReachable += $target
                }
            }
            elseif ($CheckType -eq "RPC Port Check") {
                # The following does a ping first...
                # Test-NetConnection -Port 135 -ComputerName <Target>

                #$CheckCommand = Test-Connection -Count 1 -ComputerName $target -Protocol DCOM

                # The following tests for the default RPC port, but not the service itself
                $CheckCommand = Test-Port -ComputerName $target -Port 135 | Select-Object -ExpandProperty Open

                if ($CheckCommand){
                    $ResultsListBox.Items.Insert(0,"$($MessageTrue):      $target")
                }
                else {
                    $ResultsListBox.Items.Insert(0,"$($MessageFalse):    $target")
                    $script:NotReachable += $target
                }
            }
            elseif ($CheckType -eq "SMB Port Check") {
                # The following does a ping first...
                # Test-NetConnection -Port 135 -ComputerName <Target>

                # The following tests for the default RPC port, but not the service itself
                $CheckCommand = Test-Port -ComputerName $target -Port 445 | Select-Object -ExpandProperty Open

                if($CheckCommand){
                    $ResultsListBox.Items.Insert(0,"$($MessageTrue):      $target")
                }
                else {
                    $ResultsListBox.Items.Insert(0,"$($MessageFalse):    $target")
                    $script:NotReachable += $target
                }
            }

            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message " - $CheckCommand"
            $ResultsListBox.Refresh()
            $PoShEasyWin.Refresh()
            Start-Sleep -Milliseconds 50
            $script:ProgressBarEndpointsProgressBar.Value += 1
        }

        # Popup windows requesting user action
        #[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic")
        #$verify = [Microsoft.VisualBasic.Interaction]::MsgBox(`
        #    "Do you want to uncheck unresponsive hosts?", `
        #    #'YesNoCancel,Question', `
        #    'YesNo,Question', `
        #    "PoSh-EasyWin")
        #switch ($verify) {
        #    'Yes'{
                [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
                foreach ($root in $AllTreeViewNodes) {
                    $root.Checked = $False
                    foreach ($Category in $root.Nodes) {
                        $Category.Checked = $False
                        $EntryNodeCheckedCount = 0
                        foreach ($Entry in $Category.nodes) {
                            if ($script:NotReachable -icontains $($Entry.Text)) {
                                $Entry.Checked   = $False
                                $Entry.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                                $Entry.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
                            }
                            if ($Entry.Checked) {
                                $EntryNodeCheckedCount += 1
                            }
                        }
                        if ($EntryNodeCheckedCount -eq 0) {
                            $Category.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                            $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
                        }
                    }
                }
        #    }
        #    'No'     {continue}
        #    #'Cancel' {exit}
        #}
        $ResultsListBox.Items.Insert(0,"")
        $ResultsListBox.Items.Insert(0,"Finished Testing Connections")
    }
}




# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUnhGr2s+NaCzgYLv8DZ4lkcBz
# uZ+gggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUDLUc57jKwhAxhgBgBacd1TkFKR0wDQYJKoZI
# hvcNAQEBBQAEggEAxXXRoxhn/2mDmzi478gjCN8n9CeucmvynAg3Dm/pn9b3GHQ+
# vsf067qIcpy+m4UILTge3lL6RQ4lcJvyz3LRTcZCGSExKmJ/z9Wx7C5q4yopEQma
# +SZGWvcA+j1UNomw/0I4NJOjL9IdSKUaadVV1KUqM33SjkY39ZXZkAwUKX0K0JFO
# LLoTKIMDO6rWZPNOwS/nyoHhhKdjyE5KGDFDUuqUZAafE/EgNNXQIFXvL5LPisH6
# kgDlABGXGsM5tzqh+N2Rc8WPA1K9jge+BUVtqvTLTNRGbA2ecWkmRo3u8sc9CiNA
# Z1GcVyZFNpOBAmmI9JZ+MvYGNMykwcEI3GR8Dg==
# SIG # End signature block
