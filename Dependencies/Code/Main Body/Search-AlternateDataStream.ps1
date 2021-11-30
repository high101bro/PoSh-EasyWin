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
# 6vGgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUSDzFMXQb/n01njbiKzTsWdjwJV8wDQYJKoZI
# hvcNAQEBBQAEggEAZzZF2zdThFpWXMUQr1YmaznhKjv0H7M7VPLIzrOjOeD6XBdT
# 14IqoMUceU/OkZitzIxmOQcJQIjeSddaE7fSAYYw33TxaU1xlaKC/zxf1UiOyEeE
# yDJmiOGL73tieJDHXftspKexc1BH1JHc6KhC8n5sn0jhV+XOOBnB38/wSpF7ULIP
# 0tWEGZzchz05x8q0RDgt6Q7+Rw/xue6hU5ajQ7F2P9/aKcAyYKJRQvQPsf0g6jeo
# fejwFlSc9UKuPN7KPTcmZNvUzHQ45I7zitbkyb1wXRVI7WUxzFgOKSEnSJzKwCQJ
# Lll79D9n02w4ktDhk0QIRCnGtfftrSvb+83tzg==
# SIG # End signature block
