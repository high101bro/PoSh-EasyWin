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
    Version        : Version 7.2.1
    Updated        : 01 Mar 2022
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
    Optional       : PsExec.exe, Procmon.exe, Sysmon.exe,
                     etl2pcapng.exe, kitty.exe, plink.exe, chainsaw.exe, WxTCmd.exe

    Author         : Daniel S. Komnick (high101bro)
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
            - Unblock-File -Path .\PoSh-EasyWin.ps1
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
    Example 1
    All PoSh-EasyWin PowerShell scripts are signed, you can import the public certificate and run them.

    The script will normally be blocked from execution. 
    PS C:\PoSh-EasyWin> .\PoSh-EasyWin.ps1

    How to check the execution policy.
    PS C:\PoSh-EasyWin> Get-ExecutionPolicy

    How to import the certificate to allow for exection of signed scripts
    PS C:\PoSh-EasyWin> Import-Certificate -FilePath ".\PoSh-EasyWin_Public_Certificate.cer" -CertStoreLocation Cert:\CurrentUser\Root

    How to check the authenticode signature.
    PS C:\PoSh-EasyWin> Get-AuthenticodeSignature .\PoSh-EasyWin.ps1

    How to set the execution policy to either RemoteSigned or AllSigned. Either method will work, though AllSigned will prompt you with info.
    PS C:\PoSh-EasyWin> Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
    PS C:\PoSh-EasyWin> Set-ExecutionPolicy -ExecutionPolicy AllSigned

    # The script should run now. 
    PS C:\PoSh-EasyWin> .\PoSh-EasyWin.ps1

    .EXAMPLE
    Example 2
    Scripts downloaded from the internet are blocked for execution as a Windodws' security precaution. If there is an error with Example 1, or you do not want to import PoSh-EasyWin's public certificate, you can do the following:

        Unblock-File .\PoSh-EasyWin.ps1
        .\PoSh-EasyWin.ps1

            -or

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
    DefaultParameterSetName='GUI',
    HelpURI='https://github.com/high101bro/PoSh-EasyWin',
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

# Font: Display --> Black Ops One
# https://flamingtext.com/logo/Design-Style
# https://www11.flamingtext.com/net-fu/dynamic.cgi?script=style-logo&text=PoSh-EasyWin&fontname=Black+Ops+One&fillTextColor=%23006fff&fillOutlineColor=%2320d

# Generates the GUI and contains the majority of the script
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

#============================================================================================================================================================
# Variables
#============================================================================================================================================================

$ErrorActionPreference = "SilentlyContinue"

# Script Launch Time - This in placed within both the title of the Main PoSh-EasyWin form and the title of the System Tray Notification
# Useful if multiple instances of PoSh-EasyWin are launched and you want to use the Abort/Reload or Exit Tool buttons on the corrent instance
$InitialScriptLoadTime = Get-Date

# The path of PoSh-EasyWin when executed
$PewScriptPath      = $myinvocation.mycommand.definition
$PewScript          = "& '$PewScriptPath'"
$PewScriptProcessId = [System.Diagnostics.Process]::GetCurrentProcess().Id

# Initial Size of PoSh-EasyWin. This is modified against the $FormSale value selected during setup
$FormOriginalWidth = 1435
$FormOriginalHeight = 685

# Location PoSh-EasyWin will save files
$PewRoot                  = $PSScriptRoot #Deprecated# Split-Path -parent $MyInvocation.MyCommand.Definition
$PewUserData              = "$PewRoot\User Data"
    if (-not (Test-Path $PewUserData )) {New-Item -ItemType Directory -Path $PewUserData -Force}
$PewLogFile               = "$PewUserData\Log File.txt"
$CredentialManagementPath = "$PewUserData\Credential Management\"
$EndpointTreeNodeFileSave = "$PewUserData\TreeView Data - Endpoint.csv"
$AccountsTreeNodeFileSave = "$PewUserData\TreeView Data - Accounts.csv"
$CommandsUserAddedWinRM   = "$PewUserData\Commands - User Added WinRM.csv"
$CommandsUserAddedSSH     = "$PewUserData\Commands - User Added SSH.csv"
$CommandsCustomGrouped    = "$PewUserData\Commands - Custom Group Commands.xml"
$PewOpNotes               = "$PewUserData\OpNotes.txt"
$PewSettings              = "$PewUserData\Settings"
$ActiveDirectoryEndpoint  = "$PewSettings\Active Directory Hostname.txt"

# Name of Collected Data Directory
$PewCollectedData   = "$PewUserData\Collected Data"
    if (-not (Test-Path $PewCollectedData )) { New-Item -ItemType Directory -Path $PewCollectedData -Force }

    # Location of separate queries
    $CollectedDataTimeStamp = "$PewCollectedData\$((Get-Date).ToString('yyyy-MM-dd HH.mm.ss'))"

    $script:SaveLocation = $CollectedDataTimeStamp
    #$script:SaveLocation = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)\Collected Data\$((Get-Date).ToString('yyyy-MM-dd HH.mm.ss'))"

$DemoData = "$PewRoot\Examples\Demo Data"
$EndpointTreeNodeFileSaveDemo = "$DemoData\TreeView Data - Endpoint.csv"
$AccountsTreeNodeFileSaveDemo = "$DemoData\TreeView Data - Accounts.csv"
$CommandsUserAddedWinRMDemo   = "$DemoData\Commands - User Added WinRM.csv"
$CommandsUserAddedSSHDemo     = "$DemoData\Commands - User Added SSH.csv"
$CommandsCustomGroupedDemo    = "$DemoData\Commands - Custom Group Commands.xml"

$Dependencies = "$PewRoot\Dependencies"
$CommandsAndScripts      = "$Dependencies\Commands & Scripts"
$CommandsEndpoint        = "$CommandsAndScripts\Commands - Endpoint.csv"
$CommandsActiveDirectory = "$CommandsAndScripts\Commands - Active Directory.csv"
$PSWriteHTMLDirectory    = "$Dependencies\Code\PSWriteHTML"
   
# Location of Event Logs Commands
$CommandsEventLogsDirectory = "$Dependencies\Event Log Info"
# CSV file of Event IDs
$EventIDsFile               = "$CommandsEventLogsDirectory\Event IDs.csv"
# CSV file from Microsoft detailing Event IDs to Monitor
$EventLogsWindowITProCenter = "$CommandsEventLogsDirectory\Individual Selection\Event Logs to Monitor - Window IT Pro Center.csv"

# Location of External Programs directory
$ExternalPrograms = "$Dependencies\Executables"
$PsExecPath       = "$ExternalPrograms\PsExec.exe"
$kitty_ssh_client = "$ExternalPrograms\KiTTY\kitty-0.74.4.7.exe"
$plink_ssh_client = "$ExternalPrograms\plink.exe"

$TagAutoListFile   = "$Dependencies\Tags - Auto Populate.txt"
$CustomPortsToScan = "$Dependencies\Custom Ports To Scan.txt"

$EasyWinIcon       = "$Dependencies\Images\Icons\favicon.ico"
$high101bro_image  = "$Dependencies\Images\high101bro Logo Color Transparent.png"

# Send Files listbox value store
$script:SendFilesValueStoreListBox = @()

# Used to track the number of previous queries selected
$script:PreviousQueryCount = 0
# Keeps track of the number of RPC protocol commands selected, if the value is ever greater than one, it'll set the collection mode to 'Monitor Jobs'
$script:RpcCommandCount = 0
# Maintains the count of all the queries selected
$script:SectionQueryCount = 0
function Update-QueryCount {
    if ($this.checked){$script:SectionQueryCount++}
    else {$script:SectionQueryCount--}
}


# Creates Shortcut for PoSh-EasyWin on Desktop
$FileToShortCut      = $($myinvocation.mycommand.definition)
$ShortcutDestination = "C:\Users\$($env:USERNAME)\Desktop\PoSh-EasyWin.lnk"
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
            if ($ShowTerminal) { Start-Process PowerShell.exe -Verb runAs -ArgumentList $PewScript }
            else               { Start-Process PowerShell.exe -Verb runAs -ArgumentList $PewScript -WindowStyle Hidden }
            exit
        }
        'No' {
            if ($ShowTerminal) { Start-Process PowerShell.exe -ArgumentList "$PewScript -SkipEvelationCheck" }
            else               { Start-Process PowerShell.exe -ArgumentList "$PewScript -SkipEvelationCheck" -WindowStyle Hidden }
            exit
        }
        'Cancel' {exit}
    }
}
elseif (-NOT $SkipEvelationCheck) {
    if ($ShowTerminal) { Start-Process PowerShell.exe -Verb runAs -ArgumentList "$PewScript -SkipEvelationCheck" }
    else               { Start-Process PowerShell.exe -Verb runAs -ArgumentList "$PewScript -SkipEvelationCheck" -WindowStyle Hidden }
    exit
}
elseif ($SkipEvelationCheck -and ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "`nThe " -ForegroundColor Green -NoNewline
    Write-Host "-SkipElevationCheck " -NoNewline
    Write-Host "parameter is not needed if the terminal used already has elevated permissions.`n" -ForegroundColor Green
}

$FormAdminCheck = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

. "$Dependencies\Code\Main\Import-FunctionsForSetup.ps1"

if (-Not (Test-Path $PewSettings)){New-Item -ItemType Directory $PewSettings | Out-Null}

# Logs what account ran the script and when
Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "===================================================================================================="
Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "PoSh-EasyWin Started By: $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"

