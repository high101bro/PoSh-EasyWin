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
# cM6gggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUlngLj1febar5zcUBdyK/lu/bOpswDQYJKoZI
# hvcNAQEBBQAEggEANu7ap6XWX/cbdF/HHt9WkS/LI0/YDP0Xk2qHMHErufFaa7Hr
# NqrbUc0Ojj73dLl96BLm3hGwoewgxDFdCBMe4QHjixzXTyXZeIZJqYO/9oS34SqY
# 6mPV0GJzW0VnQBLoFgtHF5ye6ZfJ0Y5at69ch+KSK2WSdhlyRs7XY2/aWpXJMwBO
# p0/4ZxmOuwomFiq2u2yid5/vPrniqABO1OTJq4s7LqfueymxL12YX0i4DI0MogvT
# ajjH2yXL/2U24OMKmUr24vpEjnELEEqoqEL27/m6I7myTOz4m+uxxhMon3tkG2YL
# LfJK5Ocme4jKq2dqUq4bW6AlZnRHtseFZewqaw==
# SIG # End signature block
