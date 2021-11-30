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
# 4BegggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUSh14dc349PZKLEqyqoBNKgjfQ58wDQYJKoZI
# hvcNAQEBBQAEggEAw80uSBr3Ia5MibYyzjvd02SFrLKFpFKjHPE7c+DpMTSY0p2p
# oMpavJ49ILTaid9av+5tzF+WONfL6snWVsoilXPMbWAKD+veiXSN+DRG/8l5geyD
# VhabENyxvzZXWQSbt5aFtsBWpCer6UJpgUpDYIxpekrXyThxCGh380ZUBtePJp+1
# LSRPorykomQyp68K/qtF2CwEJKhWnp3MYYY0VhuvOwGTkFeMOsNl1nrSTyLmM/gO
# EhOeA39q3jOoxmdLEPiz51T8JZapeVR7DqlVNsNR1W0+FzOK3eX1ujE8NZv9RY7u
# Bb8AZ76C6f9rgaVdA/DL4N9+me5uGNyGp++ekg==
# SIG # End signature block
