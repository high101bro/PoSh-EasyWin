<#
Antecedent: A CIM_USBController representing the Universal Serial Bus (USB) controller associated with this device.
Dependent: Describes the logical device connected to the Universal Serial Bus (USB) controller.
#>
Get-WmiObject -Class Win32_USBControllerDevice | Foreach-Object {
    $Dependent  = [wmi]($_.Dependent)
    $Antecedent = [wmi]($_.Antecedent)

    [PSCustomObject]@{
        USBDeviceName             = $Dependent.Name
        USBDeviceManufacturer     = $Dependent.Manufacturer
        USBDeviceService          = $Dependent.Service
        USBDeviceStatus           = $Dependent.Status
        USBDevicePNPDeviceID      = $Dependent.PNPDeviceID
        USBDeviceHardwareID       = $Dependent.HardwareID
        USBDeviceInstallDate      = $Dependent.InstallDate
        USBControllerName         = $Antecedent.Name
        USBControllerManufacturer = $Antecedent.Manufacturer
        USBControllerStatus       = $Antecedent.Status
        USBControllerPNPDeviceID  = $Antecedent.PNPDeviceID
        USBControllerInstallDate  = $Antecedent.InstallDate
    }
} `
| Select-Object -Property PSComputerName, * `
| Sort-Object Description,DeviceID




