<# strComputer = “.”

Set objWMIService = GetObject(“winmgmts:\\” & strComputer & “\root\cimv2”)


Set colDrives = objWMIService.ExecQuery _

    (“Select * From Win32_LogicalDisk Where DriveType = 4”)


For Each objDrive in colDrives

    Wscript.Echo “Drive letter: ” & objDrive.DeviceID

    Wscript.Echo “Network path: ” & objDrive.ProviderName

Next
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
