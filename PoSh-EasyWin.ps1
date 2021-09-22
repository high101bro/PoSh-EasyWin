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
    Version        : v6.2.1
    Updated        : 17 Sep 2021
    Created        : 21 Aug 2018

    Requirements   : PowerShell v6.0+ - PowerShell Core is not supported
                                      - GUI Windows.System.Forms
                                v5.1  - PSWriteHTML Module support
                                      - Fully tested
                                v4.0  - The use of Copy-Item -Session
                                      - Partially Tested
                                v3.0  - Splatting Arguments
                                      - PowerShell Charts support
                                      - Limited testing
                                v2.0  - Not supported, requres splatting
                                                                      
                   : WinRM   HTTP    - TCP/5985 Windows 7+ ( 80 Vista-)
                             HTTPS   - TCP/5986 Windows 7+ (443 Vista-)
                             Endpoint Listener - TCP/47001
                   : DCOM    RPC     - TCP/135 and dynamic ports, typically:
                                       TCP 49152-65535 (Windows Vista, Server 2008 and above)
                                       TCP 1024 -65535 (Windows NT4, Windows 2000, Windows 2003)
    Optional       : PsExec.exe, Procmon.exe, Autoruns.exe, Sysmon.exe,
                     etl2pcapng.exe, kitty.exe, plink.exe, chainsaw.exe

    Author         : Daniel Komnick (high101bro)
    Email          : high101bro@gmail.com
    Website        : https://github.com/high101bro/PoSh-EasyWin


    PoSh-EasyWin is the Endpoint Analysis Solution Your Windows Intranet Needs that provides a
    simple user interface to execute any number of commands against any number of computers within
    a network, access hosts, manage data, and analyze their results.

    Though this may look like a program, it is still a script that has a GUI interface built
    using the .Net Framework and WinForms. So when it's conducting queries, the GUI will be
    unresponsive to user interaction even though you are able to view status and timer updates.

    A few ways to run the script if you're unable to:
    - Unblock-File if downloaded from the internet, Windows automatically blocks them as a security precatuion
        You may have to use the Unblock-File cmdlet to be able to run the script.
            - For addtional info on: Get-Help Unblock-File
        How to Unblock the file:
            - Get-ChildItem -Path C:\Path\To\PoSh-Easywin -Recurse | Unblock-File

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
    Scripts downloaded from the internet are blocked for execution as a Windodws' security precaution

        Get-ChildItem -Path C:\Path\To\PoSh-Easywin -Recurse | Unblock-File
        .\PoSh-EasyWin.ps1

    .EXAMPLE
    This will run PoSh-EasyWin.ps1 and provide prompts that will tailor your collection.

        PowerShell.exe -ExecutionPolicy ByPass -NoProfile -File .\PoSh-EasyWin.ps1

    .LINK
    https://github.com/high101bro/PoSh-EasyWin

    .NOTES
    None
#>

[CmdletBinding(
    #ConfirmImpact=<String>,
    DefaultParameterSetName='GUI',
    HelpURI='https://github.com/high101bro/PoSh-EasyWin',
    #SupportsPaging=$true,
    #SupportsShouldProcess=$true,
    PositionalBinding = $true)]

param (
    [Parameter(
        Mandatory=$false,
        HelpMessage="Skips the terminal privledge elevation check to run with higher permissions.")]
    [switch]$SkipEvelationCheck,

    [Parameter(
        Mandatory=$false,
        HelpMessage="Launches PoSh-EasyWin without hiding the parent PowerShell Terminal.")]
    [switch]$ShowTerminal,

    [Parameter(
        Mandatory=$false,
        ParameterSetName="GUI",
        HelpMessage="The default font used in the GUI is Courier, but the following fonts also valdated.")]
    [ValidateSet('Calibri','Courier','Arial')]
        # This this validation set is expanded, ensure that larger fonts don't cause words to be truncated in the GUI
    [ValidateNotNull()]
    [string]$Font = "Courier"
)

# Keycodes
# https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.keys?view=net-5.0

# Generates the GUI and contains the majority of the script
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

#============================================================================================================================================================
# Variables
#============================================================================================================================================================

# Universally sets the ErrorActionPreference to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

# Script Launch Time - This in placed within both the title of the Main PoSh-EasyWin form and the title of the System Tray Notification
# Useful if multiple instances of PoSh-EasyWin are launched and you want to use the Abort/Reload or Exit Tool buttons on the corrent instance
$InitialScriptLoadTime = Get-Date


# Location PoSh-EasyWin will save files
$PoShHome                            = $PSScriptRoot #Deprecated# Split-Path -parent $MyInvocation.MyCommand.Definition
    # Creates settings directory
    $PoShSettings                    = "$PoShHome\Settings"

    # The path of PoSh-EasyWin when executed
    $ThisScriptPath                  = $myinvocation.mycommand.definition
    $ThisScript                      = "& '$ThisScriptPath'"

    $LogFile                         = "$PoShHome\Log File.txt"
    $IPListFile                      = "$PoShHome\iplist.txt"

    $script:EndpointTreeNodeFileSave = "$PoShHome\TreeView Data - Endpoint (Saved).csv"
    $script:AccountsTreeNodeFileSave = "$PoShHome\TreeView Data - Accounts (Saved).csv"

    $OpNotesFile                     = "$PoShHome\OpNotes.txt"
    $OpNotesWriteOnlyFile            = "$PoShHome\OpNotes (Write Only).txt"

    $script:CredentialManagementPath = "$PoShHome\Credential Management\"

    # Dependencies
    $Dependencies                             = "$PoShHome\Dependencies"
        # Location of Commands & Scripts
        $QueryCommandsAndScripts              = "$Dependencies\Commands & Scripts"
            $CommandsEndpoint                 = "$QueryCommandsAndScripts\Commands - Endpoint.csv"
            $CommandsActiveDirectory          = "$QueryCommandsAndScripts\Commands - Active Directory.csv"
            $CommandsUserAdded                = "$QueryCommandsAndScripts\Commands - User Added.csv"
            $CommandsCustomGrouped            = "$QueryCommandsAndScripts\Commands - Custom Group Commands.xml"

        $PSWriteHTMLDirectory                  = "$Dependencies\Code\PSWriteHTML"

        # The stored Active Directory hostname if previously entered
        $script:ActiveDirectoryEndpoint       = "$PoShHome\Settings\Active Directory Hostname.txt"

        # Location of Event Logs Commands
        $CommandsEventLogsDirectory           = "$Dependencies\Event Log Info"

            # CSV file of Event IDs
            $EventIDsFile                     = "$CommandsEventLogsDirectory\Event IDs.csv"

            # CSV file from Microsoft detailing Event IDs to Monitor
            $EventLogsWindowITProCenter       = "$CommandsEventLogsDirectory\Individual Selection\Event Logs to Monitor - Window IT Pro Center.csv"

        # Location of External Programs directory
        $ExternalPrograms                     = "$Dependencies\Executables"
            $PsExecPath                       = "$ExternalPrograms\PsExec.exe"
            $kitty_ssh_client                 = "$ExternalPrograms\KiTTY\kitty-0.74.4.7.exe"
            $plink_ssh_client                 = "$ExternalPrograms\plink.exe"

        # CSV list of Event IDs numbers, names, and description
        $TagAutoListFile                      = "$Dependencies\Tags - Auto Populate.txt"

        # list of ports that can be updated for custom port scans
        $CustomPortsToScan                    = "$Dependencies\Custom Ports To Scan.txt"

        $EasyWinIcon                          = "$Dependencies\Images\Icons\favicon.ico"
        $high101bro_image                     = "$Dependencies\Images\high101bro Logo Color Transparent.png"

    # Name of Collected Data Directory
    $CollectedDataDirectory                   = "$PoShHome\Collected Data"
        if (-not (Test-Path $CollectedDataDirectory )) {New-Item -ItemType Directory -Path $CollectedDataDirectory -Force}
        $script:SystemTrayOpenFolder         = $CollectedDataDirectory # = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)\Collected Data"

        # Location of separate queries
        $script:CollectedDataTimeStampDirectory = "$CollectedDataDirectory\$((Get-Date).ToString('yyyy-MM-dd HH.mm.ss'))"

        $SaveLocation = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)\Collected Data\$((Get-Date).ToString('yyyy-MM-dd HH.mm.ss'))"


# Send Files listbox value store
$script:SendFilesValueStoreListBox = @()

# Maintains a list of the PS Sessions used during session based querying
$script:PoShEasyWinPSSessions = @()

# Used to track the number of previous queries selected
$script:PreviousQueryCount = 0

# Maintains the count of all the queries selected
$script:SectionQueryCount = 0
function Update-QueryCount {
    if ($this.checked){$script:SectionQueryCount++}
    else {$script:SectionQueryCount--}
}

