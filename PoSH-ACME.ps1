<#
.SYNOPSIS  
      ______             ____  __               _____     ____  ___    __  _____  
     |   _  \           /  __||  |             /  _  \   / ___\ |  \  /  | | ___| 
     |  |_)  | _____   |  (   |  |___   ____  |  (_)  | / /     |   \/   | | |_   
     |   ___/ /  _  \   \  \  |   _  \ |____| |   _   || |      | |\  /| | |  _|  
     |  |    |  (_)  | __)  | |  | |  |       |  | |  | \ \____ | | \/ | | | |__  
     |__|     \_____/ |____/  |__| |__|       |__| |__|  \____/ |_|    |_| |____| 
    ==============================================================================
     Windows Remote Management (WinRM) Is Necessary For Endpoint Data Collection.
     PowerShell - Automated Collection Made Easy (ACME) For The Security Analyst!
     ACME: The Point At Which Something Is The Best, Perfect, Or Most Successful.
    ==============================================================================
    
    PoSh-ACME is primarily a set of Windows Management Instrumentation interface (WMI) scripts that investigators and 
    forensic analysts can use to retrieve information from a Windows OS network environment. The scripts uses WMI and 
    native commands to pull this information from each target operating system. Therefore, this script will need to be 
    executed with a user that has the necessary privileges. Addtionally, PoSh-ACME can pull Active Directory information 
    on users and computers, as well as retrieve grouped Event Logs for auditing. PoSh-ACME currently also finds various
    unique findings (will work on a percentage value sometime, like %10). Retrieved information is not only compiled
    into a single file for easy viewing, but is also saved as Collected Results (Uncompiled) for each target host.

    PoSh-ACME will retrieve the following data from an individual machine or a group of systems:       
        Basic Collection
          - Audit Event Logs (Past 3 days, Limited to 100 Logs)
          - Collected Results (Uncompiled)
          - Domain Information
          - Extended Collection
          - Unique Findings
          - Autoruns - Startup Commands
          - BIOS Information
          - Computer Information
          - Dates - Install, Boot, and Localtime
          - Disk Information
          - DLLs Accessed by Processes
          - Domain Information
          - Drivers - Detailed
          - Drivers - Signed Information
          - Drivers - Valid Signatures
          - Drivers
          - Environmental Variables
          - Event Logs (Last 1000) Application Errors
          - Event Logs (Last 1000) Application
          - Event Logs (Last 1000) Security
          - Event Logs (Last 1000) System Errors
          - Event Logs (Last 1000) System
          - Firewall Rules
          - Group Information
          - Logged-On User Information
          - Logon Information
          - Mapped Drives
          - Memory (RAM) Capacity Information
          - Memory (RAM) Physical Information
          - Memory (RAM) Utilization
          - Memory Performance Monitoring Data
          - Network Connections (netstat tcp)
          - Network Connections (netstat udp)
          - Network Connections (Windows-Based Environment)
          - Network Settings
          - Plug and Play Devices
          - Printers
          - Processes (Improved with Hashes and Parent Process Names)
          - Processes
          - Proxy Rules
          - Scheduled Tasks (schtasks)
          - Security Patches
          - Services
          - Shares
          - Software Installed
          - System Information
          - USB Controller Device Connections
          - User Information
        Domain Information
          - Account Contact Information
          - Account Details and User Information
          - Account Email Addresses
          - Account Logon & Passowrd Policy
          - Account Phone Numbers
          - Accounts - Last Logon Timestamps
          - Accounts - Primary Group is Domain Users
          - Accounts - Primary Group is Guests
          - Accounts That Are Disabled
          - Accounts That Are Inactive for Longer Than 4 Weeks
          - Active Directory Group Membership
          - Active Directory Groups
        Extended Collection
          - Network Statistics ICMP
          - Network Statistics ICMPv6
          - Network Statistics IP
          - Network Statistics IPv6
          - Network Statistics TCP
          - Network Statistics TCPv6
          - Network Statistics UDP
          - Network Statistics UDPv6
          - Network Statistics ICMP
          - Network Statistics ICMPv6
          - Network Statistics IP
          - Network Statistics IPv6
          - Network Statistics TCP
          - Network Statistics TCPv6
          - Network Statistics UDP
          - Network Statistics UDPv6
        Additional Info
          - Computer List - Collected From
          - Computer List - Not Collected
          - Computer List - Original List

        Troubleshooting remote connection failures
            about_Remote_Troubleshooting
            about_Remote
            about_Remote_Requirements
                        

.EXAMPLE

    This will run PoSh-ACME.ps1 and provide prompts that will tailor your collection.
         PowerShell.exe -ExecutionPolicy ByPass -NoProfile -File .\PoSh-ACME.ps1

    Provide all arguments to immediately tailor the collection and avoid user interaction at the menu.
        .\PoSH-ACMEv3.ps1 -SingleComputerName localhost -LimitNumberOfEventLogsCollectTo 10 -AuditEventLogs -LimitDaysOfEventLogsCollectTo 1 -LocalhostIsNotDomainServer

    Provide partial arguments if desired.
        .\PoSh-ACME.ps1 -SingleComputerName 192.168.100.7
        
        .\PoSh-ACME.ps1 -SingleComputerName localhost -IsDomainServer


.Link
    http://lmgtfy.com/?q=PowerShell

.NOTES  
    File Name      : PoSh-ACME.ps1
    Version        : v.0.1
    Author         : dako
    Credits        : @WiredPulse for the base idea and host selection portion.
    Prerequisite   : PowerShell v2
                   : WinRM
    Created        : 08 April 18


#>



[cmdletbinding()]
param(
    [parameter(Position=1,Mandatory=$False)]
        [string]$SingleComputerName,
    [parameter(Position=2,Mandatory=$False)]
        [string]$LimitNumberOfEventLogsCollectTo,
    [parameter(Position=2,Mandatory=$False)]
        [string]$LimitDaysOfEventLogsCollectTo,
    [parameter(Mandatory=$False)]
        [switch]$LocalhostIsDomainServer,
    [parameter(Mandatory=$False)]
        [switch]$LocalhostIsNotDomainServer,
    [parameter(Mandatory=$False)]
        [switch]$AuditEventLogs,
    [parameter(Mandatory=$False)]
        [switch]$DoNotAuditEventLogs
    
    )


# ============================================================================================================================================================
# Variables
# ============================================================================================================================================================
    # Universally sets the ErrorActionPreference to Silently Continue
    $ErrorActionPreference = "SilentlyContinue"
    
    # Location PoSh-ACME will save files
    $PoShLocation = "C:\$env:HOMEPATH\Desktop\PoSh-ACME Results"
    
    # Locaiton of Uncompiled Results
    $CollectedResultsUncompiled = "Collected Results (Uncompiled)"
    
    # This is used to store hosts that are not going be collected from
    $global:ComputerListNotCollected = @()
    
    # This deleay is introduced to allow certain collection commands to complete gathering data before it pulls back the data
    # Specificially in instances where Invoke-WmiMethod is being used to execute DOS or native commands on remote hosts and needs to finish
    # Increase this Start-Sleep variable in the event you determine that not all data is being pulled back as the copy command can pull back incomplete results
    $global:SleepTime = 5
    
    # This is used to for the Progress Bar and should not be changed.
    $global:TotalPercentCompleted = 1
    $global:TotalTestPercentCompleted = 1
    
    # This is used to calculate the total completion when processing. It should be the equal to the total number of collections
    # This is initially zero and will be added upon depending on which sections are ran
    $global:NumberOfSections = 0
    
    # This provides the column padding offset
    $global:ColumnPadding = 100

    # This is the number of Event Logs to collect by default
    $LimitNumberOfEventLogsCollectToDefault = 100
    $Today = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime((Get-Date))

    # The following two are ssed during Event Log Collection - Collect logs since this date
    $LimitDaysOfEventLogsCollectToDefault = 3
    


# ============================================================================================================================================================
# ============================================================================================================================================================
# Function Name 'ListComputers' - Takes entered domain and lists all computers
# ============================================================================================================================================================
# ============================================================================================================================================================

Function ListComputers
{
    $DN = ""
    $Response = ""
    $DNSName = ""
    $DNSArray = ""
    $objSearcher = ""
    $colProplist = ""
    $objComputer = ""
    $objResults = ""
    $colResults = ""
    $Computer = ""
    $comp = ""
    New-Item -type file -force "$Script:Folder_Path\Computer_List$Script:curDate.txt" | Out-Null
    $Script:Compute = "$Script:Folder_Path\Computer_List$Script:curDate.txt"
    $strCategory = "(ObjectCategory=Computer)"
    
    Write-Host "`nWould you like to automatically pull from your domain or provide your own domain? [1]" -ForegroundColor Yellow
    Write-Host "Auto pull uses the current domain you are on, if you need to select a different domain use manual."
    $response = Read-Host " [1] Auto Pull `n [2] Manual Selection`n "
    
    If($Response -eq "1" -or $Response -eq "" ) {
        $DNSName = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().Name
        If($DNSName -ne $Null) {
            $DNSArray = $DNSName.Split(".") 
            for ($x = 0; $x -lt $DNSArray.Length ; $x++) {  
                if ($x -eq ($DNSArray.Length - 1)){$Separator = ""}else{$Separator =","} 
                [string]$DN += "DC=" + $DNSArray[$x] + $Separator  } }
        $Script:Domain = $DN
        echo "Pulled computers from: "$Script:Domain 
        $objSearcher = New-Object System.DirectoryServices.DirectorySearcher("LDAP://$Script:Domain")
        $objSearcher.Filter = $strCategory
        $objSearcher.PageSize = 100000
        $objSearcher.SearchScope = "SubTree"
        $colProplist = "name"
        foreach ($i in $colPropList) {
            $objSearcher.propertiesToLoad.Add($i) }
        $colResults = $objSearcher.FindAll()
        foreach ($objResult in $colResults) {
            $objComputer = $objResult.Properties
            $comp = $objComputer.name
            echo $comp | Out-File $Script:Compute -Append }
        $Script:ComputerList = (Get-Content $Script:Compute) | Sort-Object
    }
	elseif($Response -eq "2")
    {
        Write-Host "Would you like to automatically pull from your domain or provide your own domain?" -ForegroundColor Yellow
        Write-Host "Auto pull uses the current domain you are on, if you need to select a different domain use manual."
        $Script:Domain = Read-Host "Enter your Domain here: OU=West,DC=Company,DC=com"
        If ($Script:Domain -eq $Null) {Write-Host "You did not provide a valid response."; . ListComputers}
        echo "Pulled computers from: "$Script:Domain 
        $objOU = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$Script:Domain")
        $objSearcher = New-Object System.DirectoryServices.DirectorySearcher
        $objSearcher.SearchRoot = $objOU
        $objSearcher.Filter = $strCategory
        $objSearcher.PageSize = 100000
        $objSearcher.SearchScope = "SubTree"
        $colProplist = "name"
        foreach ($i in $colPropList) { $objSearcher.propertiesToLoad.Add($i) }
        $colResults = $objSearcher.FindAll()
        foreach ($objResult in $colResults) {
            $objComputer = $objResult.Properties
            $comp = $objComputer.name
            echo $comp | Out-File $Script:Compute -Append }
        $Script:ComputerList = (Get-Content $Script:Compute) | Sort-Object
    }
    else {
        Write-Host "You did not supply a correct response, Please select a response." -foregroundColor Red
        . ListComputers }
}

# ============================================================================================================================================================
# Function Name 'ListTextFile' - Enumerates Computer Names in a text file
# Create a text file and enter the names of each computer. One computer
# name per line. Supply the path to the text file when prompted.
# ============================================================================================================================================================
Function ListTextFile 
{
	$file_Dialog = ""
    $file_Name = ""
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $file_Dialog = New-Object system.windows.forms.openfiledialog
    $file_Dialog.InitialDirectory = "$env:USERPROFILE\Desktop"
    $file_Dialog.MultiSelect = $false
    $file_Dialog.showdialog()
    $file_Name = $file_Dialog.filename
    $Comps = Get-Content $file_Name
    If ($Comps -eq $Null) {
        Write-Host "Your file was empty. You must select a file with at least one computer in it." -ForegroundColor Red
        . ListTextFile }
    Else
    {
        $Script:ComputerList = @()
        ForEach ($Comp in $Comps)
        {
            If ($Comp -match "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/\d{1,2}")
            {
                $Temp = $Comp.Split("/")
                $IP = $Temp[0]
                $Mask = $Temp[1]
                . Get-Subnet-Range $IP $Mask
                $Script:ComputerList += $Script:IPList
            }
            Else
            {
                $Script:ComputerList += $Comp
            }
        }
    }
}

