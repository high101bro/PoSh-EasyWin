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
    Version        : v.5.1.7 Beta

    Requirements   : PowerShell v3.0 for PowerShell Charts support
                     PowerShell v5.1 for PSWriteHTML Module support
                   : WinRM   HTTP  - TCP/5985 Windows 7+ ( 80 Vista-)
                             HTTPS - TCP/5986 Windows 7+ (443 Vista-)
                             Endpoint Listener - TCP/47001
                   : DCOM    RPC   - TCP/135 and dynamic ports, typically:
                                     TCP 49152-65535 (Windows Vista, Server 2008 and above)
                                     TCP 1024 -65535 (Windows NT4, Windows 2000, Windows 2003)
    Optional       : PsExec.exe, Procmon.exe, Autoruns.exe, Sysmon.exe,
                     etl2pcapng.exe, WinPmem.exe
                     wKillcx is a small command-line utility to close any TCP connection under Windows XP/Vista/Seven as well as Windows Server 2003/2008. The source code (assembly language) is included with the binary.

    Updated        : 28 Nov 2020
    Created        : 21 Aug 2018

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

    TODO:
    winrm get winrm/config/winrs

    .EXAMPLE
    This will run PoSh-EasyWin.ps1 and provide prompts that will tailor your collection.

        PowerShell.exe -ExecutionPolicy ByPass -NoProfile -File .\PoSh-EasyWin.ps1

    .LINK
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
    PositionalBinding = $true)]

#https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters?view=powershell-7
param (
    [Parameter(
        Mandatory=$false,
        HelpMessage="The provided credentials will launch PoSh-EasyWin, and is subsequentially used for querying unless otherwise changed.")]
    [ValidateNotNullOrEmpty()]
    [System.Management.Automation.PSCredential] $Credential,


    [Parameter(
        Mandatory=$false,
        HelpMessage="Skips the terminal privledge elevation check to run with higher permissions.")]
    [switch]$SkipEvelationCheck,


    [Parameter(
        Mandatory=$false,
        HelpMessage="Launches PoSh-EasyWin without hiding the parent PowerShell Terminal.")]
    [switch]$ShowTerminal,


    [Parameter(
        Mandatory=$true,
        ParameterSetName="No GUI Computer Name",
        ValueFromPipeline=$true,
        HelpMessage="Enter one or more computer names separated by commas, or imported from a file as an array. Entries will only query if they already exist within script.")]
    [Alias('PSComputerName','CN','MachineName')]
    [ValidateLength(1,63)]
        # NetBIOS Names Lenghts:   1-15
        # DNS Name Lengths:        2-63
    [ValidateNotNullOrEmpty()]
    [string[]] $ComputerName,


            [Parameter(
                Mandatory=$false,
                ParameterSetName="No GUI Computer Name",
                HelpMessage="Enter a sting(s) to filter out computers whose name matches in part or in whole.")]
            [Parameter(
                Mandatory=$false,
                ParameterSetName="No GUI Computer Search",
                HelpMessage="Enter a sting(s) to filter out computers whose name matches in part or in whole.")]
            [string[]] $FilterOutComputer,


            [Parameter(
                Mandatory=$false,
                ParameterSetName="No GUI Computer Name",
                HelpMessage="Enter a string(s) to filter back in computer names that were filtered out.")]
            [Parameter(
                Mandatory=$false,
                ParameterSetName="No GUI Computer Search",
                HelpMessage="Enter a string(s) to filter back in computer names that were filtered out.")]
            [string[]] $FilterInComputer,


    [Parameter(
        Mandatory=$false,
        ParameterSetName="No GUI Computer Name",
        HelpMessage="Only the selected Protocol will be displayed.")]
    [Parameter(
        Mandatory=$false,
        ParameterSetName="No GUI Computer Search",
        HelpMessage="Only the selected Protocol will be displayed.")]
    [ValidateSet('RPC','WinRM')]
    [string] $Protocol,


    [Parameter(
        Mandatory=$false,
        ParameterSetName="No GUI Computer Name",
        HelpMessage="Location where to save collected data.")]
    [Parameter(
        Mandatory=$false,
        ParameterSetName="No GUI Computer Search",
        HelpMessage="Location where to save collected data.")]
    [string]
    $SaveDirectory = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)\Collected Data\$((Get-Date).ToString('yyyy-MM-dd @ HHmm ss'))",


    [Parameter(
        Mandatory=$false,
        ParameterSetName="GUI")]
    [Parameter(
        Mandatory=$false,
        ParameterSetName="No GUI Computer Name",
        HelpMessage="Enter the amount of time in seconds that a command will run until it timesout. The default is 300 seconds.")]
    [Parameter(
        Mandatory=$false,
        ParameterSetName="No GUI Computer Search",
        HelpMessage="Enter the amount of time in seconds that a command will run until it timesout. The default is 300 seconds.")]
    [ValidateRange(30,600)]
    #[ValidatePattern("[0-9][0-9][0-9][0-9]")]
    [ValidateNotNullOrEmpty()]
    [int] $JobTimeOutSeconds = 120,


    [Parameter(
        Mandatory=$false,
        ParameterSetName="GUI",
        HelpMessage="The default font used in the GUI is Courier, but the following fonts also valdated.")]
    [ValidateSet('Calibri','Courier','Arial')]
        # This this validation set is expanded, ensure that larger fonts don't cause words to be truncated in the GUI
    [ValidateNotNull()]
    [string] $Font = "Courier",


    [Parameter(
        Mandatory=$false,
        HelpMessage="Enables the audiable voice completion message at the end of queries/collections.")]
    [switch] $AudibleCompletionMessage


<#
    # Removed because of inconsistent Winform scaling. The Out-GridView used to show the Copyright/EULA also had the quirk of changing the scaling of WinForms.
    # I cannot find a solution online, but the OGV EULA allowed forced the quirk to happen, allowing for some level of consistency when scaling the GUI.
    # The -AcceptEULA switch, although useful to bypass the EULA, is not currently implemented until I can find a better solution with the scaling.
    [Parameter(
        Mandatory=$false,
        ParameterSetName="GUI")]
    [Parameter(
        Mandatory=$false,
        ParameterSetName="No GUI Computer Name",
        HelpMessage="Accepts the End User License Agreement (EULA). The GUI for the GNU GPL wont display.")]
    [Parameter(
        Mandatory=$false,
        ParameterSetName="No GUI Computer Search",
        HelpMessage="Accepts the End User License Agreement (EULA). The GUI for the GNU GPL wont display.")]
    [switch] $AcceptEULA
#>
)

# Generates the GUI and contains the majority of the script
Add-Type -AssemblyName System.Windows.Forms
    #[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
Add-Type -AssemblyName System.Drawing
    #[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null


#============================================================================================================================================================
# Variables
#============================================================================================================================================================

# Universally sets the ErrorActionPreference to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

# Script Launch Time - This in placed within both the title of the Main PoSh-EasyWin form and the title of the System Tray Notification
# Useful if multiple instances of PoSh-EasyWin are launched and you want to use the Abort/Reload or Exit Tool buttons on the corrent instance
$InitialScriptLoadTime = Get-Date


# Location PoSh-EasyWin will save files
$PoShHome                         = $PSScriptRoot #Deprecated# Split-Path -parent $MyInvocation.MyCommand.Definition
    # Creates settings directory
    $PoShSettings                 = "$PoShHome\Settings"

    # The path of PoSh-EasyWin when executed
    $ThisScriptPath               = $myinvocation.mycommand.definition
    $ThisScript                   = "& '$ThisScriptPath'"

    $LogFile                      = "$PoShHome\Log File.txt"
    $IPListFile                   = "$PoShHome\iplist.txt"

    $ComputerTreeNodeFileAutoSave = "$PoShHome\Computer List TreeView (Auto-Save).csv"
    $ComputerTreeNodeFileSave     = "$PoShHome\Computer List TreeView (Saved).csv"

    $OpNotesFile                  = "$PoShHome\OpNotes.txt"
    $OpNotesWriteOnlyFile         = "$PoShHome\OpNotes (Write Only).txt"

    $script:CredentialManagementPath = "$PoShHome\Credential Management\"

    # Dependencies
    $Dependencies                             = "$PoShHome\Dependencies"
        # Location of Cmds & Scripts
        $QueryCommandsAndScripts              = "$Dependencies\Cmds & Scripts"

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
        $CustomPortsToScan                    = "$Dependencies\Custom Ports To Scan.txt"

        # This PoSh-EasyWin Form Icon
        $EasyWinIcon                          = "$Dependencies\Images\favicon.ico"

        # Directory where auto saved chart images are saved
    $AutosavedChartsDirectory                 = "$PoShHome\Autosaved Charts"

    # Name of Collected Data Directory
    $CollectedDataDirectory                   = "$PoShHome\Collected Data"
        if (-not (Test-Path $CollectedDataDirectory )) {New-Item -ItemType Directory -Path $CollectedDataDirectory -Force}
        $script:SystemTrayOpenFolder         = $CollectedDataDirectory # = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)\Collected Data"

        # Location of separate queries
        $script:CollectedDataTimeStampDirectory = "$CollectedDataDirectory\$((Get-Date).ToString('yyyy-MM-dd @ HHmm ss'))"
        # Location of Uncompiled Results
        $script:IndividualHostResults           = "$script:CollectedDataTimeStampDirectory\Results By Endpoints"


# Website / URL for Character Art
# http://patorjk.com/software/taag/#p=display&h=1&f=Standard&t=Script%20%20%20Execution


# Keeps track of the number of RPC protocol commands selected, if the value is ever greater than one, it'll set the collection mode to 'Monitor Jobs'
$script:RpcCommandCount = 0

# If the credential parameter is provided, it will use those credentials throughout the script and for queries unless otherwise selected
if ( $Credential ) { $script:Credential = $Credential }
# Clears out the Credential variable. Specify Credentials provided will stored in this variable
else { $script:Credential = $null }


# Creates Shortcut for PoSh-EasyWin on Desktop
$FileToShortCut      = $($myinvocation.mycommand.definition)
$ShortcutDestination = "C:\Users\$env:USERNAME\Desktop\PoSh-EasyWin.lnk"
if (-not (Test-Path $ShortcutDestination)) {
    $WScriptShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WScriptShell.CreateShortcut($ShortcutDestination)
    $Shortcut.TargetPath = $FileToShortCut
    $Shortcut.IconLocation = $EasyWinIcon
    $Shortcut.Save()
}


# Check if the script is running with Administrator Privlieges, if not it will attempt to re-run and prompt for credentials
# Not Using the following commandline, but rather the script below
# Note: Unable to . source this code from another file or use the call '&' operator to use as external cmdlet; it won't run the new terminal/GUI as Admin
<# #Requires -RunAsAdministrator #>
If (-NOT $SkipEvelationCheck -and -NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    $ElevateShell = [System.Windows.Forms.MessageBox]::Show("Attention Under-Privileged User!`n   $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)`n`nThe remote commands executed to collect data require elevated credentials. Select 'Yes' to attempt to run this script with elevated privileges; select 'No' to run this script with the current user's privileges; or select 'Cancel' and re-run this script within an Administrator terminal.","PoSh-EasyWin",'YesNoCancel',"Warning")
    switch ($ElevateShell) {
    'Yes'{
        if ($ShowTerminal) { Start-Process PowerShell.exe -Verb runAs -ArgumentList $ThisScript }
        else               { Start-Process PowerShell.exe -Verb runAs -ArgumentList $ThisScript -WindowStyle Hidden }
        exit
    }
    'No' {
        if ($ShowTerminal) { Start-Process PowerShell.exe -ArgumentList "$ThisScript -SkipEvelationCheck" }
        else               { Start-Process PowerShell.exe -ArgumentList "$ThisScript -SkipEvelationCheck" -WindowStyle Hidden }
        exit
    }
    'Cancel' {exit}
    }
}
elseif (-NOT $SkipEvelationCheck) {
    if ($ShowTerminal) { Start-Process PowerShell.exe -Verb runAs -ArgumentList "$ThisScript -SkipEvelationCheck" }
    else               { Start-Process PowerShell.exe -Verb runAs -ArgumentList "$ThisScript -SkipEvelationCheck" -WindowStyle Hidden }
    exit
}
$FormAdminCheck = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")


# Creates a log entry to an external file
. "$Dependencies\Code\Main Body\Create-LogEntry.ps1"

if (-Not (Test-Path $PoShSettings)){New-Item -ItemType Directory $PoShSettings | Out-Null}


# Logs what account ran the script and when
Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "===================================================================================================="
Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "PoSh-EasyWin Started By: $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"

# This prompts the user for accepting the GPLv3 License
if ($AcceptEULA) {
    Write-Output -ForeGroundColor Green  "You accepted the EULA."
    Write-Output -ForeGroundColor Yellow "For more infor, visit https://www.gnu.org/licenses/gpl-3.0.html or view a copy in the Dependencies folder."
}
else {
    Get-Content "$Dependencies\GPLv3 Notice.txt" | Out-GridView -Title 'PoSh-EasyWin User Agreement' -PassThru | Set-Variable -Name UserAgreement
    if ($UserAgreement) {
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "PoSh-EasyWin User Agreemennt Accepted By: $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"
        Write-Output -ForeGroundColor Green  "You accepted the EULA."
        Write-Output -ForeGroundColor Yellow "For more infor, visit https://www.gnu.org/licenses/gpl-3.0.html or view a copy in the Dependencies folder."
        Start-Sleep -Seconds 1
    }
    else {
        [system.media.systemsounds]::Exclamation.play()
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "PoSh-EasyWin User Agreemennt NOT Accepted By: $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"
        Write-Output -ForeGroundColor Red    "You must accept the EULA to continue."
        Write-Output -ForeGroundColor Yellow "For more infor, visit https://www.gnu.org/licenses/gpl-3.0.html or view a copy in the Dependencies folder."
        exit
    }
    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "===================================================================================================="
}


# These are the common settings for buttons in a function
. "$Dependencies\Code\Main Body\CommonButtonSettings.ps1"


# Scales the PoSh-EasyWin GUI as desired by the user
. "$Dependencies\Code\Main Body\Launch-FormScaleGUI.ps1"
if (-not (Test-Path "$PoShSettings\Form Scaling Modifier.txt")){
    Launch-FormScaleGUI
    if ($script:ResolutionSetOkay) {$null}
    else {exit}
    $FormScale = $script:ResolutionCheckScalingTrackBar.Value / 10
}
else { 
    $FormScale = [decimal](Get-Content "$PoShSettings\Form Scaling Modifier.txt") 
}


# Displays essential info about the tool, best practies, etc - opens immedately during first time launch, and can be found within the readme tab
. "$Dependencies\Code\Main Body\Launch-ReadMe.ps1"
if (-not (Test-Path "$PoShHome\Settings\User Notice And Acknowledgement.txt")) { Launch-ReadMe }


# Check for, and prompt to install the PSWriteHTML module
if ((Test-Path "$PoShHome\Settings\User Notice And Acknowledgement.txt") -and -not (Test-Path "$PoShHome\Settings\PSWriteHTML Module Install.txt")) {
    if (-not (Get-Module -ListAvailable -Name PSWriteHTML)) {
        $InstallPSWriteHTML = [System.Windows.Forms.MessageBox]::Show("PoSh-EasyWin can make use of the PSWriteHTML module to generate dynamic graphs. If this third party module is installed, it provides another means to represent data in an intuitive manner using a web browser. Though this module has been scanned and reviewed, any third party modules may pose a security risk. The PSWriteHTML module files have been packaged with PoSh-EasyWin, but are not being used unless its import. More information can be located at the following:
    https://www.powershellgallery.com/packages/PSWriteHTML
    https://github.com/EvotecIT/PSWriteHTML

This selection is persistent for this tool, but can be modified within the settings directory. Do you want to import the PSWriteHTML module?","Install PSWriteHTML Module",'YesNo',"Info")
        switch ($InstallPSWriteHTML) {
            'Yes' {
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Opted to import the PSWriteHTML module"
                'Import PSWriteHTML: Yes' | Set-Content "$PoShHome\Settings\PSWriteHTML Module Install.txt"
            }
            'No' { 
                'Import PSWriteHTML: No' | Set-Content "$PoShHome\Settings\PSWriteHTML Module Install.txt"
             }
        }
    }
}
if ((Get-Content "$PoShHome\Settings\PSWriteHTML Module Install.txt") -match 'Yes') {
    Import-Module -Name "$Dependencies\Modules\PSWriteHTML\0.0.117\PSWriteHTML.psm1" -Force
}

# Progress Bar Load Screen Code
. "$Dependencies\Code\Main Body\Launch-ProgressBarForm.ps1"


#============================================================================================================================================================
#   __  __         _            _____
#  |  \/  |  __ _ (_) _ __     |  ___|___   _ __  _ __ ___
#  | |\/| | / _` || || '_ \    | |_  / _ \ | '__|| '_ ` _ \
#  | |  | || (_| || || | | |   |  _|| (_) || |   | | | | | |
#  |_|  |_| \__,_||_||_| |_|   |_|   \___/ |_|   |_| |_| |_|
#
#============================================================================================================================================================

# Test code for loading and executing C# / C Sharpe code within PowerShell
$id = get-random
$code = @"
using System;
namespace Loading
{
	public class Test$id
	{
        public static void Main()
        {
			Console.WriteLine("C# Test: Loading PoSh-EasyWin... Enjoy!");
        }
    }
}
"@
Add-Type -TypeDefinition $code -Language CSharp
Invoke-Expression "[Loading.Test$id]::Main()"


# Timer that updates the GUI on interval
#$script:Timer = New-Object System.Windows.Forms.Timer -Property @{
#    Enabled  = $true
#    Interval = 1000 #1000 = 1 second
#}
#$script:Timer.Start()

#$script:timer.add_Tick({write-host $(Get-Date)})

### How to stop the timer... if needed
#$script:Timer.stop()
#$PoShEasyWin.Refresh()



#Start Progress bar form loading
$ScriptBlockForGuiLoadAndProgressBar = {


# Launches the accompanying Notifications Icon helper in the  System Tray
. "$Dependencies\Code\Main Body\Launch-SystemTrayNotifyIcon.ps1"


# The Launch-ProgressBarForm.ps1 is topmost upon loading to ensure it's displayed intially, but is then able to be move unpon
$ResolutionCheckForm.topmost = $false


$script:ProgressBarFormProgressBar.Value += 1
$script:ProgressBarSelectionForm.Refresh()


$PoShEasyWinAccountLaunch = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
#[System.Windows.Forms.Application]::EnableVisualStyles()
$PoShEasyWin = New-Object System.Windows.Forms.Form -Property @{
    Text          = "PoSh-EasyWin   ($PoShEasyWinAccountLaunch)  [$InitialScriptLoadTime]"
    StartPosition = "CenterScreen"
    Width  = $FormScale * 1260 #1241
    Height = $FormScale * 660  #638
    Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
    AutoScroll    = $True
    FormBorderStyle =  'Sizable' #  Fixed3D, FixedDialog, FixedSingle, FixedToolWindow, None, Sizable, SizableToolWindow
    ControlBox      = $true
    MaximizeBox     = $false
    MinimizeBox     = $true
    Add_Load = {
        if ((Test-Path "$script:CredentialManagementPath\Specified Credentials.txt")) {
            $SelectedCredentialName = Get-Content "$script:CredentialManagementPath\Specified Credentials.txt"
            $SelectedCredentialPath = Get-ChildItem "$script:CredentialManagementPath\$SelectedCredentialName"
            $script:Credential      = Import-CliXml $SelectedCredentialPath
            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("Credentials:  $SelectedCredentialName.xml")
            $ComputerListProvideCredentialsCheckBox.checked = $true
        }
        else {
            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("Credentials:  $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)")
        }
    }
    Add_Closing = {
        param($sender,$Selection)
        $script:VerifyCloseForm = New-Object System.Windows.Forms.Form -Property @{
            Text    = "Close"
            Width   = $FormScale * 250
            Height  = $FormScale * 109
            TopMost = $true
            Icon    = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
            Font    = New-Object System.Drawing.Font("$Font",($FormScale * 11),0,0,0)
            FormBorderStyle =  'Fixed3d'
            StartPosition   = 'CenterScreen'
            showintaskbar   = $true
            ControlBox      = $true
            MaximizeBox     = $false
            MinimizeBox     = $false
            Add_Closing = {
                if     ($script:VerifyToCloseForm -eq $true) { $Selection.Cancel = $false }
                elseif ($script:VerifyToCloseForm -eq $false){ $Selection.Cancel = $true }
                else   { $Selection.Cancel = $true  }
                $this.TopMost = $false
                $this.dispose()
                $this.close()
            }
        }
        $VerifyCloseLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = 'Do you want to close PoSh-EasyWin?'
            Width  = $FormScale * 250
            Height = $FormScale * 22
            Left   = $FormScale * 10
            Top    = $FormScale * 10
        }
        $script:VerifyCloseForm.Controls.Add($VerifyCloseLabel)


        $VerifyYesButton = New-Object System.Windows.Forms.Button -Property @{
            Text   = 'Yes'
            Width  = $FormScale * 100
            Height = $FormScale * 22
            Left   = $FormScale * 10
            Top    = $VerifyCloseLabel.Top + $VerifyCloseLabel.Height
            BackColor = 'LightGray'
            Add_Click = {
                $script:VerifyToCloseForm = $True
                Stop-Process -id $FormHelperProcessId -Force -ErrorAction SilentlyContinue
                $script:VerifyCloseForm.close()
            }
        }
        $script:VerifyCloseForm.Controls.Add($VerifyYesButton)
        FormButtonSettings $VerifyYesButton


        $VerifyNoButton = New-Object System.Windows.Forms.Button -Property @{
            Text   = 'No'
            Width  = $FormScale * 100
            Height = $FormScale * 22
            Left   = $VerifyYesButton.Left + $VerifyYesButton.Width + ($FormScale * 10)
            Top    = $VerifyYesButton.Top
            BackColor = 'LightGray'
            Add_Click = {
                $script:VerifyToCloseForm = $false
                $script:VerifyCloseForm.close()
            }
        }
        $script:VerifyCloseForm.Controls.Add($VerifyNoButton)
        FormButtonSettings $VerifyNoButton

        $script:VerifyCloseForm.ShowDialog()
    }
    #backgroundimage =  [system.drawing.image]::FromFile("C:\Users\Administrator\Desktop\PoSh-EasyWin\Dependencies\Background Image 001.jpg")
}

# Takes the entered domain and lists all computers
. "$Dependencies\Code\Execution\Enumeration\Import-HostsFromDomain.ps1"

# Provides messages when hovering over various areas in the GUI
. "$Dependencies\Code\Main Body\Show-ToolTip.ps1"


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
$script:ProgressBarFormProgressBar.Value += 1
$script:ProgressBarSelectionForm.Refresh()

$MainLeftTabControlBoxWidth  = 460
$MainLeftTabControlBoxHeight = 590

$MainLeftTabControl = New-Object System.Windows.Forms.TabControl -Property @{
    Name     = "Main Tab Window"
    Location = @{ X = $FormScale * 5
                  Y = $FormScale * 5 }
    Size     = @{ Width  = $FormScale * $MainLeftTabControlBoxWidth
                  Height = $FormScale * $MainLeftTabControlBoxHeight }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
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
$script:ProgressBarFormProgressBar.Value += 1
$script:ProgressBarSelectionForm.Refresh()

$Section1CollectionsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text                    = "Collections"
    Name                    = "Collections Tab"
    UseVisualStyleBackColor = $True
    Font                    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
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
$script:ProgressBarFormProgressBar.Value += 1
$script:ProgressBarSelectionForm.Refresh()

$MainLeftCollectionsTabControl = New-Object System.Windows.Forms.TabControl -Property @{
    Name     = "Collections TabControl"
    Location = @{ X = $FormScale * $TabRightPosition
                  Y = $FormScale * $TabhDownPosition }
    Size     = @{ Width  = $FormScale * $TabAreaWidth
                  Height = $FormScale * $TabAreaHeight }
    ShowToolTips  = $True
    SelectedIndex = 0
    Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
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
$script:ProgressBarFormProgressBar.Value += 1
$script:ProgressBarSelectionForm.Refresh()

$Section1CommandsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = "Queries"
    Left   = $FormScale * $Column1RightPosition
    Top    = $FormScale * $Column1DownPosition
    Width  = $FormScale * $Column1BoxWidth
    Height = $FormScale * $Column1BoxHeight
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
}
$MainLeftCollectionsTabControl.Controls.Add($Section1CommandsTab)


# Imports all the Endpoint Commands fromthe csv file
$script:AllEndpointCommands = Import-Csv $CommandsEndpoint

# Imports scripts from the Endpoint script folder and loads them into the treeview
# New scripts can be added to 'Dependencies\Cmds & Scripts\Scirpts - Endpoint' to be imported
# Verify that the scripts function properly and return results with the Invoke-Command cmdlet
. "$Dependencies\Code\Main Body\Import-EndpointScripts.ps1"
Import-EndpointScripts


# Imports all the Active Directoyr Commands fromthe csv file
$script:AllActiveDirectoryCommands = Import-Csv $CommandsActiveDirectory

# Imports scripts from the Active Directory script folder and loads them into the treeview
# New scripts can be added to 'Dependencies\Cmds & Scripts\Scirpts - Active Directory' to be imported
# Verify that the scripts function properly and return results with the Invoke-Command cmdlet
. "$Dependencies\Code\Main Body\Import-ActiveDirectoryScripts.ps1"
Import-ActiveDirectoryScripts


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
$script:ProgressBarFormProgressBar.Value += 1
$script:ProgressBarSelectionForm.Refresh()

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
. "$Dependencies\Code\Tree View\Command\Update-TreeNodeCommandState.ps1"

# Adds a treenode to the specified root node... a command node within a category node
. "$Dependencies\Code\Tree View\Command\Add-NodeCommand.ps1"

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


# Imports the Query History and populates the command treenode
$script:QueryHistory = Import-CliXml "$PoShHome\Query History.xml"
function Update-QueryHistory {
    foreach ($Command in $script:QueryHistory) {
        $Command | Add-Member -MemberType NoteProperty -Name CategoryName -Value "$($Command.CategoryName)" -Force
        Add-NodeCommand -RootNode $script:TreeNodePreviouslyExecutedCommands -Category "$($Command.CategoryName)" -Entry "$($Command.Name)" -ToolTip $Command.Command
    }
}
Update-QueryHistory


$CommandsTreeViewViewByGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text   = "Display And Group By:"
    Left   = $FormScale * 0
    Top    = $FormScale * 5
    Width  = $FormScale * 232
    Height = $FormScale * 37
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
    ForeColor = 'Blue'
}
            . "$Dependencies\Code\System.Windows.Forms\RadioButton\CommandsViewMethodRadioButton.ps1"
            $CommandsViewMethodRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text      = "Method"
                Left      = $FormScale * 10
                Top       = $FormScale * 13
                Width     = $FormScale * 70
                Height    = $FormScale * 22
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
                Checked   = $True
                Add_Click = $CommandsViewMethodRadioButtonAdd_Click
                Add_MouseHover = $CommandsViewMethodRadioButtonAdd_MouseHover
            }
            $CommandsTreeViewViewByGroupBox.Controls.Add( $CommandsViewMethodRadioButton )


            . "$Dependencies\Code\System.Windows.Forms\RadioButton\CommandsViewQueryRadioButton.ps1"
            $CommandsViewQueryRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text      = "Commands"
                Left      = $CommandsViewMethodRadioButton.Left + $CommandsViewMethodRadioButton.Width
                Top       = $CommandsViewMethodRadioButton.Top
                Width     = $FormScale * 90
                Height    = $FormScale * 22
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
                Checked   = $false
                Add_Click = $CommandsViewQueryRadioButtonAdd_Click
                Add_MouseHover = $CommandsViewQueryRadioButtonAdd_MouseHover
            }
            $CommandsTreeViewViewByGroupBox.Controls.Add($CommandsViewQueryRadioButton)
$Section1CommandsTab.Controls.Add($CommandsTreeViewViewByGroupBox)


$PoShEasyWinLogoPictureBox = New-Object System.Windows.Forms.PictureBox -Property @{
    #text     = "PoSh-EasyWin Image"
    Left     = $CommandsTreeViewViewByGroupBox.Left + $CommandsTreeViewViewByGroupBox.Width + ($FormScale * + 15)
    Top      = $FormScale * $CommandsTreeViewViewByGroupBox.Top
    Width    = $FormScale * 175
    Height   = $FormScale * 35
    AutoSize = $true
    SizeMode = 'Stretch'
    Image    = [System.Drawing.Image]::FromFile("$Dependencies\PoSh-EasyWin Image.png" )
    #InitialImage = $null
    #ErrorImage   = $null
}
$Section1CommandsTab.Controls.Add($PoShEasyWinLogoPictureBox)


# Searches for command nodes that match a given search entry
# A new category node named by the search entry will be created and all results will be nested within
. "$Dependencies\Code\Tree View\Command\Search-CommandTreeNode.ps1"


. "$Dependencies\Code\System.Windows.Forms\ComboBox\CommandsTreeViewSearchComboBox.ps1"
$CommandsTreeViewSearchComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Name     = "Search TextBox"
    Left     = $FormScale * 0
    Top      = $FormScale * 45
    Width    = $FormScale * 172
    Height   = $FormScale * 25
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
    Add_KeyDown    = $CommandsTreeViewSearchComboBoxAdd_KeyDown
    Add_MouseHover = $CommandsTreeViewSearchComboBoxAdd_MouseHover
}
    $CommandTypes = @("Chart","File","Hardware","Hunt","Network","System","User")
    ForEach ($Type in $CommandTypes) { [void] $CommandsTreeViewSearchComboBox.Items.Add($Type) }
$Section1CommandsTab.Controls.Add($CommandsTreeViewSearchComboBox)


. "$Dependencies\Code\System.Windows.Forms\Button\CommandsTreeViewSearchButton.ps1"
$CommandsTreeViewSearchButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Search"
    Left   =  $CommandsTreeViewSearchComboBox.Width + $($FormScale * 5)
    Top    = $FormScale * 45
    Width  = $FormScale * 55
    Height = $FormScale * 22
    Add_Click      = $CommandsTreeViewSearchButtonAdd_Click
    Add_MouseHover = $CommandsTreeViewSearchButtonAdd_MouseHover
}
$Section1CommandsTab.Controls.Add($CommandsTreeViewSearchButton)
CommonButtonSettings -Button $CommandsTreeViewSearchButton


. "$Dependencies\Code\System.Windows.Forms\Button\CommandsTreeviewDeselectAllButton.ps1"
$CommandsTreeviewDeselectAllButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Deselect All'
    Left   = $FormScale * 335
    Top    = $FormScale * 45
    Width  = $FormScale * 100
    Height = $FormScale * 22
    Add_Click      = $CommandsTreeviewDeselectAllButtonAdd_Click
    Add_MouseHover = $CommandsTreeviewDeselectAllButtonAdd_MouseHover
}
$Section1CommandsTab.Controls.Add($CommandsTreeviewDeselectAllButton)
CommonButtonSettings -Button $CommandsTreeviewDeselectAllButton


. "$Dependencies\Code\System.Windows.Forms\Button\CommandsTreeViewQueryHistoryRemovalButton.ps1"
$CommandsTreeViewQueryHistoryRemovalButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Remove Query History"
    Left   = $FormScale * 278
    Top    = $FormScale * 430
    Width  = $FormScale * 150
    Height = $FormScale * 22
    Add_Click = $CommandsTreeViewQueryHistoryRemovalButtonAdd_Click
}
CommonButtonSettings -Button $CommandsTreeViewQueryHistoryRemovalButton
# Note: This button is added/removed dynamicallly when query history category treenodes are selected


$script:CommandsTreeView = New-Object System.Windows.Forms.TreeView -Property @{
    Left   = 0
    Top    = $FormScale * 70
    Width  = $FormScale * 435
    Height = $FormScale * 390
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    CheckBoxes       = $True
    #LabelEdit       = $True
    ShowLines        = $True
    ShowNodeToolTips = $True
    Add_Click        = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
    Add_AfterSelect  = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
}
$script:CommandsTreeView.Sort()
$Section1CommandsTab.Controls.Add($script:CommandsTreeView)


# Scriptblock that is executed to manage the Query Build features such as the interactions between
# the textbox and button, launching Show-Command, variable manipulation, and message prompts
. "$Dependencies\Code\Main Body\CustomQueryScriptBlock.ps1"

$CustomQueryScriptBlockCheckBox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = '[WinRM] Query:'
    Left   = $script:CommandsTreeView.Left + ($FormScale * 9)
    Top    = $script:CommandsTreeView.Top + $script:CommandsTreeView.Height + ($FormScale * 5)
    AutoSize  = $true
    Enabled   = $false
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands
        if ($script:CustomQueryScriptBlockTextbox.text -ne $script:CustomQueryScriptBlockSaved) {
            $CustomQueryScriptBlockCheckBox.checked = $false
            $CustomQueryScriptBlockCheckBox.enabled = $false
        }
    }
}
$Section1CommandsTab.controls.add($CustomQueryScriptBlockCheckBox)


$CustomQueryScriptBlockGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Left   = $script:CommandsTreeView.Left
    Top    = $script:CommandsTreeView.Top + $script:CommandsTreeView.Height + ($FormScale * 6)
    Width  = $script:CommandsTreeView.width
    Height = $FormScale * 180
}
            $script:CustomQueryScriptBlockTextbox = New-Object System.Windows.Forms.Textbox -Property @{
                Text   = 'Enter A Get Cmdlet (ex: Get-Process)'
                Left   = $FormScale * 7
                Top    = $FormScale * 18
                Width  = $script:CommandsTreeView.width - ($FormScale * 14)
                Height = $FormScale * 22
                ShortcutsEnabled   = $true
                AutoCompleteSource = "CustomSource"
                AutoCompleteMode   = "SuggestAppend"
                Add_KeyDown    = { if ($_.KeyCode -eq "Enter") {  Invoke-Command $CustomQueryScriptBlock } }
                Add_MouseEnter = {
                    if ($this.text -ne $script:CustomQueryScriptBlockSaved) {
                        $CustomQueryScriptBlockCheckBox.checked = $false
                        $CustomQueryScriptBlockCheckBox.enabled = $false
                    }
                    if ($this.text -eq 'Enter A Get Cmdlet (ex: Get-Process)'){
                        $this.text = 'Get-'
                        $CustomQueryScriptBlockCheckBox.checked = $false
                        $CustomQueryScriptBlockCheckBox.enabled = $false
                    }
                    if ($this.text -eq 'Enter Any Cmdlet'){
                        $this.text = ''
                        $CustomQueryScriptBlockCheckBox.checked = $false
                        $CustomQueryScriptBlockCheckBox.enabled = $false
                    }
                }
                Add_MouseLeave = {
                    if ($this.text -ne $script:CustomQueryScriptBlockSaved) {
                        $CustomQueryScriptBlockCheckBox.enabled = $false
                    }
                    if ($CustomQueryScriptBlockOverrideCheckBox.checked) {
                        if ($this.text -eq ''){
                            $this.text = 'Enter Any Cmdlet'
                            $CustomQueryScriptBlockCheckBox.checked = $false
                            $CustomQueryScriptBlockCheckBox.enabled = $false
                        }
                    }
                    elseif (-not $CustomQueryScriptBlockOverrideCheckBox.checked) {
                        if ($this.text -eq '' -or $this.text -eq 'Get-' -or $this.text -eq 'Get'){
                            $this.text = 'Enter A Get Cmdlet (ex: Get-Process)'
                            $CustomQueryScriptBlockCheckBox.checked = $false
                            $CustomQueryScriptBlockCheckBox.enabled = $false
                        }
                    }
                }
            }
            $script:CmdletList = (Get-Command -CommandType 'Alias', 'Cmdlet', 'Function', 'Workflow').Name | Where-Object {$_ -like "Get-*"}
            $script:CustomQueryScriptBlockTextbox.AutoCompleteCustomSource.AddRange($script:CmdletList)
            $CustomQueryScriptBlockGroupBox.controls.add($script:CustomQueryScriptBlockTextbox)


            $CustomQueryScriptBlockButton = New-Object System.Windows.Forms.Button -Property @{
                Text   = 'Modify Parameters'
                Left   = $script:CustomQueryScriptBlockTextbox.Left
                Top    = $script:CustomQueryScriptBlockTextbox.top + $script:CustomQueryScriptBlockTextbox.height + ($FormScale * 5)
                Width  = $FormScale * 135
                Height = $FormScale * 22
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                Add_Click = { Invoke-Command $CustomQueryScriptBlock }
            }
            CommonButtonSettings -Button $CustomQueryScriptBlockButton
            $CustomQueryScriptBlockGroupBox.controls.add($CustomQueryScriptBlockButton)


            $CustomQueryScriptBlockOverrideCheckBox = New-Object System.Windows.Forms.CheckBox -Property @{
                Text   = 'Override - Allow other verbs'
                Left   = $CustomQueryScriptBlockButton.Left + $CustomQueryScriptBlockButton.width + ($FormScale * 10)
                Top    = $script:CustomQueryScriptBlockTextbox.Top + $script:CustomQueryScriptBlockTextbox.Height + ($FormScale * 5)
                AutoSize  = $true
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                Add_click = {
                    if ($this.checked) {
                        $script:CustomQueryScriptBlockTextbox.AutoCompleteCustomSource.Clear()
                        $script:CmdletList = (Get-Command -CommandType 'Alias', 'Cmdlet', 'Function', 'Workflow').Name
                        $script:CustomQueryScriptBlockTextbox.AutoCompleteCustomSource.AddRange($script:CmdletList)
                        $script:CustomQueryScriptBlockTextbox.text = 'Enter Any Cmdlet'
                        $CustomQueryScriptBlockCheckBox.enabled = $false
                    }
                    else {
                        $script:CustomQueryScriptBlockTextbox.AutoCompleteCustomSource.Clear()
                        $script:CmdletList = (Get-Command -CommandType 'Alias', 'Cmdlet', 'Function', 'Workflow').Name | Where-Object {$_ -like "Get-*"}
                        $script:CustomQueryScriptBlockTextbox.AutoCompleteCustomSource.AddRange($script:CmdletList)
                        $script:CustomQueryScriptBlockTextbox.text = 'Enter A Get Cmdlet (ex: Get-Process)'
                        $CustomQueryScriptBlockCheckBox.enabled = $false
                    }
                }
            }
            $CustomQueryScriptBlockGroupBox.controls.add($CustomQueryScriptBlockOverrideCheckBox)

$Section1CommandsTab.controls.add($CustomQueryScriptBlockGroupBox)

# Default View
Initialize-CommandTreeNodes

# This adds the nodes to the Commands TreeView
View-CommandTreeNodeMethod

$script:CommandsTreeView.Nodes.Add($script:TreeNodeEndpointCommands)
$script:CommandsTreeView.Nodes.Add($script:TreeNodeActiveDirectoryCommands)
$script:CommandsTreeView.Nodes.Add($script:TreeNodeCommandSearch)
$script:CommandsTreeView.Nodes.Add($script:TreeNodePreviouslyExecutedCommands)
#$script:CommandsTreeView.ExpandAll()


