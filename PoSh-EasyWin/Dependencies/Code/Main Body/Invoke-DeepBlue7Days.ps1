###############################################################
# Credits to DeepBlueCLI 2.01 for original script             #
# Modified for compatibility and streamlined for PoSh-EasyWin #
###############################################################
param (
    $RegexFile,
    $WhiteListFile
)

function Invoke-DeepBlueAll {

    # Set up the global variables
    $text      = ""   # Temporary scratch pad variable to hold output text
    $minlength = 1000  # Minimum length of command line to alert

    # Load cmd match regexes from csv file, ignore comments
    $regexes   = $RegexFile | Select-String '^[^#]' | ConvertFrom-Csv

    # Load cmd whitelist regexes from csv file, ignore comments
    $whitelist = $WhiteListFile | Select-String '^[^#]' | ConvertFrom-Csv
    
    # Passworg guessing/spraying variables:
    $maxfailedlogons      = 5    # Alert after this many failed logons
    $failedlogons         = @{}  # HashTable of failed logons per user
    $totalfailedlogons    = 0    # Total number of failed logons (for all accounts)
    $totalfailedaccounts  = 0    # Total number of accounts with a failed logon

    # Track total Sensitive Privilege Use occurrences
    $totalsensprivuse     = 0
    $maxtotalsensprivuse  = 4

    # Admin logon variables:
    $totaladminlogons     = 0    # Total number of logons with SeDebugPrivilege
    $maxadminlogons       = 10   # Alert after this many admin logons
    $adminlogons          = @{}  # HashTable of admin logons
    $multipleadminlogons  = @{}  # Hashtable to track multiple admin logons per account
    $alert_all_admin      = 0    # Set to 1 to alert every admin logon (set to 0 disable this)

    # Obfuscation variables:
    $minpercent           = .65  # minimum percentage of alphanumeric and common symbols
    $maxbinary            = .50  # Maximum percentage of zeros and ones to detect binary encoding

    # Password spray variables:
    $passspraytrack       = @{}
    $passsprayuniqusermax = 6
    $passsprayloginmax    = 6

    # Sysmon variables:
    # Check for unsigned EXEs/DLLs. This can be very chatty, so it's disabled.
    # Set $checkunsigned to 1 to enable:
    $checkunsigned = 0

    # Get the events:
    $events = @()
    

    $events += Get-WinEvent -filterhashtable @{StartTime=(Get-Date).AddDays(-7);EndTime=(Get-Date);Logname='Security';ID=@(4688,4672,4720,4728,4732,4756,4625,4673,4674,4648,1102)} -ErrorAction SilentlyContinue
    $events += Get-WinEvent -filterhashtable @{StartTime=(Get-Date).AddDays(-7);EndTime=(Get-Date);Logname='System';ID=@(104,7030,7036,7040,7045)} -ErrorAction SilentlyContinue
    $events += Get-WinEvent -filterhashtable @{StartTime=(Get-Date).AddDays(-7);EndTime=(Get-Date);Logname='Application';ID=@(2)} -ErrorAction SilentlyContinue
    $events += Get-WinEvent -filterhashtable @{StartTime=(Get-Date).AddDays(-7);EndTime=(Get-Date);logname='Microsoft-Windows-AppLocker/EXE and DLL';ID=@(8003,8004,8006,8007)} -ErrorAction SilentlyContinue
    $events += Get-WinEvent -filterhashtable @{StartTime=(Get-Date).AddDays(-7);EndTime=(Get-Date);logname='Microsoft-Windows-PowerShell/Operational';ID=@(4103,4104)} -ErrorAction SilentlyContinue
    $events += Get-WinEvent -filterhashtable @{StartTime=(Get-Date).AddDays(-7);EndTime=(Get-Date);logname='Windows PowerShell';ID=800} -ErrorAction SilentlyContinue
    $events += Get-WinEvent -filterhashtable @{StartTime=(Get-Date).AddDays(-7);EndTime=(Get-Date);logname='Microsoft-Windows-Sysmon/Operational';ID=@(1,7)} -ErrorAction SilentlyContinue


    $EventsFound = @()

    ForEach ($event in $events) {
        # Custom reporting object:
        $obj = [PSCustomObject]@{
            Date    = $event.TimeCreated
            Log     = $logname
            EventID = $event.id
            Message = ""
            Results = ""
            Command = ""
            Decoded = ""
        }
        $eventXML   = [xml]$event.ToXml()
        $servicecmd = 0 # CLIs via service creation get extra checks, this defaults to 0 (no extra checks)

        if ($event.LogName -eq 'Security' -and $event.id -eq 4688){
            # A new process has been created. (Command Line Logging)
            $commandline = $eventXML.Event.EventData.Data[8]."#text" # Process Command Line
            $creator     = $eventXML.Event.EventData.Data[13]."#text"    # Creator Process Name
            if ($commandline){
                Check-Command -EventID 4688 -commandline $commandline
            }
        }
        elseif ($event.LogName -eq 'Security' -and $event.id -eq 4672){
            # Special privileges assigned to new logon (possible admin access)
            $username   = $eventXML.Event.EventData.Data[1]."#text"
            $domain     = $eventXML.Event.EventData.Data[2]."#text"
            $securityid = $eventXML.Event.EventData.Data[3]."#text"
            $privileges = $eventXML.Event.EventData.Data[4]."#text"
            if ($privileges -Match "SeDebugPrivilege") { #Admin account with SeDebugPrivilege
                if ($alert_all_admin){ # Alert for every admin logon
                    $obj.Message  = "Logon with SeDebugPrivilege (admin access)"
                    $obj.Results  = "Username: $username`n"
                    $obj.Results += "Domain: $domain`n"
                    $obj.Results += "User SID: $securityid`n"
                    $obj.Results += "Privileges: $privileges"
                    $EventsFound += $obj
                    Write-Output $obj
                }
                # Track User SIDs used during admin logons (can track one account logging into multiple systems)
                $totaladminlogons+=1
                if($adminlogons.ContainsKey($username)){
                    $string=$adminlogons.$username
                    if (-Not ($string -Match $securityid)){ # One username with multiple admin logon SIDs
                        $multipleadminlogons.Set_Item($username,1)
                        $string += " $securityid"
                        $adminlogons.Set_Item($username,$string)
                    }
                }
                Else{
                    $adminlogons.add($username,$securityid)

                    #$adminlogons.$username=$securityid
                }
                #$adminlogons.Set_Item($username,$securitysid)
                #$adminlogons($username)+=($securitysid)
            }
        }
        elseif ($event.LogName -eq 'Security' -and $event.id -eq 4720){
            # A user account was created.
            $username     = $eventXML.Event.EventData.Data[0]."#text"
            $securityid   = $eventXML.Event.EventData.Data[2]."#text"
            $obj.Message  = "New User Created"
            $obj.Results  = "Username: $username`n"
            $obj.Results += "User SID: $securityid`n"
            $EventsFound += $obj
            Write-Output $obj
        }
        elseif($event.LogName -eq 'Security' -and (($event.id -eq 4728) -or ($event.id -eq 4732) -or ($event.id -eq 4756)) ){
            # A member was added to a security-enabled (global|local|universal) group.
            $groupname=$eventXML.Event.EventData.Data[2]."#text"
            # Check if group is Administrators, may later expand to all groups
            if ($groupname -eq "Administrators"){
                $username   = $eventXML.Event.EventData.Data[0]."#text"
                $securityid = $eventXML.Event.EventData.Data[1]."#text"
                switch ($event.id){
                    4728 {$obj.Message = "User added to global $groupname group"}
                    4732 {$obj.Message = "User added to local $groupname group"}
                    4756 {$obj.Message = "User added to universal $groupname group"}
                }
                $obj.Results  = "Username: $username`n"
                $obj.Results += "User SID: $securityid`n"
                $EventsFound += $obj
                Write-Output $obj
            }
        }
        elseif($event.LogName -eq 'Security' -and $event.id -eq 4625){
            # An account failed to log on.
            # Requires auditing logon failures
            $totalfailedlogons += 1
            $username = $eventXML.Event.EventData.Data[5]."#text"
            if($failedlogons.ContainsKey($username)){
                $count = $failedlogons.Get_Item($username)
                $failedlogons.Set_Item($username,$count+1)
            }
            Else{
                $failedlogons.Set_Item($username,1)
                $totalfailedaccounts += 1
            }
            $EventsFound += $obj
            Write-Output $obj
        }
        elseif($event.LogName -eq 'Security' -and $event.id -eq 4673){
            # Sensitive Privilege Use (Mimikatz)
            $totalsensprivuse += 1

            # use -eq here to avoid multiple log notices
            if ($totalsensprivuse -eq $maxtotalsensprivuse) {
                $obj.Message = "Sensititive Privilege Use Exceeds Threshold"
                $obj.Results = "Potentially indicative of Mimikatz, multiple sensitive privilege calls have been made.`n"

                $username   = $eventXML.Event.EventData.Data[1]."#text"
                $domainname = $eventXML.Event.EventData.Data[2]."#text"

                $obj.Results += "Username: $username`n"
                $obj.Results += "Domain Name: $domainname`n"
                $EventsFound += $obj
                Write-Output $obj
            }
        }
        elseif($event.LogName -eq 'Security' -and $event.id -eq 4674){
            # An operation was attempted on a privileged object.
            if ($event.Message){
                $array       = $event.message -split '\n' # Split each line of the message into an array
                $text        = $array[0]
                $application = Remove-Spaces($array[3])
                $user        = Remove-Spaces(($array[4]  -split ':')[1])
                $service     = Remove-Spaces(($array[11] -split ':')[1])
                $application = Remove-Spaces(($array[16] -split ':	')[1])
                $accessreq   = Remove-Spaces(($array[19] -split ':')[1])

                if ($application.ToUpper() -Eq "C:\WINDOWS\SYSTEM32\SERVICES.EXE" `
                        -And $accessreq.ToUpper() -Match "WRITE_DAC") {
                    $obj.Message  = "Possible Hidden Service Attempt"
                    $obj.Command  = ""
                    $obj.Results  = "User requested to modify the Dynamic Access Control (DAC) permissions of a sevice, possibly to hide it from view.`n"
                    $obj.Results += "User: $user`n"
                    $obj.Results += "Target service: $service`n"
                    $obj.Results += "Desired Access: $accessreq`n"
                    $EventsFound += $obj
                    Write-Output $obj
                }
            }
        }
        elseif($event.LogName -eq 'Security' -and $event.id -eq 4648){
            # A logon was attempted using explicit credentials.
            $username       = $eventXML.Event.EventData.Data[1]."#text"
            $hostname       = $eventXML.Event.EventData.Data[2]."#text"
            $targetusername = $eventXML.Event.EventData.Data[5]."#text"
            $sourceip       = $eventXML.Event.EventData.Data[12]."#text"

            # For each #4648 event, increment a counter in $passspraytrack. If that counter exceeds
            # $passsprayloginmax, then check for $passsprayuniqusermax also exceeding threshold and raise a notice.
            if ($passspraytrack[$targetusername] -eq $null) {
                $passspraytrack[$targetusername] = 1
            } else {
                $passspraytrack[$targetusername] += 1
            }
            if ($passspraytrack[$targetusername] -gt $passsprayloginmax) {
                # This user account has exceedd the threshoold for explicit logins. Identify the total number
                # of accounts that also have similar explicit login patterns.
                $passsprayuniquser=0
                foreach($key in $passspraytrack.keys) {
                    if ($passspraytrack[$key] -gt $passsprayloginmax) {
                        $passsprayuniquser += 1
                    }
                }
                if ($passsprayuniquser -gt $passsprayuniqusermax) {
                    $usernames = ""
                    foreach($key in $passspraytrack.keys) {
                        $usernames += $key
                        $usernames += " "
                    }
                    $obj.Message  = "Distributed Account Explicit Credential Use (Password Spray Attack)"
                    $obj.Results  = "The use of multiple user account access attempts with explicit credentials is "
                    $obj.Results += "an indicator of a password spray attack.`n"
                    $obj.Results += "Target Usernames: $usernames`n"
                    $obj.Results += "Accessing Username: $username`n"
                    $obj.Results += "Accessing Host Name: $hostname`n"
                    $EventsFound += $obj
                    Write-Output $obj
                    $passspraytrack = @{} # Reset
                }
            }
        }
        elseif ($event.LogName -eq 'Security' -and $event.id -eq 1102){
            # The Audit log file was cleared.
            if ($event.Message){
                # Security 1102 Message is a blob of text that looks like this:
                # The audit log was cleared.
                $array = $event.message -split '\n' # Split each line of the message into an array
                $user  = Remove-Spaces($array[3])
            }
            $obj.Message  = "Audit Log Clear"
            $obj.Results  = "The Audit log was cleared.`n"
            $obj.Results += $user
            $EventsFound += $obj
            Write-Output $obj
        }
        elseif ($event.LogName -eq 'System' -and $event.id -eq 7045){
            # A service was installed in the system.
            $servicename = $eventXML.Event.EventData.Data[0]."#text"
            $commandline = $eventXML.Event.EventData.Data[1]."#text"
            # Check for suspicious service name
            $text = (Check-Regex $servicename 1)
            if ($text){
                $obj.Message  = "New Service Created"
                $obj.Command  = $commandline
                $obj.Results  = "Service name: $servicename`n"
                $obj.Results += $text
#                $EventsFound += $obj
#                Write-Output $obj
            }
            # Check for suspicious cmd
            if ($commandline){
                $servicecmd = 1 # CLIs via service creation get extra checks
                Check-Command -EventID 7045 -commandline $commandline
            }
        }
        elseif ($event.LogName -eq 'System' -and $event.id -eq 7030){
            # The ... service is marked as an interactive service.  However, the system is configured
            # to not allow interactive services.  This service may not function properly.
            $servicename=$eventXML.Event.EventData.Data."#text"
            $obj.Message  = "Interactive service warning"
            $obj.Results  = "Service name: $servicename`n"
            $obj.Results += "Malware (and some third party software) trigger this warning"
            # Check for suspicious service name
            $servicecmd=1 # CLIs via service creation get extra check
            $obj.Results += (Check-Regex $servicename 1)
            $EventsFound += $obj
            Write-Output $obj
        }
        elseif ($event.LogName -eq 'System' -and $event.id -eq 7036){
            # The ... service entered the stopped|running state.
            $servicename=$eventXML.Event.EventData.Data[0]."#text"
            $text = (Check-Regex $servicename 1)
            if ($text){
                $obj.Message  = "Suspicious Service Name"
                $obj.Results  = "Service name: $servicename`n"
                $obj.Results += $text
                $EventsFound += $obj
                Write-Output $obj
            }
        }
        elseif ($event.LogName -eq 'System' -and $event.id -eq 7040){
            # The start type of the Windows Event Log service was changed from auto start to disabled.
            $servicename = $eventXML.Event.EventData.Data[0]."#text"
            $action      = $eventXML.Event.EventData.Data[1]."#text"
            if ($servicename -ccontains "Windows Event Log") {
                $obj.Results  = "Service name: $servicename`n"
                $obj.Results += $text
                if ($action -eq "disabled") {
                    $obj.Message  = "Event Log Service Stopped"
                    $obj.Results += "Selective event log manipulation may follow this event."
                } elseif ($action -eq "auto start") {
                    $obj.Message  = "Event Log Service Started"
                    $obj.Results += "Selective event log manipulation may precede this event."
                }
                $EventsFound += $obj
                Write-Output $obj
            }
        }
        elseif ($event.LogName -eq 'System' -and $event.id -eq 104){
            # The System log file was cleared.
            $obj.Message  = "System Log Clear"
            $obj.Results  = "The System log was cleared."
            $EventsFound += $obj
            Write-Output $obj
        }
        elseif ($event.LogName -eq 'Application' -and (($event.id -eq 2) -and ($event.Providername -eq "EMET")) ){
            # EMET Block
            $obj.Message = "EMET Block"
            if ($event.Message){
                # EMET Message is a blob of text that looks like this:
                $array        = $event.message -split '\n' # Split each line of the message into an array
                $text         = $array[0]
                $application  = Remove-Spaces($array[3])
                $command      = $application -Replace "^Application: ",""
                $username     = Remove-Spaces($array[4])
                $obj.Message  = "EMET Block"
                $obj.Command  = "$command"
                $obj.Results  = "$text`n"
                $obj.Results += "$username`n"
            }
            Else{
                # If the message is blank: EMET is not installed locally.
                # This occurs when parsing remote event logs sent from systems with EMET installed
                $obj.Message="Warning: EMET Message field is blank. Install EMET locally to see full details of this alert"
            }
            $EventsFound += $obj
            Write-Output $obj
        }
        elseif ($event.LogName -eq 'Microsoft-Windows-AppLocker/EXE and DLL' -and $event.id -eq 8003){
            # ...was allowed to run but would have been prevented from running if the AppLocker policy were enforced.
            $obj.Message  = "Applocker Warning"
            $command      = $event.message -Replace " was .*$",""
            $obj.Command  = $command
            $obj.Results  = $event.message
            $EventsFound += $obj
            Write-Output $obj
        }
        elseif ($event.LogName -eq 'Microsoft-Windows-AppLocker/EXE and DLL' -and $event.id -eq 8004){
            $obj.Message = "Applocker Block"
            # ...was prevented from running.
            $command      = $event.message -Replace " was .*$",""
            $obj.Command  = $command
            $obj.Results  = $event.message
            $EventsFound += $obj
            Write-Output $obj
        }
        elseif ($event.LogName -eq 'Windows PowerShell' -and $event.id -eq 800){
            $commandline = $eventXML.Event.EventData.Data[1]
            # Multiline replace, remove everything before "CommandLine ="
            $commandline = $commandline 
            # Removes excess beginning and ending spaces
            $commandline = $commandline.trim()
            if ($commandline){
                Check-Command -EventID 800 -commandline $commandline
            }
        }
        elseif ($event.LogName -eq 'Microsoft-Windows-PowerShell/Operational' -and $event.id -eq 4103){
            $commandline = $eventXML.Event.EventData.Data[2]."#text"
            if ($commandline -Match "Host Application"){
                # Multiline replace, remove everything before "Host Application = "
                $commandline = $commandline -Replace "(?ms)^.*Host.Application = ",""
                # Remove every line after the "Host Application = " line.
                $commandline = $commandline -Replace "(?ms)`n.*$",""
                if ($commandline){
                    Check-Command -EventID 4103 -commandline $commandline
                }
            }
        }
        elseif ($event.LogName -eq 'Microsoft-Windows-PowerShell/Operational' -and $event.id -eq 4104){
            # This section requires PowerShell command logging for event 4104 , which seems to be default with
            # Windows 10, but may not not the default with older Windows versions (which may log the script
            # block but not the command that launched it).
            # Caveats included because more testing of various Windows versions is needed
            #
            # If the command itself is not being logged:
            # Add the following to \Windows\System32\WindowsPowerShell\v1.0\profile.ps1
            # $LogCommandHealthEvent = $true
            # $LogCommandLifecycleEvent = $true
            #
            # This ignores scripts and grabs PowerShell CLIs
            if (-not ($eventxml.Event.EventData.Data[4]."#text")){
                    $commandline = $eventXML.Event.EventData.Data[2]."#text"
                    if ($commandline){
                        Check-Command -EventID 4104 -commandline $commandline
                    }
            }
        }
        elseif ($event.LogName -eq 'Microsoft-Windows-Sysmon/Operational' -and $event.id -eq 1){
            $creator     = $eventXML.Event.EventData.Data[14]."#text"
            $commandline = $eventXML.Event.EventData.Data[4]."#text"
            if ($commandline){
                Check-Command -EventID 1 -commandline $commandline
            }
        }
        elseif ($event.LogName -eq 'Microsoft-Windows-Sysmon/Operational' -and $event.id -eq 7){
            # Check for unsigned EXEs/DLLs:
            # This can be very chatty, so it's disabled.
            # Set $checkunsigned to 1 (global variable section) to enable:
            if ($checkunsigned){
                if ($eventXML.Event.EventData.Data[6]."#text" -eq "false"){
                    $obj.Message ="Unsigned Image (DLL)"
                    $image       = $eventXML.Event.EventData.Data[3]."#text"
                    $imageload   = $eventXML.Event.EventData.Data[4]."#text"
                    # $hash=$eventXML.Event.EventData.Data[5]."#text"
                    $obj.Command  = $imageload
                    $obj.Results  = "Loaded by: $image"
                    $EventsFound += $obj
                }
            }
            $EventsFound += $obj
            Write-Output $obj
        }
        #>
    }










    # Iterate through admin logons hashtable (key is $username)
    foreach ($username in $adminlogons.Keys) {
        $securityid=$adminlogons.Get_Item($username)
        if($multipleadminlogons.$username){
            $obj.Message="Multiple admin logons for one account"
            $obj.Results= "Username: $username`n"
            $obj.Results += "User SID Access Count: " + $securityid.split().Count
            $obj.EventId = 4672
            $EventsFound += $obj
            Write-Output $obj
        }
    }






    # Iterate through failed logons hashtable (key is $username)
    foreach ($username in $failedlogons.Keys) {
        $count=$failedlogons.Get_Item($username)
        if ($count -gt $maxfailedlogons){
            $obj.Message="High number of logon failures for one account"
            $obj.Results= "Username: $username`n"
            $obj.Results += "Total logon failures: $count"
            $obj.EventId = 4625
            $EventsFound += $obj
            Write-Output $obj
        }
    }






    # Password spraying:
    if (($totalfailedlogons -gt $maxfailedlogons) -and ($totalfailedaccounts -gt 1)) {
        $obj.Message="High number of total logon failures for multiple accounts"
        $obj.Results= "Total accounts: $totalfailedaccounts`n"
        $obj.Results+= "Total logon failures: $totalfailedlogons`n"
        $obj.EventId = 4625
        $EventsFound += $obj
        Write-Output $obj
    }
}












