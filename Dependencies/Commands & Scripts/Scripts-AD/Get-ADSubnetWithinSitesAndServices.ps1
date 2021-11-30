## Get a list of all domain controllers in the forest
$DcList = (Get-ADForest).Domains | ForEach { Get-ADDomainController -Discover -DomainName $_ } | ForEach { Get-ADDomainController -Server $_.Name -filter * } | Select Site, Name, Domain

## Get all replication subnets from Sites & Services
$Subnets = Get-ADReplicationSubnet -filter * -Properties * | Select Name, Site, Location, Description

## Create an empty array to build the subnet list
$ResultsArray = @()

## Loop through all subnets and build the list
ForEach ($Subnet in $Subnets) {

    $SiteName = ""
    If ($Subnet.Site -ne $null) { $SiteName = $Subnet.Site.Split(',')[0].Trim('CN=') }

    $DcInSite = $False
    If ($DcList.Site -Contains $SiteName) { $DcInSite = $True }

    $RA = New-Object PSObject
    $RA | Add-Member -type NoteProperty -name "Subnet"   -Value $Subnet.Name
    $RA | Add-Member -type NoteProperty -name "SiteName" -Value $SiteName
    $RA | Add-Member -type NoteProperty -name "DcInSite" -Value $DcInSite
    $RA | Add-Member -type NoteProperty -name "SiteLoc"  -Value $Subnet.Location
    $RA | Add-Member -type NoteProperty -name "SiteDesc" -Value $Subnet.Description

    $ResultsArray += $RA

}

## Export the array as a CSV file
$ResultsArray | Sort Subnet


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUNi6Ckf+dgcVwcekW75kiqQnp
# QSWgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU7t8cdbfwp3vBYK1y2apcNlIBsF4wDQYJKoZI
# hvcNAQEBBQAEggEAxIMjNl3tauWb/vuI+ZWcmYcntmt+LoLLpG1BPf2TgG610UGv
# iuwD34MI8+Ka2PcNc+J4EF5c+rJA9hW11gHDwBjN2Inl4ucZUTtbcy35vQcwZS+j
# 6yAWmsg/6MGA40oK4xkjnhq9blVeVRzsCgl10msMHruCsmnyS6SqygHXNU/bRalB
# watus+jrVQwTgiOjigRD0G2DFuMQlK+Oh8i1uZWDAJ+gPXO8eHgUiW9onleV1Rmx
# p/PkQNI81JkzC08pNn+FyWpg9rJrQTNoJQ0y0qOmU/UWM40Y3usCfRt+P99mArf6
# HiWWBM50JH+0XbrCEB3tPLLukL4ByZW4N0SRbw==
# SIG # End signature block
