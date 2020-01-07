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
     Version        : v.3.2.1

     Author         : high101bro
     Email          : high101bro@gmail.com
     Website        : https://github.com/high101bro/PoSh-ACME

     Requirements   : PowerShell v3+ for PowerShell Charts
                    : WinRM   HTTP  - TCP/5985
                              HTTPS - TCP/5986
                    : DCOM    RPC   - TCP/135 and dynamic ports, typically:
                                      TCP 49152-65535 (Windows Vista, Server 2008 and above)
                                      TCP 1024 -65535 (Windows NT4, Windows 2000, Windows 2003)
     Optional       : Can run standalone, but works best with the Resources folder!
                    : PsExec.exe, Procmon.exe, Autoruns.exe, Sysmon.exe, WinPmem.exe
     Updated        :  7 Jan 20
     Created        : 21 Aug 18
                        
    .EXAMPLE
        This will run PoSh-ACME.ps1 and provide prompts that will tailor your collection.

             PowerShell.exe -ExecutionPolicy ByPass -NoProfile -File .\PoSh-ACME.ps1

    .Link
        https://github.com/high101bro/PoSh-ACME

    .NOTES  
        Though this may look like a program, it is still a script that has a GUI interface built
        using the .Net Framework and WinForms. So when it's conducting queries, the GUI will be 
        unresponsive to user interaction even though you are able to view status and timer updates.

        In order to run the script:
        - Downloaded from the internet
            You may have to use the Unblock-File cmdlet to be able to run the script.
              - For addtional info on: Get-Help Unblock-File
            How to Unblock the file:
              - Unblock-File -Path .\PoSh-ACME.ps1

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
# Not Using the following commandline, but rather the script below
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
    $LogFile                              = "$PoShHome\Log File.txt"
    $IPListFile                           = "$PoShHome\iplist.txt"
    $CustomPortsToScan                    = "$PoShHome\Custom Ports To Scan.txt"
                                                    
    $ComputerListTreeViewFileAutoSave     = "$PoShHome\Computer List TreeView (Auto-Save).csv"
    $ComputerListTreeViewFileSave         = "$PoShHome\Computer List TreeView (Saved).csv"

    $OpNotesFile                          = "$PoShHome\OpNotes.txt"
    $OpNotesWriteOnlyFile                 = "$PoShHome\OpNotes (Write Only).txt"
  
    # Dependencies
    $ChartsUserCreated                    = "$PoShHome\Dependencies\Charts - User Created.ps1"
    $ImportHostsFromDomain                = "$PoShHome\Dependencies\Import Hosts From Domain.ps1"

    # Location of Active Directory & Endpoint Commands
    $CommandsEndpoint                     = "$PoShHome\Dependencies\Commands - Endpoint.csv"
    $CommandsActiveDirectory              = "$PoShHome\Dependencies\Commands - Active Directory.csv"

    # Location of Host Commands Scripts
    $CommandsHostDirectoryScripts         = "$PoShHome\Dependencies\Scripts"

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

        # Location of Event Logs Commands
        $CommandsEventLogsDirectory           = "$ResourcesDirectory\Commands - Event Logs"
            # CSV list of Event IDs numbers, names, and description
            $EventIDsFile                     = "$CommandsEventLogsDirectory\Event IDs.csv"
            # CSV file from Microsoft detailing Event IDs to Monitor
            $EventLogsWindowITProCenter       = "$CommandsEventLogsDirectory\Individual Selection\Event Logs to Monitor - Window IT Pro Center.csv"

        # Location of External Programs directory
        $ExternalPrograms                     = "$ResourcesDirectory\External Programs"
        $PsExecPath                           = "$ExternalPrograms\PsExec.exe"

        # CSV list of Event IDs numbers, names, and description
        $TagAutoListFile                      = "$ResourcesDirectory\Tags - Auto Populate.txt"

# Logs what account ran the script and when
$LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - PoSh-ACME executed by: $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"
$LogMessage | Add-Content -Path $LogFile

# The Font Used throughout PoSh-ACME GUI
$Font = "Courier"

# Clears out Computer List variable
$ComputerList      = ""

# Credentials will be stored in this variable
$script:Credential = ""

# Import hosts from domain
. $ImportHostsFromDomain

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

# Correct the initial state of the form to prevent the .Net maximized form issue
$InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState
$OnLoadForm_StateCorrection = { $PoShACME.WindowState = $InitialFormWindowState }

#============================================================================================================================================================
# This is the overall window for PoSh-ACME
#============================================================================================================================================================
$PoShACMERightPosition = 10
$PoShACMEDownPosition  = 10
$PoShACMEBoxWidth      = 1241
$PoShACMEBoxHeight     = 638

$PoShACME = New-Object System.Windows.Forms.Form -Property @{
    Text          = "PoSh-ACME   [$([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)]"
    Name          = "PoSh-ACME"
    #Location      = New-Object System.Drawing.Size($PoShACMERightPosition,$PoShACMEDownPosition) 
    StartPosition = "CenterScreen"
    Size          = @{ Width  = 1241
                       Height = 638 }
    Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$ResourcesDirectory\favicon.ico")
    AutoScroll    = $True
    #FormBorderStyle =  "fixed3d"
}
# ToolTip Function That provides messages when hovering over various areas in the GUI
function ToolTipFunction {
    param (
        $Title   = 'No Title Specified',
        $Message = 'No Message Specified',
        $Icon    = 'Warning'
    )
    $ToolTip = New-Object System.Windows.Forms.ToolTip    
    if ($OptionShowToolTipCheckBox.Checked){
        #$ToolTipMessage0   = "• This information is searchable when looking for computers.`n"
        $ToolTipMessage1   = "• ToolTips can be disabled in the Options Tab."
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage1))
        $ToolTip.Active         = $false # This is counter intuitive, but is the only way I can get it to disable tooltips when unchecked in options
        $ToolTip.UseAnimation   = $true
        $ToolTip.UseFading      = $true
        $ToolTip.IsBalloon      = $true
        $ToolTip.ToolTipIcon    = $Icon  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle   = $Title
    }    
}

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
                  Y = $Section1TabControlDownPosition }
    Size     = @{ Width  = $Section1TabControlBoxWidth
                  Height = $Section1TabControlBoxHeight }
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
$Section1CollectionsTabControl = New-Object System.Windows.Forms.TabControl -Property @{
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

#=========================================
#    ____                  _          
#   / __ \__  _____  _____(_)__  _____
#  / / / / / / / _ \/ ___/ / _ \/ ___/
# / /_/ / /_/ /  __/ /  / /  __(__  ) 
# \___\_\__,_/\___/_/  /_/\___/____/  
#
#=========================================
# Varables for positioning checkboxes
$QueriesRightPosition     = 5
$QueriesDownPositionStart = 10
$QueriesDownPosition      = 10
$QueriesDownPositionShift = 25
$QueriesBoxWidth          = 410
$QueriesBoxHeight         = 25

$Section1CommandsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text     = "Queries"
    Name     = "Queries"
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

#===================
# Endpoint Commands
#===================
# Imports all the Endpoint Commands fromthe csv file
$script:AllEndpointCommands = Import-Csv $CommandsEndpoint

# Imports scripts from the Endpoint script folder and loads them into the treeview
Function Import-EndpointScripts {
    Foreach ($script in (Get-ChildItem -Path "$CommandsHostDirectoryScripts\Endpoint")) {
        if ($script -match 'processes' -or $script -match 'services') {
            #UPDATE ME# This method of tagging scripts that produce charts is a temporary fix and needs a better solution
            $CollectionName = $script.basename
            $script:AllEndpointCommands += [PSCustomObject]@{ 
                Name                 = $CollectionName
                Type                 = "script, chart"
                Command_WinRM_Script = "Invoke-Command -FilePath '$($script.FullName)'"
                Properties_PoSh      = 'PSComputerName, *'
                Description          = "$(Get-Help $($script.FullName) | Select-Object -ExpandProperty Description)".TrimStart('@{Text=').TrimEnd('}')
                ScriptPath           = "$($script.FullName)"
            }
        }
        else {
            $CollectionName = $script.basename
            $script:AllEndpointCommands += [PSCustomObject]@{ 
                Name                 = $CollectionName
                Type                 = "script"
                Command_WinRM_Script = "Invoke-Command -FilePath '$($script.FullName)'"
                Properties_PoSh      = 'PSComputerName, *'
                Description          = "$(Get-Help $($script.FullName) | Select-Object -ExpandProperty Description)".TrimStart('@{Text=').TrimEnd('}')
                ScriptPath           = "$($script.FullName)"
            }
        }
    }
}
Import-EndpointScripts

#===========================
# Active Directory Commands
#===========================

# Imports all the Active Directoyr Commands fromthe csv file
$script:AllActiveDirectoryCommands = Import-Csv $CommandsActiveDirectory

# Imports scripts from the Active Directory script folder and loads them into the treeview
Function Import-ActiveDirectoryScripts {
    Foreach ($script in (Get-ChildItem -Path "$CommandsHostDirectoryScripts\Active Directory")) {
        $CollectionName = $script.basename
        $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
            Name                 = $CollectionName
            Type                 = "script"
            Command_WinRM_Script = "Invoke-Command -FilePath '$($script.FullName)'"
            Properties_PoSh      = 'PSComputerName, *'
            Properties_WMI       = 'PSComputerName, *'
            Description          = "$(Get-Help $($script.FullName) | Select-Object -ExpandProperty Description)".TrimStart('@{Text=').TrimEnd('}')
            ScriptPath           = "$($script.FullName)"
        }
    }
}
Import-ActiveDirectoryScripts

#===========================
# Active Directory Commands
#===========================
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
$script:TreeeViewCommandsCount = 0

function Conduct-NodeAction {
    param(
        $TreeView,
        [switch]$Commands,
        [switch]$ComputerList
        )
    if ($Commands)     { $script:TreeeViewCommandsCount = 0 }
    if ($ComputerList) { $script:TreeeViewComputerListCount = 0 }
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
                    if ($Commands)     { $script:TreeeViewCommandsCount += 1 }
                    if ($ComputerList) { $script:TreeeViewComputerListCount += 1 }
                    $Entry.Checked   = $True
                    $Entry.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
                    $Entry.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                }          
            }
        } # END if ($root.Checked)
        if ($root.isselected) { 
            $script:HostQueryTreeViewSelected = ""
            $StatusListBox.Items.clear()
            $StatusListBox.Items.Add("Category:  $($root.Text)")
            $ResultsListBox.Items.Clear()
            $ResultsListBox.Items.Add("- Checkbox This Node to Execute All Commands Within")

            $Section3QueryExplorationName.Text      = "N/A"
            $Section3QueryExplorationTypeTextBox.Text      = "N/A"
            $Section3QueryExplorationWinRMPoShTextBox.Text = "N/A"
            $Section3QueryExplorationWinRMWMITextBox.Text  = "N/A"
            $Section3QueryExplorationRPCPoShTextBox.Text   = "N/A"
            $Section3QueryExplorationRPCWMITextBox.Text    = "N/A"

            $Section4TabControl.SelectedTab   = $Section3ResultsTab
        } # END if ($root.isselected)
        foreach ($Category in $root.Nodes) { 
            $EntryNodeCheckedCountforCategory = 0
            if ($Category.Checked) {
                $Category.Expand()
                $Category.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
                $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                $Root.NodeFont      = New-Object System.Drawing.Font("$Font",10,1,1,1)
                $Root.ForeColor     = [System.Drawing.Color]::FromArgb(0,0,0,224)
                foreach ($Entry in $Category.nodes) {
                    if ($Commands)     { $script:TreeeViewCommandsCount += 1 }
                    if ($ComputerList) { $script:TreeeViewComputerListCount += 1 }
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
                        if ($Commands)     { $script:TreeeViewCommandsCount += 1 }
                        if ($ComputerList) { $script:TreeeViewComputerListCount += 1 }
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

                $Section3QueryExplorationName.Text             = "N/A"
                $Section3QueryExplorationTypeTextBox.Text      = "N/A"
                $Section3QueryExplorationWinRMPoShTextBox.Text = "N/A"
                $Section3QueryExplorationWinRMWMITextBox.Text  = "N/A"
                $Section3QueryExplorationRPCPoShTextBox.Text   = "N/A"
                $Section3QueryExplorationRPCWMITextBox.Text    = "N/A"

                $Section4TabControl.SelectedTab   = $Section3ResultsTab
            }
            foreach ($Entry in $Category.nodes) { 
                $EntryNodesWithinCategory += 1
                if ($Entry.isselected) {
                    $script:HostQueryTreeViewSelected = $Entry.Text
                    $StatusListBox.Items.clear()
                    $StatusListBox.Items.Add("$($Entry.Text)")
                    $ResultsListBox.Items.clear()
                    $ResultsListBox.Items.Add("$((($Entry.Text) -split ' -- ')[-1])")
                    if ($root.text -match 'Endpoint Commands') {
                        $Section3QueryExplorationNameTextBox.Text           = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Name                    
                        $Section3QueryExplorationTagWordsTextBox.Text       = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Type
                        $Section3QueryExplorationWinRMPoShTextBox.Text      = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WinRM_PoSh
                        $Section3QueryExplorationWinRMWMITextBox.Text       = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WinRM_WMI
                        $Section3QueryExplorationWinRMCmdTextBox.Text       = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WinRM_Cmd
                        $Section3QueryExplorationRPCPoShTextBox.Text        = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_RPC_PoSh
                        $Section3QueryExplorationRPCWMITextBox.Text         = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WMI
                        $Section3QueryExplorationPropertiesPoshTextBox.Text = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Properties_PoSh
                        $Section3QueryExplorationPropertiesWMITextBox.Text  = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Properties_WMI
                        $Section3QueryExplorationWinRSWmicTextBox.Text      = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WinRS_WMIC
                        $Section3QueryExplorationWinRSCmdTextBox.Text       = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WinRS_CMD
                        $Section3QueryExplorationDescriptionTextbox.Text    = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Description
                    }
                    elseif ($root.text -match 'Active Directory Commands') {
                        $Section3QueryExplorationNameTextBox.Text           = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Name                    
                        $Section3QueryExplorationTagWordsTextBox.Text       = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Type
                        $Section3QueryExplorationWinRMPoShTextBox.Text      = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WinRM_PoSh
                        $Section3QueryExplorationWinRMWMITextBox.Text       = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WinRM_WMI
                        $Section3QueryExplorationWinRMCmdTextBox.Text       = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WinRM_Cmd
                        $Section3QueryExplorationRPCPoShTextBox.Text        = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_RPC_PoSh
                        $Section3QueryExplorationRPCWMITextBox.Text         = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WMI
                        $Section3QueryExplorationPropertiesPoshTextBox.Text = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Properties_PoSh
                        $Section3QueryExplorationPropertiesWMITextBox.Text  = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Properties_WMI
                        $Section3QueryExplorationWinRSWmicTextBox.Text      = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WinRS_WMIC
                        $Section3QueryExplorationWinRSCmdTextBox.Text       = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WinRS_CMD
                        $Section3QueryExplorationDescriptionTextbox.Text    = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Description                    
                    }
                    
                    if ($Category.text -match 'PowerShell Scripts'){
                        $Section3QueryExplorationTabPage.Controls.Remove($Section3QueryExplorationEditCheckBox) 
                        $Section3QueryExplorationTabPage.Controls.Remove($Section3QueryExplorationSaveButton) 
                        $Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationViewScriptButton) 
                    }
                    else { 
                        $Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationEditCheckBox) 
                        $Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationSaveButton) 
                        $Section3QueryExplorationTabPage.Controls.Remove($Section3QueryExplorationViewScriptButton) 
                    }
                    $Section4TabControl.SelectedTab   = $Section3QueryExplorationTabPage
                    
                    foreach ($Entry in $Category.nodes) {                     
                        if ($entry.checked) {
                            if ($Commands)     { $script:TreeeViewCommandsCount += 1 }
                            if ($ComputerList) { $script:TreeeViewComputerListCount += 1 }
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
        } # END foreach ($Category in $root.Nodes)
    } # END foreach ($root in $AllNodes)

    # Note: If adding new checkboxes to other areas, make sure also add it to the script handler
    if ($Commands) {
        if ($FileSearchDirectoryListingCheckbox.Checked)             { $script:TreeeViewCommandsCount++ }
        if ($FileSearchFileSearchCheckbox.Checked)                   { $script:TreeeViewCommandsCount++ }
        if ($FileSearchAlternateDataStreamCheckbox.Checked)          { $script:TreeeViewCommandsCount++ }
        if ($SysinternalsSysmonCheckbox.Checked)                     { $script:TreeeViewCommandsCount++ }
        if ($SysinternalsAutorunsCheckbox.Checked)                   { $script:TreeeViewCommandsCount++ }
        if ($SysinternalsProcessMonitorCheckbox.Checked)             { $script:TreeeViewCommandsCount++ }
        if ($EventLogsEventIDsManualEntryCheckbox.Checked)           { $script:TreeeViewCommandsCount++ }
        if ($EventLogsEventIDsIndividualSelectionCheckbox.Checked)   { $script:TreeeViewCommandsCount++ }
        if ($NetworkConnectionSearchRemoteIPAddressCheckbox.checked) { $script:TreeeViewCommandsCount++ }
        if ($NetworkConnectionSearchRemotePortCheckbox.checked)      { $script:TreeeViewCommandsCount++ }
        if ($NetworkConnectionSearchProcessCheckbox.checked)         { $script:TreeeViewCommandsCount++ }
        if ($NetworkConnectionSearchDNSCacheCheckbox.checked)        { $script:TreeeViewCommandsCount++ }
        if ($EventLogsQuickPickSelectionCheckbox.Checked)            { $script:TreeeViewCommandsCount++ }
    }
    # Updates the color of the button if there is at least one query and endpoint selected
    if ($script:TreeeViewCommandsCount -gt 0 -and $script:TreeeViewComputerListCount -gt 0) { $ComputerListExecuteButton.forecolor = 'Black'; $ComputerListExecuteButton.backcolor = 'lightgreen' }
    else { $ComputerListExecuteButton.forecolor = 'Red' ; $ComputerListExecuteButton.ResetBackColor() }
} # END function

function Initialize-CommandsTreeView {
    $script:TreeNodeCommandSearch = New-Object -TypeName System.Windows.Forms.TreeNode -ArgumentList "* Search Results          " -Property @{
        Tag       = "Search"
        NodeFont  = New-Object System.Drawing.Font("$Font",11,1,2,1)
        ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
    }    
    $script:TreeNodeEndpointCommands = New-Object -TypeName System.Windows.Forms.TreeNode -ArgumentList "1) Endpoint Commands          " -Property @{
        Tag       = "Endpoint Commands"
        NodeFont  = New-Object System.Drawing.Font("$Font",11,1,2,1)
        ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
    }
    $script:TreeNodeActiveDirectoryCommands = New-Object -TypeName System.Windows.Forms.TreeNode -ArgumentList "2) Active Directory Commands          " -Property @{
        Tag       = "ADDS Commands"
        NodeFont  = New-Object System.Drawing.Font("$Font",11,1,2,1)
        ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
    }
    $script:TreeNodePreviouslyExecutedCommands = New-Object -TypeName System.Windows.Forms.TreeNode -ArgumentList "3) Query History          " -Property @{
        Tag       = "Query History"
        NodeFont  = New-Object System.Drawing.Font("$Font",11,1,2,1)
        ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
    }
    $script:TreeNodeCommandSearch.Expand()
    $script:TreeNodeEndpointCommands.Expand()
    $script:TreeNodeActiveDirectoryCommands.Expand()
    $script:TreeNodePreviouslyExecutedCommands.Collapse()
    $CommandsTreeView.Nodes.Clear()
}

