<#
    .SYNOPSIS
    A security-enabled local group membership was enumerated

    .DESCRIPTION
    Subcategory:

        Audit Security Group Management

    Event Description:

        This event generates when a process enumerates the members of a security-enabled local group on the computer or device.

        This event doesn't generate when group members were enumerated using Active Directory Users and Computers snap-in.

    Recommendations:

        If you have a list of critical local security groups in the organization, and need to specifically monitor these groups for any access (in this case, enumeration of group membership), monitor events with the â€œGroup\Group Nameâ€ values that correspond to the critical local security groups. Examples of critical local groups are built-in local administrators, built-in backup operators, and so on.

        If you need to monitor each time the membership is enumerated for a local or domain security group, to see who enumerated the membership and when, monitor this event. Typically, this event is used as an informational event, to be reviewed if needed.

    .EXAMPLE
    None
    .LINK
    https://github.com/high101bro/PoSh-EasyWin
    .NOTES
    None
#>

Get-WinEvent -FilterHashtable @{LogName='Security';Id=4799} `
| Where-Object {$_.Properties[8].Value -ne 'Registry'} `
| Select-Object @{n='GroupName';e={$_.Properties[0].value}},@{n='CreatorProcess';e={$_.Properties[8].Value}}  `
| Group-Object -Property GroupName, CreatorProcess `
| Select-Object -Property Count, Name

<# Deprecated
Get-WinEvent -FilterHashtable @{LogName='Security';Id=4799} `
| Where-Object {$_.Properties[8].Value -ne 'Registry'} `
| Select-Object @{n='CreatorProcess';e={$_.Properties[8].Value}} `
| Group-Object -Property CreatorProcess
#>









# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUL1J4/tuagM2+kvSnh6+k298R
# ITugggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUBZIbLkh40VROZtRiML0u06PpWmwwDQYJKoZI
# hvcNAQEBBQAEggEAuIjx8lQu9ytrNO9brFOdNyOpSw6yXk4ggpMM5XW5wElWzPCA
# SKQlUHMR0ReVajG+/OZFaIEH0gKXjyIlnmZ04Nb8sewA8CMmDoruHaSekT6NhCYX
# I/EfGrPHNb/YjrH7ETjmiMd9gYpeXQ9e9oJmsPFnNh1jdmWMIC7OH0YjZadrmzK2
# z7rLLnwcpMsyAG2WMI3IcRoT6noHpHkovSBOXMK9J5bkubS4s+Zv6vqwKOnUAu27
# DcoziP3mvXm//vNXdP3WdOZJbisEOmXEy2RUBrKv1GGU6Dux3lO0t6VWCBbP+m2H
# dzKhMwS0tyzEz96Fj937rCiZlzJuOyDByFf3vA==
# SIG # End signature block
