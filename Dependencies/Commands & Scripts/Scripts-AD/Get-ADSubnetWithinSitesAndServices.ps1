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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUk72yua8s168vMCy249KMj7DR
# X2GgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU8etzA3yv720dMq6h3kit15JnJW0wDQYJKoZI
# hvcNAQEBBQAEggEAO8gUI1vdcF/ZA+Avd4+NdGvdwWQuoUvDvFAK8INKwfoaMF3X
# ajnckwAOVH2DjL77+7yrmmdR+EXaaTdfjDJV54MgQMjtqy6O/VrVaEb0Ny4anOtN
# 8ytDrRK/QWz+a27ZacXCEdjKIVGlrT8jaKiKJGHrnovcg4s4tU7FfmJXK+nGpl2X
# wq5DLysLD8RKAzYgstj/Ro4ZRETuyNkjjBhGs5jwi3ZuZzv5PzatWfDfTINAH+SK
# 2rpF/Fw/S+BbdkValWFQjKMv5oBYDnf6wFvGdw2p/4o4s0b6CbT5EZcwefEkq+yA
# vRErG6Ax977RZX7UQgT1dFB1ebH+2a7WbZFFxw==
# SIG # End signature block
