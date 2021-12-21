
$Section1PacketCaptureTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = "Packet Capture  "
    Left   = $FormScale * 3
    Top    = $FormScale * -10
    Width  = $FormScale * 450
    Height = $FormScale * 20
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
    ImageIndex = 2
}
$MainLeftSection1InteractionsTabTabControl.Controls.Add($Section1PacketCaptureTab)


$NetworkEndpointPacketCaptureNetshTraceGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Left   = $FormScale * 3
    Top    = $FormScale * 5
    Width  = $FormScale * 435
    Height = $FormScale * 265
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
}

        # https://www.computerhope.com/netsh.htm
        # https://docs.microsoft.com/en-us/windows/win32/ndf/using-netsh-to-manage-traces#:~:text=Packet%20filtering%20can%20be%20used,specific%20source%20or%20destination%20address.
        $NetworkEndpointPacketCaptureCheckBox = New-Object System.Windows.Forms.CheckBox -Property @{
            Text     = "Packet Capture using netsh.exe (WinRM)"
            Left     = $FormScale * 7
            Top      = $FormScale * 13
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
                Height = $FormScale * 20
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
                Height = $FormScale * 20
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
                Height = $FormScale * 20
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
                Height = $FormScale * 20
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
                Top    = $FormScale * 30
                Width  = $FormScale * 90
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
            }
            $NetworkEndpointPacketCaptureNetshTraceGroupBox.Controls.Add($NetworkEndpointPcapCaptureDurationLabel)


                    $NetworkEndpointPacketCaptureDurationComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
                        Text   = "15 seconds"
                        Left   = $NetworkEndpointPcapCaptureDurationLabel.Left
                        Top    = $NetworkEndpointPcapCaptureDurationLabel.Top + $NetworkEndpointPcapCaptureDurationLabel.Height
                        Width  = $FormScale * 90
                        Height = $FormScale * 20
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
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
            }
            $NetworkEndpointPacketCaptureNetshTraceGroupBox.Controls.Add($NetworkEndpointPcapCaptureMaxSizeLabel)


                    $NetworkEndpointPacketCaptureMaxSizeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
                        Text   = "50"
                        Left   = $NetworkEndpointPcapCaptureMaxSizeLabel.Left
                        Top    = $NetworkEndpointPcapCaptureMaxSizeLabel.Top + $NetworkEndpointPcapCaptureMaxSizeLabel.Height
                        Width  = $FormScale * 60
                        Height = $FormScale * 20
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
                Height = $FormScale * 20
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
                Height = $FormScale * 20
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
                Width  = $FormScale * 20
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
                Height = $FormScale * 20
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
                    

            $NetworkEndpointPcapCaptureDescriptionLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "[Windows XP+ / Server 2003+] Packet captures from the endpoint perspective can be created using netsh in combination with etl2pcapng. Netsh is a native Windows executable, which is executed on each selected endpoint to produce .etl files (event trace logs). The .etl files are then copied back and locally processed with etl2pcapng (developed by Microsoft), which converts them to the .pcap/.pcapng format.  Since Windows 7 / Server 2008, netsh can be used to enable and configure network traces, while Windows XP, Vista, and Server 2003 require updated service packs and frameworks.`n`nThis method to capture endpoint packet captures is slow and can have a couple minute overtime to capture, process, and clean up files. If interupted, manual cleanup of artifacts may be required.`n`nAddtionally filtering capabilities may be support in future PoSh-EasyWin releases."
                Left   = $NetworkEndpointPacketCaptureDurationComboBox.Left
                Top    = $NetworkEndpointPacketCaptureDurationComboBox.Top + $NetworkEndpointPacketCaptureDurationComboBox.Height + $($FormScale * 10) 
                Width  = $FormScale * 425
                Height = $FormScale * 180
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
            }
            $NetworkEndpointPacketCaptureNetshTraceGroupBox.Controls.Add($NetworkEndpointPcapCaptureDescriptionLabel)
                                      
                    
