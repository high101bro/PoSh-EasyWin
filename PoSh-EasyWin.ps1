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
    Version        : v.5.1.8 Beta

    Requirements   : PowerShell v3.0 - Splatting Arguments
                                     - PowerShell Charts support
                                v4.0 - The use of Copy-Item -Session
                                v5.1 - PSWriteHTML Module support
                   : WinRM   HTTP    - TCP/5985 Windows 7+ ( 80 Vista-)
                             HTTPS   - TCP/5986 Windows 7+ (443 Vista-)
                             Endpoint Listener - TCP/47001
                   : DCOM    RPC     - TCP/135 and dynamic ports, typically:
                                       TCP 49152-65535 (Windows Vista, Server 2008 and above)
                                       TCP 1024 -65535 (Windows NT4, Windows 2000, Windows 2003)
    Optional       : PsExec.exe, Procmon.exe, Autoruns.exe, Sysmon.exe,
                     etl2pcapng.exe, WinPmem.exe

    Updated        : 11 Dec 2020
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
        else               { Start-Process PowerShell.exe -Verb runAs -ArgumentList $ThisScript -WindowStyle Hidden -NonInteractive }
        exit
    }
    'No' {
        if ($ShowTerminal) { Start-Process PowerShell.exe -ArgumentList "$ThisScript -SkipEvelationCheck" }
        else               { Start-Process PowerShell.exe -ArgumentList "$ThisScript -SkipEvelationCheck" -WindowStyle Hidden -NonInteractive }
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


###############
#
###############

#Start Progress bar form loading
$global:ScriptBlockForGuiLoadAndProgressBar = {
    

function Update-FormProgress {
    param(
        [string]$ScriptPath = '...'
    )
    $StatusDescription = $ScriptPath | Split-Path -Leaf
    # NOTE!!! Apparently there are usues with scope when dot sourcing within a function
    #if ($ScriptPath -ne '...') {
    #    # Loads the script using the Dot Sourcing method
    #    . $ScriptPath
    #}
    $script:ProgressBarMainLabel.text = "Download at: https://GitHub.com/high101bro
Loading: $StatusDescription"
    $script:ProgressBarMainLabel.Refresh()
    $script:ProgressBarFormProgressBar.Value += 1
    $script:ProgressBarSelectionForm.Refresh()
}
    

# Launches the accompanying Notifications Icon helper in the  System Tray
Update-FormProgress "$Dependencies\Code\Main Body\Launch-SystemTrayNotifyIcon.ps1"
. "$Dependencies\Code\Main Body\Launch-SystemTrayNotifyIcon.ps1"


# The Launch-ProgressBarForm.ps1 is topmost upon loading to ensure it's displayed intially, but is then able to be move unpon
$ResolutionCheckForm.topmost = $false


$PoShEasyWinAccountLaunch = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
#[System.Windows.Forms.Application]::EnableVisualStyles()
$PoShEasyWin = New-Object System.Windows.Forms.Form -Property @{
    Text          = "PoSh-EasyWin   ($PoShEasyWinAccountLaunch)  [$InitialScriptLoadTime]"
    StartPosition = "CenterScreen"
    Width  = $FormScale * 1260
    Height = $FormScale * 660
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
Update-FormProgress "$Dependencies\Code\Execution\Enumeration\Import-HostsFromDomain.ps1"
. "$Dependencies\Code\Execution\Enumeration\Import-HostsFromDomain.ps1"

# Provides messages when hovering over various areas in the GUI
Update-FormProgress "$Dependencies\Code\Main Body\Show-ToolTip.ps1"
. "$Dependencies\Code\Main Body\Show-ToolTip.ps1"


#============================================================================================================================================================
#    _____       _       ____               _                _
#   |_   _|__ _ | |__   / ___| ___   _ __  | |_  _ __  ___  | |
#     | | / _` || '_ \ | |    / _ \ | '_ \ | __|| '__|/ _ \ | |
#     | || (_| || |_) || |___| (_) || | | || |_ | |  | (_) || |
#     |_| \__,_||_.__/  \____|\___/ |_| |_| \__||_|   \___/ |_|
#
#============================================================================================================================================================

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


$TabRightPosition     = 3
$TabhDownPosition     = 3
$TabAreaWidth         = 446
$TabAreaHeight        = 557
$TextBoxRightPosition = -2
$TextBoxDownPosition  = -2
$TextBoxWidth         = 442
$TextBoxHeight        = 536


#============================================================================================================================================================
#    _____       _       ____               _                _
#   |_   _|__ _ | |__   / ___| ___   _ __  | |_  _ __  ___  | |
#     | | / _` || '_ \ | |    / _ \ | '_ \ | __|| '__|/ _ \ | |
#     | || (_| || |_) || |___| (_) || | | || |_ | |  | (_) || |
#     |_| \__,_||_.__/  \____|\___/ |_| |_| \__||_|   \___/ |_|
#
#============================================================================================================================================================

# Collections Tab
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Collections.ps1"
. "$Dependencies\Code\Main Body\Tabs\Collections.ps1"

# Interactions Tab
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Interactions.ps1"
. "$Dependencies\Code\Main Body\Tabs\Interactions.ps1"

# Enumeration Tab
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Enumeration.ps1"
. "$Dependencies\Code\Main Body\Tabs\Enumeration.ps1"

# Checklists Tab
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Checklists.ps1"
. "$Dependencies\Code\Main Body\Tabs\Checklists.ps1"

### DEPRECATED ###
# Processes Tab 
#. "$Dependencies\Code\Main Body\Tabs\Processes.ps1"
### DEPRECATED ###

# OpNotes Tab
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\OpNotes.ps1"
. "$Dependencies\Code\Main Body\Tabs\OpNotes.ps1"

# Info Tab
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Info.ps1"
. "$Dependencies\Code\Main Body\Tabs\Info.ps1"


#============================================================================================================================================================
#    _____       _       ____               _                _
#   |_   _|__ _ | |__   / ___| ___   _ __  | |_  _ __  ___  | |
#     | | / _` || '_ \ | |    / _ \ | '_ \ | __|| '__|/ _ \ | |
#     | || (_| || |_) || |___| (_) || | | || |_ | |  | (_) || |
#     |_| \__,_||_.__/  \____|\___/ |_| |_| \__||_|   \___/ |_|
#
#============================================================================================================================================================

Update-FormProgress "$Dependencies\Code\System.Windows.Forms\TabControl\Section2TabControl.ps1"
. "$Dependencies\Code\System.Windows.Forms\TabControl\Section2TabControl.ps1"
$MainCenterTabControl = New-Object System.Windows.Forms.TabControl -Property @{
    Left   = $FormScale * 470
    Top    = $FormScale * 5
    Width  = $FormScale *  370
    Height = $FormScale * 278 
    SelectedIndex  = 0
    ShowToolTips   = $True
    Font           = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click      = $MainCenterTabControlAdd_Click
    Add_MouseHover = $MainCenterTabControlAdd_MouseHover
}
$PoShEasyWin.Controls.Add($MainCenterTabControl)


# Main Tab
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Main Tab.ps1"
. "$Dependencies\Code\Main Body\Tabs\Main Tab.ps1"

# Options Tab
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Options.ps1"
. "$Dependencies\Code\Main Body\Tabs\Options.ps1"

# Statistics Tab
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Statistics.ps1"
. "$Dependencies\Code\Main Body\Tabs\Statistics.ps1"


#============================================================================================================================================================
#============================================================================================================================================================
# ComputerList Treeview Section
#============================================================================================================================================================
#============================================================================================================================================================

$Column4RightPosition = 845

# Initial load of CSV data
$script:ComputerTreeViewData = $null
$script:ComputerTreeViewData = Import-Csv $ComputerTreeNodeFileSave -ErrorAction SilentlyContinue #| Select-Object -Property Name, OperatingSystem, CanonicalName, IPv4Address, MACAddress, Notes
#$script:ComputerTreeViewData

# Saves the textbox data for Host Data
Update-FormProgress "$Dependencies\Code\Main Body\Save-HostData.ps1"
. "$Dependencies\Code\Main Body\Save-HostData.ps1"

# Initializes the Computer TreeView section that computer nodes are added to
# TreeView initialization initially happens upon load and whenever the it is regenerated, like when switching between views
# These include the root nodes of Search, and various Operating System and OU/CN names
Update-FormProgress "$Dependencies\Code\Tree View\Computer\Initialize-ComputerTreeNodes.ps1"
. "$Dependencies\Code\Tree View\Computer\Initialize-ComputerTreeNodes.ps1"

# If Computer treenodes are imported/created with missing data, this populates various fields with default data
Update-FormProgress "$Dependencies\Code\Tree View\Computer\Populate-ComputerTreeNodeDefaultData.ps1"
. "$Dependencies\Code\Tree View\Computer\Populate-ComputerTreeNodeDefaultData.ps1"

# This will keep the Computer TreeNodes checked when switching between OS and OU/CN views
Update-FormProgress "$Dependencies\Code\Tree View\Computer\Update-TreeNodeComputerState.ps1"
. "$Dependencies\Code\Tree View\Computer\Update-TreeNodeComputerState.ps1"

# Adds a treenode to the specified root node... a computer node within a category node
Update-FormProgress "$Dependencies\Code\Tree View\Computer\Add-NodeComputer.ps1"
. "$Dependencies\Code\Tree View\Computer\Add-NodeComputer.ps1"

$script:ComputerTreeViewSelected = ""

# Populate Auto Tag List used for Host Data tagging and Searching
$TagListFileContents = Get-Content -Path $TagAutoListFile

# Searches for Computer nodes that match a given search entry
# A new category node named by the search entry will be created and all results will be nested within
Update-FormProgress "$Dependencies\Code\Tree View\Computer\Search-ComputerTreeNode.ps1"
. "$Dependencies\Code\Tree View\Computer\Search-ComputerTreeNode.ps1"


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\ComboBox\ComputerTreeNodeSearchComboBox.ps1"
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


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\ComputerTreeNodeSearchButton.ps1"
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
Update-FormProgress "$Dependencies\Code\Tree View\Computer\Remove-EmptyCategory.ps1"
. "$Dependencies\Code\Tree View\Computer\Remove-EmptyCategory.ps1"
Remove-EmptyCategory


# Context menu button code
Update-FormProgress "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListCollapseToolStripButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListCollapseToolStripButton.ps1"
Update-FormProgress "$Dependencies\Code\Tree View\Computer\Message-HostAlreadyExists.ps1"
. "$Dependencies\Code\Tree View\Computer\Message-HostAlreadyExists.ps1"
Update-FormProgress "$Dependencies\Code\Tree View\Computer\AddHost-ComputerTreeNode.ps1"
. "$Dependencies\Code\Tree View\Computer\AddHost-ComputerTreeNode.ps1"
Update-FormProgress "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListAddEndpointToolStripButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListAddEndpointToolStripButton.ps1"
Update-FormProgress "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListDeselectAllToolStripButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListDeselectAllToolStripButton.ps1"
Update-FormProgress "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListNSLookupCheckedToolStripButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListNSLookupCheckedToolStripButton.ps1"
Update-FormProgress "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListTagToolStripButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListTagToolStripButton.ps1"
Update-FormProgress "$Dependencies\Code\Tree View\Computer\Move-ComputerTreeNodeSelected.ps1"
. "$Dependencies\Code\Tree View\Computer\Move-ComputerTreeNodeSelected.ps1"
Update-FormProgress "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListMoveToolStripButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListMoveToolStripButton.ps1"
Update-FormProgress "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListDeleteToolStripButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListDeleteToolStripButton.ps1"
Update-FormProgress "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListRenameToolStripButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListRenameToolStripButton.ps1"
Update-FormProgress "$Dependencies\Code\Execution\Action\Check-Connection.ps1"
. "$Dependencies\Code\Execution\Action\Check-Connection.ps1"
Update-FormProgress "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListPingToolStripButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListPingToolStripButton.ps1"
Update-FormProgress "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListRPCCheckToolStripButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListRPCCheckToolStripButton.ps1"
Update-FormProgress "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListSMBCheckToolStripButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListSMBCheckToolStripButton.ps1"
Update-FormProgress "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListWinRMCheckToolStripButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListWinRMCheckToolStripButton.ps1"


# Code for the Context Menu
# This context menu is the one activeated when you click within the computer treeview area, but not when clicking on a computer ndoe itself
Update-FormProgress "$Dependencies\Code\Context Menu Strip\Display-ContextMenuForComputerTreeView.ps1"
. "$Dependencies\Code\Context Menu Strip\Display-ContextMenuForComputerTreeView.ps1"


# This context menu is the one activeated when you click on the computer node itself within the computer treeview
# It is also activated within the Conduct-NodeAction function
Update-FormProgress "$Dependencies\Code\Context Menu Strip\Display-ContextMenuForComputerTreeNode.ps1"
. "$Dependencies\Code\Context Menu Strip\Display-ContextMenuForComputerTreeNode.ps1"
Display-ContextMenuForComputerTreeNode

# Ref Guide: https://info.sapien.com/index.php/guis/gui-controls/spotlight-on-the-contextmenustrip-control
Update-FormProgress "$Dependencies\Code\System.Windows.Forms\TreeView\ComputerTreeView.ps1"
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


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RadioButton\ComputerTreeNodeOSHostnameRadioButton.ps1"
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


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RadioButton\ComputerTreeNodeOUHostnameRadioButton.ps1"
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
#    _____       _       ____               _                _
#   |_   _|__ _ | |__   / ___| ___   _ __  | |_  _ __  ___  | |
#     | | / _` || '_ \ | |    / _ \ | '_ \ | __|| '__|/ _ \ | |
#     | || (_| || |_) || |___| (_) || | | || |_ | |  | (_) || |
#     |_| \__,_||_.__/  \____|\___/ |_| |_| \__||_|   \___/ |_|
#
#============================================================================================================================================================

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


# Action Tab
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Action.ps1"
. "$Dependencies\Code\Main Body\Tabs\Action.ps1"

# Manage Tab
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Manage.ps1"
. "$Dependencies\Code\Main Body\Tabs\Manage.ps1"


#============================================================================================================================================================
#    _____       _       ____               _                _
#   |_   _|__ _ | |__   / ___| ___   _ __  | |_  _ __  ___  | |
#     | | / _` || '_ \ | |    / _ \ | '_ \ | __|| '__|/ _ \ | |
#     | || (_| || |_) || |___| (_) || | | || |_ | |  | (_) || |
#     |_| \__,_||_.__/  \____|\___/ |_| |_| \__||_|   \___/ |_|
#
#============================================================================================================================================================

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

# About Tab
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\About.ps1"
. "$Dependencies\Code\Main Body\Tabs\About.ps1"

# Results Tab
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Results.ps1"
. "$Dependencies\Code\Main Body\Tabs\Results.ps1"

# Monitor Jobs Tab
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Monitor Jobs.ps1"
. "$Dependencies\Code\Main Body\Tabs\Monitor Jobs.ps1"

# Endpoint Data Tab
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Endpoint Data.ps1"
. "$Dependencies\Code\Main Body\Tabs\Endpoint Data.ps1"

# Query Exploration Tab
Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Query Exploration.ps1"
. "$Dependencies\Code\Main Body\Tabs\Query Exploration.ps1"


##########################################################################
##########################################################################
##########################################################################

# Charts - Convert CSV Number Strings To Intergers
Update-FormProgress "$Dependencies\Code\Charts\Convert-CsvNumberStringsToIntergers.ps1"
. "$Dependencies\Code\Charts\Convert-CsvNumberStringsToIntergers.ps1"

# Checks and compiles selected command treenode to be execute
# Those checked are either later executed individually or compiled
Update-FormProgress "$Dependencies\Code\Tree View\Command\Compile-SelectedCommandTreeNode.ps1"
. "$Dependencies\Code\Tree View\Command\Compile-SelectedCommandTreeNode.ps1"

# Allows you to search the any number of registry paths for key names, value names, and value data.
Update-FormProgress "$Dependencies\Code\Execution\Search-Registry.ps1"
. "$Dependencies\Code\Execution\Search-Registry.ps1"

# Searches for network connections that match provided IPs, Ports, or network connections started by specific process names
# Required for Query-NetworkConnectionRemoteIPAddress, Query-NetworkConnectionRemotePort, and Query-NetworkConnectionProcess
Update-FormProgress "$Dependencies\Code\Execution\Query-NetworkConnection.ps1"
. "$Dependencies\Code\Execution\Query-NetworkConnection.ps1"

# Compiles the .csv files in the collection directory then saves the combined file to the partent directory
# The first line (collumn headers) is only copied once from the first file compiled, then skipped for the rest
Update-FormProgress "$Dependencies\Code\Execution\Compile-CsvFiles.ps1"
. "$Dependencies\Code\Execution\Compile-CsvFiles.ps1"

# Compiles the .xml files in the collection directory then saves the combined file to the partent directory
Update-FormProgress "$Dependencies\Code\Execution\Compile-XmlFiles.ps1"
. "$Dependencies\Code\Execution\Compile-XmlFiles.ps1"

# Removes Duplicate CSV Headers
Update-FormProgress "$Dependencies\Code\Execution\Individual Execution\Remove-DuplicateCsvHeaders.ps1"
. "$Dependencies\Code\Execution\Individual Execution\Remove-DuplicateCsvHeaders.ps1"

# This is one of the core scripts that handles how queries are conducted
# It monitors started PoSh-EasyWin jobs and updates the GUI
Update-FormProgress "$Dependencies\Code\Execution\Individual Execution\Monitor-Jobs.ps1"
. "$Dependencies\Code\Execution\Individual Execution\Monitor-Jobs.ps1"

# Common code that runs after jobs have completed that updates the GUI, Compiles files (csv & xml), and logs
Update-FormProgress "$Dependencies\Code\Execution\Individual Execution\Post-MonitorJobs.ps1"
. "$Dependencies\Code\Execution\Individual Execution\Post-MonitorJobs.ps1"

# If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
Update-FormProgress "$Dependencies\Code\Execution\Individual Execution\Conduct-PreCommandCheck.ps1"
. "$Dependencies\Code\Execution\Individual Execution\Conduct-PreCommandCheck.ps1"

# Event Logs Search
# Combines the inputs from the various GUI fields to query for event logs; fields such as
# event codes/IDs entered, time range, and max amount
# Uses 'Get-WmiObject -Class Win32_NTLogEvent'
Update-FormProgress "$Dependencies\Code\Execution\Individual Execution\Query-EventLog.ps1"
. "$Dependencies\Code\Execution\Individual Execution\Query-EventLog.ps1"

# Searches for registry key names, value names, and value data
# Uses input from GUI to query the registry
Update-FormProgress "$Dependencies\Code\Execution\Individual Execution\Query-Registry.ps1"
. "$Dependencies\Code\Execution\Individual Execution\Query-Registry.ps1"

# Provides $script:SectionQueryCount variable data
Update-FormProgress "$Dependencies\Code\Execution\Count-SectionQueries.ps1"
. "$Dependencies\Code\Execution\Count-SectionQueries.ps1"

# Generate list of endpoints to query
Update-FormProgress "$Dependencies\Code\Main Body\Generate-ComputerList.ps1"
. "$Dependencies\Code\Main Body\Generate-ComputerList.ps1"

# Text To Speach (TTS)
# Plays message when finished, if checked within options
Update-FormProgress "$Dependencies\Code\Execution\Execute-TextToSpeach.ps1"
. "$Dependencies\Code\Execution\Execute-TextToSpeach.ps1"

# The code that is to run after execution is complete
Update-FormProgress "$Dependencies\Code\Execution\Completed-QueryExecution.ps1"
. "$Dependencies\Code\Execution\Completed-QueryExecution.ps1"

#============================================================================================================================================================
#   ____               _         _       _____                          _    _
#  / ___|   ___  _ __ (_) _ __  | |_    | ____|__  __ ___   ___  _   _ | |_ (_)  ___   _ __
#  \___ \  / __|| '__|| || '_ \ | __|   |  _|  \ \/ // _ \ / __|| | | || __|| | / _ \ | '_ \
#   ___) || (__ | |   | || |_) || |_    | |___  >  <|  __/| (__ | |_| || |_ | || (_) || | | |
#  |____/  \___||_|   |_|| .__/  \__|   |_____|/_/\_\\___| \___| \__,_| \__||_| \___/ |_| |_|
#                        |_|
#============================================================================================================================================================
Update-FormProgress "Script Execution"

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

    # Location of Uncompiled Results
    $script:IndividualHostResults = "$script:CollectedDataTimeStampDirectory\Results By Endpoints"

    # This function compiles the selected treeview comamnds, placing the proper command type and protocol into a variable list to be executed.
    Compile-SelectedCommandTreeNode

    # Counts the section queries and assigns value to the $script:SectionQueryCount variable
    Count-SectionQueries

    if ($script:EventLogsStartTimePicker.Checked -xor $script:EventLogsStopTimePicker.Checked) {
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

        # Verifies that the command is only present once. Prevents running the multiple copies of the same comand, line from using the Custom Group Commands
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

        # This is Execution Start Time is just a catch all
        # Each script/code within the execution modes should set this before they run
        $ExecutionStartTime = Get-Date


if ($SmithAccountsCurrentlyLoggedInConsoleCheckbox.checked) { . "$Dependencies\Code\Execution\Individual Execution\IndividualQuery-AccountsCurrentlyLoggedInConsole.ps1" }
if ($SmithAccountsCurrentlyLoggedInPSSessionCheckbox.checked) {  }
if ($SmithAccountActivityCheckbox.checked) {  }

if ($SmithEventLogsEventIDsManualEntryCheckbox.checked) {  }
if ($SmithEventLogsQuickPickSelectionCheckbox.checked) {  }
if ($SmithEventLogsEventIDsToMonitorCheckbox.checked) {  }

#if ($SmithFileSearchDirectoryListingCheckbox.checked) {  }
if ($SmithFileSearchFileSearchCheckbox.checked) { . "$Dependencies\Code\Execution\Individual Execution\IndividualQuery-FileSearchFileSearch.ps1" }
if ($SmithFileSearchAlternateDataStreamCheckbox.checked) { . "$Dependencies\Code\Execution\Individual Execution\IndividualQuery-FileSearchAlternateDataStream.ps1" }

if ($SmithNetworkEndpointPacketCaptureCheckBox.checked) {  }
if ($SmithNetworkConnectionSearchRemoteIPAddressCheckbox.checked) {  }
if ($SmithNetworkConnectionSearchRemotePortCheckbox.checked) {  }
if ($SmithNetworkConnectionSearchLocalPortCheckbox.checked) {  }
if ($SmithNetworkConnectionSearchProcessCheckbox.checked) {  }
if ($SmithNetworkConnectionSearchDNSCacheCheckbox.checked) {  }

if ($SmithRegistrySearchCheckbox.checked) {  }
if ($SmithRegistrySearchRecursiveCheckbox.checked) {  }
if ($SmithRegistryKeyNameCheckbox.checked) {  }
if ($SmithRegistryValueNameCheckbox.checked) {  }
if ($SmithRegistryValueDataCheckbox.checked) {  }


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

        if ($EventLogRPCRadioButton.checked -or $ExternalProgramsRPCRadioButton.checked -or $AccountsRPCRadioButton.checked) { $script:RpcCommandCount += 1 }


        if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs' -or $script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Individual Execution') {
            Create-ComputerNodeCheckBoxArray

            # Compares the computerlist against the previous computerlist queried (generated when previous query is completed )
            # If the computerlists changed, it will prompt you to do connections tests and generate a new computerlist if endpoints fail
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

            Maximize-MonitorJobsTab

            Completed-QueryExecution
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

        elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Compiled Script' ) {
            # Compiled Script Execution
            . "$Dependencies\Code\Main Body\Execution\Compiled Script.ps1"
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


# Selects the computers to query using command line parameters and arguments
Update-FormProgress "$Dependencies\Code\Execution\Command Line\Select-ComputersAndCommandsFromCommandLine.ps1"
. "$Dependencies\Code\Execution\Command Line\Select-ComputersAndCommandsFromCommandLine.ps1"

# This needs to be here to execute the script
# Note the Execution button itself is located in the Select Computer section
$script:ComputerListExecuteButton.Add_Click($ExecuteScriptHandler)

#Show the Form
$script:ProgressBarFormProgressBar.Value = 250
$script:ProgressBarSelectionForm.Hide()


Update-FormProgress "Finished Loading!"
Start-Sleep -Milliseconds 500


# Shows the GUI
$PoShEasyWin.ShowDialog() | Out-Null

} # END for $ScriptBlockForGuiLoadAndProgressBar

$ScriptBlockProgressBarInput = {
    $script:ProgressBarMessageLabel.text = "PowerShell - Endpoint Analysis Solution Your Windows Intranet Needs!"
    $script:ProgressBarSelectionForm.Refresh()

    $script:ProgressBarFormProgressBar.Value   = 0
    $script:ProgressBarFormProgressBar.Maximum = 250

    Invoke-command $global:ScriptBlockForGuiLoadAndProgressBar
}

if ((Test-Path "$PoShHome\Settings\User Notice And Acknowledgement.txt")) {
    Launch-ProgressBarForm -FormTitle "PoSh-EasyWin  [$InitialScriptLoadTime]" -ShowImage -ScriptBlockProgressBarInput $ScriptBlockProgressBarInput
}