# Keeps track of the number of RPC protocol commands selected, if the value is ever greater than one, it'll set the collection mode to 'Monitor Jobs'
$script:RpcCommandCount = 0

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
    $ElevateShell = [System.Windows.Forms.MessageBox]::Show("PoSh-EasyWin is writen in PowerShell and makes use of the .NET Framwork and WinForms to generate the user interface.`n`nIf you experience performance, user interface, or remoting issues, trying to run the tool with elevated permissions often helps. You can create and use alternate credentials for remoting within the Credential Management section.`n`nUse the -SkipElevationCheck if you want to avoid seeing this prompt.`n`nWould you like to relaunch this tool using administrator privileges.","PoSh-EasyWin",'YesNoCancel',"Warning")
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
elseif ($SkipEvelationCheck -and ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "`nThe " -ForegroundColor Green -NoNewline
    Write-Host "-SkipElevationCheck " -NoNewline
    Write-Host "parameter is not needed if the terminal used already has elevated permissions.`n" -ForegroundColor Green
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
    Write-Host  "You accepted the EULA." -ForeGroundColor Green
    Write-Host "For more infor, visit https://www.gnu.org/licenses/gpl-3.0.html or view a copy in the Dependencies folder.`n" -ForeGroundColor Yellow
}
else {
    Get-Content "$Dependencies\GPLv3 Notice.txt" | Out-GridView -Title 'PoSh-EasyWin User Agreement' -PassThru | Set-Variable -Name UserAgreement
    if ($UserAgreement) {
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "PoSh-EasyWin User Agreemennt Accepted By: $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"
        Write-Host "You accepted the EULA." -ForeGroundColor Green
        Write-Host "For more infor, visit https://www.gnu.org/licenses/gpl-3.0.html or view a copy in the Dependencies folder.`n" -ForeGroundColor Yellow
        Start-Sleep -Seconds 1
    }
    else {
        [system.media.systemsounds]::Exclamation.play()
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "PoSh-EasyWin User Agreemennt NOT Accepted By: $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"
        Write-Host "You must accept the EULA to continue." -ForeGroundColor Red
        Write-Host "For more infor, visit https://www.gnu.org/licenses/gpl-3.0.html or view a copy in the Dependencies folder.`n" -ForeGroundColor Yellow
        exit
    }
    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "===================================================================================================="
}


# These are the common settings for buttons in a function
. "$Dependencies\Code\Main Body\Apply-CommonButtonSettings.ps1"


