$SendFilesButtonAdd_Click = {

        $FileTransferOptionsForm = New-Object System.Windows.Forms.Form -Property @{
            Text   = "PoSh-EasyWin - File Transfer"
            Width  = $FormScale * 450
            Height = $FormScale * 500
            StartPosition = "CenterScreen"
            Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
            Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            AutoScroll    = $True
            #FormBorderStyle =  "fixed3d"
            #ControlBox    = $false
            MaximizeBox   = $false
            MinimizeBox   = $false
            ShowIcon      = $true
            TopMost       = $true
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
                                    AutoSize            = $False
                                    IntegralHeight      = $False
                                    Font                = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                                    Anchor = ([System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right -bor [System.Windows.Forms.AnchorStyles]::Top)
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
                                        $FileTransferStatusBar.Text = ("List contains $($script:FileTransferPathsListBox.Items.Count) items")
                                        Update-SendButtonColor
                                    }
                                }
                                $FileTransferOptionsForm.Controls.Add($script:FileTransferPathsListBox)

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
                            # function MonitorJobScriptBlock {
                            #     param(
                            #         $ExecutionStartTime,
                            #         $CollectionName,
                            #         $NetworkConnectionSearchExecutablePath,
                            #         $NetworkConnectionRegex
                            #     )
                            
                            #     foreach ($TargetComputer in $script:ComputerList) {                            
                            #         if ($ComputerListProvideCredentialsCheckBox.Checked) {
                            #             if (!$script:Credential) { $script:Credential = Get-Credential }
                            #             $QueryCredentialParam = ", $script:Credential"
                            #             $QueryCredential      = "-Credential $script:Credential"
                            #         }
                            #         else {
                            #             $QueryCredentialParam = $null
                            #             $QueryCredential      = $null
                            #         }
                            
                            
                            #         if ($ComputerListProvideCredentialsCheckBox.Checked) {
                            #             if (!$script:Credential) { Create-NewCredentials }
                            
                            #             Invoke-Command -ScriptBlock ${function:Query-NetworkConnection} `
                            #             -ArgumentList @($null,$null,$null,$null,$null,$NetworkConnectionSearchExecutablePath,$NetworkConnectionRegex) `
                            #             -ComputerName $TargetComputer `
                            #             -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
                            #             -Credential $script:Credential `
                            #             | Select-Object PSComputerName, *
                            #         }
                            #         else {
                            #             Invoke-Command -ScriptBlock ${function:Query-NetworkConnection} `
                            #             -ArgumentList @($null,$null,$null,$null,$null,$NetworkConnectionSearchExecutablePath,$NetworkConnectionRegex) `
                            #             -ComputerName $TargetComputer `
                            #             -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
                            #             | Select-Object PSComputerName, *
                            #         }
                            #     }
                            # }
                            
                            foreach ($TargetComputer in $script:ComputerList) {
                                if ($ComputerListProvideCredentialsCheckBox.Checked) {
                                    if (!$script:Credential) { Create-NewCredentials }
                            
                                    Start-Job -ScriptBlock {
                                        param($FileTransferPathsListBox,$FileTransferDestinationPathRichTextBox,$TargetComputer,$Credential)
                                
                                        # In case a $TargetComputer is an IP Address and not a Hostname
                                        $TargetComputerDrive = $TargetComputer -replace '`.','-'
                                        
                                        $AdminShare   = ($FileTransferDestinationPathRichTextBox | Split-Path -Qualifier) -replace ':','$'
                                        $TargetFolder = ($FileTransferDestinationPathRichTextBox | Split-Path -NoQualifier).Trim('\')

                                        echo $FileTransferDestinationPathRichTextBox > c:\DestinationTextbox.txt
                                        echo $AdminShare > c:\AdminShare.txt
                                        echo $TargetFolder > c:\TargetFolder.txt
                                        echo $TargetComputerDrive > c:\TargetComputerDrive.txt

                                        New-PSDrive -Name $TargetComputerDrive `
                                        -PSProvider FileSystem `
                                        -Root "\\$TargetComputer\$AdminShare\$TargetFolder" `
                                        -Credential $Credential | Out-Null
                            
                                        $Credential > c:\credential.txt

                                        "\\$TargetComputer\$AdminShare\$TargetFolder" > c:\root.txt
                                        echo $FileTransferPathsListBox > c:\FileTransferListBox.txt

                                        foreach ($Path in $FileTransferPathsListBox) {
                                            Copy-Item -Path $Path -Destination "$($TargetComputerDrive):" -Recurse -Force
                                            echo $Path > c:\path.txt
                                            "$($TargetComputerDrive):" > c:\TargetComputerDrive.txt
                                        }

                                        Remove-PSDrive -Name $TargetComputerDrive | Out-Null
                            
                                    } `
                                    -ArgumentList @($script:FileTransferPathsListBox.Items,$script:FileTransferDestinationPathRichTextBox.text,$TargetComputer,$script:Credential) `
                                    -Name "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"

                                    Get-Job > c:\Get-Jobs.txt
                                    echo '1' > c:\1.txt
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