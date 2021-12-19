$Section1NetworkConnectionsSearchTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = "Network  "
    Left   = $FormScale * 3
    Top    = $FormScale * -10
    Width  = $FormScale * 450
    Height = $FormScale * 20
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
    ImageIndex = 5
}
$MainLeftSearchTabControl.Controls.Add($Section1NetworkConnectionsSearchTab)


$MainLeftNetworkTabControlImageList = New-Object System.Windows.Forms.ImageList -Property @{
    ImageSize = @{
        Width  = $FormScale * 16
        Height = $FormScale * 16
    }
}
# Index 0 = Live 
$MainLeftNetworkTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Live-Network.png"))
# Index 1 = Sysinternals
$MainLeftNetworkTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Sysinternals.png"))


$CollectionsNetworkTabControl = New-Object System.Windows.Forms.TabControl -Property @{
    Location = @{ X = $FormScale * 3
                  Y = $FormScale * 3 }
    Size     = @{ Width  = $FormScale * 446
                  Height = $FormScale * (557 + 5)}
    ShowToolTips  = $True
    SelectedIndex = 0
    ImageList     = $MainLeftNetworkTabControlImageList
    Appearance    = [System.Windows.Forms.TabAppearance]::Buttons
    Hottrack      = $true
    Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,2,1)
    Multiline = $true
}
$Section1NetworkConnectionsSearchTab.Controls.Add($CollectionsNetworkTabControl)





################################################################################################################
################################################################################################################
################################################################################################################
################################################################################################################
################################################################################################################





$Section1NetworkLiveSearchTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = "Active Connections  "
    Left   = $FormScale * 3
    Top    = $FormScale * -10
    Width  = $FormScale * 450
    Height = $FormScale * 20
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = 'Blue'
    UseVisualStyleBackColor = $True
    ImageIndex = 0
}
$CollectionsNetworkTabControl.Controls.Add($Section1NetworkLiveSearchTab)


$NetworkLiveSearchGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text   = "Collection Options"
    Left   = $FormScale * 3
    Top    = $FormScale * 5
    Width  = $FormScale * 435
    Height = $FormScale * 50
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
}

$NetworkLiveRegexCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Use Regular Expression. Note: The backslash is the escape character, ex: c:\\Windows\\System32"
    Left   = $FormScale * 7
    Top    = $FormScale * 18
    Width  = $FormScale * 280 #430
    Height = $FormScale * 25
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = "Black"
    Checked = $false
}
$NetworkLiveSearchGroupBox.Controls.Add($NetworkLiveRegexCheckbox)


$SupportsRegexButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Regex Examples"
    Left   = $NetworkLiveRegexCheckbox.Left + $NetworkLiveRegexCheckbox.Width + $($FormScale * 28)
    Top    = $NetworkLiveRegexCheckbox.Top
    Width  = $FormScale * 115
    Height = $FormScale * 20
    Add_Click = { Import-Csv "$Dependencies\Reference RegEx Examples.csv" | Out-GridView }
}
$NetworkLiveSearchGroupBox.Controls.Add($SupportsRegexButton)
Apply-CommonButtonSettings -Button $SupportsRegexButton
$Section1NetworkLiveSearchTab.Controls.Add($NetworkLiveSearchGroupBox)


$NetworkLiveSearchRemoteIPAddressCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Remote IP (WinRM)"
    Left   = $FormScale * 3
    Top    = $NetworkLiveSearchGroupBox.Top + $NetworkLiveSearchGroupBox.Height + $($FormScale * 10)
    Width  = $FormScale * 180
    Height = $FormScale * 20
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        Update-QueryCount
        
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1NetworkLiveSearchTab.Controls.Add($NetworkLiveSearchRemoteIPAddressCheckbox)


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\NetworkLiveSearchRemoteIPAddressSelectionButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\NetworkLiveSearchRemoteIPAddressSelectionButton.ps1"
$NetworkLiveSearchRemoteIPAddressSelectionButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Select IP Addresses"
    Left   = $NetworkLiveSearchRemoteIPAddressCheckbox.Left
    Top    = $NetworkLiveSearchRemoteIPAddressCheckbox.Top + $NetworkLiveSearchRemoteIPAddressCheckbox.Height + $($FormScale * 3)
    Width  = $FormScale * 180
    Height = $FormScale * 20
    Add_Click = $NetworkLiveSearchRemoteIPAddressSelectionButtonAdd_Click
}
$Section1NetworkLiveSearchTab.Controls.Add($NetworkLiveSearchRemoteIPAddressSelectionButton)
Apply-CommonButtonSettings -Button $NetworkLiveSearchRemoteIPAddressSelectionButton


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RichTextBox\NetworkLiveSearchRemoteIPAddressRichTextbox.ps1"
. "$Dependencies\Code\System.Windows.Forms\RichTextBox\NetworkLiveSearchRemoteIPAddressRichTextbox.ps1"
$NetworkLiveSearchRemoteIPAddressRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Lines  = "Enter Remote IPs; One Per Line"
    Left   = $NetworkLiveSearchRemoteIPAddressSelectionButton.Left
    Top    = $NetworkLiveSearchRemoteIPAddressSelectionButton.Top + $NetworkLiveSearchRemoteIPAddressSelectionButton.Height + $($FormScale * 5)
    Width  = $FormScale * 180
    Height = $FormScale * 115
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    MultiLine  = $True
    ScrollBars = "Vertical"
    WordWrap   = $True
    ShortcutsEnabled = $true
    Add_MouseEnter = {if ($this.text -eq "Enter Remote IPs; One Per Line"){$this.text = ""}}            
    Add_MouseLeave = {if ($this.text -eq "") {$this.text = "Enter Remote IPs; One Per Line"}}
    Add_MouseHover = {
        Show-ToolTip -Title "Remote IP Address" -Icon "Info" -Message @"
+  Check hosts for connections to one or more remote IP addresses
+  Enter Remote IPs
+  One Per Line
"@  
    }
}
$Section1NetworkLiveSearchTab.Controls.Add($NetworkLiveSearchRemoteIPAddressRichTextbox)


$NetworkLiveSearchRemotePortCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Remote Port"
    Left = $NetworkLiveSearchRemoteIPAddressCheckbox.Left + $NetworkLiveSearchRemoteIPAddressCheckbox.Width + $($FormScale * 10)
    Top = $NetworkLiveSearchRemoteIPAddressCheckbox.Top
    Width  = $FormScale * 115
    Height = $FormScale * 20
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = { 
        Update-QueryCount
        
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1NetworkLiveSearchTab.Controls.Add($NetworkLiveSearchRemotePortCheckbox)


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\NetworkLiveSearchRemotePortSelectionButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\NetworkLiveSearchRemotePortSelectionButton.ps1"
$NetworkLiveSearchRemotePortSelectionButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Select Ports"
    Left   = $NetworkLiveSearchRemotePortCheckbox.Left
    Top    = $NetworkLiveSearchRemotePortCheckbox.Top + $NetworkLiveSearchRemotePortCheckbox.Height + $($FormScale * 3)
    Width  = $FormScale * 115
    Height = $FormScale * 20
    Add_Click = $NetworkLiveSearchRemotePortSelectionButtonAdd_Click
}
$Section1NetworkLiveSearchTab.Controls.Add($NetworkLiveSearchRemotePortSelectionButton)
Apply-CommonButtonSettings -Button $NetworkLiveSearchRemotePortSelectionButton


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RichTextBox\NetworkLiveSearchRemotePortRichTextbox.ps1"
. "$Dependencies\Code\System.Windows.Forms\RichTextBox\NetworkLiveSearchRemotePortRichTextbox.ps1"
$NetworkLiveSearchRemotePortRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Lines  = "Enter Remote Ports; One Per Line"
    Left   = $NetworkLiveSearchRemotePortSelectionButton.Left
    Top    = $NetworkLiveSearchRemotePortSelectionButton.Top + $NetworkLiveSearchRemotePortSelectionButton.Height + $($FormScale * 5)
    Width  = $FormScale * 115
    Height = $FormScale * 115
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    MultiLine  = $True
    ScrollBars = "Vertical"
    WordWrap   = $True
    ShortcutsEnabled = $true
    Add_MouseEnter = {if ($this.text -eq "Enter Remote Ports; One Per Line") {$this.text = ""}}
    Add_MouseLeave = {if ($this.text -eq "") {$this.text = "Enter Remote Ports; One Per Line"}}
    Add_MouseHover = {
        Show-ToolTip -Title "Remote Port" -Icon "Info" -Message @"
+  Check hosts for connections to one or more remote ports
+  Enter Remote Ports
+  One Per Line
"@
    }            
}
$Section1NetworkLiveSearchTab.Controls.Add($NetworkLiveSearchRemotePortRichTextbox)


$NetworkLiveSearchLocalPortCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Local Port"
    Left   = $NetworkLiveSearchRemotePortCheckbox.Left + $NetworkLiveSearchRemotePortCheckbox.Width + $($FormScale * 10)
    Top    = $NetworkLiveSearchRemotePortCheckbox.Top
    Width  = $FormScale * 115
    Height = $FormScale * 20
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = { 
        Update-QueryCount
        
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1NetworkLiveSearchTab.Controls.Add($NetworkLiveSearchLocalPortCheckbox)


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\NetworkLiveSearchLocalPortSelectionButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\NetworkLiveSearchLocalPortSelectionButton.ps1"
$NetworkLiveSearchLocalPortSelectionButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Select Ports"
    Left   = $NetworkLiveSearchLocalPortCheckbox.Left
    Top    = $NetworkLiveSearchLocalPortCheckbox.Top + $NetworkLiveSearchLocalPortCheckbox.Height + $($FormScale * 3)
    Width  = $FormScale * 115
    Height = $FormScale * 20
    Add_Click = $NetworkLiveSearchLocalPortSelectionButtonAdd_Click
}
$Section1NetworkLiveSearchTab.Controls.Add($NetworkLiveSearchLocalPortSelectionButton)
Apply-CommonButtonSettings -Button $NetworkLiveSearchLocalPortSelectionButton


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RichTextBox\NetworkLiveSearchLocalPortRichTextbox.ps1"
. "$Dependencies\Code\System.Windows.Forms\RichTextBox\NetworkLiveSearchLocalPortRichTextbox.ps1"
$NetworkLiveSearchLocalPortRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Lines  = "Enter Local Ports; One Per Line"
    Left   = $NetworkLiveSearchLocalPortSelectionButton.Left
    Top    = $NetworkLiveSearchLocalPortSelectionButton.Top  + $NetworkLiveSearchLocalPortSelectionButton.Height + $($FormScale * 5)
    Width  = $FormScale * 115
    Height = $FormScale * 115
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    MultiLine  = $True
    ScrollBars = "Vertical"
    WordWrap   = $True
    #BorderStyle = 'Fixed3d' #Fixed3D, FixedSingle, none
    ShortcutsEnabled = $true
    Add_MouseEnter = {if ($this.text -eq "Enter Local Ports; One Per Line") {$this.text = ""}}
    Add_MouseLeave = {if ($this.text -eq "") {$this.text = "Enter Local Ports; One Per Line"}}
    Add_MouseHover = {
        Show-ToolTip -Title "Local Port" -Icon "Info" -Message @"
+  Check hosts for connections with the listed local port
+  Enter Local Ports
+  One Per Line
"@
    }
}
$Section1NetworkLiveSearchTab.Controls.Add($NetworkLiveSearchLocalPortRichTextbox)


$NetworkLiveSearchCommandLineCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Command Line (WinRM)"
    Left   = $FormScale * 3
    Top    = $NetworkLiveSearchRemoteIPAddressRichTextbox.Top + $NetworkLiveSearchRemoteIPAddressRichTextbox.Height + $($FormScale * 5)
    Width  = $FormScale * 210 #430
    Height = $FormScale * 20
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        Update-QueryCount
        
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1NetworkLiveSearchTab.Controls.Add($NetworkLiveSearchCommandLineCheckbox)


$NetworkLiveSearchCommandLineRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Lines  = "Enter Command; One Per Line"
    Left   = $FormScale * 3
    Top    = $NetworkLiveSearchCommandLineCheckbox.Top + $NetworkLiveSearchCommandLineCheckbox.Height + $($FormScale * 5)
    Width  = $FormScale * 210 #430
    Height = $FormScale * 100
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    MultiLine  = $True
    ScrollBars = "Vertical"
    WordWrap   = $True
    ShortcutsEnabled = $true
    Add_MouseEnter   = { if ($this.text -eq "Enter Command; One Per Line"){ $this.text = "" } }
    Add_MouseLeave   = { if ($this.text -eq "") { $this.text = "Enter Command; One Per Line" } }
}
$Section1NetworkLiveSearchTab.Controls.Add($NetworkLiveSearchCommandLineRichTextbox)


$NetworkLiveSearchExecutablePathCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Executable Path (WinRM)"
    Left   = $NetworkLiveSearchCommandLineRichTextbox.Left + $NetworkLiveSearchCommandLineRichTextbox.Width + $($FormScale * 10)
    Top    = $NetworkLiveSearchCommandLineCheckbox.Top
    Width  = $FormScale * 210 #430
    Height = $FormScale * 20
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        Update-QueryCount
        
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1NetworkLiveSearchTab.Controls.Add($NetworkLiveSearchExecutablePathCheckbox)


$NetworkLiveSearchExecutablePathTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Lines  = "Enter full paths; One Per Line"
    Left   = $NetworkLiveSearchExecutablePathCheckbox.Left
    Top    = $NetworkLiveSearchExecutablePathCheckbox.Top + $NetworkLiveSearchExecutablePathCheckbox.Height + $($FormScale * 5)
    Width  = $FormScale * 210 #430
    Height = $FormScale * 100
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    MultiLine  = $True
    ScrollBars = "Vertical"
    WordWrap   = $True
    ShortcutsEnabled = $true
    Add_MouseEnter   = { if ($this.text -eq "Enter full paths; One Per Line"){ $this.text = "" } }
    Add_MouseLeave   = { if ($this.text -eq "") { $this.text = "Enter full paths; One Per Line" } }
}
$Section1NetworkLiveSearchTab.Controls.Add($NetworkLiveSearchExecutablePathTextbox)


$NetworkLiveSearchProcessCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Process Name (WinRM)"
    Left   = $FormScale * 3
    Top    = $NetworkLiveSearchCommandLineRichTextbox.Top + $NetworkLiveSearchCommandLineRichTextbox.Height + $($FormScale * 5)
    Width  = $FormScale * 210 #430
    Height = $FormScale * 20
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        Update-QueryCount
        
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1NetworkLiveSearchTab.Controls.Add($NetworkLiveSearchProcessCheckbox)


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RichTextBox\NetworkLiveSearchProcessRichTextbox.ps1"
. "$Dependencies\Code\System.Windows.Forms\RichTextBox\NetworkLiveSearchProcessRichTextbox.ps1"
$NetworkLiveSearchProcessRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Lines  = "Enter Process Names; One Per Line"
    Left   = $FormScale * 3
    Top    = $NetworkLiveSearchProcessCheckbox.Top + $NetworkLiveSearchProcessCheckbox.Height + $($FormScale * 5)
    Width  = $FormScale * 210 #430
    Height = $FormScale * 100
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    MultiLine  = $True
    ScrollBars = "Vertical"
    WordWrap   = $True
    ShortcutsEnabled = $true
    Add_MouseHover = {if ($this.text -eq "Enter Process Names; One Per Line") {$this.text = ""}}
    Add_MouseEnter = {if ($this.text -eq "") {$this.text = "Enter Process Names; One Per Line"}}
    Add_MouseLeave = {
        Show-ToolTip -Title "Remote Process Name" -Icon "Info" -Message @"
+  Check hosts for connections created by a given process
+  This search will also find the keyword within the process name
+  Enter Remote Process Names
+  One Per Line
"@
    }                
}
$Section1NetworkLiveSearchTab.Controls.Add($NetworkLiveSearchProcessRichTextbox)


Update-FormProgress "$Dependencies\Code\Main Body\Get-DNSCache.ps1"
. "$Dependencies\Code\Main Body\Get-DNSCache.ps1"
$NetworkLiveSearchDNSCacheCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "DNS Cache Entry (WinRM)"
    Left   = $NetworkLiveSearchProcessRichTextbox.Left + $NetworkLiveSearchProcessRichTextbox.Width + $($FormScale * 10)
    Top    = $NetworkLiveSearchProcessCheckbox.Top
    Width  = $FormScale * 210 #430
    Height = $FormScale * 20
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        Update-QueryCount
        
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1NetworkLiveSearchTab.Controls.Add($NetworkLiveSearchDNSCacheCheckbox)


$NetworkLiveSearchDNSCacheRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Lines  = "Enter DNS query info or IP addresses; One Per Line"
    Left   = $NetworkLiveSearchDNSCacheCheckbox.Left
    Top    = $NetworkLiveSearchDNSCacheCheckbox.Top + $NetworkLiveSearchDNSCacheCheckbox.Height + $($FormScale * 5)
    Width  = $FormScale * 210 #430
    Height = $FormScale * 100
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    MultiLine  = $True
    ScrollBars = "Vertical"
    WordWrap   = $True
    ShortcutsEnabled = $true
    Add_MouseEnter = { if ($this.text -eq "Enter DNS query info or IP addresses; One Per Line") { $this.text = "" } }
    Add_MouseLeave = { if ($this.text -eq "") { $this.text = "Enter DNS query info or IP addresses; One Per Line" } }                
    Add_MouseHover = {
        Show-ToolTip -Title "Remote DNS Cache Entry" -Icon "Info" -Message @"
+  Check hosts' DNS Cache for entries that match given criteria
+  The DNS Cache is not persistence on systems
+  By default, Windows stores positive responses in the DNS Cache for 86,400 seconds (1 day)
+  By default, Windows stores negative responses in the DNS Cache for 300 seconds (5 minutes)
+  The default DNS Cache time limits can be changed within the registry
+  Enter DNS query information or IP addresses
+  One Per Line
"@                    
    }
}
$Section1NetworkLiveSearchTab.Controls.Add($NetworkLiveSearchDNSCacheRichTextbox)





################################################################################################################
################################################################################################################
################################################################################################################
################################################################################################################
################################################################################################################





$Section1NetworkSysmonSearchTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = "Logged Events (Sysmon)  "
    Left   = $FormScale * 3
    Top    = $FormScale * -10
    Width  = $FormScale * 450
    Height = $FormScale * 20
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = 'Blue'
    UseVisualStyleBackColor = $True
    ImageIndex = 1
}
$CollectionsNetworkTabControl.Controls.Add($Section1NetworkSysmonSearchTab)



$NetworkSysmonSearchGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text   = "Collection Options"
    Left   = $FormScale * 3
    Top    = $FormScale * 5
    Width  = $FormScale * 435
    Height = $FormScale * 50 #100
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
}

$NetworkSysmonRegexCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Use Regular Expression. Note: The backslash is the escape character, ex: c:\\Windows\\System32"
    Left   = $FormScale * 7
    Top    = $FormScale * 18
    Width  = $FormScale * 280 #430
    Height = $FormScale * 25
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = "Black"
    Checked = $false
}
$NetworkSysmonSearchGroupBox.Controls.Add($NetworkSysmonRegexCheckbox)


$SupportsRegexButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Regex Examples"
    Left   = $NetworkSysmonRegexCheckbox.Left + $NetworkSysmonRegexCheckbox.Width + $($FormScale * 28)
    Top    = $NetworkSysmonRegexCheckbox.Top
    Width  = $FormScale * 115
    Height = $FormScale * 20
    Add_Click = { Import-Csv "$Dependencies\Reference RegEx Examples.csv" | Out-GridView }
}
$NetworkSysmonSearchGroupBox.Controls.Add($SupportsRegexButton)
Apply-CommonButtonSettings -Button $SupportsRegexButton


# $NetworkSysmonDatetimeStartLabel = New-Object System.Windows.Forms.Label -Property @{
#     Text   = "DateTime Start:"
#     Left   = $FormScale * 77
#     Top    = $NetworkSysmonRegexCheckbox.Top + $NetworkSysmonRegexCheckbox.Height + $($FormScale * 10)
#     Width  = $FormScale * 90
#     Height = $FormScale * 20
#     Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
#     ForeColor = "Black"
# }
# $NetworkSysmonSearchGroupBox.Controls.Add($NetworkSysmonDatetimeStartLabel)


# $script:NetworkSysmonStartTimePicker = New-Object System.Windows.Forms.DateTimePicker -Property @{
#     Left         = $NetworkSysmonDatetimeStartLabel.Left + $NetworkSysmonDatetimeStartLabel.Width
#     Top          = $NetworkSysmonRegexCheckbox.Top + $NetworkSysmonRegexCheckbox.Height + $($FormScale * 10)
#     Width        = $FormScale * 265
#     Height       = $FormScale * 100
#     Font         = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
#     Format       = [windows.forms.datetimepickerFormat]::custom
#     CustomFormat = "dddd MMM dd, yyyy hh:mm tt"
#     Checked      = $True
#     ShowCheckBox = $True
#     ShowUpDown   = $False
#     AutoSize     = $true
#     #MinDate      = (Get-Date -Month 1 -Day 1 -Year 2000).DateTime
#     #MaxDate      = (Get-Date).DateTime
#     Value         = (Get-Date).AddDays(-1).DateTime
#     Add_Click = {
#         if ($script:NetworkSysmonStopTimePicker.checked -eq $false) {
#             $script:NetworkSysmonStopTimePicker.checked = $true
#         }
#     }
#     Add_MouseHover = {
#         Show-ToolTip -Title "DateTime - Starting" -Icon "Info" -Message @"
# +  Select the starting datetime to filter Event Logs
# +  This can be used with the Max Collection field
# +  If left blank, it will collect all available Event Logs
# +  If used, you must select both a start and end datetime
# "@
#     }
# }
# # Wednesday, June 5, 2019 10:27:40 PM
# # $TimePicker.Value
# # 20190605162740.383143-240
# # [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime(($script:NetworkSysmonStartTimePicker.Value))
# $NetworkSysmonSearchGroupBox.Controls.Add($script:NetworkSysmonStartTimePicker)


