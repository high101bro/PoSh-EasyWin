<#
.Description
    Collects the last 1000 Windows Error Reporting (WER) faults (Application Logs, Event ID 1000) and creates a unique list.
#>
$Faults = Get-EventLog -LogName Application -InstanceId 1000 | Select-Object -ExpandProperty Message
$UniqueFault = @()
ForEach ($f in $Faults) {
    $fault = if ($f -match 'Faulting'){$f.split(':')[1].split(',')[0].trim()}
    if ($fault -notin $UniqueFault) { $UniqueFault += $fault }
}
$UniqueFault