#=======================================================================================================================================================================
#
#  Parent: Main Form -> Main Left TabControl -> Collections TabControl
#     _                                   _            _____       _
#    / \    ___  ___  ___   _   _  _ __  | |_  ___    |_   _|__ _ | |__   _ __    __ _   __ _   ___
#   / _ \  / __|/ __|/ _ \ | | | || '_ \ | __|/ __|     | | / _` || '_ \ | '_ \  / _` | / _` | / _ \
#  / ___ \| (__| (__| (_) || |_| || | | || |_ \__ \     | || (_| || |_) || |_) || (_| || (_| ||  __/
# /_/   \_\\___|\___|\___/  \__,_||_| |_| \__||___/     |_| \__,_||_.__/ | .__/  \__,_| \__, | \___|
#                                                                        |_|            |___/
#=======================================================================================================================================================================
$script:ProgressBarFormProgressBar.Value += 1
$script:ProgressBarSelectionForm.Refresh()

$Section1AccountsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = "Accounts"
    Left   = $FormScale * $Column1RightPosition
    Top    = $FormScale * $Column1DownPosition
    Width  = $FormScale * $Column1BoxWidth
    Height = $FormScale * $Column1BoxHeight
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
}
$MainLeftCollectionsTabControl.Controls.Add($Section1AccountsTab)


$AccountsMainLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Accounts can be obtained from workstations and servers."
    Left   = $FormScale * 5
    Top    = $FormScale * 5
    Width  = $FormScale * 410
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Black"
}
$Section1AccountsTab.Controls.Add($AccountsMainLabel)


$AccountsOptionsGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text   = "Collection Options"
    Left   = $FormScale * 5
    Top    = $AccountsMainLabel.Top + $AccountsMainLabel.Height
    Width  = $FormScale * 425
    Height = $FormScale * 94
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
}
            $AccountsProtocolRadioButtonLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Protocol:"
                Left   = $FormScale * 7
                Top    = $FormScale * 20
                Width  = $FormScale * 73
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
            }
            $AccountsOptionsGroupBox.Controls.Add($AccountsProtocolRadioButtonLabel)


            $AccountsWinRMRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text   = "WinRM"
                Left   = $FormScale * 80
                Top    = $FormScale * 15
                Width  = $FormScale * 80
                Height = $FormScale * 22
                Checked   = $True
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
            }
            $AccountsOptionsGroupBox.Controls.Add($AccountsWinRMRadioButton)


            $AccountsRPCRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text   = "RPC"
                Left   = $AccountsWinRMRadioButton.Left + $AccountsWinRMRadioButton.Width + $($FormScale * 10)
                Top    = $AccountsWinRMRadioButton.Top
                Width  = $FormScale * 60
                Height = $FormScale * 22
                Checked   = $False
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
                Enabled = $false
            }
            $AccountsOptionsGroupBox.Controls.Add($AccountsRPCRadioButton)


            <#
            . "$Dependencies\Code\System.Windows.Forms\Label\AccountsMaximumCollectionLabel.ps1"
            $AccountsMaximumCollectionLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Max Collection:"
                Left   = $AccountsRPCRadioButton.Left + $AccountsRPCRadioButton.Width + $($FormScale * 35)
                Top    = $AccountsRPCRadioButton.Top + $($FormScale * 3)
                Width  = $FormScale * 100
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
                Add_MouseHover = $AccountsMaximumCollectionLabelAdd_MouseHover
            }
            $AccountsOptionsGroupBox.Controls.Add($AccountsMaximumCollectionLabel)


            . "$Dependencies\Code\System.Windows.Forms\TextBox\AccountsMaximumCollectionTextBox.ps1"
            $AccountsMaximumCollectionTextBox = New-Object System.Windows.Forms.TextBox -Property @{
                    Text   = 100
                    Left   = $AccountsMaximumCollectionLabel.Left + $AccountsMaximumCollectionLabel.Width
                    Top    = $AccountsMaximumCollectionLabel.Top - $($FormScale * 3)
                    Width  = $FormScale * 50
                    Height = $FormScale * 22
                    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                    Enabled  = $True
                    Add_MouseHover = $AccountsMaximumCollectionTextBoxAdd_MouseHover
                }
                $AccountsOptionsGroupBox.Controls.Add($AccountsMaximumCollectionTextBox)
        #>


            $AccountsDatetimeStartLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "DateTime Start:"
                Left   = $FormScale * 77
                Top    = $AccountsProtocolRadioButtonLabel.Top + $AccountsProtocolRadioButtonLabel.Height + $($FormScale * 5)
                Width  = $FormScale * 90
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
            }
            $AccountsOptionsGroupBox.Controls.Add($AccountsDatetimeStartLabel)


            $AccountsStartTimePicker = New-Object System.Windows.Forms.DateTimePicker -Property @{
                Left         = $AccountsDatetimeStartLabel.Left + $AccountsDatetimeStartLabel.Width
                Top          = $AccountsProtocolRadioButtonLabel.Top + $AccountsProtocolRadioButtonLabel.Height
                Width        = $FormScale * 250
                Height       = $FormScale * 100
                Font         = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                Format       = [windows.forms.datetimepickerFormat]::custom
                CustomFormat = "dddd MMM dd, yyyy hh:mm tt"
                Enabled      = $True
                Checked      = $True
                ShowCheckBox = $True
                ShowUpDown   = $False
                AutoSize     = $true
                #MinDate      = (Get-Date -Month 1 -Day 1 -Year 2000).DateTime
                #MaxDate      = (Get-Date).DateTime
                Value         = (Get-Date).AddDays(-1).DateTime
            }
            $AccountsOptionsGroupBox.Controls.Add($AccountsStartTimePicker)


            $AccountsDatetimeStopLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "DateTime Stop:"
                Left   = $AccountsDatetimeStartLabel.Left
                Top    = $AccountsDatetimeStartLabel.Top + $AccountsDatetimeStartLabel.Height
                Width  = $AccountsDatetimeStartLabel.Width
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
            }
            $AccountsOptionsGroupBox.Controls.Add($AccountsDatetimeStopLabel)


            $AccountsStopTimePicker = New-Object System.Windows.Forms.DateTimePicker -Property @{
                Left         = $AccountsDatetimeStopLabel.Left + $AccountsDatetimeStopLabel.Width
                Top          = $AccountsDatetimeStartLabel.Top + $AccountsDatetimeStartLabel.Height - $($FormScale * 5)
                Width        = $AccountsStartTimePicker.Width
                Height       = $FormScale * 100
                Font         = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                Format       = [windows.forms.datetimepickerFormat]::custom
                CustomFormat = "dddd MMM dd, yyyy hh:mm tt"
                Enabled      = $True
                Checked      = $True
                ShowCheckBox = $True
                ShowUpDown   = $False
                AutoSize     = $true
                #MinDate      = (Get-Date -Month 1 -Day 1 -Year 2000).DateTime
                #MaxDate      = (Get-Date).DateTime
            }
            $AccountsOptionsGroupBox.Controls.Add($AccountsStopTimePicker)
$Section1AccountsTab.Controls.Add($AccountsOptionsGroupBox)


$AccountsCurrentlyLoggedInConsoleCheckbox  = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Accounts Logged In via Console"
    Left   = $FormScale * 7
    Top    = $AccountsOptionsGroupBox.Top + $AccountsOptionsGroupBox.Height + $($FormScale * 10)
    Width  = $FormScale * 325
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
}
$Section1AccountsTab.Controls.Add($AccountsCurrentlyLoggedInConsoleCheckbox)


$AccountsCurrentlyLoggedInInfoButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Reference"
    Left   = $AccountsCurrentlyLoggedInConsoleCheckbox.Left + $AccountsCurrentlyLoggedInConsoleCheckbox.Width + ($FormScale * 22)
    Top    = $AccountsCurrentlyLoggedInConsoleCheckbox.Top #- ($FormScale * 9)
    Width  = $FormScale * 75
    Height = $FormScale * 20
    Add_Click = {
        if (Test-Path "$Dependencies\Reference Account Information.csv") {
            Import-Csv "$Dependencies\Reference Account Information.csv" | Out-GridView -Title 'PoSh-EasyWin - General Account Information'
        }
        else {[System.Windows.Forms.MessageBox]::Show("The General Account Information file for reference cannot be located.",'PoSh-EasyWin Select Accounts')}
     }
}
$Section1AccountsTab.Controls.Add($AccountsCurrentlyLoggedInInfoButton)
CommonButtonSettings -Button $AccountsCurrentlyLoggedInInfoButton



$AccountsCurrentlyLoggedInPSSessionCheckbox  = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Accounts Logged In via PowerShell Session"
    Left   = $FormScale * 7
    Top    = $AccountsCurrentlyLoggedInConsoleCheckbox.Top + $AccountsCurrentlyLoggedInConsoleCheckbox.Height + $($FormScale * 10)
    Width  = $FormScale * 350
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
}
$Section1AccountsTab.Controls.Add($AccountsCurrentlyLoggedInPSSessionCheckbox)


$AccountsCurrentlyLoggedInPSSessionLabel  = New-Object System.Windows.Forms.Label -Property @{
    Text   = "With WinRM Sessions, your account should also show up in these results."
    Left   = $FormScale * 7
    Top    = $AccountsCurrentlyLoggedInPSSessionCheckbox.Top + $AccountsCurrentlyLoggedInPSSessionCheckbox.Height
    Width  = $FormScale * 400
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = "Black"
    Add_MouseHover = $AccountsMaximumCollectionLabelAdd_MouseHover
}
$Section1AccountsTab.Controls.Add($AccountsCurrentlyLoggedInPSSessionLabel)


. "$Dependencies\Code\Main Body\Get-AccountLogonActivity.ps1"
$AccountActivityCheckbox  = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Account Logon Activity"
    Left   = $FormScale * 7
    Top    = $AccountsCurrentlyLoggedInPSSessionLabel.Top + $AccountsCurrentlyLoggedInPSSessionLabel.Height + $($FormScale * 10)
    Width  = $FormScale * 410
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
}
$Section1AccountsTab.Controls.Add($AccountActivityCheckbox)


$AccountActivityLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Enter Account Names; One Per Line"
    Left   = $FormScale * 5
    Top    = $AccountActivityCheckbox.Top + $AccountActivityCheckbox.Height
    Width  = $FormScale * 200
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = "Black"
}
$Section1AccountsTab.Controls.Add($AccountActivityLabel)


$AccountActivitySelectionButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Select Accounts"
    Left   = $FormScale * 4
    Top    = $AccountActivityLabel.Top + $AccountActivityLabel.Height
    Width  = $FormScale * 125
    Height = $FormScale * 20
    Add_Click = {
        if (Test-Path "$PoShHome\Account Data.csv") {
            Import-Csv "$PoShHome\Account Data.csv" | Out-GridView -Title 'PoSh-EasyWin Select Accounts' -PassThru | Set-Variable -Name AccountCsvData
            $AccountActivityTextbox.lines = ''
            foreach ($Account in $AccountCsvData) { $AccountActivityTextbox.lines += $Account.Name}
        }
        else {
            [System.Windows.Forms.MessageBox]::Show("No Account Information available...`nImport account info from the Import Data tab.",'PoSh-EasyWin Select Accounts')
        }
    }
}
$Section1AccountsTab.Controls.Add($AccountActivitySelectionButton)
CommonButtonSettings -Button $AccountActivitySelectionButton


$AccountActivityClearButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Clear"
    Left   = $FormScale * 136
    Top    = $AccountActivityLabel.Top + $AccountActivityLabel.Height
    Width  = $FormScale * 75
    Height = $FormScale * 20
    Add_Click = { $AccountActivityTextbox.Text = "" }
}
$Section1AccountsTab.Controls.Add($AccountActivityClearButton)
CommonButtonSettings -Button $AccountActivityClearButton


$AccountActivityTextbox = New-Object System.Windows.Forms.TextBox -Property @{
    Lines  = 'Default is All Accounts'
    Left   = $FormScale * 5
    Top    = $AccountActivityClearButton.Top + $AccountActivityClearButton.Height + $($FormScale * 5)
    Width  = $FormScale * 205
    Height = $FormScale * 139
    MultiLine  = $True
    WordWrap   = $True
    AcceptsTab = $false
    AcceptsReturn  = $false
    ScrollBars     = "Vertical"
    Font           = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_MouseEnter = {if ($this.Text -eq 'Default is All Accounts'){$this.Text = ''}}
    Add_MouseLeave = {if ($this.Text -eq ''){$this.Text = 'Default is All Accounts'}}
}
$Section1AccountsTab.Controls.Add($AccountActivityTextbox)


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
$script:ProgressBarFormProgressBar.Value += 1
$script:ProgressBarSelectionForm.Refresh()

$Section1EventLogsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = "Event Logs"
    Left   = $FormScale * $Column1RightPosition
    Top    = $FormScale * $Column1DownPosition
    Width  = $FormScale * $Column1BoxWidth
    Height = $FormScale * $Column1BoxHeight
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
}
$MainLeftCollectionsTabControl.Controls.Add($Section1EventLogsTab)


$EventLogsMainLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Event Logs can be obtained from workstations and servers."
    Left   = $FormScale * 5
    Top    = $FormScale * 5
    Width  = $FormScale * 410
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Black"
}
$Section1EventLogsTab.Controls.Add($EventLogsMainLabel)


$EventLogsOptionsGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text   = "Collection Options"
    Left   = $FormScale * 5
    Top    = $EventLogsMainLabel.Top + $EventLogsMainLabel.Height
    Width  = $FormScale * 425
    Height = $FormScale * 94
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
}
            $EventLogProtocolRadioButtonLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Protocol:"
                Left   = $FormScale * 7
                Top    = $FormScale * 20
                Width  = $FormScale * 73
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
            }


            . "$Dependencies\Code\System.Windows.Forms\RadioButton\EventLogWinRMRadioButton.ps1"
            $EventLogWinRMRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text   = "WinRM"
                Left   = $FormScale * 80
                Top    = $FormScale * 15
                Width  = $FormScale * 80
                Height = $FormScale * 22
                Checked   = $True
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
                Add_Click      = $EventLogWinRMRadioButtonAdd_Click
                Add_MouseHover = $EventLogWinRMRadioButtonAdd_MouseHover
            }


            . "$Dependencies\Code\System.Windows.Forms\RadioButton\EventLogRPCRadioButton.ps1"
            $EventLogRPCRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text   = "RPC"
                Left   = $EventLogWinRMRadioButton.Left + $EventLogWinRMRadioButton.Width + $($FormScale * 10)
                Top    = $EventLogWinRMRadioButton.Top
                Width  = $FormScale * 60
                Height = $FormScale * 22
                Checked   = $False
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
                Add_Click      = $EventLogRPCRadioButtonAdd_Click
                Add_MouseHover = $EventLogRPCRadioButtonAdd_MouseHover
            }


            . "$Dependencies\Code\System.Windows.Forms\Label\EventLogsMaximumCollectionLabel.ps1"
            $EventLogsMaximumCollectionLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Max Collection:"
                Left   = $EventLogRPCRadioButton.Left + $EventLogRPCRadioButton.Width + $($FormScale * 35)
                Top    = $EventLogRPCRadioButton.Top + $($FormScale * 3)
                Width  = $FormScale * 100
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
                Add_MouseHover = $EventLogsMaximumCollectionLabelAdd_MouseHover
            }


            . "$Dependencies\Code\System.Windows.Forms\TextBox\EventLogsMaximumCollectionTextBox.ps1"
            $EventLogsMaximumCollectionTextBox = New-Object System.Windows.Forms.TextBox -Property @{
                Text   = 100
                Left   = $EventLogsMaximumCollectionLabel.Left + $EventLogsMaximumCollectionLabel.Width
                Top    = $EventLogsMaximumCollectionLabel.Top - $($FormScale * 3)
                Width  = $FormScale * 50
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                Enabled  = $True
                Add_MouseHover = $EventLogsMaximumCollectionTextBoxAdd_MouseHover
            }


            $EventLogsDatetimeStartLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "DateTime Start:"
                Left   = $FormScale * 77
                Top    = $EventLogProtocolRadioButtonLabel.Top + $EventLogProtocolRadioButtonLabel.Height + $($FormScale * 5)
                Width  = $FormScale * 90
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
            }


            . "$Dependencies\Code\System.Windows.Forms\DateTimePicker\EventLogsStartTimePicker.ps1"
            $EventLogsStartTimePicker = New-Object System.Windows.Forms.DateTimePicker -Property @{
                Left         = $EventLogsDatetimeStartLabel.Left + $EventLogsDatetimeStartLabel.Width
                Top          = $EventLogProtocolRadioButtonLabel.Top + $EventLogProtocolRadioButtonLabel.Height
                Width        = $FormScale * 250
                Height       = $FormScale * 100
                Font         = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                Format       = [windows.forms.datetimepickerFormat]::custom
                CustomFormat = "dddd MMM dd, yyyy hh:mm tt"
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


            $EventLogsDatetimeStopLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "DateTime Stop:"
                Left   = $EventLogsDatetimeStartLabel.Left
                Top    = $EventLogsDatetimeStartLabel.Top + $EventLogsDatetimeStartLabel.Height
                Width  = $EventLogsDatetimeStartLabel.Width
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
            }


            . "$Dependencies\Code\System.Windows.Forms\DateTimePicker\EventLogsStopTimePicker.ps1"
            $EventLogsStopTimePicker = New-Object System.Windows.Forms.DateTimePicker -Property @{
                Left         = $EventLogsDatetimeStopLabel.Left + $EventLogsDatetimeStopLabel.Width
                Top          = $EventLogsDatetimeStartLabel.Top + $EventLogsDatetimeStartLabel.Height - $($FormScale * 5)
                Width        = $EventLogsStartTimePicker.Width
                Height       = $FormScale * 100
                Font         = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                Format       = [windows.forms.datetimepickerFormat]::custom
                CustomFormat = "dddd MMM dd, yyyy hh:mm tt"
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

$EventLogsEventIDsManualEntryCheckbox  = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Event IDs Manual Entry"
    Left   = $FormScale * 7
    Top    = $EventLogsOptionsGroupBox.Top + $EventLogsOptionsGroupBox.Height + $($FormScale * 10)
    Width  = $FormScale * 200
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
}
$Section1EventLogsTab.Controls.Add($EventLogsEventIDsManualEntryCheckbox)


$EventLogsEventIDsManualEntryLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Enter Event IDs; One Per Line"
    Left   = $FormScale * 5
    Top    = $EventLogsEventIDsManualEntryCheckbox.Top + $EventLogsEventIDsManualEntryCheckbox.Height
    Width  = $FormScale * 200
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = "Black"
}
$Section1EventLogsTab.Controls.Add($EventLogsEventIDsManualEntryLabel)


. "$Dependencies\Code\System.Windows.Forms\Button\EventLogsEventIDsManualEntrySelectionButton.ps1"
$EventLogsEventIDsManualEntrySelectionButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Select Event IDs"
    Left   = $FormScale * 4
    Top    = $EventLogsEventIDsManualEntryLabel.Top + $EventLogsEventIDsManualEntryLabel.Height
    Width  = $FormScale * 125
    Height = $FormScale * 20
    Add_Click = $EventLogsEventIDsManualEntrySelectionButtonAdd_Click
}
$Section1EventLogsTab.Controls.Add($EventLogsEventIDsManualEntrySelectionButton)
CommonButtonSettings -Button $EventLogsEventIDsManualEntrySelectionButton


$EventLogsEventIDsManualEntryClearButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Clear"
    Left   = $FormScale * 136
    Top    = $EventLogsEventIDsManualEntryLabel.Top + $EventLogsEventIDsManualEntryLabel.Height
    Width  = $FormScale * 75
    Height = $FormScale * 20
    Add_Click = { $EventLogsEventIDsManualEntryTextbox.Text = "" }
}
$Section1EventLogsTab.Controls.Add($EventLogsEventIDsManualEntryClearButton)
CommonButtonSettings -Button $EventLogsEventIDsManualEntryClearButton


$EventLogsEventIDsManualEntryTextbox = New-Object System.Windows.Forms.TextBox -Property @{
    Lines  = $null
    Left   = $FormScale * 5
    Top    = $EventLogsEventIDsManualEntryClearButton.Top + $EventLogsEventIDsManualEntryClearButton.Height + $($FormScale * 5)
    Width  = $FormScale * 205
    Height = $FormScale * 139
    MultiLine     = $True
    WordWrap      = $True
    AcceptsTab    = $false
    AcceptsReturn = $false
    ScrollBars    = "Vertical"
    Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section1EventLogsTab.Controls.Add($EventLogsEventIDsManualEntryTextbox)

# Imports code that populates the Event IDs Quick Pick Selection,
# esentially tying a single name/selection to multiple predetermined Event IDs
. "$Dependencies\Code\Main Body\Populate-EventLogsEventIDQuickPick.ps1"


$EventLogsQuickPickSelectionCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Event IDs Quick Selection"
    Left   = $FormScale * 220
    Top    = $EventLogsOptionsGroupBox.Top + $EventLogsOptionsGroupBox.Height + $($FormScale * 10)
    Width  = $FormScale * 200
    Height = $FormScale * 22
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
}
$Section1EventLogsTab.Controls.Add( $EventLogsQuickPickSelectionCheckbox )


$EventLogsQuickPickSelectionLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Event IDs by Topic - Can Select Multiple"
    Left   = $FormScale * 218
    Top    = $EventLogsQuickPickSelectionCheckbox.Top + $EventLogsQuickPickSelectionCheckbox.Height
    Width  = $FormScale * 410
    Height = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = "Black"
}
$Section1EventLogsTab.Controls.Add($EventLogsQuickPickSelectionLabel)


. "$Dependencies\Code\System.Windows.Forms\Button\EventLogsQuickPickSelectionClearButton.ps1"
$EventLogsQuickPickSelectionClearButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Clear"
    Left   = $FormScale * 356
    Top    = $EventLogsQuickPickSelectionLabel.Top + $EventLogsQuickPickSelectionLabel.Height
    Width  = $FormScale * 75
    Height = $FormScale * 20
    Add_Click = $EventLogsQuickPickSelectionClearButtonAdd_Click
}
$Section1EventLogsTab.Controls.Add($EventLogsQuickPickSelectionClearButton)
CommonButtonSettings -Button $EventLogsQuickPickSelectionClearButton


$EventLogsQuickPickSelectionSelectAllButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Select All"
    Left   = $EventLogsQuickPickSelectionClearButton.Left - $EventLogsQuickPickSelectionClearButton.Width - $($FormScale + 10)
    Top    = $EventLogsQuickPickSelectionClearButton.Top
    Width  = $FormScale * 75
    Height = $FormScale * 20
    Add_Click = { For ($i=0;$i -lt $EventLogsQuickPickSelectionCheckedlistbox.Items.count;$i++) { $EventLogsQuickPickSelectionCheckedlistbox.SetItemChecked($i,$true) } }
}
$Section1EventLogsTab.Controls.Add($EventLogsQuickPickSelectionSelectAllButton)
CommonButtonSettings -Button $EventLogsQuickPickSelectionSelectAllButton


. "$Dependencies\Code\System.Windows.Forms\CheckedListBox\EventLogsQuickPickSelectionCheckedListBox.ps1"
$EventLogsQuickPickSelectionCheckedListBox = New-Object -TypeName System.Windows.Forms.CheckedListBox -Property @{
    Name   = "Event Logs Selection"
    Text   = "Event Logs Selection"
    Left   = $FormScale * 220
    Top    = $EventLogsQuickPickSelectionClearButton.Top + $EventLogsQuickPickSelectionClearButton.Height + $($FormScale * 5)
    Width  = $FormScale * 210
    Height = $FormScale * 150
    ScrollAlwaysVisible = $true
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click = $EventLogsQuickPickSelectionCheckedListBoxAdd_Click
}
foreach ( $Query in $script:EventLogQueries ) { $EventLogsQuickPickSelectionCheckedListBox.Items.Add("$($Query.Name)") }
$Section1EventLogsTab.Controls.Add($EventLogsQuickPickSelectionCheckedListBox)


#============================================================================================================================================================
# Event Logs - Event IDs To Monitor
#============================================================================================================================================================
$script:EventLogSeverityQueries = @()

# The following were obtained from https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/plan/appendix-l--events-to-monitor
$EventLogNotes = "
A potential criticality of High means that one occurrence of the event should be investigated. Potential criticality of Medium or Low means that these events should only be investigated if they occur unexpectedly or in numbers that significantly exceed the expected baseline in a measured period of time. All organizations should test these recommendations in their environments before creating alerts that require mandatory investigative responses. Every environment is different, and some of the events ranked with a potential criticality of High may occur due to other harmless events.
"
$EventLogsToMonitorMicrosoft = Import-Csv -Path $EventLogsWindowITProCenter
$EventLogReference           = "https://conf.splunk.com/session/2015/conf2015_MGough_MalwareArchaelogy_SecurityCompliance_FindingAdvnacedAttacksAnd.pdf"
$EventLogNotes               = Get-Content -Path "$CommandsEventLogsDirectory\Individual Selection\Notes - Event Logs to Monitor - Window IT Pro Center.txt"

# Adds the Current Event Logs to the Selection Pane
$CurrentWindowsEventIdDuplicateCheck = @()
foreach ($CSVLine in $EventLogsToMonitorMicrosoft) {
    if ($CSVLine.CurrentWindowsEventID -ne "NA") {
        $EventLogQuery = New-Object PSObject -Property @{ EventID = $CSVLine.CurrentWindowsEventID }
        $EventLogQuery | Add-Member -MemberType NoteProperty -Name LegacyEventID -Value $CSVLine.LegacyWindowsEventID -Force
        $EventLogQuery | Add-Member -MemberType NoteProperty -Name Label         -Value "Windows IT Pro Center" -Force
        $EventLogQuery | Add-Member -MemberType NoteProperty -Name Severity      -Value $CSVLine.PotentialCriticality -Force
        $EventLogQuery | Add-Member -MemberType NoteProperty -Name Reference     -Value $EventLogReference -Force
        $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message       -Value $CSVLine.EventSummary -Force
        $EventLogQuery | Add-Member -MemberType NoteProperty -Name Notes         -Value $EventLogNotes -Force
        if ($CSVLine.CurrentWindowsEventID -notin $CurrentWindowsEventIdDuplicateCheck) {
            $script:EventLogSeverityQueries      += $EventLogQuery
            $CurrentWindowsEventIdDuplicateCheck += $CSVLine.CurrentWindowsEventID
        }
    }
}
# Adds the Legacy Event Logs to the Selection Pane
$LegacyWindowsEventIdDuplicateCheck = @()
foreach ($CSVLine in $EventLogsToMonitorMicrosoft) {
    if ($CSVLine.LegacyWindowsEventID -ne "NA") {
        $EventLogQuery = New-Object PSObject -Property @{ EventID = $CSVLine.LegacyWindowsEventID }
        $EventLogQuery | Add-Member -MemberType NoteProperty -Name LegacyEventID -Value $CSVLine.LegacyWindowsEventID -Force
        $EventLogQuery | Add-Member -MemberType NoteProperty -Name Label         -Value "Windows IT Pro Center" -Force
        $EventLogQuery | Add-Member -MemberType NoteProperty -Name Severity      -Value $CSVLine.PotentialCriticality -Force
        $EventLogQuery | Add-Member -MemberType NoteProperty -Name Reference     -Value $EventLogReference -Force
        $EventLogQuery | Add-Member -MemberType NoteProperty -Name Message       -Value "<Legacy> $($CSVLine.EventSummary)" -Force
        $EventLogQuery | Add-Member -MemberType NoteProperty -Name Notes         -Value $EventLogNotes -Force
        if ($CSVLine.LegacyWindowsEventID  -notin $LegacyWindowsEventIdDuplicateCheck) {
            $script:EventLogSeverityQueries     += $EventLogQuery
            $LegacyWindowsEventIdDuplicateCheck += $CSVLine.LegacyWindowsEventID
        }
    }
}


$EventLogsEventIDsToMonitorCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Event IDs To Monitor"
    Left   = $FormScale * 7
    Top    = $EventLogsEventIDsManualEntryTextbox.Top + $EventLogsEventIDsManualEntryTextbox.Height + $($FormScale * 15)
    Width  = $FormScale * 250
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
}
$Section1EventLogsTab.Controls.Add($EventLogsEventIDsToMonitorCheckbox)


. "$Dependencies\Code\System.Windows.Forms\Button\EventLogsEventIDsToMonitorClearButton.ps1"
$EventLogsEventIDsToMonitorClearButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Clear"
    Left   = $FormScale * 356
    Top    = $EventLogsEventIDsToMonitorCheckbox.Top + $EventLogsEventIDsToMonitorCheckbox.Height - $($FormScale * 3)
    Width  = $FormScale * 75
    Height = $FormScale * 20
    Add_Click = $EventLogsEventIDsToMonitorClearButtonAdd_Click
}
$Section1EventLogsTab.Controls.Add($EventLogsEventIDsToMonitorClearButton)
CommonButtonSettings -Button $EventLogsEventIDsToMonitorClearButton

<#
$EventLogsEventIDsToMonitorSelectAllButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Select All"
    Left   = $EventLogsEventIDsToMonitorClearButton.Left - $EventLogsEventIDsToMonitorClearButton.Width - $($FormScale + 10)
    Top    = $EventLogsEventIDsToMonitorClearButton.Top
    Width  = $FormScale * 75
    Height = $FormScale * 20
    Add_Click = { For ($i=0;$i -lt $EventLogsEventIDsToMonitorCheckListBox.Items.count;$i++) { $EventLogsEventIDsToMonitorCheckListBox.SetItemChecked($i,$true) } }
}
$Section1EventLogsTab.Controls.Add($EventLogsEventIDsToMonitorSelectAllButton)
CommonButtonSettings -Button $EventLogsEventIDsToMonitorSelectAllButton
#>

$EventLogsEventIDsToMonitorLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Events IDs to Monitor for Signs of Compromise"
    Left   = $FormScale * 5
    Top    = $EventLogsEventIDsToMonitorCheckbox.Top + $EventLogsEventIDsToMonitorCheckbox.Height
    Width  = $FormScale * 410
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = "Black"
}
$Section1EventLogsTab.Controls.Add($EventLogsEventIDsToMonitorLabel)


. "$Dependencies\Code\System.Windows.Forms\CheckedListBox\EventLogsEventIDsToMonitorCheckedListBox.ps1"
$EventLogsEventIDsToMonitorCheckListBox = New-Object -TypeName System.Windows.Forms.CheckedListBox -Property @{
    Text   = "Event IDs [Potential Criticality] Event Summary"
    Left   = $FormScale * 5
    Top    = $EventLogsEventIDsToMonitorLabel.Top + $EventLogsEventIDsToMonitorLabel.Height
    Width  = $FormScale * 425
    Height = $FormScale * 125
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
$EventLogsEventIDsToMonitorCheckListBox.Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
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
$script:ProgressBarFormProgressBar.Value += 1
$script:ProgressBarSelectionForm.Refresh()

. "$Dependencies\Code\Main Body\Search-Registry.ps1"
$Section1RegistryTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text     = "Registry"
    Location = @{ X = $FormScale * $RegistryRightPosition
                  Y = $FormScale * $RegistryDownPosition }
    Size     = @{ Width  = $FormScale * 450
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
}
$MainLeftCollectionsTabControl.Controls.Add($Section1RegistryTab)


. "$Dependencies\Code\System.Windows.Forms\CheckBox\RegistrySearchCheckbox.ps1"
$RegistrySearchCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Registry Search (WinRM)"
    Location = @{ X = $FormScale * 3
                  Y = $FormScale * 15 }
    Size     = @{ Width  = $FormScale * 230
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = $RegistrySearchCheckboxAdd_Click
}
$Section1RegistryTab.Controls.Add($RegistrySearchCheckbox)


$RegistrySearchRecursiveCheckbox = New-Object System.Windows.Forms.Checkbox -Property @{
    Text     = "Recursive Search"
    Location = @{ X = $RegistrySearchCheckbox.Size.Width + $($FormScale * 85)
                  Y = $RegistrySearchCheckbox.Location.Y + $($FormScale * 3) }
    Size     = @{ Width  = $FormScale * 200
                  Height = $FormScale * 22 }
    Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor  = "Black"
}
$Section1RegistryTab.Controls.Add($RegistrySearchRecursiveCheckbox)
$script:RegistrySelected = ''


$RegistrySearchLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = "The collection time is depenant on the number of paths and queries entered, and more so if recursive is selected."
    Location = @{ X = $RegistrySearchCheckbox.Location.X
                  Y = $RegistrySearchRecursiveCheckbox.Location.Y + $RegistrySearchRecursiveCheckbox.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 300
                  Height = $FormScale * 40 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = "Black"
}
$Section1RegistryTab.Controls.Add($RegistrySearchLabel)


$RegistrySearchReferenceButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Select Location"
    Location = @{ X = $RegistrySearchLabel.Location.X + $RegistrySearchLabel.Size.Width + $($FormScale * 30)
                  Y = $RegistrySearchLabel.Location.Y }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Add_Click = {
        Import-Csv "$Dependencies\Reference Registry Locations.csv" | Out-GridView -Title 'PoSh-EasyWin Registry Reference Selection' -PassThru | Set-Variable -Name RegistryReferenceSelected
        $script:RegistrySearchDirectoryRichTextbox.text = ''
        foreach ($Registry in $RegistryReferenceSelected) { $script:RegistrySearchDirectoryRichTextbox.Lines += $Registry.Location}
    }
}
$Section1RegistryTab.Controls.Add($RegistrySearchReferenceButton)
CommonButtonSettings -Button $RegistrySearchReferenceButton


. "$Dependencies\Code\System.Windows.Forms\RichTextBox\RegistrySearchDirectoryRichTextbox.ps1"
$script:RegistrySearchDirectoryRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Text     = "Enter Registry Paths; One Per Line"
    Location = @{ X = $RegistrySearchLabel.Location.X
                  Y = $RegistrySearchLabel.Location.Y + $RegistrySearchLabel.Size.Height }
    Size     = @{ Width  = $FormScale * 430
                  Height = $FormScale * 80 }
    MultiLine     = $True
    ShortcutsEnabled = $true
    Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_MouseEnter = $RegistrySearchDirectoryRichTextboxAdd_MouseEnter
    Add_MouseLeave = $RegistrySearchDirectoryRichTextboxAdd_MouseLeave
    Add_MouseHover = $RegistrySearchDirectoryRichTextboxAdd_MouseHover
}
$Section1RegistryTab.Controls.Add($script:RegistrySearchDirectoryRichTextbox)


. "$Dependencies\Code\System.Windows.Forms\CheckBox\RegistryKeyNameCheckbox.ps1"
$RegistryKeyNameCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Key Name (Supports RegEx)"
    Location = @{ X = $script:RegistrySearchDirectoryRichTextbox.Location.X
                  Y = $script:RegistrySearchDirectoryRichTextbox.Location.Y + $script:RegistrySearchDirectoryRichTextbox.Size.Height + $($FormScale * 10) }
    Size     = @{ Width  = $FormScale * 300
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click = $RegistryKeyNameCheckBoxAdd_Click
}
$Section1RegistryTab.Controls.Add($RegistryKeyNameCheckbox)


$SupportsRegexButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Regex Examples"
    Location = @{ X = $RegistryKeyNameCheckbox.Location.X + $RegistryKeyNameCheckbox.Size.Width + $($FormScale * 28)
                  Y = $RegistryKeyNameCheckbox.Location.Y }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Add_Click = { Import-Csv "$Dependencies\Reference RegEx Examples.csv" | Out-GridView }
}
$Section1RegistryTab.Controls.Add($SupportsRegexButton)
CommonButtonSettings -Button $SupportsRegexButton


. "$Dependencies\Code\System.Windows.Forms\RichTextBox\RegistryKeyNameSearchRichTextbox.ps1"
$script:RegistryKeyNameSearchRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Text     = "Enter Key Name; One Per Line"
    Location = @{ X = $RegistryKeyNameCheckbox.Location.X
                  Y = $RegistryKeyNameCheckbox.Location.Y + $RegistryKeyNameCheckbox.Size.Height + $($FormScale * 10) }
    Size     = @{ Width  = $FormScale * 430
                  Height = $FormScale * 80 }
    MultiLine     = $True
    ShortcutsEnabled = $true
    Font           = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_MouseEnter = $RegistryKeyNameSearchRichTextboxAdd_MouseEnter
    Add_MouseLeave = $RegistryKeyNameSearchRichTextboxAdd_MouseLeave
    Add_MouseHover = $RegistryKeyNameSearchRichTextboxAdd_MouseHover
}
$Section1RegistryTab.Controls.Add($script:RegistryKeyNameSearchRichTextbox)


. "$Dependencies\Code\System.Windows.Forms\CheckBox\RegistryValueNameCheckbox.ps1"
$RegistryValueNameCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Value Name (Supports RegEx)"
    Location = @{ X = $script:RegistryKeyNameSearchRichTextboxv.Location.X
                  Y = $script:RegistryKeyNameSearchRichTextbox.Location.Y + $script:RegistryKeyNameSearchRichTextbox.Size.Height + $($FormScale * 10) }
    Size     = @{ Width  = $FormScale * 300
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click = $RegistryValueNameCheckboxAdd_Click
}
$Section1RegistryTab.Controls.Add($RegistryValueNameCheckbox)


$SupportsRegexButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Regex Examples"
    Location = @{ X = $RegistryValueNameCheckbox.Location.X + $RegistryValueNameCheckbox.Size.Width + $($FormScale * 28)
                  Y = $RegistryValueNameCheckbox.Location.Y }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
}
$SupportsRegexButton.Add_Click({ Import-Csv "$Dependencies\Reference RegEx Examples.csv" | Out-GridView })
$Section1RegistryTab.Controls.Add($SupportsRegexButton)
CommonButtonSettings -Button $SupportsRegexButton


. "$Dependencies\Code\System.Windows.Forms\RichTextBox\RegistryValueNameSearchRichTextbox.ps1"
$script:RegistryValueNameSearchRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Text     = "Enter Value Name; One Per Line"
    Location = @{ X = $RegistryValueNameCheckbox.Location.X
                  Y = $RegistryValueNameCheckbox.Location.Y + $RegistryValueNameCheckbox.Size.Height + $($FormScale * 10) }
    Size     = @{ Width  = $FormScale * 430
                  Height = $FormScale * 80 }
    MultiLine     = $True
    ShortcutsEnabled = $true
    Font           = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_MouseEnter = $RegistryValueNameSearchRichTextboxAdd_MouseEnter
    Add_MouseLeave = $RegistryValueNameSearchRichTextboxAdd_MouseLeave
    Add_MouseHover = $RegistryValueNameSearchRichTextboxAdd_MouseHover
}
$Section1RegistryTab.Controls.Add($script:RegistryValueNameSearchRichTextbox)


. "$Dependencies\Code\System.Windows.Forms\CheckBox\RegistryValueDataCheckbox.ps1"
$RegistryValueDataCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Value Data (Supports RegEx)"
    Location = @{ X = $script:RegistryValueNameSearchRichTextbox.Location.X
                  Y = $script:RegistryValueNameSearchRichTextbox.Location.Y + $script:RegistryValueNameSearchRichTextbox.Size.Height + $($FormScale * 10) }
    Size     = @{ Width  = $FormScale * 300
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click = $RegistryValueDataCheckBoxAdd_Click
}
$Section1RegistryTab.Controls.Add($RegistryValueDataCheckbox)


$SupportsRegexButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Regex Examples"
    Location = @{ X = $RegistryValueDataCheckbox.Location.X + $RegistryValueDataCheckbox.Size.Width + $($FormScale * 28)
                  Y = $RegistryValueDataCheckbox.Location.Y }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Add_Click = { Import-Csv "$Dependencies\Reference RegEx Examples.csv" | Out-GridView }
}
$Section1RegistryTab.Controls.Add($SupportsRegexButton)
CommonButtonSettings -Button $SupportsRegexButton