function Check-Command {
    Param($EventID,$commandline)

    $text   = ""
    $base64 = ""
    # Check to see if command is whitelisted
    foreach ($entry in $whitelist) {
        if ($commandline -Match $entry.regex) {
            # Command is whitelisted, return nothing
            return
        }
    }
    if ($commandline.length -gt $minlength){
        $text += "Long Command Line: greater than $minlength bytes`n"
    }
    $text += (Check-Obfu $commandline)
    $text += (Check-Regex $commandline 0)
    $text += (Check-Creator $commandline $creator)
    # Check for base64 encoded function, decode and print if found
    # This section is highly use case specific, other methods of base64 encoding and/or compressing may evade these checks
    if ($commandline -Match "\-enc.*[A-Za-z0-9/+=]{100}"){
        $base64 = $commandline -Replace "^.* \-Enc(odedCommand)? ",""
    }
    elseif ($commandline -Match ":FromBase64String\("){
        $base64 = $commandline -Replace "^.*:FromBase64String\(\'*",""
        $base64 = $base64 -Replace "\'.*$",""
    }
    if ($base64){
        if ($commandline -Match "Compression.GzipStream.*Decompress"){
            # Metasploit-style compressed and base64-encoded function. Uncompress it.
            $decoded      = New-Object IO.MemoryStream(,[Convert]::FromBase64String($base64))
            $uncompressed = (New-Object IO.StreamReader(((New-Object IO.Compression.GzipStream($decoded,[IO.Compression.CompressionMode]::Decompress))),[Text.Encoding]::ASCII)).ReadToEnd()
            $obj.Decoded  = $uncompressed
            $text        += "Base64-encoded and compressed function`n"
        }
        else{
            $decoded = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($base64))
            $obj.Decoded=$decoded
            $text += "Base64-encoded function`n"
            $text += (Check-Obfu $decoded)
            $text += (Check-Regex $decoded 0)
        }
    }
    if ($text){
        if ($servicecmd){
            $obj.Message = "Suspicious Service Command"
            $obj.Results = "Service name: $servicename`n"
        }
        Else{
            $obj.Message = "Suspicious Command Line"
        }
        $obj.Command  = $commandline
        $obj.Results += $text
        $obj.EventID  = $EventID
        $EventsFound += $obj
        Write-Output $obj
    }
    return
}