# This prompts the user for accepting the GPLv3 License
if ($AcceptEULA) {
    Write-Host  "You accepted the EULA." -ForeGroundColor Green
    Write-Host "For more infor, visit https://www.gnu.org/licenses/gpl-3.0.html or view a copy in the Dependencies folder.`n" -ForeGroundColor Yellow
}
else {
    Get-Content "$Dependencies\GPLv3 Notice.txt" | Out-GridView -Title 'PoSh-EasyWin User Agreement' -PassThru | Set-Variable -Name UserAgreement
    if ($UserAgreement) {
        Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "PoSh-EasyWin User Agreemennt Accepted By: $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"
        Write-Host "You accepted the EULA." -ForeGroundColor Green
        Write-Host "For more infor, visit https://www.gnu.org/licenses/gpl-3.0.html or view a copy in the Dependencies folder.`n" -ForeGroundColor Yellow
        Start-Sleep -Seconds 1
    }
    else {
        [system.media.systemsounds]::Exclamation.play()
        Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "PoSh-EasyWin User Agreemennt NOT Accepted By: $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"
        Write-Host "You must accept the EULA to continue." -ForeGroundColor Red
        Write-Host "For more infor, visit https://www.gnu.org/licenses/gpl-3.0.html or view a copy in the Dependencies folder.`n" -ForeGroundColor Yellow
        exit
    }
    Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "===================================================================================================="
}


if (-not (Test-Path "$PewSettings\Form Scaling Modifier.txt")){
    Show-FormScaleFrom
    if ($script:ResolutionSetOkay) {$null}
    else {exit}
    $FormScale = $script:ResolutionCheckScalingTrackBar.Value / 10
}
else {
    $FormScale = [decimal](Get-Content "$PewSettings\Form Scaling Modifier.txt")
}


if (-not (Test-Path "$PewSettings\User Notice And Acknowledgement.txt")) {
    Show-ReadMe
}


