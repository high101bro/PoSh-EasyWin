
$Section1PacketCaptureTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = "Packet Capture"
    Left   = $FormScale * 3
    Top    = $FormScale * -10
    Width  = $FormScale * 450
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
}
$MainLeftCollectionsTabControl.Controls.Add($Section1PacketCaptureTab)



$NetworkEndpointPacketCaptureNetshTraceGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Left   = $FormScale * 3
    Top    = $FormScale * 5
    Width  = $FormScale * 435
    Height = $FormScale * 65
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
}

        $NetworkEndpointPacketCaptureCheckBox = New-Object System.Windows.Forms.CheckBox -Property @{
            Text     = "Packet Capture using netsh.exe (Windows XP+ / Server 2003+)"
            Left     = $FormScale * 7
            Top      = $FormScale * 3
            Autosize = $true
            Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
            ForeColor = 'Blue'
            Add_Click = {
                Update-QueryCount
                
                Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes 
                if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
            }
        }
        $Section1PacketCaptureTab.Controls.Add($NetworkEndpointPacketCaptureCheckBox)

<#
            $NetworkEndpointPcapCaptureSourceIPCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
                Text   = "Source IP Address:"
                Left   = $FormScale * 7
                Top    = $FormScale * 20
                Width  = $FormScale * 135
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
            }
            $NetworkEndpointPacketCaptureNetshTraceGroupBox.Controls.Add($NetworkEndpointPcapCaptureSourceIPCheckbox)


                    $NetworkEndpointPacketCaptureSourceIPRichTextBox = New-Object System.Windows.Forms.RichTextBox -Property @{
                        Text   = "127.0.0.1`n0.0.0.0"
                        Left   = $NetworkEndpointPcapCaptureSourceIPCheckbox.Left
                        Top    = $NetworkEndpointPcapCaptureSourceIPCheckbox.Top + $NetworkEndpointPcapCaptureSourceIPCheckbox.Height
                        Width  = $FormScale * 135
                        Height = $FormScale * 65
                        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                        ForeColor = 'Black'
                        Multiline = $true
                        ScrollBars = 'Vertical'
                        ShortcutsEnabled = $true
                    }
                    $NetworkEndpointPacketCaptureNetshTraceGroupBox.Controls.Add($NetworkEndpointPacketCaptureSourceIPRichTextBox)


            $NetworkEndpointPcapCaptureSourceMACCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
                Text   = "Source MAC:"
                Left   = $NetworkEndpointPacketCaptureSourceIPRichTextBox.Left 
                Top    = $NetworkEndpointPacketCaptureSourceIPRichTextBox.Top + $NetworkEndpointPacketCaptureSourceIPRichTextBox.Height + $($FormScale * 5)
                Width  = $FormScale * 135
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
            }
            $NetworkEndpointPacketCaptureNetshTraceGroupBox.Controls.Add($NetworkEndpointPcapCaptureSourceMACCheckbox)


                    $NetworkEndpointPacketCaptureSourceMACRichTextBox = New-Object System.Windows.Forms.RichTextBox -Property @{
                        Text   = "00-00-00-00-00-00`nFF-FF-FF-FF-FF-FF"
                        Left   = $NetworkEndpointPcapCaptureSourceMACCheckbox.Left
                        Top    = $NetworkEndpointPcapCaptureSourceMACCheckbox.Top + $NetworkEndpointPcapCaptureSourceMACCheckbox.Height
                        Width  = $FormScale * 135
                        Height = $FormScale * 65
                        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                        ForeColor = 'Black'
                        Multiline = $true
                        ScrollBars = 'Vertical'
                        ShortcutsEnabled = $true
                    }
                    $NetworkEndpointPacketCaptureNetshTraceGroupBox.Controls.Add($NetworkEndpointPacketCaptureSourceMACRichTextBox)



            $NetworkEndpointPcapCaptureDestinationIPCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
                Text   = "Destination IP Address:"
                Left   = $NetworkEndpointPcapCaptureSourceIPCheckbox.Left + $NetworkEndpointPcapCaptureSourceIPCheckbox.Width + $($FormScale * 10) 
                Top    = $NetworkEndpointPcapCaptureSourceIPCheckbox.Top 
                Width  = $FormScale * 135
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
            }
            $NetworkEndpointPacketCaptureNetshTraceGroupBox.Controls.Add($NetworkEndpointPcapCaptureDestinationIPCheckbox)


                    $NetworkEndpointPacketCaptureDestinationIPRichTextBox = New-Object System.Windows.Forms.RichTextBox -Property @{
                        Text   = "127.0.0.1`n0.0.0.0"
                        Left   = $NetworkEndpointPcapCaptureDestinationIPCheckbox.Left
                        Top    = $NetworkEndpointPcapCaptureDestinationIPCheckbox.Top + $NetworkEndpointPcapCaptureDestinationIPCheckbox.Height
                        Width  = $FormScale * 135
                        Height = $FormScale * 65
                        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                        ForeColor = 'Black'
                        Multiline = $true
                        ScrollBars = 'Vertical'
                        ShortcutsEnabled = $true
                    }
                    $NetworkEndpointPacketCaptureNetshTraceGroupBox.Controls.Add($NetworkEndpointPacketCaptureDestinationIPRichTextBox)


            $NetworkEndpointPcapCaptureDestinationMACCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
                Text   = "Destination MAC:"
                Left   = $NetworkEndpointPacketCaptureDestinationIPRichTextBox.Left 
                Top    = $NetworkEndpointPacketCaptureDestinationIPRichTextBox.Top + $NetworkEndpointPacketCaptureDestinationIPRichTextBox.Height + $($FormScale * 5)
                Width  = $FormScale * 135
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
            }
            $NetworkEndpointPacketCaptureNetshTraceGroupBox.Controls.Add($NetworkEndpointPcapCaptureDestinationMACCheckbox)


                    $NetworkEndpointPacketCaptureDestinationMACRichTextBox = New-Object System.Windows.Forms.RichTextBox -Property @{
                        Text   = "00-00-00-00-00-00`nFF-FF-FF-FF-FF-FF"
                        Left   = $NetworkEndpointPcapCaptureDestinationMACCheckbox.Left
                        Top    = $NetworkEndpointPcapCaptureDestinationMACCheckbox.Top + $NetworkEndpointPcapCaptureDestinationMACCheckbox.Height
                        Width  = $FormScale * 135
                        Height = $FormScale * 65
                        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                        ForeColor = 'Black'
                        Multiline = $true
                        ScrollBars = 'Vertical'
                        ShortcutsEnabled = $true
                    }
                    $NetworkEndpointPacketCaptureNetshTraceGroupBox.Controls.Add($NetworkEndpointPacketCaptureDestinationMACRichTextBox)
