Function Get-ADTrustsInfo {
    <#
    .SYNOPSIS
        Query AD for all trusts in the specified domain and check their state.
    .DESCRIPTION
        This cmdlet query AD and return a custom object with informations suach as the trust name, the creation date, the last modification date, the direction, the type, the SID of the trusted domain, the trusts attributes, and the trust state.
    #>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$false,
            HelpMessage='Provide a domain name !')]
        [ValidateScript({Test-Connection $_ -Count 1 -Quiet})]
        [String]$DomainName=$env:USERDNSDOMAIN
    )
    Begin{
    }
    Process{
        $searcher=[ADSIsearcher]"(objectclass=trustedDomain)"
        $searcher.searchroot.Path="LDAP://$DomainName"
        $searcher.PropertiesToLoad.AddRange(('whenChanged','whenCreated','trustPartner','trustAttributes','trustDirection','trustType','securityIdentifier')) | Out-Null
        Write-Verbose "Searching in AD for trusts..."
        try {
            $trusts=$searcher.FindAll()
            $trusts | % {
                switch ($_.Properties.trustdirection)
                {
                        1 {$TrustDirection="Inbound"}
                        2 {$TrustDirection="Outbound"}
                        3 {$TrustDirection="Bidirectional"}
                        default {$TrustDirection="N/A"}
                }
                switch ($_.Properties.trusttype)
                {
                    1 {$TrustType="Windows NT"}       #Downlevel (2000 et inférieur)
                    2 {$TrustType="Active Directory"} #Uplevel (2003 et supérieur)
                    3 {$TrustType="Kerberos realm"}   #Not AD Based
                    4 {$TrustType="DCE"}
                    default {$TrustType="N/A"}
                }
                #Convertion du System.Byte[] en SID lisible.
                Write-Verbose "Converting the SID..."
                $SID=(New-Object -TypeName System.Security.Principal.SecurityIdentifier -ArgumentList $_.properties.securityidentifier[0], 0).value
                Write-Verbose "Querying WMI..."
                $wmitrust=Get-WmiObject -namespace "root/MicrosoftActiveDirectory" -class Microsoft_DomainTrustStatus -ComputerName $DomainName -Filter "SID='$SID'"

                [String[]]$TrustAttributes=$null
                if([int32]$_.properties.trustattributes[0] -band 0x00000001){$TrustAttributes+="Non Transitive"}
                if([int32]$_.properties.trustattributes[0] -band 0x00000002){$TrustAttributes+="UpLevel"}
                if([int32]$_.properties.trustattributes[0] -band 0x00000004){$TrustAttributes+="Quarantaine"} #SID Filtering
                if([int32]$_.properties.trustattributes[0] -band 0x00000008){$TrustAttributes+="Forest Transitive"}
                if([int32]$_.properties.trustattributes[0] -band 0x00000010){$TrustAttributes+="Cross Organization"}#Selective Auth
                if([int32]$_.properties.trustattributes[0] -band 0x00000020){$TrustAttributes+="Within Forest"}
                if([int32]$_.properties.trustattributes[0] -band 0x00000040){$TrustAttributes+="Treat as External"}
                if([int32]$_.properties.trustattributes[0] -band 0x00000080){$TrustAttributes+="Uses RC4 Encryption"}
                #http://msdn.microsoft.com/en-us/library/cc223779.aspx
                Write-Verbose "Constructing object..."
                $Object = New-Object PSObject -Property @{
                    'TrustName'      = $($_.Properties.trustpartner)
                    'Created'        = $($_.Properties.whencreated)
                    'LastChanged'    = $($_.Properties.whenchanged)
                    'Direction'      = $TrustDirection
                    'Type'           = $TrustType
                    'DomainSID'      = $SID
                    'Status'         = $wmitrust.TrustStatusString
                    'Attributes'     = $TrustAttributes -join ','
                }#End object
                Write-Output $Object
            }#End trusts %
        }catch {Write-Warning "$_" }
    }#End process
    End{
    }
}
Get-ADTrustsInfo | Select-Object @{name="PSComputerName";expression={$env:COMPUTERNAME}}, Created, TrustName, Type, Direction, Attributes, LastChanged, Status, DomainSID


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUyW1JjiqBr5/Z7YgAFmAotnHW
# yLigggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUdcw5btlaJs+NqqhqJisbqV/9Q1AwDQYJKoZI
# hvcNAQEBBQAEggEAYswXwr2vZ2Dip/4Suzh6FgQEgitdSwSb9OXOnKBAFEb25A+g
# QDtXO9IZta1pP8gfY3rKQ36Qht6GxQkPaIgEXie6ZCJ2OLS+ieCPNR8EkWUgXnEq
# 9IBSg5njZ/t1GAlS669IGKPIamFdk1ITC2S8X4+d0GW8ReXz8W6/29RQa6TERsP6
# uK0a9g7k5u0LW7nmtF12OWEfsgLjibMu6U76klH8nt5InySlktKPRjgEnSkQQDr3
# p58dQFK/9RbO6rg+Dicwv21mwNN23tbOZkscq0r6K6H2vMi35Lxm0tT45BUD5dBc
# Lfk2JV5DOu5iejKfM9nX3gXi+fDsIbPVPhSXDQ==
# SIG # End signature block
