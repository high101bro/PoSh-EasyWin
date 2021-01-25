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

