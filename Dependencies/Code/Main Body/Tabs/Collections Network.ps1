
$Section1NetworkConnectionsSearchTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text     = "Network"
    Location = @{ X = $FormScale * 3
                  Y = $FormScale * -10 }
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


        Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\NetworkConnectionSearchRemoteIPAddressSelectionButton.ps1"
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


        Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RichTextBox\NetworkConnectionSearchRemoteIPAddressRichTextbox.ps1"
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


        Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\NetworkConnectionSearchRemotePortSelectionButton.ps1"
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


        Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RichTextBox\NetworkConnectionSearchRemotePortRichTextbox.ps1"
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


        Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\NetworkConnectionSearchLocalPortSelectionButton.ps1"
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


        Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RichTextBox\NetworkConnectionSearchLocalPortRichTextbox.ps1"
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


            Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RichTextBox\NetworkConnectionSearchProcessRichTextbox.ps1"
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


Update-FormProgress "$Dependencies\Code\Main Body\Get-DNSCache.ps1"
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


            Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RichTextBox\NetworkConnectionSearchDNSCacheRichTextbox.ps1"
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