# Check for and prompt to install the PSWriteHTML module
if ((Test-Path "$PewSettings\User Notice And Acknowledgement.txt") -and -not (Test-Path "$PewSettings\PSWriteHTML Module Install.txt")) {
    if (-not (Get-InstalledModule -Name PSWriteHTML)) {
        $InstallPSWriteHTML = [System.Windows.Forms.MessageBox]::Show("PoSh-EasyWin can make use of the PSWriteHTML module to generate dynamic graphs. If this third party module is installed, it provides another means to represent data in an intuitive manner using a web browser. Though this module has been scanned and reviewed, any third party modules may pose a security risk. The PSWriteHTML module files have been packaged with PoSh-EasyWin, but are not being used unless its import. More information can be located at the following:
    https://www.powershellgallery.com/packages/PSWriteHTML
    https://github.com/EvotecIT/PSWriteHTML

This selection is persistent for this tool, but can be modified within the settings directory. Do you want to import the PSWriteHTML module?","Install PSWriteHTML Module",'YesNo',"Info")
        switch ($InstallPSWriteHTML) {
            'Yes' {
                Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "Opted to import the PSWriteHTML module"
                'Import PSWriteHTML: Yes' | Set-Content "$PewSettings\PSWriteHTML Module Install.txt"
            }
            'No' {
                'Import PSWriteHTML: No' | Set-Content "$PewSettings\PSWriteHTML Module Install.txt"
             }
        }
    }
    else {
        Write-LogEntry -LogFile $PewLogFile -NoTargetComputer -Message "PSWriteHTML was detected as being installed."
        'Import PSWriteHTML: Yes' | Set-Content "$PewSettings\PSWriteHTML Module Install.txt"
    }
}
if (Test-Path -Path "$Dependencies\Modules\PSWriteHTML"){
    if ((Get-Content "$PewSettings\PSWriteHTML Module Install.txt") -match 'Yes') {
        Import-Module -Name "$Dependencies\Modules\PSWriteHTML\*\PSWriteHTML.psm1" -Force
    }
}


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

Update-FormProgress "$Dependencies\Code\Main\Import-FunctionsForMain.ps1"
. "$Dependencies\Code\Main\Import-FunctionsForMain.ps1"

Update-FormProgress "$Dependencies\Code\Main\Import-FunctionsForCredentialManagement.ps1"
. "$Dependencies\Code\Main\Import-FunctionsForCredentialManagement.ps1"

Update-FormProgress "$Dependencies\Code\Main\Import-FunctionsForImportData.ps1"
. "$Dependencies\Code\Main\Import-FunctionsForImportData.ps1"

Update-FormProgress "$Dependencies\Code\Main\Import-FunctionsForTreeView.ps1"
. "$Dependencies\Code\Main\Import-FunctionsForTreeView.ps1"

Update-FormProgress "$Dependencies\Code\Main\Import-FunctionsForEnumeration.ps1"
. "$Dependencies\Code\Main\Import-FunctionsForEnumeration.ps1"

Start-Process -FilePath powershell.exe -ArgumentList  "-WindowStyle Hidden -Command Invoke-Command {${function:Show-SystemTrayNotifyIcon}} -ArgumentList @('$PewCollectedData','$CommandsAndScripts','$CommandsEndpoint','$CommandsActiveDirectory',$PewScriptProcessId,[bool]'`$$FormAdminCheck','$EasyWinIcon','$Font',$($PewScript.trim('&')),'$InitialScriptLoadTime')" -PassThru `
| Select-Object -ExpandProperty Id `
| Set-Variable FormHelperProcessId

# The Show-ProgressBar.ps1 is topmost upon loading to ensure it's displayed intially, but is then able to be move unpon
$ResolutionCheckForm.topmost = $false

$PoShEasyWinAccountLaunch = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

$PoShEasyWin = New-Object System.Windows.Forms.Form -Property @{
    Text    = "PoSh-EasyWin   ($PoShEasyWinAccountLaunch)  [$InitialScriptLoadTime]"
    Icon    = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
    Width   = $FormScale * $FormOriginalWidth
    Height  = $FormScale * $FormOriginalHeight
    TopMost = $true
    AutoScroll  = $false
    ControlBox  = $true
    MaximizeBox = $false
    MinimizeBox = $true
    StartPosition  = "CenterScreen"
    FormBorderStyle =  'Sizable' #  Fixed3D, FixedDialog, FixedSingle, FixedToolWindow, None, Sizable, SizableToolWindow
    Add_Load = {
        $This.TopMost = $false
        if ((Test-Path "$PewSettings\Use Selected Credentials.txt")) {
            $SelectedCredentialName = Get-Content "$PewSettings\Use Selected Credentials.txt"
            $script:SelectedCredentialPath = Get-ChildItem "$CredentialManagementPath\$SelectedCredentialName"
            $script:Credential      = Import-CliXml $script:SelectedCredentialPath
            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("Credentials:  $SelectedCredentialName")
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
}

$TopLeftPanel = New-Object System.Windows.Forms.Panel -Property @{
    Left   = $FormScale * 5
    Top    = $FormScale * 5
    Width  = $FormScale * 460
    Height = $FormScale * 45
    BorderStyle = 'FixedSingle'
}
$PoShEasyWin.Controls.Add($TopLeftPanel)

    $PoShEasyWinLogoPictureBox = New-Object Windows.Forms.PictureBox -Property @{
        Text   = "PoSh-EasyWin Image"
        Left   = $FormScale * 5
        Top    = $FormScale * 5
        Width  = $FormScale * 285
        Height = $FormScale * 35
        Image  = [System.Drawing.Image]::Fromfile("$Dependencies\Images\PoSh-EasyWin Image 01.png")
        SizeMode = 'StretchImage'
    }
    $TopLeftPanel.Controls.Add($PoShEasyWinLogoPictureBox)


$QueryAndCollectionPanel = New-Object System.Windows.Forms.Panel -Property @{
    Left   = $FormScale * 5
    Top    = $TopLeftPanel.Top + $TopLeftPanel.Height
    Width  = $FormScale * 460
    Height = $FormScale * 590
    BorderStyle = 'FixedSingle'
}
    $MainLeftTabControlImageList = New-Object System.Windows.Forms.ImageList -Property @{
        ImageSize = @{
            Width  = $FormScale * 16
            Height = $FormScale * 16
        }
    }
    # Index 0 = Commands
    $MainLeftTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\PowerShell.png"))
    # Index 1 = Search
    $MainLeftTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Search.png"))
    # Index 2 = Interaction
    $MainLeftTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Interaction.png"))
    # Index 3 = Enumeration / Scanning
    $MainLeftTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Radar-Scanning.png"))
    # Index 4 = OpNotes
    $MainLeftTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Notes.png"))
    # Index 5 = Info
    $MainLeftTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Info.png"))


    $MainLeftTabControl = New-Object System.Windows.Forms.TabControl -Property @{
        Left   = 0
        Width  = $FormScale * 460
        Height = $FormScale * 590
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,2,1)
        ForeColor  = "Blue"
        ImageList  = $MainLeftTabControlImageList
        Appearance = [System.Windows.Forms.TabAppearance]::Buttons
        Hottrack   = $true
    }
    $QueryAndCollectionPanel.Controls.Add($MainLeftTabControl)

    # This tab contains all the individual commands within the command treeview, such as the PowerShell, WMI, and Native Commands using the WinRM, RPC/DCOM, and SMB protocols
    Update-FormProgress "$Dependencies\Code\Main\Tabs\Commands.ps1"
    . "$Dependencies\Code\Main\Tabs\Commands.ps1"

    Update-FormProgress "$Dependencies\Code\Main\Tabs\Search.ps1"
    . "$Dependencies\Code\Main\Tabs\Search.ps1"

    Update-FormProgress "$Dependencies\Code\Main\Tabs\Interactions.ps1"
    . "$Dependencies\Code\Main\Tabs\Interactions.ps1"

    Update-FormProgress "$Dependencies\Code\Main\Tabs\Enumeration.ps1"
    . "$Dependencies\Code\Main\Tabs\Enumeration.ps1"

    Update-FormProgress "$Dependencies\Code\Main\Tabs\Checklists.ps1"
    . "$Dependencies\Code\Main\Tabs\Checklists.ps1"

    Update-FormProgress "$Dependencies\Code\Main\Tabs\OpNotes.ps1"
    . "$Dependencies\Code\Main\Tabs\OpNotes.ps1"

    Update-FormProgress "$Dependencies\Code\Main\Tabs\Info.ps1"
    . "$Dependencies\Code\Main\Tabs\Info.ps1"

$PoShEasyWin.Controls.Add($QueryAndCollectionPanel)


$ComputerAndAccountTreeNodeViewPanel = New-Object System.Windows.Forms.Panel -Property @{
    Left   = $QueryAndCollectionPanel.Left + $QueryAndCollectionPanel.Width
    Top    = $FormScale * 5
    Width  = $FormScale * 200
    Height = $FormScale * 635
   BorderStyle = 'FixedSingle'
}

    Update-FormProgress "$Dependencies\Code\Main\Context Menu Strip\Display-ContextMenuForAccountsTreeNode.ps1"
    . "$Dependencies\Code\Main\Context Menu Strip\Display-ContextMenuForAccountsTreeNode.ps1"
    Display-ContextMenuForAccountsTreeNode -ClickedOnArea

    $ComputerAndAccountTreeViewTabControlImageList = New-Object System.Windows.Forms.ImageList -Property @{
        ImageSize = @{
            Width  = $FormScale * 16
            Height = $FormScale * 16
        }
    }
    # Index 0 = Endpoints
    $ComputerAndAccountTreeViewTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Endpoint-Default.png"))
    # Index 1 = Accounts
    $ComputerAndAccountTreeViewTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Accounts.png"))

    $ComputerAndAccountTreeViewTabControl = New-Object System.Windows.Forms.TabControl -Property @{
        Left   = 0
        Top    = 0
        Width  = $FormScale * 192
        Height = $FormScale * 635
        Appearance = [System.Windows.Forms.TabAppearance]::Buttons
        Hottrack   = $true
        Dock       = 'Fill'
        Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,2,1)
        Add_Click  = {
            if ($This.SelectedTab -eq $ComputerTreeviewTab) { $InformationTabControl.SelectedTab = $Section3HostDataTab }
            elseif ($This.SelectedTab -eq $AccountsTreeviewTab) { $InformationTabControl.SelectedTab = $Section3AccountDataTab }
        }
        ImageList = $ComputerAndAccountTreeViewTabControlImageList
    }

    $ComputerAndAccountTreeNodeViewPanel.Controls.Add($ComputerAndAccountTreeViewTabControl)


    # Populate Auto Tag List used for Host Data tagging and Searching
    $TagListFileContents = Get-Content -Path $TagAutoListFile
        

    $ComputerTreeviewTab = New-Object System.Windows.Forms.TabPage -Property @{
        Text = "Endpoints  "
        Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        UseVisualStyleBackColor = $True
        ImageIndex = 0
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
                Add-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category $Computer.$($This.SelectedItem) -Entry $Computer.Name -ToolTip $Computer.IPv4Address -Metadata $Computer
            }
            Update-TreeViewState -Endpoint

            Update-TreeViewData -Endpoint -TreeView $script:ComputerTreeView.Nodes
        }


        $script:ComputerTreeNodeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
            Text    = 'CanonicalName'
            Left    = 0
            Top     = $FormScale * 5
            Width   = $FormScale * 135
            Height  = $FormScale * 25
            Font    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            AutoCompleteSource = "ListItems"
            AutoCompleteMode   = "SuggestAppend"
            add_SelectedIndexChanged = $script:UpdateComputerTreeViewScriptBlock
        }
        $ComputerTreeNodeComboBoxList = @('CanonicalName', 'OperatingSystem', 'OperatingSystemHotfix', 'OperatingSystemServicePack', 'Enabled', 'LockedOut', 'LogonCount', 'Created', 'Modified', 'LastLogonDate', 'MemberOf', 'isCriticalSystemObject', 'HomedirRequired', 'Location', 'ProtectedFromAccidentalDeletion', 'TrustedForDelegation')
        ForEach ($Item in $ComputerTreeNodeComboBoxList) { $script:ComputerTreeNodeComboBox.Items.Add($Item) }
        $ComputerTreeviewTab.Controls.Add($script:ComputerTreeNodeComboBox)


        $ComputerTreeNodeSearchGreedyCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
            Text    = "Greedy"
            Left    = $script:ComputerTreeNodeComboBox.Left + $script:ComputerTreeNodeComboBox.Width + $($FormScale * 5)
            Top     = $script:ComputerTreeNodeComboBox.Top - ($FormScale * 6)
            Height  = $FormScale * 25
            Width   = $FormScale * 65
            Checked = $true
            Font    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $ComputerTreeviewTab.Controls.Add($ComputerTreeNodeSearchGreedyCheckbox)


        # Initial load of CSV data
        $script:ComputerTreeViewData = $null
        if (Test-Path $EndpointTreeNodeFileSave) {
            $script:ComputerTreeViewData = Import-Csv $EndpointTreeNodeFileSave
        }
        else {
            $script:ComputerTreeViewData = Import-Csv $EndpointTreeNodeFileSaveDemo
        }

        $script:ComputerTreeViewSelected = ""


        $ComputerTreeNodeSearchComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
            Name   = "Search TextBox"
            Left   = $script:ComputerTreeNodeComboBox.Left
            Top    = $script:ComputerTreeNodeComboBox.Top + $script:ComputerTreeNodeComboBox.Height + ($FormScale * 5)
            Width  = $FormScale * 135
            Height = $FormScale * 25
            AutoCompleteSource = "ListItems"
            AutoCompleteMode   = "SuggestAppend"
            Font               = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            Add_KeyDown        = { if ($_.KeyCode -eq "Enter") { Search-TreeViewData -Endpoint } }
            Add_MouseHover     = {
                Show-ToolTip -Title "Search for Hosts" -Icon "Info" -Message @"
+  Searches through host data and returns results as nodes.
+  Search can include any character.
+  Tags are pre-built to assist with standarized notes.
+  Can search CSV Results, enable them in the Options Tab.
"@
            }

        }
        ForEach ($Tag in $TagListFileContents) { [void] $ComputerTreeNodeSearchComboBox.Items.Add($Tag) }
        $ComputerTreeviewTab.Controls.Add($ComputerTreeNodeSearchComboBox)


        $ComputerTreeNodeSearchButton = New-Object System.Windows.Forms.Button -Property @{
            Text   = "Search"
            Left   = $ComputerTreeNodeSearchComboBox.Left + $ComputerTreeNodeSearchComboBox.Width + ($FormScale * 5)
            Top    = $ComputerTreeNodeSearchComboBox.Top
            Width  = $FormScale * 55
            Height = $FormScale * 22
            Add_Click = {
                Search-TreeViewData -Endpoint
            }
            Add_MouseHover = {
    Show-ToolTip -Title "Search for Hosts" -Icon "Info" -Message @"
+  Searches through host data and returns results as nodes.
+  Search can include any character.
+  Tags are pre-built to assist with standarized notes.
+  Can search CSV Results, enable them in the Options Tab.
"@
}

        }
        $ComputerTreeviewTab.Controls.Add($ComputerTreeNodeSearchButton)
        Add-CommonButtonSettings -Button $ComputerTreeNodeSearchButton

        Remove-TreeViewEmptyCategory -Endpoint


        Update-FormProgress "$Dependencies\Code\Main\Context Menu Strip\Display-ContextMenuForComputerTreeNode.ps1"
        . "$Dependencies\Code\Main\Context Menu Strip\Display-ContextMenuForComputerTreeNode.ps1"
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

        # Position 2 = used as the default image for the computer/account/entry node. Normalize-TreeViewData.ps1 populates it by default if an imageindex number doesn't exist for it already
        $ComputerTreeviewImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Endpoint-Default.png"))
        $EndpointTreeviewImageHashTable['2'] = "$Dependencies\Images\Icons\Endpoint-Default.png"

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
        $ComputerTreeviewImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\OU-Default.png"))
        $EndpointTreeviewImageHashTable['1'] = "$Dependencies\Images\Icons\OU-Default.png"

        # Position 2 = PowerShell Icon, used to indicate an active powershell session
        $ComputerTreeviewImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\PowerShell.png"))
        $EndpointTreeviewImageHashTable['2'] = "$Dependencies\Images\Icons\PowerShell.png"

        # Position 3 = used as the default image for the computer/account/entry node. Normalize-TreeViewData.ps1 populates it by default if an imageindex number doesn't exist for it already
        $ComputerTreeviewImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Endpoint-Default.png"))
        $EndpointTreeviewImageHashTable['3'] = "$Dependencies\Images\Icons\Endpoint-Default.png"

        # Position 4 = Windows Server Default
        $ComputerTreeviewImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Windows-Server-Default.png"))
        $EndpointTreeviewImageHashTable['4'] = "$Dependencies\Images\Icons\Windows-Server-Default.png"

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

        # Position 13 = Linux Ubuntu
        $ComputerTreeviewImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Endpoint\Linux-OS-Ubuntu.png"))
        $EndpointTreeviewImageHashTable['13'] = "$Dependencies\Images\Icons\Endpoint\Linux-OS-Ubuntu.png"

        # Position 14 = Linux Debian
        $ComputerTreeviewImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Endpoint\Linux-OS-Debian.png"))
        $EndpointTreeviewImageHashTable['14'] = "$Dependencies\Images\Icons\Endpoint\Linux-OS-Debian.png"

        # Position 15 = Linux Red Hat
        $ComputerTreeviewImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Endpoint\Linux-OS-Red-Hat.png"))
        $EndpointTreeviewImageHashTable['15'] = "$Dependencies\Images\Icons\Endpoint\Linux-OS-Red-Hat.png"

        # Position 16 = Linux CentOS
        $ComputerTreeviewImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Endpoint\Linux-OS-CentOS.png"))
        $EndpointTreeviewImageHashTable['16'] = "$Dependencies\Images\Icons\Endpoint\Linux-OS-CentOS.png"


        # note, if you update this variable, update this one too... $ComputerTreeViewChangeIconRootTreeNodeCount
        $script:EndpointTreeviewImageHashTableCount = 16

        foreach ($Image in $script:ComputerTreeViewIconList.FullName) {
            $script:EndpointTreeviewImageHashTableCount++
            $ComputerTreeviewImageList.Images.Add([System.Drawing.Image]::FromFile("$Image"))
            $EndpointTreeviewImageHashTable["$script:EndpointTreeviewImageHashTableCount"] = "$Image"
        }

        # Position -1 = currently unused
        $ComputerTreeviewImageList.Images.Add([System.Drawing.Image]::FromFile("$high101bro_image"))
        $script:EndpointTreeviewImageHashTableCount++
        $EndpointTreeviewImageHashTable["$script:EndpointTreeviewImageHashTableCount"] = "$Dependencies\Images\high101bro Logo Color Transparent.png"


        $script:ComputerTreeView = New-Object System.Windows.Forms.TreeView -Property @{
            Left   = $ComputerTreeNodeSearchComboBox.Left
            Top    = $ComputerTreeNodeSearchButton.Top + $ComputerTreeNodeSearchButton.Height + ($FormScale * 5)
            Width  = $FormScale * 195
            Height = $FormScale * 555
            # Note: size and location properties are are managed by
            Font              = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            CheckBoxes        = $True
            #LabelEdit         = $True  #Not implementing yet...
            ShowLines         = $True
            ShowNodeToolTips  = $True
            Add_Click = {
                Update-TreeViewData -Endpoint -TreeView $this.Nodes

                # When the node is checked, it updates various items
                [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $this.Nodes
                foreach ($root in $AllTreeViewNodes) {
                    if ($root.checked) {
                        $root.Expand()
                        foreach ($Category in $root.Nodes) {
                            $Category.Expand()
                            foreach ($Entry in $Category.nodes) {
                                $Entry.Checked      = $True
                                $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                                $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,0,224)
                                $Category.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                                $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                                $Root.NodeFont      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                                $Root.ForeColor     = [System.Drawing.Color]::FromArgb(0,0,0,224)
                            }
                        }
                    }
                    foreach ($Category in $root.Nodes) {
                        $EntryNodeCheckedCount = 0
                        if ($Category.checked) {
                            $Category.Expand()
                            $Category.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                            $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                            $Root.NodeFont      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                            $Root.ForeColor     = [System.Drawing.Color]::FromArgb(0,0,0,224)
                            foreach ($Entry in $Category.nodes) {
                                $EntryNodeCheckedCount  += 1
                                $Entry.Checked      = $True
                                $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                                $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,0,224)
                            }
                        }
                        if (!($Category.checked)) {
                            foreach ($Entry in $Category.nodes) {
                                #if ($Entry.isselected) {
                                if ($Entry.checked) {
                                    $EntryNodeCheckedCount  += 1
                                    $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                                    $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,0,224)
                                    $Root.NodeFont      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                                    $Root.ForeColor     = [System.Drawing.Color]::FromArgb(0,0,0,224)
                                }
                                elseif (!($Entry.checked)) {
                                    if ($CategoryCheck -eq $False) {$Category.Checked = $False}
                                    $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                                    $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,0,0)
                                }
                            }
                        }
                        if ($EntryNodeCheckedCount -gt 0) {
                            $Category.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                            $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                            $Root.NodeFont      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                            $Root.ForeColor     = [System.Drawing.Color]::FromArgb(0,0,0,224)
                        }
                        else {
                            $Category.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                            $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
                            $Root.NodeFont      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                            $Root.ForeColor     = [System.Drawing.Color]::FromArgb(0,0,0,0)
                        }
                    }
                }
            }
            Add_AfterSelect = {
                Update-TreeViewData -Endpoint -TreeView $this.Nodes

                # This will return data on hosts selected/highlight, but not necessarily checked
                [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $this.Nodes
                foreach ($root in $AllTreeViewNodes) {
                    if ($root.isselected) {
                        $script:ComputerTreeViewSelected = ""
                        $StatusListBox.Items.clear()
                        $StatusListBox.Items.Add("Category:  $($root.Text)")
                        #Removed For Testing#$ResultsListBox.Items.Clear()
                        #$ResultsListBox.Items.Add("- Checkbox this Category to query all its hosts")

                        $script:Section3HostDataNameTextBox.Text                     = 'N/A'
                        $Section3HostDataOUTextBox.Text                              = 'N/A'
                        $Section3EndpointDataCreatedTextBox.Text                     = 'N/A'
                        $Section3EndpointDataModifiedTextBox.Text                    = 'N/A'
                        $Section3EndpointDataLastLogonDateTextBox.Text               = 'N/A'
                        $Section3HostDataIPTextBox.Text                              = 'N/A'
                        $Section3HostDataMACTextBox.Text                             = 'N/A'
                        $Section3EndpointDataEnabledTextBox.Text                     = 'N/A'
                        $Section3EndpointDataisCriticalSystemObjectTextBox.Text      = 'N/A'
                        $Section3EndpointDataSIDTextBox.Text                         = 'N/A'
                        $Section3EndpointDataOperatingSystemTextBox.Text             = 'N/A'
                        $Section3EndpointDataOperatingSystemHotfixComboBox.Text      = 'N/A'
                        $Section3EndpointDataOperatingSystemServicePackComboBox.Text = 'N/A'
                        $Section3EndpointDataMemberOfComboBox.Text                   = 'N/A'
                        $Section3EndpointDataLockedOutTextBox.Text                   = 'N/A'
                        $Section3EndpointDataLogonCountTextBox.Text                  = 'N/A'
                        $Section3EndpointDataPortScanComboBox.Text                   = 'N/A'
                        $Section3HostDataSelectionComboBox.Text                      = 'N/A'
                        $Section3HostDataSelectionDateTimeComboBox.Text              = 'N/A'
                        $Section3HostDataNotesRichTextBox.Text                       = 'N/A'

                        # Brings the Host Data Tab to the forefront/front view
                        $InformationTabControl.SelectedTab   = $Section3HostDataTab
                    }
                    foreach ($Category in $root.Nodes) {
                        if ($Category.isselected) {
                            $script:ComputerTreeViewSelected = ""
                            $StatusListBox.Items.clear()
                            $StatusListBox.Items.Add("Category:  $($Category.Text)")
                            #Removed For Testing#$ResultsListBox.Items.Clear()
                            #$ResultsListBox.Items.Add("- Checkbox this Category to query all its hosts")

                            # The follwing fields are filled out with N/A when host nodes are not selected
                            $script:Section3HostDataNameTextBox.Text                     = 'N/A'
                            $Section3HostDataOUTextBox.Text                              = 'N/A'
                            $Section3EndpointDataCreatedTextBox.Text                     = 'N/A'
                            $Section3EndpointDataModifiedTextBox.Text                    = 'N/A'
                            $Section3EndpointDataLastLogonDateTextBox.Text               = 'N/A'
                            $Section3HostDataIPTextBox.Text                              = 'N/A'
                            $Section3HostDataMACTextBox.Text                             = 'N/A'
                            $Section3EndpointDataEnabledTextBox.Text                     = 'N/A'
                            $Section3EndpointDataisCriticalSystemObjectTextBox.Text      = 'N/A'
                            $Section3EndpointDataSIDTextBox.Text                         = 'N/A'
                            $Section3EndpointDataOperatingSystemTextBox.Text             = 'N/A'
                            $Section3EndpointDataOperatingSystemHotfixComboBox.Text      = 'N/A'
                            $Section3EndpointDataOperatingSystemServicePackComboBox.Text = 'N/A'
                            $Section3EndpointDataMemberOfComboBox.Text                   = 'N/A'
                            $Section3EndpointDataLockedOutTextBox.Text                   = 'N/A'
                            $Section3EndpointDataLogonCountTextBox.Text                  = 'N/A'
                            $Section3EndpointDataPortScanComboBox.Text                   = 'N/A'
                            $Section3HostDataSelectionComboBox.Text                      = 'N/A'
                            $Section3HostDataSelectionDateTimeComboBox.Text              = 'N/A'
                            $Section3HostDataNotesRichTextBox.Text                       = 'N/A'

                            # Brings the Host Data Tab to the forefront/front view
                            $InformationTabControl.SelectedTab = $Section3HostDataTab
                        }
                        foreach ($Entry in $Category.nodes) {
                            if ($Entry.isselected) {
                                $InformationTabControl.SelectedTab = $Section3HostDataTab
                                $script:ComputerTreeViewSelected = $Entry.Text
                            }
                        }
                    }
                }
                $InformationTabControl.SelectedTab = $Section3HostDataTab
                Display-ContextMenuForComputerTreeNode -ClickedOnArea
            }
            Add_MouseHover = {
                $ComputerAndAccountTreeNodeViewPanel.Height = $FormScale * 635
                $ComputerAndAccountTreeViewTabControl.Height = $FormScale * 635
                $script:ComputerTreeView.Height = $FormScale * 558
            }
            Add_MouseLeave = {
                $ComputerAndAccountTreeNodeViewPanel.Height = $FormScale * 635
                $ComputerAndAccountTreeViewTabControl.Height = $FormScale * 635
                $script:ComputerTreeView.Height = $FormScale * 558
            }
            Add_MouseEnter    = {
                $ComputerAndAccountTreeNodeViewPanel.bringtofront()
                $ComputerAndAccountTreeViewTabControl.bringtofront()
                $script:ComputerTreeView.bringtofront()
            }
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
            Add-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category $Computer.CanonicalName -Entry $Computer.Name -ToolTip $Computer.IPv4Address -IPv4Address $Computer.IPv4Address -Metadata $Computer
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
        Text = "Accounts  "
        Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ImageIndex = 1
        UseVisualStyleBackColor = $True
    }
    $ComputerAndAccountTreeViewTabControl.Controls.Add($AccountsTreeviewTab)

        $script:AccountsTreeNodeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
            Text    = "CanonicalName"
            Left    = 0
            Top     = $FormScale * 5
            Width   = $FormScale * 135
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
                    Add-TreeViewData -Accounts -RootNode $script:TreeNodeAccountsList -Category $Account.$($This.SelectedItem) -Entry $Account.Name -ToolTip $Account.SID -Metadata $Account
                }
                $script:AccountsTreeView.Nodes.Add($script:TreeNodeAccountsList)
                Update-TreeViewState -Accounts
                Update-TreeViewData -Accounts -TreeView $script:AccountsTreeView.Nodes

            }
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
        }
        $AccountsTreeviewTab.Controls.Add($AccountsTreeNodeSearchGreedyCheckbox)

