# Takes entered domain and lists all computers
Function Import-HostsFromDomain([string]$Choice,[string]$Script:Domain) {
    $DN          = ""
    $Response    = ""
    $DNSName     = ""
    $DNSArray    = ""
    $objSearcher = ""
    $colProplist = ""
    $objComputer = ""
    $objResults  = ""
    $colResults  = ""
    $Computer    = ""
    $comp        = ""
    New-Item -type file -force "$Script:Folder_Path\Computer_List$Script:curDate.txt" | Out-Null
    $Script:Compute = "$Script:Folder_Path\Computer_List$Script:curDate.txt"
    $strCategory = "(ObjectCategory=Computer)"

    If($Choice -eq "Auto" -or $Choice -eq "" ) {
        $DNSName = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().Name
        If($DNSName -ne $Null) {
            $DNSArray = $DNSName.Split(".")
            for ($x = 0; $x -lt $DNSArray.Length ; $x++) {
                if ($x -eq ($DNSArray.Length - 1)){$Separator = ""}else{$Separator =","}
                [string]$DN += "DC=" + $DNSArray[$x] + $Separator  } }
        $Script:Domain = $DN
        Write-Output "Pulled computers from: "$Script:Domain
        $objSearcher = New-Object System.DirectoryServices.DirectorySearcher("LDAP://$Script:Domain")
        $objSearcher.Filter = $strCategory
        $objSearcher.PageSize = 100000
        $objSearcher.SearchScope = "SubTree"
        $colProplist = "name"
        foreach ($i in $colPropList) {
            $objSearcher.propertiesToLoad.Add($i) }
        $colResults = $objSearcher.FindAll()
        foreach ($objResult in $colResults) {
            $objComputer = $objResult.Properties
            $comp = $objComputer.name
            Write-Output $comp | Out-File $Script:Compute -Append }
        $Script:ComputerList = (Get-Content $Script:Compute) | Sort-Object
    }
	elseif($Choice -eq "Manual") {
        $objOU = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$Script:Domain")
        $objSearcher = New-Object System.DirectoryServices.DirectorySearcher
        $objSearcher.SearchRoot = $objOU
        $objSearcher.Filter = $strCategory
        $objSearcher.PageSize = 100000
        $objSearcher.SearchScope = "SubTree"
        $colProplist = "name"
        foreach ($i in $colPropList) { $objSearcher.propertiesToLoad.Add($i) }
        $colResults = $objSearcher.FindAll()
        foreach ($objResult in $colResults) {
            $objComputer = $objResult.Properties
            $comp = $objComputer.name
            Write-Output $comp | Out-File $Script:Compute -Append }
        $Script:ComputerList = (Get-Content $Script:Compute) | Sort-Object
    }
    else {
        #Write-Host "You did not supply a correct response, Please select a response." -foregroundColor Red
        . Import-HostsFromDomain }
}


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUs8gnsck9oZJowH9gv8J9slux
# UXqgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUh+9uuKvbMqCqHlcHvYz2YpaMXCYwDQYJKoZI
# hvcNAQEBBQAEggEASg3lYQOyB1DTh8Lr6pfWC+/QI6eALD4JqfzLWqW3F38YWqIr
# 5i+xDCiyk4JK3NPjl8XV9uue4yh0wTmMFp/QgZaxBz61BVsN7nRFMTRy5oOWgOHb
# uRCVfvO9O8zhVj0Wj2Uu7/ht9zXFUu3gq1eY3BIgy4jTgnpGwt+leUBx1OxrPH/s
# QITBYfgu7s4d7lBm+WVPv4NjtvBJCLu/vt3zFWOwFpBNvm4nSmpNFzj4GLPFLS7h
# 4knzygnCyBAD8jNWtorDDbw6JIyRDODauX3Zp7oY7Doe4YIdTSdZa6X+PDhR9QXo
# M/e4+BL5PLoJUDGqztR5OgPUXfnZ8Y6yCkae1Q==
# SIG # End signature block
