function Search-AlternateDataStream {
    param($DirectoriesToSearch,$MaximumDepth)
    if ([int]$MaximumDepth -gt 0) {
        #Invoke-Expression $GetChildItemDepth
        Function Get-ChildItemDepth {
            Param(
                [String[]]$Path     = $PWD,
                [String]$Filter     = "*",
                [Byte]$Depth        = 255,
                [Byte]$CurrentDepth = 0
            )
            $CurrentDepth++
            Get-ChildItem $Path -Force | ForEach-Object {
                $_ | Where-Object { $_.Name -Like $Filter }
                If ($_.PsIsContainer) {
                    If ($CurrentDepth -le $Depth) {
                        # Callback to this function
                        Get-ChildItemDepth -Path $_.FullName -Filter $Filter -Depth $Depth -CurrentDepth $CurrentDepth
                    }
                }
            }
        }

        # Older operating systems don't support the -depth parameter, needed to create a function to do so for backwards compatability
        #Get-ChildItem -Path $DirectoryPath -Depth $MaximumDepth

        $AllFiles = Get-ChildItemDepth -Path $DirectoriesToSearch -Depth $MaximumDepth
    }
    else {
        $AllFiles = Get-ChildItem -Path $DirectoriesToSearch -Force -ErrorAction SilentlyContinue
    }

    $AdsFound = $AllFiles | ForEach-Object { Get-Item $_.FullName -Force -Stream * -ErrorAction SilentlyContinue } | Where-Object stream -ne ':$DATA'
    foreach ($Ads in $AdsFound) {
        $AdsData = Get-Content -Path "$($Ads.FileName)" -Stream "$($Ads.Stream)"
        $Ads | Add-Member -MemberType NoteProperty -Name PSComputerName -Value $($Env:ComputerName)
        #too much... $Ads | Add-Member -MemberType NoteProperty -Name StreamData -Value $AdsData
        $Ads | Add-Member -MemberType NoteProperty -Name StreamDataSample -Value $(($AdsData | Out-String)[0..1000] -join "")
        if     (($Ads.Stream -eq 'Zone.Identifier') -and ($Ads.StreamDataSample -match 'ZoneID=0')) { $Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "[ZoneID 0] Local Machine Zone: The most trusted zone for content that exists on the local computer." }
        elseif (($Ads.Stream -eq 'Zone.Identifier') -and ($Ads.StreamDataSample -match 'ZoneID=1')) { $Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "[ZoneID 1] Local Intranet Zone: For content located on an organization’s intranet." }
        elseif (($Ads.Stream -eq 'Zone.Identifier') -and ($Ads.StreamDataSample -match 'ZoneID=2')) { $Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "[ZoneID 2] Trusted Sites Zone: For content located on Web sites that are considered more reputable or trustworthy than other sites on the Internet." }
        elseif (($Ads.Stream -eq 'Zone.Identifier') -and ($Ads.StreamDataSample -match 'ZoneID=3')) { $Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "[ZoneID 3] Internet Zone: For Web sites on the Internet that do not belong to another zone." }
        elseif (($Ads.Stream -eq 'Zone.Identifier') -and ($Ads.StreamDataSample -match 'ZoneID=4')) { $Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "[ZoneID 4] Restricted Sites Zone: For Web sites that contain potentially-unsafe content." }
        else {$Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "N/A"}
        $Ads | Add-Member -MemberType NoteProperty -Name FileSize -Value $(
            if     ($Ads.Length -gt 1000000000) { "$([Math]::Round($($Ads.Length / 1gb),2)) GB" }
            elseif ($Ads.Length -gt 1000000)    { "$([Math]::Round($($Ads.Length / 1mb),2)) MB" }
            elseif ($Ads.Length -gt 1000)       { "$([Math]::Round($($Ads.Length / 1kb),2)) KB" }
            elseif ($Ads.Length -le 1000)       { "$($Ads.Length) Bytes" }
        )
    }
    $AdsFound
}


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUeBcOgj7fVfIfX/6mRAcy8NIG
# 6vGgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUSDzFMXQb/n01njbiKzTsWdjwJV8wDQYJKoZI
# hvcNAQEBBQAEggEAFNjo8Q/3g6SpPVuchIQ17P0lHrFaPmGB7wgUlL6lZTWZfnnM
# QMALg29nl1WvoDfLDWTVva5sIurcAk/jgb1XSs1kr9gX78CKZQJpX4OWxBnBdVwu
# PnnpuDQ05O5BbFyCYfIpS0FNQ67a1NxLaKsrqbw7u2sYsNDaNI7avkfovrAOt6f2
# 4ZsE/qzy+J6zVhxyL9ugrL22r2hst/bYnZpb/niGMLAXs1UBZupI1u2AjGqjZaCY
# s0f7EpbNfka85NbqWZLixX4YuWCVvnqYP1j1Ab/IPdTsYC43hFClYkLEmLwOgFWX
# 1cZIDhJu2GygHEaLUS/LorHjkwsk8ZgKc+8WwQ==
# SIG # End signature block
