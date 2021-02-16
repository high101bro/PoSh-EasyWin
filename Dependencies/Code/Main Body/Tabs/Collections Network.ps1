
$Section1NetworkConnectionsSearchTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = "Network"
    Left   = $FormScale * 3
    Top    = $FormScale * -10
    Width  = $FormScale * 450
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
}
$MainLeftCollectionsTabControl.Controls.Add($Section1NetworkConnectionsSearchTab)

        $NetworkEndpointPacketCaptureCheckBox = New-Object System.Windows.Forms.CheckBox -Property @{
            Text   = "Endpoint Packet Capture"
            Left   = $FormScale * 3
            TOp    = $Section1NetworkConnectionsSearchTab.Top + $Section1NetworkConnectionsSearchTab.Height + $($FormScale * 5)
            Width  = $FormScale * 175
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
            ForeColor = 'Blue'
            Add_Click = { 
                Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands 
                if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
            }
        }
        $Section1NetworkConnectionsSearchTab.Controls.Add($NetworkEndpointPacketCaptureCheckBox)


        $NetworkEndpointPcapCaptureDurationLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Duration (Secs)"
            Left   = $NetworkEndpointPacketCaptureCheckBox.Left + $NetworkEndpointPacketCaptureCheckBox.Width + $($FormScale * 12)
            Top    = $NetworkEndpointPacketCaptureCheckBox.Top + $($FormScale * 5)
            Width  = $FormScale * 88
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $Section1NetworkConnectionsSearchTab.Controls.Add($NetworkEndpointPcapCaptureDurationLabel)


        $NetworkEndpointPacketCaptureDurationTextBox = New-Object System.Windows.Forms.TextBox -Property @{
            Text   = "60"
            Left   = $NetworkEndpointPcapCaptureDurationLabel.Left + $NetworkEndpointPcapCaptureDurationLabel.Width
            Top    = $NetworkEndpointPcapCaptureDurationLabel.Top - $($FormScale * 2)
            Width  = $FormScale * 30
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $Section1NetworkConnectionsSearchTab.Controls.Add($NetworkEndpointPacketCaptureDurationTextBox)


        $NetworkEndpointPcapCaptureMaxSizeLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Max (MB)"
            Left   = $NetworkEndpointPacketCaptureDurationTextBox.Left + $NetworkEndpointPacketCaptureDurationTextBox.Width + $($FormScale * 35)
            Top    = $NetworkEndpointPacketCaptureDurationTextBox.Top + $($FormScale * 2)
            Width  = $FormScale * 60
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $Section1NetworkConnectionsSearchTab.Controls.Add($NetworkEndpointPcapCaptureMaxSizeLabel)


        $NetworkEndpointPacketCaptureMaxSizeTextBox = New-Object System.Windows.Forms.TextBox -Property @{
            Text   = "50"
            Left   = $NetworkEndpointPcapCaptureMaxSizeLabel.Left + $NetworkEndpointPcapCaptureMaxSizeLabel.Width
            Top    = $NetworkEndpointPcapCaptureMaxSizeLabel.Top - $($FormScale * 2)
            Width  = $FormScale * 30
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $Section1NetworkConnectionsSearchTab.Controls.Add($NetworkEndpointPacketCaptureMaxSizeTextBox)


        $NetworkConnectionSearchRemoteIPAddressCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
            Text   = "Remote IP (WinRM)"
            Left   = $FormScale * 3
            Top    = $NetworkEndpointPacketCaptureCheckBox.Top + $NetworkEndpointPacketCaptureCheckBox.Height + $($FormScale * 10)
            Width  = $FormScale * 180
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
            ForeColor = 'Blue'
            Add_Click = { 
                Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands 
                if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
            }
        }
        $Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchRemoteIPAddressCheckbox)


        Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\NetworkConnectionSearchRemoteIPAddressSelectionButton.ps1"
        . "$Dependencies\Code\System.Windows.Forms\Button\NetworkConnectionSearchRemoteIPAddressSelectionButton.ps1"
        $NetworkConnectionSearchRemoteIPAddressSelectionButton = New-Object System.Windows.Forms.Button -Property @{
            Text   = "Select IP Addresses"
            Left   = $NetworkConnectionSearchRemoteIPAddressCheckbox.Left
            Top    = $NetworkConnectionSearchRemoteIPAddressCheckbox.Top + $NetworkConnectionSearchRemoteIPAddressCheckbox.Height + $($FormScale * 3)
            Width  = $FormScale * 180
            Height = $FormScale * 20
            Add_Click = $NetworkConnectionSearchRemoteIPAddressSelectionButtonAdd_Click
        }
        $Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchRemoteIPAddressSelectionButton)
        CommonButtonSettings -Button $NetworkConnectionSearchRemoteIPAddressSelectionButton


        Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RichTextBox\NetworkConnectionSearchRemoteIPAddressRichTextbox.ps1"
        . "$Dependencies\Code\System.Windows.Forms\RichTextBox\NetworkConnectionSearchRemoteIPAddressRichTextbox.ps1"
        $NetworkConnectionSearchRemoteIPAddressRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Lines  = "Enter Remote IPs; One Per Line"
            Left   = $NetworkConnectionSearchRemoteIPAddressSelectionButton.Left
            Top    = $NetworkConnectionSearchRemoteIPAddressSelectionButton.Top + $NetworkConnectionSearchRemoteIPAddressSelectionButton.Height + $($FormScale * 5)
            Width  = $FormScale * 180
            Height = $FormScale * 115
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
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
    Left = $NetworkConnectionSearchRemoteIPAddressCheckbox.Left + $NetworkConnectionSearchRemoteIPAddressCheckbox.Width + $($FormScale * 10)
    Top = $NetworkConnectionSearchRemoteIPAddressCheckbox.Top
    Width  = $FormScale * 115
    Height = $FormScale * 22
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = { 
        Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchRemotePortCheckbox)


        Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\NetworkConnectionSearchRemotePortSelectionButton.ps1"
        . "$Dependencies\Code\System.Windows.Forms\Button\NetworkConnectionSearchRemotePortSelectionButton.ps1"
        $NetworkConnectionSearchRemotePortSelectionButton = New-Object System.Windows.Forms.Button -Property @{
            Text   = "Select Ports"
            Left   = $NetworkConnectionSearchRemotePortCheckbox.Left
            Top    = $NetworkConnectionSearchRemotePortCheckbox.Top + $NetworkConnectionSearchRemotePortCheckbox.Height + $($FormScale * 3)
            Width  = $FormScale * 115
            Height = $FormScale * 20
            Add_Click = $NetworkConnectionSearchRemotePortSelectionButtonAdd_Click
        }
        $Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchRemotePortSelectionButton)
        CommonButtonSettings -Button $NetworkConnectionSearchRemotePortSelectionButton


        Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RichTextBox\NetworkConnectionSearchRemotePortRichTextbox.ps1"
        . "$Dependencies\Code\System.Windows.Forms\RichTextBox\NetworkConnectionSearchRemotePortRichTextbox.ps1"
        $NetworkConnectionSearchRemotePortRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Lines  = "Enter Remote Ports; One Per Line"
            Left   = $NetworkConnectionSearchRemotePortSelectionButton.Left
            Top    = $NetworkConnectionSearchRemotePortSelectionButton.Top + $NetworkConnectionSearchRemotePortSelectionButton.Height + $($FormScale * 5)
            Width  = $FormScale * 115
            Height = $FormScale * 115
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
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
    Text   = "Local Port"
    Left   = $NetworkConnectionSearchRemotePortCheckbox.Left + $NetworkConnectionSearchRemotePortCheckbox.Width + $($FormScale * 10)
    Top    = $NetworkConnectionSearchRemotePortCheckbox.Top
    Width  = $FormScale * 115
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = { 
        Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchLocalPortCheckbox)


        Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\NetworkConnectionSearchLocalPortSelectionButton.ps1"
        . "$Dependencies\Code\System.Windows.Forms\Button\NetworkConnectionSearchLocalPortSelectionButton.ps1"
        $NetworkConnectionSearchLocalPortSelectionButton = New-Object System.Windows.Forms.Button -Property @{
            Text   = "Select Ports"
            Left   = $NetworkConnectionSearchLocalPortCheckbox.Left
            Top    = $NetworkConnectionSearchLocalPortCheckbox.Top + $NetworkConnectionSearchLocalPortCheckbox.Height + $($FormScale * 3)
            Width  = $FormScale * 115
            Height = $FormScale * 20
            Add_Click = $NetworkConnectionSearchLocalPortSelectionButtonAdd_Click
        }
        $Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchLocalPortSelectionButton)
        CommonButtonSettings -Button $NetworkConnectionSearchLocalPortSelectionButton


        Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RichTextBox\NetworkConnectionSearchLocalPortRichTextbox.ps1"
        . "$Dependencies\Code\System.Windows.Forms\RichTextBox\NetworkConnectionSearchLocalPortRichTextbox.ps1"
        $NetworkConnectionSearchLocalPortRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Lines  = "Enter Local Ports; One Per Line"
            Left   = $NetworkConnectionSearchLocalPortSelectionButton.Left
            Top    = $NetworkConnectionSearchLocalPortSelectionButton.Top  + $NetworkConnectionSearchLocalPortSelectionButton.Height + $($FormScale * 5)
            Width  = $FormScale * 115
            Height = $FormScale * 115
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
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
    Text   = "Process Name (WinRM)"
    Left   = $FormScale * 3
    Top    = $NetworkConnectionSearchRemoteIPAddressRichTextbox.Top + $NetworkConnectionSearchRemoteIPAddressRichTextbox.Height + $($FormScale * 5)
    Width  = $FormScale * 210 #430
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchProcessCheckbox)

            $NetworkConnectionSearchProcessLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Connections created by a process."
                Left   = $FormScale * 3
                Top    = $NetworkConnectionSearchProcessCheckbox.Top + $NetworkConnectionSearchProcessCheckbox.Height + $($FormScale * 3)
                Width  = $FormScale * 210 #430
                Height = $FormScale * 22
                ForeColor = "Black"
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            }
            $Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchProcessLabel)


            Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RichTextBox\NetworkConnectionSearchProcessRichTextbox.ps1"
            . "$Dependencies\Code\System.Windows.Forms\RichTextBox\NetworkConnectionSearchProcessRichTextbox.ps1"
            $NetworkConnectionSearchProcessRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
                Lines  = "Enter Process Names; One Per Line"
                Left   = $FormScale * 3
                Top    = $NetworkConnectionSearchProcessLabel.Top + $NetworkConnectionSearchProcessLabel.Height + $($FormScale * 5)
                Width  = $FormScale * 210 #430
                Height = $FormScale * 100
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                MultiLine  = $True
                ScrollBars = "Vertical"
                WordWrap   = $True
                ShortcutsEnabled = $true
                Add_MouseHover   = $NetworkConnectionSearchProcessRichTextboxAdd_MouseHover
                Add_MouseEnter   = $NetworkConnectionSearchProcessRichTextboxAdd_MouseEnter
                Add_MouseLeave   = $NetworkConnectionSearchProcessRichTextboxAdd_MouseLeave
            }
            $Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchProcessRichTextbox)