6
        # Initial load of CSV data
        $script:AccountsTreeViewData = $null
        if (Test-Path $AccountsTreeNodeFileSave) {
            $script:AccountsTreeViewData = Import-Csv $AccountsTreeNodeFileSave
        }
        else {
            $script:AccountsTreeViewData = Import-Csv $AccountsTreeNodeFileSaveDemo
        }
        $script:AccountsTreeViewSelected = ""


        $AccountsTreeNodeSearchComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
            Name   = "Search TextBox"
            Left   = $script:AccountsTreeNodeComboBox.Left
            Top    = $script:AccountsTreeNodeComboBox.Top + $script:AccountsTreeNodeComboBox.Height + ($FormScale * 5)
            Width  = $FormScale * 135
            Height = $FormScale * 25
            AutoCompleteSource = "ListItems"
            AutoCompleteMode   = "SuggestAppend"
            Font               = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            Add_KeyDown        = { if ($_.KeyCode -eq "Enter") { Search-TreeViewData -Accounts } }
            Add_MouseHover = {
                Show-ToolTip -Title "Search for Accounts" -Icon "Info" -Message @"
+  Searches through Account data and returns results as nodes.
+  Search can include any character.
+  Tags are pre-built to assist with standarized notes.
+  Can search CSV Results, enable them in the Options Tab.
"@
            }
        }
        ForEach ($Tag in $TagListFileContents) { [void] $AccountsTreeNodeSearchComboBox.Items.Add($Tag) }
        $AccountsTreeviewTab.Controls.Add($AccountsTreeNodeSearchComboBox)


        $AccountsTreeNodeSearchButton = New-Object System.Windows.Forms.Button -Property @{
            Text   = "Search"
            Left   = $AccountsTreeNodeSearchComboBox.Left + $AccountsTreeNodeSearchComboBox.Width + ($FormScale * 5)
            Top    = $AccountsTreeNodeSearchComboBox.Top
            Width  = $FormScale * 55
            Height = $FormScale * 22
            Add_Click = {
                Search-TreeViewData -Accounts
            }
            Add_MouseHover = {
                Show-ToolTip -Title "Search for Accounts" -Icon "Info" -Message @"
+  Searches through Account data and returns results as nodes.
+  Search can include any character.
+  Tags are pre-built to assist with standarized notes.
+  Can search CSV Results, enable them in the Options Tab.
"@
            }
        }
        $AccountsTreeviewTab.Controls.Add($AccountsTreeNodeSearchButton)
        Add-CommonButtonSettings -Button $AccountsTreeNodeSearchButton

        Remove-TreeViewEmptyCategory -Accounts

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
        $AccountsTreeviewImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Account-Default.png"))
        $AccountsTreeviewImageHashTable['2'] = "$Dependencies\Images\Icons\Account-Default.png"

        $AccountsTreeviewImageHashTableCount = 2
        foreach ($Image in $script:AccountsTreeViewIconList.FullName) {
            $AccountsTreeviewImageList.Images.Add([System.Drawing.Image]::FromFile("$Image"))
            $AccountsTreeviewImageHashTableCount++
            $AccountsTreeviewImageHashTable["$AccountsTreeviewImageHashTableCount"] = "$Image"
        }

        # Position -1 = currently unused
        $AccountsTreeviewImageList.Images.Add([System.Drawing.Image]::FromFile("$high101bro_image"))
        $AccountsTreeviewImageHashTableCount++
        $AccountsTreeviewImageHashTable["$AccountsTreeviewImageHashTableCount"] = "$Dependencies\Images\Icons\OU-Default.png"


        $script:AccountsTreeView = New-Object System.Windows.Forms.TreeView -Property @{
            Left   = $AccountsTreeNodeSearchComboBox.Left
            Top    = $AccountsTreeNodeSearchButton.Top + $AccountsTreeNodeSearchButton.Height + ($FormScale * 5)
            Width  = $FormScale * 195
            Height = $FormScale * 558
            Font              = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            CheckBoxes        = $True
            ShowLines         = $True
            ShowNodeToolTips  = $True
            Add_Click = {
                Update-TreeViewData -Accounts -TreeView $this.Nodes

                # When the node is checked, it updates various items
                [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $this.Nodes
                foreach ($root in $AllTreeViewNodes) {
                    if ($root.checked) {
                        $root.Expand()
                        foreach ($Category in $root.Nodes) {
                            $Category.Expand()
                            foreach ($Entry in $Category.nodes) {
                                $Entry.Checked      = $True
                                $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                                $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,0,224)
                                $Category.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                                $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                                $Root.NodeFont      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                                $Root.ForeColor     = [System.Drawing.Color]::FromArgb(0,0,0,224)
                            }
                        }
                    }
                    foreach ($Category in $root.Nodes) {
                        $EntryNodeCheckedCount = 0
                        if ($Category.checked) {
                            $Category.Expand()
                            $Category.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                            $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                            $Root.NodeFont      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                            $Root.ForeColor     = [System.Drawing.Color]::FromArgb(0,0,0,224)
                            foreach ($Entry in $Category.nodes) {
                                $EntryNodeCheckedCount  += 1
                                $Entry.Checked      = $True
                                $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                                $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,0,224)
                            }
                        }
                        if (!($Category.checked)) {
                            foreach ($Entry in $Category.nodes) {
                                #if ($Entry.isselected) {
                                if ($Entry.checked) {
                                    $EntryNodeCheckedCount  += 1
                                    $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                                    $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,0,224)
                                    $Root.NodeFont      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                                    $Root.ForeColor     = [System.Drawing.Color]::FromArgb(0,0,0,224)
                                }
                                elseif (!($Entry.checked)) {
                                    if ($CategoryCheck -eq $False) {$Category.Checked = $False}
                                    $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                                    $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,0,0)
                                }
                            }
                        }
                        if ($EntryNodeCheckedCount -gt 0) {
                            $Category.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                            $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                            $Root.NodeFont      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                            $Root.ForeColor     = [System.Drawing.Color]::FromArgb(0,0,0,224)
                        }
                        else {
                            $Category.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                            $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
                            $Root.NodeFont      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                            $Root.ForeColor     = [System.Drawing.Color]::FromArgb(0,0,0,0)
                        }
                    }
                }
            }
            Add_AfterSelect = {
                Update-TreeViewData -Accounts -TreeView $this.Nodes

                # This will return data on hosts selected/highlight, but not necessarily checked
                [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $this.Nodes
                foreach ($root in $AllTreeViewNodes) {
                    if ($root.isselected) {
                        $script:ComputerTreeViewSelected = ""
                        $StatusListBox.Items.clear()
                        $StatusListBox.Items.Add("Category:  $($root.Text)")
                        #Removed For Testing#$ResultsListBox.Items.Clear()
                        #$ResultsListBox.Items.Add("- Checkbox this Category to query all its hosts")

                        $script:Section3AccountDataNameTextBox.Text             = 'N/A'
                        $Section3AccountDataEnabledTextBox.Text                 = 'N/A'
                        $Section3AccountDataOUTextBox.Text                      = 'N/A'
                        $Section3AccountDataLockedOutTextBox.Text               = 'N/A'
                        $Section3AccountDataSmartCardLogonRequiredTextBox.Text  = 'N/A'
                        $Section3AccountDataCreatedTextBox.Text                 = 'N/A'
                        $Section3AccountDataModifiedTextBox.Text                = 'N/A'
                        $Section3AccountDataLastLogonDateTextBox.Text           = 'N/A'
                        $Section3AccountDataLastBadPasswordAttemptTextBox.Text  = 'N/A'
                        $Section3AccountDataBadLogonCountTextBox.Text           = 'N/A'
                        $Section3AccountDataPasswordExpiredTextBox.Text         = 'N/A'
                        $Section3AccountDataPasswordNeverExpiresTextBox.Text    = 'N/A'
                        $Section3AccountDataPasswordNotRequiredTextBox.Text     = 'N/A'
                        $Section3AccountDataMemberOfComboBox.Text               = 'N/A'
                        $Section3AccountDataSIDTextBox.Text                     = 'N/A'
                        $Section3AccountDataScriptPathTextBox.Text              = 'N/A'
                        $Section3AccountDataHomeDriveTextBox.Text               = 'N/A'
                        $script:Section3AccountDataNotesRichTextBox.Text        = 'N/A'

                        # Brings the Host Data Tab to the forefront/front view
                        $InformationTabControl.SelectedTab   = $Section3HostDataTab
                    }
                    foreach ($Category in $root.Nodes) {
                        if ($Category.isselected) {
                            $script:ComputerTreeViewSelected = ""
                            $StatusListBox.Items.clear()
                            $StatusListBox.Items.Add("Category:  $($Category.Text)")
                            #Removed For Testing#$ResultsListBox.Items.Clear()
                            #$ResultsListBox.Items.Add("- Checkbox this Category to query all its hosts")

                            # The follwing fields are filled out with N/A when host nodes are not selected
                            $script:Section3AccountDataNameTextBox.Text             = 'N/A'
                            $Section3AccountDataEnabledTextBox.Text                 = 'N/A'
                            $Section3AccountDataOUTextBox.Text                      = 'N/A'
                            $Section3AccountDataLockedOutTextBox.Text               = 'N/A'
                            $Section3AccountDataSmartCardLogonRequiredTextBox.Text  = 'N/A'
                            $Section3AccountDataCreatedTextBox.Text                 = 'N/A'
                            $Section3AccountDataModifiedTextBox.Text                = 'N/A'
                            $Section3AccountDataLastLogonDateTextBox.Text           = 'N/A'
                            $Section3AccountDataLastBadPasswordAttemptTextBox.Text  = 'N/A'
                            $Section3AccountDataBadLogonCountTextBox.Text           = 'N/A'
                            $Section3AccountDataPasswordExpiredTextBox.Text         = 'N/A'
                            $Section3AccountDataPasswordNeverExpiresTextBox.Text    = 'N/A'
                            $Section3AccountDataPasswordNotRequiredTextBox.Text     = 'N/A'
                            $Section3AccountDataMemberOfComboBox.Text               = 'N/A'
                            $Section3AccountDataSIDTextBox.Text                     = 'N/A'
                            $Section3AccountDataScriptPathTextBox.Text              = 'N/A'
                            $Section3AccountDataHomeDriveTextBox.Text               = 'N/A'
                            $script:Section3AccountDataNotesRichTextBox.Text        = 'N/A'
                        }
                        foreach ($Entry in $Category.nodes) {
                            if ($Entry.isselected) {
                                $script:ComputerTreeViewSelected = $Entry.Text
                            }
                        }
                    }
                }
                $InformationTabControl.SelectedTab = $Section3AccountDataTab
                Display-ContextMenuForAccountsTreeNode -ClickedOnArea
            }
            Add_MouseEnter    = {
                $ComputerAndAccountTreeNodeViewPanel.bringtofront()
                $ComputerAndAccountTreeViewTabControl.bringtofront()
                $script:AccountsTreeView.bringtofront()
            }
            Add_MouseLeave    = $AccountsTreeViewAdd_MouseLeave
            ContextMenuStrip  = $AccountsListContextMenuStrip
            ShowPlusMinus     = $true
            HideSelection     = $false
            ImageList         = $AccountsTreeviewImageList
            ImageIndex        = 1
        }
        $script:AccountsTreeView.Sort()
        $AccountsTreeviewTab.Controls.Add($script:AccountsTreeView)

        Initialize-TreeViewData -Accounts
        Normalize-TreeViewData -Accounts

        # This will load data that is located in the saved file
        Foreach($Account in $script:AccountsTreeViewData) {
            Add-TreeViewData -Accounts -RootNode $script:TreeNodeAccountsList -Category $Account.CanonicalName -Entry $Account.Name -ToolTip $Account.SID -Metadata $Account
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



$MainCenterPanel = New-Object System.Windows.Forms.Panel -Property @{
    Left   = $ComputerAndAccountTreeNodeViewPanel.Left + $ComputerAndAccountTreeNodeViewPanel.Width
    Top    = $FormScale * 5
    Width  = $FormScale * 607
    Height = $FormScale * 278
    BorderStyle = 'FixedSingle'
}

    $MainCenterTabControlImageList = New-Object System.Windows.Forms.ImageList -Property @{
        ImageSize = @{
            Width  = $FormScale * 16
            Height = $FormScale * 16
        }
    }
    # Index 0 = Main
    $MainCenterTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Home-Main.png"))
    # Index 1 = Options
    $MainCenterTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Options.png"))
    # Index 2 = Statistics
    $MainCenterTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Statistics.png"))


    $MainCenterTabControl = New-Object System.Windows.Forms.TabControl -Property @{
        Left   = 0
        Top    = 0
        Width  = $FormScale * 607
        Height = $FormScale * 278
        SelectedIndex  = 0
        ShowToolTips   = $True
        Appearance     = [System.Windows.Forms.TabAppearance]::Buttons
        Hottrack       = $true
        Dock           = 'Fill'
        Font           = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,2,1)
        Add_MouseHover = $MainCenterTabControlAdd_MouseHover
        ImageList = $MainCenterTabControlImageList
    }
    $MainCenterPanel.Controls.Add($MainCenterTabControl)

    Update-FormProgress "$Dependencies\Code\Main\Tabs\Main Tab.ps1"
    . "$Dependencies\Code\Main\Tabs\Main Tab.ps1"

    Update-FormProgress "$Dependencies\Code\Main\Tabs\Options.ps1"
    . "$Dependencies\Code\Main\Tabs\Options.ps1"

    Update-FormProgress "$Dependencies\Code\Main\Tabs\Statistics.ps1"
    . "$Dependencies\Code\Main\Tabs\Statistics.ps1"