#>

            $NetworkEndpointPcapCaptureDurationLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Duration (secs):"
                Left   = $FormScale * 7
                Top    = $FormScale * 20
#                Left   = $NetworkEndpointPcapCaptureDestinationIPCheckbox.Left + $NetworkEndpointPcapCaptureDestinationIPCheckbox.Width + $($FormScale * 10) 
#                Top    = $NetworkEndpointPcapCaptureDestinationIPCheckbox.Top 
                Width  = $FormScale * 90
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
            }
            $NetworkEndpointPacketCaptureNetshTraceGroupBox.Controls.Add($NetworkEndpointPcapCaptureDurationLabel)


                    $NetworkEndpointPacketCaptureDurationComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
                        Text   = "15 seconds"
                        Left   = $NetworkEndpointPcapCaptureDurationLabel.Left
                        Top    = $NetworkEndpointPcapCaptureDurationLabel.Top + $NetworkEndpointPcapCaptureDurationLabel.Height
                        Width  = $FormScale * 90
                        Height = $FormScale * 22
                        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                        ForeColor = 'Black'
                    }
                    $NetworkEndpointPacketCaptureNetshTraceGroupBox.Controls.Add($NetworkEndpointPacketCaptureDurationComboBox)
                    $NetworkEndpointPacketCaptureDurationComboBox.Items.Add("15 seconds")
                    $NetworkEndpointPacketCaptureDurationComboBox.Items.Add("30 seconds")
                    $NetworkEndpointPacketCaptureDurationComboBox.Items.Add("60 seconds")
                    $NetworkEndpointPacketCaptureDurationComboBox.Items.Add("2  minutes")
                    $NetworkEndpointPacketCaptureDurationComboBox.Items.Add("5  minutes")
                    $NetworkEndpointPacketCaptureDurationComboBox.Items.Add("10 minutes")
                    $NetworkEndpointPacketCaptureDurationComboBox.Items.Add("15 minutes")
                    $NetworkEndpointPacketCaptureDurationComboBox.Items.Add("30 minutes")
                    $NetworkEndpointPacketCaptureDurationComboBox.Items.Add("60 minutes")
                    $NetworkEndpointPacketCaptureDurationComboBox.Items.Add("2  hours")
                    $NetworkEndpointPacketCaptureDurationComboBox.Items.Add("3  hours")
                    $NetworkEndpointPacketCaptureDurationComboBox.Items.Add("6  hours")
                    $NetworkEndpointPacketCaptureDurationComboBox.Items.Add("9  hours")
                    $NetworkEndpointPacketCaptureDurationComboBox.Items.Add("12 hours")


            $NetworkEndpointPcapCaptureMaxSizeLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Max (MB):"
                Left   = $NetworkEndpointPcapCaptureDurationLabel.Left + $NetworkEndpointPcapCaptureDurationLabel.Width + $($FormScale * 10) 
                Top    = $NetworkEndpointPcapCaptureDurationLabel.Top 
                Width  = $FormScale * 60
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
            }
            $NetworkEndpointPacketCaptureNetshTraceGroupBox.Controls.Add($NetworkEndpointPcapCaptureMaxSizeLabel)


                    $NetworkEndpointPacketCaptureMaxSizeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
                        Text   = "50"
                        Left   = $NetworkEndpointPcapCaptureMaxSizeLabel.Left
                        Top    = $NetworkEndpointPcapCaptureMaxSizeLabel.Top + $NetworkEndpointPcapCaptureMaxSizeLabel.Height
                        Width  = $FormScale * 60
                        Height = $FormScale * 22
                        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                        ForeColor = 'Black'
                    }
                    $NetworkEndpointPacketCaptureNetshTraceGroupBox.Controls.Add($NetworkEndpointPacketCaptureMaxSizeComboBox)
                    $NetworkEndpointPacketCaptureMaxSizeComboBox.Items.Add("10")
                    $NetworkEndpointPacketCaptureMaxSizeComboBox.Items.Add("25")
                    $NetworkEndpointPacketCaptureMaxSizeComboBox.Items.Add("50")
                    $NetworkEndpointPacketCaptureMaxSizeComboBox.Items.Add("100")
                    $NetworkEndpointPacketCaptureMaxSizeComboBox.Items.Add("250")
                    $NetworkEndpointPacketCaptureMaxSizeComboBox.Items.Add("500")
                    $NetworkEndpointPacketCaptureMaxSizeComboBox.Items.Add("1000")


            $NetworkEndpointPcapCaptureCaptureTypeLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Capture Type:"
                Left   = $NetworkEndpointPcapCaptureMaxSizeLabel.Left + $NetworkEndpointPcapCaptureMaxSizeLabel.Width + $($FormScale * 10) 
                Top    = $NetworkEndpointPcapCaptureMaxSizeLabel.Top
                Width  = $FormScale * 80
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
            }
            $NetworkEndpointPacketCaptureNetshTraceGroupBox.Controls.Add($NetworkEndpointPcapCaptureCaptureTypeLabel)


                    $NetworkEndpointPacketCaptureCaptureTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
                        Text   = "physical"
                        Left   = $NetworkEndpointPcapCaptureCaptureTypeLabel.Left
                        Top    = $NetworkEndpointPcapCaptureCaptureTypeLabel.Top + $NetworkEndpointPcapCaptureCaptureTypeLabel.Height
                        Width  = $FormScale * 80
                        Height = $FormScale * 50
                        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                        ForeColor = 'Black'
                    }
                    $NetworkEndpointPacketCaptureNetshTraceGroupBox.Controls.Add($NetworkEndpointPacketCaptureCaptureTypeComboBox)
                    $NetworkEndpointPacketCaptureCaptureTypeComboBox.Items.Add("physical")
                    $NetworkEndpointPacketCaptureCaptureTypeComboBox.Items.Add("vmswitch")
                    $NetworkEndpointPacketCaptureCaptureTypeComboBox.Items.Add("both")


            $NetworkEndpointPcapCaptureEtherTypeLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Ether Type:"
                Left   = $NetworkEndpointPcapCaptureCaptureTypeLabel.Left + $NetworkEndpointPcapCaptureCaptureTypeLabel.Width + $($FormScale * 10) 
                Top    = $NetworkEndpointPcapCaptureCaptureTypeLabel.Top
                Width  = $FormScale * 75
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
            }
            $NetworkEndpointPacketCaptureNetshTraceGroupBox.Controls.Add($NetworkEndpointPcapCaptureEtherTypeLabel)


                    $NetworkEndpointPacketCaptureEtherTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
                        Text   = 'No Filter'
                        Left   = $NetworkEndpointPcapCaptureEtherTypeLabel.Left
                        Top    = $NetworkEndpointPcapCaptureEtherTypeLabel.Top + $NetworkEndpointPcapCaptureEtherTypeLabel.Height
                        Width  = $FormScale * 75
                        Height = $FormScale * 50
                        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                        ForeColor = 'Black'
                    }
                    $NetworkEndpointPacketCaptureNetshTraceGroupBox.Controls.Add($NetworkEndpointPacketCaptureEtherTypeComboBox)
                    $NetworkEndpointPacketCaptureEtherTypeComboBox.Items.Add("No Filter")
                    $NetworkEndpointPacketCaptureEtherTypeComboBox.Items.Add("IPv4")
                    $NetworkEndpointPacketCaptureEtherTypeComboBox.Items.Add("IPv6")
                    $NetworkEndpointPacketCaptureEtherTypeComboBox.Items.Add("0x0800")
                    $NetworkEndpointPacketCaptureEtherTypeComboBox.Items.Add("0x86DD")
                    $NetworkEndpointPacketCaptureEtherTypeComboBox.Items.Add("0x0806")


            $NetworkEndpointPcapCaptureProtocolButton = New-Object System.Windows.Forms.Button -Property @{
                Text   = "ref"
                Left   = $NetworkEndpointPcapCaptureEtherTypeLabel.Left + $NetworkEndpointPcapCaptureEtherTypeLabel.Width + $($FormScale * 10) + $($FormScale * 53) 
                Top    = $NetworkEndpointPcapCaptureEtherTypeLabel.Top - $($FormScale * 3)
                Width  = $FormScale * 22
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 9),0,0,0)
                ForeColor = 'Black'
                Add_click = {
                    Import-Csv -Path "$Dependencies\Protocol Numbers.csv" | Out-GridView -Title "PoSh-EasyWin - IANA Protocol Numbers"
                }
            }
            $NetworkEndpointPacketCaptureNetshTraceGroupBox.Controls.Add($NetworkEndpointPcapCaptureProtocolButton)
            Apply-CommonButtonSettings -Button $NetworkEndpointPcapCaptureProtocolButton


            $NetworkEndpointPcapCaptureProtocolLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Protocol:"
                Left   = $NetworkEndpointPcapCaptureEtherTypeLabel.Left + $NetworkEndpointPcapCaptureEtherTypeLabel.Width + $($FormScale * 10) 
                Top    = $NetworkEndpointPcapCaptureEtherTypeLabel.Top
                Width  = $FormScale * 75
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
            }
            $NetworkEndpointPacketCaptureNetshTraceGroupBox.Controls.Add($NetworkEndpointPcapCaptureProtocolLabel)


                    $NetworkEndpointPacketCaptureProtocolComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
                        Text   = 'No Filter'
                        Left   = $NetworkEndpointPcapCaptureProtocolLabel.Left
                        Top    = $NetworkEndpointPcapCaptureProtocolLabel.Top + $NetworkEndpointPcapCaptureProtocolLabel.Height
                        Width  = $FormScale * 75
                        Height = $FormScale * 50
                        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                        ForeColor = 'Black'
                    }
                    $NetworkEndpointPacketCaptureNetshTraceGroupBox.Controls.Add($NetworkEndpointPacketCaptureProtocolComboBox)
                    $NetworkEndpointPacketCaptureProtocolComboBox.Items.Add("No Filter")
                    $NetworkEndpointPacketCaptureProtocolComboBox.Items.Add("TCP")
                    $NetworkEndpointPacketCaptureProtocolComboBox.Items.Add("UDP")
                    $NetworkEndpointPacketCaptureProtocolComboBox.Items.Add("ICMP")
                    $NetworkEndpointPacketCaptureProtocolComboBox.Items.Add("1")
                    $NetworkEndpointPacketCaptureProtocolComboBox.Items.Add("6")
                    $NetworkEndpointPacketCaptureProtocolComboBox.Items.Add("17")
                    $NetworkEndpointPacketCaptureProtocolComboBox.Items.Add("(1,6,17)")
                    $NetworkEndpointPacketCaptureProtocolComboBox.Items.Add("Type in your own")        
                    

                    
