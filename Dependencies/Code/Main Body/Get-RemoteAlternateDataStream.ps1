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
                    if (!$script:Credential) { Create-NewCredentials }
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
            Generate-NewRollingPassword
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU42g0+Q25Ma3JywN2hPNMYUTN
# hiqgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU2jajlixsbd8nByjsCm7FH6BS5WIwDQYJKoZI
# hvcNAQEBBQAEggEAaoCuvrDX9Tjx4Dpeh9DRKjWv2DygbRevM40naVOrnF3/7i9Y
# fw64nEg9xKUtBYVzkluErh5wrwhVOnOrnWrWsADrEEBa7I3pmyTcM1CcE0XYiiL4
# dkiiU7aJh0NFJA970rKqUq4HTRcsnQ9gjYVpvFBipMwpWUhbNDGLHQx+SyKrdvph
# xFZLlOEdtcCexl6WwAlXR1BViYoRfkTt3MbecXSSp/hr7laBqYzTAf2s8EhZDqGL
# FyqbL3VPEIRA2soPY40RgO6SRrdNvL8zYce4CgCNY573c52VjHs+MM5qGR3YCi1o
# T1lwG0/7dOVpOiPYWrkFAg2ObncI1fhZfg58LA==
# SIG # End signature block
