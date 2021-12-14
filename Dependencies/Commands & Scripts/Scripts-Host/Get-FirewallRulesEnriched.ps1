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
# b1igggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUsQXUWLj8WIOrFP0rMHZkeyEbJ24wDQYJKoZI
# hvcNAQEBBQAEggEALue+IWqavmbcDOaAx9Tp5jlZ7D3FcG8vnDQop9TiGkrPXMEW
# /wUv2l6xRqQJQYaSe1bh8PRW9FrW5+GiqEZuZYZsAAMreVL51sAVuYG7W3fF2RT5
# F7CTQ6+swbqian+xkJSs0mDhOdNyxBAhqTxqz/NOist6y2QT21Jg9nI1OSwA4bzN
# KsjM680yUeuwrKxMB0aun6D+GPrP/HipWHWU8CvyBsYX1ls+P7ITZQgKmxKogfQt
# IWqp3F3px52JDu0pXQKzNLSO0RuMzAIWRVf12PlniIYVdB93BLPmMisgWuEy6oVN
# BIUPWa5IvE/cClPN2+QwPYw/VSE+sBvEkHuRFg==
# SIG # End signature block
