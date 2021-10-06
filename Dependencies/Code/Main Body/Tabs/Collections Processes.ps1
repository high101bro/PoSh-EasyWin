
$Section1ProcessesSearchTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = "Processes (Under Dev)"
    Left   = $FormScale * 3
    Top    = $FormScale * -10
    Width  = $FormScale * 450
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
    ImageIndex = 7
}
$MainLeftCollectionsTabControl.Controls.Add($Section1ProcessesSearchTab)


$ProcessesSearchGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text   = "Collection Options"
    Left   = $FormScale * 3
    Top    = $FormScale * 5
    Width  = $FormScale * 435
    Height = $FormScale * 50
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
}

            $ProcessesRegexCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
                Text   = "Use Regular Expression. Note: The backslash is the escape character, ex: c:\\Windows\\System32"
                Left   = $FormScale * 7
                Top    = $FormScale * 18
                Width  = $FormScale * 280 #430
                Height = $FormScale * 25
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
                Checked = $false
            }
            $ProcessesSearchGroupBox.Controls.Add($ProcessesRegexCheckbox)


            $SupportsRegexButton = New-Object System.Windows.Forms.Button -Property @{
                Text   = "Regex Examples"
                Left   = $ProcessesRegexCheckbox.Left + $ProcessesRegexCheckbox.Width + $($FormScale * 28)
                Top    = $ProcessesRegexCheckbox.Top
                Width  = $FormScale * 115
                Height = $FormScale * 22
                Add_Click = { Import-Csv "$Dependencies\Reference RegEx Examples.csv" | Out-GridView }
            }
            $ProcessesSearchGroupBox.Controls.Add($SupportsRegexButton)
            Apply-CommonButtonSettings -Button $SupportsRegexButton
$Section1ProcessesSearchTab.Controls.Add($ProcessesSearchGroupBox)






$ProcessesSearchRemoteIPAddressCheckbox = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Under development... It will be very similar to the Network Tab."
    Left   = $FormScale * 3
    Top    = $ProcessesSearchGroupBox.Top + $ProcessesSearchGroupBox.Height + $($FormScale * 10)
    Width  = $FormScale * 420
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'DarkRed'
}
$Section1ProcessesSearchTab.Controls.Add($ProcessesSearchRemoteIPAddressCheckbox)

# $ProcessesSearchRemoteIPAddressCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
#     Text   = "Processes with Network Connections"
#     Left   = $FormScale * 3
#     Top    = $ProcessesSearchGroupBox.Top + $ProcessesSearchGroupBox.Height + $($FormScale * 10)
#     Width  = $FormScale * 180
#     Height = $FormScale * 22
#     Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
#     ForeColor = 'Blue'
#     Add_Click = {
#         Update-QueryCount
        
#         Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
#         if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
#     }
# }
# $Section1ProcessesSearchTab.Controls.Add($ProcessesSearchRemoteIPAddressCheckbox)


#         Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\ProcessesSearchRemoteIPAddressSelectionButton.ps1"
#         . "$Dependencies\Code\System.Windows.Forms\Button\ProcessesSearchRemoteIPAddressSelectionButton.ps1"
#         $ProcessesSearchRemoteIPAddressSelectionButton = New-Object System.Windows.Forms.Button -Property @{
#             Text   = "Select IP Addresses"
#             Left   = $ProcessesSearchRemoteIPAddressCheckbox.Left
#             Top    = $ProcessesSearchRemoteIPAddressCheckbox.Top + $ProcessesSearchRemoteIPAddressCheckbox.Height + $($FormScale * 3)
#             Width  = $FormScale * 180
#             Height = $FormScale * 20
#             Add_Click = $ProcessesSearchRemoteIPAddressSelectionButtonAdd_Click
#         }
#         $Section1ProcessesSearchTab.Controls.Add($ProcessesSearchRemoteIPAddressSelectionButton)
#         Apply-CommonButtonSettings -Button $ProcessesSearchRemoteIPAddressSelectionButton


#         Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RichTextBox\ProcessesSearchRemoteIPAddressRichTextbox.ps1"
#         . "$Dependencies\Code\System.Windows.Forms\RichTextBox\ProcessesSearchRemoteIPAddressRichTextbox.ps1"
#         $ProcessesSearchRemoteIPAddressRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
#             Lines  = "Enter Remote IPs; One Per Line"
#             Left   = $ProcessesSearchRemoteIPAddressSelectionButton.Left
#             Top    = $ProcessesSearchRemoteIPAddressSelectionButton.Top + $ProcessesSearchRemoteIPAddressSelectionButton.Height + $($FormScale * 5)
#             Width  = $FormScale * 180
#             Height = $FormScale * 115
#             Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
#             MultiLine  = $True
#             ScrollBars = "Vertical"
#             WordWrap   = $True
#             ShortcutsEnabled = $true
#             Add_MouseEnter = $ProcessesSearchRemoteIPAddressRichTextboxAdd_MouseEnter
#             Add_MouseLeave = $ProcessesSearchRemoteIPAddressRichTextboxAdd_MouseLeave
#             Add_MouseHover = $ProcessesSearchRemoteIPAddressRichTextboxAdd_MouseHover
#         }
#         $Section1ProcessesSearchTab.Controls.Add($ProcessesSearchRemoteIPAddressRichTextbox)


# $ProcessesSearchRemotePortCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
#     Text     = "Remote Port"
#     Left = $ProcessesSearchRemoteIPAddressCheckbox.Left + $ProcessesSearchRemoteIPAddressCheckbox.Width + $($FormScale * 10)
#     Top = $ProcessesSearchRemoteIPAddressCheckbox.Top
#     Width  = $FormScale * 115
#     Height = $FormScale * 22
#     Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
#     ForeColor = 'Blue'
#     Add_Click = { 
#         Update-QueryCount
        
#         Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
#         if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
#     }
# }
# $Section1ProcessesSearchTab.Controls.Add($ProcessesSearchRemotePortCheckbox)


#         Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\ProcessesSearchRemotePortSelectionButton.ps1"
#         . "$Dependencies\Code\System.Windows.Forms\Button\ProcessesSearchRemotePortSelectionButton.ps1"
#         $ProcessesSearchRemotePortSelectionButton = New-Object System.Windows.Forms.Button -Property @{
#             Text   = "Select Ports"
#             Left   = $ProcessesSearchRemotePortCheckbox.Left
#             Top    = $ProcessesSearchRemotePortCheckbox.Top + $ProcessesSearchRemotePortCheckbox.Height + $($FormScale * 3)
#             Width  = $FormScale * 115
#             Height = $FormScale * 20
#             Add_Click = $ProcessesSearchRemotePortSelectionButtonAdd_Click
#         }
#         $Section1ProcessesSearchTab.Controls.Add($ProcessesSearchRemotePortSelectionButton)
#         Apply-CommonButtonSettings -Button $ProcessesSearchRemotePortSelectionButton


#         Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RichTextBox\ProcessesSearchRemotePortRichTextbox.ps1"
#         . "$Dependencies\Code\System.Windows.Forms\RichTextBox\ProcessesSearchRemotePortRichTextbox.ps1"
#         $ProcessesSearchRemotePortRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
#             Lines  = "Enter Remote Ports; One Per Line"
#             Left   = $ProcessesSearchRemotePortSelectionButton.Left
#             Top    = $ProcessesSearchRemotePortSelectionButton.Top + $ProcessesSearchRemotePortSelectionButton.Height + $($FormScale * 5)
#             Width  = $FormScale * 115
#             Height = $FormScale * 115
#             Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
#             MultiLine  = $True
#             ScrollBars = "Vertical"
#             WordWrap   = $True
#             ShortcutsEnabled = $true
#             Add_MouseEnter = $ProcessesSearchRemotePortRichTextboxAdd_MouseEnter
#             Add_MouseLeave = $ProcessesSearchRemotePortRichTextboxAdd_MouseLeave
#             Add_MouseHover = $ProcessesSearchRemotePortRichTextboxAdd_MouseHover
#         }
#         $Section1ProcessesSearchTab.Controls.Add($ProcessesSearchRemotePortRichTextbox)


# $ProcessesSearchLocalPortCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
#     Text   = "Local Port"
#     Left   = $ProcessesSearchRemotePortCheckbox.Left + $ProcessesSearchRemotePortCheckbox.Width + $($FormScale * 10)
#     Top    = $ProcessesSearchRemotePortCheckbox.Top
#     Width  = $FormScale * 115
#     Height = $FormScale * 22
#     Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
#     ForeColor = 'Blue'
#     Add_Click = { 
#         Update-QueryCount
        
#         Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
#         if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
#     }
# }
# $Section1ProcessesSearchTab.Controls.Add($ProcessesSearchLocalPortCheckbox)


#         Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\ProcessesSearchLocalPortSelectionButton.ps1"
#         . "$Dependencies\Code\System.Windows.Forms\Button\ProcessesSearchLocalPortSelectionButton.ps1"
#         $ProcessesSearchLocalPortSelectionButton = New-Object System.Windows.Forms.Button -Property @{
#             Text   = "Select Ports"
#             Left   = $ProcessesSearchLocalPortCheckbox.Left
#             Top    = $ProcessesSearchLocalPortCheckbox.Top + $ProcessesSearchLocalPortCheckbox.Height + $($FormScale * 3)
#             Width  = $FormScale * 115
#             Height = $FormScale * 20
#             Add_Click = $ProcessesSearchLocalPortSelectionButtonAdd_Click
#         }
#         $Section1ProcessesSearchTab.Controls.Add($ProcessesSearchLocalPortSelectionButton)
#         Apply-CommonButtonSettings -Button $ProcessesSearchLocalPortSelectionButton


