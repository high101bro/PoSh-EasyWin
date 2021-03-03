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


