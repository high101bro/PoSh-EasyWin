
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
    Height = $FormScale * 205
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
}

        $NetworkEndpointPacketCaptureCheckBox = New-Object System.Windows.Forms.CheckBox -Property @{
            Text     = "Endpoint Packet Capture Using netsh.exe"
            Left     = $FormScale * 7
            Top      = $FormScale * 3
            Autosize = $true
            Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
            ForeColor = 'Blue'
            Add_Click = { 
                Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands 
                if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
            }
        }
        $Section1PacketCaptureTab.Controls.Add($NetworkEndpointPacketCaptureCheckBox)


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


                    $NetworkEndpointPacketCaptureSourceIPRichTextBox = New-Object System.Windows.Forms.RichTextBox -Property @{
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
                    $NetworkEndpointPacketCaptureNetshTraceGroupBox.Controls.Add($NetworkEndpointPacketCaptureSourceIPRichTextBox)



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


            $NetworkEndpointPcapCaptureDurationLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Seconds:"
                Left   = $NetworkEndpointPcapCaptureDestinationIPCheckbox.Left + $NetworkEndpointPcapCaptureDestinationIPCheckbox.Width + $($FormScale * 10) 
                Top    = $NetworkEndpointPcapCaptureDestinationIPCheckbox.Top 
                Width  = $FormScale * 60
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
            }
            $NetworkEndpointPacketCaptureNetshTraceGroupBox.Controls.Add($NetworkEndpointPcapCaptureDurationLabel)


                    $NetworkEndpointPacketCaptureDurationTextBox = New-Object System.Windows.Forms.ComboBox -Property @{
                        Text   = "60"
                        Left   = $NetworkEndpointPcapCaptureDurationLabel.Left
                        Top    = $NetworkEndpointPcapCaptureDurationLabel.Top + $NetworkEndpointPcapCaptureDurationLabel.Height
                        Width  = $FormScale * 60
                        Height = $FormScale * 22
                        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                        ForeColor = 'Black'
                    }
                    $NetworkEndpointPacketCaptureNetshTraceGroupBox.Controls.Add($NetworkEndpointPacketCaptureDurationTextBox)
                    $NetworkEndpointPacketCaptureDurationTextBox.Items.Add("15")
                    $NetworkEndpointPacketCaptureDurationTextBox.Items.Add("30")
                    $NetworkEndpointPacketCaptureDurationTextBox.Items.Add("60")
                    $NetworkEndpointPacketCaptureDurationTextBox.Items.Add("120")
                    $NetworkEndpointPacketCaptureDurationTextBox.Items.Add("300")
                    $NetworkEndpointPacketCaptureDurationTextBox.Items.Add("600")


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


                    $NetworkEndpointPacketCaptureMaxSizeTextBox = New-Object System.Windows.Forms.ComboBox -Property @{
                        Text   = "50"
                        Left   = $NetworkEndpointPcapCaptureMaxSizeLabel.Left
                        Top    = $NetworkEndpointPcapCaptureMaxSizeLabel.Top + $NetworkEndpointPcapCaptureMaxSizeLabel.Height
                        Width  = $FormScale * 55
                        Height = $FormScale * 22
                        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                        ForeColor = 'Black'
                    }
                    $NetworkEndpointPacketCaptureNetshTraceGroupBox.Controls.Add($NetworkEndpointPacketCaptureMaxSizeTextBox)
                    $NetworkEndpointPacketCaptureMaxSizeTextBox.Items.Add("10")
                    $NetworkEndpointPacketCaptureMaxSizeTextBox.Items.Add("25")
                    $NetworkEndpointPacketCaptureMaxSizeTextBox.Items.Add("50")
                    $NetworkEndpointPacketCaptureMaxSizeTextBox.Items.Add("100")
                    $NetworkEndpointPacketCaptureMaxSizeTextBox.Items.Add("250")
                    $NetworkEndpointPacketCaptureMaxSizeTextBox.Items.Add("500")
                    $NetworkEndpointPacketCaptureMaxSizeTextBox.Items.Add("1000")


            $NetworkEndpointPcapCaptureEtherTypeCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
                Text   = "Ether Type:"
                Left   = $NetworkEndpointPacketCaptureDurationTextBox.Left 
                Top    = $NetworkEndpointPacketCaptureDurationTextBox.Top + $NetworkEndpointPacketCaptureDurationTextBox.Height + $($FormScale * 10)
                Width  = $FormScale * 125
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
            }
            $NetworkEndpointPacketCaptureNetshTraceGroupBox.Controls.Add($NetworkEndpointPcapCaptureEtherTypeCheckbox)


                    $NetworkEndpointPacketCaptureEtherTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
                        Left   = $NetworkEndpointPcapCaptureEtherTypeCheckbox.Left
                        Top    = $NetworkEndpointPcapCaptureEtherTypeCheckbox.Top + $NetworkEndpointPcapCaptureEtherTypeCheckbox.Height
                        Width  = $FormScale * 125
                        Height = $FormScale * 50
                        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                        ForeColor = 'Black'
                    }
                    $NetworkEndpointPacketCaptureNetshTraceGroupBox.Controls.Add($NetworkEndpointPacketCaptureEtherTypeComboBox)
                    #$NetworkEndpointPacketCaptureEtherTypeComboBox.Items.Add("")
                    $NetworkEndpointPacketCaptureEtherTypeComboBox.Items.Add("IPv4")
                    $NetworkEndpointPacketCaptureEtherTypeComboBox.Items.Add("IPv6")
                    $NetworkEndpointPacketCaptureEtherTypeComboBox.Items.Add("(IPv4,IPv6)")
                    $NetworkEndpointPacketCaptureEtherTypeComboBox.Items.Add("NOT(IPv4)")
                    $NetworkEndpointPacketCaptureEtherTypeComboBox.Items.Add("NOT(IPv6)")
                    $NetworkEndpointPacketCaptureEtherTypeComboBox.Items.Add("NOT(IPv4,IPv6)")
                    $NetworkEndpointPacketCaptureEtherTypeComboBox.Items.Add("0x0800")
                    $NetworkEndpointPacketCaptureEtherTypeComboBox.Items.Add("NOT(0x0800)")
                    $NetworkEndpointPacketCaptureEtherTypeComboBox.Items.Add("0x86DD")
                    $NetworkEndpointPacketCaptureEtherTypeComboBox.Items.Add("NOT(0x86DD)")
                    $NetworkEndpointPacketCaptureEtherTypeComboBox.Items.Add("0x0806")
                    $NetworkEndpointPacketCaptureEtherTypeComboBox.Items.Add("NOT(0x0806)")
                    $NetworkEndpointPacketCaptureEtherTypeComboBox.Items.Add("Type in your own")


            $NetworkEndpointPcapCaptureProtocolCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
                Text   = "Protocol:"
                Left   = $NetworkEndpointPcapCaptureDestinationMACCheckbox.Left + $NetworkEndpointPcapCaptureDestinationMACCheckbox.Width + $($FormScale * 10)
                Top    = $NetworkEndpointPcapCaptureDestinationMACCheckbox.Top 
                Width  = $FormScale * 125
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
            }
            $NetworkEndpointPacketCaptureNetshTraceGroupBox.Controls.Add($NetworkEndpointPcapCaptureProtocolCheckbox)


                    $NetworkEndpointPacketCaptureProtocolComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
                        Left   = $NetworkEndpointPcapCaptureProtocolCheckbox.Left
                        Top    = $NetworkEndpointPcapCaptureProtocolCheckbox.Top + $NetworkEndpointPcapCaptureProtocolCheckbox.Height
                        Width  = $FormScale * 125
                        Height = $FormScale * 50
                        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                        ForeColor = 'Black'
                    }
                    $NetworkEndpointPacketCaptureNetshTraceGroupBox.Controls.Add($NetworkEndpointPacketCaptureProtocolComboBox)
                    #$NetworkEndpointPacketCaptureProtocolComboBox.Items.Add("")
                    $NetworkEndpointPacketCaptureProtocolComboBox.Items.Add("TCP")
                    $NetworkEndpointPacketCaptureProtocolComboBox.Items.Add("UDP")
                    $NetworkEndpointPacketCaptureProtocolComboBox.Items.Add("ICMP")
                    $NetworkEndpointPacketCaptureProtocolComboBox.Items.Add("NOT(TCP)")
                    $NetworkEndpointPacketCaptureProtocolComboBox.Items.Add("NOT(UDP)")
                    $NetworkEndpointPacketCaptureProtocolComboBox.Items.Add("NOT(ICMP)")
                    $NetworkEndpointPacketCaptureProtocolComboBox.Items.Add("(TCP,UDP)")
                    $NetworkEndpointPacketCaptureProtocolComboBox.Items.Add("NOT(TCP,UDP)")
                    $NetworkEndpointPacketCaptureProtocolComboBox.Items.Add("1")
                    $NetworkEndpointPacketCaptureProtocolComboBox.Items.Add("6")
                    $NetworkEndpointPacketCaptureProtocolComboBox.Items.Add("17")
                    $NetworkEndpointPacketCaptureProtocolComboBox.Items.Add("(1,6,17)")
                    $NetworkEndpointPacketCaptureProtocolComboBox.Items.Add("NOT(1,6,17)")
                    $NetworkEndpointPacketCaptureProtocolComboBox.Items.Add("(1-17)")
                    $NetworkEndpointPacketCaptureProtocolComboBox.Items.Add("Type in your own")        
                    

            $NetworkEndpointPcapCaptureCaptureTypeCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
                Text   = "Capture Type:"
                Left   = $NetworkEndpointPacketCaptureProtocolComboBox.Left
                Top    = $NetworkEndpointPacketCaptureProtocolComboBox.Top  + $NetworkEndpointPacketCaptureProtocolComboBox.Height + $($FormScale * 10) 
                Width  = $FormScale * 125
                Height = $FormScale * 22
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
            }
            $NetworkEndpointPacketCaptureNetshTraceGroupBox.Controls.Add($NetworkEndpointPcapCaptureCaptureTypeCheckbox)


                    $NetworkEndpointPacketCaptureCaptureTypeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
                        Left   = $NetworkEndpointPcapCaptureCaptureTypeCheckbox.Left
                        Top    = $NetworkEndpointPcapCaptureCaptureTypeCheckbox.Top + $NetworkEndpointPcapCaptureCaptureTypeCheckbox.Height
                        Width  = $FormScale * 125
                        Height = $FormScale * 50
                        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                        ForeColor = 'Black'
                    }
                    $NetworkEndpointPacketCaptureNetshTraceGroupBox.Controls.Add($NetworkEndpointPacketCaptureCaptureTypeComboBox)
                    $NetworkEndpointPacketCaptureCaptureTypeComboBox.Items.Add("physical")
                    $NetworkEndpointPacketCaptureCaptureTypeComboBox.Items.Add("vmswitch")
                    $NetworkEndpointPacketCaptureCaptureTypeComboBox.Items.Add("both")
                    
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











$NetworkEndpointPacketCaptureGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text   = "Packet Capture Using PktMon.exe (Windows 10)"
    Left   = $FormScale * 3
    Top    = $NetworkEndpointPacketCaptureNetshTraceGroupBox.Top + $NetworkEndpointPacketCaptureNetshTraceGroupBox.Height + $($FormScale * 10)
    Width  = $FormScale * 435
    Height = $FormScale * 50
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
}

            $PacketCapturePktMonTextbox = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Future Feature: Will be built soon."
                Left   = $FormScale * 7
                Top    = $FormScale * 18
                Width  = $FormScale * 280 #430
                Height = $FormScale * 25
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
            }
            $NetworkEndpointPacketCaptureGroupBox.Controls.Add($PacketCapturePktMonTextbox)


<#
            $PacketCapturePktMonButton = New-Object System.Windows.Forms.Button -Property @{
                Text   = "Regex Examples"
                Left   = $PacketCapturePktMonTextbox.Left + $PacketCapturePktMonTextbox.Width + $($FormScale * 28)
                Top    = $PacketCapturePktMonTextbox.Top
                Width  = $FormScale * 115
                Height = $FormScale * 22
                Add_Click = { Import-Csv "$Dependencies\Reference RegEx Examples.csv" | Out-GridView }
            }
            $NetworkEndpointPacketCaptureGroupBox.Controls.Add($PacketCapturePktMonButton)
            CommonButtonSettings -Button $PacketCapturePktMonButton
#>
$Section1PacketCaptureTab.Controls.Add($NetworkEndpointPacketCaptureGroupBox)








