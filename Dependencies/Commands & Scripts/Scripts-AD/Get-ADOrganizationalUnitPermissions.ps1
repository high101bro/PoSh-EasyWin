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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUEcl0kdm/JXR2tP+lRHqnFbMu
# GfGgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUJBCmghwV1P9s0pwxshX0tJ7igWMwDQYJKoZI
# hvcNAQEBBQAEggEAS319FhB9PCJxuVIogjrEEDzOcJs5xJ/ADe8x/7iZidM1Yjn1
# zSL6Vxqvg+RZfjCiXk8pJxjb/9p+yn1Lht7BA82i2gOh2Gfg8tr3XCOBHtInndCI
# eHaUxkMaayOzGGmDE8AtRgMi+7gbDTD/XDSJPRVo/VMKls4xy8wTEDu1YhKUUBHJ
# NIPo8yqkG5Rs3M0TQficWWi3ciYmNQGfHK3+WCjy608YxagnhDc6pDLs3Z7ftFhH
# 3TL+35EMal2nocPZimo80BqYZGpEE2iGa2EPW8tKAmOYZfdlu68+0f6uSYIRBSi/
# CCYBiLFltxi0nh8pVl8XubfAIUJ2/7UoW6Da+A==
# SIG # End signature block
