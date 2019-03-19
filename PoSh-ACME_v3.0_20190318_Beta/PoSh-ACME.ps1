<#
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
     Version        : v.2.3 Beta

     Author         : high101bro
     Email          : high101bro@gmail.com
     Website        : https://github.com/high101bro/PoSH-ACME

     Requirements   : PowerShell v3 or Higher
                    : WinRM  (Default Port 5986)
     Optional       : PSExec.exe, Procmon.exe, Autoruns.exe 
        		    : Can run standalone, but works best with the Resources folder!
     Updated        : 19 Dec 18
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

    Troubleshooting remote connection failures
        about_Remote_Troubleshooting
        about_Remote
        about_Remote_Requirements
                        
    .EXAMPLE
        This will run PoSh-ACME.ps1 and provide prompts that will tailor your collection.
             PowerShell.exe -ExecutionPolicy ByPass -NoProfile -File .\PoSh-ACME.ps1

    .Link
        https://github.com/high101bro/PoSH-ACME
        http://lmgtfy.com/?q=high101bro+PoSH-ACME

    .NOTES  
        Remember this is a script, not a program. So when it's conducting its queries the 
        GUI will be unresponsive to user interaction even though you are able to view 
        status and timer updates.

        In order to run the script:
        - Update locally
            Open a PowerShell terminal with Administrator privledges
              - Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process
              - Get-ExecutionPolicy -List

        - Update via GPO
            Open the GPO for editing. In the GPO editor, select:
              - Computer Configuration > Policies > Administrative Templates > Windows Components > Windows PowerShell
              - Right-click "Turn on script execution", then select "Edit"
              - In the winodws that appears, click on "Enabled" radio button
              - Under "Execution Policy", select "Allow All Scripts"
              - Click on "Ok", then close the GPO Editor
              - Push out GPO Updates, or on the computer's powershell/cmd terminal, type in `"gpupdate /force"
#>


# Check if the script is running with Administrator Privlieges, if not it will attempt to re-run and prompt for credentials
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic")
    $verify = [Microsoft.VisualBasic.Interaction]::MsgBox(`
        "Attention Under-Privileged User!`n   $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)`n`nThe remote commands executed to collect data require elevated credentials. You can either run this script with elevated privileges or provide them later by selecting the checkbox 'Use Credentials'.",`
        'YesNoCancel,Question',`
        "PoSh-ACME")
    switch ($verify) {
    'Yes'{
        $arguments = "& '" + $myinvocation.mycommand.definition + "'"
        Start-Process powershell -WindowStyle Hidden -Verb runAs -ArgumentList $arguments
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
    $LogFile                                  = "$PoShHome\LogFile.txt"
    $IPListFile                               = "$PoShHome\iplist.txt"
    $CustomPortsToScan                        = "$PoShHome\CustomPortsToScan.txt"
    $ComputerListTreeViewFileAutoSave         = "$PoShHome\Computer List TreeView (Auto-Save).csv"
    $ComputerListTreeViewFileSave             = "$PoShHome\Computer List TreeView (Saved).csv"

    $OpNotesFile                              = "$PoShHome\OpNotes.txt"
    $OpNotesWriteOnlyFile                     = "$PoShHome\OpNotes (Write Only).txt"

    # Name of Collected Data Directory
    $CollectedDataDirectory                   = "$PoShHome\Collected Data"
        # Location of separate queries
        $CollectedDataTimeStampDirectory      = "$CollectedDataDirectory\$((Get-Date).ToString('yyyy-MM-dd @ HHmm ss'))"
        # Location of Uncompiled Results
        $IndividualHostResults                = "$CollectedDataTimeStampDirectory\Individual Host Results"
    
    # Location of Resources directory
    $ResourcesDirectory = "$PoShHome\Resources"
        # Location of Host Commands Notes
        $CommandsHostDirectoryNotes           = "$ResourcesDirectory\Commands - Host"
        # Location of Host Commands Scripts
        $CommandsHostDirectoryScripts         = "$ResourcesDirectory\Commands - Host\Scripts"
        # Location of Event Logs Commands directory
        $CommandsEventLogsDirectory           = "$ResourcesDirectory\Commands - Event Logs"
        # Location of Active Directory Commands directory
        $CommandsActiveDirectory              = "$ResourcesDirectory\Commands - Active Directory"
        # Location of External Programs directory
        $ExternalPrograms                     = "$ResourcesDirectory\External Programs"
        $PSExecPath                           = "$ExternalPrograms\PsExec.exe"

        # CSV list of Event IDs numbers, names, and description
        $EventIDsFile                         = "$ResourcesDirectory\Event IDs.csv"

        $EventLogsWindowITProCenter           = "$CommandsEventLogsDirectory\Individual Selection\Event Logs to Monitor - Window IT Pro Center.csv"
        # CSV list of Event IDs numbers, names, and description
        $TagAutoListFile                      = "$ResourcesDirectory\Tags - Auto Populate.txt"

# Logs what account ran the script and when
$LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - PoSh-ACME executed by: $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"
$LogMessage | Add-Content -Path $LogFile

# The Font Used
$Font = "Courier"

$SleepTime = 5

# Number of jobs simultaneously when collecting data
$ThrottleLimit = 32

# Clears out Computer List variable
$ComputerList = ""

# Credentials will be stored in this variable
$script:Credential = ""

#============================================================================================================================================================
# Function Name 'ListComputers' - Takes entered domain and lists all computers
#============================================================================================================================================================

Function ListComputers([string]$Choice,[string]$Script:Domain) {
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
	elseif($Choice -eq "Manual")
    {
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
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Your file was empty. You must select a file with at least one computer in it.")        
        $file_Dialog.Close()
        #. ListTextFile 
        }
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

#============================================================================================================================================================
# Function Name 'SingleEntry' - Enumerates Computer from user input
#============================================================================================================================================================
Function SingleEntry {
    $Comp = $SingleHostIPTextBox.Text
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

# Used with the Listbox features to select one host from a list
Function SelectListBoxEntry {
    $Comp = $ComputerListBox.SelectedItems
    If ($Comp -eq $Null) { . SelectListBoxEntry } 
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

#============================================================================================================================================================
# Create Directory and Files
#============================================================================================================================================================
New-Item -ItemType Directory -Path "$PoShHome" -Force | Out-Null 

#============================================================================================================================================================
# PoSh-ACME Form
#============================================================================================================================================================

# This fuction is what generates the who GUI and contains the majority of the script
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
$PoShACME.ClientSize    = $System_Drawing_Size
#$PoShACME.Topmost = $true
$PoShACME.Top = $true
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

# Varables to Control Section 1 Tab Control
$Section1TabControlRightPosition  = 5
$Section1TabControlDownPosition   = 5
$Section1TabControlBoxWidth       = 460
$Section1TabControlBoxHeight      = 590

$Section1TabControl               = New-Object System.Windows.Forms.TabControl
$Section1TabControl.Name          = "Main Tab Window"
$Section1TabControl.SelectedIndex = 0
$Section1TabControl.ShowToolTips  = $True
$Section1TabControl.Location      = New-Object System.Drawing.Size($Section1TabControlRightPosition,$Section1TabControlDownPosition) 
$Section1TabControl.Size          = New-Object System.Drawing.Size($Section1TabControlBoxWidth,$Section1TabControlBoxHeight) 
$PoShACME.Controls.Add($Section1TabControl)

##############################################################################################################################################################
##
## Section 1 Collections SubTab
##
##############################################################################################################################################################

$Section1CollectionsTab          = New-Object System.Windows.Forms.TabPage
$Section1CollectionsTab.Text     = "Collections"
$Section1CollectionsTab.Name     = "Collections Tab"
$Section1CollectionsTab.UseVisualStyleBackColor = $True
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
<#
function Conduct-PreCommandExecution {
    param($CollectedDataTimeStampDirectory, $IndividualHostResults, $CollectionName)

    # Creates variables used for saving files
    #deprecated# $Global:CollectionName = $CollectionName
    #deprecated# $Global:CollectionShortName = $CollectionName -replace ' ',''

    # Creates directory for the collection
    New-Item -ItemType Directory -Name "$($CollectedDataTimeStampDirectory)\$($CollectionName)" -Force -ErrorAction SilentlyContinue | Out-Null

    # Provides updates to the status and main listbox
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Collecting Data: $CollectionName")
    $ResultsListBox.Items.Insert(0,"")
    $ResultsListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")
}#>

function Conduct-PreCommandCheck {
    param($CollectedDataTimeStampDirectory, $IndividualHostResults, $CollectionName, $TargetComputer)

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    # Removes the individual results
    Remove-Item -Path "$($IndividualHostResults)\$($CollectionName)\$($CollectionName)-$($TargetComputer).csv" -Force -ErrorAction SilentlyContinue
    # Removes the compiled results
    Remove-Item -Path "$($CollectedDataTimeStampDirectory)\$($CollectionName).csv" -Force -ErrorAction SilentlyContinue
    # Creates a directory to save compiled results
}

function Create-LogEntry {
    param(
        $TargetComputer,
        $LogFile
    )
    # Creates a log entry to an external file
    $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  $TargetComputer`: $CollectionName"
    $LogMessage | Add-Content -Path $LogFile
}

function Conduct-PostCommandExecution {
    param($CollectionName)

    # Provides updates to the status and main listbox
    $ResultsListBox.Items.RemoveAt(0)
    $ResultsListBox.Items.RemoveAt(0)
    $ResultsListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  Completed: $CollectionName")
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Finished Collecting Data!")
}

#####################################################################################################################################
##
## Section 1 Collections TabControl
##
#####################################################################################################################################

# The TabControl controls the tabs within it
$Section1CollectionsTabControl               = New-Object System.Windows.Forms.TabControl
$Section1CollectionsTabControl.Name          = "Collections TabControl"
$Section1CollectionsTabControl.Location      = New-Object System.Drawing.Size($TabRightPosition,$TabhDownPosition)
$Section1CollectionsTabControl.Size          = New-Object System.Drawing.Size($TabAreaWidth,$TabAreaHeight) 
$Section1CollectionsTabControl.ShowToolTips  = $True
$Section1CollectionsTabControl.SelectedIndex = 0
$Section1CollectionsTab.Controls.Add($Section1CollectionsTabControl)

############################################################################################################
# Section 1 Queries SubTab
############################################################################################################

# Varables for positioning checkboxes
$QueriesRightPosition     = 5
$QueriesDownPositionStart = 10
$QueriesDownPosition      = 10
$QueriesDownPositionShift = 25

$QueriesBoxWidth          = 410
$QueriesBoxHeight         = 25


#-------------
# Queries Tab
#-------------

$Section1CommandsTab          = New-Object System.Windows.Forms.TabPage
$Section1CommandsTab.Location = $System_Drawing_Point
$Section1CommandsTab.Text     = "Host Queries"

$Section1CommandsTab.Location  = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$Section1CommandsTab.Size      = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 
$Section1CommandsTab.UseVisualStyleBackColor = $True
$Section1CollectionsTabControl.Controls.Add($Section1CommandsTab)


#============================================================================================================================================================
#============================================================================================================================================================
#
# End of Commands
#
#============================================================================================================================================================
#============================================================================================================================================================

$script:AllEndpointCommands = @()


    $CollectionName = 'Accounts (Local)'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "User, Hunt" 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value "Invoke-Command -ScriptBlock { Get-LocalUser }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value "Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_UserAccount -Filter `"LocalAccount='True'`" }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value "Invoke-Command -ScriptBlock { cmd /c net user }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value "Get-WmiObject -Class Win32_UserAccount -Filter `"LocalAccount='True'`""
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value "winrs wmic useraccount where localaccount=true list brief"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value "winrs net user"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value 'PSComputerName, Name, Enabled, SID, LastLogon, AccountExpires, PasswordRequired, UserMayChangePassword, PasswordExpires, PasswordLastSet, PasswordChangeableDate, Description, FullName' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value 'PSComputerName, Name, Disabled, AccountType, Lockout, PasswordChangeable, PasswordRequired, SID, SIDType, LocalAccount, Domain, Caption, Description' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value 'Gets default built-in user accounts, local user accounts that were created, and local accounts that were connected to Microsoft accounts.'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName   = 'Anti-Virus Product'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "System" 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value 'Invoke-Command -ScriptBlock { Get-WmiObject -Namespace root\SecurityCenter2 -Class AntivirusProduct }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Get-WmiObject -Namespace root\SecurityCenter2 -Class AntivirusProduct'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value 'PSComputerName, DisplayName, pathToSignedReportingExe' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value 'PSComputerName, DisplayName, pathToSignedReportingExe'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName   = 'ARP Cache'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Network" 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value "Invoke-Command -ScriptBlock { Get-NetNeighbor }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value 'Invoke-Command -ScriptBlock { cmd /c arp -a }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "cmd /c arp -a > c:\results.txt"'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value "winrs arp -a"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value 'PSComputerName, State, IPAddress, LinkLayerAddress, InterfaceAlias, InterfaceIndex' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value "PSComputerName, State, IPAddress, LinkLayerAddress, PolicyStore" 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value 'Gets IP addresses and link-layer addresses from ARP/neighbor cache entries.'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand
    

    $CollectionName = 'BIOS Info'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Hardware" 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value 'Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_BIOS }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Get-WmiObject -Class Win32_BIOS'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value "winrs wmic bios list brief"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '*' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value 'PSComputerName, SMBIOSBIOSVersion, Name, Manufacturer, SerialNumber, Version, Description, ReleaseDate, InstallDate' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Gets the basic input/output services (BIOS) that are installed."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand
    

    $CollectionName = 'Date Info'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "System" 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value "Invoke-Command -ScriptBlock { Get-Date }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value 'Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_OperatingSystem }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Get-WmiObject -Class Win32_OperatingSystem'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value "winrs date -t"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value 'PSComputerName, DateTime' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value 'PSComputerName, InstallDate, LastBootUpTime, LocalDateTime' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Gets various DateTimes."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'Disk (Logical Info)'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "System" 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value "Invoke-Command -ScriptBlock { Get-PSDrive }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value "Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_LogicalDisk }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Get-WmiObject -Class Win32_LogicalDisk'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value "winrs wmic LogicalDisk list brief"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value 'PSComputerName, Free, Used, Description, Provider, Root' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value 'PSComputerName, FreeSpace, Size, Description, ProviderName, DeviceID, DriveType, VolumeName' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Gets logical disk/drive information."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'Disk (Physical Info)'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Hardware" 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value 'Invoke-Command -ScriptBlock { Get-Disk }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value 'Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_DiskDrive }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Get-WmiObject -Class Win32_DiskDrive'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value 'PSComputerName, Number, FriendlyName, Model, Manufacturer, SerialNumber, OperationalStatus, TotalSize, BootFromDisk, IsSystem, IsOfline, IsReadOnly, PartitionStyle, NumberOfPartitions, LargestFreeExtent, Location, UniqueId' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value 'PSComputerName, Status, Name, Caption, Description, Model, Manufacturer, SerialNumber, Signature, InterfaceType, MediaType, FirmwareRevision, SectorsPerTrack, Size, TotalCylinders, TotalHeads, TotalSectors, TotalTracks, TracksPerCylinder' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Gets one or more disks visible to the operating system."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'DNS Cache'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Network" 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value 'Invoke-Command -ScriptBlock { Get-DnsClientCache }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value 'Invoke-Command -ScriptBlock { cmd /c ipconfig /displaydns }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "cmd /c ipconfig /displaydns > c:\results.txt"'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value 'PSComputerName, Entry, RecordName, RecordType, Status, Section, TimeToLive, Data' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Retrieves the contents of the DNS client cache."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand

    
    $CollectionName = 'Drivers (Detailed)'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "System" 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value "Invoke-Command -ScriptBlock { Get-WindowsDriver -Online -All }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value "Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_Systemdriver }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value 'Invoke-Command -ScriptBlock { cmd /c driverquery /si /FO CSV }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Get-WmiObject -Class Win32_Systemdriver'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value 'PSComputerName, Online, ClassName, Driver, OriginalFileName, ClassDescription, BootCritical, DriverSigned, ProviderName, Date, Version, InBox, LogPath, LogLevel' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value 'PSComputerName, State, Status, Started, StartMode, Name, DisplayName, PathName, ExitCode, AcceptPause, AcceptStop, Caption, CreationClassName, Description, DesktopInteract, ErrorControl, InstallDate, ServiceType' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Displays driver information in a Windows image."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'Environmental Variables'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "System" 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value "Invoke-Command -ScriptBlock { Get-ChildItem Env: }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value "Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_Environment }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value "Invoke-Command -ScriptBlock { cmd /c set }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Get-WmiObject -Class Win32_Environment'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value "winrs wmic environment list"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value "winrs set"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value 'PSComputerName, PSDrive, Name, Value' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value 'PSComputerName, UserName, Name, VariableValue' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Gets the environmental variables."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand

    $CollectionName = 'EventLog Statistics (Basic)'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "System"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value "Get-EventLog -List"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value "Invoke-Command -ScriptBlock { Get-EventLog -List }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value "winrs wmic nteventlog list brief"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '@{name="PSComputerName";expression={$TargetComputer}}, MaximumKilobytes, MinimumRetentionDays, OverflowAction, @{name="Entries"; expression={($_.Entries).count}}, Log, EnableRaisingEvents' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Get Event Log statistics"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'EventLog Statistics (Detailed)'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "System"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value "Get-WinEvent -ListLog *"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value "Invoke-Command -ScriptBlock { Get-WinEvent -ListLog * }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '@{name="PSComputerName";expression={$TargetComputer}}, IsEnabled, LogMode, MaximumSizeInBytes, RecordCount, LogName, LogType, LogIsolation, FileSize, IsLogFull, LastWriteTime, OldestRecordNumber'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Get a more granular breakdown of Event Log statistics"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand

    $CollectionName = 'Failed Logins (30 days)'
    $CommandScript = {
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
    }
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "User" 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value "Invoke-Command -ScriptBlock { $CommandScript }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Get failed loggons from the last 30 days."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'Firewall Port Proxy'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value 'Invoke-Command -ScriptBlock { cmd /c netsh interface portproxy show all }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "cmd /c netsh interface portproxy show all > c:\results.txt"'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '*' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Gets the ports that are forwarded/redirected elsewhere."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'Firewall Rules'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Network, System" 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value "Invoke-Command -ScriptBlock { Get-NetFirewallRule }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value 'Invoke-Command -ScriptBlock { cmd /c netsh advfirewall firewall show rule name=all }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "cmd /c netsh advfirewall firewall show rule name=all > c:\results.txt"'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '@{name="PSComputerName";expression={$TargetComputer}}, Enabled, Name, DisplayName, Description, DisplayGroup, Group, Profile, Direction, Action, EdgeTraversalPolicy, LooseSourceMapping, LocalOnlyMapping, Owner, EnforcementStatus, Status, PrimaryStatus, PolicyStoreSource, PolicyStoreSourceType' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Get the firewall rules."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'Firewall Status'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Network, System" 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value "Invoke-Command -ScriptBlock { Get-NetFirewallProfile }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value "Invoke-Command -ScriptBlock { cmd /c netsh advfirewall show allprofiles state }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "cmd /c netsh advfirewall show allprofiles state > c:\results.txt"'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '@{name="PSComputerName";expression={$TargetComputer}}, Name, Enabled, DefaultInboundAction, DefaultOutboundAction, AllowInboundRules, AllowLocalFirewallRules, AllowLocalIPsecRules, AllowUserApps, AllowUserPorts, AllowUnicastResponseToMulticast, NotifyOnListen, EnableStealthModeForIPsec, LogFileName, LogMaxsizeKilobytes, LogAllowed, LogBlocked, LogIgnored, DisabledInterfaceAliases' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Displays settings that apply to the per-profile configurations of the Windows Firewall with Advanced Security"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'Groups (Local)'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "User" 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value "Invoke-Command -ScriptBlock { Get-LocalGroup }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value "Invoke-Command -ScriptBlock { cmd /c wmic group list }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value "Invoke-Command -ScriptBlock { cmd /c net localgroup }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Get-WmiObject -Class Win32_Group -Filter { LocalAccount="True" }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value "winrs wmic group list" # ...wmic sysaccount... meh
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value "winrs net localgroup"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '*' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value 'PSComputerName, Name, LocalAccount, Domain, SID, SIDType, Caption, Description' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'Host Files'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "File"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value "Invoke-Command -ScriptBlock { cmd /c type C:\Windows\System32\drivers\etc\hosts }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "cmd /c type C:\Windows\System32\drivers\etc\hosts > c:\results.txt"'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value "winrs dir C:\Windows\System32\drivers\etc\hosts"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_winrs        -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '*' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value 'PSComputerName, Directory, Name, Length, CreationTime, LastWriteTime, LastAccessTime, Attributes, Mode' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Gets the contents of the Host file, which is a file that maps hostnames to IP addresses."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'Logon Info'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "User"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value "Invoke-Command -ScriptBlock { cmd /c wmic netlogin list brief }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Get-WmiObject -Class Win32_NetworkLoginProfile'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value "winrs wmic netlogin list brief"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '*' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value 'PSComputerName, Name, LastLogon, LastLogoff, NumberOfLogons, PasswordAge' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Gets information about user logon activity."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'Logon Sessions'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "User, System"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value 'Invoke-Command -ScriptBlock { cmd /c query session }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "cmd /c query session > c:\results.txt"'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value "winrs query session"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '*' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Gets session information of the computer."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'Logon User Status'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "User"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value 'Invoke-Command -ScriptBlock { cmd /c query user }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "cmd /c query user > c:\results.txt"'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '*' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Gets information about when a user logged on."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'Mapped Drives'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "System"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value 'Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_MappedLogicalDisk }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Get-WmiObject -Class Win32_MappedLogicalDisk'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '*' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value 'PSComputerName, Name, ProviderName, FileSystem, Size, FreeSpace, Compressed' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Gets information about mapped drives."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'Memory (Capacity Info)'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Hardware"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value "Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_PhysicalMemoryArray }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Get-WmiObject -Class Win32_PhysicalMemoryArray'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '*' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value "PSComputerName, Model, Name, MaxCapacity, @{Name='MaxCapacityGigabyte';Expression={$_.MaxCapacity / 1Mb}}, MemoryDevices"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Gets capacity information of the system memory."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'Memory (Performance Data)'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Hardware, System"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value "Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_PerfRawData_PerfOS_Memory }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Get-WmiObject -Class Win32_PerfRawData_PerfOS_Memory'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '*' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value 'PSComputerName, AvaiLabelBytes, AvaiLabelKBytes, AvaiLabelMBytes, CacheBytes, CacheBytesPeak, CacheFaultsPersec, Caption, CommitLimit, CommittedBytes, DemandZeroFaultsPersec, FreeAndZeroPageListBytes, FreeSystemPageTableEntries, Frequency_Object, Frequency_PerfTime, Frequency_Sys100NS, LongTermAverageStandbyCacheLifetimes, ModifiedPageListBytes, PageFaultsPersec, PageReadsPersec, PagesInputPersec, PagesOutputPersec, PagesPersec, PageWritesPersec, PercentCommittedBytesInUse, PercentCommittedBytesInUse_Base, PoolNonpagedAllocs, PoolNonpagedBytes, PoolPagedAllocs, PoolPagedBytes, PoolPagedResidentBytes, StandbyCacheCoreBytes, StandbyCacheNormalPriorityBytes, StandbyCacheReserveBytes, SystemCacheResidentBytes, SystemCodeResidentBytes, SystemCodeTotalBytes, SystemDriverResidentBytes, SystemDriverTotalBytes, Timestamp_Object, Timestamp_PerfTime, Timestamp_Sys100NS, TransitionFaultsPersec, TransitionPagesRePurposedPersec, WriteCopiesPersec' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Gets performance data information of the system memory."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'Memory (Physical Info)'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Hardware"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value "Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_PhysicalMemory }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Get-WmiObject -Class Win32_PhysicalMemory'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '*' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value 'PSComputerName, Tag, Capacity, Speed, Manufacturer, PartNumber, SerialNumber' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Gets physical information of the system memory."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'Memory (Utilization)'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "System"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value "Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_OperatingSystem }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Get-WmiObject -Class Win32_OperatingSystem'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '*' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value 'PSComputerName, 
            FreePhysicalMemory,
            TotalVisibleMemorySize, 
            FreeVirtualMemory, 
            TotalVirtualMemorySize,
            @{Name="FreePhysicalMemoryMegabyte";Expression={$_.FreePhysicalMemory / 1KB}},
            @{Name="TotalVisibleMemorySizeMegabyte";Expression={$_.TotalVisibleMemorySize / 1KB}},
            @{Name="FreeVirtualMemoryeMegabyte";Expression={$_.FreeVirtualMemory / 1KB}},
            @{Name="TotalVirtualMemorySizeMegabyte";Expression={$_.TotalVirtualMemorySize / 1KB}}'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Gets utilization information of the system memory."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'Motherboard Info'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Hardware"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value "Invoke-Command -ScriptBlock { cmd /c wmic baseboard list brief }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Get-WmiObject -Class Win32_BaseBoard'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value "winrs wmic baseboard list brief"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '*' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value 'PSComputerName, Manufacturer, Model, Name, SerialNumber, SKU, Product' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand

    <#
    # There is an integrated tool in Windows Servers 2008R2 and newer, that allows capturing the network activity without installing anything.
    cmd /c netsh trace start capture=yes Ethernet.Type=IPv4 IPv4.Address=127.0.0.1 filemode=single maxSize=250 overwrite=yes tracefile=c:\temp\nettrace_test.etl
    #default save location: “traceFile=%LOCALAPPDATA%\Temp\NetTraces\NetTrace.etl”
    # e.g. Protocol=6
    # e.g. Protocol=!(TCP,UDP)
    # e.g. Protocol=(4-10)    
    Start-Sleep -Seconds 30
    cmd /c netsh trace stop
    #>

    $CollectionName = 'Network Connections TCP'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Network"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value 'Invoke-Command -ScriptBlock { Get-NetTCPConnection }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value 'Invoke-Command -ScriptBlock { cmd /c netstat -anob -p tcp }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "cmd /c netstat -anob -p tcp > c:\results.txt"'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '@{name="PSComputerName";expression={$TargetComputer}}, State, LocalAddress, LocalPort, RemoteAddress, RemotePort, OwningProcess, CreationTime, OffloadState, AppliedSetting' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Gets TCP Network Connections"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand
    

    $CollectionName = 'Network Connections UDP'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Network" 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value 'Invoke-Command -ScriptBlock { Get-NetUDPEndpoint }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value 'Invoke-Command -ScriptBlock { cmd /c netstat -anob -p udp }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "cmd /c netstat -anob -p udp > c:\results.txt"'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '@{name="PSComputerName";expression={$TargetComputer}}, LocalAddress, LocalPort' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Gets UDP Network Connections"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'Network Settings'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Network" 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value "Invoke-Command -ScriptBlock { Get-NetIPAddress }" 
    #get-netadapter...make script to combine
    #Get-NetIPConfiguration
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value "Invoke-Command -ScriptBlock { cmd /c wmic nicconfig list brief }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value "Invoke-Command -ScriptBlock { cmd /c ipconfig /all }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Get-WmiObject -Class Win32_NetworkAdapterConfiguration' 
    ##############...win32_NetworkAdapter... MAC Address
    ##############...wmic nic list brief... MAC Address
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value "winrs wmic nicconfig list brief"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value "winrs ipconfig /all"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '@{name="PSComputerName";expression={$TargetComputer}}, IPAddress, InterfaceIndex, InterfaceAlias, AddressFamily, Type, PrefixLength, PrefixOrigin, SuffixOrigin, AddressState, ValidLifetime, PreferredLifetime, SkipAsSource, PolicyStore' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value 'PSComputerName, MACAddress, `
                    @{Name="IPAddress";Expression={$_.IPAddress -join "; "}}, `
                    @{Name="IpSubnet";Expression={$_.IpSubnet -join "; "}}, `
                    @{Name="DefaultIPGateway";Expression={$_.DefaultIPgateway -join "; "}}, `
                    Description, ServiceName, IPEnabled, DHCPEnabled, DNSHostname, `
                    @{Name="DNSDomainSuffixSearchOrder";Expression={$_.DNSDomainSuffixSearchOrder -join "; "}}, `
                    DNSEnabledForWINSResolution, DomainDNSRegistrationEnabled, FullDNSRegistrationEnabled, `
                    @{Name="DNSServerSearchOrder";Expression={$_.DNSServerSearchOrder -join "; "}}, `
                    @{Name="WinsPrimaryServer";Expression={$_.WinsPrimaryServer -join "; "}}, `
                    @{Name="WINSSecondaryServer";Expression={$_.WINSSecondaryServer -join "; "}}' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Gets network settings."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'Network Statistics IPv4 All'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Network" 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value 'Invoke-Command -ScriptBlock { cmd /c netstat -e -p ip }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "cmd /c netstat -e -p ip > c:\results.txt"'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '*' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Gets all host protocol statistics for an IPv4 network."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'Network Statistics IPv4 ICMP'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Network"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value 'Invoke-Command -ScriptBlock { cmd /c netstat -e -p icmp }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "cmd /c netstat -e -p icmp > c:\results.txt"'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '*' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Gets host ICMP statistics for an IPv4 network."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'Network Statistics IPv4 TCP'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Network"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value 'Invoke-Command -ScriptBlock { cmd /c netstat -e -p tcp }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "cmd /c netstat -e -p tcp > c:\results.txt"'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '*' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Gets host TCP statistics for an IPv4 network."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'Network Statistics IPv4 UDP'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Network"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value 'Invoke-Command -ScriptBlock { cmd /c netstat -e -p udp }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "cmd /c netstat -e -p udp > c:\results.txt"'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '*' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Gets host UDP statistics for an IPv4 network."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'Network Statistics IPv6 All'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Network"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value 'Invoke-Command -ScriptBlock { cmd /c netstat -e -p ipv6 }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "cmd /c netstat -e -p ipv6 > c:\results.txt"'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '*' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Gets all host protocol statistics for an IPv6 network."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'Network Statistics IPv6 TCP'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Network"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value 'Invoke-Command -ScriptBlock { cmd /c netstat -e -p tcpv6 }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "cmd /c netstat -e -p tcpv6 > c:\results.txt"'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '*' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Gets host TCP statistics for an IPv6 network."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'Network Statistics IPv6 UDP'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Network"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value 'Invoke-Command -ScriptBlock { cmd /c netstat -e -p udpv6 }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "cmd /c netstat -e -p udpv6 > c:\results.txt"'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '*' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Gets host UDP statistics for an IPv6 network."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'Network Statistics IPv6 ICMP'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Network"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value 'Invoke-Command -ScriptBlock { cmd /c netstat -e -p icmpv6 }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "cmd /c netstat -e -p icmpv6 > c:\results.txt"'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '*' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Gets host ICMP statistics for an IPv6 network."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'Pipes (Named Pipes)'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "System, Network, Hunt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value 'Invoke-Command -ScriptBlock { Get-ChildItem "\\.\\pipe\\" -Force }'
    #$BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value 'Invoke-Command -ScriptBlock { [System.IO.Directory]::GetFiles("\\.\\pipe\\") }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '@{name="PSComputerName";expression={$TargetComputer}}, Name, Directory, IsReadOnly, CreationTime, LastAccessTime, LastWriteTime, Mode, Attributes' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "A pipe is a section of shared memory that processes use for communication. The process that creates a pipe is the pipe server. A process that connects to a pipe is a pipe client. One process writes information to the pipe, then the other process reads the information from the pipe. A named pipe is a named, one-way or duplex pipe for communication between the pipe server and one or more pipe clients. All instances of a named pipe share the same pipe name, but each instance has its own buffers and handles, and provides a separate conduit for client/server communication. The use of instances enables multiple pipe clients to use the same named pipe simultaneously. Any process can access named pipes, subject to security checks, making named pipes an easy form of communication between related or unrelated processes. Any process can act as both a server and a client, making peer-to-peer communication possible."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'Plug and Play Devices'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Hardware"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value "Invoke-Command -ScriptBlock { Get-PnpDevice }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value "Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_PnPEntity }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Get-WmiObject -Class Win32_PnPEntity'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '*' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value 'PSComputerName, InstallDate, Status, Description, Service, DeviceID, @{Name="HardwareID";Expression={$_.HardwareID -join "; "}}, Manufacturer' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Gets information on Plug and Play (PnP) Devices"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'PowerShell Profiles'
    $CommandScript = {
        $ProfileCheck = $PROFILE | Get-Member -MemberType NoteProperty | select Name, @{name='path';expression={(($_.definition) -split '=')[1]}} 
        foreach ($item in $ProfileCheck.path) {$ProfileCheck | Add-Member -MemberType NoteProperty -Name DoesItExist -Value $(Test-Path $item) -Force -ErrorAction SilentlyContinue}
        $ProfileCheck
    }
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "File, Hunt" 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value "Invoke-Command -ScriptBlock { $CommandScript }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '*' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "A PowerShell profile is a script that runs when PowerShell starts. You can use the profile as a logon script to customize the environment. You can add commands, aliases, functions, variables, snap-ins, modules, and PowerShell drives. ... PowerShell supports several profiles for users and host programs."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'Prefetch Files'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "File"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value 'Invoke-Command -ScriptBlock { Get-ChildItem C:\Windows\Prefetch -Force }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value 'Invoke-Command -ScriptBlock { cmd /c dir /a C:\Windows\Prefetch }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "cmd /c dir /a C:\Windows\Prefetch > c:\results.txt"'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value "winrs dir C:\Windows\Prefetch"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_winrs        -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '@{name="PSComputerName";expression={$TargetComputer}}, Name, Directory, IsReadOnly, CreationTime, LastAccessTime, LastWriteTime, Mode, Attributes' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value 'PSComputerName, Directory, Name, Length, CreationTime, LastWriteTime, LastAccessTime, Attributes, Mode' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Gets the Prefetch Files. Prefetch files are great artifacts for forensic investigators trying to analyze applications that have been run on a system. Windows creates a prefetch file when an application is run from a particular location for the very first time. This is used to help speed up the loading of applications"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand
    
    <#
    $CollectionName = 'Process Tree (Lineage)'
    $CommandScript = {
        $script:Results = @()
        $script:Results += $("==================================================")
        $script:Results += $("{0,-8}{1}" -f "PID","Process Name")
        $script:Results += $("==================================================")
        Function Get-ProcessChildren ($P,$Depth=1) {
            $procs | Where-Object {
                $_.ParentProcessId -eq $p.ProcessID -and $_.ParentProcessId -ne 0
            } | ForEach-Object {
                $script:Results += $("{0,-8}{1}|--- {2}" -f $_.ProcessID,(" "*5*$Depth),$_.Name,$_.ParentProcessId)
                Get-ProcessChildren $_ (++$Depth) 
                $Depth-- 
            }
        } 
        $filter = { -not (Get-Process -Id $_.ParentProcessId -ErrorAction SilentlyContinue) -or $_.ParentProcessId -eq 0 } 
            $procs = Get-WmiObject -Class Win32_Process
            $top = $procs | Where-Object $filter | Sort-Object ProcessID 
        foreach ($p in $top) {
            $script:Results += $("{0,-8}{1}" -f $p.ProcessID, $p.Name)                
            Get-ProcessChildren $p
        }
        $script:Results
    }
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value 'System' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value "Invoke-Command -ScriptBlock { $CommandScript }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '*' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value 'Gets the lineage of each process in a simple to view tree.'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value '$CommandsHostDirectoryNotes\$CollectionName.txt'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$IndividualHostResults\$CollectionName\$CollectionName"
    $script:AllEndpointCommands += $BuildCommand
    #>

    $CollectionName = 'Processes (Enhanced)'
    $Commandscript = {
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
            $Process | Add-Member -NotePropertyName ParentProcessName -NotePropertyValue $((Get-Process -Id ($Process.ParentProcessId) -ErrorAction SilentlyContinue).name)
            $Process | Add-Member -NotePropertyName FileHash -NotePropertyValue "MD5: $((Get-FileHash -Path ($Process.Path) -Algorithm MD5 -ErrorAction SilentlyContinue).Hash)"
            $Process | Add-Member -NotePropertyName DateCreated -NotePropertyValue "$([Management.ManagementDateTimeConverter]::ToDateTime($Process.CreationDate))"

            $Process | Add-Member -NotePropertyName Handle -NotePropertyValue "$($ProcessesPsId.Handle)"
            $Process | Add-Member -NotePropertyName HandleCount -NotePropertyValue "$($ProcessesPsId.HandleCount)"
            $Process | Add-Member -NotePropertyName Product -NotePropertyValue "$($ProcessesPsId.Product)"
            $Process | Add-Member -NotePropertyName PSDescription -NotePropertyValue "$($ProcessesPsId.Description)"
            $Process | Add-Member -NotePropertyName Threads -NotePropertyValue "$($ProcessesPsId.Threads.Id)"
            $Process | Add-Member -NotePropertyName Modules -NotePropertyValue "$($ProcessesPsId.modules.modulename)"

            try {
                $AuthenticodeSignature = Get-AuthenticodeSignature $Process.Path
                $Process | Add-Member -NotePropertyName StatusMessage     -NotePropertyValue $( if ($AuthenticodeSignature.StatusMessage -match 'verified') {'Signature Verified'}; elseif ($AuthenticodeSignature.StatusMessage -match 'not digitally signed') {'The file is not digitially signed.'})
                $Process | Add-Member -NotePropertyName SignerCertificate -NotePropertyValue $AuthenticodeSignature.SignerCertificate.Thumbprint
                $Process | Add-Member -NotePropertyName Company -NotePropertyValue $($AuthenticodeSignature.SignerCertificate.Subject.split(',')[0] -replace 'CN=' -replace '"')
                #$Process | Add-Member -NotePropertyName RSAKey -NotePropertyValue $($AuthenticodeSignature.SignerCertificate.PublicKey.EncodedKeyValue.rawdata -join '')
            }
            catch {}

            $Owner    = $Process.GetOwner().Domain.ToString() + "\"+ $Process.GetOwner().User.ToString()
            $OwnerSID = $Process.GetOwnerSid().Sid.ToString()
            $Process | Add-Member -NotePropertyName Owner    -NotePropertyValue $Owner
            $Process | Add-Member -NotePropertyName OwnerSID -NotePropertyValue $OwnerSID
        }
        $ProcessesWMI | Select-Object -Property PSComputerName, Name, DateCreated, ProcessId, ParentProcessId, ParentProcessName, NetworkConnections, Path, FileHash, SignerCertificate, StatusMessage, Company, Product, PSDescription, RSAKey, Owner, OwnerSID, CommandLine, WorkingSetSize, Threads, ThreadCount, Handle, HandleCount, Modules
    }
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "System"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value "Invoke-Command -ScriptBlock { $CommandScript }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Gets running processes, their hashes, loaded dlls, and associated network connections."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'Processes (Standard)'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "System"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value "Get-Process"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value "Get-WmiObject -Class Win32_Process"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value "winrs wmic process list brief"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value "winrs tasklist /v"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value "Invoke-Command -ScriptBlock { Get-Process }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value "Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_Process }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value "Invoke-Command -ScriptBlock { cmd /c tasklist /v }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '@{name="PSComputerName";expression={$TargetComputer}}, Name, ID, Path, StartTime, @{name="WorkingSetSize";expression={$_.WS}} , Handle, HandleCount, @{Name="ThreadCount";expression={($_.Threads).count}}, Company, Product, Description'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value "PSComputerName, Name, ProcessID, ParentProcessID, Path, WorkingSetSize, Handle, HandleCount, ThreadCount, CreationDate, Description"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Gets a list of running processes."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'Processor (CPU Info)'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Hardware" 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value "Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_Processor }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Get-WmiObject -Class Win32_Processor'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value 'PSComputerName, Name, Manufacturer, Caption, DeviceID, SocketDesignation, MaxClockSpeed' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Gets information on the CPU Processor."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'Remote Capability Check'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Network" 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Checks the remote capabilities of the host."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'Restore Point Info'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "System"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value "Invoke-Command -ScriptBlock { Get-ComputerRestorePoint }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '*'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Gets a list of Restore Points."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand   


    $CollectionName = 'Scheduled Tasks'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "System"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value 'Invoke-Command -ScriptBlock { Get-ScheduledTask }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value 'Invoke-Command -ScriptBlock { cmd /c schtasks /query /V /FO CSV }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "cmd /c schtasks /query /V /FO CSV > c:\results.txt"'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value 'TaskName, State, Date, Actions, TaskPath, Description' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Gets scheduled tasks."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand

    
    $CollectionName = 'Screen Saver Info'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "System"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value "Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_Desktop }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Get-WmiObject -Class Win32_Desktop'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '*' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value 'PSComputerName, Name, ScreenSaverActive, ScreenSaverTimeout, ScreenSaverExecutable, Wallpaper' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Get screensaver information."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'Security Patches'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "System"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value "Get-HotFix"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value "Invoke-Command -ScriptBlock { Get-HotFix }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value "Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_QuickFixEngineering }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Get-WmiObject -Class Win32_QuickFixEngineering'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value "winrs wmic qfe list"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '*' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value '@{Name="Name";Expression={$_.HotFixID}}, HotFixID, Description, InstalledBy, InstalledOn' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Gets information on security patches and when they were installed."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'Services'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "System"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value "cmd /c sc query state=all"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value "query state=all"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value "Get-Service"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value "Invoke-Command -ScriptBlock { Get-Service }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value "Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_Service }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value "Invoke-Command -ScriptBlock { cmd /c sc query state=all }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Get-WmiObject -Class Win32_Service'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value "winrs wmic service list brief"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value "winrs sc query state=all"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '*' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value 'PSComputerName, State, Name, ProcessID, Description, PathName, Started, StartMode, StartName | Sort-Object PSComputerName, State, Name' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Gets information on services."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'Sessions'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Network, Hunt" 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value "cmd /c net session"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value "Invoke-Command -ScriptBlock { Get-SmbSession }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value "Invoke-Command -ScriptBlock { cmd /c net session }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "cmd /c net session > c:\results.txt"'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value "winrs net session"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '*' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value 'PSComputerName, Status, Name, Path, Description' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Gets network SMB sessions."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'Shares'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Network, Hunt" 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value "cmd /c net view /ALL"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value "Invoke-Command -ScriptBlock { Get-SmbShare }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value "Invoke-Command -ScriptBlock { cmd /c wmic share }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value "Invoke-Command -ScriptBlock { cmd /c net view /ALL }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Get-WmiObject -Class Win32_Share'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value "winrs wmic share"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value "winrs net share"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '*' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value 'PSComputerName, Status, Name, Path, Description' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Gets network shares. The 'net share' command is used to manage file/printer shares."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'Software Installed'
    $CommandScript = {
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
    }
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "System, Hunt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value "Invoke-Command -ScriptBlock { $CommandScript }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value "Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_Product }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Get-WmiObject -Class Win32_Product'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '*' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value 'PSComputerName, Name, Vendor, Version, InstallDate, InstallDate2, InstallLocation, InstallSource, PackageName, PackageCache, RegOwner, HelpLink, HelpTelephone, URLInfoAbout, URLUpdateInfo, Language, Description, IdentifyingNumber' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Gets installed software."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'Startup Commands'
    $CommandScript = {
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
    }
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "System, Hunt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value "Invoke-Command -ScriptBlock { $CommandScript }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value "Invoke-Command -ScriptBlock { Get-WmiObject -class Win32_StartupCommand }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Get-WmiObject -Class Win32_StartupCommand'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value "winrs wmic startup list brief"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '*' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value 'PSComputerName, Name, Location, Command, User' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Gets startup information."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'System Info'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "System, Network, Hardware"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value 'Invoke-Command -ScriptBlock { Get-ComputerInfo }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value 'Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_ComputerSystem }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value 'Invoke-Command -ScriptBlock { cmd /c systeminfo /fo csv }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Get-WmiObject -Class Win32_ComputerSystem'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value "winrs wmic os list brief"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '*' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value 'PSComputerName, Description, Manufacturer, Model, SystemType, NumberOfProcessors, TotalPhysicalMemory, EnableDaylightSavingsTime, BootupState, PartOfDomain, Domain, Username, PrimaryOwnerName' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "GUI = msinfo32 ; Get-ComputerInfo is only avilable on WPF 5.1 ; Gets consolidated operating system information and properties."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'UEFI - Secure Boot Policy'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Hardware" 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value "Invoke-Command -ScriptBlock { Get-SecureBootPolicy }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '*' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "If the hardware supports Secure Boot, gets the publisher GUID and the policy version of the Secure Boot configuration policy. If enabled it will return True, otherwise False. If the hardware doesn't support UEFI Secure boot or is BIOS based, an not supported error will be displayed."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'UEFI - Secure Boot Status'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Hardware" 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value "Invoke-Command -ScriptBlock { Confirm-SecureBootUEFI }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '*' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "If the hardware supports UEFI Secure Boot, checks if it's enabled. If enabled it will return True, otherwise False. If the hardware doesn't support UEFI Secure boot or is BIOS based, an not supported error will be displayed."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'USB Controller Devices'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Hardware, System"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value "Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_USBControllerDevice }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value 'Get-WmiObject -Class Win32_USBControllerDevice'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '*' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value 'PSComputerName, Name, Manufacturer, Status, Service, DeviceID, @{Name="HardwareID";Expression={$_.HardwareID}}' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Gets USB information."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'Valid Signatures (C:\Windows\System32)'
    $CommandScript ={
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
    }
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value 'File' 
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value "Invoke-Command -ScriptBlock { $CommandScript }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value "Invoke-Command -ScriptBlock { Get-ChildItem C:\windows\system32 -Recurse -File | Get-AuthenticodeSignature }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    ### ... C:\Program Files  C:\Program Files (x86)  C:\pagefile.sys  
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Gets information about the digital signature of files in the C:\Windows\System32 directory."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'VMWare Detection'
    $CommandScript = {
        $VMwareDetected = $False
        $VMAdapter = Get-WmiObject Win32_NetworkAdapter -Filter 'Manufacturer LIKE "%VMware%" OR Name LIKE "%VMware%"'
        $VMBios = Get-WmiObject Win32_BIOS -Filter 'SerialNumber LIKE "%VMware%"'
        $VMToolsRunning = Get-WmiObject Win32_Process -Filter 'Name="vmtoolsd.exe"'
        if($VMAdapter -or $VMBios -or $VMToolsRunning) { $VMwareDetected = $True }
        $VMwareDetected
    }
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "System"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value "Invoke-Command -ScriptBlock { $CommandScript }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '*'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Detects VMWare Product; either the host is a VMWare VM or is hosting VMs."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'Windows Side by Side (Count)'
    $CommandScript = {
        $Query = New-Object PSObject -Property @{ PSComputerName = $env:computername }
        $Query | Add-Member -MemberType NoteProperty -Name FileCount -Value $((ls C:\Windows\WinSxS).count)
        $Query
    }
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "File"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value "Invoke-Command -ScriptBlock { $CommandScript }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '*'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value "Windows Side By Side (WinSxS), is a folder that stores different copies of DLL and system files. It stores different files for compatibility reasons and for times older versions need to be restored. Files within contain different versions, are needed for installation, backups, or updates. It's a space hog, taking up several gigabytes of space and growing with each Windows Update you perform. ou can't just delete everything in the WinSxS folder, because some of those files are needed for Windows to run and update reliably. However, with Windows 7 and above you can use the built-in Disk Cleanup tool to delete older versions of Windows updates you no longer need."
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand

 	
    # Related: Get-MpThreatCatalog 	Gets known threats from the definitions catalog.
    # Related: Get-MpThreat         Gets the history of threats detected on the computer
    # start-MpScan -ScanType [QuickScan|FullScan]
    # Start-MpScan -ScanPath C:\Users\<username>\Downloads

    $CollectionName = 'Windows Defender (Malware Detected)'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "System"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value 'Invoke-Command -ScriptBlock { Get-MpThreatDetection }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '*'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value 'Gets active and past malware threats that Windows Defender detected.'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'Windows Defender (Preferences)'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "System, Network"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value 'Invoke-Command -ScriptBlock { Get-MpPreference }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '*'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value 'Gets preferences for the Windows Defender scans and updates.'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand

    	
    $CollectionName = 'Windows Defender (Status)'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "System, Network"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value 'Invoke-Command -ScriptBlock { Get-MpComputerStatus }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '*'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value 'Gets the status of anti-malware software on the computer.'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand


    $CollectionName = 'WSMan Trusted Hosts'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "System, Network"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value 'Invoke-Command -ScriptBlock { Get-Item WSMan:\localhost\Client\TrustedHosts }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '*'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value 'The WS-Management TrustedHosts list is a list of trusted resources for your computer. The TrustedHosts list consists of a comma-separated list of computer names, IP addresses, and fully-qualified domain names. Only members of the Administrators group on the computer have permission to change the list of trusted hosts on the computer. For information about runningWindows PowerShell with administrator permissions, see How to Run as Administrator. To use the IP address of a remote computer in a Windows PowerShell command to connect to the remote computer, the IP address must be in the TrustedHosts list on your computer. This is a requirement of NTLM authentication, which is used whenever a computer is identified by the IP address instead of a computer name.'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllEndpointCommands += $BuildCommand




#=============================
#=============================
#=============================
#=============================
#=============================
#=============================
    $script:AllActiveDirectoryCommands = @()


    $CollectionName = 'ADDS Account (All Details and User Information)'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "User"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value 'Invoke-Command -ScriptBlock { Get-ADUser -Filter * -Properties * }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value "Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_UserAccount -Filter `"LocalAccount='False'`""
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value "Get-WmiObject -Class Win32_UserAccount -Filter `"LocalAccount='False'`""
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value 'Name, CanonicalName, SID, Enabled, LockedOut, AccountLockoutTime, Created, LogonWorkStations, LastLogonDate, LastBadPasswordAttempt, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CannotChangePassword, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive, Title, Organization, Office, POBox, StreetAddress, City, State, PostalCode, Fax, OfficePhone, HomePhone, MobilePhone, EmailAddress'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value '_____________'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllActiveDirectoryCommands += $BuildCommand

 
    $CollectionName = 'ADDS Account (Logon and Passowrd Policy)'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "User"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value 'Invoke-Command -ScriptBlock { Get-ADUser -Filter * -Properties * }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value 'Name, Enabled, LockedOut, AccountLockoutTime, LogonWorkStations, LastLogonDate, LastBadPasswordAttempt, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CannotChangePassword'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value '_____'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllActiveDirectoryCommands += $BuildCommand


    $CollectionName = 'ADDS Account (Contact Information)'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "User"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value 'Invoke-Command -ScriptBlock { Get-ADUser -Filter * -Properties * }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value 'Name, Title, Organization, Office, POBox, StreetAddress, City, State, PostalCode, Fax, OfficePhone, HomePhone, MobilePhone, EmailAddress'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value '_____'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllActiveDirectoryCommands += $BuildCommand


    $CollectionName = 'ADDS Account ()'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "User"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value 'Invoke-Command -ScriptBlock { Search-ADAccount -AccountDisabled }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value 'Name, Enabled, LockedOut, LastLogonDate, AccountExpirationDate, PasswordExpired, PaswordNeverExpires, SID, SamAccountName, UserPrincipalName, DistinguishedName, ObjectClass, ObjectGUID'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value '_____'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllActiveDirectoryCommands += $BuildCommand


    $CollectionName = 'ADDS Account (Expired)'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "User"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value 'Invoke-Command -ScriptBlock { Search-ADAccount -AccountExpired }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value 'Name, Enabled, LockedOut, LastLogonDate, AccountExpirationDate, PasswordExpired, PaswordNeverExpires, SID, SamAccountName, UserPrincipalName, DistinguishedName, ObjectClass, ObjectGUID'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value '_____'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllActiveDirectoryCommands += $BuildCommand


    $CollectionName = 'ADDS Account (Inactive)'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "User"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value 'Invoke-Command -ScriptBlock { Search-ADAccount -AccountInactive }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value 'Name, Enabled, LockedOut, LastLogonDate, AccountExpirationDate, PasswordExpired, PaswordNeverExpires, SID, SamAccountName, UserPrincipalName, DistinguishedName, ObjectClass, ObjectGUID'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value '_____'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllActiveDirectoryCommands += $BuildCommand


    $CollectionName = 'ADDS Account (Password Never Expires)'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "User"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value 'Invoke-Command -ScriptBlock { Search-ADAccount -PasswordNeverExpires }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value 'Name, Enabled, LockedOut, LastLogonDate, AccountExpirationDate, PasswordExpired, PaswordNeverExpires, SID, SamAccountName, UserPrincipalName, DistinguishedName, ObjectClass, ObjectGUID'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value '_____'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllActiveDirectoryCommands += $BuildCommand


    $CollectionName = 'ADDS Domain Trusts'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Domain"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value 'Invoke-Command -ScriptBlock { cmd c\ netdom query TRUST }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value '_____'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllActiveDirectoryCommands += $BuildCommand
    

    $CollectionName = 'ADDS Domain FSMO Roles'
    $CommandScript = {
            $FSMO = New-Object PSObject -Property @{Name = 'FSMORoles'}
            $FSMO | Add-Member -MemberType NoteProperty -Name InfrastructureMaster -Value $(Get-ADDomain | Select-Object InfrastructureMaster)
            $FSMO | Add-Member -MemberType NoteProperty -Name PDCEmulator -Value $(Get-ADDomain | Select-Object PDCEmulator)
            $FSMO | Add-Member -MemberType NoteProperty -Name RIDMaster -Value $(Get-ADDomain | Select-Object RIDMaster)
            $FSMO | Add-Member -memberType NoteProperty -Name SchemaMaster -Value $(Get-ADForest | Select-Object SchemaMaster)
            $FSMO | Add-Member -memberType NoteProperty -Name DomainNamingMaster -Value $(Get-ADForest | Select-Object DomainNamingMaster)
            $FSMO
    }
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Domain"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value "Invoke-Command -ScriptBlock { $CommandScript }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value 'Invoke-Command -ScriptBlock { cmd c\ netdom query FSMO }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value 'InfrastructureMaster, PDCEmulator, RIDMaster'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value '_____'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllActiveDirectoryCommands += $BuildCommand
    
    
    $CollectionName = 'ADDS Domain FSMO (Schema Master in Forest)'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Domain"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value 'Invoke-Command -ScriptBlock { Get-ADForest }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value 'Invoke-Command -ScriptBlock { cmd c\ dsquery server -forest -hasfsmo Schema }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value 'SchemaMaster'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value '_____'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllActiveDirectoryCommands += $BuildCommand


    $CollectionName = 'ADDS Domain FSMO (Domain Naming Master)'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Domain"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value 'Invoke-Command -ScriptBlock { Get-ADForest }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value 'Invoke-Command -ScriptBlock { cmd c\ dsquery server -forest -hasfsmo Name }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value 'DomainNamingMaster'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value '_____'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllActiveDirectoryCommands += $BuildCommand


    $CollectionName = 'ADDS Domain FSMO (Primary Domain Controller)'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Domain"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value 'Invoke-Command -ScriptBlock { Get-ADDomain }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value 'Invoke-Command -ScriptBlock { cmd c\ dsquery server -hasfsmo PDC }'
    #$BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value 'Invoke-Command -ScriptBlock { cmd c\ netdom query PDC }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value 'PDCEmulator'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value '_____'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllActiveDirectoryCommands += $BuildCommand


    $CollectionName = 'ADDS Domain FSMO (RID Master)'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Domain"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value 'Invoke-Command -ScriptBlock { Get-ADDomain }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value 'Invoke-Command -ScriptBlock { cmd c\ dsquery server -hasfsmo RID }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value 'RIDMaster'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value '_____'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllActiveDirectoryCommands += $BuildCommand


    $CollectionName = 'ADDS Domain FSMO (Infrastructure Master)'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Domain"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value 'Invoke-Command -ScriptBlock { Get-ADDomain }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value 'Invoke-Command -ScriptBlock { cmd c\ dsquery server -hasfsmo INFR }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value 'InfrastructureMaster'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value '_____'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllActiveDirectoryCommands += $BuildCommand


    $CollectionName = 'ADDS Domain Organizationation Units (OUs)'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Domain"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value 'Invoke-Command -ScriptBlock { cmd c\ netdom query OU }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value '_____'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllActiveDirectoryCommands += $BuildCommand
    

    $CollectionName = 'ADDS Domain Sites'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Domain"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value 'Invoke-Command -ScriptBlock { cmd c\ dsquery site -name * -limit 0 }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value '_____'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllActiveDirectoryCommands += $BuildCommand


    $CollectionName = 'ADDS Domain (Primary Group is Domain Computers)'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Domain"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value 'Invoke-Command -ScriptBlock { cmd c\ dsquery * -filter "(primaryGroupID=515)" -limit 0 }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value '_____'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllActiveDirectoryCommands += $BuildCommand


    $CollectionName = 'ADDS Domain (Primary Group is Domain Controllers)'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Domain"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value 'Invoke-Command -ScriptBlock { cmd c\ dsquery * -filter "(primaryGroupID=516)" -limit 0 }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value '_____'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllActiveDirectoryCommands += $BuildCommand


    $CollectionName = 'ADDS Domain (Domain Controllers that are Global Catalogs)'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Domain"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value 'Invoke-Command -ScriptBlock { cmd c\ dsquery server | dsget server -dnsname -site -isgc }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value '_____'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllActiveDirectoryCommands += $BuildCommand


    $CollectionName = 'ADDS Domain (Read Only Domain Controllers [RODC])'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Domain"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value 'Invoke-Command -ScriptBlock { cmd c\ dsquery server -isreadonly }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value '_____'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllActiveDirectoryCommands += $BuildCommand


    $CollectionName = 'ADDS Domain (Get All Object Classes)'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Domain"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value 'Invoke-Command -ScriptBlock { Get-AdObject -Filter * }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '*'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value '_____'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllActiveDirectoryCommands += $BuildCommand
       

    $CollectionName = 'ADDS Domain Controllers'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Domain"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value 'Invoke-Command -ScriptBlock { cmd c\ netdom query DC }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value '_____'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllActiveDirectoryCommands += $BuildCommand
<#
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

######>

    
    <#
    $CollectionName = 'ADDS Account Email Addresses'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "User"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value 'Invoke-Command -ScriptBlock { Get-ADUser -Filter * -Properties * | Where-Object {$_.EmailAddress -ne $null} }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value 'Name, EmailAddress'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value '_____'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllActiveDirectoryCommands += $BuildCommand
    #>
    <#
    $CollectionName = 'ADDS Account Phone Numbers'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "User"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value 'Invoke-Command -ScriptBlock { Get-ADUser -Filter * -Properties * | Where-Object {($_.OfficePhone -ne $null) -or ($_.HomePhone -ne $null) -or ($_.MobilePhone -ne $null)} }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value 'Name, OfficePhone, HomePhone, MobilePhone'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value '_____'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllActiveDirectoryCommands += $BuildCommand
    #>

    $CollectionName = 'ADDS Computers (Details and OS Info)'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "User"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value 'Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties * }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value 'Enabled, Name, OperatingSystem, OperatingSystemServicePack, OperatingSystemHotfix, OperatingSystemVersion, IPv4Address, IPv6Address, LogonCount, LastLogonDate, WhenCreated, WhenChanged, Location, ObjectClass, SID, SIDHistory, DistinguishedName, DNSHostName, SamAccountName, CannotChangePassword, '
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value '_____'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllActiveDirectoryCommands += $BuildCommand

                    
    $CollectionName = 'ADDS Default Domain Password Policy'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "User"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value 'Invoke-Command -ScriptBlock { Get-ADDefaultDomainPasswordPolicy }'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value '*'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value '_____'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllActiveDirectoryCommands += $BuildCommand


    $CollectionName = 'ADDS Groups'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "User"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value 'Invoke-Command -ScriptBlock { Get-ADGroup -Filter * -Properties *}'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value "Invoke-Command -ScriptBlock { Get-WmiObject -Class Win32_Group -Filter `"LocalAccount='False'`" }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value "_____"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value 'Name, SID, SIDHistory, GroupCategory, GroupScope, @{n="Member"; e={($_.Members -replace "CN=","`nCN=") }}, Members, MemberOf, WhenCreated, WhenChanged, DistinguishedName, Description, ProtectedFromAccidentalDeletion'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value 'Name, Domain, SID, SIDType, Caption, Description'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value '_____'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllActiveDirectoryCommands += $BuildCommand


    $CollectionName = 'ADDS Group Membership by Groups'
    $CommandScript = {
        $ADGroupList = Get-ADGroup -Filter * | Select-Object -ExpandProperty Name
        foreach ($Group in $ADGroupList) {
            $GroupMemberships = Get-ADGroupMember $Group
            $GroupMemberships | Add-Member -MemberType NoteProperty -Name GroupName -Value $Group -Force
            $GroupMemberships | select * -First 1
            $GroupMemberships | Select-Object -Property PSComputerName, GroupName, SamAccountName, SID, GroupCategory, GroupScope, DistinguishedName 
        } 
    }
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "User"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value "Invoke-Command -ScriptBlock { $CommandScript }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value '_____'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllActiveDirectoryCommands += $BuildCommand


    $CollectionName = 'ADDS Group Membership by Users'
    $CommandScript = {
        $ADUserList = Get-ADUser -filter * | Select-Object -ExpandProperty SamAccountName
        foreach ($SamAccountName in $ADUserList) {                        
            $GroupMemberships = Get-ADPrincipalGroupMembership -Identity $SamAccountName
            $GroupMemberships | Add-Member -MemberType NoteProperty -Name SamAccountName -Value $SamAccountName -Force
            $GroupMemberships | Select-Object -Property SamAccountName, @{Name="Group Name";Expression={$_.Name}}, SID, GroupCategory, GroupScope, DistinguishedName
        } 
    }
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "User"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value "Invoke-Command -ScriptBlock { $CommandScript }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value '_____'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllActiveDirectoryCommands += $BuildCommand


    $CollectionName = 'ADDS Groups Without Account Members'
    $CommandScript = {
        Get-ADGroup -filter * `
        | Where-Object {-Not ($_ | Get-ADGroupMember)}
    }
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "User"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value "Invoke-Command -ScriptBlock { $CommandScript }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllActiveDirectoryCommands += $BuildCommand


    $CollectionName = 'ADDS DNS All Records (Server 2008)'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Network"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value "Invoke-Command -ScriptBlock { Get-WmiObject -Namespace root\MicrosoftDNS -class microsoftdns_resourcerecord }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value "Get-WmiObject -Namespace root\MicrosoftDNS -class microsoftdns_resourcerecord"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value 'PSComputerName, __Class, ContainerName, DomainName, RecordData, OwnerName'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value '_____'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllActiveDirectoryCommands += $BuildCommand


    $CollectionName = 'ADDS DNS Root Hints (Server 2008)'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Network"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value "Invoke-Command -ScriptBlock { Get-WmiObject -Namespace root\MicrosoftDNS -class microsoftdns_resourcerecord | Where-Object {$_.domainname -eq '..roothints'} }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value "Get-WmiObject -Namespace root\MicrosoftDNS -class microsoftdns_resourcerecord"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value 'PSComputerName, *'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value '_____'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllActiveDirectoryCommands += $BuildCommand


    $CollectionName = 'ADDS DNS Zones (Server 2008)'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Network"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value "Invoke-Command -ScriptBlock { Get-WmiObject -Credential $script:Credential -Namespace "root\MicrosoftDNS" -Class MicrosoftDNS_Zone"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value "Get-WmiObject -Credential $script:Credential -Namespace "root\MicrosoftDNS" -Class MicrosoftDNS_Zone"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value 'PSComputerName, Name'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllActiveDirectoryCommands += $BuildCommand


    $CollectionName = 'ADDS DNS Statistics (Server 2008)'
    $BuildCommand = New-Object PSObject -Property @{ Name = $CollectionName }
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Type                 -Value "Network"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_CMD_Arg  -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_RPC_PoSh     -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_Script -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_PoSh   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_WMI    -Value "Invoke-Command -ScriptBlock { Get-WmiObject -Credential $script:Credential -Namespace root\MicrosoftDNS -Class MicrosoftDNS_Statistic }"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRM_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WMI          -Value "Get-WmiObject -Namespace root\MicrosoftDNS -Class MicrosoftDNS_Statistic"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_WMIC   -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Command_WinRS_CMD    -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_PoSh      -Value $null
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Properties_WMI       -Value 'PSComputerName, Name, Value'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name Message              -Value '_____'
    $BuildCommand | Add-Member -MemberType NoteProperty -Name NotesPath            -Value "$CommandsHostDirectoryNotes\$CollectionName.txt"
    $BuildCommand | Add-Member -MemberType NoteProperty -Name ExportPath           -Value "$CollectionName"
    $script:AllActiveDirectoryCommands += $BuildCommand


#============================================================================================================================================================
#============================================================================================================================================================
#
# End of Commands
#
#============================================================================================================================================================
#============================================================================================================================================================

#============================================================================================================================================================
#
# Start TreeView
#
#============================================================================================================================================================
function Conduct-NodeAction {
    param($TreeView)
    # This will return data on hosts selected/highlight, but not necessarily checked
    [System.Windows.Forms.TreeNodeCollection]$AllNodes = $TreeView
    foreach ($root in $AllNodes) { 
        if ($root.Checked) { 
            foreach ($Category in $root.Nodes) { 
                $Category.Expand()
                $Category.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
                $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                foreach ($Entry in $Category.nodes) {
                    $Entry.Checked      = $True
                    $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",10,1,1,1)
                    $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,128,0)
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
            $EntryNodeCheckedCount = 0                        
            if ($Category.checked) {
                $Category.Expand()
                $Category.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
                $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                foreach ($Entry in $Category.nodes) {
                    $EntryNodeCheckedCount  += 1
                    $Entry.Checked      = $True
                    $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",10,1,1,1)
                    $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,128,0)
                }            
            }
            elseif (!($Category.checked)) {
                foreach ($Entry in $Category.nodes) { 
                    #if ($Entry.isselected) { 
                    if ($Entry.checked) {
                        $EntryNodeCheckedCount  += 1
                        $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",10,1,1,1)
                        $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,128,0)

                    }
                    elseif (!($Entry.checked)) { 
                        if ($CategoryCheck -eq $False) {$Category.Checked = $False}
                        $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",10,1,1,1)
                        $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,0,0)
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
                    $ResultsListBox.Items.Add("$((($Entry.Text) -split ' - ')[-1])")
                    #batman
                    #$CommandNotes = Get-Content -Path $($script:AllEndpointCommands | Where-Object Name -match $((($Entry.Text) -split ' - ')[-1])).NotesPath
                    #$ResultsListBox.Items.Clear()
                    #Foreach ($Line in $CommandNotes) {
                    #    $ResultsListBox.Items.Add($Line)                    
                    #}
                                      
                    # Brings the Host Data Tab to the forefront/front view
                    $Section4TabControl.SelectedTab   = $Section3ResultsTab
                    foreach ($Entry in $Category.nodes) {                     
                        if ($entry.checked) {
                            $EntryNodeCheckedCount  += 1
                            $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",10,1,1,1)
                            $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,128,0)
                            $Category.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
                            $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                        }
                        if (!($entry.checked)) {
                            $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",10,1,1,1)
                            $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,0,0)
                        }
                    }
                }
            }       
            if ($EntryNodeCheckedCount -gt 0) {
                $Category.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
                $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
            }
            else {
                $Category.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
                $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
            }
        }         
    }
}

function Initialize-CommandsTreeView {
    $CommandsTreeView.Nodes.Clear()
    $script:TreeNodeEndpointCommands                   = New-Object -TypeName System.Windows.Forms.TreeNode -ArgumentList 'Endpoint Commands'
    $script:TreeNodeEndpointCommands.Tag               = "Endpoint Commands"
    $script:TreeNodeEndpointCommands.Expand()
    $script:TreeNodeEndpointCommands.NodeFont          = New-Object System.Drawing.Font("$Font",10,1,1,1)
    $script:TreeNodeEndpointCommands.ForeColor         = [System.Drawing.Color]::FromArgb(0,0,0,0)

    $script:TreeNodeActiveDirectoryCommands            = New-Object -TypeName System.Windows.Forms.TreeNode -ArgumentList 'Active Directory Commands'
    $script:TreeNodeActiveDirectoryCommands.Tag        = "ADDS Commands"
    $script:TreeNodeActiveDirectoryCommands.Expand()
    $script:TreeNodeActiveDirectoryCommands.NodeFont   = New-Object System.Drawing.Font("$Font",10,1,1,1)
    $script:TreeNodeActiveDirectoryCommands.ForeColor  = [System.Drawing.Color]::FromArgb(0,0,0,0)

    $script:TreeNodeCommandSearch                      = New-Object -TypeName System.Windows.Forms.TreeNode -ArgumentList '* Search Results'
    $script:TreeNodeCommandSearch.Tag                  = "Search"
    $script:TreeNodeCommandSearch.Expand()
    $script:TreeNodeCommandSearch.NodeFont             = New-Object System.Drawing.Font("$Font",10,1,1,1)
    $script:TreeNodeCommandSearch.ForeColor            = [System.Drawing.Color]::FromArgb(0,0,0,0)
}

# This section will check the checkboxes selected under the other view
function Keep-CommandsCheckboxesChecked {
    $CommandsTreeView.Nodes.Add($script:TreeNodeEndpointCommands)
    $CommandsTreeView.Nodes.Add($script:TreeNodeActiveDirectoryCommands)
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
                        $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,128,0)
                        $Category.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
                        $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                        $Category.Expand()
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
    $newNode      = New-Object System.Windows.Forms.TreeNode  
    $newNode.Name = "$Entry"
    $newNode.Text = "$Entry"

    if ($ToolTip) { $newNode.ToolTipText  = "$ToolTip" }
    else { $newNode.ToolTipText  = "No Data Available" }
    If ($RootNode.Nodes.Tag -contains $Category) {
        $HostNode = $RootNode.Nodes | Where-Object {$_.Tag -eq $Category}
    }
    Else {
        $CategoryNode               = New-Object System.Windows.Forms.TreeNode
        $CategoryNode.Name          = $Category
        $CategoryNode.Text          = $Category
        $CategoryNode.Tag           = $Category
        #$CategoryNode.Expand()
        #$CategoryNode.ToolTipText   = "Checkbox this Category to query all its hosts"

        if ($Category -match '(WinRM)') {
            $CategoryNode.ToolTipText = "PowerShell Remoting
Protocols: HTTP(WSMan), MIME, SOAP, XML
Port:      5985/5986
Encrypted: Yes
OS:        Win7 / 2008R2+
           Older OSs with WinRM installed
Data:      Deserialized Object
Pros:      Single Port required
           Supports any cmdlet
Cons       Requires WinRM on Older OSes
           May require enabling (Enable-PSRemoting or GPO)"
        }
        elseif ($Category -match '(RPC)') {
            $CategoryNode.ToolTipText = "PowerShell Commands with -ComputerName
Protocols: RPC, Remote Registry (RRP), SMB2
Encrypted: Yes
Port:      445
OS:        Windows 2000 and above
Data:      Object               
Pros:      Works against older OSes
           Does not require WinRM
Cons:      Limited cmdlets support the computername switch"
        }
        elseif ($Category -match '(WMI)') {
            $CategoryNode.ToolTipText = "Get-WMIObject
Protocols: WMI/RPC/DCOM
Encrypted: Not Encrypted (clear text)
Ports:     135, Random High
OS:        Windows 2000 and above
Data:      Object
Pros:      Works against older OSs
           Does not require WinRM
Cons:      Limited functionality
           Random high ports
           Transmits data in clear text"
        }

        #Bolds the categories if the options checkbox is true
        if ($OptionBoldTreeViewCategoriesCheckBox.Checked -eq $true) { $CategoryNode.NodeFont   = New-Object System.Drawing.Font("$Font",10,1,2,1) }
        else { $CategoryNode.NodeFont   = New-Object System.Drawing.Font("$Font",10,1,1,1)}

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
            Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category 'Remote Procedure Call (RPC) PoSh' -Entry "(RPC) PoSh - $($Command.Name)" -ToolTip $Command.Command_RPC_PoSh
        }
        if ($Command.Command_RPC_CMD) {
            Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category 'Remote Procedure Call (RPC) Win CMD' -Entry "(RPC) CMD - $($Command.Name)" -ToolTip $Command.Command_RPC_CMD
        }
        if ($Command.Command_WMI) {
            Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category 'Windows Management Instrumentation (WMI)' -Entry "(WMI) - $($Command.Name)" -ToolTip $Command.Command_WMI
        }
#        if ($Command.Command_WinRS_WMIC) {
#            Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category 'Windows Remote Shell (WinRS) WMIC' -Entry "(WinRS) WMIC - $($Command.Name)" -ToolTip $Command.Command_WinRS_WMIC
#        }
#        if ($Command.Command_WinRS_CMD) {
#            Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category 'Windows Remote Shell (WinRS) CMD' -Entry "(WinRS) CMD - $($Command.Name)" -ToolTip $Command.Command_WinRS_CMD
#        }
        if ($Command.Command_WinRM_Script) {
            Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category 'PowerShell Remoting (WinRM) Scripts' -Entry "(WinRM) Script - $($Command.Name)" -ToolTip $Command.Command_WinRM_Script
        }        
        if ($Command.Command_WinRM_PoSh) {
            Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category 'PowerShell Remoting (WinRM) PoSh' -Entry "(WinRM) PoSh - $($Command.Name)" -ToolTip $Command.Command_WinRM_PoSh
        }
        if ($Command.Command_WinRM_WMI) {
            Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category 'PowerShell Remoting (WinRM) WMI' -Entry "(WinRM) WMI - $($Command.Name)" -ToolTip $Command.Command_WinRM_WMI
        }
        if ($Command.Command_WinRM_CMD) {
            Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category 'PowerShell Remoting (WinRM) Win CMD' -Entry "(WinRM) CMD - $($Command.Name)" -ToolTip $Command.Command_WinRM_CMD
        }
    }
    Foreach($Command in $script:AllActiveDirectoryCommands) {
        if ($Command.Command_RPC_PoSh) {
            Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category 'Remote Procedure Call (RPC) PoSh' -Entry "(RPC) PoSh - $($Command.Name)" -ToolTip $Command.Command_RPC_PoSh
        }
        if ($Command.Command_RPC_CMD) {
            Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category 'Remote Procedure Call (RPC) Win CMD' -Entry "(RPC) CMD - $($Command.Name)" -ToolTip $Command.Command_RPC_CMD
        }
        if ($Command.Command_WMI) {
            Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category 'Windows Management Instrumentation (WMI)' -Entry "(WMI) - $($Command.Name)" -ToolTip $Command.Command_WMI
        }
#        if ($Command.Command_WinRS_WMIC) {
#            Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category 'Windows Remote Shell (WinRS) WMIC' -Entry "(WinRS) WMIC - $($Command.Name)" -ToolTip $Command.Command_WinRS_WMIC
#        }
#        if ($Command.Command_WinRS_CMD) {
#            Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category 'Windows Remote Shell (WinRS) CMD' -Entry "(WinRS) CMD - $($Command.Name)" -ToolTip $Command.Command_WinRS_CMD
#        }
        if ($Command.Command_WinRM_Script) {
            Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category 'PowerShell Remoting (WinRM) Scripts' -Entry "(WinRM) Script - $($Command.Name)" -ToolTip $Command.Command_WinRM_Script
        }        
        if ($Command.Command_WinRM_PoSh) {
            Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category 'PowerShell Remoting (WinRM) PoSh' -Entry "(WinRM) PoSh - $($Command.Name)" -ToolTip $Command.Command_WinRM_PoSh
        }
        if ($Command.Command_WinRM_WMI) {
            Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category 'PowerShell Remoting (WinRM) WMI' -Entry "(WinRM) WMI - $($Command.Name)" -ToolTip $Command.Command_WinRM_WMI
        }
        if ($Command.Command_WinRM_CMD) {
            Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category 'PowerShell Remoting (WinRM) Win CMD' -Entry "(WinRM) CMD - $($Command.Name)" -ToolTip $Command.Command_WinRM_CMD
        }
    }
}

# Groups Commands TreeNodes by Method
Function View-CommandsTreeViewQuery {
    Foreach($Command in $script:AllEndpointCommands) {
        if ($Command.Command_RPC_PoSh) {
            Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(RPC) PoSh - $($Command.Name)" -ToolTip $Command.Command_RPC_PoSh
        }
        if ($Command.Command_RPC_CMD) {
            Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(RPC) CMD - $($Command.Name)" -ToolTip $Command.Command_RPC_CMD
        }
        if ($Command.Command_WMI) {
            Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(WMI) - $($Command.Name)" -ToolTip $Command.Command_WMI
        }
#        if ($Command.Command_WinRS_WMIC) {
#            Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(WinRS) WMIC - $($Command.Name)" -ToolTip $Command.Command_WinRS_WMIC
#        }
#        if ($Command.Command_WinRS_CMD) {
#            Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(WinRS) CMD - $($Command.Name)" -ToolTip $Command.Command_WinRS_CMD
#        }
        if ($Command.Command_WinRM_Script) {
            Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(WinRM) Script - $($Command.Name)" -ToolTip $Command.Command_WinRM_Script
        }        
        if ($Command.Command_WinRM_PoSh) {
            Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(WinRM) PoSh - $($Command.Name)" -ToolTip $Command.Command_WinRM_PoSh
        }
        if ($Command.Command_WinRM_WMI) {
            Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(WinRM) WMI - $($Command.Name)" -ToolTip $Command.Command_WinRM_WMI
        }
        if ($Command.Command_WinRM_CMD) {
            Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(WinRM) CMD - $($Command.Name)" -ToolTip $Command.Command_WinRM_CMD
        }
    }
    Foreach($Command in $script:AllActiveDirectoryCommands) {
        if ($Command.Command_RPC_PoSh) {
            Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(RPC) PoSh - $($Command.Name)" -ToolTip $Command.Command_RPC_PoSh
        }
        if ($Command.Command_RPC_CMD) {
            Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(RPC) CMD - $($Command.Name)" -ToolTip $Command.Command_RPC_CMD
        }
        if ($Command.Command_WMI) {
            Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(WMI) - $($Command.Name)" -ToolTip $Command.Command_WMI
        }
#        if ($Command.Command_WinRS_WMIC) {
#            Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(WinRS) WMIC - $($Command.Name)" -ToolTip $Command.Command_WinRS_WMIC
#        }
#        if ($Command.Command_WinRS_CMD) {
#            Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(WinRS) CMD - $($Command.Name)" -ToolTip $Command.Command_WinRS_CMD
#        }
        if ($Command.Command_WinRM_Script) {
            Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(WinRM) Script - $($Command.Name)" -ToolTip $Command.Command_WinRM_Script
        }        
        if ($Command.Command_WinRM_PoSh) {
            Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(WinRM) PoSh - $($Command.Name)" -ToolTip $Command.Command_WinRM_PoSh
        }
        if ($Command.Command_WinRM_WMI) {
            Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(WinRM) WMI - $($Command.Name)" -ToolTip $Command.Command_WinRM_WMI
        }
        if ($Command.Command_WinRM_CMD) {
            Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(WinRM) CMD - $($Command.Name)" -ToolTip $Command.Command_WinRM_CMD
        }
    }}

#============================================================================================================================================================
# Commands - Treeview Options at the top
#============================================================================================================================================================

#-----------------------------
# View hostname/IPs by: Label
#-----------------------------
$CommandsTreeViewViewByLabel          = New-Object System.Windows.Forms.Label
$CommandsTreeViewViewByLabel.Text     = "View by:"
$CommandsTreeViewViewByLabel.Location = New-Object System.Drawing.Size(0,5)
$CommandsTreeViewViewByLabel.Size     = New-Object System.Drawing.Size(75,20)
$CommandsTreeViewViewByLabel.Font     = New-Object System.Drawing.Font("$Font",11,1,2,1)
$Section1CommandsTab.Controls.Add($CommandsTreeViewViewByLabel)

#----------------------------------------------
# Commands TreeView - Method Type Radio Button
#----------------------------------------------
$CommandsViewMethodRadioButton          = New-Object System.Windows.Forms.RadioButton
$System_Drawing_Point                    = New-Object System.Drawing.Point
$System_Drawing_Point.X                  = $CommandsTreeViewViewByLabel.Location.X + $CommandsTreeViewViewByLabel.Size.Width
$System_Drawing_Point.Y                  = $CommandsTreeViewViewByLabel.Location.Y - 5
$CommandsViewMethodRadioButton.Location = $System_Drawing_Point
$System_Drawing_Size                     = New-Object System.Drawing.Size
$System_Drawing_Size.Height              = 22
$System_Drawing_Size.Width               = 100
$CommandsViewMethodRadioButton.size     = $System_Drawing_Size
$CommandsViewMethodRadioButton.Checked  = $True
$CommandsViewMethodRadioButton.Text     = "Method"
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
$Section1CommandsTab.Controls.Add($CommandsViewMethodRadioButton)

#---------------------------------------------
# Commands TreeView - Query Type Radio Button
#---------------------------------------------
$CommandsViewQueryRadioButton          = New-Object System.Windows.Forms.RadioButton
$System_Drawing_Point                  = New-Object System.Drawing.Point
$System_Drawing_Point.X                = $CommandsViewMethodRadioButton.Location.X + $CommandsViewMethodRadioButton.Size.Width + 5
$System_Drawing_Point.Y                = $CommandsViewMethodRadioButton.Location.Y
$CommandsViewQueryRadioButton.Location = $System_Drawing_Point
$System_Drawing_Size                   = New-Object System.Drawing.Size
$System_Drawing_Size.Height            = 22
$System_Drawing_Size.Width             = 100
$CommandsViewQueryRadioButton.size     = $System_Drawing_Size
$CommandsViewQueryRadioButton.Checked  = $false
$CommandsViewQueryRadioButton.Text     = "Query"
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
$Section1CommandsTab.Controls.Add($CommandsViewQueryRadioButton)
$Column5DownPosition += $Column5DownPositionShift

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
        Foreach($Command in $script:AllCommands) {
            if (($SearchFound -inotcontains $Computer) -and (
                ($Command.Name -imatch $CommandsTreeViewSearchTextBox.Text) -or
                ($Command.Type -imatch $CommandsTreeViewSearchTextBox.Text) -or
                ($Command.Message -imatch $CommandsTreeViewSearchTextBox.Text))) {
                if ($Command.Command_RPC_PoSh) {
                    Add-CommandsNode -RootNode $script:TreeNodeCommandSearch -Category $($CommandsTreeViewSearchTextBox.Text) -Entry "(RPC) PoSh - $($Command.Name)" -ToolTip $Command.Command_RPC_PoSh
                }
                if ($Command.Command_RPC_CMD) {
                    Add-CommandsNode -RootNode $script:TreeNodeCommandSearch -Category $($CommandsTreeViewSearchTextBox.Text) -Entry "(RPC) CMD - $($Command.Name)" -ToolTip $Command.Command_RPC_CMD
                }
                if ($Command.Command_WMI) {
                    Add-CommandsNode -RootNode $script:TreeNodeCommandSearch -Category $($CommandsTreeViewSearchTextBox.Text) -Entry "(WMI) - $($Command.Name)" -ToolTip $Command.Command_WMI
                }
        #        if ($Command.Command_WinRS_WMIC) {
        #            Add-CommandsNode -RootNode $script:TreeNodeCommandSearch -Category $($CommandsTreeViewSearchTextBox.Text) -Entry "(WinRS) WMIC - $($Command.Name)" -ToolTip $Command.Command_WinRS_WMIC
        #        }
        #        if ($Command.Command_WinRS_CMD) {
        #            Add-CommandsNode -RootNode $script:TreeNodeCommandSearch -Category $($CommandsTreeViewSearchTextBox.Text) -Entry "(WinRS) CMD - $($Command.Name)" -ToolTip $Command.Command_WinRS_CMD
        #        }
                if ($Command.Command_WinRM_Script) {
                    Add-CommandsNode -RootNode $script:TreeNodeCommandSearch -Category $($CommandsTreeViewSearchTextBox.Text) -Entry "(WinRM) Script - $($Command.Name)" -ToolTip $Command.Command_WinRM_Script
                }        
                if ($Command.Command_WinRM_PoSh) {
                    Add-CommandsNode -RootNode $script:TreeNodeCommandSearch -Category $($CommandsTreeViewSearchTextBox.Text) -Entry "(WinRM) PoSh - $($Command.Name)" -ToolTip $Command.Command_WinRM_PoSh
                }
                if ($Command.Command_WinRM_WMI) {
                    Add-CommandsNode -RootNode $script:TreeNodeCommandSearch -Category $($CommandsTreeViewSearchTextBox.Text) -Entry "(WinRM) WMI - $($Command.Name)" -ToolTip $Command.Command_WinRM_WMI
                }
                if ($Command.Command_WinRM_CMD) {
                    Add-CommandsNode -RootNode $script:TreeNodeCommandSearch -Category $($CommandsTreeViewSearchTextBox.Text) -Entry "(WinRM) CMD - $($Command.Name)" -ToolTip $Command.Command_WinRM_CMD
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
$CommandsTreeViewSearchTextBox               = New-Object System.Windows.Forms.ComboBox
$CommandsTreeViewSearchTextBox.Name          = "Search TextBox"
$CommandsTreeViewSearchTextBox.Location      = New-Object System.Drawing.Size(0,25)
$CommandsTreeViewSearchTextBox.Size          = New-Object System.Drawing.Size(172,25)
$CommandsTreeViewSearchTextBox.AutoCompleteSource = "ListItems" # Options are: FileSystem, HistoryList, RecentlyUsedList, AllURL, AllSystemSources, FileSystemDirectories, CustomSource, ListItems, None
$CommandsTreeViewSearchTextBox.AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
    $CommandTypes = @("user","network","hardware","system","File","Hunt")
    ForEach ($Type in $CommandTypes) { 
        [void] $CommandsTreeViewSearchTextBox.Items.Add($Type) 
    }
$CommandsTreeViewSearchTextBox.Add_KeyDown({ 
    if ($_.KeyCode -eq "Enter") { 
        Search-CommandsTreeView
    }
})
$Section1CommandsTab.Controls.Add($CommandsTreeViewSearchTextBox)

#-----------------------------------
# Computer TreeView - Search Button
#-----------------------------------
$CommandsTreeViewSearchButton          = New-Object System.Windows.Forms.Button
$CommandsTreeViewSearchButton.Name     = "Search Button"
$CommandsTreeViewSearchButton.Text     = "Search"
$CommandsTreeViewSearchButton.Location = New-Object System.Drawing.Size(($CommandsTreeViewSearchTextBox.Size.Width + 5),25)
$CommandsTreeViewSearchButton.Size     = New-Object System.Drawing.Size(55,22)
$CommandsTreeViewSearchButton.Font     = New-Object System.Drawing.Font("$Font",10,0,2,1)
$CommandsTreeViewSearchButton.Add_Click({
    Search-CommandsTreeView
})
$Section1CommandsTab.Controls.Add($CommandsTreeViewSearchButton)


#-----------------------------------------
# Commands Treeview - Deselect All Button
#-----------------------------------------
$CommandsTreeviewDeselectAllButton           = New-Object System.Windows.Forms.Button
$CommandsTreeviewDeselectAllButton.Location  = New-Object System.Drawing.Size(336,25)
$CommandsTreeviewDeselectAllButton.Size      = New-Object System.Drawing.Size(100,22)
$CommandsTreeviewDeselectAllButton.Text      = 'Deselect All'
$CommandsTreeviewDeselectAllButton.Add_Click({
    [System.Windows.Forms.TreeNodeCollection]$AllCommandsNode = $CommandsTreeView.Nodes 
    foreach ($root in $AllCommandsNode) { 
        $root.Checked = $false
        $root.Expand()
        foreach ($Category in $root.Nodes) { 
            $Category.Collapse()
            $Category.Checked   = $false
            $Category.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
            $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
            foreach ($Entry in $Category.nodes) { 
                $Entry.Checked   = $false
                $Entry.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
                $Entry.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
            }
        }
    }
})
$Section1CommandsTab.Controls.Add($CommandsTreeviewDeselectAllButton) 

#---------------------------
# Commands Treeview Nodes
#---------------------------
$CommandsTreeView            = New-Object System.Windows.Forms.TreeView
$System_Drawing_Size         = New-Object System.Drawing.Size
$System_Drawing_Size.Width   = 435
$System_Drawing_Size.Height  = 475
$CommandsTreeView.Size       = $System_Drawing_Size
$System_Drawing_Point        = New-Object System.Drawing.Point
$System_Drawing_Point.X      = 0
$System_Drawing_Point.Y      = 50
$CommandsTreeView.Location   = $System_Drawing_Point
$CommandsTreeView.Font       = New-Object System.Drawing.Font("$Font",8,0,3,0)
$CommandsTreeView.CheckBoxes = $True
#$CommandsTreeView.LabelEdit  = $True
$CommandsTreeView.ShowLines  = $True
$CommandsTreeView.ShowNodeToolTips  = $True
$CommandsTreeView.Sort()
$CommandsTreeView.Add_Click({Conduct-NodeAction -TreeView $CommandsTreeView.Nodes})
$CommandsTreeView.add_AfterSelect({Conduct-NodeAction -TreeView $CommandsTreeView.Nodes})
$Section1CommandsTab.Controls.Add($CommandsTreeView)

# Default View
Initialize-CommandsTreeView

# This adds the nodes to the Commands TreeView
View-CommandsTreeViewMethod

$CommandsTreeView.Nodes.Add($script:TreeNodeEndpointCommands)
$CommandsTreeView.Nodes.Add($script:TreeNodeActiveDirectoryCommands)
$CommandsTreeView.Nodes.Add($script:TreeNodeCommandSearch)
#$CommandsTreeView.ExpandAll()
        
##############################################################################################################################################################
##
## Section 1 Event Logs Tab
##
##############################################################################################################################################################

# Varables for positioning checkboxes
$EventLogsRightPosition     = 5
$EventLogsDownPositionStart = 10
$EventLogsDownPosition      = 10
$EventLogsDownPositionShift = 22
$EventLogsBoxWidth          = 410
$EventLogsBoxHeight         = 22

$LimitNumberOfEventLogsCollectToChoice = 100

#----------------
# Event Logs Tab
#----------------
$Section1EventLogsTab          = New-Object System.Windows.Forms.TabPage
$Section1EventLogsTab.Location = $System_Drawing_Point
$Section1EventLogsTab.Text     = "Event Logs"
$Section1EventLogsTab.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$Section1EventLogsTab.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 
$Section1EventLogsTab.UseVisualStyleBackColor = $True
$Section1CollectionsTabControl.Controls.Add($Section1EventLogsTab)


#-------------------------
# Event Logs - Main Label
#-------------------------
$EventLogsMainLabel           = New-Object System.Windows.Forms.Label
$EventLogsMainLabel.Text      = "Event Logs can be obtained from hosts and servers."
$EventLogsMainLabel.Location  = New-Object System.Drawing.Point(5,5) 
$EventLogsMainLabel.Size      = New-Object System.Drawing.Size($EventLogsBoxWidth,$EventLogsBoxHeight) 
$EventLogsMainLabel.Font      = New-Object System.Drawing.Font("$Font",11,1,3,1)
$EventLogsMainLabel.ForeColor = "Blue"
$Section1EventLogsTab.Controls.Add($EventLogsMainLabel)

#============================================================================================================================================================
# Event Logs - Event IDs Manual Entry
#============================================================================================================================================================

#-----------------------------------------------
# Event Logs - Event IDs Manual Entry CheckBox
#-----------------------------------------------
$EventLogsEventIDsManualEntryCheckbox          = New-Object System.Windows.Forms.CheckBox
$EventLogsEventIDsManualEntryCheckbox.Name     = "Event IDs Manual Entry  *"
$EventLogsEventIDsManualEntryCheckbox.Text     = "$($EventLogsEventIDsManualEntryCheckbox.Name)"
$EventLogsEventIDsManualEntryCheckbox.Location = New-Object System.Drawing.Size(5,($EventLogsMainLabel.Location.Y + $EventLogsMainLabel.Size.Height + 2)) 
$EventLogsEventIDsManualEntryCheckbox.Size     = New-Object System.Drawing.Size(200,$EventLogsBoxHeight) 
$Section1EventLogsTab.Controls.Add($EventLogsEventIDsManualEntryCheckbox)

#-------------------------------------------------------
# Event Logs - Event IDs Manual Entry Selection Button
#-------------------------------------------------------
if (Test-Path $EventIDsFile) {
    $EventLogsEventIDsManualEntrySelectionButton          = New-Object System.Windows.Forms.Button
    $EventLogsEventIDsManualEntrySelectionButton.Text     = "Select Event IDs"
    $EventLogsEventIDsManualEntrySelectionButton.Location = New-Object System.Drawing.Size(226,($EventLogsMainLabel.Location.Y + $EventLogsMainLabel.Size.Height + 2)) 
    $EventLogsEventIDsManualEntrySelectionButton.Size     = New-Object System.Drawing.Size(125,20) 
    $EventLogsEventIDsManualEntrySelectionButton.Add_Click({
        Import-Csv "$ResourcesDirectory\Event IDs.csv" | Out-GridView -OutputMode Multiple | Set-Variable -Name EventCodeManualEntrySelectionContents
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
$EventLogsEventIDsManualEntryClearButton.Location = New-Object System.Drawing.Size(356,($EventLogsMainLabel.Location.Y + $EventLogsMainLabel.Size.Height + 2)) 
$EventLogsEventIDsManualEntryClearButton.Size     = New-Object System.Drawing.Size(75,20) 
$EventLogsEventIDsManualEntryClearButton.Add_Click({
    $EventLogsEventIDsManualEntryTextbox.Text = ""
})
$Section1EventLogsTab.Controls.Add($EventLogsEventIDsManualEntryClearButton) 

#--------------------------------------------
# Event Logs - Event IDs Manual Entry Label
#--------------------------------------------
$EventLogsEventIDsManualEntryLabel           = New-Object System.Windows.Forms.Label
$EventLogsEventIDsManualEntryLabel.Location  = New-Object System.Drawing.Point(5,($EventLogsEventIDsManualEntryCheckbox.Location.Y + $EventLogsEventIDsManualEntryCheckbox.Size.Height)) 
$EventLogsEventIDsManualEntryLabel.Size      = New-Object System.Drawing.Size($EventLogsBoxWidth,$EventLogsBoxHeight) 
$EventLogsEventIDsManualEntryLabel.Text      = "Enter Event IDs - One Per Line"
$EventLogsEventIDsManualEntryLabel.Font      = New-Object System.Drawing.Font("$Font",9,0,3,0)
$EventLogsEventIDsManualEntryLabel.ForeColor = "Black"
$Section1EventLogsTab.Controls.Add($EventLogsEventIDsManualEntryLabel)

#----------------------------------------------
# Event Logs - Event IDs Manual Entry Textbox
#----------------------------------------------
$EventLogsEventIDsManualEntryTextbox               = New-Object System.Windows.Forms.TextBox
$EventLogsEventIDsManualEntryTextbox.Location      = New-Object System.Drawing.Size(5,($EventLogsEventIDsManualEntryLabel.Location.Y + $EventLogsEventIDsManualEntryLabel.Size.Height)) 
$EventLogsEventIDsManualEntryTextbox.Size          = New-Object System.Drawing.Size(425,100)
$EventLogsEventIDsManualEntryTextbox.MultiLine     = $True
$EventLogsEventIDsManualEntryTextbox.ScrollBars    = "Vertical"
$EventLogsEventIDsManualEntryTextbox.WordWrap      = True
$EventLogsEventIDsManualEntryTextbox.AcceptsTab    = false # Allows you to enter in tabs into the textbox
$EventLogsEventIDsManualEntryTextbox.AcceptsReturn = false # Allows you to enter in tabs into the textbox
$EventLogsEventIDsManualEntryTextbox.Font          = New-Object System.Drawing.Font("$Font",9,0,3,1)
#$EventLogsEventIDsManualEntryTextbox.Add_KeyDown({          })
$Section1EventLogsTab.Controls.Add($EventLogsEventIDsManualEntryTextbox)

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
    $EventLogsEventIDsIndividualSelectionCheckbox          = New-Object System.Windows.Forms.CheckBox
    $EventLogsEventIDsIndividualSelectionCheckbox.Name     = "Event IDs Individual Selection  *"
    $EventLogsEventIDsIndividualSelectionCheckbox.Text     = "$($EventLogsEventIDsIndividualSelectionCheckbox.Name)"
    $EventLogsEventIDsIndividualSelectionCheckbox.Location = New-Object System.Drawing.Size(5,($EventLogsEventIDsManualEntryTextbox.Location.Y + $EventLogsEventIDsManualEntryTextbox.Size.Height + 8)) 
    $EventLogsEventIDsIndividualSelectionCheckbox.Size     = New-Object System.Drawing.Size(350,$EventLogsBoxHeight) 
    $Section1EventLogsTab.Controls.Add($EventLogsEventIDsIndividualSelectionCheckbox)

    #-----------------------------------------------------------
    # Event Logs - Event IDs Individual Selection Clear Button
    #-----------------------------------------------------------
    $EventLogsEventIDsIndividualSelectionClearButton          = New-Object System.Windows.Forms.Button
    $EventLogsEventIDsIndividualSelectionClearButton.Text     = "Clear"
    $EventLogsEventIDsIndividualSelectionClearButton.Location = New-Object System.Drawing.Size(356,($EventLogsEventIDsManualEntryTextbox.Location.Y + $EventLogsEventIDsManualEntryTextbox.Size.Height + 8)) 
    $EventLogsEventIDsIndividualSelectionClearButton.Size     = New-Object System.Drawing.Size(75,20)
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
    $EventLogsEventIDsIndividualSelectionLabel           = New-Object System.Windows.Forms.Label
    $EventLogsEventIDsIndividualSelectionLabel.Location  = New-Object System.Drawing.Point(5,($EventLogsEventIDsIndividualSelectionCheckbox.Location.Y + $EventLogsEventIDsIndividualSelectionCheckbox.Size.Height))
    $EventLogsEventIDsIndividualSelectionLabel.Size      = New-Object System.Drawing.Size($EventLogsBoxWidth,$EventLogsBoxHeight) 
    $EventLogsEventIDsIndividualSelectionLabel.Text      = "Events IDs to Monitor for Signs of Compromise"
    $EventLogsEventIDsIndividualSelectionLabel.Font      = New-Object System.Drawing.Font("$Font",9,0,3,0)
    $EventLogsEventIDsIndividualSelectionLabel.ForeColor = "Black"
    $Section1EventLogsTab.Controls.Add($EventLogsEventIDsIndividualSelectionLabel)

    #-----------------------------------------------------------
    # Event Logs - Event IDs Individual Selection Checklistbox
    #-----------------------------------------------------------
    $EventLogsEventIDsIndividualSelectionChecklistbox          = New-Object -TypeName System.Windows.Forms.CheckedListBox
    $EventLogsEventIDsIndividualSelectionChecklistbox.Name     = "Event IDs [Potential Criticality] Event Summary"
    $EventLogsEventIDsIndividualSelectionChecklistbox.Text     = "$($EventLogsEventIDsIndividualSelectionChecklistbox.Name)"
    $EventLogsEventIDsIndividualSelectionChecklistbox.Location = New-Object System.Drawing.Size(5,($EventLogsEventIDsIndividualSelectionLabel.Location.Y + $EventLogsEventIDsIndividualSelectionLabel.Size.Height)) 
    $EventLogsEventIDsIndividualSelectionChecklistbox.Size     = New-Object System.Drawing.Size(425,125)
    #$EventLogsEventIDsIndividualSelectionChecklistbox.checked = $true
    #$EventLogsEventIDsIndividualSelectionChecklistbox.CheckOnClick = $true #so we only have to click once to check a box
    #$EventLogsEventIDsIndividualSelectionChecklistbox.SelectionMode = One #This will only allow one options at a time
    $EventLogsEventIDsIndividualSelectionChecklistbox.ScrollAlwaysVisible = $true

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
    $Section1EventLogsTab.Controls.Add($EventLogsEventIDsIndividualSelectionChecklistbox)
}

#============================================================================================================================================================
# Event Logs - Event IDs Quick Pick Selection 
#============================================================================================================================================================
    $script:EventLogQueries = @()
    $EventLogReference = "https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/plan/appendix-l--events-to-monitor"
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Reference -Value "$EventLogReference" -Force

    $EventLogQuery = New-Object PSObject -Property @{ Name = "Application Event Logs" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Application')" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "Gets all Aplication Event Logs" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\Application Event Logs.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "Security Event Logs" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security')" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "Gets all Security Event Logs" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\Security Event Logs.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "System Event Logs" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='System')" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "Gets all System Event Logs" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\System Event Logs.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "Application Event Logs Errors" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Application') AND (type='error')" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\Application Event Logs Errors.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "System Event Logs Errors" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='System') AND (type='error')" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\System Event Logs Errors.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "Splunk Sexy Six" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "((EventCode='4688') OR (EventCode='592') OR (EventCode='4624') OR (EventCode='528') OR (EventCode='540') OR (EventCode='5140') OR (EventCode='560') OR (EventCode='5156') OR (EventCode='7045') OR (EventCode='601') OR (EventCode='4663') OR (EventCode='576'))" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "Splunk Sexy Six" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\Splunk Sexy Six.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "Incident Response - root9b" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "((EventCode='1100') OR (EventCode='1102') OR (EventCode='4608') OR (EventCode='4609') OR (EventCode='4616') OR (EventCode='4624') OR (EventCode='4625') OR (EventCode='4634') OR (EventCode='4647') OR (EventCode='4663') OR (EventCode='4688') OR (EventCode='4697') OR (EventCode='4720') OR (EventCode='4722') OR (EventCode='4723') OR (EventCode='4724') OR (EventCode='4725') OR (EventCode='4726') OR (EventCode='4732') OR (EventCode='4738') OR (EventCode='4769') OR (EventCode='4771') OR (EventCode='4772') OR (EventCode='2773') OR (EventCode='4820') OR (EventCode='4821') OR (EventCode='4825') OR (EventCode='4965') OR (EventCode='5140') OR (EventCode='5156') OR (EventCode='6006') OR (EventCode='7030') OR (EventCode='7040') OR (EventCode='7045') OR (EventCode='1056') OR (EventCode='10000') OR (EventCode='10001') OR (EventCode='10100') OR (EventCode='20001') OR (EventCode='20002') OR (EventCode='20003') OR (EventCode='24576') OR (EventCode='24577') OR (EventCode='24579') OR (EventCode='40961') OR (EventCode='4100') OR (EventCode='4104'))" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\Incident Response - root9b.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "Account Lockout" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND (EventCode='4625')" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\Account Lockout.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "Account Management" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND ((EventCode='4720') OR (EventCode='4722') OR (EventCode='4723') OR (EventCode='4724') OR (EventCode='4725') OR (EventCode='4726') OR (EventCode='4738') OR (EventCode='4740') OR (EventCode='4765') OR (EventCode='4766') OR (EventCode='4767') OR (EventCode='4780') OR (EventCode='4781') OR (EventCode='4781') OR (EventCode='4794') OR (EventCode='4798') OR (EventCode='5376') OR (EventCode='5377'))" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\Account Management.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "Account Management Events - Other" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND ((EventCode='4782') OR (EventCode='4793'))" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\Account Management Events - Other.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "Application Event Logs Generated" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND ((EventCode='4665') OR (EventCode='4666') OR (EventCode='4667') OR (EventCode='4668'))" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\Application Generated.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "Application Event Logs Group Management" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND ((EventCode='4783') OR (EventCode='4784') OR (EventCode='4785') OR (EventCode='4786') OR (EventCode='4787') OR (EventCode='4788') OR (EventCode='4789') OR (EventCode='4790') OR (EventCode='4791') OR (EventCode='4792'))" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\Application Group Management.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "Authentication Policy Change" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND ((EventCode='4670') OR (EventCode='4706') OR (EventCode='4707') OR (EventCode='4716') OR (EventCode='4713') OR (EventCode='4717') OR (EventCode='4718') OR (EventCode='4739') OR (EventCode='4864') OR (EventCode='4865') OR (EventCode='4866') OR (EventCode='4867'))" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\Authentication Policy Change.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "Authorization Policy Change" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND ((EventCode='4703') OR (EventCode='4704') OR (EventCode='4705') OR (EventCode='4670') OR (EventCode='4911') OR (EventCode='4913'))" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\Authorization Policy Change.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "Audit Policy Change" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND ((EventCode='4902') OR (EventCode='4907') OR (EventCode='4904') OR (EventCode='4905') OR (EventCode='4715') OR (EventCode='4719') OR (EventCode='4817') OR (EventCode='4902') OR (EventCode='4906') OR (EventCode='4907') OR (EventCode='4908') OR (EventCode='4912') OR (EventCode='4904') OR (EventCode='4905'))" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\Audit Policy Change.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "Central Access Policy Staging" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND (EventCode='4818')" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\Central Access Policy Staging.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "Certification Services" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND ((EventCode='4868') OR (EventCode='4869') OR (EventCode='4870') OR (EventCode='4871') OR (EventCode='4872') OR (EventCode='4873') OR (EventCode='4874') OR (EventCode='4875') OR (EventCode='4876') OR (EventCode='4877') OR (EventCode='4878') OR (EventCode='4879') OR (EventCode='4880') OR (EventCode='4881') OR (EventCode='4882') OR (EventCode='4883') OR (EventCode='4884') OR (EventCode='4885') OR (EventCode='4886') OR (EventCode='4887') OR (EventCode='4888') OR (EventCode='4889') OR (EventCode='4890') OR (EventCode='4891') OR (EventCode='4892') OR (EventCode='4893') OR (EventCode='4894') OR (EventCode='4895') OR (EventCode='4896') OR (EventCode='4897') OR (EventCode='4898'))" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\Certification Services.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "Computer Account Management" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND ((EventCode='4741') OR (EventCode='4742') OR (EventCode='4743'))" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\Computer Account Management.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "Detailed Directory Service Replication" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND ((EventCode='4928') OR (EventCode='4929') OR (EventCode='4930') OR (EventCode='4931') OR (EventCode='4934') OR (EventCode='4935') OR (EventCode='4936') OR (EventCode='4937'))" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\Detailed Directory Service Replication.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "Detailed File Share" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND (EventCode='5145')" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\Detailed File Share.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "Directory Service Access" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND ((EventCode='4662') OR (EventCode='4661'))" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\Directory Service Access.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "Directory Service Changes" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND ((EventCode='5136') OR (EventCode='5137') OR (EventCode='5138') OR (EventCode='5139') OR (EventCode='5141'))" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\Directory Service Changes.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "Directory Service Replication" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND ((EventCode='4932') OR (EventCode='4933'))" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\Directory Service Replication.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "Distribution Group Management" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND ((EventCode='4749') OR (EventCode='4750') OR (EventCode='4751') OR (EventCode='4752') OR (EventCode='4753') OR (EventCode='4759') OR (EventCode='4760') OR (EventCode='4761') OR (EventCode='4762') OR (EventCode='4763') OR (EventCode='4744') OR (EventCode='4745') OR (EventCode='4746') OR (EventCode='4747') OR (EventCode='4748'))" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\Distribution Group Management.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "DPAPI Activity" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND ((EventCode='4692') OR (EventCode='4693') OR (EventCode='4694') OR (EventCode='4695'))" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\DPAPI Activity.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "File Share" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND ((EventCode='5140') OR (EventCode='5142') OR (EventCode='5143') OR (EventCode='5144') OR (EventCode='5168'))" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\File Share.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "File System" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND ((EventCode='4656') OR (EventCode='4658') OR (EventCode='4660') OR (EventCode='4663') OR (EventCode='4664') OR (EventCode='4985') OR (EventCode='5051') OR (EventCode='4670'))" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\File System.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "Filtering Platform Connection" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND ((EventCode='5031') OR (EventCode='5150') OR (EventCode='5151') OR (EventCode='5154') OR (EventCode='5155') OR (EventCode='5156') OR (EventCode='5157') OR (EventCode='5158') OR (EventCode='5159'))" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\Filtering Platform Connection.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "Filtering Platform Packet Drop" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND ((EventCode='5152') OR (EventCode='5153'))" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\Filtering Platform Packet Drop.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "Filtering Platform Policy Change" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND ((EventCode='4709') OR (EventCode='4710') OR (EventCode='4711') OR (EventCode='4712') OR (EventCode='5040') OR (EventCode='5041') OR (EventCode='5042') OR (EventCode='5043') OR (EventCode='5044') OR (EventCode='5045') OR (EventCode='5046') OR (EventCode='5047') OR (EventCode='5048') OR (EventCode='5440') OR (EventCode='5441') OR (EventCode='5442') OR (EventCode='5443') OR (EventCode='5444') OR (EventCode='5446') OR (EventCode='5448') OR (EventCode='5449') OR (EventCode='5450') OR (EventCode='5456') OR (EventCode='5457') OR (EventCode='5458') OR (EventCode='5459') OR (EventCode='5460') OR (EventCode='5461') OR (EventCode='5462') OR (EventCode='5463') OR (EventCode='5464') OR (EventCode='5465') OR (EventCode='5466') OR (EventCode='5467') OR (EventCode='5468') OR (EventCode='5471') OR (EventCode='5472') OR (EventCode='5473') OR (EventCode='5474') OR (EventCode='5477'))" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\Filtering Platform Policy Change.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "Group Membership" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND (EventCode='4627')" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\Group Membership.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "Handle Manipulation" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND ((EventCode='4658') OR (EventCode='4690'))" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\Handle Manipulation.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "IPSec Driver" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND ((EventCode='4960') OR (EventCode='4961') OR (EventCode='4962') OR (EventCode='4963') OR (EventCode='4965') OR (EventCode='5478') OR (EventCode='5479') OR (EventCode='5480') OR (EventCode='5483') OR (EventCode='5484') OR (EventCode='5485'))" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\IPSec Driver.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "IPSec Extended Mode" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND ((EventCode='4978') OR (EventCode='4979') OR (EventCode='4980') OR (EventCode='4981') OR (EventCode='4982') OR (EventCode='4983') OR (EventCode='4984'))" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\IPSec Extended Mode.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "IPSec Main Mode" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND ((EventCode='4646') OR (EventCode='4650') OR (EventCode='4651') OR (EventCode='4652') OR (EventCode='4653') OR (EventCode='4655') OR (EventCode='4976') OR (EventCode='5049') OR (EventCode='5453'))" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\IPSec Main Mode.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "IPSec Quick Mode" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND ((EventCode='4977') OR (EventCode='5451') OR (EventCode='5452'))" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\IPSec Quick Mode.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "Kerberos Authentication Service" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND ((EventCode='4768') OR (EventCode='4771') OR (EventCode='4772'))" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\Kerberos Authentication Service.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "Kerberos Service Ticket Operations" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND ((EventCode='4769') OR (EventCode='4770') OR (EventCode='4773'))" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\Kerberos Service Ticket Operations.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "Kernel Object" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND ((EventCode='4656') OR (EventCode='4658') OR (EventCode='4660') OR (EventCode='4663'))" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\Kernel Object.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "Logon and Logoff Events" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND ((EventCode='4624') OR (EventCode='4625') OR (EventCode='4648') OR (EventCode='4675') OR (EventCode='4634') OR (EventCode='4647'))" -Force     
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\Logon and Logoff Events.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "Logon and Logoff Events - Other" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND ((EventCode='4649') OR (EventCode='4778') OR (EventCode='4779') OR (EventCode='4800') OR (EventCode='4801') OR (EventCode='4802') OR (EventCode='4803') OR (EventCode='5378') OR (EventCode='5632') OR (EventCode='5633'))" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\Logon and Logoff Events - Other.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "MPSSVC Rule-Level Policy Change" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND ((EventCode='4944') OR (EventCode='4945') OR (EventCode='4946') OR (EventCode='4947') OR (EventCode='4948') OR (EventCode='4949') OR (EventCode='4950') OR (EventCode='4951') OR (EventCode='4952') OR (EventCode='4953') OR (EventCode='4954') OR (EventCode='4956') OR (EventCode='4957') OR (EventCode='4958'))" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\MPSSVC Rule Level Policy Change.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "Network Policy Server" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND ((EventCode='6272') OR (EventCode='6273') OR (EventCode='6274') OR (EventCode='6275') OR (EventCode='6276') OR (EventCode='6277') OR (EventCode='6278') OR (EventCode='6279') OR (EventCode='6280'))" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\Network Policy Server.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "Other Events" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND ((EventCode='1100') OR (EventCode='1102') OR (EventCode='1104') OR (EventCode='1105') OR (EventCode='1108'))" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\Other Events.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "Other Object Access Events" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND ((EventCode='4671') OR (EventCode='4691') OR (EventCode='5148') OR (EventCode='5149') OR (EventCode='4698') OR (EventCode='4699') OR (EventCode='4700') OR (EventCode='4701') OR (EventCode='4702') OR (EventCode='5888') OR (EventCode='5889') OR (EventCode='5890'))" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\Other Object Access Events.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "Other Policy Change Events" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND ((EventCode='4714') OR (EventCode='4819') OR (EventCode='4826') OR (EventCode='4909') OR (EventCode='4910') OR (EventCode='5063') OR (EventCode='5064') OR (EventCode='5065') OR (EventCode='5066') OR (EventCode='5067') OR (EventCode='5068') OR (EventCode='5069') OR (EventCode='5070') OR (EventCode='5447') OR (EventCode='6144') OR (EventCode='6145'))" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\Other Policy Change Events.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "Other System Events" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND ((EventCode='5024') OR (EventCode='5025') OR (EventCode='5027') OR (EventCode='5028') OR (EventCode='5029') OR (EventCode='5030') OR (EventCode='5032') OR (EventCode='5033') OR (EventCode='5034') OR (EventCode='5035') OR (EventCode='5037') OR (EventCode='5058') OR (EventCode='5059') OR (EventCode='6400') OR (EventCode='6401') OR (EventCode='6402') OR (EventCode='6403') OR (EventCode='6404') OR (EventCode='6405') OR (EventCode='6406') OR (EventCode='6407') OR (EventCode='6408') OR (EventCode='6409'))" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\Other System Events.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "PNP Activity" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND ((EventCode='6416') OR (EventCode='6419') OR (EventCode='6420') OR (EventCode='6421') OR (EventCode='6422') OR (EventCode='6423') OR (EventCode='6424'))" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\PNP Activity.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "Process Creation and Termination" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND ((EventCode='4688') OR (EventCode='4696') OR (EventCode='4689'))" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\Process Creation and Termination.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "Registry" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND ((EventCode='4663') OR (EventCode='4656') OR (EventCode='4658') OR (EventCode='4660') OR (EventCode='4657') OR (EventCode='5039') OR (EventCode='4670'))" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\Registry.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "Removeable Storage" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND ((EventCode='4656') OR (EventCode='4658') OR (EventCode='4663'))" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\Removeable Storage.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "RPC Events" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND (EventCode='5712')" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\RPC Events.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "SAM" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND (EventCode='4661')" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\SAM.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "Security Event Logs Group Management" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND ((EventCode='4731') OR (EventCode='4732') OR (EventCode='4733') OR (EventCode='4734') OR (EventCode='4735') OR (EventCode='4764') OR (EventCode='4799') OR (EventCode='4727') OR (EventCode='4737') OR (EventCode='4728') OR (EventCode='4729') OR (EventCode='4730') OR (EventCode='4754') OR (EventCode='4755') OR (EventCode='4756') OR (EventCode='4757') OR (EventCode='4758'))" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\Security Group Management.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "Security State Change" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND ((EventCode='4608') OR (EventCode='4609') OR (EventCode='4616') OR (EventCode='4621'))" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\Security State Change.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "Security System Extension" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND ((EventCode='4610') OR (EventCode='4611') OR (EventCode='4614') OR (EventCode='4622') OR (EventCode='4697'))" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\Security System Extension.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "Sensitive and Non-Sensitive Privilege Use" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND ((EventCode='4673') OR (EventCode='4674') OR (EventCode='4985'))" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\Sensitive and NonSensitive Privilege Use.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "Special Logon" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND ((EventCode='4964') OR (EventCode='4672'))" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\Special Logon.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "System Integrity" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND ((EventCode='4612') OR (EventCode='4615') OR (EventCode='4616') OR (EventCode='5038') OR (EventCode='5056') OR (EventCode='5062') OR (EventCode='5057') OR (EventCode='5060') OR (EventCode='5061') OR (EventCode='6281') OR (EventCode='6410'))" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\System Integrity.txt" -Force
    $script:EventLogQueries += $EventLogQuery

    $EventLogQuery = New-Object PSObject -Property @{ Name = "User and Device Claims" }
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Filter -Value "(logfile='Security') AND (EventCode='4626')" -Force 
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message -Value "_____" -Force
    $EventLogQuery | Add-Member -MemberType NoteProperty -Name FilePath -Value "$CommandsEventLogsDirectory\By Topic\User and Device Claims.txt" -Force
    $script:EventLogQueries += $EventLogQuery

#---------------------------------------------
# Event Logs - Event IDs Quick Pick CheckBox
#---------------------------------------------
$EventLogsQuickPickSelectionCheckbox          = New-Object System.Windows.Forms.CheckBox
$EventLogsQuickPickSelectionCheckbox.Name     = "Event IDs Quick Selection  *"
$EventLogsQuickPickSelectionCheckbox.Text     = "$($EventLogsQuickPickSelectionCheckbox.Name)"
if (Test-Path -Path $EventLogsWindowITProCenter) { $EventLogsQuickPickSelectionCheckbox.Location = New-Object System.Drawing.Size(5,($EventLogsEventIDsIndividualSelectionChecklistbox.Location.Y + $EventLogsEventIDsIndividualSelectionChecklistbox.Size.Height + 7)) }
else { $EventLogsQuickPickSelectionCheckbox.Location = New-Object System.Drawing.Size(5,($EventLogsEventIDsManualEntryTextbox.Location.Y + $EventLogsEventIDsManualEntryTextbox.Size.Height + 7)) }
$EventLogsQuickPickSelectionCheckbox.Size     = New-Object System.Drawing.Size(350,$EventLogsBoxHeight) 
$Section1EventLogsTab.Controls.Add($EventLogsQuickPickSelectionCheckbox)

#-----------------------------------------------------------
# Event Logs - Event IDs Quick Pick Selection Clear Button
#-----------------------------------------------------------
$EventLogsQuickPickSelectionClearButton          = New-Object System.Windows.Forms.Button
$EventLogsQuickPickSelectionClearButton.Text     = "Clear"
$EventLogsQuickPickSelectionClearButton.Location = New-Object System.Drawing.Size(356,($EventLogsEventIDsIndividualSelectionChecklistbox.Location.Y + $EventLogsEventIDsIndividualSelectionChecklistbox.Size.Height + 7))
$EventLogsQuickPickSelectionClearButton.Size     = New-Object System.Drawing.Size(75,20)
$EventLogsQuickPickSelectionClearButton.Add_Click({
    # Clears the commands selected
    For ($i=0;$i -lt $EventLogsQuickPickSelectionCheckedlistbox.Items.count;$i++) {
        $EventLogsQuickPickSelectionCheckedlistbox.SetSelected($i,$False)
        $EventLogsQuickPickSelectionCheckedlistbox.SetItemChecked($i,$False)
        $EventLogsQuickPickSelectionCheckedlistbox.SetItemCheckState($i,$False)
    }
})
$Section1EventLogsTab.Controls.Add($EventLogsQuickPickSelectionClearButton) 

#------------------------------------------
# Event Logs - Event IDs Quick Pick Label
#------------------------------------------
$EventLogsQuickPickSelectionLabel           = New-Object System.Windows.Forms.Label
$EventLogsQuickPickSelectionLabel.Location  = New-Object System.Drawing.Point(5,($EventLogsQuickPickSelectionCheckbox.Location.Y + $EventLogsQuickPickSelectionCheckbox.Size.Height))
$EventLogsQuickPickSelectionLabel.Size      = New-Object System.Drawing.Size($EventLogsBoxWidth,$EventLogsBoxHeight) 
$EventLogsQuickPickSelectionLabel.Text      = "Event IDs by Topic - Can Select Multiple"
$EventLogsQuickPickSelectionLabel.Font      = New-Object System.Drawing.Font("$Font",9,0,3,0)
$EventLogsQuickPickSelectionLabel.ForeColor = "Black"
$Section1EventLogsTab.Controls.Add($EventLogsQuickPickSelectionLabel)

#-------------------------------------------------
# Event Logs - Event IDs Quick Pick Checklistbox
#-------------------------------------------------
$EventLogsQuickPickSelectionCheckedlistbox          = New-Object -TypeName System.Windows.Forms.CheckedListBox
$EventLogsQuickPickSelectionCheckedlistbox.Name     = "Event Logs Selection"
$EventLogsQuickPickSelectionCheckedlistbox.Text     = "$($EventLogsQuickPickSelectionCheckedlistbox.Name)"
$EventLogsQuickPickSelectionCheckedlistbox.Location = New-Object System.Drawing.Size(5,($EventLogsQuickPickSelectionLabel.Location.Y + $EventLogsQuickPickSelectionLabel.Size.Height)) 
$EventLogsQuickPickSelectionCheckedlistbox.Size     = New-Object System.Drawing.Size(425,125)
$EventLogsQuickPickSelectionCheckedlistbox.Font     = New-Object System.Drawing.Font("$Font",9,0,3,0)
#$EventLogsQuickPickSelectionCheckedlistbox.checked  = $true
#$EventLogsQuickPickSelectionCheckedlistbox.CheckOnClick = $true #so we only have to click once to check a box
#$EventLogsQuickPickSelectionCheckedlistbox.SelectionMode = One #This will only allow one options at a time
$EventLogsQuickPickSelectionCheckedlistbox.ScrollAlwaysVisible = $true
    # Adds a checkbox for each query
    foreach ( $Query in $script:EventLogQueries ) {
        $EventLogsQuickPickSelectionCheckedlistbox.Items.Add("$($Query.Name)")
    }
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
# Event Logs - Main Function - EventLogQuery
#============================================================================================================================================================
function EventLogQuery {
    param($CollectionName,$Filter)
    $CollectionName = $CollectionName
    Conduct-PreCommandExecution $CollectedDataTimeStampDirectory $IndividualHostResults $CollectionName

    foreach ($TargetComputer in $ComputerList) {
        Conduct-PreCommandCheck $CollectedDataTimeStampDirectory $IndividualHostResults $CollectionName $TargetComputer
        Create-LogEntry -TargetComputer $TargetComputer -LogFile $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$script:Credential) { $script:Credential = Get-Credential }
            Start-Job -Name "PoSh-ACME:  $CollectionName-$TargetComputer" -ScriptBlock {
                param($CollectedDataTimeStampDirectory,$IndividualHostResults,$CollectionName,$TargetComputer,$SleepTime,$LimitNumberOfEventLogsCollectToChoice,$Filter,$script:Credential)
                Invoke-Expression -Command $ThreadPriority
                
                Get-WmiObject -Credential $script:Credential -Class Win32_NTLogEvent -ComputerName $TargetComputer -Filter $Filter `
                | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type `
                | Select-Object -first $LimitNumberOfEventLogsCollectToChoice `
                | Export-CSV "$IndividualHostResults\$CollectionName\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($CollectedDataTimeStampDirectory,$IndividualHostResults,$CollectionName,$TargetComputer,$SleepTime,$LimitNumberOfEventLogsCollectToChoice,$Filter,$script:Credential)
        }
        else {
            Start-Job -Name "PoSh-ACME:  $CollectionName-$TargetComputer" -ScriptBlock {
                param($CollectedDataTimeStampDirectory,$IndividualHostResults,$CollectionName,$TargetComputer,$SleepTime,$LimitNumberOfEventLogsCollectToChoice,$Filter)
                Invoke-Expression -Command $ThreadPriority
                          
                Get-WmiObject -Class Win32_NTLogEvent -ComputerName $TargetComputer -Filter $Filter `
                | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type `
                | Select-Object -first $LimitNumberOfEventLogsCollectToChoice `
                | Export-CSV "$IndividualHostResults\$CollectionName\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($CollectedDataTimeStampDirectory,$IndividualHostResults,$CollectionName,$TargetComputer,$SleepTime,$LimitNumberOfEventLogsCollectToChoice,$Filter)
        }   
    }
    Monitor-Jobs -CollectionName $CollectionName
    Conduct-PostCommandExecution $CollectionName
    Compile-CsvFiles "$IndividualHostResults\$CollectionName" "$CollectedDataTimeStampDirectory\$CollectionName.csv"
}

#============================================================================================================================================================
# Event Logs - Funtions / Commands
#============================================================================================================================================================
function EventLogsEventCodeManualEntryCommand {
    $CollectionName = "Event Logs - Event IDs Manual Entry"

    $ManualEntry = $EventLogsEventIDsManualEntryTextbox.Text -split "`r`n"
    $ManualEntry = $ManualEntry -replace " ","" -replace "a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z",""
    $ManualEntry = $ManualEntry | ? {$_.trim() -ne ""}

    # Variables begins with an open "(
    $EventLogsEventIDsManualEntryTextboxFilter = '('

    foreach ($EventCode in $ManualEntry) {
        $EventLogsEventIDsManualEntryTextboxFilter += "(EventCode='$EventCode') OR "
    }
    # Replaces the ' OR ' at the end of the varable with a closing )"
    $Filter = $EventLogsEventIDsManualEntryTextboxFilter -replace " OR $",")"
    EventLogQuery -CollectionName $CollectionName -Filter $Filter
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
    EventLogQuery -CollectionName $CollectionName -Filter $Filter
}


##############################################################################################################################################################
##
## File Search
##
##############################################################################################################################################################

# Varables
$FileSearchRightPosition     = 3
$FileSearchDownPosition      = -10
$FileSearchDownPositionShift = 25
$FileSearchLabelWidth        = 450
$FileSearchLabelHeight       = 22
$FileSearchButtonWidth       = 110
$FileSearchButtonHeight      = 22

$Section1FileSearchTab          = New-Object System.Windows.Forms.TabPage
$Section1FileSearchTab.Location = $System_Drawing_Point
$Section1FileSearchTab.Text     = "File Search"
$Section1FileSearchTab.Location = New-Object System.Drawing.Size($FileSearchRightPosition,$FileSearchDownPosition) 
$Section1FileSearchTab.Size     = New-Object System.Drawing.Size($FileSearchLabelWidth,$FileSearchLabelHeight) 
$Section1FileSearchTab.UseVisualStyleBackColor = $True
$Section1CollectionsTabControl.Controls.Add($Section1FileSearchTab)

# Shift the fields
$FileSearchDownPosition += $FileSearchDownPositionShift

#============================================================================================================================================================
# File Search - Directory Listing
#============================================================================================================================================================

#---------------------------------------------------------
# File Search - Directory Listing CheckBox Command
#---------------------------------------------------------

$FileSearchDirectoryListingCheckbox = New-Object System.Windows.Forms.CheckBox
$FileSearchDirectoryListingCheckbox.Name = "Directory Listing (WinRM)"
$ListDirectory = $FileSearchDirectoryListingTextbox.Text

function FileSearchDirectoryListingCommand {
    $CollectionName = "Directory Listing"
#    Conduct-PreCommandExecution -CollectedDataTimeStampDirectory $CollectedDataTimeStampDirectory -IndividualHostResults $IndividualHostResults -CollectionName $CollectionName

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
        Create-LogEntry -TargetComputer $TargetComputer `
                        -LogFile $LogFile

        New-Item -ItemType Directory -Path "$($IndividualHostResults)\$($CollectionName)" -Force -ErrorAction SilentlyContinue

        $DirectoryPath = $FileSearchDirectoryListingTextbox.Text
        $MaximumDepth  = $FileSearchDirectoryListingMaxDepthTextbox.text

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$script:Credential) { $script:Credential = Get-Credential }
            Start-Job -Name "PoSh-ACME:  $($CollectionName)-$($TargetComputer)" -ScriptBlock {
                param($TargetComputer, $DirectoryPath, $MaximumDepth, $IndividualHostResults, $CollectionName, $script:Credential)
                [System.Threading.Thread]::CurrentThread.Priority = 'High'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'High'

                $FilesFoundList = @()

                $FilesFound = Invoke-Command -ComputerName $TargetComputer -Credential $script:Credential -ScriptBlock {
                    param($DirectoryPath, $MaximumDepth, $TargetComputer)

                    Function Get-ChildItemRecurse {
                        Param(
                            [String]$Path = $PWD,
                            [String]$Filter = "*",
                            [Byte]$Depth = $MaxDepth
                        )
                        $CurrentDepth++
                        $RecursiveListing = New-Object PSObject
                        Get-ChildItem $Path -Filter $Filter -Force | Foreach { 
                            $RecursiveListing | Add-Member -MemberType NoteProperty -Name PSComputerName -Value $TargetComputer -Force
                            #$RecursiveListing | Add-Member -MemberType NoteProperty -Name DirectoryName -Value $_.DirectoryName -Force
                            $RecursiveListing | Add-Member -MemberType NoteProperty -Name Directory -Value $_.Directory -Force
                            $RecursiveListing | Add-Member -MemberType NoteProperty -Name Name -Value $_.Name -Force
                            $RecursiveListing | Add-Member -MemberType NoteProperty -Name BaseName -Value $_.BaseName -Force
                            $RecursiveListing | Add-Member -MemberType NoteProperty -Name Extension -Value $_.Extension -Force
                            $RecursiveListing | Add-Member -MemberType NoteProperty -Name Attributes -Value $_.Attributes -Force
                            $RecursiveListing | Add-Member -MemberType NoteProperty -Name CreationTime -Value $_.CreationTime -Force
                            $RecursiveListing | Add-Member -MemberType NoteProperty -Name LastWriteTime -Value $_.LastWriteTime -Force
                            $RecursiveListing | Add-Member -MemberType NoteProperty -Name LastAccessTime -Value $_.LastAccessTime -Force
                            $RecursiveListing | Add-Member -MemberType NoteProperty -Name FullName -Value $_.FullName -Force
                            $RecursiveListing | Add-Member -MemberType NoteProperty -Name PSIsContainer -Value $_.PSIsContainer -Force
                                    
                            If ($_.PsIsContainer) {
                                If ($CurrentDepth -le $Depth) {                
                                    # Callback to this function
                                    Get-ChildItemRecurse -Path $_.FullName -Filter $Filter -Depth $MaxDepth -CurrentDepth $CurrentDepth
                                }
                            }
                            return $RecursiveListing
                        }
                    }
                $MaxDepth = $MaximumDepth
                $Path = $DirectoryPath
                        
                Get-ChildItemRecurse -Path $Path -Depth $MaxDepth | Where-Object { $_.PSIsContainer -eq $false }

                } -ArgumentList @($DirectoryPath, $MaximumDepth, $TargetComputer)
                        
                $FilesFoundList += $FilesFound | Select-Object -Property PSComputerName, Directory, Name, BaseName, Extension, Attributes, CreationTime, LastWriteTime, LastAccessTime, FullName
                
                $FilesFoundList | Export-CSV "$($IndividualHostResults)\$($CollectionName)\$($CollectionName)-$($TargetComputer).csv" -NoTypeInformation
            } -ArgumentList @($TargetComputer, $DirectoryPath, $MaximumDepth, $IndividualHostResults, $CollectionName, $script:Credential)
        }
        else {
            Start-Job -Name "PoSh-ACME:  $($CollectionName)-$($TargetComputer)" -ScriptBlock {
                param($TargetComputer, $DirectoryPath, $MaximumDepth, $IndividualHostResults, $CollectionName)
                [System.Threading.Thread]::CurrentThread.Priority = 'High'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'High'

                $FilesFoundList = @()

                $FilesFound = Invoke-Command -ComputerName $TargetComputer -ScriptBlock {
                    param($DirectoryPath, $MaximumDepth, $TargetComputer)

                    Function Get-ChildItemRecurse {
                        Param(
                            [String]$Path = $PWD,
                            [String]$Filter = "*",
                            [Byte]$Depth = $MaxDepth
                        )
                        $CurrentDepth++
                        $RecursiveListing = New-Object PSObject
                        Get-ChildItem $Path -Filter $Filter -Force | Foreach { 
                            $RecursiveListing | Add-Member -MemberType NoteProperty -Name PSComputerName -Value $TargetComputer -Force
                            #$RecursiveListing | Add-Member -MemberType NoteProperty -Name DirectoryName -Value $_.DirectoryName -Force
                            $RecursiveListing | Add-Member -MemberType NoteProperty -Name Directory -Value $_.Directory -Force
                            $RecursiveListing | Add-Member -MemberType NoteProperty -Name Name -Value $_.Name -Force
                            $RecursiveListing | Add-Member -MemberType NoteProperty -Name BaseName -Value $_.BaseName -Force
                            $RecursiveListing | Add-Member -MemberType NoteProperty -Name Extension -Value $_.Extension -Force
                            $RecursiveListing | Add-Member -MemberType NoteProperty -Name Attributes -Value $_.Attributes -Force
                            $RecursiveListing | Add-Member -MemberType NoteProperty -Name CreationTime -Value $_.CreationTime -Force
                            $RecursiveListing | Add-Member -MemberType NoteProperty -Name LastWriteTime -Value $_.LastWriteTime -Force
                            $RecursiveListing | Add-Member -MemberType NoteProperty -Name LastAccessTime -Value $_.LastAccessTime -Force
                            $RecursiveListing | Add-Member -MemberType NoteProperty -Name FullName -Value $_.FullName -Force
                            $RecursiveListing | Add-Member -MemberType NoteProperty -Name PSIsContainer -Value $_.PSIsContainer -Force
                                    
                            If ($_.PsIsContainer) {
                                If ($CurrentDepth -le $Depth) {                
                                    # Callback to this function
                                    Get-ChildItemRecurse -Path $_.FullName -Filter $Filter -Depth $MaxDepth -CurrentDepth $CurrentDepth
                                }
                            }
                            return $RecursiveListing
                        }
                    }
                $MaxDepth = $MaximumDepth
                $Path = $DirectoryPath
                        
                Get-ChildItemRecurse -Path $Path -Depth $MaxDepth | Where-Object { $_.PSIsContainer -eq $false }

                } -ArgumentList @($DirectoryPath, $MaximumDepth, $TargetComputer)
                        
                $FilesFoundList += $FilesFound | Select-Object -Property PSComputerName, Directory, Name, BaseName, Extension, Attributes, CreationTime, LastWriteTime, LastAccessTime, FullName
                
                $FilesFoundList | Export-CSV "$($IndividualHostResults)\$($CollectionName)\$($CollectionName)-$($TargetComputer).csv" -NoTypeInformation
            } -ArgumentList @($TargetComputer, $DirectoryPath, $MaximumDepth, $IndividualHostResults, $CollectionName)
        }
    }
    Monitor-Jobs -CollectionName $CollectionName
    Conduct-PostCommandExecution -CollectionName $CollectionName
    Compile-CsvFiles -LocationOfCSVsToCompile   "$($IndividualHostResults)\$($CollectionName)\$($CollectionName)*.csv" `
                     -LocationToSaveCompiledCSV "$($CollectedDataTimeStampDirectory)\$($CollectionName).csv"
    #not needed# Remove-DuplicateCsvHeaders
}
$FileSearchDirectoryListingCheckbox.Text     = "$($FileSearchDirectoryListingCheckbox.Name)"
$FileSearchDirectoryListingCheckbox.Location = New-Object System.Drawing.Size(($FileSearchRightPosition),($FileSearchDownPosition))
$FileSearchDirectoryListingCheckbox.Size     = New-Object System.Drawing.Size((230),$FileSearchLabelHeight) 
$Section1FileSearchTab.Controls.Add($FileSearchDirectoryListingCheckbox)

#--------------------------------------------------
# File Search - Directory Listing Max Depth Label
#--------------------------------------------------
$FileSearchDirectoryListingMaxDepthLabel            = New-Object System.Windows.Forms.Label
$FileSearchDirectoryListingMaxDepthLabel.Location   = New-Object System.Drawing.Point(($FileSearchDirectoryListingCheckbox.Size.Width + 52),($FileSearchDownPosition + 3)) 
$FileSearchDirectoryListingMaxDepthLabel.Size       = New-Object System.Drawing.Size(100,$FileSearchLabelHeight) 
$FileSearchDirectoryListingMaxDepthLabel.Text       = "Recursive Depth"
#$FileSearchDirectoryListingMaxDepthLabel.Font      = New-Object System.Drawing.Font("$Font",12,1,3,1)
#$FileSearchDirectoryListingMaxDepthLabel.ForeColor  = "Blue"
$Section1FileSearchTab.Controls.Add($FileSearchDirectoryListingMaxDepthLabel)

#----------------------------------------------------
# File Search - Directory Listing Max Depth Textbox
#----------------------------------------------------
$FileSearchDirectoryListingMaxDepthTextbox                = New-Object System.Windows.Forms.TextBox
$FileSearchDirectoryListingMaxDepthTextbox.Location       = New-Object System.Drawing.Size(($FileSearchDirectoryListingMaxDepthLabel.Location.X + $FileSearchDirectoryListingMaxDepthLabel.Size.Width),($FileSearchDownPosition)) 
$FileSearchDirectoryListingMaxDepthTextbox.Size           = New-Object System.Drawing.Size(50,20)
$FileSearchDirectoryListingMaxDepthTextbox.MultiLine      = $false
#$FileSearchDirectoryListingMaxDepthTextbox.ScrollBars    = "Vertical"
$FileSearchDirectoryListingMaxDepthTextbox.WordWrap       = false
#$FileSearchDirectoryListingMaxDepthTextbox.AcceptsTab    = false
#$FileSearchDirectoryListingMaxDepthTextbox.AcceptsReturn = false
$FileSearchDirectoryListingMaxDepthTextbox.Font           = New-Object System.Drawing.Font("$Font",9,0,3,1)
$FileSearchDirectoryListingMaxDepthTextbox.Text           = 0
#$FileSearchDirectoryListingMaxDepthTextbox.Add_KeyDown({          })
$Section1FileSearchTab.Controls.Add($FileSearchDirectoryListingMaxDepthTextbox)

# Shift the fields
$FileSearchDownPosition += $FileSearchDownPositionShift

#----------------------------------------------
# File Search - Directory Listing Label
#----------------------------------------------
$FileSearchDirectoryListingLabel           = New-Object System.Windows.Forms.Label
$FileSearchDirectoryListingLabel.Location  = New-Object System.Drawing.Point($FileSearchRightPosition,$FileSearchDownPosition) 
$FileSearchDirectoryListingLabel.Size      = New-Object System.Drawing.Size($FileSearchLabelWidth,$FileSearchLabelHeight) 
$FileSearchDirectoryListingLabel.Text      = "Collection time is dependant on the directory's contents."
#$FileSearchDirectoryListingLabel.Font      = New-Object System.Drawing.Font("$Font",12,1,3,1)
$FileSearchDirectoryListingLabel.ForeColor = "Blue"
$Section1FileSearchTab.Controls.Add($FileSearchDirectoryListingLabel)

# Shift the fields
$FileSearchDownPosition += $FileSearchDownPositionShift

#----------------------------------------------------
# File Search - Directory Listing Directory Textbox
#----------------------------------------------------
$FileSearchDirectoryListingTextbox               = New-Object System.Windows.Forms.TextBox
$FileSearchDirectoryListingTextbox.Location      = New-Object System.Drawing.Size($FileSearchRightPosition,($FileSearchDownPosition)) 
$FileSearchDirectoryListingTextbox.Size          = New-Object System.Drawing.Size(430,22)
$FileSearchDirectoryListingTextbox.MultiLine     = $False
#$FileSearchDirectoryListingTextbox.ScrollBars    = "Vertical"
$FileSearchDirectoryListingTextbox.WordWrap      = True
$FileSearchDirectoryListingTextbox.AcceptsTab    = false # Allows you to enter in tabs into the textbox
$FileSearchDirectoryListingTextbox.AcceptsReturn = false # Allows you to enter in tabs into the textbox
$FileSearchDirectoryListingTextbox.Text          = "C:\Windows\System32"
#$FileSearchDirectoryListingTextbox.Add_KeyDown({          })
$Section1FileSearchTab.Controls.Add($FileSearchDirectoryListingTextbox)

# Shift the fields
$FileSearchDownPosition += $FileSearchDownPositionShift + $FileSearchDirectoryListingTextbox.Size.Height

#============================================================================================================================================================
# File Search - File Search
#============================================================================================================================================================

#---------------------------------------------------
# File Search - File Search Command CheckBox
#---------------------------------------------------

$FileSearchFileSearchCheckbox = New-Object System.Windows.Forms.CheckBox
$FileSearchFileSearchCheckbox.Name = "File Search (WinRM)"

function FileSearchFileSearchCommand {
    $CollectionName = "File Search"
#    Conduct-PreCommandExecution -CollectedDataTimeStampDirectory $CollectedDataTimeStampDirectory -IndividualHostResults $IndividualHostResults -CollectionName $CollectionName

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
        Create-LogEntry -TargetComputer $TargetComputer `
                        -LogFile $LogFile

        New-Item -ItemType Directory -Path "$($IndividualHostResults)\$($CollectionName)" -Force -ErrorAction SilentlyContinue

        $DirectoriesToSearch = $FileSearchFileSearchDirectoryTextbox.Text -split "`r`n"
        $FilesToSearch       = $FileSearchFileSearchFileTextbox.Text -split "`r`n"
        $MaximumDepth        = $FileSearchFileSearchMaxDepthTextbox.text

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$script:Credential) { $script:Credential = Get-Credential }
            Start-Job -Name "PoSh-ACME:  $($CollectionName)-$($TargetComputer)" -ScriptBlock {
                param($DirectoriesToSearch, $FilesToSearch, $TargetComputer, $DirectoryPath, $Filename, $MaximumDepth, $IndividualHostResults, $CollectionName, $script:Credential)
                [System.Threading.Thread]::CurrentThread.Priority = 'High'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'High'

                $FilesFoundList = @()

                foreach ($DirectoryPath in $DirectoriesToSearch) {
                    foreach ($Filename in $FilesToSearch) {
                        $FilesFound = Invoke-Command -ComputerName $TargetComputer -Credential $script:Credential -ScriptBlock {
                            param($DirectoryPath, $Filename, $MaximumDepth, $TargetComputer)

                            Function Get-ChildItemRecurse {
                                Param(
                                    [String]$Path = $PWD,
                                    [String]$Filter = "*",
                                    [Byte]$Depth = $MaxDepth
                                )
                                $CurrentDepth++
                                $RecursiveListing = New-Object PSObject
                                Get-ChildItem $Path -Filter $Filter -Force | Foreach { 
                                    $RecursiveListing | Add-Member -MemberType NoteProperty -Name PSComputerName -Value $TargetComputer -Force
                                    #$RecursiveListing | Add-Member -MemberType NoteProperty -Name DirectoryName -Value $_.DirectoryName -Force
                                    $RecursiveListing | Add-Member -MemberType NoteProperty -Name Directory -Value $_.Directory -Force
                                    $RecursiveListing | Add-Member -MemberType NoteProperty -Name Name -Value $_.Name -Force
                                    $RecursiveListing | Add-Member -MemberType NoteProperty -Name BaseName -Value $_.BaseName -Force
                                    $RecursiveListing | Add-Member -MemberType NoteProperty -Name Extension -Value $_.Extension -Force
                                    $RecursiveListing | Add-Member -MemberType NoteProperty -Name Attributes -Value $_.Attributes -Force
                                    $RecursiveListing | Add-Member -MemberType NoteProperty -Name CreationTime -Value $_.CreationTime -Force
                                    $RecursiveListing | Add-Member -MemberType NoteProperty -Name LastWriteTime -Value $_.LastWriteTime -Force
                                    $RecursiveListing | Add-Member -MemberType NoteProperty -Name LastAccessTime -Value $_.LastAccessTime -Force
                                    $RecursiveListing | Add-Member -MemberType NoteProperty -Name FullName -Value $_.FullName -Force
                                    $RecursiveListing | Add-Member -MemberType NoteProperty -Name PSIsContainer -Value $_.PSIsContainer -Force
                                    
                                    If ($_.PsIsContainer) {
                                        If ($CurrentDepth -le $Depth) {                
                                            # Callback to this function
                                            Get-ChildItemRecurse -Path $_.FullName -Filter $Filter -Depth $MaxDepth -CurrentDepth $CurrentDepth
                                        }
                                    }
                                    return $RecursiveListing
                                }
                            }
                        $MaxDepth = $MaximumDepth
                        $Path = $DirectoryPath
                        
                        Get-ChildItemRecurse -Path $Path -Depth $MaxDepth | Where-Object { ($_.PSIsContainer -eq $false) -and ($_.Name -match "$Filename") }

                        } -ArgumentList @($DirectoryPath, $Filename, $MaximumDepth, $TargetComputer)
                        
                        $FilesFoundList += $FilesFound | Select-Object -Property PSComputerName, Directory, Name, BaseName, Extension, Attributes, CreationTime, LastWriteTime, LastAccessTime, FullName
                    }
                }
                $FilesFoundList | Export-CSV "$($IndividualHostResults)\$($CollectionName)\$($CollectionName)-$($TargetComputer).csv" -NoTypeInformation
            } -ArgumentList @($DirectoriesToSearch, $FilesToSearch, $TargetComputer, $DirectoryPath, $Filename, $MaximumDepth, $IndividualHostResults, $CollectionName, $script:Credential)
        }
        else {
            Start-Job -Name "PoSh-ACME:  $($CollectionName)-$($TargetComputer)" -ScriptBlock {
                param($DirectoriesToSearch, $FilesToSearch, $TargetComputer, $DirectoryPath, $Filename, $MaximumDepth, $IndividualHostResults, $CollectionName)
                [System.Threading.Thread]::CurrentThread.Priority = 'High'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'High'

                $FilesFoundList = @()
#Batman

                foreach ($DirectoryPath in $DirectoriesToSearch) {
                    foreach ($Filename in $FilesToSearch) {
                        $FilesFound = Invoke-Command -ComputerName $TargetComputer -ScriptBlock {
                            param($DirectoryPath, $Filename, $MaximumDepth, $TargetComputer)

                            Function Get-ChildItemRecurse {
                                Param(
                                    [String]$Path = $PWD,
                                    [String]$Filter = "*",
                                    [Byte]$Depth = $MaxDepth
                                )
                                $CurrentDepth++
                                $RecursiveListing = New-Object PSObject
                                Get-ChildItem $Path -Filter $Filter -Force | Foreach { 
                                    $RecursiveListing | Add-Member -MemberType NoteProperty -Name PSComputerName -Value $TargetComputer -Force
                                    #$RecursiveListing | Add-Member -MemberType NoteProperty -Name DirectoryName -Value $_.DirectoryName -Force
                                    $RecursiveListing | Add-Member -MemberType NoteProperty -Name Directory -Value $_.Directory -Force
                                    $RecursiveListing | Add-Member -MemberType NoteProperty -Name Name -Value $_.Name -Force
                                    $RecursiveListing | Add-Member -MemberType NoteProperty -Name BaseName -Value $_.BaseName -Force
                                    $RecursiveListing | Add-Member -MemberType NoteProperty -Name Extension -Value $_.Extension -Force
                                    $RecursiveListing | Add-Member -MemberType NoteProperty -Name Attributes -Value $_.Attributes -Force
                                    $RecursiveListing | Add-Member -MemberType NoteProperty -Name CreationTime -Value $_.CreationTime -Force
                                    $RecursiveListing | Add-Member -MemberType NoteProperty -Name LastWriteTime -Value $_.LastWriteTime -Force
                                    $RecursiveListing | Add-Member -MemberType NoteProperty -Name LastAccessTime -Value $_.LastAccessTime -Force
                                    $RecursiveListing | Add-Member -MemberType NoteProperty -Name FullName -Value $_.FullName -Force
                                    $RecursiveListing | Add-Member -MemberType NoteProperty -Name PSIsContainer -Value $_.PSIsContainer -Force
                                    
                                    If ($_.PsIsContainer) {
                                        If ($CurrentDepth -le $Depth) {                
                                            # Callback to this function
                                            Get-ChildItemRecurse -Path $_.FullName -Filter $Filter -Depth $MaxDepth -CurrentDepth $CurrentDepth
                                        }
                                    }
                                    return $RecursiveListing
                                }
                            }
                        $MaxDepth = $MaximumDepth
                        $Path = $DirectoryPath
                        
                        Get-ChildItemRecurse -Path $Path -Depth $MaxDepth | Where-Object { ($_.PSIsContainer -eq $false) -and ($_.Name -match "$Filename") }

                        } -ArgumentList @($DirectoryPath, $Filename, $MaximumDepth, $TargetComputer)
                        
                        $FilesFoundList += $FilesFound | Select-Object -Property PSComputerName, Directory, Name, BaseName, Extension, Attributes, CreationTime, LastWriteTime, LastAccessTime, FullName
                    }
                }
                $FilesFoundList | Export-CSV "$($IndividualHostResults)\$($CollectionName)\$($CollectionName)-$($TargetComputer).csv" -NoTypeInformation
            } -ArgumentList @($DirectoriesToSearch, $FilesToSearch, $TargetComputer, $DirectoryPath, $Filename, $MaximumDepth, $IndividualHostResults, $CollectionName)
        } 
    }
    Monitor-Jobs -CollectionName $CollectionName
    Conduct-PostCommandExecution -CollectionName $CollectionName
    Compile-CsvFiles -LocationOfCSVsToCompile   "$($IndividualHostResults)\$($CollectionName)\$($CollectionName)*.csv" `
                     -LocationToSaveCompiledCSV "$($CollectedDataTimeStampDirectory)\$($CollectionName).csv"
    #not needed# Remove-DuplicateCsvHeaders
}
$FileSearchFileSearchCheckbox.Text     = "$($FileSearchFileSearchCheckbox.Name)"
$FileSearchFileSearchCheckbox.Location = New-Object System.Drawing.Size(($FileSearchRightPosition),($FileSearchDownPosition)) 
$FileSearchFileSearchCheckbox.Size     = New-Object System.Drawing.Size((230),$FileSearchLabelHeight) 
$Section1FileSearchTab.Controls.Add($FileSearchFileSearchCheckbox)

#--------------------------------------------------
# File Search - File Search Max Depth Label
#--------------------------------------------------
$FileSearchFileSearchMaxDepthLabel            = New-Object System.Windows.Forms.Label
$FileSearchFileSearchMaxDepthLabel.Location   = New-Object System.Drawing.Point(($FileSearchFileSearchCheckbox.Size.Width + 52),($FileSearchDownPosition + 3)) 
$FileSearchFileSearchMaxDepthLabel.Size       = New-Object System.Drawing.Size(100,$FileSearchLabelHeight) 
$FileSearchFileSearchMaxDepthLabel.Text       = "Recursive Depth"
#$FileSearchFileSearchMaxDepthLabel.Font      = New-Object System.Drawing.Font("$Font",12,1,3,1)
#$FileSearchFileSearchMaxDepthLabel.ForeColor  = "Blue"
$Section1FileSearchTab.Controls.Add($FileSearchFileSearchMaxDepthLabel)

#----------------------------------------------------
# File Search - File Search Max Depth Textbox
#----------------------------------------------------
$FileSearchFileSearchMaxDepthTextbox                = New-Object System.Windows.Forms.TextBox
$FileSearchFileSearchMaxDepthTextbox.Location       = New-Object System.Drawing.Size(($FileSearchFileSearchMaxDepthLabel.Location.X + $FileSearchFileSearchMaxDepthLabel.Size.Width),($FileSearchDownPosition)) 
$FileSearchFileSearchMaxDepthTextbox.Size           = New-Object System.Drawing.Size(50,20)
$FileSearchFileSearchMaxDepthTextbox.MultiLine      = $false
#$FileSearchFileSearchMaxDepthTextbox.ScrollBars    = "Vertical"
$FileSearchFileSearchMaxDepthTextbox.WordWrap       = false
#$FileSearchFileSearchMaxDepthTextbox.AcceptsTab    = false
#$FileSearchFileSearchMaxDepthTextbox.AcceptsReturn = false
$FileSearchFileSearchMaxDepthTextbox.Font           = New-Object System.Drawing.Font("$Font",9,0,3,1)
$FileSearchFileSearchMaxDepthTextbox.Text           = 0
#$FileSearchFileSearchMaxDepthTextbox.Add_KeyDown({          })
$Section1FileSearchTab.Controls.Add($FileSearchFileSearchMaxDepthTextbox)

# Shift the fields
$FileSearchDownPosition += $FileSearchDownPositionShift

#----------------------------------------
# File Search - File Search Label
#----------------------------------------
$FileSearchFileSearchLabel           = New-Object System.Windows.Forms.Label
$FileSearchFileSearchLabel.Location  = New-Object System.Drawing.Point($FileSearchRightPosition,$FileSearchDownPosition) 
$FileSearchFileSearchLabel.Size      = New-Object System.Drawing.Size($FileSearchLabelWidth,$FileSearchLabelHeight) 
$FileSearchFileSearchLabel.Text      = "Collection time depends on the number of files and directories, plus recursive depth."
#$FileSearchFileSearchLabel.Font      = New-Object System.Drawing.Font("$Font",12,1,3,1)
$FileSearchFileSearchLabel.ForeColor = "Blue"
$Section1FileSearchTab.Controls.Add($FileSearchFileSearchLabel)

# Shift the fields
$FileSearchDownPosition += $FileSearchDownPositionShift - 3

#------------------------------------------------
# File Search - File Search Files Textbox
#------------------------------------------------
$FileSearchFileSearchFileTextbox               = New-Object System.Windows.Forms.TextBox
$FileSearchFileSearchFileTextbox.Location      = New-Object System.Drawing.Size($FileSearchRightPosition,($FileSearchDownPosition)) 
$FileSearchFileSearchFileTextbox.Size          = New-Object System.Drawing.Size(430,(80))
$FileSearchFileSearchFileTextbox.MultiLine     = $True
$FileSearchFileSearchFileTextbox.ScrollBars    = "Vertical"
$FileSearchFileSearchFileTextbox.WordWrap      = True
$FileSearchFileSearchFileTextbox.AcceptsTab    = false    # Allows you to enter in tabs into the textbox
$FileSearchFileSearchFileTextbox.AcceptsReturn = false # Allows you to enter in tabs into the textbox
$FileSearchFileSearchFileTextbox.Font          = New-Object System.Drawing.Font("$Font",9,0,3,1)
$FileSearchFileSearchFileTextbox.Text          = "Enter FileNames - One Per Line"
#$FileSearchFileSearchFileTextbox.Add_KeyDown({          })
$Section1FileSearchTab.Controls.Add($FileSearchFileSearchFileTextbox)

# Shift the fields
$FileSearchDownPosition += $FileSearchFileSearchFileTextbox.Size.Height + 5

#---------------------------------------------
# File Search - File Search Directory Textbox
#---------------------------------------------
$FileSearchFileSearchDirectoryTextbox               = New-Object System.Windows.Forms.TextBox
$FileSearchFileSearchDirectoryTextbox.Location      = New-Object System.Drawing.Size($FileSearchRightPosition,($FileSearchDownPosition)) 
$FileSearchFileSearchDirectoryTextbox.Size          = New-Object System.Drawing.Size(430,(80))
$FileSearchFileSearchDirectoryTextbox.MultiLine     = $True
$FileSearchFileSearchDirectoryTextbox.ScrollBars    = "Vertical"
$FileSearchFileSearchDirectoryTextbox.WordWrap      = True
$FileSearchFileSearchDirectoryTextbox.AcceptsTab    = false    # Allows you to enter in tabs into the textbox
$FileSearchFileSearchDirectoryTextbox.AcceptsReturn = false # Allows you to enter in tabs into the textbox
$FileSearchFileSearchDirectoryTextbox.Text          = "Enter Directories; One Per Line"
#$FileSearchFileSearchDirectoryTextbox.Add_KeyDown({          })
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
#    Conduct-PreCommandExecution -CollectedDataTimeStampDirectory $CollectedDataTimeStampDirectory -IndividualHostResults $IndividualHostResults -CollectionName $CollectionName

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
        Create-LogEntry -TargetComputer $TargetComputer `
                        -LogFile $LogFile

        New-Item -ItemType Directory -Path "$($IndividualHostResults)\$($CollectionName)" -Force -ErrorAction SilentlyContinue

        $DirectoriesToSearch = $FileSearchAlternateDataStreamDirectoryTextbox.Text -split "`r`n"
        $MaximumDepth        = $FileSearchAlternateDataStreamMaxDepthTextbox.text

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$script:Credential) { $script:Credential = Get-Credential }
        }
        else {
            Start-Job -Name "PoSh-ACME:  $($CollectionName)-$($TargetComputer)" -ScriptBlock {
                param($DirectoriesToSearch, $TargetComputer, $MaximumDepth, $IndividualHostResults, $CollectionName)
                [System.Threading.Thread]::CurrentThread.Priority = 'High'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'High'

                $FilesFoundList = @()

                foreach ($DirectoryPath in $DirectoriesToSearch) {
                    $FilesFound = Invoke-Command -ComputerName $TargetComputer -ScriptBlock {
                        param($DirectoryPath, $MaximumDepth, $TargetComputer)

                        Function Get-ChildItemRecurse {
                            Param(
                                [String]$Path = $PWD,
                                [String]$Filter = "*",
                                [Byte]$Depth = $MaxDepth
                            )
                            $CurrentDepth++
                            $RecursiveListing = New-Object PSObject
                            Get-ChildItem $Path -Filter $Filter -Force | Foreach { 
                                $RecursiveListing | Add-Member -MemberType NoteProperty -Name PSComputerName -Value $TargetComputer -Force
                                $RecursiveListing | Add-Member -MemberType NoteProperty -Name FullName -Value $_.FullName -Force

                                If ($_.PsIsContainer) {
                                    If ($CurrentDepth -le $Depth) {                
                                        # Callback to this function
                                        Get-ChildItemRecurse -Path $_.FullName -Filter $Filter -Depth $MaxDepth -CurrentDepth $CurrentDepth
                                    }
                                }
                                return $RecursiveListing
                            }
                        }
                        $MaxDepth = $MaximumDepth
                        $Path = $DirectoryPath
                        
                        Get-ChildItemRecurse -Path $Path -Depth $MaxDepth
                        
                    } -ArgumentList @($DirectoryPath, $MaximumDepth, $TargetComputer)
                    
                    $AdsFound = $FilesFound | ForEach-Object { Get-Item $_.FullName -Force -Stream * -ErrorAction SilentlyContinue } | Where-Object stream -ne ':$DATA'
                    
                    foreach ($Ads in $AdsFound) {
                        $AdsData = Get-Content -Path "$($Ads.FileName)" -Stream "$($Ads.Stream)"
                        $Ads | Add-Member -MemberType NoteProperty -Name PSComputerName -Value $TargetComputer
                        $Ads | Add-Member -MemberType NoteProperty -Name StreamData -Value $AdsData
                        if     (($Ads.Stream -eq 'Zone.Identifier') -and ($Ads.StreamData -match 'ZoneID=0')) { $Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "[ZoneID 0] Local Machine Zone: The most trusted zone for content that exists on the local computer." }
                        elseif (($Ads.Stream -eq 'Zone.Identifier') -and ($Ads.StreamData -match 'ZoneID=1')) { $Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "[ZoneID 1] Local Intranet Zone: For content located on an organization’s intranet." }
                        elseif (($Ads.Stream -eq 'Zone.Identifier') -and ($Ads.StreamData -match 'ZoneID=2')) { $Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "[ZoneID 2] Trusted Sites Zone: For content located on Web sites that are considered more reputable or trustworthy than other sites on the Internet." }
                        elseif (($Ads.Stream -eq 'Zone.Identifier') -and ($Ads.StreamData -match 'ZoneID=3')) { $Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "[ZoneID 3] Internet Zone: For Web sites on the Internet that do not belong to another zone." }
                        elseif (($Ads.Stream -eq 'Zone.Identifier') -and ($Ads.StreamData -match 'ZoneID=4')) { $Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "[ZoneID 4] Restricted Sites Zone: For Web sites that contain potentially-unsafe content." }
                        else {$Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "N/A"}                           
                    }                     
                }
                $AdsFound | Select-Object -Property PSComputerName, FileName, Stream, @{Name="StreamData";Expression={$_.StreamData}}, ZoneID, Length `
                | Export-CSV "$($IndividualHostResults)\$($CollectionName)\$($CollectionName)-$($TargetComputer).csv" -NoTypeInformation
            } -ArgumentList @($DirectoriesToSearch, $TargetComputer, $MaximumDepth, $IndividualHostResults, $CollectionName)
        } 
    }
    Monitor-Jobs -CollectionName $CollectionName
    Conduct-PostCommandExecution -CollectionName $CollectionName
    Compile-CsvFiles -LocationOfCSVsToCompile   "$($IndividualHostResults)\$($CollectionName)\$($CollectionName)*.csv" `
                     -LocationToSaveCompiledCSV "$($CollectedDataTimeStampDirectory)\$($CollectionName).csv"
    #not needed# Remove-DuplicateCsvHeaders
}

#--------------------------------------------------------
# File Search - File Search AlternateDataStream CheckBox
#--------------------------------------------------------
$FileSearchAlternateDataStreamCheckbox = New-Object System.Windows.Forms.CheckBox
$FileSearchAlternateDataStreamCheckbox.Name = "Search for Alternate Data Streams (WinRM)"
$FileSearchAlternateDataStreamCheckbox.Text     = "$($FileSearchAlternateDataStreamCheckbox.Name)"
$FileSearchAlternateDataStreamCheckbox.Location = New-Object System.Drawing.Size(($FileSearchRightPosition),($FileSearchDownPosition)) 
$FileSearchAlternateDataStreamCheckbox.Size     = New-Object System.Drawing.Size((250),$FileSearchLabelHeight) 
$Section1FileSearchTab.Controls.Add($FileSearchAlternateDataStreamCheckbox)

#-----------------------------------------------------
# File Search - Alternate Data Stream Max Depth Label
#-----------------------------------------------------
$FileSearchAlternateDataStreamMaxDepthLabel            = New-Object System.Windows.Forms.Label
$FileSearchAlternateDataStreamMaxDepthLabel.Location   = New-Object System.Drawing.Point(($FileSearchFileSearchCheckbox.Size.Width + 52),($FileSearchDownPosition + 3)) 
$FileSearchAlternateDataStreamMaxDepthLabel.Size       = New-Object System.Drawing.Size(100,$FileSearchLabelHeight) 
$FileSearchAlternateDataStreamMaxDepthLabel.Text       = "Recursive Depth"
#$FileSearchAlternateDataStreamMaxDepthLabel.Font      = New-Object System.Drawing.Font("$Font",12,1,3,1)
#$FileSearchAlternateDataStreamMaxDepthLabel.ForeColor  = "Blue"
$Section1FileSearchTab.Controls.Add($FileSearchAlternateDataStreamMaxDepthLabel)

#-------------------------------------------------------
# File Search - Alternate Data Stream Max Depth Textbox
#-------------------------------------------------------
$FileSearchAlternateDataStreamMaxDepthTextbox                = New-Object System.Windows.Forms.TextBox
$FileSearchAlternateDataStreamMaxDepthTextbox.Location       = New-Object System.Drawing.Size(($FileSearchAlternateDataStreamMaxDepthLabel.Location.X + $FileSearchAlternateDataStreamMaxDepthLabel.Size.Width),($FileSearchDownPosition)) 
$FileSearchAlternateDataStreamMaxDepthTextbox.Size           = New-Object System.Drawing.Size(50,20)
$FileSearchAlternateDataStreamMaxDepthTextbox.MultiLine      = $false
#$FileSearchAlternateDataStreamMaxDepthTextbox.ScrollBars    = "Vertical"
$FileSearchAlternateDataStreamMaxDepthTextbox.WordWrap       = false
#$FileSearchAlternateDataStreamMaxDepthTextbox.AcceptsTab    = false
#$FileSearchAlternateDataStreamMaxDepthTextbox.AcceptsReturn = false
$FileSearchAlternateDataStreamMaxDepthTextbox.Font           = New-Object System.Drawing.Font("$Font",9,0,3,1)
$FileSearchAlternateDataStreamMaxDepthTextbox.Text           = 0
#$FileSearchAlternateDataStreamMaxDepthTextbox.Add_KeyDown({          })
$Section1FileSearchTab.Controls.Add($FileSearchAlternateDataStreamMaxDepthTextbox)

# Shift the fields
$FileSearchDownPosition += $FileSearchAlternateDataStreamCheckbox.Size.Height + 5

#-------------------------------------------
# File Search - Alternate Data Stream Label
#-------------------------------------------
$FileSearchAlternateDataStreamLabel           = New-Object System.Windows.Forms.Label
$FileSearchAlternateDataStreamLabel.Location  = New-Object System.Drawing.Point($FileSearchRightPosition,$FileSearchDownPosition) 
$FileSearchAlternateDataStreamLabel.Size      = New-Object System.Drawing.Size($FileSearchLabelWidth,$FileSearchLabelHeight) 
$FileSearchAlternateDataStreamLabel.Text      = "Exlcudes':`$DATA' stream, and will show the ADS name and its contents."
#$FileSearchAlternateDataStreamLabel.Font      = New-Object System.Drawing.Font("$Font",12,1,3,1)
$FileSearchAlternateDataStreamLabel.ForeColor = "Blue"
$Section1FileSearchTab.Controls.Add($FileSearchAlternateDataStreamLabel)

# Shift the fields
$FileSearchDownPosition += $FileSearchDownPositionShift

#---------------------------------------------
# File Search - Alternate Data Stream Textbox
#---------------------------------------------
$FileSearchAlternateDataStreamDirectoryTextbox               = New-Object System.Windows.Forms.TextBox
$FileSearchAlternateDataStreamDirectoryTextbox.Location      = New-Object System.Drawing.Size($FileSearchRightPosition,($FileSearchDownPosition)) 
$FileSearchAlternateDataStreamDirectoryTextbox.Size          = New-Object System.Drawing.Size(430,(80))
$FileSearchAlternateDataStreamDirectoryTextbox.MultiLine     = $True
$FileSearchAlternateDataStreamDirectoryTextbox.ScrollBars    = "Vertical"
$FileSearchAlternateDataStreamDirectoryTextbox.WordWrap      = True
$FileSearchAlternateDataStreamDirectoryTextbox.AcceptsTab    = false    # Allows you to enter in tabs into the textbox
$FileSearchAlternateDataStreamDirectoryTextbox.AcceptsReturn = false # Allows you to enter in tabs into the textbox
$FileSearchAlternateDataStreamDirectoryTextbox.Font          = New-Object System.Drawing.Font("$Font",9,0,3,1)
$FileSearchAlternateDataStreamDirectoryTextbox.Text          = "Enter Directories; One Per Line"
#$FileSearchAlternateDataStreamDirectoryTextbox.Add_KeyDown({          })
$Section1FileSearchTab.Controls.Add($FileSearchAlternateDataStreamDirectoryTextbox)


# Shift the fields
$FileSearchDownPosition += $FileSearchAlternateDataStreamDirectoryTextbox.Size.Height + 5





































##############################################################################################################################################################
##
## Section 1 Sysinternals Tab
##
##############################################################################################################################################################

# Varables
$SysinternalsRightPosition     = 3
$SysinternalsDownPosition      = -10
$SysinternalsDownPositionShift = 22
$SysinternalsLabelWidth        = 450
$SysinternalsLabelHeight       = 25
$SysinternalsButtonWidth       = 110
$SysinternalsButtonHeight      = 22


$Section1SysinternalsTab          = New-Object System.Windows.Forms.TabPage
$Section1SysinternalsTab.Location = $System_Drawing_Point
$Section1SysinternalsTab.Text     = "Sysinternals"
$Section1SysinternalsTab.Location = New-Object System.Drawing.Size($SysinternalsRightPosition,$SysinternalsDownPosition) 
$Section1SysinternalsTab.Size     = New-Object System.Drawing.Size($SysinternalsLabelWidth,$SysinternalsLabelHeight) 
$Section1SysinternalsTab.UseVisualStyleBackColor = $True

# Test if the External Programs directory is present; if it's there load the tab
if (Test-Path $ExternalPrograms) {
    $Section1CollectionsTabControl.Controls.Add($Section1SysinternalsTab)
}

# Shift the fields
$SysinternalsDownPosition += $SysinternalsDownPositionShift

# Sysinternals Tab Label
$SysinternalsTabLabel           = New-Object System.Windows.Forms.Label
$SysinternalsTabLabel.Location  = New-Object System.Drawing.Point($SysinternalsRightPosition,$SysinternalsDownPosition) 
$SysinternalsTabLabel.Size      = New-Object System.Drawing.Size($SysinternalsLabelWidth,$SysinternalsLabelHeight) 
$SysinternalsTabLabel.Text      = "Options here drop/remove files to the target host's temp dir."
$SysinternalsTabLabel.Font      = New-Object System.Drawing.Font("$Font",10,1,3,1)
$SysinternalsTabLabel.ForeColor = "Red"
$Section1SysinternalsTab.Controls.Add($SysinternalsTabLabel)

# Shift the fields
$SysinternalsDownPosition += $SysinternalsDownPositionShift
# Shift the fields
$SysinternalsDownPosition += $SysinternalsDownPositionShift

#============================================================================================================================================================
# Sysinternals Autoruns
#============================================================================================================================================================

#-----------------------------
# Sysinternals Autoruns Label
#-----------------------------
$SysinternalsAutorunsLabel           = New-Object System.Windows.Forms.Label
$SysinternalsAutorunsLabel.Location  = New-Object System.Drawing.Point($SysinternalsRightPosition,$SysinternalsDownPosition) 
$SysinternalsAutorunsLabel.Size      = New-Object System.Drawing.Size(($SysinternalsLabelWidth),$SysinternalsLabelHeight) 
$SysinternalsAutorunsLabel.Text      = "Autoruns - Obtains More Startup Information than Native WMI and other Windows Commands, like various built-in Windows Applications."
#$SysinternalsAutorunsLabel.Font      = New-Object System.Drawing.Font("$Font",12,1,3,1)
$SysinternalsAutorunsLabel.ForeColor = "Blue"
$Section1SysinternalsTab.Controls.Add($SysinternalsAutorunsLabel)


# Shift the fields
$SysinternalsDownPosition += $SysinternalsDownPositionShift


#--------------------------------
# Sysinternals - Autoruns Button
#--------------------------------
$SysinternalsAutorunsButton          = New-Object System.Windows.Forms.Button
$SysinternalsAutorunsButton.Text     = "Open Autoruns"
$SysinternalsAutorunsButton.Location = New-Object System.Drawing.Size($SysinternalsRightPosition,($SysinternalsDownPosition + 5)) 
$SysinternalsAutorunsButton.Size     = New-Object System.Drawing.Size($SysinternalsButtonWidth,$SysinternalsButtonHeight) 
$SysinternalsAutorunsButton.Add_Click({
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    $SysinternalsAutorunsOpenFileDialog.Title = "Open Autoruns File"
    $SysinternalsAutorunsOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $SysinternalsAutorunsOpenFileDialog.filter = "Autoruns File (*.arn)| *.arn|All files (*.*)|*.*"
    $SysinternalsAutorunsOpenFileDialog.ShowHelp = $true
    if (Test-Path -Path $CollectedDataTimeStampDirectory) {
        $SysinternalsAutorunsOpenFileDialog.InitialDirectory = "$IndividualHostResults\$($SysinternalsAutorunsCheckbox.Name)"
        $SysinternalsAutorunsOpenFileDialog.ShowDialog() | Out-Null
        $ProcMonFileLocation = "$CollectedDataTimeStampDirectory"
    }
    else {
        $SysinternalsAutorunsOpenFileDialog.InitialDirectory = "$CollectedDataDirectory"   
        $SysinternalsAutorunsOpenFileDialog.ShowDialog() | Out-Null
        $ProcMonFileLocation = "$CollectedDataDirectory"
    }
    if ($($SysinternalsAutorunsOpenFileDialog.filename)) {
        Start-Process "$ExternalPrograms\Autoruns.exe" -ArgumentList "`"$($SysinternalsAutorunsOpenFileDialog.filename)`""
    }
})
$Section1SysinternalsTab.Controls.Add($SysinternalsAutorunsButton) 


#--------------------------------
# Sysinternals Autoruns CheckBox
#--------------------------------
$SysinternalsAutorunsCheckbox = New-Object System.Windows.Forms.CheckBox
$SysinternalsAutorunsCheckbox.Name = "Autoruns"

# Command Execution
function SysinternalsAutorunsCommand {
    $CollectionName = "Autoruns"
    Conduct-PreCommandExecution $CollectedDataTimeStampDirectory $IndividualHostResults $CollectionName

    foreach ($TargetComputer in $ComputerList) {
        Conduct-PreCommandCheck $CollectedDataTimeStampDirectory $IndividualHostResults $CollectionName $CollectionName $TargetComputer
        Create-LogEntry -TargetComputer $TargetComputer -LogFile $LogFile

        Function SysinternalsAutorunsData {
            $SysinternalsExecutable     = 'Autoruns.exe'
            $ToolName                   = 'Autoruns'
            $AdminShare                 = 'c$'
            $LocalDrive                 = 'c:'
            $PSExecPath                 = "$ExternalPrograms\PSExec.exe"
            $SysinternalsExecutablePath = "$ExternalPrograms\Autoruns.exe"
            $TargetFolder               = "Windows\Temp"
            
            $ResultsListBox.Items.Insert(2,"Copying $ToolName to $TargetComputer temporarily for use by PSExec.")
            try { Copy-Item $SysinternalsExecutablePath "\\$TargetComputer\$AdminShare\$TargetFolder" -Force -Verbose -ErrorAction Stop } catch { $ResultsListBox.Items.Insert(2,$_.Exception); break }

            # Process monitor must be launched as a separate process otherwise the sleep and terminate commands below would never execute and fill the disk
            $ResultsListBox.Items.Insert(2,"Starting process monitor on $TargetComputer")
            Start-Process -WindowStyle Hidden -FilePath $PSExecPath -ArgumentList "/accepteula -s \\$TargetComputer $LocalDrive\$TargetFolder\$SysinternalsExecutable /AcceptEula -a $LocalDrive\$TargetFolder\Autoruns-$TargetComputer.arn" -PassThru | Out-Null   

            #$ResultsListBox.Items.Insert(2,"Terminating $ToolName process on $TargetComputer")
            #Start-Process -WindowStyle Hidden -FilePath $PSExecPath -ArgumentList "/accepteula -s \\$TargetComputer $LocalDrive\$TargetFolder\$procmon /accepteula /terminate /quiet" -PassThru | Out-Null
            Start-Sleep -Seconds 30

            # Checks to see if the process is still running
            while ($true) {
                if ($(Get-WmiObject -Class Win32_Process -ComputerName "$TargetComputer" | Where-Object {$_.ProcessName -match "Autoruns"})) {  
                    #$RemoteFileSize = "$(Get-ChildItem -Path `"C:\$TempPath`" | Where-Object {$_.Name -match `"$MemoryCaptureFile`"} | Select-Object -Property Length)" #-replace "@{Length=","" -replace "}",""
                    
                    $Message = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) Checking Autoruns Status on $TargetComputer"
                    #$ResultsListBox.Items.RemoveAt(0) ; $ResultsListBox.Items.RemoveAt(0)
                    $ResultsListBox.Items.Insert(0,$Message)
                    Start-Sleep -Seconds 30
                }
                else {
                    Start-Sleep -Seconds 5

                    $ResultsListBox.Items.Insert(2,"Copy $ToolName data to local machine for analysis")
                    try { Copy-Item "\\$TargetComputer\$AdminShare\$TargetFolder\Autoruns-$TargetComputer.arn" "$IndividualHostResults\$CollectionName" -Force -Verbose -ErrorAction Stop }
                    catch { $_ ; }

                    $ResultsListBox.Items.Insert(2,"Remove temporary $ToolName executable and data file from target system")
                 
                    Remove-Item "\\$TargetComputer\$AdminShare\$TargetFolder\Autoruns-$TargetComputer.arn" -Verbose -Force
                    Remove-Item "\\$TargetComputer\$AdminShare\$TargetFolder\$SysinternalsExecutable" -Verbose -Force

                    $ResultsListBox.Items.Insert(2,"Launching $ToolName and loading collected log data")
                    if(Test-Path("$IndividualHostResults\$CollectionName\$TargetComputer.arn")) { & $procmonPath /openlog $PoShHome\Sysinternals\$TargetComputer.arn }

                    $FileSize = [math]::round(((Get-Item "$PoShHome\$TargetComputer.arn").Length/1mb),2)    
                    $ResultsListBox.Items.Insert(2,"$CollectedDataTimeStampDirectory\$TargetComputer.arn is $FileSize MB. Remember to delete it when finished.")

                    break
                }
            }
        }

        SysinternalsAutorunsData -TargetComputer $TargetComputer
    }
    Conduct-PostCommandExecution $CollectionName
}

$SysinternalsAutorunsCheckbox.Text     = "$($SysinternalsAutorunsCheckbox.Name)"
$SysinternalsAutorunsCheckbox.Location = New-Object System.Drawing.Size(($SysinternalsRightPosition + $SysinternalsButtonWidth + 5),($SysinternalsDownPosition + 5)) 
$SysinternalsAutorunsCheckbox.Size     = New-Object System.Drawing.Size(($SysinternalsLabelWidth - 130),$SysinternalsLabelHeight) 
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
$SysinternalsProcessMonitorLabel           = New-Object System.Windows.Forms.Label
$SysinternalsProcessMonitorLabel.Location  = New-Object System.Drawing.Point($SysinternalsRightPosition,$SysinternalsDownPosition) 
$SysinternalsProcessMonitorLabel.Size      = New-Object System.Drawing.Size($SysinternalsLabelWidth,$SysinternalsLabelHeight) 
$SysinternalsProcessMonitorLabel.Text      = "Procmon data will be megabytes of data per target host; Command will not run if there is less than 500MB on the local and target hosts."
#$SysinternalsProcessMonitorLabel.Font      = New-Object System.Drawing.Font("$Font",12,1,3,1)
$SysinternalsProcessMonitorLabel.ForeColor = "Blue"
$Section1SysinternalsTab.Controls.Add($SysinternalsProcessMonitorLabel)


# Shift the fields
$SysinternalsDownPosition += $SysinternalsDownPositionShift


#-------------------------------
# Sysinternals - ProcMon Button
#-------------------------------
$SysinternalsProcmonButton          = New-Object System.Windows.Forms.Button
$SysinternalsProcmonButton.Text     = "Open ProcMon"
$SysinternalsProcmonButton.Location = New-Object System.Drawing.Size($SysinternalsRightPosition,($SysinternalsDownPosition + 5)) 
$SysinternalsProcmonButton.Size     = New-Object System.Drawing.Size($SysinternalsButtonWidth,$SysinternalsButtonHeight) 
$SysinternalsProcmonButton.Add_Click({
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    $SysinternalsProcmonOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $SysinternalsProcmonOpenFileDialog.Title = "Open ProcMon File"
    $SysinternalsProcmonOpenFileDialog.filter = "ProcMon Log File (*.pml)| *.pml|All files (*.*)|*.*"
    $SysinternalsProcmonOpenFileDialog.ShowHelp = $true
    if (Test-Path -Path $CollectedDataTimeStampDirectory) {
        $SysinternalsProcmonOpenFileDialog.InitialDirectory = "$IndividualHostResults\$($SysinternalsProcessMonitorCheckbox.Name)"
        $SysinternalsProcmonOpenFileDialog.ShowDialog() | Out-Null
    }
    else {
        $SysinternalsProcmonOpenFileDialog.InitialDirectory = "$CollectedDataDirectory"   
        $SysinternalsProcmonOpenFileDialog.ShowDialog() | Out-Null
    }
    if ($($SysinternalsProcmonOpenFileDialog.filename)) {
        Start-Process "$ExternalPrograms\Procmon.exe" -ArgumentList "`"$($SysinternalsProcmonOpenFileDialog.filename)`""
    }
})
$Section1SysinternalsTab.Controls.Add($SysinternalsProcmonButton) 


#------------------------------
# Sysinternals Procmon Command
#------------------------------
$SysinternalsProcessMonitorCheckbox = New-Object System.Windows.Forms.CheckBox
$SysinternalsProcessMonitorCheckbox.Name = "Process Monitor"

# Default Procmon Time
$Script:SysinternalsProcessMonitorTime = 10

function SysinternalsProcessMonitorCommand {
    $CollectionName = "Process Monitor"
    Conduct-PreCommandExecution $CollectedDataTimeStampDirectory $IndividualHostResults $CollectionName
    foreach ($TargetComputer in $ComputerList) {
        Conduct-PreCommandCheck $CollectedDataTimeStampDirectory $IndividualHostResults $CollectionName $CollectionName $TargetComputer
        Create-LogEntry -TargetComputer $TargetComputer -LogFile $LogFile
                
        # Collect Remote host Disk Space       
        Function Get-DiskSpace([string] $TargetComputer) {
                try { $HD = Get-WmiObject Win32_LogicalDisk -ComputerName $TargetComputer -Filter "DeviceID='C:'" -ErrorAction Stop } 
                catch { $ResultsListBox.Items.Insert(2,"Unable to connect to $TargetComputer. $_"); continue}
                if(!$HD) { throw }
                $FreeSpace = [math]::round(($HD.FreeSpace/1gb),2)
                return $FreeSpace
        }

        # Uses PSExec and Procmon to get Process Monitoring informaiton on remote hosts
        # Diskspace is calculated on local and target hosts to determine if there's a risk
        # Procmon is copied over to the target host, and data is gathered there and then exported back
        # The Procmon program and capture file are deleted
        Function SysinternalsProcessMonitorData {
            # Checks to see if the duration is within 10 and 100 seconds
            Param(
                [Parameter(Mandatory=$true)][string]$TargetComputer, 
                [Parameter(Mandatory=$true,
                    HelpMessage="Enter a duration from 10 to 300 seconds (limited due to disk space requriements")]
                    [ValidateRange(10,300)][int]$Duration
            )
            $SysinternalsExecutable      = 'procmon.exe'
            $ToolName                    = 'ProcMon'
            $AdminShare                  = 'c$'
            $LocalDrive                  = 'c:'
            $PSExecPath                  = "$ExternalPrograms\PSExec.exe"
            $SysinternalsExecutablePath  = "$ExternalPrograms\Procmon.exe"
            $TargetFolder                = "Windows\Temp"            
           
            $ResultsListBox.Items.Insert(2,"Verifing connection to $TargetComputer, checking for PSExec and Procmon.")
    
            # Process monitor generates enormous amounts of data.  
            # To try and offer some protections, the script won't run if the source or target have less than 500MB free
            $ResultsListBox.Items.Insert(2,"Verifying free diskspace on source and target.")
            if((Get-DiskSpace $TargetComputer) -lt 0.5) 
                { $ResultsListBox.Items.Insert(2,"$TargetComputer has less than 500MB free - aborting to avoid filling the disk."); break }

            if((Get-DiskSpace $Env:ComputerName) -lt 0.5) 
                { $ResultsListBox.Items.Insert(2,"Local computer has less than 500MB free - aborting to avoid filling the disk."); break }

            $ResultsListBox.Items.Insert(2,"Copying Procmon to the target system temporarily for use by PSExec.")
            try { Copy-Item $SysinternalsExecutablePath "\\$TargetComputer\$AdminShare\$TargetFolder" -Force -Verbose -ErrorAction Stop } catch { $ResultsListBox.Items.Insert(2,$_.Exception); break }

            # Process monitor must be launched as a separate process otherwise the sleep and terminate commands below would never execute and fill the disk
            $ResultsListBox.Items.Insert(2,"Starting process monitor on $TargetComputer")
            #$Command = Start-Process -WindowStyle Hidden -FilePath $PSExecPath -ArgumentList "/accepteula $script:Credentials -s \\$TargetComputer $LocalDrive\$TargetFolder\$SysinternalsExecutable /AcceptEula /BackingFile $LocalDrive\$TargetFolder\$TargetComputer /RunTime 10 /Quiet" -PassThru | Out-Null
            $Command = Start-Process -WindowStyle Hidden -FilePath $PSExecPath -ArgumentList "/accepteula -s \\$TargetComputer $LocalDrive\$TargetFolder\$SysinternalsExecutable /AcceptEula /BackingFile `"$LocalDrive\$TargetFolder\ProcMon-$TargetComputer`" /RunTime $Duration /Quiet" -PassThru | Out-Null
            $Command
            $Message = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $TargetComputer $($SysinternalsProcessMonitorCheckbox.Name)"
            $Message | Add-Content -Path $LogFile
            $Message = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $TargetComputer $Command"
            $Message | Add-Content -Path $LogFile

            Start-Sleep -Seconds ($Duration + 5)

            while ($true) {
                if ($(Get-WmiObject -Class Win32_Process -ComputerName "$TargetComputer" | Where-Object {$_.ProcessName -match "Procmon"})) {                      
                    $Message = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) Checking ProcMon Status on $TargetComputer"
                    $ResultsListBox.Items.Insert(0,$Message)
                    Start-Sleep -Seconds 30
                }
                else {
                    Start-Sleep -Seconds 5

                    $ResultsListBox.Items.Insert(2,"Copy $ToolName data to local machine for analysis")
                    try { Copy-Item "\\$TargetComputer\$AdminShare\$TargetFolder\ProcMon-$TargetComputer.pml" "$IndividualHostResults\$CollectionName" -Force -Verbose -ErrorAction Stop }
                    catch { $_ ; }

                    $ResultsListBox.Items.Insert(2,"Remove temporary $ToolName executable and data file from target system")
                 
                    Remove-Item "\\$TargetComputer\$AdminShare\$TargetFolder\ProcMon-$TargetComputer.pml" -Verbose -Force
                    Remove-Item "\\$TargetComputer\$AdminShare\$TargetFolder\$SysinternalsExecutable" -Verbose -Force

                    $ResultsListBox.Items.Insert(2,"Launching $ToolName and loading collected log data")
                    if(Test-Path("$IndividualHostResults\$CollectionName\$TargetComputer.pml")) { & $SysinternalsExecutablePath /openlog $PoShHome\Sysinternals\$TargetComputer.pml }

                    $FileSize = [math]::round(((Get-Item "$IndividualHostResults\$CollectionName\$TargetComputer.pml").Length/1mb),2)    
                    $ResultsListBox.Items.Insert(2,"$IndividualHostResults\$CollectionName\$TargetComputer.pml is $FileSize MB. Remember to delete it when finished.")

                    break
                }
            }

        }

        SysinternalsProcessMonitorData -TargetComputer $TargetComputer -Duration $Script:SysinternalsProcessMonitorTime
    }
    Conduct-PostCommandExecution $CollectionName
}

$SysinternalsProcessMonitorCheckbox.Text     = "$($SysinternalsProcessMonitorCheckbox.Name)"
$SysinternalsProcessMonitorCheckbox.Location = New-Object System.Drawing.Size(($SysinternalsRightPosition + $SysinternalsButtonWidth + 5),($SysinternalsDownPosition + 5)) 
$SysinternalsProcessMonitorCheckbox.Size     = New-Object System.Drawing.Size(($SysinternalsLabelWidth - 330),$SysinternalsLabelHeight) 
$Section1SysinternalsTab.Controls.Add($SysinternalsProcessMonitorCheckbox)


#------------------------
# Procmon - Time TextBox
#------------------------
$SysinternalsProcessMonitorTimeTextBox          = New-Object System.Windows.Forms.TextBox
$SysinternalsProcessMonitorTimeTextBox.Location = New-Object System.Drawing.Size(($SysinternalsRightPosition + $SysinternalsButtonWidth + 150),($SysinternalsDownPosition + 6)) 
$SysinternalsProcessMonitorTimeTextBox.Size     = New-Object System.Drawing.Size((160),$SysinternalsLabelHeight) 
$SysinternalsProcessMonitorTimeTextBox.Text     = "Default = 10 Seconds"
# Press Enter to Input Data
$SysinternalsProcessMonitorTimeTextBox.Add_KeyDown({
    if ($_.KeyCode -eq "Enter") {
        # Enter a capture time between 10 and 300 seconds
        if (($SysinternalsProcessMonitorTimeTextBox.Text -ge 10) -and ($SysinternalsProcessMonitorTimeTextBox.Text -le 300)) {
            $Script:SysinternalsProcessMonitorTime = $SysinternalsProcessMonitorTimeTextBox.Text
            $Success=[System.Windows.Forms.MessageBox]::Show(`
                "Success! The capture time has been set for $SysinternalsProcessMonitorTime seconds.",`
                "PoSh-ACME",`
                [System.Windows.Forms.MessageBoxButtons]::OK)
                switch ($Success){
                "OK" {
                    #write-host "You pressed OK"
                }
            }
        }
        else {
            $OhDarn=[System.Windows.Forms.MessageBox]::Show(`
                "Enter a capture time between 10 and 300 seconds.",`
                "PoSh-ACME",`
                [System.Windows.Forms.MessageBoxButtons]::OK)
                switch ($OhDarn){
                "OK" {
                    #write-host "You pressed OK"
                }
            }        
        }
    }
})
$Section1SysinternalsTab.Controls.Add($SysinternalsProcessMonitorTimeTextBox)

##############################################################################################################################################################
##
## Enumeration
##
##############################################################################################################################################################

# Varables
$EnumerationRightPosition     = 3
$EnumerationDownPosition      = 0
$EnumerationDownPositionShift = 25
$EnumerationLabelWidth        = 450
$EnumerationLabelHeight       = 25
$EnumerationButtonWidth       = 110
$EnumerationButtonHeight      = 22
$EnumerationGroupGap          = 15

$Section1EnumerationTab          = New-Object System.Windows.Forms.TabPage
$Section1EnumerationTab.Location = $System_Drawing_Point
$Section1EnumerationTab.Name     = "Enumeration"
$Section1EnumerationTab.Text     = "Enumeration"
$Section1EnumerationTab.Location = New-Object System.Drawing.Size($EnumerationRightPosition,$EnumerationDownPosition) 
$Section1EnumerationTab.Size     = New-Object System.Drawing.Size($EnumerationLabelWidth,$EnumerationLabelHeight) 
$Section1EnumerationTab.UseVisualStyleBackColor = $True
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
$EnumerationDomainGenerateGroupBox           = New-Object System.Windows.Forms.GroupBox
$EnumerationDomainGenerateGroupBox.Location  = New-Object System.Drawing.Size(0,$EnumerationDownPosition)
$EnumerationDomainGenerateGroupBox.size      = New-Object System.Drawing.Size(294,100)
$EnumerationDomainGenerateGroupBox.text      = "Import List From Domain"
$EnumerationDomainGenerateGroupBox.Font      = New-Object System.Drawing.Font("$Font",12,1,2,1)
$EnumerationDomainGenerateGroupBox.ForeColor = "Blue"

$EnumerationDomainGenerateDownPosition      = 18
$EnumerationDomainGenerateDownPositionShift = 25

    $EnumerationDomainGeneratedLabelNote           = New-Object System.Windows.Forms.Label
    $EnumerationDomainGeneratedLabelNote.Location  = New-Object System.Drawing.Size($EnumerationRightPosition,($EnumerationDomainGenerateDownPosition + 3)) 
    $EnumerationDomainGeneratedLabelNote.Size      = New-Object System.Drawing.Size(220,22)
    $EnumerationDomainGeneratedLabelNote.Text      = "This host must be domained for this feature."    
    $EnumerationDomainGeneratedLabelNote.Font      = New-Object System.Drawing.Font("$Font",11,0,2,1)
    $EnumerationDomainGeneratedLabelNote.ForeColor = "Black"
    $EnumerationDomainGenerateGroupBox.Controls.Add($EnumerationDomainGeneratedLabelNote)  

    #-----------------------------------------------------
    # Enumeration - Domain Generated - Auto Pull Checkbox
    #-----------------------------------------------------
    $EnumerationDomainGeneratedAutoCheckBox           = New-Object System.Windows.Forms.Checkbox
    $EnumerationDomainGeneratedAutoCheckBox.Name      = "Auto Pull"
    $EnumerationDomainGeneratedAutoCheckBox.Text      = "$($EnumerationDomainGeneratedAutoCheckBox.Name)"
    $EnumerationDomainGeneratedAutoCheckBox.Location  = New-Object System.Drawing.Size(($EnumerationDomainGeneratedLabelNote.Size.Width + 3),($EnumerationDomainGenerateDownPosition - 1))
    $EnumerationDomainGeneratedAutoCheckBox.Size      = New-Object System.Drawing.Size(100,$EnumerationLabelHeight)
    $EnumerationDomainGeneratedAutoCheckBox.Font      = New-Object System.Drawing.Font("$Font",11,0,2,1)
    $EnumerationDomainGeneratedAutoCheckBox.ForeColor = "Black"
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
    $EnumerationDomainGeneratedTextBox           = New-Object System.Windows.Forms.TextBox
    $EnumerationDomainGeneratedTextBox.Text      = "<Domain Name>"
    $EnumerationDomainGeneratedTextBox.Location  = New-Object System.Drawing.Size($EnumerationRightPosition,$EnumerationDomainGenerateDownPosition)
    $EnumerationDomainGeneratedTextBox.Size      = New-Object System.Drawing.Size(286,$EnumerationLabelHeight)
    $EnumerationDomainGeneratedTextBox.Font      = New-Object System.Drawing.Font("$Font",11,0,2,1)
    $EnumerationDomainGeneratedTextBox.ForeColor = "Black"
    $EnumerationDomainGeneratedTextBox.Add_KeyDown({
        if ($_.KeyCode -eq "Enter") { EnumerationDomainGeneratedInputCheck }
    })
    $EnumerationDomainGenerateGroupBox.Controls.Add($EnumerationDomainGeneratedTextBox)

    $EnumerationDomainGenerateDownPosition += $EnumerationDomainGenerateDownPositionShift

    #----------------------------------------------------------
    # Enumeration - Domain Generated - Import Hosts/IPs Button
    #----------------------------------------------------------
    $EnumerationDomainGeneratedListButton           = New-Object System.Windows.Forms.Button
    $EnumerationDomainGeneratedListButton.Text      = "Import Hosts"
    $EnumerationDomainGeneratedListButton.Location  = New-Object System.Drawing.Size(190,($EnumerationDomainGenerateDownPosition - 1))
    $EnumerationDomainGeneratedListButton.Size      = New-Object System.Drawing.Size(100,22)
    $EnumerationDomainGeneratedListButton.Font      = New-Object System.Drawing.Font("$Font",11,0,2,1)
    $EnumerationDomainGeneratedListButton.ForeColor = "Red"
    $EnumerationDomainGeneratedListButton.Add_Click({ EnumerationDomainGeneratedInputCheck })
    $EnumerationDomainGenerateGroupBox.Controls.Add($EnumerationDomainGeneratedListButton) 

$Section1EnumerationTab.Controls.Add($EnumerationDomainGenerateGroupBox) 

#============================================================================================================================================================
# Enumeration - Port Scanning
#============================================================================================================================================================
if (!(Test-Path $CustomPortsToScan)) {
    #Don't modify / indent the numbers below... to ensure the file created is formated correctly
    Write-Output "21
22
23
53
80
88
110
123
135
143
161
389
443
445
3389" | Out-File -FilePath $CustomPortsToScan -Force
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
        foreach ($Port in $PortsToScan) {
            $ErrorActionPreference = 'SilentlyContinue'
            $socket = New-Object System.Net.Sockets.TcpClient
            $connect = $socket.BeginConnect($IPAddress, $port, $null, $null)
            $tryconnect = Measure-Command { $success = $connect.AsyncWaitHandle.WaitOne($Timeout_ms, $true) } | % totalmilliseconds
            $tryconnect | Out-Null 
            if ($socket.Connected) {
                $ResultsListBox.Items.Insert(2,"$(Get-Date)  - [Response Time: $tryconnect ms] $IPAddress is listening on port $Port ")
                $contime = [math]::round($tryconnect,2)    
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
        }
        if ($NetworkPortScanIPResponded -ne "") {
            $EnumerationComputerListBox.Items.Add("$NetworkPortScanIPResponded")
        }
        $NetworkPortScanResultsIPList = @() # To Clear out the Variable        
    }
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
    }
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Port Scan Completed - Results Are Saved In The Log File")
    $ResultsListBox.Items.Insert(0,"$(Get-Date)  ==================== Port Scan Complete ====================")
}

#------------------------------------
# Enumeration - Port Scan - GroupBox
#------------------------------------
$EnumerationPortScanGroupBox           = New-Object System.Windows.Forms.GroupBox
$EnumerationPortScanGroupBox.Location  = New-Object System.Drawing.Size(0,($EnumerationDomainGenerateGroupBox.Location.Y + $EnumerationDomainGenerateGroupBox.Size.Height + $EnumerationGroupGap))
$EnumerationPortScanGroupBox.size      = New-Object System.Drawing.Size(294,270)
$EnumerationPortScanGroupBox.text      = "Create List From TCP Port Scan"
$EnumerationPortScanGroupBox.Font      = New-Object System.Drawing.Font("$Font",12,1,2,1)
$EnumerationPortScanGroupBox.ForeColor = "Blue"

$EnumerationPortScanGroupDownPosition      = 18
$EnumerationPortScanGroupDownPositionShift = 25

    #----------------------------------------
    # Enumeration - Port Scan - Specific IPs
    #----------------------------------------
    $EnumerationPortScanIPNote1Label            = New-Object System.Windows.Forms.Label
    $EnumerationPortScanIPNote1Label.Location   = New-Object System.Drawing.Point($EnumerationRightPosition,($EnumerationPortScanGroupDownPosition + 3)) 
    $EnumerationPortScanIPNote1Label.Size       = New-Object System.Drawing.Size(170,22) 
    $EnumerationPortScanIPNote1Label.Text       = "Enter Comma Separated IPs"
    $EnumerationPortScanIPNote1Label.Font       = New-Object System.Drawing.Font("$Font",10,1,2,1)
    $EnumerationPortScanIPNote1Label.ForeColor  = "Black"
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPNote1Label)

    $EnumerationPortScanIPNote2Label            = New-Object System.Windows.Forms.Label
    $EnumerationPortScanIPNote2Label.Location   = New-Object System.Drawing.Point(($EnumerationPortScanIPNote1Label.Size.Width + 3),($EnumerationPortScanGroupDownPosition + 4)) 
    $EnumerationPortScanIPNote2Label.Size       = New-Object System.Drawing.Size(110,20) 
    $EnumerationPortScanIPNote2Label.Text       = "(ex: 10.0.0.1,10.0.0.2)"
    $EnumerationPortScanIPNote2Label.Font       = New-Object System.Drawing.Font("$Font",9,0,2,1)
    $EnumerationPortScanIPNote2Label.ForeColor  = "Black"
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPNote2Label)
    $EnumerationPortScanGroupDownPosition += $EnumerationPortScanGroupDownPositionShift

    #--------------------------------------------------------------
    # Enumeration - Port Scan - Enter Specific Comma Separated IPs
    #--------------------------------------------------------------
    $EnumerationPortScanSpecificIPTextbox               = New-Object System.Windows.Forms.TextBox
    $EnumerationPortScanSpecificIPTextbox.Location      = New-Object System.Drawing.Size($EnumerationRightPosition,$EnumerationPortScanGroupDownPosition) 
    $EnumerationPortScanSpecificIPTextbox.Size          = New-Object System.Drawing.Size(287,22)
    $EnumerationPortScanSpecificIPTextbox.MultiLine     = $False
    $EnumerationPortScanSpecificIPTextbox.WordWrap      = True
    $EnumerationPortScanSpecificIPTextbox.AcceptsTab    = false # Allows you to enter in tabs into the textbox
    $EnumerationPortScanSpecificIPTextbox.AcceptsReturn = false # Allows you to enter in returnss into the textbox
    $EnumerationPortScanSpecificIPTextbox.Text          = ""
    $EnumerationPortScanSpecificIPTextbox.Font          = New-Object System.Drawing.Font("$Font",11,0,2,1)
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
    $EnumerationPortScanIPRangeNote1Label.Size       = New-Object System.Drawing.Size(143,22) 
    $EnumerationPortScanIPRangeNote1Label.Text       = "Network Range:"
    $EnumerationPortScanIPRangeNote1Label.Font       = New-Object System.Drawing.Font("$Font",10,1,2,1)
    $EnumerationPortScanIPRangeNote1Label.ForeColor  = "Black"
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPRangeNote1Label)

    $EnumerationPortScanIPRangeNote2Label            = New-Object System.Windows.Forms.Label
    $EnumerationPortScanIPRangeNote2Label.Location   = New-Object System.Drawing.Point(($EnumerationPortScanIPRangeNote1Label.Size.Width + 3),($EnumerationPortScanGroupDownPosition + 4)) 
    $EnumerationPortScanIPRangeNote2Label.Size       = New-Object System.Drawing.Size(150,20) 
    $EnumerationPortScanIPRangeNote2Label.Text       = "(ex: [ 192.168.1 ]   [ 1 ]   [ 100 ])"
    $EnumerationPortScanIPRangeNote2Label.Font       = New-Object System.Drawing.Font("$Font",9,0,2,1)
    $EnumerationPortScanIPRangeNote2Label.ForeColor  = "Black"
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPRangeNote2Label)

    $EnumerationPortScanGroupDownPosition += $EnumerationPortScanGroupDownPositionShift
    $RightShift = $EnumerationRightPosition

    $EnumerationPortScanIPRangeNetworkLabel           = New-Object System.Windows.Forms.Label
    $EnumerationPortScanIPRangeNetworkLabel.Location  = New-Object System.Drawing.Point($RightShift,($EnumerationPortScanGroupDownPosition + 3)) 
    $EnumerationPortScanIPRangeNetworkLabel.Size      = New-Object System.Drawing.Size(50,22) 
    $EnumerationPortScanIPRangeNetworkLabel.Text      = "Network"
    $EnumerationPortScanIPRangeNetworkLabel.Font      = New-Object System.Drawing.Font("$Font",11,0,2,1)
    $EnumerationPortScanIPRangeNetworkLabel.ForeColor = "Black"
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPRangeNetworkLabel)

    $RightShift += $EnumerationPortScanIPRangeNetworkLabel.Size.Width

    $EnumerationPortScanIPRangeNetworkTextbox               = New-Object System.Windows.Forms.TextBox
    $EnumerationPortScanIPRangeNetworkTextbox.Location      = New-Object System.Drawing.Size($RightShift,$EnumerationPortScanGroupDownPosition) 
    $EnumerationPortScanIPRangeNetworkTextbox.Size          = New-Object System.Drawing.Size(77,22)
    $EnumerationPortScanIPRangeNetworkTextbox.MultiLine     = $False
    $EnumerationPortScanIPRangeNetworkTextbox.WordWrap      = True
    $EnumerationPortScanIPRangeNetworkTextbox.AcceptsTab    = false # Allows you to enter in tabs into the textbox
    $EnumerationPortScanIPRangeNetworkTextbox.AcceptsReturn = false # Allows you to enter in returnss into the textbox
    $EnumerationPortScanIPRangeNetworkTextbox.Text          = ""
    $EnumerationPortScanIPRangeNetworkTextbox.Font          = New-Object System.Drawing.Font("$Font",11,0,2,1)
    $EnumerationPortScanIPRangeNetworkTextbox.ForeColor     = "Black"
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPRangeNetworkTextbox)

    $RightShift += $EnumerationPortScanIPRangeNetworkTextbox.Size.Width

    $EnumerationPortScanIPRangeFirstLabel           = New-Object System.Windows.Forms.Label
    $EnumerationPortScanIPRangeFirstLabel.Location  = New-Object System.Drawing.Point($RightShift,($EnumerationPortScanGroupDownPosition + 3)) 
    $EnumerationPortScanIPRangeFirstLabel.Size      = New-Object System.Drawing.Size(40,22) 
    $EnumerationPortScanIPRangeFirstLabel.Text      = "First IP"
    $EnumerationPortScanIPRangeFirstLabel.Font      = New-Object System.Drawing.Font("$Font",11,0,2,1)
    $EnumerationPortScanIPRangeFirstLabel.ForeColor = "Black"
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPRangeFirstLabel)

    $RightShift += $EnumerationPortScanIPRangeFirstLabel.Size.Width

    $EnumerationPortScanIPRangeFirstTextbox               = New-Object System.Windows.Forms.TextBox
    $EnumerationPortScanIPRangeFirstTextbox.Location      = New-Object System.Drawing.Size($RightShift,$EnumerationPortScanGroupDownPosition) 
    $EnumerationPortScanIPRangeFirstTextbox.Size          = New-Object System.Drawing.Size(40,22)
    $EnumerationPortScanIPRangeFirstTextbox.MultiLine     = $False
    $EnumerationPortScanIPRangeFirstTextbox.WordWrap      = True
    $EnumerationPortScanIPRangeFirstTextbox.AcceptsTab    = false # Allows you to enter in tabs into the textbox
    $EnumerationPortScanIPRangeFirstTextbox.AcceptsReturn = false # Allows you to enter in returnss into the textbox
    $EnumerationPortScanIPRangeFirstTextbox.Text          = ""
    $EnumerationPortScanIPRangeFirstTextbox.Font          = New-Object System.Drawing.Font("$Font",11,0,2,1)
    $EnumerationPortScanIPRangeFirstTextbox.ForeColor     = "Black"
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPRangeFirstTextbox)

    $RightShift += $EnumerationPortScanIPRangeFirstTextbox.Size.Width

    $EnumerationPortScanIPRangeLastLabel           = New-Object System.Windows.Forms.Label
    $EnumerationPortScanIPRangeLastLabel.Location  = New-Object System.Drawing.Point($RightShift,($EnumerationPortScanGroupDownPosition + 3)) 
    $EnumerationPortScanIPRangeLastLabel.Size      = New-Object System.Drawing.Size(40,22) 
    $EnumerationPortScanIPRangeLastLabel.Text      = "Last IP"
    $EnumerationPortScanIPRangeLastLabel.Font      = New-Object System.Drawing.Font("$Font",11,0,2,1)
    $EnumerationPortScanIPRangeLastLabel.ForeColor = "Black"
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPRangeLastLabel)

    $RightShift += $EnumerationPortScanIPRangeLastLabel.Size.Width

    $EnumerationPortScanIPRangeLastTextbox               = New-Object System.Windows.Forms.TextBox
    $EnumerationPortScanIPRangeLastTextbox.Location      = New-Object System.Drawing.Size($RightShift,$EnumerationPortScanGroupDownPosition) 
    $EnumerationPortScanIPRangeLastTextbox.Size          = New-Object System.Drawing.Size(40,22)
    $EnumerationPortScanIPRangeLastTextbox.MultiLine     = $False
    $EnumerationPortScanIPRangeLastTextbox.WordWrap      = True
    $EnumerationPortScanIPRangeLastTextbox.AcceptsTab    = false # Allows you to enter in tabs into the textbox
    $EnumerationPortScanIPRangeLastTextbox.AcceptsReturn = false # Allows you to enter in returnss into the textbox
    $EnumerationPortScanIPRangeLastTextbox.Text          = ""
    $EnumerationPortScanIPRangeLastTextbox.Font          = New-Object System.Drawing.Font("$Font",11,0,2,1)
    $EnumerationPortScanIPRangeLastTextbox.ForeColor     = "Black"
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPRangeLastTextbox)

    $EnumerationPortScanGroupDownPosition += $EnumerationPortScanGroupDownPositionShift

    #------------------------------------------
    # Enumeration - Port Scan - Specific Ports
    #------------------------------------------
    $EnumerationPortScanPortNote1Label            = New-Object System.Windows.Forms.Label
    $EnumerationPortScanPortNote1Label.Location   = New-Object System.Drawing.Point($EnumerationRightPosition,($EnumerationPortScanGroupDownPosition + 3)) 
    $EnumerationPortScanPortNote1Label.Size       = New-Object System.Drawing.Size(170,22) 
    $EnumerationPortScanPortNote1Label.Text       = "Enter Comma Separated Ports"
    $EnumerationPortScanPortNote1Label.Font       = New-Object System.Drawing.Font("$Font",10,1,2,1)
    $EnumerationPortScanPortNote1Label.ForeColor  = "Black"
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortNote1Label)

    $EnumerationPortScanPortNote2Label            = New-Object System.Windows.Forms.Label
    $EnumerationPortScanPortNote2Label.Location   = New-Object System.Drawing.Point(($EnumerationPortScanPortNote1Label.Size.Width + 3),($EnumerationPortScanGroupDownPosition + 4)) 
    $EnumerationPortScanPortNote2Label.Size       = New-Object System.Drawing.Size(110,20)
    $EnumerationPortScanPortNote2Label.Text       = "(ex: 22,139,80,443,445)"
    $EnumerationPortScanPortNote2Label.Font       = New-Object System.Drawing.Font("$Font",9,0,2,1)
    $EnumerationPortScanPortNote2Label.ForeColor  = "Black"
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortNote2Label)

    $EnumerationPortScanGroupDownPosition += $EnumerationPortScanGroupDownPositionShift

    $EnumerationPortScanSpecificPortsTextbox               = New-Object System.Windows.Forms.TextBox
    $EnumerationPortScanSpecificPortsTextbox.Location      = New-Object System.Drawing.Size($EnumerationRightPosition,$EnumerationPortScanGroupDownPosition) 
    $EnumerationPortScanSpecificPortsTextbox.Size          = New-Object System.Drawing.Size(288,22)
    $EnumerationPortScanSpecificPortsTextbox.MultiLine     = $False
    $EnumerationPortScanSpecificPortsTextbox.WordWrap      = True
    $EnumerationPortScanSpecificPortsTextbox.AcceptsTab    = false # Allows you to enter in tabs into the textbox
    $EnumerationPortScanSpecificPortsTextbox.AcceptsReturn = false # Allows you to enter in returnss into the textbox
    $EnumerationPortScanSpecificPortsTextbox.Text          = ""
    $EnumerationPortScanSpecificPortsTextbox.Font          = New-Object System.Drawing.Font("$Font",11,0,2,1)
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
    $EnumerationPortScanPortQuickPickComboBox.Location      = New-Object System.Drawing.Size($EnumerationRightPosition,$EnumerationPortScanGroupDownPosition) 
    $EnumerationPortScanPortQuickPickComboBox.Size          = New-Object System.Drawing.Size(183,20)
    $EnumerationPortScanPortQuickPickComboBox.Text          = "Quick-Pick Port Selection"
    $EnumerationPortScanPortQuickPickComboBox.Font          = New-Object System.Drawing.Font("$Font",11,0,2,1)
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
        $EnumerationPortScanPortsSelectionButton.Location  = New-Object System.Drawing.Size(($EnumerationPortScanPortQuickPickComboBox.Size.Width + 8),$EnumerationPortScanGroupDownPosition) 
        $EnumerationPortScanPortsSelectionButton.Size      = New-Object System.Drawing.Size(100,20) 
        $EnumerationPortScanPortsSelectionButton.Font      = New-Object System.Drawing.Font("$Font",12,0,2,1)
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
    $EnumerationPortScanPortRangeNetworkLabel.Font      = New-Object System.Drawing.Font("$Font",10,1,2,1)
    $EnumerationPortScanPortRangeNetworkLabel.ForeColor = "Black"
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortRangeNetworkLabel)

    $EnumerationPortScanRightShift += $EnumerationPortScanPortRangeNetworkLabel.Size.Width

    $EnumerationPortScanPortRangeFirstLabel           = New-Object System.Windows.Forms.Label
    $EnumerationPortScanPortRangeFirstLabel.Location  = New-Object System.Drawing.Point($EnumerationPortScanRightShift,($EnumerationPortScanGroupDownPosition + 3)) 
    $EnumerationPortScanPortRangeFirstLabel.Size      = New-Object System.Drawing.Size(50,22) 
    $EnumerationPortScanPortRangeFirstLabel.Text      = "First Port"
    $EnumerationPortScanPortRangeFirstLabel.Font      = New-Object System.Drawing.Font("$Font",11,0,2,1)
    $EnumerationPortScanPortRangeFirstLabel.ForeColor = "Black"
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortRangeFirstLabel)

    $EnumerationPortScanRightShift += $EnumerationPortScanPortRangeFirstLabel.Size.Width

    $EnumerationPortScanPortRangeFirstTextbox               = New-Object System.Windows.Forms.TextBox
    $EnumerationPortScanPortRangeFirstTextbox.Location      = New-Object System.Drawing.Size($EnumerationPortScanRightShift,$EnumerationPortScanGroupDownPosition) 
    $EnumerationPortScanPortRangeFirstTextbox.Size          = New-Object System.Drawing.Size(50,22)
    $EnumerationPortScanPortRangeFirstTextbox.MultiLine     = $False
    $EnumerationPortScanPortRangeFirstTextbox.WordWrap      = True
    $EnumerationPortScanPortRangeFirstTextbox.AcceptsTab    = false # Allows you to enter in tabs into the textbox
    $EnumerationPortScanPortRangeFirstTextbox.AcceptsReturn = false # Allows you to enter in returnss into the textbox
    $EnumerationPortScanPortRangeFirstTextbox.Text          = ""
    $EnumerationPortScanPortRangeFirstTextbox.Font          = New-Object System.Drawing.Font("$Font",11,0,2,1)
    $EnumerationPortScanPortRangeFirstTextbox.ForeColor     = "Black"
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortRangeFirstTextbox)

    $EnumerationPortScanRightShift += $EnumerationPortScanPortRangeFirstTextbox.Size.Width + 4

    $EnumerationPortScanPortRangeLastLabel           = New-Object System.Windows.Forms.Label
    $EnumerationPortScanPortRangeLastLabel.Location  = New-Object System.Drawing.Point($EnumerationPortScanRightShift,($EnumerationPortScanGroupDownPosition + 3)) 
    $EnumerationPortScanPortRangeLastLabel.Size      = New-Object System.Drawing.Size(50,22) 
    $EnumerationPortScanPortRangeLastLabel.Text      = "Last Port"
    $EnumerationPortScanPortRangeLastLabel.Font      = New-Object System.Drawing.Font("$Font",11,0,2,1)
    $EnumerationPortScanPortRangeLastLabel.ForeColor = "Black"
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortRangeLastLabel)

    $EnumerationPortScanRightShift += $EnumerationPortScanPortRangeLastLabel.Size.Width

    $EnumerationPortScanPortRangeLastTextbox               = New-Object System.Windows.Forms.TextBox
    $EnumerationPortScanPortRangeLastTextbox.Location      = New-Object System.Drawing.Size($EnumerationPortScanRightShift,$EnumerationPortScanGroupDownPosition) 
    $EnumerationPortScanPortRangeLastTextbox.Size          = New-Object System.Drawing.Size(50,22)
    $EnumerationPortScanPortRangeLastTextbox.MultiLine     = $False
    $EnumerationPortScanPortRangeLastTextbox.WordWrap      = True
    $EnumerationPortScanPortRangeLastTextbox.AcceptsTab    = false # Allows you to enter in tabs into the textbox
    $EnumerationPortScanPortRangeLastTextbox.AcceptsReturn = false # Allows you to enter in returnss into the textbox
    $EnumerationPortScanPortRangeLastTextbox.Text          = ""
    $EnumerationPortScanPortRangeLastTextbox.Font          = New-Object System.Drawing.Font("$Font",11,0,2,1)
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
    $EnumerationPortScanTestICMPFirstCheckBox.Font      = New-Object System.Drawing.Font("$Font",10,1,2,1)
    $EnumerationPortScanTestICMPFirstCheckBox.ForeColor = "Black"
    $EnumerationPortScanTestICMPFirstCheckBox.Checked   = $False
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanTestICMPFirstCheckBox)

    $EnumerationPortScanRightShift += $EnumerationPortScanTestICMPFirstCheckBox.Size.Width + 32

    $EnumerationPortScanTimeoutLabel           = New-Object System.Windows.Forms.Label
    $EnumerationPortScanTimeoutLabel.Location  = New-Object System.Drawing.Point($EnumerationPortScanRightShift,($EnumerationPortScanGroupDownPosition + 3)) 
    $EnumerationPortScanTimeoutLabel.Size      = New-Object System.Drawing.Size(75,22) 
    $EnumerationPortScanTimeoutLabel.Text      = "Timeout (ms)"
    $EnumerationPortScanTimeoutLabel.Font      = New-Object System.Drawing.Font("$Font",10,1,2,1)
    $EnumerationPortScanTimeoutLabel.ForeColor = "Black"
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanTimeoutLabel)

    $EnumerationPortScanRightShift += $EnumerationPortScanTimeoutLabel.Size.Width

    $EnumerationPortScanTimeoutTextbox               = New-Object System.Windows.Forms.TextBox
    $EnumerationPortScanTimeoutTextbox.Location      = New-Object System.Drawing.Size($EnumerationPortScanRightShift,$EnumerationPortScanGroupDownPosition) 
    $EnumerationPortScanTimeoutTextbox.Size          = New-Object System.Drawing.Size(50,22)
    $EnumerationPortScanTimeoutTextbox.MultiLine     = $False
    $EnumerationPortScanTimeoutTextbox.WordWrap      = True
    $EnumerationPortScanTimeoutTextbox.AcceptsTab    = false # Allows you to enter in tabs into the textbox
    $EnumerationPortScanTimeoutTextbox.AcceptsReturn = false # Allows you to enter in returnss into the textbox
    $EnumerationPortScanTimeoutTextbox.Text          = 50
    $EnumerationPortScanTimeoutTextbox.Font          = New-Object System.Drawing.Font("$Font",11,0,2,1)
    $EnumerationPortScanTimeoutTextbox.ForeColor     = "Black"
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanTimeoutTextbox)

    $EnumerationPortScanRightShift        += $EnumerationPortScanTimeoutTextbox.Size.Width
    $EnumerationPortScanGroupDownPosition += $EnumerationPortScanGroupDownPositionShift

    #------------------------------------------
    # Enumeration - Port Scan - Execute Button
    #------------------------------------------
    $EnumerationPortScanExecutionButton           = New-Object System.Windows.Forms.Button
    $EnumerationPortScanExecutionButton.Text      = "Execute Scan"
    $EnumerationPortScanExecutionButton.Location  = New-Object System.Drawing.Size(190,$EnumerationPortScanGroupDownPosition)
    $EnumerationPortScanExecutionButton.Size      = New-Object System.Drawing.Size(100,22)
    $EnumerationPortScanExecutionButton.Font      = New-Object System.Drawing.Font("$Font",12,0,2,1)
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

    foreach ($Computer in $PingList) {
        #$EnumerationComputerListBox.Items.Add($Computer)
        $ping = Test-Connection $Computer -Count 1
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Pinging: $Computer")
        $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $ping"
        $LogMessage | Add-Content -Path $LogFile
        if($ping){$EnumerationComputerListBox.Items.Insert(0,"$Computer")}
    }
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Finished with Ping Sweep!")
    #Start-Sleep -Seconds 2
    #$StatusListBox.Items.Clear()
}

#-------------------------------------
# Enumeration - Ping Sweep - GroupBox
#-------------------------------------
# Create a group that will contain your radio buttons
$EnumerationPingSweepGroupBox           = New-Object System.Windows.Forms.GroupBox
$EnumerationPingSweepGroupBox.Location  = New-Object System.Drawing.Size(0,($EnumerationPortScanGroupBox.Location.Y + $EnumerationPortScanGroupBox.Size.Height + $EnumerationGroupGap))
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
    $EnumerationPingSweepNote1Label.Font       = New-Object System.Drawing.Font("$Font",10,1,2,1)
    $EnumerationPingSweepNote1Label.ForeColor  = "Black"
    $EnumerationPingSweepGroupBox.Controls.Add($EnumerationPingSweepNote1Label)

    $EnumerationPingSweepNote2Label            = New-Object System.Windows.Forms.Label
    $EnumerationPingSweepNote2Label.Location   = New-Object System.Drawing.Point(($EnumerationPingSweepNote1Label.Size.Width + 5),($EnumerationPingSweepGroupDownPosition + 4)) 
    $EnumerationPingSweepNote2Label.Size       = New-Object System.Drawing.Size(80,22)
    $EnumerationPingSweepNote2Label.Text       = "(ex: 10.0.0.0/24)"
    $EnumerationPingSweepNote2Label.Font       = New-Object System.Drawing.Font("$Font",9,0,2,1)
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
    $EnumerationPingSweepIPNetworkCIDRTextbox.Font          = New-Object System.Drawing.Font("$Font",11,0,2,1)
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
    $EnumerationPingSweepExecutionButton.Font      = New-Object System.Drawing.Font("$Font",12,0,2,1)
    $EnumerationPingSweepExecutionButton.ForeColor = "Red"
    $EnumerationPingSweepExecutionButton.Add_Click({ 
        Conduct-PingSweep
    })
    $EnumerationPingSweepGroupBox.Controls.Add($EnumerationPingSweepExecutionButton) 

$Section1EnumerationTab.Controls.Add($EnumerationPingSweepGroupBox) 

#============================================================================================================================================================
# Enumeration - Computer List ListBox
#============================================================================================================================================================
$EnumerationComputerListBox               = New-Object System.Windows.Forms.ListBox
$EnumerationComputerListBox.Location      = New-Object System.Drawing.Size(297,10)
$EnumerationComputerListBox.Size          = New-Object System.Drawing.Size(150,480)
$EnumerationComputerListBox.SelectionMode = 'MultiExtended'
$EnumerationComputerListBox.Items.Add("127.0.0.1")
$EnumerationComputerListBox.Items.Add("localhost")
$Section1EnumerationTab.Controls.Add($EnumerationComputerListBox)

#----------------------------------
# Single Host - Add To List Button
#----------------------------------
$EnumerationComputerListBoxAddToListButton           = New-Object System.Windows.Forms.Button
$EnumerationComputerListBoxAddToListButton.Text      = "Add To Computer List"
$EnumerationComputerListBoxAddToListButton.Location  = New-Object System.Drawing.Size(($EnumerationComputerListBox.Location.X - 1),($EnumerationComputerListBox.Location.Y + $EnumerationComputerListBox.Size.Height - 3))
$EnumerationComputerListBoxAddToListButton.Size      = New-Object System.Drawing.Size(($EnumerationComputerListBox.Size.Width + 2),22) 
$EnumerationComputerListBoxAddToListButton.Font      = New-Object System.Drawing.Font("$Font",11,0,2,1)
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
$Section1EnumerationTab.Controls.Add($EnumerationComputerListBoxSelectAllButton) 

#-----------------------------------
# Computer List - Clear List Button
#-----------------------------------
$EnumerationComputerListBoxClearButton               = New-Object System.Windows.Forms.Button
$EnumerationComputerListBoxClearButton.Location      = New-Object System.Drawing.Size($EnumerationComputerListBoxSelectAllButton.Location.X,($EnumerationComputerListBoxSelectAllButton.Location.Y + $EnumerationComputerListBoxSelectAllButton.Size.Height + 4))
$EnumerationComputerListBoxClearButton.Size          = New-Object System.Drawing.Size($EnumerationComputerListBoxSelectAllButton.Size.Width,22)
$EnumerationComputerListBoxClearButton.Text          = 'Clear List'
$EnumerationComputerListBoxClearButton.Add_Click({
    $EnumerationComputerListBox.Items.Clear()
})
$Section1EnumerationTab.Controls.Add($EnumerationComputerListBoxClearButton) 

##############################################################################################################################################################
##
## Section 1 Checklist Tab
##
##############################################################################################################################################################

$Section1ChecklistTab          = New-Object System.Windows.Forms.TabPage
$Section1ChecklistTab.Text     = "Checklist"
$Section1ChecklistTab.Name     = "Checklist Tab"
$Section1ChecklistTab.UseVisualStyleBackColor = $True

#Checks if the Resources Directory is there and loads it if it is
if (Test-Path $PoShHome\Resources\Checklists) {
    $Section1TabControl.Controls.Add($Section1ChecklistTab)
}

# Variable Sizes
$TabRightPosition     = 3
$TabhDownPosition     = 3
$TabAreaWidth         = 446
$TabAreaHeight        = 557

$TextBoxRightPosition = -2 
$TextBoxDownPosition  = -2
$TextBoxWidth         = 442
$TextBoxHeight        = 536


#####################################################################################################################################
##
## Section 1 Checklilst TabControl
##
#####################################################################################################################################

# The TabControl controls the tabs within it
$Section1ChecklistTabControl               = New-Object System.Windows.Forms.TabControl
$Section1ChecklistTabControl.Name          = "Checklist TabControl"
$Section1ChecklistTabControl.Location      = New-Object System.Drawing.Size($TabRightPosition,$TabhDownPosition)
$Section1ChecklistTabControl.Size          = New-Object System.Drawing.Size($TabAreaWidth,$TabAreaHeight) 
$Section1ChecklistTabControl.ShowToolTips  = $True
$Section1ChecklistTabControl.SelectedIndex = 0
$Section1ChecklistTab.Controls.Add($Section1ChecklistTabControl)


############################################################################################################
# Section 1 Checklist SubTab
############################################################################################################

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
    $TabName                                   = $File.BaseName
    $Section1ChecklistSubTab                   = New-Object System.Windows.Forms.TabPage
    $Section1ChecklistSubTab.Text              = "$TabName"
    $Section1ChecklistSubTab.AutoScroll        = $True
    $Section1ChecklistSubTab.UseVisualStyleBackColor = $True
    $Section1ChecklistTabControl.Controls.Add($Section1ChecklistSubTab)

    #-------------------------------------
    # Imports Data and Creates Checkboxes
    #-------------------------------------
    $TabContents = Get-Content -Path $File.FullName -Force | foreach {$_ + "`r`n"}
    foreach ($line in $TabContents) {
        $Checklist          = New-Object System.Windows.Forms.CheckBox
        $Checklist.Text     = "$line"
        $Checklist.Location = New-Object System.Drawing.Size($ChecklistRightPosition,$ChecklistDownPosition) 
        $Checklist.Size     = New-Object System.Drawing.Size($ChecklistBoxWidth,$ChecklistBoxHeight)
        if ($Checklist.Check -eq $True) {
            $Checklist.ForeColor = "Blue"
        }
        $Section1ChecklistSubTab.Controls.Add($Checklist)          

        # Shift the Text and Button's Location
        $ChecklistDownPosition += $ChecklistDownPositionShift
    }

    # Resets the Down Position
    $ChecklistDownPosition = $ChecklistDownPositionStart
}

##############################################################################################################################################################
##
## Section 1 Processes Tab
##
##############################################################################################################################################################
$Section1ProcessesTab          = New-Object System.Windows.Forms.TabPage
$Section1ProcessesTab.Text     = "Processes"
$Section1ProcessesTab.Name     = "Processes Tab"
$Section1ProcessesTab.UseVisualStyleBackColor = $True

#Checks if the Resources Directory is there and loads it if it is
if (Test-Path "$PoShHome\Resources\Process Info") {
    $Section1TabControl.Controls.Add($Section1ProcessesTab)
}

# Variable Sizes
$TabRightPosition       = 3
$TabhDownPosition       = 3
$TabAreaWidth           = 446
$TabAreaHeight          = 557

$TextBoxRightPosition   = -2 
$TextBoxDownPosition    = -2
$TextBoxWidth           = 442
$TextBoxHeight          = 536


#####################################################################################################################################
##
## Section 1 Processes TabControl
##
#####################################################################################################################################

# The TabControl controls the tabs within it
$Section1ProcessesTabControl               = New-Object System.Windows.Forms.TabControl
$Section1ProcessesTabControl.Name          = "Processes TabControl"
$Section1ProcessesTabControl.Location      = New-Object System.Drawing.Size($TabRightPosition,$TabhDownPosition)
$Section1ProcessesTabControl.Size          = New-Object System.Drawing.Size($TabAreaWidth,$TabAreaHeight) 
$Section1ProcessesTabControl.ShowToolTips  = $True
$Section1ProcessesTabControl.SelectedIndex = 0
$Section1ProcessesTab.Controls.Add($Section1ProcessesTabControl)


############################################################################################################
# Section 1 Processes SubTab
############################################################################################################

#------------------------------------
# Auto Creates Tabs and Imports Data
#------------------------------------
# Obtains a list of the files in the resources folder
$ResourceProcessFiles = Get-ChildItem "$PoShHome\Resources\Process Info"

# Iterates through the files and dynamically creates tabs and imports data
foreach ($File in $ResourceProcessFiles) {
    #-----------------------------
    # Creates Tabs From Each File
    #-----------------------------
    $TabName                                   = $File.BaseName
    $Section1ProcessesSubTab                   = New-Object System.Windows.Forms.TabPage
    $Section1ProcessesSubTab.Text              = "$TabName"
    $Section1ProcessesSubTab.UseVisualStyleBackColor = $True
    $Section1ProcessesTabControl.Controls.Add($Section1ProcessesSubTab)

    #-----------------------------
    # Imports Data Into Textboxes
    #-----------------------------
    $TabContents                               = Get-Content -Path $File.FullName -Force | foreach {$_ + "`r`n"} 
    $Section1ProcessesSubTabTextBox            = New-Object System.Windows.Forms.TextBox
    $Section1ProcessesSubTabTextBox.Name       = "$file"
    $Section1ProcessesSubTabTextBox.Location   = New-Object System.Drawing.Size($TextBoxRightPosition,$TextBoxDownPosition) 
    $Section1ProcessesSubTabTextBox.Size       = New-Object System.Drawing.Size($TextBoxWidth,$TextBoxHeight)
    $Section1ProcessesSubTabTextBox.MultiLine  = $True
    $Section1ProcessesSubTabTextBox.ScrollBars = "Vertical"
    $Section1ProcessesSubTabTextBox.Font       = New-Object System.Drawing.Font("$Font",9,0,3,1)
    $Section1ProcessesSubTab.Controls.Add($Section1ProcessesSubTabTextBox)
    $Section1ProcessesSubTabTextBox.Text       = "$TabContents"
}

##############################################################################################################################################################
##
## Section 1 OpNotes Tab
##
##############################################################################################################################################################

# The OpNotes TabPage Window
$Section1OpNotesTab          = New-Object System.Windows.Forms.TabPage
$Section1OpNotesTab.Text     = "OpNotes"
$Section1OpNotesTab.Name     = "OpNotes Tab"
$Section1OpNotesTab.UseVisualStyleBackColor = $True
$Section1TabControl.Controls.Add($Section1OpNotesTab)


# Variable Sizes
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
    for($i = 0; $i -lt $OpNotesListBox.Items.Count; $i++) {
        $OpNotesListBox.SetSelected($i, $true)
    }

    # Saves all OpNotes to file
    Set-Content -Path $OpNotesFile -Value ($OpNotesListBox.SelectedItems) -Force
    
    # Unselects Fields
    for($i = 0; $i -lt $OpNotesListBox.Items.Count; $i++) {
        $OpNotesListBox.SetSelected($i, $false)
    }
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
$OpNotesLabel           = New-Object System.Windows.Forms.Label
$OpNotesLabel.Location  = New-Object System.Drawing.Point($OpNotesRightPosition,$OpNotesDownPosition) 
$OpNotesLabel.Size      = New-Object System.Drawing.Size($OpNotesInputTextBoxWidth,$OpNotesInputTextBoxHeight)
$OpNotesLabel.Text      = "Enter Your OpNotes (Auto-Timestamp):"
$OpNotesLabel.Font      = New-Object System.Drawing.Font("$Font",12,1,3,1)
$OpNotesLabel.ForeColor = "Blue"
$Section1OpNotesTab.Controls.Add($OpNotesLabel)

$OpNotesDownPosition += $OpNotesDownPositionShift

#--------------------------
# OpNotes - Input Text Box
#--------------------------
$OpNotesInputTextBox          = New-Object System.Windows.Forms.TextBox
$OpNotesInputTextBox.Location = New-Object System.Drawing.Size($OpNotesRightPosition,$OpNotesDownPosition)
$OpNotesInputTextBox.Size     = New-Object System.Drawing.Size($OpNotesInputTextBoxWidth,$OpNotesInputTextBoxHeight)
# Press Enter to Input Data
$OpNotesInputTextBox.Add_KeyDown({
    if ($_.KeyCode -eq "Enter") {
        # There must be text in the input to make an entry
        if ($OpNotesInputTextBox.Text -ne "") {
            OpNoteTextBoxEntry
        }
    }
})
$Section1OpNotesTab.Controls.Add($OpNotesInputTextBox)

$OpNotesDownPosition += $OpNotesDownPositionShift

#----------------------
# OpNotes - Add Button
#----------------------
$OpNotesAddButton           = New-Object System.Windows.Forms.Button
$OpNotesAddButton.Text      = "Add"
$OpNotesAddButton.Location  = New-Object System.Drawing.Size($OpNotesRightPosition,$OpNotesDownPosition)
$OpNotesAddButton.Size      = New-Object System.Drawing.Size($OpNotesButtonWidth,$OpNotesButtonHeight)
$OpNotesAddButton.Font      = New-Object System.Drawing.Font("$Font",11,0,2,1)
$OpNotesAddButton.ForeColor = "Green"
$OpNotesAddButton.Add_Click({
    # There must be text in the input to make an entry
    if ($OpNotesInputTextBox.Text -ne "") { OpNoteTextBoxEntry }    
})
$Section1OpNotesTab.Controls.Add($OpNotesAddButton) 


# Shift Right
$OpNotesRightPosition += $OpNotesRightPositionShift


#-----------------------------
# OpNotes - Select All Button
#-----------------------------
$OpNotesAddButton          = New-Object System.Windows.Forms.Button
$OpNotesAddButton.Text     = "Select All"
$OpNotesAddButton.Location = New-Object System.Drawing.Size($OpNotesRightPosition,$OpNotesDownPosition)
$OpNotesAddButton.Size     = New-Object System.Drawing.Size($OpNotesButtonWidth,$OpNotesButtonHeight)
$OpNotesAddButton.Add_Click({
    for($i = 0; $i -lt $OpNotesListBox.Items.Count; $i++) {
        $OpNotesListBox.SetSelected($i, $true)
    }
})
$Section1OpNotesTab.Controls.Add($OpNotesAddButton) 


# Shift Right
$OpNotesRightPosition += $OpNotesRightPositionShift


#-------------------------------
# OpNotes - Open OpNotes Button
#-------------------------------
$OpNotesOpenListBox          = New-Object System.Windows.Forms.Button
$OpNotesOpenListBox.Text     = "Open OpNotes"
$OpNotesOpenListBox.Location = New-Object System.Drawing.Size($OpNotesRightPosition,$OpNotesDownPosition)
$OpNotesOpenListBox.Size     = New-Object System.Drawing.Size($OpNotesButtonWidth,$OpNotesButtonHeight) 
$OpNotesOpenListBox.Add_Click({
    Invoke-Item -Path "$PoShHome\OpNotes.txt"
})
$Section1OpNotesTab.Controls.Add($OpNotesOpenListBox)


# Shift Right
$OpNotesRightPosition += $OpNotesRightPositionShift


#--------------------------
# OpNotes - Move Up Button
#--------------------------
$OpNotesMoveUpButton               = New-Object System.Windows.Forms.Button
$OpNotesMoveUpButton.Location      = New-Object System.Drawing.Size($OpNotesRightPosition,$OpNotesDownPosition)
$OpNotesMoveUpButton.Size          = New-Object System.Drawing.Size($OpNotesButtonWidth,$OpNotesButtonHeight)
$OpNotesMoveUpButton.Text          = 'Move Up'
$OpNotesMoveUpButton.Add_Click({
    # only if the first item isn't the current one
    if($OpNotesListBox.SelectedIndex -gt 0)
    {
        $OpNotesListBox.BeginUpdate()
        #Get starting position
        $pos = $OpNotesListBox.selectedIndex
        # add a duplicate of original item up in the listbox
        $OpNotesListBox.items.insert($pos -1,$OpNotesListBox.Items.Item($pos))
        # make it the current item
        $OpNotesListBox.SelectedIndex = ($pos -1)
        # delete the old occurrence of this item
        $OpNotesListBox.Items.RemoveAt($pos +1)
        $OpNotesListBox.EndUpdate()
    }
    else {
       #Top of list, beep
       [console]::beep(500,100)
    }
    Save-OpNotes
})
$Section1OpNotesTab.Controls.Add($OpNotesMoveUpButton) 


# Shift Down
$OpNotesDownPosition += $OpNotesDownPositionShift

# Move Position back to left
$OpNotesRightPosition = $OpNotesRightPositionStart

#----------------------------------
# OpNotes - Remove Selected Button
#----------------------------------
$OpNotesRemoveButton               = New-Object System.Windows.Forms.Button
$OpNotesRemoveButton.Location      = New-Object System.Drawing.Size($OpNotesRightPosition,$OpNotesDownPosition)
$OpNotesRemoveButton.Size          = New-Object System.Drawing.Size($OpNotesButtonWidth,$OpNotesButtonHeight)
$OpNotesRemoveButton.Text          = 'Remove'
$OpNotesRemoveButton.Add_Click({
    $OpNotesListBox.Items.Remove($OpNotesListBox.SelectedItem)
    Save-OpNotes
})
$Section1OpNotesTab.Controls.Add($OpNotesRemoveButton) 


# Shift Right
$OpNotesRightPosition += $OpNotesRightPositionShift


#--------------------------------
# OpNotes - Create Report Button
#--------------------------------
$OpNotesCreateReportButton          = New-Object System.Windows.Forms.Button
$OpNotesCreateReportButton.Location = New-Object System.Drawing.Size($OpNotesRightPosition,$OpNotesDownPosition)
$OpNotesCreateReportButton.Size     = New-Object System.Drawing.Size($OpNotesButtonWidth,$OpNotesButtonHeight)
$OpNotesCreateReportButton.Text     = "Create Report"
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


# Shift Right
$OpNotesRightPosition += $OpNotesRightPositionShift


#-------------------------------
# OpNotes - Open Reports Button
#-------------------------------
$OpNotesOpenListBox          = New-Object System.Windows.Forms.Button
$OpNotesOpenListBox.Text     = "Open Reports"
$OpNotesOpenListBox.Location = New-Object System.Drawing.Size($OpNotesRightPosition,$OpNotesDownPosition)
$OpNotesOpenListBox.Size     = New-Object System.Drawing.Size($OpNotesButtonWidth,$OpNotesButtonHeight) 
$OpNotesOpenListBox.Add_Click({
    Invoke-Item -Path "$PoShHome\Reports"
})
$Section1OpNotesTab.Controls.Add($OpNotesOpenListBox)

# Shift Right
$OpNotesRightPosition += $OpNotesRightPositionShift


#----------------------------
# OpNotes - Move Down Button
#----------------------------
$OpNotesMoveDownButton               = New-Object System.Windows.Forms.Button
$OpNotesMoveDownButton.Location      = New-Object System.Drawing.Size($OpNotesRightPosition,$OpNotesDownPosition)
$OpNotesMoveDownButton.Size          = New-Object System.Drawing.Size($OpNotesButtonWidth,$OpNotesButtonHeight)
$OpNotesMoveDownButton.Text          = 'Move Down'
$OpNotesMoveDownButton.Add_Click({
    #only if the last item isn't the current one
    if(($OpNotesListBox.SelectedIndex -ne -1) -and ($OpNotesListBox.SelectedIndex -lt $OpNotesListBox.Items.Count - 1) ) {
        $OpNotesListBox.BeginUpdate()
        #Get starting position 
        $pos = $OpNotesListBox.selectedIndex
        # add a duplicate of item below in the listbox
        $OpNotesListBox.items.insert($pos,$OpNotesListBox.Items.Item($pos +1))
        # delete the old occurrence of this item
        $OpNotesListBox.Items.RemoveAt($pos +2 )
        # move to current item
        $OpNotesListBox.SelectedIndex = ($pos +1)
        $OpNotesListBox.EndUpdate()
    }
    else {
       #Bottom of list, beep
       [console]::beep(500,100)
    }
    Save-OpNotes
})
$Section1OpNotesTab.Controls.Add($OpNotesMoveDownButton) 

$OpNotesDownPosition += $OpNotesDownPositionShift

#-------------------
# OpNotes - ListBox
#-------------------
$OpNotesListBox                     = New-Object System.Windows.Forms.ListBox
$OpNotesListBox.Name                = "OpNotesListBox"
$OpNotesListBox.Location            = New-Object System.Drawing.Size($OpNotesRightPositionStart,($OpNotesDownPosition + 5)) 
$OpNotesListBox.Size                = New-Object System.Drawing.Size($OpNotesMainTextBoxWidth,$OpNotesMainTextBoxHeight)
$OpNotesListBox.Font                = New-Object System.Drawing.Font("$Font",11,0,2,1)
$OpNotesListBox.FormattingEnabled   = $True
$OpNotesListBox.SelectionMode       = 'MultiExtended'
$OpNotesListBox.ScrollAlwaysVisible = $True
$OpNotesListBox.AutoSize            = $false
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

##############################################################################################################################################################
##
## Section 1 About Tab
##
##############################################################################################################################################################
$Section1AboutTab          = New-Object System.Windows.Forms.TabPage
$Section1AboutTab.Text     = "About"
$Section1AboutTab.Name     = "About Tab"
$Section1AboutTab.UseVisualStyleBackColor = $True

#Checks if the Resources Directory is there and loads it if it is
if (Test-Path $PoShHome\Resources\About) {
    $Section1TabControl.Controls.Add($Section1AboutTab)
}

# Variable Sizes
$TabRightPosition       = 3
$TabhDownPosition       = 3
$TabAreaWidth           = 446
$TabAreaHeight          = 557

$TextBoxRightPosition   = -2 
$TextBoxDownPosition    = -2
$TextBoxWidth           = 442
$TextBoxHeight          = 536


#####################################################################################################################################
##
## Section 1 About TabControl
##
#####################################################################################################################################

# The TabControl controls the tabs within it
$Section1AboutTabControl               = New-Object System.Windows.Forms.TabControl
$Section1AboutTabControl.Name          = "About TabControl"
$Section1AboutTabControl.Location      = New-Object System.Drawing.Size($TabRightPosition,$TabhDownPosition)
$Section1AboutTabControl.Size          = New-Object System.Drawing.Size($TabAreaWidth,$TabAreaHeight) 
$Section1AboutTabControl.ShowToolTips  = $True
$Section1AboutTabControl.SelectedIndex = 0
$Section1AboutTab.Controls.Add($Section1AboutTabControl)

############################################################################################################
# Section 1 About SubTab
############################################################################################################

#------------------------------------
# Auto Creates Tabs and Imports Data
#------------------------------------
# Obtains a list of the files in the resources folder
$ResourceProcessFiles = Get-ChildItem "$PoShHome\Resources\About"

# Iterates through the files and dynamically creates tabs and imports data
foreach ($File in $ResourceProcessFiles) {
    #-----------------------------
    # Creates Tabs From Each File
    #-----------------------------
    $TabName                               = $File.BaseName
    $Section1AboutSubTab                   = New-Object System.Windows.Forms.TabPage
    $Section1AboutSubTab.Text              = "$TabName"
    $Section1AboutSubTab.UseVisualStyleBackColor = $True
    $Section1AboutTabControl.Controls.Add($Section1AboutSubTab)

    #-----------------------------
    # Imports Data Into Textboxes
    #-----------------------------
    $TabContents                           = Get-Content -Path $File.FullName -Force | foreach {$_ + "`r`n"} 
    $Section1AboutSubTabTextBox            = New-Object System.Windows.Forms.TextBox
    $Section1AboutSubTabTextBox.Name       = "$file"
    $Section1AboutSubTabTextBox.Location   = New-Object System.Drawing.Size($TextBoxRightPosition,$TextBoxDownPosition) 
    $Section1AboutSubTabTextBox.Size       = New-Object System.Drawing.Size($TextBoxWidth,$TextBoxHeight)
    $Section1AboutSubTabTextBox.MultiLine  = $True
    $Section1AboutSubTabTextBox.ScrollBars = "Vertical"
    $Section1AboutSubTabTextBox.Font       = New-Object System.Drawing.Font("Courier New",7.5,0,0,0)
    $Section1AboutSubTab.Controls.Add($Section1AboutSubTabTextBox)
    $Section1AboutSubTabTextBox.Text       = "$TabContents"
}



##############################################################################################################################################################
##############################################################################################################################################################
##
## Section 2 Tab Control
##
##############################################################################################################################################################
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

$PoShACME.Controls.Add($Section2TabControl)

##############################################################################################################################################################
##
## Section 2 Main SubTab
##
##############################################################################################################################################################
$Section2MainTab          = New-Object System.Windows.Forms.TabPage
$Section2MainTab.Text     = "Main"
$Section2MainTab.Name     = "Main"
$Section2MainTab.UseVisualStyleBackColor = $True
$Section2TabControl.Controls.Add($Section2MainTab)

#============================================================================================================================================================
# Functions used for commands/queries
#============================================================================================================================================================
# Varables to Control Column 3
$Column3RightPosition     = 3
$Column3DownPosition      = 11
$Column3BoxWidth          = 300
$Column3BoxHeight         = 22
$Column3DownPositionShift = 26

#---------------------------------------------------
# Single Host - Enter A Single Hostname/IP Checkbox
#---------------------------------------------------
# This checkbox highlights when selecing computers from the ComputerList
$SingleHostIPCheckBox          = New-Object System.Windows.Forms.Checkbox
$SingleHostIPCheckBox.Name     = "Query A Single Hostname/IP:"
$SingleHostIPCheckBox.Text     = "$($SingleHostIPCheckBox.Name)"
$SingleHostIPCheckBox.Location = New-Object System.Drawing.Size(3,11) 
$SingleHostIPCheckBox.Size     = New-Object System.Drawing.Size(210,$Column3BoxHeight)
$SingleHostIPCheckBox.Enabled  = $true
$SingleHostIPCheckBox.Font     = [System.Drawing.Font]::new("$Font", 8, [System.Drawing.FontStyle]::Bold)
$SingleHostIPCheckBox.Add_Click({
    if ($SingleHostIPCheckBox.Checked -eq $true){
        $ComputerListTreeView.Enabled   = $false
        $ComputerListTreeView.BackColor = "lightgray"
    }
    elseif ($SingleHostIPCheckBox.Checked -eq $false) {
        $SingleHostIPTextBox.Text       = "<Type In A Hostname / IP>"
        $ComputerListTreeView.Enabled   = $true
        $ComputerListTreeView.BackColor = "white"
    }
})
$Section2MainTab.Controls.Add($SingleHostIPCheckBox)

#----------------------------------
# Single Host - Add To List Button
#----------------------------------
$SingleHostIPAddButton          = New-Object System.Windows.Forms.Button
$SingleHostIPAddButton.Text     = "Add To List"
$SingleHostIPAddButton.Location = New-Object System.Drawing.Size(($Column3RightPosition + 240),$Column3DownPosition)
$SingleHostIPAddButton.Size     = New-Object System.Drawing.Size(115,$Column3BoxHeight) 
$SingleHostIPAddButton.Add_Click({
    # Conducts a simple input check for default or blank data
    if (($SingleHostIPTextBox.Text -ne '<Type In A Hostname / IP>') -and ($SingleHostIPTextBox.Text -ne '')) {
        # Adds the hostname/ip entered into the collection list box
        $value = "Manually Added"
        Add-ComputerNode -RootNode $script:TreeNodeComputerList -Category $value -Entry $SingleHostIPTextBox.Text -ToolTip 'Manually Added'
        $ComputerListTreeView.ExpandAll()
        # Clears Textbox
        $SingleHostIPTextBox.Text = "<Type In A Hostname / IP>"
        # Auto checks/unchecks various checkboxes for visual status indicators
        $SingleHostIPCheckBox.Checked = $false
    }
})
$Section2MainTab.Controls.Add($SingleHostIPAddButton) 

$Column3DownPosition += $Column3DownPositionShift

#------------------------------------
# Single Host - Input Check Function
#------------------------------------
function SingleHostInputCheck {
    if (($SingleHostIPTextBox.Text -ne '<Type In A Hostname / IP>') -and ($SingleHostIPTextBox.Text -ne '') ) {
        # Auto checks/unchecks various checkboxes for visual status indicators
        $SingleHostIPCheckBox.Checked = $true

        . SingleEntry

        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Collect Data From:")
        foreach ($Computer in $ComputerList) {
            $ResultsListBox.Items.Add("$Computer")
        }
    }
    if ($SingleHostIPCheckBox.Checked -eq $true){
        $ComputerListBox.Enabled   = $false
        $ComputerListBox.BackColor = "lightgray"
    }
    elseif ($SingleHostIPCheckBox.Checked -eq $false) {
        $SingleHostIPTextBox.Text  = "<Type In A Hostname / IP>"
        $ComputerListBox.Enabled   = $true
        $ComputerListBox.BackColor = "white"
    }
}

#-----------------------------------------------
# Single Host - <Type In A Hostname / IP> Textbox
#-----------------------------------------------
$SingleHostIPTextBox          = New-Object System.Windows.Forms.TextBox
$SingleHostIPTextBox.Text     = "<Type In A Hostname / IP>"
$SingleHostIPTextBox.Location = New-Object System.Drawing.Size($Column3RightPosition,($Column3DownPosition + 1))
$SingleHostIPTextBox.Size     = New-Object System.Drawing.Size(235,$Column3BoxHeight)
$SingleHostIPTextBox.Add_KeyDown({
    if ($_.KeyCode -eq "Enter") {
        SingleHostInputCheck
    }
})
$Section2MainTab.Controls.Add($SingleHostIPTextBox)


#--------------------------------------
# Single Host - Collect Entered Button
#--------------------------------------
$SingleHostIPOKButton          = New-Object System.Windows.Forms.Button
$SingleHostIPOKButton.Text     = "Single Collection"
$SingleHostIPOKButton.Location = New-Object System.Drawing.Size(($Column3RightPosition + 240),$Column3DownPosition)
$SingleHostIPOKButton.Size     = New-Object System.Drawing.Size(115,$Column3BoxHeight) 
$SingleHostIPOKButton.Add_Click({
    $SingleHostIPCheckBox.Checked = $true
    SingleHostInputCheck
})
$Section2MainTab.Controls.Add($SingleHostIPOKButton) 


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
$DirectoryListLabel.Font      = [System.Drawing.Font]::new($font, 9, [System.Drawing.FontStyle]::Bold)
$DirectoryListLabel.Text      = "Results Folder:"
$DirectoryListLabel.ForeColor = "Black"
$Section2MainTab.Controls.Add($DirectoryListLabel)

#------------------------------------------
# Directory Location - Open Results Button
#------------------------------------------
$DirectoryOpenListBox          = New-Object System.Windows.Forms.Button
$DirectoryOpenListBox.Text     = "Open Results"
$DirectoryOpenListBox.Location = New-Object System.Drawing.Size(($Column3RightPosition + 120),$Column3DownPosition)
$DirectoryOpenListBox.Size     = New-Object System.Drawing.Size(115,$Column3BoxHeight) 
$Section2MainTab.Controls.Add($DirectoryOpenListBox)

$DirectoryOpenListBox.Add_Click({
    Invoke-Item -Path $CollectedDataDirectory
})

#-------------------------------------------
# Directory Location - New Timestamp Button
#-------------------------------------------
$DirectoryUpdateListBox              = New-Object System.Windows.Forms.Button
$DirectoryUpdateListBox.Text         = "New Timestamp"
$DirectoryUpdateListBox.Location     = New-Object System.Drawing.Size(($Column3RightPosition + 240),$Column3DownPosition)
$DirectoryUpdateListBox.Size         = New-Object System.Drawing.Size(115,$Column3BoxHeight) 
$Section2MainTab.Controls.Add($DirectoryUpdateListBox) 
#$DirectoryUpdateListBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") {} })

$DirectoryUpdateListBox.Add_Click({
    $CollectedDataTimeStampDirectory = "$CollectedDataDirectory\$((Get-Date).ToString('yyyy-MM-dd @ HHmm ss'))"
    $CollectionSavedDirectoryTextBox.Text  = $CollectedDataTimeStampDirectory
})

# Shift Row Location
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
$ResultsSectionLabel.Font      = [System.Drawing.Font]::new($font, 9, [System.Drawing.FontStyle]::Bold)
$ResultsSectionLabel.Text      = "Choose How To View Results"
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
$Section2MainTab.Controls.Add($OpenResultsButton)

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

# Shift Row Location
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
$Section2MainTab.Controls.Add($CompareButton)

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
        $CompareCsvFilesForm.Controls.Add($DropDownField)

        #------------------
        # Drop Down Button
        #------------------
        $DropDownButton          = New-Object System.Windows.Forms.Button
        $DropDownButton.Location = New-Object System.Drawing.Size(10,($DropDownField.Location.y + $DropDownField.Size.Height + 10))
        $DropDownButton.Size     = New-Object System.Drawing.Size(100,20)
        $DropDownButton.Text     = "Execute"
        $DropDownButton.Add_Click({CompareCsvFilesFormReturn-DropDown})
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
        | Out-GridView -OutputMode Multiple | Set-Variable -Name CompareImportResults

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
    }
    Save-OpNotes

    } # End If Statement for Compare CSV Reference
    } # End If Statement for Compare CSV Difference
})

#============================================================================================================================================================
# Custom View Chart
#============================================================================================================================================================
#-------------------
# View Chart Button
#-------------------
$ViewChartButton          = New-Object System.Windows.Forms.Button
$ViewChartButton.Name     = "Build Chart"
$ViewChartButton.Text     = "$($ViewChartButton.Name)"
$ViewChartButton.UseVisualStyleBackColor = $True
$ViewChartButton.Location = New-Object System.Drawing.Size(($CompareButton.Location.X + $CompareButton.Size.Width + 5),$CompareButton.Location.Y)
$ViewChartButton.Size     = New-Object System.Drawing.Size(115,22)
$Section2MainTab.Controls.Add($ViewChartButton)

$ViewChartButton.Add_Click({
    # Open File
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    $ViewChartOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $ViewChartOpenFileDialog.Title = "Open File To View As A Chart"
    $ViewChartOpenFileDialog.InitialDirectory = "$CollectedDataDirectory"
    $ViewChartOpenFileDialog.filter = "CSV (*.csv)| *.csv|Excel (*.xlsx)| *.xlsx|Excel (*.xls)| *.xls|All files (*.*)|*.*"
    $ViewChartOpenFileDialog.ShowDialog() | Out-Null
    $ViewChartOpenFileDialog.ShowHelp = $true

    #====================================
    # Custom View Chart Command Function
    #====================================
    function ViewChartCommand {
        #https://bytecookie.wordpress.com/2012/04/13/tutorial-powershell-and-microsoft-chart-controls-or-how-to-spice-up-your-reports/
        # PowerShell v3+ OR PowerShell v2 with Microsoft Chart Controls for Microsoft .NET Framework 3.5 Installed

        Function Invoke-SaveDialog {
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
            $ViewChartForm.controls.add($Chart)
            $Chart.Anchor = $AnchorAll
        #-------------------------------
        # Custom View Chart Save Button
        #-------------------------------
            $SaveButton        = New-Object Windows.Forms.Button
            $SaveButton.Text   = "Save"
            $SaveButton.Top    = 420
            $SaveButton.Left   = 600
            $SaveButton.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
             [enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
            $SaveButton.Add_Click({
                $Result = Invoke-SaveDialog
                If ($Result) { $Chart.SaveImage($Result.FileName, $Result.Extension) }
            }) 
        $ViewChartForm.controls.add($SaveButton)
        $ViewChartForm.Add_Shown({$ViewChartForm.Activate()})
        [void]$ViewChartForm.ShowDialog()
        #---------------------------------------
        # Custom View Chart - Autosave an Image
        #---------------------------------------
        #$Chart.SaveImage('C:\temp\chart.jpeg', 'jpeg')
    }

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
            $ViewChartSelectionForm.Controls.Add($ViewChartChartTypesComboBox) 

            #---------------------------------------
            # Custom View Chart Limit Results Label
            #---------------------------------------
            $ViewChartLimitResultsLabel          = New-Object System.Windows.Forms.Label
            $ViewChartLimitResultsLabel.Location = New-Object System.Drawing.Size(10,($ViewChartChartTypesComboBox.Location.y + $ViewChartChartTypesComboBox.Size.Height + 8)) 
            $ViewChartLimitResultsLabel.size     = New-Object System.Drawing.Size(120,25) 
            $ViewChartLimitResultsLabel.Text     = "Limit Results to:"
            $ViewChartSelectionForm.Controls.Add($ViewChartLimitResultsLabel)

            #-----------------------------------------
            # Custom View Chart Limit Results Textbox
            #-----------------------------------------
            $ViewChartLimitResultsTextBox          = New-Object System.Windows.Forms.TextBox
            $ViewChartLimitResultsTextBox.Text     = 10
            $ViewChartLimitResultsTextBox.Location = New-Object System.Drawing.Size(135,($ViewChartChartTypesComboBox.Location.y + $ViewChartChartTypesComboBox.Size.Height + 5))
            $ViewChartLimitResultsTextBox.Size     = New-Object System.Drawing.Size(60,25)
            $ViewChartLimitResultsTextBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") {ViewChartExecute} })
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
                
                ### Descending Radio Button
                $ViewChartDescendingRadioButton          = New-Object System.Windows.Forms.RadioButton
                $ViewChartDescendingRadioButton.Location = New-Object System.Drawing.Size(20,38)
                $ViewChartDescendingRadioButton.size     = '250,25'
                $ViewChartDescendingRadioButton.Checked  = $true
                $ViewChartDescendingRadioButton.Text     = "Descending / Highest to Lowest"
                
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
                $ViewChartLegendCheckBox.Font     = [System.Drawing.Font]::new("$Font", 8, [System.Drawing.FontStyle]::Bold)

                ### View Chart 3D Chart CheckBox
                $ViewChart3DChartCheckBox          = New-Object System.Windows.Forms.Checkbox
                $ViewChart3DChartCheckBox.Location = New-Object System.Drawing.Size(10,38)
                $ViewChart3DChartCheckBox.Size     = '85,25'
                $ViewChart3DChartCheckBox.Checked  = $false
                $ViewChart3DChartCheckBox.Enabled  = $true
                $ViewChart3DChartCheckBox.Text     = "3D Chart"
                $ViewChart3DChartCheckBox.Font     = [System.Drawing.Font]::new("$Font", 8, [System.Drawing.FontStyle]::Bold)
                
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
            #---------------------------------------------
            # Custom View Chart Execute Button Note Label
            #---------------------------------------------
            $ViewChartExecuteButtonNoteLabel          = New-Object System.Windows.Forms.Label
            $ViewChartExecuteButtonNoteLabel.Location = New-Object System.Drawing.Size(10,($ViewChartSortOrderGroupBox.Location.y + $ViewChartSortOrderGroupBox.Size.Height + 8)) 
            $ViewChartExecuteButtonNoteLabel.size     = New-Object System.Drawing.Size(190,25) 
            $ViewChartExecuteButtonNoteLabel.Text     = "Note: Press execute again if the desired chart did not appear."
            $ViewChartSelectionForm.Controls.Add($ViewChartExecuteButtonNoteLabel)

            $ViewChartSelectionForm.Controls.Add($ViewChartExecuteButton)   
            [void] $ViewChartSelectionForm.ShowDialog()
        }
        $Property = $null
        $Property = ViewChartSelectProperty
    }
}) 


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
    $AutoChartsSelectionForm        = New-Object System.Windows.Forms.Form
    $AutoChartsSelectionForm.width  = 327
    $AutoChartsSelectionForm.height = 243 
    $AutoChartsSelectionForm.StartPosition = "CenterScreen"
    $AutoChartsSelectionForm.Text   = ”View Chart - Select Fields ”
    $AutoChartsSelectionForm.Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$ResourcesDirectory\favicon.ico")
    $AutoChartsSelectionForm.ControlBox = $true

    #------------------------------
    # Auto Create Charts Main Label
    #------------------------------
    $AutoChartsMainLabel          = New-Object System.Windows.Forms.Label
    $AutoChartsMainLabel.Location = New-Object System.Drawing.Size(10,10) 
    $AutoChartsMainLabel.size     = New-Object System.Drawing.Size(290,25) 
    $AutoChartsMainLabel.Text     = "This Will Auto Create Varios Charts From Past Collections."
    $AutoChartsSelectionForm.Controls.Add($AutoChartsMainLabel)

    #------------------------------------
    # Auto Create Charts Series GroupBox
    #------------------------------------
    # Create a group that will contain your radio buttons
    $AutoChartsSeriesGroupBox          = New-Object System.Windows.Forms.GroupBox
    $AutoChartsSeriesGroupBox.Location = New-Object System.Drawing.Size(10,($AutoChartsMainLabel.Location.y + $AutoChartsMainLabel.Size.Height + 8))
    $AutoChartsSeriesGroupBox.size     = '185,90'
    $AutoChartsSeriesGroupBox.text     = "Select Collection Series to View:`n(if Available)"

        ### View Chart Baseline Checkbox
        $AutoChartsBaselineCheckBox          = New-Object System.Windows.Forms.Checkbox
        $AutoChartsBaselineCheckBox.Location = New-Object System.Drawing.Size(10,15)
        $AutoChartsBaselineCheckBox.Size     = '165,25'
        $AutoChartsBaselineCheckBox.Checked  = $flase
        $AutoChartsBaselineCheckBox.Enabled  = $true
        $AutoChartsBaselineCheckBox.Text     = "Baseline"
        $AutoChartsBaselineCheckBox.Font     = [System.Drawing.Font]::new("$Font", 8, [System.Drawing.FontStyle]::Bold)

        ### View Chart Previous Checkbox
        $AutoChartsPreviousCheckBox          = New-Object System.Windows.Forms.Checkbox
        $AutoChartsPreviousCheckBox.Location = New-Object System.Drawing.Size(10,38)
        $AutoChartsPreviousCheckBox.Size     = '165,25'
        $AutoChartsPreviousCheckBox.Checked  = $false
        $AutoChartsPreviousCheckBox.Enabled  = $true
        $AutoChartsPreviousCheckBox.Text     = "Previous"
        $AutoChartsPreviousCheckBox.Font     = [System.Drawing.Font]::new("$Font", 8, [System.Drawing.FontStyle]::Bold)

        ### View Chart Most Recent Checkbox
        $AutoChartsMostRecentCheckBox          = New-Object System.Windows.Forms.Checkbox
        $AutoChartsMostRecentCheckBox.Location = New-Object System.Drawing.Size(10,61)
        $AutoChartsMostRecentCheckBox.Size     = '165,25'
        $AutoChartsMostRecentCheckBox.Checked  = $true
        $AutoChartsMostRecentCheckBox.Enabled  = $true
        $AutoChartsMostRecentCheckBox.Text     = "Most Recent"
        $AutoChartsMostRecentCheckBox.Font     = [System.Drawing.Font]::new("$Font", 8, [System.Drawing.FontStyle]::Bold)                

        $AutoChartsSeriesGroupBox.Controls.AddRange(@($AutoChartsBaselineCheckBox,$AutoChartsPreviousCheckBox,$AutoChartsMostRecentCheckBox))
    $AutoChartsSelectionForm.Controls.Add($AutoChartsSeriesGroupBox) 

    #------------------------------------
    # Auto Create Charts Options GroupBox
    #------------------------------------
    # Create a group that will contain your radio buttons
    $AutoChartsOptionsGroupBox          = New-Object System.Windows.Forms.GroupBox
    $AutoChartsOptionsGroupBox.Location = New-Object System.Drawing.Size(($AutoChartsSeriesGroupBox.Location.X + $AutoChartsSeriesGroupBox.Size.Width + 5),($AutoChartsSeriesGroupBox.Location.Y))
    $AutoChartsOptionsGroupBox.size     = '100,90'
    $AutoChartsOptionsGroupBox.text     = "Options:"

        ### View Chart Legend CheckBox
        $AutoChartsLegendCheckBox          = New-Object System.Windows.Forms.Checkbox
        $AutoChartsLegendCheckBox.Location = New-Object System.Drawing.Size(10,15)
        $AutoChartsLegendCheckBox.Size     = '85,25'
        $AutoChartsLegendCheckBox.Checked  = $true
        $AutoChartsLegendCheckBox.Enabled  = $true
        $AutoChartsLegendCheckBox.Text     = "Legend"
        $AutoChartsLegendCheckBox.Font     = [System.Drawing.Font]::new("$Font", 8, [System.Drawing.FontStyle]::Bold)

        ### View Chart 3D Chart CheckBox
        $AutoCharts3DChartCheckBox          = New-Object System.Windows.Forms.Checkbox
        $AutoCharts3DChartCheckBox.Location = New-Object System.Drawing.Size(10,38)
        $AutoCharts3DChartCheckBox.Size     = '85,25'
        $AutoCharts3DChartCheckBox.Checked  = $false
        $AutoCharts3DChartCheckBox.Enabled  = $true
        $AutoCharts3DChartCheckBox.Text     = "3D Chart"
        $AutoCharts3DChartCheckBox.Font     = [System.Drawing.Font]::new("$Font", 8, [System.Drawing.FontStyle]::Bold)
                
        $AutoChartsOptionsGroupBox.Controls.AddRange(@($AutoChartsLegendCheckBox,$AutoCharts3DChartCheckBox))
    $AutoChartsSelectionForm.Controls.Add($AutoChartsOptionsGroupBox) 

    #----------------------------------
    # Auto Chart Select Color ComboBox
    #----------------------------------
    $AutoChartColorSchemeSelectionComboBox          = New-Object System.Windows.Forms.ComboBox
    $AutoChartColorSchemeSelectionComboBox.Location = New-Object System.Drawing.Size(10,($AutoChartsMainLabel.Location.y + $AutoChartsMainLabel.Size.Height + 108))
    $AutoChartColorSchemeSelectionComboBox.Size     = New-Object System.Drawing.Size(185,25)
    $AutoChartColorSchemeSelectionComboBox.Text     = "Select Alternate Color Scheme"
    $AutoChartColorSchemeSelectionComboBox.AutoCompleteSource = "ListItems"
    $AutoChartColorSchemeSelectionComboBox.AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
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
    $AutoChartsSelectionForm.Controls.Add($AutoChartColorSchemeSelectionComboBox) 

    #----------------------------------
    # Auto Chart Select Chart ComboBox
    #----------------------------------
    $AutoChartSelectChartComboBox          = New-Object System.Windows.Forms.ComboBox
    $AutoChartSelectChartComboBox.Location = New-Object System.Drawing.Size(10,($AutoChartColorSchemeSelectionComboBox.Location.y + $AutoChartColorSchemeSelectionComboBox.Size.Height + 10))
    $AutoChartSelectChartComboBox.Size     = New-Object System.Drawing.Size(185,25)
    $AutoChartSelectChartComboBox.Text     = "Select A Chart"
    $AutoChartSelectChartComboBox.AutoCompleteSource = "ListItems"
    $AutoChartSelectChartComboBox.AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
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
    $AutoChartsSelectionForm.Controls.Add($AutoChartSelectChartComboBox) 

    #-----------------------------------
    # Auto Create Charts Execute Button
    #-----------------------------------
    $AutoChartsExecuteButton          = New-Object System.Windows.Forms.Button
    $AutoChartsExecuteButton.Location = New-Object System.Drawing.Size(200,($AutoChartsMainLabel.Location.y + $AutoChartsMainLabel.Size.Height + 107))
    $AutoChartsExecuteButton.Size     = New-Object System.Drawing.Size(101,54)
    $AutoChartsExecuteButton.Text     = "View Chart"
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

            #####################################################################################################################################
            ##
            ## Auto Create Charts TabControl
            ##
            #####################################################################################################################################

            # The TabControl controls the tabs within it
            $AutoChartsTabControl               = New-Object System.Windows.Forms.TabControl
            $AutoChartsTabControl.Name          = "Auto Charts"
            $AutoChartsTabControl.Text          = "Auto Charts"
            $AutoChartsTabControl.Location      = New-Object System.Drawing.Size(5,5)
            $AutoChartsTabControl.Size          = New-Object System.Drawing.Size(1135,590) 
            $AutoChartsTabControl.ShowToolTips  = $True
            $AutoChartsTabControl.SelectedIndex = 0
            $AutoChartsTabControl.Anchor        = $AnchorAll
            $AutoChartsForm.Controls.Add($AutoChartsTabControl)

            # These functions contains the commands to generate specific auto charts        
            function AutoChartsCommandLogonInfo {
                AutoChartsCommand -QueryName "Logon Info" -QueryTabName "Logged On Accounts" -PropertyX Name -PropertyY PSComputerName -ChartType1 'Column' -ChartType2_3 'Point' -MarkerStyle1 'None' -MarkerStyle2 'Square' -MarkerStyle3 'Diamond'
                AutoChartsCommand -QueryName "Logon Info" -QueryTabName "Number of Accounts Logged In To Computers" -PropertyX PSComputerName -PropertyY Name -ChartType1 'Column' -ChartType2_3 'Point' -MarkerStyle1 'None' -MarkerStyle2 'Square' -MarkerStyle3 'Diamond'
            }
            function AutoChartsCommandMappedDrives {
                AutoChartsCommand -QueryName "Mapped Drives" -QueryTabName "Number of Mapped Drives per Server" -PropertyX PSComputerName -PropertyY ProviderName -ChartType1 'Column' -ChartType2_3 'Point' -MarkerStyle1 'None' -MarkerStyle2 'Square' -MarkerStyle3 'Diamond'
                AutoChartsCommand -QueryName "Mapped Drives" -QueryTabName "Number of Servers to Mapped Drives" -PropertyX ProviderName -PropertyY PSComputerName -ChartType1 'Column' -ChartType2_3 'Point' -MarkerStyle1 'None' -MarkerStyle2 'Square' -MarkerStyle3 'Diamond'
            }
            function AutoChartsCommandNetworkSettings {
                AutoChartsCommand -QueryName "Network Settings" -QueryTabName "Number of Interfaces with IPs" -PropertyX PSComputerName -PropertyY IPAddress -ChartType1 'Column' -ChartType2_3 'Point' -MarkerStyle1 'None' -MarkerStyle2 'Square' -MarkerStyle3 'Diamond'
                AutoChartsCommand -QueryName "Network Settings" -QueryTabName "Number of Hosts with IPs"      -PropertyX IPAddress -PropertyY PSComputerName -ChartType1 'Column' -ChartType2_3 'Point' -MarkerStyle1 'None' -MarkerStyle2 'Square' -MarkerStyle3 'Diamond'            
            }
            function AutoChartsCommandProcessesStandard {
                AutoChartsCommand -QueryName "Processes" -QueryTabName "Process Names" -PropertyX Name -PropertyY PSComputerName -ChartType1 'Column' -ChartType2_3 'Point' -MarkerStyle1 'None' -MarkerStyle2 'Square' -MarkerStyle3 'Diamond'
                AutoChartsCommand -QueryName "Processes" -QueryTabName "Process Paths" -PropertyX Path -PropertyY PSComputerName -ChartType1 'Bar'    -ChartType2_3 'Bar'   -MarkerStyle1 'None' -MarkerStyle2 'None'   -MarkerStyle3 'None'
            }
            function AutoChartsCommandSecurityPatches {
                AutoChartsCommand -QueryName "Security Patches" -QueryTabName "Number of Computers with Security Patches" -PropertyX Name -PropertyY PSComputerName     -ChartType1 'Column' -ChartType2_3 'Point' -MarkerStyle1 'None' -MarkerStyle2 'Square' -MarkerStyle3 'Diamond'
                AutoChartsCommand -QueryName "Security Patches" -QueryTabName "Number of Security Patches per Computer"   -PropertyX PSComputerName -PropertyY HotFixID -ChartType1 'Column' -ChartType2_3 'Point' -MarkerStyle1 'None' -MarkerStyle2 'Square' -MarkerStyle3 'Diamond'
            }
            function AutoChartsCommandServices {
                AutoChartsCommand -QueryName "Services" -QueryTabName "Service Names" -PropertyX Name     -PropertyY PSComputerName -ChartType1 'Column' -ChartType2_3 'Point' -MarkerStyle1 'None' -MarkerStyle2 'Square' -MarkerStyle3 'Diamond'
                AutoChartsCommand -QueryName "Services" -QueryTabName "Service Paths" -PropertyX PathName -PropertyY PSComputerName -ChartType1 'Bar'    -ChartType2_3 'Bar'   -MarkerStyle1 'None' -MarkerStyle2 'None'   -MarkerStyle3 'None'
            }
            function AutoChartsCommandShares {
                AutoChartsCommand -QueryName "Shares" -QueryTabName "Shares" -PropertyX Path -PropertyY PSComputerName -ChartType1 'Column' -ChartType2_3 'Point' -MarkerStyle1 'None' -MarkerStyle2 'Square' -MarkerStyle3 'Diamond'
                AutoChartsCommand -QueryName "Shares" -QueryTabName "Shares" -PropertyX PSComputerName -PropertyY Path -ChartType1 'Bar'    -ChartType2_3 'Bar'   -MarkerStyle1 'None' -MarkerStyle2 'None'   -MarkerStyle3 'None'
            }
            function AutoChartsCommandSoftwareInstalled {
                AutoChartsCommand -QueryName "Software Installed" -QueryTabName "Software Installed" -PropertyX Name -PropertyY PSComputerName -ChartType1 'Column' -ChartType2_3 'Point' -MarkerStyle1 'None' -MarkerStyle2 'Square' -MarkerStyle3 'Diamond'
                AutoChartsCommand -QueryName "Software Installed" -QueryTabName "Software Installed" -PropertyX PSComputerName -PropertyY Name -ChartType1 'Column' -ChartType2_3 'Point' -MarkerStyle1 'None' -MarkerStyle2 'Square' -MarkerStyle3 'Diamond'
            }
            function AutoChartsCommandStartUpCommands {
                AutoChartsCommand -QueryName "Startup Commands" -QueryTabName "Startup Names"    -PropertyX Name    -PropertyY PSComputerName -ChartType1 'Column' -ChartType2_3 'Point' -MarkerStyle1 'None' -MarkerStyle2 'Square' -MarkerStyle3 'Diamond'
                AutoChartsCommand -QueryName "Startup Commands" -QueryTabName "Startup Commands" -PropertyX Command -PropertyY PSComputerName -ChartType1 'Bar'    -ChartType2_3 'Bar'   -MarkerStyle1 'None' -MarkerStyle2 'None'   -MarkerStyle3 'None'
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
            elseif ($AutoChartSelectChartComboBox.SelectedItem -match "Logon Info")           { AutoChartsCommandLogonInfo }
            elseif ($AutoChartSelectChartComboBox.SelectedItem -match "Mapped Drives")        { AutoChartsCommandMappedDrives }
            elseif ($AutoChartSelectChartComboBox.SelectedItem -match "Network Settings")     { AutoChartsCommandNetworkSettings }
            elseif ($AutoChartSelectChartComboBox.SelectedItem -match "Processes") { AutoChartsCommandProcessesStandard }
            elseif ($AutoChartSelectChartComboBox.SelectedItem -match "Security Patches")     { AutoChartsCommandSecurityPatches }
            elseif ($AutoChartSelectChartComboBox.SelectedItem -match "Services")             { AutoChartsCommandServices }
            elseif ($AutoChartSelectChartComboBox.SelectedItem -match "Shares")               { AutoChartsCommandShares }
            elseif ($AutoChartSelectChartComboBox.SelectedItem -match "Software Installed")   { AutoChartsCommandSoftwareInstalled }
            elseif ($AutoChartSelectChartComboBox.SelectedItem -match "Startup Commands")     { AutoChartsCommandStartUpCommands }
        
            # Launches the form
            $AutoChartsForm.Add_Shown({$AutoChartsForm.Activate()})
            [void]$AutoChartsForm.ShowDialog()

            #---------------------------------------
            # Auto Create Charts - Autosave an Image
            #---------------------------------------
            #$AutoChart.SaveImage('C:\temp\chart.jpeg', 'jpeg')
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
    #batman


        # Name of Collected Data Directory
        $CollectedDataDirectory                   = "$PoShHome\Collected Data"
        # Location of separate queries
        $CollectedDataTimeStampDirectory      = "$CollectedDataDirectory\$((Get-Date).ToString('yyyy-MM-dd @ HHmm ss'))"
        # Location of Uncompiled Results
        $IndividualHostResults                = "$CollectedDataTimeStampDirectory\Individual Host Results"




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
    # Checkes if the Appropriate Checkbox is selected, if so it selects the very first, previous, and most recent collections respectively
    if ($AutoChartsBaselineCheckBox.Checked -eq $true) {
        $script:CSVFileBaselineCollection   = $CSVFileMatch | Select-Object -First 1
    }
    if ($AutoChartsPreviousCheckBox.Checked -eq $true) { 
        $script:CSVFilePreviousCollection   = $CSVFileMatch | Select-Object -Last 2 | Select-Object -First 1 
    }
    if ($AutoChartsMostRecentCheckBox.Checked -eq $true) { 
        $script:CSVFileMostRecentCollection   = $CSVFileMatch | Select-Object -Last 1 
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
    $AutoChart = New-object System.Windows.Forms.DataVisualization.Charting.Chart
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

    # Controls which series is showing and what type of charts will be displayed
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
            [string[]]$CSVFiles, 
            [string]$OutputFile = "c:\merged.csv" 
        ) 
        $Script:MergedCSVFilesOutput = @(); 
        foreach($CSV in $CSVFiles) { 
            if(Test-Path $CSV) {          
                $FileName = [System.IO.Path]::GetFileName($CSV) 
                $temp = Import-CSV -Path $CSV | select *, @{Expression={$FileName};Label="FileName"} 
                $Script:MergedCSVFilesOutput += $temp 
            } else { 
                Write-Warning "$CSV : No such file found" 
            } 
 
        }        
        #$Script:Output | Export-Csv -Path $OutputFile -NoTypeInformation 
        #Write-Output "$OutputFile successfully created" 
        return $Script:MergedCSVFilesOutput
    }

    # Later used to iterate through
    $CSVFileCollection = @($script:CSVFileBaselineCollection,$script:CSVFilePreviousCollection,$script:CSVFileMostRecentCollection)
    $SeriesCount = 0

    # If the Second field/Y Axis equals PSComputername, it counts it
    if ($PropertyY -eq "PSComputerName") {
        #$Script:AutoChartsChoice0 = "Name"
        #$Script:AutoChartsChoice1 = "PSComputerName"

        # This file merger is later used to get a unique count of PropertyX and add to the DataSource (later the count is then subtracted by 1), 
        # this allow each collection to have a minimum of zero count of a process. This aligns all results, otherwise unique results will be shifted off from one another
        Merge-CSVFiles -CSVFiles $script:CSVFileBaselineCollection,$script:CSVFilePreviousCollection,$script:CSVFileMostRecentCollection 

        foreach ($CSVFile in $CSVFileCollection) {
            $SeriesCount += 1
            $DataSource = @()

            # Filtering Results for Services to show just running services
            if ($CSVFile -match "Services.csv") {
                $DataSource += Import-Csv $CSVFile | Where-Object {$_.State -eq "Running"}
                $DataSource += $Script:MergedCSVFilesOutput  | Where-Object {$_.State -eq "Running"} | Select-Object -Property $PropertyX -Unique
                $AutoChartTitle.Text = (($script:CSVFileMostRecentCollection.split('\'))[-1] -replace '.csv','') + " - Running"
            }
            else {
                #test# $DataSource = Import-Csv $CSVFile
                $DataSource += Import-Csv $CSVFile
                $DataSource += $Script:MergedCSVFilesOutput | Select-Object -Property $PropertyX -Unique
            }                    
            # Creates a Unique list
            $UniqueDataFields   = $DataSource | Select-Object -Property $PropertyX | Sort-Object -Property $PropertyX -Unique
            $UniqueComputerList = $DataSource | Select-Object -Property $PropertyY | Sort-Object -Property $PropertyY -Unique

            # Generates and Counts the data
            $OverallDataResults = @()
            foreach ($DataField in $UniqueDataFields) {
                $Count          = 0
                $Computers      = @()
                foreach ( $Line in $DataSource ) { 
                    if ( $Line.$PropertyX -eq $DataField.$PropertyX ) {
                        $Count += 1
                        if ( $Computers -notcontains $Line.$PropertyY ) { $Computers += $Line.$PropertyY }
                    }
                }
                $UniqueCount    = $Computers.Count - 1 ### 1 is subtracted to account for the one added when ensuring all data fields are present
                $DataResults    =  New-Object PSObject -Property @{
                    DataField   = $DataField
                    TotalCount  = $Count
                    UniqueCount = $UniqueCount
                    Computers   = $Computers 
                }
                $OverallDataResults += $DataResults
            }
            $Series = '$Series0' + $SeriesCount + 'Name'
            $OverallDataResults `
            | ForEach-Object {$AutoChart.Series["$(iex $Series)"].Points.AddXY($_.DataField.$PropertyX,$_.UniqueCount)}
        }
    }

    # If the Second field/Y Axis DOES NOT equals PSComputername, it uses the field provided
    elseif ($PropertyX -eq "PSComputerName") {   
        # Import Data
        $DataSource = ""
        foreach ($CSVFile in $CSVFileCollection) {
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

    ############################################################################################################
    # Auto Create Charts Processes
    ############################################################################################################

    #------------------------------------
    # Auto Creates Tabs and Imports Data
    #------------------------------------
    # Obtains a list of the files in the resources folder
    $ResourceProcessFiles = Get-ChildItem "$PoShHome\Resources\Process Info"

    #-----------------------------
    # Creates Tabs From Each File
    #-----------------------------
    $TabName                          = $QueryTabName
    $AutoChartsIndividualTabs         = New-Object System.Windows.Forms.TabPage
    $AutoChartsIndividualTabs.Text    = "$TabName"
    $AutoChartsIndividualTabs.UseVisualStyleBackColor = $True
    $AutoChartsIndividualTabs.Anchor  = $AnchorAll
    $AutoChartsTabControl.Controls.Add($AutoChartsIndividualTabs)            
    $AutoChartsIndividualTabs.controls.add($AutoChart)

    #-----------------------------------------------------
    # Auto Create Charts Collection Series Computer Count
    #-----------------------------------------------------
    $AutoChartsSeriesComputerCount           = New-Object System.Windows.Forms.Label
    $AutoChartsSeriesComputerCount.Location  = New-Object System.Drawing.Size(955,216) 
    $AutoChartsSeriesComputerCount.Size      = New-Object System.Drawing.Size(150,25)
    $AutoChartsSeriesComputerCount.Font      = [System.Drawing.Font]::new("$Font", 10, [System.Drawing.FontStyle]::Bold)
    $AutoChartsSeriesComputerCount.ForeColor = 'Black'
    $AutoChartsSeriesComputerCount.Text      = "Future Notes Section"
    $AutoChart.Controls.Add($AutoChartsSeriesComputerCount)
    
    #--------------------------------
    # Auto Create Charts Save Button
    #--------------------------------
    Function Invoke-SaveDialog {
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
    $AutoChartsSaveButton           = New-Object Windows.Forms.Button
    $AutoChartsSaveButton.Text      = "Save Image"
    $AutoChartsSaveButton.Location  = New-Object System.Drawing.Size(955,516)
    $AutoChartsSaveButton.Size      = New-Object System.Drawing.Size(150,25)
    $AutoChartsSaveButton.Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
        [enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
    $AutoChartsSaveButton.Font      = [System.Drawing.Font]::new("$Font", 10, [System.Drawing.FontStyle]::Bold)
    $AutoChartsSaveButton.ForeColor = "Black"
    $AutoChartsSaveButton.UseVisualStyleBackColor = $True
    $AutoChartsSaveButton.Add_Click({
        $Result = Invoke-SaveDialog
        If ($Result) { $AutoChart.SaveImage($Result.FileName, $Result.Extension) }
    }) 
    $AutoChart.controls.add($AutoChartsSaveButton)

    $ButtonSpacing = 35 

    if ($AutoChartSelectChartComboBox.SelectedItem -notmatch "All Charts") {
        #------------------------------------
        # Auto Create Charts Series3 Results
        #------------------------------------
        if ($AutoChartsMostRecentCheckBox.Checked -eq $True) {
            if ($script:CSVFileMostRecentCollection) { 
                $AutoChartsSeries3Results           = New-Object Windows.Forms.Button
                $AutoChartsSeries3Results.Text      = "$Series03Name Results"
                $AutoChartsSeries3Results.Location  = New-Object System.Drawing.Size(($AutoChartsSaveButton.Location.X),($AutoChartsSaveButton.Location.Y - $ButtonSpacing))
                $AutoChartsSeries3Results.Size      = New-Object System.Drawing.Size(150,25)
                $AutoChartsSeries3Results.Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
                $AutoChartsSeries3Results.Font      = [System.Drawing.Font]::new("$Font", 10, [System.Drawing.FontStyle]::Bold)
                $AutoChartsSeries3Results.ForeColor = "Red"
                $AutoChartsSeries3Results.UseVisualStyleBackColor = $True
                $AutoChartsSeries3Results.Add_Click({ Import-CSV $script:CSVFileMostRecentCollection | Out-GridView }) 
                $AutoChart.controls.add($AutoChartsSeries3Results)
                $ButtonSpacing += 35
            }
        }

        #------------------------------------
        # Auto Create Charts Series2 Results
        #------------------------------------
        if ($AutoChartsPreviousCheckBox.Checked -eq $True) {
            if ($script:CSVFilePreviousCollection) {
                $AutoChartsSeries2Results           = New-Object Windows.Forms.Button
                $AutoChartsSeries2Results.Text      = "$Series02Name Results"
                $AutoChartsSeries2Results.Location  = New-Object System.Drawing.Size(($AutoChartsSaveButton.Location.X),($AutoChartsSaveButton.Location.Y - $ButtonSpacing))
                $AutoChartsSeries2Results.Size      = New-Object System.Drawing.Size(150,25)
                $AutoChartsSeries2Results.Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
                $AutoChartsSeries2Results.Font      = [System.Drawing.Font]::new("$Font", 10, [System.Drawing.FontStyle]::Bold)
                $AutoChartsSeries2Results.ForeColor = "Orange"
                $AutoChartsSeries2Results.UseVisualStyleBackColor = $True
                $AutoChartsSeries2Results.Add_Click({ Import-CSV $script:CSVFilePreviousCollection | Out-GridView }) 
                $AutoChart.controls.add($AutoChartsSeries2Results)
                $ButtonSpacing += 35
            }
        }

        #------------------------------------
        # Auto Create Charts Series1 Results
        #------------------------------------
        if ($AutoChartsBaselineCheckBox.Checked -eq $True) {
            if ($script:CSVFileBaselineCollection) {
                $AutoChartsSeries1Results           = New-Object Windows.Forms.Button
                $AutoChartsSeries1Results.Text      = "$Series01Name Results"
                $AutoChartsSeries1Results.Location  = New-Object System.Drawing.Size(($AutoChartsSaveButton.Location.X),($AutoChartsSaveButton.Location.Y - $ButtonSpacing))
                $AutoChartsSeries1Results.Size      = New-Object System.Drawing.Size(150,25)
                $AutoChartsSeries1Results.Anchor    = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
                $AutoChartsSeries1Results.Font      = [System.Drawing.Font]::new("$Font", 10, [System.Drawing.FontStyle]::Bold)
                $AutoChartsSeries1Results.ForeColor = "Blue"
                $AutoChartsSeries1Results.UseVisualStyleBackColor = $True
                $AutoChartsSeries1Results.Add_Click({ Import-CSV $script:CSVFileBaselineCollection | Out-GridView }) 
                $AutoChart.controls.add($AutoChartsSeries1Results)
                $ButtonSpacing += 35
            }
        }
    }

    ####$AutoChart.Add_Shown({$ViewChartForm.Activate()})
    ####[void]$AutoChart.ShowDialog()
    
    #---------------------------------------
    # Custom View Chart - Autosave an Image
    #---------------------------------------
    #$AutoChart.SaveImage('C:\temp\chart.jpeg', 'jpeg')    
}

#-------------------------
# View Auto Charts Button
#-------------------------
$AutoChartsButton2          = New-Object System.Windows.Forms.Button
$AutoChartsButton2.Name     = "View Auto Chart"
$AutoChartsButton2.Text     = "$($AutoChartsButton2.Name)"
$AutoChartsButton2.UseVisualStyleBackColor = $True
$AutoChartsButton2.Location = New-Object System.Drawing.Size(($ViewChartButton.Location.X),($ViewChartButton.Location.Y - 30))
$AutoChartsButton2.Size     = New-Object System.Drawing.Size(115,22)
$AutoChartsButton2.Add_Click({ AutoChartsSelectOptions })
$Section2MainTab.Controls.Add($AutoChartsButton2)

##############################################################################################################################################################
##
## Section 1 Options SubTab
##
##############################################################################################################################################################
$Section2OptionsTab          = New-Object System.Windows.Forms.TabPage
$Section2OptionsTab.Text     = "Options"
$Section2OptionsTab.Name     = "Options"
$Section2OptionsTab.UseVisualStyleBackColor = $True
$Section2TabControl.Controls.Add($Section2OptionsTab)

#------------------------------------------
# Option - Computer List - View Log Button
#------------------------------------------
$OptionLogButton          = New-Object System.Windows.Forms.Button
$OptionLogButton.Name     = "View Log"
$OptionLogButton.Text     = "$($OptionLogButton.Name)"
$OptionLogButton.UseVisualStyleBackColor = $True
$OptionLogButton.Location = New-Object System.Drawing.Size(3,11)
$OptionLogButton.Size     = New-Object System.Drawing.Size(115,22)
$OptionLogButton.Add_Click({Start-Process notepad.exe $LogFile})
$Section2OptionsTab.Controls.Add($OptionLogButton)

#-----------------------------------
# Option - Job Timeout Checklistbox
#-----------------------------------
$script:OptionJobTimeoutSelectionComboBox          = New-Object -TypeName System.Windows.Forms.Combobox
$script:OptionJobTimeoutSelectionComboBox.Text     = 60
$script:OptionJobTimeoutSelectionComboBox.Location = New-Object System.Drawing.Size(3,($OptionLogButton.Location.Y + $OptionLogButton.Size.Height + 5))
$script:OptionJobTimeoutSelectionComboBox.Size     = New-Object System.Drawing.Size(50,25)
$script:OptionJobTimeoutSelectionComboBox.Font     = New-Object System.Drawing.Font("$Font",9,0,3,0)
    $script:OptionJobTimeoutSelectionComboBox.AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
    $JobTimesAvailable = @(15,30,45,60,120,180,240,300,600)
    ForEach ($Item in $JobTimesAvailable) { [void] $script:OptionJobTimeoutSelectionComboBox.Items.Add($Item) }
$Section2OptionsTab.Controls.Add($script:OptionJobTimeoutSelectionComboBox)

#----------------------------
# Option - Job Timeout Lablel
#----------------------------
$OptionJobTimeoutSelectionLabel          = New-Object -TypeName System.Windows.Forms.Label
$OptionJobTimeoutSelectionLabel.Text     = "Job Timeout in Seconds"
$OptionJobTimeoutSelectionLabel.Location = New-Object System.Drawing.Size(($script:OptionJobTimeoutSelectionComboBox.Size.Width + 10),($OptionLogButton.Location.Y + $OptionLogButton.Size.Height + 8))
$OptionJobTimeoutSelectionLabel.Size     = New-Object System.Drawing.Size(150,25)
$OptionJobTimeoutSelectionLabel.Font     = New-Object System.Drawing.Font("$Font",9,0,3,0)
$Section2OptionsTab.Controls.Add($OptionJobTimeoutSelectionLabel)

#------------------------------------
# Option - Search Processes Checkbox
#------------------------------------
$OptionSearchProcessesCheckBox          = New-Object System.Windows.Forms.Checkbox
$OptionSearchProcessesCheckBox.Text     = "Include Searching Through 'Processes' Results"
$OptionSearchProcessesCheckBox.Location = New-Object System.Drawing.Size(3,($script:OptionJobTimeoutSelectionComboBox.Location.Y + $script:OptionJobTimeoutSelectionComboBox.Size.Height + 5))
$OptionSearchProcessesCheckBox.Size     = New-Object System.Drawing.Size(400,$Column3BoxHeight) 
$OptionSearchProcessesCheckBox.Enabled  = $true
$OptionSearchProcessesCheckBox.Checked  = $False
$OptionSearchProcessesCheckBox.Font     = [System.Drawing.Font]::new("$Font",1,10,1)
#$OptionSearchProcessesCheckBox.Add_Click({  })
$Section2OptionsTab.Controls.Add($OptionSearchProcessesCheckBox)

#--------------------------
# Option - Bold Categories
#--------------------------
$OptionBoldTreeViewCategoriesCheckBox          = New-Object System.Windows.Forms.Checkbox
$OptionBoldTreeViewCategoriesCheckBox.Text     = "Bold TreeView Categories"
$OptionBoldTreeViewCategoriesCheckBox.Location = New-Object System.Drawing.Size(3,($OptionSearchProcessesCheckBox.Location.Y + $OptionSearchProcessesCheckBox.Size.Height + 5))
$OptionBoldTreeViewCategoriesCheckBox.Size     = New-Object System.Drawing.Size(200,$Column3BoxHeight) 
$OptionBoldTreeViewCategoriesCheckBox.Enabled  = $true
$OptionBoldTreeViewCategoriesCheckBox.Checked  = $False
$OptionBoldTreeViewCategoriesCheckBox.Font     = [System.Drawing.Font]::new("$Font",1,10,1)
$OptionBoldTreeViewCategoriesCheckBox.Add_Click({    
    $CommandsTreeView.Nodes.Clear()
    Initialize-CommandsTreeView
    if ($CommandsViewMethodRadioButton.checked) { View-CommandsTreeViewMethod }
    elseif ($CommandsViewQueryRadioButton.checked) { View-CommandsTreeViewQuery }
    Keep-CommandsCheckboxesChecked

    $ComputerListTreeView.Nodes.Clear()    
    Initialize-ComputerListTreeView
    $ComputerListTreeView.Nodes.Add($script:TreeNodeComputerList)
    if ($ComputerListTreeViewOSHostnameRadioButton.checked) { Foreach($Computer in $script:ComputerListTreeViewData) { Add-ComputerNode -RootNode $script:TreeNodeComputerList -Category $Computer.OperatingSystem -Entry $Computer.Name -ToolTip $Computer.IPv4Address } }
    elseif ($ComputerListTreeViewOUHostnameRadioButton.checked) { Foreach($Computer in $script:ComputerListTreeViewData) { Add-ComputerNode -RootNode $script:TreeNodeComputerList -Category $Computer.CanonicalName -Entry $Computer.Name -ToolTip $Computer.IPv4Address } }
    Keep-ComputerListCheckboxesChecked
})
$Section2OptionsTab.Controls.Add($OptionBoldTreeViewCategoriesCheckBox)

#--------------------------------------
# Option - Text To Speach/TTS Checkbox
#--------------------------------------
$OptionTextToSpeachCheckBox          = New-Object System.Windows.Forms.Checkbox
$OptionTextToSpeachCheckBox.Text     = "Audible Completion Message"
$OptionTextToSpeachCheckBox.Location = New-Object System.Drawing.Size(3,($OptionBoldTreeViewCategoriesCheckBox.Location.Y + $OptionBoldTreeViewCategoriesCheckBox.Size.Height + 5))
$OptionTextToSpeachCheckBox.Size     = New-Object System.Drawing.Size(200,$Column3BoxHeight) 
$OptionTextToSpeachCheckBox.Enabled  = $true
$OptionTextToSpeachCheckBox.Checked  = $False
$OptionTextToSpeachCheckBox.Font     = [System.Drawing.Font]::new("$Font",1,10,1)
#$OptionTextToSpeachCheckBox.Add_Click({ })
$Section2OptionsTab.Controls.Add($OptionTextToSpeachCheckBox)


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
$script:ComputerListTreeViewData = Import-Csv $ComputerListTreeViewFileSave -ErrorAction SilentlyContinue #| Select-Object -Property Name, OperatingSystem, CanonicalName, IPv4Address, Notes
#$script:ComputerListTreeViewData

function Save-HostData {
    $script:ComputerListTreeViewData | Export-Csv $ComputerListTreeViewFileSave -NoTypeInformation
}
function TempSave-HostData {
    $script:ComputerListTreeViewData | Export-Csv $ComputerListTreeViewFileAutoSave -NoTypeInformation
}

function Initialize-ComputerListTreeView {
    $script:TreeNodeComputerList     = New-Object -TypeName System.Windows.Forms.TreeNode -ArgumentList 'All Hosts'
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
                        $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,128,0)
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
            $CategoryNode             = New-Object System.Windows.Forms.TreeNode
            $CategoryNode.Name        = $Category
            $CategoryNode.Text        = $Category
            $CategoryNode.Tag         = $Category
            $CategoryNode.ToolTipText = "Checkbox this Category to query all its hosts"

            #Bolds the categories if the options checkbox is true
            if ($OptionBoldTreeViewCategoriesCheckBox.Checked -eq $true) { $CategoryNode.NodeFont   = New-Object System.Drawing.Font("$Font",10,1,2,1) }
            else { $CategoryNode.NodeFont   = New-Object System.Drawing.Font("$Font",10,1,1,1)}

            $CategoryNode.ForeColor  = [System.Drawing.Color]::FromArgb(0,0,0,0)

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
        }    

        # Checks if the Option is checked, if so it will include searching through 'Processes' CSVs
        # This is a slow process...
        if ($OptionSearchProcessesCheckBox.Checked) {
            # Searches though the all Collection Data Directories to find files that match
            $ListOfCollectedDataDirectories = $(Get-ChildItem -Path $CollectedDataDirectory | Sort-Object -Descending).FullName
            $script:CSVFileMatch = @()
            foreach ($CollectionDir in $ListOfCollectedDataDirectories) {
                $CSVFiles = $(Get-ChildItem -Path $CollectionDir -Recurse).FullName
                foreach ($CSVFile in $CSVFiles) {
                    # Searches for the CSV file that matches the data selected
                    if ($CSVFile -match "Processes") {
                        #$CsvContents = Import-CSV -Path $CSVFile | select
                        if ($(Import-CSV -Path $CSVFile | select -Property name | where {$_.name -imatch $ComputerListTreeViewSearchTextBox.Text} | where {$_.name -ne ''})) {
                            $ComputerWithResults = $($($($CSVFile.split('\')[-1]).split('-')[2..5]) -join '-').replace('.csv','')
                            if (($SearchFound -inotcontains $ComputerWithResults) -and ($ComputerWithResults -ne ''))  {
                                Add-ComputerNode -RootNode $script:ComputerListSearch -Category $ComputerListTreeViewSearchTextBox.Text -Entry $ComputerWithResults -ToolTip $Computer.IPv4Address    
                                $SearchFound += $ComputerWithResults
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
}

#----------------------------------------
# ComputerList TreeView - Search TextBox
#----------------------------------------
$ComputerListTreeViewSearchTextBox                    = New-Object System.Windows.Forms.ComboBox
$ComputerListTreeViewSearchTextBox.Name               = "Search TextBox"
$ComputerListTreeViewSearchTextBox.Location           = New-Object System.Drawing.Size(($Column4RightPosition),25)#(($ComputerListTreeViewViewByLabel.Location.Y),($ComputerListTreeViewViewByLabel.Location.X + $ComputerListTreeViewViewByLabel.Size.Height + 5))
$ComputerListTreeViewSearchTextBox.Size               = New-Object System.Drawing.Size(172,25)
$ComputerListTreeViewSearchTextBox.AutoCompleteSource = "ListItems" # Options are: FileSystem, HistoryList, RecentlyUsedList, AllURL, AllSystemSources, FileSystemDirectories, CustomSource, ListItems, None
$ComputerListTreeViewSearchTextBox.AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
    ForEach ($Tag in $TagList) { 
        [void] $ComputerListTreeViewSearchTextBox.Items.Add($Tag) 
    }
$ComputerListTreeViewSearchTextBox.Add_KeyDown({ 
    if ($_.KeyCode -eq "Enter") { 
        Search-ComputerListTreeView
    }
})
$PoShACME.Controls.Add($ComputerListTreeViewSearchTextBox)

#---------------------------------------
# ComputerList TreeView - Search Button
#---------------------------------------
$ComputerListTreeViewSearchButton          = New-Object System.Windows.Forms.Button
$ComputerListTreeViewSearchButton.Name     = "Search Button"
$ComputerListTreeViewSearchButton.Text     = "Search"
$ComputerListTreeViewSearchButton.Location = New-Object System.Drawing.Size(($Column4RightPosition + 176),24)#(($ComputerListTreeViewViewByLabel.Location.Y),($ComputerListTreeViewViewByLabel.Location.X + $ComputerListTreeViewViewByLabel.Size.Height + 5))
$ComputerListTreeViewSearchButton.Size     = New-Object System.Drawing.Size(55,22)
$ComputerListTreeViewSearchButton.Font     = New-Object System.Drawing.Font("$Font",10,0,2,1)
$ComputerListTreeViewSearchButton.Add_Click({
    Search-ComputerListTreeView
})
$PoShACME.Controls.Add($ComputerListTreeViewSearchButton)

#-----------------------------
# ComputerList Treeview Nodes
#-----------------------------
$ComputerListTreeView                   = New-Object System.Windows.Forms.TreeView
$System_Drawing_Size                    = New-Object System.Drawing.Size
$System_Drawing_Size.Width              = 230
$System_Drawing_Size.Height             = 308
$ComputerListTreeView.Size              = $System_Drawing_Size
$System_Drawing_Point                   = New-Object System.Drawing.Point
$System_Drawing_Point.X                 = $Column4RightPosition
$System_Drawing_Point.Y                 = $Column4DownPosition + 39
$ComputerListTreeView.Location          = $System_Drawing_Point
$ComputerListTreeView.Font              = New-Object System.Drawing.Font("$Font",8,0,3,0)
$ComputerListTreeView.CheckBoxes        = $True
#$ComputerListTreeView.LabelEdit        = $True
$ComputerListTreeView.ShowLines         = $True
$ComputerListTreeView.ShowNodeToolTips  = $True
$ComputerListTreeView.Sort()
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
                    $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,128,0)
                    $Category.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
                    $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                }                            
            }
        }
        foreach ($Category in $root.Nodes) { 
            $EntryNodeCheckedCount = 0                        
            if ($Category.checked) {
                $Category.Expand()
                $Category.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
                $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                foreach ($Entry in $Category.nodes) {
                    $EntryNodeCheckedCount  += 1
                    $Entry.Checked      = $True
                    $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",10,1,1,1)
                    $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,128,0)
                }            
            }
            if (!($Category.checked)) {
                foreach ($Entry in $Category.nodes) { 
                    #if ($Entry.isselected) { 
                    if ($Entry.checked) {
                        $EntryNodeCheckedCount  += 1
                        $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",10,1,1,1)
                        $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,128,0)
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
            }
            else {
                $Category.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
                $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
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

                $Section3HostDataName.Text  = "N/A"
                $Section3HostDataOS.Text    = "N/A"
                $Section3HostDataOU.Text    = "N/A"
                $Section3HostDataIP.Text    = "N/A"
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
                    $ResultsListBox.Items.Add("- Checkkbox one hostname/IP to RDP, PSSession, or PSExec")
                    $ResultsListBox.Items.Add("- Checkbox any number of Categories, hostnames, or IPs to run any number of queries or ping")
                    $ResultsListBox.Items.Add("")
                    $ResultsListBox.Items.Add("- Click on the Host Data Tab to view and modify data")

                    # Populates the Host Data Tab with data from the selected TreeNode
                    $Section3HostDataName.Text  = $($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).Name
                    $Section3HostDataOS.Text    = $($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).OperatingSystem
                    $Section3HostDataOU.Text    = $($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).CanonicalName
                    $Section3HostDataIP.Text    = $($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).IPv4Address
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
$ComputerListTreeViewViewByLabel          = New-Object System.Windows.Forms.Label
$ComputerListTreeViewViewByLabel.Text     = "View by:"
$ComputerListTreeViewViewByLabel.Location = New-Object System.Drawing.Size($Column4RightPosition,7)
$ComputerListTreeViewViewByLabel.Size     = New-Object System.Drawing.Size(75,25)
$ComputerListTreeViewViewByLabel.Font     = New-Object System.Drawing.Font("$Font",11,1,2,1)
$PoShACME.Controls.Add($ComputerListTreeViewViewByLabel)

#----------------------------------------------------
# ComputerList TreeView - OS & Hostname Radio Button
#----------------------------------------------------
$ComputerListTreeViewOSHostnameRadioButton          = New-Object System.Windows.Forms.RadioButton
$System_Drawing_Point                       = New-Object System.Drawing.Point
$System_Drawing_Point.X                     = $ComputerListTreeViewViewByLabel.Location.X + $ComputerListTreeViewViewByLabel.Size.Width
$System_Drawing_Point.Y                     = $ComputerListTreeViewViewByLabel.Location.Y - 5
$ComputerListTreeViewOSHostnameRadioButton.Location = $System_Drawing_Point
$System_Drawing_Size                        = New-Object System.Drawing.Size
$System_Drawing_Size.Height                 = 25
$System_Drawing_Size.Width                  = 50
$ComputerListTreeViewOSHostnameRadioButton.size     = $System_Drawing_Size
$ComputerListTreeViewOSHostnameRadioButton.Checked  = $True
$ComputerListTreeViewOSHostnameRadioButton.Text     = "OS"
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
$PoShACME.Controls.Add($ComputerListTreeViewOSHostnameRadioButton)

#---------------------------------------------------------------------
# ComputerList TreeView - Active Directory OU & Hostname Radio Button
#---------------------------------------------------------------------
$ComputerListTreeViewOUHostnameRadioButton  = New-Object System.Windows.Forms.RadioButton
$System_Drawing_Point                       = New-Object System.Drawing.Point
$System_Drawing_Point.X                     = $ComputerListTreeViewOSHostnameRadioButton.Location.X + $ComputerListTreeViewOSHostnameRadioButton.Size.Width + 5
$System_Drawing_Point.Y                     = $ComputerListTreeViewOSHostnameRadioButton.Location.Y
$ComputerListTreeViewOUHostnameRadioButton.Location = $System_Drawing_Point
$System_Drawing_Size                        = New-Object System.Drawing.Size
$System_Drawing_Size.Height                 = 25
$System_Drawing_Size.Width                  = 75
$ComputerListTreeViewOUHostnameRadioButton.size     = $System_Drawing_Size
$ComputerListTreeViewOUHostnameRadioButton.Checked  = $false
$ComputerListTreeViewOUHostnameRadioButton.Text     = "OU / CN"
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
$PoShACME.Controls.Add($ComputerListTreeViewOUHostnameRadioButton)


##############################################################################################################################################################
##############################################################################################################################################################
##
## Section 3 Computer List - Tab Control
##
##############################################################################################################################################################
##############################################################################################################################################################

$Section3TabControl               = New-Object System.Windows.Forms.TabControl
$System_Drawing_Point             = New-Object System.Drawing.Point
$System_Drawing_Point.X           = 1082
$System_Drawing_Point.Y           = 10
$Section3TabControl.Location      = $System_Drawing_Point
$Section3TabControl.Name          = "Main Tab Window for Computer List"
$Section3TabControl.SelectedIndex = 0
$Section3TabControl.ShowToolTips  = $True
$System_Drawing_Size              = New-Object System.Drawing.Size
$System_Drawing_Size.Height       = 349
$System_Drawing_Size.Width        = 126
$Section3TabControl.Size          = $System_Drawing_Size
$PoShACME.Controls.Add($Section3TabControl)

# Varables to Control Column 5
$Column5RightPosition     = 3
$Column5DownPositionStart = 6
$Column5DownPosition      = 6
$Column5DownPositionShift = 28
$Column5BoxWidth          = 110
$Column5BoxHeight         = 22

##############################################################################################################################################################
##
## Section 3 Computer List - Action Tab
##
##############################################################################################################################################################
$Section3ActionTab          = New-Object System.Windows.Forms.TabPage
$Section3ActionTab.Text     = "Action"
$Section3ActionTab.Location = New-Object System.Drawing.Size($Column5RightPosition,$Column5DownPosition) 
$Section3ActionTab.Size     = New-Object System.Drawing.Size($Column5BoxWidth,$Column5BoxHeight) 
$Section3ActionTab.UseVisualStyleBackColor = $True
$Section3TabControl.Controls.Add($Section3ActionTab)

#####################################################################################################################################
## Section 3 Computer List - Action Tab Buttons
#####################################################################################################################################

#============================================================================================================================================================
# MouseHover Tooltip
#============================================================================================================================================================
$MouseHoverToolTip = New-Object System.Windows.Forms.ToolTip
$MouseHover={
    Switch ($this.name) {
        "Host Data - Hostname"    {$tip = "Hostname"}
        "Host Data - OS"          {$tip = "Operating System"}
        "Host Data - OU"          {$tip = "Organizational Unit"}
        "Host Data - IP"          {$tip = "IPv4 Address"}
        "Host Data - Notes"       {$tip = "Analyst's Notes"}
        "Host Data - Selection"   {$tip = "Select What Data to View"}
        "Host Data - Date & Time" {$tip = "Data and Time of Collection"}
        <#"Ping"                    {$tip = 'This will ping the target and provide an option to remove those unresponsive.

        Test-Connection -Count 1 -ComputerName $Target'}
        "WinRM Check"             {$tip = 'This will check the target for WinRM and provide an option to remove those unresponsive.

        Test-WSMan -ComputerName $Target'}
        "RPC Check"               {$tip = 'This will check the target for RPC and provide an option to remove those unresponsive.

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
Test-Port -ComputerName $target -Port 135'}#>
        "Start`nCollection"       {$tip = "This will execute the script!`nBe sure to verify commands`nand targets selected!"}
    }
    $MouseHoverToolTip.SetToolTip($this,$tip)
    $MouseHoverToolTip.Active         = $true   #Turns the ToolTip on and off
    #$MouseHoverToolTip.InitialDelay   = 1000    #In Milliseconds - Sets and changes the time before the ToolTip appears
    #$MouseHoverToolTip.ReshowDelay    = 3000	#Sets the time between the display of each tooltip
    $MouseHoverToolTip.UseAnimation   = $true
    #$MouseHoverToolTip.AutoPopDelay   = 3000
    $MouseHoverToolTip.UseFading      = $true
    #$MouseHoverToolTip.IsBalloon      = $true 	#Changes the Tooltip from rectangular to balloon-shaped
    #$MouseHoverToolTip.ToolTipIcon    = "Info"  #Error, Info, Warning, None
    $MouseHoverToolTip.ToolTipTitle   = 'ToolTip:'
}


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
$ComputerListPingButton           = New-Object System.Windows.Forms.Button
$ComputerListPingButton.Location  = New-Object System.Drawing.Size($Column5RightPosition,$Column5DownPosition)
$ComputerListPingButton.Size      = New-Object System.Drawing.Size($Column5BoxWidth,$Column5BoxHeight)
$ComputerListPingButton.Name      = "Ping"
$ComputerListPingButton.Text      = "Ping"
$ComputerListPingButton.Font      = New-Object System.Drawing.Font("$Font",11,0,2,1)
$ComputerListPingButton.ForeColor = "Black"
$ComputerListPingButton.add_MouseHover($MouseHover)
$ComputerListPingButton.Add_Click({
    Check-Connection -CheckType "Ping" -MessageTrue "Able to Ping" -MessageFalse "Unable to Ping"
})
$Section3ActionTab.Controls.Add($ComputerListPingButton) 

$Column5DownPosition += $Column5DownPositionShift

#============================================================================================================================================================
# Computer List - WinRM Check (Test-WSMan)
#============================================================================================================================================================
$ComputerListWinRMCheckButton           = New-Object System.Windows.Forms.Button
$ComputerListWinRMCheckButton.Location  = New-Object System.Drawing.Size($Column5RightPosition,$Column5DownPosition)
$ComputerListWinRMCheckButton.Size      = New-Object System.Drawing.Size($Column5BoxWidth,$Column5BoxHeight)
$ComputerListWinRMCheckButton.Name      = "WinRM Check"
$ComputerListWinRMCheckButton.Text      = "WinRM Check"
$ComputerListWinRMCheckButton.Font      = New-Object System.Drawing.Font("$Font",11,0,2,1)
$ComputerListWinRMCheckButton.ForeColor = "Black"
$ComputerListWinRMCheckButton.add_MouseHover($MouseHover)
$ComputerListWinRMCheckButton.Add_Click({
    Check-Connection -CheckType "WinRM Check" -MessageTrue "Able to Verify WinRM" -MessageFalse "Unable to Verify WinRM"
})
$Section3ActionTab.Controls.Add($ComputerListWinRMCheckButton) 

$Column5DownPosition += $Column5DownPositionShift

#============================================================================================================================================================
# Computer List - RPC Check (Port 135)
#============================================================================================================================================================
$ComputerListRPCCheckButton           = New-Object System.Windows.Forms.Button
$ComputerListRPCCheckButton.Location  = New-Object System.Drawing.Size($Column5RightPosition,$Column5DownPosition)
$ComputerListRPCCheckButton.Size      = New-Object System.Drawing.Size($Column5BoxWidth,$Column5BoxHeight)
$ComputerListRPCCheckButton.Name      = "RPC Check"
$ComputerListRPCCheckButton.Text      = "RPC Check"
$ComputerListRPCCheckButton.Font      = New-Object System.Drawing.Font("$Font",11,0,2,1)
$ComputerListRPCCheckButton.ForeColor = "Black"
$ComputerListRPCCheckButton.add_MouseHover($MouseHover)
$ComputerListRPCCheckButton.Add_Click({
    Check-Connection -CheckType "RPC Check" -MessageTrue "RPC Port 135 is Open" -MessageFalse "RPC Port 135 is Closed"
})
$Section3ActionTab.Controls.Add($ComputerListRPCCheckButton) 

$Column5DownPosition += $Column5DownPositionShift

#============================================================================================================================================================
# Computer List - RDP Button
#============================================================================================================================================================
$ComputerListRDPButton           = New-Object System.Windows.Forms.Button
$ComputerListRDPButton.Location  = New-Object System.Drawing.Size($Column5RightPosition,$Column5DownPosition)
$ComputerListRDPButton.Size      = New-Object System.Drawing.Size($Column5BoxWidth,$Column5BoxHeight)
$ComputerListRDPButton.Text      = 'RDP'
$ComputerListRDPButton.Font      = New-Object System.Drawing.Font("$Font",11,0,2,1)
$ComputerListRDPButton.ForeColor = "Black"
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
$Section3ActionTab.Controls.Add($ComputerListRDPButton) 

$Column5DownPosition += $Column5DownPositionShift

#============================================================================================================================================================
# Computer List - PSExec Button
#============================================================================================================================================================
$ComputerListPSExecButton           = New-Object System.Windows.Forms.Button
$ComputerListPSExecButton.Location  = New-Object System.Drawing.Size($Column5RightPosition,$Column5DownPosition)
$ComputerListPSExecButton.Size      = New-Object System.Drawing.Size($Column5BoxWidth,$Column5BoxHeight)
$ComputerListPSExecButton.Text      = "PsExec"
$ComputerListPSExecButton.Font      = New-Object System.Drawing.Font("$Font",11,0,2,1)
$ComputerListPSExecButton.ForeColor = "Black"
$ComputerListPSExecButton.Add_Click({
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
        Start-Process PowerShell -WindowStyle Hidden -ArgumentList "Start-Process '$PSExecPath' -ArgumentList '-accepteula -s \\$ComputerListCheckedBoxesSelected $UseCredential cmd'"

        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("PSExec:  $($script:ComputerListTreeViewSelected)")
        $ResultsListBox.Items.Clear()
        if ($script:Credential) { $ResultsListBox.Items.Add("./PsExec.exe -accepteula -s \\$ComputerListCheckedBoxesSelected -u '<domain\username>' -p '<password>' cmd") }
        else { $ResultsListBox.Items.Add("./PsExec.exe -accepteula -s \\$ComputerListCheckedBoxesSelected cmd") }
        $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  PSExec: $($script:ComputerListTreeViewSelected)"
        $LogMessage | Add-Content -Path $LogFile
    }
    elseif ($ComputerListCheckedBoxesSelected.count -eq 0) {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("PSExec:  Error")
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Error:  No hostname/IP selected")
        $ResultsListBox.Items.Add("        Make sure to checkbox only one hostname/IP")
        $ResultsListBox.Items.Add("        Selecting a Category will not allow you to connect to multiple hosts")    
    }
    elseif ($ComputerListCheckedBoxesSelected.count -gt 1) {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("PSExec:  Error")
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Error:  Too many hostname/IPs selected")
        $ResultsListBox.Items.Add("        Make sure to checkbox only one hostname/IP")
        $ResultsListBox.Items.Add("        Selecting a Category will not allow you to connect to multiple hosts")    
    }
})
# Test if the External Programs directory is present; if it's there load the tab
if (Test-Path "$ExternalPrograms\PsExec.exe") {
    $Section3ActionTab.Controls.Add($ComputerListPSExecButton) 
}

$Column5DownPosition += $Column5DownPositionShift

#============================================================================================================================================================
# Computer List - PS Session Button
#============================================================================================================================================================
$ComputerListPSSessionButton           = New-Object System.Windows.Forms.Button
$ComputerListPSSessionButton.Location  = New-Object System.Drawing.Size($Column5RightPosition,$Column5DownPosition)
$ComputerListPSSessionButton.Size      = New-Object System.Drawing.Size($Column5BoxWidth,$Column5BoxHeight)
$ComputerListPSSessionButton.Text      = "PS Session"
$ComputerListPSSessionButton.Font      = New-Object System.Drawing.Font("$Font",11,0,2,1)
$ComputerListPSSessionButton.ForeColor = "Black"
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
$Section3ActionTab.Controls.Add($ComputerListPSSessionButton) 

$Column5DownPosition += $Column5DownPositionShift

#============================================================================================================================================================
# Computer List - Provide Creds Checkbox
#============================================================================================================================================================

$ComputerListProvideCredentialsCheckBox          = New-Object System.Windows.Forms.CheckBox
$ComputerListProvideCredentialsCheckBox.Name     = "Use Credentials"
$ComputerListProvideCredentialsCheckBox.Text     = "$($ComputerListProvideCredentialsCheckBox.Name)"
$ComputerListProvideCredentialsCheckBox.Location = New-Object System.Drawing.Size(($Column5RightPosition + 1),($Column5DownPosition + 3))
$ComputerListProvideCredentialsCheckBox.Size     = New-Object System.Drawing.Size($Column5BoxWidth,($Column5BoxHeight - 5))
$ComputerListProvideCredentialsCheckBox.Checked  = $false
$Section3ActionTab.Controls.Add($ComputerListProvideCredentialsCheckBox)

$Column5DownPosition += $Column5DownPositionShift

#============================================================================================================================================================
# Provide Creds Button
#============================================================================================================================================================
$ProvideCredsButton          = New-Object System.Windows.Forms.Button
$ProvideCredsButton.Name     = "Provide Creds"
$ProvideCredsButton.Text     = "$($ProvideCredsButton.Name)"
#$ProvideCredsButton.UseVisualStyleBackColor = $True
$ProvideCredsButton.Location = New-Object System.Drawing.Size($Column5RightPosition,($Column5DownPosition - 3))
$ProvideCredsButton.Size     = New-Object System.Drawing.Size($Column5BoxWidth,($Column5BoxHeight))
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
$Section3ActionTab.Controls.Add($ProvideCredsButton)

$Column5DownPosition += $Column5DownPositionShift
$Column5DownPosition += $Column5DownPositionShift + 17

#============================================================================================================================================================
# Execute Button
#============================================================================================================================================================
$ComputerListExecuteButton1           = New-Object System.Windows.Forms.Button
$ComputerListExecuteButton1.Name      = "Start`nCollection"
$ComputerListExecuteButton1.Text      = "$($ComputerListExecuteButton1.Name)"
#$ComputerListExecuteButto1n.UseVisualStyleBackColor = $True
$ComputerListExecuteButton1.Location  = New-Object System.Drawing.Size($Column5RightPosition,$Column5DownPosition)
$ComputerListExecuteButton1.Size      = New-Object System.Drawing.Size($Column5BoxWidth,($Column5BoxHeight * 2))
$ComputerListExecuteButton1.Font      = New-Object System.Drawing.Font("$Font",12,1,2,1)
$ComputerListExecuteButton1.ForeColor = "Red"
$ComputerListExecuteButton1.add_MouseHover($MouseHover)

### $ComputerListExecuteButton1.Add_Click($ExecuteScriptHandler) ### Is located lower in the script
$Section3ActionTab.Controls.Add($ComputerListExecuteButton1)

##############################################################################################################################################################
##
## Section 3 Computer List - Control Tab
##
##############################################################################################################################################################

$Section3ManageListTab           = New-Object System.Windows.Forms.TabPage
$Section3ManageListTab.Text      = "Manage List"
$Section3ManageListTab.Location  = New-Object System.Drawing.Size($Column5RightPosition,$Column5DownPosition) 
$Section3ManageListTab.Size      = New-Object System.Drawing.Size($Column5BoxWidth,$Column5BoxHeight) 
$Section3ManageListTab.UseVisualStyleBackColor = $True
$Section3TabControl.Controls.Add($Section3ManageListTab)


#####################################################################################################################################
## Section 3 Computer List - Control Tab Buttons
#####################################################################################################################################

$Column5DownPosition = $Column5DownPositionStart

#============================================================================================================================================================
# ComputerList TreeView - Import .csv Button
#============================================================================================================================================================
$ComputerListTreeViewImportCsvButton           = New-Object System.Windows.Forms.Button
$ComputerListTreeViewImportCsvButton.Name      = "Import .csv"
$ComputerListTreeViewImportCsvButton.Text      = "$($ComputerListTreeViewImportCsvButton.Name)"
$ComputerListTreeViewImportCsvButton.UseVisualStyleBackColor = $True
$ComputerListTreeViewImportCsvButton.Location  = New-Object System.Drawing.Size($Column5RightPosition,$Column5DownPosition)
$ComputerListTreeViewImportCsvButton.Size      = New-Object System.Drawing.Size(110,22)
$ComputerListTreeViewImportCsvButton.Font      = New-Object System.Drawing.Font("$Font",11,0,2,1)
$ComputerListTreeViewImportCsvButton.ForeColor = "Green"
$ComputerListTreeViewImportCsvButton.Add_Click({
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    $ComputerListTreeViewImportCsvOpenFileDialog                  = New-Object System.Windows.Forms.OpenFileDialog
    $ComputerListTreeViewImportCsvOpenFileDialog.Title            = "Import .csv Data"
    $ComputerListTreeViewImportCsvOpenFileDialog.InitialDirectory = "$PoShHome"
    $ComputerListTreeViewImportCsvOpenFileDialog.filter           = "CSV (*.csv)| *.csv|Excel (*.xlsx)| *.xlsx|Excel (*.xls)| *.xls|All files (*.*)|*.*"
    $ComputerListTreeViewImportCsvOpenFileDialog.ShowHelp         = $true
    $ComputerListTreeViewImportCsvOpenFileDialog.ShowDialog()     | Out-Null
    $ComputerListTreeViewImportCsv    = Import-Csv $($ComputerListTreeViewImportCsvOpenFileDialog.filename) | Select-Object -Property Name, IPv4Address, OperatingSystem, CanonicalName | Sort-Object -Property CanonicalName

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
$ComputerListTreeViewImportTxtButton           = New-Object System.Windows.Forms.Button
$ComputerListTreeViewImportTxtButton.Name      = "Import .txt"
$ComputerListTreeViewImportTxtButton.Text      = "$($ComputerListTreeViewImportTxtButton.Name)"
$ComputerListTreeViewImportTxtButton.UseVisualStyleBackColor = $True
$ComputerListTreeViewImportTxtButton.Location  = New-Object System.Drawing.Size($Column5RightPosition,$Column5DownPosition)
$ComputerListTreeViewImportTxtButton.Size      = New-Object System.Drawing.Size(110,22)
$ComputerListTreeViewImportTxtButton.Font      = New-Object System.Drawing.Font("$Font",11,0,2,1)
$ComputerListTreeViewImportTxtButton.ForeColor = "Green"
$ComputerListTreeViewImportTxtButton.Add_Click({
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    $ComputerListTreeViewImportTxtOpenFileDialog                  = New-Object System.Windows.Forms.OpenFileDialog
    $ComputerListTreeViewImportTxtOpenFileDialog.Title            = "Import .txt Data"
    $ComputerListTreeViewImportTxtOpenFileDialog.InitialDirectory = "$PoShHome"
    $ComputerListTreeViewImportTxtOpenFileDialog.filter           = "TXT (*.txt)| *.txt|All files (*.*)|*.*"
    $ComputerListTreeViewImportTxtOpenFileDialog.ShowHelp         = $true
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
$ComputerListTreeViewAddHostnameIPButton           = New-Object System.Windows.Forms.Button
$ComputerListTreeViewAddHostnameIPButton.Location  = New-Object System.Drawing.Size($Column5RightPosition,$Column5DownPosition)
$ComputerListTreeViewAddHostnameIPButton.Size      = New-Object System.Drawing.Size($Column5BoxWidth,$Column5BoxHeight)
$ComputerListTreeViewAddHostnameIPButton.Text      = "Add"
$ComputerListTreeViewAddHostnameIPButton.Font      = New-Object System.Drawing.Font("$Font",11,0,2,1)
$ComputerListTreeViewAddHostnameIPButton.ForeColor = "Green"
$ComputerListTreeViewAddHostnameIPButton.Add_Click({
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Add hostname/IP:")
    $ResultsListBox.Items.Clear()
    $ResultsListBox.Items.Add("Enter a hostname/IP")

    #----------------------------------
    # ComputerList TreeView Popup Form
    #----------------------------------
    $ComputerListTreeViewPopup               = New-Object system.Windows.Forms.Form
    $ComputerListTreeViewPopup.Text          = "Add Hostname/IP"
    $ComputerListTreeViewPopup.Size          = New-Object System.Drawing.Size(335,177)
    $ComputerListTreeViewPopup.StartPosition = "CenterScreen"

    #-----------------------------------------------------
    # ComputerList TreeView Popup Add Hostname/IP TextBox
    #-----------------------------------------------------
    $ComputerListTreeViewPopupAddTextBox          = New-Object System.Windows.Forms.TextBox
    $ComputerListTreeViewPopupAddTextBox.Text     = "Enter a hostname/IP"
    $ComputerListTreeViewPopupAddTextBox.Size     = New-Object System.Drawing.Size(300,25)
    $ComputerListTreeViewPopupAddTextBox.Location = New-Object System.Drawing.Size(10,10)
    $ComputerListTreeViewPopup.Controls.Add($ComputerListTreeViewPopupAddTextBox)

    #-----------------------------------------
    # ComputerList TreeView Popup OS ComboBox
    #-----------------------------------------
    $ComputerListTreeViewPopupOSComboBox                    = New-Object System.Windows.Forms.ComboBox
    $ComputerListTreeViewPopupOSComboBox.Text               = "Select an Operating System (or type in a new one)"
    $ComputerListTreeViewPopupOSComboBox.Size               = New-Object System.Drawing.Size(300,25)
    $ComputerListTreeViewPopupOSComboBox.Location           = New-Object System.Drawing.Size(10,($ComputerListTreeViewPopupAddTextBox.Location.Y + $ComputerListTreeViewPopupAddTextBox.Size.Height + 10))
    $ComputerListTreeViewPopupOSComboBox.AutoCompleteSource = "ListItems" # Options are: FileSystem, HistoryList, RecentlyUsedList, AllURL, AllSystemSources, FileSystemDirectories, CustomSource, ListItems, None
    $ComputerListTreeViewPopupOSComboBox.AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
        $ComputerListTreeViewOSCategoryList = $script:ComputerListTreeViewData | Select-Object -ExpandProperty OperatingSystem -Unique
        # Dynamically creates the OS Category combobox list used for OS Selection
        ForEach ($OS in $ComputerListTreeViewOSCategoryList) { $ComputerListTreeViewPopupOSComboBox.Items.Add($OS) }
    $ComputerListTreeViewPopup.Controls.Add($ComputerListTreeViewPopupOSComboBox)

    #-----------------------------------------
    # ComputerList TreeView Popup OU ComboBox
    #-----------------------------------------
    $ComputerListTreeViewPopupOUComboBox                    = New-Object System.Windows.Forms.ComboBox
    $ComputerListTreeViewPopupOUComboBox.Text               = "Select an Organizational Unit / Canonical Name"
    $ComputerListTreeViewPopupOUComboBox.Size               = New-Object System.Drawing.Size(300,25)
    $ComputerListTreeViewPopupOUComboBox.Location           = New-Object System.Drawing.Size(10,($ComputerListTreeViewPopupOSComboBox.Location.Y + $ComputerListTreeViewPopupOSComboBox.Size.Height + 10))        
    $ComputerListTreeViewPopupOUComboBox.AutoCompleteSource = "ListItems" # Options are: FileSystem, HistoryList, RecentlyUsedList, AllURL, AllSystemSources, FileSystemDirectories, CustomSource, ListItems, None
    $ComputerListTreeViewPopupOUComboBox.AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
        $ComputerListTreeViewOUCategoryList = $script:ComputerListTreeViewData | Select-Object -ExpandProperty CanonicalName -Unique
        # Dynamically creates the OU Category combobox list used for OU Selection
        ForEach ($OU in $ComputerListTreeViewOUCategoryList) { $ComputerListTreeViewPopupOUComboBox.Items.Add($OU) }
    $ComputerListTreeViewPopup.Controls.Add($ComputerListTreeViewPopupOUComboBox)

    #---------------------------------------------
    # function to add a hostname/IP to a category
    #---------------------------------------------
    function AddHost-ComputerListTreeView {
        if ($script:ComputerListTreeViewData.Name -contains $ComputerListTreeViewPopupAddTextBox.Text) {
            #$script:ComputerListTreeViewData = $script:ComputerListTreeViewData | Where-Object {$_.Name -ne $Entry.text}
            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("Add Hostname/IP:  Error")
            $ResultsListBox.Items.Clear()
            $ResultsListBox.Items.Add("$($ComputerListTreeViewPopupAddTextBox.Text) already exists with the following data:")
            $ResultsListBox.Items.Add("- OU/CN: $($($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $ComputerListTreeViewPopupAddTextBox.Text}).CanonicalName)")
            $ResultsListBox.Items.Add("- OS:    $($($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $ComputerListTreeViewPopupAddTextBox.Text}).OperatingSystem)")
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
                CanonicalName   = $ComputerListTreeViewPopupOUComboBox.SelectedItem
                IPv4Address     = "No IP Available"
            }        
            $script:ComputerListTreeViewData += $ComputerListTreeViewAddHostnameIP
            $ComputerListTreeView.ExpandAll()
            $ComputerListTreeViewPopup.close()
        }
    }
    $ComputerListTreeView.ExpandAll()
    Populate-ComputerListTreeViewDefaultData
    TempSave-HostData

    # Moves the hostname/IPs to the new Category
    $ComputerListTreeViewPopupAddTextBox.Add_KeyDown({ 
        if ($_.KeyCode -eq "Enter") { 
            AddHost-ComputerListTreeView
        }
    })

    #--------------------------------------------
    # ComputerList TreeView Popup Execute Button
    #--------------------------------------------
    $ComputerListTreeViewPopupMoveButton          = New-Object System.Windows.Forms.Button
    $ComputerListTreeViewPopupMoveButton.Text     = "Execute"
    $ComputerListTreeViewPopupMoveButton.Size     = New-Object System.Drawing.Size(100,25)
    $ComputerListTreeViewPopupMoveButton.Location = New-Object System.Drawing.Size(210,($ComputerListTreeViewPopupOUComboBox.Location.Y + $ComputerListTreeViewPopupOUComboBox.Size.Height + 10))
    $ComputerListTreeViewPopupMoveButton.Add_Click({
        AddHost-ComputerListTreeView
    })
    $ComputerListTreeViewPopup.Controls.Add($ComputerListTreeViewPopupMoveButton)

    $ComputerListTreeViewPopup.ShowDialog()               
})
$Section3ManageListTab.Controls.Add($ComputerListTreeViewAddHostnameIPButton) 

$Column5DownPosition += $Column5DownPositionShift

#============================================================================================================================================================
# Computer List - Treeview - Delete Button
#============================================================================================================================================================
$ComputerListDeleteButton               = New-Object System.Windows.Forms.Button
$ComputerListDeleteButton.Location      = New-Object System.Drawing.Size($Column5RightPosition,$Column5DownPosition)
$ComputerListDeleteButton.Size          = New-Object System.Drawing.Size($Column5BoxWidth,$Column5BoxHeight)
$ComputerListDeleteButton.Text          = 'Delete'
$ComputerListDeleteButton.Add_Click({
    # This array stores checkboxes that are check; a minimum of at least one checkbox will be needed later in the script
    $ComputerListCheckedBoxesSelected = @()
    [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $ComputerListTreeView.Nodes 
    foreach ($root in $AllHostsNode) { 
        if ($root.Checked) {
            $ComputerListCheckedBoxesSelected += $root.Text
        }
        foreach ($Category in $root.Nodes) { 
            if ($Category.Checked) {
                $ComputerListCheckedBoxesSelected += $Category.Text
            }
            foreach ($Entry in $Category.nodes) {
                if ($Entry.Checked) {
                    $ComputerListCheckedBoxesSelected += $Entry.Text
                }
            }       
        }         
    }

    if ($ComputerListCheckedBoxesSelected.count -ge 1) {
        # Removes the original hostname/IP that was copied above
        foreach ($i in $ComputerListCheckedBoxesSelected) {
            foreach ($root in $AllHostsNode) { 
                if (($i -contains $root.text) -and ($root.Checked -eq $True)) {
                    $ResultsListBox.Items.Add($root.text)
                    $root.remove()
                    Initialize-ComputerListTreeView
                    $Null = $ComputerListTreeView.Nodes.Add($script:TreeNodeComputerList)
                    $ComputerListTreeView.ExpandAll()
                }
                foreach ($Category in $root.Nodes) { 
                    if (($i -contains $Category.text) -and ($Category.Checked -eq $True)) {
                        $ResultsListBox.Items.Add($Category.text)
                        $Category.remove()
                        foreach ($Entry in $Category.nodes) { 
                            $ResultsListBox.Items.Add($Entry.text)
                            $Entry.remove()
                            $script:ComputerListTreeViewData = $script:ComputerListTreeViewData | Where-Object {$_.Name -ne $Entry.text}
                        }
                    }
                    foreach ($Entry in $Category.nodes) { 
                        if (($i -contains $Entry.text) -and ($Entry.Checked -eq $True)) {
                            $ResultsListBox.Items.Add($Entry.text)
                            # This removes the host from the treeview
                            $Entry.remove()
            
                            # This removes the host from the variable storing the all the computers
                            $script:ComputerListTreeViewData = $script:ComputerListTreeViewData | Where-Object {$_.Name -ne $Entry.text}
                        }
                    }
                }
            }
        }
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Deleted:  $($ComputerListCheckedBoxesSelected.Count) Selected Items")
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("The following hostnames/IPs or categories have been deleted:")

        $ComputerListTreeViewPopup.close()
    }
    else {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Delete Selection:  Error")
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Error: No Category, hostname, or IP selected")
        $ResultsListBox.Items.Add("       Make sure to checkbox at least one hostname/IP or Category")
        $ResultsListBox.Items.Add("       Selecting a Category will remove contents within it")
    }
    TempSave-HostData
})
$Section3ManageListTab.Controls.Add($ComputerListDeleteButton) 

$Column5DownPosition += $Column5DownPositionShift

#============================================================================================================================================================
# Computer List - Treeview - Move Button
#============================================================================================================================================================
$ComputerListMoveButton               = New-Object System.Windows.Forms.Button
$ComputerListMoveButton.Location      = New-Object System.Drawing.Size($Column5RightPosition,$Column5DownPosition)
$ComputerListMoveButton.Size          = New-Object System.Drawing.Size($Column5BoxWidth,$Column5BoxHeight)
$ComputerListMoveButton.Text          = 'Move'
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
        $ComputerListTreeViewPopup               = New-Object system.Windows.Forms.Form
        $ComputerListTreeViewPopup.Text          = "Move"
        $ComputerListTreeViewPopup.Size          = New-Object System.Drawing.Size(330,107)
        $ComputerListTreeViewPopup.StartPosition = "CenterScreen"

        #----------------------------------------------
        # ComputerList TreeView Popup Execute ComboBox
        #----------------------------------------------
        $ComputerListTreeViewPopupMoveComboBox          = New-Object System.Windows.Forms.ComboBox
        $ComputerListTreeViewPopupMoveComboBox.Text     = "Select A Category"
        $ComputerListTreeViewPopupMoveComboBox.Size     = New-Object System.Drawing.Size(300,25)
        $ComputerListTreeViewPopupMoveComboBox.Location = New-Object System.Drawing.Size(10,10)

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
            $ComputerListTreeViewPopup.close()
        }           
        # Moves the hostname/IPs to the new Category
        $ComputerListTreeViewPopupMoveComboBox.Add_KeyDown({ 
            if ($_.KeyCode -eq "Enter") { 
                Move-ComputerListTreeViewSelected
            }
        })
        $ComputerListTreeViewPopup.Controls.Add($ComputerListTreeViewPopupMoveComboBox)

        #--------------------------------------------
        # ComputerList TreeView Popup Execute Button
        #--------------------------------------------
        $ComputerListTreeViewPopupMoveButton          = New-Object System.Windows.Forms.Button
        $ComputerListTreeViewPopupMoveButton.Text     = "Execute"
        $ComputerListTreeViewPopupMoveButton.Size     = New-Object System.Drawing.Size(100,25)
        $ComputerListTreeViewPopupMoveButton.Location = New-Object System.Drawing.Size(210,($ComputerListTreeViewPopupMoveComboBox.Size.Height + 15))
        $ComputerListTreeViewPopupMoveButton.Add_Click({
            Move-ComputerListTreeViewSelected
        })
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
$Section3ManageListTab.Controls.Add($ComputerListMoveButton) 

$Column5DownPosition += $Column5DownPositionShift

#============================================================================================================================================================
# Computer List - Treeview - Rename Button
#============================================================================================================================================================
$ComputerListRenameButton               = New-Object System.Windows.Forms.Button
$ComputerListRenameButton.Location      = New-Object System.Drawing.Size($Column5RightPosition,$Column5DownPosition)
$ComputerListRenameButton.Size          = New-Object System.Drawing.Size($Column5BoxWidth,$Column5BoxHeight)
$ComputerListRenameButton.Text          = 'Rename'
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

        #---------------------------------------------
        # ComputerList TreeView Popup Execute TextBox
        #---------------------------------------------
        $ComputerListTreeViewRenamePopupTextBox          = New-Object System.Windows.Forms.TextBox
        $ComputerListTreeViewRenamePopupTextBox.Text     = "New Hostname/IP"
        $ComputerListTreeViewRenamePopupTextBox.Size     = New-Object System.Drawing.Size(300,25)
        $ComputerListTreeViewRenamePopupTextBox.Location = New-Object System.Drawing.Size(10,10)

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
                $ResultsListBox.Items.Add("Computer $($ComputerListTreeViewPopupMoveComboBox.SelectedItem) has been renamed to $($ComputerListTreeViewRenamePopupTextBox.Text)")
            }
            $ComputerListTreeViewRenamePopup.close()
        }           
           
        # Moves the hostname/IPs to the new Category
        $ComputerListTreeViewRenamePopupTextBox.Add_KeyDown({ 
            if ($_.KeyCode -eq "Enter") { 
                Rename-ComputerListTreeViewSelected
            }
        })
        $ComputerListTreeViewRenamePopup.Controls.Add($ComputerListTreeViewRenamePopupTextBox)

        #--------------------------------------------
        # ComputerList TreeView Popup Execute Button
        #--------------------------------------------
        $ComputerListTreeViewRenamePopupButton          = New-Object System.Windows.Forms.Button
        $ComputerListTreeViewRenamePopupButton.Text     = "Execute"
        $ComputerListTreeViewRenamePopupButton.Size     = New-Object System.Drawing.Size(100,25)
        $ComputerListTreeViewRenamePopupButton.Location = New-Object System.Drawing.Size(210,($ComputerListTreeViewRenamePopupTextBox.Size.Height + 15))
        $ComputerListTreeViewRenamePopupButton.Add_Click({
            Rename-ComputerListTreeViewSelected
        })
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
# Computer List - Treeview - Deselect All Button
#============================================================================================================================================================
$ComputerListDeselectAllButton           = New-Object System.Windows.Forms.Button
$ComputerListDeselectAllButton.Location  = New-Object System.Drawing.Size($Column5RightPosition,$Column5DownPosition)
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
$Section3ManageListTab.Controls.Add($ComputerListDeselectAllButton) 

$Column5DownPosition += $Column5DownPositionShift

#============================================================================================================================================================
# Computer List - Treeview - Collapse / Expand Button
#============================================================================================================================================================
$ComputerListTreeViewCollapseAllButton          = New-Object System.Windows.Forms.Button
$ComputerListTreeViewCollapseAllButton.Location = New-Object System.Drawing.Size($Column5RightPosition,$Column5DownPosition)
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
$Section3ManageListTab.Controls.Add($ComputerListTreeViewCollapseAllButton) 

$Column5DownPosition += $Column5DownPositionShift

#============================================================================================================================================================
# Computer List - TreeView - Save Button
#============================================================================================================================================================
$ComputerListTreeViewSaveButton          = New-Object System.Windows.Forms.Button
$ComputerListTreeViewSaveButton.Location = New-Object System.Drawing.Size($Column5RightPosition,$Column5DownPosition)
$ComputerListTreeViewSaveButton.Size     = New-Object System.Drawing.Size($Column5BoxWidth,$Column5BoxHeight)
$ComputerListTreeViewSaveButton.Text     = "Save"
$ComputerListTreeViewSaveButton.Add_Click({
    Save-HostData
})
$Section3ManageListTab.Controls.Add($ComputerListTreeViewSaveButton) 

$Column5DownPosition += $Column5DownPositionShift + 17

#============================================================================================================================================================
# Execute Button
#============================================================================================================================================================
$ComputerListExecuteButton2           = New-Object System.Windows.Forms.Button
$ComputerListExecuteButton2.Name      = "Start`nCollection"
$ComputerListExecuteButton2.Text      = "$($ComputerListExecuteButton2.Name)"
$ComputerListExecuteButton2.UseVisualStyleBackColor = $True
$ComputerListExecuteButton2.Location  = New-Object System.Drawing.Size($Column5RightPosition,$Column5DownPosition)
$ComputerListExecuteButton2.Size      = New-Object System.Drawing.Size($Column5BoxWidth,($Column5BoxHeight * 2))
$ComputerListExecuteButton2.Font      = New-Object System.Drawing.Font("$Font",12,1,2,1)
$ComputerListExecuteButton2.ForeColor = "Red"
### $ComputerListExecuteButton2.Add_Click($ExecuteScriptHandler) ### Is located lower in the script
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
$Section3ResultsTabWidth      = 738
$Section3ResultsTabHeight     = 250

$Section3DownPosition += $Section3DownPositionShift
$Section3DownPosition += $Section3DownPositionShift

#--------------
# Status Label
#--------------
$StatusLabel           = New-Object System.Windows.Forms.Label
$StatusLabel.Location  = New-Object System.Drawing.Size(($Section3RightPosition),($Section3DownPosition + 1))
$StatusLabel.Size      = New-Object System.Drawing.Size(60,($Section3ProgressBarHeight - 2))
$StatusLabel.Text      = "Status:"
$StatusLabel.Font      = New-Object System.Drawing.Font("$Font",10,1,3,1)
$StatusLabel.ForeColor = "Blue"
$PoShACME.Controls.Add($StatusLabel)  

#----------------
# Status Listbox
#----------------
$StatusListBox          = New-Object System.Windows.Forms.ListBox
$StatusListBox.Name     = "StatusListBox"
$StatusListBox.FormattingEnabled = $True
$StatusListBox.Location = New-Object System.Drawing.Size(($Section3RightPosition + 60),$Section3DownPosition) 
$StatusListBox.Size     = New-Object System.Drawing.Size($Section3ProgressBarWidth,$Section3ProgressBarHeight)
$StatusListBox.Items.Add("") | Out-Null
$PoShACME.Controls.Add($StatusListBox)

$Section3DownPosition += $Section3DownPositionShift

# ---------------------
# Progress Bar 1 Label
#----------------------
$ProgressBar1Label          = New-Object System.Windows.Forms.Label
$ProgressBar1Label.Location = New-Object System.Drawing.Size(($Section3RightPosition),($Section3DownPosition - 4))
$ProgressBar1Label.Size     = New-Object System.Drawing.Size(60,($Section3ProgressBarHeight - 7))
$ProgressBar1Label.Text     = "Section:"
$PoShACME.Controls.Add($ProgressBar1Label)  


#----------------------------
# Progress Bar 1 ProgressBar
#----------------------------
$ProgressBar1          = New-Object System.Windows.Forms.ProgressBar
$ProgressBar1.Style    = "Continuous"
#$ProgressBar1.Maximum  = 10
$ProgressBar1.Minimum  = 0
$ProgressBar1.Location = new-object System.Drawing.Size(($Section3RightPosition + 60),($Section3DownPosition - 2))
$ProgressBar1.size     = new-object System.Drawing.Size($Section3ProgressBarWidth,10)
#$ProgressBar1.Value     = 0
#$ProgressBar1.Step     = 1
$PoSHACME.Controls.Add($ProgressBar1)

$Section3DownPosition += $Section3DownPositionShift - 9

#----------------------
# Progress Bar 2 Label
#----------------------
$ProgressBar2Label          = New-Object System.Windows.Forms.Label
$ProgressBar2Label.Location = New-Object System.Drawing.Size(($Section3RightPosition),($Section3DownPosition - 4))
$ProgressBar2Label.Size     = New-Object System.Drawing.Size(60,($Section3ProgressBarHeight - 4))
$ProgressBar2Label.Text     = "Overall:"
$PoShACME.Controls.Add($ProgressBar2Label)  

#----------------------------
# Progress Bar 2 ProgressBar
#----------------------------
$ProgressBar2          = New-Object System.Windows.Forms.ProgressBar
$ProgressBar2.Maximum  = $ProgressBar2Max
$ProgressBar2.Minimum  = 0
$ProgressBar2.Location = new-object System.Drawing.Size(($Section3RightPosition + 60),($Section3DownPosition - 2))
$ProgressBar2.size     = new-object System.Drawing.Size($Section3ProgressBarWidth,10)
$ProgressBar2.Count    = 0
$PoSHACME.Controls.Add($ProgressBar2)

$Section3DownPosition += $Section3DownPositionShift - 9


##############################################################################################################################################################
##############################################################################################################################################################
##
## Section 3 Tab Control
##
##############################################################################################################################################################
##############################################################################################################################################################

$Section4TabControl               = New-Object System.Windows.Forms.TabControl
$Section4TabControl.Name          = "Main Tab Window"
$Section4TabControl.SelectedIndex = 0
$Section4TabControl.ShowToolTips  = $True
$Section4TabControl.Location      = New-Object System.Drawing.Size($Section3RightPosition,$Section3DownPosition) 
$Section4TabControl.Size          = New-Object System.Drawing.Size($Section3ResultsTabWidth,$Section3ResultsTabHeight)
$PoShACME.Controls.Add($Section4TabControl)

##############################################################################################################################################################
##
## Section 3 Status SubTab
##
##############################################################################################################################################################

$Section3ResultsTab          = New-Object System.Windows.Forms.TabPage
$Section3ResultsTab.Text     = "Results"
$Section3ResultsTab.Name     = "Results Tab"
$Section3ResultsTab.UseVisualStyleBackColor = $True
$Section4TabControl.Controls.Add($Section3ResultsTab)

#------------------------------
# Results - Add OpNotes Button
#------------------------------
$ResultsTabOpNotesAddButton           = New-Object System.Windows.Forms.Button
$ResultsTabOpNotesAddButton.Text      = "Add Selected To OpNotes"
$ResultsTabOpNotesAddButton.Location  = New-Object System.Drawing.Size(565,200)
$ResultsTabOpNotesAddButton.Size      = New-Object System.Drawing.Size(150,25)
$ResultsTabOpNotesAddButton.Font      = New-Object System.Drawing.Font("$Font",11,0,2,1)
$ResultsTabOpNotesAddButton.ForeColor = "Green"
$ResultsTabOpNotesAddButton.Add_Click({
    $Section1TabControl.SelectedTab   = $Section1OpNotesTab
    if ($ResultsListBox.Items.Count -gt 0) {
        foreach ( $Line in $ResultsListBox.SelectedItems ){
            $OpNotesListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  $Line")
            Add-Content -Path $OpNotesFileWriteOnly -Value $ResultsListBox.SelectedItems -Force        
        }
        Save-OpNotes
    }
})
$Section3ResultsTab.Controls.Add($ResultsTabOpNotesAddButton) 

#-----------------
# Results ListBox
#-----------------
$ResultsListBox                     = New-Object System.Windows.Forms.ListBox
$ResultsListBox.Name                = "ResultsListBox"
$ResultsListBox.Location            = New-Object System.Drawing.Size(-1,-1) 
$ResultsListBox.Size                = New-Object System.Drawing.Size(($Section3ResultsTabWidth - 3),($Section3ResultsTabHeight - 15))
$ResultsListBox.FormattingEnabled   = $True
$ResultsListBox.SelectionMode       = 'MultiExtended'
$ResultsListBox.ScrollAlwaysVisible = $True
$ResultsListBox.AutoSize            = $False
$ResultsListBox.Font                = New-Object System.Drawing.Font("Courier New",11,0,2,1)

$PoShACMEAboutFile     = "$ResourcesDirectory\About\PoSh-ACME.txt"
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


##############################################################################################################################################################
##
## Section 3 Host Data SubTab
##
##############################################################################################################################################################

$Section3HostDataTab          = New-Object System.Windows.Forms.TabPage
$Section3HostDataTab.Text     = "Host Data"
$Section3HostDataTab.Name     = "Host Data Tab"
$Section3HostDataTab.UseVisualStyleBackColor = $True
$Section4TabControl.Controls.Add($Section3HostDataTab)

#------------------------------
# Host Data - Hostname Textbox
#------------------------------
$Section3HostDataName          = New-Object System.Windows.Forms.TextBox
$Section3HostDataName.Name     = "Host Data - Hostname"
$Section3HostDataName.Location = New-Object System.Drawing.Size(0,3) 
$Section3HostDataName.Size     = New-Object System.Drawing.Size(250,25)
$Section3HostDataName.Font     = New-Object System.Drawing.Font("$Font",11,0,2,1)
$Section3HostDataName.ReadOnly = $true
$Section3HostDataName.add_MouseHover($MouseHover)
$Section3HostDataTab.Controls.Add($Section3HostDataName)

#------------------------
# Host Data - OS Textbox
#------------------------
$Section3HostDataOS          = New-Object System.Windows.Forms.TextBox
$Section3HostDataOS.Name     = "Host Data - OS"
$Section3HostDataOS.Location = New-Object System.Drawing.Size(0,($Section3HostDataName.Location.Y + $Section3HostDataName.Size.Height + 4)) 
$Section3HostDataOS.Size     = New-Object System.Drawing.Size(250,25)
$Section3HostDataOS.Font     = New-Object System.Drawing.Font("$Font",11,0,2,1)
$Section3HostDataOS.ReadOnly = $true
$Section3HostDataOS.add_MouseHover($MouseHover)
$Section3HostDataTab.Controls.Add($Section3HostDataOS)

<#
#============================================================================================================================================================
# Host Data - Move Button
#============================================================================================================================================================
$HostDataMoveButton               = New-Object System.Windows.Forms.Button
$HostDataMoveButton.Location      = New-Object System.Drawing.Size(($Section3HostDataOS.Location.X + $Section3HostDataOS.Size.Width + 5),($Section3HostDataOS.Location.Y))
$HostDataMoveButton.Size          = New-Object System.Drawing.Size($Column5BoxWidth,$Column5BoxHeight)
$HostDataMoveButton.Text          = "Move"
#The .addclick commands are located with the other Move Button### 
$HostDataMoveButton.Add_Click({   })
$Section3HostDataTab.Controls.Add($HostDataMoveButton) 
#>


#------------------------
# Host Data - OU Textbox
#------------------------
$Section3HostDataOU          = New-Object System.Windows.Forms.TextBox
$Section3HostDataOU.Name     = "Host Data - OU"
$Section3HostDataOU.Location = New-Object System.Drawing.Size(0,($Section3HostDataOS.Location.Y + $Section3HostDataOS.Size.Height + 4)) 
$Section3HostDataOU.Size     = New-Object System.Drawing.Size(250,25)
$Section3HostDataOU.Font     = New-Object System.Drawing.Font("$Font",11,0,2,1)
$Section3HostDataOU.ReadOnly = $true
$Section3HostDataOU.add_MouseHover($MouseHover)
$Section3HostDataTab.Controls.Add($Section3HostDataOU)

#------------------------
# Host Data - IP Textbox
#------------------------
$Section3HostDataIP          = New-Object System.Windows.Forms.TextBox
$Section3HostDataIP.Name     = "Host Data - IP"
$Section3HostDataIP.Location = New-Object System.Drawing.Size(0,($Section3HostDataOU.Location.Y + $Section3HostDataOU.Size.Height + 4)) 
$Section3HostDataIP.Size     = New-Object System.Drawing.Size(250,25)
$Section3HostDataIP.Font     = New-Object System.Drawing.Font("$Font",11,0,2,1)
$Section3HostDataIP.ReadOnly = $false
$Section3HostDataIP.add_MouseHover($MouseHover)
$Section3HostDataTab.Controls.Add($Section3HostDataIP)

#---------------------------
# Host Data - Notes Textbox
#---------------------------
$Section3HostDataNotes            = New-Object System.Windows.Forms.TextBox
$Section3HostDataNotes.Name       = "Host Data - Notes"
$Section3HostDataNotes.Location   = New-Object System.Drawing.Size(0,($Section3HostDataIP.Location.Y + $Section3HostDataIP.Size.Height + 4)) 
$Section3HostDataNotes.Size       = New-Object System.Drawing.Size(727,116)
$Section3HostDataNotes.Font       = New-Object System.Drawing.Font("$Font",11,0,2,1)
$Section3HostDataNotes.ReadOnly   = $false
$Section3HostDataNotes.Multiline  = $True
$Section3HostDataNotes.ScrollBars = $True
$Section3HostDataNotes.WordWrap   = $True
$Section3HostDataNotes.add_MouseHover($MouseHover)
$Section3HostDataTab.Controls.Add($Section3HostDataNotes)

#-------------------------
# Host Data - Save Button
#-------------------------
$Section3HostDataSaveButton           = New-Object System.Windows.Forms.Button
$Section3HostDataSaveButton.Name      = "Host Data - Save"
$Section3HostDataSaveButton.Text      = "Save"
$Section3HostDataSaveButton.Location  = New-Object System.Drawing.Size(629,73) 
$Section3HostDataSaveButton.Size      = New-Object System.Drawing.Size(100,22)
$Section3HostDataSaveButton.Font      = New-Object System.Drawing.Font("$Font",11,0,2,1)
$Section3HostDataSaveButton.ForeColor = 'Red'
$Section3HostDataSaveButton.Add_Click({
    $ComputerListTreeViewSaveData = @()
    Foreach($Computer in $script:ComputerListTreeViewData) {
            $ComputerListTreeViewSaveDataTemp = New-Object PSObject -Property @{ Name = $Computer.Name}        
            $ComputerListTreeViewSaveDataTemp | Add-Member -MemberType NoteProperty -Name OperatingSystem -Value $Computer.OperatingSystem -Force        
            $ComputerListTreeViewSaveDataTemp | Add-Member -MemberType NoteProperty -Name CanonicalName -Value $Computer.CanonicalName -Force  
            if ($Computer.Name -eq $Section3HostDataName.Text) {
                $ComputerListTreeViewSaveDataTemp | Add-Member -MemberType NoteProperty -Name Notes -Value $Section3HostDataNotes.Text -Force }
            else {
                $ComputerListTreeViewSaveDataTemp | Add-Member -MemberType NoteProperty -Name IPv4Address -Value $Computer.IPv4Address -Force
                $ComputerListTreeViewSaveDataTemp | Add-Member -MemberType NoteProperty -Name Notes -Value $Computer.Notes -Force }

            if ($Computer.Name -eq $Section3HostDataName.Text) {
                $ComputerListTreeViewSaveDataTemp | Add-Member -MemberType NoteProperty -Name IPv4Address -Value $Section3HostDataIP.Text -Force
                $ComputerListTreeViewSaveDataTemp | Add-Member -MemberType NoteProperty -Name Notes -Value $Section3HostDataNotes.Text -Force }
            else {
                $ComputerListTreeViewSaveDataTemp | Add-Member -MemberType NoteProperty -Name Notes -Value $Computer.Notes -Force }
        $ComputerListTreeViewSaveData += $ComputerListTreeViewSaveDataTemp
    }
    $script:ComputerListTreeViewData  = $ComputerListTreeViewSaveData
    $ComputerListTreeViewSaveDataTemp = $null
    $ComputerListTreeViewSaveData     = $null

    # Saves the TreeView Data to File
    $script:ComputerListTreeViewData | Export-Csv $ComputerListTreeViewFileSave -NoTypeInformation
    
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Saved Host Data:  $($Section3HostDataName.Text)")

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
        $envnames = $script:CSVFileMatch
        $script:HostDataCsvDateTime = @()
        foreach ($Csv in $envnames) {
            #$a = $CollectedDataDirectory #not use, just a note
            $DirDateTime = $Csv.split('\')[-4]
            $script:CsvFileExtention = $Csv.split('\')[-3,-2,-1] -join '\'
            $script:HostDataCsvDateTime += $DirDateTime
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
    $Section3HostDataSelectionComboBox                    = New-Object System.Windows.Forms.ComboBox
    $Section3HostDataSelectionComboBox.Location           = New-Object System.Drawing.Size(260,3)
    $Section3HostDataSelectionComboBox.Size               = New-Object System.Drawing.Size(200,25)
    $Section3HostDataSelectionComboBox.Text               = "Host Data - Selection"
    $Section3HostDataSelectionComboBox.Font               = New-Object System.Drawing.Font("$Font",11,0,2,1)
    $Section3HostDataSelectionComboBox.ForeColor          = "Black"
    $Section3HostDataSelectionComboBox.AutoCompleteSource = "ListItems" # Options are: FileSystem, HistoryList, RecentlyUsedList, AllURL, AllSystemSources, FileSystemDirectories, CustomSource, ListItems, None
    $Section3HostDataSelectionComboBox.AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
    $Section3HostDataSelectionComboBox.DataSource         = $HostDataList1
    #$Section3HostDataSelectionComboBox.Add_KeyDown({  })
    $Section3HostDataSelectionComboBox.add_MouseHover($MouseHover)
    $Section3HostDataSelectionComboBox.add_SelectedIndexChanged($HostDataList2)
    $Section3HostDataTab.Controls.Add($Section3HostDataSelectionComboBox)

    #--------------------------------------------
    # Host Data - Date & Time Collected ComboBox
    #--------------------------------------------
    $Section3HostDataSelectionDateTimeComboBox                    = New-Object System.Windows.Forms.ComboBox
    $Section3HostDataSelectionDateTimeComboBox.Location           = New-Object System.Drawing.Size(260,($Section3HostDataSelectionComboBox.Size.Height + $Section3HostDataSelectionComboBox.Location.Y + 3))
    $Section3HostDataSelectionDateTimeComboBox.Size               = New-Object System.Drawing.Size(200,25)
    $Section3HostDataSelectionDateTimeComboBox.Text               = "Host Data - Date & Time"
    $Section3HostDataSelectionDateTimeComboBox.Font               = New-Object System.Drawing.Font("$Font",11,0,2,1)
    $Section3HostDataSelectionDateTimeComboBox.ForeColor          = "Black"
    $Section3HostDataSelectionDateTimeComboBox.AutoCompleteSource = "ListItems" # Options are: FileSystem, HistoryList, RecentlyUsedList, AllURL, AllSystemSources, FileSystemDirectories, CustomSource, ListItems, None
    $Section3HostDataSelectionDateTimeComboBox.AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"

    #$Section3HostDataSelectionDateTimeComboBox.Add_KeyDown({  })
    $Section3HostDataSelectionDateTimeComboBox.add_MouseHover($MouseHover)
    $Section3HostDataTab.Controls.Add($Section3HostDataSelectionDateTimeComboBox)
  
    #-----------------------------
    # Host Data - Get Data Button
    #-----------------------------
    $Section3HostDataGetDataButton          = New-Object System.Windows.Forms.Button
    $Section3HostDataGetDataButton.Name     = "Host Data - Get Data"
    $Section3HostDataGetDataButton.Text     = "Get Data"
    $Section3HostDataGetDataButton.Location = New-Object System.Drawing.Size(($Section3HostDataSelectionDateTimeComboBox.Location.X + $Section3HostDataSelectionDateTimeComboBox.Size.Width + 5),($Section3HostDataSelectionDateTimeComboBox.Location.Y - 1))
    $Section3HostDataGetDataButton.Size     = New-Object System.Drawing.Size(75,23)
    $Section3HostDataGetDataButton.Font     = New-Object System.Drawing.Font("$Font",11,0,2,1)
    $Section3HostDataGetDataButton.Add_Click({
        # Chooses the most recent file if multiple exist
        $HostData = Import-Csv -Path "$CollectedDataDirectory\$($Section3HostDataSelectionDateTimeComboBox.SelectedItem)\$CsvFileExtention" | Where {$_.PSComputerName -match $Section3HostDataName.Text}

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
    $Section3HostDataTab.Controls.Add($Section3HostDataGetDataButton)


#---------------------------------------
# ComputerList TreeView - Tags ComboBox
#---------------------------------------
$Section3HostDataTagsComboBox               = New-Object System.Windows.Forms.ComboBox
$Section3HostDataTagsComboBox.Name          = "Tags"
$Section3HostDataTagsComboBox.Text          = "Tags"
$Section3HostDataTagsComboBox.Location      = New-Object System.Drawing.Size(260,($Section3HostDataGetDataButton.Size.Height + $Section3HostDataGetDataButton.Location.Y + 25))
$Section3HostDataTagsComboBox.Size          = New-Object System.Drawing.Size(200,25)
$Section3HostDataTagsComboBox.AutoCompleteSource = "ListItems" # Options are: FileSystem, HistoryList, RecentlyUsedList, AllURL, AllSystemSources, FileSystemDirectories, CustomSource, ListItems, None
$Section3HostDataTagsComboBox.AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
    ForEach ($Item in $TagList) { 
        [void] $Section3HostDataTagsComboBox.Items.Add($Item) 
    }
$Section3HostDataTab.Controls.Add($Section3HostDataTagsComboBox)

#-----------------------------------------
# ComputerList TreeView - Tags Add Button
#-----------------------------------------
$Section3HostDataTagsAddButton           = New-Object System.Windows.Forms.Button
$Section3HostDataTagsAddButton.Name      = "Tags Add Button"
$Section3HostDataTagsAddButton.Text      = "Add"
$Section3HostDataTagsAddButton.Location  = New-Object System.Drawing.Size(($Section3HostDataTagsComboBox.Size.Width + $Section3HostDataTagsComboBox.Location.X + 5),($Section3HostDataTagsComboBox.Location.Y - 1))
$Section3HostDataTagsAddButton.Size      = New-Object System.Drawing.Size(75,23)
$Section3HostDataTagsAddButton.Font      = New-Object System.Drawing.Font("$Font",11,0,2,1)
$Section3HostDataTagsAddButton.ForeColor = "Green"
$Section3HostDataTagsAddButton.Add_Click({ 
    if (!($Section3HostDataTagsComboBox.SelectedItem -eq "Tags")) {
        $Section3HostDataNotes.text = "[$($Section3HostDataTagsComboBox.SelectedItem)] " + $Section3HostDataNotes.text
    }
})
$Section3HostDataTab.Controls.Add($Section3HostDataTagsAddButton)

#============================================================================================================================================================
# Convert CSV Number Strings To Intergers
#============================================================================================================================================================
function Convert-CSVNumberStringsToIntergers {
    param ($InputDataSource)
    $InputDataSource | ForEach-Object {
        if ($_.CreationDate)    { $_.CreationDate    = [datatime]$_.CreationDate}
        if ($_.Handle)          { $_.Handle          = [int]$_.Handle}
        if ($_.HandleCount)     { $_.HandleCount     = [int]$_.HandleCount}
        if ($_.ParentProcessID) { $_.ParentProcessID = [int]$_.ParentProcessID}
        if ($_.ProcessID)       { $_.ProcessID       = [int]$_.ProcessID}
        if ($_.ThreadCount)     { $_.ThreadCount     = [int]$_.ThreadCount}
        if ($_.WorkingSetSize)  { $_.WorkingSetSize  = [int]$_.WorkingSetSize}
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
    Remove-Item "$LocationToSaveCompiledCSV" -Force

    $getFirstLine = $true
    Get-ChildItem "$LocationOfCSVsToCompile" | foreach {
        if ((Get-Content $PSItem).Length -eq 0){
            Remove-Item $PSItem
        }
        else {
            $filePath = $_
            $Lines = $Lines = Get-Content $filePath  
            $LinesToWrite = switch($getFirstLine) {
                $true  {$Lines}
                $false {$Lines | Select -Skip 1}
            }
            $getFirstLine = $false
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
    param($CollectionName)
    $ProgressBar1.Value = 0
    $JobsLaunch = Get-Date 
    $JobsTimer  = [int]$($script:OptionJobTimeoutSelectionComboBox.Text)
        do {
        #Clear-Host
        #Get-Job -Name "PoSh-ACME:*" | Receive-Job -Force

        $CurrentJobs = Get-Job -Name "PoSh-ACME:*"

        # Gets a host list of the Jobs
        $JobsHosts = ''
        $ACME_Jobs = $CurrentJobs | Where-Object State -eq Running | Select-Object -ExpandProperty Name
        foreach ($job in $ACME_Jobs) { $JobsHosts += $($($job -replace 'PoSh-ACME: ','' -split '-')[2])}
        $JobsHosts = $JobsHosts -replace ' ',', ' -replace ", $","" -replace "^,",""
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Processing: $JobsHosts")

        #$CurrentJobs | Out-File $env:TEMP\scrapjobs.txt
        #Get-Content $env:TEMP\scrapjobs.txt
        $jobscount = $CurrentJobs.count                  
        $ProgressBar1.Maximum = $jobscount

        $done = 0
        foreach ($job in $CurrentJobs) {
            $mystate = $job.state
            if ($mystate -eq "Completed") {$done += 1}
        }
        $ProgressBar1.Value = $done + 1

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

        # This is how often PoSoh-ACME's GUI will refresh when provide the status of the jobs
        Start-Sleep -Milliseconds 250

        foreach ($Job in $CurrentJobs) {
            if ($Job.PSBeginTime -lt $(Get-Date).AddSeconds(-$JobsTimer)) {
                $TimeStamp = $(Get-Date).ToString('yyyy/MM/dd HH:mm:ss')
                $ResultsListBox.Items.insert(5,"$($TimeStamp)   - Job Timed Out: $((($Job | Select-Object -ExpandProperty Name) -split '-')[3])")
                $Job | Stop-Job  
                $Job | Receive-Job -Force 
                $Job | Remove-Job -Force
                break        
            }
        }
        #$ResultsListBox.Items.RemoveAt(0)
        #$ResultsListBox.Items.RemoveAt(0)
        $ResultsListBox.Items.RemoveAt(0)
        $ResultsListBox.Items.RemoveAt(0)
        $ResultsListBox.Items.RemoveAt(0)
        $ResultsListBox.Items.RemoveAt(0)
       
    } while ($done -lt $jobscount)

    Get-Job -Name "PoSh-ACME:*" | Remove-Job -ErrorAction SilentlyContinue
#    Start-Sleep -Seconds 1
    $ProgressBar1.Value   = 0
}

#============================================================================================================================================================
# CheckBox Script Handler
#============================================================================================================================================================
$ExecuteScriptHandler= {
    #$StatusListBox.Items.Clear()
    #$StatusListBox.Items.Insert(0,"Conducting Pre-Checks!")

    # This is for reference, it's also used later in the handler script
    #$Section1TabControl.SelectedTab   = $Section1OpNotesTab
    #$Section2TabControl.SelectedTab   = $Section2MainTab
    #$Section3TabControl.SelectedTab   = $Section3ActionTab
    #$Section4TabControl.SelectedTab   = $Section3ResultsTab
    
    # Clears previous Target Host values
    $ComputerList = @()           

    [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $ComputerListTreeView.Nodes 
    
    ### If the root computerlist checkbox is checked, all hosts will be queried
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
    # This will dedup selected checkboxes that happened from selecting categores and individual entries
    $ComputerList = $ComputerList | Sort-Object -Unique
    $ResultsListBox.Items.Clear()
    $ResultsListBox.Items.Add("Computers to be queried:  $($ComputerList.Count)")
    $ResultsListBox.Items.Add("$ComputerList")
    start-sleep 1
    # Assigns the path to save the Collections to
    $CollectedDataTimeStampDirectory = $CollectionSavedDirectoryTextBox.Text
    $IndividualHostResults           = "$CollectedDataTimeStampDirectory\Individual Host Results"

    New-Item -Type Directory -Path $CollectionSavedDirectoryTextBox.Text

    #if ($SingleHostIPCheckBox.Checked -eq $false) {
    #    # If $SingleHostIPCheckBox.Checked is true, then query a single computer, othewise query the selected computers in the computerlistbox
    #    . SelectListBoxEntry
    #}
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
        $ResultsListBox.Items.Insert(0,"       Host Queries") 
        $ResultsListBox.Items.Insert(0,"       Event Logs") 
        $ResultsListBox.Items.Insert(0,"       Active Directory") 
        $ResultsListBox.Items.Insert(0,"       File Search") 
        $ResultsListBox.Items.Insert(0,"       Registry [future feature]") 
        $ResultsListBox.Items.Insert(0,"       Sysinternals [if Resource foler is present]") 
    }
    else {
        # Checks if any computers were selected
        if (($ComputerList.Count -eq 0) -and ($SingleHostIPCheckBox.Checked -eq $false)) {
            # This brings specific tabs to the forefront/front view
            $Section1TabControl.SelectedTab   = $Section1CollectionsTab
            $Section4TabControl.SelectedTab   = $Section3ResultsTab

            # Sounds a chime if there are no queries selected
            [system.media.systemsounds]::Exclamation.play()

            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("Error: No Target Computers Selected")
            $ResultsListBox.Items.Clear()
            $ResultsListBox.Items.Add("Error: You need to make a selction from the computer treeView:")
            $ResultsListBox.Items.Add("       Checkbox one or more target computers.")
            $ResultsListBox.Items.Add("       Checkbox a category to collect data from all nested target computers.")
        }
        # Runs commands if it passes the above checks
        else {
            # This brings specific tabs to the forefront/front view
            $Section1TabControl.SelectedTab   = $Section1OpNotesTab
            $Section2TabControl.SelectedTab   = $Section2MainTab
            $Section3TabControl.SelectedTab   = $Section3ActionTab
            $Section4TabControl.SelectedTab   = $Section3ResultsTab

            $ResultsListBox.Items.Clear();
            $CollectionTimerStart = Get-Date
            $ResultsListBox.Items.Insert(0,"$(($CollectionTimerStart).ToString('yyyy/MM/dd HH:mm:ss'))  Collection Start Time")    
            $ResultsListBox.Items.Insert(0,"")
 
            # Sets / Resets count to zero
            $CountCommandQueries = 0

            # Counts Target Computers
            $CountTargetComputer = $ComputerList.Count

            # Runs the Commands
        
            # Adds all the checkboxed commands to a list
            $CommandsCheckedBoxesSelected = @()

            [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $CommandsTreeView.Nodes
            $ResultsListBox.Items.Clear()
            foreach ($root in $AllHostsNode) { 
                foreach ($Category in $root.Nodes) {                
                    if ($CommandsViewMethodRadioButton.Checked) {
                        foreach ($Entry in $Category.nodes) { 
                            if ($Entry -match '(RPC)' -and $Entry -match 'CMD' -and $Entry.Checked) {
                                $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' - ')[1])
                                $CommandsCheckedBoxesSelected += New-Object psobject @{ 
                                    Name       = $Entry.Text
                                    Command    = $Command.Command_RPC_CMD
                                    Arguments  = $Command.Command_RPC_CMD_Arg
                                    ExportPath = $Command.ExportPath
                                    Type       = "(RPC) CMD"
                                }
                            }                    
                            if ($Entry -match '(RPC)' -and $Entry -match 'PoSh' -and $Entry.Checked) {
                                $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' - ')[1])
                                $CommandsCheckedBoxesSelected += New-Object psobject @{ 
                                    Name       = $Entry.Text
                                    Command    = $Command.Command_RPC_PoSh
                                    Properties = $Command.Properties_PoSh
                                    ExportPath = $Command.ExportPath
                                    Type       = "(RPC) PoSh"
                                }
                            }
                            if (($Entry -match '(WMI)') -and ($Entry -notmatch '(WinRS)') -and ($Entry -notmatch '(WinRM)') -and $Entry.Checked ) {
                                $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' - ')[1])
                                $CommandsCheckedBoxesSelected += New-Object psobject @{ 
                                    Name       = $Entry.Text
                                    Command    = $Command.Command_WMI
                                    Properties = $Command.Properties_WMI
                                    ExportPath = $Command.ExportPath
                                    Type       = "(WMI)"
                                }
                            }
                            if ($Entry -match '(WinRM)' -and $Entry -match 'CMD' -and $Entry.Checked) {
                                $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' - ')[1])
                                $CommandsCheckedBoxesSelected += New-Object psobject @{ 
                                    Name       = $Entry.Text
                                    Command    = $Command.Command_WinRM_CMD
                                    ExportPath = $Command.ExportPath
                                    Type       = "(WinRM) CMD"
                                }
                            }
                            if ($Entry -match '(WinRM)' -and $Entry -match 'Script' -and $Entry.Checked) {
                                $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' - ')[1])
                                $CommandsCheckedBoxesSelected += New-Object psobject @{ 
                                    Name       = $Entry.Text
                                    Command    = $Command.Command_WinRM_Script
                                    #Properties = $Command.Properties_Script
                                    ExportPath = $Command.ExportPath
                                    Type       = "(WinRM) Script"
                                }
                            }
                            if ($Entry -match '(WinRM)' -and $Entry -match 'PoSh' -and $Entry.Checked) {
                                $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' - ')[1])
                                $CommandsCheckedBoxesSelected += New-Object psobject @{ 
                                    Name       = $Entry.Text
                                    Command    = $Command.Command_WinRM_PoSh
                                    Properties = $Command.Properties_PoSh
                                    ExportPath = $Command.ExportPath
                                    Type       = '(WinRM) PoSh'
                                }
                            }
                            if ($Entry -match '(WinRM)' -and $Entry -match 'WMI' -and $Entry.Checked) {
                                $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' - ')[1])
                                $CommandsCheckedBoxesSelected += New-Object psobject @{ 
                                    Name       = $Entry.Text
                                    Command    = $Command.Command_WinRM_WMI
                                    Properties = $Command.Properties_WMI
                                    ExportPath = $Command.ExportPath
                                    Type       = "(WinRM) WMI"
                                }
                            }
                        <#    if ($Entry -match '(WinRS)' -and $Entry -match 'CMD' -and $Entry.Checked) {
                                    $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' - ')[1])
                                    $CommandsCheckedBoxesSelected += New-Object psobject @{ 
                                        Name       = $Entry.Text
                                        Command    = $Command.Command_WinRS_CMD
                                        ExportPath = $Command.ExportPath
                                        Type       = "(WinRS) CMD"
                                    }
                            }
                            if ($Entry -match '(WinRS)' -and $Entry -match 'WMIC' -and $Entry.Checked) {
                                    $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' - ')[1])
                                    $CommandsCheckedBoxesSelected += New-Object psobject @{ 
                                        Name       = $Entry.Text
                                        Command    = $Command.Command_WinRS_WMIC
                                        ExportPath = $Command.ExportPath
                                        Type       = "(WinRS) WMIC"
                                    }
                            } #>
                        }
                    }
                    if ($CommandsViewQueryRadioButton.Checked) {
                        foreach ($Entry in $Category.nodes) { 
                            if ($Entry -match '(RPC)' -and $Entry -match 'CMD' -and $Entry.Checked) {
                                $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' - ')[1])
                                $CommandsCheckedBoxesSelected += New-Object psobject @{ 
                                    Name       = $Entry.Text
                                    Command    = $Command.Command_RPC_CMD
                                    Arguments  = $Command.Command_RPC_CMD_Arg
                                    ExportPath = $Command.ExportPath
                                    Type       = "(RPC) CMD"
                                }
                            }
                            if ($Entry -match '(RPC)' -and $Entry -match 'PoSh' -and $Entry.Checked) {
                                $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' - ')[1])
                                $CommandsCheckedBoxesSelected += New-Object psobject @{ 
                                    Name       = $Entry.Text
                                    Command    = $Command.Command_RPC_PoSh
                                    Properties = $Command.Properties_PoSh
                                    ExportPath = $Command.ExportPath
                                    Type       = '(RPC) PoSh'
                                }
                            }
                            if (($Entry -match '(WMI)') -and ($Entry -notmatch '(WinRS)') -and ($Entry -notmatch '(WinRM)') -and $Entry.Checked) {                        
                                $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' - ')[1])
                                $CommandsCheckedBoxesSelected += New-Object psobject @{ 
                                    Name       = $Entry.Text
                                    Command    = $Command.Command_WMI
                                    Properties = $Command.Properties_WMI
                                    ExportPath = $Command.ExportPath
                                    Type       = "(WMI)"
                                }
                            }
                            if ($Entry -match '(WinRM)' -and $Entry -match 'CMD' -and $Entry.Checked) {
                                $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' - ')[1])
                                $CommandsCheckedBoxesSelected += New-Object psobject @{ 
                                    Name       = $Entry.Text
                                    Command    = $Command.Command_WinRM_CMD
                                    ExportPath = $Command.ExportPath
                                    Type       = "(WinRM) CMD"
                                }
                            }
                            if ($Entry -match '(WinRM)' -and $Entry -match 'Script' -and $Entry.Checked) {
                                $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' - ')[1])
                                $CommandsCheckedBoxesSelected += New-Object psobject @{ 
                                    Name       = $Entry.Text
                                    Command    = $Command.Command_WinRM_Script
                                    #Properties = $Command.Properties_Script
                                    ExportPath = $Command.ExportPath
                                    Type       = "(WinRM) Script"
                                }
                            }
                            if ($Entry -match '(WinRM)' -and $Entry -match 'PoSh' -and $Entry.Checked) {
                                $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' - ')[1])
                                $CommandsCheckedBoxesSelected += New-Object psobject @{ 
                                    Name       = $Entry.Text
                                    Command    = $Command.Command_WinRM_PoSh
                                    Properties = $Command.Properties_PoSh
                                    ExportPath = $Command.ExportPath
                                    Type       = '(WinRM) PoSh'
                                }
                            }
                            if ($Entry -match '(WinRM)' -and $Entry -match 'WMI' -and $Entry.Checked) {
                                $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' - ')[1])
                                $CommandsCheckedBoxesSelected += New-Object psobject @{ 
                                    Name       = $Entry.Text
                                    Command    = $Command.Command_WinRM_WMI
                                    Properties = $Command.Properties_WMI
                                    ExportPath = $Command.ExportPath
                                    Type       = "(WinRM) WMI"
                                }
                            }
                        
                        <#  
                            if ($Entry -match '(WinRS)' -and $Entry -match 'CMD' -and $Entry.Checked) {
                                $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' - ')[1])
                                $CommandsCheckedBoxesSelected += New-Object psobject @{ 
                                    Name       = $Entry.Text
                                    Command    = $Command.Command_WinRS_CMD
                                    ExportPath = $Command.ExportPath
                                    Type       = "(WinRS) CMD"
                                }
                            }
                            if ($Entry -match '(WinRS)' -and $Entry -match 'WMIC' -and $Entry.Checked) {
                                $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' - ')[1])
                                $CommandsCheckedBoxesSelected += New-Object psobject @{ 
                                    Name       = $Entry.Text
                                    Command    = $Command.Command_WinRS_WMIC
                                    ExportPath = $Command.ExportPath
                                    Type       = "(WinRS) WMIC"
                                }
                            }
                         #>                                        
                        }
                    }
                }
            }
            # Ensures that there are to lingering jobs in memory
            Get-Job -Name "PoSh-ACME:*" | Remove-Job -Force -ErrorAction SilentlyContinue

            # Iterates through selected commands and computers
            # Comamnds ran without credentials
            if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {            
                if (!$script:Credential) { $script:Credential = Get-Credential }
                Foreach ($Command in $CommandsCheckedBoxesSelected) {
                    $StatusListBox.Items.Clear()
                    $StatusListBox.Items.Add("Query: $($Command.Name)")
                    $ResultsListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  $($Command.Name)")
                    
                    Foreach ($TargetComputer in $ComputerList) {
                        $SavePath = "$($CollectionSavedDirectoryTextBox.Text)\Individual Host Results\$($Command.ExportPath)"
                        # Creates the directory to save the results to
                        New-Item -ItemType Directory -Path $SavePath -Force

                        Start-Job -Name "PoSh-ACME: $($Command.Name) - $TargetComputer" -ScriptBlock {
                            param($TargetComputer, $Command, $SavePath, $LogFile, $script:Credential)                      
                            # Available priority values: Low, BelowNormal, Normal, AboveNormal, High, RealTime
                            [System.Threading.Thread]::CurrentThread.Priority = 'High'
                            ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'High'
                            
                            if ($Command.Type -match '(WinRM)' -and $Command.Type -match 'CMD') {
                                $CommandString = "$($Command.Command) -ComputerName $TargetComputer -Credential $script:Credential"
                                $OutputFilePath = "$SavePath\$((($Command.Name) -split ' - ')[1]) - $($Command.Type) - $($TargetComputer).txt"
                            }
                            elseif (($Command.Type -match '(WMI)') -and ($Command.Type -notmatch '(WinRS)') -and ($Command.Type -notmatch '(WinRM)')) {
                                $CommandString = "$($Command.Command) -ComputerName $TargetComputer -Credential $script:Credential | Select-Object -Property $($Command.Properties)"
                                $OutputFilePath = "$SavePath\$((($Command.Name) -split ' - ')[1]) - $($Command.Type) - $($TargetComputer).csv"
                            }
                            elseif (($Command.Type -match '(WinRM)') -and ($Command.Type -match 'Script')) {
                                $CommandString = "$($Command.Command) -ComputerName $TargetComputer -Credential $script:Credential"
                                $OutputFilePath = "$SavePath\$((($Command.Name) -split ' - ')[1]) - $($Command.Type) - $($TargetComputer).csv"
                            }
                            elseif (($Command.Type -match '(WinRM)') -and ($Command.Type -match 'PoSh')) {
                                $CommandString = "$($Command.Command) -ComputerName $TargetComputer -Credential $script:Credential | Select-Object -Property $($Command.Properties)"
                                $OutputFilePath = "$SavePath\$((($Command.Name) -split ' - ')[1]) - $($Command.Type) - $($TargetComputer).csv"
                            }
                            elseif ($Command.Type -match 'WinRM' -and $Command.Type -match 'WMI') {
                                $CommandString = "$($Command.Command) -ComputerName $TargetComputer -Credential $script:Credential"
                                $OutputFilePath = "$SavePath\$((($Command.Name) -split ' - ')[1]) - $($Command.Type) - $($TargetComputer).csv"
                            }
    #                        elseif ($Command.Type -match'(WinRS)' -and $Command.Type -match 'CMD') {
    #                            # -username:<username> -password:<password>
    #                            $CommandString = "$($Command.Command)"
    #                            $OutputFilePath = "$SavePath\$((($Command.Name) -split ' - ')[1]) - $($Command.Type) - $($TargetComputer).txt"
    #                        }
    #                        elseif ($Command.Type -match '(WinRS)' -and $Command.Type -match 'WMIC') {
    #                            $CommandString = "$($Command.Command)"
    #                            $OutputFilePath = "$SavePath\$((($Command.Name) -split ' - ')[1]) - $($Command.Type) - $($TargetComputer).txt"
    #                        }
                            elseif ($Command.Type -match '(RPC)' -and $Command.Type -match 'CMD') {
                                $CommandString = "$($Command.Command) \\$TargetComputer $($Command.Arguments)"
                                $OutputFilePath = "$SavePath\$((($Command.Name) -split ' - ')[1]) - $($Command.Type) - $($TargetComputer).txt"
                            }
                            elseif ($Command.Type -match '(RPC)' -and $Command.Type -match 'PoSh') {
                                $CommandString = "$($Command.Command) -ComputerName $TargetComputer -Credential $script:Credential | Select-Object -Property $($Command.Properties)"
                                $OutputFilePath = "$SavePath\$((($Command.Name) -split ' - ')[1]) - $($Command.Type) - $($TargetComputer).csv"
                            }                        
                            Remove-Item -Path $OutputFilePath -Force -ErrorAction SilentlyContinue
                            Invoke-Expression -Command $CommandString | Export-Csv -Path $OutputFilePath -NoTypeInformation -Force

                            $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $CommandString"
                            $LogMessage | Add-Content -Path $LogFile
                        } -ArgumentList @($TargetComputer, $Command, $SavePath, $LogFile, $script:Credential)
                    }
                    Monitor-Jobs -CollectionName $($Command.Name)
                }
            }                 
            # Comamnds ran without credentials
            else {
                Foreach ($Command in $CommandsCheckedBoxesSelected) {
                    $CollectionCommandStartTime = Get-Date 
                    $StatusListBox.Items.Clear()
                    $StatusListBox.Items.Add("Query: $($Command.Name)")                    
                    $ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $($Command.Name)")
                    Foreach ($TargetComputer in $ComputerList) {
                        $SavePath = "$($CollectionSavedDirectoryTextBox.Text)\Individual Host Results\$($Command.ExportPath)"
                        # Creates the directory to save the results to
                        New-Item -ItemType Directory -Path $SavePath -Force

                        # Checks for the type of command selected and assembles the command to be executed
                        $OutputFileFileType = ""
                        if ($Command.Type -eq "(WinRM) CMD") {
                            $CommandString = "$($Command.Command) -ComputerName $TargetComputer"
                            $OutputFileFileType = "txt"
                        }
                        elseif (($Command.Type -eq "(WMI)") -and ($Command.Command -match "Get-WmiObject")) {
                            $CommandString = "$($Command.Command) -ComputerName $TargetComputer | Select-Object -Property $($Command.Properties)"
                            $OutputFileFileType = "csv"
                        }
                        elseif (($Command.Type -eq "(WMI)") -and ($Command.Command -match "Invoke-WmiMethod")) {
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
                            $CommandString = "$($Command.Command) -ComputerName $TargetComputer"
                            $OutputFileFileType = "csv"
                        }
                        <#
                        elseif ($Command.Type -eq "(WinRS) CMD") {
                            # -username:<username> -password:<password>
                            $CommandString = "$($Command.Command)"
                            $OutputFileFileType = "txt"
                        }
                        elseif ($Command.Type -eq "(WinRS) WMIC") {
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
                        Start-Job -Name "PoSh-ACME: $CommandName - $TargetComputer" -ScriptBlock {
                            param($OutputFileFileType, $SavePath, $CommandName, $CommandType, $TargetComputer, $CommandString)                      
                            # Available priority values: Low, BelowNormal, Normal, AboveNormal, High, RealTime
                            [System.Threading.Thread]::CurrentThread.Priority = 'High'
                            ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'High'
 
                            # Checks for the file output type, removes previous results with a file, then executes the commands
                            if ( $OutputFileFileType -eq "csv" ) {
                                $OutputFilePath = "$SavePath\$((($CommandName) -split ' - ')[1]) - $CommandType - $($TargetComputer).csv"
                                Remove-Item -Path $OutputFilePath -Force -ErrorAction SilentlyContinue
                                Invoke-Expression -Command $CommandString | Export-Csv -Path $OutputFilePath -NoTypeInformation -Force
                            }
                            elseif ( $OutputFileFileType -eq "txt" ) {
                                $OutputFilePath = "$SavePath\$((($CommandName) -split ' - ')[1]) - $CommandType - $($TargetComputer).txt"
                                Remove-Item -Path $OutputFilePath -Force -ErrorAction SilentlyContinue

                                if (($CommandType -eq "(WMI)") -and ($CommandString -match "Invoke-WmiMethod") ) {
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
                    Monitor-Jobs -CollectionName $($Command.Name)

                    $CollectionCommandEndTime  = Get-Date                    
                    $CollectionCommandDiffTime = New-TimeSpan -Start $CollectionCommandStartTime -End $CollectionCommandEndTime

                    $ResultsListBox.Items.RemoveAt(0)
                    $ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $($Command.Name)")

                    # Compiles the CSVs into a single file for easier and faster viewing of results
                    $StatusListBox.Items.Clear()
                    $StatusListBox.Items.Add("Compiling CSV Results:  $((($Command.Name) -split ' - ')[1])")
                    Compile-CsvFiles -LocationOfCSVsToCompile "$SavePath\$((($Command.Name) -split ' - ')[1]) - $($Command.Type)*.csv" -LocationToSaveCompiledCSV "$CollectedDataTimeStampDirectory\$((($Command.Name) -split ' - ')[1]) - $($Command.Type).csv"
                    $StatusListBox.Items.Clear()
                    $StatusListBox.Items.Add("Finished Collecting Data!")
                }
            }
            if ($FileSearchDirectoryListingCheckbox.Checked) {FileSearchDirectoryListingCommand ; $CountCommandQueries += 1}
            if ($FileSearchFileSearchCheckbox.Checked){FileSearchFileSearchCommand ; $CountCommandQueries += 1}
            if ($FileSearchAlternateDataStreamCheckbox.Checked){FileSearchAlternateDataStreamCommand ; $CountCommandQueries += 1} 
            if ($RekallWinPmemMemoryCaptureCheckbox.Checked){RekallWinPmemMemoryCaptureCommand ; $CountCommandQueries += 1}
            if ($SysinternalsAutorunsCheckbox.Checked){SysinternalsAutorunsCommand ; $CountCommandQueries += 1}
            if ($SysinternalsProcessMonitorCheckbox.Checked){SysinternalsProcessMonitorCommand ; $CountCommandQueries += 1}
        
            if ($EventLogsEventIDsManualEntryCheckbox.Checked) {EventLogsEventCodeManualEntryCommand ; $CountCommandQueries += 1}
            if ($EventLogsEventIDsIndividualSelectionCheckbox.Checked) {EventLogsEventCodeIndividualSelectionCommand ; $CountCommandQueries += 1}
            if ($EventLogsQuickPickSelectionCheckbox.Checked) {
                foreach ($Query in $script:EventLogQueries) {
                    if ($EventLogsQuickPickSelectionCheckedlistbox.CheckedItems -match $Query.Name) {
                        EventLogQuery -CollectionName $Query.Name -Filter $Query.Filter
                        $CountCommandQueries += 1
                    }
                }
            }
            $CollectionTimerStop = Get-Date
            $ResultsListBox.Items.Insert(0,"$(($CollectionTimerStop).ToString('yyyy/MM/dd HH:mm:ss'))  Finished Collecting Data!")

            $CollectionTime = New-TimeSpan -Start $CollectionTimerStart -End $CollectionTimerStop
            $ResultsListBox.Items.Insert(1,"   $CollectionTime  Total Elapsed Time")
            $ResultsListBox.Items.Insert(2,"====================================================================================================")
            $ResultsListBox.Items.Insert(3,"")        
      
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
    }

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
$PoShACME.ShowDialog()| Out-Null

} #End Function

# Call the PoSh-ACME Function
PoSh-ACME_GUI