. "$Dependencies\Code\System.Windows.Forms\RichTextBox\RegistryValueDataSearchRichTextbox.ps1"
$script:RegistryValueDataSearchRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Text     = "Enter Value Data; One Per Line"
    Location = @{ X = $RegistryValueDataCheckbox.Location.X
                  Y = $RegistryValueDataCheckbox.Location.Y + $RegistryValueDataCheckbox.Size.Height + $($FormScale * 10) }
    Size     = @{ Width  = $FormScale * 430
                  Height = $FormScale * 80 }
    MultiLine     = $True
    ShortcutsEnabled = $true
    Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
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
$script:ProgressBarFormProgressBar.Value += 1
$script:ProgressBarSelectionForm.Refresh()

$Section1FileSearchTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = "File Search"
    Left   = $FormScale * 3
    Top    = $FormScale * -10
    Width  = $FormScale * 450
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
}
$MainLeftCollectionsTabControl.Controls.Add($Section1FileSearchTab)

# Recursively goes through directories down to the specified depth
# Used for backwards compatibility with systems that have older PowerShell versions, newer versions of PowerShell has a -Depth parameter
. "$Dependencies\Code\Main Body\Get-ChildItemDepth.ps1"

# This code is used within both the Individual and Session Based execution modes
. "$Dependencies\Code\Main Body\Conduct-FileSearch.ps1"

$FileSearchDirectoryListingCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Directory Listing (WinRM)"
    Left   = $FormScale * 3
    Top    = $FormScale * 15
    Width  = $FormScale * 230
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
}
$Section1FileSearchTab.Controls.Add($FileSearchDirectoryListingCheckbox)


        $FileSearchDirectoryListingMaxDepthLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Recursive Depth"
            Left   = $FileSearchDirectoryListingCheckbox.Width + $($FormScale * 52)
            Top    = $FileSearchDirectoryListingCheckbox.Top + $($FormScale * 5)
            Width  = $FormScale * 100
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor  = "Black"
        }
        $Section1FileSearchTab.Controls.Add($FileSearchDirectoryListingMaxDepthLabel)


        $FileSearchDirectoryListingMaxDepthTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Text   = 0
            Left   = $FileSearchDirectoryListingMaxDepthLabel.Left + $FileSearchDirectoryListingMaxDepthLabel.Width
            Top    = $FileSearchDirectoryListingCheckbox.Top + $($FormScale * 2)
            Width  = $FormScale * 50
            Height = $FormScale * 20
            MultiLine = $false
            WordWrap  = $false
            Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $Section1FileSearchTab.Controls.Add($FileSearchDirectoryListingMaxDepthTextbox)


        $FileSearchDirectoryListingLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Collection time is dependant on the directory's contents."
            Left   = $FormScale * 3
            Top    = $FileSearchDirectoryListingCheckbox.Top + $FileSearchDirectoryListingCheckbox.Height + $($FormScale * 5)
            Width  = $FormScale * 330
            Height = $FormScale * 22
            Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = "Black"
        }
        $Section1FileSearchTab.Controls.Add($FileSearchDirectoryListingLabel)


        . "$Dependencies\Code\Main Body\Search-DirectoryTreeview.ps1"
        $FileSearchSearchResultsButton = New-Object System.Windows.Forms.Button -Property @{
            Text   = "Search Results"
            Left   = $FileSearchDirectoryListingLabel.Left + $FileSearchDirectoryListingLabel.Width
            Top    = $FileSearchDirectoryListingLabel.Top
            Width  = $FormScale * 100
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = "Black"
            Add_Click = {
                $FilSearchViewResultsOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{
                    Title = "Open Directory Files"
                    Filter = "CSV (*.csv)| *.csv|XML (*.xml)| *.xml|All files (*.*)|*.*"
                    InitialDirectory = $ExecAndScriptDir
                }
                $FilSearchViewResultsOpenFileDialog.ShowDialog()
                Search-DirectoryTreeView -Input $(Import-Csv $FilSearchViewResultsOpenFileDialog.FileName | ForEach-Object {$_.FullName.Trim("\")} )
            }
        }
        $Section1FileSearchTab.Controls.Add($FileSearchSearchResultsButton)
        CommonButtonSettings -Button $FileSearchSearchResultsButton


        . "$Dependencies\Code\System.Windows.Forms\TextBox\FileSearchDirectoryListingTextbox.ps1"
        $FileSearchDirectoryListingTextbox = New-Object System.Windows.Forms.TextBox -Property @{
            Left   = $FormScale * 3
            Top    = $FileSearchDirectoryListingLabel.Top + $FileSearchDirectoryListingLabel.Height + $($FormScale * 5)
            Width  = $FormScale * 430
            Height = $FormScale * 22
            MultiLine          = $False
            WordWrap           = $false
            Text               = "Enter a single directory"
            AutoCompleteSource = "FileSystem"
            AutoCompleteMode   = "SuggestAppend"
            Font               = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            Add_MouseEnter = $FileSearchDirectoryListingTextboxAdd_MouseEnter
            Add_MouseLeave = $FileSearchDirectoryListingTextboxAdd_MouseLeave
            Add_MouseHover = $FileSearchDirectoryListingTextboxAdd_MouseHover
        }
        $Section1FileSearchTab.Controls.Add($FileSearchDirectoryListingTextbox)


$FileSearchFileSearchCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "File Search (WinRM)"
    Left   = $FormScale * 3
    Top    = $FileSearchDirectoryListingTextbox.Top + $FileSearchDirectoryListingTextbox.Height + $($FormScale * 25)
    Width  = $FormScale * 230
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
}
$Section1FileSearchTab.Controls.Add($FileSearchFileSearchCheckbox)


        $FileSearchFileSearchMaxDepthLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Recursive Depth"
            Left   = $FileSearchFileSearchCheckbox.Width + $($FormScale * 52)
            Top    = $FileSearchFileSearchCheckbox.Top + $($FormScale * 5)
            Width  = $FormScale * 100
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor  = "Black"
        }
        $Section1FileSearchTab.Controls.Add($FileSearchFileSearchMaxDepthLabel)


        $FileSearchFileSearchMaxDepthTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Text   = 0
            Left   = $FileSearchFileSearchMaxDepthLabel.Left + $FileSearchFileSearchMaxDepthLabel.Width
            Top    = $FileSearchFileSearchCheckbox.Top + $($FormScale * 2)
            Width  = $FormScale * 50
            Height = $FormScale * 20
            MultiLine = $false
            WordWrap  = $false
            Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $Section1FileSearchTab.Controls.Add($FileSearchFileSearchMaxDepthTextbox)


        $FileSearchFileSearchLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Collection time depends on the number of files and directories, plus recursive depth."
            Left   = $FormScale * 3
            Top    = $FileSearchFileSearchMaxDepthTextbox.Top + $FileSearchFileSearchMaxDepthTextbox.Height + $($FormScale * 2)
            Width  = $FormScale * 450
            Height = $FormScale * 22
            Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = "Black"
        }
        $Section1FileSearchTab.Controls.Add($FileSearchFileSearchLabel)


        $FileSearchSearchByFileHashLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Search by Filename or Filehash:"
            Left   = $FileSearchFileSearchLabel.Left
            Top    = $FileSearchFileSearchLabel.Top + $FileSearchFileSearchLabel.Height
            Width  = $FormScale * 175
            Height = $FormScale * 22
            Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = "Black"
        }
        $Section1FileSearchTab.Controls.Add($FileSearchSearchByFileHashLabel)


        . "$Dependencies\Code\Main Body\Get-FileHash.ps1"
        $FileSearchSelectFileHashComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
            Text   = "Filename"
            Left   = $FileSearchSearchByFileHashLabel.Left + $FileSearchSearchByFileHashLabel.Width
            Top    = $FileSearchSearchByFileHashLabel.Top
            Width  = $FormScale * 100
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $HashingAlgorithms = @('Filename','MD5','SHA1','SHA256','SHA384','SHA512','RIPEMD160')
        ForEach ($Hash in $HashingAlgorithms) { $FileSearchSelectFileHashComboBox.Items.Add($Hash) }
        $Section1FileSearchTab.Controls.Add($FileSearchSelectFileHashComboBox)


        . "$Dependencies\Code\System.Windows.Forms\RichTextBox\FileSearchFileSearchDirectoryRichTextbox.ps1"
        $FileSearchFileSearchDirectoryRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Text   = "Enter Directories; One Per Line"
            Left   = $FormScale * 3
            Top    = $FileSearchSearchByFileHashLabel.Top + $FileSearchSearchByFileHashLabel.Height + ($FormScale * 5)
            Width  = $FormScale * 430
            Height = $FormScale * 80
            MultiLine = $True
            Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            Add_MouseEnter = $FileSearchFileSearchDirectoryRichTextboxAdd_MouseEnter
            Add_MouseLeave = $FileSearchFileSearchDirectoryRichTextboxAdd_MouseLeave
            Add_MouseHover = $FileSearchFileSearchDirectoryRichTextboxAdd_MouseHover
        }
        $Section1FileSearchTab.Controls.Add($FileSearchFileSearchDirectoryRichTextbox)


        . "$Dependencies\Code\System.Windows.Forms\RichTextBox\FileSearchFileSearchFileRichTextbox.ps1"
        $FileSearchFileSearchFileRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Text   = "Enter FileNames; One Per Line"
            Left   = $FormScale * 3
            Top    = $FileSearchFileSearchDirectoryRichTextbox.Top + $FileSearchFileSearchDirectoryRichTextbox.Height + $($FormScale * 5)
            Width  = $FormScale * 430
            Height = $FormScale * 80
            MultiLine  = $True
            ScrollBars = "Vertical" #Horizontal
            Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            Add_MouseEnter = $FileSearchFileSearchFileRichTextboxAdd_MouseEnter
            Add_MouseLeave = $FileSearchFileSearchFileRichTextboxAdd_MouseLeave
            Add_MouseHover = $FileSearchFileSearchFileRichTextboxAdd_MouseHover
        }
        $Section1FileSearchTab.Controls.Add($FileSearchFileSearchFileRichTextbox)


. "$Dependencies\Code\Main Body\Get-AlternateDataStream.ps1"
$FileSearchAlternateDataStreamCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Alternate Data Stream Search (WinRM)"
    Left   = $FormScale * 3
    Top    = $FileSearchFileSearchFileRichTextbox.Top + $FileSearchFileSearchFileRichTextbox.Height + $($FormScale * 20)
    Width  = $FormScale * 260
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
}
$Section1FileSearchTab.Controls.Add($FileSearchAlternateDataStreamCheckbox)


        $FileSearchAlternateDataStreamMaxDepthLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Recursive Depth"
            Left   = $FileSearchFileSearchCheckbox.Width + $($FormScale * 52)
            Top    = $FileSearchAlternateDataStreamCheckbox.Top + $($FormScale * 5)
            Width  = $FormScale * 100
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale *11),0,0,0)
        }
        $Section1FileSearchTab.Controls.Add($FileSearchAlternateDataStreamMaxDepthLabel)


        $FileSearchAlternateDataStreamMaxDepthTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Text   = 0
            Left   = $FileSearchAlternateDataStreamMaxDepthLabel.Left + $FileSearchAlternateDataStreamMaxDepthLabel.Width
            Top    = $FileSearchAlternateDataStreamCheckbox.Top + $($FormScale * 2)
            Width  = $FormScale * 50
            Height = $FormScale * 20
            MultiLine = $false
            Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $Section1FileSearchTab.Controls.Add($FileSearchAlternateDataStreamMaxDepthTextbox)


        $FileSearchAlternateDataStreamLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Exlcudes':`$DATA' stream, and will show the ADS name and its contents."
            Left   = $FormScale * 3
            Top    = $FileSearchAlternateDataStreamMaxDepthTextbox.Top + $FileSearchAlternateDataStreamMaxDepthTextbox.Height
            Width  = $FormScale * 450
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = "Black"
        }
        $Section1FileSearchTab.Controls.Add($FileSearchAlternateDataStreamLabel)


        . "$Dependencies\Code\System.Windows.Forms\RichTextBox\FileSearchAlternateDataStreamDirectoryRichTextbox.ps1"
        $FileSearchAlternateDataStreamDirectoryRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Lines  = "Enter Directories; One Per Line"
            Left   = $FormScale * 3
            Top    = $FileSearchAlternateDataStreamLabel.Top + $FileSearchAlternateDataStreamLabel.Height
            Width  = $FormScale * 430
            Height = $FormScale * 80
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            MultiLine     = $True
            Add_MouseEnter = $FileSearchAlternateDataStreamDirectoryRichTextboxAdd_MouseEnter
            Add_MouseLeave = $FileSearchAlternateDataStreamDirectoryRichTextboxAdd_MouseLeave
            Add_MouseHover = $FileSearchAlternateDataStreamDirectoryRichTextboxAdd_MouseHover
        }
        $Section1FileSearchTab.Controls.Add($FileSearchAlternateDataStreamDirectoryRichTextbox)


        . "$Dependencies\Code\System.Windows.Forms\Button\FileSearchAlternateDataStreamDirectoryExtractStreamDataButton.ps1"
        $FileSearchAlternateDataStreamDirectoryExtractStreamDataButton = New-Object System.Windows.Forms.Button -Property @{
            Text   = 'Retrieve & Extract Stream Data'
            Left   = $FileSearchAlternateDataStreamDirectoryRichTextbox.Left + $FileSearchAlternateDataStreamDirectoryRichTextbox.Width - $($FormScale * 200 - 1)
            Top    = $FileSearchAlternateDataStreamDirectoryRichTextbox.Top + $FileSearchAlternateDataStreamDirectoryRichTextbox.Height + $($FormScale * 5)
            Width  = $FormScale * 200
            Height = $FormScale * 20
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
$script:ProgressBarFormProgressBar.Value += 1
$script:ProgressBarSelectionForm.Refresh()

$NetworkConnectionSearchDownPosition = -10

$Section1NetworkConnectionsSearchTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text     = "Network"
    Location = @{ X = $FormScale * 3
                  Y = $FormScale * $NetworkConnectionSearchDownPosition }
    Size     = @{ Width  = $FormScale * 450
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
}
$MainLeftCollectionsTabControl.Controls.Add($Section1NetworkConnectionsSearchTab)

        $NetworkEndpointPacketCaptureCheckBox = New-Object System.Windows.Forms.CheckBox -Property @{
            Text     = "Endpoint Packet Capture"
            Location = @{ X = $FormScale * 3
                          Y = $Section1NetworkConnectionsSearchTab.Location.Y + $Section1NetworkConnectionsSearchTab.Size.Height + $($FormScale * 5) }
            Size     = @{ Width  = $FormScale * 175
                          Height = $FormScale * 22 }
            Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
            ForeColor = 'Blue'
            Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
        }
        $Section1NetworkConnectionsSearchTab.Controls.Add($NetworkEndpointPacketCaptureCheckBox)


        $NetworkEndpointPcapCaptureDurationLabel = New-Object System.Windows.Forms.Label -Property @{
            Text     = "Duration (Secs)"
            Location = @{ X = $NetworkEndpointPacketCaptureCheckBox.Location.X + $NetworkEndpointPacketCaptureCheckBox.Size.Width + $($FormScale * 12)
                          Y = $NetworkEndpointPacketCaptureCheckBox.Location.Y + $($FormScale * 5) }
            Size     = @{ Width  = $FormScale * 88
                          Height = $FormScale * 22 }
            Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $Section1NetworkConnectionsSearchTab.Controls.Add($NetworkEndpointPcapCaptureDurationLabel)


        $NetworkEndpointPacketCaptureDurationTextBox = New-Object System.Windows.Forms.TextBox -Property @{
            Text     = "60"
            Location = @{ X = $NetworkEndpointPcapCaptureDurationLabel.Location.X + $NetworkEndpointPcapCaptureDurationLabel.Size.Width
                          Y = $NetworkEndpointPcapCaptureDurationLabel.Location.Y - $($FormScale * 2) }
            Size     = @{ Width  = $FormScale * 30
                          Height = $FormScale * 22 }
            Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $Section1NetworkConnectionsSearchTab.Controls.Add($NetworkEndpointPacketCaptureDurationTextBox)


        $NetworkEndpointPcapCaptureMaxSizeLabel = New-Object System.Windows.Forms.Label -Property @{
            Text     = "Max (MB)"
            Location = @{ X = $NetworkEndpointPacketCaptureDurationTextBox.Location.X + $NetworkEndpointPacketCaptureDurationTextBox.Size.Width + $($FormScale * 35)
                          Y = $NetworkEndpointPacketCaptureDurationTextBox.Location.Y + $($FormScale * 2) }
            Size     = @{ Width  = $FormScale * 60
                          Height = $FormScale * 22 }
            Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $Section1NetworkConnectionsSearchTab.Controls.Add($NetworkEndpointPcapCaptureMaxSizeLabel)


        $NetworkEndpointPacketCaptureMaxSizeTextBox = New-Object System.Windows.Forms.TextBox -Property @{
            Text     = "50"
            Location = @{ X = $NetworkEndpointPcapCaptureMaxSizeLabel.Location.X + $NetworkEndpointPcapCaptureMaxSizeLabel.Size.Width
                          Y = $NetworkEndpointPcapCaptureMaxSizeLabel.Location.Y - $($FormScale * 2) }
            Size     = @{ Width  = $FormScale * 30
                          Height = $FormScale * 22 }
            Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $Section1NetworkConnectionsSearchTab.Controls.Add($NetworkEndpointPacketCaptureMaxSizeTextBox)


        $NetworkConnectionSearchRemoteIPAddressCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
            Text     = "Remote IP (WinRM)"
            Location = @{ X = $FormScale * 3
                          Y = $NetworkEndpointPacketCaptureCheckBox.Location.Y + $NetworkEndpointPacketCaptureCheckBox.Size.Height + $($FormScale * 10) }
            Size     = @{ Width  = $FormScale * 180
                          Height = $FormScale * 22 }
            Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
            ForeColor = 'Blue'
            Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
        }
        $Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchRemoteIPAddressCheckbox)


        . "$Dependencies\Code\System.Windows.Forms\Button\NetworkConnectionSearchRemoteIPAddressSelectionButton.ps1"
        $NetworkConnectionSearchRemoteIPAddressSelectionButton = New-Object System.Windows.Forms.Button -Property @{
            Text      = "Select IP Addresses"
            Location = @{ X = $NetworkConnectionSearchRemoteIPAddressCheckbox.Location.X
                          Y = $NetworkConnectionSearchRemoteIPAddressCheckbox.Location.Y + $NetworkConnectionSearchRemoteIPAddressCheckbox.Size.Height + $($FormScale * 3) }
            Size     = @{ Width  = $FormScale * 180
                          Height = $FormScale * 20 }
            Add_Click = $NetworkConnectionSearchRemoteIPAddressSelectionButtonAdd_Click
        }
        $Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchRemoteIPAddressSelectionButton)
        CommonButtonSettings -Button $NetworkConnectionSearchRemoteIPAddressSelectionButton


        . "$Dependencies\Code\System.Windows.Forms\RichTextBox\NetworkConnectionSearchRemoteIPAddressRichTextbox.ps1"
        $NetworkConnectionSearchRemoteIPAddressRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Lines     = "Enter Remote IPs; One Per Line"
            Location = @{ X = $NetworkConnectionSearchRemoteIPAddressSelectionButton.Location.X
                          Y = $NetworkConnectionSearchRemoteIPAddressSelectionButton.Location.Y + $NetworkConnectionSearchRemoteIPAddressSelectionButton.Size.Height + $($FormScale * 5) }
            Size     = @{ Width  = $FormScale * 180
                          Height = $FormScale * 115 }
            Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            MultiLine  = $True
            ScrollBars = "Vertical"
            WordWrap   = $True
            ShortcutsEnabled = $true
            Add_MouseEnter = $NetworkConnectionSearchRemoteIPAddressRichTextboxAdd_MouseEnter
            Add_MouseLeave = $NetworkConnectionSearchRemoteIPAddressRichTextboxAdd_MouseLeave
            Add_MouseHover = $NetworkConnectionSearchRemoteIPAddressRichTextboxAdd_MouseHover
        }
        $Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchRemoteIPAddressRichTextbox)


$NetworkConnectionSearchRemotePortCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Remote Port"
    Location = @{ X = $NetworkConnectionSearchRemoteIPAddressCheckbox.Location.X + $NetworkConnectionSearchRemoteIPAddressCheckbox.Size.Width + $($FormScale * 10)
                  Y = $NetworkConnectionSearchRemoteIPAddressCheckbox.Location.Y }
    Size     = @{ Width  = $FormScale * 115
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
}
$Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchRemotePortCheckbox)


        . "$Dependencies\Code\System.Windows.Forms\Button\NetworkConnectionSearchRemotePortSelectionButton.ps1"
        $NetworkConnectionSearchRemotePortSelectionButton = New-Object System.Windows.Forms.Button -Property @{
            Text      = "Select Ports"
            Location = @{ X = $NetworkConnectionSearchRemotePortCheckbox.Location.X
                          Y = $NetworkConnectionSearchRemotePortCheckbox.Location.Y + $NetworkConnectionSearchRemotePortCheckbox.Size.Height + $($FormScale * 3) }
            Size     = @{ Width  = $FormScale * 115
                          Height = $FormScale * 20 }
            Add_Click = $NetworkConnectionSearchRemotePortSelectionButtonAdd_Click
        }
        $Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchRemotePortSelectionButton)
        CommonButtonSettings -Button $NetworkConnectionSearchRemotePortSelectionButton


        . "$Dependencies\Code\System.Windows.Forms\RichTextBox\NetworkConnectionSearchRemotePortRichTextbox.ps1"
        $NetworkConnectionSearchRemotePortRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Lines     = "Enter Remote Ports; One Per Line"
            Location = @{ X = $NetworkConnectionSearchRemotePortSelectionButton.Location.X
                          Y = $NetworkConnectionSearchRemotePortSelectionButton.Location.Y + $NetworkConnectionSearchRemotePortSelectionButton.Size.Height + $($FormScale * 5) }
            Size     = @{ Width  = $FormScale * 115
                          Height = $FormScale * 115 }
            Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            MultiLine  = $True
            ScrollBars = "Vertical"
            WordWrap   = $True
            ShortcutsEnabled = $true
            Add_MouseEnter = $NetworkConnectionSearchRemotePortRichTextboxAdd_MouseEnter
            Add_MouseLeave = $NetworkConnectionSearchRemotePortRichTextboxAdd_MouseLeave
            Add_MouseHover = $NetworkConnectionSearchRemotePortRichTextboxAdd_MouseHover
        }
        $Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchRemotePortRichTextbox)


$NetworkConnectionSearchLocalPortCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Local Port"
    Location = @{ X = $NetworkConnectionSearchRemotePortCheckbox.Location.X + $NetworkConnectionSearchRemotePortCheckbox.Size.Width + $($FormScale * 10)
                  Y = $NetworkConnectionSearchRemotePortCheckbox.Location.Y }
    Size     = @{ Width  = $FormScale * 115
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
}
$Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchLocalPortCheckbox)


        . "$Dependencies\Code\System.Windows.Forms\Button\NetworkConnectionSearchLocalPortSelectionButton.ps1"
        $NetworkConnectionSearchLocalPortSelectionButton = New-Object System.Windows.Forms.Button -Property @{
            Text      = "Select Ports"
            Location = @{ X = $NetworkConnectionSearchLocalPortCheckbox.Location.X
                          Y = $NetworkConnectionSearchLocalPortCheckbox.Location.Y + $NetworkConnectionSearchLocalPortCheckbox.Size.Height + $($FormScale * 3) }
            Size     = @{ Width  = $FormScale * 115
                          Height = $FormScale * 20 }
            Add_Click = $NetworkConnectionSearchLocalPortSelectionButtonAdd_Click
        }
        $Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchLocalPortSelectionButton)
        CommonButtonSettings -Button $NetworkConnectionSearchLocalPortSelectionButton


        . "$Dependencies\Code\System.Windows.Forms\RichTextBox\NetworkConnectionSearchLocalPortRichTextbox.ps1"
        $NetworkConnectionSearchLocalPortRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Lines     = "Enter Local Ports; One Per Line"
            Location = @{ X = $NetworkConnectionSearchLocalPortSelectionButton.Location.X
                          Y = $NetworkConnectionSearchLocalPortSelectionButton.Location.Y  + $NetworkConnectionSearchLocalPortSelectionButton.Size.Height + $($FormScale * 5) }
            Size     = @{ Width  = $FormScale * 115
                          Height = $FormScale * 115 }
            Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
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


$NetworkConnectionSearchProcessCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Process Name (WinRM)"
    Location = @{ X = $FormScale * 3
                  Y = $NetworkConnectionSearchRemoteIPAddressRichTextbox.Location.Y + $NetworkConnectionSearchRemoteIPAddressRichTextbox.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 430
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
}
$Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchProcessCheckbox)

            $NetworkConnectionSearchProcessLabel = New-Object System.Windows.Forms.Label -Property @{
                Text     = "Check hosts for connections created by a given process."
                Location = @{ X = $FormScale * 3
                              Y = $NetworkConnectionSearchProcessCheckbox.Location.Y + $NetworkConnectionSearchProcessCheckbox.Size.Height + $($FormScale * 3) }
                Size     = @{ Width  = $FormScale * 430
                              Height = $FormScale * 22 }
                ForeColor = "Black"
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            }
            $Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchProcessLabel)


            . "$Dependencies\Code\System.Windows.Forms\RichTextBox\NetworkConnectionSearchProcessRichTextbox.ps1"
            $NetworkConnectionSearchProcessRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
                Lines    = "Enter Process Names; One Per Line"
                Location = @{ X = $FormScale * 3
                              Y = $NetworkConnectionSearchProcessLabel.Location.Y + $NetworkConnectionSearchProcessLabel.Size.Height + $($FormScale * 5) }
                Size     = @{ Width  = $FormScale * 430
                              Height = $FormScale * 100 }
                Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                MultiLine     = $True
                ScrollBars    = "Vertical"
                WordWrap      = $True
                ShortcutsEnabled = $true
                Add_MouseHover   = $NetworkConnectionSearchProcessRichTextboxAdd_MouseHover
                Add_MouseEnter   = $NetworkConnectionSearchProcessRichTextboxAdd_MouseEnter
                Add_MouseLeave   = $NetworkConnectionSearchProcessRichTextboxAdd_MouseLeave
            }
            $Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchProcessRichTextbox)


. "$Dependencies\Code\Main Body\Get-DNSCache.ps1"
$NetworkConnectionSearchDNSCacheCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "DNS Cache Entry (WinRM)"
    Location = @{ X = $FormScale * 3
                  Y = $NetworkConnectionSearchProcessRichTextbox.Location.Y + $NetworkConnectionSearchProcessRichTextbox.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 430
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
}
$Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchDNSCacheCheckbox)

            $NetworkConnectionSearchDNSCacheLabel = New-Object System.Windows.Forms.Label -Property @{
                Text     = "Check hosts' DNS Cache for entries that match given criteria."
                Location = @{ X = $FormScale * 3
                              Y = $NetworkConnectionSearchDNSCacheCheckbox.Location.Y + $NetworkConnectionSearchDNSCacheCheckbox.Size.Height + $($FormScale * 3) }
                Size     = @{ Width  = $FormScale * 430
                              Height = $FormScale * 22 }
                Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
            }
            $Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchDNSCacheLabel)


            . "$Dependencies\Code\System.Windows.Forms\RichTextBox\NetworkConnectionSearchDNSCacheRichTextbox.ps1"
            $NetworkConnectionSearchDNSCacheRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
                Lines     = "Enter DNS query information or IP addresses; One Per Line"
                Location = @{ X = $FormScale * 3
                              Y = $NetworkConnectionSearchDNSCacheLabel.Location.Y + $NetworkConnectionSearchDNSCacheLabel.Size.Height + $($FormScale * 5) }
                Size     = @{ Width  = $FormScale * 430
                              Height = $FormScale * 100 }
                Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
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
#  Parent: Main Form -> Main Left TabControl
#  ___         _                           _    _                        _____       _
# |_ _| _ __  | |_  ___  _ __  __ _   ___ | |_ (_)  ___   _ __   ___    |_   _|__ _ | |__   _ __    __ _   __ _   ___
#  | | | '_ \ | __|/ _ \| '__|/ _` | / __|| __|| | / _ \ | '_ \ / __|     | | / _` || '_ \ | '_ \  / _` | / _` | / _ \
#  | | | | | || |_|  __/| |  | (_| || (__ | |_ | || (_) || | | |\__ \     | || (_| || |_) || |_) || (_| || (_| ||  __/
# |___||_| |_| \__|\___||_|   \__,_| \___| \__||_| \___/ |_| |_||___/     |_| \__,_||_.__/ | .__/  \__,_| \__, | \___|
#                                                                                          |_|            |___/
#=======================================================================================================================================================================
$script:ProgressBarFormProgressBar.Value += 1
$script:ProgressBarSelectionForm.Refresh()

$Section1InteractionsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text     = "Interactions"
    Location = @{ X = $FormScale * 3
                  Y = $FormScale * 0 }
    Size     = @{ Width  = $FormScale * 450
                  Height = $FormScale * 25 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
}
$MainLeftTabControl.Controls.Add($Section1InteractionsTab)


$MainLeftSection1InteractionsTabTabControl = New-Object System.Windows.Forms.TabControl -Property @{
    Name     = "Interactions TabControl"
    Location = @{ X = $FormScale * $TabRightPosition
                  Y = $FormScale * $TabhDownPosition }
    Size     = @{ Width  = $FormScale * $TabAreaWidth
                  Height = $FormScale * $TabAreaHeight }
    ShowToolTips  = $True
    SelectedIndex = 0
    Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section1InteractionsTab.Controls.Add($MainLeftSection1InteractionsTabTabControl)


#==================================================================================================================================================================================
#
#  Parent: Main Form -> Main Left TabControl -> Interactions TabControl
#  __  __         _  _    _         _____             _                _         _          _          _    _                        _____       _
# |  \/  | _   _ | || |_ (_)       | ____| _ __    __| | _ __    ___  (_) _ __  | |_       / \    ___ | |_ (_)  ___   _ __   ___    |_   _|__ _ | |__   _ __    __ _   __ _   ___
# | |\/| || | | || || __|| | _____ |  _|  | '_ \  / _` || '_ \  / _ \ | || '_ \ | __|     / _ \  / __|| __|| | / _ \ | '_ \ / __|     | | / _` || '_ \ | '_ \  / _` | / _` | / _ \
# | |  | || |_| || || |_ | ||_____|| |___ | | | || (_| || |_) || (_) || || | | || |_     / ___ \| (__ | |_ | || (_) || | | |\__ \     | || (_| || |_) || |_) || (_| || (_| ||  __/
# |_|  |_| \__,_||_| \__||_|       |_____||_| |_| \__,_|| .__/  \___/ |_||_| |_| \__|   /_/   \_\\___| \__||_| \___/ |_| |_||___/     |_| \__,_||_.__/ | .__/  \__,_| \__, | \___|
#                                                       |_|                                                                                            |_|            |___/
#==================================================================================================================================================================================
$script:ProgressBarFormProgressBar.Value += 1
$script:ProgressBarSelectionForm.Refresh()

$Section1ActionOnEndpointTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = "Multi-Endpoint Actions"
    Left   = $FormScale * 3
    Top    = $FormScale * -10
    Width  = $FormScale * 440
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
}
$MainLeftSection1InteractionsTabTabControl.Controls.Add($Section1ActionOnEndpointTab)


$ActionsTabProcessKillerGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text   = "Process Stopper (WinRM)"
    Left   = $FormScale * 5
    Top    = $FormScale * 10
    Width  = $FormScale * 425
    Height = $FormScale * 89
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
}
            $ActionsTabProcessKillerLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Stop Multiple Processes On Multiple Endpoints."
                Left   = $FormScale * 7
                Top    = $FormScale * 22
                Width  = $FormScale * 410
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
            }
            $ActionsTabProcessKillerGroupBox.Controls.Add($ActionsTabProcessKillerLabel)


            $ActionsTabProcessKillerCollectNewProcessDataRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text   = "Collect Process Data From Endpoints"
                Left   = $FormScale * 12
                Top    = $ActionsTabProcessKillerLabel.Top + $ActionsTabProcessKillerLabel.Height
                Width  = $FormScale * 255
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
                Checked   = $true
            }
            $ActionsTabProcessKillerGroupBox.Controls.Add($ActionsTabProcessKillerCollectNewProcessDataRadioButton)


            $ActionsTabProcessKillerSelectFileRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text   = "Open Process Data From CSV File"
                Left   = $FormScale * 12
                Top    = $ActionsTabProcessKillerCollectNewProcessDataRadioButton.Top + $ActionsTabProcessKillerCollectNewProcessDataRadioButton.Height
                Width  = $FormScale * 255
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
            }
            $ActionsTabProcessKillerGroupBox.Controls.Add($ActionsTabProcessKillerSelectFileRadioButton)


            . "$Dependencies\Code\Execution\Action\Stop-ProcessesOnMultipleComputers.ps1"
            $ActionsTabProcessKillerButton = New-Object System.Windows.Forms.Button -Property @{
                Text   = "Select Processes To Stop"
                Left   = $FormScale * 268
                Top    = $ActionsTabProcessKillerSelectFileRadioButton.Top - $($FormScale * 5)
                Width  = $FormScale * 150
                Height = $FormScale * 22
                Add_Click = {
                    if ($ActionsTabProcessKillerCollectNewProcessDataRadioButton.checked){
                        Stop-ProcessesOnMultipleComputers -CollectNewProcessData
                    }
                    if ($ActionsTabProcessKillerSelectFileRadioButton.checked){
                        Stop-ProcessesOnMultipleComputers -SelectProcessCsvFile
                    }
                }
            }
            $ActionsTabProcessKillerGroupBox.Controls.Add($ActionsTabProcessKillerButton)
            CommonButtonSettings -Button $ActionsTabProcessKillerButton
$Section1ActionOnEndpointTab.Controls.Add($ActionsTabProcessKillerGroupBox)


$ActionsTabServiceKillerGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text   = "Service Stopper (WinRM)"
    Left   = $FormScale * 5
    Top    = $ActionsTabProcessKillerGroupBox.Top + $ActionsTabProcessKillerGroupBox.Height + $($FormScale * 10)
    Width  = $FormScale * 425
    Height = $FormScale * 89
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
}
            $ActionsTabServiceKillerLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Stop Multiple Services On Multiple endpoints."
                Left   = $FormScale * 7
                Top    = $FormScale * 22
                Width  = $FormScale * 410
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
            }
            $ActionsTabServiceKillerGroupBox.Controls.Add($ActionsTabServiceKillerLabel)


            $ActionsTabServiceKillerCollectNewServiceDataRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text   = "Collect Service Data From Endpoints"
                Left   = $FormScale * 12
                Top    = $ActionsTabServiceKillerLabel.Top + $ActionsTabServiceKillerLabel.Height
                Width  = $FormScale * 255
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
                Checked   = $true
            }
            $ActionsTabServiceKillerGroupBox.Controls.Add($ActionsTabServiceKillerCollectNewServiceDataRadioButton)


            $ActionsTabServiceKillerSelectFileRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text   = "Open Service Data From CSV File"
                Left   = $FormScale * 12
                Top    = $ActionsTabServiceKillerCollectNewServiceDataRadioButton.Top + $ActionsTabServiceKillerCollectNewServiceDataRadioButton.Height
                Width  = $FormScale * 255
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
            }
            $ActionsTabServiceKillerGroupBox.Controls.Add($ActionsTabServiceKillerSelectFileRadioButton)


            . "$Dependencies\Code\Execution\Action\Stop-ServicesOnMultipleComputers.ps1"
            $ActionsTabServiceKillerButton = New-Object System.Windows.Forms.Button -Property @{
                Text   = "Select Services To Stop"
                Left   = $FormScale * 268
                Top    = $ActionsTabServiceKillerSelectFileRadioButton.Top - $($FormScale * 5)
                Width  = $FormScale * 150
                Height = $FormScale * 22
                Add_Click = {
                    if ($ActionsTabServiceKillerCollectNewServiceDataRadioButton.checked){
                        Stop-ServicesOnMultipleComputers -CollectNewServiceData
                    }
                    if ($ActionsTabServiceKillerSelectFileRadioButton.checked){
                        Stop-ServicesOnMultipleComputers -SelectServiceCsvFile
                    }
                }
            }
            $ActionsTabServiceKillerGroupBox.Controls.Add($ActionsTabServiceKillerButton)
            CommonButtonSettings -Button $ActionsTabServiceKillerButton
$Section1ActionOnEndpointTab.Controls.Add($ActionsTabServiceKillerGroupBox)


$ActionsTabAccountLogoutGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text   = "Account Logout (WinRM)"
    Left   = $FormScale * 5
    Top    = $ActionsTabServiceKillerGroupBox.Top + $ActionsTabServiceKillerGroupBox.Height + $($FormScale * 10)
    Width  = $FormScale * 425
    Height = $FormScale * 89
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
}
            $ActionsTabAccountLogoutLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Logout Multiple Accounts On multiple Endpoints."
                Left   = $FormScale * 7
                Top    = $FormScale * 22
                Width  = $FormScale * 410
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
            }
            $ActionsTabAccountLogoutGroupBox.Controls.Add($ActionsTabAccountLogoutLabel)


            $ActionsTabAccountLogoutCollectLoggedOnAccountsRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text   = "Collect Logged On Accounts From Endpoints"
                Left   = $FormScale * 12
                Top    = $ActionsTabAccountLogoutLabel.Top + $ActionsTabAccountLogoutLabel.Height
                Width  = $FormScale * 255
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
                Checked   = $true
            }
            $ActionsTabAccountLogoutGroupBox.Controls.Add($ActionsTabAccountLogoutCollectLoggedOnAccountsRadioButton)


            $ActionsTabAccountLogoutSelectFileRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text   = "Open Logged On Accounts From CSV File"
                Left   = $FormScale * 12
                Top    = $ActionsTabAccountLogoutCollectLoggedOnAccountsRadioButton.Top + $ActionsTabAccountLogoutCollectLoggedOnAccountsRadioButton.Height
                Width  = $FormScale * 255
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
            }
            $ActionsTabAccountLogoutGroupBox.Controls.Add($ActionsTabAccountLogoutSelectFileRadioButton)


            . "$Dependencies\Code\Execution\Action\Logout-AccountsOnMultipleComputers.ps1"
            $ActionsTabAccountLogoutButton = New-Object System.Windows.Forms.Button -Property @{
                Text   = "Select Accounts to Logout"
                Left   = $FormScale * 268
                Top    = $ActionsTabAccountLogoutSelectFileRadioButton.Top - $($FormScale * 5)
                Width  = $FormScale * 150
                Height = $FormScale * 22
                Add_Click = {
                    if ($ActionsTabAccountLogoutCollectLoggedOnAccountsRadioButton.checked){
                        Logout-AccountsOnMultipleComputers -CollectNewAccountData
                    }
                    elseif ($ActionsTabAccountLogoutSelectFileRadioButton.checked){
                        Logout-AccountsOnMultipleComputers -SelectAccountCsvFile
                    }
                }
            }
            $ActionsTabAccountLogoutGroupBox.Controls.Add($ActionsTabAccountLogoutButton)
            CommonButtonSettings -Button $ActionsTabAccountLogoutButton