Function Get-Subnet-Range {
    #.Synopsis
    # Lists all IPs in a subnet.
    #.Example
    # Get-Subnet-Range -IP 192.168.1.0 -Netmask /24
    #.Example
    # Get-Subnet-Range -IP 192.168.1.128 -Netmask 255.255.255.128        
    Param(
        [string]
        $IP,
        [string]
        $netmask
    )  
    Begin {
        $IPs = New-Object System.Collections.ArrayList

        Function Get-NetworkAddress {
            #.Synopsis
            # Get the network address of a given lan segment
            #.Example
            # Get-NetworkAddress -IP 192.168.1.36 -mask 255.255.255.0
            Param (
                [string]
                $IP,
                [string]
                $Mask,
                [switch]
                $Binary
            )
            Begin {
                $NetAdd = $null
            }
            Process {
                $BinaryIP = ConvertTo-BinaryIP $IP
                $BinaryMask = ConvertTo-BinaryIP $Mask
                0..34 | %{
                    $IPBit = $BinaryIP.Substring($_,1)
                    $MaskBit = $BinaryMask.Substring($_,1)
                    IF ($IPBit -eq '1' -and $MaskBit -eq '1') {
                        $NetAdd = $NetAdd + "1"
                    } elseif ($IPBit -eq ".") {
                        $NetAdd = $NetAdd +'.'
                    } else {
                        $NetAdd = $NetAdd + "0"
                    }
                }
                if ($Binary) {
                    return $NetAdd
                } else {
                    return ConvertFrom-BinaryIP $NetAdd
                }
            }
        }
       
        Function ConvertTo-BinaryIP {
            #.Synopsis
            # Convert an IP address to binary
            #.Example
            # ConvertTo-BinaryIP -IP 192.168.1.1
            Param (
                [string]
                $IP
            )
            Process {
                $out = @()
                Foreach ($octet in $IP.split('.')) {
                    $strout = $null
                    0..7|% {
                        IF (($octet - [math]::pow(2,(7-$_)))-ge 0) {
                            $octet = $octet - [math]::pow(2,(7-$_))
                            [string]$strout = $strout + "1"
                        } else {
                            [string]$strout = $strout + "0"
                        }  
                    }
                    $out += $strout
                }
                return [string]::join('.',$out)
            }
        }
 
 
        Function ConvertFrom-BinaryIP {
            #.Synopsis
            # Convert from Binary to an IP address
            #.Example
            # Convertfrom-BinaryIP -IP 11000000.10101000.00000001.00000001
            Param (
                [string]
                $IP
            )
            Process {
                $out = @()
                Foreach ($octet in $IP.split('.')) {
                    $strout = 0
                    0..7|% {
                        $bit = $octet.Substring(($_),1)
                        IF ($bit -eq 1) {
                            $strout = $strout + [math]::pow(2,(7-$_))
                        }
                    }
                    $out += $strout
                }
                return [string]::join('.',$out)
            }
        }

        Function ConvertTo-MaskLength {
            #.Synopsis
            # Convert from a netmask to the masklength
            #.Example
            # ConvertTo-MaskLength -Mask 255.255.255.0
            Param (
                [string]
                $mask
            )
            Process {
                $out = 0
                Foreach ($octet in $Mask.split('.')) {
                    $strout = 0
                    0..7|% {
                        IF (($octet - [math]::pow(2,(7-$_)))-ge 0) {
                            $octet = $octet - [math]::pow(2,(7-$_))
                            $out++
                        }
                    }
                }
                return $out
            }
        }
 
        Function ConvertFrom-MaskLength {
            #.Synopsis
            # Convert from masklength to a netmask
            #.Example
            # ConvertFrom-MaskLength -Mask /24
            #.Example
            # ConvertFrom-MaskLength -Mask 24
            Param (
                [int]
                $mask
            )
            Process {
                $out = @()
                [int]$wholeOctet = ($mask - ($mask % 8))/8
                if ($wholeOctet -gt 0) {
                    1..$($wholeOctet) |%{
                        $out += "255"
                    }
                }
                $subnet = ($mask - ($wholeOctet * 8))
                if ($subnet -gt 0) {
                    $octet = 0
                    0..($subnet - 1) | %{
                         $octet = $octet + [math]::pow(2,(7-$_))
                    }
                    $out += $octet
                }
                for ($i=$out.count;$i -lt 4; $I++) {
                    $out += 0
                }
                return [string]::join('.',$out)
            }
        }

        Function Get-IPRange {
            #.Synopsis
            # Given an Ip and subnet, return every IP in that lan segment
            #.Example
            # Get-IPRange -IP 192.168.1.36 -Mask 255.255.255.0
            #.Example
            # Get-IPRange -IP 192.168.5.55 -Mask /23
            Param (
                [string]
                $IP,
               
                [string]
                $netmask
            )
            Process {
                iF ($netMask.length -le 3) {
                    $masklength = $netmask.replace('/','')
                    $Subnet = ConvertFrom-MaskLength $masklength
                } else {
                    $Subnet = $netmask
                    $masklength = ConvertTo-MaskLength -Mask $netmask
                }
                $network = Get-NetworkAddress -IP $IP -Mask $Subnet
               
                [int]$FirstOctet,[int]$SecondOctet,[int]$ThirdOctet,[int]$FourthOctet = $network.split('.')
                $TotalIPs = ([math]::pow(2,(32-$masklength)) -2)
                $blocks = ($TotalIPs - ($TotalIPs % 256))/256
                if ($Blocks -gt 0) {
                    1..$blocks | %{
                        0..255 |%{
                            if ($FourthOctet -eq 255) {
                                If ($ThirdOctet -eq 255) {
                                    If ($SecondOctet -eq 255) {
                                        $FirstOctet++
                                        $secondOctet = 0
                                    } else {
                                        $SecondOctet++
                                        $ThirdOctet = 0
                                    }
                                } else {
                                    $FourthOctet = 0
                                    $ThirdOctet++
                                }  
                            } else {
                                $FourthOctet++
                            }
                            Write-Output ("{0}.{1}.{2}.{3}" -f `
                            $FirstOctet,$SecondOctet,$ThirdOctet,$FourthOctet)
                        }
                    }
                }
                $sBlock = $TotalIPs - ($blocks * 256)
                if ($sBlock -gt 0) {
                    1..$SBlock | %{
                        if ($FourthOctet -eq 255) {
                            If ($ThirdOctet -eq 255) {
                                If ($SecondOctet -eq 255) {
                                    $FirstOctet++
                                    $secondOctet = 0
                                } else {
                                    $SecondOctet++
                                    $ThirdOctet = 0
                                }
                            } else {
                                $FourthOctet = 0
                                $ThirdOctet++
                            }  
                        } else {
                            $FourthOctet++
                        }
                        Write-Output ("{0}.{1}.{2}.{3}" -f `
                        $FirstOctet,$SecondOctet,$ThirdOctet,$FourthOctet)
                    }
                }
            }
        }
    }
    Process {
        #get every ip in scope
        Get-IPRange $IP $netmask | %{
        [void]$IPs.Add($_)
        }
        $Script:IPList = $IPs
    }
}



# ============================================================================================================================================================
# Function Name 'SingleEntry' - Enumerates Computer from user input
# ============================================================================================================================================================
Function SingleEntry 
{
    Write-Host "`nEnter Computer Name or IP (1.1.1.1) or IP Subnet (1.1.1.1/24)" -ForegroundColor Yellow
    $Comp = Read-Host " "
    If ($Comp -eq $Null) { . SingleEntry } 
    ElseIf ($Comp -match "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/\d{1,2}")
    {
        $Temp = $Comp.Split("/")
        $IP = $Temp[0]
        $Mask = $Temp[1]
        . Get-Subnet-Range $IP $Mask
        $Script:ComputerList = $Script:IPList
    }
    Else
    { $Script:ComputerList = $Comp}
}



# ============================================================================================================================================================
# ============================================================================================================================================================
# The following functions provide status information for the automated collection of remote hosts
# ============================================================================================================================================================
# ============================================================================================================================================================

function CollectionStartMessage {
    # Gets the time at which the collection is started
    $global:CollectionTimerStart = Get-Date

    # Outputs the message that the collection has started
    Write-Host "Collecting: " -ForegroundColor Yellow -NoNewline
    Write-Host $CollectionName -ForegroundColor White -NoNewline   
}

function CollectionProgressStatus {
    # Provides the banner that states the progess of the collection and overall script
    Write-Progress `
        -Activity "Collecting Data From: $TargetComputer" `
        -PercentComplete (($IncrementBar / $global:ComputerList.Count) * 100) `
        -CurrentOperation "$([math]::Round($($global:TotalPercentCompleted / $($global:ComputerList.Count * $global:NumberOfSections) * 100),2))% Completed"
        #-Status $CollectionName
    $global:IncrementBar++
    $global:TotalPercentCompleted++
}
#mark

function CollectionStopMessage {
    # Gets the time at which the collection is finished
    $global:CollectionTimerStop = Get-Date
    $CollectionTime = New-TimeSpan -Start $CollectionTimerStart -End $CollectionTimerStop
    
    # Outputs the message that the collection has completed and how long it took
    $padding = $global:ColumnPadding - ($CollectionName.Length + "Collecting: ".Length)
    Write-Host "Completed: ".PadLeft($padding) -ForegroundColor Green -NoNewline
    Write-Host "$($CollectionTime.ToString())" -ForegroundColor Cyan
}

function CompileCsvFiles([string]$LocationOfCSVsToCompile, [string]$LocationToSaveCompiledCSV) {
    # This function compiles the .csv files in the collection directory which outputs in the parent directory
    # The first line (collumn headers) is only copied once from the first file compiled, then skipped for the rest
    $getFirstLine = $true
    get-childItem "$LocationOfCSVsToCompile\*.csv" | foreach {
        $filePath = $_
        $Lines =  $Lines = Get-Content $filePath  
        $LinesToWrite = switch($getFirstLine) {
            $true  {$Lines}
            $false {$Lines | Select -Skip 1}
        }
        $getFirstLine = $false
        Add-Content "$LocationToSaveCompiledCSV" $LinesToWrite -Force
    }  
}



# ============================================================================================================================================================
# ============================================================================================================================================================
# Main PowerShell Collection Get-WmiObject - Commands
# ============================================================================================================================================================
# ============================================================================================================================================================

# The new object is configured as an arraylist for tuples to contain CollecitonName and Command
$WmiObjectCommandList = New-Object System.Collections.ArrayList

# [Tuple]::Create(`
#    'DESCRIPTION USED FOR TERMINAL MESSAGE AND FILENAME',`
#    'COMMAND TO BE RAN'
#    'CSV or TXT -- DEPENDS ON HOW THE COMMAND IS WRITTEN),
$WmiObjectCommandList.AddRange((

[Tuple]::Create(`
    'Computer Information',
    'Get-WmiObject -Class Win32_ComputerSystem -ComputerName $TargetComputer | Select-Object PSComputerName, Description, Manufacturer, Model, SystemType, NumberOfProcessors, TotalPhysicalMemory, EnableDaylightSavingsTime, BootupState, ThermalState, ChassisBootupState, KeyboardPasswordStatus, PowerSupplyState, PartOfDomain, Domain, Roles, Username, PrimaryOwnerName'),
[Tuple]::Create(`
    'Security Patches',
    'Get-WmiObject -Class Win32_QuickFixEngineering -ComputerName $TargetComputer | Select-Object PSComputerName, HotFixID, Description, InstalledBy, InstalledOn'),
[Tuple]::Create(`
    'Services',
    'Get-WmiObject -Class Win32_Service -ComputerName $TargetComputer | Select-Object PSComputerName, State, Name, ProcessID, Description, PathName, Started, StartMode, StartName | Sort-Object PSComputerName, State, Name'),
[Tuple]::Create(`
    'Processes',
    'Get-WmiObject -Class Win32_Process -ComputerName $TargetComputer | Select-Object -Property PSComputerName, Name, ProcessID, ParentProcessID, Path, WorkingSetSize, Handle, HandleCount, ThreadCount, CreationDate'),
[Tuple]::Create(`
    'Processes (Improved with Hashes and Parent Process Names)',
    '$ErrorActionPreference="SilentlyContinue" ; function Get-FileHash{param ([string] $Path ) $HashAlgorithm = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider ; $Hash=[System.BitConverter]::ToString($hashAlgorithm.ComputeHash([System.IO.File]::ReadAllBytes($Path))) ; $Properties=@{"Algorithm" = "MD5";"Path" = $Path;"Hash" = $Hash.Replace("-", "");} ; $Ret=New-Object –TypeName PSObject –Prop $Properties ; return $Ret;} ; function Get-Processes {Write-Verbose "Getting ProcessList" ; $processes = Get-WmiObject -Class Win32_Process -ComputerName $TargetComputer ; $processList = @();foreach ($process in $processes) {try {$Owner = $process.GetOwner().Domain.ToString() + "\"+ $process.GetOwner().User.ToString() ; $OwnerSID = $process.GetOwnerSid().Sid} catch {} ; $thisProcess=New-Object PSObject -Property @{PSComputerName=$process.PSComputerName ; OSName=$process.OSName ; Name=$process.Caption ; ProcessId=[int]$process.ProcessId ; ParentProcessName=($processes | where { $_.ProcessID -eq $process.ParentProcessId}).Caption ; ParentProcessId=[int]$process.ParentProcessId ; MemoryKiloBytes=[int]$process.WorkingSetSize/1000 ; SessionId=[int]$process.SessionId ; Owner=$Owner ; OwnerSID=$OwnerSID ; PathName=$process.ExecutablePath ; CommandLine=$process.CommandLine ; CreationDate=$process.ConvertToDateTime($process.CreationDate)} ; if ($process.ExecutablePath) {$Signature = Get-FileHash $process.ExecutablePath | Select-Object -Property Hash, Algorithm ; $Signature.PSObject.Properties | Foreach-Object {$thisProcess | Add-Member -type NoteProperty -Name $_.Name -Value $_.Value -Force}} $processList += $thisProcess} return $processList} ; Get-Processes | Select-Object -Property PSComputerName, Name, ProcessID, ParentProcessName, ParentProcessId, MemoryKiloBytes, CommandLine, PathName, Hash, Algorithm, CreationDate, Owner, OwnerSID, SessionId'),
[Tuple]::Create(`
    'Logon Information',
    'Get-WmiObject -Class Win32_NetworkLoginProfile -ComputerName $TargetComputer | Select-Object PSComputerName, Name, LastLogon, LastLogoff, NumberOfLogons, PasswordAge'),
[Tuple]::Create(`
    'Logged-On User Information',
    'Get-WmiObject -Class Win32_ComputerSystem -ComputerName $TargetComputer | Select-Object PSComputerName, Username'),
[Tuple]::Create(`
    'User Information',
    'Get-WmiObject -Class Win32_UserAccount -ComputerName $TargetComputer | Select-Object PSComputerName, Name, AccountType, Disabled, Fullname, Domain, LocalAccount, Lockout, PasswordChangeable, PasswordExpires, SID'),
[Tuple]::Create(`
    'Group Information',
    'Get-WmiObject -Class Win32_Group -ComputerName $TargetComputer | Select-Object PSComputerName, Name, Caption, Domain, SID'),
[Tuple]::Create(`
    'Autoruns - Startup Commands',
    'Get-WmiObject -Class Win32_StartupCommand -ComputerName $TargetComputer | Select-Object PSComputerName, Name, Location, Command, User'),
[Tuple]::Create(`
    'Dates - Install, Boot, and Localtime',
    '$DateTimes=Get-WmiObject -class Win32_OperatingSystem -ComputerName $TargetComputer | Select-Object PSComputerName, InstallDate, LastBootUpTime, LocalDateTime ; foreach ($time in $DateTimes) {$InstallDate=[System.Management.ManagementDateTimeConverter]::ToDateTime($time.InstallDate) ; $LastBootUpTime=[System.Management.ManagementDateTimeConverter]::ToDateTime($time.LastBootUpTime) ; $LocalDateTime=[System.Management.ManagementDateTimeConverter]::ToDateTime($time.LocalDateTime) ; $DateTimeOutput=@() ; $DateTimeOutput += New-Object psobject -Property @{PSComputerName=$TargetComputer ; InstallDate=$InstallDate ; LastBootUpTime=$LastBootUpTime ; LocalDateTime=$LocalDateTime} ; $DateTimeOutput}'),
[Tuple]::Create(`
    'Environmental Variables',
    'Get-WmiObject -Class Win32_Environment -ComputerName $TargetComputer | Select-Object PSComputerName, UserName, Name, VariableValue'),
[Tuple]::Create(`
    'BIOS Information',
    'Get-WmiObject -Class Win32_BIOS -ComputerName $TargetComputer'),
[Tuple]::Create(`
    'Drivers - Detailed',
    'Get-WmiObject -Class Win32_Systemdriver -ComputerName $TargetComputer | Select-Object PSComputerName, State, Status, Started, StartMode, Name, InstallDate, DisplayName, PathName, ExitCode, AcceptPause, AcceptStop, Caption, CreationClassName, Description, DesktopInteract, DisplayName, ErrorControl, InstallDate, PathName, ServiceType'),
[Tuple]::Create(`
    'Drivers - Valid Signatures',
    'Get-WmiObject -Class Win32_SystemDriver -ComputerName $TargetComputer | ForEach-Object {Get-AuthenticodeSignature $_.pathname} | Select-Object PSComputerName, Status, Path, @{Name="SignerCertificate";Expression={$_.SignerCertificate -join "; "}}'),
[Tuple]::Create(`
    'Memory (RAM) Capacity Information',
    'Get-WmiObject -Class Win32_PhysicalMemoryArray -ComputerName $TargetComputer | Select-Object PSComputerName, Model, Name, MaxCapacity, MemoryDevices'),
[Tuple]::Create(`
    'Memory (RAM) Physical Information',
    'Get-WmiObject -Class Win32_PhysicalMemory -ComputerName $TargetComputer | Select-Object PSComputerName, Tag, Capacity, Speed, Manufacturer, PartNumber, SerialNumber'),
[Tuple]::Create(`
    'Memory (RAM) Utilization',
    'Get-WmiObject -Class Win32_OperatingSystem -ComputerName $TargetComputer | Select-Object -Property PSComputerName, FreePhysicalMemory, TotalVisibleMemorySize, FreeVirtualMemory, TotalVirtualMemorySize'),
[Tuple]::Create(`
    'Memory Performance Monitoring Data',
    'Get-WmiObject -Class Win32_PerfRawData_PerfOS_Memory -ComputerName $TargetComputer | Sort-Object -Property PSComputerName, AvailableBytes, AvailableKBytes, AvailableMBytes, CacheBytes, CacheBytesPeak, CacheFaultsPersec, Caption, CommitLimit, CommittedBytes, DemandZeroFaultsPersec, FreeAndZeroPageListBytes, FreeSystemPageTableEntries, Frequency_Object, Frequency_PerfTime, Frequency_Sys100NS, LongTermAverageStandbyCacheLifetimes, ModifiedPageListBytes, PageFaultsPersec, PageReadsPersec, PagesInputPersec, PagesOutputPersec, PagesPersec, PageWritesPersec, PercentCommittedBytesInUse, PercentCommittedBytesInUse_Base, PoolNonpagedAllocs, PoolNonpagedBytes, PoolPagedAllocs, PoolPagedBytes, PoolPagedResidentBytes, StandbyCacheCoreBytes, StandbyCacheNormalPriorityBytes, StandbyCacheReserveBytes, SystemCacheResidentBytes, SystemCodeResidentBytes, SystemCodeTotalBytes, SystemDriverResidentBytes, SystemDriverTotalBytes, Timestamp_Object, Timestamp_PerfTime, Timestamp_Sys100NS, TransitionFaultsPersec, TransitionPagesRePurposedPersec, WriteCopiesPersec'),
[Tuple]::Create(`
    'Disk Information',
    'Get-WmiObject -Class Win32_LogicalDisk -ComputerName $TargetComputer | Select-Object PSComputerName, DeviceID, Description, ProviderName, FreeSpace, Size, DriveType'),
[Tuple]::Create(`
    'Mapped Drives',
    'Get-WmiObject -Class Win32_MappedLogicalDisk -ComputerName $TargetComputer | Select-Object PSComputerName, Name, ProviderName'),
[Tuple]::Create(`
    'Network - Active Connections in a Windows-Based Environment',
    'Get-WmiObject -Class Win32_NetworkConnection -ComputerName $TargetComputer | Select-Object PSComputerName, LocalName, RemoteName, UserName, Status, ConnectionState, ConnectionType, DisplayType, ResourceType, ProviderName, Caption, InstallDate, Site, Container'),
[Tuple]::Create(`
    'Shares',
    'Get-WmiObject -Class Win32_Share -ComputerName $TargetComputer | Select-Object PSComputerName, Name, Path, Description'),
[Tuple]::Create(`
    'Plug and Play Devices',
    'Get-WmiObject -Class Win32_PnPEntity -ComputerName $TargetComputer | Select-Object PSComputerName, InstallDate, Status, Description, Service, DeviceID, @{Name="HardwareID";Expression={$_.HardwareID -join "; "}}, Manufacturer'),
[Tuple]::Create(`
    'USB Controller Device Connections',
    'Get-WmiObject Win32_USBControllerDevice -ComputerName $TargetComputer | Select-Object PSComputerName, Antecedent, Dependent'),
[Tuple]::Create(`
    'Printers',
    'Get-WmiObject -Class Win32_Printer -ComputerName $TargetComputer  | Select-Object -Property SystemName, Name, Location, ShareName, PrinterStatus, PrinterState'),
[Tuple]::Create(`
    'Network Settings',
    'Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $TargetComputer | Select-Object PSComputerName, MACAddress, @{Name="IPAddress";Expression={$_.IPAddress -join "; "}}, @{Name="IpSubnet";Expression={$_.IpSubnet -join "; "}}, @{Name="DefaultIPGateway";Expression={$_.DefaultIPgateway -join "; "}}, Description, ServiceName, IPEnabled, DHCPEnabled, DNSHostname, @{Name="DNSDomainSuffixSearchOrder";Expression={$_.DNSDomainSuffixSearchOrder -join "; "}}, DNSEnabledForWINSResolution, DomainDNSRegistrationEnabled, FullDNSRegistrationEnabled, @{Name="DNSServerSearchOrder";Expression={$_.DNSServerSearchOrder -join "; "}}, @{Name="WinsPrimaryServer";Expression={$_.WinsPrimaryServer -join "; "}}, @{Name="WINSSecindaryServer";Expression={$_.WINSSecindaryServer -join "; "}}'),
[Tuple]::Create(`
    'Software Installed',
    'Get-WmiObject Win32_Product -ComputerName $TargetComputer | Select-Object -Property PSComputerName, Name, Vendor, Version, InstallDate, InstallDate2, InstallLocation, InstallSource, PackageName, PackageCache, RegOwner, HelpLink, HelpTelephone, URLInfoAbout, URLUpdateInfo, Language, Description, IdentifyingNumber'),
[Tuple]::Create(`
    "Event Logs (Last $LimitNumberOfEventLogsCollectToChoice) Application",
    'Get-WmiObject -Class Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Application`")" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
[Tuple]::Create(`
    "Event Logs (Last $LimitNumberOfEventLogsCollectToChoice) Security",
    'Get-WmiObject -Class Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`")" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
[Tuple]::Create(`
    "Event Logs (Last $LimitNumberOfEventLogsCollectToChoice) System",
    'Get-WmiObject -Class Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"System`")" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
[Tuple]::Create(`
    "Event Logs (Last $LimitNumberOfEventLogsCollectToChoice) Application Errors",
    'Get-WmiObject -Class Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Application`") AND (type=`"error`")" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
[Tuple]::Create(`
    "Event Logs (Last $LimitNumberOfEventLogsCollectToChoice) System Errors",
    'Get-WmiObject -Class Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"System`") AND (type=`"error`")" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice')
));



# ============================================================================================================================================================
# ============================================================================================================================================================
# Retrieve Domain User Account Information - Commands
# ============================================================================================================================================================
# ============================================================================================================================================================

# The new object is configured as an arraylist for tuples to contain CollecitonName and Command
$ActiveDirectoryCommandList = New-Object System.Collections.ArrayList

# [Tuple]::Create(`
#    'DESCRIPTION USED FOR TERMINAL MESSAGE AND FILENAME',`
#    'COMMAND TO BE RAN'),
$ActiveDirectoryCommandList.AddRange((
[Tuple]::Create(`
    'Account Details and User Information',`
    'Get-ADUser -Filter * -Properties * | Select-Object Name, CanonicalName, SID, Enabled, LockedOut, AccountLockoutTime, Created, LogonWorkStations, LastLogonDate, LastBadPasswordAttempt, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CannotChangePassword, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive, Title, Organization, Office, POBox, StreetAddress, City, State, PostalCode, Fax, OfficePhone, HomePhone, MobilePhone, EmailAddress'),
[Tuple]::Create(`
    'Account Logon & Passowrd Policy',`
    'Get-ADUser -Filter * -Properties * | Select-Object Name, Enabled, LockedOut, AccountLockoutTime, LogonWorkStations, LastLogonDate, LastBadPasswordAttempt, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CannotChangePassword'),
[Tuple]::Create(`
    'Account Contact Information',`
    'Get-ADUser -Filter * -Properties * | Select-Object Name, Title, Organization, Office, POBox, StreetAddress, City, State, PostalCode, Fax, OfficePhone, HomePhone, MobilePhone, EmailAddress'),
[Tuple]::Create(`
    'Account Email Addresses',`
    'Get-ADUser -Filter * -Properties * | Where-Object {$_.EmailAddress -ne $null} | Select-Object Name, EmailAddress'),
[Tuple]::Create(`
    'Account Phone Numbers',`
    'Get-ADUser -Filter * -Properties * | Where-Object {($_.OfficePhone -ne $null) -or ($_.HomePhone -ne $null) -or ($_.MobilePhone -ne $null)} | Select-Object Name, OfficePhone, HomePhone, MobilePhone'),
[Tuple]::Create(`
    'Active Directory Groups',`
    'Get-ADGroup -Filter * | Select-Object -Property Name, SID, GroupCategory, GroupScope, DistinguishedName'),
[Tuple]::Create(`
    'Active Directory Group Membership',`
    '$ADGroupList = Get-ADGroup -Filter * | Select-Object -Property Name ; foreach ($Group in $ADGroupList) {Get-ADPrincipalGroupMembership -Identity $Group.name | Select-Object -Property Name, SID, GroupCategory, GroupScope, DistinguishedName}'),
[Tuple]::Create(`
    'Accounts That Are Inactive for Longer Than 4 Weeks',`
    'dsquery user domainroot -inactive 4'),
[Tuple]::Create(`
    'Accounts That Are Disabled',`
    'dsquery user -disabled'),
[Tuple]::Create(`
    'Accounts - Last Logon Timestamps',`
    'dsquery * -filter "&(objectClass=person)(objectCategory=user)" -attr cn lastLogonTimestamp -limit 0'),
[Tuple]::Create(`
    'Accounts - Primary Group is Domain Users',`
    'dsquery * -filter "(primaryGroupID=513)" -limit 0'),
[Tuple]::Create(`
    'Accounts - Primary Group is Guests',`
    'dsquery * -filter "(primaryGroupID=514)" -limit 0')
<# NOTES... maybe future implementation
find all members for a particular group
dsget group "<group>" -members
find all groups for a particular member
dsget user "<DN of user>" -memberof -expand
get the groups name from user container
dsquery group -o rdn cn=users,dc=contoso.dc=com
get the members from a group
dsquery group-samid "CS_CLUB_ACCOUNTS" | dsget group -members -expand | dsget user -samid
find all members for a OU
dsquery user ou=targetOU,dc=domain,dc=com
find all groups for a OU
dsquery group ou=targetOU,dc=domain,dc=com
#>
));



# ============================================================================================================================================================
# ============================================================================================================================================================
# Retrieve Domain Computer Information - Commands
# ============================================================================================================================================================
# ============================================================================================================================================================

# The new object is configured as an arraylist for tuples to contain CollecitonName and Command
$netdomCommandList = New-Object System.Collections.ArrayList

# [Tuple]::Create(`
#    'DESCRIPTION USED FOR TERMINAL MESSAGE AND FILENAME',`
#    'COMMAND TO BE RAN'),
$netdomCommandList.AddRange((
[Tuple]::Create(`
    'Domain Trusts',
    'netdom query TRUST'),
[Tuple]::Create(`
    'Domain FSMO Owners',
    'netdom query FSMO'),
[Tuple]::Create(`
    'Domain Organizationation Units (OUs)',
    'netdom query OU'),
[Tuple]::Create(`
    'Domain FSMO Schema Master in Forest',
    'dsquery server -forest -hasfsmo Schema'),
[Tuple]::Create(`
    'Domain FSMO Domain Naming Master',
    'dsquery server -forest -hasfsmo Name'),
[Tuple]::Create(`
    'Domain FSMO Primary Domain Controller',
    'dsquery server -hasfsmo PDC'),
[Tuple]::Create(`
    'Domain FSMO RID Pool Manager',
    'dsquery server -hasfsmo RID'),
[Tuple]::Create(`
    'Domain FSMO Infrastructure Master',
    'dsquery server -hasfsmo INFR'),
[Tuple]::Create(`
    'Domain Sites',
    'dsquery site -name * -limit 0'),
[Tuple]::Create(`
    'Domain - Primary Group is Domain Computers',`
    'dsquery * -filter "(primaryGroupID=515)" -limit 0'),
[Tuple]::Create(`
    'Domain - Primary Group is Domain Controllers',`
    'dsquery * -filter "(primaryGroupID=516)" -limit 0'),
[Tuple]::Create(`
    'Domain - Domain Controllers that are Global Catalogs',`
    'dsquery server | dsget server -dnsname -site -isgc'),
[Tuple]::Create(`
    'Domain - Domain Controllers that are Read Only (RODC)',`
    'dsquery server -isreadonly'),
[Tuple]::Create(`
    'Domain - Hyper-V Hosts',`
    'dsquery * forestroot -filter "&(cn=Microsoft Hyper-V)(objectCategory=serviceconnectionpoint)" -attr servicebindinginformation'),
[Tuple]::Create(`
    'Domain - Virtual Machines',`
    'dsquery * domainroot -filter "(&(cn=Windows Virtual Machine)(objectClass=serviceConnectionPoint))"'),
    #'dsquery * forestroot -filter "&(cn=Windows Virtual Machine)(objectCategory=serviceconnectionpoint)" -limit 0 -attr *')
    #'Get-ADObject -LDAPFilter "(&(objectClass=serviceConnectionPoint)(CN=Windows Virtual Machine))"'
[Tuple]::Create(`
    'Domain Controller - Primary',
    'netdom query PDC'),
[Tuple]::Create(`
    'Domain Controllers',
    'netdom query DC')
));



# ============================================================================================================================================================
# ============================================================================================================================================================
# Audit Event Log Queries - Commands
# ============================================================================================================================================================
# ============================================================================================================================================================

# The Following 'if ($true)' is used just to collapse the section when viewing in PowerShellISE, otherwise there's no other function
if ($true) {
# The new object is configured as an arraylist for tuples to contain CollecitonName and Command
$AuditEventLogsCommands = New-Object System.Collections.ArrayList

# [Tuple]::Create(`
#    'DESCRIPTION USED FOR TERMINAL MESSAGE AND FILENAME',`
#    'COMMAND TO BE RAN'),
$AuditEventLogsCommands.AddRange((
[Tuple]::Create(`
    "Kerberos Authentication Service",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND ((EventCode=`"4768`") OR (EventCode=`"4771`") OR (EventCode=`"4772`")) AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-kerberos-authentication-service
        4768(S, F): A Kerberos authentication ticket (TGT) was requested.
        4771(F): Kerberos pre-authentication failed.
        4772(F): A Kerberos authentication ticket request failed.
    #>
[Tuple]::Create(`
    "Kerberos Service Ticket Operations",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND ((EventCode=`"4769`") OR (EventCode=`"4770`") OR (EventCode=`"4773`")) AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-kerberos-service-ticket-operations
        4769(S, F): A Kerberos service ticket was requested.
        4770(S): A Kerberos service ticket was renewed.
        4773(F): A Kerberos service ticket request failed.
    #>
[Tuple]::Create(`
    "Application Group Management",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND ((EventCode=`"4783`") OR (EventCode=`"4784`") OR (EventCode=`"4785`") OR (EventCode=`"4786`") OR (EventCode=`"4787`") OR (EventCode=`"4788`") OR (EventCode=`"4789`") OR (EventCode=`"4790`") OR (EventCode=`"4791`") OR (EventCode=`"4792`")) AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-application-group-management
        4783(S): A basic application group was created.
        4784(S): A basic application group was changed.
        4785(S): A member was added to a basic application group.
        4786(S): A member was removed from a basic application group.
        4787(S): A non-member was added to a basic application group.
        4788(S): A non-member was removed from a basic application group.
        4789(S): A basic application group was deleted.
        4790(S): An LDAP query group was created.
        4791(S): An LDAP query group was changed.
        4792(S): An LDAP query group was deleted.
    #>
[Tuple]::Create(`
    "Computer Account Management",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND ((EventCode=`"4741`") OR (EventCode=`"4742`") OR (EventCode=`"4743`")) AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-computer-account-management
        4741(S): A computer account was created.
        4742(S): A computer account was changed.
        4743(S): A computer account was deleted.
    #>
[Tuple]::Create(`
    "Distribution Group Management",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND ((EventCode=`"4749`") OR (EventCode=`"4750`") OR (EventCode=`"4751`") OR (EventCode=`"4752`") OR (EventCode=`"4753`") OR (EventCode=`"4759`") OR (EventCode=`"4760`") OR (EventCode=`"4761`") OR (EventCode=`"4762`") OR (EventCode=`"4763`") OR (EventCode=`"4744`") OR (EventCode=`"4745`") OR (EventCode=`"4746`") OR (EventCode=`"4747`") OR (EventCode=`"4748`")) AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-distribution-group-management
        4749(S): A security-disabled global group was created.
        4750(S): A security-disabled global group was changed.
        4751(S): A member was added to a security-disabled global group.
        4752(S): A member was removed from a security-disabled global group.
        4753(S): A security-disabled global group was deleted.
        4759(S): A security-disabled universal group was created. See event “4749: A security-disabled global group was created.” Event 4759 is the same, but it is generated for a universal distribution group instead of a global distribution group. All event fields, XML, and recommendations are the same. The type of group is the only difference.
        4760(S): A security-disabled universal group was changed. See event “4750: A security-disabled global group was changed.” Event 4760 is the same, but it is generated for a universal distribution group instead of a global distribution group. All event fields, XML, and recommendations are the same. The type of group is the only difference.
        4761(S): A member was added to a security-disabled universal group. See event “4751: A member was added to a security-disabled global group.” Event 4761 is the same, but it is generated for a universal distribution group instead of a global distribution group. All event fields, XML, and recommendations are the same. The type of group is the only difference.
        4762(S): A member was removed from a security-disabled universal group. See event “4752: A member was removed from a security-disabled global group.” Event 4762 is the same, but it is generated for a universal distribution group instead of a global distribution group. All event fields, XML, and recommendations are the same. The type of group is the only difference.
        4763(S): A security-disabled universal group was deleted. See event “4753: A security-disabled global group was deleted.” Event 4763 is the same, but it is generated for a universal distribution group instead of a global distribution group. All event fields, XML, and recommendations are the same. The type of group is the only difference.
        4744(S): A security-disabled local group was created. See event “4749: A security-disabled global group was created.” Event 4744 is the same, but it is generated for a local distribution group instead of a global distribution group. All event fields, XML, and recommendations are the same. The type of group is the only difference.
        4745(S): A security-disabled local group was changed. See event “4750: A security-disabled global group was changed.” Event 4745 is the same, but it is generated for a local distribution group instead of a global distribution group. All event fields, XML, and recommendations are the same. The type of group is the only difference.
        4746(S): A member was added to a security-disabled local group. See event “4751: A member was added to a security-disabled global group.” Event 4746 is the same, but it is generated for a local distribution group instead of a global distribution group. All event fields, XML, and recommendations are the same. The type of group is the only difference.
        4747(S): A member was removed from a security-disabled local group. See event “4752: A member was removed from a security-disabled global group.” Event 4747 is the same, but it is generated for a local distribution group instead of a global distribution group. All event fields, XML, and recommendations are the same. The type of group is the only difference.
        4748(S): A security-disabled local group was deleted. See event “4753: A security-disabled global group was deleted.” Event 4748 is the same, but it is generated for a local distribution group instead of a global distribution group. All event fields, XML, and recommendations are the same. The type of group is the only difference.
    #>
[Tuple]::Create(`
    "Other Account Management Events",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND ((EventCode=`"4782`") OR (EventCode=`"4793`")) AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-other-account-management-events
        4782(S): The password hash an account was accessed.
        4793(S): The Password Policy Checking API was called.
    #>
[Tuple]::Create(`
    "Security Group Management",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND ((EventCode=`"4731`") OR (EventCode=`"4732`") OR (EventCode=`"4733`") OR (EventCode=`"4734`") OR (EventCode=`"4735`") OR (EventCode=`"4764`") OR (EventCode=`"4799`") OR (EventCode=`"4727`") OR (EventCode=`"4737`") OR (EventCode=`"4728`") OR (EventCode=`"4729`") OR (EventCode=`"4730`") OR (EventCode=`"4754`") OR (EventCode=`"4755`") OR (EventCode=`"4756`") OR (EventCode=`"4757`") OR (EventCode=`"4758`")) AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-security-group-management
        4731(S): A security-enabled local group was created.
        4732(S): A member was added to a security-enabled local group.
        4733(S): A member was removed from a security-enabled local group.
        4734(S): A security-enabled local group was deleted.
        4735(S): A security-enabled local group was changed.
        4764(S): A group’s type was changed.
        4799(S): A security-enabled local group membership was enumerated.
        4727(S): A security-enabled global group was created. See event “4731: A security-enabled local group was created.” Event 4727 is the same, but it is generated for a global security group instead of a local security group. All event fields, XML, and recommendations are the same. The type of group is the only difference. Important: this event generates only for domain groups, so the Local sections in event 4731 do not apply.
        4737(S): A security-enabled global group was changed. See event “4735: A security-enabled local group was changed.” Event 4737 is the same, but it is generated for a global security group instead of a local security group. All event fields, XML, and recommendations are the same. The type of group is the only difference. Important: this event generates only for domain groups, so the Local sections in event 4735 do not apply.
        4728(S): A member was added to a security-enabled global group. See event “4732: A member was added to a security-enabled local group.” Event 4728 is the same, but it is generated for a global security group instead of a local security group. All event fields, XML, and recommendations are the same. The type of group is the only difference. Important: this event generates only for domain groups, so the Local sections in event 4732 do not apply.
        4729(S): A member was removed from a security-enabled global group. See event “4733: A member was removed from a security-enabled local group.” Event 4729 is the same, but it is generated for a global security group instead of a local security group. All event fields, XML, and recommendations are the same. The type of group is the only difference. Important: this event generates only for domain groups, so the Local sections in event 4733 do not apply.
        4730(S): A security-enabled global group was deleted. See event “4734: A security-enabled local group was deleted.” Event 4730 is the same, but it is generated for a global security group instead of a local security group. All event fields, XML, and recommendations are the same. The type of group is the only difference. Important: this event generates only for domain groups, so the Local sections in event 4734 do not apply.
        4754(S): A security-enabled universal group was created. See event “4731: A security-enabled local group was created.”. Event 4754 is the same, but it is generated for a universal security group instead of a local security group. All event fields, XML, and recommendations are the same. The type of group is the only difference. Important: this event generates only for domain groups, so the Local sections in event 4731 do not apply.
        4755(S): A security-enabled universal group was changed. See event “4735: A security-enabled local group was changed.”. Event 4737 is the same, but it is generated for a universal security group instead of a local security group. All event fields, XML, and recommendations are the same. The type of group is the only difference. Important: this event generates only for domain groups, so the Local sections in event 4735 do not apply.
        4756(S): A member was added to a security-enabled universal group. See event “4732: A member was added to a security-enabled local group.”. Event 4756 is the same, but it is generated for a universal security group instead of a local security group. All event fields, XML, and recommendations are the same. The type of group is the only difference. Important: this event generates only for domain groups, so the Local sections in event 4732 do not apply.
        4757(S): A member was removed from a security-enabled universal group. See event “4733: A member was removed from a security-enabled local group.”. Event 4757 is the same, but it is generated for a universal security group instead of a local security group. All event fields, XML, and recommendations are the same. The type of group is the only difference. Important: this event generates only for domain groups, so the Local sections in event 4733 do not apply.
        4758(S): A security-enabled universal group was deleted. See event “4734: A security-enabled local group was deleted.”. Event 4758 is the same, but it is generated for a universal security group instead of a local security group. All event fields, XML, and recommendations are the same. The type of group is the only difference. Important: this event generates only for domain groups, so the Local sections in event 4734 do not apply.
    #>
[Tuple]::Create(`
    "User Account Management",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND ((EventCode=`"4720`") OR (EventCode=`"4722`") OR (EventCode=`"4723`") OR (EventCode=`"4724`") OR (EventCode=`"4725`") OR (EventCode=`"4726`") OR (EventCode=`"4738`") OR (EventCode=`"4740`") OR (EventCode=`"4765`") OR (EventCode=`"4766`") OR (EventCode=`"4767`") OR (EventCode=`"4780`") OR (EventCode=`"4781`") OR (EventCode=`"4781`") OR (EventCode=`"4794`") OR (EventCode=`"4798`") OR (EventCode=`"5376`") OR (EventCode=`"5377`")) AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-user-account-management
        4720(S): A user account was created.
        4722(S): A user account was enabled.
        4723(S, F): An attempt was made to change an account's password.
        4724(S, F): An attempt was made to reset an account's password.
        4725(S): A user account was disabled.
        4726(S): A user account was deleted.
        4738(S): A user account was changed.
        4740(S): A user account was locked out.
        4765(S): SID History was added to an account.
        4766(F): An attempt to add SID History to an account failed.
        4767(S): A user account was unlocked.
        4780(S): The ACL was set on accounts which are members of administrators groups.
        4781(S): The name of an account was changed.
        4794(S, F): An attempt was made to set the Directory Services Restore Mode administrator password.
        4798(S): A user's local group membership was enumerated.
        5376(S): Credential Manager credentials were backed up.
        5377(S): Credential Manager credentials were restored from a backup.
    #>
[Tuple]::Create(`
    "DPAPI Activity",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND ((EventCode=`"4692`") OR (EventCode=`"4693`") OR (EventCode=`"4694`") OR (EventCode=`"4695`")) AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-dpapi-activity
        4692(S, F): Backup of data protection master key was attempted.
        4693(S, F): Recovery of data protection master key was attempted.
        4694(S, F): Protection of auditable protected data was attempted.
        4695(S, F): Unprotection of auditable protected data was attempted.
    #>
[Tuple]::Create(`
    "PNP Activity",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND ((EventCode=`"6416`") OR (EventCode=`"6419`") OR (EventCode=`"6420`") OR (EventCode=`"6421`") OR (EventCode=`"6422`") OR (EventCode=`"6423`") OR (EventCode=`"6424`")) AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-pnp-activity
        6416(S): A new external device was recognized by the System
        6419(S): A request was made to disable a device
        6420(S): A device was disabled.
        6421(S): A request was made to enable a device.
        6422(S): A device was enabled.
        6423(S): The installation of this device is forbidden by system policy.
        6424(S): The installation of this device was allowed, after having previously been forbidden by policy.
    #>
[Tuple]::Create(`
    "Process Creation & Termination",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND ((EventCode=`"4688`") OR (EventCode=`"4696`") OR (EventCode=`"4689`")) AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-process-creation
        4688(S): A new process has been created.
        4696(S): A primary token was assigned to process.
    #><#
        https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-process-termination
        4689(S): A process has exited.
    #>
[Tuple]::Create(`
    "RPC Events",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND (EventCode=`"5712`") AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-rpc-events
        5712(S): A Remote Procedure Call (RPC) was attempted.
    #>
[Tuple]::Create(`
    "Detailed Directory Service Replication",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND ((EventCode=`"4928`") OR (EventCode=`"4929`") OR (EventCode=`"4930`") OR (EventCode=`"4931`") OR (EventCode=`"4934`") OR (EventCode=`"4935`") OR (EventCode=`"4936`") OR (EventCode=`"4937`")) AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-detailed-directory-service-replication
        4928(S, F): An Active Directory replica source naming context was established.
        4929(S, F): An Active Directory replica source naming context was removed.
        4930(S, F): An Active Directory replica source naming context was modified.
        4931(S, F): An Active Directory replica destination naming context was modified.
        4934(S): Attributes of an Active Directory object were replicated.
        4935(F): Replication failure begins.
        4936(S): Replication failure ends.
        4937(S): A lingering object was removed from a replica.
    #>
[Tuple]::Create(`
    "Directory Service Access",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND ((EventCode=`"4662`") OR (EventCode=`"4661`")) AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-directory-service-access
        4662(S, F): An operation was performed on an object.
        4661(S, F): A handle to an object was requested.
    #>
[Tuple]::Create(`
    "Directory Service Changes",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND ((EventCode=`"5136`") OR (EventCode=`"5137`") OR (EventCode=`"5138`") OR (EventCode=`"5139`") OR (EventCode=`"5141`")) AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-directory-service-changes
        5136(S): A directory service object was modified.
        5137(S): A directory service object was created.
        5138(S): A directory service object was undeleted.
        5139(S): A directory service object was moved.
        5141(S): A directory service object was deleted
    #>
[Tuple]::Create(`
    "Directory Service Replication",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND ((EventCode=`"4932`") OR (EventCode=`"4933`")) AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-directory-service-replication
        4932(S): Synchronization of a replica of an Active Directory naming context has begun.
        4933(S, F): Synchronization of a replica of an Active Directory naming context has ended.
    #>
[Tuple]::Create(`
    "Account Lockout",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND (EventCode=`"4625`") AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-account-lockout
        4625(F): An account failed to log on.
    #>
[Tuple]::Create(`
    "User & Device Claims",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND (EventCode=`"4626`") AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-user-device-claims
        4626(S): User/Device claims information.
    #>
[Tuple]::Create(`
    "Group Membership",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND (EventCode=`"4627`") AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-group-membership
        4627(S): Group membership information.
    #>
[Tuple]::Create(`
    "IPSec Extended Mode",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND ((EventCode=`"4978`") OR (EventCode=`"4979`") OR (EventCode=`"4980`") OR (EventCode=`"4981`") OR (EventCode=`"4982`") OR (EventCode=`"4983`") OR (EventCode=`"4984`")) AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-ipsec-extended-mode
        4978: During Extended Mode negotiation, IPsec received an invalid negotiation packet. If this problem persists, it could indicate a network issue or an attempt to modify or replay this negotiation.
        4979: IPsec Main Mode and Extended Mode security associations were established.
        4980: IPsec Main Mode and Extended Mode security associations were established.
        4981: IPsec Main Mode and Extended Mode security associations were established.
        4982: IPsec Main Mode and Extended Mode security associations were established.
        4983: An IPsec Extended Mode negotiation failed. The corresponding Main Mode security association has been deleted.
        4984: An IPsec Extended Mode negotiation failed. The corresponding Main Mode security association has been deleted.
    #>
[Tuple]::Create(`
    "IPSec Main Mode",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND ((EventCode=`"4646`") OR (EventCode=`"4650`") OR (EventCode=`"4651`") OR (EventCode=`"4652`") OR (EventCode=`"4653`") OR (EventCode=`"4655`") OR (EventCode=`"4976`") OR (EventCode=`"5049`") OR (EventCode=`"5453`")) AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-ipsec-main-mode
        4646: Security ID: %1
        4650: An IPsec Main Mode security association was established. Extended Mode was not enabled. Certificate authentication was not used.
        4651: An IPsec Main Mode security association was established. Extended Mode was not enabled. A certificate was used for authentication.
        4652: An IPsec Main Mode negotiation failed.
        4653: An IPsec Main Mode negotiation failed.
        4655: An IPsec Main Mode security association ended.
        4976: During Main Mode negotiation, IPsec received an invalid negotiation packet. If this problem persists, it could indicate a network issue or an attempt to modify or replay this negotiation.
        5049: An IPsec Security Association was deleted.
        5453: An IPsec negotiation with a remote computer failed because the IKE and AuthIP IPsec Keying Modules (IKEEXT) service is not started.
    #>
[Tuple]::Create(`
    "IPSec Quick Mode",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND ((EventCode=`"4977`") OR (EventCode=`"5451`") OR (EventCode=`"5452`")) AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-ipsec-quick-mode
        4977: During Quick Mode negotiation, IPsec received an invalid negotiation packet. If this problem persists, it could indicate a network issue or an attempt to modify or replay this negotiation.
        5451: An IPsec Quick Mode security association was established.
        5452: An IPsec Quick Mode security association ended.
    #>
[Tuple]::Create(`
    "Network Policy Server",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND ((EventCode=`"6272`") OR (EventCode=`"6273`") OR (EventCode=`"6274`") OR (EventCode=`"6275`") OR (EventCode=`"6276`") OR (EventCode=`"6277`") OR (EventCode=`"6278`") OR (EventCode=`"6279`") OR (EventCode=`"6280`")) AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-network-policy-server
        6272: Network Policy Server granted access to a user.
        6273: Network Policy Server denied access to a user.
        6274: Network Policy Server discarded the request for a user.
        6275: Network Policy Server discarded the accounting request for a user.
        6276: Network Policy Server quarantined a user.
        6277: Network Policy Server granted access to a user but put it on probation because the host did not meet the defined health policy.
        6278: Network Policy Server granted full access to a user because the host met the defined health policy.
        6279: Network Policy Server locked the user account due to repeated failed authentication attempts.
        6280: Network Policy Server unlocked the user account.
    #>
[Tuple]::Create(`
    "Logon & Logoff Events",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND ((EventCode=`"4624`") OR (EventCode=`"4625`") OR (EventCode=`"4648`") OR (EventCode=`"4675`") OR (EventCode=`"4634`") OR (EventCode=`"4647`")) AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-logon
        4624(S): An account was successfully logged on.
        4625(F): An account failed to log on.
        4648(S): A logon was attempted using explicit credentials.
        4675(S): SIDs were filtered.
    #><#
        https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-logoff
        4634(S): An account was logged off.
        4647(S): User initiated logoff.
    #>
[Tuple]::Create(`
    "Logon & Logoff Events (Other)",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND ((EventCode=`"4649`") OR (EventCode=`"4778`") OR (EventCode=`"4779`") OR (EventCode=`"4800`") OR (EventCode=`"4801`") OR (EventCode=`"4802`") OR (EventCode=`"4803`") OR (EventCode=`"5378`") OR (EventCode=`"5632`") OR (EventCode=`"5633`")) AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-other-logonlogoff-events
        4649(S): A replay attack was detected.
        4778(S): A session was reconnected to a Window Station.
        4779(S): A session was disconnected from a Window Station.
        4800(S): The workstation was locked.
        4801(S): The workstation was unlocked.
        4802(S): The screen saver was invoked.
        4803(S): The screen saver was dismissed.
        5378(F): The requested credentials delegation was disallowed by policy.
        5632(S): A request was made to authenticate to a wireless network.
        5633(S): A request was made to authenticate to a wired network.
    #>
[Tuple]::Create(`
    "Special Logon",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND ((EventCode=`"4964`") OR (EventCode=`"4672`")) AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-special-logon
        4964(S): Special groups have been assigned to a new logon.
        4672(S): Special privileges assigned to new logon.
    #>
[Tuple]::Create(`
    "Application Generated",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND ((EventCode=`"4665`") OR (EventCode=`"4666`") OR (EventCode=`"4667`") OR (EventCode=`"4668`")) AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-application-generated
        4665: An attempt was made to create an application client context.
        4666: An application attempted an operation.
        4667: An application client context was deleted.
        4668: An application was initialized.
    #>
[Tuple]::Create(`
    "Certification Services",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND ((EventCode=`"4868`") OR (EventCode=`"4869`") OR (EventCode=`"4870`") OR (EventCode=`"4871`") OR (EventCode=`"4872`") OR (EventCode=`"4873`") OR (EventCode=`"4874`") OR (EventCode=`"4875`") OR (EventCode=`"4876`") OR (EventCode=`"4877`") OR (EventCode=`"4878`") OR (EventCode=`"4879`") OR (EventCode=`"4880`") OR (EventCode=`"4881`") OR (EventCode=`"4882`") OR (EventCode=`"4883`") OR (EventCode=`"4884`") OR (EventCode=`"4885`") OR (EventCode=`"4886`") OR (EventCode=`"4887`") OR (EventCode=`"4888`") OR (EventCode=`"4889`") OR (EventCode=`"4890`") OR (EventCode=`"4891`") OR (EventCode=`"4892`") OR (EventCode=`"4893`") OR (EventCode=`"4894`") OR (EventCode=`"4895`") OR (EventCode=`"4896`") OR (EventCode=`"4897`") OR (EventCode=`"4898`")) AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-certification-services
        4868: The certificate manager denied a pending certificate request.
        4869: Certificate Services received a resubmitted certificate request.
        4870: Certificate Services revoked a certificate.
        4871: Certificate Services received a request to publish the certificate revocation list (CRL).
        4872: Certificate Services published the certificate revocation list (CRL).
        4873: A certificate request extension changed.
        4874: One or more certificate request attributes changed.
        4875: Certificate Services received a request to shut down.
        4876: Certificate Services backup started.
        4877: Certificate Services backup completed.
        4878: Certificate Services restore started.
        4879: Certificate Services restore completed.
        4880: Certificate Services started.
        4881: Certificate Services stopped.
        4882: The security permissions for Certificate Services changed.
        4883: Certificate Services retrieved an archived key.
        4884: Certificate Services imported a certificate into its database.
        4885: The audit filter for Certificate Services changed.
        4886: Certificate Services received a certificate request.
        4887: Certificate Services approved a certificate request and issued a certificate.
        4888: Certificate Services denied a certificate request.
        4889: Certificate Services set the status of a certificate request to pending.
        4890: The certificate manager settings for Certificate Services changed.
        4891: A configuration entry changed in Certificate Services.
        4892: A property of Certificate Services changed.
        4893: Certificate Services archived a key.
        4894: Certificate Services imported and archived a key.
        4895: Certificate Services published the CA certificate to Active Directory Domain Services.
        4896: One or more rows have been deleted from the certificate database.
        4897: Role separation enabled.
        4898: Certificate Services loaded a template.
    #>
[Tuple]::Create(`
    "Detailed File Share",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND (EventCode=`"5145`") AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-detailed-file-share
        5145(S, F): A network share object was checked to see whether client can be granted desired access.
    #>
[Tuple]::Create(`
    "File Share",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND ((EventCode=`"5140`") OR (EventCode=`"5142`") OR (EventCode=`"5143`") OR (EventCode=`"5144`") OR (EventCode=`"5168`")) AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-file-share
        5140(S, F): A network share object was accessed.
        5142(S): A network share object was added.
        5143(S): A network share object was modified.
        5144(S): A network share object was deleted.
        5168(F): SPN check for SMB/SMB2 failed.
    #>
[Tuple]::Create(`
    "File System",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND ((EventCode=`"4656`") OR (EventCode=`"4658`") OR (EventCode=`"4660`") OR (EventCode=`"4663`") OR (EventCode=`"4664`") OR (EventCode=`"4985`") OR (EventCode=`"5051`") OR (EventCode=`"4670`")) AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-file-system
        4656(S, F): A handle to an object was requested.
        4658(S): The handle to an object was closed.
        4660(S): An object was deleted.
        4663(S): An attempt was made to access an object.
        4664(S): An attempt was made to create a hard link.
        4985(S): The state of a transaction has changed.
        5051(-): A file was virtualized.
        4670(S): Permissions on an object were changed.
    #>
[Tuple]::Create(`
    "Filtering Platform Connection",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND ((EventCode=`"5031`") OR (EventCode=`"5150`") OR (EventCode=`"5151`") OR (EventCode=`"5154`") OR (EventCode=`"5155`") OR (EventCode=`"5156`") OR (EventCode=`"5157`") OR (EventCode=`"5158`") OR (EventCode=`"5159`")) AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-filtering-platform-connection
        5031(F): The Windows Firewall Service blocked an application from accepting incoming connections on the network.
        5150(-): The Windows Filtering Platform blocked a packet.
        5151(-): A more restrictive Windows Filtering Platform filter has blocked a packet.
        5154(S): The Windows Filtering Platform has permitted an application or service to listen on a port for incoming connections.
        5155(F): The Windows Filtering Platform has blocked an application or service from listening on a port for incoming connections.
        5156(S): The Windows Filtering Platform has permitted a connection.
        5157(F): The Windows Filtering Platform has blocked a connection.
        5158(S): The Windows Filtering Platform has permitted a bind to a local port.
        5159(F): The Windows Filtering Platform has blocked a bind to a local port.
    #>
[Tuple]::Create(`
    "Filtering Platform Packet Drop",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND ((EventCode=`"5152`") OR (EventCode=`"5153`")) AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-filtering-platform-packet-drop
        5152(F): The Windows Filtering Platform blocked a packet.
        5153(S): A more restrictive Windows Filtering Platform filter has blocked a packet
    #>
[Tuple]::Create(`
    "Handle Manipulation",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND ((EventCode=`"4658`") OR (EventCode=`"4690`")) AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-handle-manipulation
        4658(S): The handle to an object was closed.
        4690(S): An attempt was made to duplicate a handle to an object.
    #>
[Tuple]::Create(`
    "Kernel Object",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND ((EventCode=`"4656`") OR (EventCode=`"4658`") OR (EventCode=`"4660`") OR (EventCode=`"4663`")) AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-kernel-object
        4656(S, F): A handle to an object was requested.
        4658(S): The handle to an object was closed.
        4660(S): An object was deleted.
        4663(S): An attempt was made to access an object.
    #>
[Tuple]::Create(`
    "Other Object Access Events",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND ((EventCode=`"4671`") OR (EventCode=`"4691`") OR (EventCode=`"5148`") OR (EventCode=`"5149`") OR (EventCode=`"4698`") OR (EventCode=`"4699`") OR (EventCode=`"4700`") OR (EventCode=`"4701`") OR (EventCode=`"4702`") OR (EventCode=`"5888`") OR (EventCode=`"5889`") OR (EventCode=`"5890`")) AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-other-object-access-events
        4671(-): An application attempted to access a blocked ordinal through the TBS.
        4691(S): Indirect access to an object was requested.
        5148(F): The Windows Filtering Platform has detected a DoS attack and entered a defensive mode; packets associated with this attack will be discarded.
        5149(F): The DoS attack has subsided and normal processing is being resumed.
        4698(S): A scheduled task was created.
        4699(S): A scheduled task was deleted.
        4700(S): A scheduled task was enabled.
        4701(S): A scheduled task was disabled.
        4702(S): A scheduled task was updated.
        5888(S): An object in the COM+ Catalog was modified.
        5889(S): An object was deleted from the COM+ Catalog.
        5890(S): An object was added to the COM+ Catalog.
    #>
[Tuple]::Create(`
    "Registry",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND ((EventCode=`"4663`") OR (EventCode=`"4656`") OR (EventCode=`"4658`") OR (EventCode=`"4660`") OR (EventCode=`"4657`") OR (EventCode=`"5039`") OR (EventCode=`"4670`")) AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-registry
        4663(S): An attempt was made to access an object.
        4656(S, F): A handle to an object was requested.
        4658(S): The handle to an object was closed.
        4660(S): An object was deleted.
        4657(S): A registry value was modified.
        5039(-): A registry key was virtualized.
        4670(S): Permissions on an object were changed.
    #>
[Tuple]::Create(`
    "Removeable Storage",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND ((EventCode=`"4656`") OR (EventCode=`"4658`") OR (EventCode=`"4663`")) AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-removable-storage
        4656(S, F): A handle to an object was requested.
        4658(S): The handle to an object was closed.
        4663(S): An attempt was made to access an object.
    #>
[Tuple]::Create(`
    "SAM",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND (EventCode=`"4661`") AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-sam
        4661(S, F): A handle to an object was requested.
    #>
[Tuple]::Create(`
    "Central Access Policy Staging",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND (EventCode=`"4818`") AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-central-access-policy-staging
        4818(S): Proposed Central Access Policy does not grant the same access permissions as the current Central Access Policy.
    #>
[Tuple]::Create(`
    "Audit Policy Change",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND ((EventCode=`"4902`") OR (EventCode=`"4907`") OR (EventCode=`"4904`") OR (EventCode=`"4905`") OR (EventCode=`"4715`") OR (EventCode=`"4719`") OR (EventCode=`"4817`") OR (EventCode=`"4902`") OR (EventCode=`"4906`") OR (EventCode=`"4907`") OR (EventCode=`"4908`") OR (EventCode=`"4912`") OR (EventCode=`"4904`") OR (EventCode=`"4905`")) AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-audit-policy-change
        4902(S): The Per-user audit policy table was created.
        4907(S): Auditing settings on object were changed.
        4904(S): An attempt was made to register a security event source.
        4905(S): An attempt was made to unregister a security event source.
        4715(S): The audit policy (SACL) on an object was changed.
        4719(S): System audit policy was changed.
        4817(S): Auditing settings on object were changed.
        4902(S): The Per-user audit policy table was created.
        4906(S): The CrashOnAuditFail value has changed.
        4907(S): Auditing settings on object were changed.
        4908(S): Special Groups Logon table modified.
        4912(S): Per User Audit Policy was changed.
        4904(S): An attempt was made to register a security event source.
        4905(S): An attempt was made to unregister a security event source.
    #>
[Tuple]::Create(`
    "Authentication Policy Change",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND ((EventCode=`"4670`") OR (EventCode=`"4706`") OR (EventCode=`"4707`") OR (EventCode=`"4716`") OR (EventCode=`"4713`") OR (EventCode=`"4717`") OR (EventCode=`"4718`") OR (EventCode=`"4739`") OR (EventCode=`"4864`") OR (EventCode=`"4865`") OR (EventCode=`"4866`") OR (EventCode=`"4867`")) AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-authentication-policy-change    
        4670(S): Permissions on an object were changed
        4706(S): A new trust was created to a domain.
        4707(S): A trust to a domain was removed.
        4716(S): Trusted domain information was modified.
        4713(S): Kerberos policy was changed.
        4717(S): System security access was granted to an account.
        4718(S): System security access was removed from an account.
        4739(S): Domain Policy was changed.
        4864(S): A namespace collision was detected.
        4865(S): A trusted forest information entry was added.
        4866(S): A trusted forest information entry was removed.
        4867(S): A trusted forest information entry was modified.
    #>
[Tuple]::Create(`
    "Authorization Policy Change",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND ((EventCode=`"4703`") OR (EventCode=`"4704`") OR (EventCode=`"4705`") OR (EventCode=`"4670`") OR (EventCode=`"4911`") OR (EventCode=`"4913`")) AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-authorization-policy-change   
        4703(S): A user right was adjusted.
        4704(S): A user right was assigned.
        4705(S): A user right was removed.
        4670(S): Permissions on an object were changed.
        4911(S): Resource attributes of the object were changed.
        4913(S): Central Access Policy on the object was changed.
    #>
[Tuple]::Create(`
    "Filtering Platform Policy Change",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND ((EventCode=`"4709`") OR (EventCode=`"4710`") OR (EventCode=`"4711`") OR (EventCode=`"4712`") OR (EventCode=`"5040`") OR (EventCode=`"5041`") OR (EventCode=`"5042`") OR (EventCode=`"5043`") OR (EventCode=`"5044`") OR (EventCode=`"5045`") OR (EventCode=`"5046`") OR (EventCode=`"5047`") OR (EventCode=`"5048`") OR (EventCode=`"5440`") OR (EventCode=`"5441`") OR (EventCode=`"5442`") OR (EventCode=`"5443`") OR (EventCode=`"5444`") OR (EventCode=`"5446`") OR (EventCode=`"5448`") OR (EventCode=`"5449`") OR (EventCode=`"5450`") OR (EventCode=`"5456`") OR (EventCode=`"5457`") OR (EventCode=`"5458`") OR (EventCode=`"5459`") OR (EventCode=`"5460`") OR (EventCode=`"5461`") OR (EventCode=`"5462`") OR (EventCode=`"5463`") OR (EventCode=`"5464`") OR (EventCode=`"5465`") OR (EventCode=`"5466`") OR (EventCode=`"5467`") OR (EventCode=`"5468`") OR (EventCode=`"5471`") OR (EventCode=`"5472`") OR (EventCode=`"5473`") OR (EventCode=`"5474`") OR (EventCode=`"5477`")) AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-filtering-platform-policy-change
        4709(S): IPsec Services was started.
        4710(S): IPsec Services was disabled.
        4711(S): May contain any one of the following:
        4712(F): IPsec Services encountered a potentially serious failure.
        5040(S): A change has been made to IPsec settings. An Authentication Set was added.
        5041(S): A change has been made to IPsec settings. An Authentication Set was modified.
        5042(S): A change has been made to IPsec settings. An Authentication Set was deleted.
        5043(S): A change has been made to IPsec settings. A Connection Security Rule was added.
        5044(S): A change has been made to IPsec settings. A Connection Security Rule was modified.
        5045(S): A change has been made to IPsec settings. A Connection Security Rule was deleted.
        5046(S): A change has been made to IPsec settings. A Crypto Set was added.
        5047(S): A change has been made to IPsec settings. A Crypto Set was modified.
        5048(S): A change has been made to IPsec settings. A Crypto Set was deleted.
        5440(S): The following callout was present when the Windows Filtering Platform Base Filtering Engine started.
        5441(S): The following filter was present when the Windows Filtering Platform Base Filtering Engine started.
        5442(S): The following provider was present when the Windows Filtering Platform Base Filtering Engine started.
        5443(S): The following provider context was present when the Windows Filtering Platform Base Filtering Engine started.
        5444(S): The following sub-layer was present when the Windows Filtering Platform Base Filtering Engine started.
        5446(S): A Windows Filtering Platform callout has been changed.
        5448(S): A Windows Filtering Platform provider has been changed.
        5449(S): A Windows Filtering Platform provider context has been changed.
        5450(S): A Windows Filtering Platform sub-layer has been changed.
        5456(S): PAStore Engine applied Active Directory storage IPsec policy on the computer.
        5457(F): PAStore Engine failed to apply Active Directory storage IPsec policy on the computer.
        5458(S): PAStore Engine applied locally cached copy of Active Directory storage IPsec policy on the computer.
        5459(F): PAStore Engine failed to apply locally cached copy of Active Directory storage IPsec policy on the computer.
        5460(S): PAStore Engine applied local registry storage IPsec policy on the computer.
        5461(F): PAStore Engine failed to apply local registry storage IPsec policy on the computer.
        5462(F): PAStore Engine failed to apply some rules of the active IPsec policy on the computer. Use the IP Security Monitor snap-in to diagnose the problem.
        5463(S): PAStore Engine polled for changes to the active IPsec policy and detected no changes.
        5464(S): PAStore Engine polled for changes to the active IPsec policy, detected changes, and applied them to IPsec Services.
        5465(S): PAStore Engine received a control for forced reloading of IPsec policy and processed the control successfully.
        5466(F): PAStore Engine polled for changes to the Active Directory IPsec policy, determined that Active Directory cannot be reached, and will use the cached copy of the Active Directory IPsec policy instead. Any changes made to the Active Directory IPsec policy since the last poll could not be applied.
        5467(F): PAStore Engine polled for changes to the Active Directory IPsec policy, determined that Active Directory can be reached, and found no changes to the policy. The cached copy of the Active Directory IPsec policy is no longer being used.
        5468(S): PAStore Engine polled for changes to the Active Directory IPsec policy, determined that Active Directory can be reached, found changes to the policy, and applied those changes. The cached copy of the Active Directory IPsec policy is no longer being used.
        5471(S): PAStore Engine loaded local storage IPsec policy on the computer.
        5472(F): PAStore Engine failed to load local storage IPsec policy on the computer.
        5473(S): PAStore Engine loaded directory storage IPsec policy on the computer.
        5474(F): PAStore Engine failed to load directory storage IPsec policy on the computer.
        5477(F): PAStore Engine failed to add quick mode filter.
    #>
[Tuple]::Create(`
    "MPSSVC Rule-Level Policy Change",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND ((EventCode=`"4944`") OR (EventCode=`"4945`") OR (EventCode=`"4946`") OR (EventCode=`"4947`") OR (EventCode=`"4948`") OR (EventCode=`"4949`") OR (EventCode=`"4950`") OR (EventCode=`"4951`") OR (EventCode=`"4952`") OR (EventCode=`"4953`") OR (EventCode=`"4954`") OR (EventCode=`"4956`") OR (EventCode=`"4957`") OR (EventCode=`"4958`")) AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-mpssvc-rule-level-policy-change
        4944(S): The following policy was active when the Windows Firewall started.
        4945(S): A rule was listed when the Windows Firewall started.
        4946(S): A change has been made to Windows Firewall exception list. A rule was added.
        4947(S): A change has been made to Windows Firewall exception list. A rule was modified.
        4948(S): A change has been made to Windows Firewall exception list. A rule was deleted.
        4949(S): Windows Firewall settings were restored to the default values.
        4950(S): A Windows Firewall setting has changed.
        4951(F): A rule has been ignored because its major version number was not recognized by Windows Firewall.
        4952(F): Parts of a rule have been ignored because its minor version number was not recognized by Windows Firewall. The other parts of the rule will be enforced.
        4953(F): A rule has been ignored by Windows Firewall because it could not parse the rule.
        4954(S): Windows Firewall Group Policy settings have changed. The new settings have been applied.
        4956(S): Windows Firewall has changed the active profile.
        4957(F): Windows Firewall did not apply the following rule:
        4958(F): Windows Firewall did not apply the following rule because the rule referred to items not configured on this computer:
    #>
[Tuple]::Create(`
    "Other Policy Change Events",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND ((EventCode=`"4714`") OR (EventCode=`"4819`") OR (EventCode=`"4826`") OR (EventCode=`"4909`") OR (EventCode=`"4910`") OR (EventCode=`"5063`") OR (EventCode=`"5064`") OR (EventCode=`"5065`") OR (EventCode=`"5066`") OR (EventCode=`"5067`") OR (EventCode=`"5068`") OR (EventCode=`"5069`") OR (EventCode=`"5070`") OR (EventCode=`"5447`") OR (EventCode=`"6144`") OR (EventCode=`"6145`")) AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-other-policy-change-events
        4714(S): Encrypted data recovery policy was changed.
        4819(S): Central Access Policies on the machine have been changed.
        4826(S): Boot Configuration Data loaded.
        4909(-): The local policy settings for the TBS were changed.
        4910(-): The group policy settings for the TBS were changed.
        5063(S, F): A cryptographic provider operation was attempted.
        5064(S, F): A cryptographic context operation was attempted.
        5065(S, F): A cryptographic context modification was attempted.
        5066(S, F): A cryptographic function operation was attempted.
        5067(S, F): A cryptographic function modification was attempted.
        5068(S, F): A cryptographic function provider operation was attempted.
        5069(S, F): A cryptographic function property operation was attempted.
        5070(S, F): A cryptographic function property modification was attempted.
        5447(S): A Windows Filtering Platform filter has been changed.
        6144(S): Security policy in the group policy objects has been applied successfully.
        6145(F): One or more errors occurred while processing security policy in the group policy objects.
    #>
[Tuple]::Create(`
    "Sensitive and Non-Sensitive Privilege Use",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND ((EventCode=`"4673`") OR (EventCode=`"4674`") OR (EventCode=`"4985`")) AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-sensitive-privilege-use
        https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-non-sensitive-privilege-use
        4673(S, F): A privileged service was called.
        4674(S, F): An operation was attempted on a privileged object.
        4985(S): The state of a transaction has changed.
    #>
[Tuple]::Create(`
    "IPSec Driver",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND ((EventCode=`"4960`") OR (EventCode=`"4961`") OR (EventCode=`"4962`") OR (EventCode=`"4963`") OR (EventCode=`"4965`") OR (EventCode=`"5478`") OR (EventCode=`"5479`") OR (EventCode=`"5480`") OR (EventCode=`"5483`") OR (EventCode=`"5484`") OR (EventCode=`"5485`")) AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-ipsec-driver
        4960(S): IPsec dropped an inbound packet that failed an integrity check. If this problem persists, it could indicate a network issue or that packets are being modified in transit to this computer. Verify that the packets sent from the remote computer are the same as those received by this computer. This error might also indicate interoperability problems with other IPsec implementations.
        4961(S): IPsec dropped an inbound packet that failed a replay check. If this problem persists, it could indicate a replay attack against this computer.
        4962(S): IPsec dropped an inbound packet that failed a replay check. The inbound packet had too low a sequence number to ensure it was not a replay.
        4963(S): IPsec dropped an inbound clear text packet that should have been secured. This is usually due to the remote computer changing its IPsec policy without informing this computer. This could also be a spoofing attack attempt.
        4965(S): IPsec received a packet from a remote computer with an incorrect Security Parameter Index (SPI). This is usually caused by malfunctioning hardware that is corrupting packets. If these errors persist, verify that the packets sent from the remote computer are the same as those received by this computer. This error may also indicate interoperability problems with other IPsec implementations. In that case, if connectivity is not impeded, then these events can be ignored.
        5478(S): IPsec Services has started successfully.
        5479(): IPsec Services has been shut down successfully. The shutdown of IPsec Services can put the computer at greater risk of network attack or expose the computer to potential security risks.
        5480(F): IPsec Services failed to get the complete list of network interfaces on the computer. This poses a potential security risk because some of the network interfaces may not get the protection provided by the applied IPsec filters. Use the IP Security Monitor snap-in to diagnose the problem.
        5483(F): IPsec Services failed to initialize RPC server. IPsec Services could not be started.
        5484(F): IPsec Services has experienced a critical failure and has been shut down. The shutdown of IPsec Services can put the computer at greater risk of network attack or expose the computer to potential security risks.
        5485(F): IPsec Services failed to process some IPsec filters on a plug-and-play event for network interfaces. This poses a potential security risk because some of the network interfaces may not get the protection provided by the applied IPsec filters. Use the IP Security Monitor snap-in to diagnose the problem.
    #>
[Tuple]::Create(`
    "Other System Events",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND ((EventCode=`"5024`") OR (EventCode=`"5025`") OR (EventCode=`"5027`") OR (EventCode=`"5028`") OR (EventCode=`"5029`") OR (EventCode=`"5030`") OR (EventCode=`"5032`") OR (EventCode=`"5033`") OR (EventCode=`"5034`") OR (EventCode=`"5035`") OR (EventCode=`"5037`") OR (EventCode=`"5058`") OR (EventCode=`"5059`") OR (EventCode=`"6400`") OR (EventCode=`"6401`") OR (EventCode=`"6402`") OR (EventCode=`"6403`") OR (EventCode=`"6404`") OR (EventCode=`"6405`") OR (EventCode=`"6406`") OR (EventCode=`"6407`") OR (EventCode=`"6408`") OR (EventCode=`"6409`")) AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-other-system-events
        Audit Other System Events contains Windows Firewall Service and Windows Firewall driver start and stop events, failure events for these services and Windows Firewall Service policy processing failures.
        Audit Other System Events determines whether the operating system audits various system events.
        The system events in this category include:
            - Startup and shutdown of the Windows Firewall service and driver.
            - Security policy processing by the Windows Firewall service.
            - Cryptography key file and migration operations.
            - BranchCache events.
        5024(S): The Windows Firewall Service has started successfully.
        5025(S): The Windows Firewall Service has been stopped.
        5027(F): The Windows Firewall Service was unable to retrieve the security policy from the local storage. The service will continue enforcing the current policy.
        5028(F): The Windows Firewall Service was unable to parse the new security policy. The service will continue with currently enforced policy.
        5029(F): The Windows Firewall Service failed to initialize the driver. The service will continue to enforce the current policy.
        5030(F): The Windows Firewall Service failed to start.
        5032(F): Windows Firewall was unable to notify the user that it blocked an application from accepting incoming connections on the network.
        5033(S): The Windows Firewall Driver has started successfully.
        5034(S): The Windows Firewall Driver was stopped.
        5035(F): The Windows Firewall Driver failed to start.
        5037(F): The Windows Firewall Driver detected critical runtime error. Terminating.
        5058(S, F): Key file operation.
        5059(S, F): Key migration operation.
        6400(-): BranchCache: Received an incorrectly formatted response while discovering availability of content.
        6401(-): BranchCache: Received invalid data from a peer. Data discarded.
        6402(-): BranchCache: The message to the hosted cache offering it data is incorrectly formatted.
        6403(-): BranchCache: The hosted cache sent an incorrectly formatted response to the client.
        6404(-): BranchCache: Hosted cache could not be authenticated using the provisioned SSL certificate.
        6405(-): BranchCache: %2 instance(s) of event id %1 occurred.
        6406(-): %1 registered to Windows Firewall to control filtering for the following: %2
        6407(-): 1%
        6408(-): Registered product %1 failed and Windows Firewall is now controlling the filtering for %2
        6409(-): BranchCache: A service connection point object could not be parsed.
    #>
[Tuple]::Create(`
    "Security State Change",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND ((EventCode=`"4608`") OR (EventCode=`"4609`") OR (EventCode=`"4616`") OR (EventCode=`"4621`")) AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-security-state-change
        4608(S): Windows is starting up.
        4616(S): The system time was changed.
        4621(S): Administrator recovered system from CrashOnAuditFail.
        4609(-): Note  Event 4609(S): Windows is shutting down currently doesn’t generate. It is a defined event, but it is never invoked by the operating system.
    #>
[Tuple]::Create(`
    "Security System Extension",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND ((EventCode=`"4610`") OR (EventCode=`"4611`") OR (EventCode=`"4614`") OR (EventCode=`"4622`") OR (EventCode=`"4697`")) AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-security-system-extension
        4610(S): An authentication package has been loaded by the Local Security Authority.
        4611(S): A trusted logon process has been registered with the Local Security Authority.
        4614(S): A notification package has been loaded by the Security Account Manager.
        4622(S): A security package has been loaded by the Local Security Authority.
        4697(S): A service was installed in the system.
    #>
[Tuple]::Create(`
    "System Integrity",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND ((EventCode=`"4612`") OR (EventCode=`"4615`") OR (EventCode=`"4616`") OR (EventCode=`"5038`") OR (EventCode=`"5056`") OR (EventCode=`"5062`") OR (EventCode=`"5057`") OR (EventCode=`"5060`") OR (EventCode=`"5061`") OR (EventCode=`"6281`") OR (EventCode=`"6410`")) AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice'),
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-system-integrity
        4612(S): Internal resources allocated for the queuing of audit messages have been exhausted, leading to the loss of some audits.
        4615(S): Invalid use of LPC port.
        4618(S): A monitored security event pattern has occurred.
        4816(S): RPC detected an integrity violation while decrypting an incoming message.
        5038(F): Code integrity determined that the image hash of a file is not valid. The file could be corrupt due to unauthorized modification or the invalid hash could indicate a potential disk device error.
        5056(S): A cryptographic self-test was performed.
        5062(S): A kernel-mode cryptographic self-test was performed.
        5057(F): A cryptographic primitive operation failed.
        5060(F): Verification operation failed.
        5061(S, F): Cryptographic operation.
        6281(F): Code Integrity determined that the page hashes of an image file are not valid. The file could be improperly signed without page hashes or corrupt due to unauthorized modification. The invalid hashes could indicate a potential disk device error.
        6410(F): Code integrity determined that a file does not meet the security requirements to load into a process.
    #>
[Tuple]::Create(`
    "Other Events",
    'Get-WmiObject Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile=`"Security`") AND ((EventCode=`"1100`") OR (EventCode=`"1102`") OR (EventCode=`"1104`") OR (EventCode=`"1105`") OR (EventCode=`"1108`")) AND ((TimeGenerated >= `"$PastDate`") AND (TimeGenerated <= `"$Today`"))" | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type | Select-Object -first $LimitNumberOfEventLogsCollectToChoice')
    <#  https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/other-events
        1100(S): The event logging service has shut down.
        1102(S): The audit log was cleared.
        1104(S): The security log is now full.
        1105(S): Event log automatic backup.
        1108(S): The event logging service encountered an error while processing an incoming event published from %1
    #>

));
}


# ============================================================================================================================================================
# ============================================================================================================================================================
# The following functions are the banners
# ============================================================================================================================================================
# ============================================================================================================================================================
Function PoSh_Banner1 {
    Write-Host ""
    Write-Host ""
    Write-Host ""
    Write-Host "  ______             ____  __      " -f Cyan -n ; Write-Host "       " -f Gray -n ; Write-Host "  _____     ____  ___    __  _____  " -f Cyan
    Write-Host " |   _  \           /  __||  |     " -f Cyan -n ; Write-Host "       " -f Gray -n ; Write-Host " /  _  \   / ___\ |  \  /  | | ___| " -f Cyan
    Write-Host " |  |_)  | _____   |  (   |  |___  " -f Cyan -n ; Write-Host " ____  " -f Gray -n ; Write-Host "|  (_)  | / /     |   \/   | | |_   " -f Cyan
    Write-Host " |   ___/ /  _  \   \  \  |   _  \ " -f Cyan -n ; Write-Host "|____| " -f Gray -n ; Write-Host "|   _   || |      | |\  /| | |  _|  " -f Cyan
    Write-Host " |  |    |  (_)  | __)  | |  | |  |" -f Cyan -n ; Write-Host "       " -f Gray -n ; Write-Host "|  | |  | \ \____ | | \/ | | | |__  " -f Cyan
    Write-Host " |__|     \_____/ |____/  |__| |__|" -f Cyan -n ; Write-Host "       " -f Gray -n ; Write-Host "|__| |__|  \____/ |_|    |_| |____| " -f Cyan
    Write-Host ""
}

Function PoSh_Banner2 {
    Write-Host "==============================================================================" -ForegroundColor White
    Write-Host " Windows Remote Management (WinRM) Is Necessary For Endpoint Data Collection."  -ForegroundColor Red
    Write-Host " PowerShell - Automated Collection Made Easy (ACME) For The Security Analyst!"  -ForegroundColor Yellow
    Write-Host " ACME: The Point At Which Something Is The Best, Perfect, Or Most Successful."  -ForegroundColor Green
    Write-Host "==============================================================================" -ForegroundColor White
    Write-Host ""
}


# ============================================================================================================================================================
# ============================================================================================================================================================
# The Menu Section
# ============================================================================================================================================================
# ============================================================================================================================================================

# Initial Banner
Clear-Host
Posh_Banner1
PoSh_Banner2


# If -ComputerName switch IS provided as an argument, it will use the provided host/IPs/network
if ($SingleComputerName) {
    $global:ComputerList = $SingleComputerName
    Write-Host "PoSh-ACME Will Collect Data From: " -ForegroundColor Yellow -NoNewline
    Write-Host "$global:ComputerList" -ForegroundColor White
}

# If -ComputerName switch is NOT provided as an argument, a menu is provided to help select hosts/IPs/network
elseif (!$SingleComputerName) {
    Write-Host "How do you want to list computers? [1]"	-ForegroundColor Yellow
    $strResponse = Read-Host " [1] All Domain Computers (Must provide Domain) `n [2] Computer names from a File `n [3] List a Single Computer or Network manually `n "
    if($strResponse -eq "1" -or $strResponse -eq ""){. ListComputers | Sort-Object}
    elseif($strResponse -eq "2"){. ListTextFile}
    elseif($strResponse -eq "3"){. SingleEntry}
	else {
        Write-Host "You did not supply a correct response," -ForegroundColor Red
        Write-Host "`tPlease run the script again." -ForegroundColor Yellow
        break
    }
}

#####
# If the -LimitNumberOfEventLogsCollectTo switch is NOT provided as an argument, the respective menu section will appear
#####
if (!$LimitNumberOfEventLogsCollectTo) {
    Write-Host "`nWhat number do you want to limited Event Logs from being collected? [$LimitNumberOfEventLogsCollectToDefault] " -ForegroundColor Yellow
    Write-Host "The more you collect the longer it takes and the larger the file."
    $LimitNumberOfEventLogsCollectToPrompt = Read-Host " "
    # Note that the default EventLog Number is at the top of the script
    if ($LimitNumberOfEventLogsCollectToPrompt -eq "") {$LimitNumberOfEventLogsCollectToChoice = $LimitNumberOfEventLogsCollectToDefault}
    else {$LimitNumberOfEventLogsCollectToChoice = $LimitNumberOfEventLogsCollectToPrompt}
}
elseif ($LimitNumberOfEventLogsCollectTo) {
    $LimitNumberOfEventLogsCollectToChoice = $LimitNumberOfEventLogsCollectTo
}


#####
# If the -AuditEventLogs or -DoNotAuditEventLogs switches are NOT provided as an argument, the respective menu section will appear
#####
# Provides error if both switches are provided
if ($AuditEventLogs -and $DoNotAuditEventLogs) {
    Write-Host "`n[!] Error: You cannot specify both of the following switches together" -ForegroundColor Red
    Write-Host "    -AuditEventLogs" -ForegroundColor Yellow
    Write-Host "    -DoNotAuditEventLogs`n" -ForegroundColor Yellow
    exit(1);
}
elseif ($AuditEventLogs) {$AuditEventLogsChoice = "True"}
elseif ($DoNotAuditEventLogs) {$AuditEventLogsChoice = "False"}
else {
    Write-Host "`nDo you want to run various Event Log Audits? [False]" -ForegroundColor Yellow
    Write-Host "This will collect specific Event Logs and group them logically." 
    Write-Host " [1] True `n [2] False" 
    $AuditEventLogsPrompt = Read-Host " "
        if ($AuditEventLogsPrompt -eq "")  {$AuditEventLogsChoice = "False"}
        if ($AuditEventLogsPrompt -eq "1") {$AuditEventLogsChoice = "True"}
        if ($AuditEventLogsPrompt -eq "2") {$AuditEventLogsChoice = "False"}
}
    #####
    # This menu is only an option if the $AuditEventLogsChoice is set to True
    # If the -LimitDaysOfEventLogsCollectToDefault switch is  NOT provided as an argument, the respective menu section will appear
    #####
    if ($AuditEventLogsChoice -eq "True") { if (!$LimitDaysOfEventLogsCollectTo) {
        Write-Host "`nHow many days back will Event Logs be audited? [$LimitDaysOfEventLogsCollectToDefault] " -ForegroundColor Yellow
        Write-Host "The more you collect the longer it takes and the larger the file."
        $LimitDaysOfEventLogsCollectToPrompt = Read-Host " "
        # Note that the default EventLog Number is at the top of the script
        if ($LimitDaysOfEventLogsCollectToPrompt -eq "") {$LimitDaysOfEventLogsCollectToChoice = $LimitDaysOfEventLogsCollectToDefault
            $PastDate = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime((Get-Date).AddDays(-$LimitDaysOfEventLogsCollectToDefault))
        }
        else {$LimitDaysOfEventLogsCollectToChoice = $LimitDaysOfEventLogsCollectToPrompt
            $PastDate = [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime((Get-Date).AddDays(-$LimitDaysOfEventLogsCollectToChoice))    
        }
    }
    elseif ($LimitDaysOfEventLogsCollectTo) {
        $LimitDaysOfEventLogsCollectToChoice = $LimitDaysOfEventLogsCollectTo
    } }


#####
# If the -LocalhostIsDomainServer or -LocalhostIsNotDomainServer switches are NOT provided as an argument, the respective menu section will appear
#####
# Provides error if both switches are provided
if ($LocalhostIsDomainServer -and $LocalhostIsNotDomainServer) {
    Write-Host "`n[!] Error: You cannot specify both of the following switches together" -ForegroundColor Red
    Write-Host "    -LocalhostIsDomainServer" -ForegroundColor Yellow
    Write-Host "    -LocalhostIsNotDomainServer`n" -ForegroundColor Yellow
    exit(1);
}
elseif ($LocalhostIsDomainServer) {$LocalhostIsDomainServerChoice = "True"}
elseif ($LocalhostIsNotDomainServer) {$LocalhostIsDomainServerChoice = "False"}
else {
    Write-Host "`nIs this host a Domain Controller or Server? [False]" -ForegroundColor Yellow
    Write-Host "This will Pull Addtional Domain and User Information." 
    Write-Host " [1] True `n [2] False" 
    $LocalhostIsDomainServerPrompt = Read-Host " "
        if ($LocalhostIsDomainServerPrompt -eq "")  {$LocalhostIsDomainServerChoice = "False"}
        if ($LocalhostIsDomainServerPrompt -eq "1") {$LocalhostIsDomainServerChoice = "True"}
        if ($LocalhostIsDomainServerPrompt -eq "2") {$LocalhostIsDomainServerChoice = "False"}
}

# Outputs a List of all the Computers initially provided
$global:ComputerList | Out-File "$PoShLocation\~Computer List - Original List.txt"



# ============================================================================================================================================================
# ============================================================================================================================================================
# Start Collection and Compilation of Data
# ============================================================================================================================================================
# ============================================================================================================================================================

Clear-Host
PoSh_Banner1

# Starts the timer for the collection
Set-Variable -Name ScriptTimerStart -Value $(Get-Date) -Force

Write-Host "Computer List to Collect Data From:" -ForegroundColor Yellow
$global:ComputerList
Write-Host ""


# ------------------------------------------------------------------------------------------------------------------------------------------------------------
# Tests connection to remote hosts and removes them if unable to pull data
# ------------------------------------------------------------------------------------------------------------------------------------------------------------
$TotalTestPercentCompleted = 0
Write-Host "Testing ability to collect data from remote hosts." -ForegroundColor Cyan
foreach ($TargetComputer in $global:ComputerList) {
    # Provides the Progress Bar
    Write-Progress `
        -Activity "Testing Collection Capability on: $TargetComputer" `
        -PercentComplete $([math]::Round($($TotalTestPercentCompleted / $global:ComputerList.Count * 100),2)) `
        -CurrentOperation "$([math]::Round($($TotalTestPercentCompleted / $global:ComputerList.Count * 100),2))% Completed"
        #-Status $CollectionName
    $TotalTestPercentCompleted ++
    
    try {
        Get-WmiObject -Class Win32_computersystem -ComputerName $TargetComputer -ErrorAction Stop | Out-Null
        #$CheckWinRM = Get-Service -ComputerName $TargetComputer | Where-Object {$_.Name -eq "WinRM"} | Select-Object -Property Status -ExpandProperty Status
        #if ($CheckWinRM -ne "Running") {Write-Host "action taken"}
    }
    catch [System.Runtime.InteropServices.COMException],[System.UnauthorizedAccessException] { 
        #Write-Host "$($Error[0])" -ForegroundColor Red    
        Write-Host "[!] Unable to collect from host! " -ForegroundColor Red -NoNewline
        Write-Host "Removing the following computer from the list: " -ForegroundColor Yellow -NoNewline
        Write-Host "$TargetComputer" -ForegroundColor White
        # Removes $TargetComputer from $global:ComputerList if it fails to connect
        $global:ComputerList = $global:ComputerList | Where-Object { $_ -ne "$TargetComputer" }
        $global:ComputerListNotCollected +=  $TargetComputer
    }
    catch { 
        ### The following $Error line helps identify the specific exception to catch!
        # $Error[0].Exception.GetType().FullName    
        #Write-Host "NO:  $TargetComputer" 
        Write-Host "What is this... a new Error?" -ForegroundColor Red
        $Error[0].Exception.GetType().FullName
        Write-Host "$($Error[0])" -ForegroundColor Red    
    }
}


# Provides the Progress Bar
Write-Progress `
    -Activity "Testing Connection with: $TargetComputer" `
    -PercentComplete (($CountHosts / $global:ComputerList.Count) * 100) `
    -CurrentOperation "$([math]::Round($($TotalPercentCompleted / $global:ComputerList.Count * 100),2))% Completed"
    #-Status $CollectionName
$CountHosts++
$global:TotalPercentCompleted++


# Outputs a List of all the Computers that will not be collected from
$global:ComputerListNotCollected | Out-File "$PoShLocation\~Computer List - Not Collected.txt"

# Outputs a List of all the Computers to Collect From
$global:ComputerList | Out-File "$PoShLocation\~Computer List - Collected From.txt"

Write-Host "`nPoSh-ACME Will Begin to Collect and Compile Data...`n" -ForegroundColor Green

New-Item -ItemType Directory "$PoShLocation" -Force | Out-Null 



# ------------------------------------------------------------------------------------------------------------------------------------------------------------
# Counts up the total number of commands - This is used by the progress bar to calcuation overall completion percentage
# ------------------------------------------------------------------------------------------------------------------------------------------------------------
if ($LocalhostIsDomainServerChoice -eq "True" ) {
    # This will add to the command count to update the progress bar
    $global:NumberOfSections += $ActiveDirectoryCommandList.Count

    # This will add to the command count to update the progress bar
    $global:NumberOfSections += $netdomCommandList.Count
}

# This will add to the command count to update the progress bar
$global:NumberOfSections += $WmiObjectCommandList.Count

# This number represents the number of queries that requires addtional post processing code and has to be counted manually
$global:NumberOfSections += 5



# ============================================================================================================================================================
# ============================================================================================================================================================
# Retrieve Domain Information
# ============================================================================================================================================================
# ============================================================================================================================================================

# Checks if the -LocalhostIsDomainServer switch is set or the menu choice is yes, if so it will run the commands only on the local host.
if ($LocalhostIsDomainServerChoice -eq "True" ) {

# ------------------------------------------------------------------------------------------------------------------------------------------------------------
# Retrieve Domain User Account Information - Command Execution
# ------------------------------------------------------------------------------------------------------------------------------------------------------------

# Creates the collection specific directory that stores each host results
New-Item -ItemType Directory "$PoShLocation\Domain Information" -Force | Out-Null

# Executes all the User Account commands
foreach ($tuple in $ActiveDirectoryCommandList) {
    # This is the first part of the tuple and becomes the name of the file
    $CollectionName = $($tuple.Item1)
    $global:IncrementBar = 1
    CollectionStartMessage
    $Command = $($tuple.Item2)
    # The -match "Get" is to detect PowerShell cmdlets and exports the results as .csv, otherwise they'll export as .txt files
    if ($Command -match "Get") {
        Invoke-Expression $Command | Export-Csv -Path "$PoShLocation\Domain Information\$CollectionName.csv" -NoTypeInformation
    }
    else {
        Invoke-Expression $Command | Out-File -FilePath "$PoShLocation\Domain Information\$CollectionName.txt"
    }
    CollectionProgressStatus
    CollectionStopMessage
}


# ------------------------------------------------------------------------------------------------------------------------------------------------------------
# Retrieve Domain Computer Information - Command Execution
# ------------------------------------------------------------------------------------------------------------------------------------------------------------

# Creates a directory to store the individual collections
$CollectionName = "Domain Information"
$CollectionDirectory = $CollectionName
New-Item -ItemType Directory -Path "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" -Force | Out-Null

# Executes all the Domain Information commands
foreach ($tuple in $netdomCommandList) {
    $CollectionName = $($tuple.Item1)
    $global:IncrementBar = 1
    CollectionStartMessage
    
    $Command = $($tuple.Item2)
    Write-Output "================================================================================================" | Out-File -FilePath "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName.txt" -Force
    Write-Output "================================================================================================" | Out-File -FilePath "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName.txt" -Append -Force
    Write-Output "$($tuple.Item1)" | Out-File -FilePath "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName.txt" -Append -Force 
    Write-Output "------------------------------------------------------------------------------------------------" | Out-File -FilePath "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName.txt" -Append -Force
    Invoke-Expression $Command | Out-File -FilePath "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName.txt" -Append -Force

    # Removes empty blank lines form the file
    (Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName.txt") | Where-Object {$_.trim() -ne ""} | Set-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName.txt"

    CollectionProgressStatus
    CollectionStopMessage
}

# Combines the files into a single file
$CollectionName = "Domain Information"
foreach ($command in $netdomCommandList) {
    $Filename = ".\$($command.Item1).txt"
    Get-Content -Path "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$Filename" | Out-File -FilePath "$PoShLocation\$CollectionName.txt" -Force -Append   
}   
}



# ============================================================================================================================================================
# ============================================================================================================================================================
# Main PowerShell Collection Get-WmiObject - Command Exection
# ============================================================================================================================================================
# ============================================================================================================================================================

# Executes all Get-WmiObject Commands
foreach ($tuple in $WmiObjectCommandList) {
    $CollectionName = $($tuple.Item1)
    $CollectionDirectory = $CollectionName
    $global:IncrementBar = 1
    CollectionStartMessage

    # Creates the collection specific directory that stores each host results
    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    foreach ($TargetComputer in $global:ComputerList) {
        $Command = $($tuple.Item2)
        Invoke-Expression $Command | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName - $TargetComputer.csv" -NoTypeInformation
        CollectionProgressStatus
    }
    CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
    CollectionStopMessage
}


# ============================================================================================================================================================
# ============================================================================================================================================================
# Main PowerShell Collection Invoke-WmiMethod - Command Exection
# ============================================================================================================================================================
# ============================================================================================================================================================

# ============================================================================================================================================================
# Sections that require some post processing to to make them csv compatable
# ============================================================================================================================================================

# ------------------------------------------------------------------------------------------------------------------------------------------------------------
# Firewall Status
# ------------------------------------------------------------------------------------------------------------------------------------------------------------

# The Following 'if ($true)' is used just to collapse the section when viewing in PowerShellISE, otherwise there's no other function
if ($true) {

$CollectionName = "Firewall Status"
$CollectionShortName = $CollectedResultsUncompiled -replace " ",""
$CollectionDirectory = $CollectionName

# Creates the collection specific directory that stores each host results
New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" -Force | Out-Null
$global:IncrementBar = 1
CollectionStartMessage

# Executes all the User Account commands
foreach ($TargetComputer in $global:ComputerList) {
    # Execute Commands to collect data from the targets
    $Command = $($tuple.Item2)
    Invoke-WmiMethod -Class Win32_Process -Name Create -ComputerName $TargetComputer -ArgumentList "cmd /c netsh advfirewall show allprofiles state > c:\$CollectionShortName-$TargetComputer.txt" | Out-Null
    
    Start-Sleep -Seconds $SleepTime

    # This copies the data from the target then removes the copy
    Copy-Item "\\$TargetComputer\c$\$CollectionShortName-$TargetComputer.txt" "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
    Remove-Item "\\$TargetComputer\c$\$CollectionShortName-$TargetComputer.txt"

    $FirewallStatus = (Get-Content -Path "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") -replace '-{2,}','' -replace ',',';' -replace '^ {3,}',':  ' | Where-Object {$_.trim() -ne ''} 
    
    # Extracts the fields that become the file headers
    $FileHeader = "Firewall Profile,State"
    # Extracts the data 
    $FileData = $(($FirewallStatus | Out-String) -replace '-{2,}','' -replace ' {2,}','' -replace "`n","" -replace ":","," -replace "State","" -creplace "ON","ON`n" -creplace "OFF","OFF`n" -replace 'Ok.','' -replace "^ | $","") -split "`n" | Where-Object {$_.trim() -ne ""}
    
    # Adds computer names/ips to data
    $ConvertedToCsv = ""
    $ConvertedToCsv += "PSComputerName,$FileHeader`n"
    foreach ($line in $FileData) {$ConvertedToCsv += "$TargetComputer,$line`n"}
    $ConvertedToCsv | Where-Object {$_.trim() -ne ""} | Where-Object {$_.PSComputerName -ne ""}| Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"
}
    
CollectionProgressStatus
    
CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
CollectionStopMessage



# ------------------------------------------------------------------------------------------------------------------------------------------------------------
# Firewall Rules
# ------------------------------------------------------------------------------------------------------------------------------------------------------------

$CollectionName = "Firewall Rules"
$CollectionShortName = $CollectedResultsUncompiled -replace " ",""
$CollectionDirectory = $CollectionName

# Creates the collection specific directory that stores each host results
New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" -Force | Out-Null
$global:IncrementBar = 1
CollectionStartMessage

# Executes all the User Account commands
foreach ($TargetComputer in $global:ComputerList) {
    # Execute Commands to collect data from the targets
    $Command = $($tuple.Item2)
    Invoke-WmiMethod -Class Win32_Process -Name Create -ComputerName $TargetComputer -ArgumentList "cmd /c netsh advfirewall firewall show rule name=all > c:\$CollectionShortName-$TargetComputer.txt" | Out-Null

    Start-Sleep -Seconds $SleepTime

    # This copies the data from the target then removes the copy
    Copy-Item "\\$TargetComputer\c$\$CollectionShortName-$TargetComputer.txt" "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
    Remove-Item "\\$TargetComputer\c$\$CollectionShortName-$TargetComputer.txt"

    $FirewallRules = (Get-Content -Path "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") -replace '-{2,}','' -replace ',',';' -replace '^ {3,}',':  ' | Where-Object {$_.trim() -ne ''} 

    # Extracts the fields that become the file headers
    ###$FileHeader = ""
    ###foreach ($line in ($FirewallRules | Select-Object -First 12)) {$FileHeader += "$(($line -replace ' {2,}','' -split ':')[0]),"}
    ###$FileHeader = $FileHeader -split "`n" -replace "^,|,$",""
    $FileHeader = "Rule Name,Enabled,Direction,Profiles,Grouping,LocalIP,RemoteIP,Protocol,LocalPort,RemotePort,Edge traversal,Action"

    # Extracts the data 
    $FileData = ""
    foreach ($line in ($FirewallRules)) {$FileData += "$(($line -replace ' {2,}','' -replace "Allow","Allow;;" -replace "Block","Block;;" -replace "Bypass","Bypass;;" -split ':')[1]),"}
    $FileData = $FileData -split ';;' -replace "^,|,$|","" -replace " ,|, ","," | Where-Object {$_.trim() -ne ""}

    # Adds computer names/ips to data
    $ConvertedToCsv = ""
    $ConvertedToCsv += "PSComputerName,$FileHeader`n"
    foreach ($Rule in $FileData) {$ConvertedToCsv += "$TargetComputer,$Rule`n"}
    $ConvertedToCsv | Where-Object {$_.trim() -ne ""} | Where-Object {$_.PSComputerName -ne ""}| Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"
}
    
CollectionProgressStatus
    
CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
CollectionStopMessage



# ------------------------------------------------------------------------------------------------------------------------------------------------------------
# Proxy Port Rules
# ------------------------------------------------------------------------------------------------------------------------------------------------------------

# This is the first part of the tuple that is primary used as the collections name. It is also the variable name used when providing the graphical update.
$CollectionName = "Proxy Rules"
# This is used to create the directory name
$CollectionDirectory = $CollectionName

# Creates the collection specific directory that stores each host results
New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" -Force | Out-Null
$global:IncrementBar = 1
CollectionStartMessage

# Executes all the User Account commands
foreach ($TargetComputer in $global:ComputerList) {
    # Execute Commands to collect data from the targets
    $Command = $($tuple.Item2)
    Invoke-WmiMethod -Class Win32_Process -Name Create -ComputerName $TargetComputer -ArgumentList "cmd /c netsh interface portproxy show all > c:\ProxyRules-$TargetComputer.txt" | Out-Null

    Start-Sleep -Seconds $SleepTime

    # This copies the data from the target then removes the copy
    Copy-Item "\\$TargetComputer\c$\ProxyRules-$TargetComputer.txt" "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
    Remove-Item "\\$TargetComputer\c$\ProxyRules-$TargetComputer.txt"

    # Extracts the fields that become the file headers
    <# $FileHeader = ""
    foreach ($line in ($PortProxyRules | Select-Object -Skip 3 -First 1)) {$FileHeader += $line -replace ' {2,}',','} #>
    $FileHeader = "Listen on IPv4 Address,Listen on IPv4 Port,Connect to IPv4 Address,Connect to IPv4 Port"

    # Extracts the fields that contain data
    $ProxyRules = Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"

    $FileData = @()
    foreach ($line in ($ProxyRules | Select-Object -Skip 5)) {$FileData += "`n$($line -replace ' {2,}',',')"}
    
    # Combines the csv header and data to create the file
    $ConvertedToCsv = @()
    $ConvertedToCsv += $FileHeader
    $ConvertedToCsv += $FileData  -replace "^,|,$","" -replace "^ | $","" -replace ";;","`n"
    $CsvFile = $ConvertedToCsv

    # Adds the Computer Name/IP header and field data
    $FormattedCsvFile = ""
    foreach ($line in $($CsvFile | Select-Object -First 1 )) {$FormattedCsvFile =  "PSComputerName,"  + $line}
    foreach ($line in $($CsvFile | Select-Object -Skip 1 | Where-Object {$_.trim() -ne ""}))  {$FormattedCsvFile += "`n$TargetComputer," + $($line -replace "`n","")}
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"

    $FormattedCsvFile | Out-File -FilePath "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"
    
    CollectionProgressStatus
    }
CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
CollectionStopMessage



# ------------------------------------------------------------------------------------------------------------------------------------------------------------
# Network Connections - TCP
# ------------------------------------------------------------------------------------------------------------------------------------------------------------

$CollectionName = "Network Connections (netstat tcp)"
$CollectionDirectory = $CollectionName
$global:IncrementBar = 1
CollectionStartMessage

# Creates the collection specific directory that stores each host results
New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

foreach ($TargetComputer in $global:ComputerList) {
    Invoke-WmiMethod -Class Win32_Process -Name Create -ComputerName $TargetComputer -ArgumentList "cmd /c netstat -anob -p tcp > c:\netstat-$TargetComputer.txt" | Out-Null
    
    # This deleay is introduced to allow the collection command to complete gathering data before it pulls back the data
    Start-Sleep -Seconds $SleepTime
    Copy-Item   "\\$TargetComputer\c$\netstat-$TargetComputer.txt" "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory"
    Remove-Item "\\$TargetComputer\c$\netstat-$TargetComputer.txt"

    # Processes collection to format it from txt to csv
    $Connections = Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\netstat-$TargetComputer.txt" | Select-Object -skip 3
    $TCPdata = @()
    $Connections.trim()  | Out-String |   ForEach-Object {$TCPdata += $_ -replace "`r`n",";;" -replace ";;;;",";;" -creplace ";;TCP","`r`nTCP" -replace ";;","  " -replace " {2,}","," -creplace "PID","PID,Executed Process" -replace "^,|,$",""}
        # -replace "`r`n",";;"                       Replaces return cariages and newlines with a new place holder field separator
        # -replace ";;;;",";;"                       Replaces instances where two return carriages and newlines were back to back
        # -creplace ";;TCP","`r`nTCP"                Replaces the beginning of the TCP network connection line with a return carriage/new line
        # -replace ';;\[',' ['                       Collapses the two separate fields into one
        # -replace ";;","  "                         Replaces the field separator (return carriages/new lines) with double white spaces
        # -replace " {2,}",","                       Replaces two or more white spaces with commas to make it a CSV
        # -creplace "PID","PID,Executed Process"     Addes in extra field header that is not present for the Executables (the 'b' in -anob)
        # -replace "^,|,$",""                        Repaces any potential commas at the beginning or end of a line
    $format = $TCPdata -split "`r`n"
    $TCPnetstat =@()
    # This section is needed to combine two specific csv fields together for easier viewing
    foreach ($line in $format) {
        if ($line -match "\d,\[") {$TCPnetstat += $line}
        if ($line -notmatch "\d,\[") {$TCPnetstat += $line -replace ",\["," ["}
    }
    
    # Adds the addtional column header, PSComputerName, and target computer to each connection
    $TCPnetstat | ForEach-Object {
        if ($_ -match "PID,Executed Process") {
            "PSComputerName," + "$_"
        }
        else {
            "$TargetComputer," + "$_"
        }
    } | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\netstat-formated-$TargetComputer.csv"

    CollectionProgressStatus
}
CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
CollectionStopMessage 



# ------------------------------------------------------------------------------------------------------------------------------------------------------------
# Network Connections - UDP
# ------------------------------------------------------------------------------------------------------------------------------------------------------------
$CollectionName = "Network Connections (netstat udp)"
$CollectionDirectory = $CollectionName
$global:IncrementBar = 1
CollectionStartMessage

# Creates the collection specific directory that stores each host results
New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null


foreach ($TargetComputer in $global:ComputerList) {
    Invoke-WmiMethod -Class Win32_Process -Name Create -ComputerName $TargetComputer -ArgumentList "cmd /c netstat -anob -p udp > c:\netstat-$TargetComputer.txt" | Out-Null
    
    # This deleay is introduced to allow the collection command to complete gathering data before it pulls back the data
    Start-Sleep -Seconds $SleepTime
    Copy-Item   "\\$TargetComputer\c$\netstat-$TargetComputer.txt" "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory"
    Remove-Item "\\$TargetComputer\c$\netstat-$TargetComputer.txt"

    # Processes collection to format it from txt to csv
    $Connections = Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\netstat-$TargetComputer.txt" | Select-Object -skip 3
    $TCPdata = @()
    $Connections.trim()  | Out-String |   ForEach-Object {$TCPdata += $_ -replace "`r`n",";;" -replace ";;;;",";;" -creplace ";;UDP","`r`nUDP" -replace ";;","  " -replace " {2,}","," -replace "State,","" -creplace "PID","PID,Executed Process" -replace "^,|,$",""}

    $format = $TCPdata -split "`r`n"
    $TCPnetstat =@()
    # This section is needed to combine two specific csv fields together for easier viewing
    foreach ($line in $format) {
        if ($line -match "\d,\[") {$TCPnetstat += $line}
        if ($line -notmatch "\d,\[") {$TCPnetstat += $line -replace ",\["," ["}
    }
    
    # Adds the addtional column header, PSComputerName, and target computer to each connection
    $TCPnetstat | ForEach-Object {
        if ($_ -match "PID,Executed Process") {"PSComputerName," + "$_"}
        else {"$TargetComputer," + "$_"}
    } | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\netstat-formated-$TargetComputer.csv"

    CollectionProgressStatus
}
CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
CollectionStopMessage 


# ------------------------------------------------------------------------------------------------------------------------------------------------------------
# Scheduled Tasks (schtasks)
# ------------------------------------------------------------------------------------------------------------------------------------------------------------

# Executes all Get-WmiObject Commands
$CollectionName = "Scheduled Tasks (schtasks)"
$CollectionDirectory = $CollectionName
# This is used when executing commands remotely on targets, it prevents errors by removing spaces in collection name
$CollectionShortName = $CollectionName -replace ' ',''
$global:IncrementBar = 1
CollectionStartMessage

# Creates the collection specific directory that stores each host results
New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null


foreach ($TargetComputer in $global:ComputerList) {
    $Command = $($tuple.Item2)
    Invoke-WmiMethod -Class Win32_Process -Name Create -Computername $TargetComputer -ArgumentList "cmd /c schtasks /query /V /FO CSV > c:\$TargetComputer-$CollectionShortName.csv" | Out-Null
    # This deleay is introduced to allow the collection command to complete gathering data before it pulls back the data
    Start-Sleep -Seconds $SleepTime
    # Pulls back the data from the Target Computer
    Copy-Item -Path "\\$TargetComputer\c$\$TargetComputer-$CollectionShortName.csv" -Destination "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\"
    Remove-Item -Path "\\$TargetComputer\c$\$TargetComputer-$CollectionShortName.csv"
    CollectionProgressStatus
}
CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"

# Removes duplicate headers from csv file
$count = 1
$output = @()
$Contents = Get-Content "$PoShLocation\$CollectionName.csv" | Sort-Object -Unique -Descending
$Header = $Contents | Select-Object -First 1
foreach ($line in $Contents) {
    if ($line -match $Header -and $count -eq 1) {
        $output = $line + "`r`n"
        $count ++
    }
    elseif ($line -notmatch $Header) {
        $output += $line + "`r`n"
    }
}
Remove-Item -Path "$PoShLocation\$CollectionName.csv"
$output | Out-File -FilePath "$PoShLocation\$CollectionName.csv"
    
CollectionStopMessage



# ------------------------------------------------------------------------------------------------------------------------------------------------------------
# DLLs Loaded by Processes
# ------------------------------------------------------------------------------------------------------------------------------------------------------------

# Executes all Get-WmiObject Commands
$CollectionName = "DLLs Loaded by Processes"
$CollectionDirectory = $CollectionName
# This is used when executing commands remotely on targets, it prevents errors by removing spaces in collection name
$CollectionShortName = $CollectionName -replace ' ',''
$global:IncrementBar = 1
CollectionStartMessage

# Creates the collection specific directory that stores each host results
New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null


foreach ($TargetComputer in $global:ComputerList) {
    $Command = $($tuple.Item2)
    Invoke-WmiMethod -Class Win32_Process -Name Create -Computername $TargetComputer -ArgumentList "cmd /c tasklist /m /FO CSV > c:\$CollectionShortName-$TargetComputer.csv" | Out-Null
    # This deleay is introduced to allow the collection command to complete gathering data before it pulls back the data
    Start-Sleep -Seconds $SleepTime
    # Pulls back the data from the Target Computer
    Copy-Item -Path "\\$TargetComputer\c$\$CollectionShortName-$TargetComputer.csv" -Destination "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"
    Remove-Item -Path "\\$TargetComputer\c$\$CollectionShortName-$TargetComputer.csv"

    $DLLProcesses = (Import-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv") 
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"

    # Add PSComputerName header and host/ip name
    $DLLProcesses | Add-Member -MemberType NoteProperty "PSComputerName" -Value "$TargetComputer"
    $DLLProcesses | Select-Object "PSComputerName","Image Name","PID","Modules" | Export-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

    CollectionProgressStatus
}
CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"  
CollectionStopMessage


# ------------------------------------------------------------------------------------------------------------------------------------------------------------
# Driver - Signed Information
# ------------------------------------------------------------------------------------------------------------------------------------------------------------

# Executes all Get-WmiObject Commands
$CollectionName = "Drivers - Signed Information"
$CollectionDirectory = $CollectionName
# This is used when executing commands remotely on targets, it prevents errors by removing spaces in collection name
$CollectionShortName = $CollectionName -replace ' ',''
$global:IncrementBar = 1
CollectionStartMessage

# Creates the collection specific directory that stores each host results
New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

foreach ($TargetComputer in $global:ComputerList) {
    $Command = $($tuple.Item2)
    Invoke-WmiMethod -Class Win32_Process -Name Create -Computername $TargetComputer -ArgumentList "cmd /c driverquery /si /FO CSV > c:\$CollectionShortName-$TargetComputer.csv" | Out-Null
    # This deleay is introduced to allow the collection command to complete gathering data before it pulls back the data
    Start-Sleep -Seconds $SleepTime
    # Pulls back the data from the Target Computer
    Copy-Item -Path "\\$TargetComputer\c$\$CollectionShortName-$TargetComputer.csv" -Destination "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"
    Remove-Item -Path "\\$TargetComputer\c$\$CollectionShortName-$TargetComputer.csv"

    $DriverSignedInfo = (Import-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv") 
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"
    
    # Add PSComputerName header and host/ip name
    $DriverSignedInfo | Add-Member -MemberType NoteProperty "PSComputerName" -Value "$TargetComputer"
    $DriverSignedInfo | Select-Object PSComputerName, IsSigned, Manufacturer, DeviceName, InfName | Export-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation
             
    CollectionProgressStatus
}
CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"  
CollectionStopMessage


# ------------------------------------------------------------------------------------------------------------------------------------------------------------
# System Information
# ------------------------------------------------------------------------------------------------------------------------------------------------------------

$CollectionName = "System Information"
$CollectionDirectory = $CollectionName
$global:IncrementBar = 1
CollectionStartMessage

# Creates the collection specific directory that stores each host results
New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

foreach ($TargetComputer in $global:ComputerList) {
    Invoke-WmiMethod -Class Win32_Process -Name Create -ComputerName $TargetComputer -ArgumentList "cmd /c systeminfo /fo csv > c:\$TargetComputer-systeminfo.csv" | Out-Null
    
    # This deleay is introduced to allow the collection command to complete gathering data before it pulls back the data
    Start-Sleep -Seconds $SleepTime
    Copy-Item "\\$TargetComputer\c$\$TargetComputer-systeminfo.csv" "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory"
    Remove-Item "\\$TargetComputer\c$\$TargetComputer-systeminfo.csv"
    
    # Adds the addtional column header, PSComputerName, and target computer to each connection
    $SystemInfo = Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$TargetComputer-systeminfo.csv"
    $SystemInfo | ForEach-Object {
        if ($_ -match '"Host Name","OS Name"') {"PSComputerName," + "$_"}
        else {"$TargetComputer," + "$_"}
    } | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$TargetComputer-systeminfo-formated.csv"
    
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$TargetComputer-systeminfo.csv"
    CollectionProgressStatus
}
CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
CollectionStopMessage 
}


# ============================================================================================================================================================
# ============================================================================================================================================================
# Network Statistics - IPv4, IPv6, TCP, TCPv6, UDP, UDPv6, ICMP, ICMPv6
# ============================================================================================================================================================
# ============================================================================================================================================================

# The new object is configured as an arraylist for tuples to contain CollecitonName and Command
$NetworkStatisticsCommandList = New-Object System.Collections.ArrayList
$NetworkStatisticsCommandList.AddRange((
[Tuple]::Create(`
    'Network Statistics IP',
    'netstat -e -p ip'),
[Tuple]::Create(`
    'Network Statistics TCP',
    'netstat -e -p tcp'),
[Tuple]::Create(`
    'Network Statistics UDP',
    'netstat -e -p udp'),
[Tuple]::Create(`
    'Network Statistics ICMP',
    'netstat -e -p icmp'),
[Tuple]::Create(`
    'Network Statistics IPv6',
    'netstat -e -p ipv6'),
[Tuple]::Create(`
    'Network Statistics TCPv6',
    'netstat -e -p tcpv6'),
[Tuple]::Create(`
    'Network Statistics UDPv6',
    'netstat -e -p udpv6'),
[Tuple]::Create(`
    'Network Statistics ICMPv6',
    'netstat -e -p icmpv6')
))

# Executes all the User Account commands
foreach ($tuple in $NetworkStatisticsCommandList) {
    # This is the first part of the tuple that is primary used as the collections name. It is also the variable name used when providing the graphical update.
    $global:CollectionName = $($tuple.Item1)
    
    # This is used when executing commands remotely on targets, it prevents errors by removing spaces in collection name
    $global:CollectionShortName = $CollectionName -replace " ",""
    
    # This is used to create the directory name
    $global:CollectionDirectory = $CollectionName

    $ExtendedCollection = "Extended Collection"

    # Creates the collection specific directory that stores each host results
    New-Item -ItemType Directory "$PoShLocation\$ExtendedCollection\$CollectionDirectory" -Force | Out-Null
    $global:IncrementBar = 1
    CollectionStartMessage

    foreach ($TargetComputer in $global:ComputerList) {
        # Execute Commands to collect data from the targets
        $Command = $($tuple.Item2)
        Invoke-WmiMethod -Class Win32_Process -Name Create -ComputerName $TargetComputer -ArgumentList "cmd /c $Command > c:\$CollectionShortName-$TargetComputer.txt" | Out-Null

        Start-Sleep -Seconds $SleepTime

        # This copies the data from the target then removes the copy
        Copy-Item "\\$TargetComputer\c$\$global:CollectionShortName-$TargetComputer.txt" "$PoShLocation\$ExtendedCollection\$CollectionDirectory"
        Remove-Item "\\$TargetComputer\c$\$global:CollectionShortName-$TargetComputer.txt"
        
        # Processes collection to format it from txt to csv
        $Statistics = Get-Content "$PoShLocation\$ExtendedCollection\$CollectionDirectory\$CollectionShortName-$TargetComputer.txt" | Select-Object -skip 4 -First 6
                
        # This data is formated differently the the others for TCP and UDP as it as sent and recieve metrics in columns
        $StatisticsData = $Statistics -replace " {2,}","," -replace "^,|,$",""

        # Extracts the fields that become the file headers
        $FileHeader = ""
        foreach ($line in $StatisticsData) {$FileHeader += "$($($line -split ',')[0]) (Rx/Tx),"}
            
        # Extracts the fields that contain data
        $FileData = ""
        foreach ($line in $StatisticsData) {$FileData += "$($($line -split ',')[1])/$($($line -split ',')[2]),"}
        $ConvertedToCsv = ""
        $ConvertedToCsv += "PSComputerName,"  + $FileHeader -replace ",$","`r`n"
        $ConvertedToCsv += "$TargetComputer," + $FileData   -replace ",$",""
        $ConvertedToCsv | Out-File -FilePath "$PoShLocation\$ExtendedCollection\$CollectionDirectory\$CollectionName-$TargetComputer.csv"
                         
        CollectionProgressStatus
        }
    CompileCsvFiles "$PoShLocation\$ExtendedCollection\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
    CollectionStopMessage
}



# ============================================================================================================================================================
# ============================================================================================================================================================
# Unique Findings
# ============================================================================================================================================================
# ============================================================================================================================================================

# Creates the directory for Unique Findings
$UniqueFindings = "Unique Findings"
New-Item -ItemType Directory "$PoShLocation\$UniqueFindings" -Force | Out-Null 

function UniqueData ([string]$CollectionToUnique, [string]$PropertyToUniqueOn) {    
    # unique process file paths running on systems
    $CollectionName = $CollectionToUnique
    $Files = Get-ChildItem "$PoShLocation\$CollectedResultsUncompiled\$CollectionName\$CollectionName*.csv"

    $AllData = @()
    Foreach ($file in $Files) {$AllData += Import-Csv ($file).FullName}
    $UniqueData = $AllData | Sort-Object -Unique -Property $PropertyToUniqueOn 
    
    # '-ErrorAction 0' Older versions of powershell have issues counting 0 or 1 -- this accounts for it
    # 'Where-Object {$_.PSComputerName -ne ""}' removes any entires where there is no computer name, typically bank lines
    $UniqueCount = @($UniqueData | Where-Object {$_.PSComputerName -ne ""} -ErrorAction 0).count
        
    $UniqueData | Sort-Object -Property $PropertyToUniqueOn | Export-Csv "$PoShLocation\$UniqueFindings\$CollectionName - Uniqued by $PropertyToUniqueOn ($UniqueCount).csv" -NoTypeInformation

}

# Unique Data "<Uncompiled Directory Collection Name>" "<Property used to Unique>" "<Properties to Sort By>" 
# Example: UniqueData 'Processes (Improved with Hashes and Parent Process Names)' 'Pathname' 'PSComputerName, Name'
UniqueData 'Autoruns - Startup Commands' 'Command'
#UniqueData 'BIOS''--'
#UniqueData 'Computer Information''--'
UniqueData 'Dates - Install, Boot, and Localtime' 'LocalDateTime'
UniqueData 'Disk Information' 'ProviderName' 
UniqueData 'DLLs Loaded by Processes' 'Modules'
UniqueData 'Drivers - Detailed' 'DisplayName'
UniqueData 'Drivers - Detailed' 'PathName'
#UniqueData 'Drivers - Signed Information''--'
UniqueData 'Drivers - Valid Signatures' 'Path'
UniqueData 'Environmental Variables' 'VariableValue'
UniqueData 'Firewall Rules' '"Rule Name"'
UniqueData 'Firewall Rules' 'LocalIP'
UniqueData 'Firewall Rules' 'LocalPort'
UniqueData 'Firewall Rules' 'RemoteIP'
UniqueData 'Firewall Rules' 'RemotePort'
UniqueData 'Group Information' 'Name'
#UniqueData 'Logged-On User Information''--'
#UniqueData 'Logon-Information''--'
UniqueData 'Mapped Drives' 'ProviderName'
#UniqueData 'Memory (RAM) Capacity Information''--'
#UniqueData 'Memory (RAM) Physical Information''--'
#UniqueData 'Memory (RAM) Utilization''--'
#UniqueData 'Memory Performance Monitoring Data''--'
UniqueData 'Network Connections (netstat tcp)' '"Executed Process"'
UniqueData 'Network Connections (netstat udp)' '"Executed Process"'
UniqueData 'Network Connections (netstat tcp)' '"Foreign Address"'
UniqueData 'Network Connections (netstat udp)' '"Foreign Address"'
UniqueData 'Network - Active Connections in a Windows-Based Environment' 'RemoteName'
UniqueData 'Network Settings' 'DNSDomainSuffixSearchOrder'
UniqueData 'Plug and Play Devices' 'Manufacturer' 
UniqueData 'Plug and Play Devices' 'Description'
UniqueData 'Plug and Play Devices' 'HardwareID'
UniqueData 'Printers' 'Name'
UniqueData 'Processes (Improved with Hashes and Parent Process Names)' 'Pathname'
UniqueData 'Processes (Improved with Hashes and Parent Process Names)' 'Hash'
UniqueData 'Processes (Improved with Hashes and Parent Process Names)' 'CommandLine'
UniqueData 'Processes (Improved with Hashes and Parent Process Names)' 'ParentProcessName'
UniqueData 'Processes' 'Name'
UniqueData 'Processes' 'Path'
#UniqueData 'Proxy Rules''--'
UniqueData 'Scheduled Tasks (schtasks)' 'TaskName'
UniqueData 'Scheduled Tasks (schtasks)' '"Task To Run"'
#UniqueData 'Security Patches''--'
UniqueData 'Services' 'PathName'
UniqueData 'Services' 'Name'
UniqueData 'Shares' 'Path'
UniqueData 'Software Installed' 'Name'
UniqueData 'Software Installed' 'Vendor'
UniqueData 'Software Installed' 'PackageName'
UniqueData 'System Information' '"OS Name"'
UniqueData 'System Information' '"OS Version"'
UniqueData 'System Information' '"System Manufacturer"'
UniqueData 'System Information' '"Hotfix(s)"'
UniqueData 'USB Controller Device Connections' 'Antecedent'
UniqueData 'USB Controller Device Connections' 'Dependent'
#UniqueData 'User Information''--'
#UniqueData '' ''



# ============================================================================================================================================================
# ============================================================================================================================================================
# Audit Event Log Queries - Command Execution
# ============================================================================================================================================================
# ============================================================================================================================================================

if ($AuditEventLogsChoice -eq "True") {

# This will add to the command count to update the progress bar
$global:NumberOfSections += $AuditEventLogsCommands.Count

# Creates a directory to store the individual collections
$CollectionDirectory = "Audit Event Logs (Past $LimitDaysOfEventLogsCollectToChoice days, Limited to $LimitNumberOfEventLogsCollectToChoice Logs)"
New-Item -ItemType Directory -Path "$PoShLocation\$CollectionDirectory" -Force | Out-Null

# Executes all Get-WmiObject Commands
foreach ($tuple in $AuditEventLogsCommands) {
    $CollectionName = "Event Logs Audit (Past $LimitDaysOfEventLogsCollectToChoice Days) $($tuple.Item1)"
    $CollectionFileName = $($tuple.Item1)
    $AuditEventLogsDirectory = $($tuple.Item1)
    $global:IncrementBar = 1
    CollectionStartMessage

    # Creates the collection specific directory that stores each host results
    New-Item -ItemType Directory -Path "$PoShLocation\$CollectionDirectory\$AuditEventLogsDirectory" -Force | Out-Null
    
    foreach ($TargetComputer in $global:ComputerList) {
        $Command = $($tuple.Item2)
        Invoke-Expression $Command | Export-CSV "$PoShLocation\$CollectionDirectory\$AuditEventLogsDirectory\$CollectionFileName - $TargetComputer.csv" -NoTypeInformation
        CollectionProgressStatus
    }
    CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
    CollectionStopMessage
} 
}



# ============================================================================================================================================================
# ============================================================================================================================================================
# Calculate Total Script Runtime
# ============================================================================================================================================================
# ============================================================================================================================================================

# Outputs the message that the collection has started
Write-Host "Completion: " -ForegroundColor Green -NoNewline
$CompletionMessage = "PoSh-ACME Has Finished Collecting Data!"
Write-Host $CompletionMessage -ForegroundColor White -NoNewline   

# Gets the time at which the collection is finished
Set-Variable -Name ScriptTimerStop -Value $(Get-Date) -Force
$CollectionTime = New-TimeSpan -Start $ScriptTimerStart -End $ScriptTimerStop
    
# Outputs the message that the collection has completed and how long it took
$padding = $global:ColumnPadding - ($CompletionMessage.Length + "Completion: ".Length)
Write-Host "Completed: ".PadLeft($padding) -ForegroundColor Green -NoNewline
Write-Host "$($CollectionTime.ToString())" -ForegroundColor White

