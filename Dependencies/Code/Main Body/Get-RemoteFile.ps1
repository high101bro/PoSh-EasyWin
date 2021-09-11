function Get-RemoteFile {
    param(
        $Files
    )
    $FilesToDownload = $Files

    if ($FilesToDownload) {
        $DownloadSize = $FilesToDownload | Select-Object -ExpandProperty length | Measure-Object -Sum | Select-Object -ExpandProperty Sum
        if     ($DownloadSize -gt 1000000000) { $DownloadSize = "$([Math]::Round($($DownloadSize / 1gb),2)) GB" }
        elseif ($DownloadSize -gt 1000000)    { $DownloadSize = "$([Math]::Round($($DownloadSize / 1mb),2)) MB" }
        elseif ($DownloadSize -gt 1000)       { $DownloadSize = "$([Math]::Round($($DownloadSize / 1kb),2)) KB" }
        elseif ($DownloadSize -le 1000)       { $DownloadSize = "$DownloadSize Bytes" }

        $ConfirmDownload = $False
        $MessageBox = [System.Windows.Forms.MessageBox]::Show("Total data amount prior to compression and download:  $DownloadSize`n`nFiles are hashed and compressed remotely before retrieval.","PoSh-EasyWin - Retreive Files",[System.Windows.Forms.MessageBoxButtons]::OKCancel)
        switch ($MessageBox){
            "OK"     { $ConfirmDownload = $true }
            "Cancel" { $ConfirmDownload = $False }
        }
    }


    if ($FilesToDownload -and $ConfirmDownload) {
        $InformationTabControl.SelectedTab = $Section3ResultsTab

        if (Test-Path $($script:CollectionSavedDirectoryTextBox.Text)) { $RetrieveFilesSaveDirectory = $script:CollectionSavedDirectoryTextBox.Text }
        $RetrieveFilesSaveDirectory = $script:CollectionSavedDirectoryTextBox.Text

    

        $StatusListBox.Items.clear()
        $StatusListBox.Items.Add("Retrieving Files")
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Retrieving the following files from:")
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Retrieved the following files from:"

        # Function Zip-File
        # Uses the .Net Framework to zip files and directories
        . "$Dependencies\Code\Execution\Retrieve Files\Zip-File.ps1"

        # Function Create-RetrievedFileDetails
        # Creates the 'File Details.txt' fiile that is included into zipped Retrieved Files
        . "$Dependencies\Code\Execution\Retrieve Files\Create-RetrievedFileDetails.ps1"

        $FilesToDownload = $FilesToDownload | Sort-Object -Property PSComputerName
        $RetrieveFilesCurrentComputer = ''

        $script:ProgressBarEndpointsProgressBar.Maximum = ($FilesToDownload.PSComputerName | Sort-Object -Unique).count
        $script:ProgressBarEndpointsProgressBar.Value   = 0

        Foreach ($File in $FilesToDownload) {
            if ($RetrieveFilesCurrentComputer -eq '') {
                $RetrieveFilesCurrentComputer = $File.PSComputerName
                $script:ProgressBarQueriesProgressBar.Maximum = ($FilesToDownload | Where-Object {$_.PSComputerName -eq $RetrieveFilesCurrentComputer}).count
                $script:ProgressBarQueriesProgressBar.Value   = 0


                $LocalSavePath = "$RetrieveFilesSaveDirectory\Retrieved Files - $RetrieveFilesCurrentComputer"
                if ( -not (Test-Path -Path "$RetrieveFilesSaveDirectory\Retrieved Files - $RetrieveFilesCurrentComputer") ) {
                    New-Item -Type Directory -Path $LocalSavePath
                }


                if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                    if (!$script:Credential) { Create-NewCredentials }
                    $session = New-PSSession -ComputerName $RetrieveFilesCurrentComputer -Name "PoSh-EasyWin Retrieve File $RetrieveFilesCurrentComputer" -Credential $script:Credential
                    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "- New-PSSession -ComputerName $RetrieveFilesCurrentComputer -Credential $script:Credential"
                }
                else {
                    $session = New-PSSession -ComputerName $RetrieveFilesCurrentComputer -Name "PoSh-EasyWin Retrieve File $RetrieveFilesCurrentComputer"
                    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "- New-PSSession -ComputerName $RetrieveFilesCurrentComputer"
                }

                # Identified file is first compressed on the endpoint
                # If the target item is a directory, the directory will be directly compressed
                # If the target item is not a directory, it will copy the item to c:\Windows\Temp
                # Uses .Net Framework System.IO.Compression.FileSystem
                Invoke-Command -ScriptBlock ${function:Zip-File} -argumentlist @($File.FullName),"c:\Windows\Temp","Optimal" -Session $session
#                Copy-Item -Path "c:\Windows\Temp\$($File.BaseName).zip" -Destination $LocalSavePath -FromSession $session

                # File is hashed remotely on endpoint, then copied back over the network
                $RetrievedFileHashMD5 = Invoke-Command -ScriptBlock { param($File) (Get-FileHash -Algorithm md5 -Path "$($File.FullName)").Hash } -argumentlist $File -Session $session
                Copy-Item -Path "c:\Windows\Temp\$($File.BaseName).zip" -Destination "$LocalSavePath\$($File.BaseName) [MD5=$RetrievedFileHashMD5].zip" -FromSession $session

                Start-Sleep -Milliseconds 250

                # The zipped file is removed from the endpoint
                Invoke-Command -ScriptBlock {
                    param($File)
                    Remove-Item "c:\Windows\Temp\$($File.BaseName).zip"
                } -ArgumentList $File -Session $session

                # The 'File Details.txt' is created locally from the source file on the endpoint
                # This script also get other file metatadata
                # Also hashes the file with multiple algorithms
                # Gets AuthenticodeSignature information
                Create-RetrievedFileDetails -LocalSavePath $LocalSavePath -File $File

                $script:ProgressBarQueriesProgressBar.Value += 1
            }
            elseif ($RetrieveFilesCurrentComputer -eq $File.PSComputerName) {
                # no need for new session as there is already one open to the target computer

                # Reference notes above
                Invoke-Command -ScriptBlock ${function:Zip-File} -argumentlist @($File.FullName),"c:\Windows\Temp","Optimal" -Session $session
#                Copy-Item -Path "c:\Windows\Temp\$($File.BaseName).zip" -Destination $LocalSavePath -FromSession $session

                # Reference notes above
                $RetrievedFileHashMD5 = Invoke-Command -ScriptBlock { param($File) (Get-FileHash -Algorithm md5 -Path "$($File.FullName)").Hash } -argumentlist $File -Session $session
                Copy-Item -Path "c:\Windows\Temp\$($File.BaseName).zip" -Destination "$LocalSavePath\$($File.BaseName) [MD5=$RetrievedFileHashMD5].zip" -FromSession $session

                Start-Sleep -Milliseconds 250

                # Reference notes above
                Invoke-Command -ScriptBlock {
                    param($File)
                    Remove-Item "c:\Windows\Temp\$($File.BaseName).zip"
                } -ArgumentList $File -Session $session

                # Reference notes above
                Create-RetrievedFileDetails -LocalSavePath $LocalSavePath -File $File

                $script:ProgressBarQueriesProgressBar.Value += 1
            }
            elseif ($RetrieveFilesCurrentComputer -ne $File.PSComputerName) {
                Get-PSSession -Name "PoSh-EasyWin Retrieve File $RetrieveFilesCurrentComputer" | Remove-PSSession
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "   Remove-PSSession -ComputerName $RetrieveFilesCurrentComputer"

                $RetrieveFilesCurrentComputer = $File.PSComputerName
                $script:ProgressBarQueriesProgressBar.Maximum = ($FilesToDownload | Where-Object {$_.PSComputerName -eq $RetrieveFilesCurrentComputer}).count
                $script:ProgressBarQueriesProgressBar.Value   = 0

                $LocalSavePath = "$RetrieveFilesSaveDirectory\Retrieved Files - $RetrieveFilesCurrentComputer"
                if ( -not (Test-Path -Path "$RetrieveFilesSaveDirectory\Retrieved Files - $RetrieveFilesCurrentComputer") ) { New-Item -Type Directory -Path $LocalSavePath }
                $session = New-PSSession -ComputerName $RetrieveFilesCurrentComputer -Name "PoSh-EasyWin Retrieve File $RetrieveFilesCurrentComputer"
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "- New-PSSession -ComputerName $RetrieveFilesCurrentComputer"

                # Reference notes above
                Invoke-Command -ScriptBlock ${function:Zip-File} -argumentlist @($File.FullName),"c:\Windows\Temp","Optimal" -Session $session
#                Copy-Item -Path "c:\Windows\Temp\$($File.BaseName).zip" -Destination $LocalSavePath -FromSession $session

                # Reference notes above
                $RetrievedFileHashMD5 = Invoke-Command -ScriptBlock { param($File) (Get-FileHash -Algorithm md5 -Path "$($File.FullName)").Hash } -argumentlist $File -Session $session
                Copy-Item -Path "c:\Windows\Temp\$($File.BaseName).zip" -Destination "$LocalSavePath\$($File.BaseName) [MD5=$RetrievedFileHashMD5].zip" -FromSession $session

                Start-Sleep -Milliseconds 250

                # Reference notes above
                Invoke-Command -ScriptBlock {
                    param($File)
                    Remove-Item "c:\Windows\Temp\$($File.BaseName).zip"
                } -ArgumentList $File -Session $session

                # Reference notes above
                Create-RetrievedFileDetails -LocalSavePath $LocalSavePath -File $File

                $script:ProgressBarEndpointsProgressBar.Value += 1
                $script:ProgressBarQueriesProgressBar.Value += 1
                $PoShEasyWin.Refresh()
            }
            $ResultsListBox.Items.Insert(1,"- $($RetrieveFilesCurrentComputer): $($File.FullName)")
            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "   Copied: $($File.FullName)"
            $PoShEasyWin.Refresh()
        }
        $script:ProgressBarEndpointsProgressBar.Maximum = 1
        $script:ProgressBarEndpointsProgressBar.Value   = 1
        $script:ProgressBarQueriesProgressBar.Maximum   = 1
        $script:ProgressBarQueriesProgressBar.Value     = 1

        Get-PSSession -Name "PoSh-EasyWin Retrieve File $RetrieveFilesCurrentComputer" | Remove-PSSession
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "   Remove-PSSession -ComputerName $RetrieveFilesCurrentComputer"

        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Retrieved Files Saved To: $RetrieveFilesSaveDirectory"
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Retrieved Files From Endpoints Were Zipped To 'c:\Windows\Temp\' Then Removed"

        if ($script:RollCredentialsState -and $script:ComputerListProvideCredentialsCheckBox.checked) {
            Start-Sleep -Seconds 3
            Generate-NewRollingPassword
        }

        if ($FilesToDownload) { Start-Sleep -Seconds 1;  Invoke-Item -Path $RetrieveFilesSaveDirectory }
        $PoShEasyWin.Refresh()
    }

    Apply-CommonButtonSettings -Button $RetrieveFilesButton

    Apply-CommonButtonSettings -Button $OpenXmlResultsButton
    Apply-CommonButtonSettings -Button $OpenCsvResultsButton
}