<#
            $NetworkEndpointPcapCaptureSeverityLevelCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
                Text   = "Severity Level:"
                Left   = $NetworkEndpointPacketCaptureProtocolComboBox.Left
                Top    = $NetworkEndpointPacketCaptureProtocolComboBox.Top  + $NetworkEndpointPacketCaptureProtocolComboBox.Height + $($FormScale * 5) 
                Width  = $FormScale * 125
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
            }
            $NetworkEndpointPacketCaptureNetshTraceGroupBox.Controls.Add($NetworkEndpointPcapCaptureSeverityLevelCheckbox)


                    $NetworkEndpointPacketCaptureSeverityLevelComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
                        Left   = $NetworkEndpointPcapCaptureSeverityLevelCheckbox.Left
                        Top    = $NetworkEndpointPcapCaptureSeverityLevelCheckbox.Top + $NetworkEndpointPcapCaptureSeverityLevelCheckbox.Height
                        Width  = $FormScale * 125
                        Height = $FormScale * 50
                        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                        ForeColor = 'Black'
                    }
                    $NetworkEndpointPacketCaptureNetshTraceGroupBox.Controls.Add($NetworkEndpointPacketCaptureSeverityLevelComboBox)
                    #$NetworkEndpointPacketCaptureSeverityLevelComboBox.Items.Add("")
                    $NetworkEndpointPacketCaptureSeverityLevelComboBox.Items.Add("5-Verbose (All Events)")
                    $NetworkEndpointPacketCaptureSeverityLevelComboBox.Items.Add("4-Informational-Critical")
                    $NetworkEndpointPacketCaptureSeverityLevelComboBox.Items.Add("3-Warnings-Critical")
                    $NetworkEndpointPacketCaptureSeverityLevelComboBox.Items.Add("2-Errors,Critical")
                    $NetworkEndpointPacketCaptureSeverityLevelComboBox.Items.Add("1-Only Critical")
