####################################################################################################
# ScriptBlocks
####################################################################################################

$CollectionSavedDirectoryTextBoxAdd_MouseHover = {
    Show-ToolTip -Title "Results Folder" -Icon "Info" -Message @"
+  This path supports auto-directory completion.
+  Collections are saved to a 'Collected Data' directory that is created
    automatically where the PoSh-EasyWin script is executed from.
+  The directory's timestamp does not auto-renew after data is collected,
    you have to manually do so. This allows you to easily run multiple
    collections and keep this co-located.
+  The full directory path may also be manually modified to contain any
    number or characters that are permitted within NTFS. This allows
    data to be saved to uniquely named or previous directories created.
"@
}

$SendFilesButtonAdd_Click = {
    #batman - convert this scriptblock into a function called Launch-FileTransferForm
    $FileTransferOptionsForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = "PoSh-EasyWin - File Transfer"
        Width  = $FormScale * 470
        Height = $FormScale * 535
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

$RetrieveFilesButtonAdd_Click = {

    [System.Windows.Forms.MessageBox]::Show("Ensure you execute a recent File Search or Directory Listing Query prior to attempting to retrieve files from one or more endpoints.","PoSh-EasyWin - Retrieve Files",'Ok',"Info")

    $MainLeftTabControl.SelectedTab = $Section1SearchTab
    $MainLeftSearchTabControl.SelectedTab = $Section1FileSearchTab
    $InformationTabControl.SelectedTab = $Section3ResultsTab
    try {
#       [System.Reflection.Assembly]::LoadWithPartialName("System .Windows.Forms") | Out-Null
        $RetrieveFileOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{
            Title            = "Select A File Search CSV File"
            InitialDirectory = "$(if (Test-Path $($script:CollectionSavedDirectoryTextBox.Text)) {$($script:CollectionSavedDirectoryTextBox.Text)} else {$CollectedDataDirectory})"
            Filter           = "CSV (*.csv)|*.csv|All files (*.*)|*.*"
            ShowHelp         = $true
        }
        $RetrieveFileOpenFileDialog.ShowDialog() | Out-Null
        $DownloadFilesFrom = Import-Csv $($RetrieveFileOpenFileDialog.filename)
        $StatuListBox.Items.Clear()
        $StatusListBox.Items.Add("Retrieve Files")
    }
    catch{}

    $SelectedFilesToDownload = $null
    $SelectedFilesToDownload = $DownloadFilesFrom | Select-Object ComputerName, Name, FullName, CreationTime, LastAccessTime, LastWriteTime, Length, Attributes, VersionInfo, * -ErrorAction SilentlyContinue

    Get-RemoteFile -Files $SelectedFilesToDownload

    Remove-Variable -Name SelectedFilesToDownload
}

$RetrieveFilesButtonAdd_MouseHover = {
    Show-ToolTip -Title "Retrieve Files" -Icon "Info" -Message @"
+  Use the File Search query section to search for files or obtain directory
    listings, then open the results here to be able to download multple files
    from multiple endpoints.
+  To use this feature, first query for files and select then from the following:
    - Directory Listing.csv
    - File Search.csv
+  Requires WinRM Service
"@
}

$OpenXmlResultsButtonAdd_Click = {
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    $ViewXMLResultsOpenResultsOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{
        Title            = "View Collection Results"
        InitialDirectory = $(if (Test-Path "$($script:CollectionSavedDirectoryTextBox.Text)") {$($script:CollectionSavedDirectoryTextBox.Text)} else {$CollectedDataDirectory})
        filter           = "Results (*.xml)|*.xml|XML (*.xml)|*.xml|All files (*.*)|*.*"
        #filter           = "Results (*.txt;*.csv;*.xlsx;*.xls)|*.txt;*.csv;*.xls;*.xlsx|Text (*.txt)|*.txt|CSV (*.csv)|*.csv|Excel (*.xlsx)|*.xlsx|Excel (*.xls)|*.xls|All files (*.*)|*.*"
        ShowHelp = $true
    }
    $ViewXMLResultsOpenResultsOpenFileDialog.ShowDialog()
    if ($ViewXMLResultsOpenResultsOpenFileDialog.filename) {
        $ViewXMLResultsOpenResultsOpenFileDialog.filename | Set-Variable -Name ViewImportResults
        $SavePath = Split-Path -Path $ViewXMLResultsOpenResultsOpenFileDialog.filename
        $FileName = Split-Path -Path $ViewXMLResultsOpenResultsOpenFileDialog.filename -Leaf

        if ($ViewImportResults) {
            script:Open-XmlResultsInShell -ViewImportResults $ViewImportResults -FileName $FileName -SavePath $SavePath
        }
    }
    else {
        Remove-Variable -Name ViewImportResults -Force -ErrorAction SilentlyContinue
    }

    Apply-CommonButtonSettings -Button $RetrieveFilesButton

    Apply-CommonButtonSettings -Button $OpenXmlResultsButton
    Apply-CommonButtonSettings -Button $OpenCsvResultsButton

    Apply-CommonButtonSettings -Button $AutoCreateDashboardChartButton
    Apply-CommonButtonSettings -Button $SendFilesButton
}

$OpenXmlResultsButtonAdd_MouseHover = {
    Show-ToolTip -Title "Open Data In Shell (PowerShell Terminal)" -Icon "Info" -Message @"
+ Allows you to view and manipulate the results as object data from xml files
+ The results are stored in `$Results and passed into a new PowerShell terminal
+ The 'C:\Windows\Temp\PoSh-EasyWin' dir is created, mounted as a PSDrive, and used
"@
}

$OpenCsvResultsButtonAdd_Click = {
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    $ViewCSVResultsOpenResultsOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{
        Title            = "Open CSV Data"
        InitialDirectory = "$(if (Test-Path $($script:CollectionSavedDirectoryTextBox.Text)) {$($script:CollectionSavedDirectoryTextBox.Text)} else {$CollectedDataDirectory})"
        filter           = "Results (*.txt;*.csv;*.xlsx;*.xls)|*.txt;*.csv;*.xls;*.xlsx|Text (*.txt)|*.txt|CSV (*.csv)|*.csv|Excel (*.xlsx)|*.xlsx|Excel (*.xls)|*.xls|All files (*.*)|*.*"
        ShowHelp = $true
    }
    $ViewCSVResultsOpenResultsOpenFileDialog.ShowDialog()
    Import-Csv $($ViewCSVResultsOpenResultsOpenFileDialog.filename) | Out-GridView -Title "$($ViewCSVResultsOpenResultsOpenFileDialog.filename)" -OutputMode Multiple | Set-Variable -Name ViewImportResults

    if ($ViewImportResults) {
        $OpNotesListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) View CSV File:  $($ViewCSVResultsOpenResultsOpenFileDialog.filename)")
        Add-Content -Path $OpNotesWriteOnlyFile -Value ("$($(Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) View CSV File:  $($ViewCSVResultsOpenResultsOpenFileDialog.filename)") -Force
        foreach ($Selection in $ViewImportResults) {
            $OpNotesListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  $($($Selection -replace '@{','' -replace '}','') -replace '@{','' -replace '}','')")
            Add-Content -Path $OpNotesWriteOnlyFile -Value ("$($(Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  $($Selection -replace '@{','' -replace '}','')") -Force
        }
    }
    Save-OpNotes

    Apply-CommonButtonSettings -Button $RetrieveFilesButton
    Apply-CommonButtonSettings -Button $OpenXmlResultsButton
    Apply-CommonButtonSettings -Button $OpenCsvResultsButton
    Apply-CommonButtonSettings -Button $AutoCreateDashboardChartButton
    Apply-CommonButtonSettings -Button $SendFilesButton
}

$OpenCsvResultsButtonAdd_MouseHover = {
    Show-ToolTip -Title "View Results" -Icon "Info" -Message @"
+  Utilizes Out-GridView to view the results.
+  Out-GridView is native to PowerShell, lightweight, and fast.
+  Results can be easily filtered with conditional statements.
+  Collected data from is primarily saved as CSVs, so they can
    be opened with Excel or similar products.
+  Multiple lines can be selected and added to OpNotes.
    The selection can be contiguous by using the Shift key
    and/or be separate using the Ctrl key, the press OK.
"@
}

$DirectoryUpdateButtonAdd_MouseHover = {
    Show-ToolTip -Title "New Timestamp" -Icon "Info" -Message @"
+  Provides a new timestamp name for the directory files are saved.
+  The timestamp is automatically renewed upon launch of PoSh-EasyWin.
+  Collections are saved to a 'Collected Data' directory that is created
    automatically where the PoSh-EasyWin script is executed from.
+  The directory's timestamp does not auto-renew after data is collected,
    you have to manually do so. This allows you to easily run multiple
    collections and keep this co-located.
+  The full directory path may also be manually modified to contain any
    number or characters that are permitted within NTFS. This allows
    data to be saved to uniquely named or previous directories created.
"@
}


$DirectoryOpenButtonAdd_Click = {
    # Invoke-Item -Path "$($script:CollectionSavedDirectoryTextBox.Text)"
    if ($SaveResultsToFileShareCheckbox.Checked) {
        if (Test-Path $($script:CollectionSavedDirectoryTextBox.Text)) {
            # Invoke-Item -Path "$($script:CollectionSavedDirectoryTextBox.Text)"
            # Start-Process PowerShell.exe -ArgumentList "-NoExit & Set-Location '$($script:CollectionSavedDirectoryTextBox.Text)'"
            $Command = @"
            Start-Process 'PowerShell' -ArgumentList '-NoExit',
            '-ExecutionPolicy Bypass',
                { Write-Host '================================================================================' -ForegroundColor Red ; },
                { Write-Host ' To view the SMB File Share natively within Windows Explorer, you need' ; },
                { Write-Host ' to manually map the network drive letter ' -ForegroundColor White -NoNewline ; },
                { Write-Host '$($script:SmbShareDriveLetter): ' -ForegroundColor Cyan -NoNewline ; },
                { Write-Host 'to folder ' -ForegroundColor White -NoNewline ; },
                { Write-Host '\\$script:SMBServer\$script:FileShareName' -ForegroundColor Cyan ; },
                { Write-Host '' ; },
                { Write-Host ' If the Network Drive is mapped, you can open the drive with the following:' -ForegroundColor White ; },
                { Write-Host ' PS> ' -ForegroundColor White -NoNewLine ; },
                { Write-Host ' Invoke-Item "$($script:CollectionSavedDirectoryTextBox.Text)"' -ForegroundColor Cyan ; },
                { Write-Host ' PS> ' -ForegroundColor White -NoNewLine ; },
                { Write-Host ' Invoke-Item .' -ForegroundColor Cyan ; },
                { Write-Host ' PS> ' -ForegroundColor White -NoNewLine ; },
                { Write-Host ' ii .' -ForegroundColor Cyan ; },
                { Write-Host '================================================================================' -ForegroundColor Red ; },
                { Set-Location '"$($script:CollectionSavedDirectoryTextBox.Text)"' ; },
                { Write-Host '' ; }
"@
            Invoke-Expression $Command
            
        }
        elseif (Test-Path "$($script:SmbShareDriveLetter):") {
            # Invoke-Item -Path "$($script:SmbShareDriveLetter):"
            # Start-Process PowerShell.exe -ArgumentList "-NoExit & Set-Location '$($script:SmbShareDriveLetter):'"
            $Command = @"
            Start-Process 'PowerShell' -ArgumentList '-NoExit',
            '-ExecutionPolicy Bypass',
                { Write-Host '================================================================================' -ForegroundColor Red ; },
                { Write-Host ' To view the SMB File Share natively within Windows Explorer, you need' ; },
                { Write-Host ' to manually map the network drive letter ' -ForegroundColor White -NoNewline ; },
                { Write-Host '$($script:SmbShareDriveLetter): ' -ForegroundColor Cyan -NoNewline ; },
                { Write-Host 'to folder ' -ForegroundColor White -NoNewline ; },
                { Write-Host '\\$script:SMBServer\$script:FileShareName' -ForegroundColor Cyan ; },
                { Write-Host '' ; },
                { Write-Host ' If the Network Drive is mapped, you can open the drive with the following:' -ForegroundColor White ; },
                { Write-Host ' PS> ' -ForegroundColor White -NoNewLine ; },
                { Write-Host ' Invoke-Item "$($script:SmbShareDriveLetter):"' -ForegroundColor Cyan ; },
                { Write-Host ' PS> ' -ForegroundColor White -NoNewLine ; },
                { Write-Host ' Invoke-Item .' -ForegroundColor Cyan ; },
                { Write-Host ' PS> ' -ForegroundColor White -NoNewLine ; },
                { Write-Host ' ii .' -ForegroundColor Cyan ; },
                { Write-Host '================================================================================' -ForegroundColor Red ; },
                { Set-Location "$($script:SmbShareDriveLetter):" ; },
                { Write-Host '' ; }
"@
            Invoke-Expression $Command

        }
        else {
            $SaveResultsToFileShareCheckbox.Checked = $false
            [System.Windows.Forms.MessageBox]::Show("There is not share drive connected.","PoSh-EasyWIn - Open Directory",'Ok',"Warning")
        }
    }
    else {
        if (Test-Path $($script:CollectionSavedDirectoryTextBox.Text)) {
            Invoke-Item -Path $script:CollectionSavedDirectoryTextBox.Text
        }
        elseif (Test-Path $CollectedDataDirectory) {
            Invoke-Item -Path $CollectedDataDirectory
        }
        else {
            Invoke-Item -Path $PoShHome
        }
    }
}

$DirectoryOpenButtonAdd_MouseHover = {
    Show-ToolTip -Title "Open Results" -Icon "Info" -Message @"
+  Opens the directory where the collected data is saved.
+  The 'Collected Data' parent directory is opened by default.
+  After collecting data, the directory opened is changed to that
    of where the data is saved - normally the timestamp folder.
+  From here, you can easily navigate the rest of the directory.
"@
}


$AutoCreateDashboardChartButtonAdd_Click = {
    # https://bytecookie.wordpress.com/2012/04/13/tutorial-powershell-and-microsoft-chart-controls-or-how-to-spice-up-your-reports/
    # https://blogs.msdn.microsoft.com/alexgor/2009/03/27/aligning-multiple-series-with-categorical-values/
    # Auto Charts Select Property Function

    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

    $AutoChartsSelectionForm = New-Object System.Windows.Forms.Form -Property @{
        Name          = "Dashboard Charts"
        Text          = "Dashboard Charts"
        Size      = @{ Width  = $FormScale * 327
                       Height = $FormScale * 155 }
        StartPosition = "CenterScreen"
        Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$script:EasyWinIcon")
        #ControlBox    = $true
        Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoScroll    = $True
        #FormBorderStyle =  "fixed3d"
        Add_Closing = { $This.dispose() }
    }

    $AutoChartsMainLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Generates a dashboard with multiple charts "
        Location = @{ X = $FormScale * 10
                      Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 300
                      Height = $FormScale * 25 }
        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $AutoChartsSelectionForm.Controls.Add($AutoChartsMainLabel)


    $AutoChartSelectChartComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Text      = "Select A Chart"
        Location  = @{ X = $FormScale * 10
                     Y = $AutoChartsMainLabel.Location.y + $AutoChartsMainLabel.Size.Height + $($FormScale * 5) }
        Size      = @{ Width  = $FormScale * 292
                       Height = $FormScale * 25 }
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = 'Red'
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
    }
    $AutoChartSelectChartComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { Launch-AutoChartsViewCharts }})
    $AutoChartSelectChartComboBox.Add_Click({
        if ($AutoChartSelectChartComboBox.text -eq 'Select A Chart') { $AutoChartSelectChartComboBox.ForeColor = 'Red' }
        else { $AutoChartSelectChartComboBox.ForeColor = 'Black' }
    })
    $AutoChartsAvailable = @(
        "Dashboard Overview",
        "Active Directory Computers, Users, and Groups",
        "Threat Hunting with Deep Blue"
    )
    ForEach ($Item in $AutoChartsAvailable) { [void] $AutoChartSelectChartComboBox.Items.Add($Item) }
    $AutoChartsSelectionForm.Controls.Add($AutoChartSelectChartComboBox)


    $script:AutoChartsProgressBar = New-Object System.Windows.Forms.ProgressBar -Property @{
        Style    = "Continuous"
        #Maximum = 10
        Minimum  = 0
        Location = @{ X = $FormScale * 10
                      Y = $AutoChartSelectChartComboBox.Location.y + $AutoChartSelectChartComboBox.Size.Height + 10 }
        Size     = @{ Width  = $FormScale * 290
                      Height = $FormScale * 10 }
        Value   = 0
    }
    $AutoChartsSelectionForm.Controls.Add($script:AutoChartsProgressBar)


    $AutoChartsExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "View Dashboard"
        Location = @{ X = $AutoChartsProgressBar.Location.X
                      Y = $AutoChartsProgressBar.Location.y + $AutoChartsProgressBar.Size.Height + $($FormScale * 5) }
        Size     = @{ Width  = $AutoChartsProgressBar.Size.Width
                      Height = $FormScale * 22 }
    }
    Apply-CommonButtonSettings -Button $AutoChartsExecuteButton
    $AutoChartsExecuteButton.Add_Click({
        if ($AutoChartSelectChartComboBox.text -eq 'Select A Chart') { $AutoChartSelectChartComboBox.ForeColor = 'Red' }
        else { $AutoChartSelectChartComboBox.ForeColor = 'Black' }
        Launch-AutoChartsViewCharts
    })
    function Launch-AutoChartsViewCharts {
        $AnchorAll = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right -bor
            [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left
        $script:AutoChartsForm = New-Object Windows.Forms.Form -Property @{
            Location = @{ X = $FormScale * 5
                          Y = $FormScale * 5 }
            Size     = @{ Width  = $PoShEasyWin.Size.Width    #1241
                          Height = $PoShEasyWin.Size.Height } #638
            StartPosition = "CenterScreen"
            Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$script:EasyWinIcon")
            Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            Add_Closing = { $This.dispose() }
        }

        # The TabControl controls the tabs within it
        $AutoChartsTabControl = New-Object System.Windows.Forms.TabControl -Property @{
            Name     = "Auto Charts"
            Text     = "Auto Charts"
            Location = @{ X = $FormScale * 5
                          Y = $FormScale * 5 }
            Size     = @{ Width  = $PoShEasyWin.Size.Width - $($FormScale * 25)
                          Height = $PoShEasyWin.Size.Height - $($FormScale * 50) }
            Appearance = [System.Windows.Forms.TabAppearance]::Buttons    
            Hottrack   = $true
            Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,2,1)
        }
        $AutoChartsTabControl.ShowToolTips  = $True
        $AutoChartsTabControl.SelectedIndex = 0
        $AutoChartsTabControl.Anchor        = $AnchorAll
        $script:AutoChartsForm.Controls.Add($AutoChartsTabControl)


        # Dashboard with multiple charts
        if ($AutoChartSelectChartComboBox.SelectedItem -eq "Dashboard Overview") {
            . "$Dependencies\Code\Charts\DashboardChart_Hunt.ps1"
            . "$Dependencies\Code\Charts\DashboardChart_Processes.ps1"
            # . "$Dependencies\Code\Charts\DashboardChart_Services.ps1"
            # . "$Dependencies\Code\Charts\DashboardChart_NetworkConnections.ps1"
            # . "$Dependencies\Code\Charts\DashboardChart_NetworkInterfaces.ps1"
            # . "$Dependencies\Code\Charts\DashboardChart_LogonActivity.ps1"
            # . "$Dependencies\Code\Charts\DashboardChart_SecurityPatches.ps1"
            # . "$Dependencies\Code\Charts\DashboardChart_SmbShare.ps1"
            # . "$Dependencies\Code\Charts\DashboardChart_Software.ps1"
            # . "$Dependencies\Code\Charts\DashboardChart_Startups.ps1"
            
            [System.Windows.Forms.MessageBox]::Show("These charts are populated with data from previous queries. If some of the charts are outdated or don't contain data, try running the associated queries. There is a command group with all the applicable queries needs for your convienience.","PoSh-EasyWin",'Ok',"Info")
            $script:AutoChartsForm.Add_Shown({$script:AutoChartsForm.Activate()})
            [void]$script:AutoChartsForm.ShowDialog()
        }
        elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Active Directory Computers, Users, and Groups") {
            . "$Dependencies\Code\Charts\DashboardChart_ActiveDirectoryComputers.ps1"
            . "$Dependencies\Code\Charts\DashboardChart_ActiveDirectoryUserAccounts.ps1"
            . "$Dependencies\Code\Charts\DashboardChart_ActiveDirectoryGroups.ps1"
            
            $script:AutoChartsForm.Add_Shown({$script:AutoChartsForm.Activate()})
            [void]$script:AutoChartsForm.ShowDialog()
        }
        elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Threat Hunting with Deep Blue") {
            . "$Dependencies\Code\Charts\DashboardChart_DeepBlue.ps1"
            $script:AutoChartsForm.Add_Shown({$script:AutoChartsForm.Activate()})
            [void]$script:AutoChartsForm.ShowDialog()
        }
        # Garbage Collection to free up memory
        [System.GC]::Collect()
    }
    $AutoChartsSelectionForm.Controls.Add($AutoChartsExecuteButton)
    [void] $AutoChartsSelectionForm.ShowDialog()

    Apply-CommonButtonSettings -Button $OpenXmlResultsButton
    Apply-CommonButtonSettings -Button $OpenCsvResultsButton

    Apply-CommonButtonSettings -Button $AutoCreateDashboardChartButton
    Apply-CommonButtonSettings -Button $SendFilesButton
}

$AutoCreateDashboardChartButtonAdd_MouseHover = {
    Show-ToolTip -Title "Dashboard Charts" -Icon "Info" -Message @"
+  Utilizes PowerShell (v3) charts to visualize data.
+  These charts are auto created from pre-selected CSV files and fields.
+  The dashboard consists of multiple charts from the same CSV file and
    are designed for easy analysis of data to identify outliers.
+  Each chart can be modified and an image can be saved.
"@
}

$AutoCreateMultiSeriesChartButtonAdd_Click = {
    # https://bytecookie.wordpress.com/2012/04/13/tutorial-powershell-and-microsoft-chart-controls-or-how-to-spice-up-your-reports/
    # https://blogs.msdn.microsoft.com/alexgor/2009/03/27/aligning-multiple-series-with-categorical-values/
    # Auto Charts Select Property Function

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    

    $AutoChartsSelectionForm = New-Object System.Windows.Forms.Form -Property @{
        width         = $FormScale * 327
        height        = $FormScale * 205
        StartPosition = "CenterScreen"
        Text          = "Multi-Series Chart"
        Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$script:EasyWinIcon")
        ControlBox    = $true
        Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoScroll    = $True
        Add_Closing = { $This.dispose() }
    }
                $AutoChartsMainLabel = New-Object System.Windows.Forms.Label -Property @{
                    Text     = "Create A Multi-Series Chart From Past Collected Data"
                    Location = @{ X = $FormScale * 10
                                Y = $FormScale * 10 }
                    Size     = @{ Width  = $FormScale * 300
                                Height = $FormScale * 25 }
                    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                }
                $AutoChartsSelectionForm.Controls.Add($AutoChartsMainLabel)


                $AutoChartSelectChartComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
                    Text      = "Select A Chart"
                    Location  = @{ X = $FormScale * 10
                                Y = $AutoChartsMainLabel.Location.y + $AutoChartsMainLabel.Size.Height + $($FormScale * 5) }
                    Size      = @{ Width  = $FormScale * 292
                                Height = $FormScale * 25 }
                    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                    ForeColor = 'Red'
                    AutoCompleteSource = "ListItems"
                    AutoCompleteMode   = "SuggestAppend"
                }
                $AutoChartSelectChartComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { Launch-AutoChartsViewCharts }})
                $AutoChartSelectChartComboBox.Add_Click({
                    if ($AutoChartSelectChartComboBox.text -eq 'Select A Chart') { $AutoChartSelectChartComboBox.ForeColor = 'Red' }
                    else { $AutoChartSelectChartComboBox.ForeColor = 'Black' }
                })
                $AutoChartsAvailable = @(
                    "Disk Drives by Model",
                    "Disk Drive Models per Endpoint",
                    "Interface Alias",
                    "Interfaces with IPs per Endpoint",
                    "Local User Accounts",
                    "Local Accounts per Endpoint",
                    "Mapped Drives by Device ID",
                    "Mapped Drive Device IDs per Endpoint",
                    "Mapped Drives by Volume Name",
                    "Mapped Drive Volume Names per Endpoint",
                    "Process Names",
                    "Process Paths",
                    "Process Company",
                    "Process Product",
                    "Processes per Endpoint",
                    "Process MD5 Hashes",
                    "Process Signer Certificate",
                    "Process Signer Company",
                    "Security Patches HotFixes",
                    "Security Patches Service Packs In Effect",
                    "Security Patches per Endpoint",
                    "Services Names",
                    "Services Paths",
                    "Services per Endpoint",
                    "Share Names",
                    "Share Paths",
                    "Shares per Endpoint",
                    "Software Installed by Names",
                    "Software Installed by Vendors",
                    "Software Installed per Endpoint",
                    "Startup Names",
                    "Startup Commands",
                    "Startups per Endpoint"
                    )
                ForEach ($Item in $AutoChartsAvailable) { [void] $AutoChartSelectChartComboBox.Items.Add($Item) }
                $AutoChartsSelectionForm.Controls.Add($AutoChartSelectChartComboBox)


                $script:AutoChartsProgressBar = New-Object System.Windows.Forms.ProgressBar -Property @{
                    Style    = "Continuous"
                    #Maximum = 10
                    Minimum  = 0
                    Location = @{ X = $FormScale * 10
                                Y = $AutoChartSelectChartComboBox.Location.y + $AutoChartSelectChartComboBox.Size.Height + $($FormScale * 10) }
                    Size     = @{ Width  = $FormScale * 290
                                Height = $FormScale * 10 }
                    Value   = 0
                }
                $AutoChartsSelectionForm.Controls.Add($script:AutoChartsProgressBar)


                # Create a group that will contain your radio buttons
                $AutoChartsCreateChartsFromGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
                    text     = "Filter Results Using:"
                    Location = @{ X = $FormScale * 10
                                Y = $script:AutoChartsProgressBar.Location.y + $script:AutoChartsProgressBar.Size.Height + $($FormScale * 8) }
                    Size     = @{ Width  = $FormScale * 185
                                Height = $FormScale * 65 }
                    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                }
                    ### View Chart WMI Results Checkbox
                    $AutoChartsWmiCollectionsCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
                        Text     = "WMI Collections"
                        Location = @{ X = $FormScale * 10
                                    Y = $FormScale * 15 }
                        Size     = @{ Width  = $FormScale * 164
                                    Height = $FormScale * 25 }
                        Checked  = $false
                        Enabled  = $true
                        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                    }
                    $AutoChartsWmiCollectionsCheckBox.Add_Click({ $AutoChartsPoShCollectionsCheckBox.Checked = $false })

                    ### View Chart WinRM Results Checkbox
                    $AutoChartsPoShCollectionsCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
                        Location = @{ X = $FormScale * 10
                                    Y = $FormScale * 38 }
                        Size     = @{ Width  = $FormScale * 165
                                    Height = $FormScale * 25 }
                        Checked  = $false
                        Enabled  = $true
                        Text     = "PoSh Collections"
                        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                    }
                    $AutoChartsPoShCollectionsCheckBox.Add_Click({ $AutoChartsWmiCollectionsCheckBox.Checked  = $false })

                    $AutoChartsCreateChartsFromGroupBox.Controls.AddRange(@($AutoChartsWmiCollectionsCheckBox,$AutoChartsPoShCollectionsCheckBox))
                $AutoChartsSelectionForm.Controls.Add($AutoChartsCreateChartsFromGroupBox)


                $AutoChartsExecuteButton = New-Object System.Windows.Forms.Button -Property @{
                    Text     = "View Chart"
                    Location = @{ X = $AutoChartsCreateChartsFromGroupBox.Location.X + $AutoChartsCreateChartsFromGroupBox.Size.Width + $($FormScale * 5)
                                Y = $AutoChartsCreateChartsFromGroupBox.Location.y + $($FormScale * 5) }
                    Size     = @{ Width  = $FormScale * 101
                                Height = $FormScale * 59 }
                }
                Apply-CommonButtonSettings -Button $AutoChartsExecuteButton
                $AutoChartsExecuteButton.Add_Click({
                    if ($AutoChartSelectChartComboBox.text -eq 'Select A Chart') { $AutoChartSelectChartComboBox.ForeColor = 'Red' }
                    else { $AutoChartSelectChartComboBox.ForeColor = 'Black' }
                    Launch-AutoChartsViewCharts
                })
                function Launch-AutoChartsViewCharts {
                    ## Auto Create Charts Form
                    $AnchorAll = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right -bor
                        [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left
                    $script:AutoChartsForm               = New-Object Windows.Forms.Form
                    $script:AutoChartsForm.Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$script:EasyWinIcon")
                    $script:AutoChartsForm.Width         = $PoShEasyWin.Size.Width  #1160
                    $script:AutoChartsForm.Height        = $PoShEasyWin.Size.Height #638
                    $script:AutoChartsForm.StartPosition = "CenterScreen"
                    $script:AutoChartsForm.Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 18),0,0,0)
                    $script:AutoChartsForm.Add_Closing = { $This.dispose() }


                    ## Auto Create Charts TabControl
                    # The TabControl controls the tabs within it
                    $AutoChartsTabControl               = New-Object System.Windows.Forms.TabControl
                    $AutoChartsTabControl.Name          = "Auto Charts"
                    $AutoChartsTabControl.Text          = "Auto Charts"
                    $AutoChartsTabControl.Location      = New-Object System.Drawing.Point($($FormScale * 5),$($FormScale * 5))
                    $AutoChartsTabControl.Size          = New-Object System.Drawing.Size($($FormScale * 1535),$($FormScale * 590))
                    $AutoChartsTabControl.ShowToolTips  = $True
                    $AutoChartsTabControl.SelectedIndex = 0
                    $AutoChartsTabControl.Anchor        = $AnchorAll
                    $AutoChartsTabControl.Appearance = [System.Windows.Forms.TabAppearance]::Buttons
                    $AutoChartsTabControl.Hottrack      = $true
                    $AutoChartsTabControl.Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,2,1)
                    $script:AutoChartsForm.Controls.Add($AutoChartsTabControl)

                    # Accounts
                    if     ($AutoChartSelectChartComboBox.SelectedItem -eq "Local User Accounts") { Generate-AutoChartsCommand -QueryName "Local Users" -QueryTabName "Local User Accounts" -PropertyX "Name" -PropertyY "PSComputerName" }
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Local Accounts per Endpoint") { Generate-AutoChartsCommand -QueryName "Local Users" -QueryTabName "Local Accounts per Endpoint" -PropertyX "PSComputerName" -PropertyY "Name" }

                    # Interface / Network Settings
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Interface Alias") { Generate-AutoChartsCommand -QueryName "Network Settings" -QueryTabName "Interface Alias" -PropertyX "InterfaceAlias" -PropertyY "PSComputerName" }
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Interfaces with IPs per Endpoint") { Generate-AutoChartsCommand -QueryName "Network Settings" -QueryTabName "Interfaces with IPs per Endpoint" -PropertyX "PSComputerName" -PropertyY "IPAddress" }

                    # Mapped Drives
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Disk Drives by Model") { Generate-AutoChartsCommand -QueryName "Disk - Physical Info" -QueryTabName "Disk Drives by Model" -PropertyX "PSComputerName" -PropertyY "Model" }
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Disk Drive Models per Endpoint") { Generate-AutoChartsCommand -QueryName "Disk - Physical Info" -QueryTabName "Disk Drive Models per Endpoint" -PropertyX "Model" -PropertyY "PSComputerName" }
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Mapped Drives by Device ID") { Generate-AutoChartsCommand -QueryName "LogicalDisk" -QueryTabName "Mapped Drives by Device ID" -PropertyX "PSComputerName" -PropertyY "DeviceID" }
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Mapped Drive Device IDs per Endpoint") { Generate-AutoChartsCommand -QueryName "LogicalDisk" -QueryTabName "Mapped Drive Device IDs per Endpoint" -PropertyX "DeviceID" -PropertyY "PSComputerName" }
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Mapped Drives by Volume Name") { Generate-AutoChartsCommand -QueryName "LogicalDisk" -QueryTabName "Mapped Drives by Volume Name" -PropertyX "PSComputerName" -PropertyY "VolumeName" }
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Mapped Drive Volume Names per Endpoint") { Generate-AutoChartsCommand -QueryName "LogicalDisk" -QueryTabName "Mapped Drive Volume Names per Endpoint" -PropertyX "VolumeName" -PropertyY "PSComputerName" }

                    # Processes
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Process Names") { Generate-AutoChartsCommand -QueryName "Processes" -QueryTabName "Process Names" -PropertyX "Name" -PropertyY "PSComputerName"}
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Process Paths") { Generate-AutoChartsCommand -QueryName "Processes" -QueryTabName "Process Paths" -PropertyX "Path" -PropertyY "PSComputerName" }
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Process Company") { Generate-AutoChartsCommand -QueryName "Processes" -QueryTabName "Process Company" -PropertyX "Company" -PropertyY "PSComputerName" }
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Process Product") { Generate-AutoChartsCommand -QueryName "Processes" -QueryTabName "Process Product" -PropertyX "Product" -PropertyY "PSComputerName" }
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Processes per Endpoint") { Generate-AutoChartsCommand -QueryName "Processes" -QueryTabName "Processes per Endpoint" -PropertyX "PSComputerName" -PropertyY "ProcessID" }

                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Process MD5 Hashes") { Generate-AutoChartsCommand -QueryName "Processes" -QueryTabName "Process MD5 Hashes" -PropertyX "MD5Hash" -PropertyY "PSComputerName" }
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Process Signer Certificate") { Generate-AutoChartsCommand -QueryName "Processes" -QueryTabName "Process Signer Certificate" -PropertyX "SignerCertificate" -PropertyY "PSComputerName" }
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Process Signer Company") { Generate-AutoChartsCommand -QueryName "Processes" -QueryTabName "Process Signer Company" -PropertyX "SignerCompany" -PropertyY "PSComputerName" }

                    # Services
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Services Names") { Generate-AutoChartsCommand -QueryName "Services" -QueryTabName "Running Service Names" -PropertyX "Name"     -PropertyY "PSComputerName" }
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Services Paths") { Generate-AutoChartsCommand -QueryName "Services" -QueryTabName "Running Service Paths" -PropertyX "PathName" -PropertyY "PSComputerName" }
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Services per Endpoint") { Generate-AutoChartsCommand -QueryName "Services" -QueryTabName "Running Services per Endpoint" -PropertyX "PSComputerName" -PropertyY "Name" }

                    # Security Patches
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Security Patches HotFixes") { Generate-AutoChartsCommand -QueryName "Security Patches" -QueryTabName "Security Patches Hotfix"    -PropertyX "HotFixID" -PropertyY "PSComputerName" }
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Security Patches Service Packs In Effect") { Generate-AutoChartsCommand -QueryName "Security Patches" -QueryTabName "Service Packs In Effect" -PropertyX "ServicePackInEffect" -PropertyY "PSComputerName" }
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Security Patches per Endpoint") { Generate-AutoChartsCommand -QueryName "Security Patches" -QueryTabName "Security Patches per Endpoint"   -PropertyX "PSComputerName" -PropertyY "HotFixID" }

                    # Shares
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Share Names") { Generate-AutoChartsCommand -QueryName "Shares" -QueryTabName "Share Names" -PropertyX "Name" -PropertyY "PSComputerName" }
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Share Paths") { Generate-AutoChartsCommand -QueryName "Shares" -QueryTabName "Share Paths" -PropertyX "Path" -PropertyY "PSComputerName" }
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Shares per Endpoint") { Generate-AutoChartsCommand -QueryName "Shares" -QueryTabName "Shares per Endpoint" -PropertyX "PSComputerName" -PropertyY "Name" }

                    # Software Installed
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Software Installed by Names") { Generate-AutoChartsCommand -QueryName "Software Installed" -QueryTabName "Software Installed by Names" -PropertyX "Name" -PropertyY "PSComputerName" }
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Software Installed by Vendors") { Generate-AutoChartsCommand -QueryName "Software Installed" -QueryTabName "Software Installed by Vendors" -PropertyX "Vendor" -PropertyY "PSComputerName" }
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Software Installed per Endpoint") { Generate-AutoChartsCommand -QueryName "Software Installed" -QueryTabName "Software Installed per Endpoint" -PropertyX "PSComputerName" -PropertyY "Name" }

                    # Startup / Autoruns
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Startup Names") { Generate-AutoChartsCommand -QueryName "Startup Commands" -QueryTabName "Startup Names" -PropertyX "Name" -PropertyY "PSComputerName" }
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Startup Commands") { Generate-AutoChartsCommand -QueryName "Startup Commands" -QueryTabName "Startup Commands" -PropertyX "Command" -PropertyY "PSComputerName" }
                    elseif ($AutoChartSelectChartComboBox.SelectedItem -eq "Startups per Endpoint") { Generate-AutoChartsCommand -QueryName "Startup Commands" -QueryTabName "Startups per Endpoint" -PropertyX "PSComputerName" -PropertyY "Name" }
                }
                $AutoChartsSelectionForm.Controls.Add($AutoChartsExecuteButton)
    [void] $AutoChartsSelectionForm.ShowDialog()

    Apply-CommonButtonSettings -Button $OpenXmlResultsButton
    Apply-CommonButtonSettings -Button $OpenCsvResultsButton

    Apply-CommonButtonSettings -Button $AutoCreateDashboardChartButton
    Apply-CommonButtonSettings -Button $SendFilesButton
}





####################################################################################################
# WinForms 
####################################################################################################

$MainCenterMainTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text = "Main  "
    Name = "Main"
    Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
    ImageIndex = 0
}
$MainCenterTabControl.Controls.Add($MainCenterMainTab)


$DirectoryListLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Results Folder:"
    Left   = $FormScale * 3
    Top    = $FormScale * 4
    Width  = $FormScale * 120
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
    ForeColor = "Blue"
}
$MainCenterMainTab.Controls.Add($DirectoryListLabel)


# This shows the name of the directy that data will be currently saved to
$script:CollectionSavedDirectoryTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Name   = "Saved Directory List Box"
    Text   = $SaveLocation
    Left   = $DirectoryListLabel.Left
    Top    = $DirectoryListLabel.Top + $DirectoryListLabel.Height
    #Width  = $FormScale * 354
    Width  = $FormScale * 595
    Height = $FormScale * 22
    WordWrap   = $false
    AcceptsTab = $true
    TabStop    = $true
    Multiline  = $false
    AutoSize   = $false
    Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "FileSystem"
    AutoCompleteMode   = "SuggestAppend"
    Add_MouseHover     = $CollectionSavedDirectoryTextBoxAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($script:CollectionSavedDirectoryTextBox)


$ResultsFolderAutoTimestampCheckbox = New-Object System.Windows.Forms.Checkbox -Property @{
    Text   = "Auto Timestamp"
    Top    = $script:CollectionSavedDirectoryTextBox.Top + $script:CollectionSavedDirectoryTextBox.Height + $($FormScale * 5)
    Left   = $script:CollectionSavedDirectoryTextBox.Left + ($FormScale * 240)
    Width  = $FormScale * 115
    Height = $FormScale * 22
    Checked = $true
}
$MainCenterMainTab.Controls.Add($ResultsFolderAutoTimestampCheckbox)


$SaveResultsToFileShareCheckbox = New-Object System.Windows.Forms.Checkbox -Property @{
    Text   = "Use File Share"
    Top    = $ResultsFolderAutoTimestampCheckbox.Top
    Left   = $CollectionSavedDirectoryTextBox.Left + ($FormScale * 125)
    Width  = $FormScale * 115
    Height = $FormScale * 22
    Checked = $false
    add_click = {
        if ($This.Checked) { . "$Dependencies\Code\Main Body\Launch-FileShareConnection.ps1" }
        else { $script:CollectionSavedDirectoryTextBox.Text = $SaveLocation }
    }
}
$MainCenterMainTab.Controls.Add($SaveResultsToFileShareCheckbox)


$DirectoryUpdateButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "New Timestamp"
    Top    = $ResultsFolderAutoTimestampCheckbox.Top
    # Left   = $DirectoryOpenButton.Left + $DirectoryOpenButton.width + ($FormScale * 5)
    Left   = $ResultsFolderAutoTimestampCheckbox.Left + $ResultsFolderAutoTimestampCheckbox.Width + $($FormScale * 5)
    Width  = $FormScale * 115
    Height = $FormScale * 22
    Add_Click      = {
        $script:CollectedDataTimeStampDirectory = "$CollectedDataDirectory\$((Get-Date).ToString('yyyy-MM-dd HH.mm.ss'))"
        $script:CollectionSavedDirectoryTextBox.Text = $script:CollectedDataTimeStampDirectory    
    }
    Add_MouseHover = $DirectoryUpdateButtonAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($DirectoryUpdateButton)
Apply-CommonButtonSettings -Button $DirectoryUpdateButton


$DirectoryOpenButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Open Folder"
    Top    = $DirectoryUpdateButton.Top
    Left   = $DirectoryUpdateButton.Left + $DirectoryUpdateButton.Width + $($FormScale * 5)
    Width  = $FormScale * 115
    Height = $FormScale * 22
    Add_Click      = $DirectoryOpenButtonAdd_Click
    Add_MouseHover = $DirectoryOpenButtonAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($DirectoryOpenButton)
Apply-CommonButtonSettings -Button $DirectoryOpenButton


$ResultsSectionLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Actions and Analysis:"
    Left   = $CollectionSavedDirectoryTextBox.Left
    Top    = $DirectoryUpdateButton.Top + $DirectoryUpdateButton.Height + $($FormScale * 13)
    Width  = $FormScale * 230
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
    ForeColor = "Blue"
}
$MainCenterMainTab.Controls.Add($ResultsSectionLabel)


$SendFilesButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Send Files"
    Left   = $ResultsSectionLabel.Left
    Top    = $ResultsSectionLabel.Top + $ResultsSectionLabel.Height + ($FormScale * 1)
    Width  = $FormScale * 115
    Height = $FormScale * 22
    Add_Click = $SendFilesButtonAdd_Click
}
$MainCenterMainTab.Controls.Add($SendFilesButton)
Apply-CommonButtonSettings -Button $SendFilesButton


Update-FormProgress "$Dependencies\Code\Main Body\PSWriteHTMLButton.ps1"
. "$Dependencies\Code\Main Body\PSWriteHTMLButton.ps1"
$PSWriteHTMLButton = New-Object System.Windows.Forms.Button -Property @{
    Left   = $SendFilesButton.Left + $SendFilesButton.Width + $($FormScale * 5)
    Top    = $SendFilesButton.Top
    Width  = $FormScale * 115
    Height = $FormScale * 22
    Add_Click      = $PSWriteHTMLButtonAdd_Click
    Add_MouseHover = $PSWriteHTMLButtonAdd_MouseHover
    Enabled = $false
}
$MainCenterMainTab.Controls.Add($PSWriteHTMLButton)
Apply-CommonButtonSettings -Button $PSWriteHTMLButton
if ((Test-Path -Path "$Dependencies\Modules\PSWriteHTML") -and (Get-Content "$PoShHome\Settings\PSWriteHTML Module Install.txt") -match 'Yes') {
    $PSWriteHTMLButton.enabled = $true
    $PSWriteHTMLButton.Text    = "Graph Data [Beta]"
}

# This is placed here as the code is used with the "Open Data In Shell" button in the main form as well as within the dashboards
Update-FormProgress "$Dependencies\Code\Main Body\script:Open-XmlResultsInShell.ps1"
. "$Dependencies\Code\Main Body\script:Open-XmlResultsInShell.ps1"

# Used to populate the dashboard choices form
$AutoCreateDashboardChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Dashboard Charts"
    Left   = $PSWriteHTMLButton.Left + $PSWriteHTMLButton.Width + $($FormScale * 5)
    Top    = $PSWriteHTMLButton.Top
    Width  = $FormScale * 115
    Height = $FormScale * 22
    Add_Click      = $AutoCreateDashboardChartButtonAdd_Click
    Add_MouseHover = $AutoCreateDashboardChartButtonAdd_MouseHover
    Enabled        = $true
}
$MainCenterMainTab.Controls.Add($AutoCreateDashboardChartButton)
Apply-CommonButtonSettings -Button $AutoCreateDashboardChartButton


$TeamChatPopoutClientButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Start Chat Client"
    Left   = $AutoCreateDashboardChartButton.Left + $AutoCreateDashboardChartButton.Width + $($FormScale * 5)
    Top    = $AutoCreateDashboardChartButton.Top
    Width  = $FormScale * 115
    Height = $FormScale * 22
    Add_Click = {
        if (Verify-Action -Title "Team Chat Client" -Question "Do you want to launch the team chat client?`n`nThe chat messages are passed along in plain text.`nThis is currently designed for internal use only.`nThe server is hosted on port TCP/15600.") {
            . "$Dependencies\Code\PoSh-Chat\Start-PoShChatClient.ps1"
        }
    }
}
$MainCenterMainTab.Controls.Add($TeamChatPopoutClientButton)
Apply-CommonButtonSettings -Button $TeamChatPopoutClientButton


$PowerShellTerminalButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "PowerShell"
    Left   = $TeamChatPopoutClientButton.Left + $TeamChatPopoutClientButton.Width + $($FormScale * 5)
    Top    = $TeamChatPopoutClientButton.Top
    Width  = $FormScale * 115
    Height = $FormScale * 22
    Add_Click = {
        if (Verify-Action -Title "Team Chat" -Question "Do you want to launch a PowerShell terminal?") {
            Start-Process PowerShell.exe
        }
    }
}
$MainCenterMainTab.Controls.Add($PowerShellTerminalButton)
Apply-CommonButtonSettings -Button $PowerShellTerminalButton


# batman
# Update-FormProgress "$Dependencies\Code\Charts\Generate-AutoChartsCommand.ps1"
# . "$Dependencies\Code\Charts\Generate-AutoChartsCommand.ps1"
# $AutoCreateMultiSeriesChartButton = New-Object System.Windows.Forms.Button -Property @{
#     Text   = "Multi-Charts"
#     Left   = $PowerShellTerminalButton.Left
#     Top    = $PowerShellTerminalButton.Top + $PowerShellTerminalButton.Height + ($FormScale * 1)
#     Width  = $FormScale * 115
#     Height = $FormScale * 22
#     Add_Click      = $AutoCreateMultiSeriesChartButtonAdd_Click
#     Add_MouseHover = $AutoCreateMultiSeriesChartButtonAdd_MouseHover
# }
# $MainCenterMainTab.Controls.Add($AutoCreateMultiSeriesChartButton)
# Apply-CommonButtonSettings -Button $AutoCreateMultiSeriesChartButton


Update-FormProgress "$Dependencies\Code\Main Body\Get-RemoteFile.ps1"
. "$Dependencies\Code\Main Body\Get-RemoteFile.ps1"
$RetrieveFilesButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Retrieve Files"
    Left   = $SendFilesButton.Left
    Top    = $SendFilesButton.Top + $SendFilesButton.Height + $($FormScale * 5)
    Width  = $FormScale * 115
    Height = $FormScale * 22
    Add_Click      = $RetrieveFilesButtonAdd_Click
    Add_MouseHover = $RetrieveFilesButtonAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($RetrieveFilesButton)
Apply-CommonButtonSettings -Button $RetrieveFilesButton


$OpenXmlResultsButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Open Data In Shell"
    Left   = $RetrieveFilesButton.Left + $RetrieveFilesButton.Width + $($FormScale * 5)
    Top    = $RetrieveFilesButton.Top
    Width  = $FormScale * 115
    Height = $FormScale * 22
    Add_Click      = $OpenXmlResultsButtonAdd_Click
    Add_MouseHover = $OpenXmlResultsButtonAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($OpenXmlResultsButton)
Apply-CommonButtonSettings -Button $OpenXmlResultsButton


$OpenCsvResultsButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "View CSV Results"
    Left   = $OpenXmlResultsButton.Left + $OpenXmlResultsButton.Width + $($FormScale * 5)
    Top    = $OpenXmlResultsButton.Top
    Width  = $FormScale * 115
    Height = $FormScale * 22
    Add_Click      = $OpenCsvResultsButtonAdd_Click
    Add_MouseHover = $OpenCsvResultsButtonAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($OpenCsvResultsButton)
Apply-CommonButtonSettings -Button $OpenCsvResultsButton


$TeamChatStartChatServerButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Start Chat Server"
    Left   = $OpenCsvResultsButton.Left + $OpenCsvResultsButton.Width + $($FormScale * 5)
    Top    = $OpenCsvResultsButton.Top
    Width  = $FormScale * 115
    Height = $FormScale * 22
    Add_Click = {
        if (Verify-Action -Title "Team Chat Server" -Question "Do you want to launch the team chat server?`n`nThe chat messages are passed along in plain text.`nThis is currently designed for internal use only.`nEnsure to only have one instance running to avoid issues.`nThe server is hosted on port TCP/15600.") {
            New-Item -ItemType Directory -Path "$PoShHome\Team Chat Logs\" -ErrorAction SilentlyContinue
            $Datetime = (Get-Date).ToString('yyyy-MM-dd HH.mm.ss')
            Start-Process PowerShell.exe -ArgumentList @("-NoExit & '$Dependencies\code\PoSh-Chat\Start-PoshChatServer.ps1' -EnableLogging '$PoSHHome\Team Chat Logs\team chat ($Datetime).log'")
        }
    }
}
$MainCenterMainTab.Controls.Add($TeamChatStartChatServerButton)
Apply-CommonButtonSettings -Button $TeamChatStartChatServerButton


