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
                    1 {$TrustType="Windows NT"}       #Downlevel (2000 et inf�rieur)
                    2 {$TrustType="Active Directory"} #Uplevel (2003 et sup�rieur)
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUBsRyGShi9lJ8TdNSrBGW2ybO
# vMigggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUfNVaCQj7teYN7HoMKdrl0uuTIJ0wDQYJKoZI
# hvcNAQEBBQAEggEAAzNzTJcw7/xf3M70aBQrXj02cWzvyr5Ya+zYqMhQXvrILcF5
# qGWV01BX+oD3Txk08/sodZP5u52i++F1xlg/ZZmmHiLJ9YcUPIurAdw1lp1gme0t
# 8q2e28QsqDYJweXs5KNT45UrA0sb15BKXCi52Dnp4YliTFZnc05cFoCJS5EgR2A9
# 8Il81x90hnlIDik9/b5K7+DOteycFIMWJla/Z4trI6VmApwoRSOJJ+I+6wiaQAvC
# HbX/a81mDdBVgqdHSskHYm5YRrU0SPZeMx1KagcH0j3x5gUuGVviIZMTdKE6WD7H
# Y53MbneuwY0Tl4J3C5xmfQ0lpzxWZ8ajOweYSg==
# SIG # End signature block