#>
                    
$Section1PacketCaptureTab.Controls.Add($NetworkEndpointPacketCaptureNetshTraceGroupBox)



# Provides messages when hovering over various areas in the GUI
Update-FormProgress "$Dependencies\Code\Main Body\Launch-PktMon.ps1"
. "$Dependencies\Code\Main Body\Launch-PktMon.ps1"

$NetworkEndpointPacketCaptureGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text   = "Packet Capture using PktMon.exe (Windows 10+ / Server 2019+)"
    Left   = $FormScale * 3
    Top    = $NetworkEndpointPacketCaptureNetshTraceGroupBox.Top + $NetworkEndpointPacketCaptureNetshTraceGroupBox.Height + $($FormScale * 10)
    Width  = $FormScale * 435
    Height = $FormScale * 125
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
}

            $PacketCapturePktMonTextbox = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Packet Monitor (Pktmon) is an in-box, cross-component network diagnostics tool for Windows. It can be used for packet capture, packet drop detection, packet filtering and counting. In addtion to traditionaly hardware based systems, this tool is especially helpful in virtualization scenarios, like container networking and SDN, because it provides visibility within the networking stack."
                Left   = $FormScale * 7
                Top    = $FormScale * 18
                Width  = $FormScale * 430
                Height = $FormScale * 75
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
            }
            $NetworkEndpointPacketCaptureGroupBox.Controls.Add($PacketCapturePktMonTextbox)

                    
            $PacketCapturePktMonLaunchButton = New-Object System.Windows.Forms.Button -Property @{
                Text   = 'Launch PktMon GUI'
                Left   = $PacketCapturePktMonTextbox.Left
                Top    = $PacketCapturePktMonTextbox.Top + $PacketCapturePktMonTextbox.Height + $($FormScale * 5) 
                Width  = $FormScale * 125
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
                Add_Click = {
                    if ($script:ComputerList.Count -gt 0) {
                        Launch-PktMon
                    }
                    else {
                        [System.Windows.Forms.MessageBox]::Show("You need to select one or more endpoints first.","PoSh-EasyWin",'Ok',"Info")
                    }
                }
            }
            $NetworkEndpointPacketCaptureGroupBox.Controls.Add($PacketCapturePktMonLaunchButton)
            Apply-CommonButtonSettings -Button $PacketCapturePktMonLaunchButton


$Section1PacketCaptureTab.Controls.Add($NetworkEndpointPacketCaptureGroupBox)








