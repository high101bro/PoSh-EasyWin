
$SmithNetworkConnectionsSearchTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text     = "Network"
    Location = @{ X = $FormScale * 3
                  Y = $FormScale * -10 }
    Size     = @{ Width  = $FormScale * 450
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
}
$MainLeftSMITHTabControl.Controls.Add($SmithNetworkConnectionsSearchTab)

        $SmithNetworkEndpointPacketCaptureCheckBox = New-Object System.Windows.Forms.CheckBox -Property @{
            Text     = "Endpoint Packet Capture"
            Location = @{ X = $FormScale * 3
                          Y = $SmithNetworkConnectionsSearchTab.Location.Y + $SmithNetworkConnectionsSearchTab.Size.Height + $($FormScale * 5) }
            Size     = @{ Width  = $FormScale * 175
                          Height = $FormScale * 22 }
            Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
            ForeColor = 'Blue'
            Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
        }
        $SmithNetworkConnectionsSearchTab.Controls.Add($SmithNetworkEndpointPacketCaptureCheckBox)


        $SmithNetworkEndpointPcapCaptureDurationLabel = New-Object System.Windows.Forms.Label -Property @{
            Text     = "Duration (Secs)"
            Location = @{ X = $SmithNetworkEndpointPacketCaptureCheckBox.Location.X + $SmithNetworkEndpointPacketCaptureCheckBox.Size.Width + $($FormScale * 12)
                          Y = $SmithNetworkEndpointPacketCaptureCheckBox.Location.Y + $($FormScale * 5) }
            Size     = @{ Width  = $FormScale * 88
                          Height = $FormScale * 22 }
            Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $SmithNetworkConnectionsSearchTab.Controls.Add($SmithNetworkEndpointPcapCaptureDurationLabel)


        $SmithNetworkEndpointPacketCaptureDurationTextBox = New-Object System.Windows.Forms.TextBox -Property @{
            Text     = "60"
            Location = @{ X = $SmithNetworkEndpointPcapCaptureDurationLabel.Location.X + $SmithNetworkEndpointPcapCaptureDurationLabel.Size.Width
                          Y = $SmithNetworkEndpointPcapCaptureDurationLabel.Location.Y - $($FormScale * 2) }
            Size     = @{ Width  = $FormScale * 30
                          Height = $FormScale * 22 }
            Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $SmithNetworkConnectionsSearchTab.Controls.Add($SmithNetworkEndpointPacketCaptureDurationTextBox)


        $SmithNetworkEndpointPcapCaptureMaxSizeLabel = New-Object System.Windows.Forms.Label -Property @{
            Text     = "Max (MB)"
            Location = @{ X = $SmithNetworkEndpointPacketCaptureDurationTextBox.Location.X + $SmithNetworkEndpointPacketCaptureDurationTextBox.Size.Width + $($FormScale * 35)
                          Y = $SmithNetworkEndpointPacketCaptureDurationTextBox.Location.Y + $($FormScale * 2) }
            Size     = @{ Width  = $FormScale * 60
                          Height = $FormScale * 22 }
            Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $SmithNetworkConnectionsSearchTab.Controls.Add($SmithNetworkEndpointPcapCaptureMaxSizeLabel)


        $SmithNetworkEndpointPacketCaptureMaxSizeTextBox = New-Object System.Windows.Forms.TextBox -Property @{
            Text     = "50"
            Location = @{ X = $SmithNetworkEndpointPcapCaptureMaxSizeLabel.Location.X + $SmithNetworkEndpointPcapCaptureMaxSizeLabel.Size.Width
                          Y = $SmithNetworkEndpointPcapCaptureMaxSizeLabel.Location.Y - $($FormScale * 2) }
            Size     = @{ Width  = $FormScale * 30
                          Height = $FormScale * 22 }
            Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $SmithNetworkConnectionsSearchTab.Controls.Add($SmithNetworkEndpointPacketCaptureMaxSizeTextBox)


        $SmithNetworkConnectionSearchRemoteIPAddressCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
            Text     = "Remote IP (WinRM)"
            Location = @{ X = $FormScale * 3
                          Y = $SmithNetworkEndpointPacketCaptureCheckBox.Location.Y + $SmithNetworkEndpointPacketCaptureCheckBox.Size.Height + $($FormScale * 10) }
            Size     = @{ Width  = $FormScale * 180
                          Height = $FormScale * 22 }
            Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
            ForeColor = 'Blue'
            Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
        }
        $SmithNetworkConnectionsSearchTab.Controls.Add($SmithNetworkConnectionSearchRemoteIPAddressCheckbox)


        $SmithNetworkConnectionSearchRemoteIPAddressSelectionButton = New-Object System.Windows.Forms.Button -Property @{
            Text      = "Select IP Addresses"
            Location = @{ X = $SmithNetworkConnectionSearchRemoteIPAddressCheckbox.Location.X
                          Y = $SmithNetworkConnectionSearchRemoteIPAddressCheckbox.Location.Y + $SmithNetworkConnectionSearchRemoteIPAddressCheckbox.Size.Height + $($FormScale * 3) }
            Size     = @{ Width  = $FormScale * 180
                          Height = $FormScale * 20 }
            Add_Click = $SmithNetworkConnectionSearchRemoteIPAddressSelectionButtonAdd_Click
        }
        $SmithNetworkConnectionsSearchTab.Controls.Add($SmithNetworkConnectionSearchRemoteIPAddressSelectionButton)
        CommonButtonSettings -Button $SmithNetworkConnectionSearchRemoteIPAddressSelectionButton


        $SmithNetworkConnectionSearchRemoteIPAddressRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Lines     = "Enter Remote IPs; One Per Line"
            Location = @{ X = $SmithNetworkConnectionSearchRemoteIPAddressSelectionButton.Location.X
                          Y = $SmithNetworkConnectionSearchRemoteIPAddressSelectionButton.Location.Y + $SmithNetworkConnectionSearchRemoteIPAddressSelectionButton.Size.Height + $($FormScale * 5) }
            Size     = @{ Width  = $FormScale * 180
                          Height = $FormScale * 115 }
            Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            MultiLine  = $True
            ScrollBars = "Vertical"
            WordWrap   = $True
            ShortcutsEnabled = $true
            Add_MouseEnter = $SmithNetworkConnectionSearchRemoteIPAddressRichTextboxAdd_MouseEnter
            Add_MouseLeave = $SmithNetworkConnectionSearchRemoteIPAddressRichTextboxAdd_MouseLeave
            Add_MouseHover = $SmithNetworkConnectionSearchRemoteIPAddressRichTextboxAdd_MouseHover
        }
        $SmithNetworkConnectionsSearchTab.Controls.Add($SmithNetworkConnectionSearchRemoteIPAddressRichTextbox)


$SmithNetworkConnectionSearchRemotePortCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Remote Port"
    Location = @{ X = $SmithNetworkConnectionSearchRemoteIPAddressCheckbox.Location.X + $SmithNetworkConnectionSearchRemoteIPAddressCheckbox.Size.Width + $($FormScale * 10)
                  Y = $SmithNetworkConnectionSearchRemoteIPAddressCheckbox.Location.Y }
    Size     = @{ Width  = $FormScale * 115
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
}
$SmithNetworkConnectionsSearchTab.Controls.Add($SmithNetworkConnectionSearchRemotePortCheckbox)


        $SmithNetworkConnectionSearchRemotePortSelectionButton = New-Object System.Windows.Forms.Button -Property @{
            Text      = "Select Ports"
            Location = @{ X = $SmithNetworkConnectionSearchRemotePortCheckbox.Location.X
                          Y = $SmithNetworkConnectionSearchRemotePortCheckbox.Location.Y + $SmithNetworkConnectionSearchRemotePortCheckbox.Size.Height + $($FormScale * 3) }
            Size     = @{ Width  = $FormScale * 115
                          Height = $FormScale * 20 }
            Add_Click = $SmithNetworkConnectionSearchRemotePortSelectionButtonAdd_Click
        }
        $SmithNetworkConnectionsSearchTab.Controls.Add($SmithNetworkConnectionSearchRemotePortSelectionButton)
        CommonButtonSettings -Button $SmithNetworkConnectionSearchRemotePortSelectionButton


        $SmithNetworkConnectionSearchRemotePortRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Lines     = "Enter Remote Ports; One Per Line"
            Location = @{ X = $SmithNetworkConnectionSearchRemotePortSelectionButton.Location.X
                          Y = $SmithNetworkConnectionSearchRemotePortSelectionButton.Location.Y + $SmithNetworkConnectionSearchRemotePortSelectionButton.Size.Height + $($FormScale * 5) }
            Size     = @{ Width  = $FormScale * 115
                          Height = $FormScale * 115 }
            Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            MultiLine  = $True
            ScrollBars = "Vertical"
            WordWrap   = $True
            ShortcutsEnabled = $true
            Add_MouseEnter = $SmithNetworkConnectionSearchRemotePortRichTextboxAdd_MouseEnter
            Add_MouseLeave = $SmithNetworkConnectionSearchRemotePortRichTextboxAdd_MouseLeave
            Add_MouseHover = $SmithNetworkConnectionSearchRemotePortRichTextboxAdd_MouseHover
        }
        $SmithNetworkConnectionsSearchTab.Controls.Add($SmithNetworkConnectionSearchRemotePortRichTextbox)


$SmithNetworkConnectionSearchLocalPortCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Local Port"
    Location = @{ X = $SmithNetworkConnectionSearchRemotePortCheckbox.Location.X + $SmithNetworkConnectionSearchRemotePortCheckbox.Size.Width + $($FormScale * 10)
                  Y = $SmithNetworkConnectionSearchRemotePortCheckbox.Location.Y }
    Size     = @{ Width  = $FormScale * 115
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
}
$SmithNetworkConnectionsSearchTab.Controls.Add($SmithNetworkConnectionSearchLocalPortCheckbox)


        $SmithNetworkConnectionSearchLocalPortSelectionButton = New-Object System.Windows.Forms.Button -Property @{
            Text      = "Select Ports"
            Location = @{ X = $SmithNetworkConnectionSearchLocalPortCheckbox.Location.X
                          Y = $SmithNetworkConnectionSearchLocalPortCheckbox.Location.Y + $SmithNetworkConnectionSearchLocalPortCheckbox.Size.Height + $($FormScale * 3) }
            Size     = @{ Width  = $FormScale * 115
                          Height = $FormScale * 20 }
            Add_Click = $SmithNetworkConnectionSearchLocalPortSelectionButtonAdd_Click
        }
        $SmithNetworkConnectionsSearchTab.Controls.Add($SmithNetworkConnectionSearchLocalPortSelectionButton)
        CommonButtonSettings -Button $SmithNetworkConnectionSearchLocalPortSelectionButton


        $SmithNetworkConnectionSearchLocalPortRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Lines     = "Enter Local Ports; One Per Line"
            Location = @{ X = $SmithNetworkConnectionSearchLocalPortSelectionButton.Location.X
                          Y = $SmithNetworkConnectionSearchLocalPortSelectionButton.Location.Y  + $SmithNetworkConnectionSearchLocalPortSelectionButton.Size.Height + $($FormScale * 5) }
            Size     = @{ Width  = $FormScale * 115
                          Height = $FormScale * 115 }
            Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            MultiLine  = $True
            ScrollBars = "Vertical"
            WordWrap   = $True
            #BorderStyle = 'Fixed3d' #Fixed3D, FixedSingle, none
            ShortcutsEnabled = $true
            Add_MouseEnter = $SmithNetworkConnectionSearchLocalPortRichTextboxAdd_MouseEnter
            Add_MouseLeave = $SmithNetworkConnectionSearchLocalPortRichTextboxAdd_MouseLeave
            Add_MouseHover = $SmithNetworkConnectionSearchLocalPortRichTextboxAdd_MouseHover
        }
        $SmithNetworkConnectionsSearchTab.Controls.Add($SmithNetworkConnectionSearchLocalPortRichTextbox)


$SmithNetworkConnectionSearchProcessCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Process Name (WinRM)"
    Location = @{ X = $FormScale * 3
                  Y = $SmithNetworkConnectionSearchRemoteIPAddressRichTextbox.Location.Y + $SmithNetworkConnectionSearchRemoteIPAddressRichTextbox.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 430
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
}
$SmithNetworkConnectionsSearchTab.Controls.Add($SmithNetworkConnectionSearchProcessCheckbox)

            $SmithNetworkConnectionSearchProcessLabel = New-Object System.Windows.Forms.Label -Property @{
                Text     = "Check hosts for connections created by a given process."
                Location = @{ X = $FormScale * 3
                              Y = $SmithNetworkConnectionSearchProcessCheckbox.Location.Y + $SmithNetworkConnectionSearchProcessCheckbox.Size.Height + $($FormScale * 3) }
                Size     = @{ Width  = $FormScale * 430
                              Height = $FormScale * 22 }
                ForeColor = "Black"
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            }
            $SmithNetworkConnectionsSearchTab.Controls.Add($SmithNetworkConnectionSearchProcessLabel)


            $SmithNetworkConnectionSearchProcessRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
                Lines    = "Enter Process Names; One Per Line"
                Location = @{ X = $FormScale * 3
                              Y = $SmithNetworkConnectionSearchProcessLabel.Location.Y + $SmithNetworkConnectionSearchProcessLabel.Size.Height + $($FormScale * 5) }
                Size     = @{ Width  = $FormScale * 430
                              Height = $FormScale * 100 }
                Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                MultiLine     = $True
                ScrollBars    = "Vertical"
                WordWrap      = $True
                ShortcutsEnabled = $true
                Add_MouseHover   = $SmithNetworkConnectionSearchProcessRichTextboxAdd_MouseHover
                Add_MouseEnter   = $SmithNetworkConnectionSearchProcessRichTextboxAdd_MouseEnter
                Add_MouseLeave   = $SmithNetworkConnectionSearchProcessRichTextboxAdd_MouseLeave
            }
            $SmithNetworkConnectionsSearchTab.Controls.Add($SmithNetworkConnectionSearchProcessRichTextbox)


