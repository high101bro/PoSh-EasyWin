function Create-LogEntry {
    param(
        $TargetComputer,
        $Message,
        $LogFile,
        [switch]$NoTargetComputer
    )
    if ($NoTargetComputer) {
        Add-Content -Path $LogFile -Value "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  $Message"
    }
    else {
        Add-Content -Path $LogFile -Value "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  $TargetComputer`: $Message"
    }
}

