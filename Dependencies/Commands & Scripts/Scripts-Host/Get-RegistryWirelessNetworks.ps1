function Get-WirelessNetworks {
    $RegistryPath     = "Registry::HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles\"
    $RegistryKeyNames = Get-ChildItem -Name $RegistryPath
    $Data = @()
    foreach ($Key in $RegistryKeyNames){
        $KeyPath = $RegistryPath + $Key
        $KeyProperty = get-itemproperty -Path $KeyPath

        $DateCreated = $KeyProperty.DateCreated
          $DC_Hexes  = [System.BitConverter]::ToString($KeyProperty.datecreated) -split '-'
          $DC_Year   = [Convert]::ToInt32($DC_Hexes[1]+$DC_Hexes[0],16)
          $DC_Month  = [Convert]::ToInt32($DC_Hexes[3]+$DC_Hexes[2],16)
          $DC_Day    = [Convert]::ToInt32($DC_Hexes[7]+$DC_Hexes[6],16)
          $DC_Hour   = [Convert]::ToInt32($DC_Hexes[9]+$DC_Hexes[8],16)
          $DC_Minute = [Convert]::ToInt32($DC_Hexes[11]+$DC_Hexes[10],16)
          $DC_Second = [Convert]::ToInt32($DC_Hexes[13]+$DC_Hexes[12],16)
          $DateCreatedFormatted = [datetime]"$DC_Month/$DC_Day/$DC_Year $DC_Hour`:$DC_Minute`:$DC_Second"

        $DateLastConnected = $KeyProperty.DateLastConnected
          $DLC_Hexes  = [System.BitConverter]::ToString($KeyProperty.DateLastConnected) -split '-'
          $DLC_Year   = [Convert]::ToInt32($DLC_Hexes[1]+$DLC_Hexes[0],16)
          $DLC_Month  = [Convert]::ToInt32($DLC_Hexes[3]+$DLC_Hexes[2],16)
          $DLC_Day    = [Convert]::ToInt32($DLC_Hexes[7]+$DLC_Hexes[6],16)
          $DLC_Hour   = [Convert]::ToInt32($DLC_Hexes[9]+$DLC_Hexes[8],16)
          $DLC_Minute = [Convert]::ToInt32($DLC_Hexes[11]+$DLC_Hexes[10],16)
          $DLC_Second = [Convert]::ToInt32($DLC_Hexes[13]+$DLC_Hexes[12],16)
          $DateLastConnectedFormatted = [datetime]"$DLC_Month/$DLC_Day/$DLC_Year $DLC_Hour`:$DLC_Minute`:$DLC_Second"

        $Data += [PSCustomObject]@{
		 "PSComputerName"   = $env:ComputerName
            "SSID"             = $KeyProperty.Description
            "ProfileName"      = $KeyProperty.ProfileName
            "DateCreated"      = $DateCreatedFormatted
            "DateLastConnected"= $DateLastConnectedFormatted
        }
    }
    $Data
}
Get-WirelessNetworks | Select-Object -Property PSComputerName, SSID, ProfileName, DateCreated, DateLastConnected

