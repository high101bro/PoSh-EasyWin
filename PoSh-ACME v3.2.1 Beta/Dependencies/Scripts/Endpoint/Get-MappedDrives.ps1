<#
.Description

	This script gets the Logical Dives mapped to the computer. It translates the drivetype something user readible.
	This also gets plugged in External Drives via USB.
#>
Get-WmiObject -Class Win32_LogicalDisk | 
    Select-Object -Property DeviceID, DriveType, @{
        Name       = 'DriveTypeName'
        Expression = {
            if     ($_.DriveType -eq 0) {'Unknown'}
            elseif ($_.DriveType -eq 1) {'No Root Directory'}
            elseif ($_.DriveType -eq 2) {'Removeable Disk'}
            elseif ($_.DriveType -eq 3) {'Local Drive'}
            elseif ($_.DriveType -eq 4) {'Network Drive'}
            elseif ($_.DriveType -eq 5) {'Compact Disc'}
            elseif ($_.DriveType -eq 6) {'RAM Disk'}
            else                        {'Error: Unknown'}        
        }},VolumeName, 
    @{L='FreeSpaceGB';E={"{0:N2}" -f ($_.FreeSpace /1GB)}},
    @{L="Capacity";E={"{0:N2}" -f ($_.Size/1GB)}}