<#
            $NetworkEndpointPcapCaptureSeverityLevelCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
                Text   = "Severity Level:"
                Left   = $NetworkEndpointPacketCaptureProtocolComboBox.Left
                Top    = $NetworkEndpointPacketCaptureProtocolComboBox.Top  + $NetworkEndpointPacketCaptureProtocolComboBox.Height + $($FormScale * 5) 
                Width  = $FormScale * 125
                Height = $FormScale * 20
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
Update-FormProgress "$Dependencies\Code\Main Body\Show-PktMon.ps1"
. "$Dependencies\Code\Main Body\Show-PktMon.ps1"

$NetworkEndpointPacketCaptureGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text   = "Packet Capture using PktMon.exe (WinRM)"
    Left   = $FormScale * 3
    Top    = $NetworkEndpointPacketCaptureNetshTraceGroupBox.Top + $NetworkEndpointPacketCaptureNetshTraceGroupBox.Height + $($FormScale * 10)
    Width  = $FormScale * 435
    Height = $FormScale * 220
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
}

            $PacketCapturePktMonLaunchButton = New-Object System.Windows.Forms.Button -Property @{
                Text   = 'Launch PktMon GUI'
                Left   = $FormScale * 7
                Top    = $FormScale * 18
                Width  = $FormScale * 125
                Height = $FormScale * 20
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
                Add_Click = {
                    if ($script:ComputerList.Count -gt 0) {
                        Show-PktMon
                    }
                    else {
                        [System.Windows.Forms.MessageBox]::Show("You need to select one or more endpoints first.","PoSh-EasyWin",'Ok',"Info")
                    }
                }
            }
            $NetworkEndpointPacketCaptureGroupBox.Controls.Add($PacketCapturePktMonLaunchButton)
            Apply-CommonButtonSettings -Button $PacketCapturePktMonLaunchButton


            $PacketCapturePktMonTextbox = New-Object System.Windows.Forms.Label -Property @{
                Text   = "[Windows 10+ / Server 2019+] Packet captures from the endpoint perspective can be created using pktmon. Packet Monitor (pktmon) is a native Windows executable which can produce .pcap/.pcapng formatted files since Windows 10 / Server 2019. It contains many advanced packet filtering features, such as for IPs, ports, and protocols. In addtion to traditionaly hardware based systems, this tool is especially helpful in virtualization scenarios, like container networking and SDN, because it provides visibility within the networking stack.`n`nThis method is much faster than using netsh and etl2pcapng. Implementation within PoSh-EasyWin is session based, and allows you to connect to multiple endpoints while still using unique filters for each endpoint.`n`nAddtionally capabilities will be added in future PoSh-EasyWin releases."
                Left   = $PacketCapturePktMonLaunchButton.Left
                Top    = $PacketCapturePktMonLaunchButton.Top + $PacketCapturePktMonLaunchButton.Height + $($FormScale * 5) 
                Width  = $FormScale * 425
                Height = $FormScale * 165
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
            }
            $NetworkEndpointPacketCaptureGroupBox.Controls.Add($PacketCapturePktMonTextbox)

$Section1PacketCaptureTab.Controls.Add($NetworkEndpointPacketCaptureGroupBox)



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUXUGQbxyJmj9k7NhZMOf4KZp+
# 3amgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUn49EdOA5O5g5AYg/u21EWwpV+agwDQYJKoZI
# hvcNAQEBBQAEggEAYzH0XIRMoR4bdCj2DOER3IT9v6zr/3Z0K8cvxfpM/GEAH3R8
# BjnSd7JbC2EFXPO60Yb7H+b67GIWpDNW9NFCxntwjBVSgXD/xMrz/r503Zn7DorA
# SIUNCoQWjaNBDsyuzXwcpU9wNQcQbSn71fE7AneFjE/gr1y96U9CKSttrJc7fzTT
# ZS+I7i1ip4qXDKPxb5Nj6s+c5rDL7i/Tg1XfXRqtBoNPvTadRvDDdIXDrTmkFHrS
# W9lrKJYklZGsrqaCId2rPz9uhO7dO6kkdA5G+9i8lMwuDP9gxnFienWBvk1a06JY
# +xyH65BeuXI0oljmMcHDGC3/td2fmOUOq+LXAA==
# SIG # End signature block
