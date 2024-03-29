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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUefBt+53GY6VCyokTX8FKRHu9
# XVygggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUCH4udROG73y/xke2l5Rdjk83bEIwDQYJKoZI
# hvcNAQEBBQAEggEADvT+hnfIhbiTpzHDVX6KnvfpHVY8RUztqSvtoMXm0LGf38WH
# Fb2JfVa5jwp8g/CYp2s5Y784QYIO41H2c3izxx+8mJ6H2a5qXR2QKCk09cqrhp1y
# d4jrT8F+v/+DuNLmAnwprOjn5Mrp3fr6jW9KbfplivR6ss1eR1A3+otMdZTL4jSe
# xm0SOaXJ8RW7/MKUxmfUrtf5Qj/aGA8HeQrqdDs3aTDKHIYiztfqc+BMPZNL2NEq
# ZYpln7TuFmSmFyfgktcfJN/FPamlZepvAeDVuMgiSXrd+qWMZpegtHx5kjX6NG7V
# MriNOJ1qLUOJOkxVTWAWshHdO4SQY6ZlrKtQiQ==
# SIG # End signature block
