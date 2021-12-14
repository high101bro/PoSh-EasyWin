<#
.Description
	Active Directory has five FSMO roles, two of which are enterprise-level (ie, one per forest) and three of which are domain-level (ie, one per domain). The enterpriese-level FSMO roles are called the Schema Master and the Domain Naming Master. The Domain-level FSMO roles are called the Primary Domain Controller Emulator, the Relative Identifier Master, and the Infrastructure Master.

	In a new Active Directory forest, all five FSMO roles are assigned to the initial domain controller in the newly created forest root domain. When a new domain is added to an existing forest, only the three domain-level FSMO roles are assigned to the initial domain controller in the newly created domain; the two enterprise-level FSMO roles already exist in the forest root domain.

	FSMO roles often remain assigned to their original domain controllers, but they can be transferred if necessary.

	Schema Master
		This is an enterprise-level FSMO role, there is only one Schema Master in an Active Directory forest.

	Domain Naming Master
		This is an enterprise-level FSMO role, there is only one Domain Naming Master in an Active Directory forest.

	RID Master
		This is a domain-level FSMO role, there is one RID Master in each domain in an Active Directory Forest.

	Infrastructure Master
		This is a domain-level FSMO role, there is one Infrastructure Master in each domain in an Active Directory Forest.

	PDCEmulator
		This is a domain-level FSMO role, there is one PDCE in each domain in an Active Directory Forest.

	https://blog.stealthbits.com/what-are-fsmo-roles-active-directory/
#>
[PSCustomObject]@{
    Name                 = 'FSMORoles'
    InfrastructureMaster = $(Get-ADDomain | Select-Object -ExpandProperty InfrastructureMaster)
    PDCEmulator          = $(Get-ADDomain | Select-Object -ExpandProperty PDCEmulator)
    RIDMaster            = $(Get-ADDomain | Select-Object -ExpandProperty RIDMaster)
    SchemaMaster         = $(Get-ADForest | Select-Object -ExpandProperty SchemaMaster)
    DomainNamingMaster   = $(Get-ADForest | Select-Object -ExpandProperty DomainNamingMaster)
} | Select-Object @{name="PSComputerName";expression={$env:COMPUTERNAME}}, Name, InfrastructureMaster, PDCEmulator, RIDMaster, SchemaMaster, DomainNamingMaster


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUg9YyvqAqKtfjf5oCZGYYrSj3
# 4BegggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUSh14dc349PZKLEqyqoBNKgjfQ58wDQYJKoZI
# hvcNAQEBBQAEggEAknHW+K0tkd7plKHmlzUWhCDoKpA3If1Xks+wOX41fbbk98nE
# dv07cAuq+e6DJIUAnWYwWi3pxAz2v7BUbPLg5a6SYeLrsPvpD6Rk6/Ey6Mfc8gsx
# nc/EjCrSqk7fLNyAS2BtRsyX2uWsQ3htywK9MXjhZmpI0H6o2PzA0dGAZdXLTqTR
# siL1VMuuPQwQ8NUrTOlnvEC5NgE5k4oJwcyxisqwHOFoDiWS4OiCCVGv+LeZ4na7
# +Wk5bqjRwt5HQzlKY2E6it1NQdY10hM8FSiKdG3Z3ygEaKV/xXeNeSN5TtrdaPzq
# fOYqSrWEVz0L41QqVP8R9l0TDJ1Gn/BSVtSdzw==
# SIG # End signature block
