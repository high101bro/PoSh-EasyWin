<#
    .SYNOPSIS
    Compiles information about firewall rules.

    .DESCRIPTION
    Creates enriched firewall rule objects from multiple cmdlets:
        Get-NetFirewallRule
        Get-NetFirewallAddressFilter
        Get-NetFirewallPortFilter
        Get-NetFirewallApplicationFilter
        Get-NetFirewallServiceFilter
        Get-NetFirewallInterfaceFilter
        Get-NetFirewallInterfaceTypeFilter
        Get-NetFirewallSecurityFilter

    .NOTES
    Updated:    High101Bro
    Build Date: 2020/03/20
#>

function Get-EnrichedFirewallRules {
    Param(
        $Name = "*",
        [switch]$Verbose
    )

    #Requires -Version 4.0

    # convert Stringarray to comma separated liste (String)
    function StringArrayToList($StringArray) {
        if ($StringArray) {
            $Result = ""
            Foreach ($Value In $StringArray) {
                if ($Result -ne "") { $Result += "," }
                $Result += $Value
            }
            return $Result
        }
        else {
            return ""
        }
    }
    $FirewallRules = Get-NetFirewallRule -DisplayName $Name -PolicyStore "ActiveStore"
    $FirewallRuleSet = @()
    ForEach ($Rule In $FirewallRules) {
        if ($Verbose) { Write-Output "Processing rule `"$($Rule.DisplayName)`" ($($Rule.Name))" }

        $AdressFilter        = $Rule | Get-NetFirewallAddressFilter
        $PortFilter          = $Rule | Get-NetFirewallPortFilter
        $ApplicationFilter   = $Rule | Get-NetFirewallApplicationFilter
        $ServiceFilter       = $Rule | Get-NetFirewallServiceFilter
        $InterfaceFilter     = $Rule | Get-NetFirewallInterfaceFilter
        $InterfaceTypeFilter = $Rule | Get-NetFirewallInterfaceTypeFilter
        $SecurityFilter      = $Rule | Get-NetFirewallSecurityFilter

        # Created Enriched Object
        $HashProps = [PSCustomObject]@{
            Name                = $Rule.Name
            DisplayName         = $Rule.DisplayName
            Description         = $Rule.Description
            Group               = $Rule.Group
            Enabled             = $Rule.Enabled
            Profile             = $Rule.Profile
            Platform            = StringArrayToList $Rule.Platform
            Direction           = $Rule.Direction
            Action              = $Rule.Action
            EdgeTraversalPolicy = $Rule.EdgeTraversalPolicy
            LooseSourceMapping  = $Rule.LooseSourceMapping
            LocalOnlyMapping    = $Rule.LocalOnlyMapping
            Owner               = $Rule.Owner
            LocalAddress        = StringArrayToList $AdressFilter.LocalAddress
            RemoteAddress       = StringArrayToList $AdressFilter.RemoteAddress
            Protocol            = $PortFilter.Protocol
            LocalPort           = StringArrayToList $PortFilter.LocalPort
            RemotePort          = StringArrayToList $PortFilter.RemotePort
            IcmpType            = StringArrayToList $PortFilter.IcmpType
            DynamicTarget       = $PortFilter.DynamicTarget
            Program             = $ApplicationFilter.Program -Replace "$($ENV:SystemRoot.Replace("\","\\"))\\", "%SystemRoot%\" -Replace "$(${ENV:ProgramFiles(x86)}.Replace("\","\\").Replace("(","\(").Replace(")","\)"))\\", "%ProgramFiles(x86)%\" -Replace "$($ENV:ProgramFiles.Replace("\","\\"))\\", "%ProgramFiles%\"
            Package             = $ApplicationFilter.Package
            Service             = $ServiceFilter.Service
            InterfaceAlias      = StringArrayToList $InterfaceFilter.InterfaceAlias
            InterfaceType       = $InterfaceTypeFilter.InterfaceType
            LocalUser           = $SecurityFilter.LocalUser
            RemoteUser          = $SecurityFilter.RemoteUser
            RemoteMachine       = $SecurityFilter.RemoteMachine
            Authentication      = $SecurityFilter.Authentication
            Encryption          = $SecurityFilter.Encryption
            OverrideBlockRules  = $SecurityFilter.OverrideBlockRules
        }
        $FirewallRuleSet += $HashProps
    }
    return $FirewallRuleSet
}
Get-EnrichedFirewallRules



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUoxZVruhZwkVIqWOyF9IAAINp
# b1igggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUsQXUWLj8WIOrFP0rMHZkeyEbJ24wDQYJKoZI
# hvcNAQEBBQAEggEAKpNEvmiMOjBlE9gJVyFqsvc2iePa2sAfV/qGckZ4ElV2A4lw
# DJwDuvbbJyPLBMt3SoP7Js7U3e9GL1PaDPRsYX9vSwEXHOj5pcKSvuvfJsd2T2tq
# NlEps0XBj0SN6eD5v9QSiIYPi13fSrIuu+INVX5fniQnMV7+ZExyQck/PDXDRhof
# 6Aq7phps4YCZJffHQ2pqGexvULyn2Gq6FGootZQGRTw8YZRHoL1k5ptQ9KAnpK3p
# arrzbS1huW2XWk9uWVQVYdhjkPGm2gXeMn+/0TXtXt78eWTL4DMlLU0L19psJwIg
# xZRQWc8ju/w5C0aAj/qgLuqwGYIuoB1uHvJ07w==
# SIG # End signature block