$PoShEasyWin.Controls.Add($MainCenterPanel)


$ExecutionButtonPanel = New-Object System.Windows.Forms.Panel -Property @{
    Left   = $MainCenterPanel.Left + $MainCenterPanel.Width
    Top    = $MainCenterPanel.Top
    Height = $MainCenterPanel.Height
    Width  = $FormScale * 140
    BorderStyle = 'FixedSingle'
}
    $MainRightTabControlImageList = New-Object System.Windows.Forms.ImageList -Property @{
        ImageSize = @{
            Width  = $FormScale * 16
            Height = $FormScale * 16
        }
    }
    $MainRightTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Action.png"))


    $MainRightTabControl = New-Object System.Windows.Forms.TabControl -Property @{
        Name   = "Main Tab Window for Computer List"
        Left   = 0
        Top    = 0
        Height = $FormScale * 273
        Width  = $FormScale * 140
        ShowToolTips = $True
        Appearance   = [System.Windows.Forms.TabAppearance]::Buttons
        Hottrack     = $true
        Dock         = 'Fill'
        Font         = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,2,1)
        ImageList    = $MainRightTabControlImageList
        SelectedIndex = 0
    }
    $ExecutionButtonPanel.Controls.Add($MainRightTabControl)

    Update-FormProgress "$Dependencies\Code\Main\Tabs\Action.ps1"
    . "$Dependencies\Code\Main\Tabs\Action.ps1"

