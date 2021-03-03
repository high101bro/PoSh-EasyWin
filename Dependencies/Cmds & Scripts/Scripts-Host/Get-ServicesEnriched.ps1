$service = Get-WmiObject -Class Win32_Service

foreach ($svc in $service) {
    $ProcessName = Get-Process -Id $svc.processid | Select-Object -ExpandProperty Name
    $svc | Add-member -NotePropertyName 'ProcessName' -NotePropertyValue $ProcessName
}
$service | select PSComputerName, Name, State, Status, Started, StartMode, StartName, ProcessID, ProcessName,  PathName, Caption, Description, DelayedAutoStart, AcceptPause, AcceptStop