# This section will check the checkboxes selected under the other view
function Keep-CommandsCheckboxesChecked {
    $CommandsTreeView.Nodes.Add($script:TreeNodeEndpointCommands)
    $CommandsTreeView.Nodes.Add($script:TreeNodeActiveDirectoryCommands)
    $CommandsTreeView.Nodes.Add($script:TreeNodeCommandSearch)
    $CommandsTreeView.Nodes.Add($script:TreeNodePreviouslyExecutedCommands)    
    [System.Windows.Forms.TreeNodeCollection]$AllCommandsNode = $CommandsTreeView.Nodes 
    if ($CommandsCheckedBoxesSelected.count -gt 0) {
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Categories that were checked will not remained checked.")
        $ResultsListBox.Items.Add("")
        $ResultsListBox.Items.Add("The following Commands are still selected:")
        foreach ($root in $AllCommandsNode) { 
            foreach ($Category in $root.Nodes) { 
                foreach ($Entry in $Category.nodes) { 
                    if ($CommandsCheckedBoxesSelected -contains $Entry.text -and $root.text -notmatch 'Query History') {
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
Cons       Requires WinRM
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
Pros:      Works with older OSs
           Does not require WinRM
Cons:      Uses random high ports
           Not firewall friendly
           Transmits data in clear text
"@
        }
        else { $CategoryNode.ToolTipText = "This is the directory name of the commands executed previously at that momemnt." }

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
    # Adds Endpoint Command nodes
    Foreach( $Command in $script:AllEndpointCommands ) {
        if ($Command.Command_RPC_PoSh)     { Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-13}{1}" -f "[RPC]", "PowerShell Cmdlets") -Entry "(RPC) PoSh -- $($Command.Name)" -ToolTip $Command.Command_RPC_PoSh }
        if ($Command.Command_WMI)          { Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-13}{1}" -f "[RPC]", "Windows Management Instrumentation (WMI)") -Entry "(RPC) WMI -- $($Command.Name)" -ToolTip $Command.Command_WMI }
        if ($Command.Command_WinRM_Script) { Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-10}{1}" -f "[WinRM]", "PowerShell Scripts") -Entry "(WinRM) Script -- $($Command.Name)" -ToolTip $Command.Command_WinRM_Script }        
        if ($Command.Command_WinRM_PoSh)   { Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-10}{1}" -f "[WinRM]", "PowerShell Cmdlets") -Entry "(WinRM) PoSh -- $($Command.Name)" -ToolTip $Command.Command_WinRM_PoSh }
        if ($Command.Command_WinRM_WMI)    { Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-10}{1}" -f "[WinRM]", "Windows Management Instrumentation (WMI)") -Entry "(WinRM) WMI -- $($Command.Name)" -ToolTip $Command.Command_WinRM_WMI }
        if ($Command.Command_WinRM_CMD)    { Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-10}{1}" -f "[WinRM]", "Windows CMD") -Entry "(WinRM) CMD -- $($Command.Name)" -ToolTip $Command.Command_WinRM_CMD }
    }
    # Adds Active Directory Command nodes
    Foreach($Command in $script:AllActiveDirectoryCommands) {
        if ($Command.Command_RPC_PoSh)     { Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-13}{1}" -f "[RPC]", "PowerShell Cmdlets") -Entry "(RPC) PoSh -- $($Command.Name)" -ToolTip $Command.Command_RPC_PoSh }
        if ($Command.Command_WMI)          { Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-13}{1}" -f "[RPC]", "Windows Management Instrumentation (WMI)") -Entry "(RPC) WMI -- $($Command.Name)" -ToolTip $Command.Command_WMI }
        if ($Command.Command_WinRM_Script) { Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-10}{1}" -f "[WinRM]", "PowerShell Scripts") -Entry "(WinRM) Script -- $($Command.Name)" -ToolTip $Command.Command_WinRM_Script }        
        if ($Command.Command_WinRM_PoSh)   { Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-10}{1}" -f "[WinRM]", "PowerShell Cmdlets") -Entry "(WinRM) PoSh -- $($Command.Name)" -ToolTip $Command.Command_WinRM_PoSh }
        if ($Command.Command_WinRM_WMI)    { Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-10}{1}" -f "[WinRM]", "Windows Management Instrumentation (WMI)") -Entry "(WinRM) WMI -- $($Command.Name)" -ToolTip $Command.Command_WinRM_WMI }
        if ($Command.Command_WinRM_CMD)    { Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-10}{1}" -f "[WinRM]", "Windows CMD") -Entry "(WinRM) CMD -- $($Command.Name)" -ToolTip $Command.Command_WinRM_CMD }

    }
    # Adds the selected commands to the Query History Command Nodes
    foreach ($Command in $script:QueryHistoryCommands) { Add-CommandsNode -RootNode $script:TreeNodePreviouslyExecutedCommands -Category "$($Command.CategoryName)" -Entry "$($Command.Name)" -ToolTip "$($Command.Command)" }
}
# Groups Commands TreeNodes by Method
Function View-CommandsTreeViewQuery {
    # Adds Endpoint Command nodes
    Foreach($Command in $script:AllEndpointCommands) {
        if ($Command.Command_RPC_PoSh)     { Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(RPC) PoSh -- $($Command.Name)" -ToolTip $Command.Command_RPC_PoSh }
        if ($Command.Command_WMI)          { Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(RPC) WMI -- $($Command.Name)" -ToolTip $Command.Command_WMI }
        if ($Command.Command_WinRM_Script) { Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(WinRM) Script -- $($Command.Name)" -ToolTip $Command.Command_WinRM_Script }        
        if ($Command.Command_WinRM_PoSh)   { Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(WinRM) PoSh -- $($Command.Name)" -ToolTip $Command.Command_WinRM_PoSh }
        if ($Command.Command_WinRM_WMI)    { Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(WinRM) WMI -- $($Command.Name)" -ToolTip $Command.Command_WinRM_WMI }
        if ($Command.Command_WinRM_CMD)    { Add-CommandsNode -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(WinRM) CMD -- $($Command.Name)" -ToolTip $Command.Command_WinRM_CMD }
    }
    # Adds Active Directory Command nodes
    Foreach($Command in $script:AllActiveDirectoryCommands) {
        if ($Command.Command_RPC_PoSh)     { Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(RPC) PoSh -- $($Command.Name)" -ToolTip $Command.Command_RPC_PoSh }
        if ($Command.Command_WMI)          { Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(RPC) WMI -- $($Command.Name)" -ToolTip $Command.Command_WMI }
        if ($Command.Command_WinRM_Script) { Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(WinRM) Script -- $($Command.Name)" -ToolTip $Command.Command_WinRM_Script }        
        if ($Command.Command_WinRM_PoSh)   { Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(WinRM) PoSh -- $($Command.Name)" -ToolTip $Command.Command_WinRM_PoSh }
        if ($Command.Command_WinRM_WMI)    { Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(WinRM) WMI -- $($Command.Name)" -ToolTip $Command.Command_WinRM_WMI }
        if ($Command.Command_WinRM_CMD)    { Add-CommandsNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(WinRM) CMD -- $($Command.Name)" -ToolTip $Command.Command_WinRM_CMD }
    }
    # Adds the selected commands to the Query History Command Nodes
    foreach ($Command in $script:QueryHistoryCommands) {
        Add-CommandsNode -RootNode $script:TreeNodePreviouslyExecutedCommands -Category "$($Command.CategoryName)" -Entry "$($Command.Name)" -ToolTip "$($Command.Command)"
    }
}

Function Message-HostAlreadyExists($Message) {
    [system.media.systemsounds]::Exclamation.play()
    if ($Computer.Name) {$Computer = $Computer.Name}
    else {$Computer}
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("$Message")
    $ResultsListBox.Items.Add("$Computer - already exists with the following data:")
    $ResultsListBox.Items.Add("- OU/CN: $($($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $Computer}).CanonicalName)")
    $ResultsListBox.Items.Add("- OS:    $($($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $Computer}).OperatingSystem)")
    #$ResultsListBox.Items.Add("- IP:    $($($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $Computer}).IPv4Address)")
    #$ResultsListBox.Items.Add("- MAC:   $($($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $Computer}).MACAddress)")
    $ResultsListBox.Items.Add("")
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
                    if ($Entry.Checked) { $CommandsCheckedBoxesSelected += $Entry.Text }
                }
            }
        }
        $CommandsTreeView.Nodes.Clear()
        Initialize-CommandsTreeView
        AutoSave-HostData
        View-CommandsTreeViewMethod
        Keep-CommandsCheckboxesChecked
    })
    $CommandsViewMethodRadioButton.Add_MouseHover({
        ToolTipFunction -Title "Display by Method" -Icon "Info" -Message @"
⦿ Displays commands grouped by the method they're collected
⦿ All commands executed against each host are logged`n`n
"@  })
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
        AutoSave-HostData
        View-CommandsTreeViewQuery
        Keep-CommandsCheckboxesChecked
    })
    $CommandsViewQueryRadioButton.Add_MouseHover({
    ToolTipFunction -Title "Display by Query" -Icon "Info" -Message @"
⦿ Displays commands grouped by queries
⦿ All commands executed against each host are logged`n`n
"@  })
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
                      Y = 13 }
        Size     = @{ Width  = 130
                      Height = 22 }
        Checked  = $true
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = 'Black'
    }
    $CommandsTreeViewQueryAsIndividualRadioButton.Add_Click({ 
        $PoShACME.Controls.Add($ProgressBarQueriesLabel)
        $PoShACME.Controls.Add($ProgressBarQueriesProgressBar)
    })
    $CommandsTreeViewQueryAsGroupBox.Controls.Add($CommandsTreeViewQueryAsIndividualRadioButton)

    #------------------------------------------------------
    # Commands Treeview - Query As Compiled - Radio Button
    #------------------------------------------------------
    $CommandsTreeViewQueryAsCompiledRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
        Text     = 'Compile & Review'
        Location = @{ X = $CommandsTreeViewQueryAsIndividualRadioButton.Location.X + $CommandsTreeViewQueryAsIndividualRadioButton.Size.Width
                      Y = $CommandsTreeViewQueryAsIndividualRadioButton.Location.Y }
        Size     = @{ Width  = 125
                      Height = 22 }
        Checked  = $false
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = 'Black'
    }
    $CommandsTreeViewQueryAsCompiledRadioButton.Add_Click({ 
        $PoShACME.Controls.Remove($ProgressBarQueriesLabel)
        $PoShACME.Controls.Remove($ProgressBarQueriesProgressBar)
    })
    $CommandsTreeViewQueryAsGroupBox.Controls.Add($CommandsTreeViewQueryAsCompiledRadioButton)
$Section1CommandsTab.Controls.Add($CommandsTreeViewQueryAsGroupBox)

#-------------------------------------
# Commands TreeView - Search Function
#-------------------------------------
function Search-CommandsTreeView {
    $Section4TabControl.SelectedTab = $Section3ResultsTab
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
                ($Command.Description -imatch $CommandsTreeViewSearchTextBox.Text))) {
                if ($Command.Command_RPC_PoSh)     { Add-CommandsNode -RootNode $script:TreeNodeCommandSearch -Category $($CommandsTreeViewSearchTextBox.Text) -Entry "(RPC) PoSh -- $($Command.Name)" -ToolTip $Command.Command_RPC_PoSh }
                if ($Command.Command_WMI)          { Add-CommandsNode -RootNode $script:TreeNodeCommandSearch -Category $($CommandsTreeViewSearchTextBox.Text) -Entry "(RPC) WMI -- $($Command.Name)" -ToolTip $Command.Command_WMI }
                #if ($Command.Command_RPC_CMD)     { Add-CommandsNode -RootNode $script:TreeNodeCommandSearch -Category $($CommandsTreeViewSearchTextBox.Text) -Entry "(RPC) CMD -- $($Command.Name)" -ToolTip $Command.Command_RPC_CMD }
                #if ($Command.Command_WinRS_WMIC)  { Add-CommandsNode -RootNode $script:TreeNodeCommandSearch -Category $($CommandsTreeViewSearchTextBox.Text) -Entry "(WinRM) WMIC -- $($Command.Name)" -ToolTip $Command.Command_WinRS_WMIC }
                #if ($Command.Command_WinRS_CMD)   { Add-CommandsNode -RootNode $script:TreeNodeCommandSearch -Category $($CommandsTreeViewSearchTextBox.Text) -Entry "(WinRM) CMD -- $($Command.Name)" -ToolTip $Command.Command_WinRS_CMD }
                if ($Command.Command_WinRM_Script) { Add-CommandsNode -RootNode $script:TreeNodeCommandSearch -Category $($CommandsTreeViewSearchTextBox.Text) -Entry "(WinRM) Script -- $($Command.Name)" -ToolTip $Command.Command_WinRM_Script }        
                if ($Command.Command_WinRM_PoSh)   { Add-CommandsNode -RootNode $script:TreeNodeCommandSearch -Category $($CommandsTreeViewSearchTextBox.Text) -Entry "(WinRM) PoSh -- $($Command.Name)" -ToolTip $Command.Command_WinRM_PoSh }
                if ($Command.Command_WinRM_WMI)    { Add-CommandsNode -RootNode $script:TreeNodeCommandSearch -Category $($CommandsTreeViewSearchTextBox.Text) -Entry "(WinRM) WMI -- $($Command.Name)" -ToolTip $Command.Command_WinRM_WMI }
                if ($Command.Command_WinRM_CMD)    { Add-CommandsNode -RootNode $script:TreeNodeCommandSearch -Category $($CommandsTreeViewSearchTextBox.Text) -Entry "(WinRM) CMD -- $($Command.Name)" -ToolTip $Command.Command_WinRM_CMD }
            }
        }
    }
    # Expands the search results
    [System.Windows.Forms.TreeNodeCollection]$AllCommandsNode = $CommandsTreeView.Nodes 
    foreach ($root in $AllCommandsNode) { 
        if ($root.text -match 'Search Results'){
            $root.Expand()
            foreach ($Category in $root.Nodes) {
                if ($CommandsTreeViewSearchTextBox.text -in $Category.text) { $Category.Expand() }
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
                  Y = 45 }
    Size     = @{ Width  = 172
                  Height = 25 }
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
    ToolTipFunction -Title "Search Input Field" -Icon "Info" -Message @"
⦿ Searches may be typed in manually.
⦿ Searches can include any character.
⦿ There are several default searches available.`n`n
"@ })
$Section1CommandsTab.Controls.Add($CommandsTreeViewSearchTextBox)

#-----------------------------------
# Computer TreeView - Search Button
#-----------------------------------
$CommandsTreeViewSearchButton = New-Object System.Windows.Forms.Button -Property @{
    Name     = "Search Button"
    Text     = "Search"
    Location = @{ X = $CommandsTreeViewSearchTextBox.Size.Width + 5
                  Y = 45 }
    Size     = @{ Width  = 55
                  Height = 22 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$CommandsTreeViewSearchButton.Add_Click({ Search-CommandsTreeView })
$CommandsTreeViewSearchButton.Add_MouseHover({
    ToolTipFunction -Title "Command Search" -Icon "Info" -Message @"
⦿ Searches through query names and metadata.
⦿ Search results are returned as nodes.
⦿ Search results are not persistent.`n`n
"@ })
$Section1CommandsTab.Controls.Add($CommandsTreeViewSearchButton)


#-----------------------------------------
# Commands Treeview - Deselect All Button
#-----------------------------------------
$CommandsTreeviewDeselectAllButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = 'Deselect All'
    Location = @{ X = 336
                  Y = 45 }
    Size     = @{ Width  = 100
                  Height = 22 }
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

    Conduct-NodeAction -TreeView $CommandsTreeView.Nodes -Commands
})
$CommandsTreeviewDeselectAllButton.Add_MouseHover({
    ToolTipFunction -Title "Deselect All" -Icon "Info" -Message @"
⦿ Unchecks all commands checked within this view.
⦿ Commands and queries in other Tabs must be manually unchecked.`n`n
"@ })
$Section1CommandsTab.Controls.Add($CommandsTreeviewDeselectAllButton) 

#---------------------------
# Commands Treeview Nodes
#---------------------------
$CommandsTreeView = New-Object System.Windows.Forms.TreeView -Property @{
    Location = @{ X = 0 
                  Y = 70 }
    Size     = @{ Width  = 435
                  Height = 459 }
    Font             = New-Object System.Drawing.Font("$Font",11,0,0,0)
    CheckBoxes       = $True
    #LabelEdit       = $True
    ShowLines        = $True
    ShowNodeToolTips = $True
}
$CommandsTreeView.Sort()
$CommandsTreeView.Add_Click({ Conduct-NodeAction -TreeView $CommandsTreeView.Nodes -Commands })
$CommandsTreeView.add_AfterSelect({ Conduct-NodeAction -TreeView $CommandsTreeView.Nodes -Commands })
$Section1CommandsTab.Controls.Add($CommandsTreeView)

# Default View
Initialize-CommandsTreeView
# This adds the nodes to the Commands TreeView
View-CommandsTreeViewMethod

$CommandsTreeView.Nodes.Add($script:TreeNodeEndpointCommands)
$CommandsTreeView.Nodes.Add($script:TreeNodeActiveDirectoryCommands)
$CommandsTreeView.Nodes.Add($script:TreeNodeCommandSearch)
$CommandsTreeView.Nodes.Add($script:TreeNodePreviouslyExecutedCommands)
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
                  Y = $Column1DownPosition }
    Size     = @{ Width  = $Column1BoxWidth
                  Height = $Column1BoxHeight }
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
    $EventLogWinRMRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
        Text     = "WinRM"
        Location = @{ X = 80
                      Y = 15 }
        Size     = @{ Width  = 60
                      Height = 22 }
        Checked  = $True
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = 'Black'
    }
    $EventLogWinRMRadioButton.Add_MouseHover({
        ToolTipFunction -Title "WinRM" -Icon "Info" -Message @"
⦿ Invoke-Command -ComputerName <Endpoint> -ScriptBlock { 
     Get-WmiObject -Class Win32_NTLogEvent -Filter "(((EventCode='4624') OR (EventCode='4634')) and `
     (TimeGenerated>='20190313180030.000000-300') and (TimeGenerated<='20190314180030.000000-300')) }"`n`n
"@  })
    #---------------------------------------
    # Event Log Protocol RPC - Radio Button
    #---------------------------------------
    $EventLogRPCRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
        Text     = "RPC"
        Location = @{ X = $EventLogWinRMRadioButton.Location.X + 55
                      Y = $EventLogWinRMRadioButton.Location.Y }
        Size     = @{ Width  = 60
                      Height = 22 }
        Checked  = $False
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = 'Black'
    }
    $EventLogRPCRadioButton.Add_MouseHover({
        ToolTipFunction -Title "RPC" -Icon "Info" -Message @"
⦿ Get-WmiObject -Class Win32_NTLogEvent -Filter "(((EventCode='4624') OR (EventCode='4634')) and `
     (TimeGenerated>='$([System.Management.ManagementDateTimeConverter]::ToDmtfDateTime(($EventLogsStartTimePicker.Value)))') and (TimeGenerated<='20190314180030.000000-300'))"`n`n
"@  })
    #---------------------------------------
    # Event Logs - Maximum Collection Label
    #---------------------------------------
    $EventLogsMaximumCollectionLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Max Collection:"
        Location = @{ X = $EventLogRPCRadioButton.Location.X + $EventLogRPCRadioButton.Size.Width + 52
                      Y = $EventLogRPCRadioButton.Location.Y + 3 }
        Size     = @{ Width  = 100
                      Height = 22 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = "Black"
    }
    $EventLogsMaximumCollectionLabel.Add_MouseHover({
        ToolTipFunction -Title "Max Collection" -Icon "Info" -Message @"
⦿ Enter the maximum number of Event Logs to return
⦿ This can be used with the datatime picker
⦿ If left blank, it will collect all available Event Logs
⦿ An entry of 0 (zero) will return no Event Logs`n`n
"@  })
        #-----------------------------------------
        # Event Logs - Maximum Collection TextBox
        #-----------------------------------------
        $EventLogsMaximumCollectionTextBox = New-Object System.Windows.Forms.TextBox -Property @{
            Text     = $null
            Location = @{ X = $EventLogsMaximumCollectionLabel.Location.X + $EventLogsMaximumCollectionLabel.Size.Width
                          Y = $EventLogsMaximumCollectionLabel.Location.Y - 3 }
            Size     = @{ Width  = 50
                          Height = 22 }
            Font     = New-Object System.Drawing.Font("$Font",10,0,0,0)
            Enabled  = $True
        }
        $EventLogsMaximumCollectionTextBox.Add_MouseHover({
            ToolTipFunction -Title "Max Collection" -Icon "Info" -Message @"
⦿ Enter the maximum number of Event Logs to return
⦿ This can be used with the datatime picker
⦿ If left blank, it will collect all available Event Logs
⦿ An entry of 0 (zero) will return no Event Logs`n`n
"@  })
    #-----------------------------------
    # Event Logs - DateTime Start Label
    #-----------------------------------
    $EventLogsDatetimeStartLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "DateTime Start:"
        Location = @{ X = 77
                      Y = $EventLogProtocolRadioButtonLabel.Location.Y + $EventLogProtocolRadioButtonLabel.Size.Height + 5 }
        Size     = @{ Width  = 90
                      Height = 25 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = "Black"
    }
        #--------------------------------------------
        # Event Logs - DateTime Start DateTimePicker
        #--------------------------------------------
        $EventLogsStartTimePicker = New-Object System.Windows.Forms.DateTimePicker -Property @{
            Location      = @{ X = $EventLogsDatetimeStartLabel.Location.X + $EventLogsDatetimeStartLabel.Size.Width
                               Y = $EventLogProtocolRadioButtonLabel.Location.Y + $EventLogProtocolRadioButtonLabel.Size.Height }
            Size          = @{ Width  = 250
                               Height = 100 }
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
        $EventLogsStartTimePicker.Add_MouseHover({
            ToolTipFunction -Title "DateTime - Starting" -Icon "Info" -Message @"
⦿ Select the starting datetime to filter Event Logs
⦿ This can be used with the Max Collection field
⦿ If left blank, it will collect all available Event Logs
⦿ If used, you must select both a start and end datetime`n`n
"@  })
        $EventLogsStartTimePicker.Add_Click({ if ($EventLogsStopTimePicker.checked -eq $false){$EventLogsStopTimePicker.checked = $true } })
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
                      Y = $EventLogsDatetimeStartLabel.Location.Y + $EventLogsDatetimeStartLabel.Size.Height }
        Size     = @{ Width  = $EventLogsDatetimeStartLabel.Width
                      Height = 25 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = "Black"
    }
        #-------------------------------------------
        # Event Logs - DateTime Stop DateTimePicker
        #-------------------------------------------
        $EventLogsStopTimePicker = New-Object System.Windows.Forms.DateTimePicker -Property @{
            Location     = @{ X = $EventLogsDatetimeStopLabel.Location.X + $EventLogsDatetimeStopLabel.Size.Width
                              Y = $EventLogsDatetimeStartLabel.Location.Y + $EventLogsDatetimeStartLabel.Size.Height - 5 }
            Size         = @{ Width  = $EventLogsStartTimePicker.Width
                              Height = 100 }
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
        $EventLogsStartTimePicker.Add_MouseHover({
            ToolTipFunction -Title "DateTime - Ending" -Icon "Info" -Message @"
⦿ Select the ending datetime to filter Event Logs
⦿ This can be used with the Max Collection field
⦿ If left blank, it will collect all available Event Logs
⦿ If used, you must select both a start and end datetime`n`n
"@  })
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
}
$EventLogsEventIDsManualEntryCheckbox.Add_Click({Conduct-NodeAction -TreeView $CommandsTreeView.Nodes -Commands})
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
if (Test-Path $EventIDsFile) {
    $EventLogsEventIDsManualEntrySelectionButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Select Event IDs"
        Location = @{ X = 4
                      Y = $EventLogsEventIDsManualEntryLabel.Location.Y + $EventLogsEventIDsManualEntryLabel.Size.Height }
        Size     = @{ Width  = 125
                      Height = 20 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $EventLogsEventIDsManualEntrySelectionButton.Add_Click({
        Import-Csv $EventIDsFile | Out-GridView  -Title 'PoSh-ACME: Event IDs' -OutputMode Multiple | Set-Variable -Name EventCodeManualEntrySelectionContents
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
$EventLogsEventIDsManualEntryClearButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Clear"
    Location = @{ X = 136
                  Y = $EventLogsEventIDsManualEntryLabel.Location.Y + $EventLogsEventIDsManualEntryLabel.Size.Height }
    Size     = @{ Width  = 75
                  Height = 20 }
}
$EventLogsEventIDsManualEntryClearButton.Add_Click({ $EventLogsEventIDsManualEntryTextbox.Text = "" })
$EventLogsEventIDsManualEntryClearButton.Font = New-Object System.Drawing.Font("$Font",11,0,0,0)
$Section1EventLogsTab.Controls.Add($EventLogsEventIDsManualEntryClearButton) 

#----------------------------------------------
# Event Logs - Event IDs Manual Entry Textbox
#----------------------------------------------
$EventLogsEventIDsManualEntryTextbox = New-Object System.Windows.Forms.TextBox -Property @{
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
. "$PoShHome\Dependencies\Event Logs - Event ID Quick Pick Pick Selection.ps1"

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
}
$EventLogsQuickPickSelectionCheckbox.Add_Click({Conduct-NodeAction -TreeView $CommandsTreeView.Nodes -Commands})
$Section1EventLogsTab.Controls.Add($EventLogsQuickPickSelectionCheckbox)

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
$EventLogsQuickPickSelectionClearButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Clear"
    Location = @{ X = 356
                  Y = $EventLogsQuickPickSelectionLabel.Location.Y + $EventLogsQuickPickSelectionLabel.Size.Height }
    Size     = @{ Width  = 75
                  Height = 20 }
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
                  Y = $EventLogsQuickPickSelectionClearButton.Location.Y + $EventLogsQuickPickSelectionClearButton.Size.Height + 5 }
    Size     = @{ Width  = 210
                  Height = 150 }
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
                      Y = $EventLogsEventIDsManualEntryTextbox.Location.Y + $EventLogsEventIDsManualEntryTextbox.Size.Height + 15 }
        Size     = @{ Width  = 350
                      Height = $EventLogsBoxHeight }
        Font     = New-Object System.Drawing.Font("$Font",12,1,2,1)
        ForeColor = 'Blue'
    }
    $EventLogsEventIDsIndividualSelectionCheckbox.Add_Click({Conduct-NodeAction -TreeView $CommandsTreeView.Nodes -Commands})
    $Section1EventLogsTab.Controls.Add($EventLogsEventIDsIndividualSelectionCheckbox)

    #-----------------------------------------------------------
    # Event Logs - Event IDs Individual Selection Clear Button
    #-----------------------------------------------------------
    $EventLogsEventIDsIndividualSelectionClearButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Clear"
        Location = @{ X = 356
                      Y = $EventLogsEventIDsIndividualSelectionCheckbox.Location.Y + $EventLogsEventIDsIndividualSelectionCheckbox.Size.Height - 3 }
        Size     = @{ Width  = 75
                      Height = 20 }
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
                      Y = $EventLogsEventIDsIndividualSelectionCheckbox.Location.Y + $EventLogsEventIDsIndividualSelectionCheckbox.Size.Height }
        Size     = @{ Width  = $EventLogsBoxWidth
                      Height = $EventLogsBoxHeight }
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
                      Y = $EventLogsEventIDsIndividualSelectionLabel.Location.Y + $EventLogsEventIDsIndividualSelectionLabel.Size.Height }
        Size     = @{ Width  = 425
                      Height = 125 }
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
            if ( $ComputerListProvideCredentialsCheckBox.Checked ) {
                $EventLogQueryBuild = "Invoke-Command $EventLogQueryComputer -ScriptBlock { $EventLogQueryCommand $EventLogQueryFilter $EventLogQueryPipe } -Credential $script:Credential"
                Start-Job -Name "PoSh-ACME: $CollectionName -- $TargetComputer" -ScriptBlock {
                    param($ThreadPriority,$EventLogQueryBuild,$script:Credential)
                    Invoke-Expression -Command "$ThreadPriority"
                    Invoke-Expression -Command "$EventLogQueryBuild $script:Credential"
                } -ArgumentList @($ThreadPriority,$EventLogQueryBuild,$script:Credential)
            }
            else {
                $EventLogQueryBuild = "Invoke-Command $EventLogQueryComputer -ScriptBlock { $EventLogQueryCommand $EventLogQueryFilter $EventLogQueryPipe }"
                Start-Job -Name "PoSh-ACME: $CollectionName -- $TargetComputer" -ScriptBlock {
                    param($ThreadPriority,$EventLogQueryBuild)
                    Invoke-Expression -Command "$ThreadPriority"
                    Invoke-Expression -Command "$EventLogQueryBuild"
                } -ArgumentList @($ThreadPriority,$EventLogQueryBuild)
            }
            $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  $TargetComputer`: $EventLogQueryBuild"
            $LogMessage | Add-Content -Path $LogFile

        }
        elseif ($EventLogRPCRadioButton.Checked) {
            if ( $ComputerListProvideCredentialsCheckBox.Checked ) {
                $EventLogQueryBuild = "$EventLogQueryCommand $EventLogQueryComputer $EventLogQueryFilter -Credential $script:Credential $EventLogQueryPipe"
                Start-Job -Name "PoSh-ACME: $CollectionName -- $TargetComputer" -ScriptBlock {
                    param($ThreadPriority,$EventLogQueryBuild)
                    Invoke-Expression -Command "$ThreadPriority"
                    Invoke-Expression -Command "$EventLogQueryBuild"
                } -ArgumentList @($ThreadPriority,$EventLogQueryBuild)
            }
            else {
                $EventLogQueryBuild = "$EventLogQueryCommand $EventLogQueryComputer $EventLogQueryFilter $EventLogQueryPipe"
                Start-Job -Name "PoSh-ACME: $CollectionName -- $TargetComputer" -ScriptBlock {
                    param($ThreadPriority,$EventLogQueryBuild)
                    Invoke-Expression -Command "$ThreadPriority"
                    Invoke-Expression -Command "$EventLogQueryBuild"
                } -ArgumentList @($ThreadPriority,$EventLogQueryBuild)
            }
            $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  $TargetComputer`: $EventLogQueryBuild"
            $LogMessage | Add-Content -Path $LogFile            
        }
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
    Text                    = "Search"
    Location = @{ X = $FileSearchRightPosition
                  Y = $FileSearchDownPosition }
    Size     = @{ Width  = $FileSearchLabelWidth
                  Height = $FileSearchLabelHeight }
    Font                    = New-Object System.Drawing.Font("$Font",11,0,0,0)
    UseVisualStyleBackColor = $True
}
$Section1CollectionsTabControl.Controls.Add($Section1FileSearchTab)

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

        if ($ComputerListProvideCredentialsCheckBox.Checked) {
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
}

$FileSearchDirectoryListingCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Directory Listing (WinRM)"
    Location = @{ X = $FileSearchRightPosition
                  Y = $FileSearchDownPosition }
    Size     = @{ Width  = 230
                  Height = $FileSearchLabelHeight }
    Font     = New-Object System.Drawing.Font("$Font",12,1,2,1)
    ForeColor = 'Blue'
}
$FileSearchDirectoryListingCheckbox.Add_Click({Conduct-NodeAction -TreeView $CommandsTreeView.Nodes -Commands})
$Section1FileSearchTab.Controls.Add($FileSearchDirectoryListingCheckbox)

#--------------------------------------------------
# File Search - Directory Listing Max Depth Label
#--------------------------------------------------
$FileSearchDirectoryListingMaxDepthLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "Recursive Depth"
    Location = @{ X = $FileSearchDirectoryListingCheckbox.Size.Width + 52
                  Y = $FileSearchDownPosition + 3 }
    Size     = @{ Width  = 100
                  Height = $FileSearchLabelHeight }
    Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor  = "Black"
}
$Section1FileSearchTab.Controls.Add($FileSearchDirectoryListingMaxDepthLabel)

#----------------------------------------------------
# File Search - Directory Listing Max Depth Textbox
#----------------------------------------------------
$FileSearchDirectoryListingMaxDepthTextbox = New-Object System.Windows.Forms.TextBox -Property @{
    Text     = 0
    Location = @{ X = $FileSearchDirectoryListingMaxDepthLabel.Location.X + $FileSearchDirectoryListingMaxDepthLabel.Size.Width
                  Y = $FileSearchDownPosition }
    Size     = @{ Width  = 50
                  Height = 20 }
    MultiLine      = $false
    WordWrap       = $false
    Font           = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$Section1FileSearchTab.Controls.Add($FileSearchDirectoryListingMaxDepthTextbox)

$FileSearchDownPosition += $FileSearchDownPositionShift

#----------------------------------------------
# File Search - Directory Listing Label
#----------------------------------------------
$FileSearchDirectoryListingLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = "Collection time is dependant on the directory's contents."
    Location = @{ X = $FileSearchRightPosition
                  Y = $FileSearchDownPosition }
    Size     = @{ Width  = $FileSearchLabelWidth
                  Height = $FileSearchLabelHeight }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Black"
}
$Section1FileSearchTab.Controls.Add($FileSearchDirectoryListingLabel)

$FileSearchDownPosition += $FileSearchDownPositionShift

#----------------------------------------------------
# File Search - Directory Listing Directory Textbox
#----------------------------------------------------
$FileSearchDirectoryListingTextbox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $FileSearchRightPosition
                  Y = $FileSearchDownPosition }
    Size     = @{ Width  = 430
                  Height = 22 }
    MultiLine          = $False
    #ScrollBars         = "Vertical"
    WordWrap           = $false
    Text               = "Enter a single directory"
    AutoCompleteSource = "FileSystem" # Options are: FileSystem, HistoryList, RecentlyUsedList, AllURL, AllSystemSources, FileSystemDirectories, CustomSource, ListItems, None
    AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
    Font               = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$FileSearchDirectoryListingTextbox.Add_MouseHover({
    ToolTipFunction -Title "Directory Listing (WinRM)" -Icon "Info" -Message @"
⦿ Enter a single directory
⦿ Example - C:\Windows\System32`n`n
"@ })
$FileSearchDirectoryListingTextbox.Add_MouseEnter({ if ($FileSearchDirectoryListingTextbox.text -eq "Enter a single directory"){ $FileSearchDirectoryListingTextbox.text = "" } })
$FileSearchDirectoryListingTextbox.Add_MouseLeave({ if ($FileSearchDirectoryListingTextbox.text -eq ""){ $FileSearchDirectoryListingTextbox.text = "Enter a single directory" } })
$Section1FileSearchTab.Controls.Add($FileSearchDirectoryListingTextbox)

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

        if ($ComputerListProvideCredentialsCheckBox.Checked) {
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
}

#---------------------------------------------------
# File Search - File Search Command CheckBox
#---------------------------------------------------
$FileSearchFileSearchCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "File Search (WinRM)"
    Location = @{ X = $FileSearchRightPosition
                  Y = $FileSearchDownPosition }
    Size     = @{ Width  = 230
                  Height = $FileSearchLabelHeight }
    Font     = New-Object System.Drawing.Font("$Font",12,1,2,1)
    ForeColor = 'Blue'
}
$FileSearchFileSearchCheckbox.Add_Click({ 

#Conduct-NodeAction -TreeView $CommandsTreeView.Nodes -Commands 

})
$Section1FileSearchTab.Controls.Add($FileSearchFileSearchCheckbox)

#--------------------------------------------------
# File Search - File Search Max Depth Label
#--------------------------------------------------
$FileSearchFileSearchMaxDepthLabel = New-Object System.Windows.Forms.Label -Property @{
    Text       = "Recursive Depth"
    Location = @{ X = $FileSearchFileSearchCheckbox.Size.Width + 52
                  Y = $FileSearchDownPosition + 3 }
    Size     = @{ Width  = 100
                  Height = $FileSearchLabelHeight }
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
$Section1FileSearchTab.Controls.Add($FileSearchFileSearchMaxDepthTextbox)

$FileSearchDownPosition += $FileSearchDownPositionShift

#----------------------------------------------------
# File Search - File Search Select FileHash ComboBox
#----------------------------------------------------
$FileSearchSelectFileHashCheckbox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text     = "Select FileHashes - Default is None"
    Location = @{ X = $FileSearchRightPosition
                  Y = $FileSearchDownPosition }
    Size     = @{ Width  = 200
                  Height = $FileSearchLabelHeight }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$HashList = @('None', 'MD5','SHA1','SHA256','SHA512','MD5 + SHA1','MD5 + SHA256','MD5 + SHA512','MD5 + SHA1 + SHA256 + SHA512')
ForEach ($Hash in $HashList) { $FileSearchSelectFileHashCheckbox.Items.Add($Hash) }
$Section1FileSearchTab.Controls.Add($FileSearchSelectFileHashCheckbox)

$FileSearchDownPosition += $FileSearchDownPositionShift

#----------------------------------------
# File Search - File Search Label
#----------------------------------------
$FileSearchFileSearchLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = "Collection time depends on the number of files and directories, plus recursive depth."
    Location = @{ X = $FileSearchRightPosition
                  Y = $FileSearchDownPosition }
    Size     = @{ Width  = $FileSearchLabelWidth
                  Height = $FileSearchLabelHeight }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Black"
}
$Section1FileSearchTab.Controls.Add($FileSearchFileSearchLabel)

$FileSearchDownPosition += $FileSearchDownPositionShift - 3

#------------------------------------------------
# File Search - File Search Files Textbox
#------------------------------------------------
$FileSearchFileSearchFileTextbox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $FileSearchRightPosition
                  Y = $FileSearchDownPosition }
    Size     = @{ Width  = 430
                  Height = 80 }
    MultiLine     = $True
    ScrollBars    = "Vertical" #Horizontal
    WordWrap      = $false
    AcceptsTab    = $false    # Allows you to enter in tabs into the textbox
    AcceptsReturn = $false # Allows you to enter in tabs into the textbox
    AllowDrop     = $true
    Text          = "Enter FileNames; One Per Line"
    Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$FileSearchFileSearchFileTextbox.Add_MouseHover({
    ToolTipFunction -Title "File Search (WinRM)" -Icon "Info" -Message @"
⦿ Enter FileNames
⦿ One Per Line
⦿ Filenames don't have to include file extension
⦿ This search will also find the keyword within the filename`n`n
"@ })
$FileSearchFileSearchFileTextbox.Add_MouseEnter({
    if ($FileSearchFileSearchFileTextbox.text -eq "Enter FileNames; One Per Line"){ $FileSearchFileSearchFileTextbox.text = "" }
})
$FileSearchFileSearchFileTextbox.Add_MouseLeave({ 
    if ($FileSearchFileSearchFileTextbox.text -eq ""){ $FileSearchFileSearchFileTextbox.text = "Enter FileNames; One Per Line" }
})
$Section1FileSearchTab.Controls.Add($FileSearchFileSearchFileTextbox)

$FileSearchDownPosition += $FileSearchFileSearchFileTextbox.Size.Height + 5

#---------------------------------------------
# File Search - File Search Directory Textbox
#---------------------------------------------
$FileSearchFileSearchDirectoryTextbox = New-Object System.Windows.Forms.TextBox -Property @{
    Text     = "Enter Directories; One Per Line"
    Location = @{ X = $FileSearchRightPosition
                  Y = $FileSearchDownPosition }
    Size     = @{ Width  = 430
                  Height = 80 }
    MultiLine           = $True
    ScrollBars          = "Vertical"
    WordWrap            = $True
    AcceptsTab          = $false    # Allows you to enter in tabs into the textbox
    AcceptsReturn       = $false # Allows you to enter in tabs into the textbox
    Font                = New-Object System.Drawing.Font("$Font",11,0,0,0)
    #AutoCompleteSource = "FileSystem" # Options are: FileSystem, HistoryList, RecentlyUsedList, AllURL, AllSystemSources, FileSystemDirectories, CustomSource, ListItems, None
    #AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
}
#$FileSearchFileSearchDirectoryTextbox.Add_KeyDown({          })
$FileSearchFileSearchDirectoryTextbox.Add_MouseHover({
    ToolTipFunction -Title "File Search (WinRM)" -Icon "Info" -Message @"
⦿ Enter Directories
⦿ One Per Line`n`n
"@ })
$FileSearchFileSearchDirectoryTextbox.Add_MouseEnter({ if ($FileSearchFileSearchDirectoryTextbox.text -eq "Enter Directories; One Per Line"){ $FileSearchFileSearchDirectoryTextbox.text = "" } })
$FileSearchFileSearchDirectoryTextbox.Add_MouseLeave({ if ($FileSearchFileSearchDirectoryTextbox.text -eq ""){ $FileSearchFileSearchDirectoryTextbox.text = "Enter Directories; One Per Line" } })
$Section1FileSearchTab.Controls.Add($FileSearchFileSearchDirectoryTextbox)

$FileSearchDownPosition += $FileSearchFileSearchDirectoryTextbox.Size.Height + 5
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

        if ($ComputerListProvideCredentialsCheckBox.Checked) {
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
}

#--------------------------------------------------------
# File Search - File Search AlternateDataStream CheckBox
#--------------------------------------------------------
$FileSearchAlternateDataStreamCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Alternate Data Stream Search (WinRM)"
    Location = @{ X = $FileSearchRightPosition
                  Y = $FileSearchDownPosition }
    Size     = @{ Width  = 250
                  Height = $FileSearchLabelHeight }
    Font     = New-Object System.Drawing.Font("$Font",12,1,2,1)
    ForeColor = 'Blue'
}
$FileSearchAlternateDataStreamCheckbox.Add_Click({Conduct-NodeAction -TreeView $CommandsTreeView.Nodes -Commands})
$Section1FileSearchTab.Controls.Add($FileSearchAlternateDataStreamCheckbox)

#-----------------------------------------------------
# File Search - Alternate Data Stream Max Depth Label
#-----------------------------------------------------
$FileSearchAlternateDataStreamMaxDepthLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "Recursive Depth"
    Location = @{ X = $FileSearchFileSearchCheckbox.Size.Width + 52
                  Y = $FileSearchDownPosition + 3 }
    Size     = @{ Width  = 100
                  Height = $FileSearchLabelHeight }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$Section1FileSearchTab.Controls.Add($FileSearchAlternateDataStreamMaxDepthLabel)

#-------------------------------------------------------
# File Search - Alternate Data Stream Max Depth Textbox
#-------------------------------------------------------
$FileSearchAlternateDataStreamMaxDepthTextbox = New-Object System.Windows.Forms.TextBox -Property @{
    Text           = 0
    Location = @{ X = $FileSearchAlternateDataStreamMaxDepthLabel.Location.X + $FileSearchAlternateDataStreamMaxDepthLabel.Size.Width
                  Y = $FileSearchDownPosition }
    Size     = @{ Width  = 50
                  Height = 20 }
    MultiLine      = $false
    #ScrollBars    = "Vertical"
    WordWrap       = $false
    #AcceptsTab    = $false
    #AcceptsReturn = $false    
    Font           = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$Section1FileSearchTab.Controls.Add($FileSearchAlternateDataStreamMaxDepthTextbox)

$FileSearchDownPosition += $FileSearchAlternateDataStreamCheckbox.Size.Height + 5

#-------------------------------------------
# File Search - Alternate Data Stream Label
#-------------------------------------------
$FileSearchAlternateDataStreamLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = "Exlcudes':`$DATA' stream, and will show the ADS name and its contents."
    Location = @{ X = $FileSearchRightPosition
                  Y = $FileSearchDownPosition }
    Size     = @{ Width  = $FileSearchLabelWidth
                  Height = $FileSearchLabelHeight }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Black"
}
$Section1FileSearchTab.Controls.Add($FileSearchAlternateDataStreamLabel)

$FileSearchDownPosition += $FileSearchDownPositionShift

#---------------------------------------------
# File Search - Alternate Data Stream Textbox
#---------------------------------------------
$FileSearchAlternateDataStreamDirectoryTextbox = New-Object System.Windows.Forms.TextBox -Property @{
    Text          = "Enter Directories; One Per Line"
    Location = @{ X = $FileSearchRightPosition
                  Y = $FileSearchDownPosition }
    Size     = @{ Width  = 430
                  Height = 80 }
    Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
    MultiLine     = $True
    ScrollBars    = "Vertical"
    WordWrap      = $True
    AcceptsTab    = $false # Allows you to enter in tabs into the textbox
    AcceptsReturn = $false # Allows you to enter in tabs into the textbox
}
$FileSearchAlternateDataStreamDirectoryTextbox.Add_MouseHover({
    ToolTipFunction -Title "Alternate Data Stream Search (WinRM)" -Icon "Info" -Message @"
⦿ Enter Directories
⦿ One Per Line`n`n
"@ })
$FileSearchAlternateDataStreamDirectoryTextbox.Add_MouseEnter({ if ($FileSearchAlternateDataStreamDirectoryTextbox.text -eq "Enter Directories; One Per Line"){ $FileSearchAlternateDataStreamDirectoryTextbox.text = "" } })
$FileSearchAlternateDataStreamDirectoryTextbox.Add_MouseLeave({ if ($FileSearchAlternateDataStreamDirectoryTextbox.text -eq ""){ $FileSearchAlternateDataStreamDirectoryTextbox.text = "Enter Directories; One Per Line" } })
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
    Text     = "Network Connections"
    Location = @{ X = $NetworkConnectionSearchRightPosition
                  Y = $NetworkConnectionSearchDownPosition }
    Size     = @{ Width  = $NetworkConnectionSearchWidth
                  Height = $NetworkConnectionSearchHeight }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
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

        if ($ComputerListProvideCredentialsCheckBox.Checked) {
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
}

#--------------------------------------------------------
# Network Connections Search - Remote IP Address CheckBox
#--------------------------------------------------------
$NetworkConnectionSearchRemoteIPAddressCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Remote IP Address"
    Location = @{ X = $NetworkConnectionSearchRightPosition
                  Y = $NetworkConnectionSearchDownPosition }
    Size     = @{ Width  = 210
                  Height = $NetworkConnectionSearchLabelHeight }
    Font     = New-Object System.Drawing.Font("$Font",12,1,2,1)
    ForeColor = 'Blue'
}
$NetworkConnectionSearchRemoteIPAddressCheckbox.Add_Click({Conduct-NodeAction -TreeView $CommandsTreeView.Nodes -Commands})
$Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchRemoteIPAddressCheckbox)

$NetworkConnectionSearchDownPosition += $NetworkConnectionSearchDownPositionShift

#-----------------------------------------------------
# Network Connections Search - Remote IP Address Label
#-----------------------------------------------------
$NetworkConnectionSearchRemoteIPAddressLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = "Check hosts for connections to one or more remote IP addresses and/or ports."
    Location = @{ X = $NetworkConnectionSearchRightPosition
                  Y = $NetworkConnectionSearchDownPosition }
    Size     = @{ Width  = 430
                  Height = $NetworkConnectionSearchLabelHeight }
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
                  Y = $NetworkConnectionSearchDownPosition }
    Size     = @{ Width  = 210
                  Height = 120 }
    Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    MultiLine  = $True
    ScrollBars = "Vertical"
    WordWrap   = $True
}
$NetworkConnectionSearchRemoteIPAddressTextbox.Add_MouseHover({
    ToolTipFunction -Title "Remote IP Address (WinRM)" -Icon "Info" -Message @"
⦿ Check hosts for connections to one or more remote IP addresses
⦿ Enter Remote IPs
⦿ One Per Line`n`n
"@ })
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

        if ($ComputerListProvideCredentialsCheckBox.Checked) {
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
}
#--------------------------------------------------------
# Network Connections Search - Remote Port CheckBox
#--------------------------------------------------------
$NetworkConnectionSearchRemotePortCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Remote Port"
    Location = @{ X = $NetworkConnectionSearchRemoteIPAddressCheckbox.Location.X + $NetworkConnectionSearchRemoteIPAddressCheckbox.Size.Width + 10
                  Y = $NetworkConnectionSearchRemoteIPAddressCheckbox.Location.Y }
    Size     = @{ Width  = 100
                  Height = $NetworkConnectionSearchLabelHeight }
    Font     = New-Object System.Drawing.Font("$Font",12,1,2,1)
    ForeColor = 'Blue'
}
$NetworkConnectionSearchRemotePortCheckbox.Add_Click({Conduct-NodeAction -TreeView $CommandsTreeView.Nodes -Commands})
$Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchRemotePortCheckbox)

#------------------------------------------------------------------
# Network Connections Search - Remote Port - Port Selection Button
#------------------------------------------------------------------
if (Test-Path "$ResourcesDirectory\Ports, Protocols, and Services.csv") {
    $NetworkConnectionSearchRemotePortSelectionCheckbox = New-Object System.Windows.Forms.Button -Property @{
        Text      = "Select Ports"
        Location = @{ X = $NetworkConnectionSearchRemotePortCheckbox.Location.X + 113
                      Y = $NetworkConnectionSearchRemotePortCheckbox.Location.Y }
        Size     = @{ Width  = 100
                      Height = 20 }
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = "Black"
    }
    $NetworkConnectionSearchRemotePortSelectionCheckbox.Add_Click({
        Import-Csv "$ResourcesDirectory\Ports, Protocols, and Services.csv" | Out-GridView -Title 'PoSh-ACME: Port Selection' -OutputMode Multiple | Set-Variable -Name PortManualEntrySelectionContents
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
    Text     = "Enter Remote Ports; One Per Line"
    Location = @{ X = $NetworkConnectionSearchRemoteIPAddressTextbox.Location.X + $NetworkConnectionSearchRemoteIPAddressTextbox.Size.Width + 10
                  Y = $NetworkConnectionSearchRemoteIPAddressTextbox.Location.Y }
    Size     = @{ Width  = 210
                  Height = 120 }
    Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    MultiLine  = $True
    ScrollBars = "Vertical"
    WordWrap   = $True
}
$NetworkConnectionSearchRemotePortTextbox.Add_MouseHover({
    ToolTipFunction -Title "Remote Port (WinRM)" -Icon "Info" -Message @"
⦿ Check hosts for connections to one or more remote ports
⦿ Enter Remote Ports
⦿ One Per Line`n`n
"@ })
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

        if ($ComputerListProvideCredentialsCheckBox.Checked) {
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
    Location = @{ X = $NetworkConnectionSearchRightPosition
                  Y = $NetworkConnectionSearchDownPosition }
    Size     = @{ Width  = 430
                  Height = $NetworkConnectionSearchLabelHeight }
    Font     = New-Object System.Drawing.Font("$Font",12,1,2,1)
    ForeColor = 'Blue'
}
$NetworkConnectionSearchProcessCheckbox.Add_Click({Conduct-NodeAction -TreeView $CommandsTreeView.Nodes -Commands})
$Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchProcessCheckbox)

$NetworkConnectionSearchDownPosition += $NetworkConnectionSearchDownPositionShift

#-----------------------------------------------------
# Network Connections Search - Process Label
#-----------------------------------------------------
$NetworkConnectionSearchProcessLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "Check hosts for connections created by a given process."
    Location = @{ X = $NetworkConnectionSearchRightPosition
                  Y = $NetworkConnectionSearchDownPosition }
    Size     = @{ Width  = 430
                  Height = $NetworkConnectionSearchLabelHeight }
    ForeColor = "Black"
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchProcessLabel)

$NetworkConnectionSearchDownPosition += $NetworkConnectionSearchDownPositionShift

#---------------------------------------------
# Network Connections Search -  Process Textbox
#---------------------------------------------
$NetworkConnectionSearchProcessTextbox = New-Object System.Windows.Forms.TextBox -Property @{
    Text          = "Enter Process Names; One Per Line"
    Location = @{ X = $NetworkConnectionSearchRightPosition
                  Y = $NetworkConnectionSearchDownPosition }
    Size     = @{ Width  = 430
                  Height = 120 }
    Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
    MultiLine     = $True
    ScrollBars    = "Vertical"
    WordWrap      = $True
}
#$NetworkConnectionSearchProcessTextbox.Add_KeyDown({          })
$NetworkConnectionSearchProcessTextbox.Add_MouseHover({
    ToolTipFunction -Title "Remote Process Name (WinRM)" -Icon "Info" -Message @"
⦿ Check hosts for connections created by a given process
⦿ This search will also find the keyword within the process name
⦿ Enter Remote Process Names
⦿ One Per Line`n`n
"@ })
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

        if ($ComputerListProvideCredentialsCheckBox.Checked) {
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
}

#--------------------------------------------------------
# Network Connections Search - DNS Cache CheckBox
#--------------------------------------------------------
$NetworkConnectionSearchDNSCacheCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Remote DNS Cache Entry"
    Location = @{ X = $NetworkConnectionSearchRightPosition
                  Y = $NetworkConnectionSearchDownPosition }
    Size     = @{ Width  = 430
                  Height = $NetworkConnectionSearchLabelHeight }
    Font     = New-Object System.Drawing.Font("$Font",12,1,2,1)
    ForeColor = 'Blue'
}
$NetworkConnectionSearchDNSCacheCheckbox.Add_Click({Conduct-NodeAction -TreeView $CommandsTreeView.Nodes -Commands})
$Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchDNSCacheCheckbox)

$NetworkConnectionSearchDownPosition += $NetworkConnectionSearchDownPositionShift

#-----------------------------------------------------
# Network Connections Search - DNS Cache Label
#-----------------------------------------------------
$NetworkConnectionSearchDNSCacheLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = "Check hosts' DNS Cache for entries that match given criteria."
    Location = @{ X = $NetworkConnectionSearchRightPosition
                  Y = $NetworkConnectionSearchDownPosition }
    Size     = @{ Width  = 430
                  Height = $NetworkConnectionSearchLabelHeight }
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
    Location = @{ X = $NetworkConnectionSearchRightPosition
                  Y = $NetworkConnectionSearchDownPosition }
    Size     = @{ Width  = 430
                  Height = 100 }
    Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    MultiLine  = $True
    ScrollBars = "Vertical"
    WordWrap   = $True
}
#$NetworkConnectionSearchDNSCacheTextbox.Add_KeyDown({          })
$NetworkConnectionSearchDNSCacheTextbox.Add_MouseHover({
    ToolTipFunction -Title "Remote DNS Cache Entry (WinRM)" -Icon "Info" -Message @"
⦿ Check hosts' DNS Cache for entries that match given criteria
⦿ The DNS Cache is not persistence on systems
⦿ By default, Windows stores positive responses in the DNS Cache for 86,400 seconds (1 day)
⦿ By default, Windows stores negative responses in the DNS Cache for 300 seconds (5 minutes)
⦿ The default DNS Cache time limits can be changed within the registry
⦿ Enter DNS query information or IP addresses
⦿ One Per Line`n`n
"@ })
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
                  Y = $SysinternalsDownPosition }
    Size     = @{ Width  = $SysinternalsLabelWidth
                  Height = $SysinternalsLabelHeight }
    UseVisualStyleBackColor = $True
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
# Test if the External Programs directory is present; if it's there load the tab
if (Test-Path $ExternalPrograms) { $Section1CollectionsTabControl.Controls.Add($Section1SysinternalsTab) }

$SysinternalsDownPosition += $SysinternalsDownPositionShift

# Sysinternals Tab Label
$SysinternalsTabLabel = New-Object System.Windows.Forms.Label -Property @{
    Location = @{ X = $SysinternalsRightPosition
                  Y = $SysinternalsDownPosition }
    Size     = @{ Width  = $SysinternalsLabelWidth
                  Height = $SysinternalsLabelHeight }
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
                  Y = $SysinternalsDownPosition }
    Size     = @{ Width  = $SysinternalsLabelWidth
                  Height = $SysinternalsLabelHeight }
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
                  Y = $SysinternalsDownPosition + 5 }
    Size     = @{ Width  = $SysinternalsButtonWidth
                  Height = $SysinternalsButtonHeight }
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
                  Y = $SysinternalsDownPosition + 5 }
    Size     = @{ Width  = 75
                  Height = $SysinternalsLabelHeight }
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
    Conduct-NodeAction -TreeView $CommandsTreeView.Nodes -Commands
})
$Section1SysinternalsTab.Controls.Add($SysinternalsSysmonCheckbox)

#---------------------------
# Sysinternals Sysmon Label
#---------------------------
$SysinternalsSysmonConfigLabel = New-Object System.Windows.Forms.Textbox -Property @{
    Text     = "Config:"
    Location = @{ X = 200
                  Y = $SysinternalsSysmonCheckbox.Location.Y + 1 }
    Size     = @{ Width  = 225
                  Height = $SysinternalsLabelHeight }    
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Black"
    Enabled   = $false
}
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
                  Y = $SysinternalsDownPosition }
    Size     = @{ Width  = $SysinternalsLabelWidth
                  Height = $SysinternalsLabelHeight }
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
                  Y = $SysinternalsDownPosition + 5 }
    Size     = @{ Width  = $SysinternalsButtonWidth
                  Height = $SysinternalsButtonHeight }
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
                  Y = $SysinternalsDownPosition + 5 }
    Size     = @{ Width  = $SysinternalsLabelWidth - 130
                  Height = $SysinternalsLabelHeight }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$SysinternalsAutorunsCheckbox.Add_Click({Conduct-NodeAction -TreeView $CommandsTreeView.Nodes -Commands})
$Section1SysinternalsTab.Controls.Add($SysinternalsAutorunsCheckbox)

$SysinternalsDownPosition += $SysinternalsDownPositionShift
$SysinternalsDownPosition += $SysinternalsDownPositionShift

#============================================================================================================================================================
# Sysinternals Process Monitor
#============================================================================================================================================================

#------------------------------
# Sysinternals - ProcMon Label
#------------------------------
$SysinternalsProcessMonitorLabel = New-Object System.Windows.Forms.Label -Property @{
    Location = @{ X = $SysinternalsRightPosition
                  Y = $SysinternalsDownPosition }
    Size     = @{ Width  = $SysinternalsLabelWidth - 5
                  Height = $SysinternalsLabelHeight }
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
                  Y = $SysinternalsDownPosition + 5 }
    Size     = @{ Width  = $SysinternalsButtonWidth
                  Height = $SysinternalsButtonHeight }
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
                  Y = $SysinternalsDownPosition + 5 }
    Size     = @{ Width  = $SysinternalsLabelWidth - 330
                  Height = $SysinternalsLabelHeight }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$SysinternalsProcessMonitorCheckbox.Add_Click({Conduct-NodeAction -TreeView $CommandsTreeView.Nodes -Commands})
$Section1SysinternalsTab.Controls.Add($SysinternalsProcessMonitorCheckbox)

#---------------------------------
# Procmon - Capture Time ComboBox
#---------------------------------
$SysinternalsProcessMonitorTimeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text     = "5 Seconds"
    Location = @{ X = $SysinternalsRightPosition + $SysinternalsButtonWidth + 150
                  Y = $SysinternalsDownPosition + 6 }
    Size     = @{ Width  = 160
                  Height = $SysinternalsLabelHeight } 
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$ProcmonCaptureTimes = @('5 Seconds','10 Seconds','15 Seconds','30 Seconds','1 Minute','2 Minutes','3 Minutes','4 Minutes','5 Minutes')
    ForEach ($time in $ProcmonCaptureTimes) { $SysinternalsProcessMonitorTimeComboBox.Items.Add($time) }
$Section1SysinternalsTab.Controls.Add($SysinternalsProcessMonitorTimeComboBox)

$SysinternalsDownPosition += $SysinternalsDownPositionShift
$SysinternalsDownPosition += $SysinternalsDownPositionShift

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
    Name     = "Enumeration"
    Text     = "Enumeration"
    Location = @{ X = $EnumerationRightPosition
                  Y = $EnumerationDownPosition }
    Size     = @{ Width  = $EnumerationLabelWidth
                  Height = $EnumerationLabelHeight }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    UseVisualStyleBackColor = $True
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
    Location  = New-Object System.Drawing.Point(0,$EnumerationDownPosition)
    size      = New-Object System.Drawing.Size(294,100)
    text      = "Import Hosts From Domain"
    Font      = New-Object System.Drawing.Font("$Font",12,1,2,1)
    ForeColor = "Blue"
}
$EnumerationDomainGenerateDownPosition      = 18
$EnumerationDomainGenerateDownPositionShift = 25

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
    $EnumerationDomainGeneratedAutoCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
        Text      = "Auto Pull"
        Location  = New-Object System.Drawing.Point(($EnumerationDomainGeneratedLabelNote.Size.Width + 3),($EnumerationDomainGenerateDownPosition - 1))
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
        Location  = New-Object System.Drawing.Point($EnumerationRightPosition,$EnumerationDomainGenerateDownPosition)
        Size      = New-Object System.Drawing.Size(286,$EnumerationLabelHeight)
        Font      = New-Object System.Drawing.Font("$Font",10,0,0,0)
        ForeColor = "Black"
    }
    $EnumerationDomainGeneratedTextBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { EnumerationDomainGeneratedInputCheck } })
    $EnumerationDomainGenerateGroupBox.Controls.Add($EnumerationDomainGeneratedTextBox)

    $EnumerationDomainGenerateDownPosition += $EnumerationDomainGenerateDownPositionShift

    #----------------------------------------------------------
    # Enumeration - Domain Generated - Import Hosts/IPs Button
    #----------------------------------------------------------
    $EnumerationDomainGeneratedListButton = New-Object System.Windows.Forms.Button -Property @{
        Text      = "Import Hosts"
        Location  = New-Object System.Drawing.Point(190,($EnumerationDomainGenerateDownPosition - 1))
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
    elseif ($EnumerationPortScanPortQuickPickComboBox.SelectedItem -eq "") { $PortsToScan += $null }

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
        $ProgressBarEndpointsLabel.Maximum = $PortsToScan.count
        $ProgressBarEndpointsLabel.Value   = 0

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
            $ProgressBarEndpointsLabel.Value += 1
        }
        if ($NetworkPortScanIPResponded -ne "") { $EnumerationComputerListBox.Items.Add("$NetworkPortScanIPResponded") }
        $NetworkPortScanResultsIPList = @() # To Clear out the Variable        
    }
    # Sets the intial progress bar values
    $ProgressBarQueriesProgressBar.Maximum = $IPsToScan.count
    $ProgressBarQueriesProgressBar.Value   = 0

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
        $ProgressBarQueriesProgressBar.Value += 1
    }
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Port Scan Completed - Results Are Saved In The Log File")
    $ResultsListBox.Items.Insert(0,"$(Get-Date)  ==================== Port Scan Complete ====================")
}
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
        if ($EnumerationPortScanPortQuickPickComboBox.SelectedItem -match "N/A") { $ResultsListBox.Items.Add("") }        
        elseif ($EnumerationPortScanPortQuickPickComboBox.SelectedItem -match "Nmap Top 100 Ports") { $ResultsListBox.Items.Add("Will conduct a connect scan the top 100 ports as reported by nmap on each target.") }
        elseif ($EnumerationPortScanPortQuickPickComboBox.SelectedItem -match "Nmap Top 1000 Ports") { $ResultsListBox.Items.Add("Will conduct a connect scan the top 1000 ports as reported by nmap on each target.") }        
        elseif ($EnumerationPortScanPortQuickPickComboBox.SelectedItem -match "Well-Known Ports") { $ResultsListBox.Items.Add("Will conduct a connect scan all Well-Known Ports on each target [0-1023].") }        
        elseif ($EnumerationPortScanPortQuickPickComboBox.SelectedItem -match "Registered Ports") { $ResultsListBox.Items.Add("Will conduct a connect scan all Registered Ports on each target [1024-49151].") }        
        elseif ($EnumerationPortScanPortQuickPickComboBox.SelectedItem -match "Dynamic Ports") { $ResultsListBox.Items.Add("Will conduct a connect scan all Dynamic Ports, AKA Ephemeral Ports, on each target [49152-65535].") }
        elseif ($EnumerationPortScanPortQuickPickComboBox.SelectedItem -match "All Ports") { $ResultsListBox.Items.Add("Will conduct a connect scan all 65535 ports on each target.") }        
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
            Import-Csv "$ResourcesDirectory\Ports, Protocols, and Services.csv" | Out-GridView -Title 'PoSh-ACME: Port Selection' -OutputMode Multiple | Set-Variable -Name PortManualEntrySelectionContents
            $PortsColumn = $PortManualEntrySelectionContents | Select-Object -ExpandProperty "Port"
            $PortsToBeScan = ""
            Foreach ($Port in $PortsColumn) { $PortsToBeScan += "$Port," }       
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
    $ProgressBarEndpointsLabel.Maximum = 1
    $ProgressBarEndpointsLabel.Value   = 0
    $ProgressBarQueriesProgressBar.Maximum = $PingList.count
    $ProgressBarQueriesProgressBar.Value   = 0

    foreach ($Computer in $PingList) {
        $ping = Test-Connection $Computer -Count 1
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Pinging: $Computer")
        $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $ping"
        $LogMessage | Add-Content -Path $LogFile
        if($ping){$EnumerationComputerListBox.Items.Insert(0,"$Computer")}
        $ProgressBarQueriesProgressBar.Value += 1
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
    $EnumerationPingSweepIPNetworkCIDRTextbox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { Conduct-PingSweep } })
    $EnumerationPingSweepGroupBox.Controls.Add($EnumerationPingSweepIPNetworkCIDRTextbox)

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
    $EnumerationPingSweepExecutionButton.Add_Click({ Conduct-PingSweep })
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
            Message-HostAlreadyExists -Message "Port Scan Import:  Warning"
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
    $script:ComputerListTreeView.ExpandAll()
    Populate-ComputerListTreeViewDefaultData
    AutoSave-HostData
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
            Location = @{ X = $ChecklistRightPosition
                          Y = $ChecklistDownPosition }
            Size     = @{ Width  = $ChecklistBoxWidth
                          Height = $ChecklistBoxHeight }
            Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        }
        if ($Checklist.Check -eq $True) { $Checklist.ForeColor = "Blue" }
        $Section1ChecklistSubTab.Controls.Add($Checklist)          

        $ChecklistDownPosition += $ChecklistDownPositionShift
    }
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
    Name     = "Processes TabControl"
    Location = @{ X = $TabRightPosition
                  Y = $TabhDownPosition }
    Size     = @{ Width  = $TabAreaWidth
                  Height = $TabAreaHeight }
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
        Location = @{ X = $TextBoxRightPosition
                      Y = $TextBoxDownPosition }
        Size     = @{ Width  = $TextBoxWidth
                      Height = $TextBoxHeight }
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
    
    $OpNotesInputTextBox.Text = ""
}