$PoShEasyWin.Controls.Add($ExecutionButtonPanel)


$InformationPanel = New-Object System.Windows.Forms.Panel -Property @{
    Left   = $MainCenterPanel.Left
    Top    = $MainCenterPanel.Top + $MainCenterPanel.Height
    Width  = $FormScale * 747
    Height = $FormScale * 357
    BorderStyle = 'FixedSingle'
}

    $InformationPanelImageList = New-Object System.Windows.Forms.ImageList -Property @{
        ImageSize = @{
            Width  = $FormScale * 16
            Height = $FormScale * 16
        }
    }
    # Index 0 = About
    $InformationPanelImageList.Images.Add([System.Drawing.Image]::FromFile("$high101bro_image"))
    # Index 1 = Results / Information
    $InformationPanelImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Information.png"))
    # Index 2 = Monitor Jobs
    $InformationPanelImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Monitor-Jobs.png"))
    # Index 3 = Endpoint Data
    $InformationPanelImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Endpoint-Default.png"))
    # Index 4 = Account Data
    $InformationPanelImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Accounts.png"))
    # Index 5 = Command Exploration
    $InformationPanelImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\PowerShell.png"))


    $InformationTabControl = New-Object System.Windows.Forms.TabControl -Property @{
        Left   = 0
        Top    = 0
        Height = $FormScale * 357
        Width  = $FormScale * 752
        Appearance   = [System.Windows.Forms.TabAppearance]::Buttons
        Hottrack     = $true
        Dock         = 'Fill'
        Font         = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,2,1)
        ShowToolTips = $True
        Add_Click = { Resize-MonitorJobsTab -Minimize }
        Add_MouseHover = { $this.bringtofront() }
        ImageList = $InformationPanelImageList
    }
    $InformationPanel.Controls.Add($InformationTabControl)

    Update-FormProgress "$Dependencies\Code\Main\Tabs\About.ps1"
    . "$Dependencies\Code\Main\Tabs\About.ps1"

    Update-FormProgress "$Dependencies\Code\Main\Tabs\Results.ps1"
    . "$Dependencies\Code\Main\Tabs\Results.ps1"

    Update-FormProgress "$Dependencies\Code\Main\Tabs\Monitor Jobs.ps1"
    . "$Dependencies\Code\Main\Tabs\Monitor Jobs.ps1"

    Update-FormProgress "$Dependencies\Code\Main\Tabs\Endpoint Data.ps1"
    . "$Dependencies\Code\Main\Tabs\Endpoint Data.ps1"

    Update-FormProgress "$Dependencies\Code\Main\Tabs\Account Data.ps1"
    . "$Dependencies\Code\Main\Tabs\Account Data.ps1"

    Update-FormProgress "$Dependencies\Code\Main\Tabs\Query Exploration.ps1"
    . "$Dependencies\Code\Main\Tabs\Query Exploration.ps1"

