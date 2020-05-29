<#
    .SYNOPSIS
    PoSh-EasyWin is a primarily a domain-wide host querying tool and provides easy viewing of queried
    data via a filterable table and charts... plus much, much more.

    .DESCRIPTION
    _____        ____   _             _____                  __        __ _        
    |  _ \  ___ / ___| | |__         | ____| __ _  ___  _   _\ \      / /(_) _ __  
    | |_) |/ _ \\___ \ | '_ \  _____ |  _|  / _` |/ __|| | | |\ \ /\ / / | || '_ \ 
    |  __/| (_) |___) || | | ||_____|| |___| (_| |\__ \| |_| | \ V  V /  | || | | |
    |_|    \___/|____/ |_| |_|       |_____|\__,_||___/ \__, |  \_/\_/   |_||_| |_|
                                                        |___/                      
    ==================================================================================
    PoSh-EasyWin: PowerShell - Endpoint Analysis Solution Your Windows Intranet Needs!
    I know, I know-it's over the top... but who doesn't love tools with acronym names? 
    ==================================================================================

    File Name      : PoSh-EasyWin.ps1
    Version        : v.4.2

    Requirements   : PowerShell v3+ for PowerShell Charts
                   : WinRM   HTTP  - TCP/5985 Win7+ ( 80 Vista-)
                             HTTPS - TCP/5986 Win7+ (443 Vista-)
                             Endpoint Listener - TCP/47001
                   : DCOM    RPC   - TCP/135 and dynamic ports, typically:
                                     TCP 49152-65535 (Windows Vista, Server 2008 and above)
                                     TCP 1024 -65535 (Windows NT4, Windows 2000, Windows 2003)
    Optional       : PsExec.exe, Procmon.exe, Autoruns.exe, Sysmon.exe, WinPmem.exe

    Updated        : 28 MAY 2020
    Created        : 21 AUG 2018

    Author         : Daniel Komnick (high101bro)
    Email          : high101bro@gmail.com
    Website        : https://github.com/high101bro/PoSh-EasyWin


    PoSh-EasyWin is the Endpoint Analysis Solution Your Windows Intranet Needs that provides a 
    simple user interface to execute any number of commands against any number of computers within 
    a network, access hosts, manage data, and analyze their results.

    Copyright (C) 2018  Daniel S Komnick

    This program is free software: you can redistribute it and/or modify it under the terms of the
    GNU General Public License as published by the Free Software Foundation, either version 3 of 
    the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
    See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with this program.
    It is located in the 'GPLv3 - GNU General Public License.txt' file in the Dependencies folder.
    If not, see <https://www.gnu.org/licenses/>.

    Credits:
    Learned a lot and referenced code from sources like Microsoft Technet, PowerShell Gallery, StackOverflow, and a numerous other websites.
    That said, I didn't track all sites and individuals that deserve credit. In the unlikely event you believe you do, please notify me. 

    .EXAMPLE
    This will run PoSh-EasyWin.ps1 and provide prompts that will tailor your collection.

        PowerShell.exe -ExecutionPolicy ByPass -NoProfile -File .\PoSh-EasyWin.ps1

    .Link
    https://github.com/high101bro/PoSh-EasyWin

    .NOTES  
    Though this may look like a program, it is still a script that has a GUI interface built
    using the .Net Framework and WinForms. So when it's conducting queries, the GUI will be 
    unresponsive to user interaction even though you are able to view status and timer updates.

    In order to run the script:
    - Downloaded from the internet
        You may have to use the Unblock-File cmdlet to be able to run the script.
            - For addtional info on: Get-Help Unblock-File
        How to Unblock the file:
            - Unblock-File -Path .\PoSh-EasyWin.ps1

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

#https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_cmdletbindingattribute?view=powershell-7
[CmdletBinding(
    #ConfirmImpact=<String>,
    DefaultParameterSetName='GUI',
    HelpURI='https://github.com/high101bro/PoSh-EasyWin',
    #SupportsPaging=$true,
    #SupportsShouldProcess=$true,
    PositionalBinding=$true)
]

#https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters?view=powershell-7
param (

    [Parameter(
        Mandatory=$false,
        HelpMessage="The provided credentials will launch PoSh-EasyWin, and is subsequentially used for querying unless otherwise changed."
    )]
    [ValidateNotNullOrEmpty()]
    [System.Management.Automation.PSCredential]
    $Credential,

    [Parameter(
        Mandatory=$true,
        ParameterSetName="No GUI Computer Name",
        ValueFromPipeline=$true,
        HelpMessage="Enter one or more computer names separated by commas, or imported from a file as an array. Entries will only query if they already exist within script."
    )]
    [Alias('PSComputerName','CN','MachineName')]
    [ValidateLength(1,63)]
        # NetBIOS Names Lenghts:   1-15
        # DNS Name Lengths:        2-63
    [ValidateNotNullOrEmpty()]
    [string[]]
    $ComputerName,

    [Parameter(
        Mandatory=$true,
        ParameterSetName="No GUI Computer Search",
        HelpMessage="Enter a string (use quotes if there are spaces) to search for a computer by its NetBIOS Name, IP, MAC, OS, OU/CN, Tags, or notes."
    )]
    [ValidateNotNullOrEmpty()]
    [string[]]
    $ComputerSearch,

            [Parameter(
                Mandatory=$false,
                ParameterSetName="No GUI Computer Name",
                HelpMessage="Enter a sting(s) to filter out computers whose name matches in part or in whole."
            )]
            [Parameter(
                Mandatory=$false,
                ParameterSetName="No GUI Computer Search",
                HelpMessage="Enter a sting(s) to filter out computers whose name matches in part or in whole."
            )]
            [string[]]
            $FilterOutComputer,

            [Parameter(
                Mandatory=$false,
                ParameterSetName="No GUI Computer Name",
                HelpMessage="Enter a string(s) to filter back in computer names that were filtered out."
            )]
            [Parameter(
                Mandatory=$false,
                ParameterSetName="No GUI Computer Search",
                HelpMessage="Enter a string(s) to filter back in computer names that were filtered out."
            )]
            [string[]]
            $FilterInComputer,
    
    [Parameter(
        Mandatory=$true,
        ParameterSetName="No GUI Computer Name",
        HelpMessage="Searches for commands within PoSh-EasyWin."
    )]
    [Parameter(
        Mandatory=$true,
        ParameterSetName="No GUI Computer Search",
        HelpMessage="Searches for commands within PoSh-EasyWin."
    )]
    [ValidateNotNullOrEmpty()]
    [string[]]
    $CommandSearch,

            [Parameter(
                Mandatory=$false,
                ParameterSetName="No GUI Computer Name",
                HelpMessage="Filters out results from the Command Search."
            )]
            [Parameter(
                Mandatory=$false,
                ParameterSetName="No GUI Computer Search",
                HelpMessage="Filters out results from the Command Search."
            )]
            [string[]]
            $FilterOutCommand,

            [Parameter(
                Mandatory=$false,
                ParameterSetName="No GUI Computer Name",
                HelpMessage="Filters Command Search results back in, overriding the -FilterOutCommand."
            )]
            [Parameter(
                Mandatory=$false,
                ParameterSetName="No GUI Computer Search",
                HelpMessage="Filters Command Search results back in, overriding the -FilterOutCommand."
            )]
            [string[]]
            $FilterInCommand,

    [Parameter(
        Mandatory=$false,
        ParameterSetName="No GUI Computer Name",
        HelpMessage="Only the selected Protocol will be displayed."
    )]
    [Parameter(
        Mandatory=$false,
        ParameterSetName="No GUI Computer Search",
        HelpMessage="Only the selected Protocol will be displayed."
    )]
    [ValidateSet('RPC','WinRM')]
    [string]
    $Protocol,

    [Parameter(
        Mandatory=$false,
        ParameterSetName="No GUI Computer Name",
        HelpMessage="Location where to save collected data."
    )]
    [Parameter(
        Mandatory=$false,
        ParameterSetName="No GUI Computer Search",
        HelpMessage="Location where to save collected data."
    )]
    [string]
    $SaveDirectory = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)\Collected Data\$((Get-Date).ToString('yyyy-MM-dd @ HHmm ss'))",

    [Parameter(
        Mandatory=$false,
        ParameterSetName="GUI"
    )]
    [Parameter(
        Mandatory=$false,
        ParameterSetName="No GUI Computer Name",
        HelpMessage="Enter the amount of time in seconds that a command will run until it timesout. The default is 300 seconds."
    )]
    [Parameter(
        Mandatory=$false,
        ParameterSetName="No GUI Computer Search",
        HelpMessage="Enter the amount of time in seconds that a command will run until it timesout. The default is 300 seconds."
    )]
    [ValidateRange(30,600)]
    #[ValidatePattern("[0-9][0-9][0-9][0-9]")]
    [ValidateNotNullOrEmpty()]
    [int]
    $JobTimeOutSeconds = 300,




    [Parameter(
        Mandatory=$false,
        ParameterSetName="GUI",
        HelpMessage="The default font used in the GUI is Courier, but the following fonts also valdated."
    )]
    [ValidateSet('Calibri','Courier','Arial')]
        # This this validation set is expanded, ensure that larger fonts don't cause words to be truncated in the GUI
    [ValidateNotNull()]
    [string]
    $Font = "Courier",




    [Parameter(
        Mandatory=$false,
        ParameterSetName="GUI",
        HelpMessage="Disables the Tool Tips that display when the mouse hovers over various areas in the GUI."
    )]
    [switch]
    $DisableToolTip,




    [Parameter(
        Mandatory=$false,
        HelpMessage="Enables the audiable voice completion message at the end of queries/collections."
    )]
    [switch]
    $AudibleCompletionMessage,



    [Parameter(
        Mandatory=$false,
        ParameterSetName="GUI",
        HelpMessage="This disables the GUI and uses commandline mode."
    )]
    [Parameter(
        Mandatory=$false,
        ParameterSetName="No GUI Computer Name",
        HelpMessage="This disables the GUI and uses commandline mode."
    )]
    [Parameter(
        Mandatory=$false,
        ParameterSetName="No GUI Computer Search",
        HelpMessage="This disables the GUI and uses commandline mode."
    )]
    [switch]
    $NoGUI,




    [Parameter(
        Mandatory=$false,
        ParameterSetName="GUI"
    )]
    [Parameter(
        Mandatory=$false,
        ParameterSetName="No GUI Computer Name",
        HelpMessage="Accepts the End User License Agreement (EULA). The GUI for the GNU GPL wont display."
    )]
    [Parameter(
        Mandatory=$false,
        ParameterSetName="No GUI Computer Search",
        HelpMessage="Accepts the End User License Agreement (EULA). The GUI for the GNU GPL wont display."
    )]
    [switch]
    $AcceptEULA



)

#============================================================================================================================================================
# Variables
#============================================================================================================================================================

# Universally sets the ErrorActionPreference to Silently Continue
$ErrorActionPreference = "SilentlyContinue"
   
# Location PoSh-EasyWin will save files
$PoShHome                         = Split-Path -parent $MyInvocation.MyCommand.Definition
    # Files
    $LogFile                      = "$PoShHome\Log File.txt"
    $IPListFile                   = "$PoShHome\iplist.txt"
                                                    
    $ComputerTreeNodeFileAutoSave = "$PoShHome\Computer List TreeView (Auto-Save).csv"
    $ComputerTreeNodeFileSave     = "$PoShHome\Computer List TreeView (Saved).csv"

    $OpNotesFile                  = "$PoShHome\OpNotes.txt"
    $OpNotesWriteOnlyFile         = "$PoShHome\OpNotes (Write Only).txt"
  
    $CredentialManagementPath     = "$PoShHome\Credential Management\"

    # Dependencies
    $Dependencies                 = "$PoShHome\Dependencies"
        # Location of Query Commands and Scripts 
        $QueryCommandsAndScripts              = "$Dependencies\Query Commands and Scripts"

        # Location of Active Directory & Endpoint Commands
            $CommandsEndpoint                 = "$QueryCommandsAndScripts\Commands - Endpoint.csv"
            $CommandsActiveDirectory          = "$QueryCommandsAndScripts\Commands - Active Directory.csv"

        # Location of Event Logs Commands
        $CommandsEventLogsDirectory           = "$Dependencies\Event Log Info"

            # CSV file of Event IDs
            $EventIDsFile                     = "$CommandsEventLogsDirectory\Event IDs.csv"

            # CSV file from Microsoft detailing Event IDs to Monitor
            $EventLogsWindowITProCenter       = "$CommandsEventLogsDirectory\Individual Selection\Event Logs to Monitor - Window IT Pro Center.csv"

        # Location of External Programs directory
        $ExternalPrograms                     = "$Dependencies\Executables"
            $PsExecPath                       = "$ExternalPrograms\PsExec.exe"

        # CSV list of Event IDs numbers, names, and description
        $TagAutoListFile                      = "$Dependencies\Tags - Auto Populate.txt"

        # list of ports that can be updated for custom port scans
        $CustomPortsToScan            = "$Dependencies\Custom Ports To Scan.txt"

    # Directory where auto saved chart images are saved
    $AutosavedChartsDirectory                 = "$PoShHome\Autosaved Charts"

    # Name of Collected Data Directory
    $CollectedDataDirectory                   = "$PoShHome\Collected Data"
        # Location of separate queries
        $script:CollectedDataTimeStampDirectory      = "$CollectedDataDirectory\$((Get-Date).ToString('yyyy-MM-dd @ HHmm ss'))"
        # Location of Uncompiled Results
        $script:IndividualHostResults         = "$script:CollectedDataTimeStampDirectory\Individual Host Results"

# URL for Character Art
# http://patorjk.com/software/taag/#p=display&h=1&f=Standard&t=Script%20%20%20Execution

# This variable maintains the state of Rolling Credentials
$script:RollCredentialsState = $false
$script:AdminCredsToRollPasswordState = $false

# Keeps track of the number of RPC protocol commands selected, if the value is ever greater than one, it'll set the collection mode to 'Individual Execution'
$script:RpcCommandCount = 0

# If the credential parameter is provided, it will use those credentials throughout the script and for queries unless otherwise selected
if ( $Credential ) { $script:Credential = $Credential }
# Clears out the Credential variable. Specify Credentials provided will stored in this variable
else { $script:Credential = $null }

# Check if the script is running with Administrator Privlieges, if not it will attempt to re-run and prompt for credentials
# Not Using the following commandline, but rather the script below
# Note: Unable to . source this code from another file or use the call '&' operator to use as external cmdlet; it won't run the new terminal/GUI as Admin
# #Requires -RunAsAdministrator
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic")
    $verify = [Microsoft.VisualBasic.Interaction]::MsgBox(`
        "Attention Under-Privileged User!`n   $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)`n`nThe remote commands executed to collect data require elevated credentials. Select 'Yes' to attempt to run this script with elevated privileges; select 'No' to run this script with the current user's privileges; or select 'Cancel' and re-run this script with an Administrator terminal.",`
        'YesNoCancel,Question',`
        "PoSh-EasyWin")
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

# Creates a log entry to an external file
. "$Dependencies\Code\Main Body\Create-LogEntry.ps1"

# Logs what account ran the script and when
Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "===================================================================================================="
Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "PoSh-EasyWin Started By: $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"

# This prompts the user for accepting the GPLv3 License
if ($AcceptEULA) {
    Write-Host -ForeGroundColor Green  "You accepted the EULA."
    Write-Host -ForeGroundColor Yellow "For more infor, visit https://www.gnu.org/licenses/gpl-3.0.html or view a copy in the Dependencies folder."
}
else {
    Get-Content "$Dependencies\GPLv3 Notice.txt" | Out-GridView -Title 'PoSh-EasyWin User Agreement' -PassThru | Set-Variable -Name UserAgreement
    if ($UserAgreement) { 
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "PoSh-EasyWin User Agreemennt Accepted By: $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)" 
        Write-Host -ForeGroundColor Green  "You accepted the EULA."
        Write-Host -ForeGroundColor Yellow "For more infor, visit https://www.gnu.org/licenses/gpl-3.0.html or view a copy in the Dependencies folder."
            Start-Sleep -Seconds 1
    }
    else { 
        [system.media.systemsounds]::Exclamation.play()
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "PoSh-EasyWin User Agreemennt NOT Accepted By: $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"
        Write-Host -ForeGroundColor Red    "You must accept the EULA to continue."
        Write-Host -ForeGroundColor Yellow "For more infor, visit https://www.gnu.org/licenses/gpl-3.0.html or view a copy in the Dependencies folder."
        exit 
    }
    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "===================================================================================================="
}

#============================================================================================================================================================
#   __  __         _            _____                       
#  |  \/  |  __ _ (_) _ __     |  ___|___   _ __  _ __ ___  
#  | |\/| | / _` || || '_ \    | |_  / _ \ | '__|| '_ ` _ \ 
#  | |  | || (_| || || | | |   |  _|| (_) || |   | | | | | |
#  |_|  |_| \__,_||_||_| |_|   |_|   \___/ |_|   |_| |_| |_|                                                                                                        
#
#============================================================================================================================================================

# Generates the GUI and contains the majority of the script
[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null

#[System.Windows.Forms.Application]::EnableVisualStyles()
$PoShEasyWin = New-Object System.Windows.Forms.Form -Property @{
    Text          = "PoSh-EasyWin   [$([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)]"
    StartPosition = "CenterScreen"
    Size          = @{ Width  = 1260 #1241
                       Height = 660 } #638
    Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
    AutoScroll    = $True
    FormBorderStyle =  'Sizable' #  Fixed3D, FixedDialog, FixedSingle, FixedToolWindow, None, Sizable, SizableToolWindow
    #backgroundimage =  [system.drawing.image]::FromFile("C:\Users\Administrator\Desktop\PoSh-EasyWin\Dependencies\Background Image 001.jpg")
}

# Takes the entered domain and lists all computers
. "$Dependencies\Code\Execution\Enumeration\Import-HostsFromDomain.ps1"

# Provides messages when hovering over various areas in the GUI
. "$Dependencies\Code\Main Body\Show-ToolTip.ps1"

# These are the common settings for buttons in a function
. "$Dependencies\Code\Main Body\CommonButtonSettings.ps1"

#============================================================================================================================================================
#
#  Parent: Main Form
#   __  __         _            _            __  _       _____       _       ____               _                _ 
#  |  \/  |  __ _ (_) _ __     | |     ___  / _|| |_    |_   _|__ _ | |__   / ___| ___   _ __  | |_  _ __  ___  | |
#  | |\/| | / _` || || '_ \    | |    / _ \| |_ | __|     | | / _` || '_ \ | |    / _ \ | '_ \ | __|| '__|/ _ \ | |
#  | |  | || (_| || || | | |   | |___|  __/|  _|| |_      | || (_| || |_) || |___| (_) || | | || |_ | |  | (_) || |
#  |_|  |_| \__,_||_||_| |_|   |_____|\___||_|   \__|     |_| \__,_||_.__/  \____|\___/ |_| |_| \__||_|   \___/ |_|                                                                                                           
#
#============================================================================================================================================================

$MainLeftTabControlBoxWidth  = 460
$MainLeftTabControlBoxHeight = 590

$MainLeftTabControl = New-Object System.Windows.Forms.TabControl -Property @{
    Name     = "Main Tab Window"
    Location = @{ X = 5
                  Y = 5 }
    Size     = @{ Width  = $MainLeftTabControlBoxWidth
                  Height = $MainLeftTabControlBoxHeight }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    SelectedIndex = 0
    ShowToolTips  = $True
}
$PoShEasyWin.Controls.Add($MainLeftTabControl)


#============================================================================================================================================================
#
#  Parent: Main Form -> Main Left TabControl
#    ____        _  _              _    _                        _____       _      ____                     
#   / ___| ___  | || |  ___   ___ | |_ (_)  ___   _ __   ___    |_   _|__ _ | |__  |  _ \  __ _   __ _   ___ 
#  | |    / _ \ | || | / _ \ / __|| __|| | / _ \ | '_ \ / __|     | | / _` || '_ \ | |_) |/ _` | / _` | / _ \
#  | |___| (_) || || ||  __/| (__ | |_ | || (_) || | | |\__ \     | || (_| || |_) ||  __/| (_| || (_| ||  __/
#   \____|\___/ |_||_| \___| \___| \__||_| \___/ |_| |_||___/     |_| \__,_||_.__/ |_|    \__,_| \__, | \___|
#                                                                                                |___/       
#============================================================================================================================================================

$Section1CollectionsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text                    = "Collections"
    Name                    = "Collections Tab"
    UseVisualStyleBackColor = $True
    Font                    = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$MainLeftTabControl.Controls.Add($Section1CollectionsTab)

$TabRightPosition     = 3
$TabhDownPosition     = 3
$TabAreaWidth         = 446
$TabAreaHeight        = 557
$TextBoxRightPosition = -2 
$TextBoxDownPosition  = -2
$TextBoxWidth         = 442
$TextBoxHeight        = 536


#============================================================================================================================================================
#
#  Parent: Main Form -> Main Left TabControl -> Collections Tab
#    ____        _  _              _    _                        _____       _       ____               _                _ 
#   / ___| ___  | || |  ___   ___ | |_ (_)  ___   _ __   ___    |_   _|__ _ | |__   / ___| ___   _ __  | |_  _ __  ___  | |
#  | |    / _ \ | || | / _ \ / __|| __|| | / _ \ | '_ \ / __|     | | / _` || '_ \ | |    / _ \ | '_ \ | __|| '__|/ _ \ | |
#  | |___| (_) || || ||  __/| (__ | |_ | || (_) || | | |\__ \     | || (_| || |_) || |___| (_) || | | || |_ | |  | (_) || |
#   \____|\___/ |_||_| \___| \___| \__||_| \___/ |_| |_||___/     |_| \__,_||_.__/  \____|\___/ |_| |_| \__||_|   \___/ |_|
#
#============================================================================================================================================================

#------------------------
# Collection Tab Control
#------------------------
$MainLeftCollectionsTabControl = New-Object System.Windows.Forms.TabControl -Property @{
    Name     = "Collections TabControl"
    Location = @{ X = $TabRightPosition
                  Y = $TabhDownPosition }
    Size     = @{ Width  = $TabAreaWidth
                  Height = $TabAreaHeight }
    ShowToolTips  = $True
    SelectedIndex = 0
    Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$Section1CollectionsTab.Controls.Add($MainLeftCollectionsTabControl)


#============================================================================================================================================================
#
#  Parent: Main Form -> Main Left TabControl -> Collections TabControl
#    ___                      _                _____       _      ____                     
#   / _ \  _   _   ___  _ __ (_)  ___  ___    |_   _|__ _ | |__  |  _ \  __ _   __ _   ___ 
#  | | | || | | | / _ \| '__|| | / _ \/ __|     | | / _` || '_ \ | |_) |/ _` | / _` | / _ \
#  | |_| || |_| ||  __/| |   | ||  __/\__ \     | || (_| || |_) ||  __/| (_| || (_| ||  __/
#   \__\_\ \__,_| \___||_|   |_| \___||___/     |_| \__,_||_.__/ |_|    \__,_| \__, | \___|
#                                                                              |___/       
#============================================================================================================================================================

$QueriesRightPosition     = 5
$QueriesDownPositionStart = 10
$QueriesDownPosition      = 10
$QueriesDownPositionShift = 25
$QueriesBoxWidth          = 410
$QueriesBoxHeight         = 25

#------------------
# Commands TabPage
#------------------
$Section1CommandsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text     = "Queries"
    Location = @{ X = $Column1RightPosition
                  Y = $Column1DownPosition }
    Size     = @{ Width  = $Column1BoxWidth
                  Height = $Column1BoxHeight }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    UseVisualStyleBackColor = $True
}
$MainLeftCollectionsTabControl.Controls.Add($Section1CommandsTab)


#-------------------
# Endpoint Commands
#-------------------
# Imports all the Endpoint Commands fromthe csv file
$script:AllEndpointCommands = Import-Csv $CommandsEndpoint

# Imports scripts from the Endpoint script folder and loads them into the treeview
# New scripts can be added to 'Dependencies\Query Commands and Scripts\Scirpts - Endpoint' to be imported
# Verify that the scripts function properly and return results with the Invoke-Command cmdlet
. "$Dependencies\Code\Main Body\Import-EndpointScripts.ps1"
Import-EndpointScripts


#---------------------------
# Active Directory Commands
#---------------------------
# Imports all the Active Directoyr Commands fromthe csv file
$script:AllActiveDirectoryCommands = Import-Csv $CommandsActiveDirectory

# Imports scripts from the Active Directory script folder and loads them into the treeview
# New scripts can be added to 'Dependencies\Query Commands and Scripts\Scirpts - Active Directory' to be imported
# Verify that the scripts function properly and return results with the Invoke-Command cmdlet
. "$Dependencies\Code\Main Body\Import-ActiveDirectoryScripts.ps1"
Import-ActiveDirectoryScripts


#------------------------
# Query History Commands
#------------------------
# Initializes/empties the Query History Commands array
# Queries executed will be stored within this array and added later to as treenodes
$script:QueryHistoryCommands = @()


#======================================================================
#   ______             _    ___                 ______          __   
#  /_  __/_______  ___| |  / (_)__ _      __   / ____/___  ____/ /__ 
#   / / / ___/ _ \/ _ \ | / / / _ \ | /| / /  / /   / __ \/ __  / _ \
#  / / / /  /  __/  __/ |/ / /  __/ |/ |/ /  / /___/ /_/ / /_/ /  __/
# /_/ /_/   \___/\___/|___/_/\___/|__/|__/   \____/\____/\__,_/\___/ 
#
#======================================================================

$script:TreeeViewComputerListCount = 0
$script:TreeeViewCommandsCount     = 0

# Handles the behavior of nodes when clicked, such as checking all sub-checkboxes, changing text colors, and Tabs selected.
# Also counts the total number of checkboxes checked (both command and computer treenodes, and other query checkboxes) and
# changes the color of the start collection button to-and-from Green.
. "$Dependencies\Code\Tree View\Conduct-NodeAction.ps1"

# Initializes the Commands TreeView section that various command nodes are added to
# TreeView initialization initially happens upon load and whenever the it is regenerated, like when switching between views 
# These include the root nodes of Search, Endpoint and Active Directory queryies by method and type, and Query History
. "$Dependencies\Code\Tree View\Command\Initialize-CommandTreeNodes.ps1"

# This will keep the Command TreeNodes checked when switching between Method and Command views
. "$Dependencies\Code\Tree View\Command\KeepChecked-CommandTreeNode.ps1"

# Adds a treenode to the specified root node... a command node within a category node
. "$Dependencies\Code\Tree View\Command\Add-CommandTreeNode.ps1"

$script:HostQueryTreeViewSelected = ""

# This builds out the Commands TreeView with command nodes
# The TreeNodes are organized by the Method the queries are conducted, eg: RPC, WinRM
. "$Dependencies\Code\Tree View\Command\View-CommandTreeNodeMethod.ps1"

# This builds out the Commands TreeView with command nodes
# The TreeNodes are organized by the Query/Commannd Topic the queries are conducted, eg: Processes, Services
. "$Dependencies\Code\Tree View\Command\View-CommandTreeNodeQuery.ps1"

# Deselects all nodes within the indicated treeview
. "$Dependencies\Code\Main Body\DeselectAllCommands.ps1"
. "$Dependencies\Code\Main Body\DeselectAllComputers.ps1"

#============================================================================================================================================================
# Commands - Treeview Options at the top
#============================================================================================================================================================
# Imports the Query History and populates the command treenode
$script:QueryHistory = Import-CliXml "$PoShHome\Query History.xml"
function Update-QueryHistory {
    foreach ($Command in $script:QueryHistory) {
        $Command | Add-Member -MemberType NoteProperty -Name CategoryName -Value "$($Command.CategoryName)" -Force
        Add-CommandTreeNode -RootNode $script:TreeNodePreviouslyExecutedCommands -Category "$($Command.CategoryName)" -Entry "$($Command.Name)" -ToolTip $Command.Command
    }
}
Update-QueryHistory

#---------------------------------------------------
# Commands Treeview - View hostname/IPs by GroupBox
#---------------------------------------------------
$CommandsTreeViewViewByGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text     = "Display And Group By:"
    Location = @{ X = 0
                  Y = 5
                }
    Size     = @{ Width  = 232 #173
                  Height = 37
                }
    Font     = New-Object System.Drawing.Font("$Font",11,1,2,1)
    ForeColor = 'Blue'
}

    #---------------------------------------------
    # Commands TreeView - Method Type RadioButton
    #---------------------------------------------
    . "$Dependencies\Code\System.Windows.Forms\RadioButton\CommandsViewMethodRadioButton.ps1"
    $CommandsViewMethodRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
        Text     = "Method"
        Location = @{ X = 10
                      Y = 13 }
        Size     = @{ Width  = 70
                      Height = 22 }
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = 'Black'
        Checked   = $True
        Add_Click = $CommandsViewMethodRadioButtonAdd_Click
        Add_MouseHover = $CommandsViewMethodRadioButtonAdd_MouseHover
    }
    $CommandsTreeViewViewByGroupBox.Controls.Add( $CommandsViewMethodRadioButton )


    #--------------------------------------------
    # Commands TreeView - Query Type RadioButton
    #--------------------------------------------
    . "$Dependencies\Code\System.Windows.Forms\RadioButton\CommandsViewQueryRadioButton.ps1"
    $CommandsViewQueryRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
        Text     = "Commands"
        Location = @{ X = $CommandsViewMethodRadioButton.Location.X + $CommandsViewMethodRadioButton.Size.Width
                      Y = $CommandsViewMethodRadioButton.Location.Y }
        Size     = @{ Width  = 90
                      Height = 22 }
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = 'Black'
        Checked   = $false
        Add_Click      = $CommandsViewQueryRadioButtonAdd_Click
        Add_MouseHover = $CommandsViewQueryRadioButtonAdd_MouseHover
    }
    $CommandsTreeViewViewByGroupBox.Controls.Add($CommandsViewQueryRadioButton)

$Section1CommandsTab.Controls.Add($CommandsTreeViewViewByGroupBox)


#-------------------------------------
# Commands TreeView - PoSh-EasyWin Image
#-------------------------------------
$PoShEasyWinLogoPictureBox = New-Object System.Windows.Forms.PictureBox -Property @{
    #text     = "PoSh-EasyWin Image"
    Location = @{ X = $CommandsTreeViewViewByGroupBox.Location.X + $CommandsTreeViewViewByGroupBox.Size.Width + 15
                  Y = $CommandsTreeViewViewByGroupBox.Location.Y }
    Size     = @{ Width  = 175
                  Height = 35 }
    AutoSize = $true
    SizeMode = 'Stretch'
    Image = [System.Drawing.Image]::FromFile("$Dependencies\PoSh-EasyWin Image.png" )
    #InitialImage = $null
    #ErrorImage   = $null
}
$Section1CommandsTab.Controls.Add($PoShEasyWinLogoPictureBox)


# Searches for command nodes that match a given search entry
# A new category node named by the search entry will be created and all results will be nested within
. "$Dependencies\Code\Tree View\Command\Search-CommandTreeNode.ps1"


#------------------------------------
# Computer TreeView - Search TextBox
#------------------------------------
. "$Dependencies\Code\System.Windows.Forms\ComboBox\CommandsTreeViewSearchComboBox.ps1"
$CommandsTreeViewSearchComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Name     = "Search TextBox"
    Location = @{ X = 0
                  Y = 45 }
    Size     = @{ Width  = 172
                  Height = 25 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
    Add_KeyDown    = $CommandsTreeViewSearchComboBoxAdd_KeyDown
    Add_MouseHover = $CommandsTreeViewSearchComboBoxAdd_MouseHover
}
    $CommandTypes = @("Chart","File","Hardware","Hunt","Network","System","User")
    ForEach ($Type in $CommandTypes) { [void] $CommandsTreeViewSearchComboBox.Items.Add($Type) }
$Section1CommandsTab.Controls.Add($CommandsTreeViewSearchComboBox)


#-----------------------------------
# Commands TreeView - Search Button
#-----------------------------------
. "$Dependencies\Code\System.Windows.Forms\Button\CommandsTreeViewSearchButton.ps1"
$CommandsTreeViewSearchButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Search"
    Location = @{ X = $CommandsTreeViewSearchComboBox.Size.Width + 5
                  Y = 45 }
    Size     = @{ Width  = 55
                  Height = 22 }
    Add_Click      = $CommandsTreeViewSearchButtonAdd_Click
    Add_MouseHover = $CommandsTreeViewSearchButtonAdd_MouseHover
}
$Section1CommandsTab.Controls.Add($CommandsTreeViewSearchButton)
CommonButtonSettings -Button $CommandsTreeViewSearchButton


#-----------------------------------------
# Commands Treeview - Deselect All Button
#-----------------------------------------
. "$Dependencies\Code\System.Windows.Forms\Button\CommandsTreeviewDeselectAllButton.ps1"
$CommandsTreeviewDeselectAllButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = 'Deselect All'
    Location = @{ X = 335
                  Y = 45 }
    Size     = @{ Width  = 100
                  Height = 22 }
    Add_Click      = $CommandsTreeviewDeselectAllButtonAdd_Click
    Add_MouseHover = $CommandsTreeviewDeselectAllButtonAdd_MouseHover
}
$Section1CommandsTab.Controls.Add($CommandsTreeviewDeselectAllButton) 
CommonButtonSettings -Button $CommandsTreeviewDeselectAllButton


#--------------------------------------------
# Commands Treeview - History Removal Button
#--------------------------------------------
. "$Dependencies\Code\System.Windows.Forms\Button\CommandsTreeViewQueryHistoryRemovalButton.ps1"
$CommandsTreeViewQueryHistoryRemovalButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "Remove Query History"
    Location = @{ X = 265
                  Y = 504 }
    Size     = @{ Width  = 150
                  Height = 22 }
    Add_Click = $CommandsTreeViewQueryHistoryRemovalButtonAdd_Click
}
CommonButtonSettings -Button $CommandsTreeViewQueryHistoryRemovalButton

# Note: This button is added/removed dynamicallly when query history category treenodes are selected


#-------------------------
# Commands Treeview Nodes
#-------------------------
$script:CommandsTreeView = New-Object System.Windows.Forms.TreeView -Property @{
    Location = @{ X = 0 
                  Y = 70 }
    Size     = @{ Width  = 435
                  Height = 459 }
    Font             = New-Object System.Drawing.Font("$Font",11,0,0,0)
    CheckBoxes       = $True
    #LabelEdit       = $True
    ShowLines        = $True
    ShowNodeToolTips = $True
    Add_Click       = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
    Add_AfterSelect = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
    
}
$script:CommandsTreeView.Sort()
$Section1CommandsTab.Controls.Add($script:CommandsTreeView)

# Default View
Initialize-CommandTreeNodes

# This adds the nodes to the Commands TreeView
View-CommandTreeNodeMethod

$script:CommandsTreeView.Nodes.Add($script:TreeNodeEndpointCommands)
$script:CommandsTreeView.Nodes.Add($script:TreeNodeActiveDirectoryCommands)
$script:CommandsTreeView.Nodes.Add($script:TreeNodeCommandSearch)
$script:CommandsTreeView.Nodes.Add($script:TreeNodePreviouslyExecutedCommands)
#$script:CommandsTreeView.ExpandAll()


#============================================================================================================================================================
#
#  Parent: Main Form -> Main Left TabControl -> Collections TabControl
#   _____                     _       _                           _____       _      ____                     
#  | ____|__   __ ___  _ __  | |_    | |     ___    __ _  ___    |_   _|__ _ | |__  |  _ \  __ _   __ _   ___ 
#  |  _|  \ \ / // _ \| '_ \ | __|   | |    / _ \  / _` |/ __|     | | / _` || '_ \ | |_) |/ _` | / _` | / _ \
#  | |___  \ V /|  __/| | | || |_    | |___| (_) || (_| |\__ \     | || (_| || |_) ||  __/| (_| || (_| ||  __/
#  |_____|  \_/  \___||_| |_| \__|   |_____|\___/  \__, ||___/     |_| \__,_||_.__/ |_|    \__,_| \__, | \___|
#                                                  |___/                                          |___/          
#============================================================================================================================================================

$EventLogsRightPosition     = 5
$EventLogsDownPositionStart = 10
$EventLogsDownPosition      = 10
$EventLogsDownPositionShift = 22
$EventLogsBoxWidth          = 410
$EventLogsBoxHeight         = 22

#--------------------
# Event Logs TabPage
#--------------------
$Section1EventLogsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text     = "Event Logs"
    Location = @{ X = $Column1RightPosition
                  Y = $Column1DownPosition }
    Size     = @{ Width  = $Column1BoxWidth
                  Height = $Column1BoxHeight }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    UseVisualStyleBackColor = $True
}
$MainLeftCollectionsTabControl.Controls.Add($Section1EventLogsTab)


#-------------------------
# Event Logs - Main Label
#-------------------------
$EventLogsMainLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "Event Logs can be obtained from workstations and servers."
    Location = @{ X = 5
                  Y = 5 }
    Size     = @{ Width  = $EventLogsBoxWidth
                  Height = $EventLogsBoxHeight }
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
                  Y = $EventLogsMainLabel.Location.Y + $EventLogsMainLabel.Size.Height }
    Size     = @{ Width  = 425
                  Height = 94 }
    Font      = New-Object System.Drawing.Font("$Font",12,1,2,1)
    ForeColor = "Blue"
}


    #---------------------------------------
    # Event Log Protocol Radio Button Label
    #---------------------------------------
    $EventLogProtocolRadioButtonLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Protocol:"
        Location = @{ X = 7
                      Y = 20 }
        Size     = @{ Width  = 73
                      Height = 20 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = 'Black'
    }


    #-----------------------------------------
    # Event Log Protocol WinRM - Radio Button
    #-----------------------------------------
    . "$Dependencies\Code\System.Windows.Forms\RadioButton\EventLogWinRMRadioButton.ps1"
    $EventLogWinRMRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
        Text     = "WinRM"
        Location = @{ X = 80
                      Y = 15 }
        Size     = @{ Width  = 80
                      Height = 22 }
        Checked  = $True
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = 'Black'
        Add_Click      = $EventLogWinRMRadioButtonAdd_Click
        Add_MouseHover = $EventLogWinRMRadioButtonAdd_MouseHover
    }


    #---------------------------------------
    # Event Log Protocol RPC - Radio Button
    #---------------------------------------
    . "$Dependencies\Code\System.Windows.Forms\RadioButton\EventLogRPCRadioButton.ps1"
    $EventLogRPCRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
        Text     = "RPC"
        Location = @{ X = $EventLogWinRMRadioButton.Location.X + $EventLogWinRMRadioButton.Size.Width + 10
                      Y = $EventLogWinRMRadioButton.Location.Y }
        Size     = @{ Width  = 60
                      Height = 22 }
        Checked  = $False
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = 'Black'
        Add_Click      = $EventLogRPCRadioButtonAdd_Click
        Add_MouseHover = $EventLogRPCRadioButtonAdd_MouseHover
    }


    #---------------------------------------
    # Event Logs - Maximum Collection Label
    #---------------------------------------
    . "$Dependencies\Code\System.Windows.Forms\Label\EventLogsMaximumCollectionLabel.ps1"
    $EventLogsMaximumCollectionLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Max Collection:"
        Location = @{ X = $EventLogRPCRadioButton.Location.X + $EventLogRPCRadioButton.Size.Width + 35
                      Y = $EventLogRPCRadioButton.Location.Y + 3 }
        Size     = @{ Width  = 100
                      Height = 22 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = "Black"
        Add_MouseHover = $EventLogsMaximumCollectionLabelAdd_MouseHover
    }


        #-----------------------------------------
        # Event Logs - Maximum Collection TextBox
        #-----------------------------------------
        . "$Dependencies\Code\System.Windows.Forms\TextBox\EventLogsMaximumCollectionTextBox.ps1"
        $EventLogsMaximumCollectionTextBox = New-Object System.Windows.Forms.TextBox -Property @{
            Text     = 100
            Location = @{ X = $EventLogsMaximumCollectionLabel.Location.X + $EventLogsMaximumCollectionLabel.Size.Width
                          Y = $EventLogsMaximumCollectionLabel.Location.Y - 3 }
            Size     = @{ Width  = 50
                          Height = 22 }
            Font     = New-Object System.Drawing.Font("$Font",10,0,0,0)
            Enabled  = $True
            Add_MouseHover = $EventLogsMaximumCollectionTextBoxAdd_MouseHover
        }


    #-----------------------------------
    # Event Logs - DateTime Start Label
    #-----------------------------------
    $EventLogsDatetimeStartLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "DateTime Start:"
        Location = @{ X = 77
                      Y = $EventLogProtocolRadioButtonLabel.Location.Y + $EventLogProtocolRadioButtonLabel.Size.Height + 5 }
        Size     = @{ Width  = 90
                      Height = 22 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = "Black"
    }


    #--------------------------------------------
    # Event Logs - DateTime Start DateTimePicker
    #--------------------------------------------
    . "$Dependencies\Code\System.Windows.Forms\DateTimePicker\EventLogsStartTimePicker.ps1"
    $EventLogsStartTimePicker = New-Object System.Windows.Forms.DateTimePicker -Property @{
        Location      = @{ X = $EventLogsDatetimeStartLabel.Location.X + $EventLogsDatetimeStartLabel.Size.Width
                           Y = $EventLogProtocolRadioButtonLabel.Location.Y + $EventLogProtocolRadioButtonLabel.Size.Height }
        Size          = @{ Width  = 250
                           Height = 100 }
        Font         = New-Object System.Drawing.Font("$Font",11,0,0,0)
        Format       = [windows.forms.datetimepickerFormat]::custom
        CustomFormat = “dddd MMM dd, yyyy hh:mm tt”
        Enabled      = $True
        Checked      = $True
        ShowCheckBox = $True
        ShowUpDown   = $False
        AutoSize     = $true
        #MinDate      = (Get-Date -Month 1 -Day 1 -Year 2000).DateTime
        #MaxDate      = (Get-Date).DateTime
        Value         = (Get-Date).AddDays(-1).DateTime
        Add_Click      = $EventLogsStartTimePickerAdd_Click
        Add_MouseHover = $EventLogsStartTimePickerAdd_MouseHover
    }
    # Wednesday, June 5, 2019 10:27:40 PM
    # $TimePicker.Value
    # 20190605162740.383143-240
    # [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime(($EventLogsStartTimePicker.Value))
    
    
    #----------------------------------
    # Event Logs - Datetime Stop Label
    #----------------------------------
    $EventLogsDatetimeStopLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "DateTime Stop:"
        Location = @{ X = $EventLogsDatetimeStartLabel.Location.X
                      Y = $EventLogsDatetimeStartLabel.Location.Y + $EventLogsDatetimeStartLabel.Size.Height }
        Size     = @{ Width  = $EventLogsDatetimeStartLabel.Width
                      Height = 22 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = "Black"
    }


    #-------------------------------------------
    # Event Logs - DateTime Stop DateTimePicker
    #-------------------------------------------
    . "$Dependencies\Code\System.Windows.Forms\DateTimePicker\EventLogsStopTimePicker.ps1"
    $EventLogsStopTimePicker = New-Object System.Windows.Forms.DateTimePicker -Property @{
        Location     = @{ X = $EventLogsDatetimeStopLabel.Location.X + $EventLogsDatetimeStopLabel.Size.Width
                          Y = $EventLogsDatetimeStartLabel.Location.Y + $EventLogsDatetimeStartLabel.Size.Height - 5 }
        Size         = @{ Width  = $EventLogsStartTimePicker.Width
                          Height = 100 }
        Font         = New-Object System.Drawing.Font("$Font",11,0,0,0)
        Format       = [windows.forms.datetimepickerFormat]::custom
        CustomFormat = “dddd MMM dd, yyyy hh:mm tt”
        Enabled      = $True
        Checked      = $True
        ShowCheckBox = $True
        ShowUpDown   = $False
        AutoSize     = $true
        #MinDate      = (Get-Date -Month 1 -Day 1 -Year 2000).DateTime
        #MaxDate      = (Get-Date).DateTime
        Add_MouseHover = $EventLogsStartTimePickerAdd_MouseHover
    }    
    $EventLogsOptionsGroupBox.Controls.AddRange(@($EventLogProtocolRadioButtonLabel,$EventLogRPCRadioButton,$EventLogWinRMRadioButton,$EventLogsDatetimeStartLabel,$EventLogsStartTimePicker,$EventLogsDatetimeStopLabel,$EventLogsStopTimePicker,$EventLogsMaximumCollectionLabel,$EventLogsMaximumCollectionTextBox))
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
                  Y = $EventLogsOptionsGroupBox.Location.Y + $EventLogsOptionsGroupBox.Size.Height + 10 }
    Size     = @{ Width  = 200
                  Height = $EventLogsBoxHeight }
    Font     = New-Object System.Drawing.Font("$Font",12,1,2,1)
    ForeColor = 'Blue'
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
}
$Section1EventLogsTab.Controls.Add($EventLogsEventIDsManualEntryCheckbox)


#--------------------------------------------
# Event Logs - Event IDs Manual Entry Label
#--------------------------------------------
$EventLogsEventIDsManualEntryLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "Enter Event IDs; One Per Line"
    Location = @{ X = 5
                  Y = $EventLogsEventIDsManualEntryCheckbox.Location.Y + $EventLogsEventIDsManualEntryCheckbox.Size.Height }
    Size     = @{ Width  = 200
                  Height = $EventLogsBoxHeight }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Black"
}
$Section1EventLogsTab.Controls.Add($EventLogsEventIDsManualEntryLabel)


#-------------------------------------------------------
# Event Logs - Event IDs Manual Entry Selection Button
#-------------------------------------------------------
. "$Dependencies\Code\System.Windows.Forms\Button\EventLogsEventIDsManualEntrySelectionButton.ps1"
$EventLogsEventIDsManualEntrySelectionButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Select Event IDs"
    Location = @{ X = 4
                  Y = $EventLogsEventIDsManualEntryLabel.Location.Y + $EventLogsEventIDsManualEntryLabel.Size.Height }
    Size     = @{ Width  = 125
                  Height = 20 }
    Add_Click = $EventLogsEventIDsManualEntrySelectionButtonAdd_Click
}
$Section1EventLogsTab.Controls.Add($EventLogsEventIDsManualEntrySelectionButton) 
CommonButtonSettings -Button $EventLogsEventIDsManualEntrySelectionButton


#---------------------------------------------------
# Event Logs - Event IDs Manual Entry Clear Button
#---------------------------------------------------
$EventLogsEventIDsManualEntryClearButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Clear"
    Location = @{ X = 136
                  Y = $EventLogsEventIDsManualEntryLabel.Location.Y + $EventLogsEventIDsManualEntryLabel.Size.Height }
    Size     = @{ Width  = 75
                  Height = 20 }
    Add_Click = { $EventLogsEventIDsManualEntryTextbox.Text = "" }
}
$Section1EventLogsTab.Controls.Add($EventLogsEventIDsManualEntryClearButton) 
CommonButtonSettings -Button $EventLogsEventIDsManualEntryClearButton


#----------------------------------------------
# Event Logs - Event IDs Manual Entry Textbox
#----------------------------------------------
$EventLogsEventIDsManualEntryTextbox = New-Object System.Windows.Forms.TextBox -Property @{
    Lines   = $null
    Location = @{ X = 5
                  Y = $EventLogsEventIDsManualEntryClearButton.Location.Y + $EventLogsEventIDsManualEntryClearButton.Size.Height + 5 }
    Size     = @{ Width  = 205
                  Height = 139 }
    MultiLine     = $True
    WordWrap      = $True
    AcceptsTab    = $false 
    AcceptsReturn = $false 
    ScrollBars    = "Vertical"
    Font           = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$Section1EventLogsTab.Controls.Add($EventLogsEventIDsManualEntryTextbox)

# Imports code that populates the Event IDs Quick Pick Selection,
# esentially tying a single name/selection to multiple predetermined Event IDs
. "$Dependencies\Code\Main Body\Populate-EventLogsEventIDQuickPick.ps1"


#--------------------------------------------
# Event Logs - Event IDs Quick Pick CheckBox
#--------------------------------------------
$EventLogsQuickPickSelectionCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Event IDs Quick Selection"
    Location = @{ X = 220
                  Y = $EventLogsOptionsGroupBox.Location.Y + $EventLogsOptionsGroupBox.Size.Height + 10 }
    Size     = @{ Width  = 200
                  Height = $EventLogsBoxHeight }
    Font     = New-Object System.Drawing.Font("$Font",12,1,2,1)
    ForeColor = 'Blue'
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
}
$Section1EventLogsTab.Controls.Add( $EventLogsQuickPickSelectionCheckbox )


#-----------------------------------------
# Event Logs - Event IDs Quick Pick Label
#-----------------------------------------
$EventLogsQuickPickSelectionLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = "Event IDs by Topic - Can Select Multiple"
    Location = @{ X = 218
                  Y = $EventLogsQuickPickSelectionCheckbox.Location.Y + $EventLogsQuickPickSelectionCheckbox.Size.Height }
    Size     = @{ Width  = $EventLogsBoxWidth
                  Height = $EventLogsBoxHeight }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Black"
}


#-----------------------------------------------------------
# Event Logs - Event IDs Quick Pick Selection Clear Button
#-----------------------------------------------------------
. "$Dependencies\Code\System.Windows.Forms\Button\EventLogsQuickPickSelectionClearButton.ps1"
$EventLogsQuickPickSelectionClearButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Clear"
    Location = @{ X = 356
                  Y = $EventLogsQuickPickSelectionLabel.Location.Y + $EventLogsQuickPickSelectionLabel.Size.Height }
    Size     = @{ Width  = 75
                  Height = 20 }
    Add_Click = $EventLogsQuickPickSelectionClearButtonAdd_Click
}
$Section1EventLogsTab.Controls.Add($EventLogsQuickPickSelectionClearButton) 
$Section1EventLogsTab.Controls.Add($EventLogsQuickPickSelectionLabel) 
CommonButtonSettings -Button $EventLogsQuickPickSelectionClearButton


#-------------------------------------------------
# Event Logs - Event IDs Quick Pick CheckListBox
#-------------------------------------------------
. "$Dependencies\Code\System.Windows.Forms\CheckedListBox\EventLogsQuickPickSelectionCheckedListBox.ps1"
$EventLogsQuickPickSelectionCheckedListBox = New-Object -TypeName System.Windows.Forms.CheckedListBox -Property @{
    Name     = "Event Logs Selection"
    Text     = "Event Logs Selection"
    Location = @{ X = 220
                  Y = $EventLogsQuickPickSelectionClearButton.Location.Y + $EventLogsQuickPickSelectionClearButton.Size.Height + 5 }
    Size     = @{ Width  = 210
                  Height = 150 }
    ScrollAlwaysVisible = $true
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    Add_Click = $EventLogsQuickPickSelectionCheckedListBoxAdd_Click
}
foreach ( $Query in $script:EventLogQueries ) { $EventLogsQuickPickSelectionCheckedListBox.Items.Add("$($Query.Name)") }
$Section1EventLogsTab.Controls.Add($EventLogsQuickPickSelectionCheckedListBox)


#============================================================================================================================================================
# Event Logs - Event IDs To Monitor
#============================================================================================================================================================
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


#--------------------------------------------
# Event Logs - Event IDs To Monitor CheckBox
#--------------------------------------------
$EventLogsEventIDsToMonitorCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Event IDs To Monitor"
    Location = @{ X = 7
                    Y = $EventLogsEventIDsManualEntryTextbox.Location.Y + $EventLogsEventIDsManualEntryTextbox.Size.Height + 15 }
    Size     = @{ Width  = 350
                    Height = $EventLogsBoxHeight }
    Font     = New-Object System.Drawing.Font("$Font",12,1,2,1)
    ForeColor = 'Blue'
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
}
$Section1EventLogsTab.Controls.Add($EventLogsEventIDsToMonitorCheckbox)


#------------------------------------------------
# Event Logs - Event IDs To Monitor Clear Button
#------------------------------------------------
. "$Dependencies\Code\System.Windows.Forms\Button\EventLogsEventIDsToMonitorClearButton.ps1"
$EventLogsEventIDsToMonitorClearButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Clear"
    Location = @{ X = 356
                  Y = $EventLogsEventIDsToMonitorCheckbox.Location.Y + $EventLogsEventIDsToMonitorCheckbox.Size.Height - 3 }
    Size     = @{ Width  = 75
                  Height = 20 }
    Add_Click = $EventLogsEventIDsToMonitorClearButtonAdd_Click
}
$Section1EventLogsTab.Controls.Add($EventLogsEventIDsToMonitorClearButton) 
CommonButtonSettings -Button $EventLogsEventIDsToMonitorClearButton


#----------------------------------------------------
# Event Logs - Event IDs To Monitor Label
#----------------------------------------------------
$EventLogsEventIDsToMonitorLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "Events IDs to Monitor for Signs of Compromise"
    Location = @{ X = 5
                    Y = $EventLogsEventIDsToMonitorCheckbox.Location.Y + $EventLogsEventIDsToMonitorCheckbox.Size.Height }
    Size     = @{ Width  = $EventLogsBoxWidth
                    Height = $EventLogsBoxHeight }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Black"
}
$Section1EventLogsTab.Controls.Add($EventLogsEventIDsToMonitorLabel)


#-----------------------------------------------------------
# Event Logs - Event IDs To Monitor CheckListBox
#-----------------------------------------------------------
. "$Dependencies\Code\System.Windows.Forms\CheckedListBox\EventLogsEventIDsToMonitorCheckedListBox.ps1"
$EventLogsEventIDsToMonitorCheckListBox = New-Object -TypeName System.Windows.Forms.CheckedListBox -Property @{
    Text     = "Event IDs [Potential Criticality] Event Summary"
    Location = @{ X = 5
                    Y = $EventLogsEventIDsToMonitorLabel.Location.Y + $EventLogsEventIDsToMonitorLabel.Size.Height }
    Size     = @{ Width  = 425
                    Height = 125 }
    #checked            = $true
    #CheckOnClick       = $true #so we only have to click once to check a box
    #SelectionMode      = One #This will only allow one options at a time
    ScrollAlwaysVisible = $true
    Add_Click = $EventLogsEventIDsToMonitorCheckedListBoxAdd_Click
}
# Creates the list from the variable
foreach ( $Query in $script:EventLogSeverityQueries ) {
    $EventLogsEventIDsToMonitorCheckListBox.Items.Add("$($Query.EventID) [$($Query.Severity)] $($Query.Message)")    
}
    $EventLogsEventIDsToMonitorCheckListBox.Items.Add("4624 [test] An account was successfully logged on")    
    $EventLogsEventIDsToMonitorCheckListBox.Items.Add("4634 [test] An account was logged off")    
$EventLogsEventIDsToMonitorCheckListBox.Font = New-Object System.Drawing.Font("$Font",11,0,0,0)
$Section1EventLogsTab.Controls.Add($EventLogsEventIDsToMonitorCheckListBox)


#============================================================================================================================================================
#
#  Parent: Main Form -> Main Left TabControl -> Collections TabControl
#   ____               _       _                    _____       _      ____                     
#  |  _ \  ___   __ _ (_) ___ | |_  _ __  _   _    |_   _|__ _ | |__  |  _ \  __ _   __ _   ___ 
#  | |_) |/ _ \ / _` || |/ __|| __|| '__|| | | |     | | / _` || '_ \ | |_) |/ _` | / _` | / _ \
#  |  _ <|  __/| (_| || |\__ \| |_ | |   | |_| |     | || (_| || |_) ||  __/| (_| || (_| ||  __/
#  |_| \_\\___| \__, ||_||___/ \__||_|    \__, |     |_| \__,_||_.__/ |_|    \__,_| \__, | \___|
#               |___/                     |___/                                     |___/             
#============================================================================================================================================================

$Section1RegistryTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text     = "Registry"
    Location = @{ X = $RegistryRightPosition
                  Y = $RegistryDownPosition }
    Size     = @{ Width  = 450
                  Height = 22 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    UseVisualStyleBackColor = $True
}
$MainLeftCollectionsTabControl.Controls.Add($Section1RegistryTab)


#----------------------------------------------------
# Registry Search - Registry Search Command CheckBox
#----------------------------------------------------
. "$Dependencies\Code\System.Windows.Forms\CheckBox\RegistrySearchCheckbox.ps1"
$RegistrySearchCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Registry Search (WinRM)"
    Location = @{ X = 3
                  Y = 15 }
    Size     = @{ Width  = 230
                  Height = 22 }
    Font     = New-Object System.Drawing.Font("$Font",12,1,2,1)
    ForeColor = 'Blue'
    Add_Click = $RegistrySearchCheckboxAdd_Click
}
$Section1RegistryTab.Controls.Add($RegistrySearchCheckbox)


#------------------------------------------------------
# Registry Search - Registry Search Max Depth Checkbox
#------------------------------------------------------
$RegistrySearchRecursiveCheckbox = New-Object System.Windows.Forms.Checkbox -Property @{
    Text     = "Recursive Search"
    Location = @{ X = $RegistrySearchCheckbox.Size.Width + 82
                  Y = $RegistrySearchCheckbox.Location.Y + 3 }
    Size     = @{ Width  = 200
                  Height = 22 }
    Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor  = "Black"
}
$Section1RegistryTab.Controls.Add($RegistrySearchRecursiveCheckbox)


#-----------------------------------------
# Registry Search - Registry Search Label
#-----------------------------------------
$RegistrySearchLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = "Collection time is dependant on the amount of paths and queries; more so if recursive."
    Location = @{ X = $RegistrySearchCheckbox.Location.X
                  Y = $RegistrySearchRecursiveCheckbox.Location.Y + $RegistrySearchRecursiveCheckbox.Size.Height + 10 }
    Size     = @{ Width  = 450
                  Height = 22 }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Black"
}
$Section1RegistryTab.Controls.Add($RegistrySearchLabel)


#---------------------------------------------
# Registry Search - Registry Search Directory Textbox
#---------------------------------------------
. "$Dependencies\Code\System.Windows.Forms\RichTextBox\RegistrySearchDirectoryRichTextbox.ps1"
$script:RegistrySearchDirectoryRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Text     = "Enter Registry Paths; One Per Line"
    Location = @{ X = $RegistrySearchLabel.Location.X
                  Y = $RegistrySearchLabel.Location.Y + $RegistrySearchLabel.Size.Height + 10 }
    Size     = @{ Width  = 430
                  Height = 80 }
    MultiLine     = $True
    ShortcutsEnabled = $true
    Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
    Add_MouseEnter = $RegistrySearchDirectoryRichTextboxAdd_MouseEnter
    Add_MouseLeave = $RegistrySearchDirectoryRichTextboxAdd_MouseLeave
    Add_MouseHover = $RegistrySearchDirectoryRichTextboxAdd_MouseHover    
}
$Section1RegistryTab.Controls.Add($script:RegistrySearchDirectoryRichTextbox)


#------------------------------
# Registry - Key Name Checkbox
#------------------------------
. "$Dependencies\Code\System.Windows.Forms\CheckBox\RegistryKeyNameCheckbox.ps1"
$RegistryKeyNameCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Key Name (Supports RegEx)"
    Location = @{ X = $script:RegistrySearchDirectoryRichTextbox.Location.X 
                  Y = $script:RegistrySearchDirectoryRichTextbox.Location.Y + $script:RegistrySearchDirectoryRichTextbox.Size.Height + 10 }
    Size     = @{ Width  = 300
                  Height = 22 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    Add_Click = $RegistryKeyNameCheckBoxAdd_Click
}
$Section1RegistryTab.Controls.Add($RegistryKeyNameCheckbox)


#-----------------------------------------
# Registry Search - Registry Regex Button
#-----------------------------------------
$SupportsRegexButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Regex Examples"
    Location = @{ X = $RegistryKeyNameCheckbox.Location.X + $RegistryKeyNameCheckbox.Size.Width + 28
                  Y = $RegistryKeyNameCheckbox.Location.Y }
    Size     = @{ Width  = 100
                  Height = 22 }
    Add_Click = { Import-Csv "$Dependencies\RegEx Examples.csv" | Out-GridView }
}
$Section1RegistryTab.Controls.Add($SupportsRegexButton)
CommonButtonSettings -Button $SupportsRegexButton


#------------------------------------------------------
# Registry Search - Registry Value Name Search Textbox
#------------------------------------------------------
. "$Dependencies\Code\System.Windows.Forms\RichTextBox\RegistryKeyNameSearchRichTextbox.ps1"
$script:RegistryKeyNameSearchRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Text     = "Enter Key Name; One Per Line"
    Location = @{ X = $RegistryKeyNameCheckbox.Location.X
                  Y = $RegistryKeyNameCheckbox.Location.Y + $RegistryKeyNameCheckbox.Size.Height + 10 }
    Size     = @{ Width  = 430
                  Height = 80 }
    MultiLine     = $True
    ShortcutsEnabled = $true
    Font           = New-Object System.Drawing.Font("$Font",11,0,0,0)
    Add_MouseEnter = $RegistryKeyNameSearchRichTextboxAdd_MouseEnter
    Add_MouseLeave = $RegistryKeyNameSearchRichTextboxAdd_MouseLeave
    Add_MouseHover = $RegistryKeyNameSearchRichTextboxAdd_MouseHover    
}
$Section1RegistryTab.Controls.Add($script:RegistryKeyNameSearchRichTextbox)


#--------------------------------
# Registry - Value Name Checkbox
#--------------------------------
. "$Dependencies\Code\System.Windows.Forms\CheckBox\RegistryValueNameCheckbox.ps1"
$RegistryValueNameCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Value Name (Supports RegEx)"
    Location = @{ X = $script:RegistryKeyNameSearchRichTextboxv.Location.X
                  Y = $script:RegistryKeyNameSearchRichTextbox.Location.Y + $script:RegistryKeyNameSearchRichTextbox.Size.Height + 10 }
    Size     = @{ Width  = 300
                  Height = 22 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    Add_Click = $RegistryValueNameCheckboxAdd_Click
}
$Section1RegistryTab.Controls.Add($RegistryValueNameCheckbox)


#-----------------------------------------
# Registry Search - Registry Regex Button
#-----------------------------------------
$SupportsRegexButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Regex Examples"
    Location = @{ X = $RegistryValueNameCheckbox.Location.X + $RegistryValueNameCheckbox.Size.Width + 28
                  Y = $RegistryValueNameCheckbox.Location.Y }
    Size     = @{ Width  = 100
                  Height = 22 }
}
$SupportsRegexButton.Add_Click({ Import-Csv "$Dependencies\RegEx Examples.csv" | Out-GridView }) 
$Section1RegistryTab.Controls.Add($SupportsRegexButton)
CommonButtonSettings -Button $SupportsRegexButton


#------------------------------------------------------
# Registry Search - Registry Value Name Search Textbox
#------------------------------------------------------
. "$Dependencies\Code\System.Windows.Forms\RichTextBox\RegistryValueNameSearchRichTextbox.ps1"
$script:RegistryValueNameSearchRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Text     = "Enter Value Name; One Per Line"
    Location = @{ X = $RegistryValueNameCheckbox.Location.X
                  Y = $RegistryValueNameCheckbox.Location.Y + $RegistryValueNameCheckbox.Size.Height + 10 }
    Size     = @{ Width  = 430
                  Height = 80 }
    MultiLine     = $True
    ShortcutsEnabled = $true
    Font           = New-Object System.Drawing.Font("$Font",11,0,0,0)
    Add_MouseEnter = $RegistryValueNameSearchRichTextboxAdd_MouseEnter
    Add_MouseLeave = $RegistryValueNameSearchRichTextboxAdd_MouseLeave
    Add_MouseHover = $RegistryValueNameSearchRichTextboxAdd_MouseHover    
}
$Section1RegistryTab.Controls.Add($script:RegistryValueNameSearchRichTextbox)


#--------------------------------
# Registry - Value Data Checkbox
#--------------------------------
. "$Dependencies\Code\System.Windows.Forms\CheckBox\RegistryValueDataCheckbox.ps1"
$RegistryValueDataCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Value Data (Supports RegEx)"
    Location = @{ X = $script:RegistryValueNameSearchRichTextbox.Location.X
                  Y = $script:RegistryValueNameSearchRichTextbox.Location.Y + $script:RegistryValueNameSearchRichTextbox.Size.Height + 10 }
    Size     = @{ Width  = 300
                  Height = 22 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    Add_Click = $RegistryValueDataCheckBoxAdd_Click
}
$Section1RegistryTab.Controls.Add($RegistryValueDataCheckbox)


#-----------------------------------------
# Registry Search - Registry Regex Button
#-----------------------------------------
$SupportsRegexButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Regex Examples"
    Location = @{ X = $RegistryValueDataCheckbox.Location.X + $RegistryValueDataCheckbox.Size.Width + 28
                  Y = $RegistryValueDataCheckbox.Location.Y }
    Size     = @{ Width  = 100
                  Height = 22 }
    Add_Click = { Import-Csv "$Dependencies\RegEx Examples.csv" | Out-GridView }
}
$Section1RegistryTab.Controls.Add($SupportsRegexButton)
CommonButtonSettings -Button $SupportsRegexButton


#----------------------------------------------------------
# Registry Search - Registry Value Data Search RichTextbox
#----------------------------------------------------------
. "$Dependencies\Code\System.Windows.Forms\RichTextBox\RegistryValueDataSearchRichTextbox.ps1"
$script:RegistryValueDataSearchRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Text     = "Enter Value Data; One Per Line"
    Location = @{ X = $RegistryValueDataCheckbox.Location.X
                  Y = $RegistryValueDataCheckbox.Location.Y + $RegistryValueDataCheckbox.Size.Height + 10 }
    Size     = @{ Width  = 430
                  Height = 80 }
    MultiLine     = $True
    ShortcutsEnabled = $true
    Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
    Add_MouseEnter = $RegistryValueDataSearchRichTextboxAdd_MouseEnter
    Add_MouseLeave = $RegistryValueDataSearchRichTextboxAdd_MouseLeave
    Add_MouseHover = $RegistryValueDataSearchRichTextboxAdd_MouseHover    
}
$Section1RegistryTab.Controls.Add($script:RegistryValueDataSearchRichTextbox)


#============================================================================================================================================================
#
#  Parent: Main Form -> Main Left TabControl -> Collections TabControl
#   _____  _  _           ____                           _         _____       _      ____                     
#  |  ___|(_)| |  ___    / ___|   ___   __ _  _ __  ___ | |__     |_   _|__ _ | |__  |  _ \  __ _   __ _   ___ 
#  | |_   | || | / _ \   \___ \  / _ \ / _` || '__|/ __|| '_ \      | | / _` || '_ \ | |_) |/ _` | / _` | / _ \
#  |  _|  | || ||  __/    ___) ||  __/| (_| || |  | (__ | | | |     | || (_| || |_) ||  __/| (_| || (_| ||  __/
#  |_|    |_||_| \___|   |____/  \___| \__,_||_|   \___||_| |_|     |_| \__,_||_.__/ |_|    \__,_| \__, | \___|
#                                                                                                  |___/                  
#============================================================================================================================================================

$Section1FileSearchTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text     = "File Search"
    Location = @{ X = 3
                  Y = -10 }
    Size     = @{ Width  = 450
                  Height = 22 }
    Font                    = New-Object System.Drawing.Font("$Font",11,0,0,0)
    UseVisualStyleBackColor = $True
}
$MainLeftCollectionsTabControl.Controls.Add($Section1FileSearchTab)

# Recursively goes through directories down to the specified depth
# Used for backwards compatibility with systems that have older PowerShell versions, newer versions of PowerShell has a -Depth parameter 
. "$Dependencies\Code\Main Body\Get-ChildItemDepth.ps1"


#------------------------------------------
# File Search - Directory Listing CheckBox
#------------------------------------------
$FileSearchDirectoryListingCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Directory Listing (WinRM)"
    Location = @{ X = 3
                  Y = 15 }
    Size     = @{ Width  = 230
                  Height = 22 }
    Font     = New-Object System.Drawing.Font("$Font",12,1,2,1)
    ForeColor = 'Blue'
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
}
$Section1FileSearchTab.Controls.Add($FileSearchDirectoryListingCheckbox)


        #-------------------------------------------------
        # File Search - Directory Listing Max Depth Label
        #-------------------------------------------------
        $FileSearchDirectoryListingMaxDepthLabel = New-Object System.Windows.Forms.Label -Property @{
            Text     = "Recursive Depth"
            Location = @{ X = $FileSearchDirectoryListingCheckbox.Size.Width + 52
                        Y = $FileSearchDirectoryListingCheckbox.Location.Y + 5}
            Size     = @{ Width  = 100
                        Height = 22 }
            Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
            ForeColor  = "Black"
        }
        $Section1FileSearchTab.Controls.Add($FileSearchDirectoryListingMaxDepthLabel)


        #----------------------------------------------------
        # File Search - Directory Listing Max Depth Textbox
        #----------------------------------------------------
        $FileSearchDirectoryListingMaxDepthTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Text     = 0
            Location = @{ X = $FileSearchDirectoryListingMaxDepthLabel.Location.X + $FileSearchDirectoryListingMaxDepthLabel.Size.Width
                        Y = $FileSearchDirectoryListingCheckbox.Location.Y + 2}
            Size     = @{ Width  = 50
                        Height = 20 }
            MultiLine      = $false
            WordWrap       = $false
            Font           = New-Object System.Drawing.Font("$Font",11,0,0,0)
        }
        $Section1FileSearchTab.Controls.Add($FileSearchDirectoryListingMaxDepthTextbox)


        #----------------------------------------------
        # File Search - Directory Listing Label
        #----------------------------------------------
        $FileSearchDirectoryListingLabel = New-Object System.Windows.Forms.Label -Property @{
            Text      = "Collection time is dependant on the directory's contents.`nPoSh v5+ for recursive depth, anything lower will do a full recursive listing."
            Location = @{ X = 3
                        Y = $FileSearchDirectoryListingCheckbox.Location.Y + $FileSearchDirectoryListingCheckbox.Size.Height + 5 }
            Size     = @{ Width  = 450
                        Height = 30 }
            Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
            ForeColor = "Black"
        }
        $Section1FileSearchTab.Controls.Add($FileSearchDirectoryListingLabel)


        #----------------------------------------------------
        # File Search - Directory Listing Directory Textbox
        #----------------------------------------------------
        . "$Dependencies\Code\System.Windows.Forms\TextBox\FileSearchDirectoryListingTextbox.ps1"
        $FileSearchDirectoryListingTextbox = New-Object System.Windows.Forms.TextBox -Property @{
            Location = @{ X = 3
                        Y = $FileSearchDirectoryListingLabel.Locaiton.Y + $FileSearchDirectoryListingLabel.Size.Height + 45 }
            Size     = @{ Width  = 430
                        Height = 22 }
            MultiLine          = $False
            WordWrap           = $false
            Text               = "Enter a single directory"
            AutoCompleteSource = "FileSystem"
            AutoCompleteMode   = "SuggestAppend"
            Font               = New-Object System.Drawing.Font("$Font",11,0,0,0)
            Add_MouseEnter = $FileSearchDirectoryListingTextboxAdd_MouseEnter
            Add_MouseLeave = $FileSearchDirectoryListingTextboxAdd_MouseLeave
            Add_MouseHover = $FileSearchDirectoryListingTextboxAdd_MouseHover    
        }
        $Section1FileSearchTab.Controls.Add($FileSearchDirectoryListingTextbox)


#---------------------------------------------------
# File Search - File Search Command CheckBox
#---------------------------------------------------
$FileSearchFileSearchCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "File Search (WinRM)"
    Location = @{ X = 3
                  Y = $FileSearchDirectoryListingTextbox.Location.Y + $FileSearchDirectoryListingTextbox.Size.Height + 25}
    Size     = @{ Width  = 230
                  Height = 22 }
    Font     = New-Object System.Drawing.Font("$Font",12,1,2,1)
    ForeColor = 'Blue'
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
}
$Section1FileSearchTab.Controls.Add($FileSearchFileSearchCheckbox)


        #--------------------------------------------------
        # File Search - File Search Max Depth Label
        #--------------------------------------------------
        $FileSearchFileSearchMaxDepthLabel = New-Object System.Windows.Forms.Label -Property @{
            Text       = "Recursive Depth"
            Location = @{ X = $FileSearchFileSearchCheckbox.Size.Width + 52
                        Y = $FileSearchFileSearchCheckbox.Location.Y + 5 }
            Size     = @{ Width  = 100
                        Height = 22 }
            Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
            ForeColor  = "Black"
        }
        $Section1FileSearchTab.Controls.Add($FileSearchFileSearchMaxDepthLabel)


        #----------------------------------------------------
        # File Search - File Search Max Depth Textbox
        #----------------------------------------------------
        $FileSearchFileSearchMaxDepthTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Text     = 0
            Location = @{ X = $FileSearchFileSearchMaxDepthLabel.Location.X + $FileSearchFileSearchMaxDepthLabel.Size.Width
                        Y = $FileSearchFileSearchCheckbox.Location.Y + 2}
            Size     = @{ Width  = 50
                        Height = 20 }
            MultiLine = $false
            WordWrap  = $false
            Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        }
        $Section1FileSearchTab.Controls.Add($FileSearchFileSearchMaxDepthTextbox)

        <#
        #----------------------------------------------------
        # File Search - File Search Select FileHash ComboBox
        #----------------------------------------------------
        $FileSearchSelectFileHashCheckbox = New-Object System.Windows.Forms.ComboBox -Property @{
            Text     = "Select FileHashes - Default is None"
            Location = @{ X = 3
                        Y = $FileSearchDownPosition }
            Size     = @{ Width  = 200
                        Height = 22 }
            Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        }
        $HashList = @('None', 'MD5','SHA1','SHA256','SHA512','MD5 + SHA1','MD5 + SHA256','MD5 + SHA512','MD5 + SHA1 + SHA256 + SHA512')
        ForEach ($Hash in $HashList) { $FileSearchSelectFileHashCheckbox.Items.Add($Hash) }
        $Section1FileSearchTab.Controls.Add($FileSearchSelectFileHashCheckbox)

        $FileSearchDownPosition += 25
        #>


        #----------------------------------------
        # File Search - File Search Label
        #----------------------------------------
        $FileSearchFileSearchLabel = New-Object System.Windows.Forms.Label -Property @{
            Text      = "Collection time depends on the number of files and directories, plus recursive depth.`nPoSh v5+ for recursive depth, anything lower will do a full recursive search."
            Location = @{ X = 3
                        Y = $FileSearchFileSearchMaxDepthTextbox.Location.Y + $FileSearchFileSearchMaxDepthTextbox.Size.Height + 2 }
            Size     = @{ Width  = 450
                        Height = 30 }
            Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
            ForeColor = "Black"
        }
        $Section1FileSearchTab.Controls.Add($FileSearchFileSearchLabel)


        #---------------------------------------------
        # File Search - File Search Directory Textbox
        #---------------------------------------------
        . "$Dependencies\Code\System.Windows.Forms\RichTextBox\FileSearchFileSearchDirectoryRichTextbox.ps1"
        $FileSearchFileSearchDirectoryRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Text     = "Enter Directories; One Per Line"
            Location = @{ X = 3
                        Y = $FileSearchFileSearchLabel.Location.Y + $FileSearchFileSearchLabel.Size.Height }
            Size     = @{ Width  = 430
                        Height = 80 }
            MultiLine = $True
            Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
            Add_MouseEnter = $FileSearchFileSearchDirectoryRichTextboxAdd_MouseEnter
            Add_MouseLeave = $FileSearchFileSearchDirectoryRichTextboxAdd_MouseLeave
            Add_MouseHover = $FileSearchFileSearchDirectoryRichTextboxAdd_MouseHover
        }
        $Section1FileSearchTab.Controls.Add($FileSearchFileSearchDirectoryRichTextbox)


        #---------------------------------------------
        # File Search - File Search Files RichTextbox
        #---------------------------------------------
        . "$Dependencies\Code\System.Windows.Forms\RichTextBox\FileSearchFileSearchFileRichTextbox.ps1"
        $FileSearchFileSearchFileRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Location = @{ X = 3
                        Y = $FileSearchFileSearchDirectoryRichTextbox.Location.Y + $FileSearchFileSearchDirectoryRichTextbox.Size.Height + 5}
            Size     = @{ Width  = 430
                        Height = 80 }
            MultiLine     = $True
            ScrollBars    = "Vertical" #Horizontal
            Text          = "Enter FileNames; One Per Line"
            Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
            Add_MouseEnter = $FileSearchFileSearchFileRichTextboxAdd_MouseEnter
            Add_MouseLeave = $FileSearchFileSearchFileRichTextboxAdd_MouseLeave
            Add_MouseHover = $FileSearchFileSearchFileRichTextboxAdd_MouseHover    
        }
        $Section1FileSearchTab.Controls.Add($FileSearchFileSearchFileRichTextbox)


#--------------------------------------------------------
# File Search - File Search AlternateDataStream CheckBox
#--------------------------------------------------------
$FileSearchAlternateDataStreamCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Alternate Data Stream Search (WinRM)"
    Location = @{ X = 3
                  Y = $FileSearchFileSearchFileRichTextbox.Location.Y + $FileSearchFileSearchFileRichTextbox.Size.Height + 20}
    Size     = @{ Width  = 260
                  Height = 22 }
    Font     = New-Object System.Drawing.Font("$Font",12,1,2,1)
    ForeColor = 'Blue'
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
}
$Section1FileSearchTab.Controls.Add($FileSearchAlternateDataStreamCheckbox)


        #-----------------------------------------------------
        # File Search - Alternate Data Stream Max Depth Label
        #-----------------------------------------------------
        $FileSearchAlternateDataStreamMaxDepthLabel = New-Object System.Windows.Forms.Label -Property @{
            Text     = "Recursive Depth"
            Location = @{ X = $FileSearchFileSearchCheckbox.Size.Width + 52
                        Y = $FileSearchAlternateDataStreamCheckbox.Location.Y + 5}
            Size     = @{ Width  = 100
                        Height = 22 }
            Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        }
        $Section1FileSearchTab.Controls.Add($FileSearchAlternateDataStreamMaxDepthLabel)


        #-------------------------------------------------------
        # File Search - Alternate Data Stream Max Depth Textbox
        #-------------------------------------------------------
        $FileSearchAlternateDataStreamMaxDepthTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Text     = 0
            Location = @{ X = $FileSearchAlternateDataStreamMaxDepthLabel.Location.X + $FileSearchAlternateDataStreamMaxDepthLabel.Size.Width
                        Y = $FileSearchAlternateDataStreamCheckbox.Location.Y + 2 }
            Size     = @{ Width  = 50
                        Height = 20 }
            MultiLine = $false
            Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        }
        $Section1FileSearchTab.Controls.Add($FileSearchAlternateDataStreamMaxDepthTextbox)


        #-------------------------------------------
        # File Search - Alternate Data Stream Label
        #-------------------------------------------
        $FileSearchAlternateDataStreamLabel = New-Object System.Windows.Forms.Label -Property @{
            Text     = "Exlcudes':`$DATA' stream, and will show the ADS name and its contents."
            Location = @{ X = 3
                Y = $FileSearchAlternateDataStreamMaxDepthTextbox.Location.Y + $FileSearchAlternateDataStreamMaxDepthTextbox.Size.Height }
            Size     = @{ Width  = 450
                        Height = 22 }
            Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
            ForeColor = "Black"
        }
        $Section1FileSearchTab.Controls.Add($FileSearchAlternateDataStreamLabel)


        #-------------------------------------------------
        # File Search - Alternate Data Stream RichTextbox
        #-------------------------------------------------
        . "$Dependencies\Code\System.Windows.Forms\RichTextBox\FileSearchAlternateDataStreamDirectoryRichTextbox.ps1"
        $FileSearchAlternateDataStreamDirectoryRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Lines          = "Enter Directories; One Per Line"
            Location = @{ X = 3
                        Y = $FileSearchAlternateDataStreamLabel.Location.Y + $FileSearchAlternateDataStreamLabel.Size.Height}
            Size     = @{ Width  = 430
                        Height = 80 }
            Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
            MultiLine     = $True
            Add_MouseEnter = $FileSearchAlternateDataStreamDirectoryRichTextboxAdd_MouseEnter
            Add_MouseLeave = $FileSearchAlternateDataStreamDirectoryRichTextboxAdd_MouseLeave
            Add_MouseHover = $FileSearchAlternateDataStreamDirectoryRichTextboxAdd_MouseHover
        }
        $Section1FileSearchTab.Controls.Add($FileSearchAlternateDataStreamDirectoryRichTextbox)


        #---------------------------------------------------------
        # File Search - Alternate Data Stream Extract Stream Data
        #---------------------------------------------------------
        . "$Dependencies\Code\System.Windows.Forms\Button\FileSearchAlternateDataStreamDirectoryExtractStreamDataButton.ps1"
        $FileSearchAlternateDataStreamDirectoryExtractStreamDataButton = New-Object System.Windows.Forms.Button -Property @{
            Text      = 'Retrieve & Extract Stream Data'
            Location = @{ X = $FileSearchAlternateDataStreamDirectoryRichTextbox.Location.X + $FileSearchAlternateDataStreamDirectoryRichTextbox.Size.Width - 200 - 1
                          Y = $FileSearchAlternateDataStreamDirectoryRichTextbox.Location.Y + $FileSearchAlternateDataStreamDirectoryRichTextbox.Size.Height + 5 }
            Size     = @{ Width  = 200
                          Height = 20 }
            Add_Click = $FileSearchAlternateDataStreamDirectoryExtractStreamDataButtonAdd_Click
        }
        $Section1FileSearchTab.Controls.Add($FileSearchAlternateDataStreamDirectoryExtractStreamDataButton) 
        CommonButtonSettings -Button $FileSearchAlternateDataStreamDirectoryExtractStreamDataButton


#=======================================================================================================================================================================
#
#  Parent: Main Form -> Main Left TabControl -> Collections TabControl
#   _   _        _                          _         ____                                  _    _                        _____       _      ____                     
#  | \ | |  ___ | |_ __      __ ___   _ __ | | __    / ___| ___   _ __   _ __    ___   ___ | |_ (_)  ___   _ __   ___    |_   _|__ _ | |__  |  _ \  __ _   __ _   ___ 
#  |  \| | / _ \| __|\ \ /\ / // _ \ | '__|| |/ /   | |    / _ \ | '_ \ | '_ \  / _ \ / __|| __|| | / _ \ | '_ \ / __|     | | / _` || '_ \ | |_) |/ _` | / _` | / _ \
#  | |\  ||  __/| |_  \ V  V /| (_) || |   |   <    | |___| (_) || | | || | | ||  __/| (__ | |_ | || (_) || | | |\__ \     | || (_| || |_) ||  __/| (_| || (_| ||  __/
#  |_| \_| \___| \__|  \_/\_/  \___/ |_|   |_|\_\    \____|\___/ |_| |_||_| |_| \___| \___| \__||_| \___/ |_| |_||___/     |_| \__,_||_.__/ |_|    \__,_| \__, | \___|
#                                                                                                                                                         |___/       
#=======================================================================================================================================================================

$NetworkConnectionSearchDownPosition = -10

$Section1NetworkConnectionsSearchTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text     = "Network Connections"
    Location = @{ X = 3
                  Y = $NetworkConnectionSearchDownPosition }
    Size     = @{ Width  = 450
                  Height = 22 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    UseVisualStyleBackColor = $True
}
$MainLeftCollectionsTabControl.Controls.Add($Section1NetworkConnectionsSearchTab)


        #---------------------------------------------------------
        # Network Connections Search - Remote IP Address CheckBox
        #---------------------------------------------------------
        $NetworkConnectionSearchRemoteIPAddressCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
            Text     = "Remote IP Address"
            Location = @{ X = 3
                          Y = $Section1NetworkConnectionsSearchTab.Location.Y + $Section1NetworkConnectionsSearchTab.Size.Height + 5 }
            Size     = @{ Width  = 180
                          Height = 22 }
            Font     = New-Object System.Drawing.Font("$Font",12,1,2,1)
            ForeColor = 'Blue'
            Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
        }
        $Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchRemoteIPAddressCheckbox)


        #------------------------------------------------------------------
        # Network Connections Search - Remote IP address Selection Button
        #------------------------------------------------------------------
        . "$Dependencies\Code\System.Windows.Forms\Button\NetworkConnectionSearchRemoteIPAddressSelectionButton.ps1"
        $NetworkConnectionSearchRemoteIPAddressSelectionButton = New-Object System.Windows.Forms.Button -Property @{
            Text      = "Select IP Addresses"
            Location = @{ X = $NetworkConnectionSearchRemoteIPAddressCheckbox.Location.X
                          Y = $NetworkConnectionSearchRemoteIPAddressCheckbox.Location.Y + $NetworkConnectionSearchRemoteIPAddressCheckbox.Size.Height + 3 }
            Size     = @{ Width  = 180
                          Height = 20 }
            Add_Click = $NetworkConnectionSearchRemoteIPAddressSelectionButtonAdd_Click
        }
        $Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchRemoteIPAddressSelectionButton) 
        CommonButtonSettings -Button $NetworkConnectionSearchRemoteIPAddressSelectionButton

        #---------------------------------------------------------
        # Network Connections Search -  Remote IP Address Textbox
        #---------------------------------------------------------
        . "$Dependencies\Code\System.Windows.Forms\RichTextBox\NetworkConnectionSearchRemoteIPAddressRichTextbox.ps1"
        $NetworkConnectionSearchRemoteIPAddressRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Lines     = "Enter Remote IPs; One Per Line"
            Location = @{ X = $NetworkConnectionSearchRemoteIPAddressSelectionButton.Location.X
                          Y = $NetworkConnectionSearchRemoteIPAddressSelectionButton.Location.Y + $NetworkConnectionSearchRemoteIPAddressSelectionButton.Size.Height + 5 }                          
            Size     = @{ Width  = 180
                          Height = 115 }
            Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
            MultiLine  = $True
            ScrollBars = "Vertical"
            WordWrap   = $True
            ShortcutsEnabled = $true
            Add_MouseEnter = $NetworkConnectionSearchRemoteIPAddressRichTextboxAdd_MouseEnter
            Add_MouseLeave = $NetworkConnectionSearchRemoteIPAddressRichTextboxAdd_MouseLeave
            Add_MouseHover = $NetworkConnectionSearchRemoteIPAddressRichTextboxAdd_MouseHover
        }
        $Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchRemoteIPAddressRichTextbox)


#--------------------------------------------------------
# Network Connections Search - Remote Port CheckBox
#--------------------------------------------------------
$NetworkConnectionSearchRemotePortCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Remote Port"
    Location = @{ X = $NetworkConnectionSearchRemoteIPAddressCheckbox.Location.X + $NetworkConnectionSearchRemoteIPAddressCheckbox.Size.Width + 10
                  Y = $NetworkConnectionSearchRemoteIPAddressCheckbox.Location.Y }
    Size     = @{ Width  = 115
                  Height = 22 }
    Font     = New-Object System.Drawing.Font("$Font",12,1,2,1)
    ForeColor = 'Blue'
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
}
$Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchRemotePortCheckbox)


        #------------------------------------------------------------------
        # Network Connections Search - Remote Port - Port Selection Button
        #------------------------------------------------------------------
        . "$Dependencies\Code\System.Windows.Forms\Button\NetworkConnectionSearchRemotePortSelectionButton.ps1"
        $NetworkConnectionSearchRemotePortSelectionButton = New-Object System.Windows.Forms.Button -Property @{
            Text      = "Select Ports"
            Location = @{ X = $NetworkConnectionSearchRemotePortCheckbox.Location.X
                          Y = $NetworkConnectionSearchRemotePortCheckbox.Location.Y + $NetworkConnectionSearchRemotePortCheckbox.Size.Height + 3 }
            Size     = @{ Width  = 115
                          Height = 20 }
            Add_Click = $NetworkConnectionSearchRemotePortSelectionButtonAdd_Click
        }
        $Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchRemotePortSelectionButton) 
        CommonButtonSettings -Button $NetworkConnectionSearchRemotePortSelectionButton         


        #-------------------------------------------------------
        # Network Connections Search -  Remote Port RichTextbox
        #-------------------------------------------------------
        . "$Dependencies\Code\System.Windows.Forms\RichTextBox\NetworkConnectionSearchRemotePortRichTextbox.ps1"
        $NetworkConnectionSearchRemotePortRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Lines     = "Enter Remote Ports; One Per Line"
            Location = @{ X = $NetworkConnectionSearchRemotePortSelectionButton.Location.X
                          Y = $NetworkConnectionSearchRemotePortSelectionButton.Location.Y + $NetworkConnectionSearchRemotePortSelectionButton.Size.Height + 5 }
            Size     = @{ Width  = 115
                          Height = 115 }
            Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
            MultiLine  = $True
            ScrollBars = "Vertical"
            WordWrap   = $True
            ShortcutsEnabled = $true
            Add_MouseEnter = $NetworkConnectionSearchRemotePortRichTextboxAdd_MouseEnter
            Add_MouseLeave = $NetworkConnectionSearchRemotePortRichTextboxAdd_MouseLeave
            Add_MouseHover = $NetworkConnectionSearchRemotePortRichTextboxAdd_MouseHover
        }
        $Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchRemotePortRichTextbox)


#--------------------------------------------------------
# Network Connections Search - Local Port CheckBox
#--------------------------------------------------------
$NetworkConnectionSearchLocalPortCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Local Port"
    Location = @{ X = $NetworkConnectionSearchRemotePortCheckbox.Location.X + $NetworkConnectionSearchRemotePortCheckbox.Size.Width + 10
                  Y = $NetworkConnectionSearchRemotePortCheckbox.Location.Y }
    Size     = @{ Width  = 115
                  Height = 22 }
    Font     = New-Object System.Drawing.Font("$Font",12,1,2,1)
    ForeColor = 'Blue'
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
}
$Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchLocalPortCheckbox)


        #------------------------------------------------------------------
        # Network Connections Search - Local Port - Port Selection Button
        #------------------------------------------------------------------
        . "$Dependencies\Code\System.Windows.Forms\Button\NetworkConnectionSearchLocalPortSelectionButton.ps1"
        $NetworkConnectionSearchLocalPortSelectionButton = New-Object System.Windows.Forms.Button -Property @{
            Text      = "Select Ports"
            Location = @{ X = $NetworkConnectionSearchLocalPortCheckbox.Location.X
                        Y = $NetworkConnectionSearchLocalPortCheckbox.Location.Y + $NetworkConnectionSearchLocalPortCheckbox.Size.Height + 3 }
            Size     = @{ Width  = 115
                        Height = 20 }
            Add_Click = $NetworkConnectionSearchLocalPortSelectionButtonAdd_Click
        }
        $Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchLocalPortSelectionButton) 
        CommonButtonSettings -Button $NetworkConnectionSearchLocalPortSelectionButton


        #-------------------------------------------------------
        # Network Connections Search -  Local Port RichTextbox
        #-------------------------------------------------------
        . "$Dependencies\Code\System.Windows.Forms\RichTextBox\NetworkConnectionSearchLocalPortRichTextbox.ps1"
        $NetworkConnectionSearchLocalPortRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Lines     = "Enter Local Ports; One Per Line"
            Location = @{ X = $NetworkConnectionSearchLocalPortSelectionButton.Location.X
                        Y = $NetworkConnectionSearchLocalPortSelectionButton.Location.Y  + $NetworkConnectionSearchLocalPortSelectionButton.Size.Height + 5 }
            Size     = @{ Width  = 115
                        Height = 115 }
            Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
            MultiLine  = $True
            ScrollBars = "Vertical"
            WordWrap   = $True
            #BorderStyle = 'Fixed3d' #Fixed3D, FixedSingle, none
            ShortcutsEnabled = $true
            Add_MouseEnter = $NetworkConnectionSearchLocalPortRichTextboxAdd_MouseEnter
            Add_MouseLeave = $NetworkConnectionSearchLocalPortRichTextboxAdd_MouseLeave
            Add_MouseHover = $NetworkConnectionSearchLocalPortRichTextboxAdd_MouseHover
        }
        $Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchLocalPortRichTextbox)


#--------------------------------------------------------
# Network Connections Search - Process CheckBox
#--------------------------------------------------------
$NetworkConnectionSearchProcessCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Process Name      (Min: Win10 / Server2016 +)"
    Location = @{ X = 3
                  Y = $NetworkConnectionSearchRemoteIPAddressRichTextbox.Location.Y + $NetworkConnectionSearchRemoteIPAddressRichTextbox.Size.Height + 5 }
    Size     = @{ Width  = 430
                  Height = 22 }
    Font     = New-Object System.Drawing.Font("$Font",12,1,2,1)
    ForeColor = 'Blue'
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
}
$Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchProcessCheckbox)


            #--------------------------------------------
            # Network Connections Search - Process Label
            #--------------------------------------------
            $NetworkConnectionSearchProcessLabel = New-Object System.Windows.Forms.Label -Property @{
                Text     = "Check hosts for connections created by a given process."
                Location = @{ X = 3
                              Y = $NetworkConnectionSearchProcessCheckbox.Location.Y + $NetworkConnectionSearchProcessCheckbox.Size.Height + 5 }
                Size     = @{ Width  = 430
                              Height = 22 }
                ForeColor = "Black"
                Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
            }
            $Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchProcessLabel)


            #-----------------------------------------------
            # Network Connections Search -  Process Textbox
            #-----------------------------------------------
            . "$Dependencies\Code\System.Windows.Forms\RichTextBox\NetworkConnectionSearchProcessRichTextbox.ps1"
            $NetworkConnectionSearchProcessRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
                Lines    = "Enter Process Names; One Per Line"
                Location = @{ X = 3
                              Y = $NetworkConnectionSearchProcessLabel.Location.Y + $NetworkConnectionSearchProcessLabel.Size.Height + 5 }
                Size     = @{ Width  = 430
                              Height = 120 }
                Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
                MultiLine     = $True
                ScrollBars    = "Vertical"
                WordWrap      = $True
                ShortcutsEnabled = $true
                Add_MouseHover   = $NetworkConnectionSearchProcessRichTextboxAdd_MouseHover
                Add_MouseEnter   = $NetworkConnectionSearchProcessRichTextboxAdd_MouseEnter
                Add_MouseLeave   = $NetworkConnectionSearchProcessRichTextboxAdd_MouseLeave
            }
            $Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchProcessRichTextbox)


#-------------------------------------------------
# Network Connections Search - DNS Cache CheckBox
#-------------------------------------------------
$NetworkConnectionSearchDNSCacheCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "DNS Cache Entry"
    Location = @{ X = 3
                  Y = $NetworkConnectionSearchProcessRichTextbox.Location.Y + $NetworkConnectionSearchProcessRichTextbox.Size.Height + 5  }
    Size     = @{ Width  = 430
                  Height = 22 }
    Font     = New-Object System.Drawing.Font("$Font",12,1,2,1)
    ForeColor = 'Blue'
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
}
$Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchDNSCacheCheckbox)


            #----------------------------------------------
            # Network Connections Search - DNS Cache Label
            #----------------------------------------------
            $NetworkConnectionSearchDNSCacheLabel = New-Object System.Windows.Forms.Label -Property @{
                Text     = "Check hosts' DNS Cache for entries that match given criteria."
                Location = @{ X = 3
                              Y = $NetworkConnectionSearchDNSCacheCheckbox.Location.Y + $NetworkConnectionSearchDNSCacheCheckbox.Size.Height + 5 }
                Size     = @{ Width  = 430
                              Height = 22 }
                Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
                ForeColor = "Black"
            }
            $Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchDNSCacheLabel)


            #-------------------------------------------------
            # Network Connections Search -  DNS Cache Textbox
            #-------------------------------------------------
            . "$Dependencies\Code\System.Windows.Forms\RichTextBox\NetworkConnectionSearchDNSCacheRichTextbox.ps1"
            $NetworkConnectionSearchDNSCacheRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
                Lines     = "Enter DNS query information or IP addresses; One Per Line"
                Location = @{ X = 3
                            Y = $NetworkConnectionSearchDNSCacheLabel.Location.Y + $NetworkConnectionSearchDNSCacheLabel.Size.Height + 5 }
                Size     = @{ Width  = 430
                            Height = 100 }
                Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
                MultiLine  = $True
                ScrollBars = "Vertical"
                WordWrap   = $True
                ShortcutsEnabled = $true
                Add_MouseEnter = $NetworkConnectionSearchDNSCacheRichTextboxAdd_MouseEnter
                Add_MouseLeave = $NetworkConnectionSearchDNSCacheRichTextboxAdd_MouseLeave
                Add_MouseHover = $NetworkConnectionSearchDNSCacheRichTextboxAdd_MouseHover
            }
            $Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchDNSCacheRichTextbox)


#=======================================================================================================================================================================
#
#  Parent: Main Form -> Main Left TabControl -> Collections TabControl
#   ____               _         _                             _          _____       _      ____                     
#  / ___|  _   _  ___ (_) _ __  | |_  ___  _ __  _ __    __ _ | | ___    |_   _|__ _ | |__  |  _ \  __ _   __ _   ___ 
#  \___ \ | | | |/ __|| || '_ \ | __|/ _ \| '__|| '_ \  / _` || |/ __|     | | / _` || '_ \ | |_) |/ _` | / _` | / _ \
#   ___) || |_| |\__ \| || | | || |_|  __/| |   | | | || (_| || |\__ \     | || (_| || |_) ||  __/| (_| || (_| ||  __/
#  |____/  \__, ||___/|_||_| |_| \__|\___||_|   |_| |_| \__,_||_||___/     |_| \__,_||_.__/ |_|    \__,_| \__, | \___|
#          |___/                                                                                          |___/       
#=======================================================================================================================================================================

$SysinternalsRightPosition     = 3
$SysinternalsDownPosition      = -10
$SysinternalsDownPositionShift = 22
$SysinternalsButtonWidth       = 110
$SysinternalsButtonHeight      = 22

$Section1SysinternalsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text     = "Sysinternals"
    Location = @{ X = $SysinternalsRightPosition
                  Y = $SysinternalsDownPosition }
    Size     = @{ Width  = 440
                  Height = 22 }
    UseVisualStyleBackColor = $True
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
# Test if the External Programs directory is present; if it's there load the tab
if (Test-Path $ExternalPrograms) { $MainLeftCollectionsTabControl.Controls.Add($Section1SysinternalsTab) }

$SysinternalsDownPosition += $SysinternalsDownPositionShift


#--------------------------------------
# External Programs - Options GroupBox
#--------------------------------------
$ExternalProgramsOptionsGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text      = "Collection Options"
    Location  = @{ X = $SysinternalsRightPosition
                   Y = $SysinternalsDownPosition }
    Size     = @{ Width  = 430
                  Height = 47 }
    Font      = New-Object System.Drawing.Font("$Font",12,1,2,1)
    ForeColor = "Blue"
}

    #-----------------------------------------------
    # External Programs Protocol Radio Button Label
    #-----------------------------------------------
    $ExternalProgramsProtocolRadioButtonLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Protocol:"
        Location = @{ X = 7
                      Y = 22 }
        Size     = @{ Width  = 73
                      Height = 20 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = 'Black'
    }


    #-------------------------------------------------
    # External Programs Protocol WinRM - Radio Button
    #-------------------------------------------------
    . "$Dependencies\Code\System.Windows.Forms\RadioButton\ExternalProgramsWinRMRadioButton.ps1"
    $ExternalProgramsWinRMRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
        Text     = "WinRM"
        Location = @{ X = 80
                      Y = 19 }
        Size     = @{ Width  = 80
                      Height = 22 }
        Checked  = $True
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = 'Black'
        Add_Click      = $ExternalProgramsWinRMRadioButtonAdd_Click
        Add_MouseHover = $ExternalProgramsWinRMRadioButtonAdd_MouseHover
    }


    #-----------------------------------------------
    # External Programs Protocol RPC - Radio Button
    #-----------------------------------------------
    . "$Dependencies\Code\System.Windows.Forms\RadioButton\ExternalProgramsRPCRadioButton.ps1"
    $ExternalProgramsRPCRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
        Text     = "RPC"
        Location = @{ X = $ExternalProgramsWinRMRadioButton.Location.X + $ExternalProgramsWinRMRadioButton.Size.Width + 5
                      Y = $ExternalProgramsWinRMRadioButton.Location.Y }
        Size     = @{ Width  = 60
                      Height = 22 }
        Checked  = $False
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = 'Black'
        Add_Click      = $ExternalProgramsRPCRadioButtonAdd_Click
        Add_MouseHover = $ExternalProgramsRPCRadioButtonAdd_MouseHover
    }


    #-----------------------------------------------
    # External Programs - Maximum Collection Label
    #-----------------------------------------------
    $ExternalProgramsCheckTimeLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Recheck Time (secs):"
        Location = @{ X = $ExternalProgramsRPCRadioButton.Location.X + $ExternalProgramsRPCRadioButton.Size.Width + 30
                      Y = $ExternalProgramsRPCRadioButton.Location.Y + 3 }
        Size     = @{ Width  = 130
                      Height = 22 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = "Black"
    }


        #-------------------------------------------------
        # External Programs - Maximum Collection TextBox
        #-------------------------------------------------
        . "$Dependencies\Code\System.Windows.Forms\TextBox\ExternalProgramsCheckTimeTextBox.ps1"
        $ExternalProgramsCheckTimeTextBox = New-Object System.Windows.Forms.TextBox -Property @{
            Text     = 15
            Location = @{ X = $ExternalProgramsCheckTimeLabel.Location.X + $ExternalProgramsCheckTimeLabel.Size.Width
                          Y = $ExternalProgramsCheckTimeLabel.Location.Y - 3 }
            Size     = @{ Width  = 30
                          Height = 22 }
            Font     = New-Object System.Drawing.Font("$Font",10,0,0,0)
            Enabled  = $True
            Add_MouseHover = $ExternalProgramsCheckTimeTextBoxAdd_MouseHover
        }
   
    $ExternalProgramsOptionsGroupBox.Controls.AddRange(@($ExternalProgramsProtocolRadioButtonLabel,$ExternalProgramsRPCRadioButton,$ExternalProgramsWinRMRadioButton,$ExternalProgramsCheckTimeLabel,$ExternalProgramsCheckTimeTextBox))
$Section1SysinternalsTab.Controls.Add($ExternalProgramsOptionsGroupBox)


#------------------------
# Sysinternals Tab Label
#------------------------
$SysinternalsTabLabel = New-Object System.Windows.Forms.Label -Property @{
    Location = @{ X = $SysinternalsRightPosition
                  Y = $ExternalProgramsOptionsGroupBox.Location.Y + $ExternalProgramsOptionsGroupBox.Size.Height + 10 }
    Size     = @{ Width  = 440
                  Height = 25 }
    Text      = "The following tools following queries drop/remove files to the target host's temp dir.`nPoSh-EasyWin must be ran with elevated credentials for these to function.`nThese queries to target hosts are not threaded."
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Red"
}
$Section1SysinternalsTab.Controls.Add($SysinternalsTabLabel)


#============================================================================================================================================================
# Sysinternals Sysmon
#============================================================================================================================================================

#------------------------------
# Sysinternals Sysmon CheckBox
#------------------------------
. "$Dependencies\Code\System.Windows.Forms\CheckBox\SysinternalsSysmonCheckbox.ps1"
$SysinternalsSysmonCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text      = "Sysmon"
    Location  = @{ X = $ExternalProgramsOptionsGroupBox.Location.X + 5
                   Y = $SysinternalsTabLabel.Location.Y + $SysinternalsTabLabel.Size.Height + 7 }
    AutoSize  = $true
    Font      = New-Object System.Drawing.Font("$Font",12,1,2,1)
    ForeColor = 'Blue'
    Add_Click      = $SysinternalsSysmonCheckBoxAdd_Click
    Add_MouseHover = $SysinternalsSysmonCheckboxAdd_MouseHover
}
$Section1SysinternalsTab.Controls.Add($SysinternalsSysmonCheckbox)


#------------------------------
# Sysinternals Sysmon GroupBox
#------------------------------
$ExternalProgramsSysmonGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Location  = @{ X = $ExternalProgramsOptionsGroupBox.Location.X
                   Y = $SysinternalsTabLabel.Location.Y + $SysinternalsTabLabel.Size.Height + 10 }
    Size      = @{ Width  = $ExternalProgramsOptionsGroupBox.Size.Width 
                   Height = 135 }
    Font      = New-Object System.Drawing.Font("$Font",12,1,2,1)
    ForeColor = "Blue"
}
$Section1SysinternalsTab.Controls.Add($ExternalProgramsSysmonGroupBox)


    #---------------------------
    # Sysinternals Sysmon Label
    #---------------------------
    $SysinternalsSysmonLabel = New-Object System.Windows.Forms.Label -Property @{
        Location = @{ X = 5
                      Y = 20 }
        Size     = @{ Width  = 420
                      Height = 25 }
        Text      = "System Monitor (Sysmon) will be installed on the endpoints. Logs created by sysmon can be viewed via command lilne, Windows Event Viewer, or a SIEM."
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = "Black"
    }
    $ExternalProgramsSysmonGroupBox.Controls.Add($SysinternalsSysmonLabel)

    # Selects the .xml configuration file for sysmon
    . "$Dependencies\Code\Main Body\Get-SysinternalsSysmonXMLConfigSelection.ps1"
    $script:SysmonXMLPath = $null


    #------------------------------------------
    # Sysinternals Sysmon Select Config Button
    #------------------------------------------
    $SysinternalsSysmonSelectConfigButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Select Config"
        Location = @{ X = $SysinternalsSysmonLabel.Location.X
                      Y = $SysinternalsSysmonLabel.Location.Y + $SysinternalsSysmonLabel.Size.Height + 10 }
        Size     = @{ Width  = $SysinternalsButtonWidth
                      Height = $SysinternalsButtonHeight }
        Add_Click = { Get-SysinternalsSysmonXMLConfigSelection }
    }
    $ExternalProgramsSysmonGroupBox.Controls.Add($SysinternalsSysmonSelectConfigButton) 
    CommonButtonSettings -Button $SysinternalsSysmonSelectConfigButton


    #--------------------------------------
    # Sysinternals Sysmon Event IDs Button
    #--------------------------------------
    . "$Dependencies\Code\System.Windows.Forms\Button\SysinternalsSysmonEventIdsButton.ps1"
    $SysinternalsSysmonEventIdsButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Sysmon Event IDs"
        Location = @{ X = $SysinternalsSysmonSelectConfigButton.Location.X
                      Y = $SysinternalsSysmonSelectConfigButton.Location.Y + $SysinternalsSysmonSelectConfigButton.Size.Height + 5 }
        Size     = @{ Width  = $SysinternalsButtonWidth
                      Height = $SysinternalsButtonHeight }
        Add_Click      = $SysinternalsSysmonEventIdsButtonAdd_Click
        Add_MouseHover = $SysinternalsSysmonEventIdsButtonAdd_MouseHover
    }
    $ExternalProgramsSysmonGroupBox.Controls.Add($SysinternalsSysmonEventIdsButton) 
    CommonButtonSettings -Button $SysinternalsSysmonEventIdsButton


    #-----------------------------
    # Sysinternals Sysmon TextBox
    #-----------------------------
    $SysinternalsSysmonConfigTextBox = New-Object System.Windows.Forms.Textbox -Property @{
        Text     = "Config:"
        Location = @{ X = 125
                      Y = $SysinternalsSysmonSelectConfigButton.Location.Y + 1 }
        Size     = @{ Width  = 300
                      Height = 22 }    
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = "Black"
        BackColor = "White"
        Enabled   = $false
    }
    $ExternalProgramsSysmonGroupBox.Controls.Add($SysinternalsSysmonConfigTextBox)


    #------------------------------------------------------
    # Sysinternals Sysmon Rename Process and Service Label
    #------------------------------------------------------
    $SysinternalsSysmonRenameServiceProcessLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Service/Process Name:"
        Location = @{ X = 200
                      Y = $SysinternalsSysmonConfigTextBox.Location.Y + $SysinternalsSysmonConfigTextBox.Size.Height + 8 }
        Size     = @{ Width  = 130
                      Height = 22 }    
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = "Blue"
    }
    $ExternalProgramsSysmonGroupBox.Controls.Add($SysinternalsSysmonRenameServiceProcessLabel)


    #--------------------------------------------------------
    # Sysinternals Sysmon Rename Process and Service TextBox
    #--------------------------------------------------------
    . "$Dependencies\Code\System.Windows.Forms\Textbox\SysinternalsSysmonRenameServiceProcessTextBox.ps1"
    $SysinternalsSysmonRenameServiceProcessTextBox = New-Object System.Windows.Forms.Textbox -Property @{
        Text     = "Sysmon"
        Location = @{ X = $SysinternalsSysmonRenameServiceProcessLabel.Location.X + $SysinternalsSysmonRenameServiceProcessLabel.Size.Width + 10
                      Y = $SysinternalsSysmonRenameServiceProcessLabel.Location.Y - 3}
        Size     = @{ Width  = 85
                      Height = 22 }    
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        Add_MouseHover = $SysinternalsSysmonRenameServiceProcessTextBoxAdd_MouseHover
    }
    $ExternalProgramsSysmonGroupBox.Controls.Add($SysinternalsSysmonRenameServiceProcessTextBox)


    #-----------------------------------------
    # Sysinternals Sysmon Rename Driver Label
    #-----------------------------------------
    $SysinternalsSysmonRenameDriverLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Driver Name:"
        Location = @{ X = $SysinternalsSysmonRenameServiceProcessLabel.Location.X
                      Y = $SysinternalsSysmonRenameServiceProcessLabel.Location.Y + $SysinternalsSysmonRenameServiceProcessLabel.Size.Height }
        Size     = @{ Width  = $SysinternalsSysmonRenameServiceProcessLabel.Size.Width
                      Height = 22 }    
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = "Blue"
    }
    $ExternalProgramsSysmonGroupBox.Controls.Add($SysinternalsSysmonRenameDriverLabel)


    #-------------------------------------------
    # Sysinternals Sysmon Rename Driver TextBox
    #-------------------------------------------
    . "$Dependencies\Code\System.Windows.Forms\Textbox\SysinternalsSysmonRenameDriverTextBox.ps1"
    $SysinternalsSysmonRenameDriverTextBox = New-Object System.Windows.Forms.Textbox -Property @{
        Text     = "SysmonDrv"
        Location = @{ X = $SysinternalsSysmonRenameServiceProcessTextBox.Location.X 
                      Y = $SysinternalsSysmonRenameDriverLabel.Location.Y - 3}
        Size     = @{ Width  = $SysinternalsSysmonRenameServiceProcessTextBox.Size.Width
                      Height = 22 }
        MaxLength = 8
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        Add_MouseHover = $SysinternalsSysmonRenameDriverTextBoxAdd_MouseHover
    }
    $ExternalProgramsSysmonGroupBox.Controls.Add($SysinternalsSysmonRenameDriverTextBox)
  

#============================================================================================================================================================
# Sysinternals Autoruns
#============================================================================================================================================================

#--------------------------------
# Sysinternals Autoruns CheckBox
#--------------------------------
. "$Dependencies\Code\System.Windows.Forms\CheckBox\SysinternalsAutorunsCheckbox.ps1"
$SysinternalsAutorunsCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text      = "Autoruns"
    Location  = @{ X = $ExternalProgramsOptionsGroupBox.Location.X + 5
                   Y = $ExternalProgramsSysmonGroupBox.Location.Y + $ExternalProgramsSysmonGroupBox.Size.Height + 7 }
    AutoSize  = $true
    Font      = New-Object System.Drawing.Font("$Font",12,1,2,1)
    ForeColor = "Blue"
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
    Add_MouseHover = $SysinternalsAutorunsCheckboxAdd_MouseHover
}
$Section1SysinternalsTab.Controls.Add($SysinternalsAutorunsCheckbox)


#--------------------------------
# Sysinternals Autoruns GroupBox
#--------------------------------
$ExternalProgramsAutorunsGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Location  = @{ X = $ExternalProgramsSysmonGroupBox.Location.X
                   Y = $ExternalProgramsSysmonGroupBox.Location.Y + $ExternalProgramsSysmonGroupBox.Size.Height + 10 }
    Size      = @{ Width  = $ExternalProgramsOptionsGroupBox.Size.Width 
                   Height = 79 }
    Font      = New-Object System.Drawing.Font("$Font",12,1,2,1)
}
$Section1SysinternalsTab.Controls.Add($ExternalProgramsAutorunsGroupBox)

    #-----------------------------
    # Sysinternals Autoruns Label
    #-----------------------------
    $SysinternalsAutorunsLabel = New-Object System.Windows.Forms.Label -Property @{
        Location = @{ X = 5
                      Y = 20 }
        Size     = @{ Width  = $SysinternalsSysmonLabel.Size.Width
                      Height = 25 }
        Text      = "Obtains More Startup Information than Native WMI and other Windows Commands, like various built-in Windows Applications."
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = "Black"
    }
    $ExternalProgramsAutorunsGroupBox.Controls.Add($SysinternalsAutorunsLabel)

    $SysinternalsDownPosition += $SysinternalsDownPositionShift


    #------------------------------
    # Sysinternals Autoruns Button
    #------------------------------
    . "$Dependencies\Code\System.Windows.Forms\Button\SysinternalsAutorunsButton.ps1"
    $SysinternalsAutorunsButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Open Autoruns"
        Location = @{ X = $SysinternalsAutorunsLabel.Location.X
                      Y = $SysinternalsAutorunsLabel.Location.Y + $SysinternalsAutorunsLabel.Size.Height + 5 }
        Size     = @{ Width  = $SysinternalsButtonWidth
                      Height = $SysinternalsButtonHeight }
        Add_Click = $SysinternalsAutorunsButtonAdd_Click
    }
    $ExternalProgramsAutorunsGroupBox.Controls.Add($SysinternalsAutorunsButton) 
    CommonButtonSettings -Button $SysinternalsAutorunsButton


    #--------------------------------------------------------
    # Sysinternals Autoruns Rename Process and Service Label
    #--------------------------------------------------------
    $SysinternalsAutorunsRenameProcessLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Process Name:"
        Location = @{ X = $SysinternalsSysmonRenameServiceProcessLabel.Location.X
                      Y = $SysinternalsAutorunsButton.Location.Y }
        Size     = @{ Width  = $SysinternalsSysmonRenameServiceProcessLabel.Size.Width
                      Height = 22 }    
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = "Blue"
    }
    $ExternalProgramsAutorunsGroupBox.Controls.Add($SysinternalsAutorunsRenameProcessLabel)


    #----------------------------------------------------------
    # Sysinternals Autoruns Rename Process and Service TextBox
    #----------------------------------------------------------
    . "$Dependencies\Code\System.Windows.Forms\Textbox\SysinternalsAutorunsRenameProcessTextBox.ps1"
    $SysinternalsAutorunsRenameProcessTextBox = New-Object System.Windows.Forms.Textbox -Property @{
        Text     = "Autoruns"
        Location = @{ X = $SysinternalsSysmonRenameServiceProcessTextBox.Location.X
                      Y = $SysinternalsAutorunsRenameProcessLabel.Location.Y - 3}
        Size     = @{ Width  = $SysinternalsSysmonRenameServiceProcessTextBox.Size.Width
                      Height = 22 }    
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        Add_MouseHover = $SysinternalsAutorunsRenameProcessTextBoxAdd_MouseHover
    }
    $ExternalProgramsAutorunsGroupBox.Controls.Add($SysinternalsAutorunsRenameProcessTextBox)


#============================================================================================================================================================
# Sysinternals Process Monitor
#============================================================================================================================================================

#--------------------------------
# Sysinternals Procmon CheckBox
#--------------------------------
. "$Dependencies\Code\System.Windows.Forms\CheckBox\SysinternalsProcessMonitorCheckbox.ps1"
$SysinternalsProcessMonitorCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Procmon"
    Location = @{ X = $ExternalProgramsAutorunsGroupBox.Location.X + 5
                  Y = $ExternalProgramsAutorunsGroupBox.Location.Y + $ExternalProgramsAutorunsGroupBox.Size.Height + 7 }
    AutoSize  = $true
    Font      = New-Object System.Drawing.Font("$Font",12,1,2,1)
    ForeColor = "Blue"
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
    Add_MouseHover = $SysinternalsProcessMonitorCheckboxAdd_MouseHover
}
$Section1SysinternalsTab.Controls.Add($SysinternalsProcessMonitorCheckbox)


#--------------------------------
# Sysinternals Autoruns GroupBox
#--------------------------------
$ExternalProgramsProcmonGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Location  = @{ X = $ExternalProgramsAutorunsGroupBox.Location.X
                   Y = $ExternalProgramsAutorunsGroupBox.Location.Y + $ExternalProgramsAutorunsGroupBox.Size.Height + 10 }
    Size      = @{ Width  = $ExternalProgramsOptionsGroupBox.Size.Width 
                   Height = 105 }
    Font      = New-Object System.Drawing.Font("$Font",12,1,2,1)
    ForeColor = "Blue"
}
$Section1SysinternalsTab.Controls.Add($ExternalProgramsProcmonGroupBox)


    #------------------------------------
    # Sysinternals ProcMon Monitor Label
    #------------------------------------
    $SysinternalsProcessMonitorLabel = New-Object System.Windows.Forms.Label -Property @{
        Location = @{ X = 5
                      Y = 20 }
        Size     = @{ Width  = $SysinternalsSysmonLabel.Size.Width
                      Height = 25 }
        Text      = "Obtains process data over a timespan and can easily return data in 100's of MBs. Checks are done to see if 500MB is available on the localhost and endpoints."
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = "Black"
    }
    $ExternalProgramsProcmonGroupBox.Controls.Add($SysinternalsProcessMonitorLabel)

    $SysinternalsDownPosition += $SysinternalsDownPositionShift


    #-----------------------------
    # Sysinternals ProcMon Button
    #-----------------------------
    . "$Dependencies\Code\System.Windows.Forms\Button\SysinternalsProcmonButton.ps1"
    $SysinternalsProcmonButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Open Procmon"
        Location = @{ X = $SysinternalsProcessMonitorLabel.Location.X
                      Y = $SysinternalsProcessMonitorLabel.Location.Y + $SysinternalsProcessMonitorLabel.Size.Height + 5 }
        Size     = @{ Width  = $SysinternalsButtonWidth
                      Height = $SysinternalsButtonHeight }
        Add_Click = $SysinternalsProcmonButtonAdd_Click
    }
    $ExternalProgramsProcmonGroupBox.Controls.Add($SysinternalsProcmonButton) 
    CommonButtonSettings -Button $SysinternalsProcmonButton


    #-------------------------------------------
    # Sysinternals Procmon - Capture Time Label
    #-------------------------------------------
    $SysinternalsProcmonCaptureTimeLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Capture Time:"
        Location = @{ X = $SysinternalsSysmonRenameServiceProcessLabel.Location.X
                      Y = $SysinternalsProcmonButton.Location.Y }
        Size     = @{ Width  = $SysinternalsSysmonRenameServiceProcessLabel.Size.Width
                    Height = 22 }    
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = "Blue"
    }
    $ExternalProgramsProcmonGroupBox.Controls.Add($SysinternalsProcmonCaptureTimeLabel)

    #----------------------------------------------
    # Sysinternals Procmon - Capture Time ComboBox
    #----------------------------------------------
    $script:SysinternalsProcessMonitorTimeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Text     = "5 Seconds"
        Location = @{ X = $SysinternalsSysmonRenameServiceProcessTextBox.Location.X
                      Y = $SysinternalsProcmonCaptureTimeLabel.Location.Y }
        Size     = @{ Width  = $SysinternalsSysmonRenameServiceProcessTextBox.Size.Width
                      Height = 22 } 
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $ProcmonCaptureTimes = @('5 Seconds','10 Seconds','15 Seconds','30 Seconds','1 Minute','2 Minutes','3 Minutes','4 Minutes','5 Minutes')
        ForEach ($time in $ProcmonCaptureTimes) { $script:SysinternalsProcessMonitorTimeComboBox.Items.Add($time) }
    $ExternalProgramsProcmonGroupBox.Controls.Add($script:SysinternalsProcessMonitorTimeComboBox)


    #-------------------------------------------------------
    # Sysinternals Procmon Rename Process and Service Label
    #-------------------------------------------------------
    $SysinternalsProcmonRenameProcessLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Process Name:"
        Location = @{ X = $SysinternalsSysmonRenameServiceProcessLabel.Location.X
                      Y = $SysinternalsProcmonCaptureTimeLabel.Location.Y + $SysinternalsProcmonCaptureTimeLabel.Size.Height + 5 }
        Size     = @{ Width  = $SysinternalsSysmonRenameServiceProcessLabel.Size.Width
                      Height = 22 }    
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = "Blue"
    }
    $ExternalProgramsProcmonGroupBox.Controls.Add($SysinternalsProcmonRenameProcessLabel)


    #---------------------------------------------------------
    # Sysinternals Procmon Rename Process and Service TextBox
    #---------------------------------------------------------
    . "$Dependencies\Code\System.Windows.Forms\Textbox\SysinternalsProcmonRenameProcessTextBox.ps1"
    $SysinternalsProcmonRenameProcessTextBox = New-Object System.Windows.Forms.Textbox -Property @{
        Text     = "Procmon"
        Location = @{ X = $SysinternalsSysmonRenameServiceProcessTextBox.Location.X
                      Y = $SysinternalsProcmonRenameProcessLabel.Location.Y - 3}
        Size     = @{ Width  = $SysinternalsSysmonRenameServiceProcessTextBox.Size.Width
                      Height = 22 }    
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        Add_MouseHover = $SysinternalsProcmonRenameProcessTextBoxAdd_MouseHover
    }
    $ExternalProgramsProcmonGroupBox.Controls.Add($SysinternalsProcmonRenameProcessTextBox)


#=======================================================================================================================================================================
#
#  Parent: Main Form -> Main Left TabControl
#   _____                                             _    _                   _____       _      ____                     
#  | ____| _ __   _   _  _ __ ___    ___  _ __  __ _ | |_ (_)  ___   _ __     |_   _|__ _ | |__  |  _ \  __ _   __ _   ___ 
#  |  _|  | '_ \ | | | || '_ ` _ \  / _ \| '__|/ _` || __|| | / _ \ | '_ \      | | / _` || '_ \ | |_) |/ _` | / _` | / _ \
#  | |___ | | | || |_| || | | | | ||  __/| |  | (_| || |_ | || (_) || | | |     | || (_| || |_) ||  __/| (_| || (_| ||  __/
#  |_____||_| |_| \__,_||_| |_| |_| \___||_|   \__,_| \__||_| \___/ |_| |_|     |_| \__,_||_.__/ |_|    \__,_| \__, | \___|
#                                                                                                              |___/       
#=======================================================================================================================================================================

$EnumerationRightPosition     = 3
$EnumerationDownPosition      = 0
$EnumerationDownPositionShift = 25
$EnumerationLabelWidth        = 450
$EnumerationLabelHeight       = 25
$EnumerationButtonWidth       = 110
$EnumerationButtonHeight      = 22
$EnumerationGroupGap          = 15


$Section1EnumerationTab = New-Object System.Windows.Forms.TabPage -Property @{
    Name     = "Enumeration"
    Text     = "Enumeration"
    Location = @{ X = $EnumerationRightPosition
                  Y = $EnumerationDownPosition }
    Size     = @{ Width  = $EnumerationLabelWidth
                  Height = $EnumerationLabelHeight }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    UseVisualStyleBackColor = $True
}
$MainLeftTabControl.Controls.Add($Section1EnumerationTab)

$EnumerationDownPosition += 13


# Enumeration - Domain Generated Input Check
. "$Dependencies\Code\Execution\Enumeration\InputCheck-EnumerationByDomainImport.ps1"


#------------------------------------
# Enumeration - Port Scan - GroupBox
#------------------------------------
$EnumerationDomainGenerateGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Location  = New-Object System.Drawing.Point(0,$EnumerationDownPosition)
    size      = New-Object System.Drawing.Size(294,100)
    text      = "Import Hosts From Domain"
    Font      = New-Object System.Drawing.Font("$Font",12,1,2,1)
    ForeColor = "Blue"
}

$EnumerationDomainGenerateDownPosition      = 18
$EnumerationDomainGenerateDownPositionShift = 25


    #----------------------------------------
    # Enumeration - Domain Generated - Label
    #----------------------------------------
    $EnumerationDomainGeneratedLabelNote = New-Object System.Windows.Forms.Label -Property @{
        Location  = New-Object System.Drawing.Point($EnumerationRightPosition,($EnumerationDomainGenerateDownPosition + 3)) 
        Size      = New-Object System.Drawing.Size(220,22)
        Text      = "This host must be domained for this feature."    
        Font      = New-Object System.Drawing.Font("$Font",10,0,0,0)
        ForeColor = "Black"
    }
    $EnumerationDomainGenerateGroupBox.Controls.Add($EnumerationDomainGeneratedLabelNote)  


    #-----------------------------------------------------
    # Enumeration - Domain Generated - Auto Pull Checkbox
    #-----------------------------------------------------
    . "$Dependencies\Code\System.Windows.Forms\Checkbox\EnumerationDomainGeneratedAutoCheckBox.ps1"
    $EnumerationDomainGeneratedAutoCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
        Text      = "Auto Pull"
        Location  = New-Object System.Drawing.Point(($EnumerationDomainGeneratedLabelNote.Size.Width + 3),($EnumerationDomainGenerateDownPosition - 1))
        Size      = New-Object System.Drawing.Size(100,$EnumerationLabelHeight)
        Font      = New-Object System.Drawing.Font("$Font",10,0,0,0)
        ForeColor = "Black"
        Add_Click = $EnumerationDomainGeneratedAutoCheckBoxAdd_Click
    }
    $EnumerationDomainGenerateGroupBox.Controls.Add($EnumerationDomainGeneratedAutoCheckBox)

    $EnumerationDomainGenerateDownPosition += $EnumerationDomainGenerateDownPositionShift


    #------------------------------------------------
    # Enumeration - Domain Generated - Input Textbox
    #------------------------------------------------
    $EnumerationDomainGeneratedTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Text      = "<Domain Name>"
        Location  = New-Object System.Drawing.Point($EnumerationRightPosition,$EnumerationDomainGenerateDownPosition)
        Size      = New-Object System.Drawing.Size(286,$EnumerationLabelHeight)
        Font      = New-Object System.Drawing.Font("$Font",10,0,0,0)
        ForeColor = "Black"
        Add_KeyDown = { if ($_.KeyCode -eq "Enter") { InputCheck-EnumerationByDomainImport } }
    }
    $EnumerationDomainGenerateGroupBox.Controls.Add($EnumerationDomainGeneratedTextBox)

    $EnumerationDomainGenerateDownPosition += $EnumerationDomainGenerateDownPositionShift


    #----------------------------------------------------------
    # Enumeration - Domain Generated - Import Hosts/IPs Button
    #----------------------------------------------------------
    $EnumerationDomainGeneratedListButton = New-Object System.Windows.Forms.Button -Property @{
        Text      = "Import Hosts"
        Location  = New-Object System.Drawing.Point(190,($EnumerationDomainGenerateDownPosition - 1))
        Size      = New-Object System.Drawing.Size(100,22)
        Add_Click = { InputCheck-EnumerationByDomainImport }
    }
    $EnumerationDomainGenerateGroupBox.Controls.Add($EnumerationDomainGeneratedListButton) 
    CommonButtonSettings -Button $EnumerationDomainGeneratedListButton

$Section1EnumerationTab.Controls.Add($EnumerationDomainGenerateGroupBox)


#============================================================================================================================================================
# Enumeration - Port Scanning
#============================================================================================================================================================
if (!(Test-Path $CustomPortsToScan)) {
    #Don't modify / indent the numbers below... to ensure the file created is formated correctly
    Write-Output "21`r`n22`r`n23`r`n53`r`n80`r`n88`r`n110`r`n123`r`n135`r`n143`r`n161`r`n389`r`n443`r`n445`r`n3389" | Out-File -FilePath $CustomPortsToScan -Force
}

# Using the inputs selected or provided from the GUI, it scans the specified IPs or network range for specified ports
# The intent of this scan is not to be stealth, but rather find hosts; such as those not in active directory
# The results can be added to the computer treenodes 
. "$Dependencies\Code\Execution\Enumeration\Conduct-PortScan.ps1"


#------------------------------------
# Enumeration - Port Scan - GroupBox
#------------------------------------
$EnumerationPortScanGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text      = "Create List From TCP Port Scan"
    Location = @{ X = 0
                  Y = $EnumerationDomainGenerateGroupBox.Location.Y + $EnumerationDomainGenerateGroupBox.Size.Height + $EnumerationGroupGap }
    Size     = @{ Width  = 294
                  Height = 270 }
    Font      = New-Object System.Drawing.Font("$Font",12,1,2,1)
    ForeColor = "Blue"
}
$EnumerationPortScanGroupDownPosition      = 18
$EnumerationPortScanGroupDownPositionShift = 25
    

    #----------------------------------------
    # Enumeration - Port Scan - Specific IPs
    #----------------------------------------
    $EnumerationPortScanIPNote1Label = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Enter Comma Separated IPs"
        Location   = New-Object System.Drawing.Point($EnumerationRightPosition,($EnumerationPortScanGroupDownPosition + 3))
        Size       = New-Object System.Drawing.Size(170,22) 
        Font       = New-Object System.Drawing.Font("$Font",10,0,0,0)
        ForeColor  = "Black"
    }
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPNote1Label)


    #-----------------------------------------
    # Enumeration - Port Scan - IP Note Label
    #-----------------------------------------
    $EnumerationPortScanIPNote2Label = New-Object System.Windows.Forms.Label -Property @{
        Text       = "(ex: 10.0.0.1,10.0.0.2)"
        Location   = New-Object System.Drawing.Point(($EnumerationPortScanIPNote1Label.Size.Width + 3),($EnumerationPortScanGroupDownPosition + 4)) 
        Size       = New-Object System.Drawing.Size(110,20) 
        Font       = New-Object System.Drawing.Font("$Font",10,0,0,0)
        ForeColor  = "Black"
    }
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPNote2Label)
    $EnumerationPortScanGroupDownPosition += $EnumerationPortScanGroupDownPositionShift

    
    #--------------------------------------------------------------
    # Enumeration - Port Scan - Enter Specific Comma Separated IPs
    #--------------------------------------------------------------
    $EnumerationPortScanSpecificIPTextbox = New-Object System.Windows.Forms.TextBox -Property @{
        Text          = ""
        Location      = New-Object System.Drawing.Point($EnumerationRightPosition,$EnumerationPortScanGroupDownPosition) 
        Size          = New-Object System.Drawing.Size(287,22)
        MultiLine     = $False
        WordWrap      = $True
        AcceptsTab    = $false
        AcceptsReturn = $false
        Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor     = "Black"
    }
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanSpecificIPTextbox)

    $EnumerationPortScanGroupDownPosition += $EnumerationPortScanGroupDownPositionShift

    
    #------------------------------------
    # Enumeration - Port Scan - IP Range
    #------------------------------------
    $EnumerationPortScanIPRangeNote1Label = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Network Range:"
        Location   = New-Object System.Drawing.Point($EnumerationRightPosition,($EnumerationPortScanGroupDownPosition + 3)) 
        Size       = New-Object System.Drawing.Size(140,22) 
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor  = "Black"
    }
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPRangeNote1Label)


    #-----------------------------------------------
    # Enumeration - Port Scan - IP Range Note Label
    #-----------------------------------------------
    $EnumerationPortScanIPRangeNote2Label = New-Object System.Windows.Forms.Label -Property @{
        Text       = "(ex: [ 192.168.1 ]  [ 1 ]  [ 100 ])"
        Location   = New-Object System.Drawing.Point(($EnumerationPortScanIPRangeNote1Label.Size.Width),($EnumerationPortScanGroupDownPosition + 4)) 
        Size       = New-Object System.Drawing.Size(150,20) 
        Font       = New-Object System.Drawing.Font("$Font",10,0,0,0)
        ForeColor  = "Black"
    }
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPRangeNote2Label)

    $EnumerationPortScanGroupDownPosition += $EnumerationPortScanGroupDownPositionShift
    $RightShift = $EnumerationRightPosition


    #--------------------------------------------------
    # Enumeration - Port Scan - IP Range Network Label
    #--------------------------------------------------
    $EnumerationPortScanIPRangeNetworkLabel = New-Object System.Windows.Forms.Label -Property @{
        Text      = "Network"
        Location  = New-Object System.Drawing.Point($RightShift,($EnumerationPortScanGroupDownPosition + 3)) 
        Size      = New-Object System.Drawing.Size(50,22) 
        Font      = New-Object System.Drawing.Font("$Font",10,0,0,0)
        ForeColor = "Black"
    }
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPRangeNetworkLabel)

    $RightShift += $EnumerationPortScanIPRangeNetworkLabel.Size.Width


    #----------------------------------------------------
    # Enumeration - Port Scan - IP Range Network TextBox
    #----------------------------------------------------
    $EnumerationPortScanIPRangeNetworkTextbox = New-Object System.Windows.Forms.TextBox -Property @{
        Text          = ""
        Location      = New-Object System.Drawing.Point($RightShift,$EnumerationPortScanGroupDownPosition) 
        Size          = New-Object System.Drawing.Size(77,22)
        MultiLine     = $False
        WordWrap      = $True
        AcceptsTab    = $false
        AcceptsReturn = $false
        Font          = New-Object System.Drawing.Font("$Font",10,0,0,0)
        ForeColor     = "Black"
    }
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPRangeNetworkTextbox)

    $RightShift += $EnumerationPortScanIPRangeNetworkTextbox.Size.Width


    #------------------------------------------------
    # Enumeration - Port Scan - IP Range First Label
    #------------------------------------------------
    $EnumerationPortScanIPRangeFirstLabel = New-Object System.Windows.Forms.Label -Property @{
        Text      = "First IP"
        Location  = New-Object System.Drawing.Point($RightShift,($EnumerationPortScanGroupDownPosition + 3)) 
        Size      = New-Object System.Drawing.Size(40,22) 
        Font      = New-Object System.Drawing.Font("$Font",10,0,0,0)
        ForeColor = "Black"
    }
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPRangeFirstLabel)

    $RightShift += $EnumerationPortScanIPRangeFirstLabel.Size.Width


    #--------------------------------------------------
    # Enumeration - Port Scan - IP Range First TextBox
    #--------------------------------------------------
    $EnumerationPortScanIPRangeFirstTextbox = New-Object System.Windows.Forms.TextBox -Property @{
        Text          = ""
        Location      = New-Object System.Drawing.Point($RightShift,$EnumerationPortScanGroupDownPosition) 
        Size          = New-Object System.Drawing.Size(40,22)
        MultiLine     = $False
        WordWrap      = $True
        AcceptsTab    = $false
        AcceptsReturn = $false
        Font          = New-Object System.Drawing.Font("$Font",10,0,0,0)
        ForeColor     = "Black"
    }
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPRangeFirstTextbox)

    $RightShift += $EnumerationPortScanIPRangeFirstTextbox.Size.Width

    
    #-----------------------------------------------
    # Enumeration - Port Scan - IP Range Last Label
    #-----------------------------------------------
    $EnumerationPortScanIPRangeLastLabel = New-Object System.Windows.Forms.Label -Property @{
        Text      = "Last IP"
        Location  = New-Object System.Drawing.Point($RightShift,($EnumerationPortScanGroupDownPosition + 3)) 
        Size      = New-Object System.Drawing.Size(40,22) 
        Font      = New-Object System.Drawing.Font("$Font",10,0,0,0)
        ForeColor = "Black"
    }
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPRangeLastLabel)

    $RightShift += $EnumerationPortScanIPRangeLastLabel.Size.Width
    

    #-------------------------------------------------
    # Enumeration - Port Scan - IP Range Last TextBox
    #-------------------------------------------------
    $EnumerationPortScanIPRangeLastTextbox = New-Object System.Windows.Forms.TextBox -Property @{
        Text          = ""
        Location      = New-Object System.Drawing.Size($RightShift,$EnumerationPortScanGroupDownPosition) 
        Size          = New-Object System.Drawing.Size(40,22)
        MultiLine     = $False
        WordWrap      = $True
        AcceptsTab    = $false
        AcceptsReturn = $false
        Font          = New-Object System.Drawing.Font("$Font",10,0,0,0)
        ForeColor     = "Black"
    }
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPRangeLastTextbox)

    $EnumerationPortScanGroupDownPosition += $EnumerationPortScanGroupDownPositionShift


    #---------------------------------------
    # Enumeration - Port Scan - Note1 Label
    #---------------------------------------
    $EnumerationPortScanPortNote1Label = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Comma Separated Ports"
        Location   = New-Object System.Drawing.Point($EnumerationRightPosition,($EnumerationPortScanGroupDownPosition + 3)) 
        Size       = New-Object System.Drawing.Size(170,22) 
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor  = "Black"
    }
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortNote1Label)


    #---------------------------------------
    # Enumeration - Port Scan - Note2 Label
    #---------------------------------------
    $EnumerationPortScanPortNote2Label = New-Object System.Windows.Forms.Label -Property @{
        Location  = New-Object System.Drawing.Point(($EnumerationPortScanPortNote1Label.Size.Width + 3),($EnumerationPortScanGroupDownPosition + 4)) 
        Size      = New-Object System.Drawing.Size(110,20)
        Text      = "(ex: 22,80,135,445)"
        Font      = New-Object System.Drawing.Font("$Font",10,0,0,0)
        ForeColor = "Black"
    }
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortNote2Label)

    $EnumerationPortScanGroupDownPosition += $EnumerationPortScanGroupDownPositionShift


    #--------------------------------------------------
    # Enumeration - Port Scan - Specific Ports TextBox
    #--------------------------------------------------
    $EnumerationPortScanSpecificPortsTextbox = New-Object System.Windows.Forms.TextBox -Property @{
        Text          = ""
        Location      = New-Object System.Drawing.Point($EnumerationRightPosition,$EnumerationPortScanGroupDownPosition) 
        Size          = New-Object System.Drawing.Size(288,22)
        MultiLine     = $False
        WordWrap      = $True
        AcceptsTab    = $false
        AcceptsReturn = $false
        Font          = New-Object System.Drawing.Font("$Font",10,0,0,0)
        ForeColor     = "Black"
    }
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanSpecificPortsTextbox)

    $EnumerationPortScanGroupDownPosition += $EnumerationPortScanGroupDownPositionShift


    #-----------------------------------------------------
    # Enumeration - Port Scan - Ports Quick Pick ComboBox
    #-----------------------------------------------------
    . "$Dependencies\Code\System.Windows.Forms\ComboBox\EnumerationPortScanPortQuickPickComboBox.ps1"
    $EnumerationPortScanPortQuickPickComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Text          = "Quick-Pick Port Selection"
        Location      = New-Object System.Drawing.Point($EnumerationRightPosition,$EnumerationPortScanGroupDownPosition) 
        Size          = New-Object System.Drawing.Size(183,20)
        Font          = New-Object System.Drawing.Font("$Font",10,0,0,0)
        ForeColor     = "Black"
        Add_Click = $EnumerationPortScanPortQuickPickComboBoxAdd_Click
    }
    $EnumerationPortScanPortQuickPickComboBox.Items.AddRange($EnumerationPortScanPortQuickPickComboBoxItemsAddRange)
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortQuickPickComboBox)


    #-------------------------------------------------
    # Enumeration - Port Scan - Port Selection Button
    #-------------------------------------------------
    . "$Dependencies\Code\System.Windows.Forms\Button\EnumerationPortScanPortsSelectionButton.ps1"
    $EnumerationPortScanPortsSelectionButton = New-Object System.Windows.Forms.Button -Property @{
        Text      = "Select Ports"
        Location  = New-Object System.Drawing.Point(($EnumerationPortScanPortQuickPickComboBox.Size.Width + 8),$EnumerationPortScanGroupDownPosition) 
        Size      = New-Object System.Drawing.Size(100,20) 
        Add_Click = $EnumerationPortScanPortsSelectionButtonAdd_Click
    }
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortsSelectionButton) 
    CommonButtonSettings -Button $EnumerationPortScanPortsSelectionButton

    $EnumerationPortScanGroupDownPosition += $EnumerationPortScanGroupDownPositionShift


    #--------------------------------------
    # Enumeration - Port Scan - Port Range
    #--------------------------------------
    $EnumerationPortScanRightShift = $EnumerationRightPosition

    $EnumerationPortScanPortRangeNetworkLabel = New-Object System.Windows.Forms.Label -Property @{
        Location  = New-Object System.Drawing.Point($EnumerationPortScanRightShift,($EnumerationPortScanGroupDownPosition + 3)) 
        Size      = New-Object System.Drawing.Size(83,22) 
        Text      = "Port Range"
        Font      = New-Object System.Drawing.Font("$Font",10,0,0,0)
        ForeColor = "Black"
    }
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortRangeNetworkLabel)

    $EnumerationPortScanRightShift += $EnumerationPortScanPortRangeNetworkLabel.Size.Width


    #----------------------------------------
    # Enumeration Port Scan Port Range First 
    #----------------------------------------
    $EnumerationPortScanPortRangeFirstLabel = New-Object System.Windows.Forms.Label -Property @{
        Text      = "First Port"
        Location  = New-Object System.Drawing.Point($EnumerationPortScanRightShift,($EnumerationPortScanGroupDownPosition + 3)) 
        Size      = New-Object System.Drawing.Size(50,22) 
        Font      = New-Object System.Drawing.Font("$Font",10,0,0,0)
        ForeColor = "Black"
    }
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortRangeFirstLabel)

    $EnumerationPortScanRightShift += $EnumerationPortScanPortRangeFirstLabel.Size.Width

    $EnumerationPortScanPortRangeFirstTextbox = New-Object System.Windows.Forms.TextBox -Property @{
        Text          = ""
        Location      = New-Object System.Drawing.Point($EnumerationPortScanRightShift,$EnumerationPortScanGroupDownPosition) 
        Size          = New-Object System.Drawing.Size(50,22)
        MultiLine     = $False
        WordWrap      = $True
        AcceptsTab    = $false # Allows you to enter in tabs into the textbox
        AcceptsReturn = $false # Allows you to enter in returnss into the textbox
        Font          = New-Object System.Drawing.Font("$Font",10,0,0,0)
        ForeColor     = "Black"
    }
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortRangeFirstTextbox)

    $EnumerationPortScanRightShift += $EnumerationPortScanPortRangeFirstTextbox.Size.Width + 4

    
    #-----------------------------------------
    # Enumeration - Port Scan Port Range Last
    #-----------------------------------------
    $EnumerationPortScanPortRangeLastLabel = New-Object System.Windows.Forms.Label -Property @{
        Text      = "Last Port"
        Location  = New-Object System.Drawing.Point($EnumerationPortScanRightShift,($EnumerationPortScanGroupDownPosition + 3)) 
        Size      = New-Object System.Drawing.Size(50,22) 
        Font      = New-Object System.Drawing.Font("$Font",10,0,0,0)
        ForeColor = "Black"
    }
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortRangeLastLabel)

    $EnumerationPortScanRightShift += $EnumerationPortScanPortRangeLastLabel.Size.Width

    $EnumerationPortScanPortRangeLastTextbox = New-Object System.Windows.Forms.TextBox -Property @{
        Text          = ""
        Location      = New-Object System.Drawing.Point($EnumerationPortScanRightShift,$EnumerationPortScanGroupDownPosition) 
        Size          = New-Object System.Drawing.Size(50,22)
        MultiLine     = $False
        WordWrap      = $True
        AcceptsTab    = $false # Allows you to enter in tabs into the textbox
        AcceptsReturn = $false # Allows you to enter in returnss into the textbox
        Font          = New-Object System.Drawing.Font("$Font",10,0,0,0)
        ForeColor     = "Black"
    }
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortRangeLastTextbox)

    $EnumerationPortScanGroupDownPosition += $EnumerationPortScanGroupDownPositionShift


    #--------------------------------------
    # Enumeration - Port Scan - Port Range
    #--------------------------------------
    $EnumerationPortScanRightShift = $EnumerationRightPosition

    $EnumerationPortScanTestICMPFirstCheckBox           = New-Object System.Windows.Forms.CheckBox -Property @{
        Text      = "Test ICMP First (ping)"
        Location  = New-Object System.Drawing.Point($EnumerationPortScanRightShift,($EnumerationPortScanGroupDownPosition)) 
        Size      = New-Object System.Drawing.Size(130,22) 
        Font      = New-Object System.Drawing.Font("$Font",10,0,0,0)
        ForeColor = "Black"
        Checked   = $False
    }
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanTestICMPFirstCheckBox)

    $EnumerationPortScanRightShift += $EnumerationPortScanTestICMPFirstCheckBox.Size.Width + 32

    
    #---------------------------------
    # Enumeration - Port Scan Timeout
    #---------------------------------
    $EnumerationPortScanTimeoutLabel = New-Object System.Windows.Forms.Label -Property @{
        Text      = "Timeout (ms)"
        Location  = New-Object System.Drawing.Point($EnumerationPortScanRightShift,($EnumerationPortScanGroupDownPosition + 3)) 
        Size      = New-Object System.Drawing.Size(75,22) 
        Font      = New-Object System.Drawing.Font("$Font",10,0,0,0)
        ForeColor = "Black"
    }
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanTimeoutLabel)

    $EnumerationPortScanRightShift += $EnumerationPortScanTimeoutLabel.Size.Width

    $EnumerationPortScanTimeoutTextbox = New-Object System.Windows.Forms.TextBox -Property @{
        Text          = 50
        Location      = New-Object System.Drawing.Point($EnumerationPortScanRightShift,$EnumerationPortScanGroupDownPosition) 
        Size          = New-Object System.Drawing.Size(50,22)
        MultiLine     = $False
        WordWrap      = $True
        AcceptsTab    = $false
        AcceptsReturn = $false
        Font          = New-Object System.Drawing.Font("$Font",10,0,0,0)
        ForeColor     = "Black"
    }
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanTimeoutTextbox)

    $EnumerationPortScanRightShift        += $EnumerationPortScanTimeoutTextbox.Size.Width
    $EnumerationPortScanGroupDownPosition += $EnumerationPortScanGroupDownPositionShift


    #------------------------------------------
    # Enumeration - Port Scan - Execute Button
    #------------------------------------------
    . "$Dependencies\Code\System.Windows.Forms\Button\EnumerationPortScanExecutionButton.ps1"
    $EnumerationPortScanExecutionButton = New-Object System.Windows.Forms.Button -Property @{
        Text      = "Execute Scan"
        Location  = New-Object System.Drawing.Point(190,$EnumerationPortScanGroupDownPosition)
        Size      = New-Object System.Drawing.Size(100,22)
        Add_Click = $EnumerationPortScanExecutionButtonAdd_Click
    }
    $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanExecutionButton) 
    CommonButtonSettings -Button $EnumerationPortScanExecutionButton
                
$Section1EnumerationTab.Controls.Add($EnumerationPortScanGroupBox) 

# Using the inputs selected or provided from the GUI, it conducts a basic ping sweep
# The results can be added to the computer treenodes 
# Lists all IPs in a subnet
. "$Dependencies\Code\Main Body\Get-SubnetRange.ps1"

. "$Dependencies\Code\Execution\Enumeration\Conduct-PingSweep.ps1"


#-------------------------------------
# Enumeration - Ping Sweep - GroupBox
#-------------------------------------
# Create a group that will contain your radio buttons
$EnumerationPingSweepGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text      = "Create List From Ping Sweep"
    Location  = New-Object System.Drawing.Point(0,($EnumerationPortScanGroupBox.Location.Y + $EnumerationPortScanGroupBox.Size.Height + $EnumerationGroupGap))
    Size      = New-Object System.Drawing.Size(294,70)
    Font      = New-Object System.Drawing.Font("$Font",12,1,2,1)
    ForeColor = "Blue"
}

$EnumerationPingSweepGroupDownPosition      = 18
$EnumerationPingSweepGroupDownPositionShift = 25

    #-------------------------------------------------
    # Enumeration - Ping Sweep - Network & CIDR Label
    #-------------------------------------------------
    $EnumerationPingSweepNote1Label = New-Object System.Windows.Forms.Label -Property @{
        Text       = "Enter Network/CIDR:"
        Location   = New-Object System.Drawing.Point($EnumerationRightPosition,($EnumerationPingSweepGroupDownPosition + 3)) 
        Size       = New-Object System.Drawing.Size(105,22) 
        Font       = New-Object System.Drawing.Font("$Font",10,0,0,0)
        ForeColor  = "Black"
    }
    $EnumerationPingSweepGroupBox.Controls.Add($EnumerationPingSweepNote1Label)

    
    #---------------------------------
    # Enumeration - Ping Sweep Note 2
    #---------------------------------
    $EnumerationPingSweepNote2Label = New-Object System.Windows.Forms.Label -Property @{
        Text       = "(ex: 10.0.0.0/24)"
        Location   = New-Object System.Drawing.Point(($EnumerationPingSweepNote1Label.Size.Width + 5),($EnumerationPingSweepGroupDownPosition + 4)) 
        Size       = New-Object System.Drawing.Size(80,22)
        Font       = New-Object System.Drawing.Font("$Font",10,0,0,0)
        ForeColor  = "Black"
    }
    $EnumerationPingSweepGroupBox.Controls.Add($EnumerationPingSweepNote2Label)


    #---------------------------------------------------
    # Enumeration - Ping Sweep - Network & CIDR Textbox
    #---------------------------------------------------
    . "$Dependencies\Code\System.Windows.Forms\TextBox\EnumerationPingSweepIPNetworkCIDRTextbox.ps1"
    $EnumerationPingSweepIPNetworkCIDRTextbox = New-Object System.Windows.Forms.TextBox -Property @{
        Text          = ""
        Location      = New-Object System.Drawing.Size(190,($EnumerationPingSweepGroupDownPosition)) 
        Size          = New-Object System.Drawing.Size(100,$EnumerationLabelHeight)
        MultiLine     = $False
        WordWrap      = $True
        AcceptsTab    = $false
        AcceptsReturn = $false
        Font          = New-Object System.Drawing.Font("$Font",10,0,0,0)
        ForeColor     = "Black"
        Add_KeyDown   = $EnumerationPingSweepIPNetworkCIDRTextboxAdd_KeyDown
    }
    $EnumerationPingSweepGroupBox.Controls.Add($EnumerationPingSweepIPNetworkCIDRTextbox)

    $EnumerationPingSweepGroupDownPosition += $EnumerationPingSweepGroupDownPositionShift


    #-------------------------------------------
    # Enumeration - Ping Sweep - Execute Button
    #-------------------------------------------
    . "$Dependencies\Code\System.Windows.Forms\Button\EnumerationPingSweepExecutionButton.ps1"
    $EnumerationPingSweepExecutionButton = New-Object System.Windows.Forms.Button -Property @{
        Text      = "Execute Sweep"
        Location  = New-Object System.Drawing.Size(190,$EnumerationPingSweepGroupDownPosition)
        Size      = New-Object System.Drawing.Size(100,22)
        Add_Click = $EnumerationPingSweepExecutionButtonAdd_Click
    }
    $EnumerationPingSweepGroupBox.Controls.Add($EnumerationPingSweepExecutionButton) 
    CommonButtonSettings -Button $EnumerationPingSweepExecutionButton

$Section1EnumerationTab.Controls.Add($EnumerationPingSweepGroupBox) 


#-------------------------------------------
# Enumeration - Resolve DNS Name Button
#-------------------------------------------
. "$Dependencies\Code\System.Windows.Forms\Button\EnumerationResolveDNSNameButton.ps1"
$EnumerationResolveDNSNameButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "DNS Resolution"
    Location  = New-Object System.Drawing.Point(296,19)
    Size      = New-Object System.Drawing.Size(152,22)
    Add_Click = $EnumerationResolveDNSNameButtonAdd_Click
}
$Section1EnumerationTab.Controls.Add($EnumerationResolveDNSNameButton) 
CommonButtonSettings -Button $EnumerationResolveDNSNameButton


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
$Section1EnumerationTab.Controls.Add($EnumerationComputerListBox)


#----------------------------------
# Single Host - Add To List Button
#----------------------------------
. "$Dependencies\Code\System.Windows.Forms\Button\EnumerationComputerListBoxAddToListButton.ps1"
$EnumerationComputerListBoxAddToListButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "Add To Computer List"
    Location  = New-Object System.Drawing.Point(($EnumerationComputerListBox.Location.X - 1),($EnumerationComputerListBox.Location.Y + $EnumerationComputerListBox.Size.Height - 3))
    Size      = New-Object System.Drawing.Size(($EnumerationComputerListBox.Size.Width + 2),22) 
    Add_Click = $EnumerationComputerListBoxAddToListButtonAdd_Click
}
$Section1EnumerationTab.Controls.Add($EnumerationComputerListBoxAddToListButton) 
CommonButtonSettings -Button $EnumerationComputerListBoxAddToListButton


#---------------------------------
# Enumeration - Select All Button
#---------------------------------
. "$Dependencies\Code\System.Windows.Forms\Button\EnumerationComputerListBoxSelectAllButton.ps1"
$EnumerationComputerListBoxSelectAllButton = New-Object System.Windows.Forms.Button -Property @{
    Location = New-Object System.Drawing.Size($EnumerationComputerListBoxAddToListButton.Location.X,($EnumerationComputerListBoxAddToListButton.Location.Y + $EnumerationComputerListBoxAddToListButton.Size.Height + 4))
    Size     = New-Object System.Drawing.Size($EnumerationComputerListBoxAddToListButton.Size.Width,22)
    Text     = "Select All"
    Add_Click = $EnumerationComputerListBoxSelectAllButtonAdd_Click
}
$Section1EnumerationTab.Controls.Add($EnumerationComputerListBoxSelectAllButton) 
CommonButtonSettings -Button $EnumerationComputerListBoxSelectAllButton


#-----------------------------------
# Computer List - Clear List Button
#-----------------------------------
. "$Dependencies\Code\System.Windows.Forms\Button\EnumerationComputerListBoxClearButton.ps1"
$EnumerationComputerListBoxClearButton = New-Object System.Windows.Forms.Button -Property @{
    Location  = New-Object System.Drawing.Size($EnumerationComputerListBoxSelectAllButton.Location.X,($EnumerationComputerListBoxSelectAllButton.Location.Y + $EnumerationComputerListBoxSelectAllButton.Size.Height + 4))
    Size      = New-Object System.Drawing.Size($EnumerationComputerListBoxSelectAllButton.Size.Width,22)
    Text      = 'Clear List'
    Add_Click = $EnumerationComputerListBoxClearButtonAdd_Click
}
$Section1EnumerationTab.Controls.Add($EnumerationComputerListBoxClearButton) 
CommonButtonSettings -Button $EnumerationComputerListBoxClearButton


#=======================================================================================================================================================================
#
#  Parent: Main Form -> Main Left TabControl
#    ____  _                  _     _  _       _            _____       _      ____                     
#   / ___|| |__    ___   ___ | | __| |(_) ___ | |_  ___    |_   _|__ _ | |__  |  _ \  __ _   __ _   ___ 
#  | |    | '_ \  / _ \ / __|| |/ /| || |/ __|| __|/ __|     | | / _` || '_ \ | |_) |/ _` | / _` | / _ \
#  | |___ | | | ||  __/| (__ |   < | || |\__ \| |_ \__ \     | || (_| || |_) ||  __/| (_| || (_| ||  __/
#   \____||_| |_| \___| \___||_|\_\|_||_||___/ \__||___/     |_| \__,_||_.__/ |_|    \__,_| \__, | \___|
#                                                                                           |___/       
#=======================================================================================================================================================================

$MainLeftChecklistTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text                    = "Checklist"
    Name                    = "Checklist Tab"
    Font                    = New-Object System.Drawing.Font("$Font",11,0,0,0)
    UseVisualStyleBackColor = $True
}
if (Test-Path "$Dependencies\Checklists") { $MainLeftTabControl.Controls.Add($MainLeftChecklistTab) }

$TabRightPosition     = 3
$TabhDownPosition     = 3
$TabAreaWidth         = 446
$TabAreaHeight        = 557
$TextBoxRightPosition = -2 
$TextBoxDownPosition  = -2
$TextBoxWidth         = 442
$TextBoxHeight        = 536


#============================================================================================================================================================
#
#  Parent: Main Form -> Main Left TabControl -> Checklist Tabpage
#    ____  _                  _     _  _       _            _____       _       ____               _                _ 
#   / ___|| |__    ___   ___ | | __| |(_) ___ | |_  ___    |_   _|__ _ | |__   / ___| ___   _ __  | |_  _ __  ___  | |
#  | |    | '_ \  / _ \ / __|| |/ /| || |/ __|| __|/ __|     | | / _` || '_ \ | |    / _ \ | '_ \ | __|| '__|/ _ \ | |
#  | |___ | | | ||  __/| (__ |   < | || |\__ \| |_ \__ \     | || (_| || |_) || |___| (_) || | | || |_ | |  | (_) || |
#   \____||_| |_| \___| \___||_|\_\|_||_||___/ \__||___/     |_| \__,_||_.__/  \____|\___/ |_| |_| \__||_|   \___/ |_|
#
#============================================================================================================================================================

$MainLeftChecklistTabControl = New-Object System.Windows.Forms.TabControl -Property @{
    Name          = "Checklist TabControl"
    Location      = New-Object System.Drawing.Point($TabRightPosition,$TabhDownPosition)
    Size          = New-Object System.Drawing.Size($TabAreaWidth,$TabAreaHeight) 
    Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ShowToolTips  = $True
    SelectedIndex = 0
}
$MainLeftChecklistTab.Controls.Add($MainLeftChecklistTabControl)


$ChecklistRightPosition     = 5
$ChecklistDownPositionStart = 10
$ChecklistDownPosition      = 10
$ChecklistDownPositionShift = 30
$CheckListBoxWidth          = 410
$CheckListBoxHeight         = 30


#-------------------------------------------------------
# Checklists Auto Create Tabs and Checkboxes from files
#-------------------------------------------------------
$ResourceChecklistFiles = Get-ChildItem "$Dependencies\Checklists"

# Iterates through the files and dynamically creates tabs and imports data
. "$Dependencies\Code\Main Body\Dynamically Create Checklists.ps1"


#=======================================================================================================================================================================
#
#  Parent: Main Form -> Main Left TabControl
#   ____                                                  _____       _      ____                     
#  |  _ \  _ __  ___    ___  ___  ___  ___   ___  ___    |_   _|__ _ | |__  |  _ \  __ _   __ _   ___ 
#  | |_) || '__|/ _ \  / __|/ _ \/ __|/ __| / _ \/ __|     | | / _` || '_ \ | |_) |/ _` | / _` | / _ \
#  |  __/ | |  | (_) || (__|  __/\__ \\__ \|  __/\__ \     | || (_| || |_) ||  __/| (_| || (_| ||  __/
#  |_|    |_|   \___/  \___|\___||___/|___/ \___||___/     |_| \__,_||_.__/ |_|    \__,_| \__, | \___|
#                                                                                         |___/       
#=======================================================================================================================================================================

$Section1ProcessesTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text                    = "Processes"
    Name                    = "Processes Tab"
    UseVisualStyleBackColor = $True
    Font                    = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
if (Test-Path "$Dependencies\Process Info") { $MainLeftTabControl.Controls.Add($Section1ProcessesTab) }

$TabRightPosition       = 3
$TabhDownPosition       = 3
$TabAreaWidth           = 446
$TabAreaHeight          = 557
$TextBoxRightPosition   = -2 
$TextBoxDownPosition    = -2
$TextBoxWidth           = 442
$TextBoxHeight          = 536

    
#============================================================================================================================================================
#
#  Parent: Main Form -> Main Left TabControl -> Processes Tab
#  ____                                                  _____       _       ____               _                _ 
#  |  _ \  _ __  ___    ___  ___  ___  ___   ___  ___    |_   _|__ _ | |__   / ___| ___   _ __  | |_  _ __  ___  | |
#  | |_) || '__|/ _ \  / __|/ _ \/ __|/ __| / _ \/ __|     | | / _` || '_ \ | |    / _ \ | '_ \ | __|| '__|/ _ \ | |
#  |  __/ | |  | (_) || (__|  __/\__ \\__ \|  __/\__ \     | || (_| || |_) || |___| (_) || | | || |_ | |  | (_) || |
#  |_|    |_|   \___/  \___|\___||___/|___/ \___||___/     |_| \__,_||_.__/  \____|\___/ |_| |_| \__||_|   \___/ |_|
#
#============================================================================================================================================================

$MainLeftProcessesTabControl = New-Object System.Windows.Forms.TabControl -Property @{
    Name     = "Processes TabControl"
    Location = @{ X = $TabRightPosition
                  Y = $TabhDownPosition }
    Size     = @{ Width  = $TabAreaWidth
                  Height = $TabAreaHeight }
    Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ShowToolTips  = $True
    SelectedIndex = 0
}
$Section1ProcessesTab.Controls.Add($MainLeftProcessesTabControl)


    #=================================================================================================================================================================================
    #
    #  Parent: Main Form -> Main Left TabControl -> Processes TabControl
    #   ____                                   _              _  _             ____                                 _             _     _____       _      ____                     
    #  |  _ \  _   _  _ __    __ _  _ __ ___  (_)  ___  __ _ | || | _   _     / ___|  ___  _ __    ___  _ __  __ _ | |_  ___   __| |   |_   _|__ _ | |__  |  _ \  __ _   __ _   ___ 
    #  | | | || | | || '_ \  / _` || '_ ` _ \ | | / __|/ _` || || || | | |   | |  _  / _ \| '_ \  / _ \| '__|/ _` || __|/ _ \ / _` |     | | / _` || '_ \ | |_) |/ _` | / _` | / _ \
    #  | |_| || |_| || | | || (_| || | | | | || || (__| (_| || || || |_| |   | |_| ||  __/| | | ||  __/| |  | (_| || |_|  __/| (_| |     | || (_| || |_) ||  __/| (_| || (_| ||  __/
    #  |____/  \__, ||_| |_| \__,_||_| |_| |_||_| \___|\__,_||_||_| \__, |    \____| \___||_| |_| \___||_|   \__,_| \__|\___| \__,_|     |_| \__,_||_.__/ |_|    \__,_| \__, | \___|
    #          |___/                                                |___/                                                                                               |___/       
    #=================================================================================================================================================================================

    # Iterates through the files and dynamically creates tabs and imports data
    . "$Dependencies\Code\Main Body\Dynamically Create Process Info.ps1"


#=======================================================================================================================================================================
#
#  Parent: Main Form -> Main Left TabControl
#    ___          _   _         _                 _____       _      ____                     
#   / _ \  _ __  | \ | |  ___  | |_  ___  ___    |_   _|__ _ | |__  |  _ \  __ _   __ _   ___ 
#  | | | || '_ \ |  \| | / _ \ | __|/ _ \/ __|     | | / _` || '_ \ | |_) |/ _` | / _` | / _ \
#  | |_| || |_) || |\  || (_) || |_|  __/\__ \     | || (_| || |_) ||  __/| (_| || (_| ||  __/
#   \___/ | .__/ |_| \_| \___/  \__|\___||___/     |_| \__,_||_.__/ |_|    \__,_| \__, | \___|
#         |_|                                                                     |___/       
#=======================================================================================================================================================================

$Section1OpNotesTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text                    = "OpNotes"
    Name                    = "OpNotes Tab"
    UseVisualStyleBackColor = $True
    Font                    = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$MainLeftTabControl.Controls.Add($Section1OpNotesTab)

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

# The purpose to allow saving of Opnotes automatcially
. "$Dependencies\Code\Main Body\Save-OpNotes.ps1"

# This function is called when pressing enter in the text box or click add
. "$Dependencies\Code\Main Body\OpNoteTextBoxEntry.ps1"

#-------------------------------------
# OpNoptes - Enter your OpNotes Label
#-------------------------------------
$OpNotesLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = "Enter Your OpNotes (Auto-Timestamp):"
    Location = @{ X = $OpNotesRightPosition
                  Y = $OpNotesDownPosition }
    Size     = @{ Width  = $OpNotesInputTextBoxWidth
                  Height = $OpNotesInputTextBoxHeight }
    Font      = New-Object System.Drawing.Font("$Font",13,1,2,1)
    ForeColor = "Blue"
}
$Section1OpNotesTab.Controls.Add($OpNotesLabel)

$OpNotesDownPosition += $OpNotesDownPositionShift


#--------------------------
# OpNotes - Input Text Box
#--------------------------
. "$Dependencies\Code\System.Windows.Forms\TextBox\OpNotesInputTextBox.ps1"
$OpNotesInputTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = New-Object System.Drawing.Point($OpNotesRightPosition,$OpNotesDownPosition)
    Size     = New-Object System.Drawing.Size($OpNotesInputTextBoxWidth,$OpNotesInputTextBoxHeight)
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    Add_KeyDown = $OpNotesInputTextBoxAdd_KeyDown
}
$Section1OpNotesTab.Controls.Add($OpNotesInputTextBox)

$OpNotesDownPosition += $OpNotesDownPositionShift


#----------------------
# OpNotes - Add Button
#----------------------
. "$Dependencies\Code\System.Windows.Forms\Button\OpNotesAddButton.ps1"
$OpNotesAddButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "Add"
    Location  = New-Object System.Drawing.Point($OpNotesRightPosition,$OpNotesDownPosition)
    Size      = New-Object System.Drawing.Size($OpNotesButtonWidth,$OpNotesButtonHeight)
    Add_Click = $OpNotesAddButtonAdd_Click
}
$Section1OpNotesTab.Controls.Add($OpNotesAddButton) 
CommonButtonSettings -Button $OpNotesAddButton

$OpNotesRightPosition += $OpNotesRightPositionShift


#-----------------------------
# OpNotes - Select All Button
#-----------------------------
. "$Dependencies\Code\System.Windows.Forms\Button\OpNotesSelectAllButton.ps1"
$OpNotesSelectAllButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Select All"
    Location = New-Object System.Drawing.Point($OpNotesRightPosition,$OpNotesDownPosition)
    Size     = New-Object System.Drawing.Size($OpNotesButtonWidth,$OpNotesButtonHeight)
    Add_Click = $OpNotesSelectAllButtonAdd_Click
}
$Section1OpNotesTab.Controls.Add($OpNotesSelectAllButton) 
CommonButtonSettings -Button $OpNotesSelectAllButton

$OpNotesRightPosition += $OpNotesRightPositionShift


#-------------------------------
# OpNotes - Open OpNotes Button
#-------------------------------
. "$Dependencies\Code\System.Windows.Forms\Button\OpNotesOpenOpNotesButton.ps1"
$OpNotesOpenOpNotesButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Open OpNotes"
    Location = @{ X = $OpNotesRightPosition
                  Y = $OpNotesDownPosition }
    Size     = @{ Width  = $OpNotesButtonWidth
                  Height = $OpNotesButtonHeight }
    Add_Click = $OpNotesOpenOpNotesButtonAdd_Click
}
$Section1OpNotesTab.Controls.Add($OpNotesOpenOpNotesButton)
CommonButtonSettings -Button $OpNotesOpenOpNotesButton

$OpNotesRightPosition += $OpNotesRightPositionShift


#--------------------------
# OpNotes - Move Up Button
#--------------------------
. "$Dependencies\Code\System.Windows.Forms\Button\OpNotesMoveUpButton.ps1"
$OpNotesMoveUpButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = 'Move Up'
    Location = @{ X = $OpNotesRightPosition
                  Y = $OpNotesDownPosition }
    Size     = @{ Width  = $OpNotesButtonWidth
                  Height = $OpNotesButtonHeight }
    Add_Click = $OpNotesMoveUpButtonAdd_Click
}
$Section1OpNotesTab.Controls.Add($OpNotesMoveUpButton) 
CommonButtonSettings -Button $OpNotesMoveUpButton

$OpNotesDownPosition += $OpNotesDownPositionShift
$OpNotesRightPosition = $OpNotesRightPositionStart


#----------------------------------
# OpNotes - Remove Selected Button
#----------------------------------
. "$Dependencies\Code\System.Windows.Forms\Button\OpNotesRemoveButton.ps1"
$OpNotesRemoveButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = 'Remove'
    Location = New-Object System.Drawing.Point($OpNotesRightPosition,$OpNotesDownPosition)
    Size     = New-Object System.Drawing.Size($OpNotesButtonWidth,$OpNotesButtonHeight)
    Add_Click = $OpNotesRemoveButtonAdd_Click
}
$Section1OpNotesTab.Controls.Add($OpNotesRemoveButton) 
CommonButtonSettings -Button $OpNotesRemoveButton

$OpNotesRightPosition += $OpNotesRightPositionShift


#--------------------------------
# OpNotes - Create Report Button
#--------------------------------
. "$Dependencies\Code\System.Windows.Forms\Button\OpNotesCreateReportButton.ps1"
$OpNotesCreateReportButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Create Report"
    Location = New-Object System.Drawing.Point($OpNotesRightPosition,$OpNotesDownPosition)
    Size     = New-Object System.Drawing.Size($OpNotesButtonWidth,$OpNotesButtonHeight)
    Add_Click = $OpNotesCreateReportButtonAdd_Click
}
$Section1OpNotesTab.Controls.Add($OpNotesCreateReportButton) 
CommonButtonSettings -Button $OpNotesCreateReportButton

$OpNotesRightPosition += $OpNotesRightPositionShift


#-------------------------------
# OpNotes - Open Reports Button
#-------------------------------
$OpNotesOpenReportsButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Open Reports"
    Location = New-Object System.Drawing.Point($OpNotesRightPosition,$OpNotesDownPosition)
    Size     = New-Object System.Drawing.Size($OpNotesButtonWidth,$OpNotesButtonHeight) 
    Add_Click = { Invoke-Item -Path "$PoShHome\Reports" }
}
$Section1OpNotesTab.Controls.Add($OpNotesOpenReportsButton)
CommonButtonSettings -Button $OpNotesOpenReportsButton

$OpNotesRightPosition += $OpNotesRightPositionShift


#----------------------------
# OpNotes - Move Down Button
#----------------------------
. "$Dependencies\Code\System.Windows.Forms\Button\OpNotesMoveDownButton.ps1"
$OpNotesMoveDownButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = 'Move Down'
    Location = New-Object System.Drawing.Point($OpNotesRightPosition,$OpNotesDownPosition)
    Size     = New-Object System.Drawing.Size($OpNotesButtonWidth,$OpNotesButtonHeight)
    Add_Click = $OpNotesMoveDownButtonAdd_Click
}
$Section1OpNotesTab.Controls.Add($OpNotesMoveDownButton) 
CommonButtonSettings -Button $OpNotesMoveDownButton

$OpNotesDownPosition += $OpNotesDownPositionShift


#-------------------
# OpNotes - ListBox
#-------------------
. "$Dependencies\Code\System.Windows.Forms\ListBox\OpNotesListBox.ps1"
$OpNotesListBox = New-Object System.Windows.Forms.ListBox -Property @{
    Name                = "OpNotesListBox"
    Location            = New-Object System.Drawing.Point($OpNotesRightPositionStart,($OpNotesDownPosition + 5)) 
    Size                = New-Object System.Drawing.Size($OpNotesMainTextBoxWidth,$OpNotesMainTextBoxHeight)
    Font                = New-Object System.Drawing.Font("$Font",11,0,0,0)
    FormattingEnabled   = $True
    SelectionMode       = 'MultiExtended'
    ScrollAlwaysVisible = $True
    AutoSize            = $false
    Add_MouseEnter = $OpNotesListBoxAdd_MouseEnter
    Add_MouseLeave = $OpNotesListBoxAdd_MouseLeave

}
$Section1OpNotesTab.Controls.Add($OpNotesListBox)

# Obtains the OpNotes to be viewed and manipulated later
$OpNotesFileContents = Get-Content "$OpNotesFile"

# Checks to see if OpNotes.txt exists and loads it
$OpNotesFileContents = Get-Content "$OpNotesFile"
if (Test-Path -Path $OpNotesFile) {
    $OpNotesListBox.Items.Clear()
    foreach ($OpNotesEntry in $OpNotesFileContents){ $OpNotesListBox.Items.Add("$OpNotesEntry") }
}


#=======================================================================================================================================================================
#
#  Parent: Main Form -> Main Left TabControl
#   ___          __            _____       _      ____                     
#  |_ _| _ __   / _|  ___     |_   _|__ _ | |__  |  _ \  __ _   __ _   ___ 
#   | | | '_ \ | |_  / _ \      | | / _` || '_ \ | |_) |/ _` | / _` | / _ \
#   | | | | | ||  _|| (_) |     | || (_| || |_) ||  __/| (_| || (_| ||  __/
#  |___||_| |_||_|   \___/      |_| \__,_||_.__/ |_|    \__,_| \__, | \___|
#                                                              |___/       
#=======================================================================================================================================================================

$MainLeftInfoTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text                    = "Info"
    Font                    = New-Object System.Drawing.Font("$Font",11,0,0,0)
    UseVisualStyleBackColor = $True
}
$MainLeftTabControl.Controls.Add($MainLeftInfoTab)

$TabRightPosition       = 3
$TabhDownPosition       = 3
$TabAreaWidth           = 446
$TabAreaHeight          = 557
$TextBoxRightPosition   = -2 
$TextBoxDownPosition    = -2
$TextBoxWidth           = 442
$TextBoxHeight          = 536

#============================================================================================================================================================
#
#  Parent: Main Form -> Main Left TabControl -> Info TabPage
#   ___          __            _____       _       ____               _                _ 
#  |_ _| _ __   / _|  ___     |_   _|__ _ | |__   / ___| ___   _ __  | |_  _ __  ___  | |
#   | | | '_ \ | |_  / _ \      | | / _` || '_ \ | |    / _ \ | '_ \ | __|| '__|/ _ \ | |
#   | | | | | ||  _|| (_) |     | || (_| || |_) || |___| (_) || | | || |_ | |  | (_) || |
#  |___||_| |_||_|   \___/      |_| \__,_||_.__/  \____|\___/ |_| |_| \__||_|   \___/ |_|
#
#============================================================================================================================================================

$MainLeftInfoTabControl = New-Object System.Windows.Forms.TabControl -Property @{
    Location      = New-Object System.Drawing.Point($TabRightPosition,$TabhDownPosition)
    Size          = New-Object System.Drawing.Size($TabAreaWidth,$TabAreaHeight) 
    Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ShowToolTips  = $True
    SelectedIndex = 0
}
$MainLeftInfoTab.Controls.Add($MainLeftInfoTabControl)

#------------------------------------
# Auto Creates Tabs and Imports Data
#------------------------------------
$ResourceFiles = Get-ChildItem "$Dependencies\About"

# Iterates through the files and dynamically creates tabs and imports data
foreach ($File in $ResourceFiles) {
   
    #=================================================================================================================================================================================
    #
    #  Parent: Main Form -> Main Left TabControl -> Info TabControl
    #   ____                                   _              _  _             ____                                 _             _     _____       _      ____                     
    #  |  _ \  _   _  _ __    __ _  _ __ ___  (_)  ___  __ _ | || | _   _     / ___|  ___  _ __    ___  _ __  __ _ | |_  ___   __| |   |_   _|__ _ | |__  |  _ \  __ _   __ _   ___ 
    #  | | | || | | || '_ \  / _` || '_ ` _ \ | | / __|/ _` || || || | | |   | |  _  / _ \| '_ \  / _ \| '__|/ _` || __|/ _ \ / _` |     | | / _` || '_ \ | |_) |/ _` | / _` | / _ \
    #  | |_| || |_| || | | || (_| || | | | | || || (__| (_| || || || |_| |   | |_| ||  __/| | | ||  __/| |  | (_| || |_|  __/| (_| |     | || (_| || |_) ||  __/| (_| || (_| ||  __/
    #  |____/  \__, ||_| |_| \__,_||_| |_| |_||_| \___|\__,_||_||_| \__, |    \____| \___||_| |_| \___||_|   \__,_| \__|\___| \__,_|     |_| \__,_||_.__/ |_|    \__,_| \__, | \___|
    #          |___/                                                |___/                                                                                               |___/       
    #=================================================================================================================================================================================

    $Section1AboutSubTab = New-Object System.Windows.Forms.TabPage -Property @{
        Text                    = $File.BaseName
        UseVisualStyleBackColor = $True
        Font                    = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $MainLeftInfoTabControl.Controls.Add($Section1AboutSubTab)


    #-----------------------------
    # Imports Data Into Textboxes
    #-----------------------------
    $TabContents = Get-Content -Path $File.FullName -Force | foreach {$_ + "`r`n"} 
    $Section1AboutSubTabTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Text       = "$TabContents"
        Name       = "$file"
        Location   = New-Object System.Drawing.Point($TextBoxRightPosition,$TextBoxDownPosition) 
        Size       = New-Object System.Drawing.Size($TextBoxWidth,$TextBoxHeight)
        MultiLine  = $True
        ScrollBars = "Vertical"
        Font       = New-Object System.Drawing.Font("Courier New",9,0,0,0)
    }
    $Section1AboutSubTab.Controls.Add($Section1AboutSubTabTextBox)    
}


#============================================================================================================================================================
#
#  Parent: Main Form
#   __  __         _             ____              _                  _____       _       ____               _                _ 
#  |  \/  |  __ _ (_) _ __      / ___| ___  _ __  | |_  ___  _ __    |_   _|__ _ | |__   / ___| ___   _ __  | |_  _ __  ___  | |
#  | |\/| | / _` || || '_ \    | |    / _ \| '_ \ | __|/ _ \| '__|     | | / _` || '_ \ | |    / _ \ | '_ \ | __|| '__|/ _ \ | |
#  | |  | || (_| || || | | |   | |___|  __/| | | || |_|  __/| |        | || (_| || |_) || |___| (_) || | | || |_ | |  | (_) || |
#  |_|  |_| \__,_||_||_| |_|    \____|\___||_| |_| \__|\___||_|        |_| \__,_||_.__/  \____|\___/ |_| |_| \__||_|   \___/ |_|
#
#============================================================================================================================================================

. "$Dependencies\Code\System.Windows.Forms\TabControl\Section2TabControl.ps1"
$MainCenterTabControl = New-Object System.Windows.Forms.TabControl -Property @{
    Name          = "Main Tab Window"
    Location      = @{ X = 470
                       Y = 5 }
    Size          = @{ Width =  370
                       Height = 278 }
    SelectedIndex = 0
    ShowToolTips  = $True
    Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
    Add_Click      = $MainCenterTabControlAdd_Click
    Add_MouseHover = $MainCenterTabControlAdd_MouseHover
}
$PoShEasyWin.Controls.Add($MainCenterTabControl)


#=======================================================================================================================================================================
#
#  Parent: Main Form -> Main Center TabControl
#   __  __         _            _____       _      ____                     
#  |  \/  |  __ _ (_) _ __     |_   _|__ _ | |__  |  _ \  __ _   __ _   ___ 
#  | |\/| | / _` || || '_ \      | | / _` || '_ \ | |_) |/ _` | / _` | / _ \
#  | |  | || (_| || || | | |     | || (_| || |_) ||  __/| (_| || (_| ||  __/
#  |_|  |_| \__,_||_||_| |_|     |_| \__,_||_.__/ |_|    \__,_| \__, | \___|
#                                                               |___/       
#=======================================================================================================================================================================

$MainCenterMainTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text                    = "Main"
    Name                    = "Main"
    UseVisualStyleBackColor = $True
    Font                    = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$MainCenterTabControl.Controls.Add($MainCenterMainTab)

$Column3RightPosition     = 3
$Column3DownPosition      = 11
$Column3BoxWidth          = 300
$Column3BoxHeight         = 22
$Column3DownPositionShift = 26

$DefaultSingleHostIPText = "<Type In A Hostname / IP>"

#---------------------------------------------------
# Single Host - Enter A Single Hostname/IP Checkbox
#---------------------------------------------------
# This checkbox highlights when selecting computers from the ComputerList
. "$Dependencies\Code\System.Windows.Forms\Checkbox\SingleHostIPCheckBox.ps1"
$script:SingleHostIPCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
    Text      = "Query A Single Host:"
    Location  = @{ X = 3
                   Y = 11 }
    Size      = @{ Width  = 210
                   Height = $Column3BoxHeight }
    Font      = New-Object System.Drawing.Font("$Font",11,1,2,1)
    Forecolor = 'Blue'
    Enabled   = $true
    Add_Click      = $SingleHostIPCheckBoxAdd_Click
    Add_MouseHover = $SingleHostIPCheckBoxAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($script:SingleHostIPCheckBox)

$Column3DownPosition += $Column3DownPositionShift

#-----------------------------
# Single Host - Input Textbox
#-----------------------------
. "$Dependencies\Code\System.Windows.Forms\TextBox\SingleHostIPTextBox.ps1"
$script:SingleHostIPTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Text     = $DefaultSingleHostIPText
    Location = @{ X = $Column3RightPosition
                  Y = $Column3DownPosition + 1 }
    Size     = @{ Width  = 235
                  Height = $Column3BoxHeight }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    Add_KeyDown    = $SingleHostIPTextBoxAdd_KeyDown
    Add_MouseHover = $SingleHostIPTextBoxAdd_MouseHover
    Add_MouseEnter = $SingleHostIPTextBoxAdd_MouseEnter
    Add_MouseLeave = $SingleHostIPTextBoxAdd_MouseLeave
}
$MainCenterMainTab.Controls.Add($script:SingleHostIPTextBox)


#----------------------------------
# Single Host - Add To List Button
#----------------------------------
. "$Dependencies\Code\System.Windows.Forms\Button\SingleHostIPAddButton.ps1"
$SingleHostIPAddButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Add To List"
    Location = @{ X = $Column3RightPosition + 240
                  Y = $Column3DownPosition }
    Size     = @{ Width  = 115
                  Height = $Column3BoxHeight } 
    Add_Click      = $SingleHostIPAddButtonAdd_Click
    Add_MouseHover = $SingleHostIPAddButtonAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($SingleHostIPAddButton)
CommonButtonSettings -Button $SingleHostIPAddButton

$Column3DownPosition += $Column3DownPositionShift
$Column3DownPosition += $Column3DownPositionShift - 3


#-------------------------------------------
# Directory Location - Results Folder Label
#-------------------------------------------
$DirectoryListLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = "Results Folder:"
    Location  = @{ X = $Column3RightPosition
                   Y = $SingleHostIPAddButton.Location.Y + $SingleHostIPAddButton.Size.Height + 30 }
    Size      = @{ Width  = 120
                   Height = 22 }
    Font      = New-Object System.Drawing.Font("$Font",11,1,2,1)
    ForeColor = "Blue"
}
$MainCenterMainTab.Controls.Add($DirectoryListLabel)


#----------------------------------------
# Directory Location - Directory TextBox
#----------------------------------------
# This shows the name of the directy that data will be currently saved to
. "$Dependencies\Code\System.Windows.Forms\TextBox\CollectionSavedDirectoryTextBox.ps1"
$script:CollectionSavedDirectoryTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Name     = "Saved Directory List Box"
    Text    = $SaveDirectory
    Location = @{ X = $Column3RightPosition
                  Y = $DirectoryListLabel.Location.Y + $DirectoryListLabel.Size.Height } 
    Size     = @{ Width  = 354
                  Height = 22 }
    WordWrap = $false
    AcceptsTab = $true
    TabStop    = $true
    Multiline  = $false
    AutoSize   = $false
    Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    AutoCompleteSource = "FileSystem"
    AutoCompleteMode   = "SuggestAppend"
    Add_MouseHover     = $CollectionSavedDirectoryTextBoxAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($script:CollectionSavedDirectoryTextBox)


#------------------------------------------
# Directory Location - Open Results Button
#------------------------------------------
. "$Dependencies\Code\System.Windows.Forms\Button\DirectoryOpenButton.ps1"
$DirectoryOpenButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Open Folder"
    Location = @{ X = $Column3RightPosition + 120
                  Y = $script:CollectionSavedDirectoryTextBox.Location.Y + $script:CollectionSavedDirectoryTextBox.Size.Height + 5 }
    Size     = @{ Width  = 115
                  Height = $Column3BoxHeight } 
    Add_Click      = $DirectoryOpenButtonAdd_Click 
    Add_MouseHover = $DirectoryOpenButtonAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($DirectoryOpenButton)
CommonButtonSettings -Button $DirectoryOpenButton


#-------------------------------------------
# Directory Location - New Timestamp Button
#-------------------------------------------
. "$Dependencies\Code\System.Windows.Forms\Button\DirectoryUpdateButton.ps1"
$DirectoryUpdateButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "New Timestamp"
    Location = @{ X = $DirectoryOpenButton.Location.X + $DirectoryOpenButton.Size.Width + 5
                  Y = $DirectoryOpenButton.Location.Y }
    Size     = @{ Width  = 115
                  Height = $Column3BoxHeight } 
    Add_Click      = $DirectoryUpdateButtonAdd_Click
    Add_MouseHover = $DirectoryUpdateButtonAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($DirectoryUpdateButton) 
CommonButtonSettings -Button $DirectoryUpdateButton


#-----------------
# Results Section
#-----------------
$ResultsSectionLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = "Analyst Options:"
    Location  = @{ X = 2
                   Y = $DirectoryUpdateButton.Location.Y + $DirectoryUpdateButton.Size.Height + 15 }
    Size      = @{ Width  = 230
                   Height = $Column3BoxHeight } 
    Font      = New-Object System.Drawing.Font("$Font",11,1,2,1)
    ForeColor = "Blue"
}
$MainCenterMainTab.Controls.Add($ResultsSectionLabel)


#-------------------
# View Chart Button
#-------------------
. "$Dependencies\Code\System.Windows.Forms\Button\BuildChartButton.ps1"
$BuildChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Build Charts"
    Location = @{ X = $ResultsSectionLabel.Location.X
                  Y = $ResultsSectionLabel.Location.Y + $ResultsSectionLabel.Size.Height}
    Size     = @{ Width  = 115
                  Height = 22 }
    Add_Click      = $BuildChartButtonAdd_Click
    Add_MouseHover = $BuildChartButtonAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($BuildChartButton)
CommonButtonSettings -Button $BuildChartButton


#--------------------------------
# Auto Create Multi-Series Chart
#--------------------------------
. "$Dependencies\Code\Charts\Generate-AutoChartsCommand.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\AutoCreateMultiSeriesChartButton.ps1"
$AutoCreateMultiSeriesChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Multi-Series Charts"
    Location = @{ X = $BuildChartButton.Location.X + $BuildChartButton.Size.Width + 5
                    Y = $BuildChartButton.Location.Y }
    Size     = @{ Width  = 115
                    Height = 22 }
    Add_Click = $AutoCreateMultiSeriesChartButtonAdd_Click
    Add_MouseHover = $AutoCreateMultiSeriesChartButtonAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($AutoCreateMultiSeriesChartButton)
CommonButtonSettings -Button $AutoCreateMultiSeriesChartButton


#-------------------------------------
# Auto Create Dashboard Charts Button
#-------------------------------------
. "$Dependencies\Code\Main Body\Open-XmlResultsInShell.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\AutoCreateDashboardChartButton.ps1"
$AutoCreateDashboardChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Dashboard Charts"
    Location = @{ X = $AutoCreateMultiSeriesChartButton.Location.X + $AutoCreateMultiSeriesChartButton.Size.Width + 5
                    Y = $AutoCreateMultiSeriesChartButton.Location.Y }
    Size     = @{ Width = 115
                    Height = 22 }
    Add_Click      = $AutoCreateDashboardChartButtonAdd_Click
    Add_MouseHover = $AutoCreateDashboardChartButtonAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($AutoCreateDashboardChartButton)
CommonButtonSettings -Button $AutoCreateDashboardChartButton


#==================
# Copy File Button
#==================
. "$Dependencies\Code\System.Windows.Forms\Button\RetrieveFilesButton.ps1"
$RetrieveFilesButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Retrieve Files"
    Location = @{ X = $BuildChartButton.Location.X
                  Y = $BuildChartButton.Location.Y + $BuildChartButton.Size.Height + 5 }
    Size     = @{ Width  = 115
                  Height = 22 }
    Add_Click      = $RetrieveFilesButtonAdd_Click
    Add_MouseHover = $RetrieveFilesButtonAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($RetrieveFilesButton)
CommonButtonSettings -Button $RetrieveFilesButton


#==================
# Open XML Results
#==================
. "$Dependencies\Code\System.Windows.Forms\Button\OpenXmlResultsButton.ps1"
$OpenXmlResultsButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Open Data In Shell"
    Location = @{ X = $AutoCreateMultiSeriesChartButton.Location.X
                  Y = $AutoCreateMultiSeriesChartButton.Location.Y + $AutoCreateMultiSeriesChartButton.Size.Height + 5 }
    Size     = @{ Width  = 115
                  Height = 22 }
    Add_Click      = $OpenXmlResultsButtonAdd_Click
    Add_MouseHover = $OpenXmlResultsButtonAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($OpenXmlResultsButton)
CommonButtonSettings -Button $OpenXmlResultsButton


#==================
# View CSV Results
#==================
. "$Dependencies\Code\System.Windows.Forms\Button\OpenCsvResultsButton.ps1"
$OpenCsvResultsButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "View CSV Results"
    Location = @{ X = $AutoCreateDashboardChartButton.Location.X
                  Y = $AutoCreateDashboardChartButton.Location.Y + $AutoCreateDashboardChartButton.Size.Height + 5 }
    Size     = @{ Width  = 115
                  Height = 22 }
    Add_Click = $OpenCsvResultsButtonAdd_Click
    Add_MouseHover = $OpenCsvResultsButtonAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($OpenCsvResultsButton)
CommonButtonSettings -Button $OpenCsvResultsButton


# The Launch-ChartImageSaveFileDialog function is use by 'build charts and autocharts'
. "$Dependencies\Code\Charts\Launch-ChartImageSaveFileDialog.ps1"

# Increases the chart size by 4 then saves it to file
. "$Dependencies\Code\Charts\Save-ChartImage.ps1"


#=======================================================================================================================================================================
#
#  Parent: Main Form -> Main Center TabControl
#    ___          _    _                        _____       _      ____                     
#   / _ \  _ __  | |_ (_)  ___   _ __   ___    |_   _|__ _ | |__  |  _ \  __ _   __ _   ___ 
#  | | | || '_ \ | __|| | / _ \ | '_ \ / __|     | | / _` || '_ \ | |_) |/ _` | / _` | / _ \
#  | |_| || |_) || |_ | || (_) || | | |\__ \     | || (_| || |_) ||  __/| (_| || (_| ||  __/
#   \___/ | .__/  \__||_| \___/ |_| |_||___/     |_| \__,_||_.__/ |_|    \__,_| \__, | \___|
#         |_|                                                                   |___/       
#=======================================================================================================================================================================

$Section2OptionsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text                    = "Options"
    Name                    = "Options"
    Font                    = New-Object System.Drawing.Font("$Font",11,0,0,0)
    UseVisualStyleBackColor = $True
}
$MainCenterTabControl.Controls.Add($Section2OptionsTab)


#-------------------------------
# Option - Job Timeout Combobox
#-------------------------------
. "$Dependencies\Code\System.Windows.Forms\ComboBox\OptionJobTimeoutSelectionComboBox.ps1"
$OptionJobTimeoutSelectionComboBox = New-Object -TypeName System.Windows.Forms.Combobox -Property @{
    #Text    = 600     #The default is set with the Cmdlet Parameter Options
    Text = $JobTimeOutSeconds
    Location = @{ X = 3
                  Y = 11 }
    Size     = @{ Width  = 50
                  Height = 22 }
    Font     = New-Object System.Drawing.Font("$Font",9,0,3,0)
    AutoCompleteMode = "SuggestAppend" 
    Add_MouseHover = $OptionJobTimeoutSelectionComboBoxAdd_MouseHover
}
$JobTimesAvailable = @(15,30,45,60,120,180,240,300,600)
ForEach ($Item in $JobTimesAvailable) { $OptionJobTimeoutSelectionComboBox.Items.Add($Item) }
$Section2OptionsTab.Controls.Add($OptionJobTimeoutSelectionComboBox)


#----------------------------
# Option - Job Timeout Label
#----------------------------
$OptionJobTimeoutSelectionLabel = New-Object -TypeName System.Windows.Forms.Label -Property @{
    Text     = "Job Timeout in Seconds"
    Location = @{ X = $OptionJobTimeoutSelectionComboBox.Size.Width + 10
                  Y = $OptionJobTimeoutSelectionComboBox.Location.Y + 3 }
    Size     = @{ Width  = 150
                  Height = 25 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$Section2OptionsTab.Controls.Add($OptionJobTimeoutSelectionLabel)


#----------------------------------------------
# Option - Statistics Update Interval Combobox
#----------------------------------------------
. "$Dependencies\Code\System.Windows.Forms\Combobox\OptionStatisticsUpdateIntervalComboBox.ps1"
$OptionStatisticsUpdateIntervalCombobox = New-Object System.Windows.Forms.Combobox -Property @{
    Text     = 5
    Location = @{ X = 3
                  Y = $OptionJobTimeoutSelectionComboBox.Location.Y + $OptionJobTimeoutSelectionComboBox.Size.Height + 5 }
    Size     = @{ Width  = 50
                  Height = 22 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    Add_MouseHover = $OptionStatisticsUpdateIntervalComboboxAdd_MouseHover
}
$StatisticsTimesAvailable = @(1,5,10,15,30,45,60)
ForEach ($Item in $StatisticsTimesAvailable) { $OptionStatisticsUpdateIntervalCombobox.Items.Add($Item) }
$Section2OptionsTab.Controls.Add($OptionStatisticsUpdateIntervalCombobox)


#-------------------------------------------
# Option - Statistics Update Interval Label
#-------------------------------------------
$OptionStatisticsUpdateIntervalLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "Statistics Update Interval"
    Location = @{ X = $OptionStatisticsUpdateIntervalCombobox.Size.Width + 10
                  Y = $OptionStatisticsUpdateIntervalCombobox.Location.Y + 3 }
    Size     = @{ Width  = 200
                  Height = 22 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$Section2OptionsTab.Controls.Add($OptionStatisticsUpdateIntervalLabel)


#------------------------------------------------------------------
# Option - Search Computers for Previously Collected Data Groupbox
#------------------------------------------------------------------
$OptionSearchComputersForPreviouslyCollectedDataProcessesCheckBox = New-Object System.Windows.Forms.Groupbox -Property @{
    Text     = "Search Computers for Previously Collected Data"
    Location = @{ X = 3
                  Y = $OptionStatisticsUpdateIntervalCombobox.Location.Y + $OptionStatisticsUpdateIntervalCombobox.Size.Height + 5 }
    Size     = @{ Width  = 352
                  Height = 97 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$Section2OptionsTab.Controls.Add($OptionSearchComputersForPreviouslyCollectedDataProcessesCheckBox)


    #---------------------------------------------------------
    # Option - Collected Data Directory Search Limit Combobox
    #---------------------------------------------------------
    . "$Dependencies\Code\System.Windows.Forms\ComboBox\CollectedDataDirectorySearchLimitComboBox.ps1"
    $CollectedDataDirectorySearchLimitComboBox = New-Object System.Windows.Forms.Combobox -Property @{
        Text     = 50
        Location = @{ X = 10
                      Y = 15 }
        Size     = @{ Width  = 50
                      Height = 22 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        Add_MouseHover = $CollectedDataDirectorySearchLimitComboBoxAdd_MouseHover
    }
    $NumberOfDirectoriesToSearchBack = @(25,50,100,150,200,250,500,750,1000)
    ForEach ($Item in $NumberOfDirectoriesToSearchBack) { $CollectedDataDirectorySearchLimitComboBox.Items.Add($Item) }


    #------------------------------------------------------
    # Option - Collected Data Directory Search Limit Label
    #------------------------------------------------------
    $CollectedDataDirectorySearchLimitLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Number of Past Directories to Search"
        Location = @{ X = $CollectedDataDirectorySearchLimitCombobox.Size.Width + 10
                      Y = $CollectedDataDirectorySearchLimitCombobox.Location.Y + 3 }
        Size     = @{ Width  = 200
                      Height = 22 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }

    
    #------------------------------------
    # Option - Search Processes Checkbox
    #------------------------------------
    $OptionSearchProcessesCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
        Text     = "Processes"
        Location = @{ X = 10
                      Y = $CollectedDataDirectorySearchLimitCombobox.Location.Y + $CollectedDataDirectorySearchLimitCombobox.Size.Height + 0 }
        Size     = @{ Width  = 200
                      Height = 20 }
        Enabled  = $true
        Checked  = $False
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }

    
    #-----------------------------------
    # Option - Search Services Checkbox
    #-----------------------------------
    $OptionSearchServicesCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
        Text     = "Services"
        Location = @{ X = 10
                      Y = $OptionSearchProcessesCheckBox.Location.Y + $OptionSearchProcessesCheckBox.Size.Height + 0 }
        Size     = @{ Width  = 200
                      Height = 20 }
        Enabled  = $true
        Checked  = $False
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }

    
    #--------------------------------------------------
    # Option - Search Network TCP Connections Checkbox
    #--------------------------------------------------
    $OptionSearchNetworkTCPConnectionsCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
        Text     = "Network TCP Connections"
        Location = @{ X = 10
                      Y = $OptionSearchServicesCheckBox.Location.Y + $OptionSearchServicesCheckBox.Size.Height - 1 }
        Size     = @{ Width  = 200
                      Height = 20 }
        Enabled  = $true
        Checked  = $False
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
$OptionSearchComputersForPreviouslyCollectedDataProcessesCheckBox.Controls.AddRange(@($OptionSearchProcessesCheckBox,$OptionSearchServicesCheckBox,$OptionSearchNetworkTCPConnectionsCheckBox,$CollectedDataDirectorySearchLimitCombobox,$CollectedDataDirectorySearchLimitLabel))


#--------------------------
# Option -  GUI Top Window
#--------------------------
. "$Dependencies\Code\System.Windows.Forms\CheckBox\OptionGUITopWindowCheckBox.ps1"
$OptionGUITopWindowCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
    Text     = "GUI always on top"
    Location = @{ X = 3
                  Y = $OptionSearchComputersForPreviouslyCollectedDataProcessesCheckBox.Location.Y + $OptionSearchComputersForPreviouslyCollectedDataProcessesCheckBox.Size.Height + 2 }
    Size     = @{ Width  = 300
                  Height = $Column3BoxHeight }
    Enabled  = $true
    Checked  = $false
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    Add_Click = $OptionGUITopWindowCheckBoxAdd_Click
}
$Section2OptionsTab.Controls.Add( $OptionGUITopWindowCheckBox )


#-------------------------------------
# Option -  Autosave Charts As Images
#-------------------------------------
. "$Dependencies\Code\System.Windows.Forms\Checkbox\OptionsAutoSaveChartsAsImages.ps1"
$OptionsAutoSaveChartsAsImages = New-Object System.Windows.Forms.Checkbox -Property @{
    Text     = "Autosave Charts As Images"
    Location = @{ X = 3
                  Y = $OptionGUITopWindowCheckBox.Location.Y + $OptionGUITopWindowCheckBox.Size.Height + 0 }
    Size     = @{ Width  = 300
                  Height = $Column3BoxHeight }
    Enabled  = $true
    Checked  = $false
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    Add_Click      = $OptionsAutoSaveChartsAsImagesAdd_Click
    Add_MouseHover = $OptionsAutoSaveChartsAsImagesAdd_MouseHover
}
$Section2OptionsTab.Controls.Add( $OptionsAutoSaveChartsAsImages )


#-----------------------
# Option - Show ToolTip
#-----------------------
$OptionShowToolTipCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
    Text     = "Show ToolTip"
    Location = @{ X = 3
                  Y = $OptionsAutoSaveChartsAsImages.Location.Y + $OptionsAutoSaveChartsAsImages.Size.Height + 0 }
    Size     = @{ Width  = 200 
                  Height = $Column3BoxHeight }
    Enabled  = $true
    Checked  = $true
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
if ($DisableToolTip) {$OptionShowToolTipCheckBox.Checked = $False}
$Section2OptionsTab.Controls.Add($OptionShowToolTipCheckBox)


#--------------------------------------
# Option - Text To Speach/TTS Checkbox
#--------------------------------------
$OptionTextToSpeachCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
    Text     = "Audible Completion Message"
    Location = @{ X = 3
                  Y = $OptionShowToolTipCheckBox.Location.Y + $OptionShowToolTipCheckBox.Size.Height + 0 }
    Size     = @{ Width  = 200
                  Height = $Column3BoxHeight }
    Enabled  = $true
    Checked  = $false
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
# Cmdlet Parameter Option
if ($AudibleCompletionMessage) {$OptionTextToSpeachCheckBox.Checked = $True}
$Section2OptionsTab.Controls.Add($OptionTextToSpeachCheckBox)

#=======================================================================================================================================================================
#
#  Parent: Main Form -> Main Center TabControl
#   ____   _          _    _       _    _                _____       _      ____                     
#  / ___| | |_  __ _ | |_ (_) ___ | |_ (_)  ___  ___    |_   _|__ _ | |__  |  _ \  __ _   __ _   ___ 
#  \___ \ | __|/ _` || __|| |/ __|| __|| | / __|/ __|     | | / _` || '_ \ | |_) |/ _` | / _` | / _ \
#   ___) || |_| (_| || |_ | |\__ \| |_ | || (__ \__ \     | || (_| || |_) ||  __/| (_| || (_| ||  __/
#  |____/  \__|\__,_| \__||_||___/ \__||_| \___||___/     |_| \__,_||_.__/ |_|    \__,_| \__, | \___|
#                                                                                        |___/       
#=======================================================================================================================================================================

$Section2StatisticsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text                    = "Statistics"
    Name                    = "Statistics"
    Font                    = New-Object System.Drawing.Font("$Font",10,0,0,0)
    UseVisualStyleBackColor = $True
}
$MainCenterTabControl.Controls.Add($Section2StatisticsTab)

# Gets various statistics on PoSh-EasyWin such as number of queries and computer treenodes selected, and
# the number number of csv files and data storage consumed
. "$Dependencies\Code\Execution\Get-PoShEasyWinStatistics.ps1"
$StatisticsResults = Get-PoShEasyWinStatistics


#---------------------
# Statistics - Button
#---------------------
. "$Dependencies\Code\System.Windows.Forms\Button\StatisticsRefreshButton.ps1"
$StatisticsRefreshButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Refresh"
    Location = @{ X = 2
                  Y = 5 }
    Size     = @{ Width  = 100
                  Height = 22 }
    Add_Click = $StatisticsRefreshButtonAdd_Click
}
$Section2StatisticsTab.Controls.Add($StatisticsRefreshButton)
CommonButtonSettings -Button $StatisticsRefreshButton


#------------------------------------------
# Option - Computer List - View Log Button
#------------------------------------------
. "$Dependencies\Code\System.Windows.Forms\Button\StatisticsViewLogButton.ps1"
$StatisticsViewLogButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "View Log"
    Location = @{ X = 258
                  Y = 5 }
    Size     = @{ Width  = 100
                  Height = 22 }
    Add_Click      = $StatisticsViewLogButtonAdd_Click
    Add_MouseHover = $StatisticsViewLogButtonAdd_MouseHover
}
$Section2StatisticsTab.Controls.Add($StatisticsViewLogButton)
CommonButtonSettings -Button $StatisticsViewLogButton


#----------------------
# Statistics - Textbox
#----------------------
$StatisticsNumberOfCSVs = New-Object System.Windows.Forms.Textbox -Property @{
    Text       = $StatisticsResults
    Location = @{ X = 3
                  Y = 32 }
    Size     = @{ Width  = 354
                  Height = 215 }
    Font       = New-Object System.Drawing.Font("Courier new",11,0,0,0)
    Multiline  = $true
    Enabled    = $true
}
$Section2StatisticsTab.Controls.Add($StatisticsNumberOfCSVs)

#============================================================================================================================================================
#============================================================================================================================================================
# ComputerList Treeview Section
#============================================================================================================================================================
#============================================================================================================================================================

$Column4RightPosition     = 845
$Column4DownPosition      = 11
$Column4BoxWidth          = 220
$Column4BoxHeight         = 22
$Column4DownPositionShift = 25

# Initial load of CSV data
$script:ComputerTreeViewData = $null
$script:ComputerTreeViewData = Import-Csv $ComputerTreeNodeFileSave -ErrorAction SilentlyContinue #| Select-Object -Property Name, OperatingSystem, CanonicalName, IPv4Address, MACAddress, Notes
#$script:ComputerTreeViewData

# Saves the textbox data for Host Data
. "$Dependencies\Code\Main Body\Save-HostData.ps1"

# Auto saves the textbox data for Host Data, only useful is script freezes for some reason and then the main saved files is removed manually
. "$Dependencies\Code\Main Body\AutoSave-HostData.ps1"

# Initializes the Computer TreeView section that computer nodes are added to
# TreeView initialization initially happens upon load and whenever the it is regenerated, like when switching between views 
# These include the root nodes of Search, and various Operating System and OU/CN names 
. "$Dependencies\Code\Tree View\Computer\Initialize-ComputerTreeNodes.ps1"

# If Computer treenodes are imported/created with missing data, this populates various fields with default data
. "$Dependencies\Code\Tree View\Computer\Populate-ComputerTreeNodeDefaultData.ps1"

# This will keep the Computer TreeNodes checked when switching between OS and OU/CN views
. "$Dependencies\Code\Tree View\Computer\KeepChecked-ComputerTreeNode.ps1"

# Adds a treenode to the specified root node... a computer node within a category node
. "$Dependencies\Code\Tree View\Computer\Add-ComputerTreeNode.ps1"

$script:ComputerTreeViewSelected = ""

# Populate Auto Tag List used for Host Data tagging and Searching
$TagListFileContents = Get-Content -Path $TagAutoListFile

# Searches for Computer nodes that match a given search entry
# A new category node named by the search entry will be created and all results will be nested within
. "$Dependencies\Code\Tree View\Computer\Search-ComputerTreeNode.ps1"


#----------------------------------------
# ComputerList TreeView - Search TextBox
#----------------------------------------
. "$Dependencies\Code\System.Windows.Forms\ComboBox\ComputerTreeNodeSearchComboBox.ps1"
$ComputerTreeNodeSearchComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Name     = "Search TextBox"
    Location = @{ X = $Column4RightPosition
                  Y = 25 }
    Size     = @{ Width  = 172
                  Height = 25 }
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
    Font               = New-Object System.Drawing.Font("$Font",11,0,0,0)
    Add_KeyDown        = $ComputerTreeNodeSearchComboBoxAdd_KeyDown 
    Add_MouseHover     = $ComputerTreeNodeSearchComboBoxAdd_MouseHover
}
ForEach ($Tag in $TagListFileContents) { [void] $ComputerTreeNodeSearchComboBox.Items.Add($Tag) }
$PoShEasyWin.Controls.Add($ComputerTreeNodeSearchComboBox)


#---------------------------------------
# ComputerList TreeView - Search Button
#---------------------------------------
. "$Dependencies\Code\System.Windows.Forms\Button\ComputerTreeNodeSearchButton.ps1"
$ComputerTreeNodeSearchButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Search"
    Location = @{ X = $Column4RightPosition + 176
                  Y = 24 }
    Size     = @{ Width  = 55
                  Height = 22 }
    Add_Click      = $ComputerTreeNodeSearchButtonAdd_Click
    Add_MouseHover = $ComputerTreeNodeSearchButtonAdd_MouseHover
}
$PoShEasyWin.Controls.Add($ComputerTreeNodeSearchButton)
CommonButtonSettings -Button $ComputerTreeNodeSearchButton


# Code to remove empty categoryies
. "$Dependencies\Code\Tree View\Computer\Remove-EmptyCategory.ps1"
Remove-EmptyCategory


$ComputerListContextMenuStrip = New-Object System.Windows.Forms.ContextMenuStrip -Property @{
    ShowCheckMargin = $false
    ShowImageMargin = $false
    ShowItemToolTips = $True
    Width    = 100
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = 'Black'
}
        $ComputerListRenameToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
            Text      = "Select an Endpoint"
            Font      = New-Object System.Drawing.Font("$Font",11,1,2,1)
            ForeColor = 'Blue'
        }
        $ComputerListContextMenuStrip.Items.Add($ComputerListRenameToolStripLabel)
        $ComputerListContextMenuStrip.Items.Add('-')

        $ComputerListRenameToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
            Text      = "Left-Click an Endpoint Node,`r`nthen Right-Click for more Options"
            ForeColor = 'DarkRed'
        }
        $ComputerListContextMenuStrip.Items.Add($ComputerListRenameToolStripLabel)

        . "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListCollapseToolStripButton.ps1"
        $ComputerListCollapseToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
            Text      = "Collapse"
            Add_CLick = $ComputerListCollapseToolStripButtonAdd_Click
        }
        $ComputerListContextMenuStrip.Items.Add($ComputerListCollapseToolStripButton)

        . "$Dependencies\Code\Tree View\Computer\Message-HostAlreadyExists.ps1"
        . "$Dependencies\Code\Tree View\Computer\AddHost-ComputerTreeNode.ps1"
        . "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListAddEndpointToolStripButton.ps1"
        $ComputerListAddEndpointToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
            Text      = "Add Endpoint"
            Add_CLick = $ComputerListAddEndpointToolStripButtonAdd_Click
        }
        $ComputerListContextMenuStrip.Items.Add($ComputerListAddEndpointToolStripButton)

        $ComputerListContextMenuStrip.Items.Add('-')

        $ComputerListRenameToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
            Text      = 'Checked Endpoints'
            Font      = New-Object System.Drawing.Font("$Font",11,1,2,1)
            ForeColor = 'Blue'
        }
        $ComputerListContextMenuStrip.Items.Add($ComputerListRenameToolStripLabel)
        $ComputerListContextMenuStrip.Items.Add('-')

        . "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListDeselectAllToolStripButton.ps1"
        $ComputerListDeselectAllToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
            Text      = "Uncheck All"
            Add_CLick = $ComputerListDeselectAllToolStripButtonAdd_Click
        }
        $ComputerListContextMenuStrip.Items.Add($ComputerListDeselectAllToolStripButton)

        . "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListTagToolStripButton.ps1"
        $ComputerListMassTagToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
            Text      = "Tag All"
            Add_CLick = $ComputerListTagAllCheckedToolStripButtonAdd_Click
        }
        $ComputerListContextMenuStrip.Items.Add($ComputerListMassTagToolStripButton)

        . "$Dependencies\Code\Tree View\Computer\Move-ComputerTreeNodeSelected.ps1"
        . "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListMoveToolStripButton.ps1"
        $ComputerListMoveToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
            Text      = "Move All"
            Add_CLick = $ComputerListMoveAllCheckedToolStripButtonAdd_Click
        }
        $ComputerListContextMenuStrip.Items.Add($ComputerListMoveToolStripButton)
       
        . "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListDeleteToolStripButton.ps1"
        $ComputerListDeleteToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
            Text      = "Delete All"
            Add_CLick = $ComputerListDeleteAllCheckedToolStripButtonAdd_Click
        }
        $ComputerListContextMenuStrip.Items.Add($ComputerListDeleteToolStripButton)

        # The following are used within Conduct-TreeNodeAction via the ContextMenuStips
        # They're placed here to be loaded once, rather than multiple times 
        . "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListRenameToolStripButton.ps1"











function Display-ContextMenu {
    Create-ComputerNodeCheckBoxArray

    $ComputerListContextMenuStrip.Items.Remove($ComputerListRenameToolStripButton)
    $ComputerListContextMenuStrip = New-Object System.Windows.Forms.ContextMenuStrip -Property @{
        ShowCheckMargin = $false
        ShowImageMargin = $false
        ShowItemToolTips = $True
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = 'Black'
    }

    #$ComputerListContextMenuStrip.Items.Add("$($Entry.Text)")
    $ComputerListRenameToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
        Text      = "$($Entry.Text)"
        Font      = New-Object System.Drawing.Font("$Font",11,1,2,1)
        ForeColor = 'Blue'
    }
    $ComputerListContextMenuStrip.Items.Add($ComputerListRenameToolStripLabel)
      
    #$comboBoxMenuItem = New-Object System.Windows.Forms.ToolStripComboBox
    #$comboBoxMenuItem.Items.Add('Option 1')
    #$comboBoxMenuItem.Items.Add('Option 2')
    #$ComputerListContextMenuStrip.Items.Add($comboBoxMenuItem)

    $ComputerListContextMenuStrip.Items.Add('-')

    $script:ExpandCollapseStatus = "Collapse"
    $ComputerListCollapseToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
        Text      = "Collapse"
        Add_CLick = $ComputerListCollapseToolStripButtonAdd_Click
    }
    $ComputerListContextMenuStrip.Items.Add($ComputerListCollapseToolStripButton)

    $ComputerListTagSelectedToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
        Text      = "Tag"
        Add_CLick = $ComputerListTagSelectedToolStripButtonAdd_Click
    }
    $ComputerListContextMenuStrip.Items.Add($ComputerListTagSelectedToolStripButton)

    $ComputerListAddEndpointToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
        Text      = "Add Endpoint"
        Add_CLick = $ComputerListAddEndpointToolStripButtonAdd_Click
    }
    $ComputerListContextMenuStrip.Items.Add($ComputerListAddEndpointToolStripButton)

    $ComputerListRenameToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
        Text      = "Rename"
        Add_CLick = $ComputerListRenameToolStripButtonAdd_Click
    }
    $ComputerListContextMenuStrip.Items.Add($ComputerListRenameToolStripButton)
    
    $ComputerListMoveToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
        Text      = "Move"
        Add_CLick = $ComputerListMoveSelectedToolStripButtonAdd_Click
    }
    $ComputerListContextMenuStrip.Items.Add($ComputerListMoveToolStripButton)

    $ComputerListDeleteSelectedToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
        #Text      = "Delete:  $($script:EntrySelected.text)"
        Text      = "Delete"
        Add_CLick = $ComputerListDeleteSelectedToolStripButtonAdd_Click
    }
    $ComputerListContextMenuStrip.Items.Add($ComputerListDeleteSelectedToolStripButton)

    

    if ($script:ComputerTreeViewSelected.count -gt 0) {
        $ComputerListContextMenuStrip.Items.Add('-')
        #$ComputerListContextMenuStrip.Items.Add('Checked Endpoints')
        $ComputerListRenameToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
            Text      = 'Checked Endpoints'
            Font      = New-Object System.Drawing.Font("$Font",11,1,2,1)
            ForeColor = 'Blue'
        }
        $ComputerListContextMenuStrip.Items.Add($ComputerListRenameToolStripLabel)
        $ComputerListContextMenuStrip.Items.Add('-')
    
        $ComputerListDeselectAllToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
            Text      = "Uncheck All"
            Add_CLick = $ComputerListDeselectAllToolStripButtonAdd_Click
        }
        $ComputerListContextMenuStrip.Items.Add($ComputerListDeselectAllToolStripButton)

        $ComputerListTagAllCheckedToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
            Text      = "Tag All"
            Add_CLick = $ComputerListTagAllCheckedToolStripButtonAdd_Click
        }
        $ComputerListContextMenuStrip.Items.Add($ComputerListTagAllCheckedToolStripButton)

        $ComputerListMoveToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
            Text      = "Move All"
            Add_CLick = $ComputerListMoveAllCheckedToolStripButtonAdd_Click
        }
        $ComputerListContextMenuStrip.Items.Add($ComputerListMoveToolStripButton)

        $ComputerListDeleteAllCheckedToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
            Text      = "Delete All"
            Add_CLick = $ComputerListDeleteAllCheckedToolStripButtonAdd_Click
        }
        $ComputerListContextMenuStrip.Items.Add($ComputerListDeleteAllCheckedToolStripButton)
    }

    $Entry.ContextMenuStrip = $ComputerListContextMenuStrip
}
















Display-ContextMenu

#-----------------------------
# ComputerList Treeview Nodes
#-----------------------------
# Ref Guide: https://info.sapien.com/index.php/guis/gui-controls/spotlight-on-the-contextmenustrip-control
. "$Dependencies\Code\System.Windows.Forms\TreeView\ComputerTreeView.ps1"
$script:ComputerTreeView = New-Object System.Windows.Forms.TreeView -Property @{
    size              = @{ Width = 230
                           Height = 308 }
    Location          = @{ X = $Column4RightPosition ; Y = $Column4DownPosition + 39 }
    Font              = New-Object System.Drawing.Font("$Font",11,0,0,0)
    CheckBoxes        = $True
    #LabelEdit         = $True  #Not implementing yet...
    ShowLines         = $True
    ShowNodeToolTips  = $True
    Add_Click         = $ComputerTreeViewAdd_Click
    Add_AfterSelect   = $ComputerTreeViewAdd_AfterSelect
    Add_MouseHover    = $ComputerTreeViewAdd_MouseHover
    #Add_MouseEnter    = $ComputerTreeViewAdd_MouseEnter
    Add_MouseLeave    = $ComputerTreeViewAdd_MouseLeave
    #ShortcutsEnabled  = $false                                #Used for ContextMenuStrip
    ContextMenuStrip  = $ComputerListContextMenuStrip      #Ref Add_click
}
$script:ComputerTreeView.Sort()
$PoShEasyWin.Controls.Add($script:ComputerTreeView)


#---------------------------------------
# ComputerList TreeView - Radio Buttons
#---------------------------------------
# Default View
Initialize-ComputerTreeNodes
Populate-ComputerTreeNodeDefaultData

# Yes, this save initially during load because it will save the poulated default data
Save-HostData

# This will load data that is located in the saved file
Foreach($Computer in $script:ComputerTreeViewData) {
    Add-ComputerTreeNode -RootNode $script:TreeNodeComputerList -Category $Computer.OperatingSystem -Entry $Computer.Name -ToolTip $Computer.IPv4Address
}
$script:ComputerTreeView.Nodes.Add($script:TreeNodeComputerList)
$script:ComputerTreeView.ExpandAll()


#-----------------------------------
# View hostname/IPs by: OS or OU/CN
#-----------------------------------
$ComputerTreeNodeViewByLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "View by:"
    Location = @{ X = $Column4RightPosition
                  Y = 7 }
    Size     = @{ Width  = 75
                  Height = 25 }
    Font     = New-Object System.Drawing.Font("$Font",11,1,2,1)
}
$PoShEasyWin.Controls.Add($ComputerTreeNodeViewByLabel)

. "$Dependencies\Code\System.Windows.Forms\RadioButton\ComputerTreeNodeOSHostnameRadioButton.ps1"
$script:ComputerTreeNodeOSHostnameRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
    Text     = "OS"
    Location = @{ X = $ComputerTreeNodeViewByLabel.Location.X + $ComputerTreeNodeViewByLabel.Size.Width
                  Y = $ComputerTreeNodeViewByLabel.Location.Y - 5 }
    Size     = @{ Height = 25
                  Width  = 50 }
    Checked  = $True
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    Add_Click      = $script:ComputerTreeNodeOSHostnameRadioButtonAdd_Click
    Add_MouseHover = $script:ComputerTreeNodeOSHostnameRadioButtonAdd_MouseHover
}
$PoShEasyWin.Controls.Add($script:ComputerTreeNodeOSHostnameRadioButton)

. "$Dependencies\Code\System.Windows.Forms\RadioButton\ComputerTreeNodeOUHostnameRadioButton.ps1"
$ComputerTreeNodeOUHostnameRadioButton  = New-Object System.Windows.Forms.RadioButton -Property @{
    Text     = "OU / CN"
    Location = @{ X = $script:ComputerTreeNodeOSHostnameRadioButton.Location.X + $script:ComputerTreeNodeOSHostnameRadioButton.Size.Width + 5
                  Y = $script:ComputerTreeNodeOSHostnameRadioButton.Location.Y }
    Size     = @{ Height = 25
                  Width  = 75 }
    Checked  = $false
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    Add_Click      = $ComputerTreeNodeOUHostnameRadioButtonAdd_Click 
    Add_MouseHover = $ComputerTreeNodeOUHostnameRadioButtonAdd_MouseHover
}
$PoShEasyWin.Controls.Add($ComputerTreeNodeOUHostnameRadioButton)


#============================================================================================================================================================
#
#  Parent: Main Form
#   __  __         _            ____   _         _      _       _____       _       ____               _                _ 
#  |  \/  |  __ _ (_) _ __     |  _ \ (_)  __ _ | |__  | |_    |_   _|__ _ | |__   / ___| ___   _ __  | |_  _ __  ___  | |
#  | |\/| | / _` || || '_ \    | |_) || | / _` || '_ \ | __|     | | / _` || '_ \ | |    / _ \ | '_ \ | __|| '__|/ _ \ | |
#  | |  | || (_| || || | | |   |  _ < | || (_| || | | || |_      | || (_| || |_) || |___| (_) || | | || |_ | |  | (_) || |
#  |_|  |_| \__,_||_||_| |_|   |_| \_\|_| \__, ||_| |_| \__|     |_| \__,_||_.__/  \____|\___/ |_| |_| \__||_|   \___/ |_|
#
#============================================================================================================================================================

$MainRightTabControl = New-Object System.Windows.Forms.TabControl -Property @{
    Name         = "Main Tab Window for Computer List"
    Location     = @{ X = 1082 
                      Y = 10 }
    Size         = @{ Height = 349
                      Width  = 140 }
    ShowToolTips = $True
    Font         = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$PoShEasyWin.Controls.Add($MainRightTabControl)

#=======================================================================================================================================================================
#
#  Parent: Main Form -> Main Right TabControl
#      _          _    _                   _____       _      ____                     
#     / \    ___ | |_ (_)  ___   _ __     |_   _|__ _ | |__  |  _ \  __ _   __ _   ___ 
#    / _ \  / __|| __|| | / _ \ | '_ \      | | / _` || '_ \ | |_) |/ _` | / _` | / _ \
#   / ___ \| (__ | |_ | || (_) || | | |     | || (_| || |_) ||  __/| (_| || (_| ||  __/
#  /_/   \_\\___| \__||_| \___/ |_| |_|     |_| \__,_||_.__/ |_|    \__,_| \__, | \___|
#                                                                       |___/       
#=======================================================================================================================================================================

$Column5RightPosition     = 3
$Column5DownPositionStart = 6
$Column5DownPosition      = 6
$Column5DownPositionShift = 28
$Column5BoxWidth          = 124
$Column5BoxHeight         = 22

. "$Dependencies\Code\Tree View\Computer\Create-ComputerNodeCheckBoxArray.ps1"
. "$Dependencies\Code\Tree View\Computer\ComputerNodeSelectedLessThanOne.ps1"
. "$Dependencies\Code\Tree View\Computer\ComputerNodeSelectedMoreThanOne.ps1"
. "$Dependencies\Code\Tree View\Computer\Verify-Action.ps1"

$Section3ActionTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text     = "Action"
    Location = @{ X = $Column5RightPosition
                  Y = $Column5DownPosition }
    Size     = @{ Height = $Column5BoxWidth
                  Width  = $Column5BoxHeight }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    UseVisualStyleBackColor = $True
}
$MainRightTabControl.Controls.Add($Section3ActionTab)


# This function is the base code for testing various connections with remote computers
. "$Dependencies\Code\Execution\Action\Check-Connection.ps1"


#-----------------------------
# Computer List - Ping Button
#-----------------------------

. "$Dependencies\Code\System.Windows.Forms\Button\ComputerListPingButton.ps1"
$ComputerListPingButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "Ping"
    Location  = @{ X = $Column5RightPosition
                   Y = $Column5DownPosition }
    Size      = @{ Height = $Column5BoxHeight 
                   Width  = $Column5BoxWidth }
    Add_Click = $ComputerListPingButtonAdd_Click 
    Add_MouseHover = $ComputerListPingButtonAdd_MouseHover
}
$Section3ActionTab.Controls.Add($ComputerListPingButton) 
CommonButtonSettings -Button $ComputerListPingButton

$Column5DownPosition += $Column5DownPositionShift


#------------------------------------------
# Computer List - WinRM Check (Test-WSMan)
#------------------------------------------
. "$Dependencies\Code\System.Windows.Forms\Button\ComputerListWinRMCheckButton.ps1"
$ComputerListWinRMCheckButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "WinRM Check"
    Location  = @{ X = $Column5RightPosition
                   Y = $Column5DownPosition }
    Size      = @{ Width  = $Column5BoxWidth
                   Height = $Column5BoxHeight }
    Add_Click = $ComputerListWinRMCheckButtonAdd_Click
    Add_MouseHover = $ComputerListWinRMCheckButtonAdd_MouseHover
}
$Section3ActionTab.Controls.Add($ComputerListWinRMCheckButton) 
CommonButtonSettings -Button $ComputerListWinRMCheckButton

$Column5DownPosition += $Column5DownPositionShift


#--------------------------------------
# Computer List - RPC Check (Port 135)
#--------------------------------------
. "$Dependencies\Code\System.Windows.Forms\Button\ComputerListRPCCheckButton.ps1"
$ComputerListRPCCheckButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "RPC Check"
    Location  = @{ X = $Column5RightPosition
                   Y = $Column5DownPosition }
    Size      = @{ Width  = $Column5BoxWidth
                   Height = $Column5BoxHeight }
    Add_Click = $ComputerListRPCCheckButtonAdd_Click
    Add_MouseHover = $ComputerListRPCCheckButtonAdd_MouseHover
}
$Section3ActionTab.Controls.Add($ComputerListRPCCheckButton) 
CommonButtonSettings -Button $ComputerListRPCCheckButton

$Column5DownPosition += $Column5DownPositionShift

<#

# WORK IN PROGRESS, NOT READY FOR PRIME TIME, STILL WORKING OUT THE KINKS

#------------------------------------------
# Memory Capture - Button (Rekall WinPmem)
#------------------------------------------

# Used to verify settings before capturing memory as this can be quite resource exhaustive
# Contains various checks to ensure that adequate resources are available on the remote and local hosts
. "$Dependencies\Code\Execution\Action\Launch-RekallWinPmemForm.ps1"

#----------------------------------------
# Rekall WinPmem - Memory Capture Button
#----------------------------------------
$RekallWinPmemMemoryCaptureButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "Memory Capture"
    Location  = @{ X = $Column5RightPosition
                   Y = $Column5DownPosition }
    Size      = @{ Width  = $Column5BoxWidth
                   Height = $Column5BoxHeight  }
}
CommonButtonSettings -Button $RekallWinPmemMemoryCaptureButton

$RekallWinPmemMemoryCaptureButton.Add_MouseHover({
    Show-ToolTip -Title "Memory Capture" -Icon "Info" -Message @"
+  Uses Rekall WinPmep to retrieve memory for analysis. 
+  The memory.raw file collected can be used with Volatility or windbg. 
+  It supports all windows versions from WinXP SP2 to Windows 10.
+  It supports processor types: i386 and amd64.
+  Uses RPC/DCOM `n`n
"@ })
$RekallWinPmemMemoryCaptureButton.add_click({ 
    # This brings specific tabs to the forefront/front view
    $MainBottomTabControl.SelectedTab = $Section3ResultsTab
    
    # Ensures only one endpoint is selected
    # This array stores checkboxes that are check; a minimum of at least one checkbox will be needed later in the script
    $script:ComputerTreeViewSelected = @()
    [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerTreeView.Nodes 
    foreach ($root in $AllHostsNode) { 
        if ($root.Checked) {
            foreach ($Category in $root.Nodes) { foreach ($Entry in $Category.nodes) { $script:ComputerTreeViewSelected += $Entry.Text } }
        }
        foreach ($Category in $root.Nodes) {
            if ($Category.Checked) {
                foreach ($Entry in $Category.nodes) { $script:ComputerTreeViewSelected += $Entry.Text }
            }
            foreach ($Entry in $Category.nodes) {
                if ($Entry.Checked) {
                    $script:ComputerTreeViewSelected += $Entry.Text
                }
            }
        }
    }
    $ResultsListBox.Items.Clear()
    if ($script:ComputerTreeViewSelected.count -eq 1) {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Rekall WinPMem:  $($script:ComputerTreeViewSelected)")
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Launching Memory Collection Window")
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Launched Memory Collection Window"
        Launch-RekallWinPmemForm
    }
    elseif ($script:ComputerTreeViewSelected.count -lt 1) { ComputerNodeSelectedLessThanOne -Message 'Rekall WinPmem' }
    elseif ($script:ComputerTreeViewSelected.count -gt 1) { ComputerNodeSelectedMoreThanOne -Message 'Rekall WinPmem' }
})

# Test if the External Programs directory is present; if it's there load the tab
if (Test-Path "$ExternalPrograms\WinPmem.exe") { $Section3ActionTab.Controls.Add($RekallWinPmemMemoryCaptureButton) }
#>

#$Column5DownPosition += $Column5DownPositionShift


#---------------------------------
# Computer List - EventLog Button
#---------------------------------
. "$Dependencies\Code\System.Windows.Forms\Button\EventViewerButton.ps1"
$EventViewerButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = 'Event Viewer'
    Location  = @{ X = $Column5RightPosition
                   Y = $Column5DownPosition }
    Size      = @{ Height = $Column5BoxHeight
                   Width  = $Column5BoxWidth }
    Add_Click = $EventViewerButtonAdd_Click
    Add_MouseHover = $EventViewerButtonAdd_MouseHover
}
$Section3ActionTab.Controls.Add($EventViewerButton) 
CommonButtonSettings -Button $EventViewerButton

$Column5DownPosition += $Column5DownPositionShift


#----------------------------
# Computer List - RDP Button
#----------------------------
. "$Dependencies\Code\System.Windows.Forms\Button\ComputerListRDPButton.ps1"
$ComputerListRDPButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = 'Remote Desktop'
    Location  = @{ X = $Column5RightPosition
                   Y = $Column5DownPosition }
    Size      = @{ Width  = $Column5BoxWidth
                   Height = $Column5BoxHeight }
    Add_Click = $ComputerListRDPButtonAdd_Click
    Add_MouseHover = $ComputerListRDPButtonAdd_MouseHover
}
$Section3ActionTab.Controls.Add($ComputerListRDPButton) 
CommonButtonSettings -Button $ComputerListRDPButton

$Column5DownPosition += $Column5DownPositionShift


#-----------------------------------
# Computer List - PS Session Button
#-----------------------------------
. "$Dependencies\Code\System.Windows.Forms\Button\ComputerListPSSessionButton.ps1"
$ComputerListPSSessionButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "PS Session"
    Location  = @{ X = $Column5RightPosition
                   Y = $Column5DownPosition }
    Size      = @{ Width  = $Column5BoxWidth
                   Height = $Column5BoxHeight }
    Add_Click = $ComputerListPSSessionButtonAdd_Click
    Add_MouseHover = $ComputerListPSSessionButtonAdd_MouseHover
}
$Section3ActionTab.Controls.Add($ComputerListPSSessionButton) 
CommonButtonSettings -Button $ComputerListPSSessionButton

$Column5DownPosition += $Column5DownPositionShift


#-------------------------------
# Computer List - PsExec Button
#-------------------------------
. "$Dependencies\Code\System.Windows.Forms\Button\ComputerListPsExecButton.ps1"
$ComputerListPsExecButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = 'PsExec'
    Location  = @{ X = $Column5RightPosition
                   Y = $Column5DownPosition }
    Size      = @{ Width  = $Column5BoxWidth
                   Height = $Column5BoxHeight }
    Add_Click = $ComputerListPsExecButtonAdd_Click
    Add_MouseHover = $ComputerListPsExecButtonAdd_MouseHover
}
CommonButtonSettings -Button $ComputerListPsExecButton

# Test if the External Programs directory is present; if it's there load the tab
if (Test-Path "$ExternalPrograms\PsExec.exe") { $Section3ActionTab.Controls.Add($ComputerListPsExecButton) }

$Column5DownPosition += $Column5DownPositionShift


#-------------------------------------------------
# Credential Management Functions for Credentials 
#-------------------------------------------------

# Rolls the credenaisl: 250 characters of random: abcdefghiklmnoprstuvwxyzABCDEFGHKLMNOPRSTUVWXYZ1234567890
. "$Dependencies\Code\Credential Management\Generate-NewRollingPassword.ps1" 

# Used to create new credentials (Get-Credential), create a log entry, and save an encypted local copy
. "$Dependencies\Code\Credential Management\Create-NewCredentials.ps1"
# Encrypt an exported credential object
# The Export-Clixml cmdlet encrypts credential objects by using the Windows Data Protection API.
# The encryption ensures that only your user account on only that computer can decrypt the contents of the 
# credential object. The exported CLIXML file can't be used on a different computer or by a different user.

. "$Dependencies\Code\System.Windows.Forms\Button\ProvideCredentialsButton.ps1"
$ProvideCredentialsButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Manage Credentials"
    Location = @{ X = $Column5RightPosition
                  Y = $Column5DownPosition }
    Size     = @{ Width  = $Column5BoxWidth
                  Height = $Column5BoxHeight }
    Add_Click = $ProvideCredentialsButtonAdd_Click
    Add_MouseHover = $ProvideCredentialsButtonAdd_MouseHover
}
$Section3ActionTab.Controls.Add($ProvideCredentialsButton)
CommonButtonSettings -Button $ProvideCredentialsButton

$Column5DownPosition += $Column5DownPositionShift - 2


#----------------------------------------
# Computer List - Provide Creds Checkbox
#----------------------------------------
. "$Dependencies\Code\System.Windows.Forms\CheckBox\ComputerListProvideCredentialsCheckBox.ps1"
$ComputerListProvideCredentialsCheckBox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Specify Credentials"
    Location = @{ X = $Column5RightPosition + 1
                  Y = $Column5DownPosition }
    Size     = @{ Width  = $Column5BoxWidth
                  Height = $Column5BoxHeight - 5 }
    Checked  = $false
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    Add_Click      = $ComputerListProvideCredentialsCheckBoxAdd_Click
    Add_MouseHover = $ComputerListProvideCredentialsCheckBoxAdd_MouseHover
}
$Section3ActionTab.Controls.Add($ComputerListProvideCredentialsCheckBox)

$Column5DownPosition += $Column5DownPositionShift


#--------------------------------------------------------
# Commands Treeview - Query As Individual - Radio Button
#--------------------------------------------------------
. "$Dependencies\Code\System.Windows.Forms\ComboBox\CommandTreeViewQueryMethodSelectionComboBox.ps1"
$CommandTreeViewQueryMethodSelectionComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Location = @{ X = $Column5RightPosition
                  Y = $Column5DownPosition }
    Size     = @{ Width  = $Column5BoxWidth
                  Height = 22 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = 'Black'
    DropDownStyle = 'DropDownList'
    Add_SelectedIndexChanged = $CommandTreeViewQueryMethodSelectionComboBoxAdd_SelectedIndexChanged
}
$QueryMethodSelectionList = @(
    'Individual Execution',
    'Compiled Script',
    'Session Based'
)
Foreach ($QueryMethod in $QueryMethodSelectionList) { $CommandTreeViewQueryMethodSelectionComboBox.Items.Add($QueryMethod) }
$CommandTreeViewQueryMethodSelectionComboBox.SelectedIndex = 2 #'Session Based'
$Section3ActionTab.Controls.Add($CommandTreeViewQueryMethodSelectionComboBox)

$Column5DownPosition += $Column5DownPositionShift + 2


#-----------------------------
# ComputerList Execute Button
#-----------------------------
. "$Dependencies\Code\System.Windows.Forms\Button\ComputerListExecuteButton.ps1"
$ComputerListExecuteButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "Execute Script"
    Location  = @{ X = $Column5RightPosition
                   Y = $Column5DownPosition  }
    Size      = @{ Width  = $Column5BoxWidth
                   Height = ($Column5BoxHeight * 2) - 10 }
    Enabled   = $true
    Add_MouseHover = $ComputerListExecuteButtonAdd_MouseHover
}
### $ComputerListExecuteButton.Add_Click($ExecuteScriptHandler) ### Is located lower in the script
$Section3ActionTab.Controls.Add($ComputerListExecuteButton)
CommonButtonSettings -Button $ComputerListExecuteButton


#=======================================================================================================================================================================
#
#  Parent: Main Form -> Main Right TabControl
#   __  __                                       _____       _      ____                     
#  |  \/  |  __ _  _ __    __ _   __ _   ___    |_   _|__ _ | |__  |  _ \  __ _   __ _   ___ 
#  | |\/| | / _` || '_ \  / _` | / _` | / _ \     | | / _` || '_ \ | |_) |/ _` | / _` | / _ \
#  | |  | || (_| || | | || (_| || (_| ||  __/     | || (_| || |_) ||  __/| (_| || (_| ||  __/
#  |_|  |_| \__,_||_| |_| \__,_| \__, | \___|     |_| \__,_||_.__/ |_|    \__,_| \__, | \___|
#                                |___/                                           |___/       
#=======================================================================================================================================================================

$Section3ManageListTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text      = "Manage List"
    Location  = @{ X = $Column5RightPosition
                   Y = $Column5DownPosition }
    Size      = @{ Width  = $Column5BoxWidth
                   Height = $Column5BoxHeight }
    UseVisualStyleBackColor = $True
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$MainRightTabControl.Controls.Add($Section3ManageListTab)

$Column5DownPosition = $Column5DownPositionStart

# Changes the Comoputer TreeView Save Button to Red
. "$Dependencies\Code\Tree View\Computer\Update-NeedToSaveTreeView.ps1"



#-------------------------------------------------------------
# ComputerList TreeView - Import From Active Directory Button
#-------------------------------------------------------------
. "$Dependencies\Code\System.Windows.Forms\Button\ComputerTreeNodeImportFromActiveDirectoryButton.ps1"
$ComputerTreeNodeImportFromActiveDirectoryButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "Import from AD"
    Location  = @{ X = $Column5RightPosition
                   Y = $Column5DownPosition }
    Size      = @{ Width  = $Column5BoxWidth
                   Height = $Column5BoxHeight }
    Add_Click = $ComputerTreeNodeImportFromActiveDirectoryButtonAdd_Click
}
$Section3ManageListTab.Controls.Add($ComputerTreeNodeImportFromActiveDirectoryButton)
CommonButtonSettings -Button $ComputerTreeNodeImportFromActiveDirectoryButton

$Column5DownPosition += $Column5DownPositionShift


#--------------------------------------------
# ComputerList TreeView - Import .csv Button
#--------------------------------------------
. "$Dependencies\Code\System.Windows.Forms\Button\ComputerTreeNodeImportCsvButton.ps1"
$ComputerTreeNodeImportCsvButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "Import from .CSV"
    Location  = @{ X = $Column5RightPosition
                   Y = $Column5DownPosition }
    Size      = @{ Width  = $Column5BoxWidth
                   Height = $Column5BoxHeight }
    Add_Click = $ComputerTreeNodeImportCsvButtonAdd_Click
}
$Section3ManageListTab.Controls.Add($ComputerTreeNodeImportCsvButton)
CommonButtonSettings -Button $ComputerTreeNodeImportCsvButton

$Column5DownPosition += $Column5DownPositionShift


#--------------------------------------------
# ComputerList TreeView - Import .txt Button
#--------------------------------------------
. "$Dependencies\Code\System.Windows.Forms\Button\ComputerTreeNodeImportTxtButton.ps1"
$ComputerTreeNodeImportTxtButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "Import from .TXT"
    Location  = @{ X = $Column5RightPosition
                   Y = $Column5DownPosition }
    Size      = @{ Width  = $Column5BoxWidth
                   Height = $Column5BoxHeight }
    Add_Click = $ComputerTreeNodeImportTxtButtonAdd_Click
}
$Section3ManageListTab.Controls.Add($ComputerTreeNodeImportTxtButton)
CommonButtonSettings -Button $ComputerTreeNodeImportTxtButton

$Column5DownPosition += $Column5DownPositionShift


#----------------------------------------
# Computer List - TreeView - Save Button
#----------------------------------------
. "$Dependencies\Code\System.Windows.Forms\Button\ComputerTreeNodeSaveButton.ps1"
$ComputerTreeNodeSaveButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "TreeView`r`nSaved"
    Location = @{ X = $Column5RightPosition
                  Y = $Column5DownPosition }
    Size     = @{ Width  = $Column5BoxWidth
                  Height = ($Column5BoxHeight * 2) - 10 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    Add_Click      = $ComputerTreeNodeSaveButtonAdd_Click
    Add_MouseHover = $ComputerTreeNodeSaveButtonAdd_MouseHover
}
$Section3ManageListTab.Controls.Add($ComputerTreeNodeSaveButton)
CommonButtonSettings -Button $ComputerTreeNodeSaveButton


#----------------
# Status LIstBox
#----------------
$StatusLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "Status:"
    Location = @{ X = 470
                  Y = 288 }
    Size     = @{ Width  = 60
                  Height = 20 }
    Font      = New-Object System.Drawing.Font("$Font",12,1,2,1)
    ForeColor = "Blue"
}
$PoShEasyWin.Controls.Add($StatusLabel)  

$StatusListBox = New-Object System.Windows.Forms.ListBox -Property @{
    Name     = "StatusListBox"
    Location = @{ X = $StatusLabel.Location.X + $StatusLabel.Size.Width
                  Y = $StatusLabel.Location.Y }
    Size     = @{ Width  = 310
                  Height = 22 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    FormattingEnabled = $True
}
$StatusListBox.Items.Add("Welcome to PoSh-EasyWin!") | Out-Null
$PoShEasyWin.Controls.Add($StatusListBox)


# ---------------
# Progress Bar 1 
#----------------
$ProgressBarEndpointsLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "Endpoint:"
    Location = @{ X = $StatusLabel.Location.X
                  Y = $StatusLabel.Location.Y + $StatusLabel.Size.Height }
    Size     = @{ Width  = $StatusLabel.Size.Width
                  Height = $StatusLabel.Size.Height }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$PoShEasyWin.Controls.Add($ProgressBarEndpointsLabel)  

$script:ProgressBarEndpointsProgressBar = New-Object System.Windows.Forms.ProgressBar -Property @{
    Location = @{ X = $ProgressBarEndpointsLabel.Location.X + $ProgressBarEndpointsLabel.Size.Width
                  Y = $ProgressBarEndpointsLabel.Location.Y }
    Size     = @{ Width  = $StatusListBox.Size.Width - 1
                  Height = 15 }
    Forecolor = 'LightBlue'
    BackColor = 'white'
    Style     = "Continuous" #"Marque" 
    Minimum   = 0
}
$PoSHEasyWin.Controls.Add($script:ProgressBarEndpointsProgressBar)


#----------------
# Progress Bar 2 
#----------------
$ProgressBarQueriesLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "Task:"
    Location = @{ X = $ProgressBarEndpointsLabel.Location.X
                  Y = $ProgressBarEndpointsLabel.Location.Y + $ProgressBarEndpointsLabel.Size.Height }
    Size     = @{ Width  = $ProgressBarEndpointsLabel.Size.Width
                  Height = $ProgressBarEndpointsLabel.Size.Height }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$PoShEasyWin.Controls.Add($ProgressBarQueriesLabel)  

$script:ProgressBarQueriesProgressBar = New-Object System.Windows.Forms.ProgressBar -Property @{
    Location = @{ X = $ProgressBarQueriesLabel.Location.X + $ProgressBarQueriesLabel.Size.Width
                  Y = $ProgressBarQueriesLabel.Location.Y }
    Size     = @{ Width  = $script:ProgressBarEndpointsProgressBar.Size.Width
                  Height = $script:ProgressBarEndpointsProgressBar.Size.Height }
    Forecolor = 'LightGreen'
    BackColor = 'white'
    Style     = "Continuous"
    Minimum   = 0
}
$PoSHEasyWin.Controls.Add($script:ProgressBarQueriesProgressBar)


#============================================================================================================================================================
#
#  Parent: Main Form
#   __  __         _            ____          _    _                        _____       _       ____               _                _ 
#  |  \/  |  __ _ (_) _ __     | __ )   ___  | |_ | |_  ___   _ __ ___     |_   _|__ _ | |__   / ___| ___   _ __  | |_  _ __  ___  | |
#  | |\/| | / _` || || '_ \    |  _ \  / _ \ | __|| __|/ _ \ | '_ ` _ \      | | / _` || '_ \ | |    / _ \ | '_ \ | __|| '__|/ _ \ | |
#  | |  | || (_| || || | | |   | |_) || (_) || |_ | |_| (_) || | | | | |     | || (_| || |_) || |___| (_) || | | || |_ | |  | (_) || |
#  |_|  |_| \__,_||_||_| |_|   |____/  \___/  \__| \__|\___/ |_| |_| |_|     |_| \__,_||_.__/  \____|\___/ |_| |_| \__||_|   \___/ |_|
#
#============================================================================================================================================================

$MainBottomTabControl = New-Object System.Windows.Forms.TabControl -Property @{
    Name     = "Main Tab Window"
    Location = @{ X = 470
                  Y = $ProgressBarQueriesLabel.Location.Y + $ProgressBarQueriesLabel.Size.Height - 2 }
    Size     = @{ Width  = 752
                  Height = 250 }
    ShowToolTips  = $True
    Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$PoShEasyWin.Controls.Add($MainBottomTabControl)


#=======================================================================================================================================================================
#
#  Parent: Main Form -> Main Bottom TabControl
#      _     _                    _       _____       _      ____                     
#     / \   | |__    ___   _   _ | |_    |_   _|__ _ | |__  |  _ \  __ _   __ _   ___ 
#    / _ \  | '_ \  / _ \ | | | || __|     | | / _` || '_ \ | |_) |/ _` | / _` | / _ \
#   / ___ \ | |_) || (_) || |_| || |_      | || (_| || |_) ||  __/| (_| || (_| ||  __/
#  /_/   \_\|_.__/  \___/  \__,_| \__|     |_| \__,_||_.__/ |_|    \__,_| \__, | \___|
#                                                                      |___/       
#=======================================================================================================================================================================

$Section3AboutTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text                    = "About"
    UseVisualStyleBackColor = $True
    Font                    = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$MainBottomTabControl.Controls.Add($Section3AboutTab)


$PoShEasyWinLogoPictureBox = New-Object Windows.Forms.PictureBox -Property @{
    Text     = "PoSh-EasyWin Image"
    Location = @{ X = 3
                  Y = 10 }
    Size     = @{ Width  = 355
                  Height = 35 }
    Image = [System.Drawing.Image]::Fromfile("$Dependencies\Images\PoSh-EasyWin Image 01.png")
    SizeMode = 'StretchImage'
}
$Section3AboutTab.Controls.Add($PoShEasyWinLogoPictureBox)

. "$Dependencies\Code\System.Windows.Forms\Button\PoShEasyWinLicenseAndAboutButton.ps1"
$PoShEasyWinLicenseAndAboutButton = New-Object Windows.Forms.Button -Property @{
    Text     = "GNU General Public License v3"
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    Location = @{ X = 540
                  Y = 22 }
    Size     = @{ Width  = 200
                  Height = 22 }
    Add_Click      = $PoShEasyWinLicenseAndAboutButtonAdd_Click
    Add_MouseHover = $PoShEasyWinLicenseAndAboutButtonAdd_MouseHover
}
$Section3AboutTab.Controls.Add($PoShEasyWinLicenseAndAboutButton)
CommonButtonSettings -Button $PoShEasyWinLicenseAndAboutButton


$Section1AboutSubTabRichTextBox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Text     = $(Get-Content "$Dependencies\About PoSh-EasyWin.txt" -raw)
    Font     = New-Object System.Drawing.Font("Courier New",11,0,0,0)
    Location = @{ X = 0
                  Y = $PoShEasyWinLogoPictureBox.Location.Y + $PoShEasyWinLogoPictureBox.Size.Height + 2}
    Size     = @{ Width  = 742
                  Height = 175 }
    MultiLine  = $True
    ScrollBars = "Vertical"
    WordWrap   = $true
    ReadOnly   = $True
    BackColor  = 'White'
    ShortcutsEnabled = $true    
}
$Section3AboutTab.Controls.Add($Section1AboutSubTabRichTextBox)    


#=======================================================================================================================================================================
#
#  Parent: Main Form -> Main Bottom TabControl
#   ____                    _  _            _____       _      ____                     
#  |  _ \  ___  ___  _   _ | || |_  ___    |_   _|__ _ | |__  |  _ \  __ _   __ _   ___ 
#  | |_) |/ _ \/ __|| | | || || __|/ __|     | | / _` || '_ \ | |_) |/ _` | / _` | / _ \
#  |  _ <|  __/\__ \| |_| || || |_ \__ \     | || (_| || |_) ||  __/| (_| || (_| ||  __/
#  |_| \_\\___||___/ \__,_||_| \__||___/     |_| \__,_||_.__/ |_|    \__,_| \__, | \___|
#                                                                           |___/       
#=======================================================================================================================================================================

$Section3ResultsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text                    = "Results"
    Name                    = "Results Tab"
    UseVisualStyleBackColor = $True
    Font                    = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$MainBottomTabControl.Controls.Add($Section3ResultsTab)


#------------------------------
# Results - Add OpNotes Button
#------------------------------
. "$Dependencies\Code\System.Windows.Forms\Button\ResultsTabOpNotesAddButton.ps1" 
$ResultsTabOpNotesAddButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "Add Selected To OpNotes"
    Location  = @{ X = 578
                   Y = 198 }
    Size      = @{ Width  = 150
                   Height = 25 }
    Add_Click = $ResultsTabOpNotesAddButtonAdd_Click
    Add_MouseHover = $ResultsTabOpNotesAddButtonAdd_MouseHover
}
$Section3ResultsTab.Controls.Add($ResultsTabOpNotesAddButton) 
CommonButtonSettings -Button $ResultsTabOpNotesAddButton


#-----------------
# Results ListBox
#-----------------
$ResultsListBox = New-Object System.Windows.Forms.ListBox -Property @{
    Name     = "ResultsListBox"
    Location = @{ X = -1
                  Y = -1 }
    Size     = @{ Width  = 752 - 3
                  Height = 250 - 15 }
    FormattingEnabled   = $True
    SelectionMode       = 'MultiExtended'
    ScrollAlwaysVisible = $True
    AutoSize            = $False
    Font                = New-Object System.Drawing.Font("Courier New",11,0,0,0)
}
$Section3ResultsTab.Controls.Add($ResultsListBox)


#=======================================================================================================================================================================
#
#  Parent: Main Form -> Main Bottom TabControl
#   _   _              _       ____          _             _____       _      ____                     
#  | | | |  ___   ___ | |_    |  _ \   __ _ | |_  __ _    |_   _|__ _ | |__  |  _ \  __ _   __ _   ___ 
#  | |_| | / _ \ / __|| __|   | | | | / _` || __|/ _` |     | | / _` || '_ \ | |_) |/ _` | / _` | / _ \
#  |  _  || (_) |\__ \| |_    | |_| || (_| || |_| (_| |     | || (_| || |_) ||  __/| (_| || (_| ||  __/
#  |_| |_| \___/ |___/ \__|   |____/  \__,_| \__|\__,_|     |_| \__,_||_.__/ |_|    \__,_| \__, | \___|
#                                                                                          |___/       
#=======================================================================================================================================================================

$Section3HostDataTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text                    = "Host Data"
    Name                    = "Host Data Tab"
    UseVisualStyleBackColor = $True
    Font                    = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$MainBottomTabControl.Controls.Add($Section3HostDataTab)


#------------------------------
# Host Data - Hostname Textbox
#------------------------------
. "$Dependencies\Code\System.Windows.Forms\TextBox\Section3HostDataNameTextBox.ps1" 
$Section3HostDataNameTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = 0
                  Y = 3 }
    Size     = @{ Width  = 250
                  Height = 25 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ReadOnly = $true
    Add_MouseHover = $Section3HostDataNameTextBoxAdd_MouseHover
}
$Section3HostDataTab.Controls.Add($Section3HostDataNameTextBox)


#------------------------`
# Host Data - OS Textbox
#------------------------
. "$Dependencies\Code\System.Windows.Forms\TextBox\Section3HostDataOSTextBox.ps1" 
$Section3HostDataOSTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = 0
                  Y = $Section3HostDataNameTextBox.Location.Y + $Section3HostDataNameTextBox.Size.Height + 4 }
    Size     = @{ Width  = 250
                  Height = 25 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ReadOnly = $true
    Add_MouseHover = $Section3HostDataOSTextBoxAdd_MouseHover
}
$Section3HostDataTab.Controls.Add($Section3HostDataOSTextBox)


#------------------------
# Host Data - OU Textbox
#------------------------
. "$Dependencies\Code\System.Windows.Forms\TextBox\Section3HostDataOUTextBox.ps1" 
$Section3HostDataOUTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = 0
                  Y = $Section3HostDataOSTextBox.Location.Y + $Section3HostDataOSTextBox.Size.Height + 4 }
    Size     = @{ Width  = 250
                  Height = 25 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ReadOnly = $true
    Add_MouseHover = $Section3HostDataOUTextBoxAdd_MouseHover
}
$Section3HostDataTab.Controls.Add($Section3HostDataOUTextBox)


#----------------------------------
# Host Data - IP Textbox
#----------------------------------
. "$Dependencies\Code\System.Windows.Forms\TextBox\Section3HostDataIPTextBox.ps1" 
$Section3HostDataIPTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = 0
                    Y = $Section3HostDataOUTextBox.Location.Y + $Section3HostDataOUTextBox.Size.Height + 4 }
    Size     = @{ Width  = 120
                    Height = 25 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ReadOnly = $false
    Add_MouseHover = $Section3HostDataIPTextBoxAdd_MouseHover
}
$Section3HostDataTab.Controls.Add($Section3HostDataIPTextBox)


#----------------------------------
# Host Data - MAC Textbox
#----------------------------------
. "$Dependencies\Code\System.Windows.Forms\TextBox\Section3HostDataMACTextBox.ps1" 
$Section3HostDataMACTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3HostDataIPTextBox.Size.Width + 10
                    Y = $Section3HostDataOUTextBox.Location.Y + $Section3HostDataOUTextBox.Size.Height + 4 }
    Size     = @{ Width  = 120
                    Height = 25 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ReadOnly = $false
    Add_MouseHover = $Section3HostDataMACTextBoxAdd_MouseHover
}
$Section3HostDataTab.Controls.Add($Section3HostDataMACTextBox)


#--------------------------------------
# Host Data Notes - Add OpNotes Button
#--------------------------------------
. "$Dependencies\Code\System.Windows.Forms\Button\Section3HostDataNotesAddOpNotesButton.ps1" 
$Section3HostDataNotesAddOpNotesButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "Add Host Data To OpNotes"
    Location = @{ X = 570
                  Y = 197 }
    Size     = @{ Width  = 150
                  Height = 25 }
    Add_Click = $Section3HostDataNotesAddOpNotesButtonAdd_Click
    Add_MouseHover = $Section3HostDataNotesAddOpNotesButtonAdd_MouseHover
}
$Section3HostDataTab.Controls.Add($Section3HostDataNotesAddOpNotesButton) 
CommonButtonSettings -Button $Section3HostDataNotesAddOpNotesButton

# Mass Tag one or multiple hosts in the computer treeview
. "$Dependencies\Code\Tree View\Computer\Save-ComputerTreeNodeHostData.ps1" 

# Checks if the Host Data has been modified and determines the text color: Green/Red
. "$Dependencies\Code\Main Body\Check-HostDataIfModified.ps1" 


#-------------------------
# Host Data - TextBox
#-------------------------
. "$Dependencies\Code\System.Windows.Forms\TextBox\Section3HostDataNotesTextBox.ps1"
$Section3HostDataNotesTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = 0
                  Y = $Section3HostDataIPTextBox.Location.Y + $Section3HostDataIPTextBox.Size.Height + 3 }
    Size     = @{ Width  = 739
                  Height = 126 }
    Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    Multiline  = $True
    ScrollBars = 'Vertical'
    WordWrap   = $True
    ReadOnly   = $false
    Add_MouseHover = $Section3HostDataNotesTextBoxAdd_MouseHover
    Add_MouseEnter = { Check-HostDataIfModified }
    Add_MouseLeave = { Check-HostDataIfModified }
}
$Section3HostDataTab.Controls.Add($Section3HostDataNotesTextBox)


#-------------------------
# Host Data - Save Button
#-------------------------
$script:Section3HostDataNotesSaveCheck = ""
. "$Dependencies\Code\System.Windows.Forms\Button\Section3HostDataSaveButton.ps1"
$Section3HostDataSaveButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "Data Saved"
    Location = @{ X = 640
                  Y = 73 }
    Size     = @{ Width  = 100
                  Height = 22 }
    Add_Click = $Section3HostDataSaveButtonAdd_Click
    Add_MouseHover = $Section3HostDataSaveButtonAdd_MouseHover
}
$Section3HostDataTab.Controls.Add($Section3HostDataSaveButton)
CommonButtonSettings -Button $Section3HostDataSaveButton


#============================================================================================================================================================
# Host Data - Selection Data ComboBox and Date/Time ComboBox
#============================================================================================================================================================

    #--------------------------------
    # Host Data - Selection ComboBox
    #--------------------------------
    . "$Dependencies\Code\System.Windows.Forms\ComboBox\Section3HostDataSelectionComboBox.ps1"
    $Section3HostDataSelectionComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location           = New-Object System.Drawing.Point(260,3)
        Size               = New-Object System.Drawing.Size(200,25)
        Text               = "Host Data - Selection"
        Font               = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor          = "Black"
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
        DataSource         = $HostDataList1
        Add_MouseHover     = $Section3HostDataSelectionComboBoxAdd_MouseHover
        Add_SelectedIndexChanged = $Section3HostDataSelectionComboBoxAdd_SelectedIndexChanged
    }
    $Section3HostDataTab.Controls.Add($Section3HostDataSelectionComboBox)

    #--------------------------------------------
    # Host Data - Date & Time Collected ComboBox
    #--------------------------------------------
    . "$Dependencies\Code\System.Windows.Forms\ComboBox\Section3HostDataSelectionDateTimeComboBox.ps1"
    $Section3HostDataSelectionDateTimeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Location           = New-Object System.Drawing.Point(260,($Section3HostDataSelectionComboBox.Size.Height + $Section3HostDataSelectionComboBox.Location.Y + 3))
        Size               = New-Object System.Drawing.Size(200,25)
        Text               = "Host Data - Date & Time"
        Font               = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor          = "Black"
        AutoCompleteSource = "ListItems" 
        AutoCompleteMode   = "SuggestAppend" 
        Add_MouseHover     = $Section3HostDataSelectionDateTimeComboBoxAdd_MouseHover
    }
    $Section3HostDataTab.Controls.Add($Section3HostDataSelectionDateTimeComboBox)
  
    #-----------------------------
    # Host Data - Get Data Button
    #-----------------------------
    . "$Dependencies\Code\System.Windows.Forms\Button\Section3HostDataGetDataButton.ps1"
    $Section3HostDataGetDataButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Get Data"
        Location = New-Object System.Drawing.Point(($Section3HostDataSelectionDateTimeComboBox.Location.X + $Section3HostDataSelectionDateTimeComboBox.Size.Width + 5),($Section3HostDataSelectionDateTimeComboBox.Location.Y - 1))
        Size     = New-Object System.Drawing.Size(75,23)
        Add_Click = $Section3HostDataGetDataButtonAdd_Click
        Add_MouseHover = $Section3HostDataGetDataButtonAdd_MouseHover
    }
    $Section3HostDataTab.Controls.Add($Section3HostDataGetDataButton)
    CommonButtonSettings -Button $Section3HostDataGetDataButton


#---------------------------------------
# ComputerList TreeView - Tags ComboBox
#---------------------------------------
. "$Dependencies\Code\System.Windows.Forms\ComboBox\Section3HostDataTagsComboBox.ps1"
$Section3HostDataTagsComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Name               = "Tags"
    Text               = "Tags"
    Location           = New-Object System.Drawing.Point(260,($Section3HostDataGetDataButton.Size.Height + $Section3HostDataGetDataButton.Location.Y + 25))
    Size               = New-Object System.Drawing.Size(200,25)
    AutoCompleteSource = "ListItems" 
    AutoCompleteMode   = "SuggestAppend"
    Font               = New-Object System.Drawing.Font("$Font",11,0,0,0)
    Add_MouseHover     = $Section3HostDataTagsComboBoxAdd_MouseHover
}
ForEach ($Item in $TagListFileContents) { $Section3HostDataTagsComboBox.Items.Add($Item) }
$Section3HostDataTab.Controls.Add($Section3HostDataTagsComboBox)


#-----------------------------------------
# ComputerList TreeView - Tags Add Button
#-----------------------------------------
. "$Dependencies\Code\System.Windows.Forms\Button\Section3HostDataTagsAddButton.ps1" 
$Section3HostDataTagsAddButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Add"
    Location = @{ X = $Section3HostDataTagsComboBox.Size.Width + $Section3HostDataTagsComboBox.Location.X + 5
                  Y = $Section3HostDataTagsComboBox.Location.Y - 1 }
    Size     = @{ Width  = 75
                  Height = 23 }
    Add_Click = $Section3HostDataTagsAddButtonAdd_Click
    Add_MouseHover = $Section3HostDataTagsAddButtonAdd_MouseHover
}
$Section3HostDataTab.Controls.Add($Section3HostDataTagsAddButton)
CommonButtonSettings -Button $Section3HostDataTagsAddButton


#=======================================================================================================================================================================
#
#  Parent: Main Form -> Main Bottom TabControl
#    ___                                _____               _                     _    _                   _____       _      ____                     
#   / _ \  _   _   ___  _ __  _   _    | ____|__  __ _ __  | |  ___   _ __  __ _ | |_ (_)  ___   _ __     |_   _|__ _ | |__  |  _ \  __ _   __ _   ___ 
#  | | | || | | | / _ \| '__|| | | |   |  _|  \ \/ /| '_ \ | | / _ \ | '__|/ _` || __|| | / _ \ | '_ \      | | / _` || '_ \ | |_) |/ _` | / _` | / _ \
#  | |_| || |_| ||  __/| |   | |_| |   | |___  >  < | |_) || || (_) || |  | (_| || |_ | || (_) || | | |     | || (_| || |_) ||  __/| (_| || (_| ||  __/
#   \__\_\ \__,_| \___||_|    \__, |   |_____|/_/\_\| .__/ |_| \___/ |_|   \__,_| \__||_| \___/ |_| |_|     |_| \__,_||_.__/ |_|    \__,_| \__, | \___|
#                             |___/                 |_|                                                                                    |___/       
#=======================================================================================================================================================================

$Section3QueryExplorationTabPage = New-Object System.Windows.Forms.TabPage -Property @{
    Text = "Query Exploration"
    Name = "Query Exploration"
    Font = New-Object System.Drawing.Font("$Font",11,0,0,0)
    UseVisualStyleBackColor = $True
}
$MainBottomTabControl.Controls.Add($Section3QueryExplorationTabPage)


#--------------------------
# Query Exploration - Name
#--------------------------
$Section3QueryExplorationNameLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "Query Name:"
    Location = @{ X = 0
                  Y = 6 }
    Size     = @{ Width  = 100
                  Height = 22 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$Section3QueryExplorationNameTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationNameLabel.Location.X + $Section3QueryExplorationNameLabel.Size.Width + 5
                  Y = 3 }
    Size     = @{ Width  = 195
                  Height = 22 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ReadOnly = $true
    Add_MouseEnter = { $Section3QueryExplorationNameTextBox.size = @{ Width = 633 } }
    Add_MouseLeave = { $Section3QueryExplorationNameTextBox.size = @{ Width = 195 } }    
}
$Section3QueryExplorationTabPage.Controls.AddRange(@($Section3QueryExplorationNameLabel,$Section3QueryExplorationNameTextBox))


#--------------------------------
# Query Exploration - WinRM PoSh 
#--------------------------------
$Section3QueryExplorationWinRMPoShLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "WinRM PoSh:"
    Location = @{ X = 0
                  Y = $Section3QueryExplorationNameLabel.location.Y + $Section3QueryExplorationNameLabel.Size.Height }
    Size     = @{ Width  = 100
                  Height = 22 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$Section3QueryExplorationWinRMPoShTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationWinRMPoShLabel.Location.X + $Section3QueryExplorationWinRMPoShLabel.Size.Width + 5
                  Y = $Section3QueryExplorationWinRMPoShLabel.Location.Y - 3 }
    Size     = @{ Width  = 195
                  Height = 22 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ReadOnly = $true
    Add_MouseEnter = { $Section3QueryExplorationWinRMPoShTextBox.size = @{ Width = 633 } }
    Add_MouseLeave = { $Section3QueryExplorationWinRMPoShTextBox.size = @{ Width = 195 } }
}
$Section3QueryExplorationTabPage.Controls.AddRange(@($Section3QueryExplorationWinRMPoShLabel,$Section3QueryExplorationWinRMPoShTextBox))


#-------------------------------
# Query Exploration - WinRM WMI 
#-------------------------------
$Section3QueryExplorationWinRMWMILabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "WinRM WMI:"
    Location = @{ X = 0
                  Y = $Section3QueryExplorationWinRMPoShLabel.location.Y + $Section3QueryExplorationWinRMPoShLabel.Size.Height }
    Size     = @{ Width  = 100
                  Height = 22 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$Section3QueryExplorationWinRMWMITextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationWinRMWMILabel.Location.X + $Section3QueryExplorationWinRMWMILabel.Size.Width + 5
                  Y = $Section3QueryExplorationWinRMWMILabel.Location.Y - 3 }
    Size     = @{ Width  = 195
                  Height = 22 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ReadOnly = $true
    Add_MouseEnter = { $Section3QueryExplorationWinRMWMITextBox.size = @{ Width = 633 } }
    Add_MouseLeave = { $Section3QueryExplorationWinRMWMITextBox.size = @{ Width = 195 } }    
}
$Section3QueryExplorationTabPage.Controls.AddRange(@($Section3QueryExplorationWinRMWMILabel,$Section3QueryExplorationWinRMWMITextBox))
        

#-------------------------------
# Query Exploration - WinRM Cmd 
#-------------------------------
$Section3QueryExplorationWinRMCmdLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "WinRM Cmd:"
    Location = @{ X = 0
                  Y = $Section3QueryExplorationWinRMWMILabel.location.Y + $Section3QueryExplorationWinRMWMILabel.Size.Height }
    Size     = @{ Width  = 100
                  Height = 22 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$Section3QueryExplorationWinRMCmdTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationWinRMCmdLabel.Location.X + $Section3QueryExplorationWinRMCmdLabel.Size.Width + 5
                  Y = $Section3QueryExplorationWinRMCmdLabel.Location.Y - 3 }
    Size     = @{ Width  = 195
                  Height = 22 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ReadOnly = $true
    Add_MouseEnter = { $Section3QueryExplorationWinRMCmdTextBox.size = @{ Width = 633 } }
    Add_MouseLeave = { $Section3QueryExplorationWinRMCmdTextBox.size = @{ Width = 195 } }
}
$Section3QueryExplorationTabPage.Controls.AddRange(@($Section3QueryExplorationWinRMCmdLabel,$Section3QueryExplorationWinRMCmdTextBox))


#------------------------------
# Query Exploration - RPC PoSh
#------------------------------
$Section3QueryExplorationRPCPoShLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "RPC/DCOM PoSh:"
    Location = @{ X = 0
                  Y = $Section3QueryExplorationWinRMCmdLabel.location.Y + $Section3QueryExplorationWinRMCmdLabel.Size.Height }
    Size     = @{ Width  = 100
                  Height = 22 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$Section3QueryExplorationRPCPoShTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationRPCPoShLabel.Location.X + $Section3QueryExplorationRPCPoShLabel.Size.Width + 5
                  Y = $Section3QueryExplorationRPCPoShLabel.Location.Y - 3 }
    Size     = @{ Width  = 195
                  Height = 22 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ReadOnly = $true
    Add_MouseEnter = { $Section3QueryExplorationRPCPoShTextBox.size = @{ Width = 633 } }
    Add_MouseLeave = { $Section3QueryExplorationRPCPoShTextBox.size = @{ Width = 195 } }
}
$Section3QueryExplorationTabPage.Controls.AddRange(@($Section3QueryExplorationRPCPoShLabel,$Section3QueryExplorationRPCPoShTextBox))


#-----------------------------
# Query Exploration - RPC WMI
#-----------------------------
$Section3QueryExplorationRPCWMILabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "RPC/DCOM WMI:"
    Location = @{ X = 0
                  Y = $Section3QueryExplorationRPCPoShLabel.location.Y + $Section3QueryExplorationRPCPoShLabel.Size.Height }
    Size     = @{ Width  = 100
                  Height = 22 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$Section3QueryExplorationRPCWMITextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationRPCWMILabel.Location.X + $Section3QueryExplorationRPCWMILabel.Size.Width + 5
                  Y = $Section3QueryExplorationRPCWMILabel.Location.Y - 3 }
    Size     = @{ Width  = 195
                  Height = 22 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ReadOnly = $true
    Add_MouseEnter = { $Section3QueryExplorationRPCWMITextBox.size = @{ Width = 633 } }
    Add_MouseLeave = { $Section3QueryExplorationRPCWMITextBox.size = @{ Width = 195 } }
}
$Section3QueryExplorationTabPage.Controls.AddRange(@($Section3QueryExplorationRPCWMILabel,$Section3QueryExplorationRPCWMITextBox))


#-------------------------------------
# Query Exploration - Properties PoSh
#-------------------------------------
$Section3QueryExplorationPropertiesPoshLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "Properties PoSh:"
    Location = @{ X = 0
                  Y = $Section3QueryExplorationRPCWMILabel.location.Y + $Section3QueryExplorationRPCWMILabel.Size.Height }
    Size     = @{ Width  = 100
                  Height = 22 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$Section3QueryExplorationPropertiesPoshTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationPropertiesPoshLabel.Location.X + $Section3QueryExplorationPropertiesPoshLabel.Size.Width + 5
                  Y = $Section3QueryExplorationPropertiesPoshLabel.Location.Y - 3 }
    Size     = @{ Width  = 195
                  Height = 22 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ReadOnly = $true
    Add_MouseEnter = { $Section3QueryExplorationPropertiesPoshTextBox.size = @{ Width = 633 } }
    Add_MouseLeave = { $Section3QueryExplorationPropertiesPoshTextBox.size = @{ Width = 195 } }
}
$Section3QueryExplorationTabPage.Controls.AddRange(@($Section3QueryExplorationPropertiesPoshLabel,$Section3QueryExplorationPropertiesPoshTextBox))


#------------------------------------
# Query Exploration - Properties WMI
#------------------------------------
$Section3QueryExplorationPropertiesWMILabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "Properties WMI:"
    Location = @{ X = 0
                  Y = $Section3QueryExplorationPropertiesPoshLabel.location.Y + $Section3QueryExplorationPropertiesPoshLabel.Size.Height }
    Size     = @{ Width  = 100
                  Height = 22 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$Section3QueryExplorationPropertiesWMITextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationPropertiesWMILabel.Location.X + $Section3QueryExplorationPropertiesWMILabel.Size.Width + 5
                  Y = $Section3QueryExplorationPropertiesWMILabel.Location.Y - 3 }
    Size     = @{ Width  = 195
                  Height = 22 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ReadOnly = $true
    Add_MouseEnter = { $Section3QueryExplorationPropertiesWMITextBox.size = @{ Width = 633 } }
    Add_MouseLeave = { $Section3QueryExplorationPropertiesWMITextBox.size = @{ Width = 195 } }
}
$Section3QueryExplorationTabPage.Controls.AddRange(@($Section3QueryExplorationPropertiesWMILabel,$Section3QueryExplorationPropertiesWMITextBox))


#--------------------------------
# Query Exploration - WinRS WMIC
#--------------------------------
$Section3QueryExplorationWinRSWmicLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "WinRS WMIC:"
    Location = @{ X = 0
                  Y = $Section3QueryExplorationPropertiesWMILabel.location.Y + $Section3QueryExplorationPropertiesWMILabel.Size.Height }
    Size     = @{ Width  = 100
                  Height = 22 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$Section3QueryExplorationWinRSWmicTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationWinRSWmicLabel.Location.X + $Section3QueryExplorationWinRSWmicLabel.Size.Width + 5
                  Y = $Section3QueryExplorationWinRSWmicLabel.Location.Y - 3 }
    Size     = @{ Width  = 195
                  Height = 22 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ReadOnly = $true
    Add_MouseEnter = { $Section3QueryExplorationWinRSWmicTextBox.size = @{ Width = 633 } }
    Add_MouseLeave = { $Section3QueryExplorationWinRSWmicTextBox.size = @{ Width = 195 } }
}
$Section3QueryExplorationTabPage.Controls.AddRange(@($Section3QueryExplorationWinRSWmicLabel,$Section3QueryExplorationWinRSWmicTextBox))


#-------------------------------
# Query Exploration - WinRS Cmd
#-------------------------------
$Section3QueryExplorationWinRSCmdLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "WinRS Cmd:"
    Location = @{ X = 0
                  Y = $Section3QueryExplorationWinRSWmicLabel.location.Y + $Section3QueryExplorationWinRSWmicLabel.Size.Height }
    Size     = @{ Width  = 100
                  Height = 22 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$Section3QueryExplorationWinRSCmdTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationWinRSCmdLabel.Location.X + $Section3QueryExplorationWinRSCmdLabel.Size.Width + 5
                  Y = $Section3QueryExplorationWinRSCmdLabel.Location.Y - 3 }
    Size     = @{ Width  = 195
                  Height = 22 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ReadOnly = $true
    Add_MouseEnter = { $Section3QueryExplorationWinRSCmdTextBox.size = @{ Width = 633 } }
    Add_MouseLeave = { $Section3QueryExplorationWinRSCmdTextBox.size = @{ Width = 195 } }
}
$Section3QueryExplorationTabPage.Controls.AddRange(@($Section3QueryExplorationWinRSCmdLabel,$Section3QueryExplorationWinRSCmdTextBox))


#---------------------------------
# Query Exploration - Description
#---------------------------------
$Section3QueryExplorationDescriptionTextbox = New-Object System.Windows.Forms.TextBox -Property @{
    Location   = @{ X = $Section3QueryExplorationNameTextBox.Location.X + $Section3QueryExplorationNameTextBox.Size.Width + 10 
                    Y = $Section3QueryExplorationNameTextBox.Location.Y }
    Size       = @{ Width  = 428
                    Height = 196 }
    Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    Multiline  = $True
    ScrollBars = 'Vertical'
    WordWrap   = $True
    ReadOnly   = $true
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationDescriptionTextbox)


#-------------------------------
# Query Exploration - Tag Words
#-------------------------------
$Section3QueryExplorationTagWordsLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "Tags"
    Location = @{ X = $Section3QueryExplorationDescriptionTextbox.Location.X
                  Y = $Section3QueryExplorationDescriptionTextbox.location.Y + $Section3QueryExplorationDescriptionTextbox.Size.Height + 5 }
    Size     = @{ Width  = 35
                  Height = 22 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$Section3QueryExplorationTagWordsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationTagWordsLabel.Location.X + $Section3QueryExplorationTagWordsLabel.Size.Width + 5
                  Y = $Section3QueryExplorationTagWordsLabel.Location.Y - 3 }
    Size     = @{ Width  = 200
                  Height = 22 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ReadOnly = $true
}
$Section3QueryExplorationTabPage.Controls.AddRange(@($Section3QueryExplorationTagWordsLabel,$Section3QueryExplorationTagWordsTextBox))


#-----------------------------------
# Query Exploration - Edit CheckBox
#-----------------------------------
. "$Dependencies\Code\System.Windows.Forms\CheckBox\Section3QueryExplorationEditCheckBox.ps1"
$Section3QueryExplorationEditCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
    Text      = "Edit"
    Location  = @{ X = $Section3QueryExplorationDescriptionTextbox.Location.X + 255
                   Y = $Section3QueryExplorationDescriptionTextbox.Location.Y + $Section3QueryExplorationDescriptionTextbox.Size.Height + 3 }
    Size      = @{ Height = 25
                   Width  = 50 }
    Font      = New-Object System.Drawing.Font("$Font",11,0,2,1)
    Checked   = $false
    Add_Click = $Section3QueryExplorationEditCheckBoxAdd_Click
}
# Note: The button is added/removed in other parts of the code


#---------------------------------
# Query Exploration - Save Button
#---------------------------------
. "$Dependencies\Code\System.Windows.Forms\Button\Section3QueryExplorationSaveButton.ps1"
$Section3QueryExplorationSaveButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = 'Locked'
    Location  = @{ X = $Section3QueryExplorationEditCheckBox.Location.X + 50
                   Y = $Section3QueryExplorationEditCheckBox.Location.Y }
    Size      = @{ Width  = $Column5BoxWidth
                   Height = $Column5BoxHeight }
    Add_Click = $Section3QueryExplorationSaveButtonAdd_Click
}
CommonButtonSettings -Button $Section3QueryExplorationSaveButton
# Note: The button is added/removed in other parts of the code


#---------------------------------
# Query Exploration - View Script
#---------------------------------
. "$Dependencies\Code\System.Windows.Forms\Button\Section3QueryExplorationViewScriptButton.ps1"
$Section3QueryExplorationViewScriptButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = 'View Script'
    Location  = @{ X = $Section3QueryExplorationEditCheckBox.Location.X + 50
                   Y = $Section3QueryExplorationEditCheckBox.Location.Y }
    Size      = @{ Width  = $Column5BoxWidth
                   Height = $Column5BoxHeight }
    Add_Click = $Section3QueryExplorationViewScriptButtonAdd_Click
}
CommonButtonSettings -Button $Section3QueryExplorationViewScriptButton


# Charts - Convert CSV Number Strings To Intergers 
. "$Dependencies\Code\Charts\Convert-CsvNumberStringsToIntergers.ps1"

# Checks and compiles selected command treenode to be execute
# Those checked are either later executed individually or compiled
. "$Dependencies\Code\Tree View\Command\Compile-SelectedCommandTreeNode.ps1"

# Allows you to search the any number of registry paths for key names, value names, and value data.
. "$Dependencies\Code\Execution\Search-Registry.ps1" 

# Searches for network connections that match provided IPs, Ports, or network connections started by specific process names
# Required for Query-NetworkConnectionRemoteIPAddress, Query-NetworkConnectionRemotePort, and Query-NetworkConnectionProcess
. "$Dependencies\Code\Execution\Query-NetworkConnection.ps1"

# Compiles the .csv files in the collection directory then saves the combined file to the partent directory
# The first line (collumn headers) is only copied once from the first file compiled, then skipped for the rest  
. "$Dependencies\Code\Execution\Compile-CsvFiles.ps1"

# Compiles the .xml files in the collection directory then saves the combined file to the partent directory
. "$Dependencies\Code\Execution\Compile-XmlFiles.ps1"

# Removes Duplicate CSV Headers
. "$Dependencies\Code\Execution\Individual Execution\Remove-DuplicateCsvHeaders.ps1"

# This is one of the core scripts that handles how queries are conducted
# It monitors started PoSh-EasyWin jobs and updates the GUI
. "$Dependencies\Code\Execution\Individual Execution\Monitor-Jobs.ps1" 

# If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
. "$Dependencies\Code\Execution\Individual Execution\Conduct-PreCommandCheck.ps1"

# Event Logs Search
# Combines the inputs from the various GUI fields to query for event logs; fields such as
# event codes/IDs entered, time range, and max amount
# Uses 'Get-WmiObject -Class Win32_NTLogEvent'
. "$Dependencies\Code\Execution\Individual Execution\Query-EventLog.ps1"

# Searches for registry key names, value names, and value data
# Uses input from GUI to query the registry
. "$Dependencies\Code\Execution\Individual Execution\Query-Registry.ps1"

 # This sorts the command treenodes again prior to execution, mainly so 'Query History' nodes are accounted for when checking for RPC commands, it also performs another command dedup check
. "$Dependencies\Code\Tree View\Command\Sort-CommandTreeNode.ps1"

# Imports the Query History and populates the command treenode
Update-QueryHistory

# Provides $script:SectionQueryCount variable data
. "$Dependencies\Code\Execution\Count-SectionQueries.ps1"

#============================================================================================================================================================
#   ____               _         _       _____                          _    _               
#  / ___|   ___  _ __ (_) _ __  | |_    | ____|__  __ ___   ___  _   _ | |_ (_)  ___   _ __  
#  \___ \  / __|| '__|| || '_ \ | __|   |  _|  \ \/ // _ \ / __|| | | || __|| | / _ \ | '_ \ 
#   ___) || (__ | |   | || |_) || |_    | |___  >  <|  __/| (__ | |_| || |_ | || (_) || | | |
#  |____/  \___||_|   |_|| .__/  \__|   |_____|/_/\_\\___| \___| \__,_| \__||_| \___/ |_| |_|
#                        |_|                                                                 
#============================================================================================================================================================
$ExecuteScriptHandler = {
    # Clears the Progress bars
    $script:ProgressBarEndpointsProgressBar.Value     = 0
    $script:ProgressBarQueriesProgressBar.Value       = 0
    $script:ProgressBarEndpointsProgressBar.BackColor = 'White'
    $script:ProgressBarQueriesProgressBar.BackColor   = 'White'
    if ($NoGUI){
        $ProgressBarEndpointsCommandLine = 0
        $ProgressBarQueriesCommandLine   = 0
        #Write-Progress -Activity Updating -Status 'Completed: ' -PercentComplete $ProgressBarEndpointsCommandLine -CurrentOperation Endpoints
    }
    # Clears previous Target Host values
    if ( $ComputerSearch ) { continue }
    else { $ComputerList = @() }

    if ($EventLogRPCRadioButton.checked -or $ExternalProgramsRPCRadioButton.checked) { $script:RpcCommandCount += 1 }

    # Generate list of endpoints to query
    if ( $ComputerSearch ){ continue }
    else { . "$Dependencies\Code\Main Body\Generate-ComputerListToQuery.ps1" }

    Start-Sleep -Seconds 1

    # Assigns the path to save the Collections to
    $script:CollectedDataTimeStampDirectory = $script:CollectionSavedDirectoryTextBox.Text
    if ($SaveDirectory) { $script:CollectedDataTimeStampDirectory = $SaveDirectory }

    
    $script:IndividualHostResults    = "$script:CollectedDataTimeStampDirectory\Individual Host Results"
    if (-Not $CommandSearch) { 
        Sort-CommandTreeNode

        Compile-SelectedCommandTreeNode
    }
    Count-SectionQueries

    # The total count of queries/commands to be executed from all areas
    $CommandCountTotalBothQueryAndSection = $script:CommandsCheckedBoxesSelected.count + $script:SectionQueryCount

    # Checks if any computers were selected
    if ($ComputerList.Count -eq 0 -and $script:SingleHostIPCheckBox.Checked -eq $false) {
        # This brings specific tabs to the forefront/front view
        $MainLeftTabControl.SelectedTab = $Section1CollectionsTab
        $MainBottomTabControl.SelectedTab = $Section3ResultsTab

        [system.media.systemsounds]::Exclamation.play()
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Error: No Endpoints Selected or Entered")

        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Error: 1) Make a selection from the Computer TreeView:")
        $ResultsListBox.Items.Add("            Check one or more target computers")
        $ResultsListBox.Items.Add("            Check a category to collect data from all nested target computers")
        $ResultsListBox.Items.Add("       2) Enter a Single Host to collect from:")
        $ResultsListBox.Items.Add("            Check the Query A Single Host Checkbox")
        $ResultsListBox.Items.Add("            Enter a valid host to collect data from")
    }
    elseif ($CommandCountTotalBothQueryAndSection -eq 0) {
        # This brings specific tabs to the forefront/front view
        $MainLeftTabControl.SelectedTab = $Section1CollectionsTab
        $MainBottomTabControl.SelectedTab = $Section3ResultsTab

        [system.media.systemsounds]::Exclamation.play()
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Error: No Queries Selected")

        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Error: 1) Make a selection from the Command TreeView:")
        $ResultsListBox.Items.Add("            Check one or more queries nodes")
        $ResultsListBox.Items.Add("            Check a category to collect data from all nested queries")
        $ResultsListBox.Items.Add("       2) Make a selection and provide agruments from one or mote of the following:")
        $ResultsListBox.Items.Add("            Event Logs")
        $ResultsListBox.Items.Add("            Registry")
        $ResultsListBox.Items.Add("            File Search")
        $ResultsListBox.Items.Add("            Network Connections")
        $ResultsListBox.Items.Add("            SysInternals")
    }
    elseif ($EventLogsStartTimePicker.Checked -xor $EventLogsStopTimePicker.Checked) {
        # This brings specific tabs to the forefront/front view
        $MainLeftTabControl.SelectedTab = $Section1CollectionsTab
        $MainBottomTabControl.SelectedTab = $Section3ResultsTab

        [system.media.systemsounds]::Exclamation.play()
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
        # Text To Speach (TTS)
        # Plays message when finished, if checked within options
        . "$Dependencies\Code\Execution\Execute-TextToSpeach.ps1"

        # The code that is to run after execution is complete
        . "$Dependencies\Code\Execution\Completed-QueryExecution.ps1"
        
        # This brings specific tabs to the forefront/front view
        #$MainLeftTabControl.SelectedTab = $Section1OpNotesTab
        #$MainCenterTabControl.SelectedTab = $MainCenterMainTab
        $MainCenterTabControl.SelectedTab = $Section2StatisticsTab
            if ($MainCenterTabControl.SelectedTab -match 'Statistics') {
                $MainCenterTabControl.Width  = 370
                $MainCenterTabControl.Height = 278
            }
        $MainRightTabControl.SelectedTab  = $Section3ActionTab
        $MainBottomTabControl.SelectedTab = $Section3ResultsTab
        $PoShEasyWin.Refresh()


        $ResultsListBox.Items.Clear();
        $CollectionTimerStart = Get-Date
        $ResultsListBox.Items.Insert(0,"$(($CollectionTimerStart).ToString('yyyy/MM/dd HH:mm:ss'))  Collection Start Time")    
        $ResultsListBox.Items.Insert(0,"")

        # Counts Target Computers
        $CountComputerListCheckedBoxesSelected = $ComputerList.Count

        # The number of command queries completed
        $CompletedCommandQueries = 0

        # Counts the Total Queries
        $CountCommandQueries = 0

        ########################Compile-SelectedCommandTreeNode

        # Verifies that the command is only present once. Prevents running the multiple copies of the same comand, line from using the Query History comamnds
        $CommandsCheckedBoxesSelectedTemp  = @()
        $CommandsCheckedBoxesSelectedDedup = @()
        foreach ($Command in $script:CommandsCheckedBoxesSelected) {
            if ($CommandsCheckedBoxesSelectedTemp -notcontains $Command.command) {
                $CommandsCheckedBoxesSelectedTemp  += "$($Command.command)"
                $CommandsCheckedBoxesSelectedDedup += $command
                $CountCommandQueries++
            }
        }

        # Adds section checkboxes to the command count
        if ($RegistrySearchCheckbox.checked)                         { $CountCommandQueries++ }
        if ($FileSearchDirectoryListingCheckbox.Checked)             { $CountCommandQueries++ }
        if ($FileSearchFileSearchCheckbox.Checked)                   { $CountCommandQueries++ }
        if ($FileSearchAlternateDataStreamCheckbox.Checked)          { $CountCommandQueries++ } 
        if ($SysinternalsSysmonCheckbox.Checked)                     { $CountCommandQueries++ }
        if ($SysinternalsAutorunsCheckbox.Checked)                   { $CountCommandQueries++ }
        if ($SysinternalsProcessMonitorCheckbox.Checked)             { $CountCommandQueries++ }        
        if ($EventLogsEventIDsManualEntryCheckbox.Checked)           { $CountCommandQueries++ }
        if ($EventLogsEventIDsToMonitorCheckbox.Checked)             { $CountCommandQueries++ }
        if ($NetworkConnectionSearchRemoteIPAddressCheckbox.checked) { $CountCommandQueries++ }
        if ($NetworkConnectionSearchRemotePortCheckbox.checked)      { $CountCommandQueries++ }
        if ($NetworkConnectionSearchLocalPortCheckbox.checked)       { $CountCommandQueries++ }        
        if ($NetworkConnectionSearchProcessCheckbox.checked)         { $CountCommandQueries++ }
        if ($NetworkConnectionSearchDNSCacheCheckbox.checked)        { $CountCommandQueries++ }
        if ($EventLogsQuickPickSelectionCheckbox.Checked) { foreach ($Query in $script:EventLogQueries) { if ($EventLogsQuickPickSelectionCheckedlistbox.CheckedItems -match $Query.Name) { $CountCommandQueries++ } } }
        $script:CommandsCheckedBoxesSelected          = $CommandsCheckedBoxesSelectedDedup
        $script:ProgressBarQueriesProgressBar.Maximum = $CountCommandQueries
   

        # Adds executed commands to query history commands variable
        $script:QueryHistoryCommands += $script:CommandsCheckedBoxesSelected

        # Adds the selected commands to the Query History Command Nodes 
        $QueryHistoryCategoryName = $script:CollectionSavedDirectoryTextBox.Text.Replace("$CollectedDataDirectory","").TrimStart('\')
        foreach ($Command in $script:CommandsCheckedBoxesSelected) {
            $Command | Add-Member -MemberType NoteProperty -Name CategoryName -Value $QueryHistoryCategoryName -Force
            Add-CommandTreeNode -RootNode $script:TreeNodePreviouslyExecutedCommands -Category $QueryHistoryCategoryName -Entry "$($Command.Name)" -ToolTip $Command.Command
        }

        # Saves the Query History to file, inlcudes other queries from past PoSh-EasyWin sessions
        $script:QueryHistory  + $script:CommandsCheckedBoxesSelected | Export-Clixml "$PoShHome\Query History.xml"
        $script:QueryHistory += $script:CommandsCheckedBoxesSelected

        # Ensures that there are to lingering jobs in memory
        Get-Job -Name "PoSh-EasyWin:*" | Remove-Job -Force -ErrorAction SilentlyContinue

        #=======================================================================================================================================================================
        #   ___             _  _         _      _                _     _____                          _    _               
        #  |_ _| _ __    __| |(_)__   __(_)  __| | _   _   __ _ | |   | ____|__  __ ___   ___  _   _ | |_ (_)  ___   _ __  
        #   | | | '_ \  / _` || |\ \ / /| | / _` || | | | / _` || |   |  _|  \ \/ // _ \ / __|| | | || __|| | / _ \ | '_ \ 
        #   | | | | | || (_| || | \ V / | || (_| || |_| || (_| || |   | |___  >  <|  __/| (__ | |_| || |_ | || (_) || | | |
        #  |___||_| |_| \__,_||_|  \_/  |_| \__,_| \__,_| \__,_||_|   |_____|/_/\_\\___| \___| \__,_| \__||_| \___/ |_| |_|
        #
        #=======================================================================================================================================================================
        # Code that executes each command queries Individual
        # This may be slower then running commands directly with Invoke-Command as it starts multiple PowerShell instances per host
        # The mulple incstance essentiall threade up to 32 jobs, which provides the tolerance against individual queries that either hang or take forever
        # With multiple instances, each command query's status is tracked per host with a progress bar
        # These instances/jobs are one threaded when querying the same command type; eg: all process queries are multi-threaded, once their all complete it moves on to the service query
        function Conduct-IndividualExecution {
            $ExecutionStartTime = Get-Date 

            $PoSHEasyWin.Controls.Add($ProgressBarEndpointsLabel)
            $PoSHEasyWin.Controls.Add($script:ProgressBarEndpointsProgressBar)
            $PoShEasyWin.Controls.Add($ProgressBarQueriesLabel)
            $PoSHEasyWin.Controls.Add($script:ProgressBarQueriesProgressBar)

            $script:CollectedDataTimeStampDirectory = $script:CollectionSavedDirectoryTextBox.Text
            New-Item -Type Directory -Path $script:CollectedDataTimeStampDirectory -ErrorAction SilentlyContinue

            # This executes each selected command from the Commands' TreeView
            if ($script:CommandsCheckedBoxesSelected.count -gt 0) { . "$Dependencies\Code\Execution\Individual Execution\Execute-IndividualCommands.ps1" }

            # Event Logs Event IDs Manual Entry
            if ($EventLogsEventIDsManualEntryCheckbox.Checked) { . "$Dependencies\Code\Execution\Individual Execution\IndividualQuery-EventLogsEventCodeManualEntryCommand.ps1" }

            # Event Logs Event IDs Quick Pick Selection
            if ($EventLogsQuickPickSelectionCheckbox.Checked) { . "$Dependencies\Code\Execution\Individual Execution\IndividualQuery-EventLogsQuickPick.ps1" }

            # Event Logs Event IDs To Monitor
            if ($EventLogsEventIDsToMonitorCheckbox.Checked) { . "$Dependencies\Code\Execution\Individual Execution\IndividualQuery-EventLogsEventIDsToMonitor.ps1" }

            # Registry Search
            if ($RegistrySearchCheckbox.checked) { . "$Dependencies\Code\Execution\Individual Execution\IndividualQuery-RegistrySearch.ps1" }

            # Directory Listing
            # Combines the inputs from the various GUI fields to query for directory listings
            if ($FileSearchDirectoryListingCheckbox.Checked) { . "$Dependencies\Code\Execution\Individual Execution\IndividualQuery-DirectoryListing.ps1" ; $RetrieveFilesButton.BackColor = 'LightGreen' }

            # File Search
            # Combines the inputs from the various GUI fields to query for filenames and/or file hashes
            if ($FileSearchFileSearchCheckbox.Checked) { . "$Dependencies\Code\Execution\Individual Execution\IndividualQuery-FilenameAndFileHash.ps1" ; $RetrieveFilesButton.BackColor = 'LightGreen' }

            # Alternate Data Streams
            # Combines the inputs from the various GUI fields to query for Alternate Data Streams
            if ($FileSearchAlternateDataStreamCheckbox.Checked) { . "$Dependencies\Code\Execution\Individual Execution\IndividualQuery-AlternateDataStream.ps1" ; $RetrieveFilesButton.BackColor = 'LightGreen' }

            # Network Connection Search Remote IP Address 
            # Checks network connections for remote ip addresses and only returns those that match
            if ($NetworkConnectionSearchRemoteIPAddressCheckbox.checked) { . "$Dependencies\Code\Execution\Individual Execution\IndividualQuery-NetworkConnectionRemoteIPAddress.ps1" }
            
            # Network Connection Search Remote Port 
            # Checks network connections for remote ports and only returns those that match
            if ($NetworkConnectionSearchRemotePortCheckbox.checked) { . "$Dependencies\Code\Execution\Individual Execution\IndividualQuery-NetworkConnectionRemotePort.ps1" }

            # Network Connection Search Local Port 
            # Checks network connections for remote ports and only returns those that match
            if ($NetworkConnectionSearchLocalPortCheckbox.checked) { . "$Dependencies\Code\Execution\Individual Execution\IndividualQuery-NetworkConnectionLocalPort.ps1" }

            # Network Connection Search Remote Process 
            # Checks network connections for those started by a specified process name and only returns those that match
            if ($NetworkConnectionSearchProcessCheckbox.checked) { . "$Dependencies\Code\Execution\Individual Execution\IndividualQuery-NetworkConnectionProcess.ps1" }

            # Network Connection Search DNS Cache
            # Checks dns cache for the provided search terms and only returns those that match
            if ($NetworkConnectionSearchDNSCacheCheckbox.checked) { . "$Dependencies\Code\Execution\Individual Execution\IndividualQuery-NetworkConnectionSearchDNSCache.ps1" }

            # Sysmon
            # Pushes Sysmon to remote hosts and configure it with the selected config .xml file
            # If sysmon is already installed, it will update the config .xml file instead
            # Symon and its supporting files are removed afterwards
            if ($SysinternalsSysmonCheckbox.Checked) { . "$Dependencies\Code\Execution\Individual Execution\IndividualPush-Sysmon.ps1" }

            # Autoruns
            # Pushes Autoruns to remote hosts and pulls back the autoruns results to be opened locally
            # Autoruns and its supporting files are removed afterwards
            if ($SysinternalsAutorunsCheckbox.Checked) { . "$Dependencies\Code\Execution\Individual Execution\IndividualPush-Autoruns.ps1" }

            # Procmon
            # Pushes Process Monitor to remote hosts and pulls back the procmon results to be opened locally
            # Diskspace is calculated on local and target hosts to determine if there's a risk
            # Process Monitor and its supporting files are removed afterwards
            if ($SysinternalsProcessMonitorCheckbox.Checked) { . "$Dependencies\Code\Execution\Individual Execution\IndividualPush-Procmon.ps1" }        
            
            Completed-QueryExecution
        }

        if ($NoGui -and $script:RpcCommandCount -gt 0 -and $CommandCountTotalBothQueryAndSection -gt 0 ) {
            Conduct-IndividualExecution
        }
        elseif ($CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Individual Execution' -and $script:RpcCommandCount -gt 0 -and $CommandCountTotalBothQueryAndSection -gt 0 ) {
            Conduct-IndividualExecution
        }
        elseif ($CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Individual Execution' -and $script:RpcCommandCount -eq 0 ) {
            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add('No RPC Commands Selected')
            $MessageBox = [System.Windows.Forms.MessageBox]::Show("Only WinRM based commands were select.`nDo you want to change to 'Session Based' querying instead?`n`nThis would be faster and not as noisy on the network.","Optimize Performance",'YesNoCancel','Info')
            Switch ( $MessageBox ) {
                'Yes' {
                    $CommandTreeViewQueryMethodSelectionComboBox.SelectedIndex = 2 #'Session Based'
                }
                'No' {
                    Conduct-IndividualExecution
                }
                'Cancel' {
                    $StatusListBox.Items.Clear()
                    $StatusListBox.Items.Add('Individual Execution Cancelled')
                }
            }
        }
        #=======================================================================================================================================================================
        #    ____                          _  _            _     ____               _         _       _____                          _    _               
        #   / ___| ___   _ __ ___   _ __  (_)| |  ___   __| |   / ___|   ___  _ __ (_) _ __  | |_    | ____|__  __ ___   ___  _   _ | |_ (_)  ___   _ __  
        #  | |    / _ \ | '_ ` _ \ | '_ \ | || | / _ \ / _` |   \___ \  / __|| '__|| || '_ \ | __|   |  _|  \ \/ // _ \ / __|| | | || __|| | / _ \ | '_ \ 
        #  | |___| (_) || | | | | || |_) || || ||  __/| (_| |    ___) || (__ | |   | || |_) || |_    | |___  >  <|  __/| (__ | |_| || |_ | || (_) || | | |
        #   \____|\___/ |_| |_| |_|| .__/ |_||_| \___| \__,_|   |____/  \___||_|   |_|| .__/  \__|   |_____|/_/\_\\___| \___| \__,_| \__||_| \___/ |_| |_|
        #                          |_|                                                |_|                                                                 
        #=======================================================================================================================================================================
        # Code that compiles individual command treenodes into one to execute
        # A single compiled query for command nodes is sent to the hosts and when results are returned are automatcially 
        # saved to their own local csv files
        # This is faster when collecting data as only a single job per remote host is started locally for command treenode queries
        # The secondary progress bar is removed as it cannnot track compile queries

        elseif ($CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Compiled Script' -and $CommandCountTotalBothQueryAndSection -gt 0 ) {
            $ExecutionStartTime = Get-Date 
            
            # Compiles the individual commands into an object hashtable '$script:QueryCommands'
            . "$Dependencies\Code\Execution\Compiled Script\Compile-QueryCommands.ps1"

            $PoSHEasyWin.Controls.Add($ProgressBarEndpointsLabel)
            $PoSHEasyWin.Controls.Add($script:ProgressBarEndpointsProgressBar)
            $PoShEasyWin.Controls.Remove($ProgressBarQueriesLabel)
            $PoSHEasyWin.Controls.Remove($script:ProgressBarQueriesProgressBar)
            Count-SectionQueries

            if ($script:SectionQueryCount -gt 0) {
                # This brings specific tabs to the forefront/front view
                $MainLeftTabControl.SelectedTab = $Section1CollectionsTab
                $MainBottomTabControl.SelectedTab = $Section3ResultsTab

                [system.media.systemsounds]::Exclamation.play()
                $MessageBox = [System.Windows.Forms.MessageBox]::Show("This mode does not currently support pushing:`nSysMon, AutoRuns, and ProcMon`n`nNor does it support the following sections:`nEventLogs, Registry, File Search, Network Connections","Compiled Script Error",[System.Windows.Forms.MessageBoxButtons]::OK)
            }
            else {
                Compile-QueryCommands
                
                # Prior to script execution, this launches a form to pre-view the script, allowing you to verify and edit its contents priot to being sent to endpoints                 
                #------------------------------
                # Command Review and Edit Form
                #------------------------------
                $CommandReviewEditForm = New-Object System.Windows.Forms.Form -Property @{
                    width         = 1025
                    height        = 525
                    StartPosition = "CenterScreen"
                    Text          = ”Collection Script - Review, Edit, and Verify”
                    Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$Dependencies\Images\favicon.ico")
                    ControlBox    = $true
                    Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
                }
                    #-------------------------------
                    # Command Reveiw and Edit Label
                    #-------------------------------
                    $CommandReviewEditLabel = New-Object System.Windows.Forms.Label -Property @{
                        Text      = "Edit The Script Block:"
                        Location  = @{ X = 5
                                       Y = 8 }
                        Size      = @{ Height = 25
                                       Width  = 160 }
                        ForeColor = "Blue"
                        Font      = New-Object System.Drawing.Font("$Font",14,0,0,0)
                    }
                    $CommandReviewEditForm.Controls.Add($CommandReviewEditLabel)

                    #--------------------------------------------
                    # Command Reveiw and Edit Enable RadioButton
                    #--------------------------------------------
                    $CommandReviewEditEnabledRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                        Text      = "Yes"
                        Location  = @{ X = $CommandReviewEditLabel.Location.X + $CommandReviewEditLabel.Size.Width + 20
                                       Y = 5 }
                        Size      = @{ Height = 25
                                       Width  = 50 }
                        Checked   = $false
                        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
                    }
                    $CommandReviewEditEnabledRadioButton.Add_Click({ 
                        $script:CommandReviewEditRichTextbox.BackColor = 'White' 
                        $script:CommandReviewEditRichTextbox.ReadOnly  = $False 
                    })
                    $CommandReviewEditEnabledRadioButton.Add_MouseHover({
                        Show-ToolTip -Title "Enable Script Editing" -Icon "Info" -Message @"
+  The script below is generated by the selections made.
+  Use caustion if editing, charts use the hashtable name field.
"@                  })
                    $CommandReviewEditForm.Controls.Add($CommandReviewEditEnabledRadioButton)

                    #---------------------------------------------
                    # Command Reveiw and Edit Disable RadioButton
                    #---------------------------------------------
                    $CommandReviewEditDisabledRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                        Text     = "No"
                        Location = @{ X = $CommandReviewEditEnabledRadioButton.Location.X + $CommandReviewEditEnabledRadioButton.Size.Width + 10
                                      Y = 5 }
                        Size     = @{ Height = 25
                                      Width  = 50 }
                        Checked  = $true
                        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
                    }
                    $CommandReviewEditDisabledRadioButton.Add_Click({ 
                        $script:CommandReviewEditRichTextbox.BackColor = 'LightGray' 
                        $script:CommandReviewEditRichTextbox.ReadOnly  = $True 
                    })
                    $CommandReviewEditDisabledRadioButton.Add_MouseHover({
                        Show-ToolTip -Title "Disable Script Editing" -Icon "Info" -Message @"
+  The script below is generated by the selections made.
+  Use caustion if editing, charts use the hashtable name field.
"@                  })
                    $CommandReviewEditForm.Controls.Add($CommandReviewEditDisabledRadioButton)

                    #-------------------------------------------
                    # Command Reveiw Reload Normal & Raw Button
                    #-------------------------------------------
                    $CommandReviewReloadNormalRawButton = New-Object System.Windows.Forms.Button -Property @{
                        Text      = "Reload Script (Raw)"
                        Location  = @{ X = $CommandReviewEditDisabledRadioButton.Location.X + $CommandReviewEditDisabledRadioButton.Size.Width + 25 
                                    Y = 7 }
                        Size      = @{ Height = 22
                                    Width  = 175 }
                    }
                    CommonButtonSettings -Button $CommandReviewReloadNormalRawButton
                    $CommandReviewReloadNormalRawButton.Add_MouseHover({
                        Show-ToolTip -Title "Reload Script - Normal" -Icon "Info" -Message @"
+  When command treenode scripts are selected, they may load without return carriages depending on how they were created/formatted 
+  To mitigate this, you can reload to get the scirpt's content normally or in a raw format
"@                  })
                    $CommandReviewReloadNormalRawButton.Add_Click({ 
                        if ($CommandReviewReloadNormalRawButton.Text -eq "Reload Script (Raw)") { 
                            Compile-QueryCommands -raw
                            $CommandReviewReloadNormalRawButton.Text = "Reload Script (Normal)" 
                        }
                        else { 
                            Compile-QueryCommands
                            $CommandReviewReloadNormalRawButton.Text = "Reload Script (Raw)" 
                        }
                        Buffer-CommandReviewString
                    })
                    $CommandReviewEditForm.Controls.Add($CommandReviewReloadNormalRawButton)


                    #-----------------------------------------------
                    # Command Review Script Block ByteCount Textbox
                    #-----------------------------------------------
                    $CommandReviewScriptBlockByteCountTextbox = New-Object System.Windows.Forms.TextBox -Property @{
                        Location  = @{ X = $CommandReviewReloadNormalRawButton.Location.X + $CommandReviewReloadNormalRawButton.Size.Width + 25 
                                       Y = 7 }
                        Size      = @{ Height = 22
                                       Width  = 100 }
                    }
                    $CommandReviewEditForm.Controls.Add($CommandReviewScriptBlockByteCountTextbox)


                    #-----------------------------------------
                    # Command Reveiw and Edit Verify Checkbox
                    #-----------------------------------------
                    $CommandReviewEditVerifyCheckbox = New-Object System.Windows.Forms.Checkbox -Property @{
                        Text      = 'Verify'
                        Font      = New-Object System.Drawing.Font("$Font",14,0,0,0)
                        Location  = @{ X = 790
                                    Y = 6 }
                        Size      = @{ Height = 26
                                    Width  = 75 }
                        Checked   = $false
                    }
                    $CommandReviewEditVerifyCheckbox.Add_Click({
                        if ($CommandReviewEditVerifyCheckbox.checked){
                            $CommandReviewEditExecuteButton.Enabled   = $true
                            $CommandReviewEditExecuteButton.Text      = "Execute"
                            $CommandReviewEditExecuteButton.ForeColor = "Green"
                        }
                        else {
                            $CommandReviewEditExecuteButton.Enabled   = $false
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
                        Location  = @{ X = 879
                                    Y = 5 }
                        Size      = @{ Height = 25
                                    Width  = 100 }
                    }
                    CommonButtonSettings -Button $CommandReviewEditExecuteButton
                    $CommandReviewEditExecuteButton.Add_Click({ 
                        $script:CommandReviewEditRichTextbox.SaveFile("C:\Richtext_RTF.rtf")
                        $CommandReviewEditForm.close() 
                    })
                    $CommandReviewEditExecuteButton.Add_MouseHover({
                        Show-ToolTip -Title "Cancel or Execute" -Icon "Info" -Message @"
+  To Cancel, you need to uncheck the verify box.
+  To Execute, you first need to check the verify box.
+  First verify the contents of the script and edit if need be.
+  When executed, the compiled script is ran against each selected computer.
+  The results return as one object, then are locally extracted and saved individually.
+  The results for each section are saved individually by host and query.
+  The results are also compiled by query into a single file containing every host.
+  The code is executed within a PowerShel Job for each destination host.
+  The compiled commands reduce the amount of network traffic.
+  This method is faster, but requires more RAM on the target host.
+  Use caustion if editing, charts use the hashtable name field.
"@                  })
                    $CommandReviewEditForm.Controls.Add($CommandReviewEditExecuteButton)

                    #---------------------------------
                    # Command Review and Edit Textbox
                    #---------------------------------
                    $script:CommandReviewEditRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
                        Location = @{ X = 5
                                      Y = 35 }
                        Size     = @{ Height = 422
                                      Width  = 974 }
                        Font       = New-Object System.Drawing.Font("Courier New",11,0,0,0)
                        Multiline  = $True
                        ScrollBars = 'Vertical'
                        WordWrap   = $True
                        ReadOnly   = $True
                        BackColor  = 'LightGray' #LightSteelBlue
                        ShortcutsEnabled = $true
                        Add_KeyDown = { 
                            if ($_.KeyCode) { $CommandReviewScriptBlockByteCountTextbox.Text = "$([System.Text.Encoding]::UTF7.GetByteCount($($script:CommandReviewEditRichTextbox.Text))) bytes" } 
                        }
                    }
                    $CommandReviewEditForm.Controls.Add($script:CommandReviewEditRichTextbox)

                    #--------------------------------
                    # Command Reveiw and Edit String
                    #--------------------------------
                    # This is the string that contains the command(s) to query, it is iterated over $targetcomputer

                    function Buffer-CommandReviewString {

                        if ($ComputerListProvideCredentialsCheckBox.Checked) {
                            if (!$script:Credential) { Create-NewCredentials }
                            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Credentials Used: $($script:Credential.UserName)"
                        $script:CommandReviewString = @"
Invoke-Command -Credential `$script:Credential -ComputerName `$TargetComputer -ScriptBlock {
    param(`$TargetComputer) 
    `$QueryResults = @{}


"@
                        } # END if
                        else {
                            $script:CommandReviewString = @"
Invoke-Command -ComputerName `$TargetComputer -ScriptBlock {
    param(`$TargetComputer) 
    `$QueryResults = @{}


"@
                        } # END else
                        $QueryCommandsCount = 0
                        ForEach ($Query in $($script:QueryCommands.keys)) {
                            $QueryCommandsCount++
                            $script:CommandReviewString += @"
    #===================================================================================================
    # Query $($QueryCommandsCount): $($script:QueryCommands[$Query]['Name'])
    #===================================================================================================

"@
                           # if ($($script:QueryCommands[$Query]['Properties']) -eq $null) {
                                $script:CommandReviewString += @"
    `$QueryResults += @{
        '$($script:QueryCommands["$Query"]["Name"])' = @{
            'Name'    = "$($script:QueryCommands[$Query]['Name']) -- `$TargetComputer"
            'Results' = `$($($script:QueryCommands[$Query]['Command'])
            )
        }
    }


"@
                          #  } # END if
                         <#   else {
                                $script:CommandReviewString += @"
    `$QueryResults += @{
        '$($script:QueryCommands["$Query"]["Name"])' = @{
            'Name'    = "$($script:QueryCommands[$Query]['Name']) -- `$TargetComputer"
            'Results' = `$($($script:QueryCommands[$Query]['Command']) | Select-Object -Property $($script:QueryCommands[$Query]['Properties'].replace('PSComputerName','@{Name="PSComputerName";Expression={$env:ComputerName}}'))
            ) # END 'Results'
        } # END '$($script:QueryCommands["$Query"]["Name"])'
    } # END `$QueryResults


"@
                            } # END else #>
                        } # END ForEach
                        $script:CommandReviewString += @"
    return `$QueryResults
} -ArgumentList @(`$TargetComputer)
"@
# This returns the results of all the queries as a single object with nested object data,
# which is then locally processed and separated into its individual result .CSVs files

                        $script:CommandReviewEditRichTextbox.text = $script:CommandReviewString
                        $CommandReviewScriptBlockByteCountTextbox.Text = "$([System.Text.Encoding]::UTF7.GetByteCount($script:CommandReviewString)) bytes"
                    }
                    Buffer-CommandReviewString
            
                $CommandReviewEditForm.ShowDialog() | Out-Null 

                # Executes Compiled Script if the code is verified
                . "$Dependencies\Code\Execution\Compiled Script\Execute-CompiledScriptIfVerified.ps1"
            }
        }

        #=======================================================================================================================================================================
        #   ____                   _                   ____                         _     _____                          _    _               
        #  / ___|   ___  ___  ___ (_)  ___   _ __     | __ )   __ _  ___   ___   __| |   | ____|__  __ ___   ___  _   _ | |_ (_)  ___   _ __  
        #  \___ \  / _ \/ __|/ __|| | / _ \ | '_ \    |  _ \  / _` |/ __| / _ \ / _` |   |  _|  \ \/ // _ \ / __|| | | || __|| | / _ \ | '_ \ 
        #   ___) ||  __/\__ \\__ \| || (_) || | | |   | |_) || (_| |\__ \|  __/| (_| |   | |___  >  <|  __/| (__ | |_| || |_ | || (_) || | | |
        #  |____/  \___||___/|___/|_| \___/ |_| |_|   |____/  \__,_||___/ \___| \__,_|   |_____|/_/\_\\___| \___| \__,_| \__||_| \___/ |_| |_|
        #
        #=======================================================================================================================================================================
        # A session is established to each endpoint, and queries are executed through it

        elseif ($CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Session Based' -and $script:RpcCommandCount -eq 0 -and $CommandCountTotalBothQueryAndSection -gt 0 ) {
            $ExecutionStartTime = Get-Date 

            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("Attempting to Establish Sessions to $($ComputerList.Count) Endpoints")
            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Attempting to Establish Sessions to $($ComputerList.Count) Endpoints"
            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "[!] $($ComputerList -join ', ')"

            $PoSHEasyWin.Controls.Add($ProgressBarEndpointsLabel)
            $PoSHEasyWin.Controls.Add($script:ProgressBarEndpointsProgressBar)
            $PoShEasyWin.Controls.Add($ProgressBarQueriesLabel)
            $PoSHEasyWin.Controls.Add($script:ProgressBarQueriesProgressBar)            
            #$script:ProgressBarQueriesProgressBar.Maximum = $CommandCountTotalBothQueryAndSection           
            if ($NoGUI) { $ProgressBarQueriesCommandLineMaximum = ($script:CommandsCheckedBoxesSelected).count }

            $script:CollectedDataTimeStampDirectory = $script:CollectionSavedDirectoryTextBox.Text
            New-Item -Type Directory -Path $script:CollectedDataTimeStampDirectory -ErrorAction SilentlyContinue

            if ($ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { Create-NewCredentials }
                $PSSession = New-PSSession -ComputerName $ComputerList -Credential $script:Credential | Sort-Object ComputerName
            }
            else {
                $PSSession = New-PSSession -ComputerName $ComputerList | Sort-Object ComputerName
            }

            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Session Based Collection Started to $($PSSession.count) Endpoints"
            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "New-PSSession -ComputerName $($PSSession.ComputerName -join ', ')"

            # Unchecks hosts that do not have a session established
            . "$Dependencies\Code\Execution\Session Based\Uncheck-ComputerTreeNodesWithoutSessions.ps1"

            if ($PSSession.count -eq 1) { 
                $ResultsListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  Session Created to $($PSSession.count) Endpoint")
            }
            elseif ($PSSession.count -gt 1) { 
                $ResultsListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  Sessions Created to $($PSSession.count) Endpoints")
            }
            else {                
                $ResultsListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  No Sessions Created")
                [system.media.systemsounds]::Exclamation.play()
            }
            $PoShEasyWin.Refresh()

            $script:ProgressBarQueriesProgressBar.Maximum   = $CountCommandQueries
            $script:ProgressBarEndpointsProgressBar.Maximum = ($PSSession.ComputerName).Count

            
            if ($PSSession.count -ge 1) {
                New-Item -ItemType Directory -Path "$($script:CollectionSavedDirectoryTextBox.Text)" -Force
        
                # Individual Queries
                if ($script:CommandsCheckedBoxesSelected.count -gt 0) { . "$Dependencies\Code\Execution\Session Based\SessionQuery-IndividualQueries.ps1" }

                # Event Logs Event IDs Manual Entry
                if ($EventLogsEventIDsManualEntryCheckbox.Checked) { . "$Dependencies\Code\Execution\Session Based\SessionQuery-EventLogsEventIDsManualEntry.ps1" }

                # Event Logs Event IDs Quick Pick Selection
                if ($EventLogsQuickPickSelectionCheckbox.Checked) { . "$Dependencies\Code\Execution\Session Based\SessionQuery-EventLogsQuickPickSelection.ps1" }

                # Event Logs Event IDs To Monitor
                if ($EventLogsEventIDsToMonitorCheckbox.Checked) { . "$Dependencies\Code\Execution\Session Based\SessionQuery-EventLogsEventIDsToMonitor.ps1" }

                # Registry Search
                if ($RegistrySearchCheckbox.checked) { . "$Dependencies\Code\Execution\Session Based\SessionQuery-RegistrySearch.ps1" }

                # Directory Listing
                # Combines the inputs from the various GUI fields to query for directory listings
                if ($FileSearchDirectoryListingCheckbox.Checked) { . "$Dependencies\Code\Execution\Session Based\SessionQuery-FileSearchDirectoryListing.ps1" ; $RetrieveFilesButton.BackColor = 'LightGreen' }

                # File Search
                # Combines the inputs from the various GUI fields to query for filenames and/or file hashes
                if ($FileSearchFileSearchCheckbox.Checked) { . "$Dependencies\Code\Execution\Session Based\SessionQuery-FileSearchFileSearch.ps1" ; $RetrieveFilesButton.BackColor = 'LightGreen' }

                # Alternate Data Stream
                # Combines the inputs from the various GUI fields to query for Alternate Data Streams
                if ($FileSearchAlternateDataStreamCheckbox.Checked) { . "$Dependencies\Code\Execution\Session Based\SessionQuery-FileSearchAlternateDataStream.ps1" ; $RetrieveFilesButton.BackColor = 'LightGreen' } 
            
                # Network Connection Search Remote IP Address
                # Checks network connections for remote ip addresses and only returns those that match
                if ($NetworkConnectionSearchRemoteIPAddressCheckbox.checked) { . "$Dependencies\Code\Execution\Session Based\SessionQuery-NetworkConnectionSearchRemoteIPAddress.ps1" }

                # Network Connection Search Remote Port
                # Checks network connections for remote ports and only returns those that match
                if ($NetworkConnectionSearchRemotePortCheckbox.checked) { . "$Dependencies\Code\Execution\Session Based\SessionQuery-NetworkConnectionSearchRemotePort.ps1" }

                # Network Connection Search Local Port
                # Checks network connections for Local ports and only returns those that match
                if ($NetworkConnectionSearchLocalPortCheckbox.checked) { . "$Dependencies\Code\Execution\Session Based\SessionQuery-NetworkConnectionSearchLocalPort.ps1" }

                # Network Connection Search Process
                # Checks network connections for those started by a specified process name and only returns those that match
                if ($NetworkConnectionSearchProcessCheckbox.checked) { . "$Dependencies\Code\Execution\Session Based\SessionQuery-NetworkConnectionSearchProcess.ps1" }

                # Network Connection Search DNS Check
                # Checks dns cache for the provided search terms and only returns those that match
                if ($NetworkConnectionSearchDNSCacheCheckbox.checked) { . "$Dependencies\Code\Execution\Session Based\SessionQuery-NetworkConnectionSearchDNSCache.ps1" }

                # Sysmon
                # Pushes Sysmon to remote hosts and configure it with the selected config .xml file
                # If sysmon is already installed, it will update the config .xml file instead
                # Symon and its supporting files are removed afterwards
                if ($SysinternalsSysmonCheckbox.Checked) { . "$Dependencies\Code\Execution\Session Based\SessionPush-SysMon.ps1" }

                # AutoRuns
                # Pushes Autoruns to remote hosts and pulls back the autoruns results to be opened locally
                # Autoruns and its supporting files are removed afterwards
                if ($SysinternalsAutorunsCheckbox.Checked) { . "$Dependencies\Code\Execution\Session Based\SessionPush-AutoRuns.ps1" }

                # ProcMon
                # Pushes Process Monitor to remote hosts and pulls back the procmon results to be opened locally
                # Diskspace is calculated on local and target hosts to determine if there's a risk
                # Process Monitor and its supporting files are removed afterwards
                if ($SysinternalsProcessMonitorCheckbox.Checked) { . "$Dependencies\Code\Execution\Session Based\SessionPush-ProcMon.ps1" }

                ######################################
                # End of Session Based Querying
                ######################################
                Get-ChildItem -Path "$($script:CollectionSavedDirectoryTextBox.Text)\*.csv" | Where-Object Length -eq 0 | Remove-Item -Force

                Get-PSSession | Remove-PSSession
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Remove-PSSession -ComputerName $($PSSession.ComputerName -join ', ')"

                if     ($PSSession.count -eq 1) { $ResultsListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  Session Removed to $($PSSession.count) Endpoint") }
                elseif ($PSSession.count -gt 1) { $ResultsListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  Sessions Removed to $($PSSession.count) Endpoints") }
                $PoShEasyWin.Refresh()          

                Completed-QueryExecution
            }
        }
    }

    $MainCenterTabControl.SelectedTab = $MainCenterMainTab
        if ($MainCenterTabControl.SelectedTab -match 'Main') {
            $MainCenterTabControl.Width  = 370
            $MainCenterTabControl.Height = 278
        }
        $PoShEasyWin.Refresh()
}

# Selects the computers to query using command line parameters and arguments
. "$Dependencies\Code\Execution\Command Line\Select-ComputersAndCommandsFromCommandLine.ps1"

# This needs to be here to execute the script
# Note the Execution button itself is located in the Select Computer section
$ComputerListExecuteButton.Add_Click($ExecuteScriptHandler)

# Correct the initial state of the form to prevent the .Net maximized form issue
$InitialFormWindowState     = New-Object System.Windows.Forms.FormWindowState
$OnLoadForm_StateCorrection = { $PoShEasyWin.WindowState = $InitialFormWindowState }

#Save the initial state of the form
#$InitialFormWindowState = $PoShEasyWin.WindowState

#Init the OnLoad event to correct the initial state of the form
$PoShEasyWin.add_Load($OnLoadForm_StateCorrection)

#Show the Form
if ($NoGUI) {
    #Write-Host -ForegroundColor Green 'Using PoSh-EasyWin in command line mode.'
    continue
}
else {
    $PoShEasyWin.ShowDialog() | Out-Null 
}
