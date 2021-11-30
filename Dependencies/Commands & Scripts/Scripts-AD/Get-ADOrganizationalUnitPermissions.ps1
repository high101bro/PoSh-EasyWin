            # This array will hold the report output.
            $report = @()

            $schemaIDGUID = @{}
            ### NEED TO RECONCILE THE CONFLICTS ###
            $ErrorActionPreference = 'SilentlyContinue'
            Get-ADObject -SearchBase (Get-ADRootDSE).schemaNamingContext -LDAPFilter '(schemaIDGUID=*)' -Properties name, schemaIDGUID |
             ForEach-Object {$schemaIDGUID.Add([System.GUID]$_.schemaIDGUID,$_.name)}
            Get-ADObject -SearchBase "CN=Extended-Rights,$((Get-ADRootDSE).configurationNamingContext)" -LDAPFilter '(objectClass=controlAccessRight)' -Properties name, rightsGUID |
             ForEach-Object {$schemaIDGUID.Add([System.GUID]$_.rightsGUID,$_.name)}
            $ErrorActionPreference = 'Continue'

            # Get a list of all OUs.  Add in the root containers for good measure (users, computers, etc.).
            $OUs  = @(Get-ADDomain | Select-Object -ExpandProperty DistinguishedName)
            $OUs += Get-ADOrganizationalUnit -Filter * | Select-Object -ExpandProperty DistinguishedName
            $OUs += Get-ADObject -SearchBase (Get-ADDomain).DistinguishedName -SearchScope OneLevel -LDAPFilter '(objectClass=container)' | Select-Object -ExpandProperty DistinguishedName

            # Loop through each of the OUs and retrieve their permissions.
            # Add report columns to contain the OU path and string names of the ObjectTypes.
            ForEach ($OU in $OUs) {
                $report += Get-Acl -Path "AD:\$OU" |
                 Select-Object -ExpandProperty Access |
                 Select-Object @{name='organizationalUnit';expression={$OU}}, `
                               @{name='objectTypeName';expression={if ($_.objectType.ToString() -eq '00000000-0000-0000-0000-000000000000') {'All'} Else {$schemaIDGUID.Item($_.objectType)}}}, `
                               @{name='inheritedObjectTypeName';expression={$schemaIDGUID.Item($_.inheritedObjectType)}}, `
                               *
            }
            $report | Select OrganizationalUnit, IdentityReference, ObjectTypeName, InheritedObjectTypeName, ActiveDirectoryRights, InheritanceType, AccessControlType, IsInherited, InheritanceFlags, ProgationFlags, ObjectType, InheritedObjectType, ObjectFlags

            <#
            # Various reports of interest

            # Show only explicitly assigned permissions by Group and OU
            $report |
             Where-Object {-not $_.IsInherited} |
             Select-Object IdentityReference, OrganizationalUnit -Unique |
             Sort-Object IdentityReference

            # Show explicitly assigned permissions for a user or group
            $filter = Read-Host "Enter the user or group name to search in OU permissions"
            $report |
             Where-Object {$_.IdentityReference -like "*$filter*"} |
             Select-Object IdentityReference, OrganizationalUnit, IsInherited -Unique |
             Sort-Object IdentityReference
             #>


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUkrUOigEd/MoitJz+TABWkiyH
# 1SygggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU1sBEITCVqpgxzttKg2mS+GZOaQUwDQYJKoZI
# hvcNAQEBBQAEggEA0s5duWKPnLNxLGfZm7l7SO2zpKqBTDJ/85YpgzSpNypWWT+I
# 1r9HxCBCe9zmq4evu1Y5yKIcEIKjyraDZV3qhwuZ2MuNkC07MI4eclkpDmIeblHl
# J4xsODpNLotKPQNRLP4v4AYMVR1Dn34wNmBcr2xZPhvHz9SrQURwp25z+fYw8Hg9
# Xy5m0zN+7iVSuq+zRoITs3/PrD9/LnT5e0isyQ3hf9kV+5kBass3oi0DaB8gyzGt
# 8SY/cJgauVOUeqmQmaXDBNhynNFseWGGjjledeI3SAdYUF/dX59HeC9NIgid0Pdx
# aDtA66nfu1vjjMT+3Vxc+VeyXZ1SpyJRBI1qXQ==
# SIG # End signature block
