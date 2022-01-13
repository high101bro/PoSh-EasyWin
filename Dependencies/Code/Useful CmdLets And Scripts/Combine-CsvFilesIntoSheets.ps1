function Combine-CsvFilesIntoSheets {
    param(
        [string]$PathToCsvFiles = '.'
    )
    Set-Location $PathToCsvFiles
    
    $csvs = Get-ChildItem .\* -Include *.csv
    $y = $csvs.Count
    
    Write-Host "Detected the following CSV files: ($y)"
    foreach ($csv in $csvs) {
        Write-Host " "$csv.Name
    }

    #creates file name with date/username
    $OutputXlsxFileName = $(Get-Date -f yyyyMMdd) + "_" + $env:USERNAME + "_combined-data.xlsx"
    Write-Host "Creating: $OutputXlsxFileName"

    $excelapp = New-Object -ComObject Excel.Application
    $excelapp.SheetsInNewWorkbook = $csvs.Count
    $xlsx = $excelapp.Workbooks.Add()
    $sheet = 1

    foreach ($csv in $csvs) {
        $row = 1
        $column = 1
        $worksheet = $xlsx.Worksheets.Item($sheet)
        $worksheet.Name = $csv.BaseName
        $file = Get-Content $csv
        foreach ($line in $file) {
            $linecontents = $line -split ',(?!\s*\w+")'
            foreach ($cell in $linecontents) {
                if ($cell[0] -eq '"' -and $cell[-1] -eq '"') {
                    $cell = ($cell).trim('"')
                }
                elseif ($cell[0] -eq "'" -and $cell[-1] -eq "'") {
                    $cell = ($cell).trim("'")
                }
                $worksheet.Cells.Item($row,$column) = $cell
                $column++
            }
            $column = 1
            $row++
        }
        $sheet++
    }
    $output = $PathToCsvFiles + "\" + $OutputXlsxFileName
    $xlsx.SaveAs($output)
    $excelapp.quit()
}
# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU9/A82ycmEmvw6ijvi0Ng5S1J
# 7AGgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUHVOv9+LoDKSvLNzG6WAvEaXGZsUwDQYJKoZI
# hvcNAQEBBQAEggEAEuYsTmDRljxzgYwgmbH1Fl8PlUjsTj17PQ6NTrcIYeSKfdhQ
# SnYnVwNhe5oBoAu2yZYXDrzIOT5KliMdTGhNwQ3XPvs39z+7nHWeV7LfsoP7/CLW
# EOUdYK5kjHxC8jBuq1kTPyoy4SYqFhs7mZKiVi94274Ye2ap8FIp27ncCfpWS/PB
# meVgCv/LsxHNvtvkEnxRV29fG0eMnZso6uY7qZ4mfdkOm7QXWUDv7/DTy7IbVUvy
# 2w2hRCsOk0KvdZ8YxTYNEXW5kkjjmiFCHBz9GBqqKIIjeLF0hJDR8Z+653RSTip+
# BZh92oHrV9oiwa2ut75R5o2atwaaBXx8hSSnDA==
# SIG # End signature block