# The Launch-ChartImageSaveFileDialog function is use by 'build charts and autocharts'
Update-FormProgress "$Dependencies\Code\Charts\Launch-ChartImageSaveFileDialog.ps1"
. "$Dependencies\Code\Charts\Launch-ChartImageSaveFileDialog.ps1"


# Increases the chart size by 4 then saves it to file
Update-FormProgress "$Dependencies\Code\Charts\Save-ChartImage.ps1"
. "$Dependencies\Code\Charts\Save-ChartImage.ps1"


$StatusLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Status:"
    Left   = $RetrieveFilesButton.Left
    Top    = $RetrieveFilesButton.Top + $RetrieveFilesButton.Height + $FormScale * 28
    Width  = $FormScale * 60
    Height = $FormScale * 20
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
}
$MainCenterMainTab.Controls.Add($StatusLabel)


$StatusListBox = New-Object System.Windows.Forms.ListBox -Property @{
    Name   = "StatusListBox"
    Left   = $StatusLabel.Left + $StatusLabel.Width
    Width  = $FormScale * 535
    Top    = $StatusLabel.Top
    Height = $FormScale * 22
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    FormattingEnabled = $True
}
$StatusListBox.Items.Add("Welcome to PoSh-EasyWin!") | Out-Null
$MainCenterMainTab.Controls.Add($StatusListBox)


$ProgressBarEndpointsLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Endpoint:"
    Left   = $StatusLabel.Left
    Top    = $StatusLabel.Top + $StatusLabel.Height
    Width  = $StatusLabel.Width
    Height = $StatusLabel.Height
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$MainCenterMainTab.Controls.Add($ProgressBarEndpointsLabel)


$script:ProgressBarEndpointsProgressBar = New-Object System.Windows.Forms.ProgressBar -Property @{
    Left   = $ProgressBarEndpointsLabel.Left + $ProgressBarEndpointsLabel.Width
    Width = $StatusListBox.Width - ($FormScale * 1)
    Top    = $ProgressBarEndpointsLabel.Top
    Height = $FormScale * 15
    Forecolor = 'LightBlue'
    BackColor = 'white'
    Style     = "Continuous" #"Marque"
    Minimum   = 0
}
$MainCenterMainTab.Controls.Add($script:ProgressBarEndpointsProgressBar)


$ProgressBarQueriesLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Task:"
    Left   = $ProgressBarEndpointsLabel.Left
    Top    = $ProgressBarEndpointsLabel.Top + $ProgressBarEndpointsLabel.Height
    Width  = $ProgressBarEndpointsLabel.Width
    Height = $ProgressBarEndpointsLabel.Height
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$MainCenterMainTab.Controls.Add($ProgressBarQueriesLabel)


