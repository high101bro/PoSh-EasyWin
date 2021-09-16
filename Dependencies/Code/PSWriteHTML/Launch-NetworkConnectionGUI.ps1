function script:Launch-NetworkConnectionGUI {
    $script:PSWriteHTMLSupportForm = New-Object System.Windows.Forms.Form -Property @{
        Text    = 'PoSh-EasyWin'
        Width   = $FormScale * 325
        Height  = $FormScale * 350
        StartPosition = "CenterScreen"
        TopMost = $false
        Icon    = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        Font    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        FormBorderStyle =  'Sizable' #  Fixed3D, FixedDialog, FixedSingle, FixedToolWindow, None, Sizable, SizableToolWindow
        ShowIcon        = $true
        showintaskbar   = $false
        ControlBox      = $true
        MaximizeBox     = $false
        MinimizeBox     = $true
        AutoScroll      = $True
        Add_Closing = { $This.dispose() }
    }


    $script:PoShEasyWinIPToExcludeLabel = New-Object System.Windows.Forms.Label -Property @{
        Text   = "Enter PoSh-EasyWin's IP. This will place it as an icon within various graphs for easy recognition, like network connections."
        Left   = $FormScale * 5
        Top    = $FormScale * 5
        Width  = $FormScale * 280
        Height = $FormScale * 40
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $script:PSWriteHTMLSupportForm.Controls.Add($script:PoShEasyWinIPToExcludeLabel)


                $script:ConnectionStatesFilterCheckedListBox = New-Object -TypeName System.Windows.Forms.CheckedListBox -Property @{
                    Left   = $script:PoShEasyWinIPToExcludeLabel.Left
                    Top    = $script:PoShEasyWinIPToExcludeLabel.Top + $script:PoShEasyWinIPToExcludeLabel.Height
                    Width  = $script:PoShEasyWinIPToExcludeLabel.Width
                    Height = $FormScale * 90
                    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                    ScrollAlwaysVisible = $true
                }
                $ConnectionFilterStates = @('Established','TimeWait','CloseWait','Listen','Bound','All Others: Closed,Closing,DeleteTCB,FinWait1,FinWait2,LastAck,SynReceived,SynSent')
                        foreach ( $State in $ConnectionFilterStates ) { 
                            $script:ConnectionStatesFilterCheckedListBox.Items.Add($State) 
                        }                
                        if ((Test-Path "$PoShHome\Settings\Network Connection Selected States.txt")){
                            $ConnectionFilterStatesImportedChecked = Get-Content "$PoShHome\Settings\Network Connection Selected States.txt"
                            foreach ($State in $ConnectionFilterStatesImportedChecked) {
                                Set-CheckState -Check -CheckedlistBox $script:ConnectionStatesFilterCheckedListBox -Match $State
                            }
                            $script:PSWriteHTMLSupportForm.Controls.Add($script:ConnectionStatesFilterCheckedListBox)
                        }
                        else {
                            $ConnectionFilterStatesDefaultChecked = @('Established','TimeWait','CloseWait')
                            foreach ($State in $ConnectionFilterStatesDefaultChecked) {
                                Set-CheckState -Check -CheckedlistBox $script:ConnectionStatesFilterCheckedListBox -Match $State
                            }
                            $script:PSWriteHTMLSupportForm.Controls.Add($script:ConnectionStatesFilterCheckedListBox)    
                        }

    
                $script:PSWriteHTMLResolveDNSCheckbox = New-Object System.Windows.Forms.checkbox -Property @{
                    Text   = "Resolve DNS"
                    Left   = $script:ConnectionStatesFilterCheckedListBox.Left
                    Top    = $script:ConnectionStatesFilterCheckedListBox.Top + $script:ConnectionStatesFilterCheckedListBox.Height
                    Width  = $script:ConnectionStatesFilterCheckedListBox.Width / 3
                    Height = $FormScale * 22
                    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                    checked = $false
                }
                $script:PSWriteHTMLSupportForm.Controls.Add($script:PSWriteHTMLResolveDNSCheckbox)


                            $script:PSWriteHTMLNameServerLabel = New-Object System.Windows.Forms.Label -Property @{
                                Text   = "Name Server:"
                                Left   = $script:PSWriteHTMLResolveDNSCheckbox.Left + $script:PSWriteHTMLResolveDNSCheckbox.Width
                                Top    = $script:PSWriteHTMLResolveDNSCheckbox.Top + ($FormScale * 4)
                                Width  = $script:PSWriteHTMLResolveDNSCheckbox.Width
                                Height = $FormScale * 22
                                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                            }
                            $script:PSWriteHTMLSupportForm.Controls.Add($script:PSWriteHTMLNameServerLabel)


                            $script:PSWriteHTMLNameServerTextBox = New-Object System.Windows.Forms.TextBox -Property @{
                                Text   = "Disabled"
                                Left   = $script:PSWriteHTMLNameServerLabel.Left + $script:PSWriteHTMLNameServerLabel.Width
                                Top    = $script:PSWriteHTMLNameServerLabel.Top
                                Width  = $script:PSWriteHTMLNameServerLabel.Width - ($FormScale * 5)
                                Height = $FormScale * 22
                                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                                Enabled = $false
                            }
                            $script:PSWriteHTMLSupportForm.Controls.Add($script:PSWriteHTMLNameServerTextBox)


                $script:PSWriteHTMLExcludeIPv6FromGraphsCheckbox = New-Object System.Windows.Forms.checkbox -Property @{
                    Text    = "Exclude IPv6"
                    Left    = $script:PSWriteHTMLResolveDNSCheckbox.Left
                    Top     = $script:PSWriteHTMLResolveDNSCheckbox.Top + $script:PSWriteHTMLResolveDNSCheckbox.Height
                    Width   = $script:PSWriteHTMLResolveDNSCheckbox.Width
                    Height  = $FormScale * 22
                    Font    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                    checked = $true
                }
                $script:PSWriteHTMLSupportForm.Controls.Add($script:PSWriteHTMLExcludeIPv6FromGraphsCheckbox)


                $script:PSWriteHTMLExcludeEasyWinFromGraphsCheckbox = New-Object System.Windows.Forms.checkbox -Property @{
                    Text    = "Exclude the following from the Graphs"
                    Left    = $script:PSWriteHTMLExcludeIPv6FromGraphsCheckbox.Left
                    Top     = $script:PSWriteHTMLExcludeIPv6FromGraphsCheckbox.Top + $script:PSWriteHTMLExcludeIPv6FromGraphsCheckbox.Height
                    Width   = $script:ConnectionStatesFilterCheckedListBox.Width
                    Height  = $FormScale * 22
                    Font    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                    checked = $true
                }
                $script:PSWriteHTMLSupportForm.Controls.Add($script:PSWriteHTMLExcludeEasyWinFromGraphsCheckbox)


                $script:IPAddressesToExcludeTextbox = New-Object System.Windows.Forms.TextBox -Property @{
                    Left   = $script:PSWriteHTMLExcludeEasyWinFromGraphsCheckbox.Left
                    Top    = $script:PSWriteHTMLExcludeEasyWinFromGraphsCheckbox.Top + $script:PSWriteHTMLExcludeEasyWinFromGraphsCheckbox.Height
                    Width  = $script:PoShEasyWinIPToExcludeLabel.Width
                    Height = $FormScale * 80
                    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                    Multiline  = $true
                    ScrollBars = 'Vertical'
            #        ScrollAlwaysVisible = $true
                }
                $script:PSWriteHTMLSupportForm.Controls.Add($script:IPAddressesToExcludeTextbox)
                if ((Test-Path "$PoShHome\Settings\Network Connection IP's to Exclude.txt")){
                    $script:IPAddressesToExcludeTextbox.text = ''
                    foreach ($line in (Get-Content "$PoShHome\Settings\Network Connection IP's to Exclude.txt")) {
                        $script:IPAddressesToExcludeTextbox.text += "$line`r`n"
                    }
                }
                else {
                    $DefaultIPListToExclude = @('127.0.0.1','0.0.0.0','::1','::')
                    $script:IPAddressesToExcludeTextbox.text = ''
                    foreach ($IP in $DefaultIPListToExclude) {
                        $script:IPAddressesToExcludeTextbox.text += "$IP`r`n"
                    }                    
                }


    $PSWriteHTMLSupportOkayButton = New-Object System.Windows.Forms.Button -Property @{
        Text   = 'Okay'
        Left   = $script:IPAddressesToExcludeTextbox.Left
        Top    = $script:IPAddressesToExcludeTextbox.Top + $script:IPAddressesToExcludeTextbox.Height + $($FormScale * 5)
        Width  = $FormScale * 100
        Height = $FormScale * 22
        Add_Click = {
            $script:ConnectionStatesFilterCheckedListBox.CheckedItems | Set-Content "$PoShHome\Settings\Network Connection Selected States.txt"

            $script:IPAddressesToExcludeTextbox.text | Set-Content "$PoShHome\Settings\Network Connection IP's to Exclude.txt"

            $script:IPAddressesToExcludeTextboxtext = $script:IPAddressesToExcludeTextbox.text
            $script:PSWriteHTMLExcludeEasyWinFromGraphsCheckboxchecked = $script:PSWriteHTMLExcludeEasyWinFromGraphsCheckbox.checked
            $script:PSWriteHTMLExcludeIPv6FromGraphsCheckboxchecked = $script:PSWriteHTMLExcludeIPv6FromGraphsCheckbox.checked

            $script:PSWriteHTMLSupportForm.close()
        }
    }
    $script:PSWriteHTMLSupportForm.Controls.Add($PSWriteHTMLSupportOkayButton)
    Apply-CommonButtonSettings -Button $PSWriteHTMLSupportOkayButton

    $script:PSWriteHTMLSupportForm.ShowDialog()    
}