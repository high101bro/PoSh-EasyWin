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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUZICdl9PKnjCXfoSVln8hHCKv
# 8L2gggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUOt18bn0owuwPInX1lWlacDWdvBcwDQYJKoZI
# hvcNAQEBBQAEggEAZJQPUAc8oETwl28x8hQe2KMom8wX7WuwMVPE+2q5q7u4xt0a
# We8kx/+maswLZQvkDHuLk5BbyO9FTPxsiX7smJ4we/Bju/xXlqdNQENIMP44uAbG
# UzJTIRlrl0egcOr7d3QmiXOc45VqM4q9HSCKoLVxIkVTh+9r6eUhr1X8GAIM4aFw
# XQ5caUStCVX6CfjyTJVybfitKUfLU/FEcXcCNZCz20eJb1C3/niWzfD4fpZ0o8xy
# fFuA23guXfAXI2AP8BkEqSFe+hSp9krxK7Hkce7K7h4yISTZYfYzig6fzyCexaMV
# zjyozGcTxrXqLuR0qFyb9+mR97y5z6yUaAC6Gw==
# SIG # End signature block
