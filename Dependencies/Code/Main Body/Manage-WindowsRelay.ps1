
Param( 
    $Relay="v4tov4",
    $ListenAddress = "0.0.0.0",
    $ListenPort = 8888,
    $ConnectAddress,
    $ConnectPort,
    $ComputerName,
    $UserName,
    $Password,
    [Switch]$Delete,
    [Switch]$Show

)


if ($UserName -and $Password) {
    $SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
    $Creds = New-Object System.Management.Automation.PSCredential ($UserName, $SecurePassword)
}
else {
    $Creds = $False
}

if ($Show) {
    if ($Creds) {
        Invoke-Command -ScriptBlock {netsh interface portproxy show all} -ComputerName $ComputerName -Credential $Creds
    }
    else {
        Invoke-Command -ScriptBlock {netsh interface portproxy show all} -ComputerName $ComputerName 
    }
}

if (!$Delete -and !$Show) {
    switch ($Relay) {
        "v4tov4" {
            $sb = [ScriptBlock]::Create("netsh interface portproxy add v4tov4 listenport=$ListenPort listenaddress=$ListenAddress connectport=$ConnectPort connectaddress=$ConnectAddress protocol=tcp")
            Write-Output "Initiating v4tov4 Relay. Listening on $ListenAddress, Port $ListenPort. Connecting to $Connectaddress, Port $Connectport"
        }
        "v6tov4" {
            $sb = [ScriptBlock]::Create("netsh interface portproxy add v6tov4 listenport=$ListenPort listenaddress=$ListenAddress connectport=$ConnectPort connectaddress=$ConnectAddress")
            Write-Output "Initiating v6tov4 Relay. Listening on $ListenAddress, Port $ListenPort. Connecting to $Connectaddress, Port $Connectport"
        }
        "v4tov6" {
            $sb = [ScriptBlock]::Create("netsh interface portproxy add v4tov6 listenport=$ListenPort listenaddress=$ListenAddress connectport=$ConnectPort connectaddress=$ConnectAddress")
            Write-Output "Initiating v4tov6 Relay. Listening on $ListenAddress, Port $ListenPort. Connecting to $Connectaddress, Port $Connectport"
        }
        "v6tov6" {
            $sb = [ScriptBlock]::Create("netsh interface portproxy add v6tov6 listenport=$ListenPort listenaddress=$ListenAddress connectport=$ConnectPort connectaddress=$ConnectAddress protocol=tcp")
            Write-Output "Initiating v6tov6 Relay. Listening on $ListenAddress, Port $ListenPort. Connecting to $Connectaddress, Port $Connectport"
        }
    }

    if ($Creds) {
        Invoke-Command -ScriptBlock $sb -ComputerName $ComputerName -Credential $Creds
        Invoke-Command -ScriptBlock {param ($SBRelay) netsh interface portproxy show $SBRelay } -ArgumentList $Relay -ComputerName $ComputerName -Credential $Creds
    }
    else {
        Invoke-Command -ScriptBlock $sb -ComputerName $ComputerName
        Invoke-Command -ScriptBlock {netsh interface portproxy show $Relay } -ComputerName $ComputerName
    }
}
if ($Delete) {
    switch ($Relay) {
        "v4tov4" {
            $sbdelete = [ScriptBlock]::Create("netsh interface portproxy delete v4tov4 listenport=$ListenPort listenaddress=$ListenAddress protocol=tcp")
            Write-Output "Deleting v4tov4 Relay which was listening on $ListenAddress, Port $ListenPort and connecting to $Connectaddress, Port $Connectport"
        }
        "v6tov4" {
            $sbdelete = [ScriptBlock]::Create("netsh interface portproxy delete v6tov4 listenport=$ListenPort listenaddress=$ListenAddress")
            Write-Output "Deleting v6tov4 Relay which was listening on $ListenAddress, Port $ListenPort and connecting to $Connectaddress, Port $Connectport"
        }
        "v4tov6" {
            $sbdelete = [ScriptBlock]::Create("netsh interface portproxy delete v4tov6 listenport=$ListenPort listenaddress=$ListenAddress")
            Write-Output "Deleting v4tov6 Relay which was listening on $ListenAddress, Port $ListenPort and connecting to $Connectaddress, Port $Connectport"
        }
        "v6tov6" {
            $sbdelete = [ScriptBlock]::Create("netsh interface portproxy delete v6tov6 listenport=$ListenPort listenaddress=$ListenAddress protocol=tcp")
            Write-Output "Deleting v6tov6 Relay which was listening on $ListenAddress, Port $ListenPort and connecting to $Connectaddress, Port $Connectport"
        }
    }

    if ($Creds) {
        Invoke-Command -ScriptBlock $sbdelete -ComputerName $ComputerName -Credential $Creds
        Invoke-Command -ScriptBlock {param ($SBRelay) netsh interface portproxy show $SBRelay } -ArgumentList $Relay -ComputerName $ComputerName -Credential $Creds
    }
    else {
        Invoke-Command -ScriptBlock $sbdelete -ComputerName $ComputerName
        Invoke-Command -ScriptBlock {netsh interface portproxy show $Relay } -ComputerName $ComputerName
    }
}
