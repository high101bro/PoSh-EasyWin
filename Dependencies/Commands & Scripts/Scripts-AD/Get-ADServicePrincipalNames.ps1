<#
    .SYNOPSIS
        Get Service Principal Names

    .DESCRIPTION
        Get Service Principal Names

        Output includes:
            ComputerName - SPN Host
            Specification - SPN Port (or Instance)
            ServiceClass - SPN Service Class (MSSQLSvc, HTTP, etc.)
            sAMAccountName - sAMAccountName for the AD object with a matching SPN
            SPN - Full SPN string

    .PARAMETER ComputerName
        One or more hostnames to filter on.  Default is *

    .PARAMETER ServiceClass
        Service class to filter on.

        Examples:
            HOST
            MSSQLSvc
            TERMSRV
            RestrictedKrbHost
            HTTP

    .PARAMETER Specification
        Filter results to this specific port or instance name

    .PARAMETER SPN
        If specified, filter explicitly and only on this SPN.  Accepts Wildcards.

    .PARAMETER Domain
        If specified, search in this domain. Use a fully qualified domain name, e.g. contoso.org

        If not specified, we search the current user's domain

    .EXAMPLE
        Get-Spn -ServiceType MSSQLSvc

        #This command gets all MSSQLSvc SPNs for the current domain

    .EXAMPLE
        Get-Spn -ComputerName SQLServer54, SQLServer55

        #List SPNs associated with SQLServer54, SQLServer55

    .EXAMPLE
        Get-SPN -SPN http*

        #List SPNs maching http*

    .EXAMPLE
        Get-SPN -ComputerName SQLServer54 -Domain Contoso.org

        # List SPNs associated with SQLServer54 in contoso.org

    .NOTES
        Adapted from
            http://www.itadmintools.com/2011/08/list-spns-in-active-directory-using.html
            http://poshcode.org/3234
        Version History
            v1.0   - Chad Miller - Initial release
            v1.1   - ramblingcookiemonster - added parameters to specify service type, host, and specification
            v1.1.1 - ramblingcookiemonster - added parameterset for explicit SPN lookup, added ServiceClass to results

    .FUNCTIONALITY
        Active Directory
#>

[cmdletbinding(DefaultParameterSetName='Parse')]
param(
    [Parameter( Position=0,
                ValueFromPipeline=$true,
                ValueFromPipelineByPropertyName=$true,
                ParameterSetName='Parse' )]
    [string[]]$ComputerName = "*",

    [Parameter(ParameterSetName='Parse')]
    [string]$ServiceClass = "*",

    [Parameter(ParameterSetName='Parse')]
    [string]$Specification = "*",

    [Parameter(ParameterSetName='Explicit')]
    [string]$SPN,

    [string]$Domain
)

#Set up domain specification, borrowed from PyroTek3
#https://github.com/PyroTek3/PowerShell-AD-Recon/blob/master/Find-PSServiceAccounts
    if(-not $Domain)
    {
        $ADDomainInfo = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
        $Domain = $ADDomainInfo.Name
    }
    $DomainDN = "DC=" + $Domain -Replace("\.",',DC=')
    $DomainLDAP = "LDAP://$DomainDN"
    Write-Verbose "Search root: $DomainLDAP"

#Filter based on service type and specification.  For regexes, convert * to .*
    if($PsCmdlet.ParameterSetName -like "Parse")
    {
        $ServiceFilter = If($ServiceClass -eq "*"){".*"} else {$ServiceClass}
        $SpecificationFilter = if($Specification -ne "*"){".$Domain`:$specification"} else{"*"}
    }
    else
    {
        #To use same logic as 'parse' parameterset, set these variables up...
            $ComputerName = @("*")
            $Specification = "*"
    }

#Set up objects for searching
    $SearchRoot = [ADSI]$DomainLDAP
    $searcher = New-Object System.DirectoryServices.DirectorySearcher
    $searcher.SearchRoot = $SearchRoot
    $searcher.PageSize = 1000

#Loop through all the computers and search!
foreach($computer in $ComputerName)
{
    #Set filter - Parse SPN or use the explicit SPN parameter
    if($PsCmdlet.ParameterSetName -like "Parse")
    {
        $filter = "(servicePrincipalName=$ServiceClass/$computer$SpecificationFilter)"
    }
    else
    {
        $filter = "(servicePrincipalName=$SPN)"
    }
    $searcher.Filter = $filter

    Write-Verbose "Searching for SPNs with filter $filter"
    foreach ($result in $searcher.FindAll()) {

        $account = $result.GetDirectoryEntry()
        foreach ($servicePrincipalName in $account.servicePrincipalName.Value) {

            #Regex will capture computername and port/instance
            if($servicePrincipalName -match "^(?<ServiceClass>$ServiceFilter)\/(?<computer>[^\.|^:]+)[^:]*(:{1}(?<port>\w+))?$") {

                #Build up an object, get properties in the right order, filter on computername
                New-Object psobject -property @{
                    ComputerName=$matches.computer
                    Specification=$matches.port
                    ServiceClass=$matches.ServiceClass
                    sAMAccountName=$($account.sAMAccountName)
                    SPN=$servicePrincipalName
                } |
                    Select-Object ComputerName, Specification, ServiceClass, sAMAccountName, SPN |
                    #To get results that match parameters, filter on comp and spec
                    Where-Object {$_.ComputerName -like $computer -and $_.Specification -like $Specification}
            }
        }
    }
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU2YHawJhBN4+OKW/q9tbisl1l
# KVugggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUE62ZCV5LwqHKMv9mZAYTv9j0LMgwDQYJKoZI
# hvcNAQEBBQAEggEADkNbKDEuHD8u6C4yJM3uU5vxcmyLtb5X9jYSXyn1HeFeYOMg
# 6SxlYQ/j727beMFqnrzOAfBv4AUcazcvt//z5IkWCexLTcqcPEYWofJ77g31MRi3
# 2Qoxw4/eJP3jobd6wn8UF28/VqOL2+7mXQ+nGrH5vIDZrgN+jp7b9OGexE7k76yn
# 6D6oAandevmfz2VUrnS8uNzUO5XVun5cDm1EEuyjOHUeh1OUWK0CTUvYz5sgzJud
# Z4mxXSVjiiPibew5rKhZ4dIiFSeS4Fpwh34vEy1uNPnJwOSr+t62e5gtYVgjfbkH
# ECgG2+2Ia89m6oRBYeuZ7ZGZSqiOW3SanlpjWw==
# SIG # End signature block
