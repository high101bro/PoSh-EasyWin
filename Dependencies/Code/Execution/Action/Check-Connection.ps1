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

    if ($script:ComputerTreeViewSelected.count -lt 1) {
        Show-MessageBox -Message "No hostname/IP selected`r`nMake sure to checkbox only one hostname/IP`r`nSelecting a Category will not allow you to connect to multiple hosts" -Title "$($CheckType):  Error"
    }
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
                #    if (!$script:Credential) { Set-NewCredential }
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUy250MrORD5UKtZ9N8mTIwT3A
# 0BigggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUfwZsqt10OIZcafW9DQ7JXFKnf1IwDQYJKoZI
# hvcNAQEBBQAEggEAjium7GwDKMfFVsF/7WP8PDJns/RP5sUT0z+S4Vip3n4CJXYf
# FujGuzTw9yPOzzQmhKtNVTW89HbrcK6SrfdWBUq87uuiDogdV+I7JiL9c7f3UUbG
# Ve9w+vKt3PoWgqkF3oU7i+ewozP6QpFL0VdzCGl000JOMlFRQxFvcliRWFe5AbMN
# YQ1x1AVJGeHokIYgey7ItNGc8PPF6k4OSXu7x5VcKeLAbv8Pvu/dAUJs8BuWjzml
# iOlQFsGa6Xr3rIpu4G8Mna5mB8Kerqo/lBwo6C8hKj+dOCZDABjTR8+4c+fDW2Jd
# 0hilFVWhJq3CFcDopB7edcTTkf69QBoHeNtRPg==
# SIG # End signature block
