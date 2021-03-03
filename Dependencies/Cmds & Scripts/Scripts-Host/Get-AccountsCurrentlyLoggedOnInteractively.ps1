## Find all sessions matching the specified username
$quser = quser | Where-Object {$_ -notmatch 'SESSIONNAME'}

$sessions = ($quser -split "`r`n").trim()

foreach ($session in $sessions) {
    try {
        # This checks if the value is an integer, if it is then it'll TRY, if it errors then it'll CATCH
        [int]($session -split '  +')[2] | Out-Null

        [PSCustomObject]@{
            PSComputerName = $env:COMPUTERNAME
            UserName       = ($session -split '  +')[0].TrimStart('>')
            SessionName    = ($session -split '  +')[1]
            SessionID      = ($session -split '  +')[2]
            State          = ($session -split '  +')[3]
            IdleTime       = ($session -split '  +')[4]
            LogonTime      = ($session -split '  +')[5]
        }
    }
    catch {
        [PSCustomObject]@{
            PSComputerName = $env:COMPUTERNAME
            UserName       = ($session -split '  +')[0].TrimStart('>')
            SessionName    = ''
            SessionID      = ($session -split '  +')[1]
            State          = ($session -split '  +')[2]
            IdleTime       = ($session -split '  +')[3]
            LogonTime      = ($session -split '  +')[4]
        }
    }
}