Update-FormProgress "$Dependencies\Code\Main Body\Get-DNSCache.ps1"
. "$Dependencies\Code\Main Body\Get-DNSCache.ps1"
$NetworkConnectionSearchDNSCacheCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "DNS Cache Entry (WinRM)"
    Left   = $NetworkConnectionSearchProcessRichTextbox.Left + $NetworkConnectionSearchProcessRichTextbox.Width + $($FormScale * 5)
    Top    = $NetworkConnectionSearchProcessCheckbox.Top
    Width  = $FormScale * 210 #430
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchDNSCacheCheckbox)

            $NetworkConnectionSearchDNSCacheLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "DNS Cache Entries (Volatile)."
                Left   = $NetworkConnectionSearchDNSCacheCheckbox.Left
                Top    = $NetworkConnectionSearchDNSCacheCheckbox.Top + $NetworkConnectionSearchDNSCacheCheckbox.Height + $($FormScale * 3)
                Width  = $FormScale * 210 #430
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
            }
            $Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchDNSCacheLabel)


            $NetworkConnectionSearchDNSCacheRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
                Lines  = "Enter DNS query info or IP addresses; One Per Line"
                Left   = $NetworkConnectionSearchDNSCacheCheckbox.Left
                Top    = $NetworkConnectionSearchDNSCacheLabel.Top + $NetworkConnectionSearchDNSCacheLabel.Height + $($FormScale * 5)
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
                    Show-ToolTip -Title "Remote DNS Cache Entry (WinRM)" -Icon "Info" -Message @"
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
            $Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchDNSCacheRichTextbox)


$NetworkConnectionSearchCommandLineCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Command Line (WinRM)"
    Left   = $FormScale * 3
    Top    = $NetworkConnectionSearchProcessRichTextbox.Top + $NetworkConnectionSearchProcessRichTextbox.Height + $($FormScale * 5)
    Width  = $FormScale * 210 #430
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchCommandLineCheckbox)

            $NetworkConnectionSearchCommandLineLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Connections with these commands."
                Left   = $FormScale * 3
                Top    = $NetworkConnectionSearchCommandLineCheckbox.Top + $NetworkConnectionSearchCommandLineCheckbox.Height + $($FormScale * 3)
                Width  = $FormScale * 210 #430
                Height = $FormScale * 22
                ForeColor = "Black"
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            }
            $Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchCommandLineLabel)


            $NetworkConnectionSearchCommandLineRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
                Lines  = "Enter Command; One Per Line"
                Left   = $FormScale * 3
                Top    = $NetworkConnectionSearchCommandLineLabel.Top + $NetworkConnectionSearchCommandLineLabel.Height + $($FormScale * 5)
                Width  = $FormScale * 210 #430
                Height = $FormScale * 100
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                MultiLine  = $True
                ScrollBars = "Vertical"
                WordWrap   = $True
                ShortcutsEnabled = $true
                #Add_MouseHover   = $NetworkConnectionSearchCommandLineRichTextboxAdd_MouseHover
                Add_MouseEnter   = { if ($this.text -eq "Enter Command; One Per Line"){ $this.text = "" } }
                Add_MouseLeave   = { if ($this.text -eq "") { $this.text = "Enter Command; One Per Line" } }
            }
            $Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchCommandLineRichTextbox)


$NetworkConnectionSearchFullPathCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Full Path of Executable (WinRM)"
    Left   = $NetworkConnectionSearchCommandLineRichTextbox.Left + $NetworkConnectionSearchCommandLineRichTextbox.Width + $($FormScale * 5)
    Top    = $NetworkConnectionSearchCommandLineCheckbox.Top
    Width  = $FormScale * 210 #430
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchFullPathCheckbox)

            $NetworkConnectionSearchFullPathLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Connections with the following full paths."
                Left   = $NetworkConnectionSearchFullPathCheckbox.Left
                Top    = $NetworkConnectionSearchFullPathCheckbox.Top + $NetworkConnectionSearchFullPathCheckbox.Height + $($FormScale * 3)
                Width  = $FormScale * 210 #430
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
            }
            $Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchFullPathLabel)


            $NetworkConnectionSearchFullPathTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
                Lines  = "Enter full paths; One Per Line"
                Left   = $NetworkConnectionSearchFullPathCheckbox.Left
                Top    = $NetworkConnectionSearchFullPathLabel.Top + $NetworkConnectionSearchFullPathLabel.Height + $($FormScale * 5)
                Width  = $FormScale * 210 #430
                Height = $FormScale * 100
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                MultiLine  = $True
                ScrollBars = "Vertical"
                WordWrap   = $True
                ShortcutsEnabled = $true
                Add_MouseEnter   = { if ($this.text -eq "Enter full paths; One Per Line"){ $this.text = "" } }
                Add_MouseLeave   = { if ($this.text -eq "") { $this.text = "Enter full paths; One Per Line" } }
                #Add_MouseHover = $NetworkConnectionSearchFullPathTextboxAdd_MouseHover
            }
            $Section1NetworkConnectionsSearchTab.Controls.Add($NetworkConnectionSearchFullPathTextbox)







