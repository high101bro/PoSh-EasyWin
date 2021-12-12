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



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUktuDRNqApGZx+74YEC2Nrf64
# qQCgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUKMZPkmj8iI4z859IJIcbd7TSb9swDQYJKoZI
# hvcNAQEBBQAEggEAxj0u4IEWj+9YlawFsPRHaEi07LUkA7uJJgc2tFOB1TaKbA+M
# 0673JoZwV+ClJlTAjnMA5P7RF19ee2vtMeSyEw/DuogklOaQSCMTSz5FFsA8jv4G
# 0JP82Y44ukla0svAWUIQQdTMDsAtGU/DGcoJtCuLZjf2zN9TTjrbbSkEW8lpdYNg
# uxrrzYYgGTQLQUlGRB6EWtcAHb5S1Ict2gIoCRu7tGA7ATitBffSD8aRkf9agIJa
# TST8slWICdPgXheSG28irOuWrzLSQMmodKEFFNurnsZTS3+fcPcwx7CkahrMTxg4
# h8+6p4PokabTIkz5zeaFoWCi4U5UuqRC1wdPpQ==
# SIG # End signature block