############################################################################################################
# Section 1 OpNotes SubTab
############################################################################################################

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
$OpNotesInputTextBox          = New-Object System.Windows.Forms.TextBox -Property @{
    Location = New-Object System.Drawing.Point($OpNotesRightPosition,$OpNotesDownPosition)
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
    Location  = New-Object System.Drawing.Point($OpNotesRightPosition,$OpNotesDownPosition)
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
    Location = New-Object System.Drawing.Point($OpNotesRightPosition,$OpNotesDownPosition)
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
$OpNotesOpenListBox = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Open OpNotes"
    Location = @{ X = $OpNotesRightPosition
                  Y = $OpNotesDownPosition }
    Size     = @{ Width  = $OpNotesButtonWidth
                  Height = $OpNotesButtonHeight }
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
                  Y = $OpNotesDownPosition }
    Size     = @{ Width  = $OpNotesButtonWidth
                  Height = $OpNotesButtonHeight }
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
$OpNotesRightPosition = $OpNotesRightPositionStart

#----------------------------------
# OpNotes - Remove Selected Button
#----------------------------------
$OpNotesRemoveButton = New-Object System.Windows.Forms.Button -Property @{
    Location = New-Object System.Drawing.Point($OpNotesRightPosition,$OpNotesDownPosition)
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
    Location = New-Object System.Drawing.Point($OpNotesRightPosition,$OpNotesDownPosition)
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
    Location = New-Object System.Drawing.Point($OpNotesRightPosition,$OpNotesDownPosition)
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
    Location = New-Object System.Drawing.Point($OpNotesRightPosition,$OpNotesDownPosition)
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
        foreach ($note in $OpNotesToMove) { $OpNotesListBox.items.insert($SelectedItemPositions[0] +1,$note) 
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
    Location            = New-Object System.Drawing.Point($OpNotesRightPositionStart,($OpNotesDownPosition + 5)) 
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
    foreach ($OpNotesEntry in $OpNotesFileContents){ $OpNotesListBox.Items.Add("$OpNotesEntry") }
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
    Location      = New-Object System.Drawing.Point($TabRightPosition,$TabhDownPosition)
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
        Location   = New-Object System.Drawing.Point($TextBoxRightPosition,$TextBoxDownPosition) 
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
$Section2TabControl.Location      = New-Object System.Drawing.Point($Section2TabControlRightPosition,$Section2TabControlDownPosition) 
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
# This checkbox highlights when selecting computers from the ComputerList
$script:SingleHostIPCheckBox          = New-Object System.Windows.Forms.Checkbox
$script:SingleHostIPCheckBox.Name     = "Query A Single Host:"
$script:SingleHostIPCheckBox.Text     = "Query A Single Host:"
$script:SingleHostIPCheckBox.Location = New-Object System.Drawing.Point(3,11) 
$script:SingleHostIPCheckBox.Size     = New-Object System.Drawing.Size(210,$Column3BoxHeight)
$script:SingleHostIPCheckBox.Font     = New-Object System.Drawing.Font("$Font",11,1,2,1)
$script:SingleHostIPCheckBox.Enabled  = $true
$script:SingleHostIPCheckBox.Add_Click({
    if ($script:SingleHostIPCheckBox.Checked -eq $true){
        $script:SingleHostIPTextBox.Text       = ""
        $script:ComputerListTreeView.Enabled   = $false
        $script:ComputerListTreeView.BackColor = "lightgray"
    }
    elseif ($script:SingleHostIPCheckBox.Checked -eq $false) {
        $script:SingleHostIPTextBox.Text = $DefaultSingleHostIPText
        $script:ComputerListTreeView.Enabled    = $true
        $script:ComputerListTreeView.BackColor  = "white"
    }
})
$script:SingleHostIPCheckBox.Add_MouseHover({
    ToolTipFunction -Title "Query A Single Host" -Icon "Info" -Message @"
⦿ Queries a single host provided in the input field,
    disabling the computer treeview list.
⦿ Enter a valid hostname or IP address to collect data from. 
⦿ Depending upon host or domain configurations, some queries 
    such as WinRM against valid IPs may not yield results.`n`n
"@ })
$Section2MainTab.Controls.Add($script:SingleHostIPCheckBox)

$Column3DownPosition += $Column3DownPositionShift

#-----------------------------
# Single Host - Input Textbox
#-----------------------------
$script:SingleHostIPTextBox          = New-Object System.Windows.Forms.TextBox
$script:SingleHostIPTextBox.Text     = $DefaultSingleHostIPText
$script:SingleHostIPTextBox.Location = New-Object System.Drawing.Point($Column3RightPosition,($Column3DownPosition + 1))
$script:SingleHostIPTextBox.Size     = New-Object System.Drawing.Size(235,$Column3BoxHeight)
$script:SingleHostIPTextBox.Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
$script:SingleHostIPTextBox.Add_KeyDown({
    $script:SingleHostIPCheckBox.Checked   = $true
    $script:ComputerListTreeView.Enabled   = $false
    $script:ComputerListTreeView.BackColor = "lightgray"
})
$script:SingleHostIPTextBox.Add_MouseEnter({
    if ($script:SingleHostIPTextBox.text -eq "$DefaultSingleHostIPText"){ $script:SingleHostIPTextBox.text = "" }
})
$script:SingleHostIPTextBox.Add_MouseLeave({ 
    if ($script:SingleHostIPTextBox.text -eq ""){ $script:SingleHostIPTextBox.text = "$DefaultSingleHostIPText" }
})
$script:SingleHostIPTextBox.Add_MouseHover({
    ToolTipFunction -Title "Single Host Input Field" -Icon "Info" -Message @"
⦿ Queries a single host provided in the input field,
    disabling the computer treeview list.
⦿ Enter a valid hostname or IP address to collect data from. 
⦿ Depending upon host or domain configurations, some queries 
    such as WinRM against valid IPs may not yield results.`n`n
"@ })
$Section2MainTab.Controls.Add($script:SingleHostIPTextBox)

#----------------------------------
# Single Host - Add To List Button
#----------------------------------
$SingleHostIPAddButton          = New-Object System.Windows.Forms.Button
$SingleHostIPAddButton.Text     = "Add To List"
$SingleHostIPAddButton.Location = New-Object System.Drawing.Point(($Column3RightPosition + 240),$Column3DownPosition)
$SingleHostIPAddButton.Size     = New-Object System.Drawing.Size(115,$Column3BoxHeight) 
$SingleHostIPAddButton.Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
$SingleHostIPAddButton.Add_Click({
    # Conducts a simple input check for default or blank data
    if (($script:SingleHostIPTextBox.Text -ne $DefaultSingleHostIPText) -and ($script:SingleHostIPTextBox.Text -ne '')) {
        if ($script:ComputerListTreeViewData.Name -contains $script:SingleHostIPTextBox.Text) {
            Message-HostAlreadyExists -Message "Add Hostname/IP:  Error"
        }
        else {
            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("Added Selection:  $($script:SingleHostIPTextBox.Text)")

            $NewNodeValue = "Manually Added"
            # Adds the hostname/ip entered into the collection list box
            Add-ComputerNode -RootNode $script:TreeNodeComputerList -Category $NewNodeValue -Entry $script:SingleHostIPTextBox.Text -ToolTip 'No Data Avialable'
            $ResultsListBox.Items.Clear()
            $ResultsListBox.Items.Add("$($script:SingleHostIPTextBox.Text) has been added to $($NewNodeValue)")

            $ComputerListTreeViewAddHostnameIP = New-Object PSObject -Property @{ 
                Name            = $script:SingleHostIPTextBox.Text
                OperatingSystem = $NewNodeValue
                CanonicalName   = $NewNodeValue
                IPv4Address     = "No IP Available"
            }        
            $script:ComputerListTreeViewData += $ComputerListTreeViewAddHostnameIP

            $script:ComputerListTreeView.ExpandAll()
            # Enables the Computer TreeView
            $script:ComputerListTreeView.Enabled   = $true
            $script:ComputerListTreeView.BackColor = "white"
            # Clears Textbox
            $script:SingleHostIPTextBox.Text = $DefaultSingleHostIPText
            # Auto checks/unchecks various checkboxes for visual status indicators
            $script:SingleHostIPCheckBox.Checked = $false

            Populate-ComputerListTreeViewDefaultData
            AutoSave-HostData
        }
    }
})
$SingleHostIPAddButton.Add_MouseHover({
    ToolTipFunction -Title "Query A Single Host" -Icon "Info" -Message @"
⦿ Adds a single host to the computer treeview.
⦿ The host is added under`n`n
"@ })
$Section2MainTab.Controls.Add($SingleHostIPAddButton) 

$Column3DownPosition += $Column3DownPositionShift
$Column3DownPosition += $Column3DownPositionShift
$Column3DownPosition += $Column3DownPositionShift - 3

#-------------------------------------------
# Directory Location - Results Folder Label
#-------------------------------------------
$DirectoryListLabel           = New-Object System.Windows.Forms.Label
$DirectoryListLabel.Location  = New-Object System.Drawing.Point($Column3RightPosition,($Column3DownPosition + 2)) 
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
$DirectoryOpenListBox.Location = New-Object System.Drawing.Point(($Column3RightPosition + 120),$Column3DownPosition)
$DirectoryOpenListBox.Size     = New-Object System.Drawing.Size(115,$Column3BoxHeight) 
$DirectoryOpenListBox.Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
$DirectoryOpenListBox.Add_Click({ Invoke-Item -Path $CollectedDataDirectory })
$DirectoryOpenListBox.Add_MouseHover({
    ToolTipFunction -Title "Open Results" -Icon "Info" -Message @"
⦿ Opens the directory where the collected data is saved.
⦿ The 'Collected Data' parent directory is opened by default. 
⦿ After collecting data, the directory opened is changed to that
    of where the data is saved - normally the timestamp folder.
⦿ From here, you can easily navigate the rest of the directory.`n`n
"@ })
$Section2MainTab.Controls.Add($DirectoryOpenListBox)

#-------------------------------------------
# Directory Location - New Timestamp Button
#-------------------------------------------
$DirectoryUpdateListBox              = New-Object System.Windows.Forms.Button
$DirectoryUpdateListBox.Text         = "New Timestamp"
$DirectoryUpdateListBox.Location     = New-Object System.Drawing.Point(($Column3RightPosition + 240),$Column3DownPosition)
$DirectoryUpdateListBox.Size         = New-Object System.Drawing.Size(115,$Column3BoxHeight) 
$DirectoryUpdateListBox.Font         = New-Object System.Drawing.Font("$Font",11,0,0,0)
$DirectoryUpdateListBox.Add_Click({
    $CollectedDataTimeStampDirectory = "$CollectedDataDirectory\$((Get-Date).ToString('yyyy-MM-dd @ HHmm ss'))"
    $CollectionSavedDirectoryTextBox.Text  = $CollectedDataTimeStampDirectory
})
$DirectoryUpdateListBox.Add_MouseHover({
    ToolTipFunction -Title "New Timestamp" -Icon "Info" -Message @"
⦿ Provides a new timestamp name for the directory files are saved.
⦿ The timestamp is automatically renewed upon launch of PoSh-ACME.
⦿ Collections are saved to a 'Collected Data' directory that is created
    automatically where the PoSh-ACME script is executed from.
⦿ The directory's timestamp does not auto-renew after data is collected, 
    you have to manually do so. This allows you to easily run multiple
    collections and keep this co-located.
⦿ The full directory path may also be manually modified to contain any
    number or characters that are permitted within NTFS. This allows
    data to be saved to uniquely named or previous directories created.`n`n
"@ })
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
$CollectionSavedDirectoryTextBox.Location      = New-Object System.Drawing.Point($Column3RightPosition,$Column3DownPosition) 
$CollectionSavedDirectoryTextBox.Size          = New-Object System.Drawing.Size(354,35)
$CollectionSavedDirectoryTextBox.Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
$CollectionSavedDirectoryTextBox.Add_MouseHover({
    ToolTipFunction -Title "Results Folder" -Icon "Info" -Message @"
⦿ This path supports auto-directory completion.
⦿ Collections are saved to a 'Collected Data' directory that is created
    automatically where the PoSh-ACME script is executed from.
⦿ The directory's timestamp does not auto-renew after data is collected, 
    you have to manually do so. This allows you to easily run multiple
    collections and keep this co-located.
⦿ The full directory path may also be manually modified to contain any
    number or characters that are permitted within NTFS. This allows
    data to be saved to uniquely named or previous directories created.`n`n
"@ })
$Section2MainTab.Controls.Add($CollectionSavedDirectoryTextBox)

#============================================================================================================================================================
# Results Section
#============================================================================================================================================================

#-------------------------------------------
# Directory Location - Results Folder Label
#-------------------------------------------
$ResultsSectionLabel           = New-Object System.Windows.Forms.Label
$ResultsSectionLabel.Location  = New-Object System.Drawing.Point(2,200) 
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
$OpenResultsButton.Location = New-Object System.Drawing.Point(2,($ResultsSectionLabel.Location.Y + $ResultsSectionLabel.Size.Height + 5))
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
    ToolTipFunction -Title "View Results" -Icon "Info" -Message @"
⦿ Utilizes Out-GridView to view the results.
⦿ Out-GridView is native to PowerShell, lightweight, and fast.
⦿ Results can be easily filtered with conditional statements.
⦿ Collected data from is primarily saved as CSVs, so they can 
    be opened with Excel or similar products.
⦿ Multiple lines can be selected and added to OpNotes.
    The selection can be contiguous by using the Shift key
    and/or be separate using the Ctrl key, the press OK.`n`n
"@ })
$Section2MainTab.Controls.Add($OpenResultsButton)

$Column5DownPosition += $Column5DownPositionShift


# The script:Invoke-SaveChartAsImage function is use by 'build charts and autocharts'
Function script:Invoke-SaveChartAsImage {
    #$FileTypes = [enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')| ForEach { $_.Insert(0,'*.') }
    $SaveFileDlg = New-Object System.Windows.Forms.SaveFileDialog
    $SaveFileDlg.DefaultExt='JPG'
    #$SaveFileDlg.Filter = "Image Files ($($FileTypes)) | All Files (*.*)|*.*"
    $SaveFileDlg.filter = "JPEG (*.jpeg)|*.jpeg|PNG (*.png)|*.png|BMP (*.bmp)|*.bmp|GIF (*.gif)|*.gif|TIFF (*.tiff)|*.tiff|All files (*.*)|*.*"
    $return = $SaveFileDlg.ShowDialog()
    If ($Return -eq 'OK') {
        [pscustomobject]@{
            FileName  = $SaveFileDlg.FileName
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
$BuildChartButton.Name     = "Build Charts"
$BuildChartButton.Text     = "$($BuildChartButton.Name)"
$BuildChartButton.UseVisualStyleBackColor = $True
$BuildChartButton.Location = New-Object System.Drawing.Point(($OpenResultsButton.Location.X + $OpenResultsButton.Size.Width + 5),$OpenResultsButton.Location.Y)
$BuildChartButton.Size     = New-Object System.Drawing.Size(115,22)
$BuildChartButton.Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
$BuildChartButton.Add_Click({
    . $ChartsUserCreated
}) 
$BuildChartButton.Add_MouseHover({
    ToolTipFunction -Title "Build Chart" -Icon "Info" -Message @"
⦿ Utilizes PowerShell (v3) charts to visualize data.
⦿ These charts are built manually from selecting a CSV file and fields.
⦿ Use caution, manually recreated charts can be built that either don't
    work, don't make sensse, or don't accurately represent data.`n`n
"@ })
$Section2MainTab.Controls.Add($BuildChartButton)


#--------------------------------
# Auto Create Multi-Series Chart
#--------------------------------
if (Test-Path -Path "$PoShHome\Dependencies\Charts - MultiSeries.ps1") {
    # Loads File
    . "$PoShHome\Dependencies\Charts - MultiSeries.ps1"

    $AutoCreateMultiSeriesChartButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Multi-Series Charts"
        Location = @{ X = $BuildChartButton.Location.X + $BuildChartButton.Size.Width + 5
                      Y = $BuildChartButton.Location.Y }
        Size     = @{ Width  = 115
                      Height = 22 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        UseVisualStyleBackColor = $True
    }
    $AutoCreateMultiSeriesChartButton.Add_Click({ AutoChartsMultiSeriesCharts })
    $AutoCreateMultiSeriesChartButton.Add_MouseHover({
        ToolTipFunction -Title "Multi-Series Chart" -Icon "Info" -Message @"
⦿ Utilizes PowerShell (v3) charts to visualize data.
⦿ These charts are auto created from pre-selected CSV files and fields.
⦿ Multi-series charts are generated from CSV files of similar queries
    for analysis (baseline, previous, and most recents).
⦿ Multi-series charts will only display results from hosts that are
    found in each series; non-common hosts result will be hidden.
⦿ Charts can be filtered for data collected via WMI or PoSh commands.
⦿ Charts can be modified and an image can be saved.`n`n
"@ })
    $Section2MainTab.Controls.Add($AutoCreateMultiSeriesChartButton)
}


#-------------------------------------
# Auto Create Dashboard Charts Button
#-------------------------------------
if (Test-Path -Path "$PoShHome\Dependencies\Charts - Dashboard.ps1") {
    # Loads File
    . "$PoShHome\Dependencies\Charts - Dashboard.ps1"

    $AutoCreateDashboardChartButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Dashboard Charts"
        Location = @{ X = $AutoCreateMultiSeriesChartButton.Location.X
                      Y = $AutoCreateMultiSeriesChartButton.Location.Y - $AutoCreateMultiSeriesChartButton.Size.Height - 5 }
        Size     = @{ Width = 115
                      Height = 22 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        UseVisualStyleBackColor = $True
    }
    $AutoCreateDashboardChartButton.Add_Click({ AutoChartsDashboardCharts })
    $AutoCreateDashboardChartButton.Add_MouseHover({
        ToolTipFunction -Title "Dashboard Charts" -Icon "Info" -Message @"
⦿ Utilizes PowerShell (v3) charts to visualize data.
⦿ These charts are auto created from pre-selected CSV files and fields.
⦿ The dashboard consists of multiple charts from the same CSV file and 
    are designed for easy analysis of data to identify outliers.
⦿ Each chart can be modified and an image can be saved.`n`n
"@ })
    $Section2MainTab.Controls.Add($AutoCreateDashboardChartButton)
}


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
                  Y = 11 }
    Size     = @{ Width  = 50
                  Height = 22 }
    Font     = New-Object System.Drawing.Font("$Font",9,0,3,0)
    AutoCompleteMode = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
}
$JobTimesAvailable = @(15,30,45,60,120,180,240,300,600)
ForEach ($Item in $JobTimesAvailable) { $OptionJobTimeoutSelectionComboBox.Items.Add($Item) }
$OptionJobTimeoutSelectionComboBox.Add_MouseHover({
    ToolTipFunction -Title "Sets the Background Job Timeout" -Icon "Info" -Message @"
⦿ Queries are threaded and not executed serially like typical scripts.
⦿ This is done in command order for each host checked.`n`n
"@ })
$OptionJobTimeoutSelectionComboBox.Text = $JobTimeOutSeconds
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
$OptionStatisticsUpdateIntervalCombobox = New-Object System.Windows.Forms.Combobox -Property @{
    Text     = 5
    Location = @{ X = 3
                  Y = $OptionJobTimeoutSelectionComboBox.Location.Y + $OptionJobTimeoutSelectionComboBox.Size.Height + 5 }
    Size     = @{ Width  = 50
                  Height = 22 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$StatisticsTimesAvailable = @(1,5,10,15,30,45,60)
ForEach ($Item in $StatisticsTimesAvailable) { $OptionStatisticsUpdateIntervalCombobox.Items.Add($Item) }
$OptionStatisticsUpdateIntervalCombobox.Add_MouseHover({
    ToolTipFunction -Title "Statistics Update Interval" -Icon "Info" -Message @"
⦿ How often the Statistics Tab updates when collecting data.
⦿ The value entered is in seconds.
⦿ Collecting statistics requires some additional processing time,
     so the longer the time the less execution time overhead.
⦿ Do not set the value to zero '0'.`n`n
"@
})
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
    $CollectedDataDirectorySearchLimitCombobox = New-Object System.Windows.Forms.Combobox -Property @{
        Text     = 50
        Location = @{ X = 10
                      Y = 15 }
        Size     = @{ Width  = 50
                      Height = 22 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $NumberOfDirectoriesToSearchBack = @(25,50,100,150,200,250,500,750,1000)
    ForEach ($Item in $NumberOfDirectoriesToSearchBack) { $CollectedDataDirectorySearchLimitCombobox.Items.Add($Item) }
    $CollectedDataDirectorySearchLimitCombobox.Add_MouseHover({
        ToolTipFunction -Title "Statistics Update Interval" -Icon "Info" -Message @"
    ⦿ This is how many directories to search for data within the Collected Data directory.
    ⦿ It allows you to search for specified data within previous data collections.
    ⦿ The more directories you search, the longer the wait time.`n`n
"@
    })
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
                      Y = $OptionSearchServicesCheckBox.Location.Y + $OptionSearchServicesCheckBox.Size.Height + 0 }
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
$OptionGUITopWindowCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
    Text     = "GUI always on top"
    Location = @{ X = 3
                  Y = $OptionSearchComputersForPreviouslyCollectedDataProcessesCheckBox.Location.Y + $OptionSearchComputersForPreviouslyCollectedDataProcessesCheckBox.Size.Height + 2 }
    Size     = @{ Width  = 300
                  Height = $Column3BoxHeight }
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
                  Y = $OptionGUITopWindowCheckBox.Location.Y + $OptionGUITopWindowCheckBox.Size.Height + 0 }
    Size     = @{ Width  = 300
                  Height = $Column3BoxHeight }
    Enabled  = $true
    Checked  = $true
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
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
#Cmdlet Parameter Option
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

    $StatisticsResults += "$('{0,-25}{1}' -f "Number of CSV files:", $($StatisticsAllCSVFilesMeasured.Count))`r`n"

    $StatisticsFirstCollection = $($StatisticsAllCSVFiles | Sort-Object -Property CreationTime | Select-Object -First 1).CreationTime
    $StatisticsResults += "$('{0,-25}{1}' -f "First query datetime:", $StatisticsFirstCollection)`r`n"

    $StatisticsLatestCollection = $($StatisticsAllCSVFiles | Sort-Object -Property CreationTime | Select-Object -Last 1).CreationTime
    $StatisticsResults += "$('{0,-25}{1}' -f "Latest query datetime:", $StatisticsLatestCollection)`r`n"
    
    $StatisticsAllCSVFilesSum = $(
        $CSVBytes = $StatisticsAllCSVFilesMeasured.Sum
        if ($CSVBytes -gt 1GB) {"{0:N3} GB" -f $($CSVBytes / 1GB)}
        elseif ($CSVBytes -gt 1MB) {"{0:N3} MB" -f $($CSVBytes / 1MB)}
        elseif ($CSVBytes -gt 1KB) {"{0:N3} KB" -f $($CSVBytes / 1KB)}
        else {"{0:N3} Bytes" -f $CSVBytes}    
    )
    $StatisticsResults += "$('{0,-25}{1}' -f "Total CSV Data:", $StatisticsAllCSVFilesSum)`r`n"

    $StatisticsAllCSVFilesAverage = $(
        $CSVBytes = $StatisticsAllCSVFilesMeasured.Average
        if ($CSVBytes -gt 1GB) {"{0:N3} GB" -f $($CSVBytes / 1GB)}
        elseif ($CSVBytes -gt 1MB) {"{0:N3} MB" -f $($CSVBytes / 1MB)}
        elseif ($CSVBytes -gt 1KB) {"{0:N3} KB" -f $($CSVBytes / 1KB)}
        else {"{0:N3} Bytes" -f $CSVBytes}    
    )
    $StatisticsResults += "$('{0,-25}{1}' -f "Average CSV filesize:", $StatisticsAllCSVFilesAverage)`r`n"

    $StatisticsAllCSVFilesMaximum = $(
        $CSVBytes = $StatisticsAllCSVFilesMeasured.Maximum
        if ($CSVBytes -gt 1GB) {"{0:N3} GB" -f $($CSVBytes / 1GB)}
        elseif ($CSVBytes -gt 1MB) {"{0:N3} MB" -f $($CSVBytes / 1MB)}
        elseif ($CSVBytes -gt 1KB) {"{0:N3} KB" -f $($CSVBytes / 1KB)}
        else {"{0:N3} Bytes" -f $CSVBytes}    
    )
    $StatisticsResults += "$('{0,-25}{1}' -f "Largest CSV filesize:", $StatisticsAllCSVFilesMaximum)`r`n"

    $StatisticsAllCSVFilesMinimum = $(
        $CSVBytes = $StatisticsAllCSVFilesMeasured.Minimum
        if ($CSVBytes -gt 1GB) {"{0:N3} GB" -f $($CSVBytes / 1GB)}
        elseif ($CSVBytes -gt 1MB) {"{0:N3} MB" -f $($CSVBytes / 1MB)}
        elseif ($CSVBytes -gt 1KB) {"{0:N3} KB" -f $($CSVBytes / 1KB)}
        else {"{0:N3} Bytes" -f $CSVBytes}    
    )
    $StatisticsResults += "$('{0,-25}{1}' -f "Smallest CSV filesize:", $StatisticsAllCSVFilesMinimum)`r`n"

    $StatisticsResults += "`r`n"
    $StatisticsLogFile = Get-ItemProperty -Path $Logfile

    $NumberOfLogEntries = (get-content -path $logfile | Select-String -Pattern '\d{4}/\d{2}/\d{2} \d{2}[:]\d{2}[:]\d{2} [-] ').count
    $StatisticsResults += "$('{0,-25}{1}' -f "Number of Log Entries:", $NumberOfLogEntries)`r`n"

    $StatisticsLogFileSize = $(
        $LogFileSize = $StatisticsLogFile.Length
        if ($LogFileSize -gt 1GB) {"{0:N3} GB" -f $($LogFileSize / 1GB)}
        elseif ($LogFileSize -gt 1MB) {"{0:N3} MB" -f $($LogFileSize / 1MB)}
        elseif ($LogFileSize -gt 1KB) {"{0:N3} KB" -f $($LogFileSize / 1KB)}
        else {"{0:N3} Bytes" -f $LogFileSize}    
    )
    $StatisticsResults += "$('{0,-25}{1}' -f "Logfile filesize:", $StatisticsLogFileSize)`r`n"

    $StatisticsResults += "`r`n"
    $StatisticsComputerCount = 0
    [System.Windows.Forms.TreeNodeCollection]$StatisticsAllHostsNode = $script:ComputerListTreeView.Nodes
    foreach ($root in $StatisticsAllHostsNode) {foreach ($Category in $root.Nodes) {foreach ($Entry in $Category.nodes) {if ($Entry.Checked) { $StatisticsComputerCount++ }}}}
    $StatisticsResults += "$('{0,-25}{1}' -f "Computers Selected:", $StatisticsComputerCount)`r`n"   
    $StatisticsResults += "$('{0,-25}{1}' -f "Queries Selected:", $CountCommandQueries)`r`n"

    $ResourcesDirCheck = Test-Path -Path $ResourcesDirectory
    $StatisticsResults += "$('{0,-25}{1}' -f "Resource Folder Check:", $ResourcesDirCheck)`r`n"

    return $StatisticsResults
}
$StatisticsResults = Get-PoShACMEStatistics

#---------------------
# Statistics - Button
#---------------------
$StatisticsRefreshButton = New-Object System.Windows.Forms.Button -Property @{
    Name     = "Refresh"
    Text     = "Refresh"
    Location = @{ X = 2
                  Y = 5 }
    Size     = @{ Width  = 100
                  Height = 22 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
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
    Text     = "View Log"
    Location = @{ X = 258
                  Y = 5 }
    Size     = @{ Width  = 100
                  Height = 22 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    UseVisualStyleBackColor = $True
}
$StatisticsLogButton.Add_Click({Start-Process notepad.exe $LogFile}) 
$StatisticsLogButton.Add_MouseHover({
    ToolTipFunction -Title "View Activity Log File" -Icon "Info" -Message @"
⦿ Opens the PoSh-ACME activity log file.
⦿ All activities are logged, to inlcude:
    The launch of PoSh-ACME and the assosciated account/privileges.
    Each queries executed against each host.
    Network enumeration scannning for hosts: IPs and Ports.
    Connectivity checks: Ping, WinRM, & RPC.
    Remote access to hosts, but not commands executed within.`n`n
"@ })
$Section2StatisticsTab.Controls.Add($StatisticsLogButton)

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
    #Scrollbars = "Vertical"
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
$script:ComputerListTreeViewData = $null
$script:ComputerListTreeViewData = Import-Csv $ComputerListTreeViewFileSave -ErrorAction SilentlyContinue #| Select-Object -Property Name, OperatingSystem, CanonicalName, IPv4Address, MACAddress, Notes
#$script:ComputerListTreeViewData

function Save-HostData {
    $script:ComputerListTreeViewData | Export-Csv $ComputerListTreeViewFileSave -NoTypeInformation -Force
}
function AutoSave-HostData {
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
            $ComputerListTreeViewInsertDefaultDat0a | Add-Member -MemberType NoteProperty -Name CanonicalName -Value "/Unknown OU" -Force }

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
    [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerListTreeView.Nodes
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
    param([switch]$NoMessage)
    $script:ComputerListTreeView.Nodes.Add($script:TreeNodeComputerList)
    $script:ComputerListTreeView.ExpandAll()
    
    if ($script:ComputerListCheckedBoxesSelected.count -gt 0) {
        if (-not $NoMessage) {
            $ResultsListBox.Items.Clear()
            $ResultsListBox.Items.Add("Categories that were checked will not remained checked.")
            $ResultsListBox.Items.Add("")
            $ResultsListBox.Items.Add("The following hostname/IP selections are still selected in the new treeview:")
        }
        foreach ($root in $AllHostsNode) { 
            foreach ($Category in $root.Nodes) { 
                foreach ($Entry in $Category.nodes) { 
                    if ($script:ComputerListCheckedBoxesSelected -contains $Entry.text -and $root.text -notmatch 'Query History') {
                        $Entry.Checked      = $true
                        $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",10,1,1,1)
                        $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,0,224)
                        $Category.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
                        $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                        $ResultsListBox.Items.Add(" - $($Entry.Text)")
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

function Search-ComputerListTreeView {
    #$Section4TabControl.SelectedTab   = $Section3ResultsTab
    [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerListTreeView.Nodes

    # Checks if the search node already exists
    $SearchNode = $false
    foreach ($root in $AllHostsNode) { 
        if ($root.text -imatch 'Search Results') { $SearchNode = $true }
    }
    if ($SearchNode -eq $false) { $script:ComputerListTreeView.Nodes.Add($script:ComputerListSearch) }

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
        $ListOfCollectedDataDirectories = $(Get-ChildItem -Path $CollectedDataDirectory | Sort-Object -Descending).FullName | Select-Object -first $CollectedDataDirectorySearchLimitCombobox.text
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
    [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerListTreeView.Nodes 
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
    $script:SingleHostIPCheckBox.Checked    = $false
    $script:SingleHostIPTextBox.Text        = $DefaultSingleHostIPText
    $script:ComputerListTreeView.Enabled    = $true
    $script:ComputerListTreeView.BackColor  = "white"
}

#----------------------------------------
# ComputerList TreeView - Search TextBox
#----------------------------------------
$ComputerListTreeViewSearchTextBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Name     = "Search TextBox"
    Location = @{ X = $Column4RightPosition
                  Y = 25 }
    Size     = @{ Width  = 172
                  Height = 25 }
    AutoCompleteSource = "ListItems" # Options are: FileSystem, HistoryList, RecentlyUsedList, AllURL, AllSystemSources, FileSystemDirectories, CustomSource, ListItems, None
    AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
    Font               = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
ForEach ($Tag in $TagListFileContents) { [void] $ComputerListTreeViewSearchTextBox.Items.Add($Tag) }
$ComputerListTreeViewSearchTextBox.Add_KeyDown({ 
    if ($_.KeyCode -eq "Enter") { Search-ComputerListTreeView }
})
$ComputerListTreeViewSearchTextBox.Add_MouseHover({
    ToolTipFunction -Title "Search for Hosts" -Icon "Info" -Message @"
⦿ Searches through host data and returns results as nodes.
⦿ Search can include any character.
⦿ Tags are pre-built to assist with standarized notes.
⦿ Can search CSV Results, enable them in the Options Tab.`n`n
"@ })
$PoShACME.Controls.Add($ComputerListTreeViewSearchTextBox)

#---------------------------------------
# ComputerList TreeView - Search Button
#---------------------------------------
$ComputerListTreeViewSearchButton = New-Object System.Windows.Forms.Button -Property @{
    Name     = "Search Button"
    Text     = "Search"
    Location = @{ X = $Column4RightPosition + 176
                  Y = 24 }
    Size     = @{ Width  = 55
                  Height = 22 }
}
$ComputerListTreeViewSearchButton.Add_Click({ Search-ComputerListTreeView })
$ComputerListTreeViewSearchButton.Add_MouseHover({
    ToolTipFunction -Title "Search for Hosts" -Icon "Info" -Message @"
⦿ Searches through host data and returns results as nodes.
⦿ Search can include any character.
⦿ Tags are pre-built to assist with standarized notes.
⦿ Can search CSV Results, enable them in the Options Tab.`n`n
"@ })
$ComputerListTreeViewSearchButton.Font = New-Object System.Drawing.Font("$Font",11,0,0,0)
$PoShACME.Controls.Add($ComputerListTreeViewSearchButton)

#-----------------------------
# ComputerList Treeview Nodes
#-----------------------------
#Ref: https://info.sapien.com/index.php/guis/gui-controls/spotlight-on-the-contextmenustrip-control
$script:ComputerListTreeView = New-Object System.Windows.Forms.TreeView -Property @{
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
$script:ComputerListTreeView.Sort()
$script:ComputerListTreeView.Add_MouseEnter({ $script:ComputerListTreeView.size = @{ Width = 230 ; Height = 544 } })
$script:ComputerListTreeView.Add_MouseLeave({ $script:ComputerListTreeView.size = @{ Width = 230 ; Height = 308 } })

$script:ComputerListTreeView.Add_Click({ Conduct-NodeAction -TreeView $script:ComputerListTreeView.Nodes -ComputerList })
$script:ComputerListTreeView.add_AfterSelect({ Conduct-NodeAction -TreeView $script:ComputerListTreeView.Nodes -ComputerList })
$script:ComputerListTreeView.Add_Click({
    # When the node is checked, it updates various items
    [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerListTreeView.Nodes
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
$script:ComputerListTreeView.add_AfterSelect({
    # This will return data on hosts selected/highlight, but not necessarily checked
    [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerListTreeView.Nodes
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
                $Section4TabControl.SelectedTab = $Section3HostDataTab
            }
            foreach ($Entry in $Category.nodes) { 
                if ($Entry.isselected) { 
                    $Section4TabControl.SelectedTab = $Section3HostDataTab
                    $script:ComputerListTreeViewSelected = $Entry.Text
                    Function Update-HostDataNotes {
                        # Populates the Host Data Tab with data from the selected TreeNode
                        $Section3HostDataName.Text = $($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).Name
                        $Section3HostDataOS.Text   = $($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).OperatingSystem
                        $Section3HostDataOU.Text   = $($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).CanonicalName
                        $Section3HostDataIP.Text   = $($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).IPv4Address
                        $Section3HostDataMAC.Text  = $($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).MACAddress
                        $script:Section3HostDataNotesSaveCheck = $Section3HostDataNotes.Text = $($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).Notes
                   
                        $Section3HostDataSelectionComboBox.Text         = "Host Data - Selection"
                        $Section3HostDataSelectionDateTimeComboBox.Text = "Host Data - Date & Time"
                        Check-HostDataIfModified
                    }

                    if ($script:Section3HostDataNotesSaveCheck -ne $Section3HostDataNotes.Text) { 
                        [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic")
                        $verify = [Microsoft.VisualBasic.Interaction]::MsgBox(`
                            "Host Data Notes have not been saved!`n`nIf you continue without saving, any`nmodifications will be lost!`n`nDo you want to continue?",`
                            'YesNo,Question',` #'YesNoCancel,Question',`
                            "PoSh-ACME")
                        switch ($verify) {
                        'Yes'{ Update-HostDataNotes }
                        'No' { $Entry.isselected -eq $true  #... this line isn't working as expected, but isn't causing errors
                            $StatusListBox.Items.Clear()
                            $StatusListBox.Items.Add($Section3HostDataName.Text)
                            #Update-HostDataNotes
                        }
                        #'Cancel' { continue } #cancel option not needed
                        }
                    }
                    else { Update-HostDataNotes }
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
$script:ComputerListTreeView.Nodes.Add($script:TreeNodeComputerList)
$script:ComputerListTreeView.ExpandAll()

#-----------------------------
# View hostname/IPs by: Label
#-----------------------------
$ComputerListTreeViewViewByLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "View by:"
    Location = @{ X = $Column4RightPosition
                  Y = 7 }
    Size     = @{ Width  = 75
                  Height = 25 }
    Font     = New-Object System.Drawing.Font("$Font",11,1,2,1)
}
$PoShACME.Controls.Add($ComputerListTreeViewViewByLabel)

#----------------------------------------------------
# ComputerList TreeView - OS & Hostname Radio Button
#----------------------------------------------------
$ComputerListTreeViewOSHostnameRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
    Text     = "OS"
    Location = @{ X = $ComputerListTreeViewViewByLabel.Location.X + $ComputerListTreeViewViewByLabel.Size.Width
                  Y = $ComputerListTreeViewViewByLabel.Location.Y - 5 }
    Size     = @{ Height = 25
                  Width  = 50 }
    Checked  = $True
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$ComputerListTreeViewOSHostnameRadioButton.Add_Click({
    $ComputerListTreeViewCollapseAllButton.Text = "Collapse"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Treeview:  Operating Systems")

    # This variable stores data on checked checkboxes, so boxes checked remain among different views
    $script:ComputerListCheckedBoxesSelected = @()

    [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerListTreeView.Nodes 
    foreach ($root in $AllHostsNode) { 
        foreach ($Category in $root.Nodes) {
            foreach ($Entry in $Category.nodes) { 
                if ($Entry.Checked) { $script:ComputerListCheckedBoxesSelected += $Entry.Text }
            }
        }
    }
    $script:ComputerListTreeView.Nodes.Clear()
    Initialize-ComputerListTreeView
    Populate-ComputerListTreeViewDefaultData
    AutoSave-HostData
    Foreach($Computer in $script:ComputerListTreeViewData) { Add-ComputerNode -RootNode $script:TreeNodeComputerList -Category $Computer.OperatingSystem -Entry $Computer.Name -ToolTip $Computer.IPv4Address }    
    Keep-ComputerListCheckboxesChecked
})
$ComputerListTreeViewOSHostnameRadioButton.Add_MouseHover({
    ToolTipFunction -Title "Operating System View" -Icon "Info" -Message @"
⦿ Displays the hosts by Operating Systems.
⦿ Hosts will remain checked when switching between views.`n`n
"@ })
$PoShACME.Controls.Add($ComputerListTreeViewOSHostnameRadioButton)

#---------------------------------------------------------------------
# ComputerList TreeView - Active Directory OU & Hostname Radio Button
#---------------------------------------------------------------------
$ComputerListTreeViewOUHostnameRadioButton  = New-Object System.Windows.Forms.RadioButton -Property @{
    Text     = "OU / CN"
    Location = @{ X = $ComputerListTreeViewOSHostnameRadioButton.Location.X + $ComputerListTreeViewOSHostnameRadioButton.Size.Width + 5
                  Y = $ComputerListTreeViewOSHostnameRadioButton.Location.Y }
    Size     = @{ Height = 25
                  Width  = 75 }
    Checked  = $false
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$ComputerListTreeViewOUHostnameRadioButton.Add_Click({ 
    $ComputerListTreeViewCollapseAllButton.Text = "Collapse"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Treeview:  Active Directory Organizational Units")

    # This variable stores data on checked checkboxes, so boxes checked remain among different views
    $script:ComputerListCheckedBoxesSelected = @()

    [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerListTreeView.Nodes 
    foreach ($root in $AllHostsNode) { 
        foreach ($Category in $root.Nodes) {
            foreach ($Entry in $Category.nodes) { 
                if ($Entry.Checked) {
                    $script:ComputerListCheckedBoxesSelected += $Entry.Text
                }
            }
        }
    }            
    $script:ComputerListTreeView.Nodes.Clear()
    Initialize-ComputerListTreeView
    Populate-ComputerListTreeViewDefaultData
    AutoSave-HostData

    Foreach($Computer in $script:ComputerListTreeViewData) { Add-ComputerNode -RootNode $script:TreeNodeComputerList -Category $Computer.CanonicalName -Entry $Computer.Name -ToolTip $Computer.IPv4Address }
    Keep-ComputerListCheckboxesChecked
})
$ComputerListTreeViewOUHostnameRadioButton.Add_MouseHover({
    ToolTipFunction -Title "Organizational Unit / Canonical Name  View" -Icon "Info" -Message @"
⦿ Displays the hosts by Organizational Unit / Canonical Name.
⦿ Hosts will remain checked when switching between views.`n`n
"@ })
$PoShACME.Controls.Add($ComputerListTreeViewOUHostnameRadioButton)


##############################################################################################################################################################
##############################################################################################################################################################
##
## Section 3 Computer List - Tab Control
##
##############################################################################################################################################################
##############################################################################################################################################################

$Section3TabControl = New-Object System.Windows.Forms.TabControl -Property @{
    Name         = "Main Tab Window for Computer List"
    Location     = @{ X = 1082 
                      Y = 10 }
    Size         = @{ Height = 349
                      Width  = 140 }
    ShowToolTips = $True
    Font         = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$PoShACME.Controls.Add($Section3TabControl)

# Varables to Control Column 5
$Column5RightPosition     = 3
$Column5DownPositionStart = 6
$Column5DownPosition      = 6
$Column5DownPositionShift = 28
$Column5BoxWidth          = 124
$Column5BoxHeight         = 22

#=======================================================
#     ___        __  _                ______      __  
#    /   | _____/ /_(_)___  ____     /_  __/___ _/ /_ 
#   / /| |/ ___/ __/ / __ \/ __ \     / / / __ `/ __ \
#  / ___ / /__/ /_/ / /_/ / / / /    / / / /_/ / /_/ /
# /_/  |_\___/\__/_/\____/_/ /_/    /_/  \__,_/_.___/ 
#                                                    
#=======================================================

function Create-ComputerNodeCheckBoxArray {
    # This array stores checkboxes that are check; a minimum of at least one checkbox will be needed later in the script
    $script:ComputerListCheckedBoxesSelected = @()
    [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerListTreeView.Nodes 
    foreach ($root in $AllHostsNode) { 
        if ($root.Checked) {
            foreach ($Category in $root.Nodes) { 
                foreach ($Entry in $Category.nodes) { 
                    $script:ComputerListCheckedBoxesSelected += $Entry.Text 
                } 
            }
        }
        foreach ($Category in $root.Nodes) { 
            if ($Category.Checked) {
                foreach ($Entry in $Category.nodes) { $script:ComputerListCheckedBoxesSelected += $Entry.Text }       
            }
            foreach ($Entry in $Category.nodes) {
                if ($Entry.Checked) {
                    $script:ComputerListCheckedBoxesSelected += $Entry.Text
                }
            }       
        }         
    }
    return $script:ComputerListCheckedBoxesSelected
}
function ComputerNodeSelectedLessThanOne {
    param($Message)
    [system.media.systemsounds]::Exclamation.play()
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("$($Message):  Error")
    $ResultsListBox.Items.Clear()
    $ResultsListBox.Items.Add("Error:  No hostname/IP selected")
    $ResultsListBox.Items.Add("        Make sure to checkbox only one hostname/IP")
    $ResultsListBox.Items.Add("        Selecting a Category will not allow you to connect to multiple hosts")
}
function ComputerNodeSelectedMoreThanOne {
    param($Message)
    [system.media.systemsounds]::Exclamation.play()
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("$($Message):  Error")
    $ResultsListBox.Items.Clear()
    $ResultsListBox.Items.Add("Error:  Too many hostname/IPs selected")
    $ResultsListBox.Items.Add("        Make sure to checkbox only one hostname/IP")
    $ResultsListBox.Items.Add("        Selecting a Category will not allow you to connect to multiple hosts")    
}

##############################################################################################################################################################
##
## Section 3 - Action Tab
##
##############################################################################################################################################################
$Section3ActionTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text     = "Action"
    Location = @{ X = $Column5RightPosition
                  Y = $Column5DownPosition }
    Size     = @{ Height = $Column5BoxWidth
                  Width  = $Column5BoxHeight }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    UseVisualStyleBackColor = $True
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
    $script:ComputerListCheckedBoxesSelected = @()
    [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerListTreeView.Nodes 
    foreach ($root in $AllHostsNode) { 
        if ($root.Checked) {
            foreach ($Category in $root.Nodes) { foreach ($Entry in $Category.nodes) { $script:ComputerListCheckedBoxesSelected += $Entry.Text } }
        }
        foreach ($Category in $root.Nodes) { 
            if ($Category.Checked) {
                foreach ($Entry in $Category.nodes) { $script:ComputerListCheckedBoxesSelected += $Entry.Text }       
            }
            foreach ($Entry in $Category.nodes) {
                if ($Entry.Checked) {
                    $script:ComputerListCheckedBoxesSelected += $Entry.Text
                }
            }       
        }         
    }
    $script:ComputerListCheckedBoxesSelected = $script:ComputerListCheckedBoxesSelected | Select-Object -Unique

    $ResultsListBox.Items.Clear()
    if ($script:ComputerListCheckedBoxesSelected.count -lt 1) { ComputerNodeSelectedLessThanOne -Message $CheckType }
    else {
        $StatusListBox.Items.Clear()    
        $StatusListBox.Items.Add("$($CheckType):  $($script:ComputerListCheckedBoxesSelected.count) hosts")    
        Start-Sleep -Milliseconds 50
        $NotReachable = @()
        foreach ($target in $script:ComputerListCheckedBoxesSelected){
            if ($CheckType -eq "Ping") { $CheckCommand = Test-Connection -Count 1 -ComputerName $target }
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
            [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerListTreeView.Nodes 
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
$ComputerListPingButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "Ping"
    Location  = @{ X = $Column5RightPosition
                   Y = $Column5DownPosition }
    Size      = @{ Height = $Column5BoxHeight 
                   Width  = $Column5BoxWidth }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Black"
}
$ComputerListPingButton.Add_MouseHover($MouseHover)
$ComputerListPingButton.Add_Click({ Check-Connection -CheckType "Ping" -MessageTrue "Able to Ping" -MessageFalse "Unable to Ping" })
$ComputerListPingButton.Add_MouseHover({
    ToolTipFunction -Title "Ping Check" -Icon "Info" -Message @"
⦿ Unresponsive hosts can be removed from being nodes checked.
⦿ Command:
    Test-Connection -Count 1 -ComputerName <target>
⦿ Command Alternative (legacy):
    ping -n1 <target>`n`n
"@ })
$Section3ActionTab.Controls.Add($ComputerListPingButton) 

$Column5DownPosition += $Column5DownPositionShift

#============================================================================================================================================================
# Computer List - WinRM Check (Test-WSMan)
#============================================================================================================================================================
$ComputerListWinRMCheckButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "WinRM Check"
    Location  = @{ X = $Column5RightPosition
                   Y = $Column5DownPosition }
    Size      = @{ Width  = $Column5BoxWidth
                   Height = $Column5BoxHeight }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Black"
}
$ComputerListWinRMCheckButton.Add_MouseHover($MouseHover)
$ComputerListWinRMCheckButton.Add_Click({ Check-Connection -CheckType "WinRM Check" -MessageTrue "Able to Verify WinRM" -MessageFalse "Unable to Verify WinRM" })
$ComputerListWinRMCheckButton.Add_MouseHover({
    ToolTipFunction -Title "WinRM Check" -Icon "Info" -Message @"
⦿ Unresponsive hosts can be removed from being nodes checked.
⦿ Command:
    Test-WSman -ComputerName <target>
⦿ Command  Alternative (Sends Ping First):
    Test-NetConnection CommonTCPPort WINRM -ComputerName <target>`n`n
"@ })
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
    ToolTipFunction -Title "RPC Check" -Icon "Info" -Message @"
⦿ Unresponsive hosts can be removed from being nodes checked.
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
    Test-NetConnection -Port 135 -ComputerName <target>`n`n
"@ })
$Section3ActionTab.Controls.Add($ComputerListRPCCheckButton) 

$Column5DownPosition += $Column5DownPositionShift

#============================================================================================================================================================
# Memory Capture - Button (Rekall WinPmem)
#============================================================================================================================================================

#================================
# Memory Capture - Function Form
#================================
$script:ReportedRAMAmount                = $null
$script:ReportedDiskSize                 = $null
$script:ReportedDiskFreeSpace            = $null
$script:RekalWinPmemDiskPercentageUse    = $null
$script:RekallWinPmemReportedAverageLoad = $null

function RekallWinPmemRemoteHostPreCheckForm {
    function RekallWinPmemStatusCheckUpdate {
        $RekallWinPmemStatusMessageLabel.Text = $null

        # Update RAM Status
        if ($script:ReportedRAMAmount -gt $RekallWinPmemSettingHowMuchRAMToCollectComboBox.Text ) {
            $RekallWinPmemReportedTotalRAMLabel.Text = $('{0,-40}{1,-20}{2}' -f 'Total RAM Amount:',"$([math]::round($($script:ReportedRAMAmount / 1GB),2)) GB", "Fail")
            $RekallWinPmemStatusMessageLabel.Text += "[!] The RAM collection SETTING is insufficient`r`n"
        }
        else {
            $RekallWinPmemReportedTotalRAMLabel.Text = $('{0,-40}{1,-20}{2}' -f 'Total RAM Amount:',"$([math]::round($($script:ReportedRAMAmount / 1GB),2)) GB", "Pass")
            $RekallWinPmemStatusMessageLabel.Text += "[+] Passes RAM mount check`r`n"
        }

        # Update Disk Size Status
        if ($script:ReportedDiskSize -lt $script:ReportedRAMAmount){
            $RekallWinPmemRemoteTotalDiskSpaceLabel.Text = $('{0,-40}{1,-20}{2}' -f 'Total Disk Space:',"$([math]::round($($script:ReportedDiskSize / 1GB),2)) GB", "Fail")
            $RekallWinPmemStatusMessageLabel.Text += "[!] Endpoint has less disk space than its total RAM`r`n"
        }
        else {
            $RekallWinPmemRemoteTotalDiskSpaceLabel.Text = $('{0,-40}{1,-20}{2}' -f 'Total Disk Space:',"$([math]::round($($script:ReportedDiskSize / 1GB),2)) GB", "Pass")

            $RekallWinPmemStatusMessageLabel.Text += "[+] Passes disk size check`r`n"
        }            

        # Update Disk Free Space Status
        if ($script:ReportedDiskFreeSpace -lt $RekallWinPmemSettingMinimumAvailbleDiskSpaceComboBox.Text){
            $RekallWinPmemRemoteAvailableDiskSpaceLabel.Text = $('{0,-40}{1,-20}{2}' -f 'Available Disk Space:',"$([math]::round($($script:ReportedDiskFreeSpace  / 1GB),2)) GB", "Fail")
            $RekallWinPmemStatusMessageLabel.Text += "[!] The available disk space SETTING is insufficient`r`n"
        }
        else {
            $RekallWinPmemRemoteAvailableDiskSpaceLabel.Text = $('{0,-40}{1,-20}{2}' -f 'Available Disk Space:',"$([math]::round($($script:ReportedDiskFreeSpace  / 1GB),2)) GB", "Pass")
            $RekallWinPmemStatusMessageLabel.Text += "[+] Passes disk free space check`r`n"
        }            

        # Update Disk Utilization Percentage Use Status
        if ( $script:RekalWinPmemDiskPercentageUse -gt 75 ) {
            $RekallWinPmemReportedDiskPercentUsedLabel.Text = $('{0,-40}{1,-20}{2}' -f 'Disk Percentage Used:', "$script:RekalWinPmemDiskPercentageUse %", "Risk")
            $RekallWinPmemStatusMessageLabel.Text += "[!] Endpoint is using more than 75% of its disk space`r`n"
        }
        else {
            $RekallWinPmemReportedDiskPercentUsedLabel.Text = $('{0,-40}{1,-20}{2}' -f 'Disk Percentage Used:', "$script:RekalWinPmemDiskPercentageUse %", "Okay")
            $RekallWinPmemStatusMessageLabel.Text += "[+] Passes disk utilization ratio check`r`n"
        }

        # Update the Average Processor Load Status
        if ( $RekalWinPmemAverageLoad -gt 75 ) {
            $RekallWinPmemRemoteCPULevelLabel.Text = $('{0,-40}{1,-20}{2}' -f 'CPU Utilization (10s Avg):', "$([math]::Round($script:RekallWinPmemReportedAverageLoad,2)) %", "Risk")
            $RekallWinPmemStatusMessageLabel.Text += "[!] Endpoint is using more than 75% of its CPU`r`n"
        }
        else {
            $RekallWinPmemRemoteCPULevelLabel.Text = $('{0,-40}{1,-20}{2}' -f 'CPU Utilitzation (10s Avg):', "$([math]::Round($script:RekallWinPmemReportedAverageLoad,2)) %", "Okay")
            $RekallWinPmemStatusMessageLabel.Text += "[+] Passes CPU utilization check`r`n"
        }
                     
        $RekallWinPmemCheckRemoteResourcesButton.Text = "Update Status"

        if ($RekallWinPmemReportedTotalRAMLabel.Text -match 'Pass' -and $RekallWinPmemRemoteAvailableDiskSpaceLabel.Text -match 'Pass' -and $RekallWinPmemRemoteTotalDiskSpaceLabel.Text -match 'Pass') {
            if ($RekallWinPmemReportedDiskPercentUsedLabel.Text -match 'Okay' -and $RekallWinPmemRemoteCPULevelLabel.Text -match 'Okay') {
                $RekallWinPmemCollectMemoryButton.Enabled = $true
                $RekallWinPmemCollectMemoryOverrideRiskCheckbox.Enabled = $false
            }
            else {
                $RekallWinPmemCollectMemoryButton.Enabled = $false
                $RekallWinPmemCollectMemoryOverrideRiskCheckbox.Enabled = $true
                if ($RekallWinPmemCollectMemoryOverrideRiskCheckbox.checked){ $RekallWinPmemCollectMemoryButton.Enabled = $true }
                else { $RekallWinPmemCollectMemoryButton.Enabled = $false }
            }
        }
        else {
            $RekallWinPmemCollectMemoryButton.Enabled = $false
            $RekallWinPmemCollectMemoryOverrideRiskCheckbox.Enabled = $false                
        }
    }

    #-----------------------
    # Rekall WinPmem - Form
    #-----------------------
    $RekallWinPmemForm = New-Object System.Windows.Forms.Form -Property @{
        Text     = ”Memory Collection - ReKall WinPmem”
        Width    = 542
        Height   = 450
        StartPosition = "CenterScreen"
        ControlBox    = $true
        Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$ResourcesDirectory\favicon.ico")
    }
    #-----------------------------
    # Rekall WinPmem - Main Label
    #-----------------------------
    $RekallWinPmemMainLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Remote Memory Collection using Rekall WinPmem"
        Location = @{ X = 10
                      Y = 10 }
        Size     = @{ Width  = 528
                      Height = 25 }
        Font     = New-Object System.Drawing.Font("$Font",12,0,0,0)
    }
    $RekallWinPmemForm.Controls.Add($RekallWinPmemMainLabel)

    #-------------------------------------------
    # Rekall WinPmem - Verify Settings GroupBox
    #-------------------------------------------
    $RekallWinPmemVerifySettingsGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
        Text     = "Memory Collection Restrictions Settings"
        Location = @{ X = 10
                      Y = $RekallWinPmemMainLabel.Location.y + $RekallWinPmemMainLabel.Size.Height }
        Size     = @{ Width  = 508
                      Height = 105 }
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = "Blue"
    }
        #---------------------------------
        # Rekall WinPmem - Settings Label
        #---------------------------------
        $RekallWinPmemVerifySettingsLabel = New-Object System.Windows.Forms.Label -Property @{
            Text     = "Set limitations to reduce endpoint resource risk and limit network bandwidth utilization."
            Location = @{ X = 8
                          Y = 20 }
            Size     = @{ Width  = 480
                          Height = 20 }
            Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
            ForeColor = "Black"
        }
        $RekallWinPmemVerifySettingsGroupBox.Controls.Add($RekallWinPmemVerifySettingsLabel)

        #------------------------------------------------------------
        # Rekall WinPmem - Settings How Much RAM to Collect ComboBox
        #------------------------------------------------------------
        $RekallWinPmemSettingHowMuchRAMToCollectComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
            Text     = "4GB"
            Location = @{ X = 20
                          Y = $RekallWinPmemVerifySettingsLabel.Location.Y + $RekallWinPmemVerifySettingsLabel.Size.Height }
            Size     = @{ Width  = 65
                          Height = 20 }
            Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
            ForeColor = "Black"
            AutoCompleteSource = "ListItems"
            AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
        }
        $RekallWinPmemRemoteTotalRamSize = @('1GB','2GB','4GB','6GB','8GB','10GB','12GB','16GB') #1073741824 bytes = 1GB
        ForEach ($Item in $RekallWinPmemRemoteTotalRamSize) { $RekallWinPmemSettingHowMuchRAMToCollectComboBox.Items.Add($Item) }
        #$RekallWinPmemRemoteTotalRAMComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") {ViewChartExecute} })
        $RekallWinPmemVerifySettingsGroupBox.Controls.Add($RekallWinPmemSettingHowMuchRAMToCollectComboBox)

        #---------------------------------------------------------
        # Rekall WinPmem - Settings How Much RAM to Collect Label
        #---------------------------------------------------------
        $RekallWinPmemSettingHowMuchRAMToCollectLabel = New-Object System.Windows.Forms.Label -Property @{
            Text     = "The maximum amount of endpoint RAM that can be collected"
            Location = @{ X = $RekallWinPmemSettingHowMuchRAMToCollectComboBox.Location.X + $RekallWinPmemSettingHowMuchRAMToCollectComboBox.Size.Width + 5
                          Y = $RekallWinPmemSettingHowMuchRAMToCollectComboBox.Location.Y + 2 }
            Size     = @{ Width  = 355
                          Height = 25 }
            Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
            ForeColor = "Black"
        }
        $RekallWinPmemVerifySettingsGroupBox.Controls.Add($RekallWinPmemSettingHowMuchRAMToCollectLabel)

        #---------------------------------------------------------------
        # Rekall WinPmem - Setting Minimum Availble Disk Space ComboBox
        #---------------------------------------------------------------
        $RekallWinPmemSettingMinimumAvailbleDiskSpaceComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
            Text     = "250GB"
            Location = @{ X = 20
                          Y = $RekallWinPmemSettingHowMuchRAMToCollectComboBox.Location.Y + $RekallWinPmemSettingHowMuchRAMToCollectComboBox.Size.Height + 5 }
            Size     = @{ Width  = 65
                          Height = 25 }
            Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
            ForeColor = "Black"
            AutoCompleteSource = "ListItems"
            AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
        }
        $RekallWinPmemRemoteAvailableDiskSpace = @('25GB','50GB','100GB','250GB','500GB','750GB','1TB','2TB') #1073741824 bytes = 1GB
        ForEach ($Item in $RekallWinPmemRemoteAvailableDiskSpace) { $RekallWinPmemSettingMinimumAvailbleDiskSpaceComboBox.Items.Add($Item) }
        $RekallWinPmemVerifySettingsGroupBox.Controls.Add($RekallWinPmemSettingMinimumAvailbleDiskSpaceComboBox)

        #--------------------------------------------------------------
        # Rekall WinPmem - Settings Mimimal Available Disk Space Label
        #--------------------------------------------------------------
        $RekallWinPmemSettingMinimumAvailbleDiskSpaceLabel = New-Object System.Windows.Forms.Label -Property @{
            Text     = "The minimum endpoint disk space to permit memory collection."                     
            Location = @{ X = $RekallWinPmemSettingMinimumAvailbleDiskSpaceComboBox.Location.X + $RekallWinPmemSettingMinimumAvailbleDiskSpaceComboBox.Size.Width + 5
                          Y = $RekallWinPmemSettingMinimumAvailbleDiskSpaceComboBox.Location.Y + 2 }
            Size     = @{ Width  = 355
                          Height = 25 }
            Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
            ForeColor = "Black"
        }
        $RekallWinPmemVerifySettingsGroupBox.Controls.Add($RekallWinPmemSettingMinimumAvailbleDiskSpaceLabel)

    $RekallWinPmemForm.Controls.Add($RekallWinPmemVerifySettingsGroupBox) 

    #----------------------------------------------
    # Rekall WinPmem - Reported Resources GroupBox
    #----------------------------------------------
    $RekallWinPmemReportedResourcesGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
        Text     = "Endpoint Resource Information and Checks"
        Location = @{ X = 10
                      Y = $RekallWinPmemVerifySettingsGroupBox.Location.y + $RekallWinPmemVerifySettingsGroupBox.Size.Height + 5 }
        Size     = @{ Width  = 508
                      Height = 144 }
        Font      = New-Object System.Drawing.Font("$Font",12,0,0,0)
        ForeColor = "Blue"
    }
        #-------------------------------------------
        # Rekall WinPmem - Reported Total RAM Label
        #-------------------------------------------
        $RekallWinPmemReportedTotalRAMLabel = New-Object System.Windows.Forms.Label -Property @{
            Text     = "Total RAM Amount:"
            Location = @{ X = 20
                          Y = 20 }
            Size     = @{ Width  = 475
                          Height = 20 }
            Font     = New-Object System.Drawing.Font("Courier New",11,0,0,0)
            ForeColor = "Black"
        }
        $RekallWinPmemReportedResourcesGroupBox.Controls.Add($RekallWinPmemReportedTotalRAMLabel)

        #------------------------------------------------
        # Rekall WinPmem - Remote Total Disk Space Label
        #------------------------------------------------
        $RekallWinPmemRemoteTotalDiskSpaceLabel = New-Object System.Windows.Forms.Label -Property @{
            Text     = "Total Disk Space"
            Location = @{ X = 20
                          Y = $RekallWinPmemReportedTotalRAMLabel.Location.y + $RekallWinPmemReportedTotalRAMLabel.Size.Height - 2 }
            Size     = @{ Width  = 475
                          Height = 20 }
            Font      = New-Object System.Drawing.Font("Courier New",11,0,0,0)
            ForeColor = "Black"
        }
        $RekallWinPmemReportedResourcesGroupBox.Controls.Add($RekallWinPmemRemoteTotalDiskSpaceLabel)

        #----------------------------------------------------
        # Rekall WinPmem - Remote Available Disk Space Label
        #----------------------------------------------------
        $RekallWinPmemRemoteAvailableDiskSpaceLabel = New-Object System.Windows.Forms.Label -Property @{
            Text     = "Available Disk Space"
            Location = @{ X = 20
                          Y = $RekallWinPmemRemoteTotalDiskSpaceLabel.Location.y + $RekallWinPmemRemoteTotalDiskSpaceLabel.Size.Height - 2 }
            Size     = @{ Width  = 475
                         Height = 20 }
            Font      = New-Object System.Drawing.Font("Courier New",11,0,0,0)
            ForeColor = "Black"
        }
        $RekallWinPmemReportedResourcesGroupBox.Controls.Add($RekallWinPmemRemoteAvailableDiskSpaceLabel)

        #---------------------------------------------------
        # Rekall WinPmem - Reported Disk Percent Used Label
        #---------------------------------------------------
        $RekallWinPmemReportedDiskPercentUsedLabel = New-Object System.Windows.Forms.Label -Property @{
            Text     = "Disk Percentage Used:"
            Location = @{ X = 20
                          Y = $RekallWinPmemRemoteAvailableDiskSpaceLabel.Location.y + $RekallWinPmemRemoteAvailableDiskSpaceLabel.Size.Height - 2 }
            Size     = @{ Width  = 475
                          Height = 20 }
            Font      = New-Object System.Drawing.Font("Courier New",11,0,0,0)
            ForeColor = "Black"
        }
        $RekallWinPmemReportedResourcesGroupBox.Controls.Add($RekallWinPmemReportedDiskPercentUsedLabel)

        #-----------------------------------------
        # Rekall WinPmem - Remote CPU Level Label
        #-----------------------------------------
        $RekallWinPmemRemoteCPULevelLabel = New-Object System.Windows.Forms.Label -Property @{
            Text     = "CPU Utilization (10s Avg):"
            Location = @{ X = 20
                          Y = $RekallWinPmemReportedDiskPercentUsedLabel.Location.y + $RekallWinPmemReportedDiskPercentUsedLabel.Size.Height - 2 }
            Size     = @{ Width  = 475
                          Height = 20 }
            Font      = New-Object System.Drawing.Font("Courier New",11,0,0,0)
            ForeColor = "Black"
        }
        $RekallWinPmemReportedResourcesGroupBox.Controls.Add($RekallWinPmemRemoteCPULevelLabel)

        #------------------------------------------------
        # Rekall WinPmem - Check Remote Resources Button
        #------------------------------------------------
        $RekallWinPmemCheckRemoteResourcesButton = New-Object System.Windows.Forms.Button -Property @{
            Text     = "Check Remote Resources"
            Location = @{ X = 180
                          Y = $RekallWinPmemRemoteCPULevelLabel.Location.y + $RekallWinPmemRemoteCPULevelLabel.Size.Height }
            Size     = @{ Width  = 150
                          Height = 25 }
            Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
            ForeColor = "Black"
        }
        $RekallWinPmemCheckRemoteResourcesButton.add_click({
            # This brings specific tabs to the forefront/front view
            $Section4TabControl.SelectedTab   = $Section3ResultsTab

            if ($RekallWinPmemCheckRemoteResourcesButton.Text -eq "Check Remote Resources") {
                $RekallWinPmemCheckRemoteResourcesButton.Text = "Querying Endpoint"
                $RekallWinPmemCheckRemoteResourcesButton.add_click({$null})
            }
            $RekallWinPmemStatusMessageLabel.Text = $null

            # Provides GUI Message about collecting remote info
            $RekallWinPmemReportedTotalRAMLabel.Text         = $('{0,-40}{1,-20}{2}' -f 'Total RAM Amount:',          "Collecting", "____")
            $RekallWinPmemRemoteTotalDiskSpaceLabel.Text     = $('{0,-40}{1,-20}{2}' -f 'Total Disk Space:',          "Collecting", "____")
            $RekallWinPmemRemoteAvailableDiskSpaceLabel.Text = $('{0,-40}{1,-20}{2}' -f 'Available Disk Space:',      "Collecting", "____")
            $RekallWinPmemReportedDiskPercentUsedLabel.Text  = $('{0,-40}{1,-20}{2}' -f 'Disk Percentage Used:',      "Collecting", "____")
            $RekallWinPmemRemoteCPULevelLabel.Text           = $('{0,-40}{1,-20}{2}' -f 'CPU Utilization (10s Avg):', "Collecting", "____")

            if ($RekallWinPmemCheckRemoteResourcesButton.Text -eq "Querying Endpoint") {
                # Gets RAM Amount
                # Get-WmiObject -Class Win32_PhysicalMemory | Select capacity
                $script:ReportedRAMAmount = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $script:ComputerListCheckedBoxesSelected | Select-Object -ExpandProperty TotalPhysicalMemory
                $Message = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty TotalPhysicalMemory"
                $Message | Add-Content -Path $LogFile
                $RekallWinPmemReportedTotalRAMLabel.Text = $('{0,-40}{1,-20}{2}' -f 'Total RAM Amount:',"$([math]::round($($script:ReportedRAMAmount / 1GB),2)) GB", "____")
                Start-Sleep -Milliseconds 500

                # Gets Disk Statistics
                $ReportedDiskInfo = Get-WmiObject -Class Win32_LogicalDisk -ComputerName $script:ComputerListCheckedBoxesSelected | Where-Object {$_.DriveType -eq 3 -and $_.DeviceID -eq 'C:'} | Select-Object -Property Size, FreeSpace
                $Message = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Get-WmiObject -Class Win32_LogicalDisk -ComputerName $script:ComputerListCheckedBoxesSelected | Select-Object -Property Size, FreeSpace"
                $Message | Add-Content -Path $LogFile

                    # Determine Disk Total Size
                    $script:ReportedDiskSize = $ReportedDiskInfo | Select-Object -ExpandProperty Size                
                    $RekallWinPmemRemoteTotalDiskSpaceLabel.Text = $('{0,-40}{1,-20}{2}' -f 'Total Disk Space:',"$([math]::round($($script:ReportedDiskSize / 1GB),2)) GB", "____")
                    Start-Sleep -Milliseconds 500

                    # Determine Disk Free Space
                    $script:ReportedDiskFreeSpace = $ReportedDiskInfo | Select-Object -ExpandProperty FreeSpace
                    $RekallWinPmemRemoteAvailableDiskSpaceLabel.Text = $('{0,-40}{1,-20}{2}' -f 'Available Disk Space:',"$([math]::round($($script:ReportedDiskFreeSpace / 1GB),2)) GB", "____")
                    Start-Sleep -Milliseconds 500

                # Calculate Disk Utilization Percentage Use
                $script:RekalWinPmemDiskPercentageUse = $([math]::abs([math]::round($((($script:ReportedDiskFreeSpace / $script:ReportedDiskSize) * 100) - 100),2)))
                $RekallWinPmemReportedDiskPercentUsedLabel.Text = $('{0,-40}{1,-20}{2}' -f 'Disk Percentage Used:', "$script:RekalWinPmemDiskPercentageUse %", "____")
                Start-Sleep -Milliseconds 500

                # Gets the Average Processor Load
                $LoadPercentageAverage = @()
                foreach ($count in $(10..10)) {
                    if ($count -in @(0,5,10)) {
                        $LoadPercentageAverage += Get-WmiObject Win32_Processor -ComputerName $script:ComputerListCheckedBoxesSelected | Select-Object -Property LoadPercentage
                        $Message = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Get-WmiObject Win32_Processor -ComputerName $script:ComputerListCheckedBoxesSelected | Select-Object -Property LoadPercentage"
                        $Message | Add-Content -Path $LogFile
                    }
                    $RekallWinPmemRemoteCPULevelLabel.Text = $('{0,-40}{1,-20}{2}' -f 'CPU Utilization (10s Avg):', "Remaining $($count)", "____")
                    if ($count -eq 0) {break}
                    Start-Sleep -Seconds 1
                }
                $script:RekallWinPmemReportedAverageLoad = $LoadPercentageAverage | Measure-Object -Property LoadPercentage -Average | Select-Object -ExpandProperty Average
                $RekalWinPmemAverageLoad = $([math]::abs([math]::round($((($script:ReportedDiskFreeSpace / $script:ReportedDiskSize) * 100) - 100),2)))
                $RekallWinPmemRemoteCPULevelLabel.Text = $('{0,-40}{1,-20}{2}' -f 'CPU Utilization (10s Avg):', "$([math]::Round($script:RekallWinPmemReportedAverageLoad,2)) %", "____")
            }
            RekallWinPmemStatusCheckUpdate
        })
        $RekallWinPmemReportedResourcesGroupBox.Controls.Add($RekallWinPmemCheckRemoteResourcesButton) 

    $RekallWinPmemForm.Controls.Add($RekallWinPmemReportedResourcesGroupBox) 

    #---------------------------------------
    # Rekall WinPmem - Status Message Label
    #---------------------------------------
    $RekallWinPmemStatusMessageLabel = New-Object System.Windows.Forms.Textbox -Property @{
        Text     = "Status: Need to query endpoint"
        Location = @{ X = 10
                      Y = $RekallWinPmemReportedResourcesGroupBox.Location.Y + $RekallWinPmemReportedResourcesGroupBox.Size.Height + 5 }
        Size     = @{ Width  = 508
                      Height = 80 }
        Font      = New-Object System.Drawing.Font("Courier New",11,0,0,0)
        ForeColor = "Black"
        MultiLine = $true
        Enabled   = $false
    }
    $RekallWinPmemForm.Controls.Add($RekallWinPmemStatusMessageLabel)

    #----------------------------------------
    # Rekall WinPmem - Collect Memory Button
    #----------------------------------------
    $RekallWinPmemCollectMemoryButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Collect Memory"
        Location = @{ X = 190
                      Y = $RekallWinPmemStatusMessageLabel.Location.y + $RekallWinPmemStatusMessageLabel.Size.Height + 5 }
        Size     = @{ Width  = 150
                      Height = 25 }
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = "Black"
        Enabled   = $false
    }
    $RekallWinPmemCollectMemoryButton.add_click({ 
        RekallWinPmemStatusCheckUpdate
        if ($RekallWinPmemCollectMemoryButton.Enabled) {
            $RekallWinPmemForm.Close()        
            RekallWinPmemMemoryCaptureCommand -ChunkSize $($RekallWinPmemCompressionSettingChunkSizeComboBox.Text) -Compression $($RekallWinPmemCompressionSettingCompressionTypeComboBox.Text)
        }
    })
    $RekallWinPmemForm.Controls.Add($RekallWinPmemCollectMemoryButton)

    #---------------------------------------------------
    # Rekall WinPmem - Collect Memory Override Checkbox
    #---------------------------------------------------
    $RekallWinPmemCollectMemoryOverrideRiskCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
        Text     = "Override Risk"
        Location = @{ X = $RekallWinPmemCollectMemoryButton.Location.X + $RekallWinPmemCollectMemoryButton.Size.Width + 25
                      Y = $RekallWinPmemCollectMemoryButton.Location.Y + 2 }
        Size     = @{ Width  = 185
                      Height = 25 }
        Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor = "Black"
        Enabled   = $false
    }
    $RekallWinPmemCollectMemoryOverrideRiskCheckbox.add_click({
        if ($RekallWinPmemCollectMemoryOverrideRiskCheckbox.checked){ 
            $RekallWinPmemCollectMemoryButton.Enabled = $true 
        }
        else { $RekallWinPmemCollectMemoryButton.Enabled = $false }
    })
    $RekallWinPmemForm.Controls.Add($RekallWinPmemCollectMemoryOverrideRiskCheckbox)

    $RekallWinPmemForm.ShowDialog()
}

#===========================================
# Memory Capture - Function Capture Command
#===========================================
function RekallWinPmemMemoryCaptureCommand {
    $CollectionName = "Memory Capture"
    $CollectionCommandStartTime = Get-Date 
    Conduct-PreCommandExecution $PoShLocation $CollectedResultsUncompiled $CollectionName
    $ResultsListBox.Items.Insert(1,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName - $script:ComputerListCheckedBoxesSelected")
    Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $CollectedDataTimeStampDirectory `
                            -IndividualHostResults $IndividualHostResults -CollectionName $CollectionName `
                            -TargetComputer $script:ComputerListCheckedBoxesSelected
    Create-LogEntry -TargetComputer $script:ComputerListCheckedBoxesSelected -CollectionName $CollectionName -LogFile $LogFile
    Function RekallWinPmemMemoryCaptureData {
        # https://isc.sans.edu/forums/diary/Winpmem+Mild+mannered+memory+aquisition+tool/17054/
        # This will create a raw memory image named "memory.raw" suitable for analysis with Volatility, Mandiants Redline and others.
        $TempPath            = "Windows\Temp"
        $WinPmem             = "WinPmem.exe"
        $MemoryCaptureScript = "Capture-Memory.ps1"
        $MemoryCaptureFile   = "MemoryCapture-$($script:ComputerListCheckedBoxesSelected).raw"
        $CompressionsType    = $Compression.TrimEnd(' Compression')

        # Starts the WinPmem Memory Capture and saves the capture to the targets Windows' Temp dir
        "Start-Process `"C:\$TempPath\$WinPmem`" -WindowStyle Hidden -ArgumentList `"C:\$TempPath\$MemoryCaptureFile`"" > "$ExternalPrograms\$MemoryCaptureScript"

        $Message = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Starting Memory Capture"
        $RekallWinPmemStatusMessageLabel.Text = "$Message `r`n" + "$($RekallWinPmemStatusMessageLabel.Text)"

        # Copies WinPmem.exe and Strings.exe over to the TargetComputer
        $CopyWinPmemToTargetHost = "Copy-Item '$ExternalPrograms\$WinPmem' '\\$script:ComputerListCheckedBoxesSelected\C$\$TempPath' -Force"
        Invoke-Expression $CopyWinPmemToTargetHost
        $Message = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $CopyWinPmemToTargetHost"
        $Message | Add-Content -Path $LogFile

        # Copies the Capture-Memory.ps1 script to the TargetComputer
        $CopyMemoryScriptToTargetHost = Copy-Item "$ExternalPrograms\$MemoryCaptureScript" "\\$script:ComputerListCheckedBoxesSelected\C$\$TempPath" -Force
        Invoke-Expression $CopyMemoryScriptToTargetHost
        $Message = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $CopyMemoryScriptToTargetHost"
        $Message | Add-Content -Path $LogFile

        # Executes the Capture-Memory.ps1 Script located on the TargetComputer - This uses the WinPmem Program to save the Memory to the TargetComputer
        $ExecuteMemoryCaptureOnTargetHost = "Invoke-WmiMethod -Class Win32_Process -Name Create -ComputerName $script:ComputerListCheckedBoxesSelected -ArgumentList `"PowerShell -WindowStyle Hidden -Command C:\$TempPath\$MemoryCaptureScript`" | Out-Null"
        Invoke-Expression $ExecuteMemoryCaptureOnTargetHost 
        $Message = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $ExecuteMemoryCaptureOnTargetHost"
        $Message | Add-Content -Path $LogFile

        Start-Sleep -Seconds 10
        # Checks to see if the process is still running
        while ($true) {
            $CheckWinPmemProcessOnTargetHost = "Get-WmiObject -Class Win32_Process -ComputerName $script:ComputerListCheckedBoxesSelected | Where-Object ProcessName -eq WinPmem.exe"
            $CheckWinPmemProcessOnTargetHostStatus = Invoke-Expression $CheckWinPmemProcessOnTargetHost
            $Message1 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Checking Status "
            $Message1 | Add-Content -Path $LogFile
            $RekallWinPmemStatusMessageLabel.Text = "$Message1 `r`n" + "$($RekallWinPmemStatusMessageLabel.Text)"
            $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $CheckWinPmemProcessOnTargetHost"
            $Message2 | Add-Content -Path $LogFile

            if ($CheckWinPmemProcessOnTargetHostStatus) { Start-Sleep -Seconds 10 }
            else {
                # Copies the Memory Capture File from the TargetComputer back to the Localhost
                $CopyMemoryCaptureFromTargetHost = "Copy-Item '\\$script:ComputerListCheckedBoxesSelected\C$\$TempPath\$MemoryCaptureFile' '$CollectedDataTimeStampDirectory' -Force"
                Invoke-Expression $CopyMemoryCaptureFromTargetHost
                $Message = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $CopyMemoryCaptureFromTargetHost"
                $Message | Add-Content -Path $LogFile
                                
                $Message = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Memory Capture Has Finished!"
                $Message | Add-Content -Path $LogFile
                $RekallWinPmemStatusMessageLabel.Text = "$Message `r`n" + "$($RekallWinPmemStatusMessageLabel.Text)"
                Start-Sleep -Seconds 5

                # Removes the Memory Capture script from the localhost and TargetHost
                Remove-Item "$ExternalPrograms\$MemoryCaptureScript" -Force
                Remove-Item "\\$script:ComputerListCheckedBoxesSelected\C$\$TempPath\$MemoryCaptureScript" -Force
                    
                # Removes WinPmem and Memory Capture filefrom the TargetHost
                Remove-Item "\\$script:ComputerListCheckedBoxesSelected\C$\$TempPath\$WinPmem" -Force
                Remove-Item "\\$script:ComputerListCheckedBoxesSelected\C$\$TempPath\$MemoryCaptureFile" -Force
                break
            }
        }
    }
    RekallWinPmemMemoryCaptureData

    $CollectionCommandEndTime1  = Get-Date 
    $CollectionCommandDiffTime1 = New-TimeSpan -Start $CollectionCommandStartTime -End $CollectionCommandEndTime1
    $ResultsListBox.Items.RemoveAt(1)
    $ResultsListBox.Items.Insert(1,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime1]  $CollectionName - $script:ComputerListCheckedBoxesSelected")

    Conduct-PostCommandExecution $CollectionName
    $CollectionCommandEndTime0  = Get-Date 
    $CollectionCommandDiffTime0 = New-TimeSpan -Start $CollectionCommandStartTime -End $CollectionCommandEndTime0
    $ResultsListBox.Items.RemoveAt(0)
    $ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime0]  $CollectionName")
}

#------------------------------------------
# Rekall WinPmem - Memory Capture Button
#------------------------------------------
$RekallWinPmemMemoryCaptureButton = New-Object System.Windows.Forms.Button -Property @{
    Name      = "Memory Capture"
    Text      = "Memory Capture"
    Location  = @{ X = $Column5RightPosition
                   Y = $Column5DownPosition }
    Size      = @{ Width  = $Column5BoxWidth
                   Height = $Column5BoxHeight  }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Black"
}

$RekallWinPmemMemoryCaptureButton.Add_MouseHover({
    ToolTipFunction -Title "Memory Capture" -Icon "Info" -Message @"
⦿ Uses Rekall WinPmep to retrieve memory for analysis. 
⦿ The memory.raw file collected can be used with Volatility or windbg. 
⦿ It supports all windows versions from WinXP SP2 to Windows 10.
⦿ It supports processor types: i386 and amd64.
⦿ Uses RPC/DCOM `n`n
"@ })
$RekallWinPmemMemoryCaptureButton.add_click({ 
    # This brings specific tabs to the forefront/front view
    $Section4TabControl.SelectedTab   = $Section3ResultsTab
    
    # Ensures only one endpoint is selected
    # This array stores checkboxes that are check; a minimum of at least one checkbox will be needed later in the script
    $script:ComputerListCheckedBoxesSelected = @()
    [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerListTreeView.Nodes 
    foreach ($root in $AllHostsNode) { 
        if ($root.Checked) {
            foreach ($Category in $root.Nodes) { foreach ($Entry in $Category.nodes) { $script:ComputerListCheckedBoxesSelected += $Entry.Text } }
        }
        foreach ($Category in $root.Nodes) {
            if ($Category.Checked) {
                foreach ($Entry in $Category.nodes) { $script:ComputerListCheckedBoxesSelected += $Entry.Text }
            }
            foreach ($Entry in $Category.nodes) {
                if ($Entry.Checked) {
                    $script:ComputerListCheckedBoxesSelected += $Entry.Text
                }
            }
        }
    }
    $ResultsListBox.Items.Clear()
    if ($script:ComputerListCheckedBoxesSelected.count -eq 1) {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Rekall WinPMem:  $($script:ComputerListTreeViewSelected)")
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Launching Memory Collection Window")
        $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  Launched Memory Collection Window"
        $LogMessage | Add-Content -Path $LogFile
        RekallWinPmemRemoteHostPreCheckForm
    }
    elseif ($script:ComputerListCheckedBoxesSelected.count -lt 1) { ComputerNodeSelectedLessThanOne -Message 'Rekall WinPmem' }
    elseif ($script:ComputerListCheckedBoxesSelected.count -gt 1) { ComputerNodeSelectedMoreThanOne -Message 'Rekall WinPmem' }
})

# Test if the External Programs directory is present; if it's there load the tab
if (Test-Path "$ExternalPrograms\WinPmem.exe") { $Section3ActionTab.Controls.Add($RekallWinPmemMemoryCaptureButton) }

$Column5DownPosition += $Column5DownPositionShift

#============================================================================================================================================================
# Computer List - EventLog Button
#============================================================================================================================================================
$EventViewerButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = 'Event Viewer'
    Location  = @{ X = $Column5RightPosition
                   Y = $Column5DownPosition }
    Size      = @{ Height = $Column5BoxHeight
                   Width  = $Column5BoxWidth }
    Font      = New-Object System.Drawing.Font("$Font",11,0,2,1)
    ForeColor = "Black"
}
$EventViewerButton.Add_Click({
    # This brings specific tabs to the forefront/front view
    $Section4TabControl.SelectedTab   = $Section3ResultsTab

    Create-ComputerNodeCheckBoxArray       
    $ResultsListBox.Items.Clear()
    if ($script:ComputerListCheckedBoxesSelected.count -gt 1) {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Show Event Viewer:  $($script:ComputerListTreeViewSelected)")
        $ResultsListBox.Items.Clear()

        # Note: Show-EventLog doesn't support -Credential, nor will it spawn a local GUI if used witn invoke-command/enter-pssession for a remote host with credentials provided
        Foreach ($Computer in $($script:ComputerListCheckedBoxesSelected | Select-Object -Unique)){ 
            Show-EventLog -ComputerName $Computer 
            $ResultsListBox.Items.Add("Show-EventLog -ComputerName $script:ComputerListCheckedBoxesSelected")
            $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  Show-EventLog -ComputerName $($script:ComputerListTreeViewSelected)"
            $LogMessage | Add-Content -Path $LogFile            
        }
        $ResultsListBox.Items.Add("Show-EventLog -ComputerName $script:ComputerListCheckedBoxesSelected")
        $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  Show-EventLog -ComputerName $($script:ComputerListTreeViewSelected)"
        $LogMessage | Add-Content -Path $LogFile
    }
    elseif ($script:ComputerListCheckedBoxesSelected.count -lt 1) { ComputerNodeSelectedLessThanOne -Message 'Show Event Viewer' }
})
$EventViewerButton.Add_MouseHover({
    ToolTipFunction -Title "Event Viewer" -Icon "Info" -Message @"
⦿ Will attempt to show the Event Viewer for a single host.
⦿ NOT compatiable with 'Alternate Credentials'
⦿ Uses RPC/DCOM, not WinRM
⦿ Command:
        Show-EventLog -ComputerName <Hostname>`n`n
"@ })
$Section3ActionTab.Controls.Add($EventViewerButton) 

$Column5DownPosition += $Column5DownPositionShift

#============================================================================================================================================================
# Computer List - RDP Button
#============================================================================================================================================================
$ComputerListRDPButton = New-Object System.Windows.Forms.Button -Property @{
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
    $Section4TabControl.SelectedTab = $Section3ResultsTab

    Create-ComputerNodeCheckBoxArray 
    $ResultsListBox.Items.Clear()
    if ($script:ComputerListCheckedBoxesSelected.count -eq 1) {
        if ($ComputerListProvideCredentialsCheckBox.Checked) {
            if (!$script:Credential) { $script:Credential = Get-Credential }
            $Username = $script:Credential.UserName
            $Password = $script:Credential.GetNetworkCredential().Password
            # The cmdkey utility helps you manage username and passwords; it allows you to create, delete, and display credentials for the current user
                # cmdkey /list                <-- lists all credentials
                # cmdkey /list:targetname     <-- lists the credentials for a speicific target
                # cmdkey /add:targetname      <-- creates domain credential
                # cmdkey /generic:targetname  <-- creates a generic credential
                # cmdkey /delete:targetname   <-- deletes target credential
            #cmdkey /generic:TERMSRV/$script:ComputerListCheckedBoxesSelected /user:$Username /pass:$Password
            cmdkey /add:$script:ComputerListCheckedBoxesSelected /user:$Username /pass:$Password
            mstsc /v:$($script:ComputerListCheckedBoxesSelected):3389
            #Start-Sleep -Seconds 1
            #cmdkey /delete:$script:ComputerListCheckedBoxesSelected 
        }
        else {
            mstsc /v:$($script:ComputerListCheckedBoxesSelected):3389
        }
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Remote Desktop:  $($script:ComputerListCheckedBoxesSelected)")
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("mstsc /v:$($script:ComputerListCheckedBoxesSelected):3389")
        $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  Remote Desktop (RDP): $($script:ComputerListCheckedBoxesSelected)"
        $LogMessage | Add-Content -Path $LogFile
    }
    elseif ($script:ComputerListCheckedBoxesSelected.count -lt 1) { ComputerNodeSelectedLessThanOne -Message 'Remote Desktop' }
    elseif ($script:ComputerListCheckedBoxesSelected.count -gt 1) { ComputerNodeSelectedMoreThanOne -Message 'Remote Desktop' }
})
$ComputerListRDPButton.Add_MouseHover({
    ToolTipFunction -Title "Remote Desktop Connection" -Icon "Info" -Message @"
⦿ Will attempt to RDP into a single host.
⦿ Command:
        mstsc /v:<target>:3389
        mstsc /v:<target>:3389 /user:USERNAME /pass:PASSWORD
⦿ Compatiable with 'Alternate Credentials' if permitted by network policy`n`n
"@ })
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

    Create-ComputerNodeCheckBoxArray    
    $ResultsListBox.Items.Clear()
    if ($script:ComputerListCheckedBoxesSelected.count -eq 1) {        
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Enter-PSSession:  $($script:ComputerListTreeViewSelected)")
        $ResultsListBox.Items.Clear()
        if ($ComputerListProvideCredentialsCheckBox.Checked) {
            if (-not $script:Credential) { $script:Credential = Get-Credential }
            $Username = $script:Credential.UserName
            $Password = $script:Credential.GetNetworkCredential().Password
            $ResultsListBox.Items.Add("Enter-PSSession -ComputerName $script:ComputerListCheckedBoxesSelected -Credential $script:Credential")                        
            start-process powershell -ArgumentList "-noexit Enter-PSSession -ComputerName $script:ComputerListCheckedBoxesSelected -Credential `$(New-Object pscredential('$Username'`,`$('$Password' | ConvertTo-SecureString -AsPlainText -Force)))"
        }

        else {
            $ResultsListBox.Items.Add("Enter-PSSession -ComputerName $script:ComputerListCheckedBoxesSelected")
            Start-Process PowerShell -ArgumentList "-noexit Enter-PSSession -ComputerName $script:ComputerListCheckedBoxesSelected" 
        }
        $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Enter-PSSession -ComputerName $($script:ComputerListTreeViewSelected)"
        $LogMessage | Add-Content -Path $LogFile
    }
    elseif ($script:ComputerListCheckedBoxesSelected.count -lt 1) { ComputerNodeSelectedLessThanOne -Message 'Enter-PSSession' }
    elseif ($script:ComputerListCheckedBoxesSelected.count -gt 1) { ComputerNodeSelectedMoreThanOne -Message 'Enter-PSSession' }
})
$ComputerListPSSessionButton.Add_MouseHover({
    ToolTipFunction -Title "Enter-PSSession" -Icon "Info" -Message @"
⦿ Starts an interactive session with a remote computer.
⦿ Requires the WinRM service.
⦿ To use with an IP address, the Credential parameter must be used.
Also, the computer must be configured for HTTPS transport or
the remote computer's IP must be in the local TrustedHosts.
⦿ Command:
        Enter-PSSession -ComputerName <target>
⦿ Compatiable with 'Alternate Credentials'`n`n
"@ })
$Section3ActionTab.Controls.Add($ComputerListPSSessionButton) 

$Column5DownPosition += $Column5DownPositionShift

#============================================================================================================================================================
# Computer List - PsExec Button
#============================================================================================================================================================
$ComputerListPsExecButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "PsExec"
    Location  = @{ X = $Column5RightPosition
                   Y = $Column5DownPosition }
    Size      = @{ Width  = $Column5BoxWidth
                   Height = $Column5BoxHeight }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Black"
}
$ComputerListPsExecButton.Add_Click({
    # This brings specific tabs to the forefront/front view
    $Section4TabControl.SelectedTab   = $Section3ResultsTab

    Create-ComputerNodeCheckBoxArray  
    $ResultsListBox.Items.Clear()
    if ($script:ComputerListCheckedBoxesSelected.count -eq 1) {        
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("PsExec:  $($script:ComputerListTreeViewSelected)")
        $ResultsListBox.Items.Clear()
        if ($ComputerListProvideCredentialsCheckBox.Checked) {
            if (!$script:Credential) { $script:Credential = Get-Credential }
            $Username = $script:Credential.UserName
            $Password = $script:Credential.GetNetworkCredential().Password
            $UseCredential = "-u $Username -p $Password"
            $ResultsListBox.Items.Add("./PsExec.exe -accepteula \\$script:ComputerListCheckedBoxesSelected '<domain\username>' -p '<password>' cmd")
            Start-Process PowerShell -WindowStyle Hidden -ArgumentList "Start-Process -WindowStyle Hidden '$PsExecPath' -ArgumentList '-accepteula \\$script:ComputerListCheckedBoxesSelected $UseCredential cmd'"        
        }
        else { 
            $ResultsListBox.Items.Add("./PsExec.exe -accepteula \\$script:ComputerListCheckedBoxesSelected cmd")
            Start-Process PowerShell -WindowStyle Hidden -ArgumentList "Start-Process -WindowStyle Hidden '$PsExecPath' -ArgumentList '-accepteula \\$script:ComputerListCheckedBoxesSelected cmd'"
        }
        $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  PsExec: $($script:ComputerListTreeViewSelected)"
        $LogMessage | Add-Content -Path $LogFile
    }
    elseif ($script:ComputerListCheckedBoxesSelected.count -lt 1) { ComputerNodeSelectedLessThanOne -Message 'PsExec' }
    elseif ($script:ComputerListCheckedBoxesSelected.count -gt 1) { ComputerNodeSelectedMoreThanOne -Message 'PsExec' }
})
$ComputerListPsExecButton.Add_MouseHover({
    ToolTipFunction -Title "PsExec" -Icon "Info" -Message @"
⦿ Will attempt to obtain a cmd prompt via PsExec.
⦿ PsExec is a Windows Sysinternals tool.
⦿ Some anti-virus scanners will alert on this.
⦿ Command:
        PsExec.exe -accepteula \\<target> cmd
        PsExec.exe -accepteula \\<target> -u <domain\username> -p <password> cmd
⦿ Compatiable with 'Alternate Credentials'`n`n
"@ })
# Test if the External Programs directory is present; if it's there load the tab
if (Test-Path "$ExternalPrograms\PsExec.exe") { $Section3ActionTab.Controls.Add($ComputerListPsExecButton) }

$Column5DownPosition += $Column5DownPositionShift


#============================================================================================================================================================
# Provide Creds Button
#============================================================================================================================================================
$ProvideCredsButton = New-Object System.Windows.Forms.Button -Property @{
    Name     = "Provide Creds"
    Text     = "Provide Creds`n"
    Location = @{ X = $Column5RightPosition
                  Y = $Column5DownPosition }
    Size     = @{ Width  = $Column5BoxWidth
                  Height = $Column5BoxHeight }
    Font = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
#$ProvideCredsButton.UseVisualStyleBackColor = $True
$ProvideCredsButton.Add_Click({
    # This brings specific tabs to the forefront/front view
    $Section4TabControl.SelectedTab = $Section3ResultsTab

    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Provide Credentials:")

    $script:Credential = Get-Credential
    $ComputerListProvideCredentialsCheckBox.Checked = $True

    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Provide Credentials: Stored")
    $ResultsListBox.Items.Clear()
})
$ProvideCredsButton.Add_MouseHover({
    ToolTipFunction -Title "Use Alternate Credentials" -Icon "Info" -Message @"
⦿ Credentials are stored as a SecureString.
⦿ If checked, credentials are applied to:
     RDP, PSSession, PSExec`n`n
"@ })
$Section3ActionTab.Controls.Add($ProvideCredsButton)

$Column5DownPosition += $Column5DownPositionShift - 2

#============================================================================================================================================================
# Computer List - Provide Creds Checkbox
#============================================================================================================================================================

$ComputerListProvideCredentialsCheckBox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Alternate Credentials"
    Location = @{ X = $Column5RightPosition + 1
                  Y = $Column5DownPosition }
    Size     = @{ Width  = $Column5BoxWidth
                  Height = $Column5BoxHeight - 5 }
    Checked  = $false
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$ComputerListProvideCredentialsCheckBox.Add_MouseHover({
    ToolTipFunction -Title "Use Alternate Credentials" -Icon "Info" -Message @"
⦿ Credentials are stored as a SecureString.
⦿ If checked, credentials are applied to:
     RDP, PSSession, PSExec`n`n
"@ })
$Section3ActionTab.Controls.Add($ComputerListProvideCredentialsCheckBox)

$Column5DownPosition += $Column5DownPositionShift + 2

#============================================================================================================================================================
# Execute Button
#============================================================================================================================================================
$ComputerListExecuteButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "Start`nCollection"
    Location  = @{ X = $Column5RightPosition
                   Y = $Column5DownPosition  }
    Size      = @{ Width  = $Column5BoxWidth
                   Height = ($Column5BoxHeight * 2) - 10 }
    #UseVisualStyleBackColor = $True
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Red"
}
$ComputerListExecuteButton.Add_MouseHover({
    ToolTipFunction -Title "Start Collection" -Icon "Info" -Message @"
⦿ Starts the collection process.
⦿ All checked commands are executed against all checked hosts.
⦿ Be sure to verify selections before execution.
⦿ All queries to targets are logged with timestamps.
⦿ Results are stored in CSV format.`n`n
"@ })
### $ComputerListExecuteButton.Add_Click($ExecuteScriptHandler) ### Is located lower in the script
$Section3ActionTab.Controls.Add($ComputerListExecuteButton)

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
    Text      = "Manage List"
    Location  = @{ X = $Column5RightPosition
                   Y = $Column5DownPosition }
    Size      = @{ Width  = $Column5BoxWidth
                   Height = $Column5BoxHeight }
    UseVisualStyleBackColor = $True
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$Section3TabControl.Controls.Add($Section3ManageListTab)

$Column5DownPosition = $Column5DownPositionStart

Function Update-NeedToSaveTreeView {
    $ComputerListTreeViewSaveButton.Text      = "Save`nTreeView"
    $ComputerListTreeViewSaveButton.Font      = New-Object System.Drawing.Font("$Font",12,0,0,0)
    $ComputerListTreeViewSaveButton.ForeColor = "Red"
}
#============================================================================================================================================================
# Computer List - Treeview - Deselect All Button
#============================================================================================================================================================
$ComputerListDeselectAllButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = 'Deselect All'
    Location = @{ X = $Column5RightPosition
                  Y = $Column5DownPosition }
    Size     = @{ Width  = $Column5BoxWidth
                  Height = $Column5BoxHeight }
}
$ComputerListDeselectAllButton.Add_Click({   
    #$script:ComputerListTreeView.Nodes.Clear()
    [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerListTreeView.Nodes 
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
    Conduct-NodeAction -TreeView $script:ComputerListTreeView.Nodes -ComputerList
})
$ComputerListDeselectAllButton.Font = New-Object System.Drawing.Font("$Font",11,0,0,0)
$Section3ManageListTab.Controls.Add($ComputerListDeselectAllButton) 

$Column5DownPosition += $Column5DownPositionShift

#============================================================================================================================================================
# Computer List - Treeview - Collapse / Expand Button
#============================================================================================================================================================
$ComputerListTreeViewCollapseAllButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Collapse"
    Location = @{ X = $Column5RightPosition
                  Y = $Column5DownPosition }
    Size     = @{ Width  = $Column5BoxWidth
                  Height = $Column5BoxHeight }
}
$ComputerListTreeViewCollapseAllButton.Add_Click({
    if ($ComputerListTreeViewCollapseAllButton.Text -eq "Collapse") {
        $script:ComputerListTreeView.CollapseAll()
        [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerListTreeView.Nodes 
        foreach ($root in $AllHostsNode) { 
            $root.Expand()
        }
        $ComputerListTreeViewCollapseAllButton.Text = "Expand"
    }
    elseif ($ComputerListTreeViewCollapseAllButton.Text -eq "Expand") {
        $script:ComputerListTreeView.ExpandAll()
        $ComputerListTreeViewCollapseAllButton.Text = "Collapse"
    }

})
$ComputerListTreeViewCollapseAllButton.Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
$Section3ManageListTab.Controls.Add($ComputerListTreeViewCollapseAllButton) 

$Column5DownPosition += $Column5DownPositionShift

#============================================================================================================================================================
# ComputerList TreeView - Import From Active Directory Button
#============================================================================================================================================================
$ComputerListTreeViewImportFromActiveDirectoryButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "Import from AD"
    Location  = @{ X = $Column5RightPosition
                   Y = $Column5DownPosition }
    Size      = @{ Width  = $Column5BoxWidth
                   Height = $Column5BoxHeight }
    UseVisualStyleBackColor = $True
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Green"
}
$ComputerListTreeViewImportFromActiveDirectoryButton.Add_Click({
    # This brings specific tabs to the forefront/front view
    $Section4TabControl.SelectedTab   = $Section3ResultsTab
    
    Create-ComputerNodeCheckBoxArray    
    if ($script:SingleHostIPCheckBox.Checked -eq $true) {
        if ($ComputerListProvideCredentialsCheckBox.Checked) {
            if (!$script:Credential) { $script:Credential = Get-Credential }
            $Username = $script:Credential.UserName
            $Password = '"PASSWORD HIDDEN"'
            
            $ImportedActiveDirectoryHosts = Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, OperatingSystem, CanonicalName, IPv4Address, MACAddress } -ComputerName "$($script:SingleHostIPTextBox.Text)" -Credential $script:Credential
            $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, OperatingSystem, CanonicalName, IPv4Address, MACAddress } -ComputerName $($script:SingleHostIPTextBox.Text) -Credential [ $UserName | $Password ]"
            $LogMessage | Add-Content -Path $LogFile
        }
        else {
            $ImportedActiveDirectoryHosts = Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, OperatingSystem, CanonicalName, IPv4Address, MACAddress } -ComputerName "$($script:SingleHostIPTextBox.Text)"
            $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, OperatingSystem, CanonicalName, IPv4Address, MACAddress } -ComputerName $($script:SingleHostIPTextBox.Text)"
            $LogMessage | Add-Content -Path $LogFile
        }
        $script:SingleHostIPCheckBox.Checked   = $false
        $script:SingleHostIPTextBox.Text       = $DefaultSingleHostIPText
        $script:ComputerListTreeView.Enabled   = $true
        $script:ComputerListTreeView.BackColor = "white"

        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Importing Hosts")
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Importing hosts from Active Directory")
        $ResultsListBox.Items.Add("Make sure to select a domain server to import from")
        $ResultsListBox.Items.Add("")
        Start-Sleep -Seconds 1
        Update-NeedToSaveTreeView
    }
    elseif ($script:ComputerListCheckedBoxesSelected.count -eq 1) {
        if ($ComputerListProvideCredentialsCheckBox.Checked) {
            if (!$script:Credential) { $script:Credential = Get-Credential }
            $Username = $script:Credential.UserName
            $Password = '"PASSWORD HIDDEN"'

            $ImportedActiveDirectoryHosts = Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, OperatingSystem, CanonicalName, IPv4Address, MACAddress } -ComputerName $script:ComputerListCheckedBoxesSelected -Credential $script:Credential
            $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, OperatingSystem, CanonicalName, IPv4Address, MACAddress } -ComputerName $script:ComputerListCheckedBoxesSelected -Credential [ $UserName | $Password ]"
            $LogMessage | Add-Content -Path $LogFile
        }
        else {
            $ImportedActiveDirectoryHosts = Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, OperatingSystem, CanonicalName, IPv4Address, MACAddress } -ComputerName $script:ComputerListCheckedBoxesSelected
            $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  Invoke-Command -ScriptBlock { Get-ADComputer -Filter * -Properties Name, OperatingSystem, CanonicalName, IPv4Address, MACAddress } -ComputerName $script:ComputerListCheckedBoxesSelected"
            $LogMessage | Add-Content -Path $LogFile
        }
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Importing Hosts")
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Importing hosts from Active Directory")
        $ResultsListBox.Items.Add("Make sure to select a domain server to import from")
        $ResultsListBox.Items.Add("")
        Start-Sleep -Seconds 1
        Update-NeedToSaveTreeView
    }
    elseif ($script:ComputerListCheckedBoxesSelected.count -lt 1) { ComputerNodeSelectedLessThanOne -Message 'Importing Hosts' }
    elseif ($script:ComputerListCheckedBoxesSelected.count -gt 1) { ComputerNodeSelectedMoreThanOne -Message 'Importing Hosts' }
    
    # Imports data
    foreach ($Computer in $ImportedActiveDirectoryHosts) {
        # Checks if data already exists
        if ($script:ComputerListTreeViewData.Name -contains $Computer.Name) {
            Message-HostAlreadyExists -Message "Importing Hosts:  Warning"
        }
        else {
            if ($ComputerListTreeViewOSHostnameRadioButton.Checked) {
                if ($Computer.OperatingSystem -eq "") { Add-ComputerNode -RootNode $script:TreeNodeComputerList -Category 'Unknown' -Entry $Computer.Name -ToolTip $Computer.IPv4Address }
                else { Add-ComputerNode -RootNode $script:TreeNodeComputerList -Category $Computer.OperatingSystem -Entry $Computer.Name -ToolTip $Computer.IPv4Address }
            }
            elseif ($ComputerListTreeViewOUHostnameRadioButton.Checked) {
                $CanonicalName = $($($Computer.CanonicalName) -replace $Computer.Name,"" -replace $Computer.CanonicalName.split('/')[0],"").TrimEnd("/")
                if ($Computer.CanonicalName -eq "") { Add-ComputerNode -RootNode $script:TreeNodeComputerList -Category '/Unknown' -Entry $Computer.Name -ToolTip $Computer.IPv4Address }
                else { Add-ComputerNode -RootNode $script:TreeNodeComputerList -Category $CanonicalName -Entry $Computer.Name -ToolTip $Computer.IPv4Address }
            }
            $script:ComputerListTreeViewData += $Computer
        }
    }
    if ($ComputerListTreeViewOSHostnameRadioButton.Checked) {
        Foreach($Computer in $script:ComputerListTreeViewData) { Add-ComputerNode -RootNode $script:TreeNodeComputerList -Category $Computer.OperatingSystem -Entry $Computer.Name -ToolTip $Computer.IPv4Address }    
    }
    elseif ($ComputerListTreeViewOUHostnameRadioButton.Checked) {
        Foreach($Computer in $script:ComputerListTreeViewData) { Add-ComputerNode -RootNode $script:TreeNodeComputerList -Category $Computer.CanonicalName -Entry $Computer.Name -ToolTip $Computer.IPv4Address }
    }
    $script:ComputerListTreeView.Nodes.Clear()
    Initialize-ComputerListTreeView
    Keep-ComputerListCheckboxesChecked -NoMessage
    Populate-ComputerListTreeViewDefaultData
    Foreach($Computer in $script:ComputerListTreeViewData) { Add-ComputerNode -RootNode $script:TreeNodeComputerList -Category $Computer.CanonicalName -Entry $Computer.Name -ToolTip $Computer.IPv4Address }
    $script:ComputerListTreeView.ExpandAll()
    AutoSave-HostData
    Update-NeedToSaveTreeView
})
$Section3ManageListTab.Controls.Add($ComputerListTreeViewImportFromActiveDirectoryButton)

$Column5DownPosition += $Column5DownPositionShift

#============================================================================================================================================================
# ComputerList TreeView - Import .csv Button
#============================================================================================================================================================
$ComputerListTreeViewImportCsvButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "Import from .CSV"
    Location  = @{ X = $Column5RightPosition
                   Y = $Column5DownPosition }
    Size      = @{ Width  = $Column5BoxWidth
                   Height = $Column5BoxHeight }
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
    $ComputerListTreeViewImportCsv = Import-Csv $($ComputerListTreeViewImportCsvOpenFileDialog.filename) | Select-Object -Property Name, IPv4Address, MACAddress, OperatingSystem, CanonicalName | Sort-Object -Property CanonicalName

    $StatusListBox.Items.Clear()
    $ResultsListBox.Items.Clear()
    
    # Imports data
    foreach ($Computer in $ComputerListTreeViewImportCsv) {
        # Checks if data already exists
        if ($script:ComputerListTreeViewData.Name -contains $Computer.Name) {
            Message-HostAlreadyExists -Message "Import .CSV:  Warning"
        }
        else {
            if ($ComputerListTreeViewOSHostnameRadioButton.Checked) {
                if ($Computer.OperatingSystem -eq "") { Add-ComputerNode -RootNode $script:TreeNodeComputerList -Category 'Unknown' -Entry $Computer.Name -ToolTip $Computer.IPv4Address }
                else { Add-ComputerNode -RootNode $script:TreeNodeComputerList -Category $Computer.OperatingSystem -Entry $Computer.Name -ToolTip $Computer.IPv4Address }
            }
            elseif ($ComputerListTreeViewOUHostnameRadioButton.Checked) {
                $CanonicalName = $($($Computer.CanonicalName) -replace $Computer.Name,"" -replace $Computer.CanonicalName.split('/')[0],"").TrimEnd("/")
                if ($Computer.CanonicalName -eq "") { Add-ComputerNode -RootNode $script:TreeNodeComputerList -Category '/Unknown' -Entry $Computer.Name -ToolTip $Computer.IPv4Address }
                else { Add-ComputerNode -RootNode $script:TreeNodeComputerList -Category $CanonicalName -Entry $Computer.Name -ToolTip $Computer.IPv4Address }
            }
            $script:ComputerListTreeViewData += $Computer

            $script:ComputerListTreeView.Nodes.Clear()
            Initialize-ComputerListTreeView
            Keep-ComputerListCheckboxesChecked -NoMessage
            Populate-ComputerListTreeViewDefaultData
            Foreach($Computer in $script:ComputerListTreeViewData) { Add-ComputerNode -RootNode $script:TreeNodeComputerList -Category $Computer.CanonicalName -Entry $Computer.Name -ToolTip $Computer.IPv4Address }
            $script:ComputerListTreeView.ExpandAll()
            AutoSave-HostData
            Update-NeedToSaveTreeView
        }
    }
})
$Section3ManageListTab.Controls.Add($ComputerListTreeViewImportCsvButton)

$Column5DownPosition += $Column5DownPositionShift

#============================================================================================================================================================
# ComputerList TreeView - Import .txt Button
#============================================================================================================================================================
$ComputerListTreeViewImportTxtButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "Import from .TXT"
    Location  = @{ X = $Column5RightPosition
                   Y = $Column5DownPosition }
    Size      = @{ Width  = $Column5BoxWidth
                   Height = $Column5BoxHeight }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Green"
    UseVisualStyleBackColor = $True
}
$ComputerListTreeViewImportTxtButton.Add_Click({
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    $ComputerListTreeViewImportTxtOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{
        Title            = "Import .txt Data"
        InitialDirectory = "$PoShHome"
        filter           = "TXT (*.txt)| *.txt|All files (*.*)|*.*"
        ShowHelp         = $true
    }
    $ComputerListTreeViewImportTxtOpenFileDialog.ShowDialog() | Out-Null    
    $ComputerListTreeViewImportTxt = Get-Content $($ComputerListTreeViewImportTxtOpenFileDialog.filename)

    $StatusListBox.Items.Clear()
    $ResultsListBox.Items.Clear()

    foreach ($Computer in $ComputerListTreeViewImportTxt) {
        # Checks if the data already exists
        if ($script:ComputerListTreeViewData.Name -contains $Computer) {
            Message-HostAlreadyExists -Message "Import .CSV:  Warning"
        }
        else {
            if ($ComputerListTreeViewOSHostnameRadioButton.Checked -and $Computer -ne "") {
                Add-ComputerNode -RootNode $script:TreeNodeComputerList -Category 'Unknown' -Entry $Computer -ToolTip 'N/A'
            }
            elseif ($ComputerListTreeViewOUHostnameRadioButton.Checked -and $Computer -ne "") {
                Add-ComputerNode -RootNode $script:TreeNodeComputerList -Category '/Unknown' -Entry $Computer -ToolTip 'N/A'
            }
            $script:ComputerListTreeViewData += [PSCustomObject]@{
                Name            = $Computer
                OperatingSystem = 'Unknown'
                CanonicalName   = '/Unknown'
                IPv4Address     = 'N/A'
                MACAddress      = 'N/A'
            }
            $script:ComputerListTreeView.Nodes.Clear()
            Initialize-ComputerListTreeView
            Keep-ComputerListCheckboxesChecked -NoMessage
            Populate-ComputerListTreeViewDefaultData
            Foreach($Computer in $script:ComputerListTreeViewData) { Add-ComputerNode -RootNode $script:TreeNodeComputerList -Category $Computer.CanonicalName -Entry $Computer.Name -ToolTip $Computer.IPv4Address }
            $script:ComputerListTreeView.ExpandAll()
            AutoSave-HostData
            Update-NeedToSaveTreeView
        }
    }
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
        [system.media.systemsounds]::Exclamation.play()
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Add Hostname/IP:  Error")
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Error:  Enter a suitable non-default value")
    }
    elseif ($script:ComputerListTreeViewData.Name -contains $ComputerListTreeViewPopupAddTextBox.Text) {
        Message-HostAlreadyExists -Message "Add Hostname/IP:  Error"
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
        $script:ComputerListTreeView.ExpandAll()
        $ComputerListTreeViewPopup.close()
        Keep-ComputerListCheckboxesChecked -NoMessage
        Update-NeedToSaveTreeView
    }
}

#----------------------------------
# ComputerList TreeView Add Button
#----------------------------------
$ComputerListTreeViewAddHostnameIPButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "Add"
    Location = @{ X = $Column5RightPosition
                  Y = $Column5DownPosition }
    Size     = @{ Width  = $Column5BoxWidth
                  Height = $Column5BoxHeight }
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
        Location = @{ X = 10
                      Y = 10 }
        Size     = @{ Width  = 300
                      Height = 25 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $ComputerListTreeViewPopupAddTextBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { AddHost-ComputerListTreeView } })
    $ComputerListTreeViewPopup.Controls.Add($ComputerListTreeViewPopupAddTextBox)

    #-----------------------------------------
    # ComputerList TreeView Popup OS ComboBox
    #-----------------------------------------
    $ComputerListTreeViewPopupOSComboBox  = New-Object System.Windows.Forms.ComboBox -Property @{
        Text     = "Select an Operating System (or type in a new one)"
        Location = @{ X = 10
                      Y = $ComputerListTreeViewPopupAddTextBox.Location.Y + $ComputerListTreeViewPopupAddTextBox.Size.Height + 10 }
        Size     = @{ Width  = 300
                      Height = 25 }
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
        Text     = "Select an Organizational Unit / Canonical Name (or type a new one)"
        Location = @{ X = 10
                      Y = $ComputerListTreeViewPopupOSComboBox.Location.Y + $ComputerListTreeViewPopupOSComboBox.Size.Height + 10 }
        Size     = @{ Width  = 300
                      Height = 25 }
        AutoCompleteSource = "ListItems" # Options are: FileSystem, HistoryList, RecentlyUsedList, AllURL, AllSystemSources, FileSystemDirectories, CustomSource, ListItems, None
        AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
        Font               = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $ComputerListTreeViewOUCategoryList = $script:ComputerListTreeViewData | Select-Object -ExpandProperty CanonicalName -Unique
    # Dynamically creates the OU Category combobox list used for OU Selection
    ForEach ($OU in $ComputerListTreeViewOUCategoryList) { $ComputerListTreeViewPopupOUComboBox.Items.Add($OU) }
    $ComputerListTreeViewPopupOUComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { AddHost-ComputerListTreeView } })
    $ComputerListTreeViewPopup.Controls.Add($ComputerListTreeViewPopupOUComboBox)

    #---------------------------------------------
    # ComputerList TreeView Popup Add Host Button
    #---------------------------------------------
    $ComputerListTreeViewPopupAddHostButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Add Host"
        Location = @{ X = 210
                      Y = $ComputerListTreeViewPopupOUComboBox.Location.Y + $ComputerListTreeViewPopupOUComboBox.Size.Height + 10 }
        Size     = @{ Width  = 100
                      Height = 25 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $ComputerListTreeViewPopupAddHostButton.Add_Click({ AddHost-ComputerListTreeView })
    $ComputerListTreeViewPopupAddHostButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { AddHost-ComputerListTreeView } })    
    $ComputerListTreeViewPopup.Controls.Add($ComputerListTreeViewPopupAddHostButton)

    $script:ComputerListTreeView.ExpandAll()
    Populate-ComputerListTreeViewDefaultData
    AutoSave-HostData
    $ComputerListTreeViewPopup.ShowDialog()               
})
$Section3ManageListTab.Controls.Add($ComputerListTreeViewAddHostnameIPButton) 

$Column5DownPosition += $Column5DownPositionShift

#============================================================================================================================================================
# Computer List - Treeview - Delete Button
#============================================================================================================================================================

$ComputerListDeleteButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Delete"
    Location = @{ X = $Column5RightPosition
                  Y = $Column5DownPosition }
    Size     = @{ Width  = $Column5BoxWidth
                  Height = $Column5BoxHeight }
}
$ComputerListDeleteButton.Add_Click({
    # This brings specific tabs to the forefront/front view
    $Section4TabControl.SelectedTab = $Section3ResultsTab

    Create-ComputerNodeCheckBoxArray 
    if ($script:ComputerListCheckedBoxesSelected.count -gt 0) {
        # Removes selected computer nodes
        foreach ($i in $script:ComputerListCheckedBoxesSelected) {
            [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerListTreeView.Nodes 
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
        foreach ($i in $script:ComputerListCheckedBoxesSelected) {
            foreach ($root in $AllHostsNode) {
                foreach ($Category in $root.Nodes) { 
                    if (($i -eq $Category.text) -and ($Category.Checked)) { $Category.remove() }
                }
            }
        }
        # Removes selected root node - Note: had to put this in its own loop... see above category note
        foreach ($i in $script:ComputerListCheckedBoxesSelected) {
            foreach ($root in $AllHostsNode) {                
                if (($i -eq $root.text) -and ($root.Checked)) {
                    foreach ($Category in $root.Nodes) { $Category.remove() }
                    $root.remove()
                    if ($i -eq "All Hosts") { $script:ComputerListTreeView.Nodes.Add($script:TreeNodeComputerList) }                                    
                }
            }
        }

        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Deleted:  $($script:ComputerListCheckedBoxesSelected.Count) Selected Items")
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("The following hosts have been deleted:  ")
        $ComputerListDeletedArray = @()
        foreach ($Node in $script:ComputerListCheckedBoxesSelected) { 
            if ($Node -notin $ComputerListDeletedArray) {
                $ComputerListDeletedArray += $Node
                $ResultsListBox.Items.Add(" - $Node") 
            }
        }
        $script:ComputerListTreeView.Nodes.Clear()
        Initialize-ComputerListTreeView
        Foreach($Computer in $script:ComputerListTreeViewData) { Add-ComputerNode -RootNode $script:TreeNodeComputerList -Category $Computer.CanonicalName -Entry $Computer.Name -ToolTip $Computer.IPv4Address }
        Keep-ComputerListCheckboxesChecked -NoMessage
        $script:ComputerListTreeView.ExpandAll()
        AutoSave-HostData
        Update-NeedToSaveTreeView
    } # END if statement
    else { ComputerNodeSelectedLessThanOne -Message 'Delete Selection' }
})
$ComputerListDeleteButton.Font = New-Object System.Drawing.Font("$Font",11,0,0,0)
$Section3ManageListTab.Controls.Add($ComputerListDeleteButton) 

$Column5DownPosition += $Column5DownPositionShift

#============================================================================================================================================================
# Computer List - Treeview - Move Button
#============================================================================================================================================================
$ComputerListMoveButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = 'Move'
    Location = @{ X = $Column5RightPosition
                  Y = $Column5DownPosition }
    Size     = @{ Width  = $Column5BoxWidth
                  Height = $Column5BoxHeight }
}
$ComputerListMoveButton.Add_Click({
    # This brings specific tabs to the forefront/front view
    $Section4TabControl.SelectedTab   = $Section3ResultsTab
    
    Create-ComputerNodeCheckBoxArray 
    if ($script:ComputerListCheckedBoxesSelected.count -ge 1) {
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
        $ComputerListTreeViewPopupMoveComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
            Text     = "Select A Category"
            Location = @{ X = 10
                          Y = 10 }
            Size     = @{ Width  = 300
                          Height = 25 }
            AutoCompleteSource = "ListItems" # Options are: FileSystem, HistoryList, RecentlyUsedList, AllURL, AllSystemSources, FileSystemDirectories, CustomSource, ListItems, None
            AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
            Font               = New-Object System.Drawing.Font("$Font",11,0,0,0)
        }
        # Dynamically creates the combobox's Category list used for the move destination
        $ComputerListTreeViewCategoryList = @()
        [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerListTreeView.Nodes 
        ForEach ($root in $AllHostsNode) { foreach ($Category in $root.Nodes) { $ComputerListTreeViewCategoryList += $Category.text } }
        ForEach ($Item in $ComputerListTreeViewCategoryList) { $ComputerListTreeViewPopupMoveComboBox.Items.Add($Item) }

        # Moves the checkboxed nodes to the selected Category
        function Move-ComputerListTreeViewSelected {                       
            # Makes a copy of the checkboxed node name in the new Category
            $ComputerListTreeViewToMove = New-Object System.Collections.ArrayList

            function Copy-TreeViewNode {
                # Adds (copies) the node to the new Category
                [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerListTreeView.Nodes 
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
                Update-NeedToSaveTreeView
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
            Check-CategoryIsEmpty
            $ComputerListTreeViewPopup.close()        
        }
        # Moves the hostname/IPs to the new Category
        $ComputerListTreeViewPopupMoveComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { Move-ComputerListTreeViewSelected } })
        $ComputerListTreeViewPopup.Controls.Add($ComputerListTreeViewPopupMoveComboBox)

        #--------------------------------------------
        # ComputerList TreeView Popup Execute Button
        #--------------------------------------------
        $ComputerListTreeViewPopupExecuteButton = New-Object System.Windows.Forms.Button -Property @{
            Text     = "Execute"
            Location = @{ X = 210
                          Y = $ComputerListTreeViewPopupMoveComboBox.Size.Height + 15 }
            Size     = @{ Width  = 100
                          Height = 25 }
            Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        }
        $ComputerListTreeViewPopupExecuteButton.Add_Click({ 
            # This brings specific tabs to the forefront/front view
            $Section4TabControl.SelectedTab   = $Section3ResultsTab
            Move-ComputerListTreeViewSelected 
        })
        $ComputerListTreeViewPopup.Controls.Add($ComputerListTreeViewPopupExecuteButton)
        $ComputerListTreeViewPopup.ShowDialog()               

        $script:ComputerListTreeView.Nodes.Clear()
        Initialize-ComputerListTreeView
        AutoSave-HostData
        if ($ComputerListTreeViewOSHostnameRadioButton.Checked) {
            Foreach($Computer in $script:ComputerListTreeViewData) { Add-ComputerNode -RootNode $script:TreeNodeComputerList -Category $Computer.OperatingSystem -Entry $Computer.Name -ToolTip $Computer.IPv4Address }    
        }
        elseif ($ComputerListTreeViewOUHostnameRadioButton.Checked) {
            Foreach($Computer in $script:ComputerListTreeViewData) { Add-ComputerNode -RootNode $script:TreeNodeComputerList -Category $Computer.CanonicalName -Entry $Computer.Name -ToolTip $Computer.IPv4Address }
        }
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Move Selection:  $($ComputerListTreeViewToMove.Count) Hosts")
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("The following hostnames/IPs have been moved to $($ComputerListTreeViewPopupMoveComboBox.SelectedItem):")
        Keep-ComputerListCheckboxesChecked -NoMessage
    }
    else { ComputerNodeSelectedLessThanOne -Message 'Move Selection' }

})
$ComputerListMoveButton.Font = New-Object System.Drawing.Font("$Font",11,0,0,0)
$Section3ManageListTab.Controls.Add($ComputerListMoveButton) 

$Column5DownPosition += $Column5DownPositionShift

#============================================================================================================================================================
# Computer List - Treeview - Rename Button
#============================================================================================================================================================
$ComputerListRenameButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = 'Rename'
    Location = @{ X = $Column5RightPosition
                  Y = $Column5DownPosition }
    Size     = @{ Width  = $Column5BoxWidth
                  Height = $Column5BoxHeight }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$ComputerListRenameButton.Add_Click({
    # This brings specific tabs to the forefront/front view
    $Section4TabControl.SelectedTab   = $Section3ResultsTab

    Create-ComputerNodeCheckBoxArray 
    if ($script:ComputerListCheckedBoxesSelected.count -eq 1) {
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
                Message-HostAlreadyExists -Message "Rename Hostname/IP:  Error"
            }
            else {
                # Makes a copy of the checkboxed node name in the new Category
                $ComputerListTreeViewToRename = New-Object System.Collections.ArrayList

                # Adds (copies) the node to the new Category
                [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerListTreeView.Nodes 
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
                Update-NeedToSaveTreeView
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
        $ComputerListTreeViewRenamePopupButton = New-Object System.Windows.Forms.Button -Property @{
            Text     = "Execute"
            Location = @{ X = 210
                          Y = $Column5DownPosition }
            Size     = @{ Width  = 100
                          Height = $ComputerListTreeViewRenamePopupTextBox.Size.Height + 15 }
            Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        }
        $ComputerListTreeViewRenamePopupButton.Add_Click({ Rename-ComputerListTreeViewSelected })
        $ComputerListTreeViewRenamePopup.Controls.Add($ComputerListTreeViewRenamePopupButton)

        $ComputerListTreeViewRenamePopup.ShowDialog()               
    }
    elseif ($script:ComputerListCheckedBoxesSelected.count -lt 1) { ComputerNodeSelectedLessThanOne -Message 'Rename Selection' }
    elseif ($script:ComputerListCheckedBoxesSelected.count -gt 1) { ComputerNodeSelectedMoreThanOne -Message 'Rename Selection' }
    AutoSave-HostData
})
$Section3ManageListTab.Controls.Add($ComputerListRenameButton) 

$Column5DownPosition += $Column5DownPositionShift

#============================================================================================================================================================
# Computer List - TreeView - Mass Tag
#============================================================================================================================================================
$script:ComputerListMassTagValue = ''
#---------------------------------------------------------------------
# function to Mass Tgg one or multiple hosts in the computer treeview
#---------------------------------------------------------------------
function MassTag-ComputerListTreeView {    
    Create-ComputerNodeCheckBoxArray 
    $Section4TabControl.SelectedTab = $Section3HostDataTab

    if ($script:ComputerListCheckedBoxesSelected.count -ge 1) {
        $ComputerListMassTagForm = New-Object System.Windows.Forms.Form -Property @{
            Text = "Mass Tag"
            Size     = @{ Width  = 350
                          Height = 115 }
            StartPosition = "CenterScreen"
            Font = New-Object System.Drawing.Font('Courier New',11,0,0,0)

        }
        $ComputerListMassTagForm | select *
        $ComputerListMassTagNewTagNameLabel = New-Object System.Windows.Forms.Label -Property @{
            Text     = "Mass Tag Name:"
            Location = @{ X = 5
                          Y = 14}
            Size     = @{ Width  = 100
                          Height = 25 }
        }
        $ComputerListMassTagNewTagNameComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
            Text     = ""
            Location = @{ X = $ComputerListMassTagNewTagNameLabel.Location.X + $ComputerListMassTagNewTagNameLabel.Size.Width + 5
                          Y = 10 }
            Size     = @{ Width  = 215
                          Height = 25 }
            AutoCompleteSource = "ListItems" # Options are: FileSystem, HistoryList, RecentlyUsedList, AllURL, AllSystemSources, FileSystemDirectories, CustomSource, ListItems, None
            AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
            #DataSource         = $ArrayIfNotAddedWIth .Items.Add
        }
        #$TagListFileContents = Get-Content -Path $TagAutoListFile
        ForEach ($Tag in $TagListFileContents) { $ComputerListMassTagNewTagNameComboBox.Items.Add($Tag) }
        $ComputerListMassTagNewTagNameComboBox.Add_KeyDown({ 
            if ($_.KeyCode -eq "Enter" -and $ComputerListMassTagNewTagNameComboBox.text -ne '') {
                $script:ComputerListMassTagValue = $ComputerListMassTagNewTagNameComboBox.text
                $ComputerListMassTagForm.Close()
            }
        })
        $ComputerListMassTagNewTagNameButton = New-Object System.Windows.Forms.Button -Property @{
            Text     = "Apply Tag"
            Location = @{ X = $ComputerListMassTagNewTagNameLabel.Location.X + 104
                          Y = $ComputerListMassTagNewTagNameLabel.Location.Y + $ComputerListMassTagNewTagNameLabel.Size.Height + 2 }
            Size     = @{ Width  = 100
                          Height = 25 }
        }
        $ComputerListMassTagNewTagNameButton.Add_Click({ 
            if ($ComputerListMassTagNewTagNameComboBox.text -ne '') {
                $script:ComputerListMassTagValue = $ComputerListMassTagNewTagNameComboBox.text
                $ComputerListMassTagForm.Close()
            }
        })
        $ComputerListMassTagForm.Controls.AddRange(@($ComputerListMassTagNewTagNameLabel,$ComputerListMassTagNewTagNameComboBox,$ComputerListMassTagNewTagNameButton))
        $ComputerListMassTagForm.Add_Shown({$ComputerListMassTagForm.Activate()})
        $ComputerListMassTagForm.ShowDialog()

        $ComputerListMassTageArray = @()
        foreach ($node in $script:ComputerListCheckedBoxesSelected) {    
            [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerListTreeView.Nodes
            foreach ($root in $AllHostsNode) {
                foreach ($Category in $root.Nodes) { 
                    foreach ($Entry in $Category.Nodes) {
                        if ($Entry.Checked -and $Entry.Text -notin $ComputerListMassTageArray) {
                            $ComputerListMassTageArray += $Entry.Text
                            $Section4TabControl.SelectedTab = $Section3HostDataTab
                            $Section3HostDataName.Text = $($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).Name
                            $Section3HostDataOS.Text   = $($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).OperatingSystem
                            $Section3HostDataOU.Text   = $($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).CanonicalName
                            $Section3HostDataIP.Text   = $($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).IPv4Address
                            $Section3HostDataMAC.Text  = $($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).MACAddress
                            $Section3HostDataNotes.Text = "[$($script:ComputerListMassTagValue)] " + $($script:ComputerListTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).Notes
                        }
                        Save-ComputerListHostData
                        Check-HostDataIfModified
                    }
                }
            }  
        }
        $StatusListBox.Items.clear()
        $StatusListBox.Items.Add("Mass Tag Complete: $($script:ComputerListCheckedBoxesSelected.count) Endpoints")
        $ResultsListBox.Items.Clear()
    }
}

$ComputerListTreeViewMassTagButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Mass Tag"
    Location = @{ X = $Column5RightPosition
                  Y = $Column5DownPosition }
    Size     = @{ Width  = $Column5BoxWidth
                  Height = $Column5BoxHeight }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$ComputerListTreeViewMassTagButton.Add_Click({
    MassTag-ComputerListTreeView
    #Update-NeedToSaveTreeView
})
$Section3ManageListTab.Controls.Add($ComputerListTreeViewMassTagButton) 

$Column5DownPosition += $Column5DownPositionShift

#============================================================================================================================================================
# Computer List - TreeView - Save Button
#============================================================================================================================================================
$ComputerListTreeViewSaveButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "TreeView`nSaved"
    Location = @{ X = $Column5RightPosition
                  Y = $Column5DownPosition }
    Size     = @{ Width  = $Column5BoxWidth
                  Height = ($Column5BoxHeight * 2) - 10 }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Green"
    UseVisualStyleBackColor = $True
}
$ComputerListTreeViewSaveButton.Add_Click({ 
    Save-HostData
    $ComputerListTreeViewSaveButton.Text      = "TreeView`nSaved"
    $ComputerListTreeViewSaveButton.Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    $ComputerListTreeViewSaveButton.ForeColor = "Green"
})
$ComputerListTreeViewSaveButton.Add_MouseHover({
    ToolTipFunction -Title "Start Collection" -Icon "Warning" -Message @"
⦿ Saves changes made to the Computer TreeView and their data
⦿ Once saved, the data is loaded automatically upon PoSh-ACME startup
⦿ Location: "$ComputerListTreeViewFileSave"

⦿ Autosaves are made immedately when changes are made
⦿ Autosaves are not loaded upon PoSh-ACME reload, use 'Import .CSV'
⦿ Location: "$ComputerListTreeViewFileAutoSave"`n`n 
"@ })
$Section3ManageListTab.Controls.Add($ComputerListTreeViewSaveButton)

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
$Section3ResultsTabWidth   = 752
$Section3ResultsTabHeight  = 250

$Section3DownPosition += $Section3DownPositionShift
$Section3DownPosition += $Section3DownPositionShift

#--------------
# Status Label
#--------------
$StatusLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "Status:"
    Location = @{ X = $Section3RightPosition
                  Y = $Section3DownPosition + 1 }
    Size     = @{ Width  = 60
                  Height = $Section3ProgressBarHeight - 2 }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Blue"
}
$PoShACME.Controls.Add($StatusLabel)  

#----------------
# Status Listbox
#----------------
$StatusListBox = New-Object System.Windows.Forms.ListBox -Property @{
    Name     = "StatusListBox"
    Location = @{ X = $Section3RightPosition + 60
                  Y = $Section3DownPosition }
    Size     = @{ Width  = $Section3ProgressBarWidth
                  Height = $Section3ProgressBarHeight }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    FormattingEnabled = $True
}
$StatusListBox.Items.Add("") | Out-Null
$PoShACME.Controls.Add($StatusListBox)

$Section3DownPosition += $Section3DownPositionShift

# ---------------------
# Progress Bar 1 Label
#----------------------
$ProgressBarEndpointsLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "Endpoint:"
    Location = @{ X = $Section3RightPosition
                  Y = $Section3DownPosition - 4 }
    Size     = @{ Width  = 60
                  Height = $Section3ProgressBarHeight - 7 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$PoShACME.Controls.Add($ProgressBarEndpointsLabel)  

#----------------------------
# Progress Bar 1 ProgressBar
#----------------------------
$ProgressBarEndpointsProgressBar = New-Object System.Windows.Forms.ProgressBar -Property @{
    Style    = "Continuous"
    #Maximum = 10
    Minimum  = 0
    Location = @{ X = $Section3RightPosition + 60
                  Y = $Section3DownPosition - 2 }
    Size     = @{ Width  = $Section3ProgressBarWidth
                  Height = 10 }
    #Value   = 0
    #Step    = 1
}
$PoSHACME.Controls.Add($ProgressBarEndpointsProgressBar)

$Section3DownPosition += $Section3DownPositionShift - 9

#----------------------
# Progress Bar 2 Label
#----------------------
$ProgressBarQueriesLabel = New-Object System.Windows.Forms.Label -Property @{
    Text     = "Query:"
    Location = @{ X = $Section3RightPosition
                  Y = $Section3DownPosition - 4 }
    Size     = @{ Width  = 60
                  Height = $Section3ProgressBarHeight - 4 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$PoShACME.Controls.Add($ProgressBarQueriesLabel)  

#----------------------------
# Progress Bar 2 ProgressBar
#----------------------------
$ProgressBarQueriesProgressBar = New-Object System.Windows.Forms.ProgressBar -Property @{
    Location = @{ X = $Section3RightPosition + 60
                  Y = $Section3DownPosition - 2 }
    Size     = @{ Width  = $Section3ProgressBarWidth
                  Height = 10 }
    #Value   = 0
    Style    = "Continuous"
    #Maximum = 10
    Minimum  = 0
    #Step    = 1
    #Count   = 0
}
$PoSHACME.Controls.Add($ProgressBarQueriesProgressBar)
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
                  Y = $Section3DownPosition }
    Size     = @{ Width  = $Section3ResultsTabWidth
                  Height = $Section3ResultsTabHeight }
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
    Location  = @{ X = 579
                   Y = 200 }
    Size      = @{ Width  = 150
                   Height = 25 }
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
    ToolTipFunction -Title "Add Selected To OpNotes" -Icon "Info" -Message @"
⦿ One or more lines can be selected to add to the OpNotes.
⦿ The selection can be contiguous by using the Shift key
    and/or be separate using the Ctrl key, the press OK.
⦿ A Datetime stampe will be prefixed to the entry.`n`n
"@ })
$Section3ResultsTab.Controls.Add($ResultsTabOpNotesAddButton) 

#-----------------
# Results ListBox
#-----------------
$ResultsListBox = New-Object System.Windows.Forms.ListBox -Property @{
    Name     = "ResultsListBox"
    Location = @{ X = -1
                  Y = -1 }
    Size     = @{ Width  = $Section3ResultsTabWidth - 3
                  Height = $Section3ResultsTabHeight - 15 }
    FormattingEnabled   = $True
    SelectionMode       = 'MultiExtended'
    ScrollAlwaysVisible = $True
    AutoSize            = $False
    Font                = New-Object System.Drawing.Font("Courier New",11,0,0,0)
}
$PoShACMEAboutFile     = "$ResourcesDirectory\About\PoSh-ACME.txt"
# URL for Character Art
# http://patorjk.com/software/taag/#p=display&h=0&f=Slant&t=PoSh-ACME
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
    $ResultsListBox.Items.Add(" Website        : https://github.com/high101bro/PoSh-ACME                     ") | Out-Null
$Section3ResultsTab.Controls.Add($ResultsListBox)

#=========================================================================
#     __  __           __     ____        __           ______      __  
#    / / / /___  _____/ /_   / __ \____ _/ /_____ _   /_  __/___ _/ /_ 
#   / /_/ / __ \/ ___/ __/  / / / / __ `/ __/ __ `/    / / / __ `/ __ \
#  / __  / /_/ (__  ) /_   / /_/ / /_/ / /_/ /_/ /    / / / /_/ / /_/ /
# /_/ /_/\____/____/\__/  /_____/\__,_/\__/\__,_/    /_/  \__,_/_.___/ 
#                                                                      
#=========================================================================

$Section3HostDataTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text                    = "Host Data"
    Name                    = "Host Data Tab"
    UseVisualStyleBackColor = $True
    Font                    = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
$Section4TabControl.Controls.Add($Section3HostDataTab)

#------------------------------
# Host Data - Hostname Textbox
#------------------------------
$Section3HostDataName = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = 0
                  Y = 3 }
    Size     = @{ Width  = 250
                  Height = 25 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ReadOnly = $true
}
$Section3HostDataName.Add_MouseHover({
    ToolTipFunction -Title "Hostname" -Icon "Info" -Message @"
⦿ This field is reserved for the hostname.
⦿ Hostnames are not case sensitive.
⦿ Though IP addresses may be entered, WinRM queries may fail as
    IPs may only be used for authentication under certain conditions.`n`n
"@ })
$Section3HostDataTab.Controls.Add($Section3HostDataName)

#------------------------
# Host Data - OS Textbox
#------------------------
$Section3HostDataOS = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = 0
                  Y = $Section3HostDataName.Location.Y + $Section3HostDataName.Size.Height + 4 }
    Size     = @{ Width  = 250
                  Height = 25 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ReadOnly = $true
}
$Section3HostDataOS.Add_MouseHover({
    ToolTipFunction -Title "Operating System" -Icon "Info" -Message @"
⦿ This field is useful to view groupings of hosts by OS.`n`n
"@ })
$Section3HostDataTab.Controls.Add($Section3HostDataOS)

#------------------------
# Host Data - OU Textbox
#------------------------
$Section3HostDataOU = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = 0
                  Y = $Section3HostDataOS.Location.Y + $Section3HostDataOS.Size.Height + 4 }
    Size     = @{ Width  = 250
                  Height = 25 }
    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ReadOnly = $true
}
$Section3HostDataOU.Add_MouseHover({
    ToolTipFunction -Title "Organizational Unit / Container Name" -Icon "Info" -Message @"
⦿ This field is useful to view groupings of hosts by OU/CN.`n`n
"@ })
$Section3HostDataTab.Controls.Add($Section3HostDataOU)

#----------------------------------
# Host Data - IP and MAC Textboxes
#----------------------------------
    # IP Address TextBox
    $Section3HostDataIP = New-Object System.Windows.Forms.TextBox -Property @{
        Location = @{ X = 0
                      Y = $Section3HostDataOU.Location.Y + $Section3HostDataOU.Size.Height + 4 }
        Size     = @{ Width  = 120
                      Height = 25 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ReadOnly = $false
    }
    $Section3HostDataIP.Add_MouseHover({
        ToolTipFunction -Title "IP Address" -Icon "Info" -Message @"
⦿ Informational field not used to query hosts.`n`n
"@  })
    $Section3HostDataTab.Controls.Add($Section3HostDataIP)

    # MAC Address TextBox
    $Section3HostDataMAC = New-Object System.Windows.Forms.TextBox -Property @{
        Location = @{ X = $Section3HostDataIP.Size.Width + 10
                      Y = $Section3HostDataOU.Location.Y + $Section3HostDataOU.Size.Height + 4 }
        Size     = @{ Width  = 120
                      Height = 25 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ReadOnly = $false
    }
    $Section3HostDataMAC.Add_MouseHover({
        ToolTipFunction -Title "MAC Address" -Icon "Info" -Message @"
⦿ Informational field not used to query hosts.`n`n
"@  })
    $Section3HostDataTab.Controls.Add($Section3HostDataMAC)

#--------------------------------------
# Host Data Notes - Add OpNotes Button
#--------------------------------------
$Section3HostDataNotesAddOpNotesButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "Add Host Data To OpNotes"
    Location = @{ X = 570
                  Y = 197 }
    Size     = @{ Width  = 150
                  Height = 25 }
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
    ToolTipFunction -Title "Add Selected To OpNotes" -Icon "Info" -Message @"
⦿ One or more lines can be selected to add to the OpNotes.
⦿ The selection can be contiguous by using the Shift key
    and/or be separate using the Ctrl key, the press OK.
⦿ A Datetime stampe will be prefixed to the entry.`n`n
"@ })
$Section3HostDataTab.Controls.Add($Section3HostDataNotesAddOpNotesButton) 

#---------------------------
# Host Data - Notes Textbox
#---------------------------
Function Save-ComputerListHostData {
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
  
    $script:Section3HostDataNotesSaveCheck = $Section3HostDataNotes.Text
    Check-HostDataIfModified

    # Saves the TreeView Data to File
    $script:ComputerListTreeViewData | Export-Csv $ComputerListTreeViewFileSave -NoTypeInformation -Force    
}   

function Check-HostDataIfModified {
    if ($script:Section3HostDataNotesSaveCheck -eq $Section3HostDataNotes.Text) {
        $Section3HostDataSaveButton.ForeColor = "Green"
        $Section3HostDataSaveButton.Text      = "Data Saved"
    }
    else {
        $Section3HostDataSaveButton.ForeColor = "Red"
        $Section3HostDataSaveButton.Text      = "Save Data"
    } 
}
$Section3HostDataNotes = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = 0
                  Y = $Section3HostDataIP.Location.Y + $Section3HostDataIP.Size.Height + 3 }
    Size     = @{ Width  = 739
                  Height = 126 }
    Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
    Multiline  = $True
    ScrollBars = 'Vertical'
    WordWrap   = $True
    ReadOnly   = $false
}
$Section3HostDataNotes.Add_MouseHover({
    ToolTipFunction -Title "Host Notes" -Icon "Info" -Message @"
⦿ These notes are specific to the host.
⦿ Also can contains Tags if used.`n`n
"@ 
})
$Section3HostDataNotes.Add_MouseEnter({ Check-HostDataIfModified })
$Section3HostDataNotes.Add_MouseLeave({ Check-HostDataIfModified })
$Section3HostDataTab.Controls.Add($Section3HostDataNotes)

#-------------------------
# Host Data - Save Button
#-------------------------
$script:Section3HostDataNotesSaveCheck = ""
$Section3HostDataSaveButton = New-Object System.Windows.Forms.Button -Property @{
    Name      = "Host Data - Save"
    Text      = "Data Saved"
    Location = @{ X = 640
                  Y = 73 }
    Size     = @{ Width  = 100
                  Height = 22 }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = 'Green'
}
$Section3HostDataSaveButton.Add_Click({
    Save-ComputerListHostData
    Save-HostData
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Saved Host Data:  $($Section3HostDataName.Text)")

})
$Section3HostDataSaveButton.Add_MouseHover({
    ToolTipFunction -Title "Warning" -Icon "Warning" -Message @"
⦿ Best practice is to save after modifying each host data.`n`n
"@ })
$Section3HostDataTab.Controls.Add($Section3HostDataSaveButton)

#============================================================================================================================================================
# Host Data - Selection Data ComboBox and Date/Time ComboBox
#============================================================================================================================================================
$HostDataList1 = @(
    "Host Data - Selection",
    "Disk - Physical Info",
    "Local Users",
    "Network Settings",
    "Processes",
    "Security Patches",
    "Services",
    "Shares",
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
        Location           = New-Object System.Drawing.Point(260,3)
        Size               = New-Object System.Drawing.Size(200,25)
        Text               = "Host Data - Selection"
        Font               = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor          = "Black"
        AutoCompleteSource = "ListItems" # Options are: FileSystem, HistoryList, RecentlyUsedList, AllURL, AllSystemSources, FileSystemDirectories, CustomSource, ListItems, None
        AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
        DataSource         = $HostDataList1
    }
    $Section3HostDataSelectionComboBox.Add_MouseHover({
        ToolTipFunction -Title "Select Search Topic" -Icon "Info" -Message @"
⦿ If data exists, the datetime group will be displayed below.
⦿ These files can be searchable, toggle in Options Tab.
⦿ Note: Datetimes with more than one collection type won't
    display, these results will need to be navigated to manually.`n`n
"@  })
    $Section3HostDataSelectionComboBox.add_SelectedIndexChanged($HostDataList2)
    $Section3HostDataTab.Controls.Add($Section3HostDataSelectionComboBox)

    #--------------------------------------------
    # Host Data - Date & Time Collected ComboBox
    #--------------------------------------------
    $Section3HostDataSelectionDateTimeComboBox                    = New-Object System.Windows.Forms.ComboBox -Property @{
        Location           = New-Object System.Drawing.Point(260,($Section3HostDataSelectionComboBox.Size.Height + $Section3HostDataSelectionComboBox.Location.Y + 3))
        Size               = New-Object System.Drawing.Size(200,25)
        Text               = "Host Data - Date & Time"
        Font               = New-Object System.Drawing.Font("$Font",11,0,0,0)
        ForeColor          = "Black"
        AutoCompleteSource = "ListItems" # Options are: FileSystem, HistoryList, RecentlyUsedList, AllURL, AllSystemSources, FileSystemDirectories, CustomSource, ListItems, None
        AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
    }
    $Section3HostDataSelectionDateTimeComboBox.Add_MouseHover({
        ToolTipFunction -Title "Datetime of Results" -Icon "Info" -Message @"
⦿ If data exists, the datetime group will be displayed.
⦿ These files can be searchable, toggle in Options Tab.
⦿ Note: Datetimes with more than one collection type won't
    display, these results will need to be navigated to manually.`n`n
"@  })    
    $Section3HostDataTab.Controls.Add($Section3HostDataSelectionDateTimeComboBox)
  
    #-----------------------------
    # Host Data - Get Data Button
    #-----------------------------
    $Section3HostDataGetDataButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Get Data"
        Location = New-Object System.Drawing.Point(($Section3HostDataSelectionDateTimeComboBox.Location.X + $Section3HostDataSelectionDateTimeComboBox.Size.Width + 5),($Section3HostDataSelectionDateTimeComboBox.Location.Y - 1))
        Size     = New-Object System.Drawing.Size(75,23)
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $Section3HostDataGetDataButton.Add_Click({
        # Chooses the most recent file if multiple exist
        $HostData = Import-Csv -Path "$CollectedDataDirectory\$($Section3HostDataSelectionDateTimeComboBox.SelectedItem)\$script:HostDataCsvPath\*$($Section3HostDataName.Text)*.csv"
        
        if ($HostData) {
            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("Showing Results:  $HostDataSection")
            $HostData | Out-GridView -Title 'PoSh-ACME: Collected Data' -OutputMode Multiple | Set-Variable -Name HostDataResultsSection
        
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
        ToolTipFunction -Title "Get Data" -Icon "Info" -Message @"
⦿ If data exists, the datetime group will be displayed.
⦿ These files can be searchable, toggle in Options Tab.
⦿ Note: Datetimes with more than one collection type won't
    display, these results will need to be navigated to manually.`n`n
"@  }) 
    $Section3HostDataTab.Controls.Add($Section3HostDataGetDataButton)

#---------------------------------------
# ComputerList TreeView - Tags ComboBox
#---------------------------------------
$Section3HostDataTagsComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Name               = "Tags"
    Text               = "Tags"
    Location           = New-Object System.Drawing.Point(260,($Section3HostDataGetDataButton.Size.Height + $Section3HostDataGetDataButton.Location.Y + 25))
    Size               = New-Object System.Drawing.Size(200,25)
    AutoCompleteSource = "ListItems" # Options are: FileSystem, HistoryList, RecentlyUsedList, AllURL, AllSystemSources, FileSystemDirectories, CustomSource, ListItems, None
    AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
}
    ForEach ($Item in $TagListFileContents) { 
        [void] $Section3HostDataTagsComboBox.Items.Add($Item) 
    }
$Section3HostDataTagsComboBox.Add_MouseHover({
    ToolTipFunction -Title "List of Pre-Built Tags" -Icon "Info" -Message @"
⦿ Tags are not mandatory.
⦿ Tags provide standized info to aide searches.
⦿ Custom tags can be modified, created, and used.`n`n
"@ })
$Section3HostDataTab.Controls.Add($Section3HostDataTagsComboBox)

#-----------------------------------------
# ComputerList TreeView - Tags Add Button
#-----------------------------------------
$Section3HostDataTagsAddButton = New-Object System.Windows.Forms.Button -Property @{
    Name      = "Tags Add Button"
    Text      = "Add"
    Location = @{ X = $Section3HostDataTagsComboBox.Size.Width + $Section3HostDataTagsComboBox.Location.X + 5
                  Y = $Section3HostDataTagsComboBox.Location.Y - 1
                }
    Size     = @{ Width  = 75
                  Height = 23
                }
    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
    ForeColor = "Green"
}
$Section3HostDataTagsAddButton.Add_Click({ 
    if (!($Section3HostDataTagsComboBox.SelectedItem -eq "Tags")) {
        $Section3HostDataNotes.text = "[$($Section3HostDataTagsComboBox.SelectedItem)] " + $Section3HostDataNotes.text
    }
})
$Section3HostDataTagsAddButton.Add_MouseHover({
    ToolTipFunction -Title "Add Tag to Notes" -Icon "Info" -Message @"
⦿ Tags are not mandatory.
⦿ Tags provide standized info to aide searches.
⦿ Custom tags can be created and used.`n`n
"@ })
$Section3HostDataTab.Controls.Add($Section3HostDataTagsAddButton)

#=========================================================================
#                                ______      __  
#                               /_  __/___ _/ /_ 
#  Query Exploration             / / / __ `/ __ \
#                               / / / /_/ / /_/ /
#                              /_/  \__,_/_.___/ 
#                                                                      
#=========================================================================

$Section3QueryExplorationTabPage = New-Object System.Windows.Forms.TabPage -Property @{
    Text = "Query Exploration"
    Name = "Query Exploration"
    Font = New-Object System.Drawing.Font("$Font",11,0,0,0)
    UseVisualStyleBackColor = $True
}
$Section4TabControl.Controls.Add($Section3QueryExplorationTabPage)

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
}
$Section3QueryExplorationNameTextBox.Add_MouseEnter({ $Section3QueryExplorationNameTextBox.size = @{ Width = 633 } })
$Section3QueryExplorationNameTextBox.Add_MouseLeave({ $Section3QueryExplorationNameTextBox.size = @{ Width = 195 } })
$Section3QueryExplorationTabPage.Controls.AddRange(@($Section3QueryExplorationNameLabel,$Section3QueryExplorationNameTextBox))

#------------------------------------------------
# Query Exploration - WinRM PoSh Label & Textbox
#------------------------------------------------
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
}
$Section3QueryExplorationWinRMPoShTextBox.Add_MouseEnter({ $Section3QueryExplorationWinRMPoShTextBox.size = @{ Width = 633 } })
$Section3QueryExplorationWinRMPoShTextBox.Add_MouseLeave({ $Section3QueryExplorationWinRMPoShTextBox.size = @{ Width = 195 } })
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
}
$Section3QueryExplorationWinRMWMITextBox.Add_MouseEnter({ $Section3QueryExplorationWinRMWMITextBox.size = @{ Width = 633 } })
$Section3QueryExplorationWinRMWMITextBox.Add_MouseLeave({ $Section3QueryExplorationWinRMWMITextBox.size = @{ Width = 195 } })
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
}
$Section3QueryExplorationWinRMCmdTextBox.Add_MouseEnter({ $Section3QueryExplorationWinRMCmdTextBox.size = @{ Width = 633 } })
$Section3QueryExplorationWinRMCmdTextBox.Add_MouseLeave({ $Section3QueryExplorationWinRMCmdTextBox.size = @{ Width = 195 } })
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
}
$Section3QueryExplorationRPCPoShTextBox.Add_MouseEnter({ $Section3QueryExplorationRPCPoShTextBox.size = @{ Width = 633 } })
$Section3QueryExplorationRPCPoShTextBox.Add_MouseLeave({ $Section3QueryExplorationRPCPoShTextBox.size = @{ Width = 195 } })
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
}
$Section3QueryExplorationRPCWMITextBox.Add_MouseEnter({ $Section3QueryExplorationRPCWMITextBox.size = @{ Width = 633 } })
$Section3QueryExplorationRPCWMITextBox.Add_MouseLeave({ $Section3QueryExplorationRPCWMITextBox.size = @{ Width = 195 } })
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
}
$Section3QueryExplorationPropertiesPoshTextBox.Add_MouseEnter({ $Section3QueryExplorationPropertiesPoshTextBox.size = @{ Width = 633 } })
$Section3QueryExplorationPropertiesPoshTextBox.Add_MouseLeave({ $Section3QueryExplorationPropertiesPoshTextBox.size = @{ Width = 195 } })
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
}
$Section3QueryExplorationPropertiesWMITextBox.Add_MouseEnter({ $Section3QueryExplorationPropertiesWMITextBox.size = @{ Width = 633 } })
$Section3QueryExplorationPropertiesWMITextBox.Add_MouseLeave({ $Section3QueryExplorationPropertiesWMITextBox.size = @{ Width = 195 } })
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
}
$Section3QueryExplorationWinRSWmicTextBox.Add_MouseEnter({ $Section3QueryExplorationWinRSWmicTextBox.size = @{ Width = 633 } })
$Section3QueryExplorationWinRSWmicTextBox.Add_MouseLeave({ $Section3QueryExplorationWinRSWmicTextBox.size = @{ Width = 195 } })
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
}
$Section3QueryExplorationWinRSCmdTextBox.Add_MouseEnter({ $Section3QueryExplorationWinRSCmdTextBox.size = @{ Width = 633 } })
$Section3QueryExplorationWinRSCmdTextBox.Add_MouseLeave({ $Section3QueryExplorationWinRSCmdTextBox.size = @{ Width = 195 } })
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
$Section3QueryExplorationEditCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
    Text      = "Edit"
    Location  = @{ X = $Section3QueryExplorationDescriptionTextbox.Location.X + 255
                   Y = $Section3QueryExplorationDescriptionTextbox.Location.Y + $Section3QueryExplorationDescriptionTextbox.Size.Height + 3 }
    Size      = @{ Height = 25
                   Width  = 50 }
    Font      = New-Object System.Drawing.Font("$Font",11,0,2,1)
    Checked   = $false
}
$Section3QueryExplorationEditCheckBox.Add_Click({
    if ($Section3QueryExplorationEditCheckBox.checked){
        $Section3QueryExplorationSaveButton.Text      = "Save"
        $Section3QueryExplorationSaveButton.ForeColor = "Red"
        $Section3QueryExplorationDescriptionTextbox.ReadOnly    = $false
        $Section3QueryExplorationWinRSCmdTextBox.ReadOnly       = $false
        $Section3QueryExplorationWinRSWmicTextBox.ReadOnly      = $false
        $Section3QueryExplorationPropertiesWMITextBox.ReadOnly  = $false
        $Section3QueryExplorationPropertiesPoshTextBox.ReadOnly = $false
        $Section3QueryExplorationRPCWMITextBox.ReadOnly         = $false
        $Section3QueryExplorationRPCPoShTextBox.ReadOnly        = $false
        $Section3QueryExplorationWinRMWMITextBox.ReadOnly       = $false
        $Section3QueryExplorationWinRMCmdTextBox.ReadOnly       = $false
        $Section3QueryExplorationWinRMPoShTextBox.ReadOnly      = $false
        $Section3QueryExplorationTagWordsTextBox.ReadOnly       = $false
    }
    else {
        $Section3QueryExplorationSaveButton.Text      = "Locked"
        $Section3QueryExplorationSaveButton.ForeColor = "Green"
        $Section3QueryExplorationDescriptionTextbox.ReadOnly    = $true
        $Section3QueryExplorationWinRSCmdTextBox.ReadOnly       = $true
        $Section3QueryExplorationWinRSWmicTextBox.ReadOnly      = $true
        $Section3QueryExplorationPropertiesWMITextBox.ReadOnly  = $true
        $Section3QueryExplorationPropertiesPoshTextBox.ReadOnly = $true
        $Section3QueryExplorationRPCWMITextBox.ReadOnly         = $true
        $Section3QueryExplorationRPCPoShTextBox.ReadOnly        = $true
        $Section3QueryExplorationWinRMWMITextBox.ReadOnly       = $true
        $Section3QueryExplorationWinRMCmdTextBox.ReadOnly       = $true
        $Section3QueryExplorationWinRMPoShTextBox.ReadOnly      = $true
        $Section3QueryExplorationTagWordsTextBox.ReadOnly       = $true
    }
})

#---------------------------------
# Query Exploration - Save Button
#---------------------------------
$Section3QueryExplorationSaveButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = 'Locked'
    Location  = @{ X = $Section3QueryExplorationEditCheckBox.Location.X + 50
                   Y = $Section3QueryExplorationEditCheckBox.Location.Y }
    Size      = @{ Width  = $Column5BoxWidth
                   Height = $Column5BoxHeight }
    Font      = New-Object System.Drawing.Font("$Font",11,0,2,1)
    ForeColor = "Green"
}
$Section3QueryExplorationSaveButton.Add_Click({ 
    if ($Section3QueryExplorationSaveButton.Text -eq "Save") {
        $Section3QueryExplorationSaveButton.Text        = "Locked"
        $Section3QueryExplorationSaveButton.ForeColor   = "Green"
        $Section3QueryExplorationEditCheckBox.checked   = $false
        $Section3QueryExplorationDescriptionTextbox.ReadOnly    = $true
        $Section3QueryExplorationWinRSCmdTextBox.ReadOnly       = $true
        $Section3QueryExplorationWinRSWmicTextBox.ReadOnly      = $true
        $Section3QueryExplorationPropertiesWMITextBox.ReadOnly  = $true
        $Section3QueryExplorationPropertiesPoshTextBox.ReadOnly = $true
        $Section3QueryExplorationRPCWMITextBox.ReadOnly         = $true
        $Section3QueryExplorationRPCPoShTextBox.ReadOnly        = $true
        $Section3QueryExplorationWinRMWMITextBox.ReadOnly       = $true
        $Section3QueryExplorationWinRMCmdTextBox.ReadOnly       = $true
        $Section3QueryExplorationWinRMPoShTextBox.ReadOnly      = $true
        $Section3QueryExplorationTagWordsTextBox.ReadOnly       = $true

        $SaveAllEndpointCommands = @()
        Foreach($Query in $script:AllEndpointCommands) {
            if ($Section3QueryExplorationNameTextBox.Text -ne $Query.Name -and $Query.Type -ne 'script') {
                # For those commands not selected, this just copies their unmodified data to be saved.
                $SaveAllEndpointCommands += [PSCustomObject]@{
                    Name               = $Query.Name
                    Type               = $Query.Type
                    Command_WinRM_PoSh = $Query.Command_WinRM_PoSh
                    Command_WinRM_WMI  = $Query.Command_WinRM_WMI
                    Command_WinRM_Cmd  = $Query.Command_WinRM_Cmd
                    Command_RPC_Posh   = $Query.Command_RPC_Posh
                    Command_WMI        = $Query.Command_WMI
                    Properties_PoSh    = $Query.Properties_PoSh
                    Properties_WMI     = $Query.Properties_WMI
                    Command_WinRS_WMIC = $Query.Command_WinRS_WMIC
                    Command_WinRS_CMD  = $Query.Command_WinRS_CMD
                    Description        = $Query.Description
                    ExportFileName     = $Query.ExportFileName
                }
            }
            elseif ($Section3QueryExplorationNameTextBox.Text -eq $Query.Name -and $Query.Type -ne 'script') {
                # if the node is selected, it saves the information in the text boxes
                $SaveAllEndpointCommands += [PSCustomObject]@{
                    Name               = $Section3QueryExplorationNameTextBox.Text
                    Type               = $Section3QueryExplorationTagWordsTextBox.Text
                    Command_WinRM_PoSh = $Section3QueryExplorationWinRMPoShTextBox.Text
                    Command_WinRM_WMI  = $Section3QueryExplorationWinRMWMITextBox.Text
                    Command_WinRM_Cmd  = $Section3QueryExplorationWinRMCmdTextBox.Text
                    Command_RPC_Posh   = $Section3QueryExplorationRPCPoShTextBox.Text
                    Command_WMI        = $Section3QueryExplorationRPCWMITextBox.Text
                    Properties_PoSh    = $Section3QueryExplorationPropertiesPoshTextBox.Text
                    Properties_WMI     = $Section3QueryExplorationPropertiesWMITextBox.Text
                    Command_WinRS_WMIC = $Section3QueryExplorationWinRSWmicTextBox.Text
                    Command_WinRS_CMD  = $Section3QueryExplorationWinRSCmdTextBox.Text
                    Description        = $Section3QueryExplorationDescriptionTextbox.Text
                    ExportFileName     = $Query.ExportFileName
                }
            }
        }
        $SaveAllEndpointCommands    | Export-Csv $CommandsEndpoint -NoTypeInformation -Force
        $script:AllEndpointCommands = $SaveAllEndpointCommands
        Import-EndpointScripts

        $SaveAllActiveDirectoryCommands = @()
        Foreach($Query in $script:AllActiveDirectoryCommands) {
            if ($Section3QueryExplorationNameTextBox.Text -ne $Query.Name -and $Query.Type -ne 'script') {
                # if the node is selected, it saves the information in the text boxes
                $SaveAllActiveDirectoryCommands += [PSCustomObject]@{
                    Name               = $Query.Name
                    Type               = $Query.Type
                    Command_WinRM_PoSh = $Query.Command_WinRM_PoSh
                    Command_WinRM_WMI  = $Query.Command_WinRM_WMI
                    Command_WinRM_Cmd  = $Query.Command_WinRM_Cmd
                    Command_RPC_Posh   = $Query.Command_RPC_Posh
                    Command_WMI        = $Query.Command_WMI
                    Properties_PoSh    = $Query.Properties_PoSh
                    Properties_WMI     = $Query.Properties_WMI
                    Command_WinRS_WMIC = $Query.Command_WinRS_WMIC
                    Command_WinRS_CMD  = $Query.Command_WinRS_CMD
                    Description        = $Query.Description
                    ExportFileName     = $Query.ExportFileName
                }
            }
            elseif ($Section3QueryExplorationNameTextBox.Text -eq $Query.Name -and $Query.Type -ne 'script') {
                # if the node is selected, it saves the information in the text boxes
                $SaveAllActiveDirectoryCommands += [PSCustomObject]@{
                    Name               = $Section3QueryExplorationNameTextBox.Text
                    Type               = $Section3QueryExplorationTagWordsTextBox.Text
                    Command_WinRM_PoSh = $Section3QueryExplorationWinRMPoShTextBox.Text
                    Command_WinRM_WMI  = $Section3QueryExplorationWinRMWMITextBox.Text
                    Command_WinRM_Cmd  = $Section3QueryExplorationWinRMCmdTextBox.Text
                    Command_RPC_Posh   = $Section3QueryExplorationRPCPoShTextBox.Text
                    Command_WMI        = $Section3QueryExplorationRPCWMITextBox.Text
                    Properties_PoSh    = $Section3QueryExplorationPropertiesPoshTextBox.Text
                    Properties_WMI     = $Section3QueryExplorationPropertiesWMITextBox.Text
                    Command_WinRS_WMIC = $Section3QueryExplorationWinRSWmicTextBox.Text
                    Command_WinRS_CMD  = $Section3QueryExplorationWinRSCmdTextBox.Text
                    Description        = $Section3QueryExplorationDescriptionTextbox.Text
                    ExportFileName     = $Query.ExportFileName
                }
            }
        }
        $SaveAllActiveDirectoryCommands    | Export-Csv $CommandsActiveDirectory -NoTypeInformation -Force
        $script:AllActiveDirectoryCommands = $SaveAllActiveDirectoryCommands
        Import-ActiveDirectoryScripts

        $CommandsTreeView.Nodes.Clear()
        Initialize-CommandsTreeView
        View-CommandsTreeViewMethod
        Keep-CommandsCheckboxesChecked

        $Section4TabControl.SelectedTab = $Section3ResultsTab
        $CommandTextBoxList = @($Section3QueryExplorationNameTextBox,$Section3QueryExplorationTagWordsTextBox,$Section3QueryExplorationWinRMPoShTextBox,$Section3QueryExplorationWinRMWMITextBox,$Section3QueryExplorationWinRMCmdTextBox,$Section3QueryExplorationRPCPoShTextBox,$Section3QueryExplorationRPCWMITextBox,$Section3QueryExplorationPropertiesPoshTextBox,$Section3QueryExplorationPropertiesWMITextBox,$Section3QueryExplorationWinRSWmicTextBox,$Section3QueryExplorationWinRSCmdTextBox,$Section3QueryExplorationDescriptionTextbox)
        foreach ( $TextBox in $CommandTextBoxList ) { $TextBox.Text = '' }
        $StatusListBox.Items.Add("Command updated.")
        $ResultsListBox.Items.Clear()

    }
    else {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Section is locked from editing.")
        [system.media.systemsounds]::Exclamation.play()
    }
})

#---------------------------------
# Query Exploration - View Script
#---------------------------------
$Section3QueryExplorationViewScriptButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = 'View Script'
    Location  = @{ X = $Section3QueryExplorationEditCheckBox.Location.X + 50
                   Y = $Section3QueryExplorationEditCheckBox.Location.Y }
    Size      = @{ Width  = $Column5BoxWidth
                   Height = $Column5BoxHeight }
    Font      = New-Object System.Drawing.Font("$Font",11,0,2,1)
    ForeColor = "Green"
}

$Section3QueryExplorationViewScriptButton.Add_Click({ 
    Foreach($Query in $script:AllEndpointCommands) {
        if ($Section3QueryExplorationNameTextBox.Text -eq $Query.Name -and $Query.Type -eq 'script') { notepad.exe $Query.ScriptPath}
    }
    Foreach($Query in $script:AllActiveDirectoryCommands) {
        if ($Section3QueryExplorationNameTextBox.Text -eq $Query.Name -and $Query.Type -eq 'script') { notepad.exe $Query.ScriptPath}
    }
})

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
    $ProgressBarEndpointsProgressBar.Value = 0
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
        $ProgressBarEndpointsProgressBar.Maximum = $jobscount

        # Gets the results from jobs that are completed
        $CurrentJobs | Receive-Job -Force

        # Counts the total of completed jobs for each update
        $done = 0
        foreach ($job in $CurrentJobs) { if ($($job.state) -eq "Completed") {$done++} }
        $ProgressBarEndpointsProgressBar.Value = $done 
        
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
        $ResultsListBox.Refresh()

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
    $PoShACME.Refresh()
    Start-Sleep -Seconds 1
}

#============================================================================================================================================================
# CheckBox Script Handler
#============================================================================================================================================================
$ExecuteScriptHandler= {
    # Clears the Progress bars
    $ProgressBarEndpointsProgressBar.Value = 0
    $ProgressBarQueriesProgressBar.Value   = 0

    # Clears previous Target Host values
    $ComputerList = @()           

    if ($script:SingleHostIPCheckBox.Checked -eq $true) {
        if (($script:SingleHostIPTextBox.Text -ne $DefaultSingleHostIPText) -and ($script:SingleHostIPTextBox.Text -ne '') ) {
            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("Single Host Collection")
            $ComputerList = $script:SingleHostIPTextBox.Text
        }
    }
    elseif ($script:SingleHostIPCheckBox.Checked -eq $false) {    
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Multiple Host Collection")
        
        # If the root computerlist checkbox is checked, all hosts will be queried
        [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerListTreeView.Nodes 
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

    # Checks if any computers were selected
    if (($ComputerList.Count -eq 0) -and ($script:SingleHostIPCheckBox.Checked -eq $false)) {
        # This brings specific tabs to the forefront/front view
        $Section1TabControl.SelectedTab = $Section1CollectionsTab
        $Section4TabControl.SelectedTab = $Section3ResultsTab

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
        $CountComputerListCheckedBoxesSelected = $ComputerList.Count

        # Commands in the treenode that are selected
        $CommandsCheckedBoxesSelected = @()

        # The number of command queries completed
        $CompletedCommandQueries = 0

        # Counts the Total Queries
        $CountCommandQueries = 0

        [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $CommandsTreeView.Nodes
        $ResultsListBox.Items.Clear()

        # Compiles all the commands into one object
        $script:AllCommands  = $script:AllEndpointCommands
        $script:AllCommands += $script:AllActiveDirectoryCommands
        $script:AllCommands += $script:ImportCustomCommands

        # Check if check boxes match query type and runs them
        foreach ($root in $AllHostsNode) { 
            foreach ($Category in $root.Nodes) {                
                if ($CommandsViewMethodRadioButton.Checked) {
                    foreach ($Entry in $Category.nodes) {                        
                        # Builds the query that is selected
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
                        elseif ($Entry.Checked -and $Entry -match '(RPC)' -and  $Entry -match 'WMI' -and $Entry -notmatch '(WinRS)' -and $Entry -notmatch '(WinRM)') {
                            $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                            $CommandsCheckedBoxesSelected += New-Object psobject @{ 
                                Name           = $Entry.Text
                                Command        = $Command.Command_WMI
                                Properties     = $Command.Properties_WMI
                                ExportFileName = $Command.ExportFileName
                                Type           = "(RPC) WMI"
                            }
                        }
                        elseif ($Entry.Checked -and $Entry -match '(WinRM)' -and $Entry -match 'CMD') {
                            $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                            $CommandsCheckedBoxesSelected += New-Object psobject @{ 
                                Name           = $Entry.Text
                                Command        = $Command.Command_WinRM_CMD
                                ExportFileName = $Command.ExportFileName
                                Type           = "(WinRM) CMD"
                            }
                        }
                        elseif ($Entry.Checked -and $Entry -match '(WinRM)' -and $Entry -match 'Script') {
                            $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                            $CommandsCheckedBoxesSelected += New-Object psobject @{ 
                                Name           = $Entry.Text
                                Command        = $Command.Command_WinRM_Script
                                #Properties     = $Command.Properties_Script
                                ExportFileName = $Command.ExportFileName
                                Type           = "(WinRM) Script"
                            }
                        }
                        elseif ($Entry.Checked -and $Entry -match '(WinRM)' -and $Entry -match 'PoSh') {
                            $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                            $CommandsCheckedBoxesSelected += New-Object psobject @{ 
                                Name           = $Entry.Text
                                Command        = $Command.Command_WinRM_PoSh
                                Properties     = $Command.Properties_PoSh
                                ExportFileName = $Command.ExportFileName
                                Type           = '(WinRM) PoSh'
                            }
                        }
                        elseif ($Entry.Checked -and $Entry -match '(WinRM)' -and $Entry -match 'WMI') {
                            $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                            $CommandsCheckedBoxesSelected += New-Object psobject @{ 
                                Name           = $Entry.Text
                                Command        = $Command.Command_WinRM_WMI
                                Properties     = $Command.Properties_WMI
                                ExportFileName = $Command.ExportFileName
                                Type           = "(WinRM) WMI"
                            }
                        }
                    }
                }
                if ($CommandsViewQueryRadioButton.Checked) {
                    foreach ($Entry in $Category.nodes) { 
                        # Builds the query that is selected
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
                        elseif (($Entry -match '(RPC)') -and  $Entry -match 'WMI' -and ($Entry -notmatch '(WinRS)') -and ($Entry -notmatch '(WinRM)') -and $Entry.Checked) {                        
                            $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                            $CommandsCheckedBoxesSelected += New-Object psobject @{ 
                                Name           = $Entry.Text
                                Command        = $Command.Command_WMI
                                Properties     = $Command.Properties_WMI
                                ExportFileName = $Command.ExportFileName
                                Type           = "(RPC) WMI"
                            }
                        }
                        elseif ($Entry -match '(WinRM)' -and $Entry -match 'CMD' -and $Entry.Checked) {
                            $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                            $CommandsCheckedBoxesSelected += New-Object psobject @{ 
                                Name           = $Entry.Text
                                Command        = $Command.Command_WinRM_CMD
                                ExportFileName = $Command.ExportFileName
                                Type           = "(WinRM) CMD"
                            }
                        }
                        elseif ($Entry -match '(WinRM)' -and $Entry -match 'Script' -and $Entry.Checked) {
                            $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                            $CommandsCheckedBoxesSelected += New-Object psobject @{ 
                                Name           = $Entry.Text
                                Command        = $Command.Command_WinRM_Script
                                #Properties     = $Command.Properties_Script
                                ExportFileName = $Command.ExportFileName
                                Type           = "(WinRM) Script"
                            }
                        }
                        elseif ($Entry -match '(WinRM)' -and $Entry -match 'PoSh' -and $Entry.Checked) {
                            $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                            $CommandsCheckedBoxesSelected += New-Object psobject @{ 
                                Name           = $Entry.Text
                                Command        = $Command.Command_WinRM_PoSh
                                Properties     = $Command.Properties_PoSh
                                ExportFileName = $Command.ExportFileName
                                Type           = '(WinRM) PoSh'
                            }
                        }
                        elseif ($Entry -match '(WinRM)' -and $Entry -match 'WMI' -and $Entry.Checked) {
                            $Command = $script:AllCommands | Where-Object Name -eq $(($Entry.Text -split ' -- ')[1])
                            $CommandsCheckedBoxesSelected += New-Object psobject @{ 
                                Name           = $Entry.Text
                                Command        = $Command.Command_WinRM_WMI
                                Properties     = $Command.Properties_WMI
                                ExportFileName = $Command.ExportFileName
                                Type           = "(WinRM) WMI"
                            }
                        }                        
                    }
                }
            }
        }
        
        # Verifies that the command is only present once. Prevents running the multiple copies of the same comand, typically from using the Query History comamnds
        $CommandsCheckedBoxesSelectedTemp  = @()
        $CommandsCheckedBoxesSelectedDedup = @()
        foreach ($Command in $CommandsCheckedBoxesSelected) {
            if ($CommandsCheckedBoxesSelectedTemp -notcontains $Command.command) {
                $CommandsCheckedBoxesSelectedTemp  += "$($Command.command)"
                $CommandsCheckedBoxesSelectedDedup += $command
                $CountCommandQueries++
            }
        }
        $CommandsCheckedBoxesSelected = $CommandsCheckedBoxesSelectedDedup
        $ProgressBarQueriesProgressBar.Maximum = $CountCommandQueries

        # Adds executed commands to query history commands variable
        $script:QueryHistoryCommands += $CommandsCheckedBoxesSelected

        # Adds the selected commands to the Query History Command Nodes 
        $QueryHistoryCategoryName = $CollectionSavedDirectoryTextBox.Text.Replace("$CollectedDataDirectory","").TrimStart('\')
        foreach ($Command in $CommandsCheckedBoxesSelected) {
            $Command | Add-Member -MemberType NoteProperty -Name CategoryName -Value $QueryHistoryCategoryName -Force
            Add-CommandsNode -RootNode $script:TreeNodePreviouslyExecutedCommands -Category $QueryHistoryCategoryName -Entry "$($Command.Name)" -ToolTip $Command.Command
        }
        # Ensures that there are to lingering jobs in memory
        Get-Job -Name "PoSh-ACME:*" | Remove-Job -Force -ErrorAction SilentlyContinue

        # Iterates through selected commands and computers
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
                    if ($ComputerListProvideCredentialsCheckBox.Checked) {
                        if (!$script:Credential) { $script:Credential = Get-Credential }                    
                        if (($Command.Type -eq "(RPC) WMI") -and ($Command.Command -match "Get-WmiObject")) {
                            $CommandString = "$($Command.Command) -ComputerName $TargetComputer -Credential `$script:Credential | Select-Object -Property $($Command.Properties)"
                            $OutputFileFileType = "csv"
                        }
                        elseif (($Command.Type -eq "(RPC) WMI") -and ($Command.Command -match "Invoke-WmiMethod")) {
                            $CommandString = "$($Command.Command) -ComputerName $TargetComputer -Credential `$script:Credential"
                            $OutputFileFileType = "txt"
                        }
                        elseif ($Command.Type -eq "(WinRM) Script") {
                            $CommandString = "$($Command.Command) -ComputerName $TargetComputer -Credential `$script:Credential"
                            $OutputFileFileType = "csv"
                        }
                        elseif ($Command.Type -eq "(WinRM) PoSh") {
                            $CommandString = "$($Command.Command) -ComputerName $TargetComputer -Credential `$script:Credential | Select-Object -Property $($Command.Properties)"
                            $OutputFileFileType = "csv"
                        }
                        elseif ($Command.Type -eq "(WinRM) WMI") {
                            $CommandString = "$($Command.Command) -ComputerName $TargetComputer -Credential `$script:Credential | Select-Object -Property $($Command.Properties)"
                            $OutputFileFileType = "csv"
                        }
                        if ($Command.Type -eq "(WinRM) CMD") {
                            $CommandString = "$($Command.Command) -ComputerName $TargetComputer -Credential `$script:Credential"
                            $OutputFileFileType = "txt"
                        }
                        elseif ($Command.Type -eq "(RPC) PoSh") {
                            $CommandString = "$($Command.Command) -ComputerName $TargetComputer -Credential `$script:Credential | Select-Object -Property @{n='PSComputerName';e={`$TargetComputer}}, $($Command.Properties)"
                            $OutputFileFileType = "csv"
                        }
                    }
                    # No credentials provided
                    else {
                        if (($Command.Type -eq "(RPC) WMI") -and ($Command.Command -match "Get-WmiObject")) {
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
                        elseif ($Command.Type -eq "(WinRM) CMD") {
                            $CommandString = "$($Command.Command)"
                            $OutputFileFileType = "txt"
                        }
                        elseif ($Command.Type -eq "(RPC) PoSh") {
                            $CommandString = "$($Command.Command) -ComputerName $TargetComputer | Select-Object -Property @{n='PSComputerName';e={`$TargetComputer}}, $($Command.Properties)"
                            $OutputFileFileType = "csv"
                        }
                    }

                    $CommandName = $Command.Name
                    $CommandType = $Command.Type

                    # Sends each query separetly to each computers, which produces a lot of network connections

                    Start-Job -Name "PoSh-ACME: $CommandName -- $TargetComputer" -ScriptBlock {
                        param($OutputFileFileType, $SavePath, $CommandName, $CommandType, $TargetComputer, $CommandString, $script:Credential)                      
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
                    } -InitializationScript $null -ArgumentList @($OutputFileFileType, $SavePath, $CommandName, $CommandType, $TargetComputer, $CommandString, $script:Credential)

                    # Logs the commands to file
                    $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $CommandString"
                    $LogMessage | Add-Content -Path $LogFile
                }
                # Increments the overall progress bar
                $CompletedCommandQueries++
                $ProgressBarQueriesProgressBar.Value = $CompletedCommandQueries

                # Monitors the progress of the Jobs and provides user status feedback. Jobs will also timeout, which the duration is a configurable
                Monitor-Jobs

                # This allows the Endpoint progress bar to appear completed momentarily
                $ProgressBarEndpointsProgressBar.Maximum = 1; $ProgressBarEndpointsProgressBar.Value = 1; Start-Sleep -Milliseconds 250

                $CollectionCommandEndTime  = Get-Date                    
                $CollectionCommandDiffTime = New-TimeSpan -Start $CollectionCommandStartTime -End $CollectionCommandEndTime
                $ResultsListBox.Items.RemoveAt(0)
                $ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $($Command.Name)")

                # Compiles the CSVs into a single file for easier and faster viewing of results
                $StatusListBox.Items.Clear()
                $StatusListBox.Items.Add("Compiling CSV Results:  $((($Command.Name) -split ' -- ')[1])")
                Compile-CsvFiles -LocationOfCSVsToCompile "$SavePath\$((($Command.Name) -split ' -- ')[1]) - $($Command.Type)*.csv" `
                                 -LocationToSaveCompiledCSV "$CollectedDataTimeStampDirectory\$((($Command.Name) -split ' -- ')[1]) - $($Command.Type).csv"
                $StatusListBox.Items.Clear()
                $StatusListBox.Items.Add("Finished Collecting Data!")
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
                if (($Command.Type -eq "(RPC) WMI") -and ($Command.Command -match "Get-WmiObject")) { $QueryCommands += @{ $Command.Name = @{ Name = $Command.Name ; Command = $Command.Command ; Properties = $Command.Properties }} }
                elseif (($Command.Type -eq "(RPC) WMI") -and ($Command.Command -match "Invoke-WmiMethod")) {
                    $QueryCommands += @{ $Command.Name = @{ Name = $Command.Name ; Command = $Command.Command ; Properties = $Command.Properties }}
                }
                elseif ($Command.Type -eq "(WinRM) Script") {
                    $CommandScript = $command.command
                    $QueryCommands += @{ 
                        $Command.Name = @{ Name = $Command.Name
                        Command = @"

$(Invoke-Expression ("$CommandScript").Replace("Invoke-Command -FilePath '","Get-Content -Raw -Path '"))

"@
                        Properties = $Command.Properties }}
                }
                elseif ($Command.Type -eq "(WinRM) PoSh") {
                    $QueryCommands += @{ $Command.Name = @{ Name = $Command.Name ; Command = $Command.Command ; Properties = $Command.Properties }}
                }
                elseif ($Command.Type -eq "(WinRM) WMI") {
                    $QueryCommands += @{ $Command.Name = @{ Name = $Command.Name ; Command = $Command.Command ; Properties = $Command.Properties }}
                }
                elseif ($Command.Type -eq "(WinRM) CMD") {
                    $QueryCommands += @{ $Command.Name = @{ Name = $Command.Name ; Command = $Command.Command ; Properties = $Command.Properties }}
                }
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
                                   Y = 8 }
                    Size      = @{ Height = 25
                                   Width  = 160 }
                }
                $CommandReviewEditForm.Controls.Add($CommandReviewEditLabel)

                #--------------------------------------------
                # Command Reveiw and Edit Enable RadioButton
                #--------------------------------------------
                $CommandReviewEditEnabledRadio = New-Object System.Windows.Forms.RadioButton -Property @{
                    Text      = "Yes"
                    Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
                    Location  = @{ X = $CommandReviewEditLabel.Location.X + $CommandReviewEditLabel.Size.Width + 20
                                   Y = 5 }
                    Size      = @{ Height = 25
                                   Width  = 50 }
                    Checked   = $false
                }
                $CommandReviewEditEnabledRadio.Add_Click({ $CommandReviewEditTextbox.ReadOnly = $False })
                $CommandReviewEditEnabledRadio.Add_MouseHover({
                    ToolTipFunction -Title "Enable Script Editing" -Icon "Info" -Message @"
⦿ The script below is generated by the selections made.
⦿ Use caustion if editing, charts use the hashtable name field.`n`n
"@                  })
                $CommandReviewEditForm.Controls.Add($CommandReviewEditEnabledRadio)

                #---------------------------------------------
                # Command Reveiw and Edit Disable RadioButton
                #---------------------------------------------
                $CommandReviewEditDisabledRadio = New-Object System.Windows.Forms.RadioButton -Property @{
                    Text     = "No"
                    Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
                    Location = @{ X = $CommandReviewEditEnabledRadio.Location.X + $CommandReviewEditEnabledRadio.Size.Width + 10
                                  Y = 5 }
                    Size     = @{ Height = 25
                                  Width  = 50 }
                    Checked  = $true
                }
                $CommandReviewEditDisabledRadio.Add_Click({ $CommandReviewEditTextbox.ReadOnly = $True })
                $CommandReviewEditDisabledRadio.Add_MouseHover({
                    ToolTipFunction -Title "Disable Script Editing" -Icon "Info" -Message @"
⦿ The script below is generated by the selections made.
⦿ Use caustion if editing, charts use the hashtable name field.`n`n
"@                  })
                $CommandReviewEditForm.Controls.Add($CommandReviewEditDisabledRadio)

                #-----------------------------------------
                # Command Reveiw and Edit Verify Checkbox
                #-----------------------------------------
                $CommandReviewEditVerifyCheckbox = New-Object System.Windows.Forms.Checkbox -Property @{
                    Text      = "Verify"
                    Font      = New-Object System.Drawing.Font("$Font",14,0,0,0)
                    Location  = @{ X = 805
                                   Y = 6 }
                    Size      = @{ Height = 25
                                   Width  = 65 }
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
                                   Y = 5 }
                    Size      = @{ Height = 25
                                   Width  = 100 }
                }
                $CommandReviewEditExecuteButton.Add_Click({ $CommandReviewEditForm.close() })
                $CommandReviewEditExecuteButton.Add_MouseHover({
                        ToolTipFunction -Title "Cancel or Execute" -Icon "Info" -Message @"
⦿ To Cancel, you need to uncheck the verify box.
⦿ To Execute, you first need to check the verify box.
⦿ First verify the contents of the script and edit if need be.
⦿ When executed, the compiled script is ran against each selected computer.
⦿ The results return as one object, then are locally extracted and saved individually.
⦿ The results for each section are saved individually by host and query.
⦿ The results are also compiled by query into a single file containing every host.
⦿ The code is executed within a PowerShel Job for each destination host.
⦿ The compiled commands reduce the amount of network traffic.
⦿ This method is faster, but requires more RAM on the target host.
⦿ Use caustion if editing, charts use the hashtable name field.`n`n
"@                  })
                $CommandReviewEditForm.Controls.Add($CommandReviewEditExecuteButton)

                #--------------------------------
                # Command Reveiw and Edit String
                #--------------------------------
# This is the string that contains the command(s) to query, it is iterated over $targetcomputer
                if ($ComputerListProvideCredentialsCheckBox.Checked) {
                    if (!$script:Credential) { $script:Credential = Get-Credential }     
$CommandReviewString = @"
Invoke-Command -Credential `$script:Credential -ComputerName `$TargetComputer -ScriptBlock {
param(`$TargetComputer) 
`$QueryResults = @{}


"@
                } # END if
                else {
$CommandReviewString = @"
Invoke-Command -ComputerName `$TargetComputer -ScriptBlock {
param(`$TargetComputer) 
`$QueryResults = @{}


"@
                } # END else
$QueryCommandsCount = 0
ForEach ($Query in $($QueryCommands.keys)) {
    $QueryCommandsCount++
    $CommandReviewString += @"
#===================================================================================================
# Query $($QueryCommandsCount): $($QueryCommands[$Query]['Name'])
#===================================================================================================

"@
    if ($($QueryCommands[$Query]['Properties']) -eq $null) {
    $CommandReviewString += @"
`$QueryResults += @{
    '$($QueryCommands["$Query"]["Name"])' = @{
        'Name'    = "$($QueryCommands[$Query]['Name']) -- `$TargetComputer"
        'Results' = `$($($QueryCommands[$Query]['Command'])
        ) # END 'Results'
    } # END '$($QueryCommands["$Query"]["Name"])'
} # END `$QueryResults


"@
    } # END if
    else {
    $CommandReviewString += @"
`$QueryResults += @{
    '$($QueryCommands["$Query"]["Name"])' = @{
        'Name'    = "$($QueryCommands[$Query]['Name']) -- `$TargetComputer"
        'Results' = `$($($QueryCommands[$Query]['Command']) | Select-Object -Property $($QueryCommands[$Query]['Properties'].replace('PSComputerName','@{Name="PSComputerName";Expression={$env:ComputerName}}'))
        ) # END 'Results'
    } # END '$($QueryCommands["$Query"]["Name"])'
} # END `$QueryResults


"@
    } # END else
} # END ForEach
$CommandReviewString += @"
return `$QueryResults                           
} -ArgumentList @(`$TargetComputer)
"@
                #---------------------------------
                # Command Review and Edit Textbox
                #---------------------------------
                $CommandReviewEditTextbox = New-Object System.Windows.Forms.TextBox -Property @{
                    Location = @{ X = 5
                                  Y = 35 }
                    Size     = @{ Height = 422
                                  Width  = 974 }
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
                        param($TargetComputer, $CommandReviewEditTextboxText, $script:Credential)
                        # Available priority values: Low, BelowNormal, Normal, AboveNormal, High, RealTime
                        [System.Threading.Thread]::CurrentThread.Priority = 'High'
                        ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'High'

                        Invoke-Expression -Command $CommandReviewEditTextboxText
                    } -InitializationScript $null -ArgumentList @($TargetComputer, $CommandReviewEditTextboxText, $script:Credential)
                }
                    
                # Checks Jobs for completion
                # This is similar to the Monitor-Job function, but specific to execution of compiled commands
                # Start: Job Monitoring
                $TargetComputerCount = $ComputerList.count
                $CompletedJobs = @()
                $ResultsListBox.Items.Insert(0,"")

                    Start-Sleep -Seconds 1
                    # The number of Jobs created by PoSh-ACME
                    $PoShACMEJobs = Get-Job -Name "PoSh-ACME:*"
                    $ProgressBarEndpointsProgressBar.minimum   = 0
                    $ProgressBarEndpointsProgressBar.maximum   = $PoShACMEJobs.count
                    
                    While ($TargetComputerCount -gt 0) {
                        foreach ($Job in $PoShACMEJobs) {
                            if (($Job.State -eq 'Completed') -and ($Job.Name -notin $CompletedJobs)) {
                                $TargetComputerCount -= 1
                                $CompletedJobs += $Job.Name
                                #$ProgressBarEndpointsProgressBar.value = $CompletedJobs.count
                                $ProgressBarEndpointsProgressBar.Increment(1)
                                Start-Sleep -Milliseconds 250
                                $CollectionCommandEndTime  = Get-Date                    
                                $CollectionCommandDiffTime = New-TimeSpan -Start $CollectionCommandStartTime -End $CollectionCommandEndTime
                                #$ResultsListBox.Items.RemoveAt(0)                                
                                $ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$($CollectionCommandDiffTime)]  Completed: $(($Job.Name).split('--')[-1].trim())")                            
                            }
                        }
                        Start-Sleep -Seconds 1                    
                    }

                    # Extracts individual query data from each jobs
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
                                if ("$SavePath\$($Query) - $($Type)*.csv" -notin $CollectionTypes) { $CollectionTypes += "$SavePath\$($Query) - $($Type)*.csv" }
                            } 
                        }
                        Remove-Job -Name "$($Job.Name)" -Force
                    }# End: Job Monitoring

                # This allows the Endpoint progress bar to appear completed momentarily
                $ProgressBarEndpointsProgressBar.Maximum = 1; $ProgressBarEndpointsProgressBar.Value = 1; Start-Sleep -Milliseconds 250

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

        #########################################
        ##                                     ##
        ##  Executes the other query sections  ##
        ##                                     ##
        #########################################
        # Counts and Executes the following sections if checked
        # Make sure to update Conduct-NodeAction if adding new checkboxes
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
        $ProgressBarEndpointsProgressBar.Maximum = 1
        $ProgressBarEndpointsProgressBar.Value   = 1
        $ProgressBarQueriesProgressBar.Maximum = 1
        $ProgressBarQueriesProgressBar.Value   = 1
      
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
            if (($CountCommandQueries -eq 0) -and ($CountComputerListCheckedBoxesSelected -eq 0)) {$speak.Speak("You need to select at least one query and target host.")}
            else {
                if ($CountCommandQueries -eq 0) {$speak.Speak("You need to select at least one query.")}
                if ($CountComputerListCheckedBoxesSelected -eq 0) {$speak.Speak("You need to select at least one target host.")}
                else {$speak.Speak("PoSh-ACME has completed $($CountCommandQueries) $($TTSQuerySingularPlural) against $($CountComputerListCheckedBoxesSelected) $($TTSTargetComputerSingularPlural).")}
            }        
        }
    }
    $Section2TabControl.SelectedTab   = $Section2MainTab
}
# This needs to be here to execute the script
# Note the Execution button itself is located in the Select Computer section
$ComputerListExecuteButton.Add_Click($ExecuteScriptHandler)

#Save the initial state of the form
$InitialFormWindowState = $PoShACME.WindowState

#Init the OnLoad event to correct the initial state of the form
$PoShACME.add_Load($OnLoadForm_StateCorrection)

#Show the Form
$PoShACME.ShowDialog() | Out-Null 


} # END Function

# Call the PoSh-ACME Function
PoSh-ACME_GUI