$Section1ActionOnEndpointTab.Controls.Add($ActionsTabAccountLogoutGroupBox)


$ActionsTabKillNetworkConnectionGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text   = "Network Connection Killer (WinRM)"
    Left   = $FormScale * 5
    Top    = $ActionsTabAccountLogoutGroupBox.Top + $ActionsTabAccountLogoutGroupBox.Height + $($FormScale * 10)
    Width  = $FormScale * 425
    Height = $FormScale * 89
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
}
            $ActionsTabKillNetworkConnectionLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Kill Multiple Network Connections On Multiple Endpoints. (Kills Owning PID)"
                Left   = $FormScale * 7
                Top    = $FormScale * 22
                Width  = $FormScale * 410
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
            }
            $ActionsTabKillNetworkConnectionGroupBox.Controls.Add($ActionsTabKillNetworkConnectionLabel)


            $ActionsTabGetNetworkConnectionsRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text   = "Collect Network Connections from Endpoints"
                Left   = $FormScale * 12
                Top    = $ActionsTabKillNetworkConnectionLabel.Top + $ActionsTabKillNetworkConnectionLabel.Height
                Width  = $FormScale * 255
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
                Checked   = $true
            }
            $ActionsTabKillNetworkConnectionGroupBox.Controls.Add($ActionsTabGetNetworkConnectionsRadioButton)


            $ActionsTabKillNetworkConnectionsSelectFileRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text   = "Open Network Connections From CSV File"
                Left   = $FormScale * 12
                Top    = $ActionsTabGetNetworkConnectionsRadioButton.Top + $ActionsTabGetNetworkConnectionsRadioButton.Height
                Width  = $FormScale * 255
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
            }
            $ActionsTabKillNetworkConnectionGroupBox.Controls.Add($ActionsTabKillNetworkConnectionsSelectFileRadioButton)


            . "$Dependencies\Code\Execution\Action\Kill-NetworkConnectionsOnMultipleComputers.ps1"
            $ActionsTabSelectNetworkConnectionsToKillButton = New-Object System.Windows.Forms.Button -Property @{
                Text   = "Select Connections To Kill"
                Left   = $FormScale * 268
                Top    = $ActionsTabKillNetworkConnectionsSelectFileRadioButton.Top - $($FormScale * 5)
                Width  = $FormScale * 150
                Height = $FormScale * 22
                Add_Click = {
                    if ($ActionsTabGetNetworkConnectionsRadioButton.checked){
                        Kill-NetworkConnectionsOnMultipleComputers -CollectNewNetworkConnections
                    }
                    elseif ($ActionsTabKillNetworkConnectionsSelectFileRadioButton.checked){
                        Kill-NetworkConnectionsOnMultipleComputers -SelectNetworkConnectionsCsvFile
                    }
                }
            }
            $ActionsTabKillNetworkConnectionGroupBox.Controls.Add($ActionsTabSelectNetworkConnectionsToKillButton)
            CommonButtonSettings -Button $ActionsTabSelectNetworkConnectionsToKillButton
$Section1ActionOnEndpointTab.Controls.Add($ActionsTabKillNetworkConnectionGroupBox)


$ActionsTabQuarantineEndpointGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text   = "Quarantine Endpoints (WinRM) - BETA"
    Left   = $FormScale * 5
    Top    = $ActionsTabKillNetworkConnectionGroupBox.Top + $ActionsTabKillNetworkConnectionGroupBox.Height + $($FormScale * 10)
    Width  = $FormScale * 425
    Height = $FormScale * 89
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
}
            $ActionsTabQuarantineEndpointLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Quarantine Using Firewall Rules - Access From:  "
                Left   = $FormScale * 7
                Top    = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                AutoSize  = $true
                ForeColor = 'Black'
            }
            $ActionsTabQuarantineEndpointGroupBox.Controls.Add($ActionsTabQuarantineEndpointLabel)


            . "$Dependencies\Code\System.Windows.Forms\Textbox\ActionsTabQuarantineEndpointAccessFromIPSubnetTextbox.ps1"
            $ActionsTabQuarantineEndpointAccessFromIPSubnetTextbox = New-Object System.Windows.Forms.Textbox -Property @{
                Text   = "Enter IP, Range, or Subnet"
                Left   = $FormScale * 268
                Top    = $ActionsTabQuarantineEndpointLabel.Top
                Width  = $FormScale * 150
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor      = 'Black'
                Add_MouseEnter = $ActionsTabQuarantineEndpointAccessFromIPSubnetTextbox_MouseEnter
                Add_MouseLeave = $ActionsTabQuarantineEndpointAccessFromIPSubnetTextbox_MouseLeave
                Add_MouseHover = $ActionsTabQuarantineEndpointAccessFromIPSubnetTextbox_MouseHover
            }
            $ActionsTabQuarantineEndpointGroupBox.Controls.Add($ActionsTabQuarantineEndpointAccessFromIPSubnetTextbox)


            $ActionsTabCopyEndpointFirewallRulesRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text   = "Backup Firewall Rules and Quarantine"
                Left   = $FormScale * 12
                Top    = $ActionsTabQuarantineEndpointLabel.Top + $ActionsTabQuarantineEndpointLabel.Height
                Width  = $FormScale * 255
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
                Checked   = $true
                Add_Click = {
                    If ($this.checked){
                        $ActionsTabQuarantineEndpointAccessFromIPSubnetTextbox.Enabled = $true
                        $ActionsTabQuarantineEndpointsButton.text = "Backup and Quarantine"
                    }
                }
            }
            $ActionsTabQuarantineEndpointGroupBox.Controls.Add($ActionsTabCopyEndpointFirewallRulesRadioButton)


            $ActionsTabApplyFirewallRulesLocalCopyToEndpointsRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text   = "Restore Firewall Rules and Un-Quarantine"
                Left   = $FormScale * 12
                Top    = $ActionsTabCopyEndpointFirewallRulesRadioButton.Top + $ActionsTabCopyEndpointFirewallRulesRadioButton.Height
                Width  = $FormScale * 255
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
                Add_CLick = {
                    If ($this.checked){$ActionsTabQuarantineEndpointAccessFromIPSubnetTextbox.Enabled = $false}
                    $ActionsTabQuarantineEndpointsButton.text = "Restore and Un-Quarantine"
                }
            }
            $ActionsTabQuarantineEndpointGroupBox.Controls.Add($ActionsTabApplyFirewallRulesLocalCopyToEndpointsRadioButton)


            . "$Dependencies\Code\Execution\Action\Quarantine-EndpointsWithFirewallRules.ps1"
            $ActionsTabQuarantineEndpointsButton = New-Object System.Windows.Forms.Button -Property @{
                Text   = "Backup and Quarantine"
                Left   = $FormScale * 268
                Top    = $ActionsTabApplyFirewallRulesLocalCopyToEndpointsRadioButton.Top - $($FormScale * 5)
                Width  = $FormScale * 150
                Height = $FormScale * 22
                Add_Click = {
                    if ($ActionsTabCopyEndpointFirewallRulesRadioButton.checked) {
                        Quarantine-EndpointsWithFirewallRules -CopyEndpointFirewallRulesToLocalhost
                    }
                    elseif ($ActionsTabApplyFirewallRulesLocalCopyToEndpointsRadioButton.checked) {
                        Quarantine-EndpointsWithFirewallRules -ApplyFirewallRulesLocalCopyToEndpoints
                    }
                    [system.media.systemsounds]::Exclamation.play()
                }
            }
            $ActionsTabQuarantineEndpointGroupBox.Controls.Add($ActionsTabQuarantineEndpointsButton)
            CommonButtonSettings -Button $ActionsTabQuarantineEndpointsButton
$Section1ActionOnEndpointTab.Controls.Add($ActionsTabQuarantineEndpointGroupBox)


#=======================================================================================================================================================================
#
#  Parent: Main Form -> Main Left TabControl -> Interactions TabControl
#  _____                          _          _      _                _____       _
# | ____|__  __ ___   ___  _   _ | |_  __ _ | |__  | |  ___  ___    |_   _|__ _ | |__   _ __    __ _   __ _   ___
# |  _|  \ \/ // _ \ / __|| | | || __|/ _` || '_ \ | | / _ \/ __|     | | / _` || '_ \ | '_ \  / _` | / _` | / _ \
# | |___  >  <|  __/| (__ | |_| || |_| (_| || |_) || ||  __/\__ \     | || (_| || |_) || |_) || (_| || (_| ||  __/
# |_____|/_/\_\\___| \___| \__,_| \__|\__,_||_.__/ |_| \___||___/     |_| \__,_||_.__/ | .__/  \__,_| \__, | \___|
#                                                                                      |_|            |___/
#=======================================================================================================================================================================
$script:ProgressBarFormProgressBar.Value += 1
$script:ProgressBarSelectionForm.Refresh()

$SysinternalsRightPosition     = 3
$SysinternalsDownPosition      = -10
$SysinternalsDownPositionShift = 22
$SysinternalsButtonWidth       = 110
$SysinternalsButtonHeight      = 22

$Section1ExecutablesTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text     = "Executables"
    Location = @{ X = $FormScale * $SysinternalsRightPosition
                  Y = $FormScale * $SysinternalsDownPosition }
    Size     = @{ Width  = $FormScale * 440
                  Height = $FormScale * 22 }
    UseVisualStyleBackColor = $True
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
# Test if the External Programs directory is present; if it's there load the tab
if (Test-Path $ExternalPrograms) { $MainLeftSection1InteractionsTabTabControl.Controls.Add($Section1ExecutablesTab) }

$SysinternalsDownPosition += $SysinternalsDownPositionShift


#============================================================================================================================================================
# Options GroupBox
#============================================================================================================================================================
$ExternalProgramsOptionsGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text      = "Collection Options"
    Location  = @{ X = $FormScale * $SysinternalsRightPosition
                   Y = $FormScale * $SysinternalsDownPosition }
    Size     = @{ Width  = $FormScale * 430
                  Height = $FormScale * 47 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
}
            $ExternalProgramsProtocolRadioButtonLabel = New-Object System.Windows.Forms.Label -Property @{
                Text     = "Protocol:"
                Location = @{ X = $FormScale * 7
                            Y = $FormScale * 22 }
                Size     = @{ Width  = $FormScale * 73
                            Height = $FormScale * 20 }
                Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
            }


            . "$Dependencies\Code\System.Windows.Forms\RadioButton\ExternalProgramsWinRMRadioButton.ps1"
            $ExternalProgramsWinRMRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text     = "WinRM"
                Location = @{ X = $FormScale * 80
                            Y = $FormScale * 19 }
                Size     = @{ Width  = $FormScale * 80
                            Height = $FormScale * 22 }
                Checked  = $True
                Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
                Add_Click      = $ExternalProgramsWinRMRadioButtonAdd_Click
                Add_MouseHover = $ExternalProgramsWinRMRadioButtonAdd_MouseHover
            }


            . "$Dependencies\Code\System.Windows.Forms\RadioButton\ExternalProgramsRPCRadioButton.ps1"
            $ExternalProgramsRPCRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text     = "RPC"
                Location = @{ X = $ExternalProgramsWinRMRadioButton.Location.X + $ExternalProgramsWinRMRadioButton.Size.Width + $($FormScale * 5)
                            Y = $ExternalProgramsWinRMRadioButton.Location.Y }
                Size     = @{ Width  = $FormScale * 60
                            Height = $FormScale * 22 }
                Checked  = $False
                Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
                Add_Click      = $ExternalProgramsRPCRadioButtonAdd_Click
                Add_MouseHover = $ExternalProgramsRPCRadioButtonAdd_MouseHover
            }


            $ExternalProgramsCheckTimeLabel = New-Object System.Windows.Forms.Label -Property @{
                Text     = "Recheck Time (secs):"
                Location = @{ X = $ExternalProgramsRPCRadioButton.Location.X + $ExternalProgramsRPCRadioButton.Size.Width + $($FormScale * 30)
                            Y = $ExternalProgramsRPCRadioButton.Location.Y + $($FormScale * 3) }
                Size     = @{ Width  = $FormScale * 130
                            Height = $FormScale * 22 }
                Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
            }


            . "$Dependencies\Code\System.Windows.Forms\TextBox\ExternalProgramsCheckTimeTextBox.ps1"
            $ExternalProgramsCheckTimeTextBox = New-Object System.Windows.Forms.TextBox -Property @{
                Text     = 15
                Location = @{ X = $ExternalProgramsCheckTimeLabel.Location.X + $ExternalProgramsCheckTimeLabel.Size.Width
                                Y = $ExternalProgramsCheckTimeLabel.Location.Y - 3 }
                Size     = @{ Width  = $FormScale * 30
                                Height = $FormScale * 22 }
                Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                Enabled  = $True
                Add_MouseHover = $ExternalProgramsCheckTimeTextBoxAdd_MouseHover
            }

            $ExternalProgramsOptionsGroupBox.Controls.AddRange(@($ExternalProgramsProtocolRadioButtonLabel,$ExternalProgramsRPCRadioButton,$ExternalProgramsWinRMRadioButton,$ExternalProgramsCheckTimeLabel,$ExternalProgramsCheckTimeTextBox))
$Section1ExecutablesTab.Controls.Add($ExternalProgramsOptionsGroupBox)


#============================================================================================================================================================
# Sysinternals Sysmon
#============================================================================================================================================================

. "$Dependencies\Code\System.Windows.Forms\CheckBox\SysinternalsSysmonCheckbox.ps1"
$SysinternalsSysmonCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text      = "Sysmon"
    Location  = @{ X = $ExternalProgramsOptionsGroupBox.Location.X + $($FormScale * 5)
                   Y = $ExternalProgramsOptionsGroupBox.Location.Y + $ExternalProgramsOptionsGroupBox.Size.Height + $($FormScale * 5) }
    AutoSize  = $true
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click      = $SysinternalsSysmonCheckBoxAdd_Click
    Add_MouseHover = $SysinternalsSysmonCheckboxAdd_MouseHover
}
$Section1ExecutablesTab.Controls.Add($SysinternalsSysmonCheckbox)


$ExternalProgramsSysmonGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Location  = @{ X = $ExternalProgramsOptionsGroupBox.Location.X
                   Y =  $ExternalProgramsOptionsGroupBox.Location.Y + $ExternalProgramsOptionsGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $ExternalProgramsOptionsGroupBox.Size.Width
                   Height = $FormScale * 133 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
}
            $SysinternalsSysmonLabel = New-Object System.Windows.Forms.Label -Property @{
                Location = @{ X = $FormScale * 5
                            Y = $FormScale * 20 }
                Size     = @{ Width  = $FormScale * 420
                            Height = $FormScale * 25 }
                Text      = "System Monitor (Sysmon) will be installed on the endpoints. Logs created by sysmon can be viewed via command lilne, Windows Event Viewer, or a SIEM."
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
            }
            $ExternalProgramsSysmonGroupBox.Controls.Add($SysinternalsSysmonLabel)

            # Selects the .xml configuration file for sysmon
            . "$Dependencies\Code\System.Windows.Forms\OpenFileDialog\Select-SysinternalsSysmonXmlConfig.ps1"
            $script:SysmonXMLPath = $null
            $SysinternalsSysmonSelectConfigButton = New-Object System.Windows.Forms.Button -Property @{
                Text     = "Select Config"
                Location = @{ X = $SysinternalsSysmonLabel.Location.X
                            Y = $SysinternalsSysmonLabel.Location.Y + $SysinternalsSysmonLabel.Size.Height + $($FormScale * 10) }
                Size     = @{ Width  = $FormScale * $SysinternalsButtonWidth
                            Height = $FormScale * $SysinternalsButtonHeight }
                Add_Click = { Select-SysinternalsSysmonXmlConfig }
            }
            $ExternalProgramsSysmonGroupBox.Controls.Add($SysinternalsSysmonSelectConfigButton)
            CommonButtonSettings -Button $SysinternalsSysmonSelectConfigButton


            . "$Dependencies\Code\System.Windows.Forms\Button\SysinternalsSysmonEventIdsButton.ps1"
            $SysinternalsSysmonEventIdsButton = New-Object System.Windows.Forms.Button -Property @{
                Text     = "Sysmon Event IDs"
                Location = @{ X = $SysinternalsSysmonSelectConfigButton.Location.X
                            Y = $SysinternalsSysmonSelectConfigButton.Location.Y + $SysinternalsSysmonSelectConfigButton.Size.Height + $($FormScale * 5) }
                Size     = @{ Width  = $FormScale * $SysinternalsButtonWidth
                            Height = $FormScale * $SysinternalsButtonHeight }
                Add_Click      = $SysinternalsSysmonEventIdsButtonAdd_Click
                Add_MouseHover = $SysinternalsSysmonEventIdsButtonAdd_MouseHover
            }
            $ExternalProgramsSysmonGroupBox.Controls.Add($SysinternalsSysmonEventIdsButton)
            CommonButtonSettings -Button $SysinternalsSysmonEventIdsButton


            $SysinternalsSysmonConfigTextBox = New-Object System.Windows.Forms.Textbox -Property @{
                Text     = "Config:"
                Location = @{ X = $FormScale * 125
                            Y = $SysinternalsSysmonSelectConfigButton.Location.Y + $($FormScale * 1) }
                Size     = @{ Width  = $FormScale * 300
                            Height = $FormScale * 22 }
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
                BackColor = "White"
                Enabled   = $false
                Multiline = $true
            }
            $ExternalProgramsSysmonGroupBox.Controls.Add($SysinternalsSysmonConfigTextBox)


            $SysinternalsSysmonRenameServiceProcessLabel = New-Object System.Windows.Forms.Label -Property @{
                Text     = "Service/Process Name:"
                Location = @{ X = $FormScale * 200
                            Y = $SysinternalsSysmonConfigTextBox.Location.Y + $SysinternalsSysmonConfigTextBox.Size.Height + $($FormScale * 8) }
                Size     = @{ Width  = $FormScale * 130
                            Height = $FormScale * 22 }
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Blue"
            }
            $ExternalProgramsSysmonGroupBox.Controls.Add($SysinternalsSysmonRenameServiceProcessLabel)


            . "$Dependencies\Code\System.Windows.Forms\Textbox\SysinternalsSysmonRenameServiceProcessTextBox.ps1"
            $SysinternalsSysmonRenameServiceProcessTextBox = New-Object System.Windows.Forms.Textbox -Property @{
                Text     = "Sysmon"
                Location = @{ X = $SysinternalsSysmonRenameServiceProcessLabel.Location.X + $SysinternalsSysmonRenameServiceProcessLabel.Size.Width + $($FormScale * 10)
                            Y = $SysinternalsSysmonRenameServiceProcessLabel.Location.Y - $($FormScale * 3) }
                Size     = @{ Width  = $FormScale * 85
                            Height = $FormScale * 22 }
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                Add_MouseHover = $SysinternalsSysmonRenameServiceProcessTextBoxAdd_MouseHover
            }
            $ExternalProgramsSysmonGroupBox.Controls.Add($SysinternalsSysmonRenameServiceProcessTextBox)


            $SysinternalsSysmonRenameDriverLabel = New-Object System.Windows.Forms.Label -Property @{
                Text     = "Driver Name:"
                Location = @{ X = $SysinternalsSysmonRenameServiceProcessLabel.Location.X
                            Y = $SysinternalsSysmonRenameServiceProcessLabel.Location.Y + $SysinternalsSysmonRenameServiceProcessLabel.Size.Height }
                Size     = @{ Width  = $SysinternalsSysmonRenameServiceProcessLabel.Size.Width
                            Height = $FormScale * 22 }
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Blue"
            }
            $ExternalProgramsSysmonGroupBox.Controls.Add($SysinternalsSysmonRenameDriverLabel)


            . "$Dependencies\Code\System.Windows.Forms\Textbox\SysinternalsSysmonRenameDriverTextBox.ps1"
            $SysinternalsSysmonRenameDriverTextBox = New-Object System.Windows.Forms.Textbox -Property @{
                Text     = "SysmonDrv"
                Location = @{ X = $SysinternalsSysmonRenameServiceProcessTextBox.Location.X
                            Y = $SysinternalsSysmonRenameDriverLabel.Location.Y - $($FormScale * 3) }
                Size     = @{ Width  = $SysinternalsSysmonRenameServiceProcessTextBox.Size.Width
                            Height = $FormScale * 22 }
                MaxLength = 8
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                Add_MouseHover = $SysinternalsSysmonRenameDriverTextBoxAdd_MouseHover
            }
            $ExternalProgramsSysmonGroupBox.Controls.Add($SysinternalsSysmonRenameDriverTextBox)
$Section1ExecutablesTab.Controls.Add($ExternalProgramsSysmonGroupBox)


#============================================================================================================================================================
# Sysinternals Autoruns
#============================================================================================================================================================

. "$Dependencies\Code\System.Windows.Forms\CheckBox\SysinternalsAutorunsCheckbox.ps1"
$SysinternalsAutorunsCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text      = "Autoruns"
    Location  = @{ X = $ExternalProgramsOptionsGroupBox.Location.X + $($FormScale * 5)
                   Y = $ExternalProgramsSysmonGroupBox.Location.Y + $ExternalProgramsSysmonGroupBox.Size.Height + $($FormScale * 5) }
    AutoSize  = $true
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
    Add_MouseHover = $SysinternalsAutorunsCheckboxAdd_MouseHover
}
$Section1ExecutablesTab.Controls.Add($SysinternalsAutorunsCheckbox)


$ExternalProgramsAutorunsGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Location  = @{ X = $ExternalProgramsSysmonGroupBox.Location.X
                   Y = $ExternalProgramsSysmonGroupBox.Location.Y + $ExternalProgramsSysmonGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $ExternalProgramsOptionsGroupBox.Size.Width
                   Height = $FormScale * 76 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
}
            $SysinternalsAutorunsLabel = New-Object System.Windows.Forms.Label -Property @{
                Location = @{ X = $FormScale * 5
                            Y = $FormScale * 20 }
                Size     = @{ Width  = $SysinternalsSysmonLabel.Size.Width
                            Height = $FormScale * 25 }
                Text      = "Obtains More Startup Information than Native WMI and other Windows Commands, like various built-in Windows Applications."
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
            }
            $ExternalProgramsAutorunsGroupBox.Controls.Add($SysinternalsAutorunsLabel)

            $SysinternalsDownPosition += $SysinternalsDownPositionShift


            . "$Dependencies\Code\System.Windows.Forms\Button\SysinternalsAutorunsButton.ps1"
            $SysinternalsAutorunsButton = New-Object System.Windows.Forms.Button -Property @{
                Text     = "Open Autoruns"
                Location = @{ X = $SysinternalsAutorunsLabel.Location.X
                            Y = $SysinternalsAutorunsLabel.Location.Y + $SysinternalsAutorunsLabel.Size.Height + $($FormScale * 5) }
                Size     = @{ Width  = $FormScale * $SysinternalsButtonWidth
                            Height = $FormScale * $SysinternalsButtonHeight }
                Add_Click = $SysinternalsAutorunsButtonAdd_Click
            }
            $ExternalProgramsAutorunsGroupBox.Controls.Add($SysinternalsAutorunsButton)
            CommonButtonSettings -Button $SysinternalsAutorunsButton


            $SysinternalsAutorunsRenameProcessLabel = New-Object System.Windows.Forms.Label -Property @{
                Text     = "Process Name:"
                Location = @{ X = $SysinternalsSysmonRenameServiceProcessLabel.Location.X
                            Y = $SysinternalsAutorunsButton.Location.Y }
                Size     = @{ Width  = $SysinternalsSysmonRenameServiceProcessLabel.Size.Width
                            Height = $FormScale * 22 }
                Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Blue"
            }
            $ExternalProgramsAutorunsGroupBox.Controls.Add($SysinternalsAutorunsRenameProcessLabel)


            . "$Dependencies\Code\System.Windows.Forms\Textbox\SysinternalsAutorunsRenameProcessTextBox.ps1"
            $SysinternalsAutorunsRenameProcessTextBox = New-Object System.Windows.Forms.Textbox -Property @{
                Text     = "Autoruns"
                Location = @{ X = $SysinternalsSysmonRenameServiceProcessTextBox.Location.X
                            Y = $SysinternalsAutorunsRenameProcessLabel.Location.Y - $($FormScale * 3) }
                Size     = @{ Width  = $SysinternalsSysmonRenameServiceProcessTextBox.Size.Width
                            Height = $FormScale * 22 }
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                Add_MouseHover = $SysinternalsAutorunsRenameProcessTextBoxAdd_MouseHover
            }
            $ExternalProgramsAutorunsGroupBox.Controls.Add($SysinternalsAutorunsRenameProcessTextBox)
$Section1ExecutablesTab.Controls.Add($ExternalProgramsAutorunsGroupBox)


#============================================================================================================================================================
# Sysinternals Process Monitor
#============================================================================================================================================================

. "$Dependencies\Code\System.Windows.Forms\CheckBox\SysinternalsProcessMonitorCheckbox.ps1"
$SysinternalsProcessMonitorCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Procmon"
    Location = @{ X = $ExternalProgramsAutorunsGroupBox.Location.X + $($FormScale * 5)
                  Y = $ExternalProgramsAutorunsGroupBox.Location.Y + $ExternalProgramsAutorunsGroupBox.Size.Height + $($FormScale * 5) }
    AutoSize  = $true
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
    Add_MouseHover = $SysinternalsProcessMonitorCheckboxAdd_MouseHover
}
$Section1ExecutablesTab.Controls.Add($SysinternalsProcessMonitorCheckbox)


$ExternalProgramsProcmonGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Location  = @{ X = $ExternalProgramsAutorunsGroupBox.Location.X
                   Y = $ExternalProgramsAutorunsGroupBox.Location.Y + $ExternalProgramsAutorunsGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $ExternalProgramsOptionsGroupBox.Size.Width
                   Height = $FormScale * 102 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
}
            $SysinternalsProcessMonitorLabel = New-Object System.Windows.Forms.Label -Property @{
                Location = @{ X = $FormScale * 5
                            Y = $FormScale * 20 }
                Size     = @{ Width  = $SysinternalsSysmonLabel.Size.Width
                            Height = $FormScale * 25 }
                Text      = "Obtains process data over a timespan and can easily return data in 100's of MBs. Checks are done to see if 500MB is available on the localhost and endpoints."
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
            }
            $ExternalProgramsProcmonGroupBox.Controls.Add($SysinternalsProcessMonitorLabel)

            $SysinternalsDownPosition += $SysinternalsDownPositionShift


            . "$Dependencies\Code\System.Windows.Forms\Button\SysinternalsProcmonButton.ps1"
            $SysinternalsProcmonButton = New-Object System.Windows.Forms.Button -Property @{
                Text     = "Open Procmon"
                Location = @{ X = $SysinternalsProcessMonitorLabel.Location.X
                            Y = $SysinternalsProcessMonitorLabel.Location.Y + $SysinternalsProcessMonitorLabel.Size.Height + $($FormScale * 5) }
                Size     = @{ Width  = $FormScale * $SysinternalsButtonWidth
                            Height = $FormScale * $SysinternalsButtonHeight }
                Add_Click = $SysinternalsProcmonButtonAdd_Click
            }
            $ExternalProgramsProcmonGroupBox.Controls.Add($SysinternalsProcmonButton)
            CommonButtonSettings -Button $SysinternalsProcmonButton


            $SysinternalsProcmonCaptureTimeLabel = New-Object System.Windows.Forms.Label -Property @{
                Text     = "Capture Time:"
                Location = @{ X = $SysinternalsSysmonRenameServiceProcessLabel.Location.X
                            Y = $SysinternalsProcmonButton.Location.Y }
                Size     = @{ Width  = $SysinternalsSysmonRenameServiceProcessLabel.Size.Width
                            Height = $FormScale * 22 }
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Blue"
            }
            $ExternalProgramsProcmonGroupBox.Controls.Add($SysinternalsProcmonCaptureTimeLabel)


            $script:SysinternalsProcessMonitorTimeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
                Text     = "5 Seconds"
                Location = @{ X = $SysinternalsSysmonRenameServiceProcessTextBox.Location.X
                            Y = $SysinternalsProcmonCaptureTimeLabel.Location.Y }
                Size     = @{ Width  = $SysinternalsSysmonRenameServiceProcessTextBox.Size.Width
                            Height = $FormScale * 22 }
                Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            }
            $ProcmonCaptureTimes = @('5 Seconds','10 Seconds','15 Seconds','30 Seconds','1 Minute','2 Minutes','3 Minutes','4 Minutes','5 Minutes')
                ForEach ($time in $ProcmonCaptureTimes) { $script:SysinternalsProcessMonitorTimeComboBox.Items.Add($time) }
            $ExternalProgramsProcmonGroupBox.Controls.Add($script:SysinternalsProcessMonitorTimeComboBox)


            $SysinternalsProcmonRenameProcessLabel = New-Object System.Windows.Forms.Label -Property @{
                Text     = "Process Name:"
                Location = @{ X = $SysinternalsSysmonRenameServiceProcessLabel.Location.X
                            Y = $SysinternalsProcmonCaptureTimeLabel.Location.Y + $SysinternalsProcmonCaptureTimeLabel.Size.Height + $($FormScale * 5) }
                Size     = @{ Width  = $SysinternalsSysmonRenameServiceProcessLabel.Size.Width
                            Height = $FormScale * 22 }
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Blue"
            }
            $ExternalProgramsProcmonGroupBox.Controls.Add($SysinternalsProcmonRenameProcessLabel)


            . "$Dependencies\Code\System.Windows.Forms\Textbox\SysinternalsProcmonRenameProcessTextBox.ps1"
            $SysinternalsProcmonRenameProcessTextBox = New-Object System.Windows.Forms.Textbox -Property @{
                Text     = "Procmon"
                Location = @{ X = $SysinternalsSysmonRenameServiceProcessTextBox.Location.X
                            Y = $SysinternalsProcmonRenameProcessLabel.Location.Y - $($FormScale * 3) }
                Size     = @{ Width  = $SysinternalsSysmonRenameServiceProcessTextBox.Size.Width
                            Height = $FormScale * 22 }
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                Add_MouseHover = $SysinternalsProcmonRenameProcessTextBoxAdd_MouseHover
            }
            $ExternalProgramsProcmonGroupBox.Controls.Add($SysinternalsProcmonRenameProcessTextBox)
$Section1ExecutablesTab.Controls.Add($ExternalProgramsProcmonGroupBox)


#============================================================================================================================================================
# User Specified Files and Custom Script
#============================================================================================================================================================

. "$Dependencies\Code\System.Windows.Forms\CheckBox\ExeScriptUserSpecifiedExecutableAndScriptCheckbox.ps1"
$ExeScriptUserSpecifiedExecutableAndScriptCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text      = "User Specified Files and Custom Script (WinRM)"
    Location  = @{ X = $ExternalProgramsProcmonGroupBox.Location.X + $($FormScale * 5)
                   Y = $ExternalProgramsProcmonGroupBox.Location.Y + $ExternalProgramsProcmonGroupBox.Size.Height + $($FormScale * 5) }
    AutoSize  = $true
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click      = $ExeScriptUserSpecifiedExecutableAndScriptCheckboxAdd_Click
    Add_MouseHover = $ExeScriptUserSpecifiedExecutableAndScriptCheckboxAdd_MouseHover
}
$Section1ExecutablesTab.Controls.Add($ExeScriptUserSpecifiedExecutableAndScriptCheckbox)


$ExeScriptProgramGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Location  = @{ X = $ExternalProgramsProcmonGroupBox.Location.X
                   Y = $ExternalProgramsProcmonGroupBox.Location.Y + $ExternalProgramsProcmonGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $ExternalProgramsProcmonGroupBox.Size.Width
                   Height = $FormScale * 135 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
}
            $ExeScriptProgramLabel = New-Object System.Windows.Forms.Label -Property @{
                Location = @{ X = $FormScale * 5
                            Y = $FormScale * 20 }
                Size     = @{ Width  = $FormScale * 420
                            Height = $FormScale * 25 }
                Text      = "Allows for the custom deployment of executables and scripts. Execution flow, cleanup, and retrieval of files is to be managed within the accompanying script."
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
            }
            $ExeScriptProgramGroupBox.Controls.Add($ExeScriptProgramLabel)


            . "$Dependencies\Code\System.Windows.Forms\OpenFileDialog\Select-UserSpecifiedExecutable.ps1"
            . "$Dependencies\Code\System.Windows.Forms\Button\ExeScriptSelectExecutableButton.ps1"
            $ExeScriptSelectExecutableButton = New-Object System.Windows.Forms.Button -Property @{
                Text     = "Select Dir or File"
                Location = @{ X = $ExeScriptProgramLabel.Location.X
                            Y = $ExeScriptProgramLabel.Location.Y + $ExeScriptProgramLabel.Size.Height + $($FormScale * 10) }
                Size     = @{ Width  = $FormScale * 110
                            Height = $FormScale * 22 }
                Add_Click      = { Select-UserSpecifiedExecutable }
                Add_MouseHover = $ExeScriptSelectExecutableButtonAdd_MouseHover
            }
            $ExeScriptProgramGroupBox.Controls.Add($ExeScriptSelectExecutableButton)
            CommonButtonSettings -Button $ExeScriptSelectExecutableButton


            $ExeScriptSelectExecutableTextBox = New-Object System.Windows.Forms.Textbox -Property @{
                Text     = "Directory:"
                Location = @{ X = $FormScale * 125
                            Y = $ExeScriptSelectExecutableButton.Location.Y + $($FormScale * 1) }
                Size     = @{ Width  = $FormScale * 200
                            Height = $FormScale * 22 }
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
                BackColor = "White"
                Enabled   = $false
                Multiline = $true
            }
            $ExeScriptProgramGroupBox.Controls.Add($ExeScriptSelectExecutableTextBox)


            $ExeScriptSelectDirRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text     = "Dir"
                Location = @{ X = $ExeScriptSelectExecutableTextBox.Location.X + $ExeScriptSelectExecutableTextBox.Size.Width + $($FormScale * 10)
                            Y = $ExeScriptSelectExecutableTextBox.Location.Y }
                Size     = @{ Width  = $FormScale * 45
                            Height = $FormScale * 22 }
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
                Add_Click = {
                    $ExeScriptSelectExecutableTextBox.text = "Directory:"
                    if ($ExeScriptSelectExecutableTextBox.text -eq "Directory:") {$ExeScriptUserSpecifiedExecutableAndScriptCheckbox.checked = $false}
                }
                Checked   = $True
            }
            $ExeScriptProgramGroupBox.Controls.Add($ExeScriptSelectDirRadioButton)


            $ExeScriptSelectFileRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text     = "File"
                Location = @{ X = $ExeScriptSelectDirRadioButton.Location.X + $ExeScriptSelectDirRadioButton.Size.Width
                            Y = $ExeScriptSelectDirRadioButton.Location.Y }
                Size     = @{ Width  = $FormScale * 40
                            Height = $FormScale * 22 }
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                Add_Click = {
                    $ExeScriptSelectExecutableTextBox.text = "File:"
                    if ($ExeScriptSelectExecutableTextBox.text -eq "File:") {$ExeScriptUserSpecifiedExecutableAndScriptCheckbox.checked = $false}
                }
                ForeColor = "Black"
            }
            $ExeScriptProgramGroupBox.Controls.Add($ExeScriptSelectFileRadioButton)



            . "$Dependencies\Code\System.Windows.Forms\OpenFileDialog\Select-UserSpecifiedScript.ps1"
            . "$Dependencies\Code\System.Windows.Forms\Button\ExeScriptSelectScriptButton.ps1"
            $ExeScriptSelectScriptButton = New-Object System.Windows.Forms.Button -Property @{
                Text     = "Select Script"
                Location = @{ X = $ExeScriptSelectExecutableButton.Location.X
                            Y = $ExeScriptSelectExecutableButton.Location.Y + $ExeScriptSelectExecutableButton.Size.Height + $($FormScale * 5) }
                Size     = @{ Width  = $FormScale * 110
                            Height = $FormScale * 22 }
                Add_Click      = { Select-UserSpecifiedScript }
                Add_MouseHover = $ExeScriptSelectScriptButtonAdd_MouseHover
            }
            $ExeScriptProgramGroupBox.Controls.Add($ExeScriptSelectScriptButton)
            CommonButtonSettings -Button $ExeScriptSelectScriptButton


            $ExeScriptSelectScriptTextBox = New-Object System.Windows.Forms.Textbox -Property @{
                Text     = "Script:"
                Location = @{ X = $FormScale * 125
                            Y = $ExeScriptSelectScriptButton.Location.Y + $($FormScale * 1) }
                Size     = @{ Width  = $ExeScriptSelectExecutableTextBox.Size.Width
                            Height = $FormScale * 22 }
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
                BackColor = "White"
                Enabled   = $false
                Multiline = $true
            }
            $ExeScriptProgramGroupBox.Controls.Add($ExeScriptSelectScriptTextBox)


            . "$Dependencies\Code\System.Windows.Forms\Checkbox\ExeScriptScriptOnlyCheckbox.ps1"
            $ExeScriptScriptOnlyCheckbox = New-Object System.Windows.Forms.Checkbox -Property @{
                Text     = "Script Only"
                Location = @{ X = $ExeScriptSelectDirRadioButton.Location.X
                            Y = $ExeScriptSelectScriptTextBox.Location.Y }
                Size     = @{ Width  = $FormScale * 90
                            Height = $FormScale * 22 }
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
                Add_Click = $ExeScriptScriptOnlyCheckboxAdd_Click
            }
            $ExeScriptProgramGroupBox.Controls.Add($ExeScriptScriptOnlyCheckbox)


            $ExeScriptDestinationDirectoryLabel = New-Object System.Windows.Forms.Label -Property @{
                Text     = "Destination Folder:"
                Location = @{ X = $ExeScriptSelectScriptButton.Location.X
                            Y = $ExeScriptSelectScriptButton.Location.Y + $ExeScriptSelectScriptButton.Size.Height + $($FormScale * 7) }
                Size     = @{ Width  = $FormScale * 110
                            Height = $FormScale * 22 }
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
            }
            $ExeScriptProgramGroupBox.Controls.Add($ExeScriptDestinationDirectoryLabel)


            $script:ExeScriptDestinationDirectoryTextBox = New-Object System.Windows.Forms.Textbox -Property @{
                Text     = "C:\Windows\Temp\"
                Location = @{ X = $FormScale * 125
                            Y = $ExeScriptDestinationDirectoryLabel.Location.Y - $($FormScale * 2) }
                Size     = @{ Width  = $FormScale * 300
                            Height = $FormScale * 22 }
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                AutoCompleteSource = "FileSystem"
                AutoCompleteMode   = "SuggestAppend"
                }
            $ExeScriptProgramGroupBox.Controls.Add($script:ExeScriptDestinationDirectoryTextBox)
$Section1ExecutablesTab.Controls.Add($ExeScriptProgramGroupBox)


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
$script:ProgressBarFormProgressBar.Value += 1
$script:ProgressBarSelectionForm.Refresh()

$EnumerationRightPosition     = 3
$EnumerationLabelWidth        = 450
$EnumerationLabelHeight       = 25
$EnumerationGroupGap          = 15
#batman
$Section1EnumerationTab = New-Object System.Windows.Forms.TabPage -Property @{
    Name   = "Enumeration"
    Text   = "Enumeration"
    Left   = $FormScale * $EnumerationRightPosition
    Top    = 0
    Width  = $FormScale * $EnumerationLabelWidth
    Height = $FormScale * $EnumerationLabelHeight
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
}
$MainLeftTabControl.Controls.Add($Section1EnumerationTab)

