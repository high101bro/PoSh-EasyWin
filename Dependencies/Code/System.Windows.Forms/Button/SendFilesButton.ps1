$SendFilesButtonAdd_Click = {

        $FileTransferOptionsForm = New-Object System.Windows.Forms.Form -Property @{
            Text   = "PoSh-EasyWin - File Transfer"
            Width  = $FormScale * 470
            Height = $FormScale * 535
            StartPosition = "CenterScreen"
            Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
            Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            AutoScroll    = $True
            #FormBorderStyle =  "fixed3d"
            #ControlBox    = $false
            MaximizeBox   = $false
            MinimizeBox   = $false
            ShowIcon      = $true
            TopMost       = $false
            Add_Shown     = $null
            Add_Closing = { $This.dispose() }
        }
    
    
                    $FileTransferPropertyList0PictureBox = New-Object Windows.Forms.PictureBox -Property @{
                        Text   = "PowerShell Charts"
                        Left   = $FormScale * 10
                        Top    = $FormScale * 10
                        Width  = $FormScale * 275
                        Height = $FormScale * 44
                        Image  = [System.Drawing.Image]::Fromfile("$Dependencies\Images\Send_Files_Banner.png")
                        SizeMode = 'StretchImage'
                    }
                    $FileTransferOptionsForm.Controls.Add($FileTransferPropertyList0PictureBox)

                    
                            $FileTransferProtocolGroupBox = New-Object Windows.Forms.GroupBox -Property @{
                                Text   = "Protocol:"
                                Left   = $FileTransferPropertyList0PictureBox.Left + $FileTransferPropertyList0PictureBox.Width + ($FormScale * 40)
                                Top    = $FileTransferPropertyList0PictureBox.Top + ($FormScale * 10)
                                Width  = $FormScale * 100
                                Height = $FormScale * 85
                                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
                                ForeColor = 'Blue'
                            }
                            $FileTransferOptionsForm.Controls.Add($FileTransferProtocolGroupBox)

                    
                            $script:FileTransferProtocolWinRMRadioButton = New-Object Windows.Forms.RadioButton -Property @{
                                Text   = "WinRM"
                                Left   = $FormScale * 15
                                Top    = $FormScale * 15
                                Width  = $FormScale * 75
                                Height = $FormScale * 22
                                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                                ForeColor = 'Black'
                                Enabled   = $true
                                Add_Click = { $this.Text | Set-Content "$PoShHome\Settings\Send Files Protocol.txt" -Force }
                            }
                            $FileTransferProtocolGroupBox.Controls.Add($script:FileTransferProtocolWinRMRadioButton)


                            $script:FileTransferProtocolSMBRadioButton = New-Object Windows.Forms.RadioButton -Property @{
                                Text   = "SMB"
                                Left   = $script:FileTransferProtocolWinRMRadioButton.Left
                                Top    = $script:FileTransferProtocolWinRMRadioButton.Top + $script:FileTransferProtocolWinRMRadioButton.Height
                                Width  = $FormScale * 75
                                Height = $FormScale * 22
                                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                                ForeColor = 'Black'
                                Enabled   = $true
                                Add_Click = { $this.Text | Set-Content "$PoShHome\Settings\Send Files Protocol.txt" -Force }
                            }
                            $FileTransferProtocolGroupBox.Controls.Add($script:FileTransferProtocolSMBRadioButton)


                            $script:FileTransferProtocolRPCRadioButton = New-Object Windows.Forms.RadioButton -Property @{
                                Text   = "RPC (n/a)"
                                Left   = $script:FileTransferProtocolSMBRadioButton.Left
                                Top    = $script:FileTransferProtocolSMBRadioButton.Top + $script:FileTransferProtocolSMBRadioButton.Height
                                Width  = $FormScale * 75
                                Height = $FormScale * 22
                                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                                ForeColor = 'Black'
                                Enabled   = $false
                                #Add_Click = { $this.Text | Set-Content "$PoShHome\Settings\Send Files Protocol.txt" -Force }
                            }
                            $FileTransferProtocolGroupBox.Controls.Add($script:FileTransferProtocolRPCRadioButton)

                            if ((Test-Path "$PoShHome\Settings\Send Files Protocol.txt")) { 
                                if ((Get-Content "$PoShHome\Settings\Send Files Protocol.txt") -eq 'WinRM') {
                                    $script:FileTransferProtocolWinRMRadioButton.checked = $true
                                }
                                elseif ((Get-Content "$PoShHome\Settings\Send Files Protocol.txt") -eq 'SMB')   {
                                    $script:FileTransferProtocolSMBRadioButton.checked = $true
                                }
                                elseif ((Get-Content "$PoShHome\Settings\Send Files Protocol.txt") -eq 'RPC') {
                                    $script:FileTransferProtocolRPCRadioButton.checked = $true
                                }
                                else {
                                    $script:FileTransferProtocolWinRMRadioButton.checked = $true
                                }
                            }
                            else {
                                $script:FileTransferProtocolWinRMRadioButton.checked = $true
                            }


                    $FileTransferPropertyList0Label = New-Object System.Windows.Forms.Label -Property @{
                        Text   = "Select any number of files to send to endpoints."
                        Left   = $FormScale * 10
                        Top    = $FileTransferPropertyList0PictureBox.Top + $FileTransferPropertyList0PictureBox.Height + ($FormScale * 5)
                        Width  = $FormScale * 405
                        Height = $FormScale * 22
                        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
                        ForeColor = 'Blue'
                    }
                    $FileTransferOptionsForm.Controls.Add($FileTransferPropertyList0Label)
    
    
                    $FileTransferPropertyList1Label = New-Object System.Windows.Forms.Label -Property @{
                        Text   = "You can also Drag and Drop files into the area below."
                        Left   = $FormScale * 10
                        Top    = $FileTransferPropertyList0Label.Top + $FileTransferPropertyList0Label.Height + ($FormScale * 5)
                        Width  = $FormScale * 405
                        Height = $FormScale * 22
                        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,2,1)
                    }
                    $FileTransferOptionsForm.Controls.Add($FileTransferPropertyList1Label)
    
    
                    $FileTransferChooseFilesButton = New-Object System.Windows.Forms.Button -Property @{
                        Text   = "Chose Files"
                        Left   = $FormScale * 10
                        Top    = $FileTransferPropertyList1Label.Top + $FileTransferPropertyList1Label.Height
                        Width  = $FormScale * 100
                        Height = $FormScale * 22
                        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
                        Add_Click = {
                            $FileTransferPropertyImportOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{
                                Title            = "Select Files To Send To Endpoints"
                                InitialDirectory = "$PoShHome"
                                filter           = "All files (*.*)|*.*|CSV (*.csv)| *.csv|Excel (*.xlsx)| *.xlsx|Excel (*.xls)| *.xls"
                                ShowHelp         = $true
                                Multiselect      = $true
                            }
                            $FileTransferPropertyImportOpenFileDialog.ShowDialog() | Out-Null
                            foreach ($filename in $FileTransferPropertyImportOpenFileDialog.filenames) {
                                if ( $filename -in $script:FileTransferPathsListBox.Items) {
                                    [System.Windows.Forms.MessageBox]::Show("The filepath has previously been added for:  $filename.","PoSh-EasyWin - Duplicate File Detected",'Ok',"Info")
                                }
                                else {
                                    $script:FileTransferPathsListBox.Items.Add($filename)
                                    $script:SendFilesValueStoreListBox += $filename
                                }
                            }
                            Update-SendButtonColor
                            $FileTransferStatusBar.Text = ("List contains $($script:FileTransferPathsListBox.Items.Count) items")
                        }
                    }
                    $FileTransferOptionsForm.Controls.Add($FileTransferChooseFilesButton)
                    Apply-CommonButtonSettings -Button $FileTransferChooseFilesButton
    


                    $FileTransferChooseDirectoryButton = New-Object System.Windows.Forms.Button -Property @{
                        Text   = "Chose Directory"
                        Left   = $FileTransferChooseFilesButton.Left + $FileTransferChooseFilesButton.Width + ($FormScale * 5)
                        Top    = $FileTransferChooseFilesButton.Top
                        Width  = $FormScale * 100
                        Height = $FormScale * 22
                        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
                        Add_Click = {
                            $FileTransferPropertyImportFolderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{
                                Description            = "Select a Directory To Send To Endpoints"
                                #InitialDirectory = "$PoShHome"
                                #filter           = "All files (*.*)|*.*|CSV (*.csv)| *.csv|Excel (*.xlsx)| *.xlsx|Excel (*.xls)| *.xls"
                                #ShowHelp         = $true
                                #Multiselect      = $true
                            }
                            $FileTransferPropertyImportFolderBrowserDialog.ShowDialog() | Out-Null
                            foreach ($directory in $FileTransferPropertyImportFolderBrowserDialog.SelectedPath) {
                                if ( $directory -in $script:FileTransferPathsListBox.Items) {
                                    [System.Windows.Forms.MessageBox]::Show("The filepath has previously been added for:  $directory.","PoSh-EasyWin - Duplicate File Detected",'Ok',"Info")
                                }
                                else {
                                    $script:FileTransferPathsListBox.Items.Add($directory)
                                    $script:SendFilesValueStoreListBox += $directory
                                }
                            }
                            Update-SendButtonColor
                            $FileTransferStatusBar.Text = ("List contains $($script:FileTransferPathsListBox.Items.Count) items")
                        }
                    }
                    $FileTransferOptionsForm.Controls.Add($FileTransferChooseDirectoryButton)
                    Apply-CommonButtonSettings -Button $FileTransferChooseDirectoryButton
                        

                    $FileTransferPropertyList1Button = New-Object System.Windows.Forms.Button -Property @{
                        Text   = "Select All"
                        Left   = $FileTransferChooseDirectoryButton.Left + $FileTransferChooseDirectoryButton.Width + ($FormScale * 5)
                        Top    = $FileTransferChooseDirectoryButton.Top
                        Width  = $FormScale * 100
                        Height = $FormScale * 22
                        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                        ForeColor = 'Black'
                        Add_Click = {
                            for($i = 0; $i -lt $script:FileTransferPathsListBox.Items.Count; $i++) { $script:FileTransferPathsListBox.SetSelected($i, $true) }
                            Update-SendButtonColor
                        }
                    }
                    $FileTransferOptionsForm.Controls.Add($FileTransferPropertyList1Button)
                    Apply-CommonButtonSettings -Button $FileTransferPropertyList1Button
    
    
                    $FileTransferRemoveButton = New-Object System.Windows.Forms.Button -Property @{
                        Text   = "Remove"
                        Left   = $FileTransferPropertyList1Button.Left + $FileTransferPropertyList1Button.Width + ($FormScale * 5)
                        Top    = $FileTransferPropertyList1Button.Top
                        Width  = $FormScale * 100
                        Height = $FormScale * 22
                        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                        ForeColor = 'Black'
                        Add_Click = {
                            while($script:FileTransferPathsListBox.SelectedItems) {
                                $script:FileTransferPathsListBox.Items.Remove($script:FileTransferPathsListBox.SelectedItems[0])
                            }

                            $script:SendFilesValueStoreListBox = $script:FileTransferPathsListBox.items

                            Update-SendButtonColor
                        }
                    }
                    $FileTransferOptionsForm.Controls.Add($FileTransferRemoveButton)
                    Apply-CommonButtonSettings -Button $FileTransferRemoveButton
        
    

                                function Update-SendButtonColor {
                                    if ( $script:ComputerList -gt 0 -and $script:FileTransferPathsListBox.SelectedItems.count -gt 0 ) {
                                        $FileTransferSendButton.BackColor = 'LightGreen'
                                        $FileTransferSendButton.Enabled = $true
                                    }
                                    else {
                                        $FileTransferSendButton.BackColor = 'LightGray'                                         
                                        $FileTransferSendButton.Enabled = $false
                                        #$FileTransferSendButton.ResetBackColor()
                                    }
                                }
    
    
                                $script:FileTransferPathsListBox = New-Object System.Windows.Forms.ListBox -Property @{
                                    Left   = $FormScale * 10
                                    Top    = $FileTransferChooseFilesButton.Top + $FileTransferChooseFilesButton.Height + ($FormScale * 5)
                                    Width  = $FormScale * 415
                                    Height = $FormScale * 251
                                    AllowDrop           = $True
                                    FormattingEnabled   = $True
                                    SelectionMode       = 'MultiExtended'
                                    ScrollAlwaysVisible = $True
                                    #AutoSize            = $False
                                    #IntegralHeight      = $False
                                    Font                = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                                    #Anchor = ([System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right -bor [System.Windows.Forms.AnchorStyles]::Top)
                                    Add_Click = {
                                        Update-SendButtonColor
                                    }
                                    Add_DragOver = [System.Windows.Forms.DragEventHandler]{
                                        if ( $_.Data.GetDataPresent([Windows.Forms.DataFormats]::FileDrop) ) {
                                            $_.Effect = 'Copy'
                                        }
                                        else {
                                            $_.Effect = 'None'
                                        }
                                    }
                                    Add_DragDrop = [System.Windows.Forms.DragEventHandler]{
                                        foreach ($filename in $_.Data.GetData([Windows.Forms.DataFormats]::FileDrop)) {
                                            if ( $filename -in $script:FileTransferPathsListBox.Items) {
                                                [System.Windows.Forms.MessageBox]::Show("The filepath has previously been added for:  $filename.","PoSh-EasyWin - Duplicate File Detected",'Ok',"Info")
                                            }
                                            else {
                                                $script:FileTransferPathsListBox.Items.Add($filename)
                                            }
                                        }
                                        $script:SendFilesValueStoreListBox = $script:FileTransferPathsListBox.items

                                        $FileTransferStatusBar.Text = ("List contains $($script:FileTransferPathsListBox.Items.Count) items")
                                        Update-SendButtonColor
                                    }
                                }
                                $FileTransferOptionsForm.Controls.Add($script:FileTransferPathsListBox)

                                foreach ($path in $script:SendFilesValueStoreListBox) {
                                    $script:FileTransferPathsListBox.Items.Add($path)
                                }
    

                    $FileTransferDestinationPathLabel = New-Object System.Windows.Forms.Label -Property @{
                        Text   = "Destination Path:"
                        Left   = $FormScale * 10
                        Top    = $script:FileTransferPathsListBox.Top + $script:FileTransferPathsListBox.Height + ($FormScale * 5)
                        Width  = $FormScale * 415
                        Height = $FormScale * 22
                        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,2,1)
                    }
                    $FileTransferOptionsForm.Controls.Add($FileTransferDestinationPathLabel)


                    $script:FileTransferDestinationPathRichTextBox = New-Object System.Windows.Forms.TextBox -Property @{
                        Text   = "C:\Windows\Temp"
                        Left   = $FormScale * 10
                        Top    = $FileTransferDestinationPathLabel.Top + $FileTransferDestinationPathLabel.Height + ($FormScale * 5)
                        Width  = $FormScale * 415
                        Height = $FormScale * 22
                        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                    }
                    $FileTransferOptionsForm.Controls.Add($script:FileTransferDestinationPathRichTextBox)


                    $FileTransferSendButton = New-Object System.Windows.Forms.Button -Property @{
                        Text   = "Send"
                        Left   = $FileTransferDestinationPathRichTextBox.Left + $FileTransferDestinationPathRichTextBox.Width - ($FormScale * 100)
                        Top    = $FileTransferDestinationPathRichTextBox.Top + $FileTransferDestinationPathRichTextBox.Height + ($FormScale * 5)
                        Width  = $FormScale * 100
                        Height = $FormScale * 22
                        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
                        Enabled = $false
                        Add_Click = {
                            Generate-ComputerList
                            $CollectionName = 'Send Files'
                            
                            $FilePaths = [array]$script:FileTransferPathsListBox.SelectedItems

                            foreach ($TargetComputer in $script:ComputerList) {
                                if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                                    if (!$script:Credential) { Create-NewCredentials }
                                    
                                    Start-Job -ScriptBlock {
                                        param(
                                            $FileTransferPathsListBox,
                                            $FileTransferDestinationPathRichTextBox,
                                            $TargetComputer,
                                            $Credential,
                                            $FileTransferProtocolWinRMRadioButton,
                                            $FileTransferProtocolSMBRadioButton,
                                            $FileTransferProtocolRPCRadioButton
                                        )
                                        if ($FileTransferProtocolWinRMRadioButton.checked -eq $true) {
                                            $PSSession = New-PSSession -ComputerName $TargetComputer -Credential $Credential
                                            Foreach ($Session in $PSSession) {
                                                foreach ($Path in $FileTransferPathsListBox) {
                                                    Copy-Item -Path "$Path" -Recurse -Destination "$FileTransferDestinationPathRichTextBox" -ToSession $Session -Force -ErrorAction Stop
                                                }
                                            }
                                            $PSSession | Remove-PSSession
                                        }
                                        if ($FileTransferProtocolSMBRadioButton.checked -eq $true) {
                                            # In case a $TargetComputer is an IP Address and not a Hostname
                                            $TargetComputerDrive = $TargetComputer -replace '`.','-'
                                            
                                            $AdminShare   = ($FileTransferDestinationPathRichTextBox | Split-Path -Qualifier) -replace ':','$'
                                            $TargetFolder = ($FileTransferDestinationPathRichTextBox | Split-Path -NoQualifier).Trim('\')

                                            New-PSDrive -Name $TargetComputerDrive `
                                            -PSProvider FileSystem `
                                            -Root "\\$TargetComputer\$AdminShare\$TargetFolder" `
                                            -Credential $Credential | Out-Null
                                
                                            foreach ($Path in $FileTransferPathsListBox) {
                                                Copy-Item -Path "$Path" -Destination "$($TargetComputerDrive):" -Recurse -Force
                                            }

                                            Remove-PSDrive -Name $TargetComputerDrive | Out-Null
                                        }
                                        if ($FileTransferProtocolRPCRadioButton.checked -eq $true) {
                                            $null
                                        }
                                    } `
                                    -ArgumentList @($FilePaths,$script:FileTransferDestinationPathRichTextBox.text,$TargetComputer,$script:Credential,$script:FileTransferProtocolWinRMRadioButton,$script:FileTransferProtocolSMBRadioButton,$script:FileTransferProtocolRPCRadioButton) `
                                    -Name "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"

                                    ############Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `${function:ExecutableAndScript} -ArgumentList @(`$ExeScriptSelectScript,`$ExeScriptScriptOnlyCheckbox,`$ExeScriptSelectDirRadioButton,`$ExeScriptSelectFileRadioButton,`$ExeScriptSelectDirOrFilePath,`$TargetComputer,`$AdminShare,`$TargetFolder) -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)' -Credential `$script:Credential"
                                }
                            }


                            $EndpointString = ''
                            foreach ($item in $script:ComputerList) {$EndpointString += "$item`n"}

                            $InputValues = @"
===========================================================================
Collection Name:
===========================================================================
Send Files

===========================================================================
Execution Time:
===========================================================================
$(Get-Date)

===========================================================================
Credentials:
===========================================================================
$($script:Credential.UserName)

===========================================================================
Endpoints:
===========================================================================
$($EndpointString.trim())

===========================================================================
Remote IP Address:
===========================================================================
$($SearchString.trim())

"@

                            if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
                                Monitor-Jobs -CollectionName $CollectionName -MonitorMode -InputValues $InputValues -SendFileSwitch -SendFilePath "$($script:FileTransferDestinationPathRichTextBox.text)" -ComputerName $script:ComputerList
                            }
                            elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Individual Execution') {
                                Monitor-Jobs -CollectionName $CollectionName
                                Post-MonitorJobs -CollectionName $CollectionName -CollectionCommandStartTime $ExecutionStartTime
                            }


                            while($script:FileTransferPathsListBox.SelectedItems) {
                                $script:FileTransferPathsListBox.Items.Remove($script:FileTransferPathsListBox.SelectedItems[0])
                            }
                            $FileTransferOptionsForm.Dispose()
                        }
                    }
                    $FileTransferOptionsForm.Controls.Add($FileTransferSendButton)
                    Apply-CommonButtonSettings -Button $FileTransferSendButton
    
                    

                    $FileTransferStatusBar = New-Object System.Windows.Forms.StatusBar
                    $FileTransferStatusBar.Text = "Ready"
                    $FileTransferOptionsForm.Controls.Add($FileTransferStatusBar)
        
        $FileTransferOptionsForm.ShowDialog()   
}
# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU/0yPEkLkJIyqvqOt9BLWdFUb
# 9CqgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUvAsw3ULRUphxLRKjXZK9yPeH/H0wDQYJKoZI
# hvcNAQEBBQAEggEAU9MXI9+b959Ng1aPmoHIfSdXRsihD0J4eiQ6iBlrouFrBZ4J
# QTNV05PF2q1qy9dukyM7N/DbootrFw5UHEAcllIbJfXevK19I7ImYmPVyc8NXc9p
# h9sNo8GEsyQCGDDn7Nc7nlqgyRZnZMLOobhPhC8+yaPr/ya8pwWNt98P3h3pB7Nw
# PMlIc1sczTslnmg8cNe/YfQ+o1lpD7KtrGnG5t4tU+Hl9jYsA/p6iSDqUCq9rCrt
# UkGw37zf71qO94YRpl/A+SWgBIXFLR0PrCyNPVpz44KvZcMHOQEgf+C0JzdUbAeN
# 0hsLiXCa1fsOaUjYHJNWcU2gvZ1x7hhn7DsmXw==
# SIG # End signature block
