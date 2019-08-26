<#
### if ((Show-Command -PassThru -ErrorPopup).split('-')[0] -ne 'Get') {Write-Host "Limited to only using cmdlets with Get verbs!"}
### Show-Command -PassThru -ErrorPopup
### These commands use the ErrorPopup parameter of the Show-Command cmdlet to save the output of a command in a variable.

#    # There is an integrated tool in Windows Servers 2008R2 and newer, that allows capturing the network activity without installing anything.
#    cmd /c netsh trace start capture=yes Ethernet.Type=IPv4 IPv4.Address=127.0.0.1 filemode=single maxSize=250 overwrite=yes tracefile=c:\temp\nettrace_test.etl
#    #default save location: “traceFile=%LOCALAPPDATA%\Temp\NetTraces\NetTrace.etl”
#    # e.g. Protocol=6
#    # e.g. Protocol=!(TCP,UDP)
#    # e.g. Protocol=(4-10)    
#    Start-Sleep -Seconds 30
#    cmd /c netsh trace stop

    .SYNOPSIS
     _______             ____  __               _____     ____  ___    __  _____ 
     |   _  \           /  __||  |             /  _  \   / ___\ |  \  /  | | ___|
     |  |_)  | _____   |  (   |  |___   ____  |  (_)  | / /     |   \/   | | |_  
     |   ___/ /  _  \   \  \  |   _  \ |____| |   _   || |      | |\  /| | |  _| 
     |  |    |  (_)  | __)  | |  | |  |       |  | |  | \ \____ | | \/ | | | |__ 
     |__|     \_____/ |____/  |__| |__|       |__| |__|  \____/ |_|    |_| |____|
     ============================================================================
     PowerShell-Analyst's Collection Made Easy (ACME) for Security Professionals.
     ACME: The point at which something is the Best, Perfect, or Most Successful!
     ============================================================================
     File Name      : PoSh-ACME.ps1
     Version        : v.3.4 Beta

     Author         : high101bro
     Email          : high101bro@gmail.com
     Website        : https://github.com/high101bro/PoSH-ACME

     Requirements   : PowerShell v3 or Higher
                    : WinRM   HTTP  - TCP/5985
                              HTTPS - TCP/5986
                    : DCOM    RPC   - TCP/135 and dynamic ports, typically:
                                      TCP 49152-65535 (Windows Vista, Server 2008 and above)
                                      TCP 1024 -65535 (Windows NT4, Windows 2000, Windows 2003)
     Optional       : Can run standalone, but works best with the Resources folder!
                    : PsExec.exe, Procmon.exe, Autoruns.exe, Sysmon.exe
     Updated        :  3 Jun 19
     Created        : 21 Aug 18

    PoSh-ACME is a tool that allows you to run any number of queries against any number
    of hosts. The queries primarily consist of one liner commands, but several are made
    of scripts that allows for obtaining data on older systems like Server 2008 R2 where
    newer commands are not supported. PoSh-ACME consists of queries speicific for hosts
    and servers, workgroups and domains, registry and Event Logs. It provides a simple
    way to view data in CSV format using PowerShell's built in Out-GridView, as well as
    displays the data in various chart formats. Other add-on features includes a spread
    of external applications like various Sysinternals tools, and basic reference info
    for quick use when not on the web.

    As the name indicates, PoSh-ACME is writen in PowerShell. The GUI utilizes the .net 
    frame work to access Windows built in WinForms.

    If at all possible, update to the current version of PowerShell, but
        Start-Job requires PowerShell v3.0
        PowerShell Charts requires PowerShell v3.0
        Get-FileHash requires PowerShell v3.0
                        
    .EXAMPLE
        This will run PoSh-ACME.ps1 and provide prompts that will tailor your collection.

             PowerShell.exe -ExecutionPolicy ByPass -NoProfile -File .\PoSh-ACME.ps1

    .Link
        https://github.com/high101bro/PoSH-ACME

    .NOTES  
        Remember this is a script, not a program. So when it's conducting its queries the 
        GUI will be unresponsive to user interaction even though you are able to view 
        status and timer updates.

        In order to run the script:
        - Downloaded from the internet
            You may have to use the Unblock-File cmdlet to be able to run the script.
              - For addtional info on:Get-Help Unblock-File
            How to Unblock the file:
              - Unblock-File -Path .PoSh-ACME.ps1

        - Update Execution Policy locally
            Open a PowerShell terminal with Administrator privledges
              - Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process
              - Get-ExecutionPolicy -List

        - Update Execution Policy via GPO
            Open the GPO for editing. In the GPO editor, select:
              - Computer Configuration > Policies > Administrative Templates > Windows Components > Windows PowerShell
              - Right-click "Turn on script execution", then select "Edit"
              - In the winodws that appears, click on "Enabled" radio button
              - Under "Execution Policy", select "Allow All Scripts"
              - Click on "Ok", then close the GPO Editor
              - Push out GPO Updates, or on the computer's powershell/cmd terminal, type in `"gpupdate /force"
#>
param (
    #Cmdlet Parameter Options
    [switch]$DisableToolTip,
    [switch]$AudibleCompletionMessage,
    [int]$JobTimeOutSeconds = 600
)

#============================================================================================================================================================
# Check if script is running as Administrator
#============================================================================================================================================================
# Not Using the following, but rather the script below
# #Requires -RunAsAdministrator

# Check if the script is running with Administrator Privlieges, if not it will attempt to re-run and prompt for credentials
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic")
    $verify = [Microsoft.VisualBasic.Interaction]::MsgBox(`
        "Attention Under-Privileged User!`n   $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)`n`nThe remote commands executed to collect data require elevated credentials. Select 'Yes' to attempt to run this script with elevated privileges; select 'No' to run this script with the current user's privileges; or select 'Cancel' and re-run this script with an Administrator terminal.",`
        'YesNoCancel,Question',`
        "PoSh-ACME")
    switch ($verify) {
    'Yes'{
        $arguments = "& '" + $myinvocation.mycommand.definition + "'"
        #Start-Process PowerShell.exe -Verb runAs -ArgumentList $arguments -WindowStyle Hidden
        Start-Process PowerShell.exe -Verb runAs -ArgumentList $arguments
        exit
    }
    'No'     {continue}
    'Cancel' {exit}
    }
}

#============================================================================================================================================================
# Variables
#============================================================================================================================================================

# Universally sets the ErrorActionPreference to Silently Continue
$ErrorActionPreference = "SilentlyContinue"
   
# Location PoSh-ACME will save files
$PoShHome = Split-Path -parent $MyInvocation.MyCommand.Definition

    # Files
    $LogFile                                  = "$PoShHome\Log File.txt"
    $IPListFile                               = "$PoShHome\iplist.txt"
    $CustomPortsToScan                        = "$PoShHome\Custom Ports To Scan.txt"
    $CustomWinRMCommands                      = "$PoShHome\Custom WinRM Commands.csv"
                                                    
    $ComputerListTreeViewFileAutoSave         = "$PoShHome\Computer List TreeView (Auto-Save).csv"
    $ComputerListTreeViewFileSave             = "$PoShHome\Computer List TreeView (Saved).csv"

    $OpNotesFile                              = "$PoShHome\OpNotes.txt"
    $OpNotesWriteOnlyFile                     = "$PoShHome\OpNotes (Write Only).txt"
    
    # Directory where auto saved chart images are saved
    $AutosavedChartsDirectory                 = "$PoShHome\Autosaved Charts"
        if (-not $(Test-Path -Path $AutosavedChartsDirectory)) {New-Item -Type Directory -Path $AutosavedChartsDirectory -Force}

    # Name of Collected Data Directory
    $CollectedDataDirectory                   = "$PoShHome\Collected Data"
        # Location of separate queries
        $CollectedDataTimeStampDirectory      = "$CollectedDataDirectory\$((Get-Date).ToString('yyyy-MM-dd @ HHmm ss'))"
        # Location of Uncompiled Results
        $IndividualHostResults                = "$CollectedDataTimeStampDirectory\Individual Host Results"
    
    # Location of Resources directory
    $ResourcesDirectory                       = "$PoShHome\Resources"
        # Location of Host Commands Notes
        $CommandsHostDirectoryNotes           = "$ResourcesDirectory\Commands - Host"

        # Location of Host Commands Scripts
        $CommandsHostDirectoryScripts         = "$ResourcesDirectory\Commands - Host\Scripts"

        # Location of Event Logs Commands directory
        $CommandsEventLogsDirectory           = "$ResourcesDirectory\Commands - Event Logs"
            # CSV list of Event IDs numbers, names, and description
            $EventIDsFile                         = "$CommandsEventLogsDirectory\Event IDs.csv"
            # CSV file from Microsoft detailing Event IDs to Monitor
            $EventLogsWindowITProCenter           = "$CommandsEventLogsDirectory\Individual Selection\Event Logs to Monitor - Window IT Pro Center.csv"

        # Location of Active Directory Commands directory
        $CommandsActiveDirectory              = "$ResourcesDirectory\Commands - Active Directory"

        # Location of External Programs directory
        $ExternalPrograms                     = "$ResourcesDirectory\External Programs"
        $PsExecPath                           = "$ExternalPrograms\PsExec.exe"

        # CSV list of Event IDs numbers, names, and description
        $TagAutoListFile                      = "$ResourcesDirectory\Tags - Auto Populate.txt"

#=======================================================================================================================
# Checks if files exists and imports them if they do, otherwise it creates a demo file that is customizable by the user
# This allows persistence of various user files that will be utlized upon the launch of PoSh-ACME
#=======================================================================================================================

# Check for Custom WinRM Comamnds
if ( Test-Path -Path $CustomWinRMCommands ) { $script:ImportCustomCommands = Import-Csv -Path $CustomWinRMCommands }
else {
    $script:AllExampleCommands = @()

    $CollectionName = 'Processes (Example)'
    $ExampleCommand = New-Object PSObject -Property @{ 
        Name                 = $CollectionName 
        Type                 = 'System, Hunt'
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = 'Get-Process'
        Command_WMI          = 'Get-WmiObject -Class Win32_Process'
        Command_WinRS_WMIC   = 'winrs wmic process list brief'
        Command_WinRS_CMD    = 'winrs tasklist /V /FO CSV'
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = 'Invoke-Command -ScriptBlock { Get-Process }'
        Command_WinRM_WMI    = 'Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_Process }'
        Command_WinRM_CMD    = 'Invoke-Command -ScriptBlock { cmd /c tasklist /V /FO CSV }'
        Properties_PoSh      = '@{name="PSComputerName";expression={$TargetComputer}}, Name, ID, Path, StartTime, @{name="WorkingSetSize";expression={$_.WS}} , Handle, HandleCount, @{Name="ThreadCount";expression={($_.Threads).count}}, Company, Product, Description'
        Properties_WMI       = 'PSComputerName, Name, ProcessID, ParentProcessID, Path, WorkingSetSize, Handle, HandleCount, ThreadCount, CreationDate, Description'
        Message              = 'Gets a list of running processes.'
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }
    $script:AllExampleCommands += $ExampleCommand

    ### Example of older method
    $CollectionName = 'Services (Example)'
    $ExampleCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $ExampleCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value 'System'
    $ExampleCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value 'cmd /c sc '
    $ExampleCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value 'query state=all'
    $ExampleCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value 'Get-Service'
    $ExampleCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $ExampleCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value 'Invoke-Command -ScriptBlock { Get-Service }'
    $ExampleCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value 'Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_Service }'
    $ExampleCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value 'Invoke-Command -ScriptBlock { cmd /c sc query state=all }'
    $ExampleCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Get-WmiObject -Class Win32_Service'
    $ExampleCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $ExampleCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $ExampleCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '@{name="PSComputerName";expression={$TargetComputer}}, Status, Name, DisplayName, RequiredServices, StartType, CanPauseAndContinue, CanShutdown, CanStop, ServiceHandle' 
    $ExampleCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value 'PSComputerName, State, Name, ProcessID, Description, PathName, Started, StartMode, StartName' 
    $ExampleCommand | Add-Member -MemberType NoteProperty -Name Message              -Value 'Gets information on services.'
    $ExampleCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $ExampleCommand | Add-Member -MemberType NoteProperty -Name ExportFileName       -Value "$CollectionName"
    $script:AllExampleCommands += $ExampleCommand

    $script:AllExampleCommands | Export-Csv -Path $CustomWinRMCommands -NoTypeInformation
}

# Logs what account ran the script and when
$LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - PoSh-ACME executed by: $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"
$LogMessage | Add-Content -Path $LogFile

# The Font Used throughout PoSh-ACME GUI
$Font              = "Courier"

# Number of jobs simultaneously when collecting data
$ThrottleLimit     = 32

# Clears out Computer List variable
$ComputerList      = ""

# Credentials will be stored in this variable
$script:Credential = ""

#============================================================================================================================================================
# Function Name 'ListComputers' - Takes entered domain and lists all computers
#============================================================================================================================================================

Function ListComputers([string]$Choice,[string]$Script:Domain) {
    $DN          = ""
    $Response    = ""
    $DNSName     = ""
    $DNSArray    = ""
    $objSearcher = ""
    $colProplist = ""
    $objComputer = ""
    $objResults  = ""
    $colResults  = ""
    $Computer    = ""
    $comp        = ""
    New-Item -type file -force "$Script:Folder_Path\Computer_List$Script:curDate.txt" | Out-Null
    $Script:Compute = "$Script:Folder_Path\Computer_List$Script:curDate.txt"
    $strCategory = "(ObjectCategory=Computer)"
       
    If($Choice -eq "Auto" -or $Choice -eq "" ) {
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
	elseif($Choice -eq "Manual") {
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
        #Write-Host "You did not supply a correct response, Please select a response." -foregroundColor Red
        . ListComputers }
}


#============================================================================================================================================================
# Function Name 'ListTextFile' - Enumerates Computer Names in a text file
# Create a text file and enter the names of each computer. One computer
# name per line. Supply the path to the text file when prompted.
#============================================================================================================================================================
Function ListTextFile {
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
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Your file was empty. You must select a file with at least one computer in it.")        
        $file_Dialog.Close()
        #. ListTextFile 
        }
    Else {
        $Script:ComputerList = @()
        ForEach ($Comp in $Comps) {
            If ($Comp -match "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/\d{1,2}") {
                $Temp = $Comp.Split("/")
                $IP = $Temp[0]
                $Mask = $Temp[1]
                . Get-Subnet-Range $IP $Mask
                $Script:ComputerList += $Script:IPList
            }
            Else {
                $Script:ComputerList += $Comp
            }
        }
    }
}

# Lists all IPs in a subnet
# Ex: Get-Subnet-Range -IP 192.168.1.0 -Netmask /24
# Ex: Get-Subnet-Range -IP 192.168.1.128 -Netmask 255.255.255.128
Function Get-Subnet-Range {
    Param(
        [string]
        $IP,
        [string]
        $netmask
    )  
    Begin {
        $IPs = New-Object System.Collections.ArrayList

        # Get the network address of a given lan segment
        # Ex: Get-NetworkAddress -IP 192.168.1.36 -mask 255.255.255.0
        Function Get-NetworkAddress {
            Param (
                [string]$IP,
                [string]$Mask,
                [switch]$Binary
            )
            Begin { $NetAdd = $null }
            Process {
                $BinaryIP = ConvertTo-BinaryIP $IP
                $BinaryMask = ConvertTo-BinaryIP $Mask
                0..34 | %{
                    $IPBit = $BinaryIP.Substring($_,1)
                    $MaskBit = $BinaryMask.Substring($_,1)
                    IF ($IPBit -eq '1' -and $MaskBit -eq '1') {
                        $NetAdd = $NetAdd + "1"
                    } 
                    elseif ($IPBit -eq ".") { $NetAdd = $NetAdd +'.'} 
                    else { $NetAdd = $NetAdd + "0" }
                }
                if ($Binary) { return $NetAdd } 
                else { return ConvertFrom-BinaryIP $NetAdd }
            }
        }

        # Convert an IP address to binary
        # Ex: ConvertTo-BinaryIP -IP 192.168.1.1
        Function ConvertTo-BinaryIP {
            Param ( [string]$IP )
            Process {
                $out = @()
                Foreach ($octet in $IP.split('.')) {
                    $strout = $null
                    0..7|% {
                        if (($octet - [math]::pow(2,(7-$_)))-ge 0) {
                            $octet = $octet - [math]::pow(2,(7-$_))
                            [string]$strout = $strout + "1"
                        } 
                        else { [string]$strout = $strout + "0" }  
                    }
                    $out += $strout
                }
                return [string]::join('.',$out)
            }
        }
 
        # Convert from Binary to an IP address
        # Convertfrom-BinaryIP -IP 11000000.10101000.00000001.00000001
        Function ConvertFrom-BinaryIP {
            Param ( [string]$IP )
            Process {
                $out = @()
                Foreach ($octet in $IP.split('.')) {
                    $strout = 0
                    0..7|% {
                        $bit = $octet.Substring(($_),1)
                        IF ($bit -eq 1) { $strout = $strout + [math]::pow(2,(7-$_)) }
                    }
                    $out += $strout
                }
                return [string]::join('.',$out)
            }
        }

        # Convert from a netmask to the masklength
        # Ex: ConvertTo-MaskLength -Mask 255.255.255.0
        Function ConvertTo-MaskLength {
            Param ( [string]$mask )
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
 
        # Convert from masklength to a netmask
        # Ex: ConvertFrom-MaskLength -Mask /24
        # Ex: ConvertFrom-MaskLength -Mask 24
        Function ConvertFrom-MaskLength {
            Param ( [int]$mask )
            Process {
                $out = @()
                [int]$wholeOctet = ($mask - ($mask % 8))/8
                if ($wholeOctet -gt 0) { 1..$($wholeOctet) | % { $out += "255" } }
                $subnet = ($mask - ($wholeOctet * 8))
                if ($subnet -gt 0) {
                    $octet = 0
                    0..($subnet - 1) | % { $octet = $octet + [math]::pow(2,(7-$_)) }
                    $out += $octet
                }
                for ($i=$out.count;$i -lt 4; $I++) { $out += 0 }
                return [string]::join('.',$out)
            }
        }

        # Given an Ip and subnet, return every IP in that lan segment
        # Ex: Get-IPRange -IP 192.168.1.36 -Mask 255.255.255.0
        # Ex: Get-IPRange -IP 192.168.5.55 -Mask /23
        Function Get-IPRange {
            Param (
                [string]$IP,
                [string]$netmask
            )
            Process {
                iF ($netMask.length -le 3) {
                    $masklength = $netmask.replace('/','')
                    $Subnet = ConvertFrom-MaskLength $masklength
                } 
                else {
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
                                    } 
                                    else {
                                        $SecondOctet++
                                        $ThirdOctet = 0
                                    }
                                } 
                                else {
                                    $FourthOctet = 0
                                    $ThirdOctet++
                                }  
                            } 
                            else {
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
                                } 
                                else {
                                    $SecondOctet++
                                    $ThirdOctet = 0
                                }
                            } 
                            else {
                                $FourthOctet = 0
                                $ThirdOctet++
                            }  
                        } 
                        else {
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
        # Get every ip in scope
        Get-IPRange $IP $netmask | ForEach-Object { [void]$IPs.Add($_) }
        $Script:IPList = $IPs
    }
}

# Enumerates Computer from user input
Function SingleEntry {
    $Comp = $SingleHostIPTextBox.Text
    If ($Comp -eq $Null) { . SingleEntry } 
    ElseIf ($Comp -match "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/\d{1,2}") {
        $Temp = $Comp.Split("/")
        $IP = $Temp[0]
        $Mask = $Temp[1]
        . Get-Subnet-Range $IP $Mask
        $Script:ComputerList = $Script:IPList
    }
    Else{ $Script:ComputerList = $Comp}
}

# Used with the Listbox features to select one host from a list
Function SelectListBoxEntry {
    $Comp = $ComputerListBox.SelectedItems
    If ($Comp -eq $Null) { . SelectListBoxEntry } 
    ElseIf ($Comp -match "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/\d{1,2}") {
        $Temp = $Comp.Split("/")
        $IP = $Temp[0]
        $Mask = $Temp[1]
        . Get-Subnet-Range $IP $Mask
        $Script:ComputerList = $Script:IPList
    }
    Else { $Script:ComputerList = $Comp}
}

#============================================================================================================================================================
# Create Directory and Files
#============================================================================================================================================================
New-Item -ItemType Directory -Path "$PoShHome" -Force | Out-Null 

#============================================================================================================================================================
# PoSh-ACME Form
#============================================================================================================================================================

# Generates the GUI and contains the majority of the script
function PoSh-ACME_GUI {
    [reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
    [reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null

$OnLoadForm_StateCorrection= {
    # Correct the initial state of the form to prevent the .Net maximized form issue
    $PoShACME.WindowState = $InitialFormWindowState
}

#============================================================================================================================================================
# This is the overall window for PoSh-ACME
#============================================================================================================================================================
# Varables for overall windows
$PoShACMERightPosition = 10
$PoShACMEDownPosition  = 10
$PoShACMEBoxWidth      = 1223
$PoShACMEBoxHeight     = 635

$PoShACME               = New-Object System.Windows.Forms.Form
$PoShACME.Text          = "PoSh-ACME   [$([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)]"
$PoShACME.Name          = "PoSh-ACME"
$PoShACME.Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$ResourcesDirectory\favicon.ico")
$PoShACME.Location      = New-Object System.Drawing.Size($PoShACMERightPosition,$PoShACMEDownPosition) 
$PoShACME.Size          = New-Object System.Drawing.Size($PoShACMEBoxWidth,$PoShACMEBoxHeight)
$PoShACME.StartPosition = "CenterScreen"
$PoShACME.Top           = $true
$PoShACME.BackColor     = "fff5ff"
$PoShACME.FormBorderStyle =  "fixed3d"
#$InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState


##############################################################################################################################################################
##############################################################################################################################################################
##
## Section 1 Tab Control
##
##############################################################################################################################################################
##############################################################################################################################################################

# Varables
$Section1TabControlRightPosition  = 5
$Section1TabControlDownPosition   = 5
$Section1TabControlBoxWidth       = 460
$Section1TabControlBoxHeight      = 590

$Section1TabControl = New-Object System.Windows.Forms.TabControl -Property @{
    Name     = "Main Tab Window"
    Location = @{ X = $Section1TabControlRightPosition
                  Y = $Section1TabControlDownPosition
                }
    Size     = @{ Width  = $Section1TabControlBoxWidth
                  Height = $Section1TabControlBoxHeight
                }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    SelectedIndex = 0
    ShowToolTips  = $True
}
$PoShACME.Controls.Add($Section1TabControl)

#######################################################################################################################################################################
##       ##
##  TAB  ## Collections
##       ##
#######################################################################################################################################################################

$Section1CollectionsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text                    = "Collections"
    Name                    = "Collections Tab"
    UseVisualStyleBackColor = $True
    Font                    = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$Section1TabControl.Controls.Add($Section1CollectionsTab)

# Variable Sizes
$TabRightPosition     = 3
$TabhDownPosition     = 3
$TabAreaWidth         = 446
$TabAreaHeight        = 557

$TextBoxRightPosition = -2 
$TextBoxDownPosition  = -2
$TextBoxWidth         = 442
$TextBoxHeight        = 536

#============================================================================================================================================================
# Functions used for commands/queries
#============================================================================================================================================================

function Conduct-PreCommandCheck {
    param(
        $CollectedDataTimeStampDirectory, 
        $IndividualHostResults, 
        $CollectionName, 
        $TargetComputer
    )
    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    # Removes the individual results
    Remove-Item -Path "$($IndividualHostResults)\$($CollectionName)\$($CollectionName)-$($TargetComputer).csv" -Force -ErrorAction SilentlyContinue
    # Removes the compiled results
    Remove-Item -Path "$($CollectedDataTimeStampDirectory)\$($CollectionName).csv" -Force -ErrorAction SilentlyContinue
    # Creates a directory to save compiled results
    New-Item -ItemType Directory -Path "$($IndividualHostResults)\$($CollectionName)" -Force -ErrorAction SilentlyContinue
}

function Create-LogEntry {
    param($TargetComputer,$CollectionName,$LogFile)
    # Creates a log entry to an external file
    $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  $TargetComputer`: $CollectionName"
    $LogMessage | Add-Content -Path $LogFile
}

#####################################################################################################################################
##
## Section 1 Collections TabControl
##
#####################################################################################################################################

# The TabControl controls the tabs within it
$Section1CollectionsTabControl               = New-Object System.Windows.Forms.TabControl -Property @{
    Name          = "Collections TabControl"
    Location = @{ X = $TabRightPosition
                  Y = $TabhDownPosition
                }
    Size     = @{ Width  = $TabAreaWidth
                  Height = $TabAreaHeight
                }
    ShowToolTips  = $True
    SelectedIndex = 0
    Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$Section1CollectionsTab.Controls.Add($Section1CollectionsTabControl)

#######################################################################################################################################################################
##           ##
##  SUB-TAB  ## Queries
##           ##
#######################################################################################################################################################################

# Varables for positioning checkboxes
$QueriesRightPosition     = 5
$QueriesDownPositionStart = 10
$QueriesDownPosition      = 10
$QueriesDownPositionShift = 25
$QueriesBoxWidth          = 410
$QueriesBoxHeight         = 25

$Section1CommandsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text     = "Queries"
    Location = @{ X = $Column1RightPosition
                  Y = $Column1DownPosition
                }
    Size     = @{ Width  = $Column1BoxWidth
                  Height = $Column1BoxHeight
                }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    UseVisualStyleBackColor = $True
}
$Section1CollectionsTabControl.Controls.Add($Section1CommandsTab)


#==========================================================================================================
#     ______          __            _       __     ______                                          __    
#    / ____/___  ____/ /___  ____  (_)___  / /_   / ____/___  ____ ___  ____ ___  ____ _____  ____/ /____
#   / __/ / __ \/ __  / __ \/ __ \/ / __ \/ __/  / /   / __ \/ __ `__ \/ __ `__ \/ __ `/ __ \/ __  / ___/
#  / /___/ / / / /_/ / /_/ / /_/ / / / / / /_   / /___/ /_/ / / / / / / / / / / / /_/ / / / / /_/ (__  ) 
# /_____/_/ /_/\__,_/ .___/\____/_/_/ /_/\__/   \____/\____/_/ /_/ /_/_/ /_/ /_/\__,_/_/ /_/\__,_/____/  
#
#==========================================================================================================

$script:AllEndpointCommands = @()

    # Old method of creating an all encompassing command Object
    $CollectionName = 'Accounts (Local Users)'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name = $CollectionName
        Type                 = "User, Hunt" 
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = "Get-WmiObject -Class Win32_UserAccount -Filter `"LocalAccount='True'`""
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { Get-LocalUser }"
        Command_WinRM_WMI    = "Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_UserAccount -Filter `"LocalAccount='True'`" }"
        Command_WinRM_CMD    = "Invoke-Command -ScriptBlock { cmd /c net user }"
        Command_WinRS_WMIC   = "winrs wmic useraccount where localaccount=true list brief"
        Command_WinRS_CMD    = "winrs net user"
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, Name, Enabled, SID, LastLogon, AccountExpires, PasswordRequired, UserMayChangePassword, PasswordExpires, PasswordLastSet, PasswordChangeableDate, Description, FullName' 
        Properties_WMI       = 'PSComputerName, Name, Disabled, AccountType, Lockout, PasswordChangeable, PasswordRequired, SID, SIDType, LocalAccount, Domain, Caption, Description' 
        Message              = 'Gets default built-in user accounts, local user accounts that were created, and local accounts that were connected to Microsoft accounts.'
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'Accounts (Local Administrators)'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "User, Hunt" 
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { Get-LocalGroupMember -Group administrators }"
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = "Invoke-Command -ScriptBlock { cmd /c net localgroup administrators }"
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = "winrs net localgroup administrators"
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}},Name, SID, ObjectClass, PrincipalSource'
        Properties_WMI       = 'PSComputerName, *'
        Message              = 'Gets default built-in user accounts, local user accounts that were created, and local accounts that were connected to Microsoft accounts.'
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }
    
    $CollectionName   = 'Anti Virus Product'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "System" 
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = 'Get-WmiObject -Namespace root\SecurityCenter2 -Class AntivirusProduct'
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = 'Invoke-Command -ScriptBlock { Get-WmiObject -Namespace root\SecurityCenter2 -Class AntivirusProduct }'
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, DisplayName, pathToSignedReportingExe' 
        Properties_WMI       = 'PSComputerName, DisplayName, pathToSignedReportingExe'
        Message              = $null
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName   = 'ARP Cache'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Network" 
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null #'Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "cmd /c arp -a > c:\results.txt"'
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { Get-NetNeighbor }"
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = 'Invoke-Command -ScriptBlock { cmd /c arp -a }'
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = "winrs arp -a"
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, State, IPAddress, LinkLayerAddress, InterfaceAlias, InterfaceIndex' 
        Properties_WMI       = "PSComputerName, State, IPAddress, LinkLayerAddress, PolicyStore" 
        Message              = 'Gets IP addresses and link-layer addresses from ARP/neighbor cache entries.'
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }
    
    $CollectionName = 'BIOS Info'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Hardware" 
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = 'Get-WmiObject -Class Win32_BIOS'
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = 'Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_BIOS }'
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = "winrs wmic bios list brief"
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *' 
        Properties_WMI       = 'PSComputerName, SMBIOSBIOSVersion, Name, Manufacturer, SerialNumber, Version, Description, ReleaseDate, InstallDate' 
        Message              = "Gets the basic input/output services (BIOS) that are installed."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'Date Info'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "System" 
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = 'Get-WmiObject -Class Win32_OperatingSystem'
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { Get-Date }"
        Command_WinRM_WMI    = 'Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_OperatingSystem }'
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = "winrs date"
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, DateTime' 
        Properties_WMI       = 'PSComputerName, @{n="InstallDateFormatted";e={$_.ConvertToDateTime($_.InstallDate)}},@{n="LastBootupTimeFormatted";e={$_.ConvertToDateTime($_.LastBootupTime)}},@{n="LocalDateTimeFormatted";e={$_.ConvertToDateTime($_.LocalDateTime)}},InstallDate, LastBootUpTime, LocalDateTime' 
        Message              = "Gets various DateTimes."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'Disk (Logical Info)'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "System" 
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = 'Get-WmiObject -Class Win32_LogicalDisk'
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { Get-PSDrive }"
        Command_WinRM_WMI    = "Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_LogicalDisk }"
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = "winrs wmic LogicalDisk list brief"
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, Free, Used, Description, Provider, Root' 
        Properties_WMI       = 'PSComputerName, FreeSpace, Size, Description, ProviderName, DeviceID, DriveType, VolumeName' 
        Message              = "Gets logical disk/drive information."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'Disk (Physical Info)'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Hardware" 
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = 'Get-WmiObject -Class Win32_DiskDrive'
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = 'Invoke-Command -ScriptBlock { Get-Disk }'
        Command_WinRM_WMI    = 'Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_DiskDrive }'
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = 'winrs wmic DiskDrive list brief'
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, Number, FriendlyName, Model, Manufacturer, SerialNumber, OperationalStatus, TotalSize, BootFromDisk, IsSystem, IsOfline, IsReadOnly, PartitionStyle, NumberOfPartitions, LargestFreeExtent, Location, UniqueId' 
        Properties_WMI       = 'PSComputerName, Status, Name, Caption, Description, Model, Manufacturer, SerialNumber, Signature, InterfaceType, MediaType, FirmwareRevision, SectorsPerTrack, Size, TotalCylinders, TotalHeads, TotalSectors, TotalTracks, TracksPerCylinder' 
        Message              = "Gets one or more disks visible to the operating system."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }


    $CollectionName = 'DNS Cache'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Network" 
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null #'Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "cmd /c ipconfig /displaydns > c:\results.txt"'
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = 'Invoke-Command -ScriptBlock { Get-DnsClientCache }'
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = 'Invoke-Command -ScriptBlock { cmd /c ipconfig /displaydns }'
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = 'winrs cmd /c ipconfig /displaydns'
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, Entry, RecordName, RecordType, Status, Section, TimeToLive, Data' 
        Properties_WMI       = 'PSComputerName, *'
        Message              = "Retrieves the contents of the DNS client cache."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'Drivers (Detailed)'
    $CommandScript  = @'

            # Gets Driver Details, MD5 Hash, and File Signature Status
            # This script can be quite time consuming
            $Drivers = Get-WindowsDriver -Online -All
            $MD5     = [System.Security.Cryptography.HashAlgorithm]::Create("MD5")
            $SHA256  = [System.Security.Cryptography.HashAlgorithm]::Create("SHA256")
        
            foreach ($Driver in $Drivers) {
                $filebytes = [system.io.file]::ReadAllBytes($($Driver).OriginalFilename)
            
                $HashMD5 = [System.BitConverter]::ToString($MD5.ComputeHash($filebytes)) -replace "-", ""
                $Driver | Add-Member -NotePropertyName HashMD5 -NotePropertyValue $HashMD5            

                # If enbaled, add HashSHA256 to Select-Object
                #$HashSHA256 = [System.BitConverter]::ToString($SHA256.ComputeHash($filebytes)) -replace "-", ""
                #$Driver | Add-Member -NotePropertyName HashSHA256 -NotePropertyValue $HashSHA256
            
                $FileSignature = Get-AuthenticodeSignature -FilePath $Driver.OriginalFileName
                $Signercertificate = $FileSignature.SignerCertificate.Thumbprint
                $Driver | Add-Member -NotePropertyName SignerCertificate -NotePropertyValue $Signercertificate
                $Status = $FileSignature.Status
                $Driver | Add-Member -NotePropertyName Status -NotePropertyValue $Status
                $Driver | Select-Object -Property PSComputerName, Online, ClassName, Driver, OriginalFileName, ClassDescription, BootCritical, HashMD5, DriverSignature, SignerCertificate, Status, ProviderName, Date, Version, InBox, LogPath, LogLevel
            }

'@
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "System" 
        #Command_RPC_CMD      = 'cmd c/ driverquery /si /s ' #cmd /c driverquery /si /s hostname /FO CSV
        #Command_RPC_CMD_Arg  = '/FO CSV'
        Command_RPC_PoSh     = $null
        Command_WMI          = 'Get-WmiObject -Class Win32_Systemdriver'
        Command_WinRM_Script = "Invoke-Command -ScriptBlock { $CommandScript }"
        Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { Get-WindowsDriver -Online -All }"
        Command_WinRM_WMI    = "Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_Systemdriver }"
        Command_WinRM_CMD    = 'Invoke-Command -ScriptBlock { cmd /c driverquery /si /FO CSV }'
        Command_WinRS_WMIC   = $null #Note: 'winrs wmic SystemDriver' does not work
        Command_WinRS_CMD    = 'winrs driverquery /si /FO CSV'
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, Online, ClassName, Driver, OriginalFileName, ClassDescription, BootCritical, DriverSignature, ProviderName, Date, Version, InBox, LogPath, LogLevel' 
        Properties_WMI       = 'PSComputerName, State, Status, Started, StartMode, Name, DisplayName, PathName, ExitCode, AcceptPause, AcceptStop, Caption, CreationClassName, Description, DesktopInteract, ErrorControl, InstallDate, ServiceType' 
        Message              = "Displays driver information in a Windows image."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'Environmental Variables'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "System" 
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = 'Get-WmiObject -Class Win32_Environment'
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { Get-ChildItem Env: }"
        Command_WinRM_WMI    = "Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_Environment }"
        Command_WinRM_CMD    = "Invoke-Command -ScriptBlock { cmd /c set }"
        Command_WinRS_WMIC   = "winrs wmic environment list"
        Command_WinRS_CMD    = "winrs set"
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, PSDrive, Name, Value' 
        Properties_WMI       = 'PSComputerName, UserName, Name, VariableValue' 
        Message              = "Gets the environmental variables."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'EventLog Statistics (Basic)'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "System"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = "Get-EventLog -List"
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { Get-EventLog -List }"
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = "winrs wmic nteventlog list brief"
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, MaximumKilobytes, MinimumRetentionDays, OverflowAction, @{name="Entries"; expression={($_.Entries).count}}, Log, EnableRaisingEvents' 
        Properties_WMI       = 'PSComputerName, *'
        Message              = "Get Event Log statistics"
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'EventLog Statistics (Detailed)'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "System"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = "Get-WinEvent -ListLog *"
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { Get-WinEvent -ListLog * }"
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, IsEnabled, LogMode, MaximumSizeInBytes, RecordCount, LogName, LogType, LogIsolation, FileSize, IsLogFull, LastWriteTime, OldestRecordNumber'
        Properties_WMI       = 'PSComputerName, *'
        Message              = "Get a more granular breakdown of Event Log statistics"
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'Failed Logins (30 days)'
    $CommandScript = @'
 
            # Get Filaed Logins (30 days)
            Get-Eventlog -LogName Security -InstanceId 4625 -After (Get-Date).AddDays(-30) `
                | Select TimeGenerated, ReplacementStrings `
                | Foreach { 
                    New-Object PSObject -Property @{ 
                    Source_Computer = $_.ReplacementStrings[13] 
                    UserName = $_.ReplacementStrings[5] 
                    IP_Address = $_.ReplacementStrings[19] 
                    Date = $_.TimeGenerated 
                }
            }
'@
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "User" 
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = "Invoke-Command -ScriptBlock { $CommandScript }"
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = $null
        Properties_WMI       = 'PSComputerName, *'
        Message              = "Get failed loggons from the last 30 days."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'Firewall Port Proxy'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = $null
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null #'Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "cmd /c netsh interface portproxy show all > c:\results.txt"'
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = 'Invoke-Command -ScriptBlock { cmd /c netsh interface portproxy show all }'
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = 'winrs netsh interface portproxy show all'
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *' 
        Properties_WMI       = 'PSComputerName, *'
        Message              = "Gets the ports that are forwarded/redirected elsewhere."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'Firewall Rules'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Network, System" 
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null #'Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "cmd /c netsh advfirewall firewall show rule name=all > c:\results.txt"'
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { Get-NetFirewallRule }"
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = 'Invoke-Command -ScriptBlock { cmd /c netsh advfirewall firewall show rule name=all }'
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = 'winrs netsh advfirewall firewall show rule name=all'
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, Enabled, Name, DisplayName, Description, DisplayGroup, Group, Profile, Direction, Action, EdgeTraversalPolicy, LooseSourceMapping, LocalOnlyMapping, Owner, EnforcementStatus, Status, PrimaryStatus, PolicyStoreSource, PolicyStoreSourceType' 
        Properties_WMI       = 'PSComputerName, *'
        Message              = "Get the firewall rules."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'Firewall Status'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Network, System" 
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null #'Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "cmd /c netsh advfirewall show allprofiles state > c:\results.txt"'
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { Get-NetFirewallProfile }"
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = "Invoke-Command -ScriptBlock { cmd /c netsh advfirewall show allprofiles state }"
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = 'winrs netsh advfirewall show allprofiles state'
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, Name, Enabled, DefaultInboundAction, DefaultOutboundAction, AllowInboundRules, AllowLocalFirewallRules, AllowLocalIPsecRules, AllowUserApps, AllowUserPorts, AllowUnicastResponseToMulticast, NotifyOnListen, EnableStealthModeForIPsec, LogFileName, LogMaxsizeKilobytes, LogAllowed, LogBlocked, LogIgnored, DisabledInterfaceAliases' 
        Properties_WMI       = 'PSComputerName, *'
        Message              = "Displays settings that apply to the per-profile configurations of the Windows Firewall with Advanced Security"
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'Groups (Local)'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "User" 
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = "Get-WmiObject -Class Win32_Group -Filter { LocalAccount='True' }"
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { Get-LocalGroup }"
        Command_WinRM_WMI    = "Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_Group -Filter { LocalAccount='True' }}"
        Command_WinRM_CMD    = "Invoke-Command -ScriptBlock { cmd /c net localgroup }"
        Command_WinRS_WMIC   = "winrs wmic group list"
        #Command_WinRS_WMIC   = "winrs wmic sysaccount"
        Command_WinRS_CMD    = "winrs net localgroup"
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *' 
        Properties_WMI       = 'PSComputerName, Name, LocalAccount, Domain, SID, SIDType, Caption, Description' 
        Message              = $null
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'Host Files'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "File"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null #'Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "cmd /c type C:\Windows\System32\drivers\etc\hosts > c:\results.txt"'
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = "Invoke-Command -ScriptBlock { Get-Content C:\Windows\System32\drivers\etc\hosts }"
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = "winrs type C:\Windows\System32\drivers\etc\hosts"
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *' 
        Properties_WMI       = 'PSComputerName, Directory, Name, Length, CreationTime, LastWriteTime, LastAccessTime, Attributes, Mode' 
        Message              = "Gets the contents of the Host file, which is a file that maps hostnames to IP addresses."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'Logon Info'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "User, Charts"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = 'Get-WmiObject -Class Win32_NetworkLoginProfile'
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = "Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_NetworkLoginProfile }"
        Command_WinRM_CMD    = "Invoke-Command -ScriptBlock { cmd /c net config workstation | find /I ' name ' }"
        Command_WinRS_WMIC   = "winrs wmic netlogin list brief"
        Command_WinRS_CMD    = "winrs net config workstation | find /I ' name '"
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *' 
        Properties_WMI       = 'PSComputerName, Name, LastLogon, LastLogoff, NumberOfLogons, PasswordAge' 
        Message              = "Gets information about user logon activity."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'Logon Sessions'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "User, System"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null #'Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "cmd /c query session > c:\results.txt"'
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = 'Invoke-Command -ScriptBlock { cmd /c query session }'
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = 'winrs query session'
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *'
        Properties_WMI       = 'PSComputerName, *'
        Message              = "Gets session information of the computer."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'Logon User Status'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "User"
        #Command_RPC_CMD      = 'query user /server:' # query user /server:$SERVER
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = 'Get-WmiObject -Class Win32_LoggedOnUser'
        #Command_WMI          = $null #'Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "cmd /c query user > c:\results.txt"'
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = 'Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_LoggedOnUser }'
        Command_WinRM_CMD    = 'Invoke-Command -ScriptBlock { cmd /c query user }'
        Command_WinRS_WMIC   = $null #NOTE: 'wmic loggedonuser' does not work
        Command_WinRS_CMD    = "winrs query user"
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *' 
        Properties_WMI       = 'PSComputerName, Antecedent, Dependent'
        Message              = "Gets information about when a user logged on."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'Mapped Drives'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "System, Charts"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = 'Get-WmiObject -Class Win32_MappedLogicalDisk'
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = 'Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_MappedLogicalDisk }'
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null #NOTE: 'wmic mappedlogicaldisk' does not work
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *' 
        Properties_WMI       = 'PSComputerName, Name, ProviderName, FileSystem, Size, FreeSpace, Compressed' 
        Message              = "Gets information about mapped drives."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'Memory (Capacity Info)'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Hardware"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = 'Get-WmiObject -Class Win32_PhysicalMemoryArray'
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = "Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_PhysicalMemoryArray }"
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null #NOTE 'wmic PhysicalMemoryArray' does not work
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *' 
        Properties_WMI       = "PSComputerName, Model, Name, MaxCapacity, @{Name='MaxCapacityGigabyte';Expression={$_.MaxCapacity / 1Mb}}, MemoryDevices"
        Message              = "Gets capacity information of the system memory."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'Memory (Performance Data)'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Hardware, System"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = 'Get-WmiObject -Class Win32_PerfRawData_PerfOS_Memory'
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = "Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_PerfRawData_PerfOS_Memory }"
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null #NOTE: 'wmic PerfRawData_PerfOS_Memory' does not work
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *' 
        Properties_WMI       = 'PSComputerName, AvaiLabelBytes, AvaiLabelKBytes, AvaiLabelMBytes, CacheBytes, CacheBytesPeak, CacheFaultsPersec, Caption, CommitLimit, CommittedBytes, DemandZeroFaultsPersec, FreeAndZeroPageListBytes, FreeSystemPageTableEntries, Frequency_Object, Frequency_PerfTime, Frequency_Sys100NS, LongTermAverageStandbyCacheLifetimes, ModifiedPageListBytes, PageFaultsPersec, PageReadsPersec, PagesInputPersec, PagesOutputPersec, PagesPersec, PageWritesPersec, PercentCommittedBytesInUse, PercentCommittedBytesInUse_Base, PoolNonpagedAllocs, PoolNonpagedBytes, PoolPagedAllocs, PoolPagedBytes, PoolPagedResidentBytes, StandbyCacheCoreBytes, StandbyCacheNormalPriorityBytes, StandbyCacheReserveBytes, SystemCacheResidentBytes, SystemCodeResidentBytes, SystemCodeTotalBytes, SystemDriverResidentBytes, SystemDriverTotalBytes, Timestamp_Object, Timestamp_PerfTime, Timestamp_Sys100NS, TransitionFaultsPersec, TransitionPagesRePurposedPersec, WriteCopiesPersec' 
        Message              = "Gets performance data information of the system memory."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'Memory (Physical Info)'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Hardware"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = 'Get-WmiObject -Class Win32_PhysicalMemory'
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = "Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_PhysicalMemory }"
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null #NOTE 'wmic PhysicalMemory' does not work
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *' 
        Properties_WMI       = 'PSComputerName, Tag, Capacity, Speed, Manufacturer, PartNumber, SerialNumber' 
        Message              = "Gets physical information of the system memory."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'Memory (Utilization)'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "System"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = 'Get-WmiObject -Class Win32_OperatingSystem'
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = "Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_OperatingSystem }"
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null #NOTE: 'wmic OperatingSystem' does not work
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *' 
        Properties_WMI       = 'PSComputerName, FreePhysicalMemory,TotalVisibleMemorySize, FreeVirtualMemory, TotalVirtualMemorySize, @{Name="FreePhysicalMemoryMegabyte";Expression={$_.FreePhysicalMemory / 1KB}}, @{Name="TotalVisibleMemorySizeMegabyte";Expression={$_.TotalVisibleMemorySize / 1KB}}, @{Name="FreeVirtualMemoryeMegabyte";Expression={$_.FreeVirtualMemory / 1KB}}, @{Name="TotalVirtualMemorySizeMegabyte";Expression={$_.TotalVirtualMemorySize / 1KB}}'
        Message              = "Gets utilization information of the system memory."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'Motherboard Info'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Hardware"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = 'Get-WmiObject -Class Win32_BaseBoard'
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = "Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_BaseBoard }"
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = "winrs wmic baseboard list brief"
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *' 
        Properties_WMI       = 'PSComputerName, Manufacturer, Model, Name, SerialNumber, SKU, Product' 
        Message              = $null
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'Network Connections TCP (Enhanced)'
    $CommandScript = @'

            function Get-NetTCPProcessConnection {
                $Connections = Get-NetTCPConnection
                $Processes   = Get-WmiObject -Class Win32_Process
                ForEach ($Conn in $Connections) {
                    foreach ($Proc in $Processes) {
                        if ($Conn.OwningProcess -eq $Proc.ProcessId) {
                            $Conn | Add-Member -MemberType NoteProperty -Name 'ProcessName' -Value $Proc.Name
                            $Conn | Add-Member -MemberType NoteProperty -Name 'Duration' -Value $((New-TimeSpan -Start ($Conn.CreationTime)).ToString())
                            $Conn | Add-Member -MemberType NoteProperty -Name 'CommandLine' -Value $Proc.CommandLine
                        }
                    }        
                }
                return $Connections `
                    | Select-Object -Property @{name="PSComputerName";expression={hostname}}, RemoteAddress, RemotePort, OwningProcess, ProcessName, CreationTime, CommandLine `
                    | Sort-Object -Property ProcessName
            }
            Get-NetTCPProcessConnection
'@    
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Network"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = "Invoke-command -ScriptBlock { $CommandScript }"
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, State, LocalAddress, LocalPort, RemoteAddress, RemotePort, OwningProcess, CreationTime, OffloadState, AppliedSetting' 
        Properties_WMI       = 'PSComputerName, *'
        Message              = "Gets TCP Network Connectionn, Enhanced Process Names and conneciton duration."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'Network Connections TCP'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Network"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null #'Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "cmd /c netstat -anob -p tcp > c:\results.txt"'
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = 'Invoke-Command -ScriptBlock { Get-NetTCPConnection }'
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = 'Invoke-Command -ScriptBlock { cmd /c netstat -anob -p tcp }'
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = 'winrs netstat -anob -p tcp'
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, State, LocalAddress, LocalPort, RemoteAddress, RemotePort, OwningProcess, CreationTime, OffloadState, AppliedSetting' 
        Properties_WMI       = 'PSComputerName, *'
        Message              = "Gets TCP Network Connections"
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }
    
    $CollectionName = 'Network Connections UDP'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Network" 
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null #'Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "cmd /c netstat -anob -p udp > c:\results.txt"'
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = 'Invoke-Command -ScriptBlock { Get-NetUDPEndpoint }'
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = 'Invoke-Command -ScriptBlock { cmd /c netstat -anob -p udp }'
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = 'winrs netstat -anob -p udp'
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, LocalAddress, LocalPort' 
        Properties_WMI       = 'PSComputerName, *'
        Message              = "Gets UDP Network Connections"
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'Network Interface Info (Enhanced)'
        #Get-NetIPConfiguration
        #Get-NetAdapter
        #Get-NetIPAddress
        #Get-WmiObject -Class Win32_NetworkAdapterConfiguration

    $CollectionName = 'Network Settings'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Network, Charts, MAC Address, IP Address" 
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = 'Get-WmiObject -Class Win32_NetworkAdapterConfiguration' 
#       Command_WMI          = 'Get-WmiObject -Class Win32_NetworkAdapter' 
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { Get-NetIPAddress }" 
#       Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { Get-NetAdapter }" 
        Command_WinRM_WMI    = "Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_NetworkAdapterConfiguration }"
#       Command_WinRM_WMI    = "Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_NetworkAdapter }"
        Command_WinRM_CMD    = "Invoke-Command -ScriptBlock { cmd /c ipconfig /all }"
        Command_WinRS_WMIC   = "winrs wmic nicconfig list brief"
#       Command_WinRS_WMIC   = "winrs wmic nic list brief"
        Command_WinRS_CMD    = "winrs ipconfig /all"
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, IPAddress, InterfaceIndex, InterfaceAlias, AddressFamily, Type, PrefixLength, PrefixOrigin, SuffixOrigin, AddressState, ValidLifetime, PreferredLifetime, SkipAsSource, PolicyStore' 
        Properties_WMI       = 'PSComputerName, MACAddress, `
            @{Name="IPAddress";Expression={$_.IPAddress -join "; "}}, `
            @{Name="IpSubnet";Expression={$_.IpSubnet -join "; "}}, `
            @{Name="DefaultIPGateway";Expression={$_.DefaultIPgateway -join "; "}}, `
            Description, ServiceName, IPEnabled, DHCPEnabled, DNSHostname, `
            @{Name="DNSDomainSuffixSearchOrder";Expression={$_.DNSDomainSuffixSearchOrder -join "; "}}, `
            DNSEnabledForWINSResolution, DomainDNSRegistrationEnabled, FullDNSRegistrationEnabled, `
            @{Name="DNSServerSearchOrder";Expression={$_.DNSServerSearchOrder -join "; "}}, `
            @{Name="WinsPrimaryServer";Expression={$_.WinsPrimaryServer -join "; "}}, `
            @{Name="WINSSecondaryServer";Expression={$_.WINSSecondaryServer -join "; "}}' 
        Message              = "Gets network interface settings."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'Network Statistics IPv4 All'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Network" 
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null #'Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "cmd /c netstat -e -p ip > c:\results.txt"'
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = 'Invoke-Command -ScriptBlock { cmd /c netstat -e -p ip }'
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *' 
        Properties_WMI       = 'PSComputerName, *'
        Message              = "Gets all host protocol statistics for an IPv4 network."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'Network Statistics IPv4 ICMP'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Network"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null #'Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "cmd /c netstat -e -p icmp > c:\results.txt"'
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = 'Invoke-Command -ScriptBlock { cmd /c netstat -e -p icmp }'
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *' 
        Properties_WMI       = 'PSComputerName, *'
        Message              = "Gets host ICMP statistics for an IPv4 network."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'Network Statistics IPv4 TCP'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Network"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null #'Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "cmd /c netstat -e -p tcp > c:\results.txt"'
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = 'Invoke-Command -ScriptBlock { cmd /c netstat -e -p tcp }'
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *' 
        Properties_WMI       = 'PSComputerName, *'
        Message              = "Gets host TCP statistics for an IPv4 network."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'Network Statistics IPv4 UDP'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Network"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null #'Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "cmd /c netstat -e -p udp > c:\results.txt"'
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = 'Invoke-Command -ScriptBlock { cmd /c netstat -e -p udp }'
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *' 
        Properties_WMI       = 'PSComputerName, *'
        Message              = "Gets host UDP statistics for an IPv4 network."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'Network Statistics IPv6 All'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Network"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null #'Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "cmd /c netstat -e -p ipv6 > c:\results.txt"'
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = 'Invoke-Command -ScriptBlock { cmd /c netstat -e -p ipv6 }'
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *' 
        Properties_WMI       = 'PSComputerName, *'
        Message              = "Gets all host protocol statistics for an IPv6 network."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'Network Statistics IPv6 TCP'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Network"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null #'Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "cmd /c netstat -e -p tcpv6 > c:\results.txt"'
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = 'Invoke-Command -ScriptBlock { cmd /c netstat -e -p tcpv6 }'
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *' 
        Properties_WMI       = 'PSComputerName, *'
        Message              = "Gets host TCP statistics for an IPv6 network."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'Network Statistics IPv6 UDP'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Network"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null #'Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "cmd /c netstat -e -p udpv6 > c:\results.txt"'
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = 'Invoke-Command -ScriptBlock { cmd /c netstat -e -p udpv6 }'
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *' 
        Properties_WMI       = 'PSComputerName, *'
        Message              = "Gets host UDP statistics for an IPv6 network."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'Network Statistics IPv6 ICMP'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Network"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null #'Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "cmd /c netstat -e -p icmpv6 > c:\results.txt"'
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = 'Invoke-Command -ScriptBlock { cmd /c netstat -e -p icmpv6 }'
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *' 
        Properties_WMI       = 'PSComputerName, *'
        Message              = "Gets host ICMP statistics for an IPv6 network."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'Pipes (Named Pipes)'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "System, Network, Hunt"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WinRM_WMI    = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = 'Invoke-Command -ScriptBlock { Get-ChildItem \\.\\pipe\\ -Force }'
    #    Command_WinRM_PoSh   = 'Invoke-Command -ScriptBlock { [System.IO.Directory]::GetFiles("\\.\\pipe\\") }'
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, Name, Directory, IsReadOnly, CreationTime, LastAccessTime, LastWriteTime, Mode, Attributes' 
        Properties_WMI       = 'PSComputerName, *'
        Message              = "A pipe is a section of shared memory that processes use for communication. The process that creates a pipe is the pipe server. A process that connects to a pipe is a pipe client. One process writes information to the pipe, then the other process reads the information from the pipe. A named pipe is a named, one-way or duplex pipe for communication between the pipe server and one or more pipe clients. All instances of a named pipe share the same pipe name, but each instance has its own buffers and handles, and provides a separate conduit for client/server communication. The use of instances enables multiple pipe clients to use the same named pipe simultaneously. Any process can access named pipes, subject to security checks, making named pipes an easy form of communication between related or unrelated processes. Any process can act as both a server and a client, making peer-to-peer communication possible."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'Plug and Play Devices'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = 'Plug and Play Devices'
        Type                 = "Hardware"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = 'Get-WmiObject -Class Win32_PnPEntity'
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { Get-PnpDevice }"
        Command_WinRM_WMI    = "Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_PnPEntity }"
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *' 
        Properties_WMI       = 'PSComputerName, InstallDate, Status, Description, Service, DeviceID, @{Name="HardwareID";Expression={$_.HardwareID -join "; "}}, Manufacturer' 
        Message              = "Gets information on Plug and Play (PnP) Devices"
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }
<#THIS ISN'T WORKING REMOTLY FOR SOME REASON, NEEDS TROUBLESHOOTING
    $CollectionName = 'PowerShell Profiles'
    $CommandScript = @'

            $ProfileCheck = $Variable:Profile | Get-Member -MemberType NoteProperty | select Name, @{name='Path';expression={((($_.definition) -split '=')[1])}} 
            foreach ($item in $ProfileCheck) {
                $TestPath = $(Test-Path -Path $item.path)
                $item | Add-Member -MemberType NoteProperty -Name "DoesItExist" -value $TestPath
            }
            $ProfileCheck | Select-Object -Property @{name="PSComputerName";expression={hostname}}, Name, Path, DoesItExist
'@
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "File, Hunt" 
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Command_WinRM_Script = "Invoke-Command -ScriptBlock { $CommandScript }"
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *'
        Properties_WMI       = 'PSComputerName, *'
        Message              = "A PowerShell profile is a script that runs when PowerShell starts. You can use the profile as a logon script to customize the environment. You can add commands, aliases, functions, variables, snap-ins, modules, and PowerShell drives. ... PowerShell supports several profiles for users and host programs."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }
<#THIS ISN'T WORKING REMOTLY FOR SOME REASON, NEEDS TROUBLESHOOTING #>

    $CollectionName = 'Prefetch Files'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "File"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null #'Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "cmd /c dir /a C:\Windows\Prefetch > c:\results.txt"'
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = 'Invoke-Command -ScriptBlock { Get-ChildItem C:\Windows\Prefetch -Force }'
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = 'Invoke-Command -ScriptBlock { cmd /c dir /a C:\Windows\Prefetch }'
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = "winrs dir C:\Windows\Prefetch"
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, Name, Directory, IsReadOnly, CreationTime, LastAccessTime, LastWriteTime, Mode, Attributes' 
        Properties_WMI       = 'PSComputerName, Directory, Name, Length, CreationTime, LastWriteTime, LastAccessTime, Attributes, Mode' 
        Message              = "Gets the Prefetch Files. Prefetch files are great artifacts for forensic investigators trying to analyze applications that have been run on a system. Windows creates a prefetch file when an application is run from a particular location for the very first time. This is used to help speed up the loading of applications"
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }    

    $CollectionName = 'Printers Mapped'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "File"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = 'Get-WmiObject -Class Win32_Printer'
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = 'Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_Printer }'
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *'
        Properties_WMI       = 'PSComputerName, Name, Status, Shared, Local, Network, SpoolEnabled, KeepPrintedJobs, DriverName, Default, Location'
        Message              = "Gets printer information."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }
    
<# THIS ISN'T WORKING REMOTLY FOR SOME REASON, NEEDS TROUBLESHOOTING
    $CollectionName = 'Process Tree (Lineage)'
    $CommandScript = @'

            $script:Results = @()
            $script:Results += $('==================================================')
            $script:Results += $('{0,-8}{1}' -f 'PID','Process Name')
            $script:Results += $('==================================================')
            Function Get-ProcessChildren ($P,$Depth=1) {
                $procs | Where-Object {
                    $_.ParentProcessId -eq $p.ProcessID -and $_.ParentProcessId -ne 0
                } | ForEach-Object {
                    $script:Results += $('{0,-8}{1}|--- {2}' -f $_.ProcessID,(' '*5*$Depth),$_.Name,$_.ParentProcessId)
                    Get-ProcessChildren $_ (++$Depth) 
                    $Depth-- 
                }
            } 
            $filter = { -not (Get-Process -Id $_.ParentProcessId -ErrorAction SilentlyContinue) -or $_.ParentProcessId -eq 0 } 
                $procs = Get-WmiObject -Class Win32_Process
                $top = $procs | Where-Object $filter | Sort-Object ProcessID 
            foreach ($p in $top) {
                $script:Results += $('{0,-8}{1}' -f $p.ProcessID, $p.Name)                
                Get-ProcessChildren $p
            }
            return $script:Results
'@
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = 'Process Tree (Lineage)'
        Type                 = 'System' 
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_PoSh   = $null
        Command_WinRM_Script = "Invoke-Command -ScriptBlock { $CommandScript }"
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *' 
        Properties_WMI       = 'PSComputerName, *'
        Message              = 'Gets the lineage of each process in a simple to view tree.'
        NotesPath            = '$CommandsHostDirectoryNotes\$CollectionName.txt'
        ExportFileName       = "$IndividualHostResults\$CollectionName\$CollectionName"
    }
THIS ISN'T WORKING REMOTLY FOR SOME REASON, NEEDS TROUBLESHOOTING #>

    $CollectionName = 'Processes (Enhanced)'
    $Commandscript = @'

            # Enhanced process collection coorelates information from multiple sources
            # Correlates network connection data, and adds other data such as filehashes and signatures
            # This script may take some time to run and collect data
            $ErrorActionPreference="SilentlyContinue"
            # Create Hashtable of all network processes and their PIDs
            $Connections = @{}
            foreach($Connection in Get-NetTCPConnection) {
                $connStr = "[$($Connection.State)] " + "$($Connection.LocalAddress)" + ":" + "$($Connection.LocalPort)" + " <--> " + "$($Connection.RemoteAddress)" + ":" + "$($Connection.RemotePort)`n"
                if($Connection.OwningProcess -in $Connections.keys) {
                    if($connStr -notin $Connections[$Connection.OwningProcess]) {
                        $Connections[$Connection.OwningProcess] += $connStr
                    }
                }
                else{
                    $Connections[$Connection.OwningProcess] = $connStr
                }
            }
            $ProcessesWMI       = Get-WmiObject -Class Win32_Process 
            $ProcessesPS        = Get-Process
            $NetworkConnections = Get-NetTCPConnection

            $ProcessCount   = ($ProcessesWMI).count
            $IterationCount = 0
            foreach ($Process in $ProcessesWMI) {
                $IterationCount += 1
                $ProcessesPsId = $ProcessesPS | Where Id -eq $Process.ProcessId
                Write-Progress -Activity "Compiling Process Info and TCP Network Connections" -Status "Progress: $($Process.Name)" -PercentComplete ($IterationCount/$ProcessCount*100)
                $Process | Add-Member -NotePropertyName NetworkConnections -NotePropertyValue $Connections[$Process.ProcessId] -ErrorAction SilentlyContinue
                $Process | Add-Member -NotePropertyName ParentProcessName  -NotePropertyValue $((Get-Process -Id ($Process.ParentProcessId) -ErrorAction SilentlyContinue).name)
                $Process | Add-Member -NotePropertyName MD5Hash            -NotePropertyValue $((Get-FileHash -Path ($Process.Path) -Algorithm MD5 -ErrorAction SilentlyContinue).Hash)
                $Process | Add-Member -NotePropertyName DateCreated        -NotePropertyValue $([Management.ManagementDateTimeConverter]::ToDateTime($Process.CreationDate))
                $Process | Add-Member -NotePropertyName Handle             -NotePropertyValue $($ProcessesPsId.Handle)
                $Process | Add-Member -NotePropertyName HandleCount        -NotePropertyValue $($ProcessesPsId.HandleCount)
                $Process | Add-Member -NotePropertyName Product            -NotePropertyValue $($ProcessesPsId.Product)
                $Process | Add-Member -NotePropertyName PSDescription      -NotePropertyValue $($ProcessesPsId.Description)
                $Process | Add-Member -NotePropertyName Threads            -NotePropertyValue $($ProcessesPsId.Threads.Id)
                $Process | Add-Member -NotePropertyName Modules            -NotePropertyValue $($ProcessesPsId.modules.modulename)

                try {
                    $AuthenticodeSignature = Get-AuthenticodeSignature $Process.Path
                    $Process  | Add-Member -NotePropertyName StatusMessage     -NotePropertyValue $( if ($AuthenticodeSignature.StatusMessage -match 'verified') {'Signature Verified'}; elseif ($AuthenticodeSignature.StatusMessage -match 'not digitally signed') {'The file is not digitially signed.'})
                    $Process  | Add-Member -NotePropertyName SignerCertificate -NotePropertyValue $AuthenticodeSignature.SignerCertificate.Thumbprint
                    $Process  | Add-Member -NotePropertyName Company           -NotePropertyValue $($AuthenticodeSignature.SignerCertificate.Subject.split(',')[0] -replace 'CN=' -replace '"')
                    #$Process | Add-Member -NotePropertyName RSAKey            -NotePropertyValue $($AuthenticodeSignature.SignerCertificate.PublicKey.EncodedKeyValue.rawdata -join '')
                }
                catch {}

                $Owner    = $Process.GetOwner().Domain.ToString() + "\"+ $Process.GetOwner().User.ToString()
                $OwnerSID = $Process.GetOwnerSid().Sid.ToString()
                $Process  | Add-Member -NotePropertyName Owner    -NotePropertyValue $Owner
                $Process  | Add-Member -NotePropertyName OwnerSID -NotePropertyValue $OwnerSID
            }
            $ProcessesWMI | Select-Object -Property PSComputerName, Name, DateCreated, ProcessId, ParentProcessId, ParentProcessName, NetworkConnections, Path, MD5Hash, SignerCertificate, StatusMessage, Company, Product, PSDescription, RSAKey, Owner, OwnerSID, CommandLine, WorkingSetSize, Threads, ThreadCount, Handle, HandleCount, Modules
'@
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = 'Processes (Enhanced)'
        Type                 = "System"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = "Invoke-Command -ScriptBlock { $CommandScript }"
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *'
        Properties_WMI       = 'PSComputerName, *'
        Message              = "Gets running processes, their hashes, loaded dlls, and associated network connections."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'Processes - (Standard)'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "System, Charts"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = "Get-Process"
        Command_WMI          = "Get-WmiObject -Class Win32_Process"
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { Get-Process }"
        Command_WinRM_WMI    = "Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_Process }"
        Command_WinRM_CMD    = "Invoke-Command -ScriptBlock { cmd /c tasklist /V /FO CSV }"
        Command_WinRS_WMIC   = "winrs wmic process list brief"
        Command_WinRS_CMD    = "winrs tasklist /V /FO CSV"
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, Name, ID, Path, StartTime, @{name="WorkingSetSize";expression={$_.WS}} , Handle, HandleCount, @{Name="ThreadCount";expression={($_.Threads).count}}, Company, Product, Description'
        Properties_WMI       = 'PSComputerName, @{name="Name";expression={(($_.Name).split("."))[0]}}, ProcessID, ParentProcessID, Path, WorkingSetSize, Handle, HandleCount, ThreadCount, CreationDate, Description'
        Message              = "Gets a list of running processes."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'Processor (CPU Info)'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Hardware" 
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = 'Get-WmiObject -Class Win32_Processor'
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = "Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_Processor }"
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null #NOTE: 'wmic processor' does not work
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *'
        Properties_WMI       = 'PSComputerName, Name, Manufacturer, Caption, DeviceID, SocketDesignation, MaxClockSpeed' 
        Message              = "Gets information on the CPU Processor."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'Restore Point Info'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "System"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { Get-ComputerRestorePoint }"
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *'
        Properties_WMI       = 'PSComputerName, *'
        Message              = "Gets a list of Restore Points."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }   

    $CollectionName = 'Scheduled Tasks'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "System"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null #'Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "cmd /c schtasks /query /V /FO CSV > c:\results.txt"'
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = 'Invoke-Command -ScriptBlock { Get-ScheduledTask }'
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = 'Invoke-Command -ScriptBlock { cmd /c schtasks /query /V /FO CSV }'
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = 'winrs schtasks /query /V /FO CSV'
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, TaskName, State, Date, Actions, TaskPath, Description' 
        Properties_WMI       = 'PSComputerName, *'
        Message              = "Gets scheduled tasks."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }
    
    $CollectionName = 'Screen Saver Info'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "System"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = 'Get-WmiObject -Class Win32_Desktop'
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = "Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_Desktop }"
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = 'winrs wmic desktop list brief'
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *' 
        Properties_WMI       = 'PSComputerName, Name, ScreenSaverActive, ScreenSaverTimeout, ScreenSaverExecutable, Wallpaper' 
        Message              = "Get screensaver information."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'Security Patches'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "System, Charts"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = "Get-HotFix"
        Command_WMI          = 'Get-WmiObject -Class Win32_QuickFixEngineering'
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { Get-HotFix }"
        Command_WinRM_WMI    = "Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_QuickFixEngineering }"
        Command_WinRM_CMD    = "Invoke-Command -ScriptBlock { cmd c\ dism /online /get-packages }"
        Command_WinRS_WMIC   = "winrs wmic qfe list"
        Command_WinRS_CMD    = "winrs dism /online /get-packages"
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *' 
        Properties_WMI       = 'PSComputerName, @{Name="Name";Expression={$_.HotFixID}}, HotFixID, Description, InstalledBy, InstalledOn' 
        Message              = "Gets information on security patches and when they were installed."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'Services'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "System, Charts"
        #Command_RPC_CMD      = "cmd /c sc \\"#sc \\hostname query state= all
        #Command_RPC_CMD_Arg  = "query state= all" 
        Command_RPC_PoSh     = "Get-Service"
        Command_WMI          = 'Get-WmiObject -Class Win32_Service'
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { Get-Service }"
        Command_WinRM_WMI    = "Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_Service }"
        Command_WinRM_CMD    = "Invoke-Command -ScriptBlock { cmd /c sc query state=all }"
        Command_WinRS_WMIC   = "winrs wmic service list brief"
        Command_WinRS_CMD    = "winrs sc query state=all"
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, Status, Name, DisplayName, RequiredServices, StartType, CanPauseAndContinue, CanShutdown, CanStop, ServiceHandle' 
        Properties_WMI       = 'PSComputerName, State, Name, ProcessID, Description, PathName, Started, StartMode, StartName' 
        Message              = "Gets information on services."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'Services Hosted in each Process'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "System"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = "Invoke-Command -ScriptBlock { cmd /c tasklist /SVC /FO CSV }"
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = "winrs tasklist /SVC /FO CSV"
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *'
        Properties_WMI       = 'PSComputerName, *'
        Message              = "Displays with the services hosted in each process."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    ############################################
    ########## PsExec \\servername NET SESSION
    ############################################
    $CollectionName = 'Sessions'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Network, Hunt" 
        Command_RPC_PoSh     = $null
        #Command_RPC_CMD      = "cmd /c net session \\" #net session \\hostname
        #Command_RPC_CMD_Arg  = $null
        Command_WMI          = $null #'Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "cmd /c net session > c:\results.txt"'
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { Get-SmbSession }"
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = "Invoke-Command -ScriptBlock { cmd /c net session }"
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = "winrs net session"
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *' 
        Properties_WMI       = 'PSComputerName, Status, Name, Path, Description' 
        Message              = "Gets network SMB sessions."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'Shares'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Network, Hunt, Charts" 
        #Command_RPC_CMD      = "cmd /c net view /ALL \\"
        #Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = 'Get-WmiObject -Class Win32_Share'
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { Get-SmbShare }"
        Command_WinRM_WMI    = "Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_Share }"
        #Command_WinRM_WMI    = "Invoke-Command -ScriptBlock { cmd /c wmic share }"
        Command_WinRM_CMD    = "Invoke-Command -ScriptBlock { cmd /c net view /ALL }"
        Command_WinRS_WMIC   = "winrs wmic share"
        Command_WinRS_CMD    = "winrs net share"
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *' 
        Properties_WMI       = 'PSComputerName, Status, Name, Path, Description' 
        Message              = "Gets network shares. The 'net share' command is used to manage file/printer shares."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'Software Installed'
    $CommandScript = @'

            # This script gets the software installed by using the registry    
            Function Get-Software  {
                [OutputType('System.Software.Inventory')]
                [Cmdletbinding()] 
                Param( 
                    [Parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)] 
                    [String[]]$Computername=$env:COMPUTERNAME
                )         
                Begin {}
                Process  {
                    $Paths  = @("SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall","SOFTWARE\\Wow6432node\\Microsoft\\Windows\\CurrentVersion\\Uninstall")         
                    ForEach($Path in $Paths) { 
                    Write-Verbose  "Checking Path: $Path"
                    #  Create an instance of the Registry Object and open the HKLM base key 
                    Try  {$reg=[microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine',$Computername,'Registry64')} 
                    Catch  {Write-Error $_ ; Continue} 
                    #  Drill down into the Uninstall key using the OpenSubKey Method 
                    Try  {
                        $regkey=$reg.OpenSubKey($Path)  
                        # Retrieve an array of string that contain all the subkey names 
                        $subkeys=$regkey.GetSubKeyNames()      
                        # Open each Subkey and use GetValue Method to return the required  values for each 
                        ForEach ($key in $subkeys){   
                            Write-Verbose "Key: $Key"
                            $thisKey=$Path+"\\"+$key 
                            Try {  
                                $thisSubKey=$reg.OpenSubKey($thisKey)   
                                # Prevent Objects with empty DisplayName 
                                $DisplayName =  $thisSubKey.getValue("DisplayName")
                                If ($DisplayName  -AND $DisplayName  -notmatch '^Update  for|rollup|^Security Update|^Service Pack|^HotFix') {
                                    $Date = $thisSubKey.GetValue('InstallDate')
                                    If ($Date) {
                                        Try {$Date = [datetime]::ParseExact($Date, 'yyyyMMdd', $Null)}
                                        Catch{Write-Warning "$($Computername): $_ <$($Date)>" ; $Date = $Null}
                                    } 
                                    # Create New Object with empty Properties 
                                    $Publisher =  Try {$thisSubKey.GetValue('Publisher').Trim()} 
                                        Catch {$thisSubKey.GetValue('Publisher')}
                                    $Version = Try {
                                        #Some weirdness with trailing [char]0 on some strings
                                        $thisSubKey.GetValue('DisplayVersion').TrimEnd(([char[]](32,0)))
                                    } 
                                        Catch {$thisSubKey.GetValue('DisplayVersion')}
                                    $UninstallString =  Try {$thisSubKey.GetValue('UninstallString').Trim()} 
                                        Catch {$thisSubKey.GetValue('UninstallString')}
                                    $InstallLocation =  Try {$thisSubKey.GetValue('InstallLocation').Trim()} 
                                        Catch {$thisSubKey.GetValue('InstallLocation')}
                                    $InstallSource =  Try {$thisSubKey.GetValue('InstallSource').Trim()} 
                                        Catch {$thisSubKey.GetValue('InstallSource')}
                                    $HelpLink = Try {$thisSubKey.GetValue('HelpLink').Trim()} 
                                        Catch {$thisSubKey.GetValue('HelpLink')}
                                    $Object = [pscustomobject]@{
                                        Computername = $Computername
                                        DisplayName = $DisplayName
                                        Version  = $Version
                                        InstallDate = $Date
                                        Publisher = $Publisher
                                        UninstallString = $UninstallString
                                        InstallLocation = $InstallLocation
                                        InstallSource  = $InstallSource
                                        HelpLink = $thisSubKey.GetValue('HelpLink')
                                        EstimatedSizeMB = [decimal]([math]::Round(($thisSubKey.GetValue('EstimatedSize')*1024)/1MB,2))
                                    }
                                    $Object.pstypenames.insert(0,'System.Software.Inventory')
                                        Write-Output $Object
                                    }
                                } 
                                Catch {Write-Warning "$Key : $_"}   
                            }
                        } 
                        Catch  {}   
                        $reg.Close() 
                    }                  
                } 
            } 
            Get-Software        
'@

    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = 'Software Installed'
        Type                 = "System, Hunt, Charts"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = 'Get-WmiObject -Class Win32_Product'
        Command_WinRM_Script = "Invoke-Command -ScriptBlock { $CommandScript }"
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = "Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_Product }"
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = 'winrs wmic product list brief'
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *' 
        Properties_WMI       = 'PSComputerName, Name, Vendor, Version, InstallDate, InstallDate2, InstallLocation, InstallSource, PackageName, PackageCache, RegOwner, HelpLink, HelpTelephone, URLInfoAbout, URLUpdateInfo, Language, Description, IdentifyingNumber' 
        Message              = "Gets installed software."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'Startup Commands'
    $CommandScript = @'

            Invoke-Command -ScriptBlock {
                $env:computername
                #$ErrorActionPreference = 'SilentlyContinue'

                $SHA256  = [System.Security.Cryptography.HashAlgorithm]::Create("SHA256")
                $MD5     = [System.Security.Cryptography.HashAlgorithm]::Create("MD5")
                $regkeys = @(
                'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run',
                'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run',
                'HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce',
                'HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce',
                'HKLM:\Software\Microsoft\Windows\CurrentVersion\RunServices',
                'HKLM:\Software\Microsoft\Windows\CurrentVersion\RunServicesOnce',
                'HCCU:\Software\Microsoft\Windows\Curre ntVersion\RunOnce\Setup',
                'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon',
                'HKLM:\Software\Microsoft\Active Setup\Installed Components',
                'HKLM:\System\CurrentControlSet\Servic es\VxD',
                'HKCU:\Control Panel\Desktop',
                'HKLM:\System\CurrentControlSet\Control\Session Manager',
                'HKLM:\System\CurrentControlSet\Services',
                'HKLM:\System\CurrentControlSet\Services\Winsock2\Parameters\Protocol_Catalog\Catalog_Entries',
                'HKLM:\System\Control\WOW\cmdline',
                'HKLM:\System\Control\WOW\wowcmdline',
                'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\Userinit',
                'HKLM:\Software\Microsoft\Windows\Curr entVersion\ShellServiceObjectDelayLoad',
                'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Windows\run',
                'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Windows\load',
                'HKCU:\Software\Microsoft\Windows\Curre ntVersion\Policies\Explorer\run',
                'HLKM:\Software\Microsoft\Windows\Curr entVersion\Policies\Explorer\run'
                )
                foreach ($key in $regkeys) {
                    $entry = Get-ItemProperty -Path $key
                    $entry = $entry | Select-Object * -ExcludeProperty PSPath,PSParentPath,PSChildName,PSDrive,PSProvider
                    #$entry.psobject.Properties |ft
                    foreach($item in $entry.PSObject.Properties) {
                        $value = $item.value.replace('"', '')
                        # The entry could be an actual path
                        if(Test-Path $value) {

                            $filebytes = [system.io.file]::ReadAllBytes($value)
                            $HashObject = New-Object PSObject -Property @{
                                Path = $value;
                                MD5    = [System.BitConverter]::ToString($md5.ComputeHash($filebytes)) -replace "-", "";
                                SHA256 = [System.BitConverter]::ToString($sha256.ComputeHash($filebytes)) -replace "-","";
                                Computer = $($env:computername)
                            }
                            $HashObject 
                        }
                    }
                }
            } | select Computer, MD5, SHA256, Path
'@
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "System, Hunt, Charts"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = 'Get-WmiObject -Class Win32_StartupCommand'
        Command_WinRM_Script = "Invoke-Command -ScriptBlock { $CommandScript }"
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = "Invoke-Command -ScriptBlock { Get-WmiObject -class Win32_StartupCommand }"
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = "winrs wmic startup list brief"
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *' 
        Properties_WMI       = 'PSComputerName, Name, Location, Command, User' 
        Message              = "Gets startup information."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'System Info'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "System, Network, Hardware"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = 'Get-WmiObject -Class Win32_ComputerSystem'
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = 'Invoke-Command -ScriptBlock { Get-ComputerInfo }'
        Command_WinRM_WMI    = 'Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_ComputerSystem }'
        Command_WinRM_CMD    = 'Invoke-Command -ScriptBlock { cmd /c systeminfo /fo csv }'
        Command_WinRS_WMIC   = "winrs wmic computersystem list brief"
#       Command_WinRS_WMIC   = "winrs wmic os list brief"
        Command_WinRS_CMD    = "winrs systeminfo /fo csv"
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *' 
        Properties_WMI       = 'PSComputerName, Description, Manufacturer, Model, SystemType, NumberOfProcessors, TotalPhysicalMemory, EnableDaylightSavingsTime, BootupState, PartOfDomain, Domain, Username, PrimaryOwnerName' 
        Message              = "GUI = msinfo32 ; Get-ComputerInfo is only avilable on WPF 5.1 ; Gets consolidated operating system information and properties."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'UEFI Secure Boot Policy'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Hardware" 
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = 'Invoke-Command -ScriptBlock { Get-SecureBootPolicy }'
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *' 
        Properties_WMI       = 'PSComputerName, *'
        Message              = "If the hardware supports Secure Boot, gets the publisher GUID and the policy version of the Secure Boot configuration policy. If enabled it will return True, otherwise False. If the hardware doesn't support UEFI Secure boot or is BIOS based, an not supported error will be displayed."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'UEFI Secure Boot Status'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Hardware" 
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = 'Invoke-Command -ScriptBlock { Confirm-SecureBootUEFI }'
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *' 
        Properties_WMI       = 'PSComputerName, *'
        Message              = "If the hardware supports UEFI Secure Boot, checks if it's enabled. If enabled it will return True, otherwise False. If the hardware doesn't support UEFI Secure boot or is BIOS based, an not supported error will be displayed."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'USB Controller Devices'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Hardware, System"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = 'Get-WmiObject -Class Win32_USBControllerDevice'
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = "Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_USBControllerDevice }"
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null #NOTE: 'wmic usbcontrollerdeivce' does not work
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *' 
        Properties_WMI       = 'PSComputerName, Name, Manufacturer, Status, Service, DeviceID, @{Name="HardwareID";Expression={$_.HardwareID}}' 
        Message              = "Gets USB information."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

<#
    $CollectionName = 'Valid Signatures (C:\Windows\System32)'
    $CommandScript = @'

        $Files  = Get-ChildItem -File C:\Windows\System32 -Recurse -Force
        $SHA256 = [System.Security.Cryptography.HashAlgorithm]::Create("SHA256")
        $MD5    = [System.Security.Cryptography.HashAlgorithm]::Create("MD5")

        foreach ($File in $Files) {
            #$filebytes = [system.io.file]::ReadAllBytes($File)
            
            #$HashMD5 = [System.BitConverter]::ToString($MD5.ComputeHash($filebytes)) -replace "-", ""
            #$File | Add-Member -NotePropertyName HashMD5 -NotePropertyValue $HashMD5
            $HashMD5 = $(Get-FileHash -Path $File.FullName -Algorithm MD5).Hash
            $File | Add-Member -NotePropertyName HashMD5 -NotePropertyValue $HashMD5
            
            #$HashSHA256 = [System.BitConverter]::ToString($SHA256.ComputeHash($filebytes)) -replace "-", ""
            #$File | Add-Member -NotePropertyName HashSHA256 -NotePropertyValue $HashSHA256
            $HashSHA256 = $(Get-FileHash -Path $File.FullName -Algorithm SHA256).Hash
            $File | Add-Member -NotePropertyName HashSHA256 -NotePropertyValue $HashSHA256
            
            $FileSignature = Get-AuthenticodeSignature -FilePath $File.FullName
            $Signercertificate = $FileSignature.SignerCertificate.Thumbprint
            $File | Add-Member -NotePropertyName SignerCertificate -NotePropertyValue $Signercertificate
            $Status = $FileSignature.Status
            $File | Add-Member -NotePropertyName Status -NotePropertyValue $Status
            $File | Select Name, HashMD5, HashSHA256, SignerCertificate, Status, CreationTime, LastAccessTime, LastWriteTime, Attributes, FullName
        }
'@

    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = 'File' 
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = "Invoke-Command -ScriptBlock { $CommandScript }"
        Command_WinRM_PoSh   = $null #"Invoke-Command -ScriptBlock { Get-ChildItem C:\windows\system32 -Recurse -File | Get-AuthenticodeSignature }"
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
# ... C:\Program Files  C:\Program Files (x86)  C:\pagefile.sys  
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, SignerCertificate, TimeStamperCertificate, Status, StatusMessage, Path, SignatureType, IsOSBinary'
        Properties_WMI       = 'PSComputerName, *'
        Message              = "Gets information about the digital signature of files in the C:\Windows\System32 directory."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }
#>
    $CollectionName = 'VMWare Detection'
    $CommandScript  = @'

            $VMwareDetected   = $False
            $VMNetworkAdapter = $(Get-WmiObject Win32_NetworkAdapter -Filter 'Manufacturer LIKE "%VMware%" OR Name LIKE "%VMware%"')
            $VMBios           = $(Get-WmiObject Win32_BIOS -Filter 'SerialNumber LIKE "%VMware%"')
            $VMWareService    = $(Get-Service | Where-Object {$_.Name -match "vmware" -and $_.Status -eq 'Running'} )
            $VMWareProcess    = $(Get-Process | Where-Object Name -match "vmware")
            $VMToolsProcess   = $(Get-Process | Where-Object Name -match "vmtoolsd")
            if($VMNetworkAdapter -or $VMBios -or $VMToolsProcess) { 
                $VMwareDetected = $True
            }
            [PSCustomObject]@{ 
                PSComputerName   = hostname
                Name             = 'VMWare Detection'
                VMWareDetected   = $VMwareDetected
                VMNetworkAdapter = $VMNetworkAdapter
                VMBIOS           = $VMBIOS
                VMWareService    = $VMWareService
                VMWareProcess    = $VMWareProcess
                VMToolsProcess   = $VMToolsProcess
            }

'@
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "System"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = "Invoke-Command -ScriptBlock { $CommandScript }"
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *'
        Properties_WMI       = 'PSComputerName, *'
        Message              = "Detects VMWare Product; either the host is a VMWare VM or is hosting VMs."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'Windows Side by Side (Count)'
    $CommandScript = @'

            # WinSxS is short of 'Windows Side by Side'. It is a folder in XP, Vista, 7, and 8 that stores different copies of DLL and system files.
            # These components are kept to rollback any problematic change or to repair a file that becomes corrupted.
            # Because programs can use the samm DLL file, this folder stores the different files for compatibility reasons.
            [PSCustomObject]@{ 
                Name           = 'Windows Side by Side (Count)'
                PSComputerName = hostname
                FileCount      = $((Get-ChildItem -Path 'C:\Windows\WinSxS').count)
            }
'@
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "File"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = "Invoke-Command -ScriptBlock { $CommandScript }"
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *'
        Properties_WMI       = 'PSComputerName, *'
        Message              = "Windows Side By Side (WinSxS), is a folder that stores different copies of DLL and system files. It stores different files for compatibility reasons and for times older versions need to be restored. Files within contain different versions, are needed for installation, backups, or updates. It's a space hog, taking up several gigabytes of space and growing with each Windows Update you perform. ou can't just delete everything in the WinSxS folder, because some of those files are needed for Windows to run and update reliably. However, with Windows 7 and above you can use the built-in Disk Cleanup tool to delete older versions of Windows updates you no longer need."
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }
 	
    # Related: Get-MpThreatCatalog 	Gets known threats from the definitions catalog.
    # Related: Get-MpThreat         Gets the history of threats detected on the computer
    # start-MpScan -ScanType [QuickScan|FullScan]
    # Start-MpScan -ScanPath C:\Users\<username>\Downloads

    $CollectionName = 'Windows Defender (Malware Detected)'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "System"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = 'Invoke-Command -ScriptBlock { Get-MpThreatDetection }'
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *'
        Properties_WMI       = 'PSComputerName, *'
        Message              = 'Gets active and past malware threats that Windows Defender detected.'
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'Windows Defender (Preferences)'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "System, Network"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = 'Invoke-Command -ScriptBlock { Get-MpPreference }'
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *'
        Properties_WMI       = 'PSComputerName, *'
        Message              = 'Gets preferences for the Windows Defender scans and updates.'
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }
    	
    $CollectionName = 'Windows Defender (Status)'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "System, Network"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = 'Invoke-Command -ScriptBlock { Get-MpComputerStatus }'
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *'
        Properties_WMI       = 'PSComputerName, *'
        Message              = 'Gets the status of anti-malware software on the computer.'
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'WSMan Trusted Hosts'
    $script:AllEndpointCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "System, Network"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = 'Invoke-Command -ScriptBlock { Get-Item WSMan:\localhost\Client\TrustedHosts }'
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *'
        Properties_WMI       = 'PSComputerName, *'
        Message              = 'The WS-Management TrustedHosts list is a list of trusted resources for your computer. The TrustedHosts list consists of a comma-separated list of computer names, IP addresses, and fully-qualified domain names. Only members of the Administrators group on the computer have permission to change the list of trusted hosts on the computer. For information about runningWindows PowerShell with administrator permissions, see How to Run as Administrator. To use the IP address of a remote computer in a Windows PowerShell command to connect to the remote computer, the IP address must be in the TrustedHosts list on your computer. This is a requirement of NTLM authentication, which is used whenever a computer is identified by the IP address instead of a computer name.'
        NotesPath            = "$CommandsHostDirectoryNotes\$CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

#===========================================================================================================================================
#     ___        __  _               ____  _                __                      ______                                          __    
#    /   | _____/ /_(_)   _____     / __ \(_)_______  _____/ /_____  _______  __   / ____/___  ____ ___  ____ ___  ____ _____  ____/ /____
#   / /| |/ ___/ __/ / | / / _ \   / / / / / ___/ _ \/ ___/ __/ __ \/ ___/ / / /  / /   / __ \/ __ `__ \/ __ `__ \/ __ `/ __ \/ __  / ___/
#  / ___ / /__/ /_/ /| |/ /  __/  / /_/ / / /  /  __/ /__/ /_/ /_/ / /  / /_/ /  / /___/ /_/ / / / / / / / / / / / /_/ / / / / /_/ (__  ) 
# /_/  |_\___/\__/_/ |___/\___/  /_____/_/_/   \___/\___/\__/\____/_/   \__, /   \____/\____/_/ /_/ /_/_/ /_/ /_/\__,_/_/ /_/\__,_/____/  
#                                                                      /____/                                                              
#==========================================================================================================================================
    $script:AllActiveDirectoryCommands = @()

    ### Win32_MemoryDevice
    ### Win32_ComputerSystemProcessor
    ### netstat -es
    ### tasklist /SVC /FO CSV
    ### tree
    ### auditpol /get /category:\*
    # dsquery * -filter "&(objectClass=person)(objectCategory=user)" -attr cn lastLogonTimestamp -limit 0

<# Command Template
    $CollectionName = 'AD Accounts (All Details and User Information)'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "User"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *'
        Properties_WMI       = 'PSComputerName, *'
        Message              = '_____________'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }
#>
    $CollectionName = 'AD Accounts (All Details and User Information)'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "User"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = "Get-WmiObject -Class Win32_UserAccount -Filter `"LocalAccount='False'`""
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = 'Invoke-Command -ScriptBlock { Get-ADUser -Filter * -Properties * }'
        Command_WinRM_WMI    = "Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_UserAccount -Filter `"LocalAccount='False'`" }" 
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = 'winrs wmic useraccount'
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, Name, CanonicalName, SID, Enabled, LockedOut, AccountLockoutTime, Created, LogonWorkStations, LastLogonDate, LastBadPasswordAttempt, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CannotChangePassword, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive, Title, Organization, Office, POBox, StreetAddress, City, State, PostalCode, Fax, OfficePhone, HomePhone, MobilePhone, EmailAddress'
        Properties_WMI       = 'PSComputerName, *'
        Message              = '_____________'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD Accounts (Logon and Passowrd Policy)'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "User"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = 'Invoke-Command -ScriptBlock { Get-ADUser -Filter * -Properties * }'
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, Name, Enabled, LockedOut, AccountLockoutTime, LogonWorkStations, LastLogonDate, LastBadPasswordAttempt, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CannotChangePassword'
        Properties_WMI       = 'PSComputerName, *'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD Accounts (Contact Information)'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "User"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = 'Invoke-Command -ScriptBlock { Get-ADUser -Filter * -Properties * }'
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, Name, Title, Organization, Office, POBox, StreetAddress, City, State, PostalCode, Fax, OfficePhone, HomePhone, MobilePhone, EmailAddress'
        Properties_WMI       = 'PSComputerName, *'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD Accounts (Disabled)'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "User"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = 'Invoke-Command -ScriptBlock { Search-ADAccount -AccountDisabled }'
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = 'Invoke-Command -ScriptBlock { cmd c\ dsquery user -disabled }'
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, Name, Enabled, LockedOut, LastLogonDate, AccountExpirationDate, PasswordExpired, PaswordNeverExpires, SID, SamAccountName, UserPrincipalName, DistinguishedName, ObjectClass, ObjectGUID'
        Properties_WMI       = 'PSComputerName, *'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD Accounts (Expired)'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "User"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = 'Invoke-Command -ScriptBlock { Search-ADAccount -AccountExpired }'
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, Name, Enabled, LockedOut, LastLogonDate, AccountExpirationDate, PasswordExpired, PaswordNeverExpires, SID, SamAccountName, UserPrincipalName, DistinguishedName, ObjectClass, ObjectGUID'
        Properties_WMI       = 'PSComputerName, *'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD Accounts (Inactive)'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "User"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = 'Invoke-Command -ScriptBlock { Search-ADAccount -AccountInactive }'
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = 'Invoke-Command -ScriptBlock { cmd c\ dsquery user domainroot -inactive 4 }' #Accounts That Are Inactive for Longer Than 4 Weeks
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, Name, Enabled, LockedOut, LastLogonDate, AccountExpirationDate, PasswordExpired, PaswordNeverExpires, SID, SamAccountName, UserPrincipalName, DistinguishedName, ObjectClass, ObjectGUID'
        Properties_WMI       = 'PSComputerName, *'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD Accounts (Locked Out)'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "User"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = 'Invoke-Command -ScriptBlock { Search-ADAccount -LockedOut }'
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, Name, Enabled, LockedOut, LastLogonDate, AccountExpirationDate, PasswordExpired, PaswordNeverExpires, SID, SamAccountName, UserPrincipalName, DistinguishedName, ObjectClass, ObjectGUID'
        Properties_WMI       = 'PSComputerName, *'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD Accounts (Created Within 30 Days)'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "User"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = 'Invoke-Command -ScriptBlock { $days = ((Get-Date).AddDays(-30)).Date ; Get-ADUser -Filter {whenCreated -ge $days} -Properties whenCreated }'
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = $null
        Command_WMI          = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, Name, Enabled, LockedOut, LastLogonDate, AccountExpirationDate, PasswordExpired, PaswordNeverExpires, SID, SamAccountName, UserPrincipalName, DistinguishedName, ObjectClass, ObjectGUID'
        Properties_WMI       = 'PSComputerName, *'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD Accounts (Password Last Set)'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "User"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = 'Invoke-Command -ScriptBlock { Get-ADUser -Filter * -Properties PasswordLastSet }'
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, Name, PasswordLastSet, Enabled, SamAccountName, SID'
        Properties_WMI       = 'PSComputerName, *'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD Accounts (Password Last Set Domain Admins)'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "User"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = 'Invoke-Command -ScriptBlock { Get-ADGroupMember -Identity "Domain Admins" | Get-ADUser -Properties PasswordLastSet }'
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, Name, PasswordLastSet, Enabled, SamAccountName, SID'
        Properties_WMI       = 'PSComputerName, *'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD Accounts (Password Never Expires)'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "User"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = 'Invoke-Command -ScriptBlock { Search-ADAccount -PasswordNeverExpires }'
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, Name, Enabled, LockedOut, LastLogonDate, AccountExpirationDate, PasswordExpired, PaswordNeverExpires, SID, SamAccountName, UserPrincipalName, DistinguishedName, ObjectClass, ObjectGUID'
        Properties_WMI       = 'PSComputerName, *'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD Domain Object Changes Made (Last 1 Hour)'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "User"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { `$StartDate = (Get-Date).AddHours(-1) ; Get-ADObject -Filter 'whenChanged -gt `$StartDate' -IncludeDeletedObjects -properties * | Sort-Object WhenCreated }"
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, Name, ObjectClass, WhenCreated, WhenChanged, Deleted, LastLogon, LogonCount, DistinguishedName, ObjectSID'
        Properties_WMI       = 'PSComputerName, *'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD Domain Object Changes Made (Last 8 Hours)'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "User"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { `$StartDate = (Get-Date).AddHours(-8) ; Get-ADObject -Filter 'whenChanged -gt `$StartDate' -IncludeDeletedObjects -properties * | Sort-Object WhenCreated }"
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, Name, ObjectClass, WhenCreated, WhenChanged, Deleted, LastLogon, LogonCount, DistinguishedName, ObjectSID'
        Properties_WMI       = 'PSComputerName, *'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD Domain Object Changes Made (Last 1 Day)'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "User"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { `$StartDate = (Get-Date).AddDays(-1) ; Get-ADObject -Filter 'whenChanged -gt `$StartDate' -IncludeDeletedObjects -properties * | Sort-Object WhenCreated }"
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, Name, ObjectClass, WhenCreated, WhenChanged, Deleted, LastLogon, LogonCount, DistinguishedName, ObjectSID'
        Properties_WMI       = 'PSComputerName, *'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD Domain Object Changes Made (Last 1 Week)'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "User"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { `$StartDate = (Get-Date).AddDays(-7) ; Get-ADObject -Filter 'whenChanged -gt `$StartDate' -IncludeDeletedObjects -properties * | Sort-Object WhenCreated }"
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, Name, ObjectClass, WhenCreated, WhenChanged, Deleted, LastLogon, LogonCount, DistinguishedName, ObjectSID'
        Properties_WMI       = 'PSComputerName, *'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD Domain Object Changes Made (Last 1 Month)'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "User"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { `$StartDate = (Get-Date).AddMonths(-1) ; Get-ADObject -Filter 'whenChanged -gt `$StartDate' -IncludeDeletedObjects -properties * | Sort-Object WhenCreated }"
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, Name, ObjectClass, WhenCreated, WhenChanged, Deleted, LastLogon, LogonCount, DistinguishedName, ObjectSID'
        Properties_WMI       = 'PSComputerName, *'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD Domain Object Creations (Last 1 Hour)'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "User"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { `$StartDate = (Get-Date).AddHours(-1) ; Get-ADObject -Filter 'WhenCreated -gt `$StartDate' -IncludeDeletedObjects -properties * | Sort-Object WhenCreated }"
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, Name, ObjectClass, WhenCreated, WhenChanged, Deleted, LastLogon, LogonCount, DistinguishedName, ObjectSID'
        Properties_WMI       = 'PSComputerName, *'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD Domain Object Creations (Last 8 Hours)'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "User"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { `$StartDate = (Get-Date).AddHours(-8) ; Get-ADObject -Filter 'WhenCreated -gt `$StartDate' -IncludeDeletedObjects -properties * | Sort-Object WhenCreated }"
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, Name, ObjectClass, WhenCreated, WhenChanged, Deleted, LastLogon, LogonCount, DistinguishedName, ObjectSID'
        Properties_WMI       = 'PSComputerName, *'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD Domain Object Creations (Last 1 Day)'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "User"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { `$StartDate = (Get-Date).AddDays(-1) ; Get-ADObject -Filter 'WhenCreated -gt `$StartDate' -IncludeDeletedObjects -properties * | Sort-Object WhenCreated }"
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, Name, ObjectClass, WhenCreated, WhenChanged, Deleted, LastLogon, LogonCount, DistinguishedName, ObjectSID'
        Properties_WMI       = 'PSComputerName, *'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD Domain Object Creations (Last 1 Week)'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "User"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { `$StartDate = (Get-Date).AddDays(-7) ; Get-ADObject -Filter 'WhenCreated -gt `$StartDate' -IncludeDeletedObjects -properties * | Sort-Object WhenCreated }"
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, Name, ObjectClass, WhenCreated, WhenChanged, Deleted, LastLogon, LogonCount, DistinguishedName, ObjectSID'
        Properties_WMI       = 'PSComputerName, *'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD Domain Object Creations (Last 1 Month)'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "User"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { `$StartDate = (Get-Date).AddMonths(-1) ; Get-ADObject -Filter 'WhenCreated -gt `$StartDate' -IncludeDeletedObjects -properties * | Sort-Object WhenCreated }"
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, Name, ObjectClass, WhenCreated, WhenChanged, Deleted, LastLogon, LogonCount, DistinguishedName, ObjectSID'
        Properties_WMI       = 'PSComputerName, *'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD Domain Controllers (All of them)'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Domain"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = 'Invoke-Command -ScriptBlock { cmd c\ netdom query DC }'
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = $null
        Properties_WMI       = 'PSComputerName, *'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }
    # if you prefer host names only
    # DSQUERY Server -o rdn

    $CollectionName = 'AD Domain Controllers (Primary)'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Domain"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = 'Invoke-Command -ScriptBlock { cmd c\ netdom query PDC }'
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = $null
        Properties_WMI       = 'PSComputerName, *'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD Domain Controllers (That are Global Catalogs)'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Domain"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = 'Invoke-Command -ScriptBlock { cmd c\ dsquery server | dsget server -dnsname -site -isgc }'
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = $null
        Properties_WMI       = 'PSComputerName, *'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD Domain Controllers (Read Only Domain Controllers [RODC])'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Domain"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = 'Invoke-Command -ScriptBlock { cmd c\ dsquery server -isreadonly }'
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = $null
        Properties_WMI       = 'PSComputerName, *'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD Domain FSMO Roles'
    $CommandScript = @'

            [PSCustomObject]@{ 
                Name                 = 'FSMORoles'
                InfrastructureMaster = $(Get-ADDomain | Select-Object -ExpandProperty InfrastructureMaster)
                PDCEmulator          = $(Get-ADDomain | Select-Object -ExpandProperty PDCEmulator)
                RIDMaster            = $(Get-ADDomain | Select-Object -ExpandProperty RIDMaster)
                SchemaMaster         = $(Get-ADForest | Select-Object -ExpandProperty SchemaMaster)
                DomainNamingMaster   = $(Get-ADForest | Select-Object -ExpandProperty DomainNamingMaster)
            } | Select-Object @{name="PSComputerName";expression={hostname}}, Name, InfrastructureMaster, PDCEmulator, RIDMaster, SchemaMaster, DomainNamingMaster
'@
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Domain"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = "Invoke-Command -ScriptBlock { $CommandScript }"
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = 'Invoke-Command -ScriptBlock { cmd c\ netdom query FSMO }'
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = $null
        Properties_WMI       = 'PSComputerName, *'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }
    
    $CollectionName = 'AD Domain FSMO (Schema Master in Forest)'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Domain"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = 'Invoke-Command -ScriptBlock { Get-ADForest }'
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = 'Invoke-Command -ScriptBlock { cmd c\ dsquery server -forest -hasfsmo Schema }'
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, SchemaMaster'
        Properties_WMI       = 'PSComputerName, *'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD Domain FSMO (Domain Naming Master)'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Domain"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = 'Invoke-Command -ScriptBlock { Get-ADForest }'
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = 'Invoke-Command -ScriptBlock { cmd c\ dsquery server -forest -hasfsmo Name }'
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, DomainNamingMaster'
        Properties_WMI       = 'PSComputerName, *'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD Domain FSMO (Primary Domain Controller)'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Domain"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = 'Invoke-Command -ScriptBlock { Get-ADDomain }'
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = 'Invoke-Command -ScriptBlock { cmd c\ dsquery server -hasfsmo PDC }'
    #    Command_WinRM_CMD    = 'Invoke-Command -ScriptBlock { cmd c\ netdom query PDC }'
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, PDCEmulator'
        Properties_WMI       = 'PSComputerName, *'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD Domain FSMO (RID Master)'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Domain"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = 'Invoke-Command -ScriptBlock { Get-ADDomain }'
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = 'Invoke-Command -ScriptBlock { cmd c\ dsquery server -hasfsmo RID }'
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, RIDMaster'
        Properties_WMI       = 'PSComputerName, *'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD Domain FSMO (Infrastructure Master)'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Domain"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = 'Invoke-Command -ScriptBlock { Get-ADDomain }'
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = 'Invoke-Command -ScriptBlock { cmd c\ dsquery server -hasfsmo INFR }'
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, InfrastructureMaster'
        Properties_WMI       = 'PSComputerName, *'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD Domain Organizationation Units (OUs)'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Domain"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = 'Invoke-Command -ScriptBlock { cmd c\ netdom query OU }'
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = $null
        Properties_WMI       = 'PSComputerName, *'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD Domain Servers (All of them)'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Domain"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = 'Invoke-Command -ScriptBlock { cmd c\ netdom query server }'
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = $null
        Properties_WMI       = 'PSComputerName, *'
        Message              = 'Lists all domain joined servers.'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD Domain Sites'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Domain"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = 'Invoke-Command -ScriptBlock { cmd c\ dsquery site -name * -limit 0 }'
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = $null
        Properties_WMI       = 'PSComputerName, *'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD Domain Trusts'
    $CommandScript = @'

            Function Get-ADTrustsInfo {
                <#
                .SYNOPSIS
                    Query AD for all trusts in the specified domain and check their state.
                .DESCRIPTION
                    This cmdlet query AD and return a custom object with informations suach as the trust name, the creation date, the last modification date, the direction, the type, the SID of the trusted domain, the trusts attributes, and the trust state.
                #>
                [cmdletbinding()]
                param(
                    [Parameter(Mandatory=$false,
                        HelpMessage='Provide a domain name !')]
                    [ValidateScript({Test-Connection $_ -Count 1 -Quiet})]
                    [String]$DomainName=$env:USERDNSDOMAIN
                )
                Begin{
                }
                Process{
                    $searcher=[ADSIsearcher]"(objectclass=trustedDomain)"
                    $searcher.searchroot.Path="LDAP://$DomainName"
                    $searcher.PropertiesToLoad.AddRange(('whenChanged','whenCreated','trustPartner','trustAttributes','trustDirection','trustType','securityIdentifier')) | Out-Null
                    Write-Verbose "Searching in AD for trusts..."
                    try {
                        $trusts=$searcher.FindAll()
                        $trusts | % {
                            switch ($_.Properties.trustdirection)
                            {
                                 1 {$TrustDirection="Inbound"}
                                 2 {$TrustDirection="Outbound"}
                                 3 {$TrustDirection="Bidirectional"}
                                 default {$TrustDirection="N/A"}
                            }
                            switch ($_.Properties.trusttype)
                            {
                                1 {$TrustType="Windows NT"} #Downlevel (2000 et inférieur)
                                2 {$TrustType="Active Directory"}#Uplevel (2003 et supérieur)
                                3 {$TrustType="Kerberos realm"}#Not AD Based
                                4 {$TrustType="DCE"}
                                default {$TrustType="N/A"}
                            }
                            #Convertion du System.Byte[] en SID lisible.
                            Write-Verbose "Converting the SID..."
                            $SID=(New-Object -TypeName System.Security.Principal.SecurityIdentifier -ArgumentList $_.properties.securityidentifier[0], 0).value
                            Write-Verbose "Querying WMI..."
                            $wmitrust=Get-WmiObject -namespace "root/MicrosoftActiveDirectory" -class Microsoft_DomainTrustStatus -ComputerName $DomainName -Filter "SID='$SID'"
                
                            [String[]]$TrustAttributes=$null
                            if([int32]$_.properties.trustattributes[0] -band 0x00000001){$TrustAttributes+="Non Transitive"}
                            if([int32]$_.properties.trustattributes[0] -band 0x00000002){$TrustAttributes+="UpLevel"}
                            if([int32]$_.properties.trustattributes[0] -band 0x00000004){$TrustAttributes+="Quarantaine"} #SID Filtering
                            if([int32]$_.properties.trustattributes[0] -band 0x00000008){$TrustAttributes+="Forest Transitive"}
                            if([int32]$_.properties.trustattributes[0] -band 0x00000010){$TrustAttributes+="Cross Organization"}#Selective Auth
                            if([int32]$_.properties.trustattributes[0] -band 0x00000020){$TrustAttributes+="Within Forest"}
                            if([int32]$_.properties.trustattributes[0] -band 0x00000040){$TrustAttributes+="Treat as External"}
                            if([int32]$_.properties.trustattributes[0] -band 0x00000080){$TrustAttributes+="Uses RC4 Encryption"}
                            #http://msdn.microsoft.com/en-us/library/cc223779.aspx
                            Write-Verbose "Constructing object..."
                            $Object = New-Object PSObject -Property @{
                                'TrustName'      = $($_.Properties.trustpartner)
                                'Created'        = $($_.Properties.whencreated)
                                'LastChanged'    = $($_.Properties.whenchanged)
                                'Direction'      = $TrustDirection
                                'Type'           = $TrustType
                                'DomainSID'      = $SID
                                'Status'         = $wmitrust.TrustStatusString
                                'Attributes'     = $TrustAttributes -join ','
                            }#End object
                            Write-Output $Object
                        }#End trusts %
                    }catch {Write-Warning "$_" }
                }#End process
                End{
                }
            } 
            Get-ADTrustsInfo | Select @{name="PSComputerName";expression={hostname}}, Created, TrustName, Type, Direction, Attributes, LastChanged, Status, DomainSID
'@
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Domain"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = 'Get-WmiObject -Class Microsoft_DomainTrustStatus -Namespace ROOT\MicrosoftActiveDirectory'
        Command_WinRM_Script = "Invoke-Command -ScriptBlock { $CommandScript }"
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = 'Invoke-Command -ScriptBlock { Get-WmiObject -Class Microsoft_DomainTrustStatus -Namespace ROOT\MicrosoftActiveDirectory }'
        Command_WinRM_CMD    = 'Invoke-Command -ScriptBlock { cmd c\ netdom query TRUST }'
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, TrustedDomain, TrustAttributes, TrustDirection, TrustType'
        Properties_WMI       = 'PSComputername, TrustedDomain, TrustAttributes, TrustDirection, TrustType'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }
    <#
    TrustedAttributes = Direction of Trust
        1 = Non-Transitive
        2 = Transitive
    TrustedDirection = Direction of Trust
        1 = Incoming only
        2 = Outgoing only
        3 = Two-way
    #>
    $CollectionName = 'AD Domain Workstations (All of them)'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Domain"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = 'Invoke-Command -ScriptBlock { cmd c\ netdom query workstation }'
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = $null
        Properties_WMI       = 'PSComputerName, *'
        Message              = 'Lists all domain joined workstations.'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD Group (Primary Group is Domain Computers)'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Domain"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = 'Invoke-Command -ScriptBlock { cmd c\ dsquery * -filter "(primaryGroupID=515)" -limit 0 }'
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = $null
        Properties_WMI       = 'PSComputerName, *'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD Group (Primary Group is Domain Controllers)'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Domain"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = 'Invoke-Command -ScriptBlock { cmd c\ dsquery * -filter "(primaryGroupID=516)" -limit 0 }'
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = $null
        Properties_WMI       = 'PSComputerName, *'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD Group (Primary Group is Domain Users)'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Domain"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = 'Invoke-Command -ScriptBlock { cmd c\ dsquery * -filter "(primaryGroupID=513)" -limit 0 }'
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = $null
        Properties_WMI       = 'PSComputerName, *'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD Group (Primary Group is Guests)'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Domain"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = 'Invoke-Command -ScriptBlock { cmd c\ dsquery * -filter "(primaryGroupID=514)" -limit 0 }'
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = $null
        Properties_WMI       = 'PSComputerName, *'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD Get All Object Classes'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Domain"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = 'Invoke-Command -ScriptBlock { Get-AdObject -Filter * }'
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *'
        Properties_WMI       = 'PSComputerName, *'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }  

    $CollectionName = 'AD Computers (Details and OS Info)'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "User"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = 'Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties * }'
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, Enabled, Name, OperatingSystem, OperatingSystemServicePack, OperatingSystemHotfix, OperatingSystemVersion, IPv4Address, IPv6Address, LogonCount, LastLogonDate, WhenCreated, WhenChanged, Location, ObjectClass, SID, SIDHistory, DistinguishedName, DNSHostName, SamAccountName, CannotChangePassword'
        Properties_WMI       = 'PSComputerName, *'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }
                    
    $CollectionName = 'AD Default Domain Password Policy'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "User"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = 'Invoke-Command -ScriptBlock { Get-ADDefaultDomainPasswordPolicy }'
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *'
        Properties_WMI       = 'PSComputerName, *'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD Groups'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "User"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = "Get-WmiObject -Class Win32_Group -Filter `"LocalAccount='False'`""
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = 'Invoke-Command -ScriptBlock { Get-ADGroup -Filter * -Properties *}'
        Command_WinRM_WMI    = "Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_Group -Filter `"LocalAccount='False'`" }"
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, Name, SID, SIDHistory, GroupCategory, GroupScope, @{n="Member"; e={($_.Members -replace "CN=","`nCN=") }}, Members, MemberOf, WhenCreated, WhenChanged, DistinguishedName, Description, ProtectedFromAccidentalDeletion'
        Properties_WMI       = 'PSComputerName, Name, Domain, SID, SIDType, Caption, Description'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    # find all members for a particular group
    # dsget group "<group>" -members
    # find all groups for a particular member
    # dsget user "<DN of user>" -memberof -expand
    # get the groups name from user container
    # dsquery group -o rdn cn=users,dc=contoso.dc=com
    # get the members from a group
    # dsquery group-samid "CS_CLUB_ACCOUNTS" | dsget group -members -expand | dsget user -samid
    # find all members for a OU
    # dsquery user ou=targetOU,dc=domain,dc=com
    # find all groups for a OU
    # dsquery group ou=targetOU,dc=domain,dc=com

    $CollectionName = 'AD Group Membership by Groups'
    $CommandScript = @'

            $ADGroupList  = @()
            $ADGroupNames = Get-ADGroup -Filter * | Select-Object -ExpandProperty Name
            foreach ($Group in $ADGroupNames) {
                $GroupMembers = Get-ADGroupMember $Group | Select -ExpandProperty Name
                foreach ($Member in $GroupMembers) {
                    $AdGroupList += [PSCustomObject]@{Group=$Group;Member=$Member}
                }
            } 
            return $ADGroupList
'@
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "User"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = "Invoke-Command -ScriptBlock { $CommandScript }"
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = $null
        Properties_WMI       = 'PSComputerName, *'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD Group Membership by Users'
    $CommandScript = {
        $ADUserList = Get-ADUser -filter * | Select-Object -ExpandProperty SamAccountName
        foreach ($SamAccountName in $ADUserList) {                        
            $GroupMemberships = Get-ADPrincipalGroupMembership -Identity $SamAccountName
            $GroupMemberships | Add-Member -MemberType NoteProperty -Name SamAccountName = $SamAccountName -Force
            $GroupMemberships | Select-Object -Property SamAccountName, @{Name="Group Name";Expression={$_.Name}}, SID, GroupCategory, GroupScope, DistinguishedName
        } 
    }
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "User"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = "Invoke-Command -ScriptBlock { $CommandScript }"
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = $null
        Properties_WMI       = 'PSComputerName, *'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }


    $CollectionName = 'AD Groups Without Account Members'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "User"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = $null
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = 'Invoke-Command -ScriptBlock { Get-ADGroup -filter * | Where-Object {-Not ($_ | Get-ADGroupMember)} }'
        Command_WinRM_WMI    = $null
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, Name, ObjectClass, DistinguishedName, GroupCategory, GroupScope, ObjectGUID, SamAccountName, SID'
        Properties_WMI       = 'PSComputerName, *'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }
   
    # The block list automatically applies to all zones for which the server is authoritative. For example, if the DNS server is authoritative for contoso.com and for europe.contoso.com, it ignores queries for wpad.contoso.com as well as for wpad.europe.contoso.com. However, the DNS Server service does not ignore queries for names in zones for which it is not authoritative. 
    # dnscmd /info /globalqueryblocklist

    $CollectionName = 'AD DNS All Records (Server 2008)'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Network"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = "Get-WmiObject -Namespace root\MicrosoftDNS -class microsoftdns_resourcerecord"
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = "Invoke-Command -ScriptBlock { Get-WmiObject -Namespace root\MicrosoftDNS -class microsoftdns_resourcerecord }"
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *'
        Properties_WMI       = 'PSComputerName, __Class, ContainerName, DomainName, RecordData, OwnerName'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD DNS Root Hints (Server 2008)'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Network"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = "Get-WmiObject -Namespace root\MicrosoftDNS -class microsoftdns_resourcerecord"
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = "Invoke-Command -ScriptBlock { Get-WmiObject -Namespace root\MicrosoftDNS -class microsoftdns_resourcerecord | Where-Object {`$_.domainname -eq '..roothints'} }"
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *'
        Properties_WMI       = 'PSComputerName, *'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD DNS Zones (Server 2008)'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Network"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = "Get-WmiObject -Namespace 'root\MicrosoftDNS' -Class MicrosoftDNS_Zone"
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = "Invoke-Command -ScriptBlock { Get-WmiObject -Namespace 'root\MicrosoftDNS' -Class MicrosoftDNS_Zone }"
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = $null
        Properties_WMI       = '@{name="PSComputerName";expression={hostname}}, *'
        Message              = 'PSComputerName, Name'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD DNS Statistics (Server 2008)'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Network"
        Command_RPC_CMD      = $null
        Command_RPC_CMD_Arg  = $null
        Command_RPC_PoSh     = $null
        Command_WMI          = "Get-WmiObject -Namespace root\MicrosoftDNS -Class MicrosoftDNS_Statistic"
        Command_WinRM_Script = $null
        Command_WinRM_PoSh   = $null
        Command_WinRM_WMI    = "Invoke-Command -ScriptBlock { Get-WmiObject -Namespace root\MicrosoftDNS -Class MicrosoftDNS_Statistic }"
        Command_WinRM_CMD    = $null
        Command_WinRS_WMIC   = $null
        Command_WinRS_CMD    = $null
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *'
        Properties_WMI       = 'PSComputerName, Name, Value'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

<#
    DNS Server Statistics NOT included
        RecursionStatistics
        DnsSecStatistics
        MasterStatistics
        SecondaryStatistics
        WinsStatistics
        UpdateStatistics
#>
    $CollectionName = 'AD DNS Server Statistics (Time)'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Network"
        Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { Get-DnsServerStatistics | Select -ExpandProperty TimeStatistics }"
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, LastClearTime, ServerStartTime, TimeElapsedSinceLastClearedStatistics, TimeElapsedSinceLastClearedStatisticsBetweenRestart, TimeElapsedSinceServerStart, TimeElapsedSinceServerStartBetweenRestart'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }
    
    $CollectionName = 'AD DNS Server Statistics (Query 1)'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Network"
        Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { Get-DnsServerStatistics | Select -ExpandProperty QueryStatistics }"
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, TcpClientConnections, TcpQueries, TcpQueriesSent, TcpResponses, TcpResponsesReceived, UdpQueries, UdpQueriesSent, UdpResponses, UdpResponsesReceived'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD DNS Server Statistics (Query 2)'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Network"
        Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { Get-DnsServerStatistics | Select -ExpandProperty Query2Statistics }"
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, Notify, Standard, TKeyNego, TotalQueries, TypeA, TypeAll, TypeAxfr, TypeIxfr, TypeMx, TypeNs, TypeOther, TypePtr, TypeSoa, TypeSrv, Update'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

<#
    Get-DnsServer -expanded NOT included
        ServerDsSetting      # Get-DnsServerDsSetting 
        ServerCache
        ServerEdns        
#>
    $CollectionName = 'AD DNS Server Global Query Block List'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Network"
        Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { Get-DnsServerGlobalQueryBlockList }"
        #Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { Get-DnsServer | Select -ExpandProperty ServerGlobalQueryBlockList }"
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, Enabled, List'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD DNS Server Global Name Zone'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Network"
        Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { Get-DnsServerGlobalNameZone }"
        #Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { Get-DnsServer | Select -ExpandProperty ServerGlobalNameZone }"
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, Enable, GlobalOverLocal, PreferAAAA, AlwaysQueryServer, EnableEDnsProbes, BlockUpdates, SendTimeout, ServerQueryInterval'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD DNS Server Forwarder'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Network"
        Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { Get-DnsServerForwarder }"
        #Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { Get-DnsServer | Select -ExpandProperty ServerForwarder }"
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, UseRootHint, Timeout, EnableReordering, IPAddress, ReorderedIPAddress'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD DNS Server Diagnostics'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Network"
        Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { Get-DnsServerDiagnostics }"
        #Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { Get-DnsServer | Select -ExpandProperty ServerDiagnostics }"
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, SaveLogsToPersistentStorage, Queries, Answers, Notifications, Update, QuestionTransactions, UnmatchedResponse, SendPackets, ReceivePackets, TcpPackets, UdpPackets, FullPackets, FilterIPAddressList, EventLogLevel, UseSystemEventLog, EnableLoggingToFile, EnableLogFileRollover, LogFilePath, MaxMBFileSize, WriteThrough, EnableLoggingForLocalLookupEvent, EnableLoggingForPluginDllEvent, EnableLoggingForRecursiveLookupEvent, EnableLoggingForRemoteServerEvent, EnableLoggingForServerStartStopEvent, EnableLoggingForTombstoneEvent, EnableLoggingForZoneDataWriteEvent, EnableLoggingForZoneLoadingEvent'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }
    
    $CollectionName = 'AD DNS Server Scavenging'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Network"
        Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { Get-DnsServerScavenging }"
        #Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { Get-DnsServer | Select -ExpandProperty ServerScavenging }"
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, NoRefreshInterval, RefreshInterval, ScavengingInterval, ScavengingState, LastScavengeTime'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD DNS Server Settings'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Network"
        Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { Get-DnsServerSetting }"
        #Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { Get-DnsServer | Select -ExpandProperty ServerSetting }"
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, ComputerName, MajorVersion, MinorVersion, BuildNumber, IsReadOnlyDC, EnableDnsSec, EnableIPv6, ListeningIPAddress, AllIPAddress'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD DNS Server RootHints'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Network"
        Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { Get-DnsServerRecursion }"
        #Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { Get-DnsServer | Select -ExpandProperty ServerRecursion }"
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, Enable, AdditionalTimeout, RetryInterval, Timeout, SecureResponse'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD DNS Server RootHints'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Network"
        Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { Get-DNSServerRootHint }"
        #Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { Get-DnsServer | Select -ExpandProperty ServerRootHint }"
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, *'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }
    
    $CollectionName = 'AD DNS Server Zone'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Network"
        Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { Get-DnsServerZone }"
        #Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { Get-DnsServer | Select -ExpandProperty ServerZone }"
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, ZoneName, ZoneType, IsAutoCreated, IsDsIntegrated, IsReverseLookupZone, IsSigned'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD DNS Server Zone Aging'
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = "Network"
        Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { Get-DnsServer | Select -ExpandProperty ServerZoneAging }"
        #Command_WinRM_PoSh   = "Invoke-Command -ScriptBlock { Get-DnsServerZoneAging }" #Requies name input
        Properties_PoSh      = '@{name="PSComputerName";expression={hostname}}, ZoneName, AgingEnabled, AvailForScavengeTime, RefreshInterval, NoRefreshInterval, ScavengeServers'
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

    $CollectionName = 'AD Organizational Unit (OU) Permissions'
    $CommandScript = @'

            # This array will hold the report output.
            $report = @()

            $schemaIDGUID = @{}
            ### NEED TO RECONCILE THE CONFLICTS ###
            $ErrorActionPreference = 'SilentlyContinue'
            Get-ADObject -SearchBase (Get-ADRootDSE).schemaNamingContext -LDAPFilter '(schemaIDGUID=*)' -Properties name, schemaIDGUID |
             ForEach-Object {$schemaIDGUID.add([System.GUID]$_.schemaIDGUID,$_.name)}
            Get-ADObject -SearchBase "CN=Extended-Rights,$((Get-ADRootDSE).configurationNamingContext)" -LDAPFilter '(objectClass=controlAccessRight)' -Properties name, rightsGUID |
             ForEach-Object {$schemaIDGUID.add([System.GUID]$_.rightsGUID,$_.name)}
            $ErrorActionPreference = 'Continue'

            # Get a list of all OUs.  Add in the root containers for good measure (users, computers, etc.).
            $OUs  = @(Get-ADDomain | Select-Object -ExpandProperty DistinguishedName)
            $OUs += Get-ADOrganizationalUnit -Filter * | Select-Object -ExpandProperty DistinguishedName
            $OUs += Get-ADObject -SearchBase (Get-ADDomain).DistinguishedName -SearchScope OneLevel -LDAPFilter '(objectClass=container)' | Select-Object -ExpandProperty DistinguishedName

            # Loop through each of the OUs and retrieve their permissions.
            # Add report columns to contain the OU path and string names of the ObjectTypes.
            ForEach ($OU in $OUs) {
                $report += Get-Acl -Path "AD:\$OU" |
                 Select-Object -ExpandProperty Access | 
                 Select-Object @{name='organizationalUnit';expression={$OU}}, `
                               @{name='objectTypeName';expression={if ($_.objectType.ToString() -eq '00000000-0000-0000-0000-000000000000') {'All'} Else {$schemaIDGUID.Item($_.objectType)}}}, `
                               @{name='inheritedObjectTypeName';expression={$schemaIDGUID.Item($_.inheritedObjectType)}}, `
                               *
            }
            $report | Select OrganizationalUnit, IdentityReference, ObjectTypeName, InheritedObjectTypeName, ActiveDirectoryRights, InheritanceType, AccessControlType, IsInherited, InheritanceFlags, ProgationFlags, ObjectType, InheritedObjectType, ObjectFlags

            <# 
            # Various reports of interest

            # Show only explicitly assigned permissions by Group and OU
            $report |
             Where-Object {-not $_.IsInherited} |
             Select-Object IdentityReference, OrganizationalUnit -Unique |
             Sort-Object IdentityReference

            # Show explicitly assigned permissions for a user or group
            $filter = Read-Host "Enter the user or group name to search in OU permissions"
            $report |
             Where-Object {$_.IdentityReference -like "*$filter*"} |
             Select-Object IdentityReference, OrganizationalUnit, IsInherited -Unique |
             Sort-Object IdentityReference 
             #>
'@    
    $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
        Name                 = $CollectionName
        Type                 = ""
        Command_WinRM_Script = "Invoke-Command -ScriptBlock { $CommandScript }"
        Message              = '_____'
        NotesPath            = "$CommandsHostDirectoryNotes\ADDS - $CollectionName.txt"
        ExportFileName       = "$CollectionName"
    }

#======================================================================
#   ______             _    ___                 ______          __   
#  /_  __/_______  ___| |  / (_)__ _      __   / ____/___  ____/ /__ 
#   / / / ___/ _ \/ _ \ | / / / _ \ | /| / /  / /   / __ \/ __  / _ \
#  / / / /  /  __/  __/ |/ / /  __/ |/ |/ /  / /___/ /_/ / /_/ /  __/
# /_/ /_/   \___/\___/|___/_/\___/|__/|__/   \____/\____/\__,_/\___/ 
#
#======================================================================
function Conduct-NodeAction {
    param($TreeView)
    # This will return data on hosts selected/highlight, but not necessarily checked
    [System.Windows.Forms.TreeNodeCollection]$AllNodes = $TreeView
    foreach ($root in $AllNodes) { 
        $EntryNodeCheckedCountforRoot = 0
        if ($root.Checked) { 
            $Root.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
            $Root.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
            $Root.Expand()
            foreach ($Category in $root.Nodes) { 
                $Category.Expand()
                $Category.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
                $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                foreach ($Entry in $Category.nodes) {
                    $Entry.Checked   = $True
                    $Entry.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
                    $Entry.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                }          
            }
        }
        if ($root.isselected) { 
            $script:HostQueryTreeViewSelected = ""
            $StatusListBox.Items.clear()
            $StatusListBox.Items.Add("Category:  $($root.Text)")
            $ResultsListBox.Items.Clear()
            $ResultsListBox.Items.Add("- Checkbox This Node to Execute All Commands Within")

            # Brings the Host Data Tab to the forefront/front view
            $Section4TabControl.SelectedTab   = $Section3ResultsTab
        }
        foreach ($Category in $root.Nodes) { 
            $EntryNodeCheckedCountforCategory = 0
            if ($Category.checked) {
                $Category.Expand()
                $Category.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
                $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                $Root.NodeFont      = New-Object System.Drawing.Font("$Font",10,1,1,1)
                $Root.ForeColor     = [System.Drawing.Color]::FromArgb(0,0,0,224)
                foreach ($Entry in $Category.nodes) {
                    $EntryNodeCheckedCountforCategory += 1
                    $EntryNodeCheckedCountforRoot     += 1
                    $Entry.Checked   = $True
                    $Entry.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
                    $Entry.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                }            
            }
            elseif (!($Category.checked)) {
                foreach ($Entry in $Category.nodes) { 
                    #if ($Entry.isselected) { 
                    if ($Entry.checked) {
                        $EntryNodeCheckedCountforCategory += 1
                        $EntryNodeCheckedCountforRoot     += 1
                        $Entry.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
                        $Entry.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                    }
                    elseif (!($Entry.checked)) { 
                        if ($CategoryCheck -eq $False) {$Category.Checked = $False}
                        $Entry.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
                        $Entry.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
                    }            
                }        
            }            
            if ($Category.isselected) { 
                $script:HostQueryTreeViewSelected = ""
                $StatusListBox.Items.clear()
                $StatusListBox.Items.Add("Category:  $($Category.Text)")
                $ResultsListBox.Items.Clear()
                $ResultsListBox.Items.Add("- Checkbox This Node to Execute All Commands Within")

                # Brings the Host Data Tab to the forefront/front view
                $Section4TabControl.SelectedTab   = $Section3ResultsTab
            }
            foreach ($Entry in $Category.nodes) { 
                if ($Entry.isselected) {
                    $script:HostQueryTreeViewSelected = $Entry.Text
                    $StatusListBox.Items.clear()
                    $StatusListBox.Items.Add("Hostname/IP:  $($Entry.Text)")
                    $ResultsListBox.Items.clear()
                    $ResultsListBox.Items.Add("$((($Entry.Text) -split ' -- ')[-1])")
                    
                    #$CommandNotes = Get-Content -Path $($script:AllEndpointCommands | Where-Object Name -match $((($Entry.Text) -split ' -- ')[-1])).NotesPath
                    #$ResultsListBox.Items.Clear()
                    #Foreach ($Line in $CommandNotes) {
                    #    $ResultsListBox.Items.Add($Line)                    
                    #}
                                      
                    # Brings the Host Data Tab to the forefront/front view
                    $Section4TabControl.SelectedTab   = $Section3ResultsTab
                    foreach ($Entry in $Category.nodes) {                     
                        if ($entry.checked) {
                            $EntryNodeCheckedCountforCategory += 1
                            $EntryNodeCheckedCountforRoot     += 1
                            $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",10,1,1,1)
                            $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,0,224)
                            $Category.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
                            $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                            $Root.NodeFont      = New-Object System.Drawing.Font("$Font",10,1,1,1)
                            $Root.ForeColor     = [System.Drawing.Color]::FromArgb(0,0,0,224)
                        }
                        if (!($entry.checked)) {
                            $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",10,1,1,1)
                            $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,0,0)
                        }
                    }
                }
            }       
            if ($EntryNodeCheckedCountforCategory -gt 0) {
                $Category.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
                $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
            }
            else {
                $Category.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
                $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
            }
            if ($EntryNodeCheckedCountforRoot -gt 0) {
                $Root.NodeFont      = New-Object System.Drawing.Font("$Font",10,1,1,1)
                $Root.ForeColor     = [System.Drawing.Color]::FromArgb(0,0,0,224)
            }
            else {
                $Root.NodeFont      = New-Object System.Drawing.Font("$Font",10,1,1,1)
                $Root.ForeColor     = [System.Drawing.Color]::FromArgb(0,0,0,0)
            }
        }         
    }
}
#marco
function Initialize-CommandsTreeView {
    $script:TreeNodeImportCustomCommands = New-Object -TypeName System.Windows.Forms.TreeNode -ArgumentList "1) Custom Commands          " -Property @{
        Tag       = "Custom Commands"
        NodeFont  = New-Object System.Drawing.Font("$Font",11,1,2,1)
        ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
    }
    $script:TreeNodeCommandSearch = New-Object -TypeName System.Windows.Forms.TreeNode -ArgumentList "* Search Results          " -Property @{
        Tag       = "Search"
        NodeFont  = New-Object System.Drawing.Font("$Font",11,1,2,1)
        ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
    }    
    $script:TreeNodeEndpointCommands = New-Object -TypeName System.Windows.Forms.TreeNode -ArgumentList "2) Endpoint Commands          " -Property @{
        Tag       = "Endpoint Commands"
        NodeFont  = New-Object System.Drawing.Font("$Font",11,1,2,1)
        ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
    }
    $script:TreeNodeActiveDirectoryCommands = New-Object -TypeName System.Windows.Forms.TreeNode -ArgumentList "3) Active Directory Commands          " -Property @{
        Tag       = "ADDS Commands"
        NodeFont  = New-Object System.Drawing.Font("$Font",11,1,2,1)
        ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
    }
    $script:TreeNodeImportCustomCommands.Expand()
    $script:TreeNodeCommandSearch.Expand()
    $script:TreeNodeEndpointCommands.Expand()
    $script:TreeNodeActiveDirectoryCommands.Expand()
    $CommandsTreeView.Nodes.Clear()
}

# This section will check the checkboxes selected under the other view
function Keep-CommandsCheckboxesChecked {
    $CommandsTreeView.Nodes.Add($script:TreeNodeEndpointCommands)
    $CommandsTreeView.Nodes.Add($script:TreeNodeActiveDirectoryCommands)
    $CommandsTreeView.Nodes.Add($script:TreeNodeImportCustomCommands)
    $CommandsTreeView.Nodes.Add($script:TreeNodeCommandSearch)
    [System.Windows.Forms.TreeNodeCollection]$AllCommandsNode = $CommandsTreeView.Nodes 
    if ($CommandsCheckedBoxesSelected.count -gt 0) {
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Categories that were checked will not remained checked.")
        $ResultsListBox.Items.Add("")
        $ResultsListBox.Items.Add("The following Commands are still selected:")
        foreach ($root in $AllCommandsNode) { 
            foreach ($Category in $root.Nodes) { 
                foreach ($Entry in $Category.nodes) { 
                    if ($CommandsCheckedBoxesSelected -contains $Entry.text) {
                        $Entry.Checked      = $true
                        $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",10,1,1,1)
                        $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,0,224)
                        $Category.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
                        $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                        $Category.Expand()
                        $Root.NodeFont      = New-Object System.Drawing.Font("$Font",10,1,1,1)
                        $Root.ForeColor     = [System.Drawing.Color]::FromArgb(0,0,0,224)
                        $Root.Expand()
                        $ResultsListBox.Items.Add($Entry.Text)
                    }            
                }
            }
        }
    }
}

# Adds a node to the specified root node... a command node within a category node
function Add-CommandsNode { 
    param ( 
        $RootNode, 
        $Category,
        $Entry,
        $ToolTip
    )
    $newNode = New-Object System.Windows.Forms.TreeNode -Property @{
        Name = "$Entry"
        Text = "$Entry"
    }
    if ($ToolTip) { $newNode.ToolTipText  = "$ToolTip" }
    else { $newNode.ToolTipText  = "No Data Available" }
    If ($RootNode.Nodes.Tag -contains $Category) {
        $HostNode = $RootNode.Nodes | Where-Object {$_.Tag -eq $Category}
    }
    Else {
        $CategoryNode = New-Object System.Windows.Forms.TreeNode -Property @{
            Name = $Category
            Text = $Category
            Tag  = $Category
            #ToolTipText   = "Checkbox this Category to query all its hosts"
        }
        #$CategoryNode.Expand()
        
        if ($Category -match '(WinRM)') {
            $CategoryNode.ToolTipText = @"
Windows Remote Management (WinRM)
Protocols: HTTP(WSMan), MIME, SOAP, XML
Port:      5985/5986
Encrypted: Yes
OS:        Win7 / 2008R2+
           Older OSs with WinRM installed
Data:      Deserialized Objects
Pros:      Single Port required
           Supports any cmdlet
Cons       Requires WinRM on Older OSes
           May require enabling (Enable-PSRemoting or GPO)
"@
        }
        elseif ($Category -match '(RPC)') {
            $CategoryNode.ToolTipText = @"
Remote Procedure Call
Protocols: RPC/DCOM
Encrypted: Not Encrypted (clear text)
Ports:     135, Random High
OS:        Windows 2000 and above
Data:      PowerShell = Deserialized Objects
           Native CMD = Serialized Data
Pros:      Works against older OSs
           Does not require WinRM
Cons:      Uses random high ports
           Not firewall friendly
           Transmits data in clear text
"@
        }

        $CategoryNode.NodeFont   = New-Object System.Drawing.Font("$Font",10,1,1,1)
        $CategoryNode.ForeColor  = [System.Drawing.Color]::FromArgb(0,0,0,0)
        $Null     = $RootNode.Nodes.Add($CategoryNode)
        $HostNode = $RootNode.Nodes | Where-Object {$_.Tag -eq $Category}
    }
    $Null = $HostNode.Nodes.Add($newNode)
}

$script:HostQueryTreeViewSelected = ""

# Groups Commands TreeNodes by Method
Function View-CommandsTreeViewMethod {
    Foreach($Command in $script:AllEndpointCommands) {
        if ($Command.Command_RPC_PoSh) {
            Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-13}{1}" -f "[RPC]", "PowerShell Cmdlets") -Entry "(RPC) PoSh -- $($Command.Name)" -ToolTip $Command.Command_RPC_PoSh
        }
        if ($Command.Command_RPC_CMD) {
            Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-13}{1}" -f "[RPC]", "Windows CMD") -Entry "(RPC) CMD -- $($Command.Name)" -ToolTip $Command.Command_RPC_CMD
        }
        if ($Command.Command_WMI) {
            Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-13}{1}" -f "[RPC]", "Windows Management Instrumentation (WMI)") -Entry "(RPC) WMI -- $($Command.Name)" -ToolTip $Command.Command_WMI
        }
#        if ($Command.Command_WinRS_WMIC) {
#            Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-10}{1}" -f "[WinRM]", "WMIC") -Entry "(WinRM) WMIC -- $($Command.Name)" -ToolTip $Command.Command_WinRS_WMIC
#        }
#        if ($Command.Command_WinRS_CMD) {
#            Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-10}{1}" -f "[WinRM]", "Windows CMD") -Entry "(WinRM) CMD -- $($Command.Name)" -ToolTip $Command.Command_WinRS_CMD
#        }
        if ($Command.Command_WinRM_Script) {
            Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-10}{1}" -f "[WinRM]", "PowerShell Scripts") -Entry "(WinRM) Script -- $($Command.Name)" -ToolTip $Command.Command_WinRM_Script
        }        
        if ($Command.Command_WinRM_PoSh) {
            Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-10}{1}" -f "[WinRM]", "PowerShell Cmdlets") -Entry "(WinRM) PoSh -- $($Command.Name)" -ToolTip $Command.Command_WinRM_PoSh
        }
        if ($Command.Command_WinRM_WMI) {
            Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-10}{1}" -f "[WinRM]", "Windows Management Instrumentation (WMI)") -Entry "(WinRM) WMI -- $($Command.Name)" -ToolTip $Command.Command_WinRM_WMI
        }
        if ($Command.Command_WinRM_CMD) {
            Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-10}{1}" -f "[WinRM]", "Windows CMD") -Entry "(WinRM) CMD -- $($Command.Name)" -ToolTip $Command.Command_WinRM_CMD
        }
    }
    Foreach($Command in $script:AllActiveDirectoryCommands) {
        if ($Command.Command_RPC_PoSh) {
            Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-13}{1}" -f "[RPC]", "PowerShell Cmdlets") -Entry "(RPC) PoSh -- $($Command.Name)" -ToolTip $Command.Command_RPC_PoSh
        }
        if ($Command.Command_RPC_CMD) {
            Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-13}{1}" -f "[RPC]", "Windows CMD") -Entry "(RPC) CMD -- $($Command.Name)" -ToolTip $Command.Command_RPC_CMD
        }
        if ($Command.Command_WMI) {
            Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-13}{1}" -f "[RPC]", "Windows Management Instrumentation (WMI)") -Entry "(RPC) WMI -- $($Command.Name)" -ToolTip $Command.Command_WMI
        }
#        if ($Command.Command_WinRS_WMIC) {
#            Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-10}{1}" -f "[WinRM]", "WMIC") -Entry "(WinRM) WMIC -- $($Command.Name)" -ToolTip $Command.Command_WinRS_WMIC
#        }
#        if ($Command.Command_WinRS_CMD) {
#            Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-10}{1}" -f "[WinRM]", "Windows CMD") -Entry "(WinRM) CMD -- $($Command.Name)" -ToolTip $Command.Command_WinRS_CMD
#        }
        if ($Command.Command_WinRM_Script) {
            Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-10}{1}" -f "[WinRM]", "PowerShell Scripts") -Entry "(WinRM) Script -- $($Command.Name)" -ToolTip $Command.Command_WinRM_Script
        }        
        if ($Command.Command_WinRM_PoSh) {
            Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-10}{1}" -f "[WinRM]", "PowerShell Cmdlets") -Entry "(WinRM) PoSh -- $($Command.Name)" -ToolTip $Command.Command_WinRM_PoSh
        }
        if ($Command.Command_WinRM_WMI) {
            Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-10}{1}" -f "[WinRM]", "Windows Management Instrumentation (WMI)") -Entry "(WinRM) WMI -- $($Command.Name)" -ToolTip $Command.Command_WinRM_WMI
        }
        if ($Command.Command_WinRM_CMD) {
            Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-10}{1}" -f "[WinRM]", "Windows CMD") -Entry "(WinRM) CMD -- $($Command.Name)" -ToolTip $Command.Command_WinRM_CMD
        }
    }
    Foreach ($Command in $script:ImportCustomCommands) {
        if ($Command.Command_RPC_PoSh) {
            Add-CommandsNode -RootNode $script:TreeNodeImportCustomCommands -Category $("{0,-13}{1}" -f "[RPC]", "PowerShell Cmdlets") -Entry "(RPC) PoSh -- $($Command.Name)" -ToolTip $Command.Command_RPC_PoSh
        }
        if ($Command.Command_RPC_CMD) {
            Add-CommandsNode -RootNode $script:TreeNodeImportCustomCommands -Category $("{0,-13}{1}" -f "[RPC]", "Windows CMD") -Entry "(RPC) CMD -- $($Command.Name)" -ToolTip $Command.Command_RPC_CMD
        }
        if ($Command.Command_WMI) {
            Add-CommandsNode -RootNode $script:TreeNodeImportCustomCommands -Category $("{0,-13}{1}" -f "[RPC]", "Windows Management Instrumentation (WMI)") -Entry "(RPC) WMI -- $($Command.Name)" -ToolTip $Command.Command_WMI
        }
#        if ($Command.Command_WinRS_WMIC) {
#            Add-CommandsNode -RootNode $script:TreeNodeImportCustomCommands -Category $("{0,-10}{1}" -f "[WinRM]", "WMIC") -Entry "(WinRM) WMIC -- $($Command.Name)" -ToolTip $Command.Command_WinRS_WMIC
#        }
#        if ($Command.Command_WinRS_CMD) {
#            Add-CommandsNode -RootNode $script:TreeNodeImportCustomCommands -Category $("{0,-10}{1}" -f "[WinRM]", "Windows CMD") -Entry "(WinRM) CMD -- $($Command.Name)" -ToolTip $Command.Command_WinRS_CMD
#        }
        if ($Command.Command_WinRM_Script) {
            Add-CommandsNode -RootNode $script:TreeNodeImportCustomCommands -Category $("{0,-10}{1}" -f "[WinRM]", "PowerShell Scripts") -Entry "(WinRM) Script -- $($Command.Name)" -ToolTip $Command.Command_WinRM_Script
        }        
        if ($Command.Command_WinRM_PoSh) {
            Add-CommandsNode -RootNode $script:TreeNodeImportCustomCommands -Category $("{0,-10}{1}" -f "[WinRM]", "PowerShell Cmdlets") -Entry "(WinRM) PoSh -- $($Command.Name)" -ToolTip $Command.Command_WinRM_PoSh
        }
        if ($Command.Command_WinRM_WMI) {
            Add-CommandsNode -RootNode $script:TreeNodeImportCustomCommands -Category $("{0,-10}{1}" -f "[WinRM]", "Windows Management Instrumentation (WMI)") -Entry "(WinRM) WMI -- $($Command.Name)" -ToolTip $Command.Command_WinRM_WMI
        }
        if ($Command.Command_WinRM_CMD) {
            Add-CommandsNode -RootNode $script:TreeNodeImportCustomCommands -Category $("{0,-10}{1}" -f "[WinRM]", "Windows CMD") -Entry "(WinRM) CMD -- $($Command.Name)" -ToolTip $Command.Command_WinRM_CMD
        }
    }
}

# Groups Commands TreeNodes by Method
Function View-CommandsTreeViewQuery {
    Foreach($Command in $script:AllEndpointCommands) {
        if ($Command.Command_RPC_PoSh) {
            Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(RPC) PoSh -- $($Command.Name)" -ToolTip $Command.Command_RPC_PoSh
        }
        if ($Command.Command_RPC_CMD) {
            Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(RPC) CMD -- $($Command.Name)" -ToolTip $Command.Command_RPC_CMD
        }
        if ($Command.Command_WMI) {
            Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(RPC) WMI -- $($Command.Name)" -ToolTip $Command.Command_WMI
        }
#        if ($Command.Command_WinRS_WMIC) {
#            Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(WinRM) WMIC -- $($Command.Name)" -ToolTip $Command.Command_WinRS_WMIC
#        }
#        if ($Command.Command_WinRS_CMD) {
#            Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(WinRM) CMD -- $($Command.Name)" -ToolTip $Command.Command_WinRS_CMD
#        }
        if ($Command.Command_WinRM_Script) {
            Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(WinRM) Script -- $($Command.Name)" -ToolTip $Command.Command_WinRM_Script
        }        
        if ($Command.Command_WinRM_PoSh) {
            Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(WinRM) PoSh -- $($Command.Name)" -ToolTip $Command.Command_WinRM_PoSh
        }
        if ($Command.Command_WinRM_WMI) {
            Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(WinRM) WMI -- $($Command.Name)" -ToolTip $Command.Command_WinRM_WMI
        }
        if ($Command.Command_WinRM_CMD) {
            Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(WinRM) CMD -- $($Command.Name)" -ToolTip $Command.Command_WinRM_CMD
        }
    }
    Foreach($Command in $script:AllActiveDirectoryCommands) {
        if ($Command.Command_RPC_PoSh) {
            Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(RPC) PoSh -- $($Command.Name)" -ToolTip $Command.Command_RPC_PoSh
        }
        if ($Command.Command_RPC_CMD) {
            Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(RPC) CMD -- $($Command.Name)" -ToolTip $Command.Command_RPC_CMD
        }
        if ($Command.Command_WMI) {
            Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(RPC) WMI -- $($Command.Name)" -ToolTip $Command.Command_WMI
        }
#        if ($Command.Command_WinRS_WMIC) {
#            Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(WinRM) WMIC -- $($Command.Name)" -ToolTip $Command.Command_WinRS_WMIC
#        }
#        if ($Command.Command_WinRS_CMD) {
#            Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(WinRM) CMD -- $($Command.Name)" -ToolTip $Command.Command_WinRS_CMD
#        }
        if ($Command.Command_WinRM_Script) {
            Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(WinRM) Script -- $($Command.Name)" -ToolTip $Command.Command_WinRM_Script
        }        
        if ($Command.Command_WinRM_PoSh) {
            Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(WinRM) PoSh -- $($Command.Name)" -ToolTip $Command.Command_WinRM_PoSh
        }
        if ($Command.Command_WinRM_WMI) {
            Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(WinRM) WMI -- $($Command.Name)" -ToolTip $Command.Command_WinRM_WMI
        }
        if ($Command.Command_WinRM_CMD) {
            Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(WinRM) CMD -- $($Command.Name)" -ToolTip $Command.Command_WinRM_CMD
        }
    }
    Foreach ($Command in $script:ImportCustomCommands) {
        if ($Command.Command_RPC_PoSh) {
            Add-CommandsNode -RootNode $script:TreeNodeImportCustomCommands -Category $Command.Name -Entry "(RPC) PoSh -- $($Command.Name)" -ToolTip $Command.Command_RPC_PoSh
        }
        if ($Command.Command_RPC_CMD) {
            Add-CommandsNode -RootNode $script:TreeNodeImportCustomCommands -Category $Command.Name -Entry "(RPC) CMD -- $($Command.Name)" -ToolTip $Command.Command_RPC_CMD
        }
        if ($Command.Command_WMI) {
            Add-CommandsNode -RootNode $script:TreeNodeImportCustomCommands -Category $Command.Name -Entry "(RPC) WMI -- $($Command.Name)" -ToolTip $Command.Command_WMI
        }
#        if ($Command.Command_WinRS_WMIC) {
#            Add-CommandsNode -RootNode $script:TreeNodeImportCustomCommands -Category $Command.Name -Entry "(WinRM) WMIC -- $($Command.Name)" -ToolTip $Command.Command_WinRS_WMIC
#        }
#        if ($Command.Command_WinRS_CMD) {
#            Add-CommandsNode -RootNode $script:TreeNodeImportCustomCommands -Category $Command.Name -Entry "(WinRM) CMD -- $($Command.Name)" -ToolTip $Command.Command_WinRS_CMD
#        }
        if ($Command.Command_WinRM_Script) {
            Add-CommandsNode -RootNode $script:TreeNodeImportCustomCommands -Category $Command.Name -Entry "(WinRM) Script -- $($Command.Name)" -ToolTip $Command.Command_WinRM_Script
        }        
        if ($Command.Command_WinRM_PoSh) {
            Add-CommandsNode -RootNode $script:TreeNodeImportCustomCommands -Category $Command.Name -Entry "(WinRM) PoSh -- $($Command.Name)" -ToolTip $Command.Command_WinRM_PoSh
        }
        if ($Command.Command_WinRM_WMI) {
            Add-CommandsNode -RootNode $script:TreeNodeImportCustomCommands -Category $Command.Name -Entry "(WinRM) WMI -- $($Command.Name)" -ToolTip $Command.Command_WinRM_WMI
        }
        if ($Command.Command_WinRM_CMD) {
            Add-CommandsNode -RootNode $script:TreeNodeImportCustomCommands -Category $Command.Name -Entry "(WinRM) CMD -- $($Command.Name)" -ToolTip $Command.Command_WinRM_CMD
        }
    }

}
#============================================================================================================================================================
# Commands - Treeview Options at the top
#============================================================================================================================================================

#---------------------------------------------------
# Commands Treeview - View hostname/IPs by GroupBox
#---------------------------------------------------
$CommandsTreeViewViewByGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text     = "Display Queries By:"
    Location = @{ X = 0
                  Y = 5
                }
    Size     = @{ Width  = 173
                  Height = 37
                }
    Font     = New-Object System.Drawing.Font("$Font",11,1,2,1)
    ForeColor = 'Blue'
}
    #---------------------------------------------
    # Commands TreeView - Method Type RadioButton
    #---------------------------------------------
    $CommandsViewMethodRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
        Text     = "Method"
        Location = @{ X = 10
                      Y = 13
                    }
        Size     = @{ Width  = 60
                      Height = 22                  
                    }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = 'Black'
        Checked  = $True
    }
    $CommandsViewMethodRadioButton.Add_Click({
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("View Commands By:  Method")

        # This variable stores data on checked checkboxes, so boxes checked remain among different views
        $CommandsCheckedBoxesSelected = @()

        [System.Windows.Forms.TreeNodeCollection]$AllCommandsNode = $CommandsTreeView.Nodes 
        foreach ($root in $AllCommandsNode) { 
            foreach ($Category in $root.Nodes) {
                foreach ($Entry in $Category.nodes) { 
                    if ($Entry.Checked) {
                        $CommandsCheckedBoxesSelected += $Entry.Text                    
                    }
                }
            }
        }
        $CommandsTreeView.Nodes.Clear()
        Initialize-CommandsTreeView
        TempSave-HostData
        View-CommandsTreeViewMethod
        Keep-CommandsCheckboxesChecked
        #$CommandsTreeView.ExpandAll()
    })
    $CommandsViewMethodRadioButton.Add_MouseHover({
        $ToolTip = New-Object System.Windows.Forms.ToolTip    
        if ($OptionShowToolTipCheckBox.Checked){
            $Message = "⦿ Displays commands grouped by the method they're collected
    ⦿ All commands executed against each host are logged`n`n"
            $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage3))
            $ToolTip.Active       = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
            $ToolTip.UseAnimation = $true
            $ToolTip.UseFading    = $true
            $ToolTip.IsBalloon    = $true
            $ToolTip.ToolTipIcon  = "Info"  #Error, Info, Warning, None
            $ToolTip.ToolTipTitle = 'Display by Method'
        }    
    })
    $CommandsTreeViewViewByGroupBox.Controls.Add($CommandsViewMethodRadioButton)

    #--------------------------------------------
    # Commands TreeView - Query Type RadioButton
    #--------------------------------------------
    $CommandsViewQueryRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
        Text     = "Commands"
        Location = @{ X = $CommandsViewMethodRadioButton.Location.X + $CommandsViewMethodRadioButton.Size.Width
                      Y = $CommandsViewMethodRadioButton.Location.Y
                    }
        Size     = @{ Width  = 80
                      Height = 22
                    }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = 'Black'
        Checked  = $false
    }
    $CommandsViewQueryRadioButton.Add_Click({ 
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("View Commands By:  Query")

        # This variable stores data on checked checkboxes, so boxes checked remain among different views
        $CommandsCheckedBoxesSelected = @()

        [System.Windows.Forms.TreeNodeCollection]$AllCommandsNode = $CommandsTreeView.Nodes 
        foreach ($root in $AllCommandsNode) { 
            foreach ($Category in $root.Nodes) {
                foreach ($Entry in $Category.nodes) { 
                    if ($Entry.Checked) {
                        $CommandsCheckedBoxesSelected += $Entry.Text
                    }
                }
            }
        }            
        $CommandsTreeView.Nodes.Clear()
        Initialize-CommandsTreeView
        TempSave-HostData
        View-CommandsTreeViewQuery
        Keep-CommandsCheckboxesChecked
        #$CommandsTreeView.ExpandAll()
    })
    $CommandsViewQueryRadioButton.Add_MouseHover({
        $ToolTip = New-Object System.Windows.Forms.ToolTip    
        if ($OptionShowToolTipCheckBox.Checked){
            $Message = "⦿ Displays commands grouped by queries
    ⦿ All commands executed against each host are logged`n`n"
            $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage3))
            $ToolTip.Active       = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
            $ToolTip.UseAnimation = $true
            $ToolTip.UseFading    = $true
            $ToolTip.IsBalloon    = $true
            $ToolTip.ToolTipIcon  = "Info"  #Error, Info, Warning, None
            $ToolTip.ToolTipTitle = 'Display by Query'
        }    
    })
    $CommandsTreeViewViewByGroupBox.Controls.Add($CommandsViewQueryRadioButton)

$Section1CommandsTab.Controls.Add($CommandsTreeViewViewByGroupBox)

$Column5DownPosition += $Column5DownPositionShift

#---------------------------------------
# Commands Treeview - Query As GroupBox
#---------------------------------------
$CommandsTreeViewQueryAsGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text     = "Execute Queries As:"
    Location = @{ X = $CommandsTreeViewViewByLabel.Location.X + 178
                  Y = 5
                }
    Size     = @{ Width  = 257
                  Height = 37
                }
    Font     = New-Object System.Drawing.Font("$Font",11,1,2,1)
    ForeColor = 'Blue'
}
    #--------------------------------------------------------
    # Commands Treeview - Query As Individual - Radio Button
    #--------------------------------------------------------
    $CommandsTreeViewQueryAsIndividualRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
        Text     = "Separate Commands"
        Location = @{ X = 10 
                      Y = 13
                    }
        Size     = @{ Width  = 130
                      Height = 22
                    }
        Checked  = $true
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = 'Black'
    }
    $CommandsTreeViewQueryAsGroupBox.Controls.Add($CommandsTreeViewQueryAsIndividualRadioButton)

    #------------------------------------------------------
    # Commands Treeview - Query As Compiled - Radio Button
    #------------------------------------------------------
    $CommandsTreeViewQueryAsCompiledRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
        Text     = 'Compile & Review'
        Location = @{ X = $CommandsTreeViewQueryAsIndividualRadioButton.Location.X + $CommandsTreeViewQueryAsIndividualRadioButton.Size.Width
                      Y = $CommandsTreeViewQueryAsIndividualRadioButton.Location.Y
                    }
        Size     = @{ Width  = 125
                      Height = 22
                    }
        Checked  = $false
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = 'Black'
    }
    $CommandsTreeViewQueryAsGroupBox.Controls.Add($CommandsTreeViewQueryAsCompiledRadioButton)

$Section1CommandsTab.Controls.Add($CommandsTreeViewQueryAsGroupBox)

#-------------------------------------
# Commands TreeView - Search Function
#-------------------------------------
function Search-CommandsTreeView {
    $Section4TabControl.SelectedTab   = $Section3ResultsTab
    [System.Windows.Forms.TreeNodeCollection]$AllCommandsNode = $CommandsTreeView.Nodes

    # Checks if the search node already exists
    $SearchNode = $false
    foreach ($root in $AllCommandsNode) { 
        if ($root.text -imatch 'Search Results') { $SearchNode = $true }
    }
    if ($SearchNode -eq $false) { $CommandsTreeView.Nodes.Add($script:TreeNodeCommandSearch) }

    # Checks if the search has already been conduected
    $SearchCheck = $false
    foreach ($root in $AllCommandsNode) { 
        if ($root.text -imatch 'Search Results') {                    
            foreach ($Category in $root.Nodes) { 
                if ($Category.text -eq $CommandsTreeViewSearchTextBox.Text) { $SearchCheck = $true}            
            }
        }
    }
    # Conducts the search, if something is found it will add it to the treeview
    # Will not produce multiple results if the host triggers in more than one field
    $SearchFound = @()
    if ($CommandsTreeViewSearchTextBox.Text -ne "" -and $SearchCheck -eq $false) {
        $script:AllCommands  = $script:AllEndpointCommands
        $script:AllCommands += $script:AllActiveDirectoryCommands
        $script:AllCommands += $script:ImportCustomCommands
        Foreach($Command in $script:AllCommands) {
            if (($SearchFound -inotcontains $Computer) -and (
                ($Command.Name -imatch $CommandsTreeViewSearchTextBox.Text) -or
                ($Command.Type -imatch $CommandsTreeViewSearchTextBox.Text) -or
                ($Command.Message -imatch $CommandsTreeViewSearchTextBox.Text))) {
                if ($Command.Command_RPC_PoSh) {
                    Add-CommandsNode -RootNode $script:TreeNodeCommandSearch -Category $($CommandsTreeViewSearchTextBox.Text) -Entry "(RPC) PoSh -- $($Command.Name)" -ToolTip $Command.Command_RPC_PoSh
                }
                if ($Command.Command_RPC_CMD) {
                    Add-CommandsNode -RootNode $script:TreeNodeCommandSearch -Category $($CommandsTreeViewSearchTextBox.Text) -Entry "(RPC) CMD -- $($Command.Name)" -ToolTip $Command.Command_RPC_CMD
                }
                if ($Command.Command_WMI) {
                    Add-CommandsNode -RootNode $script:TreeNodeCommandSearch -Category $($CommandsTreeViewSearchTextBox.Text) -Entry "(RPC) WMI -- $($Command.Name)" -ToolTip $Command.Command_WMI
                }
        #        if ($Command.Command_WinRS_WMIC) {
        #            Add-CommandsNode -RootNode $script:TreeNodeCommandSearch -Category $($CommandsTreeViewSearchTextBox.Text) -Entry "(WinRM) WMIC -- $($Command.Name)" -ToolTip $Command.Command_WinRS_WMIC
        #        }
        #        if ($Command.Command_WinRS_CMD) {
        #            Add-CommandsNode -RootNode $script:TreeNodeCommandSearch -Category $($CommandsTreeViewSearchTextBox.Text) -Entry "(WinRM) CMD -- $($Command.Name)" -ToolTip $Command.Command_WinRS_CMD
        #        }
                if ($Command.Command_WinRM_Script) {
                    Add-CommandsNode -RootNode $script:TreeNodeCommandSearch -Category $($CommandsTreeViewSearchTextBox.Text) -Entry "(WinRM) Script -- $($Command.Name)" -ToolTip $Command.Command_WinRM_Script
                }        
                if ($Command.Command_WinRM_PoSh) {
                    Add-CommandsNode -RootNode $script:TreeNodeCommandSearch -Category $($CommandsTreeViewSearchTextBox.Text) -Entry "(WinRM) PoSh -- $($Command.Name)" -ToolTip $Command.Command_WinRM_PoSh
                }
                if ($Command.Command_WinRM_WMI) {
                    Add-CommandsNode -RootNode $script:TreeNodeCommandSearch -Category $($CommandsTreeViewSearchTextBox.Text) -Entry "(WinRM) WMI -- $($Command.Name)" -ToolTip $Command.Command_WinRM_WMI
                }
                if ($Command.Command_WinRM_CMD) {
                    Add-CommandsNode -RootNode $script:TreeNodeCommandSearch -Category $($CommandsTreeViewSearchTextBox.Text) -Entry "(WinRM) CMD -- $($Command.Name)" -ToolTip $Command.Command_WinRM_CMD
                }            
            }
        }
    }
    # Expands the search results
    [System.Windows.Forms.TreeNodeCollection]$AllCommandsNode = $CommandsTreeView.Nodes 
    foreach ($root in $AllCommandsNode) { 
        if ($root.text -match 'Search Results'){
            $root.Expand()
            foreach ($Category in $root.Nodes) {
                if ($CommandsTreeViewSearchTextBox.text -in $Category.text) {
                    $Category.Expand()
                }
            }
        }
    }
    $CommandsTreeViewSearchTextBox.Text = ""
}

#------------------------------------
# Computer TreeView - Search TextBox
#------------------------------------
$CommandsTreeViewSearchTextBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Name     = "Search TextBox"
    Location = @{ X = 0
                  Y = 45
                }
    Size     = @{ Width  = 172
                  Height = 25
                }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems" # Options are: FileSystem, HistoryList, RecentlyUsedList, AllURL, AllSystemSources, FileSystemDirectories, CustomSource, ListItems, None
    AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
}
$CommandTypes = @("Chart","File","Hardware","Hunt","Network","System","User")
ForEach ($Type in $CommandTypes) { [void] $CommandsTreeViewSearchTextBox.Items.Add($Type) }
$CommandsTreeViewSearchTextBox.Add_KeyDown({ 
    if ($_.KeyCode -eq "Enter") { Search-CommandsTreeView }
})
$CommandsTreeViewSearchTextBox.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ Searches may be typed in manually.
⦿ Searches can include any character.
⦿ There are several default searches available.`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage3))
        $ToolTip.Active       = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation = $true
        $ToolTip.UseFading    = $true
        $ToolTip.IsBalloon    = $true
        $ToolTip.ToolTipIcon  = "Info"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle = 'Search Input Field'
    }    
})
$Section1CommandsTab.Controls.Add($CommandsTreeViewSearchTextBox)

#-----------------------------------
# Computer TreeView - Search Button
#-----------------------------------
$CommandsTreeViewSearchButton = New-Object System.Windows.Forms.Button -Property @{
    Name     = "Search Button"
    Text     = "Search"
    Location = @{ X = $CommandsTreeViewSearchTextBox.Size.Width + 5
                  Y = 45
                }
    Size     = @{ Width  = 55
                  Height = 22
                }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$CommandsTreeViewSearchButton.Add_Click({ Search-CommandsTreeView })
$CommandsTreeViewSearchButton.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ Searches through query names and metadata.
⦿ Search results are returned as nodes.
⦿ Search results are not persistent.`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage3))
        $ToolTip.Active       = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation = $true
        $ToolTip.UseFading    = $true
        $ToolTip.IsBalloon    = $true
        $ToolTip.ToolTipIcon  = "Info"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle = 'Command Search'
    }    
})
$Section1CommandsTab.Controls.Add($CommandsTreeViewSearchButton)


#-----------------------------------------
# Commands Treeview - Deselect All Button
#-----------------------------------------
$CommandsTreeviewDeselectAllButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = 'Deselect All'
    Location = @{ X = 336
                  Y = 45
                }
    Size     = @{ Width  = 100
                  Height = 22
                }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$CommandsTreeviewDeselectAllButton.Add_Click({
    [System.Windows.Forms.TreeNodeCollection]$AllCommandsNode = $CommandsTreeView.Nodes 
    foreach ($root in $AllCommandsNode) { 
        $root.Checked   = $false
        $root.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
        $root.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
        $root.Collapse()
        $root.Expand()
        foreach ($Category in $root.Nodes) { 
            $Category.Checked   = $false
            $Category.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
            $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
            $Category.Collapse()
            foreach ($Entry in $Category.nodes) { 
                $Entry.Checked   = $false
                $Entry.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
                $Entry.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
            }
        }
    }
    $EventLogsEventIDsManualEntryCheckbox.checked           = $false
    $EventLogsQuickPickSelectionCheckbox.checked            = $false
    $EventLogsEventIDsIndividualSelectionCheckbox.checked   = $false
    $FileSearchDirectoryListingCheckbox.checked             = $false
    $FileSearchFileSearchCheckbox.checked                   = $false
    $FileSearchAlternateDataStreamCheckbox.checked          = $false
    $NetworkConnectionSearchRemoteIPAddressCheckbox.checked = $false
    $NetworkConnectionSearchRemotePortCheckbox.checked      = $false
    $NetworkConnectionSearchProcessCheckbox.checked         = $false
    $NetworkConnectionSearchDNSCacheCheckbox.checked        = $false
    $SysinternalsSysmonCheckbox.checked                     = $false
    $SysinternalsAutorunsCheckbox.checked                   = $false
    $SysinternalsProcessMonitorCheckbox.checked             = $false
})
$CommandsTreeviewDeselectAllButton.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ Unchecks all commands checked within this view.
⦿ Commands and queries in other Tabs must be manually unchecked.`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage3))
        $ToolTip.Active       = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation = $true
        $ToolTip.UseFading    = $true
        $ToolTip.IsBalloon    = $true
        $ToolTip.ToolTipIcon  = "Info"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle = 'Deselect All'
    }    
})
$Section1CommandsTab.Controls.Add($CommandsTreeviewDeselectAllButton) 

#---------------------------
# Commands Treeview Nodes
#---------------------------
$CommandsTreeView = New-Object System.Windows.Forms.TreeView -Property @{
    Location = @{ X = 0
                  Y = 70
                }
    Size     = @{ Width  = 435
                  Height = 459
                }
    Font             = New-Object System.Drawing.Font("$Font",11,0,0,0)
    CheckBoxes       = $True
    #LabelEdit       = $True
    ShowLines        = $True
    ShowNodeToolTips = $True
}
$CommandsTreeView.Sort()
$CommandsTreeView.Add_Click({ Conduct-NodeAction -TreeView $CommandsTreeView.Nodes })
$CommandsTreeView.Add_AfterSelect({ Conduct-NodeAction -TreeView $CommandsTreeView.Nodes })
$Section1CommandsTab.Controls.Add($CommandsTreeView)

# Default View
Initialize-CommandsTreeView

# This adds the nodes to the Commands TreeView
View-CommandsTreeViewMethod

$CommandsTreeView.Nodes.Add($script:TreeNodeEndpointCommands)
$CommandsTreeView.Nodes.Add($script:TreeNodeActiveDirectoryCommands)
$CommandsTreeView.Nodes.Add($script:TreeNodeImportCustomCommands)
$CommandsTreeView.Nodes.Add($script:TreeNodeCommandSearch)
#$CommandsTreeView.ExpandAll()

#===============================================================================
#     ______                 __     __                        ______      __  
#    / ____/   _____  ____  / /_   / /   ____  ____ ______   /_  __/___ _/ /_ 
#   / __/ | | / / _ \/ __ \/ __/  / /   / __ \/ __ `/ ___/    / / / __ `/ __ \
#  / /___ | |/ /  __/ / / / /_   / /___/ /_/ / /_/ (__  )    / / / /_/ / /_/ /
# /_____/ |___/\___/_/ /_/\__/  /_____/\____/\__, /____/    /_/  \__,_/_.___/ 
#                                          /____/                            
#===============================================================================

#######################################################################################################################################################################
##           ##
##  SUB-TAB  ## Event Logs
##           ##
#######################################################################################################################################################################

# Varables for positioning checkboxes
$EventLogsRightPosition     = 5
$EventLogsDownPositionStart = 10
$EventLogsDownPosition      = 10
$EventLogsDownPositionShift = 22
$EventLogsBoxWidth          = 410
$EventLogsBoxHeight         = 22

$Section1EventLogsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text     = "Event Logs"
    Location = @{ X = $Column1RightPosition
                  Y = $Column1DownPosition
                }
    Size     = @{ Width  = $Column1BoxWidth
                  Height = $Column1BoxHeight
                }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    UseVisualStyleBackColor = $True
}
$Section1CollectionsTabControl.Controls.Add($Section1EventLogsTab)

#-------------------------
# Event Logs - Main Label
#-------------------------
$EventLogsMainLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "Event Logs can be obtained from workstations and servers."
    Location = @{ X = 5
                  Y = 5
                }
    Size     = @{ Width  = $EventLogsBoxWidth
                  Height = $EventLogsBoxHeight
                }
    Font     = New-Object System.Drawing.Font("$Font",10,1,3,1)
    ForeColor = "Black"
}
$Section1EventLogsTab.Controls.Add($EventLogsMainLabel)

#-------------------------------
# Event Logs - Options GroupBox
#-------------------------------
$EventLogsOptionsGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text      = "Collection Options"
    Location = @{ X = 5
                  Y = $EventLogsMainLabel.Location.Y + $EventLogsMainLabel.Size.Height
                }
    Size     = @{ Width  = 425
                  Height = 94
                }
    Font      = New-Object System.Drawing.Font("$Font",12,1,2,1)
    ForeColor = "Blue"
}
    #---------------------------------------
    # Event Log Protocol Radio Button Label
    #---------------------------------------
    $EventLogProtocolRadioButtonLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Protocol:"
        Location = @{ X = 7
                      Y = 20
                    }
        Size     = @{ Width  = 73
                      Height = 20
                    }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = 'Black'
    }
    #-----------------------------------------
    # Event Log Protocol WinRM - Radio Button
    #-----------------------------------------
    $EventLogWinRMRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
        Text     = "WinRM"
        Location = @{ X = 80
                      Y = 15
                    }
        Size     = @{ Width  = 60
                      Height = 22
                    }
        Checked  = $True
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = 'Black'
    }
    #$EventLogWinRMRadioButton.Add_Click({
    #    if ($EventLogWinRMRadioButton.Checked -eq $true) {$EventLogWinRMRadioButton.Checked = $false}
    #})
    <#$EventLogWinRMRadioButton.Add_MouseHover({
        $ToolTip = New-Object System.Windows.Forms.ToolTip    
        if ($OptionShowToolTipCheckBox.Checked){
            $Message = "⦿ Displays commands grouped by queries
    ⦿ All commands executed against each host are logged`n`n"
            $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage3))
            $ToolTip.Active       = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
            $ToolTip.UseAnimation = $true
            $ToolTip.UseFading    = $true
            $ToolTip.IsBalloon    = $true
            $ToolTip.ToolTipIcon  = "Info"  #Error, Info, Warning, None
            $ToolTip.ToolTipTitle = 'Display by Query'
        }    
    })#>
    #---------------------------------------
    # Event Log Protocol RPC - Radio Button
    #---------------------------------------
    $EventLogRPCRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
        Text     = "RPC"
        Location = @{ X = $EventLogWinRMRadioButton.Location.X + 75
                      Y = $EventLogWinRMRadioButton.Location.Y
                    }
        Size     = @{ Width  = 60
                      Height = 22
                    }
        Checked  = $False
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = 'Black'
    }
    #$EventLogRPCRadioButton.Add_Click({   })
    #$EventLogRPCRadioButton.Add_MouseHover({   })

    #---------------------------------------
    # Event Logs - Maximum Collection Label
    #---------------------------------------
    $EventLogsMaximumCollectionLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Max Collection:"
        Location = @{ X = $EventLogRPCRadioButton.Location.X + $EventLogRPCRadioButton.Size.Width + 52
                      Y = $EventLogRPCRadioButton.Location.Y + 3
                    }
        Size     = @{ Width  = 100
                      Height = 22
                    }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = "Black"
    }
        #-----------------------------------------
        # Event Logs - Maximum Collection TextBox
        #-----------------------------------------
        $EventLogsMaximumCollectionTextBox = New-Object System.Windows.Forms.TextBox -Property @{
            Text     = $null
            Location = @{ X = $EventLogsMaximumCollectionLabel.Location.X + $EventLogsMaximumCollectionLabel.Size.Width
                          Y = $EventLogsMaximumCollectionLabel.Location.Y - 3
                        }
            Size     = @{ Width  = 50
                          Height = 22
                        }
            Font     = New-Object System.Drawing.Font("$Font",10,0,0,0)
            Enabled  = $True
        }

    #-----------------------------------
    # Event Logs - DateTime Start Label
    #-----------------------------------
    $EventLogsDatetimeStartLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "DateTime Start:"
        Location = @{ X = 77
                      Y = $EventLogProtocolRadioButtonLabel.Location.Y + $EventLogProtocolRadioButtonLabel.Size.Height + 5
                    }
        Size     = @{ Width  = 90
                      Height = 25
                    }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = "Black"
    }
        #--------------------------------------------
        # Event Logs - DateTime Start DateTimePicker
        #--------------------------------------------
        $EventLogsStartTimePicker = New-Object System.Windows.Forms.DateTimePicker -Property @{
            Location      = @{ X = $EventLogsDatetimeStartLabel.Location.X + $EventLogsDatetimeStartLabel.Size.Width
                               Y = $EventLogProtocolRadioButtonLabel.Location.Y + $EventLogProtocolRadioButtonLabel.Size.Height
                             }
            Size          = @{ Width  = 250
                               Height = 100
                             }
            Font         = New-Object System.Drawing.Font("$Font",11,0,0,0)
            Format       = [windows.forms.datetimepickerFormat]::custom
            CustomFormat = “dddd MMM dd, yyyy hh:mm tt”
            Enabled      = $True
            Checked      = $false
            ShowCheckBox = $True
            ShowUpDown   = $False
            AutoSize     = $true
            #MinDate      = (Get-Date -Month 1 -Day 1 -Year 2000).DateTime
            #MaxDate      = (Get-Date).DateTime
        }
        $EventLogsStartTimePicker.Add_Click({ 
            $ResultsListBox.Items.Add('this is only a test')
            if ($EventLogsStopTimePicker.checked -eq $false){$EventLogsStopTimePicker.checked = $true }
        })
        # Wednesday, June 5, 2019 10:27:40 PM
            # $TimePicker.Value
        # 20190605162740.383143-240
            # [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime(($EventLogsStartTimePicker.Value))

    #----------------------------------
    # Event Logs - Datetime Stop Label
    #----------------------------------
    $EventLogsDatetimeStopLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Datetime Stop:"
        Location = @{ X = $EventLogsDatetimeStartLabel.Location.X
                      Y = $EventLogsDatetimeStartLabel.Location.Y + $EventLogsDatetimeStartLabel.Size.Height
                    }
        Size     = @{ Width  = $EventLogsDatetimeStartLabel.Width
                      Height = 25
                    }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = "Black"
    }
        #-------------------------------------------
        # Event Logs - DateTime Stop DateTimePicker
        #-------------------------------------------
        $EventLogsStopTimePicker = New-Object System.Windows.Forms.DateTimePicker -Property @{
            Location     = @{ X = $EventLogsDatetimeStopLabel.Location.X + $EventLogsDatetimeStopLabel.Size.Width
                              Y = $EventLogsDatetimeStartLabel.Location.Y + $EventLogsDatetimeStartLabel.Size.Height - 5
                            }
            Size         = @{ Width  = $EventLogsStartTimePicker.Width
                              Height = 100
                            }
            Font         = New-Object System.Drawing.Font("$Font",11,0,0,0)
            Format       = [windows.forms.datetimepickerFormat]::custom
            CustomFormat = “dddd MMM dd, yyyy hh:mm tt”
            Enabled      = $True
            Checked      = $false
            ShowCheckBox = $True
            ShowUpDown   = $False
            AutoSize     = $true
            #MinDate      = (Get-Date -Month 1 -Day 1 -Year 2000).DateTime
            #MaxDate      = (Get-Date).DateTime
        }
    
    $EventLogsOptionsGroupBox.Controls.Add($EventLogProtocolRadioButtonLabel)
    $EventLogsOptionsGroupBox.Controls.Add($EventLogRPCRadioButton)
    $EventLogsOptionsGroupBox.Controls.Add($EventLogWinRMRadioButton)
    $EventLogsOptionsGroupBox.Controls.Add($EventLogsDatetimeStartLabel)
    $EventLogsOptionsGroupBox.Controls.Add($EventLogsStartTimePicker)
    $EventLogsOptionsGroupBox.Controls.Add($EventLogsDatetimeStopLabel)
    $EventLogsOptionsGroupBox.Controls.Add($EventLogsStopTimePicker)
    $EventLogsOptionsGroupBox.Controls.Add($EventLogsMaximumCollectionLabel)
    $EventLogsOptionsGroupBox.Controls.Add($EventLogsMaximumCollectionTextBox)
$Section1EventLogsTab.Controls.Add($EventLogsOptionsGroupBox)

#============================================================================================================================================================
# Event Logs - Event IDs Manual Entry
#============================================================================================================================================================

#-----------------------------------------------
# Event Logs - Event IDs Manual Entry CheckBox
#-----------------------------------------------
$EventLogsEventIDsManualEntryCheckbox  = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Event IDs Manual Entry"
    Location = @{ X = 7
                  Y = $EventLogsOptionsGroupBox.Location.Y + $EventLogsOptionsGroupBox.Size.Height + 10
                }
    Size     = @{ Width  = 200
                  Height = $EventLogsBoxHeight
                }
    Font     = New-Object System.Drawing.Font("$Font",12,1,2,1)
    ForeColor = 'Blue'
}
$Section1EventLogsTab.Controls.Add($EventLogsEventIDsManualEntryCheckbox)

#--------------------------------------------
# Event Logs - Event IDs Manual Entry Label
#--------------------------------------------
$EventLogsEventIDsManualEntryLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "Enter Event IDs; One Per Line"
    Location = @{ X = 5
                  Y = $EventLogsEventIDsManualEntryCheckbox.Location.Y + $EventLogsEventIDsManualEntryCheckbox.Size.Height
                }
    Size     = @{ Width  = 200
                  Height = $EventLogsBoxHeight
                }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Black"
}
$Section1EventLogsTab.Controls.Add($EventLogsEventIDsManualEntryLabel)

#-------------------------------------------------------
# Event Logs - Event IDs Manual Entry Selection Button
#-------------------------------------------------------
if (Test-Path $EventIDsFile) {
    $EventLogsEventIDsManualEntrySelectionButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Select Event IDs"
        Location = @{ X = 4
                      Y = $EventLogsEventIDsManualEntryLabel.Location.Y + $EventLogsEventIDsManualEntryLabel.Size.Height
                    }
        Size     = @{ Width  = 125
                      Height = 20
                    }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $EventLogsEventIDsManualEntrySelectionButton.Add_Click({
        Import-Csv $EventIDsFile | Out-GridView -OutputMode Multiple | Set-Variable -Name EventCodeManualEntrySelectionContents
        $EventIDColumn = $EventCodeManualEntrySelectionContents | Select-Object -ExpandProperty "Event ID"
        Foreach ($EventID in $EventIDColumn) {
            $EventLogsEventIDsManualEntryTextbox.Text += "$EventID`r`n"
        }
    })
    $Section1EventLogsTab.Controls.Add($EventLogsEventIDsManualEntrySelectionButton) 
}

#---------------------------------------------------
# Event Logs - Event IDs Manual Entry Clear Button
#---------------------------------------------------
$EventLogsEventIDsManualEntryClearButton          = New-Object System.Windows.Forms.Button 
$EventLogsEventIDsManualEntryClearButton.Text     = "Clear"
$EventLogsEventIDsManualEntryClearButton.Location = New-Object System.Drawing.Point(136,($EventLogsEventIDsManualEntryLabel.Location.Y + $EventLogsEventIDsManualEntryLabel.Size.Height)) 
$EventLogsEventIDsManualEntryClearButton.Size     = New-Object System.Drawing.Size(75,20) 
$EventLogsEventIDsManualEntryClearButton.Add_Click({
    $EventLogsEventIDsManualEntryTextbox.Text = ""
})
$EventLogsEventIDsManualEntryClearButton.Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
$Section1EventLogsTab.Controls.Add($EventLogsEventIDsManualEntryClearButton) 


#----------------------------------------------
# Event Logs - Event IDs Manual Entry Textbox
#----------------------------------------------
$EventLogsEventIDsManualEntryTextbox               = New-Object System.Windows.Forms.TextBox 
$EventLogsEventIDsManualEntryTextbox.Location      = New-Object System.Drawing.Point(5,($EventLogsEventIDsManualEntryClearButton.Location.Y + $EventLogsEventIDsManualEntryClearButton.Size.Height + 5)) 
$EventLogsEventIDsManualEntryTextbox.Size          = New-Object System.Drawing.Size(205,139)
$EventLogsEventIDsManualEntryTextbox.MultiLine     = $True
$EventLogsEventIDsManualEntryTextbox.ScrollBars    = "Vertical"
$EventLogsEventIDsManualEntryTextbox.WordWrap      = $True
$EventLogsEventIDsManualEntryTextbox.AcceptsTab    = $false # Allows you to enter in tabs into the textbox
$EventLogsEventIDsManualEntryTextbox.AcceptsReturn = $false # Allows you to enter in tabs into the textbox
$EventLogsEventIDsManualEntryTextbox.Font          = New-Object System.Drawing.Font("$Font",10,0,1,1)
#$EventLogsEventIDsManualEntryTextbox.Add_KeyDown({   })
$Section1EventLogsTab.Controls.Add($EventLogsEventIDsManualEntryTextbox)

#============================================================================================================================================================
# Event Logs - Event IDs Quick Pick Selection 
#============================================================================================================================================================
    $script:EventLogQueries = @()
    #$EventLogReference = "https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/plan/appendix-l--events-to-monitor"
    #$EventLogQuery | Add-Member -MemberType NoteProperty -Name Reference -Value "$EventLogReference" -Force

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "Application Event Logs"
        Filter   = "(logfile='Application')" 
        Message  = "Gets all Aplication Event Logs"
        FilePath = "$CommandsEventLogsDirectory\By Topic\Application Event Logs.txt"
    }

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "Security Event Logs"
        Filter   = "(logfile='Security')" 
        Message  = "Gets all Security Event Logs"
        FilePath = "$CommandsEventLogsDirectory\By Topic\Security Event Logs.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "System Event Logs"
        Filter   = "(logfile='System')" 
        Message  = "Gets all System Event Logs"
        FilePath = "$CommandsEventLogsDirectory\By Topic\System Event Logs.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "Application Event Logs Errors"
        Filter   = "(logfile='Application') AND (type='error')" 
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\Application Event Logs Errors.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "System Event Logs Errors"
        Filter   = "(logfile='System') AND (type='error')" 
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\System Event Logs Errors.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "Splunk Sexy Six"
        Filter   = "((EventCode='4688') OR (EventCode='592') OR (EventCode='4624') OR (EventCode='528') OR (EventCode='540') OR (EventCode='5140') OR (EventCode='560') OR (EventCode='5156') OR (EventCode='7045') OR (EventCode='601') OR (EventCode='4663') OR (EventCode='576'))"
        Message  = "Splunk Sexy Six"
        FilePath = "$CommandsEventLogsDirectory\By Topic\Splunk Sexy Six.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "Incident Response - root9b"
        Filter   = "((EventCode='1100') OR (EventCode='1102') OR (EventCode='4608') OR (EventCode='4609') OR (EventCode='4616') OR (EventCode='4624') OR (EventCode='4625') OR (EventCode='4634') OR (EventCode='4647') OR (EventCode='4663') OR (EventCode='4688') OR (EventCode='4697') OR (EventCode='4720') OR (EventCode='4722') OR (EventCode='4723') OR (EventCode='4724') OR (EventCode='4725') OR (EventCode='4726') OR (EventCode='4732') OR (EventCode='4738') OR (EventCode='4769') OR (EventCode='4771') OR (EventCode='4772') OR (EventCode='2773') OR (EventCode='4820') OR (EventCode='4821') OR (EventCode='4825') OR (EventCode='4965') OR (EventCode='5140') OR (EventCode='5156') OR (EventCode='6006') OR (EventCode='7030') OR (EventCode='7040') OR (EventCode='7045') OR (EventCode='1056') OR (EventCode='10000') OR (EventCode='10001') OR (EventCode='10100') OR (EventCode='20001') OR (EventCode='20002') OR (EventCode='20003') OR (EventCode='24576') OR (EventCode='24577') OR (EventCode='24579') OR (EventCode='40961') OR (EventCode='4100') OR (EventCode='4104'))"
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\Incident Response - root9b.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "Account Lockout"
        Filter   = "(logfile='Security') AND (EventCode='4625')" 
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\Account Lockout.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "Account Management"
        Filter   = "(logfile='Security') AND ((EventCode='4720') OR (EventCode='4722') OR (EventCode='4723') OR (EventCode='4724') OR (EventCode='4725') OR (EventCode='4726') OR (EventCode='4738') OR (EventCode='4740') OR (EventCode='4765') OR (EventCode='4766') OR (EventCode='4767') OR (EventCode='4780') OR (EventCode='4781') OR (EventCode='4781') OR (EventCode='4794') OR (EventCode='4798') OR (EventCode='5376') OR (EventCode='5377'))"
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\Account Management.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "Account Management Events - Other"
        Filter   = "(logfile='Security') AND ((EventCode='4782') OR (EventCode='4793'))"
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\Account Management Events - Other.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "Application Event Logs Generated"
        Filter   = "(logfile='Security') AND ((EventCode='4665') OR (EventCode='4666') OR (EventCode='4667') OR (EventCode='4668'))"
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\Application Generated.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "Application Event Logs Group Management"
        Filter   = "(logfile='Security') AND ((EventCode='4783') OR (EventCode='4784') OR (EventCode='4785') OR (EventCode='4786') OR (EventCode='4787') OR (EventCode='4788') OR (EventCode='4789') OR (EventCode='4790') OR (EventCode='4791') OR (EventCode='4792'))"
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\Application Group Management.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "Authentication Policy Change"
        Filter   = "(logfile='Security') AND ((EventCode='4670') OR (EventCode='4706') OR (EventCode='4707') OR (EventCode='4716') OR (EventCode='4713') OR (EventCode='4717') OR (EventCode='4718') OR (EventCode='4739') OR (EventCode='4864') OR (EventCode='4865') OR (EventCode='4866') OR (EventCode='4867'))"
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\Authentication Policy Change.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "Authorization Policy Change"
        Filter   = "(logfile='Security') AND ((EventCode='4703') OR (EventCode='4704') OR (EventCode='4705') OR (EventCode='4670') OR (EventCode='4911') OR (EventCode='4913'))"
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\Authorization Policy Change.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "Audit Policy Change"
        Filter   = "(logfile='Security') AND ((EventCode='4902') OR (EventCode='4907') OR (EventCode='4904') OR (EventCode='4905') OR (EventCode='4715') OR (EventCode='4719') OR (EventCode='4817') OR (EventCode='4902') OR (EventCode='4906') OR (EventCode='4907') OR (EventCode='4908') OR (EventCode='4912') OR (EventCode='4904') OR (EventCode='4905'))"
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\Audit Policy Change.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "Central Access Policy Staging"
        Filter   = "(logfile='Security') AND (EventCode='4818')" 
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\Central Access Policy Staging.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "Certification Services"
        Filter   = "(logfile='Security') AND ((EventCode='4868') OR (EventCode='4869') OR (EventCode='4870') OR (EventCode='4871') OR (EventCode='4872') OR (EventCode='4873') OR (EventCode='4874') OR (EventCode='4875') OR (EventCode='4876') OR (EventCode='4877') OR (EventCode='4878') OR (EventCode='4879') OR (EventCode='4880') OR (EventCode='4881') OR (EventCode='4882') OR (EventCode='4883') OR (EventCode='4884') OR (EventCode='4885') OR (EventCode='4886') OR (EventCode='4887') OR (EventCode='4888') OR (EventCode='4889') OR (EventCode='4890') OR (EventCode='4891') OR (EventCode='4892') OR (EventCode='4893') OR (EventCode='4894') OR (EventCode='4895') OR (EventCode='4896') OR (EventCode='4897') OR (EventCode='4898'))"
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\Certification Services.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "Computer Account Management"
        Filter   = "(logfile='Security') AND ((EventCode='4741') OR (EventCode='4742') OR (EventCode='4743'))"
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\Computer Account Management.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "Detailed Directory Service Replication"
        Filter   = "(logfile='Security') AND ((EventCode='4928') OR (EventCode='4929') OR (EventCode='4930') OR (EventCode='4931') OR (EventCode='4934') OR (EventCode='4935') OR (EventCode='4936') OR (EventCode='4937'))" 
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\Detailed Directory Service Replication.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "Detailed File Share"
        Filter   = "(logfile='Security') AND (EventCode='5145')" 
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\Detailed File Share.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "Directory Service Access"
        Filter   = "(logfile='Security') AND ((EventCode='4662') OR (EventCode='4661'))" 
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\Directory Service Access.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "Directory Service Changes"
        Filter   = "(logfile='Security') AND ((EventCode='5136') OR (EventCode='5137') OR (EventCode='5138') OR (EventCode='5139') OR (EventCode='5141'))" 
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\Directory Service Changes.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "Directory Service Replication"
        Filter   = "(logfile='Security') AND ((EventCode='4932') OR (EventCode='4933'))" 
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\Directory Service Replication.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "Distribution Group Management"
        Filter   = "(logfile='Security') AND ((EventCode='4749') OR (EventCode='4750') OR (EventCode='4751') OR (EventCode='4752') OR (EventCode='4753') OR (EventCode='4759') OR (EventCode='4760') OR (EventCode='4761') OR (EventCode='4762') OR (EventCode='4763') OR (EventCode='4744') OR (EventCode='4745') OR (EventCode='4746') OR (EventCode='4747') OR (EventCode='4748'))" 
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\Distribution Group Management.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "DPAPI Activity"
        Filter   = "(logfile='Security') AND ((EventCode='4692') OR (EventCode='4693') OR (EventCode='4694') OR (EventCode='4695'))" 
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\DPAPI Activity.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "File Share"
        Filter   = "(logfile='Security') AND ((EventCode='5140') OR (EventCode='5142') OR (EventCode='5143') OR (EventCode='5144') OR (EventCode='5168'))" 
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\File Share.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "File System"
        Filter   = "(logfile='Security') AND ((EventCode='4656') OR (EventCode='4658') OR (EventCode='4660') OR (EventCode='4663') OR (EventCode='4664') OR (EventCode='4985') OR (EventCode='5051') OR (EventCode='4670'))" 
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\File System.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "Filtering Platform Connection"
        Filter   = "(logfile='Security') AND ((EventCode='5031') OR (EventCode='5150') OR (EventCode='5151') OR (EventCode='5154') OR (EventCode='5155') OR (EventCode='5156') OR (EventCode='5157') OR (EventCode='5158') OR (EventCode='5159'))" 
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\Filtering Platform Connection.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "Filtering Platform Packet Drop"
        Filter   = "(logfile='Security') AND ((EventCode='5152') OR (EventCode='5153'))" 
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\Filtering Platform Packet Drop.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "Filtering Platform Policy Change"
        Filter   = "(logfile='Security') AND ((EventCode='4709') OR (EventCode='4710') OR (EventCode='4711') OR (EventCode='4712') OR (EventCode='5040') OR (EventCode='5041') OR (EventCode='5042') OR (EventCode='5043') OR (EventCode='5044') OR (EventCode='5045') OR (EventCode='5046') OR (EventCode='5047') OR (EventCode='5048') OR (EventCode='5440') OR (EventCode='5441') OR (EventCode='5442') OR (EventCode='5443') OR (EventCode='5444') OR (EventCode='5446') OR (EventCode='5448') OR (EventCode='5449') OR (EventCode='5450') OR (EventCode='5456') OR (EventCode='5457') OR (EventCode='5458') OR (EventCode='5459') OR (EventCode='5460') OR (EventCode='5461') OR (EventCode='5462') OR (EventCode='5463') OR (EventCode='5464') OR (EventCode='5465') OR (EventCode='5466') OR (EventCode='5467') OR (EventCode='5468') OR (EventCode='5471') OR (EventCode='5472') OR (EventCode='5473') OR (EventCode='5474') OR (EventCode='5477'))" 
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\Filtering Platform Policy Change.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "Group Membership"
        Filter   = "(logfile='Security') AND (EventCode='4627')" 
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\Group Membership.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "Handle Manipulation"
        Filter   = "(logfile='Security') AND ((EventCode='4658') OR (EventCode='4690'))" 
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\Handle Manipulation.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "IPSec Driver"
        Filter   = "(logfile='Security') AND ((EventCode='4960') OR (EventCode='4961') OR (EventCode='4962') OR (EventCode='4963') OR (EventCode='4965') OR (EventCode='5478') OR (EventCode='5479') OR (EventCode='5480') OR (EventCode='5483') OR (EventCode='5484') OR (EventCode='5485'))" 
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\IPSec Driver.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "IPSec Extended Mode"
        Filter   = "(logfile='Security') AND ((EventCode='4978') OR (EventCode='4979') OR (EventCode='4980') OR (EventCode='4981') OR (EventCode='4982') OR (EventCode='4983') OR (EventCode='4984'))" 
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\IPSec Extended Mode.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "IPSec Main Mode"
        Filter   = "(logfile='Security') AND ((EventCode='4646') OR (EventCode='4650') OR (EventCode='4651') OR (EventCode='4652') OR (EventCode='4653') OR (EventCode='4655') OR (EventCode='4976') OR (EventCode='5049') OR (EventCode='5453'))" 
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\IPSec Main Mode.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "IPSec Quick Mode"
        Filter   = "(logfile='Security') AND ((EventCode='4977') OR (EventCode='5451') OR (EventCode='5452'))" 
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\IPSec Quick Mode.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "Kerberos Authentication Service"
        Filter   = "(logfile='Security') AND ((EventCode='4768') OR (EventCode='4771') OR (EventCode='4772'))" 
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\Kerberos Authentication Service.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "Kerberos Service Ticket Operations"
        Filter   = "(logfile='Security') AND ((EventCode='4769') OR (EventCode='4770') OR (EventCode='4773'))" 
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\Kerberos Service Ticket Operations.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "Kernel Object"
        Filter   = "(logfile='Security') AND ((EventCode='4656') OR (EventCode='4658') OR (EventCode='4660') OR (EventCode='4663'))" 
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\Kernel Object.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "Logon and Logoff Events"
        Filter   = "(logfile='Security') AND ((EventCode='4624') OR (EventCode='4625') OR (EventCode='4648') OR (EventCode='4675') OR (EventCode='4634') OR (EventCode='4647'))"     
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\Logon and Logoff Events.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "Logon and Logoff Events - Other"
        Filter   = "(logfile='Security') AND ((EventCode='4649') OR (EventCode='4778') OR (EventCode='4779') OR (EventCode='4800') OR (EventCode='4801') OR (EventCode='4802') OR (EventCode='4803') OR (EventCode='5378') OR (EventCode='5632') OR (EventCode='5633'))" 
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\Logon and Logoff Events - Other.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "MPSSVC Rule-Level Policy Change"
        Filter   = "(logfile='Security') AND ((EventCode='4944') OR (EventCode='4945') OR (EventCode='4946') OR (EventCode='4947') OR (EventCode='4948') OR (EventCode='4949') OR (EventCode='4950') OR (EventCode='4951') OR (EventCode='4952') OR (EventCode='4953') OR (EventCode='4954') OR (EventCode='4956') OR (EventCode='4957') OR (EventCode='4958'))" 
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\MPSSVC Rule Level Policy Change.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "Network Policy Server"
        Filter   = "(logfile='Security') AND ((EventCode='6272') OR (EventCode='6273') OR (EventCode='6274') OR (EventCode='6275') OR (EventCode='6276') OR (EventCode='6277') OR (EventCode='6278') OR (EventCode='6279') OR (EventCode='6280'))" 
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\Network Policy Server.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "Other Events"
        Filter   = "(logfile='Security') AND ((EventCode='1100') OR (EventCode='1102') OR (EventCode='1104') OR (EventCode='1105') OR (EventCode='1108'))" 
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\Other Events.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "Other Object Access Events"
        Filter   = "(logfile='Security') AND ((EventCode='4671') OR (EventCode='4691') OR (EventCode='5148') OR (EventCode='5149') OR (EventCode='4698') OR (EventCode='4699') OR (EventCode='4700') OR (EventCode='4701') OR (EventCode='4702') OR (EventCode='5888') OR (EventCode='5889') OR (EventCode='5890'))" 
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\Other Object Access Events.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "Other Policy Change Events"
        Filter   = "(logfile='Security') AND ((EventCode='4714') OR (EventCode='4819') OR (EventCode='4826') OR (EventCode='4909') OR (EventCode='4910') OR (EventCode='5063') OR (EventCode='5064') OR (EventCode='5065') OR (EventCode='5066') OR (EventCode='5067') OR (EventCode='5068') OR (EventCode='5069') OR (EventCode='5070') OR (EventCode='5447') OR (EventCode='6144') OR (EventCode='6145'))" 
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\Other Policy Change Events.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "Other System Events"
        Filter   = "(logfile='Security') AND ((EventCode='5024') OR (EventCode='5025') OR (EventCode='5027') OR (EventCode='5028') OR (EventCode='5029') OR (EventCode='5030') OR (EventCode='5032') OR (EventCode='5033') OR (EventCode='5034') OR (EventCode='5035') OR (EventCode='5037') OR (EventCode='5058') OR (EventCode='5059') OR (EventCode='6400') OR (EventCode='6401') OR (EventCode='6402') OR (EventCode='6403') OR (EventCode='6404') OR (EventCode='6405') OR (EventCode='6406') OR (EventCode='6407') OR (EventCode='6408') OR (EventCode='6409'))" 
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\Other System Events.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "PNP Activity"
        Filter   = "(logfile='Security') AND ((EventCode='6416') OR (EventCode='6419') OR (EventCode='6420') OR (EventCode='6421') OR (EventCode='6422') OR (EventCode='6423') OR (EventCode='6424'))" 
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\PNP Activity.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "Process Creation and Termination"
        Filter   = "(logfile='Security') AND ((EventCode='4688') OR (EventCode='4696') OR (EventCode='4689'))" 
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\Process Creation and Termination.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "Registry"
        Filter   = "(logfile='Security') AND ((EventCode='4663') OR (EventCode='4656') OR (EventCode='4658') OR (EventCode='4660') OR (EventCode='4657') OR (EventCode='5039') OR (EventCode='4670'))" 
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\Registry.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "Removeable Storage"
        Filter   = "(logfile='Security') AND ((EventCode='4656') OR (EventCode='4658') OR (EventCode='4663'))" 
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\Removeable Storage.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "RPC Events"
        Filter   = "(logfile='Security') AND (EventCode='5712')" 
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\RPC Events.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "SAM"
        Filter   = "(logfile='Security') AND (EventCode='4661')" 
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\SAM.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "Security Event Logs Group Management"
        Filter   = "(logfile='Security') AND ((EventCode='4731') OR (EventCode='4732') OR (EventCode='4733') OR (EventCode='4734') OR (EventCode='4735') OR (EventCode='4764') OR (EventCode='4799') OR (EventCode='4727') OR (EventCode='4737') OR (EventCode='4728') OR (EventCode='4729') OR (EventCode='4730') OR (EventCode='4754') OR (EventCode='4755') OR (EventCode='4756') OR (EventCode='4757') OR (EventCode='4758'))" 
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\Security Group Management.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "Security State Change"
        Filter   = "(logfile='Security') AND ((EventCode='4608') OR (EventCode='4609') OR (EventCode='4616') OR (EventCode='4621'))" 
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\Security State Change.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "Security System Extension"
        Filter   = "(logfile='Security') AND ((EventCode='4610') OR (EventCode='4611') OR (EventCode='4614') OR (EventCode='4622') OR (EventCode='4697'))" 
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\Security System Extension.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "Sensitive and Non-Sensitive Privilege Use"
        Filter   = "(logfile='Security') AND ((EventCode='4673') OR (EventCode='4674') OR (EventCode='4985'))" 
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\Sensitive and NonSensitive Privilege Use.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "Special Logon"
        Filter   = "(logfile='Security') AND ((EventCode='4964') OR (EventCode='4672'))" 
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\Special Logon.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "System Integrity"
        Filter   = "(logfile='Security') AND ((EventCode='4612') OR (EventCode='4615') OR (EventCode='4616') OR (EventCode='5038') OR (EventCode='5056') OR (EventCode='5062') OR (EventCode='5057') OR (EventCode='5060') OR (EventCode='5061') OR (EventCode='6281') OR (EventCode='6410'))" 
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\System Integrity.txt"
    }    

    $script:EventLogQueries += [PSCustomObject]@{ 
        Name     = "User and Device Claims"
        Filter   = "(logfile='Security') AND (EventCode='4626')" 
        Message  = "_____"
        FilePath = "$CommandsEventLogsDirectory\By Topic\User and Device Claims.txt"
    }    

#--------------------------------------------
# Event Logs - Event IDs Quick Pick CheckBox
#--------------------------------------------
$EventLogsQuickPickSelectionCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Event IDs Quick Selection"
    Location = @{ X = 220
                  Y = $EventLogsOptionsGroupBox.Location.Y + $EventLogsOptionsGroupBox.Size.Height + 10
                }
    Size     = @{ Width  = 200
                  Height = $EventLogsBoxHeight
                }
    Font     = New-Object System.Drawing.Font("$Font",12,1,2,1)
    ForeColor = 'Blue'
}
$Section1EventLogsTab.Controls.Add($EventLogsQuickPickSelectionCheckbox)

#-----------------------------------------
# Event Logs - Event IDs Quick Pick Label
#-----------------------------------------
$EventLogsQuickPickSelectionLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = "Event IDs by Topic - Can Select Multiple"
    Location = @{ X = 218
                  Y = $EventLogsQuickPickSelectionCheckbox.Location.Y + $EventLogsQuickPickSelectionCheckbox.Size.Height
                }
    Size     = @{ Width  = $EventLogsBoxWidth
                  Height = $EventLogsBoxHeight
                }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Black"
}
#-----------------------------------------------------------
# Event Logs - Event IDs Quick Pick Selection Clear Button
#-----------------------------------------------------------
$EventLogsQuickPickSelectionClearButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Clear"
    Location = @{ X = 356
                  Y = $EventLogsQuickPickSelectionLabel.Location.Y + $EventLogsQuickPickSelectionLabel.Size.Height
                }
    Size     = @{ Width  = 75
                  Height = 20
                }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$EventLogsQuickPickSelectionClearButton.Add_Click({
    # Clears the commands selected
    For ($i=0;$i -lt $EventLogsQuickPickSelectionCheckedlistbox.Items.count;$i++) {
        $EventLogsQuickPickSelectionCheckedlistbox.SetSelected($i,$False)
        $EventLogsQuickPickSelectionCheckedlistbox.SetItemChecked($i,$False)
        $EventLogsQuickPickSelectionCheckedlistbox.SetItemCheckState($i,$False)
    }
})
$Section1EventLogsTab.Controls.Add($EventLogsQuickPickSelectionClearButton) 
$Section1EventLogsTab.Controls.Add($EventLogsQuickPickSelectionLabel) 

#-------------------------------------------------
# Event Logs - Event IDs Quick Pick Checklistbox
#-------------------------------------------------
$EventLogsQuickPickSelectionCheckedlistbox = New-Object -TypeName System.Windows.Forms.CheckedListBox -Property @{
    Name     = "Event Logs Selection"
    Text     = "Event Logs Selection"
    Location = @{ X = 220
                  Y = $EventLogsQuickPickSelectionClearButton.Location.Y + $EventLogsQuickPickSelectionClearButton.Size.Height + 5
                }
    Size     = @{ Width  = 210
                  Height = 150
                }
    #checked = $true
    #CheckOnClick        = $true #so we only have to click once to check a box
    #SelectionMode       = One #This will only allow one options at a time
    ScrollAlwaysVisible = $true
    Font                = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
# Adds a checkbox for each query
foreach ( $Query in $script:EventLogQueries ) { $EventLogsQuickPickSelectionCheckedlistbox.Items.Add("$($Query.Name)") }
$EventLogsQuickPickSelectionCheckedlistbox.Add_Click({
    foreach ( $Query in $script:EventLogQueries ) {
        If ( $Query.Name -imatch $EventLogsQuickPickSelectionCheckedlistbox.SelectedItem ) {
            $ResultsListBox.Items.Clear()
            $CommandFileNotes = Get-Content -Path $Query.FilePath
            foreach ($line in $CommandFileNotes) {$ResultsListBox.Items.Add("$line")}
        }
    }
})
$Section1EventLogsTab.Controls.Add($EventLogsQuickPickSelectionCheckedlistbox)

#============================================================================================================================================================
# Event Logs - Event IDs Individual Selection
#============================================================================================================================================================
if (Test-Path -Path $EventLogsWindowITProCenter) {
    $script:EventLogSeverityQueries = @()

    #####################################################
    # Event Logs - Windows IT Pro Center - From CSV File
    #####################################################

    # The following were obtained from https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/plan/appendix-l--events-to-monitor
    $EventLogNotes = "
    A potential criticality of High means that one occurrence of the event should be investigated. Potential criticality of Medium or Low means that these events should only be investigated if they occur unexpectedly or in numbers that significantly exceed the expected baseline in a measured period of time. All organizations should test these recommendations in their environments before creating alerts that require mandatory investigative responses. Every environment is different, and some of the events ranked with a potential criticality of High may occur due to other harmless events.
    "
    $EventLogsToMonitorMicrosoft = Import-Csv -Path $EventLogsWindowITProCenter
    $EventLogReference           = "https://conf.splunk.com/session/2015/conf2015_MGough_MalwareArchaelogy_SecurityCompliance_FindingAdvnacedAttacksAnd.pdf"
    $EventLogNotes               = Get-Content -Path "$CommandsEventLogsDirectory\Individual Selection\Notes - Event Logs to Monitor - Window IT Pro Center.txt"

    # Adds the Current Event Logs to the Selection Pane
    foreach ($CSVLine in $EventLogsToMonitorMicrosoft) {
        $EventLogQuery = New-Object PSObject -Property @{ EventID = $CSVLine.CurrentWindowsEventID } 
        $EventLogQuery | Add-Member -MemberType NoteProperty -Name LegacyEventID -Value $CSVLine.LegacyWindowsEventID -Force    
        $EventLogQuery | Add-Member -MemberType NoteProperty -Name Label         -Value "Windows IT Pro Center" -Force
        $EventLogQuery | Add-Member -MemberType NoteProperty -Name Severity      -Value $CSVLine.PotentialCriticality -Force
        $EventLogQuery | Add-Member -MemberType NoteProperty -Name Reference     -Value $EventLogReference -Force
        $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message       -Value $CSVLine.EventSummary -Force
        $EventLogQuery | Add-Member -MemberType NoteProperty -Name Notes         -Value $EventLogNotes -Force
        $script:EventLogSeverityQueries += $EventLogQuery
    }
    # Adds the Legacy Event Logs to the Selection Pane
    foreach ($CSVLine in $EventLogsToMonitorMicrosoft) {
        if ($CSVLine.LegacyWindowsEventID -ne "NA") {
            $EventLogQuery = New-Object PSObject -Property @{ EventID = $CSVLine.LegacyWindowsEventID } 
            $EventLogQuery | Add-Member -MemberType NoteProperty -Name LegacyEventID -Value $CSVLine.LegacyWindowsEventID -Force    
            $EventLogQuery | Add-Member -MemberType NoteProperty -Name Label         -Value "Windows IT Pro Center" -Force
            $EventLogQuery | Add-Member -MemberType NoteProperty -Name Severity      -Value $CSVLine.PotentialCriticality -Force
            $EventLogQuery | Add-Member -MemberType NoteProperty -Name Reference     -Value $EventLogReference -Force
            $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message       -Value "<Legacy> $($CSVLine.EventSummary)" -Force
            $EventLogQuery | Add-Member -MemberType NoteProperty -Name Notes         -Value $EventLogNotes -Force
            $script:EventLogSeverityQueries += $EventLogQuery
        }
    }

    #-------------------------------------------------------
    # Event Logs - Event IDs Individual Selection CheckBox
    #-------------------------------------------------------
    $EventLogsEventIDsIndividualSelectionCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
        Text     = "Event IDs Individual Selection"
        Location = @{ X = 7
                      Y = $EventLogsEventIDsManualEntryTextbox.Location.Y + $EventLogsEventIDsManualEntryTextbox.Size.Height + 15
                    }
        Size     = @{ Width  = 350
                      Height = $EventLogsBoxHeight
                    }
        Font     = New-Object System.Drawing.Font("$Font",12,1,2,1)
        ForeColor = 'Blue'
    }
    $Section1EventLogsTab.Controls.Add($EventLogsEventIDsIndividualSelectionCheckbox)

    #-----------------------------------------------------------
    # Event Logs - Event IDs Individual Selection Clear Button
    #-----------------------------------------------------------
    $EventLogsEventIDsIndividualSelectionClearButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Clear"
        Location = @{ X = 356
                      Y = $EventLogsEventIDsIndividualSelectionCheckbox.Location.Y + $EventLogsEventIDsIndividualSelectionCheckbox.Size.Height - 3
                    }
        Size     = @{ Width  = 75
                      Height = 20
                    }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $EventLogsEventIDsIndividualSelectionClearButton.Add_Click({
        # Clears the commands selected
        For ($i=0;$i -lt $EventLogsEventIDsIndividualSelectionChecklistbox.Items.count;$i++) {
            $EventLogsEventIDsIndividualSelectionChecklistbox.SetSelected($i,$False)
            $EventLogsEventIDsIndividualSelectionChecklistbox.SetItemChecked($i,$False)
            $EventLogsEventIDsIndividualSelectionChecklistbox.SetItemCheckState($i,$False)
        }
    })
    $Section1EventLogsTab.Controls.Add($EventLogsEventIDsIndividualSelectionClearButton) 

    #----------------------------------------------------
    # Event Logs - Event IDs Individual Selection Label
    #----------------------------------------------------
    $EventLogsEventIDsIndividualSelectionLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Events IDs to Monitor for Signs of Compromise"
        Location = @{ X = 5
                      Y = $EventLogsEventIDsIndividualSelectionCheckbox.Location.Y + $EventLogsEventIDsIndividualSelectionCheckbox.Size.Height
                    }
        Size     = @{ Width  = $EventLogsBoxWidth
                      Height = $EventLogsBoxHeight
                    }
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = "Black"
    }
    $Section1EventLogsTab.Controls.Add($EventLogsEventIDsIndividualSelectionLabel)

    #-----------------------------------------------------------
    # Event Logs - Event IDs Individual Selection Checklistbox
    #-----------------------------------------------------------
    $EventLogsEventIDsIndividualSelectionChecklistbox = New-Object -TypeName System.Windows.Forms.CheckedListBox -Property @{
        Text     = "Event IDs [Potential Criticality] Event Summary"
        Location = @{ X = 5
                      Y = $EventLogsEventIDsIndividualSelectionLabel.Location.Y + $EventLogsEventIDsIndividualSelectionLabel.Size.Height
                    }
        Size     = @{ Width  = 425
                      Height = 125
                    }
        #checked            = $true
        #CheckOnClick       = $true #so we only have to click once to check a box
        #SelectionMode      = One #This will only allow one options at a time
        ScrollAlwaysVisible = $true
    }
    #----------------------------------------------------
    # Event Logs - Event IDs Individual Populate Dropbox
    #----------------------------------------------------
    # Creates the list from the variable
    foreach ( $Query in $script:EventLogSeverityQueries ) {
        $EventLogsEventIDsIndividualSelectionChecklistbox.Items.Add("$($Query.EventID) [$($Query.Severity)] $($Query.Message)")    
    }
    #
    #$EventLogsEventIDsIndividualSelectionChecklistboxFilter = ""
    $EventLogsEventIDsIndividualSelectionChecklistbox.Add_Click({
        $EventID = $($script:EventLogSeverityQueries | Where {$_.EventID -eq $($($EventLogsEventIDsIndividualSelectionChecklistbox.SelectedItem) -split " ")[0]})
        $Display = @(
            "====================================================================================================",
            "Current Event ID:  $($EventID.EventID)",
            "Legacy Event ID:   $($EventID.LegacyEventID)",
            "===================================================================================================="
            "$($EventID.Message)",
            "Ref: $($EventID.Reference)",
            "===================================================================================================="
            )
        # Adds the data from PSObject
        $ResultsListBox.Items.Clear()
        foreach ($item in $Display) {
            $ResultsListBox.Items.Add($item)
        }
        # Adds the notes 
        foreach ($line in $($EventID.Notes -split "`r`n")) {
            $ResultsListBox.Items.Add($line)
        }

    })
    $EventLogsEventIDsIndividualSelectionChecklistbox.Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    $Section1EventLogsTab.Controls.Add($EventLogsEventIDsIndividualSelectionChecklistbox)
}

#============================================================================================================================================================
# Event Logs - Main Function - Query-EventLog
#============================================================================================================================================================
#
function Query-EventLog {
    param($CollectionName,$Filter)
    $CollectionCommandStartTime = Get-Date 
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Query: $CollectionName")                    
    $ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")
    foreach ($TargetComputer in $ComputerList) {
        Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $CollectedDataTimeStampDirectory `
                                -IndividualHostResults $IndividualHostResults -CollectionName $CollectionName `
                                -TargetComputer $TargetComputer
        Create-LogEntry -TargetComputer $TargetComputer -CollectionName $CollectionName -LogFile $LogFile

        # Builds the Event Log Query Command
        $EventLogQueryCommand  = "Get-WmiObject -Class Win32_NTLogEvent"
        $EventLogQueryComputer = "-ComputerName $TargetComputer"
        if ($EventLogsMaximumCollectionTextBox.Text -eq $null -or $EventLogsMaximumCollectionTextBox.Text -eq '' -or $EventLogsMaximumCollectionTextBox.Text -eq 0) { $EventLogQueryMax = $null}
        else { $EventLogQueryMax = "-First $($EventLogsMaximumCollectionTextBox.Text)" }
        if ( $ComputerListProvideCredentialsCheckBox.Checked ) { $EventLogQueryCredential = "-Credential $script:Credential" }
        else { $EventLogQueryCredential = $null }
        if ( $EventLogsStartTimePicker.Checked -and $EventLogsStopTimePicker.Checked ) {
            $EventLogQueryFilter = @"
-Filter "($Filter and (TimeGenerated>='$([System.Management.ManagementDateTimeConverter]::ToDmtfDateTime(($EventLogsStartTimePicker.Value)))') and (TimeGenerated<='$([System.Management.ManagementDateTimeConverter]::ToDmtfDateTime(($EventLogsStopTimePicker.Value)))'))"
"@
        }
        else { $EventLogQueryFilter = "-Filter `"$Filter`""}
        $EventLogQueryPipe = @"
| Select-Object PSComputerName, LogFile, EventIdentifier, CategoryString, @{Name='TimeGenerated';Expression={[Management.ManagementDateTimeConverter]::ToDateTime(`$_.TimeGenerated)}}, Message, Type $EventLogQueryMax | Export-CSV "$IndividualHostResults\$CollectionName\$CollectionName-$TargetComputer.csv" -NoTypeInformation    
"@



        if ($EventLogWinRMRadioButton.Checked) {
            $EventLogQueryBuild = "Invoke-Command $EventLogQueryComputer $EventLogQueryCredential -ScriptBlock { $EventLogQueryCommand $EventLogQueryFilter $EventLogQueryPipe }"
            $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  $TargetComputer`: $EventLogQueryBuild"
            $LogMessage | Add-Content -Path $LogFile
        }
        elseif ($EventLogRPCRadioButton.Checked) {
            $EventLogQueryBuild = "$EventLogQueryCommand $EventLogQueryComputer $EventLogQueryCredential $EventLogQueryFilter $EventLogQueryPipe"
            $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  $TargetComputer`: $EventLogQueryBuild"
            $LogMessage | Add-Content -Path $LogFile
        }
       
        ### Future code implementation, Currently using WMI via RPC and WinRM (nested withing Invoke-Command)
        #Invoke-Command -ComputerName DellWin10 -Credential (Get-Credential) -ScriptBlock { Get-WinEvent -ComputerName DellWin10 -FilterHashtable @{LogName='Security';Id='4624';StartTime=(Get-Date -Date '5/19/2019 8:00:00 AM');EndTime=(Get-Date -Date '5/19/2019 5:00:00 PM')} | Select @{Name="PSComputerName";Expression={$_.MachineName}}, LogName, Id, ProcessId, TimeCreated, Message, @{Name="KeywordsDisplayNames";Expression={$_.KeywordsDisplayNames}} -First 10 }
        
        Start-Job -Name "PoSh-ACME: $CollectionName -- $TargetComputer" -ScriptBlock {
            param($ThreadPriority,$EventLogQueryBuild)
            Invoke-Expression -Command $ThreadPriority
            Invoke-Expression -Command $EventLogQueryBuild
        } -ArgumentList @($ThreadPriority,$EventLogQueryBuild)
    }
    Monitor-Jobs
    $CollectionCommandEndTime  = Get-Date                    
    $CollectionCommandDiffTime = New-TimeSpan -Start $CollectionCommandStartTime -End $CollectionCommandEndTime
    $ResultsListBox.Items.RemoveAt(0)
    $ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $CollectionName")
    Compile-CsvFiles -LocationOfCSVsToCompile   "$($IndividualHostResults)\$($CollectionName)\$($CollectionName)*.csv" `
                     -LocationToSaveCompiledCSV "$($CollectedDataTimeStampDirectory)\$($CollectionName).csv"

}

#============================================================================================================================================================
# Event Logs - Funtions / Commands
#============================================================================================================================================================
function EventLogsEventCodeManualEntryCommand {
    $CollectionName = "Event Logs - Event IDs Manual Entry"

    $ManualEntry = $EventLogsEventIDsManualEntryTextbox.Text -split "`r`n"
    $ManualEntry = $ManualEntry -replace " ","" -replace "a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z",""
    $ManualEntry = $ManualEntry | Where-Object {$_.trim() -ne ""}

    # Variables begins with an open "(
    $EventLogsEventIDsManualEntryTextboxFilter = '('

    foreach ($EventCode in $ManualEntry) {
        $EventLogsEventIDsManualEntryTextboxFilter += "(EventCode='$EventCode') OR "
    }
    # Replaces the ' OR ' at the end of the varable with a closing )"
    $Filter = $EventLogsEventIDsManualEntryTextboxFilter -replace " OR $",")"
    Query-EventLog -CollectionName $CollectionName -Filter $Filter
}
function EventLogsEventCodeIndividualSelectionCommand {
    $CollectionName = "Event Logs - Event IDs Indiviual Selection"

    # Variables begins with an open "(
    $EventLogsEventIDsIndividualSelectionChecklistboxFilter = '('
    foreach ($Checked in $EventLogsEventIDsIndividualSelectionChecklistbox.CheckedItems) {
        # Get's just the EventID from the checkbox
        $Checked = $($Checked -split " ")[0]

        $EventLogsEventIDsIndividualSelectionChecklistboxFilter += "(EventCode='$Checked') OR "
    }
    # Replaces the ' OR ' at the end of the varable with a closing )"
    $Filter = $EventLogsEventIDsIndividualSelectionChecklistboxFilter -replace " OR $",")"
    Query-EventLog -CollectionName $CollectionName -Filter $Filter
}

#=====================================================================================================================================================
#   _______ __          __  __           __                         __   ___    ____  _____    _____                      __       ______      __  
#   / ____(_) /__       / / / /___ ______/ /_       ____ _____  ____/ /  /   |  / __ \/ ___/   / ___/___  ____ ___________/ /_     /_  __/___ _/ /_ 
#  / /_  / / / _ \     / /_/ / __ `/ ___/ __ \     / __ `/ __ \/ __  /  / /| | / / / /\__ \    \__ \/ _ \/ __ `/ ___/ ___/ __ \     / / / __ `/ __ \
# / __/ / / /  __/    / __  / /_/ (__  ) / / /    / /_/ / / / / /_/ /  / ___ |/ /_/ /___/ /   ___/ /  __/ /_/ / /  / /__/ / / /    / / / /_/ / /_/ /
#/_/   /_/_/\___( )  /_/ /_/\__,_/____/_/ /_( )   \__,_/_/ /_/\__,_/  /_/  |_/_____//____/   /____/\___/\__,_/_/   \___/_/ /_/    /_/  \__,_/_.___/ 
#               |/                          |/                                                                                                      
#=====================================================================================================================================================

#######################################################################################################################################################################
##           ##
##  SUB-TAB  ## File, Hash, and ADS Search
##           ##
#######################################################################################################################################################################

# Varables
$FileSearchRightPosition     = 3
$FileSearchDownPosition      = -10
$FileSearchDownPositionShift = 25
$FileSearchLabelWidth        = 450
$FileSearchLabelHeight       = 22
$FileSearchButtonWidth       = 110
$FileSearchButtonHeight      = 22

$Section1FileSearchTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text                    = "File, Hash, and ADS Search"
    Location                = New-Object System.Drawing.Point($FileSearchRightPosition,$FileSearchDownPosition) 
    Size                    = New-Object System.Drawing.Size($FileSearchLabelWidth,$FileSearchLabelHeight) 
    Font                    = New-Object System.Drawing.Font("$Font",11,0,0,0)
    UseVisualStyleBackColor = $True
}
$Section1CollectionsTabControl.Controls.Add($Section1FileSearchTab)

# Shift the fields
$FileSearchDownPosition += $FileSearchDownPositionShift

#============================================================================================================================================================
# File Search - Directory Listing
#============================================================================================================================================================

# This function is used for backwards compatibility, newer versions of PowerShell has a -Depth parameter 
$GetChildItemRecurse = @"
Function Get-ChildItemRecurse {
    Param(
        [String]`$Path   = `$PWD,
        [String]`$Filter = "*",
        [Byte]`$Depth    = `$MaxDepth
    )
    `$CurrentDepth++
    `$RecursiveListing = New-Object PSObject
    Get-ChildItem `$Path -Filter `$Filter -Force | Foreach { 
        `$RecursiveListing | Add-Member -MemberType NoteProperty -Name PSComputerName -Value `$TargetComputer -Force
        #`$RecursiveListing | Add-Member -MemberType NoteProperty -Name DirectoryName -Value `$_.DirectoryName -Force
        `$RecursiveListing | Add-Member -MemberType NoteProperty -Name Directory -Value `$_.Directory -Force
        `$RecursiveListing | Add-Member -MemberType NoteProperty -Name Name -Value `$_.Name -Force
        `$RecursiveListing | Add-Member -MemberType NoteProperty -Name BaseName -Value `$_.BaseName -Force
        `$RecursiveListing | Add-Member -MemberType NoteProperty -Name Extension -Value `$_.Extension -Force
        `$RecursiveListing | Add-Member -MemberType NoteProperty -Name Attributes -Value `$_.Attributes -Force
        `$RecursiveListing | Add-Member -MemberType NoteProperty -Name CreationTime -Value `$_.CreationTime -Force
        `$RecursiveListing | Add-Member -MemberType NoteProperty -Name LastWriteTime -Value `$_.LastWriteTime -Force
        `$RecursiveListing | Add-Member -MemberType NoteProperty -Name LastAccessTime -Value `$_.LastAccessTime -Force
        `$RecursiveListing | Add-Member -MemberType NoteProperty -Name FullName -Value `$_.FullName -Force
        `$RecursiveListing | Add-Member -MemberType NoteProperty -Name PSIsContainer -Value `$_.PSIsContainer -Force
                                    
        If (`$_.PsIsContainer) {
            If (`$CurrentDepth -le `$Depth) {                
                Get-ChildItemRecurse -Path `$_.FullName -Filter `$Filter -Depth `$MaxDepth -CurrentDepth `$CurrentDepth
            }
        }
        return `$RecursiveListing
    }
}
"@

#--------------------------------------------------
# File Search - Directory Listing CheckBox Command
#--------------------------------------------------
function FileSearchDirectoryListingCommand {
    $CollectionName = "Directory Listing"
    $CollectionCommandStartTime = Get-Date 
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Query: $CollectionName")                    
    $ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")
    foreach ($TargetComputer in $ComputerList) {
        param(
            $CollectedDataTimeStampDirectory, 
            $IndividualHostResults, 
            $CollectionName, 
            $TargetComputer
        )
        Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $CollectedDataTimeStampDirectory `
                                -IndividualHostResults $IndividualHostResults -CollectionName $CollectionName `
                                -TargetComputer $TargetComputer
        Create-LogEntry -TargetComputer $TargetComputer -CollectionName $CollectionName -LogFile $LogFile

        $DirectoryPath = $FileSearchDirectoryListingTextbox.Text
        $MaximumDepth  = $FileSearchDirectoryListingMaxDepthTextbox.text

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$script:Credential) { $script:Credential = Get-Credential }
            $QueryCredentialParam = ", $script:Credential"
            $QueryCredential      = "-Credential $script:Credential"
        }
        else {
            $QueryCredentialParam = $null
            $QueryCredential      = $null        
        }
$QueryJob= @"
        Start-Job -Name "PoSh-ACME: `$(`$CollectionName) -- `$(`$TargetComputer)" -ScriptBlock {
            param(`$TargetComputer, `$DirectoryPath, `$MaximumDepth, `$IndividualHostResults, `$CollectionName $QueryCredentialParam)
            [System.Threading.Thread]::CurrentThread.Priority = 'High'
            ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'High'

            `$FilesFoundList = @()
            `$FilesFound = Invoke-Command -ComputerName `$TargetComputer $QueryCredential -ScriptBlock {
                param(`$DirectoryPath, `$MaximumDepth, `$TargetComputer)

                $GetChildItemRecurse

            `$MaxDepth = `$MaximumDepth
            `$Path = `$DirectoryPath
                        
            Get-ChildItemRecurse -Path `$Path -Depth `$MaxDepth | Where-Object { `$_.PSIsContainer -eq `$false }

            } -ArgumentList @(`$DirectoryPath, `$MaximumDepth, `$TargetComputer)
                        
            `$FilesFoundList += `$FilesFound | Select-Object -Property PSComputerName, Directory, Name, BaseName, Extension, Attributes, CreationTime, LastWriteTime, LastAccessTime, FullName
                
            `$FilesFoundList | Export-CSV "`$(`$IndividualHostResults)\`$(`$CollectionName)\`$(`$CollectionName)-`$(`$TargetComputer).csv" -NoTypeInformation
        } -ArgumentList @(`$TargetComputer, `$DirectoryPath, `$MaximumDepth, `$IndividualHostResults, `$CollectionName $QueryCredentialParam)
"@
    }
    Invoke-Expression -Command $QueryJob
    Monitor-Jobs
    $CollectionCommandEndTime  = Get-Date                    
    $CollectionCommandDiffTime = New-TimeSpan -Start $CollectionCommandStartTime -End $CollectionCommandEndTime
    $ResultsListBox.Items.RemoveAt(0)
    $ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $CollectionName")
    Compile-CsvFiles -LocationOfCSVsToCompile   "$($IndividualHostResults)\$($CollectionName)\$($CollectionName)*.csv" `
                     -LocationToSaveCompiledCSV "$($CollectedDataTimeStampDirectory)\$($CollectionName).csv"
    #not needed# Remove-DuplicateCsvHeaders
}

$FileSearchDirectoryListingCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Directory Listing (WinRM)"
    Location = New-Object System.Drawing.Point($FileSearchRightPosition,$FileSearchDownPosition)
    Size     = New-Object System.Drawing.Size(230,$FileSearchLabelHeight) 
    Font     = New-Object System.Drawing.Font("$Font",12,1,2,1)
    ForeColor = 'Blue'
}
$Section1FileSearchTab.Controls.Add($FileSearchDirectoryListingCheckbox)

#--------------------------------------------------
# File Search - Directory Listing Max Depth Label
#--------------------------------------------------
$FileSearchDirectoryListingMaxDepthLabel = New-Object System.Windows.Forms.Label -Property @{
    Text       = "Recursive Depth"
    Location   = New-Object System.Drawing.Point(($FileSearchDirectoryListingCheckbox.Size.Width + 52),($FileSearchDownPosition + 3)) 
    Size       = New-Object System.Drawing.Size(100,$FileSearchLabelHeight) 
    Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor  = "Black"
}
$Section1FileSearchTab.Controls.Add($FileSearchDirectoryListingMaxDepthLabel)

#----------------------------------------------------
# File Search - Directory Listing Max Depth Textbox
#----------------------------------------------------
$FileSearchDirectoryListingMaxDepthTextbox = New-Object System.Windows.Forms.TextBox -Property @{
    Text           = 0
    Location       = New-Object System.Drawing.Size(($FileSearchDirectoryListingMaxDepthLabel.Location.X + $FileSearchDirectoryListingMaxDepthLabel.Size.Width),($FileSearchDownPosition)) 
    Size           = New-Object System.Drawing.Size(50,20)
    MultiLine      = $false
    WordWrap       = $false
    Font           = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
#$FileSearchDirectoryListingMaxDepthTextbox.Add_KeyDown({          })
$Section1FileSearchTab.Controls.Add($FileSearchDirectoryListingMaxDepthTextbox)

# Shift the fields
$FileSearchDownPosition += $FileSearchDownPositionShift

#----------------------------------------------
# File Search - Directory Listing Label
#----------------------------------------------
$FileSearchDirectoryListingLabel = New-Object System.Windows.Forms.Label -Property @{
    Location  = New-Object System.Drawing.Point($FileSearchRightPosition,$FileSearchDownPosition) 
    Size      = New-Object System.Drawing.Size($FileSearchLabelWidth,$FileSearchLabelHeight) 
    Text      = "Collection time is dependant on the directory's contents."
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Black"
}
$Section1FileSearchTab.Controls.Add($FileSearchDirectoryListingLabel)

# Shift the fields
$FileSearchDownPosition += $FileSearchDownPositionShift

#----------------------------------------------------
# File Search - Directory Listing Directory Textbox
#----------------------------------------------------
$FileSearchDirectoryListingTextbox = New-Object System.Windows.Forms.TextBox -Property @{
    Location           = New-Object System.Drawing.Size($FileSearchRightPosition,($FileSearchDownPosition)) 
    Size               = New-Object System.Drawing.Size(430,22)
    MultiLine          = $False
    #ScrollBars         = "Vertical"
    WordWrap           = $false
    Text               = "Enter a single directory"
    AutoCompleteSource = "FileSystem" # Options are: FileSystem, HistoryList, RecentlyUsedList, AllURL, AllSystemSources, FileSystemDirectories, CustomSource, ListItems, None
    AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
    Font               = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
#$FileSearchDirectoryListingTextbox.Add_KeyDown({          })
$FileSearchDirectoryListingTextbox.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ Enter a single directory`n⦿ Example - C:\Windows\System32`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage3))
        $ToolTip.Active       = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation = $true
        $ToolTip.UseFading    = $true
        $ToolTip.IsBalloon    = $true
        $ToolTip.ToolTipIcon  = "Info"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle = 'Directory Listing (WinRM)'
    }
})
$FileSearchDirectoryListingTextbox.Add_MouseEnter({
    if ($FileSearchDirectoryListingTextbox.text -eq "Enter a single directory"){ $FileSearchDirectoryListingTextbox.text = "" }
})
$FileSearchDirectoryListingTextbox.Add_MouseLeave({ 
    if ($FileSearchDirectoryListingTextbox.text -eq ""){ $FileSearchDirectoryListingTextbox.text = "Enter a single directory" }
})
$Section1FileSearchTab.Controls.Add($FileSearchDirectoryListingTextbox)

# Shift the fields
$FileSearchDownPosition += $FileSearchDownPositionShift + $FileSearchDirectoryListingTextbox.Size.Height

#============================================================================================================================================================
# File Search - File and Hash Search
#============================================================================================================================================================

function FileSearchFileSearchCommand {
    $CollectionName = "File and Hash Search"
    $CollectionCommandStartTime = Get-Date 
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Query: $CollectionName")                    
    $ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")
    foreach ($TargetComputer in $ComputerList) {
        param(
            $CollectedDataTimeStampDirectory, 
            $IndividualHostResults, 
            $CollectionName, 
            $TargetComputer
        )
        Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $CollectedDataTimeStampDirectory `
                                -IndividualHostResults $IndividualHostResults -CollectionName $CollectionName `
                                -TargetComputer $TargetComputer
        Create-LogEntry -TargetComputer $TargetComputer -CollectionName $CollectionName -LogFile $LogFile

        $DirectoriesToSearch = $FileSearchFileSearchDirectoryTextbox.Text -split "`r`n"
        $FilesToSearch       = $FileSearchFileSearchFileTextbox.Text -split "`r`n"
        $MaximumDepth        = $FileSearchFileSearchMaxDepthTextbox.text
        $FileHashSelection   = $FileSearchSelectFileHashCheckbox.Text

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$script:Credential) { $script:Credential = Get-Credential }
            $QueryCredentialParam = ", $script:Credential"
            $QueryCredential      = "-Credential $script:Credential"
        }
        else {
            $QueryCredentialParam = $null
            $QueryCredential      = $null        
        }
$QueryJob= @"
        Start-Job -Name "PoSh-ACME: `$(`$CollectionName) -- `$(`$TargetComputer)" -ScriptBlock {
            param(`$DirectoriesToSearch, `$FilesToSearch, `$TargetComputer, `$DirectoryPath, `$Filename, `$MaximumDepth, `$IndividualHostResults, `$CollectionName $QueryCredentialParam)
            [System.Threading.Thread]::CurrentThread.Priority = 'High'
            ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'High'

            `$FilesFoundList = @()
            foreach (`$DirectoryPath in `$DirectoriesToSearch) {
                foreach (`$Filename in `$FilesToSearch) {
                    `$FilesFound = Invoke-Command -ComputerName `$TargetComputer $QueryCredential -ScriptBlock {
                        param(`$DirectoryPath, `$Filename, `$MaximumDepth, `$TargetComputer)

                    $GetChildItemRecurse

                    `$MaxDepth = `$MaximumDepth
                    `$Path = `$DirectoryPath
                        
                    Get-ChildItemRecurse -Path `$Path -Depth `$MaxDepth | Where-Object { (`$_.PSIsContainer -eq `$false) -and (`$_.Name -match "`$Filename") }
                    } -ArgumentList @(`$DirectoryPath, `$Filename, `$MaximumDepth, `$TargetComputer)
                        
                    `$FilesFoundList += `$FilesFound | Select-Object -Property PSComputerName, Directory, Name, BaseName, Extension, Attributes, CreationTime, LastWriteTime, LastAccessTime, FullName
                }
            }
            `$FilesFoundList | Export-CSV "`$(`$IndividualHostResults)\`$(`$CollectionName)\`$(`$CollectionName)-`$(`$TargetComputer).csv" -NoTypeInformation
        } -ArgumentList @(`$DirectoriesToSearch, `$FilesToSearch, `$TargetComputer, `$DirectoryPath, `$Filename, `$MaximumDepth, `$IndividualHostResults, `$CollectionName $QueryCredentialParam)
"@
    }
    Invoke-Expression -Command $QueryJob
    Monitor-Jobs
    $CollectionCommandEndTime  = Get-Date                    
    $CollectionCommandDiffTime = New-TimeSpan -Start $CollectionCommandStartTime -End $CollectionCommandEndTime
    $ResultsListBox.Items.RemoveAt(0)
    $ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $CollectionName")
    Compile-CsvFiles -LocationOfCSVsToCompile   "$($IndividualHostResults)\$($CollectionName)\$($CollectionName)*.csv" `
                     -LocationToSaveCompiledCSV "$($CollectedDataTimeStampDirectory)\$($CollectionName).csv"
    #not needed# Remove-DuplicateCsvHeaders
}

#---------------------------------------------------
# File Search - File Search Command CheckBox
#---------------------------------------------------
$FileSearchFileSearchCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "File Search (WinRM)"
    Location = New-Object System.Drawing.Size(($FileSearchRightPosition),($FileSearchDownPosition)) 
    Size     = New-Object System.Drawing.Size((230),$FileSearchLabelHeight)
    Font     = New-Object System.Drawing.Font("$Font",12,1,2,1)
    ForeColor = 'Blue'
}
$Section1FileSearchTab.Controls.Add($FileSearchFileSearchCheckbox)

#--------------------------------------------------
# File Search - File Search Max Depth Label
#--------------------------------------------------
$FileSearchFileSearchMaxDepthLabel            = New-Object System.Windows.Forms.Label -Property @{
    Text       = "Recursive Depth"
    Location   = New-Object System.Drawing.Point(($FileSearchFileSearchCheckbox.Size.Width + 52),($FileSearchDownPosition + 3)) 
    Size       = New-Object System.Drawing.Size(100,$FileSearchLabelHeight) 
    Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor  = "Black"
}
$Section1FileSearchTab.Controls.Add($FileSearchFileSearchMaxDepthLabel)

#----------------------------------------------------
# File Search - File Search Max Depth Textbox
#----------------------------------------------------
$FileSearchFileSearchMaxDepthTextbox = New-Object System.Windows.Forms.TextBox -Property @{
    Text           = 0
    Location       = New-Object System.Drawing.Size(($FileSearchFileSearchMaxDepthLabel.Location.X + $FileSearchFileSearchMaxDepthLabel.Size.Width),($FileSearchDownPosition)) 
    Size           = New-Object System.Drawing.Size(50,20)
    MultiLine      = $false
    #ScrollBars    = "Vertical"
    WordWrap       = $false
    #AcceptsTab    = $false
    #AcceptsReturn = $false
    Font           = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
#$FileSearchFileSearchMaxDepthTextbox.Add_KeyDown({          })
$Section1FileSearchTab.Controls.Add($FileSearchFileSearchMaxDepthTextbox)

# Shift the fields
$FileSearchDownPosition += $FileSearchDownPositionShift

#--------------------------------------------------------
# File Search - File Search Select FileHash CheckListBox
#--------------------------------------------------------
$FileSearchSelectFileHashCheckbox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text     = "Select FileHashes - Default is None"
    Location = New-Object System.Drawing.Point($FileSearchRightPosition,$FileSearchDownPosition) 
    Size     = New-Object System.Drawing.Size(200,$FileSearchLabelHeight) 
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
    $HashList = @('None', 'MD5','SHA1','SHA256','SHA512','MD5 + SHA1','MD5 + SHA256','MD5 + SHA512','MD5 + SHA1 + SHA256 + SHA512')
    ForEach ($Hash in $HashList) { $FileSearchSelectFileHashCheckbox.Items.Add($Hash) }
$Section1FileSearchTab.Controls.Add($FileSearchSelectFileHashCheckbox)

# Shift the fields
$FileSearchDownPosition += $FileSearchDownPositionShift

#----------------------------------------
# File Search - File Search Label
#----------------------------------------
$FileSearchFileSearchLabel = New-Object System.Windows.Forms.Label -Property @{
    Location  = New-Object System.Drawing.Point($FileSearchRightPosition,$FileSearchDownPosition) 
    Size      = New-Object System.Drawing.Size($FileSearchLabelWidth,$FileSearchLabelHeight) 
    Text      = "Collection time depends on the number of files and directories, plus recursive depth."
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Black"
}
$Section1FileSearchTab.Controls.Add($FileSearchFileSearchLabel)

# Shift the fields
$FileSearchDownPosition += $FileSearchDownPositionShift - 3

#------------------------------------------------
# File Search - File Search Files Textbox
#------------------------------------------------
$FileSearchFileSearchFileTextbox = New-Object System.Windows.Forms.TextBox -Property @{
    Location            = New-Object System.Drawing.Point($FileSearchRightPosition,($FileSearchDownPosition)) 
    Size                = New-Object System.Drawing.Size(430,(80))
    MultiLine           = $True
    ScrollBars          = "Vertical" #Horizontal
    WordWrap            = $false
    AcceptsTab          = $false    # Allows you to enter in tabs into the textbox
    AcceptsReturn       = $false # Allows you to enter in tabs into the textbox
    AllowDrop           = $true
    Text                = "Enter FileNames; One Per Line"
    Font                = New-Object System.Drawing.Font("$Font",11,0,0,0)
    #AutoCompleteSource = "FileSystem" # Options are: FileSystem, HistoryList, RecentlyUsedList, AllURL, AllSystemSources, FileSystemDirectories, CustomSource, ListItems, None
    #AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
}
#$FileSearchFileSearchFileTextbox.Add_KeyDown({          })
$FileSearchFileSearchFileTextbox.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ Enter FileNames
⦿ One Per Line
⦿ Filenames don't have to include file extension
⦿ This search will also find the keyword within the filename`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage3))
        $ToolTip.Active       = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation = $true
        $ToolTip.UseFading    = $true
        $ToolTip.IsBalloon    = $true
        $ToolTip.ToolTipIcon  = "Info"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle = 'File Search (WinRM)'
    }
})
$FileSearchFileSearchFileTextbox.Add_MouseEnter({
    if ($FileSearchFileSearchFileTextbox.text -eq "Enter FileNames; One Per Line"){ $FileSearchFileSearchFileTextbox.text = "" }
})
$FileSearchFileSearchFileTextbox.Add_MouseLeave({ 
    if ($FileSearchFileSearchFileTextbox.text -eq ""){ $FileSearchFileSearchFileTextbox.text = "Enter FileNames; One Per Line" }
})
$Section1FileSearchTab.Controls.Add($FileSearchFileSearchFileTextbox)

# Shift the fields
$FileSearchDownPosition += $FileSearchFileSearchFileTextbox.Size.Height + 5

#---------------------------------------------
# File Search - File Search Directory Textbox
#---------------------------------------------
$FileSearchFileSearchDirectoryTextbox = New-Object System.Windows.Forms.TextBox -Property @{
    Location            = New-Object System.Drawing.Point($FileSearchRightPosition,($FileSearchDownPosition)) 
    Size                = New-Object System.Drawing.Size(430,(80))
    MultiLine           = $True
    ScrollBars          = "Vertical"
    WordWrap            = $True
    AcceptsTab          = $false    # Allows you to enter in tabs into the textbox
    AcceptsReturn       = $false # Allows you to enter in tabs into the textbox
    Text                = "Enter Directories; One Per Line"
    Font                = New-Object System.Drawing.Font("$Font",11,0,0,0)
    #AutoCompleteSource = "FileSystem" # Options are: FileSystem, HistoryList, RecentlyUsedList, AllURL, AllSystemSources, FileSystemDirectories, CustomSource, ListItems, None
    #AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
}
#$FileSearchFileSearchDirectoryTextbox.Add_KeyDown({          })
$FileSearchFileSearchDirectoryTextbox.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ Enter Directories
⦿ One Per Line`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage3))
        $ToolTip.Active       = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation = $true
        $ToolTip.UseFading    = $true
        $ToolTip.IsBalloon    = $true
        $ToolTip.ToolTipIcon  = "Info"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle = 'File Search (WinRM)'
    }
})
$FileSearchFileSearchDirectoryTextbox.Add_MouseEnter({
    if ($FileSearchFileSearchDirectoryTextbox.text -eq "Enter Directories; One Per Line"){ $FileSearchFileSearchDirectoryTextbox.text = "" }
})
$FileSearchFileSearchDirectoryTextbox.Add_MouseLeave({ 
    if ($FileSearchFileSearchDirectoryTextbox.text -eq ""){ $FileSearchFileSearchDirectoryTextbox.text = "Enter Directories; One Per Line" }
})
$Section1FileSearchTab.Controls.Add($FileSearchFileSearchDirectoryTextbox)

# Shift the fields
$FileSearchDownPosition += $FileSearchFileSearchDirectoryTextbox.Size.Height + 5

# Shift the fields
$FileSearchDownPosition += $FileSearchDownPositionShift - 3

#============================================================================================================================================================
# File Search - Alternate Data Stream Function
#============================================================================================================================================================

function FileSearchAlternateDataStreamCommand {
    $CollectionName = "Alternate Data Stream"
    $CollectionCommandStartTime = Get-Date 
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Query: $CollectionName")                    
    $ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")
    foreach ($TargetComputer in $ComputerList) {
        param(
            $CollectedDataTimeStampDirectory, 
            $IndividualHostResults, 
            $CollectionName, 
            $TargetComputer
        )
        Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $CollectedDataTimeStampDirectory `
                                -IndividualHostResults $IndividualHostResults -CollectionName $CollectionName `
                                -TargetComputer $TargetComputer
        Create-LogEntry -TargetComputer $TargetComputer -CollectionName $CollectionName -LogFile $LogFile

        $DirectoriesToSearch = $FileSearchAlternateDataStreamDirectoryTextbox.Text -split "`r`n"
        $MaximumDepth        = $FileSearchAlternateDataStreamMaxDepthTextbox.text

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$script:Credential) { $script:Credential = Get-Credential }
            $QueryCredentialParam = ", $script:Credential"
            $QueryCredential      = "-Credential $script:Credential"
        }
        else {
            $QueryCredentialParam = $null
            $QueryCredential      = $null        
        }
$QueryJob = @"
        Start-Job -Name "PoSh-ACME: `$(`$CollectionName) -- `$(`$TargetComputer)" -ScriptBlock {
            param(`$DirectoriesToSearch, `$TargetComputer, `$MaximumDepth, `$IndividualHostResults, `$CollectionName $QueryCredentialParam)
            [System.Threading.Thread]::CurrentThread.Priority = 'High'
            ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'High'

            foreach (`$DirectoryPath in `$DirectoriesToSearch) {
                `$FilesFound = Invoke-Command -ComputerName `$TargetComputer $QueryCredential -ScriptBlock {
                    param(`$DirectoryPath, `$MaximumDepth, `$TargetComputer)

                    $GetChildItemRecurse

                    Get-ChildItemRecurse -Path `$DirectoryPath -Depth `$MaximumDepth
                } -ArgumentList @(`$DirectoryPath, `$MaximumDepth, `$TargetComputer)
                    
                `$AdsFound = `$FilesFound | ForEach-Object { Get-Item `$_.FullName -Force -Stream * -ErrorAction SilentlyContinue } | Where-Object stream -ne ':`$DATA'
                foreach (`$Ads in `$AdsFound) {
                    `$AdsData = Get-Content -Path "`$(`$Ads.FileName)" -Stream "`$(`$Ads.Stream)"
                    `$Ads | Add-Member -MemberType NoteProperty -Name PSComputerName -Value `$TargetComputer
                    `$Ads | Add-Member -MemberType NoteProperty -Name StreamData -Value `$AdsData
                    if     ((`$Ads.Stream -eq 'Zone.Identifier') -and (`$Ads.StreamData -match 'ZoneID=0')) { `$Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "[ZoneID 0] Local Machine Zone: The most trusted zone for content that exists on the local computer." }
                    elseif ((`$Ads.Stream -eq 'Zone.Identifier') -and (`$Ads.StreamData -match 'ZoneID=1')) { `$Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "[ZoneID 1] Local Intranet Zone: For content located on an organization’s intranet." }
                    elseif ((`$Ads.Stream -eq 'Zone.Identifier') -and (`$Ads.StreamData -match 'ZoneID=2')) { `$Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "[ZoneID 2] Trusted Sites Zone: For content located on Web sites that are considered more reputable or trustworthy than other sites on the Internet." }
                    elseif ((`$Ads.Stream -eq 'Zone.Identifier') -and (`$Ads.StreamData -match 'ZoneID=3')) { `$Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "[ZoneID 3] Internet Zone: For Web sites on the Internet that do not belong to another zone." }
                    elseif ((`$Ads.Stream -eq 'Zone.Identifier') -and (`$Ads.StreamData -match 'ZoneID=4')) { `$Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "[ZoneID 4] Restricted Sites Zone: For Web sites that contain potentially-unsafe content." }
                    else {`$Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "N/A"}                           
                }
            }        
            `$AdsFound | Select-Object -Property @{Name='PSComputerName';Expression={`$(hostname)}}, FileName, Stream, @{Name="StreamDataSample";Expression={`$(`$(`$_.StreamData | Out-String)[0..100] -join '')}}, ZoneId , Length | Export-CSV "`$(`$IndividualHostResults)\`$(`$CollectionName)\`$(`$CollectionName)-`$(`$TargetComputer).csv" -NoTypeInformation
        } -ArgumentList @(`$DirectoriesToSearch, `$TargetComputer, `$MaximumDepth, `$IndividualHostResults, `$CollectionName $QueryCredentialParam)
"@
    }
    Invoke-Expression -Command $QueryJob
    Monitor-Jobs
    $CollectionCommandEndTime  = Get-Date                    
    $CollectionCommandDiffTime = New-TimeSpan -Start $CollectionCommandStartTime -End $CollectionCommandEndTime
    $ResultsListBox.Items.RemoveAt(0)
    $ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $CollectionName")
    Compile-CsvFiles -LocationOfCSVsToCompile   "$($IndividualHostResults)\$($CollectionName)\$($CollectionName)*.csv" `
                     -LocationToSaveCompiledCSV "$($CollectedDataTimeStampDirectory)\$($CollectionName).csv"
    #not needed# Remove-DuplicateCsvHeaders
}

#--------------------------------------------------------
# File Search - File Search AlternateDataStream CheckBox
#--------------------------------------------------------
$FileSearchAlternateDataStreamCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Alternate Data Stream Search (WinRM)"
    Location = New-Object System.Drawing.Point(($FileSearchRightPosition),($FileSearchDownPosition)) 
    Size     = New-Object System.Drawing.Size((250),$FileSearchLabelHeight)
    Font     = New-Object System.Drawing.Font("$Font",12,1,2,1)
    ForeColor = 'Blue'
}
$Section1FileSearchTab.Controls.Add($FileSearchAlternateDataStreamCheckbox)

#-----------------------------------------------------
# File Search - Alternate Data Stream Max Depth Label
#-----------------------------------------------------
$FileSearchAlternateDataStreamMaxDepthLabel = New-Object System.Windows.Forms.Label -Property @{
    Location = New-Object System.Drawing.Point(($FileSearchFileSearchCheckbox.Size.Width + 52),($FileSearchDownPosition + 3)) 
    Size     = New-Object System.Drawing.Size(100,$FileSearchLabelHeight) 
    Text     = "Recursive Depth"
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
#$FileSearchAlternateDataStreamMaxDepthLabel.ForeColor  = "Blue"
$Section1FileSearchTab.Controls.Add($FileSearchAlternateDataStreamMaxDepthLabel)

#-------------------------------------------------------
# File Search - Alternate Data Stream Max Depth Textbox
#-------------------------------------------------------
$FileSearchAlternateDataStreamMaxDepthTextbox = New-Object System.Windows.Forms.TextBox -Property @{
    Text           = 0
    Location       = New-Object System.Drawing.Point(($FileSearchAlternateDataStreamMaxDepthLabel.Location.X + $FileSearchAlternateDataStreamMaxDepthLabel.Size.Width),($FileSearchDownPosition)) 
    Size           = New-Object System.Drawing.Size(50,20)
    MultiLine      = $false
    #ScrollBars    = "Vertical"
    WordWrap       = $false
    #AcceptsTab    = $false
    #AcceptsReturn = $false    
    Font           = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
#$FileSearchAlternateDataStreamMaxDepthTextbox.Add_KeyDown({          })
$Section1FileSearchTab.Controls.Add($FileSearchAlternateDataStreamMaxDepthTextbox)

# Shift the fields
$FileSearchDownPosition += $FileSearchAlternateDataStreamCheckbox.Size.Height + 5

#-------------------------------------------
# File Search - Alternate Data Stream Label
#-------------------------------------------
$FileSearchAlternateDataStreamLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = "Exlcudes':`$DATA' stream, and will show the ADS name and its contents."
    Location  = New-Object System.Drawing.Point($FileSearchRightPosition,$FileSearchDownPosition) 
    Size      = New-Object System.Drawing.Size($FileSearchLabelWidth,$FileSearchLabelHeight) 
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Black"
}
$Section1FileSearchTab.Controls.Add($FileSearchAlternateDataStreamLabel)

# Shift the fields
$FileSearchDownPosition += $FileSearchDownPositionShift

#---------------------------------------------
# File Search - Alternate Data Stream Textbox
#---------------------------------------------
$FileSearchAlternateDataStreamDirectoryTextbox = New-Object System.Windows.Forms.TextBox -Property @{
    Text          = "Enter Directories; One Per Line"
    Location      = New-Object System.Drawing.Point($FileSearchRightPosition,($FileSearchDownPosition)) 
    Size          = New-Object System.Drawing.Size(430,(80))
    Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
    MultiLine     = $True
    ScrollBars    = "Vertical"
    WordWrap      = $True
    AcceptsTab    = $false # Allows you to enter in tabs into the textbox
    AcceptsReturn = $false # Allows you to enter in tabs into the textbox
    #AutoCompleteSource = "FileSystem" # Options are: FileSystem, HistoryList, RecentlyUsedList, AllURL, AllSystemSources, FileSystemDirectories, CustomSource, ListItems, None
    #AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
}
#$FileSearchAlternateDataStreamDirectoryTextbox.Add_KeyDown({          })
$FileSearchAlternateDataStreamDirectoryTextbox.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ Enter Directories
⦿ One Per Line`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage3))
        $ToolTip.Active       = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation = $true
        $ToolTip.UseFading    = $true
        $ToolTip.IsBalloon    = $true
        $ToolTip.ToolTipIcon  = "Info"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle = 'Alternate Data Stream Search (WinRM)'
    }
})
$FileSearchAlternateDataStreamDirectoryTextbox.Add_MouseEnter({
    if ($FileSearchAlternateDataStreamDirectoryTextbox.text -eq "Enter Directories; One Per Line"){ $FileSearchAlternateDataStreamDirectoryTextbox.text = "" }
})
$FileSearchAlternateDataStreamDirectoryTextbox.Add_MouseLeave({ 
    if ($FileSearchAlternateDataStreamDirectoryTextbox.text -eq ""){ $FileSearchAlternateDataStreamDirectoryTextbox.text = "Enter Directories; One Per Line" }
})
$Section1FileSearchTab.Controls.Add($FileSearchAlternateDataStreamDirectoryTextbox)

#===============================================================================================================================
#     _   __     __                      __      ______                            __  _                     ______      __  
#    / | / /__  / /__      ______  _____/ /__   / ____/___  ____  ____  ___  _____/ /_(_)___  ____  _____   /_  __/___ _/ /_ 
#   /  |/ / _ \/ __/ | /| / / __ \/ ___/ //_/  / /   / __ \/ __ \/ __ \/ _ \/ ___/ __/ / __ \/ __ \/ ___/    / / / __ `/ __ \
#  / /|  /  __/ /_ | |/ |/ / /_/ / /  / ,<    / /___/ /_/ / / / / / / /  __/ /__/ /_/ / /_/ / / / (__  )    / / / /_/ / /_/ /
# /_/ |_/\___/\__/ |__/|__/\____/_/  /_/|_|   \____/\____/_/ /_/_/ /_/\___/\___/\__/_/\____/_/ /_/____/    /_/  \__,_/_.___/ 
#                                                                                                                           
#===============================================================================================================================

#######################################################################################################################################################################
##           ##
##  SUB-TAB  ## Network Connections Search
##           ##
#######################################################################################################################################################################

# Varables
$NetworkConnectionSearchRightPosition     = 3
$NetworkConnectionSearchDownPosition      = -10
$NetworkConnectionSearchDownPositionShift = 25
$NetworkConnectionSearchWidth             = 450
$NetworkConnectionSearchHeight            = 22
$NetworkConnectionSearchButtonWidth       = 110
$NetworkConnectionSearchButtonHeight      = 22
$NetworkConnectionSearchLabelHeight       = 22

$Section1NetworkConnectionsSearchTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text                    = "Network Connections"
    Location                = New-Object System.Drawing.Point($NetworkConnectionSearchRightPosition,$NetworkConnectionSearchDownPosition) 
    Size                    = New-Object System.Drawing.Size($NetworkConnectionSearchWidth,$NetworkConnectionSearchHeight) 
    Font                    = New-Object System.Drawing.Font("$Font",11,0,0,0)
    UseVisualStyleBackColor = $True
}
$Section1CollectionsTabControl.Controls.Add($Section1NetworkConnectionsSearchTab)

$NetworkConnectionSearchDownPosition += $NetworkConnectionSearchDownPositionShift

$SearchNetworkConnection = @'
    function Search-NetworkConnection {
        param(
            [string[]]$IP          = $null,
            [string[]]$Port        = $null,
            [string[]]$ProcessName = $null
        )
        $Connections      = Get-NetTCPConnection
        $Processes        = Get-WmiObject -Class Win32_Process
        $ConnectionsFound = @()        
        
        foreach ($Conn in $Connections) {
            foreach ($Proc in $Processes) {
                if ($Conn.OwningProcess -eq $Proc.ProcessId) {
                    $Conn | Add-Member -MemberType NoteProperty -Name 'Duration'    -Value $((New-TimeSpan -Start ($Conn.CreationTime)).ToString())
                    $Conn | Add-Member -MemberType NoteProperty -Name 'ParentPID'   -Value $Proc.ParentProcessId
                    $Conn | Add-Member -MemberType NoteProperty -Name 'ProcessName' -Value $Proc.Name
                    $Conn | Add-Member -MemberType NoteProperty -Name 'CommandLine' -Value $Proc.CommandLine
                }
            }
        }
        foreach ($Conn in $Connections) {        
            if ($IP) {
                foreach ($DestIP in $IP) { 
                    if (($Conn.RemoteAddress -eq $DestIP) -and ($DestIP -ne '')) { 
                        $ConnectionsFound += [PSCustomObject]@{
                            LocalAddress   = $conn.LocalAddress
                            LocalPort      = $conn.LocalPort
                            RemoteAddress  = $conn.RemoteAddress
                            RemotePort     = $conn.RemotePort
                            State          = $conn.State
                            Duration       = $((New-TimeSpan -Start ($Conn.CreationTime)).ToString())
                            ParentPID      = $conn.ParentPID
                            ProcessID      = $conn.OwningProcess
                            ProcessName    = $conn.ProcessName
                            CommandLine    = $conn.CommandLine
                        }
                    } 
                }
            }
            elseif ($Port) {
                foreach ($DestPort in $Port) { 
                    if (($Conn.RemotePort -eq $DestPort) -and ($DestPort -ne '')) { 
                        $ConnectionsFound += [PSCustomObject]@{
                            LocalAddress   = $conn.LocalAddress
                            LocalPort      = $conn.LocalPort
                            RemoteAddress  = $conn.RemoteAddress
                            RemotePort     = $conn.RemotePort
                            State          = $conn.State
                            Duration       = $((New-TimeSpan -Start ($Conn.CreationTime)).ToString())
                            ParentPID      = $conn.ParentPID
                            ProcessID      = $conn.OwningProcess
                            ProcessName    = $conn.ProcessName
                            CommandLine    = $conn.CommandLine
                        }
                    } 
                }
            }
            elseif ($ProcessName) {
                foreach ($ProcName in $ProcessName) { 
                    if (($conn.ProcessName -match $ProcName) -and ($ProcName -ne '')) { 
                        $ConnectionsFound += [PSCustomObject]@{
                            LocalAddress   = $conn.LocalAddress
                            LocalPort      = $conn.LocalPort
                            RemoteAddress  = $conn.RemoteAddress
                            RemotePort     = $conn.RemotePort
                            State          = $conn.State
                            Duration       = $((New-TimeSpan -Start ($Conn.CreationTime)).ToString())
                            ParentPID      = $conn.ParentPID
                            ProcessID      = $conn.OwningProcess
                            ProcessName    = $conn.ProcessName
                            CommandLine    = $conn.CommandLine
                        }
                    } 
                }
            }
        }
        return $ConnectionsFound
    } -ArgumentList @($IP,$Port,$ProcessName)
'@

#============================================================================================================================================================
# Network Connections Remote IP Address
#============================================================================================================================================================

function NetworkConnectionRemoteIPAddressCommand {
    $CollectionName = "Network Connection Remote IP Address"
    $CollectionCommandStartTime = Get-Date
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Query: $CollectionName")
    $ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")
    foreach ($TargetComputer in $ComputerList) {
        param(
            $CollectedDataTimeStampDirectory, 
            $IndividualHostResults, 
            $CollectionName,
            $TargetComputer
        )
        Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $CollectedDataTimeStampDirectory `
                                -IndividualHostResults $IndividualHostResults -CollectionName $CollectionName `
                                -TargetComputer $TargetComputer
        Create-LogEntry -TargetComputer $TargetComputer -CollectionName $CollectionName -LogFile $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$script:Credential) { $script:Credential = Get-Credential }
            $QueryCredentialParam = ", $script:Credential"
            $QueryCredential      = "-Credential $script:Credential"
        }
        else {
            $QueryCredentialParam = $null
            $QueryCredential      = $null        
        }
        $NetworkConnectionSearchRemoteIPAddress = @()
        foreach ($IP in $($NetworkConnectionSearchRemoteIPAddressTextbox.Text).split("`r`n")){ $NetworkConnectionSearchRemoteIPAddress += $IP }

$QueryJob = @"
        Start-Job -Name "PoSh-ACME: `$(`$CollectionName) -- `$(`$TargetComputer)" -ScriptBlock {
            param(`$TargetComputer, `$NetworkConnectionSearchRemoteIPAddress, `$IndividualHostResults, `$CollectionName $QueryCredentialParam)
            [System.Threading.Thread]::CurrentThread.Priority = 'High'
            ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'High'

            `$ConnectionFound = Invoke-Command -ComputerName `$TargetComputer $QueryCredential -ScriptBlock {
                param(`$NetworkConnectionSearchRemoteIPAddress, `$TargetComputer)

                $SearchNetworkConnection
                Search-NetworkConnection -IP `$NetworkConnectionSearchRemoteIPAddress

            } -ArgumentList @(`$NetworkConnectionSearchRemoteIPAddress, `$TargetComputer)
                    
            `$ConnectionFound | Select-Object -Property @{Name='PSComputerName';Expression={`$(`$TargetComputer)}}, * | Export-CSV "`$(`$IndividualHostResults)\`$(`$CollectionName)\`$(`$CollectionName)-`$(`$TargetComputer).csv" -NoTypeInformation
            
        } -ArgumentList @(`$TargetComputer, `$NetworkConnectionSearchRemoteIPAddress, `$IndividualHostResults, `$CollectionName $QueryCredentialParam)
"@
    }
    Invoke-Expression -Command $QueryJob
    Monitor-Jobs
    $CollectionCommandEndTime  = Get-Date                    
    $CollectionCommandDiffTime = New-TimeSpan -Start $CollectionCommandStartTime -End $CollectionCommandEndTime
    $ResultsListBox.Items.RemoveAt(0)
    $ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $CollectionName")
    Compile-CsvFiles -LocationOfCSVsToCompile   "$($IndividualHostResults)\$($CollectionName)\$($CollectionName)*.csv" `
                     -LocationToSaveCompiledCSV "$($CollectedDataTimeStampDirectory)\$($CollectionName).csv"
    #not needed# Remove-DuplicateCsvHeaders
}

#--------------------------------------------------------
# Network Connections Search - Remote IP Address CheckBox
#--------------------------------------------------------
$NetworkConnectionSearchRemoteIPAddressCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Remote IP Address"
    Location = @{ X = $NetworkConnectionSearchRightPosition
                  Y = $NetworkConnectionSearchDownPosition
                }
    Size     = @{ Width  = 210
                  Height = $NetworkConnectionSearchLabelHeight
                }
    Font     = New-Object System.Drawing.Font("$Font",12,1,2,1)
    ForeColor = 'Blue'
}
$Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchRemoteIPAddressCheckbox)

$NetworkConnectionSearchDownPosition += $NetworkConnectionSearchDownPositionShift

#-----------------------------------------------------
# Network Connections Search - Remote IP Address Label
#-----------------------------------------------------
$NetworkConnectionSearchRemoteIPAddressLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = "Check hosts for connections to one or more remote IP addresses and/or ports."
    Location = @{ X = $NetworkConnectionSearchRightPosition
                  Y = $NetworkConnectionSearchDownPosition
                }
    Size     = @{ Width  = 430
                  Height = $NetworkConnectionSearchLabelHeight
                }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Black"
}
$Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchRemoteIPAddressLabel)

$NetworkConnectionSearchDownPosition += $NetworkConnectionSearchDownPositionShift

#---------------------------------------------------------
# Network Connections Search -  Remote IP Address Textbox
#---------------------------------------------------------
$NetworkConnectionSearchRemoteIPAddressTextbox = New-Object System.Windows.Forms.TextBox -Property @{
    Text     = "Enter Remote IPs; One Per Line"
    Location = @{ X = $NetworkConnectionSearchRightPosition
                  Y = $NetworkConnectionSearchDownPosition
                }
    Size     = @{ Width  = 210
                  Height = 120
                }
    Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    MultiLine  = $True
    ScrollBars = "Vertical"
    WordWrap   = $True
}
#$NetworkConnectionSearchRemoteIPAddressTextbox.Add_KeyDown({          })
$NetworkConnectionSearchRemoteIPAddressTextbox.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ Check hosts for connections to one or more remote IP addresses
⦿ Enter Remote IPs
⦿ One Per Line`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage3))
        $ToolTip.Active       = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation = $true
        $ToolTip.UseFading    = $true
        $ToolTip.IsBalloon    = $true
        $ToolTip.ToolTipIcon  = "Info"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle = 'Remote IP Address (WinRM)'
    }
})
$NetworkConnectionSearchRemoteIPAddressTextbox.Add_MouseEnter({
    if ($NetworkConnectionSearchRemoteIPAddressTextbox.text -eq "Enter Remote IPs; One Per Line"){ $NetworkConnectionSearchRemoteIPAddressTextbox.text = "" }
})
$NetworkConnectionSearchRemoteIPAddressTextbox.Add_MouseLeave({ 
    if ($NetworkConnectionSearchRemoteIPAddressTextbox.text -eq ""){ $NetworkConnectionSearchRemoteIPAddressTextbox.text = "Enter Remote IPs; One Per Line" }
})
$Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchRemoteIPAddressTextbox)

$NetworkConnectionSearchDownPosition += $NetworkConnectionSearchRemoteIPAddressTextbox.Size.Height + 10

#============================================================================================================================================================
# Network Connections Remote Port
#============================================================================================================================================================

function NetworkConnectionRemotePortCommand {
    $CollectionName = "Network Connection Remote Port"
    $CollectionCommandStartTime = Get-Date
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Query: $CollectionName")
    $ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")
    foreach ($TargetComputer in $ComputerList) {
        param(
            $CollectedDataTimeStampDirectory, 
            $IndividualHostResults, 
            $CollectionName,
            $TargetComputer
        )
        Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $CollectedDataTimeStampDirectory `
                                -IndividualHostResults $IndividualHostResults -CollectionName $CollectionName `
                                -TargetComputer $TargetComputer
        Create-LogEntry -TargetComputer $TargetComputer -CollectionName $CollectionName -LogFile $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$script:Credential) { $script:Credential = Get-Credential }
            $QueryCredentialParam = ", $script:Credential"
            $QueryCredential      = "-Credential $script:Credential"
        }
        else {
            $QueryCredentialParam = $null
            $QueryCredential      = $null        
        }
        $NetworkConnectionSearchRemotePort = @()
        foreach ($Port in $($NetworkConnectionSearchRemotePortTextbox.Text).split("`r`n")){ $NetworkConnectionSearchRemotePort += $Port }

$QueryJob = @"
        Start-Job -Name "PoSh-ACME: `$(`$CollectionName) -- `$(`$TargetComputer)" -ScriptBlock {
            param(`$TargetComputer, `$NetworkConnectionSearchRemotePort, `$IndividualHostResults, `$CollectionName $QueryCredentialParam)
            [System.Threading.Thread]::CurrentThread.Priority = 'High'
            ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'High'

            `$ConnectionFound = Invoke-Command -ComputerName `$TargetComputer $QueryCredential -ScriptBlock {
                param(`$NetworkConnectionSearchRemotePort, `$TargetComputer)

                $SearchNetworkConnection
                Search-NetworkConnection -Port `$NetworkConnectionSearchRemotePort

            } -ArgumentList @(`$NetworkConnectionSearchRemotePort, `$TargetComputer)
                    
            `$ConnectionFound | Select-Object -Property @{Name='PSComputerName';Expression={`$(`$TargetComputer)}}, * | Export-CSV "`$(`$IndividualHostResults)\`$(`$CollectionName)\`$(`$CollectionName)-`$(`$TargetComputer).csv" -NoTypeInformation   
        } -ArgumentList @(`$TargetComputer, `$NetworkConnectionSearchRemotePort, `$IndividualHostResults, `$CollectionName $QueryCredentialParam)
"@
    }
    Invoke-Expression -Command $QueryJob
    Monitor-Jobs
    $CollectionCommandEndTime  = Get-Date                    
    $CollectionCommandDiffTime = New-TimeSpan -Start $CollectionCommandStartTime -End $CollectionCommandEndTime
    $ResultsListBox.Items.RemoveAt(0)
    $ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $CollectionName")
    Compile-CsvFiles -LocationOfCSVsToCompile   "$($IndividualHostResults)\$($CollectionName)\$($CollectionName)*.csv" `
                     -LocationToSaveCompiledCSV "$($CollectedDataTimeStampDirectory)\$($CollectionName).csv"
    #not needed# Remove-DuplicateCsvHeaders
}

#--------------------------------------------------------
# Network Connections Search - Remote Port CheckBox
#--------------------------------------------------------
$NetworkConnectionSearchRemotePortCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Remote Port"
    Location = @{ X = $NetworkConnectionSearchRemoteIPAddressCheckbox.Location.X + $NetworkConnectionSearchRemoteIPAddressCheckbox.Size.Width + 10
                  Y = $NetworkConnectionSearchRemoteIPAddressCheckbox.Location.Y
                }
    Size     = @{ Width  = 100
                  Height = $NetworkConnectionSearchLabelHeight
                }
    Font     = New-Object System.Drawing.Font("$Font",12,1,2,1)
    ForeColor = 'Blue'
}
$Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchRemotePortCheckbox)

#------------------------------------------------------------------
# Network Connections Search - Remote Port - Port Selection Button
#------------------------------------------------------------------
if (Test-Path "$ResourcesDirectory\Ports, Protocols, and Services.csv") {
    $NetworkConnectionSearchRemotePortSelectionCheckbox = New-Object System.Windows.Forms.Button -Property @{
        Text      = "Select Ports"
        Location = @{ X = $NetworkConnectionSearchRemotePortCheckbox.Location.X + 113
                      Y = $NetworkConnectionSearchRemotePortCheckbox.Location.Y
                    }
        Size     = @{ Width  = 100
                      Height = 20
                    }
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = "Black"
    }
    $NetworkConnectionSearchRemotePortSelectionCheckbox.Add_Click({
        Import-Csv "$ResourcesDirectory\Ports, Protocols, and Services.csv" | Out-GridView -OutputMode Multiple | Set-Variable -Name PortManualEntrySelectionContents
        $PortsColumn = $PortManualEntrySelectionContents | Select-Object -ExpandProperty "Port"
        $PortsToBeScan = ""
        Foreach ($Port in $PortsColumn) {
            $PortsToBeScan += "$Port`r`n"
        }
        if ($NetworkConnectionSearchRemotePortTextbox.Text -eq "Enter Remote Ports; One Per Line") { $NetworkConnectionSearchRemotePortTextbox.Text = "" }
        $NetworkConnectionSearchRemotePortTextbox.Text += $("`r`n" + $PortsToBeScan)
        $NetworkConnectionSearchRemotePortTextbox.Text  = $NetworkConnectionSearchRemotePortTextbox.Text.Trim("")
    })
    $Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchRemotePortSelectionCheckbox) 
}

#---------------------------------------------
# Network Connections Search -  Remote Port Textbox
#---------------------------------------------
$NetworkConnectionSearchRemotePortTextbox = New-Object System.Windows.Forms.TextBox -Property @{
    Text          = "Enter Remote Ports; One Per Line"
    Location      = New-Object System.Drawing.Point(($NetworkConnectionSearchRemoteIPAddressTextbox.Location.X + $NetworkConnectionSearchRemoteIPAddressTextbox.Size.Width + 10),($NetworkConnectionSearchRemoteIPAddressTextbox.Location.Y)) 
    Size          = New-Object System.Drawing.Size(210,(120))
    Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
    MultiLine     = $True
    ScrollBars    = "Vertical"
    WordWrap      = $True
}
#$NetworkConnectionSearchRemotePortTextbox.Add_KeyDown({          })
$NetworkConnectionSearchRemotePortTextbox.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ Check hosts for connections to one or more remote ports
⦿ Enter Remote Ports
⦿ One Per Line`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage3))
        $ToolTip.Active       = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation = $true
        $ToolTip.UseFading    = $true
        $ToolTip.IsBalloon    = $true
        $ToolTip.ToolTipIcon  = "Info"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle = 'Remote Port (WinRM)'
    }
})
$NetworkConnectionSearchRemotePortTextbox.Add_MouseEnter({
    if ($NetworkConnectionSearchRemotePortTextbox.text -eq "Enter Remote Ports; One Per Line"){ $NetworkConnectionSearchRemotePortTextbox.text = "" }
})
$NetworkConnectionSearchRemotePortTextbox.Add_MouseLeave({ 
    if ($NetworkConnectionSearchRemotePortTextbox.text -eq ""){ $NetworkConnectionSearchRemotePortTextbox.text = "Enter Remote Ports; One Per Line" }
})
$Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchRemotePortTextbox)

#============================================================================================================================================================
# Network Connections Process
#============================================================================================================================================================

function NetworkConnectionProcessCommand {
    $CollectionName = "Network Connection Process Check"
    $CollectionCommandStartTime = Get-Date
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Query: $CollectionName")
    $ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")
    foreach ($TargetComputer in $ComputerList) {
        param(
            $CollectedDataTimeStampDirectory, 
            $IndividualHostResults, 
            $CollectionName,
            $TargetComputer
        )
        Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $CollectedDataTimeStampDirectory `
                                -IndividualHostResults $IndividualHostResults -CollectionName $CollectionName `
                                -TargetComputer $TargetComputer
        Create-LogEntry -TargetComputer $TargetComputer -CollectionName $CollectionName -LogFile $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$script:Credential) { $script:Credential = Get-Credential }
            $QueryCredentialParam = ", $script:Credential"
            $QueryCredential      = "-Credential $script:Credential"
        }
        else {
            $QueryCredentialParam = $null
            $QueryCredential      = $null        
        }
        $NetworkConnectionSearchProcess = @()
        foreach ($Port in $($NetworkConnectionSearchProcessTextbox.Text).split("`r`n")){ $NetworkConnectionSearchProcess += $Port }

$QueryJob = @"
        Start-Job -Name "PoSh-ACME: `$(`$CollectionName) -- `$(`$TargetComputer)" -ScriptBlock {
            param(`$TargetComputer, `$NetworkConnectionSearchProcess, `$IndividualHostResults, `$CollectionName $QueryCredentialParam)
            [System.Threading.Thread]::CurrentThread.Priority = 'High'
            ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'High'

            `$ConnectionFound = Invoke-Command -ComputerName `$TargetComputer $QueryCredential -ScriptBlock {
                param(`$NetworkConnectionSearchProcess, `$TargetComputer)

                $SearchNetworkConnection
                Search-NetworkConnection -ProcessName `$NetworkConnectionSearchProcess

            } -ArgumentList @(`$NetworkConnectionSearchProcess, `$TargetComputer)
                    
            `$ConnectionFound | Select-Object -Property @{Name='PSComputerName';Expression={`$(`$TargetComputer)}}, * | Export-CSV "`$(`$IndividualHostResults)\`$(`$CollectionName)\`$(`$CollectionName)-`$(`$TargetComputer).csv" -NoTypeInformation   
        } -ArgumentList @(`$TargetComputer, `$NetworkConnectionSearchProcess, `$IndividualHostResults, `$CollectionName $QueryCredentialParam)
"@
    }
    Invoke-Expression -Command $QueryJob
    Monitor-Jobs
    $CollectionCommandEndTime  = Get-Date                    
    $CollectionCommandDiffTime = New-TimeSpan -Start $CollectionCommandStartTime -End $CollectionCommandEndTime
    $ResultsListBox.Items.RemoveAt(0)
    $ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $CollectionName")
    Compile-CsvFiles -LocationOfCSVsToCompile   "$($IndividualHostResults)\$($CollectionName)\$($CollectionName)*.csv" `
                     -LocationToSaveCompiledCSV "$($CollectedDataTimeStampDirectory)\$($CollectionName).csv"
    #not needed# Remove-DuplicateCsvHeaders
}

#--------------------------------------------------------
# Network Connections Search - Process CheckBox
#--------------------------------------------------------
$NetworkConnectionSearchProcessCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Remote Process Name"
    Location = New-Object System.Drawing.Point(($NetworkConnectionSearchRightPosition),($NetworkConnectionSearchDownPosition)) 
    Size     = New-Object System.Drawing.Size((430),$NetworkConnectionSearchLabelHeight)
    Font     = New-Object System.Drawing.Font("$Font",12,1,2,1)
    ForeColor = 'Blue'
}
$Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchProcessCheckbox)

$NetworkConnectionSearchDownPosition += $NetworkConnectionSearchDownPositionShift

#-----------------------------------------------------
# Network Connections Search - Process Label
#-----------------------------------------------------
$NetworkConnectionSearchProcessLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = "Check hosts for connections created by a given process."
    Location  = New-Object System.Drawing.Point(($NetworkConnectionSearchRightPosition),($NetworkConnectionSearchDownPosition)) 
    Size      = New-Object System.Drawing.Size(430,$NetworkConnectionSearchLabelHeight) 
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Black"
}
$Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchProcessLabel)

$NetworkConnectionSearchDownPosition += $NetworkConnectionSearchDownPositionShift

#---------------------------------------------
# Network Connections Search -  Process Textbox
#---------------------------------------------
$NetworkConnectionSearchProcessTextbox = New-Object System.Windows.Forms.TextBox -Property @{
    Text          = "Enter Process Names; One Per Line"
    Location      = New-Object System.Drawing.Point($NetworkConnectionSearchRightPosition,($NetworkConnectionSearchDownPosition)) 
    Size          = New-Object System.Drawing.Size(430,(120))
    Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
    MultiLine     = $True
    ScrollBars    = "Vertical"
    WordWrap      = $True
}
#$NetworkConnectionSearchProcessTextbox.Add_KeyDown({          })
$NetworkConnectionSearchProcessTextbox.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ Check hosts for connections created by a given process
⦿ This search will also find the keyword within the process name
⦿ Enter Remote Process Names
⦿ One Per Line`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage3))
        $ToolTip.Active       = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation = $true
        $ToolTip.UseFading    = $true
        $ToolTip.IsBalloon    = $true
        $ToolTip.ToolTipIcon  = "Info"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle = 'Remote Process Name (WinRM)'
    }
})
$NetworkConnectionSearchProcessTextbox.Add_MouseEnter({
    if ($NetworkConnectionSearchProcessTextbox.text -eq "Enter Process Names; One Per Line"){ $NetworkConnectionSearchProcessTextbox.text = "" }
})
$NetworkConnectionSearchProcessTextbox.Add_MouseLeave({ 
    if ($NetworkConnectionSearchProcessTextbox.text -eq ""){ $NetworkConnectionSearchProcessTextbox.text = "Enter Process Names; One Per Line" }
})
$Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchProcessTextbox)

$NetworkConnectionSearchDownPosition += $NetworkConnectionSearchRemoteIPAddressTextbox.Size.Height + 10


#============================================================================================================================================================
# Network Connections DNS Cache
#============================================================================================================================================================

function NetworkConnectionSearchDNSCacheCommand {
    $CollectionName = "Network Connection DNS Cache Check"
    $CollectionCommandStartTime = Get-Date
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Query: $CollectionName")
    $ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")
    foreach ($TargetComputer in $ComputerList) {
        param(
            $CollectedDataTimeStampDirectory, 
            $IndividualHostResults, 
            $CollectionName,
            $TargetComputer
        )
        Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $CollectedDataTimeStampDirectory `
                                -IndividualHostResults $IndividualHostResults -CollectionName $CollectionName `
                                -TargetComputer $TargetComputer
        Create-LogEntry -TargetComputer $TargetComputer -CollectionName $CollectionName -LogFile $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$script:Credential) { $script:Credential = Get-Credential }
            $QueryCredentialParam = ", $script:Credential"
            $QueryCredential      = "-Credential $script:Credential"
        }
        else {
            $QueryCredentialParam = $null
            $QueryCredential      = $null        
        }
        $NetworkConnectionSearchDNSCache = @()
        foreach ($DNSQuery in $($NetworkConnectionSearchDNSCacheTextbox.Text).split("`r`n")){ $NetworkConnectionSearchDNSCache += $DNSQuery | Where {$_ -ne ''} }

$QueryJob = @"
        Start-Job -Name "PoSh-ACME: `$(`$CollectionName) -- `$(`$TargetComputer)" -ScriptBlock {
            param(`$TargetComputer, `$NetworkConnectionSearchDNSCache, `$IndividualHostResults, `$CollectionName $QueryCredentialParam)
            [System.Threading.Thread]::CurrentThread.Priority = 'High'
            ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'High'

            `$DNSQueryCache = Invoke-Command -ComputerName `$TargetComputer -ScriptBlock { Get-DnsClientCache }        
            `$DNSQueryFoundList = @()
            foreach (`$DNSQuery in `$NetworkConnectionSearchDNSCache) {
#                `$DNSQueryFoundList += `$DNSQueryCache | Out-String -Stream | Select-String -Pattern `$DNSQuery
                `$DNSQueryFoundList += `$DNSQueryCache | Where {(`$_.name -match `$DNSQuery) -or (`$_.entry -match `$DNSQuery) -or (`$_.data -match `$DNSQuery) }
            }
            `$DNSQueryFoundList | Select-Object -Property @{Name='PSComputerName';Expression={`$(`$TargetComputer)}}, Entry, Name, Data, Type, Status, Section, TTL, DataLength | Export-CSV "`$(`$IndividualHostResults)\`$(`$CollectionName)\`$(`$CollectionName)-`$(`$TargetComputer).csv" -NoTypeInformation

        } -ArgumentList @(`$TargetComputer, `$NetworkConnectionSearchDNSCache, `$IndividualHostResults, `$CollectionName $QueryCredentialParam)
"@
    }
    Invoke-Expression -Command $QueryJob
    Monitor-Jobs
    $CollectionCommandEndTime  = Get-Date                    
    $CollectionCommandDiffTime = New-TimeSpan -Start $CollectionCommandStartTime -End $CollectionCommandEndTime
    $ResultsListBox.Items.RemoveAt(0)
    $ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $CollectionName")
    Compile-CsvFiles -LocationOfCSVsToCompile   "$($IndividualHostResults)\$($CollectionName)\$($CollectionName)*.csv" `
                     -LocationToSaveCompiledCSV "$($CollectedDataTimeStampDirectory)\$($CollectionName).csv"
    #not needed# Remove-DuplicateCsvHeaders
}

#--------------------------------------------------------
# Network Connections Search - DNS Cache CheckBox
#--------------------------------------------------------
$NetworkConnectionSearchDNSCacheCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Remote DNS Cache Entry"
    Location = New-Object System.Drawing.Point(($NetworkConnectionSearchRightPosition),($NetworkConnectionSearchDownPosition)) 
    Size     = New-Object System.Drawing.Size((430),$NetworkConnectionSearchLabelHeight)
    Font     = New-Object System.Drawing.Font("$Font",12,1,2,1)
    ForeColor = 'Blue'
}
$Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchDNSCacheCheckbox)

$NetworkConnectionSearchDownPosition += $NetworkConnectionSearchDownPositionShift

#-----------------------------------------------------
# Network Connections Search - DNS Cache Label
#-----------------------------------------------------
$NetworkConnectionSearchDNSCacheLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = "Check hosts' DNS Cache for entries that match given criteria."
    Location  = New-Object System.Drawing.Point(($NetworkConnectionSearchRightPosition),($NetworkConnectionSearchDownPosition)) 
    Size      = New-Object System.Drawing.Size(430,$NetworkConnectionSearchLabelHeight) 
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Black"
}
$Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchDNSCacheLabel)

$NetworkConnectionSearchDownPosition += $NetworkConnectionSearchDownPositionShift

#-------------------------------------------------
# Network Connections Search -  DNS Cache Textbox
#-------------------------------------------------
$NetworkConnectionSearchDNSCacheTextbox = New-Object System.Windows.Forms.TextBox -Property @{
    Text          = "Enter DNS query information or IP addresses; One Per Line"
    Location      = New-Object System.Drawing.Point($NetworkConnectionSearchRightPosition,($NetworkConnectionSearchDownPosition)) 
    Size          = New-Object System.Drawing.Size(430,(100))
    Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
    MultiLine     = $True
    ScrollBars    = "Vertical"
    WordWrap      = $True
}
#$NetworkConnectionSearchDNSCacheTextbox.Add_KeyDown({          })
$NetworkConnectionSearchDNSCacheTextbox.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ Check hosts' DNS Cache for entries that match given criteria
⦿ The DNS Cache is not persistence on systems
⦿ By default, Windows stores positive responses in the DNS Cache for 86,400 seconds (1 day)
⦿ By default, Windows stores negative responses in the DNS Cache for 300 seconds (5 minutes)
⦿ The default DNS Cache time limits can be changed within the registry
⦿ Enter DNS query information or IP addresses
⦿ One Per Line`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage3))
        $ToolTip.Active       = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation = $true
        $ToolTip.UseFading    = $true
        $ToolTip.IsBalloon    = $true
        $ToolTip.ToolTipIcon  = "Info"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle = 'Remote DNS Cache Entry (WinRM)'
    }
})
$NetworkConnectionSearchDNSCacheTextbox.Add_MouseEnter({
    if ($NetworkConnectionSearchDNSCacheTextbox.text -eq "Enter DNS query information or IP addresses; One Per Line"){ $NetworkConnectionSearchDNSCacheTextbox.text = "" }
})
$NetworkConnectionSearchDNSCacheTextbox.Add_MouseLeave({ 
    if ($NetworkConnectionSearchDNSCacheTextbox.text -eq ""){ $NetworkConnectionSearchDNSCacheTextbox.text = "Enter DNS query information or IP addresses; One Per Line" }
})
$Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchDNSCacheTextbox)

$NetworkConnectionSearchDownPosition += $NetworkConnectionSearchDownPositionShift

#===================================================================================
#   _____            _       __                        __        ______      __  
#   / ___/__  _______(_)___  / /____  _________  ____ _/ /____   /_  __/___ _/ /_ 
#   \__ \/ / / / ___/ / __ \/ __/ _ \/ ___/ __ \/ __ `/ / ___/    / / / __ `/ __ \
#  ___/ / /_/ (__  ) / / / / /_/  __/ /  / / / / /_/ / (__  )    / / / /_/ / /_/ /
# /____/\__, /____/_/_/ /_/\__/\___/_/  /_/ /_/\__,_/_/____/    /_/  \__,_/_.___/ 
#      /____/                                                                     
#===================================================================================

#######################################################################################################################################################################
##           ##
##  SUB-TAB  ## Sysinternals
##           ##
#######################################################################################################################################################################

# Varables
$SysinternalsRightPosition     = 3
$SysinternalsDownPosition      = -10
$SysinternalsDownPositionShift = 22
$SysinternalsLabelWidth        = 450
$SysinternalsLabelHeight       = 25
$SysinternalsButtonWidth       = 110
$SysinternalsButtonHeight      = 22

$Section1SysinternalsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text     = "Sysinternals"
    Location = @{ X = $SysinternalsRightPosition
                  Y = $SysinternalsDownPosition
                }
    Size     = @{ Width  = $SysinternalsLabelWidth
                  Height = $SysinternalsLabelHeight
                }
    UseVisualStyleBackColor = $True
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
# Test if the External Programs directory is present; if it's there load the tab
if (Test-Path $ExternalPrograms) {
    $Section1CollectionsTabControl.Controls.Add($Section1SysinternalsTab)
}

# Shift the fields
$SysinternalsDownPosition += $SysinternalsDownPositionShift

# Sysinternals Tab Label
$SysinternalsTabLabel = New-Object System.Windows.Forms.Label -Property @{
    Location = @{ X = $SysinternalsRightPosition
                  Y = $SysinternalsDownPosition
                }
    Size     = @{ Width  = $SysinternalsLabelWidth
                  Height = $SysinternalsLabelHeight
                }
    Text      = "The following queries drop/remove files to the target host's temp dir.`nPoSh-ACME must be ran with elevated credentials for these to function.`nThese queries to target hosts are not threaded."
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Red"
}
$Section1SysinternalsTab.Controls.Add($SysinternalsTabLabel)

$SysinternalsDownPosition += $SysinternalsDownPositionShift
$SysinternalsDownPosition += $SysinternalsDownPositionShift

#============================================================================================================================================================
# Sysinternals Sysmon
#============================================================================================================================================================
$script:SysmonXMLPath = ""
$script:SysmonXMLName = ""
function SysinternalsSysmonCommand {
    param ($SysmonXMLPath, $SysmonXMLName)
    $CollectionName = "Sysmon"
    $CollectionCommandStartTime = Get-Date 
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Query: $CollectionName")                    
    $ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")
    foreach ($TargetComputer in $ComputerList) {
        $ResultsListBox.Items.Insert(1,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName - $TargetComputer")
        Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $CollectedDataTimeStampDirectory `
                                -IndividualHostResults $IndividualHostResults -CollectionName $CollectionName `
                                -TargetComputer $TargetComputer
        Create-LogEntry -TargetComputer $TargetComputer -CollectionName $CollectionName -LogFile $LogFile

        $SysinternalsExecutable     = 'Sysmon.exe'
        $ToolName                   = 'Sysmon'
        $AdminShare                 = 'c$'
        $LocalDrive                 = 'c:'
        $PsExecPath                 = "$ExternalPrograms\PsExec.exe"
        $SysinternalsExecutablePath = "$ExternalPrograms\Sysmon.exe"
        $SysmonXMLName              = "$SysmonXMLName"     
        $SysmonXMLPath              = "$SysmonXMLPath"
        $TargetFolder               = "Windows\Temp"
            
        # Checks is the sysmon service is already installed, if so it updates the sysmon configuration
        if ($(Get-Service -ComputerName $TargetComputer -Name sysmon)){
            $ResultsListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [+] $ToolName is already an installed service on $TargetComputer")
            $ResultsListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [+] Copying $ToolName to $TargetComputer to update $ToolName configuration")
            try { Copy-Item $SysinternalsExecutablePath "\\$TargetComputer\$AdminShare\$TargetFolder" -Force -ErrorAction Stop } 
            catch { $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] $($_.Exception)"); break }                

            $ResultsListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [+] Copying $SysmonXMLName config file to $TargetComputer to be used by $ToolName")
            try { Copy-Item $SysmonXMLPath "\\$TargetComputer\$AdminShare\$TargetFolder" -Force -ErrorAction Stop } 
            catch { $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] $($_.Exception)"); break }

            $ResultsListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] Updating $ToolName configuration on $TargetComputer")
            #Start-Process -WindowStyle Hidden -FilePath $PsExecPath -ArgumentList "/accepteula -s \\$TargetComputer $LocalDrive\$TargetFolder\$SysinternalsExecutable -AcceptEula -c '$LocalDrive\$TargetFolder\$SysmonXMLName'" -PassThru | Out-Null
            Invoke-WmiMethod -ComputerName $TargetComputer -Class Win32_Process -Name Create -ArgumentList "$LocalDrive\$TargetFolder\$SysinternalsExecutable -accepteula -c $LocalDrive\$TargetFolder\$SysmonXMLName"
            Start-Sleep -Seconds 5

            $ResultsListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [-] Removing $ToolName executable and $SysmonXMLName from $TargetComputer")                 
            Remove-Item "\\$TargetComputer\$AdminShare\$TargetFolder\$SysinternalsExecutable" -Force
            Remove-Item "\\$TargetComputer\$AdminShare\$TargetFolder\$SysmonXMLName" -Force
        }
        # If sysmon is not a service, it will install sysmon with the selected configuration
        else {
            $ResultsListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [+] Copying $ToolName to $TargetComputer to be executed by PsExec")
            try { Copy-Item $SysinternalsExecutablePath "\\$TargetComputer\$AdminShare\$TargetFolder" -Force -ErrorAction Stop } 
            catch { $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] $($_.Exception)"); break }

            $ResultsListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [+] Copying $SysmonXMLName config file to $TargetComputer to be used by $ToolName")
            try { Copy-Item $SysmonXMLPath "\\$TargetComputer\$AdminShare\$TargetFolder" -Force -ErrorAction Stop } 
            catch { $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] $($_.Exception)"); break }

            $ResultsListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] Installing $ToolName on $TargetComputer")
            #Start-Process -WindowStyle Hidden -FilePath $PsExecPath -ArgumentList "/accepteula -s \\$TargetComputer $LocalDrive\$TargetFolder\$SysinternalsExecutable /AcceptEula -i '$LocalDrive\$TargetFolder\$SysmonXMLName'" -PassThru | Out-Null
            Invoke-WmiMethod -ComputerName $TargetComputer -Class Win32_Process -Name Create -ArgumentList "$LocalDrive\$TargetFolder\$SysinternalsExecutable -accepteula -i $LocalDrive\$TargetFolder\$SysmonXMLName"
            Start-Sleep -Seconds 5
                
            $ResultsListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [-] Removing $ToolName executable and $SysmonXMLName from $TargetComputer")                 
            Remove-Item "\\$TargetComputer\$AdminShare\$TargetFolder\$SysinternalsExecutable" -Force
            Remove-Item "\\$TargetComputer\$AdminShare\$TargetFolder\$SysmonXMLName" -Force
        }
        $CollectionCommandEndTime1  = Get-Date 
        $CollectionCommandDiffTime1 = New-TimeSpan -Start $CollectionCommandStartTime -End $CollectionCommandEndTime1
        $ResultsListBox.Items.RemoveAt(1)
        $ResultsListBox.Items.Insert(1,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime1]  $CollectionName - $TargetComputer")
    }
    $CollectionCommandEndTime0  = Get-Date 
    $CollectionCommandDiffTime0 = New-TimeSpan -Start $CollectionCommandStartTime -End $CollectionCommandEndTime0
    $ResultsListBox.Items.RemoveAt(0)
    $ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime0]  $CollectionName")
}

#-----------------------------
# Sysinternals Sysmon Label
#-----------------------------
$SysinternalsSysmonLabel = New-Object System.Windows.Forms.Label -Property @{
    Location = @{ X = $SysinternalsRightPosition
                  Y = $SysinternalsDownPosition
                }
    Size     = @{ Width  = $SysinternalsLabelWidth
                  Height = $SysinternalsLabelHeight
                }
    Text      = "System Monitor (sysmon) will be installed on the remote hosts. You can view events created by sysmon within Windows Event Viewer or, if forwarded to, within a SIEM."
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Blue"
}
$Section1SysinternalsTab.Controls.Add($SysinternalsSysmonLabel)

$SysinternalsDownPosition += $SysinternalsDownPositionShift

#--------------------------------
# Sysinternals - Sysmon Button
#--------------------------------
function SysinternalsSysmonXMLConfigSelection {
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    $SysinternalsSysmonOpenFileDialog.Title = "Select Sysmon Configuration XML File"
    $SysinternalsSysmonOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{
        Filter = "XML Files (*.xml)| *.xml|All files (*.*)|*.*"
        ShowHelp = $true
        InitialDirectory = "$ExternalPrograms\Sysmon Support  Files\XML Configs"
    }
    $SysinternalsSysmonOpenFileDialog.ShowDialog() | Out-Null
    if ($($SysinternalsSysmonOpenFileDialog.filename)) { 
        $SysmonXMLPath = $SysinternalsSysmonOpenFileDialog.filename 
        $SysinternalsSysmonConfigLabel.text = "Config: $(($SysinternalsSysmonOpenFileDialog.filename).split('\')[-1])"
        $SysmonXMLName = $(($SysinternalsSysmonOpenFileDialog.filename).split('\')[-1])
    }
    $script:SysmonXMLPath = $SysmonXMLPath
    $script:SysmonXMLName = $SysmonXMLName
}

$SysmonXMLPath = $null
$SysinternalsSysmonButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Select Config"
    Location = @{ X = $SysinternalsRightPosition
                  Y = $SysinternalsDownPosition + 5
                }
    Size     = @{ Width  = $SysinternalsButtonWidth
                  Height = $SysinternalsButtonHeight
                }
}
$SysinternalsSysmonButton.Add_Click({ SysinternalsSysmonXMLConfigSelection })
$SysinternalsSysmonButton.Font = New-Object System.Drawing.Font("$Font",11,0,0,0)
$Section1SysinternalsTab.Controls.Add($SysinternalsSysmonButton) 

#--------------------------------
# Sysinternals Sysmon CheckBox
#--------------------------------
$SysinternalsSysmonCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Sysmon"
    Location = @{ X = $SysinternalsRightPosition + $SysinternalsButtonWidth + 5
                  Y = $SysinternalsDownPosition + 5
                }
    Size     = @{ Width  = 75
                  Height = $SysinternalsLabelHeight
                }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$SysinternalsSysmonCheckbox.Add_Click({
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Sysinternals - Sysmon")
    
    # Gets locally stored info on sysmon
    $ResultsListBox.Items.Clear()
    foreach ($line in $(Get-Content "$ExternalPrograms\Sysmon Support  Files\About Sysmon.txt")) { $ResultsListBox.Items.Add("$line") }

    # Manages how the checkbox is handeled to ensure that a config is selected if sysmon is checked
    if ($SysinternalsSysmonCheckbox.checked -and $SysinternalsSysmonConfigLabel.Text -eq "Config:") { SysinternalsSysmonXMLConfigSelection }
    if ($SysinternalsSysmonConfigLabel.Text -eq "Config:"){ $SysinternalsSysmonCheckbox.checked = $false }
})
$Section1SysinternalsTab.Controls.Add($SysinternalsSysmonCheckbox)

#---------------------------
# Sysinternals Sysmon Label
#---------------------------
$SysinternalsSysmonConfigLabel = New-Object System.Windows.Forms.Textbox -Property @{
    Text     = "Config:"
    Location = @{ X = 200
                  Y = $SysinternalsSysmonCheckbox.Location.Y + 1
                }
    Size     = @{ Width  = 225
                  Height = $SysinternalsLabelHeight
                }    
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Black"
    Enabled   = $false
}
#$SysinternalsSysmonConfigLabel.Add_KeyDown({ })
$Section1SysinternalsTab.Controls.Add($SysinternalsSysmonConfigLabel)

$SysinternalsDownPosition += $SysinternalsDownPositionShift + $SysinternalsDownPositionShift

#============================================================================================================================================================
# Sysinternals Autoruns
#============================================================================================================================================================

#-----------------------------
# Sysinternals Autoruns Label
#-----------------------------
$SysinternalsAutorunsLabel = New-Object System.Windows.Forms.Label -Property @{
    Location = @{ X = $SysinternalsRightPosition
                  Y = $SysinternalsDownPosition
                }
    Size     = @{ Width  = $SysinternalsLabelWidth
                  Height = $SysinternalsLabelHeight
                }
    Text      = "Autoruns - Obtains More Startup Information than Native WMI and other Windows Commands, like various built-in Windows Applications."
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Blue"
}
$Section1SysinternalsTab.Controls.Add($SysinternalsAutorunsLabel)

$SysinternalsDownPosition += $SysinternalsDownPositionShift

#--------------------------------
# Sysinternals - Autoruns Button
#--------------------------------
$SysinternalsAutorunsButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Open Autoruns"
    Location = @{ X = $SysinternalsRightPosition
                  Y = $SysinternalsDownPosition + 5
                }
    Size     = @{ Width  = $SysinternalsButtonWidth
                  Height = $SysinternalsButtonHeight
                }
}
$SysinternalsAutorunsButton.Add_Click({
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    $SysinternalsAutorunsOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{
        Title    = "Open Autoruns File"
        Filter   = "Autoruns File (*.arn)| *.arn|All files (*.*)|*.*"
        ShowHelp = $true
    }
    if (Test-Path -Path "$($CollectionSavedDirectoryTextBox.Text)\Individual Host Results\Autoruns") {
        $SysinternalsAutorunsOpenFileDialog.InitialDirectory = "$IndividualHostResults\$($SysinternalsAutorunsCheckbox.Text)"
        $SysinternalsAutorunsOpenFileDialog.ShowDialog() | Out-Null
    }
    else {
        $SysinternalsAutorunsOpenFileDialog.InitialDirectory = "$CollectedDataDirectory"   
        $SysinternalsAutorunsOpenFileDialog.ShowDialog() | Out-Null
    }
    if ($($SysinternalsAutorunsOpenFileDialog.filename)) {
        Start-Process "$ExternalPrograms\Autoruns.exe" -ArgumentList "`"$($SysinternalsAutorunsOpenFileDialog.filename)`""
    }
})
$Section1SysinternalsTab.Controls.Add($SysinternalsAutorunsButton) 


#--------------------------------
# Sysinternals Autoruns CheckBox
#--------------------------------
# Command Execution
function SysinternalsAutorunsCommand {
    $CollectionName = "Autoruns"
    $CollectionCommandStartTime = Get-Date 
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Query: $CollectionName")                    
    $ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")
    foreach ($TargetComputer in $ComputerList) {
        $ResultsListBox.Items.Insert(1,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName - $TargetComputer")
        Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $CollectedDataTimeStampDirectory `
                                -IndividualHostResults $IndividualHostResults -CollectionName $CollectionName `
                                -TargetComputer $TargetComputer
        Create-LogEntry -TargetComputer $TargetComputer -CollectionName $CollectionName -LogFile $LogFile
        Function SysinternalsAutorunsData {
            $SysinternalsExecutable     = 'Autoruns.exe'
            $ToolName                   = 'Autoruns'
            $AdminShare                 = 'c$'
            $LocalDrive                 = 'c:'
            $PsExecPath                 = "$ExternalPrograms\PsExec.exe"
            $SysinternalsExecutablePath = "$ExternalPrograms\Autoruns.exe"
            $TargetFolder               = "Windows\Temp"
            
            $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [+] Copying $ToolName to $TargetComputer temporarily to be executed by PsExec")
            try { Copy-Item $SysinternalsExecutablePath "\\$TargetComputer\$AdminShare\$TargetFolder" -Force -ErrorAction Stop } 
            catch { $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] $($_.Exception)"); break }

            # Process monitor must be launched as a separate process otherwise the sleep and terminate commands below would never execute and fill the disk
            $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] Starting Autoruns on $TargetComputer")
            Start-Process -WindowStyle Hidden -FilePath $PsExecPath -ArgumentList "/accepteula -s \\$TargetComputer $LocalDrive\$TargetFolder\$SysinternalsExecutable /AcceptEula -a $LocalDrive\$TargetFolder\Autoruns-$TargetComputer.arn" -PassThru | Out-Null   

            #$ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [-] Terminating $ToolName process on $TargetComputer")
            #Start-Process -WindowStyle Hidden -FilePath $PsExecPath -ArgumentList "/accepteula -s \\$TargetComputer $LocalDrive\$TargetFolder\$procmon /accepteula /terminate /quiet" -PassThru | Out-Null
            Start-Sleep -Seconds 30

            # Checks to see if the process is still running
            while ($true) {
                if ($(Get-WmiObject -Class Win32_Process -ComputerName "$TargetComputer" | Where-Object {$_.ProcessName -match "Autoruns"})) {  
                    #$RemoteFileSize = "$(Get-ChildItem -Path `"C:\$TempPath`" | Where-Object {$_.Name -match `"$MemoryCaptureFile`"} | Select-Object -Property Length)" #-replace "@{Length=","" -replace "}",""
                    
                    $Message = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) Checking Autoruns Status on $TargetComputer"
                    #$ResultsListBox.Items.RemoveAt(0) ; $ResultsListBox.Items.RemoveAt(0)
                    $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] $Message")
                    Start-Sleep -Seconds 30
                }
                else {
                    Start-Sleep -Seconds 5

                    $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [+] Copying $ToolName data to local machine for analysis")
                    try { Copy-Item "\\$TargetComputer\$AdminShare\$TargetFolder\Autoruns-$TargetComputer.arn" "$IndividualHostResults\$CollectionName" -Force -ErrorAction Stop }
                    catch { $_ ; }

                    $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [-] Removing temporarily $ToolName executable and data file from target system")
                 
                    Remove-Item "\\$TargetComputer\$AdminShare\$TargetFolder\Autoruns-$TargetComputer.arn" -Force
                    Remove-Item "\\$TargetComputer\$AdminShare\$TargetFolder\$SysinternalsExecutable" -Force

                    $FileSize = [math]::round(((Get-Item "$IndividualHostResults\$CollectionName\Autoruns-$TargetComputer.arn").Length/1mb),2)    
                    $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] ..\Autoruns-$TargetComputer.arn is $FileSize MB. Remember to delete it when finished.")

                    #$ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] Launching $ToolName and loading collected log data")
                    #if(Test-Path("$IndividualHostResults\$CollectionName\Autoruns-$TargetComputer.arn")) { & $SysinternalsExecutablePath $IndividualHostResults\$CollectionName\Autoruns-$TargetComputer.arn }
                    break
                }
            }
        }
        SysinternalsAutorunsData -TargetComputer $TargetComputer
        $CollectionCommandEndTime1  = Get-Date 
        $CollectionCommandDiffTime1 = New-TimeSpan -Start $CollectionCommandStartTime -End $CollectionCommandEndTime1
        $ResultsListBox.Items.RemoveAt(1)
        $ResultsListBox.Items.Insert(1,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime1]  $CollectionName - $TargetComputer")
    }
    $CollectionCommandEndTime0  = Get-Date 
    $CollectionCommandDiffTime0 = New-TimeSpan -Start $CollectionCommandStartTime -End $CollectionCommandEndTime0
    $ResultsListBox.Items.RemoveAt(0)
    $ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime0]  $CollectionName")
}

$SysinternalsAutorunsCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Name     = "Autoruns"
    Text     = "Autoruns"
    Location = @{ X = $SysinternalsRightPosition + $SysinternalsButtonWidth + 5
                  Y = $SysinternalsDownPosition + 5
                }
    Size     = @{ Width  = $SysinternalsLabelWidth - 130
                  Height = $SysinternalsLabelHeight
                }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$Section1SysinternalsTab.Controls.Add($SysinternalsAutorunsCheckbox)

# Shift the fields
$SysinternalsDownPosition += $SysinternalsDownPositionShift
# Shift the fields
$SysinternalsDownPosition += $SysinternalsDownPositionShift

#============================================================================================================================================================
# Sysinternals Process Monitor
#============================================================================================================================================================

#------------------------------
# Sysinternals - ProcMon Label
#------------------------------
$SysinternalsProcessMonitorLabel = New-Object System.Windows.Forms.Label -Property @{
    Location = @{ X = $SysinternalsRightPosition
                  Y = $SysinternalsDownPosition
                }
    Size     = @{ Width  = $SysinternalsLabelWidth - 5
                  Height = $SysinternalsLabelHeight
                }
    Text      = "Process Monitor (procmon) data will be megabytes of data per target host; Command will not run if there is less than 500MB on the local and target hosts."
    #Font    = New-Object System.Drawing.Font("$Font",12,1,3,1)
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Blue"
}
$Section1SysinternalsTab.Controls.Add($SysinternalsProcessMonitorLabel)

$SysinternalsDownPosition += $SysinternalsDownPositionShift

#-------------------------------
# Sysinternals - ProcMon Button
#-------------------------------
$SysinternalsProcmonButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Open ProcMon"
    Location = @{ X = $SysinternalsRightPosition
                  Y = $SysinternalsDownPosition + 5
                }
    Size     = @{ Width  = $SysinternalsButtonWidth
                  Height = $SysinternalsButtonHeight
                }
}
$SysinternalsProcmonButton.Add_Click({
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    $SysinternalsProcmonOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{
        Title    = "Open ProcMon File"
        Filter   = "ProcMon Log File (*.pml)| *.pml|All files (*.*)|*.*"
        ShowHelp = $true
    }
    if (Test-Path -Path "$($CollectionSavedDirectoryTextBox.Text)\Individual Host Results\Procmon") {
        $SysinternalsProcmonOpenFileDialog.InitialDirectory = "$IndividualHostResults\$($SysinternalsProcessMonitorCheckbox.Text)"
        $SysinternalsProcmonOpenFileDialog.ShowDialog()
    }
    else {
        $SysinternalsProcmonOpenFileDialog.InitialDirectory = "$CollectedDataDirectory"   
        $SysinternalsProcmonOpenFileDialog.ShowDialog()
    }
    if ($($SysinternalsProcmonOpenFileDialog.filename)) {
        Start-Process "$ExternalPrograms\Procmon.exe" -ArgumentList "`"$($SysinternalsProcmonOpenFileDialog.filename)`""
    }
})

$Section1SysinternalsTab.Controls.Add($SysinternalsProcmonButton) 


#------------------------------
# Sysinternals Procmon Command
#------------------------------
function SysinternalsProcessMonitorCommand {
    param ($SysinternalsProcessMonitorTime = 5)
    $CollectionName = "Procmon"
    $CollectionCommandStartTime = Get-Date 
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Query: $CollectionName")
    $ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")
    foreach ($TargetComputer in $ComputerList) {
        $ResultsListBox.Items.Insert(1,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName - $TargetComputer")
        Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $CollectedDataTimeStampDirectory `
                                -IndividualHostResults $IndividualHostResults -CollectionName $CollectionName `
                                -TargetComputer $TargetComputer
        Create-LogEntry -TargetComputer $TargetComputer -CollectionName $CollectionName -LogFile $LogFile
                      
        # Collect Remote host Disk Space       
        Function Get-DiskSpace([string] $TargetComputer) {
                try { $HD = Get-WmiObject Win32_LogicalDisk -ComputerName $TargetComputer -Filter "DeviceID='C:'" -ErrorAction Stop } 
                catch { $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] Unable to connect to $TargetComputer. $_"); continue}
                if(!$HD) { throw }
                $FreeSpace = [math]::round(($HD.FreeSpace/1gb),2)
                return $FreeSpace
        }

        # Uses PsExec and Procmon to get Process Monitoring informaiton on remote hosts
        # Diskspace is calculated on local and target hosts to determine if there's a risk
        # Procmon is copied over to the target host, and data is gathered there and then exported back
        # The Procmon program and capture file are deleted
        Function SysinternalsProcessMonitorData {
            # Checks to see if the duration is within 10 and 100 seconds
            Param(
                [Parameter(Mandatory=$true)][string]$TargetComputer, 
                [Parameter(Mandatory=$true,
                    HelpMessage="Enter a duration from 10 to 300 seconds (limited due to disk space requriements")]
                    [ValidateRange(5,300)][int]$Duration
            )
            $SysinternalsExecutable      = 'procmon.exe'
            $ToolName                    = 'ProcMon'
            $AdminShare                  = 'c$'
            $LocalDrive                  = 'c:'
            $PsExecPath                  = "$ExternalPrograms\PsExec.exe"
            $SysinternalsExecutablePath  = "$ExternalPrograms\Procmon.exe"
            $TargetFolder                = "Windows\Temp"            
           
            $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] Verifing connection to $TargetComputer, checking for PsExec and Procmon.")
    
            # Process monitor generates enormous amounts of data.  
            # To try and offer some protections, the script won't run if the source or target have less than 500MB free
            $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] Verifying free diskspace on source and target.")
            if((Get-DiskSpace $TargetComputer) -lt 0.5) 
                { $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] $TargetComputer has less than 500MB free - aborting to avoid filling the disk"); break }

            if((Get-DiskSpace $Env:ComputerName) -lt 0.5) 
                { $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] Local computer has less than 500MB free - aborting to avoid filling the disk"); break }

            $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [+] Copying $ToolName to $TargetComputer temporarily to be executed by PsExec")
            try { Copy-Item $SysinternalsExecutablePath "\\$TargetComputer\$AdminShare\$TargetFolder" -Force -ErrorAction Stop } 
            catch { $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] $($_.Exception)"); break }

            # Process monitor must be launched as a separate process otherwise the sleep and terminate commands below would never execute and fill the disk
            $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] Starting process monitor on $TargetComputer")
            #$Command = Start-Process -WindowStyle Hidden -FilePath $PsExecPath -ArgumentList "/accepteula $script:Credentials -s \\$TargetComputer $LocalDrive\$TargetFolder\$SysinternalsExecutable /AcceptEula /BackingFile $LocalDrive\$TargetFolder\$TargetComputer /RunTime 10 /Quiet" -PassThru | Out-Null
            $Command = Start-Process -WindowStyle Hidden -FilePath $PsExecPath -ArgumentList "/accepteula -s \\$TargetComputer $LocalDrive\$TargetFolder\$SysinternalsExecutable /AcceptEula /BackingFile `"$LocalDrive\$TargetFolder\ProcMon-$TargetComputer`" /RunTime $Duration /Quiet" -PassThru | Out-Null
            $Command
            $Message = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $TargetComputer $($SysinternalsProcessMonitorCheckbox.Name)"
            $Message | Add-Content -Path $LogFile
            $Message = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $TargetComputer $Command"
            $Message | Add-Content -Path $LogFile

            Start-Sleep -Seconds ($Duration + 5)

            while ($true) {
                if ($(Get-WmiObject -Class Win32_Process -ComputerName "$TargetComputer" | Where-Object {$_.ProcessName -match "Procmon"})) {                      
                    $Message = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) Checking ProcMon Status on $TargetComputer"
                    $ResultsListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] $Message")
                    Start-Sleep -Seconds 30
                }
                else {
                    Start-Sleep -Seconds 5

                    $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [+] Copying $ToolName data to local machine for analysis")
                    try { Copy-Item "\\$TargetComputer\$AdminShare\$TargetFolder\ProcMon-$TargetComputer.pml" "$IndividualHostResults\$CollectionName" -Force -ErrorAction Stop }
                    catch { $_ ; }

                    $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [-] Removing temporary $ToolName executable and data file from target system")
                 
                    Remove-Item "\\$TargetComputer\$AdminShare\$TargetFolder\ProcMon-$TargetComputer.pml" -Force
                    Remove-Item "\\$TargetComputer\$AdminShare\$TargetFolder\$SysinternalsExecutable" -Force

                    $FileSize = [math]::round(((Get-Item "$IndividualHostResults\$CollectionName\$TargetComputer.pml").Length/1mb),2)    
                    $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] ..\ProcMon-$TargetComputer.pml is $FileSize MB. Remember to delete it when finished.")

                    #$ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] Launching $ToolName and loading collected log data")
                    #if(Test-Path("$IndividualHostResults\$CollectionName\ProcMon-$TargetComputer.pml")) { & $SysinternalsExecutablePath /openlog $IndividualHostResults\$CollectionName\ProcMon-$TargetComputer.pml }
                    break
                }
            }
        }
        $SysinternalsProcessMonitorTimeSwitch = switch ($SysinternalsProcessMonitorTime) {
            '5 Seconds'   {5}
            '10 Seconds'  {10}
            '15 Seconds'  {15}
            '30 Seconds'  {30}
            '1 Minute'    {60}
            '2 Minutes'   {120}
            '3 Minutes'   {180}
            '4 Minutes'   {240}
            '5 Minutes'   {360}
        }
        SysinternalsProcessMonitorData -TargetComputer $TargetComputer -Duration $SysinternalsProcessMonitorTimeSwitch
        $CollectionCommandEndTime1  = Get-Date            
        $CollectionCommandDiffTime1 = New-TimeSpan -Start $CollectionCommandStartTime -End $CollectionCommandEndTime1
        $ResultsListBox.Items.RemoveAt(1)
        $ResultsListBox.Items.Insert(1,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime1]  $CollectionName - $TargetComputer")
    }
    $CollectionCommandEndTime0  = Get-Date 
    $CollectionCommandDiffTime0 = New-TimeSpan -Start $CollectionCommandStartTime -End $CollectionCommandEndTime0
    $ResultsListBox.Items.RemoveAt(0)
    $ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime0]  $CollectionName")
}

$SysinternalsProcessMonitorCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Procmon"
    Location = @{ X = $SysinternalsRightPosition + $SysinternalsButtonWidth + 5
                  Y = $SysinternalsDownPosition + 5
                }
    Size     = @{ Width  = $SysinternalsLabelWidth - 330
                  Height = $SysinternalsLabelHeight
                }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$Section1SysinternalsTab.Controls.Add($SysinternalsProcessMonitorCheckbox)

#---------------------------------
# Procmon - Capture Time ComboBox
#---------------------------------
$SysinternalsProcessMonitorTimeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text     = "5 Seconds"
    Location = @{ X = $SysinternalsRightPosition + $SysinternalsButtonWidth + 150
                  Y = $SysinternalsDownPosition + 6
                }
    Size     = @{ Width  = 160
                  Height = $SysinternalsLabelHeight
                } 
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$ProcmonCaptureTimes = @('5 Seconds','10 Seconds','15 Seconds','30 Seconds','1 Minute','2 Minutes','3 Minutes','4 Minutes','5 Minutes')
    ForEach ($time in $ProcmonCaptureTimes) { $SysinternalsProcessMonitorTimeComboBox.Items.Add($time) }
$Section1SysinternalsTab.Controls.Add($SysinternalsProcessMonitorTimeComboBox)

#=========================================================================================
#     ______                                      __  _                ______      __  
#    / ____/___  __  ______ ___  ___  _________ _/ /_(_)___  ____     /_  __/___ _/ /_ 
#   / __/ / __ \/ / / / __ `__ \/ _ \/ ___/ __ `/ __/ / __ \/ __ \     / / / __ `/ __ \
#  / /___/ / / / /_/ / / / / / /  __/ /  / /_/ / /_/ / /_/ / / / /    / / / /_/ / /_/ /
# /_____/_/ /_/\__,_/_/ /_/ /_/\___/_/   \__,_/\__/_/\____/_/ /_/    /_/  \__,_/_.___/ 
#                                                                                     
#=========================================================================================

#######################################################################################################################################################################
##       ##
##  TAB  ## Enumeration
##       ##
#######################################################################################################################################################################

# Varables
$EnumerationRightPosition     = 3
$EnumerationDownPosition      = 0
$EnumerationDownPositionShift = 25
$EnumerationLabelWidth        = 450
$EnumerationLabelHeight       = 25
$EnumerationButtonWidth       = 110
$EnumerationButtonHeight      = 22
$EnumerationGroupGap          = 15

$Section1EnumerationTab = New-Object System.Windows.Forms.TabPage -Property @{
    Name                    = "Enumeration"
    Text                    = "Enumeration"
    Location                = New-Object System.Drawing.Point($EnumerationRightPosition,$EnumerationDownPosition) 
    Size                    = New-Object System.Drawing.Size($EnumerationLabelWidth,$EnumerationLabelHeight) 
    UseVisualStyleBackColor = $True
    Font                    = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$Section1TabControl.Controls.Add($Section1EnumerationTab)

$EnumerationDownPosition += 13

#============================================================================================================================================================
# Enumeration - Domain Generated
#============================================================================================================================================================

#-------------------------------------------------------
# Enumeration - Domain Generated - function Input Check
#-------------------------------------------------------
function EnumerationDomainGeneratedInputCheck {
    if (($EnumerationDomainGeneratedTextBox.Text -ne '<Domain Name>') -or ($EnumerationDomainGeneratedAutoCheckBox.Checked)) {
        if (($EnumerationDomainGeneratedTextBox.Text -ne '') -or ($EnumerationDomainGeneratedAutoCheckBox.Checked)) {
            # Checks if the domain input field is either blank or contains the default info
            If ($EnumerationDomainGeneratedAutoCheckBox.Checked  -eq $true){. ListComputers "Auto"}
            else {. ListComputers "Manual" "$($EnumerationDomainGeneratedTextBox.Text)"}

            $EnumerationComputerListBox.Items.Clear()
            foreach ($Computer in $ComputerList) {
                [void] $EnumerationComputerListBox.Items.Add("$Computer")
            }
        }
    }
}

#------------------------------------
# Enumeration - Port Scan - GroupBox
#------------------------------------
$EnumerationDomainGenerateGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Location  = New-Object System.Drawing.Size(0,$EnumerationDownPosition)
    size      = New-Object System.Drawing.Size(294,100)
    text      = "Import List From Domain"
    Font      = New-Object System.Drawing.Font("$Font",12,1,2,1)
    ForeColor = "Blue"
}

$EnumerationDomainGenerateDownPosition      = 18
$EnumerationDomainGenerateDownPositionShift = 25

    $EnumerationDomainGeneratedLabelNote = New-Object System.Windows.Forms.Label -Property @{
        Location  = New-Object System.Drawing.Size($EnumerationRightPosition,($EnumerationDomainGenerateDownPosition + 3)) 
        Size      = New-Object System.Drawing.Size(220,22)
        Text      = "This host must be domained for this feature."    
        Font      = New-Object System.Drawing.Font("$Font",10,0,0,0)
        ForeColor = "Black"
    }
    $EnumerationDomainGenerateGroupBox.Controls.Add($EnumerationDomainGeneratedLabelNote)  

    #-----------------------------------------------------
    # Enumeration - Domain Generated - Auto Pull Checkbox
    #-----------------------------------------------------
    $EnumerationDomainGeneratedAutoCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
        Text      = "Auto Pull"
        Location  = New-Object System.Drawing.Size(($EnumerationDomainGeneratedLabelNote.Size.Width + 3),($EnumerationDomainGenerateDownPosition - 1))
        Size      = New-Object System.Drawing.Size(100,$EnumerationLabelHeight)
        Font      = New-Object System.Drawing.Font("$Font",10,0,0,0)
        ForeColor = "Black"
    }
    $EnumerationDomainGeneratedAutoCheckBox.Add_Click({
        if ($EnumerationDomainGeneratedAutoCheckBox.Checked -eq $true){
            $EnumerationDomainGeneratedTextBox.Enabled   = $false
            $EnumerationDomainGeneratedTextBox.BackColor = "lightgray"
        }
        elseif ($EnumerationDomainGeneratedAutoCheckBox.Checked -eq $false) {
            $EnumerationDomainGeneratedTextBox.Text = "<Domain Name>"
            $EnumerationDomainGeneratedTextBox.Enabled   = $true    
            $EnumerationDomainGeneratedTextBox.BackColor = "white"
        }
    })
    $EnumerationDomainGenerateGroupBox.Controls.Add($EnumerationDomainGeneratedAutoCheckBox)

    $EnumerationDomainGenerateDownPosition += $EnumerationDomainGenerateDownPositionShift

    #------------------------------------------------
    # Enumeration - Domain Generated - Input Textbox
    #------------------------------------------------
    $EnumerationDomainGeneratedTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Text      = "<Domain Name>"
        Location  = New-Object System.Drawing.Size($EnumerationRightPosition,$EnumerationDomainGenerateDownPosition)
        Size      = New-Object System.Drawing.Size(286,$EnumerationLabelHeight)
        Font      = New-Object System.Drawing.Font("$Font",10,0,0,0)
        ForeColor = "Black"
    }
    $EnumerationDomainGeneratedTextBox.Add_KeyDown({
        if ($_.KeyCode -eq "Enter") { EnumerationDomainGeneratedInputCheck }
    })
    $EnumerationDomainGenerateGroupBox.Controls.Add($EnumerationDomainGeneratedTextBox)

    $EnumerationDomainGenerateDownPosition += $EnumerationDomainGenerateDownPositionShift

    #----------------------------------------------------------
    # Enumeration - Domain Generated - Import Hosts/IPs Button
    #----------------------------------------------------------
    $EnumerationDomainGeneratedListButton = New-Object System.Windows.Forms.Button -Property @{
        Text      = "Import Hosts"
        Location  = New-Object System.Drawing.Size(190,($EnumerationDomainGenerateDownPosition - 1))
        Size      = New-Object System.Drawing.Size(100,22)
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = "Red"
    }
    $EnumerationDomainGeneratedListButton.Add_Click({ EnumerationDomainGeneratedInputCheck })
    $EnumerationDomainGenerateGroupBox.Controls.Add($EnumerationDomainGeneratedListButton) 

$Section1EnumerationTab.Controls.Add($EnumerationDomainGenerateGroupBox) 

#============================================================================================================================================================
# Enumeration - Port Scanning
#============================================================================================================================================================
if (!(Test-Path $CustomPortsToScan)) {
    #Don't modify / indent the numbers below... to ensure the file created is formated correctly
    Write-Output "21`n22`n23`n53`n80`n88`n110`n123`n135`n143`n161`n389`n443`n445`n3389" | Out-File -FilePath $CustomPortsToScan -Force
}

function Conduct-PortScan {
    param (
        $Timeout_ms,
        $TestWithICMPFirst,
        $SpecificIPsToScan,
        $Network,
        [int]$FirstIP,
        [int]$LastIP,
        $SpecificPortsToScan,
        $FirstPort,
        $LastPort
    )
    $IPsToScan = @()
    $IPsToScan += $SpecificIPsToScan -split "," -replace " ",""
    if ( $FirstIP -ne "" -and $LastIP -ne "" ) {
        if ( ($FirstIP -lt [int]0 -or $FirstIP -gt [int]255) -or ($LastIP -lt [int]0 -or $LastIP -gt [int]255) ) {
            $ResultsListBox.Items.Clear()
            $ResultsListBox.Items.Add("Error! The First and Last IP Fields must be an interger between 0 and 255")
            return
        }
        $IPRange = $FirstIP..$LastIP
        foreach ( $IP in $IPRange ) { $IPsToScan += "$Network.$IP" }
    }
    elseif (( $FirstIP -ne "" -and $LastIP -eq "" ) -or ( $FirstIP -eq "" -and $LastIP -ne "" )) {        
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Error! You can't have one empty IP range field.")
        return
    }
    
    # Since sorting IPs in PowerShell easily and accurately can be a pain...
    # The [System.Version] object is used to represent file and application versions, and we can leverage it to sort IP addresses simply. We sort on a custom calculation, converting the IP addresses to version objects. The conversion is just for sorting purposes.
    $IPsToScan  = $IPsToScan | Sort-Object { [System.Version]$_ } -Unique | ? {$_ -ne ""}

    $PortsToScan = @()
    # Adds the user entered specific ports that were comma separated
    $PortsToScan += $SpecificPortsToScan -split "," -replace " ",""
    # Adds the user entered ports ranged entered in the port range section
    $PortsToScan += $FirstPort..$LastPort

    function Generate-PortsStatusMessage {
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Please wait as the port range is being generated...")
        Start-Sleep -Seconds 1
    }
    # If the respective drop down is selected, the ports will be added to the port scan
    if ($EnumerationPortScanPortQuickPickComboBox.SelectedItem -eq "N/A") {
        $PortsToScan += ""
    }
    elseif ($EnumerationPortScanPortQuickPickComboBox.SelectedItem -eq "Nmap Top 100 Ports") {
        Generate-PortsStatusMessage
        $NmapTop100Ports = "7,9,13,21,22,23,25,26,37,53,79,80,81,88,106,110,111,113,119,135,139,143,144,179,199,389,427,443,444,445,465,513,514,515,543,544,548,554,587,631,646,873,990,993,995,1025,1026,1027,1028,1029,1110,1433,1720,1723,1755,1900,2000,2001,2049,2121,2717,3000,3128,3306,3389,3986,4899,5000,5009,5051,5060,5101,5190,5357,5432,5631,5666,5800,5900,6000,6001,6646,7070,8000,8008,8009,8080,8081,8443,8888,9100,9999,10000,32768,49152,49153,49154,49155,49156,49157" -split "," -replace " ",""
        $PortsToScan    += $NmapTop100Ports
    }
    elseif ($EnumerationPortScanPortQuickPickComboBox.SelectedItem -eq "Nmap Top 1000 Ports") {
        Generate-PortsStatusMessage
        $NmapTop1000Ports = "1,3,4,6,7,9,13,17,19,20,21,22,23,24,25,26,30,32,33,37,42,43,49,53,70,79,80,81,82,83,84,85,88,89,90,99,100,106,109,110,111,113,119,125,135,139,143,144,146,161,163,179,199,211,212,222,254,255,256,259,264,280,301,306,311,340,366,389,406,407,416,417,425,427,443,444,445,458,464,465,481,497,500,512,513,514,515,524,541,543,544,545,548,554,555,563,587,593,616,617,625,631,636,646,648,666,667,668,683,687,691,700,705,711,714,720,722,726,749,765,777,783,787,800,801,808,843,873,880,888,898,900,901,902,903,911,912,981,987,990,992,993,995,999,1000,1001,1002,1007,1009,1010,1011,1021,1022,1023,1024,1025,1026,1027,1028,1029,1030,1031,1032,1033,1034,1035,1036,1037,1038,1039,1040,1041,1042,1043,1044,1045,1046,1047,1048,1049,1050,1051,1052,1053,1054,1055,1056,1057,1058,1059,1060,1061,1062,1063,1064,1065,1066,1067,1068,1069,1070,1071,1072,1073,1074,1075,1076,1077,1078,1079,1080,1081,1082,1083,1084,1085,1086,1087,1088,1089,1090,1091,1092,1093,1094,1095,1096,1097,1098,1099,1100,1102,1104,1105,1106,1107,1108,1110,1111,1112,1113,1114,1117,1119,1121,1122,1123,1124,1126,1130,1131,1132,1137,1138,1141,1145,1147,1148,1149,1151,1152,1154,1163,1164,1165,1166,1169,1174,1175,1183,1185,1186,1187,1192,1198,1199,1201,1213,1216,1217,1218,1233,1234,1236,1244,1247,1248,1259,1271,1272,1277,1287,1296,1300,1301,1309,1310,1311,1322,1328,1334,1352,1417,1433,1434,1443,1455,1461,1494,1500,1501,1503,1521,1524,1533,1556,1580,1583,1594,1600,1641,1658,1666,1687,1688,1700,1717,1718,1719,1720,1721,1723,1755,1761,1782,1783,1801,1805,1812,1839,1840,1862,1863,1864,1875,1900,1914,1935,1947,1971,1972,1974,1984,1998,1999,2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2013,2020,2021,2022,2030,2033,2034,2035,2038,2040,2041,2042,2043,2045,2046,2047,2048,2049,2065,2068,2099,2100,2103,2105,2106,2107,2111,2119,2121,2126,2135,2144,2160,2161,2170,2179,2190,2191,2196,2200,2222,2251,2260,2288,2301,2323,2366,2381,2382,2383,2393,2394,2399,2401,2492,2500,2522,2525,2557,2601,2602,2604,2605,2607,2608,2638,2701,2702,2710,2717,2718,2725,2800,2809,2811,2869,2875,2909,2910,2920,2967,2968,2998,3000,3001,3003,3005,3006,3007,3011,3013,3017,3030,3031,3052,3071,3077,3128,3168,3211,3221,3260,3261,3268,3269,3283,3300,3301,3306,3322,3323,3324,3325,3333,3351,3367,3369,3370,3371,3372,3389,3390,3404,3476,3493,3517,3527,3546,3551,3580,3659,3689,3690,3703,3737,3766,3784,3800,3801,3809,3814,3826,3827,3828,3851,3869,3871,3878,3880,3889,3905,3914,3918,3920,3945,3971,3986,3995,3998,4000,4001,4002,4003,4004,4005,4006,4045,4111,4125,4126,4129,4224,4242,4279,4321,4343,4443,4444,4445,4446,4449,4550,4567,4662,4848,4899,4900,4998,5000,5001,5002,5003,5004,5009,5030,5033,5050,5051,5054,5060,5061,5080,5087,5100,5101,5102,5120,5190,5200,5214,5221,5222,5225,5226,5269,5280,5298,5357,5405,5414,5431,5432,5440,5500,5510,5544,5550,5555,5560,5566,5631,5633,5666,5678,5679,5718,5730,5800,5801,5802,5810,5811,5815,5822,5825,5850,5859,5862,5877,5900,5901,5902,5903,5904,5906,5907,5910,5911,5915,5922,5925,5950,5952,5959,5960,5961,5962,5963,5987,5988,5989,5998,5999,6000,6001,6002,6003,6004,6005,6006,6007,6009,6025,6059,6100,6101,6106,6112,6123,6129,6156,6346,6389,6502,6510,6543,6547,6565,6566,6567,6580,6646,6666,6667,6668,6669,6689,6692,6699,6779,6788,6789,6792,6839,6881,6901,6969,7000,7001,7002,7004,7007,7019,7025,7070,7100,7103,7106,7200,7201,7402,7435,7443,7496,7512,7625,7627,7676,7741,7777,7778,7800,7911,7920,7921,7937,7938,7999,8000,8001,8002,8007,8008,8009,8010,8011,8021,8022,8031,8042,8045,8080,8081,8082,8083,8084,8085,8086,8087,8088,8089,8090,8093,8099,8100,8180,8181,8192,8193,8194,8200,8222,8254,8290,8291,8292,8300,8333,8383,8400,8402,8443,8500,8600,8649,8651,8652,8654,8701,8800,8873,8888,8899,8994,9000,9001,9002,9003,9009,9010,9011,9040,9050,9071,9080,9081,9090,9091,9099,9100,9101,9102,9103,9110,9111,9200,9207,9220,9290,9415,9418,9485,9500,9502,9503,9535,9575,9593,9594,9595,9618,9666,9876,9877,9878,9898,9900,9917,9929,9943,9944,9968,9998,9999,10000,10001,10002,10003,10004,10009,10010,10012,10024,10025,10082,10180,10215,10243,10566,10616,10617,10621,10626,10628,10629,10778,11110,11111,11967,12000,12174,12265,12345,13456,13722,13782,13783,14000,14238,14441,14442,15000,15002,15003,15004,15660,15742,16000,16001,16012,16016,16018,16080,16113,16992,16993,17877,17988,18040,18101,18988,19101,19283,19315,19350,19780,19801,19842,20000,20005,20031,20221,20222,20828,21571,22939,23502,24444,24800,25734,25735,26214,27000,27352,27353,27355,27356,27715,28201,30000,30718,30951,31038,31337,32768,32769,32770,32771,32772,32773,32774,32775,32776,32777,32778,32779,32780,32781,32782,32783,32784,32785,33354,33899,34571,34572,34573,35500,38292,40193,40911,41511,42510,44176,44442,44443,44501,45100,48080,49152,49153,49154,49155,49156,49157,49158,49159,49160,49161,49163,49165,49167,49175,49176,49400,49999,50000,50001,50002,50003,50006,50300,50389,50500,50636,50800,51103,51493,52673,52822,52848,52869,54045,54328,55055,55056,55555,55600,56737,56738,57294,57797,58080,60020,60443,61532,61900,62078,63331,64623,64680,65000,65129,65389" -split "," -replace " ",""
        $PortsToScan     += $NmapTop1000Ports 
    }
    elseif ($EnumerationPortScanPortQuickPickComboBox.SelectedItem -eq "Well-Known Ports (0-1023)") {
        Generate-PortsStatusMessage
        $PortsToScan += 0..1023
    }
    elseif ($EnumerationPortScanPortQuickPickComboBox.SelectedItem -eq "Registered Ports (1024-49151)") {
        Generate-PortsStatusMessage
        $PortsToScan += 1024..49151
    }
    elseif ($EnumerationPortScanPortQuickPickComboBox.SelectedItem -eq "Dynamic Ports (49152-65535)") {
        Generate-PortsStatusMessage
        $PortsToScan += 49152..65535
    }
    elseif ($EnumerationPortScanPortQuickPickComboBox.SelectedItem -eq "All Ports (0-65535)") {
        Generate-PortsStatusMessage
        $PortsToScan += 0..65535
    }
    elseif ($EnumerationPortScanPortQuickPickComboBox.SelectedItem -match "Previous Scan") {
        Generate-PortsStatusMessage
        $LastPortsScanned = $((Get-Content $LogFile | Select-String -Pattern "Ports To Be Scanned" | Select-Object -Last 1) -split '  ')[2]
        $LastPortsScannedConvertedToList = @()
        Foreach ($Port in $(($LastPortsScanned) -split',')){ $LastPortsScannedConvertedToList += $Port }
        $PortsToScan += $LastPortsScannedConvertedToList | Where {$_ -ne ""}
    }
    elseif ($EnumerationPortScanPortQuickPickComboBox.SelectedItem -match "CustomPortsToScan") {
        Generate-PortsStatusMessage
        $CustomSavedPorts = $($PortList="";(Get-Content $CustomPortsToScan | foreach {$PortList += $_ + ','}); $PortList)
        $CustomSavedPortsConvertedToList = @()
        Foreach ($Port in $(($CustomSavedPorts) -split',')){ $CustomSavedPortsConvertedToList += $Port }
        $PortsToScan += $CustomSavedPortsConvertedToList | Where {$_ -ne ""}
    }
    elseif ($EnumerationPortScanPortQuickPickComboBox.SelectedItem -eq "") {
        $PortsToScan += $null
    }

    # Places the Ports to Scan in Numerical Order, removes duplicate entries, and remove possible empty fields
##Consumes too much time##
##    $SortedPorts=@()
##    foreach ( $Port in $PortsToScan ) { $SortedPorts += [int]$Port }
##    $PortsToScan = $SortedPorts | ? {$_ -ne ""}

    # Validates Unique Port List To Scan
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Validating Unique Port List To Scan")
    $PortsToScan = $PortsToScan | Sort-Object -Unique | ? {$_ -ne ""}

    if ($($PortsToScan).count -eq 0) {
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Insert(0,"No ports have been entered or selected to scan!")
        return
    }
    $IPsToScan = $IPsToScan | Sort-Object -Unique | ? {$_ -ne ""}
    if ($($IPsToScan).count -eq 0) {
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Insert(0,"Input Error or no IP addresses have been entered to scan!")
        return
    }
    $NetworkPortScanIPResponded = ""
    $TimeStamp  = $((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))
    $LogMessage = "$TimeStamp  ==================== Port Scan Initiliaztion ===================="
    $LogMessage | Add-Content -Path $LogFile
    $LogMessage = "$TimeStamp  Ports To Be Scanned:  $PortsToScan"
    $LogMessage | Add-Content -Path $LogFile
    $EnumerationComputerListBox.Items.Clear()
    $ResultsListBox.Items.Clear()
    $ResultsListBox.Items.Insert(0,"$TimeStamp  ==================== Port Scan Initiliaztion ====================")
    $ResultsListBox.Items.Insert(0,"$TimeStamp  Ports To Be Scanned:  $PortsToScan")
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Conducting Port Scan"); Start-Sleep -Seconds 1
    
    function PortScan {
        # Sets the intial progress bar values
        $ProgressBarSection.Maximum = $PortsToScan.count
        $ProgressBarSection.Value   = 0

        foreach ($Port in $PortsToScan) {
            $ErrorActionPreference = 'SilentlyContinue'
            $socket     = New-Object System.Net.Sockets.TcpClient
            $connect    = $socket.BeginConnect($IPAddress, $port, $null, $null)
            $tryconnect = Measure-Command { $success = $connect.AsyncWaitHandle.WaitOne($Timeout_ms, $true) } | % totalmilliseconds
            $tryconnect | Out-Null 
            if ($socket.Connected) {
                $ResultsListBox.Items.Insert(2,"$(Get-Date)  - [Response Time: $tryconnect ms] $IPAddress is listening on port $Port ")
                $contime    = [math]::round($tryconnect,2)    
                $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  - [Response Time: $contime ms] $IPAddress is listening on port $Port"
                $LogMessage | Add-Content -Path $LogFile
                $NetworkPortScanIPResponded = $IPAddress
                $socket.Close()
                $socket.Dispose()
                $socket = $null
            }
            $ErrorActionPreference = 'Continue'
            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("Scanning: $IPAddress`:$Port")            
            $ProgressBarSection.Value += 1
        }
        if ($NetworkPortScanIPResponded -ne "") { $EnumerationComputerListBox.Items.Add("$NetworkPortScanIPResponded") }
        $NetworkPortScanResultsIPList = @() # To Clear out the Variable        
    }
    # Sets the intial progress bar values
    $ProgressBarOverall.Maximum = $IPsToScan.count
    $ProgressBarOverall.Value   = 0

    # Iterate through each IP to scan
    foreach ($IPAddress in $IPsToScan) {
        if ($TestWithICMPFirst -eq $true) {
            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("Testing Connection (ping): $IPAddress")
            if (Test-Connection -BufferSize 32 -Count 1 -Quiet -ComputerName $IPAddress) {
                $ResultsListBox.Items.Insert(1,"$(Get-Date)  Port Scan IP:  $IPAddress")
                $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  ICMP Connection Test - $IPAddress is UP - Conducting Port Scan:)"
                $LogMessage | Add-Content -Path $LogFile
                PortScan
            }
            else {
                $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  ICMP Connection Test - $IPAddress is DOWN - No ports scanned)"
                $LogMessage | Add-Content -Path $LogFile
            }
        }
        elseif ($TestWithICMPFirst -eq $false) {
            $ResultsListBox.Items.Insert(1,"$(Get-Date)  Port Scan IP - $IPAddress")
            $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  Port Scan IP:  $IPAddress"
            $LogMessage | Add-Content -Path $LogFile
            PortScan
        }
        $ProgressBarOverall.Value += 1
    }
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Port Scan Completed - Results Are Saved In The Log File")
    $ResultsListBox.Items.Insert(0,"$(Get-Date)  ==================== Port Scan Complete ====================")
}

#------------------------------------
# Enumeration - Port Scan - GroupBox
#------------------------------------
$EnumerationPortScanGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Location  = New-Object System.Drawing.Point(0,($EnumerationDomainGenerateGroupBox.Location.Y + $EnumerationDomainGenerateGroupBox.Size.Height + $EnumerationGroupGap))
    Size      = New-Object System.Drawing.Size(294,270)
    text      = "Create List From TCP Port Scan"
    Font      = New-Object System.Drawing.Font("$Font",12,1,2,1)
    ForeColor = "Blue"
}
$EnumerationPortScanGroupDownPosition      = 18
$EnumerationPortScanGroupDownPositionShift = 25

    #----------------------------------------
    # Enumeration - Port Scan - Specific IPs
    #----------------------------------------
    $EnumerationPortScanIPNote1Label            = New-Object System.Windows.Forms.Label
    $EnumerationPortScanIPNote1Label.Location   = New-Object System.Drawing.Point($EnumerationRightPosition,($EnumerationPortScanGroupDownPosition + 3)) 
    $EnumerationPortScanIPNote1Label.Size       = New-Object System.Drawing.Size(170,22) 
    $EnumerationPortScanIPNote1Label.Text       = "Enter Comma Separated IPs"
    $EnumerationPortScanIPNote1Label.Font       = New-Object System.Drawing.Font("$Font",10,0,0,0)
    $EnumerationPortScanIPNote1Label.ForeColor  = "Black"
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPNote1Label)

    $EnumerationPortScanIPNote2Label            = New-Object System.Windows.Forms.Label
    $EnumerationPortScanIPNote2Label.Location   = New-Object System.Drawing.Point(($EnumerationPortScanIPNote1Label.Size.Width + 3),($EnumerationPortScanGroupDownPosition + 4)) 
    $EnumerationPortScanIPNote2Label.Size       = New-Object System.Drawing.Size(110,20) 
    $EnumerationPortScanIPNote2Label.Text       = "(ex: 10.0.0.1,10.0.0.2)"
    $EnumerationPortScanIPNote2Label.Font       = New-Object System.Drawing.Font("$Font",10,0,0,0)
    $EnumerationPortScanIPNote2Label.ForeColor  = "Black"
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPNote2Label)
    $EnumerationPortScanGroupDownPosition += $EnumerationPortScanGroupDownPositionShift

    #--------------------------------------------------------------
    # Enumeration - Port Scan - Enter Specific Comma Separated IPs
    #--------------------------------------------------------------
    $EnumerationPortScanSpecificIPTextbox               = New-Object System.Windows.Forms.TextBox
    $EnumerationPortScanSpecificIPTextbox.Location      = New-Object System.Drawing.Point($EnumerationRightPosition,$EnumerationPortScanGroupDownPosition) 
    $EnumerationPortScanSpecificIPTextbox.Size          = New-Object System.Drawing.Size(287,22)
    $EnumerationPortScanSpecificIPTextbox.MultiLine     = $False
    $EnumerationPortScanSpecificIPTextbox.WordWrap      = $True
    $EnumerationPortScanSpecificIPTextbox.AcceptsTab    = $false # Allows you to enter in tabs into the textbox
    $EnumerationPortScanSpecificIPTextbox.AcceptsReturn = $false # Allows you to enter in returnss into the textbox
    $EnumerationPortScanSpecificIPTextbox.Text          = ""
    $EnumerationPortScanSpecificIPTextbox.Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
    $EnumerationPortScanSpecificIPTextbox.ForeColor     = "Black"
    #$EnumerationPortScanSpecificIPTextbox.Add_KeyDown({ 
    #    if ($_.KeyCode -eq "Enter") { Conduct-PortScan }
    #})
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanSpecificIPTextbox)

    $EnumerationPortScanGroupDownPosition += $EnumerationPortScanGroupDownPositionShift

    #------------------------------------
    # Enumeration - Port Scan - IP Range
    #------------------------------------
    $EnumerationPortScanIPRangeNote1Label            = New-Object System.Windows.Forms.Label
    $EnumerationPortScanIPRangeNote1Label.Location   = New-Object System.Drawing.Point($EnumerationRightPosition,($EnumerationPortScanGroupDownPosition + 3)) 
    $EnumerationPortScanIPRangeNote1Label.Size       = New-Object System.Drawing.Size(140,22) 
    $EnumerationPortScanIPRangeNote1Label.Text       = "Network Range:"
    $EnumerationPortScanIPRangeNote1Label.Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    $EnumerationPortScanIPRangeNote1Label.ForeColor  = "Black"
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPRangeNote1Label)

    $EnumerationPortScanIPRangeNote2Label            = New-Object System.Windows.Forms.Label
    $EnumerationPortScanIPRangeNote2Label.Location   = New-Object System.Drawing.Point(($EnumerationPortScanIPRangeNote1Label.Size.Width),($EnumerationPortScanGroupDownPosition + 4)) 
    $EnumerationPortScanIPRangeNote2Label.Size       = New-Object System.Drawing.Size(150,20) 
    $EnumerationPortScanIPRangeNote2Label.Text       = "(ex: [ 192.168.1 ]  [ 1 ]  [ 100 ])"
    $EnumerationPortScanIPRangeNote2Label.Font       = New-Object System.Drawing.Font("$Font",10,0,0,0)
    $EnumerationPortScanIPRangeNote2Label.ForeColor  = "Black"
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPRangeNote2Label)

    $EnumerationPortScanGroupDownPosition += $EnumerationPortScanGroupDownPositionShift
    $RightShift = $EnumerationRightPosition

    $EnumerationPortScanIPRangeNetworkLabel           = New-Object System.Windows.Forms.Label
    $EnumerationPortScanIPRangeNetworkLabel.Location  = New-Object System.Drawing.Point($RightShift,($EnumerationPortScanGroupDownPosition + 3)) 
    $EnumerationPortScanIPRangeNetworkLabel.Size      = New-Object System.Drawing.Size(50,22) 
    $EnumerationPortScanIPRangeNetworkLabel.Text      = "Network"
    $EnumerationPortScanIPRangeNetworkLabel.Font      = New-Object System.Drawing.Font("$Font",10,0,0,0)
    $EnumerationPortScanIPRangeNetworkLabel.ForeColor = "Black"
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPRangeNetworkLabel)

    $RightShift += $EnumerationPortScanIPRangeNetworkLabel.Size.Width

    $EnumerationPortScanIPRangeNetworkTextbox               = New-Object System.Windows.Forms.TextBox
    $EnumerationPortScanIPRangeNetworkTextbox.Location      = New-Object System.Drawing.Point($RightShift,$EnumerationPortScanGroupDownPosition) 
    $EnumerationPortScanIPRangeNetworkTextbox.Size          = New-Object System.Drawing.Size(77,22)
    $EnumerationPortScanIPRangeNetworkTextbox.MultiLine     = $False
    $EnumerationPortScanIPRangeNetworkTextbox.WordWrap      = $True
    $EnumerationPortScanIPRangeNetworkTextbox.AcceptsTab    = $false # Allows you to enter in tabs into the textbox
    $EnumerationPortScanIPRangeNetworkTextbox.AcceptsReturn = $false # Allows you to enter in returnss into the textbox
    $EnumerationPortScanIPRangeNetworkTextbox.Text          = ""
    $EnumerationPortScanIPRangeNetworkTextbox.Font          = New-Object System.Drawing.Font("$Font",10,0,0,0)
    $EnumerationPortScanIPRangeNetworkTextbox.ForeColor     = "Black"
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPRangeNetworkTextbox)

    $RightShift += $EnumerationPortScanIPRangeNetworkTextbox.Size.Width

    $EnumerationPortScanIPRangeFirstLabel           = New-Object System.Windows.Forms.Label
    $EnumerationPortScanIPRangeFirstLabel.Location  = New-Object System.Drawing.Point($RightShift,($EnumerationPortScanGroupDownPosition + 3)) 
    $EnumerationPortScanIPRangeFirstLabel.Size      = New-Object System.Drawing.Size(40,22) 
    $EnumerationPortScanIPRangeFirstLabel.Text      = "First IP"
    $EnumerationPortScanIPRangeFirstLabel.Font      = New-Object System.Drawing.Font("$Font",10,0,0,0)
    $EnumerationPortScanIPRangeFirstLabel.ForeColor = "Black"
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPRangeFirstLabel)

    $RightShift += $EnumerationPortScanIPRangeFirstLabel.Size.Width

    $EnumerationPortScanIPRangeFirstTextbox               = New-Object System.Windows.Forms.TextBox
    $EnumerationPortScanIPRangeFirstTextbox.Location      = New-Object System.Drawing.Point($RightShift,$EnumerationPortScanGroupDownPosition) 
    $EnumerationPortScanIPRangeFirstTextbox.Size          = New-Object System.Drawing.Size(40,22)
    $EnumerationPortScanIPRangeFirstTextbox.MultiLine     = $False
    $EnumerationPortScanIPRangeFirstTextbox.WordWrap      = $True
    $EnumerationPortScanIPRangeFirstTextbox.AcceptsTab    = $false # Allows you to enter in tabs into the textbox
    $EnumerationPortScanIPRangeFirstTextbox.AcceptsReturn = $false # Allows you to enter in returnss into the textbox
    $EnumerationPortScanIPRangeFirstTextbox.Text          = ""
    $EnumerationPortScanIPRangeFirstTextbox.Font          = New-Object System.Drawing.Font("$Font",10,0,0,0)
    $EnumerationPortScanIPRangeFirstTextbox.ForeColor     = "Black"
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPRangeFirstTextbox)

    $RightShift += $EnumerationPortScanIPRangeFirstTextbox.Size.Width

    $EnumerationPortScanIPRangeLastLabel           = New-Object System.Windows.Forms.Label
    $EnumerationPortScanIPRangeLastLabel.Location  = New-Object System.Drawing.Point($RightShift,($EnumerationPortScanGroupDownPosition + 3)) 
    $EnumerationPortScanIPRangeLastLabel.Size      = New-Object System.Drawing.Size(40,22) 
    $EnumerationPortScanIPRangeLastLabel.Text      = "Last IP"
    $EnumerationPortScanIPRangeLastLabel.Font      = New-Object System.Drawing.Font("$Font",10,0,0,0)
    $EnumerationPortScanIPRangeLastLabel.ForeColor = "Black"
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPRangeLastLabel)

    $RightShift += $EnumerationPortScanIPRangeLastLabel.Size.Width

    $EnumerationPortScanIPRangeLastTextbox               = New-Object System.Windows.Forms.TextBox
    $EnumerationPortScanIPRangeLastTextbox.Location      = New-Object System.Drawing.Size($RightShift,$EnumerationPortScanGroupDownPosition) 
    $EnumerationPortScanIPRangeLastTextbox.Size          = New-Object System.Drawing.Size(40,22)
    $EnumerationPortScanIPRangeLastTextbox.MultiLine     = $False
    $EnumerationPortScanIPRangeLastTextbox.WordWrap      = $True
    $EnumerationPortScanIPRangeLastTextbox.AcceptsTab    = $false # Allows you to enter in tabs into the textbox
    $EnumerationPortScanIPRangeLastTextbox.AcceptsReturn = $false # Allows you to enter in returnss into the textbox
    $EnumerationPortScanIPRangeLastTextbox.Text          = ""
    $EnumerationPortScanIPRangeLastTextbox.Font          = New-Object System.Drawing.Font("$Font",10,0,0,0)
    $EnumerationPortScanIPRangeLastTextbox.ForeColor     = "Black"
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPRangeLastTextbox)

    $EnumerationPortScanGroupDownPosition += $EnumerationPortScanGroupDownPositionShift

    #------------------------------------------
    # Enumeration - Port Scan - Specific Ports
    #------------------------------------------
    $EnumerationPortScanPortNote1Label            = New-Object System.Windows.Forms.Label
    $EnumerationPortScanPortNote1Label.Location   = New-Object System.Drawing.Point($EnumerationRightPosition,($EnumerationPortScanGroupDownPosition + 3)) 
    $EnumerationPortScanPortNote1Label.Size       = New-Object System.Drawing.Size(170,22) 
    $EnumerationPortScanPortNote1Label.Text       = "Comma Separated Ports"
    $EnumerationPortScanPortNote1Label.Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    $EnumerationPortScanPortNote1Label.ForeColor  = "Black"
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortNote1Label)

    $EnumerationPortScanPortNote2Label            = New-Object System.Windows.Forms.Label
    $EnumerationPortScanPortNote2Label.Location   = New-Object System.Drawing.Point(($EnumerationPortScanPortNote1Label.Size.Width + 3),($EnumerationPortScanGroupDownPosition + 4)) 
    $EnumerationPortScanPortNote2Label.Size       = New-Object System.Drawing.Size(110,20)
    $EnumerationPortScanPortNote2Label.Text       = "(ex: 22,80,135,445)"
    $EnumerationPortScanPortNote2Label.Font       = New-Object System.Drawing.Font("$Font",10,0,0,0)
    $EnumerationPortScanPortNote2Label.ForeColor  = "Black"
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortNote2Label)

    $EnumerationPortScanGroupDownPosition += $EnumerationPortScanGroupDownPositionShift

    $EnumerationPortScanSpecificPortsTextbox               = New-Object System.Windows.Forms.TextBox
    $EnumerationPortScanSpecificPortsTextbox.Location      = New-Object System.Drawing.Point($EnumerationRightPosition,$EnumerationPortScanGroupDownPosition) 
    $EnumerationPortScanSpecificPortsTextbox.Size          = New-Object System.Drawing.Size(288,22)
    $EnumerationPortScanSpecificPortsTextbox.MultiLine     = $False
    $EnumerationPortScanSpecificPortsTextbox.WordWrap      = $True
    $EnumerationPortScanSpecificPortsTextbox.AcceptsTab    = $false # Allows you to enter in tabs into the textbox
    $EnumerationPortScanSpecificPortsTextbox.AcceptsReturn = $false # Allows you to enter in returnss into the textbox
    $EnumerationPortScanSpecificPortsTextbox.Text          = ""
    $EnumerationPortScanSpecificPortsTextbox.Font          = New-Object System.Drawing.Font("$Font",10,0,0,0)
    $EnumerationPortScanSpecificPortsTextbox.ForeColor     = "Black"
    #$EnumerationPortScanSpecificPortsTextbox.Add_KeyDown({ 
    #    if ($_.KeyCode -eq "Enter") { Conduct-PortScan }
    #})
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanSpecificPortsTextbox)

    $EnumerationPortScanGroupDownPosition += $EnumerationPortScanGroupDownPositionShift

    #-----------------------------------------------------
    # Enumeration - Port Scan - Ports Quick Pick ComboBox
    #-----------------------------------------------------

    $EnumerationPortScanPortQuickPickComboBox               = New-Object System.Windows.Forms.ComboBox
    $EnumerationPortScanPortQuickPickComboBox.Location      = New-Object System.Drawing.Point($EnumerationRightPosition,$EnumerationPortScanGroupDownPosition) 
    $EnumerationPortScanPortQuickPickComboBox.Size          = New-Object System.Drawing.Size(183,20)
    $EnumerationPortScanPortQuickPickComboBox.Text          = "Quick-Pick Port Selection"
    $EnumerationPortScanPortQuickPickComboBox.Font          = New-Object System.Drawing.Font("$Font",10,0,0,0)
    $EnumerationPortScanPortQuickPickComboBox.ForeColor     = "Black"    
    $EnumerationPortScanPortQuickPickComboBox.Items.Add("N/A")
    $EnumerationPortScanPortQuickPickComboBox.Items.Add("Nmap Top 100 Ports")
    $EnumerationPortScanPortQuickPickComboBox.Items.Add("Nmap Top 1000 Ports")
    $EnumerationPortScanPortQuickPickComboBox.Items.Add("Well-Known Ports (0-1023)")
    $EnumerationPortScanPortQuickPickComboBox.Items.Add("Registered Ports (1024-49151)")
    $EnumerationPortScanPortQuickPickComboBox.Items.Add("Dynamic Ports (49152-65535)")
    $EnumerationPortScanPortQuickPickComboBox.Items.Add("All Ports (0-65535)")
    $EnumerationPortScanPortQuickPickComboBox.Items.Add("Previous Scan - Parses LogFile.txt")
    $EnumerationPortScanPortQuickPickComboBox.Items.Add("File: CustomPortsToScan.txt")
    $EnumerationPortScanPortQuickPickComboBox.Add_Click({
        $ResultsListBox.Items.Clear()
        if ($EnumerationPortScanPortQuickPickComboBox.SelectedItem -match "N/A") {
            $ResultsListBox.Items.Add("")            
        }        
        elseif ($EnumerationPortScanPortQuickPickComboBox.SelectedItem -match "Nmap Top 100 Ports") {
            $ResultsListBox.Items.Add("Will conduct a connect scan the top 100 ports as reported by nmap on each target.")   
        }
        elseif ($EnumerationPortScanPortQuickPickComboBox.SelectedItem -match "Nmap Top 1000 Ports") {
            $ResultsListBox.Items.Add("Will conduct a connect scan the top 1000 ports as reported by nmap on each target.")   
        }        
        elseif ($EnumerationPortScanPortQuickPickComboBox.SelectedItem -match "Well-Known Ports") {
            $ResultsListBox.Items.Add("Will conduct a connect scan all Well-Known Ports on each target [0-1023].")   
        }        
        elseif ($EnumerationPortScanPortQuickPickComboBox.SelectedItem -match "Registered Ports") {
            $ResultsListBox.Items.Add("Will conduct a connect scan all Registered Ports on each target [1024-49151].")   
        }        
        elseif ($EnumerationPortScanPortQuickPickComboBox.SelectedItem -match "Dynamic Ports") {
            $ResultsListBox.Items.Add("Will conduct a connect scan all Dynamic Ports, AKA Ephemeral Ports, on each target [49152-65535].")            
        }        
        elseif ($EnumerationPortScanPortQuickPickComboBox.SelectedItem -match "All Ports") {
            $ResultsListBox.Items.Add("Will conduct a connect scan all 65535 ports on each target.")            
        }        
        elseif ($EnumerationPortScanPortQuickPickComboBox.SelectedItem -match "Previous Scan") {
            $LastPortsScanned = $((Get-Content $LogFile | Select-String -Pattern "Ports To Be Scanned" | Select-Object -Last 1) -split '  ')[2]
            $LastPortsScannedConvertedToList = @()
            Foreach ($Port in $(($LastPortsScanned) -split',')){ $LastPortsScannedConvertedToList += $Port }
            $ResultsListBox.Items.Add("Will conduct a connect scan on ports listed below.")            
            $ResultsListBox.Items.Add("Previous Ports Scanned:  $($LastPortsScannedConvertedToList | Where {$_ -ne ''})")            
        }
        elseif ($EnumerationPortScanPortQuickPickComboBox.SelectedItem -match "CustomPortsToScan") {
            $CustomSavedPorts = $($PortList="";(Get-Content $CustomPortsToScan | foreach {$PortList += $_ + ','}); $PortList)
            $CustomSavedPortsConvertedToList = @()
            Foreach ($Port in $(($CustomSavedPorts) -split',')){ $CustomSavedPortsConvertedToList += $Port }
            $ResultsListBox.Items.Add("Will conduct a connect scan on ports listed below.")            
            $ResultsListBox.Items.Add("Previous Ports Scanned:  $($CustomSavedPortsConvertedToList | Where {$_ -ne ''})")
        }
    })
    #$EnumerationPortScanPortQuickPickComboBox.Add_KeyDown({ 
    #    if ($_.KeyCode -eq "Enter") { Conduct-PortScan }
    #})
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortQuickPickComboBox)

    #-------------------------------------------------
    # Enumeration - Port Scan - Port Selection Button
    #-------------------------------------------------
    if (Test-Path "$ResourcesDirectory\Ports, Protocols, and Services.csv") {
        $EnumerationPortScanPortsSelectionButton           = New-Object System.Windows.Forms.Button
        $EnumerationPortScanPortsSelectionButton.Text      = "Select Ports"
        $EnumerationPortScanPortsSelectionButton.Location  = New-Object System.Drawing.Point(($EnumerationPortScanPortQuickPickComboBox.Size.Width + 8),$EnumerationPortScanGroupDownPosition) 
        $EnumerationPortScanPortsSelectionButton.Size      = New-Object System.Drawing.Size(100,20) 
        $EnumerationPortScanPortsSelectionButton.Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        $EnumerationPortScanPortsSelectionButton.ForeColor = "Black"
        $EnumerationPortScanPortsSelectionButton.Add_Click({
            Import-Csv "$ResourcesDirectory\Ports, Protocols, and Services.csv" | Out-GridView -OutputMode Multiple | Set-Variable -Name PortManualEntrySelectionContents
            $PortsColumn = $PortManualEntrySelectionContents | Select-Object -ExpandProperty "Port"
            $PortsToBeScan = ""
            Foreach ($Port in $PortsColumn) {
                $PortsToBeScan += "$Port,"
            }       
            $EnumerationPortScanSpecificPortsTextbox.Text += $("," + $PortsToBeScan)
            $EnumerationPortScanSpecificPortsTextbox.Text = $EnumerationPortScanSpecificPortsTextbox.Text.Trim(",")
        })
        $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortsSelectionButton) 
    }

    $EnumerationPortScanGroupDownPosition += $EnumerationPortScanGroupDownPositionShift

    #--------------------------------------
    # Enumeration - Port Scan - Port Range
    #--------------------------------------

    $EnumerationPortScanRightShift = $EnumerationRightPosition

    $EnumerationPortScanPortRangeNetworkLabel           = New-Object System.Windows.Forms.Label
    $EnumerationPortScanPortRangeNetworkLabel.Location  = New-Object System.Drawing.Point($EnumerationPortScanRightShift,($EnumerationPortScanGroupDownPosition + 3)) 
    $EnumerationPortScanPortRangeNetworkLabel.Size      = New-Object System.Drawing.Size(83,22) 
    $EnumerationPortScanPortRangeNetworkLabel.Text      = "Port Range"
    $EnumerationPortScanPortRangeNetworkLabel.Font      = New-Object System.Drawing.Font("$Font",10,0,0,0)
    $EnumerationPortScanPortRangeNetworkLabel.ForeColor = "Black"
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortRangeNetworkLabel)

    $EnumerationPortScanRightShift += $EnumerationPortScanPortRangeNetworkLabel.Size.Width

    $EnumerationPortScanPortRangeFirstLabel           = New-Object System.Windows.Forms.Label
    $EnumerationPortScanPortRangeFirstLabel.Location  = New-Object System.Drawing.Point($EnumerationPortScanRightShift,($EnumerationPortScanGroupDownPosition + 3)) 
    $EnumerationPortScanPortRangeFirstLabel.Size      = New-Object System.Drawing.Size(50,22) 
    $EnumerationPortScanPortRangeFirstLabel.Text      = "First Port"
    $EnumerationPortScanPortRangeFirstLabel.Font      = New-Object System.Drawing.Font("$Font",10,0,0,0)
    $EnumerationPortScanPortRangeFirstLabel.ForeColor = "Black"
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortRangeFirstLabel)

    $EnumerationPortScanRightShift += $EnumerationPortScanPortRangeFirstLabel.Size.Width

    $EnumerationPortScanPortRangeFirstTextbox               = New-Object System.Windows.Forms.TextBox
    $EnumerationPortScanPortRangeFirstTextbox.Location      = New-Object System.Drawing.Point($EnumerationPortScanRightShift,$EnumerationPortScanGroupDownPosition) 
    $EnumerationPortScanPortRangeFirstTextbox.Size          = New-Object System.Drawing.Size(50,22)
    $EnumerationPortScanPortRangeFirstTextbox.MultiLine     = $False
    $EnumerationPortScanPortRangeFirstTextbox.WordWrap      = $True
    $EnumerationPortScanPortRangeFirstTextbox.AcceptsTab    = $false # Allows you to enter in tabs into the textbox
    $EnumerationPortScanPortRangeFirstTextbox.AcceptsReturn = $false # Allows you to enter in returnss into the textbox
    $EnumerationPortScanPortRangeFirstTextbox.Text          = ""
    $EnumerationPortScanPortRangeFirstTextbox.Font          = New-Object System.Drawing.Font("$Font",10,0,0,0)
    $EnumerationPortScanPortRangeFirstTextbox.ForeColor     = "Black"
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortRangeFirstTextbox)

    $EnumerationPortScanRightShift += $EnumerationPortScanPortRangeFirstTextbox.Size.Width + 4

    $EnumerationPortScanPortRangeLastLabel           = New-Object System.Windows.Forms.Label
    $EnumerationPortScanPortRangeLastLabel.Location  = New-Object System.Drawing.Point($EnumerationPortScanRightShift,($EnumerationPortScanGroupDownPosition + 3)) 
    $EnumerationPortScanPortRangeLastLabel.Size      = New-Object System.Drawing.Size(50,22) 
    $EnumerationPortScanPortRangeLastLabel.Text      = "Last Port"
    $EnumerationPortScanPortRangeLastLabel.Font      = New-Object System.Drawing.Font("$Font",10,0,0,0)
    $EnumerationPortScanPortRangeLastLabel.ForeColor = "Black"
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortRangeLastLabel)

    $EnumerationPortScanRightShift += $EnumerationPortScanPortRangeLastLabel.Size.Width

    $EnumerationPortScanPortRangeLastTextbox               = New-Object System.Windows.Forms.TextBox
    $EnumerationPortScanPortRangeLastTextbox.Location      = New-Object System.Drawing.Point($EnumerationPortScanRightShift,$EnumerationPortScanGroupDownPosition) 
    $EnumerationPortScanPortRangeLastTextbox.Size          = New-Object System.Drawing.Size(50,22)
    $EnumerationPortScanPortRangeLastTextbox.MultiLine     = $False
    $EnumerationPortScanPortRangeLastTextbox.WordWrap      = $True
    $EnumerationPortScanPortRangeLastTextbox.AcceptsTab    = $false # Allows you to enter in tabs into the textbox
    $EnumerationPortScanPortRangeLastTextbox.AcceptsReturn = $false # Allows you to enter in returnss into the textbox
    $EnumerationPortScanPortRangeLastTextbox.Text          = ""
    $EnumerationPortScanPortRangeLastTextbox.Font          = New-Object System.Drawing.Font("$Font",10,0,0,0)
    $EnumerationPortScanPortRangeLastTextbox.ForeColor     = "Black"
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortRangeLastTextbox)

    $EnumerationPortScanGroupDownPosition += $EnumerationPortScanGroupDownPositionShift

    #--------------------------------------
    # Enumeration - Port Scan - Port Range
    #--------------------------------------

    $EnumerationPortScanRightShift = $EnumerationRightPosition

    $EnumerationPortScanTestICMPFirstCheckBox           = New-Object System.Windows.Forms.CheckBox
    $EnumerationPortScanTestICMPFirstCheckBox.Location  = New-Object System.Drawing.Point($EnumerationPortScanRightShift,($EnumerationPortScanGroupDownPosition)) 
    $EnumerationPortScanTestICMPFirstCheckBox.Size      = New-Object System.Drawing.Size(130,22) 
    $EnumerationPortScanTestICMPFirstCheckBox.Text      = "Test ICMP First (ping)"
    $EnumerationPortScanTestICMPFirstCheckBox.Font      = New-Object System.Drawing.Font("$Font",10,0,0,0)
    $EnumerationPortScanTestICMPFirstCheckBox.ForeColor = "Black"
    $EnumerationPortScanTestICMPFirstCheckBox.Checked   = $False
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanTestICMPFirstCheckBox)

    $EnumerationPortScanRightShift += $EnumerationPortScanTestICMPFirstCheckBox.Size.Width + 32

    $EnumerationPortScanTimeoutLabel           = New-Object System.Windows.Forms.Label
    $EnumerationPortScanTimeoutLabel.Location  = New-Object System.Drawing.Point($EnumerationPortScanRightShift,($EnumerationPortScanGroupDownPosition + 3)) 
    $EnumerationPortScanTimeoutLabel.Size      = New-Object System.Drawing.Size(75,22) 
    $EnumerationPortScanTimeoutLabel.Text      = "Timeout (ms)"
    $EnumerationPortScanTimeoutLabel.Font      = New-Object System.Drawing.Font("$Font",10,0,0,0)
    $EnumerationPortScanTimeoutLabel.ForeColor = "Black"
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanTimeoutLabel)

    $EnumerationPortScanRightShift += $EnumerationPortScanTimeoutLabel.Size.Width

    $EnumerationPortScanTimeoutTextbox               = New-Object System.Windows.Forms.TextBox
    $EnumerationPortScanTimeoutTextbox.Location      = New-Object System.Drawing.Point($EnumerationPortScanRightShift,$EnumerationPortScanGroupDownPosition) 
    $EnumerationPortScanTimeoutTextbox.Size          = New-Object System.Drawing.Size(50,22)
    $EnumerationPortScanTimeoutTextbox.MultiLine     = $False
    $EnumerationPortScanTimeoutTextbox.WordWrap      = $True
    $EnumerationPortScanTimeoutTextbox.AcceptsTab    = $false # Allows you to enter in tabs into the textbox
    $EnumerationPortScanTimeoutTextbox.AcceptsReturn = $false # Allows you to enter in returnss into the textbox
    $EnumerationPortScanTimeoutTextbox.Text          = 50
    $EnumerationPortScanTimeoutTextbox.Font          = New-Object System.Drawing.Font("$Font",10,0,0,0)
    $EnumerationPortScanTimeoutTextbox.ForeColor     = "Black"
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanTimeoutTextbox)

    $EnumerationPortScanRightShift        += $EnumerationPortScanTimeoutTextbox.Size.Width
    $EnumerationPortScanGroupDownPosition += $EnumerationPortScanGroupDownPositionShift

    #------------------------------------------
    # Enumeration - Port Scan - Execute Button
    #------------------------------------------
    $EnumerationPortScanExecutionButton           = New-Object System.Windows.Forms.Button
    $EnumerationPortScanExecutionButton.Text      = "Execute Scan"
    $EnumerationPortScanExecutionButton.Location  = New-Object System.Drawing.Point(190,$EnumerationPortScanGroupDownPosition)
    $EnumerationPortScanExecutionButton.Size      = New-Object System.Drawing.Size(100,22)
    $EnumerationPortScanExecutionButton.Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    $EnumerationPortScanExecutionButton.ForeColor = "Red"
    $EnumerationPortScanExecutionButton.Add_Click({ 
        Conduct-PortScan -Timeout_ms $EnumerationPortScanTimeoutTextbox.Text -TestWithICMPFirst $EnumerationPortScanTestICMPFirstCheckBox.Checked -SpecificIPsToScan $EnumerationPortScanSpecificIPTextbox.Text -SpecificPortsToScan $EnumerationPortScanSpecificPortsTextbox.Text -Network $EnumerationPortScanIPRangeNetworkTextbox.Text -FirstIP $EnumerationPortScanIPRangeFirstTextbox.Text -LastIP $EnumerationPortScanIPRangeLastTextbox.Text -FirstPort $EnumerationPortScanPortRangeFirstTextbox.Text -LastPort $EnumerationPortScanPortRangeLastTextbox.Text
    })
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanExecutionButton) 
                
$Section1EnumerationTab.Controls.Add($EnumerationPortScanGroupBox) 

#============================================================================================================================================================
# Enumeration - Ping Sweep
#============================================================================================================================================================
Function Conduct-PingSweep {
    Function Create-PingList {
        param($IPAddress)
        $Comp = $IPAddress
        if ($Comp -eq $Null) { . Create-PingList } 
        elseif ($Comp -match "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/\d{1,2}") {
            $Temp = $Comp.Split("/")
            $IP = $Temp[0]
            $Mask = $Temp[1]
            . Get-Subnet-Range $IP $Mask
            $global:PingList = $Script:IPList
        }
        Else { $global:PingList = $Comp }
    }
    . Create-PingList $EnumerationPingSweepIPNetworkCIDRTextbox.Text
    $EnumerationComputerListBox.Items.Clear()

    # Sets initial values for the progress bars
    $ProgressBarSection.Maximum = 1
    $ProgressBarSection.Value   = 0
    $ProgressBarOverall.Maximum = $PingList.count
    $ProgressBarOverall.Value   = 0

    foreach ($Computer in $PingList) {
        $ping = Test-Connection $Computer -Count 1
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Pinging: $Computer")
        $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $ping"
        $LogMessage | Add-Content -Path $LogFile
        if($ping){$EnumerationComputerListBox.Items.Insert(0,"$Computer")}
        $ProgressBarOverall.Value += 1
    }
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Finished with Ping Sweep!")
}

#-------------------------------------
# Enumeration - Ping Sweep - GroupBox
#-------------------------------------
# Create a group that will contain your radio buttons
$EnumerationPingSweepGroupBox           = New-Object System.Windows.Forms.GroupBox
$EnumerationPingSweepGroupBox.Location  = New-Object System.Drawing.Point(0,($EnumerationPortScanGroupBox.Location.Y + $EnumerationPortScanGroupBox.Size.Height + $EnumerationGroupGap))
$EnumerationPingSweepGroupBox.size      = New-Object System.Drawing.Size(294,70)
$EnumerationPingSweepGroupBox.text      = "Create List From Ping Sweep"
$EnumerationPingSweepGroupBox.Font      = New-Object System.Drawing.Font("$Font",12,1,2,1)
$EnumerationPingSweepGroupBox.ForeColor = "Blue"

$EnumerationPingSweepGroupDownPosition      = 18
$EnumerationPingSweepGroupDownPositionShift = 25

    #-------------------------------------------------
    # Enumeration - Ping Sweep - Network & CIDR Label
    #-------------------------------------------------
    $EnumerationPingSweepNote1Label            = New-Object System.Windows.Forms.Label
    $EnumerationPingSweepNote1Label.Location   = New-Object System.Drawing.Point($EnumerationRightPosition,($EnumerationPingSweepGroupDownPosition + 3)) 
    $EnumerationPingSweepNote1Label.Size       = New-Object System.Drawing.Size(105,22) 
    $EnumerationPingSweepNote1Label.Text       = "Enter Network/CIDR:"
    $EnumerationPingSweepNote1Label.Font       = New-Object System.Drawing.Font("$Font",10,0,0,0)
    $EnumerationPingSweepNote1Label.ForeColor  = "Black"
    $EnumerationPingSweepGroupBox.Controls.Add($EnumerationPingSweepNote1Label)

    $EnumerationPingSweepNote2Label            = New-Object System.Windows.Forms.Label
    $EnumerationPingSweepNote2Label.Location   = New-Object System.Drawing.Point(($EnumerationPingSweepNote1Label.Size.Width + 5),($EnumerationPingSweepGroupDownPosition + 4)) 
    $EnumerationPingSweepNote2Label.Size       = New-Object System.Drawing.Size(80,22)
    $EnumerationPingSweepNote2Label.Text       = "(ex: 10.0.0.0/24)"
    $EnumerationPingSweepNote2Label.Font       = New-Object System.Drawing.Font("$Font",10,0,0,0)
    $EnumerationPingSweepNote2Label.ForeColor  = "Black"
    $EnumerationPingSweepGroupBox.Controls.Add($EnumerationPingSweepNote2Label)

    #---------------------------------------------------
    # Enumeration - Ping Sweep - Network & CIDR Textbox
    #---------------------------------------------------
    $EnumerationPingSweepIPNetworkCIDRTextbox               = New-Object System.Windows.Forms.TextBox
    $EnumerationPingSweepIPNetworkCIDRTextbox.Location      = New-Object System.Drawing.Size(190,($EnumerationPingSweepGroupDownPosition)) 
    $EnumerationPingSweepIPNetworkCIDRTextbox.Size          = New-Object System.Drawing.Size(100,$EnumerationLabelHeight)
    $EnumerationPingSweepIPNetworkCIDRTextbox.MultiLine     = $False
    $EnumerationPingSweepIPNetworkCIDRTextbox.WordWrap      = True
    $EnumerationPingSweepIPNetworkCIDRTextbox.AcceptsTab    = false # Allows you to enter in tabs into the textbox
    $EnumerationPingSweepIPNetworkCIDRTextbox.AcceptsReturn = false # Allows you to enter in returnss into the textbox
    $EnumerationPingSweepIPNetworkCIDRTextbox.Text          = ""
    $EnumerationPingSweepIPNetworkCIDRTextbox.Font          = New-Object System.Drawing.Font("$Font",10,0,0,0)
    $EnumerationPingSweepIPNetworkCIDRTextbox.ForeColor     = "Black"
    $EnumerationPingSweepIPNetworkCIDRTextbox.Add_KeyDown({
        if ($_.KeyCode -eq "Enter") { Conduct-PingSweep }
    })
    $EnumerationPingSweepGroupBox.Controls.Add($EnumerationPingSweepIPNetworkCIDRTextbox)

    # Shift the fields
    $EnumerationPingSweepGroupDownPosition += $EnumerationPingSweepGroupDownPositionShift

    #-------------------------------------------
    # Enumeration - Ping Sweep - Execute Button
    #-------------------------------------------
    $EnumerationPingSweepExecutionButton           = New-Object System.Windows.Forms.Button
    $EnumerationPingSweepExecutionButton.Text      = "Execute Sweep"
    $EnumerationPingSweepExecutionButton.Location  = New-Object System.Drawing.Size(190,$EnumerationPingSweepGroupDownPosition)
    $EnumerationPingSweepExecutionButton.Size      = New-Object System.Drawing.Size(100,22)
    $EnumerationPingSweepExecutionButton.Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    $EnumerationPingSweepExecutionButton.ForeColor = "Red"
    $EnumerationPingSweepExecutionButton.Add_Click({ 
        Conduct-PingSweep
    })
    $EnumerationPingSweepGroupBox.Controls.Add($EnumerationPingSweepExecutionButton) 

$Section1EnumerationTab.Controls.Add($EnumerationPingSweepGroupBox) 

#============================================================================================================================================================
# Enumeration - Computer List ListBox
#============================================================================================================================================================
#-------------------------------------------
# Enumeration - Resolve DNS Name Button
#-------------------------------------------
$EnumerationResolveDNSNameButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "Resolve DNS Name"
    Location  = New-Object System.Drawing.Point(296,19)
    Size      = New-Object System.Drawing.Size(152,22)
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$EnumerationResolveDNSNameButton.Add_Click({ 
    # Select all fields
    for($i = 0; $i -lt $EnumerationComputerListBox.Items.Count; $i++) { $EnumerationComputerListBox.SetSelected($i, $true) }
    $EnumerationComputerListBoxSelected = $EnumerationComputerListBox.SelectedItems
    #$EnumerationComputerListBox.Items.Clear()

    # Resolve DNS Names
    $DNSResolutionList = @()
    foreach ($Selected in $($EnumerationComputerListBox.SelectedItems)) {      
        $DNSResolution      = (((Resolve-DnsName $Selected).NameHost).split('.'))[0]
        $DNSResolutionList += $DNSResolution
        $EnumerationComputerListBox.Items.Remove($Selected)
    }
    foreach ($Item in $DNSResolutionList) {
        $EnumerationComputerListBox.Items.Add($Item)
    }
})
$Section1EnumerationTab.Controls.Add($EnumerationResolveDNSNameButton) 

#-------------------------------------
# Enumeration - Computer List Listbox
#-------------------------------------
$EnumerationComputerListBox = New-Object System.Windows.Forms.ListBox -Property @{
    Location      = New-Object System.Drawing.Point(297,(10  + ($EnumerationResolveDNSNameButton.Size.Height + 13)))
    Size          = New-Object System.Drawing.Size(150,(480 - ($EnumerationResolveDNSNameButton.Size.Height + 13)))
    Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
    SelectionMode = 'MultiExtended'
}
$EnumerationComputerListBox.Items.Add("127.0.0.1")
$EnumerationComputerListBox.Items.Add("localhost")    
$Section1EnumerationTab.Controls.Add($EnumerationComputerListBox)

#----------------------------------
# Single Host - Add To List Button
#----------------------------------
$EnumerationComputerListBoxAddToListButton           = New-Object System.Windows.Forms.Button
$EnumerationComputerListBoxAddToListButton.Text      = "Add To Computer List"
$EnumerationComputerListBoxAddToListButton.Location  = New-Object System.Drawing.Point(($EnumerationComputerListBox.Location.X - 1),($EnumerationComputerListBox.Location.Y + $EnumerationComputerListBox.Size.Height - 3))
$EnumerationComputerListBoxAddToListButton.Size      = New-Object System.Drawing.Size(($EnumerationComputerListBox.Size.Width + 2),22) 
$EnumerationComputerListBoxAddToListButton.Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
$EnumerationComputerListBoxAddToListButton.ForeColor = "Green"
$EnumerationComputerListBoxAddToListButton.Add_Click({
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Enumeration:  Added $($EnumerationComputerListBox.SelectedItems.Count) IPs")
    $ResultsListBox.Items.Clear()
    foreach ($Selected in $EnumerationComputerListBox.SelectedItems) {      
        if ($script:ComputerListTreeViewData.Name -contains $Selected) {
            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("Port Scan Import:  Warning")
            $ResultsListBox.Items.Add("$($Selected) already exists with the following data:")
            $ResultsListBox.Items.Add("- OU/CN: $($($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $Selected}).CanonicalName)")
            $ResultsListBox.Items.Add("- OS:    $($($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $Selected}).OperatingSystem)")
            $ResultsListBox.Items.Add("- IP:    $($($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $Selected}).IPv4Address)")
            $ResultsListBox.Items.Add("- MAC:   $($($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $Selected}).MACAddress)")
            $ResultsListBox.Items.Add("")
        }
        else {
            if ($ComputerListTreeViewOSHostnameRadioButton.Checked) {
                Add-ComputerNode -RootNode $script:TreeNodeComputerList -Category 'Unknown' -Entry $Selected -ToolTip $Computer.IPv4Address
                $ResultsListBox.Items.Add("$($Selected) has been added to the Unknown category")
            }
            elseif ($ComputerListTreeViewOUHostnameRadioButton.Checked) {
                $CanonicalName = $($($Computer.CanonicalName) -replace $Computer.Name,"" -replace $Computer.CanonicalName.split('/')[0],"").TrimEnd("/")
                Add-ComputerNode -RootNode $script:TreeNodeComputerList -Category '/Unknown' -Entry $Selected -ToolTip $Computer.IPv4Address
                $ResultsListBox.Items.Add("$($Selected) has been added to /Unknown category")
            }
            $ComputerListTreeViewAddHostnameIP = New-Object PSObject -Property @{ 
                Name            = $Selected
                OperatingSystem = 'Unknown'
                CanonicalName   = '/Unknown'
                IPv4Address     = $Selected
            }
            $script:ComputerListTreeViewData += $ComputerListTreeViewAddHostnameIP
        }
    }
    $ComputerListTreeView.ExpandAll()
    Populate-ComputerListTreeViewDefaultData
    TempSave-HostData
})
$Section1EnumerationTab.Controls.Add($EnumerationComputerListBoxAddToListButton) 

#---------------------------------
# Enumeration - Select All Button
#---------------------------------
$EnumerationComputerListBoxSelectAllButton          = New-Object System.Windows.Forms.Button
$EnumerationComputerListBoxSelectAllButton.Location = New-Object System.Drawing.Size($EnumerationComputerListBoxAddToListButton.Location.X,($EnumerationComputerListBoxAddToListButton.Location.Y + $EnumerationComputerListBoxAddToListButton.Size.Height + 4))
$EnumerationComputerListBoxSelectAllButton.Size     = New-Object System.Drawing.Size($EnumerationComputerListBoxAddToListButton.Size.Width,22)
$EnumerationComputerListBoxSelectAllButton.Text     = "Select All"
$EnumerationComputerListBoxSelectAllButton.Add_Click({
    # Select all fields
    for($i = 0; $i -lt $EnumerationComputerListBox.Items.Count; $i++) {
        $EnumerationComputerListBox.SetSelected($i, $true)
    }
})
$EnumerationComputerListBoxSelectAllButton.Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
$Section1EnumerationTab.Controls.Add($EnumerationComputerListBoxSelectAllButton) 

#-----------------------------------
# Computer List - Clear List Button
#-----------------------------------
$EnumerationComputerListBoxClearButton           = New-Object System.Windows.Forms.Button
$EnumerationComputerListBoxClearButton.Location  = New-Object System.Drawing.Size($EnumerationComputerListBoxSelectAllButton.Location.X,($EnumerationComputerListBoxSelectAllButton.Location.Y + $EnumerationComputerListBoxSelectAllButton.Size.Height + 4))
$EnumerationComputerListBoxClearButton.Size      = New-Object System.Drawing.Size($EnumerationComputerListBoxSelectAllButton.Size.Width,22)
$EnumerationComputerListBoxClearButton.Text      = 'Clear List'
$EnumerationComputerListBoxClearButton.Add_Click({
    $EnumerationComputerListBox.Items.Clear()
})
$EnumerationComputerListBoxClearButton.Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
$Section1EnumerationTab.Controls.Add($EnumerationComputerListBoxClearButton) 

#=================================================================
#    ________              __   ___      __     ______      __  
#   / ____/ /_  ___  _____/ /__/ (_)____/ /_   /_  __/___ _/ /_ 
#  / /   / __ \/ _ \/ ___/ //_/ / / ___/ __/    / / / __ `/ __ \
# / /___/ / / /  __/ /__/ ,< / / (__  ) /_     / / / /_/ / /_/ /
# \____/_/ /_/\___/\___/_/|_/_/_/____/\__/    /_/  \__,_/_.___/ 
# 
#=================================================================

#######################################################################################################################################################################
##       ##
##  TAB  ## Checklist
##       ##
#######################################################################################################################################################################

$Section1ChecklistTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text                    = "Checklist"
    Name                    = "Checklist Tab"
    Font                    = New-Object System.Drawing.Font("$Font",11,0,0,0)
    UseVisualStyleBackColor = $True
}
if (Test-Path $PoShHome\Resources\Checklists) { $Section1TabControl.Controls.Add($Section1ChecklistTab) }

# Variables
$TabRightPosition     = 3
$TabhDownPosition     = 3
$TabAreaWidth         = 446
$TabAreaHeight        = 557

$TextBoxRightPosition = -2 
$TextBoxDownPosition  = -2
$TextBoxWidth         = 442
$TextBoxHeight        = 536

# The TabControl controls the tabs within it
$Section1ChecklistTabControl = New-Object System.Windows.Forms.TabControl -Property @{
    Name          = "Checklist TabControl"
    Location      = New-Object System.Drawing.Point($TabRightPosition,$TabhDownPosition)
    Size          = New-Object System.Drawing.Size($TabAreaWidth,$TabAreaHeight) 
    Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ShowToolTips  = $True
    SelectedIndex = 0
}
$Section1ChecklistTab.Controls.Add($Section1ChecklistTabControl)

#######################################################################################################################################################################
##  SUB-TAB  ## Checklist Files
#######################################################################################################################################################################

# Varables for positioning checkboxes
$ChecklistRightPosition     = 5
$ChecklistDownPositionStart = 10
$ChecklistDownPosition      = 10
$ChecklistDownPositionShift = 30
$ChecklistBoxWidth          = 410
$ChecklistBoxHeight         = 30

#-------------------------------------------------------
# Checklists Auto Create Tabs and Checkboxes from files
#-------------------------------------------------------
# Obtains a list of the files in the resources folder
$ResourceChecklistFiles = Get-ChildItem "$PoShHome\Resources\Checklists"

# Iterates through the files and dynamically creates tabs and imports data
foreach ($File in $ResourceChecklistFiles) {
    #-------------------------
    # Creates Tabs From Files
    #-------------------------
    $Section1ChecklistSubTab = New-Object System.Windows.Forms.TabPage -Property @{
        Text                    = $File.BaseName
        AutoScroll              = $True
        UseVisualStyleBackColor = $True
        Font                    = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $Section1ChecklistTabControl.Controls.Add($Section1ChecklistSubTab)

    #-------------------------------------
    # Imports Data and Creates Checkboxes
    #-------------------------------------
    $TabContents = Get-Content -Path $File.FullName -Force | foreach {$_ + "`r`n"}
    foreach ($line in $TabContents) {
        $Checklist = New-Object System.Windows.Forms.CheckBox -Property @{
            Text     = "$line"
            Location = New-Object System.Drawing.Point($ChecklistRightPosition,$ChecklistDownPosition) 
            Size     = New-Object System.Drawing.Size($ChecklistBoxWidth,$ChecklistBoxHeight)
            Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        }
        if ($Checklist.Check -eq $True) { $Checklist.ForeColor = "Blue" }
        $Section1ChecklistSubTab.Controls.Add($Checklist)          

        # Shift the Text and Button's Location
        $ChecklistDownPosition += $ChecklistDownPositionShift
    }

    # Resets the Down Position
    $ChecklistDownPosition = $ChecklistDownPositionStart
}

#==========================================================================
#     ____                                              ______      __  
#    / __ \_________  ________  _____________  _____   /_  __/___ _/ /_ 
#   / /_/ / ___/ __ \/ ___/ _ \/ ___/ ___/ _ \/ ___/    / / / __ `/ __ \
#  / ____/ /  / /_/ / /__/  __(__  |__  )  __(__  )    / / / /_/ / /_/ /
# /_/   /_/   \____/\___/\___/____/____/\___/____/    /_/  \__,_/_.___/ 
#                                                                      
#==========================================================================

#######################################################################################################################################################################
##       ##
##  TAB  ## Processes
##       ##
#######################################################################################################################################################################

$Section1ProcessesTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text                    = "Processes"
    Name                    = "Processes Tab"
    UseVisualStyleBackColor = $True
    Font                    = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
#Checks if the Resources Directory is there and loads it if it is
if (Test-Path "$PoShHome\Resources\Process Info") { $Section1TabControl.Controls.Add($Section1ProcessesTab) }

# Variables
$TabRightPosition       = 3
$TabhDownPosition       = 3
$TabAreaWidth           = 446
$TabAreaHeight          = 557
$TextBoxRightPosition   = -2 
$TextBoxDownPosition    = -2
$TextBoxWidth           = 442
$TextBoxHeight          = 536

# The TabControl controls the tabs within it
$Section1ProcessesTabControl = New-Object System.Windows.Forms.TabControl -Property @{
    Name          = "Processes TabControl"
    Location      = New-Object System.Drawing.Point($TabRightPosition,$TabhDownPosition)
    Size          = New-Object System.Drawing.Size($TabAreaWidth,$TabAreaHeight) 
    Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ShowToolTips  = $True
    SelectedIndex = 0
}
$Section1ProcessesTab.Controls.Add($Section1ProcessesTabControl)

#######################################################################################################################################################################
##  SUB-TAB  ## Processes Files
#######################################################################################################################################################################
#------------------------------------
# Auto Creates Tabs and Imports Data
#------------------------------------
# Obtains a list of the files in the resources folder
$ResourceFiles = Get-ChildItem "$PoShHome\Resources\Process Info"

# Iterates through the files and dynamically creates tabs and imports data
foreach ($File in $ResourceFiles) {
    #-----------------------------
    # Creates Tabs From Each File
    #-----------------------------
    $Section1ProcessesSubTab = New-Object System.Windows.Forms.TabPage -Property @{
        Text                    = $File.BaseName
        Font                    = New-Object System.Drawing.Font("$Font",11,0,0,0)
        UseVisualStyleBackColor = $True
    }
    $Section1ProcessesTabControl.Controls.Add($Section1ProcessesSubTab)

    #-----------------------------
    # Imports Data Into Textboxes
    #-----------------------------
    $TabContents = Get-Content -Path $File.FullName -Force | foreach {$_ + "`r`n"} 
    $Section1ProcessesSubTabTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Name       = "$file"
        Text       = "$TabContents"
        Location   = New-Object System.Drawing.Point($TextBoxRightPosition,$TextBoxDownPosition) 
        Size       = New-Object System.Drawing.Size($TextBoxWidth,$TextBoxHeight)
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
        MultiLine  = $True
        ScrollBars = "Vertical"
    }
    $Section1ProcessesSubTab.Controls.Add($Section1ProcessesSubTabTextBox)
}

#================================================================
#    ____        _   __      __               ______      __  
#   / __ \____  / | / /___  / /____  _____   /_  __/___ _/ /_ 
#  / / / / __ \/  |/ / __ \/ __/ _ \/ ___/    / / / __ `/ __ \
# / /_/ / /_/ / /|  / /_/ / /_/  __(__  )    / / / /_/ / /_/ /
# \____/ .___/_/ |_/\____/\__/\___/____/    /_/  \__,_/_.___/ 
#     /_/                                                     
#================================================================

#######################################################################################################################################################################
##       ##
##  TAB  ## OpNotes
##       ##
#######################################################################################################################################################################

# The OpNotes TabPage Window
$Section1OpNotesTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text                    = "OpNotes"
    Name                    = "OpNotes Tab"
    UseVisualStyleBackColor = $True
    Font                    = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$Section1TabControl.Controls.Add($Section1OpNotesTab)

# Variables
$TabRightPosition          = 3
$TabhDownPosition          = 3
$TabAreaWidth              = 446
$TabAreaHeight             = 557

$OpNotesInputTextBoxWidth  = 450
$OpNotesInputTextBoxHeight = 22

$OpNotesButtonWidth        = 100
$OpNotesButtonHeight       = 22

$OpNotesMainTextBoxWidth   = 450
$OpNotesMainTextBoxHeight  = 470

$OpNotesRightPositionStart = 0
$OpNotesRightPosition      = 0
$OpNotesRightPositionShift = $OpNotesButtonWidth + 10
$OpNotesDownPosition       = 2
$OpNotesDownPositionShift  = 22

#-------------------------------
# OpNotes - OpNotes Save Script
#-------------------------------
# The purpose to allow saving of Opnotes automatcially
function Save-OpNotes {
    # Select all fields to be saved
    for($i = 0; $i -lt $OpNotesListBox.Items.Count; $i++) { $OpNotesListBox.SetSelected($i, $true) }

    # Saves all OpNotes to file
    Set-Content -Path $OpNotesFile -Value ($OpNotesListBox.SelectedItems) -Force
    
    # Unselects Fields
    for($i = 0; $i -lt $OpNotesListBox.Items.Count; $i++) { $OpNotesListBox.SetSelected($i, $false) }
}

#---------------------------------
# OpNotes - OpNotes Textbox Entry
#---------------------------------
# This function is called when pressing enter in the text box or click add
function OpNoteTextBoxEntry {
    # Adds Timestamp to Entered Text
    $OpNotesAdded = $OpNotesListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) $($OpNotesInputTextBox.Text)")

    Save-OpNotes

    # Adds all entries to the OpNotesWriteOnlyFile -- This file gets all entries and are not editable from the GUI
    # Useful for looking into accidentally deleted entries
    Add-Content -Path $OpNotesWriteOnlyFile -Value ("$($(Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) $($OpNotesInputTextBox.Text)") -Force 
#    $PrependData = Get-Content $OpNotesWriteOnlyFile
#    Set-Content -Path $OpNotesWriteOnlyFile -Value (("$($(Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) $($OpNotesInputTextBox.Text)"),$PrependData) -Force 
    
    #Clears Textbox
    $OpNotesInputTextBox.Text = ""
}

############################################################################################################
# Section 1 OpNotes SubTab
############################################################################################################

#-------------------------------------
# OpNoptes - Enter your OpNotes Label
#-------------------------------------
$OpNotesLabel = New-Object System.Windows.Forms.Label -Property @{
    Location  = New-Object System.Drawing.Point($OpNotesRightPosition,$OpNotesDownPosition) 
    Size      = New-Object System.Drawing.Size($OpNotesInputTextBoxWidth,$OpNotesInputTextBoxHeight)
    Text      = "Enter Your OpNotes (Auto-Timestamp):"
    Font      = New-Object System.Drawing.Font("$Font",13,1,2,1)
    ForeColor = "Blue"
}
$Section1OpNotesTab.Controls.Add($OpNotesLabel)

$OpNotesDownPosition += $OpNotesDownPositionShift

#--------------------------
# OpNotes - Input Text Box
#--------------------------
$OpNotesInputTextBox          = New-Object System.Windows.Forms.TextBox -Property @{
    Location = New-Object System.Drawing.Size($OpNotesRightPosition,$OpNotesDownPosition)
    Size     = New-Object System.Drawing.Size($OpNotesInputTextBoxWidth,$OpNotesInputTextBoxHeight)
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
# Press Enter to Input Data
$OpNotesInputTextBox.Add_KeyDown({
    if ($_.KeyCode -eq "Enter") {
        # There must be text in the input to make an entry
        if ($OpNotesInputTextBox.Text -ne "") { OpNoteTextBoxEntry }
    }
})
$Section1OpNotesTab.Controls.Add($OpNotesInputTextBox)

$OpNotesDownPosition += $OpNotesDownPositionShift

#----------------------
# OpNotes - Add Button
#----------------------
$OpNotesAddButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "Add"
    Location  = New-Object System.Drawing.Size($OpNotesRightPosition,$OpNotesDownPosition)
    Size      = New-Object System.Drawing.Size($OpNotesButtonWidth,$OpNotesButtonHeight)
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Green"
}
$OpNotesAddButton.Add_Click({
    # There must be text in the input to make an entry
    if ($OpNotesInputTextBox.Text -ne "") { OpNoteTextBoxEntry }    
})
$Section1OpNotesTab.Controls.Add($OpNotesAddButton) 

$OpNotesRightPosition += $OpNotesRightPositionShift

#-----------------------------
# OpNotes - Select All Button
#-----------------------------
$OpNotesAddButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Select All"
    Location = New-Object System.Drawing.Size($OpNotesRightPosition,$OpNotesDownPosition)
    Size     = New-Object System.Drawing.Size($OpNotesButtonWidth,$OpNotesButtonHeight)
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$OpNotesAddButton.Add_Click({
    for($i = 0; $i -lt $OpNotesListBox.Items.Count; $i++) {
        $OpNotesListBox.SetSelected($i, $true)
    }
})
$Section1OpNotesTab.Controls.Add($OpNotesAddButton) 

$OpNotesRightPosition += $OpNotesRightPositionShift

#-------------------------------
# OpNotes - Open OpNotes Button
#-------------------------------
$OpNotesOpenListBox          = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Open OpNotes"
    Location = @{ X = $OpNotesRightPosition
                  Y = $OpNotesDownPosition
                }
    Size     = @{ Width  = $OpNotesButtonWidth
                  Height = $OpNotesButtonHeight
                }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$OpNotesOpenListBox.Add_Click({ Invoke-Item -Path "$PoShHome\OpNotes.txt" })
$Section1OpNotesTab.Controls.Add($OpNotesOpenListBox)

$OpNotesRightPosition += $OpNotesRightPositionShift

#--------------------------
# OpNotes - Move Up Button
#--------------------------
$OpNotesMoveUpButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = 'Move Up'
    Location = @{ X = $OpNotesRightPosition
                  Y = $OpNotesDownPosition
                }
    Size     = @{ Width  = $OpNotesButtonWidth
                  Height = $OpNotesButtonHeight
                }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$OpNotesMoveUpButton.Add_Click({
    if($OpNotesListBox.SelectedIndex -gt 0) {
        $OpNotesListBox.BeginUpdate()
        $OpNotesToMove         = @()
        $SelectedItemPositions = @()
        $SelectedItemIndices   = $($OpNotesListBox.SelectedIndices)

        $BufferLine = $null
        #Checks if the lines are contiguous, if they are not it will not move the lines
        foreach ($line in $SelectedItemIndices) {
            if (($BufferLine - $line) -ne -1 -and $BufferLine -ne $null) {
                $OpNotesListBox.EndUpdate()
                $StatusListBox.Items.Clear()
                $StatusListBox.Items.Add("Error: OpNotes")
                $ResultsListBox.Items.Clear()
                $ResultsListBox.Items.Add('Error: You can only move contiguous lines up or down.')
                [system.media.systemsounds]::Exclamation.play()
                #[console]::beep(500,100)
                return
            }
            $BufferLine = [int]$line
        }
        #Adds lines to variable to be moved and removes each line
        while($OpNotesListBox.SelectedItems) {
            $SelectedItemPositions += $OpNotesListBox.SelectedIndex
            $OpNotesToMove         += $OpNotesListBox.SelectedItems[0]
            $OpNotesListBox.Items.Remove($OpNotesListBox.SelectedItems[0]) 
        }
        #Reverses Array order... [array]::reverse($OpNotesToMove) was not working
        if ($a.Length -gt 999) {$OpNotesToMove = $OpNotesToMove[-1..-10000]}
        else {$OpNotesToMove = $OpNotesToMove[-1..-1000]}

        #Adds lines to their new location
        foreach ($note in $OpNotesToMove) {
            $OpNotesListBox.items.insert($SelectedItemPositions[0] -1,$note)
        }
        $OpNotesListBox.EndUpdate()
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Success: OpNotes Action")
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Moved OpNote lines up.")
        $ResultsListBox.Items.Add('Opnotes have been saved.')
        Save-OpNotes
    
        #the index location of the line
        $IndexCount = $SelectedItemIndices.count
        foreach ($Index in $SelectedItemIndices) { $OpNotesListBox.SetSelected(($Index - 1),$true) }
    }
    else {
        [system.media.systemsounds]::Exclamation.play()
        #[console]::beep(500,100)
    }
})
$Section1OpNotesTab.Controls.Add($OpNotesMoveUpButton) 

$OpNotesDownPosition += $OpNotesDownPositionShift

# Move Position back to left
$OpNotesRightPosition = $OpNotesRightPositionStart

#----------------------------------
# OpNotes - Remove Selected Button
#----------------------------------
$OpNotesRemoveButton = New-Object System.Windows.Forms.Button -Property @{
    Location = New-Object System.Drawing.Size($OpNotesRightPosition,$OpNotesDownPosition)
    Size     = New-Object System.Drawing.Size($OpNotesButtonWidth,$OpNotesButtonHeight)
    Text     = 'Remove'
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$OpNotesRemoveButton.Add_Click({
    while($OpNotesListBox.SelectedItems) { $OpNotesListBox.Items.Remove($OpNotesListBox.SelectedItems[0]) }
    Save-OpNotes
})
$Section1OpNotesTab.Controls.Add($OpNotesRemoveButton) 

$OpNotesRightPosition += $OpNotesRightPositionShift

#--------------------------------
# OpNotes - Create Report Button
#--------------------------------
$OpNotesCreateReportButton = New-Object System.Windows.Forms.Button -Property @{
    Location = New-Object System.Drawing.Size($OpNotesRightPosition,$OpNotesDownPosition)
    Size     = New-Object System.Drawing.Size($OpNotesButtonWidth,$OpNotesButtonHeight)
    Text     = "Create Report"
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$OpNotesCreateReportButton.Add_Click({
    New-Item -ItemType Directory "$PoShHome\Reports" -ErrorAction SilentlyContinue | Out-Null
    if ($OpNotesListBox.SelectedItems.Count -gt 0) { 
        # Popup that allows you select where to save the Report
        [System.Reflection.Assembly]::LoadWithPartialName("PresentationFramework") | Out-Null
        #$OpNotesSaveLocation                 = New-Object -Typename System.Windows.Forms.SaveFileDialog
        $OpNotesSaveLocation                  = New-Object Microsoft.Win32.SaveFileDialog
        $OpNotesSaveLocation.InitialDirectory = "$PoShHome\Reports"
        $OpNotesSaveLocation.MultiSelect      = $false
        $OpNotesSaveLocation.Filter           = "Text files (*.txt)| *.txt" 
        $OpNotesSaveLocation.ShowDialog()
        Write-Output $($OpNotesListBox.SelectedItems) | Out-File "$($OpNotesSaveLocation.Filename)"
    }
    else {
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add('You must select at least one line to add to a report!')
    }
})
$Section1OpNotesTab.Controls.Add($OpNotesCreateReportButton) 

$OpNotesRightPosition += $OpNotesRightPositionShift

#-------------------------------
# OpNotes - Open Reports Button
#-------------------------------
$OpNotesOpenListBox = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Open Reports"
    Location = New-Object System.Drawing.Size($OpNotesRightPosition,$OpNotesDownPosition)
    Size     = New-Object System.Drawing.Size($OpNotesButtonWidth,$OpNotesButtonHeight) 
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$OpNotesOpenListBox.Add_Click({ Invoke-Item -Path "$PoShHome\Reports" })
$Section1OpNotesTab.Controls.Add($OpNotesOpenListBox)

$OpNotesRightPosition += $OpNotesRightPositionShift

#----------------------------
# OpNotes - Move Down Button
#----------------------------
$OpNotesMoveDownButton = New-Object System.Windows.Forms.Button -Property @{
    Location = New-Object System.Drawing.Size($OpNotesRightPosition,$OpNotesDownPosition)
    Size     = New-Object System.Drawing.Size($OpNotesButtonWidth,$OpNotesButtonHeight)
    Text     = 'Move Down'
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$OpNotesMoveDownButton.Add_Click({
    if(($OpNotesListBox.Items).Count -ne (($OpNotesListBox.SelectedIndices)[-1] + 1) ) {
        $OpNotesListBox.BeginUpdate()
        $OpNotesToMove = @()
        $SelectedItemPositions = @()
        $SelectedItemIndices = $($OpNotesListBox.SelectedIndices)

        $BufferLine = $null
        #Checks if the lines are contiguous, if they are not it will not move the lines
        foreach ($line in $SelectedItemIndices) {
            if (($BufferLine - $line) -ne -1 -and $BufferLine -ne $null) {
                $OpNotesListBox.EndUpdate()
                $StatusListBox.Items.Clear()
                $StatusListBox.Items.Add("Error: OpNotes")
                $ResultsListBox.Items.Clear()
                $ResultsListBox.Items.Add('Error: You can only move contiguous lines up or down.')
                [system.media.systemsounds]::Exclamation.play()
                #[console]::beep(500,100)
                return
            }
            $BufferLine = [int]$line
        }
        #Adds lines to variable to be moved and removes each line
        while($OpNotesListBox.SelectedItems) {
            $SelectedItemPositions += $OpNotesListBox.SelectedIndex
            $OpNotesToMove         += $OpNotesListBox.SelectedItems[0]
            $OpNotesListBox.Items.Remove($OpNotesListBox.SelectedItems[0]) 
        }
        #Reverses Array order... [array]::reverse($OpNotesToMove) was not working
        if ($a.Length -gt 999) {$OpNotesToMove = $OpNotesToMove[-1..-10000]}
        else {$OpNotesToMove = $OpNotesToMove[-1..-1000]}

        #Adds lines to their new location
        foreach ($note in $OpNotesToMove) {
            $OpNotesListBox.items.insert($SelectedItemPositions[0] +1,$note)
        }
        $OpNotesListBox.EndUpdate()
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Success: OpNotes Action")
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Moved OpNote lines down.")
        $ResultsListBox.Items.Add('Opnotes have been saved.')
        Save-OpNotes
    
        #the index location of the line
        $IndexCount = $SelectedItemIndices.count
        foreach ($Index in $SelectedItemIndices) { $OpNotesListBox.SetSelected(($Index + 1),$true) }
    }
    else {
        [system.media.systemsounds]::Exclamation.play()
        #[console]::beep(500,100)
    }


})
$Section1OpNotesTab.Controls.Add($OpNotesMoveDownButton) 

$OpNotesDownPosition += $OpNotesDownPositionShift

#-------------------
# OpNotes - ListBox
#-------------------
$OpNotesListBox = New-Object System.Windows.Forms.ListBox -Property @{
    Name                = "OpNotesListBox"
    Location            = New-Object System.Drawing.Size($OpNotesRightPositionStart,($OpNotesDownPosition + 5)) 
    Size                = New-Object System.Drawing.Size($OpNotesMainTextBoxWidth,$OpNotesMainTextBoxHeight)
    Font                = New-Object System.Drawing.Font("$Font",11,0,0,0)
    FormattingEnabled   = $True
    SelectionMode       = 'MultiExtended'
    ScrollAlwaysVisible = $True
    AutoSize            = $false
}
#$OpNotesListBox.Add_MouseHover({  Write-host 'this is a test' })
$OpNotesListBox.Add_MouseEnter({
    $Section1TabControl.Size = New-Object System.Drawing.Size(($Section1TabControlBoxWidth + 615),$Section1TabControlBoxHeight)
    $OpNotesListBox.Size     = New-Object System.Drawing.Size(($OpNotesMainTextBoxWidth + 615),$OpNotesMainTextBoxHeight)
})
$OpNotesListBox.Add_MouseLeave({
    $Section1TabControl.Size = New-Object System.Drawing.Size($Section1TabControlBoxWidth,$Section1TabControlBoxHeight)
    $OpNotesListBox.Size     = New-Object System.Drawing.Size($OpNotesMainTextBoxWidth,$OpNotesMainTextBoxHeight)
})
$Section1OpNotesTab.Controls.Add($OpNotesListBox)

# Obtains the OpNotes to be viewed and manipulated later
$OpNotesFileContents = Get-Content "$OpNotesFile"

# Checks to see if OpNotes.txt exists and loads it
$OpNotesFileContents = Get-Content "$OpNotesFile"
if (Test-Path -Path $OpNotesFile) {
    $OpNotesListBox.Items.Clear()
    foreach ($OpNotesEntry in $OpNotesFileContents){
        $OpNotesListBox.Items.Add("$OpNotesEntry")
    }
}

#========================================================
#     ___    __                __     ______      __  
#    /   |  / /_  ____  __  __/ /_   /_  __/___ _/ /_ 
#   / /| | / __ \/ __ \/ / / / __/    / / / __ `/ __ \
#  / ___ |/ /_/ / /_/ / /_/ / /_     / / / /_/ / /_/ /
# /_/  |_/_.___/\____/\__,_/\__/    /_/  \__,_/_.___/ 
#                                                    
#========================================================

#######################################################################################################################################################################
##       ##
##  TAB  ## About
##       ##
#######################################################################################################################################################################

$Section1AboutTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text                    = "About"
    Name                    = "About Tab"
    Font                    = New-Object System.Drawing.Font("$Font",11,0,0,0)
    UseVisualStyleBackColor = $True
}
if (Test-Path $PoShHome\Resources\About) { $Section1TabControl.Controls.Add($Section1AboutTab) }

# Variables
$TabRightPosition       = 3
$TabhDownPosition       = 3
$TabAreaWidth           = 446
$TabAreaHeight          = 557
$TextBoxRightPosition   = -2 
$TextBoxDownPosition    = -2
$TextBoxWidth           = 442
$TextBoxHeight          = 536

#####################################################################################################################################
## Section 1 About TabControl
#####################################################################################################################################

# The TabControl controls the tabs within it
$Section1AboutTabControl = New-Object System.Windows.Forms.TabControl -Property @{
    Name          = "About TabControl"
    Location      = New-Object System.Drawing.Size($TabRightPosition,$TabhDownPosition)
    Size          = New-Object System.Drawing.Size($TabAreaWidth,$TabAreaHeight) 
    Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ShowToolTips  = $True
    SelectedIndex = 0
}
$Section1AboutTab.Controls.Add($Section1AboutTabControl)

#------------------------------------
# Auto Creates Tabs and Imports Data
#------------------------------------
# Obtains a list of the files in the resources folder
$ResourceFiles = Get-ChildItem "$PoShHome\Resources\About"

# Iterates through the files and dynamically creates tabs and imports data
foreach ($File in $ResourceFiles) {
    #-----------------------------
    # Creates Tabs From Each File
    #-----------------------------
    $Section1AboutSubTab = New-Object System.Windows.Forms.TabPage -Property @{
        Text                    = $File.BaseName
        UseVisualStyleBackColor = $True
        Font                    = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $Section1AboutTabControl.Controls.Add($Section1AboutSubTab)

    #-----------------------------
    # Imports Data Into Textboxes
    #-----------------------------
    $TabContents                           = Get-Content -Path $File.FullName -Force | foreach {$_ + "`r`n"} 
    $Section1AboutSubTabTextBox            = New-Object System.Windows.Forms.TextBox -Property @{
        Text       = "$TabContents"
        Name       = "$file"
        Location   = New-Object System.Drawing.Size($TextBoxRightPosition,$TextBoxDownPosition) 
        Size       = New-Object System.Drawing.Size($TextBoxWidth,$TextBoxHeight)
        MultiLine  = $True
        ScrollBars = "Vertical"
        Font       = New-Object System.Drawing.Font("Courier New",9,0,0,0)
    }
    $Section1AboutSubTab.Controls.Add($Section1AboutSubTabTextBox)    
}

##############################################################################################################################################################
## Section 2 Tab Control
##############################################################################################################################################################

# Varables to Control Section 1 Tab Control
$Section2TabControlRightPosition  = 470
$Section2TabControlDownPosition   = 5
$Section2TabControlBoxWidth       = 370
$Section2TabControlBoxHeight      = 278

$Section2TabControl               = New-Object System.Windows.Forms.TabControl
$Section2TabControl.Name          = "Main Tab Window"
$Section2TabControl.SelectedIndex = 0
$Section2TabControl.ShowToolTips  = $True
$Section2TabControl.Location      = New-Object System.Drawing.Size($Section2TabControlRightPosition,$Section2TabControlDownPosition) 
$Section2TabControl.Size          = New-Object System.Drawing.Size($Section2TabControlBoxWidth,$Section2TabControlBoxHeight) 
$Section2TabControl.Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
$PoShACME.Controls.Add($Section2TabControl)

#================================================
#     __  ___      _          ______      __  
#    /  |/  /___ _(_)___     /_  __/___ _/ /_ 
#   / /|_/ / __ `/ / __ \     / / / __ `/ __ \
#  / /  / / /_/ / / / / /    / / / /_/ / /_/ /
# /_/  /_/\__,_/_/_/ /_/    /_/  \__,_/_.___/ 
#
#================================================

#######################################################################################################################################################################
##       ##
##  TAB  ## Main
##       ##
#######################################################################################################################################################################

$Section2MainTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text                    = "Main"
    Name                    = "Main"
    UseVisualStyleBackColor = $True
    Font                    = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$Section2TabControl.Controls.Add($Section2MainTab)

# Varables
$Column3RightPosition     = 3
$Column3DownPosition      = 11
$Column3BoxWidth          = 300
$Column3BoxHeight         = 22
$Column3DownPositionShift = 26

$DefaultSingleHostIPText = "<Type In A Hostname / IP>"

#---------------------------------------------------
# Single Host - Enter A Single Hostname/IP Checkbox
#---------------------------------------------------
# This checkbox highlights when selecing computers from the ComputerList
$SingleHostIPCheckBox          = New-Object System.Windows.Forms.Checkbox
$SingleHostIPCheckBox.Name     = "Query A Single Host:"
$SingleHostIPCheckBox.Text     = "$($SingleHostIPCheckBox.Name)"
$SingleHostIPCheckBox.Location = New-Object System.Drawing.Size(3,11) 
$SingleHostIPCheckBox.Size     = New-Object System.Drawing.Size(210,$Column3BoxHeight)
$SingleHostIPCheckBox.Font     = New-Object System.Drawing.Font("$Font",11,1,2,1)
$SingleHostIPCheckBox.Enabled  = $true
$SingleHostIPCheckBox.Add_Click({
    if ($SingleHostIPCheckBox.Checked -eq $true){
        $SingleHostIPTextBox.Text       = ""
        $ComputerListTreeView.Enabled   = $false
        $ComputerListTreeView.BackColor = "lightgray"
    }
    elseif ($SingleHostIPCheckBox.Checked -eq $false) {
        $SingleHostIPTextBox.Text       = $DefaultSingleHostIPText
        $ComputerListTreeView.Enabled   = $true
        $ComputerListTreeView.BackColor = "white"
    }
})
$SingleHostIPCheckBox.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ Queries a single host provided in the input field,
    disabling the computer treeview list.
⦿ Enter a valid hostname or IP address to collect data from. 
⦿ Depending upon host or domain configurations, some queries 
    such as WinRM against valid IPs may not yield results.`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage3))
        $ToolTip.Active       = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation = $true
        $ToolTip.UseFading    = $true
        $ToolTip.IsBalloon    = $true
        $ToolTip.ToolTipIcon  = "Info"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle = 'Query A Single Host'
    }    
})
$Section2MainTab.Controls.Add($SingleHostIPCheckBox)

$Column3DownPosition += $Column3DownPositionShift

#-----------------------------
# Single Host - Input Textbox
#-----------------------------
$SingleHostIPTextBox          = New-Object System.Windows.Forms.TextBox
$SingleHostIPTextBox.Text     = $DefaultSingleHostIPText
$SingleHostIPTextBox.Location = New-Object System.Drawing.Size($Column3RightPosition,($Column3DownPosition + 1))
$SingleHostIPTextBox.Size     = New-Object System.Drawing.Size(235,$Column3BoxHeight)
$SingleHostIPTextBox.Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
$SingleHostIPTextBox.Add_KeyDown({
    $SingleHostIPCheckBox.Checked   = $true
    $ComputerListTreeView.Enabled   = $false
    $ComputerListTreeView.BackColor = "lightgray"
})
$SingleHostIPTextBox.Add_MouseEnter({
    if ($SingleHostIPTextBox.text -eq "$DefaultSingleHostIPText"){ $SingleHostIPTextBox.text = "" }
})
$SingleHostIPTextBox.Add_MouseLeave({ 
    if ($SingleHostIPTextBox.text -eq ""){ $SingleHostIPTextBox.text = "$DefaultSingleHostIPText" }
})
$SingleHostIPTextBox.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ Queries a single host provided in the input field,
    disabling the computer treeview list.
⦿ Enter a valid hostname or IP address to collect data from. 
⦿ Depending upon host or domain configurations, some queries 
    such as WinRM against valid IPs may not yield results.`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage3))
        $ToolTip.Active       = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation = $true
        $ToolTip.UseFading    = $true
        $ToolTip.IsBalloon    = $true
        $ToolTip.ToolTipIcon  = "Info"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle = 'Single Host Input Field'
    }    
})
$Section2MainTab.Controls.Add($SingleHostIPTextBox)

#----------------------------------
# Single Host - Add To List Button
#----------------------------------
$SingleHostIPAddButton          = New-Object System.Windows.Forms.Button
$SingleHostIPAddButton.Text     = "Add To List"
$SingleHostIPAddButton.Location = New-Object System.Drawing.Size(($Column3RightPosition + 240),$Column3DownPosition)
$SingleHostIPAddButton.Size     = New-Object System.Drawing.Size(115,$Column3BoxHeight) 
$SingleHostIPAddButton.Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
$SingleHostIPAddButton.Add_Click({
    # Conducts a simple input check for default or blank data
    if (($SingleHostIPTextBox.Text -ne $DefaultSingleHostIPText) -and ($SingleHostIPTextBox.Text -ne '')) {
        if ($script:ComputerListTreeViewData.Name -contains $SingleHostIPTextBox.Text) {
            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("Add Hostname/IP:  Error")
            $ResultsListBox.Items.Clear()
            $ResultsListBox.Items.Add("Error: $($SingleHostIPTextBox.Text) already exists with the following data:")
            $ResultsListBox.Items.Add("- OU/CN: $($($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $SingleHostIPTextBox.Text}).CanonicalName)")
            $ResultsListBox.Items.Add("- OS:    $($($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $SingleHostIPTextBox.Text}).OperatingSystem)")
            $ResultsListBox.Items.Add("- IP:    $($($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $SingleHostIPTextBox.Text}).IPv4Address)")
            $ResultsListBox.Items.Add("- MAC:   $($($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $SingleHostIPTextBox.Text}).MACAddress)")
        }
        else {
            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("Added Selection:  $($SingleHostIPTextBox.Text)")

            $NewNodeValue = "Manually Added"
            # Adds the hostname/ip entered into the collection list box
            Add-ComputerNode -RootNode $script:TreeNodeComputerList -Category $NewNodeValue -Entry $SingleHostIPTextBox.Text -ToolTip 'No Data Avialable'
            $ResultsListBox.Items.Clear()
            $ResultsListBox.Items.Add("$($SingleHostIPTextBox.Text) has been added to $($NewNodeValue)")

            $ComputerListTreeViewAddHostnameIP = New-Object PSObject -Property @{ 
                Name            = $SingleHostIPTextBox.Text
                OperatingSystem = $NewNodeValue
                CanonicalName   = $NewNodeValue
                IPv4Address     = "No IP Available"
            }        
            $script:ComputerListTreeViewData += $ComputerListTreeViewAddHostnameIP

            $ComputerListTreeView.ExpandAll()
            # Enables the Computer TreeView
            $ComputerListTreeView.Enabled   = $true
            $ComputerListTreeView.BackColor = "white"
            # Clears Textbox
            $SingleHostIPTextBox.Text = $DefaultSingleHostIPText
            # Auto checks/unchecks various checkboxes for visual status indicators
            $SingleHostIPCheckBox.Checked = $false

            Populate-ComputerListTreeViewDefaultData
            TempSave-HostData
        }
    }
})
$SingleHostIPAddButton.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ Adds a single host to the computer treeview.
⦿ The host is added under`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage3))
        $ToolTip.Active       = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation = $true
        $ToolTip.UseFading    = $true
        $ToolTip.IsBalloon    = $true
        $ToolTip.ToolTipIcon  = "Info"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle = 'Query A Single Host'
    }    
})
$Section2MainTab.Controls.Add($SingleHostIPAddButton) 

# Shift Row Location
$Column3DownPosition += $Column3DownPositionShift

# Shift Row Location
$Column3DownPosition += $Column3DownPositionShift

# Shift Row Location
$Column3DownPosition += $Column3DownPositionShift - 3

#-------------------------------------------
# Directory Location - Results Folder Label
#-------------------------------------------
$DirectoryListLabel           = New-Object System.Windows.Forms.Label
$DirectoryListLabel.Location  = New-Object System.Drawing.Size($Column3RightPosition,($Column3DownPosition + 2)) 
$DirectoryListLabel.Size      = New-Object System.Drawing.Size(120,$Column3BoxHeight) 
$DirectoryListLabel.Text      = "Results Folder:"
$DirectoryListLabel.Font      = New-Object System.Drawing.Font("$Font",11,1,2,1)
$DirectoryListLabel.ForeColor = "Black"
$Section2MainTab.Controls.Add($DirectoryListLabel)

#------------------------------------------
# Directory Location - Open Results Button
#------------------------------------------
$DirectoryOpenListBox          = New-Object System.Windows.Forms.Button
$DirectoryOpenListBox.Text     = "Open Results"
$DirectoryOpenListBox.Location = New-Object System.Drawing.Size(($Column3RightPosition + 120),$Column3DownPosition)
$DirectoryOpenListBox.Size     = New-Object System.Drawing.Size(115,$Column3BoxHeight) 
$DirectoryOpenListBox.Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
$DirectoryOpenListBox.Add_Click({ Invoke-Item -Path $CollectedDataDirectory })
$DirectoryOpenListBox.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ Opens the directory where the collected data is saved.
⦿ The 'Collected Data' parent directory is opened by default. 
⦿ After collecting data, the directory opened is changed to that
    of where the data is saved - normally the timestamp folder.
⦿ From here, you can easily navigate the rest of the directory.`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage3))
        $ToolTip.Active         = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation   = $true
        $ToolTip.UseFading      = $true
        $ToolTip.IsBalloon      = $true
        $ToolTip.ToolTipIcon    = "Info"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle   = 'Open Results'
    }
})
$Section2MainTab.Controls.Add($DirectoryOpenListBox)

#-------------------------------------------
# Directory Location - New Timestamp Button
#-------------------------------------------
$DirectoryUpdateListBox              = New-Object System.Windows.Forms.Button
$DirectoryUpdateListBox.Text         = "New Timestamp"
$DirectoryUpdateListBox.Location     = New-Object System.Drawing.Size(($Column3RightPosition + 240),$Column3DownPosition)
$DirectoryUpdateListBox.Size         = New-Object System.Drawing.Size(115,$Column3BoxHeight) 
$DirectoryUpdateListBox.Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
#$DirectoryUpdateListBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") {} })
$DirectoryUpdateListBox.Add_Click({
    $CollectedDataTimeStampDirectory = "$CollectedDataDirectory\$((Get-Date).ToString('yyyy-MM-dd @ HHmm ss'))"
    $CollectionSavedDirectoryTextBox.Text  = $CollectedDataTimeStampDirectory
})
$DirectoryUpdateListBox.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ Provides a new timestamp name for the directory files are saved.
⦿ The timestamp is automatically renewed upon launch of PoSh-ACME.
⦿ Collections are saved to a 'Collected Data' directory that is created
    automatically where the PoSh-ACME script is executed from.
⦿ The directory's timestamp does not auto-renew after data is collected, 
    you have to manually do so. This allows you to easily run multiple
    collections and keep this co-located.
⦿ The full directory path may also be manually modified to contain any
    number or characters that are permitted within NTFS. This allows
    data to be saved to uniquely named or previous directories created.`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage3))
        $ToolTip.Active         = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation   = $true
        $ToolTip.UseFading      = $true
        $ToolTip.IsBalloon      = $true
        $ToolTip.ToolTipIcon    = "Info"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle   = 'New Timestamp'
    }
})
$Section2MainTab.Controls.Add($DirectoryUpdateListBox) 

$Column3DownPosition += $Column3DownPositionShift

#----------------------------------------
# Directory Location - Directory TextBox
#----------------------------------------
# This shows the name of the directy that data will be currently saved to
$CollectionSavedDirectoryTextBox               = New-Object System.Windows.Forms.TextBox
$CollectionSavedDirectoryTextBox.Name          = "Saved Directory List Box"
$CollectionSavedDirectoryTextBox.Text          = $CollectedDataTimeStampDirectory
$CollectionSavedDirectoryTextBox.WordWrap      = $false
$CollectionSavedDirectoryTextBox.AcceptsTab    = $true
$CollectionSavedDirectoryTextBox.TabStop       = $true
#$CollectionSavedDirectoryTextBox.Multiline     = $true
#$CollectionSavedDirectoryTextBox.AutoSize      = $true
$CollectionSavedDirectoryTextBox.AutoCompleteSource = "FileSystem" # Options are: FileSystem, HistoryList, RecentlyUsedList, AllURL, AllSystemSources, FileSystemDirectories, CustomSource, ListItems, None
$CollectionSavedDirectoryTextBox.AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
$CollectionSavedDirectoryTextBox.Location      = New-Object System.Drawing.Size($Column3RightPosition,$Column3DownPosition) 
$CollectionSavedDirectoryTextBox.Size          = New-Object System.Drawing.Size(354,35)
$CollectionSavedDirectoryTextBox.Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
$CollectionSavedDirectoryTextBox.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ This path supports auto-directory completion.
⦿ Collections are saved to a 'Collected Data' directory that is created
    automatically where the PoSh-ACME script is executed from.
⦿ The directory's timestamp does not auto-renew after data is collected, 
    you have to manually do so. This allows you to easily run multiple
    collections and keep this co-located.
⦿ The full directory path may also be manually modified to contain any
    number or characters that are permitted within NTFS. This allows
    data to be saved to uniquely named or previous directories created.`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage3))
        $ToolTip.Active         = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation   = $true
        $ToolTip.UseFading      = $true
        $ToolTip.IsBalloon      = $true
        $ToolTip.ToolTipIcon    = "Info"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle   = 'Results Folder'
    }
})
$Section2MainTab.Controls.Add($CollectionSavedDirectoryTextBox)

#============================================================================================================================================================
# Results Section
#============================================================================================================================================================

#-------------------------------------------
# Directory Location - Results Folder Label
#-------------------------------------------
$ResultsSectionLabel           = New-Object System.Windows.Forms.Label
$ResultsSectionLabel.Location  = New-Object System.Drawing.Size(2,200) 
$ResultsSectionLabel.Size      = New-Object System.Drawing.Size(230,$Column3BoxHeight) 
$ResultsSectionLabel.Text      = "Choose How To View Results"
$ResultsSectionLabel.Font      = New-Object System.Drawing.Font("$Font",11,1,2,1)
$ResultsSectionLabel.ForeColor = "Black"
$Section2MainTab.Controls.Add($ResultsSectionLabel)

#============================================================================================================================================================
# View Results
#============================================================================================================================================================
$OpenResultsButton          = New-Object System.Windows.Forms.Button
$OpenResultsButton.Name     = "View Results"
$OpenResultsButton.Text     = "$($OpenResultsButton.Name)"
$OpenResultsButton.UseVisualStyleBackColor = $True
$OpenResultsButton.Location = New-Object System.Drawing.Size(2,($ResultsSectionLabel.Location.Y + $ResultsSectionLabel.Size.Height + 5))
$OpenResultsButton.Size     = New-Object System.Drawing.Size(115,22)
$OpenResultsButton.Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
$OpenResultsButton.Add_Click({
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    $ViewCSVResultsOpenResultsOpenFileDialog                  = New-Object System.Windows.Forms.OpenFileDialog
    $ViewCSVResultsOpenResultsOpenFileDialog.Title            = "View Collection Results"
    $ViewCSVResultsOpenResultsOpenFileDialog.InitialDirectory = "$(if (Test-Path $($CollectionSavedDirectoryTextBox.Text)) {$($CollectionSavedDirectoryTextBox.Text)} else {$CollectedDataDirectory})"
    $ViewCSVResultsOpenResultsOpenFileDialog.filter           = "Results (*.txt;*.csv;*.xlsx;*.xls)|*.txt;*.csv;*.xls;*.xlsx|Text (*.txt)|*.txt|CSV (*.csv)|*.csv|Excel (*.xlsx)|*.xlsx|Excel (*.xls)|*.xls|All files (*.*)|*.*"
    $ViewCSVResultsOpenResultsOpenFileDialog.ShowDialog() | Out-Null
    $ViewCSVResultsOpenResultsOpenFileDialog.ShowHelp = $true
    Import-Csv $($ViewCSVResultsOpenResultsOpenFileDialog.filename) | Out-GridView -Title "$($ViewCSVResultsOpenResultsOpenFileDialog.filename)" -OutputMode Multiple | Set-Variable -Name ViewImportResults
    
    if ($ViewImportResults) {
        $OpNotesListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) View CSV File:  $($ViewCSVResultsOpenResultsOpenFileDialog.filename)")
        Add-Content -Path $OpNotesWriteOnlyFile -Value ("$($(Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) View CSV File:  $($ViewCSVResultsOpenResultsOpenFileDialog.filename)") -Force 
        foreach ($Selection in $ViewImportResults) {
            $OpNotesListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  $($($Selection -replace '@{','' -replace '}','') -replace '@{','' -replace '}','')")
            Add-Content -Path $OpNotesWriteOnlyFile -Value ("$($(Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  $($Selection -replace '@{','' -replace '}','')") -Force 
        }
    }
    Save-OpNotes
})
$OpenResultsButton.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ Utilizes Out-GridView to view the results.
⦿ Out-GridView is native to PowerShell, lightweight, and fast.
⦿ Results can be easily filtered with conditional statements.
⦿ Collected data from is primarily saved as CSVs, so they can 
    be opened with Excel or similar products.
⦿ Multiple lines can be selected and added to OpNotes.
    The selection can be contiguous by using the Shift key
    and/or be separate using the Ctrl key, the press OK.`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage123))
        $ToolTip.Active         = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation   = $true
        $ToolTip.UseFading      = $true
        $ToolTip.IsBalloon      = $true
        $ToolTip.ToolTipIcon    = "Info"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle   = 'View Results'
    }
})
$Section2MainTab.Controls.Add($OpenResultsButton)

$Column5DownPosition += $Column5DownPositionShift

#============================================================================================================================================================
# Compare CSV Files
#============================================================================================================================================================

#--------------------
# Compare CSV Button
#--------------------
$CompareButton          = New-Object System.Windows.Forms.Button
$CompareButton.Name     = "Compare CSVs"
$CompareButton.Text     = "$($CompareButton.Name)"
$CompareButton.UseVisualStyleBackColor = $True
$CompareButton.Location = New-Object System.Drawing.Size(($OpenResultsButton.Location.X + $OpenResultsButton.Size.Width + 5),$OpenResultsButton.Location.Y)
$CompareButton.Size     = New-Object System.Drawing.Size(115,22)
$CompareButton.Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
$CompareButton.Add_Click({
    # Compare Reference Object
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    $OpenCompareReferenceObjectFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenCompareReferenceObjectFileDialog.Title = "Compare Reference Csv"
    $OpenCompareReferenceObjectFileDialog.InitialDirectory = "$CollectedDataDirectory"
    $OpenCompareReferenceObjectFileDialog.filter = "CSV (*.csv)| *.csv|Excel (*.xlsx)| *.xlsx|Excel (*.xls)| *.xls|All files (*.*)|*.*"
    $OpenCompareReferenceObjectFileDialog.ShowDialog() | Out-Null
    $OpenCompareReferenceObjectFileDialog.ShowHelp = $true

    if ($OpenCompareReferenceObjectFileDialog.Filename) {

    # Compare Difference Object
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    $OpenCompareDifferenceObjectFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenCompareDifferenceObjectFileDialog.Title = "Compare Difference Csv"
    $OpenCompareDifferenceObjectFileDialog.InitialDirectory = "$CollectedDataDirectory"
    $OpenCompareDifferenceObjectFileDialog.filter = "CSV (*.csv)| *.csv|Excel (*.xlsx)| *.xlsx|Excel (*.xls)| *.xls|All files (*.*)|*.*"
    $OpenCompareDifferenceObjectFileDialog.ShowDialog() | Out-Null
    $OpenCompareDifferenceObjectFileDialog.ShowHelp = $true

    if ($OpenCompareDifferenceObjectFileDialog.Filename) {

    # Imports Csv file headers
    [array]$DropDownArrayItems = Import-Csv $OpenCompareReferenceObjectFileDialog.FileName | Get-Member -MemberType NoteProperty | Select-Object -Property Name -ExpandProperty Name
    [array]$DropDownArray = $DropDownArrayItems | sort

    # This Function Returns the Selected Value and Closes the Form
    function CompareCsvFilesFormReturn-DropDown {
        if ($DropDownField.SelectedItem -eq $null){
            $DropDownField.SelectedItem = $DropDownField.Items[0]
            $script:Choice = $DropDownField.SelectedItem.ToString()
            $CompareCsvFilesForm.Close()
        }
        else{
            $script:Choice = $DropDownField.SelectedItem.ToString()
            $CompareCsvFilesForm.Close()
        }
    }
    function SelectProperty{
        [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
        [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

        #------------------------
        # Compare Csv Files Form
        #------------------------
        $CompareCsvFilesForm = New-Object System.Windows.Forms.Form
        $CompareCsvFilesForm.width  = 330
        $CompareCsvFilesForm.height = 160
        $CompareCsvFilesForm.Text   = ”Compare Two CSV Files”
        $CompareCsvFilesForm.Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$ResourcesDirectory\favicon.ico")
        $CompareCsvFilesForm.StartPosition = "CenterScreen"
        $CompareCsvFilesForm.ControlBox = $true
        #$CompareCsvFilesForm.Add_Shown({$CompareCsvFilesForm.Activate()})

        #-----------------
        # Drop Down Label
        #-----------------
        $DropDownLabel          = New-Object System.Windows.Forms.Label
        $DropDownLabel.Location = New-Object System.Drawing.Size(10,10) 
        $DropDownLabel.size     = New-Object System.Drawing.Size(290,45) 
        $DropDownLabel.Text     = "What Property Field Do You Want To Compare?`n  <=   Found in the Reference File`n  =>   Found in the Difference File`n`nReplace the 'Name' property as necessary..."
        $DropDownLabel.Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        $CompareCsvFilesForm.Controls.Add($DropDownLabel)

        #-----------------
        # Drop Down Field
        #-----------------
        $DropDownField          = New-Object System.Windows.Forms.ComboBox
        $DropDownField.Location = New-Object System.Drawing.Size(10,($DropDownLabel.Location.y + $DropDownLabel.Size.Height))
        $DropDownField.Size     = New-Object System.Drawing.Size(290,30)
        ForEach ($Item in $DropDownArray) {
         [void] $DropDownField.Items.Add($Item)
        }
        $DropDownField.Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        $CompareCsvFilesForm.Controls.Add($DropDownField)

        #------------------
        # Drop Down Button
        #------------------
        $DropDownButton          = New-Object System.Windows.Forms.Button
        $DropDownButton.Location = New-Object System.Drawing.Size(10,($DropDownField.Location.y + $DropDownField.Size.Height + 10))
        $DropDownButton.Size     = New-Object System.Drawing.Size(100,20)
        $DropDownButton.Text     = "Execute"
        $DropDownButton.Add_Click({CompareCsvFilesFormReturn-DropDown})
        $DropDownButton.Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        $CompareCsvFilesForm.Controls.Add($DropDownButton)   

        [void] $CompareCsvFilesForm.ShowDialog()
        return $script:choice
    }
    $Property = $null
    $Property = SelectProperty
   
    #--------------------------------
    # Compares two Csv files Command
    #--------------------------------
    Compare-Object -ReferenceObject (Import-Csv $OpenCompareReferenceObjectFileDialog.FileName) -DifferenceObject (Import-Csv $OpenCompareDifferenceObjectFileDialog.FileName) -Property $Property `
        | Out-GridView -Title "Reference [<=]:  `"$(($OpenCompareReferenceObjectFileDialog.FileName).split('\') | ? {$_ -match '\d\d\d\d-\d\d-\d\d'})...$(($OpenCompareReferenceObjectFileDialog.FileName).split('\')[-1])`"  <-->  Difference [=>]:  `"$(($OpenCompareDifferenceObjectFileDialog.FileName).split('\') | ? {$_ -match '\d\d\d\d-\d\d-\d\d'})...$(($OpenCompareDifferenceObjectFileDialog.FileName).split('\')[-1])`"" -OutputMode Multiple | Set-Variable -Name CompareImportResults

    # Outputs messages to ResultsListBox 
    $ResultsListBox.Items.Clear()
    $ResultsListBox.Items.Add("Compare Reference File:  $($OpenCompareReferenceObjectFileDialog.FileName)")
    $ResultsListBox.Items.Add("Compare Difference File: $($OpenCompareDifferenceObjectFileDialog.FileName)")
    $ResultsListBox.Items.Add("Compare Property Field:  $($Property)")

    # Writes selected fields to OpNotes
    if ($CompareImportResults) {
        $OpNotesListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) Compare Reference File:  $($OpenCompareReferenceObjectFileDialog.FileName)")
        $OpNotesListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) Compare Difference File: $($OpenCompareDifferenceObjectFileDialog.FileName)")
        $OpNotesListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) Compare Property Field:  $($OpenCompareWhatToCompare)")
        foreach ($Selection in $CompareImportResults) {
            $OpNotesListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  Compare: $($Selection -replace '@{','' -replace '}','')")
            Add-Content -Path $OpNotesWriteOnlyFile -Value ("$($(Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  $($OpNotesListBox.SelectedItems)") -Force 
        }
        $Section1TabControl.SelectedTab = $Section1OpNotesTab
    }
    Save-OpNotes

    } # End If Statement for Compare CSV Reference
    } # End If Statement for Compare CSV Difference
})
$CompareButton.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ Utilizes Compare-Object to compare two similar CSV Files.
⦿ Reads the CSV header and provides a dropdown to select a field.
⦿ Provides basic results, indicating which file has different lines:
    The side indicator of <= are for findings in the Reference File.
    The side indicator of => are for findings in the Difference File.
⦿ If the two files are identical, no results will be provided.
⦿ Multiple lines can be selected and added to OpNotes.
    The selection can be contiguous by using the Shift key
    and/or be separate using the Ctrl key, the press OK.`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage123))
        $ToolTip.Active         = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation   = $true
        $ToolTip.UseFading      = $true
        $ToolTip.IsBalloon      = $true
        $ToolTip.ToolTipIcon    = "Info"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle   = 'Compare CSVs'
    }
})
$Section2MainTab.Controls.Add($CompareButton)

# The Invoke-SaveChartAsImage function is use by 'build charts and autocharts'
Function Invoke-SaveChartAsImage {
    $FileTypes = [enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')| ForEach {
        $_.Insert(0,'*.')
    }
    $SaveFileDlg = New-Object System.Windows.Forms.SaveFileDialog
    $SaveFileDlg.DefaultExt='PNG'
    $SaveFileDlg.Filter="Image Files ($($FileTypes)) | All Files (*.*)|*.*"
    $return = $SaveFileDlg.ShowDialog()
    If ($Return -eq 'OK') {
        [pscustomobject]@{
            FileName = $SaveFileDlg.FileName
            Extension = $SaveFileDlg.FileName -replace '.*\.(.*)','$1'
        }
    }
}
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms.DataVisualization

#============================================================================================================================================================
# Custom View Chart
#============================================================================================================================================================
#-------------------
# View Chart Button
#-------------------
$BuildChartButton          = New-Object System.Windows.Forms.Button
$BuildChartButton.Name     = "Build Chart"
$BuildChartButton.Text     = "$($BuildChartButton.Name)"
$BuildChartButton.UseVisualStyleBackColor = $True
$BuildChartButton.Location = New-Object System.Drawing.Size(($CompareButton.Location.X + $CompareButton.Size.Width + 5),$CompareButton.Location.Y)
$BuildChartButton.Size     = New-Object System.Drawing.Size(115,22)
$BuildChartButton.Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
$BuildChartButton.Add_Click({
    # Open File
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    $ViewChartOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $ViewChartOpenFileDialog.Title = "Open File To View As A Chart"
    $ViewChartOpenFileDialog.InitialDirectory = "$CollectedDataDirectory"
    $ViewChartOpenFileDialog.Filter = "CSV (*.csv)| *.csv|Excel (*.xlsx)| *.xlsx|Excel (*.xls)| *.xls|All files (*.*)|*.*"
    $ViewChartOpenFileDialog.ShowDialog() | Out-Null
    $ViewChartOpenFileDialog.ShowHelp = $true

    #====================================
    # Custom View Chart Command Function
    #====================================
    function ViewChartCommand {
        #https://bytecookie.wordpress.com/2012/04/13/tutorial-powershell-and-microsoft-chart-controls-or-how-to-spice-up-your-reports/
        # PowerShell v3+ OR PowerShell v2 with Microsoft Chart Controls for Microsoft .NET Framework 3.5 Installed
        #-----------------------------------------
        # Custom View Chart - Obtains source data
        #-----------------------------------------
            $DataSource = $ViewChartFile | Select-Object -Property $Script:ViewChartChoice[0], $Script:ViewChartChoice[1]

        #--------------------------
        # Custom View Chart Object
        #--------------------------
            $Chart = New-object System.Windows.Forms.DataVisualization.Charting.Chart
            $Chart.Width           = 700
            $Chart.Height          = 400
            $Chart.Left            = 10
            $Chart.Top             = 10
            $Chart.BackColor       = [System.Drawing.Color]::White
            $Chart.BorderColor     = 'Black'
            $Chart.BorderDashStyle = 'Solid'
            $Chart.Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','18', [System.Drawing.FontStyle]::Bold)
        #-------------------------
        # Custom View Chart Title 
        #-------------------------
            $ChartTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title
            $ChartTitle.text      = ($ViewChartOpenFileDialog.FileName.split('\'))[-1] -replace '.csv',''
            $ChartTitle.Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','18', [System.Drawing.FontStyle]::Bold)
            $ChartTitle.ForeColor = "black"
            $ChartTitle.Alignment = "topcenter" #"topLeft"
            $Chart.Titles.Add($ChartTitle)
        #------------------------
        # Custom View Chart Area
        #------------------------
            $ChartArea                = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
            $ChartArea.Name           = "Chart Area"
            $ChartArea.AxisX.Title    = $Script:ViewChartChoice[0]
            if ($Script:ViewChartChoice[1] -eq "PSComputername") {$ChartArea.AxisY.Title = "Number of Computers"}
            else {$ChartArea.AxisY.Title    = $Script:ViewChartChoice[1]}
            $ChartArea.AxisX.Interval = 1
            #$ChartArea.AxisY.Interval = 1
            $ChartArea.AxisY.IntervalAutoMode = $true

            # Option to enable 3D Charts
            if ($Script:ViewChartChoice[7] -eq $true) {
                $ChartArea.Area3DStyle.Enable3D=$True
                $ChartArea.Area3DStyle.Inclination = 50
            }
            $Chart.ChartAreas.Add($ChartArea)
        #--------------------------
        # Custom View Chart Legend 
        #--------------------------
            $Legend = New-Object system.Windows.Forms.DataVisualization.Charting.Legend
            $Legend.Enabled = $Script:ViewChartChoice[6]
            $Legend.Name = "Legend"
            $Legend.Title = $Script:ViewChartChoice[1]
            $Legend.TitleAlignment = "topleft"
            $Legend.TitleFont = New-Object System.Drawing.Font @('Microsoft Sans Serif','11', [System.Drawing.FontStyle]::Bold)
            $Legend.IsEquallySpacedItems = $True
            $Legend.BorderColor = 'Black'
            $Chart.Legends.Add($Legend)
        #---------------------------------
        # Custom View Chart Data Series 1
        #---------------------------------
            $Series01Name = $Script:ViewChartChoice[1]
            $Chart.Series.Add("$Series01Name")
            $Chart.Series["$Series01Name"].ChartType = $Script:ViewChartChoice[2]
            $Chart.Series["$Series01Name"].BorderWidth  = 1
            $Chart.Series["$Series01Name"].IsVisibleInLegend = $true
            $Chart.Series["$Series01Name"].Chartarea = "Chart Area"
            $Chart.Series["$Series01Name"].Legend = "Legend"
            $Chart.Series["$Series01Name"].Color = "#62B5CC"
            $Chart.Series["$Series01Name"].Font = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
            # Pie Charts - Moves text off pie
            $Chart.Series["$Series01Name"]['PieLabelStyle'] = 'Outside'
            $Chart.Series["$Series01Name"]['PieLineColor'] = 'Black'
            $Chart.Series["$Series01Name"]['PieDrawingStyle'] = 'Concave'

        #-----------------------------------------------------------
        # Custom View Chart - Code that counts computers that match
        #-----------------------------------------------------------
            # If the Second field/Y Axis equals PSComputername, it counts it
            if ($Script:ViewChartChoice[1] -eq "PSComputerName") {
                $Script:ViewChartChoice0 = "Name"
                $Script:ViewChartChoice1 = "PSComputerName"                
                #test# $DataSource = Import-Csv "C:\Users\Dan\Documents\GitHub\Dev Ops\Collected Data\2018-10-23 @ 2246 51\Processes.csv"
                $UniqueDataFields = $DataSource | Select-Object -Property $Script:ViewChartChoice0 | Sort-Object -Property $Script:ViewChartChoice0 -Unique                
                $ComputerWithDataResults = @()
                foreach ($DataField in $UniqueDataFields) {
                    $Count = 0
                    $Computers = @()
                    foreach ( $Line in $DataSource ) { 
                        if ( $Line.Name -eq $DataField.Name ) {
                            $Count += 1
                            if ( $Computers -notcontains $Line.PSComputerName ) { $Computers += $Line.PSComputerName }
                        }
                    }
                    $UniqueCount = $Computers.Count
                    $ComputersWithData =  New-Object PSObject -Property @{
                        DataField    = $DataField
                        TotalCount   = $Count
                        UniqueCount  = $UniqueCount
                        ComputerHits = $Computers 
                    }
                    $ComputerWithDataResults += $ComputersWithData
                    #"$DataField"
                    #"Count: $Count"
                    #"Computers: $Computers"
                    #"------------------------------"
                }
                #$DataSourceX = '$_.DataField.Name'
                #$DataSourceY = '$_.UniqueCount'
                if ($Script:ViewChartChoice[5]) {
                    $ComputerWithDataResults `
                        | Sort-Object -Property UniqueCount -Descending `
                        | Select-Object -First $Script:ViewChartChoice[3] `
                        | ForEach-Object {$Chart.Series["$Series01Name"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
                }
                else {
                    $ComputerWithDataResults `
                        | Sort-Object -Property UniqueCount `
                        | Select-Object -First $Script:ViewChartChoice[3] `
                        | ForEach-Object {$Chart.Series["$Series01Name"].Points.AddXY($_.DataField.Name,$_.UniqueCount)}
                }
            }
            # If the Second field/Y Axis DOES NOT equal PSComputername, Data is generated from the DataSource fields Selected
            else {
                Convert-CSVNumberStringsToIntergers $DataSource
                $DataSourceX = '$_.($Script:ViewChartXChoice)'
                $DataSourceY = '$_.($Script:ViewChartYChoice)'
                if ($Script:ViewChartChoice[5]) {
                    $DataSource `
                    | Sort-Object -Property $Script:ViewChartChoice[1] -Descending `
                    | Select-Object -First $Script:ViewChartChoice[3] `
                    | ForEach-Object {$Chart.Series["$Series01Name"].Points.AddXY( $(iex $DataSourceX), $(iex $DataSourceY) )}  
                }
                else {
                    $DataSource `
                    | Sort-Object -Property $Script:ViewChartChoice[1] `
                    | Select-Object -First $Script:ViewChartChoice[3] `
                    | ForEach-Object {$Chart.Series["$Series01Name"].Points.AddXY( $(iex $DataSourceX), $(iex $DataSourceY) )}  
                }
            }        
        #------------------------
        # Custom View Chart Form 
        #------------------------
            $AnchorAll = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right -bor
                [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left
            $ViewChartForm               = New-Object Windows.Forms.Form
            $ViewChartForm.Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$ResourcesDirectory\favicon.ico")
            $ViewChartForm.Width         = 740
            $ViewChartForm.Height        = 490
            $ViewChartForm.StartPosition = "CenterScreen"
            $ViewChartForm.Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
            $ViewChartForm.controls.add($Chart)
            $Chart.Anchor = $AnchorAll
        #-------------------------------
        # Custom View Chart Save Button
        #-------------------------------
            $SaveButton        = New-Object Windows.Forms.Button
            $SaveButton.Text   = "Save Image"
            $SaveButton.Top    = 420
            $SaveButton.Left   = 600
            $SaveButton.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
             [enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
            $SaveButton.Add_Click({
                $Result = Invoke-SaveChartAsImage
                If ($Result) { $Chart.SaveImage($Result.FileName, $Result.Extension) }
            })
            $SaveButton.Font   = New-Object System.Drawing.Font("$Font",11,0,0,0)
        $ViewChartForm.controls.add($SaveButton)
        $ViewChartForm.Add_Shown({$ViewChartForm.Activate()})
        [void]$ViewChartForm.ShowDialog()

        #---------------------------------------
        # Custom View Chart - Autosave an Image
        #---------------------------------------
        # Autosaves the chart if checked
        $FileName           = ($ViewChartOpenFileDialog.FileName.split('\'))[-1] -replace '.csv',''
        $FileDate           = ($ViewChartOpenFileDialog.FileName.split('\'))[-2] -replace '.csv',''
        if ($OptionsAutoSaveChartsAsImages.checked) { $Chart.SaveImage("$AutosavedChartsDirectory\$FileDate-$FileName.png", 'png') }    }

    #=================================================
    # Custom View Chart Select Property Form Function
    #=================================================
    # This following 'if statement' is used for when canceling out of a window
    if ($ViewChartOpenFileDialog.FileName) {
        # Imports the file chosen
        $ViewChartFile = Import-Csv $ViewChartOpenFileDialog.FileName
        [array]$ViewChartArrayItems = $ViewChartFile | Get-Member -MemberType NoteProperty | Select-Object -Property Name -ExpandProperty Name
        [array]$ViewChartArray = $ViewChartArrayItems | Sort-Object

        function ViewChartSelectProperty{
            [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
            [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

            #------------------------------------
            # Custom View Chart Execute Function
            #------------------------------------
            # This Function Returns the Selected Value from the Drop Down and then Closes the Form
            function ViewChartExecute {
                if ($ViewChartXComboBox.SelectedItem -eq $null){
                    #$ViewChartXComboBox.SelectedItem = $ViewChartXComboBox.Items[0]
                    $ViewChartXComboBox.SelectedItem = "Name"
                    $Script:ViewChartXChoice = $ViewChartXComboBox.SelectedItem.ToString()
                    #$ViewChartSelectionForm.Close()
                }
                if ($ViewChartYComboBox.SelectedItem -eq $null){
                    #$ViewChartYComboBox.SelectedItem = $ViewChartYComboBox.Items[0]
                    $ViewChartYComboBox.SelectedItem = "PSComputerName"
                    $Script:ViewChartYChoice = $ViewChartYComboBox.SelectedItem.ToString()
                    #$ViewChartSelectionForm.Close()
                }
                if ($ViewChartChartTypesComboBox.SelectedItem -eq $null){
                    #$ViewChartChartTypesComboBox.SelectedItem = $ViewChartChartTypesComboBox.Items[0]
                    $ViewChartChartTypesComboBox.SelectedItem = "Column"
                    $Script:ViewChartChartTypesChoice = $ViewChartChartTypesComboBox.SelectedItem.ToString()
                    #$ViewChartSelectionForm.Close()
                }
                else{
                    $Script:ViewChartXChoice = $ViewChartXComboBox.SelectedItem.ToString()
                    $Script:ViewChartYChoice = $ViewChartYComboBox.SelectedItem.ToString()
                    $Script:ViewChartChartTypesChoice = $ViewChartChartTypesComboBox.SelectedItem.ToString()
                    ViewChartCommand
                    #$ViewChartSelectionForm.Close()
                }
                # This array outputs the multiple results and is later used in the charts
                $Script:ViewChartChoice = @($Script:ViewChartXChoice, $Script:ViewChartYChoice, $Script:ViewChartChartTypesChoice, $ViewChartLimitResultsTextBox.Text, $ViewChartAscendingRadioButton.Checked, $ViewChartDescendingRadioButton.Checked, $ViewChartLegendCheckBox.Checked, $ViewChart3DChartCheckBox.Checked)
                <# Notes:
                    $Script:ViewChartChoice[0] = $Script:ViewChartXChoice
                    $Script:ViewChartChoice[1] = $Script:ViewChartYChoice
                    $Script:ViewChartChoice[2] = $Script:ViewChartChartTypesChoice
                    $Script:ViewChartChoice[3] = $ViewChartLimitResultsTextBox.Text
                    $Script:ViewChartChoice[4] = $ViewChartAscendingRadioButton.Checked
                    $Script:ViewChartChoice[5] = $ViewChartDescendingRadioButton.Checked
                    $Script:ViewChartChoice[6] = $ViewChartLegendCheckBox.Checked
                    $Script:ViewChartChoice[7] = $ViewChart3DChartCheckBox.Checked
                #>
                return $Script:ViewChartChoice
            }

            #----------------------------------
            # Custom View Chart Selection Form
            #----------------------------------
            $ViewChartSelectionForm        = New-Object System.Windows.Forms.Form 
            $ViewChartSelectionForm.width  = 327
            $ViewChartSelectionForm.height = 287 
            $ViewChartSelectionForm.StartPosition = "CenterScreen"
            $ViewChartSelectionForm.Text   = ”View Chart - Select Fields ”
            $ViewChartSelectionForm.Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$ResourcesDirectory\favicon.ico")
            $ViewChartSelectionForm.ControlBox = $true
            #$ViewChartSelectionForm.Add_Shown({$ViewChartSelectionForm.Activate()})

            #------------------------------
            # Custom View Chart Main Label
            #------------------------------
            $ViewChartMainLabel          = New-Object System.Windows.Forms.Label
            $ViewChartMainLabel.Location = New-Object System.Drawing.Size(10,10) 
            $ViewChartMainLabel.size     = New-Object System.Drawing.Size(290,25) 
            $ViewChartMainLabel.Text     = "Fill out the bellow to view a chart of a csv file:`nNote: Currently some limitations with compiled results files."
            $ViewChartMainLabel.Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
            $ViewChartSelectionForm.Controls.Add($ViewChartMainLabel)

            #------------------------------
            # Custom View Chart X ComboBox
            #------------------------------
            $ViewChartXComboBox          = New-Object System.Windows.Forms.ComboBox
            $ViewChartXComboBox.Location = New-Object System.Drawing.Size(10,($ViewChartMainLabel.Location.y + $ViewChartMainLabel.Size.Height + 5))
            $ViewChartXComboBox.Size     = New-Object System.Drawing.Size(185,25)
            $ViewChartXComboBox.Text     = "Field 1 - X Axis"
            $ViewChartXComboBox.AutoCompleteSource = "ListItems"
            $ViewChartXComboBox.AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
            $ViewChartXComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") {ViewChartExecute} })
            ForEach ($Item in $ViewChartArray) { $ViewChartXComboBox.Items.Add($Item) }
            $ViewChartXComboBox.Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
            $ViewChartSelectionForm.Controls.Add($ViewChartXComboBox)

            #------------------------------
            # Custom View Chart Y ComboBox
            #------------------------------
            $ViewChartYComboBox          = New-Object System.Windows.Forms.ComboBox
            $ViewChartYComboBox.Location = New-Object System.Drawing.Size(10,($ViewChartXComboBox.Location.y + $ViewChartXComboBox.Size.Height + 5))
            $ViewChartYComboBox.Size     = New-Object System.Drawing.Size(185,25)
            $ViewChartYComboBox.Text     = "Field 2 - Y Axis"
            $ViewChartYComboBox.AutoCompleteSource = "ListItems"
            $ViewChartYComboBox.AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
            $ViewChartYComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") {ViewChartExecute} })
            ForEach ($Item in $ViewChartArray) { $ViewChartYComboBox.Items.Add($Item) }
            $ViewChartYComboBox.Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
            $ViewChartSelectionForm.Controls.Add($ViewChartYComboBox)

            #----------------------------------
            # Custom View Chart Types ComboBox
            #----------------------------------
            $ViewChartChartTypesComboBox          = New-Object System.Windows.Forms.ComboBox
            $ViewChartChartTypesComboBox.Location = New-Object System.Drawing.Size(10,($ViewChartYComboBox.Location.y + $ViewChartYComboBox.Size.Height + 5))
            $ViewChartChartTypesComboBox.Size     = New-Object System.Drawing.Size(185,25)
            $ViewChartChartTypesComboBox.Text     = "Chart Types"
            $ViewChartChartTypesComboBox.AutoCompleteSource = "ListItems"
            $ViewChartChartTypesComboBox.AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
            $ViewChartChartTypesComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") {ViewChartExecute} })
            $ChartTypesAvailable = @('Pie','Column','Line','Bar','Doughnut','Area','--- Less Commonly Used Below ---','BoxPlot','Bubble','CandleStick','ErrorBar','Fastline','FastPoint','Funnel','Kagi','Point','PointAndFigure','Polar','Pyramid','Radar','Range','Rangebar','RangeColumn','Renko','Spline','SplineArea','SplineRange','StackedArea','StackedBar','StackedColumn','StepLine','Stock','ThreeLineBreak')
            ForEach ($Item in $ChartTypesAvailable) {
             [void] $ViewChartChartTypesComboBox.Items.Add($Item)
            }
            $ViewChartChartTypesComboBox.Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
            $ViewChartSelectionForm.Controls.Add($ViewChartChartTypesComboBox) 

            #---------------------------------------
            # Custom View Chart Limit Results Label
            #---------------------------------------
            $ViewChartLimitResultsLabel          = New-Object System.Windows.Forms.Label
            $ViewChartLimitResultsLabel.Location = New-Object System.Drawing.Size(10,($ViewChartChartTypesComboBox.Location.y + $ViewChartChartTypesComboBox.Size.Height + 8)) 
            $ViewChartLimitResultsLabel.size     = New-Object System.Drawing.Size(120,25) 
            $ViewChartLimitResultsLabel.Text     = "Limit Results to:"
            $ViewChartLimitResultsLabel.Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
            $ViewChartSelectionForm.Controls.Add($ViewChartLimitResultsLabel)

            #-----------------------------------------
            # Custom View Chart Limit Results Textbox
            #-----------------------------------------
            $ViewChartLimitResultsTextBox          = New-Object System.Windows.Forms.TextBox
            $ViewChartLimitResultsTextBox.Text     = 10
            $ViewChartLimitResultsTextBox.Location = New-Object System.Drawing.Size(135,($ViewChartChartTypesComboBox.Location.y + $ViewChartChartTypesComboBox.Size.Height + 5))
            $ViewChartLimitResultsTextBox.Size     = New-Object System.Drawing.Size(60,25)
            $ViewChartLimitResultsTextBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") {ViewChartExecute} })
            $ViewChartLimitResultsTextBox.Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
            $ViewChartSelectionForm.Controls.Add($ViewChartLimitResultsTextBox)

            #---------------------------------------
            # Custom View Chart Sort Order GroupBox
            #---------------------------------------
            # Create a group that will contain your radio buttons
            $ViewChartSortOrderGroupBox          = New-Object System.Windows.Forms.GroupBox
            $ViewChartSortOrderGroupBox.Location = New-Object System.Drawing.Size(10,($ViewChartLimitResultsTextBox.Location.y + $ViewChartLimitResultsTextBox.Size.Height + 7))
            $ViewChartSortOrderGroupBox.size     = '290,65'
            $ViewChartSortOrderGroupBox.text     = "Select how to Sort Data:"

                ### Ascending Radio Button
                $ViewChartAscendingRadioButton          = New-Object System.Windows.Forms.RadioButton
                $ViewChartAscendingRadioButton.Location = New-Object System.Drawing.Size(20,15)
                $ViewChartAscendingRadioButton.size     = '250,25'
                $ViewChartAscendingRadioButton.Checked  = $false
                $ViewChartAscendingRadioButton.Text     = "Ascending / Lowest to Highest"
                $ViewChartAscendingRadioButton.Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
                
                ### Descending Radio Button
                $ViewChartDescendingRadioButton          = New-Object System.Windows.Forms.RadioButton
                $ViewChartDescendingRadioButton.Location = New-Object System.Drawing.Size(20,38)
                $ViewChartDescendingRadioButton.size     = '250,25'
                $ViewChartDescendingRadioButton.Checked  = $true
                $ViewChartDescendingRadioButton.Text     = "Descending / Highest to Lowest"
                $ViewChartDescendingRadioButton.Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
                
                $ViewChartSortOrderGroupBox.Controls.AddRange(@($ViewChartAscendingRadioButton,$ViewChartDescendingRadioButton))
            $ViewChartSelectionForm.Controls.Add($ViewChartSortOrderGroupBox) 

            #------------------------------------
            # Custom View Chart Options GroupBox
            #------------------------------------
            # Create a group that will contain your radio buttons
            $ViewChartOptionsGroupBox          = New-Object System.Windows.Forms.GroupBox
            $ViewChartOptionsGroupBox.Location = New-Object System.Drawing.Size(($ViewChartXComboBox.Location.X + $ViewChartXComboBox.Size.Width + 5),$ViewChartXComboBox.Location.Y)
            $ViewChartOptionsGroupBox.size     = '100,105'
            $ViewChartOptionsGroupBox.text     = "Options:"

                ### View Chart Legend CheckBox
                $ViewChartLegendCheckBox          = New-Object System.Windows.Forms.Checkbox
                $ViewChartLegendCheckBox.Location = New-Object System.Drawing.Size(10,15)
                $ViewChartLegendCheckBox.Size     = '85,25'
                $ViewChartLegendCheckBox.Checked  = $false
                $ViewChartLegendCheckBox.Enabled  = $true
                $ViewChartLegendCheckBox.Text     = "Legend"
                $ViewChartLegendCheckBox.Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)

                ### View Chart 3D Chart CheckBox
                $ViewChart3DChartCheckBox          = New-Object System.Windows.Forms.Checkbox
                $ViewChart3DChartCheckBox.Location = New-Object System.Drawing.Size(10,38)
                $ViewChart3DChartCheckBox.Size     = '85,25'
                $ViewChart3DChartCheckBox.Checked  = $false
                $ViewChart3DChartCheckBox.Enabled  = $true
                $ViewChart3DChartCheckBox.Text     = "3D Chart"
                $ViewChart3DChartCheckBox.Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
                
                $ViewChartOptionsGroupBox.Controls.AddRange(@($ViewChartLegendCheckBox,$ViewChart3DChartCheckBox))
            $ViewChartSelectionForm.Controls.Add($ViewChartOptionsGroupBox) 

            #----------------------------------
            # Custom View Chart Execute Button
            #----------------------------------
            $ViewChartExecuteButton          = New-Object System.Windows.Forms.Button
            $ViewChartExecuteButton.Location = New-Object System.Drawing.Size(200,($ViewChartSortOrderGroupBox.Location.y + $ViewChartSortOrderGroupBox.Size.Height + 8))
            $ViewChartExecuteButton.Size     = New-Object System.Drawing.Size(100,23)
            $ViewChartExecuteButton.Text     = "Execute"
            $ViewChartExecuteButton.Add_Click({ ViewChartExecute })
            $ViewChartExecuteButton.Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)  
            $ViewChartSelectionForm.Controls.Add($ViewChartExecuteButton)   
                  
            #---------------------------------------------
            # Custom View Chart Execute Button Note Label
            #---------------------------------------------
            $ViewChartExecuteButtonNoteLabel          = New-Object System.Windows.Forms.Label
            $ViewChartExecuteButtonNoteLabel.Location = New-Object System.Drawing.Size(10,($ViewChartSortOrderGroupBox.Location.y + $ViewChartSortOrderGroupBox.Size.Height + 8)) 
            $ViewChartExecuteButtonNoteLabel.size     = New-Object System.Drawing.Size(190,25) 
            $ViewChartExecuteButtonNoteLabel.Text     = "Note: Press execute again if the desired chart did not appear."
            $ViewChartExecuteButtonNoteLabel.Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
            $ViewChartSelectionForm.Controls.Add($ViewChartExecuteButtonNoteLabel)

            [void] $ViewChartSelectionForm.ShowDialog()
        }
        $Property = $null
        $Property = ViewChartSelectProperty
    }
}) 
$BuildChartButton.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ Utilizes PowerShell (v3) charts to visualize data.
⦿ These charts are built manually from selecting a CSV file and fields.
⦿ Use caution, manually recreated charts can be built that either don't
    work, don't make sensse, or don't accurately represent data.`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage123))
        $ToolTip.Active         = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation   = $true
        $ToolTip.UseFading      = $true
        $ToolTip.IsBalloon      = $true
        $ToolTip.ToolTipIcon    = "Info"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle   = 'Build Chart'
    }
})
$Section2MainTab.Controls.Add($BuildChartButton)

#============================================================================================================================================================
#============================================================================================================================================================
# Auto Create Charts
#============================================================================================================================================================
#============================================================================================================================================================
# https://bytecookie.wordpress.com/2012/04/13/tutorial-powershell-and-microsoft-chart-controls-or-how-to-spice-up-your-reports/
# https://blogs.msdn.microsoft.com/alexgor/2009/03/27/aligning-multiple-series-with-categorical-values/

#======================================
# Auto Charts Select Property Function
#======================================
function AutoChartsSelectOptions {
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

    #----------------------------------
    # Auto Create Charts Selection Form
    #----------------------------------
    $AutoChartsSelectionForm = New-Object System.Windows.Forms.Form -Property @{
        width         = 327
        height        = 313 
        StartPosition = "CenterScreen"
        Text          = ”View Chart - Select Fields ”
        Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$ResourcesDirectory\favicon.ico")
        ControlBox    = $true
        Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    #------------------------------
    # Auto Create Charts Main Label
    #------------------------------
    $AutoChartsMainLabel          = New-Object System.Windows.Forms.Label -Property @{
        Location = New-Object System.Drawing.Point(10,10) 
        size     = New-Object System.Drawing.Size(290,25) 
        Text     = "This Will Auto Create Varios Charts From Past Collections."
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $AutoChartsSelectionForm.Controls.Add($AutoChartsMainLabel)

    #------------------------------------
    # Auto Create Charts Series GroupBox
    #------------------------------------
    # Create a group that will contain your radio buttons
    $AutoChartsSeriesGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
        Location = New-Object System.Drawing.Point(10,($AutoChartsMainLabel.Location.y + $AutoChartsMainLabel.Size.Height + 8))
        Size     = '185,90'
        Text     = "Select Collection Series to View:`n(if Available)"
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
        ### View Chart Baseline Checkbox
        $AutoChartsBaselineCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
            Location = New-Object System.Drawing.Point(10,15)
            Size     = '100,25'
            Checked  = $false
            Enabled  = $true
            Text     = "Baseline"
            Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        }
        ### View Chart Previous Checkbox
        $AutoChartsPreviousCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
            Location = New-Object System.Drawing.Point(10,38)
            Size     = '100,25'
            Checked  = $false
            Enabled  = $true
            Text     = "Previous"
            Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        }
        ### View Chart Most Recent Checkbox
        $AutoChartsMostRecentCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
            Location = New-Object System.Drawing.Point(10,61)
            Size     = '100,25'
            Checked  = $true
            Enabled  = $true
            Text     = "Most Recent"
            Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        }
        $AutoChartsSeriesGroupBox.Controls.AddRange(@($AutoChartsBaselineCheckBox,$AutoChartsPreviousCheckBox,$AutoChartsMostRecentCheckBox))
    $AutoChartsSelectionForm.Controls.Add($AutoChartsSeriesGroupBox) 

    #-----------------------------------------
    # Auto Create Using Results From GroupBox
    #-----------------------------------------
    # Create a group that will contain your radio buttons
    $AutoChartsCreateChartsFromGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
        Location = New-Object System.Drawing.Point(10,($AutoChartsSeriesGroupBox.Location.y + $AutoChartsSeriesGroupBox.Size.Height + 8))
        size     = '185,65'
        text     = "Filter Charts Using Results From:"
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
        ### View Chart WMI Results Checkbox
        $AutoChartsWmiCollectionsCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
            Location = New-Object System.Drawing.Point(10,15)
            Size     = '165,25'
            Checked  = $false
            Enabled  = $true
            Text     = "WMI Collections"
            Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        }        
        $AutoChartsWmiCollectionsCheckBox.Add_Click({ $AutoChartsPoShCollectionsCheckBox.Checked = $false })

        ### View Chart WinRM Results Checkbox
        $AutoChartsPoShCollectionsCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
            Location = New-Object System.Drawing.Point(10,38)
            Size     = '165,25'
            Checked  = $false
            Enabled  = $true
            Text     = "PoSh Collections"
            Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        }
        $AutoChartsPoShCollectionsCheckBox.Add_Click({ $AutoChartsWmiCollectionsCheckBox.Checked  = $false })
        
        $AutoChartsCreateChartsFromGroupBox.Controls.AddRange(@($AutoChartsWmiCollectionsCheckBox,$AutoChartsPoShCollectionsCheckBox))
    $AutoChartsSelectionForm.Controls.Add($AutoChartsCreateChartsFromGroupBox) 

    #------------------------------------
    # Auto Create Charts Options GroupBox
    #------------------------------------
    # Create a group that will contain your radio buttons
    $AutoChartsOptionsGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
        Location = New-Object System.Drawing.Point(($AutoChartsSeriesGroupBox.Location.X + $AutoChartsSeriesGroupBox.Size.Width + 5),($AutoChartsSeriesGroupBox.Location.Y))
        size     = '100,163'
        text     = "Options:"
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
        ### View Chart Legend CheckBox
        $AutoChartsLegendCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
            Location = New-Object System.Drawing.Point(10,15)
            Size     = '85,25'
            Checked  = $true
            Enabled  = $true
            Text     = "Legend"
            Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        }
        ### View Chart 3D Chart CheckBox
        $AutoCharts3DChartCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
            Location = New-Object System.Drawing.Point(10,38)
            Size     = '85,25'
            Checked  = $false
            Enabled  = $true
            Text     = "3D Chart"
            Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        }                
        $AutoChartsOptionsGroupBox.Controls.AddRange(@($AutoChartsLegendCheckBox,$AutoCharts3DChartCheckBox))
    $AutoChartsSelectionForm.Controls.Add($AutoChartsOptionsGroupBox) 

    #----------------------------------
    # Auto Chart Select Color ComboBox
    #----------------------------------
    $AutoChartColorSchemeSelectionComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location = New-Object System.Drawing.Point(10,($AutoChartsCreateChartsFromGroupBox.Location.y + $AutoChartsCreateChartsFromGroupBox.Size.Height + 10))
        Size     = New-Object System.Drawing.Size(185,25)
        Text     = "Select Alternate Color Scheme"
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
    }
    $ColorShcemesAvailable = @(
        'Blue, Orange, Red',
        'Light Blue, Orange, Red',
        'Black, Red, Green',  
        'Dark Red, Red, Orange',
        'Dark Blue, Blue, Light Blue',
        'Dark Green, Green, Light Green',
        'Dark Gray, Gray, Light Gray')
    ForEach ($Item in $ColorShcemesAvailable) {
        [void] $AutoChartColorSchemeSelectionComboBox.Items.Add($Item)
    }
    $AutoChartColorSchemeSelectionComboBox.Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
    $AutoChartsSelectionForm.Controls.Add($AutoChartColorSchemeSelectionComboBox) 

    #----------------------------------
    # Auto Chart Select Chart ComboBox
    #----------------------------------
    $AutoChartSelectChartComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location           = New-Object System.Drawing.Point(10,($AutoChartColorSchemeSelectionComboBox.Location.y + $AutoChartColorSchemeSelectionComboBox.Size.Height + 10))
        Size               = New-Object System.Drawing.Size(185,25)
        Text               = "Select A Chart"
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
    }
    $AutoChartSelectChartComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { AutoChartsViewCharts }})
    $AutoChartsAvailable = @(
        #"All Charts",
        "Logon Info",
        "Mapped Drives",
        "Network Settings",        
        "Processes",
        "Security Patches",
        "Services",
        "Shares",
        "Software Installed",
        "Startup Commands")
    ForEach ($Item in $AutoChartsAvailable) { [void] $AutoChartSelectChartComboBox.Items.Add($Item) }
    $AutoChartSelectChartComboBox.Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
    $AutoChartsSelectionForm.Controls.Add($AutoChartSelectChartComboBox) 

    #-----------------------------------
    # Auto Create Charts Execute Button
    #-----------------------------------
    $AutoChartsExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Location = New-Object System.Drawing.Point(200,($AutoChartColorSchemeSelectionComboBox.Location.y))
        Size     = New-Object System.Drawing.Size(101,54)
        Text     = "View Chart"
    }
    $AutoChartsExecuteButton.Add_Click({ AutoChartsViewCharts })

    function AutoChartsViewCharts {
        if (($AutoChartsBaselineCheckBox.Checked -eq $False) -and ($AutoChartsPreviousCheckBox.Checked -eq $False) -and ($AutoChartsMostRecentCheckBox.Checked -eq $False)) {
            $OhDarn=[System.Windows.Forms.MessageBox]::Show(`
                "You need to select at least one collection series:`nBaseline, Previous, or Most Recent",`
                "PoSh-ACME",`
                [System.Windows.Forms.MessageBoxButtons]::OK)
                switch ($OhDarn){
                "OK" {
                    #write-host "You pressed OK"
                }
            }        
        }
        elseif ($AutoChartSelectChartComboBox.SelectedItem -notin $AutoChartsAvailable) {
            $OhDarn=[System.Windows.Forms.MessageBox]::Show(`
                "You need to select a Chart!",`
                "PoSh-ACME",`
                [System.Windows.Forms.MessageBoxButtons]::OK)
                switch ($OhDarn){
                "OK" {
                    #write-host "You pressed OK"
                }
            }
        }
        else {
            #####################################################################################################################################
            #####################################################################################################################################
            ##
            ## Auto Create Charts Form 
            ##
            #####################################################################################################################################             
            #####################################################################################################################################

            $AnchorAll = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right -bor
                [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left
            $AutoChartsForm               = New-Object Windows.Forms.Form
            $AutoChartsForm.Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$ResourcesDirectory\favicon.ico")
            $AutoChartsForm.Width         = $PoShACME.Size.Width  #1160
            $AutoChartsForm.Height        = $PoShACME.Size.Height #638
            $AutoChartsForm.StartPosition = "CenterScreen"
            $AutoChartsForm.Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)

            #####################################################################################################################################
            ##
            ## Auto Create Charts TabControl
            ##
            #####################################################################################################################################

            # The TabControl controls the tabs within it
            $AutoChartsTabControl               = New-Object System.Windows.Forms.TabControl
            $AutoChartsTabControl.Name          = "Auto Charts"
            $AutoChartsTabControl.Text          = "Auto Charts"
            $AutoChartsTabControl.Location      = New-Object System.Drawing.Point(5,5)
            $AutoChartsTabControl.Size          = New-Object System.Drawing.Size(1135,590) 
            $AutoChartsTabControl.ShowToolTips  = $True
            $AutoChartsTabControl.SelectedIndex = 0
            $AutoChartsTabControl.Anchor        = $AnchorAll
            $AutoChartsTabControl.Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
            $AutoChartsForm.Controls.Add($AutoChartsTabControl)

            # These functions contains the commands to generate specific auto charts        
            function AutoChartsCommandLogonInfo {
                AutoChartsCommand -QueryName "Logon Info" -QueryTabName "Logged On Accounts" -PropertyX Name -PropertyY PSComputerName -ChartType1 'Column' -ChartType2_3 'Point' -MarkerStyle1 'None' -MarkerStyle2 'Square' -MarkerStyle3 'Diamond'
                #AutoChartsCommand -QueryName "Logon Info" -QueryTabName "Number of Accounts Logged In To Computers" -PropertyX PSComputerName -PropertyY Name -ChartType1 'Column' -ChartType2_3 'Point' -MarkerStyle1 'None' -MarkerStyle2 'Square' -MarkerStyle3 'Diamond'
            }
            function AutoChartsCommandMappedDrives {
                AutoChartsCommand -QueryName "Mapped Drives" -QueryTabName "Number of Mapped Drives per Server" -PropertyX PSComputerName -PropertyY ProviderName -ChartType1 'Column' -ChartType2_3 'Point' -MarkerStyle1 'None' -MarkerStyle2 'Square' -MarkerStyle3 'Diamond'
                AutoChartsCommand -QueryName "Mapped Drives" -QueryTabName "Number of Servers to Mapped Drives" -PropertyX ProviderName -PropertyY PSComputerName -ChartType1 'Column' -ChartType2_3 'Point' -MarkerStyle1 'None' -MarkerStyle2 'Square' -MarkerStyle3 'Diamond'
            }
            function AutoChartsCommandNetworkSettings {
                AutoChartsCommand -QueryName "Network Settings" -QueryTabName "Number of Interfaces with IPs" -PropertyX PSComputerName -PropertyY IPAddress -ChartType1 'Column' -ChartType2_3 'Point' -MarkerStyle1 'None' -MarkerStyle2 'Square' -MarkerStyle3 'Diamond'
                #AutoChartsCommand -QueryName "Network Settings" -QueryTabName "Number of Hosts with IPs"      -PropertyX IPAddress -PropertyY PSComputerName -ChartType1 'Column' -ChartType2_3 'Point' -MarkerStyle1 'None' -MarkerStyle2 'Square' -MarkerStyle3 'Diamond'            
            }
            function AutoChartsCommandProcessesStandard {
                AutoChartsCommand -QueryName "Processes" -QueryTabName "Process Names" -PropertyX Name -PropertyY PSComputerName -ChartType1 'Column' -ChartType2_3 'Point' -MarkerStyle1 'None' -MarkerStyle2 'Square' -MarkerStyle3 'Diamond'
                #AutoChartsCommand -QueryName "Processes" -QueryTabName "Process Paths" -PropertyX Path -PropertyY PSComputerName -ChartType1 'Bar'    -ChartType2_3 'Bar'   -MarkerStyle1 'None' -MarkerStyle2 'None'   -MarkerStyle3 'None'
            }
            function AutoChartsCommandSecurityPatches {
                AutoChartsCommand -QueryName "Security Patches" -QueryTabName "Number of Computers with Security Patches" -PropertyX Name -PropertyY PSComputerName     -ChartType1 'Column' -ChartType2_3 'Point' -MarkerStyle1 'None' -MarkerStyle2 'Square' -MarkerStyle3 'Diamond'
                #AutoChartsCommand -QueryName "Security Patches" -QueryTabName "Number of Security Patches per Computer"   -PropertyX PSComputerName -PropertyY HotFixID -ChartType1 'Column' -ChartType2_3 'Point' -MarkerStyle1 'None' -MarkerStyle2 'Square' -MarkerStyle3 'Diamond'
            }
            function AutoChartsCommandServices {
                AutoChartsCommand -QueryName "Services" -QueryTabName "Service Names" -PropertyX Name     -PropertyY PSComputerName -ChartType1 'Column' -ChartType2_3 'Point' -MarkerStyle1 'None' -MarkerStyle2 'Square' -MarkerStyle3 'Diamond'
                #AutoChartsCommand -QueryName "Services" -QueryTabName "Service Paths" -PropertyX PathName -PropertyY PSComputerName -ChartType1 'Bar'    -ChartType2_3 'Bar'   -MarkerStyle1 'None' -MarkerStyle2 'None'   -MarkerStyle3 'None'
            }
            function AutoChartsCommandShares {
                AutoChartsCommand -QueryName "Shares" -QueryTabName "Shares" -PropertyX Path -PropertyY PSComputerName -ChartType1 'Column' -ChartType2_3 'Point' -MarkerStyle1 'None' -MarkerStyle2 'Square' -MarkerStyle3 'Diamond'
                #AutoChartsCommand -QueryName "Shares" -QueryTabName "Shares" -PropertyX PSComputerName -PropertyY Path -ChartType1 'Bar'    -ChartType2_3 'Bar'   -MarkerStyle1 'None' -MarkerStyle2 'None'   -MarkerStyle3 'None'
            }
            function AutoChartsCommandSoftwareInstalled {
                AutoChartsCommand -QueryName "Software Installed" -QueryTabName "Software Installed" -PropertyX Name -PropertyY PSComputerName -ChartType1 'Column' -ChartType2_3 'Point' -MarkerStyle1 'None' -MarkerStyle2 'Square' -MarkerStyle3 'Diamond'
                #AutoChartsCommand -QueryName "Software Installed" -QueryTabName "Number of Software Installed on Computers" -PropertyX PSComputerName -PropertyY Name -ChartType1 'Column' -ChartType2_3 'Point' -MarkerStyle1 'None' -MarkerStyle2 'Square' -MarkerStyle3 'Diamond'
            }
            function AutoChartsCommandStartUpCommands {
                AutoChartsCommand -QueryName "Startup Commands" -QueryTabName "Startup Names"    -PropertyX Name    -PropertyY PSComputerName -ChartType1 'Column' -ChartType2_3 'Point' -MarkerStyle1 'None' -MarkerStyle2 'Square' -MarkerStyle3 'Diamond'
                #AutoChartsCommand -QueryName "Startup Commands" -QueryTabName "Startup Commands" -PropertyX Command -PropertyY PSComputerName -ChartType1 'Bar'    -ChartType2_3 'Bar'   -MarkerStyle1 'None' -MarkerStyle2 'None'   -MarkerStyle3 'None'
            }

            # Calls the functions for the respective commands to generate charts
            if ($AutoChartSelectChartComboBox.SelectedItem -match "All Charts") {
                AutoChartsCommandLogonInfo
                AutoChartsCommandMappedDrives
                AutoChartsCommandNetworkSettings
                AutoChartsCommandProcessesStandard
                AutoChartsCommandSecurityPatches
                AutoChartsCommandServices
                AutoChartsCommandShares
                AutoChartsCommandSoftwareInstalled
                AutoChartsCommandStartUpCommands
            }
            elseif ($AutoChartSelectChartComboBox.SelectedItem -match "Logon Info")         { AutoChartsCommandLogonInfo }
            elseif ($AutoChartSelectChartComboBox.SelectedItem -match "Mapped Drives")      { AutoChartsCommandMappedDrives }
            elseif ($AutoChartSelectChartComboBox.SelectedItem -match "Network Settings")   { AutoChartsCommandNetworkSettings }
            elseif ($AutoChartSelectChartComboBox.SelectedItem -match "Processes")          { AutoChartsCommandProcessesStandard }
            elseif ($AutoChartSelectChartComboBox.SelectedItem -match "Security Patches")   { AutoChartsCommandSecurityPatches }
            elseif ($AutoChartSelectChartComboBox.SelectedItem -match "Services")           { AutoChartsCommandServices }
            elseif ($AutoChartSelectChartComboBox.SelectedItem -match "Shares")             { AutoChartsCommandShares }
            elseif ($AutoChartSelectChartComboBox.SelectedItem -match "Software Installed") { AutoChartsCommandSoftwareInstalled }
            elseif ($AutoChartSelectChartComboBox.SelectedItem -match "Startup Commands")   { AutoChartsCommandStartUpCommands }
        }
    }
    
    $AutoChartsSelectionForm.Controls.Add($AutoChartsExecuteButton)   
    [void] $AutoChartsSelectionForm.ShowDialog()
}

#=====================================
# Auto Create Charts Command Function
#=====================================
function AutoChartsCommand {
    param (
        $QueryName,
        $QueryTabName,
        $PropertyX,
        $PropertyY,
        $ChartType1,
        $ChartType2_3,
        $MarkerStyle1,
        $MarkerStyle2,
        $MarkerStyle3
    )
    # Name of Collected Data Directory
    $CollectedDataDirectory               = "$PoShHome\Collected Data"
    # Location of separate queries
    $CollectedDataTimeStampDirectory      = "$CollectedDataDirectory\$((Get-Date).ToString('yyyy-MM-dd @ HHmm ss'))"
    # Location of Uncompiled Results
    $IndividualHostResults                = "$CollectedDataTimeStampDirectory\Individual Host Results"

    # Filter results for just WMI Collections
    if ( $AutoChartsWmiCollectionsCheckBox.Checked ) { 
        # Searches though the all Collection Data Directories to find files that match the $QueryName
        $ListOfCollectedDataDirectories = (Get-ChildItem -Path $CollectedDataDirectory).FullName
        $CSVFileMatch = @()
        foreach ($CollectionDir in $ListOfCollectedDataDirectories) {
            $CSVFiles = (Get-ChildItem -Path $CollectionDir).FullName | Where {$_ -match 'WMI'} 
            foreach ($CSVFile in $CSVFiles) {
                if ($CSVFile -match $QueryName) {
                    $CSVFileMatch += $CSVFile
                }
            }
        }
    }
    # Filter results for other than WMI Collections    
    elseif ( $AutoChartsPoShCollectionsCheckBox.Checked ) { 
        # Searches though the all Collection Data Directories to find files that match the $QueryName
        $ListOfCollectedDataDirectories = (Get-ChildItem -Path $CollectedDataDirectory).FullName
        $CSVFileMatch = @()
        foreach ($CollectionDir in $ListOfCollectedDataDirectories) {
            $CSVFiles = (Get-ChildItem -Path $CollectionDir).FullName | Where {$_ -notmatch 'WMI'} 
            foreach ($CSVFile in $CSVFiles) {
                if ($CSVFile -match $QueryName) {
                    $CSVFileMatch += $CSVFile
                }
            }
        }
    }
    # Don't filter results
    else {
        # Searches though the all Collection Data Directories to find files that match the $QueryName
        $ListOfCollectedDataDirectories = (Get-ChildItem -Path $CollectedDataDirectory).FullName
        $CSVFileMatch = @()
        foreach ($CollectionDir in $ListOfCollectedDataDirectories) {
            $CSVFiles = (Get-ChildItem -Path $CollectionDir).FullName
            foreach ($CSVFile in $CSVFiles) {
                if ($CSVFile -match $QueryName) {
                    $CSVFileMatch += $CSVFile
                }
            }
        }
    }

    # Checkes if the Appropriate Checkbox is selected, if so it selects the very first, previous, and most recent collections respectively
    # Each below will be the filename/path for their respective collection: baseline, previous, and most recent
    if ($AutoChartsBaselineCheckBox.Checked -eq $true) {
        $script:CSVFileBaselineCollection = $CSVFileMatch | Select-Object -First 1
    }
    if ($AutoChartsPreviousCheckBox.Checked -eq $true) { 
        $script:CSVFilePreviousCollection = $CSVFileMatch | Select-Object -Last 2 | Select-Object -First 1 
    }
    if ($AutoChartsMostRecentCheckBox.Checked -eq $true) { 
        $script:CSVFileMostRecentCollection = $CSVFileMatch | Select-Object -Last 1 
    }

    # Checks if the files selected are identicle, removing series as necessary that are to prevent erroneous double data
    if (($script:CSVFileMostRecentCollection -eq $script:CSVFilePreviousCollection) -and ($script:CSVFileMostRecentCollection -eq $script:CSVFileBaselineCollection)) {
        $script:CSVFilePreviousCollection = $null
        $script:CSVFileBaselineCollection = $null
    }
    else {
        if (($script:CSVFileMostRecentCollection -ne $script:CSVFilePreviousCollection) -and ($script:CSVFilePreviousCollection -eq $script:CSVFileBaselineCollection)) {
            $script:CSVFilePreviousCollection = $null        
        }    
    }
    
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Windows.Forms.DataVisualization

    #--------------------------
    # Auto Create Charts Object
    #--------------------------
    $AutoChart                = New-object System.Windows.Forms.DataVisualization.Charting.Chart
    $AutoChart.Width           = 1115
    $AutoChart.Height          = 552
    $AutoChart.Left            = 5
    $AutoChart.Top             = 7
    $AutoChart.BackColor       = [System.Drawing.Color]::White
    $AutoChart.BorderColor     = 'Black'
    $AutoChart.BorderDashStyle = 'Solid'
    #$AutoChart.DataManipulator.Sort() = "Descending"
    $AutoChart.Font            = New-Object System.Drawing.Font @('Microsoft Sans Serif','18', [System.Drawing.FontStyle]::Bold)
    $AutoChart.Anchor          = $AnchorAll
    
    #--------------------------
    # Auto Create Charts Title 
    #--------------------------
    $AutoChartTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title
    $AutoChartTitle.ForeColor = "black"
    if ($AutoChartsMostRecentCheckBox.Checked -eq $true) {
        $AutoChartTitle.Text = ($script:CSVFileMostRecentCollection.split('\'))[-1] -replace '.csv',''
    }
    elseif ($AutoChartsPreviousCheckBox.Checked -eq $true) {
        $AutoChartTitle.Text = ($script:CSVFilePreviousCollection.split('\'))[-1] -replace '.csv',''
    }
    elseif ($AutoChartsBaselineCheckBox.Checked -eq $true) {
        $AutoChartTitle.Text = ($CSVFileMostBaselineCollection.split('\'))[-1] -replace '.csv',''
    }
    else {       
        $AutoChartTitle.Text = "`Missing Data!`n1). Run The Appropriate Query`n2). Ensure To Select At Least One Series"
        $AutoChartTitle.ForeColor = "Red"
    }
    if (-not $script:CSVFileBaselineCollection -and -not $script:CSVFilePreviousCollection -and -not $script:CSVFileMostRecentCollection) {
        $AutoChartTitle.Text = "`Missing Data!`n1). Run The Appropriate Query`n2). Ensure To Select At Least One Series"
        $AutoChartTitle.ForeColor = "Red"
    }
    $AutoChartTitle.Font      = New-Object System.Drawing.Font @('Microsoft Sans Serif','18', [System.Drawing.FontStyle]::Bold)
    $AutoChartTitle.Alignment = "topcenter" #"topLeft"
    $AutoChart.Titles.Add($AutoChartTitle)

    #-------------------------
    # Auto Create Charts Area
    #-------------------------
    $AutoChartArea                        = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
    $AutoChartArea.Name                   = "Chart Area"
    $AutoChartArea.AxisX.Title            = $PropertyX
    if ($PropertyY -eq "PSComputername") {$AutoChartArea.AxisY.Title = "Number of Computers"}
    else {
        if ($PropertyY -eq 'Name') {
            $AutoChartArea.AxisY.Title    = "Number of $QueryName"
        }
        else {$AutoChartArea.AxisY.Title  = "Number of $PropertyY"}
    }
    #else {$AutoChartArea.AxisY.Title      = $PropertyY}
    $AutoChartArea.AxisX.Interval         = 1
    #$AutoChartArea.AxisY.Interval        = 1
    $AutoChartArea.AxisY.IntervalAutoMode = $true

    # Option to enable 3D Charts
    if ($AutoCharts3DChartCheckBox.Checked) {
        $AutoChartArea.Area3DStyle.Enable3D=$True
        $AutoChartArea.Area3DStyle.Inclination = 75
    }
    $AutoChart.ChartAreas.Add($AutoChartArea)

    #--------------------------
    # Auto Create Charts Legend 
    #--------------------------
    $Legend                      = New-Object system.Windows.Forms.DataVisualization.Charting.Legend
    $Legend.Enabled              = $AutoChartsLegendCheckBox.Checked
    $Legend.Name                 = "Legend"
    $Legend.Title                = "Legend"
    $Legend.TitleAlignment       = "topleft"
    $Legend.TitleFont            = New-Object System.Drawing.Font @('Microsoft Sans Serif','11', [System.Drawing.FontStyle]::Bold)
    $Legend.IsEquallySpacedItems = $True
    $Legend.BorderColor          = 'Black'
    $AutoChart.Legends.Add($Legend)

    #-----------------------------------------
    # Auto Create Charts Data Series Baseline
    #-----------------------------------------
    $Series01Name = "Baseline"
    $AutoChart.Series.Add("$Series01Name")
    $AutoChart.Series["$Series01Name"].Enabled           = $True
    $AutoChart.Series["$Series01Name"].ChartType         = $ChartType1
    $AutoChart.Series["$Series01Name"].BorderWidth       = 1
    $AutoChart.Series["$Series01Name"].IsVisibleInLegend = $true
    $AutoChart.Series["$Series01Name"].Chartarea         = "Chart Area"
    $AutoChart.Series["$Series01Name"].Legend            = "Legend"
    $AutoChart.Series["$Series01Name"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
    # Pie Charts - Moves text off pie
    $AutoChart.Series["$Series01Name"]['PieLineColor']   = 'Black'
    $AutoChart.Series["$Series01Name"]['PieLabelStyle']  = 'Outside'

    #-----------------------------------------
    # Auto Create Charts Data Series Previous
    #-----------------------------------------
    $Series02Name = 'Previous'
    $AutoChart.Series.Add("$Series02Name")
    $AutoChart.Series["$Series02Name"].Enabled           = $True
    $AutoChart.Series["$Series02Name"].BorderWidth       = 1
    $AutoChart.Series["$Series02Name"].IsVisibleInLegend = $true
    $AutoChart.Series["$Series02Name"].Chartarea         = "Chart Area"
    $AutoChart.Series["$Series02Name"].Legend            = "Legend"
    $AutoChart.Series["$Series02Name"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
    # Pie Charts - Moves text off pie
    #if (-not ($script:CSVFileMostRecentCollection -eq $script:CSVFilePreviousCollection) -or -not ($script:CSVFileMostRecentCollection -eq $script:CSVFileBaselineCollection)) {
    #    $AutoChart.Series["$Series03Name"].ChartType         = $ChartType1
    #    $AutoChart.Series["$Series03Name"].MarkerColor       = 'Blue'
    #}
    $AutoChart.Series["$Series02Name"]['PieLineColor']   = 'Black'
    $AutoChart.Series["$Series02Name"]['PieLabelStyle']  = 'Outside'
           
    #---------------------------------------
    # Auto Create Charts Data Series Recent
    #---------------------------------------
    $Series03Name = 'Most Recent'
    $AutoChart.Series.Add("$Series03Name")  
    $AutoChart.Series["$Series03Name"].Enabled           = $True
    $AutoChart.Series["$Series03Name"].BorderWidth       = 1
    $AutoChart.Series["$Series03Name"].IsVisibleInLegend = $true
    $AutoChart.Series["$Series03Name"].Chartarea         = "Chart Area"
    $AutoChart.Series["$Series03Name"].Legend            = "Legend"
    $AutoChart.Series["$Series03Name"].Font              = New-Object System.Drawing.Font @('Microsoft Sans Serif','9', [System.Drawing.FontStyle]::Normal)
    # Pie Charts - Moves text off pie
    $AutoChart.Series["$Series03Name"]['PieLineColor']   = 'Black'
    $AutoChart.Series["$Series03Name"]['PieLabelStyle']  = 'Outside'

    #-------------------------------------------------------
    # Auto Create Charts - Chart Type and Series Management
    #-------------------------------------------------------
    # Empties out variable that contains csv data if the respective checkbox is not checked
    if ($AutoChartsBaselineCheckBox.Checked   -eq $False) { $script:CSVFileBaselineCollection   = $null }
    if ($AutoChartsPreviousCheckBox.Checked   -eq $False) { $script:CSVFilePreviousCollection   = $null }
    if ($AutoChartsMostRecentCheckBox.Checked -eq $False) { $script:CSVFileMostRecentCollection = $null }

    # Controls which series is showing and what chart types will be displayed
    if ($script:CSVFileBaselineCollection -and $script:CSVFilePreviousCollection -and $script:CSVFileMostRecentCollection) {
        $AutoChart.Series["$Series01Name"].ChartType     = $ChartType1
        $AutoChart.Series["$Series01Name"].Color         = 'Blue'
        $AutoChart.Series["$Series02Name"].ChartType     = $ChartType2_3
        $AutoChart.Series["$Series02Name"].MarkerColor   = 'Orange'  
        $AutoChart.Series["$Series02Name"].MarkerStyle   = $MarkerStyle2
        $AutoChart.Series["$Series02Name"].MarkerSize    = '10'            
        $AutoChart.Series["$Series03Name"].ChartType     = $ChartType2_3
        $AutoChart.Series["$Series03Name"].MarkerColor   = 'Red'  
        $AutoChart.Series["$Series03Name"].MarkerStyle   = $MarkerStyle3
        $AutoChart.Series["$Series03Name"].MarkerSize    = '10'        
        $AutoChart.Series["$Series01Name"].Enabled       = $True
        $AutoChart.Series["$Series02Name"].Enabled       = $True
        $AutoChart.Series["$Series03Name"].Enabled       = $True
    }
    elseif ($script:CSVFileBaselineCollection -and -not $script:CSVFilePreviousCollection -and -not $script:CSVFileMostRecentCollection) {
        $AutoChart.Series["$Series01Name"].ChartType     = $ChartType1
        $AutoChart.Series["$Series01Name"].Color         = 'Blue'
        $AutoChart.Series["$Series01Name"].Enabled       = $True
        $AutoChart.Series["$Series02Name"].Enabled       = $False
        $AutoChart.Series["$Series03Name"].Enabled       = $False
    }
    elseif (($script:CSVFileBaselineCollection) -and ($script:CSVFilePreviousCollection) -and -not ($script:CSVFileMostRecentCollection)) {
        $AutoChart.Series["$Series01Name"].ChartType     = $ChartType1
        $AutoChart.Series["$Series01Name"].Color         = 'Blue'
        $AutoChart.Series["$Series01Name"].MarkerColor   = 'Blue'              
        $AutoChart.Series["$Series02Name"].ChartType     = $ChartType2_3
        $AutoChart.Series["$Series02Name"].MarkerColor   = 'Orange'  
        $AutoChart.Series["$Series02Name"].MarkerStyle   = $MarkerStyle2
        $AutoChart.Series["$Series02Name"].MarkerSize    = '10'  
        $AutoChart.Series["$Series03Name"].Enabled       = $False
    }
    elseif (($script:CSVFileBaselineCollection) -and -not ($script:CSVFilePreviousCollection) -and ($script:CSVFileMostRecentCollection)) {
        $AutoChart.Series["$Series01Name"].ChartType     = $ChartType1
        $AutoChart.Series["$Series01Name"].Color         = 'Blue'         
        $AutoChart.Series["$Series03Name"].ChartType     = $ChartType2_3
        $AutoChart.Series["$Series03Name"].MarkerColor   = 'Red'  
        $AutoChart.Series["$Series03Name"].MarkerStyle   = $MarkerStyle3
        $AutoChart.Series["$Series03Name"].MarkerSize    = '10'  
        $AutoChart.Series["$Series02Name"].Enabled       = $False
    }
    elseif (($script:CSVFilePreviousCollection) -and -not ($script:CSVFileBaselineCollection) -and -not ($script:CSVFileMostRecentCollection)) {
        $AutoChart.Series["$Series02Name"].ChartType     = $ChartType1
        $AutoChart.Series["$Series02Name"].Color         = 'Orange'
        $AutoChart.Series["$Series01Name"].Enabled       = $False
        $AutoChart.Series["$Series03Name"].Enabled       = $False
    }
    elseif (($script:CSVFilePreviousCollection) -and -not ($script:CSVFileBaselineCollection) -and ($script:CSVFileMostRecentCollection)) {
        $AutoChart.Series["$Series02Name"].ChartType     = $ChartType1
        $AutoChart.Series["$Series02Name"].Color         = 'Orange'
        $AutoChart.Series["$Series03Name"].ChartType     = $ChartType2_3
        $AutoChart.Series["$Series03Name"].MarkerColor   = 'Red'  
        $AutoChart.Series["$Series03Name"].MarkerStyle   = $MarkerStyle3
        $AutoChart.Series["$Series03Name"].MarkerSize    = '10'                     
        $AutoChart.Series["$Series01Name"].Enabled       = $False
    }
    elseif (($script:CSVFileMostRecentCollection) -and -not ($script:CSVFilePreviousCollection) -and -not ($script:CSVFileBaselineCollection)) {
        $AutoChart.Series["$Series03Name"].ChartType     = $ChartType1
        $AutoChart.Series["$Series03Name"].Color         = 'Red'
        $AutoChart.Series["$Series01Name"].Enabled       = $False
        $AutoChart.Series["$Series02Name"].Enabled       = $False
    }

    #---------------------------------------------
    # Auto Create Charts - Alternate Color Scheme
    #---------------------------------------------
    if ($AutoChartColorSchemeSelectionComboBox -ne 'Select Alternate Color Scheme') {
        $AutoChart.Series["$Series01Name"].Color       = ($AutoChartColorSchemeSelectionComboBox.SelectedItem -replace ' ','' -split ',')[0]
        $AutoChart.Series["$Series01Name"].MarkerColor = ($AutoChartColorSchemeSelectionComboBox.SelectedItem -replace ' ','' -split ',')[0]
        $AutoChart.Series["$Series02Name"].Color       = ($AutoChartColorSchemeSelectionComboBox.SelectedItem -replace ' ','' -split ',')[1]
        $AutoChart.Series["$Series02Name"].MarkerColor = ($AutoChartColorSchemeSelectionComboBox.SelectedItem -replace ' ','' -split ',')[1]
        $AutoChart.Series["$Series03Name"].Color       = ($AutoChartColorSchemeSelectionComboBox.SelectedItem -replace ' ','' -split ',')[2]
        $AutoChart.Series["$Series03Name"].MarkerColor = ($AutoChartColorSchemeSelectionComboBox.SelectedItem -replace ' ','' -split ',')[2]
    }

    #------------------------------------------------------------
    # Auto Create Charts - Code that counts computers that match
    #------------------------------------------------------------
    function Merge-CSVFiles { 
        [cmdletbinding()] 
        param( 
            [string]$CSVFileBaseline,
            [string]$CSVFilePrevious,
            [string]$CSVFileMostRecent
        ) 
        $script:CsvAllHosts = @()

        # Checks if the files exists, then stores the complete csv in a variable
        if ((Test-Path $CSVFileBaseline) -and $AutoChartsBaselineCheckBox.Checked) {
            $CsvFile1Data         = Import-CSV -Path $CSVFileBaseline | Select-Object *, @{Expression={$([System.IO.Path]::GetFileName($CSVFileBaseline))};Label="FileName"}
            $CsvFile1Hosts        = $CsvFile1Data | Select-Object -ExpandProperty PSComputerName -Unique
            $script:CsvAllHosts  += $CsvFile1Hosts
        }
        if ((Test-Path $CSVFilePrevious) -and $AutoChartsPreviousCheckBox.Checked) {
            $CsvFile2Data         = Import-CSV -Path $CSVFilePrevious | Select-Object *, @{Expression={$([System.IO.Path]::GetFileName($CSVFilePrevious))};Label="FileName"}
            $CsvFile2Hosts        = $CsvFile2Data | Select-Object -ExpandProperty PSComputerName -Unique
            $script:CsvAllHosts  += $CsvFile2Hosts
        }
        if ((Test-Path $CSVFileMostRecent) -and $AutoChartsMostRecentCheckBox.Checked) {
            $CsvFile3Data         = Import-CSV -Path $CSVFileMostRecent | Select-Object *, @{Expression={$([System.IO.Path]::GetFileName($CSVFileMostRecent))};Label="FileName"}
            $CsvFile3Hosts        = $CsvFile3Data | Select-Object -ExpandProperty PSComputerName -Unique
            $script:CsvAllHosts  += $CsvFile3Hosts
        }

        # Gets unique listing of all hosts (PSComputerName), this will be used to compare each csv file against
        $script:CsvUniqueHosts  = @()
        $script:CsvUniqueHosts += $script:CsvAllHosts | Sort-Object -Unique

        # Checks to see if hosts in the overall unique list exist in each csv
        # If one is found that doesn't exist in the csv file, it is removed from the overall list
        # This is to ensure that the results when compared between baseline, previous and most recent match the same computers
        foreach ($UniqueHost in $script:CsvUniqueHosts) { 
            if ((Test-Path $CSVFileBaseline) -and $AutoChartsBaselineCheckBox.Checked) {
                if ($CsvFile1Hosts -notcontains $UniqueHost) { $script:CsvUniqueHosts = $script:CsvUniqueHosts | Where-Object {$_ -ne $UniqueHost} }
            }
            if ((Test-Path $CSVFilePrevious) -and $AutoChartsPreviousCheckBox.Checked) {
                if ($CsvFile2Hosts -notcontains $UniqueHost) { $script:CsvUniqueHosts = $script:CsvUniqueHosts | Where-Object {$_ -ne $UniqueHost} }
            }
            if ((Test-Path $CSVFileMostRecent) -and $AutoChartsMostRecentCheckBox.Checked) {
                if ($CsvFile3Hosts -notcontains $UniqueHost) { $script:CsvUniqueHosts = $script:CsvUniqueHosts | Where-Object {$_ -ne $UniqueHost} }
            }
        }

        # Compiles the data for only similar hosts
        $Script:MergedCSVUniquePropertyDataResults = @()
        if ((Test-Path $CSVFileBaseline) -and $AutoChartsBaselineCheckBox.Checked) {
            foreach ($UniqueHost in $script:CsvUniqueHosts) { $Script:MergedCSVUniquePropertyDataResults += $CsvFile1Data | Where { $_.PSComputerName -eq $UniqueHost } }
        }
        if ((Test-Path $CSVFilePrevious) -and $AutoChartsPreviousCheckBox.Checked) {
            foreach ($UniqueHost in $script:CsvUniqueHosts) { $Script:MergedCSVUniquePropertyDataResults += $CsvFile2Data | Where { $_.PSComputerName -eq $UniqueHost } }
        }
        if ((Test-Path $CSVFileMostRecent) -and $AutoChartsMostRecentCheckBox.Checked) {
            foreach ($UniqueHost in $script:CsvUniqueHosts) { $Script:MergedCSVUniquePropertyDataResults += $CsvFile3Data | Where { $_.PSComputerName -eq $UniqueHost } }
        }
    }
    # Later used to iterate through
    $CsvFileList = @($script:CSVFileBaselineCollection,$script:CSVFilePreviousCollection,$script:CSVFileMostRecentCollection)
    $SeriesCount = 0

    # If the Second field/Y Axis equals PSComputername, it counts it
    if ($PropertyY -eq "PSComputerName") {
        #$Script:AutoChartsChoice0 = "Name"
        #$Script:AutoChartsChoice1 = "PSComputerName"

        # This file merger is later used to get a unique count of PropertyX and add to the DataSource (later the count is then subtracted by 1), 
        # this allow each collection to have a minimum of zero count of a process. This aligns all results, otherwise unique results will be shifted 
        # off from one another when alphabetized
        Merge-CSVFiles -CSVFileBaseline $script:CSVFileBaselineCollection `
                       -CSVFilePrevious $script:CSVFilePreviousCollection `
                       -CSVFileMostRecent $script:CSVFileMostRecentCollection
        
        # The purpose of the code below is to ultiately add any missing unique fields to each collection.
        # ex: If the most recent scan/collection contained an item not in the baseline, the baseline will now contain that item but at a zero value
        # This is needed to ensure columns align when viewing multiple scans at once
        foreach ($CSVFile in $CsvFileList) {
            $SeriesCount += 1
            $DataSource = @()

            # Filtering Results for Services to show just running services
            if ($CSVFile -match "Services") {
                foreach ($UniqueHost in $script:CsvUniqueHosts) { 
                    $DataSource += Import-Csv $CSVFile | Where { $_.PSComputerName -eq $UniqueHost } | Where-Object {$_.State -eq "Running" } 
                }
                # Gets a unique list of each item across all hosts
                $DataSource += $Script:MergedCSVUniquePropertyDataResults  | Where-Object {$_.State -eq "Running"} | Select-Object -Property $PropertyX -Unique
                $AutoChartTitle.Text = (($script:CSVFileMostRecentCollection.split('\'))[-1] -replace '.csv','') + " - Running"
            }

            # Combines the file data along with the unique field list
            # This essentially ends up adding a +1 count to all exist fiends, but will be later subtracted later
            else {
                $ImportCsvFile = Import-Csv $CSVFile
                foreach ($UniqueHost in $script:CsvUniqueHosts) { 
                    $DataSource += $ImportCsvFile | Where { $_.PSComputerName -eq $UniqueHost } 
                }
                # Gets a unique list of each item and appends it to ensure each collection has the same number of fields
                $DataSource += $Script:MergedCSVUniquePropertyDataResults | Select-Object -Property $PropertyX -Unique
            }

            # Important, gets a unique list for X and Y
            $UniqueDataFields   = $DataSource | Select-Object -Property $PropertyX | Sort-Object -Property $PropertyX -Unique
            $UniqueComputerList = $DataSource | Select-Object -Property $PropertyY | Sort-Object -Property $PropertyY -Unique
            
            # Generates and Counts the data
            # Counts the number of times that any given property possess a given value
            $OverallDataResults = @()
            foreach ($DataField in $UniqueDataFields) {
                $Count          = 0
                $CsvComputers   = @()
                foreach ( $Line in $DataSource ) {
                    if ($($Line.$PropertyX) -eq $DataField.$PropertyX) {
                        $Count += 1
                        if ( $CsvComputers -notcontains $($Line.$PropertyY) ) { $CsvComputers += $($Line.$PropertyY) }                        
                    }
                }
                ### The - 1 is subtracted to account for the one added when adding $Script:MergedCSVUniquePropertyDataResults 
                $UniqueCount    = $CsvComputers.Count - 1 
                $DataResults    = New-Object PSObject -Property @{
                    DataField   = $DataField
                    TotalCount  = $Count
                    UniqueCount = $UniqueCount
                    Computers   = $CsvComputers 
                }
                $OverallDataResults += $DataResults
            }
            $Series = '$Series0' + $SeriesCount + 'Name'
            $OverallDataResults | ForEach-Object {$AutoChart.Series["$(iex $Series)"].Points.AddXY($_.DataField.$PropertyX,$_.UniqueCount)}
        }        
    }

    # If the Second field/Y Axis DOES NOT equals PSComputername, it uses the field provided
    elseif ($PropertyX -eq "PSComputerName") {   
        # Import Data
        $DataSource = ""
        foreach ($CSVFile in $CsvFileList) {
            $SeriesCount += 1
            $DataSource = Import-Csv $CSVFile
########## TEST DATA ##########
#            $DataSource = @()
#            $DataSource += Import-Csv "C:\Users\Dan\Documents\GitHub\PoSH-ACME\PoSh-ACME_v2.3_20181106_Beta_Nightly_Build\Collected Data\2018-11-19 @ 2101 42\Network Settings.csv"
#            $PropertyX = "PSComputerName"
#            $PropertyY = "IPAddress"
########## TEST DATA ##########

            $SelectedDataField  = $DataSource | Select-Object -Property $PropertyY | Sort-Object -Property $PropertyY -Unique
            $UniqueComputerList = $DataSource | Select-Object -Property $PropertyX | Sort-Object -Property $PropertyX -Unique
            $OverallResults     = @()
            $CurrentComputer    = ''
            $CheckIfFirstLine   = 'False'
            $ResultsCount       = 0
            $Computer           = ''
            $YResults           = @()
            $OverallDataResults = @()
            foreach ( $Line in $DataSource ) {
                if ( $CheckIfFirstLine -eq 'False' ) { 
                    $CurrentComputer  = $Line.$PropertyX
                    $CheckIfFirstLine = 'True' 
                }
                if ( $CheckIfFirstLine -eq 'True' ) { 
                    if ( $Line.$PropertyX -eq $CurrentComputer ) {
                        if ( $YResults -notcontains $Line.$PropertyY ) {
                            if ( $Line.$PropertyY -ne "" ) {
                                $YResults     += $Line.$PropertyY
                                $ResultsCount += 1
                            }
                            if ( $Computer -notcontains $Line.$PropertyX ) { $Computer = $Line.$PropertyX }
                        }       
                    }
                    elseif ( $Line.$PropertyX -ne $CurrentComputer ) { 
                        $CurrentComputer = $Line.$PropertyX
                        $DataResults     = New-Object PSObject -Property @{
                            ResultsCount = $ResultsCount
                            Computer     = $Computer
                        }
                        $OverallDataResults += $DataResults
                        $YResults        = @()
                        $ResultsCount    = 0
                        $Computer        = @()
                        if ( $YResults -notcontains $Line.$PropertyY ) {
                            if ( $Line.$PropertyY -ne "" ) {
                                $YResults     += $Line.$PropertyY
                                $ResultsCount += 1
                            }
                            if ( $Computer -notcontains $Line.$PropertyX ) { $Computer = $Line.$PropertyX }
                        }
                    }
                }
            }
            $DataResults     = New-Object PSObject -Property @{
                ResultsCount = $ResultsCount
                Computer     = $Computer
            }    
            $OverallDataResults += $DataResults
            #$OverallDataResults
        $Series = '$Series0' + $SeriesCount + 'Name'        
        $OverallDataResults `
        | ForEach-Object {$AutoChart.Series["$(iex $Series)"].Points.AddXY($_.Computer,$_.ResultsCount)}        
        }
    }
    Clear-Variable -Name MergedCSVDataResults

    ############################################################################################################
    # Auto Create Charts Processes
    ############################################################################################################

    #------------------------------------
    # Auto Creates Tabs and Imports Data
    #------------------------------------
    # Obtains a list of the files in the resources folder
    ###$ResourceFiles = Get-ChildItem "$PoShHome\Resources\Process Info"

    #-----------------------------
    # Creates Tabs From Each File
    #-----------------------------
    $TabName                          = $QueryTabName
    $AutoChartsIndividualTabs         = New-Object System.Windows.Forms.TabPage
    $AutoChartsIndividualTabs.Text    = "$TabName"
    $AutoChartsIndividualTabs.UseVisualStyleBackColor = $True
    $AutoChartsIndividualTabs.Anchor  = $AnchorAll
    $AutoChartsIndividualTabs.Font    = New-Object System.Drawing.Font("$Font",11,0,0,0)
    $AutoChartsTabControl.Controls.Add($AutoChartsIndividualTabs)            
    $AutoChartsIndividualTabs.controls.add($AutoChart)

    #------------------------------
    # Auto Charts - Notice Textbox
    #------------------------------
    $AutoChartsNoticeTextbox             = New-Object System.Windows.Forms.Textbox
    $AutoChartsNoticeTextbox.Location    = New-Object System.Drawing.Point(964,216)
    $AutoChartsNoticeTextbox.Size        = New-Object System.Drawing.Size(126,60)
    $AutoChartsNoticeTextbox.Anchor      = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    $AutoChartsNoticeTextbox.Font        = New-Object System.Drawing.Font("Courier New",11,0,0,0)
    $AutoChartsNoticeTextbox.ForeColor   = 'Black'
    $AutoChartsNoticeTextbox.Text        = "Computers
 - Total:     $(($script:CsvAllHosts | Sort-Object -Unique).Count)
 - Displayed: $($CsvComputers.Count -1)
 - Hidden:    $((($script:CsvAllHosts | Sort-Object -Unique).Count) - $($CsvComputers.Count -1))"
    $AutoChartsNoticeTextbox.Multiline   = $true
    $AutoChartsNoticeTextbox.BorderStyle = 'FixedSingle' #None, FixedSingle, Fixed3D
    $AutoChart.Controls.Add($AutoChartsNoticeTextbox)
    
    #--------------------------------
    # Auto Create Charts Save Button
    #--------------------------------      
    $AutoChartsSaveButton           = New-Object Windows.Forms.Button
    $AutoChartsSaveButton.Text      = "Save Image"
    $AutoChartsSaveButton.Location  = New-Object System.Drawing.Point(955,516)
    $AutoChartsSaveButton.Size      = New-Object System.Drawing.Size(150,25)
    $AutoChartsSaveButton.Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    # we can find supported values here:
    #    [enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
    $AutoChartsSaveButton.Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    $AutoChartsSaveButton.ForeColor = "Black"
    $AutoChartsSaveButton.UseVisualStyleBackColor = $True
    $AutoChartsSaveButton.Add_Click({
        $Result = Invoke-SaveChartAsImage
        If ($Result) { $AutoChart.SaveImage($Result.FileName, $Result.Extension) }
    })
    $AutoChart.controls.add($AutoChartsSaveButton)
    $ButtonSpacing = 35 


    if ($AutoChartSelectChartComboBox.SelectedItem -notmatch "All Charts") {
        #------------------------------------
        # Auto Create Charts Series1 Results
        #------------------------------------
        if ($AutoChartsBaselineCheckBox.Checked -eq $True) {
            if ($script:CSVFileBaselineCollection) {
                $AutoChartsSeries1Results = New-Object Windows.Forms.Button -Property @{
                    Text      = "$Series01Name Results"
                    Location = @{ X = $AutoChartsSaveButton.Location.X
                                  Y = $AutoChartsSaveButton.Location.Y - $ButtonSpacing
                                }
                    Size     = @{ Width  = 150 
                                  Height = 25
                                }
                    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
                    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
                    ForeColor = "Blue"
                    UseVisualStyleBackColor = $True
                }
                $AutoChartsSeries1Results.Add_Click({ Import-CSV $script:CSVFileBaselineCollection | Out-GridView -Title "$script:CSVFileBaselineCollection" }) 
                $AutoChart.controls.add($AutoChartsSeries1Results)
                $ButtonSpacing += 35
            
                # Autosaves the chart if checked
                $FileName           = ($script:CSVFileBaselineCollection).split('\')[-1]
                $FileDate           = ($script:CSVFileBaselineCollection).split('\')[-2]
                if ($OptionsAutoSaveChartsAsImages.checked) { $AutoChart.SaveImage("$AutosavedChartsDirectory\$FileDate-$FileName.png", 'png') }
            }
        }
        #------------------------------------
        # Auto Create Charts Series2 Results
        #------------------------------------
        if ($AutoChartsPreviousCheckBox.Checked -eq $True) {
            if ($script:CSVFilePreviousCollection) {
                $AutoChartsSeries2Results = New-Object Windows.Forms.Button -Property @{
                    Text      = "$Series02Name Results"
                    Location = @{ X = $AutoChartsSaveButton.Location.X
                                  Y = $AutoChartsSaveButton.Location.Y - $ButtonSpacing
                                }
                    Size     = @{ Width  = 150 
                                  Height = 25
                                }
                    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
                    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
                    ForeColor = "Orange"
                    UseVisualStyleBackColor = $True
                    }
                $AutoChartsSeries2Results.Add_Click({ Import-CSV $script:CSVFilePreviousCollection | Out-GridView -Title "$script:CSVFilePreviousCollection" }) 
                $AutoChart.controls.add($AutoChartsSeries2Results)
                $ButtonSpacing += 35

                # Autosaves the chart if checked
                $FileName           = ($script:CSVFilePreviousCollection).split('\')[-1]
                $FileDate           = ($script:CSVFilePreviousCollection).split('\')[-2]
                if ($OptionsAutoSaveChartsAsImages.checked) { $AutoChart.SaveImage("$AutosavedChartsDirectory\$FileDate-$FileName.png", 'png') }
            }
        }
        #------------------------------------
        # Auto Create Charts Series3 Results
        #------------------------------------
        if ($AutoChartsMostRecentCheckBox.Checked -eq $True) {
            if ($script:CSVFileMostRecentCollection) { 
                $AutoChartsSeries3Results = New-Object Windows.Forms.Button -Property @{
                    Text      = "$Series03Name Results"
                    Location = @{ X = $AutoChartsSaveButton.Location.X
                                  Y = $AutoChartsSaveButton.Location.Y - $ButtonSpacing
                                }
                    Size     = @{ Width  = 150 
                                  Height = 25
                                }
                    Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
                    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
                    ForeColor = "Red"
                    UseVisualStyleBackColor = $True
                    }
                $AutoChartsSeries3Results.Add_Click({ Import-CSV $script:CSVFileMostRecentCollection | Out-GridView -Title "$script:CSVFileMostRecentCollection" }) 
                $AutoChart.controls.add($AutoChartsSeries3Results)
                $ButtonSpacing += 35

                # Autosaves the chart if checked
                $FileName           = ($script:CSVFileMostRecentCollection).split('\')[-1]
                $FileDate           = ($script:CSVFileMostRecentCollection).split('\')[-2]
                if ($OptionsAutoSaveChartsAsImages.checked) { $AutoChart.SaveImage("$AutosavedChartsDirectory\$FileDate-$FileName.png", 'png') }
            }
        }
    }

    # Launches the form
    $AutoChartsForm.Add_Shown({$AutoChartsForm.Activate()})
    [void]$AutoChartsForm.ShowDialog()
}

#---------------------------
# Auto Create Charts Button
#---------------------------
$AutoCreateChartsButton          = New-Object System.Windows.Forms.Button -Property @{
    Name     = "Auto Create Charts"
    Text     = "Auto Create Charts"
    Location = @{ X = $BuildChartButton.Location.X
                  Y = $BuildChartButton.Location.Y - 30
                }
    Size     = @{ Width  = 115
                  Height = 22
                }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    UseVisualStyleBackColor = $True
}
$AutoCreateChartsButton.Add_Click({ AutoChartsSelectOptions })
$AutoCreateChartsButton.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ Utilizes PowerShell (v3) charts to visualize data.
⦿ These charts are auto created from pre-selected CSV files and fields.
⦿ Multi-series charts can be created that are generated from baseline, 
    previous, and most recents CSV files for pre-selected CSV files.
⦿ Multi-series charts will only display results from hosts that are
    found in each series; excess host results will be hidden.
⦿ Charts can be filtered for data collected via WMI or PoSh commands.
⦿ Images can be saved of each chart in .png format.`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage123))
        $ToolTip.Active         = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation   = $true
        $ToolTip.UseFading      = $true
        $ToolTip.IsBalloon      = $true
        $ToolTip.ToolTipIcon    = "Info"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle   = 'Auto Create Charts'
    }
})
$Section2MainTab.Controls.Add($AutoCreateChartsButton)

#=============================================================
#    ____        __  _                     ______      __  
#   / __ \____  / /_(_)___  ____  _____   /_  __/___ _/ /_ 
#  / / / / __ \/ __/ / __ \/ __ \/ ___/    / / / __ `/ __ \
# / /_/ / /_/ / /_/ / /_/ / / / (__  )    / / / /_/ / /_/ /
# \____/ .___/\__/_/\____/_/ /_/____/    /_/  \__,_/_.___/ 
#     /_/                                                  
#=============================================================

##############################################################################################################################################################
##
## Section 1 Options SubTab
##
##############################################################################################################################################################
$Section2OptionsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text                    = "Options"
    Name                    = "Options"
    Font                    = New-Object System.Drawing.Font("$Font",11,0,0,0)
    UseVisualStyleBackColor = $True
}
$Section2TabControl.Controls.Add($Section2OptionsTab)

#-------------------------------
# Option - Job Timeout Combobox
#-------------------------------
$OptionJobTimeoutSelectionComboBox = New-Object -TypeName System.Windows.Forms.Combobox -Property @{
    #Text    = 600     #The default is set with the Cmdlet Parameter Options
    Location = @{ X = 3
                  Y = 11
                }
    Size     = @{ Width  = 50
                  Height = 22
                }
    Font     = New-Object System.Drawing.Font("$Font",9,0,3,0)
    AutoCompleteMode = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
}
$JobTimesAvailable = @(15,30,45,60,120,180,240,300,600)
ForEach ($Item in $JobTimesAvailable) { $OptionJobTimeoutSelectionComboBox.Items.Add($Item) }
$OptionJobTimeoutSelectionComboBox.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ Queries are threaded and not executed serially like typical scripts.`n⦿ This is done in command order for each host checked.`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage3))
        $ToolTip.Active         = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation   = $true
        $ToolTip.UseFading      = $true
        $ToolTip.IsBalloon      = $true
        $ToolTip.ToolTipIcon    = "Info"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle   = 'Sets the Background Job Timeout'
    }    
})
$OptionJobTimeoutSelectionComboBox.Text = $JobTimeOutSeconds
$Section2OptionsTab.Controls.Add($OptionJobTimeoutSelectionComboBox)

#----------------------------
# Option - Job Timeout Label
#----------------------------
$OptionJobTimeoutSelectionLabel = New-Object -TypeName System.Windows.Forms.Label -Property @{
    Text     = "Job Timeout in Seconds"
    Location = @{ X = $OptionJobTimeoutSelectionComboBox.Size.Width + 10
                  Y = $OptionJobTimeoutSelectionComboBox.Location.Y + 3
                }
    Size     = @{ Width  = 150
                  Height = 25
                }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$Section2OptionsTab.Controls.Add($OptionJobTimeoutSelectionLabel)

#----------------------------------------------
# Option - Statistics Update Interval Combobox
#----------------------------------------------
$OptionStatisticsUpdateIntervalCombobox = New-Object System.Windows.Forms.Combobox -Property @{
    Text     = 5
    Location = @{ X = 3
                  Y = $OptionJobTimeoutSelectionComboBox.Location.Y + $OptionJobTimeoutSelectionComboBox.Size.Height + 5
                }
    Size     = @{ Width  = 50
                  Height = 22
                }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$StatisticsTimesAvailable = @(1,5,10,15,30,45,60)
ForEach ($Item in $StatisticsTimesAvailable) { $OptionStatisticsUpdateIntervalCombobox.Items.Add($Item) }
$OptionStatisticsUpdateIntervalCombobox.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ How often the Statistics Tab updates when collecting data.
⦿ The value entered is in seconds.
⦿ Collecting statistics requires some additional processing time,
     so the longer the time the less execution time overhead.
⦿ Do not set the value to zero '0'.`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage3))
        $ToolTip.Active         = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation   = $true
        $ToolTip.UseFading      = $true
        $ToolTip.IsBalloon      = $true
        $ToolTip.ToolTipIcon    = "Info"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle   = 'Statistics Update Interval'
    }    
})
$Section2OptionsTab.Controls.Add($OptionStatisticsUpdateIntervalCombobox)

#-------------------------------------------
# Option - Statistics Update Interval Label
#-------------------------------------------
$OptionStatisticsUpdateIntervalLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "Statistics Update Interval"
    Location = @{ X = $OptionStatisticsUpdateIntervalCombobox.Size.Width + 10
                  Y = $OptionStatisticsUpdateIntervalCombobox.Location.Y + 3
                }
    Size     = @{ Width  = 200
                  Height = 22
                }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$Section2OptionsTab.Controls.Add($OptionStatisticsUpdateIntervalLabel)

#------------------------------------
# Option - Search Processes Checkbox
#------------------------------------
$OptionSearchProcessesCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
    Text     = "Host Data Search - Include 'Processes' Results"
    Location = @{ X = 3
                  Y = $OptionStatisticsUpdateIntervalCombobox.Location.Y + $OptionStatisticsUpdateIntervalCombobox.Size.Height + 5
                }
    Size     = @{ Width  = 400
                  Height = $Column3BoxHeight
                }
    Enabled  = $true
    Checked  = $False
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
#$OptionSearchProcessesCheckBox.Add_Click({  })
$Section2OptionsTab.Controls.Add($OptionSearchProcessesCheckBox)

#-----------------------------------
# Option - Search Services Checkbox
#-----------------------------------
$OptionSearchServicesCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
    Text     = "Host Data Search - Include 'Services' Results"
    Location = @{ X = 3
                  Y = $OptionSearchProcessesCheckBox.Location.Y + $OptionSearchProcessesCheckBox.Size.Height + 5
                }
    Size     = @{ Width  = 400
                  Height = $Column3BoxHeight
                }
    Enabled  = $true
    Checked  = $False
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
#$OptionSearchServicesCheckBox.Add_Click({  })
$Section2OptionsTab.Controls.Add($OptionSearchServicesCheckBox)

#--------------------------------------------------
# Option - Search Network TCP Connections Checkbox
#--------------------------------------------------
$OptionSearchNetworkTCPConnectionsCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
    Text     = "Host Data Search - Include 'Network TCP Connections' Results"
    Location = @{ X = 3
                  Y = $OptionSearchServicesCheckBox.Location.Y + $OptionSearchServicesCheckBox.Size.Height + 5
                }
    Size     = @{ Width  = 400
                  Height = $Column3BoxHeight
                }
    Enabled  = $true
    Checked  = $False
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
#$OptionSearchNetworkTCPConnectionsCheckBox.Add_Click({  })
$Section2OptionsTab.Controls.Add( $OptionSearchNetworkTCPConnectionsCheckBox )

#--------------------------
# Option -  GUI Top Window
#--------------------------
$OptionGUITopWindowCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
    Text     = "GUI always on top"
    Location = @{ X = 3
                  Y = $OptionSearchNetworkTCPConnectionsCheckBox.Location.Y + $OptionSearchNetworkTCPConnectionsCheckBox.Size.Height + 5
                }
    Size     = @{ Width  = 300
                  Height = $Column3BoxHeight
                }
    Enabled  = $true
    Checked  = $false
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$OptionGUITopWindowCheckBox.Add_Click({ 
    # Option to toggle if the Windows is not the top most
    if   ( $OptionGUITopWindowCheckBox.checked ) { $PoShACME.Topmost = $true  }
    else { $PoShACME.Topmost = $false }
})
$Section2OptionsTab.Controls.Add( $OptionGUITopWindowCheckBox )

#-------------------------------------
# Option -  Autosave Charts As Images
#-------------------------------------
$OptionsAutoSaveChartsAsImages = New-Object System.Windows.Forms.Checkbox -Property @{
    Text     = "Autosave Charts As Images"
    Location = @{ X = 3
                  Y = $OptionGUITopWindowCheckBox.Location.Y + $OptionGUITopWindowCheckBox.Size.Height + 5
                }
    Size     = @{ Width  = 300
                  Height = $Column3BoxHeight
                }
    Enabled  = $true
    Checked  = $true
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
#$OptionsAutoSaveChartsAsImages.Add_Click({  })
$Section2OptionsTab.Controls.Add( $OptionsAutoSaveChartsAsImages )


#-----------------------
# Option - Show ToolTip
#-----------------------
$OptionShowToolTipCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
    Text     = "Show ToolTip"
    Location = @{ X = 3
                  Y = $OptionsAutoSaveChartsAsImages.Location.Y + $OptionsAutoSaveChartsAsImages.Size.Height + 5
                }
    Size     = @{ Width  = 200 
                  Height = $Column3BoxHeight
                }
    Enabled  = $true
    Checked  = $true
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
#$OptionShowToolTipCheckBox.Add_Click({    })
#Cmdlet Parameter Option
    if ($DisableToolTip) {$OptionShowToolTipCheckBox.Checked = $False}
$Section2OptionsTab.Controls.Add($OptionShowToolTipCheckBox)

#--------------------------------------
# Option - Text To Speach/TTS Checkbox
#--------------------------------------
$OptionTextToSpeachCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
    Text     = "Audible Completion Message"
    Location = @{ X = 3
                  Y = $OptionShowToolTipCheckBox.Location.Y + $OptionShowToolTipCheckBox.Size.Height + 5
                }
    Size     = @{ Width  = 200
                  Height = $Column3BoxHeight
                }
    Enabled  = $true
    Checked  = $false
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
#$OptionTextToSpeachCheckBox.Add_Click({ })
# Cmdlet Parameter Option
if ($AudibleCompletionMessage) {$OptionTextToSpeachCheckBox.Checked = $True}
$Section2OptionsTab.Controls.Add($OptionTextToSpeachCheckBox)

#=====================================================================
#    _____ __        __  _      __  _              ______      __  
#   / ___// /_____ _/ /_(_)____/ /_(_)_________   /_  __/___ _/ /_ 
#   \__ \/ __/ __ `/ __/ / ___/ __/ / ___/ ___/    / / / __ `/ __ \
#  ___/ / /_/ /_/ / /_/ (__  ) /_/ / /__(__  )    / / / /_/ / /_/ /
# /____/\__/\__,_/\__/_/____/\__/_/\___/____/    /_/  \__,_/_.___/ 
#
#=====================================================================


##############################################################################################################################################################
##
## Section 1 Statistics SubTab
##
##############################################################################################################################################################
$Section2StatisticsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text                    = "Statistics"
    Name                    = "Statistics"
    Font                    = New-Object System.Drawing.Font("$Font",10,0,0,0)
    UseVisualStyleBackColor = $True
}
$Section2TabControl.Controls.Add($Section2StatisticsTab)

function Get-PoShACMEStatistics {
    $StatisticsResults             = ""
    $StatisticsAllCSVFiles         = Get-Childitem -Path $CollectedDataDirectory -Recurse -Include "*.csv"
    $StatisticsAllCSVFilesMeasured = $StatisticsAllCSVFiles | Measure-Object -Property Length -Sum -Average -Maximum -Minimum

    $StatisticsResults += "$('{0,-28}{1}' -f "Number of CSV files:", $($StatisticsAllCSVFilesMeasured.Count))`r`n"

    $StatisticsFirstCollection = $($StatisticsAllCSVFiles | Sort-Object -Property CreationTime | Select-Object -First 1).CreationTime
    $StatisticsResults += "$('{0,-28}{1}' -f "First query datetime:", $StatisticsFirstCollection)`r`n"

    $StatisticsLatestCollection = $($StatisticsAllCSVFiles | Sort-Object -Property CreationTime | Select-Object -Last 1).CreationTime
    $StatisticsResults += "$('{0,-28}{1}' -f "Latest query datetime:", $StatisticsLatestCollection)`r`n"
    
    $StatisticsAllCSVFilesSum = $(
        $CSVBytes = $StatisticsAllCSVFilesMeasured.Sum
        if ($CSVBytes -gt 1GB) {"{0:N3} GB" -f $($CSVBytes / 1GB)}
        elseif ($CSVBytes -gt 1MB) {"{0:N3} MB" -f $($CSVBytes / 1MB)}
        elseif ($CSVBytes -gt 1KB) {"{0:N3} KB" -f $($CSVBytes / 1KB)}
        else {"{0:N3} Bytes" -f $CSVBytes}    
    )
    $StatisticsResults += "$('{0,-28}{1}' -f "Total amount of CSV data:", $StatisticsAllCSVFilesSum)`r`n"

    $StatisticsAllCSVFilesAverage = $(
        $CSVBytes = $StatisticsAllCSVFilesMeasured.Average
        if ($CSVBytes -gt 1GB) {"{0:N3} GB" -f $($CSVBytes / 1GB)}
        elseif ($CSVBytes -gt 1MB) {"{0:N3} MB" -f $($CSVBytes / 1MB)}
        elseif ($CSVBytes -gt 1KB) {"{0:N3} KB" -f $($CSVBytes / 1KB)}
        else {"{0:N3} Bytes" -f $CSVBytes}    
    )
    $StatisticsResults += "$('{0,-28}{1}' -f "Average CSV filesize:", $StatisticsAllCSVFilesAverage)`r`n"

    $StatisticsAllCSVFilesMaximum = $(
        $CSVBytes = $StatisticsAllCSVFilesMeasured.Maximum
        if ($CSVBytes -gt 1GB) {"{0:N3} GB" -f $($CSVBytes / 1GB)}
        elseif ($CSVBytes -gt 1MB) {"{0:N3} MB" -f $($CSVBytes / 1MB)}
        elseif ($CSVBytes -gt 1KB) {"{0:N3} KB" -f $($CSVBytes / 1KB)}
        else {"{0:N3} Bytes" -f $CSVBytes}    
    )
    $StatisticsResults += "$('{0,-28}{1}' -f "Largest CSV filesize:", $StatisticsAllCSVFilesMaximum)`r`n"

    $StatisticsAllCSVFilesMinimum = $(
        $CSVBytes = $StatisticsAllCSVFilesMeasured.Minimum
        if ($CSVBytes -gt 1GB) {"{0:N3} GB" -f $($CSVBytes / 1GB)}
        elseif ($CSVBytes -gt 1MB) {"{0:N3} MB" -f $($CSVBytes / 1MB)}
        elseif ($CSVBytes -gt 1KB) {"{0:N3} KB" -f $($CSVBytes / 1KB)}
        else {"{0:N3} Bytes" -f $CSVBytes}    
    )
    $StatisticsResults += "$('{0,-28}{1}' -f "Smallest CSV filesize:", $StatisticsAllCSVFilesMinimum)`r`n"

    $StatisticsResults += "`r`n"
    $StatisticsLogFile = Get-ItemProperty -Path $Logfile

    $NumberOfLogEntries = (get-content -path $logfile | Select-String -Pattern '\d{4}/\d{2}/\d{2} \d{2}[:]\d{2}[:]\d{2} [-] ').count
    $StatisticsResults += "$('{0,-28}{1}' -f "Number of Log Entries:", $NumberOfLogEntries)`r`n"

    $StatisticsLogFileSize = $(
        $LogFileSize = $StatisticsLogFile.Length
        if ($LogFileSize -gt 1GB) {"{0:N3} GB" -f $($LogFileSize / 1GB)}
        elseif ($LogFileSize -gt 1MB) {"{0:N3} MB" -f $($LogFileSize / 1MB)}
        elseif ($LogFileSize -gt 1KB) {"{0:N3} KB" -f $($LogFileSize / 1KB)}
        else {"{0:N3} Bytes" -f $LogFileSize}    
    )
    $StatisticsResults += "$('{0,-28}{1}' -f "Logfile filesize:", $StatisticsLogFileSize)`r`n"

    $StatisticsResults += "`r`n"
    $StatisticsComputerCount = 0
    [System.Windows.Forms.TreeNodeCollection]$StatisticsAllHostsNode = $ComputerListTreeView.Nodes
    foreach ($root in $StatisticsAllHostsNode) {foreach ($Category in $root.Nodes) {foreach ($Entry in $Category.nodes) {if ($Entry.Checked) { $StatisticsComputerCount++ }}}}
    $StatisticsResults += "$('{0,-28}{1}' -f "Computers Selected:", $StatisticsComputerCount)`r`n"

    $StatisticsCommandCount = 0
    [System.Windows.Forms.TreeNodeCollection]$StatisticsAllCommandsNode = $CommandsTreeView.Nodes 
    foreach ($root in $StatisticsAllCommandsNode) { foreach ($Category in $root.Nodes) { foreach ($Entry in $Category.nodes) { if ($Entry.Checked) { $StatisticsCommandCount++ }}}}
    $StatisticsResults += "$('{0,-28}{1}' -f "Queries Selected:", $StatisticsCommandCount)`r`n"

    $ResourcesDirCheck = Test-Path -Path $ResourcesDirectory
    $StatisticsResults += "$('{0,-28}{1}' -f "Resources Directory Check:", $ResourcesDirCheck)`r`n"

    return $StatisticsResults
}
$StatisticsResults = Get-PoShACMEStatistics

#---------------------
# Statistics - Button
#---------------------
$StatisticsRefreshButton = New-Object System.Windows.Forms.Button -Property @{
    Name                    = "Refresh"
    Text                    = "Refresh"
    Location                = New-Object System.Drawing.Point(2,5)
    Size                    = New-Object System.Drawing.Size(100,22)
    Font                    = New-Object System.Drawing.Font("$Font",11,0,0,0)
    UseVisualStyleBackColor = $True
}
$StatisticsRefreshButton.Add_Click({
    $StatisticsResults = Get-PoShACMEStatistics
    $StatisticsNumberOfCSVs.text = $StatisticsResults
}) 
$Section2StatisticsTab.Controls.Add($StatisticsRefreshButton)

#------------------------------------------
# Option - Computer List - View Log Button
#------------------------------------------
$StatisticsLogButton = New-Object System.Windows.Forms.Button -Property @{
    Text                    = "View Log"
    Location                = New-Object System.Drawing.Point(258,5)
    Size                    = New-Object System.Drawing.Size(100,22)
    Font                    = New-Object System.Drawing.Font("$Font",11,0,0,0)
    UseVisualStyleBackColor = $True
}
$StatisticsLogButton.Add_Click({Start-Process notepad.exe $LogFile}) 
$StatisticsLogButton.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ Opens the PoSh-ACME activity log file.
⦿ All activities are logged, to inlcude:
    The launch of PoSh-ACME and the assosciated account/privileges.
    Each queries executed against each host.
    Network enumeration scannning for hosts: IPs and Ports.
    Connectivity checks: Ping, WinRM, & RPC.
    Remote access to hosts, but not commands executed within.`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage3))
        $ToolTip.Active         = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation   = $true
        $ToolTip.UseFading      = $true
        $ToolTip.IsBalloon      = $true
        $ToolTip.ToolTipIcon    = "Info"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle   = 'View Activity Log File'
    }    
})
$Section2StatisticsTab.Controls.Add($StatisticsLogButton)

#----------------------
# Statistics - Textbox
#----------------------
$StatisticsNumberOfCSVs = New-Object System.Windows.Forms.Textbox -Property @{
    Text       = $StatisticsResults
    Location   = New-Object System.Drawing.Point(3,32)
    Size       = New-Object System.Drawing.Size(354,215)
    Font       = New-Object System.Drawing.Font("Courier new",11,0,0,0)
    Multiline  = $true
    #Scrollbars = "Vertical"
    Enabled    = $true
}
#$StatisticsNumberOfCSVs.Add_MouseHover({
#    $StatisticsResults = Get-PoShACMEStatistics
#    $StatisticsNumberOfCSVs.text = $StatisticsResults
#})
#$OptionTextToSpeachCheckBox.Add_Click({ })
$Section2StatisticsTab.Controls.Add($StatisticsNumberOfCSVs)

#============================================================================================================================================================
#============================================================================================================================================================
#============================================================================================================================================================
# ComputerList Treeview Section
#============================================================================================================================================================
#============================================================================================================================================================
#============================================================================================================================================================
# Varables to Control Column 4
$Column4RightPosition     = 845
$Column4DownPosition      = 11
$Column4BoxWidth          = 220
$Column4BoxHeight         = 22
$Column4DownPositionShift = 25

# Initial load of CSV data
$script:ComputerListTreeViewData = $null
$script:ComputerListTreeViewData = Import-Csv $ComputerListTreeViewFileSave -ErrorAction SilentlyContinue #| Select-Object -Property Name, OperatingSystem, CanonicalName, IPv4Address, MACAddress, Notes
#$script:ComputerListTreeViewData

function Save-HostData {
    $script:ComputerListTreeViewData | Export-Csv $ComputerListTreeViewFileSave -NoTypeInformation
}
function TempSave-HostData {
    $script:ComputerListTreeViewData | Export-Csv $ComputerListTreeViewFileAutoSave -NoTypeInformation
}

function Initialize-ComputerListTreeView {
    $script:TreeNodeComputerList = New-Object -TypeName System.Windows.Forms.TreeNode -ArgumentList 'All Hosts' 
    $script:TreeNodeComputerList.Tag = "Computers"
    $script:TreeNodeComputerList.Expand()
    $script:TreeNodeComputerList.NodeFont   = New-Object System.Drawing.Font("$Font",10,1,1,1)
    $script:TreeNodeComputerList.ForeColor  = [System.Drawing.Color]::FromArgb(0,0,0,0)

    $script:ComputerListSearch       = New-Object -TypeName System.Windows.Forms.TreeNode -ArgumentList '* Search Results'
    $script:ComputerListSearch.Tag   = "Search"
}

function Populate-ComputerListTreeViewDefaultData {
    # This section populates the data with default data if it doesn't have any
    $script:ComputerListTreeViewDataTemp = @()
    Foreach($Computer in $script:ComputerListTreeViewData) {
        # Trims out the domain name from the the CanonicalName
        $CanonicalName = $($($Computer.CanonicalName) -replace $Computer.Name,"" -replace $Computer.CanonicalName.split('/')[0],"").TrimEnd("/")

        $ComputerListTreeViewInsertDefaultData = New-Object PSObject -Property @{ Name = $Computer.Name}        
        if ($Computer.OperatingSystem) { 
            $ComputerListTreeViewInsertDefaultData | Add-Member -MemberType NoteProperty -Name OperatingSystem -Value $Computer.OperatingSystem -Force }
        else { 
            $ComputerListTreeViewInsertDefaultData | Add-Member -MemberType NoteProperty -Name OperatingSystem -Value "Unknown OS" -Force }
        
        if ($Computer.CanonicalName) { 
            $ComputerListTreeViewInsertDefaultData | Add-Member -MemberType NoteProperty -Name CanonicalName -Value $CanonicalName -Force }
        else { 
            $ComputerListTreeViewInsertDefaultData | Add-Member -MemberType NoteProperty -Name CanonicalName -Value "/Unknown OU" -Force }

        if ($Computer.IPv4Address) { 
            $ComputerListTreeViewInsertDefaultData | Add-Member -MemberType NoteProperty -Name IPv4Address -Value $Computer.IPv4Address -Force }
        else { 
            $ComputerListTreeViewInsertDefaultData | Add-Member -MemberType NoteProperty -Name IPv4Address -Value "No IP Available" -Force }

        if ($Computer.MACAddress) { 
            $ComputerListTreeViewInsertDefaultData | Add-Member -MemberType NoteProperty -Name MACAddress -Value $Computer.MACAddress -Force }
        else { 
            $ComputerListTreeViewInsertDefaultData | Add-Member -MemberType NoteProperty -Name MACAddress -Value "No MAC Available" -Force }

        if ($Computer.Notes) { 
            $ComputerListTreeViewInsertDefaultData | Add-Member -MemberType NoteProperty -Name Notes -Value $Computer.Notes -Force }
        else { 
            $ComputerListTreeViewInsertDefaultData | Add-Member -MemberType NoteProperty -Name Notes -Value "No Notes Available" -Force }
        
        $script:ComputerListTreeViewDataTemp += $ComputerListTreeViewInsertDefaultData
        ###write-host $($ComputerListTreeViewInsertDefaultData | Select Name, OperatingSystem, CanonicalName, IPv4Address, Notes)
    }
    $script:ComputerListTreeViewData       = $script:ComputerListTreeViewDataTemp
    $script:ComputerListTreeViewDataTemp   = $null
    $ComputerListTreeViewInsertDefaultData = $null
}

# This function checks if the category node is empty, if so the node is removed
function Check-CategoryIsEmpty {
    [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $ComputerListTreeView.Nodes
    foreach ($root in $AllHostsNode) { 
        foreach ($Category in $root.Nodes) { 
            $CategoryNodeContentCount = 0
            # Counts the number of computer nodes in each category
            foreach ($Entry in $Category.nodes) { $CategoryNodeContentCount += 1 }
            # Removes a category node if it is empty
            if ($CategoryNodeContentCount -eq 0) { $Category.remove() }
        }
    }
    
}

# This section will check the checkboxes selected under the other view
function Keep-ComputerListCheckboxesChecked {
    $ComputerListTreeView.Nodes.Add($script:TreeNodeComputerList)
    $ComputerListTreeView.ExpandAll()
    
    if ($ComputerListCheckedBoxesSelected.count -gt 0) {
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Categories that were checked will not remained checked.")
        $ResultsListBox.Items.Add("")
        $ResultsListBox.Items.Add("The following hostname/IP selections are still selected in the new treeview:")
        foreach ($root in $AllHostsNode) { 
            foreach ($Category in $root.Nodes) { 
                foreach ($Entry in $Category.nodes) { 
                    if ($ComputerListCheckedBoxesSelected -contains $Entry.text) {
                        $Entry.Checked = $true
                        $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",10,1,1,1)
                        $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,0,224)
                        $Category.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
                        $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                        $ResultsListBox.Items.Add($Entry.Text)
                    }            
                }
            }
        }
    }
}

function Add-ComputerNode { 
        param ( 
            $RootNode, 
            $Category,
            $Entry,
            $ToolTip
        )
        $newNode      = New-Object System.Windows.Forms.TreeNode  
        $newNode.Name = "$Entry"
        $newNode.Text = "$Entry"
        if ($ToolTip) { $newNode.ToolTipText  = "$ToolTip" }
        else { $newNode.ToolTipText  = "No Data Available" }

        If ($RootNode.Nodes.Tag -contains $Category) {
            $HostNode = $RootNode.Nodes | Where-Object {$_.Tag -eq $Category}
        }
        Else {
            $CategoryNode = New-Object System.Windows.Forms.TreeNode -Property @{
                Name        = $Category
                Text        = $Category
                Tag         = $Category
                ToolTipText = "Checkbox this Category to query all its hosts"
                NodeFont    = New-Object System.Drawing.Font("$Font",11,1,2,1)
                ForeColor   = [System.Drawing.Color]::FromArgb(0,0,0,0)
            }
            $Null     = $RootNode.Nodes.Add($CategoryNode)
            $HostNode = $RootNode.Nodes | Where-Object {$_.Tag -eq $Category}
        }
        $Null = $HostNode.Nodes.Add($newNode)
}
$script:ComputerListTreeViewSelected = ""


# Populate Auto Tag List used for Host Data tagging and Searching
$TagListFileContents = Get-Content -Path $TagAutoListFile
$TagList = @()
foreach ($Tag in $TagListFileContents) {
    $TagList += $Tag
}

function Search-ComputerListTreeView {
    #$Section4TabControl.SelectedTab   = $Section3ResultsTab
    [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $ComputerListTreeView.Nodes

    # Checks if the search node already exists
    $SearchNode = $false
    foreach ($root in $AllHostsNode) { 
        if ($root.text -imatch 'Search Results') { $SearchNode = $true }
    }
    if ($SearchNode -eq $false) { $ComputerListTreeView.Nodes.Add($script:ComputerListSearch) }

    # Checks if the search has already been conduected
    $SearchCheck = $false
    foreach ($root in $AllHostsNode) { 
        if ($root.text -imatch 'Search Results') {                    
            foreach ($Category in $root.Nodes) { 
                if ($Category.text -eq $ComputerListTreeViewSearchTextBox.Text) { $SearchCheck = $true}            
            }
        }
    }
    # Conducts the search, if something is found it will add it to the treeview
    # Will not produce multiple results if the host triggers in more than one field
    $SearchFound = @()
    if ($ComputerListTreeViewSearchTextBox.Text -ne "" -and $SearchCheck -eq $false) {
        Foreach($Computer in $script:ComputerListTreeViewData) {
            if (($SearchFound -inotcontains $Computer) -and ($Computer.Notes -imatch $ComputerListTreeViewSearchTextBox.Text)) {
                Add-ComputerNode -RootNode $script:ComputerListSearch -Category $ComputerListTreeViewSearchTextBox.Text -Entry $Computer.Name -ToolTip $Computer.IPv4Address    
                $SearchFound += $Computer
            }
            if (($SearchFound -inotcontains $Computer) -and ($Computer.Name -imatch $ComputerListTreeViewSearchTextBox.Text)) {
                Add-ComputerNode -RootNode $script:ComputerListSearch -Category $ComputerListTreeViewSearchTextBox.Text -Entry $Computer.Name -ToolTip $Computer.IPv4Address    
                $SearchFound += $Computer
            }
            if (($SearchFound -inotcontains $Computer) -and ($Computer.OperatingSystem -imatch $ComputerListTreeViewSearchTextBox.Text)) {
                Add-ComputerNode -RootNode $script:ComputerListSearch -Category $ComputerListTreeViewSearchTextBox.Text -Entry $Computer.Name -ToolTip $Computer.IPv4Address    
                $SearchFound += $Computer
            }
            if (($SearchFound -inotcontains $Computer) -and ($Computer.CanonicalName -imatch $ComputerListTreeViewSearchTextBox.Text)) {
                Add-ComputerNode -RootNode $script:ComputerListSearch -Category $ComputerListTreeViewSearchTextBox.Text -Entry $Computer.Name -ToolTip $Computer.IPv4Address    
                $SearchFound += $Computer
            }
            if (($SearchFound -inotcontains $Computer) -and ($Computer.IPv4address -imatch $ComputerListTreeViewSearchTextBox.Text)) {
                Add-ComputerNode -RootNode $script:ComputerListSearch -Category $ComputerListTreeViewSearchTextBox.Text -Entry $Computer.Name -ToolTip $Computer.IPv4Address    
                $SearchFound += $Computer
            }                
            if (($SearchFound -inotcontains $Computer) -and ($Computer.MACAddress -imatch $ComputerListTreeViewSearchTextBox.Text)) {
                Add-ComputerNode -RootNode $script:ComputerListSearch -Category $ComputerListTreeViewSearchTextBox.Text -Entry $Computer.Name -ToolTip $Computer.IPv4Address    
                $SearchFound += $Computer
            }                
        }    

        # Checks if the Option is checked, if so it will include searching through 'Processes' CSVs
        # This is a slow process...
    if ($OptionSearchProcessesCheckBox.Checked -or $OptionSearchServicesCheckBox.Checked -or $OptionSearchNetworkTCPConnectionsCheckBox.Checked) {
        # Searches though the all Collection Data Directories to find files that match
        $ListOfCollectedDataDirectories = $(Get-ChildItem -Path $CollectedDataDirectory | Sort-Object -Descending).FullName
        $script:CSVFileMatch = @()

        foreach ($CollectionDir in $ListOfCollectedDataDirectories) {
            $CSVFiles = $(Get-ChildItem -Path $CollectionDir -Filter "*.csv" -Recurse).FullName
            foreach ($CSVFile in $CSVFiles) {
                if ($OptionSearchProcessesCheckBox.Checked) {
                    # Searches for the CSV file that matches the data selected
                    if (($CSVFile -match "Processes") -and ($CSVFile -match "Individual Host Results") -and ($CSVFile -match ".csv")) {
                        if ($(Import-CSV -Path $CSVFile | select -Property Name, Description | `
                            where {($_.Name -imatch $ComputerListTreeViewSearchTextBox.Text) -or ($_.Description -imatch $ComputerListTreeViewSearchTextBox.Text)} #| where {$_.name -ne ''}
                            )) {
                            $ComputerWithResults = $CSVFile.Split('\')[-1].split('-')[-1].split('.')[-2].replace(' ','')
                            if (($SearchFound -inotcontains $ComputerWithResults) -and ($ComputerWithResults -ne ''))  {
                                Add-ComputerNode -RootNode $script:ComputerListSearch -Category $ComputerListTreeViewSearchTextBox.Text -Entry $ComputerWithResults #-ToolTip $Computer.IPv4Address
                                $SearchFound += $ComputerWithResults
                            }
                        }
                    }
                }
                if ($OptionSearchServicesCheckBox.Checked) {
                    # Searches for the CSV file that matches the data selected
                    if (($CSVFile -match "Services") -and ($CSVFile -match "Individual Host Results") -and ($CSVFile -match ".csv")) {
                        if ($(Import-CSV -Path $CSVFile | select -Property Name, DisplayName | `
                            where {($_.Name -imatch $ComputerListTreeViewSearchTextBox.Text) -or ($_.DisplayName -imatch $ComputerListTreeViewSearchTextBox.Text)} #| where {$_.name -ne ''}
                            )) {
                            $ComputerWithResults = $CSVFile.Split('\')[-1].split('-')[-1].split('.')[-2].replace(' ','')
                            if (($SearchFound -inotcontains $ComputerWithResults) -and ($ComputerWithResults -ne ''))  {
                                Add-ComputerNode -RootNode $script:ComputerListSearch -Category $ComputerListTreeViewSearchTextBox.Text -Entry $ComputerWithResults #-ToolTip $Computer.IPv4Address
                                $SearchFound += $ComputerWithResults
                            }
                        }
                    }
                }
                if ($OptionSearchNetworkTCPConnectionsCheckBox.Checked) {
                    # Searches for the CSV file that matches the data selected
                    if (($CSVFile -match "Network") -and ($CSVFile -match "Individual Host Results") -and ($CSVFile -match ".csv")) {
                        if ($(Import-CSV -Path $CSVFile | select -Property RemoteAddress, RemotePort, LocalPort | `
                            where {($_.RemoteAddress -imatch $ComputerListTreeViewSearchTextBox.Text) -or ($_.RemotePort -imatch $ComputerListTreeViewSearchTextBox.Text) -or ($_.LocalPort -imatch $ComputerListTreeViewSearchTextBox.Text)} #| where {$_.name -ne ''}
                            )) {
                            $ComputerWithResults = $CSVFile.Split('\')[-1].split('-')[-1].split('.')[-2].replace(' ','')
                            if (($SearchFound -inotcontains $ComputerWithResults) -and ($ComputerWithResults -ne ''))  {
                                Add-ComputerNode -RootNode $script:ComputerListSearch -Category $ComputerListTreeViewSearchTextBox.Text -Entry $ComputerWithResults #-ToolTip $Computer.IPv4Address
                                $SearchFound += $ComputerWithResults
                            }
                        }
                    }
                }
            }
        }
    }
}
    [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $ComputerListTreeView.Nodes 
    foreach ($root in $AllHostsNode) { 
        if ($root.text -match 'Search Results'){
            $root.Expand()
            foreach ($Category in $root.Nodes) {
                if ($ComputerListTreeViewSearchTextBox.text -in $Category.text) {
                    $Category.Expand()
                }
            }
        }
    }
    $ComputerListTreeViewSearchTextBox.Text = ""

    #$SingleHostIPCheckBox.Enabled  = $true
    # Enables and disables fields
#    if ($SingleHostIPCheckBox.Checked -eq $true){
#        $SingleHostIPTextBox.Text       = ""
#        $ComputerListTreeView.Enabled   = $false
#        $ComputerListTreeView.BackColor = "lightgray"
#    }
#    elseif ($SingleHostIPCheckBox.Checked -eq $false) {
        $SingleHostIPCheckBox.Checked   = $false
        $SingleHostIPTextBox.Text       = $DefaultSingleHostIPText
        $ComputerListTreeView.Enabled   = $true
        $ComputerListTreeView.BackColor = "white"
#    }

}

#----------------------------------------
# ComputerList TreeView - Search TextBox
#----------------------------------------
$ComputerListTreeViewSearchTextBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Name               = "Search TextBox"
    Location           = New-Object System.Drawing.Point(($Column4RightPosition),25)
    Size               = New-Object System.Drawing.Size(172,25)
    AutoCompleteSource = "ListItems" # Options are: FileSystem, HistoryList, RecentlyUsedList, AllURL, AllSystemSources, FileSystemDirectories, CustomSource, ListItems, None
    AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
    Font               = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
ForEach ($Tag in $TagList) { [void] $ComputerListTreeViewSearchTextBox.Items.Add($Tag) }
$ComputerListTreeViewSearchTextBox.Add_KeyDown({ 
    if ($_.KeyCode -eq "Enter") { Search-ComputerListTreeView }
})
$ComputerListTreeViewSearchTextBox.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ Searches through host data and returns results as nodes.
⦿ Search can include any character.
⦿ Tags are pre-built to assist with standarized notes.
⦿ Can search CSV Results, enable them in the Options Tab.`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage3))
        $ToolTip.Active         = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation   = $true
        $ToolTip.UseFading      = $true
        $ToolTip.IsBalloon      = $true
        $ToolTip.ToolTipIcon    = "Info"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle   = 'Search for Hosts'
    }    
})
$PoShACME.Controls.Add($ComputerListTreeViewSearchTextBox)

#---------------------------------------
# ComputerList TreeView - Search Button
#---------------------------------------
$ComputerListTreeViewSearchButton = New-Object System.Windows.Forms.Button -Property @{
    Name     = "Search Button"
    Text     = "Search"
    Location = New-Object System.Drawing.Point(($Column4RightPosition + 176),24)#(($ComputerListTreeViewViewByLabel.Location.Y),($ComputerListTreeViewViewByLabel.Location.X + $ComputerListTreeViewViewByLabel.Size.Height + 5))
    Size     = New-Object System.Drawing.Size(55,22)
}
$ComputerListTreeViewSearchButton.Add_Click({ Search-ComputerListTreeView })
$ComputerListTreeViewSearchButton.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ Searches through host data and returns results as nodes.
⦿ Search can include any character.
⦿ Tags are pre-built to assist with standarized notes.
⦿ Can search CSV Results, enable them in the Options Tab.`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage3))
        $ToolTip.Active         = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation   = $true
        $ToolTip.UseFading      = $true
        $ToolTip.IsBalloon      = $true
        $ToolTip.ToolTipIcon    = "Info"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle   = 'Search for Hosts'
    }    
})
$ComputerListTreeViewSearchButton.Font = New-Object System.Drawing.Font("$Font",11,0,0,0)
$PoShACME.Controls.Add($ComputerListTreeViewSearchButton)

#-----------------------------
# ComputerList Treeview Nodes
#-----------------------------
#Ref: https://info.sapien.com/index.php/guis/gui-controls/spotlight-on-the-contextmenustrip-control
#$ComputerListTreeViewContextMenuStrip = New-Object System.Windows.Forms.ContextMenuStrip
#$ComputerListTreeViewContextMenuStrip.Items.Add("$(hostname)")
#$ComputerListTreeViewContextMenuStrip.Items.Add("Delete")
##$ComputerListTreeViewContextMenuStrip.Items.Add("Move")
#$ComputerListTreeViewContextMenuStrip.Items.Add("Rename")
#$ComputerListTreeViewContextMenuStrip.ShowImageMargin   = $false #default is $true  #This property gets or sets a value indicating whether space for an image is shown on the left edge of the ToolStripMenuItem
#$ComputerListTreeViewContextMenuStrip.ShowCheckMargin   = $true  #default is $false #This property gets or sets a value indicating whether space for a check mark is shown on the left edge of the ToolStripMenuItem    
##$ComputerListTreeViewContextMenuStrip.ShowItemToolTips  = $false #This property gets or sets a value indicating whether ToolTips are to be displayed on ToolStrip items.
#$ComputerListTreeViewContextMenuStrip.SourceControl     = $true #This property returns the last control that caused the ContextMenuStrip to display.
#$ComputerListTreeViewContextMenuStrip.DropShadowEnabled = $true
#$ComputerListTreeViewContextMenuStrip.Text = 'testtest'
#$ComputerListTreeViewContextMenuStrip.Add_Click({ Write-Host $($ComputerListTreeViewContextMenuStrip.Text) })

$ComputerListTreeView = New-Object System.Windows.Forms.TreeView -Property @{
    size              = @{ Width = 230 ; Height = 308 }
    Location          = @{ X = $Column4RightPosition ; Y = $Column4DownPosition + 39 }
    Font              = New-Object System.Drawing.Font("$Font",11,0,0,0)
    CheckBoxes        = $True
    #LabelEdit         = $True  #Not implementing yet...
    ShowLines         = $True
    ShowNodeToolTips  = $True
    #ShortcutsEnabled  = $false                                #Used for ContextMenuStrip
    #ContextMenuStrip  = $ComputerListTreeViewContextMenuStrip #Used for ContextMenuStrip
}
<#$ComputerListTreeView.add_AfterLabelEdit({
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("This is only a test!!!")
})#>
$ComputerListTreeView.Sort()
#$ComputerListTreeView.Add_MouseEnter({ $ComputerListTreeView.size = @{ Width = 361 ; Height = 544 } })
$ComputerListTreeView.Add_MouseEnter({ $ComputerListTreeView.size = @{ Width = 230 ; Height = 544 } })
$ComputerListTreeView.Add_MouseLeave({ $ComputerListTreeView.size = @{ Width = 230 ; Height = 308 } })

$ComputerListTreeView.Add_Click({Conduct-NodeAction -TreeView $ComputerListTreeView.Nodes})
$ComputerListTreeView.add_AfterSelect({Conduct-NodeAction -TreeView $ComputerListTreeView.Nodes})
$ComputerListTreeView.Add_Click({
    # When the node is checked, it updates various items
    [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $ComputerListTreeView.Nodes
    foreach ($root in $AllHostsNode) { 
        if ($root.checked) {
            $root.Expand()
            foreach ($Category in $root.Nodes) { 
                $Category.Expand()
                foreach ($Entry in $Category.nodes) {
                    $Entry.Checked      = $True
                    $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",10,1,1,1)
                    $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,0,224)
                    $Category.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
                    $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                    $Root.NodeFont      = New-Object System.Drawing.Font("$Font",10,1,1,1)
                    $Root.ForeColor     = [System.Drawing.Color]::FromArgb(0,0,0,224)
                }                            
            }
        }
        foreach ($Category in $root.Nodes) { 
            $EntryNodeCheckedCount = 0                        
            if ($Category.checked) {
                $Category.Expand()
                $Category.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
                $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                $Root.NodeFont      = New-Object System.Drawing.Font("$Font",10,1,1,1)
                $Root.ForeColor     = [System.Drawing.Color]::FromArgb(0,0,0,224)
                foreach ($Entry in $Category.nodes) {
                    $EntryNodeCheckedCount  += 1
                    $Entry.Checked      = $True
                    $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",10,1,1,1)
                    $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,0,224)
                }            
            }
            if (!($Category.checked)) {
                foreach ($Entry in $Category.nodes) { 
                    #if ($Entry.isselected) { 
                    if ($Entry.checked) {
                        $EntryNodeCheckedCount  += 1
                        $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",10,1,1,1)
                        $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,0,224)
                        $Root.NodeFont      = New-Object System.Drawing.Font("$Font",10,1,1,1)
                        $Root.ForeColor     = [System.Drawing.Color]::FromArgb(0,0,0,224)
                    }
                    elseif (!($Entry.checked)) { 
                        if ($CategoryCheck -eq $False) {$Category.Checked = $False}
                        $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",10,1,1,1)
                        $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,0,0)
                    }            
                }        
            }            
            if ($EntryNodeCheckedCount -gt 0) {
                $Category.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
                $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                $Root.NodeFont      = New-Object System.Drawing.Font("$Font",10,1,1,1)
                $Root.ForeColor     = [System.Drawing.Color]::FromArgb(0,0,0,224)
            }
            else {
                $Category.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
                $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
                $Root.NodeFont      = New-Object System.Drawing.Font("$Font",10,1,1,1)
                $Root.ForeColor     = [System.Drawing.Color]::FromArgb(0,0,0,0)
            }
        }
    }
})
$ComputerListTreeView.add_AfterSelect({
    # This will return data on hosts selected/highlight, but not necessarily checked
    [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $ComputerListTreeView.Nodes
    foreach ($root in $AllHostsNode) { 
        if ($root.isselected) { 
            $script:ComputerListTreeViewSelected = ""
            $StatusListBox.Items.clear()
            $StatusListBox.Items.Add("Category:  $($root.Text)")
            $ResultsListBox.Items.Clear()
            $ResultsListBox.Items.Add("- Checkbox this Category to query all its hosts")

            $Section3HostDataName.Text  = "N/A"
            $Section3HostDataOS.Text    = "N/A"
            $Section3HostDataOU.Text    = "N/A"
            $Section3HostDataIP.Text    = "N/A"
            $Section3HostDataTags.Text  = "N/A"
            $Section3HostDataNotes.Text = "N/A"

            # Brings the Host Data Tab to the forefront/front view
            $Section4TabControl.SelectedTab   = $Section3HostDataTab
        }
        foreach ($Category in $root.Nodes) { 
            if ($Category.isselected) { 
                $script:ComputerListTreeViewSelected = ""
                $StatusListBox.Items.clear()
                $StatusListBox.Items.Add("Category:  $($Category.Text)")
                $ResultsListBox.Items.Clear()
                $ResultsListBox.Items.Add("- Checkbox this Category to query all its hosts")

                # The follwing fields are filled out with N/A when host nodes are not selected
                $Section3HostDataName.Text  = "N/A"
                $Section3HostDataOS.Text    = "N/A"
                $Section3HostDataOU.Text    = "N/A"
                $Section3HostDataIP.Text    = "N/A"
                $Section3HostDataMAC.Text   = "N/A"
                $Section3HostDataTags.Text  = "N/A"
                $Section3HostDataNotes.Text = "N/A"

                # Brings the Host Data Tab to the forefront/front view
                $Section4TabControl.SelectedTab   = $Section3HostDataTab
            }
            foreach ($Entry in $Category.nodes) { 
                if ($Entry.isselected) { 
                    $script:ComputerListTreeViewSelected = $Entry.Text
                    $StatusListBox.Items.clear()
                    $StatusListBox.Items.Add("Hostname/IP:  $($Entry.Text)")
                    $ResultsListBox.Items.Clear()
                    $ResultsListBox.Items.Add("- Checkkbox one hostname/IP to RDP, PSSession, or PsExec")
                    $ResultsListBox.Items.Add("- Checkbox any number of Categories, hostnames, or IPs to run any number of queries or ping")
                    $ResultsListBox.Items.Add("")
                    $ResultsListBox.Items.Add("- Click on the Host Data Tab to view and modify data")

                    # Populates the Host Data Tab with data from the selected TreeNode
                    $Section3HostDataName.Text  = $($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).Name
                    $Section3HostDataOS.Text    = $($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).OperatingSystem
                    $Section3HostDataOU.Text    = $($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).CanonicalName
                    $Section3HostDataIP.Text    = $($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).IPv4Address
                    $Section3HostDataMAC.Text   = $($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).MACAddress
                    $Section3HostDataNotes.Text = $($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).Notes
                    
                    $Section3HostDataSelectionComboBox.Text         = "Host Data - Selection"
                    $Section3HostDataSelectionDateTimeComboBox.Text = "Host Data - Date & Time"

                    # Brings the Host Data Tab to the forefront/front view
                    $Section4TabControl.SelectedTab   = $Section3HostDataTab
                }
            }       
        }         
    }
})
$PoShACME.Controls.Add($ComputerListTreeView)

#============================================================================================================================================================
# ComputerList TreeView - Radio Buttons
#============================================================================================================================================================
# Default View
Initialize-ComputerListTreeView
Populate-ComputerListTreeViewDefaultData
# Yes, this save initially during load because it will save the poulated default data
Save-HostData

# This will load data that is located in the saved file
Foreach($Computer in $script:ComputerListTreeViewData) {
    Add-ComputerNode -RootNode $script:TreeNodeComputerList -Category $Computer.OperatingSystem -Entry $Computer.Name -ToolTip $Computer.IPv4Address
}
$ComputerListTreeView.Nodes.Add($script:TreeNodeComputerList)
$ComputerListTreeView.ExpandAll()

#-----------------------------
# View hostname/IPs by: Label
#-----------------------------
$ComputerListTreeViewViewByLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "View by:"
    Location = New-Object System.Drawing.Point($Column4RightPosition,7)
    Size     = New-Object System.Drawing.Size(75,25)
    Font     = New-Object System.Drawing.Font("$Font",11,1,2,1)
}
$PoShACME.Controls.Add($ComputerListTreeViewViewByLabel)

#----------------------------------------------------
# ComputerList TreeView - OS & Hostname Radio Button
#----------------------------------------------------
$ComputerListTreeViewOSHostnameRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
    Location = @{ X = $ComputerListTreeViewViewByLabel.Location.X + $ComputerListTreeViewViewByLabel.Size.Width
                  Y = $ComputerListTreeViewViewByLabel.Location.Y - 5
                }
    Size     = @{ Height = 25
                  Width  = 50
                }
    Checked  = $True
    Text     = "OS"
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$ComputerListTreeViewOSHostnameRadioButton.Add_Click({
    $ComputerListTreeViewCollapseAllButton.Text = "Collapse"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Treeview:  Operating Systems")

    # This variable stores data on checked checkboxes, so boxes checked remain among different views
    $ComputerListCheckedBoxesSelected = @()

    [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $ComputerListTreeView.Nodes 
    foreach ($root in $AllHostsNode) { 
        foreach ($Category in $root.Nodes) {
            foreach ($Entry in $Category.nodes) { 
                if ($Entry.Checked) {
                    $ComputerListCheckedBoxesSelected += $Entry.Text
                }
            }
        }
    }
    $ComputerListTreeView.Nodes.Clear()
    Initialize-ComputerListTreeView
    Populate-ComputerListTreeViewDefaultData
    TempSave-HostData
    Foreach($Computer in $script:ComputerListTreeViewData) {
        Add-ComputerNode -RootNode $script:TreeNodeComputerList -Category $Computer.OperatingSystem -Entry $Computer.Name -ToolTip $Computer.IPv4Address
    }
    Keep-ComputerListCheckboxesChecked
})
$ComputerListTreeViewOSHostnameRadioButton.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ Displays the hosts by Operating Systems.
⦿ Hosts will remain checked when switching between views.`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage3))
        $ToolTip.Active         = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation   = $true
        $ToolTip.UseFading      = $true
        $ToolTip.IsBalloon      = $true
        $ToolTip.ToolTipIcon    = "Info"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle   = 'Operating System View'
    }    
})
$PoShACME.Controls.Add($ComputerListTreeViewOSHostnameRadioButton)

#---------------------------------------------------------------------
# ComputerList TreeView - Active Directory OU & Hostname Radio Button
#---------------------------------------------------------------------
$ComputerListTreeViewOUHostnameRadioButton  = New-Object System.Windows.Forms.RadioButton -Property @{
    Location = @{ X = $ComputerListTreeViewOSHostnameRadioButton.Location.X + $ComputerListTreeViewOSHostnameRadioButton.Size.Width + 5
                  Y = $ComputerListTreeViewOSHostnameRadioButton.Location.Y
                }
    Size     = @{ Height = 25
                  Width  = 75
                }
    Checked  = $false
    Text     = "OU / CN"
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$ComputerListTreeViewOUHostnameRadioButton.Add_Click({ 
    $ComputerListTreeViewCollapseAllButton.Text = "Collapse"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Treeview:  Active Directory Organizational Units")

    # This variable stores data on checked checkboxes, so boxes checked remain among different views
    $ComputerListCheckedBoxesSelected = @()

    [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $ComputerListTreeView.Nodes 
    foreach ($root in $AllHostsNode) { 
        foreach ($Category in $root.Nodes) {
            foreach ($Entry in $Category.nodes) { 
                if ($Entry.Checked) {
                    $ComputerListCheckedBoxesSelected += $Entry.Text
                }
            }
        }
    }            
    $ComputerListTreeView.Nodes.Clear()
    Initialize-ComputerListTreeView
    Populate-ComputerListTreeViewDefaultData
    TempSave-HostData

    Foreach($Computer in $script:ComputerListTreeViewData) {
        Add-ComputerNode -RootNode $script:TreeNodeComputerList -Category $Computer.CanonicalName -Entry $Computer.Name -ToolTip $Computer.IPv4Address
    }
    Keep-ComputerListCheckboxesChecked
})
$ComputerListTreeViewOUHostnameRadioButton.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ Displays the hosts by Organizational Unit / Canonical Name.
⦿ Hosts will remain checked when switching between views.`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage3))
        $ToolTip.Active         = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation   = $true
        $ToolTip.UseFading      = $true
        $ToolTip.IsBalloon      = $true
        $ToolTip.ToolTipIcon    = "Info"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle   = 'Organizational Unit / Canonical Name  View'
    }    
})
$PoShACME.Controls.Add($ComputerListTreeViewOUHostnameRadioButton)


##############################################################################################################################################################
##############################################################################################################################################################
##
## Section 3 Computer List - Tab Control
##
##############################################################################################################################################################
##############################################################################################################################################################

$Section3TabControl = New-Object System.Windows.Forms.TabControl -Property @{
    Location      = @{ X = 1082 ; Y = 10 }
    Size          = @{ Height = 349 ; Width  = 126 }
    Name          = "Main Tab Window for Computer List"
    ShowToolTips  = $True
    Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$PoShACME.Controls.Add($Section3TabControl)

# Varables to Control Column 5
$Column5RightPosition     = 3
$Column5DownPositionStart = 6
$Column5DownPosition      = 6
$Column5DownPositionShift = 28
$Column5BoxWidth          = 110
$Column5BoxHeight         = 22

#=======================================================
#     ___        __  _                ______      __  
#    /   | _____/ /_(_)___  ____     /_  __/___ _/ /_ 
#   / /| |/ ___/ __/ / __ \/ __ \     / / / __ `/ __ \
#  / ___ / /__/ /_/ / /_/ / / / /    / / / /_/ / /_/ /
# /_/  |_\___/\__/_/\____/_/ /_/    /_/  \__,_/_.___/ 
#                                                    
#=======================================================

##############################################################################################################################################################
##
## Section 3 - Action Tab
##
##############################################################################################################################################################
$Section3ActionTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text                    = "Action"
    Location                = @{ X = $Column5RightPosition
                                 Y = $Column5DownPosition
                               }
    Size                    = @{ Height = $Column5BoxWidth
                                 Width  = $Column5BoxHeight
                               }
    UseVisualStyleBackColor = $True
    Font                    = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$Section3TabControl.Controls.Add($Section3ActionTab)

#####################################################################################################################################
## Section 3 Computer List - Action Tab Buttons
#####################################################################################################################################

# This function is the base code for testing various connections with remote computers
function Check-Connection {
    param (
        $CheckType,
        $MessageTrue,
        $MessageFalse
    )
    # This brings specific tabs to the forefront/front view
    $Section4TabControl.SelectedTab   = $Section3ResultsTab

    # This array stores checkboxes that are check; a minimum of at least one checkbox will be needed later in the script
    $ComputerListCheckedBoxesSelected = @()
    [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $ComputerListTreeView.Nodes 
    foreach ($root in $AllHostsNode) { 
        if ($root.Checked) {
            foreach ($Category in $root.Nodes) { foreach ($Entry in $Category.nodes) { $ComputerListCheckedBoxesSelected += $Entry.Text } }
        }
        foreach ($Category in $root.Nodes) { 
            if ($Category.Checked) {
                foreach ($Entry in $Category.nodes) { $ComputerListCheckedBoxesSelected += $Entry.Text }       
            }
            foreach ($Entry in $Category.nodes) {
                if ($Entry.Checked) {
                    $ComputerListCheckedBoxesSelected += $Entry.Text
                }
            }       
        }         
    }
    $ComputerListCheckedBoxesSelected = $ComputerListCheckedBoxesSelected | Select-Object -Unique

    $ResultsListBox.Items.Clear()
    if ($ComputerListCheckedBoxesSelected.count -eq 0) {
        $StatusListBox.Items.Clear()    
        $StatusListBox.Items.Add("$($CheckType):  Error")    
        $ResultsListBox.Items.Add("Error:  No hostname/IPs selected")
        $ResultsListBox.Items.Add("        Make sure to checkbox one or more hostname/IPs")
        $ResultsListBox.Items.Add("        Selecting a Category will allow you ping multiple hosts")    
    }
    else {
        $StatusListBox.Items.Clear()    
        $StatusListBox.Items.Add("$($CheckType):  $($ComputerListCheckedBoxesSelected.count) hosts")    
        Start-Sleep -Milliseconds 50
        $NotReachable = @()
        foreach ($target in $ComputerListCheckedBoxesSelected){
            if ($CheckType -eq "Ping") {
                $CheckCommand = Test-Connection -Count 1 -ComputerName $target
            }
            elseif ($CheckType -eq "WinRM Check") {
                $CheckCommand = Test-WSman -ComputerName $target
                # The following does a ping first...
                # Test-NetConnection -CommonTCPPort WINRM -ComputerName <Target>
            }
            elseif ($CheckType -eq "RPC Check") {
                function Test-Port {
                    param ($ComputerName, $Port)
                    begin { $tcp = New-Object Net.Sockets.TcpClient }
                    process {
                        try { $tcp.Connect($ComputerName, $Port) } catch {}
                        if ($tcp.Connected) { $tcp.Close(); $open = $true }
                        else { $open = $false }
                        [PSCustomObject]@{ IP = $ComputerName; Port = $Port; Open = $open }
                    }
                }
                $CheckCommand = Test-Port -ComputerName $target -Port 135 | Select-Object -ExpandProperty Open
                # The following does a ping first...
                # Test-NetConnection -Port 135 -ComputerName <Target>
            }
            foreach ($line in $target){
                if($CheckCommand){$ResultsListBox.Items.Insert(0,"$($MessageTrue):    $target"); Start-Sleep -Milliseconds 50}
                else {
                    $ResultsListBox.Items.Insert(0,"$($MessageFalse):  $target")
                    $NotReachable += $target
                    }
                $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $CheckCommand"
                $LogMessage | Add-Content -Path $LogFile
            }
        }
        # Popup windows requesting user action
        [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic")
        $verify = [Microsoft.VisualBasic.Interaction]::MsgBox(`
            "Do you want to uncheck unresponsive hosts?",`
            #'YesNoCancel,Question',`
            'YesNo,Question',`
            "PoSh-ACME")
        switch ($verify) {
        'Yes'{
            [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $ComputerListTreeView.Nodes 
            foreach ($root in $AllHostsNode) { 
                foreach ($Category in $root.Nodes) { 
                    $Category.Checked = $False
                    $EntryNodeCheckedCount = 0
                    foreach ($Entry in $Category.nodes) {
                        if ($NotReachable -icontains $($Entry.Text)) {
                            $Entry.Checked         = $False
                            $Entry.NodeFont        = New-Object System.Drawing.Font("$Font",10,1,1,1)
                            $Entry.ForeColor       = [System.Drawing.Color]::FromArgb(0,0,0,0)
                        }
                        if ($Entry.Checked) {
                            $EntryNodeCheckedCount += 1                  
                        }
                    }   
                    if ($EntryNodeCheckedCount -eq 0) {
                        $Category.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
                        $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
                    }
                }         
            }   
        }
        'No'     {continue}
        #'Cancel' {exit}
        }
        $ResultsListBox.Items.Insert(0,"")
        $ResultsListBox.Items.Insert(0,"Finished Testing Connections")
    }
}

#============================================================================================================================================================
# Computer List - Ping Button
#============================================================================================================================================================
$ComputerListPingButton           = New-Object System.Windows.Forms.Button -Property @{
    Location  = @{ X = $Column5RightPosition
                   Y = $Column5DownPosition }
    Size      = @{ Height = $Column5BoxHeight 
                   Width  = $Column5BoxWidth }
    Name      = "Ping"
    Text      = "Ping"
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Black"
}
$ComputerListPingButton.Add_MouseHover($MouseHover)
$ComputerListPingButton.Add_Click({
    Check-Connection -CheckType "Ping" -MessageTrue "Able to Ping" -MessageFalse "Unable to Ping"
})
$ComputerListPingButton.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ Unresponsive hosts can be removed from being nodes checked.
⦿ Command:
        Test-Connection -Count 1 -ComputerName <target>
⦿ Command Alternative (legacy):
        ping -n1 <target>`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage3))
        $ToolTip.Active         = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation   = $true
        $ToolTip.UseFading      = $true
        $ToolTip.IsBalloon      = $true
        $ToolTip.ToolTipIcon    = "Warning"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle   = 'Ping Check'
    }    
})
$Section3ActionTab.Controls.Add($ComputerListPingButton) 

$Column5DownPosition += $Column5DownPositionShift

#============================================================================================================================================================
# Computer List - WinRM Check (Test-WSMan)
#============================================================================================================================================================
$ComputerListWinRMCheckButton = New-Object System.Windows.Forms.Button -Property @{
    Location  = @{ X = $Column5RightPosition
                   Y = $Column5DownPosition }
    Size      = @{ Width  = $Column5BoxWidth
                   Height = $Column5BoxHeight }
    Name      = "WinRM Check"
    Text      = "WinRM Check"
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Black"
}
$ComputerListWinRMCheckButton.Add_MouseHover($MouseHover)
$ComputerListWinRMCheckButton.Add_Click({
    Check-Connection -CheckType "WinRM Check" -MessageTrue "Able to Verify WinRM" -MessageFalse "Unable to Verify WinRM"
})
$ComputerListWinRMCheckButton.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ Unresponsive hosts can be removed from being nodes checked.
⦿ Command:
        Test-WSman -ComputerName <target>
⦿ Command  Alternative (Sends Ping First):
        Test-NetConnection CommonTCPPort WINRM -ComputerName <target>`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage3))
        $ToolTip.Active         = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation   = $true
        $ToolTip.UseFading      = $true
        $ToolTip.IsBalloon      = $true
        $ToolTip.ToolTipIcon    = "Warning"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle   = 'WinRM Check'
    }    
})
$Section3ActionTab.Controls.Add($ComputerListWinRMCheckButton) 

$Column5DownPosition += $Column5DownPositionShift

#============================================================================================================================================================
# Computer List - RPC Check (Port 135)
#============================================================================================================================================================
$ComputerListRPCCheckButton = New-Object System.Windows.Forms.Button -Property @{
    Location  = @{ X = $Column5RightPosition
                   Y = $Column5DownPosition }
    Size      = @{ Width  = $Column5BoxWidth
                   Height = $Column5BoxHeight }
    Name      = "RPC Check"
    Text      = "RPC Check"
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Black"
}
$ComputerListRPCCheckButton.Add_MouseHover($MouseHover)
$ComputerListRPCCheckButton.Add_Click({
    Check-Connection -CheckType "RPC Check" -MessageTrue "RPC Port 135 is Open" -MessageFalse "RPC Port 135 is Closed"
})
$ComputerListRPCCheckButton.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ Unresponsive hosts can be removed from being nodes checked.
⦿ Command:
        function Test-Port {
            param ($ComputerName, $Port)
            begin { $tcp = New-Object Net.Sockets.TcpClient }
            process {
                try { $tcp.Connect($ComputerName, $Port) } catch {}
                if ($tcp.Connected) { $tcp.Close(); $open = $true }
                else { $open = $false }
                [PSCustomObject]@{ IP = $ComputerName; Port = $Port; Open = $open }
            }
        }
        $CheckCommand = Test-Port -ComputerName $target -Port 135 | Select-Object -ExpandProperty Open
⦿ Command Alternative (Sends Ping First):
        Test-NetConnection -Port 135 -ComputerName <target>`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage3))
        $ToolTip.Active         = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation   = $true
        $ToolTip.UseFading      = $true
        $ToolTip.IsBalloon      = $true
        $ToolTip.ToolTipIcon    = "Warning"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle   = 'RPC Check'
    }    
})
$Section3ActionTab.Controls.Add($ComputerListRPCCheckButton) 

$Column5DownPosition += $Column5DownPositionShift

#============================================================================================================================================================
# Computer List - EventLog Button
#============================================================================================================================================================
$EventViewerButton = New-Object System.Windows.Forms.Button -Property @{
    Location  = @{ X = $Column5RightPosition
                   Y = $Column5DownPosition }
    Size      = @{ Height = $Column5BoxHeight
                   Width  = $Column5BoxWidth }
    Text      = 'Event Viewer'
    Font      = New-Object System.Drawing.Font("$Font",11,0,2,1)
    ForeColor = "Black"
}
$EventViewerButton.Add_Click({
    # This brings specific tabs to the forefront/front view
    $Section4TabControl.SelectedTab   = $Section3ResultsTab

    # This array stores checkboxes that are check; a minimum of at least one checkbox will be needed later in the script
    $ComputerListCheckedBoxesSelected = @()
    [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $ComputerListTreeView.Nodes 
    foreach ($root in $AllHostsNode) { 
        if ($root.Checked) {
            foreach ($Category in $root.Nodes) { foreach ($Entry in $Category.nodes) { $ComputerListCheckedBoxesSelected += $Entry.Text } }
        }
        foreach ($Category in $root.Nodes) { 
            if ($Category.Checked) {
                foreach ($Entry in $Category.nodes) { $ComputerListCheckedBoxesSelected += $Entry.Text }       
            }
            foreach ($Entry in $Category.nodes) {
                if ($Entry.Checked) {
                    $ComputerListCheckedBoxesSelected += $Entry.Text
                }
            }       
        }         
    }    
    $ResultsListBox.Items.Clear()
    if ($ComputerListCheckedBoxesSelected.count -eq 1) {
        Invoke-Expression -Command "Show-EventLog -ComputerName $ComputerListCheckedBoxesSelected"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Show Event Viewer:  $($script:ComputerListTreeViewSelected)")
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Show-EventLog -ComputerName $ComputerListCheckedBoxesSelected")
        $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  Show-EventLog -ComputerName $($script:ComputerListTreeViewSelected)"
        $LogMessage | Add-Content -Path $LogFile
    }
    elseif ($ComputerListCheckedBoxesSelected.count -eq 0) {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Show Event Viewer:  Error")
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Error:  No hostname/IP selected")
        $ResultsListBox.Items.Add("        Make sure to checkbox only one hostname/IP")
        $ResultsListBox.Items.Add("        Selecting a Category will not allow you to connect to multiple hosts")
    }
    elseif ($ComputerListCheckedBoxesSelected.count -gt 1) {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Show Event Viewer:  Error")
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Error:  Too many hostname/IPs selected")
        $ResultsListBox.Items.Add("        Make sure to checkbox only one hostname/IP")
        $ResultsListBox.Items.Add("        Selecting a Category will not allow you to connect to multiple hosts")    
    }
})
$EventViewerButton.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ Will attempt to show the Event Viewer for a single host.
⦿ Uses RPC/SMB, not WinRM
⦿ Command:
        Show-EventLog -ComputerName <Hostname>`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage3))
        $ToolTip.Active         = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation   = $true
        $ToolTip.UseFading      = $true
        $ToolTip.IsBalloon      = $true
        $ToolTip.ToolTipIcon    = "Warning"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle   = 'Event Viewer'
    }    
})
$Section3ActionTab.Controls.Add($EventViewerButton) 

$Column5DownPosition += $Column5DownPositionShift

#============================================================================================================================================================
# Computer List - RDP Button
#============================================================================================================================================================
$ComputerListRDPButton           = New-Object System.Windows.Forms.Button -Property @{
    Location  = @{ X = $Column5RightPosition
                   Y = $Column5DownPosition }
    Size      = @{ Width  = $Column5BoxWidth
                   Height = $Column5BoxHeight }
    Text      = 'RDP'
    Font      = New-Object System.Drawing.Font("$Font",11,0,2,1)
    ForeColor = "Black"
}
$ComputerListRDPButton.Add_Click({
    # This brings specific tabs to the forefront/front view
    $Section4TabControl.SelectedTab   = $Section3ResultsTab

    # This array stores checkboxes that are check; a minimum of at least one checkbox will be needed later in the script
    $ComputerListCheckedBoxesSelected = @()
    [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $ComputerListTreeView.Nodes 
    foreach ($root in $AllHostsNode) { 
        if ($root.Checked) {
            foreach ($Category in $root.Nodes) { foreach ($Entry in $Category.nodes) { $ComputerListCheckedBoxesSelected += $Entry.Text } }
        }
        foreach ($Category in $root.Nodes) { 
            if ($Category.Checked) {
                foreach ($Entry in $Category.nodes) { $ComputerListCheckedBoxesSelected += $Entry.Text }       
            }
            foreach ($Entry in $Category.nodes) {
                if ($Entry.Checked) {
                    $ComputerListCheckedBoxesSelected += $Entry.Text
                }
            }       
        }         
    }    
    $ResultsListBox.Items.Clear()
    if ($ComputerListCheckedBoxesSelected.count -eq 1) {
        $mstsc = mstsc /v:$($ComputerListCheckedBoxesSelected):3389
        $mstsc
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Remote Desktop:  $($script:ComputerListTreeViewSelected)")
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("mstsc /v:$($ComputerListCheckedBoxesSelected):3389")
        $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  Remote Desktop (RDP): $($script:ComputerListTreeViewSelected)"
        $LogMessage | Add-Content -Path $LogFile
    }
    elseif ($ComputerListCheckedBoxesSelected.count -eq 0) {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Remote Desktop:  Error")
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Error:  No hostname/IP selected")
        $ResultsListBox.Items.Add("        Make sure to checkbox only one hostname/IP")
        $ResultsListBox.Items.Add("        Selecting a Category will not allow you to connect to multiple hosts")
    }
    elseif ($ComputerListCheckedBoxesSelected.count -gt 1) {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Remote Desktop:  Error")
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Error:  Too many hostname/IPs selected")
        $ResultsListBox.Items.Add("        Make sure to checkbox only one hostname/IP")
        $ResultsListBox.Items.Add("        Selecting a Category will not allow you to connect to multiple hosts")    
    }
})
$ComputerListRDPButton.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ Will attempt to RDP into a single host.
⦿ Command:
        mstsc /v:<target>:3389`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage3))
        $ToolTip.Active         = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation   = $true
        $ToolTip.UseFading      = $true
        $ToolTip.IsBalloon      = $true
        $ToolTip.ToolTipIcon    = "Warning"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle   = 'Remote Desktop Connection'
    }    
})
$Section3ActionTab.Controls.Add($ComputerListRDPButton) 

$Column5DownPosition += $Column5DownPositionShift

#============================================================================================================================================================
# Computer List - PS Session Button
#============================================================================================================================================================
$ComputerListPSSessionButton = New-Object System.Windows.Forms.Button -Property @{
    Location  = @{ X = $Column5RightPosition
                   Y = $Column5DownPosition }
    Size      = @{ Width  = $Column5BoxWidth
                   Height = $Column5BoxHeight }
    Text      = "PS Session"
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Black"
}
$ComputerListPSSessionButton.Add_Click({
    # This brings specific tabs to the forefront/front view
    $Section4TabControl.SelectedTab   = $Section3ResultsTab

    # This array stores checkboxes that are check; a minimum of at least one checkbox will be needed later in the script
    $ComputerListCheckedBoxesSelected = @()
    [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $ComputerListTreeView.Nodes 
    foreach ($root in $AllHostsNode) { 
        if ($root.Checked) {
            foreach ($Category in $root.Nodes) { foreach ($Entry in $Category.nodes) { $ComputerListCheckedBoxesSelected += $Entry.Text } }
        }
        foreach ($Category in $root.Nodes) { 
            if ($Category.Checked) {
                foreach ($Entry in $Category.nodes) { $ComputerListCheckedBoxesSelected += $Entry.Text }       
            }
            foreach ($Entry in $Category.nodes) {
                if ($Entry.Checked) {
                    $ComputerListCheckedBoxesSelected += $Entry.Text
                }
            }       
        }         
    }   
    $ResultsListBox.Items.Clear()
    if ($ComputerListCheckedBoxesSelected.count -eq 1) {        
        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$script:Credential) { $script:Credential = Get-Credential }
            Start-Process PowerShell -ArgumentList "-noexit Enter-PSSession -ComputerName $ComputerListCheckedBoxesSelected -Credential (Get-Credential)"
        }
        else {
            Start-Process PowerShell -ArgumentList "-noexit Enter-PSSession -ComputerName $ComputerListCheckedBoxesSelected" 
        }
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Enter-PSSession:  $($script:ComputerListTreeViewSelected)")
        $ResultsListBox.Items.Clear()
        if ($script:Credential) { $ResultsListBox.Items.Add("Enter-PSSession -ComputerName $SelectedComputer -Credential (Get-Credential)") }
        else { $ResultsListBox.Items.Add("Enter-PSSession -ComputerName $SelectedComputer") }
        $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  Enter-PSSession: $($script:ComputerListTreeViewSelected)"
        $LogMessage | Add-Content -Path $LogFile
    }
     elseif ($ComputerListCheckedBoxesSelected.count -eq 0) {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Enter-PSSession:  Error")
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Error:  No hostname/IP selected")
        $ResultsListBox.Items.Add("        Make sure to checkbox only one hostname/IP")
        $ResultsListBox.Items.Add("        Selecting a Category will not allow you to connect to multiple hosts")    
    }
    elseif ($ComputerListCheckedBoxesSelected.count -gt 1) {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Enter-PSSession:  Error")
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Error:  Too many hostname/IPs selected")
        $ResultsListBox.Items.Add("        Make sure to checkbox only one hostname/IP")
        $ResultsListBox.Items.Add("        Selecting a Category will not allow you to connect to multiple hosts")    
    }
})
$ComputerListPSSessionButton.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ Starts an interactive session with a remote computer.
⦿ Requires the WinRM service.
⦿ To use with an IP address, the Credential parameter must be used.
Also, the computer must be configured for HTTPS transport or
the remote computer's IP must be in the local TrustedHosts.
⦿ Command:
        Enter-PSSession -ComputerName <target>`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage3))
        $ToolTip.Active         = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation   = $true
        $ToolTip.UseFading      = $true
        $ToolTip.IsBalloon      = $true
        $ToolTip.ToolTipIcon    = "Warning"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle   = 'Enter-PSSession'
    }    
})
$Section3ActionTab.Controls.Add($ComputerListPSSessionButton) 

$Column5DownPosition += $Column5DownPositionShift

#============================================================================================================================================================
# Computer List - PsExec Button
#============================================================================================================================================================
$ComputerListPsExecButton = New-Object System.Windows.Forms.Button -Property @{
    Location  = @{ X = $Column5RightPosition
                   Y = $Column5DownPosition }
    Size      = @{ Width  = $Column5BoxWidth
                   Height = $Column5BoxHeight }
    Text      = "PsExec"
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Black"
}
$ComputerListPsExecButton.Add_Click({
    # This brings specific tabs to the forefront/front view
    $Section4TabControl.SelectedTab   = $Section3ResultsTab

    if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
        if (!$script:Credential) { $script:Credential = Get-Credential }
        $Username = $script:Credential.UserName
        $Password = $script:Credential.GetNetworkCredential().Password
        $UseCredential = "-u $Username -p $Password"
    }
    else { $script:Credentials = "" }

    # This array stores checkboxes that are check; a minimum of at least one checkbox will be needed later in the script
    $ComputerListCheckedBoxesSelected = @()
    [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $ComputerListTreeView.Nodes 
    foreach ($root in $AllHostsNode) { 
        if ($root.Checked) {
            foreach ($Category in $root.Nodes) { foreach ($Entry in $Category.nodes) { $ComputerListCheckedBoxesSelected += $Entry.Text } }
        }
        foreach ($Category in $root.Nodes) { 
            if ($Category.Checked) {
                foreach ($Entry in $Category.nodes) { $ComputerListCheckedBoxesSelected += $Entry.Text }       
            }
            foreach ($Entry in $Category.nodes) {
                if ($Entry.Checked) {
                    $ComputerListCheckedBoxesSelected += $Entry.Text
                }
            }       
        }         
    }   
    $ResultsListBox.Items.Clear()
    if ($ComputerListCheckedBoxesSelected.count -eq 1) {
        Start-Process PowerShell -WindowStyle Hidden -ArgumentList "Start-Process '$PsExecPath' -ArgumentList '-accepteula -s \\$ComputerListCheckedBoxesSelected $UseCredential cmd'"

        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("PsExec:  $($script:ComputerListTreeViewSelected)")
        $ResultsListBox.Items.Clear()
        if ($script:Credential) { $ResultsListBox.Items.Add("./PsExec.exe -accepteula -s \\$ComputerListCheckedBoxesSelected -u '<domain\username>' -p '<password>' cmd") }
        else { $ResultsListBox.Items.Add("./PsExec.exe -accepteula -s \\$ComputerListCheckedBoxesSelected cmd") }
        $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  PsExec: $($script:ComputerListTreeViewSelected)"
        $LogMessage | Add-Content -Path $LogFile
    }
    elseif ($ComputerListCheckedBoxesSelected.count -eq 0) {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("PsExec:  Error")
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Error:  No hostname/IP selected")
        $ResultsListBox.Items.Add("        Make sure to checkbox only one hostname/IP")
        $ResultsListBox.Items.Add("        Selecting a Category will not allow you to connect to multiple hosts")    
    }
    elseif ($ComputerListCheckedBoxesSelected.count -gt 1) {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("PsExec:  Error")
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Error:  Too many hostname/IPs selected")
        $ResultsListBox.Items.Add("        Make sure to checkbox only one hostname/IP")
        $ResultsListBox.Items.Add("        Selecting a Category will not allow you to connect to multiple hosts")    
    }
})
$ComputerListPsExecButton.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ Will attempt to obtain a cmd prompt via PsExec.`n⦿ PsExec is a Windows Sysinternals tool.`n⦿ Some anti-virus scanners will alert on this.
⦿ Command:
        PsExec.exe -accepteula -s \\<target> -u <domain\username> -p <password> cmd`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage3))
        $ToolTip.Active         = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation   = $true
        $ToolTip.UseFading      = $true
        $ToolTip.IsBalloon      = $true
        $ToolTip.ToolTipIcon    = "Warning"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle   = 'PsExec'
    }    
})
# Test if the External Programs directory is present; if it's there load the tab
if (Test-Path "$ExternalPrograms\PsExec.exe") { $Section3ActionTab.Controls.Add($ComputerListPsExecButton) }

$Column5DownPosition += $Column5DownPositionShift

<#
#============================================================================================================================================================
# Computer List - Provide Creds Checkbox
#============================================================================================================================================================

$ComputerListProvideCredentialsCheckBox = New-Object System.Windows.Forms.CheckBox -Property @{
    Location = @{ X = $Column5RightPosition + 1
                  Y = $Column5DownPosition + 3 }
    Size     = @{ Width  = $Column5BoxWidth
                  Height = $Column5BoxHeight - 5 }
    Name     = "Use Credentials"
    Text     = "Use Credentials"
    Checked  = $false
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$ComputerListProvideCredentialsCheckBox.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ Credentials are stored as a SecureString.
⦿ If checked, credentials are applied to supported commands.`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage3))
        $ToolTip.Active         = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation   = $true
        $ToolTip.UseFading      = $true
        $ToolTip.IsBalloon      = $true
        $ToolTip.ToolTipIcon    = "Info"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle   = 'Use Credentials'
    }    
})
$Section3ActionTab.Controls.Add($ComputerListProvideCredentialsCheckBox)

$Column5DownPosition += $Column5DownPositionShift

#============================================================================================================================================================
# Provide Creds Button
#============================================================================================================================================================
$ProvideCredsButton = New-Object System.Windows.Forms.Button -Property @{
    Location = @{ X = $Column5RightPosition
                  Y = $Column5DownPosition - 3 }
    Size     = @{ Width  = $Column5BoxWidth
                  Height = $Column5BoxHeight }
    Name     = "Provide Creds"
    Text     = "Provide Creds"
    Font = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
#$ProvideCredsButton.UseVisualStyleBackColor = $True
$ProvideCredsButton.Add_Click({
    # This brings specific tabs to the forefront/front view
    $Section4TabControl.SelectedTab   = $Section3ResultsTab

    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Provide Credentials:")

    $script:Credential = Get-Credential
    $ComputerListProvideCredentialsCheckBox.Checked = $True

    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Provide Credentials: Stored")
    $ResultsListBox.Items.Clear()
})
$ProvideCredsButton.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ Credentials are stored as a SecureString.
⦿ If checked, credentials are applied to supported commands.`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage3))
        $ToolTip.Active       = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation = $true
        $ToolTip.UseFading    = $true
        $ToolTip.IsBalloon    = $true
        $ToolTip.ToolTipIcon  = "Info"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle = 'Use Credentials'
    }    
})
$Section3ActionTab.Controls.Add($ProvideCredsButton)
#>
$Column5DownPosition += $Column5DownPositionShift + $Column5DownPositionShift + 17

#============================================================================================================================================================
# Execute Button
#============================================================================================================================================================
$ComputerListExecuteButton1 = New-Object System.Windows.Forms.Button -Property @{
    Location  = @{ X = $Column5RightPosition
                   Y = $Column5DownPosition }
    Size      = @{ Width  = $Column5BoxWidth
                   Height = $Column5BoxHeight * 2 }
    Name      = "Start`nCollection"
    Text      = "Start`nCollection"
    #UseVisualStyleBackColor = $True
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Red"
}
$ComputerListExecuteButton1.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ Starts the collection process.
⦿ All checked commands are executed against all checked hosts.
⦿ Be sure to verify selections before execution.
⦿ All queries to targets are logged with timestamps.
⦿ Results are stored in CSV format.`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage3))
        $ToolTip.Active         = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation   = $true
        $ToolTip.UseFading      = $true
        $ToolTip.IsBalloon      = $true
        $ToolTip.ToolTipIcon    = "Warning"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle   = 'Start Collection'
    }    
})
### $ComputerListExecuteButton1.Add_Click($ExecuteScriptHandler) ### Is located lower in the script
$Section3ActionTab.Controls.Add($ComputerListExecuteButton1)

#===================================================================================
#     __  ___                                __    _      __     ______      __  
#    /  |/  /___ _____  ____ _____ ____     / /   (_)____/ /_   /_  __/___ _/ /_ 
#   / /|_/ / __ `/ __ \/ __ `/ __ `/ _ \   / /   / / ___/ __/    / / / __ `/ __ \
#  / /  / / /_/ / / / / /_/ / /_/ /  __/  / /___/ (__  ) /_     / / / /_/ / /_/ /
# /_/  /_/\__,_/_/ /_/\__,_/\__, /\___/  /_____/_/____/\__/    /_/  \__,_/_.___/ 
#                          /____/                                                
#===================================================================================

##############################################################################################################################################################
##
## Section 3 - Manage List Tab
##
##############################################################################################################################################################

$Section3ManageListTab = New-Object System.Windows.Forms.TabPage -Property @{
    Location  = @{ X = $Column5RightPosition
                   Y = $Column5DownPosition }
    Size      = @{ Width  = $Column5BoxWidth
                   Height = $Column5BoxHeight }
    Text      = "Manage List"
    UseVisualStyleBackColor = $True
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$Section3TabControl.Controls.Add($Section3ManageListTab)

#####################################################################################################################################
## Section 3 Computer List - Control Tab Buttons
#####################################################################################################################################

$Column5DownPosition = $Column5DownPositionStart

#============================================================================================================================================================
# Computer List - Treeview - Deselect All Button
#============================================================================================================================================================
$ComputerListDeselectAllButton           = New-Object System.Windows.Forms.Button
$ComputerListDeselectAllButton.Location  = New-Object System.Drawing.Point($Column5RightPosition,$Column5DownPosition)
$ComputerListDeselectAllButton.Size      = New-Object System.Drawing.Size($Column5BoxWidth,$Column5BoxHeight)
$ComputerListDeselectAllButton.Text      = 'Deselect All'
$ComputerListDeselectAllButton.Add_Click({
    #$ComputerListTreeView.Nodes.Clear()
    [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $ComputerListTreeView.Nodes 
    foreach ($root in $AllHostsNode) { 
        if ($root.Checked) { $root.Checked = $false }
        foreach ($Category in $root.Nodes) { 
            if ($Category.Checked) { $Category.Checked = $false }
            foreach ($Entry in $Category.nodes) { 
                if ($Entry.Checked) { $Entry.Checked = $false }
                    $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",10,1,1,1)
                    $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,0,0)
                    $Category.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
                    $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
            }
        }
    }
})
$ComputerListDeselectAllButton.Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
$Section3ManageListTab.Controls.Add($ComputerListDeselectAllButton) 

$Column5DownPosition += $Column5DownPositionShift

#============================================================================================================================================================
# Computer List - Treeview - Collapse / Expand Button
#============================================================================================================================================================
$ComputerListTreeViewCollapseAllButton          = New-Object System.Windows.Forms.Button
$ComputerListTreeViewCollapseAllButton.Location = New-Object System.Drawing.Point($Column5RightPosition,$Column5DownPosition)
$ComputerListTreeViewCollapseAllButton.Size     = New-Object System.Drawing.Size($Column5BoxWidth,$Column5BoxHeight)
$ComputerListTreeViewCollapseAllButton.Text     = "Collapse"
$ComputerListTreeViewCollapseAllButton.Add_Click({
<#    $ComputerListTreeViewFound = $ComputerListTreeView.Nodes.Find("WIN81-01", $true)
    $ResultsListBox.Items.Clear()
    [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $ComputerListTreeView.Nodes 
            foreach ($Node in $ComputerListTreeViewFound) { 
                $ResultsListBox.Items.Add($Node.Text)
            }       
    $ResultsListBox.Items.Add("")#>
    if ($ComputerListTreeViewCollapseAllButton.Text -eq "Collapse") {
        $ComputerListTreeView.CollapseAll()
        [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $ComputerListTreeView.Nodes 
        foreach ($root in $AllHostsNode) { 
            $root.Expand()
        }
        $ComputerListTreeViewCollapseAllButton.Text = "Expand"
    }
    elseif ($ComputerListTreeViewCollapseAllButton.Text -eq "Expand") {
        $ComputerListTreeView.ExpandAll()
        $ComputerListTreeViewCollapseAllButton.Text = "Collapse"
    }

})
$ComputerListTreeViewCollapseAllButton.Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
$Section3ManageListTab.Controls.Add($ComputerListTreeViewCollapseAllButton) 

$Column5DownPosition += $Column5DownPositionShift

#============================================================================================================================================================
# ComputerList TreeView - Import .csv Button
#============================================================================================================================================================
$ComputerListTreeViewImportCsvButton = New-Object System.Windows.Forms.Button -Property @{
    Location  = @{ X = $Column5RightPosition
                   Y = $Column5DownPosition
                 }
    Size      = @{ Width  = 110
                   Height = 22
                 }
    Name      = "Import .csv"
    Text      = "Import .csv"
    UseVisualStyleBackColor = $True
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Green"
}
$ComputerListTreeViewImportCsvButton.Add_Click({
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    $ComputerListTreeViewImportCsvOpenFileDialog                  = New-Object System.Windows.Forms.OpenFileDialog -Property @{
        Title            = "Import .csv Data"
        InitialDirectory = "$PoShHome"
        filter           = "CSV (*.csv)| *.csv|Excel (*.xlsx)| *.xlsx|Excel (*.xls)| *.xls|All files (*.*)|*.*"
        ShowHelp         = $true
    }
    $ComputerListTreeViewImportCsvOpenFileDialog.ShowDialog() | Out-Null
    $ComputerListTreeViewImportCsv    = Import-Csv $($ComputerListTreeViewImportCsvOpenFileDialog.filename) | Select-Object -Property Name, IPv4Address, MACAddress, OperatingSystem, CanonicalName | Sort-Object -Property CanonicalName

    $StatusListBox.Items.Clear()
    $ResultsListBox.Items.Clear()
    
    # Imports data
    foreach ($Computer in $ComputerListTreeViewImportCsv) {
        # Checks if data already exists
        if ($script:ComputerListTreeViewData.Name -contains $Computer.Name) {
            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("Import .csv:  Warning")
            $ResultsListBox.Items.Add("$($Computer.Name) already exists with the following data:")
            $ResultsListBox.Items.Add("- OU/CN: $($($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $Computer.Name}).CanonicalName)")
            $ResultsListBox.Items.Add("- OS:    $($($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $Computer.Name}).OperatingSystem)")
            $ResultsListBox.Items.Add("- IP:    $($($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $Computer.Name}).IPv4Address)")
            $ResultsListBox.Items.Add("- MAC:   $($($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $Computer.Name}).MACAddress)")
            $ResultsListBox.Items.Add("")
        }
        else {
            if ($ComputerListTreeViewOSHostnameRadioButton.Checked) {
                if ($Computer.OperatingSystem -eq "") {
                    Add-ComputerNode -RootNode $script:TreeNodeComputerList -Category 'Unknown' -Entry $Computer.Name -ToolTip $Computer.IPv4Address
                }
                else {
                    Add-ComputerNode -RootNode $script:TreeNodeComputerList -Category $Computer.OperatingSystem -Entry $Computer.Name -ToolTip $Computer.IPv4Address
                }
            }
            elseif ($ComputerListTreeViewOUHostnameRadioButton.Checked) {
                $CanonicalName = $($($Computer.CanonicalName) -replace $Computer.Name,"" -replace $Computer.CanonicalName.split('/')[0],"").TrimEnd("/")
                if ($Computer.CanonicalName -eq "") {
                    Add-ComputerNode -RootNode $script:TreeNodeComputerList -Category '/Unknown' -Entry $Computer.Name -ToolTip $Computer.IPv4Address
                }
                else {
                    Add-ComputerNode -RootNode $script:TreeNodeComputerList -Category $CanonicalName -Entry $Computer.Name -ToolTip $Computer.IPv4Address
                }
            }
            $script:ComputerListTreeViewData += $Computer
        }
    }
    $ComputerListTreeView.ExpandAll()
    Populate-ComputerListTreeViewDefaultData
    TempSave-HostData
})
$Section3ManageListTab.Controls.Add($ComputerListTreeViewImportCsvButton)

$Column5DownPosition += $Column5DownPositionShift

#============================================================================================================================================================
# ComputerList TreeView - Import .txt Button
#============================================================================================================================================================
$ComputerListTreeViewImportTxtButton = New-Object System.Windows.Forms.Button -Property @{
    Location                = @{ X = $Column5RightPosition
                                 Y = $Column5DownPosition }
    Size                    = @{ Width  = 110
                                 Height = 22 }
    Name                    = "Import .txt"
    Text                    = "Import .txt"
    UseVisualStyleBackColor = $True
    Font                    = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor               = "Green"
}
$ComputerListTreeViewImportTxtButton.Add_Click({
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    $ComputerListTreeViewImportTxtOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{
        Title            = "Import .txt Data"
        InitialDirectory = "$PoShHome"
        filter           = "TXT (*.txt)| *.txt|All files (*.*)|*.*"
        ShowHelp         = $true
    }
    $ComputerListTreeViewImportTxtOpenFileDialog.ShowDialog()     | Out-Null    
    $ComputerListTreeViewImportTxt = Import-Csv $($ComputerListTreeViewImportTxtOpenFileDialog.filename) -Header Name, OperatingSystem, CanonicalName, IPv4Address
    $ComputerListTreeViewImportTxt | Export-Csv $ComputerListTreeViewFileTemp -NoTypeInformation -Append
    $ComputerListTreeViewImportCsv = Import-Csv $ComputerListTreeViewFileTemp | Select-Object -Property Name, IPv4Address, OperatingSystem, CanonicalName

    $StatusListBox.Items.Clear()
    $ResultsListBox.Items.Clear()

    # Imports Data
    foreach ($Computer in $ComputerListTreeViewImportCsv) {
        # Checks if the data already exists
        if ($script:ComputerListTreeViewData.Name -contains $Computer.Name) {
            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("Import .csv:  Warning")
            $ResultsListBox.Items.Add("$($Computer.Name) already exists with the following data:")
            $ResultsListBox.Items.Add("- OU/CN: $($($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $Computer.Name}).CanonicalName)")
            $ResultsListBox.Items.Add("- OS:    $($($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $Computer.Name}).OperatingSystem)")
            $ResultsListBox.Items.Add("- IP:    $($($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $Computer.Name}).IPv4Address)")
            $ResultsListBox.Items.Add("- MAC:   $($($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $Computer.Name}).MACAddress)")
            $ResultsListBox.Items.Add("")        }
        else {
            if ($ComputerListTreeViewOSHostnameRadioButton.Checked) {
                if ($Computer.OperatingSystem -eq "") {
                    Add-ComputerNode -RootNode $script:TreeNodeComputerList -Category 'Unknown' -Entry $Computer.Name #-ToolTip $Computer.IPv4Address
                }
                else {
                    Add-ComputerNode -RootNode $script:TreeNodeComputerList -Category $Computer.OperatingSystem -Entry $Computer.Name #-ToolTip $Computer.IPv4Address
                }
            }
            elseif ($ComputerListTreeViewOUHostnameRadioButton.Checked) {
                $CanonicalName = $($($Computer.CanonicalName) -replace $Computer.Name,"" -replace $Computer.CanonicalName.split('/')[0],"").TrimEnd("/")
                if ($Computer.CanonicalName -eq "") {
                    Add-ComputerNode -RootNode $script:TreeNodeComputerList -Category '/Unknown' -Entry $Computer.Name #-ToolTip $Computer.IPv4Address
                }
                else {
                    Add-ComputerNode -RootNode $script:TreeNodeComputerList -Category $CanonicalName -Entry $Computer.Name #-ToolTip $Computer.IPv4Address
                }
            }
            $script:ComputerListTreeViewData += $Computer
        }
    }
    $ComputerListTreeView.ExpandAll()
    Populate-ComputerListTreeViewDefaultData
    TempSave-HostData
    Remove-Item $ComputerListTreeViewFileTemp
})
$Section3ManageListTab.Controls.Add($ComputerListTreeViewImportTxtButton)

$Column5DownPosition += $Column5DownPositionShift

#============================================================================================================================================================
# Computer List - Treeview - Add Button
#============================================================================================================================================================

#---------------------------------------------
# function to add a hostname/IP to a category
#---------------------------------------------
function AddHost-ComputerListTreeView {
    if (($ComputerListTreeViewPopupAddTextBox.Text -eq "Enter a hostname/IP") -or ($ComputerListTreeViewPopupOSComboBox.Text -eq "Select an Operating System (or type in a new one)") -or ($ComputerListTreeViewPopupOUComboBox.Text -eq "Select an Organizational Unit / Canonical Name (or type a new one)")) {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Add Hostname/IP:  Error")
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Error:  Enter a suitable non-default value")
    }
    elseif ($script:ComputerListTreeViewData.Name -contains $ComputerListTreeViewPopupAddTextBox.Text) {
        #$script:ComputerListTreeViewData = $script:ComputerListTreeViewData | Where-Object {$_.Name -ne $Entry.text}
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Add Hostname/IP:  Error")
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Error: $($ComputerListTreeViewPopupAddTextBox.Text) already exists with the following data:")
        $ResultsListBox.Items.Add("- OU/CN: $($($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $ComputerListTreeViewPopupAddTextBox.Text}).CanonicalName)")
        $ResultsListBox.Items.Add("- OS:    $($($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $ComputerListTreeViewPopupAddTextBox.Text}).OperatingSystem)")
        $ResultsListBox.Items.Add("- IP:    $($($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $ComputerListTreeViewPopupAddTextBox.Name}).IPv4Address)")
        $ResultsListBox.Items.Add("- MAC:   $($($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $ComputerListTreeViewPopupAddTextBox.Name}).MACAddress)")
    }
    else {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Added Selection:  $($ComputerListTreeViewPopupAddTextBox.Text)")

        if ($ComputerListTreeViewOSHostnameRadioButton.Checked) {
            Add-ComputerNode -RootNode $script:TreeNodeComputerList -Category $ComputerListTreeViewPopupOSComboBox.Text -Entry $ComputerListTreeViewPopupAddTextBox.Text #-ToolTip "No Data Available"
            $ResultsListBox.Items.Clear()
            $ResultsListBox.Items.Add("$($ComputerListTreeViewPopupAddTextBox.Text) has been added to $($ComputerListTreeViewPopupOSComboBox.Text)")
        }
        elseif ($ComputerListTreeViewOUHostnameRadioButton.Checked) {
            Add-ComputerNode -RootNode $script:TreeNodeComputerList -Category $ComputerListTreeViewPopupOUComboBox.SelectedItem -Entry $ComputerListTreeViewPopupAddTextBox.Text #-ToolTip "No Data Available"            
            $ResultsListBox.Items.Clear()
            $ResultsListBox.Items.Add("$($ComputerListTreeViewPopupAddTextBox.Text) has been added to $($ComputerListTreeViewPopupOUComboBox.Text)")
        }       
        $ComputerListTreeViewAddHostnameIP = New-Object PSObject -Property @{ 
            Name            = $ComputerListTreeViewPopupAddTextBox.Text
            OperatingSystem = $ComputerListTreeViewPopupOSComboBox.Text
            CanonicalName   = $ComputerListTreeViewPopupOUComboBox.Text
            IPv4Address     = "No IP Available"
        }        
        $script:ComputerListTreeViewData += $ComputerListTreeViewAddHostnameIP
        $ComputerListTreeView.ExpandAll()
        $ComputerListTreeViewPopup.close()
    }
}

#----------------------------------
# ComputerList TreeView Add Button
#----------------------------------
$ComputerListTreeViewAddHostnameIPButton = New-Object System.Windows.Forms.Button -Property @{
    Location  = New-Object System.Drawing.Point($Column5RightPosition,$Column5DownPosition)
    Size      = New-Object System.Drawing.Size($Column5BoxWidth,$Column5BoxHeight)
    Text      = "Add"
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Green"
}
$ComputerListTreeViewAddHostnameIPButton.Add_Click({
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Add hostname/IP:")
    $ResultsListBox.Items.Clear()
    $ResultsListBox.Items.Add("Enter a hostname/IP")

    #----------------------------------
    # ComputerList TreeView Popup Form
    #----------------------------------
    $ComputerListTreeViewPopup = New-Object system.Windows.Forms.Form -Property @{
        Text          = "Add Hostname/IP"
        Size          = New-Object System.Drawing.Size(335,177)
        StartPosition = "CenterScreen"
        Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    #-----------------------------------------------------
    # ComputerList TreeView Popup Add Hostname/IP TextBox
    #-----------------------------------------------------
    $ComputerListTreeViewPopupAddTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Text     = "Enter a hostname/IP"
        Size     = New-Object System.Drawing.Size(300,25)
        Location = New-Object System.Drawing.Point(10,10)
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $ComputerListTreeViewPopupAddTextBox.Add_KeyDown({ 
        if ($_.KeyCode -eq "Enter") { AddHost-ComputerListTreeView }
    })
    $ComputerListTreeViewPopup.Controls.Add($ComputerListTreeViewPopupAddTextBox)

    #-----------------------------------------
    # ComputerList TreeView Popup OS ComboBox
    #-----------------------------------------
    $ComputerListTreeViewPopupOSComboBox  = New-Object System.Windows.Forms.ComboBox -Property @{
        Text               = "Select an Operating System (or type in a new one)"
        Size               = New-Object System.Drawing.Size(300,25)
        Location           = New-Object System.Drawing.Point(10,($ComputerListTreeViewPopupAddTextBox.Location.Y + $ComputerListTreeViewPopupAddTextBox.Size.Height + 10))
        AutoCompleteSource = "ListItems" # Options are: FileSystem, HistoryList, RecentlyUsedList, AllURL, AllSystemSources, FileSystemDirectories, CustomSource, ListItems, None
        AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
        Font               = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $ComputerListTreeViewOSCategoryList = $script:ComputerListTreeViewData | Select-Object -ExpandProperty OperatingSystem -Unique
    # Dynamically creates the OS Category combobox list used for OS Selection
    ForEach ($OS in $ComputerListTreeViewOSCategoryList) { $ComputerListTreeViewPopupOSComboBox.Items.Add($OS) }
    $ComputerListTreeViewPopup.Controls.Add($ComputerListTreeViewPopupOSComboBox)

    #-----------------------------------------
    # ComputerList TreeView Popup OU ComboBox
    #-----------------------------------------
    $ComputerListTreeViewPopupOUComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Text               = "Select an Organizational Unit / Canonical Name (or type a new one)"
        Size               = New-Object System.Drawing.Size(300,25)
        Location           = New-Object System.Drawing.Point(10,($ComputerListTreeViewPopupOSComboBox.Location.Y + $ComputerListTreeViewPopupOSComboBox.Size.Height + 10))        
        AutoCompleteSource = "ListItems" # Options are: FileSystem, HistoryList, RecentlyUsedList, AllURL, AllSystemSources, FileSystemDirectories, CustomSource, ListItems, None
        AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
        Font               = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $ComputerListTreeViewOUCategoryList = $script:ComputerListTreeViewData | Select-Object -ExpandProperty CanonicalName -Unique
    # Dynamically creates the OU Category combobox list used for OU Selection
    ForEach ($OU in $ComputerListTreeViewOUCategoryList) { $ComputerListTreeViewPopupOUComboBox.Items.Add($OU) }
    $ComputerListTreeViewPopup.Controls.Add($ComputerListTreeViewPopupOUComboBox)

    #--------------------------------------------
    # ComputerList TreeView Popup Execute Button
    #--------------------------------------------
    $ComputerListTreeViewPopupMoveButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Add Host"
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        Size     = New-Object System.Drawing.Size(100,25)
        Location = New-Object System.Drawing.Point(210,($ComputerListTreeViewPopupOUComboBox.Location.Y + $ComputerListTreeViewPopupOUComboBox.Size.Height + 10))
    }
    $ComputerListTreeViewPopupMoveButton.Add_Click({ AddHost-ComputerListTreeView })
    $ComputerListTreeViewPopup.Controls.Add($ComputerListTreeViewPopupMoveButton)

    $ComputerListTreeView.ExpandAll()
    Populate-ComputerListTreeViewDefaultData
    TempSave-HostData
    $ComputerListTreeViewPopup.ShowDialog()               
})
$Section3ManageListTab.Controls.Add($ComputerListTreeViewAddHostnameIPButton) 

$Column5DownPosition += $Column5DownPositionShift

#============================================================================================================================================================
# Computer List - Treeview - Delete Button
#============================================================================================================================================================
$ComputerListDeleteButton = New-Object System.Windows.Forms.Button -Property @{
    Location = New-Object System.Drawing.Point($Column5RightPosition,$Column5DownPosition)
    Size     = New-Object System.Drawing.Size($Column5BoxWidth,$Column5BoxHeight)
    Text     = 'Delete'
}
$ComputerListDeleteButton.Add_Click({
    # The array stores any node that is checked
    $ComputerListCheckedBoxesSelected = @()
    [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $ComputerListTreeView.Nodes 
    foreach ($root in $AllHostsNode) { 
        if ($root.Checked) { $ComputerListCheckedBoxesSelected += $root.Text }
        foreach ($Category in $root.Nodes) { 
            if ($Category.Checked) { $ComputerListCheckedBoxesSelected += $Category.Text }
            foreach ($Entry in $Category.nodes) {
                if ($Entry.Checked) { $ComputerListCheckedBoxesSelected += $Entry.Text }
            }       
        }         
    }

    if ($ComputerListCheckedBoxesSelected.count -gt 0) {
        # Removes selected computer nodes
        foreach ($i in $ComputerListCheckedBoxesSelected) {
            foreach ($root in $AllHostsNode) {
                foreach ($Category in $root.Nodes) { 
                    foreach ($Entry in $Category.nodes) { 
                        if (($i -eq $Entry.text) -and ($Entry.Checked)) {
                            # Removes the node from the treeview
                            $Entry.remove()
                            # Removes the host from the variable storing the all the computers
                            $script:ComputerListTreeViewData = $script:ComputerListTreeViewData | Where-Object {$_.Name -ne $Entry.text}
                        }
                    }
                }
            }
        }
        # Removes selected category nodes - Note: had to put this in its own loop... 
        # the saving of nodes didn't want to work properly when use in the above loop when switching between treenode views.
        foreach ($i in $ComputerListCheckedBoxesSelected) {
            foreach ($root in $AllHostsNode) {
                foreach ($Category in $root.Nodes) { 
                    if (($i -eq $Category.text) -and ($Category.Checked)) { $Category.remove() }
                }
            }
        }
        # Removes selected root node - Note: had to put this in its own loop... see above category note
        foreach ($i in $ComputerListCheckedBoxesSelected) {
            foreach ($root in $AllHostsNode) {                
                if (($i -eq $root.text) -and ($root.Checked)) {
                    foreach ($Category in $root.Nodes) { $Category.remove() }
                    $root.remove()
                    if ($i -eq "All Hosts") { $ComputerListTreeView.Nodes.Add($script:TreeNodeComputerList) }                                    
                }
            }
        }

        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Deleted:  $($ComputerListCheckedBoxesSelected.Count) Selected Items")
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("The following hostnames/IPs or categories have been deleted:  ")
        foreach ($n in $ComputerListCheckedBoxesSelected) { $ResultsListBox.Items.Add(" - $n") }

        Initialize-ComputerListTreeView
        Populate-ComputerListTreeViewDefaultData
        Check-CategoryIsEmpty
        TempSave-HostData
    }
    else {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Delete Selection:  Error")
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Error: No Category, hostname, or IP selected")
        $ResultsListBox.Items.Add("       Make sure to checkbox at least one hostname/IP or Category")
        $ResultsListBox.Items.Add("       Selecting a Category will remove contents within it")
    }
})
$ComputerListDeleteButton.Font = New-Object System.Drawing.Font("$Font",11,0,0,0)
$Section3ManageListTab.Controls.Add($ComputerListDeleteButton) 

$Column5DownPosition += $Column5DownPositionShift

#============================================================================================================================================================
# Computer List - Treeview - Move Button
#============================================================================================================================================================
$ComputerListMoveButton = New-Object System.Windows.Forms.Button -Property @{
    Location = New-Object System.Drawing.Point($Column5RightPosition,$Column5DownPosition)
    Size     = New-Object System.Drawing.Size($Column5BoxWidth,$Column5BoxHeight)
    Text     = 'Move'
}
$ComputerListMoveButton.Add_Click({
    # Creates a list of all the checkboxes selected
    $ComputerListCheckedBoxesSelected = @()
    [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $ComputerListTreeView.Nodes 
    foreach ($root in $AllHostsNode) { 
        foreach ($Category in $root.Nodes) { 
            foreach ($Entry in $Category.nodes) { 
                if ($Entry.Checked) {
                    $ComputerListCheckedBoxesSelected += $Entry.Text
                }
            }       
        }         
    }

    if ($ComputerListCheckedBoxesSelected.count -ge 1) {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Move Selection:  ")
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Select a Category to move the hostname/IP into")

        #----------------------------------
        # ComputerList TreeView Popup Form
        #----------------------------------
        $ComputerListTreeViewPopup = New-Object system.Windows.Forms.Form -Property @{
            Text          = "Move"
            Size          = New-Object System.Drawing.Size(330,107)
            StartPosition = "CenterScreen"
        }
        #----------------------------------------------
        # ComputerList TreeView Popup Execute ComboBox
        #----------------------------------------------
        $ComputerListTreeViewPopupMoveComboBox          = New-Object System.Windows.Forms.ComboBox -Property @{
            Text               = "Select A Category"
            Size               = New-Object System.Drawing.Size(300,25)
            Location           = New-Object System.Drawing.Point(10,10)
            AutoCompleteSource = "ListItems" # Options are: FileSystem, HistoryList, RecentlyUsedList, AllURL, AllSystemSources, FileSystemDirectories, CustomSource, ListItems, None
            AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
            Font               = New-Object System.Drawing.Font("$Font",11,0,0,0)
        }
        # Dynamically creates the combobox's Category list used for the move destination
        $ComputerListTreeViewCategoryList = @()
        [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $ComputerListTreeView.Nodes 
        ForEach ($root in $AllHostsNode) { foreach ($Category in $root.Nodes) { $ComputerListTreeViewCategoryList += $Category.text } }
        ForEach ($Item in $ComputerListTreeViewCategoryList) { $ComputerListTreeViewPopupMoveComboBox.Items.Add($Item) }

        # Moves the checkboxed nodes to the selected Category
        function Move-ComputerListTreeViewSelected {                       
            # Makes a copy of the checkboxed node name in the new Category
            $ComputerListTreeViewToMove = New-Object System.Collections.ArrayList

            function Copy-TreeViewNode {
                # Adds (copies) the node to the new Category
                [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $ComputerListTreeView.Nodes 
                foreach ($root in $AllHostsNode) { 
                    if ($root.Checked) { $root.Checked = $false }
                    foreach ($Category in $root.Nodes) { 
                        if ($Category.Checked) { $Category.Checked = $false }
                        foreach ($Entry in $Category.nodes) { 
                            if ($Entry.Checked) {
                                Add-ComputerNode -RootNode $script:TreeNodeComputerList -Category $ComputerListTreeViewPopupMoveComboBox.SelectedItem -Entry $Entry.text #-ToolTip "No Data Available"
                                $ComputerListTreeViewToMove.Add($Entry.text)
                            }
                        }
                    }
                }
            }
            if ($ComputerListTreeViewOSHostnameRadioButton.Checked) {
                Copy-TreeViewNode
                # Removes the original hostname/IP that was copied above
                foreach ($i in $ComputerListTreeViewToMove) {
                    foreach ($root in $AllHostsNode) { 
                        foreach ($Category in $root.Nodes) { 
                            foreach ($Entry in $Category.nodes) { 
                                if (($i -contains $Entry.text) -and ($Entry.Checked)) {
                                    $($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).OperatingSystem = $ComputerListTreeViewPopupMoveComboBox.SelectedItem
                                    $ResultsListBox.Items.Add($Entry.text)
                                    $Entry.remove()
                                }
                            }
                        }
                    }
                }
            }
            elseif ($ComputerListTreeViewOUHostnameRadioButton.Checked) {
                Copy-TreeViewNode                
                # Removes the original hostname/IP that was copied above
                foreach ($i in $ComputerListTreeViewToMove) {
                    foreach ($root in $AllHostsNode) { 
                        foreach ($Category in $root.Nodes) { 
                            foreach ($Entry in $Category.nodes) { 
                                if (($i -contains $Entry.text) -and ($Entry.Checked)) {
                                    $($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).CanonicalName = $ComputerListTreeViewPopupMoveComboBox.SelectedItem
                                    $ResultsListBox.Items.Add($Entry.text)
                                    $Entry.remove()
                                }
                            }
                        }
                    }
                }
            }
            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("Move Selection:  $($ComputerListTreeViewToMove.Count) Hosts")
            $ResultsListBox.Items.Clear()
            $ResultsListBox.Items.Add("The following hostnames/IPs have been moved to $($ComputerListTreeViewPopupMoveComboBox.SelectedItem):")
            foreach ($n in $ComputerListCheckedBoxesSelected) {
                $ResultsListBox.Items.Add(" - $n")
            }
            Check-CategoryIsEmpty
            $ComputerListTreeViewPopup.close()        
        }
        # Moves the hostname/IPs to the new Category
        $ComputerListTreeViewPopupMoveComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { Move-ComputerListTreeViewSelected } })
        $ComputerListTreeViewPopup.Controls.Add($ComputerListTreeViewPopupMoveComboBox)

        #--------------------------------------------
        # ComputerList TreeView Popup Execute Button
        #--------------------------------------------
        $ComputerListTreeViewPopupMoveButton = New-Object System.Windows.Forms.Button -Property @{
            Text     = "Execute"
            Size     = New-Object System.Drawing.Size(100,25)
            Location = New-Object System.Drawing.Point(210,($ComputerListTreeViewPopupMoveComboBox.Size.Height + 15))
            Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        }
        $ComputerListTreeViewPopupMoveButton.Add_Click({ Move-ComputerListTreeViewSelected })
        $ComputerListTreeViewPopup.Controls.Add($ComputerListTreeViewPopupMoveButton)
        $ComputerListTreeViewPopup.ShowDialog()               
    }
    else {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Move Selection:  Error")
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Error: No hostname/IP selected")
        $ResultsListBox.Items.Add("       Make sure to checkbox at least one hostname/IP")
        $ResultsListBox.Items.Add("       Selecting a Category will not move the contents within it")
    }
    TempSave-HostData
})
$ComputerListMoveButton.Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
$Section3ManageListTab.Controls.Add($ComputerListMoveButton) 

$Column5DownPosition += $Column5DownPositionShift

#============================================================================================================================================================
# Computer List - Treeview - Rename Button
#============================================================================================================================================================
$ComputerListRenameButton           = New-Object System.Windows.Forms.Button
$ComputerListRenameButton.Location  = New-Object System.Drawing.Point($Column5RightPosition,$Column5DownPosition)
$ComputerListRenameButton.Size      = New-Object System.Drawing.Size($Column5BoxWidth,$Column5BoxHeight)
$ComputerListRenameButton.Text      = 'Rename'
$ComputerListRenameButton.Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
$ComputerListRenameButton.Add_Click({
    # Creates a list of all the checkboxes selected
    $ComputerListCheckedBoxesSelected = @()
    [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $ComputerListTreeView.Nodes 
    foreach ($root in $AllHostsNode) { 
        foreach ($Category in $root.Nodes) { 
            foreach ($Entry in $Category.nodes) { 
                if ($Entry.Checked) {
                    $ComputerListCheckedBoxesSelected += $Entry.Text
                }
            }       
        }         
    }
    if ($ComputerListCheckedBoxesSelected.count -eq 1) {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Rename Selection:  ")
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Enter a new name:")

        #----------------------------------
        # ComputerList TreeView Popup Form
        #----------------------------------
        $ComputerListTreeViewRenamePopup               = New-Object system.Windows.Forms.Form
        $ComputerListTreeViewRenamePopup.Text          = "Rename $($script:ComputerListTreeViewSelected)"
        $ComputerListTreeViewRenamePopup.Size          = New-Object System.Drawing.Size(330,107)
        $ComputerListTreeViewRenamePopup.StartPosition = "CenterScreen"
        $ComputerListTreeViewRenamePopup.Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)

        #---------------------------------------------
        # ComputerList TreeView Popup Execute TextBox
        #---------------------------------------------
        $ComputerListTreeViewRenamePopupTextBox          = New-Object System.Windows.Forms.TextBox
        $ComputerListTreeViewRenamePopupTextBox.Text     = "New Hostname/IP"
        $ComputerListTreeViewRenamePopupTextBox.Size     = New-Object System.Drawing.Size(300,25)
        $ComputerListTreeViewRenamePopupTextBox.Location = New-Object System.Drawing.Point(10,10)
        $ComputerListTreeViewRenamePopupTextBox.Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)

        #-----------------------------------------
        # Function to rename the checkboxed nodes
        #-----------------------------------------
        function Rename-ComputerListTreeViewSelected {                       
            if ($script:ComputerListTreeViewData.Name -contains $ComputerListTreeViewRenamePopupTextBox.Text) {
                #$script:ComputerListTreeViewData = $script:ComputerListTreeViewData | Where-Object {$_.Name -ne $Entry.text}
                $StatusListBox.Items.Clear()
                $StatusListBox.Items.Add("Rename Hostname/IP:  Error")
                $ResultsListBox.Items.Clear()
                $ResultsListBox.Items.Add("$($ComputerListTreeViewRenamePopupTextBox.Text) already exists with the following data:")
                $ResultsListBox.Items.Add("- OU/CN: $($($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $ComputerListTreeViewRenamePopupTextBox.Text}).CanonicalName)")
                $ResultsListBox.Items.Add("- OS:    $($($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $ComputerListTreeViewRenamePopupTextBox.Text}).OperatingSystem)")
                $ResultsListBox.Items.Add("- IP:    $($($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $ComputerListTreeViewRenamePopupTextBox.Name}).IPv4Address)")
                $ResultsListBox.Items.Add("- MAC:   $($($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $ComputerListTreeViewRenamePopupTextBox.Name}).MACAddress)")
            }
            else {
                # Makes a copy of the checkboxed node name in the new Category
                $ComputerListTreeViewToRename = New-Object System.Collections.ArrayList

                # Adds (copies) the node to the new Category
                [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $ComputerListTreeView.Nodes 
                foreach ($root in $AllHostsNode) { 
                    if ($root.Checked) { $root.Checked = $false }
                    foreach ($Category in $root.Nodes) { 
                        if ($Category.Checked) { $Category.Checked = $false }
                        foreach ($Entry in $Category.nodes) { 
                            if ($Entry.Checked) {
                                Add-ComputerNode -RootNode $script:TreeNodeComputerList -Category $Category.Text -Entry $ComputerListTreeViewRenamePopupTextBox.text #-ToolTip "No Data Available"
                                $ComputerListTreeViewToRename.Add($Entry.text)
                            }
                        }
                    }
                }
                # Removes the original hostname/IP that was copied above
                foreach ($i in $ComputerListTreeViewToRename) {
                    foreach ($root in $AllHostsNode) { 
                        foreach ($Category in $root.Nodes) { 
                            foreach ($Entry in $Category.nodes) { 
                                if (($i -contains $Entry.text) -and ($Entry.Checked)) {
                                    $($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).Name = $ComputerListTreeViewRenamePopupTextBox.text
                                    $ResultsListBox.Items.Add($Entry.text)
                                    $Entry.remove()
                                }
                            }
                        }
                    }
                }
                $StatusListBox.Items.Clear()
                $StatusListBox.Items.Add("Rename Selection:  $($ComputerListTreeViewToRename.Count) Hosts")
                $ResultsListBox.Items.Clear()
                $ResultsListBox.Items.Add("The computer has been renamed to $($ComputerListTreeViewRenamePopupTextBox.Text)")
            }
            $ComputerListTreeViewRenamePopup.close()
        }           
           
        # Moves the hostname/IPs to the new Category
        $ComputerListTreeViewRenamePopupTextBox.Add_KeyDown({ 
            if ($_.KeyCode -eq "Enter") { Rename-ComputerListTreeViewSelected }
        })
        $ComputerListTreeViewRenamePopup.Controls.Add($ComputerListTreeViewRenamePopupTextBox)

        #--------------------------------------------
        # ComputerList TreeView Popup Execute Button
        #--------------------------------------------
        $ComputerListTreeViewRenamePopupButton          = New-Object System.Windows.Forms.Button
        $ComputerListTreeViewRenamePopupButton.Text     = "Execute"
        $ComputerListTreeViewRenamePopupButton.Size     = New-Object System.Drawing.Size(100,25)
        $ComputerListTreeViewRenamePopupButton.Location = New-Object System.Drawing.Point(210,($ComputerListTreeViewRenamePopupTextBox.Size.Height + 15))
        $ComputerListTreeViewRenamePopupButton.Add_Click({
            Rename-ComputerListTreeViewSelected
        })
        $ComputerListTreeViewRenamePopupButton.Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        $ComputerListTreeViewRenamePopup.Controls.Add($ComputerListTreeViewRenamePopupButton)

        $ComputerListTreeViewRenamePopup.ShowDialog()               
    }
    elseif ($ComputerListCheckedBoxesSelected.count -gt 1) {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Rename Selection:  Error")
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Error: Too many checkboxes selected")
        $ResultsListBox.Items.Add("       Make sure to checkbox only one hostname/IP")
    }
    elseif ($ComputerListCheckedBoxesSelected.count -lt 1) {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Rename Selection:  Error")
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Error: No hostname/IP selected")
        $ResultsListBox.Items.Add("       Make sure to checkbox at least one hostname/IP")
    }
    TempSave-HostData
})
$Section3ManageListTab.Controls.Add($ComputerListRenameButton) 

$Column5DownPosition += $Column5DownPositionShift

#============================================================================================================================================================
# Computer List - TreeView - Save Button
#============================================================================================================================================================
$ComputerListTreeViewSaveButton          = New-Object System.Windows.Forms.Button
$ComputerListTreeViewSaveButton.Location = New-Object System.Drawing.Point($Column5RightPosition,$Column5DownPosition)
$ComputerListTreeViewSaveButton.Size     = New-Object System.Drawing.Size($Column5BoxWidth,$Column5BoxHeight)
$ComputerListTreeViewSaveButton.Text     = "Save"
$ComputerListTreeViewSaveButton.Add_Click({
    Save-HostData
})
$ComputerListTreeViewSaveButton.Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
$Section3ManageListTab.Controls.Add($ComputerListTreeViewSaveButton) 

$Column5DownPosition += $Column5DownPositionShift + 17

#============================================================================================================================================================
# Execute Button
#============================================================================================================================================================
$ComputerListExecuteButton2           = New-Object System.Windows.Forms.Button
$ComputerListExecuteButton2.Name      = "Start`nCollection"
$ComputerListExecuteButton2.Text      = "$($ComputerListExecuteButton2.Name)"
$ComputerListExecuteButton2.UseVisualStyleBackColor = $True
$ComputerListExecuteButton2.Location  = New-Object System.Drawing.Point($Column5RightPosition,$Column5DownPosition)
$ComputerListExecuteButton2.Size      = New-Object System.Drawing.Size($Column5BoxWidth,($Column5BoxHeight * 2))
$ComputerListExecuteButton2.ForeColor = "Red"
### $ComputerListExecuteButton2.Add_Click($ExecuteScriptHandler) ### Is located lower in the script
$ComputerListExecuteButton2.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ Starts the collection process.
⦿ All checked commands are executed against all checked hosts.
⦿ Be sure to verify selections before execution.
⦿ All queries to targets are logged with timestamps.
⦿ Results are stored in CSV format.`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage3))
        $ToolTip.Active         = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation   = $true
        $ToolTip.UseFading      = $true
        $ToolTip.IsBalloon      = $true
        $ToolTip.ToolTipIcon    = "Warning"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle   = 'Start Collection'
    }    
})
$ComputerListExecuteButton2.Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
$Section3ManageListTab.Controls.Add($ComputerListExecuteButton2)

##############################################################################################################################################################
##############################################################################################################################################################
##############################################################################################################################################################
##
## Section 3 Bottom Area
##
##############################################################################################################################################################
##############################################################################################################################################################
##############################################################################################################################################################

# Variables
$Section3RightPosition     = 470
$Section3DownPosition      = 238
$Section3ProgressBarWidth  = 308
$Section3ProgressBarHeight = 22
$Section3DownPositionShift = 25
$Section3ResultsTabWidth   = 738
$Section3ResultsTabHeight  = 250

$Section3DownPosition += $Section3DownPositionShift
$Section3DownPosition += $Section3DownPositionShift

#--------------
# Status Label
#--------------
$StatusLabel = New-Object System.Windows.Forms.Label -Property @{
    Location  = New-Object System.Drawing.Point(($Section3RightPosition),($Section3DownPosition + 1))
    Size      = New-Object System.Drawing.Size(60,($Section3ProgressBarHeight - 2))
    Text      = "Status:"
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Blue"
}
$PoShACME.Controls.Add($StatusLabel)  

#----------------
# Status Listbox
#----------------
$StatusListBox = New-Object System.Windows.Forms.ListBox -Property @{
    Name              = "StatusListBox"
    Location          = New-Object System.Drawing.Point(($Section3RightPosition + 60),$Section3DownPosition) 
    Size              = New-Object System.Drawing.Size($Section3ProgressBarWidth,$Section3ProgressBarHeight)
    Font              = New-Object System.Drawing.Font("$Font",11,0,0,0)
    FormattingEnabled = $True
}
$StatusListBox.Items.Add("") | Out-Null
$PoShACME.Controls.Add($StatusListBox)

$Section3DownPosition += $Section3DownPositionShift

# ---------------------
# Progress Bar 1 Label
#----------------------
$ProgressBarSectionLabel = New-Object System.Windows.Forms.Label -Property @{
    Location = New-Object System.Drawing.Point(($Section3RightPosition),($Section3DownPosition - 4))
    Size     = New-Object System.Drawing.Size(60,($Section3ProgressBarHeight - 7))
    Text     = "Section:"
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$PoShACME.Controls.Add($ProgressBarSectionLabel)  

#----------------------------
# Progress Bar 1 ProgressBar
#----------------------------
$ProgressBarSection = New-Object System.Windows.Forms.ProgressBar -Property @{
    Style    = "Continuous"
    #Maximum = 10
    Minimum  = 0
    Location = new-object System.Drawing.Point(($Section3RightPosition + 60),($Section3DownPosition - 2))
    size     = new-object System.Drawing.Size($Section3ProgressBarWidth,10)
    #Value   = 0
    #Step    = 1
}
$PoSHACME.Controls.Add($ProgressBarSection)

$Section3DownPosition += $Section3DownPositionShift - 9

#----------------------
# Progress Bar 2 Label
#----------------------
$ProgressBarOverallLabel = New-Object System.Windows.Forms.Label -Property @{
    Location = New-Object System.Drawing.Point(($Section3RightPosition),($Section3DownPosition - 4))
    Size     = New-Object System.Drawing.Size(60,($Section3ProgressBarHeight - 4))
    Text     = "Overall:"
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$PoShACME.Controls.Add($ProgressBarOverallLabel)  

#----------------------------
# Progress Bar 2 ProgressBar
#----------------------------
$ProgressBarOverall = New-Object System.Windows.Forms.ProgressBar -Property @{
    Location = @{ X = $Section3RightPosition + 60
                  Y = $Section3DownPosition - 2
                }
    Size     = @{ Width  = $Section3ProgressBarWidth
                  Height = 10
                }
    #Value   = 0
    Style    = "Continuous"
    #Maximum = 10
    Minimum  = 0
    #Step    = 1
    #Count   = 0
}
$PoSHACME.Controls.Add($ProgressBarOverall)
$Section3DownPosition += $Section3DownPositionShift - 9

##############################################################################################################################################################
##############################################################################################################################################################
##
## Section 3 Tab Control
##
##############################################################################################################################################################
##############################################################################################################################################################

$Section4TabControl = New-Object System.Windows.Forms.TabControl -Property @{
    Name     = "Main Tab Window"
    Location = @{ X = $Section3RightPosition
                  Y = $Section3DownPosition
                }
    Size     = @{ Width  = $Section3ResultsTabWidth
                  Height = $Section3ResultsTabHeight
                }
    SelectedIndex = 0
    ShowToolTips  = $True
    Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$PoShACME.Controls.Add($Section4TabControl)

#============================================================
#     ____                  ____          ______      __  
#    / __ \___  _______  __/ / /______   /_  __/___ _/ /_ 
#   / /_/ / _ \/ ___/ / / / / __/ ___/    / / / __ `/ __ \
#  / _, _/  __(__  ) /_/ / / /_(__  )    / / / /_/ / /_/ /
# /_/ |_|\___/____/\__,_/_/\__/____/    /_/  \__,_/_.___/ 
#
#============================================================

##############################################################################################################################################################
##
## Section 3 Status SubTab
##
##############################################################################################################################################################

$Section3ResultsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text                    = "Results"
    Name                    = "Results Tab"
    UseVisualStyleBackColor = $True
    Font                    = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$Section4TabControl.Controls.Add($Section3ResultsTab)

#------------------------------
# Results - Add OpNotes Button
#------------------------------
$ResultsTabOpNotesAddButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "Add Selected To OpNotes"

    Location = @{ X = 565
                  Y = 200
                }
    Size     = @{ Width  = 150
                  Height = 25
                }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Green"
}
$ResultsTabOpNotesAddButton.Add_Click({
    $Section1TabControl.SelectedTab   = $Section1OpNotesTab
    if ($ResultsListBox.Items.Count -gt 0) {
        $TimeStamp = Get-Date
        $OpNotesListBox.Items.Add("$(($TimeStamp).ToString('yyyy/MM/dd HH:mm:ss')) [+] Notes added from Results Window:")
        Add-Content -Path $OpNotesWriteOnlyFile -Value "$(($TimeStamp).ToString('yyyy/MM/dd HH:mm:ss')) [+] Notes added from Results Window:" -Force        
        foreach ( $Line in $ResultsListBox.SelectedItems ){
            $OpNotesListBox.Items.Add("$(($TimeStamp).ToString('yyyy/MM/dd HH:mm:ss'))  -  $Line")
            Add-Content -Path $OpNotesWriteOnlyFile -Value "$(($TimeStamp).ToString('yyyy/MM/dd HH:mm:ss'))  -  $Line" -Force        
        }
        Save-OpNotes
    }
})
$ResultsTabOpNotesAddButton.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ One or more lines can be selected to add to the OpNotes.
⦿ The selection can be contiguous by using the Shift key
    and/or be separate using the Ctrl key, the press OK.
⦿ A Datetime stampe will be prefixed to the entry.`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage123))
        $ToolTip.Active       = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation = $true
        $ToolTip.UseFading    = $true
        $ToolTip.IsBalloon    = $true
        $ToolTip.ToolTipIcon  = "Info"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle = 'Add Selected To OpNotes'
    }
})
$Section3ResultsTab.Controls.Add($ResultsTabOpNotesAddButton) 

#-----------------
# Results ListBox
#-----------------
$ResultsListBox = New-Object System.Windows.Forms.ListBox -Property @{
    Name                = "ResultsListBox"
    Location            = New-Object System.Drawing.Point(-1,-1) 
    Size                = New-Object System.Drawing.Size(($Section3ResultsTabWidth - 3),($Section3ResultsTabHeight - 15))
    FormattingEnabled   = $True
    SelectionMode       = 'MultiExtended'
    ScrollAlwaysVisible = $True
    AutoSize            = $False
    Font                = New-Object System.Drawing.Font("Courier New",11,0,0,0)
}
$PoShACMEAboutFile     = "$ResourcesDirectory\About\PoSh-ACME.txt"
# URL for Character Art
# http://patorjk.com/software/taag/#p=display&h=0&f=Slant&t=Posh-ACME
$PoShACMEAboutContents = Get-Content $PoShACMEAboutFile -ErrorAction SilentlyContinue
    $ResultsListBox.Items.Add("      ____            _____   __              ___     _____   __   ___  _____ ") | Out-Null
    $ResultsListBox.Items.Add("     / __ \          / ___/  / /             /   |   / ___/  /  | /  / / ___/ ") | Out-Null
    $ResultsListBox.Items.Add("    / / / / _____   / /_    / /_            / /| |  / /     / /||/  / / /_    ") | Out-Null
    $ResultsListBox.Items.Add("   / /_/ / / ___ \  \__ \  / __ \  ______  / /_| | / /     / / |_/ / / __/    ") | Out-Null
    $ResultsListBox.Items.Add("  / ____/ / /__/ / ___/ / / / / / /_____/ / ____ |/ /___  / /   / / / /___    ") | Out-Null
    $ResultsListBox.Items.Add(" /_/      \_____/ /____/ /_/ /_/         /_/   |_|\____/ /_/   /_/ /_____/    ") | Out-Null
    $ResultsListBox.Items.Add("==============================================================================") | Out-Null
    $ResultsListBox.Items.Add(" PowerShell-Analyst's Collection Made Easy (ACME) for Security Professionals. ") | Out-Null
    $ResultsListBox.Items.Add(" ACME: The point at which something is the Best, Perfect, or Most Successful! ") | Out-Null
    $ResultsListBox.Items.Add("==============================================================================") | Out-Null
    $ResultsListBox.Items.Add("") | Out-Null
    $ResultsListBox.Items.Add(" Author         : high101bro                                                  ") | Out-Null
    $ResultsListBox.Items.Add(" Website        : https://github.com/high101bro/PoSH-ACME                     ") | Out-Null
$Section3ResultsTab.Controls.Add($ResultsListBox)

#=========================================================================
#     __  __           __     ____        __           ______      __  
#    / / / /___  _____/ /_   / __ \____ _/ /_____ _   /_  __/___ _/ /_ 
#   / /_/ / __ \/ ___/ __/  / / / / __ `/ __/ __ `/    / / / __ `/ __ \
#  / __  / /_/ (__  ) /_   / /_/ / /_/ / /_/ /_/ /    / / / /_/ / /_/ /
# /_/ /_/\____/____/\__/  /_____/\__,_/\__/\__,_/    /_/  \__,_/_.___/ 
#                                                                      
#=========================================================================

##############################################################################################################################################################
##
## Section 3 Host Data SubTab
##
##############################################################################################################################################################

$Section3HostDataTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text                    = "Host Data"
    Name                    = "Host Data Tab"
    UseVisualStyleBackColor = $True
    Font                    = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$Section4TabControl.Controls.Add($Section3HostDataTab)

# Default Messages
$ToolTipMessage1   = "• This information is searchable when looking for computers.`n"
$ToolTipMessage2   = "• $ComputerListTreeViewFileSave `n"
$ToolTipMessage3   = "• ToolTips can be disabled in the Options Tab."
$ToolTipMessage123 = $ToolTipMessage1 + $ToolTipMessage2 + $ToolTipMessage3
#------------------------------
# Host Data - Hostname Textbox
#------------------------------
$Section3HostDataName = New-Object System.Windows.Forms.TextBox -Property @{
    Location = New-Object System.Drawing.Point(0,3) 
    Size     = New-Object System.Drawing.Size(250,25)
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ReadOnly = $true
}
$Section3HostDataName.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ This field is reserved for the hostname.
⦿ Hostnames are not case sensitive.
⦿ Though IP addresses may be entered, WinRM queries may fail as
IPs may only be used for authentication under certain conditions.`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage123))
        $ToolTip.Active         = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation   = $true
        $ToolTip.UseFading      = $true
        $ToolTip.IsBalloon      = $true
        $ToolTip.ToolTipIcon    = "Info"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle   = 'Hostname'
    }
})
$Section3HostDataTab.Controls.Add($Section3HostDataName)

#------------------------
# Host Data - OS Textbox
#------------------------
$Section3HostDataOS = New-Object System.Windows.Forms.TextBox -Property @{
    Location = New-Object System.Drawing.Point(0,($Section3HostDataName.Location.Y + $Section3HostDataName.Size.Height + 4)) 
    Size     = New-Object System.Drawing.Size(250,25)
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ReadOnly = $true
}
$Section3HostDataOS.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ This field is useful to view groupings of hosts by OS.`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage123))
        $ToolTip.Active         = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation   = $true
        $ToolTip.UseFading      = $true
        $ToolTip.IsBalloon      = $true
        $ToolTip.ToolTipIcon    = "Info"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle   = 'Operating System'
    }    
})
$Section3HostDataTab.Controls.Add($Section3HostDataOS)

#------------------------
# Host Data - OU Textbox
#------------------------
$Section3HostDataOU = New-Object System.Windows.Forms.TextBox -Property @{
    Location = New-Object System.Drawing.Point(0,($Section3HostDataOS.Location.Y + $Section3HostDataOS.Size.Height + 4)) 
    Size     = New-Object System.Drawing.Size(250,25)
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ReadOnly = $true
}
$Section3HostDataOU.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ This field is useful to view groupings of hosts by OU/CN.`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage123))
        $ToolTip.Active         = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation   = $true
        $ToolTip.UseFading      = $true
        $ToolTip.IsBalloon      = $true
        $ToolTip.ToolTipIcon    = "Info"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle   = 'Organizational Unit / Container Name'
    }    
})
$Section3HostDataTab.Controls.Add($Section3HostDataOU)

#----------------------------------
# Host Data - IP and MAC Textboxes
#----------------------------------
    # IP Address TextBox
    $Section3HostDataIP = New-Object System.Windows.Forms.TextBox -Property @{
        Location = New-Object System.Drawing.Point(0,($Section3HostDataOU.Location.Y + $Section3HostDataOU.Size.Height + 4)) 
        Size     = New-Object System.Drawing.Size(120,25)
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ReadOnly = $false
    }
    $Section3HostDataIP.Add_MouseHover({
        $ToolTip = New-Object System.Windows.Forms.ToolTip    
        if ($OptionShowToolTipCheckBox.Checked){
            $Message = "⦿ Informational field not used to query hosts.`n`n"
            $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage123))
            $ToolTip.Active         = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
            $ToolTip.UseAnimation   = $true
            $ToolTip.UseFading      = $true
            $ToolTip.IsBalloon      = $true
            $ToolTip.ToolTipIcon    = "Info"  #Error, Info, Warning, None
            $ToolTip.ToolTipTitle   = 'IP Address'
        }    
    })
    $Section3HostDataTab.Controls.Add($Section3HostDataIP)

    # MAC Address TextBox
    $Section3HostDataMAC = New-Object System.Windows.Forms.TextBox -Property @{
        Location = New-Object System.Drawing.Point(($Section3HostDataIP.Size.Width + 10),($Section3HostDataOU.Location.Y + $Section3HostDataOU.Size.Height + 4)) 
        Size     = New-Object System.Drawing.Size(120,25)
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ReadOnly = $false
    }
    $Section3HostDataMAC.Add_MouseHover({
        $ToolTip = New-Object System.Windows.Forms.ToolTip    
        if ($OptionShowToolTipCheckBox.Checked){
            $Message = "⦿ Informational field not used to query hosts.`n`n"
            $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage123))
            $ToolTip.Active         = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
            $ToolTip.UseAnimation   = $true
            $ToolTip.UseFading      = $true
            $ToolTip.IsBalloon      = $true
            $ToolTip.ToolTipIcon    = "Info"  #Error, Info, Warning, None
            $ToolTip.ToolTipTitle   = 'MAC Address'
        }    
    })
    $Section3HostDataTab.Controls.Add($Section3HostDataMAC)

#--------------------------------------
# Host Data Notes - Add OpNotes Button
#--------------------------------------
$Section3HostDataNotesAddOpNotesButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "Add Host Data To OpNotes"
    Location  = New-Object System.Drawing.Point(558,197)
    Size      = New-Object System.Drawing.Size(150,25)
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Green"
}
$Section3HostDataNotesAddOpNotesButton.Add_Click({
    $Section1TabControl.SelectedTab   = $Section1OpNotesTab
    if ($Section3HostDataNotes.text) {
        $TimeStamp = Get-Date
        $OpNotesListBox.Items.Add("$(($TimeStamp).ToString('yyyy/MM/dd HH:mm:ss')) [+] Host Data Notes from: $($Section3HostDataName.Text)")
        Add-Content -Path $OpNotesWriteOnlyFile -Value "$(($TimeStamp).ToString('yyyy/MM/dd HH:mm:ss')) [+] Host Data Notes from: $($Section3HostDataName.Text)" -Force        
        foreach ( $Line in ($Section3HostDataNotes.text -split "`r`n") ){
            $OpNotesListBox.Items.Add("$(($TimeStamp).ToString('yyyy/MM/dd HH:mm:ss'))  -  $Line")
            Add-Content -Path $OpNotesWriteOnlyFile -Value "$(($TimeStamp).ToString('yyyy/MM/dd HH:mm:ss'))  -  $Line" -Force        
        }
        Save-OpNotes
    }
})
$Section3HostDataNotesAddOpNotesButton.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ One or more lines can be selected to add to the OpNotes.
⦿ The selection can be contiguous by using the Shift key
    and/or be separate using the Ctrl key, the press OK.
⦿ A Datetime stampe will be prefixed to the entry.`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage123))
        $ToolTip.Active       = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation = $true
        $ToolTip.UseFading    = $true
        $ToolTip.IsBalloon    = $true
        $ToolTip.ToolTipIcon  = "Info"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle = 'Add Selected To OpNotes'
    }
})
$Section3HostDataTab.Controls.Add($Section3HostDataNotesAddOpNotesButton) 

#---------------------------
# Host Data - Notes Textbox
#---------------------------
$Section3HostDataNotes = New-Object System.Windows.Forms.TextBox -Property @{
    Location   = New-Object System.Drawing.Point(0,($Section3HostDataIP.Location.Y + $Section3HostDataIP.Size.Height + 3)) 
    Size       = New-Object System.Drawing.Size(727,126)
    Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    Multiline  = $True
    ScrollBars = 'Vertical'
    WordWrap   = $True
    ReadOnly   = $false
}
$Section3HostDataNotes.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ These notes are specific to the host.
⦿ Also can contains Tags if used.`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage123))
        $ToolTip.Active         = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation   = $true
        $ToolTip.UseFading      = $true
        $ToolTip.IsBalloon      = $true
        $ToolTip.ToolTipIcon    = "Info"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle   = 'Host Notes'
    }    
})
$Section3HostDataTab.Controls.Add($Section3HostDataNotes)

#-------------------------
# Host Data - Save Button
#-------------------------
$Section3HostDataSaveButton = New-Object System.Windows.Forms.Button -Property @{
    Name      = "Host Data - Save"
    Text      = "Save"
    Location  = New-Object System.Drawing.Point(629,73) 
    Size      = New-Object System.Drawing.Size(100,22)
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = 'Red'
}
$Section3HostDataSaveButton.Add_Click({
    $ComputerListTreeViewSaveData = @()
    Foreach($Computer in $script:ComputerListTreeViewData) {
        $ComputerListTreeViewSaveDataTemp = New-Object PSObject -Property @{ Name = $Computer.Name}        
        $ComputerListTreeViewSaveDataTemp | Add-Member -MemberType NoteProperty -Name OperatingSystem -Value $Computer.OperatingSystem -Force        
        $ComputerListTreeViewSaveDataTemp | Add-Member -MemberType NoteProperty -Name CanonicalName   -Value $Computer.CanonicalName -Force        
        # If the node is selected, it will save the values you enter
        if ($Computer.Name -eq $Section3HostDataName.Text) {
            $ComputerListTreeViewSaveDataTemp | Add-Member -MemberType NoteProperty -Name IPv4Address -Value $Section3HostDataIP.Text -Force
            $ComputerListTreeViewSaveDataTemp | Add-Member -MemberType NoteProperty -Name MACAddress  -Value $Section3HostDataMAC.Text -Force
            $ComputerListTreeViewSaveDataTemp | Add-Member -MemberType NoteProperty -Name Notes       -Value $Section3HostDataNotes.Text -Force }
        # Else, if the node is not selected, it will retain what was saved
        else {
            $ComputerListTreeViewSaveDataTemp | Add-Member -MemberType NoteProperty -Name IPv4Address -Value $Computer.IPv4Address -Force
            $ComputerListTreeViewSaveDataTemp | Add-Member -MemberType NoteProperty -Name MACAddress  -Value $Computer.MACAddress -Force           
            $ComputerListTreeViewSaveDataTemp | Add-Member -MemberType NoteProperty -Name Notes       -Value $Computer.Notes -Force }
        $ComputerListTreeViewSaveData += $ComputerListTreeViewSaveDataTemp
    }
    $script:ComputerListTreeViewData  = $ComputerListTreeViewSaveData
    $ComputerListTreeViewSaveDataTemp = $null
    $ComputerListTreeViewSaveData     = $null

    # Saves the TreeView Data to File
    $script:ComputerListTreeViewData | Export-Csv $ComputerListTreeViewFileSave -NoTypeInformation -Force
    
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Saved Host Data:  $($Section3HostDataName.Text)")

})
$Section3HostDataSaveButton.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ Best practice is to save after modifying each host data.`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage2 + $ToolTipMessage3))
        $ToolTip.Active         = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation   = $true
        $ToolTip.UseFading      = $true
        $ToolTip.IsBalloon      = $true
        $ToolTip.ToolTipIcon    = "Warning"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle   = 'Warning:'
    }    
})
$Section3HostDataTab.Controls.Add($Section3HostDataSaveButton)


#============================================================================================================================================================
# Host Data - Selection Data ComboBox and Date/Time ComboBox
#============================================================================================================================================================
$HostDataList1 = @(
    "Host Data - Selection",
    "Accounts",
    "Logon Info",
    "Network Settings",
    "Processes",
    "Security Patches",
    "Services",
    "Software Installed",
    "Startup Commands"
)

$HostDataList2 = {
    function Get-HostDataCsvResults {
        # Searches though the all Collection Data Directories to find files that match
        $ListOfCollectedDataDirectories = $(Get-ChildItem -Path $CollectedDataDirectory | Sort-Object -Descending).FullName
        $script:CSVFileMatch = @()
        foreach ($CollectionDir in $ListOfCollectedDataDirectories) {
            $CSVFiles = $(Get-ChildItem -Path $CollectionDir -Recurse).FullName
            foreach ($CSVFile in $CSVFiles) {
                # Searches for the CSV file that matches the data selected
                if (($CSVFile -match $Section3HostDataSelectionComboBox.SelectedItem) -and ($CSVFile -match $Section3HostDataName.Text)) {
                    $HostDataCsvFile = Import-CSV -Path $CSVFile
                    # Searches for the Hostname in the CsvFile, if present that file will be used for viewing
                    if ($HostDataCsvFile.PSComputerName -eq $Section3HostDataName.Text) {
                        $script:CSVFileMatch += "$CSVFile"
                        break
                    }
                }
            }
        }        
    }

    function Get-HostDataCsvDateTime {
        $script:HostDataCsvDateTime = @()
        foreach ($Csv in $script:CSVFileMatch) {
            #$a = $CollectedDataDirectory #not use, just a note
            $DirDateTime = $Csv.split('\')[-4]
            $script:HostDataCsvDateTime += $DirDateTime
            $script:HostDataCsvPath = $Csv.split('\')[-3,-2] -join '\'
        }
    }                               

    # Locates CsvFiles speicifc to Hosts and specific results
    Switch ($Section3HostDataSelectionComboBox.text) {
        "Accounts"   { 
            Get-HostDataCsvResults $Section3HostDataSelectionComboBox.SelectedItem
            if ($($script:CSVFileMatch).count -eq 0) {$script:HostDataCsvDateTime = @('No Data Available')}
            else {Get-HostDataCsvDateTime}
        }
        "Logon Info"         {
            Get-HostDataCsvResults $Section3HostDataSelectionComboBox.SelectedItem
            if ($($script:CSVFileMatch).count -eq 0) {$script:HostDataCsvDateTime = @('No Data Available')}
            else {Get-HostDataCsvDateTime}          
        }
        "Network Settings"   {
            Get-HostDataCsvResults $Section3HostDataSelectionComboBox.SelectedItem
            if ($($script:CSVFileMatch).count -eq 0) {$script:HostDataCsvDateTime = @('No Data Available')}
            else {Get-HostDataCsvDateTime}          
        }
        "Processes" {
            Get-HostDataCsvResults $Section3HostDataSelectionComboBox.SelectedItem
            if ($($script:CSVFileMatch).count -eq 0) {$script:HostDataCsvDateTime = @('No Data Available')}
            else {Get-HostDataCsvDateTime}
        }
        "Security Patches"   {
            Get-HostDataCsvResults $Section3HostDataSelectionComboBox.SelectedItem
            if ($($script:CSVFileMatch).count -eq 0) {$script:HostDataCsvDateTime = @('No Data Available')}
            else {Get-HostDataCsvDateTime}
        }
        "Services"           {
            Get-HostDataCsvResults $Section3HostDataSelectionComboBox.SelectedItem
            if ($($script:CSVFileMatch).count -eq 0) {$script:HostDataCsvDateTime = @('No Data Available')}
            else {Get-HostDataCsvDateTime}
        }
        "Software Installed" {
            Get-HostDataCsvResults $Section3HostDataSelectionComboBox.SelectedItem
            if ($($script:CSVFileMatch).count -eq 0) {$script:HostDataCsvDateTime = @('No Data Available')}
            else {Get-HostDataCsvDateTime}
        }
        "Startup Commands"   {
            Get-HostDataCsvResults $Section3HostDataSelectionComboBox.SelectedItem
            if ($($script:CSVFileMatch).count -eq 0) {$script:HostDataCsvDateTime = @('No Data Available')}
            else {Get-HostDataCsvDateTime}
        }
    }
    $Section3HostDataSelectionDateTimeComboBox.DataSource = $script:HostDataCsvDateTime
}

    #--------------------------------
    # Host Data - Selection ComboBox
    #--------------------------------
    $Section3HostDataSelectionComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location           = New-Object System.Drawing.Size(260,3)
        Size               = New-Object System.Drawing.Size(200,25)
        Text               = "Host Data - Selection"
        Font               = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor          = "Black"
        AutoCompleteSource = "ListItems" # Options are: FileSystem, HistoryList, RecentlyUsedList, AllURL, AllSystemSources, FileSystemDirectories, CustomSource, ListItems, None
        AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
        DataSource         = $HostDataList1
    }
    #$Section3HostDataSelectionComboBox.Add_KeyDown({  })
    $Section3HostDataSelectionComboBox.Add_MouseHover({
        $ToolTip = New-Object System.Windows.Forms.ToolTip    
        if ($OptionShowToolTipCheckBox.Checked){
            $Message = "⦿ If data exists, the datetime group will be displayed below.
⦿ These files can be searchable, toggle in Options Tab.
⦿ Note: Datetimes with more than one collection type won't
    display, these results will need to be navigated to manually.`n`n"
            $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage123))
            $ToolTip.Active       = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
            $ToolTip.UseAnimation = $true
            $ToolTip.UseFading    = $true
            $ToolTip.IsBalloon    = $true
            $ToolTip.ToolTipIcon  = "Info"  #Error, Info, Warning, None
            $ToolTip.ToolTipTitle = 'Select Search Topic'
        }
    })
    $Section3HostDataSelectionComboBox.add_SelectedIndexChanged($HostDataList2)
    $Section3HostDataTab.Controls.Add($Section3HostDataSelectionComboBox)

    #--------------------------------------------
    # Host Data - Date & Time Collected ComboBox
    #--------------------------------------------
    $Section3HostDataSelectionDateTimeComboBox                    = New-Object System.Windows.Forms.ComboBox -Property @{
        Location           = New-Object System.Drawing.Size(260,($Section3HostDataSelectionComboBox.Size.Height + $Section3HostDataSelectionComboBox.Location.Y + 3))
        Size               = New-Object System.Drawing.Size(200,25)
        Text               = "Host Data - Date & Time"
        Font               = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor          = "Black"
        AutoCompleteSource = "ListItems" # Options are: FileSystem, HistoryList, RecentlyUsedList, AllURL, AllSystemSources, FileSystemDirectories, CustomSource, ListItems, None
        AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
    }
    #$Section3HostDataSelectionDateTimeComboBox.Add_KeyDown({  })
    $Section3HostDataSelectionDateTimeComboBox.Add_MouseHover({
        $ToolTip = New-Object System.Windows.Forms.ToolTip    
        if ($OptionShowToolTipCheckBox.Checked){
            $Message = "⦿ If data exists, the datetime group will be displayed.
⦿ These files can be searchable, toggle in Options Tab.
⦿ Note: Datetimes with more than one collection type won't
    display, these results will need to be navigated to manually.`n`n"
            $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage123))
            $ToolTip.Active         = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
            $ToolTip.UseAnimation   = $true
            $ToolTip.UseFading      = $true
            $ToolTip.IsBalloon      = $true
            $ToolTip.ToolTipIcon    = "Info"  #Error, Info, Warning, None
            $ToolTip.ToolTipTitle   = 'Datetime of Results'
        }    
    })    
    $Section3HostDataTab.Controls.Add($Section3HostDataSelectionDateTimeComboBox)
  
    #-----------------------------
    # Host Data - Get Data Button
    #-----------------------------
    $Section3HostDataGetDataButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Get Data"
        Location = New-Object System.Drawing.Size(($Section3HostDataSelectionDateTimeComboBox.Location.X + $Section3HostDataSelectionDateTimeComboBox.Size.Width + 5),($Section3HostDataSelectionDateTimeComboBox.Location.Y - 1))
        Size     = New-Object System.Drawing.Size(75,23)
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $Section3HostDataGetDataButton.Add_Click({
        # Chooses the most recent file if multiple exist
        $HostData = Import-Csv -Path "$CollectedDataDirectory\$($Section3HostDataSelectionDateTimeComboBox.SelectedItem)\$script:HostDataCsvPath\*$($Section3HostDataName.Text)*.csv"
        
        if ($HostData) {
            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("Showing Results:  $HostDataSection")
            $HostData | Out-GridView -OutputMode Multiple | Set-Variable -Name HostDataResultsSection
        
            # Adds Out-GridView selected Host Data to OpNotes
            foreach ($Selection in $HostDataResultsSection) {
                $OpNotesListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  $HostDataSection - $($Selection -replace '@{','' -replace '}','')")
                Add-Content -Path $OpNotesWriteOnlyFile -Value ($OpNotesListBox.SelectedItems) -Force
            }
            Save-OpNotes
        }
        else {
            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("No Data Available:  $HostDataSection")
            # Sounds a chime if there is not data 
            [system.media.systemsounds]::Exclamation.play()
        }
    })
    $Section3HostDataGetDataButton.Add_MouseHover({
        $ToolTip = New-Object System.Windows.Forms.ToolTip    
        if ($OptionShowToolTipCheckBox.Checked){
            $Message = "⦿ If data exists, the datetime group will be displayed.
⦿ These files can be searchable, toggle in Options Tab.
⦿ Note: Datetimes with more than one collection type won't
    display, these results will need to be navigated to manually.`n`n"
            $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage123))
            $ToolTip.Active         = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
            $ToolTip.UseAnimation   = $true
            $ToolTip.UseFading      = $true
            $ToolTip.IsBalloon      = $true
            $ToolTip.ToolTipIcon    = "Info"  #Error, Info, Warning, None
            $ToolTip.ToolTipTitle   = 'Get Data'
        }    
    }) 
    $Section3HostDataTab.Controls.Add($Section3HostDataGetDataButton)

#---------------------------------------
# ComputerList TreeView - Tags ComboBox
#---------------------------------------
$Section3HostDataTagsComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Name               = "Tags"
    Text               = "Tags"
    Location           = New-Object System.Drawing.Size(260,($Section3HostDataGetDataButton.Size.Height + $Section3HostDataGetDataButton.Location.Y + 25))
    Size               = New-Object System.Drawing.Size(200,25)
    AutoCompleteSource = "ListItems" # Options are: FileSystem, HistoryList, RecentlyUsedList, AllURL, AllSystemSources, FileSystemDirectories, CustomSource, ListItems, None
    AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
    ForEach ($Item in $TagList) { 
        [void] $Section3HostDataTagsComboBox.Items.Add($Item) 
    }
$Section3HostDataTagsComboBox.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ Tags are not mandatory.
⦿ Tags provide standized info to aide searches.
⦿ Custom tags can be modified, created, and used.`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage123))
        $ToolTip.Active         = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation   = $true
        $ToolTip.UseFading      = $true
        $ToolTip.IsBalloon      = $true
        $ToolTip.ToolTipIcon    = "Info"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle   = 'List of Pre-Built Tags'
    }    
})
$Section3HostDataTab.Controls.Add($Section3HostDataTagsComboBox)

#-----------------------------------------
# ComputerList TreeView - Tags Add Button
#-----------------------------------------
$Section3HostDataTagsAddButton = New-Object System.Windows.Forms.Button -Property @{
    Name      = "Tags Add Button"
    Text      = "Add"
    Location  = New-Object System.Drawing.Point(($Section3HostDataTagsComboBox.Size.Width + $Section3HostDataTagsComboBox.Location.X + 5),($Section3HostDataTagsComboBox.Location.Y - 1))
    Size      = New-Object System.Drawing.Size(75,23)
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Green"
}
$Section3HostDataTagsAddButton.Add_Click({ 
    if (!($Section3HostDataTagsComboBox.SelectedItem -eq "Tags")) {
        $Section3HostDataNotes.text = "[$($Section3HostDataTagsComboBox.SelectedItem)] " + $Section3HostDataNotes.text
    }
})
$Section3HostDataTagsAddButton.Add_MouseHover({
    $ToolTip = New-Object System.Windows.Forms.ToolTip
    if ($OptionShowToolTipCheckBox.Checked){
        $Message = "⦿ Tags are not mandatory.
⦿ Tags provide standized info to aide searches.
⦿ Custom tags can be created and used.`n`n"
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage123))
        $ToolTip.Active         = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation   = $true
        $ToolTip.UseFading      = $true
        $ToolTip.IsBalloon      = $true
        $ToolTip.ToolTipIcon    = "Info"  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle   = 'Add Tag to Notes'
    }
})
$Section3HostDataTab.Controls.Add($Section3HostDataTagsAddButton)

#============================================================================================================================================================
# Convert CSV Number Strings To Intergers
#============================================================================================================================================================
function Convert-CSVNumberStringsToIntergers {
    param ($InputDataSource)
    $InputDataSource | ForEach-Object {
        if ($_.CreationDate)    { $_.CreationDate    = [datatime]$_.CreationDate }
        if ($_.Handle)          { $_.Handle          = [int]$_.Handle            }
        if ($_.HandleCount)     { $_.HandleCount     = [int]$_.HandleCount       }
        if ($_.ParentProcessID) { $_.ParentProcessID = [int]$_.ParentProcessID   }
        if ($_.ProcessID)       { $_.ProcessID       = [int]$_.ProcessID         }
        if ($_.ThreadCount)     { $_.ThreadCount     = [int]$_.ThreadCount       }
        if ($_.WorkingSetSize)  { $_.WorkingSetSize  = [int]$_.WorkingSetSize    }
    }
}

#============================================================================================================================================================
# Compile CSV Files
#============================================================================================================================================================
function Compile-CsvFiles {
    param (
        [string]$LocationOfCSVsToCompile, 
        [string]$LocationToSaveCompiledCSV
    )
    # This function compiles the .csv files in the collection directory which outputs in the parent directory
    # The first line (collumn headers) is only copied once from the first file compiled, then skipped for the rest  
    Remove-Item -Path "$LocationToSaveCompiledCSV" -Force
    Start-Sleep -Milliseconds 250

    $GetFirstLine = $true
    Get-ChildItem "$LocationOfCSVsToCompile" | foreach {
        if ((Get-Content $PSItem).Length -eq 0) {
            Remove-Item $PSItem
        }
        else {
            $FilePath = $_
            $Lines = $Lines = Get-Content $FilePath  
            $LinesToWrite = switch($GetFirstLine) {
                $true  {$Lines}
                $false {$Lines | Select -Skip 1}
            }
            $GetFirstLine = $false
            Add-Content -Path "$LocationToSaveCompiledCSV" $LinesToWrite -Force
        }
    }  
}

#============================================================================================================================================================
# Removes Duplicate CSV Headers
#============================================================================================================================================================
function Remove-DuplicateCsvHeaders {
    $count = 1
    $output = @()
    $Contents = Get-Content "$($CollectedDataTimeStampDirectory)\$($CollectionName).csv" 
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
    Remove-Item -Path "$($CollectedDataTimeStampDirectory)\$($CollectionName).csv"
    $output | Out-File -FilePath "$($CollectedDataTimeStampDirectory)\$($CollectionName).csv"
}

#============================================================================================================================================================
# Monitor Jobs of Individual Queries
#============================================================================================================================================================
function Monitor-Jobs {
    # Initially updates statistics
    $StatisticsResults = Get-PoShACMEStatistics
    $StatisticsNumberOfCSVs.text = $StatisticsResults        

    $SleepMilliseconds = 250
    $ProgressBarSection.Value = 0
    $JobsLaunch = Get-Date 
    
    # Sets the job timeout value, so they don't run forever
    $JobsTimer  = [int]$($OptionJobTimeoutSelectionComboBox.Text)

    # This is how often the statistics page updates, be default it is 20 which is 5 seconds (250 ms x 4)
    $StatisticsUpdateInterval      = (1000 / $SleepMilliseconds) * $OptionStatisticsUpdateIntervalCombobox.text
    $StatisticsUpdateIntervalCount = 0

    do {
        # Updates Statistics 
        $StatisticsUpdateIntervalCount++
        if (($StatisticsUpdateIntervalCount % $StatisticsUpdateInterval) -eq 0) {
            $StatisticsResults = Get-PoShACMEStatistics
            $StatisticsNumberOfCSVs.text = $StatisticsResults        
        }
        
        # The number of Jobs created by PoSh-ACME
        $CurrentJobs                = Get-Job -Name "PoSh-ACME:*"
        $jobscount                  = $CurrentJobs.count                  
        $ProgressBarSection.Maximum = $jobscount

        # Gets the results from jobs that are completed
        $CurrentJobs | Receive-Job -Force

        ### Not currently satisfied with it
        # Gets a host list of the Jobs
        #$ACME_Jobs = $CurrentJobs | Where-Object State -eq Running | Select-Object -ExpandProperty Name
        #$JobsHosts = ''
        #foreach ($job in $ACME_Jobs) { $JobsHosts += $($($job -replace 'PoSh-ACME: ','' -split '--')[2])}
        #$JobsHosts = $JobsHosts -replace ' ',', ' -replace ", $","" -replace "^,",""       
        #$StatusListBox.Items.Clear()
        #$StatusListBox.Items.Add("Processing: $JobsHosts")
                

        # Counts the total of completed jobs for each update
        $done = 0
        foreach ($job in $CurrentJobs) {
            if ($($job.state) -eq "Completed") {$done++}
        }
        $ProgressBarSection.Value = $done 
        
        # Calcualtes and formats time elaspsed
        $CurrentTime = Get-Date
        $Timecount   = $JobsLaunch - $CurrentTime        
        $hour        = [Math]::Truncate($Timecount)
        $minute      = ($CollectionTime - $hour) * 60
        $second      = [int](($minute - ([Math]::Truncate($minute))) * 60)
        $minute      = [Math]::Truncate($minute)
        $Timecount   = [datetime]::Parse("$hour`:$minute`:$second")

        # Provides updates on the jobs
        $ResultsListBox.Items.Insert(0,"Running Jobs:  $($jobscount - $done)")        
        $ResultsListBox.Items.Insert(1,"Current Time:  $($currentTime)")
        $ResultsListBox.Items.Insert(2,"Elasped Time:  $($Timecount -replace '-','')")
        $ResultsListBox.Items.Insert(3,"")
        $ExecutionStatusCheckedListBox.Items.Add("$JobsHosts")

        # This is how often PoSoh-ACME's GUI will refresh when provide the status of the jobs
        # Default have is 250 ms. If you change this, be sure to update the $StatisticsUpdateInterval variarible within this function
        Start-Sleep -Milliseconds $SleepMilliseconds

        # Checks if the current job is running too long and stops it
        foreach ($Job in $CurrentJobs) {
            if ($Job.PSBeginTime -lt $(Get-Date).AddSeconds(-$JobsTimer)) {
                $TimeStamp = $(Get-Date).ToString('yyyy/MM/dd HH:mm:ss')
                $ResultsListBox.Items.insert(5,"$($TimeStamp)   - Job Timed Out: $((($Job | Select-Object -ExpandProperty Name) -split '-')[-1])")
                $JobsKillTime = Get-Date
                $Job | Stop-Job 
                $Job | Receive-Job -Force 
                $Job | Remove-Job -Force
                $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Job [TIMED OUT]: `"$($Job.Name)`" - Started at $($Job.PSBeginTime) - Ran for $($JobsKillTime - $Job.PSBeginTime)"
                $LogMessage | Add-Content -Path $LogFile
                break        
            }
        }
        $ResultsListBox.Items.RemoveAt(0)
        $ResultsListBox.Items.RemoveAt(0)
        $ResultsListBox.Items.RemoveAt(0)
        $ResultsListBox.Items.RemoveAt(0)  
    } while ($done -lt $jobscount)

    # Logs Jobs Beginning and Ending Times
    foreach ($Job in $CurrentJobs) {
        if ($($Job.PSEndTime -ne $null)) {
            $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Job [COMPLETED]: `"$($Job.Name)`" - Started at $($Job.PSBeginTime) - Ended at $($Job.PSEndTime)"
            $LogMessage | Add-Content -Path $LogFile
        }
    }

    # Updates Statistics One last time
    $StatisticsResults = Get-PoShACMEStatistics
    $StatisticsNumberOfCSVs.text = $StatisticsResults        
    Get-Job -Name "PoSh-ACME:*" | Remove-Job -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
}

#============================================================================================================================================================
# CheckBox Script Handler
#============================================================================================================================================================
$ExecuteScriptHandler= {
    # This is for reference, it's also used later in the handler script
    #$Section1TabControl.SelectedTab   = $Section1OpNotesTab
    #$Section2TabControl.SelectedTab   = $Section2MainTab
    #$Section3TabControl.SelectedTab   = $Section3ActionTab
    #$Section4TabControl.SelectedTab   = $Section3ResultsTab

    # Clears the Progress bars
    $ProgressBarSection.Value = 0
    $ProgressBarOverall.Value = 0

    # Clears previous Target Host values
    $ComputerList = @()           

    if ($SingleHostIPCheckBox.Checked -eq $true) {
        if (($SingleHostIPTextBox.Text -ne $DefaultSingleHostIPText) -and ($SingleHostIPTextBox.Text -ne '') ) {
            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("Single Host Collection")
            $ComputerList = $SingleHostIPTextBox.Text
        }
    }
    elseif ($SingleHostIPCheckBox.Checked -eq $false) {    
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Multiple Host Collection")
        
        # If the root computerlist checkbox is checked, all hosts will be queried
        [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $ComputerListTreeView.Nodes 
        if ($script:ComputerListSearch.Checked) { 
            foreach ($root in $AllHostsNode) { 
                if ($root.text -imatch "Search Results") {
                    foreach ($Category in $root.Nodes) {
                        foreach ($Entry in $Category.nodes) {
                            $ComputerList += $Entry.text 
                        }
                    }            
                }
            }    
        }     
        if ($script:TreeNodeComputerList.Checked) {
            foreach ($root in $AllHostsNode) { 
                if ($root.text -imatch "All Hosts") {
                    foreach ($Category in $root.Nodes) { 
                        foreach ($Entry in $Category.nodes) { 
                            $ComputerList += $Entry.text 
                        }       
                    } 
                }
            }
        }
        foreach ($root in $AllHostsNode) {         
            # This loop will select all hosts in a Category    
            foreach ($Category in $root.Nodes) {
                if ($Category.Checked) {
                    foreach ($Entry in $Category.Nodes) {
                        $ComputerList += $Entry.text
                    }
                }
            }
            # This loop will check for entries that are checked
            foreach ($Category in $root.Nodes) { 
                foreach ($Entry in $Category.nodes) { 
                    if ($Entry.Checked) { $ComputerList += $Entry.text }
                }
            }
        }
        # This will dedup the ComputerList, though there is unlikely multiple computers of the same name
        $ComputerList = $ComputerList | Sort-Object -Unique
    }
    $ResultsListBox.Items.Clear()
    $ResultsListBox.Items.Add("Computers to be queried:  $($ComputerList.Count)")
    $ResultsListBox.Items.Add("$ComputerList")
    Start-Sleep -Seconds 1
    
    # Assigns the path to save the Collections to
    $CollectedDataTimeStampDirectory = $CollectionSavedDirectoryTextBox.Text
    $IndividualHostResults           = "$CollectedDataTimeStampDirectory\Individual Host Results"


<#
    # Checks if any commands were selected
    if ($false) {
    #if ($CommandsSelectionCheckedlistbox.CheckedItems.Count -eq 0) {
        # This brings specific tabs to the forefront/front view
        $Section1TabControl.SelectedTab            = $Section1CollectionsTab
        $Section1CollectionsTabControl.SelectedTab = $Section1CommandsTab
        $Section4TabControl.SelectedTab            = $Section3ResultsTab

        # Sounds a chime if there are no queries selected
        [system.media.systemsounds]::Exclamation.play()

        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Insert(0,"Error: Nothing Selected To Collect")
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Insert(0,"Error: You need to make a selection from one of the following in the Collections Tab:")
        $ResultsListBox.Items.Insert(0,"       Queries") 
        $ResultsListBox.Items.Insert(0,"       Event Logs") 
        $ResultsListBox.Items.Insert(0,"       Active Directory") 
        $ResultsListBox.Items.Insert(0,"       File Search") 
        $ResultsListBox.Items.Insert(0,"       Registry [future feature]") 
        $ResultsListBox.Items.Insert(0,"       Sysinternals [if Resource foler is present]") 
    }
    else {
#>

    # Checks if any computers were selected
    if (($ComputerList.Count -eq 0) -and ($SingleHostIPCheckBox.Checked -eq $false)) {
        # This brings specific tabs to the forefront/front view
        $Section1TabControl.SelectedTab = $Section1CollectionsTab
        $Section4TabControl.SelectedTab = $Section3ResultsTab

        # Sounds a chime if there are no queries selected
        [system.media.systemsounds]::Exclamation.play()

        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Error: No Hosts Entered or Selected")
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Error: 1) Make a selection from the Computer TreeView:")
        $ResultsListBox.Items.Add("            Check one or more target computers")
        $ResultsListBox.Items.Add("            Check a category to collect data from all nested target computers")
        $ResultsListBox.Items.Add("       2) Enter a Single Host to collect from:")
        $ResultsListBox.Items.Add("            Check the Query A Single Host Checkbox")
        $ResultsListBox.Items.Add("            Enter a valid host to collect data from")
    }
    #elseif ($EventLogsStartTimePicker.Checked -and -not $EventLogsStopTimePicker.Checked) {$EventLogsStopTimePicker.Checked = $true}
    elseif ($EventLogsStartTimePicker.Checked -xor $EventLogsStopTimePicker.Checked) {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Error: Event Log DateTime Range Error")
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Error: Event Log DateTime Range Selection Error")
        $ResultsListBox.Items.Add("       DateTime Start and DateTime Stop must both be checked or unchecked.") 
    }

    ####################################################
    #  Executes queries if it passes the above checks  #
    ####################################################
    else {
        # This brings specific tabs to the forefront/front view
        #$Section1TabControl.SelectedTab = $Section1OpNotesTab
        #$Section2TabControl.SelectedTab = $Section2MainTab
        $Section2TabControl.SelectedTab = $Section2StatisticsTab
        $Section3TabControl.SelectedTab = $Section3ActionTab
        $Section4TabControl.SelectedTab = $Section3ResultsTab

        $ResultsListBox.Items.Clear();
        $CollectionTimerStart = Get-Date
        $ResultsListBox.Items.Insert(0,"$(($CollectionTimerStart).ToString('yyyy/MM/dd HH:mm:ss'))  Collection Start Time")    
        $ResultsListBox.Items.Insert(0,"")
         
        # Counts Target Computers
        $CountTargetComputer = $ComputerList.Count

        #Initiallizes and zeroes out the variable 
        $CompletedCommandQueries = 0

        # Counts the Total Queries
        $CountCommandQueries = 0



#        if ($CommandsTreeViewQueryAsCompiledRadioButton.checked -eq $true) {
#
#            $QueryCommands += @{ $Command.Name = @{ Name = $Command.Name ; Command = $Command.Command ; Properties = $Command.Properties }}
#   }






        # Adds all the checkboxed commands to a list
        $CommandsCheckedBoxesSelected = @()

        [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $CommandsTreeView.Nodes
        $ResultsListBox.Items.Clear()

        #Compiles all the commands into one object
        $script:AllCommands  = $script:AllEndpointCommands
        $script:AllCommands += $script:AllActiveDirectoryCommands
        $script:AllCommands += $script:ImportCustomCommands

        #Check if check boxes match query type and runs them
        foreach ($root in $AllHostsNode) { 
            foreach ($Category in $root.Nodes) {                
                if ($CommandsViewMethodRadioButton.Checked) {
                    foreach ($Entry in $Category.nodes) { 
                        # Counts the query nodes
                        if ($Entry.Checked) { $CountCommandQueries++}
                        
                        # Builds the query that is selected
                        if ($Entry.Checked -and $Entry -match '(RPC)' -and $Entry -match 'CMD') {
                            $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                            $CommandsCheckedBoxesSelected += New-Object psobject @{ 
                                Name           = $Entry.Text
                                Command        = $Command.Command_RPC_CMD
                                Arguments      = $Command.Command_RPC_CMD_Arg
                                ExportFileName = $Command.ExportFileName
                                Type           = "(RPC) CMD"
                            }
                        }                    
                        if ($Entry.Checked -and $Entry -match '(RPC)' -and $Entry -match 'PoSh') {
                            $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                            $CommandsCheckedBoxesSelected += New-Object psobject @{ 
                                Name           = $Entry.Text
                                Command        = $Command.Command_RPC_PoSh
                                Properties     = $Command.Properties_PoSh
                                ExportFileName = $Command.ExportFileName
                                Type           = "(RPC) PoSh"
                            }
                        }
                        if ($Entry.Checked -and $Entry -match '(RPC)' -and  $Entry -match 'WMI' -and $Entry -notmatch '(WinRS)' -and $Entry -notmatch '(WinRM)') {
                            $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                            $CommandsCheckedBoxesSelected += New-Object psobject @{ 
                                Name           = $Entry.Text
                                Command        = $Command.Command_WMI
                                Properties     = $Command.Properties_WMI
                                ExportFileName = $Command.ExportFileName
                                Type           = "(RPC) WMI"
                            }
                        }
                        if ($Entry.Checked -and $Entry -match '(WinRM)' -and $Entry -match 'CMD') {
                            $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                            $CommandsCheckedBoxesSelected += New-Object psobject @{ 
                                Name           = $Entry.Text
                                Command        = $Command.Command_WinRM_CMD
                                ExportFileName = $Command.ExportFileName
                                Type           = "(WinRM) CMD"
                            }
                        }
                        if ($Entry.Checked -and $Entry -match '(WinRM)' -and $Entry -match 'Script') {
                            $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                            $CommandsCheckedBoxesSelected += New-Object psobject @{ 
                                Name           = $Entry.Text
                                Command        = $Command.Command_WinRM_Script
                                #Properties     = $Command.Properties_Script
                                ExportFileName = $Command.ExportFileName
                                Type           = "(WinRM) Script"
                            }
                        }
                        if ($Entry.Checked -and $Entry -match '(WinRM)' -and $Entry -match 'PoSh') {
                            $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                            $CommandsCheckedBoxesSelected += New-Object psobject @{ 
                                Name           = $Entry.Text
                                Command        = $Command.Command_WinRM_PoSh
                                Properties     = $Command.Properties_PoSh
                                ExportFileName = $Command.ExportFileName
                                Type           = '(WinRM) PoSh'
                            }
                        }
                        if ($Entry.Checked -and $Entry -match '(WinRM)' -and $Entry -match 'WMI') {
                            $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                            $CommandsCheckedBoxesSelected += New-Object psobject @{ 
                                Name           = $Entry.Text
                                Command        = $Command.Command_WinRM_WMI
                                Properties     = $Command.Properties_WMI
                                ExportFileName = $Command.ExportFileName
                                Type           = "(WinRM) WMI"
                            }
                        }
                    <#    if ($Entry.Checked -and $Entry -match '(WinRS)' -and $Entry -match 'CMD') {
                                $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                                $CommandsCheckedBoxesSelected += New-Object psobject @{ 
                                    Name           = $Entry.Text
                                    Command        = $Command.Command_WinRS_CMD
                                    ExportFileName = $Command.ExportFileName
                                    Type           = "(WinRM) CMD"
                                }
                        }
                        if ($Entry.Checked -and $Entry -match '(WinRS)' -and $Entry -match 'WMIC') {
                                $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                                $CommandsCheckedBoxesSelected += New-Object psobject @{ 
                                    Name           = $Entry.Text
                                    Command        = $Command.Command_WinRS_WMIC
                                    ExportFileName = $Command.ExportFileName
                                    Type           = "(WinRM) WMIC"
                                }
                        } #>
                    }
                }
                if ($CommandsViewQueryRadioButton.Checked) {
                    foreach ($Entry in $Category.nodes) { 
                        # Counts the query nodes
                        if ($Entry.Checked) { $CountCommandQueries++}

                        # Builds the query that is selected
                        if ($Entry -match '(RPC)' -and $Entry -match 'CMD' -and $Entry.Checked) {
                            $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                            $CommandsCheckedBoxesSelected += New-Object psobject @{ 
                                Name           = $Entry.Text
                                Command        = $Command.Command_RPC_CMD
                                Arguments      = $Command.Command_RPC_CMD_Arg
                                ExportFileName = $Command.ExportFileName
                                Type           = "(RPC) CMD"
                            }
                        }
                        if ($Entry -match '(RPC)' -and $Entry -match 'PoSh' -and $Entry.Checked) {
                            $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                            $CommandsCheckedBoxesSelected += New-Object psobject @{ 
                                Name           = $Entry.Text
                                Command        = $Command.Command_RPC_PoSh
                                Properties     = $Command.Properties_PoSh
                                ExportFileName = $Command.ExportFileName
                                Type           = '(RPC) PoSh'
                            }
                        }
                        if (($Entry -match '(RPC)') -and  $Entry -match 'WMI' -and ($Entry -notmatch '(WinRS)') -and ($Entry -notmatch '(WinRM)') -and $Entry.Checked) {                        
                            $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                            $CommandsCheckedBoxesSelected += New-Object psobject @{ 
                                Name           = $Entry.Text
                                Command        = $Command.Command_WMI
                                Properties     = $Command.Properties_WMI
                                ExportFileName = $Command.ExportFileName
                                Type           = "(RPC) WMI"
                            }
                        }
                        if ($Entry -match '(WinRM)' -and $Entry -match 'CMD' -and $Entry.Checked) {
                            $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                            $CommandsCheckedBoxesSelected += New-Object psobject @{ 
                                Name           = $Entry.Text
                                Command        = $Command.Command_WinRM_CMD
                                ExportFileName = $Command.ExportFileName
                                Type           = "(WinRM) CMD"
                            }
                        }
                        if ($Entry -match '(WinRM)' -and $Entry -match 'Script' -and $Entry.Checked) {
                            $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                            $CommandsCheckedBoxesSelected += New-Object psobject @{ 
                                Name           = $Entry.Text
                                Command        = $Command.Command_WinRM_Script
                                #Properties     = $Command.Properties_Script
                                ExportFileName = $Command.ExportFileName
                                Type           = "(WinRM) Script"
                            }
                        }
                        if ($Entry -match '(WinRM)' -and $Entry -match 'PoSh' -and $Entry.Checked) {
                            $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                            $CommandsCheckedBoxesSelected += New-Object psobject @{ 
                                Name           = $Entry.Text
                                Command        = $Command.Command_WinRM_PoSh
                                Properties     = $Command.Properties_PoSh
                                ExportFileName = $Command.ExportFileName
                                Type           = '(WinRM) PoSh'
                            }
                        }
                        if ($Entry -match '(WinRM)' -and $Entry -match 'WMI' -and $Entry.Checked) {
                            $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                            $CommandsCheckedBoxesSelected += New-Object psobject @{ 
                                Name           = $Entry.Text
                                Command        = $Command.Command_WinRM_WMI
                                Properties     = $Command.Properties_WMI
                                ExportFileName = $Command.ExportFileName
                                Type           = "(WinRM) WMI"
                            }
                        }
                        
                    <#  
                        if ($Entry -match '(WinRS)' -and $Entry -match 'CMD' -and $Entry.Checked) {
                            $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                            $CommandsCheckedBoxesSelected += New-Object psobject @{ 
                                Name           = $Entry.Text
                                Command        = $Command.Command_WinRS_CMD
                                ExportFileName = $Command.ExportFileName
                                Type           = "(WinRM) CMD"
                            }
                        }
                        if ($Entry -match '(WinRS)' -and $Entry -match 'WMIC' -and $Entry.Checked) {
                            $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                            $CommandsCheckedBoxesSelected += New-Object psobject @{ 
                                Name           = $Entry.Text
                                Command        = $Command.Command_WinRS_WMIC
                                ExportFileName = $Command.ExportFileName
                                Type           = "(WinRM) WMIC"
                            }
                        }
                        #>                                        
                    }
                }
            }
        }
        $ProgressBarOverall.Maximum = $CountCommandQueries
        
        # Ensures that there are to lingering jobs in memory
        Get-Job -Name "PoSh-ACME:*" | Remove-Job -Force -ErrorAction SilentlyContinue

        # Iterates through selected commands and computers
        # Comamnds ran with credentials
        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {            
            if (!$script:Credential) { $script:Credential = Get-Credential }
            Foreach ($Command in $CommandsCheckedBoxesSelected) {
                $CollectionCommandStartTime = Get-Date 
                $StatusListBox.Items.Clear()
                $StatusListBox.Items.Add("Query: $($Command.Name)")                    
                $ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $($Command.Name)")
                Foreach ($TargetComputer in $ComputerList) {
                    $SavePath = "$($CollectionSavedDirectoryTextBox.Text)\Individual Host Results\$($Command.ExportFileName)"

                    # Creates the directory to save the results to
                    New-Item -ItemType Directory -Path $SavePath -Force

                    # Checks for the type of command selected and assembles the command to be executed
                    $OutputFileFileType = ""
                    if ($Command.Type -eq "(WinRM) CMD") {
                        $CommandString = "$($Command.Command) -ComputerName $TargetComputer -Credential $script:Credential"
                        $OutputFileFileType = "txt"
                    }
                    elseif (($Command.Type -eq "(RPC) WMI") -and ($Command.Command -match "Get-WmiObject")) {
                        $CommandString = "$($Command.Command) -ComputerName $TargetComputer -Credential $script:Credential | Select-Object -Property $($Command.Properties)"
                        $OutputFileFileType = "csv"
                    }
                    elseif (($Command.Type -eq "(RPC) WMI") -and ($Command.Command -match "Invoke-WmiMethod")) {
                        $CommandString = "$($Command.Command) -ComputerName $TargetComputer -Credential $script:Credential"
                        $OutputFileFileType = "txt"
                    }
                    elseif ($Command.Type -eq "(WinRM) Script") {
                        $CommandString = "$($Command.Command) -ComputerName $TargetComputer -Credential $script:Credential"
                        $OutputFileFileType = "csv"
                    }
                    elseif ($Command.Type -eq "(WinRM) PoSh") {
                        $CommandString = "$($Command.Command) -ComputerName $TargetComputer -Credential $script:Credential | Select-Object -Property $($Command.Properties)"
                        $OutputFileFileType = "csv"
                    }
                    elseif ($Command.Type -eq "(WinRM) WMI") {
                        $CommandString = "$($Command.Command) -ComputerName $TargetComputer -Credential $script:Credential | Select-Object -Property $($Command.Properties)"
                        $OutputFileFileType = "csv"
                    }
                    <#
                    elseif ($Command.Type -eq "(WinRM) CMD") {
                        # -username:<username> -password:<password>
                        $CommandString = "$($Command.Command)"
                        $OutputFileFileType = "txt"
                    }
                    elseif ($Command.Type -eq "(WinRM) WMIC") {
                        $CommandString = "$($Command.Command)"
                        $OutputFileFileType = "txt"
                    }
                    #>
                    elseif ($Command.Type -eq "(RPC) CMD") {
                        $CommandString = "$($Command.Command)$TargetComputer $($Command.Arguments)"
                        $OutputFileFileType = "txt"
                    }
                    elseif ($Command.Type -eq "(RPC) PoSh") {
                        $CommandString = "$($Command.Command) -ComputerName $TargetComputer -Credential $script:Credential | Select-Object -Property $($Command.Properties)"
                        $OutputFileFileType = "csv"
                    }

                    $CommandName = $Command.Name
                    $CommandType = $Command.Type
                    Start-Job -Name "PoSh-ACME: $CommandName -- $TargetComputer" -ScriptBlock {
                        param($OutputFileFileType, $SavePath, $CommandName, $CommandType, $TargetComputer, $CommandString)                      
                        # Available priority values: Low, BelowNormal, Normal, AboveNormal, High, RealTime
                        [System.Threading.Thread]::CurrentThread.Priority = 'High'
                        ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'High'
 
                        # Checks for the file output type, removes previous results with a file, then executes the commands
                        if ( $OutputFileFileType -eq "csv" ) {
                            $OutputFilePath = "$SavePath\$((($CommandName) -split ' -- ')[1]) - $CommandType - $($TargetComputer).csv"
                            Remove-Item -Path $OutputFilePath -Force -ErrorAction SilentlyContinue
                            Remove-Item -Path $OutputFilePath -Force -ErrorAction SilentlyContinue
                            Invoke-Expression -Command $CommandString | Export-Csv -Path $OutputFilePath -NoTypeInformation -Force
                        }
                        elseif ( $OutputFileFileType -eq "txt" ) {
                            $OutputFilePath = "$SavePath\$((($CommandName) -split ' -- ')[1]) - $CommandType - $($TargetComputer).txt"
                            Remove-Item -Path $OutputFilePath -Force -ErrorAction SilentlyContinue

                            if (($CommandType -eq "(RPC) WMI") -and ($CommandString -match "Invoke-WmiMethod") ) {
                                # This is to catch Invoke-WmiMethod commands because these commands will drop files on the target that we want to retrieve then remove
                                Invoke-Expression -Command $CommandString
                                Start-Sleep -Seconds 1
                                Move-Item   "\\$TargetComputer\c$\results.txt" "$OutputFilePath"
                                #Copy-Item   "\\$TargetComputer\c$\results.txt" "$OutputFilePath"
                                #Remove-Item "\\$TargetComputer\c$\results.txt"
                            }
                            else {
                                # Runs all other commands an saves them locally as a .txt file
                                Invoke-Expression -Command $CommandString | Out-File $OutputFilePath -Force
                            }
                        }
                    } -InitializationScript $null -ArgumentList @($OutputFileFileType, $SavePath, $CommandName, $CommandType, $TargetComputer, $CommandString)

                    # Logs the commands to file
                    $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $CommandString"
                    $LogMessage | Add-Content -Path $LogFile
                }
                # Monitors the progress of the Jobs and provides user status feedback. Jobs will also timeout, which the duration is a configurable
                Monitor-Jobs

                $CollectionCommandEndTime  = Get-Date                    
                $CollectionCommandDiffTime = New-TimeSpan -Start $CollectionCommandStartTime -End $CollectionCommandEndTime
                $ResultsListBox.Items.RemoveAt(0)
                $ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $($Command.Name)")

                # Compiles the CSVs into a single file for easier and faster viewing of results
                $StatusListBox.Items.Clear()
                $StatusListBox.Items.Add("Compiling CSV Results:  $((($Command.Name) -split ' -- ')[1])")
                Compile-CsvFiles -LocationOfCSVsToCompile "$SavePath\$((($Command.Name) -split ' -- ')[1]) - $($Command.Type)*.csv" -LocationToSaveCompiledCSV "$CollectedDataTimeStampDirectory\$((($Command.Name) -split ' -- ')[1]) - $($Command.Type).csv"
                $StatusListBox.Items.Clear()
                $StatusListBox.Items.Add("Finished Collecting Data!")
            
                $CompletedCommandQueries++
                $ProgressBarOverall.Value = $CompletedCommandQueries
            }
        }                 
        
        # Comamnds ran without credentials
        else {
            #======================================================================================================================================
            ######################################
            ##                                  ##
            ##  Queries executed independantly  ##
            ##                                  ##
            ######################################
            #======================================================================================================================================
            if ($CommandsTreeViewQueryAsIndividualRadioButton.checked -eq $true) {
                New-Item -Type Directory -Path $CollectionSavedDirectoryTextBox.Text -ErrorAction SilentlyContinue

                Foreach ($Command in $CommandsCheckedBoxesSelected) {
                    $CollectionCommandStartTime = Get-Date
                    $StatusListBox.Items.Clear()
                    $StatusListBox.Items.Add("Query: $($Command.Name)")                    
                    $ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $($Command.Name)")

                    # Each command to each target host is executed on it's own process thread, which utilizes more memory overhead on the localhost [running PoSh-ACME] and produces many more network connections to targets [noisier on the network].
                    Foreach ($TargetComputer in $ComputerList) {
                        $SavePath = "$($CollectionSavedDirectoryTextBox.Text)\Individual Host Results\$($Command.ExportFileName)"
                        # Creates the directory to save the results to
                        New-Item -ItemType Directory -Path $SavePath -Force

                        # Checks for the type of command selected and assembles the command to be executed
                        $OutputFileFileType = ""
                        if ($Command.Type -eq "(WinRM) CMD") {
                            $CommandString = "$($Command.Command) -ComputerName $TargetComputer"
                            $OutputFileFileType = "txt"
                        }
                        elseif (($Command.Type -eq "(RPC) WMI") -and ($Command.Command -match "Get-WmiObject")) {
                            $CommandString = "$($Command.Command) -ComputerName $TargetComputer | Select-Object -Property $($Command.Properties)"
                            $OutputFileFileType = "csv"
                        }
                        elseif (($Command.Type -eq "(RPC) WMI") -and ($Command.Command -match "Invoke-WmiMethod")) {
                            $CommandString = "$($Command.Command) -ComputerName $TargetComputer"
                            $OutputFileFileType = "txt"
                        }
                        elseif ($Command.Type -eq "(WinRM) Script") {
                            $CommandString = "$($Command.Command) -ComputerName $TargetComputer"
                            $OutputFileFileType = "csv"
                        }
                        elseif ($Command.Type -eq "(WinRM) PoSh") {
                            $CommandString = "$($Command.Command) -ComputerName $TargetComputer | Select-Object -Property $($Command.Properties)"
                            $OutputFileFileType = "csv"
                        }
                        elseif ($Command.Type -eq "(WinRM) WMI") {
                            $CommandString = "$($Command.Command) -ComputerName $TargetComputer | Select-Object -Property $($Command.Properties)"
                            $OutputFileFileType = "csv"
                        }
                        <#
                        elseif ($Command.Type -eq "(WinRM) CMD") {
                            # -username:<username> -password:<password>
                            $CommandString = "$($Command.Command)"
                            $OutputFileFileType = "txt"
                        }
                        elseif ($Command.Type -eq "(WinRM) WMIC") {
                            $CommandString = "$($Command.Command)"
                            $OutputFileFileType = "txt"
                        }
                        #>
                        elseif ($Command.Type -eq "(RPC) CMD") {
                            $CommandString = "$($Command.Command) \\$TargetComputer $($Command.Arguments)"
                            $OutputFileFileType = "txt"
                        }
                        elseif ($Command.Type -eq "(RPC) PoSh") {
                            $CommandString = "$($Command.Command) -ComputerName $TargetComputer | Select-Object -Property $($Command.Properties)"
                            $OutputFileFileType = "csv"
                        }

                        $CommandName = $Command.Name
                        $CommandType = $Command.Type

                        # Sends each query separetly to each computers, which produces a lot of network connections

                        Start-Job -Name "PoSh-ACME: $CommandName -- $TargetComputer" -ScriptBlock {
                            param($OutputFileFileType, $SavePath, $CommandName, $CommandType, $TargetComputer, $CommandString)                      
                            # Available priority values: Low, BelowNormal, Normal, AboveNormal, High, RealTime
                            [System.Threading.Thread]::CurrentThread.Priority = 'High'
                            ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'High'
 
                            # Checks for the file output type, removes previous results with a file, then executes the commands
                            if ( $OutputFileFileType -eq "csv" ) {
                                $OutputFilePath = "$SavePath\$((($CommandName) -split ' -- ')[1]) - $CommandType - $($TargetComputer).csv"
                                Remove-Item -Path $OutputFilePath -Force -ErrorAction SilentlyContinue
                                Invoke-Expression -Command $CommandString | Export-Csv -Path $OutputFilePath -NoTypeInformation -Force
                            }
                            elseif ( $OutputFileFileType -eq "txt" ) {
                                $OutputFilePath = "$SavePath\$((($CommandName) -split ' -- ')[1]) - $CommandType - $($TargetComputer).txt"
                                Remove-Item -Path $OutputFilePath -Force -ErrorAction SilentlyContinue

                                if (($CommandType -eq "(RPC) WMI") -and ($CommandString -match "Invoke-WmiMethod") ) {
                                    # This is to catch Invoke-WmiMethod commands because these commands will drop files on the target that we want to retrieve then remove
                                    Invoke-Expression -Command $CommandString
                                    Start-Sleep -Seconds 1
                                    Move-Item   "\\$TargetComputer\c$\results.txt" "$OutputFilePath"
                                    #Copy-Item   "\\$TargetComputer\c$\results.txt" "$OutputFilePath"
                                    #Remove-Item "\\$TargetComputer\c$\results.txt"
                                }
                                else {
                                    # Runs all other commands an saves them locally as a .txt file
                                    Invoke-Expression -Command $CommandString | Out-File $OutputFilePath -Force
                                }
                            }
                        } -InitializationScript $null -ArgumentList @($OutputFileFileType, $SavePath, $CommandName, $CommandType, $TargetComputer, $CommandString)

                        # Logs the commands to file
                        $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $CommandString"
                        $LogMessage | Add-Content -Path $LogFile
                    }
                    # Monitors the progress of the Jobs and provides user status feedback. Jobs will also timeout, which the duration is a configurable
                    Monitor-Jobs

                    $CollectionCommandEndTime  = Get-Date                    
                    $CollectionCommandDiffTime = New-TimeSpan -Start $CollectionCommandStartTime -End $CollectionCommandEndTime
                    $ResultsListBox.Items.RemoveAt(0)
                    $ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $($Command.Name)")

                    # Compiles the CSVs into a single file for easier and faster viewing of results
                    $StatusListBox.Items.Clear()
                    $StatusListBox.Items.Add("Compiling CSV Results:  $((($Command.Name) -split ' -- ')[1])")
                    Compile-CsvFiles -LocationOfCSVsToCompile "$SavePath\$((($Command.Name) -split ' -- ')[1]) - $($Command.Type)*.csv" -LocationToSaveCompiledCSV "$CollectedDataTimeStampDirectory\$((($Command.Name) -split ' -- ')[1]) - $($Command.Type).csv"
                    $StatusListBox.Items.Clear()
                    $StatusListBox.Items.Add("Finished Collecting Data!")

                    # This allows the Section progress bar to appear completed momentarily
                    $ProgressBarSection.Maximum = 1; $ProgressBarSection.Value = 1; Start-Sleep -Milliseconds 250
                    
                    # Increments the overall progress bar
                    $CompletedCommandQueries++
                    $ProgressBarOverall.Value = $CompletedCommandQueries                
                }
            }
            
            #======================================================================================================================================
            ####################################
            ##                                ##
            ##  Compile all Queries into one  ##
            ##                                ##
            ####################################
            #======================================================================================================================================
            elseif ($CommandsTreeViewQueryAsCompiledRadioButton.checked -eq $true) {
                $QueryCommands = @{}
                Foreach ($Command in $CommandsCheckedBoxesSelected) {
                    # Checks for the type of command selected and assembles the command to be executed
                    $OutputFileFileType = ""
                    if ($Command.Type -eq "(WinRM) CMD") {
                        $QueryCommands += @{ $Command.Name = @{ Name = $Command.Name ; Command = $Command.Command ; Properties = $Command.Properties }}
                    }
                    elseif (($Command.Type -eq "(RPC) WMI") -and ($Command.Command -match "Get-WmiObject")) {
                        $QueryCommands += @{ $Command.Name = @{ Name = $Command.Name ; Command = $Command.Command ; Properties = $Command.Properties }}
                    }
                    elseif (($Command.Type -eq "(RPC) WMI") -and ($Command.Command -match "Invoke-WmiMethod")) {
                        $QueryCommands += @{ $Command.Name = @{ Name = $Command.Name ; Command = $Command.Command ; Properties = $Command.Properties }}
                    }
                    elseif ($Command.Type -eq "(WinRM) Script") {
                        $QueryCommands += @{ $Command.Name = @{ Name = $Command.Name ; Command = $Command.Command ; Properties = $Command.Properties }}
                    }
                    elseif ($Command.Type -eq "(WinRM) PoSh") {
                        $QueryCommands += @{ $Command.Name = @{ Name = $Command.Name ; Command = $Command.Command ; Properties = $Command.Properties }}
                    }
                    elseif ($Command.Type -eq "(WinRM) WMI") {
                        $QueryCommands += @{ $Command.Name = @{ Name = $Command.Name ; Command = $Command.Command ; Properties = $Command.Properties }}
                    }
                    #elseif ($Command.Type -eq "(WinRM) CMD") {
                    #    # -username:<username> -password:<password>
                    #    $QueryCommands += @{ $Command.Name = @{ Name = $Command.Name ; Command = $Command.Command ; Properties = $Command.Properties }}
                    #}
                    #elseif ($Command.Type -eq "(WinRM) WMIC") {
                    #    $QueryCommands += @{ $Command.Name = @{ Name = $Command.Name ; Command = $Command.Command ; Properties = $Command.Properties }}
                    #}
                    elseif ($Command.Type -eq "(RPC) CMD") {
                        $QueryCommands += @{ $Command.Name = @{ Name = $Command.Name ; Command = $Command.Command ; Properties = $Command.Properties }}
                    }
                    elseif ($Command.Type -eq "(RPC) PoSh") {
                        $QueryCommands += @{ $Command.Name = @{ Name = $Command.Name ; Command = $Command.Command ; Properties = $Command.Properties }}
                    }
                    $CommandName = $Command.Name
                    $CommandType = $Command.Type
                }

                #------------------------------
                # Command Review and Edit Form
                #------------------------------
                $CommandReviewEditForm = New-Object System.Windows.Forms.Form -Property @{
                    width         = 1000
                    height        = 500
                    StartPosition = "CenterScreen"
                    Text          = ”Collection Script - Review, Edit, and Verify”
                    Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$ResourcesDirectory\favicon.ico")
                    ControlBox    = $true
                    Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
                }
                    #-------------------------------
                    # Command Reveiw and Edit Label
                    #-------------------------------
                    $CommandReviewEditLabel = New-Object System.Windows.Forms.Label -Property @{
                        Text      = "Edit The Script Block:"
                        ForeColor = "Blue"
                        Font      = New-Object System.Drawing.Font("$Font",14,0,0,0)
                        Location  = @{ X = 5
                                       Y = 8
                                     }
                        Size      = @{ Height = 25
                                       Width  = 160
                                     }
                    }
                    $CommandReviewEditForm.Controls.Add($CommandReviewEditLabel)

                    #--------------------------------------------
                    # Command Reveiw and Edit Enable RadioButton
                    #--------------------------------------------
                    $CommandReviewEditEnabledRadio = New-Object System.Windows.Forms.RadioButton -Property @{
                        Text      = "Yes"
                        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
                        Location  = @{ X = $CommandReviewEditLabel.Location.X + $CommandReviewEditLabel.Size.Width + 20
                                       Y = 5
                                     }
                        Size      = @{ Height = 25
                                       Width  = 50
                                     }
                        Checked   = $false
                    }
                    $CommandReviewEditEnabledRadio.Add_Click({ $CommandReviewEditTextbox.ReadOnly = $False })
                    $CommandReviewEditEnabledRadio.Add_MouseHover({
                        $ToolTip = New-Object System.Windows.Forms.ToolTip
                        if ($OptionShowToolTipCheckBox.Checked){
                            $Message = "⦿ The script below is generated by the selections made.
⦿ Use caustion if editing, charts use the hashtable name field.`n`n"
                            $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage123))
                            $ToolTip.Active         = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
                            $ToolTip.UseAnimation   = $true
                            $ToolTip.UseFading      = $true
                            $ToolTip.IsBalloon      = $true
                            $ToolTip.ToolTipIcon    = "Info"  #Error, Info, Warning, None
                            $ToolTip.ToolTipTitle   = 'Enable Script Editing'
                        }
                    })
                    $CommandReviewEditForm.Controls.Add($CommandReviewEditEnabledRadio)

                    #---------------------------------------------
                    # Command Reveiw and Edit Disable RadioButton
                    #---------------------------------------------
                    $CommandReviewEditDisabledRadio = New-Object System.Windows.Forms.RadioButton -Property @{
                        Text     = "No"
                        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
                        Location = @{ X = $CommandReviewEditEnabledRadio.Location.X + $CommandReviewEditEnabledRadio.Size.Width + 10
                                      Y = 5
                                    }
                        Size     = @{ Height = 25
                                      Width  = 50
                                    }
                        Checked  = $true
                    }
                    $CommandReviewEditDisabledRadio.Add_Click({ $CommandReviewEditTextbox.ReadOnly = $True })
                    $CommandReviewEditDisabledRadio.Add_MouseHover({
                        $ToolTip = New-Object System.Windows.Forms.ToolTip
                        if ($OptionShowToolTipCheckBox.Checked){
                            $Message = "⦿ The script below is generated by the selections made.
⦿ Use caustion if editing, charts use the hashtable name field.`n`n"
                            $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage123))
                            $ToolTip.Active         = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
                            $ToolTip.UseAnimation   = $true
                            $ToolTip.UseFading      = $true
                            $ToolTip.IsBalloon      = $true
                            $ToolTip.ToolTipIcon    = "Info"  #Error, Info, Warning, None
                            $ToolTip.ToolTipTitle   = 'Disable Script Editing'
                        }
                    })
                    $CommandReviewEditForm.Controls.Add($CommandReviewEditDisabledRadio)

                    #-----------------------------------------
                    # Command Reveiw and Edit Verify Checkbox
                    #-----------------------------------------
                    $CommandReviewEditVerifyCheckbox = New-Object System.Windows.Forms.Checkbox -Property @{
                        Text      = "Verify"
                        Font      = New-Object System.Drawing.Font("$Font",14,0,0,0)
                        Location  = @{ X = 805
                                       Y = 6
                                     }
                        Size      = @{ Height = 25
                                       Width  = 65
                                     }
                        Checked   = $false
                    }
                    $CommandReviewEditVerifyCheckbox.Add_Click({
                        if ($CommandReviewEditVerifyCheckbox.checked){
                            $CommandReviewEditExecuteButton.Text      = "Execute"
                            $CommandReviewEditExecuteButton.ForeColor = "Green"
                        }
                        else {
                            $CommandReviewEditExecuteButton.Text      = "Cancel"
                            $CommandReviewEditExecuteButton.ForeColor = "Red"                
                        }
                
                    })
                    $CommandReviewEditForm.Controls.Add($CommandReviewEditVerifyCheckbox)

                    #----------------------------------------
                    # Command Reveiw and Edit Execute Button
                    #----------------------------------------
                    $CommandReviewEditExecuteButton = New-Object System.Windows.Forms.Button -Property @{
                        Text      = "Cancel"
                        ForeColor = "Red"
                        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
                        Location  = @{ X = 879
                                       Y = 5
                                     }
                        Size      = @{ Height = 25
                                       Width  = 100
                                     }
                    }
                    $CommandReviewEditExecuteButton.Add_Click({ $CommandReviewEditForm.close() })
                    $CommandReviewEditExecuteButton.Add_MouseHover({
                        $ToolTip = New-Object System.Windows.Forms.ToolTip
                        if ($OptionShowToolTipCheckBox.Checked){
                            $Message = "⦿ To Cancel, you need to uncheck the verify box.
⦿ To Execute, you first need to check the verify box.
⦿ First verify the contents of the script and edit if need be.
⦿ When executed, the compiled script is ran against each selected computer.
⦿ The results return as one object, then are locally extracted and saved individually.
⦿ The results for each section are saved individually by host and query.
⦿ The results are also compiled by query into a single file containing every host.
⦿ The code is executed within a PowerShel Job for each destination host.
⦿ The compiled commands reduce the amount of network traffic.
⦿ This method is faster, but requires more RAM on the target host.
⦿ Use caustion if editing, charts use the hashtable name field.`n`n"
                            $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage123))
                            $ToolTip.Active         = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
                            $ToolTip.UseAnimation   = $ 
                            $ToolTip.UseFading      = $true
                            $ToolTip.IsBalloon      = $true
                            $ToolTip.ToolTipIcon    = "Info"  #Error, Info, Warning, None
                            $ToolTip.ToolTipTitle   = 'Cancel or Execute'
                        }
                    })
                    $CommandReviewEditForm.Controls.Add($CommandReviewEditExecuteButton)

                    #--------------------------------
                    # Command Reveiw and Edit String
                    #--------------------------------
# This is the string that contains the command(s) to query, it is iterated over $targetcomputer
$CommandReviewString = @"
Invoke-Command -ComputerName `$TargetComputer -ScriptBlock {
    param(`$TargetComputer) 
    `$QueryResults = @{}


"@

ForEach ($Query in $($QueryCommands.keys)) {
#$QueryString = "$($QueryCommands[$Query]['Command']) | Select-Object -Property $($QueryCommands[$Query]['Properties'])"
    if ($($QueryCommands[$Query]['Properties']) -eq $null) {
    $CommandReviewString += @"
    `$QueryResults += @{
        '$($QueryCommands["$Query"]["Name"])' = @{
            'Name'    = "$($QueryCommands[$Query]['Name']) -- `$TargetComputer"
            'Results' = `$($($QueryCommands[$Query]['Command']))
        }
    }


"@
    }
    else {
    $CommandReviewString += @"
    `$QueryResults += @{
        '$($QueryCommands["$Query"]["Name"])' = @{
            'Name'    = "$($QueryCommands[$Query]['Name']) -- `$TargetComputer"
            'Results' = `$($($QueryCommands[$Query]['Command']) | Select-Object -Property $($QueryCommands[$Query]['Properties']))
        }
    }


"@
    }
}
$CommandReviewString += @"
    return `$QueryResults                           
} -ArgumentList @(`$TargetComputer)
"@
                    #---------------------------------
                    # Command Review and Edit Textbox
                    #---------------------------------
                    $CommandReviewEditTextbox = New-Object System.Windows.Forms.TextBox -Property @{
                        Location = @{ X = 5
                                      Y = 35
                                    }
                        Size     = @{ Height = 422
                                      Width  = 974
                                    }
                        Font       = New-Object System.Drawing.Font("Courier New",11,0,0,0)
                        Text       = $CommandReviewString
                        Multiline  = $True
                        ScrollBars = 'Vertical'
                        WordWrap   = $True
                        ReadOnly   = $True
                    }
                    $CommandReviewEditForm.Controls.Add($CommandReviewEditTextbox)
            
                $CommandReviewEditForm.ShowDialog() | Out-Null 
    
                if ($CommandReviewEditVerifyCheckbox.checked){
                    New-Item -Type Directory -Path $CollectionSavedDirectoryTextBox.Text -ErrorAction SilentlyContinue
 
                    $StatusListBox.Items.Clear()
                    $StatusListBox.Items.Add("Compiled Queries To Target Hosts")                    
                    #$ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $($TargetComputer)")

                    $CollectionCommandStartTime = Get-Date
    #                ForEach ($Query in $($QueryCommands.keys)) {
    #                    $ResultsListBox.Items.Insert(0,"")
    #                    $ResultsListBox.Items.Insert(0,"$($QueryCommands[$Query]['Command'])")
    #                    $ResultsListBox.Items.Insert(0,"$($QueryCommands[$Query]['Name'])")
    #                }

                    # Clear any PoSh-ACME Jobs
                    $ClearJobs = Get-Job -Name 'PoSh-ACME*'
                    $ClearJobs | Stop-Job
                    $ClearJobs | Receive-Job -Force
                    $ClearJobs | Remove-Job -Force

                    # Each command to each target host is executed on it's own process thread, which utilizes more memory overhead on the localhost [running PoSh-ACME] and produces many more network connections to targets [noisier on the network].
                    Foreach ($TargetComputer in $ComputerList) {

                        # Logs the commands to file
                        $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Sent to $($TargetComputer): `r`n$($CommandReviewEditTextbox.text)"
                        $LogMessage | Add-Content -Path $LogFile 

                        # Executes the compiled jobs
                        $CommandReviewEditTextboxText = $CommandReviewEditTextbox.Text
                        Start-Job -Name "PoSh-ACME: $CommandName -- $TargetComputer" -ScriptBlock {
                            param($TargetComputer, $CommandReviewEditTextboxText)
                            # Available priority values: Low, BelowNormal, Normal, AboveNormal, High, RealTime
                            [System.Threading.Thread]::CurrentThread.Priority = 'High'
                            ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'High'

                            Invoke-Expression -Command $CommandReviewEditTextboxText
                        } -InitializationScript $null -ArgumentList @($TargetComputer, $CommandReviewEditTextboxText)
                    }
                    






<#
#############                            function Monitor-Jobs {

                                do {

        
                                    Get-Job -Name "PoSh-ACME:*" | Receive-Job -Force


                                    # Gets a host list of the Jobs
                                    $ACME_Jobs = $CurrentJobs | Where-Object State -eq Running | Select-Object -ExpandProperty Name
                                    $JobsHosts = ''
                                    foreach ($job in $ACME_Jobs) { $JobsHosts += $($($job -replace 'PoSh-ACME: ','' -split '--')[2])}
                                    $JobsHosts = $JobsHosts -replace ' ',', ' -replace ", $","" -replace "^,",""
        
                                    $StatusListBox.Items.Clear()
                                    $StatusListBox.Items.Add("Processing: $JobsHosts")

                                    #$CurrentJobs | Out-File $env:TEMP\scrapjobs.txt
                                    #Get-Content $env:TEMP\scrapjobs.txt
                                    $jobscount = $CurrentJobs.count                  
                                    $ProgressBarSection.Maximum = $jobscount

                                    # Counts the total of completed jobs for each update
                                    $done = 0
                                    foreach ($job in $CurrentJobs) {
                                        $mystate = $job.state
                                        if ($mystate -eq "Completed") {$done++}
                                    }
                                    $ProgressBarSection.Value = $done + 1
        
                                    # Calcualtes and formats time elaspsed
                                    $CurrentTime = Get-Date
                                    $Timecount   = $JobsLaunch - $CurrentTime        
                                    $hour        = [Math]::Truncate($Timecount)
                                    $minute      = ($CollectionTime - $hour) * 60
                                    $second      = [int](($minute - ([Math]::Truncate($minute))) * 60)
                                    $minute      = [Math]::Truncate($minute)
                                    $Timecount   = [datetime]::Parse("$hour`:$minute`:$second")

                                    # Provides updates on the jobs
                                    $ResultsListBox.Items.Insert(0,"Running Jobs:  $($jobscount - $done)")        
                                    $ResultsListBox.Items.Insert(1,"Current Time:  $currentTime")
                                    $ResultsListBox.Items.Insert(2,"Elasped Time:  $($Timecount -replace '-','')")
                                    $ResultsListBox.Items.Insert(3,"")
                                    $ExecutionStatusCheckedListBox.Items.Add("$JobsHosts")

                                    # This is how often PoSoh-ACME's GUI will refresh when provide the status of the jobs
                                    # Default have is 250 ms. If you change this, be sure to update the $StatisticsUpdateInterval variarible within this function
                                    Start-Sleep -Milliseconds $SleepMilliseconds

                                    
                                    $CompletedJobs = @()
                                    foreach ($Job in $CurrentJobs) {
                                        #if ($Job.PSBeginTime -lt $(Get-Date).AddSeconds(-$JobsTimer)) {
                                        #    $TimeStamp = $(Get-Date).ToString('yyyy/MM/dd HH:mm:ss')
                                        #    $ResultsListBox.Items.insert(5,"$($TimeStamp)   - Job Timed Out: $((($Job | Select-Object -ExpandProperty Name) -split '-')[3])")
                                        #    $Job | Stop-Job 
                                        #    $Job | Receive-Job -Force 
                                        #    $Job | Remove-Job -Force
                                        #    break        
                                        #}
                                        if (($Job.State -eq 'Completed') -and ($Job.Name -notin $CompletedJobs)) {
                                            $TargetComputerCount -= 1
                                            $CompletedJobs += $Job.Name
                                            $CollectionCommandEndTime  = Get-Date                    
                                            $CollectionCommandDiffTime = New-TimeSpan -Start $CollectionCommandStartTime -End $CollectionCommandEndTime
                                            #$ResultsListBox.Items.RemoveAt(0)
                                            $ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$($CollectionCommandDiffTime)]  Completed: $(($Job.Name).split('--')[-1].trim())")
                                        }
                                    }
                                    #$ResultsListBox.Items.RemoveAt(0)
                                    #$ResultsListBox.Items.RemoveAt(0)
                                    $ResultsListBox.Items.RemoveAt(0)
                                    $ResultsListBox.Items.RemoveAt(0)
                                    $ResultsListBox.Items.RemoveAt(0)
                                    $ResultsListBox.Items.RemoveAt(0)       
                                } while ($done -lt $jobscount)


##########                            }
#>






















<#
                                # Initially updates statistics
                                $StatisticsResults = Get-PoShACMEStatistics
                                $StatisticsNumberOfCSVs.text = $StatisticsResults        

                                $ProgressBarSection.Value = 0
                                $JobsLaunch = Get-Date 
                                $JobsTimer  = [int]$($OptionJobTimeoutSelectionComboBox.Text)
    
                                $SleepMilliseconds = 250

                                # This is how often the statistics page updates, be default it is 20 which is 5 seconds (250 ms x 4)
                                $StatisticsUpdateInterval      = (1000 / $SleepMilliseconds) * $OptionStatisticsUpdateIntervalCombobox.text
                                $StatisticsUpdateIntervalCount = 0
#>















                    # Checks Jobs for completion
                    $TargetComputerCount = $ComputerList.count
                    $CompletedJobs = @()
                    $ResultsListBox.Items.Insert(0,"")

                    # The number of Jobs created by PoSh-ACME
                    $PoShACMEJobs = Get-Job -Name "PoSh-ACME:*"

                    While ($TargetComputerCount -gt 0) {
<#                        # Updates Statistics 
                        $StatisticsUpdateIntervalCount++
                        if (($StatisticsUpdateIntervalCount % $StatisticsUpdateInterval) -eq 0) {
                            $StatisticsResults = Get-PoShACMEStatistics
                            $StatisticsNumberOfCSVs.text = $StatisticsResults        
                        }
#>                        
                        foreach ($Job in $PoShACMEJobs) {
                            if (($Job.State -eq 'Completed') -and ($Job.Name -notin $CompletedJobs)) {
                                $TargetComputerCount -= 1
                                $CompletedJobs += $Job.Name
                                $CollectionCommandEndTime  = Get-Date                    
                                $CollectionCommandDiffTime = New-TimeSpan -Start $CollectionCommandStartTime -End $CollectionCommandEndTime
                                #$ResultsListBox.Items.RemoveAt(0)
                                $ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$($CollectionCommandDiffTime)]  Completed: $(($Job.Name).split('--')[-1].trim())")
                            }
                        }
                        Start-Sleep -Seconds 1                    
                    }
                    
                    # Extracts individual query data from each jobs
                    $ProgressBarSection.enabled = $false
                    $ProgressBarOverall.maximum = $PoShACMEJobs.count
                    $ProgressBarOverallCount    = 0

                    $CollectionTypes = @()
                    foreach ($Job in $PoShACMEJobs) {
                        if ($Job.Name -ne '' -and $Job.Command -ne '' -and $Job.Name -ne $null -and $Job.Command -ne $null) {
                            # Writes output of single query collection as multiple separate files
                            # Excludes system properties that begin with __
                        
                            $QueryFileName = $(($Job.Name -split ':')[1]).Trim()
                            $ReceivedJob   = $(Receive-Job -Name "$($Job.Name)") 
                            Foreach ($key in $($ReceivedJob.keys)){
                                $Type     = (($ReceivedJob[$key]['Name'] -split '--').trim())[0]
                                $Query    = (($ReceivedJob[$key]['Name'] -split '--').trim())[1]
                                $Hostname = (($ReceivedJob[$key]['Name'] -split '--').trim())[2]
                                $SavePath = "$($CollectionSavedDirectoryTextBox.Text)\Individual Host Results\$Query"
 
                                # Creates the directory to save the results to
                                New-Item -ItemType Directory -Path $SavePath -Force

                                # Saves results
                                $ReceivedJob[$key]['Results'] | Select-Object -Property * -ExcludeProperty __* | Export-Csv "$SavePath\$($Query) - $($Type) - $($Hostname).csv" -NoTypeInformation

                                # Creates a list of each type of collection, this is to be used later for compiling results
                                if ("$SavePath\$($Query) - $($Type)*.csv" -notin $CollectionTypes) {
                                    $CollectionTypes += "$SavePath\$($Query) - $($Type)*.csv"
                                    $ProgressBarOverallCount++
                                }
                            } 
                        }
                        Remove-Job -Name "$($Job.Name)" -Force
                    }












<#
                                # Updates Statistics One last time
                                $StatisticsResults = Get-PoShACMEStatistics
                                $StatisticsNumberOfCSVs.text = $StatisticsResults        
                                Get-Job -Name "PoSh-ACME:*" | Remove-Job -Force -ErrorAction SilentlyContinue
                                Start-Sleep -Seconds 1
#>













































                    # Compile results 
                    $StatusListBox.Items.Clear()
                    $StatusListBox.Items.Add("Compiling CSV Results From Target Hosts")                    
                    foreach ($Collection in $CollectionTypes) {
                        $CompiledFileName = "$(($Collection).split('\')[-1].split('*')[0]).csv"
                        Compile-CsvFiles -LocationOfCSVsToCompile $Collection -LocationToSaveCompiledCSV "$CollectedDataTimeStampDirectory\$($CompiledFileName)"
                    }
                    $StatusListBox.Items.Clear()
                    $StatusListBox.Items.Add("Finished Collecting Data!")
                }
                else {
                    $StatusListBox.Items.Clear()
                    $StatusListBox.Items.Add("ALERT: Query Cancelled!")
                    $ResultsListBox.Items.Insert(0,"ALERT: The query has been cancelled!")
                }
            }
        }

        #########################################
        ##                                     ##
        ##  Executes the other query sections  ##
        ##                                     ##
        #########################################
        # Counts and Executes the following sections if checked
        if ($FileSearchDirectoryListingCheckbox.Checked)             { $CountCommandQueries++ ; FileSearchDirectoryListingCommand }
        if ($FileSearchFileSearchCheckbox.Checked)                   { $CountCommandQueries++ ; FileSearchFileSearchCommand }
        if ($FileSearchAlternateDataStreamCheckbox.Checked)          { $CountCommandQueries++ ; FileSearchAlternateDataStreamCommand } 
        if ($SysinternalsSysmonCheckbox.Checked)                     { $CountCommandQueries++ ; SysinternalsSysmonCommand -SysmonXMLPath $script:SysmonXMLPath -SysmonXMLName $script:SysmonXMLName }
        if ($SysinternalsAutorunsCheckbox.Checked)                   { $CountCommandQueries++ ; SysinternalsAutorunsCommand }
        if ($SysinternalsProcessMonitorCheckbox.Checked)             { $CountCommandQueries++ ; SysinternalsProcessMonitorCommand -SysinternalsProcessMonitorTime $SysinternalsProcessMonitorTimeComboBox.Text }        
        if ($EventLogsEventIDsManualEntryCheckbox.Checked)           { $CountCommandQueries++ ; EventLogsEventCodeManualEntryCommand }
        if ($EventLogsEventIDsIndividualSelectionCheckbox.Checked)   { $CountCommandQueries++ ; EventLogsEventCodeIndividualSelectionCommand }
        if ($NetworkConnectionSearchRemoteIPAddressCheckbox.checked) { $CountCommandQueries++ ; NetworkConnectionRemoteIPAddressCommand }
        if ($NetworkConnectionSearchRemotePortCheckbox.checked)      { $CountCommandQueries++ ; NetworkConnectionRemotePortCommand }
        if ($NetworkConnectionSearchProcessCheckbox.checked)         { $CountCommandQueries++ ; NetworkConnectionProcessCommand }
        if ($NetworkConnectionSearchDNSCacheCheckbox.checked)        { $CountCommandQueries++ ; NetworkConnectionSearchDNSCacheCommand }
        if ($EventLogsQuickPickSelectionCheckbox.Checked) {
            foreach ($Query in $script:EventLogQueries) {
                if ($EventLogsQuickPickSelectionCheckedlistbox.CheckedItems -match $Query.Name) {
                    $CountCommandQueries++
                    Query-EventLog -CollectionName $Query.Name -Filter $Query.Filter
                }
            }
        }        

        ########################################
        ##                                    ##
        ##  The end of the collection script  ##
        ##                                    ##
        ########################################    
        $CollectionTimerStop = Get-Date
        $ResultsListBox.Items.Insert(0,"$(($CollectionTimerStop).ToString('yyyy/MM/dd HH:mm:ss'))  Finished Collecting Data!")

        $CollectionTime = New-TimeSpan -Start $CollectionTimerStart -End $CollectionTimerStop
        $ResultsListBox.Items.Insert(1,"   $CollectionTime  Total Elapsed Time")
        $ResultsListBox.Items.Insert(2,"====================================================================================================")
        $ResultsListBox.Items.Insert(3,"")        

        # Makes sure that the Progress Bars are full at the end of collection
        $ProgressBarSection.Maximum = 1
        $ProgressBarSection.Value   = 1
        $ProgressBarOverall.Maximum = 1
        $ProgressBarOverall.Value   = 1
      
        #-----------------------------
        # Plays a Sound When Finished
        #-----------------------------
        [system.media.systemsounds]::Exclamation.play()

        #----------------------
        # Text To Speach (TTS)
        #----------------------
        if ($OptionTextToSpeachCheckBox.Checked -eq $true) {
            Add-Type -AssemblyName System.speech
            $speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
            Start-Sleep -Seconds 1

            # TTS for Query Count
            if ($CountCommandQueries -eq 1) {$TTSQuerySingularPlural = "query"}
            else {$TTSQuerySingularPlural = "queries"}

            # TTS for TargetComputer Count
            if ($ComputerList.Count -eq 1) {$TTSTargetComputerSingularPlural = "host"}
            else {$TTSTargetComputerSingularPlural = "hosts"}
        
            # Say Message
            if (($CountCommandQueries -eq 0) -and ($CountTargetComputer -eq 0)) {$speak.Speak("You need to select at least one query and target host.")}
            else {
                if ($CountCommandQueries -eq 0) {$speak.Speak("You need to select at least one query.")}
                if ($CountTargetComputer -eq 0) {$speak.Speak("You need to select at least one target host.")}
                else {$speak.Speak("PoSh-ACME has completed $CountCommandQueries $TTSQuerySingularPlural against $CountTargetComputer $TTSTargetComputerSingularPlural.")}
            }        
        }
    }
    $Section2TabControl.SelectedTab   = $Section2MainTab
}
# This needs to be here to execute the script
# Note the Execution button itself is located in the Select Computer section
$ComputerListExecuteButton1.Add_Click($ExecuteScriptHandler)
$ComputerListExecuteButton2.Add_Click($ExecuteScriptHandler)

#Save the initial state of the form
$InitialFormWindowState = $PoShACME.WindowState

#Init the OnLoad event to correct the initial state of the form
$PoShACME.add_Load($OnLoadForm_StateCorrection)

#Show the Form
$PoShACME.ShowDialog() | Out-Null 


} #End Function

# Call the PoSh-ACME Function
PoSh-ACME_GUI