#         Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RichTextBox\ProcessesSearchLocalPortRichTextbox.ps1"
#         . "$Dependencies\Code\System.Windows.Forms\RichTextBox\ProcessesSearchLocalPortRichTextbox.ps1"
#         $ProcessesSearchLocalPortRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
#             Lines  = "Enter Local Ports; One Per Line"
#             Left   = $ProcessesSearchLocalPortSelectionButton.Left
#             Top    = $ProcessesSearchLocalPortSelectionButton.Top  + $ProcessesSearchLocalPortSelectionButton.Height + $($FormScale * 5)
#             Width  = $FormScale * 115
#             Height = $FormScale * 115
#             Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
#             MultiLine  = $True
#             ScrollBars = "Vertical"
#             WordWrap   = $True
#             #BorderStyle = 'Fixed3d' #Fixed3D, FixedSingle, none
#             ShortcutsEnabled = $true
#             Add_MouseEnter = $ProcessesSearchLocalPortRichTextboxAdd_MouseEnter
#             Add_MouseLeave = $ProcessesSearchLocalPortRichTextboxAdd_MouseLeave
#             Add_MouseHover = $ProcessesSearchLocalPortRichTextboxAdd_MouseHover
#         }
#         $Section1ProcessesSearchTab.Controls.Add($ProcessesSearchLocalPortRichTextbox)



















# $ProcessesSearchCommandLineCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
#     Text   = "Command Line (WinRM)"
#     Left   = $FormScale * 3
#     Top    = $ProcessesSearchRemoteIPAddressRichTextbox.Top + $ProcessesSearchRemoteIPAddressRichTextbox.Height + $($FormScale * 5)
#     Width  = $FormScale * 210 #430
#     Height = $FormScale * 22
#     Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
#     ForeColor = 'Blue'
#     Add_Click = {
#         Update-QueryCount
        
#         Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
#         if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
#     }
# }
# $Section1ProcessesSearchTab.Controls.Add($ProcessesSearchCommandLineCheckbox)


#             $ProcessesSearchCommandLineRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
#                 Lines  = "Enter Command; One Per Line"
#                 Left   = $FormScale * 3
#                 Top    = $ProcessesSearchCommandLineCheckbox.Top + $ProcessesSearchCommandLineCheckbox.Height + $($FormScale * 5)
#                 Width  = $FormScale * 210 #430
#                 Height = $FormScale * 100
#                 Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
#                 MultiLine  = $True
#                 ScrollBars = "Vertical"
#                 WordWrap   = $True
#                 ShortcutsEnabled = $true
#                 #Add_MouseHover   = $ProcessesSearchCommandLineRichTextboxAdd_MouseHover
#                 Add_MouseEnter   = { if ($this.text -eq "Enter Command; One Per Line"){ $this.text = "" } }
#                 Add_MouseLeave   = { if ($this.text -eq "") { $this.text = "Enter Command; One Per Line" } }
#             }
#             $Section1ProcessesSearchTab.Controls.Add($ProcessesSearchCommandLineRichTextbox)


# $ProcessesSearchExecutablePathCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
#     Text   = "Executable Path (WinRM)"
#     Left   = $ProcessesSearchCommandLineRichTextbox.Left + $ProcessesSearchCommandLineRichTextbox.Width + $($FormScale * 5)
#     Top    = $ProcessesSearchCommandLineCheckbox.Top
#     Width  = $FormScale * 210 #430
#     Height = $FormScale * 22
#     Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
#     ForeColor = 'Blue'
#     Add_Click = {
#         Update-QueryCount
        
#         Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
#         if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
#     }
# }
# $Section1ProcessesSearchTab.Controls.Add($ProcessesSearchExecutablePathCheckbox)


#             $ProcessesSearchExecutablePathTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
#                 Lines  = "Enter full paths; One Per Line"
#                 Left   = $ProcessesSearchExecutablePathCheckbox.Left
#                 Top    = $ProcessesSearchExecutablePathCheckbox.Top + $ProcessesSearchExecutablePathCheckbox.Height + $($FormScale * 5)
#                 Width  = $FormScale * 210 #430
#                 Height = $FormScale * 100
#                 Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
#                 MultiLine  = $True
#                 ScrollBars = "Vertical"
#                 WordWrap   = $True
#                 ShortcutsEnabled = $true
#                 Add_MouseEnter   = { if ($this.text -eq "Enter full paths; One Per Line"){ $this.text = "" } }
#                 Add_MouseLeave   = { if ($this.text -eq "") { $this.text = "Enter full paths; One Per Line" } }
#                 #Add_MouseHover = $ProcessesSearchExecutablePathTextboxAdd_MouseHover
#             }
#             $Section1ProcessesSearchTab.Controls.Add($ProcessesSearchExecutablePathTextbox)






















