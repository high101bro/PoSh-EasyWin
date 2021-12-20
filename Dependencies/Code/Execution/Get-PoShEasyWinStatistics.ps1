function Get-PoShEasyWinStatistics {
    Compile-TreeViewCommand

    $StatisticsResults             = ""
    $StatisticsAllCSVFiles         = Get-Childitem -Path $CollectedDataDirectory -Recurse -Include "*.csv"
    $StatisticsAllCSVFilesMeasured = $StatisticsAllCSVFiles | Measure-Object -Property Length -Sum -Average -Maximum -Minimum

    $StatisticsResults += "$('{0,-25}{1}' -f "Number of CSV files:", $($StatisticsAllCSVFilesMeasured.Count))`r`n"

    $StatisticsFirstCollection = $($StatisticsAllCSVFiles | Sort-Object -Property CreationTime | Select-Object -First 1).CreationTime
    $StatisticsResults += "$('{0,-25}{1}' -f "First query datetime:", $StatisticsFirstCollection)`r`n"

    $StatisticsLatestCollection = $($StatisticsAllCSVFiles | Sort-Object -Property CreationTime | Select-Object -Last 1).CreationTime
    $StatisticsResults += "$('{0,-25}{1}' -f "Latest query datetime:", $StatisticsLatestCollection)`r`n"

    $StatisticsAllCSVFilesSum = $(
        $CSVBytes = $StatisticsAllCSVFilesMeasured.Sum
        if ($CSVBytes -gt 1GB) {"{0:N3} GB" -f $($CSVBytes / 1GB)}
        elseif ($CSVBytes -gt 1MB) {"{0:N3} MB" -f $($CSVBytes / 1MB)}
        elseif ($CSVBytes -gt 1KB) {"{0:N3} KB" -f $($CSVBytes / 1KB)}
        else {"{0:N3} Bytes" -f $CSVBytes}
    )
    $StatisticsResults += "$('{0,-25}{1}' -f "Total CSV Data:", $StatisticsAllCSVFilesSum)`r`n"

    $StatisticsAllCSVFilesAverage = $(
        $CSVBytes = $StatisticsAllCSVFilesMeasured.Average
        if ($CSVBytes -gt 1GB) {"{0:N3} GB" -f $($CSVBytes / 1GB)}
        elseif ($CSVBytes -gt 1MB) {"{0:N3} MB" -f $($CSVBytes / 1MB)}
        elseif ($CSVBytes -gt 1KB) {"{0:N3} KB" -f $($CSVBytes / 1KB)}
        else {"{0:N3} Bytes" -f $CSVBytes}
    )
    $StatisticsResults += "$('{0,-25}{1}' -f "Average CSV filesize:", $StatisticsAllCSVFilesAverage)`r`n"

    $StatisticsAllCSVFilesMaximum = $(
        $CSVBytes = $StatisticsAllCSVFilesMeasured.Maximum
        if ($CSVBytes -gt 1GB) {"{0:N3} GB" -f $($CSVBytes / 1GB)}
        elseif ($CSVBytes -gt 1MB) {"{0:N3} MB" -f $($CSVBytes / 1MB)}
        elseif ($CSVBytes -gt 1KB) {"{0:N3} KB" -f $($CSVBytes / 1KB)}
        else {"{0:N3} Bytes" -f $CSVBytes}
    )
    $StatisticsResults += "$('{0,-25}{1}' -f "Largest CSV filesize:", $StatisticsAllCSVFilesMaximum)`r`n"

    $StatisticsAllCSVFilesMinimum = $(
        $CSVBytes = $StatisticsAllCSVFilesMeasured.Minimum
        if ($CSVBytes -gt 1GB) {"{0:N3} GB" -f $($CSVBytes / 1GB)}
        elseif ($CSVBytes -gt 1MB) {"{0:N3} MB" -f $($CSVBytes / 1MB)}
        elseif ($CSVBytes -gt 1KB) {"{0:N3} KB" -f $($CSVBytes / 1KB)}
        else {"{0:N3} Bytes" -f $CSVBytes}
    )
    $StatisticsResults += "$('{0,-25}{1}' -f "Smallest CSV filesize:", $StatisticsAllCSVFilesMinimum)`r`n"

    $StatisticsResults += "`r`n"
    $StatisticsLogFile = Get-ItemProperty -Path $Logfile

    $NumberOfLogEntries = (get-content -path $logfile | Select-String -Pattern '\d{4}/\d{2}/\d{2} \d{2}[:]\d{2}[:]\d{2} [-] ').count
    $StatisticsResults += "$('{0,-25}{1}' -f "Number of Log Entries:", $NumberOfLogEntries)`r`n"

    $StatisticsLogFileSize = $(
        $LogFileSize = $StatisticsLogFile.Length
        if ($LogFileSize -gt 1GB) {"{0:N3} GB" -f $($LogFileSize / 1GB)}
        elseif ($LogFileSize -gt 1MB) {"{0:N3} MB" -f $($LogFileSize / 1MB)}
        elseif ($LogFileSize -gt 1KB) {"{0:N3} KB" -f $($LogFileSize / 1KB)}
        else {"{0:N3} Bytes" -f $LogFileSize}
    )
    $StatisticsResults += "$('{0,-25}{1}' -f "Logfile filesize:", $StatisticsLogFileSize)`r`n"

    $StatisticsResults += "`r`n"
    $StatisticsComputerCount = 0
    [System.Windows.Forms.TreeNodeCollection]$StatisticsAllHostsNode = $script:ComputerTreeView.Nodes
    foreach ($root in $StatisticsAllHostsNode) {foreach ($Category in $root.Nodes) {foreach ($Entry in $Category.nodes) {if ($Entry.Checked) { $StatisticsComputerCount++ }}}}
    $StatisticsResults += "$('{0,-25}{1}' -f "Computers Selected:", $StatisticsComputerCount)`r`n"
    $StatisticsResults += "$('{0,-25}{1}' -f "Queries Selected:", $QueryCount)`r`n"

    $ResourcesDirCheck = Test-Path -Path "$Dependencies"
    $StatisticsResults += "$('{0,-25}{1}' -f "Dependancies Check:", $ResourcesDirCheck)`r`n"

    return $StatisticsResults
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUk9dxYyWApwE9XSd93XmfVVmz
# 4kygggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUtruZ5WBdBiz08OfpEek0Nrg7hbMwDQYJKoZI
# hvcNAQEBBQAEggEAGWABwwoDKqIx7IU8UqzBbNY9Uefd6OaMkRJ0V+HRhImsgHA2
# UKahx2ZpkhHaKDVTQ5pPn6B2U80kNbax4dAR82G8EJLA1AXLL2BaUTkpUcT85Iy+
# x6FUfHy188xrxh8+L72MWputfdArRbmGztxRBPMHQtl/KsGXMlTC1NU1kayfjOzE
# 4N2OFILEnXF6/emelO+fHT0u9Ax3Bvfqew9phc6lzIEUQAvbV1lduMy7HRHw4XX8
# 6PvqD7ItvySPRn4GVGBw/XFb7RHR6i0W+EDoU8gs68lNAbN4GUx7Kl3BwjiiK9XT
# zo2p5Hl9vDexnaBq2AJJdLU1wsLbwr04+hSBDw==
# SIG # End signature block