$PoShEasyWin.Controls.Add($InformationPanel)

Update-FormProgress "$Dependencies\Code\Execution\Monitor-Jobs.ps1"
. "$Dependencies\Code\Execution\Monitor-Jobs.ps1"

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

    $GetDate = (Get-Date).ToString('yyyy-MM-dd HH.mm.ss')
    if ($ResultsFolderAutoTimestampCheckbox.Checked -eq $true -and $SaveResultsToFileShareCheckbox.Checked -eq $false) {
        $CollectedDataTimeStamp = "$PewCollectedData\$GetDate"
        $script:CollectionSavedDirectoryTextBox.Text = $CollectedDataTimeStamp
    }
    elseif ($ResultsFolderAutoTimestampCheckbox.Checked -eq $true -and $SaveResultsToFileShareCheckbox.Checked -eq $true) {
        $script:CollectionSavedDirectoryTextBox.Text = "$($script:SmbShareDriveLetter):\$GetDate"
    }

    # Clears the Progress bars
    $script:ProgressBarEndpointsProgressBar.Value     = 0
    $script:ProgressBarQueriesProgressBar.Value       = 0
    $script:ProgressBarEndpointsProgressBar.BackColor = 'White'
    $script:ProgressBarQueriesProgressBar.BackColor   = 'White'

    if ($script:ComputerListProvideCredentialsCheckBox.Checked) { $Username = $script:Credential.UserName}
    else {$Username = $PoShEasyWinAccountLaunch }

    Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes

    # Clears previous and generates new computerlist
    $script:ComputerList = @()
    Generate-ComputerList
    
    # This function compiles the selected treeview comamnds, placing the proper command type and protocol into a variable list to be executed.
    Compile-TreeViewCommand

    # Assigns the path to save the Collections to
    $CollectedDataTimeStamp = $script:CollectionSavedDirectoryTextBox.Text

    # Location of Uncompiled Results
    $script:IndividualHostResults = "$CollectedDataTimeStamp"

    if ($script:EventLogsStartTimePicker.Checked -xor $script:EventLogsStopTimePicker.Checked) {
        # This brings specific tabs to the forefront/front view
        $MainLeftTabControl.SelectedTab = $Section1SearchTab
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

        # Checks if the query/command was validated, if it was modified it will uncheck it
        if ($script:CustomQueryScriptBlockTextbox.text -ne $script:CustomQueryScriptBlockSaved) {
            $CustomQueryScriptBlockCheckBox.checked = $false
            $CustomQueryScriptBlockCheckBox.enabled = $false
        }

        # Adds section checkboxes to the command count
        foreach ($Checkbbox in $script:AllCheckBoxesList) {
            if     ($AccountsWinRMRadioButton.Checked -and $Checkbbox.Checked) { $script:WinRMCommandCount++ }
            elseif ($AccountsRpcRadioButton.Checked   -and $Checkbbox.Checked) { $script:RpcCommandCount++ }
            elseif ($EventLogWinRMRadioButton.Checked -and $Checkbbox.Checked) { $script:WinRMCommandCount++ }
            elseif ($EventLogRpcRadioButton.Checked   -and $Checkbbox.Checked) { $script:RpcCommandCount++ }
            elseif ($ExternalProgramsWinRMRadioButton.checked -and $Checkbbox.checked) { $script:WinRMCommandCount++ }
            elseif ($ExternalProgramsRpcRadioButton.checked   -and $Checkbbox.checked) { $script:RpcCommandCount++ }
            elseif ($Checkbbox.checked) { $script:WinRMCommandCount++ }
        }


        if ($EventLogsQuickPickSelectionCheckbox.Checked) {
            # This is subtracted one because it get's added to the count because it's in the $script:AllCheckBoxesList list
            $CountCommandQueries--

            foreach ($Query in $script:EventLogQueries) {
                if ($EventLogWinRMRadioButton.Checked -and $EventLogsQuickPickSelectionCheckedlistbox.CheckedItems -match $Query.Name) { $CountCommandQueries++ ; $script:WinRMCommandCount++ }
                if ($EventLogRpcRadioButton.Checked   -and $EventLogsQuickPickSelectionCheckedlistbox.CheckedItems -match $Query.Name) { $CountCommandQueries++ ; $script:RpcCommandCount++ }
            }
        }

        $QueryCount = $CountCommandQueries + $script:TreeeViewCommandsCount

        $script:ProgressBarQueriesProgressBar.Maximum = $QueryCount

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


        if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs' -or $script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Individual Execution') {
            Create-TreeViewCheckBoxArray -Endpoint

            # Compares the computerlist against the previous computerlist queried (generated when previous query is completed )
            # If the computerlists changed, it will prompt you to do connections tests and generate a new computerlist if endpoints fail
            if ((Compare-Object -ReferenceObject $script:ComputerList -DifferenceObject $script:ComputerListHistory) -or `
                !(([bool]($script:RpcCommandCount     -gt 0) -eq [bool]$script:RpcCommandCountHistory) -and `
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

                $CollectedDataTimeStamp = $script:CollectionSavedDirectoryTextBox.Text
                New-Item -Type Directory -Path $CollectedDataTimeStamp -ErrorAction SilentlyContinue

                if ($script:CommandsCheckedBoxesSelected.count -gt 0)    { . "$Dependencies\Code\Execution\Individual Execution\Execute-IndividualCommands.ps1" }
                if ($CustomQueryScriptBlockCheckBox.Checked)             { . "$Dependencies\Code\Execution\Individual Execution\IndividualQuery-QueryBuild.ps1" }
                if ($AccountsCurrentlyLoggedInConsoleCheckbox.Checked)   { . "$Dependencies\Code\Execution\Individual Execution\IndividualQuery-AccountsCurrentlyLoggedInConsole.ps1" }
                if ($AccountsCurrentlyLoggedInPSSessionCheckbox.Checked) { . "$Dependencies\Code\Execution\Individual Execution\IndividualQuery-AccountsCurrentlyLoggedInPSSession.ps1" }
                if ($AccountActivityCheckbox.Checked)                    { . "$Dependencies\Code\Execution\Individual Execution\IndividualQuery-AccountLogonActivity.ps1" }
                if ($EventLogsEventIDsManualEntryCheckbox.Checked)       { . "$Dependencies\Code\Execution\Individual Execution\IndividualQuery-EventLogsEventCodeManualEntryCommand.ps1" }
                if ($EventLogsQuickPickSelectionCheckbox.Checked)        { . "$Dependencies\Code\Execution\Individual Execution\IndividualQuery-EventLogsQuickPick.ps1" }
                if ($EventLogNameEVTXLogNameSelectionCheckbox.Checked)   { . "$Dependencies\Code\Execution\Individual Execution\IndividualQuery-EventLogNameRetrieveEVTX.ps1" }
                if ($RegistrySearchCheckbox.checked)                     { . "$Dependencies\Code\Execution\Individual Execution\IndividualQuery-RegistrySearch.ps1" }
                if ($FileSearchDirectoryListingCheckbox.Checked)         { . "$Dependencies\Code\Execution\Individual Execution\IndividualQuery-FileSearchDirectoryListing.ps1" }
                if ($FileSearchFileSearchCheckbox.Checked)               { . "$Dependencies\Code\Execution\Individual Execution\IndividualQuery-FileSearchFileSearch.ps1" }
                if ($FileSearchAlternateDataStreamCheckbox.Checked)      { . "$Dependencies\Code\Execution\Individual Execution\IndividualQuery-FileSearchAlternateDataStream.ps1" }
                if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Individual Execution' -and $NetworkEndpointPacketCaptureCheckBox.Checked) {
                    [System.Windows.Forms.MessageBox]::Show("The Individual Execution mode does not support Packet Capture, use the Monitor Jobs mode.","Incompatible Mode",'Ok',"Info")
                }
                else {
                    if ($NetworkEndpointPacketCaptureCheckBox.Checked) { . "$Dependencies\Code\Execution\Individual Execution\IndividualCapture-EndpointPacketCaptureNetSh.ps1" }
                }

                # Live Process Search for various data
                if ($ProcessLiveSearchNameCheckbox.checked)               { IndividualQuery-ProcessLive -ProcessLiveSearchNameCheckbox }
                if ($ProcessLiveSearchCommandlineCheckbox.checked)        { IndividualQuery-ProcessLive -ProcessLiveSearchCommandlineCheckbox }
                if ($ProcessLiveSearchParentNameCheckbox.checked)         { IndividualQuery-ProcessLive -ProcessLiveSearchParentNameCheckbox }
                if ($ProcessLiveSearchOwnerSIDCheckbox.checked)           { IndividualQuery-ProcessLive -ProcessLiveSearchOwnerSIDCheckbox }
                if ($ProcessLiveSearchServiceInfoCheckbox.checked)        { IndividualQuery-ProcessLive -ProcessLiveSearchServiceInfoCheckbox }
                if ($ProcessLiveSearchNetworkConnectionsCheckbox.checked) { IndividualQuery-ProcessLive -ProcessLiveSearchNetworkConnectionsCheckbox }
                if ($ProcessLiveSearchHashesSignerCertsCheckbox.checked)  { IndividualQuery-ProcessLive -ProcessLiveSearchHashesSignerCertsCheckbox }
                if ($ProcessLiveSearchCompanyProductCheckbox.checked)     { IndividualQuery-ProcessLive -ProcessLiveSearchCompanyProductCheckbox }

                # Searches for Sysmon Event ID 1 for various Process Creation data
                if ($ProcessSysmonSearchFilePathCheckbox.checked)          { IndividualQuery-ProcessSysmon -ProcessSysmonSearchFilePathCheckbox }
                if ($ProcessSysmonSearchCommandlineCheckbox.checked)       { IndividualQuery-ProcessSysmon -ProcessSysmonSearchCommandlineCheckbox }
                if ($ProcessSysmonSearchParentFilePathCheckbox.checked)    { IndividualQuery-ProcessSysmon -ProcessSysmonSearchParentFilePathCheckbox }
                if ($ProcessSysmonSearchParentCommandlineCheckbox.checked) { IndividualQuery-ProcessSysmon -ProcessSysmonSearchParentCommandlineCheckbox }
                if ($ProcessSysmonSearchRuleNameCheckbox.checked)          { IndividualQuery-ProcessSysmon -ProcessSysmonSearchRuleNameCheckbox }
                if ($ProcessSysmonSearchUserAccountIdCheckbox.checked)     { IndividualQuery-ProcessSysmon -ProcessSysmonSearchUserAccountIdCheckbox }
                if ($ProcessSysmonSearchHashesCheckbox.checked)            { IndividualQuery-ProcessSysmon -ProcessSysmonSearchHashesCheckbox }
                if ($ProcessSysmonSearchCompanyProductCheckbox.checked)    { IndividualQuery-ProcessSysmon -ProcessSysmonSearchCompanyProductCheckbox }

                # Live Network Connection Search for various data
                if ($NetworkLiveSearchRemoteIPAddressCheckbox.checked) { . "$Dependencies\Code\Execution\Individual Execution\IndividualQuery-NetworkLiveRemoteIPAddress.ps1" }
                if ($NetworkLiveSearchRemotePortCheckbox.checked)      { . "$Dependencies\Code\Execution\Individual Execution\IndividualQuery-NetworkLiveRemotePort.ps1" }
                if ($NetworkLiveSearchLocalPortCheckbox.checked)       { . "$Dependencies\Code\Execution\Individual Execution\IndividualQuery-NetworkLiveLocalPort.ps1" }
                if ($NetworkLiveSearchCommandLineCheckbox.checked)     { . "$Dependencies\Code\Execution\Individual Execution\IndividualQuery-NetworkLiveSearchCommandLine.ps1" }
                if ($NetworkLiveSearchExecutablePathCheckbox.checked)  { . "$Dependencies\Code\Execution\Individual Execution\IndividualQuery-NetworkLiveSearchExecutablePath.ps1" }
                if ($NetworkLiveSearchProcessCheckbox.checked)         { . "$Dependencies\Code\Execution\Individual Execution\IndividualQuery-NetworkLiveProcess.ps1" }
                if ($NetworkLiveSearchDNSCacheCheckbox.checked)        { . "$Dependencies\Code\Execution\Individual Execution\IndividualQuery-NetworkLiveSearchDNSCache.ps1" }

                # Searches for Sysmon Event ID 3 for various Network Connections data
                if ($NetworkSysmonSearchSourceIPAddressCheckbox.checked)      { IndividualQuery-NetworkSysmon -NetworkSysmonSearchSourceIPAddressCheckbox }
                if ($NetworkSysmonSearchSourcePortCheckbox.checked)           { IndividualQuery-NetworkSysmon -NetworkSysmonSearchSourcePortCheckbox }
                if ($NetworkSysmonSearchDestinationIPAddressCheckbox.checked) { IndividualQuery-NetworkSysmon -NetworkSysmonSearchDestinationIPAddressCheckbox }
                if ($NetworkSysmonSearchDestinationPortCheckbox.checked)      { IndividualQuery-NetworkSysmon -NetworkSysmonSearchDestinationPortCheckbox }
                if ($NetworkSysmonSearchAccountCheckbox.checked)              { IndividualQuery-NetworkSysmon -NetworkSysmonSearchAccountCheckbox }
                if ($NetworkSysmonSearchExecutablePathCheckbox.checked)       { IndividualQuery-NetworkSysmon -NetworkSysmonSearchExecutablePathCheckbox }

                if ($SysinternalsSysmonCheckbox.Checked)         { . "$Dependencies\Code\Execution\Individual Execution\IndividualPush-Sysmon.ps1" }
                if ($SysinternalsProcessMonitorCheckbox.Checked) { . "$Dependencies\Code\Execution\Individual Execution\IndividualPush-Procmon.ps1" }

                # User Specified Files and Custom Script
                # Pushes user Specified Files and Custom Script to the endpoints
                # The script has to manage all the particulars with the executable; execution, results retrieval, cleanup, etc.
                if ($ExeScriptUserSpecifiedExecutableAndScriptCheckbox.checked) { . "$Dependencies\Code\Execution\Individual Execution\IndividualPush-ExecutableAndScript.ps1" }

                Start-Sleep -Seconds 1
                if ($script:Section3MonitorJobsResizeCheckbox.checked) { Resize-MonitorJobsTab -Maximize }
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


# This needs to be here to execute the script
# Note the Execution button itself is located in the Select Computer section
$script:ComputerListExecuteButton.Add_Click($ExecuteScriptHandler)


$script:PoShEasyWinStatusBar = New-Object System.Windows.Forms.StatusBar
$PoShEasyWin.Controls.Add($script:PoShEasyWinStatusBar)


# Starts the ticker for the GUI and adds the status bar
$script:PoShEasyWinFormTicker = New-Object System.Windows.Forms.Timer -Property @{
    Enabled  = $true
    Interval = 1000
    Add_Tick = { $script:PoShEasyWinStatusBar.Text = "$(Get-Date) - Computers Selected [$($script:ComputerList.Count)], Queries Selected [$($script:SectionQueryCount)]" }
    }
$script:PoShEasyWinFormTicker.Start()


#Show the Form
$script:ProgressBarFormProgressBar.Value = $script:ProgressBarFormProgressBar.Maximum
$script:ProgressBarSelectionForm.Hide()


Update-FormProgress "Finished Loading!"
Start-Sleep -Milliseconds 500

# Shows the GUI
$PoShEasyWin.ShowDialog() | Out-Null

} # END for $ScriptBlockForGuiLoadAndProgressBar


