param (
    [switch]$string
)

$Connections = Invoke-Command -ScriptBlock { cmd /c netstat -anob -p tcp }
    
if ($string) {
    # Processes collection to format it from txt to csv
    $Connections = $Connections | Select-Object -skip 3
    $TCPdata = @()
    $Connections.trim() | Out-String | ForEach-Object { 
        $TCPdata += $_ -replace "`r`n",";;" -replace ";;;;",";;" -creplace ";;TCP","`r`nTCP" -replace ";;","  " -replace " {2,}","," -creplace "PID","PID,ExecutedProcess" -replace "^,|,$","" 
        # -replace "`r`n",";;"                       Replaces return cariages and newlines with a new place holder field separator
        # -replace ";;;;",";;"                       Replaces instances where two return carriages and newlines were back to back
        # -creplace ";;TCP","`r`nTCP"                Replaces the beginning of the TCP network connection line with a return carriage/new line
        # -replace ';;\[',' ['                       Collapses the two separate fields into one
        # -replace ";;","  "                         Replaces the field separator (return carriages/new lines) with double white spaces
        # -replace " {2,}",","                       Replaces two or more white spaces with commas to make it a CSV
        # -creplace "PID","PID,Executed Process"     Addes in extra field header that is not present for the Executables (the 'b' in -anob)
        # -replace "^,|,$",""                        Repaces any potential commas at the beginning or end of a line
    }
    $format = $TCPdata -split "`r`n"
    $TCPnetstat =@()
    # This section is needed to combine two specific csv fields together for easier viewing
    foreach ($line in $format) {
        if ($line -match "\d,\[") {$TCPnetstat += $line}
        if ($line -notmatch "\d,\[") {$TCPnetstat += $line -replace ",\["," ["}
    }

    # Adds the addtional column header, PSComputerName, and target computer to each connection
    $TCPnetstat | ForEach-Object {
        if ($_ -match "PID,ExecutedProcess") {
            "PSComputerName," + "$_"
        }
        else {
            "$($env:COMPUTERNAME)," + "$_"
        }
    }
}

else {
    # Processes collection to format it from txt to csv
    $Connections = $Connections | Select-Object -skip 4
    $TCPdata = @()
    $Connections.trim() | Out-String | ForEach-Object { 
        $TCPdata += $_ -replace "`r`n",";;" -replace ";;;;",";;" -creplace ";;TCP","`r`nTCP" -replace ";;","  " -replace " {2,}","," -creplace "PID","PID,ExecutedProcess" -replace "^,|,$","" 
        # -replace "`r`n",";;"                       Replaces return cariages and newlines with a new place holder field separator
        # -replace ";;;;",";;"                       Replaces instances where two return carriages and newlines were back to back
        # -creplace ";;TCP","`r`nTCP"                Replaces the beginning of the TCP network connection line with a return carriage/new line
        # -replace ';;\[',' ['                       Collapses the two separate fields into one
        # -replace ";;","  "                         Replaces the field separator (return carriages/new lines) with double white spaces
        # -replace " {2,}",","                       Replaces two or more white spaces with commas to make it a CSV
        # -creplace "PID","PID,Executed Process"     Addes in extra field header that is not present for the Executables (the 'b' in -anob)
        # -replace "^,|,$",""                        Repaces any potential commas at the beginning or end of a line
    }
    $format = $TCPdata -split "`r`n"
    $TCPnetstat =@()
    # This section is needed to combine two specific csv fields together for easier viewing
    foreach ($line in $format) {
        if ($line -match "\d,\[") {$TCPnetstat += $line}
        if ($line -notmatch "\d,\[") {$TCPnetstat += $line -replace ",\["," ["}
    }

    # Creates an object from the string data
    $NetstatData = @()
    $TCPnetstat | ForEach-Object  {
        $conn = $_ -split ','
        $NetstatData += [PSCustomObject]@{
            PSComputerName  = $env:COMPUTERNAME
            Protocol        = $conn[0]
            LocalAddress    = ($conn[1] -split ':')[0]
            LocalPort       = ($conn[1] -split ':')[1]
            RemoteAddress   = ($conn[2] -split ':')[0]
            RemotePort      = ($conn[2] -split ':')[1]
            State           = $conn[3]
            PID             = $conn[4]
            ExecutedProcess = $conn[5]
        }
    }
    $NetstatData | Select-Object PSComputerName, Protocol, LocalAddress, LocalPort, RemoteAddress, RemotePort, State, PID, ExecutedProcess
}

