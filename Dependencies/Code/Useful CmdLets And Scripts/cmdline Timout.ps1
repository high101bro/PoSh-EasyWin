function Read-KeyOrTimeout {
    Param(
        [int]$seconds = 5,
        [string]$prompt = 'Hit a key',
        [string]$default = 'This is the default'
    )
    $startTime = Get-Date
    $timeOut = New-TimeSpan -Seconds $seconds
    Write-Host $prompt
    while (-not $host.ui.RawUI.KeyAvailable) {
        $currentTime = Get-Date
        if ($currentTime -gt $startTime + $timeOut) {
            Break
        }
    }
    if ($host.ui.RawUI.KeyAvailable) {
        [string]$response = ($host.ui.RawUI.ReadKey("IncludeKeyDown,NoEcho")).character
    }
    else {
        $response = $default
    }
    Write-Output "You typed $($response.toUpper())"
}
Read-KeyOrTimeOut


