$ExecutionStartTime = Get-Date
$CollectionName = "Directory Listing Query"
$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Executing: $CollectionName")
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")
$PoShEasyWin.Refresh()

$script:ProgressBarEndpointsProgressBar.Value = 0

$OutputFilePath = "$($script:CollectionSavedDirectoryTextBox.Text)\Directory Listing"
$DirectoryPath  = $FileSearchDirectoryListingTextbox.Text
$MaximumDepth   = $FileSearchDirectoryListingMaxDepthTextbox.text

Invoke-Command -ScriptBlock {
    param($DirectoryPath,$MaximumDepth,$GetChildItemDepth)
    function Get-DirectoryListing {
        param($DirectoryPath,$MaximumDepth)
        if ([int]$MaximumDepth -gt 0) {
            Invoke-Expression $GetChildItemDepth

            # Older operating systems don't support the -depth parameter, needed to create a function to do so for backwards compatability
            #Get-ChildItem -Path $DirectoryPath -Depth $MaximumDepth

            Get-ChildItemDepth -Path $DirectoryPath -Depth $MaximumDepth -Force -ErrorAction SilentlyContinue
        }
        else {
            Get-ChildItem -Path $DirectoryPath -Force -ErrorAction SilentlyContinue
        }
    }
    Get-DirectoryListing -DirectoryPath $DirectoryPath -MaximumDepth $MaximumDepth

} -ArgumentList $DirectoryPath,$MaximumDepth,$GetChildItemDepth -Session $PSSession | Select-Object PSComputerName, Mode, Length, Name, Extension, Attributes, FullName, CreationTime, LastWriteTime, LastAccessTime, BaseName, Directory, PSIsContainer `
| Set-Variable SessionData
$SessionData | Export-Csv    -Path "$OutputFilePath.csv" -NoTypeInformation -Force
$SessionData | Export-Clixml -Path "$OutputFilePath.xml" -Force
Remove-Variable -Name SessionData -Force

$ResultsListBox.Items.RemoveAt(0)
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  [$(New-TimeSpan -Start $ExecutionStartTime -End (Get-Date))]  $CollectionName")
$PoShEasyWin.Refresh()

$script:ProgressBarQueriesProgressBar.Value   += 1
$script:ProgressBarEndpointsProgressBar.Value = ($PSSession.ComputerName).Count
$PoShEasyWin.Refresh()
Start-Sleep -match 500



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUzPYGBTSCE/8ws5qrpLm7rZ5X
# lligggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU3S2Gh7vr2tdkhJLdkQtyzmIe7agwDQYJKoZI
# hvcNAQEBBQAEggEAY3HpbUmalXHBJWxu1ghRLimmyL7P4/HtxLUFezWwYlC4b3mJ
# wWiE9c+FmWsamf75deP2dI/b0pO2tn3P0nuD0U1Avr3pU5BXX2m9hHJYVXaq8Ube
# 7s5ZY8oopllhqjBoSK1bfk8LptyFBp6geIcpAn/A6F0S8vcW3DgzNTe6QiIo5m5H
# jtR3ttfX1NWgvJiJPXhuFY8dHKYAhulKOBhk76rIZ5s9tuDwrLQ9Y6ShENALukcG
# LhNDunWjlJC4hqZQWnKU5wmx6v789d1xpR/bENj5h74tgS/4Q9UDGUoEdkAEAp1t
# XVjAQU5iuweU4AIIr6t+Llo3phnN2bAFKQPzLw==
# SIG # End signature block