$SmithNetworkConnectionSearchDNSCacheCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "DNS Cache Entry (WinRM)"
    Location = @{ X = $FormScale * 3
                  Y = $SmithNetworkConnectionSearchProcessRichTextbox.Location.Y + $SmithNetworkConnectionSearchProcessRichTextbox.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 430
                  Height = $FormScale * 22 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
}
$SmithNetworkConnectionsSearchTab.Controls.Add($SmithNetworkConnectionSearchDNSCacheCheckbox)

            $SmithNetworkConnectionSearchDNSCacheLabel = New-Object System.Windows.Forms.Label -Property @{
                Text     = "Check hosts' DNS Cache for entries that match given criteria."
                Location = @{ X = $FormScale * 3
                              Y = $SmithNetworkConnectionSearchDNSCacheCheckbox.Location.Y + $SmithNetworkConnectionSearchDNSCacheCheckbox.Size.Height + $($FormScale * 3) }
                Size     = @{ Width  = $FormScale * 430
                              Height = $FormScale * 22 }
                Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
            }
            $SmithNetworkConnectionsSearchTab.Controls.Add($SmithNetworkConnectionSearchDNSCacheLabel)


            $SmithNetworkConnectionSearchDNSCacheRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
                Lines     = "Enter DNS query information or IP addresses; One Per Line"
                Location = @{ X = $FormScale * 3
                              Y = $SmithNetworkConnectionSearchDNSCacheLabel.Location.Y + $SmithNetworkConnectionSearchDNSCacheLabel.Size.Height + $($FormScale * 5) }
                Size     = @{ Width  = $FormScale * 430
                              Height = $FormScale * 100 }
                Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                MultiLine  = $True
                ScrollBars = "Vertical"
                WordWrap   = $True
                ShortcutsEnabled = $true
                Add_MouseEnter = $SmithNetworkConnectionSearchDNSCacheRichTextboxAdd_MouseEnter
                Add_MouseLeave = $SmithNetworkConnectionSearchDNSCacheRichTextboxAdd_MouseLeave
                Add_MouseHover = $SmithNetworkConnectionSearchDNSCacheRichTextboxAdd_MouseHover
            }
            $SmithNetworkConnectionsSearchTab.Controls.Add($SmithNetworkConnectionSearchDNSCacheRichTextbox)