function Check-Regex{
    param(
        $string,
        $type
    )
    $regextext = "" # Local variable for return output
    foreach ($regex in $regexes){
        if ($regex.Type -eq $type) { # Type is 0 for Commands, 1 for services. Set in regexes.csv
            if ($string -Match $regex.regex) {
               $regextext += $regex.String + "`n"
            }
        }
    }
    #if ($regextext){
    #   $regextext = $regextext.Substring(0,$regextext.Length-1) # Remove final newline.
    #}
    return $regextext
}

function Check-Obfu{
    param(
        $string
    )
    # Check for special characters in the command. Inspired by Invoke-Obfuscation: https://twitter.com/danielhbohannon/status/778268820242825216

    $obfutext        = ""       # Local variable for return output
    $lowercasestring = $string.ToLower()
    $length          = $lowercasestring.length
    $noalphastring   = $lowercasestring -replace "[a-z0-9/\;:|.]"
    $nobinarystring  = $lowercasestring -replace "[01]" # To catch binary encoding

    # Calculate the percent alphanumeric/common symbols
    if ($length -gt 0){
        $percent = (($length - $noalphastring.length) / $length)

        # Adjust minpercent for very short commands, to avoid triggering short warnings
        if (($length / 100) -lt $minpercent){
            $minpercent = ($length / 100)
        }
        if ($percent -lt $minpercent){
            $percent   = "{0:P0}" -f $percent      # Convert to a percent
            $obfutext += "Possible command obfuscation: only $percent alphanumeric and common symbols`n"
        }

        # Calculate the percent of binary characters
        $percent = (($nobinarystring.length - $length / $length) / $length)
        $binarypercent = 1 - $percent
        if ($binarypercent -gt $maxbinary){

            #$binarypercent = 1-$percent
            $binarypercent = "{0:P0}" -f $binarypercent      # Convert to a percent
            $obfutext     += "Possible command obfuscation: $binarypercent zeroes and ones (possible numeric or binary encoding)`n"
        }
    }
    return $obfutext
}

function Check-Creator{
    param(
        $command,
        $creator
    )
    $creatortext = ""  # Local variable for return output
    if ($creator){
        if ($command -Match "powershell"){
            if ($creator -Match "PSEXESVC"){
                $creatortext += "PowerShell launched via PsExec: $creator`n"
            }
            elseif($creator -Match "WmiPrvSE"){
                $creatortext += "PowerShell launched via WMI: $creator`n"
            }
        }
    }
    return $creatortext
}


function Remove-Spaces {
    param(
        $string
    )
    # Changes this:   Application       : C:\Program Files (x86)\Internet Explorer\iexplore.exe
    #      to this: Application: C:\Program Files (x86)\Internet Explorer\iexplore.exe
    $string = $string.trim() -Replace "\s+:",":"
    return $string
}

. Invoke-DeepBlueAll

$EventsFound

