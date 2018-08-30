# https://michlstechblog.info/blog/powershell-show-a-messagebox/
# Get-WmiObject -Class Win32_Desktop
# Get-WmiObject -Class Win32_Processor 
# Win32_LogonSession 
# Win32_LocalTime 
# query user
# arp -a      arp -av
# ipconfig /displaydns
# $PSVersionTable
#"C:\Windows\System32\drivers\etc\hosts"
# Run a command on a remote computer
#     Invoke-Command -ComputerName localhost -ScriptBlock { get-process } -credential domain\administrator
#     PSv6 SSH remote code execution:   Invoke-Command -HostName LinuxServer01 -UserName UserA -ScriptBlock { Get-MailBox * }


<#If you’re on a home network where you want to go ahead and trust any PC to connect remotely, you can type the following cmdlet in PowerShell (again, you’ll need to run it as Administrator).
Set-Item wsman:\localhost\client\trustedhosts *#>


# Check if the script is running with Administrator Privlieges, if not it will attempt to re-run and prompt for credentials
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic")
    $verify = [Microsoft.VisualBasic.Interaction]::MsgBox(`
        "Attention Under-Privileged User!`n   $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)`n`nThis sciprt requires Administrator privileges in order to remotely collect data corretcly! Otherwise, the script-up will start and may not collect data as expected.",`
        'YesNoCancel,Question',`
        "PoSH-ACME")
    switch ($verify) {
    'Yes'{
        $arguments = "& '" + $myinvocation.mycommand.definition + "'"
        Start-Process powershell -WindowStyle Hidden -Verb runAs -ArgumentList $arguments
    }
    'No'     {break}
    'Cancel' {exit}
    }
}


# ============================================================================================================================================================
# Variables
# ============================================================================================================================================================

# Universally sets the ErrorActionPreference to Silently Continue
$ErrorActionPreference = "SilentlyContinue"
    
# Location PoSh-ACME will save files
$PoShHome = "C:\$env:HOMEPATH\Desktop\PoSh-ACME Results"
$global:PoShLocation = "$PoShHome\$((Get-Date).ToString('yyyy-MM-dd @ HHmm ss'))"
    
# Location of Uncompiled Results
$CollectedResultsUncompiled = "Collected Results (Uncompiled)"

# Locaiton of Log File
$LogFile = "$PoShHome\PoSH-ACME Log.txt"

# Logs what account ran the script and when
$LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - PoSh-ACME executed by: $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"
$LogMessage | Add-Content -Path $LogFile

# This deleay is introduced to allow certain collection commands to complete gathering data before it pulls back the data
# Specificially in instances where Invoke-WmiMethod is being used to execute DOS or native commands on remote hosts and needs to finish
# Increase this Start-Sleep variable in the event you determine that not all data is being pulled back as the copy command can pull back incomplete results
$SleepTime = 5

# Clears out Computer List variable
$ComputerList = ""



# ============================================================================================================================================================
# Create Directory
# ============================================================================================================================================================
New-Item -ItemType Directory -Path "$PoShHome" -Force | Out-Null 



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
# ============================================================================================================================================================
# ============================================================================================================================================================
# ============================================================================================================================================================

function PoSh_ACME_GUI {

[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null

$PoShACME = New-Object System.Windows.Forms.Form
$InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState

#Mark
#$PoShACME.Topmost = $true


#$b1= $false
#$b2= $false
#$b3= $false


$OnLoadForm_StateCorrection=
{ #Correct the initial state of the form to prevent the .Net maximized form issue
    $PoShACME.WindowState = $InitialFormWindowState
}


# ============================================================================================================================================================
# This is the overall window for PoSh-ACME
# ============================================================================================================================================================
$PoShACME.Text = "PoSh-ACME   [$([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)]"
$PoShACME.Name = "PoSh-ACME"
$PoShACME.DataBindings.DefaultDataSourceUpdateMode = 0
$PoShACME.Location = New-Object System.Drawing.Size(10,10) 
$PoShACME.Size     = New-Object System.Drawing.Size(1150,649) 
$PoShACME.ClientSize = $System_Drawing_Size



# ============================================================================================================================================================
# ============================================================================================================================================================
# Column 1 - Checkboxes and Buttons for commands
# ============================================================================================================================================================
# ============================================================================================================================================================

# Varables to Control Column 1
$Column4RightAlignment   = 5
$Column4RowLocation      = -10
$Column4BoxWidth         = 230
$Column4BoxHeight        = 25
$Column4RowLocationShift = 22


# Shift the fields
$Column4RowLocation += $Column4RowLocationShift


# creates the label
$QueryLabel           = New-Object System.Windows.Forms.Label
$QueryLabel.Location  = New-Object System.Drawing.Size($Column4RightAlignment,$Column4RowLocation) 
$QueryLabel.Size      = New-Object System.Drawing.Size($Column4BoxWidth,$Column4BoxHeight) 
$QueryLabel.Text      = "Quick Options"
#$QueryLabel.Font     = [System.Drawing.Font]::new("Microsoft Sans Serif", 10, [System.Drawing.FontStyle]::Bold)
$QueryLabel.Font      = "Microsoft Sans Serif,12"
$QueryLabel.ForeColor = "Blue"
$PoShACME.Controls.Add($QueryLabel)  # Shift the Text and Button's Locaiton


# Shift the fields
$Column4RowLocation += $Column4RowLocationShift


# Hunt the Bad Stuff
$HuntCheckBox          = New-Object System.Windows.Forms.Checkbox
$HuntCheckBox.Name     = "Hunt the Bad Stuff"
$HuntCheckBox.Text     = "$($HuntCheckBox.Name)"
$HuntCheckBox.TabIndex = 2
$HuntCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$HuntCheckBox.Location = New-Object System.Drawing.Size($Column4RightAlignment,$Column4RowLocation)
$HuntCheckBox.Size     = New-Object System.Drawing.Size(160,$Column4BoxHeight)
$HuntCheckBox.Add_Click({
    If ($HuntCheckBox.Checked -eq $true){
        $ClearCheckBox.Checked           = $false
        $SurveyCheckBox.Checked          = $false
        $TestConnectionsCheckbox.Checked = $false
        $CheckBoxNum00.Checked = $true
        $CheckBoxNum02.Checked = $true
        $CheckBoxNum03.Checked = $true
        $CheckBoxNum04.Checked = $true
    }
})
$PoShACME.Controls.Add($HuntCheckbox)

# Survey / Baseline
$SurveyCheckBox          = New-Object System.Windows.Forms.Checkbox
$SurveyCheckBox.Name     = "Survey (All)"
$SurveyCheckBox.Text     = "$($SurveyCheckBox.Name)"
$SurveyCheckBox.TabIndex = 2
$SurveyCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$SurveyCheckBox.Location = New-Object System.Drawing.Size(($Column4RightAlignment + 160),$Column4RowLocation)
$SurveyCheckBox.Size     = New-Object System.Drawing.Size(100,$Column4BoxHeight)
$SurveyCheckBox.Add_Click({
    If ($SurveyCheckBox.Checked -eq $true){
        $ClearCheckBox.Checked           = $false
        $HuntCheckBox.Checked            = $false
        $TestConnectionsCheckbox.Checked = $true
        $CheckBoxNum00.Checked           = $true
        $CheckBoxNum01.Checked           = $true
        $CheckBoxNum02.Checked           = $true
        $CheckBoxNum03.Checked           = $true
        $CheckBoxNum04.Checked           = $true
        $CheckBoxNum05.Checked           = $true
        $CheckBoxNum06.Checked           = $true
        $CheckBoxNum07.Checked           = $true
        $CheckBoxNum08.Checked           = $true
        $CheckBoxNum09.Checked           = $true
        $CheckBoxNum10.Checked           = $true
        $CheckBoxNum11.Checked           = $true
        $CheckBoxNum12.Checked           = $true
        $CheckBoxNum13.Checked           = $true
        $CheckBoxNum14.Checked           = $true
        $CheckBoxNum15.Checked           = $true
        $CheckBoxNum16.Checked           = $true
        $CheckBoxNum17.Checked           = $true
        $CheckBoxNum18.Checked           = $true
        $CheckBoxNum19.Checked           = $true
        $CheckBoxNum20.Checked           = $true
        $CheckBoxNum21.Checked           = $true
        $CheckBoxNum22.Checked           = $true
        $CheckBoxNum23.Checked           = $true
        $CheckBoxNum24.Checked           = $true
        $CheckBoxNum25.Checked           = $true
        $CheckBoxNum26.Checked           = $true
        $CheckBoxNum27.Checked           = $true
        $CheckBoxNum28.Checked           = $true
        $CheckBoxNum29.Checked           = $true
        $CheckBoxNum30.Checked           = $true
        $CheckBoxNum31.Checked           = $true
        $CheckBoxNum32.Checked           = $true
        $CheckBoxNum33.Checked           = $true
        $CheckBoxNum34.Checked           = $true
        $CheckBoxNum35.Checked           = $true
        $CheckBoxNum36.Checked           = $true
        $CheckBoxNum37.Checked           = $true
        $CheckBoxNum38.Checked           = $true
        $CheckBoxNum39.Checked           = $true
        $CheckBoxNum40.Checked           = $true
        $CheckBoxNum41.Checked           = $true
    }
})
$PoShACME.Controls.Add($SurveyCheckBox)

# Clear All Sections
$ClearCheckBox          = New-Object System.Windows.Forms.Checkbox
$ClearCheckBox.Name     = "Clear"
$ClearCheckBox.Text     = "$($ClearCheckBox.Name)"
$ClearCheckBox.TabIndex = 2
$ClearCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$ClearCheckBox.Location = New-Object System.Drawing.Size(($Column4RightAlignment + 300),$Column4RowLocation)
$ClearCheckBox.Size     = New-Object System.Drawing.Size(80,$Column4BoxHeight)
$ClearCheckBox.Add_Click({
    If ($ClearCheckBox.Checked -eq $true){
        $HuntCheckBox.Checked            = $false
        $SurveyCheckBox.Checked          = $false
        $TestConnectionsCheckbox.Checked = $false
        $CheckBoxNum00.Checked           = $false
        $CheckBoxNum01.Checked           = $false
        $CheckBoxNum02.Checked           = $false
        $CheckBoxNum03.Checked           = $false
        $CheckBoxNum04.Checked           = $false
        $CheckBoxNum05.Checked           = $false
        $CheckBoxNum06.Checked           = $false
        $CheckBoxNum07.Checked           = $false
        $CheckBoxNum08.Checked           = $false
        $CheckBoxNum09.Checked           = $false
        $CheckBoxNum10.Checked           = $false
        $CheckBoxNum11.Checked           = $false
        $CheckBoxNum12.Checked           = $false
        $CheckBoxNum13.Checked           = $false
        $CheckBoxNum14.Checked           = $false
        $CheckBoxNum15.Checked           = $false
        $CheckBoxNum16.Checked           = $false
        $CheckBoxNum17.Checked           = $false
        $CheckBoxNum18.Checked           = $false
        $CheckBoxNum19.Checked           = $false
        $CheckBoxNum20.Checked           = $false
        $CheckBoxNum21.Checked           = $false
        $CheckBoxNum22.Checked           = $false
        $CheckBoxNum23.Checked           = $false
        $CheckBoxNum24.Checked           = $false
        $CheckBoxNum25.Checked           = $false
        $CheckBoxNum26.Checked           = $false
        $CheckBoxNum27.Checked           = $false
        $CheckBoxNum28.Checked           = $false
        $CheckBoxNum29.Checked           = $false
        $CheckBoxNum30.Checked           = $false
        $CheckBoxNum31.Checked           = $false
        $CheckBoxNum32.Checked           = $false
        $CheckBoxNum33.Checked           = $false
        $CheckBoxNum34.Checked           = $false
        $CheckBoxNum35.Checked           = $false
        $CheckBoxNum36.Checked           = $false
        $CheckBoxNum37.Checked           = $false
        $CheckBoxNum38.Checked           = $false
        $CheckBoxNum39.Checked           = $false
        $CheckBoxNum40.Checked           = $false
        $CheckBoxNum41.Checked           = $false    }
})
$PoShACME.Controls.Add($ClearCheckBox)


# Shift the Text and Button's Locaiton
$Column4RowLocation   += $Column4RowLocationShift
$Column4RowLocation += $Column4RowLocationShift


# creates the label
$QueryLabel           = New-Object System.Windows.Forms.Label
$QueryLabel.Location  = New-Object System.Drawing.Size($Column4RightAlignment,$Column4RowLocation) 
$QueryLabel.Size      = New-Object System.Drawing.Size(300,$Column4BoxHeight) 
$QueryLabel.Text      = "Select Information To Collect:"
#$QueryLabel.Font     = [System.Drawing.Font]::new("Microsoft Sans Serif", 10, [System.Drawing.FontStyle]::Bold)
$QueryLabel.Font      = "Microsoft Sans Serif,12"
$QueryLabel.ForeColor = "Blue"
$PoShACME.Controls.Add($QueryLabel)  # Shift the Text and Button's Locaiton


$Column4RowLocation   += $Column4RowLocationShift


# ============================================================================================================================================================
# Tests connection to remote hosts and removes them if unable to pull data
# ============================================================================================================================================================

# Command CheckBox and Text
$TestConnectionsCheckbox      = New-Object System.Windows.Forms.CheckBox
$TestConnectionsCheckbox.Name = "Test Connections First"
function TestConnectionsCheckbox {
    foreach ($TargetComputer in $ComputerList) {
        $Message1    = "Testing Connection with $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage | Add-Content -Path $LogFile

        try {
            Get-WmiObject -Class Win32_computersystem -ComputerName $TargetComputer -ErrorAction Stop | Out-Null
            #$CheckWinRM = Get-Service -ComputerName $TargetComputer | Where-Object {$_.Name -eq "WinRM"} | Select-Object -Property Status -ExpandProperty Status
            #if ($CheckWinRM -ne "Running") {Write-Host "action taken"}
        }
        catch [System.Runtime.InteropServices.COMException],[System.UnauthorizedAccessException] { 
            #Write-Host "$($Error[0])" -ForegroundColor Red    
            $Message1 = "Unable to Collect from host! Remove computer from list: $TargetComputer"
            $MainListBox.Items.Insert(0,$Message1)
            $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
            $LogMessage | Add-Content -Path $LogFile
            
            # Removes $TargetComputer from $global:ComputerList if it fails to connect
            $global:ComputerList = $ComputerList | Where-Object { $_ -ne "$TargetComputer" }
            $global:ComputerListNotCollected +=  $TargetComputer
        }
        catch { 
            ### The following $Error line helps identify the specific exception to catch!
            # $Error[0].Exception.GetType().FullName    
            #Write-Host "NO:  $TargetComputer" 
            $Error[0].Exception.GetType().FullName
            $Message1 = "What is this error? $($Error[0])"
            $MainListBox.Items.Insert(0,$Message1)
            $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
            $LogMessage | Add-Content -Path $LogFile 
        }
    }
    $Message2 = "Completed: $($TestConnectionsCheckbox.Name)"
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)


    # Outputs a List of all the Computers initially provided
    $global:ComputerList | Out-File "$PoShLocation\~Computer List - Original List.txt"

    # Outputs a List of all the Computers that will not be collected from
    $global:ComputerListNotCollected | Out-File "$PoShLocation\~Computer List - Not Collected.txt"

    # Outputs a List of all the Computers to Collect From
    $global:ComputerList | Out-File "$PoShLocation\~Computer List - Collected From.txt"
}
$TestConnectionsCheckbox.Text     = "$($TestConnectionsCheckbox.Name)"
$TestConnectionsCheckbox.TabIndex = 2
$TestConnectionsCheckbox.DataBindings.DefaultDataSourceUpdateMode = 0
$TestConnectionsCheckbox.Location = New-Object System.Drawing.Size($Column4RightAlignment,$Column4RowLocation) 
$TestConnectionsCheckbox.Size     = New-Object System.Drawing.Size($Column4BoxWidth,$Column4BoxHeight) 
$PoShACME.Controls.Add($TestConnectionsCheckbox)



# ============================================================================================================================================================
# Processes (Advanced with Hashes)
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column4RowLocation   += $Column4RowLocationShift



# Command CheckBox and Text
$CheckBoxNum01 = New-Object System.Windows.Forms.CheckBox
$CheckBoxNum01.Name = "Processes (Advanced)"
function CommandNum01 {
    foreach ($TargetComputer in $ComputerList) {
        $CollectionName      = "$($CheckBoxNum01.Name)"
        $CollectionDirectory = $CollectionName
        $Message1            = "Collecting: $($CheckBoxNum01.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null
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
        Get-Processes | Select-Object -Property PSComputerName, Name, ProcessID, ParentProcessName, ParentProcessId, MemoryKiloBytes, CommandLine, PathName, Hash, Algorithm, CreationDate, Owner, OwnerSID, SessionId | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName - $TargetComputer.csv" -NoTypeInformation
        }

    $Message2 = "Completed: $($CheckBoxNum01.Name)"
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
# Command Checkbox
$CheckBoxNum01.Text     = "$($CheckBoxNum01.Name)"
$CheckBoxNum01.TabIndex = 2
$CheckBoxNum01.DataBindings.DefaultDataSourceUpdateMode = 0
$CheckBoxNum01.Location = New-Object System.Drawing.Size($Column4RightAlignment,$Column4RowLocation) 
$CheckBoxNum01.Size     = New-Object System.Drawing.Size($Column4BoxWidth,$Column4BoxHeight) 
# Populates to PoSH-ACME GUI
$PoShACME.Controls.Add($CheckBoxNum01)



# ============================================================================================================================================================
# Processes (Basic)
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column4RowLocation   += $Column4RowLocationShift


# Command CheckBox and Text
$CheckBoxNum00 = New-Object System.Windows.Forms.CheckBox
$CheckBoxNum00.Name = "Processes (Basic)"
function CommandNum00 {
    foreach ($TargetComputer in $ComputerList) {
        $CollectionName      = "$($CheckBoxNum00.Name)"
        $CollectionDirectory = $CollectionName
        $Message1            = "Collecting: $($CheckBoxNum00.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null
        Get-WmiObject -Class Win32_Process -ComputerName $TargetComputer `
        | Select-Object -Property PSComputerName, Name, ProcessID, ParentProcessID, Path, WorkingSetSize, Handle, HandleCount, ThreadCount, CreationDate `
        | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName - $TargetComputer.csv" -NoTypeInformation
    }

    $Message2 = "Completed: $($CheckBoxNum00.Name)"
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
# Command Checkbox
$CheckBoxNum00.Text     = "$($CheckBoxNum00.Name)"
$CheckBoxNum00.TabIndex = 2
$CheckBoxNum00.DataBindings.DefaultDataSourceUpdateMode = 0
$CheckBoxNum00.Location = New-Object System.Drawing.Size($Column4RightAlignment,$Column4RowLocation) 
$CheckBoxNum00.Size     = New-Object System.Drawing.Size($Column4BoxWidth,$Column4BoxHeight) 
# Populates to PoSH-ACME GUI
$PoShACME.Controls.Add($CheckBoxNum00)



# ============================================================================================================================================================
# Services
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column4RowLocation   += $Column4RowLocationShift



# Command CheckBox and Text
$CheckBoxNum02 = New-Object System.Windows.Forms.CheckBox
$CheckBoxNum02.Name = "Services"
function CommandNum02 {
    foreach ($TargetComputer in $ComputerList) {
        $CollectionName      = "$($CheckBoxNum02.Name)"
        $CollectionDirectory = $CollectionName
        $Message1            = "Collecting: $($CheckBoxNum02.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null
        Get-WmiObject -Class Win32_Service -ComputerName $TargetComputer `
        | Select-Object PSComputerName, State, Name, ProcessID, Description, PathName, Started, StartMode, StartName | Sort-Object PSComputerName, State, Name `
        | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName - $TargetComputer.csv" -NoTypeInformation
    }

    $Message2 = "Completed: $($CheckBoxNum02.Name)"
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
# Command Checkbox
$CheckBoxNum02.Text             = "$($CheckBoxNum02.Name)"
$CheckBoxNum02.TabIndex         = 2
$CheckBoxNum02.DataBindings.DefaultDataSourceUpdateMode = 0
$CheckBoxNum02.Location = New-Object System.Drawing.Size($Column4RightAlignment,$Column4RowLocation) 
$CheckBoxNum02.Size     = New-Object System.Drawing.Size($Column4BoxWidth,$Column4BoxHeight) 
# Populates to PoSH-ACME GUI
$PoShACME.Controls.Add($CheckBoxNum02)



# ============================================================================================================================================================
# Network Connections TCP
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column4RowLocation   += $Column4RowLocationShift


# Command Text and CheckBox
$CheckBoxNum03 = New-Object System.Windows.Forms.CheckBox
$CheckBoxNum03.Name = "Network Connections TCP"
function CommandNum03 {
    foreach ($TargetComputer in $ComputerList) {
        $CollectionName      = "$($CheckBoxNum03.Name)"
        $CollectionDirectory = $CollectionName
        $Message1            = "Collecting: $($CheckBoxNum03.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null
        Invoke-WmiMethod -Class Win32_Process -Name Create -ComputerName $TargetComputer -ArgumentList "cmd /c netstat -anob -p tcp > c:\netstat-$TargetComputer.txt" | Out-Null
    
        # This deleay is introduced to allow the collection command to complete gathering data before it pulls back the data
        Start-Sleep -Seconds $SleepTime
        Copy-Item   "\\$TargetComputer\c$\netstat-$TargetComputer.txt" "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory"
        Remove-Item "\\$TargetComputer\c$\netstat-$TargetComputer.txt"

        # Processes collection to format it from txt to csv
        $Connections = Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\netstat-$TargetComputer.txt" | Select-Object -skip 3
        $TCPdata = @()
        $Connections.trim()  | Out-String | ForEach-Object {$TCPdata += $_ -replace "`r`n",";;" -replace ";;;;",";;" -creplace ";;TCP","`r`nTCP" -replace ";;","  " -replace " {2,}","," -creplace "PID","PID,Executed Process" -replace "^,|,$",""}
        $format = $TCPdata -split "`r`n"
        $TCPnetstat =@()
        # This section combines two specific csv fields together for easier viewing
        foreach ($line in $format) {
            if ($line -match "\d,\[") {$TCPnetstat += $line}
            if ($line -notmatch "\d,\[") {$TCPnetstat += $line -replace ",\["," ["}
        }
        $TCPnetstat | Out-File "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"

        # Add PSComputerName header and host/ip name
        $AddTargetHost = (Import-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv")
        $AddTargetHost | Add-Member -MemberType NoteProperty "PSComputerName" -Value "$TargetComputer"
        $AddTargetHost | Select-Object -Property PSComputerName, * | Export-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation
    }

    $Message2 = "Completed: $($CheckBoxNum03.Name)"
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
# Command Checkbox
$CheckBoxNum03.Text             = "$($CheckBoxNum03.Name)"
$CheckBoxNum03.TabIndex         = 2
$CheckBoxNum03.DataBindings.DefaultDataSourceUpdateMode = 0
$CheckBoxNum03.Location = New-Object System.Drawing.Size($Column4RightAlignment,$Column4RowLocation) 
$CheckBoxNum03.Size     = New-Object System.Drawing.Size($Column4BoxWidth,$Column4BoxHeight) 
# Populates to PoSH-ACME GUI
$PoShACME.Controls.Add($CheckBoxNum03)



# ============================================================================================================================================================
# Network Connections UDP
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column4RowLocation   += $Column4RowLocationShift



# Command CheckBox and Text
$CheckBoxNum04 = New-Object System.Windows.Forms.CheckBox
$CheckBoxNum04.Name = "Network Connections UDP"
function CommandNum04 {
    foreach ($TargetComputer in $ComputerList) {
        $CollectionName      = "$($CheckBoxNum04.Name)"
        $CollectionDirectory = $CollectionName
        $Message1            = "Collecting: $($CheckBoxNum04.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null
        Invoke-WmiMethod -Class Win32_Process -Name Create -ComputerName $TargetComputer -ArgumentList "cmd /c netstat -anob -p udp > c:\netstat-$TargetComputer.txt" | Out-Null
    
        # This deleay is introduced to allow the collection command to complete gathering data before it pulls back the data
        Start-Sleep -Seconds $SleepTime
        Copy-Item   "\\$TargetComputer\c$\netstat-$TargetComputer.txt" "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory"
        Remove-Item "\\$TargetComputer\c$\netstat-$TargetComputer.txt"

        # Processes collection to format it from txt to csv
        $Connections = Get-Content "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\netstat-$TargetComputer.txt" | Select-Object -skip 3
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

    $Message2 = "Completed: $($CheckBoxNum04.Name)"
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
# Command Checkbox
$CheckBoxNum04.Text     = "$($CheckBoxNum04.Name)"
$CheckBoxNum04.TabIndex = 2
$CheckBoxNum04.DataBindings.DefaultDataSourceUpdateMode = 0
$CheckBoxNum04.Location = New-Object System.Drawing.Size($Column4RightAlignment,$Column4RowLocation) 
$CheckBoxNum04.Size     = New-Object System.Drawing.Size($Column4BoxWidth,$Column4BoxHeight) 
# Populates to PoSH-ACME GUI
$PoShACME.Controls.Add($CheckBoxNum04)



# ============================================================================================================================================================
# Netowrk Settings
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column4RowLocation   += $Column4RowLocationShift


# Command CheckBox and Text
$CheckBoxNum05 = New-Object System.Windows.Forms.CheckBox
$CheckBoxNum05.Name = "Network Settings"
function CommandNum05 {
    foreach ($TargetComputer in $ComputerList) {
        $CollectionName      = "$($CheckBoxNum05.Name)"
        $CollectionDirectory = $CollectionName
        $Message1            = "Collecting: $($CheckBoxNum05.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null
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
            | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName - $TargetComputer.csv" -NoTypeInformation
    }

    $Message2 = "Completed: $($CheckBoxNum05.Name)"
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
# Command Checkbox
$CheckBoxNum05.Text     = "$($CheckBoxNum05.Name)"
$CheckBoxNum05.TabIndex = 2
$CheckBoxNum05.DataBindings.DefaultDataSourceUpdateMode = 0
$CheckBoxNum05.Location = New-Object System.Drawing.Size($Column4RightAlignment,$Column4RowLocation) 
$CheckBoxNum05.Size     = New-Object System.Drawing.Size($Column4BoxWidth,$Column4BoxHeight) 
# Populates to PoSH-ACME GUI
$PoShACME.Controls.Add($CheckBoxNum05)



# ============================================================================================================================================================
# Computer Informatioin
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column4RowLocation   += $Column4RowLocationShift



# Command CheckBox and Text
$CheckBoxNum06 = New-Object System.Windows.Forms.CheckBox
$CheckBoxNum06.Name = "Computer Information"
function CommandNum06 {
    foreach ($TargetComputer in $ComputerList) {
        $CollectionName      = "$($CheckBoxNum06.Name)"
        $CollectionDirectory = $CollectionName
        $Message1            = "Collecting: $($CheckBoxNum06.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null
        Get-WmiObject -Class Win32_ComputerSystem -ComputerName $TargetComputer `
        | Select-Object PSComputerName, Description, Manufacturer, Model, SystemType, NumberOfProcessors, TotalPhysicalMemory, EnableDaylightSavingsTime, BootupState, ThermalState, ChassisBootupState, KeyboardPasswordStatus, PowerSupplyState, PartOfDomain, Domain, Roles, Username, PrimaryOwnerName `
        | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName - $TargetComputer.csv" -NoTypeInformation
    }

    $Message2 = "Completed: $($CheckBoxNum06.Name)"
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
# Command Checkbox
$CheckBoxNum06.Text     = "$($CheckBoxNum06.Name)"
$CheckBoxNum06.TabIndex = 2
$CheckBoxNum06.DataBindings.DefaultDataSourceUpdateMode = 0
$CheckBoxNum06.Location = New-Object System.Drawing.Size($Column4RightAlignment,$Column4RowLocation) 
$CheckBoxNum06.Size     = New-Object System.Drawing.Size($Column4BoxWidth,$Column4BoxHeight) 
# Populates to PoSH-ACME GUI
$PoShACME.Controls.Add($CheckBoxNum06)



# ============================================================================================================================================================
# Security Patches
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column4RowLocation   += $Column4RowLocationShift



# Command CheckBox and Text
$CheckBoxNum07 = New-Object System.Windows.Forms.CheckBox
$CheckBoxNum07.Name = "Security Patches"
function CommandNum07 {
    foreach ($TargetComputer in $ComputerList) {
        $CollectionName      = "$($CheckBoxNum07.Name)"
        $CollectionDirectory = $CollectionName
        $Message1            = "Collecting: $($CheckBoxNum07.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null
        Get-WmiObject -Class Win32_QuickFixEngineering -ComputerName $TargetComputer `
        | Select-Object PSComputerName, HotFixID, Description, InstalledBy, InstalledOn `
        | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName - $TargetComputer.csv" -NoTypeInformation
    }

    $Message2 = "Completed: $($CheckBoxNum07.Name)"
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
# Command Checkbox
$CheckBoxNum07.Text     = "$($CheckBoxNum07.Name)"
$CheckBoxNum07.TabIndex = 2
$CheckBoxNum07.DataBindings.DefaultDataSourceUpdateMode = 0
$CheckBoxNum07.Location = New-Object System.Drawing.Size($Column4RightAlignment,$Column4RowLocation) 
$CheckBoxNum07.Size     = New-Object System.Drawing.Size($Column4BoxWidth,$Column4BoxHeight) 
# Populates to PoSH-ACME GUI
$PoShACME.Controls.Add($CheckBoxNum07)



# ============================================================================================================================================================
# Logon Information
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column4RowLocation   += $Column4RowLocationShift



# Command CheckBox and Text
$CheckBoxNum08 = New-Object System.Windows.Forms.CheckBox
$CheckBoxNum08.Name = "Logon Information"
function CommandNum08 {
    foreach ($TargetComputer in $ComputerList) {
        $CollectionName      = "$($CheckBoxNum08.Name)"
        $CollectionDirectory = $CollectionName
        $Message1            = "Collecting: $($CheckBoxNum08.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null
        Get-WmiObject -Class Win32_NetworkLoginProfile -ComputerName $TargetComputer `
        | Select-Object PSComputerName, Name, LastLogon, LastLogoff, NumberOfLogons, PasswordAge `
        | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName - $TargetComputer.csv" -NoTypeInformation
    }

    $Message2 = "Completed: $($CheckBoxNum08.Name)"
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
# Command Checkbox
$CheckBoxNum08.Text     = "$($CheckBoxNum08.Name)"
$CheckBoxNum08.TabIndex = 2
$CheckBoxNum08.DataBindings.DefaultDataSourceUpdateMode = 0
$CheckBoxNum08.Location = New-Object System.Drawing.Size($Column4RightAlignment,$Column4RowLocation) 
$CheckBoxNum08.Size     = New-Object System.Drawing.Size($Column4BoxWidth,$Column4BoxHeight) 
# Populates to PoSH-ACME GUI
$PoShACME.Controls.Add($CheckBoxNum08)



# ============================================================================================================================================================
# Group Information
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column4RowLocation   += $Column4RowLocationShift



# Command CheckBox and Text
$CheckBoxNum11 = New-Object System.Windows.Forms.CheckBox
$CheckBoxNum11.Name = "Group Information"
function CommandNum11 {
    foreach ($TargetComputer in $ComputerList) {
        $CollectionName      = "$($CheckBoxNum11.Name)"
        $CollectionDirectory = $CollectionName
        $Message1            = "Collecting: $($CheckBoxNum11.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null
        Get-WmiObject -Class Win32_Group -ComputerName $TargetComputer `
        | Select-Object PSComputerName, Name, Caption, Domain, SID `
        | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName - $TargetComputer.csv" -NoTypeInformation
    }

    $Message2 = "Completed: $($CheckBoxNum11.Name)"
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
# Command Checkbox
$CheckBoxNum11.Text     = "$($CheckBoxNum11.Name)"
$CheckBoxNum11.TabIndex = 2
$CheckBoxNum11.DataBindings.DefaultDataSourceUpdateMode = 0
$CheckBoxNum11.Location = New-Object System.Drawing.Size($Column4RightAlignment,$Column4RowLocation) 
$CheckBoxNum11.Size     = New-Object System.Drawing.Size($Column4BoxWidth,$Column4BoxHeight) 
# Populates to PoSH-ACME GUI
$PoShACME.Controls.Add($CheckBoxNum11)



# ============================================================================================================================================================
# Autoruns - Startup Commands
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column4RowLocation   += $Column4RowLocationShift



# Command CheckBox and Text
$CheckBoxNum12 = New-Object System.Windows.Forms.CheckBox
$CheckBoxNum12.Name = "Autoruns - Startup Commands"
function CommandNum12 {
    foreach ($TargetComputer in $ComputerList) {
        $CollectionName      = "$($CheckBoxNum12.Name)"
        $CollectionDirectory = $CollectionName
        $Message1            = "Collecting: $($CheckBoxNum12.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null
        Get-WmiObject -Class Win32_StartupCommand -ComputerName $TargetComputer `
        | Select-Object PSComputerName, Name, Location, Command, User `
        | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName - $TargetComputer.csv" -NoTypeInformation
    }

    $Message2 = "Completed: $($CheckBoxNum12.Name)"
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
# Command Checkbox
$CheckBoxNum12.Text     = "$($CheckBoxNum12.Name)"
$CheckBoxNum12.TabIndex = 2
$CheckBoxNum12.DataBindings.DefaultDataSourceUpdateMode = 0
$CheckBoxNum12.Location = New-Object System.Drawing.Size($Column4RightAlignment,$Column4RowLocation) 
$CheckBoxNum12.Size     = New-Object System.Drawing.Size($Column4BoxWidth,$Column4BoxHeight) 
# Populates to PoSH-ACME GUI
$PoShACME.Controls.Add($CheckBoxNum12)



# ============================================================================================================================================================
# Dates - Install, Bootup, System
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column4RowLocation   += $Column4RowLocationShift



# Command CheckBox and Text
$CheckBoxNum13 = New-Object System.Windows.Forms.CheckBox
$CheckBoxNum13.Name = "Dates - Install, Bootup, System"
function CommandNum13 {
    foreach ($TargetComputer in $ComputerList) {
        $CollectionName      = "$($CheckBoxNum13.Name)"
        $CollectionDirectory = $CollectionName
        $Message1            = "Collecting: $($CheckBoxNum13.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null
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
    CollectDateTimes | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName - $TargetComputer.csv" -NoTypeInformation
    }

    $Message2 = "Completed: $($CheckBoxNum13.Name)"
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
# Command Checkbox
$CheckBoxNum13.Text     = "$($CheckBoxNum13.Name)"
$CheckBoxNum13.TabIndex = 2
$CheckBoxNum13.DataBindings.DefaultDataSourceUpdateMode = 0
$CheckBoxNum13.Location = New-Object System.Drawing.Size($Column4RightAlignment,$Column4RowLocation) 
$CheckBoxNum13.Size     = New-Object System.Drawing.Size($Column4BoxWidth,$Column4BoxHeight) 
# Populates to PoSH-ACME GUI
$PoShACME.Controls.Add($CheckBoxNum13)



# ============================================================================================================================================================
# Environmental Variables
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column4RowLocation   += $Column4RowLocationShift



# Command CheckBox and Text
$CheckBoxNum14 = New-Object System.Windows.Forms.CheckBox
$CheckBoxNum14.Name = "Environmental Variables"
function CommandNum14 {
    foreach ($TargetComputer in $ComputerList) {
        $CollectionName      = "$($CheckBoxNum14.Name)"
        $CollectionDirectory = $CollectionName
        $Message1            = "Collecting: $($CheckBoxNum14.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null
        Get-WmiObject -Class Win32_Environment -ComputerName $TargetComputer `
        | Select-Object PSComputerName, UserName, Name, VariableValue `
        | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName - $TargetComputer.csv" -NoTypeInformation

        }

    $Message2 = "Completed: $($CheckBoxNum14.Name)"
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
# Command Checkbox
$CheckBoxNum14.Text     = "$($CheckBoxNum14.Name)"
$CheckBoxNum14.TabIndex = 2
$CheckBoxNum14.DataBindings.DefaultDataSourceUpdateMode = 0
$CheckBoxNum14.Location = New-Object System.Drawing.Size($Column4RightAlignment,$Column4RowLocation) 
$CheckBoxNum14.Size     = New-Object System.Drawing.Size($Column4BoxWidth,$Column4BoxHeight) 
# Populates to PoSH-ACME GUI
$PoShACME.Controls.Add($CheckBoxNum14)



# ============================================================================================================================================================
# BIOS Information
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column4RowLocation   += $Column4RowLocationShift



# Command CheckBox and Text
$CheckBoxNum15 = New-Object System.Windows.Forms.CheckBox
$CheckBoxNum15.Name = "BIOS Information"
function CommandNum15 {
    foreach ($TargetComputer in $ComputerList) {
        $CollectionName      = "$($CheckBoxNum15.Name)"
        $CollectionDirectory = $CollectionName
        $Message1            = "Collecting: $($CheckBoxNum15.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null
        Get-WmiObject -Class Win32_BIOS -ComputerName $TargetComputer `
        | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName - $TargetComputer.csv" -NoTypeInformation
        }

    $Message2 = "Completed: $($CheckBoxNum15.Name)"
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
# Command Checkbox
$CheckBoxNum15.Text     = "$($CheckBoxNum15.Name)"
$CheckBoxNum15.TabIndex = 2
$CheckBoxNum15.DataBindings.DefaultDataSourceUpdateMode = 0
$CheckBoxNum15.Location = New-Object System.Drawing.Size($Column4RightAlignment,$Column4RowLocation) 
$CheckBoxNum15.Size     = New-Object System.Drawing.Size($Column4BoxWidth,$Column4BoxHeight) 
# Populates to PoSH-ACME GUI
$PoShACME.Controls.Add($CheckBoxNum15)



# ============================================================================================================================================================
# Drivers - Detailed
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column4RowLocation   += $Column4RowLocationShift



# Command CheckBox and Text
$CheckBoxNum16 = New-Object System.Windows.Forms.CheckBox
$CheckBoxNum16.Name = "Drivers - Detailed"
function CommandNum16 {
    foreach ($TargetComputer in $ComputerList) {
        $CollectionName      = "$($CheckBoxNum16.Name)"
        $CollectionDirectory = $CollectionName
        $Message1            = "Collecting: $($CheckBoxNum16.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null
        Get-WmiObject -Class Win32_Systemdriver -ComputerName $TargetComputer `
        | Select-Object PSComputerName, State, Status, Started, StartMode, Name, InstallDate, DisplayName, PathName, ExitCode, AcceptPause, AcceptStop, Caption, CreationClassName, Description, DesktopInteract, DisplayName, ErrorControl, InstallDate, PathName, ServiceType `
        | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName - $TargetComputer.csv" -NoTypeInformation

        }

    $Message2 = "Completed: $($CheckBoxNum16.Name)"
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
# Command Checkbox
$CheckBoxNum16.Text     = "$($CheckBoxNum16.Name)"
$CheckBoxNum16.TabIndex = 2
$CheckBoxNum16.DataBindings.DefaultDataSourceUpdateMode = 0
$CheckBoxNum16.Location = New-Object System.Drawing.Size($Column4RightAlignment,$Column4RowLocation) 
$CheckBoxNum16.Size     = New-Object System.Drawing.Size($Column4BoxWidth,$Column4BoxHeight) 
# Populates to PoSH-ACME GUI
$PoShACME.Controls.Add($CheckBoxNum16)



# ============================================================================================================================================================
# Drivers - Valid Signatures
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column4RowLocation   += $Column4RowLocationShift



# Command CheckBox and Text
$CheckBoxNum17 = New-Object System.Windows.Forms.CheckBox
$CheckBoxNum17.Name = "Drivers - Valid Signatures"
function CommandNum17 {
    foreach ($TargetComputer in $ComputerList) {
        $CollectionName      = "$($CheckBoxNum17.Name)"
        $CollectionDirectory = $CollectionName
        $Message1            = "Collecting: $($CheckBoxNum17.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null
        Get-WmiObject -Class Win32_SystemDriver -ComputerName $TargetComputer `
        | ForEach-Object {Get-AuthenticodeSignature $_.pathname} `
        | Select-Object PSComputerName, Status, Path, @{Name="SignerCertificate";Expression={$_.SignerCertificate -join "; "}} `
        | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName - $TargetComputer.csv" -NoTypeInformation
        }

    $Message2 = "Completed: $($CheckBoxNum17.Name)"
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
# Command Checkbox
$CheckBoxNum17.Text     = "$($CheckBoxNum17.Name)"
$CheckBoxNum17.TabIndex = 2
$CheckBoxNum17.DataBindings.DefaultDataSourceUpdateMode = 0
$CheckBoxNum17.Location = New-Object System.Drawing.Size($Column4RightAlignment,$Column4RowLocation) 
$CheckBoxNum17.Size     = New-Object System.Drawing.Size($Column4BoxWidth,$Column4BoxHeight) 
# Populates to PoSH-ACME GUI
$PoShACME.Controls.Add($CheckBoxNum17)



# ============================================================================================================================================================
# Memory (RAM) Capacity Info
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column4RowLocation   += $Column4RowLocationShift



# Command CheckBox and Text
$CheckBoxNum18 = New-Object System.Windows.Forms.CheckBox
$CheckBoxNum18.Name = "Memory (RAM) Capacity Info"
function CommandNum18 {
    foreach ($TargetComputer in $ComputerList) {
        $CollectionName      = "$($CheckBoxNum18.Name)"
        $CollectionDirectory = $CollectionName
        $Message1            = "Collecting: $($CheckBoxNum18.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null
        Get-WmiObject -Class Win32_PhysicalMemoryArray -ComputerName $TargetComputer `
        | Select-Object PSComputerName, Model, Name, MaxCapacity, MemoryDevices `
        | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName - $TargetComputer.csv" -NoTypeInformation
        }

    $Message2 = "Completed: $($CheckBoxNum18.Name)"
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
# Command Checkbox
$CheckBoxNum18.Text     = "$($CheckBoxNum18.Name)"
$CheckBoxNum18.TabIndex = 2
$CheckBoxNum18.DataBindings.DefaultDataSourceUpdateMode = 0
$CheckBoxNum18.Location = New-Object System.Drawing.Size($Column4RightAlignment,$Column4RowLocation) 
$CheckBoxNum18.Size     = New-Object System.Drawing.Size($Column4BoxWidth,$Column4BoxHeight) 
# Populates to PoSH-ACME GUI
$PoShACME.Controls.Add($CheckBoxNum18)



# ============================================================================================================================================================
# Memory (RAM) Physical Information
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column4RowLocation   += $Column4RowLocationShift



# Command CheckBox and Text
$CheckBoxNum19 = New-Object System.Windows.Forms.CheckBox
$CheckBoxNum19.Name = "Memory (RAM) Physical Info"
function CommandNum19 {
    foreach ($TargetComputer in $ComputerList) {
        $CollectionName      = "$($CheckBoxNum19.Name)"
        $CollectionDirectory = $CollectionName
        $Message1            = "Collecting: $($CheckBoxNum19.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null
        Get-WmiObject -Class Win32_PhysicalMemory -ComputerName $TargetComputer `
        | Select-Object PSComputerName, Tag, Capacity, Speed, Manufacturer, PartNumber, SerialNumber `
        | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName - $TargetComputer.csv" -NoTypeInformation
        }

    $Message2 = "Completed: $($CheckBoxNum19.Name)"
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
# Command Checkbox
$CheckBoxNum19.Text     = "$($CheckBoxNum19.Name)"
$CheckBoxNum19.TabIndex = 2
$CheckBoxNum19.DataBindings.DefaultDataSourceUpdateMode = 0
$CheckBoxNum19.Location = New-Object System.Drawing.Size($Column4RightAlignment,$Column4RowLocation) 
$CheckBoxNum19.Size     = New-Object System.Drawing.Size($Column4BoxWidth,$Column4BoxHeight) 
# Populates to PoSH-ACME GUI
$PoShACME.Controls.Add($CheckBoxNum19)



# ============================================================================================================================================================
# Memory (RAM) Utilization
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column4RowLocation   += $Column4RowLocationShift



# Command CheckBox and Text
$CheckBoxNum20 = New-Object System.Windows.Forms.CheckBox
$CheckBoxNum20.Name = "Memory (RAM) Utilization"
function CommandNum20 {
    foreach ($TargetComputer in $ComputerList) {
        $CollectionName      = "$($CheckBoxNum20.Name)"
        $CollectionDirectory = $CollectionName
        $Message1            = "Collecting: $($CheckBoxNum20.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null
        Get-WmiObject -Class Win32_OperatingSystem -ComputerName $TargetComputer `
        | Select-Object -Property PSComputerName, FreePhysicalMemory, TotalVisibleMemorySize, FreeVirtualMemory, TotalVirtualMemorySize `
        | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName - $TargetComputer.csv" -NoTypeInformation
        }

    $Message2 = "Completed: $($CheckBoxNum20.Name)"
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
# Command Checkbox
$CheckBoxNum20.Text     = "$($CheckBoxNum20.Name)"
$CheckBoxNum20.TabIndex = 2
$CheckBoxNum20.DataBindings.DefaultDataSourceUpdateMode = 0
$CheckBoxNum20.Location = New-Object System.Drawing.Size($Column4RightAlignment,$Column4RowLocation) 
$CheckBoxNum20.Size     = New-Object System.Drawing.Size($Column4BoxWidth,$Column4BoxHeight) 
# Populates to PoSH-ACME GUI
$PoShACME.Controls.Add($CheckBoxNum20)



# ============================================================================================================================================================
# Memory Performance Monitoring Data
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column4RowLocation   += $Column4RowLocationShift



# Command CheckBox and Text
$CheckBoxNum21 = New-Object System.Windows.Forms.CheckBox
$CheckBoxNum21.Name = "Memory Performance Data"
function CommandNum21 {
    foreach ($TargetComputer in $ComputerList) {
        $CollectionName      = "$($CheckBoxNum21.Name)"
        $CollectionDirectory = $CollectionName
        $Message1            = "Collecting: $($CheckBoxNum21.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null
        Get-WmiObject -Class Win32_PerfRawData_PerfOS_Memory -ComputerName $TargetComputer `
        | Sort-Object -Property PSComputerName, AvailableBytes, AvailableKBytes, AvailableMBytes, CacheBytes, CacheBytesPeak, CacheFaultsPersec, Caption, CommitLimit, CommittedBytes, DemandZeroFaultsPersec, FreeAndZeroPageListBytes, FreeSystemPageTableEntries, Frequency_Object, Frequency_PerfTime, Frequency_Sys100NS, LongTermAverageStandbyCacheLifetimes, ModifiedPageListBytes, PageFaultsPersec, PageReadsPersec, PagesInputPersec, PagesOutputPersec, PagesPersec, PageWritesPersec, PercentCommittedBytesInUse, PercentCommittedBytesInUse_Base, PoolNonpagedAllocs, PoolNonpagedBytes, PoolPagedAllocs, PoolPagedBytes, PoolPagedResidentBytes, StandbyCacheCoreBytes, StandbyCacheNormalPriorityBytes, StandbyCacheReserveBytes, SystemCacheResidentBytes, SystemCodeResidentBytes, SystemCodeTotalBytes, SystemDriverResidentBytes, SystemDriverTotalBytes, Timestamp_Object, Timestamp_PerfTime, Timestamp_Sys100NS, TransitionFaultsPersec, TransitionPagesRePurposedPersec, WriteCopiesPersec `
        | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName - $TargetComputer.csv" -NoTypeInformation
        }

    $Message2 = "Completed: $($CheckBoxNum21.Name)"
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
# Command Checkbox
$CheckBoxNum21.Text     = "$($CheckBoxNum21.Name)"
$CheckBoxNum21.TabIndex = 2
$CheckBoxNum21.DataBindings.DefaultDataSourceUpdateMode = 0
$CheckBoxNum21.Location = New-Object System.Drawing.Size($Column4RightAlignment,$Column4RowLocation) 
$CheckBoxNum21.Size     = New-Object System.Drawing.Size($Column4BoxWidth,$Column4BoxHeight) 
# Populates to PoSH-ACME GUI
$PoShACME.Controls.Add($CheckBoxNum21)



# ============================================================================================================================================================
# ============================================================================================================================================================
# Column 2
# ============================================================================================================================================================
# ============================================================================================================================================================

$Column4RightAlignment   = 235     # Horizontal
$Column4RowLocation   = -10   # Vertical

# Shift the fields
$Column4RowLocation += $Column4RowLocationShift
$Column4RowLocation += $Column4RowLocationShift
$Column4RowLocation += $Column4RowLocationShift



# ============================================================================================================================================================
# Mapped Drives
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column4RowLocation   += $Column4RowLocationShift



# ============================================================================================================================================================
# Disk Information
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column4RowLocation   += $Column4RowLocationShift


# Command CheckBox and Text
$CheckBoxNum22 = New-Object System.Windows.Forms.CheckBox
$CheckBoxNum22.Name = "Disk Information"
function CommandNum22 {
    foreach ($TargetComputer in $ComputerList) {
        $CollectionName      = "$($CheckBoxNum22.Name)"
        $CollectionDirectory = $CollectionName
        $Message1            = "Collecting: $($CheckBoxNum22.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null
        Get-WmiObject -Class Win32_LogicalDisk -ComputerName $TargetComputer `
        | Select-Object PSComputerName, DeviceID, Description, ProviderName, FreeSpace, Size, DriveType `
        | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName - $TargetComputer.csv" -NoTypeInformation
        }

    $Message2 = "Completed: $($CheckBoxNum22.Name)"
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
# Command Checkbox
$CheckBoxNum22.Text     = "$($CheckBoxNum22.Name)"
$CheckBoxNum22.TabIndex = 2
$CheckBoxNum22.DataBindings.DefaultDataSourceUpdateMode = 0
$CheckBoxNum22.Location = New-Object System.Drawing.Size($Column4RightAlignment,$Column4RowLocation) 
$CheckBoxNum22.Size     = New-Object System.Drawing.Size($Column4BoxWidth,$Column4BoxHeight) 
# Populates to PoSH-ACME GUI
$PoShACME.Controls.Add($CheckBoxNum22)


# Command CheckBox and Text
$CheckBoxNum23 = New-Object System.Windows.Forms.CheckBox
$CheckBoxNum23.Name = "Mapped Drives"
function CommandNum23 {
    foreach ($TargetComputer in $ComputerList) {
        $CollectionName      = "$($CheckBoxNum23.Name)"
        $CollectionDirectory = $CollectionName
        $Message1            = "Collecting: $($CheckBoxNum23.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null
        Get-WmiObject -Class Win32_MappedLogicalDisk -ComputerName $TargetComputer `
        | Select-Object PSComputerName, Name, ProviderName `
        | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName - $TargetComputer.csv" -NoTypeInformation
        }

    $Message2 = "Completed: $($CheckBoxNum23.Name)"
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
# Command Checkbox
$CheckBoxNum23.Text     = "$($CheckBoxNum23.Name)"
$CheckBoxNum23.TabIndex = 2
$CheckBoxNum23.DataBindings.DefaultDataSourceUpdateMode = 0
$CheckBoxNum23.Location = New-Object System.Drawing.Size($Column4RightAlignment,$Column4RowLocation) 
$CheckBoxNum23.Size     = New-Object System.Drawing.Size($Column4BoxWidth,$Column4BoxHeight) 
# Populates to PoSH-ACME GUI
$PoShACME.Controls.Add($CheckBoxNum23)


# ============================================================================================================================================================
# Shares
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column4RowLocation   += $Column4RowLocationShift



# Command CheckBox and Text
$CheckBoxNum25 = New-Object System.Windows.Forms.CheckBox
$CheckBoxNum25.Name = "Shares"
function CommandNum25 {
    foreach ($TargetComputer in $ComputerList) {
        $CollectionName      = "$($CheckBoxNum25.Name)"
        $CollectionDirectory = $CollectionName
        $Message1            = "Collecting: $($CheckBoxNum25.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null
        Get-WmiObject -Class Win32_Share -ComputerName $TargetComputer `
        | Select-Object PSComputerName, Name, Path, Description `
        | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName - $TargetComputer.csv" -NoTypeInformation
        }

    $Message2 = "Completed: $($CheckBoxNum25.Name)"
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
# Command Checkbox
$CheckBoxNum25.Text     = "$($CheckBoxNum25.Name)"
$CheckBoxNum25.TabIndex = 2
$CheckBoxNum25.DataBindings.DefaultDataSourceUpdateMode = 0
$CheckBoxNum25.Location = New-Object System.Drawing.Size($Column4RightAlignment,$Column4RowLocation) 
$CheckBoxNum25.Size     = New-Object System.Drawing.Size($Column4BoxWidth,$Column4BoxHeight) 
# Populates to PoSH-ACME GUI
$PoShACME.Controls.Add($CheckBoxNum25)



# ============================================================================================================================================================
# Plug and Play Devices
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column4RowLocation   += $Column4RowLocationShift



# Command CheckBox and Text
$CheckBoxNum26 = New-Object System.Windows.Forms.CheckBox
$CheckBoxNum26.Name = "Plug and Play Devices"
function CommandNum26 {
    foreach ($TargetComputer in $ComputerList) {
        $CollectionName      = "$($CheckBoxNum26.Name)"
        $CollectionDirectory = $CollectionName
        $Message1            = "Collecting: $($CheckBoxNum26.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null
        Get-WmiObject -Class Win32_PnPEntity -ComputerName $TargetComputer `
        | Select-Object PSComputerName, InstallDate, Status, Description, Service, DeviceID, @{Name="HardwareID";Expression={$_.HardwareID -join "; "}}, Manufacturer `
        | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName - $TargetComputer.csv" -NoTypeInformation
        }

    $Message2 = "Completed: $($CheckBoxNum26.Name)"
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
# Command Checkbox
$CheckBoxNum26.Text     = "$($CheckBoxNum26.Name)"
$CheckBoxNum26.TabIndex = 2
$CheckBoxNum26.DataBindings.DefaultDataSourceUpdateMode = 0
$CheckBoxNum26.Location = New-Object System.Drawing.Size($Column4RightAlignment,$Column4RowLocation) 
$CheckBoxNum26.Size     = New-Object System.Drawing.Size($Column4BoxWidth,$Column4BoxHeight) 
# Populates to PoSH-ACME GUI
$PoShACME.Controls.Add($CheckBoxNum26)



# ============================================================================================================================================================
# USB Controller Device Connections
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column4RowLocation   += $Column4RowLocationShift



# Command CheckBox and Text
$CheckBoxNum27 = New-Object System.Windows.Forms.CheckBox
$CheckBoxNum27.Name = "USB Controller Devices"
function CommandNum27 {
    foreach ($TargetComputer in $ComputerList) {
        $CollectionName      = "$($CheckBoxNum27.Name)"
        $CollectionDirectory = $CollectionName
        $Message1            = "Collecting: $($CheckBoxNum27.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null
        Get-WmiObject Win32_USBControllerDevice -ComputerName $TargetComputer `
        | Select-Object PSComputerName, Antecedent, Dependent `
        | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName - $TargetComputer.csv" -NoTypeInformation
        }

    $Message2 = "Completed: $($CheckBoxNum27.Name)"
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
# Command Checkbox
$CheckBoxNum27.Text     = "$($CheckBoxNum27.Name)"
$CheckBoxNum27.TabIndex = 2
$CheckBoxNum27.DataBindings.DefaultDataSourceUpdateMode = 0
$CheckBoxNum27.Location = New-Object System.Drawing.Size($Column4RightAlignment,$Column4RowLocation) 
$CheckBoxNum27.Size     = New-Object System.Drawing.Size($Column4BoxWidth,$Column4BoxHeight) 
# Populates to PoSH-ACME GUI
$PoShACME.Controls.Add($CheckBoxNum27)



# ============================================================================================================================================================
# Software Installed
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column4RowLocation   += $Column4RowLocationShift



# Command CheckBox and Text
$CheckBoxNum28 = New-Object System.Windows.Forms.CheckBox
$CheckBoxNum28.Name = "Software Installed"
function CommandNum28 {
    foreach ($TargetComputer in $ComputerList) {
        $CollectionName      = "$($CheckBoxNum28.Name)"
        $CollectionDirectory = $CollectionName
        $Message1            = "Collecting: $($CheckBoxNum28.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null
        Get-WmiObject Win32_Product -ComputerName $TargetComputer `
        | Select-Object -Property PSComputerName, Name, Vendor, Version, InstallDate, InstallDate2, InstallLocation, InstallSource, PackageName, PackageCache, RegOwner, HelpLink, HelpTelephone, URLInfoAbout, URLUpdateInfo, Language, Description, IdentifyingNumber `
        | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName - $TargetComputer.csv" -NoTypeInformation
        }

    $Message2 = "Completed: $($CheckBoxNum28.Name)"
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
# Command Checkbox
$CheckBoxNum28.Text     = "$($CheckBoxNum28.Name)"
$CheckBoxNum28.TabIndex = 2
$CheckBoxNum28.DataBindings.DefaultDataSourceUpdateMode = 0
$CheckBoxNum28.Location = New-Object System.Drawing.Size($Column4RightAlignment,$Column4RowLocation) 
$CheckBoxNum28.Size     = New-Object System.Drawing.Size($Column4BoxWidth,$Column4BoxHeight) 
# Populates to PoSH-ACME GUI
$PoShACME.Controls.Add($CheckBoxNum28)



# ============================================================================================================================================================
# ============================================================================================================================================================
# Event Logs 
# ============================================================================================================================================================
# ============================================================================================================================================================

$LimitNumberOfEventLogsCollectToChoice = 100

# ============================================================================================================================================================
# Event Logs - Security
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column4RowLocation   += $Column4RowLocationShift



# Command CheckBox and Text
$CheckBoxNum29 = New-Object System.Windows.Forms.CheckBox
$CheckBoxNum29.Name = "Event Logs - Security"
function CommandNum29 {
    foreach ($TargetComputer in $ComputerList) {
        $CollectionName      = "$($CheckBoxNum29.Name)"
        $CollectionDirectory = $CollectionName
        $Message1            = "Collecting: $($CheckBoxNum29.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null
        Get-WmiObject -Class Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile='Security')" `
        | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type `
        | Select-Object -first $LimitNumberOfEventLogsCollectToChoice `
        | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName - $TargetComputer.csv" -NoTypeInformation
        }

    $Message2 = "Completed: $($CheckBoxNum29.Name)"
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
# Command Checkbox
$CheckBoxNum29.Text     = "$($CheckBoxNum29.Name)"
$CheckBoxNum29.TabIndex = 2
$CheckBoxNum29.DataBindings.DefaultDataSourceUpdateMode = 0
$CheckBoxNum29.Location = New-Object System.Drawing.Size($Column4RightAlignment,$Column4RowLocation) 
$CheckBoxNum29.Size     = New-Object System.Drawing.Size($Column4BoxWidth,$Column4BoxHeight) 
# Populates to PoSH-ACME GUI
$PoShACME.Controls.Add($CheckBoxNum29)



# ============================================================================================================================================================
# Event Logs - System
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column4RowLocation   += $Column4RowLocationShift


# Command CheckBox and Text
$CheckBoxNum30 = New-Object System.Windows.Forms.CheckBox
$CheckBoxNum30.Name = "Event Logs - System"
function CommandNum30 {
    foreach ($TargetComputer in $ComputerList) {
        $CollectionName      = "$($CheckBoxNum30.Name)"
        $CollectionDirectory = $CollectionName
        $Message1            = "Collecting: $($CheckBoxNum30.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null
        Get-WmiObject -Class Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile='System')" `
        | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type `
        | Select-Object -first $LimitNumberOfEventLogsCollectToChoice `
        | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName - $TargetComputer.csv" -NoTypeInformation
        }

    $Message2 = "Completed: $($CheckBoxNum30.Name)"
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
# Command Checkbox
$CheckBoxNum30.Text     = "$($CheckBoxNum30.Name)"
$CheckBoxNum30.TabIndex = 2
$CheckBoxNum30.DataBindings.DefaultDataSourceUpdateMode = 0
$CheckBoxNum30.Location = New-Object System.Drawing.Size($Column4RightAlignment,$Column4RowLocation) 
$CheckBoxNum30.Size     = New-Object System.Drawing.Size($Column4BoxWidth,$Column4BoxHeight) 
# Populates to PoSH-ACME GUI
$PoShACME.Controls.Add($CheckBoxNum30)



# ============================================================================================================================================================
# Event Logs - Application
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column4RowLocation   += $Column4RowLocationShift


# Command CheckBox and Text
$CheckBoxNum31               = New-Object System.Windows.Forms.CheckBox
$CheckBoxNum31.Name          = "Event Logs - Application"
function CommandNum31 {
    foreach ($TargetComputer in $ComputerList) {
        $CollectionName      = "$($CheckBoxNum31.Name)"
        $CollectionDirectory = $CollectionName
        $Message1            = "Collecting: $($CheckBoxNum31.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        Get-WmiObject -Class Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile='Application')" `
        | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type `
        | Select-Object -first $LimitNumberOfEventLogsCollectToChoice `
        | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName - $TargetComputer.csv" -NoTypeInformation
        }

    $Message2 = "Completed: $($CheckBoxNum31.Name)"
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
# Command Checkbox
$CheckBoxNum31.Text     = "$($CheckBoxNum31.Name)"
$CheckBoxNum31.TabIndex = 2
$CheckBoxNum31.DataBindings.DefaultDataSourceUpdateMode = 0
$CheckBoxNum31.Location = New-Object System.Drawing.Size($Column4RightAlignment,$Column4RowLocation) 
$CheckBoxNum31.Size     = New-Object System.Drawing.Size($Column4BoxWidth,$Column4BoxHeight) 
# Populates to PoSH-ACME GUI
$PoShACME.Controls.Add($CheckBoxNum31)



# ============================================================================================================================================================
# Event Logs - System Errors
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column4RowLocation   += $Column4RowLocationShift


# Command CheckBox and Text
$CheckBoxNum32 = New-Object System.Windows.Forms.CheckBox
$CheckBoxNum32.Name = "Event Logs - System Errors"
function CommandNum32 {
    foreach ($TargetComputer in $ComputerList) {
        $CollectionName      = "$($CheckBoxNum32.Name)"
        $CollectionDirectory = $CollectionName
        $Message1            = "Collecting: $($CheckBoxNum32.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null
        Get-WmiObject -Class Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile='System') AND (type='error')" `
        | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type `
        | Select-Object -first $LimitNumberOfEventLogsCollectToChoice `
        | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName - $TargetComputer.csv" -NoTypeInformation
        }

    $Message2 = "Completed: $($CheckBoxNum32.Name)"
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
# Command Checkbox
$CheckBoxNum32.Text     = "$($CheckBoxNum32.Name)"
$CheckBoxNum32.TabIndex = 2
$CheckBoxNum32.DataBindings.DefaultDataSourceUpdateMode = 0
$CheckBoxNum32.Location = New-Object System.Drawing.Size($Column4RightAlignment,$Column4RowLocation) 
$CheckBoxNum32.Size     = New-Object System.Drawing.Size($Column4BoxWidth,$Column4BoxHeight) 
# Populates to PoSH-ACME GUI
$PoShACME.Controls.Add($CheckBoxNum32)



# ============================================================================================================================================================
# Event Logs - Application Errors
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column4RowLocation   += $Column4RowLocationShift


# Command CheckBox and Text
$CheckBoxNum33               = New-Object System.Windows.Forms.CheckBox
$CheckBoxNum33.Name          = "Event Logs - Application Errors"
function CommandNum33 {
    foreach ($TargetComputer in $ComputerList) {
        $CollectionName      = "$($CheckBoxNum33.Name)"
        $CollectionDirectory = $CollectionName
        $Message1            = "Collecting: $($CheckBoxNum33.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

        Get-WmiObject -Class Win32_NTLogEvent -ComputerName $TargetComputer -Filter "(logfile='Application') AND (type='error')" `
        | Select-Object PSComputerName, EventCode, LogFile, TimeGenerated, Message, InsertionStrings, Type `
        | Select-Object -first $LimitNumberOfEventLogsCollectToChoice `
        | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName - $TargetComputer.csv" -NoTypeInformation
    }

    $Message2 = "Completed: $($CheckBoxNum33.Name)"
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
# Command Checkbox
$CheckBoxNum33.Text     = "$($CheckBoxNum33.Name)"
$CheckBoxNum33.TabIndex = 2
$CheckBoxNum33.DataBindings.DefaultDataSourceUpdateMode = 0
$CheckBoxNum33.Location = New-Object System.Drawing.Size($Column4RightAlignment,$Column4RowLocation) 
$CheckBoxNum33.Size     = New-Object System.Drawing.Size($Column4BoxWidth,$Column4BoxHeight) 
# Populates to PoSH-ACME GUI
$PoShACME.Controls.Add($CheckBoxNum33)



# ============================================================================================================================================================
# Prefetch Files
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column4RowLocation   += $Column4RowLocationShift


# Command CheckBox and Text
$CheckBoxNum34               = New-Object System.Windows.Forms.CheckBox
$CheckBoxNum34.Name          = "Prefetch Files"
function CommandNum34 {
    foreach ($TargetComputer in $ComputerList) {
        $CollectionName      = "$($CheckBoxNum34.Name)"
        $CollectionDirectory = $CollectionName
        $Message1            = "Collecting: $($CheckBoxNum34.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

        # Execute Commands to collect data from the targets
        #Invoke-WmiMethod -Class Win32_Process -Name Create -ComputerName $TargetComputer -ArgumentList "cmd /c dir /T:C /Q %SystemRoot%\Prefetch > c:\$CollectionShortName-CreationTime-$TargetComputer.txt" | Out-Null
        #Invoke-WmiMethod -Class Win32_Process -Name Create -ComputerName $TargetComputer -ArgumentList "cmd /c dir /T:A /Q %SystemRoot%\Prefetch > c:\$CollectionShortName-LastAccessTime-$TargetComputer.txt" | Out-Null
        #Invoke-WmiMethod -Class Win32_Process -Name Create -ComputerName $TargetComputer -ArgumentList "cmd /c dir /T:W /Q %SystemRoot%\Prefetch > c:\$CollectionShortName-LastWriteTime-$TargetComputer.txt" | Out-Null
        Invoke-WmiMethod -Class Win32_Process -Name Create -ComputerName $TargetComputer -ArgumentList "PowerShell -Command `"Get-ChildItem C:\Windows\Prefetch | Select-Object -Property Name, CreationTime, LastWriteTime, LastAccessTime, Mode, Attributes, Length, Directory | Export-CSV c:\prefetch.csv -NoTypeInformation`"" | Out-Null
 #       Invoke-WmiMethod -Class Win32_Process -Name Create -ComputerName localhost -ArgumentList "PowerShell -Command `"Get-ChildItem C:\Windows\Prefetch | Select-Object -Property Name, CreationTime, LastWriteTime, LastAccessTime, Mode, Attributes, Length, Directory | Export-CSV c:\prefetch.csv -NoTypeInformation`"" | Out-Null
 #       Invoke-WmiMethod -Class win32_process -name create -computername localhost -ArgumentList "get-process"
        Start-Sleep -Seconds $SleepTime

        # This copies the data from the target then removes the copy
        Copy-Item "\\$TargetComputer\c$\prefetch.csv" "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv"
        Remove-Item "\\$TargetComputer\c$\prefetch.csv"

        # Add PSComputerName header and host/ip name
        $AddTargetHost = (Import-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv")
        $AddTargetHost | Add-Member -MemberType NoteProperty "PSComputerName" -Value "$TargetComputer"
        $AddTargetHost | Select-Object -Property PSComputerName, * | Export-Csv "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.csv" -NoTypeInformation
    }

    $Message2 = "Completed: $($CheckBoxNum34.Name)"
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
# Command Checkbox
$CheckBoxNum34.Text     = "$($CheckBoxNum34.Name)"
$CheckBoxNum34.TabIndex = 2
$CheckBoxNum34.DataBindings.DefaultDataSourceUpdateMode = 0
$CheckBoxNum34.Location = New-Object System.Drawing.Size($Column4RightAlignment,$Column4RowLocation) 
$CheckBoxNum34.Size     = New-Object System.Drawing.Size($Column4BoxWidth,$Column4BoxHeight) 
# Populates to PoSH-ACME GUI
$PoShACME.Controls.Add($CheckBoxNum34)


# ============================================================================================================================================================
# Firewall Status
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column4RowLocation   += $Column4RowLocationShift


# Command CheckBox and Text
$CheckBoxNum35 = New-Object System.Windows.Forms.CheckBox
$CheckBoxNum35.Name = "Firewall Status"
function CommandNum35 {
    foreach ($TargetComputer in $ComputerList) {
        $CollectionName      = "$($CheckBoxNum35.Name)"
        $CollectionDirectory = $CollectionName
        $CollectionShortName = $CollectionName -replace ' ',''
        $Message1            = "Collecting: $($CheckBoxNum35.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

        # Execute Commands to collect data from the targets
        Invoke-WmiMethod -Class Win32_Process -Name Create -ComputerName $TargetComputer -ArgumentList "cmd /c netsh advfirewall show allprofiles state > c:\$CollectionShortName-$TargetComputer.txt" | Out-Null
    
        Start-Sleep -Seconds $SleepTime

        # This copies the data from the target then removes the copy
        Copy-Item "\\$TargetComputer\c$\$CollectionShortName-$TargetComputer.txt" "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt"
        Remove-Item "\\$TargetComputer\c$\$CollectionShortName-$TargetComputer.txt"

        $FirewallStatus = (Get-Content -Path "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName-$TargetComputer.txt") -replace '-{2,}','' -replace ',',';' -replace '^ {3,}',':  ' | Where-Object {$_.trim() -ne ''} 

        # Extracts the fields that become the file headers
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

    $Message2 = "Completed: $($CheckBoxNum35.Name)"
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
# Command Checkbox
$CheckBoxNum35.Text     = "$($CheckBoxNum35.Name)"
$CheckBoxNum35.TabIndex = 2
$CheckBoxNum35.DataBindings.DefaultDataSourceUpdateMode = 0
$CheckBoxNum35.Location = New-Object System.Drawing.Size($Column4RightAlignment,$Column4RowLocation) 
$CheckBoxNum35.Size     = New-Object System.Drawing.Size($Column4BoxWidth,$Column4BoxHeight) 
# Populates to PoSH-ACME GUI
$PoShACME.Controls.Add($CheckBoxNum35)




# ============================================================================================================================================================
# Firewall Rules
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column4RowLocation   += $Column4RowLocationShift


# Command CheckBox and Text
$CheckBoxNum36 = New-Object System.Windows.Forms.CheckBox
$CheckBoxNum36.Name = "Firewall Rules"
function CommandNum36 {
    foreach ($TargetComputer in $ComputerList) {
        $CollectionName      = "$($CheckBoxNum36.Name)"
        $CollectionDirectory = $CollectionName
        $CollectionShortName = $CollectionName -replace ' ',''
        $Message1            = "Collecting: $($CheckBoxNum36.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

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

    $Message2 = "Completed: $($CheckBoxNum36.Name)"
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
# Command Checkbox
$CheckBoxNum36.Text     = "$($CheckBoxNum36.Name)"
$CheckBoxNum36.TabIndex = 2
$CheckBoxNum36.DataBindings.DefaultDataSourceUpdateMode = 0
$CheckBoxNum36.Location = New-Object System.Drawing.Size($Column4RightAlignment,$Column4RowLocation) 
$CheckBoxNum36.Size     = New-Object System.Drawing.Size($Column4BoxWidth,$Column4BoxHeight) 
# Populates to PoSH-ACME GUI
$PoShACME.Controls.Add($CheckBoxNum36)


# ============================================================================================================================================================
# Port Proxy Rules
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column4RowLocation   += $Column4RowLocationShift


# Command CheckBox and Text
$CheckBoxNum37 = New-Object System.Windows.Forms.CheckBox
$CheckBoxNum37.Name = "Port Proxy Rules"
function CommandNum37 {
    foreach ($TargetComputer in $ComputerList) {
        $CollectionName      = "$($CheckBoxNum37.Name)"
        $CollectionDirectory = $CollectionName
        $CollectionShortName = $CollectionName -replace ' ',''
        $Message1            = "Collecting: $($CheckBoxNum37.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

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

    $Message2 = "Completed: $($CheckBoxNum37.Name)"
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
# Command Checkbox
$CheckBoxNum37.Text     = "$($CheckBoxNum37.Name)"
$CheckBoxNum37.TabIndex = 2
$CheckBoxNum37.DataBindings.DefaultDataSourceUpdateMode = 0
$CheckBoxNum37.Location = New-Object System.Drawing.Size($Column4RightAlignment,$Column4RowLocation) 
$CheckBoxNum37.Size     = New-Object System.Drawing.Size($Column4BoxWidth,$Column4BoxHeight) 
# Populates to PoSH-ACME GUI
$PoShACME.Controls.Add($CheckBoxNum37)



# ============================================================================================================================================================
# Scheduled Tasks (schtasks)
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column4RowLocation   += $Column4RowLocationShift


# Command CheckBox and Text
$CheckBoxNum38 = New-Object System.Windows.Forms.CheckBox
$CheckBoxNum38.Name = "Scheduled Tasks (schtasks)"
function CommandNum38 {
    foreach ($TargetComputer in $ComputerList) {
        $CollectionName      = "$($CheckBoxNum38.Name)"
        $CollectionDirectory = $CollectionName
        $CollectionShortName = $CollectionName -replace ' ',''
        $Message1            = "Collecting: $($CheckBoxNum38.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

        $Command = $($tuple.Item2)
        Invoke-WmiMethod -Class Win32_Process -Name Create -Computername $TargetComputer -ArgumentList "cmd /c schtasks /query /V /FO CSV > c:\$TargetComputer-$CollectionShortName.csv" | Out-Null
        # This deleay is introduced to allow the collection command to complete gathering data before it pulls back the data
        Start-Sleep -Seconds $SleepTime
        # Pulls back the data from the Target Computer
        Copy-Item -Path "\\$TargetComputer\c$\$TargetComputer-$CollectionShortName.csv" -Destination "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\"
        Remove-Item -Path "\\$TargetComputer\c$\$TargetComputer-$CollectionShortName.csv"
        }

    $Message2 = "Completed: $($CheckBoxNum38.Name)"
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

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
}
# Command Checkbox
$CheckBoxNum38.Text     = "$($CheckBoxNum38.Name)"
$CheckBoxNum38.TabIndex = 2
$CheckBoxNum38.DataBindings.DefaultDataSourceUpdateMode = 0
$CheckBoxNum38.Location = New-Object System.Drawing.Size($Column4RightAlignment,$Column4RowLocation) 
$CheckBoxNum38.Size     = New-Object System.Drawing.Size($Column4BoxWidth,$Column4BoxHeight) 
# Populates to PoSH-ACME GUI
$PoShACME.Controls.Add($CheckBoxNum38)



# ============================================================================================================================================================
# DLLs Loaded by Processes
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column4RowLocation   += $Column4RowLocationShift


# Command CheckBox and Text
$CheckBoxNum39 = New-Object System.Windows.Forms.CheckBox
$CheckBoxNum39.Name = "DLLs Loaded by Processes"
function CommandNum39 {
    foreach ($TargetComputer in $ComputerList) {
        $CollectionName      = "$($CheckBoxNum39.Name)"
        $CollectionDirectory = $CollectionName
        $CollectionShortName = $CollectionName -replace ' ',''
        $Message1            = "Collecting: $($CheckBoxNum39.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

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
        }

    $Message2 = "Completed: $($CheckBoxNum39.Name)"
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
# Command Checkbox
$CheckBoxNum39.Text     = "$($CheckBoxNum39.Name)"
$CheckBoxNum39.TabIndex = 2
$CheckBoxNum39.DataBindings.DefaultDataSourceUpdateMode = 0
$CheckBoxNum39.Location = New-Object System.Drawing.Size($Column4RightAlignment,$Column4RowLocation) 
$CheckBoxNum39.Size     = New-Object System.Drawing.Size($Column4BoxWidth,$Column4BoxHeight) 
# Populates to PoSH-ACME GUI
$PoShACME.Controls.Add($CheckBoxNum39)


# ============================================================================================================================================================
# Drivers - Signed Info
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column4RowLocation   += $Column4RowLocationShift


# Command CheckBox and Text
$CheckBoxNum40 = New-Object System.Windows.Forms.CheckBox
$CheckBoxNum40.Name = "Drivers - Signed Info"
function CommandNum40 {
    foreach ($TargetComputer in $ComputerList) {
        $CollectionName      = "$($CheckBoxNum40.Name)"
        $CollectionDirectory = $CollectionName
        $CollectionShortName = $CollectionName -replace ' ',''
        $Message1            = "Collecting: $($CheckBoxNum40.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

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
        }

    $Message2 = "Completed: $($CheckBoxNum40.Name)"
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
# Command Checkbox
$CheckBoxNum40.Text     = "$($CheckBoxNum40.Name)"
$CheckBoxNum40.TabIndex = 2
$CheckBoxNum40.DataBindings.DefaultDataSourceUpdateMode = 0
$CheckBoxNum40.Location = New-Object System.Drawing.Size($Column4RightAlignment,$Column4RowLocation) 
$CheckBoxNum40.Size     = New-Object System.Drawing.Size($Column4BoxWidth,$Column4BoxHeight) 
# Populates to PoSH-ACME GUI
$PoShACME.Controls.Add($CheckBoxNum40)



# ============================================================================================================================================================
# System Information
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column4RowLocation   += $Column4RowLocationShift


# Command CheckBox and Text
$CheckBoxNum41 = New-Object System.Windows.Forms.CheckBox
$CheckBoxNum41.Name = "System Information"
function CommandNum41 {
    foreach ($TargetComputer in $ComputerList) {
        $CollectionName      = "$($CheckBoxNum41.Name)"
        $CollectionDirectory = $CollectionName
        $CollectionShortName = $CollectionName -replace ' ',''
        $Message1            = "Collecting: $($CheckBoxNum41.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        New-Item -ItemType Directory "$PoShLocation\$CollectedResultsUncompiled\$CollectionName" -Force | Out-Null

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
    }

    $Message2 = "Completed: $($CheckBoxNum41.Name)"
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
# Command Checkbox
$CheckBoxNum41.Text     = "$($CheckBoxNum41.Name)"
$CheckBoxNum41.TabIndex = 2
$CheckBoxNum41.DataBindings.DefaultDataSourceUpdateMode = 0
$CheckBoxNum41.Location = New-Object System.Drawing.Size($Column4RightAlignment,$Column4RowLocation) 
$CheckBoxNum41.Size     = New-Object System.Drawing.Size($Column4BoxWidth,$Column4BoxHeight) 
# Populates to PoSH-ACME GUI
$PoShACME.Controls.Add($CheckBoxNum41)


<#

# ============================================================================================================================================================
# ______
# ============================================================================================================================================================

# Shift the Text and Button's Locaiton
$Column4RowLocation   += $Column4RowLocationShift


# Command CheckBox and Text
$CheckBoxNum___ = New-Object System.Windows.Forms.CheckBox
$CheckBoxNum___.Name = "______"
function CommandNum___ {
    foreach ($TargetComputer in $ComputerList) {
        $CollectionName      = "$($CheckBoxNum___.Name)"
        $CollectionDirectory = $CollectionName
        $Message1            = "Collecting: $($CheckBoxNum___.Name) from $TargetComputer"
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($Message1)
        $LogMessage          = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - $Message1"
        $LogMessage          | Add-Content -Path $LogFile

        Write-Host "################ REPLACE AND INSERT COMMANDS HERE ##################"
        | Export-CSV "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory\$CollectionName - $TargetComputer.csv" -NoTypeInformation
        }

    $Message2 = "Completed: $($CheckBoxNum___.Name)"
    $MainListBox.Items.Insert(0,$Message2)
    $Message3 = "Finished Collecting Data!"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add($Message3)

    CompileCsvFiles "$PoShLocation\$CollectedResultsUncompiled\$CollectionDirectory" "$PoShLocation\$CollectionName.csv"
}
# Command Checkbox
$CheckBoxNum___.Text     = "$($CheckBoxNum___.Name)"
$CheckBoxNum___.TabIndex = 2
$CheckBoxNum___.DataBindings.DefaultDataSourceUpdateMode = 0
$CheckBoxNum___.Location = New-Object System.Drawing.Size($Column4RightAlignment,$Column4RowLocation) 
$CheckBoxNum___.Size     = New-Object System.Drawing.Size($Column4BoxWidth,$Column4BoxHeight) 
# Populates to PoSH-ACME GUI
$PoShACME.Controls.Add($CheckBoxNum___)

#>








<#

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



#>




























# ============================================================================================================================================================
# ============================================================================================================================================================
# Retrieve Domain Information
# ============================================================================================================================================================
# ============================================================================================================================================================

<#
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


















# ============================================================================================================================================================
# Column 3
# ============================================================================================================================================================

# Varables to Control Column 3
$Column3RightAlignment   = 475
$Column3RowLocation      = 10
$Column3BoxWidth         = 300
$Column3BoxHeight        = 22
$Column3RowLocationShift = 26


# creates the label
$SingleTargetLabel           = New-Object System.Windows.Forms.Label
$SingleTargetLabel.Location  = New-Object System.Drawing.Size(($Column3RightAlignment - 2),($Column3RowLocation)) 
$SingleTargetLabel.Size      = New-Object System.Drawing.Size(300,$Column3BoxHeight)
$SingleTargetLabel.Text      = "Select How To Collect Data:"
$SingleTargetLabel.Font      = "Microsoft Sans Serif,12"
$SingleTargetLabel.ForeColor = "Blue"
$PoShACME.Controls.Add($SingleTargetLabel)  


# Shift Row Location
$Column3RowLocation += $Column3RowLocationShift


# creates the label
$ImportListCheckBox          = New-Object System.Windows.Forms.Checkbox
$ImportListCheckBox.Name     = "Import List From Text File:"
$ImportListCheckBox.Text     = "$($ImportListCheckBox.Name)"
$ImportListCheckBox.TabIndex = 2
$ImportListCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$ImportListCheckBox.Location = New-Object System.Drawing.Size($Column3RightAlignment,($Column3RowLocation + 2)) 
$ImportListCheckBox.Size     = New-Object System.Drawing.Size(($Column3BoxWidth - 88),$Column3BoxHeight)
$ImportListCheckBox.Add_Click({
    If ($ImportListCheckBox.Checked -eq $true){
        $DomainGeneratedCheckBox.Checked     = $false
        $DomainGeneratedAutoCheckBox.Checked = $false
        $SingleHostIPCheckBox.Checked        = $false
        $SingleHostIPSelectCheckBox.Checked  = $false

    }
})
$PoShACME.Controls.Add($ImportListCheckBox)
# Turn off the update of the display on the click of the control.
#$ImportListCheckBox.AutoCheck  =  $true

#$ImportListCheckBox.Add_CheckStateChanged({
#    if ($CheckBoxNum01.checked) {$CheckBoxNum00.Enabled = $false}
#    else {$CheckBoxNum00.Enabled = $true}
#})


# Import List From File
$ImportListButton          = New-Object System.Windows.Forms.Button
$ImportListButton.Text     = "Import Hosts/IPs"
$ImportListButton.Location = New-Object System.Drawing.Size(($Column3RightAlignment + 220),$Column3RowLocation)
$ImportListButton.Size     = New-Object System.Drawing.Size(110,$Column3BoxHeight) 
$PoShACME.Controls.Add($ImportListButton) 
$ImportListButton.add_click({
    $ImportListCheckBox.Checked          = $true
    $DomainGeneratedCheckBox.Checked     = $false
    $DomainGeneratedAutoCheckBox.Checked = $false
    $SingleHostIPCheckBox.Checked        = $false
    $SingleHostIPSelectCheckBox.Checked  = $false

    . ListTextFile

    $MainListBox.Items.Clear();   
    $MainListBox.Items.Insert(0,"Collect Data From:")
    $MainListBox.Items.Insert(0,"$file_Name")
    foreach ($Computer in $ComputerList) {
        [void] $MainListBox.Items.Insert(0,"$Computer")
    }

    $ComputerListBox.Items.Clear()
    foreach ($Computer in $ComputerList) {
        [void] $ComputerListBox.Items.Add("$Computer")
    }
})


# Shift Row Location
$Column3RowLocation += $Column3RowLocationShift + 10


# creates the label
$DomainGeneratedCheckBox          = New-Object System.Windows.Forms.Checkbox
$DomainGeneratedCheckBox.Name     = "Generate List From Domain:"
$DomainGeneratedCheckBox.Text     = "$($DomainGeneratedCheckBox.Name)"
$DomainGeneratedCheckBox.TabIndex = 2
$DomainGeneratedCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$DomainGeneratedCheckBox.Location = New-Object System.Drawing.Size($Column3RightAlignment,($Column3RowLocation)) 
$DomainGeneratedCheckBox.Size     = New-Object System.Drawing.Size(($Column3BoxWidth - 88),$Column3BoxHeight)
$DomainGeneratedCheckBox.Add_Click({
    If ($DomainGeneratedCheckBox.Checked -eq $true){
        $DomainGeneratedAutoCheckBox.Checked = $true
        $ImportListCheckBox.Checked          = $false
        $SingleHostIPCheckBox.Checked        = $false
        $SingleHostIPSelectCheckBox.Checked  = $false
    }
    If ($DomainGeneratedCheckBox.Checked -eq $false){
        $DomainGeneratedAutoCheckBox.Checked = $false
    }
})
$PoShACME.Controls.Add($DomainGeneratedCheckBox)


$DomainGeneratedAutoCheckBox          = New-Object System.Windows.Forms.Checkbox
$DomainGeneratedAutoCheckBox.Name     = "Auto Pull"
$DomainGeneratedAutoCheckBox.Text     = "$($DomainGeneratedAutoCheckBox.Name)"
$DomainGeneratedAutoCheckBox.TabIndex = 2
$DomainGeneratedAutoCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$DomainGeneratedAutoCheckBox.Location = New-Object System.Drawing.Size(($Column3RightAlignment + 221),$Column3RowLocation)
$DomainGeneratedAutoCheckBox.Size     = New-Object System.Drawing.Size((100),$Column3BoxHeight)
$DomainGeneratedAutoCheckBox.Add_Click({
    If ($DomainGeneratedAutoCheckBox.Checked -eq $true){
        $DomainGeneratedCheckBox.Checked    = $true
        $ImportListCheckBox.Checked         = $false
        $SingleHostIPCheckBox.Checked       = $false
        $SingleHostIPSelectCheckBox.Checked = $false
    }
})
$PoShACME.Controls.Add($DomainGeneratedAutoCheckBox)


# Shift Row Location
$Column3RowLocation += $Column3RowLocationShift


$DomainGeneratedTextBox          = New-Object System.Windows.Forms.TextBox
$DomainGeneratedTextBox.Text     = "<Domain Name>" #Default Content
$DomainGeneratedTextBox.Location = New-Object System.Drawing.Size(($Column3RightAlignment) ,$Column3RowLocation)
$DomainGeneratedTextBox.Size     = New-Object System.Drawing.Size(($Column3BoxWidth - 90),$Column3BoxHeight)
$DomainGeneratedListButton.add_click({
    $DomainGeneratedAutoCheckBox.Checked = $true
})
$PoShACME.Controls.Add($DomainGeneratedTextBox)


# All Domain Computers Button
$DomainGeneratedListButton          = New-Object System.Windows.Forms.Button
$DomainGeneratedListButton.Text     = "Import Hosts/IPs"
$DomainGeneratedListButton.Location = New-Object System.Drawing.Size(($Column3RightAlignment + 220),($Column3RowLocation - 1))
$DomainGeneratedListButton.Size     = New-Object System.Drawing.Size(110,$Column3BoxHeight)
$PoShACME.Controls.Add($DomainGeneratedListButton) 
$DomainGeneratedListButton.add_click({
    $DomainGeneratedCheckBox.Checked     = $true
    $ImportListCheckBox.Checked          = $false
    $SingleHostIPCheckBox.Checked        = $false
    $SingleHostIPSelectCheckBox.Checked  = $false

    If ($DomainGeneratedAutoCheckBox.Checked  -eq $true){. ListComputers "Auto"}
    else {. ListComputers "Manual" "$($DomainGeneratedTextBox.Text)"}


    $MainListBox.Items.Clear();   
    $MainListBox.Items.Insert(0,"Collect Data From:")
    foreach ($Computer in $ComputerList) {
        [void] $MainListBox.Items.Insert(0,"$Computer")
    }

    $ComputerListBox.Items.Clear()
    foreach ($Computer in $ComputerList) {
        [void] $ComputerListBox.Items.Add("$Computer")
    }

#    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic")
#    $verify = [Microsoft.VisualBasic.Interaction]::MsgBox("Yes: Auto Pull Domain Hosts`nNo:  Manual Entry",'YesNoCancel,Question', "Confirmation")
#    switch ($verify) {
#    'Yes'    {ListComputers "Auto"}
#    'No'     {ListComputers "Manual"}
#    'Cancel' {break}
#    }
})
$PoShACME.Controls.Add($DomainGeneratedTextBox)


# Shift Row Location
$Column3RowLocation += $Column3RowLocationShift + 10


# creates the label
$SingleHostIPCheckBox          = New-Object System.Windows.Forms.Checkbox
$SingleHostIPCheckBox.Name     = "Enter A Single Hostname/IP:"
$SingleHostIPCheckBox.Text     = "$($SingleHostIPCheckBox.Name)"
$SingleHostIPCheckBox.TabIndex = 2
$SingleHostIPCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$SingleHostIPCheckBox.Location = New-Object System.Drawing.Size($Column3RightAlignment,($Column3RowLocation)) 
$SingleHostIPCheckBox.Size     = New-Object System.Drawing.Size(($Column3BoxWidth - 88),$Column3BoxHeight)
$SingleHostIPCheckBox.Add_Click({
    If ($SingleHostIPCheckBox.Checked  -eq $true){
        $ImportListCheckBox.Checked          = $false
        $DomainGeneratedCheckBox.Checked     = $false
        $DomainGeneratedAutoCheckBox.Checked = $false
        $SingleHostIPSelectCheckBox.Checked  = $false
    }
})
$PoShACME.Controls.Add($SingleHostIPCheckBox)

#mark
# Single Host / IP Address
$SingleHostIPAddButton          = New-Object System.Windows.Forms.Button
$SingleHostIPAddButton.Text     = "Add To List"
$SingleHostIPAddButton.Location = New-Object System.Drawing.Size(($Column3RightAlignment + 220),$Column3RowLocation)
$SingleHostIPAddButton.Size     = New-Object System.Drawing.Size(110,$Column3BoxHeight) 
$SingleHostIPAddButton.add_click({
    $ComputerListBox.Items.Insert(0,$SingleHostIPTextBox.Text)
    $DomainGeneratedCheckBox.Checked     = $false
    $DomainGeneratedAutoCheckBox.Checked = $false
    $ImportListCheckBox.Checked          = $false
    $SingleHostIPSelectCheckBox.Checked  = $false
})
$PoShACME.Controls.Add($SingleHostIPAddButton) 


# Shift Row Location
$Column3RowLocation += $Column3RowLocationShift


$SingleHostIPTextBox          = New-Object System.Windows.Forms.TextBox
$SingleHostIPTextBox.Text     = "<Type In A Hostname/IP>"
$SingleHostIPTextBox.Location = New-Object System.Drawing.Size($Column3RightAlignment,($Column3RowLocation + 1))
$SingleHostIPTextBox.Size     = New-Object System.Drawing.Size(210,$Column3BoxHeight)
$DomainGeneratedAutoCheckBox.TabIndex = 2
$DomainGeneratedAutoCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$PoShACME.Controls.Add($SingleHostIPTextBox)


# Single Host / IP Address
$SingleHostIPOKButton          = New-Object System.Windows.Forms.Button
$SingleHostIPOKButton.Text     = "Collect Entered"
$SingleHostIPOKButton.Location = New-Object System.Drawing.Size(($Column3RightAlignment + 220),$Column3RowLocation)
$SingleHostIPOKButton.Size     = New-Object System.Drawing.Size(110,$Column3BoxHeight) 
$SingleHostIPOKButton.add_click({
    $SingleHostIPCheckBox.Checked        = $true
    $ImportListCheckBox.Checked          = $false
    $DomainGeneratedCheckBox.Checked     = $false
    $DomainGeneratedAutoCheckBox.Checked = $false
    $SingleHostIPSelectCheckBox.Checked  = $false

    . SingleEntry

    $MainListBox.Items.Clear();   
    $MainListBox.Items.Insert(0,"Collect Data From:")
    foreach ($Computer in $ComputerList) {
        [void] $MainListBox.Items.Insert(0,"$Computer")
    }
})
$PoShACME.Controls.Add($SingleHostIPOKButton) 


# Shift Row Location
$Column3RowLocation += $Column3RowLocationShift + 10


# creates the label
$SingleHostIPSelectCheckBox          = New-Object System.Windows.Forms.Checkbox
$SingleHostIPSelectCheckBox.Name     = "Select Hosts / IPs From The Right:"
$SingleHostIPSelectCheckBox.Text     = "$($SingleHostIPSelectCheckBox.Name)"
$SingleHostIPSelectCheckBox.TabIndex = 2
$SingleHostIPSelectCheckBox.DataBindings.DefaultDataSourceUpdateMode = 0
$SingleHostIPSelectCheckBox.Location = New-Object System.Drawing.Size($Column3RightAlignment,($Column3RowLocation + 2)) 
$SingleHostIPSelectCheckBox.Size     = New-Object System.Drawing.Size(($Column3BoxWidth - 80),$Column3BoxHeight)
$SingleHostIPSelectCheckBox.Add_Click({
    If ($SingleHostIPSelectCheckBox.Checked -eq $true){
        $ImportListCheckBox.Checked          = $false
        $DomainGeneratedCheckBox.Checked     = $false
        $DomainGeneratedAutoCheckBox.Checked = $false
        $SingleHostIPCheckBox.Checked        = $false
    }
})
$PoShACME.Controls.Add($SingleHostIPSelectCheckBox)


# Select from Computer List ListBox
$SingleTargetSelectButton               = New-Object System.Windows.Forms.Button
$SingleTargetSelectButton.Location      = New-Object System.Drawing.Size(($Column3RightAlignment + 220),($Column3RowLocation))
$SingleTargetSelectButton.Size          = New-Object System.Drawing.Size(110,$Column3BoxHeight)
$SingleTargetSelectButton.Text          = 'Collect Selected'
#$SingleTargetSelectButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$SingleTargetSelectButton.add_click({
    $ImportListCheckBox.Checked          = $false
    $DomainGeneratedCheckBox.Checked     = $false
    $DomainGeneratedAutoCheckBox.Checked = $false
    $SingleHostIPCheckBox.Checked        = $false
    $SingleHostIPSelectCheckBox.Checked  = $true

    . SelectListBoxEntry

    $MainListBox.Items.Clear();   
    $MainListBox.Items.Insert(0,"Collect Data From:")
    foreach ($Computer in $ComputerList) {
        [void] $MainListBox.Items.Insert(0,"$Computer")
    }
})
$PoShACME.AcceptButton = $SingleTargetSelectButton
$PoShACME.Controls.Add($SingleTargetSelectButton) 


# Shift Row Location
$Column3RowLocation += $Column3RowLocationShift

# Shift Row Location
$Column3RowLocation += $Column3RowLocationShift - 3


#This creates a label
$DirectoryListLabel           = New-Object System.Windows.Forms.Label
$DirectoryListLabel.Location  = New-Object System.Drawing.Size($Column3RightAlignment,$Column3RowLocation) 
$DirectoryListLabel.Size      = New-Object System.Drawing.Size(130,$Column3BoxHeight) 
$DirectoryListLabel.Text      = "Results Folder:"
$DirectoryListLabel.Font      = "Microsoft Sans Serif,12"
$DirectoryListLabel.ForeColor = "Blue"
$PoShACME.Controls.Add($DirectoryListLabel)


# Open Folder Button
$DirectoryListBoxUpdate          = New-Object System.Windows.Forms.Button
$DirectoryListBoxUpdate.Text     = "Open"
$DirectoryListBoxUpdate.Location = New-Object System.Drawing.Size(($Column3RightAlignment + 130),$Column3RowLocation)
$DirectoryListBoxUpdate.Size     = New-Object System.Drawing.Size(80,$Column3BoxHeight) 
$DirectoryListBoxUpdate.add_click({
    if (Test-Path -Path $PoShLocation) {Invoke-Item -Path $PoShLocation}
    else {Invoke-Item -Path $PoShHome}
    $DirectoryListBox.Items.Clear();   
    $DirectoryListBox.Items.Add("$PoShLocation")
})
$PoShACME.Controls.Add($DirectoryListBoxUpdate)


# Update DTG Button
$DirectoryListBoxUpdate          = New-Object System.Windows.Forms.Button
$DirectoryListBoxUpdate.Text     = "New Timestamp"
$DirectoryListBoxUpdate.Location = New-Object System.Drawing.Size(($Column3RightAlignment + 140 + 80),$Column3RowLocation)
$DirectoryListBoxUpdate.Size     = New-Object System.Drawing.Size(110,$Column3BoxHeight) 
$DirectoryListBoxUpdate.add_click({
    $global:PoShLocation                = "$PoShHome\$((Get-Date).ToString('yyyy-MM-dd @ HHmm ss'))"
    $DirectoryListBox.Items.Clear();   
    $DirectoryListBox.Items.Add("$PoShLocation")
})
$PoShACME.Controls.Add($DirectoryListBoxUpdate) 


# Shift Row Location
$Column3RowLocation += $Column3RowLocationShift


#This creates the box
$DirectoryListBox          = New-Object System.Windows.Forms.ListBox
$DirectoryListBox.Name     = "DirectoryListBox"
$DirectoryListBox.FormattingEnabled = $True
$DirectoryListBox.Location = New-Object System.Drawing.Size($Column3RightAlignment,$Column3RowLocation) 
$DirectoryListBox.Size     = New-Object System.Drawing.Size(330,$Column3BoxHeight)
$DirectoryListBox.DataBindings.DefaultDataSourceUpdateMode = 0
$DirectoryListBox.TabIndex = 3
$DirectoryListBox.Items.Add("$PoShLocation") | Out-Null
$PoShACME.Controls.Add($DirectoryListBox)


# Shift Row Location
$Column3RowLocation += $Column3RowLocationShift


























# ============================================================================================================================================================
# ============================================================================================================================================================
# Column 4
# ============================================================================================================================================================
# ============================================================================================================================================================

# Varables to Control Column 4
$Column4RightAlignment   = 815
$Column4RowLocation      = 11
$Column4BoxWidth         = 189
$Column4BoxHeight        = 280
$Column4RowLocationShift = 25


# Computer List ListBox
$ComputerListBox               = New-Object System.Windows.Forms.ListBox
$ComputerListBox.Location      = New-Object System.Drawing.Point($Column4RightAlignment,$Column4RowLocation)
$ComputerListBox.Size          = New-Object System.Drawing.Size($Column4BoxWidth,$Column4BoxHeight)
$ComputerListBox.SelectionMode = 'MultiExtended'
$ComputerListBox.Items.Add("This box will auto populate onload with hostsnames / IPs if")
$ComputerListBox.Items.Add("the iplist.txt file exists in the PoSh-ACME Results directory.")
$IPListFile = Get-Content "$PoShHome\iplist.txt"
if (Test-Path -Path $IPListFile) {
    $ComputerListBox.Items.Clear()
    foreach ($Computer in $IPListFile){
        $ComputerListBox.Items.Add("$Computer")
    }
 }
$PoShACME.Controls.Add($ComputerListBox)


# ============================================================================================================================================================
# ============================================================================================================================================================
# Column 5
# ============================================================================================================================================================
# ============================================================================================================================================================

# Varables to Control Column 5
$Column5RightAlignment   = 1015
$Column5RowLocation      = 10
$Column5BoxWidth         = 110
$Column5BoxHeight        = 22
$Column5RowLocationShift = 26


# Clear List
$ComputerListClearButton               = New-Object System.Windows.Forms.Button
$ComputerListClearButton.Location      = New-Object System.Drawing.Size($Column5RightAlignment,$Column5RowLocation)
$ComputerListClearButton.Size          = New-Object System.Drawing.Size($Column5BoxWidth,$Column5BoxHeight)
$ComputerListClearButton.Text          = 'Clear List'
$ComputerListClearButton.add_click({
    $ComputerListBox.Items.Clear()
})
$PoShACME.Controls.Add($ComputerListClearButton) 


# Shift Row Location
$Column5RowLocation += $Column5RowLocationShift


# Remove Selected
$ComputerListRemoveButton               = New-Object System.Windows.Forms.Button
$ComputerListRemoveButton.Location      = New-Object System.Drawing.Size($Column5RightAlignment,$Column5RowLocation)
$ComputerListRemoveButton.Size          = New-Object System.Drawing.Size($Column5BoxWidth,$Column5BoxHeight)
$ComputerListRemoveButton.Text          = 'Remove Selected'
$ComputerListRemoveButton.add_click({
    $ComputerListBox.Items.Remove($ComputerListBox.SelectedItem)
})
$PoShACME.Controls.Add($ComputerListRemoveButton) 


# Shift Row Location
$Column5RowLocation += $Column5RowLocationShift


# Move up
$ComputerListMoveUpButton               = New-Object System.Windows.Forms.Button
$ComputerListMoveUpButton.Location      = New-Object System.Drawing.Size($Column5RightAlignment,$Column5RowLocation)
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
$PoShACME.Controls.Add($ComputerListMoveUpButton) 


# Shift Row Location
$Column5RowLocation += $Column5RowLocationShift

 
# Move Down
$ComputerListMoveDownButton               = New-Object System.Windows.Forms.Button
$ComputerListMoveDownButton.Location      = New-Object System.Drawing.Size($Column5RightAlignment,$Column5RowLocation)
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
$PoShACME.Controls.Add($ComputerListMoveDownButton) 


# Shift Row Location
$Column5RowLocation += $Column5RowLocationShift


# Select All
$ComputerListSelectAllButton               = New-Object System.Windows.Forms.Button
$ComputerListSelectAllButton.Location      = New-Object System.Drawing.Size($Column5RightAlignment,$Column5RowLocation)
$ComputerListSelectAllButton.Size          = New-Object System.Drawing.Size($Column5BoxWidth,$Column5BoxHeight)
$ComputerListSelectAllButton.Text          = 'Select All'
$ComputerListSelectAllButton.add_click({
    for($i = 0; $i -lt $ComputerListBox.Items.Count; $i++) {
        $ComputerListBox.SetSelected($i, $true)
    }
})
$PoShACME.Controls.Add($ComputerListSelectAllButton) 


# Shift Row Location
$Column5RowLocation += $Column5RowLocationShift


# Save
$ComputerListSaveButton               = New-Object System.Windows.Forms.Button
$ComputerListSaveButton.Location      = New-Object System.Drawing.Size($Column5RightAlignment,$Column5RowLocation)
$ComputerListSaveButton.Size          = New-Object System.Drawing.Size($Column5BoxWidth,$Column5BoxHeight)
$ComputerListSaveButton.Text          = "Save Selected"
$ComputerListSaveButton.add_click({
    $iplist = "$PoShHome\iplist.txt"
    Set-Content -Path $iplist -Value ($ComputerListBox.SelectedItems) -Force
    $MainListBox.Items.Clear()
    $MainListBox.Items.Add("The Following Were Saved To $PoShHome\iplist.txt")
    foreach ($line in (Get-Content -Path $iplist)){
        $MainListBox.Items.Add($line)    
    }
})
$PoShACME.Controls.Add($ComputerListSaveButton) 


# Shift Row Location
$Column5RowLocation += $Column5RowLocationShift

# Shift Row Location
$Column5RowLocation += $Column5RowLocationShift - 3


# Ping / Test-Connection
$ComputerListPingButton               = New-Object System.Windows.Forms.Button
$ComputerListPingButton.Location      = New-Object System.Drawing.Size($Column5RightAlignment,$Column5RowLocation)
$ComputerListPingButton.Size          = New-Object System.Drawing.Size($Column5BoxWidth,$Column5BoxHeight)
$ComputerListPingButton.Text          = 'Ping'
$ComputerListPingButton.add_click({
    $MainListBox.Items.Clear()
    foreach ($target in $ComputerListBox.SelectedItems){
        $ping = Test-Connection $target -Count 1 -Quiet
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
$PoShACME.Controls.Add($ComputerListPingButton) 


# Shift Row Location
$Column5RowLocation += $Column5RowLocationShift


# RDP
$ComputerListRDPButton               = New-Object System.Windows.Forms.Button
$ComputerListRDPButton.Location      = New-Object System.Drawing.Size($Column5RightAlignment,$Column5RowLocation)
$ComputerListRDPButton.Size          = New-Object System.Drawing.Size($Column5BoxWidth,$Column5BoxHeight)
$ComputerListRDPButton.Text          = 'RDP'
$ComputerListRDPButton.add_click({
    $mstsc = "mstsc /v:$($ComputerListBox.SelectedItem):3389"
    #mstsc /v:10.10.10.10:3389
    $mstsc
    $MainListBox.Items.Clear()
    $MainListBox.Items.Add("Remote Desktop: $($ComputerListBox.SelectedItem)")
    $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Remote Desktop: $($ComputerListBox.SelectedItem) -- $mstsc"
    $LogMessage | Add-Content -Path $LogFile
})
$PoShACME.Controls.Add($ComputerListRDPButton) 


# Shift Row Location
$Column5RowLocation += $Column5RowLocationShift


# SSH (PSv6)
$ComputerListSSHv6Button          = New-Object System.Windows.Forms.Button
$ComputerListSSHv6Button.Location = New-Object System.Drawing.Size($Column5RightAlignment,$Column5RowLocation)
$ComputerListSSHv6Button.Size     = New-Object System.Drawing.Size($Column5BoxWidth,$Column5BoxHeight)
$ComputerListSSHv6Button.Text     = 'SSH (PSv6)'
$ComputerListSSHv6Button.add_click({
    $oReturn=[System.Windows.Forms.MessageBox]::Show(`
        "Oh darn! This hasn't been implemented yet...`nThis is just a place holder for now.",`
        "PoSh-ACME",`
        [System.Windows.Forms.MessageBoxButtons]::OK)
        switch ($oReturn){
        "OK" {
            #write-host "You pressed OK"
        }
}
#    $SSHv6 = 
#    $SSHv6
#    $MainListBox.Items.Clear()
#    $MainListBox.Items.Add("Remote Desktop To: $($ComputerListBox.SelectedItem)")
#    $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Remote Desktop: $mstsc"
#    $LogMessage | Add-Content -Path $LogFile
})
$PoShACME.Controls.Add($ComputerListSSHv6Button) 


# Shift Row Location
$Column5RowLocation += $Column5RowLocationShift


# Enter-PSSession
$ComputerListPSSessionButton          = New-Object System.Windows.Forms.Button
$ComputerListPSSessionButton.Location = New-Object System.Drawing.Size($Column5RightAlignment,$Column5RowLocation)
$ComputerListPSSessionButton.Size     = New-Object System.Drawing.Size($Column5BoxWidth,$Column5BoxHeight)
$ComputerListPSSessionButton.Text     = "PS Session"
$ComputerListPSSessionButton.add_click({
    $PSSession = Enter-PSSession -ComputerName $($ComputerListBox.SelectedItem) -UseSSL -Credential domain\administrator
    $PSSession
    $MainListBox.Items.Clear()
    $MainListBox.Items.Add("Enter-PSSession: $($ComputerListBox.SelectedItem)")
    $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - Enter-PSSession: $($ComputerListBox.SelectedItem) -- $PSSession"
    $LogMessage | Add-Content -Path $LogFile
})
$PoShACME.Controls.Add($ComputerListPSSessionButton) 


# ============================================================================================================================================================
# ============================================================================================================================================================
# Column 6 - Bottom Right Section
# ============================================================================================================================================================
# ============================================================================================================================================================

# Varables to Control Column 6 - Bottom Right Section
$Column6RightAlignment   = 475
$Column6RowLocation      = $Column5RowLocation
$Column6BoxWidth         = 589
$Column6BoxHeight        = 22
$Column6RowLocationShift = 25
$Column6MainBoxWidth     = 652
$Column6MainBoxHeight    = 240


# Shift Row Location
$Column6RowLocation += $Column6RowLocationShift
$Column6RowLocation += $Column6RowLocationShift


# creates the label
$StatusLabel          = New-Object System.Windows.Forms.Label
$StatusLabel.Location = New-Object System.Drawing.Size($Column6RightAlignment,($Column6RowLocation - 1))
$StatusLabel.Size     = New-Object System.Drawing.Size(60,$Column6BoxHeight)
$StatusLabel.Text     = "Status:"
$StatusLabel.Font      = "Microsoft Sans Serif,10"
$StatusLabel.ForeColor = "Blue"
$PoShACME.Controls.Add($StatusLabel)  

# creates the box
$StatusListBox          = New-Object System.Windows.Forms.ListBox
$StatusListBox.Name     = "StatusListBox"
$StatusListBox.FormattingEnabled = $True
$StatusListBox.Location = New-Object System.Drawing.Size(($Column6RightAlignment + 60),$Column6RowLocation) 
$StatusListBox.Size     = New-Object System.Drawing.Size($Column6BoxWidth,$Column6BoxHeight)
$StatusListBox.DataBindings.DefaultDataSourceUpdateMode = 0
$StatusListBox.TabIndex = 3
$StatusListBox.Items.Add("") | Out-Null
$PoShACME.Controls.Add($StatusListBox)


# Shift Row Location
$Column6RowLocation += $Column6RowLocationShift - 9


# ProgressBar1 Lable
$ProgressBar1Label          = New-Object System.Windows.Forms.Label
$ProgressBar1Label.Location = New-Object System.Drawing.Size(($Column6RightAlignment),($Column6RowLocation - 6))
$ProgressBar1Label.Size     = New-Object System.Drawing.Size(60,($Column6BoxHeight - 2))
$ProgressBar1Label.Text     = "Section:"
$PoShACME.Controls.Add($ProgressBar1Label)  

# ProgressBar1
$ProgressBar1Max       = 0
$ProgressBar1          = New-Object System.Windows.Forms.ProgressBar
$ProgressBar1.Maximum  = $ProgressBar1Max
$ProgressBar1.Minimum  = 0
$ProgressBar1.Location = new-object System.Drawing.Size(($Column6RightAlignment + 60),($Column6RowLocation - 2))
$ProgressBar1.size     = new-object System.Drawing.Size($Column6BoxWidth,10)
$ProgressBar1Count     = 0
$PoSHACME.Controls.Add($ProgressBar1)


# Shift Row Location
$Column6RowLocation += $Column6RowLocationShift - 9


# ProgressBar1 Lable
$ProgressBar2Label          = New-Object System.Windows.Forms.Label
$ProgressBar2Label.Location = New-Object System.Drawing.Size(($Column6RightAlignment),($Column6RowLocation - 2))
$ProgressBar2Label.Size     = New-Object System.Drawing.Size(60,($Column6BoxHeight - 4))
$ProgressBar2Label.Text     = "Overall:"
$PoShACME.Controls.Add($ProgressBar2Label)  

# ProgressBar2
$ProgressBar2Max       = 0
$ProgressBar2          = New-Object System.Windows.Forms.ProgressBar
$ProgressBar2.Maximum  = $ProgressBar2Max
$ProgressBar2.Minimum  = 0
$ProgressBar2.Location = new-object System.Drawing.Size(($Column6RightAlignment + 60),($Column6RowLocation - 2))
$ProgressBar2.size     = new-object System.Drawing.Size($Column6BoxWidth,10)
$ProgressBar2Count      = 0
$PoSHACME.Controls.Add($ProgressBar2)


# Shift Row Location
$Column6RowLocation += $Column6RowLocationShift - 9


# ===================
# Main Message Box
# ===================
$MainListBox          = New-Object System.Windows.Forms.ListBox
$MainListBox.Name     = "MainListBox"
$MainListBox.FormattingEnabled = $True
$MainListBox.Location = New-Object System.Drawing.Size($Column6RightAlignment,$Column6RowLocation) 
$MainListBox.Size     = New-Object System.Drawing.Size($Column6MainBoxWidth,$Column6MainBoxHeight)
$MainListBox.Font     = New-Object System.Drawing.Font("Courier New",8,[System.Drawing.FontStyle]::Regular)
$MainListBox.DataBindings.DefaultDataSourceUpdateMode = 0
$MainListBox.TabIndex = 3
$MainListBox.Items.Add("  ______             ____  __               _____     ____  ___    __  _____  ") | Out-Null
$MainListBox.Items.Add(" |   _  \           /  __||  |             /  _  \   / ___\ |  \  /  | | ___| ") | Out-Null
$MainListBox.Items.Add(" |  |_)  | _____   |  (   |  |___   ____  |  (_)  | / /     |   \/   | | |_   ") | Out-Null
$MainListBox.Items.Add(" |   ___/ /  _  \   \  \  |   _  \ |____| |   _   || |      | |\  /| | |  _|  ") | Out-Null
$MainListBox.Items.Add(" |  |    |  (_)  | __)  | |  | |  |       |  | |  | \ \____ | | \/ | | | |__  ") | Out-Null
$MainListBox.Items.Add(" |__|     \_____/ |____/  |__| |__|       |__| |__|  \____/ |_|    |_| |____| ") | Out-Null
$MainListBox.Items.Add("==============================================================================") | Out-Null
$MainListBox.Items.Add(" Windows Remote Management (WinRM) Is Necessary For Endpoint Data Collection. ") | Out-Null
$MainListBox.Items.Add(" PowerShell - Automated Collection Made Easy (ACME) For The Security Analyst! ") | Out-Null
$MainListBox.Items.Add(" ACME: The Point At Which Something Is The Best, Perfect, Or Most Successful. ") | Out-Null
$MainListBox.Items.Add("==============================================================================") | Out-Null
$MainListBox.Items.Add(" File Name      : PoSh-ACME.ps1                                               ") | Out-Null
$MainListBox.Items.Add(" Version        : v.2.1                                                       ") | Out-Null
$MainListBox.Items.Add(" Author         : high101bro                                                  ") | Out-Null
$MainListBox.Items.Add(" Website        : https://github.com/high101bro/PoSH-ACME                     ") | Out-Null
$MainListBox.Items.Add(" Prerequisite   : PowerShell v2 or Higher                                     ") | Out-Null
$MainListBox.Items.Add("                : WinRM  (Default Port 5986)                                  ") | Out-Null
$MainListBox.Items.Add("                : PSExec (Encoded Within Script As Base64)                    ") | Out-Null
$MainListBox.Items.Add(" Credits        : @WiredPulse Thanks for the training!                        ") | Out-Null
$MainListBox.Items.Add("                : Co-Workers Who Aren't Proficient with PowerShell...         ") | Out-Null
$MainListBox.Items.Add(" Created        : 08 Apr 18                                                   ") | Out-Null
$MainListBox.Items.Add(" Updated        : 28 Aug 18                                                   ") | Out-Null
$PoShACME.Controls.Add($MainListBox)


# ============================================================================================================================================================
# Compile CSV Files
# ============================================================================================================================================================
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
        Add-Content -Path "$LocationToSaveCompiledCSV" $LinesToWrite -Force
    }  
}


# ============================================================================================================================================================
# Unique Findings
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



# Bottom Buttom Location
$BottomButton               = 575
$BottomButtonAlignment      = 5
$BottomButtonAlignmentShift = 110

# Bottom Button Size
$BottomButtonLength         = 100
$BottomButtonHeight         = 20

# Log Button to view logs
$LogButton          = New-Object System.Windows.Forms.Button
$LogButton.Name     = "View Log"
$LogButton.Text     = "$($LogButton.Name)"
$LogButton.TabIndex = 5
$LogButton.DataBindings.DefaultDataSourceUpdateMode = 0
$LogButton.UseVisualStyleBackColor = $True
$LogButton.Location = New-Object System.Drawing.Size($BottomButtonAlignment,$BottomButton)
$LogButton.Size     = New-Object System.Drawing.Size($BottomButtonLength,$BottomButtonHeight)
$LogButton.add_Click({Start-Process notepad.exe $LogFile -PassThru})
$PoShACME.Controls.Add($LogButton)

# CheckBox Script Handler
$ScriptHandlerButtonForCheckboxes= {
#$MonitorCount = 1
#foreach ($count in 1..$MonitorCount){
#    $count
#}
    if (!$TestConnectionsCheckbox.Checked -and `
        !$CheckBoxNum00.Checked -and `
        !$CheckBoxNum01.Checked -and `
        !$CheckBoxNum02.Checked -and `
        !$CheckBoxNum03.Checked -and `
        !$CheckBoxNum04.Checked -and `
        !$CheckBoxNum05.Checked -and `
        !$CheckBoxNum06.Checked -and `
        !$CheckBoxNum07.Checked -and `
        !$CheckBoxNum08.Checked -and `
        !$CheckBoxNum09.Checked -and `
        !$CheckBoxNum10.Checked -and `
        !$CheckBoxNum11.Checked -and `
        !$CheckBoxNum12.Checked -and `
        !$CheckBoxNum13.Checked -and `
        !$CheckBoxNum14.Checked -and `
        !$CheckBoxNum15.Checked -and `
        !$CheckBoxNum16.Checked -and `
        !$CheckBoxNum17.Checked -and `
        !$CheckBoxNum18.Checked -and `
        !$CheckBoxNum19.Checked -and `
        !$CheckBoxNum20.Checked -and `
        !$CheckBoxNum21.Checked -and `
        !$CheckBoxNum22.Checked -and `
        !$CheckBoxNum23.Checked -and `
        !$CheckBoxNum24.Checked -and `
        !$CheckBoxNum25.Checked -and `
        !$CheckBoxNum26.Checked -and `
        !$CheckBoxNum27.Checked -and `
        !$CheckBoxNum28.Checked -and `
        !$CheckBoxNum29.Checked -and `
        !$CheckBoxNum30.Checked -and `
        !$CheckBoxNum31.Checked -and `
        !$CheckBoxNum32.Checked -and `
        !$CheckBoxNum33.Checked -and `
        !$CheckBoxNum34.Checked -and `
        !$CheckBoxNum35.Checked -and `
        !$CheckBoxNum36.Checked -and `
        !$CheckBoxNum37.Checked -and `
        !$CheckBoxNum38.Checked -and `
        !$CheckBoxNum39.Checked -and `
        !$CheckBoxNum40.Checked -and `
        !$CheckBoxNum41.Checked ) {
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
        $MainListBox.Items.Insert(0,"Script Start Time: $CollectionTimerStart")    
        $MainListBox.Items.Insert(0,"")

        # For the Progress Bar
        if ($TestConnectionsCheckbox.Checked){$ProgressBar2 += 1}
        if ($CheckBoxNum00.Checked){$ProgressBar2 += 1}
        if ($CheckBoxNum01.Checked){$ProgressBar2 += 1}
        if ($CheckBoxNum02.Checked){$ProgressBar2 += 1}
        if ($CheckBoxNum03.Checked){$ProgressBar2 += 1}
        if ($CheckBoxNum04.Checked){$ProgressBar2 += 1}
        if ($CheckBoxNum05.Checked){$ProgressBar2 += 1}
        if ($CheckBoxNum06.Checked){$ProgressBar2 += 1}
        if ($CheckBoxNum07.Checked){$ProgressBar2 += 1}
        if ($CheckBoxNum08.Checked){$ProgressBar2 += 1}
        if ($CheckBoxNum09.Checked){$ProgressBar2 += 1}
        if ($CheckBoxNum10.Checked){$ProgressBar2 += 1}
        if ($CheckBoxNum11.Checked){$ProgressBar2 += 1}
        if ($CheckBoxNum12.Checked){$ProgressBar2 += 1}
        if ($CheckBoxNum13.Checked){$ProgressBar2 += 1}
        if ($CheckBoxNum14.Checked){$ProgressBar2 += 1}
        if ($CheckBoxNum15.Checked){$ProgressBar2 += 1}
        if ($CheckBoxNum16.Checked){$ProgressBar2 += 1}
        if ($CheckBoxNum17.Checked){$ProgressBar2 += 1}
        if ($CheckBoxNum18.Checked){$ProgressBar2 += 1}
        if ($CheckBoxNum19.Checked){$ProgressBar2 += 1}
        if ($CheckBoxNum20.Checked){$ProgressBar2 += 1}
        if ($CheckBoxNum21.Checked){$ProgressBar2 += 1}
        if ($CheckBoxNum22.Checked){$ProgressBar2 += 1}
        if ($CheckBoxNum23.Checked){$ProgressBar2 += 1}
        if ($CheckBoxNum24.Checked){$ProgressBar2 += 1}
        if ($CheckBoxNum25.Checked){$ProgressBar2 += 1}
        if ($CheckBoxNum26.Checked){$ProgressBar2 += 1}
        if ($CheckBoxNum27.Checked){$ProgressBar2 += 1}
        if ($CheckBoxNum28.Checked){$ProgressBar2 += 1}
        if ($CheckBoxNum29.Checked){$ProgressBar2 += 1}
        if ($CheckBoxNum30.Checked){$ProgressBar2 += 1}
        if ($CheckBoxNum31.Checked){$ProgressBar2 += 1}
        if ($CheckBoxNum32.Checked){$ProgressBar2 += 1}
        if ($CheckBoxNum33.Checked){$ProgressBar2 += 1}
        if ($CheckBoxNum34.Checked){$ProgressBar2 += 1}
        if ($CheckBoxNum35.Checked){$ProgressBar2 += 1}
        if ($CheckBoxNum36.Checked){$ProgressBar2 += 1}
        if ($CheckBoxNum37.Checked){$ProgressBar2 += 1}
        if ($CheckBoxNum38.Checked){$ProgressBar2 += 1}
        if ($CheckBoxNum39.Checked){$ProgressBar2 += 1}
        if ($CheckBoxNum40.Checked){$ProgressBar2 += 1}
        if ($CheckBoxNum41.Checked){$ProgressBar2 += 1}

        # Runs the Commands
        if ($TestConnectionsCheckbox.Checked){TestConnectionsCheckbox ; $ProgressBar2.Value = $ProgressBar2Count ;  $ProgressBar2Count += 1}
        if ($CheckBoxNum00.Checked){CommandNum00 ; $ProgressBar2.Value = $ProgressBar2Count ;  $ProgressBar2Count += 1}
        if ($CheckBoxNum01.Checked){CommandNum01 ; $ProgressBar2.Value = $ProgressBar2Count ;  $ProgressBar2Count += 1}
        if ($CheckBoxNum02.Checked){CommandNum02 ; $ProgressBar2.Value = $ProgressBar2Count ;  $ProgressBar2Count += 1}
        if ($CheckBoxNum03.Checked){CommandNum03 ; $ProgressBar2.Value = $ProgressBar2Count ;  $ProgressBar2Count += 1}
        if ($CheckBoxNum04.Checked){CommandNum04 ; $ProgressBar2.Value = $ProgressBar2Count ;  $ProgressBar2Count += 1}
        if ($CheckBoxNum05.Checked){CommandNum05 ; $ProgressBar2.Value = $ProgressBar2Count ;  $ProgressBar2Count += 1}
        if ($CheckBoxNum06.Checked){CommandNum06 ; $ProgressBar2.Value = $ProgressBar2Count ;  $ProgressBar2Count += 1}
        if ($CheckBoxNum07.Checked){CommandNum07 ; $ProgressBar2.Value = $ProgressBar2Count ;  $ProgressBar2Count += 1}
        if ($CheckBoxNum08.Checked){CommandNum08 ; $ProgressBar2.Value = $ProgressBar2Count ;  $ProgressBar2Count += 1}
        if ($CheckBoxNum09.Checked){CommandNum09 ; $ProgressBar2.Value = $ProgressBar2Count ;  $ProgressBar2Count += 1}
        if ($CheckBoxNum10.Checked){CommandNum10 ; $ProgressBar2.Value = $ProgressBar2Count ;  $ProgressBar2Count += 1}
        if ($CheckBoxNum11.Checked){CommandNum11 ; $ProgressBar2.Value = $ProgressBar2Count ;  $ProgressBar2Count += 1}
        if ($CheckBoxNum12.Checked){CommandNum12 ; $ProgressBar2.Value = $ProgressBar2Count ;  $ProgressBar2Count += 1}
        if ($CheckBoxNum13.Checked){CommandNum13 ; $ProgressBar2.Value = $ProgressBar2Count ;  $ProgressBar2Count += 1}
        if ($CheckBoxNum14.Checked){CommandNum14 ; $ProgressBar2.Value = $ProgressBar2Count ;  $ProgressBar2Count += 1}
        if ($CheckBoxNum15.Checked){CommandNum15 ; $ProgressBar2.Value = $ProgressBar2Count ;  $ProgressBar2Count += 1}
        if ($CheckBoxNum16.Checked){CommandNum16 ; $ProgressBar2.Value = $ProgressBar2Count ;  $ProgressBar2Count += 1}
        if ($CheckBoxNum17.Checked){CommandNum17 ; $ProgressBar2.Value = $ProgressBar2Count ;  $ProgressBar2Count += 1}
        if ($CheckBoxNum18.Checked){CommandNum18 ; $ProgressBar2.Value = $ProgressBar2Count ;  $ProgressBar2Count += 1}
        if ($CheckBoxNum19.Checked){CommandNum19 ; $ProgressBar2.Value = $ProgressBar2Count ;  $ProgressBar2Count += 1}
        if ($CheckBoxNum20.Checked){CommandNum20 ; $ProgressBar2.Value = $ProgressBar2Count ;  $ProgressBar2Count += 1}
        if ($CheckBoxNum21.Checked){CommandNum21 ; $ProgressBar2.Value = $ProgressBar2Count ;  $ProgressBar2Count += 1}
        if ($CheckBoxNum22.Checked){CommandNum22 ; $ProgressBar2.Value = $ProgressBar2Count ;  $ProgressBar2Count += 1}
        if ($CheckBoxNum23.Checked){CommandNum23 ; $ProgressBar2.Value = $ProgressBar2Count ;  $ProgressBar2Count += 1}
        if ($CheckBoxNum24.Checked){CommandNum24 ; $ProgressBar2.Value = $ProgressBar2Count ;  $ProgressBar2Count += 1}
        if ($CheckBoxNum25.Checked){CommandNum25 ; $ProgressBar2.Value = $ProgressBar2Count ;  $ProgressBar2Count += 1}
        if ($CheckBoxNum26.Checked){CommandNum26 ; $ProgressBar2.Value = $ProgressBar2Count ;  $ProgressBar2Count += 1}
        if ($CheckBoxNum27.Checked){CommandNum27 ; $ProgressBar2.Value = $ProgressBar2Count ;  $ProgressBar2Count += 1}
        if ($CheckBoxNum28.Checked){CommandNum28 ; $ProgressBar2.Value = $ProgressBar2Count ;  $ProgressBar2Count += 1}
        if ($CheckBoxNum29.Checked){CommandNum29 ; $ProgressBar2.Value = $ProgressBar2Count ;  $ProgressBar2Count += 1}
        if ($CheckBoxNum30.Checked){CommandNum30 ; $ProgressBar2.Value = $ProgressBar2Count ;  $ProgressBar2Count += 1}
        if ($CheckBoxNum31.Checked){CommandNum31 ; $ProgressBar2.Value = $ProgressBar2Count ;  $ProgressBar2Count += 1}
        if ($CheckBoxNum32.Checked){CommandNum32 ; $ProgressBar2.Value = $ProgressBar2Count ;  $ProgressBar2Count += 1}
        if ($CheckBoxNum33.Checked){CommandNum33 ; $ProgressBar2.Value = $ProgressBar2Count ;  $ProgressBar2Count += 1}
        if ($CheckBoxNum34.Checked){CommandNum34 ; $ProgressBar2.Value = $ProgressBar2Count ;  $ProgressBar2Count += 1}
        if ($CheckBoxNum35.Checked){CommandNum35 ; $ProgressBar2.Value = $ProgressBar2Count ;  $ProgressBar2Count += 1}
        if ($CheckBoxNum36.Checked){CommandNum36 ; $ProgressBar2.Value = $ProgressBar2Count ;  $ProgressBar2Count += 1}
        if ($CheckBoxNum37.Checked){CommandNum37 ; $ProgressBar2.Value = $ProgressBar2Count ;  $ProgressBar2Count += 1}
        if ($CheckBoxNum38.Checked){CommandNum38 ; $ProgressBar2.Value = $ProgressBar2Count ;  $ProgressBar2Count += 1}
        if ($CheckBoxNum39.Checked){CommandNum39 ; $ProgressBar2.Value = $ProgressBar2Count ;  $ProgressBar2Count += 1}
        if ($CheckBoxNum40.Checked){CommandNum40 ; $ProgressBar2.Value = $ProgressBar2Count ;  $ProgressBar2Count += 1}
        if ($CheckBoxNum41.Checked){CommandNum41 ; $ProgressBar2.Value = $ProgressBar2Count ;  $ProgressBar2Count += 1}

        $MainListBox.Items.Insert(0,"")
        $MainListBox.Items.Insert(0,"Finished Collecting Data!")
 
        $CollectionTimerStop = Get-Date
        $MainListBox.Items.Insert(0,"Script Stop Time: $CollectionTimerStop")

        $CollectionTime = New-TimeSpan -Start $CollectionTimerStart -End $CollectionTimerStop
        $MainListBox.Items.Insert(0,"Total Collection Time: $CollectionTime")


        # Unique Data "<Uncompiled Directory Collection Name>" "<Property used to Unique>" "<Properties to Sort By>" 
        # Example: UniqueData 'Processes (Improved with Hashes and Parent Process Names)' 'Pathname' 'PSComputerName, Name'
        UniqueData "$($CheckBoxNum12.Name)" 'Command'
        #UniqueData 'BIOS''--'
        #UniqueData 'Computer Information''--'
        UniqueData "$($CheckBoxNum13.Name)" 'LocalDateTime'
        UniqueData "$($CheckBoxNum22.Name)" 'ProviderName' 
        ###############UniqueData 'DLLs Loaded by Processes' 'Modules'
        UniqueData "$($CheckBoxNum16.Name)" 'DisplayName'
        UniqueData "$($CheckBoxNum16.Name)" 'PathName'
        #UniqueData 'Drivers - Signed Information''--'
        UniqueData "$($CheckBoxNum17.Name)" 'Path'
        UniqueData "$($CheckBoxNum14.Name)" 'VariableValue'
        ###############UniqueData 'Firewall Rules' '"Rule Name"'
        ###############UniqueData 'Firewall Rules' 'LocalIP'
        ###############UniqueData 'Firewall Rules' 'LocalPort'
        ###############UniqueData 'Firewall Rules' 'RemoteIP'
        ###############UniqueData 'Firewall Rules' 'RemotePort'
        UniqueData "$($CheckBoxNum11.Name)" 'Name'
        #UniqueData 'Logged-On User Information''--'
        #UniqueData 'Logon-Information''--'
        UniqueData "$($CheckBoxNum23.Name)" 'ProviderName'
        #UniqueData 'Memory (RAM) Capacity Information''--'
        #UniqueData 'Memory (RAM) Physical Information''--'
        #UniqueData 'Memory (RAM) Utilization''--'
        #UniqueData 'Memory Performance Monitoring Data''--'
        UniqueData "$($CheckBoxNum03.Name)" '"Executed Process"'
        UniqueData "$($CheckBoxNum04.Name)" '"Executed Process"'
        UniqueData "$($CheckBoxNum03.Name)" '"Foreign Address"'
        UniqueData "$($CheckBoxNum04.Name)" '"Foreign Address"'
        UniqueData "$($CheckBoxNum05.Name)" 'DNSDomainSuffixSearchOrder'
        UniqueData "$($CheckBoxNum26.Name)" 'Manufacturer' 
        UniqueData "$($CheckBoxNum26.Name)" 'Description'
        UniqueData "$($CheckBoxNum26.Name)" 'HardwareID'
        ##################UniqueData 'Printers' 'Name'
        # Processes (Advanced)
        UniqueData "$($CheckBoxNum01.Name)" 'Pathname'
        UniqueData "$($CheckBoxNum01.Name)" 'Hash'
        UniqueData "$($CheckBoxNum01.Name)" 'CommandLine'
        UniqueData "$($CheckBoxNum01.Name)" 'ParentProcessName'
        # Processes (Basic)
        UniqueData "$($CheckBoxNum00.Name)" 'Name'
        UniqueData "$($CheckBoxNum00.Name)" 'Path'
        #UniqueData 'Proxy Rules''--'
        ##################UniqueData 'Scheduled Tasks (schtasks)' 'TaskName'
        ################UniqueData 'Scheduled Tasks (schtasks)' '"Task To Run"'
        #UniqueData 'Security Patches''--'
        UniqueData "$($CheckBoxNum02.Name)" 'PathName'
        UniqueData "$($CheckBoxNum02.Name)" 'Name'
        UniqueData "$($CheckBoxNum25.Name)" 'Path'
        UniqueData "$($CheckBoxNum28.Name)" 'Name'
        UniqueData "$($CheckBoxNum28.Name)" 'Vendor'
        UniqueData "$($CheckBoxNum28.Name)" 'PackageName'
        ###############UniqueData 'System Information' '"OS Name"'
        ###############UniqueData 'System Information' '"OS Version"'
        ###############UniqueData 'System Information' '"System Manufacturer"'
        ###############UniqueData 'System Information' '"Hotfix(s)"'
        UniqueData "$($CheckBoxNum27.Name)" 'Antecedent'
        UniqueData "$($CheckBoxNum27.Name)" 'Dependent'
        #UniqueData 'User Information''--'
        #UniqueData '' ''

    }
}


# Shifts the location of the script to the right
$BottomButtonAlignment += $BottomButtonAlignmentShift


$CompareButton          = New-Object System.Windows.Forms.Button
$CompareButton.Name     = "Compare"
$CompareButton.Text     = "$($CompareButton.Name)"
$CompareButton.TabIndex = 4
$CompareButton.DataBindings.DefaultDataSourceUpdateMode = 0
$CompareButton.UseVisualStyleBackColor = $True
$CompareButton.Location = New-Object System.Drawing.Size($BottomButtonAlignment,$BottomButton)
$CompareButton.Size     = New-Object System.Drawing.Size($BottomButtonLength,$BottomButtonHeight)
$ComputerListSSHv6Button.add_click({
    $oReturn=[System.Windows.Forms.MessageBox]::Show(`
        "Oh darn! This hasn't been implemented yet...`nThis is just a place holder for now.",`
        "PoSh-ACME",`
        [System.Windows.Forms.MessageBoxButtons]::OK)
        switch ($oReturn){
        "OK" {
            #write-host "You pressed OK"
        }
} })
$PoShACME.Controls.Add($CompareButton)


# Shifts the location of the script to the right
$BottomButtonAlignment += $BottomButtonAlignmentShift


$RunScriptButton          = New-Object System.Windows.Forms.Button
$RunScriptButton.Name     = "Run Script"
$RunScriptButton.Text     = "$($RunScriptButton.Name)"
$RunScriptButton.TabIndex = 4
$RunScriptButton.DataBindings.DefaultDataSourceUpdateMode = 0
$RunScriptButton.UseVisualStyleBackColor = $True
$RunScriptButton.Location = New-Object System.Drawing.Size($BottomButtonAlignment,$BottomButton)
$RunScriptButton.Size     = New-Object System.Drawing.Size($BottomButtonLength,$BottomButtonHeight)
#old # This is the location of the button that runs the script
#    $System_Drawing_Point = New-Object System.Drawing.Point
#    $System_Drawing_Point.X = 27
#    $System_Drawing_Point.Y = 156
#    $RunScriptButton.Location = $System_Drawing_Point
#    # This is the button that runs the script
#    $System_Drawing_Size = New-Object System.Drawing.Size
#    $System_Drawing_Size.Width = 75
#    $System_Drawing_Size.Height = 23
#old $RunScriptButton.Size = $System_Drawing_Size
$RunScriptButton.add_Click($ScriptHandlerButtonForCheckboxes)
$PoShACME.Controls.Add($RunScriptButton)


# Shifts the location of the script to the right
$BottomButtonAlignment += $BottomButtonAlignmentShift


$ExitButton          = New-Object System.Windows.Forms.Button
$ExitButton.Name     = "Exit"
$ExitButton.Text     = "$($ExitButton.Name)"
$ExitButton.TabIndex = 5
$ExitButton.DataBindings.DefaultDataSourceUpdateMode = 0
$ExitButton.UseVisualStyleBackColor = $True
$ExitButton.Location = New-Object System.Drawing.Size($BottomButtonAlignment,$BottomButton)
$ExitButton.Size     = New-Object System.Drawing.Size($BottomButtonLength,$BottomButtonHeight) 
$ExitButton.add_Click({$PoShACME.Close()})
#$Handle = start-Process notepad.exe -PassThru
#$ExitButton.add_Click({$Handle | Stop-Process})
    # Will close the GUI. It does not close anything else.
    # $ExitButton.add_Click({$PoShACME.Close()})

    #Will exit the entire PowerShell prompt. If you have launched an executable like Excel, it will still be open in it's own process.
    #$ExitButton.add_Click({exit})  <-- errors
$PoShACME.Controls.Add($ExitButton)



#Save the initial state of the form
$InitialFormWindowState = $PoShACME.WindowState

#Init the OnLoad event to correct the initial state of the form
$PoShACME.add_Load($OnLoadForm_StateCorrection)

#Show the Form
$PoShACME.ShowDialog()| Out-Null

} #End Function

#Call the Function
PoSh_ACME_GUI


#==============
# PSExec64.exe
#==============
# How to Encode PSExec64.exe into Base64
    #$Content = Get-Content -Path "C:\$($env:HOMEPATH)\Desktop\PsExec64.exe" -Encoding Byte
    #$PSExec64Base64 = [System.Convert]::ToBase64String($Content)
    #$PSExec64Base64 | Out-File "C:\Users\Daniel\Desktop\PsExec64Base64Encoded.txt"

# Get the Filehash of PSExec64.exe
    #Get-FileHash -Algorithm MD5 "C:\$($env:HOMEPATH)\PsExec64.exe"

# Hash calculated for PSExec64.exe on 2018-08-27
$PSExec64MD5Hash = "9321C107D1F7E336CDA550A2BF049108"

$PSExec64Base64 = "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g8Qow0iJXCQgVUiL7EiD7CBIiwVEuQEASINlGABIuzKi3y2ZKwAASDvDdW9IjU0Y/xUWiQAASItFGEiJRRD/FVCLAACLwEgxRRD/FWyJAABIjU0gi8BIMUUQ/xX0iAAAi0UgSMHgIEiNTRBIM0UgSDNFEEgzwUi5////////AABII8FIuTOi3y2ZKwAASDvDSA9EwUiJBcG4AQBIi1wkSEj30EiJBbq4AQBIg8QgXcNIiVwkCEiJbCQQSIl0JBhXSIPsIP8VeogAADPbSIv4SIXAdQ/rR0iDwAJmORh190iDwAJmORh17ivHg8ACSGPoSIvN6Gyi//9Ii/BIhcB0EUyLxUiL10iLyOj+V///SIveSIvP/xXSiQAASIvDSItcJDBIi2wkOEiLdCRASIPEIF/DzMxIhckPhAABAABTSIPsIEiL2UiLSRhIOw0kygEAdAXoZVH//0iLSyBIOw0aygEAdAXoU1H//0iLSyhIOw0QygEAdAXoQVH//0iLSzBIOw0GygEAdAXoL1H//0iLSzhIOw38yQEAdAXoHVH//0iLS0BIOw3yyQEAdAXoC1H//0iLS0hIOw3oyQEAdAXo+VD//0iLS2hIOw32yQEAdAXo51D//0iLS3BIOw3syQEAdAXo1VD//0iLS3hIOw3iyQEAdAXow1D//0iLi4AAAABIOw3VyQEAdAXorlD//0iLi4gAAABIOw3IyQEAdAXomVD//0iLi5AAAABIOw27yQEAdAXohFD//0iDxCBbw8zMSIXJdGZTSIPsIEiL2UiLCUg7DQXJAQB0BeheUP//SItLCEg7DfvIAQB0BehMUP//SItLEEg7DfHIAQB0Beg6UP//SItLWEg7DSfJAQB0BegoUP//SItLYEg7DR3JAQB0BegWUP//SIPEIFvDSIXJD4TwAwAAU0iD7CBIi9lIi0kI6PZP//9Ii0sQ6O1P//9Ii0sY6ORP//9Ii0sg6NtP//9Ii0so6NJP//9Ii0sw6MlP//9IiwvowU///0iLS0DouE///0iLS0jor0///0iLS1Dopk///0iLS1jonU///0iLS2DolE///0iLS2joi0///0iLSzjogk///0iLS3DoeU///0iLS3jocE///0iLi4AAAADoZE///0iLi4gAAADoWE///0iLi5AAAADoTE///0iLi5gAAADoQE///0iLi6AAAADoNE///0iLi6gAAADoKE///0iLi7AAAADoHE///0iLi7gAAADoEE///0iLi8AAAADoBE///0iLi8gAAADo+E7//0iLi9AAAADo7E7//0iLi9gAAADo4E7//0iLi+AAAADo1E7//0iLi+gAAADoyE7//0iLi/AAAADovE7//0iLi/gAAADosE7//0iLiwABAADopE7//0iLiwgBAADomE7//0iLixABAADojE7//0iLixgBAADogE7//0iLiyABAADodE7//0iLiygBAADoaE7//0iLizABAADoXE7//0iLizgBAADoUE7//0iLi0ABAADoRE7//0iLi0gBAADoOE7//0iLi1ABAADoLE7//0iLi2gBAADoIE7//0iLi3ABAADoFE7//0iLi3gBAADoCE7//0iLi4ABAADo/E3//0iLi4gBAADo8E3//0iLi5ABAADo5E3//0iLi2ABAADo2E3//0iLi6ABAADozE3//0iLi6gBAADowE3//0iLi7ABAADotE3//0iLi7gBAADoqE3//0iLi8ABAADonE3//0iLi8gBAADokE3//0iLi5gBAADohE3//0iLi9ABAADoeE3//0iLi9gBAADobE3//0iLi+ABAADoYE3//0iLi+gBAADoVE3//0iLi/ABAADoSE3//0iLi/gBAADoPE3//0iLiwACAADoME3//0iLiwgCAADoJE3//0iLixACAADoGE3//0iLixgCAADoDE3//0iLiyACAADoAE3//0iLiygCAADo9Ez//0iLizACAADo6Ez//0iLizgCAADo3Ez//0iLi0ACAADo0Ez//0iLi0gCAADoxEz//0iLi1ACAADouEz//0iLi1gCAADorEz//0iLi2ACAADooEz//0iLi2gCAADolEz//0iLi3ACAADoiEz//0iLi3gCAADofEz//0iLi4ACAADocEz//0iLi4gCAADoZEz//0iLi5ACAADoWEz//0iLi5gCAADoTEz//0iLi6ACAADoQEz//0iLi6gCAADoNEz//0iLi7ACAADoKEz//0iLi7gCAADoHEz//0iDxCBbw8zMQFVBVEFVQVZBV0iD7EBIjWwkMEiJXUBIiXVISIl9UEiLBY6yAQBIM8VIiUUARIt1aDP/RYv5TYvgRIvqRYX2dQdIiwFEi3AE911wQYvOiXwkKBvSSIl8JCCD4gj/wv8V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ZSBhbiBhZ3JlZW1lbnQgYmV0d2VlbiBTeXNpbnRlcm5hbHMgKGEgd2hvbGx5IG93bmVkIHN1YnNpZGlhcnkgb2YgTWljcm9zb2Z0IENvcnBvcmF0aW9uKSBhbmQgeW91LiAgUGxlYXNlIHJlYWQgdGhlbS4gIFRoZXkgYXBwbHkgdG8gdGhlIHNvZnR3YXJlIHlvdSBhcmUgZG93bmxvYWRpbmcgZnJvbSBTeXN0aW50ZXJuYWxzLmNvbSwgd2hpY2ggaW5jbHVkZXMgdGhlIG1lZGlhIG9uIHdoaWNoIHlvdSByZWNlaXZlZCBpdCwgaWYgYW55LiAgVGhlIHRlcm1zIGFsc28gYXBwbHkgdG8gYW55IFN5c2ludGVybmFsc1xwYXIAAABccGFyZFxmaS0zNjNcbGk3MjBcc2IxMjBcc2ExMjBcdHg3MjBcJ2I3XHRhYiB1cGRhdGVzLFxwYXIAAAAAAAAAXHBhcmRcZmktMzYzXGxpNzIwXHNiMTIwXHNhMTIwXCdiN1x0YWIgc3VwcGxlbWVudHMsXHBhcgBcJ2I3XHRhYiBJbnRlcm5ldC1iYXNlZCBzZXJ2aWNlcywgYW5kIFxwYXIAAAAAAABcJ2I3XHRhYiBzdXBwb3J0IHNlcnZpY2VzXHBhcgAAAFxwYXJkXHNiMTIwXHNhMTIwIGZvciB0aGlzIHNvZnR3YXJlLCB1bmxlc3Mgb3RoZXIgdGVybXMgYWNjb21wYW55IHRob3NlIGl0ZW1zLiAgSWYgc28sIHRob3NlIHRlcm1zIGFwcGx5LlxwYXIAAABcYiBCWSBVU0lORyBUSEUgU09GVFdBUkUsIFlPVSBBQ0NFUFQgVEhFU0UgVEVSTVMuICBJRiBZT1UgRE8gTk9UIEFDQ0VQVCBUSEVNLCBETyBOT1QgVVNFIFRIRSBTT0ZUV0FSRS5ccGFyAAAAAAAAXHBhcmRcYnJkcnRcYnJkcnNcYnJkcncxMFxicnNwMjAgXHNiMTIwXHNhMTIwIElmIHlvdSBjb21wbHkgd2l0aCB0aGVzZSBsaWNlbnNlIHRlcm1zLCB5b3UgaGF2ZSB0aGUgcmlnaHRzIGJlbG93LlxwYXIAAAAAAAAAAAAAAABccGFyZFxmaS0zNTdcbGkzNTdcc2IxMjBcc2ExMjBcdHgzNjBcZnMyMCAxLlx0YWJcZnMxOSBJTlNUQUxMQVRJT04gQU5EIFVTRSBSSUdIVFMuICBcYjAgWW91IG1heSBpbnN0YWxsIGFuZCB1c2UgYW55IG51bWJlciBvZiBjb3BpZXMgb2YgdGhlIHNvZnR3YXJlIG9uIHlvdXIgZGV2aWNlcy5cYlxwYXIAAAAAAFxjYXBzXGZzMjAgMi5cdGFiXGZzMTkgU2NvcGUgb2YgTGljZW5zZVxjYXBzMCAuXGIwICAgVGhlIHNvZnR3YXJlIGlzIGxpY2Vuc2VkLCBub3Qgc29sZC4gVGhpcyBhZ3JlZW1lbnQgb25seSBnaXZlcyB5b3Ugc29tZSByaWdodHMgdG8gdXNlIHRoZSBzb2Z0d2FyZS4gIFN5c2ludGVybmFscyByZXNlcnZlcyBhbGwgb3RoZXIgcmlnaHRzLiAgVW5sZXNzIGFwcGxpY2FibGUgbGF3IGdpdmVzIHlvdSBtb3JlIHJpZ2h0cyBkZXNwaXRlIHRoaXMgbGltaXRhdGlvbiwgeW91IG1heSB1c2UgdGhlIHNvZnR3YXJlIG9ubHkgYXMgZXhwcmVzc2x5IHBlcm1pdHRlZCBpbiB0aGlzIGFncmVlbWVudC4gIEluIGRvaW5nIHNvLCB5b3UgbXVzdCBjb21wbHkgd2l0aCBhbnkgdGVjaG5pY2FsIGxpbWl0YXRpb25zIGluIHRoZSBzb2Z0d2FyZSB0aGF0IG9ubHkgYWxsb3cgeW91IHRvIHVzZSBpdCBpbiBjZXJ0YWluIHdheXMuICAgIFlvdSBtYXkgbm90XGJccGFyAFxwYXJkXGZpLTM2M1xsaTcyMFxzYjEyMFxzYTEyMFx0eDcyMFxiMFwnYjdcdGFiIHdvcmsgYXJvdW5kIGFueSB0ZWNobmljYWwgbGltaXRhdGlvbnMgaW4gdGhlIGJpbmFyeSB2ZXJzaW9ucyBvZiB0aGUgc29mdHdhcmU7XHBhcgAAAAAAAAAAAAAAAAAAAFxwYXJkXGZpLTM2M1xsaTcyMFxzYjEyMFxzYTEyMFwnYjdcdGFiIHJldmVyc2UgZW5naW5lZXIsIGRlY29tcGlsZSBvciBkaXNhc3NlbWJsZSB0aGUgYmluYXJ5IHZlcnNpb25zIG9mIHRoZSBzb2Z0d2FyZSwgZXhjZXB0IGFuZCBvbmx5IHRvIHRoZSBleHRlbnQgdGhhdCBhcHBsaWNhYmxlIGxhdyBleHByZXNzbHkgcGVybWl0cywgZGVzcGl0ZSB0aGlzIGxpbWl0YXRpb247XHBhcgAAAAAAAAAAXCdiN1x0YWIgbWFrZSBtb3JlIGNvcGllcyBvZiB0aGUgc29mdHdhcmUgdGhhbiBzcGVjaWZpZWQgaW4gdGhpcyBhZ3JlZW1lbnQgb3IgYWxsb3dlZCBieSBhcHBsaWNhYmxlIGxhdywgZGVzcGl0ZSB0aGlzIGxpbWl0YXRpb247XHBhcgAAAFwnYjdcdGFiIHB1Ymxpc2ggdGhlIHNvZnR3YXJlIGZvciBvdGhlcnMgdG8gY29weTtccGFyAAAAXCdiN1x0YWIgcmVudCwgbGVhc2Ugb3IgbGVuZCB0aGUgc29mdHdhcmU7XHBhcgAAXCdiN1x0YWIgdHJhbnNmZXIgdGhlIHNvZnR3YXJlIG9yIHRoaXMgYWdyZWVtZW50IHRvIGFueSB0aGlyZCBwYXJ0eTsgb3JccGFyAAAAAABcJ2I3XHRhYiB1c2UgdGhlIHNvZnR3YXJlIGZvciBjb21tZXJjaWFsIHNvZnR3YXJlIGhvc3Rpbmcgc2VydmljZXMuXHBhcgAAAAAAAAAAAFxwYXJkXGZpLTM1N1xsaTM1N1xzYjEyMFxzYTEyMFx0eDM2MFxiXGZzMjAgMy5cdGFiIFNFTlNJVElWRSBJTkZPUk1BVElPTi4gXGIwICBQbGVhc2UgYmUgYXdhcmUgdGhhdCwgc2ltaWxhciB0byBvdGhlciBkZWJ1ZyB0b29scyB0aGF0IGNhcHR1cmUgXGxkYmxxdW90ZSBwcm9jZXNzIHN0YXRlXHJkYmxxdW90ZSAgaW5mb3JtYXRpb24sIGZpbGVzIHNhdmVkIGJ5IFN5c2ludGVybmFscyB0b29scyBtYXkgaW5jbHVkZSBwZXJzb25hbGx5IGlkZW50aWZpYWJsZSBvciBvdGhlciBzZW5zaXRpdmUgaW5mb3JtYXRpb24gKHN1Y2ggYXMgdXNlcm5hbWVzLCBwYXNzd29yZHMsIHBhdGhzIHRvIGZpbGVzIGFjY2Vzc2VkLCBhbmQgcGF0aHMgdG8gcmVnaXN0cnkgYWNjZXNzZWQpLiBCeSB1c2luZyB0aGlzIHNvZnR3YXJlLCB5b3UgYWNrbm93bGVkZ2UgdGhhdCB5b3UgYXJlIGF3YXJlIG9mIHRoaXMgYW5kIHRha2Ugc29sZSByZXNwb25zaWJpbGl0eSBmb3IgYW55IHBlcnNvbmFsbHkgaWRlbnRpZmlhYmxlIG9yIG90aGVyIHNlbnNpdGl2ZSBpbmZvcm1hdGlvbiBwcm92aWRlZCB0byBNaWNyb3NvZnQgb3IgYW55IG90aGVyIHBhcnR5IHRocm91Z2ggeW91ciB1c2Ugb2YgdGhlIHNvZnR3YXJlLlxiXHBhcgAAADUuIFx0YWJcZnMxOSBET0NVTUVOVEFUSU9OLlxiMCAgIEFueSBwZXJzb24gdGhhdCBoYXMgdmFsaWQgYWNjZXNzIHRvIHlvdXIgY29tcHV0ZXIgb3IgaW50ZXJuYWwgbmV0d29yayBtYXkgY29weSBhbmQgdXNlIHRoZSBkb2N1bWVudGF0aW9uIGZvciB5b3VyIGludGVybmFsLCByZWZlcmVuY2UgcHVycG9zZXMuXGJccGFyAAAAAAAAAAAAAFxjYXBzXGZzMjAgNi5cdGFiXGZzMTkgRXhwb3J0IFJlc3RyaWN0aW9uc1xjYXBzMCAuXGIwICAgVGhlIHNvZnR3YXJlIGlzIHN1YmplY3QgdG8gVW5pdGVkIFN0YXRlcyBleHBvcnQgbGF3cyBhbmQgcmVndWxhdGlvbnMuICBZb3UgbXVzdCBjb21wbHkgd2l0aCBhbGwgZG9tZXN0aWMgYW5kIGludGVybmF0aW9uYWwgZXhwb3J0IGxhd3MgYW5kIHJlZ3VsYXRpb25zIHRoYXQgYXBwbHkgdG8gdGhlIHNvZnR3YXJlLiAgVGhlc2UgbGF3cyBpbmNsdWRlIHJlc3RyaWN0aW9ucyBvbiBkZXN0aW5hdGlvbnMsIGVuZCB1c2VycyBhbmQgZW5kIHVzZS4gIEZvciBhZGRpdGlvbmFsIGluZm9ybWF0aW9uLCBzZWUge1xjZjFcdWx7XGZpZWxke1wqXGZsZGluc3R7SFlQRVJMSU5LIHd3dy5taWNyb3NvZnQuY29tL2V4cG9ydGluZyB9fXtcZmxkcnNsdHt3d3cubWljcm9zb2Z0LmNvbS9leHBvcnRpbmd9fX19XGNmMVx1bFxmMFxmczE5ICA8e3tcZmllbGR7XCpcZmxkaW5zdHtIWVBFUkxJTksgImh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9leHBvcnRpbmcifX17XGZsZHJzbHR7aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL2V4cG9ydGluZ319fX1cZjBcZnMxOSA+XGNmMFx1bG5vbmUgLlxiXHBhcgAAAAAAAAAAAAAAAFxjYXBzXGZzMjAgNy5cdGFiXGZzMTkgU1VQUE9SVCBTRVJWSUNFUy5cY2FwczAgIFxiMCBCZWNhdXNlIHRoaXMgc29mdHdhcmUgaXMgImFzIGlzLCAiIHdlIG1heSBub3QgcHJvdmlkZSBzdXBwb3J0IHNlcnZpY2VzIGZvciBpdC5cYlxwYXIAAAAAAAAAAFxjYXBzXGZzMjAgOC5cdGFiXGZzMTkgRW50aXJlIEFncmVlbWVudC5cYjBcY2FwczAgICBUaGlzIGFncmVlbWVudCwgYW5kIHRoZSB0ZXJtcyBmb3Igc3VwcGxlbWVudHMsIHVwZGF0ZXMsIEludGVybmV0LWJhc2VkIHNlcnZpY2VzIGFuZCBzdXBwb3J0IHNlcnZpY2VzIHRoYXQgeW91IHVzZSwgYXJlIHRoZSBlbnRpcmUgYWdyZWVtZW50IGZvciB0aGUgc29mdHdhcmUgYW5kIHN1cHBvcnQgc2VydmljZXMuXHBhcgAAAAAAAFxwYXJkXGtlZXBuXGZpLTM2MFxsaTM2MFxzYjEyMFxzYTEyMFx0eDM2MFxjZjJcYlxjYXBzXGZzMjAgOS5cdGFiXGZzMTkgQXBwbGljYWJsZSBMYXdcY2FwczAgLlxwYXIAAAAAAAAAAAAAAAAAAABccGFyZFxmaS0zNjNcbGk3MjBcc2IxMjBcc2ExMjBcdHg3MjBcY2YwXGZzMjAgYS5cdGFiXGZzMTkgVW5pdGVkIFN0YXRlcy5cYjAgICBJZiB5b3UgYWNxdWlyZWQgdGhlIHNvZnR3YXJlIGluIHRoZSBVbml0ZWQgU3RhdGVzLCBXYXNoaW5ndG9uIHN0YXRlIGxhdyBnb3Zlcm5zIHRoZSBpbnRlcnByZXRhdGlvbiBvZiB0aGlzIGFncmVlbWVudCBhbmQgYXBwbGllcyB0byBjbGFpbXMgZm9yIGJyZWFjaCBvZiBpdCwgcmVnYXJkbGVzcyBvZiBjb25mbGljdCBvZiBsYXdzIHByaW5jaXBsZXMuICBUaGUgbGF3cyBvZiB0aGUgc3RhdGUgd2hlcmUgeW91IGxpdmUgZ292ZXJuIGFsbCBvdGhlciBjbGFpbXMsIGluY2x1ZGluZyBjbGFpbXMgdW5kZXIgc3RhdGUgY29uc3VtZXIgcHJvdGVjdGlvbiBsYXdzLCB1bmZhaXIgY29tcGV0aXRpb24gbGF3cywgYW5kIGluIHRvcnQuXGJccGFyAAAAAAAAAAAAXHBhcmRcZmktMzYzXGxpNzIwXHNiMTIwXHNhMTIwXGZzMjAgYi5cdGFiXGZzMTkgT3V0c2lkZSB0aGUgVW5pdGVkIFN0YXRlcy5cYjAgICBJZiB5b3UgYWNxdWlyZWQgdGhlIHNvZnR3YXJlIGluIGFueSBvdGhlciBjb3VudHJ5LCB0aGUgbGF3cyBvZiB0aGF0IGNvdW50cnkgYXBwbHkuXGJccGFyAAAAAAAAAABccGFyZFxmaS0zNTdcbGkzNTdcc2IxMjBcc2ExMjBcdHgzNjBcY2Fwc1xmczIwIDEwLlx0YWJcZnMxOSBMZWdhbCBFZmZlY3QuXGIwXGNhcHMwICAgVGhpcyBhZ3JlZW1lbnQgZGVzY3JpYmVzIGNlcnRhaW4gbGVnYWwgcmlnaHRzLiAgWW91IG1heSBoYXZlIG90aGVyIHJpZ2h0cyB1bmRlciB0aGUgbGF3cyBvZiB5b3VyIGNvdW50cnkuICBZb3UgbWF5IGFsc28gaGF2ZSByaWdodHMgd2l0aCByZXNwZWN0IHRvIHRoZSBwYXJ0eSBmcm9tIHdob20geW91IGFjcXVpcmVkIHRoZSBzb2Z0d2FyZS4gIFRoaXMgYWdyZWVtZW50IGRvZXMgbm90IGNoYW5nZSB5b3VyIHJpZ2h0cyB1bmRlciB0aGUgbGF3cyBvZiB5b3VyIGNvdW50cnkgaWYgdGhlIGxhd3Mgb2YgeW91ciBjb3VudHJ5IGRvIG5vdCBwZXJtaXQgaXQgdG8gZG8gc28uXGJcY2Fwc1xwYXIAAAAAAAAAAAAAAABcZnMyMCAxMS5cdGFiXGZzMTkgRGlzY2xhaW1lciBvZiBXYXJyYW50eS5cY2FwczAgICAgXGNhcHMgVGhlIHNvZnR3YXJlIGlzIGxpY2Vuc2VkICJhcyAtIGlzLiIgIFlvdSBiZWFyIHRoZSByaXNrIG9mIHVzaW5nIGl0LiAgU1lTSU5URVJOQUxTIGdpdmVzIG5vIGV4cHJlc3Mgd2FycmFudGllcywgZ3VhcmFudGVlcyBvciBjb25kaXRpb25zLiAgWW91IG1heSBoYXZlIGFkZGl0aW9uYWwgY29uc3VtZXIgcmlnaHRzIHVuZGVyIHlvdXIgbG9jYWwgbGF3cyB3aGljaCB0aGlzIGFncmVlbWVudCBjYW5ub3QgY2hhbmdlLiAgVG8gdGhlIGV4dGVudCBwZXJtaXR0ZWQgdW5kZXIgeW91ciBsb2NhbCBsYXdzLCBTWVNJTlRFUk5BTFMgZXhjbHVkZXMgdGhlIGltcGxpZWQgd2FycmFudGllcyBvZiBtZXJjaGFudGFiaWxpdHksIGZpdG5lc3MgZm9yIGEgcGFydGljdWxhciBwdXJwb3NlIGFuZCBub24taW5mcmluZ2VtZW50LlxwYXIAAAAAAAAAAAAAAAAAAABccGFyZFxmaS0zNjBcbGkzNjBcc2IxMjBcc2ExMjBcdHgzNjBcZnMyMCAxMi5cdGFiXGZzMTkgTGltaXRhdGlvbiBvbiBhbmQgRXhjbHVzaW9uIG9mIFJlbWVkaWVzIGFuZCBEYW1hZ2VzLiAgWW91IGNhbiByZWNvdmVyIGZyb20gU1lTSU5URVJOQUxTIGFuZCBpdHMgc3VwcGxpZXJzIG9ubHkgZGlyZWN0IGRhbWFnZXMgdXAgdG8gVS5TLiAkNS4wMC4gIFlvdSBjYW5ub3QgcmVjb3ZlciBhbnkgb3RoZXIgZGFtYWdlcywgaW5jbHVkaW5nIGNvbnNlcXVlbnRpYWwsIGxvc3QgcHJvZml0cywgc3BlY2lhbCwgaW5kaXJlY3Qgb3IgaW5jaWRlbnRhbCBkYW1hZ2VzLlxwYXIAAAAAAAAAAAAAAAAAAABccGFyZFxsaTM1N1xzYjEyMFxzYTEyMFxiMFxjYXBzMCBUaGlzIGxpbWl0YXRpb24gYXBwbGllcyB0b1xwYXIAXHBhcmRcZmktMzYzXGxpNzIwXHNiMTIwXHNhMTIwXHR4NzIwXCdiN1x0YWIgYW55dGhpbmcgcmVsYXRlZCB0byB0aGUgc29mdHdhcmUsIHNlcnZpY2VzLCBjb250ZW50IChpbmNsdWRpbmcgY29kZSkgb24gdGhpcmQgcGFydHkgSW50ZXJuZXQgc2l0ZXMsIG9yIHRoaXJkIHBhcnR5IHByb2dyYW1zOyBhbmRccGFyAAAAAAAAAAAAAAAAAAAAXHBhcmRcZmktMzYzXGxpNzIwXHNiMTIwXHNhMTIwXCdiN1x0YWIgY2xhaW1zIGZvciBicmVhY2ggb2YgY29udHJhY3QsIGJyZWFjaCBvZiB3YXJyYW50eSwgZ3VhcmFudGVlIG9yIGNvbmRpdGlvbiwgc3RyaWN0IGxpYWJpbGl0eSwgbmVnbGlnZW5jZSwgb3Igb3RoZXIgdG9ydCB0byB0aGUgZXh0ZW50IHBlcm1pdHRlZCBieSBhcHBsaWNhYmxlIGxhdy5ccGFyAAAAAFxwYXJkXGxpMzYwXHNiMTIwXHNhMTIwIEl0IGFsc28gYXBwbGllcyBldmVuIGlmIFN5c2ludGVybmFscyBrbmV3IG9yIHNob3VsZCBoYXZlIGtub3duIGFib3V0IHRoZSBwb3NzaWJpbGl0eSBvZiB0aGUgZGFtYWdlcy4gIFRoZSBhYm92ZSBsaW1pdGF0aW9uIG9yIGV4Y2x1c2lvbiBtYXkgbm90IGFwcGx5IHRvIHlvdSBiZWNhdXNlIHlvdXIgY291bnRyeSBtYXkgbm90IGFsbG93IHRoZSBleGNsdXNpb24gb3IgbGltaXRhdGlvbiBvZiBpbmNpZGVudGFsLCBjb25zZXF1ZW50aWFsIG9yIG90aGVyIGRhbWFnZXMuXHBhcgAAAAAAAAAAAABccGFyZFxiIFBsZWFzZSBub3RlOiBBcyB0aGlzIHNvZnR3YXJlIGlzIGRpc3RyaWJ1dGVkIGluIFF1ZWJlYywgQ2FuYWRhLCBzb21lIG9mIHRoZSBjbGF1c2VzIGluIHRoaXMgYWdyZWVtZW50IGFyZSBwcm92aWRlZCBiZWxvdyBpbiBGcmVuY2guXHBhcgBccGFyZFxzYjI0MFxsYW5nMTAzNiBSZW1hcnF1ZSA6IENlIGxvZ2ljaWVsIFwnZTl0YW50IGRpc3RyaWJ1XCdlOSBhdSBRdVwnZTliZWMsIENhbmFkYSwgY2VydGFpbmVzIGRlcyBjbGF1c2VzIGRhbnMgY2UgY29udHJhdCBzb250IGZvdXJuaWVzIGNpLWRlc3NvdXMgZW4gZnJhblwnZTdhaXMuXHBhcgAAAAAAAFxwYXJkXHNiMTIwXHNhMTIwIEVYT05cJ2M5UkFUSU9OIERFIEdBUkFOVElFLlxiMCAgTGUgbG9naWNpZWwgdmlzXCdlOSBwYXIgdW5lIGxpY2VuY2UgZXN0IG9mZmVydCBcJ2FiIHRlbCBxdWVsIFwnYmIuIFRvdXRlIHV0aWxpc2F0aW9uIGRlIGNlIGxvZ2ljaWVsIGVzdCBcJ2UwIHZvdHJlIHNldWxlIHJpc3F1ZSBldCBwXCdlOXJpbC4gU3lzaW50ZXJuYWxzIG4nYWNjb3JkZSBhdWN1bmUgYXV0cmUgZ2FyYW50aWUgZXhwcmVzc2UuIFZvdXMgcG91dmV6IGJcJ2U5blwnZTlmaWNpZXIgZGUgZHJvaXRzIGFkZGl0aW9ubmVscyBlbiB2ZXJ0dSBkdSBkcm9pdCBsb2NhbCBzdXIgbGEgcHJvdGVjdGlvbiBkdWVzIGNvbnNvbW1hdGV1cnMsIHF1ZSBjZSBjb250cmF0IG5lIHBldXQgbW9kaWZpZXIuIExhIG91IGVsbGVzIHNvbnQgcGVybWlzZXMgcGFyIGxlIGRyb2l0IGxvY2FsZSwgbGVzIGdhcmFudGllcyBpbXBsaWNpdGVzIGRlIHF1YWxpdFwnZTkgbWFyY2hhbmRlLCBkJ2FkXCdlOXF1YXRpb24gXCdlMCB1biB1c2FnZSBwYXJ0aWN1bGllciBldCBkJ2Fic2VuY2UgZGUgY29udHJlZmFcJ2U3b24gc29udCBleGNsdWVzLlxwYXIAAAAAAAAAAAAAAABccGFyZFxrZWVwblxzYjEyMFxzYTEyMFxiIExJTUlUQVRJT04gREVTIERPTU1BR0VTLUlOVFwnYzlSXCdjYVRTIEVUIEVYQ0xVU0lPTiBERSBSRVNQT05TQUJJTElUXCdjOSBQT1VSIExFUyBET01NQUdFUy5cYjAgICBWb3VzIHBvdXZleiBvYnRlbmlyIGRlIFN5c2ludGVybmFscyBldCBkZSBzZXMgZm91cm5pc3NldXJzIHVuZSBpbmRlbW5pc2F0aW9uIGVuIGNhcyBkZSBkb21tYWdlcyBkaXJlY3RzIHVuaXF1ZW1lbnQgXCdlMCBoYXV0ZXVyIGRlIDUsMDAgJCBVUy4gVm91cyBuZSBwb3V2ZXogcHJcJ2U5dGVuZHJlIFwnZTAgYXVjdW5lIGluZGVtbmlzYXRpb24gcG91ciBsZXMgYXV0cmVzIGRvbW1hZ2VzLCB5IGNvbXByaXMgbGVzIGRvbW1hZ2VzIHNwXCdlOWNpYXV4LCBpbmRpcmVjdHMgb3UgYWNjZXNzb2lyZXMgZXQgcGVydGVzIGRlIGJcJ2U5blwnZTlmaWNlcy5ccGFyAFxsYW5nMTAzMyBDZXR0ZSBsaW1pdGF0aW9uIGNvbmNlcm5lIDpccGFyAAAAAAAAAAAAAAAAAAAAXHBhcmRca2VlcG5cZmktMzYwXGxpNzIwXHNiMTIwXHNhMTIwXHR4NzIwXGxhbmcxMDM2XCdiN1x0YWIgdG91dCAgY2UgcXVpIGVzdCByZWxpXCdlOSBhdSBsb2dpY2llbCwgYXV4IHNlcnZpY2VzIG91IGF1IGNvbnRlbnUgKHkgY29tcHJpcyBsZSBjb2RlKSBmaWd1cmFudCBzdXIgZGVzIHNpdGVzIEludGVybmV0IHRpZXJzIG91IGRhbnMgZGVzIHByb2dyYW1tZXMgdGllcnMgOyBldFxwYXIAAABccGFyZFxmaS0zNjNcbGk3MjBcc2IxMjBcc2ExMjBcdHg3MjBcJ2I3XHRhYiBsZXMgclwnZTljbGFtYXRpb25zIGF1IHRpdHJlIGRlIHZpb2xhdGlvbiBkZSBjb250cmF0IG91IGRlIGdhcmFudGllLCBvdSBhdSB0aXRyZSBkZSByZXNwb25zYWJpbGl0XCdlOSBzdHJpY3RlLCBkZSBuXCdlOWdsaWdlbmNlIG91IGQndW5lIGF1dHJlIGZhdXRlIGRhbnMgbGEgbGltaXRlIGF1dG9yaXNcJ2U5ZSBwYXIgbGEgbG9pIGVuIHZpZ3VldXIuXHBhcgAAAAAAAAAAXHBhcmRcc2IxMjBcc2ExMjAgRWxsZSBzJ2FwcGxpcXVlIFwnZTlnYWxlbWVudCwgbVwnZWFtZSBzaSBTeXNpbnRlcm5hbHMgY29ubmFpc3NhaXQgb3UgZGV2cmFpdCBjb25uYVwnZWV0cmUgbCdcJ2U5dmVudHVhbGl0XCdlOSBkJ3VuIHRlbCBkb21tYWdlLiAgU2kgdm90cmUgcGF5cyBuJ2F1dG9yaXNlIHBhcyBsJ2V4Y2x1c2lvbiBvdSBsYSBsaW1pdGF0aW9uIGRlIHJlc3BvbnNhYmlsaXRcJ2U5IHBvdXIgbGVzIGRvbW1hZ2VzIGluZGlyZWN0cywgYWNjZXNzb2lyZXMgb3UgZGUgcXVlbHF1ZSBuYXR1cmUgcXVlIGNlIHNvaXQsIGlsIHNlIHBldXQgcXVlIGxhIGxpbWl0YXRpb24gb3UgbCdleGNsdXNpb24gY2ktZGVzc3VzIG5lIHMnYXBwbGlxdWVyYSBwYXMgXCdlMCB2b3RyZSBcJ2U5Z2FyZC5ccGFyAFxiIEVGRkVUIEpVUklESVFVRS5cYjAgICBMZSBwclwnZTlzZW50IGNvbnRyYXQgZFwnZTljcml0IGNlcnRhaW5zIGRyb2l0cyBqdXJpZGlxdWVzLiBWb3VzIHBvdXJyaWV6IGF2b2lyIGQnYXV0cmVzIGRyb2l0cyBwclwnZTl2dXMgcGFyIGxlcyBsb2lzIGRlIHZvdHJlIHBheXMuICBMZSBwclwnZTlzZW50IGNvbnRyYXQgbmUgbW9kaWZpZSBwYXMgbGVzIGRyb2l0cyBxdWUgdm91cyBjb25mXCdlOHJlbnQgbGVzIGxvaXMgZGUgdm90cmUgcGF5cyBzaSBjZWxsZXMtY2kgbmUgbGUgcGVybWV0dGVudCBwYXMuXGJccGFyAAAAXHBhcmRcYjBcZnMyMFxsYW5nMTAzM1xwYXIAAAAAAABccGFyZFxzYTIwMFxzbDI3NlxzbG11bHQxXGYxXGZzMjJcbGFuZzlccGFyAH0AAAAAAAAAAAAAAFMAWQBTAEkATgBUAEUAUgBOAEEATABTACAAUwBPAEYAVABXAEEAUgBFACAATABJAEMARQBOAFMARQAgAFQARQBSAE0AUwAKAFQAaABlAHMAZQAgAGwAaQBjAGUAbgBzAGUAIAB0AGUAcgBtAHMAIABhAHIAZQAgAGEAbgAgAGEAZwByAGUAZQBtAGUAbgB0ACAAYgBlAHQAdwBlAGUAbgAgAFMAeQBzAGkAbgB0AGUAcgBuAGEAbABzACgAYQAgAHcAaABvAGwAbAB5ACAAbwB3AG4AZQBkACAAcwB1AGIAcwBpAGQAaQBhAHIAeQAgAG8AZgAgAE0AaQBjAHIAbwBzAG8AZgB0ACAAQwBvAHIAcABvAHIAYQB0AGkAbwBuACkAIABhAG4AZAAgAHkAbwB1AC4AUABsAGUAYQBzAGUAIAByAGUAYQBkACAAdABoAGUAbQAuAFQAaABlAHkAIABhAHAAcABsAHkAIAB0AG8AIAB0AGgAZQAgAHMAbwBmAHQAdwBhAHIAZQAgAHkAbwB1ACAAYQByAGUAIABkAG8AdwBuAGwAbwBhAGQAaQBuAGcAIABmAHIAbwBtACAAdABlAGMAaABuAGUAdAAuAG0AaQBjAHIAbwBzAG8AZgB0AC4AYwBvAG0AIAAvACAAcwB5AHMAaQBuAHQAZQByAG4AYQBsAHMALAAgAHcAaABpAGMAaAAgAGkAbgBjAGwAdQBkAGUAcwAgAHQAaABlACAAbQBlAGQAaQBhACAAbwBuACAAdwBoAGkAYwBoACAAeQBvAHUAIAByAGUAYwBlAGkAdgBlAGQAIABpAHQALAAgAGkAZgAgAGEAbgB5AC4AVABoAGUAIAB0AGUAcgBtAHMAIABhAGwAcwBvACAAYQBwAHAAbAB5ACAAdABvACAAYQBuAHkAIABTAHkAcwBpAG4AdABlAHIAbgBhAGwAcwAKACoAIAB1AHAAZABhAHQAZQBzACwACgAqAHMAdQBwAHAAbABlAG0AZQBuAHQAcwAsAAoAKgBJAG4AdABlAHIAbgBlAHQAIAAtACAAYgBhAHMAZQBkACAAcwBlAHIAdgBpAGMAZQBzACwACgAqAGEAbgBkACAAcwB1AHAAcABvAHIAdAAgAHMAZQByAHYAaQBjAGUAcwAKAGYAbwByACAAdABoAGkAcwAgAHMAbwBmAHQAdwBhAHIAZQAsACAAdQBuAGwAZQBzAHMAIABvAHQAaABlAHIAIAB0AGUAcgBtAHMAIABhAGMAYwBvAG0AcABhAG4AeQAgAHQAaABvAHMAZQAgAGkAdABlAG0AcwAuAEkAZgAgAHMAbwAsACAAdABoAG8AcwBlACAAdABlAHIAbQBzACAAYQBwAHAAbAB5AC4ACgBCAFkAIABVAFMASQBOAEcAIABUAEgARQAgAFMATwBGAFQAVwBBAFIARQAsACAAWQBPAFUAIABBAEMAQwBFAFAAVAAgAFQASABFAFMARQAgAFQARQBSAE0AUwAuAEkARgAgAFkATwBVACAARABPACAATgBPAFQAIABBAEMAQwBFAFAAVAAgAFQASABFAE0ALAAgAEQATwAgAE4ATwBUACAAVQBTAEUAIABUAEgARQAgAFMATwBGAFQAVwBBAFIARQAuAAoACgBJAGYAIAB5AG8AdQAgAGMAbwBtAHAAbAB5ACAAdwBpAHQAaAAgAHQAaABlAHMAZQAgAGwAaQBjAGUAbgBzAGUAIAB0AGUAcgBtAHMALAAgAHkAbwB1ACAAaABhAHYAZQAgAHQAaABlACAAcgBpAGcAaAB0AHMAIABiAGUAbABvAHcALgAKAEkATgBTAFQAQQBMAEwAQQBUAEkATwBOACAAQQBOAEQAIABVAFMARQBSACAAUgBJAEcASABUAFMACgBZAG8AdQAgAG0AYQB5ACAAaQBuAHMAdABhAGwAbAAgAGEAbgBkACAAdQBzAGUAIABhAG4AeQAgAG4AdQBtAGIAZQByACAAbwBmACAAYwBvAHAAaQBlAHMAIABvAGYAIAB0AGgAZQAgAHMAbwBmAHQAdwBhAHIAZQAgAG8AbgAgAHkAbwB1AHIAIABkAGUAdgBpAGMAZQBzAC4ACgAKAFMAQwBPAFAARQAgAE8ARgAgAEwASQBDAEUATgBTAEUACgBUAGgAZQAgAHMAbwBmAHQAdwBhAHIAZQAgAGkAcwAgAGwAaQBjAGUAbgBzAGUAZAAsACAAbgBvAHQAIABzAG8AbABkAC4AVABoAGkAcwAgAGEAZwByAGUAZQBtAGUAbgB0ACAAbwBuAGwAeQAgAGcAaQB2AGUAcwAgAHkAbwB1ACAAcwBvAG0AZQAgAHIAaQBnAGgAdABzACAAdABvACAAdQBzAGUAIAB0AGgAZQAgAHMAbwBmAHQAdwBhAHIAZQAuAFMAeQBzAGkAbgB0AGUAcgBuAGEAbABzACAAcgBlAHMAZQByAHYAZQBzACAAYQBsAGwAIABvAHQAaABlAHIAIAByAGkAZwBoAHQAcwAuAFUAbgBsAGUAcwBzACAAYQBwAHAAbABpAGMAYQBiAGwAZQAgAGwAYQB3ACAAZwBpAHYAZQBzACAAeQBvAHUAIABtAG8AcgBlACAAcgBpAGcAaAB0AHMAIABkAGUAcwBwAGkAdABlACAAdABoAGkAcwAgAGwAaQBtAGkAdABhAHQAaQBvAG4ALAAgAHkAbwB1ACAAbQBhAHkAIAB1AHMAZQAgAHQAaABlACAAcwBvAGYAdAB3AGEAcgBlACAAbwBuAGwAeQAgAGEAcwAgAGUAeABwAHIAZQBzAHMAbAB5ACAAcABlAHIAbQBpAHQAdABlAGQAIABpAG4AIAB0AGgAaQBzACAAYQBnAHIAZQBlAG0AZQBuAHQALgBJAG4AIABkAG8AaQBuAGcAIABzAG8ALAAgAHkAbwB1ACAAbQB1AHMAdAAgAGMAbwBtAHAAbAB5ACAAdwBpAHQAaAAgAGEAbgB5ACAAdABlAGMAaABuAGkAYwBhAGwAIABsAGkAbQBpAHQAYQB0AGkAbwBuAHMAIABpAG4AIAB0AGgAZQAgAHMAbwBmAHQAdwBhAHIAZQAgAHQAaABhAHQAIABvAG4AbAB5ACAAYQBsAGwAbwB3ACAAeQBvAHUAIAB0AG8AIAB1AHMAZQAgAGkAdAAgAGkAbgAgAGMAZQByAHQAYQBpAG4AIAB3AGEAeQBzAC4AWQBvAHUAIABtAGEAeQAgAG4AbwB0AAoAKgAgAHcAbwByAGsAIABhAHIAbwB1AG4AZAAgAGEAbgB5ACAAdABlAGMAaABuAGkAYwBhAGwAIABsAGkAbQBpAHQAYQB0AGkAbwBuAHMAIABpAG4AIAB0AGgAZQAgAHMAbwBmAHQAdwBhAHIAZQA7AAoAKgByAGUAdgBlAHIAcwBlACAAZQBuAGcAaQBuAGUAZQByACwAIABkAGUAYwBvAG0AcABpAGwAZQAgAG8AcgAgAGQAaQBzAGEAcwBzAGUAbQBiAGwAZQAgAHQAaABlACAAcwBvAGYAdAB3AGEAcgBlACwAIABlAHgAYwBlAHAAdAAgAGEAbgBkACAAbwBuAGwAeQAgAHQAbwAgAHQAaABlACAAZQB4AHQAZQBuAHQAIAB0AGgAYQB0ACAAYQBwAHAAbABpAGMAYQBiAGwAZQAgAGwAYQB3ACAAZQB4AHAAcgBlAHMAcwBsAHkAIABwAGUAcgBtAGkAdABzACwAIABkAGUAcwBwAGkAdABlACAAdABoAGkAcwAgAGwAaQBtAGkAdABhAHQAaQBvAG4AOwAKACoAbQBhAGsAZQAgAG0AbwByAGUAIABjAG8AcABpAGUAcwAgAG8AZgAgAHQAaABlACAAcwBvAGYAdAB3AGEAcgBlACAAdABoAGEAbgAgAHMAcABlAGMAaQBmAGkAZQBkACAAaQBuACAAdABoAGkAcwAgAGEAZwByAGUAZQBtAGUAbgB0ACAAbwByACAAYQBsAGwAbwB3AGUAZAAgAGIAeQAgAGEAcABwAGwAaQBjAGEAYgBsAGUAIABsAGEAdwAsACAAZABlAHMAcABpAHQAZQAgAHQAaABpAHMAIABsAGkAbQBpAHQAYQB0AGkAbwBuADsACgAqAHAAdQBiAGwAaQBzAGgAIAB0AGgAZQAgAHMAbwBmAHQAdwBhAHIAZQAgAGYAbwByACAAbwB0AGgAZQByAHMAIAB0AG8AIABjAG8AcAB5ADsACgAqAHIAZQBuAHQALAAgAGwAZQBhAHMAZQAgAG8AcgAgAGwAZQBuAGQAIAB0AGgAZQAgAHMAbwBmAHQAdwBhAHIAZQA7AAoAKgB0AHIAYQBuAHMAZgBlAHIAIAB0AGgAZQAgAHMAbwBmAHQAdwBhAHIAZQAgAG8AcgAgAHQAaABpAHMAIABhAGcAcgBlAGUAbQBlAG4AdAAgAHQAbwAgAGEAbgB5ACAAdABoAGkAcgBkACAAcABhAHIAdAB5ADsAIABvAHIACgAqACAAdQBzAGUAIAB0AGgAZQAgAHMAbwBmAHQAdwBhAHIAZQAgAGYAbwByACAAYwBvAG0AbQBlAHIAYwBpAGEAbAAgAHMAbwBmAHQAdwBhAHIAZQAgAGgAbwBzAHQAaQBuAGcAIABzAGUAcgB2AGkAYwBlAHMALgAKAAoAUwBFAE4AUwBJAFQASQBWAEUAIABJAE4ARgBPAFIATQBBAFQASQBPAE4ACgBQAGwAZQBhAHMAZQAgAGIAZQAgAGEAdwBhAHIAZQAgAHQAaABhAHQALAAgAHMAaQBtAGkAbABhAHIAIAB0AG8AIABvAHQAaABlAHIAIABkAGUAYgB1AGcAIAB0AG8AbwBsAHMAIAB0AGgAYQB0ACAAYwBhAHAAdAB1AHIAZQAgABwgcAByAG8AYwBlAHMAcwAgAHMAdABhAHQAZQAdICAAaQBuAGYAbwByAG0AYQB0AGkAbwBuACwAIABmAGkAbABlAHMAIABzAGEAdgBlAGQAIABiAHkAIABTAHkAcwBpAG4AdABlAHIAbgBhAGwAcwAgAHQAbwBvAGwAcwAgAG0AYQB5ACAAaQBuAGMAbAB1AGQAZQAgAHAAZQByAHMAbwBuAGEAbABsAHkAIABpAGQAZQBuAHQAaQBmAGkAYQBiAGwAZQAgAG8AcgAgAG8AdABoAGUAcgAgAHMAZQBuAHMAaQB0AGkAdgBlACAAaQBuAGYAbwByAG0AYQB0AGkAbwBuACgAcwB1AGMAaAAgAGEAcwAgAHUAcwBlAHIAbgBhAG0AZQBzACwAIABwAGEAcwBzAHcAbwByAGQAcwAsACAAcABhAHQAaABzACAAdABvACAAZgBpAGwAZQBzACAAYQBjAGMAZQBzAHMAZQBkACwAIABhAG4AZAAgAHAAYQB0AGgAcwAgAHQAbwAgAHIAZQBnAGkAcwB0AHIAeQAgAGEAYwBjAGUAcwBzAGUAZAApAC4AQgB5ACAAdQBzAGkAbgBnACAAdABoAGkAcwAgAHMAbwBmAHQAdwBhAHIAZQAsACAAeQBvAHUAIABhAGMAawBuAG8AdwBsAGUAZABnAGUAIAB0AGgAYQB0ACAAeQBvAHUAIABhAHIAZQAgAGEAdwBhAHIAZQAgAG8AZgAgAHQAaABpAHMAIABhAG4AZAAgAHQAYQBrAGUAIABzAG8AbABlACAAcgBlAHMAcABvAG4AcwBpAGIAaQBsAGkAdAB5ACAAZgBvAHIAIABhAG4AeQAgAHAAZQByAHMAbwBuAGEAbABsAHkAIABpAGQAZQBuAHQAaQBmAGkAYQBiAGwAZQAgAG8AcgAgAG8AdABoAGUAcgAgAHMAZQBuAHMAaQB0AGkAdgBlACAAaQBuAGYAbwByAG0AYQB0AGkAbwBuACAAcAByAG8AdgBpAGQAZQBkACAAdABvACAATQBpAGMAcgBvAHMAbwBmAHQAIABvAHIAIABhAG4AeQAgAG8AdABoAGUAcgAgAHAAYQByAHQAeQAgAHQAaAByAG8AdQBnAGgAIAB5AG8AdQByACAAdQBzAGUAIABvAGYAIAB0AGgAZQAgAHMAbwBmAHQAdwBhAHIAZQAuAAoACgBEAE8AQwBVAE0ARQBOAFQAQQBUAEkATwBOAAoAQQBuAHkAIABwAGUAcgBzAG8AbgAgAHQAaABhAHQAIABoAGEAcwAgAHYAYQBsAGkAZAAgAGEAYwBjAGUAcwBzACAAdABvACAAeQBvAHUAcgAgAGMAbwBtAHAAdQB0AGUAcgAgAG8AcgAgAGkAbgB0AGUAcgBuAGEAbAAgAG4AZQB0AHcAbwByAGsAIABtAGEAeQAgAGMAbwBwAHkAIABhAG4AZAAgAHUAcwBlACAAdABoAGUAIABkAG8AYwB1AG0AZQBuAHQAYQB0AGkAbwBuACAAZgBvAHIAIAB5AG8AdQByACAAaQBuAHQAZQByAG4AYQBsACwAIAByAGUAZgBlAHIAZQBuAGMAZQAgAHAAdQByAHAAbwBzAGUAcwAuAAoACgBFAFgAUABPAFIAVAAgAFIARQBTAFQAUgBJAEMAVABJAE8ATgBTAAoAVABoAGUAIABzAG8AZgB0AHcAYQByAGUAIABpAHMAIABzAHUAYgBqAGUAYwB0ACAAdABvACAAVQBuAGkAdABlAGQAIABTAHQAYQB0AGUAcwAgAGUAeABwAG8AcgB0ACAAbABhAHcAcwAgAGEAbgBkACAAcgBlAGcAdQBsAGEAdABpAG8AbgBzAC4AWQBvAHUAIABtAHUAcwB0ACAAYwBvAG0AcABsAHkAIAB3AGkAdABoACAAYQBsAGwAIABkAG8AbQBlAHMAdABpAGMAIABhAG4AZAAgAGkAbgB0AGUAcgBuAGEAdABpAG8AbgBhAGwAIABlAHgAcABvAHIAdAAgAGwAYQB3AHMAIABhAG4AZAAgAHIAZQBnAHUAbABhAHQAaQBvAG4AcwAgAHQAaABhAHQAIABhAHAAcABsAHkAIAB0AG8AIAB0AGgAZQAgAHMAbwBmAHQAdwBhAHIAZQAuAFQAaABlAHMAZQAgAGwAYQB3AHMAIABpAG4AYwBsAHUAZABlACAAcgBlAHMAdAByAGkAYwB0AGkAbwBuAHMAIABvAG4AIABkAGUAcwB0AGkAbgBhAHQAaQBvAG4AcwAsACAAZQBuAGQAIAB1AHMAZQByAHMAIABhAG4AZAAgAGUAbgBkACAAdQBzAGUALgBGAG8AcgAgAGEAZABkAGkAdABpAG8AbgBhAGwAIABpAG4AZgBvAHIAbQBhAHQAaQBvAG4ALAAgAHMAZQBlACAAdwB3AHcALgBtAGkAYwByAG8AcwBvAGYAdAAuAGMAbwBtACAALwAgAGUAeABwAG8AcgB0AGkAbgBnACAALgAKAAoAUwBVAFAAUABPAFIAVAAgAFMARQBSAFYASQBDAEUAUwAKAEIAZQBjAGEAdQBzAGUAIAB0AGgAaQBzACAAcwBvAGYAdAB3AGEAcgBlACAAaQBzACAAIgBhAHMAIABpAHMALAAgACIAIAB3AGUAIABtAGEAeQAgAG4AbwB0ACAAcAByAG8AdgBpAGQAZQAgAHMAdQBwAHAAbwByAHQAIABzAGUAcgB2AGkAYwBlAHMAIABmAG8AcgAgAGkAdAAuAAoACgBFAE4AVABJAFIARQAgAEEARwBSAEUARQBNAEUATgBUAAoAVABoAGkAcwAgAGEAZwByAGUAZQBtAGUAbgB0ACwAIABhAG4AZAAgAHQAaABlACAAdABlAHIAbQBzACAAZgBvAHIAIABzAHUAcABwAGwAZQBtAGUAbgB0AHMALAAgAHUAcABkAGEAdABlAHMALAAgAEkAbgB0AGUAcgBuAGUAdAAgAC0AIABiAGEAcwBlAGQAIABzAGUAcgB2AGkAYwBlAHMAIABhAG4AZAAgAHMAdQBwAHAAbwByAHQAIABzAGUAcgB2AGkAYwBlAHMAIAB0AGgAYQB0ACAAeQBvAHUAIAB1AHMAZQAsACAAYQByAGUAIAB0AGgAZQAgAGUAbgB0AGkAcgBlACAAYQBnAHIAZQBlAG0AZQBuAHQAIABmAG8AcgAgAHQAaABlACAAcwBvAGYAdAB3AGEAcgBlACAAYQBuAGQAIABzAHUAcABwAG8AcgB0ACAAcwBlAHIAdgBpAGMAZQBzAC4ACgAKAEEAUABQAEwASQBDAEEAQgBMAEUAIABMAEEAVwAKAFUAbgBpAHQAZQBkACAAUwB0AGEAdABlAHMALgBJAGYAIAB5AG8AdQAgAGEAYwBxAHUAaQByAGUAZAAgAHQAaABlACAAcwBvAGYAdAB3AGEAcgBlACAAaQBuACAAdABoAGUAIABVAG4AaQB0AGUAZAAgAFMAdABhAHQAZQBzACwAIABXAGEAcwBoAGkAbgBnAHQAbwBuACAAcwB0AGEAdABlACAAbABhAHcAIABnAG8AdgBlAHIAbgBzACAAdABoAGUAIABpAG4AdABlAHIAcAByAGUAdABhAHQAaQBvAG4AIABvAGYAIAB0AGgAaQBzACAAYQBnAHIAZQBlAG0AZQBuAHQAIABhAG4AZAAgAGEAcABwAGwAaQBlAHMAIAB0AG8AIABjAGwAYQBpAG0AcwAgAGYAbwByACAAYgByAGUAYQBjAGgAIABvAGYAIABpAHQALAAgAHIAZQBnAGEAcgBkAGwAZQBzAHMAIABvAGYAIABjAG8AbgBmAGwAaQBjAHQAIABvAGYAIABsAGEAdwBzACAAcAByAGkAbgBjAGkAcABsAGUAcwAuAFQAaABlACAAbABhAHcAcwAgAG8AZgAgAHQAaABlACAAcwB0AGEAdABlACAAdwBoAGUAcgBlACAAeQBvAHUAIABsAGkAdgBlACAAZwBvAHYAZQByAG4AIABhAGwAbAAgAG8AdABoAGUAcgAgAGMAbABhAGkAbQBzACwAIABpAG4AYwBsAHUAZABpAG4AZwAgAGMAbABhAGkAbQBzACAAdQBuAGQAZQByACAAcwB0AGEAdABlACAAYwBvAG4AcwB1AG0AZQByACAAcAByAG8AdABlAGMAdABpAG8AbgAgAGwAYQB3AHMALAAgAHUAbgBmAGEAaQByACAAYwBvAG0AcABlAHQAaQB0AGkAbwBuACAAbABhAHcAcwAsACAAYQBuAGQAIABpAG4AIAB0AG8AcgB0AC4ACgBPAHUAdABzAGkAZABlACAAdABoAGUAIABVAG4AaQB0AGUAZAAgAFMAdABhAHQAZQBzAC4ASQBmACAAeQBvAHUAIABhAGMAcQB1AGkAcgBlAGQAIAB0AGgAZQAgAHMAbwBmAHQAdwBhAHIAZQAgAGkAbgAgAGEAbgB5ACAAbwB0AGgAZQByACAAYwBvAHUAbgB0AHIAeQAsACAAdABoAGUAIABsAGEAdwBzACAAbwBmACAAdABoAGEAdAAgAGMAbwB1AG4AdAByAHkAIABhAHAAcABsAHkALgAKAAoATABFAEcAQQBMACAARQBGAEYARQBDAFQACgBUAGgAaQBzACAAYQBnAHIAZQBlAG0AZQBuAHQAIABkAGUAcwBjAHIAaQBiAGUAcwAgAGMAZQByAHQAYQBpAG4AIABsAGUAZwBhAGwAIAByAGkAZwBoAHQAcwAuAFkAbwB1ACAAbQBhAHkAIABoAGEAdgBlACAAbwB0AGgAZQByACAAcgBpAGcAaAB0AHMAIAB1AG4AZABlAHIAIAB0AGgAZQAgAGwAYQB3AHMAIABvAGYAIAB5AG8AdQByACAAYwBvAHUAbgB0AHIAeQAuAFkAbwB1ACAAbQBhAHkAIABhAGwAcwBvACAAaABhAHYAZQAgAHIAaQBnAGgAdABzACAAdwBpAHQAaAAgAHIAZQBzAHAAZQBjAHQAIAB0AG8AIAB0AGgAZQAgAHAAYQByAHQAeQAgAGYAcgBvAG0AIAB3AGgAbwBtACAAeQBvAHUAIABhAGMAcQB1AGkAcgBlAGQAIAB0AGgAZQAgAHMAbwBmAHQAdwBhAHIAZQAuAFQAaABpAHMAIABhAGcAcgBlAGUAbQBlAG4AdAAgAGQAbwBlAHMAIABuAG8AdAAgAGMAaABhAG4AZwBlACAAeQBvAHUAcgAgAHIAaQBnAGgAdABzACAAdQBuAGQAZQByACAAdABoAGUAIABsAGEAdwBzACAAbwBmACAAeQBvAHUAcgAgAGMAbwB1AG4AdAByAHkAIABpAGYAIAB0AGgAZQAgAGwAYQB3AHMAIABvAGYAIAB5AG8AdQByACAAYwBvAHUAbgB0AHIAeQAgAGQAbwAgAG4AbwB0ACAAcABlAHIAbQBpAHQAIABpAHQAIAB0AG8AIABkAG8AIABzAG8ALgAKAAoARABJAFMAQwBMAEEASQBNAEUAUgAgAE8ARgAgAFcAQQBSAFIAQQBOAFQAWQAKAFQAaABlACAAcwBvAGYAdAB3AGEAcgBlACAAaQBzACAAbABpAGMAZQBuAHMAZQBkACAAIgBhAHMAIAAtACAAaQBzAC4AIgAgAFkAbwB1ACAAYgBlAGEAcgAgAHQAaABlACAAcgBpAHMAawAgAG8AZgAgAHUAcwBpAG4AZwAgAGkAdAAuAFMAeQBzAGkAbgB0AGUAcgBuAGEAbABzACAAZwBpAHYAZQBzACAAbgBvACAAZQB4AHAAcgBlAHMAcwAgAHcAYQByAHIAYQBuAHQAaQBlAHMALAAgAGcAdQBhAHIAYQBuAHQAZQBlAHMAIABvAHIAIABjAG8AbgBkAGkAdABpAG8AbgBzAC4AWQBvAHUAIABtAGEAeQAgAGgAYQB2AGUAIABhAGQAZABpAHQAaQBvAG4AYQBsACAAYwBvAG4AcwB1AG0AZQByACAAcgBpAGcAaAB0AHMAIAB1AG4AZABlAHIAIAB5AG8AdQByACAAbABvAGMAYQBsACAAbABhAHcAcwAgAHcAaABpAGMAaAAgAHQAaABpAHMAIABhAGcAcgBlAGUAbQBlAG4AdAAgAGMAYQBuAG4AbwB0ACAAYwBoAGEAbgBnAGUALgBUAG8AIAB0AGgAZQAgAGUAeAB0AGUAbgB0ACAAcABlAHIAbQBpAHQAdABlAGQAIAB1AG4AZABlAHIAIAB5AG8AdQByACAAbABvAGMAYQBsACAAbABhAHcAcwAsACAAcwB5AHMAaQBuAHQAZQByAG4AYQBsAHMAIABlAHgAYwBsAHUAZABlAHMAIAB0AGgAZQAgAGkAbQBwAGwAaQBlAGQAIAB3AGEAcgByAGEAbgB0AGkAZQBzACAAbwBmACAAbQBlAHIAYwBoAGEAbgB0AGEAYgBpAGwAaQB0AHkALAAgAGYAaQB0AG4AZQBzAHMAIABmAG8AcgAgAGEAIABwAGEAcgB0AGkAYwB1AGwAYQByACAAcAB1AHIAcABvAHMAZQAgAGEAbgBkACAAbgBvAG4AIAAtACAAaQBuAGYAcgBpAG4AZwBlAG0AZQBuAHQALgAKAAoATABJAE0ASQBUAEEAVABJAE8ATgAgAE8ATgAgAEEATgBEACAARQBYAEMATABVAFMASQBPAE4AIABPAEYAIABSAEUATQBFAEQASQBFAFMAIABBAE4ARAAgAEQAQQBNAEEARwBFAFMACgBZAG8AdQAgAGMAYQBuACAAcgBlAGMAbwB2AGUAcgAgAGYAcgBvAG0AIABzAHkAcwBpAG4AdABlAHIAbgBhAGwAcwAgAGEAbgBkACAAaQB0AHMAIABzAHUAcABwAGwAaQBlAHIAcwAgAG8AbgBsAHkAIABkAGkAcgBlAGMAdAAgAGQAYQBtAGEAZwBlAHMAIAB1AHAAIAB0AG8AIABVAC4AUwAuACQANQAuADAAMAAuAFkAbwB1ACAAYwBhAG4AbgBvAHQAIAByAGUAYwBvAHYAZQByACAAYQBuAHkAIABvAHQAaABlAHIAIABkAGEAbQBhAGcAZQBzACwAIABpAG4AYwBsAHUAZABpAG4AZwAgAGMAbwBuAHMAZQBxAHUAZQBuAHQAaQBhAGwALAAgAGwAbwBzAHQAIABwAHIAbwBmAGkAdABzACwAIABzAHAAZQBjAGkAYQBsACwAIABpAG4AZABpAHIAZQBjAHQAIABvAHIAIABpAG4AYwBpAGQAZQBuAHQAYQBsACAAZABhAG0AYQBnAGUAcwAuAAoAVABoAGkAcwAgAGwAaQBtAGkAdABhAHQAaQBvAG4AIABhAHAAcABsAGkAZQBzACAAdABvAAoAKgAgAGEAbgB5AHQAaABpAG4AZwAgAHIAZQBsAGEAdABlAGQAIAB0AG8AIAB0AGgAZQAgAHMAbwBmAHQAdwBhAHIAZQAsACAAcwBlAHIAdgBpAGMAZQBzACwAIABjAG8AbgB0AGUAbgB0ACgAaQBuAGMAbAB1AGQAaQBuAGcAIABjAG8AZABlACkAIABvAG4AIAB0AGgAaQByAGQAIABwAGEAcgB0AHkAIABJAG4AdABlAHIAbgBlAHQAIABzAGkAdABlAHMALAAgAG8AcgAgAHQAaABpAHIAZAAgAHAAYQByAHQAeQAgAHAAcgBvAGcAcgBhAG0AcwA7ACAAYQBuAGQACgAqACAAYwBsAGEAaQBtAHMAIABmAG8AcgAgAGIAcgBlAGEAYwBoACAAbwBmACAAYwBvAG4AdAByAGEAYwB0ACwAIABiAHIAZQBhAGMAaAAgAG8AZgAgAHcAYQByAHIAYQBuAHQAeQAsACAAZwB1AGEAcgBhAG4AdABlAGUAIABvAHIAIABjAG8AbgBkAGkAdABpAG8AbgAsACAAcwB0AHIAaQBjAHQAIABsAGkAYQBiAGkAbABpAHQAeQAsACAAbgBlAGcAbABpAGcAZQBuAGMAZQAsACAAbwByACAAbwB0AGgAZQByACAAdABvAHIAdAAgAHQAbwAgAHQAaABlACAAZQB4AHQAZQBuAHQAIABwAGUAcgBtAGkAdAB0AGUAZAAgAGIAeQAgAGEAcABwAGwAaQBjAGEAYgBsAGUAIABsAGEAdwAuAAoASQB0ACAAYQBsAHMAbwAgAGEAcABwAGwAaQBlAHMAIABlAHYAZQBuACAAaQBmACAAUwB5AHMAaQBuAHQAZQByAG4AYQBsAHMAIABrAG4AZQB3ACAAbwByACAAcwBoAG8AdQBsAGQAIABoAGEAdgBlACAAawBuAG8AdwBuACAAYQBiAG8AdQB0ACAAdABoAGUAIABwAG8AcwBzAGkAYgBpAGwAaQB0AHkAIABvAGYAIAB0AGgAZQAgAGQAYQBtAGEAZwBlAHMALgBUAGgAZQAgAGEAYgBvAHYAZQAgAGwAaQBtAGkAdABhAHQAaQBvAG4AIABvAHIAIABlAHgAYwBsAHUAcwBpAG8AbgAgAG0AYQB5ACAAbgBvAHQAIABhAHAAcABsAHkAIAB0AG8AIAB5AG8AdQAgAGIAZQBjAGEAdQBzAGUAIAB5AG8AdQByACAAYwBvAHUAbgB0AHIAeQAgAG0AYQB5ACAAbgBvAHQAIABhAGwAbABvAHcAIAB0AGgAZQAgAGUAeABjAGwAdQBzAGkAbwBuACAAbwByACAAbABpAG0AaQB0AGEAdABpAG8AbgAgAG8AZgAgAGkAbgBjAGkAZABlAG4AdABhAGwALAAgAGMAbwBuAHMAZQBxAHUAZQBuAHQAaQBhAGwAIABvAHIAIABvAHQAaABlAHIAIABkAGEAbQBhAGcAZQBzAC4ACgBQAGwAZQBhAHMAZQAgAG4AbwB0AGUAIAA6ACAAQQBzACAAdABoAGkAcwAgAHMAbwBmAHQAdwBhAHIAZQAgAGkAcwAgAGQAaQBzAHQAcgBpAGIAdQB0AGUAZAAgAGkAbgAgAFEAdQBlAGIAZQBjACwAIABDAGEAbgBhAGQAYQAsACAAcwBvAG0AZQAgAG8AZgAgAHQAaABlACAAYwBsAGEAdQBzAGUAcwAgAGkAbgAgAHQAaABpAHMAIABhAGcAcgBlAGUAbQBlAG4AdAAgAGEAcgBlACAAcAByAG8AdgBpAGQAZQBkACAAYgBlAGwAbwB3ACAAaQBuACAARgByAGUAbgBjAGgALgAKAFIAZQBtAGEAcgBxAHUAZQAgADoAIABDAGUAIABsAG8AZwBpAGMAaQBlAGwAIADpAHQAYQBuAHQAIABkAGkAcwB0AHIAaQBiAHUA6QAgAGEAdQAgAFEAdQDpAGIAZQBjACwAIABDAGEAbgBhAGQAYQAsACAAYwBlAHIAdABhAGkAbgBlAHMAIABkAGUAcwAgAGMAbABhAHUAcwBlAHMAIABkAGEAbgBzACAAYwBlACAAYwBvAG4AdAByAGEAdAAgAHMAbwBuAHQAIABmAG8AdQByAG4AaQBlAHMAIABjAGkAIAAtACAAZABlAHMAcwBvAHUAcwAgAGUAbgAgAGYAcgBhAG4A5wBhAGkAcwAuAAoACQAJACAAIAAgAEUAWABPAE4AyQBSAEEAVABJAE8ATgAgAEQARQAgAEcAQQBSAEEATgBUAEkARQAuAEwAZQAgAGwAbwBnAGkAYwBpAGUAbAAgAHYAaQBzAOkAIABwAGEAcgAgAHUAbgBlACAAbABpAGMAZQBuAGMAZQAgAGUAcwB0ACAAbwBmAGYAZQByAHQAIACrACAAdABlAGwAIABxAHUAZQBsACAAuwAuAFQAbwB1AHQAZQAgAHUAdABpAGwAaQBzAGEAdABpAG8AbgAgAGQAZQAgAGMAZQAgAGwAbwBnAGkAYwBpAGUAbAAgAGUAcwB0ACAA4AAgAHYAbwB0AHIAZQAgAHMAZQB1AGwAZQAgAHIAaQBzAHEAdQBlACAAZQB0ACAAcADpAHIAaQBsAC4AUwB5AHMAaQBuAHQAZQByAG4AYQBsAHMAIABuACcAYQBjAGMAbwByAGQAZQAgAGEAdQBjAHUAbgBlACAAYQB1AHQAcgBlACAAZwBhAHIAYQBuAHQAaQBlACAAZQB4AHAAcgBlAHMAcwBlAC4AIABWAG8AdQBzACAAcABvAHUAdgBlAHoAIABiAOkAbgDpAGYAaQBjAGkAZQByACAAZABlACAAZAByAG8AaQB0AHMAIABhAGQAZABpAHQAaQBvAG4AbgBlAGwAcwAgAGUAbgAgAHYAZQByAHQAdQAgAGQAdQAgAGQAcgBvAGkAdAAgAGwAbwBjAGEAbAAgAHMAdQByACAAbABhACAAcAByAG8AdABlAGMAdABpAG8AbgAgAGQAdQBlAHMAIABjAG8AbgBzAG8AbQBtAGEAdABlAHUAcgBzACwAIABxAHUAZQAgAGMAZQAgAGMAbwBuAHQAcgBhAHQAIABuAGUAIABwAGUAdQB0ACAAbQBvAGQAaQBmAGkAZQByAC4AIABMAGEAIABvAHUAIABlAGwAbABlAHMAIABzAG8AbgB0ACAAcABlAHIAbQBpAHMAZQBzACAAcABhAHIAIABsAGUAIABkAHIAbwBpAHQAIABsAG8AYwBhAGwAZQAsACAAbABlAHMAIABnAGEAcgBhAG4AdABpAGUAcwAgAGkAbQBwAGwAaQBjAGkAdABlAHMAIABkAGUAIABxAHUAYQBsAGkAdADpACAAbQBhAHIAYwBoAGEAbgBkAGUALAAgAGQAJwBhAGQA6QBxAHUAYQB0AGkAbwBuACAA4AAgAHUAbgAgAHUAcwBhAGcAZQAgAHAAYQByAHQAaQBjAHUAbABpAGUAcgAgAGUAdAAgAGQAJwBhAGIAcwBlAG4AYwBlACAAZABlACAAYwBvAG4AdAByAGUAZgBhAOcAbwBuACAAcwBvAG4AdAAgAGUAeABjAGwAdQBlAHMALgAKAAkACQAgACAAIABMAEkATQBJAFQAQQBUAEkATwBOACAARABFAFMAIABEAE8ATQBNAEEARwBFAFMAIAAtACAASQBOAFQAyQBSAMoAVABTACAARQBUACAARQBYAEMATABVAFMASQBPAE4AIABEAEUAIABSAEUAUwBQAE8ATgBTAEEAQgBJAEwASQBUAMkAIABQAE8AVQBSACAATABFAFMAIABEAE8ATQBNAEEARwBFAFMALgBWAG8AdQBzACAAcABvAHUAdgBlAHoAIABvAGIAdABlAG4AaQByACAAZABlACAAUwB5AHMAaQBuAHQAZQByAG4AYQBsAHMAIABlAHQAIABkAGUAIABzAGUAcwAgAGYAbwB1AHIAbgBpAHMAcwBlAHUAcgBzACAAdQBuAGUAIABpAG4AZABlAG0AbgBpAHMAYQB0AGkAbwBuACAAZQBuACAAYwBhAHMAIABkAGUAIABkAG8AbQBtAGEAZwBlAHMAIABkAGkAcgBlAGMAdABzACAAdQBuAGkAcQB1AGUAbQBlAG4AdAAgAOAAIABoAGEAdQB0AGUAdQByACAAZABlACAANQAsACAAMAAwACAAJAAgAFUAUwAuAFYAbwB1AHMAIABuAGUAIABwAG8AdQB2AGUAegAgAHAAcgDpAHQAZQBuAGQAcgBlACAA4AAgAGEAdQBjAHUAbgBlACAAaQBuAGQAZQBtAG4AaQBzAGEAdABpAG8AbgAgAHAAbwB1AHIAIABsAGUAcwAgAGEAdQB0AHIAZQBzACAAZABvAG0AbQBhAGcAZQBzACwAIAB5ACAAYwBvAG0AcAByAGkAcwAgAGwAZQBzACAAZABvAG0AbQBhAGcAZQBzACAAcwBwAOkAYwBpAGEAdQB4ACwAIABpAG4AZABpAHIAZQBjAHQAcwAgAG8AdQAgAGEAYwBjAGUAcwBzAG8AaQByAGUAcwAgAGUAdAAgAHAAZQByAHQAZQBzACAAZABlACAAYgDpAG4A6QBmAGkAYwBlAHMALgAKAAoACQAJACAAIAAgAEMAZQB0AHQAZQAgAGwAaQBtAGkAdABhAHQAaQBvAG4AIABjAG8AbgBjAGUAcgBuAGUAIAA6AAoAdABvAHUAdAAgAGMAZQAgAHEAdQBpACAAZQBzAHQAIAByAGUAbABpAOkAIABhAHUAIABsAG8AZwBpAGMAaQBlAGwALAAgAGEAdQB4ACAAcwBlAHIAdgBpAGMAZQBzACAAbwB1ACAAYQB1ACAAYwBvAG4AdABlAG4AdQAoAHkAIABjAG8AbQBwAHIAaQBzACAAbABlACAAYwBvAGQAZQApACAAZgBpAGcAdQByAGEAbgB0ACAAcwB1AHIAIABkAGUAcwAgAHMAaQB0AGUAcwAgAEkAbgB0AGUAcgBuAGUAdAAgAHQAaQBlAHIAcwAgAG8AdQAgAGQAYQBuAHMAIABkAGUAcwAgAHAAcgBvAGcAcgBhAG0AbQBlAHMAIAB0AGkAZQByAHMAOwAgAGUAdAAKAGwAZQBzACAAcgDpAGMAbABhAG0AYQB0AGkAbwBuAHMAIABhAHUAIAB0AGkAdAByAGUAIABkAGUAIAB2AGkAbwBsAGEAdABpAG8AbgAgAGQAZQAgAGMAbwBuAHQAcgBhAHQAIABvAHUAIABkAGUAIABnAGEAcgBhAG4AdABpAGUALAAgAG8AdQAgAGEAdQAgAHQAaQB0AHIAZQAgAGQAZQAgAHIAZQBzAHAAbwBuAHMAYQBiAGkAbABpAHQA6QAgAHMAdAByAGkAYwB0AGUALAAgAGQAZQAgAG4A6QBnAGwAaQBnAGUAbgBjAGUAIABvAHUAIABkACcAdQBuAGUAIABhAHUAdAByAGUAIABmAGEAdQB0AGUAIABkAGEAbgBzACAAbABhACAAbABpAG0AaQB0AGUAIABhAHUAdABvAHIAaQBzAOkAZQAgAHAAYQByACAAbABhACAAbABvAGkAIABlAG4AIAB2AGkAZwB1AGUAdQByAC4ACgAKAEUAbABsAGUAIABzACcAYQBwAHAAbABpAHEAdQBlACAA6QBnAGEAbABlAG0AZQBuAHQALAAgAG0A6gBtAGUAIABzAGkAIABTAHkAcwBpAG4AdABlAHIAbgBhAGwAcwAgAGMAbwBuAG4AYQBpAHMAcwBhAGkAdAAgAG8AdQAgAGQAZQB2AHIAYQBpAHQAIABjAG8AbgBuAGEA7gB0AHIAZQAgAGwAJwDpAHYAZQBuAHQAdQBhAGwAaQB0AOkAIABkACcAdQBuACAAdABlAGwAIABkAG8AbQBtAGEAZwBlAC4AIABTAGkAIAB2AG8AdAByAGUAIABwAGEAeQBzACAAbgAnAGEAdQB0AG8AcgBpAHMAZQAgAHAAYQBzACAAbAAnAGUAeABjAGwAdQBzAGkAbwBuACAAbwB1ACAAbABhACAAbABpAG0AaQB0AGEAdABpAG8AbgAgAGQAZQAgAHIAZQBzAHAAbwBuAHMAYQBiAGkAbABpAHQA6QAgAHAAbwB1AHIAIABsAGUAcwAgAGQAbwBtAG0AYQBnAGUAcwAgAGkAbgBkAGkAcgBlAGMAdABzACwAIABhAGMAYwBlAHMAcwBvAGkAcgBlAHMAIABvAHUAIABkAGUAIABxAHUAZQBsAHEAdQBlACAAbgBhAHQAdQByAGUAIABxAHUAZQAgAGMAZQAgAHMAbwBpAHQALAAgAGkAbAAgAHMAZQAgAHAAZQB1AHQAIABxAHUAZQAgAGwAYQAgAGwAaQBtAGkAdABhAHQAaQBvAG4AIABvAHUAIABsACcAZQB4AGMAbAB1AHMAaQBvAG4AIABjAGkAIAAtACAAZABlAHMAcwB1AHMAIABuAGUAIABzACcAYQBwAHAAbABpAHEAdQBlAHIAYQAgAHAAYQBzACAA4AAgAHYAbwB0AHIAZQAgAOkAZwBhAHIAZAAuAAoARQBGAEYARQBUACAASgBVAFIASQBEAEkAUQBVAEUALgBMAGUAIABwAHIA6QBzAGUAbgB0ACAAYwBvAG4AdAByAGEAdAAgAGQA6QBjAHIAaQB0ACAAYwBlAHIAdABhAGkAbgBzACAAZAByAG8AaQB0AHMAIABqAHUAcgBpAGQAaQBxAHUAZQBzAC4AVgBvAHUAcwAgAHAAbwB1AHIAcgBpAGUAegAgAGEAdgBvAGkAcgAgAGQAJwBhAHUAdAByAGUAcwAgAGQAcgBvAGkAdABzACAAcAByAOkAdgB1AHMAIABwAGEAcgAgAGwAZQBzACAAbABvAGkAcwAgAGQAZQAgAHYAbwB0AHIAZQAgAHAAYQB5AHMALgAgAEwAZQAgAHAAcgDpAHMAZQBuAHQAIABjAG8AbgB0AHIAYQB0ACAAbgBlACAAbQBvAGQAaQBmAGkAZQAgAHAAYQBzACAAbABlAHMAIABkAHIAbwBpAHQAcwAgAHEAdQBlACAAdgBvAHUAcwAgAGMAbwBuAGYA6AByAGUAbgB0ACAAbABlAHMAIABsAG8AaQBzACAAZABlACAAdgBvAHQAcgBlACAAcABhAHkAcwAgAHMAaQAgAGMAZQBsAGwAZQBzAC0AYwBpACAAbgBlACAAbABlACAAcABlAHIAbQBlAHQAdABlAG4AdAAgAHAAYQBzAC4ACgAKAAAAAAAAAFMAeQBzAGkAbgB0AGUAcgBuAGEAbABzACAATABpAGMAZQBuAHMAZQAAAAAAAAAAACUAcwAgAEwAaQBjAGUAbgBzAGUAIABBAGcAcgBlAGUAbQBlAG4AdAAAAAAAAAAAAFMAbwBmAHQAdwBhAHIAZQBcAFMAeQBzAGkAbgB0AGUAcgBuAGEAbABzAFwAJQBzAAAAAAAAAAAAUgBpAGMAaABlAGQAMwAyAC4AZABsAGwAAAAAAAAAAABMAGkAYwBlAG4AcwBlACAAQQBnAHIAZQBlAG0AZQBuAHQAAAAAAAAATQBTACAAUwBoAGUAbABsACAARABsAGcAAAAAAAAAAABZAG8AdQAgAGMAYQBuACAAYQBsAHMAbwAgAHUAcwBlACAAdABoAGUAIAAvAGEAYwBjAGUAcAB0AGUAdQBsAGEAIABjAG8AbQBtAGEAbgBkAC0AbABpAG4AZQAgAHMAdwBpAHQAYwBoACAAdABvACAAYQBjAGMAZQBwAHQAIAB0AGgAZQAgAEUAVQBMAEEALgAAAAAAAAAAACYAQQBnAHIAZQBlAAAAAAAmAEQAZQBjAGwAaQBuAGUAAAAAAAAAAAAmAFAAcgBpAG4AdAAAAAAAUgBJAEMASABFAEQASQBUAAAAAAAAAAAARQB1AGwAYQBBAGMAYwBlAHAAdABlAGQAAAAAAAAAAABDb21tYW5kTGluZVRvQXJndlcAAAAAAABTAGgAZQBsAGwAMwAyAC4AZABsAGwAAAAvAGEAYwBjAGUAcAB0AGUAdQBsAGEAAAAtAGEAYwBjAGUAcAB0AGUAdQBsAGEAAAAAAAAAAAAAAFMAbwBmAHQAdwBhAHIAZQBcAE0AaQBjAHIAbwBzAG8AZgB0AFwAdwBpAG4AZABvAHcAcwAgAG4AdABcAGMAdQByAHIAZQBuAHQAdgBlAHIAcwBpAG8AbgAAAAAAAAAAAFAAcgBvAGQAdQBjAHQATgBhAG0AZQAAAGkAbwB0AHUAYQBwAAAAAAAAAAAAAAAAAFMAbwBmAHQAdwBhAHIAZQBcAE0AaQBjAHIAbwBzAG8AZgB0AFwAVwBpAG4AZABvAHcAcwAgAE4AVABcAEMAdQByAHIAZQBuAHQAVgBlAHIAcwBpAG8AbgBcAFMAZQByAHYAZQByAFwAUwBlAHIAdgBlAHIATABlAHYAZQBsAHMAAAAAAAAAAABOAGEAbgBvAFMAZQByAHYAZQByAAAAAABBY2NlcHQgRXVsYSAoWS9OKT8AACVjCgAlAGwAcwAAAFQAaABpAHMAIABpAHMAIAB0AGgAZQAgAGYAaQByAHMAdAAgAHIAdQBuACAAbwBmACAAdABoAGkAcwAgAHAAcgBvAGcAcgBhAG0ALgAgAFkAbwB1ACAAbQB1AHMAdAAgAGEAYwBjAGUAcAB0ACAARQBVAEwAQQAgAHQAbwAgAGMAbwBuAHQAaQBuAHUAZQAuAAoAAAAAAAAAAAAAAAAAAABVAHMAZQAgAC0AYQBjAGMAZQBwAHQAZQB1AGwAYQAgAHQAbwAgAGEAYwBjAGUAcAB0ACAARQBVAEwAQQAuAAoACgAAAAAAAABTAG8AZgB0AHcAYQByAGUAXABTAHkAcwBpAG4AdABlAHIAbgBhAGwAcwAAAAAAAAAlAHMAXAAlAHMAAAAAAAAALwBuAG8AYgBhAG4AbgBlAHIAAAAAAAAALQBuAG8AYgBhAG4AbgBlAHIAAAAAAAAASQBuAHQAZQByAG4AYQBsAE4AYQBtAGUAAAAAAAAAAABGAGkAbABlAFYAZQByAHMAaQBvAG4AAABGAGkAbABlAEQAZQBzAGMAcgBpAHAAdABpAG8AbgAAAEwAZQBnAGEAbABDAG8AcAB5AHIAaQBnAGgAdAAAAAAAQwBvAG0AcABhAG4AeQBOAGEAbQBlAAAACgAlAHMAIAB2ACUAcwAgAC0AIAAlAHMACgAlAHMACgAlAHMACgAKAAAAAAD//gAAXABTAHQAcgBpAG4AZwBGAGkAbABlAEkAbgBmAG8AXAAlADAANABYACUAMAA0AFgAXAAlAHMAAABcAFYAYQByAEYAaQBsAGUASQBuAGYAbwBcAFQAcgBhAG4AcwBsAGEAdABpAG8AbgAAAAAAAAAAAFMAZQBTAGgAdQB0AGQAbwB3AG4AUAByAGkAdgBpAGwAZQBnAGUAAABTAGUAQwBoAGEAbgBnAGUATgBvAHQAaQBmAHkAUAByAGkAdgBpAGwAZQBnAGUAAABTAGUAVQBuAGQAbwBjAGsAUAByAGkAdgBpAGwAZQBnAGUAAAAAAAAAUwBlAEkAbgBjAHIAZQBhAHMAZQBXAG8AcgBrAGkAbgBnAFMAZQB0AFAAcgBpAHYAaQBsAGUAZwBlAAAAAAAAAFMAZQBUAGkAbQBlAFoAbwBuAGUAUAByAGkAdgBpAGwAZQBnAGUAAABOdFNldEluZm9ybWF0aW9uUHJvY2VzcwBOAHQAZABsAGwALgBkAGwAbAAAAAAAAABTAC0AMQAtADEANgAtADQAMAA5ADYAAABDb252ZXJ0U3RyaW5nU2lkVG9TaWRXAABBAGQAdgBhAHAAaQAzADIALgBkAGwAbAAAAAAAAAAAAG4AZQB0AG0AcwBnAC4AZABsAGwAAAAAAA0AAAAgAAAAQgBJAE4AUgBFAFMAAAAAAHcAYgAAAAAAXABcACUAcwBcAEkAUABDACQAAAAAAAAAXABcACUAcwBcAEEARABNAEkATgAkAFwAJQBzAAAAAAANAEMAbwB1AGwAZABuACcAdAAgAGkAbgBzAHQAYQBsAGwAIAAlAHMAIABzAGUAcgB2AGkAYwBlADoACgAAAAAADQBDAG8AdQBsAGQAbgAnAHQAIABhAGMAYwBlAHMAcwAgACUAcwA6AAoAAAAAAAAACgBNAGEAawBlACAAcwB1AHIAZQAgAHQAaABhAHQAIAB0AGgAZQAgAGEAZABtAGkAbgAkACAAcwBoAGEAcgBlACAAaQBzACAAZQBuAGEAYgBsAGUAZAAuAAoAAAAAAAAACgBNAGEAawBlACAAcwB1AHIAZQAgAHQAaABhAHQAIAB0AGgAZQAgAGQAZQBmAGEAdQBsAHQAIABhAGQAbQBpAG4AJAAgAHMAaABhAHIAZQAgAGkAcwAgAGUAbgBhAGIAbABlAGQAIABvAG4AIAAlAHMALgAKAAAAAAAAAAAAAAAKAE0AYQBrAGUAIABzAHUAcgBlACAAdABoAGEAdAAgAGYAaQBsAGUAIABhAG4AZAAgAHAAcgBpAG4AdAAgAHMAaABhAHIAaQBuAGcAIABzAGUAcgB2AGkAYwBlAHMAIABhAHIAZQAgAGUAbgBhAGIAbABlAGQALgAKAAAAAAAAAAoATQBhAGsAZQAgAHMAdQByAGUAIAB0AGgAYQB0ACAAZgBpAGwAZQAgAGEAbgBkACAAcAByAGkAbgB0ACAAcwBoAGEAcgBpAG4AZwAgAHMAZQByAHYAaQBjAGUAcwAgAGEAcgBlACAAZQBuAGEAYgBsAGUAZAAgAG8AbgAgACUAcwAuAAoAAABDAG8AbgBuAGUAYwB0AGkAbgBnACAAdABvACAAbABvAGMAYQBsACAAcwB5AHMAdABlAG0ALgAuAC4AAAAAAAAAQwBvAG4AbgBlAGMAdABpAG4AZwAgAHQAbwAgACUAcwAuAC4ALgAAAA0AVABpAG0A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ZQBuAGUAcgBhAHQAaQBvAG4AIABzAGUAcwBzAGkAbwBuACAAawBlAHkAOgAKAAAADQBFAHIAcgBvAHIAIABzAGUAbgBkAGkAbgBnACAAcwBlAHMAcwBpAG8AbgAgAGsAZQB5ACAAdABvACAAUABzAEUAeABlAGMAIABzAGUAcgB2AGkAYwBlADoACgAAAAAAJQBzAC4AZQB4AGUAAAAAAFAAUwBFAFgARQBTAFYAQwBfAEEAUgBNAAAAAAAAAAAAUABTAEUAWABFAFMAVgBDAAAAAAAAAAAAAAAAAAAAAAANAEMAbwBuAG4AZQBjAHQAaQBuAGcAIAB3AGkAdABoACAAUABzAEUAeABlAGMAIABzAGUAcgB2AGkAYwBlACAAbwBuACAAJQBzAC4ALgAuAAAAAAAAAAAAXABcACUAcwBcAHAAaQBwAGUAXAAlAHMAAAAAAAAAAAAAAAAAAAAAAA0ARQByAHIAbwByACAAZQBzAHQAYQBiAGwAaQBzAGgAaQBuAGcAIABjAG8AbQBtAHUAbgBpAGMAYQB0AGkAbwBuACAAdwBpAHQAaAAgAFAAcwBFAHgAZQBjACAAcwBlAHIAdgBpAGMAZQAgAG8AbgAgACUAcwA6AAoAAAAAAAAADQBUAGgAZQAgAFAAcwBFAHgAZQBjACAAcwBlAHIAdgBpAGMAZQAgAHIAdQBuAG4AaQBuAGcAIABvAG4AIAAlAHMAIABpAHMAIABhAG4AIABpAG4AYwBvAG0AcABhAHQAaQBiAGwAZQAgAHYAZQByAHMAaQBvAG4ALgAKAAAAAABMAG8AYwBhAGwAIAB2AGUAcgBzAGkAbwBuADoAIAAgACUAZAAKAAAAUgBlAG0AbwB0AGUAIAB2AGUAcgBzAGkAbwBuADoAIAAlAGQACgAAAA0ARQByAHIAbwByACAAYwBvAG0AbQB1AG4AaQBjAGEAdABpAG4AZwAgAHcAaQB0AGgAIABQAHMARQB4AGUAYwAgAHMAZQByAHYAaQBjAGUAIABvAG4AIAAlAHMAOgAKAAAAAAAAAAAADQBFAHIAcgBvAHIAIABkAGUAcgBpAHYAaQBuAGcAIABzAGUAcwBzAGkAbwBuACAAawBlAHkAOgAKAAAAAAAAAEcAbABvAGIAYQBsAFwAJQBzAC0AJQBzAC0AJQBkAAAADQBTAHQAYQByAHQA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AAAAAAAAAAAgICAgIGFyZ3VtZW50cyAgQXJndW1lbnRzIHRvIHBhc3MgKG5vdGUgdGhhdCBmaWxlIHBhdGhzIG11c3QgYmUKAAAAAAAAAAAgICAgICAgICAgICAgICAgYWJzb2x1dGUgcGF0aHMgb24gdGhlIHRhcmdldCBzeXN0ZW0pLgoAACAgICAgLWFjY2VwdGV1bGEgVGhpcyBmbGFnIHN1cHByZXNzZXMgdGhlIGRpc3BsYXkgb2YgdGhlIGxpY2Vuc2UgZGlhbG9nLgoAAAAAAAAAICAgICAtbm9iYW5uZXIgICBEbyBub3QgZGlzcGxheSB0aGUgc3RhcnR1cCBiYW5uZXIgYW5kIGNvcHlyaWdodCBtZXNzYWdlLgoKAAAAAABZb3UgY2FuIGVuY2xvc2UgYXBwbGljYXRpb25zIHRoYXQgaGF2ZSBzcGFjZXMgaW4gdGhlaXIgbmFtZSB3aXRoCgAAAAAAAABxdW90YXRpb24gbWFya3MgZS5nLiBwc2V4ZWMgXFxtYXJrbGFwICJjOlxsb25nIG5hbWUgYXBwLmV4ZSIuCgAAAAAAAAAAAABJbnB1dCBpcyBvbmx5IHBhc3NlZCB0byB0aGUgcmVtb3RlIHN5c3RlbSB3aGVuIHlvdSBwcmVzcyB0aGUgZW50ZXIKAAAAAABrZXksIGFuZCB0eXBpbmcgQ3RybC1DIHRlcm1pbmF0ZXMgdGhlIHJlbW90ZSBwcm9jZXNzLgoKAElmIHlvdSBvbWl0IGEgdXNlciBuYW1lIHRoZSBwcm9jZXNzIHdpbGwgcnVuIGluIHRoZSBjb250ZXh0IG9mIHlvdXIKAAAAAAAAAAAAAAAAYWNjb3VudCBvbiB0aGUgcmVtb3RlIHN5c3RlbSwgYnV0IHdpbGwgbm90IGhhdmUgYWNjZXNzIHRvIG5ldHdvcmsKAAAAAAAAAAAAAAAAAAByZXNvdXJjZXMgKGJlY2F1c2UgaXQgaXMgaW1wZXJzb25hdGluZykuIFNwZWNpZnkgYSB2YWxpZCB1c2VyIG5hbWUKAAAAAAAAAAAAAAAAAGluIHRoZSBEb21haW5cVXNlciBzeW50YXggaWYgdGhlIHJlbW90ZSBwcm9jZXNzIHJlcXVpcmVzIGFjY2VzcwoAAAAAAAAAAAAAAAAAAAAAdG8gbmV0d29yayBy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MAAyADYADQAKAC0AIABuAG8AdAAgAGUAbgBvAHUAZwBoACAAcwBwAGEAYwBlACAAZgBvAHIAIABzAHQAZABpAG8AIABpAG4AaQB0AGkAYQBsAGkAegBhAHQAaQBvAG4ADQAKAAAAAAAAAAAAUgA2ADAAMgA3AA0ACgAtACAAbgBvAHQAIABlAG4AbwB1AGcAaAAgAHMAcABhAGMAZQAgAGYAbwByACAAbABvAHcAaQBvACAAaQBuAGkAdABpAGEAbABpAHoAYQB0AGkAbwBuAA0ACgAAAAAAAAAAAFIANgAwADIAOAANAAoALQAgAHUAbgBhAGIAbABlACAAdABvACAAaQBuAGkAdABpAGEAbABpAHoAZQAgAGgAZQBhAHAADQAKAAAAAAAAAAAAUgA2ADAAMwAwAA0ACgAtACAAQwBSAFQAIABuAG8AdAAgAGkAbgBpAHQAaQBhAGwAaQB6AGUAZAANAAoAAAAAAFIANgAwADMAMQANAAoALQAgAEEAdAB0AGUAbQBwAHQAIAB0AG8AIABpAG4AaQB0AGkAYQBsAGkAegBlACAAdABoAGUAIABDAFIAVAAgAG0AbwByAGUAIAB0AGgAYQBuACAAbwBuAGMAZQAuAAoAVABoAGkAcwAgAGkAbgBkAGkAYwBhAHQAZQBzACAAYQAgAGIAdQBnACAAaQBuACAAeQBvAHUAcgAgAGEAcABwAGwAaQBjAGEAdABpAG8AbgAuAA0ACgAAAAAAAAAAAAAAAABSADYAMAAzADIADQAKAC0AIABuAG8AdAAgAGUAbgBvAHUAZwBoACAAcwBwAGEAYwBlACAAZgBvAHIAIABsAG8AYwBhAGwAZQAgAGkAbgBmAG8AcgBtAGEAdABpAG8AbgANAAoAAAAAAAAAAAAAAAAAUgA2ADAAMwAzAA0ACgAtACAAQQB0AHQAZQBtAHAAdAAgAHQAbwAgAHUAcwBlACAATQBTAEkATAAgAGMAbwBkAGUAIABmAHIAbwBtACAAdABoAGkAcwAgAGEAcwBzAGUAbQBiAGwAeQAgAGQAdQByAGkAbgBnACAAbgBhAHQAaQB2AGUAIABjAG8AZABlACAAaQBuAGkAdABpAGEAbABpAHoAYQB0AGkAbwBuAAoAVABoAGkAcwAgAGkAbgBkAGkAYwBhAHQAZQBzACAAYQAgAGIAdQBnACAAaQBuACAAeQBvAHUAcgAgAGEAcABwAGwAaQBjAGEAdABpAG8AbgAuACAASQB0ACAAaQBzACAAbQBvAHMAdAAgAGwAaQBrAGUAbAB5ACAAdABoAGUAIAByAGUAcwB1AGwAdAAgAG8AZgAgAGMAYQBsAGwAaQBuAGcAIABhAG4AIABNAFMASQBMAC0AYwBvAG0AcABpAGwAZQBkACAAKAAvAGMAbAByACkAIABmAHUAbgBjAHQAaQBvAG4AIABmAHIAbwBtACAAYQAgAG4AYQB0AGkAdgBlACAAYwBvAG4AcwB0AHIAdQBjAHQAbwByACAAbwByACAAZgByAG8AbQAgAEQAbABsAE0AYQBpAG4ALgANAAoAAAAAAFIANgAwADMANAANAAoALQAgAGkAbgBjAG8AbgBzAGkAcwB0AGUAbgB0ACAAbwBuAGUAeABpAHQAIABiAGUAZwBpAG4ALQBlAG4AZAAgAHYAYQByAGkAYQBiAGwAZQBzAA0ACgAAAAAARABPAE0AQQBJAE4AIABlAHIAcgBvAHIADQAKAAAAAABTAEkATgBHACAAZQByAHIAbwByAA0ACgAAAAAAAAAAAFQATABPAFMAUwAgAGUAcgByAG8AcgANAAoAAAANAAoAAAAAAAAAAAByAHUAbgB0AGkAbQBlACAAZQByAHIAbwByACAAAAAAAFIAdQBuAHQAaQBtAGUAIABFAHIAcgBvAHIAIQAKAAoAUAByAG8AZwByAGEAbQA6ACAAAAAAAAAAPABwAHIAbwBnAHIAYQBtACAAbgBhAG0AZQAgAHUAbgBrAG4AbwB3AG4APgAAAAAALgAuAC4AAAAKAAoAAAAAAAAAAAAAAAAATQBpAGMAcgBvAHMAbwBmAHQAIABWAGkAcwB1AGEAbAAgAEMAKwArACAAUgB1AG4AdABpAG0AZQAgAEwAaQBiAHIAYQByAHkAAAAAAChudWxsKQAAAAAAACgAbgB1AGwAbAApAAAAAAAAAAAAAAAAAAYAAAYAAQAAEAADBgAGAhAERUVFBQUFBQU1MABQAAAAACggOFBYBwgANzAwV1AHAAAgIAgAAAAACGBoYGBgYAAAeHB4eHh4CAcIAAAHAAgICAAACAAIAAcIAAAAAAAAAEMATwBOAEkATgAkAAAAAABjAGMAcwAAAFUAVABGAC0AOAAAAAAAAABVAFQARgAtADEANgBMAEUAAAAAAAAAAABVAE4ASQBDAE8ARABFAAAABQAAwAsAAAAAAAAAAAAAAB0AAMAEAAAAAAAAAAAAAACWAADABAAAAAAAAAAAAAAAjQAAwAgAAAAAAAAAAAAAAI4AAMAIAAAAAAAAAAAAAACPAADACAAAAAAAAAAAAAAAkAAAwAgAAAAAAAAAAAAAAJEAAMAIAAAAAAAAAAAAAACSAADACAAAAAAAAAAAAAAAkwAAwAgAAAAAAAAAAAAAALQCAMAIAAAAAAAAAAAAAAC1AgDACAAAAAAAAAAAAAAADAAAAMAAAAADAAAACQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgACAAIAAgACAAIAAgACAAIAAoACgAKAAoACgAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAASAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEACEAIQAhACEAIQAhACEAIQAhACEABAAEAAQABAAEAAQABAAgQCBAIEAgQCBAIEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABABAAEAAQABAAEAAQAIIAggCCAIIAggCCAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgAQABAAEAAQACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAAgACAAIAAgACAAIAAgACAAKAAoACgAKAAoACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgAEgAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAhACEAIQAhACEAIQAhACEAIQAhAAQABAAEAAQABAAEAAQAIEBgQGBAYEBgQGBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEQABAAEAAQABAAEACCAYIBggGCAYIBggECAQIBAgECAQIBAgECAQIBAgECAQIBAgECAQIBAgECAQIBAgECAQIBEAAQABAAEAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAIABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBARAAAQEBAQEBAQEBAQEBAQECAQIBAgECAQIBAgECAQIBAgECAQIBAgECAQIBAgECAQIBAgECAQIBAgECAQIBAgEQAAIBAgECAQIBAgECAQIBAgEBAQAAAAAAAAAAAAAAAICBgoOEhYaHiImKi4yNjo+QkZKTlJWWl5iZmpucnZ6foKGio6SlpqeoqaqrrK2ur7CxsrO0tba3uLm6u7y9vr/AwcLDxMXGx8jJysvMzc7P0NHS09TV1tfY2drb3N3e3+Dh4uPk5ebn6Onq6+zt7u/w8fLz9PX29/j5+vv8/f7/AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8gISIjJCUmJygpKissLS4vMDEyMzQ1Njc4OTo7PD0+P0BhYmNkZWZnaGlqa2xtbm9wcXJzdHV2d3h5eltcXV5fYGFiY2RlZmdoaWprbG1ub3BxcnN0dXZ3eHl6e3x9fn+AgYKDhIWGh4iJiouMjY6PkJGSk5SVlpeYmZqbnJ2en6ChoqOkpaanqKmqq6ytrq+wsbKztLW2t7i5uru8vb6/wMHCw8TFxsfIycrLzM3Oz9DR0tPU1dbX2Nna29zd3t/g4eLj5OXm5+jp6uvs7e7v8PHy8/T19vf4+fr7/P3+/4CBgoOEhYaHiImKi4yNjo+QkZKTlJWWl5iZmpucnZ6foKGio6SlpqeoqaqrrK2ur7CxsrO0tba3uLm6u7y9vr/AwcLDxMXGx8jJysvMzc7P0NHS09TV1tfY2drb3N3e3+Dh4uPk5ebn6Onq6+zt7u/w8fLz9PX29/j5+vv8/f7/AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8gISIjJCUmJygpKissLS4vMDEyMzQ1Njc4OTo7PD0+P0BBQkNERUZHSElKS0xNTk9QUVJTVFVWV1hZWltcXV5fYEFCQ0RFRkdISUpLTE1OT1BRUlNUVVZXWFlae3x9fn+AgYKDhIWGh4iJiouMjY6PkJGSk5SVlpeYmZqbnJ2en6ChoqOkpaanqKmqq6ytrq+wsbKztLW2t7i5uru8vb6/wMHCw8TFxsfIycrLzM3Oz9DR0tPU1dbX2Nna29zd3t/g4eLj5OXm5+jp6uvs7e7v8PHy8/T19vf4+fr7/P3+/3UAawAAAAAAQQAAABcAAAABAAAAAAAAALCCAkABAAAAAgAAAAAAAAC4ggJAAQAAAAMAAAAAAAAAwIICQAEAAAAEAAAAAAAAAMiCAkABAAAABQAAAAAAAADYggJAAQAAAAYAAAAAAAAA4IICQAEAAAAHAAAAAAAAAOiCAkABAAAACAAAAAAAAADwggJAAQAAAAkAAAAAAAAA+IICQAEAAAAKAAAAAAAAAACDAkABAAAACwAAAAAAAAAIgwJAAQAAAAwAAAAAAAAAEIMCQAEAAAANAAAAAAAAABiDAkABAAAADgAAAAAAAAAggwJAAQAAAA8AAAAAAAAAKIMCQAEAAAAQAAAAAAAAADCDAkABAAAAEQAAAAAAAAA4gwJAAQAAABIAAAAAAAAAQIMCQAEAAAATAAAAAAAAAEiDAkABAAAAFAAAAAAAAABQgwJAAQAAABUAAAAAAAAAWIMCQAEAAAAWAAAAAAAAAGCDAkABAAAAGAAAAAAAAABogwJAAQAAABkAAAAAAAAAcIMCQAEAAAAaAAAAAAAAAHiDAkABAAAAGwAAAAAAAACAgwJAAQAAABwAAAAAAAAAiIMCQAEAAAAdAAAAAAAAAJCDAkABAAAAHgAAAAAAAACYgwJAAQAAAB8AAAAAAAAAoIMCQAEAAAAgAAAAAAAAAKiDAkABAAAAIQAAAAAAAACwgwJAAQAAACIAAAAAAAAAIGYCQAEAAAAjAAAAAAAAALiDAkABAAAAJAAAAAAAAADAgwJAAQAAACUAAAAAAAAAyIMCQAEAAAAmAAAAAAAAANCDAkABAAAAJwAAAAAAAADYgwJAAQAAACkAAAAAAAAA4IMCQAEAAAAqAAAAAAAAAOiDAkABAAAAKwAAAAAAAADwgwJAAQAAACwAAAAAAAAA+IMCQAEAAAAtAAAAAAAAAACEAkABAAAALwAAAAAAAAAIhAJAAQAAADYAAAAAAAAAEIQCQAEAAAA3AAAAAAAAABiEAkABAAAAOAAAAAAAAAAghAJAAQAAADkAAAAAAAAAKIQCQAEAAAA+AAAAAAAAADCEAkABAAAAPwAAAAAAAAA4hAJAAQAAAEAAAAAAAAAAQIQCQAEAAABBAAAAAAAAAEiEAkABAAAAQwAAAAAAAABQhAJAAQAAAEQAAAAAAAAAWIQCQAEAAABGAAAAAAAAAGCEAkABAAAARwAAAAAAAABohAJAAQAAAEkAAAAAAAAAcIQCQAEAAABKAAAAAAAAAHiEAkABAAAASwAAAAAAAACAhAJAAQAAAE4AAAAAAAAAiIQCQAEAAABPAAAAAAAAAJCEAkABAAAAUAAAAAAAAACYhAJAAQAAAFYAAAAAAAAAoIQCQAEAAABXAAAAAAAAAKiEAkABAAAAWgAAAAAAAACwhAJAAQAAAGUAAAAAAAAAuIQCQAEAAAB/AAAAAAAAAMCEAkABAAAAAQQAAAAAAADIhAJAAQAAAAIEAAAAAAAA2IQCQAEAAAADBAAAAAAAAOiEAkABAAAABAQAAAAAAACASQJAAQAAAAUEAAAAAAAA+IQCQAEAAAAGBAAAAAAAAAiFAkABAAAABwQAAAAAAAAYhQJAAQAAAAgEAAAAAAAAKIUCQAEAAAAJBAAAAAAAADhNAkABAAAACwQAAAAAAAA4hQJAAQAAAAwEAAAAAAAASIUCQAEAAAANBAAAAAAAAFiFAkABAAAADgQAAAAAAABohQJAAQAAAA8EAAAAAAAAeIUCQAEAAAAQBAAAAAAAAIiFAkABAAAAEQQAAAAAAABQSQJAAQAAABIEAAAAAAAAcEkCQAEAAAATBAAAAAAAAJiFAkABAAAAFAQAAAAAAACohQJAAQAAABUEAAAAAAAAuIUCQAEAAAAWBAAAAAAAAMiFAkABAAAAGAQAAAAAAADYhQJAAQAAABkEAAAAAAAA6IUCQAEAAAAaBAAAAAAAAPiFAkABAAAAGwQAAAAAAAAIhgJAAQAAABwEAAAAAAAAGIYCQAEAAAAdBAAAAAAAACiGAkABAAAAHgQAAAAAAAA4hgJAAQAAAB8EAAAAAAAASIYCQAEAAAAgBAAAAAAAAFiGAkABAAAAIQQAAAAAAABohgJAAQAAACIEAAAAAAAAeIYCQAEAAAAjBAAAAAAAAIiGAkABAAAAJAQAAAAAAACYhgJAAQAAACUEAAAAAAAAqIYCQAEAAAAmBAAAAAAAALiGAkABAAAAJwQAAAAAAADIhgJAAQAAACkEAAAAAAAA2IYCQAEAAAAqBAAAAAAAAOiGAkABAAAAKwQAAAAAAAD4hgJAAQAAACwEAAAAAAAACIcCQAEAAAAtBAAAAAAAACCHAkABAAAALwQAAAAAAAAwhwJAAQAAADIEAAAAAAAAQIcCQAEAAAA0BAAAAAAAAFCHAkABAAAANQQAAAAAAABghwJAAQAAADYEAAAAAAAAcIcCQAEAAAA3BAAAAAAAAICHAkABAAAAOAQAAAAAAACQhwJAAQAAADkEAAAAAAAAoIcCQAEAAAA6BAAAAAAAALCHAkABAAAAOwQAAAAAAADAhwJAAQAAAD4EAAAAAAAA0IcCQAEAAAA/BAAAAAAAAOCHAkABAAAAQAQAAAAAAADwhwJAAQAAAEEEAAAAAAAAAIgCQAEAAABDBAAAAAAAABCIAkABAAAARAQAAAAAAAAoiAJAAQAAAEUEAAAAAAAAOIgCQAEAAABGBAAAAAAAAEiIAkABAAAARwQAAAAAAABYiAJAAQAAAEkEAAAAAAAAaIgCQAEAAABKBAAAAAAAAHiIAkABAAAASwQAAAAAAACIiAJAAQAAAEwEAAAAAAAAmIgCQAEAAABOBAAAAAAAAKiIAkABAAAATwQAAAAAAAC4iAJAAQAAAFAEAAAAAAAAyIgCQAEAAABSBAAAAAAAANiIAkABAAAAVgQAAAAAAADoiAJAAQAAAFcEAAAAAAAA+IgCQAEAAABaBAAAAAAAAAiJAkABAAAAZQQAAAAAAAAYiQJAAQAAAGsEAAAAAAAAKIkCQAEAAABsBAAAAAAAADiJAkABAAAAgQQAAAAAAABIiQJAAQAAAAEIAAAAAAAAWIkCQAEAAAAECAAAAAAAAGBJAkABAAAABwgAAAAAAABoiQJAAQAAAAkIAAAAAAAAeIkCQAEAAAAKCAAAAAAAAIiJAkABAAAADAgAAAAAAACYiQJAAQAAABAIAAAAAAAAqIkCQAEAAAATCAAAAAAAALiJAkABAAAAFAgAAAAAAADIiQJAAQAAABYIAAAAAAAA2IkCQAEAAAAaCAAAAAAAAOiJAkABAAAAHQgAAAAAAAAAigJAAQAAACwIAAAAAAAAEIoCQAEAAAA7CAAAAAAAACiKAkABAAAAPggAAAAAAAA4igJAAQAAAEMIAAAAAAAASIoCQAEAAABrCAAAAAAAAGCKAkABAAAAAQwAAAAAAABwigJAAQAAAAQMAAAAAAAAgIoCQAEAAAAHDAAAAAAAAJCKAkABAAAACQwAAAAAAACgigJAAQAAAAoMAAAAAAAAsIoCQAEAAAAMDAAAAAAAAMCKAkABAAAAGgwAAAAAAADQigJAAQAAADsMAAAAAAAA6IoCQAEAAABrDAAAAAAAAPiKAkABAAAAARAAAAAAAAAIiwJAAQAAAAQQAAAAAAAAGIsCQAEAAAAHEAAAAAAAACiLAkABAAAACRAAAAAAAAA4iwJAAQAAAAoQAAAAAAAASIsCQAEAAAAMEAAAAAAAAFiLAkABAAAAGhAAAAAAAABoiwJAAQAAADsQAAAAAAAAeIsCQAEAAAABFAAAAAAAAIiLAkABAAAABBQAAAAAAACYiwJAAQAAAAcUAAAAAAAAqIsCQAEAAAAJFAAAAAAAALiLAkABAAAAChQAAAAAAADIiwJAAQAAAAwUAAAAAAAA2IsCQAEAAAAaFAAAAAAAAOiLAkABAAAAOxQAAAAAAAAAjAJAAQAAAAEYAAAAAAAAEIwCQAEAAAAJGAAAAAAAACCMAkABAAAAChgAAAAAAAAwjAJAAQAAAAwYAAAAAAAAQIwCQAEAAAAaGAAAAAAAAFCMAkABAAAAOxgAAAAAAABojAJAAQAAAAEcAAAAAAAAeIwCQAEAAAAJHAAAAAAAAIiMAkABAAAAChwAAAAAAACYjAJAAQAAABocAAAAAAAAqIwCQAEAAAA7HAAAAAAAAMCMAkABAAAAASAAAAAAAADQjAJAAQAAAAkgAAAAAAAA4IwCQAEAAAAKIAAAAAAAAPCMAkABAAAAOyAAAAAAAAAAjQJAAQAAAAEkAAAAAAAAEI0CQAEAAAAJJAAAAAAAACCNAkABAAAACiQAAAAAAAAwjQJAAQAAADskAAAAAAAAQI0CQAEAAAABKAAAAAAAAFCNAkABAAAACSgAAAAAAABgjQJAAQAAAAooAAAAAAAAcI0CQAEAAAABLAAAAAAAAICNAkABAAAACSwAAAAAAACQjQJAAQAAAAosAAAAAAAAoI0CQAEAAAABMAAAAAAAALCNAkABAAAACTAAAAAAAADAjQJAAQAAAAowAAAAAAAA0I0CQAEAAAABNAAAAAAAAOCNAkABAAAACTQAAAAAAADwjQJAAQAAAAo0AAAAAAAAAI4CQAEAAAABOAAAAAAAABCOAkABAAAACjgAAAAAAAAgjgJAAQAAAAE8AAAAAAAAMI4CQAEAAAAKPAAAAAAAAECOAkABAAAAAUAAAAAAAABQjgJAAQAAAApAAAAAAAAAYI4CQAEAAAAKRAAAAAAAAHCOAkABAAAACkgAAAAAAACAjgJAAQAAAApMAAAAAAAAkI4CQAEAAAAKUAAAAAAAAKCOAkABAAAABHwAAAAAAACwjgJAAQAAABp8AAAAAAAAwI4CQAEAAADAhAJAAQAAAEIAAAAAAAAAEIQCQAEAAAAsAAAAAAAAAMiOAkABAAAAcQAAAAAAAACwggJAAQAAAAAAAAAAAAAA2I4CQAEAAADYAAAAAAAAAOiOAkABAAAA2gAAAAAAAAD4jgJAAQAAALEAAAAAAAAACI8CQAEAAACgAAAAAAAAABiPAkABAAAAjwAAAAAAAAAojwJAAQAAAM8AAAAAAAAAOI8CQAEAAADVAAAAAAAAAEiPAkABAAAA0gAAAAAAAABYjwJAAQAAAKkAAAAAAAAAaI8CQAEAAAC5AAAAAAAAAHiPAkABAAAAxAAAAAAAAACIjwJAAQAAANwAAAAAAAAAmI8CQAEAAABDAAAAAAAAAKiPAkABAAAAzAAAAAAAAAC4jwJAAQAAAL8AAAAAAAAAyI8CQAEAAADIAAAAAAAAAPiDAkABAAAAKQAAAAAAAADYjwJAAQAAAJsAAAAAAAAA8I8CQAEAAABrAAAAAAAAALiDAkABAAAAIQAAAAAAAAAIkAJAAQAAAGMAAAAAAAAAuIICQAEAAAABAAAAAAAAABiQAkABAAAARAAAAAAAAAAokAJAAQAAAH0AAAAAAAAAOJACQAEAAAC3AAAAAAAAAMCCAkABAAAAAgAAAAAAAABQkAJAAQAAAEUAAAAAAAAA2IICQAEAAAAEAAAAAAAAAGCQAkABAAAARwAAAAAAAABwkAJAAQAAAIcAAAAAAAAA4IICQAEAAAAFAAAAAAAAAICQAkABAAAASAAAAAAAAADoggJAAQAAAAYAAAAAAAAAkJACQAEAAACiAAAAAAAAAKCQAkABAAAAkQAAAAAAAACwkAJAAQAAAEkAAAAAAAAAwJACQAEAAACzAAAAAAAAANCQAkABAAAAqwAAAAAAAAC4hAJAAQAAAEEAAAAAAAAA4JACQAEAAACLAAAAAAAAAPCCAkABAAAABwAAAAAAAADwkAJAAQAAAEoAAAAAAAAA+IICQAEAAAAIAAAAAAAAAACRAkABAAAAowAAAAAAAAAQkQJAAQAAAM0AAAAAAAAAIJECQAEAAACsAAAAAAAAADCRAkABAAAAyQAAAAAAAABAkQJAAQAAAJIAAAAAAAAAUJECQAEAAAC6AAAAAAAAAGCRAkABAAAAxQAAAAAAAABwkQJAAQAAALQAAAAAAAAAgJECQAEAAADWAAAAAAAAAJCRAkABAAAA0AAAAAAAAACgkQJAAQAAAEsAAAAAAAAAsJECQAEAAADAAAAAAAAAAMCRAkABAAAA0wAAAAAAAAAAgwJAAQAAAAkAAAAAAAAA0JECQAEAAADRAAAAAAAAAOCRAkABAAAA3QAAAAAAAADwkQJAAQAAANcAAAAAAAAAAJICQAEAAADKAAAAAAAAABCSAkABAAAAtQAAAAAAAAAgkgJAAQAAAMEAAAAAAAAAMJICQAEAAADUAAAAAAAAAECSAkABAAAApAAAAAAAAABQkgJAAQAAAK0AAAAAAAAAYJICQAEAAADfAAAAAAAAAHCSAkABAAAAkwAAAAAAAACAkgJAAQAAAOAAAAAAAAAAkJICQAEAAAC7AAAAAAAAAKCSAkABAAAAzgAAAAAAAACwkgJAAQAAAOEAAAAAAAAAwJICQAEAAADbAAAAAAAAANCSAkABAAAA3gAAAAAAAADgkgJAAQAAANkAAAAAAAAA8JICQAEAAADGAAAAAAAAAMiDAkABAAAAIwAAAAAAAAAAkwJAAQAAAGUAAAAAAAAAAIQCQAEAAAAqAAAAAAAAABCTAkABAAAAbAAAAAAAAADggwJAAQAAACYAAAAAAAAAIJMCQAEAAABoAAAAAAAAAAiDAkABAAAACgAAAAAAAAAwkwJAAQAAAEwAAAAAAAAAIIQCQAEAAAAuAAAAAAAAAECTAkABAAAAcwAAAAAAAAAQgwJAAQAAAAsAAAAAAAAAUJMCQAEAAACUAAAAAAAAAGCTAkABAAAApQAAAAAAAABwkwJAAQAAAK4AAAAAAAAAgJMCQAEAAABNAAAAAAAAAJCTAkABAAAAtgAAAAAAAACgkwJAAQAAALwAAAAAAAAAoIQCQAEAAAA+AAAAAAAAALCTAkABAAAAiAAAAAAAAABohAJAAQAAADcAAAAAAAAAwJMCQAEAAAB/AAAAAAAAABiDAkABAAAADAAAAAAAAADQkwJAAQAAAE4AAAAAAAAAKIQCQAEAAAAvAAAAAAAAAOCTAkABAAAAdAAAAAAAAAB4gwJAAQAAABgAAAAAAAAA8JMCQAEAAACvAAAAAAAAAACUAkABAAAAWgAAAAAAAAAggwJAAQAAAA0AAAAAAAAAEJQCQAEAAABPAAAAAAAAAPCDAkABAAAAKAAAAAAAAAAglAJAAQAAAGoAAAAAAAAAsIMCQAEAAAAfAAAAAAAAADCUAkABAAAAYQAAAAAAAAAogwJAAQAAAA4AAAAAAAAAQJQCQAEAAABQAAAAAAAAADCDAkABAAAADwAAAAAAAABQlAJAAQAAAJUAAAAAAAAAYJQCQAEAAABRAAAAAAAAADiDAkABAAAAEAAAAAAAAABwlAJAAQAAAFIAAAAAAAAAGIQCQAEAAAAtAAAAAAAAAICUAkABAAAAcgAAAAAAAAA4hAJAAQAAADEAAAAAAAAAkJQCQAEAAAB4AAAAAAAAAICEAkABAAAAOgAAAAAAAACglAJAAQAAAIIAAAAAAAAAQIMCQAEAAAARAAAAAAAAAKiEAkABAAAAPwAAAAAAAACwlAJAAQAAAIkAAAAAAAAAwJQCQAEAAABTAAAAAAAAAECEAkABAAAAMgAAAAAAAADQlAJAAQAAAHkAAAAAAAAA2IMCQAEAAAAlAAAAAAAAAOCUAkABAAAAZwAAAAAAAADQgwJAAQAAACQAAAAAAAAA8JQCQAEAAABmAAAAAAAAAACVAkABAAAAjgAAAAAAAAAIhAJAAQAAACsAAAAAAAAAEJUCQAEAAABtAAAAAAAAACCVAkABAAAAgwAAAAAAAACYhAJAAQAAAD0AAAAAAAAAMJUCQAEAAACGAAAAAAAAAIiEAkABAAAAOwAAAAAAAABAlQJAAQAAAIQAAAAAAAAAMIQCQAEAAAAwAAAAAAAAAFCVAkABAAAAnQAAAAAAAABglQJAAQAAAHcAAAAAAAAAcJUCQAEAAAB1AAAAAAAAAICVAkABAAAAVQAAAAAAAABIgwJAAQAAABIAAAAAAAAAkJUCQAEAAACWAAAAAAAAAKCVAkABAAAAVAAAAAAAAACwlQJAAQAAAJcAAAAAAAAAUIMCQAEAAAATAAAAAAAAAMCVAkABAAAAjQAAAAAAAABghAJAAQAAADYAAAAAAAAA0JUCQAEAAAB+AAAAAAAAAFiDAkABAAAAFAAAAAAAAADglQJAAQAAAFYAAAAAAAAAYIMCQAEAAAAVAAAAAAAAAPCVAkABAAAAVwAAAAAAAAAAlgJAAQAAAJgAAAAAAAAAEJYCQAEAAACMAAAAAAAAACCWAkABAAAAnwAAAAAAAAAwlgJAAQAAAKgAAAAAAAAAaIMCQAEAAAAWAAAAAAAAAECWAkABAAAAWAAAAAAAAABwgwJAAQAAABcAAAAAAAAAUJYCQAEAAABZAAAAAAAAAJCEAkABAAAAPAAAAAAAAABglgJAAQAAAIUAAAAAAAAAcJYCQAEAAACnAAAAAAAAAICWAkABAAAAdgAAAAAAAACQlgJAAQAAAJwAAAAAAAAAgIMCQAEAAAAZAAAAAAAAAKCWAkABAAAAWwAAAAAAAADAgwJAAQAAACIAAAAAAAAAsJYCQAEAAABkAAAAAAAAAMCWAkABAAAAvgAAAAAAAADQlgJAAQAAAMMAAAAAAAAA4JYCQAEAAACwAAAAAAAAAPCWAkABAAAAuAAAAAAAAAAAlwJAAQAAAMsAAAAAAAAAEJcCQAEAAADHAAAAAAAAAIiDAkABAAAAGgAAAAAAAAAglwJAAQAAAFwAAAAAAAAAwI4CQAEAAADjAAAAAAAAADCXAkABAAAAwgAAAAAAAABIlwJAAQAAAL0AAAAAAAAAYJcCQAEAAACmAAAAAAAAAHiXAkABAAAAmQAAAAAAAACQgwJAAQAAABsAAAAAAAAAkJcCQAEAAACaAAAAAAAAAKCXAkABAAAAXQAAAAAAAABIhAJAAQAAADMAAAAAAAAAsJcCQAEAAAB6AAAAAAAAALCEAkABAAAAQAAAAAAAAADAlwJAAQAAAIoAAAAAAAAAcIQCQAEAAAA4AAAAAAAAANCXAkABAAAAgAAAAAAAAAB4hAJAAQAAADkAAAAAAAAA4JcCQAEAAACBAAAAAAAAAJiDAkABAAAAHAAAAAAAAADwlwJAAQAAAF4AAAAAAAAAAJgCQAEAAABuAAAAAAAAAKCDAkABAAAAHQAAAAAAAAAQmAJAAQAAAF8AAAAAAAAAWIQCQAEAAAA1AAAAAAAAACCYAkABAAAAfAAAAAAAAAAgZgJAAQAAACAAAAAAAAAAMJgCQAEAAABiAAAAAAAAAKiDAkABAAAAHgAAAAAAAABAmAJAAQAAAGAAAAAAAAAAUIQCQAEAAAA0AAAAAAAAAFCYAkABAAAAngAAAAAAAABomAJAAQAAAHsAAAAAAAAA6IMCQAEAAAAnAAAAAAAAAICYAkABAAAAaQAAAAAAAACQmAJAAQAAAG8AAAAAAAAAoJgCQAEAAAADAAAAAAAAALCYAkABAAAA4gAAAAAAAADAmAJAAQAAAJAAAAAAAAAA0JgCQAEAAAChAAAAAAAAAOCYAkABAAAAsgAAAAAAAADwmAJAAQAAAKoAAAAAAAAAAJkCQAEAAABGAAAAAAAAABCZAkABAAAAcAAAAAAAAABhAHIAAAAAAGIAZwAAAAAAYwBhAAAAAAB6AGgALQBDAEgAUwAAAAAAYwBzAAAAAABkAGEAAAAAAGQAZQAAAAAAZQBsAAAAAABlAG4AAAAAAGUAcwAAAAAAZgBpAAAAAABmAHIAAAAAAGgAZQAAAAAAaAB1AAAAAABpAHMAAAAAAGkAdAAAAAAAagBhAAAAAABrAG8AAAAAAG4AbAAAAAAAbgBvAAAAAABwAGwAAAAAAHAAdAAAAAAAcgBvAAAAAAByAHUAAAAAAGgAcgAAAAAAcwBrAAAAAABzAHEAAAAAAHMAdgAAAAAAdABoAAAAAAB0AHIAAAAAAHUAcgAAAAAAaQBkAAAAAABiAGUAAAAAAHMAbAAAAAAAZQB0AAAAAABsAHYAAAAAAGwAdAAAAAAAZgBhAAAAAAB2AGkAAAAAAGgAeQAAAAAAYQB6AAAAAABlAHUAAAAAAG0AawAAAAAAYQBmAAAAAABrAGEAAAAAAGYAbwAAAAAAaABpAAAAAABtAHMAAAAAAGsAawAAAAAAawB5AAAAAABzAHcAAAAAAHUAegAAAAAAdAB0AAAAAABwAGEAAAAAAGcAdQAAAAAAdABhAAAAAAB0AGUAAAAAAGsAbgAAAAAAbQByAAAAAABzAGEAAAAAAG0AbgAAAAAAZwBsAAAAAABrAG8AawAAAHMAeQByAAAAZABpAHYAAAAAAAAAAAAAAGEAcgAtAFMAQQAAAAAAAABiAGcALQBCAEcAAAAAAAAAYwBhAC0ARQBTAAAAAAAAAGMAcwAtAEMAWgAAAAAAAABkAGEALQBEAEsAAAAAAAAAZABlAC0ARABFAAAAAAAAAGUAbAAtAEcAUgAAAAAAAABmAGkALQBGAEkAAAAAAAAAZgByAC0ARgBSAAAAAAAAAGgAZQAtAEkATAAAAAAAAABoAHUALQBIAFUAAAAAAAAAaQBzAC0ASQBTAAAAAAAAAGkAdAAtAEkAVAAAAAAAAABuAGwALQBOAEwAAAAAAAAAbgBiAC0ATgBPAAAAAAAAAHAAbAAtAFAATAAAAAAAAABwAHQALQBCAFIAAAAAAAAAcgBvAC0AUgBPAAAAAAAAAHIAdQAtAFIAVQAAAAAAAABoAHIALQBIAFIAAAAAAAAAcwBrAC0AUwBLAAAAAAAAAHMAcQAtAEEATAAAAAAAAABzAHYALQBTAEUAAAAAAAAAdABoAC0AVABIAAAAAAAAAHQAcgAtAFQAUgAAAAAAAAB1AHIALQBQAEsAAAAAAAAAaQBkAC0ASQBEAAAAAAAAAHUAawAtAFUAQQAAAAAAAABiAGUALQBCAFkAAAAAAAAAcwBsAC0AUwBJAAAAAAAAAGUAdAAtAEUARQAAAAAAAABsAHYALQBMAFYAAAAAAAAAbAB0AC0ATABUAAAAAAAAAGYAYQAtAEkAUgAAAAAAAAB2AGkALQBWAE4AAAAAAAAAaAB5AC0AQQBNAAAAAAAAAGEAegAtAEEAWgAtAEwAYQB0AG4AAAAAAGUAdQAtAEUAUwAAAAAAAABtAGsALQBNAEsAAAAAAAAAdABuAC0AWgBBAAAAAAAAAHgAaAAtAFoAQQAAAAAAAAB6AHUALQBaAEEAAAAAAAAAYQBmAC0AWgBBAAAAAAAAAGsAYQAtAEcARQAAAAAAAABmAG8ALQBGAE8AAAAAAAAAaABpAC0ASQBOAAAAAAAAAG0AdAAtAE0AVAAAAAAAAABzAGUALQBOAE8AAAAAAAAAbQBzAC0ATQBZAAAAAAAAAGsAawAtAEsAWgAAAAAAAABrAHkALQBLAEcAAAAAAAAAcwB3AC0ASwBFAAAAAAAAAHUAegAtAFUAWgAtAEwAYQB0AG4AAAAAAHQAdAAtAFIAVQAAAAAAAABiAG4ALQBJAE4AAAAAAAAAcABhAC0ASQBOAAAAAAAAAGcAdQAtAEkATgAAAAAAAAB0AGEALQBJAE4AAAAAAAAAdABlAC0ASQBOAAAAAAAAAGsAbgAtAEkATgAAAAAAAABtAGwALQBJAE4AAAAAAAAAbQByAC0ASQBOAAAAAAAAAHMAYQAtAEkATgAAAAAAAABtAG4ALQBNAE4AAAAAAAAAYwB5AC0ARwBCAAAAAAAAAGcAbAAtAEUAUwAAAAAAAABrAG8AawAtAEkATgAAAAAAcwB5AHIALQBTAFkAAAAAAGQAaQB2AC0ATQBWAAAAAABxAHUAegAtAEIATwAAAAAAbgBzAC0AWgBBAAAAAAAAAG0AaQAtAE4AWgAAAAAAAABhAHIALQBJAFEAAAAAAAAAZABlAC0AQwBIAAAAAAAAAGUAbgAtAEcAQgAAAAAAAABlAHMALQBNAFgAAAAAAAAAZgByAC0AQgBFAAAAAAAAAGkAdAAtAEMASAAAAAAAAABuAGwALQBCAEUAAAAAAAAAbgBuAC0ATgBPAAAAAAAAAHAAdAAtAFAAVAAAAAAAAABzAHIALQBTAFAALQBMAGEAdABuAAAAAABzAHYALQBGAEkAAAAAAAAAYQB6AC0AQQBaAC0AQwB5AHIAbAAAAAAAcwBlAC0AUwBFAAAAAAAAAG0AcwAtAEIATgAAAAAAAAB1AHoALQBVAFoALQBDAHkAcgBsAAAAAABxAHUAegAtAEUAQwAAAAAAYQByAC0ARQBHAAAAAAAAAHoAaAAtAEgASwAAAAAAAABkAGUALQBBAFQAAAAAAAAAZQBuAC0AQQBVAAAAAAAAAGUAcwAtAEUAUwAAAAAAAABmAHIALQBDAEEAAAAAAAAAcwByAC0AUwBQAC0AQwB5AHIAbAAAAAAAcwBlAC0ARgBJAAAAAAAAAHEAdQB6AC0AUABFAAAAAABhAHIALQBMAFkAAAAAAAAAegBoAC0AUwBHAAAAAAAAAGQAZQAtAEwAVQAAAAAAAABlAG4ALQBDAEEAAAAAAAAAZQBzAC0ARwBUAAAAAAAAAGYAcgAtAEMASAAAAAAAAABoAHIALQBCAEEAAAAAAAAAcwBtAGoALQBOAE8AAAAAAGEAcgAtAEQAWgAAAAAAAAB6AGgALQBNAE8AAAAAAAAAZABlAC0ATABJAAAAAAAAAGUAbgAtAE4AWgAAAAAAAABlAHMALQBDAFIAAAAAAAAAZgByAC0ATABVAAAAAAAAAGIAcwAtAEIAQQAtAEwAYQB0AG4AAAAAAHMAbQBqAC0AUwBFAAAAAABhAHIALQBNAEEAAAAAAAAAZQBuAC0ASQBFAAAAAAAAAGUAcwAtAFAAQQAAAAAAAABmAHIALQBNAEMAAAAAAAAAcwByAC0AQgBBAC0ATABhAHQAbgAAAAAAcwBtAGEALQBOAE8AAAAAAGEAcgAtAFQATgAAAAAAAABlAG4ALQBaAEEAAAAAAAAAZQBzAC0ARABPAAAAAAAAAHMAcgAtAEIAQQAtAEMAeQByAGwAAAAAAHMAbQBhAC0AUwBFAAAAAABhAHIALQBPAE0AAAAAAAAAZQBuAC0ASgBNAAAAAAAAAGUAcwAtAFYARQAAAAAAAABzAG0AcwAtAEYASQAAAAAAYQByAC0AWQBFAAAAAAAAAGUAbgAtAEMAQgAAAAAAAABlAHMALQBDAE8AAAAAAAAAcwBtAG4ALQBGAEkAAAAAAGEAcgAtAFMAWQAAAAAAAABlAG4ALQBCAFoAAAAAAAAAZQBzAC0AUABFAAAAAAAAAGEAcgAtAEoATwAAAAAAAABlAG4ALQBUAFQAAAAAAAAAZQBzAC0AQQBSAAAAAAAAAGEAcgAtAEwAQgAAAAAAAABlAG4ALQBaAFcAAAAAAAAAZQBzAC0ARQBDAAAAAAAAAGEAcgAtAEsAVwAAAAAAAABlAG4ALQBQAEgAAAAAAAAAZQBzAC0AQwBMAAAAAAAAAGEAcgAtAEEARQAAAAAAAABlAHMALQBVAFkAAAAAAAAAYQByAC0AQgBIAAAAAAAAAGUAcwAtAFAAWQAAAAAAAABhAHIALQBRAEEAAAAAAAAAZQBzAC0AQgBPAAAAAAAAAGUAcwAtAFMAVgAAAAAAAABlAHMALQBIAE4AAAAAAAAAZQBzAC0ATgBJAAAAAAAAAGUAcwAtAFAAUgAAAAAAAAB6AGgALQBDAEgAVAAAAAAAcwByAAAAAABhAGYALQB6AGEAAAAAAAAAYQByAC0AYQBlAAAAAAAAAGEAcgAtAGIAaAAAAAAAAABhAHIALQBkAHoAAAAAAAAAYQByAC0AZQBnAAAAAAAAAGEAcgAtAGkAcQAAAAAAAABhAHIALQBqAG8AAAAAAAAAYQByAC0AawB3AAAAAAAAAGEAcgAtAGwAYgAAAAAAAABhAHIALQBsAHkAAAAAAAAAYQByAC0AbQBhAAAAAAAAAGEAcgAtAG8AbQAAAAAAAABhAHIALQBxAGEAAAAAAAAAYQByAC0AcwBhAAAAAAAAAGEAcgAtAHMAeQAAAAAAAABhAHIALQB0AG4AAAAAAAAAYQByAC0AeQBlAAAAAAAAAGEAegAtAGEAegAtAGMAeQByAGwAAAAAAGEAegAtAGEAegAtAGwAYQB0AG4AAAAAAGIAZQAtAGIAeQAAAAAAAABiAGcALQBiAGcAAAAAAAAAYgBuAC0AaQBuAAAAAAAAAGIAcwAtAGIAYQAtAGwAYQB0AG4AAAAAAGMAYQAtAGUAcwAAAAAAAABjAHMALQBjAHoAAAAAAAAAYwB5AC0AZwBiAAAAAAAAAGQAYQAtAGQAawAAAAAAAABkAGUALQBhAHQAAAAAAAAAZABlAC0AYwBoAAAAAAAAAGQAZQAtAGQAZQAAAAAAAABkAGUALQBsAGkAAAAAAAAAZABlAC0AbAB1AAAAAAAAAGQAaQB2AC0AbQB2AAAAAABlAGwALQBnAHIAAAAAAAAAZQBuAC0AYQB1AAAAAAAAAGUAbgAtAGIAegAAAAAAAABlAG4ALQBjAGEAAAAAAAAAZQBuAC0AYwBiAAAAAAAAAGUAbgAtAGcAYgAAAAAAAABlAG4ALQBpAGUAAAAAAAAAZQBuAC0AagBtAAAAAAAAAGUAbgAtAG4AegAAAAAAAABlAG4ALQBwAGgAAAAAAAAAZQBuAC0AdAB0AAAAAAAAAGUAbgAtAHUAcwAAAAAAAABlAG4ALQB6AGEAAAAAAAAAZQBuAC0AegB3AAAAAAAAAGUAcwAtAGEAcgAAAAAAAABlAHMALQBiAG8AAAAAAAAAZQBzAC0AYwBsAAAAAAAAAGUAcwAtAGMAbwAAAAAAAABlAHMALQBjAHIAAAAAAAAAZQBzAC0AZABvAAAAAAAAAGUAcwAtAGUAYwAAAAAAAABlAHMALQBlAHMAAAAAAAAAZQBzAC0AZwB0AAAAAAAAAGUAcwAtAGgAbgAAAAAAAABlAHMALQBtAHgAAAAAAAAAZQBzAC0AbgBpAAAAAAAAAGUAcwAtAHAAYQAAAAAAAABlAHMALQBwAGUAAAAAAAAAZQBzAC0AcAByAAAAAAAAAGUAcwAtAHAAeQAAAAAAAABlAHMALQBzAHYAAAAAAAAAZQBzAC0AdQB5AAAAAAAAAGUAcwAtAHYAZQAAAAAAAABlAHQALQBlAGUAAAAAAAAAZQB1AC0AZQBzAAAAAAAAAGYAYQAtAGkAcgAAAAAAAABmAGkALQBmAGkAAAAAAAAAZgBvAC0AZgBvAAAAAAAAAGYAcgAtAGIAZQAAAAAAAABmAHIALQBjAGEAAAAAAAAAZgByAC0AYwBoAAAAAAAAAGYAcgAtAGYAcgAAAAAAAABmAHIALQBsAHUAAAAAAAAAZgByAC0AbQBjAAAAAAAAAGcAbAAtAGUAcwAAAAAAAABnAHUALQBpAG4AAAAAAAAAaABlAC0AaQBsAAAAAAAAAGgAaQAtAGkAbgAAAAAAAABoAHIALQBiAGEAAAAAAAAAaAByAC0AaAByAAAAAAAAAGgAdQAtAGgAdQAAAAAAAABoAHkALQBhAG0AAAAAAAAAaQBkAC0AaQBkAAAAAAAAAGkAcwAtAGkAcwAAAAAAAABpAHQALQBjAGgAAAAAAAAAaQB0AC0AaQB0AAAAAAAAAGoAYQAtAGoAcAAAAAAAAABrAGEALQBnAGUAAAAAAAAAawBrAC0AawB6AAAAAAAAAGsAbgAtAGkAbgAAAAAAAABrAG8AawAtAGkAbgAAAAAAawBvAC0AawByAAAAAAAAAGsAeQAtAGsAZwAAAAAAAABsAHQALQBsAHQAAAAAAAAAbAB2AC0AbAB2AAAAAAAAAG0AaQAtAG4AegAAAAAAAABtAGsALQBtAGsAAAAAAAAAbQBsAC0AaQBuAAAAAAAAAG0AbgAtAG0AbgAAAAAAAABtAHIALQBpAG4AAAAAAAAAbQBzAC0AYgBuAAAAAAAAAG0AcwAtAG0AeQAAAAAAAABtAHQALQBtAHQAAAAAAAAAbgBiAC0AbgBvAAAAAAAAAG4AbAAtAGIAZQAAAAAAAABuAGwALQBuAGwAAAAAAAAAbgBuAC0AbgBvAAAAAAAAAG4AcwAtAHoAYQAAAAAAAABwAGEALQBpAG4AAAAAAAAAcABsAC0AcABsAAAAAAAAAHAAdAAtAGIAcgAAAAAAAABwAHQALQBwAHQAAAAAAAAAcQB1AHoALQBiAG8AAAAAAHEAdQB6AC0AZQBjAAAAAABxAHUAegAtAHAAZQAAAAAAcgBvAC0AcgBvAAAAAAAAAHIAdQAtAHIAdQAAAAAAAABzAGEALQBpAG4AAAAAAAAAcwBlAC0AZgBpAAAAAAAAAHMAZQAtAG4AbwAAAAAAAABzAGUALQBzAGUAAAAAAAAAcwBrAC0AcwBrAAAAAAAAAHMAbAAtAHMAaQAAAAAAAABzAG0AYQAtAG4AbwAAAAAAcwBtAGEALQBzAGUAAAAAAHMAbQBqAC0AbgBvAAAAAABzAG0AagAtAHMAZQAAAAAAcwBtAG4ALQBmAGkAAAAAAHMAbQBzAC0AZgBpAAAAAABzAHEALQBhAGwAAAAAAAAAcwByAC0AYgBhAC0AYwB5AHIAbAAAAAAAcwByAC0AYgBhAC0AbABhAHQAbgAAAAAAcwByAC0AcwBwAC0AYwB5AHIAbAAAAAAAcwByAC0AcwBwAC0AbABhAHQAbgAAAAAAcwB2AC0AZgBpAAAAAAAAAHMAdgAtAHMAZQAAAAAAAABzAHcALQBrAGUAAAAAAAAAcwB5AHIALQBzAHkAAAAAAHQAYQAtAGkAbgAAAAAAAAB0AGUALQBpAG4AAAAAAAAAdABoAC0AdABoAAAAAAAAAHQAbgAtAHoAYQAAAAAAAAB0AHIALQB0AHIAAAAAAAAAdAB0AC0AcgB1AAAAAAAAAHUAawAtAHUAYQAAAAAAAAB1AHIALQBwAGsAAAAAAAAAdQB6AC0AdQB6AC0AYwB5AHIAbAAAAAAAdQB6AC0AdQB6AC0AbABhAHQAbgAAAAAAdgBpAC0AdgBuAAAAAAAAAHgAaAAtAHoAYQAAAAAAAAB6AGgALQBjAGgAcwAAAAAAegBoAC0AYwBoAHQAAAAAAHoAaAAtAGMAbgAAAAAAAAB6AGgALQBoAGsAAAAAAAAAegBoAC0AbQBvAAAAAAAAAHoAaAAtAHMAZwAAAAAAAAB6AGgALQB0AHcAAAAAAAAAegB1AC0AegBhAAAAAAAAAFUAUwBFAFIAMwAyAC4ARABMAEwAAAAAAE1lc3NhZ2VCb3hXAAAAAABHZXRBY3RpdmVXaW5kb3cAR2V0TGFzdEFjdGl2ZVBvcHVwAAAAAAAAR2V0VXNlck9iamVjdEluZm9ybWF0aW9uVwAAAAAAAABHZXRQcm9jZXNzV2luZG93U3RhdGlvbgAAAAAAAAAAAAaAgIaAgYAAABADhoCGgoAUBQVFRUWFhYUFAAAwMIBQgIgACAAoJzhQV4AABwA3MDBQUIgAAAAgKICIgIAAAABgaGBoaGgICAd4cHB3cHAICAAACAAIAAcIAAAAAAAAAENyZWF0ZUZpbGUyAAAAAABDAE8ATgBPAFUAVAAkAAAAIHMBQAEAAABlKzAwMAAAAAAAAAAAAAAAMSNTTkFOAAAxI0lORAAAADEjSU5GAAAAMSNRTkFOAAAAAAAAAAAAAHAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAg4gJAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEXCgAXVAwAFzQLABcyE/AR4A/QDcALcCEFAgAFZAoAcB8AAO4fAAAAmwIAIQAAAHAfAADuHwAAAJsCAAENBgANMgnwB+AFwANwAlAhDAQADNQMAAU0CgBwGQAAnRkAADybAgAhBQIABWQLAJ0ZAACxGQAATJsCACEAAACdGQAAsRkAAEybAgAhAAAAcBkAAJ0ZAAA8mwIAGRsDAAkBTgACMAAACIEAAGACAAABBgIABlICMBkZAgAHAU0ACIEAAFACAAAhCAIACDRMAEATAAD/EwAAtJsCACEAAABAEwAA/xMAALSbAgAZHgQAEAElAATwAlAIgQAACAEAACEIAgAINCkAsBYAABUXAADomwIAIS8KAC/kIgAn1CMAGMQkABB0KwAIZCoAFRcAAB0XAAD8mwIAIQAEAADEJAAAdCsAFRcAAB0XAAD8mwIAIQAAALAWAAAVFwAA6JsCABkfBQANZFAADQFMAAZwAAAIgQAAUAIAACEIAgAINE8AABAAALMQAABcnAIAIQAAAAAQAACzEAAAXJwCABkcBAAKAVEAA2ACUAiBAABQAgAAIToMADr0TAAy5E0AINROABjETwAQdFAACDRWAEAbAADdGwAAmJwCACEABgAA1E4AAMRPAAB0UABAGwAA3RsAAJicAgAhAAIAAHRQAEAbAADdGwAAmJwCACEAAABAGwAA3RsAAJicAgAhBQIABTQIAKASAADtEgAA5K8CACEAAACgEgAA7RIAAOSvAgABBgIABjICYCETBAATNAYABXQHAIAUAACUFAAAOJ0CACEABAAAdAcAADQGAIAUAACUFAAAOJ0CACEAAgAAdAcAgBQAAJQUAAA4nQIAIQAAAIAUAACUFAAAOJ0CAAEJBAAJUgXgA1ACMCESBgAS9AQADcQFAAV0DAAQIQAAGyEAAJSdAgAhBQIABWQKABshAABHIQAAoJ0CACEAAAAbIQAARyEAAKCdAgAhAAAAECEAABshAACUnQIAGSQCABIBTwAIgQAAYAIAACEhCgAh5E4AEHRTAAxkUgAIVFEABDRQAIAiAACkIgAA8J0CACEAAACAIgAApCIAAPCdAgAZGwMACQFKAAIwAAAIgQAAQAIAAAEKBAAKNAgAClIGcBkyDQAkdCcAJGQmACQ0JQAkAR4AGPAW4BTQEsAQUAAACIEAAOgAAAABCgQACpIGcAVgBDABDwYAD2QNAA80DAAPcgtwGRkCAAcBSQAIgQAAMAIAABkdBQALAVAABHADYAIwAAAIgQAAcAIAABkdBQALARABBHADYAIwAAAIgQAAcAgAABkpCwAXNDgBFwEwARDwDuAM0ArACHAHYAZQAAAIgQAAcAkAABkeBgAPZA8ADzQOAA+SC3AIgQAAQAAAAAFSDQBS5A4ATdQWAEV0FQA9NBQAC+IH8AXAA2ACUAAAAUEIAEFkBwA8NAYAClQIAAoyBnAZKQsAFzSUABcBjAAQ8A7gDNAKwAhwB2AGUAAACIEAAFAEAAABDAQADDQOAAyyCHAZKAkAFlRZABY0WAAWAVIAD/AN4AtwAAAIgQAAgAIAACEIAgAIZFYAkC0AAGkuAAB4nwIAIQAAAJAtAABpLgAAeJ8CABknCQAVVE8AFTRMABUBSAAO4AxwC2AAAAiBAAAwAgAAARoKABp0CQAaZAgAGlQHABo0BgAaMhbgARQIABRkCgAUVAkAFDQIABRSEHABEwgAE2QMABNUCwATUg/wDeALcCEFAgAFNAoAED8AAEg/AAAIoAIAIQAAABA/AABIPwAACKACABkZBAAKNAwACnIGcAiBAAAwAAAAARYKABZUEgAWNBEAFpIS8BDgDsAMcAtgARkKABl0DQAZZAwAGTQLABlSFfAT4BHAGSsHABp0LQEaNCwBGgEoAQtQAAAIgQAAMAkAAAEVCAAVdAkAFWQIABU0BwAVMhHgIQUCAAVUBgAAUQAAXVEAAKCgAgAhAAAAAFEAAF1RAACgoAIAIQACAABUBgAAUQAAXVEAAKCgAgABEggAElQNABI0DAASUg7gDHALYBkqBwAYZBJgGDQRYBgBDmALcAAACIEAAGAAAwAZKgcAGGQQQBg0D0AYAQxAC3AAAAiBAABQAAIAARoKABp0DQAaZAwAGlQLABo0CgAachbgARQKABQ0EgAUkhDwDuAM0ArACHAHYAZQARUIABV0DgAVZA0AFVQMABWSEeAZOQsAKGTFEyg0xBMoAbwTE/AR4A/QDcALUAAACIEAANCdAAAhCAIACHTDExBeAABEYAAAfKECACEAAAAQXgAARGAAAHyhAgAhAAIAAHTDExBeAABEYAAAfKECABk2CQAldGgIJWRnCCU0ZgglAWQIEFAAAAiBAAAQQwAAGScGABYBfQAH4AXAAzACUAiBAADAAwAAISAIACD0egAY1HsAEHR8AAhkggCQUgAAClMAAPihAgAhAAAAkFIAAApTAAD4oQIAGSUGABMBCxAG8ARwA2ACMAiBAABAgAAAIRAEABDkChAIVBIQoHAAAFhzAABAogIAIQAAAKBwAABYcwAAQKICACEABAAA5AoQAFQSEKBwAABYcwAAQKICAAEUCAAUZAwAFFQLABQ0CgAUchBwARQIABRkCAAUVAcAFDQGABQyEHARHAoAHGQPABw0DgAcchjwFuAU0BLAEHDY0AAAAQAAAAt6AAAfewAAQKYBAAAAAAARGQMAGUIVcBQwAADY0AAAAQAAAON8AAAffQAAZKYBAAAAAAARGQMAGUIVcBQwAADY0AAAAQAAAI99AADLfQAAZKYBAAAAAAABFwEAF0IAAAEPAQAPYgAAARkEABmSEnARMBBQEQYCAAYyAjDY0AAAAQAAAAl/AAAQfwAAi6YBAAAAAAAZGQQACjQMAAqSBmAIgQAAQAAAAAEAAAAAAAAAAQAAAAAAAAABAAAAEQ8EAA80BwAPMgtw2NAAAAEAAABQjAAAWowAAKSmAQAAAAAAERkKABl0DAAZZAsAGTQKABlSFfAT4BHQ2NAAAAIAAADMjAAAEI0AALymAQAAAAAAmYwAACmNAADkpgEAAAAAABEaBAAaMhZwFWAUMNjQAAABAAAAIY4AAEuOAAD9pgEAAAAAAAETAQATQgAAERcIABdkCwAXNAoAFzIT8BHgD3DY0AAAAQAAAFWPAAB8jwAAqqgBAAAAAAABCgQACnQCAAU0AQARHQwAHcQNAB10DAAdZAsAHTQKAB1SGfAX4BXQ2NAAAAIAAADFkQAA35EAADCnAQAAAAAAapEAAPGSAABLpwEAAAAAABEVCAAVdAgAFWQHABU0BgAVMhHw2NAAAAEAAADPkAAA7pAAABenAQAAAAAAEQ8EAA80BwAPMgtw2NAAAAEAAAAXlwAAIZcAAKSmAQAAAAAAERwFABxCGOAWcBVgFDAAANjQAAABAAAAlJcAAEyYAABkpwEAAAAAABEZCAAZdAgAGWQHABk0BgAZMhXg2NAAAAEAAABGmgAAWpoAAJKoAQAAAAAAASAMACBkDQAgVAsAIDQKACAyHPAa4BjQFsAUcBETCAATZA0AEzQMABNSD/AN4Atw2NAAAAEAAADpmgAAKZsAAH6nAQAAAAAAERMIABNkDAATNAsAE1IP8A3gC3DY0AAAAgAAANabAAD5mwAAZKcBAAAAAAD+mwAAEpwAAGSnAQAAAAAAARgKABhkDQAYVAsAGDQKABhSFPAS4BBwCQQBAARCAADY0AAAAQAAAC6dAABDnQAAlqcBAEOdAAABBAEABBIAAAEIAQAIQgAAAQkBAAliAAABEgYAEnQTABJkEQAS0gtQAQ8GAA9kBQAPNAQADxILcAETAQATYgAAARQIABRkDgAUVA0AFDQMABSSEHABGQoAGXQLABlkCgAZVAkAGTQIABlSFeAJBAEABEIAANjQAAABAAAA2qYAAO2mAACWpwEA7aYAAAAAAAABAAAACQoEAAo0CQAKUgZw2NAAAAEAAABIqQAA5KkAAJanAQDkqQAAGS8JAB50uwAeZLoAHjS5AB4BtgAQUAAACIEAAKAFAAARBgIABjICMNjQAAABAAAAD68AACWvAAC0pwEAAAAAABEKBAAKNAcACjIGcNjQAAABAAAABrMAAF2zAADNpwEAAAAAABEZCgAZ5AsAGXQKABlkCQAZNAgAGVIV8NjQAAABAAAAv7QAAHa1AADNpwEAAAAAABklCgAWVBEAFjQQABZyEvAQ4A7ADHALYAiBAAA4AAAAGSsHABp0tAAaNLMAGgGwAAtQAAAIgQAAcAUAAAESBAASNA0AEpILUBETBAATNAcAEzIPcNjQAAACAAAA7LkAABm6AADmpwEAAAAAACu6AABiugAA/6cBAAAAAAARCgQACjQGAAoyBnDY0AAAAgAAAMu7AADVuwAA5qcBAAAAAADquwAAEbwAAP+nAQAAAAAAAQoEAAo0BgAKMgZwEQYCAAYyAnDY0AAAAQAAAM29AADjvQAAtKcBAAAAAAAREAYAEHQHABA0BgAQMgzg2NAAAAEAAACqvwAAzb8AABioAQAAAAAAAQYCAAYyAlABCgQACjQNAApyBnABCAQACHIEcANgAjAZLQsAG2RRABtUUAAbNE8AGwFKABTwEuAQcAAACIEAAEACAAAJCgQACjQGAAoyBnDY0AAAAQAAAM3JAAAAygAAQKgBAADKAAARGQoAGXQKABlkCQAZNAgAGTIV8BPgEcDY0AAAAQAAAKbKAABsywAAYKgBAAAAAAABGQoAGXQJABlkCAAZVAcAGTQGABkyFeAJBAEABEIAANjQAAABAAAA/c0AAAHOAAABAAAAAc4AAAEEAQAEQgAAERcKABdkDwAXNA4AF1IT8BHgD9ANwAtw2NAAAAEAAADczwAAY9AAAHSoAQAAAAAAARwMABxkEAAcVA8AHDQOABxyGPAW4BTQEsAQcAEQBgAQdAcAEDQGABAyDOABCQIACTIFMBkwCwAfNGYAHwFcABDwDuAM0ArACHAHYAZQAAAIgQAA2AIAABEZCgAZdAsAGWQKABk0CAAZMhXwE+ARwNjQAAABAAAAmd8AAL/fAACSqAEAAAAAABkwCwAfNKYAHwGcABDwDuAM0ArACHAHYAZQAAAIgQAA0AQAAAEYCAAYZAgAGFQHABg0BgAYMhRwARgKABhkCgAYVAkAGDQIABgyFPAS4BBwARcIABdkCQAXVAgAFzQHABcyE3ABGwoAG3QQABtkDwAbNA4AG5IU8BLgEFABFAgAFGQGABRUBQAUNAQAFBIQcBEPBgAPZAkADzQIAA9SC3DY0AAAAQAAAOLwAABU8QAA3KgBAAAAAAAREQYAETQKABEyDeALcApg2NAAAAEAAADX8QAAG/IAAKqoAQAAAAAAERUIABU0CwAVMhHwD+ANwAtwCmDY0AAAAQAAAL7yAADx8gAA9agBAAAAAAAZNgsAJTRzAyUBaAMQ8A7gDNAKwAhwB2AGUAAACIEAADAbAAARDwQADzQHAA8yC3DY0AAAAQAAAFr7AABl+wAApKYBAAAAAAAZNw0AJWQTAiVUEgIlNBECJQEKAhjwFuAU0BLAEHAAAAiBAABAEAAAERgIABhkCgAYNAgAGDIU8BLgEHDY0AAAAQAAAA7/AAA2/wAAkqgBAAAAAAARIA0AIMQfACB0HgAgZB0AIDQcACABGAAZ8BfgFdAAANjQAAACAAAAhP8AALf/AADBqAEAAAAAAMD/AABTAgEAwagBAAAAAAAREQYAETQKABEyDeALcApg2NAAAAEAAADvAgEAEwMBAKqoAQAAAAAAAQ0GAA00CgANMgngB3AGYBEPBgAPZAkADzQIAA9SC3DY0AAAAQAAAE4GAQBMBwEA3KgBAAAAAAABHAwAHGQPABxUDgAcNAwAHFIY8BbgFNASwBBwAAAAAAEHAgAHAZsAAQAAAAEAAAABAAAAARAGABBkEQAQsgngB3AGUAEGAgAGcgIwAQ8GAA9kEQAPNBAAD9ILcBktDUUfdBIAG2QRABc0EAATQw6SCvAI4AbQBMACUAAACIEAAEgAAAAZMAsAHzSCAB8BeAAQ8A7gDNAKwAhwB2AGUAAACIEAALADAAABDwYAD2QHAA80BgAPMgtwAQwGAAw0DAAMUghwB2AGUAEVCQAVxAUAFXQEABVkAwAVNAIAFfAAAAENBAANNAkADTIGUAEKAgAKMgYwAQ4CAA4yCjABDwYAD2QPAA80DgAPsgtwGS0NNR90EAAbZA8AFzQOABMzDnIK8AjgBtAEwAJQAAAIgQAAMAAAAAEPBgAPZAkADzQIAA9SC3ABBgIABjICMAEQBgAQZA0AEDQMABCSDHAAAAAAAQAAABkeCAAPkgvwCeAHwAVwBGADUAIwCIEAAEgAAAABFQYAFWQQABU0DgAVshFwGSEIABJUDwASNA4AEnIO4AxwC2AIgQAAMAAAAAEZCgAZdA8AGWQOABlUDQAZNAwAGZIV4BEVCAAVNAsAFTIR8A/gDcALcApg2NAAAAEAAADWSwEAC0wBAPWoAQAAAAAAERsKABtkDAAbNAsAGzIX8BXgE9ARwA9w2NAAAAEAAAA4TgEAa04BAPWoAQAAAAAAARwJAByiFfAT4BHQD8ANcAxgCzAKUAAAEQ8EAA80BgAPMgtw2NAAAAEAAACiWQEArlkBAAypAQAAAAAAEQoEAAo0DAAKkgZw2NAAAAEAAAC7XAEA31wBACSpAQAAAAAAAQYCAAZyAlABJQsAJTQbACUBEgAa8BjgFtAUwBJwEWAQUAAAARQIABRkEAAUVA8AFDQOABSyEHAZJQoAFlQRABY0EAAWchLwEOAO0AxwC2AIgQAAOAAAAAEVCAAVdAgAFWQHABU0BgAVMhHgGSgKABo0GwAa8hDwDuAM0ArACHAHYAZQCIEAAHAAAAABEggAElQKABI0CAASMg7gDHALYAEdDAAddAsAHWQKAB1UCQAdNAgAHTIZ8BfgFdAZHAQADTQUAA3yBnAIgQAAeAAAABkaBAAL8gRwA2ACMAiBAAB4AAAAGS0MAB90FQAfZBQAHzQSAB+yGPAW4BTQEsAQUAiBAABYAAAAGSoLABw0HgAcARQAEPAO4AzQCsAIcAdgBlAAAAiBAACYAAAAAQQBAASCAAABBAEABGIAAAEdDAAddBEAHWQQAB1UDwAdNA4AHZIZ8BfgFdAZGwYADAERAAVwBGADUAIwCIEAAHAAAAABHAwAHGQSABxUEQAcNBAAHJIY8BbgFNASwBBwARkKABl0DQAZZAwAGVQLABk0CgAZchXgGRgFAAniBXAEYANQAjAAAAiBAABgAAAAGR0GAA7yB+AFcARgA1ACMAiBAABwAAAAARgKABhkCAAYVAcAGDQGABgSFOASwBBwARIGABLkEwASdBEAEtILUAEEAQAEIgAAGR8GABEBEQAFcARgAzACUAiBAABwAAAAAQUCAAU0AQAZKgsAHDQhABwBGAAQ8A7gDNAKwAhwB2AGUAAACIEAALAAAABItwIAAAAAAAAAAADStwIAgLUBANi2AgAAAAAAAAAAAAK4AgAQtQEAaLcCAAAAAAAAAAAAELgCAKC1AQDAtgIAAAAAAAAAAABMuAIA+LQBAHCzAgAAAAAAAAAAACa8AgCosQEA8LYCAAAAAAAAAAAA1LwCACi1AQA4swIAAAAAAAAAAAAqvQIAcLEBACizAgAAAAAAAAAAAEC9AgBgsQEAyLECAAAAAAAAAAAAVMACAACwAQAAAAAAAAAAAAAAAAAAAAAAAAAAABK+AgAAAAAAPMACAAAAAAAswAIAAAAAABrAAgAAAAAACsACAAAAAAD6vwIAAAAAAOi/AgAAAAAA1r8CAAAAAADEvwIAAAAAALK/AgAAAAAApL8CAAAAAACOvwIAAAAAAHa/AgAAAAAAZr8CAAAAAABQvwIAAAAAAEC/AgAAAAAALr8CAAAAAAAevwIAAAAAAAy/AgAAAAAA+r4CAAAAAADkvgIAAAAAANC+AgAAAAAAtL4CAAAAAACkvgIAAAAAAJi+AgAAAAAAiL4CAAAAAAB2vgIAAAAAAGS+AgAAAAAATL4CAAAAAAA2vgIAAAAAACy+AgAAAAAAIr4CAAAAAAACvgIAAAAAAPi9AgAAAAAA3L0CAAAAAADGvQIAAAAAALC9AgAAAAAAnr0CAAAAAACKvQIAAAAAAHq9AgAAAAAAbL0CAAAAAABcvQIAAAAAAE69AgAAAAAAAAAAAAAAAAA0vQIAAAAAAAAAAAAAAAAAFL0CAAAAAAAKvQIAAAAAAP68AgAAAAAA8LwCAAAAAADgvAIAAAAAACC9AgAAAAAAAAAAAAAAAABOuwIAAAAAAGK7AgAAAAAAcrsCAAAAAACMuwIAAAAAAKC7AgAAAAAAtrsCAAAAAADMuwIAAAAAANi7AgAAAAAA6rsCAAAAAAACvAIAAAAAABa8AgAAAAAANLsCAAAAAACCwwIAAAAAAGjDAgAAAAAATsMCAAAAAAA+wwIAAAAAACrDAgAAAAAAGMMCAAAAAAAKwwIAAAAAAPjCAgAAAAAA7sICAAAAAADgwgIAAAAAAB67AgAAAAAADLsCAAAAAAD+ugIAAAAAAOS6AgAAAAAA1LoCAAAAAACougIAAAAAAL66AgAAAAAAgLoCAAAAAACOugIAAAAAAHS6AgAAAAAAVroCAAAAAABAugIAAAAAACy6AgAAAAAAHroCAAAAAAAQugIAAAAAAPq5AgAAAAAA6rkCAAAAAADYuQIAAAAAABrEAgAAAAAAxrkCAAAAAAC2uQIAAAAAAKi5AgAAAAAAnLkCAAAAAACKuQIAAAAAAHq5AgAAAAAAcrkCAAAAAABcuQIAAAAAAFC5AgAAAAAAQLkCAAAAAAAwuQIAAAAAABy5AgAAAAAADrkCAAAAAAD+uAIAAAAAAOq4AgAAAAAA1LgCAAAAAADCuAIAAAAAAK64AgAAAAAAnrgCAAAAAACOuAIAAAAAAIC4AgAAAAAAdLgCAAAAAABmuAIAAAAAAFS4AgAAAAAAnMMCAAAAAAC2wwIAAAAAAMbDAgAAAAAA3MMCAAAAAADowwIAAAAAAPbDAgAAAAAACsQCAAAAAABiwAIAAAAAAHLAAgAAAAAAgsACAAAAAACQwAIAAAAAAKbAAgAAAAAAvMACAAAAAADIwAIAAAAAANTAAgAAAAAA5sACAAAAAAD6wAIAAAAAAAzBAgAAAAAAJMECAAAAAAA8wQIAAAAAAEzBAgAAAAAAXMECAAAAAABywQIAAAAAAIDBAgAAAAAAlMECAAAAAACwwQIAAAAAAMLBAgAAAAAA1MECAAAAAADewQIAAAAAAOrBAgAAAAAA9sECAAAAAAAOwgIAAAAAACLCAgAAAAAAPMICAAAAAABQwgIAAAAAAGzCAgAAAAAAisICAAAAAACywgIAAAAAAMbCAgAAAAAA0sICAAAAAAAAAAAAAAAAADK4AgAAAAAAHLgCAAAAAAAAAAAAAAAAAN63AgAAAAAA7rcCAAAAAAAAAAAAAAAAAHi8AgAAAAAAarwCAAAAAACKvAIAAAAAAES8AgAAAAAANLwCAAAAAACWvAIAAAAAAKq8AgAAAAAAuLwCAAAAAADGvAIAAAAAAF68AgAAAAAAAAAAAAAAAACqtwIAAAAAAMC3AgAAAAAAkLcCAAAAAAAAAAAAAAAAAHMAAAAAAACAOQAAAAAAAIAMAAAAAAAAgDQAAAAAAACAAAAAAAAAAAAFAEdldEZpbGVWZXJzaW9uSW5mb1NpemVXAAYAR2V0RmlsZVZlcnNpb25JbmZvVwAOAFZlclF1ZXJ5VmFsdWVXAABWRVJTSU9OLmRsbADaAE5ldFNlcnZlckVudW0AZQBOZXRBcGlCdWZmZXJGcmVlAABORVRBUEkzMi5kbGwAAFdTMl8zMi5kbGwAAAYAV05ldEFkZENvbm5lY3Rpb24yVwAMAFdOZXRDYW5jZWxDb25uZWN0aW9uMlcAAE1QUi5kbGwATAJHZXRQcm9jQWRkcmVzcwAARgNMb2NhbEFsbG9jAABKA0xvY2FsRnJlZQD6AUdldEZpbGVUeXBlAGsCR2V0U3RkSGFuZGxlAABBA0xvYWRMaWJyYXJ5VwAAHgJHZXRNb2R1bGVIYW5kbGVXAACNAUdldENvbW1hbmRMaW5lVwAaAkdldE1vZHVsZUZpbGVOYW1lVwAAigRTZXRQcmlvcml0eUNsYXNzAABWA0xvY2tSZXNvdXJjZQAAaAFGcmVlTGlicmFyeQDGAUdldEN1cnJlbnRQcm9jZXNzAAgCR2V0TGFzdEVycm9yAACABFNldExhc3RFcnJvcgAAZwRTZXRFdmVudAAACAVXYWl0Rm9yU2luZ2xlT2JqZWN0AMAEU2xlZXAAQwNMb2FkUmVzb3VyY2UAAL8EU2l6ZW9mUmVzb3VyY2UAADQFV3JpdGVGaWxlAFIAQ2xvc2VIYW5kbGUAmgJHZXRUaWNrQ291bnQAAGMBRm9ybWF0TWVzc2FnZUEAAEADTG9hZExpYnJhcnlFeFcAAFQBRmluZFJlc291cmNlVwB3AkdldFN5c3RlbURpcmVjdG9yeVcAjwBDcmVhdGVGaWxlVwDXAERlbGV0ZUZpbGVXAJUBR2V0Q29tcHV0ZXJOYW1lVwAAaQNNdWx0aUJ5dGVUb1dpZGVDaGFyALgBR2V0Q29uc29sZVNjcmVlbkJ1ZmZlckluZm8AAMMDUmVhZEZpbGUAAKoCR2V0VmVyc2lvbgAAiwRTZXRQcm9jZXNzQWZmaW5pdHlNYXNrAADHAUdldEN1cnJlbnRQcm9jZXNzSWQA5gFHZXRFeGl0Q29kZVByb2Nlc3MAABYEUmVzdW1lVGhyZWFkAAAGBVdhaXRGb3JNdWx0aXBsZU9iamVjdHMAAPkBR2V0RmlsZVRpbWUA7ABEdXBsaWNhdGVIYW5kbGUA5QBEaXNjb25uZWN0TmFtZWRQaXBlAIkEU2V0TmFtZWRQaXBlSGFuZGxlU3RhdGUA2ARUcmFuc2FjdE5hbWVkUGlwZQCFAENyZWF0ZUV2ZW50VwAA4wFHZXRFbnZpcm9ubWVudFZhcmlhYmxlVwACAkdldEZ1bGxQYXRoTmFtZVcAAG8EU2V0RmlsZUF0dHJpYnV0ZXNXAADxAUdldEZpbGVBdHRyaWJ1dGVzVwAAdQBDb3B5RmlsZVcADwVXYWl0TmFtZWRQaXBlVwAAOwRTZXRDb25zb2xlQ3RybEhhbmRsZXIAVgRTZXRDb25zb2xlVGl0bGVXAADBA1JlYWRDb25zb2xlVwAAS0VSTkVMMzIuZGxsAACAAlNlbmRNZXNzYWdlVwAAqgBEaWFsb2dCb3hJbmRpcmVjdFBhcmFtVwDaAEVuZERpYWxvZwApAUdldERsZ0l0ZW0AANMCU2V0V2luZG93VGV4dFcAAI4CU2V0Q3Vyc29yAH4BR2V0U3lzQ29sb3JCcnVzaAAAuQFJbmZsYXRlUmVjdADvAUxvYWRDdXJzb3JXAP4BTG9hZFN0cmluZ1cAVVNFUjMyLmRsbAAAywFHZXREZXZpY2VDYXBzAJQCU2V0TWFwTW9kZQAAsAJTdGFydERvY1cA7wBFbmREb2MAALICU3RhcnRQYWdlAPIARW5kUGFnZQBHREkzMi5kbGwAFQBQcmludERsZ1cAQ09NRExHMzIuZGxsAAAwAlJlZ0Nsb3NlS2V5ADwCUmVnQ3JlYXRlS2V5VwBkAlJlZ09wZW5LZXlXAGECUmVnT3BlbktleUV4VwBuAlJlZ1F1ZXJ5VmFsdWVFeFcAAH4CUmVnU2V0VmFsdWVFeFcAAFoBR2V0VG9rZW5JbmZvcm1hdGlvbgDCAlNldFRva2VuSW5mb3JtYXRpb24AIABBbGxvY2F0ZUFuZEluaXRpYWxpemVTaWQAACABRnJlZVNpZAA2AUdldExlbmd0aFNpZAAAdgFJbml0aWFsaXplQWNsABYAQWRkQWNlAAAjAUdldEFjZQAAEABBZGRBY2Nlc3NBbGxvd2VkQWNlAJcBTG9va3VwUHJpdmlsZWdlVmFsdWVXAE4BR2V0U2VjdXJpdHlJbmZvALsCU2V0U2VjdXJpdHlJbmZvAKsBTHNhRnJlZU1lbW9yeQCdAUxzYUNsb3NlAAC9AUxzYU9wZW5Qb2xpY3kApAFMc2FFbnVtZXJhdGVBY2NvdW50UmlnaHRzAPcBT3BlblByb2Nlc3NUb2tlbgAAVwBDbG9zZVNlcnZpY2VIYW5kbGUAAFwAQ29udHJvbFNlcnZpY2UAAIEAQ3JlYXRlU2VydmljZVcAANoARGVsZXRlU2VydmljZQD5AU9wZW5TQ01hbmFnZXJXAAD7AU9wZW5TZXJ2aWNlVwAAKAJRdWVyeVNlcnZpY2VTdGF0dXMAAMkCU3RhcnRTZXJ2aWNlVwCxAENyeXB0QWNxdWlyZUNvbnRleHRXAADLAENyeXB0UmVsZWFzZUNvbnRleHQAwABDcnlwdEdlbktleQC1AENyeXB0RGVyaXZlS2V5AAC3AENyeXB0RGVzdHJveUtleQC/AENyeXB0RXhwb3J0S2V5AADKAENyeXB0SW1wb3J0S2V5AAC6AENyeXB0RW5jcnlwdAAAtABDcnlwdERlY3J5cHQAALMAQ3J5cHRDcmVhdGVIYXNoAMgAQ3J5cHRIYXNoRGF0YQB8AENyZWF0ZVByb2Nlc3NBc1VzZXJXAABBRFZBUEkzMi5kbGwAAO4ARW5jb2RlUG9pbnRlcgDLAERlY29kZVBvaW50ZXIAHwFFeGl0UHJvY2VzcwAdAkdldE1vZHVsZUhhbmRsZUV4VwAAIAVXaWRlQ2hhclRvTXVsdGlCeXRlANcCSGVhcEZyZWUAANMCSGVhcEFsbG9jALIBR2V0Q29uc29sZU1vZGUAALgDUmVhZENvbnNvbGVJbnB1dEEASwRTZXRDb25zb2xlTW9kZQAA8gBFbnRlckNyaXRpY2FsU2VjdGlvbgAAOwNMZWF2ZUNyaXRpY2FsU2VjdGlvbgAAlARTZXRTdGRIYW5kbGUAALQAQ3JlYXRlVGhyZWFkAADLAUdldEN1cnJlbnRUaHJlYWRJZAAAIAFFeGl0VGhyZWFkAAACA0lzRGVidWdnZXJQcmVzZW50AAYDSXNQcm9jZXNzb3JGZWF0dXJlUHJlc2VudABwAkdldFN0cmluZ1R5cGVXAAAMA0lzVmFsaWRDb2RlUGFnZQBuAUdldEFDUAAAPgJHZXRPRU1DUAAAeAFHZXRDUEluZm8A0gBEZWxldGVDcml0aWNhbFNlY3Rpb24AGARSdGxDYXB0dXJlQ29udGV4dAAfBFJ0bExvb2t1cEZ1bmN0aW9uRW50cnkAACYEUnRsVmlydHVhbFVud2luZAAA4gRVbmhhbmRsZWRFeGNlcHRpb25GaWx0ZXIAALMEU2V0VW5oYW5kbGVkRXhjZXB0aW9uRmlsdGVyAOsCSW5pdGlhbGl6ZUNyaXRpY2FsU2VjdGlvbkFuZFNwaW5Db3VudADOBFRlcm1pbmF0ZVByb2Nlc3MAANMEVGxzQWxsb2MAANUEVGxzR2V0VmFsdWUA1gRUbHNTZXRWYWx1ZQDUBFRsc0ZyZWUAagJHZXRTdGFydHVwSW5mb1cAJQRSdGxV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AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAbgBvAHIAbQBhAGwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAYQBiAG8AdgBlAG4AbwByAG0AYQBsAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAaABpAGcAaAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAAAAcgBlAGEAbAB0AGkAbQBlAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAYgBhAGMAawBnAHIAbwB1AG4AZAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAA/////1AAUwBFAFgARQBTAFYAQwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAQEA/////////////////////////////////////////////////////wAAAAAAAAAAAAAAADKi3y2ZKwAAzV0g0mbU///AqAVAAQAAAAAAAAAAAAAAwKgFQAEAAAABAQAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAAACAgICAgICAgICAgICAgICAgICAgICAgICAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAYWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXoAAAAAAABBQkNERUZHSElKS0xNTk9QUVJTVFVWV1hZWgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAAACAgICAgICAgICAgICAgICAgICAgICAgICAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAYWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXoAAAAAAABBQkNERUZHSElKS0xNTk9QUVJTVFVWV1hZWgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAgQIAAAAAKQDAABggnmCIQAAAAAAAACm3wAAAAAAAKGlAAAAAAAAgZ/g/AAAAABAfoD8AAAAAKgDAADBo9qjIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgf4AAAAAAABA/gAAAAAAALUDAADBo9qjIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgf4AAAAAAABB/gAAAAAAALYDAADPouSiGgDlouiiWwAAAAAAAAAAAAAAAAAAAAAAgf4AAAAAAABAfqH+AAAAAFEFAABR2l7aIABf2mraMgAAAAAAAAAAAAAAAAAAAAAAgdPY3uD5AAAxfoH+AAAAAADoAkABAAAA/////wAAAAABAAAAFgAAAAIAAAACAAAAAwAAAAIAAAAEAAAAGAAAAAUAAAANAAAABgAAAAkAAAAHAAAADAAAAAgAAAAMAAAACQAAAAwAAAAKAAAABwAAAAsAAAAIAAAADAAAABYAAAANAAAAFgAAAA8AAAACAAAAEAAAAA0AAAARAAAAEgAAABIAAAACAAAAIQAAAA0AAAA1AAAAAgAAAEEAAAANAAAAQwAAAAIAAABQAAAAEQAAAFIAAAANAAAAUwAAAA0AAABXAAAAFgAAAFkAAAALAAAAbAAAAA0AAABtAAAAIAAAAHAAAAAcAAAAcgAAAAkAAAAGAAAAFgAAAIAAAAAKAAAAgQAAAAoAAACCAAAACQAAAIMAAAAWAAAAhAAAAA0AAACRAAAAKQAAAJ4AAAANAAAAoQAAAAIAAACkAAAACwAAAKcAAAANAAAAtwAAABEAAADOAAAAAgAAANcAAAALAAAAGAcAAAwAAAAMAAAACAAAAAEAAABDAAAAAAAAAAAAAACMSQJAAQAAAJBJAkABAAAAlEkCQAEAAACYSQJAAQAAAJxJAkABAAAAoEkCQAEAAACkSQJAAQAAAKhJAkABAAAAsEkCQAEAAAC4SQJAAQAAAMBJAkABAAAA0EkCQAEAAADcSQJAAQAAAOhJAkABAAAA9EkCQAEAAAD4SQJAAQAAAPxJAkABAAAAAEoCQAEAAAAESgJAAQAAAAhKAkABAAAADEoCQAEAAAAQSgJAAQAAABRKAkABAAAAGEoCQAEAAAAcSgJAAQAAACBKAkABAAAAKEoCQAEAAAAwSgJAAQAAADxKAkABAAAAREoCQAEAAAAESgJAAQAAAExKAkABAAAAVEoCQAEAAABcSgJAAQAAAGhKAkABAAAAeEoCQAEAAACASgJAAQAAAJBKAkABAAAAnEoCQAEAAACgSgJAAQAAAKhKAkABAAAAuEoCQAEAAADQSgJAAQAAAAEAAAAAAAAA4EoCQAEAAADoSgJAAQAAAPBKAkABAAAA+EoCQAEAAAAASwJAAQAAAAhLAkABAAAAEEsCQAEAAAAYSwJAAQAAAChLAkABAAAAOEsCQAEAAABISwJAAQAAAGBLAkABAAAAeEsCQAEAAACISwJAAQAAAKBLAkABAAAAqEsCQAEAAACwSwJAAQAAALhLAkABAAAAwEsCQAEAAADISwJAAQAAANBLAkABAAAA2EsCQAEAAADgSwJAAQAAAOhLAkABAAAA8EsCQAEAAAD4SwJAAQAAAABMAkABAAAAEEwCQAEAAAAoTAJAAQAAADhMAkABAAAAwEsCQAEAAABITAJAAQAAAFhMAkABAAAAaEwCQAEAAAB4TAJAAQAAAJBMAkABAAAAoEwCQAEAAAC4TAJAAQAAAMxMAkABAAAA1EwCQAEAAADgTAJAAQAAAPhMAkABAAAAIE0CQAEAAAA4TQJAAQAAAIDvAkABAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAKTsAkABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAApOwCQAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACk7AJAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAKTsAkABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAApOwCQAEAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAg9AJAAQAAAAAAAAAAAAAAAAAAAAAAAAAQXwJAAQAAAKBjAkABAAAAIGUCQAEAAACw7AJAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP7///8AAAAAFGECQAEAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP////8AAAAAAAAAAAAAAADAOgFAAQAAAMA6AUABAAAAwDoBQAEAAADAOgFAAQAAAMA6AUABAAAAwDoBQAEAAADAOgFAAQAAAMA6AUABAAAAwDoBQAEAAADAOgFAAQAAAGxcAkABAAAAeFwCQAEAAAD+/////////wEAAAACAAAA//////////+ACgAA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baAAABimAgBwoAAAg6AAACipAgCEoAAAH6EAABCmAgAgoQAAcKIAACCmAgCQogAA9qIAACStAgD4ogAA9KQAADCmAgD0pAAAKaUAAECmAgAspQAA26UAAEimAgDcpQAAzqYAAFymAgDQpgAA+qYAAHSmAgD8pgAAMKcAAHytAgAwpwAAoacAAHytAgDApwAAh6gAAJimAgCIqAAACKoAAJymAgAIqgAANKoAAHytAgA0qgAARqoAACipAgBIqgAAOqsAAMCmAgBEqwAAqasAAPSfAgCsqwAAyqsAAOyvAgDMqwAAB6wAACipAgCUrAAAKq4AAKyiAgDQrgAARa8AAOCmAgBIrwAAqq8AAASoAgCsrwAA1K8AACipAgDUrwAAUbAAAHysAgBUsAAA4rAAAKyiAgDksAAAxbIAAHSnAgDIsgAAgrMAAACnAgCEswAAyLUAACSnAgDItQAAdrgAAFSnAgB4uAAAQrkAAJCnAgBMuQAAf7oAAJynAgCAugAAvLoAAHytAgC8ugAA4LoAAHytAgDgugAAYrsAAASoAgBkuwAAJrwAANCnAgAovAAAp7wAAHytAgCovAAAzLwAACipAgDMvAAA7LwAACipAgDsvAAAOr0AAASoAgA8vQAAXL0AACipAgCsvQAA870AABCoAgD0vQAALL4AAASoAgAsvgAAZL4AAASoAgBkvgAAqL4AAASoAgCovgAAL78AAKyiAgAwvwAA7b8AADCoAgDwvwAAUcAAAOCsAgBswAAA2cAAAGCoAgDcwAAATcEAAGyoAgDAwQAA68EAACipAgDswQAAOMIAAHytAgA4wgAAMsYAAHytAgBExgAAY8YAAHytAgBkxgAAhMYAAHytAgCExgAAx8YAACipAgD4xgAAZ8kAAHioAgDAyQAADcoAAJyoAgBAygAAg8oAAHytAgCEygAAjssAAMCoAgCQywAAp8sAACipAgCoywAAJ8wAAPCoAgAozAAAoswAAPCoAgCkzAAAJc0AAPCoAgAozQAArM0AACCqAgCszQAA5c0AAASoAgDozQAAB84AAAipAgAIzgAAJc4AACipAgAozgAAW84AAHytAgCczgAAz9AAADCpAgDY0AAAudIAAGCpAgC80gAA89IAAIypAgD00gAAw9MAAHypAgDE0wAA5NMAACipAgDk0wAA9N0AAJSpAgD03QAA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5IH//0iLi5gAAADo2IH//0iLi6AAAADozIH//0iLi6gAAADowIH//0iLi7AAAADotIH//0iLi7gAAADoqIH//0iLi8AAAADonIH//0iLi8gAAADokIH//0iLi9AAAADohIH//0iLi9gAAADoeIH//0iLi+AAAADobIH//0iLi+gAAADoYIH//0iLi/AAAADoVIH//0iLi/gAAADoSIH//0iLiwABAADoPIH//0iLiwgBAADoMIH//0iLixABAADoJIH//0iLixgBAADoGIH//0iLiyABAADoDIH//0iLiygBAADoAIH//0iLizABAADo9ID//0iLizgBAADo6ID//0iLi0ABAADo3ID//0iLi0gBAADo0ID//0iLi1ABAADoxID//0iLi2gBAADouID//0iLi3ABAADorID//0iLi3gBAADooID//0iLi4ABAADolID//0iLi4gBAADoiID//0iLi5ABAADofID//0iLi2ABAADocID//0iLi6ABAADoZID//0iLi6gBAADoWID//0iLi7ABAADoTID//0iLi7gBAADoQID//0iLi8ABAADoNID//0iLi8gBAADoKID//0iLi5gBAADoHID//0iLi9ABAADoEID//0iLi9gBAADoBID//0iLi+ABAADo+H///0iLi+gBAADo7H///0iLi/ABAADo4H///0iLi/gBAADo1H///0iLiwACAADoyH///0iLiwgCAADovH///0iLixACAADosH///0iLixgCAADopH///0iLiyACAADomH///0iLiygCAADojH///0iLizACAADogH///0iLizgCAADodH///0iLi0ACAADoaH///0iLi0gCAADoXH///0iLi1ACAADoUH///0iLi1gCAADoRH///0iLi2ACAADoOH///0iLi2gCAADoLH///0iLi3ACAADoIH///0iLi3gCAADoFH///0iLi4ACAADoCH///0iLi4gCAADo/H7//0iLi5ACAADo8H7//0iLi5gCAADo5H7//0iLi6ACAADo2H7//0iLi6gCAADozH7//0iLi7ACAADowH7//0iLi7gCAADotH7//0iDxCBbw8zMQFVBVEFVQVZBV0iD7FBIjWwkQEiJXUBIiXVISIl9UEiLBRJJAQBIM8VIiUUIi11gM/9Ni+FFi+hIiVUAhdt+KkSL00mLwUH/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FyZFxicmRyYlxicmRyc1xicmRydzEwXGJyc3AyMCBcc2IxMjBcc2ExMjBcYlxmMFxmczI0IFNZU0lOVEVSTkFMUyBTT0ZUV0FSRSBMSUNFTlNFIFRFUk1TXGZzMjhccGFyAAAAAAAAAAAAAAAAXHBhcmRcc2IxMjBcc2ExMjBcYjBcZnMxOSBUaGVzZSBsaWNlbnNlIHRlcm1zIGFyZSBhbiBhZ3JlZW1lbnQgYmV0d2VlbiBTeXNpbnRlcm5hbHMgKGEgd2hvbGx5IG93bmVkIHN1YnNpZGlhcnkgb2YgTWljcm9zb2Z0IENvcnBvcmF0aW9uKSBhbmQgeW91LiAgUGxlYXNlIHJlYWQgdGhlbS4gIFRoZXkgYXBwbHkgdG8gdGhlIHNvZnR3YXJlIHlvdSBhcmUgZG93bmxvYWRpbmcgZnJvbSBTeXN0aW50ZXJuYWxzLmNvbSwgd2hpY2ggaW5jbHVkZXMgdGhlIG1lZGlhIG9uIHdoaWNoIHlvdSByZWNlaXZlZCBpdCwgaWYgYW55LiAgVGhlIHRlcm1zIGFsc28gYXBwbHkgdG8gYW55IFN5c2ludGVybmFsc1xwYXIAAABccGFyZFxmaS0zNjNcbGk3MjBcc2IxMjBcc2ExMjBcdHg3MjBcJ2I3XHRhYiB1cGRhdGVzLFxwYXIAAAAAAAAAXHBhcmRcZmktMzYzXGxpNzIwXHNiMTIwXHNhMTIwXCdiN1x0YWIgc3VwcGxlbWVudHMsXHBhcgBcJ2I3XHRhYiBJbnRlcm5ldC1iYXNlZCBzZXJ2aWNlcywgYW5kIFxwYXIAAAAAAABcJ2I3XHRhYiBzdXBwb3J0IHNlcnZpY2VzXHBhcgAAAFxwYXJkXHNiMTIwXHNhMTIwIGZvciB0aGlzIHNvZnR3YXJlLCB1bmxlc3Mgb3RoZXIgdGVybXMgYWNjb21wYW55IHRob3NlIGl0ZW1zLiAgSWYgc28sIHRob3NlIHRlcm1zIGFwcGx5LlxwYXIAAABcYiBCWSBVU0lORyBUSEUgU09GVFdBUkUsIFlPVSBBQ0NFUFQgVEhFU0UgVEVSTVMuICBJRiBZT1UgRE8gTk9UIEFDQ0VQVCBUSEVNLCBETyBOT1QgVVNFIFRIRSBTT0ZUV0FSRS5ccGFyAAAAAAAAXHBhcmRcYnJkcnRcYnJkcnNcYnJkcncxMFxicnNwMjAgXHNiMTIwXHNhMTIwIElmIHlvdSBjb21wbHkgd2l0aCB0aGVzZSBsaWNlbnNlIHRlcm1zLCB5b3UgaGF2ZSB0aGUgcmlnaHRzIGJlbG93LlxwYXIAAAAAAAAAAAAAAABccGFyZFxmaS0zNTdcbGkzNTdcc2IxMjBcc2ExMjBcdHgzNjBcZnMyMCAxLlx0YWJcZnMxOSBJTlNUQUxMQVRJT04gQU5EIFVTRSBSSUdIVFMuICBcYjAgWW91IG1heSBpbnN0YWxsIGFuZCB1c2UgYW55IG51bWJlciBvZiBjb3BpZXMgb2YgdGhlIHNvZnR3YXJlIG9uIHlvdXIgZGV2aWNlcy5cYlxwYXIAAAAAAFxjYXBzXGZzMjAgMi5cdGFiXGZzMTkgU2NvcGUgb2YgTGljZW5zZVxjYXBzMCAuXGIwICAgVGhlIHNvZnR3YXJlIGlzIGxpY2Vuc2VkLCBub3Qgc29sZC4gVGhpcyBhZ3JlZW1lbnQgb25seSBnaXZlcyB5b3Ugc29tZSByaWdodHMgdG8gdXNlIHRoZSBzb2Z0d2FyZS4gIFN5c2ludGVybmFscyByZXNlcnZlcyBhbGwgb3RoZXIgcmlnaHRzLiAgVW5sZXNzIGFwcGxpY2FibGUgbGF3IGdpdmVzIHlvdSBtb3JlIHJpZ2h0cyBkZXNwaXRlIHRoaXMgbGltaXRhdGlvbiwgeW91IG1heSB1c2UgdGhlIHNvZnR3YXJlIG9ubHkgYXMgZXhwcmVzc2x5IHBlcm1pdHRlZCBpbiB0aGlzIGFncmVlbWVudC4gIEluIGRvaW5nIHNvLCB5b3UgbXVzdCBjb21wbHkgd2l0aCBhbnkgdGVjaG5pY2FsIGxpbWl0YXRpb25zIGluIHRoZSBzb2Z0d2FyZSB0aGF0IG9ubHkgYWxsb3cgeW91IHRvIHVzZSBpdCBpbiBjZXJ0YWluIHdheXMuICAgIFlvdSBtYXkgbm90XGJccGFyAFxwYXJkXGZpLTM2M1xsaTcyMFxzYjEyMFxzYTEyMFx0eDcyMFxiMFwnYjdcdGFiIHdvcmsgYXJvdW5kIGFueSB0ZWNobmljYWwgbGltaXRhdGlvbnMgaW4gdGhlIGJpbmFyeSB2ZXJzaW9ucyBvZiB0aGUgc29mdHdhcmU7XHBhcgAAAAAAAAAAAAAAAAAAAFxwYXJkXGZpLTM2M1xsaTcyMFxzYjEyMFxzYTEyMFwnYjdcdGFiIHJldmVyc2UgZW5naW5lZXIsIGRlY29tcGlsZSBvciBkaXNhc3NlbWJsZSB0aGUgYmluYXJ5IHZlcnNpb25zIG9mIHRoZSBzb2Z0d2FyZSwgZXhjZXB0IGFuZCBvbmx5IHRvIHRoZSBleHRlbnQgdGhhdCBhcHBsaWNhYmxlIGxhdyBleHByZXNzbHkgcGVybWl0cywgZGVzcGl0ZSB0aGlzIGxpbWl0YXRpb247XHBhcgAAAAAAAAAAXCdiN1x0YWIgbWFrZSBtb3JlIGNvcGllcyBvZiB0aGUgc29mdHdhcmUgdGhhbiBzcGVjaWZpZWQgaW4gdGhpcyBhZ3JlZW1lbnQgb3IgYWxsb3dlZCBieSBhcHBsaWNhYmxlIGxhdywgZGVzcGl0ZSB0aGlzIGxpbWl0YXRpb247XHBhcgAAAFwnYjdcdGFiIHB1Ymxpc2ggdGhlIHNvZnR3YXJlIGZvciBvdGhlcnMgdG8gY29weTtccGFyAAAAXCdiN1x0YWIgcmVudCwgbGVhc2Ugb3IgbGVuZCB0aGUgc29mdHdhcmU7XHBhcgAAXCdiN1x0YWIgdHJhbnNmZXIgdGhlIHNvZnR3YXJlIG9yIHRoaXMgYWdyZWVtZW50IHRvIGFueSB0aGlyZCBwYXJ0eTsgb3JccGFyAAAAAABcJ2I3XHRhYiB1c2UgdGhlIHNvZnR3YXJlIGZvciBjb21tZXJjaWFsIHNvZnR3YXJlIGhvc3Rpbmcgc2VydmljZXMuXHBhcgAAAAAAAAAAAFxwYXJkXGZpLTM1N1xsaTM1N1xzYjEyMFxzYTEyMFx0eDM2MFxiXGZzMjAgMy5cdGFiIFNFTlNJVElWRSBJTkZPUk1BVElPTi4gXGIwICBQbGVhc2UgYmUgYXdhcmUgdGhhdCwgc2ltaWxhciB0byBvdGhlciBkZWJ1ZyB0b29scyB0aGF0IGNhcHR1cmUgXGxkYmxxdW90ZSBwcm9jZXNzIHN0YXRlXHJkYmxxdW90ZSAgaW5mb3JtYXRpb24sIGZpbGVzIHNhdmVkIGJ5IFN5c2ludGVybmFscyB0b29scyBtYXkgaW5jbHVkZSBwZXJzb25hbGx5IGlkZW50aWZpYWJsZSBvciBvdGhlciBzZW5zaXRpdmUgaW5mb3JtYXRpb24gKHN1Y2ggYXMgdXNlcm5hbWVzLCBwYXNzd29yZHMsIHBhdGhzIHRvIGZpbGVzIGFjY2Vzc2VkLCBhbmQgcGF0aHMgdG8gcmVnaXN0cnkgYWNjZXNzZWQpLiBCeSB1c2luZyB0aGlzIHNvZnR3YXJlLCB5b3UgYWNrbm93bGVkZ2UgdGhhdCB5b3UgYXJlIGF3YXJlIG9mIHRoaXMgYW5kIHRha2Ugc29sZSByZXNwb25zaWJpbGl0eSBmb3IgYW55IHBlcnNvbmFsbHkgaWRlbnRpZmlhYmxlIG9yIG90aGVyIHNlbnNpdGl2ZSBpbmZvcm1hdGlvbiBwcm92aWRlZCB0byBNaWNyb3NvZnQgb3IgYW55IG90aGVyIHBhcnR5IHRocm91Z2ggeW91ciB1c2Ugb2YgdGhlIHNvZnR3YXJlLlxiXHBhcgAAADUuIFx0YWJcZnMxOSBET0NVTUVOVEFUSU9OLlxiMCAgIEFueSBwZXJzb24gdGhhdCBoYXMgdmFsaWQgYWNjZXNzIHRvIHlvdXIgY29tcHV0ZXIgb3IgaW50ZXJuYWwgbmV0d29yayBtYXkgY29weSBhbmQgdXNlIHRoZSBkb2N1bWVudGF0aW9uIGZvciB5b3VyIGludGVybmFsLCByZWZlcmVuY2UgcHVycG9zZXMuXGJccGFyAAAAAAAAAAAAAFxjYXBzXGZzMjAgNi5cdGFiXGZzMTkgRXhwb3J0IFJlc3RyaWN0aW9uc1xjYXBzMCAuXGIwICAgVGhlIHNvZnR3YXJlIGlzIHN1YmplY3QgdG8gVW5pdGVkIFN0YXRlcyBleHBvcnQgbGF3cyBhbmQgcmVndWxhdGlvbnMuICBZb3UgbXVzdCBjb21wbHkgd2l0aCBhbGwgZG9tZXN0aWMgYW5kIGludGVybmF0aW9uYWwgZXhwb3J0IGxhd3MgYW5kIHJlZ3VsYXRpb25zIHRoYXQgYXBwbHkgdG8gdGhlIHNvZnR3YXJlLiAgVGhlc2UgbGF3cyBpbmNsdWRlIHJlc3RyaWN0aW9ucyBvbiBkZXN0aW5hdGlvbnMsIGVuZCB1c2VycyBhbmQgZW5kIHVzZS4gIEZvciBhZGRpdGlvbmFsIGluZm9ybWF0aW9uLCBzZWUge1xjZjFcdWx7XGZpZWxke1wqXGZsZGluc3R7SFlQRVJMSU5LIHd3dy5taWNyb3NvZnQuY29tL2V4cG9ydGluZyB9fXtcZmxkcnNsdHt3d3cubWljcm9zb2Z0LmNvbS9leHBvcnRpbmd9fX19XGNmMVx1bFxmMFxmczE5ICA8e3tcZmllbGR7XCpcZmxkaW5zdHtIWVBFUkxJTksgImh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9leHBvcnRpbmcifX17XGZsZHJzbHR7aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL2V4cG9ydGluZ319fX1cZjBcZnMxOSA+XGNmMFx1bG5vbmUgLlxiXHBhcgAAAAAAAAAAAAAAAFxjYXBzXGZzMjAgNy5cdGFiXGZzMTkgU1VQUE9SVCBTRVJWSUNFUy5cY2FwczAgIFxiMCBCZWNhdXNlIHRoaXMgc29mdHdhcmUgaXMgImFzIGlzLCAiIHdlIG1heSBub3QgcHJvdmlkZSBzdXBwb3J0IHNlcnZpY2VzIGZvciBpdC5cYlxwYXIAAAAAAAAAAFxjYXBzXGZzMjAgOC5cdGFiXGZzMTkgRW50aXJlIEFncmVlbWVudC5cYjBcY2FwczAgICBUaGlzIGFncmVlbWVudCwgYW5kIHRoZSB0ZXJtcyBmb3Igc3VwcGxlbWVudHMsIHVwZGF0ZXMsIEludGVybmV0LWJhc2VkIHNlcnZpY2VzIGFuZCBzdXBwb3J0IHNlcnZpY2VzIHRoYXQgeW91IHVzZSwgYXJlIHRoZSBlbnRpcmUgYWdyZWVtZW50IGZvciB0aGUgc29mdHdhcmUgYW5kIHN1cHBvcnQgc2VydmljZXMuXHBhcgAAAAAAAFxwYXJkXGtlZXBuXGZpLTM2MFxsaTM2MFxzYjEyMFxzYTEyMFx0eDM2MFxjZjJcYlxjYXBzXGZzMjAgOS5cdGFiXGZzMTkgQXBwbGljYWJsZSBMYXdcY2FwczAgLlxwYXIAAAAAAAAAAAAAAAAAAABccGFyZFxmaS0zNjNcbGk3MjBcc2IxMjBcc2ExMjBcdHg3MjBcY2YwXGZzMjAgYS5cdGFiXGZzMTkgVW5pdGVkIFN0YXRlcy5cYjAgICBJZiB5b3UgYWNxdWlyZWQgdGhlIHNvZnR3YXJlIGluIHRoZSBVbml0ZWQgU3RhdGVzLCBXYXNoaW5ndG9uIHN0YXRlIGxhdyBnb3Zlcm5zIHRoZSBpbnRlcnByZXRhdGlvbiBvZiB0aGlzIGFncmVlbWVudCBhbmQgYXBwbGllcyB0byBjbGFpbXMgZm9yIGJyZWFjaCBvZiBpdCwgcmVnYXJkbGVzcyBvZiBjb25mbGljdCBvZiBsYXdzIHByaW5jaXBsZXMuICBUaGUgbGF3cyBvZiB0aGUgc3RhdGUgd2hlcmUgeW91IGxpdmUgZ292ZXJuIGFsbCBvdGhlciBjbGFpbXMsIGluY2x1ZGluZyBjbGFpbXMgdW5kZXIgc3RhdGUgY29uc3VtZXIgcHJvdGVjdGlvbiBsYXdzLCB1bmZhaXIgY29tcGV0aXRpb24gbGF3cywgYW5kIGluIHRvcnQuXGJccGFyAAAAAAAAAAAAXHBhcmRcZmktMzYzXGxpNzIwXHNiMTIwXHNhMTIwXGZzMjAgYi5cdGFiXGZzMTkgT3V0c2lkZSB0aGUgVW5pdGVkIFN0YXRlcy5cYjAgICBJZiB5b3UgYWNxdWlyZWQgdGhlIHNvZnR3YXJlIGluIGFueSBvdGhlciBjb3VudHJ5LCB0aGUgbGF3cyBvZiB0aGF0IGNvdW50cnkgYXBwbHkuXGJccGFyAAAAAAAAAABccGFyZFxmaS0zNTdcbGkzNTdcc2IxMjBcc2ExMjBcdHgzNjBcY2Fwc1xmczIwIDEwLlx0YWJcZnMxOSBMZWdhbCBFZmZlY3QuXGIwXGNhcHMwICAgVGhpcyBhZ3JlZW1lbnQgZGVzY3JpYmVzIGNlcnRhaW4gbGVnYWwgcmlnaHRzLiAgWW91IG1heSBoYXZlIG90aGVyIHJpZ2h0cyB1bmRlciB0aGUgbGF3cyBvZiB5b3VyIGNvdW50cnkuICBZb3UgbWF5IGFsc28gaGF2ZSByaWdodHMgd2l0aCByZXNwZWN0IHRvIHRoZSBwYXJ0eSBmcm9tIHdob20geW91IGFjcXVpcmVkIHRoZSBzb2Z0d2FyZS4gIFRoaXMgYWdyZWVtZW50IGRvZXMgbm90IGNoYW5nZSB5b3VyIHJpZ2h0cyB1bmRlciB0aGUgbGF3cyBvZiB5b3VyIGNvdW50cnkgaWYgdGhlIGxhd3Mgb2YgeW91ciBjb3VudHJ5IGRvIG5vdCBwZXJtaXQgaXQgdG8gZG8gc28uXGJcY2Fwc1xwYXIAAAAAAAAAAAAAAABcZnMyMCAxMS5cdGFiXGZzMTkgRGlzY2xhaW1lciBvZiBXYXJyYW50eS5cY2FwczAgICAgXGNhcHMgVGhlIHNvZnR3YXJlIGlzIGxpY2Vuc2VkICJhcyAtIGlzLiIgIFlvdSBiZWFyIHRoZSByaXNrIG9mIHVzaW5nIGl0LiAgU1lTSU5URVJOQUxTIGdpdmVzIG5vIGV4cHJlc3Mgd2FycmFudGllcywgZ3VhcmFudGVlcyBvciBjb25kaXRpb25zLiAgWW91IG1heSBoYXZlIGFkZGl0aW9uYWwgY29uc3VtZXIgcmlnaHRzIHVuZGVyIHlvdXIgbG9jYWwgbGF3cyB3aGljaCB0aGlzIGFncmVlbWVudCBjYW5ub3QgY2hhbmdlLiAgVG8gdGhlIGV4dGVudCBwZXJtaXR0ZWQgdW5kZXIgeW91ciBsb2NhbCBsYXdzLCBTWVNJTlRFUk5BTFMgZXhjbHVkZXMgdGhlIGltcGxpZWQgd2FycmFudGllcyBvZiBtZXJjaGFudGFiaWxpdHksIGZpdG5lc3MgZm9yIGEgcGFydGljdWxhciBwdXJwb3NlIGFuZCBub24taW5mcmluZ2VtZW50LlxwYXIAAAAAAAAAAAAAAAAAAABccGFyZFxmaS0zNjBcbGkzNjBcc2IxMjBcc2ExMjBcdHgzNjBcZnMyMCAxMi5cdGFiXGZzMTkgTGltaXRhdGlvbiBvbiBhbmQgRXhjbHVzaW9uIG9mIFJlbWVkaWVzIGFuZCBEYW1hZ2VzLiAgWW91IGNhbiByZWNvdmVyIGZyb20gU1lTSU5URVJOQUxTIGFuZCBpdHMgc3VwcGxpZXJzIG9ubHkgZGlyZWN0IGRhbWFnZXMgdXAgdG8gVS5TLiAkNS4wMC4gIFlvdSBjYW5ub3QgcmVjb3ZlciBhbnkgb3RoZXIgZGFtYWdlcywgaW5jbHVkaW5nIGNvbnNlcXVlbnRpYWwsIGxvc3QgcHJvZml0cywgc3BlY2lhbCwgaW5kaXJlY3Qgb3IgaW5jaWRlbnRhbCBkYW1hZ2VzLlxwYXIAAAAAAAAAAAAAAAAAAABccGFyZFxsaTM1N1xzYjEyMFxzYTEyMFxiMFxjYXBzMCBUaGlzIGxpbWl0YXRpb24gYXBwbGllcyB0b1xwYXIAXHBhcmRcZmktMzYzXGxpNzIwXHNiMTIwXHNhMTIwXHR4NzIwXCdiN1x0YWIgYW55dGhpbmcgcmVsYXRlZCB0byB0aGUgc29mdHdhcmUsIHNlcnZpY2VzLCBjb250ZW50IChpbmNsdWRpbmcgY29kZSkgb24gdGhpcmQgcGFydHkgSW50ZXJuZXQgc2l0ZXMsIG9yIHRoaXJkIHBhcnR5IHByb2dyYW1zOyBhbmRccGFyAAAAAAAAAAAAAAAAAAAAXHBhcmRcZmktMzYzXGxpNzIwXHNiMTIwXHNhMTIwXCdiN1x0YWIgY2xhaW1zIGZvciBicmVhY2ggb2YgY29udHJhY3QsIGJyZWFjaCBvZiB3YXJyYW50eSwgZ3VhcmFudGVlIG9yIGNvbmRpdGlvbiwgc3RyaWN0IGxpYWJpbGl0eSwgbmVnbGlnZW5jZSwgb3Igb3RoZXIgdG9ydCB0byB0aGUgZXh0ZW50IHBlcm1pdHRlZCBieSBhcHBsaWNhYmxlIGxhdy5ccGFyAAAAAFxwYXJkXGxpMzYwXHNiMTIwXHNhMTIwIEl0IGFsc28gYXBwbGllcyBldmVuIGlmIFN5c2ludGVybmFscyBrbmV3IG9yIHNob3VsZCBoYXZlIGtub3duIGFib3V0IHRoZSBwb3NzaWJpbGl0eSBvZiB0aGUgZGFtYWdlcy4gIFRoZSBhYm92ZSBsaW1pdGF0aW9uIG9yIGV4Y2x1c2lvbiBtYXkgbm90IGFwcGx5IHRvIHlvdSBiZWNhdXNlIHlvdXIgY291bnRyeSBtYXkgbm90IGFsbG93IHRoZSBleGNsdXNpb24gb3IgbGltaXRhdGlvbiBvZiBpbmNpZGVudGFsLCBjb25zZXF1ZW50aWFsIG9yIG90aGVyIGRhbWFnZXMuXHBhcgAAAAAAAAAAAABccGFyZFxiIFBsZWFzZSBub3RlOiBBcyB0aGlzIHNvZnR3YXJlIGlzIGRpc3RyaWJ1dGVkIGluIFF1ZWJlYywgQ2FuYWRhLCBzb21lIG9mIHRoZSBjbGF1c2VzIGluIHRoaXMgYWdyZWVtZW50IGFyZSBwcm92aWRlZCBiZWxvdyBpbiBGcmVuY2guXHBhcgBccGFyZFxzYjI0MFxsYW5nMTAzNiBSZW1hcnF1ZSA6IENlIGxvZ2ljaWVsIFwnZTl0YW50IGRpc3RyaWJ1XCdlOSBhdSBRdVwnZTliZWMsIENhbmFkYSwgY2VydGFpbmVzIGRlcyBjbGF1c2VzIGRhbnMgY2UgY29udHJhdCBzb250IGZvdXJuaWVzIGNpLWRlc3NvdXMgZW4gZnJhblwnZTdhaXMuXHBhcgAAAAAAAFxwYXJkXHNiMTIwXHNhMTIwIEVYT05cJ2M5UkFUSU9OIERFIEdBUkFOVElFLlxiMCAgTGUgbG9naWNpZWwgdmlzXCdlOSBwYXIgdW5lIGxpY2VuY2UgZXN0IG9mZmVydCBcJ2FiIHRlbCBxdWVsIFwnYmIuIFRvdXRlIHV0aWxpc2F0aW9uIGRlIGNlIGxvZ2ljaWVsIGVzdCBcJ2UwIHZvdHJlIHNldWxlIHJpc3F1ZSBldCBwXCdlOXJpbC4gU3lzaW50ZXJuYWxzIG4nYWNjb3JkZSBhdWN1bmUgYXV0cmUgZ2FyYW50aWUgZXhwcmVzc2UuIFZvdXMgcG91dmV6IGJcJ2U5blwnZTlmaWNpZXIgZGUgZHJvaXRzIGFkZGl0aW9ubmVscyBlbiB2ZXJ0dSBkdSBkcm9pdCBsb2NhbCBzdXIgbGEgcHJvdGVjdGlvbiBkdWVzIGNvbnNvbW1hdGV1cnMsIHF1ZSBjZSBjb250cmF0IG5lIHBldXQgbW9kaWZpZXIuIExhIG91IGVsbGVzIHNvbnQgcGVybWlzZXMgcGFyIGxlIGRyb2l0IGxvY2FsZSwgbGVzIGdhcmFudGllcyBpbXBsaWNpdGVzIGRlIHF1YWxpdFwnZTkgbWFyY2hhbmRlLCBkJ2FkXCdlOXF1YXRpb24gXCdlMCB1biB1c2FnZSBwYXJ0aWN1bGllciBldCBkJ2Fic2VuY2UgZGUgY29udHJlZmFcJ2U3b24gc29udCBleGNsdWVzLlxwYXIAAAAAAAAAAAAAAABccGFyZFxrZWVwblxzYjEyMFxzYTEyMFxiIExJTUlUQVRJT04gREVTIERPTU1BR0VTLUlOVFwnYzlSXCdjYVRTIEVUIEVYQ0xVU0lPTiBERSBSRVNQT05TQUJJTElUXCdjOSBQT1VSIExFUyBET01NQUdFUy5cYjAgICBWb3VzIHBvdXZleiBvYnRlbmlyIGRlIFN5c2ludGVybmFscyBldCBkZSBzZXMgZm91cm5pc3NldXJzIHVuZSBpbmRlbW5pc2F0aW9uIGVuIGNhcyBkZSBkb21tYWdlcyBkaXJlY3RzIHVuaXF1ZW1lbnQgXCdlMCBoYXV0ZXVyIGRlIDUsMDAgJCBVUy4gVm91cyBuZSBwb3V2ZXogcHJcJ2U5dGVuZHJlIFwnZTAgYXVjdW5lIGluZGVtbmlzYXRpb24gcG91ciBsZXMgYXV0cmVzIGRvbW1hZ2VzLCB5IGNvbXByaXMgbGVzIGRvbW1hZ2VzIHNwXCdlOWNpYXV4LCBpbmRpcmVjdHMgb3UgYWNjZXNzb2lyZXMgZXQgcGVydGVzIGRlIGJcJ2U5blwnZTlmaWNlcy5ccGFyAFxsYW5nMTAzMyBDZXR0ZSBsaW1pdGF0aW9uIGNvbmNlcm5lIDpccGFyAAAAAAAAAAAAAAAAAAAAXHBhcmRca2VlcG5cZmktMzYwXGxpNzIwXHNiMTIwXHNhMTIwXHR4NzIwXGxhbmcxMDM2XCdiN1x0YWIgdG91dCAgY2UgcXVpIGVzdCByZWxpXCdlOSBhdSBsb2dpY2llbCwgYXV4IHNlcnZpY2VzIG91IGF1IGNvbnRlbnUgKHkgY29tcHJpcyBsZSBjb2RlKSBmaWd1cmFudCBzdXIgZGVzIHNpdGVzIEludGVybmV0IHRpZXJzIG91IGRhbnMgZGVzIHByb2dyYW1tZXMgdGllcnMgOyBldFxwYXIAAABccGFyZFxmaS0zNjNcbGk3MjBcc2IxMjBcc2ExMjBcdHg3MjBcJ2I3XHRhYiBsZXMgclwnZTljbGFtYXRpb25zIGF1IHRpdHJlIGRlIHZpb2xhdGlvbiBkZSBjb250cmF0IG91IGRlIGdhcmFudGllLCBvdSBhdSB0aXRyZSBkZSByZXNwb25zYWJpbGl0XCdlOSBzdHJpY3RlLCBkZSBuXCdlOWdsaWdlbmNlIG91IGQndW5lIGF1dHJlIGZhdXRlIGRhbnMgbGEgbGltaXRlIGF1dG9yaXNcJ2U5ZSBwYXIgbGEgbG9pIGVuIHZpZ3VldXIuXHBhcgAAAAAAAAAAXHBhcmRcc2IxMjBcc2ExMjAgRWxsZSBzJ2FwcGxpcXVlIFwnZTlnYWxlbWVudCwgbVwnZWFtZSBzaSBTeXNpbnRlcm5hbHMgY29ubmFpc3NhaXQgb3UgZGV2cmFpdCBjb25uYVwnZWV0cmUgbCdcJ2U5dmVudHVhbGl0XCdlOSBkJ3VuIHRlbCBkb21tYWdlLiAgU2kgdm90cmUgcGF5cyBuJ2F1dG9yaXNlIHBhcyBsJ2V4Y2x1c2lvbiBvdSBsYSBsaW1pdGF0aW9uIGRlIHJlc3BvbnNhYmlsaXRcJ2U5IHBvdXIgbGVzIGRvbW1hZ2VzIGluZGlyZWN0cywgYWNjZXNzb2lyZXMgb3UgZGUgcXVlbHF1ZSBuYXR1cmUgcXVlIGNlIHNvaXQsIGlsIHNlIHBldXQgcXVlIGxhIGxpbWl0YXRpb24gb3UgbCdleGNsdXNpb24gY2ktZGVzc3VzIG5lIHMnYXBwbGlxdWVyYSBwYXMgXCdlMCB2b3RyZSBcJ2U5Z2FyZC5ccGFyAFxiIEVGRkVUIEpVUklESVFVRS5cYjAgICBMZSBwclwnZTlzZW50IGNvbnRyYXQgZFwnZTljcml0IGNlcnRhaW5zIGRyb2l0cyBqdXJpZGlxdWVzLiBWb3VzIHBvdXJyaWV6IGF2b2lyIGQnYXV0cmVzIGRyb2l0cyBwclwnZTl2dXMgcGFyIGxlcyBsb2lzIGRlIHZvdHJlIHBheXMuICBMZSBwclwnZTlzZW50IGNvbnRyYXQgbmUgbW9kaWZpZSBwYXMgbGVzIGRyb2l0cyBxdWUgdm91cyBjb25mXCdlOHJlbnQgbGVzIGxvaXMgZGUgdm90cmUgcGF5cyBzaSBjZWxsZXMtY2kgbmUgbGUgcGVybWV0dGVudCBwYXMuXGJccGFyAAAAXHBhcmRcYjBcZnMyMFxsYW5nMTAzM1xwYXIAAAAAAABccGFyZFxzYTIwMFxzbDI3NlxzbG11bHQxXGYxXGZzMjJcbGFuZzlccGFyAH0AAAAAAAAAAAAAAFMAWQBTAEkATgBUAEUAUgBOAEEATABTACAAUwBPAEYAVABXAEEAUgBFACAATABJAEMARQBOAFMARQAgAFQARQBSAE0AUwAKAFQAaABlAHMAZQAgAGwAaQBjAGUAbgBzAGUAIAB0AGUAcgBtAHMAIABhAHIAZQAgAGEAbgAgAGEAZwByAGUAZQBtAGUAbgB0ACAAYgBlAHQAdwBlAGUAbgAgAFMAeQBzAGkAbgB0AGUAcgBuAGEAbABzACgAYQAgAHcAaABvAGwAbAB5ACAAbwB3AG4AZQBkACAAcwB1AGIAcwBpAGQAaQBhAHIAeQAgAG8AZgAgAE0AaQBjAHIAbwBzAG8AZgB0ACAAQwBvAHIAcABvAHIAYQB0AGkAbwBuACkAIABhAG4AZAAgAHkAbwB1AC4AUABsAGUAYQBzAGUAIAByAGUAYQBkACAAdABoAGUAbQAuAFQAaABlAHkAIABhAHAAcABsAHkAIAB0AG8AIAB0AGgAZQAgAHMAbwBmAHQAdwBhAHIAZQAgAHkAbwB1ACAAYQByAGUAIABkAG8AdwBuAGwAbwBhAGQAaQBuAGcAIABmAHIAbwBtACAAdABlAGMAaABuAGUAdAAuAG0AaQBjAHIAbwBzAG8AZgB0AC4AYwBvAG0AIAAvACAAcwB5AHMAaQBuAHQAZQByAG4AYQBsAHMALAAgAHcAaABpAGMAaAAgAGkAbgBjAGwAdQBkAGUAcwAgAHQAaABlACAAbQBlAGQAaQBhACAAbwBuACAAdwBoAGkAYwBoACAAeQBvAHUAIAByAGUAYwBlAGkAdgBlAGQAIABpAHQALAAgAGkAZgAgAGEAbgB5AC4AVABoAGUAIAB0AGUAcgBtAHMAIABhAGwAcwBvACAAYQBwAHAAbAB5ACAAdABvACAAYQBuAHkAIABTAHkAcwBpAG4AdABlAHIAbgBhAGwAcwAKACoAIAB1AHAAZABhAHQAZQBzACwACgAqAHMAdQBwAHAAbABlAG0AZQBuAHQAcwAsAAoAKgBJAG4AdABlAHIAbgBlAHQAIAAtACAAYgBhAHMAZQBkACAAcwBlAHIAdgBpAGMAZQBzACwACgAqAGEAbgBkACAAcwB1AHAAcABvAHIAdAAgAHMAZQByAHYAaQBjAGUAcwAKAGYAbwByACAAdABoAGkAcwAgAHMAbwBmAHQAdwBhAHIAZQAsACAAdQBuAGwAZQBzAHMAIABvAHQAaABlAHIAIAB0AGUAcgBtAHMAIABhAGMAYwBvAG0AcABhAG4AeQAgAHQAaABvAHMAZQAgAGkAdABlAG0AcwAuAEkAZgAgAHMAbwAsACAAdABoAG8AcwBlACAAdABlAHIAbQBzACAAYQBwAHAAbAB5AC4ACgBCAFkAIABVAFMASQBOAEcAIABUAEgARQAgAFMATwBGAFQAVwBBAFIARQAsACAAWQBPAFUAIABBAEMAQwBFAFAAVAAgAFQASABFAFMARQAgAFQARQBSAE0AUwAuAEkARgAgAFkATwBVACAARABPACAATgBPAFQAIABBAEMAQwBFAFAAVAAgAFQASABFAE0ALAAgAEQATwAgAE4ATwBUACAAVQBTAEUAIABUAEgARQAgAFMATwBGAFQAVwBBAFIARQAuAAoACgBJAGYAIAB5AG8AdQAgAGMAbwBtAHAAbAB5ACAAdwBpAHQAaAAgAHQAaABlAHMAZQAgAGwAaQBjAGUAbgBzAGUAIAB0AGUAcgBtAHMALAAgAHkAbwB1ACAAaABhAHYAZQAgAHQAaABlACAAcgBpAGcAaAB0AHMAIABiAGUAbABvAHcALgAKAEkATgBTAFQAQQBMAEwAQQBUAEkATwBOACAAQQBOAEQAIABVAFMARQBSACAAUgBJAEcASABUAFMACgBZAG8AdQAgAG0AYQB5ACAAaQBuAHMAdABhAGwAbAAgAGEAbgBkACAAdQBzAGUAIABhAG4AeQAgAG4AdQBtAGIAZQByACAAbwBmACAAYwBvAHAAaQBlAHMAIABvAGYAIAB0AGgAZQAgAHMAbwBmAHQAdwBhAHIAZQAgAG8AbgAgAHkAbwB1AHIAIABkAGUAdgBpAGMAZQBzAC4ACgAKAFMAQwBPAFAARQAgAE8ARgAgAEwASQBDAEUATgBTAEUACgBUAGgAZQAgAHMAbwBmAHQAdwBhAHIAZQAgAGkAcwAgAGwAaQBjAGUAbgBzAGUAZAAsACAAbgBvAHQAIABzAG8AbABkAC4AVABoAGkAcwAgAGEAZwByAGUAZQBtAGUAbgB0ACAAbwBuAGwAeQAgAGcAaQB2AGUAcwAgAHkAbwB1ACAAcwBvAG0AZQAgAHIAaQBnAGgAdABzACAAdABvACAAdQBzAGUAIAB0AGgAZQAgAHMAbwBmAHQAdwBhAHIAZQAuAFMAeQBzAGkAbgB0AGUAcgBuAGEAbABzACAAcgBlAHMAZQByAHYAZQBzACAAYQBsAGwAIABvAHQAaABlAHIAIAByAGkAZwBoAHQAcwAuAFUAbgBsAGUAcwBzACAAYQBwAHAAbABpAGMAYQBiAGwAZQAgAGwAYQB3ACAAZwBpAHYAZQBzACAAeQBvAHUAIABtAG8AcgBlACAAcgBpAGcAaAB0AHMAIABkAGUAcwBwAGkAdABlACAAdABoAGkAcwAgAGwAaQBtAGkAdABhAHQAaQBvAG4ALAAgAHkAbwB1ACAAbQBhAHkAIAB1AHMAZQAgAHQAaABlACAAcwBvAGYAdAB3AGEAcgBlACAAbwBuAGwAeQAgAGEAcwAgAGUAeABwAHIAZQBzAHMAbAB5ACAAcABlAHIAbQBpAHQAdABlAGQAIABpAG4AIAB0AGgAaQBzACAAYQBnAHIAZQBlAG0AZQBuAHQALgBJAG4AIABkAG8AaQBuAGcAIABzAG8ALAAgAHkAbwB1ACAAbQB1AHMAdAAgAGMAbwBtAHAAbAB5ACAAdwBpAHQAaAAgAGEAbgB5ACAAdABlAGMAaABuAGkAYwBhAGwAIABsAGkAbQBpAHQAYQB0AGkAbwBuAHMAIABpAG4AIAB0AGgAZQAgAHMAbwBmAHQAdwBhAHIAZQAgAHQAaABhAHQAIABvAG4AbAB5ACAAYQBsAGwAbwB3ACAAeQBvAHUAIAB0AG8AIAB1AHMAZQAgAGkAdAAgAGkAbgAgAGMAZQByAHQAYQBpAG4AIAB3AGEAeQBzAC4AWQBvAHUAIABtAGEAeQAgAG4AbwB0AAoAKgAgAHcAbwByAGsAIABhAHIAbwB1AG4AZAAgAGEAbgB5ACAAdABlAGMAaABuAGkAYwBhAGwAIABsAGkAbQBpAHQAYQB0AGkAbwBuAHMAIABpAG4AIAB0AGgAZQAgAHMAbwBmAHQAdwBhAHIAZQA7AAoAKgByAGUAdgBlAHIAcwBlACAAZQBuAGcAaQBuAGUAZQByACwAIABkAGUAYwBvAG0AcABpAGwAZQAgAG8AcgAgAGQAaQBzAGEAcwBzAGUAbQBiAGwAZQAgAHQAaABlACAAcwBvAGYAdAB3AGEAcgBlACwAIABlAHgAYwBlAHAAdAAgAGEAbgBkACAAbwBuAGwAeQAgAHQAbwAgAHQAaABlACAAZQB4AHQAZQBuAHQAIAB0AGgAYQB0ACAAYQBwAHAAbABpAGMAYQBiAGwAZQAgAGwAYQB3ACAAZQB4AHAAcgBlAHMAcwBsAHkAIABwAGUAcgBtAGkAdABzACwAIABkAGUAcwBwAGkAdABlACAAdABoAGkAcwAgAGwAaQBtAGkAdABhAHQAaQBvAG4AOwAKACoAbQBhAGsAZQAgAG0AbwByAGUAIABjAG8AcABpAGUAcwAgAG8AZgAgAHQAaABlACAAcwBvAGYAdAB3AGEAcgBlACAAdABoAGEAbgAgAHMAcABlAGMAaQBmAGkAZQBkACAAaQBuACAAdABoAGkAcwAgAGEAZwByAGUAZQBtAGUAbgB0ACAAbwByACAAYQBsAGwAbwB3AGUAZAAgAGIAeQAgAGEAcABwAGwAaQBjAGEAYgBsAGUAIABsAGEAdwAsACAAZABlAHMAcABpAHQAZQAgAHQAaABpAHMAIABsAGkAbQBpAHQAYQB0AGkAbwBuADsACgAqAHAAdQBiAGwAaQBzAGgAIAB0AGgAZQAgAHMAbwBmAHQAdwBhAHIAZQAgAGYAbwByACAAbwB0AGgAZQByAHMAIAB0AG8AIABjAG8AcAB5ADsACgAqAHIAZQBuAHQALAAgAGwAZQBhAHMAZQAgAG8AcgAgAGwAZQBuAGQAIAB0AGgAZQAgAHMAbwBmAHQAdwBhAHIAZQA7AAoAKgB0AHIAYQBuAHMAZgBlAHIAIAB0AGgAZQAgAHMAbwBmAHQAdwBhAHIAZQAgAG8AcgAgAHQAaABpAHMAIABhAGcAcgBlAGUAbQBlAG4AdAAgAHQAbwAgAGEAbgB5ACAAdABoAGkAcgBkACAAcABhAHIAdAB5ADsAIABvAHIACgAqACAAdQBzAGUAIAB0AGgAZQAgAHMAbwBmAHQAdwBhAHIAZQAgAGYAbwByACAAYwBvAG0AbQBlAHIAYwBpAGEAbAAgAHMAbwBmAHQAdwBhAHIAZQAgAGgAbwBzAHQAaQBuAGcAIABzAGUAcgB2AGkAYwBlAHMALgAKAAoAUwBFAE4AUwBJAFQASQBWAEUAIABJAE4ARgBPAFIATQBBAFQASQBPAE4ACgBQAGwAZQBhAHMAZQAgAGIAZQAgAGEAdwBhAHIAZQAgAHQAaABhAHQALAAgAHMAaQBtAGkAbABhAHIAIAB0AG8AIABvAHQAaABlAHIAIABkAGUAYgB1AGcAIAB0AG8AbwBsAHMAIAB0AGgAYQB0ACAAYwBhAHAAdAB1AHIAZQAgABwgcAByAG8AYwBlAHMAcwAgAHMAdABhAHQAZQAdICAAaQBuAGYAbwByAG0AYQB0AGkAbwBuACwAIABmAGkAbABlAHMAIABzAGEAdgBlAGQAIABiAHkAIABTAHkAcwBpAG4AdABlAHIAbgBhAGwAcwAgAHQAbwBvAGwAcwAgAG0AYQB5ACAAaQBuAGMAbAB1AGQAZQAgAHAAZQByAHMAbwBuAGEAbABsAHkAIABpAGQAZQBuAHQAaQBmAGkAYQBiAGwAZQAgAG8AcgAgAG8AdABoAGUAcgAgAHMAZQBuAHMAaQB0AGkAdgBlACAAaQBuAGYAbwByAG0AYQB0AGkAbwBuACgAcwB1AGMAaAAgAGEAcwAgAHUAcwBlAHIAbgBhAG0AZQBzACwAIABwAGEAcwBzAHcAbwByAGQAcwAsACAAcABhAHQAaABzACAAdABvACAAZgBpAGwAZQBzACAAYQBjAGMAZQBzAHMAZQBkACwAIABhAG4AZAAgAHAAYQB0AGgAcwAgAHQAbwAgAHIAZQBnAGkAcwB0AHIAeQAgAGEAYwBjAGUAcwBzAGUAZAApAC4AQgB5ACAAdQBzAGkAbgBnACAAdABoAGkAcwAgAHMAbwBmAHQAdwBhAHIAZQAsACAAeQBvAHUAIABhAGMAawBuAG8AdwBsAGUAZABnAGUAIAB0AGgAYQB0ACAAeQBvAHUAIABhAHIAZQAgAGEAdwBhAHIAZQAgAG8AZgAgAHQAaABpAHMAIABhAG4AZAAgAHQAYQBrAGUAIABzAG8AbABlACAAcgBlAHMAcABvAG4AcwBpAGIAaQBsAGkAdAB5ACAAZgBvAHIAIABhAG4AeQAgAHAAZQByAHMAbwBuAGEAbABsAHkAIABpAGQAZQBuAHQAaQBmAGkAYQBiAGwAZQAgAG8AcgAgAG8AdABoAGUAcgAgAHMAZQBuAHMAaQB0AGkAdgBlACAAaQBuAGYAbwByAG0AYQB0AGkAbwBuACAAcAByAG8AdgBpAGQAZQBkACAAdABvACAATQBpAGMAcgBvAHMAbwBmAHQAIABvAHIAIABhAG4AeQAgAG8AdABoAGUAcgAgAHAAYQByAHQAeQAgAHQAaAByAG8AdQBnAGgAIAB5AG8AdQByACAAdQBzAGUAIABvAGYAIAB0AGgAZQAgAHMAbwBmAHQAdwBhAHIAZQAuAAoACgBEAE8AQwBVAE0ARQBOAFQAQQBUAEkATwBOAAoAQQBuAHkAIABwAGUAcgBzAG8AbgAgAHQAaABhAHQAIABoAGEAcwAgAHYAYQBsAGkAZAAgAGEAYwBjAGUAcwBzACAAdABvACAAeQBvAHUAcgAgAGMAbwBtAHAAdQB0AGUAcgAgAG8AcgAgAGkAbgB0AGUAcgBuAGEAbAAgAG4AZQB0AHcAbwByAGsAIABtAGEAeQAgAGMAbwBwAHkAIABhAG4AZAAgAHUAcwBlACAAdABoAGUAIABkAG8AYwB1AG0AZQBuAHQAYQB0AGkAbwBuACAAZgBvAHIAIAB5AG8AdQByACAAaQBuAHQAZQByAG4AYQBsACwAIAByAGUAZgBlAHIAZQBuAGMAZQAgAHAAdQByAHAAbwBzAGUAcwAuAAoACgBFAFgAUABPAFIAVAAgAFIARQBTAFQAUgBJAEMAVABJAE8ATgBTAAoAVABoAGUAIABzAG8AZgB0AHcAYQByAGUAIABpAHMAIABzAHUAYgBqAGUAYwB0ACAAdABvACAAVQBuAGkAdABlAGQAIABTAHQAYQB0AGUAcwAgAGUAeABwAG8AcgB0ACAAbABhAHcAcwAgAGEAbgBkACAAcgBlAGcAdQBsAGEAdABpAG8AbgBzAC4AWQBvAHUAIABtAHUAcwB0ACAAYwBvAG0AcABsAHkAIAB3AGkAdABoACAAYQBsAGwAIABkAG8AbQBlAHMAdABpAGMAIABhAG4AZAAgAGkAbgB0AGUAcgBuAGEAdABpAG8AbgBhAGwAIABlAHgAcABvAHIAdAAgAGwAYQB3AHMAIABhAG4AZAAgAHIAZQBnAHUAbABhAHQAaQBvAG4AcwAgAHQAaABhAHQAIABhAHAAcABsAHkAIAB0AG8AIAB0AGgAZQAgAHMAbwBmAHQAdwBhAHIAZQAuAFQAaABlAHMAZQAgAGwAYQB3AHMAIABpAG4AYwBsAHUAZABlACAAcgBlAHMAdAByAGkAYwB0AGkAbwBuAHMAIABvAG4AIABkAGUAcwB0AGkAbgBhAHQAaQBvAG4AcwAsACAAZQBuAGQAIAB1AHMAZQByAHMAIABhAG4AZAAgAGUAbgBkACAAdQBzAGUALgBGAG8AcgAgAGEAZABkAGkAdABpAG8AbgBhAGwAIABpAG4AZgBvAHIAbQBhAHQAaQBvAG4ALAAgAHMAZQBlACAAdwB3AHcALgBtAGkAYwByAG8AcwBvAGYAdAAuAGMAbwBtACAALwAgAGUAeABwAG8AcgB0AGkAbgBnACAALgAKAAoAUwBVAFAAUABPAFIAVAAgAFMARQBSAFYASQBDAEUAUwAKAEIAZQBjAGEAdQBzAGUAIAB0AGgAaQBzACAAcwBvAGYAdAB3AGEAcgBlACAAaQBzACAAIgBhAHMAIABpAHMALAAgACIAIAB3AGUAIABtAGEAeQAgAG4AbwB0ACAAcAByAG8AdgBpAGQAZQAgAHMAdQBwAHAAbwByAHQAIABzAGUAcgB2AGkAYwBlAHMAIABmAG8AcgAgAGkAdAAuAAoACgBFAE4AVABJAFIARQAgAEEARwBSAEUARQBNAEUATgBUAAoAVABoAGkAcwAgAGEAZwByAGUAZQBtAGUAbgB0ACwAIABhAG4AZAAgAHQAaABlACAAdABlAHIAbQBzACAAZgBvAHIAIABzAHUAcABwAGwAZQBtAGUAbgB0AHMALAAgAHUAcABkAGEAdABlAHMALAAgAEkAbgB0AGUAcgBuAGUAdAAgAC0AIABiAGEAcwBlAGQAIABzAGUAcgB2AGkAYwBlAHMAIABhAG4AZAAgAHMAdQBwAHAAbwByAHQAIABzAGUAcgB2AGkAYwBlAHMAIAB0AGgAYQB0ACAAeQBvAHUAIAB1AHMAZQAsACAAYQByAGUAIAB0AGgAZQAgAGUAbgB0AGkAcgBlACAAYQBnAHIAZQBlAG0AZQBuAHQAIABmAG8AcgAgAHQAaABlACAAcwBvAGYAdAB3AGEAcgBlACAAYQBuAGQAIABzAHUAcABwAG8AcgB0ACAAcwBlAHIAdgBpAGMAZQBzAC4ACgAKAEEAUABQAEwASQBDAEEAQgBMAEUAIABMAEEAVwAKAFUAbgBpAHQAZQBkACAAUwB0AGEAdABlAHMALgBJAGYAIAB5AG8AdQAgAGEAYwBxAHUAaQByAGUAZAAgAHQAaABlACAAcwBvAGYAdAB3AGEAcgBlACAAaQBuACAAdABoAGUAIABVAG4AaQB0AGUAZAAgAFMAdABhAHQAZQBzACwAIABXAGEAcwBoAGkAbgBnAHQAbwBuACAAcwB0AGEAdABlACAAbABhAHcAIABnAG8AdgBlAHIAbgBzACAAdABoAGUAIABpAG4AdABlAHIAcAByAGUAdABhAHQAaQBvAG4AIABvAGYAIAB0AGgAaQBzACAAYQBnAHIAZQBlAG0AZQBuAHQAIABhAG4AZAAgAGEAcABwAGwAaQBlAHMAIAB0AG8AIABjAGwAYQBpAG0AcwAgAGYAbwByACAAYgByAGUAYQBjAGgAIABvAGYAIABpAHQALAAgAHIAZQBnAGEAcgBkAGwAZQBzAHMAIABvAGYAIABjAG8AbgBmAGwAaQBjAHQAIABvAGYAIABsAGEAdwBzACAAcAByAGkAbgBjAGkAcABsAGUAcwAuAFQAaABlACAAbABhAHcAcwAgAG8AZgAgAHQAaABlACAAcwB0AGEAdABlACAAdwBoAGUAcgBlACAAeQBvAHUAIABsAGkAdgBlACAAZwBvAHYAZQByAG4AIABhAGwAbAAgAG8AdABoAGUAcgAgAGMAbABhAGkAbQBzACwAIABpAG4AYwBsAHUAZABpAG4AZwAgAGMAbABhAGkAbQBzACAAdQBuAGQAZQByACAAcwB0AGEAdABlACAAYwBvAG4AcwB1AG0AZQByACAAcAByAG8AdABlAGMAdABpAG8AbgAgAGwAYQB3AHMALAAgAHUAbgBmAGEAaQByACAAYwBvAG0AcABlAHQAaQB0AGkAbwBuACAAbABhAHcAcwAsACAAYQBuAGQAIABpAG4AIAB0AG8AcgB0AC4ACgBPAHUAdABzAGkAZABlACAAdABoAGUAIABVAG4AaQB0AGUAZAAgAFMAdABhAHQAZQBzAC4ASQBmACAAeQBvAHUAIABhAGMAcQB1AGkAcgBlAGQAIAB0AGgAZQAgAHMAbwBmAHQAdwBhAHIAZQAgAGkAbgAgAGEAbgB5ACAAbwB0AGgAZQByACAAYwBvAHUAbgB0AHIAeQAsACAAdABoAGUAIABsAGEAdwBzACAAbwBmACAAdABoAGEAdAAgAGMAbwB1AG4AdAByAHkAIABhAHAAcABsAHkALgAKAAoATABFAEcAQQBMACAARQBGAEYARQBDAFQACgBUAGgAaQBzACAAYQBnAHIAZQBlAG0AZQBuAHQAIABkAGUAcwBjAHIAaQBiAGUAcwAgAGMAZQByAHQAYQBpAG4AIABsAGUAZwBhAGwAIAByAGkAZwBoAHQAcwAuAFkAbwB1ACAAbQBhAHkAIABoAGEAdgBlACAAbwB0AGgAZQByACAAcgBpAGcAaAB0AHMAIAB1AG4AZABlAHIAIAB0AGgAZQAgAGwAYQB3AHMAIABvAGYAIAB5AG8AdQByACAAYwBvAHUAbgB0AHIAeQAuAFkAbwB1ACAAbQBhAHkAIABhAGwAcwBvACAAaABhAHYAZQAgAHIAaQBnAGgAdABzACAAdwBpAHQAaAAgAHIAZQBzAHAAZQBjAHQAIAB0AG8AIAB0AGgAZQAgAHAAYQByAHQAeQAgAGYAcgBvAG0AIAB3AGgAbwBtACAAeQBvAHUAIABhAGMAcQB1AGkAcgBlAGQAIAB0AGgAZQAgAHMAbwBmAHQAdwBhAHIAZQAuAFQAaABpAHMAIABhAGcAcgBlAGUAbQBlAG4AdAAgAGQAbwBlAHMAIABuAG8AdAAgAGMAaABhAG4AZwBlACAAeQBvAHUAcgAgAHIAaQBnAGgAdABzACAAdQBuAGQAZQByACAAdABoAGUAIABsAGEAdwBzACAAbwBmACAAeQBvAHUAcgAgAGMAbwB1AG4AdAByAHkAIABpAGYAIAB0AGgAZQAgAGwAYQB3AHMAIABvAGYAIAB5AG8AdQByACAAYwBvAHUAbgB0AHIAeQAgAGQAbwAgAG4AbwB0ACAAcABlAHIAbQBpAHQAIABpAHQAIAB0AG8AIABkAG8AIABzAG8ALgAKAAoARABJAFMAQwBMAEEASQBNAEUAUgAgAE8ARgAgAFcAQQBSAFIAQQBOAFQAWQAKAFQAaABlACAAcwBvAGYAdAB3AGEAcgBlACAAaQBzACAAbABpAGMAZQBuAHMAZQBkACAAIgBhAHMAIAAtACAAaQBzAC4AIgAgAFkAbwB1ACAAYgBlAGEAcgAgAHQAaABlACAAcgBpAHMAawAgAG8AZgAgAHUAcwBpAG4AZwAgAGkAdAAuAFMAeQBzAGkAbgB0AGUAcgBuAGEAbABzACAAZwBpAHYAZQBzACAAbgBvACAAZQB4AHAAcgBlAHMAcwAgAHcAYQByAHIAYQBuAHQAaQBlAHMALAAgAGcAdQBhAHIAYQBuAHQAZQBlAHMAIABvAHIAIABjAG8AbgBkAGkAdABpAG8AbgBzAC4AWQBvAHUAIABtAGEAeQAgAGgAYQB2AGUAIABhAGQAZABpAHQAaQBvAG4AYQBsACAAYwBvAG4AcwB1AG0AZQByACAAcgBpAGcAaAB0AHMAIAB1AG4AZABlAHIAIAB5AG8AdQByACAAbABvAGMAYQBsACAAbABhAHcAcwAgAHcAaABpAGMAaAAgAHQAaABpAHMAIABhAGcAcgBlAGUAbQBlAG4AdAAgAGMAYQBuAG4AbwB0ACAAYwBoAGEAbgBnAGUALgBUAG8AIAB0AGgAZQAgAGUAeAB0AGUAbgB0ACAAcABlAHIAbQBpAHQAdABlAGQAIAB1AG4AZABlAHIAIAB5AG8AdQByACAAbABvAGMAYQBsACAAbABhAHcAcwAsACAAcwB5AHMAaQBuAHQAZQByAG4AYQBsAHMAIABlAHgAYwBsAHUAZABlAHMAIAB0AGgAZQAgAGkAbQBwAGwAaQBlAGQAIAB3AGEAcgByAGEAbgB0AGkAZQBzACAAbwBmACAAbQBlAHIAYwBoAGEAbgB0AGEAYgBpAGwAaQB0AHkALAAgAGYAaQB0AG4AZQBzAHMAIABmAG8AcgAgAGEAIABwAGEAcgB0AGkAYwB1AGwAYQByACAAcAB1AHIAcABvAHMAZQAgAGEAbgBkACAAbgBvAG4AIAAtACAAaQBuAGYAcgBpAG4AZwBlAG0AZQBuAHQALgAKAAoATABJAE0ASQBUAEEAVABJAE8ATgAgAE8ATgAgAEEATgBEACAARQBYAEMATABVAFMASQBPAE4AIABPAEYAIABSAEUATQBFAEQASQBFAFMAIABBAE4ARAAgAEQAQQBNAEEARwBFAFMACgBZAG8AdQAgAGMAYQBuACAAcgBlAGMAbwB2AGUAcgAgAGYAcgBvAG0AIABzAHkAcwBpAG4AdABlAHIAbgBhAGwAcwAgAGEAbgBkACAAaQB0AHMAIABzAHUAcABwAGwAaQBlAHIAcwAgAG8AbgBsAHkAIABkAGkAcgBlAGMAdAAgAGQAYQBtAGEAZwBlAHMAIAB1AHAAIAB0AG8AIABVAC4AUwAuACQANQAuADAAMAAuAFkAbwB1ACAAYwBhAG4AbgBvAHQAIAByAGUAYwBvAHYAZQByACAAYQBuAHkAIABvAHQAaABlAHIAIABkAGEAbQBhAGcAZQBzACwAIABpAG4AYwBsAHUAZABpAG4AZwAgAGMAbwBuAHMAZQBxAHUAZQBuAHQAaQBhAGwALAAgAGwAbwBzAHQAIABwAHIAbwBmAGkAdABzACwAIABzAHAAZQBjAGkAYQBsACwAIABpAG4AZABpAHIAZQBjAHQAIABvAHIAIABpAG4AYwBpAGQAZQBuAHQAYQBsACAAZABhAG0AYQBnAGUAcwAuAAoAVABoAGkAcwAgAGwAaQBtAGkAdABhAHQAaQBvAG4AIABhAHAAcABsAGkAZQBzACAAdABvAAoAKgAgAGEAbgB5AHQAaABpAG4AZwAgAHIAZQBsAGEAdABlAGQAIAB0AG8AIAB0AGgAZQAgAHMAbwBmAHQAdwBhAHIAZQAsACAAcwBlAHIAdgBpAGMAZQBzACwAIABjAG8AbgB0AGUAbgB0ACgAaQBuAGMAbAB1AGQAaQBuAGcAIABjAG8AZABlACkAIABvAG4AIAB0AGgAaQByAGQAIABwAGEAcgB0AHkAIABJAG4AdABlAHIAbgBlAHQAIABzAGkAdABlAHMALAAgAG8AcgAgAHQAaABpAHIAZAAgAHAAYQByAHQAeQAgAHAAcgBvAGcAcgBhAG0AcwA7ACAAYQBuAGQACgAqACAAYwBsAGEAaQBtAHMAIABmAG8AcgAgAGIAcgBlAGEAYwBoACAAbwBmACAAYwBvAG4AdAByAGEAYwB0ACwAIABiAHIAZQBhAGMAaAAgAG8AZgAgAHcAYQByAHIAYQBuAHQAeQAsACAAZwB1AGEAcgBhAG4AdABlAGUAIABvAHIAIABjAG8AbgBkAGkAdABpAG8AbgAsACAAcwB0AHIAaQBjAHQAIABsAGkAYQBiAGkAbABpAHQAeQAsACAAbgBlAGcAbABpAGcAZQBuAGMAZQAsACAAbwByACAAbwB0AGgAZQByACAAdABvAHIAdAAgAHQAbwAgAHQAaABlACAAZQB4AHQAZQBuAHQAIABwAGUAcgBtAGkAdAB0AGUAZAAgAGIAeQAgAGEAcABwAGwAaQBjAGEAYgBsAGUAIABsAGEAdwAuAAoASQB0ACAAYQBsAHMAbwAgAGEAcABwAGwAaQBlAHMAIABlAHYAZQBuACAAaQBmACAAUwB5AHMAaQBuAHQAZQByAG4AYQBsAHMAIABrAG4AZQB3ACAAbwByACAAcwBoAG8AdQBsAGQAIABoAGEAdgBlACAAawBuAG8AdwBuACAAYQBiAG8AdQB0ACAAdABoAGUAIABwAG8AcwBzAGkAYgBpAGwAaQB0AHkAIABvAGYAIAB0AGgAZQAgAGQAYQBtAGEAZwBlAHMALgBUAGgAZQAgAGEAYgBvAHYAZQAgAGwAaQBtAGkAdABhAHQAaQBvAG4AIABvAHIAIABlAHgAYwBsAHUAcwBpAG8AbgAgAG0AYQB5ACAAbgBvAHQAIABhAHAAcABsAHkAIAB0AG8AIAB5AG8AdQAgAGIAZQBjAGEAdQBzAGUAIAB5AG8AdQByACAAYwBvAHUAbgB0AHIAeQAgAG0AYQB5ACAAbgBvAHQAIABhAGwAbABvAHcAIAB0AGgAZQAgAGUAeABjAGwAdQBzAGkAbwBuACAAbwByACAAbABpAG0AaQB0AGEAdABpAG8AbgAgAG8AZgAgAGkAbgBjAGkAZABlAG4AdABhAGwALAAgAGMAbwBuAHMAZQBxAHUAZQBuAHQAaQBhAGwAIABvAHIAIABvAHQAaABlAHIAIABkAGEAbQBhAGcAZQBzAC4ACgBQAGwAZQBhAHMAZQAgAG4AbwB0AGUAIAA6ACAAQQBzACAAdABoAGkAcwAgAHMAbwBmAHQAdwBhAHIAZQAgAGkAcwAgAGQAaQBzAHQAcgBpAGIAdQB0AGUAZAAgAGkAbgAgAFEAdQBlAGIAZQBjACwAIABDAGEAbgBhAGQAYQAsACAAcwBvAG0AZQAgAG8AZgAgAHQAaABlACAAYwBsAGEAdQBzAGUAcwAgAGkAbgAgAHQAaABpAHMAIABhAGcAcgBlAGUAbQBlAG4AdAAgAGEAcgBlACAAcAByAG8AdgBpAGQAZQBkACAAYgBlAGwAbwB3ACAAaQBuACAARgByAGUAbgBjAGgALgAKAFIAZQBtAGEAcgBxAHUAZQAgADoAIABDAGUAIABsAG8AZwBpAGMAaQBlAGwAIADpAHQAYQBuAHQAIABkAGkAcwB0AHIAaQBiAHUA6QAgAGEAdQAgAFEAdQDpAGIAZQBjACwAIABDAGEAbgBhAGQAYQAsACAAYwBlAHIAdABhAGkAbgBlAHMAIABkAGUAcwAgAGMAbABhAHUAcwBlAHMAIABkAGEAbgBzACAAYwBlACAAYwBvAG4AdAByAGEAdAAgAHMAbwBuAHQAIABmAG8AdQByAG4AaQBlAHMAIABjAGkAIAAtACAAZABlAHMAcwBvAHUAcwAgAGUAbgAgAGYAcgBhAG4A5wBhAGkAcwAuAAoACQAJACAAIAAgAEUAWABPAE4AyQBSAEEAVABJAE8ATgAgAEQARQAgAEcAQQBSAEEATgBUAEkARQAuAEwAZQAgAGwAbwBnAGkAYwBpAGUAbAAgAHYAaQBzAOkAIABwAGEAcgAgAHUAbgBlACAAbABpAGMAZQBuAGMAZQAgAGUAcwB0ACAAbwBmAGYAZQByAHQAIACrACAAdABlAGwAIABxAHUAZQBsACAAuwAuAFQAbwB1AHQAZQAgAHUAdABpAGwAaQBzAGEAdABpAG8AbgAgAGQAZQAgAGMAZQAgAGwAbwBnAGkAYwBpAGUAbAAgAGUAcwB0ACAA4AAgAHYAbwB0AHIAZQAgAHMAZQB1AGwAZQAgAHIAaQBzAHEAdQBlACAAZQB0ACAAcADpAHIAaQBsAC4AUwB5AHMAaQBuAHQAZQByAG4AYQBsAHMAIABuACcAYQBjAGMAbwByAGQAZQAgAGEAdQBjAHUAbgBlACAAYQB1AHQAcgBlACAAZwBhAHIAYQBuAHQAaQBlACAAZQB4AHAAcgBlAHMAcwBlAC4AIABWAG8AdQBzACAAcABvAHUAdgBlAHoAIABiAOkAbgDpAGYAaQBjAGkAZQByACAAZABlACAAZAByAG8AaQB0AHMAIABhAGQAZABpAHQAaQBvAG4AbgBlAGwAcwAgAGUAbgAgAHYAZQByAHQAdQAgAGQAdQAgAGQAcgBvAGkAdAAgAGwAbwBjAGEAbAAgAHMAdQByACAAbABhACAAcAByAG8AdABlAGMAdABpAG8AbgAgAGQAdQBlAHMAIABjAG8AbgBzAG8AbQBtAGEAdABlAHUAcgBzACwAIABxAHUAZQAgAGMAZQAgAGMAbwBuAHQAcgBhAHQAIABuAGUAIABwAGUAdQB0ACAAbQBvAGQAaQBmAGkAZQByAC4AIABMAGEAIABvAHUAIABlAGwAbABlAHMAIABzAG8AbgB0ACAAcABlAHIAbQBpAHMAZQBzACAAcABhAHIAIABsAGUAIABkAHIAbwBpAHQAIABsAG8AYwBhAGwAZQAsACAAbABlAHMAIABnAGEAcgBhAG4AdABpAGUAcwAgAGkAbQBwAGwAaQBjAGkAdABlAHMAIABkAGUAIABxAHUAYQBsAGkAdADpACAAbQBhAHIAYwBoAGEAbgBkAGUALAAgAGQAJwBhAGQA6QBxAHUAYQB0AGkAbwBuACAA4AAgAHUAbgAgAHUAcwBhAGcAZQAgAHAAYQByAHQAaQBjAHUAbABpAGUAcgAgAGUAdAAgAGQAJwBhAGIAcwBlAG4AYwBlACAAZABlACAAYwBvAG4AdAByAGUAZgBhAOcAbwBuACAAcwBvAG4AdAAgAGUAeABjAGwAdQBlAHMALgAKAAkACQAgACAAIABMAEkATQBJAFQAQQBUAEkATwBOACAARABFAFMAIABEAE8ATQBNAEEARwBFAFMAIAAtACAASQBOAFQAyQBSAMoAVABTACAARQBUACAARQBYAEMATABVAFMASQBPAE4AIABEAEUAIABSAEUAUwBQAE8ATgBTAEEAQgBJAEwASQBUAMkAIABQAE8AVQBSACAATABFAFMAIABEAE8ATQBNAEEARwBFAFMALgBWAG8AdQBzACAAcABvAHUAdgBlAHoAIABvAGIAdABlAG4AaQByACAAZABlACAAUwB5AHMAaQBuAHQAZQByAG4AYQBsAHMAIABlAHQAIABkAGUAIABzAGUAcwAgAGYAbwB1AHIAbgBpAHMAcwBlAHUAcgBzACAAdQBuAGUAIABpAG4AZABlAG0AbgBpAHMAYQB0AGkAbwBuACAAZQBuACAAYwBhAHMAIABkAGUAIABkAG8AbQBtAGEAZwBlAHMAIABkAGkAcgBlAGMAdABzACAAdQBuAGkAcQB1AGUAbQBlAG4AdAAgAOAAIABoAGEAdQB0AGUAdQByACAAZABlACAANQAsACAAMAAwACAAJAAgAFUAUwAuAFYAbwB1AHMAIABuAGUAIABwAG8AdQB2AGUAegAgAHAAcgDpAHQAZQBuAGQAcgBlACAA4AAgAGEAdQBjAHUAbgBlACAAaQBuAGQAZQBtAG4AaQBzAGEAdABpAG8AbgAgAHAAbwB1AHIAIABsAGUAcwAgAGEAdQB0AHIAZQBzACAAZABvAG0AbQBhAGcAZQBzACwAIAB5ACAAYwBvAG0AcAByAGkAcwAgAGwAZQBzACAAZABvAG0AbQBhAGcAZQBzACAAcwBwAOkAYwBpAGEAdQB4ACwAIABpAG4AZABpAHIAZQBjAHQAcwAgAG8AdQAgAGEAYwBjAGUAcwBzAG8AaQByAGUAcwAgAGUAdAAgAHAAZQByAHQAZQBzACAAZABlACAAYgDpAG4A6QBmAGkAYwBlAHMALgAKAAoACQAJACAAIAAgAEMAZQB0AHQAZQAgAGwAaQBtAGkAdABhAHQAaQBvAG4AIABjAG8AbgBjAGUAcgBuAGUAIAA6AAoAdABvAHUAdAAgAGMAZQAgAHEAdQBpACAAZQBzAHQAIAByAGUAbABpAOkAIABhAHUAIABsAG8AZwBpAGMAaQBlAGwALAAgAGEAdQB4ACAAcwBlAHIAdgBpAGMAZQBzACAAbwB1ACAAYQB1ACAAYwBvAG4AdABlAG4AdQAoAHkAIABjAG8AbQBwAHIAaQBzACAAbABlACAAYwBvAGQAZQApACAAZgBpAGcAdQByAGEAbgB0ACAAcwB1AHIAIABkAGUAcwAgAHMAaQB0AGUAcwAgAEkAbgB0AGUAcgBuAGUAdAAgAHQAaQBlAHIAcwAgAG8AdQAgAGQAYQBuAHMAIABkAGUAcwAgAHAAcgBvAGcAcgBhAG0AbQBlAHMAIAB0AGkAZQByAHMAOwAgAGUAdAAKAGwAZQBzACAAcgDpAGMAbABhAG0AYQB0AGkAbwBuAHMAIABhAHUAIAB0AGkAdAByAGUAIABkAGUAIAB2AGkAbwBsAGEAdABpAG8AbgAgAGQAZQAgAGMAbwBuAHQAcgBhAHQAIABvAHUAIABkAGUAIABnAGEAcgBhAG4AdABpAGUALAAgAG8AdQAgAGEAdQAgAHQAaQB0AHIAZQAgAGQAZQAgAHIAZQBzAHAAbwBuAHMAYQBiAGkAbABpAHQA6QAgAHMAdAByAGkAYwB0AGUALAAgAGQAZQAgAG4A6QBnAGwAaQBnAGUAbgBjAGUAIABvAHUAIABkACcAdQBuAGUAIABhAHUAdAByAGUAIABmAGEAdQB0AGUAIABkAGEAbgBzACAAbABhACAAbABpAG0AaQB0AGUAIABhAHUAdABvAHIAaQBzAOkAZQAgAHAAYQByACAAbABhACAAbABvAGkAIABlAG4AIAB2AGkAZwB1AGUAdQByAC4ACgAKAEUAbABsAGUAIABzACcAYQBwAHAAbABpAHEAdQBlACAA6QBnAGEAbABlAG0AZQBuAHQALAAgAG0A6gBtAGUAIABzAGkAIABTAHkAcwBpAG4AdABlAHIAbgBhAGwAcwAgAGMAbwBuAG4AYQBpAHMAcwBhAGkAdAAgAG8AdQAgAGQAZQB2AHIAYQBpAHQAIABjAG8AbgBuAGEA7gB0AHIAZQAgAGwAJwDpAHYAZQBuAHQAdQBhAGwAaQB0AOkAIABkACcAdQBuACAAdABlAGwAIABkAG8AbQBtAGEAZwBlAC4AIABTAGkAIAB2AG8AdAByAGUAIABwAGEAeQBzACAAbgAnAGEAdQB0AG8AcgBpAHMAZQAgAHAAYQBzACAAbAAnAGUAeABjAGwAdQBzAGkAbwBuACAAbwB1ACAAbABhACAAbABpAG0AaQB0AGEAdABpAG8AbgAgAGQAZQAgAHIAZQBzAHAAbwBuAHMAYQBiAGkAbABpAHQA6QAgAHAAbwB1AHIAIABsAGUAcwAgAGQAbwBtAG0AYQBnAGUAcwAgAGkAbgBkAGkAcgBlAGMAdABzACwAIABhAGMAYwBlAHMAcwBvAGkAcgBlAHMAIABvAHUAIABkAGUAIABxAHUAZQBsAHEAdQBlACAAbgBhAHQAdQByAGUAIABxAHUAZQAgAGMAZQAgAHMAbwBpAHQALAAgAGkAbAAgAHMAZQAgAHAAZQB1AHQAIABxAHUAZQAgAGwAYQAgAGwAaQBtAGkAdABhAHQAaQBvAG4AIABvAHUAIABsACcAZQB4AGMAbAB1AHMAaQBvAG4AIABjAGkAIAAtACAAZABlAHMAcwB1AHMAIABuAGUAIABzACcAYQBwAHAAbABpAHEAdQBlAHIAYQAgAHAAYQBzACAA4AAgAHYAbwB0AHIAZQAgAOkAZwBhAHIAZAAuAAoARQBGAEYARQBUACAASgBVAFIASQBEAEkAUQBVAEUALgBMAGUAIABwAHIA6QBzAGUAbgB0ACAAYwBvAG4AdAByAGEAdAAgAGQA6QBjAHIAaQB0ACAAYwBlAHIAdABhAGkAbgBzACAAZAByAG8AaQB0AHMAIABqAHUAcgBpAGQAaQBxAHUAZQBzAC4AVgBvAHUAcwAgAHAAbwB1AHIAcgBpAGUAegAgAGEAdgBvAGkAcgAgAGQAJwBhAHUAdAByAGUAcwAgAGQAcgBvAGkAdABzACAAcAByAOkAdgB1AHMAIABwAGEAcgAgAGwAZQBzACAAbABvAGkAcwAgAGQAZQAgAHYAbwB0AHIAZQAgAHAAYQB5AHMALgAgAEwAZQAgAHAAcgDpAHMAZQBuAHQAIABjAG8AbgB0AHIAYQB0ACAAbgBlACAAbQBvAGQAaQBmAGkAZQAgAHAAYQBzACAAbABlAHMAIABkAHIAbwBpAHQAcwAgAHEAdQBlACAAdgBvAHUAcwAgAGMAbwBuAGYA6AByAGUAbgB0ACAAbABlAHMAIABsAG8AaQBzACAAZABlACAAdgBvAHQAcgBlACAAcABhAHkAcwAgAHMAaQAgAGMAZQBsAG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cICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8gISIjJCUmJygpKissLS4vMDEyMzQ1Njc4OTo7PD0+P0BBQkNERUZHSElKS0xNTk9QUVJTVFVWV1hZWltcXV5fYGFiY2RlZmdoaWprbG1ub3BxcnN0dXZ3eHl6e3x9fn8AawBlAHIAbgBlAGwAMwAyAC4AZABsAGwAAAAAAAAAAABGbHNBbGxvYwAAAAAAAAAARmxzRnJlZQBGbHNHZXRWYWx1ZQAAAAAARmxzU2V0VmFsdWUAAAAAAEluaXRpYWxpemVDcml0aWNhbFNlY3Rpb25FeAAAAAAAQ3JlYXRlRXZlbnRFeFcAAENyZWF0ZVNlbWFwaG9yZUV4VwAAAAAAAFNldFRocmVhZFN0YWNrR3VhcmFudGVlAENyZWF0ZVRocmVhZHBvb2xUaW1lcgAAAFNldFRocmVhZHBvb2xUaW1lcgAAAAAAAFdhaXRGb3JUaHJlYWRwb29sVGltZXJDYWxsYmFja3MAQ2xvc2VUaHJlYWRwb29sVGltZXIAAAAAQ3JlYXRlVGhyZWFkcG9vbFdhaXQAAAAAU2V0VGhyZWFkcG9vbFdhaXQAAAAAAAAAQ2xvc2VUaHJlYWRwb29sV2FpdAAAAAAARmx1c2hQcm9jZXNzV3JpdGVCdWZmZXJzAAAAAAAAAABGcmVlTGlicmFyeVdoZW5DYWxsYmFja1JldHVybnMAAEdldEN1cnJlbnRQcm9jZXNzb3JOdW1iZXIAAAAAAAAAR2V0TG9naWNhbFByb2Nlc3NvckluZm9ybWF0aW9uAABDcmVhdGVTeW1ib2xpY0xpbmtXAAAAAABTZXREZWZhdWx0RGxsRGlyZWN0b3JpZXMAAAAAAAAAAEVudW1TeXN0ZW1Mb2NhbGVzRXgAAAAAAENvbXBhcmVTdHJpbmdFeABHZXREYXRlRm9ybWF0RXgAR2V0TG9jYWxlSW5mb0V4AEdldFRpbWVGb3JtYXRFeABHZXRVc2VyRGVmYXVsdExvY2FsZU5hbWUAAAAAAAAAAElzVmFsaWRMb2NhbGVOYW1lAAAAAAAAAExDTWFwU3RyaW5nRXgAAABHZXRDdXJyZW50UGFja2FnZUlkAAAAAABHZXRUaWNrQ291bnQ2NAAAR2V0RmlsZUluZm9ybWF0aW9uQnlIYW5kbGVFeFcAAABTZXRGaWxlSW5mb3JtYXRpb25CeUhhbmRsZVcAAAAAAAAAAAAAAAAAAgAAAAAAAADQrwFAAQAAAAgAAAAAAAAAMLABQAEAAAAJAAAAAAAAAJCwAUABAAAACgAAAAAAAADwsAFAAQAAABAAAAAAAAAAQLEBQAEAAAARAAAAAAAAAKCxAUABAAAAEgAAAAAAAAAAsgFAAQAAABMAAAAAAAAAULIBQAEAAAAYAAAAAAAAALCyAUABAAAAGQAAAAAAAAAgswFAAQAAABoAAAAAAAAAcLMBQAEAAAAbAAAAAAAAAOCzAUABAAAAHAAAAAAAAABQtAFAAQAAAB4AAAAAAAAAoLQBQAEAAAAfAAAAAAAAAOC0AUABAAAAIAAAAAAAAACwtQFAAQAAACEAAAAAAAAAILYBQAEAAAAiAAAAAAAAABC4AUABAAAAeAAAAAAAAAB4uAFAAQAAAHkAAAAAAAAAmLgBQAEAAAB6AAAAAAAAALi4AUABAAAA/AAAAAAAAADUuAFAAQAAAP8AAAAAAAAA4LgBQAEAAABSADYAMAAwADIADQAKAC0AIABmAGwAbwBhAHQAaQBuAGcAIABwAG8AaQBuAHQAIABzAHUAcABwAG8AcgB0ACAAbgBvAHQAIABsAG8AYQBkAGUAZAANAAoAAAAAAAAAAABSADYAMAAwADgADQAKAC0AIABuAG8AdAAgAGUAbgBvAHUAZwBoACAAcwBwAGEAYwBlACAAZgBvAHIAIABhAHIAZwB1AG0AZQBuAHQAcwANAAoAAAAAAAAAAAAAAAAAAABSADYAMAAwADkADQAKAC0AIABuAG8AdAAgAGUAbgBvAHUAZwBoACAAcwBwAGEAYwBlACAAZgBvAHIAIABlAG4AdgBpAHIAbwBuAG0AZQBuAHQADQAKAAAAAAAAAAAAAABSADYAMAAxADAADQAKAC0AIABhAGIAbwByAHQAKAApACAAaABhAHMAIABiAGUAZQBuACAAYwBhAGwAbABlAGQADQAKAAAAAAAAAAAAAAAAAFIANgAwADEANgANAAoALQAgAG4AbwB0ACAAZQBuAG8AdQBnAGgAIABzAHAAYQBjAGUAIABmAG8AcgAgAHQAaAByAGUAYQBkACAAZABhAHQAYQANAAoAAAAAAAAAAAAAAFIANgAwADEANwANAAoALQAgAHUAbgBlAHgAcABlAGMAdABlAGQAIABtAHUAbAB0AGkAdABoAHIAZQBhAGQAIABsAG8AYwBrACAAZQByAHIAbwByAA0ACgAAAAAAAAAAAFIANgAwADEAOAANAAoALQAgAHUAbgBlAHgAcABlAGMAdABlAGQAIABoAGUAYQBwACAAZQByAHIAbwByAA0ACgAAAAAAAAAAAAAAAAAAAAAAUgA2ADAAMQA5AA0ACgAtACAAdQBuAGEAYgBsAGUAIAB0AG8AIABvAHAAZQBuACAAYwBvAG4AcwBvAGwAZQAgAGQAZQB2AGkAYwBlAA0ACgAAAAAAAAAAAAAAAAAAAAAAUgA2ADAAMgA0AA0ACgAtACAAbgBvAHQAIABlAG4AbwB1AGcAaAAgAHMAcABhAGMAZQAgAGYAbwByACAAXwBvAG4AZQB4AGkAdAAvAGEAdABlAHgAaQB0ACAAdABhAGIAbABlAA0ACgAAAAAAAAAAAFIANgAwADIANQANAAoALQAgAHAAdQByAGUAIAB2AGkAcgB0AHUAYQBsACAAZgB1AG4AYwB0AGkAbwBuACAAYwBhAGwAbAANAAoAAAAAAAAAUgA2ADAAMgA2AA0ACgAtACAAbgBvAHQAIABlAG4AbwB1AGcAaAAgAHMAcABhAGMAZQAgAGYAbwByACAAcwB0AGQAaQBvACAAaQBuAGkAdABpAGEAbABpAHoAYQB0AGkAbwBuAA0ACgAAAAAAAAAAAFIANgAwADIANwANAAoALQAgAG4AbwB0ACAAZQBuAG8AdQBnAGgAIABzAHAAYQBjAGUAIABmAG8AcgAgAGwAbwB3AGkAbwAgAGkAbgBpAHQAaQBhAGwAaQB6AGEAdABpAG8AbgANAAoAAAAAAAAAAABSADYAMAAyADgADQAKAC0AIAB1AG4AYQBiAGwAZQAgAHQAbwAgAGkAbgBpAHQAaQBhAGwAaQB6AGUAIABoAGUAYQBwAA0ACgAAAAAAAAAAAFIANgAwADMAMAANAAoALQAgAEMAUgBUACAAbgBvAHQAIABpAG4AaQB0AGkAYQBsAGkAegBlAGQADQAKAAAAAABSADYAMAAzADEADQAKAC0AIABBAHQAdABlAG0AcAB0ACAAdABvACAAaQBuAGkAdABpAGEAbABpAHoAZQAgAHQAaABlACAAQwBSAFQAIABtAG8AcgBlACAAdABoAGEAbgAgAG8AbgBjAGUALgAKAFQAaABpAHMAIABpAG4AZABpAGMAYQB0AGUAcwAgAGEAIABiAHUAZwAgAGkAbgAgAHkAbwB1AHIAIABhAHAAcABsAGkAYwBhAHQAaQBvAG4ALgANAAoAAAAAAAAAAAAAAAAAUgA2ADAAMwAyAA0ACgAtACAAbgBvAHQAIABlAG4AbwB1AGcAaAAgAHMAcABhAGMAZQAgAGYAbwByACAAbABvAGMAYQBsAGUAIABpAG4AZgBvAHIAbQBhAHQAaQBvAG4ADQAKAAAAAAAAAAAAAAAAAFIANgAwADMAMwANAAoALQAgAEEAdAB0AGUAbQBwAHQAIAB0AG8AIAB1AHMAZQAgAE0AUwBJAEwAIABjAG8AZABlACAAZgByAG8AbQAgAHQAaABpAHMAIABhAHMAcwBlAG0AYgBsAHkAIABkAHUAcgBpAG4AZwAgAG4AYQB0AGkAdgBlACAAYwBvAGQAZQAgAGkAbgBpAHQAaQBhAGwAaQB6AGEAdABpAG8AbgAKAFQAaABpAHMAIABpAG4AZABpAGMAYQB0AGUAcwAgAGEAIABiAHUAZwAgAGkAbgAgAHkAbwB1AHIAIABhAHAAcABsAGkAYwBhAHQAaQBvAG4ALgAgAEkAdAAgAGkAcwAgAG0AbwBzAHQAIABsAGkAawBlAGwAeQAgAHQAaABlACAAcgBlAHMAdQBsAHQAIABvAGYAIABjAGEAbABsAGkAbgBnACAAYQBuACAATQBTAEkATAAtAGMAbwBtAHAAaQBsAGUAZAAgACgALwBjAGwAcgApACAAZgB1AG4AYwB0AGkAbwBuACAAZgByAG8AbQAgAGEAIABuAGEAdABpAHYAZQAgAGMAbwBuAHMAdAByAHUAYwB0AG8AcgAgAG8AcgAgAGYAcgBvAG0AIABEAGwAbABNAGEAaQBuAC4ADQAKAAAAAABSADYAMAAzADQADQAKAC0AIABpAG4AYwBvAG4AcwBpAHMAdABlAG4AdAAgAG8AbgBlAHgAaQB0ACAAYgBlAGcAaQBuAC0AZQBuAGQAIAB2AGEAcgBpAGEAYgBsAGUAcwANAAoAAAAAAEQATwBNAEEASQBOACAAZQByAHIAbwByAA0ACgAAAAAAUwBJAE4ARwAgAGUAcgByAG8AcgANAAoAAAAAAAAAAABUAEwATwBTAFMAIABlAHIAcgBvAHIADQAKAAAADQAKAAAAAAAAAAAAcgB1AG4AdABpAG0AZQAgAGUAcgByAG8AcgAgAAAAAABSAHUAbgB0AGkAbQBlACAARQByAHIAbwByACEACgAKAFAAcgBvAGcAcgBhAG0AOgAgAAAAAAAAADwAcAByAG8AZwByAGEAbQAgAG4AYQBtAGUAIAB1AG4AawBuAG8AdwBuAD4AAAAAAC4ALgAuAAAACgAKAAAAAAAAAAAAAAAAAE0AaQBjAHIAbwBzAG8AZgB0ACAAVgBpAHMAdQBhAGwAIABDACsAKwAgAFIAdQBuAHQAaQBtAGUAIABMAGkAYgByAGEAcgB5AAAAAAAobnVsbCkAAAAAAAAoAG4AdQBsAGwAKQAAAAAAAAAAAAAAAAAGAAAGAAEAABAAAwYABgIQBEVFRQUFBQUFNTAAUAAAAAAoIDhQWAcIADcwMFdQBwAAICAIAAAAAAhgaGBgYGAAAHhweHh4eAgHCAAABwAICAgAAAgACAAHCAAAAAAAAABjAGMAcwAAAFUAVABGAC0AOAAAAAAAAABVAFQARgAtADEANgBMAEUAAAAAAAAAAABVAE4ASQBDAE8ARABFAAAABQAAwAsAAAAAAAAAAAAAAB0AAMAEAAAAAAAAAAAAAACWAADABAAAAAAAAAAAAAAAjQAAwAgAAAAAAAAAAAAAAI4AAMAIAAAAAAAAAAAAAACPAADACAAAAAAAAAAAAAAAkAAAwAgAAAAAAAAAAAAAAJEAAMAIAAAAAAAAAAAAAACSAADACAAAAAAAAAAAAAAAkwAAwAgAAAAAAAAAAAAAALQCAMAIAAAAAAAAAAAAAAC1AgDACAAAAAAAAAAAAAAADAAAAMAAAAADAAAACQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgACAAIAAgACAAIAAgACAAIAAoACgAKAAoACgAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAASAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEACEAIQAhACEAIQAhACEAIQAhACEABAAEAAQABAAEAAQABAAgQCBAIEAgQCBAIEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABABAAEAAQABAAEAAQAIIAggCCAIIAggCCAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgAQABAAEAAQACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAAgACAAIAAgACAAIAAgACAAKAAoACgAKAAoACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgAEgAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAhACEAIQAhACEAIQAhACEAIQAhAAQABAAEAAQABAAEAAQAIEBgQGBAYEBgQGBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEQABAAEAAQABAAEACCAYIBggGCAYIBggECAQIBAgECAQIBAgECAQIBAgECAQIBAgECAQIBAgECAQIBAgECAQIBEAAQABAAEAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAIABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQAB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Nvbm5lY3ROYW1lZFBpcGUAAEADTG9hZExpYnJhcnlFeFcAAI8AQ3JlYXRlRmlsZVcAaQNNdWx0aUJ5dGVUb1dpZGVDaGFyAMMDUmVhZEZpbGUAAMoBR2V0Q3VycmVudFRocmVhZAAAqgJHZXRWZXJzaW9uAADTAkhlYXBBbGxvYwDXAkhlYXBGcmVlAABRAkdldFByb2Nlc3NIZWFwAACLBFNldFByb2Nlc3NBZmZpbml0eU1hc2sAAM4EVGVybWluYXRlUHJvY2VzcwAA5gFHZXRFeGl0Q29kZVByb2Nlc3MAAKYEU2V0VGhyZWFkUHJpb3JpdHkAZgRTZXRFcnJvck1vZGUAABYEUmVzdW1lVGhyZWFkAAAGBVdhaXRGb3JNdWx0aXBsZU9iamVjdHMAAF0BRmx1c2hGaWxlQnVmZmVycwAAfQRTZXRIYW5kbGVJbmZvcm1hdGlvbgAAoQBDcmVhdGVQaXBlAADlAERpc2Nvbm5lY3ROYW1lZFBpcGUAYQVsc3RybGVuVwAAhQBDcmVhdGVFdmVudFcAAKAAQ3JlYXRlTmFtZWRQaXBlVwAAZAFGb3JtYXRNZXNzYWdlVwAAOwRTZXRDb25zb2xlQ3RybEhhbmRsZXIAS0VSTkVMMzIuZGxsAAAsAk9wZW5EZXNrdG9wVwAASgBDbG9zZURlc2t0b3AAADECT3BlbldpbmRvd1N0YXRpb25XAABOAENsb3NlV2luZG93U3RhdGlvbgAAsAJTZXRQcm9jZXNzV2luZG93U3RhdGlvbgBqAUdldFByb2Nlc3NXaW5kb3dTdGF0aW9uAMQCU2V0VXNlck9iamVjdFNlY3VyaXR5AI4BR2V0VXNlck9iamVjdFNlY3VyaXR5AFVTRVIzMi5kbGwAADACUmVnQ2xvc2VLZXkAZAJSZWdPcGVuS2V5VwBuAlJlZ1F1ZXJ5VmFsdWVFeFcAAFoBR2V0VG9rZW5JbmZvcm1hdGlvbgDCAlNldFRva2VuSW5mb3JtYXRpb24AIABBbGxvY2F0ZUFuZEluaXRpYWxpemVTaWQAACABRnJlZVNpZAA2AUdldExlbmd0aFNpZAAAdgFJbml0aWFsaXplQWNsABYAQWRkQWNlAAAjAUdldEFjZQAAEABBZGRBY2Nlc3NBbGxvd2VkQWNlAJcBTG9va3VwUHJpdmlsZWdlVmFsdWVXAE4BR2V0U2VjdXJpdHlJbmZvALsCU2V0U2VjdXJpdHlJbmZvAKsBTHNhRnJlZU1lbW9yeQCdAUxzYUNsb3NlAAC9AUxzYU9wZW5Qb2xpY3kApAFMc2FFbnVtZXJhdGVBY2NvdW50UmlnaHRzAJACUmV2ZXJ0VG9TZWxmAAD3AU9wZW5Qcm9jZXNzVG9rZW4AAB8AQWRqdXN0VG9rZW5Qcml2aWxlZ2VzAI0BTG9nb25Vc2VyVwAAVwBDbG9zZVNlcnZpY2VIYW5kbGUAAFwAQ29udHJvbFNlcnZpY2UAAIEAQ3JlYXRlU2VydmljZVcAANoARGVsZXRlU2VydmljZQD5AU9wZW5TQ01hbmFnZXJXAAD7AU9wZW5TZXJ2aWNlVwAAKAJRdWVyeVNlcnZpY2VTdGF0dXMAALEAQ3J5cHRBY3F1aXJlQ29udGV4dFcAAMsAQ3J5cHRSZWxlYXNlQ29udGV4dADAAENyeXB0R2VuS2V5ALUAQ3J5cHREZXJpdmVLZXkAALcAQ3J5cHREZXN0cm95S2V5AL8AQ3J5cHRFeHBvcnRLZXkAAMoAQ3J5cHRJbXBvcnRLZXkAALoAQ3J5cHRFbmNyeXB0AAC0AENyeXB0RGVjcnlwdAAAswBDcnlwdENyZWF0ZUhhc2gAyABDcnlwdEhhc2hEYXRhAHQBSW1wZXJzb25hdGVOYW1lZFBpcGVDbGllbnQAAPwBT3BlblRocmVhZFRva2VuAAcBRXF1YWxTaWQAAHYAQ29weVNpZAAkAUdldEFjbEluZm9ybWF0aW9uAHcBSW5pdGlhbGl6ZVNlY3VyaXR5RGVzY3JpcHRvcgAAtgJTZXRTZWN1cml0eURlc2NyaXB0b3JEYWNsAEgBR2V0U2VjdXJpdHlEZXNjcmlwdG9yRGFjbACRAUxvb2t1cEFjY291bnRTaWRXAI8BTG9va3VwQWNjb3VudE5hbWVXAAB8AENyZWF0ZVByb2Nlc3NBc1VzZXJXAADfAER1cGxpY2F0ZVRva2VuRXgAAKYCU2V0RW50cmllc0luQWNsVwAA2wBEZXJlZ2lzdGVyRXZlbnRTb3VyY2UAgwJSZWdpc3RlckV2ZW50U291cmNlVwAAjwJSZXBvcnRFdmVudFcAAIgCUmVnaXN0ZXJTZXJ2aWNlQ3RybEhhbmRsZXJXAMACU2V0U2VydmljZVN0YXR1cwAAyAJTdGFydFNlcnZpY2VDdHJsRGlzcGF0Y2hlclcAQURWQVBJMzIuZGxsAAAGAENvbW1hbmRMaW5lVG9Bcmd2VwAAU0hFTEwzMi5kbGwA7gBFbmNvZGVQb2ludGVyAMsARGVjb2RlUG9pbnRlcgAfAUV4aXRQcm9jZXNzAB0CR2V0TW9kdWxlSGFuZGxlRXhXAAAgBVdpZGVDaGFyVG9NdWx0aUJ5dGUAsgFHZXRDb25zb2xlTW9kZQAA8gBFbnRlckNyaXRpY2FsU2VjdGlvbgAAOwNMZWF2ZUNyaXRpY2FsU2VjdGlvbgAAlARTZXRTdGRIYW5kbGUAALQAQ3JlYXRlVGhyZWFkAADLAUdldEN1cnJlbnRUaHJlYWRJZAAAIAFFeGl0VGhyZWFkAAACA0lzRGVidWdnZXJQcmVzZW50AAYDSXNQcm9jZXNzb3JGZWF0dXJlUHJlc2VudADaAkhlYXBSZUFsbG9jACUEUnRsVW53aW5kRXgAjAFHZXRDb21tYW5kTGluZUEADANJc1ZhbGlkQ29kZVBhZ2UAbgFHZXRBQ1AAAD4CR2V0T0VNQ1AAAHgBR2V0Q1BJbmZvANIARGVsZXRlQ3JpdGljYWxTZWN0aW9uABgEUnRsQ2FwdHVyZUNvbnRleHQAHwRSdGxMb29rdXBGdW5jdGlvbkVudHJ5AAAmBFJ0bFZpcnR1YWxVbndpbmQAAOIEVW5oYW5kbGVkRXhjZXB0aW9uRmlsdGVyAACzBFNldFVuaGFuZGxlZEV4Y2VwdGlvbkZpbHRlcgDrAkluaXRpYWxpemVDcml0aWNhbFNlY3Rpb25BbmRTcGluQ291bnQA0wRUbHNBbGxvYwAA1QRUbHNHZXRWYWx1ZQDWBFRsc1NldFZhbHVlANQEVGxzRnJlZQBqAkdldFN0YXJ0dXBJbmZvVwCgAUdldENvbnNvbGVDUAAAGQJHZXRNb2R1bGVGaWxlTmFtZUEAAKkDUXVlcnlQZXJmb3JtYW5jZUNvdW50ZXIAxwFHZXRDdXJyZW50UHJvY2Vzc0lkAIACR2V0U3lzdGVtVGltZUFzRmlsZVRpbWUA4QFHZXRFbnZpcm9ubWVudFN0cmluZ3NXAABnAUZyZWVFbnZpcm9ubWVudFN0cmluZ3NXAHACR2V0U3RyaW5nVHlwZVcAAC8DTENNYXBTdHJpbmdXAACMA091dHB1dERlYnVnU3RyaW5nVwAA3AJIZWFwU2l6ZQAAdQRTZXRGaWxlUG9pbnRlckV4AAAzBVdyaXRlQ29uc29sZVcAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAwDUBQAEAAABANgFAAQAAAHg2AUABAAAAsDYBQAEAAAAgNwFAAQAAAHg4AUABAAAAuDgBQAEAAADwOAFAAQAAACA5AUABAAAAQDkBQAEAAACwOQFAAQAAACA6AUABAAAAoDoBQAEAAABQOwFAAQAAADA9AUABAAAAwD0BQAEAAACgPgFAAQAAACg/AUABAAAAYD8BQAEAAACQPwFAAQAAAOA/AUABAAAAMEABQAEAAACgQgFAAQAAAGBDAUABAAAA0EUBQAEAAABgRgFAAQAAAFBHAUABAAAAwEcBQAEAAACASQFAAQAAADBKAUABAAAA4EsBQAEAAADATQFAAQAAABBPAUABAAAAUE8BQAEAAAAQUAFAAQAAAOBQAUABAAAAEFIBQAEAAACgUgFAAQAAAFBTAUABAAAAoFUBQAEAAABYVwFAAQAAAJBXAUABAAAAcFgBQAEAAABwWQFAAQAAAABbAUABAAAAKFwBQAEAAABIXAFAAQAAAHRcAUABAAAAAAAAAAAAAACAXAFAAQAAAICWAUABAAAAqJYBQAEAAADYlgFAAQAAAACXAUABAAAAQJcBQAEAAAABAAAA/////zKi3y2ZKwAAzV0g0mbU//+ATwRAAQAAAAAAAAAAAAAAgE8EQAEAAAABAQAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAAACAgICAgICAgICAgICAgICAgICAgICAgICAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAYWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXoAAAAAAABBQkNERUZHSElKS0xNTk9QUVJTVFVWV1hZWgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAAACAgICAgICAgICAgICAgICAgICAgICAgICAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAYWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXoAAAAAAABBQkNERUZHSElKS0xNTk9QUVJTVFVWV1hZWgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAgQIAAAAAKQDAABggnmCIQAAAAAAAACm3wAAAAAAAKGlAAAAAAAAgZ/g/AAAAABAfoD8AAAAAKgDAADBo9qjIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgf4AAAAAAABA/gAAAAAAALUDAADBo9qjIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgf4AAAAAAABB/gAAAAAAALYDAADPouSiGgDlouiiWwAAAAAAAAAAAAAAAAAAAAAAgf4AAAAAAABAfqH+AAAAAFEFAABR2l7aIABf2mraMgAAAAAAAAAAAAAAAAAAAAAAgdPY3uD5AAAxfoH+AAAAAKAnAkABAAAA/////wAAAAABAAAAFgAAAAIAAAACAAAAAwAAAAIAAAAEAAAAGAAAAAUAAAANAAAABgAAAAkAAAAHAAAADAAAAAgAAAAMAAAACQAAAAwAAAAKAAAABwAAAAsAAAAIAAAADAAAABYAAAANAAAAFgAAAA8AAAACAAAAEAAAAA0AAAARAAAAEgAAABIAAAACAAAAIQAAAA0AAAA1AAAAAgAAAEEAAAANAAAAQwAAAAIAAABQAAAAEQAAAFIAAAANAAAAUwAAAA0AAABXAAAAFgAAAFkAAAALAAAAbAAAAA0AAABtAAAAIAAAAHAAAAAcAAAAcgAAAAkAAAAGAAAAFgAAAIAAAAAKAAAAgQAAAAoAAACCAAAACQAAAIMAAAAWAAAAhAAAAA0AAACRAAAAKQAAAJ4AAAANAAAAoQAAAAIAAACkAAAACwAAAKcAAAANAAAAtwAAABEAAADOAAAAAgAAANcAAAALAAAAGAcAAAwAAAAMAAAACAAAAAEAAABDAAAAAAAAAAAAAADspgFAAQAAAPCmAUABAAAA9KYBQAEAAAD4pgFAAQAAAPymAUABAAAAAKcBQAEAAAAEpwFAAQAAAAinAUABAAAAEKcBQAEAAAAYpwFAAQAAACCnAUABAAAAMKcBQAEAAAA8pwFAAQAAAEinAUABAAAAVKcBQAEAAABYpwFAAQAAAFynAUABAAAAYKcBQAEAAABkpwFAAQAAAGinAUABAAAAbKcBQAEAAABwpwFAAQAAAHSnAUABAAAAeKcBQAEAAAB8pwFAAQAAAICnAUABAAAAiKcBQAEAAACQpwFAAQAAAJynAUABAAAApKcBQAEAAABkpwFAAQAAAKynAUABAAAAtKcBQAEAAAC8pwFAAQAAAMinAUABAAAA2KcBQAEAAADgpwFAAQAAAPCnAUABAAAA/KcBQAEAAAAAqAFAAQAAAAioAUABAAAAGKgBQAEAAAAwqAFAAQAAAAEAAAAAAAAAQKgBQAEAAABIqAFAAQAAAFCoAUABAAAAWKgBQAEAAABgqAFAAQAAAGioAUABAAAAcKgBQAEAAAB4qAFAAQAAAIioAUABAAAAmKgBQAEAAACoqAFAAQAAAMCoAUABAAAA2KgBQAEAAADoqAFAAQAAAACpAUABAAAACKkBQAEAAAAQqQFAAQAAABipAUABAAAAIKkBQAEAAAAoqQFAAQAAADCpAUABAAAAOKkBQAEAAABAqQFAAQAAAEipAUABAAAAUKkBQAEAAABYqQFAAQAAAGCpAUABAAAAcKkBQAEAAACIqQFAAQAAAJipAUABAAAAIKkBQAEAAACoqQFAAQAAALipAUABAAAAyKkBQAEAAADYqQFAAQAAAPCpAUABAAAAAKoBQAEAAAAYqgFAAQAAACyqAUABAAAANKoBQAEAAABAqgFAAQAAAFiqAUABAAAAgKoBQAEAAACYqgFAAQAAACAvAkABAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEQsAkABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAARCwCQAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABELAJAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEQsAkABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAARCwCQAEAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACwMwJAAQAAAAAAAAAAAAAAAAAAAAAAAABgvAFAAQAAAPDAAUABAAAAcMIBQAEAAABQLAJAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP7///8AAAAAZL4BQAEAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA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inqKe4p8in2Kfop/inCKgYqCioOKhIqFioaKh4qIiomKioqLioyKjYqOio+KgIqRipKKk4qUipWKloqXipiKmYqaipuKnIqdip6Kn4qQiqGKooqjiqSKpYqmiqeKqIqpiqqKq4qsiq2KroqviqCKsYqyirOKtIq1iraKt4q4irmKuoq7iryKvYq+ir+KsIrBisKKw4rEisWKxorHisiKyYrKisuKzIrNis6Kz4rAitGK0orTitSK1YrWiteK2IrZitqK24rcit2K3orfitCK4YriiuOK5IrliuaK54roiumK6orriuyK7Yruiu+K4IrxivKK84r0ivWK9or3iviK+Yr6ivuK/Ir9iv6K/4rwDQAQAIAgAACKAYoCigOKBIoFigaKB4oIigmKCooLigyKDYoOig+KAIoRihKKE4oUihWKFooXihiKGYoaihuKHAodCh4KHwoQCiEKIgojCiQKJQomCicKKAopCioKKwosCi0KLgovCiAKMQoyCjMKNAo1CjYKNwo4CjkKOgo7CjwKPQo+Cj8KMApBCkIKQwpECkUKRgpHCkgKSQpKCksKTApNCk4KTwpAClEKUgpTClQKVQpWClcKWApZCloKWwpcCl0KXgpfClAKYQpiCmMKZAplCmYKZwpoCmkKagprCmwKbQpuCm8KYApxCnIKcwp0CnUKdgp3CngKeQp6CnsKfAp9Cn4KfwpwCoEKggqDCoQKhQqGCocKiAqJCooKiwqMCo0KjgqPCoAKkQqSCpMKlAqVCpYKlwqYCpkKmgqbCpwKnQqeCp8KkAqhCqIKowqkCqUKpgqnCqgKqQqqCqsKrAqtCq4KrwqgCrEKsgqzCrQKtQq2CrcKuAq5CroKuwq8Cr0Kvgq/CrAKwQrCCsMKxArFCsYKxwrICskKygrLCswKzQrOCs8KwArRCtIK0wrUCtUK1grXCtgK2QraCtsK3ArdCt4K3wrQCuEK4grjCuQK5QrmCucK6ArpCuoK6wrsCu0K7grvCuAK8QryCvMK9Ar1CvYK9wr4CvkK+gr7CvwK/Qr+Cv8K8A8AEADAAAAGCn+KcAIAIANAEAAACgCKAQoBigIKAooDCgOKBAoEigUKBYoGCgaKBwoHiggKCIoJCgmKCgoKigsKC4oMCgyKDQoNig4KDooPCg+KAAoQihEKEYoSChKKEwoTihQKFIoVChWKFgoW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AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACwAQAcAAAA4KXopfCl+KUAphimIKYopjCmAAAAQAIAFAAAACCpKKkwqTipQKlIqQBQAgA4AAAACKEYoSihOKFIoVihaKF4oYihmKGoobihyKHYoeih+KEIohiiKKI4okiiWKJoogAAAGACAEQBAAA4pkimWKZopnimiKaYpqimuKbIptim6Kb4pginGKcopzinSKdYp2ineKeIp5inqKe4p8in2Kfop/inCKgYqCioOKhIqFioaKh4qIiomKioqLioyKjYqOio+KgIqRipKKk4qUipWKloqXipiKmYqaipuKnIqdip6Kn4qQiqGKooqjiqSKpYqmiqeKqIqpiqqKq4qsiq2KroqviqCKsYqyirOKtIq1iraKt4q4irmKuoq7iryKvYq+ir+KsIrBisKKw4rEisWKxorHisiKyYrKisuKzIrNis6Kz4rAitGK0orTitSK1YrWiteK2IrZitqK24rcit2K3orfitCK4YriiuOK5IrliuaK54roiumK6orriuyK7Yruiu+K4IrxivKK84r0ivWK9or3iviK+Yr6ivuK/Ir9iv6K/4rwAAAHACAAgCAAAIoBigKKA4oEigWKBooHigiKCYoKiguKDIoNig6KD4oAihGKEooTihSKFYoWiheKGIoZihqKG4ocih2KHoofihCKIYoiiiOKJIoliiaKJ4ooiimKKooriiyKLYouii+KIIoxijKKM4o0ijWKNoo3ijiKOYo6ijuKPIo9ij6KP4owikGKQopDikSKRYpGikcKSApJCkoKSwpMCk0KTgpPCkAKUQpSClMKVApVClYKVwpYClkKWgpbClwKXQpeCl8KUAphCmIKYwpkCmUKZgpnCmgKaQpqCmsKbAptCm4KbwpgCnEKcgpzCnQKdQp2CncKeAp5CnoKewp8Cn0Kfgp/CnAKgQqCCoMKhAqFCoYKhwqICokKigqLCowKjQqOCo8KgAqRCpIKkwqUCpUKlgqXCpgKmQqaCpsKnAqdCp4KnwqQCqEKogqjCqQKpQqmCqcKqAqpCqoKqwqsCq0KrgqvCqAKsQqyCrMKtAq1CrYKtwq4CrkKugq7CrwKvQq+Cr8KsArB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"
$PSExec64Decoded = [System.Convert]::FromBase64String($PSExec64Base64)
if (!(Test-Path ("$PoShHome\PSExec64.exe"))) {
    Set-Content -Path "$PoShHome\PSExec64.exe" -Value $PSExec64Decoded -Encoding Byte
    $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - PSExec64.exe was Base64 decoded for use by PoSH-ACE ($PoShHome\PSExec64.exe)"
    $LogMessage | Add-Content -Path $LogFile
}

#Checks if the hash doesn't match, an 
$PSExec64MD5HashNew = $(Get-FileHash -Algorithm MD5 "$PoShHome\PSExec64.exe").Hash
if ($PSExec64MD5Hash -ne $PSExec64MD5HashNew) {
    $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - PSExec64.exe's hash doesn't match. $PSExec64MD5Hash (good) vs $PSExec64MD5HashNew (doesn't match). Replaced File $PoShHome\PSExec64.exe"
    $LogMessage | Add-Content -Path $LogFile
    Set-Content -Path "$PoShHome\PSExec64.exe" -Value $PSExec64Decoded -Encoding Byte
    $LogMessage = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) - PSExec64.exe was Base64 decoded for use by PoSH-ACE ($PoShHome\PSExec64.exe)"
    $LogMessage | Add-Content -Path $LogFile
}
