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




# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUKCGJF0ROT4ram+wuHkI3nMO9
# cM6gggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUlngLj1febar5zcUBdyK/lu/bOpswDQYJKoZI
# hvcNAQEBBQAEggEApbzhOrHVTFDQCty3ibS3EozhgfBQG2DBbveHVl26nFYiw3AV
# 9p7/L3HnNtE2P+bxUop/aRL+s2cTvBTGk2S0x4WfT1aAFUnS6exVJZExFfjQTI1x
# tsDfK2Sdd8QQ6RKKISChdo7Yj2qQt1SUmqmohNjbPS8vuQmAOEix2iqA4CvJtYLz
# EvsYF4BVPbbBZd1dWffYd0ifus4hHZGPRAZNDg+elb7knUIPsPXfuQp+MAbhLMRT
# RLrciwszaWK9vuV9ZHgnGDB2e8VLUTUuySG5VEC76ZL22kjSX7lGm0n6EiWewWjE
# dzg4xCh72q/zeYuiJKPocX5++3A6RKeGT1Z1Iw==
# SIG # End signature block