# Scales the PoSh-EasyWin GUI as desired by the user
. "$Dependencies\Code\Main Body\script:Launch-FormScaleGUI.ps1"
if (-not (Test-Path "$PoShSettings\Form Scaling Modifier.txt")){
    script:Launch-FormScaleGUI -Extended
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
    if (-not (Get-InstalledModule -Name PSWriteHTML)) {
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
    else {
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "PSWriteHTML was detected as being installed."
        'Import PSWriteHTML: Yes' | Set-Content "$PoShHome\Settings\PSWriteHTML Module Install.txt"
    }    
}
if (Test-Path -Path "$Dependencies\Modules\PSWriteHTML"){
    if ((Get-Content "$PoShHome\Settings\PSWriteHTML Module Install.txt") -match 'Yes') {
        Import-Module -Name "$Dependencies\Modules\PSWriteHTML\*\PSWriteHTML.psm1" -Force
    }
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

#Start Progress bar form loading
$global:ScriptBlockForGuiLoadAndProgressBar = {
function Update-FormProgress {
    param(
        [string]$ScriptPath = '...'
    )
    $StatusDescription = $ScriptPath | Split-Path -Leaf
    # NOTE: Apparently there are issues with scoping when dot sourcing within a function
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


# Used with PSWriteHTML
function Set-CheckState {
    Param(
        $CheckedListBox,
         # regex matches anything
         [string]$Match = '.',
         [switch]$Check
    )
    0 .. ($CheckedListBox.Items.Count - 1) |
        Where-Object { $CheckedListBox.Items[$_] -match $Match  } |
        ForEach-Object { $CheckedListBox.SetItemChecked($_, $Check) }
}

# Launches the accompanying Notifications Icon helper in the  System Tray
Update-FormProgress "$Dependencies\Code\Main Body\Launch-SystemTrayNotifyIcon.ps1"
. "$Dependencies\Code\Main Body\Launch-SystemTrayNotifyIcon.ps1"


# The Launch-ProgressBarForm.ps1 is topmost upon loading to ensure it's displayed intially, but is then able to be move unpon
$ResolutionCheckForm.topmost = $false


$PoShEasyWinAccountLaunch = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
#[System.Windows.Forms.Application]::EnableVisualStyles()


$PoShEasyWin = New-Object System.Windows.Forms.Form -Property @{
    Text    = "PoSh-EasyWin   ($PoShEasyWinAccountLaunch)  [$InitialScriptLoadTime]"
    Icon    = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
    TopMost = $true
    AutoScroll  = $True
    ControlBox  = $true
    MaximizeBox = $false
    MinimizeBox = $true
    StartPosition  = "CenterScreen"
    FormBorderStyle =  'Sizable' #  Fixed3D, FixedDialog, FixedSingle, FixedToolWindow, None, Sizable, SizableToolWindow
    Add_Load = {
        $This.TopMost = $false
        if ((Test-Path "$script:CredentialManagementPath\Specified Credentials.txt")) {
            $SelectedCredentialName = Get-Content "$script:CredentialManagementPath\Specified Credentials.txt"
            $script:SelectedCredentialPath = Get-ChildItem "$script:CredentialManagementPath\$SelectedCredentialName"
            $script:Credential      = Import-CliXml $script:SelectedCredentialPath
            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("Credentials:  $SelectedCredentialName.xml")
            $script:ComputerListProvideCredentialsCheckBox.checked = $true
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

$QueryAndCollectionPanel = New-Object System.Windows.Forms.Panel -Property @{
    Left   = $FormScale * 5
    Top    = $FormScale * 5
}
            $PoShEasyWinPictureBox = New-Object Windows.Forms.PictureBox -Property @{
                Text   = "PowerShell Charts"
                Left   = 0
                Top    = 0
                Width  = $FormScale * 400
                Height = $FormScale * 45
                Image  = [System.Drawing.Image]::Fromfile("$Dependencies\Images\PoSh-EasyWin Image 01.png")
                SizeMode = 'StretchImage'
            }
            # Added/Removed by Set-GuiLayout

            $High101BroPictureBox = New-Object Windows.Forms.PictureBox -Property @{
                Text   = "high101bro"
                Left   = $PoShEasyWinPictureBox.Left + $PoShEasyWinPictureBox.Width + ($FormScale * 10)
                Top    = $PoShEasyWinPictureBox.Top
                Width  = $FormScale * 45
                Height = $FormScale * 45
                Image  = [System.Drawing.Image]::Fromfile($high101bro_image)
                SizeMode = 'StretchImage'
                Add_Click = {
                    $Verify = [System.Windows.Forms.MessageBox]::Show(
                        "Do you want to navigate to PoSh-EasyWin's GitHub page?",
                        "PoSh-EasyWin - high101bro",
                        'YesNo',
                        "Warning")
                    switch ($Verify) {
                        'Yes'{Start-Process "https://www.github.com/high101bro/PoSh-EasyWin"}
                        'No' {continue}
                    }                    
                }
            }

            $MainLeftTabControl = New-Object System.Windows.Forms.TabControl -Property @{
                Left   = 0
                Width  = $FormScale * 460
                Height = $FormScale * 590
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            }
            $QueryAndCollectionPanel.Controls.Add($MainLeftTabControl)


            $TabRightPosition     = 3
            $TabhDownPosition     = 3
            $TabAreaWidth         = 446
            $TabAreaHeight        = 557
            $TextBoxRightPosition = -2
            $TextBoxDownPosition  = -2
            $TextBoxWidth         = 442
            $TextBoxHeight        = 536


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
            
$PoShEasyWin.Controls.Add($QueryAndCollectionPanel)


$MainCenterPanel = New-Object System.Windows.Forms.Panel

            $MainCenterTabControl = New-Object System.Windows.Forms.TabControl -Property @{
                Left   = 0
                Top    = 0
                Width  = $FormScale * 370
                Height = $FormScale * 278 
                SelectedIndex  = 0
                ShowToolTips   = $True
                Font           = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                Add_MouseHover = $MainCenterTabControlAdd_MouseHover
            }
            $MainCenterPanel.Controls.Add($MainCenterTabControl)

            # Main Tab
            Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Main Tab.ps1"
            . "$Dependencies\Code\Main Body\Tabs\Main Tab.ps1"

            # Options Tab
            Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Options.ps1"
            . "$Dependencies\Code\Main Body\Tabs\Options.ps1"

            # Statistics Tab
            Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Statistics.ps1"
            . "$Dependencies\Code\Main Body\Tabs\Statistics.ps1"

$PoShEasyWin.Controls.Add($MainCenterPanel)


$ComputerAndAccountTreeNodeViewPanel = New-Object System.Windows.Forms.Panel

            Update-FormProgress "$Dependencies\Code\Context Menu Strip\Display-ContextMenuForAccountsTreeNode.ps1"
            . "$Dependencies\Code\Context Menu Strip\Display-ContextMenuForAccountsTreeNode.ps1"
            Display-ContextMenuForAccountsTreeNode -ClickedOnArea

            $ComputerAndAccountTreeViewTabControl = New-Object System.Windows.Forms.TabControl -Property @{
                Left   = 0
                Top    = 0
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                Add_Click = {
                    if ($This.SelectedTab -eq $ComputerTreeviewTab) {
                        $InformationTabControl.SelectedTab = $Section3HostDataTab
                    }
                    elseif ($This.SelectedTab -eq $AccountsTreeviewTab) {
                        $InformationTabControl.SelectedTab = $Section3AccountDataTab
                    }
                }
            }
            $ComputerAndAccountTreeNodeViewPanel.Controls.Add($ComputerAndAccountTreeViewTabControl)

                    # If Computer treenodes are imported/created with missing data, this populates various fields with default data
                    Update-FormProgress "$Dependencies\Code\Tree View\Normalize-TreeViewData.ps1"
                    . "$Dependencies\Code\Tree View\Normalize-TreeViewData.ps1"

                    Update-FormProgress "$Dependencies\Code\Tree View\Save-TreeViewData.ps1"
                    . "$Dependencies\Code\Tree View\Save-TreeViewData.ps1"

                    # Initializes the Computer TreeView section that computer nodes are added to
                    # TreeView initialization initially happens upon load and whenever the it is regenerated, like when switching between views
                    # These include the root nodes of Search, and various Operating System and OU/CN names
                    Update-FormProgress "$Dependencies\Code\Tree View\Initialize-TreeViewData.ps1"
                    . "$Dependencies\Code\Tree View\Initialize-TreeViewData.ps1"

                    # This will keep the Computer TreeNodes checked when switching between OS and OU/CN views
                    Update-FormProgress "$Dependencies\Code\Tree View\UpdateState-TreeViewData.ps1"
                    . "$Dependencies\Code\Tree View\UpdateState-TreeViewData.ps1"

                    # Adds a treenode to the specified root node... a computer node within a category node
                    Update-FormProgress "$Dependencies\Code\Tree View\AddTreeNodeTo-TreeViewData.ps1"
                    . "$Dependencies\Code\Tree View\AddTreeNodeTo-TreeViewData.ps1"

                    # Populate Auto Tag List used for Host Data tagging and Searching
                    $TagListFileContents = Get-Content -Path $TagAutoListFile

                    # Searches for Accounts nodes that match a given search entry
                    # A new category node named by the search entry will be created and all results will be nested within
                    Update-FormProgress "$Dependencies\Code\Tree View\Search-TreeViewData.ps1"
                    . "$Dependencies\Code\Tree View\Search-TreeViewData.ps1"

                    # Code to remove empty categoryies
                    Update-FormProgress "$Dependencies\Code\Tree View\Remove-EmptyCategory.ps1"
                    . "$Dependencies\Code\Tree View\Remove-EmptyCategory.ps1"

                    Update-FormProgress "$Dependencies\Code\Tree View\Message-NodeAlreadyExists.ps1"
                    . "$Dependencies\Code\Tree View\Message-NodeAlreadyExists.ps1"

                    Update-FormProgress "$Dependencies\Code\Tree View\Show-MoveForm.ps1"
                    . "$Dependencies\Code\Tree View\Show-MoveForm.ps1"

                    Update-FormProgress "$Dependencies\Code\Tree View\Show-TagForm.ps1"
                    . "$Dependencies\Code\Tree View\Show-TagForm.ps1"

                    Update-FormProgress "$Dependencies\Code\Execution\Action\Check-Connection.ps1"
                    . "$Dependencies\Code\Execution\Action\Check-Connection.ps1"

                    Update-FormProgress "$Dependencies\Code\Tree View\MoveNode-TreeViewData.ps1"
                    . "$Dependencies\Code\Tree View\MoveNode-TreeViewData.ps1"

                    Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\Import-DataFromActiveDirectory.ps1"
                    . "$Dependencies\Code\System.Windows.Forms\Button\Import-DataFromActiveDirectory.ps1"

                    Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\Import-DataFromCsv.ps1"
                    . "$Dependencies\Code\System.Windows.Forms\Button\Import-DataFromCsv.ps1"
                    
                    Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\Import-DataFromTxt.ps1"
                    . "$Dependencies\Code\System.Windows.Forms\Button\Import-DataFromTxt.ps1"
                    
            $ComputerTreeviewTab = New-Object System.Windows.Forms.TabPage -Property @{
                Text = "Endpoints"
                Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                UseVisualStyleBackColor = $True
            }
            $ComputerAndAccountTreeViewTabControl.Controls.Add($ComputerTreeviewTab)

                    $script:UpdateComputerTreeViewScriptBlock = {
                        # This variable stores data on checked checkboxes, so boxes checked remain among different views
                        $script:ComputerTreeViewSelected = @()

                        [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
                        foreach ($root in $AllTreeViewNodes) {
                            foreach ($Category in $root.Nodes) {
                                foreach ($Entry in $Category.nodes) {
                                    if ($Entry.Checked) {
                                        $script:ComputerTreeViewSelected += $Entry.Text
                                    }
                                }
                            }
                        }
                        $script:ComputerTreeView.Nodes.Clear()
                        Initialize-TreeViewData -Endpoint
                        Normalize-TreeViewData -Endpoint
                        Save-TreeViewData -Endpoint

                        $script:ComputerTreeView.Nodes.Add($script:TreeNodeComputerList)
                        Foreach($Computer in $script:ComputerTreeViewData) {
                            AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category $Computer.$($This.SelectedItem) -Entry $Computer.Name -ToolTip $Computer.IPv4Address -Metadata $Computer
                        }
                        UpdateState-TreeViewData -Endpoint

                        Update-TreeViewData -Endpoint -TreeView $script:ComputerTreeView.Nodes
                    }


                    $script:ComputerTreeNodeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
                        Text    = 'CanonicalName'
                        Left    = 0
                        Top     = $FormScale * 5
                        Width   = $FormScale * 120
                        Height  = $FormScale * 25
                        Font    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                        AutoCompleteSource = "ListItems"
                        AutoCompleteMode   = "SuggestAppend"    
                        add_SelectedIndexChanged = $script:UpdateComputerTreeViewScriptBlock
                        #Add_MouseHover = $ComputerTreeNodeEnabledRadioButtonAdd_MouseHover
                    }
                    $ComputerTreeNodeComboBoxList = @('CanonicalName', 'OperatingSystem', 'OperatingSystemHotfix', 'OperatingSystemServicePack', 'Enabled', 'LockedOut', 'LogonCount', 'Created', 'Modified', 'LastLogonDate', 'MemberOf', 'isCriticalSystemObject', 'HomedirRequired', 'Location', 'ProtectedFromAccidentalDeletion', 'TrustedForDelegation')
                    ForEach ($Item in $ComputerTreeNodeComboBoxList) { $script:ComputerTreeNodeComboBox.Items.Add($Item) }
                    $ComputerTreeviewTab.Controls.Add($script:ComputerTreeNodeComboBox)


                    $ComputerTreeNodeSearchGreedyCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
                        Text    = "Greedy"
                        Left    = $script:ComputerTreeNodeComboBox.Left + $script:ComputerTreeNodeComboBox.Width + ($FormScale * 5)
                        Top     = $script:ComputerTreeNodeComboBox.Top - ($FormScale * 6)
                        Height  = $FormScale * 25
                        Width   = $FormScale * 65
                        Checked = $true
                        Font    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                        #ToolTipText = "Checkbox this to get results with partial matches`nex: 'server' will show results with 'server-01' and 'Windows Server 2012'"
                    }
                    $ComputerTreeviewTab.Controls.Add($ComputerTreeNodeSearchGreedyCheckbox)
                            

                    # Initial load of CSV data
                    $script:ComputerTreeViewData = $null
                    $script:ComputerTreeViewData = Import-Csv $script:EndpointTreeNodeFileSave -ErrorAction SilentlyContinue #| Select-Object -Property Name, OperatingSystem, CanonicalName, IPv4Address, MACAddress, Notes

                    $script:ComputerTreeViewSelected = ""

                    Update-FormProgress "$Dependencies\Code\System.Windows.Forms\ComboBox\ComputerTreeNodeSearchComboBox.ps1"
                    . "$Dependencies\Code\System.Windows.Forms\ComboBox\ComputerTreeNodeSearchComboBox.ps1"
                    $ComputerTreeNodeSearchComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
                        Name   = "Search TextBox"
                        Left   = $script:ComputerTreeNodeComboBox.Left
                        Top    = $script:ComputerTreeNodeComboBox.Top + $script:ComputerTreeNodeComboBox.Height + ($FormScale * 5)
                        Width  = $FormScale * 120
                        Height = $FormScale * 25
                        AutoCompleteSource = "ListItems"
                        AutoCompleteMode   = "SuggestAppend"
                        Font               = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                        Add_KeyDown        = $ComputerTreeNodeSearchComboBoxAdd_KeyDown
                        Add_MouseHover     = $ComputerTreeNodeSearchComboBoxAdd_MouseHover
                    }
                    ForEach ($Tag in $TagListFileContents) { [void] $ComputerTreeNodeSearchComboBox.Items.Add($Tag) }
                    $ComputerTreeviewTab.Controls.Add($ComputerTreeNodeSearchComboBox)


                    Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\ComputerTreeNodeSearchButton.ps1"
                    . "$Dependencies\Code\System.Windows.Forms\Button\ComputerTreeNodeSearchButton.ps1"
                    $ComputerTreeNodeSearchButton = New-Object System.Windows.Forms.Button -Property @{
                        Text   = "Search"
                        Left   = $ComputerTreeNodeSearchComboBox.Left + $ComputerTreeNodeSearchComboBox.Width + ($FormScale * 5)
                        Top    = $ComputerTreeNodeSearchComboBox.Top
                        Width  = $FormScale * 55
                        Height = $FormScale * 22
                        Add_Click = { 
                            Search-TreeViewData -Endpoint
                        }
                        Add_MouseHover = $ComputerTreeNodeSearchButtonAdd_MouseHover
                    }
                    $ComputerTreeviewTab.Controls.Add($ComputerTreeNodeSearchButton)
                    Apply-CommonButtonSettings -Button $ComputerTreeNodeSearchButton

                    Remove-EmptyCategory -Endpoint


                    Update-FormProgress "$Dependencies\Code\Tree View\Computer\AddHost-ComputerTreeNode.ps1"
                    . "$Dependencies\Code\Tree View\Computer\AddHost-ComputerTreeNode.ps1"

                    Update-FormProgress "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListDeselectAllToolStripButton.ps1"
                    . "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListDeselectAllToolStripButton.ps1"

                    Update-FormProgress "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListNSLookupCheckedToolStripButton.ps1"
                    . "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListNSLookupCheckedToolStripButton.ps1"

                    Update-FormProgress "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListTagToolStripButton.ps1"
                    . "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListTagToolStripButton.ps1"

                    Update-FormProgress "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListMoveToolStripButton.ps1"
                    . "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListMoveToolStripButton.ps1"

                    Update-FormProgress "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListDeleteToolStripButton.ps1"
                    . "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListDeleteToolStripButton.ps1"

                    Update-FormProgress "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListRenameToolStripButton.ps1"
                    . "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListRenameToolStripButton.ps1"

                    Update-FormProgress "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListPingToolStripButton.ps1"
                    . "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListPingToolStripButton.ps1"

                    Update-FormProgress "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListRPCCheckToolStripButton.ps1"
                    . "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListRPCCheckToolStripButton.ps1"

                    Update-FormProgress "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListSMBCheckToolStripButton.ps1"
                    . "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListSMBCheckToolStripButton.ps1"

                    Update-FormProgress "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListWinRMCheckToolStripButton.ps1"
                    . "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListWinRMCheckToolStripButton.ps1"

                    Update-FormProgress "$Dependencies\Code\Context Menu Strip\Display-ContextMenuForComputerTreeNode.ps1"
                    . "$Dependencies\Code\Context Menu Strip\Display-ContextMenuForComputerTreeNode.ps1"
                    Display-ContextMenuForComputerTreeNode -ClickedOnArea


                    # The .ImageList allows for the images to be loaded from disk to memory only once, then referenced using their index number
                    $ComputerTreeviewImageList = New-Object System.Windows.Forms.ImageList -Property @{
                        ImageSize = @{
                            Width  = $FormScale * 16
                            Height = $FormScale * 16
                        }
                    }
                    $script:ComputerTreeViewIconList = Get-ChildItem "$Dependencies\Images\Icons\Endpoint"

                    # This hashtable is used to maintain a relationship between the imageindex number and the image filepath, it is used when populating the Endpoint Data tab
                    $EndpointTreeviewImageHashTable = [ordered]@{}

                    # Position 0 = Default Image, this one is often seen when clicking on a treenode
                    $ComputerTreeviewImageList.Images.Add([System.Drawing.Image]::FromFile("$EasyWinIcon"))
                    $EndpointTreeviewImageHashTable['0'] = "$EasyWinIcon"

                    # Position 1 = used as the default image that is loaded against the .treeview itself, thus shown at the top level for the Organizational Units, It gets overwritten by each node that is added
                    $ComputerTreeviewImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Icon OU LightYellow.png"))
                    $EndpointTreeviewImageHashTable['1'] = "$Dependencies\Images\Icons\Icon OU LightYellow.png"
                    
                    # Position 2 = PowerShell Icon, used to indicate an active powershell session
                    $ComputerTreeviewImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\PowerShell Icon.png"))
                    $EndpointTreeviewImageHashTable['2'] = "$Dependencies\Images\Icons\PowerShell Icon.png"

                    # Position 3 = used as the default image for the computer/account/entry node. Normalize-TreeViewData.ps1 populates it by default if an imageindex number doesn't exist for it already
                    $ComputerTreeviewImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Endpoint Default.png"))
                    $EndpointTreeviewImageHashTable['3'] = "$Dependencies\Images\Icons\Endpoint Default.png"
                    
                    # Position 4 = Windows Server Default
                    $ComputerTreeviewImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Windows Server Default.png"))
                    $EndpointTreeviewImageHashTable['4'] = "$Dependencies\Images\Icons\Windows Server Default.png"
                                        
                    # Position 5 = Windows Desktop Client Default
                    $ComputerTreeviewImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Endpoint\Windows-Desktop-Client.png"))
                    $EndpointTreeviewImageHashTable['5'] = "$Dependencies\Images\Icons\Endpoint\Windows-Desktop-Client.png"

                    # Position 6 = Windows Desktop `95
                    $ComputerTreeviewImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Endpoint\Windows-Desktop-95.png"))
                    $EndpointTreeviewImageHashTable['6'] = "$Dependencies\Images\Icons\Endpoint\Windows-Desktop-95.png"

                    # Position 7 = Windows Desktop XP
                    $ComputerTreeviewImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Endpoint\Windows-Desktop-XP.png"))
                    $EndpointTreeviewImageHashTable['7'] = "$Dependencies\Images\Icons\Endpoint\Windows-Desktop-XP.png"

                    # Position 8 = Windows Desktop Vista
                    $ComputerTreeviewImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Endpoint\Windows-Desktop-Vista.png"))
                    $EndpointTreeviewImageHashTable['8'] = "$Dependencies\Images\Icons\Endpoint\Windows-Desktop-Vista.png"

                    # Position 9 = Windows Desktop 7
                    $ComputerTreeviewImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Endpoint\Windows-Desktop-7.png"))
                    $EndpointTreeviewImageHashTable['9'] = "$Dependencies\Images\Icons\Endpoint\Windows-Desktop-7.png"

                    # Position 10 = Windows Desktop 8
                    $ComputerTreeviewImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Endpoint\Windows-Desktop-8.png"))
                    $EndpointTreeviewImageHashTable['10'] = "$Dependencies\Images\Icons\Endpoint\Windows-Desktop-8.png"

                    # Position 11 = Windows Desktop 10
                    $ComputerTreeviewImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Endpoint\Windows-Desktop-10.png"))
                    $EndpointTreeviewImageHashTable['11'] = "$Dependencies\Images\Icons\Endpoint\Windows-Desktop-10.png"

                    # Position 12 = Windows Desktop 11
                    $ComputerTreeviewImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Endpoint\Windows-Desktop-11.png"))
                    $EndpointTreeviewImageHashTable['12'] = "$Dependencies\Images\Icons\Endpoint\Windows-Desktop-11.png"
                    

                    # note, if you update this variable, update this one too... $ComputerTreeViewChangeIconRootTreeNodeCount
                    $script:EndpointTreeviewImageHashTableCount = 12

                    foreach ($Image in $script:ComputerTreeViewIconList.FullName) {
                        $ComputerTreeviewImageList.Images.Add([System.Drawing.Image]::FromFile("$Image"))
                        $script:EndpointTreeviewImageHashTableCount++
                        $EndpointTreeviewImageHashTable["$script:EndpointTreeviewImageHashTableCount"] = "$Image"
                    }

                    # Position -1 = currently unused
                    $ComputerTreeviewImageList.Images.Add([System.Drawing.Image]::FromFile("$high101bro_image"))
                    $script:EndpointTreeviewImageHashTableCount++
                    $EndpointTreeviewImageHashTable["$script:EndpointTreeviewImageHashTableCount"] = "$Dependencies\Images\high101bro Logo Color Transparent.png"


                    Update-FormProgress "$Dependencies\Code\System.Windows.Forms\TreeView\ComputerTreeView.ps1"
                    . "$Dependencies\Code\System.Windows.Forms\TreeView\ComputerTreeView.ps1"
                    $script:ComputerTreeView = New-Object System.Windows.Forms.TreeView -Property @{
                        Left   = $ComputerTreeNodeSearchComboBox.Left
                        Top    = $ComputerTreeNodeSearchButton.Top + $ComputerTreeNodeSearchButton.Height + ($FormScale * 5)
                        Width  = $ComputerTreeNodeSearchComboBox.Width + $ComputerTreeNodeSearchButton.Width + ($FormScale * 5)
                        Height = $FormScale * 558
                        # Note: size and location properties are are managed by 
                        Font              = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                        CheckBoxes        = $True
                        #LabelEdit         = $True  #Not implementing yet...
                        #not working # AfterLabelEdit = {  }
                        #not working #ShowRootLines     = $false
                        ShowLines         = $True
                        ShowNodeToolTips  = $True
                        Add_Click         = $ComputerTreeViewAdd_Click
                        Add_AfterSelect   = $ComputerTreeViewAdd_AfterSelect
                        #Add_MouseHover    = $ComputerTreeViewAdd_MouseHover
                        Add_MouseEnter    = {
                            $ComputerAndAccountTreeNodeViewPanel.bringtofront()
                            $ComputerAndAccountTreeViewTabControl.bringtofront()
                            $script:ComputerTreeView.bringtofront()
                        }
                        Add_MouseLeave    = $ComputerTreeViewAdd_MouseLeave
                        #ShortcutsEnabled  = $false                                #Used for ContextMenuStrip
                        ContextMenuStrip  = $ComputerListContextMenuStrip      #Ref Add_click
                        ShowPlusMinus     = $true
                        HideSelection     = $false
                        #not working #AfterSelect       = {}
                        ImageList         = $ComputerTreeviewImageList
                        ImageIndex        = 1 # the default image 
                    }
                    $script:ComputerTreeView.Sort()
                    $ComputerTreeviewTab.Controls.Add($script:ComputerTreeView)

                    Initialize-TreeViewData -Endpoint
                    Normalize-TreeViewData -Endpoint
   
                    # This will load data that is located in the saved file
                    Foreach($Computer in $script:ComputerTreeViewData) {
                        AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category $Computer.CanonicalName -Entry $Computer.Name -ToolTip $Computer.IPv4Address -IPv4Address $Computer.IPv4Address -Metadata $Computer 
                    }
                    $script:ComputerTreeView.Nodes.Add($script:TreeNodeComputerList)

                    # Controls the layout of the computer treeview
                    $script:ComputerTreeView.ExpandAll()
                    [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
                    foreach ($root in $AllTreeViewNodes) {
                        foreach ($Category in $root.Nodes) {
                            foreach ($Entry in $Category.nodes) { $Entry.Collapse() }
                        }
                    }


            $AccountsTreeviewTab = New-Object System.Windows.Forms.TabPage -Property @{
                Text = "Accounts"
                Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                UseVisualStyleBackColor = $True
            }
            $ComputerAndAccountTreeViewTabControl.Controls.Add($AccountsTreeviewTab)

                    $script:AccountsTreeNodeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
                        Text    = "CanonicalName"
                        Left    = 0
                        Top     = $FormScale * 5
                        Width   = $FormScale * 120
                        Height  = $FormScale * 25
                        Font    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                        AutoCompleteSource = "ListItems"
                        AutoCompleteMode   = "SuggestAppend"    
                        add_SelectedIndexChanged      = {
                            # This variable stores data on checked checkboxes, so boxes checked remain among different views
                            $script:AccountsTreeViewSelected = @()

                            [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:AccountsTreeView.Nodes
                            foreach ($root in $AllTreeViewNodes) {
                                foreach ($Category in $root.Nodes) {
                                    foreach ($Entry in $Category.nodes) {
                                        if ($Entry.Checked) {
                                            $script:AccountsTreeViewSelected += $Entry.Text
                                        }
                                    }
                                }
                            }
                            $script:AccountsTreeView.Nodes.Clear()
                            Initialize-TreeViewData -Accounts
                            Normalize-TreeViewData -Accounts
                            Save-TreeViewData -Accounts

                            Foreach($Account in $script:AccountsTreeViewData) {
                                AddTreeNodeTo-TreeViewData -Accounts -RootNode $script:TreeNodeAccountsList -Category $Account.$($This.SelectedItem) -Entry $Account.Name -ToolTip $Account.SID -Metadata $Account
                            }
                            $script:AccountsTreeView.Nodes.Add($script:TreeNodeAccountsList)
                            UpdateState-TreeViewData -Accounts
                            Update-TreeViewData -Accounts -TreeView $script:AccountsTreeView.Nodes

                        }
                        #Add_MouseHover = $AccountsTreeNodeEnabledRadioButtonAdd_MouseHover
                    }
                    $AccountsTreeNodeComboBoxList = @('CanonicalName','Enabled','LockedOut','SmartCardLogonRequired','Created','Modified','LastLogonDate','LastBadPasswordAttempt','PasswordNeverExpires','PasswordExpired','PasswordNotRequired','BadLogonCount',,'ScriptPath','HomeDrive')
                    ForEach ($Item in $AccountsTreeNodeComboBoxList) { $script:AccountsTreeNodeComboBox.Items.Add($Item) }
                    $AccountsTreeviewTab.Controls.Add($script:AccountsTreeNodeComboBox)


                    $AccountsTreeNodeSearchGreedyCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
                        Text    = "Greedy"
                        Left    = $script:AccountsTreeNodeComboBox.Left + $script:AccountsTreeNodeComboBox.Width + ($FormScale * 5)
                        Top     = $script:AccountsTreeNodeComboBox.Top - ($FormScale * 6)
                        Height  = $FormScale * 25
                        Width   = $FormScale * 65
                        Checked = $true
                        Font    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                        #ToolTipText = "Checkbox this to get results with partial matches`nex: 'admin' will show results with 'admin' and 'administrator'"
                    }
                    $AccountsTreeviewTab.Controls.Add($AccountsTreeNodeSearchGreedyCheckbox)
                            

                    # Initial load of CSV data
                    $script:AccountsTreeViewData = $null
                    $script:AccountsTreeViewData = Import-Csv $script:AccountsTreeNodeFileSave -ErrorAction SilentlyContinue #| Select-Object -Property Name, OperatingSystem, CanonicalName, IPv4Address, MACAddress, Notes

                    $script:AccountsTreeViewSelected = ""

                    Update-FormProgress "$Dependencies\Code\System.Windows.Forms\ComboBox\AccountsTreeNodeSearchComboBox.ps1"
                    . "$Dependencies\Code\System.Windows.Forms\ComboBox\AccountsTreeNodeSearchComboBox.ps1"
                    $AccountsTreeNodeSearchComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
                        Name   = "Search TextBox"
                        Left   = $script:AccountsTreeNodeComboBox.Left
                        Top    = $script:AccountsTreeNodeComboBox.Top + $script:AccountsTreeNodeComboBox.Height + ($FormScale * 5)
                        Width  = $FormScale * 120
                        Height = $FormScale * 25
                        AutoCompleteSource = "ListItems"
                        AutoCompleteMode   = "SuggestAppend"
                        Font               = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                        Add_KeyDown        = $AccountsTreeNodeSearchComboBoxAdd_KeyDown
                        Add_MouseHover     = $AccountsTreeNodeSearchComboBoxAdd_MouseHover
                    }
                    ForEach ($Tag in $TagListFileContents) { [void] $AccountsTreeNodeSearchComboBox.Items.Add($Tag) }
                    $AccountsTreeviewTab.Controls.Add($AccountsTreeNodeSearchComboBox)


                    Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\AccountsTreeNodeSearchButton.ps1"
                    . "$Dependencies\Code\System.Windows.Forms\Button\AccountsTreeNodeSearchButton.ps1"
                    $AccountsTreeNodeSearchButton = New-Object System.Windows.Forms.Button -Property @{
                        Text   = "Search"
                        Left   = $AccountsTreeNodeSearchComboBox.Left + $AccountsTreeNodeSearchComboBox.Width + ($FormScale * 5)
                        Top    = $AccountsTreeNodeSearchComboBox.Top
                        Width  = $FormScale * 55
                        Height = $FormScale * 22
                        Add_Click = { 
                            Search-TreeViewData -Accounts
                        }
                        Add_MouseHover = $AccountsTreeNodeSearchButtonAdd_MouseHover
                    }
                    $AccountsTreeviewTab.Controls.Add($AccountsTreeNodeSearchButton)
                    Apply-CommonButtonSettings -Button $AccountsTreeNodeSearchButton

                    Remove-EmptyCategory -Accounts

                    Update-FormProgress "$Dependencies\Code\Tree View\Accounts\AddAccount-AccountsTreeNode.ps1"
                    . "$Dependencies\Code\Tree View\Accounts\AddAccount-AccountsTreeNode.ps1"


                    # The .ImageList allows for the images to be loaded from disk to memory only once, then referenced using their index number
                    $AccountsTreeviewImageList = New-Object System.Windows.Forms.ImageList -Property @{
                        ImageSize = @{
                            Width  = $FormScale * 16
                            Height = $FormScale * 16
                        }
                    }
                    $script:AccountsTreeViewIconList = Get-ChildItem "$Dependencies\Images\Icons\Account"

                    # This hashtable is used to maintain a relationship between the imageindex number and the image filepath, it is used when populating the Account Data tab
                    $AccountsTreeviewImageHashTable = [ordered]@{}

                    # Position 0 = Default Image, this one is often seen when clicking on a treenode
                    $AccountsTreeviewImageList.Images.Add([System.Drawing.Image]::FromFile("$EasyWinIcon"))
                    $AccountsTreeviewImageHashTable['0'] = "$EasyWinIcon"

                    # Position 1 = used as the default image that is loaded against the .treeview itself, thus shown at the top level for the Organizational Units, It gets overwritten by each node that is added
                    $AccountsTreeviewImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Icon OU LightYellow.png"))
                    $AccountsTreeviewImageHashTable['1'] = "$Dependencies\Images\Icons\Icon OU LightYellow.png"
                    
                    # Position 2 = used as the default image for the computer/account/entry node. Normalize-TreeViewData.ps1 populates it by default if an imageindex number doesn't exist for it already
                    $AccountsTreeviewImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Account Default.png"))
                    $AccountsTreeviewImageHashTable['2'] = "$Dependencies\Images\Icons\Account Default.png"
                    
                    $script:AccountsTreeviewImageHashTableCount = 2
                    
                    foreach ($Image in $script:AccountsTreeViewIconList.FullName) {
                        $AccountsTreeviewImageList.Images.Add([System.Drawing.Image]::FromFile("$Image"))
                        $script:AccountsTreeviewImageHashTableCount++
                        $AccountsTreeviewImageHashTable["$script:AccountsTreeviewImageHashTableCount"] = "$Image"
                    }

                    # Position -1 = currently unused
                    $AccountsTreeviewImageList.Images.Add([System.Drawing.Image]::FromFile("$high101bro_image"))
                    $script:AccountsTreeviewImageHashTableCount++
                    $AccountsTreeviewImageHashTable["$script:AccountsTreeviewImageHashTableCount"] = "$Dependencies\Images\high101bro Logo Color Transparent.png"


                    Update-FormProgress "$Dependencies\Code\System.Windows.Forms\TreeView\AccountsTreeView.ps1"
                    . "$Dependencies\Code\System.Windows.Forms\TreeView\AccountsTreeView.ps1"
                    $script:AccountsTreeView = New-Object System.Windows.Forms.TreeView -Property @{
                        Left   = $AccountsTreeNodeSearchComboBox.Left
                        Top    = $AccountsTreeNodeSearchButton.Top + $AccountsTreeNodeSearchButton.Height + ($FormScale * 5)
                        Width  = $AccountsTreeNodeSearchComboBox.Width + $AccountsTreeNodeSearchButton.Width + ($FormScale * 5)
                        Height = $FormScale * 558
                        # Note: size and location properties are are managed by 
                        Font              = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                        CheckBoxes        = $True
                        #LabelEdit         = $True  #Not implementing yet...
                        #not working # AfterLabelEdit = {  }
                        #not working #ShowRootLines     = $false
                        ShowLines         = $True
                        ShowNodeToolTips  = $True
                        Add_Click         = $AccountsTreeViewAdd_Click
                        Add_AfterSelect   = $AccountsTreeViewAdd_AfterSelect
                        #Add_MouseHover    = $AccountsTreeViewAdd_MouseHover
                        Add_MouseEnter    = {
                            $ComputerAndAccountTreeNodeViewPanel.bringtofront()
                            $ComputerAndAccountTreeViewTabControl.bringtofront()
                            $script:AccountsTreeView.bringtofront()
                        }
                        Add_MouseLeave    = $AccountsTreeViewAdd_MouseLeave
                        #ShortcutsEnabled  = $false                            #Used for ContextMenuStrip
                        ContextMenuStrip  = $AccountsListContextMenuStrip      #Ref Add_click
                        ShowPlusMinus     = $true
                        HideSelection     = $false
                        #not working #AfterSelect       = {}
                        ImageList         = $AccountsTreeviewImageList
                        ImageIndex        = 1
                    }
                    $script:AccountsTreeView.Sort()
                    $AccountsTreeviewTab.Controls.Add($script:AccountsTreeView)

                    Initialize-TreeViewData -Accounts
                    Normalize-TreeViewData -Accounts

                    # # Yes, save initially during the load because it will save any poulated default data
                    #Save-TreeViewData -Accounts
                    
                    # This will load data that is located in the saved file
                    Foreach($Account in $script:AccountsTreeViewData) {
                        AddTreeNodeTo-TreeViewData -Accounts -RootNode $script:TreeNodeAccountsList -Category $Account.CanonicalName -Entry $Account.Name -ToolTip $Account.SID -Metadata $Account
                    }
                    $script:AccountsTreeView.Nodes.Add($script:TreeNodeAccountsList)

                    # Controls the layout of the Accounts treeview
                    $script:AccountsTreeView.ExpandAll()
                    [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:AccountsTreeView.Nodes
                    foreach ($root in $AllTreeViewNodes) {
                        foreach ($Category in $root.Nodes) {
                            foreach ($Entry in $Category.nodes) { $Entry.Collapse() }
                        }
                    }
                    
$PoShEasyWin.Controls.Add($ComputerAndAccountTreeNodeViewPanel)


$ExecutionButtonPanel = New-Object System.Windows.Forms.Panel

            $MainRightTabControl = New-Object System.Windows.Forms.TabControl -Property @{
                Name   = "Main Tab Window for Computer List"
                Left   = 0
                Top    = 0
                Width  = $FormScale * 140
                ShowToolTips = $True
                Font         = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            }
            $ExecutionButtonPanel.Controls.Add($MainRightTabControl)

            Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Action.ps1"
            . "$Dependencies\Code\Main Body\Tabs\Action.ps1"

$PoShEasyWin.Controls.Add($ExecutionButtonPanel)


$InformationPanel = New-Object System.Windows.Forms.Panel

            $InformationTabControl = New-Object System.Windows.Forms.TabControl -Property @{
                Left   = 0
                Top    = 0
                Width  = $FormScale * 752
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ShowToolTips = $True
                Add_Click = { script:Minimize-MonitorJobsTab }
                Add_MouseHover = { $this.bringtofront() }
            }
            $InformationPanel.Controls.Add($InformationTabControl)

            Update-FormProgress "$Dependencies\Code\Main Body\Tabs\About.ps1"
            . "$Dependencies\Code\Main Body\Tabs\About.ps1"

            Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Results.ps1"
            . "$Dependencies\Code\Main Body\Tabs\Results.ps1"

            Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Monitor Jobs.ps1"
            . "$Dependencies\Code\Main Body\Tabs\Monitor Jobs.ps1"

            Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Endpoint Data.ps1"
            . "$Dependencies\Code\Main Body\Tabs\Endpoint Data.ps1"

            Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Account Data.ps1"
            . "$Dependencies\Code\Main Body\Tabs\Account Data.ps1"

            Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Query Exploration.ps1"
            . "$Dependencies\Code\Main Body\Tabs\Query Exploration.ps1"

$PoShEasyWin.Controls.Add($InformationPanel)


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


# Sets the GUI layout
Update-FormProgress "$Dependencies\Code\Main Body\Set-GuiLayout.ps1"
. "$Dependencies\Code\Main Body\Set-GuiLayout.ps1"
        if ( $script:GuiLayout -match 'Compact' ) {
            Set-GuiLayout -Compact
            $script:CompactViewRadioButton.checked = $true
        }
        elseif ( $script:GuiLayout -match 'Extended' ) {
            Set-GuiLayout -Extended
            $script:ExtendedViewRadioButton.checked = $true
            $MainCenterMainTab.Controls.Add($PowerShellTerminalButton)
        }
        else {
            Set-GuiLayout -Extended
            $script:ExtendedViewRadioButton.checked = $true
            $MainCenterMainTab.Controls.Add($PowerShellTerminalButton)
        }
        $InformationTabControlOriginalTop    = $InformationPanel.Top
        $InformationTabControlOriginalHeight = $InformationPanel.Height


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

##########################################################
# Monitor Jobs --- Individual Execution --- Beta Testing #
##########################################################

# This executes each selected command from the Commands' TreeView
Update-FormProgress "$Dependencies\Code\Execution\Individual Execution\Execute-IndividualCommand.ps1"
. "$Dependencies\Code\Execution\Individual Execution\Execute-IndividualCommand.ps1"



$ExecuteScriptHandler = {
    [System.Windows.Forms.Application]::UseWaitCursor = $true

    if ($ResultsFolderAutoTimestampCheckbox.Checked) {
        $script:CollectedDataTimeStampDirectory = "$CollectedDataDirectory\$((Get-Date).ToString('yyyy-MM-dd HH.mm.ss'))"
        $script:CollectionSavedDirectoryTextBox.Text = $script:CollectedDataTimeStampDirectory
    }

    # Clears the Progress bars
    $script:ProgressBarEndpointsProgressBar.Value     = 0
    $script:ProgressBarQueriesProgressBar.Value       = 0
    $script:ProgressBarEndpointsProgressBar.BackColor = 'White'
    $script:ProgressBarQueriesProgressBar.BackColor   = 'White'

    if ($script:ComputerListProvideCredentialsCheckBox.Checked) { $Username = $script:Credential.UserName}
    else {$Username = $PoShEasyWinAccountLaunch }

    # Clears previous and generates new computerlist
    $script:ComputerList = @()
    Generate-ComputerList

    # Assigns the path to save the Collections to
    $script:CollectedDataTimeStampDirectory = $script:CollectionSavedDirectoryTextBox.Text

    # Location of Uncompiled Results
    $script:IndividualHostResults = "$script:CollectedDataTimeStampDirectory\Results By Endpoints"

    # This function compiles the selected treeview comamnds, placing the proper command type and protocol into a variable list to be executed.
    Compile-SelectedCommandTreeNode

    if ($script:EventLogsStartTimePicker.Checked -xor $script:EventLogsStopTimePicker.Checked) {
        # This brings specific tabs to the forefront/front view
        $MainLeftTabControl.SelectedTab = $Section1CollectionsTab
        #$InformationTabControl.SelectedTab = $Section3ResultsTab
        #$InformationTabControl.SelectedTab = $Section3MonitorJobsTab

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
        $MainCenterTabControl.SelectedTab = $MainCenterMainTab
        #$MainCenterTabControl.SelectedTab = $Section2StatisticsTab

        $MainRightTabControl.SelectedTab  = $Section3ActionTab
        #$InformationTabControl.SelectedTab = $Section3ResultsTab
        #$InformationTabControl.SelectedTab = $Section3MonitorJobsTab
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
        if ($NetworkConnectionSearchCommandLineCheckbox.checked)        { $CountCommandQueries++ ; $script:WinRMCommandCount++ }
        if ($NetworkConnectionSearchExecutablePathCheckbox.checked)     { $CountCommandQueries++ ; $script:WinRMCommandCount++ }
    

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


        if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs' -or 
            $script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Individual Execution' -or 
            $script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Beta Testing') {
            Create-TreeViewCheckBoxArray -Endpoint

            # Compares the computerlist against the previous computerlist queried (generated when previous query is completed )
            # If the computerlists changed, it will prompt you to do connections tests and generate a new computerlist if endpoints fail
            if ((Compare-Object -ReferenceObject $script:ComputerList -DifferenceObject $script:ComputerListHistory) -or `
                !(([bool]($script:RpcCommandCount   -gt 0) -eq [bool]$script:RpcCommandCountHistory) -and `
                    ([bool]($script:SmbCommandCount   -gt 0) -eq [bool]$script:SmbCommandCountHistory) -and `
                    ([bool]($script:WinRmCommandCount -gt 0) -eq [bool]$script:WinRmCommandCountHistory))
            ) {
                if ($script:RpcCommandCount -gt 0 ) {
                    if (Verify-Action -Title "RPC Port Check" -Question "Conduct a RPC Port Check to remove unresponsive endpoints?`n`nEndpoints:  $($script:ComputerList.count)" -Computer $($script:ComputerTreeViewSelected -join ', ')) {
                        Check-Connection -CheckType "RPC Port Check" -MessageTrue "RPC Port 135 is Open" -MessageFalse "RPC Port 135 is Closed"
                        Generate-ComputerList
                    }
                }
                if ($script:SmbCommandCount -gt 0 ) {
                    if (Verify-Action -Title "SMB Port Check" -Question "Conduct a SMB Port Check to remove unresponsive endpoints?`n`nEndpoints:  $($script:ComputerList.count)" -Computer $($script:ComputerTreeViewSelected -join ', ')) {
                        Check-Connection -CheckType "SMB Port Check" -MessageTrue "SMB Port 445 is Open" -MessageFalse "SMB Port 445 is Closed"
                        Generate-ComputerList
                    }
                }
                if ($script:WinRMCommandCount -gt 0 ) {
                    if (Verify-Action -Title "WinRM Check" -Question "Conduct a WinRM Check to remove unresponsive endpoints?`n`nEndpoints:  $($script:ComputerList.count)" -Computer $($script:ComputerTreeViewSelected -join ', ')) {
                        Check-Connection -CheckType "WinRM Check" -MessageTrue "WinRM is Available" -MessageFalse "WinRM is Unavailable"
                        Generate-ComputerList
                    }
                }
            }

            if (Verify-Action -Title "Execution Verification" -Question "Connecting Account:`n$Username`n`nNumber of Queries:  $($QueryCount)`n`nEndpoints:  $($script:ComputerList.count)" -Computer $($script:ComputerList -join ', ')) {
            
                $ProgressBarPanel.Controls.Add($ProgressBarEndpointsLabel)
                $ProgressBarPanel.Controls.Add($script:ProgressBarEndpointsProgressBar)
                $ProgressBarPanel.Controls.Add($ProgressBarQueriesLabel)
                $ProgressBarPanel.Controls.Add($script:ProgressBarQueriesProgressBar)

                $script:CollectedDataTimeStampDirectory = $script:CollectionSavedDirectoryTextBox.Text
                New-Item -Type Directory -Path $script:CollectedDataTimeStampDirectory -ErrorAction SilentlyContinue

                if ($script:CommandsCheckedBoxesSelected.count -gt 0) {
                    if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Beta Testing') { 
                        Execute-IndividualCommand -UseSession
                    }
                    else { 
                        Execute-IndividualCommand -UseComputerName 
                    }
                }

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
                if ($FileSearchDirectoryListingCheckbox.Checked) { . "$Dependencies\Code\Execution\Individual Execution\IndividualQuery-FileSearchDirectoryListing.ps1" }

                # File Search
                # Combines the inputs from the various GUI fields to query for filenames and/or file hashes
                if ($FileSearchFileSearchCheckbox.Checked) { . "$Dependencies\Code\Execution\Individual Execution\IndividualQuery-FileSearchFileSearch.ps1" }

                # Alternate Data Streams
                # Combines the inputs from the various GUI fields to query for Alternate Data Streams
                if ($FileSearchAlternateDataStreamCheckbox.Checked) { . "$Dependencies\Code\Execution\Individual Execution\IndividualQuery-FileSearchAlternateDataStream.ps1" }

                if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Individual Execution' -and $NetworkEndpointPacketCaptureCheckBox.Checked) {
                    [System.Windows.Forms.MessageBox]::Show("The Individual Execution mode does not support Packet Capture, use either Monitor Jobs or Session Based mode.","Incompatible Mode",'Ok',"Info")
                }
                else {
                    # Endpoint Packet Capture
                    # Conducts a packet capture on the endpoints using netsh
                    if ($NetworkEndpointPacketCaptureCheckBox.Checked) { . "$Dependencies\Code\Execution\Individual Execution\IndividualCapture-EndpointPacketCaptureNetSh.ps1" }
                }

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

                # Network Connection Search Command Line
                # Checks network connection for command line arguments and only returns those that match
                if ($NetworkConnectionSearchCommandLineCheckbox.checked) { . "$Dependencies\Code\Execution\Individual Execution\IndividualQuery-NetworkConnectionSearchCommandLine.ps1" }

                # Network Connection Search Execution Full Path
                # Checks network connection for those with execution full paths and only returns those that match
                if ($NetworkConnectionSearchExecutablePathCheckbox.checked) { . "$Dependencies\Code\Execution\Individual Execution\IndividualQuery-NetworkConnectionSearchExecutablePath.ps1" }
        
                # Sysmon
                # Pushes Sysmon to remote hosts and configure it with the selected config .xml file
                # If sysmon is already installed, it will update the config .xml file instead
                # Symon and its supporting files are removed afterwards        
                if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Individual Execution' -and $SysinternalsSysmonCheckbox.Checked) {
                    [System.Windows.Forms.MessageBox]::Show("The Individual Execution mode does not support Sysmon, you need to use the Session Based mode.","Incompatible Mode",'Ok',"Info")
                }
                elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs' -and $SysinternalsSysmonCheckbox.Checked) {
                    [System.Windows.Forms.MessageBox]::Show("The Monitor Jobs mode does not support Sysmon, you need to use the Session Based mode.","Incompatible Mode",'Ok',"Info")
                }
                #if ($SysinternalsSysmonCheckbox.Checked) { . "$Dependencies\Code\Execution\Individual Execution\IndividualPush-Sysmon.ps1" }

                # Autoruns
                # Pushes Autoruns to remote hosts and pulls back the autoruns results to be opened locally
                # Autoruns and its supporting files are removed afterwards
                if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Individual Execution' -and $SysinternalsAutorunsCheckbox.Checked) {
                    [System.Windows.Forms.MessageBox]::Show("The Individual Execution mode does not support AutoRuns, you need to use the Session Based mode.","Incompatible Mode",'Ok',"Info")
                }
                elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs' -and $SysinternalsAutorunsCheckbox.Checked) {
                    [System.Windows.Forms.MessageBox]::Show("The Monitor Jobs mode does not support AutoRuns, you need to use the Session Based mode.","Incompatible Mode",'Ok',"Info")
                }
                #if ($SysinternalsAutorunsCheckbox.Checked) { . "$Dependencies\Code\Execution\Individual Execution\IndividualPush-Autoruns.ps1" }

                # Procmon
                # Pushes Process Monitor to remote hosts and pulls back the procmon results to be opened locally
                # Diskspace is calculated on local and target hosts to determine if there's a risk
                # Process Monitor and its supporting files are removed afterwards
                if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Individual Execution' -and $SysinternalsProcessMonitorCheckbox.Checked) {
                    [System.Windows.Forms.MessageBox]::Show("The Individual Execution mode does not support Procmon, you need to use the Session Based mode.","Incompatible Mode",'Ok',"Info")
                }
                elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs' -and $SysinternalsProcessMonitorCheckbox.Checked) {
                    [System.Windows.Forms.MessageBox]::Show("The Monitor Jobs mode does not support Procmon, you need to use the Session Based mode.","Incompatible Mode",'Ok',"Info")
                }
                #if ($SysinternalsProcessMonitorCheckbox.Checked) { . "$Dependencies\Code\Execution\Individual Execution\IndividualPush-Procmon.ps1" }

                # User Specified Files and Custom Script
                # Pushes user Specified Files and Custom Script to the endpoints
                # The script has to manage all the particulars with the executable; execution, results retrieval, cleanup, etc.
                if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Individual Execution' -and $ExeScriptUserSpecifiedExecutableAndScriptCheckbox.Checked) {
                    [System.Windows.Forms.MessageBox]::Show("The Individual Execution mode does not support 'User Specified Files and Custom Script', you need to use the Session Based mode.","Incompatible Mode",'Ok',"Info")
                }
                elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs' -and $ExeScriptUserSpecifiedExecutableAndScriptCheckbox.Checked) {
                    [System.Windows.Forms.MessageBox]::Show("The Monitor Jobs mode does not support 'User Specified Files and Custom Script', you need to use the Session Based mode.","Incompatible Mode",'Ok',"Info")
                }
                #if ($ExeScriptUserSpecifiedExecutableAndScriptCheckbox.checked) { . "$Dependencies\Code\Execution\Individual Execution\IndividualPush-ExecutableAndScript.ps1" }

                Start-Sleep -Seconds 1
                if ($script:Section3MonitorJobsResizeCheckbox.checked){
                    script:Maximize-MonitorJobsTab
                }
                $PoShEasyWin.Refresh()
                Completed-QueryExecution
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
            $InformationTabControl.SelectedTab = $Section3ResultsTab

            Compile-QueryCommands

            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("Attempting to Establish Sessions to $($script:ComputerList.Count) Endpoints")
            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Attempting to Establish Sessions to $($script:ComputerList.Count) Endpoints"
            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "[!] $($script:ComputerList -join ', ')"

            $ProgressBarPanel.Controls.Add($ProgressBarEndpointsLabel)
            $ProgressBarPanel.Controls.Add($script:ProgressBarEndpointsProgressBar)
            $ProgressBarPanel.Controls.Add($ProgressBarQueriesLabel)
            $ProgressBarPanel.Controls.Add($script:ProgressBarQueriesProgressBar)

            $script:CollectedDataTimeStampDirectory = $script:CollectionSavedDirectoryTextBox.Text
            New-Item -Type Directory -Path $script:CollectedDataTimeStampDirectory -ErrorAction SilentlyContinue

            if (Verify-Action -Title "Execution Verification" -Question "Connecting Account:  $Username`n`nNumber of Queries:  $($QueryCount)`n`nEndpoints:  $($script:ComputerList.count)" -Computer $($script:ComputerList -join ', ')) {
                if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
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
                if ($FileSearchDirectoryListingCheckbox.Checked) { . "$Dependencies\Code\Execution\Session Based\SessionQuery-FileSearchDirectoryListing.ps1" }

                # File Search
                # Combines the inputs from the various GUI fields to query for filenames and/or file hashes
                if ($FileSearchFileSearchCheckbox.Checked) { . "$Dependencies\Code\Execution\Session Based\SessionQuery-FileSearchFileSearch.ps1" }

                # Alternate Data Stream
                # Combines the inputs from the various GUI fields to query for Alternate Data Streams
                if ($FileSearchAlternateDataStreamCheckbox.Checked) { . "$Dependencies\Code\Execution\Session Based\SessionQuery-FileSearchAlternateDataStream.ps1" }

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

                # Network Connection Search Command Line
                # Checks network connection for command line arguments and only returns those that match
                if ($NetworkConnectionSearchCommandLineCheckbox.checked) { . "$Dependencies\Code\Execution\Session Based\SessionQuery-NetworkConnectionSearchCommandLine.ps1" }

                # Network Connection Search Execution Full Path
                # Checks network connection for those with execution full paths and only returns those that match
                if ($NetworkConnectionSearchExecutablePathCheckbox.checked) { . "$Dependencies\Code\Execution\Session Based\SessionQuery-NetworkConnectionSearchExecutablePath.ps1" }

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
        elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Beta Testing' -and $script:RpcCommandCount -eq 0 -and $script:SmbCommandCount -eq 0 ) {
            if (Verify-Action -Title "Beta Testing" -Question "You are about to use PoSh-EasyWin in the beta testing execution mode. This feature is testing new concepts for querying and and data management.`n`Do not use in production and please report any bugs if you're testing it out." -Computer $($script:ComputerTreeViewSelected -join ', ')) {

            }
        }
    }

    $InformationTabControl.SelectedTab = $script:Section3MonitorJobsTab
    $PoShEasyWin.Refresh()

    [System.Windows.Forms.Application]::UseWaitCursor = $false
}


# Selects the computers to query using command line parameters and arguments
Update-FormProgress "$Dependencies\Code\Execution\Command Line\Select-ComputersAndCommandsFromCommandLine.ps1"
. "$Dependencies\Code\Execution\Command Line\Select-ComputersAndCommandsFromCommandLine.ps1"

# This needs to be here to execute the script
# Note the Execution button itself is located in the Select Computer section
$script:ComputerListExecuteButton.Add_Click($ExecuteScriptHandler)


$script:PoShEasyWinStatusBar = New-Object System.Windows.Forms.StatusBar
$PoShEasyWin.Controls.Add($script:PoShEasyWinStatusBar)


# Starts the ticker for the GUI and adds the status bar
Update-FormProgress "$Dependencies\Code\Main Body\Start-FormTicker.ps1"
. "$Dependencies\Code\Main Body\Start-FormTicker.ps1"

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
    $script:ProgressBarSelectionForm.Topmost = $false
}