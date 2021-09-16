<#
.Description
    Compiles various time related data into one easy to read results
#>

$os = $null
$GetTimeZone = $null
$os = Get-WmiObject win32_operatingsystem
$GetTimeZone = Get-Timezone
if ($GetTimeZone) {
    $DateTimes = [PSCustomObject]@{
        LastBootUpTime             = $os.ConvertToDateTime($os.LastBootUpTime)
        InstallDate                = $os.ConvertToDateTime($os.InstallDate)
        LocalDateTime              = $os.ConvertToDateTime($os.LocalDateTime)
        TimeZone                   = $GetTimeZone.StandardName
        BaseUtcOffset              = $GetTimeZone.BaseUtcOffset
        SupportsDaylightSavingTime = $GetTimeZone.SupportsDaylightSavingTime
    }
    $DateTimes | Select-Object @{n='ComputerName';E={$env:COMPUTERNAME}}, LocalDateTime, LastBootUpTime, InstallDate, TimeZone, BaseUtcOffset, SupportsDaylightSavingTime
}
else {
    $DateTimes = [PSCustomObject]@{
        LastBootUpTime  = $os.ConvertToDateTime($os.LastBootUpTime)
        InstallDate     = $os.ConvertToDateTime($os.InstallDate)
        LocalDateTime   = $os.ConvertToDateTime($os.LocalDateTime)
        CurrentTimeZone = $os.CurrentTimeZone
    }
    $DateTimes | Select-Object @{n='ComputerName';E={$env:COMPUTERNAME}}, LocalDateTime, LastBootUpTime, InstallDate, CurrentTimeZone
}