$ScriptBlockProgressBarInput = {
    $script:ProgressBarMessageLabel.text = "PowerShell - Endpoint Analysis Solution Your Windows Intranet Needs!`n`n© 2018 Daniel S. Komnick"
    $script:ProgressBarSelectionForm.Refresh()

    $script:ProgressBarFormProgressBar.Value = 0
    $ManualEntryOfUpdateFormProgress = 190
    $CommandScriptCount = 0
    $CommandScriptCount += Get-ChildItem "$CommandsAndScripts\Scripts-Host\" | Measure-Object | Select-Object -ExpandProperty Count
    $CommandScriptCount += Get-ChildItem "$CommandsAndScripts\Scripts-AD\"   | Measure-Object | Select-Object -ExpandProperty Count
    $script:ProgressBarFormProgressBar.Maximum = $ManualEntryOfUpdateFormProgress + $CommandScriptCount

    Invoke-command $global:ScriptBlockForGuiLoadAndProgressBar
}

if ((Test-Path "$PewSettings\User Notice And Acknowledgement.txt")) {
    Show-ProgressBar -FormTitle "PoSh-EasyWin  [$InitialScriptLoadTime]" -ShowImage -ScriptBlockProgressBarInput $ScriptBlockProgressBarInput
    $script:ProgressBarSelectionForm.Topmost = $false
}







# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU2mKhBeS2GvHMfeYBwjzJ/4l+
# nqOgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUoyK1K0gmrr7yqVfV/Ee7wUjG6bwwDQYJKoZI
# hvcNAQEBBQAEggEAU4WRgnRywSP/tl9Ee1QVec+cygXXvINkMS4olMJW54TLgLoq
# pIGNF/x876i0dfyQw6JdUNiuEFYhDba3fnWdHMK7TxbM154FVz3/Wyq7+En4J8t6
# gWy0OtRLEs89WQCdpQ5QUY6YiU933v6DmuInKmkNt44PVMf6Voz53fA6lnNahy/o
# dm2jtolViGkU67fEq9n5IRVHsOWQ7QuAOcRWI8MJmPPL/Xpqg4rpm/I6r4g9lz45
# PFrtQDpeCE60hvG84gOu/ORgIvSIt8qlqGGIoFxAeFxHl0ra2/DPU3w35GJ7+T6s
# OiDFmbYM2dt+zU3VyUQUAh6tksGf3Gdt14ckOg==
# SIG # End signature block
