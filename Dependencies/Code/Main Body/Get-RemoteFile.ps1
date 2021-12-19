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



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU/kJYdW1Y/IKpJIcwTRhr7dnz
# r2+gggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUgxfL0DmQqml4GAin2QiHw/cU9oMwDQYJKoZI
# hvcNAQEBBQAEggEAAxf6E2qJIlF2ROYx3bivyvsr8OaCY5MPjyD0EdqnxEZGIZRW
# 7Qz0xfuZ0i/0zRL2Svt5TtDE23ubL+3T3VHmVm1afrij8Pnr/YB+L7u5Z1ka8kVZ
# /QvL/MX7O/tEbddSJw2Oiye71U6jnLy+rKQIc85GEwwVqcf9PolGefZX39A36TUL
# O29kqIt+g5CuSTd332dsplna/GEiOCb/AbgzvqorRCuLmfxHMGv9xhPmzZrj9BPH
# vWNwR9b0i9KEQMNOdhs2mimCg7kHk9skhjizgAlokBnmExG2XHBKgynoF0IgL+nV
# FuYt5GWPtqTDQGgIt/VnhFycFZ8u3I5SHuloTg==
# SIG # End signature block
