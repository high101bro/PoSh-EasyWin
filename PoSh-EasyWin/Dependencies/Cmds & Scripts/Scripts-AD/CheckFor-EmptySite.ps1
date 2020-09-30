<#
.Description
    An empty site is generally not recommended. The term describes a site without any Domain Controllers.
    A site of this sort has two possible reasons for existing � Microsoft SCCM product used for software
    distribution and other management tools to help identify something in Active directory for end users
    or application use. In general this isn�t an issue, but if they are not needed, removing them is a
    good practice. Less for Active directory to replicated to existing Domain Controllers in other sites.
#>

$DomainControllers = (Get-ADDomainController -Filter *).Name
Foreach ($DomainController in $DomainControllers) {
    # Set up variables for the loop:
    $Query = $True
    $AutoGenerated = $Null

    # Get a list of links for this Domain Controller:
    Try {
        $Links = Get-ADReplicationConnection -Server $DomainController -ErrorAction STOP
    } Catch {
        Write-host 'Failed - Unable to query links.' -ForegroundColor Red
        $Query = $False
    }

    # Check each set of links to analyze the ones for each Domain Controller:
    If ($Query) {
        Foreach ($Line in $Links) {
            # Fix Values
            $Name = $Line.Name
            $Autogenerated= $Line.Autogenerated
            $ReplicateFromDirectoryServer = $Line.ReplicateFromDirectoryServer
            $ReplicateToDirectoryServer = $Line.ReplicateToDirectoryServer
            $FromLarge = $ReplicateFromDirectoryServer.Split(',')[1]
            $ToLarge = $ReplicateToDirectoryServer.Split(',')[0]
            $FinalFrom = $FromLarge.Split('=')[1]
            $FinalTo = $ToLarge.Split('=')[1]
            $SiteLarge = $Line.DistinguishedName.Split(',')[4]
            $Site = $SiteLarge.Split('=')[1]
            $Row = "$DomainController,$Site,$Name,$Autogenerated,$FinalFrom,$FinalTo" | Out-File $ADReplicationConnectionDestination -Append
        }
    } Else {
        Write-host '  Domain Controller with no Links found - ' -ForegroundColor White -NoNewline
        Write-Host "$DomainController" -ForegroundColor Yellow -NoNewline
        Write-Host ' - is this Domain Controller needed?' -ForegroundColor White
        $Row = "$DomainController,NoLink,,,," | Out-File $ADReplicationConnectionDestination -Append
    }
}