# $NetworkSysmonDatetimeStopLabel = New-Object System.Windows.Forms.Label -Property @{
#     Text   = "DateTime Stop:"
#     Left   = $NetworkSysmonDatetimeStartLabel.Left
#     Top    = $NetworkSysmonDatetimeStartLabel.Top + $NetworkSysmonDatetimeStartLabel.Height
#     Width  = $NetworkSysmonDatetimeStartLabel.Width
#     Height = $FormScale * 20
#     Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
#     ForeColor = "Black"
# }
# $NetworkSysmonSearchGroupBox.Controls.Add($NetworkSysmonDatetimeStopLabel)


# $script:NetworkSysmonStopTimePicker = New-Object System.Windows.Forms.DateTimePicker -Property @{
#     Left         = $NetworkSysmonDatetimeStopLabel.Left + $NetworkSysmonDatetimeStopLabel.Width
#     Top          = $NetworkSysmonDatetimeStartLabel.Top + $NetworkSysmonDatetimeStartLabel.Height
#     Width        = $script:NetworkSysmonStartTimePicker.Width
#     Height       = $FormScale * 100
#     Font         = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
#     Format       = [windows.forms.datetimepickerFormat]::custom
#     CustomFormat = "dddd MMM dd, yyyy hh:mm tt"
#     Checked      = $True
#     ShowCheckBox = $True
#     ShowUpDown   = $False
#     AutoSize     = $true
#     #MinDate      = (Get-Date -Month 1 -Day 1 -Year 2000).DateTime
#     #MaxDate      = (Get-Date).DateTime
#     Add_MouseHover = {
#         Show-ToolTip -Title "DateTime - Ending" -Icon "Info" -Message @"
# +  Select the ending datetime to filter Event Logs
# +  This can be used with the Max Collection field
# +  If left blank, it will collect all available Event Logs
# +  If used, you must select both a start and end datetime
# "@
#     }
# }
# $NetworkSysmonSearchGroupBox.Controls.Add($script:NetworkSysmonStopTimePicker)

$Section1NetworkSysmonSearchTab.Controls.Add($NetworkSysmonSearchGroupBox)


$NetworkSysmonSearchSourceIPAddressCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Source IP / Hostname (WinRM)"
    Left   = $FormScale * 3
    Top    = $NetworkSysmonSearchGroupBox.Top + $NetworkSysmonSearchGroupBox.Height + $($FormScale * 10)
    Width  = $FormScale * 250
    Height = $FormScale * 20
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        Update-QueryCount
        
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1NetworkSysmonSearchTab.Controls.Add($NetworkSysmonSearchSourceIPAddressCheckbox)


$NetworkSysmonSearchSourceIPAddressSelectionButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Select IP Addresses"
    Left   = $NetworkSysmonSearchSourceIPAddressCheckbox.Left
    Top    = $NetworkSysmonSearchSourceIPAddressCheckbox.Top + $NetworkSysmonSearchSourceIPAddressCheckbox.Height + $($FormScale * 3)
    Width  = $FormScale * 250
    Height = $FormScale * 20
    Add_Click = {
        Import-Csv "$script:EndpointTreeNodeFileSave"  | Out-GridView -Title 'PoSh-EasyWin: IP Address Selection' -OutputMode Multiple | Select-Object -Property IPv4Address | Set-Variable -Name IPAddressSelectionContents
        $IPAddressColumn = $IPAddressSelectionContents | Select-Object -ExpandProperty IPv4Address
        $IPAddressToBeScan = ""
        Foreach ($Port in $IPAddressColumn) {
            $IPAddressToBeScan += "$Port`r`n"
        }
        if ($NetworkSysmonSearchSourceIPAddressRichTextbox.Lines -eq "Enter Source IPs; One Per Line") { $NetworkSysmonSearchSourceIPAddressRichTextbox.Text = "" }
        $NetworkSysmonSearchSourceIPAddressRichTextbox.Text += $("`r`n" + $IPAddressToBeScan)
        $NetworkSysmonSearchSourceIPAddressRichTextbox.Text  = $NetworkSysmonSearchSourceIPAddressRichTextbox.Text.Trim("")                
    }
}
$Section1NetworkSysmonSearchTab.Controls.Add($NetworkSysmonSearchSourceIPAddressSelectionButton)
Apply-CommonButtonSettings -Button $NetworkSysmonSearchSourceIPAddressSelectionButton


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RichTextBox\NetworkSysmonSearchSourceIPAddressRichTextbox.ps1"
. "$Dependencies\Code\System.Windows.Forms\RichTextBox\NetworkSysmonSearchSourceIPAddressRichTextbox.ps1"
$NetworkSysmonSearchSourceIPAddressRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Lines  = "Enter Source IPs; One Per Line"
    Left   = $NetworkSysmonSearchSourceIPAddressSelectionButton.Left
    Top    = $NetworkSysmonSearchSourceIPAddressSelectionButton.Top + $NetworkSysmonSearchSourceIPAddressSelectionButton.Height + $($FormScale * 5)
    Width  = $FormScale * 250
    Height = $FormScale * 75
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    MultiLine  = $True
    ScrollBars = "Vertical"
    WordWrap   = $True
    ShortcutsEnabled = $true
    Add_MouseEnter = {if ($this.text -eq "Enter Source IPs; One Per Line"){$this.text = ""}}
    Add_MouseLeave = {if ($this.text -eq "") {$this.text = "Enter Source IPs; One Per Line"}}
    Add_MouseHover = {
        Show-ToolTip -Title "Source IP Address" -Icon "Info" -Message @"
+  Check hosts for connections to one or more Source IP addresses
+  Enter Source IPs
+  One Per Line
"@  
    }
}
$Section1NetworkSysmonSearchTab.Controls.Add($NetworkSysmonSearchSourceIPAddressRichTextbox)


$NetworkSysmonSearchSourcePortCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Source Port / Name"
    Left   = $NetworkSysmonSearchSourceIPAddressCheckbox.Left + $NetworkSysmonSearchSourceIPAddressCheckbox.Width + $($FormScale * 10)
    Top    = $NetworkSysmonSearchSourceIPAddressCheckbox.Top
    Width  = $FormScale * 170
    Height = $FormScale * 20
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = { 
        Update-QueryCount
        
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1NetworkSysmonSearchTab.Controls.Add($NetworkSysmonSearchSourcePortCheckbox)


$NetworkSysmonSearchSourcePortSelectionButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Select Ports"
    Left   = $NetworkSysmonSearchSourcePortCheckbox.Left
    Top    = $NetworkSysmonSearchSourcePortCheckbox.Top + $NetworkSysmonSearchSourcePortCheckbox.Height + $($FormScale * 3)
    Width  = $FormScale * 170
    Height = $FormScale * 20
    Add_Click = {
        Import-Csv "$Dependencies\Ports, Protocols, and Services.csv" | Out-GridView -Title 'PoSh-EasyWin: Port Selection' -OutputMode Multiple | Select-Object -Property Port | Set-Variable -Name PortManualEntrySelectionContents
        $PortsColumn = $PortManualEntrySelectionContents | Select-Object -ExpandProperty Port
        $PortsToBeScan = ""
        Foreach ($Port in $PortsColumn) {
            $PortsToBeScan += "$Port`r`n"
        }
        if ($NetworkSysmonSearchSourcePortRichTextbox.Lines -eq "Enter Source Ports; One Per Line") { $NetworkSysmonSearchSourcePortRichTextbox.Text = "" }
        $NetworkSysmonSearchSourcePortRichTextbox.Text += $("`r`n" + $PortsToBeScan)
        $NetworkSysmonSearchSourcePortRichTextbox.Text  = $NetworkSysmonSearchSourcePortRichTextbox.Text.Trim("")            
    }
}
$Section1NetworkSysmonSearchTab.Controls.Add($NetworkSysmonSearchSourcePortSelectionButton)
Apply-CommonButtonSettings -Button $NetworkSysmonSearchSourcePortSelectionButton


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RichTextBox\NetworkSysmonSearchSourcePortRichTextbox.ps1"
. "$Dependencies\Code\System.Windows.Forms\RichTextBox\NetworkSysmonSearchSourcePortRichTextbox.ps1"
$NetworkSysmonSearchSourcePortRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Lines  = "Enter Source Ports; One Per Line"
    Left   = $NetworkSysmonSearchSourcePortSelectionButton.Left
    Top    = $NetworkSysmonSearchSourcePortSelectionButton.Top  + $NetworkSysmonSearchSourcePortSelectionButton.Height + $($FormScale * 5)
    Width  = $FormScale * 170
    Height = $FormScale * 75
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    MultiLine  = $True
    ScrollBars = "Vertical"
    WordWrap   = $True
    #BorderStyle = 'Fixed3d' #Fixed3D, FixedSingle, none
    ShortcutsEnabled = $true
    Add_MouseEnter = {if ($this.text -eq "Enter Source Ports; One Per Line") {$this.text = ""}}            
    Add_MouseLeave = {if ($this.text -eq "") {$this.text = "Enter Source Ports; One Per Line"}}
    Add_MouseHover = {
        Show-ToolTip -Title "Source Port" -Icon "Info" -Message @"
+  Check hosts for connections with the listed Source port
+  Enter Source Ports
+  One Per Line
"@
    }                        
}
$Section1NetworkSysmonSearchTab.Controls.Add($NetworkSysmonSearchSourcePortRichTextbox)


$NetworkSysmonSearchDestinationIPAddressCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Destination IP / Hostname (WinRM)"
    Left   = $FormScale * 3
    Top    = $NetworkSysmonSearchSourceIPAddressRichTextbox.Top + $NetworkSysmonSearchSourceIPAddressRichTextbox.Height + $($FormScale * 10)
    Width  = $FormScale * 250
    Height = $FormScale * 20
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        Update-QueryCount
        
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1NetworkSysmonSearchTab.Controls.Add($NetworkSysmonSearchDestinationIPAddressCheckbox)