# Enumeration - Domain Generated Input Check
. "$Dependencies\Code\Execution\Enumeration\InputCheck-EnumerationByDomainImport.ps1"

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


$EnumerationPortScanGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text   = "Create List From TCP Port Scan"
    Left   = 0
    Top    = $FormScale * 13
    Width  = $FormScale * 294
    Height = $FormScale * 350
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
}
           $script:EnumerationPortScanSpecificComputerNodeCheckbox = New-Object System.Windows.Forms.checkbox -Property @{
                Text   = "Scan Endpoints That Are Checkboxed"
                Left   = $FormScale * 3
                Top    = $FormScale * 15
                Width  = $FormScale * 287
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor     = "Black"
                Add_Click = {
                    if ($this.checked){
                        $EnumerationPortScanSpecificIPTextbox.enabled     = $false
                        $EnumerationPortScanIPRangeNetworkTextbox.enabled = $false
                        $EnumerationPortScanIPRangeFirstTextbox.enabled   = $false
                        $EnumerationPortScanIPRangeLastTextbox.enabled    = $false
                        $EnumerationPortScanSpecificIPTextbox.text     = ""
                        $EnumerationPortScanIPRangeNetworkTextbox.text = ""
                        $EnumerationPortScanIPRangeFirstTextbox.text   = ""
                        $EnumerationPortScanIPRangeLastTextbox.text    = ""
                    }
                    else {
                        $EnumerationPortScanSpecificIPTextbox.enabled     = $true
                        $EnumerationPortScanIPRangeNetworkTextbox.enabled = $true
                        $EnumerationPortScanIPRangeFirstTextbox.enabled   = $true
                        $EnumerationPortScanIPRangeLastTextbox.enabled    = $true
                    }
                }
            }
            $EnumerationPortScanGroupBox.Controls.Add($script:EnumerationPortScanSpecificComputerNodeCheckbox)


            $EnumerationPortScanIPNote1Label = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Enter Comma Separated IPs (ex: 10.0.0.1,10.0.0.2)"
                Left   = $script:EnumerationPortScanSpecificComputerNodeCheckbox.Left
                Top    = $script:EnumerationPortScanSpecificComputerNodeCheckbox.Top + $script:EnumerationPortScanSpecificComputerNodeCheckbox.Height
                Width  = $FormScale * 250
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor  = "Black"
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPNote1Label)


            $EnumerationPortScanSpecificIPTextbox = New-Object System.Windows.Forms.TextBox -Property @{
                Text   = ""
                Left   = $EnumerationPortScanIPNote1Label.Left
                Top    = $EnumerationPortScanIPNote1Label.Top + $EnumerationPortScanIPNote1Label.Height
                Width  = $FormScale * 287
                Height = $FormScale * 22
                MultiLine     = $False
                WordWrap      = $True
                AcceptsTab    = $false
                AcceptsReturn = $false
                Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor     = "Black"
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanSpecificIPTextbox)


            $EnumerationPortScanIPRangeNote1Label = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Network Range:  (ex: [ 192.168.1 ]  [ 1 ]  [ 100 ])"
                Left   = $EnumerationPortScanSpecificIPTextbox.Left
                Top    = $EnumerationPortScanSpecificIPTextbox.Top + $EnumerationPortScanSpecificIPTextbox.Height + ($FormScale + 5)
                Width  = $FormScale * 250
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor  = "Blue"
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPRangeNote1Label)


            $EnumerationPortScanIPRangeNetworkLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Network"
                Left   = $EnumerationPortScanIPRangeNote1Label.left
                Top    = $EnumerationPortScanIPRangeNote1Label.Top + $EnumerationPortScanIPRangeNote1Label.Height
                Width  = $FormScale * 80
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor = "Black"
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPRangeNetworkLabel)


            $EnumerationPortScanIPRangeNetworkTextbox = New-Object System.Windows.Forms.TextBox -Property @{
                Text   = ""
                Left   = $EnumerationPortScanIPRangeNetworkLabel.Left
                Top    = $EnumerationPortScanIPRangeNetworkLabel.Top + $EnumerationPortScanIPRangeNetworkLabel.Height
                Width  = $EnumerationPortScanIPRangeNetworkLabel.Width
                Height = $FormScale * 22
                MultiLine     = $False
                WordWrap      = $True
                AcceptsTab    = $false
                AcceptsReturn = $false
                Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor     = "Black"
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPRangeNetworkTextbox)


            $EnumerationPortScanIPRangeFirstLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "First IP"
                Left   = $EnumerationPortScanIPRangeNetworkTextbox.Left  + $EnumerationPortScanIPRangeNetworkTextbox.Width + $($FormScale * 20)
                Top    = $EnumerationPortScanIPRangeNetworkLabel.Top
                Width  = $EnumerationPortScanIPRangeNetworkLabel.Width
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor = "Black"
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPRangeFirstLabel)


            $EnumerationPortScanIPRangeFirstTextbox = New-Object System.Windows.Forms.TextBox -Property @{
                Text   = ""
                Left   = $EnumerationPortScanIPRangeFirstLabel.Left
                Top    = $EnumerationPortScanIPRangeFirstLabel.Top + $EnumerationPortScanIPRangeFirstLabel.Height
                Width  = $EnumerationPortScanIPRangeFirstLabel.Width
                Height = $FormScale * 22
                MultiLine     = $False
                WordWrap      = $True
                AcceptsTab    = $false
                AcceptsReturn = $false
                Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor     = "Black"
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPRangeFirstTextbox)


            $EnumerationPortScanIPRangeLastLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Last IP"
                Left   = $EnumerationPortScanIPRangeFirstLabel.Left + $EnumerationPortScanIPRangeFirstLabel.Width + $($FormScale * 20)
                Top    = $EnumerationPortScanIPRangeFirstLabel.Top
                Width  = $EnumerationPortScanIPRangeNetworkLabel.Size.Width
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor = "Black"
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPRangeLastLabel)


            $EnumerationPortScanIPRangeLastTextbox = New-Object System.Windows.Forms.TextBox -Property @{
                Text   = ""
                Left   = $EnumerationPortScanIPRangeLastLabel.Left
                Top    = $EnumerationPortScanIPRangeLastLabel.Top + $EnumerationPortScanIPRangeLastLabel.Height
                Width  = $EnumerationPortScanIPRangeLastLabel.Size.Width
                Height = $FormScale * 20
                MultiLine     = $False
                WordWrap      = $True
                AcceptsTab    = $false
                AcceptsReturn = $false
                Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor     = "Black"
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanIPRangeLastTextbox)


            $EnumerationPortScanPortNote1Label = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Comma Separated Ports:  (ex: 22,80,135,445)"
                Left   = $EnumerationPortScanIPRangeNetworkLabel.Left
                Top    = $EnumerationPortScanIPRangeLastTextbox.Top + $EnumerationPortScanIPRangeLastTextbox.Height + $($FormScale * 5)
                Width  = $FormScale * 290
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor  = "Blue"
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortNote1Label)


            $EnumerationPortScanSpecificPortsTextbox = New-Object System.Windows.Forms.TextBox -Property @{
                Text   = ""
                Left   = $EnumerationPortScanPortNote1Label.Left
                Top    = $EnumerationPortScanPortNote1Label.Top + $EnumerationPortScanPortNote1Label.Height
                Width  = $FormScale * 288
                Height = $FormScale * 22
                MultiLine     = $False
                WordWrap      = $True
                AcceptsTab    = $false
                AcceptsReturn = $false
                Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor     = "Black"
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanSpecificPortsTextbox)


            . "$Dependencies\Code\System.Windows.Forms\ComboBox\EnumerationPortScanPortQuickPickComboBox.ps1"
            $EnumerationPortScanPortQuickPickComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
                Text   = "Quick-Pick Port Selection"
                Left   = $EnumerationPortScanSpecificPortsTextbox.Left
                Top    = $EnumerationPortScanSpecificPortsTextbox.Top + $EnumerationPortScanSpecificPortsTextbox.Height + $($FormScale * 10)
                Width  = $FormScale * 183
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor     = "Black"
                Add_Click = $EnumerationPortScanPortQuickPickComboBoxAdd_Click
            }
            $EnumerationPortScanPortQuickPickComboBox.Items.AddRange($EnumerationPortScanPortQuickPickComboBoxItemsAddRange)
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortQuickPickComboBox)


            . "$Dependencies\Code\System.Windows.Forms\Button\EnumerationPortScanPortsSelectionButton.ps1"
            $EnumerationPortScanPortsSelectionButton = New-Object System.Windows.Forms.Button -Property @{
                Text   = "Select Ports"
                Left   = $EnumerationPortScanPortQuickPickComboBox.Left + $EnumerationPortScanPortQuickPickComboBox.Width + $($FormScale * 4)
                Top    = $EnumerationPortScanPortQuickPickComboBox.Top
                Width  = $FormScale * 100
                Height = $FormScale * 20
                Add_Click = $EnumerationPortScanPortsSelectionButtonAdd_Click
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortsSelectionButton)
            CommonButtonSettings -Button $EnumerationPortScanPortsSelectionButton


            $EnumerationPortScanPortRangeNetworkLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Port Range"
                Left   = $EnumerationPortScanPortQuickPickComboBox.Left
                Top    = $EnumerationPortScanPortsSelectionButton.Top + $EnumerationPortScanPortsSelectionButton.Height + ($FormScale + 10)
                Width  = $FormScale * 83
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor = "Blue"
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortRangeNetworkLabel)


            $EnumerationPortScanPortRangeFirstLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "First Port"
                Left   = $EnumerationPortScanIPRangeFirstLabel.Left
                Top    = $EnumerationPortScanPortRangeNetworkLabel.Top
                Width  = $EnumerationPortScanIPRangeFirstLabel.Width
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor = "Black"
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortRangeFirstLabel)


            $EnumerationPortScanPortRangeFirstTextbox = New-Object System.Windows.Forms.TextBox -Property @{
                Text   = ""
                Left   = $EnumerationPortScanPortRangeFirstLabel.Left
                Top    = $EnumerationPortScanPortRangeFirstLabel.Top + $EnumerationPortScanPortRangeFirstLabel.Height
                Width  = $EnumerationPortScanPortRangeFirstLabel.Width
                Height = $FormScale * 22
                MultiLine     = $False
                WordWrap      = $True
                AcceptsTab    = $false # Allows you to enter in tabs into the textbox
                AcceptsReturn = $false # Allows you to enter in returnss into the textbox
                Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor     = "Black"
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortRangeFirstTextbox)


            $EnumerationPortScanPortRangeLastLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Last Port"
                Left   = $EnumerationPortScanIPRangeLastLabel.Left
                Top    = $EnumerationPortScanPortRangeFirstLabel.Top
                Width  = $EnumerationPortScanPortRangeFirstTextbox.Width
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor = "Black"
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortRangeLastLabel)


            $EnumerationPortScanPortRangeLastTextbox = New-Object System.Windows.Forms.TextBox -Property @{
                Text   = ""
                Left   = $EnumerationPortScanPortRangeLastLabel.Left
                Top    = $EnumerationPortScanPortRangeLastLabel.Top + $EnumerationPortScanPortRangeLastLabel.Height
                Width  = $EnumerationPortScanPortRangeLastLabel.Width
                Height = $FormScale * 22
                MultiLine     = $False
                WordWrap      = $True
                AcceptsTab    = $false # Allows you to enter in tabs into the textbox
                AcceptsReturn = $false # Allows you to enter in returnss into the textbox
                Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor     = "Black"
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanPortRangeLastTextbox)


            $EnumerationPortScanTestICMPFirstCheckBox = New-Object System.Windows.Forms.CheckBox -Property @{
                Text   = "Ping First"
                Left   = $EnumerationPortScanPortRangeNetworkLabel.Left
                Top    = $EnumerationPortScanPortRangeLastTextbox.Top + $EnumerationPortScanPortRangeLastTextbox.Height + ($FormScale * 5)
                Width  = $EnumerationPortScanIPRangeNetworkLabel.Size.Width
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor = "Black"
                Checked   = $False
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanTestICMPFirstCheckBox)


            $EnumerationPortScanTimeoutLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Timeout (ms)"
                Left   = $EnumerationPortScanPortRangeFirstLabel.Left
                Top    = $EnumerationPortScanTestICMPFirstCheckBox.Top
                Width  = $EnumerationPortScanIPRangeNetworkTextbox.Width
                Height = $FormScale * 20
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor = "Black"
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanTimeoutLabel)


            $EnumerationPortScanTimeoutTextbox = New-Object System.Windows.Forms.TextBox -Property @{
                Text   = 50
                Left   = $EnumerationPortScanTimeoutLabel.Left
                Top    = $EnumerationPortScanTimeoutLabel.Top + $EnumerationPortScanTimeoutLabel.Height
                Width  = $EnumerationPortScanIPRangeNetworkTextbox.Width
                Height = $FormScale * 22
                MultiLine     = $False
                WordWrap      = $True
                AcceptsTab    = $false
                AcceptsReturn = $false
                Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor     = "Black"
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanTimeoutTextbox)


            . "$Dependencies\Code\System.Windows.Forms\Button\EnumerationPortScanExecutionButton.ps1"
            $EnumerationPortScanExecutionButton = New-Object System.Windows.Forms.Button -Property @{
                Text   = "Execute Scan"
                Left   = $FormScale * 190
                Top    = $EnumerationPortScanTimeoutTextbox.Top
                Width  = $FormScale * 100
                Height = $FormScale * 22
                Add_Click = $EnumerationPortScanExecutionButtonAdd_Click
                Add_MouseHover = {
Show-ToolTip -Title "Execute Scan" -Icon "Info" -Message @"
+  Reference Port Check:
     New-Object System.Net.Sockets.TcpClient("<Hostname/IP>", 139)
"@
                }
            }
            $EnumerationPortScanGroupBox.Controls.Add($EnumerationPortScanExecutionButton)
            CommonButtonSettings -Button $EnumerationPortScanExecutionButton

$Section1EnumerationTab.Controls.Add($EnumerationPortScanGroupBox)


# Using the inputs selected or provided from the GUI, it conducts a basic ping sweep
# The results can be added to the computer treenodes
# Lists all IPs in a subnet
. "$Dependencies\Code\Main Body\Get-SubnetRange.ps1"

. "$Dependencies\Code\Execution\Enumeration\Conduct-PingSweep.ps1"


# Create a group that will contain your radio buttons
$EnumerationPingSweepGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text   = "Create List From Ping Sweep"
    Left   = 0
    Top    = $EnumerationPortScanGroupBox.Top + $EnumerationPortScanGroupBox.Height + $($FormScale * $EnumerationGroupGap)
    Width  = $FormScale * 294
    Height = $FormScale * 70
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
}
            $EnumerationPingSweepNote1Label = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Enter Network/CIDR: (ex: 10.0.0.0/24)"
                Left   = $FormScale * 3
                Top    = $FormScale * 20
                Width  = $FormScale * 180
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor  = "Black"
            }
            $EnumerationPingSweepGroupBox.Controls.Add($EnumerationPingSweepNote1Label)


            . "$Dependencies\Code\System.Windows.Forms\TextBox\EnumerationPingSweepIPNetworkCIDRTextbox.ps1"
            $EnumerationPingSweepIPNetworkCIDRTextbox = New-Object System.Windows.Forms.TextBox -Property @{
                Text   = ""
                Left   = $FormScale * 190
                Top    = $EnumerationPingSweepNote1Label.Top
                Width  = $FormScale * 100
                Height = $FormScale * $EnumerationLabelHeight
                MultiLine     = $False
                WordWrap      = $True
                AcceptsTab    = $false
                AcceptsReturn = $false
                Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                ForeColor     = "Black"
                Add_KeyDown   = $EnumerationPingSweepIPNetworkCIDRTextboxAdd_KeyDown
            }
            $EnumerationPingSweepGroupBox.Controls.Add($EnumerationPingSweepIPNetworkCIDRTextbox)


            . "$Dependencies\Code\System.Windows.Forms\Button\EnumerationPingSweepExecutionButton.ps1"
            $EnumerationPingSweepExecutionButton = New-Object System.Windows.Forms.Button -Property @{
                Text   = "Execute Sweep"
                Left   = $EnumerationPingSweepIPNetworkCIDRTextbox.Left
                Top    = $EnumerationPingSweepIPNetworkCIDRTextbox.Top + $EnumerationPingSweepIPNetworkCIDRTextbox.Height + ($FormScale * 8)
                Width  = $FormScale * 100
                Height = $FormScale * 22
                Add_Click = $EnumerationPingSweepExecutionButtonAdd_Click
            }
            $EnumerationPingSweepGroupBox.Controls.Add($EnumerationPingSweepExecutionButton)
            CommonButtonSettings -Button $EnumerationPingSweepExecutionButton
$Section1EnumerationTab.Controls.Add($EnumerationPingSweepGroupBox)


. "$Dependencies\Code\System.Windows.Forms\Button\EnumerationResolveDNSNameButton.ps1"
$EnumerationResolveDNSNameButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "DNS Resolution"
    Left   = $EnumerationPortScanGroupBox.Left + $EnumerationPortScanGroupBox.Width + ($FormScale + 15)
    Top    = $EnumerationPortScanGroupBox.Top + ($FormScale + 13)
    Width  = $FormScale * 152
    Height = $FormScale * 22
    Add_Click = $EnumerationResolveDNSNameButtonAdd_Click
}
$Section1EnumerationTab.Controls.Add($EnumerationResolveDNSNameButton)
CommonButtonSettings -Button $EnumerationResolveDNSNameButton


$EnumerationComputerListBox = New-Object System.Windows.Forms.ListBox -Property @{
    Left   = $EnumerationResolveDNSNameButton.Left
    Top    = $EnumerationResolveDNSNameButton.Top + $EnumerationResolveDNSNameButton.Height + ($FormScale + 10)
    Width  = $FormScale * 152
    Height = $EnumerationResolveDNSNameButton.Size.Height + $( $FormScale * 410)
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    SelectionMode = 'MultiExtended'
}
$EnumerationComputerListBox.Items.Add("127.0.0.1")
$Section1EnumerationTab.Controls.Add($EnumerationComputerListBox)


. "$Dependencies\Code\System.Windows.Forms\Button\EnumerationComputerListBoxAddToListButton.ps1"
$EnumerationComputerListBoxAddToListButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Add To Computer List"
    Left   = $EnumerationResolveDNSNameButton.Left
    Top    = $EnumerationComputerListBox.Top + $EnumerationComputerListBox.Height + ($FormScale + 5)
    Width  = $EnumerationResolveDNSNameButton.Width
    Height = $FormScale * 22
    Add_Click = $EnumerationComputerListBoxAddToListButtonAdd_Click
}
$Section1EnumerationTab.Controls.Add($EnumerationComputerListBoxAddToListButton)
CommonButtonSettings -Button $EnumerationComputerListBoxAddToListButton


. "$Dependencies\Code\System.Windows.Forms\Button\EnumerationComputerListBoxSelectAllButton.ps1"
$EnumerationComputerListBoxSelectAllButton = New-Object System.Windows.Forms.Button -Property @{
    Left   = $EnumerationComputerListBoxAddToListButton.Left
    Top    = $EnumerationComputerListBoxAddToListButton.Top + $EnumerationComputerListBoxAddToListButton.Height + ($FormScale + 10)
    Width  = $EnumerationResolveDNSNameButton.Width
    Height = $FormScale * 22
    Text   = "Select All"
    Add_Click = $EnumerationComputerListBoxSelectAllButtonAdd_Click
}
$Section1EnumerationTab.Controls.Add($EnumerationComputerListBoxSelectAllButton)
CommonButtonSettings -Button $EnumerationComputerListBoxSelectAllButton


. "$Dependencies\Code\System.Windows.Forms\Button\EnumerationComputerListBoxClearButton.ps1"
$EnumerationComputerListBoxClearButton = New-Object System.Windows.Forms.Button -Property @{
    Left   = $EnumerationComputerListBoxSelectAllButton.Left
    Top    = $EnumerationComputerListBoxSelectAllButton.Top + $EnumerationComputerListBoxSelectAllButton.Height + ($FormScale + 10)
    Width  = $EnumerationResolveDNSNameButton.Width
    Height = $FormScale * 22
    Text   = 'Clear List'
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
$script:ProgressBarFormProgressBar.Value += 1
$script:ProgressBarSelectionForm.Refresh()

$MainLeftChecklistTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text                    = "Checklist"
    Name                    = "Checklist Tab"
    Font                    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
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
$script:ProgressBarFormProgressBar.Value += 1
$script:ProgressBarSelectionForm.Refresh()

$MainLeftChecklistTabControl = New-Object System.Windows.Forms.TabControl -Property @{
    Name          = "Checklist TabControl"
    Location  = @{ X = $FormScale * $TabRightPosition
                   Y = $FormScale * $TabhDownPosition }
    Size      = @{ Width  = $FormScale * $TabAreaWidth
                   Height = $FormScale * $TabAreaHeight }
    Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ShowToolTips  = $True
    SelectedIndex = 0
}
$MainLeftChecklistTab.Controls.Add($MainLeftChecklistTabControl)


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
$script:ProgressBarFormProgressBar.Value += 1
$script:ProgressBarSelectionForm.Refresh()

$Section1ProcessesTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text                    = "Processes"
    Name                    = "Processes Tab"
    UseVisualStyleBackColor = $True
    Font                    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
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
$script:ProgressBarFormProgressBar.Value += 1
$script:ProgressBarSelectionForm.Refresh()

$MainLeftProcessesTabControl = New-Object System.Windows.Forms.TabControl -Property @{
    Name     = "Processes TabControl"
    Location = @{ X = $FormScale * $TabRightPosition
                  Y = $FormScale * $TabhDownPosition }
    Size     = @{ Width  = $FormScale * $TabAreaWidth
                  Height = $FormScale * $TabAreaHeight }
    Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
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
    $script:ProgressBarFormProgressBar.Value += 1
    $script:ProgressBarSelectionForm.Refresh()

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
$script:ProgressBarFormProgressBar.Value += 1
$script:ProgressBarSelectionForm.Refresh()

$Section1OpNotesTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text                    = "OpNotes"
    Name                    = "OpNotes Tab"
    UseVisualStyleBackColor = $True
    Font                    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
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


$OpNotesLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = "Enter Your Operator Notes (OpNotes) - Auto-Timestamp:"
    Location = @{ X = $FormScale * $OpNotesRightPosition
                  Y = $FormScale * $OpNotesDownPosition }
    Size     = @{ Width  = $FormScale * $OpNotesInputTextBoxWidth
                  Height = $FormScale * $OpNotesInputTextBoxHeight }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 13),1,2,1)
    ForeColor = "Blue"
}
$Section1OpNotesTab.Controls.Add($OpNotesLabel)

$OpNotesDownPosition += $OpNotesDownPositionShift + $($FormScale + 5)


. "$Dependencies\Code\System.Windows.Forms\TextBox\OpNotesInputTextBox.ps1"
$OpNotesInputTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $FormScale * $OpNotesRightPosition
                  Y = $FormScale * $OpNotesDownPosition }
    Size     = @{ Width  = $FormScale * $OpNotesInputTextBoxWidth
                  Height = $FormScale * $OpNotesInputTextBoxHeight }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_KeyDown = $OpNotesInputTextBoxAdd_KeyDown
}
$Section1OpNotesTab.Controls.Add($OpNotesInputTextBox)

$OpNotesDownPosition += $OpNotesDownPositionShift + $($FormScale + 5)


. "$Dependencies\Code\System.Windows.Forms\Button\OpNotesAddButton.ps1"
$OpNotesAddButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Add"
    Location = @{ X = $FormScale * $OpNotesRightPosition
                  Y = $FormScale * $OpNotesDownPosition }
    Size     = @{ Width  = $FormScale * $OpNotesButtonWidth
                  Height = $FormScale * $OpNotesButtonHeight }
    Add_Click = $OpNotesAddButtonAdd_Click
}
$Section1OpNotesTab.Controls.Add($OpNotesAddButton)
CommonButtonSettings -Button $OpNotesAddButton

$OpNotesRightPosition += $OpNotesRightPositionShift


. "$Dependencies\Code\System.Windows.Forms\Button\OpNotesSelectAllButton.ps1"
$OpNotesSelectAllButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Select All"
    Location = @{ X = $FormScale * $OpNotesRightPosition
                  Y = $FormScale * $OpNotesDownPosition }
    Size     = @{ Width  = $FormScale * $OpNotesButtonWidth
                  Height = $FormScale * $OpNotesButtonHeight }
    Add_Click = $OpNotesSelectAllButtonAdd_Click
}
$Section1OpNotesTab.Controls.Add($OpNotesSelectAllButton)
CommonButtonSettings -Button $OpNotesSelectAllButton

$OpNotesRightPosition += $OpNotesRightPositionShift


. "$Dependencies\Code\System.Windows.Forms\Button\OpNotesOpenOpNotesButton.ps1"
$OpNotesOpenOpNotesButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Open OpNotes"
    Location = @{ X = $FormScale * $OpNotesRightPosition
                  Y = $FormScale * $OpNotesDownPosition }
    Size     = @{ Width  = $FormScale * $OpNotesButtonWidth
                  Height = $FormScale * $OpNotesButtonHeight }
    Add_Click = $OpNotesOpenOpNotesButtonAdd_Click
}
$Section1OpNotesTab.Controls.Add($OpNotesOpenOpNotesButton)
CommonButtonSettings -Button $OpNotesOpenOpNotesButton

$OpNotesRightPosition += $OpNotesRightPositionShift


. "$Dependencies\Code\System.Windows.Forms\Button\OpNotesMoveUpButton.ps1"
$OpNotesMoveUpButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = 'Move Up'
    Location = @{ X = $FormScale * $OpNotesRightPosition
                  Y = $FormScale * $OpNotesDownPosition }
    Size     = @{ Width  = $FormScale * $OpNotesButtonWidth
                  Height = $FormScale * $OpNotesButtonHeight }
    Add_Click = $OpNotesMoveUpButtonAdd_Click
}
$Section1OpNotesTab.Controls.Add($OpNotesMoveUpButton)
CommonButtonSettings -Button $OpNotesMoveUpButton

$OpNotesDownPosition += $OpNotesDownPositionShift + $($FormScale + 5)
$OpNotesRightPosition = $OpNotesRightPositionStart


. "$Dependencies\Code\System.Windows.Forms\Button\OpNotesRemoveButton.ps1"
$OpNotesRemoveButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = 'Remove'
            Location = @{ X = $FormScale * $OpNotesRightPosition
                      Y = $FormScale * $OpNotesDownPosition }
        Size     = @{ Width  = $FormScale * $OpNotesButtonWidth
                      Height = $FormScale * $OpNotesButtonHeight }
    Add_Click = $OpNotesRemoveButtonAdd_Click
}
$Section1OpNotesTab.Controls.Add($OpNotesRemoveButton)
CommonButtonSettings -Button $OpNotesRemoveButton

$OpNotesRightPosition += $OpNotesRightPositionShift


. "$Dependencies\Code\System.Windows.Forms\Button\OpNotesCreateReportButton.ps1"
$OpNotesCreateReportButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Create Report"
    Location = @{ X = $FormScale * $OpNotesRightPosition
                  Y = $FormScale * $OpNotesDownPosition }
    Size     = @{ Width  = $FormScale * $OpNotesButtonWidth
                  Height = $FormScale * $OpNotesButtonHeight }
    Add_Click = $OpNotesCreateReportButtonAdd_Click
}
$Section1OpNotesTab.Controls.Add($OpNotesCreateReportButton)
CommonButtonSettings -Button $OpNotesCreateReportButton

$OpNotesRightPosition += $OpNotesRightPositionShift


$OpNotesOpenReportsButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Open Reports"
        Location = @{ X = $FormScale * $OpNotesRightPosition
                      Y = $FormScale * $OpNotesDownPosition }
        Size     = @{ Width  = $FormScale * $OpNotesButtonWidth
                      Height = $FormScale * $OpNotesButtonHeight }
    Add_Click = { Invoke-Item -Path "$PoShHome\Reports" }
}
$Section1OpNotesTab.Controls.Add($OpNotesOpenReportsButton)
CommonButtonSettings -Button $OpNotesOpenReportsButton

$OpNotesRightPosition += $OpNotesRightPositionShift


. "$Dependencies\Code\System.Windows.Forms\Button\OpNotesMoveDownButton.ps1"
$OpNotesMoveDownButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = 'Move Down'
    Location = @{ X = $FormScale * $OpNotesRightPosition
                  Y = $FormScale * $OpNotesDownPosition }
    Size     = @{ Width  = $FormScale * $OpNotesButtonWidth
                  Height = $FormScale * $OpNotesButtonHeight }
    Add_Click = $OpNotesMoveDownButtonAdd_Click
}
$Section1OpNotesTab.Controls.Add($OpNotesMoveDownButton)
CommonButtonSettings -Button $OpNotesMoveDownButton

$OpNotesDownPosition += $OpNotesDownPositionShift + $($FormScale + 5)


. "$Dependencies\Code\System.Windows.Forms\ListBox\OpNotesListBox.ps1"
$OpNotesListBox = New-Object System.Windows.Forms.ListBox -Property @{
    Name     = "OpNotesListBox"
    Location = @{ X = $FormScale * $OpNotesRightPositionStart
                  Y = $FormScale * $OpNotesDownPosition + 5 }
    Size     = @{ Width  = $FormScale * $OpNotesMainTextBoxWidth
                  Height = $FormScale * $OpNotesMainTextBoxHeight }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
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
$script:ProgressBarFormProgressBar.Value += 1
$script:ProgressBarSelectionForm.Refresh()

$MainLeftInfoTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text                    = "Info"
    Font                    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
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
$script:ProgressBarFormProgressBar.Value += 1
$script:ProgressBarSelectionForm.Refresh()

$MainLeftInfoTabControl = New-Object System.Windows.Forms.TabControl -Property @{
    Location = @{ X = $FormScale * $TabRightPosition
                  Y = $FormScale * $TabhDownPosition }
    Size     = @{ Width  = $FormScale * $TabAreaWidth
                  Height = $FormScale * $TabAreaHeight }
    Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ShowToolTips  = $True
    SelectedIndex = 0
}
$MainLeftInfoTab.Controls.Add($MainLeftInfoTabControl)


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
    $script:ProgressBarFormProgressBar.Value += 1
    $script:ProgressBarSelectionForm.Refresh()

    $Section1AboutSubTab = New-Object System.Windows.Forms.TabPage -Property @{
        Text                    = $File.BaseName
        UseVisualStyleBackColor = $True
        Font                    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $MainLeftInfoTabControl.Controls.Add($Section1AboutSubTab)


    $TabContents = Get-Content -Path $File.FullName -Force | ForEach-Object {$_ + "`r`n"}
    $Section1AboutSubTabTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Text       = "$TabContents"
        Name       = "$file"
        Location = @{ X = $FormScale * $TextBoxRightPosition
                      Y = $FormScale * $TextBoxDownPosition }
        Size     = @{ Width  = $FormScale * $TextBoxWidth
                      Height = $FormScale * $TextBoxHeight }
        MultiLine  = $True
        ScrollBars = "Vertical"
        Font       = New-Object System.Drawing.Font("Courier New",$($FormScale * 9),0,0,0)
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
$script:ProgressBarFormProgressBar.Value += 1
$script:ProgressBarSelectionForm.Refresh()

. "$Dependencies\Code\System.Windows.Forms\TabControl\Section2TabControl.ps1"
$MainCenterTabControl = New-Object System.Windows.Forms.TabControl -Property @{
    Name          = "Main Tab Window"
    Location      = @{ X = $FormScale * 470
                       Y = $FormScale * 5 }
    Size          = @{ Width  = $FormScale *  370
                       Height = $FormScale * 278 }
    SelectedIndex = 0
    ShowToolTips  = $True
    Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
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
$script:ProgressBarFormProgressBar.Value += 1
$script:ProgressBarSelectionForm.Refresh()

$MainCenterMainTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text                    = "Main"
    Name                    = "Main"
    UseVisualStyleBackColor = $True
    Font                    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$MainCenterTabControl.Controls.Add($MainCenterMainTab)

$Column3RightPosition     = 3
$Column3DownPosition      = 11
$Column3BoxHeight         = 22
$Column3DownPositionShift = 26

$DefaultSingleHostIPText = "<Type In A Hostname / IP>"


# This checkbox highlights when selecting computers from the ComputerList
. "$Dependencies\Code\System.Windows.Forms\Checkbox\SingleHostIPCheckBox.ps1"
$script:SingleHostIPCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
    Text      = "Query A Single Endpoint:"
    Location  = @{ X = $FormScale * 3
                   Y = $FormScale * 11 }
    Size      = @{ Width  = $FormScale * 210
                   Height = $FormScale * $Column3BoxHeight }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
    Forecolor = 'Blue'
    Enabled   = $true
    Add_Click      = $SingleHostIPCheckBoxAdd_Click
    Add_MouseHover = $SingleHostIPCheckBoxAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($script:SingleHostIPCheckBox)

$Column3DownPosition += $Column3DownPositionShift


. "$Dependencies\Code\System.Windows.Forms\TextBox\SingleHostIPTextBox.ps1"
$script:SingleHostIPTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Text     = $DefaultSingleHostIPText
    Location = @{ X = $FormScale * $Column3RightPosition
                  Y = $FormScale * $Column3DownPosition + 1 }
    Size     = @{ Width  = $FormScale * 235
                  Height = $FormScale * $Column3BoxHeight }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_KeyDown    = $SingleHostIPTextBoxAdd_KeyDown
    Add_MouseHover = $SingleHostIPTextBoxAdd_MouseHover
    Add_MouseEnter = $SingleHostIPTextBoxAdd_MouseEnter
    Add_MouseLeave = $SingleHostIPTextBoxAdd_MouseLeave
}
$MainCenterMainTab.Controls.Add($script:SingleHostIPTextBox)


. "$Dependencies\Code\System.Windows.Forms\Button\SingleHostIPAddButton.ps1"
$SingleHostIPAddButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Add To List"
    Location = @{ X = $FormScale * ($Column3RightPosition + 240)
                  Y = $FormScale * $Column3DownPosition }
    Size     = @{ Width  = $FormScale * 115
                  Height = $FormScale * $Column3BoxHeight }
    Add_Click      = $SingleHostIPAddButtonAdd_Click
    Add_MouseHover = $SingleHostIPAddButtonAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($SingleHostIPAddButton)
CommonButtonSettings -Button $SingleHostIPAddButton

$Column3DownPosition += $Column3DownPositionShift
$Column3DownPosition += $Column3DownPositionShift - 3


$DirectoryListLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = "Results Folder:"
    Location  = @{ X = $FormScale * $Column3RightPosition
                   Y = $SingleHostIPAddButton.Location.Y + $SingleHostIPAddButton.Size.Height + $($FormScale * 30) }
    Size      = @{ Width  = $FormScale * 120
                   Height = $FormScale * 22 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
    ForeColor = "Blue"
}
$MainCenterMainTab.Controls.Add($DirectoryListLabel)


# This shows the name of the directy that data will be currently saved to
. "$Dependencies\Code\System.Windows.Forms\TextBox\CollectionSavedDirectoryTextBox.ps1"
$script:CollectionSavedDirectoryTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Name     = "Saved Directory List Box"
    Text    = $SaveDirectory
    Location = @{ X = $FormScale * $Column3RightPosition
                  Y = $DirectoryListLabel.Location.Y + $DirectoryListLabel.Size.Height }
    Size     = @{ Width  = $FormScale * 354
                  Height = $FormScale * 22 }
    WordWrap = $false
    AcceptsTab = $true
    TabStop    = $true
    Multiline  = $false
    AutoSize   = $false
    Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "FileSystem"
    AutoCompleteMode   = "SuggestAppend"
    Add_MouseHover     = $CollectionSavedDirectoryTextBoxAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($script:CollectionSavedDirectoryTextBox)


. "$Dependencies\Code\System.Windows.Forms\Button\DirectoryOpenButton.ps1"
$DirectoryOpenButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Open Folder"
    Location = @{ X = $FormScale * ($Column3RightPosition + 120)
                  Y = $script:CollectionSavedDirectoryTextBox.Location.Y + $script:CollectionSavedDirectoryTextBox.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 115
                  Height = $FormScale * $Column3BoxHeight }
    Add_Click      = $DirectoryOpenButtonAdd_Click
    Add_MouseHover = $DirectoryOpenButtonAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($DirectoryOpenButton)
CommonButtonSettings -Button $DirectoryOpenButton


. "$Dependencies\Code\System.Windows.Forms\Button\DirectoryUpdateButton.ps1"
$DirectoryUpdateButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "New Timestamp"
    Location = @{ X = $DirectoryOpenButton.Location.X + $DirectoryOpenButton.Size.Width + $($FormScale * 5)
                  Y = $DirectoryOpenButton.Location.Y }
    Size     = @{ Width  = $FormScale * 115
                  Height = $FormScale * $Column3BoxHeight }
    Add_Click      = $DirectoryUpdateButtonAdd_Click
    Add_MouseHover = $DirectoryUpdateButtonAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($DirectoryUpdateButton)
CommonButtonSettings -Button $DirectoryUpdateButton


$ResultsSectionLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = "Analyst Options:"
    Location  = @{ X = $FormScale * 2
                   Y = $DirectoryUpdateButton.Location.Y + $DirectoryUpdateButton.Size.Height + $($FormScale * 15) }
    Size      = @{ Width  = $FormScale * 230
                   Height = $FormScale * $Column3BoxHeight }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
    ForeColor = "Blue"
}
$MainCenterMainTab.Controls.Add($ResultsSectionLabel)


. "$Dependencies\Code\System.Windows.Forms\Button\PSWriteHTMLButton.ps1"
$PSWriteHTMLButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Graph Data (BETA)"
    Location = @{ X = $ResultsSectionLabel.Location.X
                  Y = $ResultsSectionLabel.Location.Y + $ResultsSectionLabel.Size.Height }
    Size     = @{ Width  = $FormScale * 115
                  Height = $FormScale * 22 }
    Add_Click      = $PSWriteHTMLButtonAdd_Click
    Add_MouseHover = $PSWriteHTMLButtonAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($PSWriteHTMLButton)
CommonButtonSettings -Button $PSWriteHTMLButton
#if ((Get-Content "$PoShHome\Settings\PSWriteHTML Module Install.txt") -match 'No') { $PSWriteHTMLButton.enabled = $false }


. "$Dependencies\Code\Charts\Generate-AutoChartsCommand.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\AutoCreateMultiSeriesChartButton.ps1"
$AutoCreateMultiSeriesChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Multi-Series Charts"
    Location = @{ X = $PSWriteHTMLButton.Location.X + $PSWriteHTMLButton.Size.Width + $($FormScale * 5)
                  Y = $PSWriteHTMLButton.Location.Y }
    Size     = @{ Width  = $FormScale * 115
                  Height = $FormScale * 22 }
    Add_Click = $AutoCreateMultiSeriesChartButtonAdd_Click
    Add_MouseHover = $AutoCreateMultiSeriesChartButtonAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($AutoCreateMultiSeriesChartButton)
CommonButtonSettings -Button $AutoCreateMultiSeriesChartButton


# This is placed here as the code is used with the "Open Data In Shell" button in the main form as well as within the dashboards
. "$Dependencies\Code\Main Body\Open-XmlResultsInShell.ps1"

# Code to allow the dashboards to update upon request
. "$Dependencies\Code\Charts\Update-AutoChartsActiveDirectoryComputers.ps1"
. "$Dependencies\Code\Charts\Update-AutoChartsActiveDirectoryGroups.ps1"
. "$Dependencies\Code\Charts\Update-AutoChartsActiveDirectoryUserAccounts.ps1"
. "$Dependencies\Code\Charts\Update-AutoChartsApplicationCrashes.ps1"
. "$Dependencies\Code\Charts\Update-AutoChartsDeepBlueAll.ps1"
. "$Dependencies\Code\Charts\Update-AutoChartsDeepBlue7Days.ps1"
. "$Dependencies\Code\Charts\Update-AutoChartsDeepBlue24Hours.ps1"
. "$Dependencies\Code\Charts\Update-AutoChartsLoginActivity.ps1"
. "$Dependencies\Code\Charts\Update-AutoChartsNetworkConnections.ps1"
. "$Dependencies\Code\Charts\Update-AutoChartsNetworkInterfaces.ps1"
. "$Dependencies\Code\Charts\Update-AutoChartsProcesses.ps1"
. "$Dependencies\Code\Charts\Update-AutoChartsSecurityPatches.ps1"
. "$Dependencies\Code\Charts\Update-AutoChartsServices.ps1"
. "$Dependencies\Code\Charts\Update-AutoChartsSoftware.ps1"
. "$Dependencies\Code\Charts\Update-AutoChartsSmbShare.ps1"
. "$Dependencies\Code\Charts\Update-AutoChartsStartupCommands.ps1"

# Used to populate the dashboard choices form
. "$Dependencies\Code\System.Windows.Forms\Button\AutoCreateDashboardChartButton.ps1"
$AutoCreateDashboardChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Dashboard Charts"
    Location = @{ X = $AutoCreateMultiSeriesChartButton.Location.X + $AutoCreateMultiSeriesChartButton.Size.Width + $($FormScale * 5)
                  Y = $AutoCreateMultiSeriesChartButton.Location.Y }
    Size     = @{ Width  = $FormScale * 115
                  Height = $FormScale * 22 }
    Add_Click      = $AutoCreateDashboardChartButtonAdd_Click
    Add_MouseHover = $AutoCreateDashboardChartButtonAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($AutoCreateDashboardChartButton)
CommonButtonSettings -Button $AutoCreateDashboardChartButton


. "$Dependencies\Code\System.Windows.Forms\Button\RetrieveFilesButton.ps1"
$RetrieveFilesButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Retrieve Files"
    Location = @{ X = $PSWriteHTMLButton.Location.X
                  Y = $AutoCreateMultiSeriesChartButton.Location.Y + $AutoCreateMultiSeriesChartButton.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 115
                  Height = $FormScale * 22 }
    Add_Click      = $RetrieveFilesButtonAdd_Click
    Add_MouseHover = $RetrieveFilesButtonAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($RetrieveFilesButton)
CommonButtonSettings -Button $RetrieveFilesButton


. "$Dependencies\Code\System.Windows.Forms\Button\OpenXmlResultsButton.ps1"
$OpenXmlResultsButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Open Data In Shell"
    Location = @{ X = $AutoCreateMultiSeriesChartButton.Location.X
                  Y = $AutoCreateMultiSeriesChartButton.Location.Y + $AutoCreateMultiSeriesChartButton.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 115
                  Height = $FormScale * 22 }
    Add_Click      = $OpenXmlResultsButtonAdd_Click
    Add_MouseHover = $OpenXmlResultsButtonAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($OpenXmlResultsButton)
CommonButtonSettings -Button $OpenXmlResultsButton


. "$Dependencies\Code\System.Windows.Forms\Button\OpenCsvResultsButton.ps1"
$OpenCsvResultsButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "View CSV Results"
    Location = @{ X = $AutoCreateDashboardChartButton.Location.X
                  Y = $AutoCreateDashboardChartButton.Location.Y + $AutoCreateDashboardChartButton.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 115
                  Height = $FormScale * 22 }
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
$script:ProgressBarFormProgressBar.Value += 1
$script:ProgressBarSelectionForm.Refresh()

$Section2OptionsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text = "Options"
    Name = "Options"
    Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
}
$MainCenterTabControl.Controls.Add($Section2OptionsTab)


$OptionTextToSpeachButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Resize PoSh-EasyWin"
    Location = @{ X = $FormScale * 3
                  Y = $FormScale * 3 }
    Width  = $FormScale * 175
    Height = $FormScale * $Column3BoxHeight
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click = {
        Launch-FormScaleGUI -Relaunch
        If ($script:RelaunchEasyWin){
            $PoSHEasyWin.Close()
            Start-Process PowerShell.exe -Verb runAs -ArgumentList $ThisScript
        }
    }
}
# Cmdlet Parameter Option
if ($AudibleCompletionMessage) {$OptionTextToSpeachCheckBox.Checked = $True}
$Section2OptionsTab.Controls.Add($OptionTextToSpeachButton)
CommonButtonSettings -Button $OptionTextToSpeachButton


$OptionViewReadMeButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "View Read Me"
    Left   = $OptionTextToSpeachButton.Left + $OptionTextToSpeachButton.Width + ($FormScale * 5)
    Top    = $OptionTextToSpeachButton.Top
    Width  = $FormScale * 175
    Height = $FormScale * $Column3BoxHeight
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click = {
        Launch-ReadMe -ReadMe
    }
}
$Section2OptionsTab.Controls.Add($OptionViewReadMeButton)
CommonButtonSettings -Button $OptionViewReadMeButton


$OptionSearchComputersForPreviouslyCollectedDataProcessesGroupBox = New-Object System.Windows.Forms.Groupbox -Property @{
    Text     = "Search Endpoints for Previously Collected Data"
    Top      = $OptionTextToSpeachButton.Top + $OptionTextToSpeachButton.Height + $($FormScale * 5)
    Left     = $FormScale * 3 
    Size     = @{ Width  = $FormScale * 352
                  Height = $FormScale * 100 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
}
            . "$Dependencies\Code\System.Windows.Forms\ComboBox\CollectedDataDirectorySearchLimitComboBox.ps1"
            $CollectedDataDirectorySearchLimitComboBox = New-Object System.Windows.Forms.Combobox -Property @{
                Text     = 50
                Location = @{ X = $FormScale * 10
                            Y = $FormScale * 15 }
                Size     = @{ Width  = $FormScale * 50
                            Height = $FormScale * 22 }
                Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                Add_MouseHover = $CollectedDataDirectorySearchLimitComboBoxAdd_MouseHover
                Add_SelectedIndexChanged = { $This.Text | Set-Content "$PoShHome\Settings\Directory Search Limit.txt" -Force }
            }
            $NumberOfDirectoriesToSearchBack = @(25,50,100,150,200,250,500,750,1000)
            ForEach ($Item in $NumberOfDirectoriesToSearchBack) { $CollectedDataDirectorySearchLimitComboBox.Items.Add($Item) }
            if (Test-Path "$PoShHome\Settings\Directory Search Limit.txt") { $CollectedDataDirectorySearchLimitComboBox.text = Get-Content "$PoShHome\Settings\Directory Search Limit.txt" }
            $OptionSearchComputersForPreviouslyCollectedDataProcessesGroupBox.Controls.Add($CollectedDataDirectorySearchLimitCombobox)


            $CollectedDataDirectorySearchLimitLabel = New-Object System.Windows.Forms.Label -Property @{
                Text     = "Number of Past Directories to Search"
                Location = @{ X = $CollectedDataDirectorySearchLimitCombobox.Size.Width + $($FormScale * 10)
                            Y = $CollectedDataDirectorySearchLimitCombobox.Location.Y + $($FormScale + 3) }
                Size     = @{ Width  = $FormScale * 200
                            Height = $FormScale * 22 }
                Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            }
            $OptionSearchComputersForPreviouslyCollectedDataProcessesGroupBox.Controls.Add($CollectedDataDirectorySearchLimitLabel)


            $OptionSearchProcessesCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
                Text     = "Processes"
                Location = @{ X = $FormScale * 10
                            Y = $CollectedDataDirectorySearchLimitLabel.Location.Y + $CollectedDataDirectorySearchLimitLabel.Size.Height }
                Size     = @{ Width  = $FormScale * 200
                            Height = $FormScale * 20 }
                Enabled  = $true
                Checked  = $False
                Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                Add_Click = { $This.Checked | Set-Content "$PoShHome\Settings\Search - Processes Checkbox.txt" -Force }
            }
            if (Test-Path "$PoShHome\Settings\Search - Processes Checkbox.txt") { $OptionSearchProcessesCheckBox.Checked = Get-Content "$PoShHome\Settings\Search - Processes Checkbox.txt" }
            $OptionSearchComputersForPreviouslyCollectedDataProcessesGroupBox.Controls.Add($OptionSearchProcessesCheckBox)


            $OptionSearchServicesCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
                Text     = "Services"
                Location = @{ X = $FormScale * 10
                            Y = $OptionSearchProcessesCheckBox.Location.Y + $OptionSearchProcessesCheckBox.Size.Height }
                Size     = @{ Width  = $FormScale * 200
                            Height = $FormScale * 20 }
                Enabled  = $true
                Checked  = $False
                Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                Add_Click = { $This.Text | Set-Content "$PoShHome\Settings\Search - Services Checkbox.txt" -Force }
            }
            if (Test-Path "$PoShHome\Settings\Search - Services Checkbox.txt") { $OptionSearchServicesCheckBox.Checked = Get-Content "$PoShHome\Settings\Search - Services Checkbox.txt" }
            $OptionSearchComputersForPreviouslyCollectedDataProcessesGroupBox.Controls.Add($OptionSearchServicesCheckBox)


            $OptionSearchNetworkTCPConnectionsCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
                Text     = "Network TCP Connections"
                Location = @{ X = $FormScale * 10
                            Y = $OptionSearchServicesCheckBox.Location.Y + $OptionSearchServicesCheckBox.Size.Height - $($FormScale + 1) }
                Size     = @{ Width  = $FormScale * 200
                            Height = $FormScale * 20 }
                Enabled  = $true
                Checked  = $False
                Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                Add_Click = { $This.Text | Set-Content "$PoShHome\Settings\Search - Network TCP Connections Checkbox.txt" -Force }
            }
            if (Test-Path "$PoShHome\Settings\Search - Network TCP Connections Checkbox.txt") { $OptionSearchNetworkTCPConnectionsCheckBox.Checked = Get-Content "$PoShHome\Settings\Search - Network TCP Connections Checkbox.txt" }
            $OptionSearchComputersForPreviouslyCollectedDataProcessesGroupBox.Controls.Add($OptionSearchNetworkTCPConnectionsCheckBox)
$Section2OptionsTab.Controls.Add($OptionSearchComputersForPreviouslyCollectedDataProcessesGroupBox)


. "$Dependencies\Code\System.Windows.Forms\Combobox\OptionStatisticsUpdateIntervalComboBox.ps1"
$OptionStatisticsUpdateIntervalCombobox = New-Object System.Windows.Forms.Combobox -Property @{
    Text = 5
    Location = @{ X = $FormScale * 3
                  Y = $OptionSearchComputersForPreviouslyCollectedDataProcessesGroupBox.Location.Y + $OptionSearchComputersForPreviouslyCollectedDataProcessesGroupBox.Size.Height + $($FormScale + 2) }
    Size = @{ Width  = $FormScale * 50
              Height = $FormScale * 22 }
    Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_MouseHover = $OptionStatisticsUpdateIntervalComboboxAdd_MouseHover
    Add_SelectedIndexChanged = { $This.Text | Set-Content "$PoShHome\Settings\Statistics Update Interval.txt" -Force }
}
$StatisticsTimesAvailable = @(1,5,10,15,30,45,60)
ForEach ($Item in $StatisticsTimesAvailable) { $OptionStatisticsUpdateIntervalCombobox.Items.Add($Item) }
if (Test-Path "$PoShHome\Settings\Statistics Update Interval.txt") { $OptionStatisticsUpdateIntervalCombobox.text = Get-Content "$PoShHome\Settings\Statistics Update Interval.txt" }
$Section2OptionsTab.Controls.Add($OptionStatisticsUpdateIntervalCombobox)


$OptionStatisticsUpdateIntervalLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "Statistics Update Interval"
    Location = @{ X = $OptionStatisticsUpdateIntervalCombobox.Left + $OptionStatisticsUpdateIntervalCombobox.Width + $($FormScale + 5)
                  Y = $OptionStatisticsUpdateIntervalCombobox.Location.Y + $($FormScale + 3) }
    Size     = @{ Width  = $FormScale * 200
                  Height = $FormScale * 18 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section2OptionsTab.Controls.Add($OptionStatisticsUpdateIntervalLabel)


. "$Dependencies\Code\System.Windows.Forms\CheckBox\OptionGUITopWindowCheckBox.ps1"
$OptionGUITopWindowCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
    Text     = "GUI always on top"
    Location = @{ X = $FormScale * 3
                  Y = $OptionStatisticsUpdateIntervalLabel.Location.Y + $OptionStatisticsUpdateIntervalLabel.Size.Height + $($FormScale + 2) }
    Size     = @{ Width  = $FormScale * 300
                  Height = $FormScale * $Column3BoxHeight }
    Enabled  = $true
    Checked  = $false
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click = $OptionGUITopWindowCheckBoxAdd_Click
}
if (Test-Path "$PoShHome\Settings\GUI Top Most Window.txt") { $OptionGUITopWindowCheckBox.checked = Get-Content "$PoShHome\Settings\GUI Top Most Window.txt" }
$Section2OptionsTab.Controls.Add( $OptionGUITopWindowCheckBox )


. "$Dependencies\Code\System.Windows.Forms\Checkbox\OptionsAutoSaveChartsAsImages.ps1"
$OptionsAutoSaveChartsAsImages = New-Object System.Windows.Forms.Checkbox -Property @{
    Text     = "Autosave Charts As Images"
    Location = @{ X = $FormScale * 3
                  Y = $OptionGUITopWindowCheckBox.Location.Y + $OptionGUITopWindowCheckBox.Size.Height }
    Size     = @{ Width  = $FormScale * 300
                  Height = $FormScale * $Column3BoxHeight }
    Enabled  = $true
    Checked  = $false
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click      = $OptionsAutoSaveChartsAsImagesAdd_Click
    Add_MouseHover = $OptionsAutoSaveChartsAsImagesAdd_MouseHover
}
if (Test-Path "$PoShHome\Settings\Auto Save Charts As Images.txt") { $OptionsAutoSaveChartsAsImages.Checked = Get-Content "$PoShHome\Settings\Auto Save Charts As Images.txt" }
$Section2OptionsTab.Controls.Add( $OptionsAutoSaveChartsAsImages )


$OptionShowToolTipCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
    Text     = "Show ToolTip"
    Location = @{ X = $FormScale * 3
                  Y = $OptionsAutoSaveChartsAsImages.Location.Y + $OptionsAutoSaveChartsAsImages.Size.Height }
    Size     = @{ Width  = $FormScale * 200
                  Height = $FormScale * $Column3BoxHeight }
    Enabled  = $true
    Checked  = $True
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click = { $This.Checked | Set-Content "$PoShHome\Settings\Show Tool Tip.txt" -Force }
}
if (Test-Path "$PoShHome\Settings\Show Tool Tip.txt") { $OptionShowToolTipCheckBox.Checked = Get-Content "$PoShHome\Settings\Show Tool Tip.txt" }
$Section2OptionsTab.Controls.Add($OptionShowToolTipCheckBox)


$OptionTextToSpeachCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
    Text     = "Audible Completion Message"
    Location = @{ X = $FormScale * 3
                  Y = $OptionShowToolTipCheckBox.Location.Y + $OptionShowToolTipCheckBox.Size.Height }
    Size     = @{ Width  = $FormScale * 200
                  Height = $FormScale * $Column3BoxHeight }
    Enabled  = $true
    Checked  = $false
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click = { $This.Checked | Set-Content "$PoShHome\Settings\Audible Completion Message.txt" -Force }
}
if (Test-Path "$PoShHome\Settings\Audible Completion Message.txt") { $OptionTextToSpeachCheckBox.checked = Get-Content "$PoShHome\Settings\Audible Completion Message.txt" }
if ($AudibleCompletionMessage) {$OptionTextToSpeachCheckBox.Checked = $True}
$Section2OptionsTab.Controls.Add($OptionTextToSpeachCheckBox)


$OptionPacketKeepEtlCabFilesCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
    Text     = "Packet Captures - Keep .etc & .cab files"
    Location = @{ X = $FormScale * 3
                  Y = $OptionTextToSpeachCheckBox.Location.Y + $OptionTextToSpeachCheckBox.Size.Height }
    Size     = @{ Width  = $FormScale * 250
                  Height = $FormScale * $Column3BoxHeight }
    Enabled  = $true
    Checked  = $false
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click = { $This.Checked | Set-Content "$PoShHome\Settings\Packet Captures - Keep etl and cab files.txt" -Force }
}
if (Test-Path "$PoShHome\Settings\Packet Captures - Keep etl and cab files.txt") { $OptionPacketKeepEtlCabFilesCheckBox.checked = Get-Content "$PoShHome\Settings\Packet Captures - Keep etl and cab files.txt" }
$Section2OptionsTab.Controls.Add($OptionPacketKeepEtlCabFilesCheckBox)


$OptionKeepResultsByEndpointsFilesCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
    Text     = "Individual Execution - Keep Results by Endpoints"
    Location = @{ X = $FormScale * 3
                  Y = $OptionPacketKeepEtlCabFilesCheckBox.Location.Y + $OptionPacketKeepEtlCabFilesCheckBox.Size.Height }
    Size     = @{ Width  = $FormScale * 300
                  Height = $FormScale * $Column3BoxHeight }
    Enabled  = $true
    Checked  = $true
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click = { $This.Checked | Set-Content "$PoShHome\Settings\Individual Execution - Keep Results by Endpoints.txt" -Force }
}
if (Test-Path "$PoShHome\Settings\Individual Execution - Keep Results by Endpoints.txt") { $OptionKeepResultsByEndpointsFilesCheckBox.checked = Get-Content "$PoShHome\Settings\Individual Execution - Keep Results by Endpoints.txt" }
$Section2OptionsTab.Controls.Add($OptionKeepResultsByEndpointsFilesCheckBox)


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
$script:ProgressBarFormProgressBar.Value += 1
$script:ProgressBarSelectionForm.Refresh()

$Section2StatisticsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text                    = "Statistics"
    Name                    = "Statistics"
    Font                    = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
    UseVisualStyleBackColor = $True
}
$MainCenterTabControl.Controls.Add($Section2StatisticsTab)

# Gets various statistics on PoSh-EasyWin such as number of queries and computer treenodes selected, and
# the number number of csv files and data storage consumed
. "$Dependencies\Code\Execution\Get-PoShEasyWinStatistics.ps1"
$StatisticsResults = Get-PoShEasyWinStatistics


. "$Dependencies\Code\System.Windows.Forms\Button\StatisticsRefreshButton.ps1"
$StatisticsRefreshButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Refresh"
    Location = @{ X = $FormScale * 2
                  Y = $FormScale * 5 }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Add_Click = $StatisticsRefreshButtonAdd_Click
}
$Section2StatisticsTab.Controls.Add($StatisticsRefreshButton)
CommonButtonSettings -Button $StatisticsRefreshButton


. "$Dependencies\Code\System.Windows.Forms\Button\StatisticsViewLogButton.ps1"
$StatisticsViewLogButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "View Log"
    Location = @{ X = $FormScale * 258
                  Y = $FormScale * 5 }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Add_Click      = $StatisticsViewLogButtonAdd_Click
    Add_MouseHover = $StatisticsViewLogButtonAdd_MouseHover
}
$Section2StatisticsTab.Controls.Add($StatisticsViewLogButton)
CommonButtonSettings -Button $StatisticsViewLogButton


$StatisticsNumberOfCSVs = New-Object System.Windows.Forms.Textbox -Property @{
    Text       = $StatisticsResults
    Location = @{ X = $FormScale * 3
                  Y = $FormScale * 32 }
    Size     = @{ Width  = $FormScale * 354
                  Height = $FormScale * 215 }
    Font       = New-Object System.Drawing.Font("Courier new",$($FormScale * 11),0,0,0)
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
. "$Dependencies\Code\Tree View\Computer\Update-TreeNodeComputerState.ps1"

# Adds a treenode to the specified root node... a computer node within a category node
. "$Dependencies\Code\Tree View\Computer\Add-NodeComputer.ps1"

$script:ComputerTreeViewSelected = ""

# Populate Auto Tag List used for Host Data tagging and Searching
$TagListFileContents = Get-Content -Path $TagAutoListFile

# Searches for Computer nodes that match a given search entry
# A new category node named by the search entry will be created and all results will be nested within
. "$Dependencies\Code\Tree View\Computer\Search-ComputerTreeNode.ps1"


. "$Dependencies\Code\System.Windows.Forms\ComboBox\ComputerTreeNodeSearchComboBox.ps1"
$ComputerTreeNodeSearchComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Name     = "Search TextBox"
    Location = @{ X = $FormScale * $Column4RightPosition
                  Y = $FormScale * 25 }
    Size     = @{ Width  = $FormScale * 168
                  Height = $FormScale * 25 }
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
    Font               = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_KeyDown        = $ComputerTreeNodeSearchComboBoxAdd_KeyDown
    Add_MouseHover     = $ComputerTreeNodeSearchComboBoxAdd_MouseHover
}
ForEach ($Tag in $TagListFileContents) { [void] $ComputerTreeNodeSearchComboBox.Items.Add($Tag) }
$PoShEasyWin.Controls.Add($ComputerTreeNodeSearchComboBox)


. "$Dependencies\Code\System.Windows.Forms\Button\ComputerTreeNodeSearchButton.ps1"
$ComputerTreeNodeSearchButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Search"
    Location = @{ X = $ComputerTreeNodeSearchComboBox.Location.X + $ComputerTreeNodeSearchComboBox.Size.Width + $($FormScale * 5 )
                  Y = $ComputerTreeNodeSearchComboBox.Location.Y }
    Size     = @{ Width  = $FormScale * 55
                  Height = $FormScale * 22 }
    Add_Click      = $ComputerTreeNodeSearchButtonAdd_Click
    Add_MouseHover = $ComputerTreeNodeSearchButtonAdd_MouseHover
}
$PoShEasyWin.Controls.Add($ComputerTreeNodeSearchButton)
CommonButtonSettings -Button $ComputerTreeNodeSearchButton


# Code to remove empty categoryies
. "$Dependencies\Code\Tree View\Computer\Remove-EmptyCategory.ps1"
Remove-EmptyCategory


# Context menu button code
. "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListCollapseToolStripButton.ps1"
. "$Dependencies\Code\Tree View\Computer\Message-HostAlreadyExists.ps1"
. "$Dependencies\Code\Tree View\Computer\AddHost-ComputerTreeNode.ps1"
. "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListAddEndpointToolStripButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListDeselectAllToolStripButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListNSLookupCheckedToolStripButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListTagToolStripButton.ps1"
. "$Dependencies\Code\Tree View\Computer\Move-ComputerTreeNodeSelected.ps1"
. "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListMoveToolStripButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListDeleteToolStripButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListRenameToolStripButton.ps1"
. "$Dependencies\Code\Execution\Action\Check-Connection.ps1"
. "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListPingToolStripButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListRPCCheckToolStripButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListSMBCheckToolStripButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListWinRMCheckToolStripButton.ps1"


# Code for the Context Menu
# This context menu is the one activeated when you click within the computer treeview area, but not when clicking on a computer ndoe itself
. "$Dependencies\Code\Context Menu Strip\Display-ContextMenuForComputerTreeView.ps1"


# This context menu is the one activeated when you click on the computer node itself within the computer treeview
# It is also activated within the Conduct-NodeAction function
. "$Dependencies\Code\Context Menu Strip\Display-ContextMenuForComputerTreeNode.ps1"
Display-ContextMenuForComputerTreeNode

#batman
$ComputerTreeViewImageList = New-Object System.Windows.Forms.TreeView.ImageList
$ComputerTreeViewImageList.Images.Add('C:\Users\Dan\Documents\GitHub\PoSh-EasyWin\PoSh-EasyWin\Dependencies\Images\PoSh-EasyWin Image 01.png')
$ComputerTreeViewImageList.Images.Add('C:\Users\Dan\Documents\GitHub\PoSh-EasyWin\PoSh-EasyWin\Dependencies\Images\PoSh-EasyWin Image 02.png')
$ComputerTreeViewImageList.Images.Add('C:\Users\Dan\Documents\GitHub\PoSh-EasyWin\PoSh-EasyWin\Dependencies\Images\PoSh-EasyWin Image 03.png')

# Ref Guide: https://info.sapien.com/index.php/guis/gui-controls/spotlight-on-the-contextmenustrip-control
. "$Dependencies\Code\System.Windows.Forms\TreeView\ComputerTreeView.ps1"
$script:ComputerTreeView = New-Object System.Windows.Forms.TreeView -Property @{
    size              = @{ Width  = $FormScale * 230
                           Height = $FormScale * 308 }
    Location          = @{ X = $ComputerTreeNodeSearchComboBox.Location.X
                           Y = $ComputerTreeNodeSearchButton.Location.Y + $ComputerTreeNodeSearchButton.Size.Height + $($FormScale * 5) }
    Font              = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    CheckBoxes        = $True
    #LabelEdit         = $True  #Not implementing yet...
    #not working # AfterLabelEdit = {  }
    #not working #ShowRootLines     = $false
    ShowLines         = $True
    ShowNodeToolTips  = $True
    Add_Click         = $ComputerTreeViewAdd_Click
    Add_AfterSelect   = $ComputerTreeViewAdd_AfterSelect
    Add_MouseHover    = $ComputerTreeViewAdd_MouseHover
    #Add_MouseEnter    = $ComputerTreeViewAdd_MouseEnter
    Add_MouseLeave    = $ComputerTreeViewAdd_MouseLeave
    #ShortcutsEnabled  = $false                                #Used for ContextMenuStrip
    ContextMenuStrip  = $ComputerListContextMenuStrip      #Ref Add_click
    ShowPlusMinus     = $true
    HideSelection     = $false
    #not working #AfterSelect       = {( 1 | ogv )}
    ImageList         = $ComputerTreeViewImageList
    ImageIndex        = 1
}
$script:ComputerTreeView.Sort()
$PoShEasyWin.Controls.Add($script:ComputerTreeView)


Initialize-ComputerTreeNodes
Populate-ComputerTreeNodeDefaultData

# Yes, save initially during the load because it will save any poulated default data
Save-HostData

# This will load data that is located in the saved file
Foreach($Computer in $script:ComputerTreeViewData) {
    Add-NodeComputer -RootNode $script:TreeNodeComputerList -Category $Computer.OperatingSystem -Entry $Computer.Name -ToolTip $Computer.IPv4Address -Metadata $Computer
}
$script:ComputerTreeView.Nodes.Add($script:TreeNodeComputerList)

# Controls the layout of the computer treeview
$script:ComputerTreeView.ExpandAll()
[System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerTreeView.Nodes
foreach ($root in $AllHostsNode) {
    foreach ($Category in $root.Nodes) {
        foreach ($Entry in $Category.nodes) { $Entry.Collapse() }
    }
}


$ComputerTreeNodeViewByLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "View by:"
    Location = @{ X = $FormScale * $Column4RightPosition
                  Y = $FormScale * 7 }
    Size     = @{ Width  = $FormScale * 75
                  Height = $FormScale * 25 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
}
$PoShEasyWin.Controls.Add($ComputerTreeNodeViewByLabel)

. "$Dependencies\Code\System.Windows.Forms\RadioButton\ComputerTreeNodeOSHostnameRadioButton.ps1"
$script:ComputerTreeNodeOSHostnameRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
    Text     = "OS"
    Location = @{ X = $ComputerTreeNodeViewByLabel.Location.X + $ComputerTreeNodeViewByLabel.Size.Width
                  Y = $ComputerTreeNodeViewByLabel.Location.Y - $($FormScale * 5) }
    Size     = @{ Height = $FormScale * 25
                  Width  = $FormScale * 50 }
    Checked  = $True
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click      = $ComputerTreeNodeOSHostnameRadioButtonAdd_Click
    Add_MouseHover = $ComputerTreeNodeOSHostnameRadioButtonAdd_MouseHover
}
$PoShEasyWin.Controls.Add($script:ComputerTreeNodeOSHostnameRadioButton)

. "$Dependencies\Code\System.Windows.Forms\RadioButton\ComputerTreeNodeOUHostnameRadioButton.ps1"
$ComputerTreeNodeOUHostnameRadioButton  = New-Object System.Windows.Forms.RadioButton -Property @{
    Text     = "OU / CN"
    Location = @{ X = $script:ComputerTreeNodeOSHostnameRadioButton.Location.X + $script:ComputerTreeNodeOSHostnameRadioButton.Size.Width + 5
                  Y = $script:ComputerTreeNodeOSHostnameRadioButton.Location.Y }
    Size     = @{ Height = $FormScale * 25
                  Width  = $FormScale * 75 }
    Checked  = $false
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
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
$script:ProgressBarFormProgressBar.Value += 1
$script:ProgressBarSelectionForm.Refresh()

$MainRightTabControl = New-Object System.Windows.Forms.TabControl -Property @{
    Name         = "Main Tab Window for Computer List"
    Location     = @{ X = $FormScale * 1082
                      Y = $FormScale * 10 }
    Size         = @{ Height = $FormScale * 349
                      Width  = $FormScale * 140 }
    ShowToolTips = $True
    Font         = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
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
$script:ProgressBarFormProgressBar.Value += 1
$script:ProgressBarSelectionForm.Refresh()

$Column5RightPosition     = 3
$Column5DownPosition      = 6
$Column5DownPositionShift = 28
$Column5BoxWidth          = 124
$Column5BoxHeight         = 22

. "$Dependencies\Code\Tree View\Computer\Create-ComputerNodeCheckBoxArray.ps1"
. "$Dependencies\Code\Tree View\Computer\ComputerNodeSelectedLessThanOne.ps1"
. "$Dependencies\Code\Tree View\Computer\ComputerNodeSelectedMoreThanOne.ps1"
. "$Dependencies\Code\Tree View\Computer\Verify-Action.ps1"

$Section3ActionTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = "Action"
    Left   = $FormScale * $Column5RightPosition
    Top    = $FormScale * $Column5DownPosition
    Height = $FormScale * $Column5BoxWidth
    Width  = $FormScale * $Column5BoxHeight
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
}
$MainRightTabControl.Controls.Add($Section3ActionTab)


# Used to verify settings before capturing memory as this can be quite resource exhaustive
# Contains various checks to ensure that adequate resources are available on the remote and local hosts
. "$Dependencies\Code\Execution\Action\Launch-RekallWinPmemForm.ps1"


. "$Dependencies\Code\System.Windows.Forms\Button\RekallWinPmemMemoryCaptureButton.ps1"
$RekallWinPmemMemoryCaptureButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Memory Capture"
    Left   = $FormScale * $Column5RightPosition
    Top    = $FormScale * $Column5DownPosition
    Width  = $FormScale * $Column5BoxWidth
    Height = $FormScale * $Column5BoxHeight
    Add_MouseHover = $RekallWinPmemMemoryCaptureButtonAdd_MouseHover
    Add_Click      = $RekallWinPmemMemoryCaptureButtonAdd_Click
}
CommonButtonSettings -Button $RekallWinPmemMemoryCaptureButton


# Test if the External Programs directory is present; if it's there load the tab
if (Test-Path "$ExternalPrograms\WinPmem\WinPmem.exe") { $Section3ActionTab.Controls.Add($RekallWinPmemMemoryCaptureButton) }

$Column5DownPosition += $Column5DownPositionShift


. "$Dependencies\Code\System.Windows.Forms\Button\EventViewerButton.ps1"
$EventViewerButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Event Viewer'
    Left   = $FormScale * $Column5RightPosition
    Top    = $FormScale * $Column5DownPosition
    Height = $FormScale * $Column5BoxHeight
    Width  = $FormScale * $Column5BoxWidth
    Add_Click = $EventViewerButtonAdd_Click
    Add_MouseHover = $EventViewerButtonAdd_MouseHover
}
$Section3ActionTab.Controls.Add($EventViewerButton)
CommonButtonSettings -Button $EventViewerButton

$Column5DownPosition += $Column5DownPositionShift


. "$Dependencies\Code\System.Windows.Forms\Button\ComputerListRDPButton.ps1"
$ComputerListRDPButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Remote Desktop'
    Left   = $FormScale * $Column5RightPosition
    Top    = $FormScale * $Column5DownPosition
    Width  = $FormScale * $Column5BoxWidth
    Height = $FormScale * $Column5BoxHeight
    Add_Click = $ComputerListRDPButtonAdd_Click
    Add_MouseHover = $ComputerListRDPButtonAdd_MouseHover
    Add_MouseEnter = {$script:ComputerListEndpointNameToolStripLabel.text = $null}
}
$Section3ActionTab.Controls.Add($ComputerListRDPButton)
CommonButtonSettings -Button $ComputerListRDPButton

$Column5DownPosition += $Column5DownPositionShift


. "$Dependencies\Code\System.Windows.Forms\Button\ComputerListPSSessionButton.ps1"
$ComputerListPSSessionButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "PS Session"
    Left   = $FormScale * $Column5RightPosition
    Top    = $FormScale * $Column5DownPosition
    Width  = $FormScale * $Column5BoxWidth
    Height = $FormScale * $Column5BoxHeight
    Add_Click      = $ComputerListPSSessionButtonAdd_Click
    Add_MouseHover = $ComputerListPSSessionButtonAdd_MouseHover
    Add_MouseEnter = {$script:ComputerListEndpointNameToolStripLabel.text = $null}
}
$Section3ActionTab.Controls.Add($ComputerListPSSessionButton)
CommonButtonSettings -Button $ComputerListPSSessionButton

$Column5DownPosition += $Column5DownPositionShift


. "$Dependencies\Code\System.Windows.Forms\Button\ComputerListPsExecButton.ps1"
$ComputerListPsExecButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'PsExec'
    Left   = $FormScale * $Column5RightPosition
    Top    = $FormScale * $Column5DownPosition
    Width  = $FormScale * $Column5BoxWidth
    Height = $FormScale * $Column5BoxHeight
    Add_Click = $ComputerListPsExecButtonAdd_Click
    Add_MouseHover = $ComputerListPsExecButtonAdd_MouseHover
    Add_MouseEnter = {$script:ComputerListEndpointNameToolStripLabel.text = $null}
}
CommonButtonSettings -Button $ComputerListPsExecButton

# Test if the External Programs directory is present; if it's there load the tab
if (Test-Path "$ExternalPrograms\PsExec.exe") { $Section3ActionTab.Controls.Add($ComputerListPsExecButton) }

$Column5DownPosition += $Column5DownPositionShift


# Rolls the credenaisl: 250 characters of random: abcdefghiklmnoprstuvwxyzABCDEFGHKLMNOPRSTUVWXYZ1234567890
. "$Dependencies\Code\Credential Management\Generate-NewRollingPassword.ps1"

# Used to create new credentials (Get-Credential), create a log entry, and save an encypted local copy
. "$Dependencies\Code\Credential Management\Create-NewCredentials.ps1"
# Encrypt an exported credential object
# The Export-Clixml cmdlet encrypts credential objects by using the Windows Data Protection API.
# The encryption ensures that only your user account on only that computer can decrypt the contents of the
# credential object. The exported CLIXML file can't be used on a different computer or by a different user.

# Code to launch the Credential Management Form
# Provides the abiltiy to select create, select, and save credentials
# Provides the option to enable password auto rolling
. "$Dependencies\Code\Credential Management\Launch-CredentialManagementForm.ps1"

. "$Dependencies\Code\System.Windows.Forms\Button\ProvideCredentialsButton.ps1"
$ProvideCredentialsButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Manage Credentials"
    Left   = $FormScale * $Column5RightPosition
    Top    = $FormScale * $Column5DownPosition
    Width  = $FormScale * $Column5BoxWidth
    Height = $FormScale * $Column5BoxHeight
    Add_Click      = $ProvideCredentialsButtonAdd_Click
    Add_MouseHover = $ProvideCredentialsButtonAdd_MouseHover
}
$Section3ActionTab.Controls.Add($ProvideCredentialsButton)
CommonButtonSettings -Button $ProvideCredentialsButton

$Column5DownPosition += $Column5DownPositionShift - 2


. "$Dependencies\Code\System.Windows.Forms\CheckBox\ComputerListProvideCredentialsCheckBox.ps1"
$ComputerListProvideCredentialsCheckBox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Specify Credentials"
    Left   = $FormScale * $Column5RightPosition + 1
    Top    = $FormScale * $Column5DownPosition
    Width  = $FormScale * $Column5BoxWidth
    Height = $FormScale * $Column5BoxHeight - 5
    Checked = $false
    Font    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click      = $ComputerListProvideCredentialsCheckBoxAdd_Click
    Add_MouseHover = $ComputerListProvideCredentialsCheckBoxAdd_MouseHover
}
$Section3ActionTab.Controls.Add($ComputerListProvideCredentialsCheckBox)

$Column5DownPosition += $Column5DownPositionShift


. "$Dependencies\Code\System.Windows.Forms\ComboBox\CommandTreeViewQueryMethodSelectionComboBox.ps1"
$script:CommandTreeViewQueryMethodSelectionComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Left   = $FormScale * $Column5RightPosition
    Top    = $FormScale * $Column5DownPosition
    Width  = ($FormScale * $Column5BoxWidth + 1)
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor     = 'Black'
    DropDownStyle = 'DropDownList'
    Add_SelectedIndexChanged = {
        & $script:CommandTreeViewQueryMethodSelectionComboBoxAdd_SelectedIndexChanged
        #$This.Text | Set-Content "$PoShHome\Settings\Script Execution Mode.txt" -Force

        if ($this.SelectedItem -eq 'Monitor Jobs') {
            $Section3ActionTab.Controls.Add($script:OptionJobTimeoutSelectionLabel)
            $Section3ActionTab.Controls.Add($script:OptionJobTimeoutSelectionComboBox)
            $Column5DownPosition += $Column5DownPositionShift
            $script:ComputerListExecuteButton.Top = $script:OptionJobTimeoutSelectionLabel.Top + $($FormScale * $Column5DownPositionShift)
        }
        else {
            $Section3ActionTab.Controls.Remove($script:OptionJobTimeoutSelectionLabel)
            $Section3ActionTab.Controls.Remove($script:OptionJobTimeoutSelectionComboBox)
            $script:ComputerListExecuteButton.Top = $this.Top + $($FormScale * $Column5DownPositionShift)
        }
    }
}
$QueryMethodSelectionList = @(
    'Monitor Jobs',
    'Session Based'
    #'Compiled Script'
    )
Foreach ($QueryMethod in $QueryMethodSelectionList) { $script:CommandTreeViewQueryMethodSelectionComboBox.Items.Add($QueryMethod) }
if (Test-Path "$PoShHome\Settings\Script Execution Mode.txt") { $script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem = Get-Content "$PoShHome\Settings\Script Execution Mode.txt" }
else { $script:CommandTreeViewQueryMethodSelectionComboBox.SelectedIndex = 0 }
$Section3ActionTab.Controls.Add($script:CommandTreeViewQueryMethodSelectionComboBox)

