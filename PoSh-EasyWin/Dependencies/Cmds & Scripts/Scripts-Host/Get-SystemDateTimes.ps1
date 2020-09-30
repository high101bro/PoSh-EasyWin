<#
.Description
    Gets the system's last boot up time, installation date, and local date time in a easy to read format.
#>

$os = Get-WmiObject win32_operatingsystem
$DateTimes = [PSCustomObject]@{
    LastBootUpTime  = $os.ConvertToDateTime($os.LastBootUpTime)
    InstallDate     = $os.ConvertToDateTime($os.InstallDate)
    LocalDateTime   = $os.ConvertToDateTime($os.LocalDateTime)
    CurrentTimeZone = $os.CurrentTimeZone
}
$DateTimes | Select-Object PSComputerName, LocalDateTime, LastBootUpTime, InstallDate, CurrentTimeZone



