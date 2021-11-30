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
    
        If you have a list of critical local security groups in the organization, and need to specifically monitor these groups for any access (in this case, enumeration of group membership), monitor events with the “Group\Group Name” values that correspond to the critical local security groups. Examples of critical local groups are built-in local administrators, built-in backup operators, and so on.

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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU4PloIkWJvgWXTx3IfErQJMru
# wAigggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU+ij8zGJn2rf8kZqIX/zUrPeBbZwwDQYJKoZI
# hvcNAQEBBQAEggEAnpZ2uVXIoZyWU0zzbbGs4n1Ob8ywnUJ0rKaRgk/s3CPj8zDe
# hGEeyK35nqIbebg4c0Aprbv7QP+nLye5Jhv4CpZ8qxMV6VdH9+kn0IrOiXIvWadj
# cN83kVTkDql9SZwrlV4tb0WXV6mxCCkvQ3MG4pL3rJ9pInS2i81NEWLqfHC4b9JO
# /iMkXJuRA0uZTsYOMxxYi10xnPdGbESfYlmDrJD3A7yNDC2XAZP9XnWrw1+gMqY4
# +o3UxgMNGiTkltdsc7gTnUwHN9DNeXQAL/6+EWxxqdawn1Uxbc5giU/V41KDIJaa
# NSxFhLeXzPV448QD+6ADn/FNucp6WZfVsZ11fA==
# SIG # End signature block
