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
# KVugggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUE62ZCV5LwqHKMv9mZAYTv9j0LMgwDQYJKoZI
# hvcNAQEBBQAEggEAeZBYn6GOO3aY6qg/1JtVmhhq9tRGuGnbiwRjSqx6VS4rB6d5
# XcXJxMnGybVSL+Tc8R2Dh8MPL7Aj4spoWoE0xuHNnqNRleaZTIsTls0WMhVmCGt8
# ewfrOEB7hHhJh5CaTt+LqJhhTg71njOOMK1xNJfI3UlgW1kzye3kJn9qLh3uqP8X
# asuG/068Y4lg9SoBq7VHzMuud+JaHXPSd+2x7Ts2+purk0B27wu/d00hmdNaOTLF
# HpXyxi8JcUnX4KndzKcp4tLykeUziwYoE8TZZIyp3EbEnXDTTeM2ME3n3U5MhgTP
# NSpPIPbyx1Y+Ajc7d3nQEtmMp6bORDeAZ3E8WQ==
# SIG # End signature block