$NetworkSysmonSearchDestinationIPAddressSelectionButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Select IP Addresses"
    Left   = $NetworkSysmonSearchDestinationIPAddressCheckbox.Left
    Top    = $NetworkSysmonSearchDestinationIPAddressCheckbox.Top + $NetworkSysmonSearchDestinationIPAddressCheckbox.Height + $($FormScale * 3)
    Width  = $FormScale * 250
    Height = $FormScale * 20
    Add_Click = {
        Import-Csv "$script:EndpointTreeNodeFileSave"  | Out-GridView -Title 'PoSh-EasyWin: IP Address Selection' -OutputMode Multiple | Select-Object -Property IPv4Address | Set-Variable -Name IPAddressSelectionContents
        $IPAddressColumn = $IPAddressSelectionContents | Select-Object -ExpandProperty IPv4Address
        $IPAddressToBeScan = ""
        Foreach ($Port in $IPAddressColumn) {
            $IPAddressToBeScan += "$Port`r`n"
        }
        if ($NetworkSysmonSearchDestinationIPAddressRichTextbox.Lines -eq "Enter Destination IPs; One Per Line") { $NetworkSysmonSearchDestinationIPAddressRichTextbox.Text = "" }
        $NetworkSysmonSearchDestinationIPAddressRichTextbox.Text += $("`r`n" + $IPAddressToBeScan)
        $NetworkSysmonSearchDestinationIPAddressRichTextbox.Text  = $NetworkSysmonSearchDestinationIPAddressRichTextbox.Text.Trim("")            
    }
}
$Section1NetworkSysmonSearchTab.Controls.Add($NetworkSysmonSearchDestinationIPAddressSelectionButton)
Apply-CommonButtonSettings -Button $NetworkSysmonSearchDestinationIPAddressSelectionButton


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RichTextBox\NetworkSysmonSearchDestinationIPAddressRichTextbox.ps1"
. "$Dependencies\Code\System.Windows.Forms\RichTextBox\NetworkSysmonSearchDestinationIPAddressRichTextbox.ps1"
$NetworkSysmonSearchDestinationIPAddressRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Lines  = "Enter Destination IPs; One Per Line"
    Left   = $NetworkSysmonSearchDestinationIPAddressSelectionButton.Left
    Top    = $NetworkSysmonSearchDestinationIPAddressSelectionButton.Top + $NetworkSysmonSearchDestinationIPAddressSelectionButton.Height + $($FormScale * 5)
    Width  = $FormScale * 250
    Height = $FormScale * 75
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    MultiLine  = $True
    ScrollBars = "Vertical"
    WordWrap   = $True
    ShortcutsEnabled = $true
    Add_MouseEnter = {if ($this.text -eq "Enter Destination IPs; One Per Line"){$this.text = ""}}
    Add_MouseLeave = {if ($this.text -eq "") {$this.text = "Enter Destination IPs; One Per Line"}}
    Add_MouseHover = {
        Show-ToolTip -Title "Destination IP Address" -Icon "Info" -Message @"
+  Check hosts for connections to one or more Destination IP addresses
+  Enter Destination IPs
+  One Per Line
"@  
    }
}
$Section1NetworkSysmonSearchTab.Controls.Add($NetworkSysmonSearchDestinationIPAddressRichTextbox)


$NetworkSysmonSearchDestinationPortCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Destination Port / Name"
    Left = $NetworkSysmonSearchDestinationIPAddressCheckbox.Left + $NetworkSysmonSearchDestinationIPAddressCheckbox.Width + $($FormScale * 10)
    Top = $NetworkSysmonSearchDestinationIPAddressCheckbox.Top
    Width  = $FormScale * 170
    Height = $FormScale * 20
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = { 
        Update-QueryCount
        
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1NetworkSysmonSearchTab.Controls.Add($NetworkSysmonSearchDestinationPortCheckbox)


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\NetworkSysmonSearchDestinationPortSelectionButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\NetworkSysmonSearchDestinationPortSelectionButton.ps1"
$NetworkSysmonSearchDestinationPortSelectionButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Select Ports"
    Left   = $NetworkSysmonSearchDestinationPortCheckbox.Left
    Top    = $NetworkSysmonSearchDestinationPortCheckbox.Top + $NetworkSysmonSearchDestinationPortCheckbox.Height + $($FormScale * 3)
    Width  = $FormScale * 170
    Height = $FormScale * 20
    Add_Click = {
        Import-Csv "$Dependencies\Ports, Protocols, and Services.csv" | Out-GridView -Title 'PoSh-EasyWin: Port Selection' -OutputMode Multiple | Select-Object -Property Port | Set-Variable -Name PortManualEntrySelectionContents
        $PortsColumn = $PortManualEntrySelectionContents | Select-Object -ExpandProperty Port
        $PortsToBeScan = ""
        Foreach ($Port in $PortsColumn) {
            $PortsToBeScan += "$Port`r`n"
        }
        if ($NetworkSysmonSearchDestinationPortRichTextbox.Lines -eq "Enter Destination Ports; One Per Line") { $NetworkSysmonSearchDestinationPortRichTextbox.Text = "" }
        $NetworkSysmonSearchDestinationPortRichTextbox.Text += $("`r`n" + $PortsToBeScan)
        $NetworkSysmonSearchDestinationPortRichTextbox.Text  = $NetworkSysmonSearchDestinationPortRichTextbox.Text.Trim("")            
    }
}
$Section1NetworkSysmonSearchTab.Controls.Add($NetworkSysmonSearchDestinationPortSelectionButton)
Apply-CommonButtonSettings -Button $NetworkSysmonSearchDestinationPortSelectionButton


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RichTextBox\NetworkSysmonSearchDestinationPortRichTextbox.ps1"
. "$Dependencies\Code\System.Windows.Forms\RichTextBox\NetworkSysmonSearchDestinationPortRichTextbox.ps1"
$NetworkSysmonSearchDestinationPortRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Lines  = "Enter Destination Ports; One Per Line"
    Left   = $NetworkSysmonSearchDestinationPortSelectionButton.Left
    Top    = $NetworkSysmonSearchDestinationPortSelectionButton.Top + $NetworkSysmonSearchDestinationPortSelectionButton.Height + $($FormScale * 5)
    Width  = $FormScale * 170
    Height = $FormScale * 75
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    MultiLine  = $True
    ScrollBars = "Vertical"
    WordWrap   = $True
    ShortcutsEnabled = $true
    Add_MouseEnter = {if ($this.text -eq "Enter Destination Ports; One Per Line") {$this.text = ""}}
    Add_MouseLeave = {if ($this.text -eq "") {$this.text = "Enter Destination Ports; One Per Line"}}
    Add_MouseHover = {
        Show-ToolTip -Title "Destination Port" -Icon "Info" -Message @"
+  Check hosts for connections to one or more Destination ports
+  Enter Destination Ports
+  One Per Line
"@
    }
}
$Section1NetworkSysmonSearchTab.Controls.Add($NetworkSysmonSearchDestinationPortRichTextbox)


$NetworkSysmonSearchExecutablePathCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Execution / Image Path (WinRM)"
    Left   = $FormScale * 3
    Top    = $NetworkSysmonSearchDestinationIPAddressRichTextbox.Top + $NetworkSysmonSearchDestinationIPAddressRichTextbox.Height + $($FormScale * 5)
    Width  = $FormScale * 250
    Height = $FormScale * 20
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        Update-QueryCount
        
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
    Add_MouseHover = {
        Show-ToolTip -Title "Image Path" -Icon "Info" -Message @"
+  Also known as the exectuion path
+  Checks for network connection with matching image/execution paths
+  Enter Destination Ports
+  One Per Line
"@  
    }
}
$Section1NetworkSysmonSearchTab.Controls.Add($NetworkSysmonSearchExecutablePathCheckbox)


$NetworkSysmonSearchExecutablePathTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Lines  = "Enter full paths; One Per Line"
    Left   = $FormScale * 3
    Top    = $NetworkSysmonSearchExecutablePathCheckbox.Top + $NetworkSysmonSearchExecutablePathCheckbox.Height + $($FormScale * 5)
    Width  = $FormScale * 250
    Height = $FormScale * 135
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    MultiLine  = $True
    ScrollBars = "Vertical"
    WordWrap   = $True
    ShortcutsEnabled = $true
    Add_MouseEnter   = { if ($this.text -eq "Enter full paths; One Per Line"){ $this.text = "" } }
    Add_MouseLeave   = { if ($this.text -eq "") { $this.text = "Enter full paths; One Per Line" } }
    Add_MouseHover = {
        Show-ToolTip -Title "Image Path" -Icon "Info" -Message @"
+  Also known as the exectuion path
+  Checks for network connection with matching image/execution paths
+  Enter Destination Ports
+  One Per Line
"@  
    }
}
$Section1NetworkSysmonSearchTab.Controls.Add($NetworkSysmonSearchExecutablePathTextbox)


$NetworkSysmonSearchAccountCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "User / Account (WinRM)"
    Left   = $NetworkSysmonSearchExecutablePathCheckbox.Left + $NetworkSysmonSearchExecutablePathCheckbox.Width + $($FormScale * 10)
    Top    = $NetworkSysmonSearchDestinationIPAddressRichTextbox.Top + $NetworkSysmonSearchDestinationIPAddressRichTextbox.Height + $($FormScale * 5)
    Width  = $FormScale * 170
    Height = $FormScale * 20
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        Update-QueryCount
        
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
    Add_MouseHover = {
        Show-ToolTip -Title "Image Path" -Icon "Info" -Message @"
+  Also known as User
+  Checks for network connection with matching user / accounts that executed them
+  Enter Destination Ports
+  One Per Line
"@  
    }
}
$Section1NetworkSysmonSearchTab.Controls.Add($NetworkSysmonSearchAccountCheckbox)


$NetworkSysmonSearchAccountRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Lines  = "Enter Command; One Per Line"
    Left   = $NetworkSysmonSearchExecutablePathTextbox.Left + $NetworkSysmonSearchExecutablePathTextbox.Width + $($FormScale * 10)
    Top    = $NetworkSysmonSearchAccountCheckbox.Top + $NetworkSysmonSearchAccountCheckbox.Height + $($FormScale * 5)
    Width  = $FormScale * 170
    Height = $FormScale * 135
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    MultiLine  = $True
    ScrollBars = "Vertical"
    WordWrap   = $True
    ShortcutsEnabled = $true
    Add_MouseEnter   = { if ($this.text -eq "Enter Command; One Per Line"){ $this.text = "" } }
    Add_MouseLeave   = { if ($this.text -eq "") { $this.text = "Enter Command; One Per Line" } }
    Add_MouseHover = {
        Show-ToolTip -Title "Image Path" -Icon "Info" -Message @"
+  Also known as User
+  Checks for network connection with matching user / accounts that executed them
+  Enter Destination Ports
+  One Per Line
"@  
    }
}
$Section1NetworkSysmonSearchTab.Controls.Add($NetworkSysmonSearchAccountRichTextbox)



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUDCDQnstjdoggGT/Jdg9Ji2uZ
# ECCgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUe9mhwpUqO4KfFLrDDfbWbGQcvhEwDQYJKoZI
# hvcNAQEBBQAEggEAMeRJwwmf/vDQFCn/FyzmPBR7WfEyP1l166DOKxb7FtHsZ46x
# TcTpIZQJZpX/5iIGQCItmxUyZo5BIVml6Hf/8ySlGi+65kJ7xDfWwxczdEPtzoq1
# blWGP2W83+W680If/S0XZRC8qRQy0f0/+CW526WumdAtrzN/bB7BfUr9F7U2acYa
# iEJLpCHF+UzXkBt2ZnU5Wzb86mZACxSZN1eM89nlJ7FZPGC3RUm+cKZvg3+thxrF
# 7/6mIe2a8RXyKslOHHImobhCxWZht8+olhw6SruRdvwr4GGbHk3jky6aJroSHMX/
# cA0s3uaYVR7AQ73HHa+gvfCftnIeur9DLx2aQA==
# SIG # End signature block
