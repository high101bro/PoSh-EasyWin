function Get-RemoteAlternateDataStream {
    param(
        $Files
    )
    $SelectedFilesToExtractStreamData = $Files

    if ($SelectedFilesToExtractStreamData) {
        $DownloadSize = $SelectedFilesToExtractStreamData | Select-Object -ExpandProperty length | Measure-Object -Sum | Select-Object -ExpandProperty Sum
        if     ($DownloadSize -gt 1000000000) { $DownloadSize = "$([Math]::Round($($DownloadSize / 1gb),2)) GB" }
        elseif ($DownloadSize -gt 1000000)    { $DownloadSize = "$([Math]::Round($($DownloadSize / 1mb),2)) MB" }
        elseif ($DownloadSize -gt 1000)       { $DownloadSize = "$([Math]::Round($($DownloadSize / 1kb),2)) KB" }
        elseif ($DownloadSize -le 1000)       { $DownloadSize = "$DownloadSize Bytes" }

        $ConfirmSelection = $False
        $MessageBox = [System.Windows.Forms.MessageBox]::Show("Total data amount prior to compression and download:  $DownloadSize","PoSh-EasyWin - Extract Stream Data",[System.Windows.Forms.MessageBoxButtons]::OKCancel)
        switch ($MessageBox){
            "OK"     { $ConfirmSelection = $true }
            "Cancel" { $ConfirmSelection = $False }
        }
    }


    if ($SelectedFilesToExtractStreamData -and $ConfirmSelection) {
        $InformationTabControl.SelectedTab = $Section3ResultsTab

        if (Test-Path $($script:CollectionSavedDirectoryTextBox.Text)) { $RetrieveFilesSaveDirectory = $script:CollectionSavedDirectoryTextBox.Text }
        $RetrieveFilesSaveDirectory = $script:CollectionSavedDirectoryTextBox.Text


        $StatusListBox.Items.clear()
        $StatusListBox.Items.Add("Extracting Alternate Data Stream from Files")
        #Removed For Testing#$ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Extracting Alternate Data Stream from Files:")
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Retrieved the following files from:"

        # Function Zip-File
        # Uses the .Net Framework to zip files and directories
        . "$Dependencies\Code\Execution\Retrieve Files\Zip-File.ps1"

    #        # Function Create-RetrievedFileDetails
    #        # Creates the 'File Details.txt' fiile that is included into zipped Retrieved Files
        . "$Dependencies\Code\Execution\Retrieve Files\Create-RetrievedFileDetails.ps1"

        $SelectedFilesToExtractStreamData = $SelectedFilesToExtractStreamData | Sort-Object -Property PSComputerName
        $ExtractStreamDataCurrentComputer = ''

        $script:ProgressBarEndpointsProgressBar.Maximum = ($SelectedFilesToExtractStreamData.PSComputerName | Sort-Object -Unique).count
        $script:ProgressBarEndpointsProgressBar.Value   = 0


        function Extract-AlternateDataStream {
            # Identified file is first compressed on the endpoint
            # If the target item is a directory, the directory will be directly compressed
            # If the target item is not a directory, it will copy the item to c:\Windows\Temp
            # Uses .Net Framework System.IO.Compression.FileSystem
            $StreamDataRemoteSaveLocation = "C:\Windows\Temp\$($File.Stream)"
            Invoke-Command -ScriptBlock {
                param(
                    $File,
                    $StreamDataRemoteSaveLocation,
                    $ZipFile
                )
                Get-content -Path $($File.FileName) -Stream $($File.Stream) -Raw | Set-Content $StreamDataRemoteSaveLocation
                Invoke-Expression $ZipFile
                Zip-File -Path $StreamDataRemoteSaveLocation -Destination 'C:\Windows\Temp' -Compression Optimal -ADS
            } -Argumentlist @($File,$StreamDataRemoteSaveLocation,$ZipFile) -Session $session


            # File is hashed remotely on endpoint, then copied back over the network
            $RetrievedFileHashMD5 = Invoke-Command -ScriptBlock {
                param($StreamDataRemoteSaveLocation)
                (Get-FileHash -Algorithm MD5 -Path $StreamDataRemoteSaveLocation).Hash
            } -Argumentlist $StreamDataRemoteSaveLocation -Session $session
            Copy-Item -Path "c:\Windows\Temp\$($File.Stream).zip" -Destination "$LocalSavePath\$($File.Stream) [MD5=$RetrievedFileHashMD5].zip" -FromSession $session

            # The 'File Details.txt' is created locally from the source file on the endpoint
            # The file in this case is of that what is extracted from an Alternate Data Stream
            # This script also get other file metatadata
            # Also hashes the file with multiple algorithms
            # Gets AuthenticodeSignature information
            Create-RetrievedFileDetails -LocalSavePath $LocalSavePath -File $StreamDataRemoteSaveLocation -ADS $File -AdsUpdateName "$LocalSavePath\$($File.Stream) [MD5=$RetrievedFileHashMD5].zip"


            # The extracted alternate data stream and zipped file are removed from the endpoint
            Invoke-Command -ScriptBlock {
                param(
                    $File,
                    $StreamDataRemoteSaveLocation
                )
                Remove-Item -Path $StreamDataRemoteSaveLocation -Force
                Remove-Item "c:\Windows\Temp\$($File.Stream).zip" -Force
            } -ArgumentList @($File,$StreamDataRemoteSaveLocation) -Session $session

            $script:ProgressBarQueriesProgressBar.Value += 1
        }



        Foreach ($File in $SelectedFilesToExtractStreamData) {
            if ($ExtractStreamDataCurrentComputer -eq '') {
                $ExtractStreamDataCurrentComputer = $File.PSComputerName
                $script:ProgressBarQueriesProgressBar.Maximum = ($SelectedFilesToExtractStreamData | Where {$_.PSComputerName -eq $ExtractStreamDataCurrentComputer}).count
                $script:ProgressBarQueriesProgressBar.Value   = 0


                $LocalSavePath = "$RetrieveFilesSaveDirectory\Retrieved & Extracted Stream Data - $ExtractStreamDataCurrentComputer"
                if ( -not (Test-Path -Path "$RetrieveFilesSaveDirectory\Retrieved & Extracted Stream Data - $ExtractStreamDataCurrentComputer") ) {
                    New-Item -Type Directory -Path $LocalSavePath
                }


                if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                    if (!$script:Credential) { Set-NewCredential }
                    $session = New-PSSession -ComputerName $ExtractStreamDataCurrentComputer -Name "PoSh-EasyWin Extract Stream Data $ExtractStreamDataCurrentComputer" -Credential $script:Credential
                    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "- New-PSSession -ComputerName $ExtractStreamDataCurrentComputer -Credential $script:Credential"
                }
                else {
                    $session = New-PSSession -ComputerName $ExtractStreamDataCurrentComputer -Name "PoSh-EasyWin Extract Stream Data $ExtractStreamDataCurrentComputer"
                    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "- New-PSSession -ComputerName $ExtractStreamDataCurrentComputer"
                }

                Extract-AlternateDataStream
            }
            elseif ($ExtractStreamDataCurrentComputer -eq $File.PSComputerName) {
                # no need for new session as there is already one open to the target computer

                Extract-AlternateDataStream
            }
            elseif ($ExtractStreamDataCurrentComputer -ne $File.PSComputerName) {
                Get-PSSession -Name "PoSh-EasyWin Extract Stream Data $ExtractStreamDataCurrentComputer" | Remove-PSSession
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "   Remove-PSSession -ComputerName $ExtractStreamDataCurrentComputer"

                $ExtractStreamDataCurrentComputer = $File.PSComputerName
                $script:ProgressBarQueriesProgressBar.Maximum = ($SelectedFilesToExtractStreamData | Where {$_.PSComputerName -eq $ExtractStreamDataCurrentComputer}).count
                $script:ProgressBarQueriesProgressBar.Value   = 0


                $LocalSavePath = "$RetrieveFilesSaveDirectory\Retrieved & Extracted Stream Data - $ExtractStreamDataCurrentComputer"
                if ( -not (Test-Path -Path "$RetrieveFilesSaveDirectory\Retrieved & Extracted Stream Data - $ExtractStreamDataCurrentComputer") ) {
                    New-Item -Type Directory -Path $LocalSavePath
                }


                $session = New-PSSession -ComputerName $ExtractStreamDataCurrentComputer -Name "PoSh-EasyWin Extract Stream Data $ExtractStreamDataCurrentComputer"
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "- New-PSSession -ComputerName $ExtractStreamDataCurrentComputer"


                Extract-AlternateDataStream


                $script:ProgressBarEndpointsProgressBar.Value += 1
                $PoShEasyWin.Refresh()
            }
            $ResultsListBox.Items.Insert(1,"- $($ExtractStreamDataCurrentComputer): $($File.FileName)")
            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "   Copied: $($File.FileName)"
            $PoShEasyWin.Refresh()
        }
        $script:ProgressBarEndpointsProgressBar.Maximum = 1
        $script:ProgressBarEndpointsProgressBar.Value   = 1
        $script:ProgressBarQueriesProgressBar.Maximum   = 1
        $script:ProgressBarQueriesProgressBar.Value     = 1

        Get-PSSession -Name "PoSh-EasyWin Extract Stream Data $ExtractStreamDataCurrentComputer" | Remove-PSSession
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "   Remove-PSSession -ComputerName $ExtractStreamDataCurrentComputer"

        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Retrieved Files Saved To: $RetrieveFilesSaveDirectory"
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Retrieved Files From Endpoints Were Zipped To 'c:\Windows\Temp\' Then Removed"

        if ($script:RollCredentialsState -and $script:ComputerListProvideCredentialsCheckBox.checked) {
            Start-Sleep -Seconds 3
            Set-NewRollingPassword
        }

        if ($SelectedFilesToExtractStreamData) { Start-Sleep -Seconds 1;  Invoke-Item -Path $RetrieveFilesSaveDirectory }
        $PoShEasyWin.Refresh()
    }
    Apply-CommonButtonSettings -Button $FileSearchAlternateDataStreamDirectoryExtractStreamDataButton

    Apply-CommonButtonSettings -Button $RetrieveFilesButton

    Apply-CommonButtonSettings -Button $OpenXmlResultsButton
    Apply-CommonButtonSettings -Button $OpenCsvResultsButton
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUAr/c1ZmAKBI7NgY1N9eqVp8d
# Bs6gggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUakv7mP6Ci4WVgFdqfrpqHg0Ay8cwDQYJKoZI
# hvcNAQEBBQAEggEAJd1Hbzd3PUmKmE2prbGoGPzr+lKttFPB+GhKxvZXxlud3wBa
# s27E71nBHVV69LmCWAwSinsq68fDy95l63S0OXw3iaV9+3H9HP73DWKlBEbCm0+p
# 6Hzl5GfwoGiUaPa3Mv86sNbt9pvesM2Ctdk9rUTArsxEwf3bJ/aPFdbxWZwDs2Ux
# 7MvqgP01w9Tv1fMWBpPUzwMp7+yu9pD1YlamADEa+QPh1bf+thKEH+gKRHlUlwNR
# ScMg+WgPgfEmkzU5GpMEgDiODVEeUBIWhxFqzHP69RtJq5DgLUxFm9cW+IgPIZ32
# hqP1cmrvLlQYmGyQRXsUiKWPsrzVTTdmOZlwIA==
# SIG # End signature block
