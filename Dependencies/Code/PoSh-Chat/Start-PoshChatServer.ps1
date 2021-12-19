<#
To Do:
    * Graceful Exit of server while keeping console active
    * Better handling of message traffic
    * Message to client if at max connections    
#>

#Function to halt server and disconnect clients
[cmdletbinding()]
Param (
    [parameter()]
    [string]$EnableLogging # (Join-Path $pwd ChatLog.log)
)
If ($PSBoundParameters['EnableLogging']) {
    #Make global so it can be seen in event Action blocks
    $Global:EnableLogging = $EnableLogging
}
#Save previous prompt
$Global:old_Prompt = Get-Content Function:Prompt
#No Prompt
Function Global:Prompt {[char]8}
Clear-Host
##Create Globally synchronized hash tables and queue to share across runspaces
#Used for initial connections
$Global:sharedData = [HashTable]::Synchronized(@{})
#Used for managing client connections
$Global:ClientConnections = [hashtable]::Synchronized(@{})
#Used for managing the queue of messages in an orderly fashion
$Global:MessageQueue =  [System.Collections.Queue]::Synchronized((New-Object System.collections.queue))
#Used to manage incoming client messages
$Global:ClientHash = [HashTable]::Synchronized(@{})
#Removal Queue
$Global:RemoveQueue =  [System.Collections.Queue]::Synchronized((New-Object System.collections.queue))
#Listener
$Global:Listener = [HashTable]::Synchronized(@{})

#Set up timer
$Timer = New-Object Timers.Timer
$timer.Enabled = $true
$Timer.Interval = 1000 
 
#Timer event to track client connections and remove disconnected clients
$NewConnectionTimer = Register-ObjectEvent -SourceIdentifier MonitorClientConnection -InputObject $Timer -EventName Elapsed -Action { 
    While ($RemoveQueue.count -ne 0) {    
        $user = $RemoveQueue.Dequeue()
        ##Close down the runspace
        $ClientConnections.$user.PowerShell.EndInvoke($ClientConnections.$user.Job)
        $ClientConnections.$user.PowerShell.Runspace.Close()
        $ClientConnections.$user.PowerShell.Dispose()          
        $ClientConnections.Remove($User)                          
        $Messagequeue.Enqueue("~D{0}" -f $user)   
    }   
}
#Timer event to track for new incoming connections and to kick off seperate jobs to track messages 
$NewConnectionTimer = Register-ObjectEvent -SourceIdentifier NewConnectionTimer -InputObject $Timer -EventName Elapsed -Action {
    If ($ClientHash.count -lt $SharedData.count) {
        $sharedData.GetEnumerator() | ForEach-Object {
            If (-Not ($ClientHash.Contains($_.Name))) {
                #Spin off new job and add to ClientHash
                $ClientHash[$_.Name]=$_.Value               
                $User = $_.Name
                $Messagequeue.Enqueue(("~C{0}" -f $User))
                
                #Kick off a job to watch for messages from clients
                $newRunspace = [RunSpaceFactory]::CreateRunspace()
                $newRunspace.Open()
                $newRunspace.SessionStateProxy.setVariable("shareddata", $shareddata)
                $newRunspace.SessionStateProxy.setVariable("ClientHash", $ClientHash)
                $newRunspace.SessionStateProxy.setVariable("User", $user)
                $newRunspace.SessionStateProxy.setVariable("MessageQueue", $MessageQueue)               
                $newRunspace.SessionStateProxy.setVariable("RemoveQueue", $RemoveQueue)
                $newPowerShell = [PowerShell]::Create()
                $newPowerShell.Runspace = $newRunspace   
                $sb = {
                    #Code to kick off client connection monitor and look for incoming messages.
                    $client = $ClientHash.$user
                    $serverstream = $Client.GetStream()
                    #While client is connected to server, check for incoming traffic
                    While ($True) {                                              
                        [byte[]]$inStream = New-Object byte[] 200KB
                        $buffSize = $client.ReceiveBufferSize
                        $return = $serverstream.Read($inStream, 0, $buffSize)  
                        If ($return -gt 0) {
                            $Messagequeue.Enqueue([System.Text.Encoding]::ASCII.GetString($inStream[0..($return - 1)]))
                        } Else {
                            $shareddata.Remove($User)
                            $clienthash.Remove($User)                   
                            $RemoveQueue.Enqueue($User)
                            Break
                        }
                    }
                }
                $job = "" | Select-Object Job, PowerShell
                $job.PowerShell = $newPowerShell
                $Job.job = $newPowerShell.AddScript($sb).BeginInvoke()
                $ClientConnections.$User = $job                                             
            }
        }
    }
}

