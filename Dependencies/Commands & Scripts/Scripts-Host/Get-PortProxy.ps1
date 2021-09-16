$PortProxy = @()
$netsh = & netsh interface portproxy show all
$netsh | Select-Object -Skip 5 | Where-Object {$_ -ne ''} | ForEach-Object {
    $Attribitutes = $_ -replace "\s+"," " -split ' '
    $PortProxy += [PSCustomObject]@{
        'ComputerName'         = $Env:COMPUTERNAME
        'Listening On Address' = $Attribitutes[0]
        'Listening On Port'    = $Attribitutes[1]
        'Connect To Address'   = $Attribitutes[2]
        'Connect To Port'      = $Attribitutes[3]
    }
}
$PortProxy | Where-Object {$_.'Listening On Address' -match "\d.\d.\d.\d" -or $_.'Listening On Address' -match ':' }