$Column5DownPosition += $Column5DownPositionShift + 2


$script:OptionJobTimeoutSelectionLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Job Timeout:"
    Left   = $FormScale * $Column5RightPosition
    Top    = $FormScale * $Column5DownPosition
    Width  = $FormScale * 70
    Height = $FormScale * $Column5BoxHeight
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section3ActionTab.Controls.Add($script:OptionJobTimeoutSelectionLabel)


. "$Dependencies\Code\System.Windows.Forms\ComboBox\OptionJobTimeoutSelectionComboBox.ps1"
$script:OptionJobTimeoutSelectionComboBox = New-Object -TypeName System.Windows.Forms.Combobox -Property @{
    Text   = $JobTimeOutSeconds
    Left   = $script:OptionJobTimeoutSelectionLabel.Left + $script:OptionJobTimeoutSelectionLabel.Width + $($FormScale * 5)
    Top    = $script:OptionJobTimeoutSelectionLabel.Top - $($FormScale * 3)
    Width  = $FormScale * 50
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,2,0)
    AutoCompleteMode = "SuggestAppend"
    Add_MouseHover   = $script:OptionJobTimeoutSelectionComboBoxAdd_MouseHover
    Add_SelectedIndexChanged = { $This.Text | Set-Content "$PoShHome\Settings\Job Timeout.txt" -Force }
}
$JobTimesAvailable = @(15,30,45,60,120,180,240,300,600)
ForEach ($Item in $JobTimesAvailable) { $script:OptionJobTimeoutSelectionComboBox.Items.Add($Item) }
if (Test-Path "$PoShHome\Settings\Job Timeout.txt") { $script:OptionJobTimeoutSelectionComboBox.text = Get-Content "$PoShHome\Settings\Job Timeout.txt" }
$Section3ActionTab.Controls.Add($script:OptionJobTimeoutSelectionComboBox)

$Column5DownPosition += $Column5DownPositionShift - $($FormScale * 2)


. "$Dependencies\Code\System.Windows.Forms\Button\ComputerListExecuteButton.ps1"
$script:ComputerListExecuteButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Execute Script"
    Left   = $FormScale * $Column5RightPosition
    Top    = $FormScale * $Column5DownPosition
    Width  = $FormScale * $Column5BoxWidth
    Height = $FormScale * ($Column5BoxHeight * 2) - 10
    Enabled   = $false
    Add_MouseHover = $script:ComputerListExecuteButtonAdd_MouseHover
}
### $script:ComputerListExecuteButton.Add_Click($ExecuteScriptHandler) ### Is located lower in the script
$Section3ActionTab.Controls.Add($script:ComputerListExecuteButton)
CommonButtonSettings -Button $script:ComputerListExecuteButton


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
$script:ProgressBarFormProgressBar.Value += 1
$script:ProgressBarSelectionForm.Refresh()

$Section3ManageListTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = "Import Data"
    Left   = $FormScale * $Column5RightPosition
    Top    = $FormScale * $Column5DownPosition
    Width  = $FormScale * $Column5BoxWidth
    Height = $FormScale * $Column5BoxHeight
    UseVisualStyleBackColor = $True
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$MainRightTabControl.Controls.Add($Section3ManageListTab)


# Changes the Comoputer TreeView Save Button to Red
. "$Dependencies\Code\Tree View\Computer\Update-NeedToSaveTreeView.ps1"


$ImportEndpointDataLabel = New-Object System.Windows.Forms.RadioButton -Property @{
    Text   = "Endpoint Data"
    Left   = 6
    Top    = 6
    AutoSize  = $true
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = 'Blue'
    Checked   = $True
}
$Section3ManageListTab.Controls.Add($ImportEndpointDataLabel)


. "$Dependencies\Code\System.Windows.Forms\Button\ImportEndpointDataFromActiveDirectoryButton.ps1"
$ImportEndpointDataFromActiveDirectoryButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Import from AD"
    Left   = $ImportEndpointDataLabel.Left
    Top    = $ImportEndpointDataLabel.Top + $ImportEndpointDataLabel.Height + ($FormScale * 5)
    Width  = $FormScale * 124
    Height = $FormScale * 22
    Add_Click      = $ImportEndpointDataFromActiveDirectoryButtonAdd_Click
    Add_MouseHover = $ImportEndpointDataFromActiveDirectoryButtonAdd_MouseHover
}
$Section3ManageListTab.Controls.Add($ImportEndpointDataFromActiveDirectoryButton)
CommonButtonSettings -Button $ImportEndpointDataFromActiveDirectoryButton


. "$Dependencies\Code\System.Windows.Forms\Button\ImportEndpointDataFromCsvButton.ps1"
$ImportEndpointDataFromCsvButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Import from .CSV"
    Left   = $ImportEndpointDataFromActiveDirectoryButton.Left
    Top    = $ImportEndpointDataFromActiveDirectoryButton.Top + $ImportEndpointDataFromActiveDirectoryButton.Height + ($FormScale * 10)
    Width  = $FormScale * 124
    Height = $FormScale * 22
    Add_Click      = $ImportEndpointDataFromCsvButtonAdd_Click
    Add_MouseHover = $ImportEndpointDataFromCsvButtonAdd_MouseHover
}
$Section3ManageListTab.Controls.Add($ImportEndpointDataFromCsvButton)
CommonButtonSettings -Button $ImportEndpointDataFromCsvButton


. "$Dependencies\Code\System.Windows.Forms\Button\ImportEndpointDataFromTxtButton.ps1"
$ImportEndpointDataFromTxtButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Import from .TXT"
    Left   = $ImportEndpointDataFromCsvButton.Left
    Top    = $ImportEndpointDataFromCsvButton.Top + $ImportEndpointDataFromCsvButton.Height + ($FormScale * 10)
    Width  = $FormScale * 124
    Height = $FormScale * 22
    Add_Click      = $ImportEndpointDataFromTxtButtonAdd_Click
    Add_MouseHover = $ImportEndpointDataFromTxtButtonAdd_MouseHover
}
$Section3ManageListTab.Controls.Add($ImportEndpointDataFromTxtButton)
CommonButtonSettings -Button $ImportEndpointDataFromTxtButton


. "$Dependencies\Code\System.Windows.Forms\Button\ComputerTreeNodeSaveButton.ps1"
$ComputerTreeNodeSaveButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "TreeView`r`nSaved"
    Left   = $ImportEndpointDataFromTxtButton.Left
    Top    = $ImportEndpointDataFromTxtButton.Top + $ImportEndpointDataFromTxtButton.Height + ($FormScale * 10)
    Width  = $FormScale * 124
    Height = $FormScale * (22 * 2) - 10
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click      = $ComputerTreeNodeSaveButtonAdd_Click
    Add_MouseHover = $ComputerTreeNodeSaveButtonAdd_MouseHover
}
$Section3ManageListTab.Controls.Add($ComputerTreeNodeSaveButton)
CommonButtonSettings -Button $ComputerTreeNodeSaveButton


$ImportAccountDataLabel = New-Object System.Windows.Forms.RadioButton -Property @{
    Text   = "Account Data"
    Left   = 6
    Top    = $ComputerTreeNodeSaveButton.Top + $ComputerTreeNodeSaveButton.Height + ($FormScale * 5)
    AutoSize  = $true
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = 'Blue'
    Checked   = $True
}
$Section3ManageListTab.Controls.Add($ImportAccountDataLabel)


. "$Dependencies\Code\System.Windows.Forms\Button\ImportAccountDataFromActiveDirectoryButton.ps1"
$ImportAccountDataFromActiveDirectoryButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Import from AD"
    Left   = $ImportAccountDataLabel.Left
    Top    = $ImportAccountDataLabel.Top + $ImportAccountDataLabel.Height + ($FormScale * 5)
    Width  = $FormScale * 124
    Height = $FormScale * 22
    Add_Click      = $ImportAccountDataFromActiveDirectoryButtonAdd_Click
    Add_MouseHover = $ImportAccountDataFromActiveDirectoryButtonAdd_MouseHover
}
$Section3ManageListTab.Controls.Add($ImportAccountDataFromActiveDirectoryButton)
CommonButtonSettings -Button $ImportAccountDataFromActiveDirectoryButton


$StatusLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Status:"
    Left   = $FormScale * 470
    Top    = $FormScale * 288
    Width  = $FormScale * 60
    Height = $FormScale * 20
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
}
$PoShEasyWin.Controls.Add($StatusLabel)


$StatusListBox = New-Object System.Windows.Forms.ListBox -Property @{
    Name   = "StatusListBox"
    Left   = $StatusLabel.Location.X + $StatusLabel.Size.Width
    Top    = $StatusLabel.Location.Y
    Width  = $FormScale * 310
    Height = $FormScale * 22
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    FormattingEnabled = $True
}
$StatusListBox.Items.Add("Welcome to PoSh-EasyWin!") | Out-Null
$PoShEasyWin.Controls.Add($StatusListBox)


$ProgressBarEndpointsLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Endpoint:"
    Left   = $StatusLabel.Location.X
    Top    = $StatusLabel.Location.Y + $StatusLabel.Size.Height
    Width  = $StatusLabel.Size.Width
    Height = $StatusLabel.Size.Height
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$PoShEasyWin.Controls.Add($ProgressBarEndpointsLabel)


$script:ProgressBarEndpointsProgressBar = New-Object System.Windows.Forms.ProgressBar -Property @{
    Left   = $ProgressBarEndpointsLabel.Location.X + $ProgressBarEndpointsLabel.Size.Width
    Top    = $ProgressBarEndpointsLabel.Location.Y
    Width  = $StatusListBox.Size.Width - 1
    Height = $FormScale * 15
    Forecolor = 'LightBlue'
    BackColor = 'white'
    Style     = "Continuous" #"Marque"
    Minimum   = 0
}
$PoSHEasyWin.Controls.Add($script:ProgressBarEndpointsProgressBar)


$ProgressBarQueriesLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "Task:"
    Left = $ProgressBarEndpointsLabel.Location.X
    Top = $ProgressBarEndpointsLabel.Location.Y + $ProgressBarEndpointsLabel.Size.Height
    Width  = $ProgressBarEndpointsLabel.Size.Width
    Height = $ProgressBarEndpointsLabel.Size.Height
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$PoShEasyWin.Controls.Add($ProgressBarQueriesLabel)


$script:ProgressBarQueriesProgressBar = New-Object System.Windows.Forms.ProgressBar -Property @{
    Left = $ProgressBarQueriesLabel.Location.X + $ProgressBarQueriesLabel.Size.Width
    Top = $ProgressBarQueriesLabel.Location.Y
    Width  = $StatusListBox.Size.Width - 1
    Height = $FormScale * 15
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
$script:ProgressBarFormProgressBar.Value += 1
$script:ProgressBarSelectionForm.Refresh()

$MainBottomTabControlOriginalTop    = $ProgressBarQueriesLabel.Location.Y + $ProgressBarQueriesLabel.Size.Height - 2
$MainBottomTabControlOriginalHeight = $FormScale * 250

$MainBottomTabControl = New-Object System.Windows.Forms.TabControl -Property @{
    Name   = "Main Tab Window"
    Left   = $FormScale * 470
    Top    = $MainBottomTabControlOriginalTop
    Width  = $FormScale * 752
    Height = $MainBottomTabControlOriginalHeight
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ShowToolTips = $True
    Add_MouseHover = { $this.bringtofront() }
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
$script:ProgressBarFormProgressBar.Value += 1
$script:ProgressBarSelectionForm.Refresh()

$Section3AboutTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text = "About"
    Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
    Add_click = { Maximize-MonitorJobsTab }
}
$MainBottomTabControl.Controls.Add($Section3AboutTab)


$PoShEasyWinLogoPictureBox = New-Object Windows.Forms.PictureBox -Property @{
    Text     = "PoSh-EasyWin Image"
    Location = @{ X = $FormScale * 3
                  Y = $FormScale * 10 }
    Size     = @{ Width  = $FormScale * 355
                  Height = $FormScale * 35 }
    Image = [System.Drawing.Image]::Fromfile("$Dependencies\Images\PoSh-EasyWin Image 01.png")
    SizeMode = 'StretchImage'
}
$Section3AboutTab.Controls.Add($PoShEasyWinLogoPictureBox)

. "$Dependencies\Code\System.Windows.Forms\Button\PoShEasyWinLicenseAndAboutButton.ps1"
$PoShEasyWinLicenseAndAboutButton = New-Object Windows.Forms.Button -Property @{
    Text     = "GNU General Public License v3"
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Location = @{ X = $FormScale * 540
                  Y = $FormScale * 22 }
    Size     = @{ Width  = $FormScale * 200
                  Height = $FormScale * 22 }
    Add_Click      = $PoShEasyWinLicenseAndAboutButtonAdd_Click
    Add_MouseHover = $PoShEasyWinLicenseAndAboutButtonAdd_MouseHover
}
$Section3AboutTab.Controls.Add($PoShEasyWinLicenseAndAboutButton)
CommonButtonSettings -Button $PoShEasyWinLicenseAndAboutButton


$Section1AboutSubTabRichTextBox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Text     = $(Get-Content "$Dependencies\About PoSh-EasyWin.txt" -raw)
    Font     = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    Location = @{ X = $FormScale * 0
                  Y = $FormScale * $PoShEasyWinLogoPictureBox.Location.Y + $PoShEasyWinLogoPictureBox.Size.Height + 2}
    Size     = @{ Width  = $FormScale * 742
                  Height = $FormScale * 175 }
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
$script:ProgressBarFormProgressBar.Value += 1
$script:ProgressBarSelectionForm.Refresh()

$Section3ResultsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text = "Info" #"Results"
    Name = "Results Tab"
    Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
    Add_click = { Maximize-MonitorJobsTab }
}
$MainBottomTabControl.Controls.Add($Section3ResultsTab)


. "$Dependencies\Code\System.Windows.Forms\Button\ResultsTabOpNotesAddButton.ps1"
$ResultsTabOpNotesAddButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "Add Selected To OpNotes"
    Location  = @{ X = $FormScale * 578
                   Y = $FormScale * 198 }
    Size      = @{ Width  = $FormScale * 150
                   Height = $FormScale * 25 }
    Add_Click = $ResultsTabOpNotesAddButtonAdd_Click
    Add_MouseHover = $ResultsTabOpNotesAddButtonAdd_MouseHover
}
$Section3ResultsTab.Controls.Add($ResultsTabOpNotesAddButton)
CommonButtonSettings -Button $ResultsTabOpNotesAddButton


$ResultsListBox = New-Object System.Windows.Forms.ListBox -Property @{
    Name     = "ResultsListBox"
    Location = @{ X = $FormScale * -1
                  Y = $FormScale * -1 }
    Size     = @{ Width  = $FormScale * 752 - 3
                  Height = $FormScale * 250 - 15 }
    FormattingEnabled   = $True
    SelectionMode       = 'MultiExtended'
    ScrollAlwaysVisible = $True
    AutoSize            = $False
    Font                = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
}
$Section3ResultsTab.Controls.Add($ResultsListBox)










#=======================================================================================================================================================================
#
#  Parent: Main Form -> Main Bottom TabControl
#
#
#
#   Monitor Jobs
#
#
#
#=======================================================================================================================================================================

function Maximize-MonitorJobsTab {
    $script:Section3MonitorJobsResizeButton.text = "v Minimize Tab"
    $MainBottomTabControl.Top    = $MainBottomTabControlOriginalTop - 855
    $MainBottomTabControl.Height = $MainBottomTabControlOriginalHeight + 855
    $MainBottomTabControl.bringtofront()
}

function Minimize-MonitorJobsTab {
    $script:Section3MonitorJobsResizeButton.text = "^ Maximize Tab"
    $MainBottomTabControl.Top    = $MainBottomTabControlOriginalTop
    $MainBottomTabControl.Height = $MainBottomTabControlOriginalHeight    
    $MainBottomTabControl.bringtofront()
}

$script:Section3MonitorJobsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text = "Monitor Jobs"
    Name = "Monitor Jobs Tab"
    Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoScroll = $true
    Add_MouseEnter = { 
        if ($script:Section3MonitorJobsResizeCheckbox.checked -eq $true ) { Maximize-MonitorJobsTab } 
        $MainBottomTabControl.bringtofront()
    }
    UseVisualStyleBackColor = $True
}
$MainBottomTabControl.Controls.Add($script:Section3MonitorJobsTab)

$script:AllJobs = $null

# This list will contain all the job ids executed by PoSh-EasyWin
# It's populated by the Monitor-Jobs function
# Used to track which jobs were previously done to separate them from the current onces
$script:PastJobsIDList = @()

$script:PreviousJobFormItemsList = @()
$script:MonitorJobsLeftPosition  = ($FormScale * 5)
$script:MonitorJobsTopPosition   = ($FormScale * 5 + 42)

$script:Section3MonitorJobsGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text      = "Monitor Jobs Options"
    Left      = 0
    Top       = 0
    Width     = $FormScale * 730
    Height    = $FormScale * 42
    Font      = New-Object System.Drawing.Font($Font,$($FormScale * 11),1,2,1)
    ForeColor = 'Blue'
}
$script:Section3MonitorJobsTab.Controls.Add($script:Section3MonitorJobsGroupBox)


$script:Section3MonitorJobsResizeButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "^ Maximize Tab"
    Left      = $FormScale * 5
    Top       = $FormScale * 15
    Width     = $FormScale * 116
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font($Font,$($FormScale * 11),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        if ($script:Section3MonitorJobsResizeButton.text -eq     "^ Maximize Tab") { Maximize-MonitorJobsTab }
        elseif ($script:Section3MonitorJobsResizeButton.text -eq "v Minimize Tab") { Minimize-MonitorJobsTab }
    }
}
$script:Section3MonitorJobsGroupBox.Controls.Add($script:Section3MonitorJobsResizeButton)
CommonButtonSettings -Button $script:Section3MonitorJobsResizeButton


$script:Section3MonitorJobsResizeCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text      = "Auto-Max"
    Left      = $script:Section3MonitorJobsResizeButton.Left + $script:Section3MonitorJobsResizeButton.Width + ($FormScale * 5)
    Top       = $script:Section3MonitorJobsResizeButton.Top
    Width     = $FormScale * 75
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
    ForeColor = 'Black'
    Checked   = $false
}
$script:Section3MonitorJobsGroupBox.Controls.Add($script:Section3MonitorJobsResizeCheckbox)


$script:Section3MonitorJobRemoveButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = 'Remove All'
    Left      = $FormScale * 575
    Top       = $script:Section3MonitorJobsResizeButton.Top
    Width     = $FormScale * 75
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("Courier New",$($FormScale * 8),1,2,1)
    Add_Click = {
        $RemoveAllJobsVerify = [System.Windows.Forms.MessageBox]::Show("Do you want to stop and remove all jobs?`n`nThis method currently only stops running jobs and removes them from view; it will not delete the files regardless if their 'keep data' box is not checked.",'PoSh-EasyWin','YesNo','Warning')
        switch ($RemoveAllJobsVerify) {
            'Yes'{
                $MainBottomTabControl.Top    = $MainBottomTabControlOriginalTop
                $MainBottomTabControl.Height = $MainBottomTabControlOriginalHeight    
        
                Get-Variable | Where-Object {$_.Name -match 'Section3MonitorJobPanel'} | Foreach-Object {
                    Invoke-Expression "`$script:Section3MonitorJobsTab.Controls.Remove(`$script:$($_.Name))"
                }
        
                $script:TotalJobsToRemoveCount = (Get-Job -name "PoSh-EasyWin: *" | Where-Object {$_.State -match 'Run'}).count
                $StatusListBox.Items.Clear()
                $StatusListBox.Items.Add("Monitor Progress Bars Removed - Stopping $script:TotalJobsToRemoveCount Remainingg Jobs...")

                Get-Job -Name "PoSh-EasyWin: *" | Stop-Job
                Get-Job -Name "PoSh-EasyWin: *" | Remove-Job -Force

                $StatusListBox.Items.Clear()
                $StatusListBox.Items.Add("Monitor Progress Bars Removed - Stopping $script:TotalJobsToRemoveCount Remainingg Jobs - Completed")
        
                $script:MonitorJobsTopPosition = ($FormScale * 5 + 42)
            }
            'No' {
                continue
            }
        }       
    }
}
$script:Section3MonitorJobsGroupBox.Controls.Add($script:Section3MonitorJobRemoveButton)
CommonButtonSettings -Button $script:Section3MonitorJobRemoveButton
$script:Section3MonitorJobRemoveButton.ForeColor = 'Red'


$script:Section3MonitorJobKeepDataAllCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text      = 'Keep Data'
    Left      = $script:Section3MonitorJobRemoveButton.Left + $script:Section3MonitorJobRemoveButton.Width + ($FormScale * 5)
    Top       = $script:Section3MonitorJobsResizeButton.Top
    Width     = $FormScale * 70
    Height    = $FormScale * 11
    Font      = New-Object System.Drawing.Font("Courier New",$($FormScale * 8),1,2,1)
    ForeColor = 'Black'
    checked   = $true
    Add_Click = {
        if ($script:Section3MonitorJobKeepDataAllCheckbox.checked -eq $true) {
            $script:Section3MonitorJobKeepDataAllCheckbox.ForeColor = 'Black'
            Get-Variable | Where-Object {$_.Name -match 'Section3MonitorJobKeepDataCheckbox'} | Foreach-Object {
                Invoke-Expression "`$script:$($_.Name).checked = `$true"
                Invoke-Expression "`$script:$($_.Name).forecolor = 'black'"
            }
        }
        else {
            $script:Section3MonitorJobKeepDataAllCheckbox.ForeColor = 'Red'
            Get-Variable | Where-Object {$_.Name -match 'Section3MonitorJobKeepDataCheckbox'} | Foreach-Object {
                Invoke-Expression "`$script:$($_.Name).checked = `$false"
                Invoke-Expression "`$script:$($_.Name).forecolor = 'red'"
            }    
        } 
    }
}
$script:Section3MonitorJobsGroupBox.Controls.Add($script:Section3MonitorJobKeepDataAllCheckbox)



$script:Section3MonitorJobNotifyAllCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text      = 'Notify Me'
    Left      = $script:Section3MonitorJobKeepDataAllCheckbox.Left
    Top       = $script:Section3MonitorJobKeepDataAllCheckbox.Top + $script:Section3MonitorJobKeepDataAllCheckbox.Height + ($FormScale * 1)
    Width     = $FormScale * 70
    Height    = $FormScale * 11
    Font      = New-Object System.Drawing.Font("Courier New",$($FormScale * 8),1,2,1)
    ForeColor = 'Black'
    Checked   = $false
    Add_Click = {
        if ($script:Section3MonitorJobNotifyAllCheckbox.checked -eq $true) {
            $script:Section3MonitorJobNotifyAllCheckbox.ForeColor = 'Blue'
            Get-Variable | Where-Object {$_.Name -match 'Section3MonitorJobNotifyCheckbox'} | Foreach-Object {
                Invoke-Expression "`$script:$($_.Name).checked = `$true"
                Invoke-Expression "`$script:$($_.Name).forecolor = 'blue'"
            }
        }
        else {
            $script:Section3MonitorJobNotifyAllCheckbox.ForeColor = 'Black'
            Get-Variable | Where-Object {$_.Name -match 'Section3MonitorJobNotifyCheckbox'} | Foreach-Object {
                Invoke-Expression "`$script:$($_.Name).checked = `$false"
                Invoke-Expression "`$script:$($_.Name).forecolor = 'black'"
            }    
        } 
    }
}
$script:Section3MonitorJobsGroupBox.Controls.Add($script:Section3MonitorJobNotifyAllCheckbox)















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
$script:ProgressBarFormProgressBar.Value += 1
$script:ProgressBarSelectionForm.Refresh()

$Section3HostDataTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text = "Endpoint Data"
    Name = "Host Data Tab"
    Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
    Add_click = { Maximize-MonitorJobsTab }
}
$MainBottomTabControl.Controls.Add($Section3HostDataTab)


. "$Dependencies\Code\System.Windows.Forms\TextBox\Section3HostDataNameTextBox.ps1"
$Section3HostDataNameTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = 0
                  Y = $FormScale * 3 }
    Size     = @{ Width  = $FormScale * 250
                  Height = $FormScale * 25 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ReadOnly = $true
    Add_MouseHover = $Section3HostDataNameTextBoxAdd_MouseHover
}
$Section3HostDataTab.Controls.Add($Section3HostDataNameTextBox)


. "$Dependencies\Code\System.Windows.Forms\TextBox\Section3HostDataOSTextBox.ps1"
$Section3HostDataOSTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = 0
                  Y = $Section3HostDataNameTextBox.Location.Y + $Section3HostDataNameTextBox.Size.Height + $($FormScale * 4) }
    Size     = @{ Width  = $FormScale * 250
                  Height = $FormScale * 25 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ReadOnly = $true
    Add_MouseHover = $Section3HostDataOSTextBoxAdd_MouseHover
}
$Section3HostDataTab.Controls.Add($Section3HostDataOSTextBox)


. "$Dependencies\Code\System.Windows.Forms\TextBox\Section3HostDataOUTextBox.ps1"
$Section3HostDataOUTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = 0
                  Y = $Section3HostDataOSTextBox.Location.Y + $Section3HostDataOSTextBox.Size.Height + $($FormScale * 4) }
    Size     = @{ Width  = $FormScale * 250
                  Height = $FormScale * 25 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ReadOnly = $true
    Add_MouseHover = $Section3HostDataOUTextBoxAdd_MouseHover
}
$Section3HostDataTab.Controls.Add($Section3HostDataOUTextBox)


. "$Dependencies\Code\System.Windows.Forms\TextBox\Section3HostDataIPTextBox.ps1"
$Section3HostDataIPTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = 0
                  Y = $Section3HostDataOUTextBox.Location.Y + $Section3HostDataOUTextBox.Size.Height + $($FormScale * 4) }
    Size     = @{ Width  = $FormScale * 120
                  Height = $FormScale * 25 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ReadOnly = $false
    Add_MouseHover = $Section3HostDataIPTextBoxAdd_MouseHover
}
$Section3HostDataTab.Controls.Add($Section3HostDataIPTextBox)


. "$Dependencies\Code\System.Windows.Forms\TextBox\Section3HostDataMACTextBox.ps1"
$Section3HostDataMACTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3HostDataIPTextBox.Size.Width + $($FormScale * 10)
                  Y = $Section3HostDataOUTextBox.Location.Y + $Section3HostDataOUTextBox.Size.Height + $($FormScale * 4) }
    Size     = @{ Width  = $FormScale * 120
                  Height = $FormScale * 25 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ReadOnly = $false
    Add_MouseHover = $Section3HostDataMACTextBoxAdd_MouseHover
}
$Section3HostDataTab.Controls.Add($Section3HostDataMACTextBox)


#============================================================================================================================================================
# Host Data - Selection Data ComboBox and Date/Time ComboBox
#============================================================================================================================================================

    . "$Dependencies\Code\System.Windows.Forms\ComboBox\Section3HostDataSelectionComboBox.ps1"
    $Section3HostDataSelectionComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Text      = "Host Data - Selection"
        Location  = @{ X = $FormScale * 260
                       Y = $FormScale * 3 }
        Size      = @{ Width  = $FormScale * 200
                       Height = $FormScale * 25 }
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = "Black"
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
        DataSource         = $HostDataList1
        Add_MouseHover     = $Section3HostDataSelectionComboBoxAdd_MouseHover
        Add_SelectedIndexChanged = $Section3HostDataSelectionComboBoxAdd_SelectedIndexChanged
    }
    $Section3HostDataTab.Controls.Add($Section3HostDataSelectionComboBox)


    . "$Dependencies\Code\System.Windows.Forms\ComboBox\Section3HostDataSelectionDateTimeComboBox.ps1"
    $Section3HostDataSelectionDateTimeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Text      = "Host Data - Date & Time"
        Location  = @{ X = $FormScale * 260
                       Y = $Section3HostDataSelectionComboBox.Size.Height + $Section3HostDataSelectionComboBox.Location.Y + $($FormScale * 3)}
        Size      = @{ Width  = $FormScale * 200
                       Height = $FormScale * 25 }
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = "Black"
        AutoCompleteSource = "ListItems"
        AutoCompleteMode   = "SuggestAppend"
        Add_MouseHover     = $Section3HostDataSelectionDateTimeComboBoxAdd_MouseHover
    }
    $Section3HostDataTab.Controls.Add($Section3HostDataSelectionDateTimeComboBox)


    . "$Dependencies\Code\System.Windows.Forms\Button\Section3HostDataGetDataButton.ps1"
    $Section3HostDataGetDataButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Get Data"
        Location = @{ X = $Section3HostDataSelectionDateTimeComboBox.Location.X + $Section3HostDataSelectionDateTimeComboBox.Size.Width + 5
                      Y =  $Section3HostDataSelectionDateTimeComboBox.Location.Y - $($FormScale * 1) }
        Size     = @{ Width  = $FormScale * 75
                      Height = $FormScale * 22 }
        Add_Click = $Section3HostDataGetDataButtonAdd_Click
        Add_MouseHover = $Section3HostDataGetDataButtonAdd_MouseHover
    }
    $Section3HostDataTab.Controls.Add($Section3HostDataGetDataButton)
    CommonButtonSettings -Button $Section3HostDataGetDataButton


. "$Dependencies\Code\System.Windows.Forms\ComboBox\Section3HostDataTagsComboBox.ps1"
$Section3HostDataTagsComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Name               = "Tags"
    Text               = "Tags"
    Location = @{ X = $FormScale * 260
                  Y = $Section3HostDataMACTextBox.Location.Y }
    Size     = @{ Width  = $FormScale * 200
                  Height = $FormScale * 25 }
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
    Font               = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_MouseHover     = $Section3HostDataTagsComboBoxAdd_MouseHover
}
ForEach ($Item in $TagListFileContents) { $Section3HostDataTagsComboBox.Items.Add($Item) }
$Section3HostDataTab.Controls.Add($Section3HostDataTagsComboBox)


. "$Dependencies\Code\System.Windows.Forms\Button\Section3HostDataTagsAddButton.ps1"
$Section3HostDataTagsAddButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Add"
    Location = @{ X = $Section3HostDataTagsComboBox.Size.Width + $Section3HostDataTagsComboBox.Location.X + $($FormScale * 5)
                  Y = $Section3HostDataTagsComboBox.Location.Y - $($FormScale * 1) }
    Size     = @{ Width  = $FormScale * 75
                  Height = $FormScale * 22 }
    Add_Click = $Section3HostDataTagsAddButtonAdd_Click
    Add_MouseHover = $Section3HostDataTagsAddButtonAdd_MouseHover
}
$Section3HostDataTab.Controls.Add($Section3HostDataTagsAddButton)
CommonButtonSettings -Button $Section3HostDataTagsAddButton


. "$Dependencies\Code\System.Windows.Forms\RichTextBox\Section3HostDataNotesRichTextBox.ps1"
$Section3HostDataNotesRichTextBox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Location = @{ X = 0
                  Y = $Section3HostDataMACTextBox.Location.Y + $Section3HostDataMACTextBox.Size.Height + $($FormScale * 6) }
    Size     = @{ Width  = $FormScale * 634
                  Height = $FormScale * 135 }
    Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Multiline  = $True
    ScrollBars = 'Vertical'
    WordWrap   = $True
    ReadOnly   = $false
    Add_MouseHover = $Section3HostDataNotesRichTextBoxAdd_MouseHover
    Add_MouseEnter = { Check-HostDataIfModified }
    Add_MouseLeave = { Check-HostDataIfModified }
}
$Section3HostDataTab.Controls.Add($Section3HostDataNotesRichTextBox)


$script:Section3HostDataNotesSaveCheck = ""
. "$Dependencies\Code\System.Windows.Forms\Button\Section3HostDataSaveButton.ps1"
$Section3HostDataSaveButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "Data Saved"
    Location = @{ X = $Section3HostDataNotesRichTextBox.Location.X + $Section3HostDataNotesRichTextBox.Size.Width + $($FormScale + 5)
                  Y = $Section3HostDataNotesRichTextBox.Location.Y }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Add_Click = $Section3HostDataSaveButtonAdd_Click
    Add_MouseHover = $Section3HostDataSaveButtonAdd_MouseHover
}
$Section3HostDataTab.Controls.Add($Section3HostDataSaveButton)
CommonButtonSettings -Button $Section3HostDataSaveButton


. "$Dependencies\Code\System.Windows.Forms\Button\Section3HostDataNotesAddOpNotesButton.ps1"
$Section3HostDataNotesAddOpNotesButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "Add To OpNotes"
    Location = @{ X = $Section3HostDataSaveButton.Location.X
                  Y = $Section3HostDataSaveButton.Location.Y + $Section3HostDataSaveButton.Size.Height + $($FormScale + 5) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Add_Click = $Section3HostDataNotesAddOpNotesButtonAdd_Click
    Add_MouseHover = $Section3HostDataNotesAddOpNotesButtonAdd_MouseHover
}
$Section3HostDataTab.Controls.Add($Section3HostDataNotesAddOpNotesButton)
CommonButtonSettings -Button $Section3HostDataNotesAddOpNotesButton


# Mass Tag one or multiple hosts in the computer treeview
. "$Dependencies\Code\Tree View\Computer\Save-ComputerTreeNodeHostData.ps1"

# Checks if the Host Data has been modified and determines the text color: Green/Red
. "$Dependencies\Code\Main Body\Check-HostDataIfModified.ps1"


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
$script:ProgressBarFormProgressBar.Value += 1
$script:ProgressBarSelectionForm.Refresh()

$Section3QueryExplorationTabPage = New-Object System.Windows.Forms.TabPage -Property @{
    Text = "Query Exploration"
    Name = "Query Exploration"
    Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
    Add_click = { Maximize-MonitorJobsTab }
}
$MainBottomTabControl.Controls.Add($Section3QueryExplorationTabPage)


$Section3QueryExplorationNameLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "Query Name:"
    Location = @{ X = $FormScale * 0
                  Y = $FormScale * 6 }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section3QueryExplorationNameTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationNameLabel.Location.X + $Section3QueryExplorationNameLabel.Size.Width + $($FormScale * 5)
                  Y = $FormScale * 3 }
    Size     = @{ Width  = $FormScale * 195
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ReadOnly = $true
    Add_MouseEnter = { $Section3QueryExplorationNameTextBox.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $Section3QueryExplorationNameTextBox.size = @{ Width  = $FormScale * 195 } }
}
$Section3QueryExplorationTabPage.Controls.AddRange(@($Section3QueryExplorationNameLabel,$Section3QueryExplorationNameTextBox))


$Section3QueryExplorationWinRMPoShLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "WinRM PoSh:"
    Location = @{ X = 0
                  Y = $Section3QueryExplorationNameLabel.location.Y + $Section3QueryExplorationNameLabel.Size.Height }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section3QueryExplorationWinRMPoShTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationWinRMPoShLabel.Location.X + $Section3QueryExplorationWinRMPoShLabel.Size.Width + $($FormScale * 5)
                  Y = $Section3QueryExplorationWinRMPoShLabel.Location.Y - $($FormScale * 3) }
    Size     = @{ Width  = $FormScale * 195
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ReadOnly = $true
    Add_MouseEnter = { $Section3QueryExplorationWinRMPoShTextBox.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $Section3QueryExplorationWinRMPoShTextBox.size = @{ Width  = $FormScale * 195 } }
}
$Section3QueryExplorationTabPage.Controls.AddRange(@($Section3QueryExplorationWinRMPoShLabel,$Section3QueryExplorationWinRMPoShTextBox))


$Section3QueryExplorationWinRMWMILabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "WinRM WMI:"
    Location = @{ X = 0
                  Y = $Section3QueryExplorationWinRMPoShLabel.location.Y + $Section3QueryExplorationWinRMPoShLabel.Size.Height }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationWinRMWMILabel)


$Section3QueryExplorationWinRMWMITextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationWinRMWMILabel.Location.X + $Section3QueryExplorationWinRMWMILabel.Size.Width + $($FormScale * 5)
                  Y = $Section3QueryExplorationWinRMWMILabel.Location.Y - $($FormScale * 3) }
    Size     = @{ Width  = $FormScale * 195
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ReadOnly = $true
    Add_MouseEnter = { $Section3QueryExplorationWinRMWMITextBox.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $Section3QueryExplorationWinRMWMITextBox.size = @{ Width  = $FormScale * 195 } }
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationWinRMWMITextBox)


$Section3QueryExplorationWinRMCmdLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "WinRM Cmd:"
    Location = @{ X = 0
                  Y = $Section3QueryExplorationWinRMWMILabel.location.Y + $Section3QueryExplorationWinRMWMILabel.Size.Height }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationWinRMCmdLabel)


$Section3QueryExplorationWinRMCmdTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationWinRMCmdLabel.Location.X + $Section3QueryExplorationWinRMCmdLabel.Size.Width + $($FormScale * 5)
                  Y = $Section3QueryExplorationWinRMCmdLabel.Location.Y - $($FormScale * 3) }
    Size     = @{ Width  = $FormScale * 195
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ReadOnly = $true
    Add_MouseEnter = { $Section3QueryExplorationWinRMCmdTextBox.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $Section3QueryExplorationWinRMCmdTextBox.size = @{ Width  = $FormScale * 195 } }
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationWinRMCmdTextBox)


$Section3QueryExplorationRPCPoShLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "RPC/DCOM PoSh:"
    Location = @{ X = 0
                  Y = $Section3QueryExplorationWinRMCmdLabel.location.Y + $Section3QueryExplorationWinRMCmdLabel.Size.Height }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationRPCPoShLabel)


$Section3QueryExplorationRPCPoShTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationRPCPoShLabel.Location.X + $Section3QueryExplorationRPCPoShLabel.Size.Width + $($FormScale * 5)
                  Y = $Section3QueryExplorationRPCPoShLabel.Location.Y - $($FormScale * 3) }
    Size     = @{ Width  = $FormScale * 195
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ReadOnly = $true
    Add_MouseEnter = { $Section3QueryExplorationRPCPoShTextBox.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $Section3QueryExplorationRPCPoShTextBox.size = @{ Width  = $FormScale * 195 } }
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationRPCPoShTextBox)


$Section3QueryExplorationRPCWMILabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "RPC/DCOM WMI:"
    Location = @{ X = 0
                  Y = $Section3QueryExplorationRPCPoShLabel.location.Y + $Section3QueryExplorationRPCPoShLabel.Size.Height }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationRPCWMILabel)


$Section3QueryExplorationRPCWMITextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationRPCWMILabel.Location.X + $Section3QueryExplorationRPCWMILabel.Size.Width + $($FormScale * 5)
                  Y = $Section3QueryExplorationRPCWMILabel.Location.Y - $($FormScale * 3) }
    Size     = @{ Width  = $FormScale * 195
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ReadOnly = $true
    Add_MouseEnter = { $Section3QueryExplorationRPCWMITextBox.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $Section3QueryExplorationRPCWMITextBox.size = @{ Width  = $FormScale * 195 } }
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationRPCWMITextBox)


$Section3QueryExplorationPropertiesPoshLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "Properties PoSh:"
    Location = @{ X = 0
                  Y = $Section3QueryExplorationRPCWMILabel.location.Y + $Section3QueryExplorationRPCWMILabel.Size.Height }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationPropertiesPoshLabel)


$Section3QueryExplorationPropertiesPoshTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationPropertiesPoshLabel.Location.X + $Section3QueryExplorationPropertiesPoshLabel.Size.Width + $($FormScale * 5)
                  Y = $Section3QueryExplorationPropertiesPoshLabel.Location.Y - $($FormScale * 3) }
    Size     = @{ Width  = $FormScale * 195
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ReadOnly = $true
    Add_MouseEnter = { $Section3QueryExplorationPropertiesPoshTextBox.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $Section3QueryExplorationPropertiesPoshTextBox.size = @{ Width  = $FormScale * 195 } }
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationPropertiesPoshTextBox)


$Section3QueryExplorationPropertiesWMILabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "Properties WMI:"
    Location = @{ X = 0
                  Y = $Section3QueryExplorationPropertiesPoshLabel.location.Y + $Section3QueryExplorationPropertiesPoshLabel.Size.Height }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationPropertiesWMILabel)


$Section3QueryExplorationPropertiesWMITextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationPropertiesWMILabel.Location.X + $Section3QueryExplorationPropertiesWMILabel.Size.Width + $($FormScale * 5)
                  Y = $Section3QueryExplorationPropertiesWMILabel.Location.Y - $($FormScale * 3) }
    Size     = @{ Width  = $FormScale * 195
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ReadOnly = $true
    Add_MouseEnter = { $Section3QueryExplorationPropertiesWMITextBox.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $Section3QueryExplorationPropertiesWMITextBox.size = @{ Width  = $FormScale * 195 } }
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationPropertiesWMITextBox)


$Section3QueryExplorationWinRSWmicLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "WinRS WMIC:"
    Location = @{ X = 0
                  Y = $Section3QueryExplorationPropertiesWMILabel.location.Y + $Section3QueryExplorationPropertiesWMILabel.Size.Height }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationWinRSWmicLabel)


$Section3QueryExplorationWinRSWmicTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationWinRSWmicLabel.Location.X + $Section3QueryExplorationWinRSWmicLabel.Size.Width + $($FormScale * 5)
                  Y = $Section3QueryExplorationWinRSWmicLabel.Location.Y - $($FormScale * 3) }
    Size     = @{ Width  = $FormScale * 195
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ReadOnly = $true
    Add_MouseEnter = { $Section3QueryExplorationWinRSWmicTextBox.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $Section3QueryExplorationWinRSWmicTextBox.size = @{ Width  = $FormScale * 195 } }
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationWinRSWmicTextBox)


$Section3QueryExplorationWinRSCmdLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "WinRS Cmd:"
    Location = @{ X = 0
                  Y = $Section3QueryExplorationWinRSWmicLabel.location.Y + $Section3QueryExplorationWinRSWmicLabel.Size.Height }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationWinRSCmdLabel)


$Section3QueryExplorationWinRSCmdTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationWinRSCmdLabel.Location.X + $Section3QueryExplorationWinRSCmdLabel.Size.Width + $($FormScale * 5)
                  Y = $Section3QueryExplorationWinRSCmdLabel.Location.Y - $($FormScale * 3) }
    Size     = @{ Width  = $FormScale * 195
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ReadOnly = $true
    Add_MouseEnter = { $Section3QueryExplorationWinRSCmdTextBox.size = @{ Width  = $FormScale * 633 } }
    Add_MouseLeave = { $Section3QueryExplorationWinRSCmdTextBox.size = @{ Width  = $FormScale * 195 } }
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationWinRSCmdTextBox)


$Section3QueryExplorationDescriptionRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Location   = @{ X = $Section3QueryExplorationNameTextBox.Location.X + $Section3QueryExplorationNameTextBox.Size.Width + $($FormScale * 10)
                    Y = $Section3QueryExplorationNameTextBox.Location.Y }
    Size       = @{ Width  = $FormScale * 428
                    Height = $FormScale * 196 }
    Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Multiline  = $True
    ScrollBars = 'Vertical'
    WordWrap   = $True
    ReadOnly   = $true
    ShortcutsEnabled = $true
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationDescriptionRichTextbox)


$Section3QueryExplorationTagWordsLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "Tags"
    Location = @{ X = $Section3QueryExplorationDescriptionRichTextbox.Location.X
                  Y = $Section3QueryExplorationDescriptionRichTextbox.location.Y + $Section3QueryExplorationDescriptionRichTextbox.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 35
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationTagWordsLabel)


$Section3QueryExplorationTagWordsTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $Section3QueryExplorationTagWordsLabel.Location.X + $Section3QueryExplorationTagWordsLabel.Size.Width + $($FormScale * 5)
                  Y = $Section3QueryExplorationTagWordsLabel.Location.Y - $($FormScale * 3) }
    Size     = @{ Width  = $FormScale * 200
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ReadOnly = $true
}
$Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationTagWordsTextBox)


. "$Dependencies\Code\System.Windows.Forms\CheckBox\Section3QueryExplorationEditCheckBox.ps1"
$Section3QueryExplorationEditCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
    Text      = "Edit"
    Location  = @{ X = $Section3QueryExplorationDescriptionRichTextbox.Location.X + $($FormScale * 255)
                   Y = $Section3QueryExplorationDescriptionRichTextbox.Location.Y + $Section3QueryExplorationDescriptionRichTextbox.Size.Height + $($FormScale * 3) }
    Size      = @{ Height = $FormScale * 25
                   Width  = $FormScale * 50 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,2,1)
    Checked   = $false
    Add_Click = $Section3QueryExplorationEditCheckBoxAdd_Click
}
# Note: The button is added/removed in other parts of the code


. "$Dependencies\Code\System.Windows.Forms\Button\Section3QueryExplorationSaveButton.ps1"
$Section3QueryExplorationSaveButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = 'Locked'
    Location  = @{ X = $Section3QueryExplorationEditCheckBox.Location.X + $($FormScale * 50)
                   Y = $Section3QueryExplorationEditCheckBox.Location.Y }
    Size      = @{ Width  = $FormScale * $Column5BoxWidth
                   Height = $FormScale * $Column5BoxHeight }
    Add_Click = $Section3QueryExplorationSaveButtonAdd_Click
}
CommonButtonSettings -Button $Section3QueryExplorationSaveButton
# Note: The button is added/removed in other parts of the code


. "$Dependencies\Code\System.Windows.Forms\Button\Section3QueryExplorationViewScriptButton.ps1"
$Section3QueryExplorationViewScriptButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = 'View Script'
    Location  = @{ X = $Section3QueryExplorationEditCheckBox.Location.X + $($FormScale * 50)
                   Y = $Section3QueryExplorationEditCheckBox.Location.Y }
    Size      = @{ Width  = $FormScale * $Column5BoxWidth
                   Height = $FormScale * $Column5BoxHeight }
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
#. "$Dependencies\Code\Execution\Compile-CsvFiles.ps1"

# Compiles the .xml files in the collection directory then saves the combined file to the partent directory
#. "$Dependencies\Code\Execution\Compile-XmlFiles.ps1"

# Removes Duplicate CSV Headers
. "$Dependencies\Code\Execution\Individual Execution\Remove-DuplicateCsvHeaders.ps1"

# This is one of the core scripts that handles how queries are conducted
# It monitors started PoSh-EasyWin jobs and updates the GUI
. "$Dependencies\Code\Execution\Individual Execution\Monitor-Jobs.ps1"

# Common code that runs after jobs have completed that updates the GUI, Compiles files (csv & xml), and logs
. "$Dependencies\Code\Execution\Individual Execution\Post-MonitorJobs.ps1"

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

# Generate list of endpoints to query
. "$Dependencies\Code\Main Body\Generate-ComputerList.ps1"

# Text To Speach (TTS)
# Plays message when finished, if checked within options
. "$Dependencies\Code\Execution\Execute-TextToSpeach.ps1"

# The code that is to run after execution is complete
. "$Dependencies\Code\Execution\Completed-QueryExecution.ps1"

#============================================================================================================================================================
#   ____               _         _       _____                          _    _
#  / ___|   ___  _ __ (_) _ __  | |_    | ____|__  __ ___   ___  _   _ | |_ (_)  ___   _ __
#  \___ \  / __|| '__|| || '_ \ | __|   |  _|  \ \/ // _ \ / __|| | | || __|| | / _ \ | '_ \
#   ___) || (__ | |   | || |_) || |_    | |___  >  <|  __/| (__ | |_| || |_ | || (_) || | | |
#  |____/  \___||_|   |_|| .__/  \__|   |_____|/_/\_\\___| \___| \__,_| \__||_| \___/ |_| |_|
#                        |_|
#============================================================================================================================================================
$script:ProgressBarFormProgressBar.Value += 1
$script:ProgressBarSelectionForm.Refresh()

# Maintains the value of the most recent queried computers and the protocol query counts
# Used to ask if you want to conduct rpc,smb,winrm checks again if the currnet computerlist doens't match the history
$script:ComputerListHistory      = @()
$script:RpcCommandCountHistory   = $false
$script:SmbCommandCountHistory   = $false
$script:WinRmCommandCountHistory = $false

$ExecuteScriptHandler = {
    [System.Windows.Forms.Application]::UseWaitCursor = $true

    # Clears the Progress bars
    $script:ProgressBarEndpointsProgressBar.Value     = 0
    $script:ProgressBarQueriesProgressBar.Value       = 0
    $script:ProgressBarEndpointsProgressBar.BackColor = 'White'
    $script:ProgressBarQueriesProgressBar.BackColor   = 'White'

    if ($ComputerListProvideCredentialsCheckBox.Checked) { $Username = $script:Credential.UserName}
    else {$Username = $PoShEasyWinAccountLaunch }

    # Clears previous and generates new computerlist
    $script:ComputerList = @()
    Generate-ComputerList

    # Assigns the path to save the Collections to
    $script:CollectedDataTimeStampDirectory = $script:CollectionSavedDirectoryTextBox.Text
    if ($SaveDirectory) { $script:CollectedDataTimeStampDirectory = $SaveDirectory }


    $script:IndividualHostResults = "$script:CollectedDataTimeStampDirectory\Results By Endpoints"
    Sort-CommandTreeNode
    Compile-SelectedCommandTreeNode
    Count-SectionQueries


    if ($EventLogsStartTimePicker.Checked -xor $EventLogsStopTimePicker.Checked) {
        # This brings specific tabs to the forefront/front view
        $MainLeftTabControl.SelectedTab = $Section1CollectionsTab
        #$MainBottomTabControl.SelectedTab = $Section3ResultsTab
        #$MainBottomTabControl.SelectedTab = $Section3MonitorJobsTab

        [system.media.systemsounds]::Exclamation.play()
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Error: Event Log DateTime Range Error")
    }

    ####################################################
    #  Executes queries if it passes the above checks  #
    ####################################################
    else {
        # This brings specific tabs to the forefront/front view
        #$MainLeftTabControl.SelectedTab = $Section1OpNotesTab
        #$MainCenterTabControl.SelectedTab = $MainCenterMainTab
        $MainCenterTabControl.SelectedTab = $Section2StatisticsTab
            if ($MainCenterTabControl.SelectedTab -match 'Statistics') {
                $MainCenterTabControl.Width  = $FormScale * 370
                $MainCenterTabControl.Height = $FormScale * 278
            }
        $MainRightTabControl.SelectedTab  = $Section3ActionTab
        #$MainBottomTabControl.SelectedTab = $Section3ResultsTab
        #$MainBottomTabControl.SelectedTab = $Section3MonitorJobsTab
        $PoShEasyWin.Refresh()


        $CollectionTimerStart = Get-Date
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Insert(0,"$(($CollectionTimerStart).ToString('yyyy/MM/dd HH:mm:ss'))  Collection Start Time")
        $ResultsListBox.Items.Insert(0,"")

        # The number of command queries completed
        $CompletedCommandQueries = 0

        # Counts the Total Queries
        $CountCommandQueries = 0

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

        # Checks if the query/command was validated, if it was modified it will uncheck it
        if ($script:CustomQueryScriptBlockTextbox.text -ne $script:CustomQueryScriptBlockSaved) {
            $CustomQueryScriptBlockCheckBox.checked = $false
            $CustomQueryScriptBlockCheckBox.enabled = $false
        }

        # Adds section checkboxes to the command count
        if ($CustomQueryScriptBlockCheckBox.checked)                                                    { $CountCommandQueries++ ; $script:WinRMCommandCount++ }

        if ($AccountsWinRMRadioButton.Checked -and $AccountsCurrentlyLoggedInConsoleCheckbox.Checked)   { $CountCommandQueries++ ; $script:WinRMCommandCount++ }
        if ($AccountsWinRMRadioButton.Checked -and $AccountsCurrentlyLoggedInPSSessionCheckbox.Checked) { $CountCommandQueries++ ; $script:WinRMCommandCount++ }
        if ($AccountsWinRMRadioButton.Checked -and $AccountActivityCheckbox.Checked)                    { $CountCommandQueries++ ; $script:WinRMCommandCount++ }
        if ($AccountsRpcRadioButton.Checked   -and $AccountsCurrentlyLoggedInConsoleCheckbox.Checked)   { $CountCommandQueries++ ; $script:RpcCommandCount++ }
        if ($AccountsRpcRadioButton.Checked   -and $AccountsCurrentlyLoggedInPSSessionCheckbox.Checked) { $CountCommandQueries++ ; $script:RpcCommandCount++ }
        if ($AccountsRpcRadioButton.Checked   -and $AccountActivityCheckbox.Checked)                    { $CountCommandQueries++ ; $script:RpcCommandCount++ }

        if ($EventLogWinRMRadioButton.Checked -and $EventLogsEventIDsManualEntryCheckbox.Checked)       { $CountCommandQueries++ ; $script:WinRMCommandCount++ }
        if ($EventLogWinRMRadioButton.Checked -and $EventLogsEventIDsToMonitorCheckbox.Checked)         { $CountCommandQueries++ ; $script:WinRMCommandCount++ }
        if ($EventLogRpcRadioButton.Checked   -and $EventLogsEventIDsManualEntryCheckbox.Checked)       { $CountCommandQueries++ ; $script:RpcCommandCount++ }
        if ($EventLogRpcRadioButton.Checked   -and $EventLogsEventIDsToMonitorCheckbox.Checked)         { $CountCommandQueries++ ; $script:RpcCommandCount++ }
        if ($EventLogsQuickPickSelectionCheckbox.Checked) {
            foreach ($Query in $script:EventLogQueries) {
                if ($EventLogWinRMRadioButton.Checked -and $EventLogsQuickPickSelectionCheckedlistbox.CheckedItems -match $Query.Name) { $CountCommandQueries++ ; $script:WinRMCommandCount++ }
                if ($EventLogRpcRadioButton.Checked   -and $EventLogsQuickPickSelectionCheckedlistbox.CheckedItems -match $Query.Name) { $CountCommandQueries++ ; $script:RpcCommandCount++ }
            }
        }

        if ($RegistrySearchCheckbox.checked)                            { $CountCommandQueries++ ; $script:WinRMCommandCount++ }

        if ($FileSearchDirectoryListingCheckbox.Checked)                { $CountCommandQueries++ ; $script:WinRMCommandCount++ }
        if ($FileSearchFileSearchCheckbox.Checked)                      { $CountCommandQueries++ ; $script:WinRMCommandCount++ }
        if ($FileSearchAlternateDataStreamCheckbox.Checked)             { $CountCommandQueries++ ; $script:WinRMCommandCount++ }

        if ($NetworkEndpointPacketCaptureCheckBox.Checked)              { $CountCommandQueries++ ; $script:WinRMCommandCount++ }
        if ($NetworkConnectionSearchRemoteIPAddressCheckbox.checked)    { $CountCommandQueries++ ; $script:WinRMCommandCount++ }
        if ($NetworkConnectionSearchRemotePortCheckbox.checked)         { $CountCommandQueries++ ; $script:WinRMCommandCount++ }
        if ($NetworkConnectionSearchLocalPortCheckbox.checked)          { $CountCommandQueries++ ; $script:WinRMCommandCount++ }
        if ($NetworkConnectionSearchProcessCheckbox.checked)            { $CountCommandQueries++ ; $script:WinRMCommandCount++ }
        if ($NetworkConnectionSearchDNSCacheCheckbox.checked)           { $CountCommandQueries++ ; $script:WinRMCommandCount++ }

        if ($ExternalProgramsWinRMRadioButton.checked -and $SysinternalsSysmonCheckbox.Checked)                        { $CountCommandQueries++ ; $script:WinRMCommandCount++ }
        if ($ExternalProgramsWinRMRadioButton.checked -and $SysinternalsAutorunsCheckbox.Checked)                      { $CountCommandQueries++ ; $script:WinRMCommandCount++ }
        if ($ExternalProgramsWinRMRadioButton.checked -and $SysinternalsProcessMonitorCheckbox.Checked)                { $CountCommandQueries++ ; $script:WinRMCommandCount++ }
        if ($ExternalProgramsWinRMRadioButton.checked -and $ExeScriptUserSpecifiedExecutableAndScriptCheckbox.checked) { $CountCommandQueries++ ; $script:WinRMCommandCount++ }
        if ($ExternalProgramsRpcRadioButton.checked   -and $SysinternalsSysmonCheckbox.Checked)                        { $CountCommandQueries++ ; $script:RpcCommandCount++ }
        if ($ExternalProgramsRpcRadioButton.checked   -and $SysinternalsAutorunsCheckbox.Checked)                      { $CountCommandQueries++ ; $script:RpcCommandCount++ }
        if ($ExternalProgramsRpcRadioButton.checked   -and $SysinternalsProcessMonitorCheckbox.Checked)                { $CountCommandQueries++ ; $script:RpcCommandCount++ }
        if ($ExternalProgramsRpcRadioButton.checked   -and $ExeScriptUserSpecifiedExecutableAndScriptCheckbox.checked) { $CountCommandQueries++ ; $script:RpcCommandCount++ }

        $script:CommandsCheckedBoxesSelected          = $CommandsCheckedBoxesSelectedDedup
        $script:ProgressBarQueriesProgressBar.Maximum = $CountCommandQueries

        #[int]$script:RpcCommandCount + [int]$script:SmbCommandCount + [int]$script:WinRMCommandCount
        $QueryCount = $script:SectionQueryCount + $script:CommandsCheckedBoxesSelected.count

        # Adds executed commands to query history commands variable
        $script:QueryHistoryCommands += $script:CommandsCheckedBoxesSelected

        # Adds the selected commands to the Query History Command Nodes
        $QueryHistoryCategoryName = $script:CollectionSavedDirectoryTextBox.Text.Replace("$CollectedDataDirectory","").TrimStart('\')
        foreach ($Command in $script:CommandsCheckedBoxesSelected) {
            $Command | Add-Member -MemberType NoteProperty -Name CategoryName -Value $QueryHistoryCategoryName -Force
            Add-NodeCommand -RootNode $script:TreeNodePreviouslyExecutedCommands -Category $QueryHistoryCategoryName -Entry "$($Command.Name)" -ToolTip $Command.Command
        }

        # Saves the Query History to file, inlcudes other queries from past PoSh-EasyWin sessions
        $script:QueryHistory  + $script:CommandsCheckedBoxesSelected | Export-Clixml "$PoShHome\Query History.xml"
        $script:QueryHistory += $script:CommandsCheckedBoxesSelected


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
            Create-ComputerNodeCheckBoxArray

            if ((Compare-Object -ReferenceObject $script:ComputerList -DifferenceObject $script:ComputerListHistory) -or `
                   !(([bool]($script:RpcCommandCount   -gt 0) -eq [bool]$script:RpcCommandCountHistory) -and `
                     ([bool]($script:SmbCommandCount   -gt 0) -eq [bool]$script:SmbCommandCountHistory) -and `
                     ([bool]($script:WinRmCommandCount -gt 0) -eq [bool]$script:WinRmCommandCountHistory))
            ) {
                if ($script:RpcCommandCount -gt 0 ) {
                    if (Verify-Action -Title "RPC Port Check" -Question "Connecting Account:  $Username`n`nConduct a RPC Port Check to remove unresponsive endpoints?" -Computer $($script:ComputerTreeViewSelected -join ', ')) {
                        Check-Connection -CheckType "RPC Port Check" -MessageTrue "RPC Port 135 is Open" -MessageFalse "RPC Port 135 is Closed"
                        Generate-ComputerList
                    }
                }
                if ($script:SmbCommandCount -gt 0 ) {
                    if (Verify-Action -Title "SMB Port Check" -Question "Connecting Account:  $Username`n`nConduct a SMB Port Check to remove unresponsive endpoints?" -Computer $($script:ComputerTreeViewSelected -join ', ')) {
                        Check-Connection -CheckType "SMB Port Check" -MessageTrue "SMB Port 445 is Open" -MessageFalse "SMB Port 445 is Closed"
                        Generate-ComputerList
                    }
                }
                if ($script:WinRMCommandCount -gt 0 ) {
                    if (Verify-Action -Title "WinRM Check" -Question "Connecting Account:  $Username`n`nConduct a WinRM Check to remove unresponsive endpoints?" -Computer $($script:ComputerTreeViewSelected -join ', ')) {
                        Check-Connection -CheckType "WinRM Check" -MessageTrue "WinRM is Available" -MessageFalse "WinRM is Unavailable"
                        Generate-ComputerList
                    }
                }
            }
            $PoSHEasyWin.Controls.Add($ProgressBarEndpointsLabel)
            $PoSHEasyWin.Controls.Add($script:ProgressBarEndpointsProgressBar)
            $PoShEasyWin.Controls.Add($ProgressBarQueriesLabel)
            $PoSHEasyWin.Controls.Add($script:ProgressBarQueriesProgressBar)

            $script:CollectedDataTimeStampDirectory = $script:CollectionSavedDirectoryTextBox.Text
            New-Item -Type Directory -Path $script:CollectedDataTimeStampDirectory -ErrorAction SilentlyContinue

            # This executes each selected command from the Commands' TreeView
            if ($script:CommandsCheckedBoxesSelected.count -gt 0) { . "$Dependencies\Code\Execution\Individual Execution\Execute-IndividualCommands.ps1" }

            # Query Build
            if ($CustomQueryScriptBlockCheckBox.Checked) { . "$Dependencies\Code\Execution\Individual Execution\IndividualQuery-QueryBuild.ps1" }

            # Accounts Currently Logged In Console
            if ($AccountsCurrentlyLoggedInConsoleCheckbox.Checked) { . "$Dependencies\Code\Execution\Individual Execution\IndividualQuery-AccountsCurrentlyLoggedInConsole.ps1" }

            # Accounts Currently Logged In PSSession
            if ($AccountsCurrentlyLoggedInPSSessionCheckbox.Checked) { . "$Dependencies\Code\Execution\Individual Execution\IndividualQuery-AccountsCurrentlyLoggedInPSSession.ps1" }

            # Account Logon Activity
            if ($AccountActivityCheckbox.Checked) { . "$Dependencies\Code\Execution\Individual Execution\IndividualQuery-AccountLogonActivity.ps1" }

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
            if ($FileSearchDirectoryListingCheckbox.Checked) { . "$Dependencies\Code\Execution\Individual Execution\IndividualQuery-FileSearchDirectoryListing.ps1" ; $RetrieveFilesButton.BackColor = 'LightGreen' }

            # File Search
            # Combines the inputs from the various GUI fields to query for filenames and/or file hashes
            if ($FileSearchFileSearchCheckbox.Checked) { . "$Dependencies\Code\Execution\Individual Execution\IndividualQuery-FileSearchFileSearch.ps1" ; $RetrieveFilesButton.BackColor = 'LightGreen' }

            # Alternate Data Streams
            # Combines the inputs from the various GUI fields to query for Alternate Data Streams
            if ($FileSearchAlternateDataStreamCheckbox.Checked) { . "$Dependencies\Code\Execution\Individual Execution\IndividualQuery-FileSearchAlternateDataStream.ps1" ; $RetrieveFilesButton.BackColor = 'LightGreen' }

            # Endpoint Packet Capture
            # Conducts a packet capture on the endpoints using netsh
            if ($NetworkEndpointPacketCaptureCheckBox.Checked) { . "$Dependencies\Code\Execution\Individual Execution\IndividualCapture-EndpointPacketCapture.ps1" }

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

            # User Specified Files and Custom Script
            # Pushes user Specified Files and Custom Script to the endpoints
            # The script has to manage all the particulars with the executable; execution, results retrieval, cleanup, etc.
            if ($ExeScriptUserSpecifiedExecutableAndScriptCheckbox.checked) { . "$Dependencies\Code\Execution\Individual Execution\IndividualPush-ExecutableAndScript.ps1" }

            Completed-QueryExecution
        }

        if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs' ) {
            Conduct-IndividualExecution
        }

<# DEPRECATED
        if ($EventLogRPCRadioButton.checked -or $ExternalProgramsRPCRadioButton.checked -or $AccountsRPCRadioButton.checked) { $script:RpcCommandCount += 1 }

        if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs' -and ($script:RpcCommandCount -eq 0 -or $script:SmbCommandCount -eq 0) ) {

            if ($script:WinRMCommandCount -gt 1) {
                $MessageBox = [System.Windows.Forms.MessageBox]::Show("Multiple WinRM based commands were selected.
Consider swtiching to 'Session Based' mode.
Pros:
   - The local processor and memory requirements are less
   - There are less network connections - not as noisy
Cons:
   - Timeout feature is not available 
   - The monitor jobs feature won't provide status updates
   - Some queries or actions will display fewer or no updates",
"Change to Session Based Collection",'YesNoCancel','Info')
                Switch ( $MessageBox ) {
                    'Yes' {
                        $script:CommandTreeViewQueryMethodSelectionComboBox.SelectedIndex = 1
                        Invoke-Command -ScriptBlock $ExecuteScriptHandler
                        $script:CommandTreeViewQueryMethodSelectionComboBox.SelectedIndex = 0
                        break
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
            else { Conduct-IndividualExecution }
        }
DEPRECATED #>


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


        elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Compiled Script' ) {
            $ExecutionStartTime = Get-Date
            Generate-ComputerList

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
                $CommandReviewEditForm = New-Object System.Windows.Forms.Form -Property @{
                    width         = $FormScale * 1025
                    height        = $FormScale * 525
                    StartPosition = "CenterScreen"
                    Text          = �Collection Script - Review, Edit, and Verify�
                    Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
                    ControlBox    = $true
                    Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                    Add_Closing = { $This.dispose() }
                }

                    $CommandReviewEditLabel = New-Object System.Windows.Forms.Label -Property @{
                        Text      = "Edit The Script Block:"
                        Location  = @{ X = $FormScale * 5
                                       Y = $FormScale * 8 }
                        Size      = @{ Height = $FormScale * 25
                                       Width  = $FormScale * 160 }
                        ForeColor = "Blue"
                        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 14),0,0,0)
                    }
                    $CommandReviewEditForm.Controls.Add($CommandReviewEditLabel)


                    $CommandReviewEditEnabledRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                        Text      = "Yes"
                        Location  = @{ X = $FormScale * $CommandReviewEditLabel.Location.X + $CommandReviewEditLabel.Size.Width + 20
                                       Y = $FormScale * 5 }
                        Size      = @{ Height = $FormScale * 25
                                       Width  = $FormScale * 50 }
                        Checked   = $false
                        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
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


                    $CommandReviewEditDisabledRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                        Text     = "No"
                        Location = @{ X = $FormScale * $CommandReviewEditEnabledRadioButton.Location.X + $CommandReviewEditEnabledRadioButton.Size.Width + 10
                                      Y = $FormScale * 5 }
                        Size     = @{ Height = $FormScale * 25
                                      Width  = $FormScale * 50 }
                        Checked  = $true
                        Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                        Add_Click = {
                            $script:CommandReviewEditRichTextbox.BackColor = 'LightGray'
                            $script:CommandReviewEditRichTextbox.ReadOnly  = $True
                        }
                        Add_MouseHover = {
                            Show-ToolTip -Title "Disable Script Editing" -Icon "Info" -Message @"
+  The script below is generated by the selections made.
+  Use caustion if editing, charts use the hashtable name field.
"@                      }
                    }
                    $CommandReviewEditForm.Controls.Add($CommandReviewEditDisabledRadioButton)


                    $CommandReviewReloadNormalRawButton = New-Object System.Windows.Forms.Button -Property @{
                        Text      = "Reload Script (Raw)"
                        Location  = @{ X = $FormScale * $CommandReviewEditDisabledRadioButton.Location.X + $CommandReviewEditDisabledRadioButton.Size.Width + 25
                                    Y = $FormScale * 7 }
                        Size      = @{ Height = $FormScale * 22
                                    Width  = $FormScale * 175 }
                        Add_MouseHover = {
                            Show-ToolTip -Title "Reload Script - Normal" -Icon "Info" -Message @"
+  When command treenode scripts are selected, they may load without return carriages depending on how they were created/formatted
+  To mitigate this, you can reload to get the scirpt's content normally or in a raw format
"@                      }
                        Add_Click = {
                            if ($CommandReviewReloadNormalRawButton.Text -eq "Reload Script (Raw)") {
                                Compile-QueryCommands -raw
                                $CommandReviewReloadNormalRawButton.Text = "Reload Script (Normal)"
                            }
                            else {
                                Compile-QueryCommands
                                $CommandReviewReloadNormalRawButton.Text = "Reload Script (Raw)"
                            }
                            Buffer-CommandReviewString
                        }
                    }
                    CommonButtonSettings -Button $CommandReviewReloadNormalRawButton
                    $CommandReviewEditForm.Controls.Add($CommandReviewReloadNormalRawButton)


                    $CommandReviewScriptBlockByteCountTextbox = New-Object System.Windows.Forms.TextBox -Property @{
                        Location  = @{ X = $FormScale * $CommandReviewReloadNormalRawButton.Location.X + $CommandReviewReloadNormalRawButton.Size.Width + 25
                                       Y = $FormScale * 7 }
                        Size      = @{ Height = $FormScale * 22
                                       Width  = $FormScale * 100 }
                    }
                    $CommandReviewEditForm.Controls.Add($CommandReviewScriptBlockByteCountTextbox)


                    $CommandReviewEditVerifyCheckbox = New-Object System.Windows.Forms.Checkbox -Property @{
                        Text      = 'Verify'
                        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 14),0,0,0)
                        Location  = @{ X = $FormScale * 790
                                    Y = $FormScale * 6 }
                        Size      = @{ Height = $FormScale * 26
                                    Width  = $FormScale * 75 }
                        Checked   = $false
                        Add_Click = {
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
                        }
                    }

                    $CommandReviewEditForm.Controls.Add($CommandReviewEditVerifyCheckbox)


                    $CommandReviewEditExecuteButton = New-Object System.Windows.Forms.Button -Property @{
                        Text      = "Cancel"
                        Location  = @{ X = $FormScale * 879
                                    Y = $FormScale * 5 }
                        Size      = @{ Height = $FormScale * 25
                                    Width  = $FormScale * 100 }
                        Add_Click = {
                            $script:CommandReviewEditRichTextbox.SaveFile("C:\Richtext_RTF.rtf")
                            $CommandReviewEditForm.close()
                        }
                        Add_MouseHover = {
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
"@                      }
                    }
                    CommonButtonSettings -Button $CommandReviewEditExecuteButton
                    $CommandReviewEditForm.Controls.Add($CommandReviewEditExecuteButton)


                    $script:CommandReviewEditRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
                        Location = @{ X = $FormScale * 5
                                      Y = $FormScale * 35 }
                        Size     = @{ Height = $FormScale * 422
                                      Width  = $FormScale * 974 }
                        Font       = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
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

        elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Session Based' -and $script:RpcCommandCount -eq 0 -and $script:SmbCommandCount -eq 0 ) {
            $MainBottomTabControl.SelectedTab = $Section3ResultsTab

            $ExecutionStartTime = Get-Date
            Generate-ComputerList
            Compile-QueryCommands

            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("Attempting to Establish Sessions to $($script:ComputerList.Count) Endpoints")
            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Attempting to Establish Sessions to $($script:ComputerList.Count) Endpoints"
            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "[!] $($script:ComputerList -join ', ')"

            $PoSHEasyWin.Controls.Add($ProgressBarEndpointsLabel)
            $PoSHEasyWin.Controls.Add($script:ProgressBarEndpointsProgressBar)
            $PoShEasyWin.Controls.Add($ProgressBarQueriesLabel)
            $PoSHEasyWin.Controls.Add($script:ProgressBarQueriesProgressBar)

            $script:CollectedDataTimeStampDirectory = $script:CollectionSavedDirectoryTextBox.Text
            New-Item -Type Directory -Path $script:CollectedDataTimeStampDirectory -ErrorAction SilentlyContinue

            if (Verify-Action -Title "Session Query Verification" -Question "Connecting Account:  $Username`n`nNumber of Queries:  $($QueryCount)`n`nEndpoints:" -Computer $($script:ComputerList -join ', ')) {
                if ($ComputerListProvideCredentialsCheckBox.Checked) {
                    if (!$script:Credential) { Create-NewCredentials }
                    $PSSession = New-PSSession -ComputerName $script:ComputerList -Credential $script:Credential | Sort-Object ComputerName
                }
                else {
                    $PSSession = New-PSSession -ComputerName $script:ComputerList | Sort-Object ComputerName
                }

                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Session Based Collection Started to $(($PSSession | Where-Object {$_.state -match 'open'}).count) Endpoints"
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "New-PSSession -ComputerName $(($PSSession | Where-Object {$_.state -match 'open'}).ComputerName -join ', ')"

                # Unchecks hosts that do not have a session established
                . "$Dependencies\Code\Execution\Session Based\Uncheck-ComputerTreeNodesWithoutSessions.ps1"
            }

            if ($PSSession.count -eq 1) {
                $ResultsListBox.Items.Insert(1,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  Session Created to $(($PSSession | Where-Object {$_.state -match 'open'}).count) Endpoint")
            }
            elseif ($PSSession.count -gt 1) {
                $ResultsListBox.Items.Insert(1,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  Sessions Created to $(($PSSession | Where-Object {$_.state -match 'open'}).count) Endpoints")
            }
            else {
                $ResultsListBox.Items.Insert(1,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  No Sessions Created")
                [system.media.systemsounds]::Exclamation.play()
            }
            $PoShEasyWin.Refresh()

            $script:ProgressBarQueriesProgressBar.Maximum   = $CountCommandQueries
            $script:ProgressBarEndpointsProgressBar.Maximum = ($PSSession.ComputerName).Count


            if ($PSSession.count -ge 1) {
                New-Item -ItemType Directory -Path "$($script:CollectionSavedDirectoryTextBox.Text)" -Force

                # Individual Queries
                if ($script:CommandsCheckedBoxesSelected.count -gt 0) { . "$Dependencies\Code\Execution\Session Based\SessionQuery-IndividualQueries.ps1" }

                # Query Build
                if ($CustomQueryScriptBlockCheckBox.Checked) { . "$Dependencies\Code\Execution\Session Based\SessionQuery-QueryBuild.ps1" }

                # Accounts Currently Logged In Console
                if ($AccountsCurrentlyLoggedInConsoleCheckbox.Checked) { . "$Dependencies\Code\Execution\Session Based\SessionQuery-AccountsCurrentlyLoggedInConsole.ps1" }

                # Accounts Currently Logged In PSSession
                if ($AccountsCurrentlyLoggedInPSSessionCheckbox.Checked) { . "$Dependencies\Code\Execution\Session Based\SessionQuery-AccountsCurrentlyLoggedInPSSession.ps1" }

                # Account Logon Activity
                if ($AccountActivityCheckbox.Checked) { . "$Dependencies\Code\Execution\Session Based\SessionQuery-AccountLogonActivity.ps1" }

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

                # Endpoint Packet Capture
                # Conducts a packet capture on the endpoints using netsh
                if ($NetworkEndpointPacketCaptureCheckBox.Checked) { . "$Dependencies\Code\Execution\Session Based\SessionQuery-EndpointPacketCapture.ps1" }

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

                # User Specified Files and Custom Script
                # Pushes user Specified Files and Custom Script to the endpoints
                # The script has to manage all the particulars with the executable; execution, results retrieval, cleanup, etc.
                if ($ExeScriptUserSpecifiedExecutableAndScriptCheckbox.checked) { . "$Dependencies\Code\Execution\Session Based\SessionPush-ExecutableAndScript.ps1" }

                ######################################
                # End of Session Based Querying
                ######################################
                Get-ChildItem -Path "$($script:CollectionSavedDirectoryTextBox.Text)\*.csv" | Where-Object Length -eq 0 | Remove-Item -Force

                Get-PSSession | Remove-PSSession
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Remove-PSSession -ComputerName $($PSSession.ComputerName -join ', ')"

                $ResultsListBox.Items.Insert(0,'')
                if     ($PSSession.count -eq 1) { $ResultsListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  Session Removed to $($PSSession.count) Endpoint") }
                elseif ($PSSession.count -gt 1) { $ResultsListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  Sessions Removed to $($PSSession.count) Endpoints") }
                $PoShEasyWin.Refresh()

                Completed-QueryExecution
            }
        }
    }

    $MainCenterTabControl.SelectedTab = $MainCenterMainTab
    if ($MainCenterTabControl.SelectedTab -match 'Main') {
        $MainCenterTabControl.Width  = $FormScale * 370
        $MainCenterTabControl.Height = $FormScale * 278
    }
    $PoShEasyWin.Refresh()

    [System.Windows.Forms.Application]::UseWaitCursor = $false
}
$script:ProgressBarFormProgressBar.Value += 1
$script:ProgressBarSelectionForm.Refresh()

# Selects the computers to query using command line parameters and arguments
. "$Dependencies\Code\Execution\Command Line\Select-ComputersAndCommandsFromCommandLine.ps1"

# This needs to be here to execute the script
# Note the Execution button itself is located in the Select Computer section
$script:ComputerListExecuteButton.Add_Click($ExecuteScriptHandler)

<# --Potential code to deprecate
# Correct the initial state of the form to prevent the .Net maximized form issue
#$InitialFormWindowState     = New-Object System.Windows.Forms.FormWindowState
#$OnLoadForm_StateCorrection = { $PoShEasyWin.WindowState = $InitialFormWindowState }

#Save the initial state of the form
#$InitialFormWindowState = $PoShEasyWin.WindowState

#Init the OnLoad event to correct the initial state of the form
#$PoShEasyWin.add_Load($OnLoadForm_StateCorrection)
#>

#Show the Form
$script:ProgressBarFormProgressBar.Value = 40
Start-Sleep -Seconds 1
$script:ProgressBarSelectionForm.Hide()

# Shows the GUI
$PoShEasyWin.ShowDialog() | Out-Null

} # END for $ScriptBlockForGuiLoadAndProgressBar

$ScriptBlockProgressBarInput = {
    $script:ProgressBarMainLabel.text = "Please Be Patient As The GUI Loads
Download at: https://GitHub.com/high101bro
"

    $script:ProgressBarMessageLabel.text = "PowerShell - Endpoint Analysis Solution Your Windows Intranet Needs!"
    $script:ProgressBarSelectionForm.Refresh()

    $script:ProgressBarFormProgressBar.Value   = 0
    $script:ProgressBarFormProgressBar.Maximum = 40

    Invoke-command $ScriptBlockForGuiLoadAndProgressBar
}

if ((Test-Path "$PoShHome\Settings\User Notice And Acknowledgement.txt")) {
    Launch-ProgressBarForm -FormTitle "PoSh-EasyWin  [$InitialScriptLoadTime]" -ShowImage -ScriptBlockProgressBarInput $ScriptBlockProgressBarInput
}





