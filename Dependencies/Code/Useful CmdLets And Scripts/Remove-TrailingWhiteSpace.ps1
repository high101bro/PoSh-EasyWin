param(
    $FilePath = '.',
    [switch]$Save
)

if ($Save){
    $script:ReportName = "Statistics of Removing Trailing White Spaces.txt"
    "Overall Statistics After Processing" > ./$script:ReportName  
}

$Files = Get-ChildItem -Path $FilePath -Recurse

$OriginalTotal = 0
$TrimmedTotal = 0
$SpaceSavedTotal = 0

Foreach ($File in $Files) {
    $BufferStringOriginal = ""
    $BufferStringTrimmed = ""
    $JustTheFiles = $File | Where-Object {$_.PSIsContainer -eq $false -and $_.extension -eq '.ps1'}
    $JustTheFiles = $JustTheFiles.FullName | Where-Object {$_ -ne ''}    

    try {
        foreach($line in $(Get-Content -Path "$JustTheFiles")) {
            $BufferStringOriginal += "$($line)`n"
            $BufferStringTrimmed += "$($line.TrimEnd())`n"
        }

        $OriginalSize = [System.Text.Encoding]::UTF8.GetByteCount($BufferStringOriginal) / 1KB
        $OriginalTotal += $OriginalSize
        $OriginalSize = [Math]::Round($OriginalSize,2)


        $TrimmedSize = [System.Text.Encoding]::UTF8.GetByteCount($BufferStringTrimmed) / 1KB
        $TrimmedTotal += $TrimmedSize
        $TrimmedSize = [Math]::Round($TrimmedSize,2)

        $SpaceSaved = $OriginalSize - $TrimmedSize

        "===================================================================================================="
        "$($File.FullName)"
        $O = "{0,-10} : {1} KB" -f "Original",$OriginalSize
        $T = "{0,-10} : {1} KB" -f "Trimmed",$TrimmedSize
        $S = "{0,-10} : {1} KB" -f "Saved",$SpaceSaved
        Write-Host $O -ForegroundColor Red 
        Write-Host $T -ForegroundColor Green
        Write-Host $S -ForegroundColor Cyan
        Write-Host ""

        if ($Save) {
            # Saves Processed Individual Files
            $BufferStringTrimmed | Out-File -FilePath $File.FullName -Force

            # Updates the Report
            "====================================================================================================" >> ./$script:ReportName
            "$($File.FullName)" >> ./$script:ReportName  
            $O >> ./$script:ReportName  
            $T >> ./$script:ReportName  
            $S >> ./$script:ReportName  
        }
    }
    catch {
        continue
    }    
}

$SpaceSavedTotal += $OriginalTotal - $TrimmedTotal

"===================================================================================================="
"Overall Statistics After Processing"
$O = "{0,-10} : {1} KB" -f "Original",$OriginalTotal
$T = "{0,-10} : {1} KB" -f "Trimmed",$TrimmedTotal
$S = "{0,-10} : {1} KB" -f "Saved",$SpaceSavedTotal
Write-Host $O -ForegroundColor Red 
Write-Host $T -ForegroundColor Green
Write-Host $S -ForegroundColor Cyan
Write-Host ""

if ($Save) {
    # Updates the Report
    "====================================================================================================" >> ./$script:ReportName
    "Overall Statistics After Processing" >> ./$script:ReportName  
    $O >> ./$script:ReportName  
    $T >> ./$script:ReportName  
    $S >> ./$script:ReportName  
}












# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUIHY359/tdCrx06Yj7aZdZN1/
# Ed6gggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUtJiYzXB3Sn+VzOQgp1KSVEiLnJcwDQYJKoZI
# hvcNAQEBBQAEggEAT1UWj/3VdGi+dJq2MBhOPSR5HWaQRkO94aykQeq+Ldrl/jwN
# YkI1YOH6jB9em1DhLJ98sWnm1mGT8S+0WbVcYoqhle6uBvhOR9Ng2iDQDlVr0kRc
# MnFv9Bl7HFviHMg+FeBNMID1ziQR27Q+1lCkLVZ3GY0q1fn95ds7UncFy8VD/1BY
# n98rhVbpUVbJIIYwhiLbkvpEm2p1ieKel/g3ayxJGlwSk7U3p1jO4wirH1J8dvZ6
# UY9xv4FihpVIApUPtdeVh4X/DYTzl9nkgSkpQ7A46K3Pg7VPg22s84vb99CiO0ZI
# agKSfmbs45kKJLmPF/ngWJw4gv+V3CVeo3W3Ng==
# SIG # End signature block