#Timer event to track for new incoming messages and broadcast message to all connected clients
$IncomingMessageTimer = Register-ObjectEvent -SourceIdentifier IncomingMessageTimer -InputObject $Timer -EventName Elapsed -Action {
    While ($MessageQueue.Count -ne 0) {
        $Message = $MessageQueue.dequeue() 
        Switch ($Message) {
            {$_.Startswith("~M")} {
                #Message
                $data = ($_).SubString(2)
                $split = $data -split ("{0}" -f "~~")
                If ($split[1].startswith("@")) {
                    If ($split[1] -Match "(?<name>@\w+)(?<Message>.*)") {
                        $directMessage = $matches.name.Trim("@")
                        $tempmessage = $matches.Message.Trim(" ")
                        $message = ("~B{0}~~{1}" -f $split[0],$tempmessage)
                    }
                } Else {
                    Write-Host ("{0} >> {1}: {2}" -f (Get-Date).ToString(),$split[0],$split[1])
                    If ($EnableLogging) {
                        Out-File -Inputobject ("{0} >> {1}: {2}" -f (Get-Date).ToString(),$split[0],$split[1]) -FilePath $EnableLogging -Append
                    }
                }
            }
            {$_.Startswith("~D")} {
                #Disconnect
                Write-Host ("{0} >> {1} has disconnected from the chat server on {2}" -f (Get-Date).ToString(),$_.SubString(2),$env:ComputerName)
                If ($EnableLogging) {
                    Out-File -Inputobject ("{0} >> {1} has disconnected from the chat server on {2}" -f (Get-Date).ToString(),$_.SubString(2),$env:ComputerName) -FilePath $EnableLogging -Append
                }                
            }
            {$_.StartsWith("~C")} {
                #Connect
                Write-Host ("{0} >> {1} has connected to the chat server" -f (Get-Date).ToString(),$_.SubString(2))
                If ($EnableLogging) {
                    Out-File -Inputobject ("{0} >> {1} has connected to the chat server" -f (Get-Date).ToString(),$_.SubString(2)) -FilePath $EnableLogging -Append
                }                              
            }
            {$_.StartsWith("~S")} {
                #Server Shutdown
                Write-Host ("{0} >> Chat server on {1} has shutdown." -f (Get-Date).ToString(),$env:ComputerName)
                If ($EnableLogging) {
                    Out-File -Inputobject ("{0} >> Chat server on {1} has shutdown." -f (Get-Date).ToString(),$env:ComputerName) -FilePath $EnableLogging -Append
                }                              
            }            
            Default {
                Write-Host ("{0} >> {1}" -f (Get-Date).ToString(),$_)
                If ($EnableLogging) {
                    Out-File -Inputobject ("{0} >> {1}" -f (Get-Date).ToString(),$_) -FilePath $EnableLogging -Append
                }                  
            }
        }        
        #Broadcast message
        If ($directMessage) {
            $Broadcast = $Clienthash[$directMessage]
            $broadcastStream = $broadcast.GetStream()
            $string = $Message
            $broadcastbyte = ([text.encoding]::ASCII).GetBytes($String)
            $broadcastStream.Write($broadcastbyte,0,$broadcastbyte.Length)
            $broadcastStream.Flush()         
        Remove-Variable directMessage -ErrorAction SilentlyContinue
        } Else {
            $Clienthash.GetEnumerator() | ForEach-Object {
                $Broadcast = $Clienthash[$_.Name]
                $broadcastStream = $broadcast.GetStream()
                $string = $Message
                $broadcastbyte = ([text.encoding]::ASCII).GetBytes($String)
                $broadcastStream.Write($broadcastbyte,0,$broadcastbyte.Length)
                $broadcastStream.Flush()            
            }
        }
    }
}

$Timer.Start()