$script:ProgressBarQueriesProgressBar = New-Object System.Windows.Forms.ProgressBar -Property @{
    Left = $ProgressBarQueriesLabel.Left + $ProgressBarQueriesLabel.Width
    Width = $StatusListBox.Width - ($FormScale * 1)
    Top = $ProgressBarQueriesLabel.Top
    Height = $FormScale * 15
    Forecolor = 'LightGreen'
    BackColor = 'white'
    Style     = "Continuous"
    Minimum   = 0
}
$MainCenterMainTab.Controls.Add($script:ProgressBarQueriesProgressBar)



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUIdbXEg19wvb1jJVMUmmMF5DL
# zrGgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUeYkMqxr09QZcmRwY7rNYWQVSPiAwDQYJKoZI
# hvcNAQEBBQAEggEAN6OrOMkfCJg62LP43fM2KsDjoWDvVeiT/9K4YEHkbZAEl8Rk
# njPvVVOfg3TlYCmiRe1SyQHjZfSJKqKDzuRAgnY17NQak8LPW09BeQM/SfyoPcEG
# 7AgfgrTQQ7MNxBhsdPlciApELtNVZSAPqg0C14LFd6B9PIRInHLm1c1Qpl1oBQco
# JFrzBrE61+BDfY+k+ctc6qtQbk8xUVeSVBMGULAi8AAhwDkHMsq7WZZbxmMux0SS
# XXKihpjbRi/1BRbohRAR89MCLHiOG5fm6KQ3FBPKJH/e3wHgUfoXo52kkbd7+4lx
# Bp1mQTK6SxOnqNr9QrhtjigUKG5mUEQ2J7WwWQ==
# SIG # End signature block
