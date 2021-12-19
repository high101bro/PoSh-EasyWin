function script:Launch-NetworkConnectionGUI {
    $script:PSWriteHTMLSupportForm = New-Object System.Windows.Forms.Form -Property @{
        Text    = 'PoSh-EasyWin'
        Width   = $FormScale * 325
        Height  = $FormScale * 350
        StartPosition = "CenterScreen"
        TopMost = $false
        Icon    = [System.Drawing.Icon]::ExtractAssociatedIcon("$script:EasyWinIcon")
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


   
# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUb5OzoWCEntsol1MjjqheNvgY
# OASgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU0QV3dbdc6N7nniIDUrMoHZImz+UwDQYJKoZI
# hvcNAQEBBQAEggEAPxyiniKg/s5Sr13w++ha5r9TADNWVG7RwruZG01nB7QaIEDn
# cHqFjIYnyH2kCg4AmngrUf9Yq931l9I/zN/P371D2DLgs+e93ECgPCreYb2JAwT8
# mIr/XgTyQhmqugJNUoqStXH9ap5TyRt4lvfMwKhKaAdQGTbtaKAGcZoD/YZJwBbM
# vA8NqFbu8OulerX4p0gpU7WW3ocM4c52tbXuBfCBhe3Y9Yu7QZ7aGd+wII3bpFT/
# NL4pKZymordEUG1qrZCOLI/Ukh6RBcH8ah0pfmQnl4bJ+CNmZdnvLLINtf2XVyoR
# 3RE5ZqS2mheWtjFsIM14FGMF77cOxnWg5+AsbA==
# SIG # End signature block
