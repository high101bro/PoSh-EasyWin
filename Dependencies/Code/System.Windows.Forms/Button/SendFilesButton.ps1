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
                                Checked   = $true
                                Enabled   = $true
                            }
                            $FileTransferProtocolGroupBox.Controls.Add($script:FileTransferProtocolWinRMRadioButton)


                            $script:FileTransferProtocolRPCRadioButton = New-Object Windows.Forms.RadioButton -Property @{
                                Text   = "RPC (n/a)"
                                Left   = $script:FileTransferProtocolWinRMRadioButton.Left
                                Top    = $script:FileTransferProtocolWinRMRadioButton.Top + $script:FileTransferProtocolWinRMRadioButton.Height
                                Width  = $FormScale * 75
                                Height = $FormScale * 22
                                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                                ForeColor = 'Black'
                                Checked   = $false
                                Enabled   = $false
                            }
                            $FileTransferProtocolGroupBox.Controls.Add($script:FileTransferProtocolRPCRadioButton)

                            
                            $script:FileTransferProtocolSMBRadioButton = New-Object Windows.Forms.RadioButton -Property @{
                                Text   = "SMB (n/a)"
                                Left   = $script:FileTransferProtocolRPCRadioButton.Left
                                Top    = $script:FileTransferProtocolRPCRadioButton.Top + $script:FileTransferProtocolRPCRadioButton.Height
                                Width  = $FormScale * 75
                                Height = $FormScale * 22
                                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                                ForeColor = 'Black'
                                Checked   = $false
                                Enabled   = $false
                            }
                            $FileTransferProtocolGroupBox.Controls.Add($script:FileTransferProtocolSMBRadioButton)


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
                    CommonButtonSettings -Button $FileTransferChooseFilesButton
    


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
                    CommonButtonSettings -Button $FileTransferChooseDirectoryButton
                        

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
                    CommonButtonSettings -Button $FileTransferPropertyList1Button
    
    
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
                    CommonButtonSettings -Button $FileTransferRemoveButton
        
    

                                function Update-SendButtonColor {
                                    if ( $script:FileTransferPathsListBox.SelectedItems.count -gt 0 ) {
                                        $FileTransferSendButton.BackColor = 'LightGreen'                                    
                                    }
                                    else {
                                        $FileTransferSendButton.BackColor = 'LightGray'                                         
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
                        Add_Click = {
                            Generate-ComputerList
                            $CollectionName = 'Send Files'
                            
                            $FilePaths = [array]$script:FileTransferPathsListBox.SelectedItems

                            foreach ($TargetComputer in $script:ComputerList) {
                                if ($ComputerListProvideCredentialsCheckBox.Checked) {
                                    if (!$script:Credential) { Create-NewCredentials }
                                    
                                    Start-Job -ScriptBlock {
                                        param(
                                            $FileTransferPathsListBox,
                                            $FileTransferDestinationPathRichTextBox,
                                            $TargetComputer,
                                            $Credential,
                                            $FileTransferProtocolWinRMRadioButton,
                                            $FileTransferProtocolRPCRadioButton,
                                            $FileTransferProtocolSMBRadioButton
                                        )
                                        if ($FileTransferProtocolWinRMRadioButton.checked) {
                                            # In case a $TargetComputer is an IP Address and not a Hostname
                                            $TargetComputerDrive = $TargetComputer -replace '`.','-'
                                            
                                            $AdminShare   = ($FileTransferDestinationPathRichTextBox | Split-Path -Qualifier) -replace ':','$'
                                            $TargetFolder = ($FileTransferDestinationPathRichTextBox | Split-Path -NoQualifier).Trim('\')

                                            New-PSDrive -Name $TargetComputerDrive `
                                            -PSProvider FileSystem `
                                            -Root "\\$TargetComputer\$AdminShare\$TargetFolder" `
                                            -Credential $Credential | Out-Null
                                
                                            foreach ($Path in $FileTransferPathsListBox) {
                                                Copy-Item -Path $Path -Destination "$($TargetComputerDrive):" -Recurse -Force
                                            }

                                            Remove-PSDrive -Name $TargetComputerDrive | Out-Null
                                        }
                                        elseif ($FileTransferProtocolRPCRadioButton.checked) {
                                            $null
                                        }
                                        elseif ($FileTransferProtocolSMBRadioButton.checked) {
                                            $null
                                        }
                                    } `
                                    -ArgumentList @($FilePaths,$script:FileTransferDestinationPathRichTextBox.text,$TargetComputer,$script:Credential,$script:FileTransferProtocolWinRMRadioButton,$script:FileTransferProtocolRPCRadioButton,$script:FileTransferProtocolSMBRadioButton) `
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
Regular Expression:
===========================================================================
$NetworkConnectionRegex

===========================================================================
Remote IP Address:
===========================================================================
$($SearchString.trim())

"@

                            #Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:MonitorJobScriptBlock} -ArgumentList @($ExecutionStartTime,$CollectionName,$NetworkConnectionSearchExecutablePath) -InputValues $InputValues

                            if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
                                Monitor-Jobs -CollectionName $CollectionName -MonitorMode -InputValues $InputValues
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
                    CommonButtonSettings -Button $FileTransferSendButton
    
                    

                    $FileTransferStatusBar = New-Object System.Windows.Forms.StatusBar
                    $FileTransferStatusBar.Text = "Ready"
                    $FileTransferOptionsForm.Controls.Add($FileTransferStatusBar)
        
        $FileTransferOptionsForm.ShowDialog()   
}