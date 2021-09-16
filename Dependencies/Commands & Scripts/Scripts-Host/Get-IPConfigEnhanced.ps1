$GetNetAdapter = Get-NetAdapter | Select-Object -Property *

$GetNetIPAddress = Get-NetIPAddress


foreach ($NetAdapter in $GetNetAdapter) {
    foreach ($NetIPAddress in $GetNetIPAddress) {
        if ($NetAdapter.ifIndex -eq $NetIPAddress.ifIndex) {
            $NetAdapter `
            | Add-Member -MemberType NoteProperty -Name IPAddress     -Value $NetIPAddress.IPAddress     -Force -PassThru `
            | Add-Member -MemberType NoteProperty -Name PrefixLength  -Value $NetIPAddress.PrefixLength  -Force -PassThru `
            | Add-Member -MemberType NoteProperty -Name PrefixOrigin  -Value $NetIPAddress.PrefixOrigin  -Force -PassThru `
            | Add-Member -MemberType NoteProperty -Name SuffixOrigin  -Value $NetIPAddress.SuffixOrigin  -Force -PassThru `
            | Add-Member -MemberType NoteProperty -Name Type          -Value $NetIPAddress.Type          -Force -PassThru `
            | Add-Member -MemberType NoteProperty -Name AddressFamily -Value $NetIPAddress.AddressFamily -Force -PassThru `
            | Add-Member -MemberType NoteProperty -Name AddressState  -Value $NetIPAddress.AddressState  -Force -PassThru `
            | Add-Member -MemberType NoteProperty -Name PolicyStore   -Value $NetIPAddress.PolicyStore   -Force
        }
    }
}
$GetNetAdapter | Select-Object -Property Name, InterfaceName, InterfaceDescription, Status, ConnectorPresent, Virtual, AddressFamily, IPAddress, Type, MacAddress, MediaConnectionState, PromiscuousMode, AdminStatus, MediaType, LinkSpeed, MtuSize, FullDuplex, AddressState, PrefixLength, PrefixOrigin, SuffixOrigin, DriverInformation, DriverProvider, DriverVersion, DriverDate, ifIndex, PolicyStore, Speed, ReceiveLinkSpeed, TransmitLinkSpeed, DeviceWakeUpEnable, AdminLocked, NotUserRemovable, ComponentID, HardwareInterface, Hidden, * -ErrorAction SilentlyContinue