#Initial runspace creation to set up server listener 
$Global:newRunspace = [RunSpaceFactory]::CreateRunspace()
$newRunspace.Open()
$newRunspace.SessionStateProxy.setVariable("sharedData", $sharedData)
$newRunspace.SessionStateProxy.setVariable("Listener", $Listener)
$newRunspace.SessionStateProxy.setVariable("EnableLogging", $EnableLogging)
$Global:newPowerShell = [PowerShell]::Create()
$newPowerShell.Runspace = $newRunspace
$sb = {
 $Listener['listener'] = [System.Net.Sockets.TcpListener]15600
 $Listener['listener'].Start()
 [console]::WriteLine("{0} >> Chat server started on port 15600" -f (Get-Date).ToString())
 If ($EnableLogging) {
    Write-Verbose ('Logging to file')
    Out-File -Inputobject ("{0} >> Chat server started on {1} TCP port {2}" -f (Get-Date).ToString(),$env:ComputerName,15600) -FilePath $EnableLogging
} 
 while($true) {
    [byte[]]$byte = New-Object byte[] 5KB
    $client = $Listener['listener'].AcceptTcpClient()
    If ($client -ne $Null) {
        $stream = $client.GetStream()
        Do {
            #Write-Host 'Processing Data'
            Write-Verbose ("Bytes Left: {0}" -f $Client.Available)
            $Return = $stream.Read($byte, 0, $byte.Length)
            $String += [text.Encoding]::Ascii.GetString($byte[0..($Return-1)])
           
        } While ($stream.DataAvailable)
        If ($SharedData.Count -lt 30) { 
            $SharedData[$String] = $client           
            #Send list of online users to client
            $users = ("~Z{0}" -f ($shareddata.Keys -join "~~"))
            $broadcastStream = $client.GetStream()
            $broadcastbyte = ([text.encoding]::ASCII).GetBytes($users)
            $broadcastStream.Write($broadcastbyte,0,$broadcastbyte.Length)
            $broadcastStream.Flush()             
            $String = $Null
        } Else {
            #Too many clients, refuse connection
        }
    } Else {
        #Connection to server closed
        Break
    }
 }#End While
}
$Global:handle = $newPowerShell.AddScript($sb).BeginInvoke()


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU7XH1ujvV/oKumnf18AbCjipL
# 4KygggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
# AQUFADAzMTEwLwYDVQQDDChQb1NoLUVhc3lXaW4gQnkgRGFuIEtvbW5pY2sgKGhp
# Z2gxMDFicm8pMB4XDTIxMTIxNDA1MDIwMFoXDTMxMTIxNDA1MTIwMFowMzExMC8G
# A1UEAwwoUG9TaC1FYXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALvIxUDFEVGB/G0FXPryoNlF
# dA65j5jPEFM2R4468rjlTVsNYUOR+XvhjmhpggSQa6SzvXtklUJIJ6LgVUpt/0C1
# zlr1pRwTvsd3svI7FHTbJahijICjCv8u+bFcAR2hH3oHFZTqvzWD1yG9FGCw2pq3
# h4ahxtYBd1+/n+jOtPUoMzcKIOXCUe4Cay+xP8k0/OLIVvKYRlMY4B9hvTW2CK7N
# fPnvFpNFeGgZKPRLESlaWncbtEBkexmnWuferJsRtjqC75uNYuTimLDSXvNps3dJ
# wkIvKS1NcxfTqQArX3Sg5qKX+ZR21uugKXLUyMqXmVo2VEyYJLAAAITEBDM8ngUC
# AwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0G
# A1UdDgQWBBSDJIlo6BcZ7KJAW5hoB/aaTLxFzTANBgkqhkiG9w0BAQUFAAOCAQEA
# ouCzal7zPn9vc/C9uq7IDNb1oNbWbVlGJELLQQYdfBE9NWmXi7RfYNd8mdCLt9kF
# CBP/ZjHKianHeZiYay1Tj+4H541iUN9bPZ/EaEIup8nTzPbJcmDbaAGaFt2PFG4U
# 3YwiiFgxFlyGzrp//sVnOdtEtiOsS7uK9NexZ3eEQfb/Cd9HRikeUG8ZR5VoQ/kH
# 2t2+tYoCP4HsyOkEeSQbnxlO9s1jlSNvqv4aygv0L6l7zufiKcuG7q4xv/5OvZ+d
# TcY0W3MVlrrNp1T2wxzl3Q6DgI+zuaaA1w4ZGHyxP8PLr6lMi6hIugI1BSYVfk8h
# 7KAaul5m+zUTDBUyNd91ojGCAegwggHkAgEBMEcwMzExMC8GA1UEAwwoUG9TaC1F
# YXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKQIQeugH5LewQKBKT6dP
# XhQ7sDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkq
# hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGC
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUwi5BdE4aKWOMlnNI5YecGpmSRAgwDQYJKoZI
# hvcNAQEBBQAEggEAko0xPVGe/rIarepjhiIZkh9JJCeGZ7/+VFhsLzz3NWDgH/d2
# 8xIa6TbNxplTmEeCeCPJsrQ+/7AsWFd0RLIzMdEEcG/bWcXZQBlXBk+n954leZXJ
# 9Wz8Uc/jBoLb0rW2cMO9AS+8wC5kasxUPTnM8C7Z3JpNztqKP1Q5OrqRwHwa/Dkv
# S2GVOf3TKDoUioP+tIG23UPgvOGgCyy5THUyvpA5xwyRxBlDCg8+3dV/fiTt5l/R
# e/OwNVk0zKp3N2W7MCP/s/cHgbKulWXzmZAb1JUWsNb65LgNB96P0MhtQ2ZBE+c/
# psR3YjThfNg0zG5L1a5vdbgO0Qegy+MLLqYWCw==
# SIG # End signature block
