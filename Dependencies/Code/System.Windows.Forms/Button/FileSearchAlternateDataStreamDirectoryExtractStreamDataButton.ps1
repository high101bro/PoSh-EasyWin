$FileSearchAlternateDataStreamDirectoryExtractStreamDataButtonAdd_Click = {
    try {
#       [System.Reflection.Assembly]::LoadWithPartialName("System .Windows.Forms") | Out-Null
        $ExtractStreamDataOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{
            Title            = "Select An Alternate Data Stream CSV File"
            InitialDirectory = "$(if (Test-Path $($script:CollectionSavedDirectoryTextBox.Text)) {$($script:CollectionSavedDirectoryTextBox.Text)} else {$CollectedDataDirectory})"
            Filter           = "CSV (*.csv)|*.csv|All files (*.*)|*.*"
            ShowHelp         = $true
        }
        $ExtractStreamDataOpenFileDialog.ShowDialog() | Out-Null
        $ExtractStreamDataFrom = Import-Csv $($ExtractStreamDataOpenFileDialog.FileName)
        $StatuListBox.Items.Clear()
        $StatusListBox.Items.Add("Retrieve & Extract Alternate Data Stream")
    }
    catch{}

    $SelectedFilesToExtractStreamData = $null
    $SelectedFilesToExtractStreamData = $ExtractStreamDataFrom | Out-GridView -Title 'Retrieve & Extract Alternate Data Stream' -PassThru

    Get-RemoteAlternateDataStream -Files $SelectedFilesToExtractStreamData

    Remove-Variable -Name SelectedFilesToExtractStreamData
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUor/eHJobLtBukiEvS2VsHS3R
# NFWgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUV5q3rC/WFNaSwes445rAvLRyuqwwDQYJKoZI
# hvcNAQEBBQAEggEAMKnIWkibd0GwH1QpGrDDsQQaI2VVeFPRhcOFXKUNt6lmToHm
# gfgWpzW53faY2Y/OIFTSerz8s+TIjEhS/wOmsX4eS+wiYH5Ch0evPDSwrQnfk70l
# gUMa4ImN2X7klV1fkZFXDu9dR9n9U4/Ducp4+aotK2WIX5CYHTykcksV52SmSeV/
# b3Ix3NhcUuJ4tuNk2Bd0cUdWHqGYNRlzH35QqvOG/RM07D5fGP0OWVqchmAz9z/3
# /7A3MqckEh5B0EgzbS4ECcnRyToS07YJ1TlrwRMVVh6hXPzlP3JcYWuhrl29BfWN
# 1RG1OPqzer3iROH5aWu+qhuICJlF4HJn/UcxrQ==
# SIG # End signature block
