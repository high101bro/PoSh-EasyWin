Get-ItemProperty -Path HKLM:\system\CurrentControlSet\Enum\USBSTOR\*\* | Select-Object -Property FriendlyName, Service, @{Name="ContainerID";Expression={"$($_.ContainerID.trim('{}'))"}}, @{Name="HardwareID";Expression={"$($_.HardwareID)"}}






