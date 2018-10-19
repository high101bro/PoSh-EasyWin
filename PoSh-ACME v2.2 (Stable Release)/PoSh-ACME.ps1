

# Check if the script is running with Administrator Privlieges, if not it will attempt to re-run and prompt for credentials
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic")
    $verify = [Microsoft.VisualBasic.Interaction]::MsgBox(`
        "Attention Under-Privileged User!`n   $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)`n`nThis script requires Administrator privileges in order to remotely collect data corretcly! Otherwise, the script-up will start and may not collect data as expected.",`
        'YesNoCancel,Question',`
        "PoSH-ACME")
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


# ============================================================================================================================================================
# Variables
# ============================================================================================================================================================

# Universally sets the ErrorActionPreference to Silently Continue
$ErrorActionPreference = "SilentlyContinue"
   
# Location PoSh-ACME will save files
$PoShHome             = Split-Path -parent $MyInvocation.MyCommand.Definition

# Name of Collected Data Directory
$CollectedData        = "Collected Data"
    
# Location of separate queries
$PoShLocation         = "$PoShHome\$CollectedData\$((Get-Date).ToString('yyyy-MM-dd @ HHmm ss'))"

# Location of Uncompiled Results
$CollectedResultsUncompiled = "Individual Host Results"

# Files
$LogFile              = "$PoShHome\Log File.txt"
$IPListFile           = "$PoShHome\iplist.txt"
$OpNotesFile          = "$PoShHome\OpNotes.txt"
$OpNotesWriteOnlyFile = "$PoShHome\OpNotes (Write Only).txt"

# Logs what account ran the script and when
$LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - PoSh-ACME executed by: $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"
$LogMessage | Add-Content -Path $LogFile


# The Font Used
$Font = "Courier"

$SleepTime = 5

# Number of jobs simultaneously when collecting data
$ThrottleLimit = 100

# Clears out Computer List variable
$ComputerList = ""

# Credentials will be stored in this variable
$Credential = ""


# ============================================================================================================================================================
# ============================================================================================================================================================
# Function Name 'ListComputers' - Takes entered domain and lists all computers
# ============================================================================================================================================================
# ============================================================================================================================================================

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
        $MainListBox.Items.Clear()
        $MainListBox.Items.Add("Your file was empty. You must select a file with at least one computer in it.")        
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


# ============================================================================================================================================================
# Function Name 'SingleEntry' - Enumerates Computer from user input
# ============================================================================================================================================================
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



# ============================================================================================================================================================
# Create Directory and Files
# ============================================================================================================================================================
New-Item -ItemType Directory -Path "$PoShHome" -Force | Out-Null 


# ============================================================================================================================================================
# ============================================================================================================================================================
# ============================================================================================================================================================
# ============================================================================================================================================================

# Reloads PoSh-ACME
Function ReloadPoShACME {
	$PoShACME.Close()
	$PoShACME.Dispose()
    PoSh-ACME_GUI
}


function PoSh-ACME_GUI {

[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null


$OnLoadForm_StateCorrection=
{ #Correct the initial state of the form to prevent the .Net maximized form issue
    $PoShACME.WindowState = $InitialFormWindowState
}


# ============================================================================================================================================================
# ============================================================================================================================================================
# This is the overall window for PoSh-ACME
# ============================================================================================================================================================
# ============================================================================================================================================================
# Varables for overall windows
$PoShACMERightPosition = 10
$PoShACMEDownPosition  = 10
$PoShACMEBoxWidth      = 1160
$PoShACMEBoxHeight     = 638

$PoShACME             = New-Object System.Windows.Forms.Form
$PoShACME.Text         = "PoSh-ACME   [$([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)]"
$PoShACME.Name         = "PoSh-ACME"
$PoShACME.Location     = New-Object System.Drawing.Size($PoShACMERightPosition,$PoShACMEDownPosition) 
$PoShACME.Size         = New-Object System.Drawing.Size($PoShACMEBoxWidth,$PoShACMEBoxHeight) 
$PoShACME.ClientSize   = $System_Drawing_Size
$PoShACME.DataBindings.DefaultDataSourceUpdateMode = 0
$PoShACME.Top = $true


##############################################################################################################################################################
##############################################################################################################################################################
##############################################################################################################################################################
##
## Section 1 Tab Control
##
##############################################################################################################################################################
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

$Section1TabControl.TabIndex      = 4
$PoShACME.Controls.Add($Section1TabControl)


##############################################################################################################################################################
##############################################################################################################################################################
##
## Section 1 Collections SubTab
##
##############################################################################################################################################################
##############################################################################################################################################################

$Section1CollectionsTab          = New-Object System.Windows.Forms.TabPage
$Section1CollectionsTab.Text     = "Collections"
$Section1CollectionsTab.Name     = "Collections Tab"
$Section1CollectionsTab.TabIndex = 0
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
$Section1CollectionsTabControl.TabIndex      = 4
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

$Section1QueriesTab          = New-Object System.Windows.Forms.TabPage
$Section1QueriesTab.Location = $System_Drawing_Point
$Section1QueriesTab.Text     = "Queries"

$Section1QueriesTab.Location  = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$Section1QueriesTab.Size      = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 
$Section1QueriesTab.TabIndex = 0
$Section1QueriesTab.UseVisualStyleBackColor = $True
$Section1CollectionsTabControl.Controls.Add($Section1QueriesTab)



# ============================================================================================================================================================
# ============================================================================================================================================================
# Column 1
# ============================================================================================================================================================
# ============================================================================================================================================================

# Varables to Control Column 1
$Column1RightPosition     = 3
$Column1DownPositionStart = 0      
$Column1DownPosition      = -10
$Column1DownPositionShift = 17
$Column1BoxWidth          = 220
$Column1BoxHeight         = 20


#---------------------
# Quick Options Label
#---------------------

$QueryLabel           = New-Object System.Windows.Forms.Label
$QueryLabel.Location  = New-Object System.Drawing.Point($Column1RightPosition,$Column1DownPositionStart) #Note Start Position 
$QueryLabel.Size      = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 
$QueryLabel.Text      = "Quick Options"
$QueryLabel.Font      = New-Object System.Drawing.Font("$Font",11,1,3,1)
$QueryLabel.ForeColor = "Blue"
$Section1QueriesTab.Controls.Add($QueryLabel)


# Shift the fields
$Column1DownPosition += $Column1DownPositionShift + 10


#-----------------------------
# Hunt the Bad Stuff Checkbox
#-----------------------------

$HuntCheckBox          = New-Object System.Windows.Forms.Checkbox
$HuntCheckBox.Name     = "Hunt the Bad Stuff"
$HuntCheckBox.Text     = "$($HuntCheckBox.Name)"
$HuntCheckBox.TabIndex = 2
$HuntCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$HuntCheckBox.Location = New-Object System.Drawing.Size(($Column1RightPosition),$Column1DownPosition)
$HuntCheckBox.Size     = New-Object System.Drawing.Size(130,$Column1BoxHeight)
$HuntCheckBox.Add_Click({
    If ($HuntCheckBox.Checked -eq $true){
        $ClearCheckBox.Checked                 = $false
        $SurveyCheckBox.Checked                = $false
        $TestConnectionsCheckbox.Checked       = $false
        $ProcessesStandardCheckBox.Checked     = $true
        $ServicesCheckBox.Checked              = $true
        $NetworkConnectionsTCPCheckBox.Checked = $true
        $NetworkConnectionsUDPCheckBox.Checked = $true
    }
})
$Section1QueriesTab.Controls.Add($HuntCheckBox)


#---------------------
# Select All Checkbox
#---------------------

$SurveyCheckBox          = New-Object System.Windows.Forms.Checkbox
$SurveyCheckBox.Name     = "Select All (Not Recommended)"
$SurveyCheckBox.Text     = "$($SurveyCheckBox.Name)"
$SurveyCheckBox.TabIndex = 2
$SurveyCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$SurveyCheckBox.Location = New-Object System.Drawing.Size(($Column1RightPosition + 140),$Column1DownPosition)
$SurveyCheckBox.Size     = New-Object System.Drawing.Size(200,$Column1BoxHeight)
$SurveyCheckBox.Add_Click({
    If ($SurveyCheckBox.Checked -eq $true){
        $ClearCheckBox.Checked                      = $false
        $HuntCheckBox.Checked                       = $false
        $TestConnectionsCheckbox.Checked            = $true
        $ProcessTreeLineageCheckBox.Checked         = $true
        $ProcessesStandardCheckBox.Checked          = $true
        $ProcessesEnhancedCheckBox.Checked          = $true
        $ProcessorCPUInfoCheckBox.Checked           = $true
        $ServicesCheckBox.Checked                   = $true
        $NetworkConnectionsTCPCheckBox.Checked      = $true
        $NetworkConnectionsUDPCheckBox.Checked      = $true
        $NetworkSettingsCheckBox.Checked            = $true
        $NetworkStatisticsIPv4CheckBox.Checked      = $true
        $NetworkStatisticsIPv4TCPCheckBox.Checked   = $true
        $NetworkStatisticsIPv4UDPCheckBox.Checked   = $true
        $NetworkStatisticsIPv4ICMPCheckBox.Checked  = $true
        $NetworkStatisticsIPv6CheckBox.Checked      = $true
        $NetworkStatisticsIPv6TCPCheckBox.Checked   = $true
        $NetworkStatisticsIPv6UDPCheckBox.Checked   = $true
        $NetworkStatisticsIPv6ICMPCheckBox.Checked  = $true
        $ComputerInfoCheckBox.Checked               = $true
        $SecurityPatchesCheckBox.Checked            = $true
        $LogonInfoCheckBox.Checked                  = $true
        $LogonSessionsCheckBox.Checked              = $true
        $LogonUserStatusCheckBox.Checked            = $true
        $CheckBoxNum09.Checked                      = $true
        $CheckBoxNum10.Checked                      = $true
        $GroupInfoCheckBox.Checked                  = $true
        $ARPCacheCheckBox.Checked                   = $true
        $AutorunsCheckBox.Checked                   = $true
        $DatesCheckBox.Checked                      = $true
        $EnvironmentalVariablesCheckBox.Checked     = $true
        $BIOSInfoCheckBox.Checked                   = $true
        $DriversDetailedCheckBox.Checked            = $true
        $DriversValidSignaturesCheckBox.Checked     = $true
        $MemoryCapacityInfoCheckBox.Checked         = $true
        $MemoryPhysicalInfoCheckBox.Checked         = $true
        $MemoryUtilizationCheckBox.Checked          = $true
        $MemoryPerformanceDataCheckBox.Checked      = $true
        $DiskInfoCheckBox.Checked                   = $true
        $DNSCacheCheckBox.Checked                   = $true
        $MappedDrivesCheckBox.Checked               = $true
        $CheckBoxNum24.Checked                      = $true
        $ScreenSaverInfoCheckBox.Checked            = $true
        $SharesCheckBox.Checked                     = $true
        $PlugAndPlayCheckBox.Checked                = $true
        $USBControllerDevicesCheckBox.Checked       = $true
        $SoftwareInstalledCheckBox.Checked          = $true
        $EventLogsSecurityCheckBox.Checked          = $true
        $EventLogsSystemCheckBox.Checked            = $true
        $EventLogsApplicationCheckBox.Checked       = $true
        $EventLogsSystemErrorsCheckBox.Checked      = $true
        $EventLogsApplicationErrorsCheckBox.Checked = $true
        $PrefetchFilesCheckBox.Checked              = $true
        $FirewallStatusCheckBox.Checked             = $true
        $FirewallRulesCheckBox.Checked              = $true
        $PortProxyRulesCheckBox.Checked             = $true
        $ScheduledTasksCheckBox.Checked             = $true
        $DLLsLoadedByProcessesCheckBox.Checked      = $true
        $DriversSignedInfoCheckBox.Checked          = $true
        $SystemInfoCheckBox.Checked                 = $true
    }
})
$Section1QueriesTab.Controls.Add($SurveyCheckBox)


#----------------
# Clear Checkbox
#----------------

$ClearCheckBox          = New-Object System.Windows.Forms.Checkbox
$ClearCheckBox.Name     = "Clear"
$ClearCheckBox.Text     = "$($ClearCheckBox.Name)"
$ClearCheckBox.TabIndex = 2
$ClearCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$ClearCheckBox.Location = New-Object System.Drawing.Size(($Column1RightPosition + 340),$Column1DownPosition)
$ClearCheckBox.Size     = New-Object System.Drawing.Size(80,$Column1BoxHeight)
$ClearCheckBox.Add_Click({
    If ($ClearCheckBox.Checked -eq $true){
        $HuntCheckBox.Checked                       = $false
        $SurveyCheckBox.Checked                     = $false
        $TestConnectionsCheckbox.Checked            = $false
        $ProcessTreeLineageCheckBox.Checked         = $false
        $ProcessesStandardCheckBox.Checked          = $false
        $ProcessesEnhancedCheckBox.Checked          = $false
        $ProcessorCPUInfoCheckBox.Checked           = $false
        $ServicesCheckBox.Checked                   = $false
        $NetworkConnectionsTCPCheckBox.Checked      = $false
        $NetworkConnectionsUDPCheckBox.Checked      = $false
        $NetworkSettingsCheckBox.Checked            = $false
        $NetworkStatisticsIPv4CheckBox.Checked      = $false
        $NetworkStatisticsIPv4TCPCheckBox.Checked   = $false
        $NetworkStatisticsIPv4UDPCheckBox.Checked   = $false
        $NetworkStatisticsIPv4ICMPCheckBox.Checked  = $false
        $NetworkStatisticsIPv6CheckBox.Checked      = $false
        $NetworkStatisticsIPv6TCPCheckBox.Checked   = $false
        $NetworkStatisticsIPv6UDPCheckBox.Checked   = $false
        $NetworkStatisticsIPv6ICMPCheckBox.Checked  = $false
        $ComputerInfoCheckBox.Checked               = $false
        $SecurityPatchesCheckBox.Checked            = $false
        $LogonInfoCheckBox.Checked                  = $false
        $LogonSessionsCheckBox.Checked              = $false
        $LogonUserStatusCheckBox.Checked            = $false
        $CheckBoxNum09.Checked                      = $false
        $CheckBoxNum10.Checked                      = $false
        $GroupInfoCheckBox.Checked                  = $false
        $ARPCacheCheckBox.Checked                   = $false
        $AutorunsCheckBox.Checked                   = $false
        $DatesCheckBox.Checked                      = $false
        $DNSCacheCheckBox.Checked                   = $false
        $EnvironmentalVariablesCheckBox.Checked     = $false
        $BIOSInfoCheckBox.Checked                   = $false
        $DriversDetailedCheckBox.Checked            = $false
        $DriversValidSignaturesCheckBox.Checked     = $false
        $MemoryCapacityInfoCheckBox.Checked         = $false
        $MemoryPhysicalInfoCheckBox.Checked         = $false
        $MemoryUtilizationCheckBox.Checked          = $false
        $MemoryPerformanceDataCheckBox.Checked      = $false
        $DiskInfoCheckBox.Checked                   = $false
        $MappedDrivesCheckBox.Checked               = $false
        $CheckBoxNum24.Checked                      = $false
        $ScreenSaverInfoCheckBox.Checked            = $false
        $SharesCheckBox.Checked                     = $false
        $PlugAndPlayCheckBox.Checked                = $false
        $USBControllerDevicesCheckBox.Checked       = $false
        $SoftwareInstalledCheckBox.Checked          = $false
        $EventLogsSecurityCheckBox.Checked          = $false
        $EventLogsSystemCheckBox.Checked            = $false
        $EventLogsApplicationCheckBox.Checked       = $false
        $EventLogsSystemErrorsCheckBox.Checked      = $false
        $EventLogsApplicationErrorsCheckBox.Checked = $false
        $PrefetchFilesCheckBox.Checked              = $false
        $FirewallStatusCheckBox.Checked             = $false
        $FirewallRulesCheckBox.Checked              = $false
        $PortProxyRulesCheckBox.Checked             = $false
        $ScheduledTasksCheckBox.Checked             = $false
        $DLLsLoadedByProcessesCheckBox.Checked      = $false
        $DriversSignedInfoCheckBox.Checked          = $false
        $SystemInfoCheckBox.Checked                 = $false
    }
})
$Section1QueriesTab.Controls.Add($ClearCheckBox)


# Shift the Text and Button's Locaiton
$Column1DownPosition += $Column1DownPositionShift + 5


#------------------------------
# Select What to Collect Label
#------------------------------

$QueryLabel           = New-Object System.Windows.Forms.Label
$QueryLabel.Location  = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$QueryLabel.Size      = New-Object System.Drawing.Size(180,$Column1BoxHeight) 
$QueryLabel.Text      = "Select What To Collect:"
$QueryLabel.Font = New-Object System.Drawing.Font("$Font",11,1,3,1)
$QueryLabel.ForeColor = "Blue"
$Section1QueriesTab.Controls.Add($QueryLabel)


$QueryLabel2           = New-Object System.Windows.Forms.Label
$QueryLabel2.Location  = New-Object System.Drawing.Size(($Column1RightPosition + 180),($Column1DownPosition + 4)) 
$QueryLabel2.Size      = New-Object System.Drawing.Size(400,($Column1BoxHeight - 4)) 
$QueryLabel2.Text      = "* = Needs to be on the Domain"
$QueryLabel2.Font = New-Object System.Drawing.Font("$Font",8,0,3,0)
$QueryLabel2.ForeColor = "Blue"
$Section1QueriesTab.Controls.Add($QueryLabel2)  

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift




# ============================================================================================================================================================
# ARP Cache 
# ============================================================================================================================================================

$ARPCacheCheckBox            = New-Object System.Windows.Forms.CheckBox
$ARPCacheCheckBox.Name       = "ARP Cache *"

function ARPCacheCommand {
    $Message1            = "$($ARPCacheCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "ARP Cache"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Sending Command:  $($ARPCacheCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Invoke-Command -Credential $Credential -ComputerName $TargetComputer -ScriptBlock {
                    cmd /c arp -a
                } -ArgumentList @($null) | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"

                if ((Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") -eq $null) {
                    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
                }
                else {                                           
                    # Imports the text file
                    $ARPCache = (Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") 

                    # Creates the fields that become the file headers
                    $ARPCacheHeader = "Interface,Internet Address,Physical Address,Type"

                    # Extracts the data 
                    $ARPCacheData = @()
                    $ARPCacheInterface = ""
                    foreach ($line in $ARPCache) {
                        if ($line -match "---") {
                            $ARPCacheInterface = $line
                        }
                        if (($line -notmatch "---") -and ($line -notmatch "Type") -and ($line -match "  ")) {
                            $ARPCacheData += "$ARPCacheInterface   $line"
                        }
                    }
                    #Combines the File Header and Data
                    $ARPCacheCombined = @()
                    $ARPCacheCombined += $ARPCacheHeader
                    $ARPCacheCombined += $ARPCacheData
        
                    # Converts to CSV and removes unneeded data
                    $ARPCacheBuffer = @()

                    foreach ($line in $ARPCacheCombined) {
                        $ARPCacheBuffer += $line -replace " {2,}","," -replace ",$","" -replace "Interface: ",""
                    }
                    $ARPCacheBuffer | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"
        
                    # Add PSComputerName header and host/ip name
                    $ARPCacheFile = Import-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"
                    $ARPCacheFile | Add-Member -MemberType NoteProperty -Name "PSComputerName" -Value "$TargetComputer"
                    $ARPCacheFile | Select-Object "PSComputerName",*| Export-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation
                }
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'

                Invoke-Command -ComputerName $TargetComputer -ScriptBlock {
                    cmd /c arp -a
                } -ArgumentList @($null) | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"

                if ((Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") -eq $null) {
                    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
                }
                else {                                           
                    # Imports the text file
                    $ARPCache = (Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") 

                    # Creates the fields that become the file headers
                    $ARPCacheHeader = "Interface,Internet Address,Physical Address,Type"

                    # Extracts the data 
                    $ARPCacheData = @()
                    $ARPCacheInterface = ""
                    foreach ($line in $ARPCache) {
                        if ($line -match "---") {
                            $ARPCacheInterface = $line
                        }
                        if (($line -notmatch "---") -and ($line -notmatch "Type") -and ($line -match "  ")) {
                            $ARPCacheData += "$ARPCacheInterface   $line"
                        }
                    }
                    #Combines the File Header and Data
                    $ARPCacheCombined = @()
                    $ARPCacheCombined += $ARPCacheHeader
                    $ARPCacheCombined += $ARPCacheData
        
                    # Converts to CSV and removes unneeded data
                    $ARPCacheBuffer = @()

                    foreach ($line in $ARPCacheCombined) {
                        $ARPCacheBuffer += $line -replace " {2,}","," -replace ",$","" -replace "Interface: ",""
                    }
                    $ARPCacheBuffer | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"
        
                    # Add PSComputerName header and host/ip name
                    $ARPCacheFile = Import-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"
                    $ARPCacheFile | Add-Member -MemberType NoteProperty -Name "PSComputerName" -Value "$TargetComputer"
                    $ARPCacheFile | Select-Object "PSComputerName",*| Export-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation
                }
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs

    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($ARPCacheCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
    Remove-DuplicateCsvHeaders
}

$ARPCacheCheckBox.Text     = "$($ARPCacheCheckBox.Name)"
$ARPCacheCheckBox.TabIndex = 2
$ARPCacheCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$ARPCacheCheckBox.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$ARPCacheCheckBox.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 

$Section1QueriesTab.Controls.Add($ARPCacheCheckBox)




# ============================================================================================================================================================
# Autoruns - Startup
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$AutorunsCheckBox = New-Object System.Windows.Forms.CheckBox
$AutorunsCheckBox.Name = "Autoruns - Startup"

function AutorunsCommand {
    $Message1            = "$($AutorunsCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Autoruns - Startup"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''
    
    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null
    
    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($AutorunsCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'

                Get-WmiObject -Credential $Credential -Class Win32_StartupCommand -ComputerName $TargetComputer `
                | Select-Object PSComputerName, Name, Location, Command, User `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Class Win32_StartupCommand -ComputerName $TargetComputer `
                | Select-Object PSComputerName, Name, Location, Command, User `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs

    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($AutorunsCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$AutorunsCheckBox.Text     = "$($AutorunsCheckBox.Name)"
$AutorunsCheckBox.TabIndex = 2
$AutorunsCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$AutorunsCheckBox.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$AutorunsCheckBox.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 

$Section1QueriesTab.Controls.Add($AutorunsCheckBox)




# ============================================================================================================================================================
# BIOS Information
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$BIOSInfoCheckBox = New-Object System.Windows.Forms.CheckBox
$BIOSInfoCheckBox.Name = "BIOS Information"

function BIOSInfoCommand {
    $Message1            = "$($BIOSInfoCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "BIOS Information"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue


    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($BIOSInfoCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Credential $Credential -Class Win32_BIOS -ComputerName $TargetComputer `
                | Select-Object -Property PSComputerName,  SMBIOSBIOSVersion, Name, Manufacturer, SerialNumber, Version, Description, ReleaseDate, InstallDate `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Class Win32_BIOS -ComputerName $TargetComputer `
                | Select-Object -Property PSComputerName,  SMBIOSBIOSVersion, Name, Manufacturer, SerialNumber, Version, Description, ReleaseDate, InstallDate `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs
    
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($BIOSInfoCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$BIOSInfoCheckBox.Text     = "$($BIOSInfoCheckBox.Name)"
$BIOSInfoCheckBox.TabIndex = 2
$BIOSInfoCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$BIOSInfoCheckBox.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$BIOSInfoCheckBox.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 

$Section1QueriesTab.Controls.Add($BIOSInfoCheckBox)




# ============================================================================================================================================================
# Computer Informatioin
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$ComputerInfoCheckBox = New-Object System.Windows.Forms.CheckBox
$ComputerInfoCheckBox.Name = "Computer Information"

function ComputerInfoCommand {
    $Message1            = "$($ComputerInfoCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Computer Information"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($ComputerInfoCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Credential $Credential -Class Win32_ComputerSystem -ComputerName $TargetComputer `
                | Select-Object PSComputerName, Description, Manufacturer, Model, SystemType, NumberOfProcessors, TotalPhysicalMemory, EnableDaylightSavingsTime, BootupState, PartOfDomain, Domain, Username, PrimaryOwnerName `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Class Win32_ComputerSystem -ComputerName $TargetComputer `
                | Select-Object PSComputerName, Description, Manufacturer, Model, SystemType, NumberOfProcessors, TotalPhysicalMemory, EnableDaylightSavingsTime, BootupState, PartOfDomain, Domain, Username, PrimaryOwnerName `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs
    
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($ComputerInfoCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
$ComputerInfoCheckBox.Text     = "$($ComputerInfoCheckBox.Name)"
$ComputerInfoCheckBox.TabIndex = 2
$ComputerInfoCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$ComputerInfoCheckBox.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$ComputerInfoCheckBox.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 

$Section1QueriesTab.Controls.Add($ComputerInfoCheckBox)




# ============================================================================================================================================================
# Dates - Install, Bootup, System
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$DatesCheckBox = New-Object System.Windows.Forms.CheckBox
$DatesCheckBox.Name = "Dates - Install, Bootup, System"

function DatesCommand {
    $Message1            = "$($DatesCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Dates - Install, Bootup, System"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($DatesCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                function CollectDateTimes {
                    $DateTimes=Get-WmiObject -Credential $Credential -Class Win32_OperatingSystem -ComputerName $TargetComputer `
                    | Select-Object PSComputerName, InstallDate, LastBootUpTime, LocalDateTime
                    foreach ($time in $DateTimes) {
                        $InstallDate=[System.Management.ManagementDateTimeConverter]::ToDateTime($time.InstallDate)
                        $LastBootUpTime=[System.Management.ManagementDateTimeConverter]::ToDateTime($time.LastBootUpTime)
                        $LocalDateTime=[System.Management.ManagementDateTimeConverter]::ToDateTime($time.LocalDateTime)
                        $DateTimeOutput=@()
                        $DateTimeOutput += New-Object psobject -Property @{PSComputerName=$TargetComputer
                        InstallDate=$InstallDate
                        LastBootUpTime=$LastBootUpTime
                        LocalDateTime=$LocalDateTime}
                        $DateTimeOutput
                    }
                }
                CollectDateTimes | Select-Object -Property PSComputerName, * | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                function CollectDateTimes {
                    $DateTimes=Get-WmiObject -class Win32_OperatingSystem -ComputerName $TargetComputer `
                    | Select-Object PSComputerName, InstallDate, LastBootUpTime, LocalDateTime
                    foreach ($time in $DateTimes) {
                        $InstallDate=[System.Management.ManagementDateTimeConverter]::ToDateTime($time.InstallDate)
                        $LastBootUpTime=[System.Management.ManagementDateTimeConverter]::ToDateTime($time.LastBootUpTime)
                        $LocalDateTime=[System.Management.ManagementDateTimeConverter]::ToDateTime($time.LocalDateTime)
                        $DateTimeOutput=@()
                        $DateTimeOutput += New-Object psobject -Property @{PSComputerName=$TargetComputer
                        InstallDate=$InstallDate
                        LastBootUpTime=$LastBootUpTime
                        LocalDateTime=$LocalDateTime}
                        $DateTimeOutput
                    }
                }
                CollectDateTimes | Select-Object -Property PSComputerName, * | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs
    
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($DatesCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$DatesCheckBox.Text     = "$($DatesCheckBox.Name)"
$DatesCheckBox.TabIndex = 2
$DatesCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$DatesCheckBox.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$DatesCheckBox.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 

$Section1QueriesTab.Controls.Add($DatesCheckBox)




# ============================================================================================================================================================
# Disk Information
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition += $Column1DownPositionShift


$DiskInfoCheckBox = New-Object System.Windows.Forms.CheckBox
$DiskInfoCheckBox.Name = "Disk Information"

function DiskInfoCommand {
    $Message1            = "$($DiskInfoCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Disk Information"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($DiskInfoCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Credential $Credential -Class Win32_LogicalDisk -ComputerName $TargetComputer `
                | Select-Object PSComputerName, DeviceID, Description, ProviderName, FreeSpace, Size, DriveType `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Class Win32_LogicalDisk -ComputerName $TargetComputer `
                | Select-Object PSComputerName, DeviceID, Description, ProviderName, FreeSpace, Size, DriveType `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs
    
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($DiskInfoCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$DiskInfoCheckBox.Text     = "$($DiskInfoCheckBox.Name)"
$DiskInfoCheckBox.TabIndex = 2
$DiskInfoCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$DiskInfoCheckBox.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$DiskInfoCheckBox.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 

$Section1QueriesTab.Controls.Add($DiskInfoCheckBox)




# ============================================================================================================================================================
# DLLs Loaded by Processes
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition += $Column1DownPositionShift


$DLLsLoadedByProcessesCheckBox = New-Object System.Windows.Forms.CheckBox
$DLLsLoadedByProcessesCheckBox.Name = "DLLs Loaded by Processes *"

function DLLsLoadedByProcessesCommand {
    $Message1            = "$($DLLsLoadedByProcessesCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "DLLs Loaded by Processes"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($DLLsLoadedByProcessesCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Invoke-Command -Credential $Credential -ComputerName $TargetComputer -ScriptBlock {
                    param($TargetComputer)
                    function Get-FileHash{
                        param ([string] $Path ) $HashAlgorithm = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
                        $Hash=[System.BitConverter]::ToString($hashAlgorithm.ComputeHash([System.IO.File]::ReadAllBytes($Path)))
                        $Properties=@{"Algorithm" = "MD5"
                        "Path" = $Path
                        "Hash" = $Hash.Replace("-", "")
                        }
                    $Ret=New-Object –TypeName PSObject –Prop $Properties
                    return $Ret
                    }

                    $LoadedModules = "PSComputerName,ProcessName,Path,Hash,Algorithm`r`n"
                    Get-Process | foreach {
                        $ProcessName = $_.ProcessName
                        $Modules = $_ | Select-Object -ExpandProperty Modules | foreach {Get-FileHash $_.Filename}
                        foreach ($Module in $Modules) {
                            $LoadedModules += "$TargetComputer," + "$ProcessName," + "$($Module -replace '@{','' -replace 'Path=','' -replace '; ',',' -replace '}','')" + "`r`n"        
                        }
                    }
                    $LoadedModules 
                } -ArgumentList @($TargetComputer) | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"
                if ((Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv") -eq $null) {
                    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"
                }
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                
                Invoke-Command -ComputerName $TargetComputer -ScriptBlock {
                    param($TargetComputer)
                    function Get-FileHash{
                        param ([string] $Path ) $HashAlgorithm = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
                        $Hash=[System.BitConverter]::ToString($hashAlgorithm.ComputeHash([System.IO.File]::ReadAllBytes($Path)))
                        $Properties=@{"Algorithm" = "MD5"
                        "Path" = $Path
                        "Hash" = $Hash.Replace("-", "")
                        }
                    $Ret=New-Object –TypeName PSObject –Prop $Properties
                    return $Ret
                    }

                    $LoadedModules = "PSComputerName,ProcessName,ModulePath,Hash,Algorithm`r`n"
                    Get-Process | foreach {
                        $ProcessName = $_.ProcessName
                        $Modules = $_ | Select-Object -ExpandProperty Modules | foreach {Get-FileHash $_.Filename}
                        foreach ($Module in $Modules) {
                            $LoadedModules += "$TargetComputer," + "$ProcessName," + "$($Module -replace '@{','' -replace '; ',',' -replace '}','' -replace 'Path=','' -replace 'Hash=','' -replace 'Algorithm=','')" + "`r`n"        
                        }
                    }
                    $LoadedModules 
                } -ArgumentList @($TargetComputer) `
                | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"
                if ((Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv") -eq $null) {
                    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"
                }
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs

    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($DLLsLoadedByProcessesCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
$DLLsLoadedByProcessesCheckBox.Text     = "$($DLLsLoadedByProcessesCheckBox.Name)"
$DLLsLoadedByProcessesCheckBox.TabIndex = 2
$DLLsLoadedByProcessesCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$DLLsLoadedByProcessesCheckBox.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$DLLsLoadedByProcessesCheckBox.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 

$Section1QueriesTab.Controls.Add($DLLsLoadedByProcessesCheckBox)




# ============================================================================================================================================================
# DNS Cache 
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$DNSCacheCheckBox            = New-Object System.Windows.Forms.CheckBox
$DNSCacheCheckBox.Name       = "DNS Cache *"

function DNSCacheCommand {
    $Message1            = "$($DNSCacheCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "DNS Cache"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($DNSCacheCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'

                Invoke-Command -Credential $Credential -ComputerName $TargetComputer -ScriptBlock {
                    cmd /c ipconfig /displaydns
                } -ArgumentList @($null) | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"

                if ((Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") -eq $null) {
                    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
                }
                else {
                    # Imports the text file
                    $DNSCache = (Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") 

                    # Creates the fields that become the file headers
                    $DNSCacheHeader = "RecordName,RecordType,TimeToLive,DataLength,Section,A(Host)/CNAMERecord"
        
                    # Extracts the data 
                    $DNSCacheData = ""
                    $DNSCacheInterface = ""
                    $RecordName = ""
                    foreach ($line in $DNSCache) {
                        if ($line -match "---"){
                            $DNSCacheData += $line -replace "-{2,}","`n"
                        }
                        if ($line -match ':'){
                            if ($line -match "Record Name") {
                                if ($(($line -split ':')[1]) -eq $RecordName) {
                                    $DNSCacheData += "`n$(($line -split ':')[1] -replace `"^ | $`",`"`"),"
                                }
                                else {
                                    $RecordName = ($line -split ':')[1]
                                    $DNSCacheData += "$(($line -split ':')[1] -replace `"^ | $`",`"`"),"
                                }    
                            }
                            if ($line -match "Record Type") {
                                $DNSCacheData += "$(($line -split ':')[1] -replace `"^ | $`",`"`"),"
                            }
                            if ($line -match "Time To Live") {
                                $DNSCacheData += "$(($line -split ':')[1] -replace `"^ | $`",`"`"),"
                            }
                            if (($line -match "Data") -and ($line -match "Length")) {
                                $DNSCacheData += "$(($line -split ':')[1] -replace `"^ | $`",`"`"),"
                            }
                            if ($line -match "Section") {
                                $DNSCacheData += "$(($line -split ':')[1] -replace `"^ | $`",`"`"),"
                            }
                            if (($line -match "Host") -and ($line -match "Record")) {
                                $DNSCacheData += "$(($line -split ':')[1] -replace `"^ | $`",`"`")"
                            }
                            if (($line -match "CNAME") -and ($line -match "Record")) {
                                $DNSCacheData += "$(($line -split ':')[1] -replace `"^ | $`",`"`")"
                            }
                        }
                    }
                    #Combines the File Header and Data
                    $DNSCacheCombined = @()
                    $DNSCacheCombined += $DNSCacheHeader
                    $DNSCacheCombined += $DNSCacheData
        
                    # Converts to CSV
                    $DNSCacheBuffer = @()
                    foreach ($line in $DNSCacheCombined) {
                        $DNSCacheBuffer += $line 
                    }
                    $DNSCacheBuffer | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"
   
                    # Add PSComputerName header and host/ip name
                    $DNSCacheFile = Import-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" | Select-Object -Skip 1 | Where-Object {$_.PSObject.Properties.Value -ne $null}
                    $DNSCacheFile | Add-Member -MemberType NoteProperty -Name "PSComputerName" -Value "$TargetComputer"
                    $DNSCacheFile | Select-Object "PSComputerName",* | Export-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation
                }
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'

                Invoke-Command -ComputerName $TargetComputer -ScriptBlock {
                    cmd /c ipconfig /displaydns
                } -ArgumentList @($null) | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"

                if ((Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") -eq $null) {
                    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
                }
                else {
                    # Imports the text file
                    $DNSCache = (Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") 

                    # Creates the fields that become the file headers
                    $DNSCacheHeader = "RecordName,RecordType,TimeToLive,DataLength,Section,A(Host)/CNAMERecord"
        
                    # Extracts the data 
                    $DNSCacheData = ""
                    $DNSCacheInterface = ""
                    $RecordName = ""
                    foreach ($line in $DNSCache) {
                        if ($line -match "---"){
                            $DNSCacheData += $line -replace "-{2,}","`n"
                        }
                        if ($line -match ':'){
                            if ($line -match "Record Name") {
                                if ($(($line -split ':')[1]) -eq $RecordName) {
                                    $DNSCacheData += "`n$(($line -split ':')[1] -replace `"^ | $`",`"`"),"
                                }
                                else {
                                    $RecordName = ($line -split ':')[1]
                                    $DNSCacheData += "$(($line -split ':')[1] -replace `"^ | $`",`"`"),"
                                }    
                            }
                            if ($line -match "Record Type") {
                                $DNSCacheData += "$(($line -split ':')[1] -replace `"^ | $`",`"`"),"
                            }
                            if ($line -match "Time To Live") {
                                $DNSCacheData += "$(($line -split ':')[1] -replace `"^ | $`",`"`"),"
                            }
                            if (($line -match "Data") -and ($line -match "Length")) {
                                $DNSCacheData += "$(($line -split ':')[1] -replace `"^ | $`",`"`"),"
                            }
                            if ($line -match "Section") {
                                $DNSCacheData += "$(($line -split ':')[1] -replace `"^ | $`",`"`"),"
                            }
                            if (($line -match "Host") -and ($line -match "Record")) {
                                $DNSCacheData += "$(($line -split ':')[1] -replace `"^ | $`",`"`")"
                            }
                            if (($line -match "CNAME") -and ($line -match "Record")) {
                                $DNSCacheData += "$(($line -split ':')[1] -replace `"^ | $`",`"`")"
                            }
                        }
                    }
                    #Combines the File Header and Data
                    $DNSCacheCombined = @()
                    $DNSCacheCombined += $DNSCacheHeader
                    $DNSCacheCombined += $DNSCacheData
        
                    # Converts to CSV
                    $DNSCacheBuffer = @()
                    foreach ($line in $DNSCacheCombined) {
                        $DNSCacheBuffer += $line 
                    }
                    $DNSCacheBuffer | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"
   
                    # Add PSComputerName header and host/ip name
                    $DNSCacheFile = Import-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" | Select-Object -Skip 1 | Where-Object {$_.PSObject.Properties.Value -ne $null}
                    $DNSCacheFile | Add-Member -MemberType NoteProperty -Name "PSComputerName" -Value "$TargetComputer"
                    $DNSCacheFile | Select-Object "PSComputerName",* | Export-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation
                }
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs

    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($DNSCacheCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$DNSCacheCheckBox.Text     = "$($DNSCacheCheckBox.Name)"
$DNSCacheCheckBox.TabIndex = 2
$DNSCacheCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$DNSCacheCheckBox.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$DNSCacheCheckBox.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 

$Section1QueriesTab.Controls.Add($DNSCacheCheckBox)




# ============================================================================================================================================================
# Drivers - Detailed
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$DriversDetailedCheckBox = New-Object System.Windows.Forms.CheckBox
$DriversDetailedCheckBox.Name = "Drivers - Detailed"

function DriversDetailedCommand {
    $Message1                = "$($DriversDetailedCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Drivers - Detailed"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($DriversDetailedCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Credential $Credential -Class Win32_Systemdriver -ComputerName $TargetComputer `
                | Select-Object PSComputerName, State, Status, Started, StartMode, Name, DisplayName, PathName, ExitCode, AcceptPause, AcceptStop, Caption, CreationClassName, Description, DesktopInteract, DisplayName, ErrorControl, InstallDate, PathName, ServiceType, InstallDate `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Class Win32_Systemdriver -ComputerName $TargetComputer `
                | Select-Object PSComputerName, State, Status, Started, StartMode, Name, DisplayName, PathName, ExitCode, AcceptPause, AcceptStop, Caption, CreationClassName, Description, DesktopInteract, DisplayName, ErrorControl, InstallDate, PathName, ServiceType, InstallDate `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs

    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($DriversDetailedCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$DriversDetailedCheckBox.Text     = "$($DriversDetailedCheckBox.Name)"
$DriversDetailedCheckBox.TabIndex = 2
$DriversDetailedCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$DriversDetailedCheckBox.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$DriversDetailedCheckBox.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 

$Section1QueriesTab.Controls.Add($DriversDetailedCheckBox)




# ============================================================================================================================================================
# Drivers - Signed Info
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$DriversSignedInfoCheckBox = New-Object System.Windows.Forms.CheckBox
$DriversSignedInfoCheckBox.Name = "Drivers - Signed Info *"

function DriversSignedCommand {
    $Message1            = "$($DriversSignedInfoCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Drivers - Signed Info"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($DriversSignedInfoCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'

                Invoke-Command -Credential $Credential -ComputerName $TargetComputer -ScriptBlock {
                    cmd /c driverquery /si /FO CSV
                } -ArgumentList @($null) | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"

                if ((Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv") -eq $null) {
                    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"
                }
                else {
                    $DriverSignedInfo = (Import-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv") 
                    $DriverSignedInfo | Add-Member -MemberType NoteProperty -Name "PSComputerName" -Value "$TargetComputer"
                    $DriverSignedInfo | Select-Object PSComputerName, IsSigned, Manufacturer, DeviceName, InfName | Export-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation
                }
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Invoke-Command -ComputerName $TargetComputer -ScriptBlock {
                    cmd /c driverquery /si /FO CSV
                } -ArgumentList @($null) | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"

                if ((Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv") -eq $null) {
                    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"
                }
                else {
                    $DriverSignedInfo = (Import-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv") 
                    $DriverSignedInfo | Add-Member -MemberType NoteProperty -Name "PSComputerName" -Value "$TargetComputer"
                    $DriverSignedInfo | Select-Object PSComputerName, IsSigned, Manufacturer, DeviceName, InfName | Export-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation
                }
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }  
    }
    MonitorJobs

    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($DriversSignedInfoCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$DriversSignedInfoCheckBox.Text     = "$($DriversSignedInfoCheckBox.Name)"
$DriversSignedInfoCheckBox.TabIndex = 2
$DriversSignedInfoCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$DriversSignedInfoCheckBox.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$DriversSignedInfoCheckBox.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 

$Section1QueriesTab.Controls.Add($DriversSignedInfoCheckBox)




# ============================================================================================================================================================
# Drivers - Valid Signatures
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$DriversValidSignaturesCheckBox = New-Object System.Windows.Forms.CheckBox
$DriversValidSignaturesCheckBox.Name = "Drivers - Valid Signatures (slow)"

function DriversValidSignaturesCommand {
    $Message1            = "$($DriversValidSignaturesCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Drivers - Valid Signatures"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($DriversValidSignaturesCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Credential $Credential -Class Win32_SystemDriver -ComputerName $TargetComputer `
                | ForEach-Object {Get-AuthenticodeSignature $_.pathname} `
                | Select-Object PSComputerName, Status, Path, @{Name="SignerCertificate";Expression={$_.SignerCertificate -join "; "}} `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Class Win32_SystemDriver -ComputerName $TargetComputer `
                | ForEach-Object {
                    $Buffer = Get-AuthenticodeSignature $_.pathname
                    $Buffer | Add-Member -MemberType NoteProperty -Name PSComputerName -Value $TargetComputer
                    $Buffer
                    } `
                | Select-Object PSComputerName, Status, Path, @{Name="SignerCertificate";Expression={$_.SignerCertificate -join "; "}} `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs
    
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($DriversValidSignaturesCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$DriversValidSignaturesCheckBox.Text     = "$($DriversValidSignaturesCheckBox.Name)"
$DriversValidSignaturesCheckBox.TabIndex = 2
$DriversValidSignaturesCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$DriversValidSignaturesCheckBox.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$DriversValidSignaturesCheckBox.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 

$Section1QueriesTab.Controls.Add($DriversValidSignaturesCheckBox)




# ============================================================================================================================================================
# Environmental Variables
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$EnvironmentalVariablesCheckBox = New-Object System.Windows.Forms.CheckBox
$EnvironmentalVariablesCheckBox.Name = "Environmental Variables"

function EnvironmentalVariablesCommand {
    $Message1            = "$($EnvironmentalVariablesCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Environmental Variables"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($EnvironmentalVariablesCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Credential $Credential -Class Win32_Environment -ComputerName $TargetComputer `
                | Select-Object PSComputerName, UserName, Name, VariableValue `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Class Win32_Environment -ComputerName $TargetComputer `
                | Select-Object PSComputerName, UserName, Name, VariableValue `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs

    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($EnvironmentalVariablesCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$EnvironmentalVariablesCheckBox.Text     = "$($EnvironmentalVariablesCheckBox.Name)"
$EnvironmentalVariablesCheckBox.TabIndex = 2
$EnvironmentalVariablesCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$EnvironmentalVariablesCheckBox.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$EnvironmentalVariablesCheckBox.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 

$Section1QueriesTab.Controls.Add($EnvironmentalVariablesCheckBox)




# ============================================================================================================================================================
# ============================================================================================================================================================
# Event Logs 
# ============================================================================================================================================================
# ============================================================================================================================================================

$LimitNumberOfEventLogsCollectToChoice = 100




# ============================================================================================================================================================
# Event Logs - Application
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$EventLogsApplicationCheckBox               = New-Object System.Windows.Forms.CheckBox
$EventLogsApplicationCheckBox.Name          = "Event Logs (100) Application"

function EventLogsApplicationCommand {
    $Message1            = "$($EventLogsApplicationCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Event Logs (100) Application"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($EventLogsApplicationCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$LimitNumberOfEventLogsCollectToChoice,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Credential $Credential -Class Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile='Application')" `
                | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type `
                | Select-Object -first $LimitNumberOfEventLogsCollectToChoice `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation


            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$LimitNumberOfEventLogsCollectToChoice,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$LimitNumberOfEventLogsCollectToChoice)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Class Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile='Application')" `
                | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type `
                | Select-Object -first $LimitNumberOfEventLogsCollectToChoice `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$LimitNumberOfEventLogsCollectToChoice)
        }   
    }
    MonitorJobs
    
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($EventLogsApplicationCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$EventLogsApplicationCheckBox.Text     = "$($EventLogsApplicationCheckBox.Name)"
$EventLogsApplicationCheckBox.TabIndex = 2
$EventLogsApplicationCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$EventLogsApplicationCheckBox.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$EventLogsApplicationCheckBox.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 

$Section1QueriesTab.Controls.Add($EventLogsApplicationCheckBox)




# ============================================================================================================================================================
# Event Logs - Application Errors
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$EventLogsApplicationErrorsCheckBox               = New-Object System.Windows.Forms.CheckBox
$EventLogsApplicationErrorsCheckBox.Name          = "Event Logs (100) Application Errors"

function EventLogsApplicationErrorsCommand {
    $Message1            = "$($EventLogsApplicationErrorsCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Event Logs (100) Application Errors"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($EventLogsApplicationErrorsCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$LimitNumberOfEventLogsCollectToChoice,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Credential $Credential -Class Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile='Application') AND (type='error')" `
                | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type `
                | Select-Object -first $LimitNumberOfEventLogsCollectToChoice `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$LimitNumberOfEventLogsCollectToChoice,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$LimitNumberOfEventLogsCollectToChoice)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Class Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile='Application') AND (type='error')" `
                | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type `
                | Select-Object -first $LimitNumberOfEventLogsCollectToChoice `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$LimitNumberOfEventLogsCollectToChoice)
        }   
    }
    MonitorJobs
    
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($EventLogsApplicationErrorsCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$EventLogsApplicationErrorsCheckBox.Text     = "$($EventLogsApplicationErrorsCheckBox.Name)"
$EventLogsApplicationErrorsCheckBox.TabIndex = 2
$EventLogsApplicationErrorsCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$EventLogsApplicationErrorsCheckBox.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$EventLogsApplicationErrorsCheckBox.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 

$Section1QueriesTab.Controls.Add($EventLogsApplicationErrorsCheckBox)




# ============================================================================================================================================================
# Event Logs - Security
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$EventLogsSecurityCheckBox = New-Object System.Windows.Forms.CheckBox
$EventLogsSecurityCheckBox.Name = "Event Logs (100) Security"

function EventLogsSecurityCommand {
    $Message1            = "$($EventLogsSecurityCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Event Logs (100) Security"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($EventLogsSecurityCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$LimitNumberOfEventLogsCollectToChoice,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Credential $Credential -Class Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile='Security')" `
                | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type `
                | Select-Object -first $LimitNumberOfEventLogsCollectToChoice `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$LimitNumberOfEventLogsCollectToChoice,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$LimitNumberOfEventLogsCollectToChoice)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Class Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile='Security')" `
                | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type `
                | Select-Object -first $LimitNumberOfEventLogsCollectToChoice `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$LimitNumberOfEventLogsCollectToChoice)
        }   
    }
    MonitorJobs
    
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($EventLogsSecurityCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$EventLogsSecurityCheckBox.Text     = "$($EventLogsSecurityCheckBox.Name)"
$EventLogsSecurityCheckBox.TabIndex = 2
$EventLogsSecurityCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$EventLogsSecurityCheckBox.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$EventLogsSecurityCheckBox.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 

$Section1QueriesTab.Controls.Add($EventLogsSecurityCheckBox)




# ============================================================================================================================================================
# Event Logs - System
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$EventLogsSystemCheckBox = New-Object System.Windows.Forms.CheckBox
$EventLogsSystemCheckBox.Name = "Event Logs (100) System"

function EventLogsSystemCommand {
    $Message1            = "$($EventLogsSystemCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Event Logs (100) System"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($EventLogsSystemCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$LimitNumberOfEventLogsCollectToChoice,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Credential $Credential -Class Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile='System')" `
                | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type `
                | Select-Object -first $LimitNumberOfEventLogsCollectToChoice `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$LimitNumberOfEventLogsCollectToChoice,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$LimitNumberOfEventLogsCollectToChoice)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Class Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile='System')" `
                | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type `
                | Select-Object -first $LimitNumberOfEventLogsCollectToChoice `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$LimitNumberOfEventLogsCollectToChoice)
        }   
    }
    MonitorJobs
    
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($EventLogsSystemCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$EventLogsSystemCheckBox.Text     = "$($EventLogsSystemCheckBox.Name)"
$EventLogsSystemCheckBox.TabIndex = 2
$EventLogsSystemCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$EventLogsSystemCheckBox.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$EventLogsSystemCheckBox.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 

$Section1QueriesTab.Controls.Add($EventLogsSystemCheckBox)




# ============================================================================================================================================================
# Event Logs - System Errors
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$EventLogsSystemErrorsCheckBox = New-Object System.Windows.Forms.CheckBox
$EventLogsSystemErrorsCheckBox.Name = "Event Logs (100) System Errors"

function EventLogsSystemErrorsCommand {
    $Message1            = "$($EventLogsSystemErrorsCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Event Logs (100) System Errors"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($EventLogsSystemErrorsCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$LimitNumberOfEventLogsCollectToChoice,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Credential $Credential -Class Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile='System') AND (type='error')" `
                | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type `
                | Select-Object -first $LimitNumberOfEventLogsCollectToChoice `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$LimitNumberOfEventLogsCollectToChoice,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$LimitNumberOfEventLogsCollectToChoice)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Class Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile='System') AND (type='error')" `
                | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type `
                | Select-Object -first $LimitNumberOfEventLogsCollectToChoice `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$LimitNumberOfEventLogsCollectToChoice)
        }   
    }
    MonitorJobs
    
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($EventLogsSystemErrorsCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$EventLogsSystemErrorsCheckBox.Text     = "$($EventLogsSystemErrorsCheckBox.Name)"
$EventLogsSystemErrorsCheckBox.TabIndex = 2
$EventLogsSystemErrorsCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$EventLogsSystemErrorsCheckBox.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$EventLogsSystemErrorsCheckBox.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 

$Section1QueriesTab.Controls.Add($EventLogsSystemErrorsCheckBox)




# ============================================================================================================================================================
# Firewall Rules
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$FirewallRulesCheckBox = New-Object System.Windows.Forms.CheckBox
$FirewallRulesCheckBox.Name = "Firewall Rules *"

function FirewallRulesCommand {
    $Message1            = "$($FirewallRulesCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Firewall Rules"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($FirewallRulesCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'

                Invoke-Command -Credential $Credential -ComputerName $TargetComputer -ScriptBlock {
                    cmd /c netsh advfirewall firewall show rule name=all
                } -ArgumentList @($null) | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"

                if ((Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") -eq $null) {
                    Remove-Item  "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
                }
                elseif ((Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt").Length -le 5) {
                    Remove-Item      "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
                }
                else {                            
                    $FirewallRules = (Get-Content -Path "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") -replace '-{2,}','' -replace ',',';' -replace '^ {3,}',':  ' | Where-Object {$_.trim() -ne ''} 

                    $FileHeader = "Rule Name,Enabled,Direction,Profiles,Grouping,LocalIP,RemoteIP,Protocol,LocalPort,RemotePort,Edge Traversal,Action"

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
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Invoke-Command -ComputerName $TargetComputer -ScriptBlock {
                    cmd /c netsh advfirewall firewall show rule name=all
                } -ArgumentList @($null) | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"

                if ((Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") -eq $null) {
                    Remove-Item  "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
                }
                elseif ((Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt").Length -le 5) {
                    Remove-Item      "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
                }
                else {                            
                    $FirewallRules = (Get-Content -Path "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") -replace '-{2,}','' -replace ',',';' -replace '^ {3,}',':  ' | Where-Object {$_.trim() -ne ''} 

                    $FileHeader = "Rule Name,Enabled,Direction,Profiles,Grouping,LocalIP,RemoteIP,Protocol,LocalPort,RemotePort,Edge Traversal,Action"

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
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs

    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($FirewallRulesCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$FirewallRulesCheckBox.Text     = "$($FirewallRulesCheckBox.Name)"
$FirewallRulesCheckBox.TabIndex = 2
$FirewallRulesCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$FirewallRulesCheckBox.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$FirewallRulesCheckBox.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 

$Section1QueriesTab.Controls.Add($FirewallRulesCheckBox)




# ============================================================================================================================================================
# Firewall Status
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$FirewallStatusCheckBox = New-Object System.Windows.Forms.CheckBox
$FirewallStatusCheckBox.Name = "Firewall Status *"

function FirewallStatusCommand {
    $Message1            = "$($FirewallStatusCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Firewall Status"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($FirewallStatusCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Invoke-Command -Credential $Credential -ComputerName $TargetComputer -ScriptBlock {
                    cmd /c netsh advfirewall show allprofiles state
                } -ArgumentList @($null) | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
                
                if ((Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") -eq $null) {
                    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
                }
                else {
                    $FirewallStatus = (Get-Content -Path "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") -replace '-{2,}','' -replace ',',';' -replace '^ {3,}',':  ' | Where-Object {$_.trim() -ne ''} 

                    # Creates the fields that become the file headers
                    $FileHeader = "Firewall Profile,State"
                    # Extracts the data 
                    $FileData = $(($FirewallStatus | Out-String) -replace '-{2,}','' -replace ' {2,}','' -replace "`r|`n","" -replace ":","," -replace "State","" -creplace "ON","ON`n" -creplace "OFF","OFF`n" -replace 'Ok.','' -replace "^ | $","") -split "`n" | Where-Object {$_.trim() -ne ""}
    
                    #Combines the File Header and Data
                    $Combined = @()
                    $Combined += $FileHeader
                    $Combined += $FileData
                    $Combined | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"

                    # Add PSComputerName header and host/ip name
                    $AddTargetHost = (Import-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv")
                    $AddTargetHost | Add-Member -MemberType NoteProperty "PSComputerName" -Value "$TargetComputer"
                    $AddTargetHost | Select-Object -Property PSComputerName, * | Export-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation
                }
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Invoke-Command -ComputerName $TargetComputer -ScriptBlock {
                    cmd /c netsh advfirewall show allprofiles state
                } -ArgumentList @($null) | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"

                if ((Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") -eq $null) {
                    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
                }
                else {
                    $FirewallStatus = (Get-Content -Path "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") -replace '-{2,}','' -replace ',',';' -replace '^ {3,}',':  ' | Where-Object {$_.trim() -ne ''} 

                    # Creates the fields that become the file headers
                    $FileHeader = "Firewall Profile,State"
                    # Extracts the data 
                    $FileData = $(($FirewallStatus | Out-String) -replace '-{2,}','' -replace ' {2,}','' -replace "`r|`n","" -replace ":","," -replace "State","" -creplace "ON","ON`n" -creplace "OFF","OFF`n" -replace 'Ok.','' -replace "^ | $","") -split "`n" | Where-Object {$_.trim() -ne ""}
    
                    #Combines the File Header and Data
                    $Combined = @()
                    $Combined += $FileHeader
                    $Combined += $FileData
                    $Combined | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"

                    # Add PSComputerName header and host/ip name
                    $AddTargetHost = (Import-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv")
                    $AddTargetHost | Add-Member -MemberType NoteProperty "PSComputerName" -Value "$TargetComputer"
                    $AddTargetHost | Select-Object -Property PSComputerName, * | Export-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation
                }
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs

    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($FirewallStatusCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
$FirewallStatusCheckBox.Text     = "$($FirewallStatusCheckBox.Name)"
$FirewallStatusCheckBox.TabIndex = 2
$FirewallStatusCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$FirewallStatusCheckBox.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$FirewallStatusCheckBox.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 

$Section1QueriesTab.Controls.Add($FirewallStatusCheckBox)




# ============================================================================================================================================================
# Group Information
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$GroupInfoCheckBox = New-Object System.Windows.Forms.CheckBox
$GroupInfoCheckBox.Name = "Group Information"

function GroupInfoCommand {
    $Message1            = "$($GroupInfoCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Group Information"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($GroupInfoCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Credential $Credential -Class Win32_Group -ComputerName $TargetComputer `
                | Select-Object PSComputerName, Name, Caption, Domain, SID `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Class Win32_Group -ComputerName $TargetComputer `
                | Select-Object PSComputerName, Name, Caption, Domain, SID `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs
    
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($GroupInfoCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$GroupInfoCheckBox.Text     = "$($GroupInfoCheckBox.Name)"
$GroupInfoCheckBox.TabIndex = 2
$GroupInfoCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$GroupInfoCheckBox.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$GroupInfoCheckBox.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 

$Section1QueriesTab.Controls.Add($GroupInfoCheckBox)




# ============================================================================================================================================================
# Logon Information
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$LogonInfoCheckBox = New-Object System.Windows.Forms.CheckBox
$LogonInfoCheckBox.Name = "Logon Information"

function LogonInfoCommand {
    $Message1            = "$($LogonInfoCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Logon Information"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($LogonInfoCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Credential $Credential -Class Win32_NetworkLoginProfile -ComputerName $TargetComputer `
                | Select-Object PSComputerName, Name, LastLogon, LastLogoff, NumberOfLogons, PasswordAge `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Class Win32_NetworkLoginProfile -ComputerName $TargetComputer `
                | Select-Object PSComputerName, Name, LastLogon, LastLogoff, NumberOfLogons, PasswordAge `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs
    
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($LogonInfoCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
$LogonInfoCheckBox.Text     = "$($LogonInfoCheckBox.Name)"
$LogonInfoCheckBox.TabIndex = 2
$LogonInfoCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$LogonInfoCheckBox.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$LogonInfoCheckBox.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 

$Section1QueriesTab.Controls.Add($LogonInfoCheckBox)




# ============================================================================================================================================================
# Logon Sessions
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$LogonSessionsCheckBox = New-Object System.Windows.Forms.CheckBox
$LogonSessionsCheckBox.Name = "Logon Sessions *"

function LogonSessionsCommand {
    $Message1            = "$($LogonSessionsCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Logon Sessions"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($LogonSessionsCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Invoke-Command -Credential $Credential -ComputerName $TargetComputer -ScriptBlock {
                    cmd /c query session
                } -ArgumentList @($null) | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"

                if ((Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") -eq $null) {
                    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
                }
                else {
                    # Processes collection to format it from txt to csv
                    $LogonStatusInfo   = Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
                    $LogonStatusBuffer = @()
                    foreach ($line in $LogonStatusInfo) { 
                        $LogonStatusBuffer += $line -replace " {2,}",","
                    }
                    $LogonStatusBuffer | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"

                    # Add PSComputerName header and host/ip name
                    $AddTargetHost = (Import-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv")
                    $AddTargetHost | Add-Member -MemberType NoteProperty "PSComputerName" -Value "$TargetComputer"
                    $AddTargetHost | Select-Object -Property PSComputerName, * | Export-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation
                }
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Invoke-Command -ComputerName $TargetComputer -ScriptBlock {
                    cmd /c query session
                } -ArgumentList @($null) | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"

                if ((Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") -eq $null) {
                    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
                }
                else {
                    # Processes collection to format it from txt to csv
                    $LogonStatusInfo   = Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
                    $LogonStatusBuffer = @()
                    foreach ($line in $LogonStatusInfo) { 
                        $LogonStatusBuffer += $line -replace " {2,}",","
                    }
                    $LogonStatusBuffer | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"

                    # Add PSComputerName header and host/ip name
                    $AddTargetHost = (Import-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv")
                    $AddTargetHost | Add-Member -MemberType NoteProperty "PSComputerName" -Value "$TargetComputer"
                    $AddTargetHost | Select-Object -Property PSComputerName, * | Export-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation
                }
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs

    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($LogonSessionsCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
    Remove-DuplicateCsvHeaders
}
$LogonSessionsCheckBox.Text     = "$($LogonSessionsCheckBox.Name)"
$LogonSessionsCheckBox.TabIndex = 2
$LogonSessionsCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$LogonSessionsCheckBox.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$LogonSessionsCheckBox.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 

$Section1QueriesTab.Controls.Add($LogonSessionsCheckBox)




# ============================================================================================================================================================
# Logon User Status
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$LogonUserStatusCheckBox = New-Object System.Windows.Forms.CheckBox
$LogonUserStatusCheckBox.Name = "Logon User Status *"

function LogonUserStatusCommand {
    $Message1            = "$($LogonUserStatusCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Logon User Status"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($LogonUserStatusCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Invoke-Command -Credential $Credential -ComputerName $TargetComputer -ScriptBlock {
                    cmd /c query user
                } -ArgumentList @($null) | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"

                if ((Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") -eq $null) {
                    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
                }
                else {
                    # Processes collection to format it from txt to csv
                    $LogonStatusInfo   = Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
                    $LogonStatusBuffer = @()
                    foreach ($line in $LogonStatusInfo) { 
                        $LogonStatusBuffer += $line -replace " {2,}",","
                    }
                    $LogonStatusBuffer | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"

                    # Add PSComputerName header and host/ip name
                    $AddTargetHost = (Import-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv")
                    $AddTargetHost | Add-Member -MemberType NoteProperty "PSComputerName" -Value "$TargetComputer"
                    $AddTargetHost | Select-Object -Property PSComputerName, * | Export-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation
                }
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                                   
                Invoke-Command -ComputerName $TargetComputer -ScriptBlock {
                    cmd /c query user
                } -ArgumentList @($null) | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"

                if ((Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") -eq $null) {
                    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
                }
                else {
                    # Processes collection to format it from txt to csv
                    $LogonStatusInfo   = Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
                    $LogonStatusBuffer = @()
                    foreach ($line in $LogonStatusInfo) { 
                        $LogonStatusBuffer += $line -replace " {2,}",","
                    }
                    $LogonStatusBuffer | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"

                    # Add PSComputerName header and host/ip name
                    $AddTargetHost = (Import-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv")
                    $AddTargetHost | Add-Member -MemberType NoteProperty "PSComputerName" -Value "$TargetComputer"
                    $AddTargetHost | Select-Object -Property PSComputerName, * | Export-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation
                }
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs
    
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($LogonUserStatusCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
    Remove-DuplicateCsvHeaders
}
$LogonUserStatusCheckBox.Text     = "$($LogonUserStatusCheckBox.Name)"
$LogonUserStatusCheckBox.TabIndex = 2
$LogonUserStatusCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$LogonUserStatusCheckBox.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$LogonUserStatusCheckBox.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 

$Section1QueriesTab.Controls.Add($LogonUserStatusCheckBox)




# ============================================================================================================================================================
# Mapped Drives
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$MappedDrivesCheckBox = New-Object System.Windows.Forms.CheckBox
$MappedDrivesCheckBox.Name = "Mapped Drives"

function MappedDrivesCommand {
    $Message1            = "$($MappedDrivesCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Mapped Drives"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($MappedDrivesCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Credential $Credential -Class Win32_MappedLogicalDisk -ComputerName $TargetComputer `
                | Select-Object PSComputerName, Name, ProviderName `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Class Win32_MappedLogicalDisk -ComputerName $TargetComputer `
                | Select-Object PSComputerName, Name, ProviderName `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs
    
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($MappedDrivesCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$MappedDrivesCheckBox.Text     = "$($MappedDrivesCheckBox.Name)"
$MappedDrivesCheckBox.TabIndex = 2
$MappedDrivesCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$MappedDrivesCheckBox.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$MappedDrivesCheckBox.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 
$Section1QueriesTab.Controls.Add($MappedDrivesCheckBox)




# ============================================================================================================================================================
# Memory (RAM) Capacity Info
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$MemoryCapacityInfoCheckBox = New-Object System.Windows.Forms.CheckBox
$MemoryCapacityInfoCheckBox.Name = "Memory (RAM) Capacity Info"

function MemoryCapacityInfoCommand {
    $Message1            = "$($MemoryCapacityInfoCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Memory (RAM) Capacity Info"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($MemoryCapacityInfoCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Credential $Credential -Class Win32_PhysicalMemoryArray -ComputerName $TargetComputer `
                | Select-Object PSComputerName, Model, Name, MaxCapacity, MemoryDevices `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Class Win32_PhysicalMemoryArray -ComputerName $TargetComputer `
                | Select-Object PSComputerName, Model, Name, MaxCapacity, MemoryDevices `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs
    
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($MemoryCapacityInfoCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
$MemoryCapacityInfoCheckBox.Text     = "$($MemoryCapacityInfoCheckBox.Name)"
$MemoryCapacityInfoCheckBox.TabIndex = 2
$MemoryCapacityInfoCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$MemoryCapacityInfoCheckBox.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$MemoryCapacityInfoCheckBox.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 

$Section1QueriesTab.Controls.Add($MemoryCapacityInfoCheckBox)




# ============================================================================================================================================================
# Memory (RAM) Physical Information
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$MemoryPhysicalInfoCheckBox = New-Object System.Windows.Forms.CheckBox
$MemoryPhysicalInfoCheckBox.Name = "Memory (RAM) Physical Info"

function MemoryPhysicalInfoCommand {
    $Message1                = "$($MemoryPhysicalInfoCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Memory (RAM) Physical Info"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($MemoryPhysicalInfoCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Credential $Credential -Class Win32_PhysicalMemory -ComputerName $TargetComputer `
                | Select-Object PSComputerName, Tag, Capacity, Speed, Manufacturer, PartNumber, SerialNumber `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Class Win32_PhysicalMemory -ComputerName $TargetComputer `
                | Select-Object PSComputerName, Tag, Capacity, Speed, Manufacturer, PartNumber, SerialNumber `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }  
    }
    MonitorJobs
    
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($MemoryPhysicalInfoCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
$MemoryPhysicalInfoCheckBox.Text     = "$($MemoryPhysicalInfoCheckBox.Name)"
$MemoryPhysicalInfoCheckBox.TabIndex = 2
$MemoryPhysicalInfoCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$MemoryPhysicalInfoCheckBox.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$MemoryPhysicalInfoCheckBox.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 

$Section1QueriesTab.Controls.Add($MemoryPhysicalInfoCheckBox)




# ============================================================================================================================================================
# Memory (RAM) Utilization
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$MemoryUtilizationCheckBox = New-Object System.Windows.Forms.CheckBox
$MemoryUtilizationCheckBox.Name = "Memory (RAM) Utilization"

function MemoryUtilizationCommand {
    $Message1            = "$($MemoryUtilizationCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Memory (RAM) Utilization"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($MemoryUtilizationCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Credential $Credential -Class Win32_OperatingSystem -ComputerName $TargetComputer `
                | Select-Object -Property PSComputerName, FreePhysicalMemory, TotalVisibleMemorySize, FreeVirtualMemory, TotalVirtualMemorySize `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Class Win32_OperatingSystem -ComputerName $TargetComputer `
                | Select-Object -Property PSComputerName, FreePhysicalMemory, TotalVisibleMemorySize, FreeVirtualMemory, TotalVirtualMemorySize `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs
    
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($MemoryUtilizationCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$MemoryUtilizationCheckBox.Text     = "$($MemoryUtilizationCheckBox.Name)"
$MemoryUtilizationCheckBox.TabIndex = 2
$MemoryUtilizationCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$MemoryUtilizationCheckBox.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$MemoryUtilizationCheckBox.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 

$Section1QueriesTab.Controls.Add($MemoryUtilizationCheckBox)




# ============================================================================================================================================================
# ============================================================================================================================================================
# Column 2
# ============================================================================================================================================================
# ============================================================================================================================================================

# Varables to Control Column 2
$Column1RightPosition = 230   # Horizontal
$Column1DownPosition    = -10   # Vertical


# Shift the fields
$Column1DownPosition += $Column1DownPositionShift
$Column1DownPosition += $Column1DownPositionShift
$Column1DownPosition += $Column1DownPositionShift




# ============================================================================================================================================================
# Memory Performance Monitoring Data
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$MemoryPerformanceDataCheckBox = New-Object System.Windows.Forms.CheckBox
$MemoryPerformanceDataCheckBox.Name = "Memory Performance Data"

function MemoryPerformanceDataCommand {
    $Message1            = "$($MemoryPerformanceDataCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Memory Performance Data"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($MemoryPerformanceDataCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Credential $Credential -Class Win32_PerfRawData_PerfOS_Memory -ComputerName $TargetComputer `
                | Select-Object -Property PSComputerName, AvailableBytes, AvailableKBytes, AvailableMBytes, CacheBytes, CacheBytesPeak, CacheFaultsPersec, Caption, CommitLimit, CommittedBytes, DemandZeroFaultsPersec, FreeAndZeroPageListBytes, FreeSystemPageTableEntries, Frequency_Object, Frequency_PerfTime, Frequency_Sys100NS, LongTermAverageStandbyCacheLifetimes, ModifiedPageListBytes, PageFaultsPersec, PageReadsPersec, PagesInputPersec, PagesOutputPersec, PagesPersec, PageWritesPersec, PercentCommittedBytesInUse, PercentCommittedBytesInUse_Base, PoolNonpagedAllocs, PoolNonpagedBytes, PoolPagedAllocs, PoolPagedBytes, PoolPagedResidentBytes, StandbyCacheCoreBytes, StandbyCacheNormalPriorityBytes, StandbyCacheReserveBytes, SystemCacheResidentBytes, SystemCodeResidentBytes, SystemCodeTotalBytes, SystemDriverResidentBytes, SystemDriverTotalBytes, Timestamp_Object, Timestamp_PerfTime, Timestamp_Sys100NS, TransitionFaultsPersec, TransitionPagesRePurposedPersec, WriteCopiesPersec `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Class Win32_PerfRawData_PerfOS_Memory -ComputerName $TargetComputer `
                | Select-Object -Property PSComputerName, AvailableBytes, AvailableKBytes, AvailableMBytes, CacheBytes, CacheBytesPeak, CacheFaultsPersec, Caption, CommitLimit, CommittedBytes, DemandZeroFaultsPersec, FreeAndZeroPageListBytes, FreeSystemPageTableEntries, Frequency_Object, Frequency_PerfTime, Frequency_Sys100NS, LongTermAverageStandbyCacheLifetimes, ModifiedPageListBytes, PageFaultsPersec, PageReadsPersec, PagesInputPersec, PagesOutputPersec, PagesPersec, PageWritesPersec, PercentCommittedBytesInUse, PercentCommittedBytesInUse_Base, PoolNonpagedAllocs, PoolNonpagedBytes, PoolPagedAllocs, PoolPagedBytes, PoolPagedResidentBytes, StandbyCacheCoreBytes, StandbyCacheNormalPriorityBytes, StandbyCacheReserveBytes, SystemCacheResidentBytes, SystemCodeResidentBytes, SystemCodeTotalBytes, SystemDriverResidentBytes, SystemDriverTotalBytes, Timestamp_Object, Timestamp_PerfTime, Timestamp_Sys100NS, TransitionFaultsPersec, TransitionPagesRePurposedPersec, WriteCopiesPersec `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs
    
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($MemoryPerformanceDataCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$MemoryPerformanceDataCheckBox.Text     = "$($MemoryPerformanceDataCheckBox.Name)"
$MemoryPerformanceDataCheckBox.TabIndex = 2
$MemoryPerformanceDataCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$MemoryPerformanceDataCheckBox.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$MemoryPerformanceDataCheckBox.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 
$Section1QueriesTab.Controls.Add($MemoryPerformanceDataCheckBox)




# ============================================================================================================================================================
# Network Connections TCP
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


# Command Text and CheckBox
$NetworkConnectionsTCPCheckBox = New-Object System.Windows.Forms.CheckBox
$NetworkConnectionsTCPCheckBox.Name = "Network Connections TCP *"

function NetworkConnectionsTCPCommand {
    $Message1            = "$($NetworkConnectionsTCPCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Network Connections TCP"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($NetworkConnectionsTCPCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'

                Invoke-Command -Credential $Credential -ComputerName $TargetComputer -ScriptBlock {
                    cmd /c netstat -anob -p tcp
                } -ArgumentList @($null) | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
                
                if ((Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") -eq $null) {
                    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
                }
                else {                
                    # Processes collection to format it from txt to csv
                    $Connections = Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt" | Select-Object -skip 3
                    $TCPdata = @()
                    $Connections.trim() | Out-String | ForEach-Object {$TCPdata += $_ -replace "`r`n",";;" -replace ";;;;",";;" -creplace ";;TCP","`r`nTCP" -replace ";;","  " -replace " {2,}","," -creplace "PID","PID,Executed Process" -replace "^,|,$",""}
                    $format = $TCPdata -split "`r`n" -replace " {1,1}",""
                    $TCPnetstatTxt =@()
                    # This section combines two specific csv fields together for easier viewing
                    foreach ($line in $format) {
                        if ($line -match "\d,\[") {$TCPnetstatTxt += $line}
                        if ($line -notmatch "\d,\[") {$TCPnetstatTxt += $line -replace ",\["," ["}
                    }
                    $TCPnetstatTxt | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer-temp.csv"
                    $TCPnetstatCsv = (Import-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer-temp.csv")
                    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer-temp.csv"
                    $TCPnetstatCsv | Add-Member -MemberType NoteProperty -Name "PSComputerName" -Value "$TargetComputer"
                    $TCPnetstatCsv | Select-Object -Property PSComputerName, * | Export-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation
                }
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'

                Invoke-Command -ComputerName $TargetComputer -ScriptBlock {
                    cmd /c netstat -anob -p tcp
                } -ArgumentList @($null) | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"

                if ((Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") -eq $null) {
                    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
                }
                else {                
                    # Processes collection to format it from txt to csv
                    $Connections = Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt" | Select-Object -skip 3
                    $TCPdata = @()
                    $Connections.trim() | Out-String | ForEach-Object {$TCPdata += $_ -replace "`r`n",";;" -replace ";;;;",";;" -creplace ";;TCP","`r`nTCP" -replace ";;","  " -replace " {2,}","," -creplace "PID","PID,Executed Process" -replace "^,|,$",""}
                    $format = $TCPdata -split "`r`n" -replace " {1,1}",""
                    $TCPnetstatTxt =@()
                    # This section combines two specific csv fields together for easier viewing
                    foreach ($line in $format) {
                        if ($line -match "\d,\[") {$TCPnetstatTxt += $line}
                        if ($line -notmatch "\d,\[") {$TCPnetstatTxt += $line -replace ",\["," ["}
                    }
                    $TCPnetstatTxt | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer-temp.csv"
                    $TCPnetstatCsv = (Import-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer-temp.csv")
                    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer-temp.csv"
                    $TCPnetstatCsv | Add-Member -MemberType NoteProperty -Name "PSComputerName" -Value "$TargetComputer"
                    $TCPnetstatCsv | Select-Object -Property PSComputerName, * | Export-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation
                }
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs
    #Remove-DuplicateCsvHeaders
   
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($NetworkConnectionsTCPCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$NetworkConnectionsTCPCheckBox.Text             = "$($NetworkConnectionsTCPCheckBox.Name)"
$NetworkConnectionsTCPCheckBox.TabIndex         = 2
$NetworkConnectionsTCPCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$NetworkConnectionsTCPCheckBox.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$NetworkConnectionsTCPCheckBox.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 

$Section1QueriesTab.Controls.Add($NetworkConnectionsTCPCheckBox)




# ============================================================================================================================================================
# Network Connections UDP
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$NetworkConnectionsUDPCheckBox = New-Object System.Windows.Forms.CheckBox
$NetworkConnectionsUDPCheckBox.Name = "Network Connections UDP *"

function NetworkConnectionsUDPCommand {
    $Message1            = "$($NetworkConnectionsUDPCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Network Connections UDP"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($NetworkConnectionsUDPCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Invoke-Command -Credential $Credential -ComputerName $TargetComputer -ScriptBlock {
                    cmd /c netstat -anob -p udp
                } -ArgumentList @($null) | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"

                if ((Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") -eq $null) {
                    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
                }
                else {                
                    # Processes collection to format it from txt to csv
                    $Connections = Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt" | Select-Object -skip 3
                    $UDPdata = @()
                    $Connections.trim()  | Out-String |   ForEach-Object {$UDPdata += $_ -replace "`r`n",";;" -replace ";;;;",";;" -creplace ";;UDP","`r`nUDP" -replace ";;","  " -replace " {2,}","," -replace "State,","" -creplace "PID","PID,Executed Process" -replace "^,|,$",""}

                    $format = $UDPdata -split "`r`n"
                    $UDPnetstat =@()
                    # This section is needed to combine two specific csv fields together for easier viewing
                    foreach ($line in $format) {
                        if ($line -match "\d,\[") {$UDPnetstat += $line}
                        if ($line -notmatch "\d,\[") {$UDPnetstat += $line -replace ",\["," ["}
                    }
                    $UDPnetstat | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"

                    # Add PSComputerName header and host/ip name
                    $AddTargetHost = (Import-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv")
                    $AddTargetHost | Add-Member -MemberType NoteProperty "PSComputerName" -Value "$TargetComputer"
                    $AddTargetHost | Select-Object -Property PSComputerName, * | Export-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation
                }
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Invoke-Command -ComputerName $TargetComputer -ScriptBlock {
                    cmd /c netstat -anob -p udp
                } -ArgumentList @($null) | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"

                if ((Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") -eq $null) {
                    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
                }
                else {                
                    # Processes collection to format it from txt to csv
                    $Connections = Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt" | Select-Object -skip 3
                    $UDPdata = @()
                    $Connections.trim()  | Out-String |   ForEach-Object {$UDPdata += $_ -replace "`r`n",";;" -replace ";;;;",";;" -creplace ";;UDP","`r`nUDP" -replace ";;","  " -replace " {2,}","," -replace "State,","" -creplace "PID","PID,Executed Process" -replace "^,|,$",""}

                    $format = $UDPdata -split "`r`n"
                    $UDPnetstat =@()
                    # This section is needed to combine two specific csv fields together for easier viewing
                    foreach ($line in $format) {
                        if ($line -match "\d,\[") {$UDPnetstat += $line}
                        if ($line -notmatch "\d,\[") {$UDPnetstat += $line -replace ",\["," ["}
                    }
                    $UDPnetstat | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"

                    # Add PSComputerName header and host/ip name
                    $AddTargetHost = (Import-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv")
                    $AddTargetHost | Add-Member -MemberType NoteProperty "PSComputerName" -Value "$TargetComputer"
                    $AddTargetHost | Select-Object -Property PSComputerName, * | Export-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation
                }
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs
    
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($NetworkConnectionsUDPCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$NetworkConnectionsUDPCheckBox.Text     = "$($NetworkConnectionsUDPCheckBox.Name)"
$NetworkConnectionsUDPCheckBox.TabIndex = 2
$NetworkConnectionsUDPCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$NetworkConnectionsUDPCheckBox.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$NetworkConnectionsUDPCheckBox.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 

$Section1QueriesTab.Controls.Add($NetworkConnectionsUDPCheckBox)




# ============================================================================================================================================================
# Network Settings
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$NetworkSettingsCheckBox = New-Object System.Windows.Forms.CheckBox
$NetworkSettingsCheckBox.Name = "Network Settings"

function NetworkSettingsCommand {
    $Message1            = "$($NetworkSettingsCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Network Settings"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($NetworkSettingsCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Credential $Credential -Class Win32_NetworkAdapterConfiguration -ComputerName $TargetComputer `
                | Select-Object -Property `
                    PSComputerName, MACAddress, `
                    @{Name="IPAddress";Expression={$_.IPAddress -join "; "}}, `
                    @{Name="IpSubnet";Expression={$_.IpSubnet -join "; "}}, `
                    @{Name="DefaultIPGateway";Expression={$_.DefaultIPgateway -join "; "}}, `
                    Description, ServiceName, IPEnabled, DHCPEnabled, DNSHostname, `
                    @{Name="DNSDomainSuffixSearchOrder";Expression={$_.DNSDomainSuffixSearchOrder -join "; "}}, `
                    DNSEnabledForWINSResolution, DomainDNSRegistrationEnabled, FullDNSRegistrationEnabled, `
                    @{Name="DNSServerSearchOrder";Expression={$_.DNSServerSearchOrder -join "; "}}, `
                    @{Name="WinsPrimaryServer";Expression={$_.WinsPrimaryServer -join "; "}}, `
                    @{Name="WINSSecindaryServer";Expression={$_.WINSSecindaryServer -join "; "}} `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Class Win32_NetworkAdapterConfiguration -ComputerName $TargetComputer `
                | Select-Object -Property `
                    PSComputerName, MACAddress, `
                    @{Name="IPAddress";Expression={$_.IPAddress -join "; "}}, `
                    @{Name="IpSubnet";Expression={$_.IpSubnet -join "; "}}, `
                    @{Name="DefaultIPGateway";Expression={$_.DefaultIPgateway -join "; "}}, `
                    Description, ServiceName, IPEnabled, DHCPEnabled, DNSHostname, `
                    @{Name="DNSDomainSuffixSearchOrder";Expression={$_.DNSDomainSuffixSearchOrder -join "; "}}, `
                    DNSEnabledForWINSResolution, DomainDNSRegistrationEnabled, FullDNSRegistrationEnabled, `
                    @{Name="DNSServerSearchOrder";Expression={$_.DNSServerSearchOrder -join "; "}}, `
                    @{Name="WinsPrimaryServer";Expression={$_.WinsPrimaryServer -join "; "}}, `
                    @{Name="WINSSecindaryServer";Expression={$_.WINSSecindaryServer -join "; "}} `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs

    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($NetworkSettingsCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$NetworkSettingsCheckBox.Text     = "$($NetworkSettingsCheckBox.Name)"
$NetworkSettingsCheckBox.TabIndex = 2
$NetworkSettingsCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$NetworkSettingsCheckBox.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$NetworkSettingsCheckBox.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 

$Section1QueriesTab.Controls.Add($NetworkSettingsCheckBox)




# ============================================================================================================================================================
# Network Statistics IPv4
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$NetworkStatisticsIPv4CheckBox      = New-Object System.Windows.Forms.CheckBox
$NetworkStatisticsIPv4CheckBox.Name = "Network Statistics IPv4 *"

function NetworkStatisticsIPv4Command {
    $Message1            = "$($NetworkStatisticsIPv4CheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName             = "Network Statistics IPv4"
    $CollectionDirectory        = $CollectionName
    $CollectionShortName        = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1                   = "Collecting Data:  $($NetworkStatisticsIPv4CheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage                 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage                 | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Invoke-Command -Credential $Credential -ComputerName $TargetComputer -ScriptBlock {
                    cmd /c netstat -e -p ip
                } -ArgumentList @($null) | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
   
                if ((Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") -eq $null) {
                    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
                }
                else {
                    # Processes collection to format it from txt to csv
                    $Statistics = (Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") | Select-Object -skip 4 -First 6
                
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
                    $ConvertedToCsv | Out-File -FilePath "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"   
                }
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Invoke-Command -ComputerName $TargetComputer -ScriptBlock {
                    cmd /c netstat -e -p ip
                } -ArgumentList @($null) | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
   
                if ((Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") -eq $null) {
                    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
                }
                else {
                    # Processes collection to format it from txt to csv
                    $Statistics = (Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") | Select-Object -skip 4 -First 6
                
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
                    $ConvertedToCsv | Out-File -FilePath "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"   
                }
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs

    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($NetworkStatisticsIPv4CheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
$NetworkStatisticsIPv4CheckBox.Text       = "$($NetworkStatisticsIPv4CheckBox.Name)"
$NetworkStatisticsIPv4CheckBox.TabIndex   = 2
$NetworkStatisticsIPv4CheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$NetworkStatisticsIPv4CheckBox.Location   = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$NetworkStatisticsIPv4CheckBox.Size       = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 
$Section1QueriesTab.Controls.Add($NetworkStatisticsIPv4CheckBox)




# ============================================================================================================================================================
# Network Statistics IPv4 TCP
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$NetworkStatisticsIPv4TCPCheckBox      = New-Object System.Windows.Forms.CheckBox
$NetworkStatisticsIPv4TCPCheckBox.Name = "Network Statistics IPv4 TCP *"

function NetworkStatisticsIPv4TCPCommand {
    $Message1            = "$($NetworkStatisticsIPv4TCPCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName             = "Network Statistics IPv4 TCP"
    $CollectionDirectory        = $CollectionName
    $CollectionShortName        = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1                   = "Collecting Data:  $($NetworkStatisticsIPv4TCPCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage                 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage                 | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Invoke-Command -Credential $Credential -ComputerName $TargetComputer -ScriptBlock {
                    cmd /c netstat -e -p tcp
                } -ArgumentList @($null) | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"

                if ((Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") -eq $null) {
                    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
                }
                else {
                    # Processes collection to format it from txt to csv
                    $Statistics = Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt" | Select-Object -skip 4 -First 6
                
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
                    $ConvertedToCsv | Out-File -FilePath "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"                         
                }
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Invoke-Command -ComputerName $TargetComputer -ScriptBlock {
                    cmd /c netstat -e -p tcp
                } -ArgumentList @($null) | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"

                if ((Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") -eq $null) {
                    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
                }
                else {
                    # Processes collection to format it from txt to csv
                    $Statistics = Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt" | Select-Object -skip 4 -First 6
                
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
                    $ConvertedToCsv | Out-File -FilePath "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"                         
                }
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs

    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($NetworkStatisticsIPv4TCPCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
$NetworkStatisticsIPv4TCPCheckBox.Text       = "$($NetworkStatisticsIPv4TCPCheckBox.Name)"
$NetworkStatisticsIPv4TCPCheckBox.TabIndex   = 2
$NetworkStatisticsIPv4TCPCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$NetworkStatisticsIPv4TCPCheckBox.Location   = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$NetworkStatisticsIPv4TCPCheckBox.Size       = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 
$Section1QueriesTab.Controls.Add($NetworkStatisticsIPv4TCPCheckBox)




# ============================================================================================================================================================
# Network Statistics IPv4 UDP
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$NetworkStatisticsIPv4UDPCheckBox      = New-Object System.Windows.Forms.CheckBox
$NetworkStatisticsIPv4UDPCheckBox.Name = "Network Statistics IPv4 UDP *"

function NetworkStatisticsIPv4UDPCommand {
    $Message1            = "$($NetworkStatisticsIPv4UDPCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName             = "Network Statistics IPv4 UDP"
    $CollectionDirectory        = $CollectionName
    $CollectionShortName        = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1                   = "Collecting Data:  $($NetworkStatisticsIPv4UDPCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage                 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage                 | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Invoke-Command -Credential $Credential -ComputerName $TargetComputer -ScriptBlock {
                    cmd /c netstat -e -p udp
                } -ArgumentList @($null) | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"

                if ((Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") -eq $null) {
                    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
                }
                else {
                    # Processes collection to format it from txt to csv
                    $Statistics = Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt" | Select-Object -skip 4 -First 6
                
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
                    $ConvertedToCsv | Out-File -FilePath "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"             
                }
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Invoke-Command -ComputerName $TargetComputer -ScriptBlock {
                    cmd /c netstat -e -p udp
                } -ArgumentList @($null) | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"

                if ((Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") -eq $null) {
                    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
                }
                else {
                    # Processes collection to format it from txt to csv
                    $Statistics = Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt" | Select-Object -skip 4 -First 6
                
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
                    $ConvertedToCsv | Out-File -FilePath "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"             
                }
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs

    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($NetworkStatisticsIPv4UDPCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
$NetworkStatisticsIPv4UDPCheckBox.Text       = "$($NetworkStatisticsIPv4UDPCheckBox.Name)"
$NetworkStatisticsIPv4UDPCheckBox.TabIndex   = 2
$NetworkStatisticsIPv4UDPCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$NetworkStatisticsIPv4UDPCheckBox.Location   = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$NetworkStatisticsIPv4UDPCheckBox.Size       = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 
$Section1QueriesTab.Controls.Add($NetworkStatisticsIPv4UDPCheckBox)




# ============================================================================================================================================================
# Network Statistics IPv4 ICMP
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift



$NetworkStatisticsIPv4ICMPCheckBox      = New-Object System.Windows.Forms.CheckBox
$NetworkStatisticsIPv4ICMPCheckBox.Name = "Network Statistics IPv4 ICMP *"

function NetworkStatisticsIPv4ICMPCommand {
    $Message1            = "$($NetworkStatisticsIPv4ICMPCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName             = "Network Statistics IPv4 ICMP"
    $CollectionDirectory        = $CollectionName
    $CollectionShortName        = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1                   = "Collecting Data:  $($NetworkStatisticsIPv4ICMPCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage                 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage                 | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Invoke-Command -Credential $Credential -ComputerName $TargetComputer -ScriptBlock {
                    cmd /c netstat -e -p icmp
                } -ArgumentList @($null) | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"

                if ((Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") -eq $null) {
                    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
                }
                else {            
                    # Processes collection to format it from txt to csv
                    $Statistics = Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt" | Select-Object -skip 4 -First 6
                    
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
                    $ConvertedToCsv | Out-File -FilePath "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"  
                }
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Invoke-Command -ComputerName $TargetComputer -ScriptBlock {
                    cmd /c netstat -e -p icmp
                } -ArgumentList @($null) | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"

                if ((Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") -eq $null) {
                    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
                }
                else {            
                    # Processes collection to format it from txt to csv
                    $Statistics = Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt" | Select-Object -skip 4 -First 6
                    
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
                    $ConvertedToCsv | Out-File -FilePath "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"  
                }
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs

    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($NetworkStatisticsIPv4ICMPCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
$NetworkStatisticsIPv4ICMPCheckBox.Text       = "$($NetworkStatisticsIPv4ICMPCheckBox.Name)"
$NetworkStatisticsIPv4ICMPCheckBox.TabIndex   = 2
$NetworkStatisticsIPv4ICMPCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$NetworkStatisticsIPv4ICMPCheckBox.Location   = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$NetworkStatisticsIPv4ICMPCheckBox.Size       = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 
$Section1QueriesTab.Controls.Add($NetworkStatisticsIPv4ICMPCheckBox)




# ============================================================================================================================================================
# Network Statistics IPv6
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$NetworkStatisticsIPv6CheckBox      = New-Object System.Windows.Forms.CheckBox
$NetworkStatisticsIPv6CheckBox.Name = "Network Statistics IPv6 *"

function NetworkStatisticsIPv6Command {
    $Message1            = "$($NetworkStatisticsIPv6CheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName             = "Network Statistics IPv6"
    $CollectionDirectory        = $CollectionName
    $CollectionShortName        = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1                   = "Collecting Data:  $($NetworkStatisticsIPv6CheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage                 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage                 | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Invoke-Command -Credential $Credential -ComputerName $TargetComputer -ScriptBlock {
                    cmd /c netstat -e -p ipv6
                } -ArgumentList @($null) | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"

                if ((Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") -eq $null) {
                    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
                }
                else {
                    # Processes collection to format it from txt to csv
                    $Statistics = Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt" | Select-Object -skip 4 -First 6
                
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
                    $ConvertedToCsv | Out-File -FilePath "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"   
                }
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Invoke-Command -ComputerName $TargetComputer -ScriptBlock {
                    cmd /c netstat -e -p ipv6
                } -ArgumentList @($null) | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"

                if ((Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") -eq $null) {
                    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
                }
                else {
                    # Processes collection to format it from txt to csv
                    $Statistics = Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt" | Select-Object -skip 4 -First 6
                
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
                    $ConvertedToCsv | Out-File -FilePath "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"  
                }
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }  
    }
    MonitorJobs

    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($NetworkStatisticsIPv6CheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
$NetworkStatisticsIPv6CheckBox.Text       = "$($NetworkStatisticsIPv6CheckBox.Name)"
$NetworkStatisticsIPv6CheckBox.TabIndex   = 2
$NetworkStatisticsIPv6CheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$NetworkStatisticsIPv6CheckBox.Location   = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$NetworkStatisticsIPv6CheckBox.Size       = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 
$Section1QueriesTab.Controls.Add($NetworkStatisticsIPv6CheckBox)




# ============================================================================================================================================================
# Network Statistics IPv6 TCP
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$NetworkStatisticsIPv6TCPCheckBox      = New-Object System.Windows.Forms.CheckBox
$NetworkStatisticsIPv6TCPCheckBox.Name = "Network Statistics IPv6 TCP *"

function NetworkStatisticsIPv6TCPCommand {
    $Message1            = "$($NetworkStatisticsIPv6TCPCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName             = "Network Statistics IPv6 TCP"
    $CollectionDirectory        = $CollectionName
    $CollectionShortName        = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1                   = "Collecting Data:  $($NetworkStatisticsIPv6TCPCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage                 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage                 | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Invoke-Command -Credential $Credential -ComputerName $TargetComputer -ScriptBlock {
                    cmd /c netstat -e -p tcpv6
                } -ArgumentList @($null) | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"

                if ((Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") -eq $null) {
                    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
                }
                else {
                    # Processes collection to format it from txt to csv
                    $Statistics = Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt" | Select-Object -skip 4 -First 6
                
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
                    $ConvertedToCsv | Out-File -FilePath "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"   
                }
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Invoke-Command -ComputerName $TargetComputer -ScriptBlock {
                    cmd /c netstat -e -p tcpv6
                } -ArgumentList @($null) | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"

                if ((Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") -eq $null) {
                    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
                }
                else {
                    # Processes collection to format it from txt to csv
                    $Statistics = Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt" | Select-Object -skip 4 -First 6
                
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
                    $ConvertedToCsv | Out-File -FilePath "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"   
                }
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs

    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($NetworkStatisticsIPv6TCPCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
$NetworkStatisticsIPv6TCPCheckBox.Text       = "$($NetworkStatisticsIPv6TCPCheckBox.Name)"
$NetworkStatisticsIPv6TCPCheckBox.TabIndex   = 2
$NetworkStatisticsIPv6TCPCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$NetworkStatisticsIPv6TCPCheckBox.Location   = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$NetworkStatisticsIPv6TCPCheckBox.Size       = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 
$Section1QueriesTab.Controls.Add($NetworkStatisticsIPv6TCPCheckBox)




# ============================================================================================================================================================
# Network Statistics IPv6 UDP
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$NetworkStatisticsIPv6UDPCheckBox      = New-Object System.Windows.Forms.CheckBox
$NetworkStatisticsIPv6UDPCheckBox.Name = "Network Statistics IPv6 UDP *"

function NetworkStatisticsIPv6UDPCommand {
    $Message1                   = "$($NetworkStatisticsIPv6UDPCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName             = "Network Statistics IPv6 UDP"
    $CollectionDirectory        = $CollectionName
    $CollectionShortName        = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1               = "Collecting Data:  $($NetworkStatisticsIPv6UDPCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage             = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage             | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Invoke-Command -Credential $Credential -ComputerName $TargetComputer -ScriptBlock {
                    cmd /c netstat -e -p udpv6
                } -ArgumentList @($null) | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"

                if ((Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") -eq $null) {
                    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
                }
                else {
                    # Processes collection to format it from txt to csv
                    $Statistics = Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt" | Select-Object -skip 4 -First 6
                
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
                    $ConvertedToCsv | Out-File -FilePath "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"  
                }
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Invoke-Command -ComputerName $TargetComputer -ScriptBlock {
                    cmd /c netstat -e -p udpv6
                } -ArgumentList @($null) | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"

                if ((Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") -eq $null) {
                    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
                }
                else {        
                    # Processes collection to format it from txt to csv
                    $Statistics = Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt" | Select-Object -skip 4 -First 6
                
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
                    $ConvertedToCsv | Out-File -FilePath "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"  
                }
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs

    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($NetworkStatisticsIPv6UDPCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
$NetworkStatisticsIPv6UDPCheckBox.Text       = "$($NetworkStatisticsIPv6UDPCheckBox.Name)"
$NetworkStatisticsIPv6UDPCheckBox.TabIndex   = 2
$NetworkStatisticsIPv6UDPCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$NetworkStatisticsIPv6UDPCheckBox.Location   = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$NetworkStatisticsIPv6UDPCheckBox.Size       = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 
$Section1QueriesTab.Controls.Add($NetworkStatisticsIPv6UDPCheckBox)




# ============================================================================================================================================================
# Network Statistics IPv6 ICMP
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$NetworkStatisticsIPv6ICMPCheckBox      = New-Object System.Windows.Forms.CheckBox
$NetworkStatisticsIPv6ICMPCheckBox.Name = "Network Statistics IPv6 ICMP *"

function NetworkStatisticsIPv6ICMPCommand {
    $Message1            = "$($NetworkStatisticsIPv6ICMPCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName             = "Network Statistics IPv6 ICMP"
    $CollectionDirectory        = $CollectionName
    $CollectionShortName        = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1                   = "Collecting Data:  $($NetworkStatisticsIPv6ICMPCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage                 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage                 | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Invoke-Command -Credential $Credential -ComputerName $TargetComputer -ScriptBlock {
                    cmd /c netstat -e -p icmpv6
                } -ArgumentList @($null) | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"

                if ((Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") -eq $null) {
                    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
                }
                else {
                    # Processes collection to format it from txt to csv
                    $Statistics = Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt" | Select-Object -skip 4 -First 6
                
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
                    $ConvertedToCsv | Out-File -FilePath "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"   
                }
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Invoke-Command -ComputerName $TargetComputer -ScriptBlock {
                    cmd /c netstat -e -p icmpv6
                } -ArgumentList @($null) | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"

                if ((Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") -eq $null) {
                    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
                }
                else {
                    # Processes collection to format it from txt to csv
                    $Statistics = Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt" | Select-Object -skip 4 -First 6
                
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
                    $ConvertedToCsv | Out-File -FilePath "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"   
                }
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }  
    }
    MonitorJobs
    
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($NetworkStatisticsIPv6ICMPCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
$NetworkStatisticsIPv6ICMPCheckBox.Text       = "$($NetworkStatisticsIPv6ICMPCheckBox.Name)"
$NetworkStatisticsIPv6ICMPCheckBox.TabIndex   = 2
$NetworkStatisticsIPv6ICMPCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$NetworkStatisticsIPv6ICMPCheckBox.Location   = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$NetworkStatisticsIPv6ICMPCheckBox.Size       = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 
$Section1QueriesTab.Controls.Add($NetworkStatisticsIPv6ICMPCheckBox)




# ============================================================================================================================================================
# Plug and Play Devices
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$PlugAndPlayCheckBox = New-Object System.Windows.Forms.CheckBox
$PlugAndPlayCheckBox.Name = "Plug and Play Devices"

function PlugAndPlayCommand {
    $Message1            = "$($PlugAndPlayCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Plug and Play Devices"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($PlugAndPlayCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Credential $Credential -Class Win32_PnPEntity -ComputerName $TargetComputer `
                | Select-Object PSComputerName, InstallDate, Status, Description, Service, DeviceID, @{Name="HardwareID";Expression={$_.HardwareID -join "; "}}, Manufacturer `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Class Win32_PnPEntity -ComputerName $TargetComputer `
                | Select-Object PSComputerName, InstallDate, Status, Description, Service, DeviceID, @{Name="HardwareID";Expression={$_.HardwareID -join "; "}}, Manufacturer `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs
    
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($PlugAndPlayCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$PlugAndPlayCheckBox.Text     = "$($PlugAndPlayCheckBox.Name)"
$PlugAndPlayCheckBox.TabIndex = 2
$PlugAndPlayCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$PlugAndPlayCheckBox.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$PlugAndPlayCheckBox.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 

$Section1QueriesTab.Controls.Add($PlugAndPlayCheckBox)




# ============================================================================================================================================================
# Port Proxy Rules
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$PortProxyRulesCheckBox = New-Object System.Windows.Forms.CheckBox
$PortProxyRulesCheckBox.Name = "Port Proxy Rules *"

function PortProxyRulesCommand {
    $Message1            = "$($PortProxyRulesCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Port Proxy Rules"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($PortProxyRulesCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Invoke-Command -Credential $Credential -ComputerName $TargetComputer -ScriptBlock {
                    cmd /c netsh interface portproxy show all
                } -ArgumentList @($null) | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"

                if ((Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") -eq $null) {
                    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
                }
                else {
                    # Extracts the fields that become the file headers
                    <# $FileHeader = ""
                    foreach ($line in ($PortProxyRules | Select-Object -Skip 3 -First 1)) {$FileHeader += $line -replace ' {2,}',','} #>
                    $FileHeader = "Listen on IPv4 Address,Listen on IPv4 Port,Connect to IPv4 Address,Connect to IPv4 Port"

                    # Extracts the fields that contain data
                    $ProxyRules = Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"

                    $FileData = @()
                    foreach ($line in ($ProxyRules | Select-Object -Skip 5)) {$FileData += "`n$($line -replace ' {2,}',',')"}
                    $FileData = $FileData  -replace "^,|,$","" -replace "^ | $","" -replace ";;","`n" | Where-Object {$_.trim() -ne ""}
                    $FileData = foreach ($line in $($FileData | Where-Object {$_.trim() -ne ""}))  {"$TargetComputer," + $($line -replace "`n","")}

                    # Combines the csv header and data to create the file
                    $Combined = @()
                    $Combined += $FileHeader
                    $Combined += $FileData
                    $Combined | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"

                    # Add PSComputerName header and host/ip name
                    $AddTargetHost = (Import-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv")
                    $AddTargetHost | Add-Member -MemberType NoteProperty "PSComputerName" -Value "$TargetComputer"
                    $AddTargetHost | Select-Object -Property PSComputerName, * | Export-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation
                }
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Invoke-Command -ComputerName $TargetComputer -ScriptBlock {
                    cmd /c netsh interface portproxy show all
                } -ArgumentList @($null) | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"

                if ((Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") -eq $null) {
                    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
                }
                else {
                    # Extracts the fields that become the file headers
                    <# $FileHeader = ""
                    foreach ($line in ($PortProxyRules | Select-Object -Skip 3 -First 1)) {$FileHeader += $line -replace ' {2,}',','} #>
                    $FileHeader = "Listen on IPv4 Address,Listen on IPv4 Port,Connect to IPv4 Address,Connect to IPv4 Port"

                    # Extracts the fields that contain data
                    $ProxyRules = Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"

                    $FileData = @()
                    foreach ($line in ($ProxyRules | Select-Object -Skip 5)) {$FileData += "`n$($line -replace ' {2,}',',')"}
                    $FileData = $FileData  -replace "^,|,$","" -replace "^ | $","" -replace ";;","`n" | Where-Object {$_.trim() -ne ""}
                    $FileData = foreach ($line in $($FileData | Where-Object {$_.trim() -ne ""}))  {"$TargetComputer," + $($line -replace "`n","")}

                    # Combines the csv header and data to create the file
                    $Combined = @()
                    $Combined += $FileHeader
                    $Combined += $FileData
                    $Combined | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"

                    # Add PSComputerName header and host/ip name
                    $AddTargetHost = (Import-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv")
                    $AddTargetHost | Add-Member -MemberType NoteProperty "PSComputerName" -Value "$TargetComputer"
                    $AddTargetHost | Select-Object -Property PSComputerName, * | Export-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation
                }
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs
    
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($PortProxyRulesCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$PortProxyRulesCheckBox.Text     = "$($PortProxyRulesCheckBox.Name)"
$PortProxyRulesCheckBox.TabIndex = 2
$PortProxyRulesCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$PortProxyRulesCheckBox.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$PortProxyRulesCheckBox.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 

$Section1QueriesTab.Controls.Add($PortProxyRulesCheckBox)




# ============================================================================================================================================================
# Prefetch Files
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$PrefetchFilesCheckBox       = New-Object System.Windows.Forms.CheckBox
$PrefetchFilesCheckBox.Name  = "Prefetch Files *"

function PrefetchFilesCommand {
    $Message1                = "$($PrefetchFilesCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Prefetch Files"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($PrefetchFilesCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                  Invoke-Command -Credential $Credential -ComputerName $TargetComputer -ScriptBlock {
                        Get-ChildItem C:\Windows\Prefetch
                    } -ArgumentList @($null) `
                    | Select-Object -Property PSComputerName, Directory, Name, Length, CreationTime, LastWriteTime, LastAccessTime, Attributes, Mode `
                    | Export-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Invoke-Command -ComputerName $TargetComputer -ScriptBlock {
                    Get-ChildItem C:\Windows\Prefetch
                } -ArgumentList @($null) `
                | Select-Object -Property PSComputerName, Directory, Name, Length, CreationTime, LastWriteTime, LastAccessTime, Attributes, Mode `
                | Export-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs
    
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($PrefetchFilesCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$PrefetchFilesCheckBox.Text     = "$($PrefetchFilesCheckBox.Name)"
$PrefetchFilesCheckBox.TabIndex = 2
$PrefetchFilesCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$PrefetchFilesCheckBox.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$PrefetchFilesCheckBox.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 

$Section1QueriesTab.Controls.Add($PrefetchFilesCheckBox)




# ============================================================================================================================================================
# Process Tree (Lineage)
# ============================================================================================================================================================


# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$ProcessTreeLineageCheckBox = New-Object System.Windows.Forms.CheckBox
$ProcessTreeLineageCheckBox.Name = "Process Tree (Lineage) *"

function ProcessTreeLineageCommand {
    $Message1            = "$($ProcessTreeLineageCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")    
    $CollectionName      = "Process Tree (Lineage)"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($ProcessTreeLineageCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile      

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Invoke-Command -Credential $Credential -ComputerName $TargetComputer -ScriptBlock {
                    Function Get-ProcessTree {
                        '=================================================='
                        '{0,-7}{1}' -f 'PID','Process Name'
                        '==================================================' 
                        Function Get-ProcessChildren ($P,$Depth=1) {
                            $procs | Where-Object {
                                $_.ParentProcessId -eq $p.ProcessID -and $_.ParentProcessId -ne 0
                            } | ForEach-Object {
                                '{0,-7}{1}|--- {2}' -f $_.ProcessID,(' '*5*$Depth),$_.Name,$_.ParentProcessId 
                                Get-ProcessChildren $_ (++$Depth) 
                                $Depth-- 
                            }
                        } 
                        $filter = { -not (Get-Process -Id $_.ParentProcessId -ErrorAction SilentlyContinue) -or $_.ParentProcessId -eq 0 } 
                            $procs = Get-WmiObject -Class Win32_Process
                            $top = $procs | Where-Object $filter | Sort-Object ProcessID 
                        foreach ($p in $top) {
                            '{0,-7}{1}' -f $p.ProcessID, $p.Name 
                            Get-ProcessChildren $p
                        }
                    } 
                    Get-ProcessTree
                } -ArgumentList @($null) | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"                    
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'

                Invoke-Command -ComputerName $TargetComputer -ScriptBlock {
                    Function Get-ProcessTree {
                        '=================================================='
                        '{0,-7}{1}' -f 'PID','Process Name'
                        '==================================================' 
                        Function Get-ProcessChildren ($P,$Depth=1) {
                            $procs | Where-Object {
                                $_.ParentProcessId -eq $p.ProcessID -and $_.ParentProcessId -ne 0
                            } | ForEach-Object {
                                '{0,-7}{1}|--- {2}' -f $_.ProcessID,(' '*5*$Depth),$_.Name,$_.ParentProcessId 
                                Get-ProcessChildren $_ (++$Depth) 
                                $Depth-- 
                            }
                        } 
                        $filter = { -not (Get-Process -Id $_.ParentProcessId -ErrorAction SilentlyContinue) -or $_.ParentProcessId -eq 0 } 
                            $procs = Get-WmiObject -Class Win32_Process
                            $top = $procs | Where-Object $filter | Sort-Object ProcessID 
                        foreach ($p in $top) {
                            '{0,-7}{1}' -f $p.ProcessID, $p.Name 
                            Get-ProcessChildren $p
                        }
                    } 
                    Get-ProcessTree
                } -ArgumentList @($null) | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs
    
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($ProcessTreeLineageCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    ### No Compile-CsvFiles as this is just text
    # Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
    "You have to go into each 'Individual Host Results' to view their Process Trees (Lineage)" | Out-File "$PoShLocation\$CollectionName.txt"
    
}

$ProcessTreeLineageCheckBox.Text     = "$($ProcessTreeLineageCheckBox.Name)"
$ProcessTreeLineageCheckBox.TabIndex = 2
$ProcessTreeLineageCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$ProcessTreeLineageCheckBox.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$ProcessTreeLineageCheckBox.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 
$Section1QueriesTab.Controls.Add($ProcessTreeLineageCheckBox)





# ============================================================================================================================================================
# Processes - Enhanced with Hashes
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$ProcessesEnhancedCheckBox = New-Object System.Windows.Forms.CheckBox
$ProcessesEnhancedCheckBox.Name = "Processes - Enhanced with Hashes *"

function ProcessesEnhancedCommand {
    $Message1            = "$($ProcessesEnhancedCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Processes - Enhanced with Hashes"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        #$Message1            = "Collecting Data:  $($ProcessesEnhancedCheckBox.Name) from $TargetComputer"
        #$StatusListBox.Items.Clear()
        #$StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                $ErrorActionPreference="SilentlyContinue"
                function Get-FileHash{
                    param ([string] $Path ) $HashAlgorithm = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
                    $Hash=[System.BitConverter]::ToString($hashAlgorithm.ComputeHash([System.IO.File]::ReadAllBytes($Path)))
                    $Properties=@{"Algorithm" = "MD5"
                    "Path" = $Path
                    "Hash" = $Hash.Replace("-", "")
                    }
                $Ret=New-Object –TypeName PSObject –Prop $Properties
                return $Ret
                }
                function Get-Processes {
                    Write-Verbose "Getting ProcessList"
                    $processes = Get-WmiObject -Class Win32_Process
                    $processList = @()
                    foreach ($process in $processes) {
                        try {
                            $Owner = $process.GetOwner().Domain.ToString() + "\"+ $process.GetOwner().User.ToString()
                            $OwnerSID = $process.GetOwnerSid().Sid
                        } 
                        catch {}
                    $thisProcess=New-Object PSObject -Property @{
                        PSComputerName=$process.PSComputerName
                        OSName=$process.OSName
                        Name=$process.Caption
                        ProcessId=[int]$process.ProcessId
                        ParentProcessName=($processes | where {$_.ProcessID -eq $process.ParentProcessId}).Caption
                        ParentProcessId=[int]$process.ParentProcessId
                        MemoryKiloBytes=[int]$process.WorkingSetSize/1000
                        SessionId=[int]$process.SessionId
                        Owner=$Owner
                        OwnerSID=$OwnerSID
                        PathName=$process.ExecutablePath
                        CommandLine=$process.CommandLine
                        CreationDate=$process.ConvertToDateTime($process.CreationDate)
                    }
                    if ($process.ExecutablePath) {
                        $Signature = Get-FileHash $process.ExecutablePath | Select-Object -Property Hash, Algorithm
                        $Signature.PSObject.Properties | Foreach-Object {$thisProcess | Add-Member -type NoteProperty -Name $_.Name -Value $_.Value -Force}
                    } 
                    $processList += $thisProcess
                } 
                return $processList}
                Get-Processes | Select-Object -Property PSComputerName, Name, ProcessID, ParentProcessName, ParentProcessId, MemoryKiloBytes, CommandLine, PathName, Hash, Algorithm, CreationDate, Owner, OwnerSID, SessionId `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation


            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                $ErrorActionPreference="SilentlyContinue"
                function Get-FileHash{
                    param ([string] $Path ) $HashAlgorithm = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
                    $Hash=[System.BitConverter]::ToString($hashAlgorithm.ComputeHash([System.IO.File]::ReadAllBytes($Path)))
                    $Properties=@{"Algorithm" = "MD5"
                    "Path" = $Path
                    "Hash" = $Hash.Replace("-", "")
                    }
                $Ret=New-Object –TypeName PSObject –Prop $Properties
                return $Ret
                }
                function Get-Processes {
                    Write-Verbose "Getting ProcessList"
                    $processes = Get-WmiObject -Class Win32_Process -ComputerName $TargetComputer
                    $processList = @()
                    foreach ($process in $processes) {
                        try {
                            $Owner = $process.GetOwner().Domain.ToString() + "\"+ $process.GetOwner().User.ToString()
                            $OwnerSID = $process.GetOwnerSid().Sid
                        } 
                        catch {}
                    $thisProcess=New-Object PSObject -Property @{
                        PSComputerName=$process.PSComputerName
                        OSName=$process.OSName
                        Name=$process.Caption
                        ProcessId=[int]$process.ProcessId
                        ParentProcessName=($processes | where {$_.ProcessID -eq $process.ParentProcessId}).Caption
                        ParentProcessId=[int]$process.ParentProcessId
                        MemoryKiloBytes=[int]$process.WorkingSetSize/1000
                        SessionId=[int]$process.SessionId
                        Owner=$Owner
                        OwnerSID=$OwnerSID
                        PathName=$process.ExecutablePath
                        CommandLine=$process.CommandLine
                        CreationDate=$process.ConvertToDateTime($process.CreationDate)
                    }
                    if ($process.ExecutablePath) {
                        $Signature = Get-FileHash $process.ExecutablePath | Select-Object -Property Hash, Algorithm
                        $Signature.PSObject.Properties | Foreach-Object {$thisProcess | Add-Member -type NoteProperty -Name $_.Name -Value $_.Value -Force}
                    } 
                    $processList += $thisProcess
                } 
                return $processList}
                Get-Processes | Select-Object -Property PSComputerName, Name, ProcessID, ParentProcessName, ParentProcessId, MemoryKiloBytes, CommandLine, PathName, Hash, Algorithm, CreationDate, Owner, OwnerSID, SessionId `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs
    
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($ProcessesEnhancedCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$ProcessesEnhancedCheckBox.Text     = "$($ProcessesEnhancedCheckBox.Name)"
$ProcessesEnhancedCheckBox.TabIndex = 2
$ProcessesEnhancedCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$ProcessesEnhancedCheckBox.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$ProcessesEnhancedCheckBox.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 
$Section1QueriesTab.Controls.Add($ProcessesEnhancedCheckBox)




# ============================================================================================================================================================
# Processes - Standard
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$ProcessesStandardCheckBox = New-Object System.Windows.Forms.CheckBox
$ProcessesStandardCheckBox.Name = "Processes - Standard"

function ProcessesStandardCommand {
    $Message1            = "$($ProcessesStandardCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Processes - Standard"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($ProcessesStandardCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                                            
                Get-WmiObject -Credential $Credential -Class Win32_Process -ComputerName $TargetComputer `
                | Select-Object -Property PSComputerName, Name, ProcessID, ParentProcessID, Path, WorkingSetSize, Handle, HandleCount, ThreadCount, CreationDate `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                                            
                Get-WmiObject -Class Win32_Process -ComputerName $TargetComputer `
                | Select-Object -Property PSComputerName, Name, ProcessID, ParentProcessID, Path, WorkingSetSize, Handle, HandleCount, ThreadCount, CreationDate `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }  
    }
    MonitorJobs
    
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($ProcessesStandardCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$ProcessesStandardCheckBox.Text     = "$($ProcessesStandardCheckBox.Name)"
$ProcessesStandardCheckBox.TabIndex = 2
$ProcessesStandardCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$ProcessesStandardCheckBox.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$ProcessesStandardCheckBox.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 

$Section1QueriesTab.Controls.Add($ProcessesStandardCheckBox)




# ============================================================================================================================================================
# Processor Info
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$ProcessorCPUInfoCheckBox       = New-Object System.Windows.Forms.CheckBox
$ProcessorCPUInfoCheckBox.Name  = "Processor (CPU) Info"

function ProcessorCPUInfoCommand {
    $Message1            = "$($ProcessorCPUInfoCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Processor (CPU) Info"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($ProcessorCPUInfoCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Credential $Credential -Class Win32_Processor -ComputerName $TargetComputer `
                | Select-Object -Property PSComputerName, Name, Manufacturer, Caption, DeviceID, SocketDesignation, MaxClockSpeed  `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Class Win32_Processor -ComputerName $TargetComputer `
                | Select-Object -Property PSComputerName, Name, Manufacturer, Caption, DeviceID, SocketDesignation, MaxClockSpeed  `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs
    
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($ProcessorCPUInfoCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$ProcessorCPUInfoCheckBox.Text     = "$($ProcessorCPUInfoCheckBox.Name)"
$ProcessorCPUInfoCheckBox.TabIndex = 2
$ProcessorCPUInfoCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$ProcessorCPUInfoCheckBox.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$ProcessorCPUInfoCheckBox.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 

$Section1QueriesTab.Controls.Add($ProcessorCPUInfoCheckBox)




# ============================================================================================================================================================
# Scheduled Tasks (schtasks)
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$ScheduledTasksCheckBox = New-Object System.Windows.Forms.CheckBox
$ScheduledTasksCheckBox.Name = "Scheduled Tasks (schtasks) *"

function ScheduledTasksCommand {
    $Message1            = "$($ScheduledTasksCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Scheduled Tasks (schtasks)"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($ScheduledTasksCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'

                Invoke-Command -Credential $Credential -ComputerName $TargetComputer -ScriptBlock {
                    cmd /c schtasks /query /V /FO CSV
                } -ArgumentList @($null) | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"

                if ((Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv") -eq $null) {
                    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"
                }
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Invoke-Command -ComputerName $TargetComputer -ScriptBlock {
                    cmd /c schtasks /query /V /FO CSV
                } -ArgumentList @($null) | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"

                if ((Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv") -eq $null) {
                    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"
                }
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs
    
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($ScheduledTasksCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)
    
    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv" 
    Remove-DuplicateCsvHeaders
}

$ScheduledTasksCheckBox.Text     = "$($ScheduledTasksCheckBox.Name)"
$ScheduledTasksCheckBox.TabIndex = 2
$ScheduledTasksCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$ScheduledTasksCheckBox.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$ScheduledTasksCheckBox.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 

$Section1QueriesTab.Controls.Add($ScheduledTasksCheckBox)




# ============================================================================================================================================================
# Screen Saver Info
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$ScreenSaverInfoCheckBox = New-Object System.Windows.Forms.CheckBox
$ScreenSaverInfoCheckBox.Name = "Screen Saver Info"

function ScreenSaverInfoCommand {
    $Message1            = "$($ScreenSaverInfoCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Screen Saver Info"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($ScreenSaverInfoCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Credential $Credential -Class Win32_Desktop -ComputerName $TargetComputer `
                | Select-Object -Property PSComputerName, Name, ScreenSaverActive, ScreenSaverTimeout, ScreenSaverExecutable, Wallpaper `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Class Win32_Desktop -ComputerName $TargetComputer `
                | Select-Object -Property PSComputerName, Name, ScreenSaverActive, ScreenSaverTimeout, ScreenSaverExecutable, Wallpaper `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs
    
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($ScreenSaverInfoCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$ScreenSaverInfoCheckBox.Text     = "$($ScreenSaverInfoCheckBox.Name)"
$ScreenSaverInfoCheckBox.TabIndex = 2
$ScreenSaverInfoCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$ScreenSaverInfoCheckBox.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$ScreenSaverInfoCheckBox.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 

$Section1QueriesTab.Controls.Add($ScreenSaverInfoCheckBox)




# ============================================================================================================================================================
# Security Patches
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$SecurityPatchesCheckBox = New-Object System.Windows.Forms.CheckBox
$SecurityPatchesCheckBox.Name = "Security Patches"

function SecurityPatchesCommand {
    $Message1            = "$($SecurityPatchesCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Security Patches"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($SecurityPatchesCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Credential $Credential -Class Win32_QuickFixEngineering -ComputerName $TargetComputer `
                | Select-Object PSComputerName, HotFixID, Description, InstalledBy, InstalledOn `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Class Win32_QuickFixEngineering -ComputerName $TargetComputer `
                | Select-Object PSComputerName, HotFixID, Description, InstalledBy, InstalledOn `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        } 
    }
    MonitorJobs
    
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($SecurityPatchesCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$SecurityPatchesCheckBox.Text     = "$($SecurityPatchesCheckBox.Name)"
$SecurityPatchesCheckBox.TabIndex = 2
$SecurityPatchesCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$SecurityPatchesCheckBox.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$SecurityPatchesCheckBox.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 

$Section1QueriesTab.Controls.Add($SecurityPatchesCheckBox)




# ============================================================================================================================================================
# Services
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$ServicesCheckBox = New-Object System.Windows.Forms.CheckBox
$ServicesCheckBox.Name = "Services"

function ServicesCommand {
    $Message1            = "$($ServicesCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Services"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($ServicesCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                                            
                Get-WmiObject -Credential $Credential -Class Win32_Service -ComputerName $TargetComputer `
                | Select-Object PSComputerName, State, Name, ProcessID, Description, PathName, Started, StartMode, StartName | Sort-Object PSComputerName, State, Name `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                                            
                Get-WmiObject -Class Win32_Service -ComputerName $TargetComputer `
                | Select-Object PSComputerName, State, Name, ProcessID, Description, PathName, Started, StartMode, StartName | Sort-Object PSComputerName, State, Name `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs
    
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($ServicesCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$ServicesCheckBox.Text     = "$($ServicesCheckBox.Name)"
$ServicesCheckBox.TabIndex = 2
$ServicesCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$ServicesCheckBox.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$ServicesCheckBox.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 

$Section1QueriesTab.Controls.Add($ServicesCheckBox)




# ============================================================================================================================================================
# Shares
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift



$SharesCheckBox = New-Object System.Windows.Forms.CheckBox
$SharesCheckBox.Name = "Shares"

function SharesCommand {
    $Message1            = "$($SharesCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Shares"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($SharesCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Credential $Credential -Class Win32_Share -ComputerName $TargetComputer `
                | Select-Object PSComputerName, Name, Path, Description `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Class Win32_Share -ComputerName $TargetComputer `
                | Select-Object PSComputerName, Name, Path, Description `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs
    
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($SharesCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$SharesCheckBox.Text     = "$($SharesCheckBox.Name)"
$SharesCheckBox.TabIndex = 2
$SharesCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$SharesCheckBox.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$SharesCheckBox.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 

$Section1QueriesTab.Controls.Add($SharesCheckBox)




# ============================================================================================================================================================
# Software Installed
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$SoftwareInstalledCheckBox = New-Object System.Windows.Forms.CheckBox
$SoftwareInstalledCheckBox.Name = "Software Installed *"

function SoftwareInstalledCommand {
    $Message1            = "$($SoftwareInstalledCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Software Installed"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($SoftwareInstalledCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            

                Function Get-Software  {
                    [OutputType('System.Software.Inventory')]
                    [Cmdletbinding()] 
                    Param( 
                        [Parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)] 
                        [String[]]$Computername=$env:COMPUTERNAME
                    )         
                    Begin {}
                    Process  {
                        ForEach  ($Computer in  $Computername){ 
                            If  (Test-Connection -ComputerName  $Computer -Count  1 -Quiet) {
                            $Paths  = @("SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall","SOFTWARE\\Wow6432node\\Microsoft\\Windows\\CurrentVersion\\Uninstall")         
                                ForEach($Path in $Paths) { 
                                Write-Verbose  "Checking Path: $Path"
                                #  Create an instance of the Registry Object and open the HKLM base key 
                                Try  { 
                                    $reg=[microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine',$Computer,'Registry64') 
                                } 
                                Catch  { 
                                    Write-Error $_ 
                                    Continue 
                                } 
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
                                                    Try {
                                                        $Date = [datetime]::ParseExact($Date, 'yyyyMMdd', $Null)
                                                    }
                                                    Catch{
                                                        Write-Warning "$($Computer): $_ <$($Date)>"
                                                        $Date = $Null
                                                    }
                                                } 
                                                # Create New Object with empty Properties 
                                                $Publisher =  Try {
                                                    $thisSubKey.GetValue('Publisher').Trim()
                                                } 
                                                Catch {
                                                    $thisSubKey.GetValue('Publisher')
                                                }
                                                $Version = Try {
                                                    #Some weirdness with trailing [char]0 on some strings
                                                    $thisSubKey.GetValue('DisplayVersion').TrimEnd(([char[]](32,0)))
                                                } 
                                                Catch {
                                                    $thisSubKey.GetValue('DisplayVersion')
                                                }
                                                $UninstallString =  Try {
                                                    $thisSubKey.GetValue('UninstallString').Trim()
                                                } 
                                                Catch {
                                                    $thisSubKey.GetValue('UninstallString')
                                                }
                                                $InstallLocation =  Try {
                                                    $thisSubKey.GetValue('InstallLocation').Trim()
                                                } 
                                                Catch {
                                                    $thisSubKey.GetValue('InstallLocation')
                                                }
                                                $InstallSource =  Try {
                                                    $thisSubKey.GetValue('InstallSource').Trim()
                                                } 
                                                Catch {
                                                    $thisSubKey.GetValue('InstallSource')
                                                }
                                                $HelpLink = Try {
                                                    $thisSubKey.GetValue('HelpLink').Trim()
                                                } 
                                                Catch {
                                                    $thisSubKey.GetValue('HelpLink')
                                                }
                                                $Object = [pscustomobject]@{
                                                    Computername = $Computer
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
                                            Catch {
                                                Write-Warning "$Key : $_"
                                            }   
                                        }
                                    } 
                                    Catch  {}   
                                    $reg.Close() 
                                }                  
                            } 
                            Else  {
                                Write-Error  "$($Computer): unable to reach remote system!"
                            }
                        } 
                    } 
                } 
                Get-Software -Computername $TargetComputer `
                | Select-Object -Property @{Name = 'PSComputerName'; Expression = {$_.ComputerName}}, DisplayName, Version, InstallDate, Publisher, EstimatedSizeMB, UninstallString, InstallLocation, InstallSource, HelpLink `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

                # If the above doesn't provide any results, it will try to get the installed software using WMI... though obtaining results from Win32_Product class is painfully slow process
                if ((Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv").length -eq $null) {
                    Get-WmiObject -Credential $Credential Win32_Product -ComputerName $TargetComputer `
                    | Select-Object -Property PSComputerName, Name, Vendor, Version, InstallDate, InstallDate2, InstallLocation, InstallSource, PackageName, PackageCache, RegOwner, HelpLink, HelpTelephone, URLInfoAbout, URLUpdateInfo, Language, Description, IdentifyingNumber `
                    | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation                    
                }

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Function Get-Software  {
                    [OutputType('System.Software.Inventory')]
                    [Cmdletbinding()] 
                    Param( 
                        [Parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)] 
                        [String[]]$Computername=$env:COMPUTERNAME
                    )         
                    Begin {}
                    Process  {
                        ForEach  ($Computer in  $Computername){ 
                            If  (Test-Connection -ComputerName  $Computer -Count  1 -Quiet) {
                            $Paths  = @("SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall","SOFTWARE\\Wow6432node\\Microsoft\\Windows\\CurrentVersion\\Uninstall")         
                                ForEach($Path in $Paths) { 
                                Write-Verbose  "Checking Path: $Path"
                                #  Create an instance of the Registry Object and open the HKLM base key 
                                Try  { 
                                    $reg=[microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine',$Computer,'Registry64') 
                                } 
                                Catch  { 
                                    Write-Error $_ 
                                    Continue 
                                } 
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
                                                    Try {
                                                        $Date = [datetime]::ParseExact($Date, 'yyyyMMdd', $Null)
                                                    }
                                                    Catch{
                                                        Write-Warning "$($Computer): $_ <$($Date)>"
                                                        $Date = $Null
                                                    }
                                                } 
                                                # Create New Object with empty Properties 
                                                $Publisher =  Try {
                                                    $thisSubKey.GetValue('Publisher').Trim()
                                                } 
                                                Catch {
                                                    $thisSubKey.GetValue('Publisher')
                                                }
                                                $Version = Try {
                                                    #Some weirdness with trailing [char]0 on some strings
                                                    $thisSubKey.GetValue('DisplayVersion').TrimEnd(([char[]](32,0)))
                                                } 
                                                Catch {
                                                    $thisSubKey.GetValue('DisplayVersion')
                                                }
                                                $UninstallString =  Try {
                                                    $thisSubKey.GetValue('UninstallString').Trim()
                                                } 
                                                Catch {
                                                    $thisSubKey.GetValue('UninstallString')
                                                }
                                                $InstallLocation =  Try {
                                                    $thisSubKey.GetValue('InstallLocation').Trim()
                                                } 
                                                Catch {
                                                    $thisSubKey.GetValue('InstallLocation')
                                                }
                                                $InstallSource =  Try {
                                                    $thisSubKey.GetValue('InstallSource').Trim()
                                                } 
                                                Catch {
                                                    $thisSubKey.GetValue('InstallSource')
                                                }
                                                $HelpLink = Try {
                                                    $thisSubKey.GetValue('HelpLink').Trim()
                                                } 
                                                Catch {
                                                    $thisSubKey.GetValue('HelpLink')
                                                }
                                                $Object = [pscustomobject]@{
                                                    Computername = $Computer
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
                                            Catch {
                                                Write-Warning "$Key : $_"
                                            }   
                                        }
                                    } 
                                    Catch  {}   
                                    $reg.Close() 
                                }                  
                            } 
                            Else  {
                                Write-Error  "$($Computer): unable to reach remote system!"
                            }
                        } 
                    } 
                } 
                Get-Software -Computername $TargetComputer `
                | Select-Object -Property @{Name = 'PSComputerName'; Expression = {$_.ComputerName}}, DisplayName, Version, InstallDate, Publisher, EstimatedSizeMB, UninstallString, InstallLocation, InstallSource, HelpLink `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

                # If the above doesn't provide any results, it will try to get the installed software using WMI... though obtaining results from Win32_Product class is painfully slow process
                if ((Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv").length -eq $null) {
                    Get-WmiObject Win32_Product -ComputerName $TargetComputer `
                    | Select-Object -Property PSComputerName, Name, Vendor, Version, InstallDate, InstallDate2, InstallLocation, InstallSource, PackageName, PackageCache, RegOwner, HelpLink, HelpTelephone, URLInfoAbout, URLUpdateInfo, Language, Description, IdentifyingNumber `
                    | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation                    
                }
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }  
    }
    MonitorJobs
    
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($SoftwareInstalledCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$SoftwareInstalledCheckBox.Text     = "$($SoftwareInstalledCheckBox.Name)"
$SoftwareInstalledCheckBox.TabIndex = 2
$SoftwareInstalledCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$SoftwareInstalledCheckBox.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$SoftwareInstalledCheckBox.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 

$Section1QueriesTab.Controls.Add($SoftwareInstalledCheckBox)




# ============================================================================================================================================================
# System Information
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$SystemInfoCheckBox = New-Object System.Windows.Forms.CheckBox
$SystemInfoCheckBox.Name = "System Information *"

function SystemInfoCommand {
    $Message1            = "$($SystemInfoCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "System Information"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($SystemInfoCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Invoke-WmiMethod -Credential $Credential -Class Win32_Process -Name Create -ComputerName $TargetComputer -ArgumentList "cmd /c systeminfo /fo csv > `"C:\Windows\Temp\$CollectionShortName-$TargetComputer.csv`"" | Out-Null
    
                # This deleay is introduced to allow the collection command to complete gathering data before it pulls back the data
                Start-Sleep -Seconds $SleepTime

                # This copies the data from the target then removes the copy
                Copy-Item  -Credential $Credential "\\$TargetComputer\c$\Windows\Temp\$CollectionShortName-$TargetComputer.csv" "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory"
                Remove-Item -Credential $Credential "\\$TargetComputer\c$\Windows\Temp\$CollectionShortName-$TargetComputer.csv"
    
                # Adds the addtional column header, PSComputerName, and target computer to each connection
                $SystemInfo = Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionShortName-$TargetComputer.csv"
                $SystemInfo | ForEach-Object {
                    if ($_ -match '"Host Name","OS Name"') {"PSComputerName," + "$_"}
                    else {"$TargetComputer," + "$_"}
                } | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"
    
                Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionShortName-$TargetComputer.csv"

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Invoke-WmiMethod -Class Win32_Process -Name Create -ComputerName $TargetComputer -ArgumentList "cmd /c systeminfo /fo csv > `"C:\Windows\Temp\$CollectionShortName-$TargetComputer.csv`"" | Out-Null
    
                # This deleay is introduced to allow the collection command to complete gathering data before it pulls back the data
                Start-Sleep -Seconds $SleepTime

                # This copies the data from the target then removes the copy
                Copy-Item   "\\$TargetComputer\c$\Windows\Temp\$CollectionShortName-$TargetComputer.csv" "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory"
                Remove-Item "\\$TargetComputer\c$\Windows\Temp\$CollectionShortName-$TargetComputer.csv"
    
                # Adds the addtional column header, PSComputerName, and target computer to each connection
                $SystemInfo = Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionShortName-$TargetComputer.csv"
                $SystemInfo | ForEach-Object {
                    if ($_ -match '"Host Name","OS Name"') {"PSComputerName," + "$_"}
                    else {"$TargetComputer," + "$_"}
                } | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"
    
                Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionShortName-$TargetComputer.csv"

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs

    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($SystemInfoCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$SystemInfoCheckBox.Text     = "$($SystemInfoCheckBox.Name)"
$SystemInfoCheckBox.TabIndex = 2
$SystemInfoCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$SystemInfoCheckBox.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$SystemInfoCheckBox.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 

$Section1QueriesTab.Controls.Add($SystemInfoCheckBox)




# ============================================================================================================================================================
# USB Controller Device Connections
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column1DownPosition   += $Column1DownPositionShift


$USBControllerDevicesCheckBox = New-Object System.Windows.Forms.CheckBox
$USBControllerDevicesCheckBox.Name = "USB Controller Devices"

function USBControllerDevicesCommand {
    $Message1            = "$($USBControllerDevicesCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "USB Controller Devices"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($USBControllerDevicesCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                Get-WmiObject -Class Win32_USBControllerDevice -ComputerName $TargetComputer `
                | Foreach {[wmi]($_.Dependent)} `
                | Select-Object -Property PSComputerName, Name, Manufacturer, Status, Service, DeviceID, @{Name="HardwareID";Expression={$_.HardwareID}} `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                            
                #Get-WmiObject -Class Win32_USBControllerDevice -ComputerName $TargetComputer `
                #| Select-Object PSComputerName, Antecedent, Dependent `
                #| Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation
                
                Get-WmiObject -Class Win32_USBControllerDevice -ComputerName $TargetComputer `
                | Foreach {[wmi]($_.Dependent)} `
                | Select-Object -Property PSComputerName, Name, Manufacturer, Status, Service, DeviceID, @{Name="HardwareID";Expression={$_.HardwareID}} `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }  
    }
    MonitorJobs

    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($USBControllerDevicesCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$USBControllerDevicesCheckBox.Text     = "$($USBControllerDevicesCheckBox.Name)"
$USBControllerDevicesCheckBox.TabIndex = 2
$USBControllerDevicesCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$USBControllerDevicesCheckBox.Location = New-Object System.Drawing.Size($Column1RightPosition,$Column1DownPosition) 
$USBControllerDevicesCheckBox.Size     = New-Object System.Drawing.Size($Column1BoxWidth,$Column1BoxHeight) 

$Section1QueriesTab.Controls.Add($USBControllerDevicesCheckBox)




##############################################################################################################################################################
##############################################################################################################################################################
##
## Section 1 Active Directory Tab
##
##############################################################################################################################################################
##############################################################################################################################################################

# Varables
$ActiveDirectoryRightPosition     = 5
$ActiveDirectoryDownPositionStart = 10
$ActiveDirectoryDownPosition      = 10
$ActiveDirectoryDownPositionShift = 22
$ActiveDirectoryBoxWidth          = 410
$ActiveDirectoryBoxHeight         = 22


$Section1ActiveDirectoryTab          = New-Object System.Windows.Forms.TabPage
$Section1ActiveDirectoryTab.Location = $System_Drawing_Point
$Section1ActiveDirectoryTab.Text     = "Active Directory"
$Section1ActiveDirectoryTab.Location = New-Object System.Drawing.Size($ActiveDirectoryRightPosition,$ActiveDirectoryDownPosition) 
$Section1ActiveDirectoryTab.Size     = New-Object System.Drawing.Size($ActiveDirectoryBoxWidth,$ActiveDirectoryBoxHeight) 
$Section1ActiveDirectoryTab.TabIndex = 0
$Section1ActiveDirectoryTab.UseVisualStyleBackColor = $True
$Section1CollectionsTabControl.Controls.Add($Section1ActiveDirectoryTab)


# Shift the fields
$ActiveDirectoryDownPosition += $ActiveDirectoryDownPositionShift


#------------------------
# Active Directory Label
#------------------------

$ActiveDirectoryTabLabel1           = New-Object System.Windows.Forms.Label
$ActiveDirectoryTabLabel1.Location  = New-Object System.Drawing.Point(($ActiveDirectoryRightPosition),$ActiveDirectoryDownPositionStart) 
$ActiveDirectoryTabLabel1.Size      = New-Object System.Drawing.Size($ActiveDirectoryBoxWidth,$ActiveDirectoryBoxHeight) 
$ActiveDirectoryTabLabel1.Text      = "These options need to be ran on a Domain Controller Server."
$ActiveDirectoryTabLabel1.Font      = New-Object System.Drawing.Font("$Font",9,0,3,0)
$ActiveDirectoryTabLabel1.ForeColor = "Red"
$Section1ActiveDirectoryTab.Controls.Add($ActiveDirectoryTabLabel1)

# Shift the fields
$ActiveDirectoryDownPosition += $ActiveDirectoryDownPositionShift - 25



# ============================================================================================================================================================
# Active Directory - Account Details and User Information
# ============================================================================================================================================================

# Shift the fields
$ActiveDirectoryDownPosition += $ActiveDirectoryDownPositionShift


$ActiveDirectoryAccountDetailsAndUserInfoCheckBox = New-Object System.Windows.Forms.CheckBox
$ActiveDirectoryAccountDetailsAndUserInfoCheckBox.Name = "Active Directory - Account Details and User Information"

function ActiveDirectoryAccountDetailsAndUserInfoCommand {
    $Message1            = "$($ActiveDirectoryAccountDetailsAndUserInfoCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Active Directory - Account Details and User Information"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($ActiveDirectoryAccountDetailsAndUserInfoCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                                            
                Invoke-Command -Credential $Credential -ComputerName $TargetComputer -ScriptBlock {
                    Get-ADUser -Filter * -Properties * `
                    | Select-Object Name, CanonicalName, SID, Enabled, LockedOut, AccountLockoutTime, Created, LogonWorkStations, LastLogonDate, LastBadPasswordAttempt, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CannotChangePassword, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive, Title, Organization, Office, POBox, StreetAddress, City, State, PostalCode, Fax, OfficePhone, HomePhone, MobilePhone, EmailAddress
                } | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation -Force

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                                            
                Invoke-Command -ComputerName $TargetComputer -ScriptBlock {
                    Get-ADUser -Filter * -Properties * `
                    | Select-Object Name, CanonicalName, SID, Enabled, LockedOut, AccountLockoutTime, Created, LogonWorkStations, LastLogonDate, LastBadPasswordAttempt, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CannotChangePassword, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive, Title, Organization, Office, POBox, StreetAddress, City, State, PostalCode, Fax, OfficePhone, HomePhone, MobilePhone, EmailAddress
                } | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation -Force

                if ((Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv") -eq $null) {
                    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"
                
                    Invoke-Command -ComputerName $TargetComputer -ScriptBlock {
                        net users /domain
                    } | Export-CSV "$PoShLocation\$CollectionName-$TargetComputer.txt" -NoTypeInformation -Force
                }

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs

    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($ActiveDirectoryAccountDetailsAndUserInfoCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$ActiveDirectoryAccountDetailsAndUserInfoCheckBox.Text      = "$($ActiveDirectoryAccountDetailsAndUserInfoCheckBox.Name)"
$ActiveDirectoryAccountDetailsAndUserInfoCheckBox.TabIndex  = 2
$ActiveDirectoryAccountDetailsAndUserInfoCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$ActiveDirectoryAccountDetailsAndUserInfoCheckBox.Location  = New-Object System.Drawing.Point($ActiveDirectoryRightPosition,$ActiveDirectoryDownPosition) 
$ActiveDirectoryAccountDetailsAndUserInfoCheckBox.Size      = New-Object System.Drawing.Size($ActiveDirectoryBoxWidth,$ActiveDirectoryBoxHeight) 
$Section1ActiveDirectoryTab.Controls.Add($ActiveDirectoryAccountDetailsAndUserInfoCheckBox)




# ============================================================================================================================================================
# Active Directory - Account Logon & Passowrd Policy
# ============================================================================================================================================================

# Shift the fields
$ActiveDirectoryDownPosition += $ActiveDirectoryDownPositionShift


$ActiveDirectoryAccountLogonAndPassowrdPolicyCheckBox = New-Object System.Windows.Forms.CheckBox
$ActiveDirectoryAccountLogonAndPassowrdPolicyCheckBox.Name = "Active Directory - Account Logon & Password Policy"

function ActiveDirectoryAccountLogonAndPassowrdPolicyCommand {
    $Message1            = "$($ActiveDirectoryAccountLogonAndPassowrdPolicyCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Active Directory - Account Logon & Passowrd Policy"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($ActiveDirectoryAccountLogonAndPassowrdPolicyCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                                            
                Invoke-Command -Credential $Credential -ComputerName $TargetComputer -ScriptBlock {
                    Get-ADUser -Filter * -Properties * `
                    | Select-Object Name, Enabled, LockedOut, AccountLockoutTime, LogonWorkStations, LastLogonDate, LastBadPasswordAttempt, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CannotChangePassword
                } | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation -Force

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                                            
                Invoke-Command -ComputerName $TargetComputer -ScriptBlock {
                    Get-ADUser -Filter * -Properties * `
                    | Select-Object Name, Enabled, LockedOut, AccountLockoutTime, LogonWorkStations, LastLogonDate, LastBadPasswordAttempt, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CannotChangePassword
                } | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation -Force

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs

    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($ActiveDirectoryAccountLogonAndPassowrdPolicyCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$ActiveDirectoryAccountLogonAndPassowrdPolicyCheckBox.Text     = "$($ActiveDirectoryAccountLogonAndPassowrdPolicyCheckBox.Name)"
$ActiveDirectoryAccountLogonAndPassowrdPolicyCheckBox.TabIndex = 2
$ActiveDirectoryAccountLogonAndPassowrdPolicyCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$ActiveDirectoryAccountLogonAndPassowrdPolicyCheckBox.Location  = New-Object System.Drawing.Point($ActiveDirectoryRightPosition,$ActiveDirectoryDownPosition) 
$ActiveDirectoryAccountLogonAndPassowrdPolicyCheckBox.Size      = New-Object System.Drawing.Size($ActiveDirectoryBoxWidth,$ActiveDirectoryBoxHeight) 
$Section1ActiveDirectoryTab.Controls.Add($ActiveDirectoryAccountLogonAndPassowrdPolicyCheckBox)





# ============================================================================================================================================================
# Active Directory - Account Contact Information
# ============================================================================================================================================================

# Shift the fields
$ActiveDirectoryDownPosition += $ActiveDirectoryDownPositionShift


$ActiveDirectoryAccountContactInfoCheckBox = New-Object System.Windows.Forms.CheckBox
$ActiveDirectoryAccountContactInfoCheckBox.Name = "Active Directory - Account Contact Information"

function ActiveDirectoryAccountContactInfoCommand {
    $Message1            = "$($ActiveDirectoryAccountContactInfoCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Active Directory - Account Contact Information"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($ActiveDirectoryAccountContactInfoCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                                            
                Invoke-Command -Credential $Credential -ComputerName $TargetComputer -ScriptBlock {
                    Get-ADUser -Filter * -Properties * `
                    | Select-Object Name, Title, Organization, Office, POBox, StreetAddress, City, State, PostalCode, Fax, OfficePhone, HomePhone, MobilePhone, EmailAddress
                } | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation -Force

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                                            
                Invoke-Command -ComputerName $TargetComputer -ScriptBlock {
                    Get-ADUser -Filter * -Properties * `
                    | Select-Object Name, Title, Organization, Office, POBox, StreetAddress, City, State, PostalCode, Fax, OfficePhone, HomePhone, MobilePhone, EmailAddress
                } | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation -Force
                    
            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs
    
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($ActiveDirectoryAccountContactInfoCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$ActiveDirectoryAccountContactInfoCheckBox.Text     = "$($ActiveDirectoryAccountContactInfoCheckBox.Name)"
$ActiveDirectoryAccountContactInfoCheckBox.TabIndex = 2
$ActiveDirectoryAccountContactInfoCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$ActiveDirectoryAccountContactInfoCheckBox.Location  = New-Object System.Drawing.Point($ActiveDirectoryRightPosition,$ActiveDirectoryDownPosition) 
$ActiveDirectoryAccountContactInfoCheckBox.Size      = New-Object System.Drawing.Size($ActiveDirectoryBoxWidth,$ActiveDirectoryBoxHeight) 
$Section1ActiveDirectoryTab.Controls.Add($ActiveDirectoryAccountContactInfoCheckBox)






# ============================================================================================================================================================
# Active Directory - Account Email Addresses
# ============================================================================================================================================================

# Shift the fields
$ActiveDirectoryDownPosition += $ActiveDirectoryDownPositionShift


$ActiveDirectoryAccountEmailAddressesCheckBox = New-Object System.Windows.Forms.CheckBox
$ActiveDirectoryAccountEmailAddressesCheckBox.Name = "Active Directory - Account Email Addresses"

function ActiveDirectoryAccountEmailAddressesCommand {
    $Message1            = "$($ActiveDirectoryAccountEmailAddressesCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Active Directory - Account Email Addresses"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($ActiveDirectoryAccountEmailAddressesCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                                            
                Invoke-Command -Credential $Credential -ComputerName $TargetComputer -ScriptBlock {
                    Get-ADUser -Filter * -Properties * `
                    | Where-Object {$_.EmailAddress -ne $null} `
                    | Select-Object Name, EmailAddress
                } | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation -Force

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                                            
                Invoke-Command -ComputerName $TargetComputer -ScriptBlock {
                    Get-ADUser -Filter * -Properties * `
                    | Where-Object {$_.EmailAddress -ne $null} `
                    | Select-Object Name, EmailAddress
                } | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation -Force

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs
    
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($ActiveDirectoryAccountEmailAddressesCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$ActiveDirectoryAccountEmailAddressesCheckBox.Text     = "$($ActiveDirectoryAccountEmailAddressesCheckBox.Name)"
$ActiveDirectoryAccountEmailAddressesCheckBox.TabIndex = 2
$ActiveDirectoryAccountEmailAddressesCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$ActiveDirectoryAccountEmailAddressesCheckBox.Location  = New-Object System.Drawing.Point($ActiveDirectoryRightPosition,$ActiveDirectoryDownPosition) 
$ActiveDirectoryAccountEmailAddressesCheckBox.Size      = New-Object System.Drawing.Size($ActiveDirectoryBoxWidth,$ActiveDirectoryBoxHeight) 
$Section1ActiveDirectoryTab.Controls.Add($ActiveDirectoryAccountEmailAddressesCheckBox)



# ============================================================================================================================================================
# Active Directory - Account Phone Numbers
# ============================================================================================================================================================

# Shift the fields
$ActiveDirectoryDownPosition += $ActiveDirectoryDownPositionShift


$ActiveDirectoryAccountPhoneNumbersCheckBox = New-Object System.Windows.Forms.CheckBox
$ActiveDirectoryAccountPhoneNumbersCheckBox.Name = "Active Directory - Account Phone Numbers"

function ActiveDirectoryAccountPhoneNumbersCommand {
    $Message1            = "$($ActiveDirectoryAccountPhoneNumbersCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Active Directory - Account Phone Numbers"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($ActiveDirectoryAccountPhoneNumbersCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                                            
                Invoke-Command -Credential $Credential -ComputerName $TargetComputer -ScriptBlock {
                    Get-ADUser -Filter * -Properties * `
                    | Where-Object {($_.OfficePhone -ne $null) -or ($_.HomePhone -ne $null) -or ($_.MobilePhone -ne $null)} `
                    | Select-Object Name, OfficePhone, HomePhone, MobilePhone
                } | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation -Force

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                                            
                Invoke-Command -ComputerName $TargetComputer -ScriptBlock {
                    Get-ADUser -Filter * -Properties * `
                    | Where-Object {($_.OfficePhone -ne $null) -or ($_.HomePhone -ne $null) -or ($_.MobilePhone -ne $null)} `
                    | Select-Object Name, OfficePhone, HomePhone, MobilePhone
                } | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation -Force

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs
    
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($ActiveDirectoryAccountPhoneNumbersCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$ActiveDirectoryAccountPhoneNumbersCheckBox.Text     = "$($ActiveDirectoryAccountPhoneNumbersCheckBox.Name)"
$ActiveDirectoryAccountPhoneNumbersCheckBox.TabIndex = 2
$ActiveDirectoryAccountPhoneNumbersCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$ActiveDirectoryAccountPhoneNumbersCheckBox.Location  = New-Object System.Drawing.Point($ActiveDirectoryRightPosition,$ActiveDirectoryDownPosition) 
$ActiveDirectoryAccountPhoneNumbersCheckBox.Size      = New-Object System.Drawing.Size($ActiveDirectoryBoxWidth,$ActiveDirectoryBoxHeight) 
$Section1ActiveDirectoryTab.Controls.Add($ActiveDirectoryAccountPhoneNumbersCheckBox)





# ============================================================================================================================================================
# Active Directory - Computers Details and OS Info
# ============================================================================================================================================================

# Shift the fields
$ActiveDirectoryDownPosition += $ActiveDirectoryDownPositionShift


$ActiveDirectoryComputersCheckBox = New-Object System.Windows.Forms.CheckBox
$ActiveDirectoryComputersCheckBox.Name = "Active Directory - Computers"

function ActiveDirectoryComputersCommand {
    $Message1            = "$($ActiveDirectoryComputersCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Active Directory - Computers"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($ActiveDirectoryComputersCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                                            
                Invoke-Command -Credential $Credential -ComputerName $TargetComputer -ScriptBlock {
                    Get-ADComputer -Filter * -Properties *  `
                    | Select-Object -Property Enabled, Name, OperatingSystem, OperatingSystemServicePack, OperatingSystemHotfix, OperatingSystemVersion, IPv4Address, IPv6Address, LastLogonDate, Created, ObjectClass, SID, SIDHistory, DistinguishedName, DNSHostName, SamAccountName, CannotChangePassword
                } | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation -Force

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                                            
                Invoke-Command -ComputerName $TargetComputer -ScriptBlock {
                    Get-ADComputer -Filter * -Properties *  `
                    | Select-Object -Property Enabled, Name, OperatingSystem, OperatingSystemServicePack, OperatingSystemHotfix, OperatingSystemVersion, IPv4Address, IPv6Address, LastLogonDate, Created, ObjectClass, SID, SIDHistory, DistinguishedName, DNSHostName, SamAccountName, CannotChangePassword
                } | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation -Force

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs
    
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($ActiveDirectoryComputersCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$ActiveDirectoryComputersCheckBox.Text     = "$($ActiveDirectoryComputersCheckBox.Name)"
$ActiveDirectoryComputersCheckBox.TabIndex = 2
$ActiveDirectoryComputersCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$ActiveDirectoryComputersCheckBox.Location  = New-Object System.Drawing.Point($ActiveDirectoryRightPosition,$ActiveDirectoryDownPosition) 
$ActiveDirectoryComputersCheckBox.Size      = New-Object System.Drawing.Size($ActiveDirectoryBoxWidth,$ActiveDirectoryBoxHeight) 
$Section1ActiveDirectoryTab.Controls.Add($ActiveDirectoryComputersCheckBox)



# ============================================================================================================================================================
# Active Directory - Default Domain Password Policy
# ============================================================================================================================================================

# Shift the fields
$ActiveDirectoryDownPosition += $ActiveDirectoryDownPositionShift


$ActiveDirectoryDefaultDomainPasswordPolicyCheckBox = New-Object System.Windows.Forms.CheckBox
$ActiveDirectoryDefaultDomainPasswordPolicyCheckBox.Name = "Active Directory - Default Domain Password Policy"

function ActiveDirectoryDefaultDomainPasswordPolicyCommand {
    $Message1            = "$($ActiveDirectoryDefaultDomainPasswordPolicyCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Active Directory - Default Domain Password Policy"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($ActiveDirectoryDefaultDomainPasswordPolicyCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                                            
                Invoke-Command -Credential $Credential -ComputerName $TargetComputer -ScriptBlock {
                    Get-ADDefaultDomainPasswordPolicy
                } | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation -Force

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                                            
                Invoke-Command -ComputerName $TargetComputer -ScriptBlock {
                    Get-ADDefaultDomainPasswordPolicy
                } | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation -Force

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs
    
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($ActiveDirectoryDefaultDomainPasswordPolicyCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$ActiveDirectoryDefaultDomainPasswordPolicyCheckBox.Text     = "$($ActiveDirectoryDefaultDomainPasswordPolicyCheckBox.Name)"
$ActiveDirectoryDefaultDomainPasswordPolicyCheckBox.TabIndex = 2
$ActiveDirectoryDefaultDomainPasswordPolicyCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$ActiveDirectoryDefaultDomainPasswordPolicyCheckBox.Location  = New-Object System.Drawing.Point($ActiveDirectoryRightPosition,$ActiveDirectoryDownPosition) 
$ActiveDirectoryDefaultDomainPasswordPolicyCheckBox.Size      = New-Object System.Drawing.Size($ActiveDirectoryBoxWidth,$ActiveDirectoryBoxHeight) 
$Section1ActiveDirectoryTab.Controls.Add($ActiveDirectoryDefaultDomainPasswordPolicyCheckBox)

# ============================================================================================================================================================
# Active Directory - Groups
# ============================================================================================================================================================

# Shift the fields
$ActiveDirectoryDownPosition += $ActiveDirectoryDownPositionShift


$ActiveDirectoryGroupsCheckBox = New-Object System.Windows.Forms.CheckBox
$ActiveDirectoryGroupsCheckBox.Name = "Active Directory - Groups"

function ActiveDirectoryGroupsCommand {
    $Message1            = "$($ActiveDirectoryGroupsCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Active Directory - Groups"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($ActiveDirectoryGroupsCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                                            
                Invoke-Command -Credential $Credential -ComputerName $TargetComputer -ScriptBlock {
                    Get-ADGroup -Filter * `
                    | Select-Object -Property Name, SID, GroupCategory, GroupScope, DistinguishedName
                } | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation -Force

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                                            
                Invoke-Command -ComputerName $TargetComputer -ScriptBlock {
                    Get-ADGroup -Filter * `
                    | Select-Object -Property Name, SID, GroupCategory, GroupScope, DistinguishedName
                } | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation -Force

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs
    
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($ActiveDirectoryGroupsCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$ActiveDirectoryGroupsCheckBox.Text     = "$($ActiveDirectoryGroupsCheckBox.Name)"
$ActiveDirectoryGroupsCheckBox.TabIndex = 2
$ActiveDirectoryGroupsCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$ActiveDirectoryGroupsCheckBox.Location  = New-Object System.Drawing.Point($ActiveDirectoryRightPosition,$ActiveDirectoryDownPosition) 
$ActiveDirectoryGroupsCheckBox.Size      = New-Object System.Drawing.Size($ActiveDirectoryBoxWidth,$ActiveDirectoryBoxHeight) 
$Section1ActiveDirectoryTab.Controls.Add($ActiveDirectoryGroupsCheckBox)




# ============================================================================================================================================================
# Active Directory - Group Membership by Groups
# ============================================================================================================================================================

# Shift the fields
$ActiveDirectoryDownPosition += $ActiveDirectoryDownPositionShift


$ActiveDirectoryGroupMembershipByGroupsCheckBox = New-Object System.Windows.Forms.CheckBox
$ActiveDirectoryGroupMembershipByGroupsCheckBox.Name = "Active Directory - Group Membership By Groups"

function ActiveDirectoryGroupMembershipByGroupsCommand {
    $Message1            = "$($ActiveDirectoryGroupMembershipByGroupsCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Active Directory - Group Membership by Groups"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($ActiveDirectoryGroupMembershipByGroupsCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                                            
                Invoke-Command -Credential $Credential -ComputerName $TargetComputer -ScriptBlock {
                    #Gets a list of all the groups
                    $ADGroupList = Get-ADGroup -Filter * | Select-Object -ExpandProperty Name
                    foreach ($Group in $ADGroupList) {
                        $GroupMemberships = Get-ADGroupMember $Group
                        $GroupMemberships | Add-Member -MemberType NoteProperty -Name GroupName -Value $Group -Force
                        $GroupMemberships | select * -First 1
                        $GroupMemberships | Select-Object -Property PSComputerName, GroupName, SamAccountName, SID, GroupCategory, GroupScope, DistinguishedName 
                    } 
                } | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation -Force

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                                            
                Invoke-Command -ComputerName $TargetComputer -ScriptBlock {
                    #Gets a list of all the groups
                    $ADGroupList = Get-ADGroup -Filter * | Select-Object -ExpandProperty Name
                    foreach ($Group in $ADGroupList) {
                        $GroupMemberships = Get-ADGroupMember $Group
                        $GroupMemberships | Add-Member -MemberType NoteProperty -Name GroupName -Value $Group -Force
                        $GroupMemberships | select * -First 1
                        $GroupMemberships | Select-Object -Property PSComputerName, GroupName, SamAccountName, SID, GroupCategory, GroupScope, DistinguishedName 
                    } 
                } | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation -Force

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs
    
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($ActiveDirectoryGroupMembershipByGroupsCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$ActiveDirectoryGroupMembershipByGroupsCheckBox.Text     = "$($ActiveDirectoryGroupMembershipByGroupsCheckBox.Name)"
$ActiveDirectoryGroupMembershipByGroupsCheckBox.TabIndex = 2
$ActiveDirectoryGroupMembershipByGroupsCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$ActiveDirectoryGroupMembershipByGroupsCheckBox.Location  = New-Object System.Drawing.Point($ActiveDirectoryRightPosition,$ActiveDirectoryDownPosition) 
$ActiveDirectoryGroupMembershipByGroupsCheckBox.Size      = New-Object System.Drawing.Size($ActiveDirectoryBoxWidth,$ActiveDirectoryBoxHeight) 
$Section1ActiveDirectoryTab.Controls.Add($ActiveDirectoryGroupMembershipByGroupsCheckBox)




# ============================================================================================================================================================
# Active Directory - Group Membership by Users
# ============================================================================================================================================================

# Shift the fields
$ActiveDirectoryDownPosition += $ActiveDirectoryDownPositionShift


$ActiveDirectoryGroupMembershipByUsersCheckBox = New-Object System.Windows.Forms.CheckBox
$ActiveDirectoryGroupMembershipByUsersCheckBox.Name = "Active Directory - Group Membership by Users"

function ActiveDirectoryGroupMembershipByUsersCommand {
    $Message1            = "$($ActiveDirectoryGroupMembershipByUsersCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Active Directory - Group Membership by Users"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($ActiveDirectoryGroupMembershipByUsersCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                                            
                Invoke-Command -Credential $Credential -ComputerName $TargetComputer -ScriptBlock {
                    ###get-aduser dan -property Memberof | Select -ExpandProperty memberOf
                    $ADUserList = Get-ADUser -filter * | Select-Object -ExpandProperty SamAccountName
                    foreach ($SamAccountName in $ADUserList) {                        
                        $GroupMemberships = Get-ADPrincipalGroupMembership -Identity $SamAccountName
                        $GroupMemberships | Add-Member -MemberType NoteProperty -Name SamAccountName -Value $SamAccountName -Force
                        $GroupMemberships | Select-Object -Property SamAccountName, @{Name="Group Name";Expression={$_.Name}}, SID, GroupCategory, GroupScope, DistinguishedName
                    } 
                } | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation -Force

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                                            
                Invoke-Command -ComputerName $TargetComputer -ScriptBlock {                    
                    ###get-aduser dan -property Memberof | Select -ExpandProperty memberOf
                    $ADUserList = Get-ADUser -filter * | Select-Object -ExpandProperty SamAccountName
                    foreach ($SamAccountName in $ADUserList) {                        
                        $GroupMemberships = Get-ADPrincipalGroupMembership -Identity $SamAccountName
                        $GroupMemberships | Add-Member -MemberType NoteProperty -Name SamAccountName -Value $SamAccountName -Force
                        $GroupMemberships | Select-Object -Property SamAccountName, @{Name="Group Name";Expression={$_.Name}}, SID, GroupCategory, GroupScope, DistinguishedName
                    } 
                } | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation -Force

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs
    
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($ActiveDirectoryGroupMembershipByUsersCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$ActiveDirectoryGroupMembershipByUsersCheckBox.Text     = "$($ActiveDirectoryGroupMembershipByUsersCheckBox.Name)"
$ActiveDirectoryGroupMembershipByUsersCheckBox.TabIndex = 2
$ActiveDirectoryGroupMembershipByUsersCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$ActiveDirectoryGroupMembershipByUsersCheckBox.Location  = New-Object System.Drawing.Point($ActiveDirectoryRightPosition,$ActiveDirectoryDownPosition) 
$ActiveDirectoryGroupMembershipByUsersCheckBox.Size      = New-Object System.Drawing.Size($ActiveDirectoryBoxWidth,$ActiveDirectoryBoxHeight) 
$Section1ActiveDirectoryTab.Controls.Add($ActiveDirectoryGroupMembershipByUsersCheckBox)




# ============================================================================================================================================================
# Active Directory - Groups Without Account Members
# ============================================================================================================================================================

# Shift the fields
$ActiveDirectoryDownPosition += $ActiveDirectoryDownPositionShift


$ActiveDirectoryGroupsWithoutAccountMembersCheckBox = New-Object System.Windows.Forms.CheckBox
$ActiveDirectoryGroupsWithoutAccountMembersCheckBox.Name = "Active Directory - Groups Without Account Members"

function ActiveDirectoryGroupsWithoutAccountMembersCommand {
    $Message1            = "$($ActiveDirectoryGroupsWithoutAccountMembersCheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "Active Directory - Groups Without Account Members"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($ActiveDirectoryGroupsWithoutAccountMembersCheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                                            
                Invoke-Command -Credential $Credential -ComputerName $TargetComputer -ScriptBlock {
                    Get-ADGroup -filter * `
                    | Where-Object {-Not ($_ | Get-ADGroupMember)} 
                } | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation -Force

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                                            
                Invoke-Command -ComputerName $TargetComputer -ScriptBlock {
                    Get-ADGroup -filter * `
                    | Where-Object {-Not ($_ | Get-ADGroupMember)} 
                } | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation -Force

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs
    
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($ActiveDirectoryGroupsWithoutAccountMembersCheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$ActiveDirectoryGroupsWithoutAccountMembersCheckBox.Text     = "$($ActiveDirectoryGroupsWithoutAccountMembersCheckBox.Name)"
$ActiveDirectoryGroupsWithoutAccountMembersCheckBox.TabIndex = 2
$ActiveDirectoryGroupsWithoutAccountMembersCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$ActiveDirectoryGroupsWithoutAccountMembersCheckBox.Location  = New-Object System.Drawing.Point($ActiveDirectoryRightPosition,$ActiveDirectoryDownPosition) 
$ActiveDirectoryGroupsWithoutAccountMembersCheckBox.Size      = New-Object System.Drawing.Size($ActiveDirectoryBoxWidth,$ActiveDirectoryBoxHeight) 
$Section1ActiveDirectoryTab.Controls.Add($ActiveDirectoryGroupsWithoutAccountMembersCheckBox)



# ============================================================================================================================================================
# Domain - DNS All Records (Server 2008)
# ============================================================================================================================================================

# Shift the fields
$ActiveDirectoryDownPosition += $ActiveDirectoryDownPositionShift


$DomainDNSAllRecordsServer2008CheckBox = New-Object System.Windows.Forms.CheckBox
$DomainDNSAllRecordsServer2008CheckBox.Name = "DNS All Records (Server 2008)"

function DomainDNSAllRecordsServer2008Command {
    $Message1            = "$($DomainDNSAllRecordsServer2008CheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "DNS All Records (Server 2008)"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($DomainDNSAllRecordsServer2008CheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                                            
                Get-WmiObject -Credential $Credential -ComputerName $TargetComputer -Namespace root\MicrosoftDNS -class microsoftdns_resourcerecord `
                | Select-Object PSComputerName, __Class, ContainerName, DomainName, RecordData, OwnerName `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                                            
                Get-WmiObject -ComputerName $TargetComputer -Namespace root\MicrosoftDNS -class microsoftdns_resourcerecord `
                | Select-Object PSComputerName, __Class, ContainerName, DomainName, RecordData, OwnerName `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs
    
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($DomainDNSAllRecordsServer2008CheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$DomainDNSAllRecordsServer2008CheckBox.Text     = "$($DomainDNSAllRecordsServer2008CheckBox.Name)"
$DomainDNSAllRecordsServer2008CheckBox.TabIndex = 2
$DomainDNSAllRecordsServer2008CheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$DomainDNSAllRecordsServer2008CheckBox.Location  = New-Object System.Drawing.Point($ActiveDirectoryRightPosition,$ActiveDirectoryDownPosition) 
$DomainDNSAllRecordsServer2008CheckBox.Size      = New-Object System.Drawing.Size($ActiveDirectoryBoxWidth,$ActiveDirectoryBoxHeight) 
$Section1ActiveDirectoryTab.Controls.Add($DomainDNSAllRecordsServer2008CheckBox)



# ============================================================================================================================================================
# Domain - DNS Root Hints (Server 2008)
# ============================================================================================================================================================

# Shift the fields
$ActiveDirectoryDownPosition += $ActiveDirectoryDownPositionShift


$DomainDNSRootHintsServer2008CheckBox = New-Object System.Windows.Forms.CheckBox
$DomainDNSRootHintsServer2008CheckBox.Name = "DNS Root Hints (Server 2008)"

function DomainDNSRootHintsServer2008Command {
    $Message1            = "$($DomainDNSRootHintsServer2008CheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "DNS Root Hints (Server 2008)"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($DomainDNSRootHintsServer2008CheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                                            
                Get-WmiObject -Credential $Credential -Namespace root\MicrosoftDNS -class microsoftdns_resourcerecord `
                | Where-Object {$_.domainname -eq "..roothints"} `
                | Select-Object PSComputerName, * `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                                            
                Get-WmiObject -Namespace root\MicrosoftDNS -class microsoftdns_resourcerecord `
                | Where-Object {$_.domainname -eq "..roothints"} `
                | Select-Object PSComputerName, * `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation


            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs
    
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($DomainDNSRootHintsServer2008CheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$DomainDNSRootHintsServer2008CheckBox.Text     = "$($DomainDNSRootHintsServer2008CheckBox.Name)"
$DomainDNSRootHintsServer2008CheckBox.TabIndex = 2
$DomainDNSRootHintsServer2008CheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$DomainDNSRootHintsServer2008CheckBox.Location  = New-Object System.Drawing.Point($ActiveDirectoryRightPosition,$ActiveDirectoryDownPosition) 
$DomainDNSRootHintsServer2008CheckBox.Size      = New-Object System.Drawing.Size($ActiveDirectoryBoxWidth,$ActiveDirectoryBoxHeight) 
$Section1ActiveDirectoryTab.Controls.Add($DomainDNSRootHintsServer2008CheckBox)



# ============================================================================================================================================================
# Domain - DNS Zones (Server 2008)
# ============================================================================================================================================================

# Shift the fields
$ActiveDirectoryDownPosition += $ActiveDirectoryDownPositionShift


$DomainDNSZonesServer2008CheckBox = New-Object System.Windows.Forms.CheckBox
$DomainDNSZonesServer2008CheckBox.Name = "DNS Zones (Server 2008)"

function DomainDNSZonesServer2008Command {
    $Message1            = "$($DomainDNSZonesServer2008CheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "DNS Zones (Server 2008)"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($DomainDNSZonesServer2008CheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                                            
                Get-WmiObject -Credential $Credential -Namespace "root\MicrosoftDNS" -Class MicrosoftDNS_Zone `
                | Select-Object PSComputerName, Name `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                                            
                Get-WmiObject -Namespace "root\MicrosoftDNS" -Class MicrosoftDNS_Zone `
                | Select-Object PSComputerName, Name `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs
    
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($DomainDNSZonesServer2008CheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$DomainDNSZonesServer2008CheckBox.Text     = "$($DomainDNSZonesServer2008CheckBox.Name)"
$DomainDNSZonesServer2008CheckBox.TabIndex = 2
$DomainDNSZonesServer2008CheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$DomainDNSZonesServer2008CheckBox.Location  = New-Object System.Drawing.Point($ActiveDirectoryRightPosition,$ActiveDirectoryDownPosition) 
$DomainDNSZonesServer2008CheckBox.Size      = New-Object System.Drawing.Size($ActiveDirectoryBoxWidth,$ActiveDirectoryBoxHeight) 
$Section1ActiveDirectoryTab.Controls.Add($DomainDNSZonesServer2008CheckBox)




# ============================================================================================================================================================
# Domain - DNS Statistics (Server 2008)
# ============================================================================================================================================================

# Shift the fields
$ActiveDirectoryDownPosition += $ActiveDirectoryDownPositionShift


$DomainDNSStatisticsServer2008CheckBox = New-Object System.Windows.Forms.CheckBox
$DomainDNSStatisticsServer2008CheckBox.Name = "DNS Statistics (Server 2008)"

function DomainDNSStatisticsServer2008Command {
    $Message1            = "$($DomainDNSStatisticsServer2008CheckBox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "DNS Statistics (Server 2008)"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

    # If the file already exists in the directory (happens if you rerun the scan without updating the folder name/timestamp) it will delete it.
    Remove-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Force -ErrorAction SilentlyContinue

    foreach ($TargetComputer in $ComputerList) {
        $Message1            = "Collecting Data:  $($DomainDNSStatisticsServer2008CheckBox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                                            
                Get-WmiObject -Credential $Credential -Namespace root\MicrosoftDNS -Class MicrosoftDNS_Statistic `
                | Select-Object PSComputerName, Name, Value `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                                            
                Get-WmiObject -Namespace root\MicrosoftDNS -Class MicrosoftDNS_Statistic `
                | Select-Object PSComputerName, Name, Value `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime)
        }   
    }
    MonitorJobs
    
    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($DomainDNSStatisticsServer2008CheckBox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}

$DomainDNSStatisticsServer2008CheckBox.Text     = "$($DomainDNSStatisticsServer2008CheckBox.Name)"
$DomainDNSStatisticsServer2008CheckBox.TabIndex = 2
$DomainDNSStatisticsServer2008CheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$DomainDNSStatisticsServer2008CheckBox.Location  = New-Object System.Drawing.Point($ActiveDirectoryRightPosition,$ActiveDirectoryDownPosition) 
$DomainDNSStatisticsServer2008CheckBox.Size      = New-Object System.Drawing.Size($ActiveDirectoryBoxWidth,$ActiveDirectoryBoxHeight) 
$Section1ActiveDirectoryTab.Controls.Add($DomainDNSStatisticsServer2008CheckBox)



##############################################################################################################################################################
##############################################################################################################################################################
##
## Hunt The Bad Stuff
##
##############################################################################################################################################################
##############################################################################################################################################################


# Varables
$HuntTheBadStuffRightPosition     = 3
$HuntTheBadStuffDownPosition      = -10
$HuntTheBadStuffDownPositionShift = 25
$HuntTheBadStuffLableWidth        = 450
$HuntTheBadStuffLableHeight       = 22
$HuntTheBadStuffButtonWidth       = 110
$HuntTheBadStuffButtonHeight      = 22


$Section1HuntTheBadStuffTab          = New-Object System.Windows.Forms.TabPage
$Section1HuntTheBadStuffTab.Location = $System_Drawing_Point
$Section1HuntTheBadStuffTab.Text     = "File Searching"
$Section1HuntTheBadStuffTab.Location = New-Object System.Drawing.Size($HuntTheBadStuffRightPosition,$HuntTheBadStuffDownPosition) 
$Section1HuntTheBadStuffTab.Size     = New-Object System.Drawing.Size($HuntTheBadStuffLableWidth,$HuntTheBadStuffLableHeight) 
$Section1HuntTheBadStuffTab.TabIndex = 0
$Section1HuntTheBadStuffTab.UseVisualStyleBackColor = $True
$Section1CollectionsTabControl.Controls.Add($Section1HuntTheBadStuffTab)



# Shift the fields
$HuntTheBadStuffDownPosition += $HuntTheBadStuffDownPositionShift


# ============================================================================================================================================================
# Hunt The Bad Stuff - Directory Listing
# ============================================================================================================================================================

#---------------------------------------------------------
# Hunt The Bad Stuff - Directory Listing CheckBox Command
#---------------------------------------------------------

$HuntTheBadStuffDirectoryListingCheckbox = New-Object System.Windows.Forms.CheckBox
$HuntTheBadStuffDirectoryListingCheckbox.Name = "Directory Listing"

function HuntTheBadStuffDirectoryListingCommand {
    $Message1            = "$($HuntTheBadStuffDirectoryListingCheckbox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "$($HuntTheBadStuffDirectoryListingCheckbox.Name)"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''
    $Message1            = "Collecting Data:  $($HuntTheBadStuffDirectoryListingCheckbox.Name) from $TargetComputer"

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" -Force | Out-Null

    foreach ($TargetComputer in $ComputerList) {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Insert(0,$Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        $ListDirectory = $HuntTheBadStuffDirectoryListingTextbox.Text

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$DirectoriesToSearch,$FilesToSearch,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$DirectoriesToSearch,$FilesToSearch,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$ListDirectory)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                
   
                $DirectoryListing = Invoke-Command -ComputerName $TargetComputer -ScriptBlock {
                    param($ListDirectory)
                    Get-ChildItem -Force $ListDirectory -ErrorAction SilentlyContinue                    
                } -ArgumentList @($ListDirectory)
                        

                # Add the PSComputerName Property and Host name; then save the file
                $DirectoryListing | Add-Member -MemberType NoteProperty -Name PSComputerName -Value $TargetComputer
                $DirectoryListing | Select-Object -Property PSComputerName, FullName, Name, Extension, Attributes, CreationTime, LastWriteTime, LastAccessTime `
                | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation      

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$ListDirectory)
        }   
    }
    MonitorJobs

    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($HuntTheBadStuffDirectoryListingCheckbox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
    Remove-DuplicateCsvHeaders
}

$HuntTheBadStuffDirectoryListingCheckbox.Text     = "$($HuntTheBadStuffDirectoryListingCheckbox.Name)"
$HuntTheBadStuffDirectoryListingCheckbox.TabIndex = 2
$HuntTheBadStuffDirectoryListingCheckbox.DataBindings.DefaultDataSourceUpdateMode = 0
$HuntTheBadStuffDirectoryListingCheckbox.Location = New-Object System.Drawing.Size(($HuntTheBadStuffRightPosition),($HuntTheBadStuffDownPosition)) 
$HuntTheBadStuffDirectoryListingCheckbox.Size     = New-Object System.Drawing.Size($HuntTheBadStuffLableWidth,$HuntTheBadStuffLableHeight) 
$Section1HuntTheBadStuffTab.Controls.Add($HuntTheBadStuffDirectoryListingCheckbox)


# Shift the fields
$HuntTheBadStuffDownPosition += $HuntTheBadStuffDownPositionShift


#----------------------------------------------
# Hunt The Bad Stuff - Directory Listing Label
#----------------------------------------------
$HuntTheBadStuffDirectoryListingLabel           = New-Object System.Windows.Forms.Label
$HuntTheBadStuffDirectoryListingLabel.Location  = New-Object System.Drawing.Point($HuntTheBadStuffRightPosition,$HuntTheBadStuffDownPosition) 
$HuntTheBadStuffDirectoryListingLabel.Size      = New-Object System.Drawing.Size($HuntTheBadStuffLableWidth,$HuntTheBadStuffLableHeight) 
$HuntTheBadStuffDirectoryListingLabel.Text      = "Collection time is dependant on the directory's contents."
#$HuntTheBadStuffDirectoryListingLabel.Font      = New-Object System.Drawing.Font("$Font",12,1,3,1)
$HuntTheBadStuffDirectoryListingLabel.ForeColor = "Blue"
$Section1HuntTheBadStuffTab.Controls.Add($HuntTheBadStuffDirectoryListingLabel)


# Shift the fields
$HuntTheBadStuffDownPosition += $HuntTheBadStuffDownPositionShift


#----------------------------------------------------
# Hunt The Bad Stuff - Directory Listing Directory Textbox
#----------------------------------------------------
$HuntTheBadStuffDirectoryListingTextbox               = New-Object System.Windows.Forms.TextBox
$HuntTheBadStuffDirectoryListingTextbox.Location      = New-Object System.Drawing.Size($HuntTheBadStuffRightPosition,($HuntTheBadStuffDownPosition)) 
$HuntTheBadStuffDirectoryListingTextbox.Size          = New-Object System.Drawing.Size(430,22)
$HuntTheBadStuffDirectoryListingTextbox.MultiLine     = $False
#$HuntTheBadStuffDirectoryListingTextbox.ScrollBars    = "Vertical"
$HuntTheBadStuffDirectoryListingTextbox.WordWrap      = True
$HuntTheBadStuffDirectoryListingTextbox.AcceptsTab    = false # Allows you to enter in tabs into the textbox
$HuntTheBadStuffDirectoryListingTextbox.AcceptsReturn = false # Allows you to enter in tabs into the textbox
$HuntTheBadStuffDirectoryListingTextbox.DataBindings.DefaultDataSourceUpdateMode = 0
$HuntTheBadStuffDirectoryListingTextbox.Text          = "C:\Windows\System32"
#$HuntTheBadStuffDirectoryListingTextbox.Add_KeyDown({          })
$Section1HuntTheBadStuffTab.Controls.Add($HuntTheBadStuffDirectoryListingTextbox)


# Shift the fields
$HuntTheBadStuffDownPosition += $HuntTheBadStuffDownPositionShift + $HuntTheBadStuffDirectoryListingTextbox.Size.Height




# ============================================================================================================================================================
# Hunt The Bad Stuff - File Search
# ============================================================================================================================================================


#---------------------------------------------------
# Hunt The Bad Stuff - File Search Command CheckBox
#---------------------------------------------------

$HuntTheBadStuffFileSearchCheckbox = New-Object System.Windows.Forms.CheckBox
$HuntTheBadStuffFileSearchCheckbox.Name = "File Search"

function HuntTheBadStuffFileSearchCommand {
    $Message1            = "$($HuntTheBadStuffFileSearchCheckbox.Name)"
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1")
    $CollectionName      = "$($HuntTheBadStuffFileSearchCheckbox.Name)"
    $CollectionDirectory = $CollectionName
    $CollectionShortName = $CollectionName -replace ' ',''
    $Message1            = "Collecting Data:  $($HuntTheBadStuffFileSearchCheckbox.Name) from $TargetComputer"

    New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" -Force | Out-Null

    foreach ($TargetComputer in $ComputerList) {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Insert(0,$Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile


        $DirectoriesToSearch = $HuntTheBadStuffFileSearchDirectoryTextbox.Text -split "`r`n"
        $FilesToSearch       = $HuntTheBadStuffFileSearchFileTextbox.Text -split "`r`n"
        $MaximumDepth        = $HuntTheBadStuffFileSearchMaxDepthTextbox.text

        if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
            if (!$Credential) {              
                $script:Credential = Get-Credential
            }
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$DirectoriesToSearch,$FilesToSearch,$MaximumDepth,$Credential)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'AboveNormal'

                $FilesFoundList = @()
                                                            
                foreach ($DirectoryPath in $DirectoriesToSearch) {
                    foreach ($Filename in $FilesToSearch) {
                        $FilesFound = Invoke-Command -Credential $Credential -ComputerName $TargetComputer -ScriptBlock {
                            param($DirectoryPath,$Filename,$MaximumDepth)
   
                            function Get-FileHash{
                                param ([string] $Path ) 
                                $HashAlgorithm = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
                                $Hash=[System.BitConverter]::ToString($hashAlgorithm.ComputeHash([System.IO.File]::ReadAllBytes($Path)))
                                $Properties=@{
                                "Algorithm" = "MD5"
                                "Path" = $Path
                                "Hash" = $Hash.Replace("-", "")
                                }
                                $Ret=New-Object –TypeName PSObject –Prop $Properties
                                return $Ret
                            }

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
                                    $RecursiveListing | Add-Member -MemberType NoteProperty -Name Hash -Value $_.Hash -Force
                                    $RecursiveListing | Add-Member -MemberType NoteProperty -Name Algorithm -Value $_.Algorithm -Force
                                    $RecursiveListing | Add-Member -MemberType NoteProperty -Name Attributes -Value $_.Attributes -Force
                                    $RecursiveListing | Add-Member -MemberType NoteProperty -Name CreationTime -Value $_.CreationTime -Force
                                    $RecursiveListing | Add-Member -MemberType NoteProperty -Name LastWriteTime -Value $_.LastWriteTime -Force
                                    $RecursiveListing | Add-Member -MemberType NoteProperty -Name LastAccessTime -Value $_.LastAccessTime -Force
                                    $RecursiveListing | Add-Member -MemberType NoteProperty -Name FullName -Value $_.FullName -Force
                                    $RecursiveListing | Add-Member -MemberType NoteProperty -Name PSIsContainer -Value $_.PSIsContainer -Force
                                    $RecursiveListing
                                    If ($_.PsIsContainer) {
                                        If ($CurrentDepth -le $Depth) {                
                                            # Callback to this function
                                            Get-ChildItemRecurse -Path $_.FullName -Filter $Filter -Depth $MaxDepth -CurrentDepth $CurrentDepth
                                        }
                                    }
                                }
                            }
                        $MaxDepth = $MaximumDepth
                        $Path = $DirectoryPath
                        Get-ChildItemRecurse -Path $Path -Depth $MaxDepth `
                        | Where-Object { ($_.PSIsContainer -eq $false) -and ($_.Name -match "$Filename") }

                        } -ArgumentList @($DirectoryPath,$Filename,$MaximumDepth)
                        
                        # Hash the file found
                        $FileFoundHash = Get-FileHash ($FilesFound).FullName

                        # Add the PSComputerName Property and Host name; then save the file
                        $FilesFound | Add-Member -MemberType NoteProperty -Name PSComputerName -Value $TargetComputer
                        $FilesFound | Add-Member -MemberType NoteProperty -Name Hash -Value $FileFoundHash.Hash
                        $FilesFound | Add-Member -MemberType NoteProperty -Name Algorithm -Value $FileFoundHash.Algorithm                        
                        $FilesFoundList += $FilesFound | Select-Object -Property PSComputerName, Directory, Name, BaseName, Extension, Hash, Algorithm, Attributes, CreationTime, LastWriteTime, LastAccessTime, FullName
                    }
                }
                $FilesFoundList | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation
                $FilesFoundListAddHeader = Import-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Header "PSComputerName","Directory","Name","BaseName","Extension","Hash","Algorithm","Attributes","CreationTime","LastWriteTime","LastAccessTime","FullName"
                Remove-Item -Path "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"
                $FilesFoundListAddHeader | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$DirectoriesToSearch,$FilesToSearch,$MaximumDepth,$Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$DirectoriesToSearch,$FilesToSearch,$MaximumDepth)
                # Available priority values: Lowest, BelowNormal, Normal, AboveNormal, Highest
                [System.Threading.Thread]::CurrentThread.Priority = 'RealTime'
                ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'RealTime'
                #polo

                $FilesFoundList = @()
                                                            
                foreach ($DirectoryPath in $DirectoriesToSearch) {
                    foreach ($Filename in $FilesToSearch) {


                        #Get-WmiObject -class Win32_Directory -ComputerName $TargetComputer


                        $FilesFound = Invoke-Command -ComputerName $TargetComputer -ScriptBlock {
                            param($DirectoryPath,$Filename,$MaximumDepth)

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
                                    $RecursiveListing
                                    If ($_.PsIsContainer) {
                                        If ($CurrentDepth -le $Depth) {                
                                            # Callback to this function
                                            Get-ChildItemRecurse -Path $_.FullName -Filter $Filter -Depth $MaxDepth -CurrentDepth $CurrentDepth
                                        }
                                    }
                                }
                            }
                        $MaxDepth = $MaximumDepth
                        $Path = $DirectoryPath
                        
                        Get-ChildItemRecurse -Path $Path -Depth $MaxDepth `
                        | Where-Object { ($_.PSIsContainer -eq $false) -and ($_.Name -match "$Filename") }

                        } -ArgumentList @($DirectoryPath,$Filename,$MaximumDepth)
                        
                        $FilesFoundList += $FilesFound | Select-Object -Property PSComputerName, Directory, Name, BaseName, Extension, Attributes, CreationTime, LastWriteTime, LastAccessTime, FullName
                    }
                }
                $FilesFoundList | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation
                $FilesFoundListAddHeader = Import-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -Header "PSComputerName","Directory","Name","BaseName","Extension","Attributes","CreationTime","LastWriteTime","LastAccessTime","FullName"
                Remove-Item -Path "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"
                $FilesFoundListAddHeader | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation

            } -ArgumentList @($PoShHome,$PoShLocation,$CollectedResultsUncompiled,$CollectionName,$CollectionShortName,$CollectionDirectory,$TargetComputer,$SleepTime,$DirectoriesToSearch,$FilesToSearch,$MaximumDepth)
        } 
    }
    MonitorJobs

    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($HuntTheBadStuffFileSearchCheckbox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    Compile-CsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
    Remove-DuplicateCsvHeaders
}

$HuntTheBadStuffFileSearchCheckbox.Text     = "$($HuntTheBadStuffFileSearchCheckbox.Name)"
$HuntTheBadStuffFileSearchCheckbox.TabIndex = 2
$HuntTheBadStuffFileSearchCheckbox.DataBindings.DefaultDataSourceUpdateMode = 0
$HuntTheBadStuffFileSearchCheckbox.Location = New-Object System.Drawing.Size(($HuntTheBadStuffRightPosition),($HuntTheBadStuffDownPosition)) 
$HuntTheBadStuffFileSearchCheckbox.Size     = New-Object System.Drawing.Size((230),$HuntTheBadStuffLableHeight) 
$Section1HuntTheBadStuffTab.Controls.Add($HuntTheBadStuffFileSearchCheckbox)


#--------------------------------------------------
# Hunt The Bad Stuff - File Search Max Depth Label
#--------------------------------------------------
$HuntTheBadStuffFileSearchMaxDepthLabel            = New-Object System.Windows.Forms.Label
$HuntTheBadStuffFileSearchMaxDepthLabel.Location   = New-Object System.Drawing.Point(($HuntTheBadStuffFileSearchCheckbox.Size.Width + 52),($HuntTheBadStuffDownPosition + 3)) 
$HuntTheBadStuffFileSearchMaxDepthLabel.Size       = New-Object System.Drawing.Size(100,$HuntTheBadStuffLableHeight) 
$HuntTheBadStuffFileSearchMaxDepthLabel.Text       = "Recursive Depth"
#$HuntTheBadStuffFileSearchMaxDepthLabel.Font      = New-Object System.Drawing.Font("$Font",12,1,3,1)
#$HuntTheBadStuffFileSearchMaxDepthLabel.ForeColor  = "Blue"
$Section1HuntTheBadStuffTab.Controls.Add($HuntTheBadStuffFileSearchMaxDepthLabel)


#----------------------------------------------------
# Hunt The Bad Stuff - File Search Max Depth Textbox
#----------------------------------------------------
$HuntTheBadStuffFileSearchMaxDepthTextbox                = New-Object System.Windows.Forms.TextBox
$HuntTheBadStuffFileSearchMaxDepthTextbox.Location       = New-Object System.Drawing.Size(($HuntTheBadStuffFileSearchMaxDepthLabel.Location.X + $HuntTheBadStuffFileSearchMaxDepthLabel.Size.Width),($HuntTheBadStuffDownPosition)) 
$HuntTheBadStuffFileSearchMaxDepthTextbox.Size           = New-Object System.Drawing.Size(50,20)
$HuntTheBadStuffFileSearchMaxDepthTextbox.MultiLine      = $false
#$HuntTheBadStuffFileSearchMaxDepthTextbox.ScrollBars    = "Vertical"
$HuntTheBadStuffFileSearchMaxDepthTextbox.WordWrap       = false
#$HuntTheBadStuffFileSearchMaxDepthTextbox.AcceptsTab    = false
#$HuntTheBadStuffFileSearchMaxDepthTextbox.AcceptsReturn = false
$HuntTheBadStuffFileSearchMaxDepthTextbox.Font           = New-Object System.Drawing.Font("$Font",9,0,3,1)
$HuntTheBadStuffFileSearchMaxDepthTextbox.DataBindings.DefaultDataSourceUpdateMode = 0
$HuntTheBadStuffFileSearchMaxDepthTextbox.Text           = 0
#$HuntTheBadStuffFileSearchMaxDepthTextbox.Add_KeyDown({          })
$Section1HuntTheBadStuffTab.Controls.Add($HuntTheBadStuffFileSearchMaxDepthTextbox)



# Shift the fields
$HuntTheBadStuffDownPosition += $HuntTheBadStuffDownPositionShift


#----------------------------------------
# Hunt The Bad Stuff - File Search Label
#----------------------------------------
$HuntTheBadStuffFileSearchLabel           = New-Object System.Windows.Forms.Label
$HuntTheBadStuffFileSearchLabel.Location  = New-Object System.Drawing.Point($HuntTheBadStuffRightPosition,$HuntTheBadStuffDownPosition) 
$HuntTheBadStuffFileSearchLabel.Size      = New-Object System.Drawing.Size($HuntTheBadStuffLableWidth,$HuntTheBadStuffLableHeight) 
$HuntTheBadStuffFileSearchLabel.Text      = "Collection time depends on the number of files and directories, plus recursive depth."
#$HuntTheBadStuffFileSearchLabel.Font      = New-Object System.Drawing.Font("$Font",12,1,3,1)
$HuntTheBadStuffFileSearchLabel.ForeColor = "Blue"
$Section1HuntTheBadStuffTab.Controls.Add($HuntTheBadStuffFileSearchLabel)


# Shift the fields
$HuntTheBadStuffDownPosition += $HuntTheBadStuffDownPositionShift - 3


#------------------------------------------------
# Hunt The Bad Stuff - File Search Files Textbox
#------------------------------------------------
$HuntTheBadStuffFileSearchFileTextbox               = New-Object System.Windows.Forms.TextBox
$HuntTheBadStuffFileSearchFileTextbox.Location      = New-Object System.Drawing.Size($HuntTheBadStuffRightPosition,($HuntTheBadStuffDownPosition)) 
$HuntTheBadStuffFileSearchFileTextbox.Size          = New-Object System.Drawing.Size(430,(80))
$HuntTheBadStuffFileSearchFileTextbox.MultiLine     = $True
$HuntTheBadStuffFileSearchFileTextbox.ScrollBars    = "Vertical"
$HuntTheBadStuffFileSearchFileTextbox.WordWrap      = True
$HuntTheBadStuffFileSearchFileTextbox.AcceptsTab    = false    # Allows you to enter in tabs into the textbox
$HuntTheBadStuffFileSearchFileTextbox.AcceptsReturn = false # Allows you to enter in tabs into the textbox
$HuntTheBadStuffFileSearchFileTextbox.Font          = New-Object System.Drawing.Font("$Font",9,0,3,1)
$HuntTheBadStuffFileSearchFileTextbox.DataBindings.DefaultDataSourceUpdateMode = 0
$HuntTheBadStuffFileSearchFileTextbox.Text          = "Enter FileNames; One Per Line"
#$HuntTheBadStuffFileSearchFileTextbox.Add_KeyDown({          })
$Section1HuntTheBadStuffTab.Controls.Add($HuntTheBadStuffFileSearchFileTextbox)


# Shift the fields
$HuntTheBadStuffDownPosition += $HuntTheBadStuffFileSearchFileTextbox.Size.Height + 5


#----------------------------------------------------
# Hunt The Bad Stuff - File Search Directory Textbox
#----------------------------------------------------
$HuntTheBadStuffFileSearchDirectoryTextbox               = New-Object System.Windows.Forms.TextBox
$HuntTheBadStuffFileSearchDirectoryTextbox.Location      = New-Object System.Drawing.Size($HuntTheBadStuffRightPosition,($HuntTheBadStuffDownPosition)) 
$HuntTheBadStuffFileSearchDirectoryTextbox.Size          = New-Object System.Drawing.Size(430,(80))
$HuntTheBadStuffFileSearchDirectoryTextbox.MultiLine     = $True
$HuntTheBadStuffFileSearchDirectoryTextbox.ScrollBars    = "Vertical"
$HuntTheBadStuffFileSearchDirectoryTextbox.WordWrap      = True
$HuntTheBadStuffFileSearchDirectoryTextbox.AcceptsTab    = false    # Allows you to enter in tabs into the textbox
$HuntTheBadStuffFileSearchDirectoryTextbox.AcceptsReturn = false # Allows you to enter in tabs into the textbox
$HuntTheBadStuffFileSearchDirectoryTextbox.DataBindings.DefaultDataSourceUpdateMode = 0
$HuntTheBadStuffFileSearchDirectoryTextbox.Text          = "Enter Directories; One Per Line"
#$HuntTheBadStuffFileSearchDirectoryTextbox.Add_KeyDown({          })
$Section1HuntTheBadStuffTab.Controls.Add($HuntTheBadStuffFileSearchDirectoryTextbox)

    

##############################################################################################################################################################
##############################################################################################################################################################
##
## Section 1 Sysinternals Tab
##
##############################################################################################################################################################
##############################################################################################################################################################


# Varables
$SysinternalsRightPosition     = 3
$SysinternalsDownPosition      = -10
$SysinternalsDownPositionShift = 22
$SysinternalsLableWidth        = 450
$SysinternalsLableHeight       = 25
$SysinternalsButtonWidth       = 110
$SysinternalsButtonHeight      = 22


$Section1SysinternalsTab          = New-Object System.Windows.Forms.TabPage
$Section1SysinternalsTab.Location = $System_Drawing_Point
$Section1SysinternalsTab.Text     = "Sysinternals"
$Section1SysinternalsTab.Location = New-Object System.Drawing.Size($SysinternalsRightPosition,$SysinternalsDownPosition) 
$Section1SysinternalsTab.Size     = New-Object System.Drawing.Size($SysinternalsLableWidth,$SysinternalsLableHeight) 
$Section1SysinternalsTab.TabIndex = 0
$Section1SysinternalsTab.UseVisualStyleBackColor = $True

# Test if the SysinternalsSuite Directory is there; if it's there load the tab
if (Test-Path $PoShHome\SysinternalsSuite) {
    $Section1CollectionsTabControl.Controls.Add($Section1SysinternalsTab)
}


# Shift the fields
$SysinternalsDownPosition += $SysinternalsDownPositionShift


# Sysinternals Tab Label
$SysinternalsTabLabel           = New-Object System.Windows.Forms.Label
$SysinternalsTabLabel.Location  = New-Object System.Drawing.Point($SysinternalsRightPosition,$SysinternalsDownPosition) 
$SysinternalsTabLabel.Size      = New-Object System.Drawing.Size($SysinternalsLableWidth,$SysinternalsLableHeight) 
$SysinternalsTabLabel.Text      = "Options here drop/remove files to the target host's temp dir."
$SysinternalsTabLabel.Font      = New-Object System.Drawing.Font("$Font",10,1,3,1)
$SysinternalsTabLabel.ForeColor = "Red"
$Section1SysinternalsTab.Controls.Add($SysinternalsTabLabel)


# Shift the fields
$SysinternalsDownPosition += $SysinternalsDownPositionShift
# Shift the fields
$SysinternalsDownPosition += $SysinternalsDownPositionShift




# ============================================================================================================================================================
# Sysinternals Autoruns
# ============================================================================================================================================================



#-----------------------------
# Sysinternals Autoruns Label
#-----------------------------
$SysinternalsAutorunsLabel           = New-Object System.Windows.Forms.Label
$SysinternalsAutorunsLabel.Location  = New-Object System.Drawing.Point($SysinternalsRightPosition,$SysinternalsDownPosition) 
$SysinternalsAutorunsLabel.Size      = New-Object System.Drawing.Size(($SysinternalsLableWidth),$SysinternalsLableHeight) 
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
$SysinternalsAutorunsButton.add_click({
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    $SysinternalsAutorunsOpenFileDialog.Title = "Open Autoruns File"
    $SysinternalsAutorunsOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $SysinternalsAutorunsOpenFileDialog.filter = "Autoruns File (*.arn)| *.arn|All files (*.*)|*.*"
    $SysinternalsAutorunsOpenFileDialog.ShowHelp = $true
    if (Test-Path -Path $PoShLocation) {
        $SysinternalsAutorunsOpenFileDialog.InitialDirectory = "$PoShLocation\$CollectedResultsUncompiled\$($SysinternalsAutorunsCheckbox.Name)"
        $SysinternalsAutorunsOpenFileDialog.ShowDialog() | Out-Null
        $ProcMonFileLocation = "$PoShLocation"
    }
    else {
        $SysinternalsAutorunsOpenFileDialog.InitialDirectory = "$PoShHome\$CollectedData"   
        $SysinternalsAutorunsOpenFileDialog.ShowDialog() | Out-Null
        $ProcMonFileLocation = "$PoShHome\$CollectedData"
    }
    if ($($SysinternalsAutorunsOpenFileDialog.filename)) {
        Start-Process "$PoShHome\SysinternalsSuite\Autoruns.exe" -ArgumentList "`"$($SysinternalsAutorunsOpenFileDialog.filename)`""
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
        $Message1            = "Collecting Data:  $($SysinternalsAutorunsCheckbox.Name)"
        $MainListBox.Items.Insert(0,"")
        $MainListBox.Items.Insert(0,$Message1)
    foreach ($TargetComputer in $ComputerList) {
        $CollectionName      = "$($SysinternalsAutorunsCheckbox.Name)"
        $CollectionDirectory = $CollectionName
        $CollectionShortName = $CollectionName -replace ' ',''
        $Message1            = "Collecting Data:  $($SysinternalsAutorunsCheckbox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Insert(0,$Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" -Force | Out-Null                      
        Function SysinternalsAutorunsData {
            $SysinternalsExecutable     = 'Autoruns.exe'
            $ToolName                   = 'Autoruns'
            $AdminShare                 = 'c$'
            $LocalDrive                 = 'c:'
            $PSExecPath                 = "$PoShHome\SysinternalsSuite\PSExec.exe"
            $SysinternalsExecutablePath = "$PoShHome\SysinternalsSuite\Autoruns.exe"
            $TargetFolder               = "Windows\Temp"
            
            $MainListBox.Items.Insert(2,"Copying $ToolName to $TargetComputer temporarily for use by PSExec.")
            try { Copy-Item $SysinternalsExecutablePath "\\$TargetComputer\$AdminShare\$TargetFolder" -Force -Verbose -ErrorAction Stop } catch { $MainListBox.Items.Insert(2,$_.Exception); break }

            # Process monitor must be launched as a separate process otherwise the sleep and terminate commands below would never execute and fill the disk
            $MainListBox.Items.Insert(2,"Starting process monitor on $TargetComputer")
            Start-Process -WindowStyle Hidden -FilePath $PSExecPath -ArgumentList "/accepteula -s \\$TargetComputer $LocalDrive\$TargetFolder\$SysinternalsExecutable /AcceptEula -a $LocalDrive\$TargetFolder\Autoruns-$TargetComputer.arn" -PassThru | Out-Null   

            #$MainListBox.Items.Insert(2,"Terminating $ToolName process on $TargetComputer")
            #Start-Process -WindowStyle Hidden -FilePath $PSExecPath -ArgumentList "/accepteula -s \\$TargetComputer $LocalDrive\$TargetFolder\$procmon /accepteula /terminate /quiet" -PassThru | Out-Null
            Start-Sleep -Seconds 30

            # Checks to see if the process is still running
            while ($true) {
                if ($(Get-WmiObject -Class Win32_Process -ComputerName "$TargetComputer" | Where-Object {$_.ProcessName -match "Autoruns"})) {  
                    #$RemoteFileSize = "$(Get-ChildItem -Path `"C:\$TempPath`" | Where-Object {$_.Name -match `"$MemoryCaptureFile`"} | Select-Object -Property Length)" #-replace "@{Length=","" -replace "}",""
                    
                    $Message = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) Checking Autoruns Status on $TargetComputer"
                    #$MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
                    $MainListBox.Items.Insert(0,$Message)
                    Start-Sleep -Seconds 30
                }
                else {
                    Start-Sleep -Seconds 5

                    $MainListBox.Items.Insert(2,"Copy $ToolName data to local machine for analysis")
                    try { Copy-Item "\\$TargetComputer\$AdminShare\$TargetFolder\Autoruns-$TargetComputer.arn" "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" -Force -Verbose -ErrorAction Stop }
                    catch { $_ ; }

                    $MainListBox.Items.Insert(2,"Remove temporary $ToolName executable and data file from target system")
                 
                    Remove-Item "\\$TargetComputer\$AdminShare\$TargetFolder\Autoruns-$TargetComputer.arn" -Verbose -Force
                    Remove-Item "\\$TargetComputer\$AdminShare\$TargetFolder\$SysinternalsExecutable" -Verbose -Force

                    $MainListBox.Items.Insert(2,"Launching $ToolName and loading collected log data")
                    if(Test-Path("$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$TargetComputer.arn")) { & $procmonPath /openlog $PoShHome\Sysinternals\$TargetComputer.arn }

                    $FileSize = [math]::round(((Get-Item "$PoShHome\$TargetComputer.arn").Length/1mb),2)    
                    $MainListBox.Items.Insert(2,"$PoShLocation\$TargetComputer.arn is $FileSize MB. Remember to delete it when finished.")

                    break
                }
            }
        }

        SysinternalsAutorunsData -TargetComputer $TargetComputer
    }

    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed: $($SysinternalsAutorunsCheckbox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)
}

$SysinternalsAutorunsCheckbox.Text     = "$($SysinternalsAutorunsCheckbox.Name)"
$SysinternalsAutorunsCheckbox.TabIndex = 2
$SysinternalsAutorunsCheckbox.DataBindings.DefaultDataSourceUpdateMode = 0
$SysinternalsAutorunsCheckbox.Location = New-Object System.Drawing.Size(($SysinternalsRightPosition + $SysinternalsButtonWidth + 5),($SysinternalsDownPosition + 5)) 
$SysinternalsAutorunsCheckbox.Size     = New-Object System.Drawing.Size(($SysinternalsLableWidth - 130),$SysinternalsLableHeight) 
$Section1SysinternalsTab.Controls.Add($SysinternalsAutorunsCheckbox)



# Shift the fields
$SysinternalsDownPosition += $SysinternalsDownPositionShift
# Shift the fields
$SysinternalsDownPosition += $SysinternalsDownPositionShift



# ============================================================================================================================================================
# Sysinternals Process Monitor
# ============================================================================================================================================================

#------------------------------
# Sysinternals - ProcMon Label
#------------------------------
$SysinternalsProcessMonitorLabel           = New-Object System.Windows.Forms.Label
$SysinternalsProcessMonitorLabel.Location  = New-Object System.Drawing.Point($SysinternalsRightPosition,$SysinternalsDownPosition) 
$SysinternalsProcessMonitorLabel.Size      = New-Object System.Drawing.Size($SysinternalsLableWidth,$SysinternalsLableHeight) 
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
$SysinternalsProcmonButton.add_click({
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    $SysinternalsProcmonOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $SysinternalsProcmonOpenFileDialog.Title = "Open ProcMon File"
    $SysinternalsProcmonOpenFileDialog.filter = "ProcMon Log File (*.pml)| *.pml|All files (*.*)|*.*"
    $SysinternalsProcmonOpenFileDialog.ShowHelp = $true
    if (Test-Path -Path $PoShLocation) {
        $SysinternalsProcmonOpenFileDialog.InitialDirectory = "$PoShLocation\$CollectedResultsUncompiled\$($SysinternalsProcessMonitorCheckbox.Name)"
        $SysinternalsProcmonOpenFileDialog.ShowDialog() | Out-Null
    }
    else {
        $SysinternalsProcmonOpenFileDialog.InitialDirectory = "$PoShHome\$CollectedData"   
        $SysinternalsProcmonOpenFileDialog.ShowDialog() | Out-Null
    }
    if ($($SysinternalsProcmonOpenFileDialog.filename)) {
        Start-Process "$PoShHome\SysinternalsSuite\Procmon.exe" -ArgumentList "`"$($SysinternalsProcmonOpenFileDialog.filename)`""
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
        $Message1            = "Collecting Data:  $($SysinternalsProcessMonitorCheckbox.Name)"
        $MainListBox.Items.Insert(0,"")
        $MainListBox.Items.Insert(0,$Message1)
    foreach ($TargetComputer in $ComputerList) {
        $CollectionName      = "$($SysinternalsProcessMonitorCheckbox.Name)"
        $CollectionDirectory = $CollectionName
        $CollectionShortName = $CollectionName -replace ' ',''
        $Message1            = "Collecting Data:  $($SysinternalsProcessMonitorCheckbox.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Insert(0,$Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" -Force | Out-Null
                
        # Collect Remote host Disk Space       
        Function Get-DiskSpace([string] $TargetComputer) {
                try { $HD = Get-WmiObject Win32_LogicalDisk -ComputerName $TargetComputer -Filter "DeviceID='C:'" -ErrorAction Stop } 
                catch { $MainListBox.Items.Insert(2,"Unable to connect to $TargetComputer. $_"); continue}
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
            $PSExecPath                  = "$PoShHome\SysinternalsSuite\PSExec.exe"
            $SysinternalsExecutablePath  = "$PoShHome\SysinternalsSuite\Procmon.exe"
            $TargetFolder                = "Windows\Temp"            
           

            # Process monitor generates enormous amounts of data.  
            # To try and offer some protections, the script won't run if the source or target have less than 500MB free
            $MainListBox.Items.Insert(2,"Verifying free diskspace on source and target.")
            if((Get-DiskSpace $TargetComputer) -lt 0.5) 
                { $MainListBox.Items.Insert(2,"$TargetComputer has less than 500MB free - aborting to avoid filling the disk."); break }

            if((Get-DiskSpace $Env:ComputerName) -lt 0.5) 
                { $MainListBox.Items.Insert(2,"Local computer has less than 500MB free - aborting to avoid filling the disk."); break }

            $MainListBox.Items.Insert(2,"Copying Procmon to the target system temporarily for use by PSExec.")
            try { Copy-Item $SysinternalsExecutablePath "\\$TargetComputer\$AdminShare\$TargetFolder" -Force -Verbose -ErrorAction Stop } catch { $MainListBox.Items.Insert(2,$_.Exception); break }

            # Process monitor must be launched as a separate process otherwise the sleep and terminate commands below would never execute and fill the disk
            $MainListBox.Items.Insert(2,"Starting process monitor on $TargetComputer")
            #$Command = Start-Process -WindowStyle Hidden -FilePath $PSExecPath -ArgumentList "/accepteula $Credentials -s \\$TargetComputer $LocalDrive\$TargetFolder\$SysinternalsExecutable /AcceptEula /BackingFile $LocalDrive\$TargetFolder\$TargetComputer /RunTime 10 /Quiet" -PassThru | Out-Null
            $Command = Start-Process -WindowStyle Hidden -FilePath $PSExecPath -ArgumentList "/accepteula -s \\$TargetComputer $LocalDrive\$TargetFolder\$SysinternalsExecutable /AcceptEula /BackingFile `"$LocalDrive\$TargetFolder\ProcMon-$TargetComputer`" /RunTime $Duration /Quiet" -PassThru | Out-Null
            $Command
            $Message = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $TargetComputer $($SysinternalsProcessMonitorCheckbox.Name)"
            $Message | Add-Content -Path $LogFile
            $Message = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $TargetComputer $Command"
            $Message | Add-Content -Path $LogFile

            Start-Sleep -Seconds ($Duration + 5)

            while ($true) {
                if ($(Get-WmiObject -Class Win32_Process -ComputerName "$TargetComputer" | Where-Object {$_.ProcessName -match "Procmon"})) {  
                    #$RemoteFileSize = "$(Get-ChildItem -Path `"C:\$TempPath`" | Where-Object {$_.Name -match `"$MemoryCaptureFile`"} | Select-Object -Property Length)" #-replace "@{Length=","" -replace "}",""
                    
                    $Message = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) Checking ProcMon Status on $TargetComputer"
                    #$MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
                    $MainListBox.Items.Insert(0,$Message)
                    Start-Sleep -Seconds 30
                }
                else {
                    Start-Sleep -Seconds 5

                    $MainListBox.Items.Insert(2,"Copy $ToolName data to local machine for analysis")
                    try { Copy-Item "\\$TargetComputer\$AdminShare\$TargetFolder\ProcMon-$TargetComputer.pml" "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" -Force -Verbose -ErrorAction Stop }
                    catch { $_ ; }

                    $MainListBox.Items.Insert(2,"Remove temporary $ToolName executable and data file from target system")
                 
                    Remove-Item "\\$TargetComputer\$AdminShare\$TargetFolder\ProcMon-$TargetComputer.pml" -Verbose -Force
                    Remove-Item "\\$TargetComputer\$AdminShare\$TargetFolder\$SysinternalsExecutable" -Verbose -Force

                    $MainListBox.Items.Insert(2,"Launching $ToolName and loading collected log data")
                    if(Test-Path("$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$TargetComputer.pml")) { & $SysinternalsExecutablePath /openlog $PoShHome\Sysinternals\$TargetComputer.pml }

                    $FileSize = [math]::round(((Get-Item "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$TargetComputer.pml").Length/1mb),2)    
                    $MainListBox.Items.Insert(2,"$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$TargetComputer.pml is $FileSize MB. Remember to delete it when finished.")

                    break
                }
            }

        }

        SysinternalsProcessMonitorData -TargetComputer $TargetComputer -Duration $Script:SysinternalsProcessMonitorTime
    }

    $Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed: $($SysinternalsProcessMonitorCheckbox.Name)"
    $MainListBox.Items.RemoveAt(0) ; $MainListBox.Items.RemoveAt(0)
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)
}

$SysinternalsProcessMonitorCheckbox.Text     = "$($SysinternalsProcessMonitorCheckbox.Name)"
$SysinternalsProcessMonitorCheckbox.TabIndex = 2
$SysinternalsProcessMonitorCheckbox.DataBindings.DefaultDataSourceUpdateMode = 0
$SysinternalsProcessMonitorCheckbox.Location = New-Object System.Drawing.Size(($SysinternalsRightPosition + $SysinternalsButtonWidth + 5),($SysinternalsDownPosition + 5)) 
$SysinternalsProcessMonitorCheckbox.Size     = New-Object System.Drawing.Size(($SysinternalsLableWidth - 330),$SysinternalsLableHeight) 
$Section1SysinternalsTab.Controls.Add($SysinternalsProcessMonitorCheckbox)


#------------------------
# Procmon - Time TextBox
#------------------------
$SysinternalsProcessMonitorTimeTextBox          = New-Object System.Windows.Forms.TextBox
$SysinternalsProcessMonitorTimeTextBox.Location = New-Object System.Drawing.Size(($SysinternalsRightPosition + $SysinternalsButtonWidth + 150),($SysinternalsDownPosition + 6)) 
$SysinternalsProcessMonitorTimeTextBox.Size     = New-Object System.Drawing.Size((160),$SysinternalsLableHeight) 
$SysinternalsProcessMonitorTimeTextBox.TabIndex = 2
$SysinternalsProcessMonitorTimeTextBox.DataBindings.DefaultDataSourceUpdateMode = 0
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
##############################################################################################################################################################
##
## Section 1 Checklist Tab
##
##############################################################################################################################################################
##############################################################################################################################################################

$Section1ChecklistTab          = New-Object System.Windows.Forms.TabPage
$Section1ChecklistTab.Text     = "Checklist"
$Section1ChecklistTab.Name     = "Checklist Tab"
$Section1ChecklistTab.TabIndex = 0
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
$Section1ChecklistTabControl.TabIndex      = 4
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
    $Section1ChecklistSubTab.TabIndex          = 0
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
        $Checklist.DataBindings.DefaultDataSourceUpdateMode = 0
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
##############################################################################################################################################################
##
## Section 1 Processes Tab
##
##############################################################################################################################################################
##############################################################################################################################################################
$Section1ProcessesTab          = New-Object System.Windows.Forms.TabPage
$Section1ProcessesTab.Text     = "Processes"
$Section1ProcessesTab.Name     = "Processes Tab"
$Section1ProcessesTab.TabIndex = 0
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
$Section1ProcessesTabControl.TabIndex      = 4
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
    $Section1ProcessesSubTab.TabIndex          = 0
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
##############################################################################################################################################################
##
## Section 1 OpNotes Tab
##
##############################################################################################################################################################
##############################################################################################################################################################

# The OpNotes TabPage Window
$Section1OpNotesTab          = New-Object System.Windows.Forms.TabPage
$Section1OpNotesTab.Text     = "OpNotes"
$Section1OpNotesTab.Name     = "OpNotes Tab"
$Section1OpNotesTab.TabIndex = 0
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

function OpNotesSaveScript {
    # Select all fields to be saved
    for($i = 0; $i -lt $OpNotesListBox.Items.Count; $i++) {
        $OpNotesListBox.SetSelected($i, $true)
    }

    # Saves all OpNotes to file
    Set-Content -Path $OpNotesFile          -Value ($OpNotesListBox.SelectedItems) -Force

    # Unselects Fields
    for($i = 0; $i -lt $OpNotesListBox.Items.Count; $i++) {
        $OpNotesListBox.SetSelected($i, $false)
    }
}


#---------------------------------
# OpNotes - OpNotes Textbox Entry
#---------------------------------
# This function is called when pressing enter in the text box or click add
# Allows for a single function when being called from two methods

function OpNoteTextBoxEntry {
    # Adds Timestamp to Entered Text
    $OpNotesAdded = $OpNotesListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) $($OpNotesInputTextBox.Text)")
    $OpNotesAdded

    OpNotesSaveScript

    # Adds all entries to the OpNotesWriteOnlyFile -- This file gets all entries and are not editable from the GUI
    # Useful for looking into accidentally deleted entries
    $PrependData = Get-Content $OpNotesWriteOnlyFile
    Set-Content -Path $OpNotesWriteOnlyFile -Value (("$($(Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) $($OpNotesInputTextBox.Text)"),$PrependData) -Force 
    
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


# Shift Down
$OpNotesDownPosition += $OpNotesDownPositionShift


#--------------------------
# OpNotes - Input Text Box
#--------------------------
$OpNotesInputTextBox          = New-Object System.Windows.Forms.TextBox
$OpNotesInputTextBox.Location = New-Object System.Drawing.Size($OpNotesRightPosition,$OpNotesDownPosition)
$OpNotesInputTextBox.Size     = New-Object System.Drawing.Size($OpNotesInputTextBoxWidth,$OpNotesInputTextBoxHeight)
$OpNotesInputTextBox.TabIndex = 2
$OpNotesInputTextBox.DataBindings.DefaultDataSourceUpdateMode = 0
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


# Shift Down
$OpNotesDownPosition += $OpNotesDownPositionShift


#----------------------
# OpNotes - Add Button
#----------------------
$OpNotesAddButton          = New-Object System.Windows.Forms.Button
$OpNotesAddButton.Text     = "Add"
$OpNotesAddButton.Location = New-Object System.Drawing.Size($OpNotesRightPosition,$OpNotesDownPosition)
$OpNotesAddButton.Size     = New-Object System.Drawing.Size($OpNotesButtonWidth,$OpNotesButtonHeight)
$OpNotesAddButton.add_click({
    # There must be text in the input to make an entry
    if ($OpNotesInputTextBox.Text -ne "") {
        OpNoteTextBoxEntry
    }    
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
$OpNotesAddButton.add_click({
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
$OpNotesOpenListBox.add_click({
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
$OpNotesMoveUpButton.add_click({
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
    OpNotesSaveScript
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
$OpNotesRemoveButton.add_click({
    $OpNotesListBox.Items.Remove($OpNotesListBox.SelectedItem)
    OpNotesSaveScript
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
$OpNotesCreateReportButton.add_click({
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
        $MainListBox.Items.Clear()
        $MainListBox.Items.Add('You must select at least one line to add to a report!')
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
$OpNotesOpenListBox.add_click({
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
$OpNotesMoveDownButton.add_click({
    #only if the last item isn't the current one
    if(($OpNotesListBox.SelectedIndex -ne -1)   -and   ($OpNotesListBox.SelectedIndex -lt $OpNotesListBox.Items.Count - 1)    )   {
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
    OpNotesSaveScript
})
$Section1OpNotesTab.Controls.Add($OpNotesMoveDownButton) 


# Shift Down
$OpNotesDownPosition += $OpNotesDownPositionShift


#------------------------
# OpNotes - Main ListBox
#------------------------
$OpNotesListBox          = New-Object System.Windows.Forms.ListBox
$OpNotesListBox.Name     = "OpNotesListBox"
$OpNotesListBox.FormattingEnabled = $True
$OpNotesListBox.Location = New-Object System.Drawing.Size($OpNotesRightPositionStart,($OpNotesDownPosition + 5)) 
$OpNotesListBox.Size     = New-Object System.Drawing.Size($OpNotesMainTextBoxWidth,$OpNotesMainTextBoxHeight)
$OpNotesListBox.Font     = New-Object System.Drawing.Font("Courier New",8,[System.Drawing.FontStyle]::Regular)
$OpNotesListBox.SelectionMode = 'MultiExtended'
$OpNotesListBox.ScrollAlwaysVisible = $True
$OpNotesListBox.AutoSize = $false
$Section1OpNotesTab.Controls.Add($OpNotesListBox)
$OpNotesListBox



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
##############################################################################################################################################################
##
## Section 1 Commands Tab
##
##############################################################################################################################################################
##############################################################################################################################################################
$Section1CommandsTab          = New-Object System.Windows.Forms.TabPage
$Section1CommandsTab.Text     = "Commands"
$Section1CommandsTab.Name     = "Commands Tab"
$Section1CommandsTab.TabIndex = 0
$Section1CommandsTab.UseVisualStyleBackColor = $True

#Checks if the Resources Directory is there and loads it if it is
if (Test-Path $PoShHome\Resources\Commands) {
    $Section1TabControl.Controls.Add($Section1CommandsTab)
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
## Section 1 Commands TabControl
##
#####################################################################################################################################

# The TabControl controls the tabs within it
$Section1CommandsTabControl               = New-Object System.Windows.Forms.TabControl
$Section1CommandsTabControl.Name          = "Commands TabControl"
$Section1CommandsTabControl.Location      = New-Object System.Drawing.Size($TabRightPosition,$TabhDownPosition)
$Section1CommandsTabControl.Size          = New-Object System.Drawing.Size($TabAreaWidth,$TabAreaHeight) 
$Section1CommandsTabControl.ShowToolTips  = $True
$Section1CommandsTabControl.TabIndex      = 4
$Section1CommandsTabControl.SelectedIndex = 0
$Section1CommandsTab.Controls.Add($Section1CommandsTabControl)



############################################################################################################
# Section 1 Commands SubTab
############################################################################################################

#------------------------------------
# Auto Creates Tabs and Imports Data
#------------------------------------
# Obtains a list of the files in the resources folder
$ResourceProcessFiles = Get-ChildItem "$PoShHome\Resources\Commands"

# Iterates through the files and dynamically creates tabs and imports data
foreach ($File in $ResourceProcessFiles) {
    #-----------------------------
    # Creates Tabs From Each File
    #-----------------------------
    $TabName                                   = $File.BaseName
    $Section1CommandsSubTab                   = New-Object System.Windows.Forms.TabPage
    $Section1CommandsSubTab.Text              = "$TabName"
    $Section1CommandsSubTab.TabIndex          = 0
    $Section1CommandsSubTab.UseVisualStyleBackColor = $True
    $Section1CommandsTabControl.Controls.Add($Section1CommandsSubTab)

    #-----------------------------
    # Imports Data Into Textboxes
    #-----------------------------
    $TabContents                              = Get-Content -Path $File.FullName -Force | foreach {$_ + "`r`n"} 
    $Section1CommandsSubTabTextBox            = New-Object System.Windows.Forms.TextBox
    $Section1CommandsSubTabTextBox.Name       = "$file"
    $Section1CommandsSubTabTextBox.Location   = New-Object System.Drawing.Size($TextBoxRightPosition,$TextBoxDownPosition) 
    $Section1CommandsSubTabTextBox.Size       = New-Object System.Drawing.Size($TextBoxWidth,$TextBoxHeight)
    $Section1CommandsSubTabTextBox.MultiLine  = $True
    $Section1CommandsSubTabTextBox.ScrollBars = "Vertical"
    $Section1CommandsSubTabTextBox.Font       = New-Object System.Drawing.Font("$Font",9,0,3,1)
    $Section1CommandsSubTab.Controls.Add($Section1CommandsSubTabTextBox)
    $Section1CommandsSubTabTextBox.Text       = "$TabContents"
}







##############################################################################################################################################################
##############################################################################################################################################################
##
## Section 1 About Tab
##
##############################################################################################################################################################
##############################################################################################################################################################
$Section1AboutTab          = New-Object System.Windows.Forms.TabPage
$Section1AboutTab.Text     = "About"
$Section1AboutTab.Name     = "About Tab"
$Section1AboutTab.TabIndex = 0
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
$Section1AboutTabControl.TabIndex      = 4
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
    $Section1AboutSubTab.TabIndex          = 0
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
    $Section1AboutSubTabTextBox.Font       = New-Object System.Drawing.Font("Courier New",8,0,3,1)
    $Section1AboutSubTab.Controls.Add($Section1AboutSubTabTextBox)
    $Section1AboutSubTabTextBox.Text       = "$TabContents"
}


# ============================================================================================================================================================
# Column 3
# ============================================================================================================================================================

# Varables to Control Column 3
$Column3RightPosition     = 475
$Column3DownPosition      = 10
$Column3BoxWidth          = 300
$Column3BoxHeight         = 22
$Column3DownPositionShift = 26


#-------------------------------------------
# Select How To Collect Data - Main Section
#-------------------------------------------

$SelectedTargetLabel           = New-Object System.Windows.Forms.Label
$SelectedTargetLabel.Location  = New-Object System.Drawing.Size(($Column3RightPosition - 2),($Column3DownPosition)) 
$SelectedTargetLabel.Size      = New-Object System.Drawing.Size(300,$Column3BoxHeight)
$SelectedTargetLabel.Text      = "Select How To Collect Data:"
$SelectedTargetLabel.Font      = New-Object System.Drawing.Font("$Font",12,1,3,1)
$SelectedTargetLabel.ForeColor = "Blue"
$PoShACME.Controls.Add($SelectedTargetLabel)  


# Shift Row Location
$Column3DownPosition += $Column3DownPositionShift


#-------------------------------------------------------
# Selected - Select Hostnames/IPs From List Checkbox
#-------------------------------------------------------
# This checkbox highlights when selecing computers from the ComputerList
$SelectedTargetCheckBox                  = New-Object System.Windows.Forms.Checkbox
$SelectedTargetCheckBox.Name             = "Select Hostnames / IPs From List:"
$SelectedTargetCheckBox.Text             = "$($SelectedTargetCheckBox.Name)"
$SelectedTargetCheckBox.TabIndex         = 2
$SelectedTargetCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$SelectedTargetCheckBox.Location         = New-Object System.Drawing.Size($Column3RightPosition,($Column3DownPosition + 2)) 
$SelectedTargetCheckBox.Size             = New-Object System.Drawing.Size(220,$Column3BoxHeight)
$SelectedTargetCheckBox.Enabled          = $false
$SelectedTargetCheckBox.Font             = [System.Drawing.Font]::new("$Font", 8, [System.Drawing.FontStyle]::Bold)
$SelectedTargetCheckBox.Add_Click({
    If ($SelectedTargetCheckBox.Checked -eq $true){
        # Auto checks/unchecks various checkboxes for visual status indicators
        $ImportListCheckBox.Checked          = $false
        $DomainGeneratedCheckBox.Checked     = $false
        $DomainGeneratedAutoCheckBox.Checked = $false
        $SingleHostIPCheckBox.Checked        = $false
    }
    else {$SelectedTargetCheckBox.Checked  = $true}
})
$PoShACME.Controls.Add($SelectedTargetCheckBox)


#------------------------------------------
# Single Host - Collect On Selected Button
#------------------------------------------
$SelectedTargetSelectButton                = New-Object System.Windows.Forms.Button
$SelectedTargetSelectButton.Location       = New-Object System.Drawing.Size(($Column3RightPosition + 220),($Column3DownPosition + 2))
$SelectedTargetSelectButton.Size           = New-Object System.Drawing.Size(110,$Column3BoxHeight)
$SelectedTargetSelectButton.Text           = 'Select From List'
$SelectedTargetSelectButton.add_click({
    $SelectedTargetCheckBox.Font     = [System.Drawing.Font]::new("$Font", 8, [System.Drawing.FontStyle]::Bold)
    $SelectedTargetCheckBox.Enabled  = $true
    $ImportListCheckBox.Enabled          = $false
    $DomainGeneratedCheckBox.Enabled     = $false
    $SingleHostIPCheckBox.Enabled        = $false

    $SelectedTargetCheckBox.Checked  = $true
    $ImportListCheckBox.Checked          = $false
    $DomainGeneratedCheckBox.Checked     = $false
    $DomainGeneratedAutoCheckBox.Checked = $false
    $SingleHostIPCheckBox.Checked        = $false

    . SelectListBoxEntry

    $MainListBox.Items.Clear();   
    $MainListBox.Items.Add("Collect Data From:")
    foreach ($Computer in $ComputerList) {
        [void] $MainListBox.Items.Add("$Computer")
    }
})
#$PoShACME.AcceptButton = $SelectedTargetSelectButton
$PoShACME.Controls.Add($SelectedTargetSelectButton) 



# Shift Row Location
$Column3DownPosition += $Column3DownPositionShift + 10





#---------------------------------------------------
# Import List - Import List From Text File Checkbox
#---------------------------------------------------
# This checkbox highlights when selecing computers from the ComputerList

$ImportListCheckBox                          = New-Object System.Windows.Forms.Checkbox
$ImportListCheckBox.Name                     = "Import List From Text File:"
$ImportListCheckBox.Text                     = "$($ImportListCheckBox.Name)"
$ImportListCheckBox.TabIndex                 = 2
$ImportListCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$ImportListCheckBox.Location                 = New-Object System.Drawing.Size($Column3RightPosition,($Column3DownPosition + 2)) 
$ImportListCheckBox.Size                     = New-Object System.Drawing.Size(($Column3BoxWidth - 88),$Column3BoxHeight)
$ImportListCheckBox.Enabled                  = $false
$ImportListCheckBox.Font                     = [System.Drawing.Font]::new("$Font", 8, [System.Drawing.FontStyle]::Bold)
$ImportListCheckBox.Add_Click({
    If ($ImportListCheckBox.Checked -eq $true){
        # Auto checks/unchecks various checkboxes for visual status indicators
        $DomainGeneratedCheckBox.Checked     = $false
        $DomainGeneratedAutoCheckBox.Checked = $false
        $SingleHostIPCheckBox.Checked        = $false
        $SelectedTargetCheckBox.Checked  = $false
    }
    else {$ImportListCheckBox.Checked = $true}
})
$PoShACME.Controls.Add($ImportListCheckBox)


#--------------------------------------
# Import List - Import Host/IPs Button
#--------------------------------------

$ImportListButton                        = New-Object System.Windows.Forms.Button
$ImportListButton.Text                   = "Import Hosts/IPs"
$ImportListButton.Location               = New-Object System.Drawing.Size(($Column3RightPosition + 220),$Column3DownPosition)
$ImportListButton.Size                   = New-Object System.Drawing.Size(110,$Column3BoxHeight) 
$ImportListButton.add_click({
    $ImportListCheckBox.Font             = [System.Drawing.Font]::new("$Font", 8, [System.Drawing.FontStyle]::Bold)

    # Auto enables/disables various checkboxes for visual status indicators
    $ImportListCheckBox.Enabled          = $true
    $DomainGeneratedCheckBox.Enabled     = $false
    $SingleHostIPCheckBox.Enabled        = $false
    $SelectedTargetCheckBox.Enabled  = $false

    # Auto checks/unchecks various checkboxes for visual status indicators
    $ImportListCheckBox.Checked          = $true
    $DomainGeneratedCheckBox.Checked     = $false
    $DomainGeneratedAutoCheckBox.Checked = $false
    $SingleHostIPCheckBox.Checked        = $false
    $SelectedTargetCheckBox.Checked  = $false

    . ListTextFile

    $MainListBox.Items.Clear();   
    $MainListBox.Items.Add("Collect Data From:")
    $MainListBox.Items.Add("$file_Name")
    foreach ($Computer in $ComputerList) {
        [void] $MainListBox.Items.Add("$Computer")
    }
    $ComputerListBox.Items.Clear()
    foreach ($Computer in $ComputerList) {
        [void] $ComputerListBox.Items.Add("$Computer")
    }
})
$PoShACME.Controls.Add($ImportListButton) 


# Shift Row Location
$Column3DownPosition += $Column3DownPositionShift + 10





#--------------------------------
# Domain Generated - Input Check
#--------------------------------
function DomainGeneratedInputCheck {
    if (($DomainGeneratedTextBox.Text -ne '<Domain Name>') -or ($DomainGeneratedAutoCheckBox.Checked)) {
    if (($DomainGeneratedTextBox.Text -ne '') -or ($DomainGeneratedAutoCheckBox.Checked)) {
        # Auto enables/disables various checkboxes for visual status indicators
        $DomainGeneratedCheckBox.Enabled     = $true
        $ImportListCheckBox.Enabled          = $false
        $SingleHostIPCheckBox.Enabled        = $false
        $SelectedTargetCheckBox.Enabled  = $false

        # Auto checks/unchecks various checkboxes for visual status indicators
        $DomainGeneratedCheckBox.Checked     = $true
        $ImportListCheckBox.Checked          = $false
        $SingleHostIPCheckBox.Checked        = $false
        $SelectedTargetCheckBox.Checked  = $false

        # Checks if the domain input field is either blank or contains the default info
        If ($DomainGeneratedAutoCheckBox.Checked  -eq $true){. ListComputers "Auto"}
        else {. ListComputers "Manual" "$($DomainGeneratedTextBox.Text)"}

        $MainListBox.Items.Clear();
        $MainListBox.Items.Add("Collect Data From:")
        foreach ($Computer in $ComputerList) {
            [void] $MainListBox.Items.Add("$Computer")
        }

        $ComputerListBox.Items.Clear()
        foreach ($Computer in $ComputerList) {
            [void] $ComputerListBox.Items.Add("$Computer")
        }
    }
    }

}


#-------------------------------------------------------
# Domain Generated - Generate List from Domain Checkbox
#-------------------------------------------------------
# This checkbox highlights when selecing computers from the ComputerList

$DomainGeneratedCheckBox                     = New-Object System.Windows.Forms.Checkbox
$DomainGeneratedCheckBox.Name                = "Generate List From Domain:"
$DomainGeneratedCheckBox.Text                = "$($DomainGeneratedCheckBox.Name)"
$DomainGeneratedCheckBox.TabIndex            = 2
$DomainGeneratedCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$DomainGeneratedCheckBox.Location            = New-Object System.Drawing.Size($Column3RightPosition,($Column3DownPosition)) 
$DomainGeneratedCheckBox.Size                = New-Object System.Drawing.Size(($Column3BoxWidth - 88),$Column3BoxHeight)
$DomainGeneratedCheckBox.Enabled             = $false
$DomainGeneratedCheckBox.Font                = [System.Drawing.Font]::new("$Font", 8, [System.Drawing.FontStyle]::Bold)    
$DomainGeneratedCheckBox.Add_Click({
    # Auto checks/unchecks various checkboxes for visual status indicators
    If ($DomainGeneratedCheckBox.Checked   -eq $true){
        $DomainGeneratedAutoCheckBox.Checked = $true
        $ImportListCheckBox.Checked          = $false
        $SingleHostIPCheckBox.Checked        = $false
        $SelectedTargetCheckBox.Checked  = $false
    }
    else {$DomainGeneratedCheckBox.Checked   = $true}
    If ($DomainGeneratedCheckBox.Checked   -eq $false){
        $DomainGeneratedCheckBox.Checked     = $false
    }
})
$PoShACME.Controls.Add($DomainGeneratedCheckBox)


#---------------------------------------
# Domain Generated - Auto Pull Checkbox
#---------------------------------------
$DomainGeneratedAutoCheckBox          = New-Object System.Windows.Forms.Checkbox
$DomainGeneratedAutoCheckBox.Name     = "Auto Pull"
$DomainGeneratedAutoCheckBox.Text     = "$($DomainGeneratedAutoCheckBox.Name)"
$DomainGeneratedAutoCheckBox.TabIndex = 2
$DomainGeneratedAutoCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$DomainGeneratedAutoCheckBox.Location = New-Object System.Drawing.Size(($Column3RightPosition + 221),$Column3DownPosition)
$DomainGeneratedAutoCheckBox.Size     = New-Object System.Drawing.Size((100),$Column3BoxHeight)
$DomainGeneratedAutoCheckBox.Add_Click({
    If ($DomainGeneratedAutoCheckBox.Checked -eq $true){
        # Auto enables/disables various checkboxes for visual status indicators
        $DomainGeneratedCheckBox.Enabled    = $true
        $ImportListCheckBox.Enabled         = $false
        $SingleHostIPCheckBox.Enabled       = $false
        $SelectedTargetCheckBox.Enabled = $false

        # Auto checks/unchecks various checkboxes for visual status indicators
        $DomainGeneratedCheckBox.Checked    = $true
        $ImportListCheckBox.Checked         = $false
        $SingleHostIPCheckBox.Checked       = $false
        $SelectedTargetCheckBox.Checked = $false
    }
    If ($DomainGeneratedAutoCheckBox.Checked -eq $false){
        $DomainGeneratedAutoCheckBox.Checked = $false
    }
})
$PoShACME.Controls.Add($DomainGeneratedAutoCheckBox)


# Shift Row Location
$Column3DownPosition += $Column3DownPositionShift


#----------------------------------
# Domain Generated - Input Textbox
#----------------------------------

$DomainGeneratedTextBox          = New-Object System.Windows.Forms.TextBox
$DomainGeneratedTextBox.Text     = "<Domain Name>" #Default Content
$DomainGeneratedTextBox.Location = New-Object System.Drawing.Size(($Column3RightPosition) ,$Column3DownPosition)
$DomainGeneratedTextBox.Size     = New-Object System.Drawing.Size(($Column3BoxWidth - 90),$Column3BoxHeight)
$DomainGeneratedTextBox.Add_KeyDown({
    if ($_.KeyCode -eq "Enter") {
        DomainGeneratedInputCheck
    }
})
$PoShACME.Controls.Add($DomainGeneratedTextBox)


#--------------------------------------------
# Domain Generated - Import Hosts/IPs Button
#--------------------------------------------

$DomainGeneratedListButton          = New-Object System.Windows.Forms.Button
$DomainGeneratedListButton.Text     = "Import Hosts/IPs"
$DomainGeneratedListButton.Location = New-Object System.Drawing.Size(($Column3RightPosition + 220),($Column3DownPosition - 1))
$DomainGeneratedListButton.Size     = New-Object System.Drawing.Size(110,$Column3BoxHeight)
$DomainGeneratedListButton.add_click({
    DomainGeneratedInputCheck
})
$PoShACME.Controls.Add($DomainGeneratedListButton) 


# Shift Row Location
$Column3DownPosition += $Column3DownPositionShift + 10






#---------------------------
# Single Host - Input Check
#---------------------------

function SingleHostInputCheck {
    if ($SingleHostIPTextBox.Text -ne '<Type In A Hostname/IP>') {
    if ($SingleHostIPTextBox.Text -ne '') {
        # Auto enables/disables various checkboxes for visual status indicators
        $SingleHostIPCheckBox.Enabled        = $true
        $ImportListCheckBox.Enabled          = $false
        $DomainGeneratedCheckBox.Enabled     = $false
        $SelectedTargetCheckBox.Enabled      = $false

        # Auto checks/unchecks various checkboxes for visual status indicators
        $SingleHostIPCheckBox.Checked        = $true
        $ImportListCheckBox.Checked          = $false
        $DomainGeneratedCheckBox.Checked     = $false
        $DomainGeneratedAutoCheckBox.Checked = $false
        $SelectedTargetCheckBox.Checked      = $false

        . SingleEntry

        $MainListBox.Items.Clear();   
        $MainListBox.Items.Add("Collect Data From:")
        foreach ($Computer in $ComputerList) {
            [void] $MainListBox.Items.Add("$Computer")
        }
    }
    }
}


#---------------------------------------------------
# Single Host - Enter A Single Hostname/IP Checkbox
#---------------------------------------------------
# This checkbox highlights when selecing computers from the ComputerList

$SingleHostIPCheckBox                        = New-Object System.Windows.Forms.Checkbox
$SingleHostIPCheckBox.Name                   = "Enter A Single Hostname/IP:"
$SingleHostIPCheckBox.Text                   = "$($SingleHostIPCheckBox.Name)"
$SingleHostIPCheckBox.TabIndex               = 2
$SingleHostIPCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$SingleHostIPCheckBox.Location               = New-Object System.Drawing.Size($Column3RightPosition,($Column3DownPosition)) 
$SingleHostIPCheckBox.Size                   = New-Object System.Drawing.Size(($Column3BoxWidth - 88),$Column3BoxHeight)
$SingleHostIPCheckBox.Enabled                = $false
$SingleHostIPCheckBox.Font                = [System.Drawing.Font]::new("$Font", 8, [System.Drawing.FontStyle]::Bold)
$SingleHostIPCheckBox.Add_Click({
    # Auto checks/unchecks various checkboxes for visual status indicators
    If ($SingleHostIPCheckBox.Checked  -eq $true){
        $ImportListCheckBox.Checked          = $false
        $DomainGeneratedCheckBox.Checked     = $false
        $DomainGeneratedAutoCheckBox.Checked = $false
        $SelectedTargetCheckBox.Checked  = $false
    }
    else {$SingleHostIPCheckBox.Checked      = $true}

})
$PoShACME.Controls.Add($SingleHostIPCheckBox)


#----------------------------------
# Single Host - Add To List Button
#----------------------------------

$SingleHostIPAddButton          = New-Object System.Windows.Forms.Button
$SingleHostIPAddButton.Text     = "Add To List"
$SingleHostIPAddButton.Location = New-Object System.Drawing.Size(($Column3RightPosition + 220),$Column3DownPosition)
$SingleHostIPAddButton.Size     = New-Object System.Drawing.Size(110,$Column3BoxHeight) 
$SingleHostIPAddButton.add_click({
    # Conducts a simple input check for default or blank data
    if ($SingleHostIPTextBox.Text -ne '<Type In A Hostname/IP>') {
    if ($SingleHostIPTextBox.Text -ne '') {
        # Adds the hostname/ip entered into the collection list box
        $ComputerListBox.Items.Insert(0,$SingleHostIPTextBox.Text)

        # Clears Textbox
        $SingleHostIPTextBox.Text = "<Type In A Hostname/IP>"

        # Auto enables/disables various checkboxes for visual status indicators
        $SingleHostIPCheckBox.Enabled        = $true
        $ImportListCheckBox.Enabled          = $false
        $DomainGeneratedCheckBox.Enabled     = $false
        $SelectedTargetCheckBox.Enabled  = $false

        # Auto checks/unchecks various checkboxes for visual status indicators
        $SingleHostIPCheckBox.Checked        = $true
        $ImportListCheckBox.Checked          = $false
        $DomainGeneratedCheckBox.Checked     = $false
        $DomainGeneratedAutoCheckBox.Checked = $false
        $SelectedTargetCheckBox.Checked  = $false
    }
    }
})
$PoShACME.Controls.Add($SingleHostIPAddButton) 


# Shift Row Location
$Column3DownPosition += $Column3DownPositionShift


#-----------------------------------------------
# Single Host - <Type In A Hostname/IP> Textbox
#-----------------------------------------------

$SingleHostIPTextBox          = New-Object System.Windows.Forms.TextBox
$SingleHostIPTextBox.Text     = "<Type In A Hostname/IP>"
$SingleHostIPTextBox.Location = New-Object System.Drawing.Size($Column3RightPosition,($Column3DownPosition + 1))
$SingleHostIPTextBox.Size     = New-Object System.Drawing.Size(210,$Column3BoxHeight)
$SingleHostIPTextBox.TabIndex = 2
$SingleHostIPTextBox.DataBindings.DefaultDataSourceUpdateMode = 0
$SingleHostIPTextBox.Add_KeyDown({
    if ($_.KeyCode -eq "Enter") {
        SingleHostInputCheck
    }
})
$PoShACME.Controls.Add($SingleHostIPTextBox)


#--------------------------------------
# Single Host - Collect Entered Button
#--------------------------------------

$SingleHostIPOKButton          = New-Object System.Windows.Forms.Button
$SingleHostIPOKButton.Text     = "Collect Entered"
$SingleHostIPOKButton.Location = New-Object System.Drawing.Size(($Column3RightPosition + 220),$Column3DownPosition)
$SingleHostIPOKButton.Size     = New-Object System.Drawing.Size(110,$Column3BoxHeight) 
$SingleHostIPOKButton.add_click({
    SingleHostInputCheck
})
$PoShACME.Controls.Add($SingleHostIPOKButton) 


# Shift Row Location
$Column3DownPosition += $Column3DownPositionShift

# Shift Row Location
$Column3DownPosition += $Column3DownPositionShift - 3








#-------------------------------------------
# Directory Location - Results Folder Label
#-------------------------------------------

$DirectoryListLabel           = New-Object System.Windows.Forms.Label
$DirectoryListLabel.Location  = New-Object System.Drawing.Size($Column3RightPosition,$Column3DownPosition) 
$DirectoryListLabel.Size      = New-Object System.Drawing.Size(130,$Column3BoxHeight) 
$DirectoryListLabel.Text      = "Results Folder:"
$DirectoryListLabel.Font      = "Microsoft Sans Serif,12"
$DirectoryListLabel.ForeColor = "Blue"
$PoShACME.Controls.Add($DirectoryListLabel)


#----------------------------------
# Directory Location - Open Button
#----------------------------------
$DirectoryOpenListBox          = New-Object System.Windows.Forms.Button
$DirectoryOpenListBox.Text     = "Open"
$DirectoryOpenListBox.Location = New-Object System.Drawing.Size(($Column3RightPosition + 130),$Column3DownPosition)
$DirectoryOpenListBox.Size     = New-Object System.Drawing.Size(80,$Column3BoxHeight) 
$DirectoryOpenListBox.add_click({
    if (Test-Path -Path $PoShLocation) {Invoke-Item -Path $PoShLocation}
    else {Invoke-Item -Path $PoShHome}
})
$PoShACME.Controls.Add($DirectoryOpenListBox)


#-------------------------------------------
# Directory Location - New Timestamp Button
#-------------------------------------------
$DirectoryUpdateListBox              = New-Object System.Windows.Forms.Button
$DirectoryUpdateListBox.Text         = "New Timestamp"
$DirectoryUpdateListBox.Location     = New-Object System.Drawing.Size(($Column3RightPosition + 140 + 80),$Column3DownPosition)
$DirectoryUpdateListBox.Size         = New-Object System.Drawing.Size(110,$Column3BoxHeight) 
$DirectoryUpdateListBox.add_click({
    $Script:PoShLocation                    = "$PoShHome\$CollectedData\$((Get-Date).ToString('yyyy-MM-dd @ HHmm ss'))"
    $DirectoryListBox.Items.Clear();   
    $DirectoryListBox.Items.Add("....\$CollectedData\$((Get-Date).ToString('yyyy-MM-dd @ HHmm ss'))")
})
$PoShACME.Controls.Add($DirectoryUpdateListBox) 


# Shift Row Location
$Column3DownPosition += $Column3DownPositionShift


#----------------------------------------
# Directory Location - Directory Listbox
#----------------------------------------
# This shows the name of the directy that data will be currently saved to

$DirectoryListBox          = New-Object System.Windows.Forms.ListBox
$DirectoryListBox.Name     = "DirectoryListBox"
$DirectoryListBox.FormattingEnabled = $True
$DirectoryListBox.Location = New-Object System.Drawing.Size($Column3RightPosition,$Column3DownPosition) 
$DirectoryListBox.Size     = New-Object System.Drawing.Size(330,$Column3BoxHeight)
$DirectoryListBox.DataBindings.DefaultDataSourceUpdateMode = 0
$DirectoryListBox.TabIndex = 3
$DirectoryListBox.Items.Add("....\$CollectedData\$((Get-Date).ToString('yyyy-MM-dd @ HHmm ss'))") | Out-Null
$PoShACME.Controls.Add($DirectoryListBox)


# Shift Row Location
$Column3DownPosition += $Column3DownPositionShift


# ============================================================================================================================================================
# ============================================================================================================================================================
# Column 4
# ============================================================================================================================================================
# ============================================================================================================================================================

# Varables to Control Column 4
$Column4RightPosition     = 815
$Column4DownPosition      = 11
$Column4BoxWidth          = 220
$Column4BoxHeight         = 22

$Column4BigBoxWidth       = 189
$Column4BigBoxHeight      = 280

$Column4DownPositionShift = 25


# ----------------------
# Computer List ListBox
#-----------------------
$ComputerListBox               = New-Object System.Windows.Forms.ListBox
$ComputerListBox.Location      = New-Object System.Drawing.Point($Column4RightPosition,$Column4DownPosition)
$ComputerListBox.Size          = New-Object System.Drawing.Size($Column4BigBoxWidth,$Column4BigBoxHeight)
$ComputerListBox.SelectionMode = 'MultiExtended'
$ComputerListBox.Items.Add("This box will auto populate during load")
$ComputerListBox.Items.Add("with hostsnames / IPs if the iplist.txt")
$ComputerListBox.Items.Add("exists in the PoSh-ACME directory.")
$PoShACME.Controls.Add($ComputerListBox)

# Checks to see if IPListFile exists and loads it
$IPListFileContents = Get-Content "$IPListFile"
if (Test-Path -Path $IPListFileContents) {
    $ComputerListBox.Items.Clear()
    foreach ($Computer in $IPListFileContents){
        $ComputerListBox.Items.Add("$Computer")
    }
 }



##############################################################################################################################################################
##############################################################################################################################################################
##############################################################################################################################################################
##
## Section 2 Computer List - Tab Control
##
##############################################################################################################################################################
##############################################################################################################################################################
##############################################################################################################################################################


$Section2TabControl               = New-Object System.Windows.Forms.TabControl
$System_Drawing_Point             = New-Object System.Drawing.Point
$System_Drawing_Point.X           = 1015
$System_Drawing_Point.Y           = 10
$Section2TabControl.Location      = $System_Drawing_Point
$Section2TabControl.Name          = "Main Tab Window for Computer List"
$Section2TabControl.SelectedIndex = 0
$Section2TabControl.ShowToolTips  = $True
$System_Drawing_Size              = New-Object System.Drawing.Size
$System_Drawing_Size.Height       = 280
$System_Drawing_Size.Width        = 126
$Section2TabControl.Size          = $System_Drawing_Size
$Section2TabControl.TabIndex      = 4
$PoShACME.Controls.Add($Section2TabControl)


# Varables to Control Column 5
$Column5RightPosition     = 3
$Column5DownPositionStart = 6
$Column5DownPosition      = 6
$Column5DownPositionShift = 28

$Column5BoxWidth          = 110
$Column5BoxHeight         = 22


##############################################################################################################################################################
##############################################################################################################################################################
##
## Section 2 Computer List - Action Tab
##
##############################################################################################################################################################
##############################################################################################################################################################


$Section2ActionTab          = New-Object System.Windows.Forms.TabPage
$Section2ActionTab.Location = $System_Drawing_Point
$Section2ActionTab.Text     = "Action"

$Section2ActionTab.Location    = New-Object System.Drawing.Size($Column5RightPosition,$Column5DownPosition) 
$Section2ActionTab.Size        = New-Object System.Drawing.Size($Column5BoxWidth,$Column5BoxHeight) 
$Section2ActionTab.TabIndex = 0
$Section2ActionTab.UseVisualStyleBackColor = $True
$Section2TabControl.Controls.Add($Section2ActionTab)


#####################################################################################################################################
## Section 2 Computer List - Action Tab Buttons
#####################################################################################################################################



#------------------
# View CSV Results
#------------------
$OpenResultsButton          = New-Object System.Windows.Forms.Button
$OpenResultsButton.Name     = "View CSV Results"
$OpenResultsButton.Text     = "$($OpenResultsButton.Name)"
$OpenResultsButton.TabIndex = 4
$OpenResultsButton.DataBindings.DefaultDataSourceUpdateMode = 0
$OpenResultsButton.UseVisualStyleBackColor = $True
$OpenResultsButton.Location = New-Object System.Drawing.Size($Column5RightPosition,$Column5DownPosition)
$OpenResultsButton.Size     = New-Object System.Drawing.Size($Column5BoxWidth,$Column5BoxHeight)
$OpenResultsButton.add_click({
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    $ViewCSVResultsOpenResultsOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $ViewCSVResultsOpenResultsOpenFileDialog.Title = "View Collection CSV Results"
    $ViewCSVResultsOpenResultsOpenFileDialog.InitialDirectory = "$PoShHome\$CollectedData"
    $ViewCSVResultsOpenResultsOpenFileDialog.filter = "CSV (*.csv)| *.csv|Excel (*.xlsx)| *.xlsx|Excel (*.xls)| *.xls|All files (*.*)|*.*"
    $ViewCSVResultsOpenResultsOpenFileDialog.ShowDialog() | Out-Null
    $ViewCSVResultsOpenResultsOpenFileDialog.ShowHelp = $true
    Import-Csv $($ViewCSVResultsOpenResultsOpenFileDialog.filename) | Out-GridView -OutputMode Multiple | Set-Variable -Name ViewImportResults
    
    if ($ViewImportResults) {
        $OpNotesListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) View CSV File:  $($ViewCSVResultsOpenResultsOpenFileDialog.filename)")
        foreach ($Selection in $ViewImportResults) {
            $OpNotesListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) Selection:  $($Selection)")
            Add-Content -Path $OpNotesWriteOnlyFile -Value ($OpNotesListBox.SelectedItems) -Force
        }
    }
    OpNotesSaveScript
})
$Section2ActionTab.Controls.Add($OpenResultsButton)

# Shift Row Location
$Column5DownPosition += $Column5DownPositionShift


#--------------------
# Compare CSV Button
#--------------------
$CompareButton          = New-Object System.Windows.Forms.Button
$CompareButton.Name     = "Compare CSVs"
$CompareButton.Text     = "$($CompareButton.Name)"
$CompareButton.TabIndex = 4
$CompareButton.DataBindings.DefaultDataSourceUpdateMode = 0
$CompareButton.UseVisualStyleBackColor = $True
$CompareButton.Location = New-Object System.Drawing.Size($Column5RightPosition,$Column5DownPosition)
$CompareButton.Size     = New-Object System.Drawing.Size($Column5BoxWidth,$Column5BoxHeight)
$Section2ActionTab.Controls.Add($CompareButton)
$CompareButton.add_click({
    # Compare Reference Object
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    $OpenCompareReferenceObjectFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenCompareReferenceObjectFileDialog.Title = "Compare Reference Object"
    $OpenCompareReferenceObjectFileDialog.InitialDirectory = "$PoShHome\$CollectedData"
    $OpenCompareReferenceObjectFileDialog.filter = "CSV (*.csv)| *.csv|Excel (*.xlsx)| *.xlsx|Excel (*.xls)| *.xls|All files (*.*)|*.*"
    $OpenCompareReferenceObjectFileDialog.ShowDialog() | Out-Null
    $OpenCompareReferenceObjectFileDialog.ShowHelp = $true

    # Compare Difference Object
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    $OpenCompareDifferenceObjectFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenCompareDifferenceObjectFileDialog.Title = "Compare Difference Object"
    $OpenCompareDifferenceObjectFileDialog.InitialDirectory = "$PoShHome\$CollectedData"
    $OpenCompareDifferenceObjectFileDialog.filter = "CSV (*.csv)| *.csv|Excel (*.xlsx)| *.xlsx|Excel (*.xls)| *.xls|All files (*.*)|*.*"
    $OpenCompareDifferenceObjectFileDialog.ShowDialog() | Out-Null
    $OpenCompareDifferenceObjectFileDialog.ShowHelp = $true

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
        $CompareCsvFilesForm.width = 330
        $CompareCsvFilesForm.height = 160
        $CompareCsvFilesForm.Text = ”Compare Two CSV Files”
        $CompareCsvFilesForm.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
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

    # Outputs messages to mainlistbox 
    $MainListBox.Items.Clear()
    $MainListBox.Items.Add("Compare Reference File:  $($OpenCompareReferenceObjectFileDialog.FileName)")
    $MainListBox.Items.Add("Compare Difference File: $($OpenCompareDifferenceObjectFileDialog.FileName)")
    $MainListBox.Items.Add("Compare Property Field:  $($Property)")

    # Writes selected fields to OpNotes
    if ($CompareImportResults) {
        $OpNotesListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) Compare Reference File:  $($OpenCompareReferenceObjectFileDialog.FileName)")
        $OpNotesListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) Compare Difference File: $($OpenCompareDifferenceObjectFileDialog.FileName)")
        $OpNotesListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) Compare Property Field:  $($OpenCompareWhatToCompare)")
        foreach ($Selection in $CompareImportResults) {
            $OpNotesListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) Compare Selection: $($Selection)")
            Add-Content -Path $OpNotesWriteOnlyFile -Value ($OpNotesListBox.SelectedItems) -Force
        }
    }
    OpNotesSaveScript
})


# Shift Row Location
$Column5DownPosition += $Column5DownPositionShift


#-----------------------------
# Computer List - Ping Button
#-----------------------------
$ComputerListPingButton               = New-Object System.Windows.Forms.Button
$ComputerListPingButton.Location      = New-Object System.Drawing.Size($Column5RightPosition,$Column5DownPosition)
$ComputerListPingButton.Size          = New-Object System.Drawing.Size($Column5BoxWidth,$Column5BoxHeight)
$ComputerListPingButton.Text          = 'Ping'
$ComputerListPingButton.add_click({
    $MainListBox.Items.Clear()
    foreach ($target in $ComputerListBox.SelectedItems){
        $ping = Test-Connection $target -Count 1
        foreach ($line in $target){
            if($ping){$MainListBox.Items.Insert(0,"Able to Ping:    $target")}
            else {$MainListBox.Items.Insert(0,"Unable to Ping:  $target")}
        $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $ping"
        $LogMessage | Add-Content -Path $LogFile
        }
    }
    $MainListBox.Items.Insert(0,"")
    $MainListBox.Items.Insert(0,"Finished Testing Connections")
})
$Section2ActionTab.Controls.Add($ComputerListPingButton) 


# Shift Row Location
$Column5DownPosition += $Column5DownPositionShift


#----------------------------
# Computer List - RDP Button
#----------------------------
$ComputerListRDPButton               = New-Object System.Windows.Forms.Button
$ComputerListRDPButton.Location      = New-Object System.Drawing.Size($Column5RightPosition,$Column5DownPosition)
$ComputerListRDPButton.Size          = New-Object System.Drawing.Size($Column5BoxWidth,$Column5BoxHeight)
$ComputerListRDPButton.Text          = 'RDP'
$ComputerListRDPButton.add_click({
    $mstsc = mstsc /v:$($ComputerListBox.SelectedItem):3389
    #mstsc /v:10.10.10.10:3389
    $mstsc
    $MainListBox.Items.Clear()
    $MainListBox.Items.Add("Remote Desktop: $($ComputerListBox.SelectedItem)")
    $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Remote Desktop: $($ComputerListBox.SelectedItem) -- `"$mstsc`""
    $LogMessage | Add-Content -Path $LogFile
})
$Section2ActionTab.Controls.Add($ComputerListRDPButton) 


# Shift Row Location
$Column5DownPosition += $Column5DownPositionShift


# Shift Row Location
$Column5DownPosition += $Column5DownPositionShift


#-------------------------------
# Computer List - PSExec Button
#-------------------------------
$ComputerListPSExecButton          = New-Object System.Windows.Forms.Button
$ComputerListPSExecButton.Location = New-Object System.Drawing.Size($Column5RightPosition,$Column5DownPosition)
$ComputerListPSExecButton.Size     = New-Object System.Drawing.Size($Column5BoxWidth,$Column5BoxHeight)
$ComputerListPSExecButton.Text     = "PsExec"
$ComputerListPSExecButton.add_click({
    if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
        if (!$Credential) {              
            $script:Credential = Get-Credential
        }
        $Username = $Credential.UserName
        $Password = $Credential.GetNetworkCredential().Password
        $UseCredential = "-u $Username -p $Password"
    }
    else {
        $Credentials = ""
    }

    $PSExecPath   = "$PoShHome\SysinternalsSuite\PsExec.exe"
    $PSExecTarget = "$($ComputerListBox.SelectedItem)"

    Start-Process PowerShell -WindowStyle Hidden -ArgumentList "Start-Process '$PSExecPath' -ArgumentList '-accepteula -s \\$PSExecTarget $UseCredential cmd'"
    
    $MainListBox.Items.Clear()
    $MainListBox.Items.Add("Enter-PSSession: $($ComputerListBox.SelectedItem)")
    $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) PSExec: $($ComputerListBox.SelectedItem)"
    $LogMessage | Add-Content -Path $LogFile
})
# Test if the SysinternalsSuite Directory is there; if it's there load the tab
if (Test-Path "$PoShHome\SysinternalsSuite\PsExec.exe") {
    $Section2ActionTab.Controls.Add($ComputerListPSExecButton) 
}


# Shift Row Location
$Column5DownPosition += $Column5DownPositionShift


#-----------------------------------
# Computer List - PS Session Button
#-----------------------------------
$ComputerListPSSessionButton          = New-Object System.Windows.Forms.Button
$ComputerListPSSessionButton.Location = New-Object System.Drawing.Size($Column5RightPosition,$Column5DownPosition)
$ComputerListPSSessionButton.Size     = New-Object System.Drawing.Size($Column5BoxWidth,$Column5BoxHeight)
$ComputerListPSSessionButton.Text     = "PS Session"
$ComputerListPSSessionButton.add_click({
    $SelectedComputer = "$($ComputerListBox.SelectedItem)"

    if ($ComputerListProvideCredentialsCheckBox.Checked -eq $true) {
        if (!$Credential) {              
            $script:Credential = Get-Credential
        }
        Start-Process PowerShell -ArgumentList "-noexit Enter-PSSession -ComputerName $SelectedComputer -Credential (Get-Credential)"
    }
    else {
        Start-Process PowerShell -ArgumentList "-noexit Enter-PSSession -ComputerName $SelectedComputer" 
    }
    
    $MainListBox.Items.Clear()
    $MainListBox.Items.Add("Enter-PSSession: $($ComputerListBox.SelectedItem)")
    $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) PSExec: $($ComputerListBox.SelectedItem)"
    $LogMessage | Add-Content -Path $LogFile
})
$Section2ActionTab.Controls.Add($ComputerListPSSessionButton) 


# Shift Row Location
$Column5DownPosition += $Column5DownPositionShift


#----------------------------------------
# Computer List - Provide Creds Checkbox
#----------------------------------------

$ComputerListProvideCredentialsCheckBox          = New-Object System.Windows.Forms.CheckBox
$ComputerListProvideCredentialsCheckBox.Name     = "Provide Creds"
$ComputerListProvideCredentialsCheckBox.Text     = "$($ComputerListProvideCredentialsCheckBox.Name)"
$ComputerListProvideCredentialsCheckBox.TabIndex = 2
$ComputerListProvideCredentialsCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$ComputerListProvideCredentialsCheckBox.Location = New-Object System.Drawing.Size(($Column5RightPosition + 1),$Column5DownPosition)
$ComputerListProvideCredentialsCheckBox.Size     = New-Object System.Drawing.Size($Column5BoxWidth,($Column5BoxHeight - 5))
$Section2ActionTab.Controls.Add($ComputerListProvideCredentialsCheckBox)


# Shift Row Location
$Column5DownPosition += $Column5DownPositionShift


#----------------
# Execute Button
#----------------
$ComputerListExecuteButton          = New-Object System.Windows.Forms.Button
$ComputerListExecuteButton.Name     = "Execute"
$ComputerListExecuteButton.Text     = "$($ComputerListExecuteButton.Name)"
$ComputerListExecuteButton.TabIndex = 4
$ComputerListExecuteButton.DataBindings.DefaultDataSourceUpdateMode = 0
$ComputerListExecuteButton.UseVisualStyleBackColor = $True
$ComputerListExecuteButton.Location = New-Object System.Drawing.Size($Column5RightPosition,$Column5DownPosition)
$ComputerListExecuteButton.Size     = New-Object System.Drawing.Size($Column5BoxWidth,$Column5BoxHeight)
$Section2ActionTab.Controls.Add($ComputerListExecuteButton)





##############################################################################################################################################################
##############################################################################################################################################################
##
## Section 2 Computer List - Control Tab
##
##############################################################################################################################################################
##############################################################################################################################################################

$Section2ControlTab          = New-Object System.Windows.Forms.TabPage
$Section2ControlTab.Location = $System_Drawing_Point
$Section2ControlTab.Text     = "Controls"

$Section2ControlTab.Location    = New-Object System.Drawing.Size($Column5RightPosition,$Column5DownPosition) 
$Section2ControlTab.Size        = New-Object System.Drawing.Size($Column5BoxWidth,$Column5BoxHeight) 

$Section2ControlTab.TabIndex = 0
$Section2ControlTab.UseVisualStyleBackColor = $True
$Section2TabControl.Controls.Add($Section2ControlTab)


#####################################################################################################################################
## Section 2 Computer List - Control Tab Buttons
#####################################################################################################################################

# Shift Row Location
$Column5DownPosition = $Column5DownPositionStart


#-----------------------------------
# Computer List - Clear List Button
#-----------------------------------
$ComputerListClearButton               = New-Object System.Windows.Forms.Button                                          #Note Start Position
$ComputerListClearButton.Location      = New-Object System.Drawing.Size($Column5RightPosition,$Column5DownPositionStart) #Note Start Position
$ComputerListClearButton.Size          = New-Object System.Drawing.Size($Column5BoxWidth,$Column5BoxHeight)              #Note Start Position
$ComputerListClearButton.Text          = 'Clear List'
$ComputerListClearButton.add_click({
    $ComputerListBox.Items.Clear()
})
$Section2ControlTab.Controls.Add($ComputerListClearButton) 


# Shift Row Location
$Column5DownPosition += $Column5DownPositionShift


#----------------------------------------
# Computer List - Remove Selected Button
#----------------------------------------
$ComputerListRemoveButton               = New-Object System.Windows.Forms.Button
$ComputerListRemoveButton.Location      = New-Object System.Drawing.Size($Column5RightPosition,$Column5DownPosition)
$ComputerListRemoveButton.Size          = New-Object System.Drawing.Size($Column5BoxWidth,$Column5BoxHeight)
$ComputerListRemoveButton.Text          = 'Remove Selected'
$ComputerListRemoveButton.add_click({
    $ComputerListBox.Items.Remove($ComputerListBox.SelectedItem)
})
$Section2ControlTab.Controls.Add($ComputerListRemoveButton) 


# Shift Row Location
$Column5DownPosition += $Column5DownPositionShift


#--------------------------------
# Computer List - Move Up Button
#--------------------------------
$ComputerListMoveUpButton               = New-Object System.Windows.Forms.Button
$ComputerListMoveUpButton.Location      = New-Object System.Drawing.Size($Column5RightPosition,$Column5DownPosition)
$ComputerListMoveUpButton.Size          = New-Object System.Drawing.Size($Column5BoxWidth,$Column5BoxHeight)
$ComputerListMoveUpButton.Text          = 'Move Up'
$ComputerListMoveUpButton.add_click({
    # only if the first item isn't the current one
    if($ComputerListBox.SelectedIndex -gt 0)
    {
        $ComputerListBox.BeginUpdate()
        #Get starting position
        $pos = $ComputerListBox.selectedIndex
        # add a duplicate of original item up in the listbox
        $ComputerListBox.items.insert($pos -1,$ComputerListBox.Items.Item($pos))
        # make it the current item
        $ComputerListBox.SelectedIndex = ($pos -1)
        # delete the old occurrence of this item
        $ComputerListBox.Items.RemoveAt($pos +1)
        $ComputerListBox.EndUpdate()
    }ELSE{
       #Top of list, beep
       [console]::beep(500,100)
    }
})
$Section2ControlTab.Controls.Add($ComputerListMoveUpButton) 


# Shift Row Location
$Column5DownPosition += $Column5DownPositionShift


#----------------------------------
# Computer List - Move Down Button
#----------------------------------
$ComputerListMoveDownButton               = New-Object System.Windows.Forms.Button
$ComputerListMoveDownButton.Location      = New-Object System.Drawing.Size($Column5RightPosition,$Column5DownPosition)
$ComputerListMoveDownButton.Size          = New-Object System.Drawing.Size($Column5BoxWidth,$Column5BoxHeight)
$ComputerListMoveDownButton.Text          = 'Move Down'
$ComputerListMoveDownButton.add_click({
    #only if the last item isn't the current one
    if(($ComputerListBox.SelectedIndex -ne -1)   -and   ($ComputerListBox.SelectedIndex -lt $ComputerListBox.Items.Count - 1)    )   {
        $ComputerListBox.BeginUpdate()
        #Get starting position 
        $pos = $ComputerListBox.selectedIndex
        # add a duplicate of item below in the listbox
        $ComputerListBox.items.insert($pos,$ComputerListBox.Items.Item($pos +1))
        # delete the old occurrence of this item
        $ComputerListBox.Items.RemoveAt($pos +2 )
        # move to current item
        $ComputerListBox.SelectedIndex = ($pos +1)
        $ComputerListBox.EndUpdate()
    }ELSE{
       #Bottom of list, beep
       [console]::beep(500,100)
    }
})
$Section2ControlTab.Controls.Add($ComputerListMoveDownButton) 


# Shift Row Location
$Column5DownPosition += $Column5DownPositionShift


#-----------------------------------
# Computer List - Select All Button
#-----------------------------------
$ComputerListSelectAllButton          = New-Object System.Windows.Forms.Button
$ComputerListSelectAllButton.Location = New-Object System.Drawing.Size($Column5RightPosition,$Column5DownPosition)
$ComputerListSelectAllButton.Size     = New-Object System.Drawing.Size($Column5BoxWidth,$Column5BoxHeight)
$ComputerListSelectAllButton.Text     = "Select All"
$ComputerListSelectAllButton.add_click({
    # Select all fields
    for($i = 0; $i -lt $ComputerListBox.Items.Count; $i++) {
        $ComputerListBox.SetSelected($i, $true)
    }
})
$Section2ControlTab.Controls.Add($ComputerListSelectAllButton) 


# Shift Row Location
$Column5DownPosition += $Column5DownPositionShift


#----------------------------------
# Computer List - Save List Button
#----------------------------------
$ComputerListSaveButton          = New-Object System.Windows.Forms.Button
$ComputerListSaveButton.Location = New-Object System.Drawing.Size($Column5RightPosition,$Column5DownPosition)
$ComputerListSaveButton.Size     = New-Object System.Drawing.Size($Column5BoxWidth,$Column5BoxHeight)

$ComputerListSaveButton.Text     = "Save List"
$ComputerListSaveButton.add_click({
    # Select all fields to be saved
    for($i = 0; $i -lt $ComputerListBox.Items.Count; $i++) {
        $ComputerListBox.SetSelected($i, $true)
    }

    # Saves all to file
    Set-Content -Path $IPListFile -Value ($ComputerListBox.SelectedItems) -Force

    # Unselects Fields
    for($i = 0; $i -lt $ComputerListBox.Items.Count; $i++) {
        $ComputerListBox.SetSelected($i, $false)
    }

    $MainListBox.Items.Clear()
    $MainListBox.Items.Add("The Following Were Saved To $IPListFile")
        $MainListBox.Select($MainListBox.TextLength, 0) 
        $MainListBox.SelectionColor = [Drawing.Color]::Red
    foreach ($line in (Get-Content -Path $IPListFile)){
        $MainListBox.Items.Add($line)    
    }
})
$Section2ControlTab.Controls.Add($ComputerListSaveButton) 


# Shift Row Location
$Column5DownPosition += $Column5DownPositionShift
# Shift Row Location
$Column5DownPosition += $Column5DownPositionShift


#---------------------------------
# Computer List - View Log Button
#---------------------------------
$LogButton          = New-Object System.Windows.Forms.Button
$LogButton.Name     = "View Log"
$LogButton.Text     = "$($LogButton.Name)"
$LogButton.TabIndex = 5
$LogButton.DataBindings.DefaultDataSourceUpdateMode = 0
$LogButton.UseVisualStyleBackColor = $True
$LogButton.Location = New-Object System.Drawing.Size($Column5RightPosition,$Column5DownPosition)
$LogButton.Size     = New-Object System.Drawing.Size($Column5BoxWidth,$Column5BoxHeight)
$LogButton.add_Click({Start-Process notepad.exe $LogFile})
$Section2ControlTab.Controls.Add($LogButton)


# Shift Row Location
$Column5DownPosition += $Column5DownPositionShift
# Shift Row Location
$Column5DownPosition += $Column5DownPositionShift




##############################################################################################################################################################
##############################################################################################################################################################
##############################################################################################################################################################
##
## Section 3 Bottom Area
##
##############################################################################################################################################################
##############################################################################################################################################################
##############################################################################################################################################################


# Varables to Control Column 6 - Bottom Right Section
$Column6RightPosition     = 475
$Column6DownPosition      = 259
$Column6BoxWidth          = 604
$Column6BoxHeight         = 22
$Column6DownPositionShift = 25
$Column6MainBoxWidth      = 664
$Column6MainBoxHeight     = 240


# Shift Row Location
$Column6DownPosition += $Column6DownPositionShift
$Column6DownPosition += $Column6DownPositionShift


#--------------
# Status Label
#--------------

$StatusLabel           = New-Object System.Windows.Forms.Label
$StatusLabel.Location  = New-Object System.Drawing.Size(($Column6RightPosition - 2),($Column6DownPosition - 1))
$StatusLabel.Size      = New-Object System.Drawing.Size(60,$Column6BoxHeight)
$StatusLabel.Text      = "Status:"
$StatusLabel.Font      = New-Object System.Drawing.Font("$Font",12,1,3,1)
$StatusLabel.ForeColor = "Blue"
$PoShACME.Controls.Add($StatusLabel)  


#----------------
# Status Listbox
#----------------

$StatusListBox          = New-Object System.Windows.Forms.ListBox
$StatusListBox.Name     = "StatusListBox"
$StatusListBox.FormattingEnabled = $True
$StatusListBox.Location = New-Object System.Drawing.Size(($Column6RightPosition + 60),$Column6DownPosition) 
$StatusListBox.Size     = New-Object System.Drawing.Size($Column6BoxWidth,$Column6BoxHeight)
$StatusListBox.DataBindings.DefaultDataSourceUpdateMode = 0
$StatusListBox.TabIndex = 3
$StatusListBox.Items.Add("") | Out-Null
$PoShACME.Controls.Add($StatusListBox)


# Shift Row Location
$Column6DownPosition += $Column6DownPositionShift


# ---------------------
# Progress Bar 1 Lable
#----------------------

$ProgressBar1Label          = New-Object System.Windows.Forms.Label
$ProgressBar1Label.Location = New-Object System.Drawing.Size(($Column6RightPosition),($Column6DownPosition - 6))
$ProgressBar1Label.Size     = New-Object System.Drawing.Size(60,($Column6BoxHeight - 2))
$ProgressBar1Label.Text     = "Section:"
$PoShACME.Controls.Add($ProgressBar1Label)  


#----------------------------
# Progress Bar 1 ProgressBar
#----------------------------

$ProgressBar1          = New-Object System.Windows.Forms.ProgressBar
$ProgressBar1.Style    = "Continuous"
#$ProgressBar1.Maximum  = 10
$ProgressBar1.Minimum  = 0
$ProgressBar1.Location = new-object System.Drawing.Size(($Column6RightPosition + 60),($Column6DownPosition - 2))
$ProgressBar1.size     = new-object System.Drawing.Size($Column6BoxWidth,10)
#$ProgressBar1.Value     = 0
#$ProgressBar1.Step     = 1
$PoSHACME.Controls.Add($ProgressBar1)


# Shift Row Location
$Column6DownPosition += $Column6DownPositionShift - 9


#----------------------
# Progress Bar 2 Lable
#----------------------

$ProgressBar2Label          = New-Object System.Windows.Forms.Label
$ProgressBar2Label.Location = New-Object System.Drawing.Size(($Column6RightPosition),($Column6DownPosition - 2))
$ProgressBar2Label.Size     = New-Object System.Drawing.Size(60,($Column6BoxHeight - 4))
$ProgressBar2Label.Text     = "Overall:"
$PoShACME.Controls.Add($ProgressBar2Label)  


#----------------------------
# Progress Bar 2 ProgressBar
#----------------------------

$ProgressBar2          = New-Object System.Windows.Forms.ProgressBar
$ProgressBar2.Maximum  = $ProgressBar2Max
$ProgressBar2.Minimum  = 0
$ProgressBar2.Location = new-object System.Drawing.Size(($Column6RightPosition + 60),($Column6DownPosition - 2))
$ProgressBar2.size     = new-object System.Drawing.Size($Column6BoxWidth,10)
$ProgressBar2.Count      = 0
$PoSHACME.Controls.Add($ProgressBar2)


# Shift Row Location
$Column6DownPosition += $Column6DownPositionShift - 9


# ===================
# Main Message Box
# ===================
$MainListBox          = New-Object System.Windows.Forms.ListBox
$MainListBox.Name     = "MainListBox"
$MainListBox.FormattingEnabled = $True
$MainListBox.Location = New-Object System.Drawing.Size($Column6RightPosition,$Column6DownPosition) 
$MainListBox.Size     = New-Object System.Drawing.Size($Column6MainBoxWidth,$Column6MainBoxHeight)
$MainListBox.Font     = New-Object System.Drawing.Font("Courier New",8,[System.Drawing.FontStyle]::Regular)
$MainListBox.DataBindings.DefaultDataSourceUpdateMode = 0
$MainListBox.TabIndex = 3
$MainListBox.Items.Add("      ____            _____   __              ___     _____   __   ___  _____ ") | Out-Null
$MainListBox.Items.Add("     / __ \          / ___/  / /             /   |   / ___/  /  | /  / / ___/ ") | Out-Null
$MainListBox.Items.Add("    / / / / _____   / /_    / /_            / /| |  / /     / /||/  / / /_    ") | Out-Null
$MainListBox.Items.Add("   / /_/ / / ___ \  \__ \  / __ \  ______  / /_| | / /     / / |_/ / / __/    ") | Out-Null
$MainListBox.Items.Add("  / ____/ / /__/ / ___/ / / / / / /_____/ / ____ |/ /___  / /   / / / /___    ") | Out-Null
$MainListBox.Items.Add(" /_/      \_____/ /____/ /_/ /_/         /_/   |_|\____/ /_/   /_/ /_____/    ") | Out-Null
$MainListBox.Items.Add("==============================================================================") | Out-Null
$MainListBox.Items.Add(" PowerShell - Automated Collection Made Easy (ACME) For The Security Analyst! ") | Out-Null
$MainListBox.Items.Add(" ACME: The Point At Which Something Is The Best, Perfect, Or Most Successful. ") | Out-Null
$MainListBox.Items.Add("==============================================================================") | Out-Null
$MainListBox.Items.Add(" File Name      : PoSh-ACME.ps1                                               ") | Out-Null
$MainListBox.Items.Add(" Version        : v2.02                                                       ") | Out-Null
$MainListBox.Items.Add(" Author         : high101bro                                                  ") | Out-Null
$MainListBox.Items.Add(" Website        : https://github.com/high101bro/PoSH-ACME                     ") | Out-Null
$MainListBox.Items.Add(" Requirements   : PowerShell v2 or Higher    - Works best with PowerShell v3+ ") | Out-Null
$MainListBox.Items.Add("                : WinRM  (Default Port 5986) - Works best on a domain server  ") | Out-Null
$MainListBox.Items.Add("                : PSExec.exe, Procmon.exe, Autoruns.exe                       ") | Out-Null
$MainListBox.Items.Add("") | Out-Null
$PoShACME.Controls.Add($MainListBox)


# ============================================================================================================================================================
# Compile CSV Files
# ============================================================================================================================================================
function Compile-CsvFiles([string]$LocationOfCSVsToCompile, [string]$LocationToSaveCompiledCSV) {
    # This function compiles the .csv files in the collection directory which outputs in the parent directory
    # The first line (collumn headers) is only copied once from the first file compiled, then skipped for the rest  
    Remove-Item "$LocationToSaveCompiledCSV" -Force

    $getFirstLine = $true
    Get-ChildItem "$LocationOfCSVsToCompile\*.csv" | foreach {
        if ((Get-Content $PSItem).Length -eq 0){
            Remove-Item $PSItem
        }
        else {
            $filePath = $_
            $Lines =  $Lines = Get-Content $filePath  
            $LinesToWrite = switch($getFirstLine) {
                $true  {$Lines}
                $false {$Lines | Select -Skip 1}
            }
            $getFirstLine = $false
            Add-Content -Path "$LocationToSaveCompiledCSV" $LinesToWrite -Force
        }
    }  
}

# ============================================================================================================================================================
# Removes Duplicate CSV Headers
# ============================================================================================================================================================
function Remove-DuplicateCsvHeaders {
    $count = 1
    $output = @()
    $Contents = Get-Content "$PoShLocation\$CollectionName.csv" 
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
}



# ============================================================================================================================================================
# Monitor Jobs of Individual Queries
# ============================================================================================================================================================
function MonitorJobs {
    $ProgressBar1.Value   = 0
    $JobsLaunch = Get-Date
        do {
        Clear-Host

        $myjobs = Get-Job
        #$myjobs | Out-File $env:TEMP\scrapjobs.txt
        #Get-Content $env:TEMP\scrapjobs.txt
        $jobscount = $myjobs.count                  
        $ProgressBar1.Maximum = $jobscount

        $done = 0
        foreach ($job in $myjobs) {
            $mystate = $job.state
            if ($mystate -eq "Completed") {$done = $done +1}
        }
        $ProgressBar1.Value = $done + 1

        $currentTime = Get-Date
        $Timecount = $JobsLaunch - $currentTime
        $Timecount = [math]::Round(($Timecount.TotalMinutes),2)

        #$Message2 = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Completed:  $($ProcessesEnhancedCheckBox.Name)"                
        #$MainListBox.Items.Insert(0,"Jobs Running:  $jobscount")
        $MainListBox.Items.Insert(0,"Jobs Running:  $($jobscount - $done)")        
        #$MainListBox.Items.Insert(1,"Jobs Started:  $jobslaunch")
        $MainListBox.Items.Insert(1,"Current time:  $currentTime")
        $MainListBox.Items.Insert(2,"Elasped time:  $Timecount minutes")
        $MainListBox.Items.Insert(3,"")

        Start-Sleep -Seconds 1
        #$MainListBox.Items.RemoveAt(0)
        #$MainListBox.Items.RemoveAt(0)
        $MainListBox.Items.RemoveAt(0)
        $MainListBox.Items.RemoveAt(0)
        $MainListBox.Items.RemoveAt(0)
        $MainListBox.Items.RemoveAt(0)
    } while ( $done -lt $jobscount)
    
    Get-Job | Remove-Job -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
    $ProgressBar1.Value   = 0
}




# ============================================================================================================================================================
# ============================================================================================================================================================
# CheckBox Script Handler
# ============================================================================================================================================================
# ============================================================================================================================================================
$ExecuteScriptHandler= {
    if (!$TestConnectionsCheckbox.Checked -and `
        !$ARPCacheCheckBox.Checked -and `
        !$AutorunsCheckBox.Checked -and `
        !$BIOSInfoCheckBox.Checked -and `
        !$ComputerInfoCheckBox.Checked -and `
        !$DatesCheckBox.Checked -and `
        !$DiskInfoCheckBox.Checked -and `
        !$DLLsLoadedByProcessesCheckBox.Checked -and `
        !$DNSCacheCheckBox.Checked -and `
        !$DriversDetailedCheckBox.Checked -and `
        !$DriversSignedInfoCheckBox.Checked -and `
        !$DriversValidSignaturesCheckBox.Checked -and `
        !$EnvironmentalVariablesCheckBox.Checked -and `
        !$EventLogsApplicationCheckBox.Checked -and `
        !$EventLogsApplicationErrorsCheckBox.Checked -and `
        !$EventLogsSecurityCheckBox.Checked -and `
        !$EventLogsSystemCheckBox.Checked -and `
        !$EventLogsSystemErrorsCheckBox.Checked -and `
        !$FirewallRulesCheckBox.Checked -and `
        !$FirewallStatusCheckBox.Checked -and `
        !$GroupInfoCheckBox.Checked -and `
        !$LogonInfoCheckBox.Checked -and `
        !$LogonSessionsCheckBox.Checked -and `
        !$LogonUserStatusCheckBox.Checked -and `
        !$MappedDrivesCheckBox.Checked -and `
        !$MemoryCapacityInfoCheckBox.Checked -and `
        !$MemoryPerformanceDataCheckBox.Checked -and `
        !$MemoryPhysicalInfoCheckBox.Checked -and `
        !$MemoryUtilizationCheckBox.Checked -and `
        !$NetworkConnectionsTCPCheckBox.Checked -and `
        !$NetworkConnectionsUDPCheckBox.Checked -and `
        !$NetworkSettingsCheckBox.Checked -and `
        !$NetworkStatisticsIPv4CheckBox.Checked -and `
        !$NetworkStatisticsIPv4TCPCheckBox.Checked -and `
        !$NetworkStatisticsIPv4UDPCheckBox.Checked -and `
        !$NetworkStatisticsIPv4ICMPCheckBox.Checked -and `
        !$NetworkStatisticsIPv6CheckBox.Checked -and `
        !$NetworkStatisticsIPv6TCPCheckBox.Checked -and `
        !$NetworkStatisticsIPv6UDPCheckBox.Checked -and `
        !$NetworkStatisticsIPv6ICMPCheckBox.Checked -and `
        !$PlugAndPlayCheckBox.Checked -and `
        !$PortProxyRulesCheckBox.Checked -and `
        !$PrefetchFilesCheckBox.Checked -and `
        !$ProcessTreeLineageCheckBox.Checked -and `
        !$ProcessesEnhancedCheckBox.Checked -and `
        !$ProcessesStandardCheckBox.Checked -and `
        !$ProcessorCPUInfoCheckBox.Checked -and `
        !$ScheduledTasksCheckBox.Checked -and `
        !$ScreenSaverInfoCheckBox.Checked -and `
        !$ServicesCheckBox.Checked -and `
        !$SecurityPatchesCheckBox.Checked -and `
        !$SharesCheckBox.Checked -and `
        !$SoftwareInstalledCheckBox.Checked -and `
        !$SystemInfoCheckBox.Checked -and `
        !$USBControllerDevicesCheckBox.Checked -and `
        !$HuntTheBadStuffDirectoryListingCheckbox.Checked -and `
        !$HuntTheBadStuffFileSearchCheckbox.Checked -and `
        !$RekallWinPmemMemoryCaptureCheckBox.Checked -and `
        !$SysinternalsAutorunsCheckbox.Checked -and `
        !$SysinternalsProcessMonitorCheckbox.Checked -and `        
        !$ActiveDirectoryAccountDetailsAndUserInfoCheckBox.Checked -and `
        !$ActiveDirectoryAccountLogonAndPassowrdPolicyCheckBox.Checked -and `
        !$ActiveDirectoryAccountContactInfoCheckBox.Checked -and `
        !$ActiveDirectoryAccountEmailAddressesCheckBox.Checked -and `
        !$ActiveDirectoryAccountPhoneNumbersCheckBox.Checked -and `
        !$ActiveDirectoryComputersCheckBox.Checked -and `
        !$ActiveDirectoryDefaultDomainPasswordPolicyCheckBox.Checked -and `
        !$ActiveDirectoryGroupsCheckBox.Checked -and `
        !$ActiveDirectoryGroupMembershipByGroupsCheckBox.Checked -and `
        !$ActiveDirectoryGroupMembershipByUsersCheckBox.Checked -and `
        !$ActiveDirectoryGroupsWithoutAccountMembersCheckBox.Checked -and `
        !$DNSAllRecordsServer2008CheckBox.Checked -and `
        !$DomainDNSAllRecordsServer2008CheckBox.Checked -and `
        !$DomainDNSRootHintsServer2008CheckBox.Checked -and `
        !$DomainDNSZonesServer2008CheckBox.Checked -and `
        !$DomainDNSStatisticsServer2008CheckBox.Checked ) {

        $MainListBox.Items.Clear()
        $MainListBox.Items.Insert(0,"Error: No Collection CheckBoxes Were Selected...")
        $MainListBox.Items.Insert(0,"")
        $MainListBox.Items.Insert(0,"...Let me get this straight... You want me to collect nothing?")
        #$PoShACME.Close()
    }
    elseif ($ComputerList -eq "") {
        $MainListBox.Items.Clear()
        $MainListBox.Items.Insert(0,"Error: Select Computers To Collect Data From...")
        $MainListBox.Items.Insert(0,"")
        $MainListBox.Items.Insert(0,"...Whoa now, slow down turbo... Make sure you select hosts to collect from...")        
    }
    else {
        $MainListBox.Items.Clear();
        $CollectionTimerStart = Get-Date
        $MainListBox.Items.Insert(0,"$(($CollectionTimerStart).ToString('yyyy/MM/dd HH:mm:ss')) - Collection Start Time")    
        $MainListBox.Items.Insert(0,"")
 
        # Runs the Commands
        if ($TestConnectionsCheckbox.Checked){TestConnectionsCheckbox ; $ProgressBar2.Value = $ProgressBar2Count ;  $ProgressBar2Count += 1}

        if ($ARPCacheCheckBox.Checked){ARPCacheCommand}
        if ($AutorunsCheckBox.Checked){AutorunsCommand}
        if ($BIOSInfoCheckBox.Checked){BIOSInfoCommand}
        if ($ComputerInfoCheckBox.Checked){ComputerInfoCommand}
        if ($DatesCheckBox.Checked){DatesCommand}
        if ($DiskInfoCheckBox.Checked){DiskInfoCommand}
        if ($DNSCacheCheckBox.Checked){DNSCacheCommand}
        if ($DLLsLoadedByProcessesCheckBox.Checked){DLLsLoadedByProcessesCommand}
        if ($DriversDetailedCheckBox.Checked){DriversDetailedCommand}
        if ($DriversSignedInfoCheckBox.Checked){DriversSignedCommand}
        if ($DriversValidSignaturesCheckBox.Checked){DriversValidSignaturesCommand}
        if ($EnvironmentalVariablesCheckBox.Checked){EnvironmentalVariablesCommand}
        if ($EventLogsApplicationCheckBox.Checked){EventLogsApplicationCommand}
        if ($EventLogsApplicationErrorsCheckBox.Checked){EventLogsApplicationErrorsCommand}
        if ($EventLogsSecurityCheckBox.Checked){EventLogsSecurityCommand}
        if ($EventLogsSystemCheckBox.Checked){EventLogsSystemCommand}
        if ($EventLogsSystemErrorsCheckBox.Checked){EventLogsSystemErrorsCommand}
        if ($FirewallRulesCheckBox.Checked){FirewallRulesCommand}
        if ($FirewallStatusCheckBox.Checked){FirewallStatusCommand}
        if ($GroupInfoCheckBox.Checked){GroupInfoCommand}
        if ($LogonInfoCheckBox.Checked){LogonInfoCommand}
        if ($LogonSessionsCheckBox.Checked){LogonSessionsCommand}
        if ($LogonUserStatusCheckBox.Checked){LogonUserStatusCommand}
        if ($MappedDrivesCheckBox.Checked){MappedDrivesCommand}
        if ($MemoryCapacityInfoCheckBox.Checked){MemoryCapacityInfoCommand}
        if ($MemoryPerformanceDataCheckBox.Checked){MemoryPerformanceDataCommand}
        if ($MemoryPhysicalInfoCheckBox.Checked){MemoryPhysicalInfoCommand}
        if ($MemoryUtilizationCheckBox.Checked){MemoryUtilizationCommand}
        if ($NetworkConnectionsTCPCheckBox.Checked){NetworkConnectionsTCPCommand}
        if ($NetworkConnectionsUDPCheckBox.Checked){NetworkConnectionsUDPCommand}
        if ($NetworkSettingsCheckBox.Checked){NetworkSettingsCommand}
        if ($NetworkStatisticsIPv4CheckBox.Checked){NetworkStatisticsIPv4Command}
        if ($NetworkStatisticsIPv4TCPCheckBox.Checked){NetworkStatisticsIPv4TCPCommand}
        if ($NetworkStatisticsIPv4UDPCheckBox.Checked){NetworkStatisticsIPv4UDPCommand}
        if ($NetworkStatisticsIPv4ICMPCheckBox.Checked){NetworkStatisticsIPv4ICMPCommand}
        if ($NetworkStatisticsIPv6CheckBox.Checked){NetworkStatisticsIPv6Command}
        if ($NetworkStatisticsIPv6TCPCheckBox.Checked){NetworkStatisticsIPv6TCPCommand}
        if ($NetworkStatisticsIPv6UDPCheckBox.Checked){NetworkStatisticsIPv6UDPCommand}
        if ($NetworkStatisticsIPv6ICMPCheckBox.Checked){NetworkStatisticsIPv6ICMPCommand}
        if ($PlugAndPlayCheckBox.Checked){PlugAndPlayCommand}
        if ($PortProxyRulesCheckBox.Checked){PortProxyRulesCommand}
        if ($PrefetchFilesCheckBox.Checked){PrefetchFilesCommand}
        if ($ProcessTreeLineageCheckBox.Checked){ProcessTreeLineageCommand}
        if ($ProcessesEnhancedCheckBox.Checked){ProcessesEnhancedCommand}
        if ($ProcessesStandardCheckBox.Checked){ProcessesStandardCommand}
        if ($ProcessorCPUInfoCheckBox.Checked){ProcessorCPUInfoCommand}
        if ($ScheduledTasksCheckBox.Checked){ScheduledTasksCommand}
        if ($ScreenSaverInfoCheckBox.Checked){ScreenSaverInfoCommand}
        if ($SecurityPatchesCheckBox.Checked){SecurityPatchesCommand}
        if ($ServicesCheckBox.Checked){ServicesCommand}
        if ($SharesCheckBox.Checked){SharesCommand}
        if ($SoftwareInstalledCheckBox.Checked){SoftwareInstalledCommand}
        if ($SystemInfoCheckBox.Checked){SystemInfoCommand}
        if ($USBControllerDevicesCheckBox.Checked){USBControllerDevicesCommand}       
        if ($HuntTheBadStuffDirectoryListingCheckbox.Checked) {HuntTheBadStuffDirectoryListingCommand}
        if ($HuntTheBadStuffFileSearchCheckbox.Checked){HuntTheBadStuffFileSearchCommand}
        if ($RekallWinPmemMemoryCaptureCheckbox.Checked){RekallWinPmemMemoryCaptureCommand}
        if ($SysinternalsAutorunsCheckbox.Checked){SysinternalsAutorunsCommand}
        if ($SysinternalsProcessMonitorCheckbox.Checked){SysinternalsProcessMonitorCommand}
        if ($ActiveDirectoryCheckbox.Checked){ActiveDirectoryCommand}
        if ($ActiveDirectoryAccountDetailsAndUserInfoCheckbox.Checked){ActiveDirectoryAccountDetailsAndUserInfoCommand}
        if ($ActiveDirectoryAccountLogonAndPassowrdPolicyCheckbox.Checked){ActiveDirectoryAccountLogonAndPassowrdPolicyCommand}
        if ($ActiveDirectoryAccountContactInfoCheckbox.Checked){ActiveDirectoryAccountContactInfoCommand}
        if ($ActiveDirectoryAccountEmailAddressesCheckbox.Checked){ActiveDirectoryAccountEmailAddressesCommand}
        if ($ActiveDirectoryAccountPhoneNumbersCheckbox.Checked){ActiveDirectoryAccountPhoneNumbersCommand}
        if ($ActiveDirectoryComputersCheckbox.Checked){ActiveDirectoryComputersCommand}
        if ($ActiveDirectoryDefaultDomainPasswordPolicyCheckbox.Checked){ActiveDirectoryDefaultDomainPasswordPolicyCommand}
        if ($ActiveDirectoryGroupsCheckbox.Checked){ActiveDirectoryGroupsCommand}
        if ($ActiveDirectoryGroupMembershipByGroupsCheckbox.Checked){ActiveDirectoryGroupMembershipByGroupsCommand}
        if ($ActiveDirectoryGroupMembershipByUsersCheckbox.Checked){ActiveDirectoryGroupMembershipByUsersCommand}
        if ($ActiveDirectoryGroupsWithoutAccountMembersCheckbox.Checked){ActiveDirectoryGroupsWithoutAccountMembersCommand}
        if ($DNSAllRecordsServer2008Checkbox.Checked){DNSAllRecordsServer2008Command}
        if ($DomainDNSAllRecordsServer2008Checkbox.Checked){DomainDNSAllRecordsServer2008Command}
        if ($DomainDNSRootHintsServer2008Checkbox.Checked){DomainDNSRootHintsServer2008Command}
        if ($DomainDNSZonesServer2008Checkbox.Checked){DomainDNSZonesServer2008Command}
        if ($DomainDNSStatisticsServer2008Checkbox.Checked){DomainDNSStatisticsServer2008Command}

        $CollectionTimerStop = Get-Date
        $MainListBox.Items.Insert(0,"$(($CollectionTimerStop).ToString('yyyy/MM/dd HH:mm:ss')) - Finished Collecting Data!")

        $CollectionTime      = New-TimeSpan -Start $CollectionTimerStart -End $CollectionTimerStop
        $MainListBox.Items.Insert(1,"   $CollectionTime - Total Elapsed Time")
        $MainListBox.Items.Insert(2,"====================================================================================================")
        $MainListBox.Items.Insert(3,"")        

        #-----------------------------
        # Plays a Sound When Finished
        #-----------------------------
        [system.media.systemsounds]::Exclamation.play()
    }
}
# This needs to be here to execute the script
# Note the Execution button itself is located in the Select Computer section
$ComputerListExecuteButton.add_Click($ExecuteScriptHandler)


#Save the initial state of the form
$InitialFormWindowState = $PoShACME.WindowState

#Init the OnLoad event to correct the initial state of the form
$PoShACME.add_Load($OnLoadForm_StateCorrection)

#Show the Form
$PoShACME.ShowDialog()| Out-Null

} #End Function

#Call the Function
PoSh-ACME_GUI