# $ProcessesSearchProcessCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
#     Text   = "Process Name (WinRM)"
#     Left   = $FormScale * 3
#     Top    = $ProcessesSearchCommandLineRichTextbox.Top + $ProcessesSearchCommandLineRichTextbox.Height + $($FormScale * 5)
#     Width  = $FormScale * 210 #430
#     Height = $FormScale * 22
#     Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
#     ForeColor = 'Blue'
#     Add_Click = {
#         Update-QueryCount
        
#         Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
#         if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
#     }
# }
# $Section1ProcessesSearchTab.Controls.Add($ProcessesSearchProcessCheckbox)


#             Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RichTextBox\ProcessesSearchProcessRichTextbox.ps1"
#             . "$Dependencies\Code\System.Windows.Forms\RichTextBox\ProcessesSearchProcessRichTextbox.ps1"
#             $ProcessesSearchProcessRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
#                 Lines  = "Enter Process Names; One Per Line"
#                 Left   = $FormScale * 3
#                 Top    = $ProcessesSearchProcessCheckbox.Top + $ProcessesSearchProcessCheckbox.Height + $($FormScale * 5)
#                 Width  = $FormScale * 210 #430
#                 Height = $FormScale * 100
#                 Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
#                 MultiLine  = $True
#                 ScrollBars = "Vertical"
#                 WordWrap   = $True
#                 ShortcutsEnabled = $true
#                 Add_MouseHover   = $ProcessesSearchProcessRichTextboxAdd_MouseHover
#                 Add_MouseEnter   = $ProcessesSearchProcessRichTextboxAdd_MouseEnter
#                 Add_MouseLeave   = $ProcessesSearchProcessRichTextboxAdd_MouseLeave
#             }
#             $Section1ProcessesSearchTab.Controls.Add($ProcessesSearchProcessRichTextbox)


# Update-FormProgress "$Dependencies\Code\Main Body\Get-DNSCache.ps1"
# . "$Dependencies\Code\Main Body\Get-DNSCache.ps1"
# $ProcessesSearchDNSCacheCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
#     Text   = "DNS Cache Entry (WinRM)"
#     Left   = $ProcessesSearchProcessRichTextbox.Left + $ProcessesSearchProcessRichTextbox.Width + $($FormScale * 5)
#     Top    = $ProcessesSearchProcessCheckbox.Top
#     Width  = $FormScale * 210 #430
#     Height = $FormScale * 22
#     Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
#     ForeColor = 'Blue'
#     Add_Click = {
#         Update-QueryCount
        
#         Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
#         if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
#     }
# }
# $Section1ProcessesSearchTab.Controls.Add($ProcessesSearchDNSCacheCheckbox)


#             $ProcessesSearchDNSCacheRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
#                 Lines  = "Enter DNS query info or IP addresses; One Per Line"
#                 Left   = $ProcessesSearchDNSCacheCheckbox.Left
#                 Top    = $ProcessesSearchDNSCacheCheckbox.Top + $ProcessesSearchDNSCacheCheckbox.Height + $($FormScale * 5)
#                 Width  = $FormScale * 210 #430
#                 Height = $FormScale * 100
#                 Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
#                 MultiLine  = $True
#                 ScrollBars = "Vertical"
#                 WordWrap   = $True
#                 ShortcutsEnabled = $true
#                 Add_MouseEnter = { if ($this.text -eq "Enter DNS query info or IP addresses; One Per Line") { $this.text = "" } }
#                 Add_MouseLeave = { if ($this.text -eq "") { $this.text = "Enter DNS query info or IP addresses; One Per Line" } }                
#                 Add_MouseHover = {
#                     Show-ToolTip -Title "Remote DNS Cache Entry (WinRM)" -Icon "Info" -Message @"
#                     +  Check hosts' DNS Cache for entries that match given criteria
#                     +  The DNS Cache is not persistence on systems
#                     +  By default, Windows stores positive responses in the DNS Cache for 86,400 seconds (1 day)
#                     +  By default, Windows stores negative responses in the DNS Cache for 300 seconds (5 minutes)
#                     +  The default DNS Cache time limits can be changed within the registry
#                     +  Enter DNS query information or IP addresses
#                     +  One Per Line
# "@                    
#                 }
#             }
#             $Section1ProcessesSearchTab.Controls.Add($ProcessesSearchDNSCacheRichTextbox)
