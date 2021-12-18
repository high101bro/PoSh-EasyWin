Function Launch-FileShareConnection {

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Windows.Drawing

    $SmbFileShareServerForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = "PoSh-EasyWin - File Share Connection"
        Width  = $FormScale * 540
        Height = $FormScale * 300
        StartPosition = "CenterScreen"
        Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$script:EasyWinIcon")
        Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoScroll    = $True
        #FormBorderStyle =  "fixed3d"
        #ControlBox    = $false
        MaximizeBox   = $false
        MinimizeBox   = $false
        ShowIcon      = $true
        TopMost       = $false
        Add_Shown     = $null
        Add_load = {
            if (Test-Path "$PoShHome\Settings\SMB File Share Hostname IP.txt")    {$script:SmbFileShareServerHostnameIPTextbox.Text    = Get-Content "$PoShHome\Settings\SMB File Share Hostname IP.txt"}
            if (Test-Path "$PoShHome\Settings\SMB File Share File Path.txt")      {$SmbFileShareServerFilePathTextbox.Text      = Get-Content "$PoShHome\Settings\SMB File Share File Path.txt"}
            if (Test-Path "$PoShHome\Settings\SMB File Share Server Name.txt")    {$SmbFileShareServerFileShareNameTextbox.Text = Get-Content "$PoShHome\Settings\SMB File Share Server Name.txt"}
            if (Test-Path "$PoShHome\Settings\SMB File Share Drive Letter.txt")   {$SmbFileShareServerDriveLetterTextbox.Text   = Get-Content "$PoShHome\Settings\SMB File Share Drive Letter.txt"}
            if (Test-Path "$PoShHome\Settings\SMB File Share Account Access.txt") {$SmbFileShareServerAccountAccessTextbox.Text = Get-Content "$PoShHome\Settings\SMB File Share Account Access.txt"}
            if (Test-Path "$PoShHome\Settings\SMB File Share Access Rights.txt")  {$SmbFileShareServerAccessRightsTextbox.Text  = Get-Content "$PoShHome\Settings\SMB File Share Access Rights.txt"}
        }
        Add_Closing = {    
            if (Get-SmbMapping -LocalPath "$($script:SmbShareDriveLetter):") {
                $SaveResultsToFileShareCheckbox.Checked = $true
                $script:CollectionSavedDirectoryTextBox.Text = "$($script:SmbShareDriveLetter):\$((Get-Date).ToString('yyyy-MM-dd HH.mm.ss'))"
            }
            else {
                $SaveResultsToFileShareCheckbox.Checked = $false
            }
            $This.dispose() 
        }
    }




    $SmbFileShareServerLabel = New-Object System.Windows.Forms.label -Property @{
        Text   = "PoSh-EasyWin can store collected data to the localhost's filesystem or to a networked SMB file Share. Elevated permissions are required to create and connect to the SMB file share. This section allows you to specify a file path on a host that you have permissions to and create and/or connect to an SMB file share."
        Left   = $FormScale * 10
        Top    = $FormScale * 10
        Width  = $FormScale * 510
        Height = $FormScale * 60
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $SmbFileShareServerForm.Controls.Add($SmbFileShareServerLabel)


    $SmbFileShareServerConfigurationGroupbox = New-Object System.Windows.Forms.Groupbox -Property @{
        Text   = "SMB File Share Configuration"
        Left   = $SmbFileShareServerLabel.Left
        Top    = $SmbFileShareServerLabel.Top + $SmbFileShareServerLabel.Height + $($FormScale * 5) 
        Width  = $FormScale * 510
        Height = $FormScale * 170
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = 'Blue'
    }
    $SmbFileShareServerForm.Controls.Add($SmbFileShareServerConfigurationGroupbox)


        $SmbFileShareServerHostnameIPLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Server Hostname/IP:"
            Left   = $FormScale * 10
            Top    = $FormScale * 25
            Width  = $FormScale * 120
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $SmbFileShareServerConfigurationGroupbox.Controls.Add($SmbFileShareServerHostnameIPLabel)

            $script:SmbFileShareServerHostnameIPTextbox = New-Object System.Windows.Forms.Textbox -Property @{
                Text   = "localhost"
                Left   = $SmbFileShareServerHostnameIPLabel.Left + $SmbFileShareServerHostnameIPLabel.Width + $($FormScale * 5) 
                Top    = $SmbFileShareServerHostnameIPLabel.Top
                Width  = $FormScale * 360
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            }
            $SmbFileShareServerConfigurationGroupbox.Controls.Add($script:SmbFileShareServerHostnameIPTextbox)


        $SmbFileShareServerFilePathLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Remote File Path:"
            Left   = $SmbFileShareServerHostnameIPLabel.Left
            Top    = $SmbFileShareServerHostnameIPLabel.Top + $SmbFileShareServerHostnameIPLabel.Height + $($FormScale * 5)
            Width  = $FormScale * 120
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $SmbFileShareServerConfigurationGroupbox.Controls.Add($SmbFileShareServerFilePathLabel)

            $SmbFileShareServerFilePathTextbox = New-Object System.Windows.Forms.Textbox -Property @{
                Text   = "C:\Windows\Temp\PoSh-EasyWin Collected Data\"
                Left   = $SmbFileShareServerFilePathLabel.Left + $SmbFileShareServerFilePathLabel.Width + $($FormScale * 5) 
                Top    = $SmbFileShareServerFilePathLabel.Top
                Width  = $FormScale * 360
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            }
            $SmbFileShareServerConfigurationGroupbox.Controls.Add($SmbFileShareServerFilePathTextbox)


        $SmbFileShareServerFileShareNameLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Remote Share Name:"
            Left   = $SmbFileShareServerFilePathLabel.Left
            Top    = $SmbFileShareServerFilePathLabel.Top + $SmbFileShareServerFilePathLabel.Height + $($FormScale * 5)
            Width  = $FormScale * 120
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $SmbFileShareServerConfigurationGroupbox.Controls.Add($SmbFileShareServerFileShareNameLabel)

            $SmbFileShareServerFileShareNameTextbox = New-Object System.Windows.Forms.Textbox -Property @{
                Text   = 'PoSh-EasyWin'
                Left   = $SmbFileShareServerFileShareNameLabel.Left + $SmbFileShareServerFileShareNameLabel.Width + $($FormScale * 5) 
                Top    = $SmbFileShareServerFileShareNameLabel.Top
                Width  = $FormScale * 120
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            }
            $SmbFileShareServerConfigurationGroupbox.Controls.Add($SmbFileShareServerFileShareNameTextbox)


        $SmbFileShareServerDriveLetterLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Local Drive Letter:"
            Left   = $SmbFileShareServerFileShareNameTextbox.Left + $SmbFileShareServerFileShareNameTextbox.Width + $($FormScale * 5) 
            Top    = $SmbFileShareServerFileShareNameTextbox.Top
            Width  = $FormScale * 115
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $SmbFileShareServerConfigurationGroupbox.Controls.Add($SmbFileShareServerDriveLetterLabel)

            $SmbFileShareServerDriveLetterTextbox = New-Object System.Windows.Forms.Textbox -Property @{
                Text   = "P"
                Left   = $SmbFileShareServerDriveLetterLabel.Left + $SmbFileShareServerDriveLetterLabel.Width
                Top    = $SmbFileShareServerDriveLetterLabel.Top
                Width  = $FormScale * 120
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            }
            $SmbFileShareServerConfigurationGroupbox.Controls.Add($SmbFileShareServerDriveLetterTextbox)


        $SmbFileShareServerAccountAccessLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Account Access:"
            Left   = $SmbFileShareServerFileShareNameLabel.Left
            Top    = $SmbFileShareServerFileShareNameLabel.Top + $SmbFileShareServerFileShareNameLabel.Height + $($FormScale * 5)
            Width  = $FormScale * 120
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $SmbFileShareServerConfigurationGroupbox.Controls.Add($SmbFileShareServerAccountAccessLabel)

            $SmbFileShareServerAccountAccessTextbox = New-Object System.Windows.Forms.Textbox -Property @{
                Text   = 'Everyone'
                Left   = $SmbFileShareServerAccountAccessLabel.Left + $SmbFileShareServerAccountAccessLabel.Width + $($FormScale * 5) 
                Top    = $SmbFileShareServerAccountAccessLabel.Top
                Width  = $FormScale * 120
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            }
            $SmbFileShareServerConfigurationGroupbox.Controls.Add($SmbFileShareServerAccountAccessTextbox)


        $SmbFileShareServerAccessRightsLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Access Rigths:"
            Left   = $SmbFileShareServerAccountAccessTextbox.Left + $SmbFileShareServerAccountAccessTextbox.Width + $($FormScale * 5) 
            Top    = $SmbFileShareServerAccountAccessTextbox.Top
            Width  = $FormScale * 115
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $SmbFileShareServerConfigurationGroupbox.Controls.Add($SmbFileShareServerAccessRightsLabel)

            $SmbFileShareServerAccessRightsTextbox = New-Object System.Windows.Forms.ComboBox -Property @{
                Text   = "Full"
                Left   = $SmbFileShareServerAccessRightsLabel.Left + $SmbFileShareServerAccessRightsLabel.Width
                Top    = $SmbFileShareServerAccessRightsLabel.Top
                Width  = $FormScale * 120
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            }
            $SmbFileShareServerConfigurationGroupbox.Controls.Add($SmbFileShareServerAccessRightsTextbox)            
            $SmbFileShareServerAccessRightsList = @('Full','Read','Change')
            ForEach ($Item in $SmbFileShareServerAccessRightsList) { $SmbFileShareServerAccessRightsTextbox.Items.Add($Item) }


    $SmbFileShareServerFilterListSelectionAddButton = New-Object System.Windows.Forms.Button -Property @{
        Text   = 'Connect To SMB Share'
        Left   = $SmbFileShareServerAccountAccessLabel.Left
        Top    = $SmbFileShareServerAccountAccessLabel.Top + $SmbFileShareServerAccountAccessLabel.Height + $($FormScale * 5)
        Width  = $FormScale * 155
        Height = $FormScale * 22
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = 'Black'
        Add_Click = {
            $script:SmbFileShareServerHostnameIPTextbox.Text    | Set-Content "$PoShHome\Settings\SMB File Share Hostname IP.txt" -Force
            $SmbFileShareServerFilePathTextbox.Text      | Set-Content "$PoShHome\Settings\SMB File Share File Path.txt" -Force
            $SmbFileShareServerFileShareNameTextbox.Text | Set-Content "$PoShHome\Settings\SMB File Share Server Name.txt" -Force
            $SmbFileShareServerDriveLetterTextbox.Text   | Set-Content "$PoShHome\Settings\SMB File Share Drive Letter.txt" -Force
            $SmbFileShareServerAccountAccessTextbox.Text | Set-Content "$PoShHome\Settings\SMB File Share Account Access.txt" -Force
            $SmbFileShareServerAccessRightsTextbox.Text  | Set-Content "$PoShHome\Settings\SMB File Share Access Rights.txt" -Force
            
            $script:FileShareName = $SmbFileShareServerFileShareNameTextbox.Text
            $FilePath = $SmbFileShareServerFilePathTextbox.Text
            $script:SMBServer = $script:SmbFileShareServerHostnameIPTextbox.Text
            $script:SmbShareDriveLetter = $SmbFileShareServerDriveLetterTextbox.Text
            $AccountAccess = $SmbFileShareServerAccountAccessTextbox.Text
            $AccountRights = $SmbFileShareServerAccessRightsTextbox.Text

            if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                if (-not $script:Credential) { Create-NewCredentials }
            }

            $InvokeCommandSplat = @{
                ScriptBlock = {
                    param($FilePath,$script:FileShareName,$AccountAccess,$AccountRights)
                    if (-not (Get-PSDrive -Name $script:FileShareName -ErrorAction SilentlyContinue)) {
                        New-Item -Type Directory -Path $FilePath -ErrorAction SilentlyContinue
                        New-SmbShare -Path $FilePath -Name $script:FileShareName
                        Grant-SmbShareAccess -Name $script:FileShareName -AccountName $AccountAccess -AccessRight $AccountRights -Force
                    }
                }
                ArgumentList = @($FilePath,$script:FileShareName,$AccountAccess,$AccountRights)
                ComputerName = $script:SMBServer
                Credential   = $script:Credential
            }
            Invoke-Command @InvokeCommandSplat
                      
            $NewSmbMappingSplat = @{
                LocalPath  = "$($script:SmbShareDriveLetter):"
                RemotePath = "\\$script:SMBServer\$script:FileShareName"
                Persistent = $true
                UserName   = $script:Credential.UserName
                Password   = $script:Credential.GetNetworkCredential().Password
            }
            New-SmbMapping @NewSmbMappingSplat
            net use P: \\hostname\PoSh-EasyWin /USER:user@domain.com 'password' /persistent:Yes

            if (Get-SmbMapping -LocalPath "$($script:SmbShareDriveLetter):") {
                $script:FileTransferStatusBar.Text = "SMB File Share Mapping Exists for: [$($script:SmbShareDriveLetter):] $((Get-SmbMapping).RemotePath)"
                Start-Sleep -Seconds 1
                $SmbFileShareServerForm.Close()
            }
            else {
                $script:FileTransferStatusBar.Text = "SMB File Share Mapping to $script:SMBServer Failed..."
            }
        }
    }
    $SmbFileShareServerConfigurationGroupbox.Controls.Add($SmbFileShareServerFilterListSelectionAddButton)
    Apply-CommonButtonSettings -Button $SmbFileShareServerFilterListSelectionAddButton


    $SmbFileShareServerShowSmbMappingsButton = New-Object System.Windows.Forms.Button -Property @{
        Text   = 'Show SMB Mappings'
        Left   = $SmbFileShareServerFilterListSelectionAddButton.Left + $SmbFileShareServerFilterListSelectionAddButton.Width + $($FormScale * 5)
        Top    = $SmbFileShareServerFilterListSelectionAddButton.Top
        Width  = $FormScale * 155
        Height = $FormScale * 22
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = 'Black'
        Add_Click = {
            Get-SmbMapping | Out-GridView -Title '[localhost] SMB Mappings'

            $InvokeCommandSplat = @{
                ScriptBlock = {
                    $Shares = Get-SmbShare
                    Foreach ($Share in $Shares) {
                        $Rights = Get-SmbShareAccess -Name $Share.Name
                        $Share `
                        | Add-Member -MemberType NoteProperty -Name AccountName -Value "$($Rights.AccountName)" -Force -PassThru `
                        | Add-Member -MemberType NoteProperty -Name AccessRight -Value "$($Rights.AccessRight)" -Force -PassThru `
                        | Add-Member -MemberType NoteProperty -Name AccessControlType -Value "$($Rights.AccessControlType)" -Force -PassThru `
                        | Add-Member -MemberType NoteProperty -Name ScopeName -Value "$($Rights.ScopeName)" -Force -PassThru `
                        | Select-Object -Property @{n='ComputerName';e={$env:COMPUTERNAME}}, Name, Path, Description, AccountName, AccessRight, AccessControlType, ScopeName
                    }
                }
                ComputerName = $script:SmbFileShareServerHostnameIPTextbox.text
            }

            if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { Create-NewCredentials }
                $InvokeCommandSplat += @{ Credential = $script:Credential }
            }
    
            Invoke-Command @InvokeCommandSplat | Out-GridView -Title "[$($script:SmbFileShareServerHostnameIPTextbox.text)] SMB Server Mappings & Permissions"
        }
    }
    $SmbFileShareServerConfigurationGroupbox.Controls.Add($SmbFileShareServerShowSmbMappingsButton)
    Apply-CommonButtonSettings -Button $SmbFileShareServerShowSmbMappingsButton


    $SmbFileShareServerRemoveSmbMappingsButton = New-Object System.Windows.Forms.Button -Property @{
        Text   = 'Remove SMB Mappings'
        Left   = $SmbFileShareServerShowSmbMappingsButton.Left + $SmbFileShareServerShowSmbMappingsButton.Width + $($FormScale * 5)
        Top    = $SmbFileShareServerShowSmbMappingsButton.Top
        Width  = $FormScale * 155
        Height = $FormScale * 22
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = 'Black'
        Add_Click = { Get-SmbMapping | Out-GridView -Title '[localhost] SMB Mappings' -PassThru | Remove-SmbMapping -Force }
    }
    $SmbFileShareServerConfigurationGroupbox.Controls.Add($SmbFileShareServerRemoveSmbMappingsButton)
    Apply-CommonButtonSettings -Button $SmbFileShareServerRemoveSmbMappingsButton
    

    $script:Timer = New-Object System.Windows.Forms.Timer -Property @{
        Enabled  = $true
        Interval = 1000
    }
    $script:Timer.Start()


    $script:FileTransferStatusBar = New-Object System.Windows.Forms.StatusBar


    # $UpdateStatusBar = {
    #     if ($true) { $script:FileTransferStatusBar.Text = Get-Date }
    #     else { $script:Timer.Stop() }
    # }
    # $script:Timer.add_Tick($UpdateStatusBar)
    # $SmbFileShareServerForm.Controls.Add($script:FileTransferStatusBar)
    if ($((Get-SmbMapping).count) -gt 0) {
        $script:FileTransferStatusBar.Text = "Number of SMB Shares Mapped: $((Get-SmbMapping).count)"
    }
    else {
        $script:FileTransferStatusBar.Text = "Number of SMB Shares Mapped: 0"
    }
    $SmbFileShareServerForm.Controls.Add($script:FileTransferStatusBar)

    $SmbFileShareServerForm.ShowDialog()
}

Launch-FileShareConnection

#
# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUd2MWvFTklLWVu+G1a3SRbOby
# /AigggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUzDG1bOvHGyWdp+EL8pc2uz8/nXQwDQYJKoZI
# hvcNAQEBBQAEggEAaQe5ENq7F7j3rEfz7hCKriGH28kJ2/GoAz0Y7yiMXtPLZjdh
# sUm2UOGLDnKuBDcuH1VMmpstQd8b0PzCDlrfcQal311UZhM2JCH6VFFNymVo6JID
# bGPzkla7TFZZS7mDm4T1Xz4EWwAE8qJjdZlBUXLa74aNjezEioR+ZM4LnnG2IyA5
# B3c4+NkvCMlg7acsJq+D8gffp17xj8NrWg93t/N+n+A6gtfOZAtJIpqZcx+k/Dp5
# UHqzI/4T3zoI/qozPR8WRv9Aq7h8JrFsnGQBm5MeIUKQKc/WVWYD2WCVVH0YNEj7
# ZCjkOGU1rVZdeoVz49yew6CiYRRkp62CMs+lyw==
# SIG # End signature block
